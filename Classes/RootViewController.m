/*
*/

#import "RootViewController.h"
#import "DataController.h"
#import "DetailViewController.h"
#import "SettingsViewController.h"
#import "TwitterCell.h"

#define kRowHeightDefault		90.0
#define kDefaultTweetFontSize	13.0
#define kDefaultRefreshInterval	30.0
#define kBackgroundColor		[UIColor blackColor]

//[UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:1.0]


@implementation RootViewController

@synthesize dataController;

- (void) _clearPrompt:(NSTimer*)timer;
{
	self.navigationItem.prompt = nil;
}

- (void) _errorPosted:(NSNotification*)notify;
{
	NSError *error = [[notify userInfo] objectForKey:@"NSError"];
	
	if (error) {
		NSString *str = nil;
		BOOL needsAlert = NO;
		
		switch ([error code]) {
			case 400:
				str = @"Rate limit exceeded.";
				break;
				
			case 401:
				str = @"Bad username and/or password.";
				break;
				
			case 500:
			case 502:
			case 503:
				str = [NSString stringWithFormat:@"Twitter is technically... gone. Try again soon. (%@)", [error localizedDescription]];
				needsAlert = YES;
				break;
				
			default:
				str = [error localizedDescription];
				needsAlert = YES;
				break;
		}
		
		if (str) {
			if (needsAlert) {	
				UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Twitter Request Failed" 
																			  message:str
																			 delegate:nil
																	cancelButtonTitle:nil
																	otherButtonTitles:@"Continue", nil];
				[aView show];
			}
			else {
				self.navigationItem.prompt = str;
				[NSTimer scheduledTimerWithTimeInterval:kDefaultRefreshInterval/2 target:self selector:@selector(_clearPrompt:) userInfo:nil repeats:NO];
			}
		}
		
		NSLog(@"Twitter failure (reqID %@): \"%@\"", [[notify userInfo] objectForKey:@"requestID"], error);
	}
}

- (void) _dataUpdated:(NSNotification*)notify;
{
	[self.tableView reloadData];
	
	self.title = NSLocalizedString(([NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]), 
								   @"Master view navigation title");
	self.navigationItem.prompt = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) _showSettings;
{
	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
	[[self navigationController] pushViewController:settings animated:YES];
	[settings release];
}


- (void) _userAndPassSet:(NSNotification*)notify;
{
	if (!self.dataController) {
		// Create the data controller
		DataController *controller = [[DataController alloc] init];
		self.dataController = controller;
		[UIApplication sharedApplication].delegate = controller;
		[controller release];
	}
	
	NSString* user = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString* pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	if (!user || [user isEqualToString:@""] || !pass || [pass isEqualToString:@""]) {
		[self _showSettings];
	}
	else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		self.title = NSLocalizedString(([NSString stringWithFormat:@"%@", user]), @"Master view navigation title");
		[self.dataController reloadWithStandardUserInfo];
	}
}


- (void) settingsButton:(id)sender;
{
	[self _showSettings];
}

- (void) _enableRefresh:(NSTimer*)timer;
{
	_refreshButton.enabled = YES;
	[_lastRefresh release];
	_lastRefresh = nil;
}

- (void) refreshButton:(id)sender;
{
	if (!_lastRefresh || [_lastRefresh timeIntervalSinceNow] < -kDefaultRefreshInterval) {
		[_lastRefresh release];
		_lastRefresh = [[NSDate date] retain];
		_refreshButton.enabled = NO;
		self.navigationItem.prompt = @"Refreshing...";
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self.dataController refreshFriendsTimeline];
		[NSTimer scheduledTimerWithTimeInterval:kDefaultRefreshInterval target:self selector:@selector(_enableRefresh:) userInfo:nil repeats:NO];
	}
}


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.title = NSLocalizedString(@"Twonk", @"Master view navigation title");
		self.navigationItem.prompt = @"Loading...";
		self.dataController = nil;
		
		UITableView *table = (UITableView*)self.view;
		table.rowHeight = kRowHeightDefault;
		table.separatorStyle = UITableViewCellSeparatorStyleNone;
		table.separatorColor = [UIColor whiteColor];
		table.backgroundColor = kBackgroundColor;
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		_starSelect = [[UIImage imageNamed:@"star_select.png"] retain];
		_starUnselect = [[UIImage imageNamed:@"star_unselect.png"] retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dataUpdated:) name:kDataControllerUpdatedData object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_errorPosted:) name:kDataControllerTwitterError object:nil];
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
	
	// gets the whole ball rolling: set #if 0 to produce the Default.png screenshot; that is all.
#if 1
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAndPassSet" object:nil];
#else
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;
#endif
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

- (void) _starTouched;
{
	NSLog(@"_starTouched");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *itemAtIndex = (NSDictionary*)[dataController objectInListAtIndex:indexPath.row];
	NSString *idStr = [itemAtIndex objectForKey:@"id"];
	NSString *cellId = [NSString stringWithFormat:@"cellID_%@", idStr];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
    if (cell == nil) {
        cell = [[[TwitterCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.lineBreakMode = UILineBreakModeWordWrap;
		cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
		cell.backgroundView.backgroundColor = kBackgroundColor;
		
		UIView *label = [cell.contentView.subviews objectAtIndex:0];
		if (label) [label removeFromSuperview];
		
		UITextView* tView = nil;
		
		if ([cell.contentView.subviews count] == 1) {
			tView = (UITextView*)[cell.contentView.subviews objectAtIndex:0];
		}
		else {
			CGRect nFrame = CGRectMake(0, 0, cell.frame.size.width - 30, cell.frame.size.height);
			tView = [[UITextView alloc] initWithFrame:nFrame];	
			tView.scrollEnabled = NO;
			tView.editable = NO;
			tView.pagingEnabled = NO;
			tView.bounces = NO;
			tView.userInteractionEnabled = NO;
			tView.font = [UIFont boldSystemFontOfSize: kDefaultTweetFontSize];
			tView.textColor = [UIColor whiteColor];
			tView.backgroundColor = kBackgroundColor;
			
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
	[self _enableRefresh:nil];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [dataController release];
	[_refreshButton release];
	[_lastRefresh release];
    [super dealloc];
}

@end
