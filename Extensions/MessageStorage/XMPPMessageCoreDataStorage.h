#import "XMPPCoreDataStorage.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPStream;

@interface XMPPMessageCoreDataStorage : XMPPCoreDataStorage

- (void)scheduleStorageActionForEventWithID:(NSString *)streamEventID inStream:(XMPPStream *)xmppStream withBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
