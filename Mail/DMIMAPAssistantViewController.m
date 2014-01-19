//
//  DMCustomLoginViewController.m
//  DotMail
//
//  Created by Robert Widmann on 10/12/12.
//  Copyright (c) 2012 CodaFi Inc. All rights reserved.
//

#import "DMIMAPAssistantViewController.h"
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

@interface DMIMAPAssistantViewController () <TUITextFieldDelegate>

@end

@implementation DMIMAPAssistantViewController

- (instancetype)init {
	if (self = [super init]) {
		
	}
	return self;
}

- (NSString *)title {
	return @"IMAP Assistant";
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
	
	DMPopUpButton *accountsPopupButton = [[DMPopUpButton alloc]initWithFrame:(NSRect){ { 20, 280 }, { 280, 36 } }];
	//accountsPopupButton.autoresizingMask = NSViewMinYMargin | NSViewWidthSizable;
	accountsPopupButton.autoenablesItems = YES;
	[accountsPopupButton setBordered:YES];
	[accountsPopupButton setTransparent:NO];
	[accountsPopupButton addItemsWithTitles:@[ @"IMAP", @"POP" ]];
	[view addSubview:accountsPopupButton];
	[accountsPopupButton.rac_selectionSignal subscribeNext:^(NSPopUpButton *button) {
	}];
    
    CALayer *backgroundServerLayer = CALayer.layer;
	backgroundServerLayer.frame = (CGRect){ { 20, 238 }, .size.width = 280, .size.height = 40 };
	backgroundServerLayer.backgroundColor = [NSColor colorWithCalibratedRed:0.908 green:0.936 blue:0.946 alpha:1.000].CGColor;
	backgroundServerLayer.cornerRadius = 4.0f;
	[view.layer addSublayer:backgroundServerLayer];
    
    self.serverTextField = [[NSTextField alloc] initWithFrame:(CGRect){ { 24, 236 }, .size.width = 276, .size.height = 32 } ];
	[self.serverTextField.cell setUsesSingleLineMode:YES];
	self.serverTextField.focusRingType = NSFocusRingTypeNone;
	[self.serverTextField.cell setPlaceholderString:@"IMAP Hostname"];
	self.serverTextField.backgroundColor = [NSColor clearColor];
	self.serverTextField.bordered = NO;
    
    [view addSubview:self.serverTextField];
    
    
    self.imapSecureMode = [[DMPopUpButton alloc]initWithFrame:(NSRect){ { 20, 200 }, { 280, 36 } }];
	self.imapSecureMode.autoenablesItems = YES;
	[self.imapSecureMode setBordered:YES];
	[self.imapSecureMode setTransparent:NO];
	[self.imapSecureMode addItemsWithTitles:@[ @"Secure", @"Insecure" ]];
	[view addSubview:self.imapSecureMode];
	[self.imapSecureMode.rac_selectionSignal subscribeNext:^(NSPopUpButton *button) {
	}];
    
    
    
    CALayer *backgroundUsernameLayer = CALayer.layer;
	backgroundUsernameLayer.frame = (CGRect){ { 20, 158 }, .size.width = 280, .size.height = 40 };
	backgroundUsernameLayer.backgroundColor = [NSColor colorWithCalibratedRed:0.908 green:0.936 blue:0.946 alpha:1.000].CGColor;
	backgroundUsernameLayer.cornerRadius = 4.0f;
	[view.layer addSublayer:backgroundUsernameLayer];
    
    self.usernameTextField = [[NSTextField alloc] initWithFrame:(CGRect){ { 24, 156 }, .size.width = 276, .size.height = 32 } ];
	[self.usernameTextField.cell setUsesSingleLineMode:YES];
	self.usernameTextField.focusRingType = NSFocusRingTypeNone;
	[self.usernameTextField.cell setPlaceholderString:@"Username"];
	self.usernameTextField.backgroundColor = [NSColor clearColor];
	self.usernameTextField.bordered = NO;
    
    [view addSubview:self.usernameTextField];
    
    
    
    
    CALayer *backgroundPasswordLayer = CALayer.layer;
	backgroundPasswordLayer.frame = (CGRect){ { 20, 108 }, .size.width = 280, .size.height = 40 };
	backgroundPasswordLayer.backgroundColor = [NSColor colorWithCalibratedRed:0.908 green:0.936 blue:0.946 alpha:1.000].CGColor;
	backgroundPasswordLayer.cornerRadius = 4.0f;
	[view.layer addSublayer:backgroundPasswordLayer];
    
    self.passwordTextField = [[NSSecureTextField alloc] initWithFrame:(CGRect){ { 24, 106 }, .size.width = 276, .size.height = 32 } ];
	[self.passwordTextField.cell setUsesSingleLineMode:YES];
	self.passwordTextField.focusRingType = NSFocusRingTypeNone;
	[self.passwordTextField.cell setPlaceholderString:@"Password"];
	self.passwordTextField.backgroundColor = [NSColor clearColor];
	self.passwordTextField.bordered = NO;
    
    [view addSubview:self.passwordTextField];
    
    
    
    
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
    [self setInfoValue:self.serverTextField.stringValue forKey:@"imapHostname"];
    if((long)[self.imapSecureMode indexOfSelectedItem] == 1)
    {
        [self setInfoValue:@YES forKey:@"imapInsecure"];
    }
    else
    {
        [self setInfoValue:@NO forKey:@"imapInsecure"];
    }
    
    [self setInfoValue:self.usernameTextField.stringValue forKey:@"imapLogin"];
    [self setInfoValue:self.passwordTextField.stringValue forKey:@"imapPassword"];
    
    
    [[DMAccountSetupWindowController standardAccountSetupWindowController] switchView:@(DMAssistantPaneCustomSMTPAssistant)];
	
    /*[self setInfoValue:self.passwordTextField.stringValue forKey:@"smtpPassword"];
	[self setInfoValue:@(YES) forKey:@"smtpAuthenticationEnabled"];
	[self setInfoValue:@(NO) forKey:@"smtpInsecure"];*/
}



- (void)setInfo:(NSMutableDictionary *)info {
	[super setInfo:info];
	[self.serverNameField setText:[info objectForKey:@"imapHostname"]];
	[self.loginField setText:[info objectForKey:@"imapLogin"]];
	[self.passwordField setText:[info objectForKey:@"imapPassword"]];
}

- (void)resetUI {}

@end
