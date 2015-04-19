//
//  TextCellView.h
//  Reveal
//
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@protocol TextCellViewDelegate;

IB_DESIGNABLE
@interface TextCellView : BaseView

@property (strong, nonatomic) IBOutlet UIView *view;
@property (assign, nonatomic) IBInspectable NSInteger maxLines;

@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (weak, nonatomic) id<TextCellViewDelegate> delegate;

- (void)updateWithData:(PFObject *)object;

@end

@protocol TextCellViewDelegate <NSObject>
- (void)textCellView:(TextCellView *)textCellView commentOnPost:(PFObject *)object;
- (void)textCellView:(TextCellView *)textCellView sharePost:(PFObject *)object;
@end