#import "XMPPMessageBaseNode.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPMessageContextNode, XMPPMessageContextJIDItem, XMPPMessageContextMarkerItem, XMPPMessageContextStringItem, XMPPMessageContextTimestampItem;

@interface XMPPMessageBaseNode (Protected)

@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextJIDItem *> *allJIDItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextMarkerItem *> *allMarkerItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextStringItem *> *allStringItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextTimestampItem *> *allTimestampItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextNode *> *contextNodes;

@end

@interface XMPPMessageBaseNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addAllJIDItemsObject:(XMPPMessageContextJIDItem *)value;
- (void)removeAllJIDItemsObject:(XMPPMessageContextJIDItem *)value;
- (void)addAllJIDItems:(NSSet<XMPPMessageContextJIDItem *> *)value;
- (void)removeAllJIDItems:(NSSet<XMPPMessageContextJIDItem *> *)value;

- (void)addAllMarkerItemsObject:(XMPPMessageContextMarkerItem *)value;
- (void)removeAllMarkerItemsObject:(XMPPMessageContextMarkerItem *)value;
- (void)addAllMarkerItems:(NSSet<XMPPMessageContextMarkerItem *> *)value;
- (void)removeAllMarkerItems:(NSSet<XMPPMessageContextMarkerItem *> *)value;

- (void)addAllStringItemsObject:(XMPPMessageContextStringItem *)value;
- (void)removeAllStringItemsObject:(XMPPMessageContextStringItem *)value;
- (void)addAllStringItems:(NSSet<XMPPMessageContextStringItem *> *)value;
- (void)removeAllStringItems:(NSSet<XMPPMessageContextStringItem *> *)value;

- (void)addAllTimestampItemsObject:(XMPPMessageContextTimestampItem *)value;
- (void)removeAllTimestampItemsObject:(XMPPMessageContextTimestampItem *)value;
- (void)addAllTimestampItems:(NSSet<XMPPMessageContextTimestampItem *> *)value;
- (void)removeAllTimestampItems:(NSSet<XMPPMessageContextTimestampItem *> *)value;

- (void)addContextNodesObject:(XMPPMessageContextNode *)value;
- (void)removeContextNodesObject:(XMPPMessageContextNode *)value;
- (void)addContextNodes:(NSSet<XMPPMessageContextNode *> *)value;
- (void)removeContextNodes:(NSSet<XMPPMessageContextNode *> *)value;

@end

NS_ASSUME_NONNULL_END
