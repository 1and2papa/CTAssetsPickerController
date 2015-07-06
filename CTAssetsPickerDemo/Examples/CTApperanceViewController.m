/*
 
 MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
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
#import <CTAssetsPickerController/CTAssetCheckmark.h>
#import <CTAssetsPickerController/CTAssetCollectionViewCell.h>
#import <CTAssetsPickerController/CTAssetsGridViewFooter.h>



@interface CTApperanceViewController ()

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) UIFont *primaryFont;
@property (nonatomic, strong) UIFont *secondaryFont;


@end


@implementation CTApperanceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.primaryColor   = [UIColor colorWithRed:251.0/255.0 green:13.0/255.0 blue:67.0/255.0 alpha:1];
    self.secondaryColor = [UIColor colorWithWhite:1 alpha:1];
    self.primaryFont    = [UIFont fontWithName:@"SnellRoundhand-Black" size:24.0];
    self.secondaryFont  = [UIFont fontWithName:@"SnellRoundhand-Bold" size:18.0];

    // Navigation Bar apperance
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    
    // set nav bar style to black to force light content status bar style
    navBar.barStyle = UIBarStyleBlack;
    
    // bar tint color
    navBar.barTintColor = self.primaryColor;
    
    // tint color
    navBar.tintColor = self.secondaryColor;
    
    // title
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName: self.secondaryColor,
      NSFontAttributeName : self.primaryFont};
    
    // bar button item appearance
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName : self.secondaryFont}
                                 forState:UIControlStateNormal];
    
    // asset collection appearance
    CTAssetCollectionViewCell *assetCollectionViewCell = [CTAssetCollectionViewCell appearance];
    assetCollectionViewCell.titleFont = [self.secondaryFont fontWithSize:16.0];
    assetCollectionViewCell.titleTextColor = self.primaryColor;
    assetCollectionViewCell.countFont = [self.secondaryFont fontWithSize:12.0];
    assetCollectionViewCell.countTextColor = self.primaryColor;

   
    // assets grid footer apperance
    CTAssetsGridViewFooter *assetsGridViewFooter = [CTAssetsGridViewFooter appearance];
    assetsGridViewFooter.font = [self.secondaryFont fontWithSize:16.0];
    assetsGridViewFooter.textColor = self.primaryColor;
        
    // check mark
    [CTAssetCheckmark appearance].tintColor = self.primaryColor;
}

- (void)dealloc
{
    // reset apperance
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    
    navBar.barStyle = UIBarStyleDefault;
    
    navBar.barTintColor = nil;
    
    navBar.tintColor = nil;
    
    navBar.titleTextAttributes = nil;
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:nil
                                      forState:UIControlStateNormal];
    
    CTAssetCollectionViewCell *assetCollectionViewCell = [CTAssetCollectionViewCell appearance];
    assetCollectionViewCell.titleFont = nil;
    assetCollectionViewCell.titleTextColor = nil;
    assetCollectionViewCell.countFont = nil;
    assetCollectionViewCell.countTextColor = nil;
    
    
    CTAssetsGridViewFooter *assetsGridViewFooter = [CTAssetsGridViewFooter appearance];
    assetsGridViewFooter.font = nil;
    assetsGridViewFooter.textColor = nil;
    
    
    // Check mark
    [CTAssetCheckmark appearance].tintColor = nil;
}


@end
