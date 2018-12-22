//
//  MMURLRouter.h
//  MMURLRouter
//
//  Created by luting on 2018/3/29.
//  Copyright © 2018年 zyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WWBaseLib/NSObject+Singleton.h>
#import <WWBaseLib/UIApplication+Transition.h>

@protocol MMURLRouterOpenURLHandler <NSObject>

- (BOOL)needLogin;

@optional
+ (BOOL)handleURL:(NSString *_Nullable)URL params:(NSDictionary *_Nullable)params;

@end

typedef void(^RouterCompleteBlock)(UIViewController * _Nullable viewController, id _Nullable params);

@protocol MMURLRouterDelegate <NSObject>

@optional ;

- (BOOL)transitionAnimateToTarget:(UIViewController *_Nullable)viewController
                            type:(TransitionType)type ;

- (void)methodBeforeTranslationWithTarget:(UIViewController * _Nullable) viewController ;

- (void)methodAfterTranslationWithTarget:(UIViewController * _Nullable) viewController ;

@end

@interface MMURLRouter : NSObject<Singleton>

//试例
//URLRouterModel * model = [URLRouterModel new];
//model.agreement = @"ihayner";
//model.domain = @"mine";
//model.param = @{@"default" :@{@"fileName":@"",@"transitionType":@""} ,@"data":@"",@"action":@""};
//NSString *url = [model configURL];
//[[MMURLRouter sharedInstance]openURL:url completionHandler:nil];

@property (nonatomic,weak,nullable) id <MMURLRouterDelegate> routerDelegate;
@property (nonatomic,strong,nullable) NSDictionary * routerConfigInfo;

- (BOOL)openURL:(NSString *_Nonnull)url completionHandler:(RouterCompleteBlock _Nullable )completionHandler;

- (void)clearAllCache ;

- (void)clearFileCacheWithFileName:(NSString * _Nonnull)fileName;

- (NSMutableDictionary * _Nullable)fileInfo  ;

- (void)clearTempData ;

@end
