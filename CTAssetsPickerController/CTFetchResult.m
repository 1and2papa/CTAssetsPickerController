//
//  CTFetchResult.m
//  CTAssetsPickerController
//
//  Created by Gian Franco Zabarino on 09/04/2019.
//

#import "CTFetchResult.h"
#import "CTAsset.h"

@interface CTFetchResult()

@property(nonatomic, strong) NSArray<id<CTAsset>> *assets;
@property(nonatomic, strong) NSString *collectionTitle;

- (instancetype)initWithAssets:(NSArray<id<CTAsset>> *)assets collectionTitle:(NSString *)collectionTitle;

@end

@implementation CTFetchResult

+ (instancetype)fetchResultWithAssets:(NSArray<id<CTAsset>> *)assets collectionTitle:(NSString *)collectionTitle {
    return [[self alloc] initWithAssets:assets collectionTitle:collectionTitle];
}

- (instancetype)initWithAssets:(NSArray<id<CTAsset>> *)assets collectionTitle:(NSString *)collectionTitle {
    self = [super init];
    if (self) {
        self.assets = assets;
        self.collectionTitle = collectionTitle;
    }
    return self;
}

- (NSString *)collectionTitleWithCollection:(__unused PHCollection *)collection {
    return self.collectionTitle;
}

- (PHFetchResult *)photosFetchResult {
    return nil;
}

- (NSUInteger) count {
    return self.assets.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    return self.assets[index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

- (NSUInteger)indexOfObject:(id)anObject {
    return [self.assets indexOfObject:anObject];
}

- (NSUInteger)countOfAssetsWithMediaType:(PHAssetMediaType)mediaType {
    return 0;
}

@end

@implementation PHFetchResult (Conforming)

- (NSString *)collectionTitleWithCollection:(PHCollection *)collection {
    return collection.localizedTitle;
}

- (PHFetchResult *)photosFetchResult {
    return self;
}

@end
