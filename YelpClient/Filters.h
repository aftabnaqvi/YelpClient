//
//  Filters.h
//  YelpClient
//
//  Created by Syed Naqvi on 2/14/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filters : NSObject

@property (nonatomic, strong) NSMutableArray *filterKeys;
@property (nonatomic, strong) NSMutableDictionary *filterContents;

- (id) initFilters;

@end
