/*
*/

#import "DetailViewController.h"
#import "RootViewController.h"


@implementation WebViewController
/////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) _setupStopRefreshChain;
{
	UIBarButtonItem *bbutton = self.navigationItem.rightBarButtonItem;
	[self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
																							  target:self 
																							  action:@selector(_stopButton)] animated: YES];
	_refreshUp = NO;
	[bbutton release];
	
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.prompt = @"Loading...";
}

- (void) _refresh;
{	
	[self _setupStopRefreshChain];
	if (_url) [(UIWebView*)self.view loadRequest:[NSURLRequest requestWithURL:_url]];
}

- (void) _addStopButton;
{
	UIBarButtonItem *bbutton = self.navigationItem.rightBarButtonItem;
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							 target:self
																							 action:@selector(_refresh)] animated:YES];
	_refreshUp = YES;
	[bbutton release];
}
- (void) _stopButton;
{
	UIWebView *twv = (UIWebView*)self.view;		// to kill warnings
	[twv stopLoading];
	[self webViewDidFinishLoad:twv];
	
	[self _addStopButton];
}
/*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}*/

- (void)viewWillDisappear:(BOOL)animated;
{
	[_url release];
	_url = nil;
	[super viewWillDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	static BOOL hasHitFirst = NO;
	if (!hasHitFirst) {
		[self _setupStopRefreshChain];
		hasHitFirst = YES;
	}
	if (!_url) _url = [[request URL] copy];
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
	self.navigationItem.hidesBackButton = NO;
	self.navigationItem.prompt = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (!_refreshUp) [self _addStopButton];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
	NSLog(@"Fail whale! %@", error);
}

/////
@end

@implementation DetailViewController

@synthesize detailItem;

- (void) dealloc;
{
	[(UIWebView*)_webViewCtrlr.view stopLoading];
	[_webViewCtrlr.view release];
	[_webViewCtrlr release];
	
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.title = [(NSDictionary*)[(NSDictionary *)detailItem objectForKey:@"user"] objectForKey:@"name"];
}


// Standard table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell) {
		NSURL *url = nil;
		
		switch (indexPath.section) {
			case 2:
			case 3:
				if (![cell.text isEqualToString:@"No URL"]) {
					url = [NSURL URLWithString:cell.text];
				}
				
				break;
				
			case 4:
				if (![cell.text isEqualToString:@"No Reply"]) {
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@twitter.com/%@",
												([[NSUserDefaults standardUserDefaults] boolForKey:@"mobileTwitter"] ? @"m." : @""),
												[[cell.text componentsSeparatedByString:@"@"] objectAtIndex:1]]];
					NSLog(@"URL %@", url);
				}
				
				break;
				
			default:
				break;
		}
		
		if (url) {
			UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
			webView.scalesPageToFit = YES;
			
			if (_webViewCtrlr) {
				[_webViewCtrlr.view release];
				[_webViewCtrlr release];
			}
				
			_webViewCtrlr = [[WebViewController alloc] init];
			_webViewCtrlr.view = webView;
			_webViewCtrlr.title = [url host];
			webView.delegate = _webViewCtrlr;
			
			[webView loadRequest:[NSURLRequest requestWithURL:url]];
			[self.navigationController pushViewController:_webViewCtrlr animated:YES];
		}
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"tvc";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Cache a date formatter to create a string representation of the date object
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
    }
    
    // Set the text in the cell for the section/row
    
    NSString *cellText = nil;
    NSRange range;
	
    switch (indexPath.section) {
        case 0:
            cellText = [(NSDictionary*)[detailItem objectForKey:@"user"] objectForKey:@"name"];
			if ([cellText isEqualToString:@""]) cellText = [(NSDictionary*)[detailItem objectForKey:@"user"] objectForKey:@"screen_name"];
            break;
			
        case 1:
            cellText = [(NSDictionary*)[detailItem objectForKey:@"user"] objectForKey:@"location"];
			if ([cellText isEqualToString:@""]) cellText = @"Unknown location";
            break;
			
        case 2:
            cellText = [(NSDictionary*)[detailItem objectForKey:@"user"] objectForKey:@"url"];
			cell.font = [UIFont boldSystemFontOfSize:14.0];
			if ([cellText isEqualToString:@""]) { cellText = @"No URL"; }
			else { cell.selectionStyle = UITableViewCellSelectionStyleBlue; }
            break;
			
		case 3:		// currently usused
			cellText = [detailItem objectForKey:@"text"];
			range = [cellText rangeOfString:@"http://"];
			
			if (range.location != NSNotFound) {
				cellText = [cellText substringWithRange:NSMakeRange(range.location, [cellText length] - range.location)];
				cellText = [[cellText componentsSeparatedByString:@" "] objectAtIndex:0];
			}
			else {
				cellText = @"No URL";
			}
			
			break;
			
		case 4:		// currently usused
			cellText = [detailItem objectForKey:@"text"];
			range = [cellText rangeOfString:@"@"];
			
			if (range.location != NSNotFound) {
				cellText = [cellText substringWithRange:NSMakeRange(range.location, [cellText length] - range.location)];
				cellText = [[cellText componentsSeparatedByString:@" "] objectAtIndex:0];
			}
			else {
				cellText = @"No Reply";
			}
			
			break;
			
        default:
            break;
    }
    
    cell.text = cellText;
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"Name", @"Name section title");
            break;
        case 1:
            title = NSLocalizedString(@"Location", @"Location section title");
            break;
        case 2:
            title = NSLocalizedString(@"URL", @"URL section title");
            break;
		case 3:		// currently unused
			title = NSLocalizedString(@"Linked-To", @"Last Update section title");
			break;
			
		case 4:
			title = NSLocalizedString(@"Replied-To", @"");
			break;
			
        default:
            break;
    }
    return title;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
