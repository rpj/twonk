//
//  TwitterCell.m
//  SimpleDrillDown
//
//  Created by Ryan Joseph on 8/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TwitterCell.h"


@implementation TwitterCell

@synthesize info = _infoDict;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}


- (void)dealloc {
	[super dealloc];
}


@end
