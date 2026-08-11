#import <Foundation/Foundation.h>

@interface Greeter : NSObject
- (NSString *)messageForName:(NSString *)name;
@end

@implementation Greeter
- (NSString *)messageForName:(NSString *)name {
  // TODO: Localize the greeting.
  return [NSString stringWithFormat:@"Hello, %@", name];
}
@end
