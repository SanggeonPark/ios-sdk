//
//  SBEnums.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SBTriggerType){
    // Unknown trigger
    kSBTriggerNone=0,
    /**
     *  Trigger the campaign when we enter the beacon region
     */
    kSBTriggerEnter=1,
    /**
     *  Trigger the campaign when we exit the beacon region
     */
    kSBTriggerExit=2,
    /**
     *  Trigger the campaign when we enter and/or exit the beacon region
     */
    kSBTriggerEnterExit=3,
};

typedef NS_ENUM(NSInteger, SBActionType) {
    /**
     *  The campaign will show the user a notification
     */
    kSBActionTypeText=1,
    /**
     *  The campaign will show the user a website
     */
    kSBActionTypeURL=2,
    /**
     *  The campaign will trigger an in-app action
     */
    kSBActionTypeInApp=3,
    /**
     *  The campaign will not be forwarded to the app, but only reported
     */
    kSBActionTypeSilent = 4,
};

/**
 SBConversionType
 Represents the conversion type for a specific campaign action
 @since 2.1.2
 */
typedef NS_ENUM(NSInteger, SBConversionType) {
    /**
     *  The campaign action can't "fire" (ex. the user has denied access to local notifications)
     */
    kSBConversionUnavailable = -2,
    /**
     *  The campaign was suppressed by the app
     */
    kSBConversionSuppressed = -1,
    /**
     *  The campaign action has been "fired" but was ignored by the user
     *
     * @discussion: The campaigns are marked as "ignored" by default. To correctly measure conversion, be sure to call [SBManager sharedManager] reportConversion: forCampaignAction:] when performing the campaign action
     */
    kSBConversionIgnored = 0,
    /**
     *  The campaign action has been performed successfully
     */
    kSBConversionSuccessful = 1
};

/**
 SBManagerAvailabilityStatus
 Represents the app’s overall iBeacon readiness, like Bluetooth being turned on,
 Background App Refresh enabled and authorization to use location services.
 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBManagerAvailabilityStatus) {
    /**
     Background App Refresh is enabled, the app is authorized to use location services and
     Bluetooth is turned on.
     */
    SBManagerAvailabilityStatusFullyFunctional,
    
    /**
     Bluetooth is turned off. The specific status can be found in bluetoothStatus.
     */
    SBManagerAvailabilityStatusBluetoothRestricted,
    
    /**
     This application is not enabled to use Background App Refresh. The specific status can be
     found in backgroundAppRefreshStatus.
     */
    SBManagerAvailabilityStatusBackgroundAppRefreshRestricted,
    
    /**
     This application is not authorized to use location services. The specific status can be
     found in authorizationStatus.
     */
    SBManagerAvailabilityStatusAuthorizationRestricted,
    
    /**
     This application is not connected to the Sensorberg Beacon Management Platform. The
     specific status can be found in connectionState.
     */
    SBManagerAvailabilityStatusConnectionRestricted,
    
    /**
     This application cannot reach the Sensorberg Beacon Management Platform. The specific
     status can be found in reachabilityState.
     */
    SBManagerAvailabilityStatusReachabilityRestricted,
    
    /**
     This application runs on a device that does not support iBeacon.
     @since 0.7.9
     */
    SBManagerAvailabilityStatusIBeaconUnavailable
};

/**
 SBManagerBackgroundAppRefreshStatus
 
 Represents the app’s Background App Refresh status.
 
 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBManagerBackgroundAppRefreshStatus) {
    /**
     Background App Refresh is enabled, the app is authorized to use location services and
     Bluetooth is turned on.
     */
    SBManagerBackgroundAppRefreshStatusAvailable,
    
    /**
     This application is not enabled to use Background App Refresh. Due
     to active restrictions on Background App Refresh, the user cannot change
     this status, and may not have personally denied availability.
     
     Do not warn the user if the value of this property is set to
     SBManagerBackgroundAppRefreshStatusRestricted; a restricted user does not have
     the ability to enable multitasking for the app.
     */
    SBManagerBackgroundAppRefreshStatusRestricted,
    
    /**
     User has explicitly disabled Background App Refresh for this application, or
     Background App Refresh is disabled in Settings.
     */
    SBManagerBackgroundAppRefreshStatusDenied,
    
    /**
     This application runs on a device that does not support Background App Refresh.
     */
    SBManagerBackgroundAppRefreshStatusUnavailable
};

/**
 SBManagerAuthorizationStatus
 
 Represents the app’s authorization status for using location services.
 
 @since 0.7.0
 */

typedef NS_ENUM(NSInteger, SBLocationAuthorizationStatus) {
    /**
     User has not yet made a choice with regards to this application
     */
    SBLocationAuthorizationStatusNotDetermined,
    
    /**
     Authorization procedure has not been fully implemeneted in app.
     NSLocationAlwaysUsageDescription is missing from Info.plist.
     */
    SBLocationAuthorizationStatusUnimplemented,
    
    /**
     This application is not authorized to use location services. Due
     to active restrictions on location services, the user cannot change
     this status, and may not have personally denied authorization.
     
     Do not warn the user if the value of this property is set to
     SBManagerAuthorizationStatusRestricted; a restricted user does not have
     the ability to enable multitasking for the app.
     */
    SBLocationAuthorizationStatusRestricted,
    
    /**
     User has explicitly denied authorization for this application, or
     location services are disabled in Settings.
     */
    SBLocationAuthorizationStatusDenied,
    
    /**
     User has granted authorization to use their location at any time,
     including monitoring for regions, visits, or significant location changes.
     */
    SBLocationAuthorizationStatusAuthorized,
    
    /**
     This application runs on a device that does not support iBeacon.
     */
    SBLocationAuthorizationStatusUnavailable
};

typedef NS_ENUM(NSInteger, SBBluetoothStatus) {
    /**
        The Bluetooth radio is resetting (or unknown), try again later
     */
    SBBluetoothUnknown,
    /**
     The Bluetooth radio is off, unsupported or restricted
     */
    SBBluetoothOff,
    /**
     The Bluetooth radio is on, supported and accessible
     */
    SBBluetoothOn,
};

typedef enum : NSUInteger {
    SBMagneticProximityUnknown = 0,
    SBMagneticProximityImmediate = 1,
    SBMagneticProximityNear = 2,
    SBMagneticProximityFar = 3,
} SBMagneticProximity;

typedef enum : NSUInteger {
    kSBMagnitudeFar = 1500,
    kSBMagnitudeNear = 2500,
    kSBMagnitudeImmediate = 3500,
} kSBMagnitudeLevels;

static NSString * const kSBMagnitudeFarKey = @"kSBMagnitudeFar";
static NSString * const kSBMagnitudeNearKey = @"kSBMagnitudeNear";
static NSString * const kSBMagnitudeImmediateKey = @"kSBMagnitudeImmediate";

typedef enum : NSUInteger {
    iBKSSettings = 0xFFF0,
    
    
} SBPeripheralService;

typedef enum : NSUInteger {
    // Full list avaialable @ https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicsHome.aspx
    iBLESystem = 0x2A23,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.system_id.xml
    iBLEModel = 0x2A24,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.model_number_string.xml
    iBLESerialNumber = 0x2A25,
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.serial_number_string.xml
    iBLEFirmwareRev = 0x2A26,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.firmware_revision_string.xml
    iBLEHardwareRev = 0x2A27,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.hardware_revision_string.xml
    iBLESoftwareRev = 0x2A28,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    iBLEManufacturer = 0x2A29,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.manufacturer_name_string.xml
    
    iBLEIEE = 0x2A2A,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.ieee_11073-20601_regulatory_certification_data_list.xml
    iBLEPNP = 0x2A50,
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.pnp_id.xml
    
    // iBKS specific characteristic id's (see http://accent-systems.com/ibks-technical-docs/ )
    iBKSUUID  = 0xFFF1,
    iBKSMajor = 0xFFF2,
    iBKSMinor = 0xFFF3,
    iBKSCPwr  = 0xFFF4,
    iBKSAdv   = 0xFFF5,
    iBKSTxPwr = 0xFFF6,
    iBKSPwd   = 0xFFF7,
    iBKSCfg   = 0xFFF8,
    iBKSStatus= 0xFFF9,
    //
    iBKSAdvMode= 0xFFFA
    //
} SBPeripheralCharacteristic;

typedef enum : NSUInteger {
    iBKSUSB,
    iBKS105v1,
    iBKS105v2,
    FWUnknown
} SBFirmwareVersion;

@interface SBEnums : NSObject

@end
