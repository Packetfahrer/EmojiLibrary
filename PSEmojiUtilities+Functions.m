#import "PSEmojiUtilities.h"
#import <objc/runtime.h>

@implementation PSEmojiUtilities (Functions)

+ (NSArray <NSString *> *)skinModifiers {
    return @[ @"🏻", @"🏼", @"🏽", @"🏾", @"🏿" ];
}

+ (UChar32)firstLongCharacter:(NSString *)string {
    if ([string respondsToSelector:@selector(_firstLongCharacter)])
        return [string _firstLongCharacter];
    UChar32 cbase = 0;
    if (string.length) {
        cbase = [string characterAtIndex:0];
        if ((cbase & 0xfc00) == 0xd800 && string.length >= 2) {
            UChar32 y = [string characterAtIndex:1];
            if ((y & 0xfc00) == 0xdc00)
                cbase = (cbase << 10) + y - 0x35fdc00;
        }
    }
    return cbase;
}

+ (BOOL)sectionHasSkin:(NSInteger)section {
    return section <= 1 || section == 4;
}

+ (BOOL)genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiString {
    if (stringEqual(emojiString, @"🏋") || stringEqual(emojiString, @"⛹") || stringEqual(emojiString, @"🕵") || stringEqual(emojiString, @"🏌"))
        return NO;
    return YES;
}

+ (BOOL)emojiString:(NSString *)emojiString inGroup:(NSArray <NSString *> *)group {
    if (!group || group.count == 0)
        return NO;
    NSUInteger index = [group indexOfObject:emojiString inSortedRange:NSMakeRange(0, group.count) options:NSBinarySearchingFirstEqual
                            usingComparator :^(id str1, id str2) {
        /*if (stringEqual(str1, str2))
                return (NSComparisonResult)NSOrderedSame;*/
        UChar32 f1 = [self firstLongCharacter:(NSString *)str1];
        UChar32 f2 = [self firstLongCharacter:(NSString *)str2];
        if (f1 == f2)
            return (NSComparisonResult)NSOrderedSame;
        return f1 > f2 ? (NSComparisonResult)NSOrderedDescending : (NSComparisonResult)NSOrderedAscending;
    }];
    return index != NSNotFound;
}

+ (NSString *)emojiBaseFirstCharacterString:(NSString *)emojiString {
    return [NSString stringWithUnichar:[self firstLongCharacter:emojiString]];
}

+ (NSString *)getGender:(NSString *)emojiString {
    if (containString(emojiString, FEMALE))
        return FEMALE;
    if (containString(emojiString, MALE))
        return MALE;
    return nil;
}

+ (BOOL)hasGender:(NSString *)emojiString {
    return [self getGender:emojiString] != nil;
}

+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emojiString {
    for (NSString *skin in [self skinModifiers]) {
        if (containString(emojiString, skin))
            return [emojiString stringByReplacingOccurrencesOfString:skin withString:@"" options:NSLiteralSearch range:NSMakeRange(0, emojiString.length)];
    }
    return emojiString;
}

+ (NSString *)emojiStringWithoutVariantSelector:(NSString *)emojiString {
    return [emojiString stringByReplacingOccurrencesOfString:FE0F withString:@"" options:NSLiteralSearch range:NSMakeRange(0, emojiString.length)];
}

+ (NSString *)getProfession:(NSString *)emojiString {
    if ([[self ProfessionEmoji] containsObject:[self professionSkinToneEmojiBaseKey:emojiString]]) {
        NSString *base = [self emojiBaseString:emojiString];
        NSString *baseFirst = [self emojiBaseFirstCharacterString:emojiString];
        NSString *cut = [base stringByReplacingOccurrencesOfString:baseFirst withString:@"" options:NSLiteralSearch range:NSMakeRange(0, base.length)];
        return [cut substringWithRange:NSMakeRange(1, cut.length - 1)];
    }
    return nil;
}

+ (NSString *)getSkin:(NSString *)emojiString {
    for (NSString *skin in [self skinModifiers]) {
        if (containString(emojiString, skin))
            return skin;
    }
    return nil;
}

+ (BOOL)hasSkin:(NSString *)emojiString {
    return [self getSkin:emojiString] != nil;
}

+ (NSString *)changeEmojiSkin:(NSString *)emojiString toSkin:(NSString *)skin {
    NSString *oldSkin = [self getSkin:emojiString];
    if (oldSkin == nil || stringEqual(oldSkin, skin))
        return emojiString;
    return [emojiString stringByReplacingOccurrencesOfString:oldSkin withString:skin options:NSLiteralSearch range:NSMakeRange(0, emojiString.length)];
}

+ (NSString *)emojiGenderString:(NSString *)emojiString baseFirst:(NSString *)baseFirst skin:(NSString *)skin {
    BOOL needVariantSelector = [self genderEmojiBaseStringNeedVariantSelector:emojiString];
    NSString *_baseFirst = baseFirst ? baseFirst : [self emojiBaseFirstCharacterString:emojiString];
    NSString *variantSelector = needVariantSelector ? FE0F : @"";
    NSString *_skin = skin ? skin : @"";
    if (containString(emojiString, FEMALE))
        return [NSString stringWithFormat:@"%@%@%@%@", _baseFirst, _skin, ZWJ2640, variantSelector];
    else if (containString(emojiString, MALE))
        return [NSString stringWithFormat:@"%@%@%@%@", _baseFirst, _skin, ZWJ2642, variantSelector];
    return nil;
}

+ (NSString *)emojiBaseString:(NSString *)emojiString {
    if ([[self ProfessionEmoji] containsObject:emojiString])
        return emojiString;
    NSString *baseEmoji = [self professionSkinToneEmojiBaseKey:emojiString];
    if ([[self ProfessionEmoji] containsObject:baseEmoji])
        return baseEmoji;
    NSString *baseFirst = [self emojiBaseFirstCharacterString:emojiString];
    if ([self hasGender:emojiString])
        return [self emojiGenderString:emojiString baseFirst:baseFirst skin:nil];
    if (stringEqual(baseFirst, @"☝") || stringEqual(baseFirst, @"✊") || stringEqual(baseFirst, @"✋") || stringEqual(baseFirst, @"✌") || stringEqual(baseFirst, @"✍"))
        return [baseFirst stringByAppendingString:FE0F];
    return baseFirst;
}

+ (NSString *)skinToneVariant:(NSString *)emojiString baseFirst:(NSString *)baseFirst base:(NSString *)base skin:(NSString *)skin {
    NSString *_baseFirst = baseFirst ? baseFirst : [self emojiBaseFirstCharacterString:emojiString];
    NSString *_base = base ? base : [self emojiBaseString:emojiString];
    if ([[self GenderEmoji] containsObject:_baseFirst] && [self hasGender:emojiString])
        return [self emojiGenderString:emojiString baseFirst:_baseFirst skin:skin];
    else if ([[self ProfessionEmoji] containsObject:_base]) {
        NSRange baseRange = [emojiString rangeOfString:_baseFirst options:NSLiteralSearch];
        return [emojiString stringByReplacingCharactersInRange:baseRange withString:[NSString stringWithFormat:@"%@%@", _baseFirst, skin]];
    } else if ([[self DingbatVariantsEmoji] containsObject:baseFirst])
        return [NSString stringWithFormat:@"%@%@%@", baseFirst, skin, FE0F];
    return [NSString stringWithFormat:@"%@%@", _baseFirst, skin];
}

+ (NSString *)skinToneVariant:(NSString *)emojiString skin:(NSString *)skin {
    return [self skinToneVariant:emojiString baseFirst:nil base:nil skin:skin];
}

+ (NSMutableArray <NSString *> *)skinToneVariants:(NSString *)emojiString isSkin:(BOOL)isSkin {
    if (isSkin || [[self SkinToneEmoji] containsObject:emojiString]) {
        NSMutableArray <NSString *> *skins = [NSMutableArray arrayWithCapacity:5];
        NSString *baseFirst = [self emojiBaseFirstCharacterString:emojiString];
        NSString *base = [self emojiBaseString:emojiString];
        for (NSString *skin in [self skinModifiers])
            [skins addObject:[self skinToneVariant:emojiString baseFirst:baseFirst base:base skin:skin]];
        return skins;
    }
    return nil;
}

+ (NSMutableArray <NSString *> *)skinToneVariants:(NSString *)emojiString {
    return [[self SkinToneEmoji] containsObject:emojiString] ? [self skinToneVariants:emojiString isSkin:YES] : nil;
}

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString {
    NSUInteger variant = PSEmojiTypeRegular;
    if (![[self NoneVariantEmoji] containsObject:emojiString]) {
        if ([self emojiString:emojiString inGroup:[self DingbatVariantsEmoji]])
            variant |= PSEmojiTypeDingbat;
        if ([self emojiString:emojiString inGroup:[self SkinToneEmoji]])
            variant |= PSEmojiTypeSkin;
        if ([self emojiString:emojiString inGroup:[self GenderEmoji]]) {
            if (containString(emojiString, ZWJ2640) || containString(emojiString, ZWJ2642))
                variant |= PSEmojiTypeGender;
        }
        if ([[self ProfessionEmoji] containsObject:[self professionSkinToneEmojiBaseKey:emojiString]])
            variant |= PSEmojiTypeProfession;
    }
    return variant;
}

+ (BOOL)hasDingbat:(NSString *)emojiString {
    return emojiString.length && [[self DingbatVariantsEmoji] containsObject:emojiString];
}

+ (UIKeyboardEmoji *)emojiWithString:(NSString *)emojiString {
    UIKeyboardEmoji *emoji = nil;
    if ([NSClassFromString(@"UIKeyboardEmoji") respondsToSelector:@selector(emojiWithString:hasDingbat:)])
        emoji = [NSClassFromString(@"UIKeyboardEmoji") emojiWithString:emojiString hasDingbat:[self hasDingbat:emojiString]];
    else if ([NSClassFromString(@"UIKeyboardEmoji") respondsToSelector:@selector(emojiWithString:)])
        emoji = [NSClassFromString(@"UIKeyboardEmoji") emojiWithString:emojiString];
    else
        emoji = [[[NSClassFromString(@"UIKeyboardEmoji") alloc] initWithString:emojiString] autorelease];
    if ([emoji respondsToSelector:@selector(setSupportsSkin:)])
        emoji.supportsSkin = [self hasVariantsForEmoji:emojiString] & PSEmojiTypeSkin;
    return emoji;
}

+ (UIKeyboardEmoji *)emojiWithString:(NSString *)emojiString withVariantMask:(NSInteger)variantMask {
    return [NSClassFromString(@"UIKeyboardEmoji") emojiWithString:emojiString withVariantMask:variantMask];
}

+ (UIKeyboardEmoji *)emojiWithStringUniversal:(NSString *)emojiString {
    if ([NSClassFromString(@"UIKeyboardEmoji") respondsToSelector:@selector(emojiWithString:withVariantMask:)])
        return [self emojiWithString:emojiString withVariantMask:[self hasVariantsForEmoji:emojiString]];
    return [self emojiWithString:emojiString];
}

+ (void)addEmoji:(NSMutableArray <UIKeyboardEmoji *> *)emojiArray emojiString:(NSString *)emojiString withVariantMask:(NSInteger)variantMask {
    if (emojiString == nil)
        return;
    UIKeyboardEmoji *emoji = [self emojiWithString:emojiString withVariantMask:variantMask];
    if (emoji)
        [emojiArray addObject:emoji];
}

+ (void)addEmoji:(NSMutableArray <UIKeyboardEmoji *> *)emojiArray emojiString:(NSString *)emojiString {
    if (emojiString == nil)
        return;
    UIKeyboardEmoji *emoji = [self emojiWithString:emojiString];
    if (emoji)
        [emojiArray addObject:emoji];
}

+ (NSString *)overrideKBTreeEmoji:(NSString *)emojiString overrideNewVariant:(BOOL)overrideNewVariant {
    if (overrideNewVariant && emojiString && emojiString.length >= 4) {
        NSRange skinRange = NSMakeRange(NSNotFound, 0);
        NSString *base = [self emojiBaseString:emojiString];
        for (NSString *skin in [self skinModifiers]) {
            if ((skinRange = [emojiString rangeOfString:skin options:NSLiteralSearch]).location != NSNotFound)
                return [self skinToneVariant:base baseFirst:nil base:base skin:[emojiString substringWithRange:skinRange]];
        }
    }
    return emojiString;
}

+ (void)resetEmojiPreferences {
    id preferences;
    if (NSClassFromString(@"UIKeyboardEmojiPreferences"))
        preferences = [NSClassFromString(@"UIKeyboardEmojiPreferences") sharedInstance];
    else
        preferences = [NSClassFromString(@"UIKeyboardEmojiDefaultsController") sharedController];
    object_setInstanceVariable(preferences, "_defaults", (void *)[[(UIKeyboardEmojiDefaultsController *) preferences emptyDefaultsDictionary] retain]);
    object_setInstanceVariable(preferences, "_isDefaultDirty", (void *)YES);
    [(UIKeyboardEmojiDefaultsController *) preferences writeEmojiDefaults];
}

@end
