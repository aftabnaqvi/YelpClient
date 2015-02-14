//
//  SwitchCell.h
//  YelpClient
//
//  Created by Syed Naqvi on 2/14/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SwitchCell;

@protocol SwitchCellDelgate <NSObject>

-(void) switchCell:(SwitchCell*) cell didUpdateValue:(BOOL)value;

@end

//Exposing title, and switch button properties/methods.
// you can configure the appearence the switch button.
@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<SwitchCellDelgate> delegate;
-(void) setOn:(BOOL)on animated:(BOOL)animated;

@end
