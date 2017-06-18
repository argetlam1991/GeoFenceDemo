//
//  MyAnnotation.m
//  GeoFenceDemo
//
//  Created by Gu Han on 6/17/17.
//  Copyright © 2017 Gu Han. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
@synthesize coordinate;

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location {
  self = [super init];
  if (self) {
    _title = newTitle;
    coordinate = location;
  }
  return self;
}

- (MKAnnotationView *)annotationView {
  MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MyAnnotation"];
  annotationView.enabled = YES;
  annotationView.canShowCallout = YES;
  annotationView.image = [UIImage imageNamed:@"pin"];
  annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  
  return annotationView;
}
@end
