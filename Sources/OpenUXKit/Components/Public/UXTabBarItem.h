

#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXBarItem.h>

@class NSArray, NSSet, UXTabBarItemSegment;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTabBarItem: UXBarItem

@property(copy, nonatomic) NSArray<UXTabBarItemSegment *> *representedSegments; // @synthesize representedSegments=_representedSegments;
@property(copy, nonatomic) NSSet *possibleTitles; // @synthesize possibleTitles=_possibleTitles;
- (id)initWithTitle:(NSString *)title;

@end

