#define UIFUNCTIONS_NOT_C
#import "Header.h"
#import "PSEmojiType.h"

#define ZWJ @"‍"
#define FE0F @"️"
#define FEMALE @"♀"
#define MALE @"♂"
#define ZWJ2640 @"‍♀"
#define ZWJ2642 @"‍♂"
#define ZWJ2640FE0F @"‍♀️"
#define ZWJ2642FE0F @"‍♂️"

#define CATEGORIES_COUNT 9

@interface PSEmojiUtilities : NSObject
@end

@interface PSEmojiUtilities (Emoji)

+ (NSArray <NSString *> *)PeopleEmoji;
+ (NSArray <NSString *> *)NatureEmoji;
+ (NSArray <NSString *> *)FoodAndDrinkEmoji;
+ (NSArray <NSString *> *)CelebrationEmoji;
+ (NSArray <NSString *> *)ActivityEmoji;
+ (NSArray <NSString *> *)TravelAndPlacesEmoji;
+ (NSArray <NSString *> *)ObjectsEmoji;
+ (NSArray <NSString *> *)SymbolsEmoji;
+ (NSArray <NSString *> *)FlagsEmoji;
+ (NSArray <NSString *> *)DingbatVariantsEmoji;
+ (NSArray <NSString *> *)SkinToneEmoji;
+ (NSArray <NSString *> *)GenderEmoji;
+ (NSArray <NSString *> *)NoneVariantEmoji;
+ (NSArray <NSString *> *)ProfessionEmoji;
+ (NSArray <NSString *> *)PrepolulatedEmoji;
+ (NSArray <NSString *> *)PrepopulatedEmoji;
@end

@interface PSEmojiUtilities (Functions)

+ (NSArray <NSString *> *)skinModifiers;

+ (UChar32)firstLongCharacter:(NSString *)string;

+ (NSString *)getGender:(NSString *)emojiString;
+ (NSString *)getSkin:(NSString *)emojiString;
+ (NSString *)getProfession:(NSString *)emojiString;
+ (NSString *)changeEmojiSkin:(NSString *)emojiString toSkin:(NSString *)skin;
+ (NSString *)emojiBaseFirstCharacterString:(NSString *)emojiString;
+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emojiString;
+ (NSString *)emojiGenderString:(NSString *)emojiString baseFirst:(NSString *)baseFirst skin:(NSString *)skin;
+ (NSString *)emojiBaseString:(NSString *)emojiString;
+ (NSString *)skinToneVariant:(NSString *)emojiString baseFirst:(NSString *)baseFirst base:(NSString *)base skin:(NSString *)skin;
+ (NSString *)skinToneVariant:(NSString *)emojiString skin:(NSString *)skin;
+ (NSString *)overrideKBTreeEmoji:(NSString *)emojiString overrideNewVariant:(BOOL)overrideNewVariant;

+ (UIKeyboardEmojiCollectionViewCell *)collectionView:(UICollectionView *)collectionView_ cellForItemAtIndexPath:(NSIndexPath *)indexPath inputView:(UIKeyboardEmojiCollectionInputView *)inputView;
+ (UIKeyboardEmojiCategory *)prepopulatedCategory;

+ (BOOL)genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiString;
+ (BOOL)emojiString:(NSString *)emojiString inGroup:(NSArray <NSString *> *)group;
+ (BOOL)hasGender:(NSString *)emojiString;
+ (BOOL)hasSkin:(NSString *)emojiString;
+ (BOOL)hasDingbat:(NSString *)emojiString;
+ (BOOL)sectionHasSkin:(NSInteger)section;

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString;

+ (NSMutableArray <NSString *> *)skinToneVariants:(NSString *)emojiString isSkin:(BOOL)isSkin;
+ (NSMutableArray <NSString *> *)skinToneVariants:(NSString *)emojiString;

+ (UIKeyboardEmoji *)emojiWithString:(NSString *)emojiString;
+ (UIKeyboardEmoji *)emojiWithString:(NSString *)emojiString withVariantMask:(NSInteger)variantMask;
+ (UIKeyboardEmoji *)emojiWithStringUniversal:(NSString *)emojiString;

+ (void)addEmoji:(NSMutableArray <UIKeyboardEmoji *> *)emojiArray emojiString:(NSString *)emojiString withVariantMask:(NSInteger)variantMask;
+ (void)addEmoji:(NSMutableArray <UIKeyboardEmoji *> *)emojiArray emojiString:(NSString *)emojiString;

+ (void)resetEmojiPreferences;

@end

#define SoftPSEmojiUtilities NSClassFromString(@"PSEmojiUtilities")
