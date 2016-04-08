//
//  RootViewController.h
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController
    : UITableViewController<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

@property (weak, nonatomic) IBOutlet UILabel *roomName;
@property (weak, nonatomic) IBOutlet UILabel *printerName;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UILabel *budgetLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;

@property (weak, nonatomic) IBOutlet UILabel *pagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *duplexLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperLabel;


@property (weak, nonatomic) IBOutlet UIView *firstStartView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)startPrintJob;
@end
