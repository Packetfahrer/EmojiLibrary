/* Emoji variants
   XXXX: 4 binary digits of (Profession)-(Gender)-(Skin)-(Dingbat)
 */

typedef NS_ENUM (NSUInteger, PSEmojiType) {
    PSEmojiTypeProfession = 8, // 10.2+
    PSEmojiTypeGender = 4, // 10.0+
    PSEmojiTypeSkin = 2,
    PSEmojiTypeDingbat = 1,
    PSEmojiTypeRegular = 0
};
