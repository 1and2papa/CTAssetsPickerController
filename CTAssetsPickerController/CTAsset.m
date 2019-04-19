//
//  CTAsset.m
//  CTAssetsPickerController
//
//  Created by Gian Franco Zabarino on 19/04/2019.
//

#import "CTAsset.h"

@implementation PHAsset (Conforming)

- (PHAsset *)photosAsset {
    return self;
}

- (void)fetchImageWithTargetSize:(CGSize)targetSize
                     contentMode:(PHImageContentMode)contentMode
                      completion:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];

    // make sure the call is asynchronous and only calls once the completion handler
    options.synchronous = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [PHImageManager.defaultManager requestImageForAsset:self
                                             targetSize:targetSize
                                            contentMode:contentMode
                                                options:options
                                          resultHandler:completion];
}

- (NSInteger)hash {
    return (NSInteger)[self.localIdentifier hash];
}

@end
