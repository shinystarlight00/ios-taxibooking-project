//
//  EventsVC.m
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import "EventsVC.h"
#import "EventsCell.h"
#import "EventDetails.h"

@interface EventsVC ()
{
    NSMutableArray *arrForEvents;
}

@end

@implementation EventsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden=NO;
    arrForEvents = [[NSMutableArray alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getEvents];
}

#pragma mark -
#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrForEvents.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventsCell *cell= [self.tableViewForEvents dequeueReusableCellWithIdentifier:@"EventsCell" forIndexPath:indexPath];
    cell.lblEventName.text = [[arrForEvents objectAtIndex:indexPath.row] valueForKey:@"event_name"];
    cell.lblEventDateTime.text = [[arrForEvents objectAtIndex:indexPath.row] valueForKey:@"start_time"];
    cell.lblEventAddress.text = [[arrForEvents objectAtIndex:indexPath.row] valueForKey:@"event_place_address"];
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictData=[arrForEvents objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueToEventsDetails" sender:dictData];
}

#pragma mark -
#pragma mark - API Methods

-(void)getEvents
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
        [afn getDataFromPath:FILE_GET_EVENTS withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if(response)
             {
                 if([[response valueForKey:@"success"] boolValue])
                 {
                     [APPDELEGATE hideLoadingView];
                     arrForEvents = [[response valueForKey:@"all_scheduled_requests"] mutableCopy];
                     [self.tableViewForEvents reloadData];
                 }
                 else
                 {
                     [APPDELEGATE hideLoadingView];
                 }
             }
             else
             {
                 [APPDELEGATE hideLoadingView];
             }
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)deleteCell:(UIButton*)sender
{
    NSDictionary *dictEvent = [arrForEvents objectAtIndex:sender.tag];
    
    if ([APPDELEGATE connected])
    {
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        [dictParam setValue:[PREF valueForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[PREF valueForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[dictEvent valueForKey:PARAM_ID] forKey:PARAM_EVENT_ID];
        
        AFNHelper *helper = [[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [helper getDataFromPath:FILE_DELETE_EVENT withParamData:dictParam withBlock:^(id response, NSError *error)
        {
            if (response)
            {
                if ([[response valueForKey:@"success"]boolValue])
                {
                    [arrForEvents removeObjectAtIndex:sender.tag];
                    [self.tableViewForEvents reloadData];
                }
                else
                {
                    NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[helper getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else
            {}
        }];
    }
    else
    {}
}

#pragma mark -
#pragma mark - UIButton Action Methods

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addEventBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"segueToAddEvent" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueToEventsDetails"])
    {
        EventDetails *event = [segue destinationViewController];
        event.dictDetails = sender;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end