//
//  CommentCell.m
//  Reveal
//
//

#import "CommentCell.h"
#import "CommentView.h"

@interface CommentCell ()

@property (weak, nonatomic) IBOutlet CommentView *commentView;

@end

@implementation CommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCell {
    [self.commentView updateWithData:self.comment];
}

@end
