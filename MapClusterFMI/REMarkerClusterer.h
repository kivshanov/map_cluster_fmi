//
// REMarkerClusterer.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <float.h>
#import "REMarker.h"
#import "RELatLngBounds.h"
#import "RECluster.h"

@protocol REMarkerClusterDelegate <MKMapViewDelegate>

@optional

- (void)markerClusterer:(REMarkerClusterer *)markerCluster withMapView:(MKMapView *)mapView updateViewOfAnnotation:(id<MKAnnotation>)annotation withView:(MKAnnotationView *)annotationView;

@end

@interface REMarkerClusterer : NSObject <MKMapViewDelegate> {
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
@property (weak, readwrite, nonatomic) id<REMarkerClusterDelegate> delegate;
@property (copy, readwrite, nonatomic) NSString *clusterTitle;
@property (assign, readonly, nonatomic) BOOL animating;

- (id)initWithMapView:(MKMapView *)mapView delegate:(id <REMarkerClusterDelegate>)delegate;
- (void)addMarker:(id<REMarker>)marker;
- (void)addMarkers:(NSArray*)markers;
- (void)removeMarker:(id<REMarker>)marker;
- (void)removeAllMarkers;
- (void)zoomToAnnotationsBounds:(NSArray *)annotations;
- (void)clusterize:(BOOL)animated;

// Deprecated methods
//
- (void)clusterize __attribute__ ((deprecated)); // Use - (void)clusterize:(BOOL)animated;

@end
