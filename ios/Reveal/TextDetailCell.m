//
//  TextDetailCell.m
//  Reveal
//
//

#import "TextDetailCell.h"

@implementation TextDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithData:(PFObject *)object {
    [self.textCellView updateWithData:object];
}
@end
