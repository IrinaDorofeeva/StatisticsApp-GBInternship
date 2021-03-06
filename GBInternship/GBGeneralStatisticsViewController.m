//
//  GBGeneralStatisticsViewController.m
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 3/23/17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBGeneralStatisticsViewController.h"
#import "GBPieChartViewController.h"

@interface GBGeneralStatisticsViewController () 
- (IBAction)openCharts:(id)sender;

@end

@implementation GBGeneralStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUI)
                                                 name:@"FetchedSites"
                                               object:nil];
    
    _sitePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
    
    _sitePicker.delegate = self;
    _sitePicker.showsSelectionIndicator = YES;
    _sitePicker.dataSource=self;

    
     _pickedSiteTextField.inputView=[self createPicker];
    
    
    [[GBPersistentManager sharedManager] getArrayOfAvaliableSitesOnSuccess:^(NSArray *sitesArray) {
        _sitesArray =sitesArray;
    } onFailure:^(NSError *error) {
        
    }];
    
    [[GBPersistentManager sharedManager] getArrayOfAvaliablePersonsOnSuccess:^(NSArray *personsArray) {
        _personsArray =personsArray;
    } onFailure:^(NSError *error) {
        
    }];

}

- (void) reloadUI {
    
    [self.ranksTable reloadData];
    [self.sitePicker reloadAllComponents];
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    int count = (int)_sitesArray.count;
    return count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    GBSite* site = (GBSite*) _sitesArray[row];
    NSString* stringInPicker = site.siteURL;
    return stringInPicker;
}



#pragma mark PickerView Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    GBSite* site = (GBSite*) _sitesArray[row];
    NSString *resultString = [[NSString alloc] initWithFormat:
                              @"%@",
                              site.siteURL];
    
    _pickedSiteTextField.text = resultString;
    [_pickedSiteTextField resignFirstResponder];
    
 
    [[GBPersistentManager sharedManager]
     getStatisticBySiteID:site.siteID
     onSuccess:^(NSArray *statisticArray) {
         _statisticArray=statisticArray;
     } onFailure:^(NSError *error) {
    }];
    
     [_ranksTable reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _statisticArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:CellIdentifier];
    }
    
    GBStatistic* statistic = (GBStatistic*) _statisticArray[indexPath.row];
    
    
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@",statistic.persons.personName];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%hd",statistic.rank];
    cell.detailTextLabel.textAlignment=NSTextAlignmentRight;
    return cell;
}


// popover with picker for sites

- (UIView *)createPicker {
    
    UIView *pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216)];
    
    pickerView.backgroundColor = [UIColor whiteColor];
    
    
    [pickerView addSubview: _sitePicker];
    _sitePicker.center = CGPointMake(pickerView.frame.size.width  / 2,
                                     pickerView.frame.size.height / 2);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setBackgroundColor:[UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1]];
    [titleLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 16.0f]];
    titleLabel.text=@"Choose Site";
    titleLabel.textAlignment= NSTextAlignmentCenter;
    [pickerView addSubview:titleLabel];
    
    return pickerView;
}

#pragma mark - Actions -
- (IBAction)openCharts:(id)sender {
    
    if (self.statisticArray.count > 0) {
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GBPieChartViewController* vc = [sb instantiateViewControllerWithIdentifier:@"GBPieChartViewController"];
        NSMutableArray* persons = [NSMutableArray array];
        NSMutableArray* values = [NSMutableArray array];
        
        for (GBStatistic* stat in self.statisticArray) {
            [persons addObject:stat.persons.personName];
            [values addObject:[NSNumber numberWithDouble:stat.rank]];
            vc.siteTitle = stat.sites.siteURL;
        }
        
        vc.persons = persons;
        vc.values = values;
        
      
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
        [self emptyFieldsAlert];
    }
    
    
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}

#pragma mark - Alerts -
- (void) emptyFieldsAlert {
    
    UIAlertController* error =
    [UIAlertController alertControllerWithTitle:@"Oooops"
                                        message:@"You must select source to get statistic or selected site has no data!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"ОК"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [error addAction:okAction];
    [self presentViewController:error animated:YES completion:nil];
}

@end
