//
//  Business.m
//  YelpClient
//
//  Created by Syed Naqvi on 2/11/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "Business.h"

@implementation Business
-(id)initWithDictionary:(NSDictionary * )dictionary{
	self = [super init];
	if(self){
		NSArray *categories = dictionary[@"categories"];
		NSMutableArray *categoryNames = [NSMutableArray array];
		[categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[categoryNames addObject:obj[0]];
		}];
		self.categories = [categoryNames componentsJoinedByString:@", "];
		self.name = dictionary[@"name"];
		self.imageUrl = dictionary[@"image_url"];
		NSArray *streetArr = [dictionary valueForKeyPath:@"location.address"];
		NSString *street = nil;
		if (streetArr.count > 0) {
			street = streetArr[0];
		}
		NSString *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
		self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
		
		self.reviewCount = [dictionary[@"review_count"] integerValue];
		self.ratingImageUrl = dictionary[@"rating_img_url"];
		float milesPerMeter = 0.000621371f;
		self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
	}
	
	return self;
}

+ (NSArray*) businessWithDictionaries:(NSArray *)dictionaries{
	NSMutableArray *businesses = [NSMutableArray array];
	for(NSDictionary *dictionary in dictionaries){
		Business * business = [[Business alloc] initWithDictionary:dictionary];
		[businesses addObject:business];
	}
	
	return businesses;
}
@end
