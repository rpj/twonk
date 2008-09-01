/*

File: DetailViewController.m
Abstract: Creates a grouped table view to act as an inspector.

Version: 2.5

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "DetailViewController.h"
#import "RootViewController.h"


@implementation DetailViewController

@synthesize detailItem;

/////
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
	NSLog(@"Fail whale! %@", error);
}

/////

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
	return 3;
    //return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {		
		UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
		
		if (cell && ![cell.text isEqualToString:@"No URL given"]) {
			
			UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
			webView.scalesPageToFit = YES;
			webView.delegate = self;
			
			_webViewCtrlr = [[UIViewController alloc] init];
			_webViewCtrlr.view = webView;
			
			NSURL *url = [NSURL URLWithString:cell.text];
			_webViewCtrlr.title = [url host];
			[webView loadRequest:[NSURLRequest requestWithURL:url]];
			[[self navigationController] pushViewController:_webViewCtrlr animated:YES];
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
			if ([cellText isEqualToString:@""]) { cellText = @"No URL given"; }
			else { cell.selectionStyle = UITableViewCellSelectionStyleBlue; }
            break;
		case 3:		// currently usused
			cellText = [detailItem objectForKey:@"text"];
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
			title = NSLocalizedString(@"Last Update", @"Last Update section title");
        default:
            break;
    }
    return title;
}


@end
