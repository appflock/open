//
//  TextCell.h
//  Reveal
//
//

#import <UIKit/UIKit.h>
#import "TextCellView.h"

@interface TextCell : UITableViewCell

@property (strong, nonatomic) PFObject *post;
@property (weak, nonatomic) IBOutlet TextCellView *textCellView;

- (void)updateCell;

@end
