//
//  HistoryDetailVC.m
//  Rider Driver
//
//  Created by My Mac on 7/8/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "HistoryDetailVC.h"
#import "AFNHelper.h"
#import "UIView+Utils.h"
#import "UIImageView+Download.h"


@interface HistoryDetailVC ()
{
    NSString *strForCancelReason;
}

@end

@implementation HistoryDetailVC
@synthesize type;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewForCancelLaterRequest.hidden = YES;

     [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOADING_HISTORY", nil)];
    self.navigationItem.hidesBackButton = YES;
    if([type isEqualToString:@"future"])
    {
        mapImgView.frame=CGRectMake(0, mapImgView.frame.origin.y, self.view.frame.size.width,mapImgView.frame.size.height-40);
        self.viewForBottom.frame=CGRectMake(0, mapImgView.frame.origin.y+mapImgView.frame.size.height, self.viewForBottom.frame.size.width, self.viewForBottom.frame.size.height);
        self.btnCancelRequest.hidden=NO;
    }
    else
    {
        self.btnCancelRequest.hidden=YES;
    }
    [self setTripDetails];

    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTripDetails
{
    if([type isEqualToString:@"history"])
    {
        self.img3.image=[UIImage imageNamed:@"cash"];
        self.img1.image=[UIImage imageNamed:@"clock_black"];
        self.img2.image=[UIImage imageNamed:@"mile_black"];
        [self.btnNavigationTitle setTitle:@"  History" forState:UIControlStateNormal];
        [lblCost setText:[NSString stringWithFormat:@"%@ %.2f",[self.dictInfo valueForKey:@"currency"],[[self.dictInfo objectForKey:@"total"] floatValue]]];
        [lblMinutes setText:[NSString stringWithFormat:@"%.2f mins",[[self.dictInfo objectForKey:@"time"] floatValue]]];
        [lblDistance setText:[NSString stringWithFormat:@"%.2f kms",[[self.dictInfo objectForKey:@"distance"] floatValue]]];
        [txtSource setText:[NSString stringWithFormat:@"%@",[self.dictInfo objectForKey:@"src_address"]]];
        [txtDestination setText:[NSString stringWithFormat:@"%@",[self.dictInfo objectForKey:@"dest_address"]]];
        [mapImgView downloadFromURL:[self.dictInfo objectForKey:@"map_url"] withPlaceholder:[UIImage imageNamed:@"no_items_display"]];
        
    }
    else if([type isEqualToString:@"future"])
    {
       // [self.img3 applyRoundedCornersFull];
        [self.img3 downloadFromURL:[self.dictInfo objectForKey:@"type_icon"] withPlaceholder:Nil];
        self.img1.image=[UIImage imageNamed:@"img_time_future"];
        self.img2.image=[UIImage imageNamed:@"clock_black"];
        [self.btnNavigationTitle setTitle:@"  Future Request" forState:UIControlStateNormal];
        [txtSource setText:[NSString stringWithFormat:@"%@",[self.dictInfo objectForKey:@"src_address"]]];
        [txtDestination setText:[NSString stringWithFormat:@"%@",[self.dictInfo objectForKey:@"dest_address"]]];
        [mapImgView downloadFromURL:[self.dictInfo objectForKey:@"map_image"] withPlaceholder:[UIImage imageNamed:@"no_items_display"]];
        [lblCost setText:[NSString stringWithFormat:@"%@",[self.dictInfo valueForKey:@"type_name"]]];
        
        NSDate *date1=[[UtilityClass sharedObject] stringToDate:[self.dictInfo valueForKey:@"start_time"]];
        NSString *str=[NSString stringWithFormat:@"%@",[[UtilityClass sharedObject] DateToString:date1 withFormate:@"EE MMMdd hh:mm a"]];
        NSArray *DateTime = [str componentsSeparatedByString:@" "];
        
        [lblDistance setText:[NSString stringWithFormat:@"%@ %@",[DateTime objectAtIndex:2],[DateTime objectAtIndex:3]]];
        [lblMinutes setText:[NSString stringWithFormat:@"%@ %@",[DateTime objectAtIndex:0],[DateTime objectAtIndex:1]]];
        
    }
        
    [APPDELEGATE hideLoadingView];
   
}
#pragma mark -
#pragma mark - Button Action Methods

- (IBAction)btnBackPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickBtnCancelRequest:(id)sender
{
    self.viewForCancelLaterRequest.hidden = NO;
//    if([type isEqualToString:@"future"])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CANCEL_REQUEST", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
//        alert.tag=200;
//        [alert show];
//    }
    
}
-(void)DeleteRequest
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        NSString *request_id=[NSString stringWithFormat:@"%@",[self.dictInfo valueForKey:@"id"]];
        [dictParam setValue:[PREF objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[PREF objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:request_id forKey:PARAM_REQUEST_ID];
        [dictParam setValue:strForCancelReason forKey:@"cancel_reason"];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_DELETE_FUTURE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 else
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     
                     NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                     [alert show];
                 }
             }
             
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }

}
#pragma mark - 
#pragma mark - AlertView delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==200)
    {
        if(buttonIndex == 1)
        {
            [self DeleteRequest];
        }
    }
}
- (IBAction)onClickBtnDelay:(id)sender
{
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    strForCancelReason = @"1";
    NSLog(@"%@",strForCancelReason);
}

- (IBAction)onClickBtnChanged:(id)sender
{
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    strForCancelReason = @"2";
    
    NSLog(@"%@",strForCancelReason);
}

- (IBAction)onClickBookCab:(id)sender
{
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnCheck"] forState:UIControlStateNormal];
    
    strForCancelReason = @"3";
    NSLog(@"%@",strForCancelReason);
}
- (IBAction)onClickOKCancel:(id)sender
{
    if([strForCancelReason isEqualToString:@""])
    {
        [APPDELEGATE showToastMessage:@"Please select at least one reason for cancel the request"];
    }
    else
    {
        [self DeleteRequest];
        self.viewForCancelLaterRequest.hidden = YES;
    }

}
@end
