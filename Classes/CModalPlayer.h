//
//  CModalPlayer.h
//  XReader
//
//  Created by Pablo Collins on 9/26/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface CModalPlayer : UIViewController <PlayerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *currTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *playPauseBtn;
@property (strong, nonatomic) IBOutlet UIButton *rwdButton;
@property (strong, nonatomic) IBOutlet UIButton *ffwdBtn;
@property (strong, nonatomic) IBOutlet UILabel *rwdLabel;
@property (strong, nonatomic) IBOutlet UILabel *ffwdLabel;

@property (weak, nonatomic) UIViewController *opener;
@property (strong, nonatomic) IBOutlet UIView *controlPanel;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)buttonTouched:(id)sender;
- (IBAction)sliderMoved;
- (IBAction)hide:(id)sender;
- (void)removeAsPlayerDelegate;
- (IBAction)rwdTouched;
- (IBAction)ffwdTouched;

@end
