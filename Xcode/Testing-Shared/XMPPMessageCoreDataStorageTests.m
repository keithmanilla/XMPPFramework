//
//  XMPPMessageCoreDataStorageTests.m
//  XMPPFrameworkTests
//
//  Created by Piotr Wegrzynek on 10/08/2017.
//
//

#import <XCTest/XCTest.h>
@import XMPPFramework;

@interface XMPPMessageCoreDataStorageTests : XCTestCase

@property (nonatomic, strong) XMPPMessageCoreDataStorage *storage;

@end

@implementation XMPPMessageCoreDataStorageTests

- (void)setUp
{
    [super setUp];
    
    self.storage = [[XMPPMessageCoreDataStorage alloc] initWithDatabaseFilename:NSStringFromSelector(self.invocation.selector)
                                                                   storeOptions:nil];
    self.storage.autoRemovePreviousDatabaseFile = YES;
}

- (void)testBaseNodeTransientPropertyDirectUpdates
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    [self.storage.mainThreadManagedObjectContext save:NULL];
    [self.storage.mainThreadManagedObjectContext refreshObject:messageNode mergeChanges:NO];
    
    XCTAssertEqualObjects(messageNode.fromJID, [XMPPJID jidWithString:@"user1@domain1/resource1"]);
    XCTAssertEqualObjects(messageNode.toJID, [XMPPJID jidWithString:@"user2@domain2/resource2"]);
}

- (void)testBaseNodeTransientPropertyMergeUpdates
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    [self.storage.mainThreadManagedObjectContext save:NULL];
    
    [self expectationForNotification:NSManagedObjectContextObjectsDidChangeNotification object:self.storage.mainThreadManagedObjectContext handler:nil];
    
    [self.storage scheduleBlock:^{
        XMPPMessageBaseNode *storageContextMessageNode = [self.storage.managedObjectContext objectWithID:messageNode.objectID];
        storageContextMessageNode.fromJID = [XMPPJID jidWithString:@"user1a@domain1a/resource1a"];
        storageContextMessageNode.toJID = [XMPPJID jidWithString:@"user2a@domain2a/resource2a"];
        [self.storage save];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssert([messageNode.fromJID isEqualToJID:[XMPPJID jidWithString:@"user1a@domain1a/resource1a"]]);
        XCTAssert([messageNode.toJID isEqualToJID:[XMPPJID jidWithString:@"user2a@domain2a/resource2a"]]);
    }];
}

- (void)testBaseNodeTransientPropertyKeyValueObserving
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    [self keyValueObservingExpectationForObject:messageNode
                                        keyPath:NSStringFromSelector(@selector(fromJID))
                                  expectedValue:[XMPPJID jidWithString:@"user1@domain1/resource1"]];
    [self keyValueObservingExpectationForObject:messageNode
                                        keyPath:NSStringFromSelector(@selector(toJID))
                                  expectedValue:[XMPPJID jidWithString:@"user2@domain2/resource2"]];
    
    messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    [self waitForExpectationsWithTimeout:0 handler:nil];
}

- (void)testIncomingMessageStorage
{
    NSDictionary<NSString *, NSNumber *> *messageTypes = @{@"chat": @(XMPPMessageTypeChat),
                                                           @"error": @(XMPPMessageTypeError),
                                                           @"groupchat": @(XMPPMessageTypeGroupchat),
                                                           @"headline": @(XMPPMessageTypeHeadline),
                                                           @"normal": @(XMPPMessageTypeNormal)};
    
    for (NSString *typeString in messageTypes) {
        NSMutableString *messageString = [NSMutableString string];
        [messageString appendFormat: @"<message from='user1@domain1/resource1' to='user2@domain2/resource2' type='%@' id='messageID'>", typeString];
        [messageString appendString: @"	 <body>body</body>"];
        [messageString appendString: @"	 <subject>subject</subject>"];
        [messageString appendString: @"	 <thread>thread</thread>"];
        [messageString appendString: @"</message>"];
        
        NSDate *timestamp = [NSDate date];
        
        XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] initWithXMLString:messageString error:NULL]
                                                                             withStreamEventID:[NSString stringWithFormat:@"eventID_%@", typeString]
                                                                                     streamJID:[XMPPJID jidWithString:@"user2@domain2/resource2"]
                                                                                     timestamp:timestamp
                                                                        inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
        
        XCTAssertEqualObjects(messageNode.fromJID, [XMPPJID jidWithString:@"user1@domain1/resource1"]);
        XCTAssertEqualObjects(messageNode.toJID, [XMPPJID jidWithString:@"user2@domain2/resource2"]);
        XCTAssertEqualObjects(messageNode.body, @"body");
        XCTAssertEqual(messageNode.direction, XMPPMessageDirectionIncoming);
        XCTAssertEqualObjects(messageNode.stanzaID, @"messageID");
        XCTAssertEqualObjects(messageNode.subject, @"subject");
        XCTAssertEqualObjects(messageNode.thread, @"thread");
        XCTAssertEqual(messageNode.type, messageTypes[typeString].intValue);
        XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user2@domain2/resource2"]);
        XCTAssertEqualObjects([messageNode timestamp], timestamp);
    }
}

- (void)testIncomingMessageExistingEventLookup
{
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    XMPPMessageBaseNode *existingNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] init]
                                                                          withStreamEventID:@"eventID"
                                                                                  streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                  timestamp:timestamp
                                                                     inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    XMPPMessageBaseNode *repeatedQueryNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] init]
                                                                               withStreamEventID:@"eventID"
                                                                                       streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                       timestamp:timestamp
                                                                          inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    XCTAssertEqualObjects(existingNode, repeatedQueryNode);
}

- (void)testLocalOriginMessageNodeInsertion
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerLocalOriginMessageWithStreamEventID:@"localOriginMessageEventID"];
    XMPPMessageBaseNode *foundNode = [XMPPMessageBaseNode findForLocalOriginMessageWithStreamEventID:@"localOriginMessageEventID"
                                                                              inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    XCTAssertEqual(messageNode.direction, XMPPMessageDirectionOutgoing);
    XCTAssertEqualObjects(messageNode, foundNode);
}

- (void)testSingleSentMessageRegistration
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerLocalOriginMessageWithStreamEventID:@"localOriginMessageEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    
    XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user@domain/resource"]);
    XCTAssertEqualObjects([messageNode timestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:0]);
}

- (void)testRepeatedSentMessageRegistration
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerLocalOriginMessageWithStreamEventID:@"initialEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user1@domain1/resource1"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [messageNode registerLocalOriginMessageWithStreamEventID:@"subsequentEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user2@domain2/resource2"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    
    XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user2@domain2/resource2"]);
    XCTAssertEqualObjects([messageNode timestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:1]);
}

- (void)testBasicStreamTimestampMessageContextFetch
{
    XMPPMessageBaseNode *firstMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] init]
                                                                              withStreamEventID:@"firstMessageEventID"
                                                                                      streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                      timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                         inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    XMPPMessageBaseNode *secondMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] init]
                                                                               withStreamEventID:@"secondMessageEventID"
                                                                                       streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                       timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                          inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *fetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode streamTimestampContextPredicate]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [fetchedResultsController performFetch:NULL];
    
    XCTAssertEqual(fetchedResultsController.fetchedObjects.count, 2);
    XCTAssertEqualObjects(fetchedResultsController.fetchedObjects[0].relevantMessageNode, firstMessageNode);
    XCTAssertEqualObjects(fetchedResultsController.fetchedObjects[1].relevantMessageNode, secondMessageNode);
}

- (void)testObsoletedStreamTimestampMessageContextFetch
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerLocalOriginMessageWithStreamEventID:@"obsoletedMessageEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [messageNode registerLocalOriginMessageWithStreamEventID:@"obsoletingMessageEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *fetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode streamTimestampContextPredicate]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [fetchedResultsController performFetch:NULL];
    
    XCTAssertEqual(fetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects([fetchedResultsController.fetchedObjects[0].relevantMessageNode timestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:1]);
}

- (void)testRelevantMessageJIDContextFetch
{
    XMPPMessageBaseNode *incomingMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] init]
                                                                                 withStreamEventID:@"incomingMessageEventID"
                                                                                         streamJID:[XMPPJID jidWithString:@"user1@domain1/resource1"]
                                                                                         timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                            inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    incomingMessageNode.fromJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    XMPPMessageBaseNode *outgoingMessageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    outgoingMessageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    [outgoingMessageNode registerLocalOriginMessageWithStreamEventID:@"outgoingMessageEventID"];
    [outgoingMessageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user1@domain1/resource1"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *fromJIDResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode relevantMessageFromJIDPredicateWithValue:[XMPPJID jidWithString:@"user2@domain2/resource2"] compareOptions:XMPPJIDCompareFull]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [fromJIDResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *toJIDResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode relevantMessageToJIDPredicateWithValue:[XMPPJID jidWithString:@"user2@domain2/resource2"] compareOptions:XMPPJIDCompareFull]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [toJIDResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *remotePartyJIDResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode relevantMessageRemotePartyJIDPredicateWithValue:[XMPPJID jidWithString:@"user2@domain2/resource2"]
                                                                                                                  compareOptions:XMPPJIDCompareFull]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [remotePartyJIDResultsController performFetch:NULL];
    
    XCTAssertEqual(fromJIDResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(fromJIDResultsController.fetchedObjects[0].relevantMessageNode, incomingMessageNode);
    
    XCTAssertEqual(toJIDResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(toJIDResultsController.fetchedObjects[0].relevantMessageNode, outgoingMessageNode);
    
    XCTAssertEqual(remotePartyJIDResultsController.fetchedObjects.count, 2);
    XCTAssertEqualObjects(remotePartyJIDResultsController.fetchedObjects[0].relevantMessageNode, incomingMessageNode);
    XCTAssertEqualObjects(remotePartyJIDResultsController.fetchedObjects[1].relevantMessageNode, outgoingMessageNode);
}

- (void)testTimestampRangeContextFetch
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessage:[[XMPPMessage alloc] init]
                                                                         withStreamEventID:@"eventID"
                                                                                 streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                 timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                    inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *startEndFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:-1]
                                                                                                                     endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:1]]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [startEndFetchedResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *startEndEdgeCaseFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                                                     endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [startEndEdgeCaseFetchedResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *startFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:-1]
                                                                                                                     endValue:nil]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [startFetchedResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *startEdgeCaseFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                                                     endValue:nil]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [startEdgeCaseFetchedResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *endFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:nil
                                                                                                                     endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:1]]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [endFetchedResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *endEdgeCaseFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:nil
                                                                                                                     endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [endEdgeCaseFetchedResultsController performFetch:NULL];
    
    NSFetchedResultsController<id<XMPPMessageContextFetchRequestResult>> *missFetchedResultsController =
    [XMPPMessageBaseNode fetchTimestampContextWithPredicate:[XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                                                                     endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:2]]
                                           inAscendingOrder:YES
                                   fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [missFetchedResultsController performFetch:NULL];
    
    XCTAssertEqual(startEndFetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(startEndFetchedResultsController.fetchedObjects[0].relevantMessageNode, messageNode);
    XCTAssertEqual(startEndEdgeCaseFetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(startEndEdgeCaseFetchedResultsController.fetchedObjects[0].relevantMessageNode, messageNode);
    
    XCTAssertEqual(startFetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(startFetchedResultsController.fetchedObjects[0].relevantMessageNode, messageNode);
    XCTAssertEqual(startEdgeCaseFetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(startEdgeCaseFetchedResultsController.fetchedObjects[0].relevantMessageNode, messageNode);
    
    XCTAssertEqual(endFetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(endFetchedResultsController.fetchedObjects[0].relevantMessageNode, messageNode);
    XCTAssertEqual(endEdgeCaseFetchedResultsController.fetchedObjects.count, 1);
    XCTAssertEqualObjects(endEdgeCaseFetchedResultsController.fetchedObjects[0].relevantMessageNode, messageNode);
    
    XCTAssertEqual(missFetchedResultsController.fetchedObjects.count, 0);
}

- (void)testBaseMessageCreation
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    messageNode.body = @"body";
    messageNode.stanzaID = @"messageID";
    messageNode.subject = @"subject";
    messageNode.thread = @"thread";
    
    NSDictionary<NSString *, NSNumber *> *messageTypes = @{@"chat": @(XMPPMessageTypeChat),
                                                           @"error": @(XMPPMessageTypeError),
                                                           @"groupchat": @(XMPPMessageTypeGroupchat),
                                                           @"headline": @(XMPPMessageTypeHeadline),
                                                           @"normal": @(XMPPMessageTypeNormal)};
    
    for (NSString *typeString in messageTypes){
        messageNode.type = messageTypes[typeString].intValue;
        
        XMPPMessage *message = [messageNode baseMessage];
        
        XCTAssertEqualObjects([message to], [XMPPJID jidWithString:@"user2@domain2/resource2"]);
        XCTAssertEqualObjects([message body], @"body");
        XCTAssertEqualObjects([message elementID], @"messageID");
        XCTAssertEqualObjects([message subject], @"subject");
        XCTAssertEqualObjects([message thread], @"thread");
        XCTAssertEqualObjects([message type], typeString);
    }
}

@end
