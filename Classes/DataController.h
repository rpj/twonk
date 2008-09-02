/*
*/

#import <UIKit/UIKit.h>

#import "MGTwitterEngine.h"


#define kDataControllerUpdatedData		@"kDataControllerUpdatedData"


@interface DataController : NSObject <MGTwitterEngineDelegate, UIApplicationDelegate> {
	MGTwitterEngine* _twitter;
	NSString* _lastReqID;
	int _lastUpdateID;
	BOOL _validUser;
    NSMutableArray *list;
}

@property (nonatomic, retain) NSString* lastReqID;

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;

- (void) reloadWithStandardUserInfo;
- (void) refreshFriendsTimeline;
@end
