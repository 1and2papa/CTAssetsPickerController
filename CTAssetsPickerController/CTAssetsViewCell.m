/*
 CTAssetsViewCell.m
 
 The MIT License (MIT)
 
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

#import "CTAssetsViewCell.h"
#import "ALAsset+assetType.h"
#import "ALAsset+accessibilityLabel.h"
#import "NSDateFormatter+timeIntervalFormatter.h"
#import "UIImage+CTAssetsPickerController.h"




@interface CTAssetsViewCell ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;

@end





@implementation CTAssetsViewCell

static UIFont *titleFont;
static CGFloat titleHeight;
static UIImage *videoIcon;
static UIColor *titleColor;
static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    videoIcon       = [UIImage ctassetsPickerControllerImageNamed:@"CTAssetsPickerVideo"];
    titleColor      = [UIColor whiteColor];
    checkedIcon     = [UIImage ctassetsPickerControllerImageNamed:@"CTAssetsPickerChecked"];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset
{
    self.asset  = asset;
    self.image  = (asset.thumbnail == NULL) ? [UIImage ctassetsPickerControllerImageNamed:@"CTAssetsPickerEmptyCell"] : [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    
    if ([self.asset isVideo])
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        self.title = [df stringFromTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}


#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawThumbnailInRect:rect];
    
    if ([self.asset isVideo])
        [self drawVideoMetaInRect:rect];
    
    if (!self.isEnabled)
        [self drawDisabledViewInRect:rect];
    
    else if (self.selected)
        [self drawSelectedViewInRect:rect];
}

- (void)drawThumbnailInRect:(CGRect)rect
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = self.image;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
}

- (void)drawVideoMetaInRect:(CGRect)rect
{
    // Create a gradient from transparent to black
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.8,
        0.0, 0.0, 0.0, 1.0
    };
    
    CGFloat locations [] = {0.0, 0.75, 1.0};
    
    CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGFloat height          = rect.size.height;
    CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - titleHeight);
    CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(baseSpace);
    CGGradientRelease(gradient);
    
    CGSize titleSize = [self.title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
    CGRect titleRect = CGRectMake(rect.size.width - titleSize.width - 2, startPoint.y + (titleHeight - 12) / 2, titleSize.width, titleHeight);
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    titleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.title drawInRect:titleRect
            withAttributes:@{NSFontAttributeName : titleFont,
                             NSForegroundColorAttributeName : titleColor,
                             NSParagraphStyleAttributeName : titleStyle}];
    
    [videoIcon drawAtPoint:CGPointMake(4, startPoint.y + 1 + (titleHeight - videoIcon.size.height) / 2)];
}

- (void)drawDisabledViewInRect:(CGRect)rect
{
    UIView *disabledView = [[UIView alloc] initWithFrame:rect];
    disabledView.backgroundColor = disabledColor;
    [self addSubview:disabledView];
}

- (void)drawSelectedViewInRect:(CGRect)rect
{
    UIView *selectedView = [[UIView alloc] initWithFrame:rect];
    selectedView.backgroundColor = selectedColor;
    [self addSubview:selectedView];
 
    UIImageView *imageView = [[UIImageView alloc] initWithImage:checkedIcon];
    imageView.frame = CGRectMake(CGRectGetMaxX(rect) - checkedIcon.size.width, CGRectGetMinY(rect), imageView.frame.size.width, imageView.frame.size.height);
    [self addSubview:imageView];
}


#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    return self.asset.accessibilityLabel;
}

@end