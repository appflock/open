//
//  TextCellView.m
//  Reveal
//
//

#import "TextCellView.h"
#import "NSDate+NVTimeAgo.h"
#import "ActionBarView.h"
#import "AppDelegate.h"
#import "ActivityCache.h"

@interface TextCellView () <ActionBarViewDelegate>

@property (weak, nonatomic) IBOutlet ActionBarView *actionBarView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) PFObject *object;

@end

@implementation TextCellView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit {
    [super commonInit];
    self.maxLines = 1;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(counterDidChange:)
                                                 name:kNotificationPostCounterUpdated
                                               object:nil];
}

- (void)actionBarView:(ActionBarView *)actionBarView likeActionWithBlock:(void (^)())block {
    [ActivityCache likePost:self.object block:block];
}

- (void)actionBarView:(ActionBarView *)actionBarView dislikeActionWithBlock:(void (^)())block {
    [ActivityCache dislikePost:self.object block:block];
}

- (void)actionBarView:(ActionBarView *)actionBarView commentActionWithBlock:(void (^)())block {
    if (self.delegate) {
        [self.delegate textCellView:self commentOnPost:self.object];
    }
}

- (void)actionBarView:(ActionBarView *)actionBarView shareActionWithBlock:(void (^)())block {
    if (self.delegate) {
        [self.delegate textCellView:self sharePost:self.object];
    }
}

- (void)updateWithData:(PFObject *)object {
    self.object = object;

    self.actionBarView.delegate = self;
    PFObject *counter = [object objectForKey:kPost.counter];
    self.actionBarView.likeCount = [[counter objectForKey:kPostCounter.likeCount] integerValue];
    self.actionBarView.dislikeCount = [[counter objectForKey:kPostCounter.dislikeCount] integerValue];
    self.actionBarView.commentCount = [[counter objectForKey:kPostCounter.commentCount] integerValue];
    
    ActionBarViewState state = ActionBarViewStateDefault;
    if ([ActivityCache didUserLikePost:object]) {
        state = state | ActionBarViewStateLiked;
    }
    if ([ActivityCache didUserDislikePost:object]) {
        state = state | ActionBarViewStateDisliked;
    }
    [self.actionBarView setState:state];

    //self.likeButton.selected = [ActivityCache didUserLikePost:object];
    //self.likeButton.enabled = YES;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0f;
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:object[kPost.content]
                                                                           attributes:@{ NSParagraphStyleAttributeName: style }];

    self.contentLabel.attributedText = attributedString;

    self.companyLabel.text = [NSString stringWithFormat:@"- %@ -", object[kPost.company][kCompany.name]];
    self.timeLabel.text = [object.createdAt formattedAsTimeAgo];
    
}

- (void)setMaxLines:(NSInteger)maxLines {
    _maxLines = maxLines;
    self.contentLabel.numberOfLines = maxLines;
}

- (void)counterDidChange:(NSNotification *)notification {
    NSString *objectId = [notification.userInfo objectForKey:@"objectId"];

    if (objectId) {
        NSLog(@"Activity of %@ updated", objectId);
    }
    
    if (objectId && ![objectId isEqualToString:self.object.objectId]) {
        return;
    }
    
    ActionBarViewState state = self.actionBarView.state;
    if ([ActivityCache didUserLikePost:self.object]) {
        state = state | ActionBarViewStateLiked;
    } else {
        state = ~ActionBarViewStateLiked & state;
    }

    if ([ActivityCache didUserDislikePost:self.object]) {
        state = state | ActionBarViewStateDisliked;
    } else {
        state = ~ActionBarViewStateDisliked & state;
    }

    PFObject *counter = [self.object objectForKey:kPost.counter];

    self.actionBarView.likeCount = [[counter objectForKey:kPostCounter.likeCount] integerValue];
    self.actionBarView.dislikeCount = [[counter objectForKey:kPostCounter.dislikeCount] integerValue];
    self.actionBarView.commentCount = [[counter objectForKey:kPostCounter.commentCount] integerValue];

    self.actionBarView.state = state;
}


@end
