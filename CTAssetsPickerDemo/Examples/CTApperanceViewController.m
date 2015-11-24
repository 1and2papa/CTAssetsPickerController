/*
 
 MIT License (MIT)
 
 Copyright (c) 2015 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTApperanceViewController.h"

// import headers that need to be customised
#import <CTAssetsPickerController/CTAssetCollectionViewCell.h>
#import <CTAssetsPickerController/CTAssetsGridView.h>
#import <CTAssetsPickerController/CTAssetsGridViewFooter.h>
#import <CTAssetsPickerController/CTAssetsGridViewCell.h>
#import <CTAssetsPickerController/CTAssetsGridSelectedView.h>
#import <CTAssetsPickerController/CTAssetCheckmark.h>
#import <CTAssetsPickerController/CTAssetSelectionLabel.h>
#import <CTAssetsPickerController/CTAssetsPageView.h>



@interface CTApperanceViewController ()

@property (nonatomic, strong) UIColor *color1;
@property (nonatomic, strong) UIColor *color2;
@property (nonatomic, strong) UIColor *color3;
@property (nonatomic, strong) UIFont *font;

@end



@implementation CTApperanceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set appearance
    // for demo purpose. you might put the code in app delegate's application:didFinishLaunchingWithOptions: method
    self.color1 = [UIColor colorWithRed:102.0/255.0 green:161.0/255.0 blue:130.0/255.0 alpha:1];
    self.color2 = [UIColor colorWithRed:60.0/255.0 green:71.0/255.0 blue:75.0/255.0 alpha:1];
    self.color3 = [UIColor colorWithWhite:0.9 alpha:1];
    self.font   = [UIFont fontWithName:@"Futura-Medium" size:22.0];

    // Navigation Bar apperance
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    
    // set nav bar style to black to force light content status bar style
    navBar.barStyle = UIBarStyleBlack;
    
    // bar tint color
    navBar.barTintColor = self.color1;
    
    // tint color
    navBar.tintColor = self.color2;
    
    // title
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName: self.color2,
      NSFontAttributeName : self.font};
    
    // bar button item appearance
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName : [self.font fontWithSize:18.0]}
                                 forState:UIControlStateNormal];
    
    // albums view
    UITableView *assetCollectionView = [UITableView appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    assetCollectionView.backgroundColor = self.color2;
    
    // asset collection appearance
    CTAssetCollectionViewCell *assetCollectionViewCell = [CTAssetCollectionViewCell appearance];
    assetCollectionViewCell.titleFont = [self.font fontWithSize:16.0];
    assetCollectionViewCell.titleTextColor = self.color1;
    assetCollectionViewCell.selectedTitleTextColor = self.color2;
    assetCollectionViewCell.countFont = [self.font fontWithSize:12.0];
    assetCollectionViewCell.countTextColor = self.color1;
    assetCollectionViewCell.selectedCountTextColor = self.color2;
    assetCollectionViewCell.accessoryColor = self.color1;
    assetCollectionViewCell.selectedAccessoryColor = self.color2;
    assetCollectionViewCell.backgroundColor = self.color3;
    assetCollectionViewCell.selectedBackgroundColor = [self.color1 colorWithAlphaComponent:0.4];

    // grid view
    CTAssetsGridView *assetsGridView = [CTAssetsGridView appearance];
    assetsGridView.gridBackgroundColor = self.color3;
    
    // assets grid footer apperance
    CTAssetsGridViewFooter *assetsGridViewFooter = [CTAssetsGridViewFooter appearance];
    assetsGridViewFooter.font = [self.font fontWithSize:16.0];
    assetsGridViewFooter.textColor = self.color2;
    
    // grid view cell
    CTAssetsGridViewCell *assetsGridViewCell = [CTAssetsGridViewCell appearance];
    assetsGridViewCell.highlightedColor = [UIColor colorWithWhite:1 alpha:0.3];
    
    // selected grid view
    CTAssetsGridSelectedView *assetsGridSelectedView = [CTAssetsGridSelectedView appearance];
    assetsGridSelectedView.selectedBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    assetsGridSelectedView.tintColor = self.color1;
    assetsGridSelectedView.borderWidth = 3.0;
    
    // check mark
    CTAssetCheckmark *checkmark = [CTAssetCheckmark appearance];
    checkmark.tintColor = self.color1;
    [checkmark setMargin:0.0 forVerticalEdge:NSLayoutAttributeRight horizontalEdge:NSLayoutAttributeTop];
    
    // selection label
    CTAssetSelectionLabel *assetSelectionLabel = [CTAssetSelectionLabel appearance];
    assetSelectionLabel.borderWidth = 1.0;
    assetSelectionLabel.borderColor = self.color3;
    [assetSelectionLabel setSize:CGSizeMake(24.0, 24.0)];
    [assetSelectionLabel setCornerRadius:12.0];
    [assetSelectionLabel setMargin:4.0 forVerticalEdge:NSLayoutAttributeRight horizontalEdge:NSLayoutAttributeTop];
    [assetSelectionLabel setTextAttributes:@{NSFontAttributeName : [self.font fontWithSize:12.0],
                                             NSForegroundColorAttributeName : self.color3,
                                             NSBackgroundColorAttributeName : self.color1}];
    
    // page view (preview)
    CTAssetsPageView *assetsPageView = [CTAssetsPageView appearance];
    assetsPageView.pageBackgroundColor = self.color3;
    assetsPageView.fullscreenBackgroundColor = self.color2;
    
    // progress view
    [UIProgressView appearanceWhenContainedIn:[CTAssetsPickerController class], nil].tintColor = self.color1;
    
}

- (void)dealloc
{
    // reset appearance
    // for demo purpose. it is not necessary to reset appearance in real case.
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    
    navBar.barStyle = UIBarStyleDefault;
    
    navBar.barTintColor = nil;
    
    navBar.tintColor = nil;
    
    navBar.titleTextAttributes = nil;
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:nil
                                      forState:UIControlStateNormal];
    
    UITableView *assetCollectionView = [UITableView appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    assetCollectionView.backgroundColor = [UIColor whiteColor];
    
    CTAssetCollectionViewCell *assetCollectionViewCell = [CTAssetCollectionViewCell appearance];
    assetCollectionViewCell.titleFont = nil;
    assetCollectionViewCell.titleTextColor = nil;
    assetCollectionViewCell.selectedTitleTextColor = nil;
    assetCollectionViewCell.countFont = nil;
    assetCollectionViewCell.countTextColor = nil;
    assetCollectionViewCell.selectedCountTextColor = nil;
    assetCollectionViewCell.accessoryColor = nil;
    assetCollectionViewCell.selectedAccessoryColor = nil;
    assetCollectionViewCell.backgroundColor = nil;
    assetCollectionViewCell.selectedBackgroundColor = nil;
    
    CTAssetsGridView *assetsGridView = [CTAssetsGridView appearance];
    assetsGridView.gridBackgroundColor = nil;
    
    CTAssetsGridViewFooter *assetsGridViewFooter = [CTAssetsGridViewFooter appearance];
    assetsGridViewFooter.font = nil;
    assetsGridViewFooter.textColor = nil;
    
    CTAssetsGridViewCell *assetsGridViewCell = [CTAssetsGridViewCell appearance];
    assetsGridViewCell.highlightedColor = nil;
    
    CTAssetsGridSelectedView *assetsGridSelectedView = [CTAssetsGridSelectedView appearance];
    assetsGridSelectedView.selectedBackgroundColor = nil;
    assetsGridSelectedView.tintColor = nil;
    assetsGridSelectedView.borderWidth = 0.0;
    
    CTAssetCheckmark *checkmark = [CTAssetCheckmark appearance];
    checkmark.tintColor = nil;
    [checkmark setMargin:0.0 forVerticalEdge:NSLayoutAttributeRight horizontalEdge:NSLayoutAttributeBottom];
    
    CTAssetSelectionLabel *assetSelectionLabel = [CTAssetSelectionLabel appearance];
    assetSelectionLabel.borderWidth = 0.0;
    assetSelectionLabel.borderColor = nil;
    [assetSelectionLabel setSize:CGSizeZero];
    [assetSelectionLabel setCornerRadius:0.0];
    [assetSelectionLabel setMargin:0.0 forVerticalEdge:NSLayoutAttributeRight horizontalEdge:NSLayoutAttributeBottom];
    [assetSelectionLabel setTextAttributes:nil];
    
    CTAssetsPageView *assetsPageView = [CTAssetsPageView appearance];
    assetsPageView.pageBackgroundColor = nil;
    assetsPageView.fullscreenBackgroundColor = nil;
    
    [UIProgressView appearanceWhenContainedIn:[CTAssetsPickerController class], nil].tintColor = nil;
}


- (void)pickAssets:(id)sender
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // to show selection order
            picker.showsSelectionIndex = YES;
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
            
        });
    }];
}


@end
