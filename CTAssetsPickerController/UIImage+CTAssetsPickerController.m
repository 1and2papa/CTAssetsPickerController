//
//  UIImage+CTAssetsPickerController.m
//  CTAssetsPickerDemo
//
//  Created by Miguel Cabeça on 25/11/14.
//  Copyright (c) 2014 Clement T. All rights reserved.
//

#import "UIImage+CTAssetsPickerController.h"

@implementation UIImage (CTAssetsPickerController)

+ (UIImage *)ctassetsPickerControllerImageNamed:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:[NSBundle bundleWithPath:@"CTAssetsPickerController"] compatibleWithTraitCollection:nil];
}

@end
