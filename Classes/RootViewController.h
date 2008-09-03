/*
*/

#import <UIKit/UIKit.h>

@class DataController;

@interface RootViewController : UITableViewController {
    DataController *dataController;
	
	UIBarButtonItem *_refreshButton;
	NSDate *_lastRefresh;
	
	UIImage *_starSelect;
	UIImage *_starUnselect;
}

@property (nonatomic, retain) DataController *dataController;

- (void) finishSetup;

@end
