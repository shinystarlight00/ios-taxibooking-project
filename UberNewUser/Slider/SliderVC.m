//
//  SliderVC.m
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "SliderVC.h"
#import "Constants.h"
#import "SWRevealViewController.h"
#import "PickUpVC.h"
#import "CellSlider.h"
#import "HistoryVC.h"
#import "AboutVC.h"
#import "PaymentVC.h"
#import "ProfileVC.h"
#import "PromotionsVC.h"
#import "ContactUsVC.h"
#import "UIView+Utils.h"
#import "UIImageView+Download.h"
#import "UberStyleGuide.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "CustomAlert.h"
//#import "FacebookUtility.h"

@interface SliderVC ()
{
    NSMutableArray *arrListName,*arrIdentifire;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSString *strContent;
}

@end

@implementation SliderVC

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
    self.tblMenu.backgroundView=nil;
    self.tblMenu.backgroundColor=[UIColor clearColor];
    [self.imgProfilePic applyRoundedCornersFullWithColor:[UIColor clearColor]];
    
    arrSlider=[[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"Profile", nil),NSLocalizedString(@"History", nil),NSLocalizedString(@"Payment", nil),NSLocalizedString(@"Code de référence", nil),nil ];
    arrImages=[[NSMutableArray alloc]initWithObjects:@"nav_profile",@"nav_profile",@"ub__nav_history",@"nav_payment",nil];
    arrIdentifire=[[NSMutableArray alloc]initWithObjects:SEGUE_PROFILE,SEGUE_TO_HISTORY,SEGUE_PAYMENT,SEGUE_TO_REFERRAL_CODE, nil];
    
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    NSMutableArray *arrImg=[[NSMutableArray alloc]init];
    for (int i=0; i<arrPage.count; i++)
    {
        NSMutableDictionary *temp1=[arrPage objectAtIndex:i];
        [arrTemp addObject:[NSString stringWithFormat:@"  %@",[temp1 valueForKey:@"title"]]];
        [arrImg addObject:@"nav_about"];
    }
    [arrSlider addObjectsFromArray:arrTemp];
    [arrIdentifire addObjectsFromArray:arrTemp];
    
    
    [arrImages addObjectsFromArray:arrImg];
    
    
    
    [arrSlider addObject:NSLocalizedString(@"Logout", nil)];
    [arrImages addObject:@"ub__nav_logout"];
    
    
    [arrImages addObjectsFromArray:arrImg];
    
    [arrSlider addObject:NSLocalizedString(@"", nil)];
    [arrImages addObject:@""];
    
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *dictInfo=[PREF objectForKey:PREF_LOGIN_OBJECT];
    [self.imgProfilePic downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    self.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
    
    self.tblMenu.tableFooterView=self.footerView;
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    frontVC=[nav.childViewControllers objectAtIndex:0];
}

#pragma mark -
#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrSlider count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellSlider *cell=(CellSlider *)[tableView dequeueReusableCellWithIdentifier:@"CellSlider"];
    if (cell==nil) {
        cell=[[CellSlider alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSlider"];
    }
    cell.lblName.text=[arrSlider objectAtIndex:indexPath.row];
    cell.imgIcon.image=[UIImage imageNamed:[arrImages objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[arrSlider objectAtIndex:indexPath.row]isEqualToString:@"  Logout"])
    {
        CustomAlert *alert = [[CustomAlert alloc] initWithTitle:NSLocalizedString(@"LOG OUT", nil) message:NSLocalizedString(@"Êtes-vous sûr de vouloir vous déconnecter ?", nil) delegate:self cancelButtonTitle:@"" otherButtonTitle:@""];
        [APPDELEGATE.window addSubview:alert];
        [APPDELEGATE.window bringSubviewToFront:alert];
        [self.revealViewController rightRevealToggle:self];
        return;
    }
    if ((indexPath.row >3)&&(indexPath.row<(arrSlider.count-2)))
    {
        [self.revealViewController rightRevealToggle:self];
        
        UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
        
        self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
        
        NSDictionary *dictTemp=[arrPage objectAtIndex:indexPath.row-4];
        strContent=[dictTemp valueForKey:@"content"];
        
        [self.ViewObj performSegueWithIdentifier:@"contactus" sender:dictTemp];
        return;
    }
    [self.revealViewController rightRevealToggle:self];
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
    if(self.ViewObj!=nil)
        [self.ViewObj goToSetting:[arrIdentifire objectAtIndex:indexPath.row]];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
    v.backgroundColor=[UIColor clearColor];
    return nil;
}

#pragma mark -
#pragma mark- UIButton Action methods

- (void)onClickProfile:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PROFILE sender:frontVC];
    }
}

- (void)onClickPayment:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PAYMENT sender:frontVC];
    }
}

- (void)onClickPromotions:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PROMOTIONS sender:frontVC];
    }
}

- (void)onClickShare:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_SHARE sender:frontVC];
    }
}

- (void)onClickSupport:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_SUPPORT sender:frontVC];
    }
}

- (void)onClickAbout:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_ABOUT sender:frontVC];
    }
}

#pragma mark custome Alert view :
#pragma mark - Alert Button Clicked Event


- (void)customAlertView:(CustomAlert*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==0)
    {
        NSLog(@"cancel ");
    }
    else{
        NSLog(@"done ");
        
        [PREF removeObjectForKey:PREF_USER_TOKEN];
        [PREF removeObjectForKey:PREF_REQ_ID];
        [PREF removeObjectForKey:PREF_IS_LOGOUT];
        [PREF removeObjectForKey:PREF_USER_ID];
        [PREF removeObjectForKey:PREF_IS_LOGIN];
        [PREF synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}


#pragma mark -alertview

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:[PREF objectForKey:PREF_USER_ID] forKey:PARAM_ID];
            [dictParam setObject:[PREF objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
            
            if([[AppDelegate sharedAppDelegate]connected])
            {
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_LOGOUT withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     if (response)
                     {
                         [PREF removeObjectForKey:PREF_USER_TOKEN];
                         [PREF removeObjectForKey:PREF_REQ_ID];
                         [PREF removeObjectForKey:PREF_IS_LOGOUT];
                         [PREF removeObjectForKey:PREF_USER_ID];
                         [PREF removeObjectForKey:PREF_IS_LOGIN];
                         [PREF synchronize];
                         // [[FacebookUtility sharedObject]logOutFromFacebook];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     }
                 }];
            }
        }
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
