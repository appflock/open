//
//  NSString+Utils.m
//  Reveal
//
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)cleanedString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
