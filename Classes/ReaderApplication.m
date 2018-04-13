//
//  ReaderApplication.m
//  XReader
//
//  Created by Pablo Collins on 5/29/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "ReaderApplication.h"
#import "Player.h"

@implementation ReaderApplication

#pragma mark - Events

/*
 UIEventSubtypeRemoteControlPlay                 = 100,
 UIEventSubtypeRemoteControlPause                = 101,
 UIEventSubtypeRemoteControlStop                 = 102,
 UIEventSubtypeRemoteControlTogglePlayPause      = 103,
 UIEventSubtypeRemoteControlNextTrack            = 104,
 UIEventSubtypeRemoteControlPreviousTrack        = 105,
 UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
 UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
 UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
 UIEventSubtypeRemoteControlEndSeekingForward    = 109,
 */

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    if (event.type == UIEventTypeRemoteControl) {
        Player *player = [Player sharedInstance];
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [player resume];
                break;
            case UIEventSubtypeRemoteControlPause:
                [player pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                [player pause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [player togglePlayedState];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [player ffwd:30];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [player ffwd:-30];
                break;
            default:
                break;
        }
    }
}

@end
