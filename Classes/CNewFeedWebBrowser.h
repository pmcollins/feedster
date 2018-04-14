//
//  CNewFeedWebBrowser.h
//  XReader
//
//  Created by Pablo Collins on 10/22/12.
//

#import <UIKit/UIKit.h>
#import "CNewFeedForm.h"
#import "FeedExplorerDelegate.h"

@interface CNewFeedWebBrowser : UIViewController <UIWebViewDelegate, FeedExplorerDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) CNewFeedForm *cNewFeedForm;
@property (nonatomic, assign) NSString *startingUrl;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)cancelTouched:(id)sender;
- (IBAction)segControlValueChanged:(id)sender;
- (void)exploreForEmbeddedFeedUrl:(NSURL *)url;

@end
