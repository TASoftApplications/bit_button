//
//  AppDelegate.m
//  Bit Button
//
//  Created by Thomas Abplanalp on 02.01.17.
//  Copyright (c) 2017 TASoft Applications. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.options = 13;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
