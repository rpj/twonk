/*
*/

#import <UIKit/UIKit.h>

@class DataController;

@interface RootViewController : UITableViewController {
    DataController *dataController;
	UIToolbar *toolbar;
	
	UIBarButtonItem *_refreshButton;
	NSDate *_lastRefresh;
	
	UIImage *_starSelect;
	UIImage *_starUnselect;
	
	BOOL _isBlack;
}

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, assign) UIToolbar *toolbar;
@property (nonatomic, assign) NSString *barText;

- (void) finishSetup;

@end
