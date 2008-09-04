//
//  SettingsViewController.h
//  twonk
//
//  Created by Ryan Joseph on 9/1/08.
//  Copyright 2008 Micromat, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSettingsBroadcastChange	@"SettingsBroadcastChange"
#define kSettingsViewWentAway		@"SettingsViewWentAway"

@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *_username;
	IBOutlet UITextField *_password;
	IBOutlet UISwitch *_mobileSwitch;
	IBOutlet UISwitch *_reqSwitch;
	IBOutlet UISwitch *_blackSwitch;
	
	NSString *_enterUser;
	NSString *_enterPass;
}

- (IBAction) switchToggle:(id)sender;
@end
