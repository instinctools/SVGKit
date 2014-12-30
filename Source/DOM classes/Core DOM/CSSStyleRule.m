
#import "CSSStyleRule.h"

@implementation CSSStyleRule{
    NSMutableArray* selectorClasses;
    NSMutableArray* selectorIds;
    NSMutableArray* selectorTagnames;
}

@synthesize selectorText;
@synthesize style;

- (void)dealloc {
    self.style = nil;
    self.selectorText = nil;
    [super dealloc];
}

- (id)init
{
	NSAssert(FALSE, @"Can't be init'd, use the right method, idiot");
	return nil;
}

#pragma mark - methods needed for ObjectiveC implementation

- (id)initWithSelectorText:(NSString*) selector styleText:(NSString*) styleText;
{
    self = [super init];
    if (self) {
        self.selectorText = selector;
        
        selectorTagnames = [[NSMutableArray alloc] init];
        selectorIds = [[NSMutableArray alloc] init];
        selectorClasses = [[NSMutableArray alloc] init];
        
        [self initSelectorsProperties];
        
		CSSStyleDeclaration* styleDeclaration = [[[CSSStyleDeclaration alloc] init] autorelease];
		styleDeclaration.cssText = styleText;
		
		self.style = styleDeclaration;
    }
    return self;
}

-(void) initSelectorsProperties {
    NSRange nextRule = [self nextSelectorRangeFromText:selectorText startFrom:NSMakeRange(0, 0)];
    
    if (nextRule.location == NSNotFound) {
        return;
    }
    
    while (nextRule.location != NSNotFound) {
        NSString* subSelectorRule = [selectorText substringWithRange:nextRule];
        
        if ([subSelectorRule characterAtIndex:0] == '.') {
            NSString* selectorClassName = [subSelectorRule substringFromIndex:1];
            [selectorClasses addObject:selectorClassName];
        } else if([subSelectorRule characterAtIndex:0] == '#') {
            NSString* selectorIdentifier = [subSelectorRule substringFromIndex:1];
            [selectorIds addObject:selectorIdentifier];
        } else {
            NSString* selectorTagName = subSelectorRule;
            [selectorTagnames addObject:selectorTagName];
        }
        
        nextRule = [self nextSelectorRangeFromText:selectorText startFrom:nextRule];
    }
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"%@ : { %@ }", self.selectorText, self.style ];
}

-(NSArray*) selectorClasses {
    return [NSArray arrayWithArray: selectorClasses];
}

-(NSArray*) selectorIds {
    return [NSArray arrayWithArray: selectorIds];
}

-(NSArray*) selectorTagnames {
    return [NSArray arrayWithArray: selectorTagnames];
}


- (NSRange) nextSelectorRangeFromText:(NSString *) localSelectorText startFrom:(NSRange) previous
{
    NSMutableCharacterSet *selectorCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_-"];
    [selectorCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    
    NSCharacterSet *selectorStart = [NSCharacterSet characterSetWithCharactersInString:@"#."];
    
    NSInteger start = -1;
    NSUInteger end = 0;
    for( NSUInteger i = previous.location + previous.length; i < localSelectorText.length; i++ )
    {
        unichar c = [localSelectorText characterAtIndex:i];
        if( [selectorStart characterIsMember:c] )
        {
            if (start != -1) {
                break;
            }
            start = i;
        }
        else if( [selectorCharacterSet characterIsMember:c] )
        {
            if( start == -1 )
                start = i;
            end = i;
        }
        else if( start != -1 )
        {
            break;
        }
    }
    
    if( start != -1 )
        return NSMakeRange(start, end + 1 - start);
    else
        return NSMakeRange(NSNotFound, -1);
}

- (NSComparisonResult)compare:(CSSStyleRule*)otherObject {
    NSArray* left = [self specificity];
    NSArray* right = [otherObject specificity];
    
    if (left == nil) {
        if (right == nil) {
            return NSOrderedSame;
        }
        return NSOrderedAscending;
    }
    
    if (left.count != 4 || right.count != 4) {
        return NSOrderedAscending;
    }
    
    for (NSUInteger i = 0; i < 4; ++i) {
        NSNumber* leftComponent = [left objectAtIndex:i];
        NSNumber* rightComponent = [right objectAtIndex:i];
        
        NSComparisonResult localResult = [leftComponent compare:rightComponent];
        
        if (localResult != NSOrderedSame) {
            return localResult;
        }
    }
    
    
    return NSOrderedSame;
}

- (NSArray*) specificity {
    NSNumber* a = [NSNumber numberWithInt:0]; // from node (element) property (not counted here)
    
    NSNumber* b = [NSNumber numberWithInt:0];
    NSNumber* c = [NSNumber numberWithInt:0];
    NSNumber* d = [NSNumber numberWithInt:0];
    
    NSRange nextRule = [self nextSelectorRangeFromText:selectorText startFrom:NSMakeRange(0, 0)];
    
    while (nextRule.location != NSNotFound) {
        NSString* subRule = [selectorText substringWithRange:nextRule];
        
        if([subRule characterAtIndex:0] == '.') {
            c = @(c.intValue + 1);
        } else if ([subRule characterAtIndex:0] == '#') {
            b = @(b.intValue + 1);
        } else {
            d = @(d.intValue + 1);
        }
        
        nextRule = [self nextSelectorRangeFromText:selectorText startFrom:nextRule];
    }
    
    return [NSArray arrayWithObjects:a, b, c, d, nil];
}

@end
