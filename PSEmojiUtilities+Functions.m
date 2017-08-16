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
    return section <= PSEmojiCategoryPeople || ((isiOS91Up && (section == PSEmojiCategoryActivity || section == PSEmojiCategoryObjects)) || (!isiOS91Up && (section == IDXPSEmojiCategoryActivity || section == IDXPSEmojiCategoryObjects)));
}

+ (BOOL)genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiString {
    if (stringEqual(emojiString, @"🏋") || stringEqual(emojiString, @"⛹") || stringEqual(emojiString, @"🕵") || stringEqual(emojiString, @"🏌"))
        return YES;
    return NO;
}

+ (BOOL)emojiString:(NSString *)emojiString inGroup:(NSArray <NSString *> *)group {
    if (group.count) {
        NSUInteger index = [group indexOfObject:emojiString inSortedRange:NSMakeRange(0, group.count) options:NSBinarySearchingFirstEqual usingComparator:^(id str1, id str2) {
            UChar32 f1 = [self firstLongCharacter:(NSString *)str1];
            UChar32 f2 = [self firstLongCharacter:(NSString *)str2];
            if (f1 == f2)
                return (NSComparisonResult)NSOrderedSame;
            return f1 > f2 ? (NSComparisonResult)NSOrderedDescending : (NSComparisonResult)NSOrderedAscending;
        }];
        return index != NSNotFound;
    }
    return NO;
}

+ (NSString *)emojiBaseFirstCharacterString:(NSString *)emojiString {
    return [NSString stringWithUnichar:[self firstLongCharacter:emojiString]];
}

+ (NSString *)getGender:(NSString *)emojiString {
    if (containsString(emojiString, FEMALE))
        return FEMALE;
    if (containsString(emojiString, MALE))
        return MALE;
    return nil;
}

+ (BOOL)hasGender:(NSString *)emojiString {
    return [self getGender:emojiString] != nil;
}

+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emojiString {
    for (NSString *skin in [self skinModifiers]) {
        if (containsString(emojiString, skin))
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
        if (containsString(emojiString, skin))
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
    NSString *_baseFirst = baseFirst ? baseFirst : [self emojiBaseFirstCharacterString:emojiString];
    BOOL needVariantSelector = [self genderEmojiBaseStringNeedVariantSelector:_baseFirst];
    NSString *_skin = skin ? skin : @"";
    NSString *variantSelector = _skin.length == 0 && needVariantSelector ? FE0F : @"";
    if (containsString(emojiString, FEMALE))
        return [NSString stringWithFormat:@"%@%@%@%@", _baseFirst, variantSelector, _skin, ZWJ2640FE0F];
    else if (containsString(emojiString, MALE))
        return [NSString stringWithFormat:@"%@%@%@%@", _baseFirst, variantSelector, _skin, ZWJ2642FE0F];
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
        return baseRange.location != NSNotFound ? [emojiString stringByReplacingCharactersInRange:baseRange withString:[NSString stringWithFormat:@"%@%@", _baseFirst, skin]] : nil;
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
            if (containsString(emojiString, ZWJ2640) || containsString(emojiString, ZWJ2642))
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
        NSString *skin = [self getSkin:emojiString];
        if (skin) {
            NSString *emojiWithoutSkin = [self changeEmojiSkin:emojiString toSkin:@""];
            NSString *result = [self skinToneVariant:emojiWithoutSkin skin:skin];
            HBLogDebug(@"Removing %@ from the invalid %@ -> %@ to get %@", skin, emojiString, emojiWithoutSkin, result);
            return result;
        }
    }
    return emojiString;
}

+ (UIKeyboardEmojiCategory *)prepopulatedCategory {
    static UIKeyboardEmojiCategory *category = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        category = [[NSClassFromString(@"UIKeyboardEmojiCategory") alloc] init];
        category.categoryType = PSEmojiCategoryPrepopulated;
        NSArray <NSString *> *prepopulated = [self PrepopulatedEmoji];
        NSMutableArray <UIKeyboardEmoji *> *emojis = [NSMutableArray arrayWithCapacity:prepopulated.count];
        for (NSString *emojiString in prepopulated)
            [self addEmoji:emojis emojiString:emojiString withVariantMask:[self hasVariantsForEmoji:emojiString]];
        category.emoji = emojis;
    });
    return category;
}

+ (UIKeyboardEmojiCollectionViewCell *)collectionView:(UICollectionView *)collectionView_ cellForItemAtIndexPath:(NSIndexPath *)indexPath inputView:(UIKeyboardEmojiCollectionInputView *)inputView {
    UIKeyboardEmojiCollectionView *collectionView = (UIKeyboardEmojiCollectionView *)[inputView valueForKey:@"_collectionView"];
    UIKeyboardEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kEmojiCellIdentifier" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSArray <UIKeyboardEmoji *> *recents = collectionView.inputController.recents;
        NSArray <UIKeyboardEmoji *> *prepolulatedEmojis = [self prepopulatedCategory].emoji;
        NSUInteger prepolulatedCount = [(UIKeyboardEmojiGraphicsTraits *)[inputView valueForKey:@"_emojiGraphicsTraits"] prepolulatedRecentCount];
        NSRange range = NSMakeRange(0, prepolulatedCount);
        if (recents.count) {
            NSUInteger idx = 0;
            NSMutableArray <UIKeyboardEmoji *> *array = [NSMutableArray arrayWithArray:recents];
            if (array.count < prepolulatedCount) {
                while (idx < prepolulatedEmojis.count && prepolulatedCount != array.count) {
                    UIKeyboardEmoji *emoji = prepolulatedEmojis[idx++];
                    if (![array containsObject:emoji])
                        [array addObject:emoji];
                }
            }
            cell.emoji = [array subarrayWithRange:range][indexPath.item];
        } else
            cell.emoji = [prepolulatedEmojis subarrayWithRange:range][indexPath.item];
    } else {
        NSInteger section = indexPath.section;
        if (isiOS91Up)
            section = [NSClassFromString(@"UIKeyboardEmojiCategory") categoryTypeForCategoryIndex:section];
        UIKeyboardEmojiCategory *category = [NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:section];
        NSArray <UIKeyboardEmoji *> *emojis = category.emoji;
        cell.emoji = emojis[indexPath.item];
        if ((cell.emoji.variantMask & PSEmojiTypeSkin) && [PSEmojiUtilities sectionHasSkin:section]) {
            NSMutableDictionary <NSString *, NSString *> *skinPrefs = [collectionView.inputController skinToneBaseKeyPreferences];
            if (skinPrefs) {
                NSString *skinned = skinPrefs[[PSEmojiUtilities emojiBaseString:cell.emoji.emojiString]];
                if (skinned) {
                    cell.emoji.emojiString = skinned;
                    cell.emoji = cell.emoji;
                }
            }
        }
    }
    cell.emojiFontSize = [collectionView emojiGraphicsTraits].emojiKeyWidth;
    return cell;
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
