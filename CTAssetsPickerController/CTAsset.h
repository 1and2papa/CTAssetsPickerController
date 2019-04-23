//
//  CTAsset.h
//  CTAssetsPickerController
//
//  Created by Gian Franco Zabarino on 19/04/2019.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

//NS_ASSUME_NONNULL_BEGIN

@protocol CTAsset

@property (nonatomic, assign, readonly) NSUInteger pixelWidth;
@property (nonatomic, assign, readonly) NSUInteger pixelHeight;
@property (nonatomic, assign, readonly) PHAssetMediaType mediaType;

- (nullable PHAsset *)photosAsset;

- (void)fetchImageWithTargetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode completion:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))completion;

@end

@interface PHAsset (Conforming) <CTAsset>

- (nullable PHAsset *)photosAsset;

@end

//NS_ASSUME_NONNULL_END
