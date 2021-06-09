//
//  PredictiveText.h
//  PredictiveTextSearch
//
//  Created by A-Team Intern on 7.06.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PredictiveText : NSObject

-(instancetype)initWithDictionary:(NSDictionary<NSString*, NSString*>*)dictionary andLanguage:(NSString*)language;

-(NSArray<NSString*>*)predictWordsStartedWith:(NSNumber*)number;

-(NSString*)descriptionOfWord:(NSString*)word;

@end

NS_ASSUME_NONNULL_END
