/*
*/

#import <UIKit/UIKit.h>

@class DataController;

@interface RootViewController : UITableViewController {
    DataController *dataController;
}

@property (nonatomic, retain) DataController *dataController;

- (void) finishSetup;

@end
