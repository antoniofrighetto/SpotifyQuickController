//
//  ViewController.m
//  Spotify Quick Controller
//
//  Created by Antonio Frighetto on 13/07/15.
//  Copyright (c) 2015 Antonio Frighetto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@implementation ViewSubclass

- (void)drawRect:(NSRect)aRect
{
    NSArray *arrayOfColors = @[[NSColor whiteColor], [NSColor lightGrayColor], [NSColor grayColor]];
    NSGradient *gradient = [[NSGradient alloc] initWithColors:arrayOfColors];
    NSRect windowFrame = [self frame];
    [gradient drawInRect:windowFrame angle:90];
}

@end