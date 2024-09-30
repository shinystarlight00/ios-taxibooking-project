//
//  BookingVC.m
//  TaxiNow
//
//  Created by Sapana Ranipa on 04/11/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "BookingVC.h"
#import "AppDelegate.h"
#import "BookingCell.h"
#import "HistoryDetailVC.h"
#import "ProviderDetailsVC.h"

@interface BookingVC ()
{
    NSMutableArray *allData,*presentData,*futureData;
}

@end

@implementation BookingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden=NO;
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    allData=[[NSMutableArray alloc] init];
    presentData=[[NSMutableArray alloc] init];
    futureData=[[NSMutableArray alloc] init];
    [self getRequests];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-
#pragma mark- Get History API Method

-(void)getRequests
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [APPDELEGATE showLoadingWithTitle:@"Loading..."];
        NSString * strForUserId=[PREF objectForKey:PREF_USER_ID];
        NSString * strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:strForUserId forKey:PARAM_ID];
        [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_GETALLREQUESTS withParamData:dictParam withBlock:^(id response, NSError *error)
        {
            if(response)
            {
                if([[response valueForKey:@"success"] boolValue])
                {
                    [APPDELEGATE hideLoadingView];
                    
                    NSMutableArray *arrFuture=[response valueForKey:@"all_scheduled_requests"];
                    for (int i=0 ; i<arrFuture.count; i++)
                    {
                        NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:[arrFuture objectAtIndex:i]];
                        [dict setObject:@"future" forKey:@"type"];
                        [futureData addObject:dict];
                    }
                    
                    NSMutableArray *arrPresent=[response valueForKey:@"requests"];
                    for (int i=0 ; i<arrPresent.count; i++)
                    {
                        NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:[arrPresent objectAtIndex:i]];
                        [dict setObject:@"progress" forKey:@"type"];
                        [presentData addObject:dict];
                    }
                    [self setData];
                }
                else
                {
                    [APPDELEGATE hideLoadingView];
                }
            }
        }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)setData
{
    if(presentData.count>0)
    {
        for (int i=0; i<presentData.count; i++)
        {
            [allData addObject:[presentData objectAtIndex:i]];
        }
    }
    if(futureData.count>0)
    {
        for (int i=0; i<futureData.count; i++)
        {
            [allData addObject:[futureData objectAtIndex:i]];
        }
    }
    [self.tableForBooking reloadData];
}

#pragma mark - 
#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookingCell *cell= [self.tableForBooking dequeueReusableCellWithIdentifier:@"BookingCell" forIndexPath:indexPath];
    
    NSMutableDictionary *dictData=[allData objectAtIndex:indexPath.row];
    
    if([[dictData objectForKey:@"type"]isEqualToString:@"future"])
    {
        NSDate *date1=[[UtilityClass sharedObject] stringToDate:[dictData valueForKey:@"start_time"]];
        
        cell.imgBackGround.image=[UIImage imageNamed:@"bg_futureCell"];
        cell.imgTime.image=[UIImage imageNamed:@"img_time_future"];
        cell.imgAddress.image=[UIImage imageNamed:@"img_address_future"];
        cell.lblTitle.text=@"Trip has yet to start";
        cell.lblTime.text=[NSString stringWithFormat:@"%@",[[UtilityClass sharedObject] DateToString:date1 withFormate:@"EE MMMdd hh:mm a"]];
        cell.lblAddress.text=[NSString stringWithFormat:@"%@",[dictData valueForKey:@"src_address"]];
    }
    else if([[dictData objectForKey:@"type"]isEqualToString:@"progress"])
    {
        // this code for progress
        cell.imgBackGround.image=[UIImage imageNamed:@"bg_progressCell"];
        cell.imgTime.image=[UIImage imageNamed:@"img_time_progress"];
        cell.imgAddress.image=[UIImage imageNamed:@"img_address_progress"];
        cell.lblTitle.text=@"Trip is in progress";
        cell.lblTime.text=[NSString stringWithFormat:@"Today %@",[[UtilityClass sharedObject] DateToString:[NSDate date] withFormate:@"hh:mm a"]];
        cell.lblAddress.text=[NSString stringWithFormat:@"%@",[dictData valueForKey:@"src_address"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictData=[allData objectAtIndex:indexPath.row];
    if([[dictData objectForKey:@"type"]isEqualToString:@"future"])
    {
        [self performSegueWithIdentifier:@"segueToFutureRequest" sender:dictData];
    }
    else if([[dictData objectForKey:@"type"]isEqualToString:@"progress"])
    {
        [self performSegueWithIdentifier:@"segueToProgressRequest" sender:dictData];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueToFutureRequest"])
    {
        HistoryDetailVC *history = [segue destinationViewController];
        history.dictInfo = sender;
        history.type=@"future";
    }
    if ([[segue identifier] isEqualToString:@"segueToProgressRequest"])
    {
        ProviderDetailsVC *obj=[segue destinationViewController];
        obj.requestData=sender;
        obj.strRequestType=@"RideLater";
    }
}

#pragma mark -
#pragma mark - UIButton Action Methods 

- (IBAction)BackBtnPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
