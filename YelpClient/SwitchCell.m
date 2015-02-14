//
//  SwitchCell.m
//  YelpClient
//
//  Created by Syed Naqvi on 2/14/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "SwitchCell.h"
@interface SwitchCell()
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
- (IBAction)switchValueChanged:(id)sender;

@end

@implementation SwitchCell

- (void)awakeFromNib {
    // Initialization code
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setOn:(BOOL)on{
	[self.toggleSwitch setOn:on animated:NO];
}

-(void) setOn:(BOOL)on animated:(BOOL)animated{
	_on = on;
	[self.toggleSwitch setOn:on animated:animated];
}

- (IBAction)switchValueChanged:(id)sender {
	// assign toggle switch value.
	[self.delegate switchCell:self didUpdateValue:self.toggleSwitch.on];;
}
@end
