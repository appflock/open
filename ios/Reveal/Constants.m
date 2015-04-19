//
//  Constants.m
//  Reveal
//
//

#import "Constants.h"

// Segue identifiers
NSString * const kSegueComposePost = @"composePostSegue";

// Notifications
NSString * const RevealDidFinishEditingPostNotification = @"com.reveal.Reveal.didFinishEditingPostNotification";
NSString * const RevealDidFinishPostingCommentNotification = @"com.reveal.Reveal.didFinishPostingCommentNotification";

NSString * const RevealLoginRequestedNotification = @"com.reveal.Reveal.loginRequestedNotification";
NSString * const RevealDidFinishLoginNotification = @"com.reveal.Reveal.didFinishLoginNotification";
NSString * const RevealDidFailLoginNotification = @"com.reveal.Reveal.didFailLoginNoficiation";

NSString * const RevealDidFinishUpdatingProfileNotification = @"com.reveal.Reveal.didFinishUpdatingProfileNotification";

NSString * const RevealShowAddWorkplaceNotification = @"com.reveal.Reveal.showAddWorkplaceNotification";

NSString * const kUserInfoErrorKey = @"error";
NSString * const kUserInfoUserKey = @"user";

NSString * const kNotificationShowSignup = @"com.reveal.Reveal.showSignup";
NSString * const kNotificationDismissSignup = @"com.reveal.Reveal.dismissSignup";

NSString * const kNotificationPostCounterUpdated = @"com.reveal.Reveal.postCounterUpdated";
NSString * const kNotificationLikeStateDidChange = @"com.reveal.Reveal.likeStateDidChange";

const struct kCFCreateNewProfile kCFCreateNewProfile = {
    .functionName = @"createNewProfile",
    .argEmailAddress = @"emailAddress",
};

const struct kCFConfirmProfile kCFConfirmProfile = {
    .functionName = @"confirmProfile",
    .argVerificationCode = @"verificationCode",
};

const struct kUser kUser = {
    .className = @"_User",
    .profile = @"profile",
    .likes = @"likes",
    .dislikes = @"dislikes",
    .votes = @"votes",
};

const struct kProfile kProfile = {
    .className = @"Profile",
    .company = @"company",
    .userHash = @"userHash",
    .emailAddress = @"emailAddress",
    .verificationCode = @"verificationCode",
    .verified = @"verified",
};

const struct kInstallation kInstallation = {
    .className = @"Installation",
    .userHash = @"userHash"
};

const struct kPost kPost = {
    .className = @"Post",
    .type = @"type",
    .createdAt = @"createdAt",
    .content = @"content",
    .userHash = @"userHash",
    .company = @"company",
    .parent = @"parent",
    .counter = @"counter",
    .polls = @"polls",

    .pollChoices = @"pollChoices",
    .pollChoiceCountFormatString = @"pollChoice%ldCount",
};

const struct kPostCounter kPostCounter = {
    .className = @"PostCounter",
    .likeCount = @"likeCount",
    .dislikeCount = @"dislikeCount",
    .commentCount = @"commentCount",
    .voteCount = @"voteCount",
};

const struct kPostType kPostType = {
    .text = @"text",
    .comment = @"comment",
    .poll = @"poll",
};

const struct kPoll kPoll = {
    .className = @"Poll",
    .content = @"content",
    .counter = @"counter",
};

const struct kPollCounter kPollCounter = {
    .className = @"PollCounter",
    .voteCount = @"voteCount",
};

const struct kCompany kCompany = {
    .className = @"Company",
    .name = @"name",
    .emailDomain = @"emailDomain",
};

const struct kActivity kActivity = {
    .className = @"Activity",
    .type = @"type",
    .user = @"user",
    .target = @"target",
    .value = @"value",
};

const struct kActivityType kActivityType = {
    .like = @"like",
};

UIViewController *AlertViewController(NSString *title, NSString *message) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];

    [alertController addAction:okAction];
    return alertController;
}

