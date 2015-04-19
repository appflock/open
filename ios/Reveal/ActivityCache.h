//
//  ActivityCache.h
//  Reveal
//
//

#import <Foundation/Foundation.h>

@interface ActivityCache : NSObject

+ (void)reload;
+ (BOOL)didUserLikePost:(PFObject *)post;
+ (BOOL)didUserDislikePost:(PFObject *)post;

+ (void)likePost:(PFObject *)post block:(void(^)())block;
+ (void)dislikePost:(PFObject *)post block:(void(^)())block;

@end
