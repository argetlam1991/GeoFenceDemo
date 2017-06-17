//
//  ViewController.m
//  GeoFenceDemo
//
//  Created by Gu Han on 6/17/17.
//  Copyright © 2017 Gu Han. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statusCheck;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Turn off the user interface until permission is obtained
  self.uiSwitch.enabled = NO;
  self.statusCheck.enabled = NO;
  
  self.mapIsMoving = NO;
  
  // Set up the location Manager
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.allowsBackgroundLocationUpdates = YES;
  self.locationManager.pausesLocationUpdatesAutomatically = YES;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  self.locationManager.distanceFilter = 3; // meters
  
  // Zoom the map very close
  CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(0.0, 0.0);
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
  MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
  [self.mapView setRegion:adjustedRegion animated:YES];
  
  [self addCurrentAnnotation];
  
  // Check if the device can do geofences
  if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES) {
    // Regardless of authorization, if hardware can support it set up a georegion
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) ||
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
      self.uiSwitch.enabled = YES;
    } else {
      // If not authorized try and get it authorized
      [self.locationManager requestAlwaysAuthorization];
    
    }
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
  } else {
    self.statusLabel.text = @"GeoRegions not supported";
  }
  
}


- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
  if((currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse) ||
     (currentStatus == kCLAuthorizationStatusAuthorizedAlways)) {
    self.uiSwitch.enabled = YES;
  }
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
  self.mapIsMoving = YES;
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  self.mapIsMoving = NO;
}

- (IBAction)switchTapped:(UISwitch *)sender {
  if(self.uiSwitch.isOn) {
    self.mapView.showsUserLocation = YES;
    [self.locationManager startUpdatingLocation];
    //[self.locationManager startMonitoringForRegion:self.geoRegion];
    self.statusCheck.enabled = YES;
  } else {
    self.statusCheck.enabled = NO;
    //[self.locationManager stopMonitoringForRegion:self.geoRegion];
    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;
  }
  
}

- (void) addCurrentAnnotation {
  self.currentAnno = [[MKPointAnnotation alloc] init];
  self.currentAnno.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
  self.currentAnno.title = @"MY Location";
}

- (void) centerMap: (MKPointAnnotation *)centerPoint{
  [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
  self.currentAnno.coordinate = locations.lastObject.coordinate;
  if (self.mapIsMoving == NO) {
    [self centerMap:self.currentAnno];
  }
}



@end
