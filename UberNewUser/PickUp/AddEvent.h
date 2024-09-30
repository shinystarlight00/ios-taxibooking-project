//
//  AddEvent.h
//  TaxiNow
//
//  Created by Elluminati Mac Mini 1 on 29/01/16.
//  Copyright © 2016 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AddEvent : UIViewController <UITextFieldDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtEventName;
@property (weak, nonatomic) IBOutlet UITextField *txtEventAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtEventTime;
@property (weak, nonatomic) IBOutlet UITextField *txtEventMembers;
@property (weak, nonatomic) IBOutlet UITextField *txtMaximumAmount;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property (weak, nonatomic) IBOutlet UIView *viewForDateTimePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableForPlaces;


@property (weak, nonatomic) IBOutlet UIButton *btnDateTime;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

- (IBAction)backToEvents:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)pickerAction:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)doneBtnClicked:(id)sender;
- (IBAction)dateTimeBtnClicked:(id)sender;

@end