//
//  PAPLocationController.m
//  Narwhal
//
//  Created by Hector Ramos on 4/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAPLocationController.h"

static PAPLocationController *sharedInstance = nil;

@interface PAPLocationController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@end

@implementation PAPLocationController
@synthesize locationManager = _locationManager;
@synthesize lastLocation = _lastLocation;
@synthesize lastLocationName = _lastLocationName;
@synthesize locationUpdateBlock = _locationUpdateBlock;
@synthesize geocoder = _geocoder;

#pragma mark -
#pragma mark Singleton methods

+ (PAPLocationController *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[PAPLocationController alloc] init];
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)init {
    self = [super init];
    if (! self)
        return nil;
    
    _lastLocation = nil;
    _lastLocationName = @"";
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:100];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    self.geocoder = [[CLGeocoder alloc] init];
    return self;
}


#pragma mark -

- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}


- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    DLog(@"New location: %@", newLocation);
    _lastLocation = newLocation;
    
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    if (! oldLocation || distance > 100)
        [self reverseGeocode];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.parse.didUpdateToLocation" object:nil userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:@"location"]];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DLog(@"ERR: %@", error);   
}

#pragma mark -

- (void)reverseGeocode {
    if ([self.geocoder isGeocoding])
        return;
    
    [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.lastLocation.coordinate.latitude longitude:self.lastLocation.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (! error) {
            DLog(@"Places: %@", placemarks);
            for (CLPlacemark *placemark in placemarks) {
                DLog(@"country: %@", [placemark country]);
                DLog(@"administrativeArea: %@", [placemark administrativeArea]);
                DLog(@"subAdministrativeArea: %@", [placemark subAdministrativeArea]);
                DLog(@"region: %@", [placemark region]);
                DLog(@"Locality: %@", [placemark locality]);
                DLog(@"subLocality: %@", [placemark subLocality]);
                DLog(@"Thoroughfare: %@", [placemark thoroughfare]);
                DLog(@"subThoroughfare: %@", [placemark subThoroughfare]);
                DLog(@"Name: %@", [placemark name]);
                DLog(@"Desc: %@", placemark);
                DLog(@"addressDictionary: %@", [placemark addressDictionary]);
                NSArray *areasOfInterest = [placemark areasOfInterest];
                for (id area in areasOfInterest) {
                    DLog(@"Class: %@", [area class]);
                    DLog(@"AREA: %@", area);
                }
                NSString *divider = @"";
                NSString *descriptiveString = @"";
                if (! IsEmpty([placemark subThoroughfare])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@", [placemark subThoroughfare]];
                    divider = @", ";
                }
                if (! IsEmpty([placemark thoroughfare])) {
                    if (! IsEmpty(descriptiveString))
                        divider = @" ";
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark thoroughfare]];
                    divider = @", ";
                }

                if (! IsEmpty([placemark subLocality])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subLocality]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark locality]) && (IsEmpty([placemark subLocality]) || ! [[placemark subLocality] isEqualToString:[placemark locality]])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark locality]];
                    divider = @", ";
                }

                if (! IsEmpty([placemark administrativeArea])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark administrativeArea]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark ISOcountryCode])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark ISOcountryCode]];
                    divider = @", ";
                }

                if (! IsEmpty([placemark name])) {
                    descriptiveString = [NSString stringWithString:[placemark name]];
                }

                DLog(@"Smart place: %@", descriptiveString);
                [self setLastLocationName:[NSString stringWithString:descriptiveString]];
            }
            /*
             Place: (
             "301 Geary St, 301 Geary St, San Francisco, CA  94102-1801, United States @ <+37.78711200,-122.40846000> +/- 100.00m"
             )
             */
        }
    }];

}
@end
