//
//  BookingCell.h
//  TaxiNow
//
//  Created by Sapana Ranipa on 05/11/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookingCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *imgBackGround;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;


@end
