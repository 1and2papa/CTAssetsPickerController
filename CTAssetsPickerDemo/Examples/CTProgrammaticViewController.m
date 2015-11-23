/*
 
 MIT License (MIT)
 
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
 
 */

#import "CTProgrammaticViewController.h"

@interface CTProgrammaticViewController ()

@property (nonatomic, strong) PHFetchResult *result;
@property (nonatomic, strong) PHFetchOptions *options;
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end


@implementation CTProgrammaticViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *startButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showAlert:)];
    
    UIBarButtonItem *space =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[space, startButton];
    
    // get album of Camera Roll
    PHFetchResult *assetCollections =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                             subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                             options:nil];
    // create assets fetch options
    self.options = [PHFetchOptions new];
    self.options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];

    self.result = [PHAsset fetchAssetsInAssetCollection:assetCollections.firstObject options:self.options];
}

- (void)showAlert:(id)sender
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Attention"
                                        message:@"It will select last 5 assets one by one in Camera Roll, and then deselect them."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               [self start];
                           }];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)start
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // set default album (Camera Roll)
            picker.defaultAssetCollection = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
            
            // align assets fetch options
            picker.assetsFetchOptions = self.options;
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:^{
                [self selectAssetsForAssetsPickertController:picker];
            }];
            
        });
    }];
}

- (void)selectAssetsForAssetsPickertController:(CTAssetsPickerController *)picker
{
    NSInteger count = 0;
    CGFloat pause = 1.0;
    
    for (NSInteger index = self.result.count - 1; index > self.result.count - 6; index--)
    {
        PHAsset *asset = [self.result objectAtIndex:index];
        [picker performSelector:@selector(selectAsset:) withObject:asset afterDelay:count * pause];
        [picker performSelector:@selector(deselectAsset:) withObject:asset afterDelay:(count + 5) * pause];
        
        count ++;
    }
}


@end
