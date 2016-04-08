//
//  FormatViewController.h
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormatViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *oneNup;
@property (weak, nonatomic) IBOutlet UIImageView *longbindNup;
@property (weak, nonatomic) IBOutlet UIImageView *shortbindNup;

@property (weak, nonatomic) IBOutlet UILabel *sortedLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sortedSwitch;

@property (weak, nonatomic) IBOutlet UILabel *copiesExampleLabel;

@property (weak, nonatomic) IBOutlet UILabel *flagpageLabel;
@property (weak, nonatomic) IBOutlet UISwitch *flagpageSwitch;

- (IBAction)configChanged:(id)sender;

- (IBAction)setDuplexOnepage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *onepageButton;
@property (weak, nonatomic) IBOutlet UIButton *longbindButton;
- (IBAction)setDuplexLongbind:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *shortbindButton;
- (IBAction)setDuplexShortbind:(id)sender;


@property (weak, nonatomic) IBOutlet UISegmentedControl *perSheetSegmented;

@property (weak, nonatomic) IBOutlet UISegmentedControl *pageSizeSegmented;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paperTypeSegmented;


@property (weak, nonatomic) IBOutlet UICollectionView *firstPage, *lastPage;

@end
