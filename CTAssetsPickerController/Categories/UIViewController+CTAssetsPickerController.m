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

#import "UIViewController+CTAssetsPickerController.h"

@implementation UIViewController (CTAssetsPickerController)

- (NSString *)ctnavigationItemTitle
{
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]])
    {
        UILabel *titleLabel = (UILabel*)self.navigationItem.titleView;
        return titleLabel.text;
    }
    
    return nil;
}

- (void)setCtnavigationItemTitle:(NSString *)title
{
    UILabel *titleLabel = nil;
    
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]])
    {
        titleLabel = (UILabel*)self.navigationItem.titleView;
        if ([titleLabel.text isEqualToString:title]) return;
    }
    else
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 44)];
        titleLabel.text = title;
        titleLabel.font = [self cttitleFont];
        titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        titleLabel.adjustsFontSizeToFitWidth = NO;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor darkTextColor];
        
        self.navigationItem.titleView = titleLabel;
    }
    
    titleLabel.text = title;
    [titleLabel sizeToFit];
}

- (UIFont *)cttitleFont
{
    NSComparisonResult result = [@"8.2" compare:[UIDevice currentDevice].systemVersion options:NSNumericSearch];
    
    if (result == NSOrderedSame || result == NSOrderedAscending)
    {
        return [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    }
    
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
}

@end
