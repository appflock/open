 //
//  ActivityCache.m
//  Reveal
//
//

#import "ActivityCache.h"

@interface ActivityCache ()
@property (strong, nonatomic) NSMutableSet *likedPosts;
@property (strong, nonatomic) NSMutableSet *dislikedPosts;
@end

@implementation ActivityCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _likedPosts = [NSMutableSet set];
        _dislikedPosts = [NSMutableSet set];
        [self reload];
    }
    return self;
}

- (void)reload {
    if ([PFUser currentUser]) {
        PFRelation *likes = [[PFUser currentUser] relationForKey:kUser.likes];
        PFQuery *likesQuery = [likes query];

        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                for (PFObject *post in objects) {
                    NSLog(@"Liked post %@", post.objectId);
                    [_likedPosts addObject:post.objectId];
                }
            }

            if (error) {
                NSLog(@"Error when fetching likes - %@", error);
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostCounterUpdated
                                                                object:self];
        }];

        PFRelation *dislikes = [[PFUser currentUser] relationForKey:kUser.dislikes];
        PFQuery *dislikesQuery = [dislikes query];
        [dislikesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                for (PFObject *post in objects) {
                    NSLog(@"Disliked post %@", post.objectId);
                    [_dislikedPosts addObject:post.objectId];
                }
            }

            if (error) {
                NSLog(@"Error when fetching dislikes - %@", error);
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostCounterUpdated
                                                                object:self];
        }];
    }
}

- (BOOL)didUserLikePost:(PFObject *)post {
    return [self.likedPosts containsObject:post.objectId];
}

- (BOOL)didUserDislikePost:(PFObject *)post {
    return [self.dislikedPosts containsObject:post.objectId];
}

- (void)likePost:(PFObject *)post block:(void(^)())block {
    PFObject *counter = [post objectForKey:kPost.counter];
    if ([self.likedPosts containsObject:post.objectId]) {
        [self.likedPosts removeObject:post.objectId];

        [[[PFUser currentUser] relationForKey:kUser.likes] removeObject:post];
        if ([[counter objectForKey:kPostCounter.likeCount] integerValue] > 0) {
            [counter incrementKey:kPostCounter.likeCount byAmount:@(-1)];
        }
    } else {
        [self.likedPosts addObject:post.objectId];
        [[[PFUser currentUser] relationForKey:kUser.likes] addObject:post];
        [counter incrementKey:kPostCounter.likeCount byAmount:@(1)];
    }


    if ([self.dislikedPosts containsObject:post.objectId]) {
        [self.dislikedPosts removeObject:post.objectId];
        [counter incrementKey:kPostCounter.dislikeCount byAmount:@(-1)];
        [[[PFUser currentUser] relationForKey:kUser.dislikes] removeObject:post];
    }

    [counter saveInBackground];
    [[PFUser currentUser] saveInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostCounterUpdated
                                                        object:self
                                                      userInfo:@{ @"objectId": post.objectId }];
    if (block) {
        block();
    }
}


- (void)dislikePost:(PFObject *)post block:(void(^)())block {
    PFObject *counter = [post objectForKey:kPost.counter];
    if ([self.dislikedPosts containsObject:post.objectId]) {
        [self.dislikedPosts removeObject:post.objectId];

        [[[PFUser currentUser] relationForKey:kUser.dislikes] removeObject:post];
        if ([[counter objectForKey:kPostCounter.dislikeCount] integerValue] > 0) {
            [counter incrementKey:kPostCounter.dislikeCount byAmount:@(-1)];
        }
    } else {
        [self.dislikedPosts addObject:post.objectId];
        [[[PFUser currentUser] relationForKey:kUser.dislikes] addObject:post];
        [counter incrementKey:kPostCounter.dislikeCount byAmount:@(1)];
    }


    if ([self.likedPosts containsObject:post.objectId]) {
        [self.likedPosts removeObject:post.objectId];
        [counter incrementKey:kPostCounter.likeCount byAmount:@(-1)];
        [[[PFUser currentUser] relationForKey:kUser.likes] removeObject:post];
    }

    [counter saveInBackground];
    [[PFUser currentUser] saveInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostCounterUpdated
                                                        object:self
                                                      userInfo:@{ @"objectId": post.objectId }];

    if (block) {
        block();
    }
}

+ (instancetype)instance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[ActivityCache alloc] init];
    });
}

+ (void)reload {
    [[ActivityCache instance] reload];
}

+ (BOOL)didUserLikePost:(PFObject *)post {
    return [[ActivityCache instance] didUserLikePost:post];
}

+ (BOOL)didUserDislikePost:(PFObject *)post {
    return [[ActivityCache instance] didUserDislikePost:post];
}

+ (void)likePost:(PFObject *)post block:(void(^)())block {
    [[ActivityCache instance] likePost:post block:block];
}

+ (void)dislikePost:(PFObject *)post block:(void(^)())block {
    [[ActivityCache instance] dislikePost:post block:block];
}


@end
