//
//  SHKOAuth2Sharer.h
//  ShareKit
//
//  Created by Glare on 13-1-9.
//
//

#import "SHKSharer.h"
#import "LROAuth2Client.h"
#import "AFNetworking.h"

static NSString *const kSHKOAuth2AccessTokenKey=@"AccessTokenKey";
static NSString *const kSHKOAuth2ExpirationTimeIntervalSine1970Key=@"ExpirationTimeIntervalSine1970";
static NSString *const kSHKOAuth2UserIdKey =@"UserIDKey";
static NSString *const kSHKOAuth2RefreshTokenKey =@"RefreshToken";


@interface SHKOAuth2Sharer : SHKSharer
<LROAuth2ClientDelegate>

@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSURL *redirectURL;
@property (nonatomic, copy) NSURL *cancelURL;
@property (nonatomic, copy) NSURL *userURL;
@property (nonatomic, copy) NSURL *tokenURL;

#pragma mark - 
#pragma mark HTTP Client
@property (nonatomic, retain) AFHTTPClient *httpClient;
- (NSString *)httpClientBaseURL;
- (NSDictionary *)httpClientUserInfoDictionary;

- (SHKItem *)userInfoItemFromJSON:(id)JSON;

@end
