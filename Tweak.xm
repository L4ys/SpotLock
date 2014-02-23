#import <GraphicsServices/GraphicsServices.h>
#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_0
#define kCFCoreFoundationVersionNumber_iOS_6_0 793.00
#endif

// ====================================================================================
// Classes 

@interface SBIconController : NSObject <UIScrollViewDelegate>
+ (id)sharedInstance;
- (void)scrollRight;
- (BOOL)scrollToIconListAtIndex:(NSInteger)index animate:(BOOL)animate;
@end

@interface SBRootFolderView : UIView
@end

@interface SpringBoard : UIApplication
- (void)lockButtonUp:(__GSEvent *)event;
- (void)lockButtonDown:(__GSEvent *)event;
@end

// ====================================================================================

static void LockDevice()
{ 
    SpringBoard *sb = (SpringBoard*)[UIApplication sharedApplication];
    __GSEvent* event = NULL;
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    
    record.timestamp = GSCurrentEventTimestamp();
    record.type = kGSEventLockButtonDown;
    
    if ( kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 ) {
        event = GSEventCreateWithEventRecord(&record);
        [sb lockButtonDown:event];
        CFRelease(event);
    } else {
        GSSendSystemEvent(&record);
    }

    record.type = kGSEventLockButtonUp;

    if ( kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 ) {
        event = GSEventCreateWithEventRecord(&record);
        [sb lockButtonUp:event];
        CFRelease(event);
    } else {
        GSSendSystemEvent(&record);
    }
}

%group Firmware_70

%end

%hook SBIconController

- (void)_lockScreenUIWillLock:(id)arg1
{
    // Scroll back to first page of spring board befor device lock to prevent some postion showing problem
    %orig;
    [self scrollToIconListAtIndex:0 animate:NO];
}

%end

%hook SBRootFolderView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    %orig;
    
    // Add a page to the left of first page of spring board
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, screenRect.size.width, 0.0f, 0.0f)];
}

%new(v@:@{CGPoint=dd}@{^CGPoint})
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)targetContentOffset
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if ( targetContentOffset->x == 0 - screenRect.size.width )
        LockDevice();
}

%end

%end
// ====================================================================================
// iOS6

%group Firmware_60

%hook SBSearchView

- (void)setShowsKeyboard:(BOOL)keyboard animated:(BOOL)animated shouldDeferResponderStatus:(BOOL)status
{
    if ( keyboard && status )
        LockDevice();
    else
        %orig;
}

%end

%end

// ====================================================================================
// < iOS 6

%group Firmware_50 

%hook SBSearchView

- (void)setShowsKeyboard:(BOOL)keyboard animated:(BOOL)animated
{
    if ( keyboard ) {
        LockDevice();
        [[%c(SBIconController) sharedInstance] scrollRight];
    } else {
        %orig;
    }
}

%end

%end

// ====================================================================================
// iOS 5 / 6

%hook SBIconController

- (void)scrollToIconListAtIndex:(int)index animate:(BOOL)animated
{
    // Disable scroll to search page via home button or something else
    if ( index == -1 )
        return;
    %orig;
}

%end

%hook SBSearchView

- (UISearchBar *)searchBarClass
{
    // Remove search bar
    UISearchBar *searchBar = %orig;
    if ( searchBar ) {
        [searchBar release];
        searchBar = nil;
    }
    return nil;
}

%end

// ====================================================================================

%ctor 
{
    if ( kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 ) {
        //NSLog(@"[SpotLock] Firmware >= 7.0");
        %init(Firmware_70);
    } else {
        %init
        if  ( kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0 ) {
            //NSLog(@"[SpotLock] Firmware >= iOS6");
            %init(Firmware_60);
        } else {
            //NSLog(@"[SpotLock] Firmware < iOS6");
            %init(Firmware_50);
        }
    }

}

