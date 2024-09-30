//
//  AddEvent.m
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import "AddEvent.h"

@interface AddEvent ()
{
    NSMutableArray *placeMarkArr;
    NSString *strForLatitude,*strForLongitude;
}
@end

@implementation AddEvent

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.txtEventAddress addTarget:self action:@selector(Searching:) forControlEvents:UIControlEventEditingChanged];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [placeMarkArr count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableForPlaces dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if ([placeMarkArr count] > 0)
    {
        [cell.textLabel setText:[[placeMarkArr objectAtIndex:indexPath.row] objectForKey:@"description"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *address = [[placeMarkArr objectAtIndex:indexPath.row] objectForKey:@"description"];
    [self.txtEventAddress setText:address];
    [self.tableForPlaces deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableForPlaces setHidden:YES];
    [self.txtEventAddress resignFirstResponder];
    [self getLocationFromString:address];
}

-(void)getLocationFromString:(NSString *)str
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress=[response valueForKey:@"results"];
             if ([arrAddress count] > 0)
             {
                 
                     //self.txtPickupAddress.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     
                     strForLatitude=[dictLocation valueForKey:@"lat"];
                     strForLongitude=[dictLocation valueForKey:@"lng"];
                     CLLocationCoordinate2D coor;
                     coor.latitude=[strForLatitude doubleValue];
                     coor.longitude=[strForLongitude doubleValue];
                 
                 
             }
         }
     }];
}


#pragma mark- Searching Method

- (IBAction)Searching:(id)sender
{
    [placeMarkArr removeAllObjects];
    self.tableForPlaces.hidden=YES;
    NSString *str = self.txtEventAddress.text;
    if(str == nil)
        self.tableForPlaces.hidden=YES;
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:@"input"]; // AUTOCOMPLETE API
    [dictParam setObject:@"sensor" forKey:@"false"]; // AUTOCOMPLETE API
    [dictParam setObject:GOOGLE_KEY_AUTOCOMPLETE forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewAutoCompletewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             //NSArray *arrAddress=[response valueForKey:@"results"];
             NSArray *arrAddress=[response valueForKey:@"predictions"]; //AUTOCOMPLTE API
             NSLog(@"text :%@",arrAddress);
             
             NSLog(@"AutoCompelete URL: = %@",[[response valueForKey:@"predictions"] valueForKey:@"description"]);
             
             if ([arrAddress count] > 0)
             {
                 self.tableForPlaces.hidden=NO;
                 placeMarkArr=[[NSMutableArray alloc] initWithArray:arrAddress copyItems:YES];
                 //[placeMarkArr addObject:Placemark];
                 [self.tableForPlaces reloadData];
                 if(placeMarkArr.count==0)
                 {
                     self.tableForPlaces.hidden=YES;
                 }
             }
         }
     }];
}

#pragma mark -
#pragma mark - UIButton Action Methods

- (IBAction)backToEvents:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitBtnClicked:(id)sender
{
    if(self.txtEventName.text.length < 1 || self.txtEventAddress.text.length < 1 || self.txtEventTime.text.length < 1 || self.txtEventMembers.text.length < 1 || self.txtMaximumAmount.text.length < 1)
    {
        if(self.txtEventName.text.length < 1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EVENT_NAME", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(self.txtEventAddress.text.length < 1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EVENT_ADDRESS", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
       else if(self.txtEventTime.text.length < 1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EVENT_TIME", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(self.txtEventMembers.text.length < 1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EVENT_MEMBERS", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(self.txtMaximumAmount.text.length < 1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EVENT_MAXIMUM_AMOUNT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        if([[AppDelegate sharedAppDelegate]connected])
        {
            [APPDELEGATE showLoadingWithTitle:@"Loading..."];
            NSString * strForUserId=[PREF objectForKey:PREF_USER_ID];
            NSString * strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:strForUserId forKey:PARAM_ID];
            [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setObject:self.txtEventName.text forKey:PARAM_NAME];
            [dictParam setObject:self.txtEventTime.text forKey:PARAM_START_TIME];
            
            NSTimeZone *localTime = [NSTimeZone systemTimeZone];
            [dictParam setObject:[localTime name] forKey:PARAM_TIME_ZONE];
            [dictParam setObject:self.txtEventMembers.text forKey:PARAM_MEMBERS];
            [dictParam setObject:self.txtMaximumAmount.text forKey:PARAM_AMOUNT];
            [dictParam setObject:self.txtEventAddress.text forKey:PARAM_ADDRESS];
            [dictParam setObject:strForLatitude forKey:PARAM_LATITUDE];
            [dictParam setObject:strForLongitude forKey:PARAM_LONGITUDE];

            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_ADD_EVENT withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if(response)
                 {
                     if([[response valueForKey:@"success"] boolValue])
                     {
                         [APPDELEGATE hideLoadingView];
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                     else
                     {
                         [APPDELEGATE hideLoadingView];
                         NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                         [alert show];
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
}



- (IBAction)cancelBtnClicked:(id)sender
{
    self.viewForDateTimePicker.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnCancel.hidden = YES;
}

- (IBAction)doneBtnClicked:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    NSString *formatedDate = [dateFormatter stringFromDate:self.dateTimePicker.date];
    
    self.txtEventTime.text = formatedDate;

    self.viewForDateTimePicker.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnCancel.hidden = YES;
}

- (IBAction)dateTimeBtnClicked:(id)sender
{
    [self.txtEventAddress resignFirstResponder];
    [self.txtEventMembers resignFirstResponder];
    [self.txtEventName resignFirstResponder];
    [self.txtMaximumAmount resignFirstResponder];
    self.viewForDateTimePicker.hidden = NO;
    self.btnDone.hidden = NO;
    self.btnCancel.hidden = NO;
}

#pragma mark -
#pragma mark - UIDatePicker Value Changed Method

- (IBAction)pickerAction:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];

    NSString *formatedDate = [dateFormatter stringFromDate:self.dateTimePicker.date];

    self.txtEventTime.text = formatedDate;
}

#pragma mark -
#pragma mark - UITextfied Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint offset;
    if(self.viewForDateTimePicker.hidden == NO)
    {
        [self cancelBtnClicked:nil];
    }
    if(textField==self.txtEventMembers)
    {
        offset=CGPointMake(0, 100);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtMaximumAmount)
    {
        offset=CGPointMake(0, 100);
        [self.scrollView setContentOffset:offset animated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint offset;
    offset=CGPointMake(0, -64);
    [self.scrollView setContentOffset:offset animated:YES];
    
    if(textField==self.txtEventName)
        [self.txtEventAddress becomeFirstResponder];
    else if (textField==self.txtEventMembers)
        [self.txtMaximumAmount becomeFirstResponder];

    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end