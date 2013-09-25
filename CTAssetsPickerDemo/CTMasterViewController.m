
/*
 CTMasterViewController.m
 
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
#import "CTMasterViewController.h"


@interface CTMasterViewController () <UINavigationControllerDelegate, CTAssetsPickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end



@implementation CTMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *clearButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clearAssets:)];
    

    UIBarButtonItem *addButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(pickAssets:)];

    self.navigationItem.leftBarButtonItem = clearButton;
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearAssets:(id)sender
{
    if (self.assets)
    {
        [self.assets removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)pickAssets:(id)sender
{
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];

    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 10;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - Table View

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.dateFormatter stringFromDate:[asset valueForProperty:ALAssetPropertyDate]];
    cell.detailTextLabel.text = [asset valueForProperty:ALAssetPropertyType];
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    return cell;
}


#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[self indexPathOfNewlyAddedAssets:assets]
                          withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.assets addObjectsFromArray:assets];
    [self.tableView endUpdates];
}

- (NSArray *)indexPathOfNewlyAddedAssets:(NSArray *)assets
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (int i = self.assets.count; i < self.assets.count + assets.count ; i++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    
    return indexPaths;
}

@end
