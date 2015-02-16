//
//  FiltersViewController.m
//  YelpClient
//
//  Created by Syed Naqvi on 2/14/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "Filters.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelgate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,readonly) NSDictionary* selectedFilters;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSDictionary *selectedSortCriteria;
@property (nonatomic, strong) NSDictionary *selectedDeal;
@property (nonatomic, strong) NSDictionary *selectedRadius;
@property (nonatomic, strong) Filters *filters;
@property(nonatomic, strong) NSMutableDictionary *sectionExpandStatus;

- (BOOL)isSectionExpanded:(NSInteger)section;
- (void)expandSection:(NSInteger)section;
- (void)collapseSection:(NSInteger)section withRow: (NSInteger) row;

@end

@implementation FiltersViewController

// initializer...
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil			{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self){
		self.selectedCategories = [NSMutableSet set];
		self.filters = [[Filters alloc] initFilters];
		self.selectedRadius = [NSDictionary dictionary];
		self.selectedDeal = [NSDictionary dictionary];
		self.selectedSortCriteria = [NSDictionary dictionary];
		
		self.sectionExpandStatus = [NSMutableDictionary dictionary];
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	id data = [self loadFilterForKey:@"selectedCategories"];
	if(data != nil){
		self.selectedCategories = data;
	}
	
	data = [self loadFilterForKey:@"selectedRadius"];
	if(data != nil){
		self.selectedRadius = data;
	}
	else{
		self.selectedRadius = [self.filters.filterContents objectForKey:@"Radius"][0];
	}
	
	data = [self loadFilterForKey:@"selectedDeal"];
	if(data != nil){
		self.selectedDeal = data;
	}
	
	data = [self loadFilterForKey:@"selectedSortCriteria"];
	if(data != nil){
		self.selectedSortCriteria = data;
	} else {
		NSLog(@"%@", [self.filters.filterContents objectForKey:@"Sort By"]);
		self.selectedSortCriteria = [self.filters.filterContents objectForKey:@"Sort By"][0];
	}
	
	// Do any additional setup after loading the view from its nib.
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:(UIBarButtonItemStylePlain) target:self action:@selector(onCancelButton)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:(UIBarButtonItemStylePlain) target:self action:@selector(onApplySearch)];
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.barTintColor = [UIColor redColor];
	
	[self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DefaultCell"];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark private methods

// creating filters for search. its a dictionary
// 1- category_filter comma separeated codes...
-(NSDictionary*) selectedFilters{
	NSMutableDictionary* filters = [NSMutableDictionary dictionary];
	
	if([self.selectedSortCriteria count] > 0){
		[filters setObject:[self.selectedSortCriteria objectForKey:@"code"] forKey:@"sort"];
		NSLog(@" selectedSortCriteria  %@", self.selectedSortCriteria);
	}
	
	if([self.selectedRadius count] > 0){
		[filters setObject:[self.selectedRadius objectForKey:@"code"] forKey:@"radius_filter"];
	}
	
	if([self.selectedDeal count] > 0){
		[filters setObject:[self.selectedDeal objectForKey:@"code"] forKey:@"deals_filter"];
		NSLog(@" selectedDeal  %@", self.selectedDeal);
	}
	
	if(self.selectedCategories.count > 0){
		NSMutableArray *names = [NSMutableArray array];
		for(NSDictionary *category in self.selectedCategories){
			[names addObject:category[@"code"]];
		}
		NSString *categoryFilter = [names componentsJoinedByString:@","];
		[filters setObject:categoryFilter forKey:@"category_filter"];
	}
	
	return filters;
}

-(void) onCancelButton {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onApplySearch {
	[self.delegate filtersViewController:self didChangeFilters:self.selectedFilters];
	[self storeFilter:self.selectedCategories forKey:@"selectedCategories"];
	[self storeFilter:self.selectedRadius forKey:@"selectedRadius"];
	[self storeFilter:self.selectedDeal forKey:@"selectedDeal"];
	[self storeFilter:self.selectedSortCriteria forKey:@"selectedSortCriteria"];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void) storeFilter:(id) filter forKey:(NSString*) forKey{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:filter];
	[defaults setObject:data forKey:forKey];
}

-(id) loadFilterForKey:(NSString*) forKey{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:forKey];
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark TableView methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.filters.filterKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.filters.filterKeys objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSString *key = [self.filters.filterKeys objectAtIndex:section];
	NSInteger expandedSectionCount = [[self.filters.filterContents objectForKey:key] count];
	
	if ([key isEqualToString:@"Categories"]) {
		if ([self isSectionExpanded:section]) {
			return expandedSectionCount;
		} else {
			return self.filters.filterKeys.count + 1;
			//return knumRowsForCategories+1;
		}
	}
	
	if ([self isSectionExpanded:section]) {
		return expandedSectionCount;
	} else {
		return 1;
	}
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
	NSString *key = [self.filters.filterKeys objectAtIndex:[indexPath section]];
	NSArray *contents = [self.filters.filterContents objectForKey:key];
	
	cell.delegate = self;
	
	NSString* selectedFilter;
	NSString* incomingFilter = [[contents objectAtIndex:indexPath.row] objectForKey:@"name"];
	
	cell.titleLabel.text = contents[indexPath.row][@"name"];
	if ([key isEqualToString:@"Sort By"]) {
		selectedFilter = [self.selectedSortCriteria objectForKey:@"name"];
		cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
		if ([self isSectionExpanded:indexPath.section]) {
			cell.textLabel.text = contents[indexPath.row][@"name"];
			if ([selectedFilter isEqualToString:cell.textLabel.text]) {
				cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick1.ico"]];
				//cell.accessoryType = UITableViewCellAccessoryCheckmark;
				return cell;
			}
			else {
				cell.accessoryView = nil;
				return cell;
			}
			
		} else {
			cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-16.png"]];
			
			cell.textLabel.text = [self.selectedSortCriteria objectForKey:@"name"];
			return cell;
		}
	}
	
	if ([key isEqualToString:@"Deals"]) {
		selectedFilter = [self.selectedDeal objectForKey:@"name"];
		cell.on = [selectedFilter isEqualToString:incomingFilter] ? YES : NO;
		cell.titleLabel.text = contents[indexPath.row][@"name"];
		return cell;
	}
	
	if ([key isEqualToString:@"Radius"]) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
		selectedFilter = [self.selectedRadius objectForKey:@"name"];
		if ([self isSectionExpanded:indexPath.section]) {
			cell.textLabel.text = contents[indexPath.row][@"name"];
			if ([selectedFilter isEqualToString:cell.textLabel.text]) {
				cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick1.ico"]];
				//cell.accessoryType = UITableViewCellAccessoryCheckmark;
				return cell;
			}
			else {
				cell.accessoryView = nil;
				return cell;
			}
			
		} else {
			cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-16.png"]];
			
			cell.textLabel.text = [self.selectedRadius objectForKey:@"name"];
			return cell;
		}
	}
	
	// categories are bit different.... deal them separatly...
	if ([key isEqualToString:@"Categories"]) {
		if (indexPath.row == self.filters.filterKeys.count && ![self isSectionExpanded:indexPath.section] ) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
			cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cell Expander"]];
			cell.textLabel.text = @"Show all Categories";
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			//cell.textLabel.text = contents[indexPath.row][@"name"];
			return cell;
		} else {
			cell.on = [self.selectedCategories containsObject:[contents objectAtIndex:[indexPath row]]];
			cell.titleLabel.text = contents[indexPath.row][@"name"];
			return cell;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
	// Background color
	view.tintColor = [UIColor grayColor];
	
	// Text Color
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	[header.textLabel setTextColor:[UIColor whiteColor]];
	
	// Another way to set the background color
	// Note: does not preserve gradient effect of original header
	//header.contentView.backgroundColor = [UIColor blackColor];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
	switch (indexPath.section) {
			
		case 0:
		case 2:
			if ([self isSectionExpanded:section]) {
				[self collapseSection:section withRow:row];
			} else {
				[self expandSection:section];
			}
			break;
		case 3:
			if (row == self.filters.filterKeys.count && ![self isSectionExpanded:section]) {
				[self expandSection:section];
			}
			break;
			
		default:
			break;
	}
}

-(void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	NSString *key = [self.filters.filterKeys objectAtIndex:[indexPath section]];
	NSArray *contents = [self.filters.filterContents objectForKey:key];
	
	if ([key isEqualToString:@"Sort By"]) {
		if (value) {
			self.selectedSortCriteria = [contents objectAtIndex:[indexPath row]];
			NSLog(@"selected sort looks like %@", self.selectedSortCriteria);
		} else {
			self.selectedSortCriteria = [NSDictionary dictionary];
		}
		
		NSLog(@"selected sort looks like %@", self.selectedSortCriteria);
	}
	
	if ([key isEqualToString:@"Categories"]) {
		if(value){
			[self.selectedCategories addObject:[contents objectAtIndex:indexPath.row]];
		} else {
			[self.selectedCategories removeObject:[contents objectAtIndex:indexPath.row]];
		}
	}
	
	if ([key isEqualToString:@"Deals"]) {
		if(value){
			self.selectedDeal = [contents objectAtIndex:indexPath.row];
		} else {
			self.selectedDeal = [NSDictionary dictionary];
		}
	}
	
	if ([key isEqualToString:@"Radius"]) {
		if(value){
			self.selectedRadius = [contents objectAtIndex:indexPath.row];
		} else {
			self.selectedRadius = [NSDictionary dictionary];
		}
	}
	[self.tableView reloadData];
}

#pragma mark expand/collapse
- (BOOL)isSectionExpanded:(NSInteger)section {
	return [self.sectionExpandStatus[@(section)] boolValue];
}

- (void)expandSection:(NSInteger)section {
	self.sectionExpandStatus[@(section)] = @YES;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)collapseSection:(NSInteger)section withRow: (NSInteger) row {
	NSString *key = [self.filters.filterKeys objectAtIndex:section]; // key is our title
	NSArray *contents = [self.filters.filterContents objectForKey:key];
	
	switch (section) {
		case 0:
			self.selectedRadius = [NSDictionary dictionary];
			self.selectedRadius = [contents objectAtIndex:row];
			break;
			
		case 2:
			self.selectedSortCriteria = [NSDictionary dictionary];
			self.selectedSortCriteria = [contents objectAtIndex:row];
			break;
			
		default:
			break;
	}
	
	self.sectionExpandStatus[@(section)] = @NO;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
