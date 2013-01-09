//
//  SHKQQConnect.m
//  ShareKitDemo
//
//  Created by Glare on 13-1-9.
//  Copyright (c) 2013年 Glare. All rights reserved.
//

#import "SHKQQConnect.h"
#import "SHKConfiguration.h"

static NSString *const kSHKQQConnectAccessTokenKey=@"AccessTokenKey";
static NSString *const kSHKQQConnectExpirationTimeIntervalSine1970Key=@"ExpirationTimeIntervalSine1970";
static NSString *const kSHKQQConnectOpenIdKey =@"OpenIDKey";


@interface SHKQQConnect ()

@end

@implementation SHKQQConnect

+ (TencentOAuth *)tencentOAuth
{
    static TencentOAuth *tencentOAuth = nil;
    @synchronized([SHKQQConnect class]) {
        if (! tencentOAuth)
        {
            tencentOAuth = [[TencentOAuth alloc] initWithAppId:SHKCONFIG(qqConsumerKey)
                                                   andDelegate:nil];
            tencentOAuth.redirectURI = SHKCONFIG(qqRedirectURI);
            
            NSString *sharerId = [SHKQQConnect sharerId];
            tencentOAuth.accessToken = [SHK getAuthValueForKey:kSHKQQConnectAccessTokenKey forSharer:sharerId];
            NSTimeInterval timeInterval = [[SHK getAuthValueForKey:kSHKQQConnectExpirationTimeIntervalSine1970Key forSharer:sharerId] doubleValue];
            tencentOAuth.expirationDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            tencentOAuth.openId = [SHK getAuthValueForKey:kSHKQQConnectOpenIdKey forSharer:sharerId];
        }
    }
    
    return tencentOAuth;
}

+ (void)storeAuthData
{
    TencentOAuth *tencentOAuth = [SHKQQConnect tencentOAuth];
    NSString *sharer = [self sharerId];
 
    [SHK setAuthValue:tencentOAuth.accessToken forKey:kSHKQQConnectAccessTokenKey forSharer:sharer];
    NSString *timeInterval = [[NSNumber numberWithDouble:[tencentOAuth.expirationDate timeIntervalSince1970]] stringValue];
    [SHK setAuthValue:timeInterval forKey:kSHKQQConnectExpirationTimeIntervalSine1970Key forSharer:sharer];
    [SHK setAuthValue:tencentOAuth.openId forKey:kSHKQQConnectOpenIdKey forSharer:sharer];
}

+ (BOOL)handleOpenURL:(NSURL*)url
{
    TencentOAuth *tencentOAuth = [SHKQQConnect tencentOAuth];
    
    // If app has "Application does not run in background" = YES,
    // or was killed before it could return from Facebook SSO callback (from Safari or Facebook app)
    if ( ! tencentOAuth.sessionDelegate)
    {
        SHKQQConnect *qqConnectSharer = [[[SHKQQConnect alloc] init] autorelease]; //released in sinaweiboDidLogIn
        
        if ([self isServiceAuthorized]) {
            qqConnectSharer.pendingAction = SHKPendingShare;
        }
        
        [tencentOAuth setSessionDelegate:qqConnectSharer];
    }
    
    return [tencentOAuth handleOpenURL:url];
}

#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"QQ登录";
}

+ (BOOL)canShareURL
{
	return YES;
}

+ (BOOL)canShareText
{
	return YES;
}

+ (BOOL)canShareImage
{
	return YES;
}

+ (BOOL)canGetUserInfo
{
	return YES;
}

#pragma mark -
#pragma mark Authentication

- (BOOL)isAuthorized
{
    if ([[SHKQQConnect tencentOAuth] isSessionValid] &&
        [[SHKQQConnect tencentOAuth] isOpenIdValid])
        return YES;
    
    return [super isAuthorized];
}

- (void)promptAuthorization
{
	[[SHKQQConnect tencentOAuth] setSessionDelegate:self];
    [self retain]; // must retain, because SinaWeibo does not retain its delegates. Released in callback.
	[[SHKQQConnect tencentOAuth] authorize:@[
     @"get_user_info",
     @"add_share"]
                                  inSafari:NO];
}

+ (void)logout
{
    NSString *shareId = [SHKQQConnect sharerId];
    for (SHKFormFieldSettings *field in [self authorizationFormFields]) {
        [SHK removeAuthValueForKey:field.key forSharer:shareId];
    }
    [[SHKQQConnect tencentOAuth] logout:nil];
}

#pragma mark Authorization Form

+ (NSArray *)authorizationFormFields
{
    return @[
    [SHKFormFieldSettings key:kSHKQQConnectAccessTokenKey],
    [SHKFormFieldSettings key:kSHKQQConnectExpirationTimeIntervalSine1970Key],
    [SHKFormFieldSettings key:kSHKQQConnectOpenIdKey],
    ];
}


#pragma mark -
#pragma mark Access User Info

- (void)sendUserInfoAccessRequest
{
    TencentOAuth *tencentOAuth = [SHKQQConnect tencentOAuth];
    [tencentOAuth setSessionDelegate:self];
    [tencentOAuth getUserInfo];    
    [self retain]; // must retain, because SinaWeibo does not retain its delegates. Released in callback.
    
    // Notify delegate
    [self userInfoAccessDidStart];
}


#pragma mark - 
#pragma mark Tencent Session Delegate

/**
 * Called when the user successfully logged in.
 */
/*!
 @method     tencentDidLogin
 @discussion Called when the user successfully logged in.
 */
- (void)tencentDidLogin
{
    SHKLog(@"tencentDidLogin");
    
    [SHKQQConnect storeAuthData];
    
    [self authDidFinish:YES];
	
    if (self.item ||                                    // log in to share item
        SHKPendingUserInfoAccess == self.pendingAction) // or to access user info
        [self tryPendingAction];
    else {
        [self release]; //see [self promptAuthorization]
        [[SHKQQConnect tencentOAuth] setSessionDelegate:nil];
    }

}

/**
 * Called when the user dismissed the dialog without logging in.
 */
/*!
 @method     tencentDidNotLogin:
 @discussion Called when the user dismissed the dialog without logging in.
 @param      cancelled cancelled
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    SHKLog(@"tencentDidNotLogin");
    
    [self authDidFinish:NO];
    
    [self release]; // see [self promptAuthorization]
    [[SHKQQConnect tencentOAuth] setSessionDelegate:nil];
}

/**
 * Called when the notNewWork.
 */
/*!
 @method     tencentDidNotNetWork
 @discussion Called when the notNewWork.
 */
- (void)tencentDidNotNetWork
{
    SHKLog(@"tencentDidNotNetWork");
    
    [self sendDidFailWithError:[SHK error:[NSString stringWithFormat:SHKLocalizedString(@"You must be online to login to %@"),[SHKQQConnect sharerTitle]]]];
    
    [self release]; // see [self promptAuthorization]
    [[SHKQQConnect tencentOAuth] setSessionDelegate:nil];
}

/**
 * Called when the user logged out.
 */
/*!
 @method     tencentDidLogout
 @discussion Called when the user logged out.
 */
- (void)tencentDidLogout
{
    SHKLog(@"tencentDidLogout");
    [SHKQQConnect logout];
    
    [self release]; // see [self send]
    [[SHKQQConnect tencentOAuth] setSessionDelegate:nil];
}

/**
 * Called when the get_user_info has response.
 */
/*!
 @method     getUserInfoResponse:
 @discussion Called when the get_user_info has response.
 @param      response response
 */
- (void)getUserInfoResponse:(APIResponse*) response
{
    if (URLREQUEST_SUCCEED==response.retCode)
    {
        SHKItem *userInfo = [[[SHKItem alloc] init] autorelease];
        userInfo.shareType = SHKShareTypeUserInfo;
        [userInfo setCustomValue:[response.jsonResponse valueForKey:@"nickname"] forKey:@"ScreenName"];
        [userInfo setCustomValue:[response.jsonResponse valueForKey:@"figureurl_2"] forKey:@"ProfileImageUrl"];
        [self userInfoAccessDidFinishWithUserInfo:userInfo];
    }else{
        [self sendDidFailWithError:[SHK error:response.message]];
    }
    
    [self release]; // see [self send]
    [[SHKQQConnect tencentOAuth] setSessionDelegate:nil];
}

@end
