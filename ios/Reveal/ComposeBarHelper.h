//
//  ComposeBarHelper.h
//  Reveal
//
//

#import <Foundation/Foundation.h>
#import "PHFComposeBarView.h"

@interface ComposeBarHelper : NSObject

- (instancetype)initWithViewController:(UITableViewController *)viewController
                              delegate:(id<PHFComposeBarViewDelegate>)delegate;


// Call in viewDidLoad
- (void)setupComposeBar;

// Call in viewWillAppear
- (void)addComposeBar;

// Call in viewWillDisappear
- (void)removeComposeBar;

@property (readonly, nonatomic) PHFComposeBarView *composeBarView;

@end
