//
//  PredictiveText.m
//  PredictiveTextSearch
//
//  Created by A-Team Intern on 7.06.21.
//

#import "PredictiveText.h"

@interface PredictiveText ()

@property (strong, nonatomic) NSString* language;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* dictionary;
@property (strong, nonatomic) NSDictionary<NSNumber*, NSArray<NSString*>*>* enWordsSet;
@property (strong, nonatomic) NSDictionary<NSNumber*, NSArray<NSString*>*>* bgWordsSet;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* lettersNumber;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*>* predictiveDictionary;

@end

@implementation PredictiveText

-(instancetype)initWithDictionary:(NSDictionary<NSString*, NSString*>*)dictionary andLanguage:(NSString*)language
{
    if ([super init])
    {
        self.language = language;
        self.dictionary = dictionary;
        
        self.enWordsSet = @{@2: @[@"A", @"B", @"C"], @3: @[@"D", @"E", @"F"], @4: @[@"G", @"H", @"I"], @5: @[@"J", @"K", @"L"],
                            @6: @[@"M", @"N", @"O"], @7: @[@"P", @"Q", @"R", @"S"], @8: @[@"T", @"U", @"V"], @9: @[@"W", @"X", @"Y", @"Z"]};
        
        self.bgWordsSet = @{@2: @[@"А", @"Б", @"В", @"Г"], @3: @[@"Д", @"Е", @"Ж", @"З"], @4: @[@"И", @"Й", @"К", @"Л"],
                            @5: @[@"М", @"Н", @"О", @"П"], @6: @[@"Р", @"С", @"Т", @"У"], @7: @[@"Ф", @"Х", @"Ц", @"Ч"],
                            @8: @[@"Ш", @"Щ", @"Ъ"], @9: @[@"ьо", @"Ю", @"Я"]};
        
        self.lettersNumber = @{@"A": @"2", @"B": @"2", @"C": @"2", @"D": @"3", @"E": @"3", @"F": @"3", @"G": @"4", @"H": @"4",
                               @"I": @"4", @"J": @"5", @"K": @"5", @"L": @"5", @"M": @"6", @"N": @"6", @"O": @"6", @"P": @"7",
                               @"Q": @"7", @"R": @"7", @"S": @"7", @"T": @"8", @"U": @"8", @"V": @"8", @"W": @"9", @"X": @"9",
                               @"Y": @"9", @"Z": @"9", @"А": @"2", @"Б": @"2", @"Ц": @"7", @"Д": @"3", @"Е": @"3", @"Ф": @"7",
                               @"Г": @"2", @"Х": @"7", @"И": @"4", @"Й": @"4", @"К": @"4", @"Л": @"4", @"М": @"5", @"Н": @"5",
                               @"О": @"5", @"П": @"5", @"Я": @"9", @"Р": @"6", @"С": @"6", @"Т": @"6", @"У": @"6", @"Ж": @"3",
                               @"В": @"2", @"З": @"3"};
        
        [self loadPredictDictionary];
    }
    
    return self;
}

-(void)loadPredictDictionary
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePredictDictionary = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"predict_dictionary_%@.txt", self.language]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //check if have that file
    if ([fileManager fileExistsAtPath:filePredictDictionary])
    {
        self.predictiveDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePredictDictionary];
    }
    else
    {
        self.predictiveDictionary = [[NSMutableDictionary alloc] init];
    }
}

-(void)savePredictDictionary
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fileWordsName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"predict_dictionary_%@.txt", self.language]];
    
    [self.predictiveDictionary writeToFile:fileWordsName atomically:YES];
}

-(NSDictionary<NSNumber*, NSArray<NSString*>*>*)activeSet
{
    if ([self.language isEqualToString:@"en"])
    {
        return self.enWordsSet;
    }
    
    return self.bgWordsSet;
}

-(NSString*)numbersWithLetters:(NSString*)stringInput
{
    NSMutableString* numberInput = [[NSMutableString alloc] init];
    
    for (int i = 0; i < stringInput.length; ++i)
    {
        NSString* letter = [stringInput substringWithRange:NSMakeRange(i, 1)];
        
        if ([self.lettersNumber objectForKey:letter])
        {
            [numberInput appendString:[self.lettersNumber objectForKey:letter]];
        }
        else
        {
            [numberInput appendString:letter];
        }
    }
    
    return numberInput;
}

-(NSArray<NSString*>*)predictWordsStartedWith:(NSString*)stringInput
{
    stringInput = [self numbersWithLetters:stringInput];
    
    NSMutableArray<NSString*>* words = [NSMutableArray arrayWithArray:[self.dictionary allKeys]];
    
    for (int i = 0; i < stringInput.length; ++i)
    {
        NSNumber* number = [NSNumber numberWithInt:[[stringInput substringWithRange:NSMakeRange(i, 1)] intValue]];
        NSArray<NSString*>* letters = [self.activeSet objectForKey: number];
        
        NSPredicate* filterWords = [NSPredicate predicateWithBlock:^BOOL(NSString* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (evaluatedObject.length - 1 < i)
            {
                return NO;
            }
            NSString* character = [NSString stringWithFormat:@"%c", [evaluatedObject characterAtIndex:i]];
            
            if ([letters containsObject:character] && stringInput.length == evaluatedObject.length)
            {
                return YES;
            }
            
            return NO;
        }];
        
        [words filterUsingPredicate:filterWords];
    }
    
    if ([self.predictiveDictionary count] != 0)
    {
        return [self changeOrderOfWords:words];
    }
    
    return words;
}

-(NSArray<NSString*>*)changeOrderOfWords:(NSMutableArray<NSString*>*)words
{
    NSMutableArray<NSString*>* wordsPredict = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber*>* wordsPredictOrderNumber = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < words.count; ++i)
    {
        if ([self.predictiveDictionary objectForKey:words[i]] != nil)
        {
            [wordsPredict addObject:words[i]];
            [wordsPredictOrderNumber addObject: [self.predictiveDictionary objectForKey:words[i]]];
            [words removeObject:words[i]];
        }
    }
    
    if (wordsPredictOrderNumber.count != 0)
    {
        for (int i = 0; i < wordsPredictOrderNumber.count - 1; ++i)
        {
            for (int j = 0; j < wordsPredictOrderNumber.count - i - 1; ++j)
            {
                if (wordsPredictOrderNumber[j] < wordsPredictOrderNumber[j + 1])
                {
                    [wordsPredict exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    [wordsPredictOrderNumber exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                }
            }
        }
    }
    NSMutableArray<NSString*>* commonWords = [[NSMutableArray alloc] init];
    [commonWords addObjectsFromArray:wordsPredict];
    [commonWords addObjectsFromArray:words];
    
    return commonWords;
}

-(void)chooseWord:(NSString*)word;
{
    if ([self.predictiveDictionary objectForKey:word] != nil)
    {
        int numberOfRepeatability = [self.predictiveDictionary objectForKey:word].intValue + 1;
        [self.predictiveDictionary removeObjectForKey:word];
        [self.predictiveDictionary setValue:[NSNumber numberWithInt:numberOfRepeatability] forKey:word];
    }
    else
    {
        [self.predictiveDictionary setValue:[NSNumber numberWithInt:1] forKey:word];
    }
    
    [self savePredictDictionary];
}

-(NSString*)getSymbolWith:(NSString*)lastPresented
{
    if ([self.lettersNumber objectForKey:lastPresented]) //if is letter
    {
        NSNumber* number = [NSNumber numberWithInt:[[self.lettersNumber objectForKey:lastPresented] intValue]];
        NSArray<NSString*>* letters = [[self activeSet] objectForKey:number];
        
        NSUInteger index = [letters indexOfObject:lastPresented];
        
        if (letters.count - 1 == index)
        {
            return letters[0];
        }
        else
        {
            return letters[index + 1];
        }
    }
    NSArray<NSString*>* letters = [[self activeSet] objectForKey:[NSNumber numberWithInt:[lastPresented intValue]]];
    return letters[0];
}

@end
