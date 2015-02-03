//
//  NSBundle+CTAssetsPickerController.m
//  CTAssetsPickerDemo
//
//  Created by Miguel Cabeça on 25/11/14.
//  Copyright (c) 2014 Clement T. All rights reserved.
//

#import "NSBundle+CTAssetsPickerController.h"

@implementation NSBundle (CTAssetsPickerController)

+ (NSBundle *)ctassetsPickerControllerBundle
{
    return [NSBundle bundleWithPath:[NSBundle ctassetsPickerControllerBundlePath]];
}

+ (NSString *)ctassetsPickerControllerBundlePath
{
    return [[NSBundle mainBundle] pathForResource:@"CTAssetsPickerController" ofType:@"bundle"];
}

@end
