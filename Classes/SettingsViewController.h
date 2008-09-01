//
//  SettingsViewController.h
//  twonk
//
//  Created by Ryan Joseph on 9/1/08.
//  Copyright 2008 Micromat, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *_username;
	IBOutlet UITextField *_password;
	
	NSString *_enterUser;
	NSString *_enterPass;
}

- (IBAction) usernameFieldChanged:(id)sender;
- (IBAction) passwordFieldChanged:(id)sender;
@end
