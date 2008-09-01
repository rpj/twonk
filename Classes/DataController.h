/*
*/

#import <UIKit/UIKit.h>

#import "MGTwitterEngine.h"


#define kDataControllerUpdatedData		@"kDataControllerUpdatedData"


@interface DataController : NSObject <MGTwitterEngineDelegate> {
	MGTwitterEngine* _twitter;
	NSString* _lastReqID;
	int _lastUpdateID;
	BOOL _validUser;
    NSMutableArray *list;
}

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;

- (void) reloadWithUsername:(NSString*)uname andPassword:(NSString*)pass;
- (void) reloadWithStandardUserInfo;
@end
