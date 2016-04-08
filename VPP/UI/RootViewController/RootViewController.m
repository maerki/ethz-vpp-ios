//
//  RootViewController.m
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "RootViewController.h"
#import "ETHZPrintJob+NethzLoader.h"
#import "ETHPrintManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Customize UI
    self.printButton.layer.cornerRadius = 5.0f;
//    self.previewImageView.layer.borderWidth = 0.5f;
//    self.previewImageView.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor;

//    self.previewImageView.layer.shadowRadius = 0.5;
//    self.previewImageView.layer.shadowOpacity = 0.5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePrintJob)
                                                 name:ETHZVPPFileChangedNotification
                                               object:nil];
    [self updatePrintJob];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, self.collectionView.contentInset.left, 0, self.collectionView.frame.size.width-self.collectionView.contentInset.left-240);
}


- (void)updatePrintJob
{
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.collectionView.contentOffset = CGPointMake((job.copies-1)*50, 0);
    });

    self.previewImageView.image = [job previewImage];

    if(job.fileName.length)
    {
        self.titleLabel.text = job.fileName;
        self.titleLabel.alpha = 1.0f;
        self.printButton.enabled = YES;
        self.titleLabel.hidden = NO;
        self.printButton.hidden = NO;
        self.firstStartView.hidden = YES;
    }
    else
    {
        self.titleLabel.text = nil;
        self.titleLabel.hidden = YES;
        self.printButton.hidden = YES;
        self.firstStartView.hidden = NO;
    }

    if (job.printer.length == 0) {
        self.roomName.text = [job.room stringByReplacingOccurrencesOfString:@"STUD" withString:@" STUD"];
        self.printerName.text = NSLocalizedString(@"Alle", nil);
    }
    else {
        self.roomName.text = job.room;
        self.printerName.text = job.printer;
    }
    

    self.usernameField.text = job.nethzName.description;
    self.budgetLabel.text = job.budget.description;
    self.codeLabel.text = job.code.description;

    NSString *sortType;
    if(job.copies <= 1)
    {
        sortType = @"";
    }
    else if(job.sorted)
    {
        sortType = NSLocalizedString(@", sortiert", nil);
    }
    else
    {
        sortType = NSLocalizedString(@", unsortiert", nil);
    }
    self.collectionView.contentOffset = CGPointMake((job.copies - 1) * 50, 0);

    self.pagesLabel.text = [NSString stringWithFormat:@"%ld - %ld", MAX(1,(long)job.firstPage), MAX(1,(long)job.lastPage)];
    
    if (job.flagpage) {
        self.pagesLabel.text = [self.pagesLabel.text stringByAppendingString:NSLocalizedString(@", Flagpage", nil)];
    }

    NSString *duplexType;
    switch(job.duplex)
    {
        case ETHZDuplexTypeNone:
            duplexType = NSLocalizedString(@"Einseitig", nil);
            break;
        case ETHZDuplexTypeLongbind:
            duplexType = NSLocalizedString(@"Longbind", nil);
            break;
        case ETHZDuplexTypeShortbind:
            duplexType = NSLocalizedString(@"Shortbind", nil);
            break;
    }
    self.duplexLabel.text = [NSString stringWithFormat:@"%@, %ld pro Blatt", duplexType, (long)job.pagesPerSheet];

    NSString *paperType;
    switch(job.paper)
    {
        case ETHZPaperTypeRecycled:
            paperType = NSLocalizedString(@"Recycled", nil);
            break;
        case ETHZPaperTypeWhite:
            paperType = NSLocalizedString(@"White", nil);
            break;
        case ETHZPaperTypeHeavy:
            paperType = NSLocalizedString(@"Heavy", nil);
            break;
        case ETHZPaperTypeFoil:
            paperType = NSLocalizedString(@"Foil", nil);
            break;
    }
    self.paperLabel.text = [NSString stringWithFormat:@"A%ld, %@", (long)job.pageSizeA, paperType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textfield Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.section == 1 && indexPath.row == 0)
    {
        // Cell of nethz name field
        self.usernameField.enabled = YES;
        [self.usernameField becomeFirstResponder];
    }
    else if(indexPath.section == 1 && indexPath.row == 1)
    {
        // Cell of budget and code
        [[ETHZPrintJob sharedPrintJob] updateNethzData];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.enabled = NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    job.nethzName = textField.text;
    [job writeToDisk];
}

- (void)startPrintJob {
    
    ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sende VPP Job" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
//    [alert addSubview:progressView];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 40)];
    [v addSubview:progressView];
    progressView.frame = CGRectMake(15, 10, 200, progressView.frame.size.height);
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [alert setValue:v forKey:@"accessoryView"];
    
    
    [alert show];

    
    [[ETHPrintManager sharedManager] printJob:job withProgress:^(float progress) {
        progressView.progress = progress;
    } completion:^(NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fehler", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fertig", nil) message:NSLocalizedString(@"Auftrag wurde an VPP gesendet.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 142;
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
        case 142: title = @"🔚"; break;
            
            
        default:
            title = @(indexPath.row+1).description;
            break;
    }
    [(UILabel *)[cell viewWithTag:42] setText:title];
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{

    if(scrollView == self.collectionView)
    {
        targetContentOffset->x = roundf((targetContentOffset->x) / 50.0f) * 50;
        
        ETHZPrintJob *job = [ETHZPrintJob sharedPrintJob];
        job.copies = roundf((targetContentOffset->x) / 50.0f) + 1;
        [job writeToDisk];
    }
}

@end
