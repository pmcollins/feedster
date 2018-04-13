//
//  XReaderAppDelegate.h
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPrefPodcastAutoDownloads @"prefPodcastAutoDownloads"
#define kPrefFeedAutoUpdates @"prefFeedAutoUpdates"

#define kPrefFullVersion @"prefFullVersion"

@interface XReaderAppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSString *)applicationDocumentsDirectory;

@end
