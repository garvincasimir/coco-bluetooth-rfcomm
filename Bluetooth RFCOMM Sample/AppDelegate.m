//
//  AppDelegate.m
//  Coco Test
//
//  Created by Worker PC on 6/12/13.
//  Copyright (c) 2013 Worker PC. All rights reserved.
//

#import "AppDelegate.h"

#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction) clearText: sender
{
    [textView setString: @" "];
}

- (IBAction) hello: sender
{
    NSString* myString= @"I am doing ok Android. Thanks for asking";
    
    NSData* dt=[myString dataUsingEncoding: [NSString defaultCStringEncoding] ];
    
    [self sendMessage:dt];
    
}

-(void)sendMessage:(NSData *)dataToSend
{
    [self log:@"Sending Message\n"];
    [mRFCOMMChannel writeSync:(void*)dataToSend.bytes length:dataToSend.length];
}

-(void)log:(NSString *)text
{
   NSString *t = [textView string];
    
 id new = [t stringByAppendingString:text];
    
 [textView setString: new];
    
   
}


- (IBAction) discover:(id)sender
{
    IOBluetoothDeviceSelectorController  *deviceSelector;
    IOBluetoothSDPUUID                                      *sppServiceUUID;
    NSArray                                                         *deviceArray;
    IOBluetoothRFCOMMChannel *chan;
    
    [self log: @"Attempting to connect\n" ];
    
    // The device selector will provide UI to the end user to find a remote device
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
    
    if ( deviceSelector == nil ) {
        [self log: @"Error - unable to allocate IOBluetoothDeviceSelectorController.\n" ];
        return;
    }
    
    sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
    [deviceSelector addAllowedUUID:sppServiceUUID];
    if ( [deviceSelector runModal] != kIOBluetoothUISuccess ) {
        [self log: @"User has cancelled the device selection.\n" ];
        return;
    }
deviceArray = [deviceSelector getResults];
if ( ( deviceArray == nil ) || ( [deviceArray count] == 0 ) ) {
    [self log: @"Error - no selected device.  ***This should never happen.***\n" ];
    return;
}
IOBluetoothDevice *device = [deviceArray objectAtIndex:0];
IOBluetoothSDPServiceRecord     *sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
if ( sppServiceRecord == nil ) {
    [self log: @"Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n" ];
    return;
}
// To connect we need a device to connect and an RFCOMM channel ID to open on the device:
UInt8   rfcommChannelID;
if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess ) {
    [self log: @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" ];
    return;
}

// Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
if ( ( [device openRFCOMMChannelAsync:&chan withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && ( chan != nil ) ) {
    // Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
    // those details). If the device connection is left open close it and return an error:
   [self log: @"Error - open sequence failed.***\n" ];
    [self close:device];
    return;
}

    mRFCOMMChannel = chan;

}


- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    
    if ( error != kIOReturnSuccess ) {
        [self log:@"Error - failed to open the RFCOMM channel with error %08lx.\n"];

        return;
    }
    else{
        [self log:@"Connected\n"];
    }
    
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
   
     NSString  *message = [[NSString alloc] initWithBytes:dataPointer length:dataLength encoding:NSUTF8StringEncoding];
    [self log:message];
    [self log:@"\n"];
}

@end
