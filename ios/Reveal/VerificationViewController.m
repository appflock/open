//
//  VerificationViewController.m
//  Reveal
//
//

#import "VerificationViewController.h"

@interface VerificationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    CHECK_DELEGATE;
    self.navigationItem.hidesBackButton = YES;
    [super viewWillAppear:animated];
    self.verificationCodeTextField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)verifyNowAction:(id)sender {
    NSString *verificationCode = [self.verificationCodeTextField.text cleanedString];

    if (verificationCode.length == 0) {
        [self presentViewController:AlertViewController(@"Oops", @"You haven't input anything")
                           animated:YES
                         completion:nil];
        return;
    }

    [PFCloud callFunctionInBackground:kCFConfirmProfile.functionName
                       withParameters:@{ kCFConfirmProfile.argVerificationCode: verificationCode }
                                block:^(id object, NSError *error) {
                                    [self.delegate verificationViewController:self didVerifyProfile:object error:error];
                                }];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate verificationViewControllerDidCancel:self];
}



@end
