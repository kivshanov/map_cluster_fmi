//
// FMIClusterMarker
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <float.h>
#import "FMIMarker.h"
#import "FMIGeographicBounds.h"
#import "FMIClusterObject.h"

@protocol FMIClusterMarker <MKMapViewDelegate>

@optional

- (void)markerClusterer:(FMIClusterManager *)markerCluster withMapView:(MKMapView *)mapView updateViewOfAnnotation:(id<MKAnnotation>)annotation withView:(MKAnnotationView *)annotationView;

@end

@interface FMIClusterManager : NSObject <MKMapViewDelegate> {
    NSMutableArray *_tempViews;
    BOOL _animated;
}

@property (weak, readwrite, nonatomic) MKMapView *mapView;
@property (strong, readonly, nonatomic) NSMutableArray *markers;
@property (strong, readonly, nonatomic) NSMutableArray *clusters;
@property (assign, readwrite, nonatomic) NSInteger gridSize;
@property (assign, readwrite, nonatomic) BOOL isAverageCenter;
@property (assign, readwrite, nonatomic) CGFloat maxDelayOfSplitAnimation;
@property (assign, readwrite, nonatomic) CGFloat maxDurationOfSplitAnimation;
@property (weak, readwrite, nonatomic) id<FMIClusterMarker> delegate;
@property (copy, readwrite, nonatomic) NSString *clusterTitle;
@property (assign, readonly, nonatomic) BOOL animating;

- (id)initWithMapView:(MKMapView *)mapView delegate:(id <FMIClusterMarker>)delegate;
- (void)addMarker:(id<FMIMarker>)marker;
- (void)addMarkers:(NSArray*)markers;
- (void)removeMarker:(id<FMIMarker>)marker;
- (void)removeAllMarkers;
- (void)zoomToAnnotationsBounds:(NSArray *)annotations;
- (void)clusterize:(BOOL)animated;

@end
