#import "XMPPMessageBaseNode.h"
#import "XMPPMessageContextNode.h"
#import "XMPPMessageContextItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageBaseNode (ContextObsoletion)

- (nullable id)lookupInCurrentContextWithBlock:(id __nullable (^)(XMPPMessageContextNode *contextNode))lookupBlock;

@end

@interface XMPPMessageContextNode (ContextObsoletion)

- (void)obsolete;

@end

@interface XMPPMessageContextItem (ContextObsoletion)

+ (NSPredicate *)currentNodePredicate;

@end

NS_ASSUME_NONNULL_END
