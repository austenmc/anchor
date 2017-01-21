//
//  ARUser.h
//  Anchor
//
//  Created by Austen McDonald on 1/20/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Parse/Parse.h>


/**
 Subclass of PFUser, representing a user in our Anchor application. We store a few app-specific
 properties but otherwise use ARUser as you would use any PFUser object.
 */
@interface ARUser : PFUser

/**
 Client identifier provided by the FullContact app registration process. Every user should either have their
 own API ID/Secret pair or share one for one organization.
 */
@property (nonatomic, copy) NSString *fullContactClientId;

/**
 Secret string provided by the FullContact app registration process. Every user should either have their
 own API ID/Secret pair or share one for one organization.
 */
@property (nonatomic, copy) NSString *fullContactClientSecret;

/**
 Primary access token to perform API requests on FullContact. See https://api.fullcontact.com/v3/docs/authentication/
 */
@property (nonatomic, copy) NSString *fullContactAccessToken;

/**
 Token with which to request another valid access token, once the access token has expired. See https://api.fullcontact.com/v3/docs/authentication/
 */
@property (nonatomic, copy) NSString *fullContactResetToken;

@end
