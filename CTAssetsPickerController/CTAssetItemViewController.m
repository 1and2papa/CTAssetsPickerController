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

#import <MobileCoreServices/MobileCoreServices.h>
#import <PureLayout/PureLayout.h>
#import "CTAssetsPickerController.h"
#import "CTAssetItemViewController.h"
#import "CTAssetScrollView.h"
#import "NSBundle+CTAssetsPickerController.h"
#import "PHAsset+CTAssetsPickerController.h"
#import "PHImageManager+CTAssetsPickerController.h"
#import "CTAssetAnimatedImage.h"


@interface CTAssetItemViewController ()

@property (nonatomic, weak) CTAssetsPickerController *picker;

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) PHImageRequestID animatedImageRequestID;
@property (nonatomic, assign) PHImageRequestID playerItemRequestID;
@property (nonatomic, strong) CTAssetScrollView *scrollView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end


/**
 *  Compatibility mode for requesting animated images.
 *
 *  @note In iOS 8 just to know whether a current asset is GIF we must download the full-sized image data. Such approach is very inefficient considering that the image could be in iCloud. Therefore, for iOS 8 it's better to use 'CTAssetRequestAnimatedImageLocalFilesOnly' mode which guarantees playing only local GIFs (for iCloud images only poster image will be downloaded).
 */
typedef NS_ENUM(NSUInteger, CTAssetRequestAnimatedImageMode) {
    /** Request GIFs for on-device files only. Compatible with iOS 8.*/
    CTAssetRequestAnimatedImageLocalFilesOnly = 0,
    /** Request GIFs for both on-device and iCloud files. Native mode in iOS 9+. */
    CTAssetRequestAnimatedImageNormalMode
};


@implementation CTAssetItemViewController

+ (CTAssetItemViewController *)assetItemViewControllerForAsset:(PHAsset *)asset
{
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(PHAsset *)asset
{
    if (self = [super init])
    {
        _imageManager = [PHImageManager defaultManager];
        self.asset = asset;
        self.allowsSelection = NO;
        self.allowsAnimatedImages = NO;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupScrollViewButtons];

    // ensure that we are not making the same request multiple times
    if(self.image == nil)
    {
        if (self.allowsAnimatedImages)
        {
            // [iOS 9 SECTION BEGINS]
            // Note: In iOS 9 there is a quick way to determine GIF type using PHAssetResource class
            if(NSClassFromString(@"PHAssetResource"))
            {
                NSArray *assetResources = [PHAssetResource assetResourcesForAsset: self.asset];
                
                // to determine GIF type only the first asset resource is required
                PHAssetResource *firstFoundResource = assetResources[0];
                
                if([firstFoundResource.uniformTypeIdentifier isEqualToString:(NSString *)kUTTypeGIF])
                    [self requestAssetAnimatedImageWithCompatibilityMode:CTAssetRequestAnimatedImageNormalMode];
                else
                    [self requestAssetImage];
            }
            // [iOS 9 SECTION ENDS]
            else
            {
                // [iOS 8 SECTION BEGINS]
                // Note: In iOS 8 there is no documented way to detect if the asset type is GIF without request for full-sized image data
                // the only thing we can do is to filter out non-image media types
                if (self.asset.mediaType == PHAssetMediaTypeImage &&
                    (self.asset.mediaSubtypes & PHAssetMediaSubtypeNone) == 0)
                    
                    [self requestAssetAnimatedImageWithCompatibilityMode:CTAssetRequestAnimatedImageLocalFilesOnly];
                else
                    [self requestAssetImage];
                // [iOS 8 SECTION ENDS]
            }
        }
        else
            [self requestAssetImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pauseAsset:self.view];
    [self cancelRequestAsset];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.scrollView setNeedsUpdateConstraints];
    [self.scrollView updateConstraintsIfNeeded];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.scrollView updateZoomScalesAndZoom:YES];
    } completion:nil];
}


#pragma mark - Accessors

- (CTAssetsPickerController *)picker
{
    return (CTAssetsPickerController *)self.splitViewController.parentViewController;
}


#pragma mark - Setup

- (void)setupViews
{
    CTAssetScrollView *scrollView = [CTAssetScrollView newAutoLayoutView];
    scrollView.allowsSelection = self.allowsSelection;
    scrollView.allowsAnimatedImages = self.allowsAnimatedImages;
    
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
    [self.view layoutIfNeeded];
}

- (void)setupScrollViewButtons
{
    CTAssetPlayButton *playButton = self.scrollView.playButton;
    [playButton addTarget:self action:@selector(playAsset:) forControlEvents:UIControlEventTouchUpInside];
    
    CTAssetSelectionButton *selectionButton = self.scrollView.selectionButton;

    selectionButton.enabled  = [self assetScrollView:self.scrollView shouldEnableAsset:self.asset];
    selectionButton.selected = [self.picker.selectedAssets containsObject:self.asset];

    [selectionButton addTarget:self action:@selector(selectionButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [selectionButton addTarget:self action:@selector(selectionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Cancel request

- (void)cancelRequestAsset
{
    [self cancelRequestImage];
    [self cancelRequestAnimatedImage];
    [self cancelRequestPlayerItem];
}

- (void)cancelRequestImage
{
    if (self.imageRequestID)
    {
        [self.scrollView setProgress:1];
        [self.imageManager cancelImageRequest:self.imageRequestID];
    }
}

- (void)cancelRequestAnimatedImage
{
    if (self.animatedImageRequestID)
    {
        [self.scrollView setProgress:1];
        [self.imageManager cancelImageRequest:self.animatedImageRequestID];
    }
}

- (void)cancelRequestPlayerItem
{
    if (self.playerItemRequestID)
    {
        [self.scrollView stopActivityAnimating];
        [self.imageManager cancelImageRequest:self.playerItemRequestID];
    }
}


#pragma mark - Request image

- (void)requestAssetImage
{
    [self.scrollView setProgress:0];
    
    CGSize targetSize = [self targetImageSize];
    PHImageRequestOptions *options = [self imageRequestOptions];
    
    self.imageRequestID =
    [self.imageManager ctassetsPickerRequestImageForAsset:self.asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *image, NSDictionary *info) {

                                  // this image is set for transition animation
                                  self.image = image;

                                  dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                      NSError *error = info[PHImageErrorKey];
                                      
                                      if (error)
                                          [self showRequestImageError:error title:nil];
                                      else
                                          [self.scrollView bind:self.asset image:image requestInfo:info];
                                  });
                              }];
}

- (CGSize)targetImageSize
{
    UIScreen *screen    = UIScreen.mainScreen;
    CGFloat scale       = screen.scale;
    return CGSizeMake(CGRectGetWidth(screen.bounds) * scale, CGRectGetHeight(screen.bounds) * scale);
}

- (PHImageRequestOptions *)imageRequestOptions
{
    PHImageRequestOptions *options  = [PHImageRequestOptions new];
    options.networkAccessAllowed    = YES;
    options.progressHandler         = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setProgress:progress];
        });
    };

    return options;
}


#pragma mark - Request animated image

- (void)requestAssetAnimatedImageWithCompatibilityMode:(CTAssetRequestAnimatedImageMode)compatibilityMode
{
    [self.scrollView setProgress:0];

    PHImageRequestOptions *options = [self animatedImageRequestOptionsWithCompatibilityMode:compatibilityMode];
    
    self.animatedImageRequestID =
    [self.imageManager requestImageDataForAsset:self.asset
                                        options:options
                                  resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                                      
                                      NSError *error = [info objectForKey:PHImageErrorKey];
                                      
                                      if(error)
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              [self showRequestImageError:error title:nil];
                                          });
                                      }
                                      else
                                      {
                                          CTAssetAnimatedImage *image;
                                          
                                          NSNumber *isInCloud = [info objectForKey:PHImageResultIsInCloudKey];
                                          
                                          BOOL isCompatibleWithCurrentOSVersion = (compatibilityMode == CTAssetRequestAnimatedImageLocalFilesOnly) ? !isInCloud.boolValue : YES;

                                          if([dataUTI isEqualToString:(NSString *)kUTTypeGIF] && isCompatibleWithCurrentOSVersion)
                                          {
                                              FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                                              image = [[CTAssetAnimatedImage alloc]initWithAnimatedImage:animatedImage];
                                              self.image = image;
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  
                                                  [self.scrollView bind:self.asset image:image requestInfo:info];
                                              });
                                          }
                                          else
                                          {
                                              // for ordinary images it's much more efficient to decompress by means of requestImageForAsset method
                                              [self requestAssetImage];
                                          }
                                      }

                                  }];
}


- (PHImageRequestOptions *)animatedImageRequestOptionsWithCompatibilityMode:(CTAssetRequestAnimatedImageMode)compatibilityMode
{
    PHImageRequestOptions *options  = [PHImageRequestOptions new];

    switch (compatibilityMode) {
        case CTAssetRequestAnimatedImageNormalMode:
            options.networkAccessAllowed = YES;
            break;
            
        case CTAssetRequestAnimatedImageLocalFilesOnly:
            options.networkAccessAllowed = NO;
            break;

        default:
            // don't allow network access if unknown compatibility mode has been received
            options.networkAccessAllowed = NO;
            break;
    }
    
    options.progressHandler         = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setProgress:progress];
        });
    };

    return options;
}


#pragma mark - Request player item

- (void)requestAssetPlayerItem:(id)sender
{
    [self.scrollView startActivityAnimating];
    
    PHVideoRequestOptions *options = [self videoRequestOptions];
    
    self.playerItemRequestID =
    [self.imageManager requestPlayerItemForVideo:self.asset
                                         options:options
                                   resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           NSError *error   = info[PHImageErrorKey];
                                           NSString * title = CTAssetsPickerLocalizedString(@"Cannot Play Stream Video", nil);
                                           
                                           if (error)
                                               [self showRequestVideoError:error title:title];
                                           else
                                               [self.scrollView bind:playerItem requestInfo:info];
                                       });
                                   }];
}

- (PHVideoRequestOptions *)videoRequestOptions
{
    PHVideoRequestOptions *options  = [PHVideoRequestOptions new];
    options.networkAccessAllowed    = YES;
    options.progressHandler         = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //do nothing
        });
    };
    
    return options;
}


#pragma mark - Request error

- (void)showRequestImageError:(NSError *)error title:(NSString *)title
{
    [self.scrollView setProgress:1];
    [self showRequestError:error title:title];
}

- (void)showRequestVideoError:(NSError *)error title:(NSString *)title
{
    [self.scrollView stopActivityAnimating];
    [self showRequestError:error title:title];
}

- (void)showRequestError:(NSError *)error title:(NSString *)title
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action =
    [UIAlertAction actionWithTitle:CTAssetsPickerLocalizedString(@"OK", nil)
                             style:UIAlertActionStyleDefault
                           handler:nil];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Playback

- (void)playAsset:(id)sender
{
    if (!self.scrollView.player)
        [self requestAssetPlayerItem:sender];
    else
        [self.scrollView playVideo];
}

- (void)pauseAsset:(id)sender
{
    if (!self.scrollView.player)
        [self cancelRequestPlayerItem];
    else
        [self.scrollView pauseVideo];
}


#pragma mark - Selection

- (void)selectionButtonTouchDown:(id)sender
{
    PHAsset *asset = self.asset;
    CTAssetScrollView *scrollView = self.scrollView;
    
    if ([self assetScrollView:scrollView shouldHighlightAsset:asset])
        [self assetScrollView:scrollView didHighlightAsset:asset];
}

- (void)selectionButtonTouchUpInside:(id)sender
{
    PHAsset *asset = self.asset;
    CTAssetScrollView *scrollView = self.scrollView;
    CTAssetSelectionButton *selectionButton = scrollView.selectionButton;
    
    
    if (!selectionButton.selected)
    {
        if ([self assetScrollView:scrollView shouldSelectAsset:asset])
        {
            [self.picker selectAsset:asset];
            [selectionButton setSelected:YES];
            [self assetScrollView:scrollView didSelectAsset:asset];
        }
    }
    
    else
    {
        if ([self assetScrollView:scrollView shouldDeselectAsset:asset])
        {
            [self.picker deselectAsset:asset];
            [selectionButton setSelected:NO];
            [self assetScrollView:scrollView didDeselectAsset:asset];
        }
    }
    
    [self assetScrollView:self.scrollView didUnhighlightAsset:self.asset];
}


#pragma mark - Asset scrollView delegate

- (BOOL)assetScrollView:(CTAssetScrollView *)scrollView shouldEnableAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    else
        return YES;
}

- (BOOL)assetScrollView:(CTAssetScrollView *)scrollView shouldSelectAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(CTAssetScrollView *)scrollView didSelectAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
}

- (BOOL)assetScrollView:(CTAssetScrollView *)scrollView shouldDeselectAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(CTAssetScrollView *)scrollView didDeselectAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
}

- (BOOL)assetScrollView:(CTAssetScrollView *)scrollView shouldHighlightAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(CTAssetScrollView *)scrollView didHighlightAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)assetScrollView:(CTAssetScrollView *)scrollView didUnhighlightAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}


@end
