//
//  FormatViewController.m
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "FormatViewController.h"

@interface FormatViewController ()

@end

@implementation FormatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updatePrintJob];
    
    self.onepageButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.longbindButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.shortbindButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.onepageButton.layer.borderWidth = 0.5;
    self.onepageButton.layer.cornerRadius = 8;
    self.longbindButton.layer.borderWidth = 0.5;
    self.longbindButton.layer.cornerRadius = 8;
    self.shortbindButton.layer.borderWidth = 0.5;
    self.shortbindButton.layer.cornerRadius = 8;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePrintJob)
                                                 name:ETHZVPPFileChangedNotification
                                               object:nil];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.firstPage.contentInset = UIEdgeInsetsMake(0, self.firstPage.contentInset.left, 0, self.firstPage.frame.size.width-self.firstPage.contentInset.left-240);
    self.lastPage.contentInset = UIEdgeInsetsMake(0, self.lastPage.contentInset.left, 0, self.lastPage.frame.size.width-self.lastPage.contentInset.left-240);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updatePrintJob
{
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];

    
    self.sortedSwitch.on = job.sorted;


   self.flagpageSwitch.on = job.flagpage;
    
    NSString *example = @"1, 1, 1, 2, 2, 2, 3, 3, 3";
    if (job.sorted) {
        example = @"1, 2, 3, 1, 2, 3, 1, 2, 3";
    }
    if (job.flagpage) {
        example = [@"F, " stringByAppendingString:example];
    }
    
    self.copiesExampleLabel.text = example;
    
    if (job.pagesPerSheet == 1) {
        self.perSheetSegmented.selectedSegmentIndex = 0;
    }
    else if (job.pagesPerSheet == 2) {
        self.perSheetSegmented.selectedSegmentIndex = 1;
    }
    else if (job.pagesPerSheet4Landscape) {
        self.perSheetSegmented.selectedSegmentIndex = 3;
    }
    else {
        self.perSheetSegmented.selectedSegmentIndex = 2;
    }
    
    self.pageSizeSegmented.selectedSegmentIndex = 4-job.pageSizeA;
    
    self.paperTypeSegmented.selectedSegmentIndex = job.paper;
    
    [self.oneNup performSelector:@selector(updateNumbers)];
    [self.longbindNup performSelector:@selector(updateNumbers)];
    [self.shortbindNup performSelector:@selector(updateNumbers)];
    
    [self.firstPage reloadData];
    [self.lastPage reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.firstPage.contentOffset = CGPointMake((job.firstPage-1)*50, 0);
        self.lastPage.contentOffset = CGPointMake((job.lastPage-1)*50, 0);
    });
    
    
    
    
    switch (job.duplex) {
        case ETHZDuplexTypeNone:
            self.onepageButton.layer.borderColor = [UIColor colorWithRed:0.09 green:0.49 blue:0.98 alpha:1].CGColor;
            self.shortbindButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.longbindButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.oneNup.alpha = 1;
            self.longbindNup.alpha = 0.2;
            self.shortbindNup.alpha = 0.2;
            break;
            
        case ETHZDuplexTypeLongbind:
            self.longbindButton.layer.borderColor = [UIColor colorWithRed:0.09 green:0.49 blue:0.98 alpha:1].CGColor;
            self.shortbindButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.onepageButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.oneNup.alpha = 0.2;
            self.longbindNup.alpha = 1;
            self.shortbindNup.alpha = 0.2;
            break;
            
        case ETHZDuplexTypeShortbind:
            self.shortbindButton.layer.borderColor = [UIColor colorWithRed:0.09 green:0.49 blue:0.98 alpha:1].CGColor;
            self.onepageButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.longbindButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.oneNup.alpha = 0.2;
            self.longbindNup.alpha = 0.2;
            self.shortbindNup.alpha = 1;
            break;
    }

}

- (void)updateNumbers {
    
}

- (void)configChanged:(id)sender {
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];

    job.sorted = self.sortedSwitch.on;
    job.flagpage = self.flagpageSwitch.on;
    
    if (self.perSheetSegmented.selectedSegmentIndex == 0) {
        job.pagesPerSheet = 1;
        job.pagesPerSheet4Landscape = NO;
    }
    else if (self.perSheetSegmented.selectedSegmentIndex == 1) {
        job.pagesPerSheet = 2;
        job.pagesPerSheet4Landscape = NO;
    }
    else if (self.perSheetSegmented.selectedSegmentIndex == 2) {
        job.pagesPerSheet = 4;
        job.pagesPerSheet4Landscape = NO;
    }
    else if (self.perSheetSegmented.selectedSegmentIndex == 3) {
        job.pagesPerSheet = 4;
        job.pagesPerSheet4Landscape = YES;
    }
    
    job.pageSizeA = 4-self.pageSizeSegmented.selectedSegmentIndex;
    
    job.paper = self.paperTypeSegmented.selectedSegmentIndex;
    
    [self.oneNup performSelector:@selector(updateNumbers)];
    [self.longbindNup performSelector:@selector(updateNumbers)];
    [self.shortbindNup performSelector:@selector(updateNumbers)];
    
    
    NSString *example = @"1, 1, 1, 2, 2, 2, 3, 3, 3";
    if (job.sorted) {
        example = @"1, 2, 3, 1, 2, 3, 1, 2, 3";
    }
    if (job.flagpage) {
        example = [@"F, " stringByAppendingString:example];
    }
    
    self.copiesExampleLabel.text = example;
    
    
    [job writeToDisk];
    [job postChangeNotification];
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)setDuplexOnepage:(id)sender {
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    job.duplex = ETHZDuplexTypeNone;
    [job writeToDisk];
    [job postChangeNotification];
    [self updatePrintJob];
}
- (IBAction)setDuplexLongbind:(id)sender {
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    job.duplex = ETHZDuplexTypeLongbind;
    [job writeToDisk];
    [job postChangeNotification];
    [self updatePrintJob];
}
- (IBAction)setDuplexShortbind:(id)sender {
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    job.duplex = ETHZDuplexTypeShortbind;
    [job writeToDisk];
    [job postChangeNotification];
    [self updatePrintJob];
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    return job.pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    NSString *title;
    switch (indexPath.row+1) {
        case 5: title = @"✋"; break;
        case 8: title = @"🎱"; break;
        case 12: title = @"XII"; break;
        case 17: title = @"📅"; break;
        case 18: title = @"🔞"; break;
        case 21: title = @"♠️"; break;
        case 42: title = @"🚀"; break;
            
            
        default:
            title = @(indexPath.row+1).description;
            break;
    }
    [(UILabel *)[cell viewWithTag:42] setText:title];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.firstPage)
    {
        self.lastPage.contentOffset = CGPointMake(MAX(self.firstPage.contentOffset.x, self.lastPage.contentOffset.x), 0);
    }
    if(scrollView == self.lastPage)
    {
        self.firstPage.contentOffset = CGPointMake(MIN(self.firstPage.contentOffset.x, self.lastPage.contentOffset.x), 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    if(scrollView == self.firstPage)
    {
        targetContentOffset->x = roundf((targetContentOffset->x) / 50.0f) * 50;
        
        ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
        job.firstPage = roundf((targetContentOffset->x) / 50.0f) + 1;
        [job writeToDisk];
        [job postChangeNotification];
    }
    if(scrollView == self.lastPage)
    {
        targetContentOffset->x = roundf((targetContentOffset->x) / 50.0f) * 50;
        
        ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
        job.lastPage = roundf((targetContentOffset->x) / 50.0f) + 1;
        [job writeToDisk];
        [job postChangeNotification];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if(scrollView == self.firstPage)
        {
            self.lastPage.contentOffset = CGPointMake(roundf((self.lastPage.contentOffset.x) / 50.0f) * 50, 0);
        }
        if(scrollView == self.lastPage)
        {
            self.firstPage.contentOffset = CGPointMake(roundf((self.firstPage.contentOffset.x) / 50.0f) * 50, 0);
        }
    } completion:nil];
    
    
}

@end
