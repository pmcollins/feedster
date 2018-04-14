//
//  AbstractAdViewController.m
//  XReader
//
//  Created by Pablo Collins on 2/17/13.
//

#import "AbstractAdViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "XReaderAppDelegate.h"

#define kAdViewDefaultOffset 138
#define kAdViewDefaultHiddenOffset 44

@interface AbstractAdViewController ()

@end

@implementation AbstractAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isFullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefFullVersion];

    if (!isFullVersion) {
        _adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] applicationFrame].size.height - kAdViewDefaultOffset, 0, 0)];
        _adView.hidden = YES;
        _adView.delegate = self;
        _adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        [self.view addSubview:_adView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //if the user just upgraded, blow away the adview
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPrefFullVersion] && _adView) {
        [self hideAdView];
        [_adView removeFromSuperview];
        _adView = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAdView
{
    _tableView.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] applicationFrame].size.height - 88);
    _adView.hidden = YES;
}

#pragma mark - ADBannerViewDelegate

// This method is invoked when the banner has confirmation that an ad will be presented, but before the ad
// has loaded resources necessary for presentation.
- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
//    NSLog(@"bannerViewWillLoadAd: %@", banner);
}

// This method is invoked each time a banner loads a new advertisement. Once a banner has loaded an ad,
// it will display that ad until another ad is available. The delegate might implement this method if
// it wished to defer placing the banner in a view hierarchy until the banner has content to display.
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    _tableView.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] applicationFrame].size.height - 88 - 48);
    _adView.hidden = NO;
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self hideAdView];
}

// This message will be sent when the user taps on the banner and some action is to be taken.
// Actions either display full screen content in a modal session or take the user to a different
// application. The delegate may return NO to block the action from taking place, but this
// should be avoided if possible because most advertisements pay significantly more when
// the action takes place and, over the longer term, repeatedly blocking actions will
// decrease the ad inventory available to the application. Applications may wish to pause video,
// audio, or other animated content while the advertisement's action executes.
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
//    NSLog(@"bannerViewActionShouldBegin: %@ willLeaveApplication: %d", banner, willLeave);
    return YES;
}

// This message is sent when a modal action has completed and control is returned to the application.
// Games, media playback, and other activities that were paused in response to the beginning
// of the action should resume at this point.
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
//    NSLog(@"bannerViewActionDidFinish: %@", banner);
}

@end
