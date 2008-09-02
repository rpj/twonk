//
//  SettingsViewController.m
//  twonk
//
//  Created by Ryan Joseph on 9/1/08.
//  Copyright 2008 Micromat, Inc.. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		_enterUser = nil;
		_enterPass = nil;
	}
	return self;
}

- (void) viewWillAppear:(BOOL)animated;
{
	NSString *uname = nil;
	NSString *pass = nil;
	
	_mobileSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"mobileTwitter"];
	
	if ((uname = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]) &&
		(pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"])) {
		_username.text = _enterUser = uname;
		_password.text = _enterPass = pass;
	}
	
	self.navigationItem.title = @"User Setup";
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	if ((!_enterUser && !_enterPass) || 
		((_enterUser && ![_enterUser isEqualToString:_username.text]) ||
		 (_enterPass && ![_enterPass isEqualToString:_password.text]))) {
		[[NSUserDefaults standardUserDefaults] setObject:_username.text forKey:@"username"];
		[[NSUserDefaults standardUserDefaults] setObject:_password.text forKey:@"password"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAndPassSet" object:nil];
	}
	
	[super viewWillDisappear:animated];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	NSLog(@"%@ memory warning", [self class]);
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _username || textField == _password) {
		[textField resignFirstResponder];
	}
	
	if (textField == _username)
		[_password becomeFirstResponder];
	
	if (textField == _password)
		[self.navigationController popViewControllerAnimated:YES];
	
	return YES;
}

- (IBAction) mobileSwitchToggle:(id)sender;
{
	[[NSUserDefaults standardUserDefaults] setBool:_mobileSwitch.on forKey:@"mobileTwitter"];
}
@end
