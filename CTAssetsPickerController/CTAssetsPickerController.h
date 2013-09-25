
/*
 CTAssetsPickerController.h
 
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


#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>



@protocol CTAssetsPickerControllerDelegate;

/// A controller that allows picking multiple photos and videos from user's photo library.
@interface CTAssetsPickerController : UINavigationController

/// The assets picker’s delegate object.
@property (nonatomic, weak) id <UINavigationControllerDelegate, CTAssetsPickerControllerDelegate> delegate;

/// Set the ALAssetsFilter to filter the picker contents. 
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

/// The maximum number of assets to be picked.
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;

/**
 Determines whether or not the cancel button is visible in the picker
 @discussion The cancel button is visible by default. To hide the cancel button, (e.g. presenting the picker in UIPopoverController)
 set this property’s value to NO.
 */
@property (nonatomic, assign) BOOL showsCancelButton;

@end


/**
 The CTAssetsPickerControllerDelegate protocol defines methods that your delegate object must implement to interact with the assets picker interface. The methods of this protocol notify your delegate when the user finish picking photos or videos, or cancels the picker operation.
 */
@protocol CTAssetsPickerControllerDelegate <NSObject>

/**
 Tells the delegate that the user finish picking photos or videos.
 @param picker The controller object managing the assets picker interface.
 @param assets An array containing picked ALAsset objects
 */
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;

@optional

/**
 Tells the delegate that the user cancelled the pick operation.
 @param picker The controller object managing the assets picker interface.
 */
- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker;

@end
