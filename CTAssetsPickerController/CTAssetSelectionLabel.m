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

#import <PureLayout/PureLayout.h>
#import "CTAssetSelectionLabel.h"
#import "CTAssetsPickerDefines.h"



@interface CTAssetSelectionLabel ()

@property (nonatomic, strong) NSLayoutConstraint *constraint1;
@property (nonatomic, strong) NSLayoutConstraint *constraint2;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end



@implementation CTAssetSelectionLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.textAlignment = NSTextAlignmentCenter;
        self.font = CTAssetLabelFont;
        self.textColor = CTAssetLabelTextColor;
        self.backgroundColor = CTAssetLabelBackgroundColor;
        self.layer.borderColor = CTAssetLabelBorderColor.CGColor;
        self.layer.masksToBounds = YES;
        self.isAccessibilityElement = NO;
    }
    
    return self;
}

#pragma mark - Apperance

- (BOOL)isCircular
{
    return (self.layer.cornerRadius > 0);
}

- (void)setCircular:(BOOL)circular
{
    if (circular)
    {
        self.layer.cornerRadius = CTAssetLabelSize.height / 2.0;
    }
    else
    {
        self.layer.cornerRadius = 0.0;
    }
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    UIColor *color = (borderColor) ? borderColor : CTAssetLabelBorderColor;
    self.layer.borderColor = color.CGColor;
}

- (void)setMargin:(CGFloat)margin
{
    [self.superview removeConstraints:@[self.constraint1, self.constraint2]];

    self.constraint1 = [self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:margin];
    self.constraint2 = [self autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:margin];
}

- (void)setTextAttributes:(NSDictionary *)textAttributes
{
    UIFont *font = (textAttributes) ? [textAttributes objectForKey:NSFontAttributeName] : CTAssetLabelFont;
    self.font = font;
    
    UIColor *textColor = (textAttributes) ? [textAttributes objectForKey:NSForegroundColorAttributeName] : CTAssetLabelTextColor;
    self.textColor = textColor;
    
    UIColor *backgroundColor = (textAttributes) ? [textAttributes objectForKey:NSBackgroundColorAttributeName] : CTAssetLabelBackgroundColor;
    self.backgroundColor = backgroundColor;
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self autoSetDimensionsToSize:CTAssetLabelSize];
        }];
        
        self.constraint1 = [self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        self.constraint2 = [self autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
