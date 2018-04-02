//
//  LocationService.h
//  Miju
//
//  Created by patrick on 12/10/13.
//  Copyright (c) 2013 Miju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+Sino.h"

#define LocationServiceDidHasLocationNotification               @"LocationServiceDidHasLocationNotification"
#define LocationServiceDidUploadLocationNotification            @"LocationServiceDidUploadLocationNotification"
#define LocationServiceDidUpdateLocationNotification            @"LocationServiceDidUpdateLocationNotification"

@interface LocationService : NSObject
@property (nonatomic , strong) CLLocation *prevLocation;
@property (strong,nonatomic) CLLocation* lastLocation;
@property (strong,nonatomic) NSString* lastCity;
@property (assign,nonatomic) BOOL isBackground;

//@property (nonatomic) BOOL isFirstTimeGetLocation;
//@property (nonatomic,readonly) BOOL isUpdateLocation;

+ (LocationService *)sharedInstance;
- (void)startUpdateLocation;
- (void)startMonitoringSignificantLocationChanges;
- (void)stopUpdateLocation;
- (void)stopMonitoringSignificantLocationChanges;
- (void)updateLocationManually;

- (NSArray*)getUploadedLocations;
- (void)clearUploadedLocations;
@end
