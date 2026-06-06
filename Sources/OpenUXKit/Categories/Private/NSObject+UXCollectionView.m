#import "NSObject+UXCollectionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSObject (UXCollectionView)

- (void)performWithoutAnimation:(void (NS_NOESCAPE ^)(void))animation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (animation) {
        animation();
    }
    [CATransaction commit];
}

@end
