//
//  EventDetails.m
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import "EventDetails.h"

@interface EventDetails ()

@end

@implementation EventDetails

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden=NO;

    NSLog(@"details = %@",self.dictDetails);

    self.lblEventName.text = [self.dictDetails valueForKey:@"event_name"];
    self.lblEventAddress.text = [self.dictDetails valueForKey:@"event_place_address"];
    self.lblEventDateTime.text = [self.dictDetails valueForKey:@"start_time"];
    self.lblEventMembers.text = [self.dictDetails valueForKey:@"event_total_members"];
    self.lblMaximumAmount.text = [self.dictDetails valueForKey:@"event_pre_pay_for_each_member"];
    self.lblEventPromo.text = [self.dictDetails valueForKey:@"promo_code"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark - UIButton Action Methods

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end