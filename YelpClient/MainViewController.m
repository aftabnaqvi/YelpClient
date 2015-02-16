//
//  MainViewController.m
//  YelpClient
//
//  Created by Syed Naqvi on 2/10/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "YelpBusinessCell.h"
#import "SVProgressHUD.h"
#import "FiltersViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import <GoogleMaps/GoogleMaps.h>
#import "YelpMapView.h"
/**
 OAuth credential placeholders that must be filled by each user in regards to
 http://www.yelp.com/developers/getting_started/api_access
 */

static NSString * const kYelpConsumerKey       = @"4LMhMHz6JYcEeZI8waVkAg";
static NSString * const kYelpConsumerSecret    = @"_o9kfSvQM_AUcTEuTYBa20yPUEg";
static NSString * const kYelpToken             = @"-W6mM-GlhePwUdLyOsdBmmiowIeejCit";
static NSString * const kYelpTokenSecret       = @"b1RjQ94kz9rj3N7ftHfavmE8aM0";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate>
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL loadingMoreTableViewData;
@property (nonatomic) BOOL isMapVisible;
@property (nonatomic, strong) UIBarButtonItem *mapButton;

-(void)fetchBusinessesWithQuery:(NSString*)query params:(NSDictionary*) params;
@property (weak, nonatomic) IBOutlet YelpMapView *mapView;

@end

@implementation MainViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self){
		self.businesses = [NSMutableArray array];
		// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
		self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
		[self fetchBusinessesWithQuery:@"Resturants" params:nil];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.searchBar.delegate = self;
	
	[self.tableView registerNib:[UINib nibWithNibName:@"YelpBusinessCell" bundle:nil] forCellReuseIdentifier:@"YelpBusinessCell"];
	self.tableView.rowHeight = UITableViewAutomaticDimension; // set the height of the cell using autolayout parameters (constraints, I guess.)
	
	[self customizeNavigationBar];
	
	self.mapView.hidden=true;
}

- (void)addSomeMoreEntriesToTableView {
//	[self fetchBusinessesWithQuery:@"Resturants" params:nil];
//	
////	int loopTill = self.businesses.count + 20;
////	while (self.businesses.count < loopTill) {
////		[self.businesses addObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.businesses.count]];
////	};
//	self.loadingMoreTableViewData = NO;
//	//[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark search
-(void)fetchBusinessesWithQuery:(NSString*)query params:(NSDictionary*) params{
	//[self showSpinner];
	[self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation,id response){
		NSArray *businessDictionaries = response[@"businesses"];
		NSLog(@"%@", response);
		//[self.businesses  addObjectsFromArray:[Business businessWithDictionaries:businessDictionaries]];
		self.businesses  = [Business businessWithDictionaries:businessDictionaries];
		
		// passing data in mapView. Find a better way though
		self.mapView.region = response[@"region"];
		self.mapView.businesses = self.businesses;
		[self.mapView reloadData];
		
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	}failure:^(AFHTTPRequestOperation *operation, NSError *error){
		NSLog(@"error: %@", [error description]);
		[SVProgressHUD showErrorWithStatus:@"Please try again."];
	}];
	
}

//search button was tapped
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

	[searchBar resignFirstResponder];
	[self fetchBusinessesWithQuery:searchBar.text params:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	if ([searchText length] == 0) {
		[self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
		[self fetchBusinessesWithQuery:searchBar.text params:nil];
	}
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}

#pragma mark UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSLog(@"row count: %ld", (unsigned long)self.businesses.count);
	return self.businesses.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	YelpBusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YelpBusinessCell"];
	cell.business = self.businesses[indexPath.row];
	
	
	// User has scrolled to the bottom of the list of available data so simulate loading some more if we aren't already
	if (!self.loadingMoreTableViewData) {
		self.loadingMoreTableViewData = YES;
		[self performSelector:@selector(addSomeMoreEntriesToTableView) withObject:nil afterDelay:5.0f];
	}
	
	
	return cell;
}

// following methos helps rows to maintain the constrains when vsisble again from dissmissing another
// view or change the rotation...
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	YelpBusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YelpBusinessCell"];
	cell.business = self.businesses[indexPath.row];
	CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
	return size.height + 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark Navigation bar customization private
-(void) customizeNavigationBar{
	self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(self.navigationItem.titleView.frame.origin.x,
																				 self.navigationItem.titleView.frame.origin.y,
																				 self.navigationItem.titleView.frame.size.width,
																				 self.navigationItem.titleView.frame.size.height)];
	self.searchBar.tintColor = [UIColor redColor];
	[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
	self.navigationItem.titleView = self.searchBar;
	
	UIBarButtonItem *filterBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
	self.navigationItem.leftBarButtonItem = filterBarItem;
	
	self.mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
	self.navigationItem.rightBarButtonItem = self.mapButton;
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

-(void) onFilterButton{
	FiltersViewController *fvc = [[FiltersViewController alloc] init];
	fvc.delegate = self;
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
	[self presentViewController:nvc animated:YES completion:nil];
}

-(void) onMapButton{
	if (self.isMapVisible) {
		// flip back to the list
		[UIView transitionFromView:self.mapView
							toView:self.tableView
						  duration:1.0
						   options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews
						completion:nil];
		self.mapButton.title = @"Map";
		self.isMapVisible = NO;
	} else {
		// flip to the map
		[UIView transitionFromView:self.tableView
							toView:self.mapView
						  duration:1.0
						   options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionShowHideTransitionViews
						completion:nil];
		self.mapButton.title = @"List";
		self.isMapVisible = YES;
	}
}

#pragma mark - private methods
-(void) filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters{
	// fire a network event.
	NSLog(@"fire now network event: %@", filters);
	[self showSpinner];
	[self fetchBusinessesWithQuery:@"Resturants" params:filters];
}

-(void) showSpinner{
	[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
	[SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeNone];
	[SVProgressHUD setBackgroundColor:[UIColor redColor]];
}

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler{
	
}
@end
