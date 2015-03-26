//
//  RootViewController.m
//  ZaHunter
//
//  Created by Sherrie Jones on 3/25/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property NSMutableArray *pizzerias;
@property MKDirectionsRequest *request;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pizzerias = [NSMutableArray new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization]; // asks permission
    [self.locationManager startUpdatingLocation]; // begins downloading locations

}

// 1> pass in array of locations -- updates based on info from startUpdatingLocation
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 1000 && location.verticalAccuracy < 1000) {
            [self.pizzerias addObject:location];
            self.myTextView.text = @"Location Found";
            [self.locationManager stopUpdatingLocation];
            //break;
        }
    }
}

// 2> finds pizza place near home
- (void)findPizzeriaNear:(CLLocation *)location {

    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"correctional";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];

    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        MKMapItem *mapItem = response.mapItems.firstObject;
        self.myTextView.text = [NSString stringWithFormat:@"You should go to %@", mapItem.name];
        [self getDirectionsTo:mapItem];
    }];
}

// 3> in case getting the user location fails
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - location manager delegates

// 4> need source and destination
- (void)getDirectionsTo:(MKMapItem *)destinationMapItem {
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationMapItem;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject; // directions have steps

        NSMutableString *directionString = [NSMutableString new];
        int counter = 1;

        for (MKRouteStep *step in route.steps) {
            // for every step in route add to
            [directionString appendFormat:@"%d %@\n", counter, step.instructions];
            counter++;
            self.myTextView.text = directionString;
            NSLog(@"%@", step.instructions);
        }
    }];
}











@end
