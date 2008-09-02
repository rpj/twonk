/*
*/

#import <UIKit/UIkit.h>

@class RootViewController;


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	NSURL *_url;
	BOOL _refreshUp;
}

@end

@interface DetailViewController : UITableViewController <UIWebViewDelegate> {
	NSDictionary *detailItem;
	WebViewController *_webViewCtrlr;
}

@property (nonatomic, retain) NSDictionary *detailItem;

@end
