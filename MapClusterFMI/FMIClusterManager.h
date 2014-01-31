//
// FMIClusterManager.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <float.h>
#import "FMISingleMapObject.h"
#import "FMIGeographicBounds.h"
#import "FMIClusterObject.h"

@protocol FMIClusterManager<MKMapViewDelegate>

@optional

- (void)singleObjectCluster:(FMIClusterManager *)singleObjectCluster withMapView:(MKMapView *)mapView updateViewOfAnnotation:(id<MKAnnotation>)annotation withView:(MKAnnotationView *)annotationView;

@end

@interface FMIClusterManager : NSObject <MKMapViewDelegate> {
    BOOL _animated;
}

@property (weak, readwrite, nonatomic) MKMapView *mapView;
@property (strong, readonly, nonatomic) NSMutableArray *singleObjects;
@property (strong, readonly, nonatomic) NSMutableArray *clusters;
@property (assign, readwrite, nonatomic) NSInteger size;
@property (readwrite, assign, nonatomic) BOOL isAverageCenter;
@property (assign, readwrite, nonatomic) CGFloat maxAnimationDelay;
@property (assign, readwrite, nonatomic) CGFloat maxAnimationDuration;
@property (weak, readwrite, nonatomic) id<FMIClusterManager> delegate;
@property (copy, readwrite, nonatomic) NSString *clusterName;
@property (assign, readonly, nonatomic) BOOL animating;

- (id)initWithMapView:(MKMapView *)mapView delegate:(id <FMIClusterManager>)delegate;
- (void)addSingleObject:(id<FMISingleMapObject>)singleObject;
- (void)addSingleObjects:(NSArray*)singleObjects;
- (void)removeSingleObject:(id<FMISingleMapObject>)singleObject;
- (void)removeAllSingleObjects;
- (void)zoomToAnnotationsBounds:(NSArray *)annotations;
- (void)doClustering:(BOOL)animated;

@end
