/*
*/

#import <UIKit/UIKit.h>

@class DataController;

@interface RootViewController : UITableViewController {
    DataController *dataController;
	NSMutableDictionary *heights;
}

@property (nonatomic, retain) DataController *dataController;

- (void) finishSetup;

@end
