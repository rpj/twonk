/*

*/

#import "SimpleDrillDownAppDelegate.h"
#import "RootViewController.h"
#import "DataController.h"

#define kToolbarDefaultHeight	44

@implementation SimpleDrillDownAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize toolbar;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Create and configure the navigation and view controllers
    RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.navigationController = aNavigationController;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[rootViewController finishSetup];
	
	UIToolbar *tbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, window.frame.size.height - kToolbarDefaultHeight, window.frame.size.width, kToolbarDefaultHeight)];
	tbar.barStyle = UIBarStyleBlackTranslucent;
	
	UIBarButtonItem *tbarSetup = [[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStyleBordered target:rootViewController action:@selector(settingsButton:)];
	UIBarButtonItem *tbarText = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *tbarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	tbarText.enabled = NO;
	tbarText.tag = 42;
	
	[tbar setItems:[NSArray arrayWithObjects:tbarSetup, tbarSpace, tbarText, nil] animated:YES];
	
	rootViewController.toolbar = self.toolbar = tbar;
	
	[tbar release];
	[tbarSetup release];
	[tbarSpace release];
	[tbarText release];
    [aNavigationController release];
    [rootViewController release];
	
    // Configure and show the window
    [window addSubview:[navigationController view]];
	[window addSubview:self.toolbar];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end
