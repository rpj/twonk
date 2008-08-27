//
//  TwitterCell.h
//  SimpleDrillDown
//
//  Created by Ryan Joseph on 8/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TwitterCell : UITableViewCell {
	NSDictionary* _infoDict;
}

@property (nonatomic, retain) NSDictionary* info;

@end;
