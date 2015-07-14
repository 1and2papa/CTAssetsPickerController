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
#import "CTAssetCollectionViewCell.h"
#import "NSBundle+CTAssetsPickerController.h"
#import "UIImage+CTAssetsPickerController.h"
#import "NSNumberFormatter+CTAssetsPickerController.h"



@interface CTAssetCollectionViewCell ()

@property (nonatomic, assign) CGSize thumbnailSize;

@property (nonatomic, strong) CTAssetThumbnailStacks *thumbnailStacks;
@property (nonatomic, strong) UIView *labelsView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) PHAssetCollection *collection;
@property (nonatomic, assign) NSUInteger count;

@end





@implementation CTAssetCollectionViewCell

- (instancetype)initWithThumbnailSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        _thumbnailSize = size;
        
        self.opaque                             = YES;
        self.isAccessibilityElement             = YES;
        self.textLabel.backgroundColor          = self.backgroundColor;
        self.detailTextLabel.backgroundColor    = self.backgroundColor;
        self.accessoryType                      = UITableViewCellAccessoryDisclosureIndicator;
        
        [self setupViews];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupViews
{
    CTAssetThumbnailStacks *thumbnailStacks = [CTAssetThumbnailStacks newAutoLayoutView];
    thumbnailStacks.thumbnailSize = self.thumbnailSize;
    self.thumbnailStacks = thumbnailStacks;
    
    UILabel *titleLabel = [UILabel newAutoLayoutView];
    self.titleLabel = titleLabel;
    
    UILabel *countLabel = [UILabel newAutoLayoutView];
    self.countLabel = countLabel;
    
    UIView *labelsView = [UIView newAutoLayoutView];
    [labelsView addSubview:self.titleLabel];
    [labelsView addSubview:self.countLabel];
    self.labelsView = labelsView;
    
    [self.contentView addSubview:self.thumbnailStacks];
    [self.contentView addSubview:self.labelsView];
    
    [self setupFonts];
}

- (void)setupFonts
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.countLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void)setupPlaceholderImage
{
    NSString *imageName = [self placeHolderImageNameOfCollectionSubtype:self.collection.assetCollectionSubtype];
    UIImage *image = [UIImage ctassetsPickerImageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    for (CTAssetThumbnailView *thumbnailView in self.thumbnailStacks.thumbnailViews)
    {
        [thumbnailView bind:nil assetCollection:nil];
        [thumbnailView setBackgroundImage:image];
    }
}

- (NSString *)placeHolderImageNameOfCollectionSubtype:(PHAssetCollectionSubtype)subtype
{
    if (subtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
        return @"GridEmptyCameraRoll";
    
    else if (subtype == PHAssetCollectionSubtypeSmartAlbumAllHidden)
        return @"GridHiddenAlbum";
    
    else if (subtype == PHAssetCollectionSubtypeAlbumCloudShared)
        return @"GridEmptyAlbumShared";
    
    else
        return @"GridEmptyAlbum";
}


#pragma mark - Apperance

- (UIFont *)titleFont
{
    return self.titleLabel.font;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (!titleFont)
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    else
        self.titleLabel.font = titleFont;
}

- (UIColor *)titleTextColor
{
    return self.titleLabel.textColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor
{
    if (!titleTextColor)
        self.titleLabel.textColor = [UIColor darkTextColor];
    else
        self.titleLabel.textColor = titleTextColor;
}

- (UIFont *)countFont
{
    return self.countLabel.font;
}

- (void)setCountFont:(UIFont *)countFont
{
    if (!countFont)
        self.countLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    else
        self.countLabel.font = countFont;
}

- (UIColor *)countTextColor
{
    return self.countLabel.textColor;
}

- (void)setCountTextColor:(UIColor *)countTextColor
{
    if (!countTextColor)
        self.countLabel.textColor = [UIColor darkTextColor];
    else
        self.countLabel.textColor = countTextColor;
}

- (UIColor *)selectedBackgroundColor
{
    return self.selectedBackgroundView.backgroundColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    if (!selectedBackgroundColor)
        self.selectedBackgroundView = nil;
    else
    {
        UIView *view = [UIView new];
        view.backgroundColor = selectedBackgroundColor;
        self.selectedBackgroundView = view;
    }
}


#pragma mark - Override highlighted / selected

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self.thumbnailStacks setHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.thumbnailStacks setHighlighted:selected];
}

#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        CGSize size = self.thumbnailSize;
        CGFloat top = self.thumbnailStacks.edgeInsets.top;
        size.height += top;
        
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.thumbnailStacks autoSetDimensionsToSize:size];
        }];
                
        [UIView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
            [self.thumbnailStacks autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTrailing];
        }];
        
        [self.labelsView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.labelsView autoPinEdge:ALEdgeLeading
                              toEdge:ALEdgeTrailing
                              ofView:self.thumbnailStacks
                          withOffset:self.labelsView.layoutMargins.left
                            relation:NSLayoutRelationGreaterThanOrEqual];
        
        [self.titleLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        [self.countLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
        [self.countLabel autoPinEdge:ALEdgeTop
                              toEdge:ALEdgeBottom
                              ofView:self.titleLabel
                          withOffset:self.countLabel.layoutMargins.top
                            relation:NSLayoutRelationGreaterThanOrEqual];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}


#pragma mark - Bind asset collection

- (void)bind:(PHAssetCollection *)collection count:(NSUInteger)count
{
    self.collection = collection;
    self.count      = count;
    
    [self setupPlaceholderImage];

    [self.titleLabel setText:collection.localizedTitle];
    
    if (count != NSNotFound)
    {
        NSNumberFormatter *nf = [NSNumberFormatter new];
        [self.countLabel setText:[nf ctassetsPickerStringFromAssetsCount:count]];
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}


#pragma mark - Accessibility label

- (NSString *)accessibilityLabel
{
    NSString *title = self.titleLabel.text;
    NSString *count = [NSString stringWithFormat:CTAssetsPickerLocalizedString(@"%@ Photos", nil), self.countLabel.text];
    
    NSArray *labels = @[title, count];
    return [labels componentsJoinedByString:@","];
}

@end