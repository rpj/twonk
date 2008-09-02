/*
*/

#import "RootViewController.h"
#import "DataController.h"
#import "DetailViewController.h"
#import "SettingsViewController.h"

#define kRowHeightDefault		90.0
#define kDefaultTweetFontSize	13.0
#define kDefaultRefreshInterval	30.0


@implementation RootViewController

@synthesize dataController;

- (void) _dataUpdated:(NSNotification*)notify;
{
	[self.tableView reloadData];
	
	self.title = NSLocalizedString(([NSString stringWithFormat:@"%@'s Friends", [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]), 
								   @"Master view navigation title");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (!_refreshButton.enabled)
		_refreshButton.enabled = YES;
}


- (void) _userAndPassSet:(NSNotification*)notify;
{
	if (!self.dataController) {
		// Create the data controller
		DataController *controller = [[DataController alloc] init];
		self.dataController = controller;
		[controller release];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.title = NSLocalizedString(([NSString stringWithFormat:@"Loading %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]), 
								   @"Master view navigation title");
	[self.dataController reloadWithStandardUserInfo];
}


- (void) _showSettings;
{
	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
	[[self navigationController] pushViewController:settings animated:YES];
	[settings release];
}

- (void) settingsButton:(id)sender;
{
	[self _showSettings];
}

- (void) refreshButton:(id)sender;
{
	if (!_lastRefresh || [_lastRefresh timeIntervalSinceNow] < -kDefaultRefreshInterval) {
		[_lastRefresh release];
		_lastRefresh = [[NSDate date] retain];
		_refreshButton.enabled = NO;
		self.navigationItem.title = @"Refreshing...";
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self.dataController refreshFriendsTimeline];
	}
}


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.title = NSLocalizedString(@"Twonk loading...", @"Master view navigation title");
		self.dataController = nil;
		
		((UITableView*)self.view).rowHeight = kRowHeightDefault;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dataUpdated:) name:kDataControllerUpdatedData object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userAndPassSet:) name:@"UserAndPassSet" object:nil];
    }
	
    return self;
}

- (void) finishSetup;
{
	if ([self navigationItem]) {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Setup"
																					  style:UIBarButtonItemStylePlain
																					 target:self 
																					 action:@selector(settingsButton:)] animated:YES];
		
		_refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																	   target:self
																	   action:@selector(refreshButton:)];
		[[self navigationItem] setLeftBarButtonItem:_refreshButton animated:YES];
	}
	
	if (![[NSUserDefaults standardUserDefaults] stringForKey:@"username"] || 
		![[NSUserDefaults standardUserDefaults] stringForKey:@"password"]) {
		[self _showSettings];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAndPassSet" object:nil];
	}
}

- (void) viewDidAppear:(BOOL)anim;
{
	static BOOL hasAppeared = NO;
	
	if (hasAppeared)
		[self refreshButton:self];
		
	hasAppeared = YES;
	[super viewDidAppear:anim];
}


// Standard table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Only one section so return the number of items in the list
    return [dataController countOfList];
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	// wouldn't it be nice if this could be dynamic, based on the size of the content in the cell...
	return kRowHeightDefault;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *itemAtIndex = (NSDictionary*)[dataController objectInListAtIndex:indexPath.row];
	NSString *idStr = [itemAtIndex objectForKey:@"id"];
	NSString *cellId = [NSString stringWithFormat:@"cellID_%@", idStr];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.lineBreakMode = UILineBreakModeWordWrap;
		
		UIView *label = [cell.contentView.subviews objectAtIndex:0];
		if (label) [label removeFromSuperview];
		
		UITextView* tView = nil;
		
		//NSLog(@"cell[%@].contentView[%@].subviews: %@", cell, cell.contentView, cell.contentView.subviews);
		if ([cell.contentView.subviews count] == 1) {
			tView = (UITextView*)[cell.contentView.subviews objectAtIndex:0];
			NSLog(@"Reusing %@ for cell %@, index path %@", tView, cell, indexPath);
		}
		else {
			CGRect nFrame = CGRectMake(0, 0, cell.frame.size.width - 25, cell.frame.size.height);
			tView = [[UITextView alloc] initWithFrame:nFrame];	
			tView.scrollEnabled = NO;
			tView.editable = NO;
			tView.pagingEnabled = NO;
			tView.bounces = NO;
			tView.userInteractionEnabled = NO;
			tView.font = [UIFont systemFontOfSize: kDefaultTweetFontSize];
			
			[cell.contentView addSubview:tView];
			[tView release];
		}
		
		// Get the object to display and set the value in the cell
		NSDictionary *itemAtIndex = (NSDictionary *)[dataController objectInListAtIndex:indexPath.row];
		NSString* text = [NSString stringWithFormat:@"(%@) %@", [(NSDictionary*)[itemAtIndex objectForKey:@"user"] objectForKey:@"screen_name"], [itemAtIndex objectForKey:@"text"]];
		tView.text = text;
		
		// seems that if we adjust the text view's frame size here (after knowing how high the content size will be),
		// we don't get truncated text any longer.
		// however, I believe this is Doing It Wrong, because there are strange table view drawing problems when you
		// scroll now... oh well, at least it's getting closer.
		tView.frame = CGRectMake(tView.frame.origin.x, tView.frame.origin.y, tView.contentSize.width, tView.contentSize.height);
		[tView setNeedsDisplay];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.detailItem = [dataController objectInListAtIndex:indexPath.row];
    
    // Push the detail view controller
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


- (void)didReceiveMemoryWarning {
	NSLog(@"%@ memory warning", [self class]);
}

- (void)dealloc {
    [dataController release];
	[_refreshButton release];
	[_lastRefresh release];
    [super dealloc];
}

@end
