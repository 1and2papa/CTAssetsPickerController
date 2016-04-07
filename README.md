# CTAssetsPickerController

## Introduction

CTAssetsPickerController is a highly customisable iOS controller that allows picking multiple photos and videos from user's photo library. The usage and look-and-feel are just similar to UIImagePickerController. It uses **ARC** and requires **Photos** framework.

![Screenshot](Screenshot.png "Screenshot")
![Screenshot 2](Screenshot-2.png "Screenshot 2")

## Features
1. Picks multiple photos and videos across albums from user's library.
2. Previews assets by long-press gesture.
3. Filters assets for picking only photos or videos.
4. Filters assets or albums by their properties.
5. Supports assets stored in iCloud. 
6. Supports many [languages](https://github.com/chiunam/CTAssetsPickerController/wiki/Localisation).
7. Optionally shows selection order.
8. Achieves average 5x fps.
9. Conforms UIAppearance protocol.
10. Conforms UIAccessibility protocol.
11. Highly customisable.
12. Pure Auto Layout. (Thanks for the great work of [PureLayout](https://github.com/smileyborg/PureLayout))

## Release Notes
* [Release Notes](https://github.com/chiunam/CTAssetsPickerController/releases)

## Minimum Requirement
iOS 9 SDK, Minimum Deployment Target iOS 8.0

## Adding to your project
    	
1. [CocoaPods](http://cocoapods.org) Podfile

    ````
    platform :ios, '8.0'
    pod 'CTAssetsPickerController',  '~> 3.3.0'
    ````
    	
2. [Manual Setup](https://github.com/chiunam/CTAssetsPickerController/wiki/Manual-Setup-(v3))


## Usages

1. Import header

    ```` objective-c
    #import <CTAssetsPickerController/CTAssetsPickerController.h>
    ````

2. Create and present CTAssetsPickerController

    ```` objective-c
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
    ````

3. Implement didFinishPickingAssets delegate

    If the picker is presented by `presentViewController:animated:completion:` method, the delegate is responsible for dismissing the picker when the operation completes.

    ```` objective-c
    - (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
    {
    // assets contains PHAsset objects.
    }
    ````

## Questions, Issues and Suggestions

Please check with [wiki](https://github.com/chiunam/CTAssetsPickerController/wiki/) and [issues](https://github.com/chiunam/CTAssetsPickerController/issues) for common issues and questions. Please open a [new Issue] (https://github.com/chiunam/CTAssetsPickerController/issues/new) if you run into a problem specific to the picker. Bug reports and pull requests are always welcome.

## Bonus

You may reuse the preview feature of the picker to view any assets. Just init a `CTAssetsPageViewController` with an array of assets and assign `pageIndex` property. Please refer to the [demo app](https://github.com/chiunam/CTAssetsPickerController/wiki/Running-demo-app) for the details.

```` objective-c
NSArray *assets = @[asset1, asset2, asset3, ...];
CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:assets];
vc.pageIndex = assets.count - 1; // display the last asset 

[self.navigationController pushViewController:vc animated:YES];
````    

## Documentation
* [Online documentation](http://cocoadocs.org/docsets/CTAssetsPickerController/)


## License

 The MIT License (MIT)

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
