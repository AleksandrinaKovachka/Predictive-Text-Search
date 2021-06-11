//
//  SearchBarBehavior.h
//  PredictiveTextSearch
//
//  Created by A-Team Intern on 9.06.21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SuggestedWordsDelegate <NSObject>

-(void)didSuggestedWordsChangeTo:(NSArray<NSString*>*)words;

-(void)didNumbersChangeTo:(NSString*)word;

@end


@protocol UserWordsChoiceDelegate <NSObject>

-(void)didChooseWord:(NSString*)word;

@end

@interface KeypadSearchBar : UISearchBar<UISearchBarDelegate, UserWordsChoiceDelegate>

@property (weak, nonatomic) id<UISearchBarDelegate> defaultInputDelegate;
@property (weak, nonatomic) id<SuggestedWordsDelegate> suggestedWordsDelegate;

-(void)initializePredictiveTextWithDictionary:(NSDictionary<NSString*, NSString*>*)dictionary andLanguage:(NSString*)language;
-(void)isPredictiveText:(BOOL)state;
-(void)isMultiTap:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
