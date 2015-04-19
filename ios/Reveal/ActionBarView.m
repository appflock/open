//
//  ActionBarView.m
//  Reveal
//
//

#import "ActionBarView.h"

static UIColor *kActionBarViewButtonColorDefault;

#ifndef GET_TINT_COLOR
#define GET_TINT_COLOR(condition) \
    (condition) ? self.tintColor : kActionBarViewButtonColorDefault;
#endif // GET_TINT_COLOR

#ifndef SET_ACTION_BAR_VIEW_STATE
#define SET_ACTION_BAR_VIEW_STATE(current, clear) \
current = clear | current;
#endif // SET_ACTION_BAR_VIEW_STATE

#ifndef CLEAR_ACTION_BAR_VIEW_STATE
#define CLEAR_ACTION_BAR_VIEW_STATE(current, clear) \
    current = ~clear & current;
#endif // CLEAR_ACTION_BAR_VIEW_STATE

@interface ActionBarView ()
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@end

@implementation ActionBarView

+ (void)initialize {
    kActionBarViewButtonColorDefault = [UIColor lightGrayColor];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.likeButton.tintColor = kActionBarViewButtonColorDefault;
        self.dislikeButton.tintColor = kActionBarViewButtonColorDefault;
        self.commentButton.tintColor = kActionBarViewButtonColorDefault;
        self.shareButton.tintColor = kActionBarViewButtonColorDefault;
    }
    return self;
}

- (void)setState:(ActionBarViewState)state {
    _state = state;
    self.likeButton.tintColor = GET_TINT_COLOR(state & ActionBarViewStateLiked);
    self.dislikeButton.tintColor = GET_TINT_COLOR(state & ActionBarViewStateDisliked);
    self.commentButton.tintColor = GET_TINT_COLOR(state & ActionBarViewStateCommented);
}

- (NSInteger)likeCount {
    return [self.likeButton.titleLabel.text integerValue];
}

- (void)setLikeCount:(NSInteger)likeCount {
    likeCount = MAX(0, likeCount);
    [self.likeButton setTitle:[NSString stringWithFormat:@"%ld", likeCount]
                     forState:UIControlStateNormal];
}

- (NSInteger)dislikeCount {
    return [self.dislikeButton.titleLabel.text integerValue];
}

- (void)setDislikeCount:(NSInteger)dislikeCount {
    dislikeCount = MAX(0, dislikeCount);
    [self.dislikeButton setTitle:[NSString stringWithFormat:@"%ld", dislikeCount]
                        forState:UIControlStateNormal];
}


- (NSInteger)commentCount {
    return [self.commentButton.titleLabel.text integerValue];
}

- (void)setCommentCount:(NSInteger)commentCount {
    commentCount = MAX(0, commentCount);
    [self.commentButton setTitle:[NSString stringWithFormat:@"%ld", commentCount]
                        forState:UIControlStateNormal];
}

- (IBAction)likeButtonAction:(id)sender {
    if (!self.delegate) {
        return;
    }

    self.likeButton.enabled = YES;
    self.dislikeButton.enabled = YES;
    [self.delegate actionBarView:self likeActionWithBlock:^ {
        self.likeButton.enabled = YES;
        self.dislikeButton.enabled = YES;
    }];
}

- (IBAction)dislikeButtonAction:(id)sender {
    if (!self.delegate) {
        return;
    }

    self.likeButton.enabled = YES;
    self.dislikeButton.enabled = YES;
    [self.delegate actionBarView:self dislikeActionWithBlock:^ {
        self.likeButton.enabled = YES;
        self.dislikeButton.enabled = YES;
    }];
}

- (IBAction)commentButtonAction:(id)sender {
    if (!self.delegate) {
        return;
    }

    [self.delegate actionBarView:self commentActionWithBlock:^{
    }];
}


- (IBAction)shareButtonAction:(id)sender {
    if (!self.delegate) {
        return;
    }
    
    [self.delegate actionBarView:self shareActionWithBlock:^{
    }];
}
@end
