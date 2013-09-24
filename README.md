# CTAssetsPickerViewController

CTAssetsPickerViewController is an iOS view controller that allows picking multiple photos and videos from user's photo library. The usage and look-and-feel just similar to UIImagePickerController. It uses **ARC** and requires **AssetsLibrary** framework.

![Screenshot](https://raw.github.com/chiunam/CTAssetsPickerViewController/master/Screenshot.png "Screenshot")

## Adding to Project

1. Drag `CTAssetsPickerViewController` folder in your project.
2. Add `AssetsLibrary.framework`.

## Usage

See the Demo Xcode project for details.

### Create and present CTAssetsPickerViewController

```` objective-c
CTAssetsPickerViewController *picker = [[CTAssetsPickerViewController alloc] init];
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

### Implement CTAssetsPickerViewControllerDelegate

*didFinishPickingAssets*
```` objective-c
- (void)assetsPickerViewController:(CTAssetsPickerViewController *)picker didFinishPickingAssets:(NSArray *)assets
// assets contains ALAsset objects.
````

*didCancel (Optional)*
```` objective-c
- (void)assetsPickerControllerDidCancel:(CTAssetsPickerViewController *)picker;
````

## Note
CTAssetsPickerViewController does not compress the picked photos and videos. You can process the picked assets via the `defaultRepresentation` property.

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