//
//  SBInternalEvents.h
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

#import "SBInternalModels.h"

#import "SBEvent.h"

@interface SBInternalEvents : SBEvent
@end

#pragma mark - Application lifecycle events

@interface SBEventApplicationLaunched : SBEvent
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@interface SBEventApplicationActive : SBEvent
@end

@interface SBEventApplicationForeground : SBEvent
@end

@interface SBEventApplicationWillResignActive : SBEvent
@end

@interface SBEventApplicationWillTerminate : SBEvent
@end

@interface SBEventApplicationWillEnterForeground : SBEvent
@end

#pragma mark - Resolver events

@interface SBEventReachabilityEvent : SBEvent
@property (nonatomic) BOOL reachable;
@end

@interface SBEventGetLayout : SBEvent
@property (strong, nonatomic) SBMGetLayout  *layout;
@property (strong, nonatomic) SBMBeacon     *beacon;
@property (nonatomic) SBTriggerType         trigger;
@end

@interface SBEventPostLayout : SBEvent
@end

@interface SBEventPing : SBEvent
@property (nonatomic) double latency;
@end