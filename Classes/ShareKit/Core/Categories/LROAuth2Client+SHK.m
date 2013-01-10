//
//  LROAuth2Client+SHK.m
//  ShareKit
//
//  Created by Glare on 13-1-9.
//
//

#import "LROAuth2Client+SHK.h"
#import "SHKOAuth2View.h"

static UIViewController *_loginVC;

@implementation LROAuth2Client (SHK)

//popup controller
- (void)authorizeUsingPopupViewWithParam:(NSDictionary *)dic{
    SHKOAuth2View *_popup = [[SHKOAuth2View alloc] init];
    [_popup view];
    [_popup.webView setDelegate:self];
    [_popup.webView loadRequest:[self userAuthorizationRequestWithParameters:dic]];
    [_popup show];
    _loginVC = _popup;
    [_popup release];
}

- (void)authorizeUsingPopupView{
    [self authorizeUsingPopupViewWithParam:nil];
}

-(void)finishAuthUsingPopupView{
    [(SHKOAuth2View *)_loginVC close];
    _loginVC = nil;
}


//navigation controller
- (void)authorizeUsingNavigation:(UINavigationController *)navi{
    [self authorizeUsingNavigation:navi param:nil];
}

- (void)authorizeUsingNavigation:(UINavigationController *)navi param:(NSDictionary *)dic {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.title = @"授权登陆";
    UIWebView *webv = [[[UIWebView alloc] initWithFrame:vc.view.bounds] autorelease];
    [vc.view addSubview: webv];
    [navi pushViewController:vc animated:YES];
    _loginVC = vc;
    [vc release];
    [self authorizeUsingWebView:webv additionalParameters:dic];
}

-(void)finishAuthUsingNavigation{
    [_loginVC.navigationController popViewControllerAnimated:YES];
    _loginVC = nil;
}

@end
