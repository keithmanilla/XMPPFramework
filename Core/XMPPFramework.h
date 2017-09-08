#import <Foundation/Foundation.h>

#import "XMPPBandwidthMonitor.h"
#import "XMPP.h"
#import "XMPPConstants.h"
#import "XMPPElement.h"
#import "XMPPInternal.h"
#import "XMPPIQ.h"
#import "XMPPJID.h"
#import "XMPPLogging.h"
#import "XMPPMessage.h"
#import "XMPPModule.h"
#import "XMPPParser.h"
#import "XMPPPresence.h"
#import "XMPPStream.h"
#import "XMPPAnonymousAuthentication.h"
#import "XMPPDeprecatedDigestAuthentication.h"
#import "XMPPDeprecatedPlainAuthentication.h"
#import "XMPPDigestMD5Authentication.h"
#import "XMPPPlainAuthentication.h"
#import "XMPPSCRAMSHA1Authentication.h"
#import "XMPPXOAuth2Google.h"
#import "XMPPCustomBinding.h"
#import "XMPPSASLAuthentication.h"
#import "NSData+XMPP.h"
#import "NSNumber+XMPP.h"
#import "NSXMLElement+XMPP.h"
#import "DDList.h"
#import "GCDMulticastDelegate.h"
#import "RFImageToDataTransformer.h"
#import "XMPPIDTracker.h"
#import "XMPPSRVResolver.h"
#import "XMPPStringPrep.h"
#import "XMPPTimer.h"
#import "XMPPCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "NSXMLElement+XEP_0203.h"
#import "XMPPFileTransfer.h"
#import "XMPPIncomingFileTransfer.h"
#import "XMPPOutgoingFileTransfer.h"
#import "XMPPGoogleSharedStatus.h"
#import "NSXMLElement+OMEMO.h"
#import "OMEMOBundle.h"
#import "OMEMOKeyData.h"
#import "OMEMOModule.h"
#import "OMEMOPreKey.h"
#import "OMEMOSignedPreKey.h"
#import "XMPPIQ+OMEMO.h"
#import "XMPPMessage+OMEMO.h"
#import "XMPPProcessOne.h"
#import "XMPPReconnect.h"
#import "XMPPGroupCoreDataStorageObject.h"
#import "XMPPResourceCoreDataStorageObject.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "XMPPResourceMemoryStorageObject.h"
#import "XMPPRosterMemoryStorage.h"
#import "XMPPRosterMemoryStoragePrivate.h"
#import "XMPPUserMemoryStorageObject.h"
#import "XMPPResource.h"
#import "XMPPRoster.h"
#import "XMPPRosterPrivate.h"
#import "XMPPUser.h"
#import "XMPPIQ+JabberRPC.h"
#import "XMPPIQ+JabberRPCResonse.h"
#import "XMPPJabberRPCModule.h"
#import "XMPPIQ+LastActivity.h"
#import "XMPPLastActivity.h"
#import "XMPPPrivacy.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "XMPPRoomOccupantCoreDataStorageObject.h"
#import "XMPPRoomHybridStorage.h"
#import "XMPPRoomHybridStorageProtected.h"
#import "XMPPRoomMessageHybridCoreDataStorageObject.h"
#import "XMPPRoomOccupantHybridMemoryStorageObject.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoomMessageMemoryStorageObject.h"
#import "XMPPRoomOccupantMemoryStorageObject.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPMUC.h"
#import "XMPPRoom.h"
#import "XMPPRoomMessage.h"
#import "XMPPRoomOccupant.h"
#import "XMPPRoomPrivate.h"
#import "XMPPvCardAvatarCoreDataStorageObject.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardCoreDataStorageObject.h"
#import "XMPPvCardTempCoreDataStorageObject.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempAdr.h"
#import "XMPPvCardTempAdrTypes.h"
#import "XMPPvCardTempBase.h"
#import "XMPPvCardTempEmail.h"
#import "XMPPvCardTempLabel.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardTempTel.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPDateTimeProfiles.h"
#import "NSDate+XMPPDateTimeProfiles.h"
#import "NSXMLElement+XEP_0059.h"
#import "XMPPResultSet.h"
#import "XMPPIQ+XEP_0060.h"
#import "XMPPPubSub.h"
#import "TURNSocket.h"
#import "XMPPIQ+XEP_0066.h"
#import "XMPPMessage+XEP_0066.h"
#import "XMPPRegistration.h"
#import "NSDate+XMPPDateTimeProfiles.h"
#import "XMPPDateTimeProfiles.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPSoftwareVersion.h"
#import "XMPPTransports.h"
#import "NSString+XEP_0106.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPCapsCoreDataStorageObject.h"
#import "XMPPCapsResourceCoreDataStorageObject.h"
#import "XMPPCapabilities.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPMessageArchiving.h"
#import "XMPPURI.h"
#import "XMPPvCardAvatarModule.h"
#import "NSDate+XMPPDateTimeProfiles.h"
#import "XMPPMessage+XEP_0172.h"
#import "XMPPPresence+XEP_0172.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "XMPPBlocking.h"
#import "XMPPStreamManagementMemoryStorage.h"
#import "XMPPStreamManagementStanzas.h"
#import "XMPPStreamManagement.h"
#import "XMPPAutoPing.h"
#import "XMPPPing.h"
#import "XMPPAutoTime.h"
#import "XMPPTime.h"
#import "NSXMLElement+XEP_0203.h"
#import "XEP_0223.h"
#import "XMPPAttentionModule.h"
#import "XMPPMessage+XEP_0224.h"
#import "XMPPMessage+XEP_0280.h"
#import "XMPPMessageCarbons.h"
#import "NSXMLElement+XEP_0297.h"
#import "NSXMLElement+XEP_0297.h"
#import "NSXMLElement+XEP_0203.h"
#import "XMPPMessage+XEP_0308.h"
#import "XMPPMessageArchiveManagement.h"
#import "XMPPRoomLightCoreDataStorage+XEP_0313.h"
#import "XMPPMessage+XEP_0333.h"
#import "XMPPMessage+XEP_0334.h"
#import "NSXMLElement+XEP_0335.h"
#import "NSXMLElement+XEP_0352.h"
#import "XMPPIQ+XEP_0357.h"
#import "XMPPHTTPFileUpload.h"
#import "XMPPSlot.h"
#import "XMPPMUCLight.h"
#import "XMPPRoomLight.h"
#import "XMPPRoomLightCoreDataStorage.h"
#import "XMPPRoomLightCoreDataStorageProtected.h"
#import "XMPPRoomLightMessageCoreDataStorageObject.h"
#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPMessageBaseNode+ContextObsoletion.h"
#import "XMPPMessageContextNode.h"
#import "XMPPMessageContextItem.h"
#import "XMPPMessageContextItem+XMPPMessageContextFetchRequestResult.h"

FOUNDATION_EXPORT double XMPPFrameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char XMPPFrameworkVersionString[];
