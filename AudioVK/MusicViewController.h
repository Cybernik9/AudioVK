//
//  MusicViewController.h
//  AudioVK
//
//  Created by Yurii Huber on 15.11.15.
//  Copyright © 2015 Yurii Huber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicViewController : UIViewController

@property (strong, nonatomic) NSString* ownerId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *artistLable;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet UILabel *endTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLable;

@property (weak, nonatomic) IBOutlet UIButton *playStopButton;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;

- (IBAction)actionPlayStopMusic:(id)sender;
- (IBAction)actionSlider:(id)sender;
- (IBAction)actionBeginChangeValue:(id)sender;
- (IBAction)actionEndChangeValue:(id)sender;
- (IBAction)actionSliderEndValue:(id)sender;

@end
