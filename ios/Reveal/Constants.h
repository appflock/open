//
//  Constants.h
//  Reveal
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef UIColorFromHex
#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 \
                                            green:((float)((hex & 0xFF00) >> 8))/255.0 \
                                             blue:((float)(hex & 0xFF))/255.0 alpha:1.0]
#endif

extern NSString * const kSegueComposePost;

extern NSString * const RevealDidFinishEditingPostNotification;
extern NSString * const RevealDidFinishPostingCommentNotification;

extern NSString * const RevealLoginRequestedNotification;
extern NSString * const RevealDidFinishLoginNotification;
extern NSString * const RevealDidFailLoginNotification;

extern NSString * const RevealDidFinishUpdatingProfileNotification;

extern NSString * const RevealShowAddWorkplaceNotification;

extern NSString * const kUserInfoErrorKey;
extern NSString * const kUserInfoUserKey;

extern NSString * const kNotificationShowSignup;
extern NSString * const kNotificationDismissSignup;

extern NSString * const kSegueCheckVerificationCode;

UIViewController *AlertViewController(NSString *title, NSString *message);

extern NSString * const kNotificationPostCounterUpdated;
extern NSString * const kNotificationLikeStateDidChange;

#ifndef LiteralString
#define LiteralString __unsafe_unretained NSString *
#endif

// Cloud functions

extern const struct kCFCreateNewProfile {
    LiteralString functionName;
    LiteralString argEmailAddress;
} kCFCreateNewProfile;

extern const struct kCFConfirmProfile {
    LiteralString functionName;
    LiteralString argVerificationCode;
} kCFConfirmProfile;


// PFObject

extern const struct kUser {
    LiteralString className;
    LiteralString profile;
    LiteralString likes;
    LiteralString dislikes;
    LiteralString votes;
} kUser;

extern const struct kProfile {
    LiteralString className;
    LiteralString company;
    LiteralString userHash;
    LiteralString emailAddress;
    LiteralString verificationCode;
    LiteralString verified;
} kProfile;

extern const struct kInstallation {
    LiteralString className;
    LiteralString userHash;
} kInstallation;

extern const struct kPost {
    LiteralString className;
    LiteralString type;
    LiteralString createdAt;
    LiteralString content;
    LiteralString userHash;
    LiteralString company;
    LiteralString parent;

    LiteralString counter;

    LiteralString polls;
    
    LiteralString pollChoices;
    LiteralString pollChoiceCountFormatString; // "pollChoice%ldCount",
} kPost;

extern const struct kPostCounter {
    LiteralString className;
    LiteralString likeCount;
    LiteralString dislikeCount;
    LiteralString commentCount;
    LiteralString voteCount;
} kPostCounter;

extern const struct kPostType {
    LiteralString text;
    LiteralString comment;
    LiteralString poll;
} kPostType;

extern const struct kPoll {
    LiteralString className;
    LiteralString content;
    LiteralString counter;
} kPoll;

extern const struct kPollCounter {
    LiteralString className;
    LiteralString voteCount;
} kPollCounter;

extern const struct kCompany {
    LiteralString className;
    LiteralString name;
    LiteralString emailDomain;
} kCompany;

extern const struct kActivity {
    LiteralString className;
    LiteralString type;
    LiteralString user;
    LiteralString target;
    LiteralString value; // For like activity, value can be +1 or -1
} kActivity;

extern const struct kActivityType {
    LiteralString like;
} kActivityType;

#ifndef CHECK_DELEGATE
#define CHECK_DELEGATE \
if (!self.delegate) { \
    [NSException raise:@"delegate" format:@"delegete is not set"]; \
}
#endif

#ifndef CHECK_TOP_VIEW_CONTROLLER
#define CHECK_TOP_VIEW_CONTROLLER(vc) NSAssert(self.navigationController.topViewController == vc, @"View controller is not the top view controller");
#endif

#ifndef CHECK_PRESENTED_VIEW_CONTROLLER
#define CHECK_PRESENTED_VIEW_CONTROLLER(vc) NSAssert(self.presentedViewController == vc, @"View controller is not the presented view controller");
#endif

#ifndef SHARED_INSTANCE_USING_BLOCK
#define SHARED_INSTANCE_USING_BLOCK(block) \
\
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;
#endif

