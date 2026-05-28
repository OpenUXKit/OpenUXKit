#import <OpenUXKit/UXTableViewCell.h>

@interface UXTableViewCell () {
    NSString *_text;
    NSString *_detailText;
    NSImage *_image;
}
@end

@implementation UXTableViewCell

@synthesize text = _text;
@synthesize detailText = _detailText;
@synthesize image = _image;

@end
