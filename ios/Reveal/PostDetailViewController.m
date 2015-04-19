//
//  PostDetailViewController.m
//  Reveal
//
//

#import "PostDetailViewController.h"

#import "TextCellView.h"
#import "TextDetailCell.h"
#import "CommentCell.h"
#import "ComposeBarHelper.h"

@interface PostDetailViewController () <PHFComposeBarViewDelegate, TextCellViewDelegate>
@property (strong, nonatomic, readonly) ComposeBarHelper *composeBarHelper;
@property (assign, nonatomic) BOOL translatesAutoresizingMask;
@end

@implementation PostDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = kPost.className;

        self.textKey = kPost.content;

        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 15;
        self.loadingViewEnabled = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadObjects)
                                                     name:RevealDidFinishPostingCommentNotification
                                                   object:nil];

        _composeBarHelper = [[ComposeBarHelper alloc] initWithViewController:self delegate:self];

    }
    return self;
}

#pragma mark - UIViewController callback

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.composeBarHelper setupComposeBar];

    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.composeBarHelper addComposeBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.composeBarHelper removeComposeBar];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.focusOnComposeBarView) {
        [self.composeBarHelper.composeBarView becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHFComposeBarViewDelegate

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    //NSString *text = [NSString stringWithFormat:@"Main button pressed. Text:\n%@", [composeBarView text]];

    NSString *content = [composeBarView.text cleanedString];
    if (content.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops, empty comment"
                                                                                 message:@"Go back or discard?"
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go back", @"Go back action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 NSLog(@"Go back action");
                                                             }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }

    PFObject *comment = [PFObject objectWithClassName:kPost.className];
    [comment setObject:content forKey:kPost.content];
    [comment setObject:kPostType.comment forKey:kPost.type];
    [comment setObject:self.selectedPost forKey:kPost.parent];

    PFACL *publicReadAcl = [PFACL ACL];
    [publicReadAcl setPublicReadAccess:YES];
    [comment setACL:publicReadAcl];

    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RevealDidFinishPostingCommentNotification
                                                                object:comment];

            PFObject *counter = [self.selectedPost objectForKey:kPost.counter];
            [counter incrementKey:kPostCounter.commentCount];
            [counter saveInBackground];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostCounterUpdated
                                                                object:self
                                                              userInfo:@{ @"objectId": self.selectedPost.objectId }];
        }

        if (error) {
            NSLog(@"Failed to post comment %@", content);
        }
    }];
    [composeBarView setText:@"" animated:YES];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    [composeBarView resignFirstResponder];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }

    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    return count == 0 ? 1 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TextDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextDetailCell" forIndexPath:indexPath];
        cell.textCellView.delegate = self;
        [cell updateWithData:self.selectedPost];
        return cell;
    }

    if (self.objects.count == 0 && indexPath.section == 1 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AskForCommentCell" forIndexPath:indexPath];
        return cell;
    }

    // PFQueryTableViewController behavior
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPost.type equalTo:kPostType.comment];
    [query whereKey:kPost.parent equalTo:self.selectedPost];
    [query orderByAscending:kPost.createdAt];
    [query includeKey:kPost.company];
    [query includeKey:kPost.parent];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.comment = object;
    [cell updateCell];

    return cell;
}

#pragma mark - TextCellViewDelegate

- (void)textCellView:(TextCellView *)textCellView commentOnPost:(PFObject *)object {
    [self.composeBarHelper.composeBarView becomeFirstResponder];
}

- (void)textCellView:(TextCellView *)textCellView sharePost:(PFObject *)object {
    [self.composeBarHelper.composeBarView resignFirstResponder];
    
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

    activityVC.excludedActivityTypes = excludeActivities;
    activityVC.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityVC animated:YES completion:nil];
}
@end
