/*
 CTAssetsPageViewController.h
 
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
 
 */

#import <UIKit/UIKit.h>






/**
 *  A view controller that shows selected photos and vidoes from user's photo library that let the user navigate the item page by page.
 */
@interface CTAssetsPageViewController : UIPageViewController

/**
 *  The index of the photo or video with the currently showing item.
 */
@property (nonatomic, assign) NSInteger pageIndex;


/**
 *  @name Creating a Assets Page View Controller
 */

/**
 *  Initializes a newly created view controller with an array of asset items.
 *
 *  @param assets An array of `ALAsset` objects.
 *
 *  @return An instance of `CTAssetPageViewController` initialized to show the asset items in `assets`.
 */
- (id)initWithAssets:(NSArray *)assets;

@end