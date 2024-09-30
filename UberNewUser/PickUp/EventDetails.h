//
//  EventDetails.h
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface EventDetails : BaseVC

@property (weak,nonatomic) NSMutableDictionary *dictDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblEventName;
@property (weak, nonatomic) IBOutlet UILabel *lblEventAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEventMembers;
@property (weak, nonatomic) IBOutlet UILabel *lblMaximumAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblEventPromo;

- (IBAction)backBtnPressed:(id)sender;

@end