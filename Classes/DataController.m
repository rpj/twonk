/*
Derieved directly form DataController.m in Apple's "DrillDown" sample project
*/

#import "DataController.h"


@implementation DataController


- (void)requestSucceeded:(NSString *)requestIdentifier;
{
	if ([requestIdentifier isEqualToString:_lastReqID]) {
		if (!_validUser) {
			_validUser = YES;
			[_lastReqID release];
			_lastReqID = [[_twitter getFollowedTimelineFor:nil since:nil startingAtPage:0 count:200] retain];
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
	if ([identifier isEqualToString:_lastReqID] && [statuses count]) {
		_lastUpdateID = [(NSNumber*)[(NSDictionary*)[statuses objectAtIndex:0] objectForKey:@"id"] intValue];
		[list insertObjects:statuses atIndexes:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [statuses count])]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kDataControllerUpdatedData object:self userInfo:nil];
	}
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


- (void) reloadWithUsername:(NSString*)uname andPassword:(NSString*)pass;
{
	if (uname && pass) {
		_validUser = NO;
		_lastUpdateID = -1;
		
		[list release];
		list = [[NSMutableArray alloc] initWithCapacity:200];
		
		_twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
		[_twitter setUsername:uname password:pass];
		[_lastReqID release];
		_lastReqID = [[_twitter checkUserCredentials] retain];
	}
}

- (void) reloadWithStandardUserInfo;
{
	[self reloadWithUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]
				 andPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
}


- (id)init {
    if (self = [super init]) {
		NSString *uname = nil;
		NSString *pass = nil;
		
		if ((uname = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]) &&
			(pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"])) {
			[self reloadWithUsername:uname andPassword:pass];
		}
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
    return [list objectAtIndex:theIndex];
}


- (void)dealloc {
    [list release];
	[_twitter release];
    [super dealloc];
}


@end
