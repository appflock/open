//
//  CommentView.h
//  Reveal
//
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

IB_DESIGNABLE
@interface CommentView : BaseView

- (void)updateWithData:(PFObject *)object;

@end
