#import <CoreData/CoreData.h>
#import "XMPPJID.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPJID, XMPPMessage;
@protocol XMPPMessageContextFetchRequestResult;

typedef NS_ENUM(int16_t, XMPPMessageDirection) {
    XMPPMessageDirectionUnspecified,
    XMPPMessageDirectionIncoming,
    XMPPMessageDirectionOutgoing
};

typedef NS_ENUM(int16_t, XMPPMessageType) {
    XMPPMessageTypeNormal,
    XMPPMessageTypeChat,
    XMPPMessageTypeError,
    XMPPMessageTypeGroupchat,
    XMPPMessageTypeHeadline
};

@interface XMPPMessageBaseNode : NSManagedObject

@property (nonatomic, strong, nullable) XMPPJID *fromJID;
@property (nonatomic, strong, nullable) XMPPJID *toJID;

@property (nonatomic, copy, nullable) NSString *body;
@property (nonatomic, copy, nullable) NSString *stanzaID;
@property (nonatomic, copy, nullable) NSString *subject;
@property (nonatomic, copy, nullable) NSString *thread;

@property (nonatomic, assign) XMPPMessageDirection direction;
@property (nonatomic, assign) XMPPMessageType type;

+ (XMPPMessageBaseNode *)findOrCreateForIncomingMessage:(XMPPMessage *)message
                                      withStreamEventID:(NSString *)streamEventID
                                              streamJID:(XMPPJID *)streamJID
                                              timestamp:(NSDate *)timestamp
                                 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)insertForOutgoingMessageInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable XMPPMessageBaseNode *)findForLocalOriginMessageWithStreamEventID:(NSString *)streamEventID
                                                      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSFetchedResultsController<XMPPMessageContextFetchRequestResult> *)fetchTimestampContextWithPredicate:(NSPredicate *)predicate
                                                                                        inAscendingOrder:(BOOL)isInAscendingOrder
                                                                                fromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSPredicate *)streamTimestampContextPredicate;
+ (NSPredicate *)relevantMessageFromJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)relevantMessageToJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)relevantMessageRemotePartyJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)contextTimestampRangePredicateWithStartValue:(nullable NSDate *)startValue endValue:(nullable NSDate *)endValue;

- (XMPPMessage *)baseMessage;

- (void)registerLocalOriginMessageWithStreamEventID:(NSString *)streamEventID;
- (void)registerSentMessageWithStreamJID:(XMPPJID *)streamJID timestamp:(NSDate *)timestamp;

- (nullable XMPPJID *)streamJID;
- (nullable NSDate *)timestamp;

@end

@protocol XMPPMessageContextFetchRequestResult <NSFetchRequestResult>

@property (nonatomic, strong, readonly) XMPPMessageBaseNode *relevantMessageNode;

@end

NS_ASSUME_NONNULL_END
