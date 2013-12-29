//
//  LhAppDelegate.m
//  location-history
//
//  Created by Eugene Yaroslavtsev on 12/28/13.
//  Copyright (c) 2013 Derp Creations. All rights reserved.
//

#import "LhAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface LhAppDelegate ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation LhAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   if (_locationManager == nil) {
      _locationManager = [[CLLocationManager alloc] init];
   }
   
   _locationManager.delegate = self;
   
   _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
   _locationManager.activityType = CLActivityTypeFitness;
   
   [_locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
   
   // movement threshold for getting new data
   _locationManager.distanceFilter = 50; // meters
   
   [_locationManager startUpdatingLocation];
   
    // Override point for customization after application launch.
    return YES;
}

- (void)locationManager:(CLLocationManager *) manager didUpdateLocations:(NSArray *)locations {
   CLLocation* location = [locations lastObject];
   NSDate* eventDate = location.timestamp;
   
   NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

   // only process recent events
   if (abs(howRecent) > 15.0) return;
   
   // sent this up to the server
   [self sendDataToServer:location];
}

- (void)sendDataToServer:(CLLocation *)location {

   NSMutableDictionary *data = [NSMutableDictionary dictionary];
   
   data[@"latitude"] = [[NSNumber alloc] initWithDouble:location.coordinate.latitude];
   data[@"longitude"] = [[NSNumber alloc] initWithDouble:location.coordinate.longitude];
   
   NSError *error = nil;
   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
   NSParameterAssert(jsonData);
   NSURL *url = [NSURL URLWithString:@"http://localhost:8000/locations"];
   NSParameterAssert(url);
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
   [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
   [request setValue:[NSString stringWithFormat: @"%d", [jsonData length]] forHTTPHeaderField: @"Content-Length"];
   [request setHTTPBody:jsonData];
   [request setHTTPMethod:@"POST"];
   
   [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
      // process error or other
      printf("response code: %d\n", ((NSHTTPURLResponse*)response).statusCode);
   }];

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
