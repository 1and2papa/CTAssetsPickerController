/*
 
 MIT License (MIT)
 
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

#import <PureLayout/PureLayout.h>
#import "CTAssetScrollView.h"
#import "CTAssetPlayButton.h"
#import "PHAsset+CTAssetsPickerController.h"
#import "NSBundle+CTAssetsPickerController.h"
#import "UIImage+CTAssetsPickerController.h"




NSString * const CTAssetScrollViewDidTapNotification = @"CTAssetScrollViewDidTapNotification";
NSString * const CTAssetScrollViewPlayerWillPlayNotification = @"CTAssetScrollViewPlayerWillPlayNotification";
NSString * const CTAssetScrollViewPlayerWillPauseNotification = @"CTAssetScrollViewPlayerWillPauseNotification";




@interface CTAssetScrollView ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign) CGFloat perspectiveZoomScale;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) CTAssetPlayButton *playButton;

@property (nonatomic, assign) BOOL shouldUpdateConstraints;
@property (nonatomic, assign) BOOL didSetupConstraints;


@end





@implementation CTAssetScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _shouldUpdateConstraints            = YES;
        self.showsVerticalScrollIndicator   = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom                    = YES;
        self.decelerationRate               = UIScrollViewDecelerationRateFast;
        self.delegate                       = self;
        
        [self setupViews];
        [self addGestureRecognizers];
    }
    
    return self;
}

- (void)dealloc
{
    [self removePlayerNotificationObserver];
    [self removePlayerKeyValueObserver];
}


#pragma mark - Setup

- (void)setupViews
{
    UIImageView *imageView = [UIImageView new];
    imageView.isAccessibilityElement    = YES;
    imageView.accessibilityTraits       = UIAccessibilityTraitImage;
    self.imageView = imageView;
    
    [self addSubview:self.imageView];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityView = activityView;
    
    [self addSubview:self.activityView];
    
    CTAssetPlayButton *playButton = [CTAssetPlayButton newAutoLayoutView];
    self.playButton = playButton;
    [self addSubview:self.playButton];
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self updateButtonConstraints];
        [self updateActivityConstraints];
        
        self.didSetupConstraints = YES;
    }

    [self updateContentFrame];
    [super updateConstraints];
}

- (void)updateActivityConstraints
{
    [self.activityView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.superview];
    [self.activityView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.superview];
}


- (void)updateButtonConstraints
{
    [self.playButton autoAlignAxis:ALAxisVertical toSameAxisOfView:self.superview];
    [self.playButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.superview];
}


- (void)updateContentFrame
{
    CGSize boundsSize = self.bounds.size;
    
    CGFloat w = self.zoomScale * self.asset.pixelWidth;
    CGFloat h = self.zoomScale * self.asset.pixelHeight;
    
    CGFloat dx = (boundsSize.width - w) / 2.0;
    CGFloat dy = (boundsSize.height - h) / 2.0;

    self.contentOffset = CGPointZero;
    self.imageView.frame = CGRectMake(dx, dy, w, h);
}



#pragma mark - Bind asset

- (void)bind:(PHAsset *)asset image:(UIImage *)image requestInfo:(NSDictionary *)info
{
    self.asset = asset;
    self.imageView.accessibilityLabel = asset.accessibilityLabel;    
    self.playButton.hidden = [asset ctassetsPickerIsPhoto];
    
    BOOL isDegraded = [info[PHImageResultIsDegradedKey] boolValue];
    
    if (self.image == nil || !isDegraded)
    {
        BOOL zoom = (!self.image);
        self.image = image;
        self.imageView.image = image;
        
        if (isDegraded)
            [self.activityView startAnimating];
        else
            [self.activityView stopAnimating];

        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];        
        [self updateZoomScalesAndZoom:zoom];
    }
}

- (void)bind:(AVPlayerItem *)playerItem requestInfo:(NSDictionary *)info
{
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

    CALayer *layer = self.imageView.layer;
    [layer addSublayer:playerLayer];
    [playerLayer setFrame:layer.bounds];
    
    self.player = player;

    [self addPlayerNotificationObserver];
    [self addPlayerKeyValueObserver];
    
    [self playVideo];
}

- (CGSize)assetSize
{
    return CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
}


#pragma mark - Upate zoom scales

- (void)updateZoomScalesAndZoom:(BOOL)zoom
{
    if (!self.asset)
        return;
    
    CGSize assetSize    = [self assetSize];
    CGSize boundsSize   = self.bounds.size;
    
    CGFloat xScale = boundsSize.width / assetSize.width;    //scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / assetSize.height;  //scale needed to perfectly fit the image height-wise
    
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = 3.0 * minScale;
    
    if ([self.asset ctassetsPickerIsVideo])
    {
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = minScale;
    }
    
    else
    {
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = maxScale;
    }
    
    // update perspective zoom scale
    self.perspectiveZoomScale = (boundsSize.width > boundsSize.height) ? xScale : yScale;
    
    if (zoom)
        [self zoomToInitialScale];
}



#pragma mark - Zoom

- (void)zoomToInitialScale
{
    if ([self canPerspectiveZoom])
        [self zoomToPerspectiveZoomScaleAnimated:NO];
    else
        [self zoomToMinimumZoomScaleAnimated:NO];
}

- (void)zoomToMinimumZoomScaleAnimated:(BOOL)animated
{
    [self setZoomScale:self.minimumZoomScale animated:animated];
}

- (void)zoomToMaximumZoomScaleWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    CGRect zoomRect = [self zoomRectWithScale:self.maximumZoomScale withCenter:[recognizer locationInView:recognizer.view]];

    self.shouldUpdateConstraints = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self zoomToRect:zoomRect animated:NO];
        
        CGRect frame = self.imageView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;

        self.imageView.frame = frame;
    }];
}


#pragma mark - Perspective zoom

- (BOOL)canPerspectiveZoom
{
    CGSize assetSize    = [self assetSize];
    CGSize boundsSize   = self.bounds.size;
    
    CGFloat assetRatio  = assetSize.width / assetSize.height;
    CGFloat boundsRatio = boundsSize.width / boundsSize.height;
    
    // can perform perspective zoom when the difference of aspect ratios is smaller than 20%
    return (fabs( (assetRatio - boundsRatio) / boundsRatio ) < 0.2f);
}

- (void)zoomToPerspectiveZoomScaleAnimated:(BOOL)animated;
{
    CGRect zoomRect = [self zoomRectWithScale:self.perspectiveZoomScale];
    [self zoomToRect:zoomRect animated:animated];
}

- (CGRect)zoomRectWithScale:(CGFloat)scale
{
    CGSize targetSize;
    targetSize.width    = self.bounds.size.width / scale;
    targetSize.height   = self.bounds.size.height / scale;
    
    CGPoint targetOrigin;
    targetOrigin.x      = (self.asset.pixelWidth - targetSize.width) / 2.0;
    targetOrigin.y      = (self.asset.pixelHeight - targetSize.height) / 2.0;
    
    CGRect zoomRect;
    zoomRect.origin = targetOrigin;
    zoomRect.size   = targetSize;

    return zoomRect;
}


#pragma mark - Zoom with gesture recognizer

- (void)zoomWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (self.minimumZoomScale == self.maximumZoomScale)
        return;
    
    if ([self canPerspectiveZoom])
    {
        if ((self.zoomScale >= self.minimumZoomScale && self.zoomScale < self.perspectiveZoomScale) ||
            (self.zoomScale <= self.maximumZoomScale && self.zoomScale > self.perspectiveZoomScale))
            [self zoomToPerspectiveZoomScaleAnimated:YES];
        else
            [self zoomToMaximumZoomScaleWithGestureRecognizer:recognizer];
        
        return;
    }
    
    if (self.zoomScale < self.maximumZoomScale)
        [self zoomToMaximumZoomScaleWithGestureRecognizer:recognizer];
    else
        [self zoomToMinimumZoomScaleAnimated:YES];
}

- (CGRect)zoomRectWithScale:(CGFloat)scale withCenter:(CGPoint)center
{
    center = [self.imageView convertPoint:center fromView:self];
    
    CGRect zoomRect;
    
    zoomRect.size.height = self.imageView.frame.size.height / scale;
    zoomRect.size.width  = self.imageView.frame.size.width  / scale;
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}


#pragma mark - Gesture recognizers

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    
    [doubleTap setNumberOfTapsRequired:2.0];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [singleTap setDelegate:self];
    [doubleTap setDelegate:self];
    
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
}


#pragma mark - Handle tappings

- (void)handleTapping:(UITapGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTAssetScrollViewDidTapNotification object:recognizer];
    
    if (recognizer.numberOfTapsRequired == 2)
        [self zoomWithGestureRecognizer:recognizer];
}


#pragma mark - Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.shouldUpdateConstraints = YES;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setScrollEnabled:(self.zoomScale != self.perspectiveZoomScale)];
    
    if (self.shouldUpdateConstraints)
    {
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    }
}


#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isDescendantOfView:self.playButton];
}


#pragma mark - Notification observer

- (void)addPlayerNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(applicationWillResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(playerDidPlayToEnd:)
                   name:AVPlayerItemDidPlayToEndTimeNotification
                 object:nil];
}

- (void)removePlayerNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}



#pragma mark - Video player item key-value observer

- (void)addPlayerKeyValueObserver
{
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
}

- (void)removePlayerKeyValueObserver
{
    [self.player removeObserver:self forKeyPath:@"rate"];
}


#pragma mark - Video playback Key-Value changed

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"rate"])
    {
        CGFloat old = [[change valueForKey:NSKeyValueChangeOldKey] floatValue];
        CGFloat new = [[change valueForKey:NSKeyValueChangeNewKey] floatValue];

        if (old == 0.0 && new > 0.0)
        {
            if ([self playerAtStartTime])
                [self performSelector:@selector(playerWillPlayFromStart:) withObject:object];
            else
                [self performSelector:@selector(playerWillResume:) withObject:object];
        }
        
        if (old > 0.0 && new == 0.0)
            [self performSelector:@selector(playerWillPause:) withObject:object];
        
        if (old == new && new > 0.0)
            [self performSelector:@selector(playerDidPlayFromStart:) withObject:object];
    }
}


#pragma mark - Playback events

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.player pause];
    self.playButton.hidden = NO;
}

- (void)playerDidPlayToEnd:(NSNotification *)notification
{
    self.playButton.hidden = NO;
}

- (void)playerWillPlayFromStart:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTAssetScrollViewPlayerWillPlayNotification object:sender];
    self.playButton.hidden = YES;
    
    [self.activityView startAnimating];
}

- (void)playerDidPlayFromStart:(id)sender
{
    [self.activityView stopAnimating];
}

- (void)playerWillResume:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTAssetScrollViewPlayerWillPlayNotification object:sender];
    self.playButton.hidden = YES;
}

- (void)playerWillPause:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTAssetScrollViewPlayerWillPauseNotification object:sender];
}



#pragma mark - Playback

- (BOOL)playerAtStartTime
{
    return (CMTimeCompare(self.player.currentTime, kCMTimeZero) == 0);
}

- (BOOL)playerAtEndTime
{
    return (CMTimeCompare(self.player.currentTime, self.player.currentItem.duration) == 0);
}

- (void)playVideo
{
    if ([self playerAtEndTime])
        [self.player seekToTime:kCMTimeZero];
    
    [self.player play];
}

- (void)pauseVideo
{
    [self.player pause];
}




@end
