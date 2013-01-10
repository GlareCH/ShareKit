//
//  SHKOAuth2Sharer.m
//  ShareKit
//
//  Created by Glare on 13-1-9.
//
//

#import "SHKOAuth2Sharer.h"
#import "LROAuth2Client+SHK.h"
#import "SHKConstants.h"
@interface SHKOAuth2Sharer ()

@property (nonatomic, retain) LROAuth2Client *oauth2Client;

- (BOOL)authorizeUsingPopupView;
- (NSDictionary *)authorizeParam;
- (void)storeAuthDataWithResponse:(NSDictionary *)responseData;

@end

@implementation SHKOAuth2Sharer

- (void)dealloc
{
    [_clientID release];
    [_clientSecret release];
    [_redirectURL release];
    [_cancelURL release];
    [_userURL release];
    [_tokenURL release];
    
    _oauth2Client.delegate = nil;
    [_oauth2Client release];
    
    [_httpClient release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SHKOAuth2ViewDidCloseNotification
                                                  object:nil];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.httpClient = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self httpClientBaseURL]]] autorelease];
    }
    return self;
}

#pragma mark -
#pragma mark HTTP Client
- (NSString *)httpClientBaseURL
{
    return @"";
}
- (NSDictionary *)httpClientUserInfoDictionary
{
    return
    @{
    @"path":@"",
    @"parameters":@{@"":@""}
    };
}


#pragma mark -
#pragma mark Access User Info

- (void)sendUserInfoAccessRequest
{
    [self retain];
    [self userInfoAccessDidStart];
    
    __block SHKOAuth2Sharer * blockSelf = self;
    NSDictionary *httpClientUserInfoDictionary = [self httpClientUserInfoDictionary];
    [self.httpClient getPath:[httpClientUserInfoDictionary valueForKey:@"path"]
                  parameters:[httpClientUserInfoDictionary valueForKey:@"parameters"]
                     success:^(AFHTTPRequestOperation *operation, id JSON)
    {
        [blockSelf userInfoAccessDidFinishWithUserInfo:[blockSelf userInfoItemFromJSON:JSON]];
        [blockSelf release];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [blockSelf userInfoAccessDidFailWithError:error];
        [blockSelf release];
    }];
}

- (SHKItem *)userInfoItemFromJSON:(id)JSON
{
    return nil;
}

#pragma mark -
#pragma mark Authorization

- (void)storeAuthDataWithResponse:(NSDictionary *)responseData
{
    SHKLog(@"%@",responseData);
}

- (BOOL)isAuthorized
{
    NSString *sharer = [self sharerId];
    NSString *accessToken = [SHK getAuthValueForKey:kSHKOAuth2AccessTokenKey forSharer:sharer];
    NSTimeInterval timeInterval = [[SHK getAuthValueForKey:kSHKOAuth2ExpirationTimeIntervalSine1970Key forSharer:sharer] doubleValue];
    NSString *userId = [SHK getAuthValueForKey:kSHKOAuth2UserIdKey forSharer:sharer];
    NSString *refreshToken = [SHK getAuthValueForKey:kSHKOAuth2RefreshTokenKey forSharer:sharer];

    if (accessToken &&
        timeInterval>[[NSDate date] timeIntervalSince1970] &&
        userId &&
        refreshToken)
    {
        return YES;
    }
    
    return NO;
}


- (void)promptAuthorization
{
    
    self.oauth2Client = [[[LROAuth2Client alloc] initWithClientID:self.clientID
                                                           secret:self.clientSecret
                                                      redirectURL:self.redirectURL] autorelease];
    _oauth2Client.delegate = self;
    [self retain];
    
    _oauth2Client.cancelURL = self.cancelURL;
    _oauth2Client.userURL = self.userURL;
    _oauth2Client.tokenURL = self.tokenURL;
    
    if ([self authorizeUsingPopupView]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popupOauth2ViewDidClose)
                                                     name:SHKOAuth2ViewDidCloseNotification
                                                   object:nil];
        [_oauth2Client authorizeUsingPopupViewWithParam:[self authorizeParam]];
    }else{
        [_oauth2Client authorizeUsingNavigation:self param:[self authorizeParam]];
    }
}

- (BOOL)authorizeUsingPopupView
{
    // subclass can override this method
    // using Navigation by NO
    
    return YES;
}

- (NSDictionary *)authorizeParam
{
    // subclass must override this method
    
    return nil;
}

- (void)popupOauth2ViewDidClose
{
    [self oauthClientDidCancel:nil];
}

#pragma mark Authorization Form
+ (NSArray *)authorizationFormFields
{
    return @[
    [SHKFormFieldSettings key:kSHKOAuth2AccessTokenKey],
    [SHKFormFieldSettings key:kSHKOAuth2ExpirationTimeIntervalSine1970Key],
    [SHKFormFieldSettings key:kSHKOAuth2UserIdKey],
    [SHKFormFieldSettings key:kSHKOAuth2RefreshTokenKey]
    ];
}


#pragma mark - 
#pragma mark LROAuth2ClientDelegate

- (void)oauthClientDidReceiveAccessToken:(LROAuth2Client *)client
{
    if ([self authorizeUsingPopupView]) {
        [client finishAuthUsingPopupView];
    }else{
        [client finishAuthUsingNavigation];
    }
    
    [self storeAuthDataWithResponse:[client.accessToken performSelector:@selector(authResponseData)]];
    
    [self authDidFinish:YES];
    
    self.oauth2Client.delegate = nil;
    self.oauth2Client = nil;
    
    if (self.item ||                                    // log in to share item
        SHKPendingUserInfoAccess == self.pendingAction) // or to access user info
        [self tryPendingAction];
    
    [self release];
}

- (void)oauthClientDidRefreshAccessToken:(LROAuth2Client *)client
{
    [self oauthClientDidReceiveAccessToken:client];
}

- (void)oauthClientDidCancel:(LROAuth2Client *)client
{
    if (client) {
        if ([self authorizeUsingPopupView]) {
            [client finishAuthUsingPopupView];
        }else{
            [client finishAuthUsingNavigation];
        }
    }
    
    SHKLog(@"OAuth2ClientDidCancel");
    
    [self authDidFinish:NO];
    
    self.oauth2Client.delegate = nil;
    self.oauth2Client = nil;
    
    [self release];
}

@end
