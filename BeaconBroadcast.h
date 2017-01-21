#import "RCTBridgeModule.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeaconBroadcast : NSObject <RCTBridgeModule, CLLocationManagerDelegate, CBPeripheralManagerDelegate>

@end

NS_ASSUME_NONNULL_END
