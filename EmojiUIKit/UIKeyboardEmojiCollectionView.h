#import "UIKeyboardEmojiInputController.h"
#import "UIKeyboardEmojiGraphicsTraits.h"

// iOS 8.3+
@interface UIKeyboardEmojiCollectionView : UICollectionView
@property(retain, nonatomic) UIKeyboardEmojiInputController *inputController;
- (UIKeyboardEmojiGraphicsTraits *)emojiGraphicsTraits;
@end
