#import "XMPPMessageBaseNode.h"
#import "XMPPMessageContextNode.h"
#import "XMPPMessageContextItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageBaseNode (ContextHelpers)

- (XMPPMessageContextNode *)appendContextNodeWithStreamEventID:(NSString *)streamEventID;

@end

@interface XMPPMessageContextNode (ContextHelpers)

- (XMPPMessageContextJIDItem *)appendJIDItemWithTag:(XMPPMessageContextJIDItemTag)tag value:(XMPPJID *)value;
- (XMPPMessageContextMarkerItem *)appendMarkerItemWithTag:(XMPPMessageContextMarkerItemTag)tag;
- (XMPPMessageContextStringItem *)appendStringItemWithTag:(XMPPMessageContextStringItemTag)tag value:(NSString *)value;
- (XMPPMessageContextTimestampItem *)appendTimestampItemWithTag:(XMPPMessageContextTimestampItemTag)tag value:(NSDate *)value;


@end

NS_ASSUME_NONNULL_END
