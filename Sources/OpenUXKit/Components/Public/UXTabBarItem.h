

#import <OpenUXKit/UXBarItem.h>

@class NSArray, NSSet, UXTabBarItemSegment;

@interface UXTabBarItem: UXBarItem

@property(copy, nonatomic) NSArray<UXTabBarItemSegment *> *representedSegments; // @synthesize representedSegments=_representedSegments;
@property(copy, nonatomic) NSSet *possibleTitles; // @synthesize possibleTitles=_possibleTitles;
- (id)initWithTitle:(NSString *)title;

@end

