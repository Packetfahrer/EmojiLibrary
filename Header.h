#import "../PS.h"
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIKBRenderFactory.h>
#import <UIKit/UIKBKeyView.h>
#import <UIKit/UIKBRenderConfig.h>
#import <UIKit/UIKBRenderTraits.h>
#import <UIKit/UIApplication+Private.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIKBKeyView (KBResize)
- (void)emoji83_positionFixForKeyplane:(UIKBTree *)keyplane key:(UIKBTree *)key;
@end

@interface EMFEmojiLocaleData : NSObject // iOS 10+
@end

@interface EMFEmojiToken : NSObject // iOS 10+
+ (instancetype)emojiTokenWithString:(NSString *)string localeData:(EMFEmojiLocaleData *)localeData;
- (NSString *)string;
@end

@interface UIKeyboardEmoji : NSObject {
    NSString *_emojiString;
    BOOL _hasDingbat;
}
@property(retain) NSString *emojiString;
@property BOOL hasDingbat; // iOS 7-8.2
@property(retain, nonatomic) NSString *name; // iOS 5
@property(retain, nonatomic) NSString *imageName; // iOS 5
@property(retain, nonatomic) NSString *publicCodePoint; // iOS 5
@property(retain, nonatomic) NSString *privateCodePoint; // iOS 5
@property(assign) unsigned short unicodeCharacter; // iOS 5
@property(retain) NSString *codePoint; // iOS 5
@property(assign) CGGlyph glyph; // iOS 6-7
@property NSUInteger variantMask; // iOS 8.3+
+ (instancetype)emojiWithString:(NSString *)string; // iOS 6
+ (instancetype)emojiWithString:(NSString *)string hasDingbat:(BOOL)dingbat; // iOS 7-8.2
+ (instancetype)emojiWithString:(NSString *)string withVariantMask:(NSInteger)mask; // iOS 8.3+
- (instancetype)initWithString:(NSString *)string; // iOS 6
- (instancetype)initWithString:(NSString *)string hasDingbat:(BOOL)dingbat; // iOS 7-8.2
- (instancetype)initWithName:(id)name imageName:(id)imageName codePoint:(unsigned short)codePoint; // iOS 5
- (BOOL)isEqual:(UIKeyboardEmoji *)emoji;
- (NSString *)key; // -emojiString
- (id)image; // iOS 5
@end

@interface UIKeyboardEmoji (EmojiHUD)
@property(assign) BOOL supportsSkin;
@end

@interface UIKeyboardEmojiCategory : NSObject
@property NSInteger categoryType; // iOS 6+
@property NSInteger lastViewedPage;
@property(getter = displaySymbol, readonly) NSString *displaySymbol; // iOS 6+
@property(getter = displayName, readonly) NSString *displayName; // iOS 7
@property(retain) NSMutableArray <UIKeyboardEmoji *> *emoji;
@property NSUInteger lastVisibleFirstEmojiIndex;
@property(readonly) NSString *name;
@property(readonly) NSString *recentDescription; // iOS 7+
+ (instancetype)categoryForType:(NSInteger)categoryType; // iOS 6+
+ (NSMutableArray <UIKeyboardEmojiCategory *> *)categories;
+ (NSMutableArray <UIKeyboardEmoji *> *)emojiRecentsFromPreferences;
+ (NSArray <NSNumber *> *)enabledCategoryIndexes; // iOS 9.1+
+ (NSUInteger)hasVariantsForEmoji:(NSString *)emoji; // iOS 7+
+ (NSInteger)categoryTypeForCategoryIndex:(NSInteger)index; // iOS 9.1+
+ (NSInteger)numberOfCategories; // iOS 6+
+ (NSString *)localizedStringForKey:(NSString *)key; // iOS 6+
+ (NSString *)displayName:(NSInteger)categoryType; // iOS 8.3+
+ (BOOL)emojiString:(NSString *)string inGroup:(UTF32Char *)group withGroupCount:(NSUInteger)count; // iOS 6-9
+ (BOOL)emojiString:(NSString *)string inGroup:(NSArray <NSString *> *)group; // iOS 10+
- (void)releaseCategories;

// iOS < 10.2
+ (NSArray <NSString *> *)PeopleEmoji;
+ (NSArray <NSString *> *)NatureEmoji;
+ (NSArray <NSString *> *)FoodAndDrinkEmoji;
+ (NSArray <NSString *> *)CelebrationEmoji;
+ (NSArray <NSString *> *)ActivityEmoji;
+ (NSArray <NSString *> *)TravelAndPlacesEmoji;
+ (NSArray <NSString *> *)ObjectsAndSymbolsEmoji;
+ (NSArray <NSString *> *)ObjectsEmoji;
+ (NSArray <NSString *> *)SymbolsEmoji;
+ (NSArray <NSString *> *)flagEmojiCountryCodesCommon;
+ (NSArray <NSString *> *)flagEmojiCountryCodesReadyToUse; // blacklist check
+ (NSArray <NSString *> *)computeEmojiFlagsSortedByLanguage; // call -flagEmojiCountryCodesReadyToUse

+ (NSArray <NSString *> *)DingbatVariantsEmoji;
+ (NSArray <NSString *> *)SkinToneEmoji;
+ (NSArray <NSString *> *)GenderEmoji;
+ (NSArray <NSString *> *)NoneVariantEmoji;
+ (NSArray <NSString *> *)PrepopulatedEmoji;

+ (NSArray <NSString *> *)loadPrecomputedEmojiFlagCategory; // empty on iOS 10.2+

// iOS 10.2+
+ (NSArray <NSString *> *)ProfessionEmoji;
+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emoji;
@end

@interface UIKeyboardEmojiCategory (EmojiLocalization)
+ (NSArray <NSString *> *)displayNames;
+ (NSArray <NSString *> *)categoriesMap;
@end

@interface EMFEmojiCategory : NSObject
+ (id)_emojiSetForIdentifier:(NSString *)identifier setCount:(NSUInteger *)count; // iOS 10-10.1
+ (NSArray <NSString *> *)_emojiSetForIdentifier:(NSString *)identifier; // iOS 10.2+
- (NSString *)identifier;
@end

@interface UIKeyboardEmojiPage : UIView {
    NSInteger _numCols;
    NSInteger _numRows;
    NSInteger _numPages;
}
@property(retain, nonatomic) NSDictionary *emojiAttributes;
@property(retain, nonatomic) NSArray *emoji;
- (CGRect)rectForRow:(NSInteger)row Col:(NSInteger)col;
- (id)activeTouch;
- (void)touchCancelled:(id)touch;
@end

@interface UIKeyboardEmojiImageView : UIImageView
@end

@protocol UIKeyboardEmojiPressIndicationDelegate;

@interface UIKeyboardEmojiView : UIView {
    UIKeyboardEmoji *_emoji;
    UIView *_popup;
    UIKeyboardEmojiImageView *_imageView;
    UIKBRenderConfig *_renderConfig;
    UIView <UIKeyboardEmojiPressIndicationDelegate> *_delegate;
}
@property (retain) UIKeyboardEmoji *emoji;
@property (nonatomic, retain) UIKBRenderConfig *renderConfig;
@property (retain) UIView <UIKeyboardEmojiPressIndicationDelegate> *delegate;
@property (retain) UIView *popup;
@property (retain) UIKeyboardEmojiImageView *imageView;
+ (instancetype)emojiViewForEmoji:(UIKeyboardEmoji *)emoji withFrame:(CGRect)frame;
+ (void)recycleEmojiView:(UIKeyboardEmojiImageView *)emojiView;
- (void)uninstallPopup;
- (id)createAndInstallKeyPopupView;
- (void)setEmoji:(UIKeyboardEmoji *)emoji withFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame emoji:(UIKeyboardEmoji *)emoji;
@end

@interface UIKeyboardEmojiScrollView : UIScrollView
@property(retain, nonatomic) UIKBRenderConfig *renderConfig;
- (NSInteger)currentPage;
- (void)doLayout;
- (void)forceLayout;
- (void)layoutPages;
- (void)layoutRecents;
- (void)setCategory:(UIKeyboardEmojiCategory *)category; // iOS 5
@end

@interface UIKeyboardEmojiGraphicsTraits : NSObject
- (CGFloat)emojiKeyWidth;
- (NSInteger)prepolulatedRecentCount;
@end

@class UIKeyboardEmojiCollectionInputView;

@interface UIKeyboardEmojiInputController : NSObject
+ (UIView *)activeInputView; // iOS < 8.3 (UIKeyboardEmojiScrollView), iOS 8.3+ (UIKeyboardEmojiCollectionInputView)
- (void)emojiUsed:(UIKeyboardEmoji *)emoji;
- (double)scoreForEmoji:(UIKeyboardEmoji *)emoji;
- (NSMutableArray <UIKeyboardEmoji *> *)recents;
- (NSMutableDictionary <NSString *, NSString *> *)skinToneBaseKeyPreferences; // iOS 8.3+
@end

@interface UIKeyboardEmojiCollectionView : UICollectionView
@property(retain, nonatomic) UIKeyboardEmojiInputController *inputController;
- (UIKeyboardEmojiGraphicsTraits *)emojiGraphicsTraits;
@end

@interface UIKeyboardEmojiCollectionInputView : UIKBKeyView {
    UIKeyboardEmojiCollectionView *_collectionView;
}
- (NSString *)emojiBaseUnicodeString:(NSString *)string; // iOS 8.3-9.3
#ifdef WT
- (NSString *)emojiBaseString:(NSString *)string; // iOS >= 10
- (NSString *)emojiBaseFirstCharacterString:(NSString *)string; // iOS >= 10
#endif
@end

@interface UIKeyboardEmojiCollectionViewCell : UICollectionViewCell
@property NSInteger emojiFontSize;
@property(retain, nonatomic) UIKeyboardEmoji *emoji;
@end

@interface UIPageControl (Private)
- (UIImage *)_pageIndicatorImage;
@end

@interface _UIEmojiPageControl : UIPageControl
@end

@interface EmojiPageControl : UIPageControl
@end

@interface UIKeyboardEmojiDefaultsController : NSObject
+ (instancetype)sharedController;
@property NSInteger currentSequenceKey;
@property(retain, nonatomic) id recentsKey;
@property(retain, nonatomic) id usageHistoryKey;
- (NSDictionary *)emptyDefaultsDictionary;
- (void)readEmojiDefaults;
- (void)writeEmojiDefaults;
@end

@interface UIKeyboardEmojiPreferences : NSObject // iOS 9.3+
+ (instancetype)sharedInstance;
- (NSDictionary *)emptyDefaultsDictionary;
- (void)readEmojiDefaults;
- (void)writeEmojiDefaults;
@end

@interface UIKeyboardEmojiGraphics : NSObject
+ (instancetype)sharedInstance;
+ (CGFloat)emojiPageControlYOffset:(BOOL)portrait;
+ (CGSize)emojiSize:(BOOL)portrait;
+ (CGPoint)margin:(BOOL)portrait;
+ (CGPoint)padding:(BOOL)portrait;
+ (NSInteger)rowCount:(BOOL)portrait;
+ (NSInteger)colCount:(BOOL)portrait;
+ (BOOL)isLandscape;
+ (NSString *)emojiCategoryImagePath:(UIKeyboardEmojiCategory *)category; // iOS 8.3-10.1
+ (NSString *)emojiCategoryImagePath:(UIKeyboardEmojiCategory *)category forRenderConfig:(UIKBRenderConfig *)renderConfig; // iOS 10.2+
+ (UIImage *)imageWithRect:(CGRect)rect name:(NSString *)name pressed:(BOOL)pressed;
- (UIImage *)categoryRecentsGenerator:(id)pressed;
- (UIImage *)categoryPeopleGenerator:(id)pressed;
- (UIImage *)categoryNatureGenerator:(id)pressed;
- (UIImage *)categoryObjectsGenerator:(id)pressed;
- (UIImage *)categoryPlacesGenerator:(id)pressed;
- (UIImage *)categorySymbolsGenerator:(id)pressed;
- (UIImage *)categoryWithSymbol:(NSString *)symbol pressed:(id)pressed;
@end

@interface UIKeyboardEmojiScrubBarView : UIView // iOS 8.3+
@end

#ifdef WT
@protocol UIKeyboardEmojiCategoryUpdate
@property(retain, nonatomic) UIKeyboardEmojiKeyDisplayController *emojiKeyManager;
- (void)updateToCategory:(NSInteger)categoryType;
@optional
- (void)updateToCategoryWithOffsetPercentage:(CGFloat)offsetPercentage;
@end

@interface UIKeyboardEmojiKeyView : UIKBKeyView<UIKeyboardEmojiCategoryUpdate> // iOS 10
@end

@interface UIKeyboardEmojiCategoryBar : UIKeyboardEmojiKeyView
#else
@interface UIKeyboardEmojiCategoryBar : UIKBKeyView
#endif
{
#ifdef LEGACY
    NSArray *_dividerViews;
    NSArray *_segmentViews;
    NSInteger _total;
    NSInteger _dividerTotal;
#endif
    int _selected;
}
#ifdef LEGACY
- (void)releaseImagesAndViews;
- (void)updateSegmentAndDividers:(NSInteger)arg1; // ?
#endif
@end

@interface UIKeyboardEmojiCategoryBar_iPhone : UIKeyboardEmojiCategoryBar
#ifdef LEGACY
{
    NSArray *_unselectedImages;
    NSArray *_selectedImages;
}
- (void)updateSegmentImages;
#endif
@end

@interface UIKeyboardEmojiCategoryBar_iPad : UIKeyboardEmojiCategoryBar
#ifdef LEGACY
{
    NSArray *_unselectedImages;
    NSArray *_selectedImages;
}
- (void)updateSegmentImages;
#endif
@end

@interface UIKeyboardEmojiSplit : UIKBKeyView<UITableViewDelegate, UITableViewDataSource>
@end

@interface UIKeyboardEmojiSplitCategoryPicker : UIKeyboardEmojiSplit
@end

@interface UIKBRenderFactoryiPhone : UIKBRenderFactory
- (NSArray *)variantGeometriesForGeometry:(UIKBRenderGeometry *)geometry variantCount:(NSUInteger)count;
@end

@interface UIKBRenderFactory_Emoji : UIKBRenderFactory
- (UIKBRenderTraits *)_emojiCategoryControlKeyActiveTraits;
- (UIKBRenderTraits *)_emojiCategoryControlKeyTraits; // iOS 7.0-8.3
- (UIKBGradient *)_emojiSpaceKeyActiveBackgroundColorGradient;
- (UIKBGradient *)_emojiSpaceKeyBackgroundColorGradient;
- (UIKBGradient *)_emojiInputViewKeyBackgroundColorGradient;
- (NSString *)_emojiBorderColor; // iOS 7.0-8.3
@end

@interface UIKBRenderFactoryiPhone_Emoji : UIKBRenderFactory_Emoji
@end

@interface UIKBRenderFactoryEmoji_iPhone : UIKBRenderFactory_Emoji
@end

@interface UIKeyboardEmojiFactory : NSObject { // iOS 5
    NSMutableDictionary *emojiMap;
}
- (UIKeyboardEmoji *)emojiWithKey:(id)key;
- (UIKeyboardEmoji *)emojiWithPrivateCodePoint:(id)privateCodePoint;
@end

@interface UIKeyboardEmojiCategoriesControl : UIView // iOS 5
@property(assign) int selectedIndex;
@end

@interface UIKeyboardEmojiRecentsController : NSObject // iOS 5
- (void)emojiUsed:(UIKeyboardEmoji *)emoji;
@end

@interface UIKeyboardEmojiCategoriesControl_iPhone : UIKeyboardEmojiCategoriesControl // iOS 5
- (void)releaseImagesAndViews;
- (void)updateSegmentAndDividers:(NSInteger)arg1; // ?
@end

@interface UIKeyboardEmojiCategoriesControl_iPad : UIKeyboardEmojiCategoriesControl // iOS 5
- (void)releaseImagesAndViews;
- (void)updateSegmentAndDividers:(NSInteger)arg1; // ?
@end

@interface UIKeyboardLayoutEmoji : NSObject // iOS 5
+ (instancetype)emojiLayout;
+ (NSString *)localizedStringForKey:(NSString *)key;
+ (BOOL)isLandscape;
- (NSMutableArray <UIKeyboardEmoji *> *)recents;
- (UIKeyboardEmoji *)emojiWithString:(NSString *)emojiString;
- (void)emojiSelected:(UIKeyboardEmoji *)emoji;
- (void)emojiUsed:(UIKeyboardEmoji *)emoji;
- (CGRect)categoryFrame;
@end

@interface UIKeyboardEmojiCategoryController : NSObject // iOS 5
- (UIKeyboardEmojiCategory *)categoryForKey:(NSString *)categoryKey;
- (void)updateRecents;
@end

@interface TIKeyboardLayoutFactory : NSObject {
    void *_layoutsLibraryHandle;
}
+ (instancetype)sharedKeyboardFactory;
+ (NSString *)layoutsFileName;
@property(readonly, nonatomic) void *layoutsLibraryHandle;
@property(retain) NSMutableDictionary *internalCache;
- (UIKBTree *)keyboardWithName:(NSString *)name inCache:(NSMutableDictionary *)cache;
@end
