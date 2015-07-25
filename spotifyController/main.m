//
//  main.m
//  spotifyController
//
//  Created by Antonio Frighetto on 11/06/15.
//  Copyright (c) 2015 Antonio Frighetto. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}