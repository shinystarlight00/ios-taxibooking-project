//
//  BookingVC.h
//  TaxiNow
//
//  Created by Sapana Ranipa on 04/11/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface BookingVC : BaseVC <UITableViewDelegate,UITableViewDataSource>
{

}
@property (weak, nonatomic) IBOutlet UITableView *tableForBooking;


- (IBAction)BackBtnPressed:(id)sender;

@end
