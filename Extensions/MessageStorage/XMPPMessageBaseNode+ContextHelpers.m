#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

@implementation XMPPMessageBaseNode (ContextHelpers)

- (XMPPMessageContextNode *)appendContextNodeWithStreamEventID:(NSString *)streamEventID
{
    NSAssert(self.managedObjectContext, @"Attempted to append a context node to a message node not associated with any managed object context");
    
    XMPPMessageContextNode *insertedNode = [XMPPMessageContextNode xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedNode.streamEventID = streamEventID;
    insertedNode.messageNode = self;
    return insertedNode;
}

@end

@implementation XMPPMessageContextNode (ContextHelpers)

- (XMPPMessageContextJIDItem *)appendJIDItemWithTag:(XMPPMessageContextJIDItemTag)tag value:(XMPPJID *)value
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextJIDItem *insertedItem = [XMPPMessageContextJIDItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.value = value;
    insertedItem.contextNode = self;
    insertedItem.messageNode = self.messageNode;
    return insertedItem;
}

- (XMPPMessageContextMarkerItem *)appendMarkerItemWithTag:(XMPPMessageContextMarkerItemTag)tag
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextMarkerItem *insertedItem = [XMPPMessageContextMarkerItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.contextNode = self;
    insertedItem.messageNode = self.messageNode;
    return insertedItem;
}

- (XMPPMessageContextStringItem *)appendStringItemWithTag:(XMPPMessageContextStringItemTag)tag value:(NSString *)value
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextStringItem *insertedItem = [XMPPMessageContextStringItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.value = value;
    insertedItem.contextNode = self;
    insertedItem.messageNode = self.messageNode;
    return insertedItem;
}

- (XMPPMessageContextTimestampItem *)appendTimestampItemWithTag:(XMPPMessageContextTimestampItemTag)tag value:(NSDate *)value
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextTimestampItem *insertedItem = [XMPPMessageContextTimestampItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.value = value;
    insertedItem.contextNode = self;
    insertedItem.messageNode = self.messageNode;
    return insertedItem;
}

@end
