//
//  SBAnalytics.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
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
#import <Tolo/tolo.h>

#import "SBAnalytics.h"

#import "SBMSession.h"

#import "SBEvent.h"

#import "SBLocationEvents.h"

#import "SBResolverModels.h"

@interface SBAnalytics () {
    //
    NSArray <SBMMonitorEvent> *events;
    //
    NSArray <SBMReportAction> *actions;
}

@end

@implementation SBAnalytics

@synthesize events;
@synthesize actions;

- (instancetype)init
{
    self = [super init];
    if (self) {
        events = [NSArray <SBMMonitorEvent> new];
        //
        actions = [NSArray <SBMReportAction> new];
        //
    }
    return self;
}

- (NSArray<SBMMonitorEvent> *)events {
    return [events copy];
}

- (NSArray<SBMReportAction> *)actions {
    return [actions copy];
}

#pragma mark - Location events

SUBSCRIBE(SBERegionEnter) {
    if (!events) {
        events = [NSArray <SBMMonitorEvent> new];
    }
    //
    SBMMonitorEvent *enter = [SBMMonitorEvent new];
    enter.pid = event.fullUUID;
    enter.dt = [NSDate date];
    enter.trigger = 1;
    //
    events = [NSArray <SBMMonitorEvent> arrayWithArray:[events arrayByAddingObject:enter]];
}

SUBSCRIBE(SBERegionExit) {
    if (!events) {
        events = [NSArray <SBMMonitorEvent> new];
    }
    //
    SBMMonitorEvent *exit = [SBMMonitorEvent new];
    exit.pid = event.fullUUID;
    exit.dt = [NSDate date];
    exit.trigger = 2;
    //
    events = [NSArray <SBMMonitorEvent> arrayWithArray:[events arrayByAddingObject:exit]];
    //
}

SUBSCRIBE(SBEventPerformAction) {
    SBMReportAction *report = [SBMReportAction new];
    report.eid = event.action.eid;
    report.dt = [NSDate date];
    report.trigger = event.action.trigger;
    report.pid = [[event.action.beacons firstObject] fullUUID];
    report.location = @"";
    //
    actions = [NSArray <SBMReportAction> arrayWithArray:[actions arrayByAddingObject:report]];
    //
}

@end
