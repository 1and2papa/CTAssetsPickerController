
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


#import "CTAssetsPickerController.h"

NSString * const CTAssetsPickerSelectedAssetsChangedNotification = @"CTAssetsPickerSelectedAssetsChangedNotification";

static const CGFloat kThumbnailLength = 78.0f;
static const CGSize kThumbnailSize = {kThumbnailLength, kThumbnailLength};
static const CGSize kPopoverContentSize = {320, 480};


#pragma mark - Interfaces

@interface CTAssetsPickerController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end



@interface CTAssetsGroupViewController : UITableViewController

@end

@interface CTAssetsGroupViewController()

@property (nonatomic, strong) NSMutableArray *groups;

@end



@interface CTAssetsViewController : UICollectionViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end

@interface CTAssetsViewController ()

@property (nonatomic, strong) NSMutableArray *assets;

@end



@interface CTAssetsGroupViewCell : UITableViewCell

- (void)bind:(ALAssetsGroup *)assetsGroup;

@end

@interface CTAssetsGroupViewCell ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end



@interface CTAssetsViewCell : UICollectionViewCell

- (void)bind:(ALAsset *)asset;

@end

@interface CTAssetsViewCell ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

@end



@interface CTAssetsSupplementaryView : UICollectionReusableView

@property (nonatomic, strong) UILabel *label;

- (void)bind:(NSArray *)assets;

@end

@interface CTAssetsSupplementaryView ()

@end





#pragma mark - Categories

@implementation ALAsset (isEqual)

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:ALAsset.class])
        return NO;
    
    return ([[self valueForProperty:ALAssetPropertyAssetURL] isEqual:[object valueForProperty:ALAssetPropertyAssetURL]]);
}

@end


@implementation ALAssetsGroup (isEqual)

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:ALAssetsGroup.class])
        return NO;
    
    return ([[self valueForProperty:ALAssetsGroupPropertyURL] isEqual:[object valueForProperty:ALAssetsGroupPropertyURL]]);
}

@end


@implementation NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    
    unsigned int unitFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    return [calendar components:unitFlags
                       fromDate:date1
                         toDate:date2
                        options:0];
}

+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSDateComponents *components = [self.class componetsWithTimeInterval:timeInterval];
    NSInteger roundedSeconds = lround(timeInterval - (components.hour * 60 * 60) - (components.minute * 60));
    
    if (components.hour > 0)
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)roundedSeconds];
    
    else
        return [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)roundedSeconds];
}

@end





#pragma mark - CTAssetsPickerController

@implementation CTAssetsPickerController

- (id)init
{
    CTAssetsGroupViewController *groupViewController = [[CTAssetsGroupViewController alloc] init];
    
    if (self = [super initWithRootViewController:groupViewController])
    {
        _assetsLibrary      = [self.class defaultAssetsLibrary];
        _assetsFilter       = [ALAssetsFilter allAssets];
        _selectedAssets     = [[NSMutableArray alloc] init];
        _showsCancelButton  = YES;

        self.preferredContentSize = kPopoverContentSize;
        
        [self addKeyValueObserver];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeKeyValueObserver];
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


#pragma mark - Key-Value Change Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selectedAssets"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTAssetsPickerSelectedAssetsChangedNotification
                                                            object:[object valueForKey:keyPath]];
    }
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
    UIImageView *padlock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CTAssetsPickerLocked"]];
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

- (UILabel *)specialViewLabelWithFont:(UIFont *)font color:(UIColor *)color text:(NSString *)text
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

- (UIView *)specialViewWithCenterView:(UIView *)centerView
{
    UIView *view = [[UIView alloc] init];
    [view addSubview:centerView];
    
    [view addConstraint:[self horizontallyAlignedConstraintWithItem:centerView toItem:view]];
    [view addConstraint:[self verticallyAlignedConstraintWithItem:centerView toItem:view]];
    
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
    [self specialViewLabelWithFont:[UIFont boldSystemFontOfSize:17.0]
                             color:[UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1]
                              text:NSLocalizedString(@"This app does not have access to your photos or videos.", nil)];
    UILabel *message =
    [self specialViewLabelWithFont:[UIFont systemFontOfSize:14.0]
                             color:[UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1]
                              text:NSLocalizedString(@"You can enable access in Privacy Settings.", nil)];
    
    UIView *centerView = [self centerViewWithViews:@[padlock, title, message]];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-20-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    return [self specialViewWithCenterView:centerView];
}

- (UIView *)noAssetsView
{
    UILabel *title =
    [self specialViewLabelWithFont:[UIFont systemFontOfSize:26.0]
                             color:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1]
                              text:NSLocalizedString(@"No Photos or Videos", nil)];
    
    UILabel *message =
    [self specialViewLabelWithFont:[UIFont systemFontOfSize:18.0]
                             color:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1]
                              text:[self noAssetsMessage]];
    
    UIView *centerView = [self centerViewWithViews:@[title, message]];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, message);
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];

    return [self specialViewWithCenterView:centerView];
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





#pragma mark - CTAssetsGroupViewController

@implementation CTAssetsGroupViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.preferredContentSize = kPopoverContentSize;
        [self addNotificationObserver];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
    [self setupToolbar];
    [self localize];
    [self setupGroup];
}

- (void)dealloc
{
    [self removeNotificationObserver];
}


#pragma mark - Accessors

- (CTAssetsPickerController *)picker
{
    return (CTAssetsPickerController *)self.navigationController;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Setup

- (void)setupViews
{
    self.tableView.rowHeight = kThumbnailLength + 12;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupButtons
{
    if (self.picker.showsCancelButton)
    {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self.picker
                                        action:@selector(dismiss:)];
    }
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self.picker
                                    action:@selector(finishPickingAssets:)];
}

- (void)setupToolbar
{
    self.toolbarItems = self.picker.toolbarItems;
}

- (void)localize
{
    if (!self.picker.title)
        self.title = NSLocalizedString(@"Photos", nil);
    else
        self.title = self.picker.title;
}

- (void)setupGroup
{
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    ALAssetsFilter *assetsFilter = self.picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
            
            BOOL shouldShowGroup;
            
            if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldShowAssetsGroup:)])
                shouldShowGroup = [self.picker.delegate assetsPickerController:self.picker shouldShowAssetsGroup:group];
            else
                shouldShowGroup = YES;

            if (shouldShowGroup)
                [self.groups addObject:group];
        }
        else
        {
            [self reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
    {
        [self showNotAllowed];
    };
    
    // Enumerate Camera roll first
    [self.picker.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                             usingBlock:resultsBlock
                                           failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type =
    ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.picker.assetsLibrary enumerateGroupsWithTypes:type
                                             usingBlock:resultsBlock
                                           failureBlock:failureBlock];
}


#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(assetsLibraryChanged:)
                   name:ALAssetsLibraryChangedNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(selectedAssetsChanged:)
                   name:CTAssetsPickerSelectedAssetsChangedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Assets Library Changed

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    // Reload all groups
    if (notification.userInfo == nil)
        [self performSelectorOnMainThread:@selector(setupGroup) withObject:nil waitUntilDone:NO];
    
    // Reload effected assets groups
    if (notification.userInfo.count > 0)
    {
        [self reloadAssetsGroupForUserInfo:notification.userInfo
                                       key:ALAssetLibraryUpdatedAssetGroupsKey
                                    action:@selector(updateAssetsGroupForURL:)];
        
        [self reloadAssetsGroupForUserInfo:notification.userInfo
                                       key:ALAssetLibraryInsertedAssetGroupsKey
                                    action:@selector(insertAssetsGroupForURL:)];
        
        [self reloadAssetsGroupForUserInfo:notification.userInfo
                                       key:ALAssetLibraryDeletedAssetGroupsKey
                                    action:@selector(deleteAssetsGroupForURL:)];
    }
}


#pragma mark - Reload Assets Group

- (void)reloadAssetsGroupForUserInfo:(NSDictionary *)userInfo key:(NSString *)key action:(SEL)selector
{
    NSSet *URLs = [userInfo objectForKey:key];
    
    for (NSURL *URL in URLs.allObjects)
        [self performSelectorOnMainThread:selector withObject:URL waitUntilDone:NO];
}

- (NSUInteger)indexOfAssetsGroupWithURL:(NSURL *)URL
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ALAssetsGroup *group, NSDictionary *bindings){
        return [[group valueForProperty:ALAssetsGroupPropertyURL] isEqual:URL];
    }];
    
    return [self.groups indexOfObject:[self.groups filteredArrayUsingPredicate:predicate].firstObject];
}

- (void)updateAssetsGroupForURL:(NSURL *)URL
{
    ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group){
        
        NSUInteger index = [self.groups indexOfObject:group];
        
        if (index != NSNotFound)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

            [self.groups replaceObjectAtIndex:index withObject:group];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    };
    
    [self.picker.assetsLibrary groupForURL:URL resultBlock:resultBlock failureBlock:nil];
}

- (void)insertAssetsGroupForURL:(NSURL *)URL
{
    ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.groups.count inSection:0];
        
        [self.tableView beginUpdates];
        
        [self.groups addObject:group];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    };
    
    [self.picker.assetsLibrary groupForURL:URL resultBlock:resultBlock failureBlock:nil];
}

- (void)deleteAssetsGroupForURL:(NSURL *)URL
{
    NSUInteger index = [self indexOfAssetsGroupWithURL:URL];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView beginUpdates];
    
    [self.groups removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}


#pragma mark - Selected Assets Changed

- (void)selectedAssetsChanged:(NSNotification *)notification
{
    NSArray *selectedAssets = (NSArray *)notification.object;
    
    [[self.toolbarItems objectAtIndex:1] setTitle:self.picker.toolbarTitle];
    
    [self.picker setToolbarHidden:(selectedAssets.count == 0) animated:YES];
}


#pragma mark - Reload Data

- (void)reloadData
{
    if (self.groups.count > 0)
        [self.tableView reloadData];
    else
        [self showNoAssets];
}


#pragma mark - Not allowed / No assets

- (void)showNotAllowed
{
    self.title = nil;
    self.tableView.backgroundView = [self.picker notAllowedView];
}

- (void)showNoAssets
{
    self.tableView.backgroundView = [self.picker noAssetsView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CTAssetsGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[CTAssetsGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [cell bind:[self.groups objectAtIndex:indexPath.row]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsViewController *vc = [[CTAssetsViewController alloc] init];
    vc.assetsGroup = [self.groups objectAtIndex:indexPath.row];

    [self.picker pushViewController:vc animated:YES];
}

@end





#pragma mark - CTAssetsGroupViewCell

@implementation CTAssetsGroupViewCell


- (void)bind:(ALAssetsGroup *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;

    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)assetsGroup.numberOfAssets];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *)accessibilityLabel
{
    NSString *label = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    return [label stringByAppendingFormat:NSLocalizedString(@"%ld Photos", nil), (long)self.assetsGroup.numberOfAssets];
}

@end





#pragma mark - CTAssetsViewController

@implementation CTAssetsViewController

NSString * const CTAssetsViewCellIdentifier = @"CTAssetsViewCellIdentifier";
NSString * const CTAssetsSupplementaryViewIdentifier = @"CTAssetsSupplementaryViewIdentifier";

- (id)init
{
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutOfOrientation:self.interfaceOrientation];
    
    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.collectionView.allowsMultipleSelection = YES;
        
        [self.collectionView registerClass:CTAssetsViewCell.class
                forCellWithReuseIdentifier:CTAssetsViewCellIdentifier];
        
        [self.collectionView registerClass:CTAssetsSupplementaryView.class
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:CTAssetsSupplementaryViewIdentifier];

        self.preferredContentSize = kPopoverContentSize;
    }
    
    [self addNotificationObserver];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupToolbar];
    [self setupAssets];
}

- (void)dealloc
{
    [self removeNotificationObserver];
}


#pragma mark - Accessors

- (CTAssetsPickerController *)picker
{
    return (CTAssetsPickerController *)self.navigationController;
}


#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutOfOrientation:toInterfaceOrientation];
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}


#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self.picker
                                    action:@selector(finishPickingAssets:)];
}

- (void)setupToolbar
{
    self.toolbarItems = self.picker.toolbarItems;
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop)
    {
        if (asset)
            [self.assets addObject:asset];
        else
            [self reloadData];
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}


#pragma mark - Collection View Layout

- (UICollectionViewFlowLayout *)collectionViewFlowLayoutOfOrientation:(UIInterfaceOrientation)orientation
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize             = kThumbnailSize;
    layout.footerReferenceSize  = CGSizeMake(0, 44.0);
    
    if (UIInterfaceOrientationIsLandscape(orientation) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 2.0, 0, 2.0);
        layout.minimumInteritemSpacing = 3.0;
        layout.minimumLineSpacing      = 3.0;
    }
    else
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 0, 0, 0);
        layout.minimumInteritemSpacing = 2.0;
        layout.minimumLineSpacing      = 2.0;
    }
    
    return layout;
}


#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(assetsLibraryChanged:)
                   name:ALAssetsLibraryChangedNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(selectedAssetsChanged:)
                   name:CTAssetsPickerSelectedAssetsChangedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Assets Library Changed

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    // Reload all assets
    if (notification.userInfo == nil)
        [self performSelectorOnMainThread:@selector(setupAssets) withObject:nil waitUntilDone:NO];
    
    // Reload effected assets groups
    if (notification.userInfo.count > 0)
        [self reloadAssetsGroupForUserInfo:notification.userInfo];
}


#pragma mark - Reload Assets Group

- (void)reloadAssetsGroupForUserInfo:(NSDictionary *)userInfo
{
    NSSet *URLs = [userInfo objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
    NSURL *URL  = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", URL];
    NSArray *matchedGroups = [URLs.allObjects filteredArrayUsingPredicate:predicate];
    
    // Reload assets if current assets group is updated
    if (matchedGroups.count > 0)
        [self performSelectorOnMainThread:@selector(setupAssets) withObject:nil waitUntilDone:NO];
}



#pragma mark - Selected Assets Changed

- (void)selectedAssetsChanged:(NSNotification *)notification
{
    NSArray *selectedAssets = (NSArray *)notification.object;
    
    [[self.toolbarItems objectAtIndex:1] setTitle:self.picker.toolbarTitle];
    
    [self.picker setToolbarHidden:(selectedAssets.count == 0) animated:YES];
}


#pragma mark - Reload Data

- (void)reloadData
{
    if (self.assets.count > 0)
    {
        [self.collectionView reloadData];

        if (CGPointEqualToPoint(self.collectionView.contentOffset, CGPointZero))
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionViewLayout.collectionViewContentSize.height)];
    }
    else
    {
        [self showNoAssets];
    }
}


#pragma mark - No assets

- (void)showNoAssets
{
    self.collectionView.backgroundView = [self.picker noAssetsView];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:CTAssetsViewCellIdentifier
                                              forIndexPath:indexPath];
    
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)])
        cell.enabled = [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    else
        cell.enabled = YES;
    
    // XXX
    // Setting `selected` property blocks further deselection.
    // Have to call selectItemAtIndexPath too. ( ref: http://stackoverflow.com/a/17812116/1648333 )
    if ([self.picker.selectedAssets containsObject:asset])
    {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    [cell bind:asset];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsSupplementaryView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                       withReuseIdentifier:CTAssetsSupplementaryViewIdentifier
                                              forIndexPath:indexPath];
    
    [view bind:self.assets];
    
    return view;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    CTAssetsViewCell *cell = (CTAssetsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell.isEnabled)
        return NO;
    else if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    [self.picker selectAsset:asset];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];

    [self.picker deselectAsset:asset];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];

    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}


@end





#pragma mark - CTAssetsViewCell

@implementation CTAssetsViewCell

static UIFont *titleFont;
static CGFloat titleHeight;
static UIImage *videoIcon;
static UIColor *titleColor;
static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    videoIcon       = [UIImage imageNamed:@"CTAssetsPickerVideo"];
    titleColor      = [UIColor whiteColor];
    checkedIcon     = [UIImage imageNamed:@"CTAssetsPickerChecked"];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset
{
    self.asset  = asset;
    self.type   = [asset valueForProperty:ALAssetPropertyType];
    self.image  = (asset.thumbnail == NULL) ? [UIImage imageNamed:@"CTAssetsPickerEmpty"] : [UIImage imageWithCGImage:asset.thumbnail];
    
    if ([self.type isEqual:ALAssetTypeVideo])
        self.title = [NSDate timeDescriptionOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}


#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawThumbnailInRect:rect];

    if ([self.type isEqual:ALAssetTypeVideo])
        [self drawVideoMetaInRect:rect];
    
    if (!self.isEnabled)
        [self drawDisabledViewInRect:rect];
    
    else if (self.selected)
        [self drawSelectedViewInRect:rect];
}

- (void)drawThumbnailInRect:(CGRect)rect
{
    [self.image drawInRect:rect];
}

- (void)drawVideoMetaInRect:(CGRect)rect
{
    // Create a gradient from transparent to black
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.8,
        0.0, 0.0, 0.0, 1.0
    };
    
    CGFloat locations [] = {0.0, 0.75, 1.0};
    
    CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGFloat height          = rect.size.height;
    CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - titleHeight);
    CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(baseSpace);
    CGGradientRelease(gradient);
    
    CGSize titleSize = [self.title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
    CGRect titleRect = CGRectMake(rect.size.width - titleSize.width - 2, startPoint.y + (titleHeight - 12) / 2, titleSize.width, titleHeight);
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    titleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.title drawInRect:titleRect
            withAttributes:@{NSFontAttributeName : titleFont,
                             NSForegroundColorAttributeName : titleColor,
                             NSParagraphStyleAttributeName : titleStyle}];
    
    [videoIcon drawAtPoint:CGPointMake(2, startPoint.y + (titleHeight - videoIcon.size.height) / 2)];
}

- (void)drawDisabledViewInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, disabledColor.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawSelectedViewInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, selectedColor.CGColor);
    CGContextFillRect(context, rect);
    
    [checkedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - checkedIcon.size.width, CGRectGetMinY(rect))];
}


#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    
    [labels addObject:[self typeLabel]];
    [labels addObject:[self orientationLabel]];
    [labels addObject:[self dateLabel]];
    
    return [labels componentsJoinedByString:@", "];
}

- (NSString *)typeLabel
{
    NSString *type = [self.asset valueForProperty:ALAssetPropertyType];
    NSString *key  = ([type isEqual:ALAssetTypeVideo]) ? @"Video" : @"Photo";
    return NSLocalizedString(key, nil);
}

- (NSString *)orientationLabel
{
    CGSize dimension = self.asset.defaultRepresentation.dimensions;
    NSString *key    = (dimension.height >= dimension.width) ? @"Portrait" : @"Landscape";
    return NSLocalizedString(key, nil);
}

- (NSString *)dateLabel
{
    NSDate *date = [self.asset valueForProperty:ALAssetPropertyDate];
    
    NSDateFormatter *df             = [[NSDateFormatter alloc] init];
    df.locale                       = [NSLocale currentLocale];
    df.dateStyle                    = NSDateFormatterMediumStyle;
    df.timeStyle                    = NSDateFormatterShortStyle;
    df.doesRelativeDateFormatting   = YES;
    
    return [df stringFromDate:date];
}


@end





#pragma mark - CTAssetsSupplementaryView

@implementation CTAssetsSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _label = [self supplementaryLabel];
        [self addSubview:_label];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }
    
    return self;
}

- (UILabel *)supplementaryLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 8.0, 8.0)];
    label.font = [UIFont systemFontOfSize:18.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    return label;
}

- (void)bind:(NSArray *)assets
{
    NSInteger numberOfVideos = [assets filteredArrayUsingPredicate:[self predicateOfAssetType:ALAssetTypeVideo]].count;
    NSInteger numberOfPhotos = [assets filteredArrayUsingPredicate:[self predicateOfAssetType:ALAssetTypePhoto]].count;
    
    if (numberOfVideos == 0)
        self.label.text = [NSString stringWithFormat:NSLocalizedString(@"%ld Photos", nil), (long)numberOfPhotos];
    else if (numberOfPhotos == 0)
        self.label.text = [NSString stringWithFormat:NSLocalizedString(@"%ld Videos", nil), (long)numberOfVideos];
    else
        self.label.text = [NSString stringWithFormat:NSLocalizedString(@"%ld Photos, %ld Videos", nil), (long)numberOfPhotos, (long)numberOfVideos];
}

- (NSPredicate *)predicateOfAssetType:(NSString *)type
{
    return [NSPredicate predicateWithBlock:^BOOL(ALAsset *asset, NSDictionary *bindings) {
        return [[asset valueForProperty:ALAssetPropertyType] isEqual:type];
    }];
}

@end
