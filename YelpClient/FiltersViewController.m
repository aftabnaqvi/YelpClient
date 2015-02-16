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
@property (nonatomic, strong) NSMutableArray      *sectionStatusArray;
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
		
		NSNumber* noObject = [NSNumber numberWithBool:NO];
		
		// currently, we have section of filters so far. We may need to add more.
		self.sectionStatusArray = [[NSMutableArray alloc] initWithObjects:
							   noObject, noObject, noObject, noObject, nil];
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
	
	data = [self loadFilterForKey:@"selectedDeal"];
	if(data != nil){
		self.selectedDeal = data;
	}
	
	data = [self loadFilterForKey:@"selectedSortCriteria"];
	if(data != nil){
		self.selectedSortCriteria = data;
	}
	
    // Do any additional setup after loading the view from its nib.
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:(UIBarButtonItemStylePlain) target:self action:@selector(onCancelButton)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:(UIBarButtonItemStylePlain) target:self action:@selector(onApplyButton)];
	
	[self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
	[self.tableView addGestureRecognizer:tap];
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

-(void) onApplyButton {
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
//	UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
//	[headerView addGestureRecognizer:headerTapped];
	
	return [self.filters.filterKeys objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSString *key = [self.filters.filterKeys objectAtIndex:section];
	if ([[self.sectionStatusArray objectAtIndex:section] boolValue]) {
			return [[self.filters.filterContents objectForKey:key] count];
	}
	
	return 1;//[[self.filters.filterContents objectForKey:key] count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//	SwitchCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
//	cell.delegate = self;
//	cell.titleLabel.text = self.categories[indexPath.row] [@"name"];
//	cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
//	return cell;
	
	SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
	
	NSString *key = [self.filters.filterKeys objectAtIndex:[indexPath section]];
	NSArray *contents = [self.filters.filterContents objectForKey:key];

	cell.delegate = self;

	NSString* selectedFilter;
	NSString* incomingFilter = [[contents objectAtIndex:indexPath.row] objectForKey:@"name"];
	
	if ([key isEqualToString:@"Sort By"]) {
		selectedFilter = [self.selectedSortCriteria objectForKey:@"name"];
	}

	if ([key isEqualToString:@"Deals"]) {
		selectedFilter = [self.selectedDeal objectForKey:@"name"];
	}
	
	if ([key isEqualToString:@"Distance"]) {
		selectedFilter = [self.selectedRadius objectForKey:@"name"];
	}
	
	cell.on = [selectedFilter isEqualToString:incomingFilter] ? YES : NO;
	
	// categories are bit different.... deal them separatly...
	if ([key isEqualToString:@"Categories"]) {
		cell.on = [self.selectedCategories containsObject:[contents objectAtIndex:[indexPath row]]];
	}
	
	cell.titleLabel.text = contents[indexPath.row][@"name"];
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
	//[tableView deselectRowAtIndexPath:indexPath animated:NO];
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
	
	if ([key isEqualToString:@"Distance"]) {
		if(value){
			self.selectedRadius = [contents objectAtIndex:indexPath.row];
		} else {
			self.selectedRadius = [NSDictionary dictionary];
		}
	}
	[self.tableView reloadData];
}

#pragma mark - gesture tapped

- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
	CGPoint tapLocation = [gestureRecognizer locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
	if (indexPath.row == 0) {
		gestureRecognizer.cancelsTouchesInView = NO;
		NSLog(@" section index - %ld ", indexPath.section);
		BOOL collapsed  = [[self.sectionStatusArray	objectAtIndex:indexPath.section] boolValue];
		collapsed       = !collapsed;
		[self.sectionStatusArray replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
		
		//reload specific section animated
		NSRange range   = NSMakeRange(indexPath.section, 1);
		NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
		[self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
	}
}

@end
