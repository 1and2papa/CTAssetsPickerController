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

#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "CTMasterViewController.h"

#import "CTBasicViewController.h"
#import "CTMaxSelectionViewController.h"
#import "CTSelectedAssetsViewController.h"
#import "CTDefaultAlbumViewController.h"
#import "CTSelectionOrderViewController.h"
#import "CTUITweaksViewController.h"

#import "CTSortedAssetsViewController.h"

#import "CTPhotosViewController.h"
#import "CTLastWeekViewController.h"
#import "CTSloMoViewController.h"
#import "CTiCloudAlbumsViewController.h"

#import "CTProgrammaticViewController.h"

#import "CTApperanceViewController.h"

#import "CTLayoutViewController.h"




@implementation CTMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"CTAssetsPickerDemo";
    self.tableView.rowHeight = 60;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 6;
            break;

        case 1:
            return 1;
            break;
        
        case 2:
            return 4;
            break;

        case 3:
            return 1;
            break;
            
        case 4:
            return 1;
            break;
            
        case 5:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Basic";
            break;
            
        case 1:
            return @"Sorting";
            break;
            
        case 2:
            return @"Filtering";
            break;
            
        case 3:
            return @"Programmatic";
            break;
            
        case 4:
            return @"Apperance";
            break;
            
        case 5:
            return @"CollectionView Layout (Experimental)";
            break;
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section   = indexPath.section;
    NSInteger row       = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *title;
    
    if (section == 0)
    {
        if (row == 0)
            title = @"Simple uses";
        
        if (row == 1)
            title = @"Maximum selection";

        if (row == 2)
            title = @"Keep selected assets";

        if (row == 3)
            title = @"Show Camera Roll first";
        
        if (row == 4)
            title = @"Show selection order";
        
        if (row == 5)
            title = @"UI tweaks";
    }
    
    if (section == 1)
    {
        if (row == 0)
            title = @"Lastest assets on top";
    }
    
    if (section == 2)
    {
        if (row == 0)
            title = @"Photos only";
        
        if (row == 1)
            title = @"Assetes taken in last week";

        if (row == 2)
            title = @"Slo-mo videos, hide empty albums";
        
        if (row == 3)
            title = @"iCloud albums, sorted by no. of assets";
    }
    
    if (section == 3)
    {
        if (row == 0)
            title = @"Programmatically de/select assets";
    }
    
    if (section == 4)
    {
        if (row == 0)
            title = @"UI customisation";
    }
    
    if (section == 5)
    {
        if (row == 0)
            title = @"Grid view layout customisation";
    }
    
    
    cell.textLabel.text = title;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section   = indexPath.section;
    NSInteger row       = indexPath.row;
    
    UIViewController *vc;
    
    if (section == 0)
    {
        if (row == 0)
            vc = (UIViewController *)[CTBasicViewController new];
        
        if (row == 1)
            vc = (UIViewController *)[CTMaxSelectionViewController new];
        
        if (row == 2)
            vc = (UIViewController *)[CTSelectedAssetsViewController new];
        
        if (row == 3)
            vc = (UIViewController *)[CTDefaultAlbumViewController new];
        
        if (row == 4)
            vc = (UIViewController *)[CTSelectionOrderViewController new];
        
        if (row == 5)
            vc = (UIViewController *)[CTUITweaksViewController new];
    }
    
    if (section == 1)
    {
        if (row == 0)
            vc = (UIViewController *)[CTSortedAssetsViewController new];
    }
    
    if (section == 2)
    {
        if (row == 0)
            vc = (UIViewController *)[CTPhotosViewController new];
        
        if (row == 1)
            vc = (UIViewController *)[CTLastWeekViewController new];
        
        if (row == 2)
            vc = (UIViewController *)[CTSloMoViewController new];
        
        if (row == 3)
            vc = (UIViewController *)[CTiCloudAlbumsViewController new];
    }
    
    if (section == 3)
    {
        if (row == 0)
            vc = (UIViewController *)[CTProgrammaticViewController new];
    }
    
    if (section == 4)
    {
        if (row == 0)
            vc = (UIViewController *)[CTApperanceViewController new];
    }

    if (section == 5)
    {
        if (row == 0)
            vc = (UIViewController *)[CTLayoutViewController new];
    }
    
    if (vc)
        [self.navigationController pushViewController:vc animated:YES];
}


@end
