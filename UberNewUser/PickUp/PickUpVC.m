//
//  PickUpVC.m
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "PickUpVC.h"
#import "SWRevealViewController.h"
#import "AFNHelper.h"
#import "AboutVC.h"
#import "ContactUsVC.h"
#import "ProviderDetailsVC.h"
#import "CarTypeCell.h"
#import "UIImageView+Download.h"
#import "CarTypeDataModal.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UberStyleGuide.h"
#import "EastimateFareVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import <GoogleMaps/GoogleMaps.h>

@interface PickUpVC ()
{
    NSString *strForUserId,*strForUserToken,*strForLatitude,*strForLongitude,*strForRequestID,*strForDriverLatitude,*strForDriverLongitude,*strForTypeid,*strMinFare,*strPassCap,*strETA,*Referral,*dist_price,*time_price,*driver_id,*destination_latitude,*destination_longitude;
    NSString  *str_price_per_unit_distance, *str_base_distance,*strPayment_Option, *strForDriverList;
    NSMutableArray *arrForInformation,*arrForApplicationType,*arrForAddress,*arrDriver,*arrType;
    NSMutableDictionary *driverInfo, *dictRequestData;
    GMSMapView *mapView_;
    BOOL is_paymetCard,is_Fare,is_set_address,is_destination;
    int flag;
    NSMutableArray *Places,*Location;
    
    NSString *strForDestLatitude,*strForDestLongitude,*strForHomeLatitude,*strForHomeLongitude,*strForWorkLatitude,*strForWorkLongitude,*strForPerTime,*strForPerDist,*strForCancelReason;
    NSMutableArray *aritem;
    int indexCaur;
}
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation PickUpVC
@synthesize items;
#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
     [self getAllApplicationType];
    [super viewDidLoad];
    [self SetLocalization];
    [APPDELEGATE hideLoadingView];
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    Referral=@"";
    indexCaur=0;
    strForTypeid=@"0";
    strPayment_Option = @"0";
    self.btnCancel.hidden=YES;
    arrForAddress=[[NSMutableArray alloc]init];
    arrForApplicationType=[[NSMutableArray alloc]init];
    self.viewForCancelLaterRequest.hidden = YES;
    
    
    
    self.tableForCity.hidden=YES;
    self.viewForPreferral.hidden=YES;
    self.viewForReferralError.hidden=YES;
    self.paymentView.hidden=YES;
    self.viewForDriver.hidden=YES;
    self.viewForDatePicker.hidden=YES;
    is_Fare=NO;
    is_set_address=NO;
    is_destination=NO;
    driverInfo=[[NSMutableDictionary alloc] init];
    Places=[[NSMutableArray alloc] init];
    Location=[[NSMutableArray alloc] init];
    
    [self CardButtonMethos];
    
    self.img_card_sign.hidden = NO;
    
    self.viewForPromoPayment.hidden=YES;
    self.viewForRequestType.hidden=YES;
    self.btnViewClose.hidden=YES;
   
    NSLog(@"data :%@",arrForApplicationType);
    
    [self.img_driver_profile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self.myDatePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    if(![[PREF valueForKey:PREF_IS_REFEREE] boolValue])
    {
        self.viewForPreferral.hidden=NO;
        self.navigationController.navigationBarHidden=YES;
        self.btnMyLocation.hidden=YES;
        self.btnETA.hidden=YES;
    }
    
    [self updateLocationManagerr];
    CLLocationCoordinate2D coordinate = [self getLocation];
    strForCurLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    strForCurLongitude= [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    strForLatitude=strForCurLatitude;
    strForLongitude=strForCurLongitude;
    [self getAddress];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForCurLatitude doubleValue] longitude:[strForCurLongitude doubleValue] zoom:18];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewGoogleMap.frame.size.width, self.viewGoogleMap.frame.size.height) camera:camera];
    mapView_.myLocationEnabled = NO;
    mapView_.delegate=self;
    [self.viewGoogleMap addSubview:mapView_];
    [self.view bringSubviewToFront:self.tableForCity];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    
    [self.paymentView addGestureRecognizer:singleTapGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    flag=0;
    self.viewForReferralError.hidden=YES;
    self.navigationController.navigationBarHidden=YES;
    self.getFareView.hidden=YES;
    self.tableforCityFare.hidden=YES;
    
    aritem=[[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3", nil];
    
    [PREF setObject:@"FARE ESTIMATE" forKey:PRFE_FARE_ADDRESS];
    [PREF synchronize];
    
    self.tableForCity.hidden=YES;
    self.txtHome.enabled=NO;
    self.txtWork.enabled=NO;
    
    self.txtHome.text=[PREF objectForKey:PRFE_HOME_ADDRESS];
    self.txtWork.text=[PREF objectForKey:PREF_WORK_ADDRESS];
    if(self.txtHome.text.length>0)
    {
        strForHomeLatitude=[PREF valueForKey:PREF_HOME_LATITUDE];
        strForHomeLongitude=[PREF valueForKey:PREF_HOME_LONGITUDE];
    }
    else
    {
        [PREF removeObjectForKey:PREF_HOME_LATITUDE];
        [PREF removeObjectForKey:PREF_HOME_LONGITUDE];
        [PREF synchronize];
    }
    if(self.txtWork.text.length>0)
    {
        strForWorkLatitude=[PREF valueForKey:PREF_WORK_LATITUDE];
        strForWorkLongitude=[PREF valueForKey:PREF_WORK_LONGITUDE];
    }
    else
    {
        [PREF removeObjectForKey:PREF_WORK_LATITUDE];
        [PREF removeObjectForKey:PREF_WORK_LONGITUDE];
        [PREF synchronize];
    }
    
    [self getPlaces];
    self.fareView.hidden=YES;
    self.viewForMarker.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+10);
    if([[PREF valueForKey:PREF_IS_REFEREE] boolValue])
    {
        [super setNavBarTitle:TITLE_PICKUP];
        [self customSetup];
        [self checkForAppStatus];
        [self getPagesData];
        [self.paymentView setHidden:YES];
        if(is_Fare==NO)
        {
            self.fareView.hidden=YES;
            self.viewForFareAddress.hidden=YES;
            [self getProviders];
        }
        else
        {
            self.fareView.hidden=NO;
            self.viewForFareAddress.hidden=YES;
            self.lblFareAddress.text=[PREF valueForKey:PRFE_FARE_ADDRESS];
            [self.btnFare setTitle:[NSString stringWithFormat:@"%@",[PREF valueForKey:PRFE_FARE_ADDRESS]] forState:UIControlStateNormal];
            self.btnFare.titleLabel.numberOfLines=2;
            self.btnFare.titleLabel.lineBreakMode= NSLineBreakByWordWrapping;
        }
        [self CashButtonMethod];
    }
    [_carousel setType:iCarouselTypeRotary];
    //[_carousel setType:iCarouselTypeLinear];
    _carousel.decelerationRate = 5;
    _carousel.scrollSpeed = 0.1;
    _carousel.backgroundColor = [UIColor clearColor];
    indexCaur=(int)arrForApplicationType.count;
    
    NSLog(@"data :%@",arrForApplicationType);
    
}
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
{
    [self.paymentView setHidden:YES];
}

#pragma mark -
#pragma mark - get-Place:

-(void)getPlaces
{
    [Places removeAllObjects];
    [Location removeAllObjects];
    
    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?sensor=true&key=AIzaSyDqAP3tTUNxRRPVEVZTW5o9-mhDvtHnYDk&location=%f,%f&radius=500",[strForLatitude floatValue],[strForLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]options: NSJSONReadingMutableContainers error: nil];
    
    NSMutableArray *result = [JSON valueForKey:@"results"];
    
    for (NSMutableDictionary *dict in result)
    {
        NSMutableDictionary *location=[dict valueForKey:@"geometry"];
        [Location addObject:[location valueForKey:@"location"]];
        [Places addObject:[dict valueForKey:@"name"]];
    }
    
    [self.tblPlaces reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    is_Fare=NO;
    self.viewForFareAddress.hidden=YES;
}
- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}
-(void)SetLocalization
{
    [self.btnFare setTitle:NSLocalizedString(@"GET FARE ESTIMATE", nil) forState:UIControlStateNormal];
    [self.btnFare setTitle:NSLocalizedString(@"GET FARE ESTIMATE", nil) forState:UIControlStateSelected];
    [self.btnPayCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.btnPayCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateSelected];
    [self.btnPayRequest setTitle:NSLocalizedString(@"Request", nil) forState:UIControlStateNormal];
    [self.btnPayRequest setTitle:NSLocalizedString(@"Request", nil) forState:UIControlStateSelected];
    [self.bReferralSkip setTitle:NSLocalizedString(@"SKIP", nil) forState:UIControlStateNormal];
    [self.bReferralSkip setTitle:NSLocalizedString(@"SKIP", nil) forState:UIControlStateSelected];
    [self.bReferralSubmit setTitle:NSLocalizedString(@"ADD", nil) forState:UIControlStateNormal];
    [self.bReferralSubmit setTitle:NSLocalizedString(@"ADD", nil) forState:UIControlStateSelected];
    [self.btnCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateSelected];
    self.lSelectPayment.text=NSLocalizedString(@"Select Your Payment Type", nil);
    self.lRefralMsg.text=NSLocalizedString(@"Referral_Msg", nil);
    self.txtPickupAddress.placeholder=NSLocalizedString(@"SEARCH", nil);
    self.txtPreferral.placeholder=NSLocalizedString(@"Enter Referral Code", nil);
}
#pragma mark-
#pragma mark- customFont

-(void)customFont
{
    self.txtPickupAddress.font=[UberStyleGuide fontRegular];
    self.btnCancel=[APPDELEGATE setBoldFontDiscriptor:self.btnCancel];
}

#pragma mark -
#pragma mark - Location Delegate

-(CLLocationCoordinate2D) getLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return coordinate;
}

-(void)updateLocationManagerr
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    [locationManager startUpdatingLocation];
    
}

CLLocation *currentLocation;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    currentLocation = newLocation;
    
    strForCurLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    strForCurLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    // GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:newLocation.coordinate zoom:14];
    //[mapView_ animateWithCameraUpdate:updatedCamera];
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
}

#pragma mark -
#pragma mark - Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    if(alertView.tag==200)
    {
        if(buttonIndex==1)
        {
            [self performSegueWithIdentifier:SEGUE_TO_BOOKING sender:self];
        }
    }
    if(alertView.tag==300)
    {
        if(buttonIndex==1)
        {
            //[self performSegueWithIdentifier:SEGUE_TO_BOOKING sender:self];
            [APPDELEGATE showToastMessage:@"Request submitted successfully"];
        }
        else
        {
            self.viewForCancelLaterRequest.hidden = NO;
        }
    }
    
}

#pragma mark -
#pragma mark - Google Map Delegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if(!is_destination)
    {
        strForLatitude=[NSString stringWithFormat:@"%f",position.target.latitude];
        strForLongitude=[NSString stringWithFormat:@"%f",position.target.longitude];
    }
}
- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    if (arrDriver.count>0)
    {
        [self getETA:[arrDriver objectAtIndex:0]];
    }
    if(is_set_address)
    {
        is_set_address=NO;
    }
    else
    {
        if(!is_destination)
        {
            [self getAddress];
        }
    }
    if(!is_destination)
    {
        [self getProviders];
    }
    
    [self getPlaces];
}
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.paymentView setHidden:YES];
}

-(NSString *)getAddressFromLocation:(CLLocation *)location {
    __block NSString *address = nil;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {

         if(placemarks && placemarks.count > 0)
         {
            // NSLog(@"AppInfo: placemarks.count = %@",placemarks.count);

             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             
             // strAdd -> take bydefault value nil
             NSString *strAdd = nil;
             
             if ([placemark.subThoroughfare length] != 0)
                 strAdd = placemark.subThoroughfare;
             
             if ([placemark.thoroughfare length] != 0)
             {
                 // strAdd -> store value of current location
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark thoroughfare]];
                 else
                 {
                     // strAdd -> store only this value,which is not null
                     strAdd = placemark.thoroughfare;
                 }
             }
             
             if ([placemark.postalCode length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
                 else
                     strAdd = placemark.postalCode;
             }
             
             if ([placemark.locality length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
                 else
                     strAdd = placemark.locality;
             }
             
             if ([placemark.administrativeArea length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
                 else
                     strAdd = placemark.administrativeArea;
             }
             
             if ([placemark.country length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
                 else
                     strAdd = placemark.country;
             }
             
             NSLog(@"AppInfo: address = %@",strAdd);
             
             
             
             self.txtPickupAddress.text = strAdd;


         }

     }];

   // [geocoder release];
    return address;
}

-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&key=AIzaSyDqAP3tTUNxRRPVEVZTW5o9-mhDvtHnYDk",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    
    NSLog(@"AppInfo: location: %@", currentLocation);
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
         options: NSJSONReadingMutableContainers
           error: nil];
    
    NSString *address = [self getAddressFromLocation :currentLocation];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    
    NSLog(@"getAddress.count = %d",getAddress.count);
    
    if (getAddress.count!=0)
    {
        self.txtPickupAddress.text=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
}
#pragma mark -
#pragma mark - Mapview Delegate

-(void)showMapCurrentLocatinn
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:18];
    [mapView_ animateWithCameraUpdate:updatedCamera];
    
    [self getAddress];
}

#pragma mark -
#pragma mark - Memory Mgmt
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if(tableView==self.tableforCityFare)
    {
        if(placeMarkArr.count >0)
        {
            NSString *formatedAddress=[[placeMarkArr objectAtIndex:indexPath.row] valueForKey:@"description"]; // AUTOCOMPLETE API
            
            cell.textLabel.font=[UIFont fontWithName:@"Arial" size:13];
            cell.textLabel.text=formatedAddress;
        }
    }
    else if(tableView==self.tblPlaces)
    {
        cell.textLabel.font=[UIFont fontWithName:@"Arial" size:13];
        cell.textLabel.text=[Places objectAtIndex:indexPath.row];
    }
    else if(tableView == self.tableForCity)
    {
        if(placeMarkArr.count >0)
        {
            NSString *formatedAddress=[[placeMarkArr objectAtIndex:indexPath.row] valueForKey:@"description"]; // AUTOCOMPLETE API
            
            cell.textLabel.text=formatedAddress;
            cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12];
            cell.textLabel.textColor=[UIColor blackColor];
            cell.textLabel.alpha=0.7;
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tableforCityFare)
    {
        aPlacemark=[placeMarkArr objectAtIndex:indexPath.row];
        self.tableforCityFare.hidden=YES;
        [self setNewPlaceData];
    }
    else if (tableView==self.tblPlaces)
    {
        [self.tblPlaces deselectRowAtIndexPath:indexPath animated:YES];
        NSMutableDictionary *dict=[Location objectAtIndex:indexPath.row];
        strForDestLatitude=[dict valueForKey:@"lat"];
        strForDestLongitude=[dict valueForKey:@"lng"];
        
        CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
        CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForDestLatitude doubleValue], [strForDestLongitude doubleValue]);
        [PREF setObject:[Places objectAtIndex:indexPath.row] forKey:PRFE_FARE_ADDRESS];
        [PREF synchronize];
        self.getFareView.hidden=YES;
        [self.btnGetFare setTitle:[Places objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        
        self.fareView.hidden=NO;
        [self calculateRoutesFrom:scoor to:dcoor];
        
    }
    else if(tableView == self.tableForCity)
    {
        aPlacemark=[placeMarkArr objectAtIndex:indexPath.row];
        self.tableForCity.hidden=YES;
        [self setNewPlaceData];
        is_set_address=YES;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.tableForCity)
    {
        return placeMarkArr.count;
    }
    else if (tableView==self.tblPlaces)
    {
        return Places.count;
    }
    else if(tableView ==self.tableforCityFare)
    {
        return placeMarkArr.count;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(void)setNewPlaceData
{
    if (flag==1)
    {
        self.txtDestiSearch.text=[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [PREF setObject:[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]] forKey:PRFE_FARE_ADDRESS];
        [PREF synchronize];
        [self textFieldShouldReturn:self.txtDestiSearch];
    }
    else if (flag==2)
    {
        self.txtHome.text=[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [self textFieldShouldReturn:self.txtHome];
    }
    else if (flag==3)
    {
        self.txtWork.text=[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [self textFieldShouldReturn:self.txtWork];
    }
    else if(flag==4)
    {
        self.txtPickupAddress.text = [NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [self textFieldShouldReturn:self.txtPickupAddress];
    }
    else if(flag==5)
    {
        self.txtDestination.text = [NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [self textFieldShouldReturn:self.txtDestination];
    }
}
#pragma mark -
#pragma mark - UIButton Action

- (IBAction)eastimateFareBtnPressed:(id)sender
{
    is_Fare=YES;
    [[AppDelegate sharedAppDelegate]showHUDLoadingView:@"Loading..."];
    [self performSegueWithIdentifier:@"segueToEastimate" sender:nil];
    
}
- (IBAction)closeETABtnPressed:(id)sender
{
    self.fareView.hidden=YES;
    self.viewForFareAddress.hidden=YES;
    is_Fare=NO;
}
- (IBAction)ETABtnPressed:(id)sender
{
    NSLog(@"str for type id :%@",strForTypeid);
    if(![strForTypeid isEqual:@"0"])
    {
        self.fareView.hidden=NO;
    }
    else
    {
        [APPDELEGATE showToastMessage:@"Please select any service !"];
    }
    if (arrDriver.count>0) {
        [self getETA:[arrDriver objectAtIndex:0]];
    }
    [self.btnGetFare setTitle:@"Get Fare Estimate" forState:UIControlStateNormal];
}
- (IBAction)cashBtnPressed:(id)sender
{
    [self CashButtonMethod];
}
- (IBAction)cardBtnPressed:(id)sender
{
    [self CardButtonMethos];
}
-(void)CashButtonMethod
{
    [self.btnCash setBackgroundImage:[UIImage imageNamed:@"rectangle2"] forState:UIControlStateNormal];
    [self.btnCard setBackgroundImage:[UIImage imageNamed:@"rectangle3"] forState:UIControlStateNormal];
    self.img_cash_sign.hidden=NO;
    self.img_card_sign.hidden=YES;
    is_paymetCard=NO;
    strPayment_Option = @"1";
}
-(void)CardButtonMethos
{
    [self.btnCash setBackgroundImage:[UIImage imageNamed:@"rectangle3"] forState:UIControlStateNormal];
    [self.btnCard setBackgroundImage:[UIImage imageNamed:@"rectangle2"] forState:UIControlStateNormal];
    self.img_cash_sign.hidden=YES;
    self.img_card_sign.hidden=NO;
    is_paymetCard=YES;
    strPayment_Option = @"0";
}
- (void)createRequest
{
    if([CLLocationManager locationServicesEnabled])
    {
        if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil)
        {
            strForTypeid=@"1";
        }
        if(![strForTypeid isEqualToString:@"0"])
        {
            if(((strForLatitude==nil)&&(strForLongitude==nil))
               ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
            {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
            }
            else
            {
                if([[AppDelegate sharedAppDelegate]connected])
                {
                    
                    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
                    strForUserId=[PREF objectForKey:PREF_USER_ID];
                    strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
                    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                    NSString *tzName = [timeZone name];
                    
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                    [dictParam setValue:strForUserId forKey:PARAM_ID];
                    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
                    [dictParam setValue:tzName forKey:@"time_zone"];
                    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
                    [dictParam setValue:self.txtPickupAddress.text forKey:@"src_address"];
                    //if (is_paymetCard)
                    {
                        [dictParam setValue:@"0" forKey:PARAM_PAYMENT_OPT];
                    }
//                    else
//                    {
//                        [dictParam setValue:@"1" forKey:PARAM_PAYMENT_OPT];
//                    }
                    if(self.txtDestination.text.length>0)
                    {
                        [dictParam setValue:destination_latitude forKey:@"d_latitude"];
                        [dictParam setValue:destination_longitude forKey:@"d_longitude"];
                        [dictParam setValue:self.txtDestination.text forKey:@"dest_address"];
                    }
                    if(self.txtPromoCode.text.length>0)
                    {
                        [dictParam setValue:self.txtPromoCode.text forKey:@"promo_code"];
                    }
                    
                    NSLog(@"dict for request :%@",dictParam);
                    
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_CREATE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
                     {
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         
                         if (response)
                         {
                             [[AppDelegate sharedAppDelegate] hideLoadingView];
                             
                             if([[response valueForKey:@"success"]intValue]==1)
                             {
                                 [self HideRequestView];
                                 NSLog(@"pick up......%@",response);
                                 /*
                                  UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:@"Thank you! for booking." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go to booking", nil];
                                  alert.tag=200;
                                  [alert show];
                                  */
                                 NSMutableDictionary *walker=[response valueForKey:@"walker"];
                                 [self showDriver:walker];
                                 self.viewForDriver.hidden=NO;
                                 strForRequestID=[response valueForKey:@"request_id"];
                                 [PREF setObject:strForRequestID forKey:PREF_REQ_ID];
                                 [PREF synchronize];
                                 [self setTimerToCheckDriverStatus];
                                 [self.btnCancel setHidden:NO];
                                 [APPDELEGATE.window addSubview:self.btnCancel];
                                 [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
                                 [APPDELEGATE.window addSubview:self.viewForDriver];
                                 [APPDELEGATE.window bringSubviewToFront:self.viewForDriver];
                             }
                             else
                             {
                                 if([[response valueForKey:@"error_code"] integerValue]==505)
                                 {
                                     self.txtPromoCode.text=@"";
                                     [self.txtPromoCode becomeFirstResponder];
                                 }
                                 if([[response valueForKey:@"error_code"] integerValue]==512)
                                 {
                                     self.txtPromoCode.text=@"";
                                     [self.txtPromoCode becomeFirstResponder];
                                 }
                                 NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                                 [alert show];
                                 
                             }
                         }
                     }];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    [alert show];
                }
            }
            
        }
        else
            [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxi any time -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}
-(void)CreateFutureRequest
{
    self.viewForDatePicker.hidden=YES;
    
    if([CLLocationManager locationServicesEnabled])
    {
        if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil)
        {
            strForTypeid=@"1";
        }
        if(![strForTypeid isEqualToString:@"0"])
        {
            if(((strForLatitude==nil)&&(strForLongitude==nil))
               ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
            {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
            }
            else
            {
                if([[AppDelegate sharedAppDelegate]connected])
                {
                    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
                    strForUserId=[PREF objectForKey:PREF_USER_ID];
                    strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
                    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                    NSString *tzName = [timeZone name];
                    
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                    [dictParam setValue:strForUserId forKey:PARAM_ID];
                    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
                    [dictParam setValue:tzName forKey:@"time_zone"];
                    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
                    [dictParam setValue:self.txtPickupAddress.text forKey:@"src_address"];
                    [dictParam setValue:self.lblSelectedDate.text forKey:@"start_time"];
                    //if (is_paymetCard)
                    {
                        [dictParam setValue:@"0" forKey:PARAM_PAYMENT_OPT];
                    }
//                    else
//                    {
//                        [dictParam setValue:@"1" forKey:PARAM_PAYMENT_OPT];
//                    }
                    if(self.txtDestination.text.length>0)
                    {
                        [dictParam setValue:destination_latitude forKey:@"d_latitude"];
                        [dictParam setValue:destination_longitude forKey:@"d_longitude"];
                        [dictParam setValue:self.txtDestination.text forKey:@"dest_address"];
                    }
                    if(self.txtPromoCode.text.length>0)
                    {
                        [dictParam setValue:self.txtPromoCode.text forKey:@"promo_code"];
                    }
                    
                    NSLog(@"dict for request :%@",dictParam);
                    
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_CREATE_FUTURE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
                     {
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         
                         if (response)
                         {
                             [[AppDelegate sharedAppDelegate] hideLoadingView];
                             
                             if([[response valueForKey:@"success"]intValue]==1)
                             {
                                 [self HideRequestView];
                                 NSLog(@"future pick up......%@",response);
                                 dictRequestData = [[response valueForKey:@"all_scheduled_requests"]objectAtIndex:0] ;
                                 
                                 
                                 self.viewForDatePicker.hidden=YES;
                                 [self myLocationPressed:nil];
                                 UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Alert Message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                                 alert.tag=300;
                                 [alert show];
                             }
                             else
                             {
                                 if([[response valueForKey:@"error_code"] integerValue]==505)
                                 {
                                     self.txtPromoCode.text=@"";
                                     [self.txtPromoCode becomeFirstResponder];
                                 }
                                 if([[response valueForKey:@"error_code"] integerValue]==512)
                                 {
                                     self.txtPromoCode.text=@"";
                                     [self.txtPromoCode becomeFirstResponder];
                                 }
                                 NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                                 [alert show];
                                 
                             }
                         }
                     }];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    [alert show];
                }
            }
            
        }
        else
            [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxi any time -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
}
- (IBAction)pickMeUpBtnPressed:(id)sender
{
    self.getFareView.hidden=YES;
    self.fareView.hidden=YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.viewForRequestType.hidden=NO;
        self.viewForPromoPayment.hidden=NO;
        self.carousel.hidden=NO;
        self.btnETA.hidden=YES;
        self.btnViewClose.hidden=NO;
        self.txtDestination.text=@"";
        self.txtPromoCode.text=@"";
    } completion:^(BOOL finished)
     {
     }];
}

- (IBAction)OnClickCloseViewBtn:(id)sender
{
    [self HideRequestView];
}
-(void)HideRequestView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.viewForRequestType.hidden=YES;
        self.viewForPromoPayment.hidden=YES;
        self.carousel.hidden=YES;
        self.btnETA.hidden=NO;
        self.btnViewClose.hidden=YES;
        self.tableForCity.hidden=YES;
        [mapView_ clear];
        self.viewForMarker.hidden=NO;
        [self myLocationPressed:nil];
        is_destination=NO;
    } completion:^(BOOL finished)
     {
     }];
}
- (IBAction)cancelReqBtnPressed:(id)sender
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([[AppDelegate sharedAppDelegate]connected])
        {
            [[AppDelegate sharedAppDelegate]hideLoadingView];
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
            
            strForUserId=[PREF objectForKey:PREF_USER_ID];
            strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
            NSString *strReqId=[PREF objectForKey:PREF_REQ_ID];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setValue:strReqId forKey:PARAM_REQUEST_ID];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         self.btnCancel.hidden=YES;
                         self.viewForDriver.hidden=YES;
                         [PREF removeObjectForKey:PREF_REQ_ID];
                         is_walker_arrived=0;
                         is_walker_started=0;
                         is_completed=0;
                         is_started=0;
                         is_dog_rated=0;
                         [PREF synchronize];
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                     }
                     else
                     {
                         NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                         [alert show];
                         
                     }
                 }
             }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxi any time -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}
- (IBAction)myLocationPressed:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D coor;
        coor.latitude=[strForCurLatitude doubleValue];
        coor.longitude=[strForCurLongitude doubleValue];
        strForLatitude=strForCurLatitude;
        strForLongitude=strForCurLongitude;
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:18];
        [mapView_ animateWithCameraUpdate:updatedCamera];
        [self getPlaces];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxi any time -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}
- (IBAction)onClickForCancel:(id)sender
{
    self.fareView.hidden=YES;
}
-(IBAction)OnClickForCancelFareView:(id)sender
{
    self.getFareView.hidden=YES;
    self.fareView.hidden=NO;
}

- (IBAction)OnClickRidenowBtn:(id)sender
{
    [self createRequest];
}
- (IBAction)OnClickRidelaterBtn:(id)sender
{
    self.viewForDatePicker.hidden=NO;
    
    [self.myDatePicker setDate:[NSDate date]];
    [self datePickerChanged:self.myDatePicker];
    self.myDatePicker.minimumDate=self.myDatePicker.date;
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:+7];
    NSDate *sevenDays = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    self.myDatePicker.maximumDate=sevenDays;
}

- (IBAction)OnClickScheduleCloseBtn:(id)sender
{
    self.viewForDatePicker.hidden=YES;
}

- (IBAction)OnClickBtnScheduleTripBtn:(id)sender
{
    NSDate *CurrentdateTime = [NSDate date];
    NSDate *selectedDateTime=self.myDatePicker.date;
    
    NSTimeInterval distanceBetweenDates = [selectedDateTime timeIntervalSinceDate:CurrentdateTime];
    int timeInMinutes=distanceBetweenDates/60;
    
    if(timeInMinutes<31)
    {
        [self createRequest];
    }
    else
    {
        [self CreateFutureRequest];
    }
}
- (IBAction)onClickForGetFare:(id)sender
{
    if (arrDriver.count>0) {
        [self getETA:[arrDriver objectAtIndex:0]];
    }
    self.txtDestiSearch.text=@"";
    self.getFareView.hidden=NO;
    self.tableforCityFare.hidden=YES;
}
#pragma mark -
#pragma mark - Home & Work Button Action
- (IBAction)onClickHomeGetFare:(id)sender
{
    CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForHomeLatitude doubleValue], [strForHomeLongitude doubleValue]);
    [PREF setObject:self.txtHome.text forKey:PRFE_FARE_ADDRESS];
    [PREF synchronize];
    [self.btnGetFare setTitle:self.txtHome.text forState:UIControlStateNormal];
    [self calculateRoutesFrom:scoor to:dcoor];
}
- (IBAction)onClickWorkGetFare:(id)sender
{
    CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForWorkLatitude doubleValue], [strForWorkLongitude doubleValue]);
    [PREF setObject:self.txtWork.text forKey:PRFE_FARE_ADDRESS];
    [PREF synchronize];
    [self.btnGetFare setTitle:self.txtWork.text forState:UIControlStateNormal];
    [self calculateRoutesFrom:scoor to:dcoor];
}
- (IBAction)onClickHomeEdit:(id)sender
{
    self.txtHome.enabled=YES;
    self.btnHomeGetFare.hidden=YES;
    self.btnHomeEdit.hidden=YES;
    [self.txtHome becomeFirstResponder];
}
- (IBAction)onClickWorkEdit:(id)sender
{
    self.txtWork.enabled=YES;
    self.btnWorkGetFare.hidden=YES;
    self.btnWorkEdit.hidden=YES;
    [self.txtWork becomeFirstResponder];
}
#pragma mark -
#pragma mark - Referral btn Action

- (IBAction)btnSkipReferral:(id)sender
{
    Referral=@"1";
    [self createService];
}
- (IBAction)btnAddReferral:(id)sender
{
    Referral=@"0";
    [self createService];
}
-(void)createService
{
    self.viewForReferralError.hidden=YES;
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[PREF objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setObject:self.txtPreferral.text forKey:PARAM_REFERRAL_CODE];
        [dictParam setObject:[PREF objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setObject:Referral forKey:PARAM_REFERRAL_SKIP];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_APPLY_REFERRAL withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSLog(@"%@",response);
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         [PREF setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                         [PREF synchronize];
                         self.viewForPreferral.hidden=YES;
                         self.btnMyLocation.hidden=NO;
                         self.btnETA.hidden=NO;
                         self.txtPreferral.text=@"";
                         if([Referral isEqualToString:@"0"])
                         {
                             [APPDELEGATE showToastMessage:[response valueForKey:@"error"]];
                         }
                         [self getAllApplicationType];
                         [super setNavBarTitle:TITLE_PICKUP];
                         [self customSetup];
                         [self checkForAppStatus];
                         [self getPagesData];
                         [self getProviders];
                         [self.paymentView setHidden:YES];
                         self.fareView.hidden=YES;
                         [self CashButtonMethod];
                     }
                 }
                 else
                 {
                     
                     NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                     //                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                     //                     [alert show];
                     
                     self.txtPreferral.text=@"";
                     self.viewForReferralError.hidden=NO;
                     self.lblReferralMsg.text=str;
                     self.lblReferralMsg.textColor=[UIColor colorWithRed:205.0/255.0 green:0.0/255.0 blue:15.0/255.0 alpha:1];
                 }
             }
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark - Custom WS Methods

-(void)getAllApplicationType
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_APPLICATION_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 NSLog(@" all response data is : %@",response);
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSMutableArray *arr=[[NSMutableArray alloc]init];
                     arrForApplicationType=[[NSMutableArray alloc]init];
                     [arr addObjectsFromArray:[response valueForKey:@"types"]];
                     arrType=[response valueForKey:@"types"];
                     
                     for(NSMutableDictionary *dict in arr)
                     {
                         CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                         obj.id_=[dict valueForKey:@"id"];
                         obj.name=[dict valueForKey:@"name"];
                         obj.icon=[dict valueForKey:@"icon"];
                         obj.is_default=[dict valueForKey:@"is_default"];
                         obj.price_per_unit_time=[dict valueForKey:@"price_per_unit_time"];
                         obj.price_per_unit_distance=[dict valueForKey:@"price_per_unit_distance"];
                         obj.base_price=[dict valueForKey:@"base_price"];
                         obj.isSelected=NO;
                         [arrForApplicationType addObject:obj];
                         
                     }
                     [self.carousel reloadData];
                     NSLog(@"tom :%@",arrForApplicationType);
                 }
                 else
                 {}
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

-(void)setTimerToCheckDriverStatus
{
    if (timerForCheckReqStatus) {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
    }
    timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
}


-(void)checkForAppStatus
{
    NSString *strReqId=[PREF objectForKey:PREF_REQ_ID];
    if(strReqId!=nil)
    {
        [self checkForRequestStatus];
    }
    else
    {
        [self RequestInProgress];
    }
}
-(void)checkForRequestStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        strForUserId=[PREF objectForKey:PREF_USER_ID];
        strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[PREF objectForKey:PREF_REQ_ID];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue] && [[response valueForKey:@"confirmed_walker"] integerValue]!=0)
                 {
                     NSLog(@"GET REQ--->%@",response);
                     NSString *strCheck=[response valueForKey:@"walker"];
                     
                     if(strCheck)
                     {
                         self.btnCancel.hidden=YES;
                         self.viewForDriver.hidden=YES;
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                         strForDriverLatitude=[dictWalker valueForKey:@"latitude"];
                         strForDriverLongitude=[dictWalker valueForKey:@"longitude"];
                         if ([[response valueForKey:@"is_walker_rated"]integerValue]==1)
                         {
                             [PREF removeObjectForKey:PREF_REQ_ID];
                             [PREF synchronize];
                             return ;
                         }
                         
                         ProviderDetailsVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[ProviderDetailsVC class]])
                             {
                                 vcFeed = (ProviderDetailsVC *)vc;
                             }

                         }
                         if (vcFeed==nil)
                         {
                             [timerForCheckReqStatus invalidate];
                             timerForCheckReqStatus=nil;
                             [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
                             [self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
                         }
                         else
                         {

                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                     }
                     
                 }
                 if([[response valueForKey:@"confirmed_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]==1)
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     [timerForCheckReqStatus invalidate];
                     timerForCheckReqStatus=nil;
                     [PREF removeObjectForKey:PREF_REQ_ID];
                     [PREF synchronize];
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                     [APPDELEGATE hideLoadingView];
                     self.btnCancel.hidden=YES;
                     self.viewForDriver.hidden=YES;
                 }
                 else
                 {
                     //driverInfo=[response valueForKey:@"walker"];
                     //[self showDriver:driverInfo];
                 }
             }
             else
             {}
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

-(void)RequestInProgress
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        strForUserId=[PREF objectForKey:PREF_USER_ID];
        strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     [PREF setObject:[response valueForKey:@"request_id"] forKey:PREF_REQ_ID];
                     [PREF synchronize];
                     [self checkForRequestStatus];
                 }
                 else
                 {}
             }
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}
-(void)getPagesData
{
    strForUserId=[PREF objectForKey:PREF_USER_ID];
    strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGE,PARAM_ID,strForUserId];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"Respond to Request= %@",response);
             [APPDELEGATE hideLoadingView];
             
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrPage=[response valueForKey:@"informations"];
                     //[APPDELEGATE showToastMessage:@"Requset Accepted"];
                 }
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}
-(void)getProviders
{
    strForUserId=[PREF objectForKey:PREF_USER_ID];
    strForUserToken=[PREF objectForKey:PREF_USER_TOKEN];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
    [dictParam setValue:strForLatitude forKey:@"usr_lat"];
    [dictParam setValue:strForLongitude forKey:@"user_long"];
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_GET_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             NSLog(@"Respond to Get Provider= %@",response);
             if (response)
             {
                 if([[response valueForKey:@"success"] boolValue])
                 {
                     arrDriver=[response valueForKey:@"walker_list"];
                     [self showProvider];
                 }
                 
             }
             else
             {
                 arrDriver=[[NSMutableArray alloc] init];
                 [self showProvider];
             }
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];        [alert show];
    }
}

-(void)showProvider
{
    [mapView_ clear];
    BOOL is_first=YES;
    for (int i=0; i<arrDriver.count; i++)
    {
        NSDictionary *dict=[arrDriver objectAtIndex:i];
        NSString *strType=[NSString stringWithFormat:@"%@",[dict valueForKey:@"type"]];
        if ([strForTypeid isEqualToString:strType])
        {
            GMSMarker *driver_marker;
            driver_marker = [[GMSMarker alloc] init];
            driver_marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue],[[dict valueForKey:@"longitude"]doubleValue]);
            driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
            driver_marker.map = mapView_;
            if (is_first)
            {
                [self getETA:dict];
                is_first=NO;
            }
        }
    }
    is_first=YES;
}

-(void)getETA:(NSDictionary *)dict
{
    CLLocationCoordinate2D scorr=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcorr=CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue], [[dict valueForKey:@"longitude"]doubleValue]);
    [self calculateRoutesFrom:scorr to:dcorr];
    
}

#pragma mark - calculate_RouteFrom :

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,GOOGLE_KEY_NEW];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSLog(@"url :%@",apiUrl);
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"get json :%@ and source :%@ destination :%@",json,saddr,daddr);
    
    if ([[json objectForKey:@"status"]isEqualToString:@"REQUEST_DENIED"] || [[json objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"] || [[json objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]|| [[json objectForKey:@"status"] isEqualToString:@"NOT_FOUND"])
    {
        NSLog(@"query limit over ");
    }
    else
    {
        NSDictionary *getRoutes = [json valueForKey:@"routes"];
        NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
        NSArray *getAddress = [getLegs valueForKey:@"duration"];
        NSArray *getDistance = [getLegs valueForKey:@"distance"];
        NSString *strDistance = [[[getDistance objectAtIndex:0]objectAtIndex:0] valueForKey:@"value"];
        
        // NSString *strDistance = [[[getDistance objectAtIndex:0]objectAtIndex:0] valueForKey:@"text"];
        //NSArray *time=[strDistance  componentsSeparatedByString:@" "];
        //NSString *strDistanceValue = [time objectAtIndex:0];
        //NSString *strDistanceUnit = [time objectAtIndex:1];
        
        if(getAddress.count>0)
        {
            strETA = [[[getAddress objectAtIndex:0]objectAtIndex:0] valueForKey:@"text"];
            NSLog(@"data ETA :%@",strETA);
            self.lblETA.text=[NSString stringWithFormat:@"%@",strETA];
            self.lblMinTime1.text=[NSString stringWithFormat:@"%@",strETA];
        }
        else
        {
            self.lblETA.text=@"0 min";
            self.lblMinTime1.text=@"0 min";
        }
        
        /*
         if([strDistanceUnit isEqualToString:@"mi"])
         {
         float result=[strDistanceValue longLongValue]*1.6;
         strForPerDist=[NSString stringWithFormat:@"%f",[strDistanceValue floatValue]*(1.6)] ;
         }
         else if ([strDistanceUnit isEqualToString:@"m"])
         {
         strForPerDist=[NSString stringWithFormat:@"%.2f",[strDistanceValue floatValue]/1000];
         }
         else if ([strDistanceUnit isEqualToString:@"km"])
         {
         strForPerDist=[NSString stringWithFormat:@"%.2f",[strDistanceValue floatValue]];
         }
         */
        strForPerDist=[NSString stringWithFormat:@"%f",[strDistance integerValue]*(0.001)];
        NSString *fare =  [NSString stringWithFormat:@"%.2f", [strMinFare floatValue] + ([strForPerDist floatValue]- [str_base_distance floatValue]) * [str_price_per_unit_distance floatValue]];
        if([fare integerValue]<[strMinFare integerValue])
        {
            fare=[NSString stringWithFormat:@"%@",strMinFare];
        }
        NSLog(@"fr = %@",fare);
        [PREF setObject:fare forKey:PREF_FARE_AMOUNT];
        [PREF synchronize];
        self.lMinFare.text= [NSString stringWithFormat:@"€%.2f",[fare floatValue]];
        self.tableforCityFare.hidden=YES;
        self.getFareView.hidden=YES;
    }
    return nil;
}
-(void)showDriver:(NSMutableDictionary *)walker
{
    if([driver_id integerValue]!=[[walker valueForKey:@"id"]integerValue ])
    {
        driver_id=[walker valueForKey:@"id"];
        self.lbl_driverName.text=[NSString stringWithFormat:@"%@ %@",[walker valueForKey:@"first_name"],[walker valueForKey:@"last_name"]];
        self.lbl_driverRate.text=[NSString stringWithFormat:@"%@", [walker valueForKey:@"rating"]];
        self.lbl_driver_Carname.text=[NSString stringWithFormat:@"%@",[walker valueForKey:@"car_model"]];
        self.lbl_driver_CarNumber.text=[NSString stringWithFormat:@"%@",[walker valueForKey:@"car_number"]];
        [self.img_driver_profile downloadFromURL:[walker valueForKey:@"picture"] withPlaceholder:nil];
    }
}

#pragma mark
#pragma mark - UITextfield Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(self.txtPickupAddress==textField)
    {
        if(placeMarkArr.count==1)
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.txtPickupAddress.frame.origin.y+self.txtPickupAddress.frame.size.height-5, self.tableForCity.frame.size.width,44);
        else if(placeMarkArr.count==2)
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.txtPickupAddress.frame.origin.y+self.txtPickupAddress.frame.size.height-5, self.tableForCity.frame.size.width,88);
        else if(placeMarkArr.count==3)
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.txtPickupAddress.frame.origin.y+self.txtPickupAddress.frame.size.height-5, self.tableForCity.frame.size.width,132);
        else if(placeMarkArr.count==0)
            self.tableForCity.hidden=YES;
        else
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.txtPickupAddress.frame.origin.y+self.txtPickupAddress.frame.size.height-5, self.tableForCity.frame.size.width,150);
        [self.tableForCity reloadData];
    }
    else if(self.txtDestiSearch==textField)
    {
        flag=1;
        self.tableforCityFare.frame=CGRectMake(self.tableforCityFare.frame.origin.x
                                               , self.txtDestiSearch.frame.origin.y+38.0f, self.tableforCityFare.frame.size.width, self.tableforCityFare.frame.size.height);
    }
    else if(self.txtHome==textField)
    {
        flag=2;
        self.tableforCityFare.frame=CGRectMake(self.tableforCityFare.frame.origin.x
                                               , self.txtHome.frame.origin.y+38.0f, self.tableforCityFare.frame.size.width, self.tableforCityFare.frame.size.height);
    }
    else if(self.txtWork==textField)
    {
        flag=3;
        self.tableforCityFare.frame=CGRectMake(self.tableforCityFare.frame.origin.x
                                               , self.txtWork.frame.origin.y+38.0f, self.tableforCityFare.frame.size.width, self.tableforCityFare.frame.size.height);
    }
    else if (textField==self.txtDestination)
    {
        if(placeMarkArr.count==1)
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.viewForPromoPayment.frame.origin.y+self.txtDestination.frame.size.height-5, self.tableForCity.frame.size.width,44);
        else if(placeMarkArr.count==2)
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.viewForPromoPayment.frame.origin.y+self.txtDestination.frame.size.height-5, self.tableForCity.frame.size.width,88);
        else if(placeMarkArr.count==3)
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.viewForPromoPayment.frame.origin.y+self.txtDestination.frame.size.height-5, self.tableForCity.frame.size.width,132);
        else if(placeMarkArr.count==0)
            self.tableForCity.hidden=YES;
        else
            self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x,self.viewForPromoPayment.frame.origin.y+self.txtDestination.frame.size.height-5, self.tableForCity.frame.size.width,150);
        [self.tableForCity reloadData];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.txtDestiSearch==textField)
    {
        flag=1;
        self.tableforCityFare.frame=CGRectMake(self.tableforCityFare.frame.origin.x
                                               , self.txtDestiSearch.frame.origin.y+38.0f, self.tableforCityFare.frame.size.width, self.tableforCityFare.frame.size.height);
    }
    else if(self.txtHome==textField)
    {
        flag=2;
        self.tableforCityFare.frame=CGRectMake(self.tableforCityFare.frame.origin.x
                                               , self.txtHome.frame.origin.y+38.0f, self.tableforCityFare.frame.size.width, self.tableforCityFare.frame.size.height);
    }
    else if(self.txtWork==textField)
    {
        flag=3;
        self.tableforCityFare.frame=CGRectMake(self.tableforCityFare.frame.origin.x, self.txtWork.frame.origin.y+38.0f, self.tableforCityFare.frame.size.width, self.tableforCityFare.frame.size.height);
    }
    else if(textField==self.txtPickupAddress)
    {
        flag=4;
    }
    else if (textField==self.txtDestination)
    {
        flag=5;
    }
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==self.txtPickupAddress)
    {
        self.txtPickupAddress.text=@"";
    }
    if (textField==self.txtDestination)
    {
        is_destination=NO;
        self.txtDestination.text=@"";
    }
    if (textField==self.txtPreferral)
    {
        self.viewForReferralError.hidden=YES;
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.txtDestiSearch==textField)
    {
        [self getLocationFromStringForSearching:self.txtDestiSearch.text];
    }
    else if(self.txtHome==textField)
    {
        self.btnHomeEdit.hidden=NO;
        self.btnHomeGetFare.hidden=NO;
        [self getLocationFromStringForSearching:self.txtHome.text];
    }
    else if(self.txtWork==textField)
    {
        self.btnWorkEdit.hidden=NO;
        self.btnWorkGetFare.hidden=NO;
        [self getLocationFromStringForSearching:self.txtWork.text];
    }
    else if(self.txtPickupAddress == textField)
    {
        [self getLocationFromString:self.txtPickupAddress.text];
    }
    else if (textField==self.txtDestination)
    {
        if(self.txtDestination.text.length>0)
        {
            [self getLocationFromString:self.txtDestination.text];
        }
        else
        {
            is_destination=NO;
            [self myLocationPressed:self];
            self.viewForMarker.hidden=NO;
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.tableView.hidden=YES;
    self.tableforCityFare.hidden=YES;
    [textField resignFirstResponder];
    return YES;
}
-(void)getLocationFromString:(NSString *)str
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress=[response valueForKey:@"results"];
             if ([arrAddress count] > 0)
             {
                 if (flag==4)
                 {
                     //self.txtPickupAddress.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     
                     strForLatitude=[dictLocation valueForKey:@"lat"];
                     strForLongitude=[dictLocation valueForKey:@"lng"];
                     CLLocationCoordinate2D coor;
                     coor.latitude=[strForLatitude doubleValue];
                     coor.longitude=[strForLongitude doubleValue];
                     
                     GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:18];
                     [mapView_ animateWithCameraUpdate:updatedCamera];
                 }
                 else if (flag==5)
                 {
                     //self.txtDestination.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     
                     destination_latitude=[dictLocation valueForKey:@"lat"];
                     destination_longitude=[dictLocation valueForKey:@"lng"];
                     CLLocationCoordinate2D coor;
                     coor.latitude=[strForLatitude doubleValue];
                     coor.longitude=[strForLongitude doubleValue];
                     
                     CLLocationCoordinate2D coorStr;
                     coorStr.latitude=[destination_latitude doubleValue];
                     coorStr.longitude=[destination_longitude doubleValue];
                     
                     [self showRouteFrom:coorStr to:coor];
                 }
             }
         }
     }];
}
-(void)getLocationFromStringForSearching:(NSString *)str
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress = [[NSArray alloc]init];
             arrAddress=[response valueForKey:@"results"];
             if ([arrAddress count] > 0)
             {
                 if (flag==1)
                 {
                     //self.txtPickupAddress.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     strForDestLatitude=[dictLocation valueForKey:@"lat"];
                     strForDestLongitude=[dictLocation valueForKey:@"lng"];
                     CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
                     CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForDestLatitude doubleValue], [strForDestLongitude doubleValue]);
                     [self.btnGetFare setTitle:self.txtPickupAddress.text forState:UIControlStateNormal];
                     
                     self.btnGetFare.titleLabel.textAlignment = NSTextAlignmentCenter;
                     self.btnGetFare.titleLabel.numberOfLines = 0;
                     
                     [self calculateRoutesFrom:scoor to:dcoor];
                 }
                 else if (flag==2)
                 {
                     self.txtHome.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     strForHomeLatitude=[dictLocation valueForKey:@"lat"];
                     strForHomeLongitude=[dictLocation valueForKey:@"lng"];
                     
                     [PREF setObject:strForHomeLatitude forKey:PREF_HOME_LATITUDE];
                     [PREF setObject:strForHomeLongitude forKey:PREF_HOME_LONGITUDE];
                     [PREF setObject:self.txtHome.text forKey:PRFE_HOME_ADDRESS];
                     [PREF synchronize];
                     /*
                      if([self.txtWork.text isEqualToString:@""])
                      {
                      self.btnWorkGetFare.hidden=YES;
                      }
                      else
                      {
                      flag=3;
                      [self getLocationFromString:self.txtWork.text];
                      self.btnWorkGetFare.hidden=NO;
                      } */
                 }
                 else if (flag==3)
                 {
                     self.txtWork.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     strForWorkLatitude=[dictLocation valueForKey:@"lat"];
                     strForWorkLongitude=[dictLocation valueForKey:@"lng"];
                     [PREF setObject:strForWorkLatitude forKey:PREF_WORK_LATITUDE];
                     [PREF setObject:strForWorkLongitude forKey:PREF_WORK_LONGITUDE];
                     [PREF setObject:self.txtWork.text forKey:PREF_WORK_ADDRESS];
                     [PREF synchronize];
                 }
             }
             
         }
     }];
}
-(void)showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t
{
    self.viewForMarker.hidden=YES;
    [mapView_ clear];
    
    client_marker = [[GMSMarker alloc] init];
    client_marker.position = t;
    client_marker.icon = [UIImage imageNamed:@"pin_client_org"];
    client_marker.map = mapView_;
    
    destination_marker = [[GMSMarker alloc] init];
    destination_marker.position = f ;
    destination_marker.icon = [UIImage imageNamed:@"pin_destination"];
    destination_marker.map = mapView_;
    
    /* driver_marker = [[GMSMarker alloc] init];
     driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
     driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
     driver_marker.map = mapView_; */
    
    
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,GOOGLE_KEY_NEW2];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *routes_array = json[@"routes"];
    if( routes_array.count == 0) {
        [APPDELEGATE showToastMessage:@"No routes"];
        return;
    }
    GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:path];
    polyLinePath.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
    polyLinePath.strokeWidth = 5.f;
    polyLinePath.geodesic = YES;
    polyLinePath.map = mapView_;
    is_destination=YES;
    [self centerMapFirst:f two:t third:t];
}
-(void)centerMapFirst:(CLLocationCoordinate2D)pos1 two:(CLLocationCoordinate2D)pos2 third:(CLLocationCoordinate2D)pos3
{
    GMSCoordinateBounds* bounds =
    [[GMSCoordinateBounds alloc]initWithCoordinate:pos1 coordinate:pos2];
    bounds=[bounds includingCoordinate:pos3];
    CLLocationCoordinate2D location1 = bounds.southWest;
    CLLocationCoordinate2D location2 = bounds.northEast;
    
    float mapViewWidth = mapView_.frame.size.width;
    float mapViewHeight = mapView_.frame.size.height;
    
    MKMapPoint point1 = MKMapPointForCoordinate(location1);
    MKMapPoint point2 = MKMapPointForCoordinate(location2);
    
    MKMapPoint centrePoint = MKMapPointMake(
                                            (point1.x + point2.x) / 2,
                                            (point1.y + point2.y) / 2);
    CLLocationCoordinate2D centreLocation = MKCoordinateForMapPoint(centrePoint);
    
    double mapScaleWidth = mapViewWidth / fabs(point2.x - point1.x);
    double mapScaleHeight = mapViewHeight / fabs(point2.y - point1.y);
    double mapScale = MIN(mapScaleWidth, mapScaleHeight);
    
    double zoomLevel = 19.0 + log2(mapScale);
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:centreLocation zoom: zoomLevel];
    [mapView_ animateWithCameraUpdate:updatedCamera];
}

#pragma mark- Searching Method

- (IBAction)Searching:(id)sender
{
    aPlacemark=nil;
    [placeMarkArr removeAllObjects];
    self.tableForCity.hidden=YES;
    NSString *str;
    if(flag==4)
    {
        str=self.txtPickupAddress.text;
    }
    else if (flag==5)
    {
        str=self.txtDestination.text;
    }
    NSLog(@"%@",str);
    if(str == nil)
        self.tableForCity.hidden=YES;
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:@"input"]; // AUTOCOMPLETE API
    [dictParam setObject:@"sensor" forKey:@"false"]; // AUTOCOMPLETE API
    [dictParam setObject:GOOGLE_KEY_AUTOCOMPLETE forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewAutoCompletewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             //NSArray *arrAddress=[response valueForKey:@"results"];
             NSArray *arrAddress=[response valueForKey:@"predictions"]; //AUTOCOMPLTE API
             NSLog(@"text :%@",arrAddress);
             
             NSLog(@"AutoCompelete URL: = %@",[[response valueForKey:@"predictions"] valueForKey:@"description"]);
             
             if ([arrAddress count] > 0)
             {
                 self.tableForCity.hidden=NO;
                 
                 placeMarkArr=[[NSMutableArray alloc] initWithArray:arrAddress copyItems:YES];
                 //[placeMarkArr addObject:Placemark];
                 [self.tableForCity reloadData];
                 
                 if(arrAddress.count==0)
                 {
                     self.tableForCity.hidden=YES;
                 }
             }
             
         }
         
     }];
    
}
- (IBAction)SearchingDsti:(id)sender
{
    aPlacemark=nil;
    [placeMarkArr removeAllObjects];
    NSString *str;
    if (flag==1)
    {
        str=self.txtDestiSearch.text;
    }
    else if (flag==2)
    {
        str=self.txtHome.text;
    }
    else if (flag==3)
    {
        str=self.txtWork.text;
    }
    NSLog(@"dddd %@",str);
    if(str == nil)
        self.tableforCityFare.hidden=YES;
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:@"input"]; // AUTOCOMPLETE API
    [dictParam setObject:@"sensor" forKey:@"false"]; // AUTOCOMPLETE API
    [dictParam setObject:GOOGLE_KEY_AUTOCOMPLETE forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewAutoCompletewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress=[response valueForKey:@"predictions"]; //AUTOCOMPLTE API
             
             NSLog(@"AutoCompelete URL: = %@",[[response valueForKey:@"predictions"] valueForKey:@"description"]);
             if ([arrAddress count] > 0)
             {
                 placeMarkArr=[[NSMutableArray alloc] initWithArray:arrAddress copyItems:YES];
                 [self.tableforCityFare reloadData];
                 self.tableforCityFare.hidden=NO;
             }
         }
     }];
}
#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:SEGUE_ABOUT])
    {
        AboutVC *obj=[segue destinationViewController];
        obj.arrInformation=arrForInformation;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_ACCEPT])
    {
        ProviderDetailsVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strForWalkStatedLatitude=strForDriverLatitude;
        obj.strForWalkStatedLongitude=strForDriverLongitude;
        obj.strRequestType=@"RideNow";
    }
    else if([segue.identifier isEqualToString:@"contactus"])
    {
        ContactUsVC *obj=[segue destinationViewController];
        obj.dictContent=sender;
    }
    else if ([segue.identifier isEqualToString:@"segueToEastimate"])
    {
        EastimateFareVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strMinFare=strMinFare;
        obj.str_base_distance = str_base_distance;
        obj.str_price_per_unit_distance = str_price_per_unit_distance;
    }
}
-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [arrForApplicationType count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if(arrForApplicationType.count>0)
    {
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80.0f, 80.0f)];
            
            [((UIImageView *)view) downloadFromURL:(NSString*)[arrForApplicationType[index] icon] withPlaceholder:nil];
            view.contentMode = UIViewContentModeScaleAspectFill;
        }
        else
        {
            //get a reference to the label in the recycled view
        }
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    // view = arrForApplicationType[index];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 3.0;
    }
    
    return value;
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"data :%ld",(long)index);
    
}

-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    
}

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    currentIndex = carousel.currentItemIndex;
    if (arrForApplicationType.count > 0 )
    {
        
        NSString *name =[arrForApplicationType[currentIndex]name];
        
        if (![self.lblServiceType.text isEqualToString:name])
        {
            self.lblServiceType.text = [arrForApplicationType[carousel.currentItemIndex] name];
            self.llbServiceNmae.text= [arrForApplicationType[carousel.currentItemIndex] name];
            strForTypeid= [NSString stringWithFormat:@"%@",[arrForApplicationType [carousel.currentItemIndex] id_]];
            int indexs=(int)[strForTypeid integerValue]-1;
            NSLog(@"index s --%d and current index :%ld",indexs,(long)currentIndex);
            
            if (arrDriver.count>0)
            {
                [self getETA:[arrDriver objectAtIndex:0]];
            }
            
            NSDictionary *dict=[arrType objectAtIndex:currentIndex];
            
            self.lblMin_fare.text=[NSString stringWithFormat:@"€ %@",[dict valueForKey:@"min_fare"]];
            self.lblPerKm.text=[NSString stringWithFormat:@"€%.2f per %@",[[dict valueForKey:@"price_per_unit_distance"] floatValue],[dict valueForKey:@"unit"]];
            self.lblTimeCost.text=[NSString stringWithFormat:@"€%.2f per min",[[dict valueForKey:@"price_per_unit_time"] floatValue]];
            self.lMaxSize.text=[NSString stringWithFormat:@"%@",[dict valueForKey:@"max_size"]];
            
            strMinFare=[NSString stringWithFormat:@"%@",[dict valueForKey:@"base_price"]];
            strPassCap=[NSString stringWithFormat:@"%@",[dict valueForKey:@"max_size"]];
            str_base_distance = [NSString stringWithFormat:@"%@",[dict valueForKey:@"base_distance"]];
            str_price_per_unit_distance =  [NSString stringWithFormat:@"%f",[[dict valueForKey:@"price_per_unit_distance"] floatValue]];
            [PREF setObject:strMinFare forKey:PREF_FARE_AMOUNT];
            [PREF synchronize];
            
        }
    }
}

#pragma mark -
#pragma mark -  Datepicker Methods

- (void)datePickerChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    self.lblSelectedDate.text = strDate;
}

- (IBAction)onClickOKCancel:(id)sender
{
    if([strForCancelReason isEqualToString:@""])
    {
        [APPDELEGATE showToastMessage:@"Please select at least one reason for cancel the request"];
    }
    else
    {
        [self DeleteRequest];
        self.viewForCancelLaterRequest.hidden = YES;
    }
}

-(void)DeleteRequest
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        NSString *request_id=[NSString stringWithFormat:@"%@",[dictRequestData valueForKey:@"id"]];
        [dictParam setValue:[PREF objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[PREF objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:request_id forKey:PARAM_REQUEST_ID];
        [dictParam setValue:strForCancelReason forKey:@"cancel_reason"];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_DELETE_FUTURE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     
                     // [self.navigationController popViewControllerAnimated:YES];
                 }
                 else
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     
                     NSString *str=[NSString stringWithFormat:@"%@",[response valueForKey:@"error"]];
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[afn getErrorMessage:str] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                     [alert show];
                 }
             }
             
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
    
}
- (IBAction)onClickBtnDelay:(id)sender
{
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    strForCancelReason = @"1";
    NSLog(@"%@",strForCancelReason);
}

- (IBAction)onClickBtnChanged:(id)sender
{
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    strForCancelReason = @"2";
    
    NSLog(@"%@",strForCancelReason);
}

- (IBAction)onClickBookCab:(id)sender
{
    [self.btnOneCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnTwoCheck setBackgroundImage:[UIImage imageNamed:@"btnSimpleCheck"] forState:UIControlStateNormal];
    [self.btnThreeCheck setBackgroundImage:[UIImage imageNamed:@"btnCheck"] forState:UIControlStateNormal];
    
    strForCancelReason = @"3";
    NSLog(@"%@",strForCancelReason);
}

@end
