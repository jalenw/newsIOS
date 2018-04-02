//
//  BaiduVoice.m
//  News
//
//  Created by ye jiawei on 2017/11/22.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaiduVoice.h"
#import "BDSSpeechSynthesizer.h"

NSString* APP_ID = @"10746270";
NSString* API_KEY = @"GwyibPppmHY52U5xzh1LYDxD";
NSString* SECRET_KEY = @"qNMQUaPheoy784nQcdd8glh40lcrAzS2";
__strong static NSString* currentOfflineEnglishModelName;
__strong static NSString* currentOfflineChineseModelName;

@interface BaiduVoice()

@end

@implementation BaiduVoice

-(void)configureSDK{
    NSLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [self configureOnlineTTS];
    [self configureOfflineTTS];
}

-(void)configureOnlineTTS{
    //    #error "Set api key and secret key"
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:API_KEY withSecretKey:SECRET_KEY];
}

-(void)configureOfflineTTS{
    
    NSError *err = nil;
    NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_Male" ofType:@"dat"];
    NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
    NSString* licenseData = [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
    err = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:licenseData withAppCode:APP_ID];
    if(err){
        [self displayError:err withTitle:@"Offline TTS init failed"];
        return;
    }
    [BaiduVoice loadedAudioModelWithName:@"Chinese female" forLanguage:@"chn"];
    [BaiduVoice loadedAudioModelWithName:@"English female" forLanguage:@"eng"];
}

- (void)displayError:(NSError *)error withTitle:(NSString *)title {
    NSString *errMessage = error.localizedDescription;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errMessage preferredStyle:UIAlertControllerStyleAlert];
    if(alert){
        UIAlertAction* dismiss = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {}];
        [alert addAction:dismiss];
        [AppDelegateInstance.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else{
        UIAlertView *alertv = [[UIAlertView alloc] initWithTitle:title message:errMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if(alertv){
            [alertv show];
        }
    }
}

+(void)loadedAudioModelWithName:(NSString*)modelName forLanguage:(NSString*)language{
    if([language isEqualToString:@"eng"]){
        currentOfflineEnglishModelName = modelName;
    }else{
        currentOfflineChineseModelName = modelName;
    }
}

@end
