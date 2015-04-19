//
//  TextCell.m
//  Reveal
//
//

#import "TextCell.h"

@implementation TextCell

- (void)awakeFromNib {
    // Initialization code

    self.textCellView.layer.masksToBounds = NO;
    self.textCellView.layer.cornerRadius = 1;
    self.textCellView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.textCellView.layer.shadowRadius = 1;
    self.textCellView.layer.shadowOpacity = .2;
    
    self.textCellView.maxLines = 7;     
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCell {
    [self.textCellView updateWithData:self.post];
}

@end
