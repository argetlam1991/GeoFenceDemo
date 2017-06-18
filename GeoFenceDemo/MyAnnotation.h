//
//  MyAnnotation.h
//  GeoFenceDemo
//
//  Created by Gu Han on 6/17/17.
//  Copyright © 2017 Gu Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
@interface MyAnnotation : NSObject <MKAnnotation> {
  CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView;

@end
