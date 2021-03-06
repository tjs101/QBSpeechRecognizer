//
//  QBBSpeechRecognizer.h
//  EnglishToJapanese
//
//  Created by sam on 2018/6/8.
//  Copyright © 2018年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBSpeechRecognizer : NSObject

+ (QBSpeechRecognizer *)sharedInstance;

// 获取授权
- (void)requestAuthorization:(void(^)(BOOL success))handler;

- (void)startSpeechRecognizerLocalName:(NSString *)localeName recognizerText:(void ((^)(NSString *text)))recognizerText;
- (void)endSpeechRecognizer;

@end
