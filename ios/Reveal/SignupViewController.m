//
//  SignupViewController.m
//  Reveal
//
//

#import "SignupViewController.h"
#import "NSString+Email.h"

@interface SignupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.emailAddressTextField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    CHECK_DELEGATE;
    [super viewWillAppear:animated];
    // Clear the text box
    self.emailAddressTextField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)joinNowAction:(id)sender {
    NSString *emailAddress = [self.emailAddressTextField.text cleanedString];
    if (emailAddress.length == 0) {
        [self presentViewController:AlertViewController(@"Oops", @"You haven't input anything")
                           animated:YES
                         completion:nil];
        return;
    }

    if (![emailAddress isValidEmail]) {
        [self presentViewController:AlertViewController(@"Oops", @"Your email is in invalid format")
                           animated:YES
                         completion:nil];
        return;
    }

    // Create new profile for given email
    [PFCloud callFunctionInBackground:kCFCreateNewProfile.functionName
                       withParameters:@{ kCFCreateNewProfile.argEmailAddress: emailAddress }
                                block:^(id object, NSError *error) {
                                    [self.delegate signupViewController:self didSubmitEmail:emailAddress error:error];
                                }];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate signupViewControllerDidCancel:self];
}


#pragma mark - VerificationViewControllerDelegate

- (void)verificationViewController:(VerificationViewController *)viewController didVerifyProfile:(PFObject *)profile error:(NSError *)error {
    NSAssert(self.presentedViewController == viewController, @"VerificationViewController is not the presented view controller");
    if (error) {
        [self presentViewController:AlertViewController(@"Oops", error.userInfo[@"error"])
                           animated:YES
                         completion:nil];
    } else {
        [viewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)verificationViewControllerDidCancel:(VerificationViewController *)viewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
