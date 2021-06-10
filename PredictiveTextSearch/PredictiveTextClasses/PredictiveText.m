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
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*>* predictiveDictionary;

@end

@implementation PredictiveText

-(instancetype)initWithDictionary:(NSDictionary<NSString*, NSString*>*)dictionary andLanguage:(NSString*)language
{
    if ([super init])
    {
        NSLog(@"test");
        self.language = language;
        self.dictionary = dictionary;
        
        self.enWordsSet = @{@2: @[@"A", @"B", @"C"], @3: @[@"D", @"E", @"F"], @4: @[@"G", @"H", @"I"], @5: @[@"J", @"K", @"L"],
                            @6: @[@"M", @"N", @"O"], @7: @[@"P", @"Q", @"R", @"S"], @8: @[@"T", @"U", @"V"], @9: @[@"W", @"X", @"Y", @"Z"]};
        
        self.bgWordsSet = @{@3: @[@"А", @"Б", @"В", @"Г"], @4: @[@"Д", @"Е", @"Ж", @"З"], @5: @[@"М", @"Н", @"О", @"П"],
                            @6: @[@"Р", @"С", @"Т", @"У"], @7: @[@"Ф", @"Х", @"Ц", @"Ч"], @8: @[@"Ш", @"Щ", @"Ъ"],
                            @9: @[@"ьо", @"Ю", @"Я"]};
        
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
        NSLog(@"no file with predictive words");
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

-(NSArray<NSString*>*)predictWordsStartedWith:(NSString*)stringInput
{
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
    //if words is empty check for near words
    
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
}

@end
