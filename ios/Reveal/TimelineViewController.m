//
//  TimelineViewController.m
//  Reveal
//
//

#import "TimelineViewController.h"
#import "AppDelegate.h"
#import "TextCell.h"
#import "PostDetailViewController.h"
#import "ComposeViewController.h"
#import "SignupViewController.h"
#import "VerificationViewController.h"

@interface TimelineViewController () <TextCellViewDelegate,
                                      SignupViewControllerDelegate,
                                      VerificationViewControllerDelegate,
                                      ComposeViewControllerDelegate>

@end

@implementation TimelineViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = kPost.className;

        // The key of the PFObject to display in the label of the default cell style
        self.textKey = kPost.content;

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;

        self.objectsPerPage = 15;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadObjects)
                                                     name:RevealDidFinishEditingPostNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.title = @"Open";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TextCell *cell = (TextCell *) [tableView cellForRowAtIndexPath:indexPath];
    NSString *postType = [cell.post objectForKey:kPost.type];

    if ([postType isEqualToString:kPostType.text]) {
        [self showPostDetailViewControllerWithPost:cell.post focusOnComposeBarView:NO];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPost.type equalTo:kPostType.text];
    [query includeKey:kPost.company];
    [query includeKey:kPost.counter];
    [query orderByDescending:kPost.createdAt];

    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {

    static NSString *CellIdentifier = @"TextCell";

    TextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textCellView.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-pattern"]];
    cell.post = object;
    cell.textCellView.delegate = self;
    [cell updateCell];


    return cell;
}

#pragma mark - ComposerViewControllerDelegate

- (void)composeViewControllerDidCancel:(ComposeViewController *)viewController {
    CHECK_PRESENTED_VIEW_CONTROLLER(viewController.navigationController);
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)composeViewController:(ComposeViewController *)viewController didSave:(PFObject *)post error:(NSError *)error {
    CHECK_PRESENTED_VIEW_CONTROLLER(viewController.navigationController);
    if (error) {
        [viewController presentViewController:AlertViewController(@"Oops", error.userInfo[@"error"])
                                     animated:YES
                                   completion:nil];
        return;
    }

    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SignupViewControllerDelegate

- (void)showSignupViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
    UINavigationController *viewController = [storyboard instantiateInitialViewController];

    UIViewController* firstViewController = viewController.viewControllers.firstObject;
    if ([firstViewController isKindOfClass:[SignupViewController class]]) {
        SignupViewController* signupViewController = (SignupViewController *)firstViewController;
        signupViewController.delegate = self;
    }
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signupViewControllerDidCancel:(SignupViewController *)viewController {
    CHECK_PRESENTED_VIEW_CONTROLLER(viewController.navigationController);
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)signupViewController:(SignupViewController *)viewController
              didSubmitEmail:(NSString *)email
                       error:(NSError *)error {
    CHECK_PRESENTED_VIEW_CONTROLLER(viewController.navigationController);
    if (error) {
        [viewController.navigationController presentViewController:AlertViewController(@"Oops", error.userInfo[@"error"])
                                     animated:YES
                                   completion:nil];
        return;
    }

    // Try to refresh current user (so profile pointer is set)
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
        VerificationViewController *verificationViewController =
            [storyboard instantiateViewControllerWithIdentifier:@"VerificationViewController"];
        verificationViewController.delegate = self;

        [viewController.navigationController pushViewController:verificationViewController animated:YES];
    }];
}

#pragma mark - VerificationViewControllerDelegate

- (void)showVerificationViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
    VerificationViewController *viewController =
        [storyboard instantiateViewControllerWithIdentifier:@"VerificationViewController"];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)verificationViewControllerDidCancel:(VerificationViewController *)viewController {
    CHECK_PRESENTED_VIEW_CONTROLLER(viewController.navigationController);
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)verificationViewController:(VerificationViewController *)viewController didVerifyProfile:(PFObject *)profile error:(NSError *)error {
    CHECK_PRESENTED_VIEW_CONTROLLER(viewController.navigationController);
    if (error) {
        [viewController.navigationController presentViewController:AlertViewController(@"Oops", error.userInfo[@"error"])
                                     animated:YES
                                   completion:nil];
        return;
    }

    [[PFUser currentUser] fetchProfile:^(PFObject *profile, NSError *error) {
        [viewController.navigationController dismissViewControllerAnimated:NO completion: ^{
            if ([[profile objectForKey:kProfile.verified] boolValue]) {
                // Go to compose view if verified successfully
                [self showComposeViewController];
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation[@"logoinUpdate"] =  [NSDate date];
                [currentInstallation saveInBackground];
            }
        }];
    }];
}

#pragma mark - TextCellViewDelegate

- (void)textCellView:(TextCellView *)textCellView commentOnPost:(PFObject *)object {
    NSIndexPath *path = [self.tableView indexPathForCell:textCellView.tableViewCell];
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self showPostDetailViewControllerWithPost:object focusOnComposeBarView:YES];
}

- (void)textCellView:(TextCellView *)textCellView sharePost:(PFObject *)object {
    NSString *postUrl = [NSString stringWithFormat:@"http://open.parseapp.com/post/%@", object.objectId];
    NSURL *urlToPost = [NSURL URLWithString:postUrl];

    NSArray *objectsToShare = @[ urlToPost ];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                             applicationActivities:nil];

    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeMail,
                                   UIActivityTypeMessage,
                                   UIActivityTypeCopyToPasteboard];

    activityVC.popoverPresentationController.sourceView = self.view;
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - View controller helpers

- (void)showPostDetailViewControllerWithPost:(PFObject *)post focusOnComposeBarView:(BOOL)focus {
    PostDetailViewController *viewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
    viewController.selectedPost = post;
    viewController.focusOnComposeBarView = focus;
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)showComposeViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Composer" bundle:nil];
    UINavigationController *viewController = (UINavigationController *)[storyboard instantiateInitialViewController];

    NSAssert([viewController.viewControllers.firstObject isKindOfClass:[ComposeViewController class]],
             @"First view controller should be ComposeViewController");

    ComposeViewController *firstViewController = (ComposeViewController *)viewController.viewControllers.firstObject;
    firstViewController.delegate = self;

    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Button actions

- (IBAction)composeButtonAction:(id)sender {

    PFObject *profile = [[PFUser currentUser] objectForKey:kUser.profile];
    if (!profile) {
        [self showSignupViewController];
    } else {
        if ([profile isDataAvailable]) {
            if (![[profile objectForKey:kProfile.verified] boolValue]) {
                [self showSignupViewController];
            } else {
                [self showComposeViewController];
            }
        } else {
            [profile fetchInBackgroundWithBlock:^(PFObject *profile, NSError *error) {
                if (![[profile objectForKey:kProfile.verified] boolValue]) {
                    [self showSignupViewController];
                } else {
                    [self showComposeViewController];
                }
            }];
        }
    }
}

@end
