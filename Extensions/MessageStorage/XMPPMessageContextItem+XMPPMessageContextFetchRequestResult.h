#import "XMPPMessageContextItem.h"
#import "XMPPMessageBaseNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageContextItem (XMPPMessageContextFetchRequestResult) <XMPPMessageContextFetchRequestResult>

@property (nonatomic, strong, readonly) XMPPMessageBaseNode *messageNode;

@end

NS_ASSUME_NONNULL_END
