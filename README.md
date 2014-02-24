# CTAssetsPickerController

CTAssetsPickerController 2.0.0 released! It has newly re-design delegate methods, fixed serveral issues and improved usability. Please see [What's new](#whats-new) for the details.

## Introduction

CTAssetsPickerController is an iOS controller that allows picking multiple photos and videos from user's photo library. The usage and look-and-feel just similar to UIImagePickerController. It uses **ARC** and requires **AssetsLibrary** framework.

![Screenshot](https://raw.github.com/chiunam/CTAssetsPickerController/master/Screenshot.png "Screenshot")

## Features
1. Picking multiple photos and videos from user's library.
2. Filtering assets to pick only photos or videos.
3. Limiting maximum number of assets to be picked.
4. Average 5x fps.
5. Conforming UIAccessibility Protocol.


## What's new

### 2.0.0
* Rename the delegate methods to more sensible one
* Replace certain properties with delegate methods in order to provide more flexibility
* Show "no assets" view on empty albums
* Make "no assets" message to be more graceful, reflecting the device's model and camera feature
* Update padlock image to iOS 7 style
* Monitor ALAssetsLibraryChangedNotification and reload corresponding view controllers
* Use KVO to monitor the change of selected assets
* Add: iPad demo
* Add: Appledoc documentation
* Fix: Footer is not centre aligned after rotation
* Fix: Collection view layout issue on iPad landscape mode
* Fix: Collection view not scrolling to bottom on load
* Refactor certain methods


## Minimum Requirement
Xcode 5 and iOS 7.

## Installation

### via CocoaPods

````bash
$ edit Podfile
platform :ios, '7.0'
pod 'CTAssetsPickerController',  '~> 2.0.0'
$ pod install
````

### via Git Submodules

````bash
$ git submodule add http://github.com/chiunam/CTAssetsPickerController
````
1. Drag `CTAssetsPickerController` folder in your project and add to your targets.
2. Add `AssetsLibrary.framework`.

## Usage

See the Demo Xcode project and Appledoc for the details.

### Import header

```` objective-c
#import <CTAssetsPickerController.h>
````

### Create and present CTAssetsPickerController

```` objective-c
CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
picker.delegate = self;
[self presentViewController:picker animated:YES completion:nil];
````

### Implement CTAssetsPickerControllerDelegate

The delegate methods are responsible for dismissing the picker when the operation completes. To dismiss the picker, call the [dismissViewControllerAnimated:completion:](https://developer.apple.com/library/ios/documentation/uikit/reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instm/UIViewController/dismissViewControllerAnimated:completion:) method of the presenting controller responsible for displaying CTAssetsPickerController object. Please refer to the demo app.

#### Finish picking photos or videos.
```` objective-c
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
// assets contains ALAsset objects.
````

## Customization

Please refer to the documentation or header file for the complete list of properties and delegate methods.

### Properties

If you only want to pick photos or videos, create an `ALAssetsFilter` and assign to `assetsFilter`.
```` objective-c
picker.assetsFilter = [ALAssetsFilter allPhotos]; // Only pick photos.
````

Hide cancel button if you present the picker in `UIPopoverController`.
```` objective-c
picker.showsCancelButton = NO;
````

Override the picker's title.
```` objective-c
picker.title = @"Pick photos";
````

### CTAssetsPickerControllerDelegate

Limit the number of assets to be picked:-
```` objective-c
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    // Allow 10 assets to be picked
    return (picker.selectedAssets.count < 10);
}
````

Enable only certain assets to be selected:-
```` objective-c
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}
````

Show only certain albums (i.e.assets group):-

*Assets stored on iCloud (photo stream) may not displayed and picked properly if they have not downloaded to the device. You may disable them by implementing the following delegate.*

```` objective-c
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAssetsGroup:(ALAssetsGroup *)group
{
    // Do not show photo stream
    NSInteger type = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
    return (type != ALAssetsGroupPhotoStream);
}
````

## Documentation
If you have [Appledoc](https://github.com/tomaz/appledoc) installed, you can install the documentation by running the `Documentation` target of the demo project.


## Note
CTAssetsPickerController does not compress the picked photos and videos. You can process the picked assets via the `defaultRepresentation` property.

For example, you can create `UIImage` from picked assets like this:-

```` objective-c
    ALAssetRepresentation *representation = alAsset.defaultRepresentation;

    UIImage *fullResolutionImage =
    [UIImage imageWithCGImage:representation.fullResolutionImage
                        scale:1.0f
                  orientation:(UIImageOrientation)representation.orientation];
````

and create `NSData` of picked vidoes:-

```` objective-c
    ALAssetRepresentation *representation = alAsset.defaultRepresentation;

    NSURL *url          = representation.url;
    AVAsset *asset      = [AVURLAsset URLAssetWithURL:url options:nil];

    AVAssetExportSession *session =
    [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetLowQuality];

    session.outputFileType  = AVFileTypeQuickTimeMovie;
    session.outputURL       = VIDEO_EXPORTING_URL;

    [session exportAsynchronouslyWithCompletionHandler:^{

        if (session.status == AVAssetExportSessionStatusCompleted)
        {
            NSData *data    = [NSData dataWithContentsOfURL:session.outputURL];
        }

    }];

````
Please refer the documentation of `ALAssetRepresentation` and `AVAssetExportSession`.


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