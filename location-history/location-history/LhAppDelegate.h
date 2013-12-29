//
//  LhAppDelegate.h
//  location-history
//
//  Created by Eugene Yaroslavtsev on 12/28/13.
//  Copyright (c) 2013 Derp Creations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LhAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager* locationManager;

@end
