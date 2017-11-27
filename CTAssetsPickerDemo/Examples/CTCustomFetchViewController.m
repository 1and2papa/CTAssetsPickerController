//
//  CTCustomFetchViewController.m
//  CTAssetsPickerDemo
//
//  Created by Felix Dumit on 4/5/16.
//  Copyright © 2016 Clement T. All rights reserved.
//

#import "CTCustomFetchViewController.h"

@implementation CTCustomFetchViewController

- (void)pickAssets:(id)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // set custom fetch
            picker.pickFromFetch = [PHAsset fetchAssetsWithOptions:nil];
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self             presentViewController:picker
                                           animated:YES
                                         completion:nil];
        });
    }];
}

@end
