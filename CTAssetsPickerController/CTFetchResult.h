//
//  CTFetchResult.h
//  CTAssetsPickerController
//
//  Created by Gian Franco Zabarino on 09/04/2019.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

//NS_ASSUME_NONNULL_BEGIN

@protocol CTAsset;

@protocol CTFetchResult<NSObject>

@property (readonly) NSUInteger count;

- (NSString *)collectionTitleWithCollection:(PHCollection *)collection;
- (nullable PHFetchResult *)photosFetchResult;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)countOfAssetsWithMediaType:(PHAssetMediaType)mediaType;

@end

@interface CTFetchResult: NSObject<CTFetchResult>

+ (instancetype)fetchResultWithAssets:(NSArray<id<CTAsset>> *)assets collectionTitle:(NSString *)collectionTitle;

@end

@interface PHFetchResult (Conforming) <CTFetchResult>

- (nullable PHFetchResult *)photosFetchResult;

@end

//NS_ASSUME_NONNULL_END
