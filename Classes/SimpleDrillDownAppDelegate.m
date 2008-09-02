/*

*/

#import "SimpleDrillDownAppDelegate.h"
#import "RootViewController.h"
#import "DataController.h"


@implementation SimpleDrillDownAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Create and configure the navigation and view controllers
    RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.navigationController = aNavigationController;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [aNavigationController release];
    [rootViewController release];
    
	[rootViewController finishSetup];
	
    // Configure and show the window
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end
