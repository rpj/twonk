/*

File: RootViewController.m
Abstract: Creates a table view and serves as its delegate and data source.

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

#import "RootViewController.h"
#import "DataController.h"
#import "DetailViewController.h"

#define kRowHeightDefault		75.0


@implementation RootViewController

@synthesize dataController;

- (void) _dataUpdated:(NSNotification*)notify;
{
	[self.tableView reloadData];
	self.title = NSLocalizedString(@"Twonk", @"Master view navigation title");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		heights = nil;
        self.title = NSLocalizedString(@"Loading...", @"Master view navigation title");
		((UITableView*)self.view).rowHeight = kRowHeightDefault;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dataUpdated:) name:kDataControllerUpdatedData object:nil];
    }
    return self;
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
	NSNumber* num = nil;
	if ((num = [heights objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]])) {
		NSLog(@"returning height %f", [num floatValue] + 5.0);
		return [num floatValue] + 5.0;
	}
	
	return kRowHeightDefault;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.lineBreakMode = UILineBreakModeWordWrap;
    }
	
	UITextView* tView = nil;
	
	if ([cell.contentView.subviews count] == 2) {
		tView = (UITextView*)[cell.contentView.subviews objectAtIndex:1];
	}
	else {
		CGRect nFrame = CGRectMake(0, 0, cell.bounds.size.width - 25, cell.bounds.size.height - 5);
		tView = [[UITextView alloc] initWithFrame:nFrame];	
		tView.scrollEnabled = NO;
		tView.editable = NO;
		tView.pagingEnabled = NO;
		tView.bounces = NO;
		tView.font = [UIFont systemFontOfSize: 12.0];
		tView.userInteractionEnabled = NO;
		
		[cell.contentView addSubview:tView];
	}
    
    // Get the object to display and set the value in the cell
    NSDictionary *itemAtIndex = (NSDictionary *)[dataController objectInListAtIndex:indexPath.row];
	NSString* text = [NSString stringWithFormat:@"%@: %@", [(NSDictionary*)[itemAtIndex objectForKey:@"user"] objectForKey:@"screen_name"], [itemAtIndex objectForKey:@"text"]];
	tView.text = text;
	
	if (!heights) heights = [[NSMutableDictionary alloc] init];
	
	int idx = indexPath.row;
	NSString* idxKey = [NSString stringWithFormat:@"%d", idx];
	[heights setValue:[NSNumber numberWithFloat:tView.contentSize.height] forKey:idxKey];
	//if (idx < [heights count] && [heights objectAtIndex:idx]) [heights removeObjectAtIndex:idx];
	/*else if (idx >= [heights count]) {
		NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity:(idx+1)];
		[temp addObjectsFromArray:heights];
		[heights release];
		heights = temp;
	}*/
	
	//NSLog(@"Scroll view content size: %@", NSStringFromCGSize(tView.contentSize));

	//[tView setNeedsDisplay];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     Create the detail view controller and set its inspected item to the currently-selected item
     */
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    detailViewController.detailItem = [dataController objectInListAtIndex:indexPath.row];
	detailViewController.rootCtrlr = self;
    
    // Push the detail view controller
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


- (void)dealloc {
	[heights release];
    [dataController release];
    [super dealloc];
}

@end
