//
//  EventsVC.h
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface EventsVC : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewForEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEvent;

- (IBAction)addEventBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;

@end