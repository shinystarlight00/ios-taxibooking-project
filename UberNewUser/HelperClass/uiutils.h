//
//  uiutils.h
//  library
//
//  Created by JAndroid on 21/12/2016.
//  Copyright © 2016 Choe Yong Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end


@interface UIImage (Trim)

- (UIImage *)trim;
- (UIImage *)crop:(CGRect)rect;
- (UIImage *)resize:(CGSize)newSize;

@end


@interface UIView (toUIImage)

- (UIImage *)toImage;

@end




@interface NSLayoutConstraint (Additions)

/**
 Restore scrollViewContentOffset when resigning from scrollView. Default is NO.
 */
- (NSLayoutConstraint*)setMultiplier:(CGFloat)multiplier;

@end


extern BOOL g_isBusy;


@interface UIUtil : NSObject


+ (UIViewController*) getViewController:(UIView *)view;

+ (UIViewController *)topViewController;
+ (UIViewController *)_topViewController:(UIViewController *)vc;

+ (UIViewController*) loadViewControllerFromStoryboard:(NSString *)vcid storyboardName:(NSString*)sbname;

+ (UIView*) loadViewFromXib:(NSString *)xibname;

+ (void)setNavigationBarBackItem:(UIViewController *)viewctrl title:(NSString*)title;
+ (UIButton*)setNavigationBarBackItemWithReturn:(UIViewController *)viewctrl title:(NSString*)title;

+ (void) setNavigationBarBackItem:(UIImage*)icon title:(NSString*)title viewctrl:(UIViewController*)viewctrl;
+ (void) setNavigationBarBackItem:(UIImage*)icon title:(NSString*)title viewctrl:(UIViewController*)viewctrl target:(id)target
                           action:(SEL)action;

+ (void) setNavigationBarBottomBar:(UINavigationBar*)bar color:(UIColor*)color; //设置导航栏底部线条颜色
+ (void) removeAllChildsInView:(UIView*) parent;
+ (void) removeAllTargets:(UIControl*) control;

+ (void) setHeight:(CGFloat)height view:(UIView*)view;
+ (void) setViewIn:(UIView*)view parent:(UIView*)parent;
+ (void) setCornerRadius:(CGFloat)radius view:(UIView*)view;

+ (void) setNavBar:(UINavigationBar*)navbar color:(UIColor*)color;

// show hub
+(void)showHub;
+(void)showHubWithTitle:(NSString*)title;

+(void)hideHub;


#pragma mark AlertView

+ (void)alert:(NSString*)message acceptTitle:(NSString*)acceptTitle;
+ (void)alertWithTitle:(NSString*)title message:(NSString*)message acceptTitle:(NSString*)acceptTitle;

+ (void)query:(NSString*)message acceptTitle:(NSString*)acceptTitle cancelTitle:(NSString*)cancelTitle acceptHandler:(void (^)())acceptHandler;
+ (void)queryWithTitle:(NSString*)title message:(NSString*)message acceptTitle:(NSString*)acceptTitle cancelTitle:(NSString*)cancelTitle acceptHandler:(void (^)())acceptHandler;

+ (void)query:(NSString*)message acceptTitle:(NSString*)acceptTitle cancelTitle:(NSString*)cancelTitle acceptHandler:(void (^)())acceptHandler rejectHandler:(void (^)())rejectHandler;
+ (void)queryWithTitle:(NSString*)title message:(NSString*)message acceptTitle:(NSString*)acceptTitle cancelTitle:(NSString*)cancelTitle acceptHandler:(void (^)())acceptHandler rejectHandler:(void (^)())rejectHandler;

#pragma mark UIStatusBar

+ (UIColor*)setStatusBarBackgroundColor:(UIColor *)color;

@end


