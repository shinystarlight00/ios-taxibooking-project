//
//  DisplayCardVC.h
//  UberforXOwner
//
//  Created by Deep Gami on 17/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import "PTKCard.h"
#import "PTKView.h"
#import "Stripe.h"
#import "PTKTextField.h"

@interface DisplayCardVC : BaseVC<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PTKViewDelegate>
{
    NSString *strForID;
    NSString *strForToken;
    NSString *strForStripeToken,*strForLastFour;
    
    NSInteger cardTag;


}
- (IBAction)addCardBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet PTKView *paymentView;

//- (void)createBackendChargeWithToken:(STPToken *)token;

- (IBAction)backBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblNoCards;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoItems;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
- (IBAction)onClickforHidePview:(id)sender;

- (IBAction)scanBtnPressed:(id)sender;
- (IBAction)addPaymentBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtCreditCard;
@property (weak, nonatomic) IBOutlet UITextField *txtCvv;
@property (weak, nonatomic) IBOutlet UITextField *txtmm;
@property (weak, nonatomic) IBOutlet UITextField *txtyy;

@property (weak, nonatomic) IBOutlet UIView *pvew;
@property (weak, nonatomic) IBOutlet UIView *deleteCardView;
- (IBAction)onClickForCancelDeleteCardView:(id)sender;
- (IBAction)onClickForDeleteCard:(id)sender;

- (IBAction)onClcikForHideDeleteView:(id)sender;
@end
