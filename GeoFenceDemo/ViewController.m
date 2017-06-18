//
//  ViewController.m
//  GeoFenceDemo
//
//  Created by Gu Han on 6/17/17.
//  Copyright © 2017 Gu Han. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"
#import "UserNotifications/UserNotifications.h"
#import "MyAnnotation.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *pinIcon;
@property (strong, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statusCheck;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;
@property (strong, nonatomic) CLCircularRegion *geoRegion;
@property (strong, nonatomic) MyAnnotation *nasaAnno;
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
  self.locationManager.distanceFilter = 1; // meters

  
  // Zoom the map very close
  CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(0.0, 0.0);
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
  MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
  [self.mapView setRegion:adjustedRegion animated:YES];
  [self locateNASA];
  [self addCurrentAnnotation];
  
  //Set up a geoRegion object
  [self setUpGeoRegion];
  UNUserNotificationCenter *center = [UNUserNotificationCenter
                                      currentNotificationCenter];
  center.delegate = self;

  
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


- (void) setUpGeoRegion{
  self.geoRegion = [[CLCircularRegion alloc]
                    initWithCenter:CLLocationCoordinate2DMake(37.408892, -122.064457)
                    radius:30
                    identifier:@"MyRegionIdentifier"];
}



- (IBAction)switchTapped:(UISwitch *)sender {
  if(self.uiSwitch.isOn) {
    self.mapView.showsUserLocation = YES;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringForRegion:self.geoRegion];
    self.statusCheck.enabled = YES;
  } else {
    self.statusCheck.enabled = NO;
    [self.locationManager stopMonitoringForRegion:self.geoRegion];
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

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
  content.title = [NSString localizedUserNotificationStringForKey:@"GeoFence!" arguments:nil];
  content.body = [NSString localizedUserNotificationStringForKey:@"Entring the region!"
                                                       arguments:nil];
  UNNotificationRequest *request = [UNNotificationRequest
                                    requestWithIdentifier:@"EnterFence" content:content trigger:nil];
  UNUserNotificationCenter *center = [UNUserNotificationCenter
                                      currentNotificationCenter];
  [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"%@", error.localizedDescription);
    }
  }];
  
  self.eventLabel.text = @"Entered";
  
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
  UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
  content.title = [NSString localizedUserNotificationStringForKey:@"GeoFence!" arguments:nil];
  content.body = [NSString localizedUserNotificationStringForKey:@"exiting the region!"
                                                       arguments:nil];
  UNNotificationRequest *request = [UNNotificationRequest
                                    requestWithIdentifier:@"ExitFence" content:content trigger:nil];
  UNUserNotificationCenter *center = [UNUserNotificationCenter
                                      currentNotificationCenter];
  [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"%@", error.localizedDescription);
    }
  }];
  
  
  self.eventLabel.text = @"Exited";
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull void (^)(UNNotificationPresentationOptions))completionHandler {
  completionHandler(UNNotificationPresentationOptionAlert);
}


- (IBAction)statusCheckTapped:(UIBarButtonItem *)sender {
  [self.locationManager requestStateForRegion:self.geoRegion];
  
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region{
  if (state == CLRegionStateUnknown) {
    self.statusLabel.text = @"Unknow";
  } else if(state == CLRegionStateInside) {
    self.statusLabel.text = @"Inside";
  } else if(state == CLRegionStateOutside) {
    self.statusLabel.text = @"OutSide";
  } else {
    self.statusLabel.text = @"Mystery";
  }
}

- (void)locateNASA {
  self.nasaAnno = [[MyAnnotation alloc] initWithTitle:@"NASA" Location:CLLocationCoordinate2DMake(37.408892, -122.064457)];
  [self.mapView addAnnotation:self.nasaAnno];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if([annotation isKindOfClass:[MyAnnotation class]]) {
    MyAnnotation *myLocation = (MyAnnotation *)annotation;
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MyCustomAnnotation"];
    if (annotationView == nil)
      annotationView = myLocation.annotationView;
    else
      annotationView.annotation = annotation;
    return annotationView;
  } else {
    return nil;
  }
}

@end
