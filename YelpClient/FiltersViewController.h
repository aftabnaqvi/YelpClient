//
//  FiltersViewController.h
//  YelpClient
//
//  Created by Syed Naqvi on 2/14/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FiltersViewController;

//our newly defined protocol, should have the same name as a Controller's name with Delegate at the end.
@protocol FiltersViewControllerDelegate <NSObject>
-(void) filtersViewController: (FiltersViewController*)
	filtersViewController didChangeFilters:(NSDictionary*) filters;
@end

@interface FiltersViewController : UIViewController
@property (nonatomic, weak) id<FiltersViewControllerDelegate> delegate; // use generic type but make sure it implements FiltersViewControllerDelegate.
@end
