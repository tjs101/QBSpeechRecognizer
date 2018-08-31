//
//  OCRSpeechRecognizer.m
//  VoiceTranslate
//
//  Created by quentin on 2018/6/8.
//  Copyright © 2018年 Quentin. All rights reserved.
//

#import "QBSpeechRecognizer.h"
#import <Speech/Speech.h>

API_AVAILABLE(ios(10.0))
@interface QBSpeechRecognizer () <SFSpeechRecognizerDelegate>

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;/**<>*/
@property (nonatomic, strong) AVAudioEngine *audioEngine;/**<>*/
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;/**<>*/
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;/**<>*/
@end

@implementation QBSpeechRecognizer

+ (QBSpeechRecognizer *)sharedInstance
{
    static QBSpeechRecognizer *_instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[QBSpeechRecognizer alloc] init];
    });
    
    return _instance;
}

- (void)requestAuthorization:(void(^)(BOOL success))handler
{
    if (@available(iOS 10.0, *)) {
        [SFSpeechRecognizer  requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status) {
                    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    case SFSpeechRecognizerAuthorizationStatusDenied:
                    case SFSpeechRecognizerAuthorizationStatusRestricted:
                    default:
                        if (handler) {
                            handler(NO);
                        }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusAuthorized:
                        if (handler) {
                            handler(YES);
                        }
                        break;
                }
                
            });
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)startSpeechRecognizerLocalName:(NSString *)localeName recognizerText:(void ((^)(NSString *text)))recognizerText
{
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    if (error) {
        return;
    }
    [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    if (error) {
        return;
    }
    
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        return;
    }
    
    
    if (@available(iOS 10.0, *)) {
        _recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    } else {
        // Fallback on earlier versions
    }
    
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    if (inputNode == nil ||
        _recognitionRequest == nil) {
        NSLog(@"录入设备没有准备好，请重试!");
        return;
    }
    
    _recognitionRequest.shouldReportPartialResults = YES;
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeName];
    if (@available(iOS 10.0, *)) {
        _speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    } else {
        // Fallback on earlier versions
    }
    _speechRecognizer.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        _recognitionTask = [_speechRecognizer recognitionTaskWithRequest:_recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                BOOL isFinal = NO;
                if (result) {
                    NSLog(@"result==%@", result.bestTranscription.formattedString);
                    isFinal = result.isFinal;
                    if (recognizerText) {
                        recognizerText(result.bestTranscription.formattedString);
                    }
                }
                
                if (error || isFinal) {
                    [weakSelf.audioEngine stop];
                    [inputNode removeTapOnBus:0];
                    weakSelf.recognitionTask = nil;
                    weakSelf.recognitionRequest = nil;
                }
            }];

        }];
    } else {
        // Fallback on earlier versions
    }
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode removeTapOnBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        
        if (weakSelf.recognitionRequest) {
            [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
        }
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    NSParameterAssert(!error);
}

- (void)endSpeechRecognizer
{
    [self.audioEngine stop];
    if (_recognitionRequest) {
        [_recognitionRequest endAudio];
    }
    
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    
    if (_speechRecognizer) {
        _speechRecognizer.delegate = nil;
        _speechRecognizer = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    NSParameterAssert(!error);
    
    [audioSession setMode:AVAudioSessionModeMoviePlayback error:&error];
    NSParameterAssert(!error);
    
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    NSParameterAssert(!error);
}

#pragma mark - AVAudioEngine

- (AVAudioEngine *)audioEngine
{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}

#pragma mark - SFSpeechRecognizerDelegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available
API_AVAILABLE(ios(10.0)){
    if (available) {
        
    }
}

@end
