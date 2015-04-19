//
//  ComposeViewController.m
//  Reveal
//
//

#import "ComposeViewController.h"

#import "GCPlaceholderTextView.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewBottomConstraint;

@end

@implementation ComposeViewController

#pragma mark - View Controller

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentTextView.placeholder = @"Enter your thought...";
    [self observeKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.delegate) {
        [NSException raise:@"Delegate" format:@"Missing delegate"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Keyboard

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

// The callback for frame-changing of keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];

    CGFloat height = keyboardFrame.size.height;

    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.contentTextViewBottomConstraint.constant = 10 + height;

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    self.contentTextViewBottomConstraint.constant = 10;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - AlertViewController helper

- (void)showAlertViewControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops, empty message"
                                                                             message:@"Go back or discard?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go back", @"Go back action")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             NSLog(@"Go back action");
                                                         }];

    UIAlertAction *discardAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Discard", @"Discard action")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
                                                              NSLog(@"Discard action");
                                                              [self cancelButtonAction:action];
                                                          }];

    [alertController addAction:cancelAction];
    [alertController addAction:discardAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Button action

- (IBAction)saveButtonAction:(id)sender {
    NSString *content = [self.contentTextView.text cleanedString];
    if (content.length == 0) {
        [self showAlertViewControllerWithTitle:@"Oops, empty message" message:@"Go back or discard?"];
        return;
    }

    // Disable the button so we will not save the post multiple time
    UIBarButtonItem *saveButton = nil;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        saveButton = (UIBarButtonItem *)sender;
        saveButton.enabled = NO;
    }

    // Save the post, we will mask the user identity at the backend
    PFObject *post = [PFObject objectWithClassName:kPost.className];
    [post setObject:content forKey:kPost.content];
    [post setObject:kPostType.text forKey:kPost.type];

    PFACL *publicReadAcl = [PFACL ACL];
    [publicReadAcl setPublicReadAccess:YES];
    [post setACL:publicReadAcl];

    PFObject *counter = [PFObject objectWithClassName:kPostCounter.className];
    PFACL *publicReadWriteAcl = [PFACL ACL];
    [publicReadWriteAcl setPublicReadAccess:YES];
    [publicReadWriteAcl setPublicWriteAccess:YES];
    [counter setACL:publicReadWriteAcl];

    [post setObject:counter forKey:kPost.counter];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [saveButton setEnabled:YES];

        if (error) {
            [self.delegate composeViewController:self didSave:nil error:error];
            return;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:RevealDidFinishEditingPostNotification
                                                            object:post];

        [self.delegate composeViewController:self didSave:post error:nil];
    }];
}



- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate composeViewControllerDidCancel:self];
}


@end
