#import "_UXSettings.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE
@interface _UXSettingsGroup : _UXSettings <NSFastEnumeration>

- (void)enumerateSettingsUsingBlock:(void (^)(_UXSettings *settings, NSUInteger index, BOOL *stop))block;
- (void)addGroupObserver:(id)observer;
- (void)removeGroupObserver:(id)observer;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
