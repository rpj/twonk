/*
*/

#import <UIKit/UIkit.h>

@class RootViewController;

@interface DetailViewController : UITableViewController <UIWebViewDelegate> {
	NSDictionary *detailItem;
	UIViewController *_webViewCtrlr;
}

@property (nonatomic, retain) NSDictionary *detailItem;

@end
