/*
 CTAssetsPickerController.m
 
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

#import "CTAssetsPickerCommon.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsGroupViewController.h"
#import "CTAssetsPageViewController.h"
#import "CTAssetsViewControllerTransition.h"




NSString * const CTAssetsPickerSelectedAssetsChangedNotification = @"CTAssetsPickerSelectedAssetsChangedNotification";

@interface CTAssetsPickerController () <UINavigationControllerDelegate>
@end

@implementation CTAssetsPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _assetsLibrary          = [self.class defaultAssetsLibrary];
        _assetsFilter           = [ALAssetsFilter allAssets];
        _selectedAssets         = [[NSMutableArray alloc] init];
        _showsCancelButton      = YES;
        _showsNumberOfAssets    = YES;
        
        self.preferredContentSize = CTAssetPickerPopoverContentSize;
        
        [self setupNavigationController];
        [self addKeyValueObserver];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeKeyValueObserver];
}



#pragma mark - Setup Navigation Controller

- (void)setupNavigationController
{
    CTAssetsGroupViewController *vc = [[CTAssetsGroupViewController alloc] init];
    UINavigationController *nav = [[self createChildNavigationController] initWithRootViewController:vc];
    nav.delegate = self;
    
    [nav willMoveToParentViewController:self];
    [nav.view setFrame:self.view.frame];
    [self.view addSubview:nav.view];
    [self addChildViewController:nav];
    [nav didMoveToParentViewController:self];
}

- (UINavigationController *)createChildNavigationController
{
    return [UINavigationController alloc];
}

#pragma mark - UINavigationControllerDelegate


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ((operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[CTAssetsPageViewController class]]) ||
        (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[CTAssetsPageViewController class]]))
    {
        CTAssetsViewControllerTransition *transition = [[CTAssetsViewControllerTransition alloc] init];
        transition.operation = operation;
        
        return transition;
    }
    else
    {
        return nil;
    }
}



#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}

//Lazy load assetsLibrary. User will be able to set his custom assetsLibrary
- (ALAssetsLibrary *)assetsLibrary
{
    if (nil == _assetsLibrary)
    {
        _assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    return _assetsLibrary;
}



#pragma mark - Key-Value Observers

- (void)addKeyValueObserver
{
    [self addObserver:self
           forKeyPath:@"selectedAssets"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil];
}

- (void)removeKeyValueObserver
{
    [self removeObserver:self forKeyPath:@"selectedAssets"];
}


#pragma mark - Key-Value Changed

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selectedAssets"])
    {
        [self toggleDoneButton];
        [self postNotification:[object valueForKey:keyPath]];
    }
}


#pragma mark - Toggle Button

- (void)toggleDoneButton
{
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    
    for (UIViewController *viewController in nav.viewControllers)
        viewController.navigationItem.rightBarButtonItem.enabled = (self.selectedAssets.count > 0);
}


#pragma mark - Post Notification

- (void)postNotification:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTAssetsPickerSelectedAssetsChangedNotification
                                                        object:sender];
}


#pragma mark - Accessors

- (UINavigationController *)childNavigationController
{
    return (UINavigationController *)self.childViewControllers.firstObject;
}


#pragma mark - Indexed Accessors

- (NSUInteger)countOfSelectedAssets
{
    return self.selectedAssets.count;
}

- (id)objectInSelectedAssetsAtIndex:(NSUInteger)index
{
    return [self.selectedAssets objectAtIndex:index];
}

- (void)insertObject:(id)object inSelectedAssetsAtIndex:(NSUInteger)index
{
    [self.selectedAssets insertObject:object atIndex:index];
}

- (void)removeObjectFromSelectedAssetsAtIndex:(NSUInteger)index
{
    [self.selectedAssets removeObjectAtIndex:index];
}

- (void)replaceObjectInSelectedAssetsAtIndex:(NSUInteger)index withObject:(ALAsset *)object
{
    [self.selectedAssets replaceObjectAtIndex:index withObject:object];
}


#pragma mark - Select / Deselect Asset

- (void)selectAsset:(ALAsset *)asset
{
    [self insertObject:asset inSelectedAssetsAtIndex:self.countOfSelectedAssets];
}

- (void)deselectAsset:(ALAsset *)asset
{
    [self removeObjectFromSelectedAssetsAtIndex:[self.selectedAssets indexOfObject:asset]];
}


#pragma mark - Not Allowed / No Assets Views

- (NSString *)deviceModel
{
    return [[UIDevice currentDevice] model];
}

- (BOOL)isCameraDeviceAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (UIImageView *)padlockImageView
{
    UIImage *file        = [UIImage imageNamed:@"CTAssetsPickerLocked"];
    UIImage *image       = [file imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImageView *padlock = [[UIImageView alloc] initWithImage:image];
    padlock.tintColor    = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    
    padlock.translatesAutoresizingMaskIntoConstraints = NO;
    
    return padlock;
}

- (NSString *)noAssetsMessage
{
    NSString *format;
    
    if ([self isCameraDeviceAvailable])
        format = NSLocalizedString(@"You can take photos and videos using the camera, or sync photos and videos onto your %@\nusing iTunes.", nil);
    else
        format = NSLocalizedString(@"You can sync photos and videos onto your %@ using iTunes.", nil);
    
    return [NSString stringWithFormat:format, self.deviceModel];
}

- (UILabel *)auxiliaryLabelWithFont:(UIFont *)font color:(UIColor *)color text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.preferredMaxLayoutWidth = 304.0f;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 5;
    label.font          = font;
    label.textColor     = color;
    label.text          = text;
    
    [label sizeToFit];
    
    return label;
}

- (UIView *)centerViewWithViews:(NSArray *)views
{
    UIView *centerView = [[UIView alloc] init];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    for (UIView *view in views)
    {
        [centerView addSubview:view];
        [centerView addConstraint:[self horizontallyAlignedConstraintWithItem:view toItem:centerView]];
    }
    
    return centerView;
}

- (UIView *)auxiliaryViewWithCenterView:(UIView *)centerView
{
    UIView *view = [[UIView alloc] init];
    [view addSubview:centerView];
    
    [view addConstraint:[self horizontallyAlignedConstraintWithItem:centerView toItem:view]];
    [view addConstraint:[self verticallyAlignedConstraintWithItem:centerView toItem:view]];
    
    NSString *accessibilityLabel = @"";
    
    for (UIView *subview in centerView.subviews)
    {
        if ([subview isMemberOfClass:[UILabel class]])
            accessibilityLabel = [accessibilityLabel stringByAppendingFormat:@"%@\n", ((UILabel *)subview).text];
    }
    
    view.accessibilityLabel = accessibilityLabel;
    
    return view;
}

- (NSLayoutConstraint *)horizontallyAlignedConstraintWithItem:(id)view1 toItem:(id)view2
{
    return [NSLayoutConstraint constraintWithItem:view1
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view2
                                        attribute:NSLayoutAttributeCenterX
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)verticallyAlignedConstraintWithItem:(id)view1 toItem:(id)view2
{
    return [NSLayoutConstraint constraintWithItem:view1
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view2
                                        attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (UIView *)notAllowedView
{
    UIImageView *padlock = [self padlockImageView];
    
    UILabel *title =
    [self auxiliaryLabelWithFont:[UIFont boldSystemFontOfSize:17.0]
                           color:[UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1]
                            text:NSLocalizedString(@"This app does not have access to your photos or videos.", nil)];
    UILabel *message =
    [self auxiliaryLabelWithFont:[UIFont systemFontOfSize:14.0]
                           color:[UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1]
                            text:NSLocalizedString(@"You can enable access in Privacy Settings.", nil)];
    
    UIView *centerView = [self centerViewWithViews:@[padlock, title, message]];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-20-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    return [self auxiliaryViewWithCenterView:centerView];
}

- (UIView *)noAssetsView
{
    UILabel *title =
    [self auxiliaryLabelWithFont:[UIFont systemFontOfSize:26.0]
                           color:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1]
                            text:NSLocalizedString(@"No Photos or Videos", nil)];
    
    UILabel *message =
    [self auxiliaryLabelWithFont:[UIFont systemFontOfSize:18.0]
                           color:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1]
                            text:[self noAssetsMessage]];
    
    UIView *centerView = [self centerViewWithViews:@[title, message]];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, message);
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];

    return [self auxiliaryViewWithCenterView:centerView];
}


#pragma mark - Toolbar Title

- (NSPredicate *)predicateOfAssetType:(NSString *)type
{
    return [NSPredicate predicateWithBlock:^BOOL(ALAsset *asset, NSDictionary *bindings) {
        return [[asset valueForProperty:ALAssetPropertyType] isEqual:type];
    }];
}

- (NSString *)toolbarTitle
{
    if (self.selectedAssets.count == 0)
        return nil;
    
    NSPredicate *photoPredicate = [self predicateOfAssetType:ALAssetTypePhoto];
    NSPredicate *videoPredicate = [self predicateOfAssetType:ALAssetTypeVideo];
    
    BOOL photoSelected = ([self.selectedAssets filteredArrayUsingPredicate:photoPredicate].count > 0);
    BOOL videoSelected = ([self.selectedAssets filteredArrayUsingPredicate:videoPredicate].count > 0);
    
    NSString *format;
    
    if (photoSelected && videoSelected)
        format = NSLocalizedString(@"%ld Items Selected", nil);
    
    else if (photoSelected)
        format = (self.selectedAssets.count > 1) ? NSLocalizedString(@"%ld Photos Selected", nil) : NSLocalizedString(@"%ld Photo Selected", nil);
    
    else if (videoSelected)
        format = (self.selectedAssets.count > 1) ? NSLocalizedString(@"%ld Videos Selected", nil) : NSLocalizedString(@"%ld Video Selected", nil);
    
    return [NSString stringWithFormat:format, (long)self.selectedAssets.count];
}


#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title =
    [[UIBarButtonItem alloc] initWithTitle:self.toolbarTitle
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    
    [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [title setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [title setEnabled:NO];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title = [self titleButtonItem];
    UIBarButtonItem *space = [self spaceButtonItem];
    
    return @[space, title, space];
}


#pragma mark - Actions

- (void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [self.delegate assetsPickerControllerDidCancel:self];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
}


@end