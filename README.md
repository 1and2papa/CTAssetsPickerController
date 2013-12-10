# CTAssetsPickerController

CTAssetsPickerController is an iOS controller that allows picking multiple photos and videos from user's photo library. The usage and look-and-feel just similar to UIImagePickerController. It uses **ARC** and requires **AssetsLibrary** framework.

![Screenshot](https://raw.github.com/chiunam/CTAssetsPickerController/master/Screenshot.png "Screenshot")

## Features
1. Picking multiple photos and videos from user's library.
2. Filtering assets to pick only photos or videos.
3. Limiting maximum number of assets to be picked.
4. Average 5x fps.
5. Conforming UIAccessibility Protocol.

## Minimum Requirement
Xcode 5 and iOS 6.

## Installation

### via CocoaPods
Install CocoaPods if you do not have it:-
````
$ [sudo] gem install cocoapods
$ pod setup
````
Create Podfile:-
````
$ edit Podfile
platform :ios, '6.0'
pod 'CTAssetsPickerController',  '~> 1.3.0'
$ pod install
````
Use the Xcode workspace instead of the project from now on.

### via Git Submodules

````
$ git submodule add http://github.com/chiunam/CTAssetsPickerController
````
1. Drag `CTAssetsPickerController` folder in your project and add to your targets.
2. Add `AssetsLibrary.framework`.

## Usage

See the Demo Xcode project for details.

### Import header

If using CocoaPods:-
```` objective-c
#import <CTAssetsPickerController.h>
````
If using Submodules:-
```` objective-c
#import "CTAssetsPickerController.h"
````

### Create and present CTAssetsPickerController

```` objective-c
CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
picker.delegate = self;
[self presentViewController:picker animated:YES completion:NULL];
````

### Customization
You can set max number of selection to limit the assets to be picked.

```` objective-c
picker.maximumNumberOfSelection = 10;
````

If you only want to pick photos or videos, create an `ALAssetsFilter` and assign to `assetsFilter`.
```` objective-c
picker.assetsFilter = [ALAssetsFilter allPhotos]; // Only pick photos.
````    

If you only want to pick assets that meet certain criteria, create an `NSPredicate` and assign to `selectionFilter`.
Assets that does not match the predicate will not be selectable.
```` objective-c
// only allow video clips if they are at least 5s
picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(ALAsset* asset, NSDictionary *bindings) {
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return duration >= 5;
    } else {
        return YES;
    }
}];
````    

Hide the cancel button if you present the picker in `UIPopoverController`.
```` objective-c
picker.showsCancelButton = NO;
````

Show empty photo albums in the picker.
```` objective-c
picker.showsEmptyGroups = YES;
````


### Implement CTAssetsPickerControllerDelegate

*didFinishPickingAssets*
```` objective-c
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
// assets contains ALAsset objects.
````

*didCancel (Optional)*
```` objective-c
- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker;
````

*didSelectItemAtIndexPath (Optional)*
```` objective-c
- (void)assetsPickerController:(CTAssetsPickerController *)picker didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
// picker.indexPathsForSelectedItems contains indexPaths for selected items
````

*didDeselectItemAtIndexPath (Optional)*
```` objective-c
- (void)assetsPickerController:(CTAssetsPickerController *)picker didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
````

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
