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
#import "CTAssetCheckmark.h"
#import "NSBundle+CTAssetsPickerController.h"
#import "UIImage+CTAssetsPickerController.h"


@interface CTAssetCheckmark ()

@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UIImageView *checkmarkImageView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation CTAssetCheckmark


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.userInteractionEnabled = NO;
        self.isAccessibilityElement = NO;
        [self setupViews];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupViews
{
    UIImage *shadowImage = [UIImage ctassetsPickerImageNamed:@"CheckmarkShadow"];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    shadowImageView.userInteractionEnabled = NO;
    self.shadowImageView = shadowImageView;
    [self addSubview:self.shadowImageView];
    
    UIImage *checkmarkImage = [UIImage ctassetsPickerImageNamed:@"Checkmark"];
    checkmarkImage = [checkmarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:checkmarkImage];
    checkmarkImageView.userInteractionEnabled = NO;
    self.checkmarkImageView = checkmarkImageView;
    [self addSubview:self.checkmarkImageView];
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        CGSize size = [UIImage ctassetsPickerImageNamed:@"CheckmarkShadow"].size;
        
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self autoSetDimensionsToSize:size];
        }];
        
        [self.shadowImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.checkmarkImageView autoCenterInSuperview];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
