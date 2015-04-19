//
//  TextDetailCell.h
//  Reveal
//
//

#import <UIKit/UIKit.h>
#import "TextCellView.h"

@interface TextDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet TextCellView *textCellView;
- (void)updateWithData:(PFObject *)object;
@end
