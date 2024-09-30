//
//  uiutils.m
//  library
//
//  Created by JAndroid on 21/12/2016.
//  Copyright © 2016 Choe Yong Ho. All rights reserved.
//

#import "uiutils.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
@end

@implementation UIImage (Trim)

- (CGRect)cropRectForImage{
    
    CGImageRef cgImage = self.CGImage;
    CGContextRef context = [self createARGBBitmapContextFromImage:cgImage];
    if (context == NULL) return CGRectZero;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(context, rect, cgImage);
    
    unsigned char *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    //Filter through data and look for non-transparent pixels.
    int lowX = width;
    int lowY = height;
    int highX = 0;
    int highY = 0;
    if (data != NULL) {
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                int pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */;
                if (data[pixelIndex] != 0) { //Alpha value is not zero; pixel is not transparent.
                    if (x < lowX) lowX = x;
                    if (x > highX) highX = x;
                    if (y < lowY) lowY = y;
                    if (y > highY) highY = y;
                }
            }
        }
        free(data);
    } else {
        return CGRectZero;
    }
    
    return CGRectMake(lowX, lowY, highX-lowX, highY-lowY);
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) return NULL;
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL) free (bitmapData);
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

- (UIImage *)trim{
    CGRect newRect = [self cropRectForImage];
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, newRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}

- (UIImage *)crop:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}

- (UIImage *)resize:(CGSize)newSize{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end


@implementation UIView (toUIImage)

- (UIImage *)toImage{

//    UIGraphicsBeginImageContext(self.bounds.size);
//    
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return image;
    
    //UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1.4);
    //UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, self.layer.rasterizationScale);
    //UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, self.layer.contentsScale);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


UIUtil* g_UIUtil;

@implementation UIUtil


+ (void)removeAllChildsInView:(UIView *)parent{
    if( parent == nil) return;
    for(UIView* subview in [parent subviews]) [subview removeFromSuperview];
}

+ (void)setNavigationBarBottomBar:(UINavigationBar *)bar color:(UIColor *)color{
//    [bar setBackgroundImage:[[UIImage alloc] init]
//             forBarPosition:UIBarPositionAny
//                 barMetrics:UIBarMetricsDefault];
    
    [bar setShadowImage:[UIImage imageWithColor:color size:CGSizeMake(1, 1)]];
    
}

+ (void)removeAllTargets:(UIControl *)control{
    if( control == nil) return;
    for (id target in [control allTargets]) {
        [control removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }
}


// 从UIView 得到 UIViewController
+ (UIViewController *)getViewController:(UIView *)view{
    
    UIView* next = view;
    while( next != nil) {
        UIResponder* next_responder = next.nextResponder;
        if( [next_responder isKindOfClass:[UINavigationController class]]) {
            return (UIViewController*)next_responder;
        }
        if( [next_responder isKindOfClass:[UIViewController class]]) {
            UIViewController* vc = (UIViewController*)next_responder;
            if( vc.navigationController != nil) {
                return vc;
            }
        }
        next = next.superview;
    }
    
    return nil;
    
//    for (UIView* next = view; next; next = next.superview) {
//        UIResponder* nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController class]]) {
//            UIViewController* vc = (UIViewController*)nextResponder;
//            if(vc.navigationController != nil)
//                return vc;
//        }
//    }
//    return nil;
}


+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    
    resultVC = [UIUtil _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    
    while (resultVC.presentedViewController) {
        resultVC = [UIUtil _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIUtil _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIUtil _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


+ (UIViewController *)loadViewControllerFromStoryboard:(NSString *)vcid storyboardName:(NSString *)sbname
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:sbname bundle:nil];
    if( sb != nil) {
        return [sb instantiateViewControllerWithIdentifier:vcid];
    }
    return nil;
}

+ (UIView *)loadViewFromXib:(NSString *)xibname
{
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:xibname owner:nil options:nil];
    return [nibArray lastObject];

}

+ (void)setNavigationBarBackItem:(UIViewController *)viewctrl title:(NSString*)title {
    UIButton *leftBarButton = [UIUtil setNavigationBarBackItemWithReturn:viewctrl title:title];
    if( g_UIUtil == nil) {
        g_UIUtil = [[UIUtil alloc] init];
    }
    
    [leftBarButton addTarget:g_UIUtil action:@selector(popupViewController:) forControlEvents:UIControlEventTouchUpInside];
}

+ (UIButton *)setNavigationBarBackItemWithReturn:(UIViewController *)viewctrl title:(NSString*)title {
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //leftBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftBarButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [leftBarButton setTitle:title forState:UIControlStateNormal];
    [leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];//-20
    //[leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];//-20
    [leftBarButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //[leftBarButton setFrame:CGRectMake(0, 0, 52, 44)];
    [leftBarButton sizeToFit];

    leftBarButton.titleLabel.font = [UIFont systemFontOfSize:16];

    viewctrl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithCustomView:leftBarButton];

    return leftBarButton;
    
//    UIButton *leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 18, 24)];
//
//    [leftBarButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [leftBarButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//
//
//    if( g_UIUtil == nil) {
//        g_UIUtil = [[UIUtil alloc] init];
//    }
//
//    [leftBarButton addTarget:g_UIUtil action:@selector(popupViewController:) forControlEvents:UIControlEventTouchUpInside];
//
//    viewctrl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithCustomView:leftBarButton];
//
//    UILabel* titleLabel;
//    titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, ScreenWidth-120, 48)];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor= [UIColor blackColor];
//    titleLabel.textAlignment = NSTextAlignmentLeft;
//    [titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//    [titleLabel setText:[NSString stringWithFormat:@"  %@", title]];
//    viewctrl.navigationItem.titleView = titleLabel;
//
//    return leftBarButton;
}


+ (void)setNavigationBarBackItem:(UIImage *)icon title:(NSString *)title viewctrl:(UIViewController *)viewctrl
{
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setImage:icon forState:UIControlStateNormal];
    [leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];//-20
    [leftBarButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [leftBarButton setFrame:CGRectMake(0, 0, 40, 44)];
    
    if( g_UIUtil == nil) {
        g_UIUtil = [[UIUtil alloc] init];
    }
    
    [leftBarButton addTarget:g_UIUtil action:@selector(popupViewController:) forControlEvents:UIControlEventTouchUpInside];
    leftBarButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    viewctrl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithCustomView:leftBarButton];
}

+ (void)setNavigationBarBackItem:(UIImage *)icon title:(NSString *)title viewctrl:(UIViewController *)viewctrl target:(id)target action:(SEL)action{
    
    
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftBarButton setTitle:title forState:UIControlStateNormal];
    [leftBarButton setImage:icon forState:UIControlStateNormal];
    [leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];//-20
    [leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];//-20
    //[leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];//-20
    [leftBarButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [leftBarButton setFrame:CGRectMake(0, 0, 60, 44)];
    
    if( g_UIUtil == nil) {
        g_UIUtil = [[UIUtil alloc] init];
    }
    
    [leftBarButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    leftBarButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    viewctrl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithCustomView:leftBarButton];
}

+(void)setHeight:(CGFloat)height view:(UIView *)view{
    if( view == nil) return;
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

+(void)setViewIn:(UIView *)view parent:(UIView *)parent{
    if( view == nil) return;
    if( parent == nil) return;
    
    [UIUtil removeAllChildsInView:parent];
    CGRect frame = parent.frame;
    [view setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [parent addSubview:view];
}

+(void)setCornerRadius:(CGFloat)radius view:(UIView *)view{
    if( view == nil) return;
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}

+(void)setNavBar:(UINavigationBar *)navbar color:(UIColor *)color{
    if( navbar == nil) return;
    if( color == nil) return;
    
    [navbar setBackgroundImage:[UIImage imageWithColor:color size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
}


MBProgressHUD *myHud2;
UIView *myHud2_back;


+ (void)showHub{
    [UIUtil showHubWithTitle:@""];
}

+ (void)showHubWithTitle:(NSString *)title{
    
    g_isBusy = true;
    
    if( myHud2 == nil) {
        myHud2 = [[MBProgressHUD alloc]  initWithView:[UIApplication sharedApplication].keyWindow];
        myHud2.removeFromSuperViewOnHide = YES;
        myHud2.tag = 10000;
        
        myHud2.userInteractionEnabled = false;
    }
    myHud2.labelText = title;
    
    if( myHud2_back == nil) {
        myHud2_back = [[UIView alloc] init];
        myHud2_back.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        myHud2_back.userInteractionEnabled = true;
    }
    
    
    myHud2_back.frame = [UIApplication sharedApplication].keyWindow.bounds;

    [[UIApplication sharedApplication].keyWindow addSubview:myHud2];
    [[UIApplication sharedApplication].keyWindow addSubview:myHud2_back];
    
    [myHud2 show:true];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:myHud2];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:myHud2_back];
}

+ (void)hideHub{
    
    g_isBusy = false;
    
    //MBProgressHUD *myHud =(MBProgressHUD *)[view viewWithTag:10000];
    if( myHud2 == nil) return;
    [myHud2  hide:true];
    [myHud2_back setHidden:true];
}


- (void)popupViewController:(UIButton*)sender
{
    UIViewController *vc = [UIUtil getViewController:sender];
    if( [vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navvc = (UINavigationController*)vc;
        [navvc popViewControllerAnimated:true];
    } else {
        [vc.navigationController popViewControllerAnimated:true];
    }
}





#pragma mark AlertView

+ (void)alert:(NSString *)message acceptTitle:(NSString *)acceptTitle{
    [UIUtil alertWithTitle:nil message:message acceptTitle:acceptTitle];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message acceptTitle:(NSString *)acceptTitle {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:acceptTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertC addAction:alertA];
    UIViewController* viewctrl = [UIUtil topViewController];
    [viewctrl presentViewController:alertC animated:YES completion:nil];
}

+ (void)query:(NSString*)message acceptTitle:(NSString*)acceptTitle cancelTitle:(NSString*)cancelTitle acceptHandler:(void (^)())acceptHandler{
    
    [UIUtil query:message acceptTitle:acceptTitle cancelTitle:cancelTitle acceptHandler:acceptHandler rejectHandler:nil];
}

+ (void)queryWithTitle:(NSString *)title message:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle acceptHandler:(void (^)())acceptHandler {
    
    [UIUtil queryWithTitle:title message:message acceptTitle:acceptTitle cancelTitle:cancelTitle acceptHandler:acceptHandler rejectHandler:nil];
}

+ (void)query:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle acceptHandler:(void (^)())acceptHandler rejectHandler:(void (^)())rejectHandler{

    [UIUtil queryWithTitle:nil message:message acceptTitle:acceptTitle cancelTitle:cancelTitle acceptHandler:acceptHandler rejectHandler:rejectHandler];
}

+ (void)queryWithTitle:(NSString *)title message:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle acceptHandler:(void (^)())acceptHandler rejectHandler:(void (^)())rejectHandler {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:acceptTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if( acceptHandler != nil)
            acceptHandler();
    }];
    UIAlertAction *alertB = [UIAlertAction actionWithTitle:cancelTitle style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        if( rejectHandler != nil)
            rejectHandler();
    }];
    
    [alertC addAction:alertA];
    [alertC addAction:alertB];
    UIViewController* viewctrl = [UIUtil topViewController];
    [viewctrl presentViewController:alertC animated:YES completion:nil];
}


#pragma mark UIStatusBar

+ (UIColor*)setStatusBarBackgroundColor:(UIColor *)color{
    UIColor* res;
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        res = statusBar.backgroundColor;
        statusBar.backgroundColor = color;
    }
    return res;
}

@end


@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end



@implementation NSLayoutConstraint (Additions)

- (NSLayoutConstraint*)setMultiplier:(CGFloat)multiplier
{
    [NSLayoutConstraint deactivateConstraints:@[self]];
    
    NSLayoutConstraint *newl = [NSLayoutConstraint constraintWithItem:self.firstItem attribute:self.firstAttribute relatedBy:self.relation toItem:self.secondItem attribute:self.secondAttribute multiplier:multiplier constant:self.constant];
    
    newl.priority = self.priority;
    newl.shouldBeArchived = self.shouldBeArchived;
    newl.identifier = self.identifier;
    
    [NSLayoutConstraint activateConstraints:@[newl]];
    
    return newl;
}

@end

BOOL g_isBusy = false;

