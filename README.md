# CTAssetsPickerController

## Introduction

CTAssetsPickerController is an iOS controller that allows picking multiple photos and videos from user's photo library. The usage and look-and-feel are just similar to UIImagePickerController. It uses **ARC** and requires **Photos** framework.

![Screenshot](Screenshot.png "Screenshot")

## Features
1. Picks multiple photos and videos across albums from user's library.
2. Previews assets by long-press gesture.
3. Filters assets for picking only photos or videos.
4. Filters assets or albums by their properties.
5. Achieves average 5x fps.
6. Conforms UIAppearance Protocol.
7. Conforms UIAccessibility Protocol.
8. Highly customisable.
9. Pure Auto Layout.

## Release Notes
* [Release Notes](https://github.com/chiunam/CTAssetsPickerController/releases)

## Minimum Requirement
Xcode 6 and iOS 8.

## Adding to your project
[CocoaPods](http://cocoapods.org) is a very good library dependencies manager. Just create the Podfile and it does all the remaining works.  

Podfile
````
platform :ios, '8.0'
pod 'CTAssetsPickerController',  '~> 3.0.0-beta.1'
````

## Running the demo app

To run the demo app, you have to run `pod install` and then open `CTAssetsPickerDemo.xcworkspace`
````bash
git clone https://github.com/chiunam/CTAssetsPickerController/
pod install
````

## Usages

### Import header

```` objective-c
#import <CTAssetsPickerController/CTAssetsPickerController.h>
````

### Create and present CTAssetsPickerController

```` objective-c
// request authorization status
[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
    dispatch_async(dispatch_get_main_queue(), ^{

        // init picker
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        
        // set delegate
        picker.delegate = self;
        
        // present picker
        [self presentViewController:picker animated:YES completion:nil];

    });
}];
````

### Implement didFinishPickingAssets delegate

If the picker is presented by `presentViewController:animated:completion:` method, the delegate is responsible for dismissing the picker when the operation completes.

```` objective-c
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
// assets contains PHAsset objects.
````

## Customisation

Customisation can be done by setting properties or implementating delegate methods. See the demo project for the details.

### Apperance

The picker conforms `UIAppearance` protocol. For most UI appearance, (e.g. fonts, buttons, text colors), it can be overridden by setting proper `UIAppearance` after picker initalisation. Please refer to the demo project.

### Localisation

`CTAssetsPicker.strings` contains strings used in the picker. It will be included in `CTAssetsPickerController.bundle` if you add the picker to your project by using CocoaPods. You might translate the text accordingly. PR is always welcomed if you add translation of the picker.

### Notifications

`NSNotification` objects named `CTAssetsPickerSelectedAssetsDidChangeNotification`, `CTAssetsPickerDidSelectAssetNotification` and `CTAssetsPickerDidDeselectAssetNotification` will be sent when user select or deselect assets. You may add your observer to monitor the change of selection.

## Bonus

You may reuse the preview feature of the picker to view any assets. Just init a `CTAssetsPageViewController` with an array of assets and assign `pageIndex` property. Please refer to the demo app for the details.

```` objective-c
NSArray *assets = @[asset1, asset2, asset3, ...];
CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:assets];
vc.pageIndex = assets.count - 1; // display the last asset 

[self.navigationController pushViewController:vc animated:YES];
````    


## Documentation
* [Online documentation](http://cocoadocs.org/docsets/CTAssetsPickerController/)


## Note
CTAssetsPickerController does not compress the picked photos and videos. You can retrieve the image or video data of picked assets by the `PHImageManager` object. Please refer the documentation of `PHImageManager`.


## License

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
