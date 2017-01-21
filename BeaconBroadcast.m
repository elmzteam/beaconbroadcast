#import "BeaconBroadcast.h"

NS_ASSUME_NONNULL_BEGIN

@interface BeaconBroadcast()

@property (nonatomic, strong, nullable) CLLocationManager *locationManager;
@property (nonatomic, strong, nullable) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong, nullable) CBPeripheralManager *peripheralManager;

@end

@implementation BeaconBroadcast

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(startSharedAdvertisingBeaconWithString:(NSString *)uuid identifier:(NSString *)identifier major:(NSInteger)major minor:(NSInteger)minor)
{
    [[BeaconBroadcast sharedInstance] startAdvertisingBeaconWithString: uuid identifier: identifier major: major minor: minor];
}

RCT_EXPORT_METHOD(stopSharedAdvertisingBeacon)
{
    [[BeaconBroadcast sharedInstance] stopAdvertisingBeacon];
}

#pragma mark - Common

+ (instancetype)sharedInstance
{
    static dispatch_once_t p;
    static id _sharedObject;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (void)startAdvertisingBeaconWithString:(NSString *)uuid identifier:(NSString *)identifier major:(NSInteger)major minor:(NSInteger)minor
{
  NSLog(@"Turning on advertising...");

  [self createBeaconRegionWithString:uuid identifier:identifier major:major minor:minor];

  if (!self.peripheralManager)
      self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];

  [self turnOnAdvertising];
}

- (void)stopAdvertisingBeacon
{
  [self.peripheralManager stopAdvertising];

  NSLog(@"Turned off advertising.");
}

- (void)createBeaconRegionWithString:(NSString *)uuid identifier:(NSString *)identifier major:(NSInteger)major minor:(NSInteger)minor
{
    if (self.beaconRegion)
        return;

    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:uuid];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:major minor:minor identifier:identifier];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

#pragma mark - Beacon advertising

- (void)turnOnAdvertising
{
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        return;
    }

    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                     major:self.beaconRegion.major
                                                                     minor:self.beaconRegion.minor
                                                                identifier:self.beaconRegion.identifier];
    NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];

    NSLog(@"Turning on advertising for region: %@.", region);
}

#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"Couldn't turn on advertising: %@", error);
        return;
    }

    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising.");
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        return;
    }

    NSLog(@"Peripheral manager is on.");
    [self turnOnAdvertising];
}


@end

NS_ASSUME_NONNULL_END
