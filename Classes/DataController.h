/*
*/

#import <UIKit/UIKit.h>

#import "MGTwitterEngine.h"


#define kDataControllerUpdatedData		@"DataControllerUpdatedData"
#define kDataControllerTwitterError		@"DataControllerTwitterError"


@interface DataController : NSObject <MGTwitterEngineDelegate, UIApplicationDelegate> {
	MGTwitterEngine* _twitter;
	NSString* _lastReqID;
	int _lastUpdateID;
	BOOL _validUser;
	NSMutableDictionary *_imgTrack;
	NSInteger _lastRateLimitRemaining;
    NSMutableArray *list;
}

@property (nonatomic, retain) NSString* lastReqID;
@property (nonatomic, readonly) NSInteger requestsRemaining;

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;

- (void) reloadWithStandardUserInfo;
- (void) refreshFriendsTimeline;

- (void) addImageToCell:(UITableViewCell*)cell fromURL:(NSString*)url;
@end
