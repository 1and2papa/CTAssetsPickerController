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

#import <PureLayout/PureLayout.h>
#import "CTAssetsPickerDefines.h"
#import "CTAssetsGridViewCell.h"
#import "CTAssetCheckmark.h"
#import "PHAsset+CTAssetsPickerController.h"
#import "NSDateFormatter+CTAssetsPickerController.h"
#import "UIImage+CTAssetsPickerController.h"



@interface CTAssetsGridViewCell ()

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) CTAssetCheckmark *checkmark;
@property (nonatomic, strong) UIImageView *disabledImageView;
@property (nonatomic, strong) UIView *disabledView;
@property (nonatomic, strong) UIView *highlightedView;
@property (nonatomic, strong) UIView *selectedView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end





@implementation CTAssetsGridViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
        
        [self setupViews];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupViews
{
    CTAssetThumbnailView *thumbnailView = [CTAssetThumbnailView newAutoLayoutView];
    self.backgroundView = thumbnailView;
    
    UIImage *disabledImage = [UIImage ctassetsPickerImageNamed:@"GridDisabledAsset"];
    disabledImage = [disabledImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *disabledImageView = [[UIImageView alloc] initWithImage:disabledImage];
    disabledImageView.tintColor = CTAssetsPikcerThumbnailTintColor;
    self.disabledImageView = disabledImageView;
    
    
    UIView *disabledView = [UIView newAutoLayoutView];
    disabledView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    disabledView.hidden = YES;
    [disabledView addSubview:self.disabledImageView];
    self.disabledView = disabledView;
    [self addSubview:self.disabledView];
    
    UIView *highlightedView = [UIView newAutoLayoutView];
    highlightedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    highlightedView.hidden = YES;
    self.highlightedView = highlightedView;
    [self addSubview:self.highlightedView];
    
    CTAssetCheckmark *checkmark = [CTAssetCheckmark newAutoLayoutView];
    self.checkmark = checkmark;
    
    UIView *selectedView = [UIView newAutoLayoutView];
    selectedView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    selectedView.hidden = YES;
    [selectedView addSubview:checkmark];
    self.selectedView = selectedView;
    [self addSubview:self.selectedView];
}



#pragma mark - Accessors

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.disabledView.hidden = enabled;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.highlightedView.hidden = !highlighted;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectedView.hidden = !selected;
}




#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.backgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
            [self.disabledView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
            [self.highlightedView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
            [self.selectedView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        }];
        
        [self.disabledImageView autoCenterInSuperview];
        
        [self.checkmark autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [self.checkmark autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}


- (void)bind:(PHAsset *)asset
{
    self.asset = asset;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    return self.asset.accessibilityLabel;
}

@end