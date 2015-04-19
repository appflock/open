//
//  PFUser+Profile.h
//  Reveal
//
//

#import <Foundation/Foundation.h>

@interface PFUser (Profile)

- (void)fetchProfile:(void(^)(PFObject *, NSError *))block;

@end
