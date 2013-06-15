//
//  AppDelegate.h
//  Coco Test
//
//  Created by Worker PC on 6/12/13.
//  Copyright (c) 2013 Worker PC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet id textView;

    IOBluetoothRFCOMMChannel *mRFCOMMChannel;
    
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction) clearText: sender;

- (IBAction) discover: sender;

- (IBAction) hello: sender;

- (void)close:(IOBluetoothDevice*)device;

@end
