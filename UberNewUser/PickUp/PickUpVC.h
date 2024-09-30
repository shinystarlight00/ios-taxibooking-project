//
//  PickUpVC.h
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "iCarousel.h"

@interface PickUpVC : BaseVC<MKMapViewDelegate,CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,GMSMapViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,iCarouselDataSource,iCarouselDelegate>
{
    NSTimer *timerForCheckReqStatus;
    CLLocationManager *locationManager;
    NSDictionary* aPlacemark;
    NSMutableArray *placeMarkArr;
    NSInteger currentIndex;
    NSArray* routes;
    GMSMarker *client_marker,*destination_marker;
}
@property(nonatomic,weak)IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *img_driver_profile;
@property (weak, nonatomic) IBOutlet UIImageView *img_cash_sign;
@property (weak, nonatomic) IBOutlet UIImageView *img_card_sign;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@property (weak, nonatomic) IBOutlet UITableView *tableForCity;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableforCityFare;
@property (weak, nonatomic) IBOutlet UITableView *tblPlaces;

@property (weak, nonatomic) IBOutlet UIView *viewGoogleMap;
@property (weak, nonatomic) IBOutlet UIView *viewForMarker;
@property (weak, nonatomic) IBOutlet UIView *viewForPreferral;
@property (weak, nonatomic) IBOutlet UIView *viewForFareAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForReferralError;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet UIView *viewForDriver;
@property (weak, nonatomic) IBOutlet UIView *fareView;
@property (weak, nonatomic) IBOutlet UIView *getFareView;
@property (weak, nonatomic) IBOutlet UIView *viewForPromoPayment;
@property (weak, nonatomic) IBOutlet UIView *viewForRequestType;
@property (weak, nonatomic) IBOutlet UIView *viewForDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePicker;

@property (weak, nonatomic) IBOutlet UIButton* revealButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnMyLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnETA;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnPickMeUp;
@property (weak, nonatomic) IBOutlet UIButton *btnCash;
@property (weak, nonatomic) IBOutlet UIButton *btnCard;
@property (weak, nonatomic) IBOutlet UIButton *btnFare;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnPayCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnPayRequest;
@property (weak, nonatomic) IBOutlet UIButton *bReferralSubmit;
@property (weak, nonatomic) IBOutlet UIButton *bReferralSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnGetFare;
@property (weak, nonatomic) IBOutlet UIButton *btnHomeEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnWorkEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnHomeGetFare;
@property (weak, nonatomic) IBOutlet UIButton *btnWorkGetFare;
@property (weak, nonatomic) IBOutlet UIButton *btnRidelater;
@property (weak, nonatomic) IBOutlet UIButton *btnRidenow;
@property (weak, nonatomic) IBOutlet UIButton *btnViewClose;



@property (weak, nonatomic) IBOutlet UITextField *txtPreferral;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtDestination;
@property (weak, nonatomic) IBOutlet UITextField *txtDestiSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtHome;
@property (weak, nonatomic) IBOutlet UITextField *txtWork;
@property (weak, nonatomic) IBOutlet UITextField *txtPromoCode;
@property (weak, nonatomic) IBOutlet UITextField *txtPickupAddress;

@property (weak, nonatomic) IBOutlet UILabel *lblFareAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblReferralMsg;
@property (weak, nonatomic) IBOutlet UILabel *lSelectPayment;
@property (weak, nonatomic) IBOutlet UILabel *lRefralMsg;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driverName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driverRate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driver_Carname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driver_CarNumber;
@property (weak, nonatomic) IBOutlet UILabel *lMinFare;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;
@property (weak, nonatomic) IBOutlet UILabel *lMaxSize;
@property (weak, nonatomic) IBOutlet UILabel *lblPerKm;
@property (weak, nonatomic) IBOutlet UILabel *lblEstiMin;
@property (weak, nonatomic) IBOutlet UILabel *lblMin_fare;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeCost;
@property (weak, nonatomic) IBOutlet UILabel *llbServiceNmae;
@property (weak, nonatomic) IBOutlet UILabel *lblMinTime1;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceType;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedDate;

/////// Actions
- (IBAction)pickMeUpBtnPressed:(id)sender;
- (IBAction)OnClickCloseViewBtn:(id)sender;
- (IBAction)cancelReqBtnPressed:(id)sender;
- (IBAction)myLocationPressed:(id)sender;
- (IBAction)ETABtnPressed:(id)sender;
- (IBAction)cashBtnPressed:(id)sender;
- (IBAction)cardBtnPressed:(id)sender;
- (IBAction)btnSkipReferral:(id)sender;
- (IBAction)btnAddReferral:(id)sender;
- (IBAction)onClickForGetFare:(id)sender;
- (IBAction)onClickForCancel:(id)sender;
- (IBAction)SearchingDsti:(id)sender;
- (IBAction)SearcingHome:(id)sender;
- (IBAction)searchingWork:(id)sender;
- (IBAction)onClickWorkGetFare:(id)sender;
- (IBAction)onClickHomeGetFare:(id)sender;
- (IBAction)onClickHomeEdit:(id)sender;
- (IBAction)onClickWorkEdit:(id)sender;
- (IBAction)OnClickForCancelFareView:(id)sender;
- (IBAction)OnClickRidenowBtn:(id)sender;
- (IBAction)OnClickRidelaterBtn:(id)sender;
- (IBAction)OnClickScheduleCloseBtn:(id)sender;
- (IBAction)OnClickBtnScheduleTripBtn:(id)sender;

-(void)goToSetting:(NSString *)str;
@property (strong, nonatomic) IBOutlet UIView *viewForCancelLaterRequest;
@property (strong, nonatomic) IBOutlet UIButton *btnOneCheck;
@property (strong, nonatomic) IBOutlet UIButton *btnTwoCheck;
@property (strong, nonatomic) IBOutlet UIButton *btnThreeCheck;
- (IBAction)onClickOKCancel:(id)sender;

- (IBAction)onClickBtnDelay:(id)sender;

- (IBAction)onClickBtnChanged:(id)sender;
- (IBAction)onClickBookCab:(id)sender;

@end
