//
//  SHKOAuth2View.h
//  ShareKit
//
//  Created by Glare on 13-1-9.
//
//

#import <UIKit/UIKit.h>

@interface SHKOAuth2View : UIViewController {
    UIView *_backgroundView;
    UIButton *_cancelButton;
    BOOL _showingKeyboard;
    UIDeviceOrientation _orientation;
    
	UIWebView *_webView;
    UIActivityIndicatorView *_indicatorView;
}

@property (nonatomic,retain)UIView *backgroundView;
@property (nonatomic,retain)UIButton *cancelButton;
@property (nonatomic,retain)UIWebView *webView;

- (void)show;
- (void)close;
- (void)updateSubviewOrientation;
- (void)sizeToFitOrientation:(BOOL)transform;
- (CGRect)fitOrientationFrame;

@end
