//
//  AppDelegate.m
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "ARFullContact.h"
#import "ARUser.h"
#import "ARCalendarManager.h"
#import "ARScheduleViewController.h"
#import "ARKeyManager.h"

NSString *ARParseApplicationIdKey = @"ARParseApplicationId";
NSString *ARParseClientKeyKey = @"ARParseClientKey";
NSString *ARParseServerKey = @"ARParseServer";

@interface AppDelegate () <PFLogInViewControllerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) ARCalendarManager *calendarManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSString *applicationId = AR_PARSE_APPLICATION_ID;
  NSString *clientKey = AR_PARSE_CLIENT_KEY;
  NSString *server = AR_PARSE_SERVER;

  // Initialize Parse.
  [Parse enableLocalDatastore];
  [Parse initializeWithConfiguration:
   [ParseClientConfiguration
    configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
      configuration.applicationId = applicationId;
      configuration.clientKey = clientKey;
      configuration.server = server;
    }]];

  // Set up logging.
  [DDLog addLogger:[DDTTYLogger sharedInstance]];
  self.fileLogger = [[DDFileLogger alloc] init];
  self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
  self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;

  [DDLog addLogger:self.fileLogger];

  [Parse setLogLevel:PFLogLevelDebug];
  // Register observer and selector to receive the request we sent to server
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWillSendURLRequestNotification:) name:PFNetworkWillSendURLRequestNotification object:nil];
  // Register observer and selector to receive the response we get from server
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDidReceiveURLResponseNotification:) name:PFNetworkDidReceiveURLResponseNotification object:nil];

  _calendarManager = [[ARCalendarManager alloc] init];

  UIViewController *scheduleController = [[ARScheduleViewController alloc] initWithDate:[NSDate date] calendarManager:_calendarManager];
  _navigationController = [[UINavigationController alloc] initWithRootViewController:scheduleController];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = _navigationController;
  [self.window makeKeyAndVisible];

  if (![PFUser currentUser]) {
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.delegate = self;
    [_navigationController presentViewController:logInViewController animated:YES completion:nil];
  }

  self.keyManager = [[ARKeyManager alloc] init];

  return YES;
}

- (void)receiveWillSendURLRequestNotification:(NSNotification *) notification {
//  // Use key to get the NSURLRequest from userInfo
//  NSURLRequest *request = notification.userInfo[PFNetworkNotificationURLRequestUserInfoKey];
//  // DDLogDebug(@"outgoing: %@", request);
//  // DDLogDebug(@"out body: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
}

- (void)receiveDidReceiveURLResponseNotification:(NSNotification *) notification {
//  // Use key to get the NSURLRequest from userInfo
//  NSURLRequest *request = notification.userInfo[PFNetworkNotificationURLRequestUserInfoKey];
//  // Use key to get the NSURLResponse from userInfo
//  NSURLResponse *response = notification.userInfo[PFNetworkNotificationURLResponseUserInfoKey];
//  NSString *responseBody = notification.userInfo[PFNetworkNotificationURLResponseBodyUserInfoKey];
//  // DDLogDebug(@"incoming: %@", response);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  if ([url.scheme isEqualToString:@"anchor-fullcontact"]) {
    if (!_fullContact) {
      DDLogError(@"Could not find instance of ARFullContact API manager while redirecting to handle authentication. This probably means app died in the background. Someone should fix this edge case.");
    }
    [_fullContact handleAuthenticationCallback:url];
    return YES;
  }
  return NO;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
  DDLogInfo(@"User logged in: %@", user);
  
  [logInController dismissViewControllerAnimated:YES completion:nil];
}

- (ARFullContact *)fullContact
{
  ARUser *user = (ARUser *)[PFUser currentUser];
  if (!_fullContact) {
    if (user.fullContactClientId && user.fullContactClientSecret) {
      self.fullContact = [[ARFullContact alloc] initWithClientId:user.fullContactClientId
                                                    clientSecret:user.fullContactClientSecret
                                                     redirectURI:@"anchor-fullcontact://redirect"];
    }
  }
  // Be safe and update the clientID and clientSecret in case they changed.
  _fullContact.clientId = user.fullContactClientId;
  _fullContact.clientSecret = user.fullContactClientSecret;
  return _fullContact;
}

@end
