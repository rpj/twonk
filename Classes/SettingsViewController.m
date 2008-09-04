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

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.title = @"Setup";
	
	NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];
	
	if (![udef objectForKey:@"mobileTwitter"]) {
		[udef setBool:YES forKey:@"mobileTwitter"];
		[udef synchronize];
	}
	
	if (![udef objectForKey:@"blackUI"]) {
		[udef setBool:YES forKey:@"blackUI"];
		[udef synchronize];
	}
	
	if (![udef objectForKey:@"showRateInfo"]) {
		[udef setBool:NO forKey:@"showRateInfo"];
		[udef synchronize];
	}
	
	_mobileSwitch.on = [udef boolForKey:@"mobileTwitter"];
	_reqSwitch.on = [udef boolForKey:@"showRateInfo"];
	_blackSwitch.on = [udef boolForKey:@"blackUI"];
	
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
	NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];
	NSString *uname = [udef stringForKey:@"username"];
	NSString *pass = [udef stringForKey:@"password"];
	
	if (uname && ![uname isEqualToString:@""] && pass && ![pass isEqualToString:@""]) {
		_username.text = _enterUser = uname;
		_password.text = _enterPass = pass;
	}
	else {
		[self.navigationItem setHidesBackButton:YES animated:YES];
	}
	
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	// this horrible condition checks to ensure we can't get ourselves into an infinite loop with the notification
	// handler in RootViewController.
	if (!([_username.text isEqualToString:@""] || [_password.text isEqualToString:@""])) {
		if ((!_enterUser && !_enterPass) || 
			((_enterUser && ![_enterUser isEqualToString:_username.text]) ||
			 (_enterPass && ![_enterPass isEqualToString:_password.text]))) {
			[[NSUserDefaults standardUserDefaults] setObject:_username.text forKey:@"username"];
			[[NSUserDefaults standardUserDefaults] setObject:_password.text forKey:@"password"];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAndPassSet" object:nil];
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSettingsViewWentAway object:self];
	[super viewWillDisappear:animated];
}

- (void) _broadcastChanges;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSettingsBroadcastChange object:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[super dealloc];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// username field's return key defaults to "Next", but if the password field already has something in it
	// we don't want to move on and inadvertantly clear what is in the password field
	if (textField == _username && _password.text && ![_password.text isEqualToString:@""])
		_username.returnKeyType = UIReturnKeyDone;
	
	[self.navigationItem setHidesBackButton:YES animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _username || textField == _password)
		[textField resignFirstResponder];
	
	// move to the password field if empty and we're just finishing the username field
	if (textField == _username && (!_password.text || [_password.text isEqualToString:@""]))
		[_password becomeFirstResponder];
	
	// if both fields are filled in an the back button is still hidden, un-hide it
	if (_password.text && ![_password.text isEqualToString:@""] &&
		_username.text && ![_username.text isEqualToString:@""] && 
		self.navigationItem.hidesBackButton)
			[self.navigationItem setHidesBackButton:NO animated:YES];
	
	return YES;
}

- (IBAction) switchToggle:(id)sender;
{
	if ([sender isKindOfClass:[UISwitch class]]) {
		if (sender == _mobileSwitch) {
			[[NSUserDefaults standardUserDefaults] setBool:_mobileSwitch.on forKey:@"mobileTwitter"];
		} else if (sender == _blackSwitch) {
			[[NSUserDefaults standardUserDefaults] setBool:_blackSwitch.on forKey:@"blackUI"];
		} else if (sender == _reqSwitch) {
			[[NSUserDefaults standardUserDefaults] setBool:_reqSwitch.on forKey:@"showRateInfo"];
		}
		
		[self _broadcastChanges];
	}
}
@end
