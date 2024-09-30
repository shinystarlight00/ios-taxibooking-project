//
//  RegisterVC.h
//  Uber
//
//  Created by Elluminati - macbook on 23/06/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"

@interface RegisterVC : BaseVC<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>
{
    
}

///// Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtBio;
@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UIButton *btnProPic;
@property (weak, nonatomic) IBOutlet UIView *viewForPicker;
@property (weak, nonatomic) IBOutlet UIImageView *imgProPic;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *viewForEmailInfo;


- (IBAction)onClcikForBack:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *btnTerms;

@property (weak, nonatomic) IBOutlet UIButton *btnSelectCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnTerm;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

/////// labels

@property (weak, nonatomic) IBOutlet UILabel *lblEmailInfo;

////// Actions
- (IBAction)pickerCancelBtnPressed:(id)sender;
- (IBAction)pickerDoneBtnPressed:(id)sender;

- (IBAction)fbbtnPressed:(id)sender;
- (IBAction)proPicBtnPressed:(id)sender;
- (IBAction)cameraBtnPressed:(id)sender;
- (IBAction)selectCountryBtnPressed:(id)sender;

- (IBAction)googleBtnPressed:(id)sender;
- (IBAction)nextBtnPressed:(id)sender;
- (IBAction)btnEmailInfoClick:(id)sender;

- (IBAction)checkBoxBtnPressed:(id)sender;
- (IBAction)termsBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnNav_Register;


@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextField *txtCode;


@end
