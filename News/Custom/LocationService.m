//
//  LocationService.m
//  Miju
//
//  Created by patrick on 12/10/13.
//  Copyright (c) 2013 Miju. All rights reserved.
//

#import "LocationService.h"
#import "HTTPClient.h"
#import "AppDelegate.h"

#define DistanceFitler      30
//#define UploadMinInterval   10
#define UpdateLocationInterval 360

//#define LOCATIONSERVICE_DEBUG

#ifdef LOCATIONSERVICE_DEBUG
#define LOCATIONSERVICE_LOG NSLog
#else
#define LOCATIONSERVICE_LOG(...)
#endif

@interface LocationService() < CLLocationManagerDelegate>
{
    CLLocationManager* _locationManager;
}

@property CLLocation* lastUploadLocation;
@property NSDate*     lastUploadTime;
@end

@implementation LocationService

+ (instancetype)sharedInstance
{
    static LocationService *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isBackground = false;
        self.prevLocation = [[CLLocation alloc]init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.activityType = CLActivityTypeFitness;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [_locationManager performSelector:@selector(requestWhenInUseAuthorization)];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self stopUpdateLocation];
    [self stopMonitoringSignificantLocationChanges];
    _locationManager.delegate = nil;

}
- (BOOL)isLocationServiceEnabled
{
    return ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
}

- (BOOL)isSignificantLocationChangeMonitoringAvailable
{
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

- (void)startUpdateLocation
{
        if ([self isLocationServiceEnabled])
        {
            [_locationManager startMonitoringSignificantLocationChanges];
            [_locationManager startUpdatingLocation];
        }
}

-(void)startMonitoringSignificantLocationChanges
{
    if ([self isSignificantLocationChangeMonitoringAvailable])
    {
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)stopUpdateLocation 
{
    [_locationManager stopUpdatingLocation];
    [_locationManager stopMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringSignificantLocationChanges
{
    [_locationManager stopMonitoringSignificantLocationChanges];
}

- (void)updateLocationManually
{
    if ([self isLocationServiceEnabled])
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    LOCATIONSERVICE_LOG(@"%@ %d", NSStringFromSelector(_cmd), status);
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            break;
        }
        default:
        {

            break;
        }
            
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [[locations lastObject] locationMarsFromEarth];
    LOCATIONSERVICE_LOG(@"LOCATION6 %@ %@", NSStringFromSelector(_cmd), location);
    
    //NSLog(@"位置：%@",location);
//        CLLocation *tempLocation = [[CLLocation alloc]initWithLatitude:23.138843 longitude:113.258797];
    self.lastLocation = location;
//        self.lastLocation = tempLocation;
    
     NSTimeInterval dTime = [location.timestamp
                            timeIntervalSinceDate:self.prevLocation.timestamp];
    CLLocationDistance distance = [self.prevLocation distanceFromLocation:location];
    
    self.prevLocation = location;
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:self.lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0)
        {
            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
            NSString *locString = @"";
            if ([dict hasObjectForKey:@"City"]) {
                locString = [locString stringByAppendingString:dict[@"City"]];
                NSLog(@"locatiion success:%@",locString);
                if(locString.length > 0){
                    self.lastCity = locString;
                }
            }
        }else{
            NSLog(@"ERROR: %@", error);
            NSLog(@"locatiion fail");
        }
    }];
    
    [_locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter]postNotificationName:LocationServiceDidUploadLocationNotification object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    LOCATIONSERVICE_LOG(@"%@ %@", NSStringFromSelector(_cmd), error);
//    CLLocation *fixLocation = [[CLLocation alloc] initWithLatitude:23.111873 longitude:113.277555];
//    self.lastLocation = fixLocation;
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    LOCATIONSERVICE_LOG(@"%@", NSStringFromSelector(_cmd));
}


- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    LOCATIONSERVICE_LOG(@"%@", NSStringFromSelector(_cmd));
}



#pragma mark application life cycle

- (void)applicationWillTerminate:(UIApplication*)application
{
  
}

- (NSString*)filePathForLocations
{
    NSString* documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [documentDir stringByAppendingPathComponent:@"location"];
    return filePath;
}

- (void)saveUploadLocation:(CLLocation*)location
{
#ifdef DEBUG
    NSArray* oldLocations = [self getUploadedLocations];
    NSMutableArray* locations = [NSMutableArray array];
    if (!oldLocations)
    {
        locations = [NSMutableArray arrayWithObject:location];
    }
    else
    {
        locations = [NSMutableArray arrayWithArray:oldLocations];
        [locations addObject:location];
    }
    
    [NSKeyedArchiver archiveRootObject:locations toFile:[self filePathForLocations]];
#endif
}

- (NSArray*)getUploadedLocations
{
#ifdef DEBUG
    NSArray* locations = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForLocations]];
    if (!locations)
    {
        return [NSArray array];
    }
    else
    {
        return locations;
    }
#else
    return [NSArray array];
#endif
}

- (void)clearUploadedLocations
{
    [NSKeyedArchiver archiveRootObject:[NSArray array] toFile:[self filePathForLocations]];
}

-(NSString*)getNowTime
{
    NSDate* inputDate = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init] ;
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];//yyyy年MM月dd日 HH时mm分ss秒
    NSString *str = [outputFormatter stringFromDate:inputDate];
    return str;
}
@end
