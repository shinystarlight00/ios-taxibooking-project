//
//  HomeVC.m
//  Wag
//
//  Created by Elluminati - macbook on 20/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "HomeVC.h"
#import "LoginVC.h"
#import "RegisterVC.h"
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "AFNHelper.h"
#import "AppDelegate.h"

@interface HomeVC ()
{
    CLLocationManager *locationManager;
    BOOL internet;
}
@end

@implementation HomeVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkStatus];
}
-(void)setLocalization
{
    
    [self.btnsignin setTitle:NSLocalizedString(@"Sign In", nil) forState:UIControlStateNormal];
    [self.btnregister setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [self.lblcopyright setText:NSLocalizedString(@"All Copyrights Reserved By Taxi any time", nil)];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.btnsignin setTitle:NSLocalizedString(@"Sign In", nil) forState:UIControlStateNormal];
    [self.btnregister setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
     [self.lblcopyright setText:NSLocalizedString(@"All Copyrights Reserved By Taxi any time", nil)];
}

-(void)checkStatus
{
    internet=[APPDELEGATE connected];
    if ([CLLocationManager locationServicesEnabled])
    {
       // [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
        if(internet)
        {
            [self getUserLocation];
            self.lblName.text=NSLocalizedString(APPLICATION_NAME, nil);
            
            if([PREF boolForKey:PREF_IS_LOGIN])
            {
                [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"ALREADY_LOGIN", nil)];
                self.navigationController.navigationBarHidden=YES;
               // [[AppDelegate sharedAppDelegate]hideLoadingView];
                [self performSegueWithIdentifier:SEGUE_TO_DIRECT_LOGIN sender:self];
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
       // [[AppDelegate sharedAppDelegate]hideLoadingView];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxi any time -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([PREF boolForKey:PREF_IS_LOGIN])
    {
        //[[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"ALREADY_LOGIN", nil)];
        self.navigationController.navigationBarHidden=YES;
        [self performSegueWithIdentifier:SEGUE_TO_DIRECT_LOGIN sender:self];
       // [[AppDelegate sharedAppDelegate] hideLoadingView];
    }
    if(![PREF boolForKey:PREF_IS_LOGIN])
        self.navigationController.navigationBarHidden=YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(![PREF boolForKey:PREF_IS_LOGIN])
        self.navigationController.navigationBarHidden=NO;
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickSignIn:(id)sender
{
    //[self performSegueWithIdentifier:@"" sender:self];
}

-(IBAction)onClickRegister:(id)sender
{
    
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //segue.identifier
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)getUserLocation
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    [locationManager startUpdatingLocation];
}

@end
