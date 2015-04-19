//
//  BaseView.m
//  Reveal
//
//

#import "BaseView.h"

@interface BaseView ()
@property (nonatomic, strong) NSMutableArray *customConstraints;
@end

@implementation BaseView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _customConstraints = [[NSMutableArray alloc] init];

    NSString *className = NSStringFromClass([self class]);
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    self.view = [[mainBundle loadNibNamed:className owner:self options:nil] firstObject];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.view];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [self removeConstraints:self.customConstraints];
    [self.customConstraints removeAllObjects];

    if (self.view != nil) {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0];

        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0];

        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:0];

        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0];
        [self.customConstraints addObject:topConstraint];
        [self.customConstraints addObject:bottomConstraint];
        [self.customConstraints addObject:leftConstraint];
        [self.customConstraints addObject:rightConstraint];

        [self addConstraints:self.customConstraints];
    }

    [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
    return self.bounds.size;
}

@end
