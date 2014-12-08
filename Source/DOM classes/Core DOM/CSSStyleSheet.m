#import "CSSStyleSheet.h"

#import "CSSRuleList+Mutable.h"

#import "CSSStyleRule.h"

@interface SVGMutableMultiDictionary ()
@property (nonatomic, retain) NSMutableDictionary* keyToArray;
@end

@implementation SVGMutableMultiDictionary

- (instancetype)init {
    self = [super init];
    if (self) {
        _keyToArray = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) dealloc {
    [_keyToArray release];
    [super dealloc];
}

-(void)addValue:(id)value forKey:(NSString *)key {
    NSMutableArray* values = [_keyToArray valueForKey:key];
    
    if (values == nil) {
        values = [[[NSMutableArray alloc] init] autorelease];
        [_keyToArray setObject:values forKey:key];
    }
    
    [values addObject:value];
}

-(NSArray *)valuesForKey:(NSString *)key {
    NSMutableArray* arrayFromLocalMap = [_keyToArray valueForKey:key];
    return [NSArray arrayWithArray:arrayFromLocalMap];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", _keyToArray];
}

@end



@implementation CSSStyleSheet

@synthesize ownerRule;
@synthesize cssRules;

@synthesize classToRulesCache, idToRulesCache, tagnameToRulesCache;

- (void)dealloc {
    self.ownerRule = nil;
    self.cssRules = nil;
    self.classToRulesCache = nil;
    self.idToRulesCache = nil;
    self.tagnameToRulesCache = nil;
    [super dealloc];
}

/**
 Used to insert a new rule into the style sheet. The new rule now becomes part of the cascade.

 Parameters
 
 rule of type DOMString
 The parsable text representing the rule. For rule sets this contains both the selector and the style declaration. For at-rules, this specifies both the at-identifier and the rule content.
 index of type unsigned long
 The index within the style sheet's rule list of the rule before which to insert the specified rule. If the specified index is equal to the length of the style sheet's rule collection, the rule will be added to the end of the style sheet.
 
 Return Value
 
 unsigned long The index within the style sheet's rule collection of the newly inserted rule.
 */
-(long)insertRule:(NSString *)rule index:(unsigned long)index
{
	if( index == self.cssRules.length )
		index = self.cssRules.length + 1; // forces it to insert "before the one that doesn't exist" (stupid API design!)
	
	NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	rule = [rule stringByTrimmingCharactersInSet:whitespaceSet];
	
	//             DDLogVerbose(@"A substringie %@", idStyleString);
	
	NSArray* stringSplitContainer = [rule componentsSeparatedByString:@"{"];
	if( [stringSplitContainer count] >= 2 ) //not necessary unless using shitty svgs
	{
		CSSStyleRule* newRule = [[[CSSStyleRule alloc] initWithSelectorText:[stringSplitContainer objectAtIndex:0] styleText:[stringSplitContainer objectAtIndex:1]] autorelease];
        
        [self addRuleToCaches:newRule];
        
		[self.cssRules.internalArray insertObject:newRule atIndex:index-1]; // CSS says you insert "BEFORE" the index, which is the opposite of most C-based programming languages
		
		return index-1;
	}
	else
		NSAssert(FALSE, @"No idea what to do here");
	
	
	return -1; // failed, assert fired!
}

-(void) addRuleToCaches:(CSSStyleRule*) rule {
    for (NSString* selectorClassName in  rule.selectorClasses) {
        [self.classToRulesCache addValue:rule forKey:selectorClassName];
    }
    
    for (NSString* selectorIdentifier in rule.selectorIds) {
        [self.classToRulesCache addValue:rule forKey:selectorIdentifier];
    }
    
    for (NSString* selectorTagName in rule.selectorTagnames) {
        [self.classToRulesCache addValue:rule forKey:selectorTagName];
    }
}

-(void)deleteRule:(unsigned long)index
{
	[self.cssRules.internalArray removeObjectAtIndex:index];
}

#pragma mark - methods needed for ObjectiveC implementation

- (id)initWithString:(NSString*) styleSheetBody
{
    self = [super init];
    if (self)
	{
		self.cssRules = [[[CSSRuleList alloc]init] autorelease];
        
        self.classToRulesCache = [[[SVGMutableMultiDictionary alloc] init]autorelease];
        self.idToRulesCache = [[[SVGMutableMultiDictionary alloc] init]autorelease];
        self.tagnameToRulesCache = [[[SVGMutableMultiDictionary alloc] init]autorelease];
        
		@autoreleasepool { //creating lots of autoreleased strings, not helpful for older devices
			
			/**
			 We have to manually handle the "ignore anything that is between / *  and * / because those are comments"
			 
			 NB: you NEED the NSRegularExpressionDotMatchesLineSeparators argument - which Apple DOES NOT HONOUR in NSString - hence have to use NSRegularExpression
			 */
			NSError* error;
			NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:@"/\\*.*\\*/" options: NSRegularExpressionDotMatchesLineSeparators error:&error];
			styleSheetBody = [regexp stringByReplacingMatchesInString:styleSheetBody options:0 range:NSMakeRange(0,styleSheetBody.length) withTemplate:@""];
			
			NSArray *classNameAndStyleStrings = [styleSheetBody componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"}"]];
			for( NSString *idStyleString in classNameAndStyleStrings )
			{
				if( [idStyleString length] > 1 ) //not necessary unless using shitty svgs
				{
					[self insertRule:idStyleString index:self.cssRules.length];
				}
				
			}
		}
	
    }
    return self;
}

@end
