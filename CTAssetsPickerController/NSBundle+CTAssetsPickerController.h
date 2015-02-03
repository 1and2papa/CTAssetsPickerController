//
//  NSBundle+CTAssetsPickerController.h
//  CTAssetsPickerDemo
//
//  Created by Miguel Cabeça on 25/11/14.
//  Copyright (c) 2014 Clement T. All rights reserved.
//

#import <Foundation/Foundation.h>


#define CTAssetsPickerControllerLocalizedString(key) \
NSLocalizedStringFromTableInBundle((key), @"CTAssetsPickerController", [NSBundle ctassetsPickerControllerBundle], nil)

@interface NSBundle (CTAssetsPickerController)

+ (NSBundle *)ctassetsPickerControllerBundle;

@end
