/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/css.html#CSS-CSSStyleSheet
 
 interface CSSStyleSheet : stylesheets::StyleSheet {
 readonly attribute CSSRule          ownerRule;
 readonly attribute CSSRuleList      cssRules;
 unsigned long      insertRule(in DOMString rule,
 in unsigned long index)
 raises(DOMException);
 void               deleteRule(in unsigned long index)
 raises(DOMException);
 */
#import <Foundation/Foundation.h>

#import "CSSRule.h"
#import "CSSRuleList.h"


@interface SVGMutableMultiDictionary : NSObject

- (void) addValue:(id)value forKey:(NSString*) key;

- (NSArray*) valuesForKey:(NSString*) key;

@end


@interface CSSStyleSheet : NSObject


@property(nonatomic,retain) CSSRule* ownerRule;
@property(nonatomic,retain) CSSRuleList* cssRules;


@property(nonatomic,retain) SVGMutableMultiDictionary* classToRulesCache;
@property(nonatomic,retain) SVGMutableMultiDictionary* idToRulesCache;
@property(nonatomic,retain) SVGMutableMultiDictionary* tagnameToRulesCache;


-(long) insertRule:(NSString*) rule index:(unsigned long) index;
-(void) deleteRule:(unsigned long) index;

#pragma mark - methods needed for ObjectiveC implementation

- (id)initWithString:(NSString*) styleSheetBody;

@end
