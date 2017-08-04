#import <Foundation/Foundation.h>
#import <unicode/umachine.h>

@interface NSString (TIExtras)
+ (NSString *)_stringWithUnichar:(UChar32)aChar;
+ (NSString *)stringWithUnichar:(UChar32)aChar;
- (UChar32)_firstLongCharacter;
- (BOOL)_containsEmoji;
@end

#define containString(str, substr) ([str rangeOfString:substr options:NSLiteralSearch].location != NSNotFound)
