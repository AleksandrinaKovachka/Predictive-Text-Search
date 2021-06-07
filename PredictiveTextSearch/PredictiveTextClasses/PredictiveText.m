//
//  PredictiveText.m
//  PredictiveTextSearch
//
//  Created by A-Team Intern on 7.06.21.
//

#import "PredictiveText.h"

@interface PredictiveText ()

@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* dictionary;
@property (strong, nonatomic) NSDictionary<NSNumber*, NSArray<NSString*>*>* enWordsSet;
@property (strong, nonatomic) NSDictionary<NSNumber*, NSArray<NSString*>*>* bgWordsSet;
@property (strong, nonatomic) NSMutableArray<NSString*>* combinations;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*>* predictiveDictionary;

//@property (assign) int count;
//@property (strong, nonatomic) NSArray<NSString*>* words;

@end

@implementation PredictiveText

-(instancetype)initWithDictionary:(NSDictionary<NSString*, NSString*>*)dictionary
{
    if ([super init])
    {
        NSLog(@"test");
        self.dictionary = dictionary;
        
        self.enWordsSet = @{@2: @[@"A", @"B", @"C"], @3: @[@"D", @"E", @"F"], @4: @[@"G", @"H", @"I"], @5: @[@"J", @"K", @"L"],
                            @6: @[@"M", @"N", @"O"], @7: @[@"P", @"Q", @"R", @"S"], @8: @[@"T", @"U", @"V"], @9: @[@"W", @"X", @"Y", @"Z"]};
        
        self.bgWordsSet = @{@3: @[@"А", @"Б", @"В", @"Г"], @4: @[@"Д", @"Е", @"Ж", @"З"], @5: @[@"М", @"Н", @"О", @"П"],
                            @6: @[@"Р", @"С", @"Т", @"У"], @7: @[@"Ф", @"Х", @"Ц", @"Ч"], @8: @[@"Ш", @"Щ", @"Ъ"],
                            @9: @[@"ьо", @"Ю", @"Я"]};
        
        self.combinations = [[NSMutableArray alloc] init];
        
//        self.count = 0;
//        self.words = [[NSArray alloc] init];
        
        [self loadPredictDictionary];
    }
    
    return self;
}

-(void)loadPredictDictionary
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePredictDictionary = [documentsDirectory stringByAppendingPathComponent:@"predict_dictionary_en.txt"];
    
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

/*-(NSArray<NSString*>*)predictWordsStartedWith:(NSString*)stringInput
{
    if (stringInput.length == 1)
    {
        self.count = 0;
    }
    
    //get last number - make combination - filter
    int number = [stringInput intValue] % 10; //get last number
    //self.combinations = [self makeNewCombinationsWithNumber:@(number)];
    
    //search words with this combinations
    [self wordsWithCombinations:@(number)];
    
    //search in predictiveDictionary
    if ([self.predictiveDictionary count] != 0)
    {
        return [self changeOrderOfWords];
    }
    
    return self.words;
}

-(void)wordsWithCombinations:(NSNumber*)number
{
    NSArray<NSString*>* lettersOnNumber = [self.enWordsSet objectForKey:number]; //TODO: current language
    
    if (self.count == 0)
    {
        NSArray<NSString*>* nextLetters = [self.enWordsSet objectForKey:[NSNumber numberWithInt:number.intValue + 1]];
        [self allWordsWithLetters:lettersOnNumber andNextLetter:nextLetters.firstObject];
        self.count += 1;
    }
    
    NSMutableArray<NSString*>* newWords = [[NSMutableArray alloc] init];
    
    for (NSString* word in self.words)
    {
        if ([lettersOnNumber containsObject:[word substringWithRange:NSMakeRange(self.count, 1)]])
        {
            [newWords addObject:word];
        }
    }
    
    self.count += 1;
    
    self.words = newWords;
}

-(void)allWordsWithLetters:(NSArray<NSString*>*)letters andNextLetter:(NSString*)nextLetter
{
    NSArray<NSString*>* sortedWords = [[self.dictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSUInteger len = [sortedWords indexOfObject:nextLetter] - [sortedWords indexOfObject:letters.firstObject];
    self.words = [sortedWords subarrayWithRange:NSMakeRange([sortedWords indexOfObject:letters.firstObject], len)];
}

-(NSArray<NSString*>*)changeOrderOfWords
{
    NSMutableArray<NSString*>* wordsCopy = [[NSMutableArray alloc] initWithArray:self.words];
    NSMutableArray<NSString*>* words = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber*>* wordsOrderNumber = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < wordsCopy.count; ++i)
    {
        if ([self.predictiveDictionary objectForKey:wordsCopy[i]])
        {
            [words addObject:wordsCopy[i]];
            [wordsCopy removeObject:wordsCopy[i]];
            [wordsOrderNumber addObject: [self.predictiveDictionary objectForKey:wordsCopy[i]]];
        }
    }
    
    if (wordsOrderNumber.count != 0)
    {
        for (int i = 0; i < wordsOrderNumber.count - 1; ++i)
        {
            for (int j = 0; j < wordsOrderNumber.count - i - 1; ++j)
            {
                if (wordsOrderNumber[j] < wordsOrderNumber[j + 1])
                {
                    [words exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    [wordsOrderNumber exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                }
            }
        }
    }
    NSMutableArray<NSString*>* commonWords = [[NSMutableArray alloc] init];
    [commonWords addObjectsFromArray:words];
    [commonWords addObjectsFromArray:wordsCopy];
    
    return commonWords;
}*/


//if count = 0 - get all words with letter of number - if count is not
-(NSArray<NSString*>*)predictWordsStartedWith:(NSString*)stringInput
{
    //get last number - make combination - filter
    int number = [stringInput intValue] % 10; //get last number
    self.combinations = [self makeNewCombinationsWithNumber:@(number)];
    
    //search words with this combinations
    NSMutableArray<NSString*>* wordsFromCombinations = [self searchWordInDictionaryWithCombinations];
    
    //search in predictiveDictionary
    if ([self.predictiveDictionary count] != 0)
    {
        wordsFromCombinations = [self changeOrderOfWords:wordsFromCombinations];
    }
    
    return wordsFromCombinations;
}

-(NSMutableArray<NSString*>*)changeOrderOfWords:(NSMutableArray<NSString*>*)wordsFromCombinations
{
    NSMutableArray<NSString*>* words = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber*>* wordsOrderNumber = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < wordsFromCombinations.count; ++i)
    {
        if ([self.predictiveDictionary objectForKey:wordsFromCombinations[i]])
        {
            [words addObject:wordsFromCombinations[i]];
            [wordsFromCombinations removeObject:wordsFromCombinations[i]];
            [wordsOrderNumber addObject: [self.predictiveDictionary objectForKey:wordsFromCombinations[i]]];
        }
    }
    
    if (wordsOrderNumber.count != 0)
    {
        for (int i = 0; i < wordsOrderNumber.count - 1; ++i)
        {
            for (int j = 0; j < wordsOrderNumber.count - i - 1; ++j)
            {
                if (wordsOrderNumber[j] < wordsOrderNumber[j + 1])
                {
                    [words exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    [wordsOrderNumber exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                }
            }
        }
    }
    NSMutableArray<NSString*>* commonWords = [[NSMutableArray alloc] init];
    [commonWords addObjectsFromArray:words];
    [commonWords addObjectsFromArray:wordsFromCombinations];
    
    return commonWords;
}

-(NSMutableArray<NSString*>*)searchWordInDictionaryWithCombinations
{
    NSMutableArray<NSString*>* wordsFromCombinations = [[NSMutableArray alloc] init];
    
    for (NSString* key in self.dictionary)
    {
        if ([self.combinations containsObject:key])
        {
            [wordsFromCombinations addObject:key];
        }
    }
    
    return wordsFromCombinations;
}

-(NSMutableArray<NSString*>*)makeNewCombinationsWithNumber:(NSNumber*)number
{
    NSArray<NSString*>* lettersOnNumber = [self.enWordsSet objectForKey:number]; //TODO: current language
    NSMutableArray<NSString*>* newCombinations = [[NSMutableArray alloc] init];
    
    if (self.combinations.count == 0)
    {
        return [NSMutableArray arrayWithArray:lettersOnNumber];
    }
    
    for (int i = 0; i < self.combinations.count; ++i)
    {
        for (int j = 0; j < lettersOnNumber.count; ++j)
        {
            NSString* combination = [self.combinations[i] stringByAppendingString:lettersOnNumber[j]];
            [newCombinations addObject:combination];
        }
    }
    
    return newCombinations;
}

-(NSString*)descriptionOfWord:(NSString*)word
{
    if ([self.predictiveDictionary objectForKey:word] != nil)
    {
        NSNumber* numberOfRepeatability = [self.predictiveDictionary objectForKey:word];
        [self.predictiveDictionary removeObjectForKey:word];
        [self.predictiveDictionary setValue:numberOfRepeatability forKey:word];

    } else
    {
        [self.predictiveDictionary setValue:[NSNumber numberWithInt:1] forKey:word];
    }
    
    return self.dictionary[word];
}

@end
