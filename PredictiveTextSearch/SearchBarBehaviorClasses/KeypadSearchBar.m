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
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.isPredictive)
    {
        NSArray<NSString*>* words = [self.predictiveText predictWordsStartedWith:searchText];

        self.text = words.firstObject;

        [self.suggestedWordsDelegate didSuggestedWordsChangeTo:words];
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
        [self.suggestedWordsDelegate didSuggestedWordsChangeTo:words];
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

-(void)didChooseWord:(NSString*)word
{
    [self.predictiveText chooseWord:word];
}

@end
