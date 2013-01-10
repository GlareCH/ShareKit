//
//  LROAuth2Client+SHK.h
//  ShareKit
//
//  Created by Glare on 13-1-9.
//
//

#import "LROAuth2Client.h"

@interface LROAuth2Client (SHK)

//popup controller
- (void)authorizeUsingPopupView;
- (void)authorizeUsingPopupViewWithParam:(NSDictionary *)dic;
- (void)finishAuthUsingPopupView;

//navigation controller
- (void)authorizeUsingNavigation:(UINavigationController *)navi;
- (void)authorizeUsingNavigation:(UINavigationController *)navi param:(NSDictionary *)dic;
- (void)finishAuthUsingNavigation;

@end
