//
//  SBLocation.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SBLocation.h"

#import "NSString+SBUUID.h"

#import "SBUtility.h"

#import <tolo/Tolo.h>

#import <UIKit/UIApplication.h>

#import "SensorbergSDK.h"

#import "SBInternalEvents.h"

#import "SBEvent.h"

#import "SBInternalModels.h"

#import "SBSettings.h"

#import <objc_geohash/GeoHash.h>

@interface SBLocation() {
    CLLocationManager *locationManager;
    //
    NSArray *monitoredRegions;
    //
    NSMutableDictionary *sessions;
    
    NSArray *rawRegions;
    
    NSString *geolocation;
}

@end

@implementation SBLocation

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.distanceFilter = 500.0f;
        //
        sessions = [NSMutableDictionary new];
        //
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
}

#pragma mark - External methods

- (void)requestAuthorization:(BOOL)always {
    if (![CLLocationManager locationServicesEnabled]) {
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = SBLocationAuthorizationStatusUnavailable;
            event;
        }));
        return;
    }
    //
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] && ![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = SBLocationAuthorizationStatusUnavailable;
            event;
        }));
        return;
    }
    //
    if (always) {
        [locationManager requestAlwaysAuthorization];
    } else {
        [locationManager requestWhenInUseAuthorization];
    }
    //
    if ([self authorizationStatus] == SBLocationAuthorizationStatusUnimplemented) {
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = SBLocationAuthorizationStatusUnimplemented;
            event;
        }));
        //
        SBLog(@"Please set \"NSLocationAlwaysUsageDescription\" or \"NSLocationWhenInUseUsageDescription\" in info.plist of your Application!!");
    }
}

- (SBLocationAuthorizationStatus)authorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    SBLocationAuthorizationStatus authStatus;
    
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] &&
        ![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
        authStatus = SBLocationAuthorizationStatusUnimplemented;
        return authStatus;
    }
    //
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        {
            authStatus = SBLocationAuthorizationStatusRestricted;
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            authStatus = SBLocationAuthorizationStatusDenied;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            authStatus = SBLocationAuthorizationStatusAuthorized;
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            authStatus = SBLocationAuthorizationStatusAuthorized;
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        {
            authStatus = SBLocationAuthorizationStatusNotDetermined;
            break;
        }
    }
    //
    return authStatus;
}

- (void)startMonitoring:(NSArray *)regions {
    [locationManager startUpdatingLocation];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager startMonitoringSignificantLocationChanges];
    }
    //
    _isMonitoring = YES;
    //
    if (regions.count==0) {
        return;
    }
    //
    if (rawRegions != regions) {
        rawRegions = [NSArray arrayWithArray:regions];
    }
    //
    NSMutableSet *triggers = [NSMutableSet new];
    NSMutableSet *beaconRegions = [NSMutableSet new];
    NSMutableSet *geofences = [NSMutableSet new];
    NSMutableSet *beacons = [NSMutableSet new];
    //
    for (NSString *region in regions) {
        if (region.length==14) {
            SBMGeofence *fence = [[SBMGeofence alloc] initWithGeoHash:region];
            if (!isNull(fence)) {
                [triggers addObject:fence];
                [geofences addObject:fence];
            }
        } else if (region.length==32) {
            SBMRegion *beacon = [[SBMRegion alloc] initWithString:region];
            if (!isNull(beacon)) {
                [triggers addObject:beacon];
                [beaconRegions addObject:beacon];
            }
        } else if (region.length==42) {
            SBMBeacon *beacon = [[SBMBeacon alloc] initWithString:region];
            if (!isNull(beacon)) {
                [triggers addObject:beacon];
                [beacons addObject:beacon];
            }
        }
    }
    
    if (triggers.count < kSBMaxMonitoringRegionCount) {
        monitoredRegions = [NSArray arrayWithArray:triggers.allObjects];
    } else {
        monitoredRegions = [NSArray arrayWithArray:beaconRegions.allObjects];
        //
        NSMutableArray *locations = [NSMutableArray arrayWithArray:[self sortGeolocations:geofences.allObjects]];
        //
        while (monitoredRegions.count<kSBMaxMonitoringRegionCount && locations.count>0) {
            SBMTrigger *trigger = [locations firstObject];
            if (trigger) {
                [locations removeObject:trigger];
                monitoredRegions = [monitoredRegions arrayByAddingObject:trigger];
            }
        }
    }
    //
    [self performSelectorOnMainThread:@selector(stopMonitoring) withObject:self waitUntilDone:YES];
    //
    for (SBMTrigger *trigger in monitoredRegions) {
        if ([trigger isKindOfClass:[SBMGeofence class]]) {
            [self startMonitoringForGeoRegion:trigger];
        } else if ([trigger isKindOfClass:[SBMRegion class]] || ([trigger isKindOfClass:[SBMBeacon class]])) {
            [self startMonitoringForBeaconRegion:trigger];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    PUBLISH(({
        SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
        event.locationAuthorization = [self authorizationStatus];
        event;
    }));
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    } else if ([region isKindOfClass:[CLCircularRegion class]]) {
        PUBLISH(({
            SBEventRegionEnter *enter = [SBEventRegionEnter new];
            enter.beacon = [[SBMGeofence alloc] initWithGeoHash:region.identifier.pathExtension];
            enter.location = _gps;
            enter;
        }));
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self checkRegionExit];
    } else if ([region isKindOfClass:[CLCircularRegion class]]) {
        PUBLISH(({
            SBEventRegionExit *exit = [SBEventRegionExit new];
            exit.beacon = [[SBMGeofence alloc] initWithGeoHash:region.identifier.pathExtension];
            exit.location = _gps;
            exit;
        }));
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count) {
        [self updateSessionsWithBeacons:beacons];
    }
    //
    [self checkRegionExit];
    //
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [self handleLocationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    [self handleLocationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    SBLog(@"Current location: %@", locations.lastObject);
    _gps = locations.lastObject;
    if (!geolocation) {
        geolocation = [GeoHash hashForLatitude:_gps.coordinate.latitude longitude:_gps.coordinate.longitude length:9];
    }
    PUBLISH(({
        SBEventLocationUpdated *event = [SBEventLocationUpdated new];
        event.location = _gps;
        event;
    }));
    //
    NSString *newLocation = [GeoHash hashForLatitude:_gps.coordinate.latitude longitude:_gps.coordinate.longitude length:9];
    if (![geolocation isEqualToString:newLocation]) {
        geolocation = newLocation;
        SBLog(@"Updating regions");
        [self startMonitoring:rawRegions];
    }
    //
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self handleLocationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    [self handleLocationError:error];
}

#pragma mark - Internal methods

- (void)updateSessionsWithBeacons:(NSArray *)beacons {
    if (!sessions) {
        sessions = [NSMutableDictionary new];
    }
    
    for (CLBeacon *beacon in beacons) {
        SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithCLBeacon:beacon];
        
        SBMSession *session = [sessions objectForKey:sbBeacon.tid];
        if (!session) {
            session = [[SBMSession alloc] initWithId:sbBeacon.tid];
            // Because we don't have a session with this beacon, let's fire an SBEventRegionEnter event
            PUBLISH(({
                SBEventRegionEnter *enter = [SBEventRegionEnter new];
                enter.beacon = sbBeacon;
                enter.rssi = [NSNumber numberWithInteger:beacon.rssi].intValue;
                enter.proximity = beacon.proximity;
                enter.accuracy = beacon.accuracy;
                enter.location = _gps;
                enter;
            }));
        }
        session.lastSeen = [[NSDate date] timeIntervalSince1970];
        if (session.exit) {
            session.exit = 0;
        }
        //
        [sessions setObject:session forKey:sbBeacon.tid];
        //
        if (beacon.proximity!=CLProximityUnknown) {
            PUBLISH(({
                SBEventRangedBeacon *event = [SBEventRangedBeacon new];
                event.beacon = sbBeacon;
                event.rssi = [NSNumber numberWithInteger:beacon.rssi].intValue;
                event.proximity = beacon.proximity;
                event.accuracy = beacon.accuracy;
                event;
            }));
        }
    }
}

- (void)checkRegionExit {
    //
    NSTimeInterval monitoringDelay = [SBSettings sharedManager].settings.monitoringDelay;
    NSTimeInterval rangingDelay = [SBSettings sharedManager].settings.rangingSuppression;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    for (SBMSession *session in sessions.allValues) {
        if (session.lastSeen + monitoringDelay <= now ) {
            if (session.exit<=0) {
                SBLog(@"Setting exit for %@", session.pid);
                session.exit = now;
            } else if ( session.exit + rangingDelay <= now ) {
                PUBLISH(({
                    SBEventRegionExit *exit = [SBEventRegionExit new];
                    exit.beacon = [[SBMBeacon alloc] initWithString:session.pid];
                    exit.location = _gps;
                    exit;
                }));
            }
        }
    }
}

- (void)startMonitoringForBeaconRegion:(SBMTrigger *)region {
    NSUUID *uuid;
    CLBeaconRegion *beaconRegion;
    NSString *tmpRegion = [region.tid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (tmpRegion.length==32) {
        uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:tmpRegion]];
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[kSBIdentifier stringByAppendingPathExtension:tmpRegion]];
    } else if (tmpRegion.length==42) {
        SBMBeacon *b = [[SBMBeacon alloc] initWithString:tmpRegion];
        uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:b.uuid]];
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                               major:b.major
                                                               minor:b.minor
                                                          identifier:[kSBIdentifier stringByAppendingPathExtension:tmpRegion]];
    }
    [locationManager startMonitoringForRegion:beaconRegion];
    SBLog(@"Started monitoring for %@",beaconRegion.identifier);
}

- (void)startMonitoringForGeoRegion:(SBMGeofence *)region {
    CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(region.latitude, region.longitude) radius:region.radius identifier:[kSBIdentifier stringByAppendingPathExtension:region.tid]];
    [locationManager startMonitoringForRegion:circularRegion];
    SBLog(@"Started monitoring for %@",circularRegion.identifier);
}

- (void)stopMonitoring {
    for (CLRegion *region in locationManager.monitoredRegions.allObjects) {
        if ([region.identifier rangeOfString:kSBIdentifier].location!=NSNotFound) {
            [locationManager stopMonitoringForRegion:region];
            SBLog(@"Stopped monitoring for %@",region.identifier);
        }
    }
}

- (void)handleLocationError:(NSError *)error {
    if (isNull(error)) {
        return;
    }
    SBLog(@"Location error: %@", error);
    switch (error.code) {
        case kCLErrorDenied: {
            // user denied!
            break;
        }
        case kCLErrorRangingUnavailable: {
            // airplane mode, location or bluetooth unavailable!
            break;
        }
        case kCLErrorRegionMonitoringDenied: {
            // user denied access to region monitoring!
            break;
        }
        case kCLErrorRegionMonitoringSetupDelayed: {
            // region monitoring was delayed
            break;
        }
        case kCLErrorRegionMonitoringFailure: {
            // failed to start monitoring for a region (too many monitored regions or radius of geofence is too high
            break;
        }
        case kCLErrorRangingFailure: {
            // general ranging error
            break;
        }
        case kCLErrorRegionMonitoringResponseDelayed: {
            SBLog(@"Alternate region: %@",kCLErrorUserInfoAlternateRegionKey);
            break;
        }
        default:
            break;
    }
}

- (NSArray *)sortGeolocations:(NSArray *)locations {
    CLLocation *currentLocation = [locationManager location];
    //
    NSArray *sorted = [locations sortedArrayUsingComparator:^NSComparisonResult(SBMGeofence *location1, SBMGeofence *location2) {
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:location1.latitude longitude:location1.longitude];
        
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location2.latitude longitude:location2.longitude];
        
        if ([currentLocation distanceFromLocation:loc1] < [currentLocation distanceFromLocation:loc2]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return sorted;
}

#pragma mark - Events
#pragma mark SBEventApplicationWillEnterForeground
SUBSCRIBE(SBEventApplicationWillEnterForeground) {
    //
}

#pragma mark SBEventApplicationDidEnterBackground
SUBSCRIBE(SBEventApplicationDidEnterBackground) {
    
}

SUBSCRIBE(SBEventRegionExit) {
    [sessions removeObjectForKey:event.beacon.tid];
    SBLog(@"Session closed for %@", event.beacon.tid);
}

#pragma mark - For Unit Tests

- (NSDictionary *)currentSessions {
    return [sessions copy];
}

@end
