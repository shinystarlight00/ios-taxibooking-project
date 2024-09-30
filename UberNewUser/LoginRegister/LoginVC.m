//
//  LoginVC.m
//  Uber
//
//  Created by Elluminati - macbook on 21/06/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "LoginVC.h"
//#import "FacebookUtility.h"
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import "GooglePlusUtility.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "UtilityClass.h"
#import "UberStyleGuide.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LoginVC ()
{
    NSString *strForSocialId,*strLoginType,*strForEmail;
    AppDelegate *appDelegate;
    
}

@end

@implementation LoginVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
  
    [super viewDidLoad];
    [self setLocalization];
    [super setNavBarTitle:NSLocalizedString(@"SIGN IN", nil)];
    [super setBackBarItem];
    
   // [self.txtEmail setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
   // [self.txtPsw setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    strLoginType=@"manual";
    
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPsw.font=[UberStyleGuide fontRegular];

    self.btnSignIn=[APPDELEGATE setBoldFontDiscriptor:self.btnSignIn];
    self.btnForgotPsw=[APPDELEGATE setBoldFontDiscriptor:self.btnForgotPsw];
    self.btnSignUp=[APPDELEGATE setBoldFontDiscriptor:self.btnSignUp];
    
    /*self.txtEmail.text=@"deep.gami077@gmail.com";
    self.txtPsw.text=@"123123";*/
    
    //[self performSegueWithIdentifier:SEGUE_SUCCESS_LOGIN sender:self];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];

}
-(void)viewWillAppear:(BOOL)animated
{
   // [[FacebookUtility sharedObject] logOutFromFacebook];
    self.navigationController.navigationBarHidden=YES;
    
}
/*
 -(void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 self.navigationController.navigationBarHidden=YES;
 }
 
 -(void)viewWillDisappear:(BOOL)animated
 {
 self.navigationController.navigationBarHidden=NO;
 [super viewWillDisappear:animated];
 }
 */
-(void)setLocalization
{
    self.txtEmail.placeholder=NSLocalizedString(@"Email", nil);
    self.txtPsw.placeholder=NSLocalizedString(@"Password", nil);
    [self.btnForgotPsw setTitle:NSLocalizedString(@"Forgot Password", nil) forState:UIControlStateNormal];
    [self.btnSignIn setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
}
- (void)viewDidAppear:(BOOL)animated
{
     [self.btnSignUp setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
}

#pragma mark -back 


- (IBAction)onClickForback:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -move to direct register :

- (IBAction)onclickForMoveRegtister:(id)sender {
    
    [self performSegueWithIdentifier:SEGUE_TO_DIRCET_REGI sender:self];
    
}

#pragma mark -
#pragma mark - Actions

- (IBAction)onClickGooglePlus:(id)sender
{
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
    
    
    
    if ([[GooglePlusUtility sharedObject]isLogin])
    {
        [[GooglePlusUtility sharedObject]loginWithBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response) {
                 strLoginType=@"google";
                 NSLog(@"Gmail Response ->%@ ",response);
                 strForSocialId=[response valueForKey:@"userid"];
                 strForEmail=[response valueForKey:@"email"];
                 self.txtEmail.text=strForEmail;
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 [self onClickLogin:nil];
                 
             }
         }];
    }
    else
    {
        [[GooglePlusUtility sharedObject]loginWithBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response) {
                 NSLog(@"Gmail Response ->%@ ",response);
                 strForSocialId=[response valueForKey:@"userid"];
                 strForEmail=[response valueForKey:@"email"];
                 self.txtEmail.text=strForEmail;
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 [self onClickLogin:nil];
                 
             }
         }];
    }
    
    
}

- (IBAction)onClickFacebook:(id)sender
{
    if([APPDELEGATE connected])
    {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
            
            if (error) {
                
                NSLog(@"Process error");
                
            }
            
            else if (result.isCancelled)
                
            {
                
                NSLog(@"Cancelled");
                
            }
            
            else
                
            {
                
                NSLog(@"Logged in");
                
                
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                              
                                              initWithGraphPath:@"/me"
                                              
                                              parameters:@{ @"fields": @"id,email,name,first_name,last_name,gender,birthday"}
                                              
                                              HTTPMethod:@"GET"];
                
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                 
                 {
                     
                     [APPDELEGATE hideLoadingView];
                     
                     if (!error) {
                         
                         strLoginType=@"facebook";
                         strForSocialId=result[@"id"];
                         strForEmail=result[@"email"];
                         self.txtEmail.text=result[@"email"];
                         [self onClickLogin:nil];
                         
                     }
                     
                     else
                         
                     {
                         
                         NSLog(@"%@",error);
                         
                     }
                     
                 }];
            }
            
        }];
    }
//    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
//   
//     [[FacebookUtility sharedObject] logOutFromFacebook];
//    if (![[FacebookUtility sharedObject]isLogin])
//    {
//        [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
//         {
//             [APPDELEGATE hideLoadingView];
//             if (success)
//             {
//                 NSLog(@"Success");
//                 appDelegate = [UIApplication sharedApplication].delegate;
//                 [appDelegate userLoggedIn];
//                 [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
//                     if (response) {
//                        strLoginType=@"facebook";
//                         strForSocialId=[response valueForKey:@"id"];
//                         strForEmail=[response valueForKey:@"email"];
//                         self.txtEmail.text=strForEmail;
//                         [[AppDelegate sharedAppDelegate]hideLoadingView];
//                         
//                         [self onClickLogin:nil];
//                         
//                     }
//                 }];
//             }
//         }];
//    }
//    else{
//        NSLog(@"User Login Click");
//        appDelegate = [UIApplication sharedApplication].delegate;
//        [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
//            [APPDELEGATE hideLoadingView];
//            if (response) {
//                strForSocialId=[response valueForKey:@"id"];
//                strForEmail=[response valueForKey:@"email"];
//                self.txtEmail.text=strForEmail;
//                [[AppDelegate sharedAppDelegate]hideLoadingView];
//                
//                [self onClickLogin:nil];
//            }
//        }];
//        [appDelegate userLoggedIn];
//    }
    
}

-(IBAction)onClickLogin:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if(self.txtEmail.text.length>0)
        {
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
            
            NSString *strDeviceId=[PREF objectForKey:PREF_DEVICE_TOKEN];
            
            if (strDeviceId==nil || [strDeviceId isEqualToString:@""] || [strDeviceId isKindOfClass:[NSNull class]] || strDeviceId.length < 1)
            {
                strDeviceId=@"11111";
            }
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:@"ios" forKey:PARAM_DEVICE_TYPE];
            [dictParam setValue:strDeviceId forKey:PARAM_DEVICE_TOKEN];
            if([strLoginType isEqualToString:@"manual"])
                [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            // else
            //     [dictParam setValue:strForEmail forKey:PARAM_EMAIL];
            
            [dictParam setValue:strLoginType forKey:PARAM_LOGIN_BY];
            
            if([strLoginType isEqualToString:@"facebook"])
                [dictParam setValue:strForSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
            else if ([strLoginType isEqualToString:@"google"])
                [dictParam setValue:strForSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
            else
                [dictParam setValue:self.txtPsw.text forKey:PARAM_PASSWORD];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_LOGIN withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 NSLog(@"Login Response ---> %@",response);
                 if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         NSString *strLog=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"LOGIN_SUCCESS", nil),[response valueForKey:@"first_name"]];
                         
                         [APPDELEGATE showToastMessage:strLog];
                         
                         [PREF setObject:response forKey:PREF_LOGIN_OBJECT];
                         [PREF setObject:[response valueForKey:@"token"] forKey:PREF_USER_TOKEN];
                         [PREF setObject:[response valueForKey:@"id"] forKey:PREF_USER_ID];
                         [PREF setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                         [PREF setBool:YES forKey:PREF_IS_LOGIN];
                         [PREF synchronize];
                         
                         [self performSegueWithIdentifier:SEGUE_SUCCESS_LOGIN sender:self];
                     }
                     else
                     {
                         NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                         [alert show];                     }
                 }
                 
             }];
        }
        else
        {
            if(self.txtEmail.text.length==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EMAIL", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_PASSWORD", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

-(IBAction)onClickForgotPsw:(id)sender
{
    [self textFieldShouldReturn:self.txtPsw];
    /*
    if (self.txtEmail.text.length==0)
    {
        [[UtilityClass sharedObject]showAlertWithTitle:@"" andMessage:@"Enter your email id."];
        return;
    }
    else if (![[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
    {
        [[UtilityClass sharedObject]showAlertWithTitle:@"" andMessage:@"Enter valid email id."];
        return;
    }
     */
}

#pragma mark -
#pragma mark - TextField Delegate
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
{
    [self.txtEmail resignFirstResponder];
    [self.txtPsw resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int y=0;
    if (textField==self.txtEmail)
    {
        y=140;
    }
    else if (textField==self.txtPsw){
        y=160;
    }
    [self.scrLogin setContentOffset:CGPointMake(0, y) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.txtEmail)
    {
        [self.txtPsw becomeFirstResponder];
    }
    else if (textField==self.txtPsw){
        [textField resignFirstResponder];
        [self.scrLogin setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return YES;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
