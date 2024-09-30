//
//  EventsCell.h
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblEventName;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEventAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end