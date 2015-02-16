//
//  YelpMapView.h
//  YelpClient
//
//  Created by Syed Naqvi on 2/15/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMapView.h"

@interface YelpMapView : GMSMapView
@property (nonatomic, copy) NSDictionary *region;
@property (nonatomic, copy) NSArray *businesses;
- (void)reloadData;
@end
