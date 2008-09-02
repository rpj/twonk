/*
Derieved directly form DataController.m in Apple's "DrillDown" sample project
*/

#import "DataController.h"

#define TWEET_NUM	50

@implementation DataController

@synthesize lastReqID = _lastReqID;

- (void)requestSucceeded:(NSString *)requestIdentifier;
{
	if ([requestIdentifier isEqualToString:_lastReqID]) {
		if (!_validUser) {
			_validUser = YES;
			self.lastReqID = [_twitter getFollowedTimelineFor:nil since:nil startingAtPage:0 count:TWEET_NUM];
		}
	}
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error;
{
	UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Twitter Request Failed" 
													message:[[error localizedDescription] copy]
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:@"Well, can't do much!", nil];
	[aView show];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier;
{
	NSAutoreleasePool *tPool = [[NSAutoreleasePool alloc] init];
	
	if ([identifier isEqualToString:_lastReqID] && [statuses count]) {
		if (_lastUpdateID == -1) {
			[list release];
			list = [[NSMutableArray arrayWithArray:statuses] retain];
		}
		else {
			NSMutableArray *newList = [NSMutableArray arrayWithArray:statuses];
			[newList addObjectsFromArray:list];
			[list release];
			list = [newList retain];
		}
		
		_lastUpdateID = [(NSNumber*)[(NSDictionary*)[statuses objectAtIndex:0] objectForKey:@"id"] intValue];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataControllerUpdatedData object:self userInfo:nil];
	[tPool release];
}


- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier;
{
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier;
{
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier;
{
}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)identifier;
{
}



- (void) _reloadWithUsername:(NSString*)uname andPassword:(NSString*)pass;
{
	if (uname && pass) {
		_validUser = NO;
		_lastUpdateID = -1;
		
		NSAutoreleasePool *tPool = [[NSAutoreleasePool alloc] init];
		[_twitter release];
		_twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
		[_twitter setUsername:uname password:pass];
		self.lastReqID = [_twitter checkUserCredentials];
		[tPool release];
	}
}

- (void) refreshFriendsTimeline;
{
	NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];

	// XXX: correlating a member variable and a user default entry could get hairy, we should be careful...
	if (user)
		self.lastReqID = [_twitter getFollowedTimelineFor:user sinceID:_lastUpdateID startingAtPage:0 count:TWEET_NUM];
}

- (void) reloadWithStandardUserInfo;
{
	[self _reloadWithUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]
				 andPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
}


- (id)init {
    if (self = [super init]) {
		NSString *uname = nil;
		NSString *pass = nil;
		
		if ((uname = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]) &&
			(pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"]))
			[self _reloadWithUsername:uname andPassword:pass];
    }
    return self;
}

// Custom set accessor to ensure the new list is mutable
- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        [list release];
        list = [newList mutableCopy];
    }
}

// Accessor methods for list
- (unsigned)countOfList {
    return [list count];
}

- (id)objectInListAtIndex:(unsigned)theIndex {
    return (theIndex < [list count] ? [list objectAtIndex:theIndex] : nil);
}


- (void) memoryWarning;
{
	[list release];
	list = [[NSMutableArray array] retain];
}

- (void)dealloc {
    [list release];
	[_twitter release];
    [super dealloc];
}


@end
