//
//  ProfileVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVBase.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"
#import "UberStyleGuide.h"

@interface ProfileVC ()
{
    NSString *strForUserId,*strForUserToken;
}

@end

@implementation ProfileVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self SetLocalization];
    [self setDataForUserInfo];
    //[self customFont];
    [self.proPicImgv applyRoundedCornersFullWithColor:[UIColor clearColor]];
    [self.btnUpdate setSelected:NO];
    [self textDisable];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.scrollv.contentSize=CGSizeMake(320,550);
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.btnNavigation setTitle:NSLocalizedString(@"Profile", nil) forState:UIControlStateNormal];
}
-(void)SetLocalization
{
    self.txtEmail.placeholder=NSLocalizedString(@"email", nil);
    self.txtPhone.placeholder=NSLocalizedString(@"phone", nil);
    self.txtCurrentPWD.placeholder=NSLocalizedString(@"current password", nil);
    self.txtNewPWD.placeholder=NSLocalizedString(@"new password", nil);
    self.txtConformPWD.placeholder=NSLocalizedString(@"confirm  password", nil);
}
-(void)setDataForUserInfo
{
    NSMutableDictionary *dictInfo=[PREF objectForKey:PREF_LOGIN_OBJECT];
    
    [self.proPicImgv downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    self.txtName1.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
    self.txtName.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
    self.txtEmail.text=[dictInfo valueForKey:@"email"];
    self.txtPhone.text=[dictInfo valueForKey:@"phone"];
}
#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark -
#pragma mark - UIButton Action Methods

- (IBAction)WritingName:(id)sender
{
    self.txtName1.text=self.txtName.text;
}

- (IBAction)selectPhotoBtnPressed:(id)sender
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIActionSheet *actionpass;
    
    actionpass = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SELECT_PHOTO", @""),NSLocalizedString(@"TAKE_PHOTO", @""),nil];
    actionpass.delegate=self;
    [actionpass showInView:window];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateBtnPressed:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if(btn.isSelected==NO)
    {
        [btn setSelected:YES];
        [self textEnable];
        //[self.txtName becomeFirstResponder];
        [APPDELEGATE showToastMessage:@"You Can Edit Your Profile"];
    }
    else
    {
        if (self.txtNewPWD.text.length > 0 || self.txtConformPWD.text.length > 0)
        {
            if ([self.txtNewPWD.text isEqualToString:self.txtConformPWD.text])
            {
                [self updateProfile];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Profile Update Fail" message:NSLocalizedString(@"NOT_MATCH_RETYPE",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else
        {
            [self updateProfile];
        }
    }
}
-(void)updateProfile
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if([[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
        {
            
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"EDITING", nil)];
            
            strForUserId=[PREF objectForKey:PREF_USER_ID];
            strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];

            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            NSArray *ar=[self.txtName.text componentsSeparatedByString:@" "];

            if(ar.count>1)
            {
                [dictParam setValue:[ar objectAtIndex:0] forKey:PARAM_FIRST_NAME];
                [dictParam setValue:[ar objectAtIndex:1] forKey:PARAM_LAST_NAME];
            }
            else
            {
                [dictParam setValue:[ar objectAtIndex:0] forKey:PARAM_FIRST_NAME];
                [dictParam setValue:@"" forKey:PARAM_LAST_NAME];
                
            }

            [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            [dictParam setValue:self.txtPhone.text forKey:PARAM_PHONE];
            [dictParam setValue:self.txtCurrentPWD.text forKey:PARAM_OLD_PASSWORD];
            [dictParam setValue:self.txtNewPWD.text forKey:PARAM_NEW_PASSWORD];
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            
            [dictParam setValue:@"" forKey:PARAM_ADDRESS];
            [dictParam setValue:@"" forKey:PARAM_STATE];
            [dictParam setValue:@"" forKey:PARAM_COUNTRY];
            [dictParam setValue:@"" forKey:PARAM_ZIPCODE];
            [dictParam setValue:@"" forKey:PARAM_BIO];
            
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.proPicImgv.image];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_UPADTE withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
                
                [[AppDelegate sharedAppDelegate]hideLoadingView];
                if (response)
                {
                    if([[response valueForKey:@"success"] boolValue])
                    {
                        [APPDELEGATE showLoadingWithTitle:@"Updating  Profile"];
                        [PREF setObject:response forKey:PREF_LOGIN_OBJECT];
                        [PREF synchronize];
                        [self setDataForUserInfo];
                        [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_EDIT_SUCESS", nil)];
                        [self textDisable];
                        [self.btnUpdate setSelected:NO];
                        self.txtConformPWD.text=@"";
                        self.txtCurrentPWD.text=@"";
                        self.txtNewPWD.text=@"";
                         [self.navigationController popViewControllerAnimated:YES];
                        [APPDELEGATE hideLoadingView];
                    }
                    else
                    {
                        
                        NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        [alert show];
                       
                    }
                }
                
                NSLog(@"REGISTER RESPONSE --> %@",response);
            }];
        }
        
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }


}
#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtName.font=[UberStyleGuide fontRegular];
    self.txtPhone.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtCurrentPWD.font=[UberStyleGuide fontRegular];
    self.txtNewPWD.font=[UberStyleGuide fontRegular];
    self.txtConformPWD.font=[UberStyleGuide fontRegular];
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
}
-(void)textDisable
{
    self.txtName.enabled=NO;
    self.txtEmail.enabled = NO;
    self.txtPhone.enabled = NO;
    self.txtConformPWD.enabled=NO;
    self.txtCurrentPWD.enabled=NO;
    self.txtNewPWD.enabled=NO;
    self.btnProPic.enabled=NO;
}
-(void)textEnable
{
    self.txtName.enabled=YES;
    self.txtEmail.enabled = YES;
    self.txtPhone.enabled = YES;
    self.txtConformPWD.enabled=YES;
    self.txtCurrentPWD.enabled=YES;
    self.txtNewPWD.enabled=YES;
    self.btnProPic.enabled=YES;
}
#pragma mark
#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            [self takePhoto];
        }
            break;
        case 0:
        {
            [self selectPhotos];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark - Action to Share


- (void)selectPhotos
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

-(void)takePhoto
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([info valueForKey:UIImagePickerControllerEditedImage]==nil)
    {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//
            UIImage *img=[UIImage imageWithData:data];
            [self setImage:img];
        } failureBlock:^(NSError *err) {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }
    else
    {
        [self setImage:[info valueForKey:UIImagePickerControllerEditedImage]];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)setImage:(UIImage *)image
{
    self.proPicImgv.image=image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark
#pragma mark - UItextField Delegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint offset;
    if(textField==self.txtName)
    {
        offset=CGPointMake(0, 80);
        [self.scrollv setContentOffset:offset animated:YES];
        
    }
    else if (textField==self.txtCurrentPWD)
    {
        offset=CGPointMake(0, 200);
        [self.scrollv setContentOffset:offset animated:YES];
    }
    else if(textField ==self.txtNewPWD)
    {
        offset=CGPointMake(0, 240);
        [self.scrollv setContentOffset:offset animated:YES];
    }
    else if(textField ==self.txtConformPWD)
    {
        offset=CGPointMake(0, 280);
        [self.scrollv setContentOffset:offset animated:YES];

    }
    else if(textField == self.txtPhone)
    {
        offset=CGPointMake(0, 320);
        [self.scrollv setContentOffset:offset animated:YES];
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint offset;
    if (textField==self.txtPhone)
    {
        offset=CGPointMake(0, 0);
        [self.scrollv setContentOffset:offset animated:YES];
        [self.txtPhone resignFirstResponder];
        
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.txtName)
    {
        [self.txtCurrentPWD becomeFirstResponder];
    }
    if (textField==self.txtCurrentPWD)
    {
        [self.txtNewPWD becomeFirstResponder];
    }
    if (textField==self.txtNewPWD)
    {
        [self.txtConformPWD becomeFirstResponder];
    }
    if (textField==self.txtConformPWD)
    {
        [self.txtPhone becomeFirstResponder];
    }
    if (textField==self.txtPhone)
    {
        [textField resignFirstResponder];
        
    }
    //[textField resignFirstResponder];
    return YES;
}

@end
