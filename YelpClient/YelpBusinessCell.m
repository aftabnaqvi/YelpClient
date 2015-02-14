//
//  YelpCell.m
//  YelpClient
//
//  Created by Syed Naqvi on 2/10/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "YelpBusinessCell.h"
#import "UIImageView+AFNetworking.h"

@interface YelpBusinessCell()
@property (weak, nonatomic) IBOutlet UIImageView	*thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel		*nameLabel;
@property (weak, nonatomic) IBOutlet UILabel		*distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView	*ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel		*ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel		*dollarLabel;
@property (weak, nonatomic) IBOutlet UILabel		*addressLabel;
@property (weak, nonatomic) IBOutlet UILabel		*categoryLabel;
@end

@implementation YelpBusinessCell

- (void)awakeFromNib {
    // Initialization code
	// sometime name label doesn't render properly. We need to set this property and
	// override layoutSubViews
	self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
	self.categoryLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
	
	self.thumbImageView.layer.cornerRadius = 3;
	self.thumbImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

-(void) setBusiness:(Business *)business{
	_business = business;
	[self.thumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: self.business.imageUrl]]
						   placeholderImage:nil
									success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
										[self.thumbImageView setImage:image];
									}
									failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
										NSLog(@"failed loading: %@", error);
									}
	 ];
	[self.ratingImageView setImageWithURL:[NSURL URLWithString:self.business.ratingImageUrl]];
	self.nameLabel.text = self.business.name;
	self.ratingLabel.text = [NSString stringWithFormat:@"%ld Reviews", (long)self.business.reviewCount ];
	self.addressLabel.text = self.business.address;
	self.categoryLabel.text = self.business.categories;
	self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.business.distance];
}

// sometime name label doesn't render properly. We need to set this property and
// override layoutSubViews
-(void) layoutSubviews{
	[super layoutSubviews];
	self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}
@end
