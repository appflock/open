//
//  ComposeBarHelper.m
//  Reveal
//
//

#import "ComposeBarHelper.h"

@interface ComposeBarHelper ()

@property (weak, nonatomic, readonly) UITableViewController *viewController;
@property (weak, nonatomic, readonly) id<PHFComposeBarViewDelegate> delegate;
@end

@implementation ComposeBarHelper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithViewController:(UITableViewController *)viewController
                              delegate:(id<PHFComposeBarViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _delegate = delegate;
    }
    return self;

}

- (void)setupComposeBar {
    [self createComposeBar];
    [self observeKeyboard];
    [self enableTapToDismissKeyboard];
}

- (void)addComposeBar {
    [self.viewController.navigationController setToolbarHidden:NO animated:YES];
    [self.viewController.navigationController.toolbar addSubview:self.composeBarView];
}

- (void)removeComposeBar {
    [self.composeBarView removeFromSuperview];
    [self.composeBarView resignFirstResponder];
}

- (void)enableTapToDismissKeyboard {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.viewController.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.composeBarView resignFirstResponder];
}

- (void)createComposeBar {
    CGRect toolbarFrame = self.viewController.navigationController.toolbar.frame;

    CGRect frame = CGRectMake(0.0f,
                              toolbarFrame.size.height - PHFComposeBarViewInitialHeight,
                              toolbarFrame.size.width,
                              PHFComposeBarViewInitialHeight);
    _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    [_composeBarView setMaxLinesCount:5];
    _composeBarView.placeholderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:14];
    [_composeBarView setPlaceholder:@"Share a thought..."];
    _composeBarView.buttonTitle = @"Post";
    //[_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"keyboard"]];
    [_composeBarView setDelegate:self.delegate];
    [_composeBarView setButtonTintColor:[UIColor appTintColor]];
    [_composeBarView setTintColor:[UIColor appTintColor]];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillToggle:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];

    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;

    /*
    NSLog(@"Before toolbar.frame %@",
          NSStringFromCGRect(self.viewController.navigationController.toolbar.frame));
    NSLog(@"Before contentOffset %@, contentSize %@",
          NSStringFromCGPoint(self.viewController.tableView.contentOffset), NSStringFromCGSize(self.viewController.tableView.contentSize));
    NSLog(@"Before tableView.frame %@",
          NSStringFromCGRect(self.viewController.tableView.frame));
     */

    // Sit just on top of the keyboard
    CGRect newToolbarFrame = self.viewController.navigationController.toolbar.frame;
    newToolbarFrame.origin.y = endFrame.origin.y - newToolbarFrame.size.height;

    // Toolbar is overlap with table view at the bottom of screen (bottom-aligned), we can
    // calculte the height by finding the bottom and minus the origin.y
    CGFloat bottomEdge = newToolbarFrame.origin.y + newToolbarFrame.size.height;
    CGRect newTableViewFrame = self.viewController.tableView.frame;
    newTableViewFrame.size.height = bottomEdge - newTableViewFrame.origin.y;

    // Adjust the content offset by table size change
    CGFloat tableHeightChange = newTableViewFrame.size.height - self.viewController.tableView.frame.size.height;
    CGPoint newContentOffset = self.viewController.tableView.contentOffset;
    newContentOffset.y -= tableHeightChange;

    CGFloat maxScrollableY = MAX(0, self.viewController.tableView.contentSize.height -
                                 (newTableViewFrame.size.height - self.viewController.navigationController.toolbar.frame.size.height));
    NSLog(@"MaxScrollableY %f", maxScrollableY);
    if (newContentOffset.y > maxScrollableY) {
        newContentOffset.y = maxScrollableY;
    }
    if (newContentOffset.y < 0) {
        newContentOffset.y = 0;
    }

    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.viewController.navigationController.toolbar setFrame:newToolbarFrame];
                         [self.viewController.tableView setFrame:newTableViewFrame];
                         [self.viewController.tableView setContentOffset:newContentOffset];

                         /*
                         NSLog(@"After toolbar.frame %@",
                               NSStringFromCGRect(self.viewController.navigationController.toolbar.frame));
                         NSLog(@"After contentOffset %@, contentSize %@",
                               NSStringFromCGPoint(self.viewController.tableView.contentOffset), NSStringFromCGSize(self.viewController.tableView.contentSize));
                         NSLog(@"After tableView.frame %@",
                               NSStringFromCGRect(self.viewController.tableView.frame));
                          */
                     }
                     completion:NULL];
}


@end
