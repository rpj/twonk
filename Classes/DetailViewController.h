/*
*/

#import <UIKit/UIkit.h>

@class RootViewController;


@interface WebViewController : UIViewController <UIWebViewDelegate> {
}

@end

@interface DetailViewController : UITableViewController <UIWebViewDelegate> {
	NSDictionary *detailItem;
	WebViewController *_webViewCtrlr;
}

@property (nonatomic, retain) NSDictionary *detailItem;

@end
