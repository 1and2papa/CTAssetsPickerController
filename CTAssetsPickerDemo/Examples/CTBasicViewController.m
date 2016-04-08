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

#import "CTBasicViewController.h"
#import "PHImageManager+CTAssetsPickerController.h"


#define tableViewRowHeight 80.0f


@implementation CTBasicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *clearButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clearAssets:)];
    
    
    UIBarButtonItem *addButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Pick", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(pickAssets:)];
    
    UIBarButtonItem *space =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[clearButton, space, addButton];
    self.tableView.rowHeight = tableViewRowHeight;
    
    
    
    // init properties
    self.assets = [[NSMutableArray alloc] init];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)clearAssets:(id)sender
{
    self.assets = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

- (void)pickAssets:(id)sender
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{

            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];

        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];

    PHAsset *asset = [self.assets objectAtIndex:indexPath.row];
    cell.textLabel.text         = [self.dateFormatter stringFromDate:asset.creationDate];
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld X %ld", (long)asset.pixelWidth, (long)asset.pixelHeight];
    cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    cell.clipsToBounds          = YES;

    PHImageManager *manager = [PHImageManager defaultManager];
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize targetSize = CGSizeMake(tableViewRowHeight * scale, tableViewRowHeight * scale);

    [manager ctassetsPickerRequestImageForAsset:asset
                       targetSize:targetSize
                      contentMode:PHImageContentModeAspectFill
                          options:self.requestOptions
                    resultHandler:^(UIImage *image, NSDictionary *info){
                            cell.imageView.image = image;
                            [cell setNeedsLayout];
                            [cell layoutIfNeeded];
                    }];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:self.assets];
    vc.pageIndex = indexPath.row;

    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}

@end
