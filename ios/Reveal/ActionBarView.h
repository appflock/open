//
//  ActionBarView.h
//  Reveal
//
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@protocol ActionBarViewDelegate;

typedef NS_OPTIONS(NSUInteger, ActionBarViewState) {
    ActionBarViewStateDefault      = 0,
    ActionBarViewStateLiked        = 1 << 0,
    ActionBarViewStateDisliked     = 1 << 1,
    ActionBarViewStateCommented    = 1 << 2,
};

IB_DESIGNABLE
@interface ActionBarView : BaseView

@property (assign, nonatomic) ActionBarViewState state;
@property (assign, nonatomic) NSInteger likeCount;
@property (assign, nonatomic) NSInteger dislikeCount;
@property (assign, nonatomic) NSInteger commentCount;
@property (weak, nonatomic) id<ActionBarViewDelegate> delegate;

@end

@protocol ActionBarViewDelegate <NSObject>
@required
- (void)actionBarView:(ActionBarView *)actionBarView likeActionWithBlock:(void(^)())block;

- (void)actionBarView:(ActionBarView *)actionBarView dislikeActionWithBlock:(void(^)())block;

- (void)actionBarView:(ActionBarView *)actionBarView commentActionWithBlock:(void (^)())block;

- (void)actionBarView:(ActionBarView *)actionBarView shareActionWithBlock:(void (^)())block;
@end