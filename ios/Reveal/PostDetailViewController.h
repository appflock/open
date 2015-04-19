//
//  PostDetailViewController.h
//  Reveal
//
//

#import <UIKit/UIKit.h>

@interface PostDetailViewController : PFQueryTableViewController

@property (strong, nonatomic) PFObject *selectedPost;
@property (assign, nonatomic) BOOL focusOnComposeBarView;

@end
