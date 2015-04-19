//
//  SignupViewController.h
//  Reveal
//
//

#import <UIKit/UIKit.h>
#import "VerificationViewController.h"

@protocol SignupViewControllerDelegate;

@interface SignupViewController : UIViewController<VerificationViewControllerDelegate>
@property (nonatomic, weak) id<SignupViewControllerDelegate> delegate;
@end

@protocol SignupViewControllerDelegate <NSObject>
@required
- (void)signupViewControllerDidCancel:(SignupViewController *)viewController;
- (void)signupViewController:(SignupViewController *)viewController didSubmitEmail:(NSString *)email error:(NSError *)error;
@end
