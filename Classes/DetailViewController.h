/*
*/

#import <UIKit/UIkit.h>

@class RootViewController;

@interface DetailViewController : UITableViewController <UIWebViewDelegate> {
	NSDictionary *detailItem;
}

@property (nonatomic, retain) NSDictionary *detailItem;

@end
