//
//  Business.h
//  YelpClient
//
//  Created by Syed Naqvi on 2/11/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Business : NSObject
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ratingImageUrl;
@property (nonatomic, assign) NSInteger reviewCount;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;

+ (NSMutableArray*) businessWithDictionaries:(NSArray *)dictionaries;

@end
