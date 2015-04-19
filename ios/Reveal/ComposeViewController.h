//
//  ComposeViewController.h
//  Reveal
//
//

#import <UIKit/UIKit.h>

@protocol ComposeViewControllerDelegate;

@interface ComposeViewController : UIViewController
@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;
@end

@protocol ComposeViewControllerDelegate <NSObject>
@required
- (void)composeViewControllerDidCancel:(ComposeViewController *)viewController;
- (void)composeViewController:(ComposeViewController *)viewController
                      didSave:(PFObject *)post
                        error:(NSError *)error;
@end