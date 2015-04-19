//
//  VerificationViewController.h
//  Reveal
//
//

#import <UIKit/UIKit.h>

@protocol VerificationViewControllerDelegate;

@interface VerificationViewController : UIViewController
@property (nonatomic, weak) id<VerificationViewControllerDelegate> delegate;
@end

@protocol VerificationViewControllerDelegate <NSObject>
@required
- (void)verificationViewControllerDidCancel:(VerificationViewController *)viewController;
- (void)verificationViewController:(VerificationViewController *)viewController didVerifyProfile:(PFObject *)profile error:(NSError *)error;
@end
