//
// FMIClusterMarker
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FMIClusterManager.h"
#import "FMIClusterObject.h"

#define mixesKey @"mixesKey"
#define mergeatorsKey @"remainedKey"

@interface FMIClusterManager ()

@property (assign, readwrite, nonatomic) BOOL animating;
@property (strong, readonly, nonatomic) NSArray *markerAnnotations;

@end

@implementation FMIClusterManager

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _gridSize = 25;
    _maxDelayOfSplitAnimation = 0;
    _maxDelayOfSplitAnimation = 0.25;
    _tempViews = [[NSMutableArray alloc] init];
    _markers = [[NSMutableArray alloc] init];
    _clusters = [[NSMutableArray alloc] init];
    
    _clusterTitle = @"%i items";
    
    return self;
}

- (id)initWithMapView:(MKMapView *)mapView delegate:(id<FMIClusterMarker>)delegate
{
    self = [self init];
    if (!self)
        return nil;
    
    self.mapView = mapView;
    self.delegate = delegate;
    
    return self;
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    _mapView.delegate = self;
}

- (void)addMarker:(id<FMIMarker>)marker
{
    [_markers addObject:marker];
}

- (void)addMarkers:(NSArray*)markers;
{
    [_markers addObjectsFromArray:markers];
}

- (void)removeMarker:(id<FMIMarker>)marker;
{
    [_markers removeObject:marker];
}

- (void)removeAllMarkers
{
    [_clusters removeAllObjects];
    [_markers removeAllObjects];
    [self.mapView removeAnnotations:self.markerAnnotations];
}


- (BOOL)markerInBounds:(id<FMIMarker>)marker
{
    CGPoint pix = [self.mapView convertCoordinate:marker.coordinate toPointToView:nil];
    if (pix.x >=-150 && pix.x <= _mapView.frame.size.width+150) {
        if (pix.y >=-150 && pix.y <= _mapView.frame.size.height+150) {
            return YES;
        }
    }
    return NO;
}


- (void)setMapRegionForMinLat:(CGFloat)minLatitude minLong:(CGFloat)minLongitude maxLat:(CGFloat)maxLatitude maxLong:(CGFloat)maxLongitude
{    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    if (region.span.latitudeDelta < 0.059863)
        region.span.latitudeDelta = 0.059863;
    
    if (region.span.longitudeDelta < 0.059863)
        region.span.longitudeDelta = 0.059863;
    
    if ((region.center.latitude >= -90) && (region.center.latitude <= 90) && (region.center.longitude >= -180) && (region.center.longitude <= 180)) {
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
}

- (CGFloat)distanceBetweenPoints:(CLLocationCoordinate2D)p1 p2:(CLLocationCoordinate2D)p2
{
	CGFloat R = 6371; // Radius of the Earth in km
	CGFloat dLat = (p2.latitude - p1.latitude) * M_PI / 180;
	CGFloat dLon = (p2.longitude - p1.longitude) * M_PI / 180;
	CGFloat a = sin(dLat / 2) * sin(dLat / 2) + cos(p1.latitude * M_PI / 180) * cos(p2.latitude * M_PI / 180) * sin(dLon / 2) * sin(dLon / 2);
	CGFloat c = 2 * atan2(sqrt(a), sqrt(1 - a));
	CGFloat d = R * c;
	return d;
}

- (void)addToClosestCluster:(id<FMIMarker>)marker
{
    CGFloat distance = 40000; // Some large number
    FMIClusterObject *clusterToAddTo;
    for (FMIClusterObject *cluster in _clusters) {
        if ([cluster hasCenter]) {
            CGFloat d = [self distanceBetweenPoints:cluster.coordinate p2:marker.coordinate];
            if (d < distance) {
                distance = d;
                clusterToAddTo = cluster;
            }
        }
    }
    
    if (clusterToAddTo && [clusterToAddTo isMarkerInClusterBounds:marker]) {
        [clusterToAddTo addMarker:marker];
    } else {
        FMIClusterObject *cluster = [[FMIClusterObject alloc] initWithClusterer:self];
        [cluster addMarker:marker];
        [_clusters addObject:cluster];
    }
}

- (void)createClusters
{
    [_clusters removeAllObjects];
    for (id<FMIMarker>marker in _markers) {
        if (marker.coordinate.latitude == 0 && marker.coordinate.longitude == 0) 
            continue;
        //if ([self markerInBounds:marker])
             [self addToClosestCluster:marker];
    }
}

- (void)clusterize
{
    [self clusterize:YES];
}

- (void)addObject:(id) object toDictionary:(NSMutableDictionary *)dictionary withKey:(NSString *)key
{
    NSMutableArray *objectInKey = [dictionary objectForKey:key];
    if(objectInKey == nil){
        objectInKey = [NSMutableArray arrayWithCapacity:0];
        [objectInKey addObject:object];
        [dictionary setObject:objectInKey forKey:key];
    }else{
        [objectInKey addObject:object];
    }
}

- (void)zoomToAnnotationsBounds:(NSArray *)annotations
{
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (id<FMIMarker>annotation in annotations) {
        CGFloat annotationLat = annotation.coordinate.latitude;
        CGFloat annotationLong = annotation.coordinate.longitude;
        if (annotationLat == 0 && annotationLong == 0)
            continue;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 10.0, 40.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D rightCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D bottomCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D leftCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.mapView];
    
    CGFloat latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    CGFloat longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    CGFloat latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    CGFloat longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (void)splitAnnotationsWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *mergeators = [dictionary objectForKey:mergeatorsKey];
    NSDictionary *mixes = [dictionary objectForKey:mixesKey];
    
    for (NSString *mergeatorKey in [mergeators allKeys]){
        NSArray *annotations = [mixes objectForKey:mergeatorKey];
        FMIClusterObject *endCluster = [mergeators objectForKey:mergeatorKey];
        
        if (_animated) {
            for (FMIClusterObject *annotation in annotations) {
                [_mapView addAnnotation:annotation];
                if(annotation.coordinate.latitude != endCluster.coordinate.latitude || annotation.coordinate.longitude != endCluster.coordinate.longitude) {
                    CLLocationCoordinate2D realCoordinate = annotation.coordinate;
                    annotation.coordinate = endCluster.coordinate;
                    _animating = YES;
                    __typeof (&*self) __weak weakSelf = self;
                    [UIView animateWithDuration:[self randomFloatBetween:0.25 and:_maxDurationOfSplitAnimation] delay:[self randomFloatBetween:0 and:_maxDelayOfSplitAnimation]
                                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                                     animations:^{
                                         annotation.coordinate = realCoordinate;
                                     }  completion:^(BOOL finished){
                                         weakSelf.animating = NO;
                                         [_mapView removeAnnotation:annotation];
                                         [_mapView addAnnotation:annotation];
                                     }];
                }
                [_mapView removeAnnotation:endCluster];
                
            }
        } else {
            [_mapView addAnnotations:annotations];
            [_mapView removeAnnotation:endCluster];
        }
    }
}


- (void)clusterize:(BOOL)animated
{
    if (_animating && animated)
        return;
        
    _animated = animated;
    
    [self createClusters];
    
    NSMutableDictionary *mixDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *remainingAnnotations = [NSMutableArray arrayWithCapacity:0];
    
    for (FMIClusterObject *cluster in ((self.markerAnnotations.count > _clusters.count) ? self.markerAnnotations : _clusters)) {
        if ([cluster isKindOfClass:[MKUserLocation class]])
            continue;
        NSInteger numberOfMarkers = 1;
        NSMutableArray *posiblesArrays = [NSMutableArray arrayWithCapacity:0];
        for (FMIClusterObject *cluster2 in ((self.markerAnnotations.count <= _clusters.count)?self.markerAnnotations:_clusters)) {
            if ([cluster2 isKindOfClass:[MKUserLocation class]])
                continue;
            NSInteger markers = [cluster markersInClusterFromMarkers:cluster2.markers];
            if(markers >= numberOfMarkers){
                [posiblesArrays addObject:cluster2];
                numberOfMarkers = markers;
            }
        }
        
        if (posiblesArrays.count == 1) {
            [self addObject:cluster toDictionary:mixDictionary withKey:((FMIClusterObject *)[posiblesArrays lastObject]).coordinateTag];
        } else if(posiblesArrays.count == 0) {
            [remainingAnnotations addObject:cluster];
        } else {
            NSInteger minor = INT16_MAX;
            NSInteger index = posiblesArrays.count-1;
            for (FMIClusterObject *cluster in posiblesArrays) {
                if (cluster.markers.count < minor) {
                    index = [posiblesArrays indexOfObject:cluster];
                    minor = cluster.markers.count;
                }
            }
            [self addObject:cluster toDictionary:mixDictionary withKey:((FMIClusterObject *)[posiblesArrays objectAtIndex:index]).coordinateTag];
        }
    }
    
    NSMutableDictionary *mergeators = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for (FMIClusterObject *cluster in ((self.markerAnnotations.count <= _clusters.count) ? self.markerAnnotations : _clusters)) {
        if ([cluster isKindOfClass:[MKUserLocation class]])
            continue;
        [mergeators setObject:cluster forKey:cluster.coordinateTag];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         mergeators,mergeatorsKey,
                         mixDictionary,mixesKey,
                         nil];
    
    if (self.markerAnnotations.count == 0) {
        [_mapView addAnnotations:_clusters];
    }
    else if (self.markerAnnotations.count > _clusters.count) {
        [self joinAnnotationsWithDictionary:dic];
        //[self addAnnotationsWithOutSpliting:remainingAnnotations];
    } else if(self.markerAnnotations.count < _clusters.count) {
        [self splitAnnotationsWithDictionary:dic];
    }
}


- (void)joinAnnotationsWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *mergeators = [dictionary objectForKey:mergeatorsKey];
    NSDictionary *mixes = [dictionary objectForKey:mixesKey];
    
    for (NSString *mergeatorKey in [mergeators allKeys]) {
        NSArray *annotations = [mixes objectForKey:mergeatorKey];
        FMIClusterObject *endCluster = [mergeators objectForKey:mergeatorKey];
        for (FMIClusterObject *annotation in annotations){
            if (_animated) {
                _animating = YES;
                __typeof (&*self) __weak weakSelf = self;
                [UIView animateWithDuration:[self randomFloatBetween:0.25 and:_maxDurationOfSplitAnimation] delay:[self randomFloatBetween:0 and:_maxDelayOfSplitAnimation]
                                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     annotation.coordinate = endCluster.coordinate;
                                 }  completion:^(BOOL finished){
                                     weakSelf.animating = NO;
                                     if (annotation != [annotations lastObject]) {
                                         [weakSelf.mapView removeAnnotation:annotation];
                                     } else {
                                         [_mapView removeAnnotation:annotation];
                                         [_mapView addAnnotation:annotation];
                                     }
                                 }];
            }else{
                [_mapView removeAnnotations:annotations];
                [_mapView addAnnotation:endCluster];
            }
            ((FMIClusterObject *)[annotations lastObject]).title = endCluster.title;
            ((FMIClusterObject *)[annotations lastObject]).subtitle = endCluster.subtitle;
            MKAnnotationView *view = [_mapView viewForAnnotation:(_animated)?[annotations lastObject]:endCluster];
            [[view superview] bringSubviewToFront:view];
            if (_animated) ((FMIClusterObject *)[annotations lastObject]).markers = endCluster.markers;
            if ([self.delegate respondsToSelector:@selector(markerClusterer:withMapView:updateViewOfAnnotation:withView:)]) {
                [self.delegate markerClusterer:self withMapView:_mapView updateViewOfAnnotation:annotation withView:[_mapView viewForAnnotation:annotation]];
            }
        }
    }
}

- (NSArray *)markerAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSObject *annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]])
            continue;
        
        [annotations addObject:annotation];
    }
    return annotations;
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self clusterize:YES];
    [self.mapView deselectAnnotation:[self.mapView.selectedAnnotations objectAtIndex:0] animated:NO];
    
    if ([_delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)])
        [_delegate mapView:mapView regionDidChangeAnimated:animated];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([_delegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [_delegate mapView:mapView viewForAnnotation:annotation];
    }
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
	static NSString *pinID = @"REDefaultPin";
    
	MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    
	if (pinView == nil) {
		pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
    }
	
	pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    return pinView;
}

@end
