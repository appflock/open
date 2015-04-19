//
//  CommentCell.h
//  Reveal
//
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) PFObject *comment;

- (void)updateCell;

@end
