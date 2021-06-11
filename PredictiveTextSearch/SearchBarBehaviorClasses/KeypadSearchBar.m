//
//  SearchBarBehavior.m
//  PredictiveTextSearch
//
//  Created by A-Team Intern on 9.06.21.
//

#import "KeypadSearchBar.h"
#import "PredictiveText.h"

@interface KeypadSearchBar ()

@property (strong, nonatomic) PredictiveText* predictiveText;
@property (assign) BOOL isPredictive;
@property (assign) BOOL isMultiTap;
@property (assign) BOOL isTimerOn;
@property (strong, nonatomic) NSString* lastNumber;
@property (nonatomic) NSTimeInterval time;

@end

@implementation KeypadSearchBar

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
}

-(void)initializePredictiveTextWithDictionary:(NSDictionary<NSString*, NSString*>*)dictionary andLanguage:(NSString*)language
{
    self.predictiveText = [[PredictiveText alloc] initWithDictionary:dictionary andLanguage:language];
    self.isPredictive = NO;
    self.isMultiTap = NO;
    self.isTimerOn = NO;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.isPredictive)
    {
        NSArray<NSString*>* words = [self.predictiveText predictWordsStartedWith:searchText];

        self.text = words.firstObject;

        [self.suggestedWordsDelegate didSuggestedWordsChangeTo:words];
    }
    else if (self.isMultiTap)
    {
        if (searchText.length > 0)
        {
            [self symbolWith:searchText];
            [self.suggestedWordsDelegate didNumbersChangeTo:searchText];
        }
            
    }
    else
    {
        [self.defaultInputDelegate searchBar:searchBar textDidChange:searchText];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (self.isPredictive)
    {
        NSArray<NSString*>* words = [self.predictiveText predictWordsStartedWith:searchBar.text];
        
        self.text = words.firstObject;
        
        [self.suggestedWordsDelegate didSuggestedWordsChangeTo:words];
    }
    else if (self.isMultiTap)
    {
        if (searchBar.text.length > 0)
        {
            [self symbolWith:searchBar.text];
            [self.suggestedWordsDelegate didNumbersChangeTo:searchBar.text];
        }
    }
    else
    {
        [self.defaultInputDelegate searchBarSearchButtonClicked:searchBar];
    }
}

-(void)isPredictiveText:(BOOL)state
{
    self.isPredictive = state;
    
    if (state)
    {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    else
    {
        self.keyboardType = UIKeyboardTypeDefault;
    }
}

-(void)isMultiTap:(BOOL)state
{
    self.isMultiTap = state;
    
    if (state)
    {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    else
    {
        self.keyboardType = UIKeyboardTypeDefault;
    }
}

-(void)didChooseWord:(NSString*)word
{
    [self.predictiveText chooseWord:word];
}

-(void)symbolWith:(NSString*)inputString
{
    if (self.isTimerOn)
    {
        NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
        NSString* number = [inputString substringFromIndex:inputString.length - 1];
        if (curTime - self.time > 0.5)
        {
            self.lastNumber = number;
            NSMutableString* word = [NSMutableString stringWithString:[inputString substringWithRange:NSMakeRange(0, inputString.length - 1)]];
            [word appendString:[self.predictiveText getSymbolWith:number]];

            [self resetTimer];
            self.text = word;
        }
        else
        {
            
            if ([self.lastNumber isEqualToString:number])
            {
                NSString* lastSymbol = [inputString substringWithRange:NSMakeRange(inputString.length - 2, inputString.length - 2)];
                NSMutableString* word = [NSMutableString stringWithString:[inputString substringWithRange:NSMakeRange(0, inputString.length - 2)]];
                [word appendString:[self.predictiveText getSymbolWith:lastSymbol]];

                [self resetTimer];
                self.text = word;
            }
            else
            {
                self.lastNumber = number;
                NSMutableString* word = [NSMutableString stringWithString:[inputString substringWithRange:NSMakeRange(0, inputString.length - 2)]];
                [word appendString:[self.predictiveText getSymbolWith:number]];

                [self resetTimer];
                self.text = word;
            }
        }
    }
    else
    {
        self.lastNumber = inputString;
        [self resetTimer];
        self.text = [self.predictiveText getSymbolWith:inputString];
    }
    
}

-(void)resetTimer
{
    self.time = [[NSDate date] timeIntervalSince1970];
    self.isTimerOn = YES;
}

@end
