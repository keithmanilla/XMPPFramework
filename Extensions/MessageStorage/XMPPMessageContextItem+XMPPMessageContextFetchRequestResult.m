#import "XMPPMessageContextItem+XMPPMessageContextFetchRequestResult.h"

@implementation XMPPMessageContextItem (XMPPMessageContextFetchRequestResult)

- (XMPPMessageBaseNode *)relevantMessageNode
{
    return self.messageNode;
}

@end
