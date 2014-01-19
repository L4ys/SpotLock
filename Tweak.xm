#import <SpringBoard/SpringBoard.h>
#import <GraphicsServices/GraphicsServices.h>

void LockDevice() 
{
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));

    record.timestamp = GSCurrentEventTimestamp();

    record.type = kGSEventLockButtonDown;
    GSSendSystemEvent(&record);

    record.type = kGSEventLockButtonUp;
    GSSendSystemEvent(&record);
}

%hook SBIconController

- (void)scrollToIconListAtIndex:(int)index animate:(BOOL)animate
{
    if ( index == -1 )
        return;
    %orig;
}

%end

%hook SBSearchView

- (Class)searchBarClass
{
    return nil;
}

%end

// ====================================================================================
// >= iOS6
%group Firmware_ge_60

%hook SBSearchView

- (void)setShowsKeyboard:(BOOL)keyboard animated:(BOOL)animated shouldDeferResponderStatus:(BOOL)status 
{
    if ( keyboard && status ) {
        LockDevice();
    } else
        %orig; 
}

%end

%end

// ====================================================================================
// < iOS 6
%group Firmware_lt_60

%hook SBSearchView

- (void)setShowsKeyboard:(BOOL)keyboard animated:(BOOL)animated 
{
    if ( keyboard ) {
        LockDevice();
        [[%c(SBIconController) sharedInstance] scrollRight];
    } else
        %orig;
};

%end

%end

// ====================================================================================

%ctor 
{
    %init

    if ( kCFCoreFoundationVersionNumber < 793.00 ) {  // < iOS 6
        // NSLog(@"[SpotLock] Firmware < iOS6");
        %init(Firmware_lt_60);
    } else {                                          // >= iOS 6
        // NSLog(@"[SpotLock] Firmware >= iOS6");
        %init(Firmware_ge_60);
    }

}
