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

#import "CTAssetThumbnailOverlay.h"
#import "UIImage+CTAssetsPickerController.h"
#import "PHAsset+CTAssetsPickerController.h"


@interface CTAssetThumbnailOverlay ()

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *duration;

@end



@implementation CTAssetThumbnailOverlay

static UIFont *durationFont;
static UIColor *durationColor;

static UIImage *videoBadge;
static UIImage *sloMoBadge;
static UIImage *timelapseBadge;
static UIImage *gradient;



+ (void)initialize
{
    durationFont    = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    durationColor   = [UIColor whiteColor];
    videoBadge      = [UIImage ctassetsPickerImageNamed:@"GridVideoBadgeIcon"];
    sloMoBadge      = [UIImage ctassetsPickerImageNamed:@"GridSloMoBadgeIcon"];
    timelapseBadge  = [UIImage ctassetsPickerImageNamed:@"GridTimelapseBadgeIcon"];
    gradient        = [UIImage ctassetsPickerImageNamed:@"GridGradient"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = NO;
        self.clipsToBounds          = YES;
        self.isAccessibilityElement = NO;
    }
    
    return self;
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [self drawGradientInRect:rect];
    [self drawBadgeInRect:rect];
    [self drawDurationInRect:rect];
}

- (void)drawGradientInRect:(CGRect)rect
{
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMaxY(rect) - gradient.size.height;

    CGFloat width  = CGRectGetMaxX(rect) - x;
    CGFloat height = gradient.size.height;

    [gradient drawInRect:CGRectMake(x, y, width, height)];
}

- (void)drawDurationInRect:(CGRect)rect
{
    if (self.duration)
    {
        CGSize size = [self.duration sizeWithAttributes:@{NSFontAttributeName : durationFont}];
        UIEdgeInsets insets = [self durationInsets];
        
        CGFloat x = CGRectGetMaxX(rect) - size.width - insets.right;
        CGFloat y = CGRectGetMaxY(rect) - size.height - insets.bottom;
        
        CGRect durationRect = CGRectMake(x, y, size.width, size.height);
        
        NSMutableParagraphStyle *durationStyle = [NSMutableParagraphStyle new];
        durationStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSDictionary *attributes = @{NSFontAttributeName : durationFont,
                                     NSForegroundColorAttributeName : durationColor,
                                     NSParagraphStyleAttributeName : durationStyle};
        
        [self.duration drawInRect:durationRect withAttributes:attributes];
    }
}

- (void)drawBadgeInRect:(CGRect)rect
{
    UIImage *badge = [self badgeOfAsset:self.asset];
    UIEdgeInsets insets = [self badgeInsetsOfAsset:self.asset];

    CGSize size = badge.size;
    CGFloat left = insets.left;
    CGFloat bottom = insets.bottom;
    
    CGFloat x = CGRectGetMinX(rect) + left;
    CGFloat y = CGRectGetMaxY(rect) - size.height - bottom;

    CGPoint point = CGPointMake(x, y);

    [badge drawAtPoint:point];
}

- (UIImage *)badgeOfAsset:(PHAsset *)asset
{
    if (asset.ctassetsPickerIsHighFrameRateVideo)
        return sloMoBadge;

    else if (asset.ctassetsPickerIsTimelapseVideo)
        return timelapseBadge;

    else if (asset.ctassetsPickerIsVideo)
        return videoBadge;

    else
        return nil;
}

- (UIEdgeInsets)badgeInsetsOfAsset:(PHAsset *)asset
{
    if (asset.ctassetsPickerIsHighFrameRateVideo)
        return UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
    
    else if (asset.ctassetsPickerIsTimelapseVideo)
        return UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
    
    else if (asset.ctassetsPickerIsVideo)
        return UIEdgeInsetsMake(4.5, 4.5, 4.5, 4.5);
    
    else
        return UIEdgeInsetsZero;
}

- (UIEdgeInsets)durationInsets
{
    return UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
}

- (void)bind:(PHAsset *)asset duration:(NSString *)duration
{
    self.asset    = asset;
    self.duration = duration;
    
    [self setNeedsDisplay];
}


@end
