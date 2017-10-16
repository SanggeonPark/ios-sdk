//
//  SBInternalModels.h
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

#import <JSONModel/JSONModel.h>

#import "SBModel.h"

@interface SBInternalModels : SBModel
@end

#pragma mark - Resolver models

@protocol SBMContent @end
@interface SBMContent : JSONModel
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDictionary <Optional> *payload;
@property (strong, nonatomic) NSString *url;
@end

@protocol SBMTimeframe @end
@interface SBMTimeframe : JSONModel
@property (strong, nonatomic) NSDate <Optional> *start;
@property (strong, nonatomic) NSDate <Optional> *end;
@end

@protocol SBMAction @end
@interface SBMAction : JSONModel
@property (strong, nonatomic) NSString *eid;
@property (nonatomic) SBTriggerType trigger;
@property (strong, nonatomic) NSArray *beacons;
@property (nonatomic) int suppressionTime; // in seconds
@property (nonatomic) int delay; //
@property (nonatomic) BOOL reportImmediately; // when true flush the history immediately
@property (nonatomic) BOOL sendOnlyOnce; //
@property (strong, nonatomic) NSDate *deliverAt;
@property (strong, nonatomic) SBMContent *content;
@property (nonatomic) SBActionType type;
@property (strong, nonatomic) NSArray <SBMTimeframe> *timeframes;
@property (strong, nonatomic) NSString *typeString DEPRECATED_ATTRIBUTE;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *dt;
@end

#pragma mark - Post events

@protocol SBMMonitorEvent @end
@interface SBMMonitorEvent : JSONModel
@property (strong, nonatomic) NSString <Optional> *pid;
@property (strong, nonatomic) NSString <Optional> *location;
@property (strong, nonatomic) NSDate <Optional> *dt;
@property (strong, nonatomic) NSString <Optional> *pairingId;
@property (nonatomic) int trigger;
@end

@protocol SBMSession @end
@interface SBMSession : JSONModel
- (instancetype)initWithId:(NSString*)uid;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *enter;
@property (nonatomic) NSTimeInterval exit;
@property (nonatomic) NSTimeInterval lastSeen;
@property (copy, nonatomic) NSString <Optional> *pairingId;
@end

#pragma mark - Post models

@protocol SBMReportAction @end
@interface SBMReportAction : JSONModel
@property (strong, nonatomic) NSString  *eid;
@property (strong, nonatomic) NSString  *uuid;
@property (strong, nonatomic) NSString  *pid;
@property (strong, nonatomic) NSDate    *dt;
@property (strong, nonatomic) NSString <Optional> *location;
@property (nonatomic) int trigger;
@property (strong, nonatomic) NSDictionary *reaction DEPRECATED_ATTRIBUTE;
@end

@protocol SBMReportConversion @end
@interface SBMReportConversion : JSONModel
@property (strong, nonatomic) NSString *action;
@property (strong, nonatomic) NSDate *dt;
@property (nonatomic) SBConversionType type;
@property (strong, nonatomic) NSString <Optional> *location;
@end

@protocol SBMPostLayout @end
@interface SBMPostLayout : JSONModel
@property (strong, nonatomic) NSDate *deviceTimestamp;
@property (strong, nonatomic) NSArray <SBMMonitorEvent> *events;
@property (strong, nonatomic) NSArray <SBMReportAction> *actions;
@property (strong, nonatomic) NSArray <SBMReportConversion> *conversions;
@end

@protocol SBMGetLayout @end
@interface SBMGetLayout : JSONModel
@property (strong, nonatomic) NSArray *accountProximityUUIDs;
@property (nonatomic) int reportTrigger;
@property (strong, nonatomic) NSArray <SBMAction> *actions;
@property (nonatomic) BOOL currentVersion;
@property (strong, nonatomic) NSArray <SBMContent> *instantActions;

- (void)checkCampaignsForBeacon:(SBMTrigger *)beacon trigger:(SBTriggerType)trigger;

@end

@interface SBMSettings : JSONModel

@property (nonatomic, assign) NSTimeInterval monitoringDelay; // in Seconds.
@property (nonatomic, assign) NSTimeInterval postSuppression; // in Seconds.
@property (nonatomic, assign) NSTimeInterval rangingSuppression; // in seconds
@property (nonatomic, readonly, copy) NSDictionary *defaultBeaconRegions;
@property (nonatomic, copy) NSDictionary *customBeaconRegions;
@property (nonatomic, assign) BOOL enableBeaconScanning;
@property (nonatomic, copy) NSString * resolverURL;
//
@property (nonatomic, assign) BOOL activeTracking;
@property (nonatomic, assign) double monitoredRadius;
@property (nonatomic, assign) double magnetometerUpdateInterval;
@end

#pragma mark - JSONValueTransformer

@interface JSONValueTransformer (SBResolver)
- (NSDate *)NSDateFromNSString:(NSString*)string;
- (NSString*)JSONObjectFromNSDate:(NSDate *)date;
- (SBMTrigger *)SBMTriggerFromNSString:(NSString *)region;
- (NSString *)NSStringFromSBMTrigger:(SBMTrigger *)trigger;
@end
