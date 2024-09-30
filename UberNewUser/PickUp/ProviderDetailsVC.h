//
//  ProviderDetailsVC.h
//  UberNewUser
//
//  Created by Deep Gami on 29/10/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import "MapView.h"
#import "Place.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <GoogleMaps/GoogleMaps.h>

@class RatingBar;

@interface ProviderDetailsVC : BaseVC<MKMapViewDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    UIImageView* routeView;
    NSArray* routes;
    UIColor* lineColor;
    NSDictionary* aPlacemark;
    NSMutableArray *placeMarkArr;
    GMSMarker *markerOwner,*markerDriver;
    CLLocationManager *locationManager;
    NSMutableDictionary *requestData;
}
@property (strong,nonatomic)NSString *strRequestType;
@property (strong ,nonatomic)NSMutableDictionary *requestData;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (strong , nonatomic) NSTimer *timerForCheckReqStatuss;
@property (strong , nonatomic) NSTimer *timerForTimeAndDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIView *viewForCancelReason;

@property (weak, nonatomic) IBOutlet UIButton *revealBtnItem;
@property (weak, nonatomic) IBOutlet UILabel *lblRateValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgForDriverProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnMin;
@property (weak, nonatomic) IBOutlet UIButton *btnDistance;
@property (nonatomic,strong) NSString *strForLatitude;
@property (nonatomic,strong) NSString *strForLongitude;
@property (nonatomic,strong) NSString *strForWalkStatedLatitude;
@property (nonatomic,strong) NSString *strForWalkStatedLongitude;
@property (nonatomic,strong) NSTimer *timerforpathDraw;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) MKPolyline *polyline;
@property(nonatomic,strong) CrumbPath *crumbs;
@property (nonatomic,strong) CrumbPathView *crumbView;

////////// Notification View
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkerStarted;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkerArrived;
@property (weak, nonatomic) IBOutlet UILabel *lblJobStart;
@property (weak, nonatomic) IBOutlet UILabel *lblJobDone;
@property (weak, nonatomic) IBOutlet UITextField *txtPromo;
@property (weak, nonatomic) IBOutlet UIButton *btnWalkerStart;
@property (weak, nonatomic) IBOutlet UIButton *btnWalkerArrived;
@property (weak, nonatomic) IBOutlet UIButton *btnJobStart;
@property (weak, nonatomic) IBOutlet UIButton *btnJobDone;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UILabel *lblAccept;
@property (weak, nonatomic) IBOutlet UILabel *lblPromoMsg;
@property (weak, nonatomic) IBOutlet UIImageView *imgForPromoMsg;
@property (weak, nonatomic) IBOutlet RatingBar *ratingView;
@property (weak, nonatomic) IBOutlet UIView *viewForMap;
@property (weak, nonatomic) IBOutlet UIView *viewForPromo;
@property (weak, nonatomic) IBOutlet UIView *viewForPromoMessage;

//PAyment Method
@property (weak, nonatomic) IBOutlet UIButton *btnCard;
@property (weak, nonatomic) IBOutlet UIButton *btnCash;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lblCarNum;
@property (weak, nonatomic) IBOutlet UILabel *lblCarType;
@property (weak, nonatomic) IBOutlet UILabel *lblRate;
@property (weak, nonatomic) IBOutlet UIButton *btnPromoDone;
@property (weak, nonatomic) IBOutlet UIButton *btnPromoCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnPromoApply;
@property (weak, nonatomic) IBOutlet UITableView *tableForCity;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;

////// for localization
@property (weak, nonatomic) IBOutlet UILabel *lAcceptJob;
@property (weak, nonatomic) IBOutlet UILabel *lPromoCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgCashRight;
@property (weak, nonatomic) IBOutlet UIImageView *imgCardRight;


- (IBAction)cardBtnPressed:(id)sender;
- (IBAction)cashBtnPressed:(id)sender;
- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)promoBtnPressed:(id)sender;
- (IBAction)promoDoneBtnPressed:(id)sender;
- (IBAction)promoCancelBtnPressed:(id)sender;
- (IBAction)promoApplyBtnPressed:(id)sender;
- (IBAction)txtAddressPressed:(id)sender;
- (IBAction)onClickRevelButton:(id)sender;
- (IBAction)statusBtnPressed:(id)sender;
- (IBAction)contactProviderBtnPressed:(id)sender;

-(int)checkDriverStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnOneCheck;
@property (strong, nonatomic) IBOutlet UIButton *btnTwoCheck;
@property (strong, nonatomic) IBOutlet UIButton *btnThreeCheck;
- (IBAction)onClickOKCancel:(id)sender;

- (IBAction)onClickBtnDelay:(id)sender;

- (IBAction)onClickBtnChanged:(id)sender;
- (IBAction)onClickBookCab:(id)sender;
@end
