//
//  CommentView.m
//  Reveal
//
//

#import "CommentView.h"
#import "NSDate+NVTimeAgo.h"

@interface CommentView ()
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@end

@implementation CommentView

- (void)updateWithData:(PFObject *)object {
    NSString *userHash = [object objectForKey:kPost.userHash];
    PFObject *parent = [object objectForKey:kPost.parent];
    char r = (0xFF & [userHash characterAtIndex:2]) | (0xFF & [parent.objectId characterAtIndex:0]);
    char g = (0xFF & [userHash characterAtIndex:1]) | (0xFF & [parent.objectId characterAtIndex:1]);
    char b = (0xFF & [userHash characterAtIndex:0]) | (0xFF & [parent.objectId characterAtIndex:2]);
    NSUInteger hex = (r << 16) | (g << 8) | (b);

    self.userView.backgroundColor = UIColorFromHex(hex);

    self.companyLabel.text = [NSString stringWithFormat:@"%@%@%@", object[kPost.company][kCompany.name], @"\u00B7", [object.createdAt formattedAsTimeAgo]];
    self.commentLabel.text = [object objectForKey:kPost.content];

    
}

- (void)drawRect:(CGRect)rect {
    self.userView.layer.cornerRadius = self.userView.frame.size.width / 2;
    self.userView.clipsToBounds = YES;
}

@end
