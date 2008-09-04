/*
Derieved directly form DataController.m in Apple's "DrillDown" sample project
*/

#import "DataController.h"

#define TWEET_NUM	50

@implementation DataController

@synthesize lastReqID = _lastReqID;
@synthesize requestsRemaining = _lastRateLimitRemaining;

- (void)requestSucceeded:(NSString *)requestIdentifier;
{
	if ([requestIdentifier isEqualToString:_lastReqID]) {
		[_twitter getRateLimitStatus];
		
		if (!_validUser) {
			_validUser = YES;
			self.lastReqID = [_twitter getFollowedTimelineFor:nil since:nil startingAtPage:0 count:TWEET_NUM];
		}
	}
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataControllerUpdatedData object:self userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataControllerTwitterError 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																requestIdentifier, @"requestID", error, @"NSError", nil]];
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
	NSDictionary *info = nil;
	
	if ([miscInfo count] && (info = [miscInfo objectAtIndex:0])) {
		id limit = [info objectForKey:@"remaining-hits"];
		
		if (limit) _lastRateLimitRemaining = [limit intValue];
	}
}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)identifier;
{
	NSArray *arr = [_imgTrack objectForKey:identifier];
	
	if (arr && [arr count] == 2) {
		UITableViewCell *cell = [arr objectAtIndex:0];
		NSString *url = [[arr objectAtIndex:1] retain];
		
		if (cell && url) {
			cell.image = image;
			[cell setNeedsLayout];
			[cell setNeedsDisplay];
			
			[_imgTrack removeObjectForKey:identifier];
			[_imgTrack setObject:image forKey:url];
		}
		
		[url release];
	}
}

- (id) init;
{
	if ((self = [super init])) {
		_imgTrack = [[NSMutableDictionary alloc] init];
		_lastRateLimitRemaining = -1;
	}
	
	return self;
}

- (void) _reloadWithUsername:(NSString*)uname andPassword:(NSString*)pass;
{
	if (uname && pass) {
		_validUser = NO;
		_lastUpdateID = -1;
		_lastRateLimitRemaining = -1;
		
		NSAutoreleasePool *tPool = [[NSAutoreleasePool alloc] init];
		
		if (!_twitter)
			_twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
		
		[_twitter setUsername:uname password:pass];
		self.lastReqID = [_twitter checkUserCredentials];
		[_twitter getRateLimitStatus];
		
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


- (void) addImageToCell:(UITableViewCell*)cell fromURL:(NSString*)url;
{
	if (cell && url) {
		UIImage *cacheImg = [_imgTrack objectForKey:url];
		
		if (cacheImg) {
			cell.image = cacheImg;
		}
		else {
			NSString *req = [_twitter getImageAtURL:url];
			if (req) [_imgTrack setObject:[NSArray arrayWithObjects:cell, url, nil] forKey:req];
		}
	}
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


- (void)dealloc {
    [list release];
	[_twitter endUserSession];
	[_twitter release];
	[_imgTrack release];
    [super dealloc];
}



- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	_validUser = NO;
	_lastUpdateID = -1;
	_lastReqID = nil;
	
	[list release];
	list = [[NSMutableArray alloc] init];
}

@end
