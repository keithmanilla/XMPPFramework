#import "XMPPMessageBaseNode+ContextObsoletion.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"

static XMPPMessageContextMarkerItemTag const XMPPMessageContextObsoletionTag = @"XMPPMessageContextObsoletion";

@implementation XMPPMessageBaseNode (ContextObsoletion)

- (id)lookupInCurrentContextWithBlock:(id  _Nullable (^)(XMPPMessageContextNode * _Nonnull))lookupBlock
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return ![contextNode hasMarkerItemForTag:XMPPMessageContextObsoletionTag] ? lookupBlock(contextNode) : nil;
    }];
}

@end

@implementation XMPPMessageContextNode (ContextObsoletion)

- (void)obsolete
{
    [self appendMarkerItemWithTag:XMPPMessageContextObsoletionTag];
}

@end

@implementation XMPPMessageContextItem (ContextObsoletion)

+ (NSPredicate *)currentNodePredicate
{
    return [NSPredicate predicateWithFormat:@"NONE %K.%K.%K = %@",
            NSStringFromSelector(@selector(contextNode)), NSStringFromSelector(@selector(markerItems)), NSStringFromSelector(@selector(tag)),
            XMPPMessageContextObsoletionTag];
}

@end

