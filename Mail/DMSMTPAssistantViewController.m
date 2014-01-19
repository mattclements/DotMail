//
//  DMSMTPAssistantViewController.m
//  DotMail
//
//  Created by Robert Widmann on 11/9/12.
//  Copyright (c) 2012 CodaFi Inc. All rights reserved.
//

#import "DMSMTPAssistantViewController.h"
#import "DMAccountSetupWindowController.h"
#import <QuartzCore/QuartzCore.h>
#import <MailCore/mailcore.h>
#import "DMColoredView.h"
#import "DMSecureTextField.h"
#import "DMLayeredImageView.h"
#import "DMPopUpButton.h"
#import "DMFlatButton.h"
#include <pthread.h>

static CGSize const DMWelcomeViewControllerSize = (CGSize){ 320, 500 };

@interface DMSMTPAssistantViewController () <TUITextFieldDelegate>

@end

@implementation DMSMTPAssistantViewController

- (instancetype)init {
	if (self = [super init]) {
		
	}
	return self;
}

- (NSString *)title {
	return @"SMTP Assistant";
}

- (CGSize)contentSize {
	return DMWelcomeViewControllerSize;
}

- (void)loadView {
    
	DMColoredView *view = [[DMColoredView alloc]initWithFrame:(NSRect){ {0, 0}, { 600, 500 } }];
	view.backgroundColor = NSColor.whiteColor;
	
	DMLayeredImageView *iconImageView = [[DMLayeredImageView alloc]initWithFrame:(NSRect){ { 110, 380 } , { 100, 100 } }];
	iconImageView.imageAlignment = NSImageAlignCenter;
	iconImageView.image = [NSImage imageNamed:NSImageNameAdvanced];
	iconImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
	[view addSubview:iconImageView];
    
    CALayer *backgroundServerLayer = CALayer.layer;
	backgroundServerLayer.frame = (CGRect){ { 20, 288 }, .size.width = 280, .size.height = 40 };
	backgroundServerLayer.backgroundColor = [NSColor colorWithCalibratedRed:0.908 green:0.936 blue:0.946 alpha:1.000].CGColor;
	backgroundServerLayer.cornerRadius = 4.0f;
	[view.layer addSublayer:backgroundServerLayer];
    
    self.serverTextField = [[NSTextField alloc] initWithFrame:(CGRect){ { 24, 286 }, .size.width = 276, .size.height = 32 } ];
	[self.serverTextField.cell setUsesSingleLineMode:YES];
	self.serverTextField.focusRingType = NSFocusRingTypeNone;
	[self.serverTextField.cell setPlaceholderString:@"SMTP Hostname"];
	self.serverTextField.backgroundColor = [NSColor clearColor];
	self.serverTextField.bordered = NO;
    
    [view addSubview:self.serverTextField];
    
    
    self.smtpSecureMode = [[DMPopUpButton alloc]initWithFrame:(NSRect){ { 20, 250 }, { 280, 36 } }];
	self.smtpSecureMode.autoenablesItems = YES;
	[self.smtpSecureMode setBordered:YES];
	[self.smtpSecureMode setTransparent:NO];
	[self.smtpSecureMode addItemsWithTitles:@[ @"Secure", @"Insecure" ]];
	[view addSubview:self.smtpSecureMode];
	[self.smtpSecureMode.rac_selectionSignal subscribeNext:^(NSPopUpButton *button) {
	}];
    
    
    
    CALayer *backgroundUsernameLayer = CALayer.layer;
	backgroundUsernameLayer.frame = (CGRect){ { 20, 208 }, .size.width = 280, .size.height = 40 };
	backgroundUsernameLayer.backgroundColor = [NSColor colorWithCalibratedRed:0.908 green:0.936 blue:0.946 alpha:1.000].CGColor;
	backgroundUsernameLayer.cornerRadius = 4.0f;
	[view.layer addSublayer:backgroundUsernameLayer];
    
    self.usernameTextField = [[NSTextField alloc] initWithFrame:(CGRect){ { 24, 206 }, .size.width = 276, .size.height = 32 } ];
	[self.usernameTextField.cell setUsesSingleLineMode:YES];
	self.usernameTextField.focusRingType = NSFocusRingTypeNone;
	[self.usernameTextField.cell setPlaceholderString:@"Username"];
	self.usernameTextField.backgroundColor = [NSColor clearColor];
	self.usernameTextField.bordered = NO;
    
    [view addSubview:self.usernameTextField];
    
    
    
    
    CALayer *backgroundPasswordLayer = CALayer.layer;
	backgroundPasswordLayer.frame = (CGRect){ { 20, 158 }, .size.width = 280, .size.height = 40 };
	backgroundPasswordLayer.backgroundColor = [NSColor colorWithCalibratedRed:0.908 green:0.936 blue:0.946 alpha:1.000].CGColor;
	backgroundPasswordLayer.cornerRadius = 4.0f;
	[view.layer addSublayer:backgroundPasswordLayer];
    
    self.passwordTextField = [[NSSecureTextField alloc] initWithFrame:(CGRect){ { 24, 156 }, .size.width = 276, .size.height = 32 } ];
	[self.passwordTextField.cell setUsesSingleLineMode:YES];
	self.passwordTextField.focusRingType = NSFocusRingTypeNone;
	[self.passwordTextField.cell setPlaceholderString:@"Password"];
	self.passwordTextField.backgroundColor = [NSColor clearColor];
	self.passwordTextField.bordered = NO;
    
    [view addSubview:self.passwordTextField];
    
    self.smtpAuthentication = [[DMPopUpButton alloc]initWithFrame:(NSRect){ { 20, 100 }, { 280, 36 } }];
	self.smtpAuthentication.autoenablesItems = YES;
	[self.smtpAuthentication setBordered:YES];
	[self.smtpAuthentication setTransparent:NO];
	[self.smtpAuthentication addItemsWithTitles:@[ @"Authentication On", @"Authentication Off" ]];
	[view addSubview:self.smtpAuthentication];
	[self.smtpAuthentication.rac_selectionSignal subscribeNext:^(NSPopUpButton *button) {
	}];
    
    
    
    
    self.createAccountButton = [[DMFlatButton alloc]initWithFrame:(NSRect){ { 20, 28 }, { 280, 40 } }];
	self.createAccountButton.keyEquivalent = @"\r";
	self.createAccountButton.buttonType = NSMomentaryPushInButton;
	self.createAccountButton.bordered = NO;
	self.createAccountButton.tag = 0;
	self.createAccountButton.target = self;
	self.createAccountButton.action = @selector(createAccount:);
	self.createAccountButton.verticalPadding = 6;
	self.createAccountButton.title = @"Create Account";
	self.createAccountButton.font = [NSFont fontWithName:@"HelveticaNeue-Bold" size:20];
	self.createAccountButton.backgroundColor = [NSColor colorWithCalibratedRed:0.105 green:0.562 blue:0.517 alpha:1.000];
	[view addSubview:self.createAccountButton];
    
    
    
    self.serverTextField.nextKeyView = self.usernameTextField;
	self.usernameTextField.nextKeyView = self.passwordTextField;
	self.passwordTextField.nextKeyView = self.serverTextField;
    
    
	self.view = view;
}

- (void)createAccount:(id)sender {
    [self setInfoValue:self.serverTextField.stringValue forKey:@"smtpHostname"];
    if((long)[self.smtpSecureMode indexOfSelectedItem] == 1)
    {
        [self setInfoValue:@YES forKey:@"smtpInsecure"];
    }
    else
    {
        [self setInfoValue:@NO forKey:@"smtpInsecure"];
    }
    
    if((long)[self.smtpAuthentication indexOfSelectedItem] == 1)
    {
        [self setInfoValue:@NO forKey:@"smtpAuthenticationEnabled"];
    }
    else
    {
        [self setInfoValue:@YES forKey:@"smtpAuthenticationEnabled"];
    }
    
    [self setInfoValue:self.usernameTextField.stringValue forKey:@"smtpLogin"];
    [self setInfoValue:self.passwordTextField.stringValue forKey:@"smtpPassword"];
    
    
    [DMAccountSetupWindowController.standardAccountSetupWindowController finishCreatingAccount:self];
}



- (void)setInfo:(NSMutableDictionary *)info {
	[super setInfo:info];
	/*[self.serverNameField setText:[info objectForKey:@"imapHostname"]];
	[self.loginField setText:[info objectForKey:@"imapLogin"]];
	[self.passwordField setText:[info objectForKey:@"imapPassword"]];*/
}

- (void)resetUI {}

@end