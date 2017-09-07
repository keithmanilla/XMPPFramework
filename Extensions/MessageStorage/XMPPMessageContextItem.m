#import "XMPPMessageContextItem.h"
#import "XMPPJID.h"

@implementation XMPPMessageContextItem

@dynamic contextNode, messageNode;

@end

@interface XMPPMessageContextJIDItem ()

@property (nonatomic, copy, nullable) NSString *valueDomain;
@property (nonatomic, copy, nullable) NSString *valueResource;
@property (nonatomic, copy, nullable) NSString *valueUser;

@end

@interface XMPPMessageContextJIDItem (CoreDataGeneratedPrimitiveAccessors)

- (XMPPJID *)primitiveValue;
- (void)setPrimitiveValue:(XMPPJID *)value;
- (void)setPrimitiveValueDomain:(NSString *)value;
- (void)setPrimitiveValueResource:(NSString *)value;
- (void)setPrimitiveValueUser:(NSString *)value;

@end

@implementation XMPPMessageContextJIDItem

@dynamic tag, valueDomain, valueResource, valueUser;

#pragma mark - value transient property

- (XMPPJID *)value
{
    [self willAccessValueForKey:NSStringFromSelector(@selector(value))];
    XMPPJID *value = [self primitiveValue];
    [self didAccessValueForKey:NSStringFromSelector(@selector(value))];
    
    if (value) {
        return value;
    }
    
    XMPPJID *newValue = [XMPPJID jidWithUser:self.valueUser domain:self.valueDomain resource:self.valueResource];
    [self setPrimitiveValue:newValue];
    
    return newValue;
}

- (void)setValue:(XMPPJID *)value
{
    if ([self.value isEqualToJID:value]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(valueDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(valueResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(valueUser))];
    [self setPrimitiveValue:value];
    [self setPrimitiveValueDomain:value.domain];
    [self setPrimitiveValueResource:value.resource];
    [self setPrimitiveValueUser:value.user];
    [self didChangeValueForKey:NSStringFromSelector(@selector(valueDomain))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(valueResource))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(valueUser))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (void)setValueDomain:(NSString *)valueDomain
{
    if ([self.valueDomain isEqualToString:valueDomain]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(valueDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self setPrimitiveValueDomain:valueDomain];
    [self setPrimitiveValue:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(valueDomain))];
}

- (void)setValueResource:(NSString *)valueResource
{
    if ([self.valueResource isEqualToString:valueResource]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(valueResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self setPrimitiveValueResource:valueResource];
    [self setPrimitiveValue:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(valueResource))];
}

- (void)setValueUser:(NSString *)valueUser
{
    if ([self.valueUser isEqualToString:valueUser]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(valueUser))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self setPrimitiveValueUser:valueUser];
    [self setPrimitiveValue:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(valueUser))];
}

@end

@implementation XMPPMessageContextMarkerItem

@dynamic tag;

@end

@implementation XMPPMessageContextStringItem

@dynamic tag, value;

@end

@implementation XMPPMessageContextTimestampItem

@dynamic tag, value;

@end
