//
//  FeedBackVC.m
//  UberNewUser
//
//  Created by Deep Gami on 01/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "FeedBackVC.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import "PickUpVC.h"
#import "UberStyleGuide.h"

@interface FeedBackVC ()

@end

@implementation FeedBackVC

#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self SetLocalization];
    self.navigationController.navigationBarHidden=NO;
    NSArray *arrName=[self.strFirstName componentsSeparatedByString:@" "];
    self.lblFirstName.text=[arrName objectAtIndex:0];
    self.lblLastName.text=[arrName objectAtIndex:1];
    //self.lblDistance.text=[NSString stringWithFormat:@"%.2f",[[self.dictWalkInfo valueForKey:@"distance"] floatValue]];
   // self.lblTIme.text=[self.dictWalkInfo valueForKey:@"time"];
    
    self.lblDistance.text=[NSString stringWithFormat:@"%.2f %@",[[dictBillInfo valueForKey:@"distance"] floatValue],[dictBillInfo valueForKey:@"unit"]];
    self.lblTIme.text=[NSString stringWithFormat:@"%.2f %@",[[dictBillInfo valueForKey:@"time" ] floatValue],NSLocalizedString(@"Mins", nil)];

    [self.imgUser applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self.imgUser downloadFromURL:self.strUserImg withPlaceholder:nil];
    self.viewForBill.hidden=NO;
    self.txtComments.text=NSLocalizedString(@"COMMENT", nil);
    //[self.btnFeedBack setTitle:@"  Invoice" forState:UIControlStateNormal];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setPriceValue];
    [self customSetup];

}
- (void)viewDidAppear:(BOOL)animated
{
   // [self customSetup];
    [[AppDelegate sharedAppDelegate] hideLoadingView];
    [self.btnFeedBack setTitle:NSLocalizedString(@"Feedback", nil) forState:UIControlStateNormal];
}
-(void)SetLocalization
{
    self.lblInvoice.text=NSLocalizedString(@"Invoice", nil);
    self.lBasePrice.text=NSLocalizedString(@"BASE PRICE", nil);
    self.lDistanceCost.text=NSLocalizedString(@"DISTANCE COST", nil);
    self.lTimeCost.text=NSLocalizedString(@"TIME COST", nil);
    self.lPromoBonus.text=NSLocalizedString(@"PROMO BOUNCE", nil);
    self.lreferalBonus.text=NSLocalizedString(@"REFERRAL BOUNCE", nil);
    self.lTotalCost.text=NSLocalizedString(@"Total Due", nil);
    self.lComment.text=NSLocalizedString(@"COMMENT1", nil);
}
- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.btnFeedBack addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

#pragma mark-
#pragma mark- Set Invoice Details

-(void)setPriceValue
{
    self.lblBasePrice.text=[NSString stringWithFormat:@"€ %.2f",[[dictBillInfo valueForKey:@"base_price"] floatValue]];
    self.lblDistCost.text=[NSString stringWithFormat:@"€ %.2f",[[dictBillInfo valueForKey:@"distance_cost"] floatValue]];
    self.lblTimeCost.text=[NSString stringWithFormat:@"€ %.2f",[[dictBillInfo valueForKey:@"time_cost"] floatValue]];
    self.lblTotal.text=[NSString stringWithFormat:@"€ %.2f",[[dictBillInfo valueForKey:@"total"] floatValue]];
    self.lblRferralBouns.text=[NSString stringWithFormat:@"€ %.2f",[[dictBillInfo valueForKey:@"referral_bonus"] floatValue]];
    self.lblPromoBouns.text=[NSString stringWithFormat:@"€ %.2f",[[dictBillInfo valueForKey:@"promo_bonus"] floatValue]];
    self.lblDistance.text=[NSString stringWithFormat:@"%.2f %@",[[dictBillInfo valueForKey:@"distance"] floatValue],[dictBillInfo valueForKey:@"unit"]];
    float totalDist=[[dictBillInfo valueForKey:@"distance_cost"] floatValue];
    float Dist=[[dictBillInfo valueForKey:@"distance"]floatValue];
    
    if ([[dictBillInfo valueForKey:@"unit"]isEqualToString:@"kms"])
    {
        totalDist=totalDist*0.621317;
        Dist=Dist*0.621371;
    }
    if(Dist!=0)
    {
        self.lblPerDist.text=[NSString stringWithFormat:@"€%.2f %@",(totalDist/Dist),NSLocalizedString(@"per mile", nil)];
    }
    else
    {
        self.lblPerDist.text=[NSString stringWithFormat:@"€0 %@",NSLocalizedString(@"per mile", nil)];
    }
    
    float totalTime=[[dictBillInfo valueForKey:@"time_cost"] floatValue];
    float Time=[[dictBillInfo valueForKey:@"time"]floatValue];
    if(Time!=0)
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"€%.2f %@",(totalTime/Time),NSLocalizedString(@"per mins", nil)];
    }
    else
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"€0 %@",NSLocalizedString(@"per mins", nil)];
    }
}
#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.lblDistance.font=[UberStyleGuide fontRegularLight:20.70f];
    self.lblDistCost.font=[UberStyleGuide fontRegularLight:20.70f];
    self.lblBasePrice.font=[UberStyleGuide fontRegularLight:20.70f];
    self.lblDistance.font=[UberStyleGuide fontRegular:15.0f];
    self.lblPerDist.font=[UberStyleGuide fontRegularLight:10.30f];
    self.lblPerTime.font=[UberStyleGuide fontRegularLight:10.30f];
    self.lblTIme.font=[UberStyleGuide fontRegular:15.0f];
    self.lblTimeCost.font=[UberStyleGuide fontRegularLight:20.70f];
    self.lblTotal.font=[UberStyleGuide fontRegular:42.0f];
    self.lblFirstName.font=[UberStyleGuide fontRegularLight:20.0f];
    self.lblLastName.font=[UberStyleGuide fontRegularLight:20.0f];
   // self.btnFeedBack.titleLabel.font=[UberStyleGuide fontRegularLight:20.0f];
    self.btnFeedBack=[APPDELEGATE setBoldFontDiscriptor:self.btnFeedBack];
    self.btnSubmit=[APPDELEGATE setBoldFontDiscriptor:self.btnSubmit];

    self.lblPromoBouns.font=[UberStyleGuide fontRegularLight:20.70f];
    self.lblRferralBouns.font=[UberStyleGuide fontRegularLight:20.70f];
    self.btnConfirm.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.btnSubmit.titleLabel.font=[UberStyleGuide fontRegularBold];
    
    self.lBasePrice.font = [UberStyleGuide fontRegularLight];
    self.lDistanceCost.font = [UberStyleGuide fontRegularLight];
    self.lTimeCost.font = [UberStyleGuide fontRegularLight];
    self.lreferalBonus.font = [UberStyleGuide fontRegularLight];
    self.lPromoBonus.font = [UberStyleGuide fontRegularLight];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-
#pragma makr- Btn Click Events

- (IBAction)onClickBackBtn:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)submitBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REVIEWING", nil)];
        
        [self.txtComments resignFirstResponder];
        RBRatings rating=[ratingView getcurrentRatings];
        float rate=rating/2.0;
        if (rating%2 != 0)
        {
            rate += 0.5;
        }
        if(rate==0)
        {
            [[AppDelegate sharedAppDelegate] hideLoadingView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"PLEASE_RATE", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
        }
        else
        {
            NSString *strForUserId=[PREF objectForKey:PREF_USER_ID];
            NSString *strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
            NSString *strReqId=[PREF objectForKey:PREF_REQ_ID];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:strForUserId forKey:PARAM_ID];
            [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setObject:strReqId forKey:PARAM_REQUEST_ID];
            [dictParam setObject:[NSString stringWithFormat:@"%f",rate] forKey:PARAM_RATING];
            NSString *commt=self.txtComments.text;
            if([commt isEqualToString:NSLocalizedString(@"COMMENT", nil)])
            {
                [dictParam setObject:@"" forKey:PARAM_COMMENT];
            }
            else
            {
                [dictParam setObject:self.txtComments.text forKey:PARAM_COMMENT];
            }
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_RATE_DRIVER withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 NSLog(@"%@",response);
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"RATING", nil)];
                         [PREF removeObjectForKey:PREF_REQ_ID];
                         
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     }
                 }
                 
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
             }];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark - UITextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, -150, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        
    } completion:^(BOOL finished)
     {
     }];
  
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)confirmBtnPressed:(id)sender
{
    [self.btnFeedBack setTitle:@"  Feedback" forState:UIControlStateNormal];
    self.viewForBill.hidden=YES;
    self.navigationController.navigationBarHidden=NO;

    ratingView=[[RatingBar alloc] initWithSize:CGSizeMake(120, 20) AndPosition:CGPointMake(100, 195)];
    ratingView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:ratingView];
}

#pragma mark-
#pragma mark- Text Field Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtComments resignFirstResponder];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.txtComments.text=@"";
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComments)
            {
                UITextPosition *beginning = [self.txtComments beginningOfDocument];
                [self.txtComments setSelectedTextRange:[self.txtComments textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComments)
            {
                UITextPosition *beginning = [self.txtComments beginningOfDocument];
                [self.txtComments setSelectedTextRange:[self.txtComments textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
        }
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComments)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComments)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
        }
    }
    if ([self.txtComments.text isEqualToString:@""])
    {
        self.txtComments.text=NSLocalizedString(@"COMMENT", nil);
    }
    
}

#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
