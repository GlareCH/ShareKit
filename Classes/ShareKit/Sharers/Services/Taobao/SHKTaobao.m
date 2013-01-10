//
//  SHKTaobao.m
//  ShareKitDemo
//
//  Created by Glare on 13-1-9.
//  Copyright (c) 2013年 Glare. All rights reserved.
//

#import "SHKTaobao.h"
#import "SHKConfiguration.h"
#import "JSONKit.h"
#import "NSDictionary+QueryString.h"

@interface SHKTaobao ()

@end

@implementation SHKTaobao

- (id)init
{
	if (self = [super init])
	{
		// OAUTH 2
		self.clientID = SHKCONFIG(taobaoClientID);
		self.clientSecret = SHKCONFIG(taobaoClientSecret);
 		self.redirectURL = [NSURL URLWithString:SHKCONFIG(taobaoRedirectURL)];
        // -- //
        
		// You do not need to edit these, they are the same for everyone
	    self.userURL = [NSURL URLWithString:@"https://oauth.taobao.com/authorize"];
	    self.tokenURL = [NSURL URLWithString:@"https://oauth.taobao.com/token"];
        
	}
	return self;
}

#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"淘宝";
}

+ (BOOL)canShareText
{
	return YES;
}

+ (BOOL)canGetUserInfo
{
	return YES;
}

#pragma mark -
#pragma mark HTTP Client
- (NSString *)httpClientBaseURL
{
    return @"https://eco.taobao.com/";
}
- (NSDictionary *)httpClientUserInfoDictionary
{
    return
    @{
    @"path":@"router/rest",
    @"parameters":
        @{
        @"method":@"taobao.user.buyer.get",
        @"format":@"json",
        @"access_token":[SHK getAuthValueForKey:kSHKOAuth2AccessTokenKey forSharer:[self sharerId]],
        @"v":@"2.0",
        @"fields":@"user_id,nick,sex,buyer_credit,avatar,has_shop,vip_info"
        }
    };
}


#pragma mark - 
#pragma mark Access User Info

- (SHKItem *)userInfoItemFromJSON:(id)JSON
{
    NSDictionary *jsonDic = [JSON objectFromJSONData];
    NSDictionary *userDic = [[jsonDic valueForKey:@"user_buyer_get_response"] valueForKey:@"user"];
    SHKItem *userInfo = [[[SHKItem alloc] init] autorelease];
    userInfo.shareType = SHKShareTypeUserInfo;
    [userInfo setCustomValue:[userDic valueForKey:@"user_id"] forKey:@"ID"];
    [userInfo setCustomValue:[userDic valueForKey:@"nick"] forKey:@"ScreenName"];
    [userInfo setCustomValue:[userDic valueForKey:@"avatar"] forKey:@"ProfileImageUrl"];
    return userInfo;
}

#pragma mark -
#pragma mark Authentication

- (void)storeAuthDataWithResponse:(NSDictionary *)responseData
{
    NSString *sharer = [self sharerId];
    [SHK setAuthValue:[responseData JSONString] forKey:@"SHKTaobaoAuthJsonString" forSharer:sharer];
    [SHK setAuthValue:[responseData valueForKey:@"access_token"] forKey:kSHKOAuth2AccessTokenKey forSharer:sharer];
    NSNumber *timeInterval = @([[responseData valueForKey:@"expires_in"] doubleValue]+[[NSDate date] timeIntervalSince1970]);
    [SHK setAuthValue:[timeInterval stringValue] forKey:kSHKOAuth2ExpirationTimeIntervalSine1970Key forSharer:sharer];
    [SHK setAuthValue:[responseData valueForKey:@"refresh_token"] forKey:kSHKOAuth2RefreshTokenKey forSharer:sharer];
    [SHK setAuthValue:[responseData valueForKey:@"taobao_user_id"] forKey:kSHKOAuth2UserIdKey forSharer:sharer];
}

- (NSDictionary *)authorizeParam
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"code" forKey:@"response_type"];
    [params setValue:@"wap" forKey:@"view"];
    return params;
}

@end
