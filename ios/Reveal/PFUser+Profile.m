//
//  PFUser+Profile.m
//  Reveal
//
//

#import "PFUser+Profile.h"

@implementation PFUser (Profile)

/**
 * Method to fetch the private profile for the current user
 */
- (void)fetchProfile:(void(^)(PFObject *, NSError *))block {
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Fetch user error: %@", error);
            // We will still try fetching profile
        }

        PFObject *profile = [[PFUser currentUser] objectForKey:kUser.profile];
        [profile fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error) {
                block(profile, nil);
            } else {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation[@"lastLoginDate"] =  [NSDate date];
                [currentInstallation saveInBackground];
                
                block(object, nil);
            }
        }];
    }];
}

@end
