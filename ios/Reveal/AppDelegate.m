//
//  AppDelegate.m
//  Reveal
//
//

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    /**
     * Initialize Parse
     * FIND YOUR APPLICATION ID AND CLIENT KEY FROM PARSE
     */
    NSString *applicationId = @"__YOUR_PARSE_APPLICATION_ID__";
    NSString *clientKey = @"__YOUR_PARSE_CLIENT_KEY__";

    [ParseCrashReporting enable];
    [Parse setApplicationId:applicationId
                  clientKey:clientKey];

    // Turn on automatic/anonymous user
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] saveInBackground];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    [self.window setTintColor:[UIColor appTintColor]];

    if ([PFUser currentUser]) {
        [ActivityCache reload];

        // Attempt to update the user data for each launch
        [[PFUser currentUser] fetchProfile:^(PFObject *profile, NSError *error) {
            NSLog(@"Profile fetched");
        }];

        // register for pushing
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];

        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
   // [[Crashlytics sharedInstance] crash];

    // Store the deviceToken in the current installation and save it to Parse.
    NSLog(@"Push notifications registration successed");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0) {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
