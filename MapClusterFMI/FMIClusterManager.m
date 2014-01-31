//
// FMIClusterManager.m
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
@property (strong, readonly, nonatomic) NSArray *singleObjectAnnotations;

@end

@implementation FMIClusterManager

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _size = 25;
    _maxAnimationDelay = 0;
    _maxAnimationDuration = 0.25;
    _singleObjects = [[NSMutableArray alloc] init];
    _clusters = [[NSMutableArray alloc] init];
    
    _clusterName = @"%i items";
    
    return self;
}

- (id)initWithMapView:(MKMapView *)mapView delegate:(id<FMIClusterManager>)delegate
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

- (void)addSingleObject:(id<FMISingleMapObject>)singleObject
{
    [_singleObjects addObject:singleObject];
}

- (void)addSingleObjects:(NSArray*)singleObjects;
{
    [_singleObjects addObjectsFromArray:singleObjects];
}

- (void)removeSingleObject:(id<FMISingleMapObject>)singleObject
{
    [_singleObjects removeObject:singleObject];
}

- (void)removeAllSingleObjects
{
    [_clusters removeAllObjects];
    [_singleObjects removeAllObjects];
    [self.mapView removeAnnotations:self.singleObjectAnnotations];
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

- (void)addToClosestCluster:(id<FMISingleMapObject>)singleObject
{
    CGFloat distance = 40000; // Some large number
    FMIClusterObject *clusterToAddTo;
    for (FMIClusterObject *cluster in _clusters) {
        if ([cluster hasClusterCenter]) {
            CGFloat d = [self distanceBetweenPoints:cluster.coordinate p2:singleObject.coordinate];
            NSNumber *singleObjectType = ((FMISingleMapObject *)singleObject).type;
            NSNumber *clusterType = cluster.type;
            if (d < distance && [singleObjectType isEqualToNumber:clusterType]) {
                distance = d;
                clusterToAddTo = cluster;
            }
        }
    }
    
    if (clusterToAddTo && [clusterToAddTo isSingleObjectInClusterBounds:singleObject]) {
        [clusterToAddTo addSingleObject:singleObject];
    } else {
        FMIClusterObject *cluster = [[FMIClusterObject alloc] initWithCluster:self];
        [cluster addSingleObject:singleObject];
        [_clusters addObject:cluster];
    }
}

- (void)createClusters
{
    [_clusters removeAllObjects];
    for (id<FMISingleMapObject>singleObject in _singleObjects) {
        if (singleObject.coordinate.latitude == 0 && singleObject.coordinate.longitude == 0)
            continue;
             [self addToClosestCluster:singleObject];
    }
}

- (void)doClustering
{
    [self doClustering:YES];
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
    
    for (id<FMISingleMapObject>annotation in annotations) {
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

- (void)splitAnnotations:(NSDictionary *)dictionary
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
                    [UIView animateWithDuration:[self randomFloatBetween:0.25 and:_maxAnimationDuration] delay:[self randomFloatBetween:0 and:_maxAnimationDelay]
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


- (void)doClustering:(BOOL)animated
{
    if (_animating && animated)
        return;
        
    _animated = animated;
    
    [self createClusters];
    
    NSMutableDictionary *mixDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *remainingAnnotations = [NSMutableArray arrayWithCapacity:0];
    
    for (FMIClusterObject *cluster in ((self.singleObjectAnnotations.count > _clusters.count) ? self.singleObjectAnnotations : _clusters)) {
        if ([cluster isKindOfClass:[MKUserLocation class]])
            continue;
        NSInteger numberOfSingleObjects = 1;
        NSMutableArray *posiblesArrays = [NSMutableArray arrayWithCapacity:0];
        for (FMIClusterObject *cluster2 in ((self.singleObjectAnnotations.count <= _clusters.count)?self.singleObjectAnnotations:_clusters)) {
            if ([cluster2 isKindOfClass:[MKUserLocation class]])
                continue;
            NSInteger singleObjects = [cluster singleObjectsInClusterFromSingleObjects:cluster2.singleObjects];
            if(singleObjects >= numberOfSingleObjects){
                [posiblesArrays addObject:cluster2];
                numberOfSingleObjects = singleObjects;
            }
        }
        
        if (posiblesArrays.count == 1) {
            [self addObject:cluster toDictionary:mixDictionary withKey:((FMIClusterObject *)[posiblesArrays lastObject]).tag];
        } else if(posiblesArrays.count == 0) {
            [remainingAnnotations addObject:cluster];
        } else {
            NSInteger minor = INT16_MAX;
            NSInteger index = posiblesArrays.count-1;
            for (FMIClusterObject *cluster in posiblesArrays) {
                if (cluster.singleObjects.count < minor) {
                    index = [posiblesArrays indexOfObject:cluster];
                    minor = cluster.singleObjects.count;
                }
            }
            [self addObject:cluster toDictionary:mixDictionary withKey:((FMIClusterObject *)[posiblesArrays objectAtIndex:index]).tag];
        }
    }
    
    NSMutableDictionary *mergeators = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for (FMIClusterObject *cluster in ((self.singleObjectAnnotations.count <= _clusters.count) ? self.singleObjectAnnotations : _clusters)) {
        if ([cluster isKindOfClass:[MKUserLocation class]])
            continue;
        [mergeators setObject:cluster forKey:cluster.tag];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         mergeators,mergeatorsKey,
                         mixDictionary,mixesKey,
                         nil];
    
    if (self.singleObjectAnnotations.count == 0) {
        [_mapView addAnnotations:_clusters];
    }
    else if (self.singleObjectAnnotations.count > _clusters.count) {
        [self joinAnnotations:dic];
        //[self addAnnotationsWithOutSpliting:remainingAnnotations];
    } else if(self.singleObjectAnnotations.count < _clusters.count) {
        [self splitAnnotations:dic];
    }
}

- (void)joinAnnotations:(NSDictionary *)dictionary
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
                [UIView animateWithDuration:[self randomFloatBetween:0.25 and:_maxAnimationDuration] delay:[self randomFloatBetween:0 and:_maxAnimationDelay]
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
            if (_animated) ((FMIClusterObject *)[annotations lastObject]).singleObjects = endCluster.singleObjects;
            if ([self.delegate respondsToSelector:@selector(singleObjectCluster:withMapView:updateViewOfAnnotation:withView:)]) {
                [self.delegate singleObjectCluster:self withMapView:_mapView updateViewOfAnnotation:annotation withView:[_mapView viewForAnnotation:annotation]];
            }
        }
    }
}

- (NSArray *)singleObjectAnnotations
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
    [self doClustering:YES];
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
