/*
 ALAsset+accessibilityLabel.m
 
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

#import "ALAsset+accessibilityLabel.h"
#import "ALAsset+assetType.h"
#import "NSDateFormatter+timeIntervalFormatter.h"



@implementation ALAsset (accessibilityLabel)

- (NSString *)accessibilityLabel
{
    NSMutableArray *accessibilityLabels = [[NSMutableArray alloc] init];
    
    [accessibilityLabels addObject:[self typeAccessibilityLabel]];
    
    if ([self isVideo])
        [accessibilityLabels addObject:[self durationAccessibilityLabel]];
    
    [accessibilityLabels addObject:[self orientationAccessibilityLabel]];
    [accessibilityLabels addObject:[self dateAccessibilityLabel]];
    
    if (!self.defaultRepresentation)
        [accessibilityLabels addObject:NSLocalizedString(@"Not available", nil)];
    
    return [accessibilityLabels componentsJoinedByString:@", "];
}


- (NSString *)typeAccessibilityLabel
{
    if ([self isVideo]) {
        return NSLocalizedString(@"Video", nil);
    }

    return NSLocalizedString(@"Photo", nil);
}

- (NSString *)durationAccessibilityLabel
{
    NSTimeInterval duration = [[self valueForProperty:ALAssetPropertyDuration] doubleValue];
    NSDateFormatter *df     = [[NSDateFormatter alloc] init];
    return [df spellOutStringFromTimeInterval:duration];
}

- (NSString *)orientationAccessibilityLabel
{
    CGSize dimension = self.defaultRepresentation.dimensions;
    
    if (dimension.height >= dimension.width) {
        return NSLocalizedString(@"Portrait", nil);
    }
    
    return NSLocalizedString(@"Landscape", nil);
}

- (NSString *)dateAccessibilityLabel
{
    NSDate *date = [self valueForProperty:ALAssetPropertyDate];
    
    NSDateFormatter *df             = [[NSDateFormatter alloc] init];
    df.locale                       = [NSLocale currentLocale];
    df.dateStyle                    = NSDateFormatterMediumStyle;
    df.timeStyle                    = NSDateFormatterShortStyle;
    df.doesRelativeDateFormatting   = YES;
    
    return [df stringFromDate:date];
}

@end
