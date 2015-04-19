//
//  BaseView.h
//  Reveal
//
//

#import <UIKit/UIKit.h>

/**
 * Base class for custom view, this wires up the autolayout of the view.
 *
 * To use this class, follow the steps
 * - Create a new xib and its corresponding UIView class files.
 * - Open the new xib file, select File's Owner, and set it to your new class
 * - Go to connection inspector, wire the view to your root view.
 */
@interface BaseView : UIView

- (void)commonInit;

@property (strong, nonatomic) IBOutlet UIView *view;

@end
