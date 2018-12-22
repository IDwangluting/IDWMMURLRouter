//
//  MMURLRouter.m
//  MMURLRouter
//
//  Created by luting on 2018/3/29.
//  Copyright © 2018年 zyb. All rights reserved.
//

#import "MMURLRouter.h"
#import "URLRouterModel.h"
#import <Objc/runtime.h>
#import <YYModel/YYModel.h>
#import <WWBaseLib/DataHelp.h>
#import <YYCategories/YYCategories.h>
#import <WWBaseLib/NSInvocation+MethodIntercept.h>

@interface ViewControllerModel : NSObject

@property (nonatomic,copy)NSString * className;
@property (nonatomic,copy)NSString * instanceMethod ;
@property (nonatomic,copy)NSString * classMethod;
@property (nonatomic,copy)NSString * action;

@end

@implementation ViewControllerModel @end

@interface RouterInfo : NSObject

@property (nonatomic,copy)NSString * domain;
@property (nonatomic,copy)NSString * scheme;

@end

@implementation RouterInfo @end

@interface RouterFileDataModel : NSObject

@property (nonatomic,strong)NSArray <ViewControllerModel *> * viewControllerInfos;
@property (nonatomic,copy  )NSString * version;
@property (nonatomic,strong)RouterInfo * routerInfo;

@end

@implementation RouterFileDataModel @end

static NSMutableDictionary * plistInfoDic ;

@implementation MMURLRouter  {
    RouterFileDataModel * _currentFileData;
    NSString * _fileName;
}

- (void)clearTempData {
    _currentFileData = nil;
    if (_fileName) [plistInfoDic removeObjectForKey:_fileName];
    
    _fileName = nil;
}

- (NSString *)_checkoutPlistName:(NSString * _Nonnull)plistName {
    if ([plistName hasSuffix:@".plist"])  return plistName ;
    return  [plistName stringByAppendingString:@".plist"];
}

- (NSDictionary *)_loadConfigDictFromPlist:(NSString * _Nonnull)pistName {
    NSString *path = [[NSBundle mainBundle] pathForResource:pistName ofType:nil];
    NSDictionary *configDict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (validDictionary(configDict))  return configDict;
    
    NSAssert(0, @"请按照说明添加对应的plist文件");
    return nil;
}

- (URLRouterModel *)_getInfoWithURL:(NSString * _Nonnull)url {
    if (validString(url) == false) return  nil;
    
    NSArray * array1 =  [url componentsSeparatedByString:@"://"];
    NSArray * array2 =  [array1.lastObject componentsSeparatedByString:@"?params="];

    if (!(array1.count == 2 && array2.count == 2)) return nil;
    
    NSString * jsonString  = array2.lastObject ;
    NSString * agreement = array1.firstObject ;
    NSString * domain = array2.firstObject;
    
    if (validString(agreement) == false) return  nil;
    if (validString(domain) == false) return  nil;
    if (validString(jsonString) == false) return  nil;
    
    NSDictionary  * params = [jsonString jsonValueDecoded];
    
    if (validDictionary(params) == false) return nil;
    
    URLRouterModel * model = [URLRouterModel new];
    model.agreement = agreement;
    model.domain = domain;
    model.data = [params valueForKey:@"data"];
    model.action = [params  valueForKey:@"action"];
    model.fileName = [params valueForKeyPath:@"default.fileName"];
    
    if (validString(model.action) == false) return  nil;
    
    NSString * transitionType = [params valueForKeyPath:@"default.transitionType"];
    if (transitionType && [transitionType isKindOfClass:[NSString class]] && transitionType.length > 0 ) {
        model.transitionType = [transitionType intValue];
    } else if (transitionType && [transitionType isKindOfClass:[NSNumber class]] ) {
        model.transitionType = [transitionType intValue];
    } else {
        model.transitionType = 1;
    }
    return model;
}

- (BOOL)_readFileData {
    if(validDictionary(plistInfoDic)) {
        _currentFileData = [plistInfoDic valueForKey:_fileName];
    }
    
    if (validArray(_currentFileData.viewControllerInfos)) return true ;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:_fileName ofType:nil];
    if (validString(path) == false)  return false;
    
    NSDictionary * info = [NSDictionary dictionaryWithContentsOfFile:path];
    if (info.count < 1 ) return false;
    
    _currentFileData = [RouterFileDataModel yy_modelWithDictionary:info];
    _currentFileData.viewControllerInfos = [NSArray yy_modelArrayWithClass:[ViewControllerModel class]
                                                                      json:_currentFileData.viewControllerInfos];
    
    if (validArray(_currentFileData.viewControllerInfos)) {
        plistInfoDic = plistInfoDic?:[[NSMutableDictionary alloc]initWithCapacity:4];
        [plistInfoDic setObject:_currentFileData forKey:_fileName];
        return true ;
    }
    
    return false ;
}

- (BOOL)openURL:(NSString *_Nonnull)url completionHandler:(RouterCompleteBlock)completionHandler{
    if (validString(url) == false)  return false;
    
    URLRouterModel * model = [self _getInfoWithURL:url];
    if (model == nil)   return false;
    
    _fileName = [self _checkoutPlistName:model.fileName];
    
    if ([self _readFileData] == false)  return false ;
    
    ViewControllerModel * currentViewControllerInfo = nil;
    for (ViewControllerModel * item in _currentFileData.viewControllerInfos) {
        if ([item.action isEqualToString:model.action]) {
            currentViewControllerInfo = item;
            break;
        }
    }
    
    if (!validString(currentViewControllerInfo.instanceMethod) &&
        !validString(currentViewControllerInfo.classMethod)) {
        return false ;
    }
    
    if(validString(currentViewControllerInfo.className) == false) return false;
    
    const char * className = [currentViewControllerInfo.className cStringUsingEncoding:NSUTF8StringEncoding];
    if (objc_lookUpClass(className)) {
        Class cls = NSClassFromString(currentViewControllerInfo.className);
        if ([cls isSubclassOfClass: [UIViewController class]] == true) {
            NSString * methodName = currentViewControllerInfo.classMethod.length > 0 ?currentViewControllerInfo.classMethod:currentViewControllerInfo.instanceMethod ;
            SEL selector = NSSelectorFromString(methodName);
            id target = currentViewControllerInfo.classMethod.length > 0 ?[cls class]:[cls new];
            NSMethodSignature * signature = [[target class]methodSignatureForSelector:selector];
            signature = signature ?: [[target class] instanceMethodSignatureForSelector:selector];
            
            NSArray * array = [model.data isKindOfClass:[NSArray class]] ? model.data : nil;
            UIViewController * viewController = nil ;
            switch (signature.numberOfArguments) {
                case 2:
                    viewController = [NSInvocation invocationWithTarget:target selector:selector];
                    break;
                case 3:
                    viewController = [NSInvocation invocationWithTarget:target selector:selector,model.data];
                    break;
                case 4:
                    if (signature.numberOfArguments - array.count != 2)  return false;
                    viewController = [NSInvocation invocationWithTarget:target
                                                               selector:selector,array[0],array[1]];
                    break;
                case 5:
                    if (signature.numberOfArguments - array.count != 2)  return false;
                    viewController = [NSInvocation invocationWithTarget:target
                                                               selector:selector,array[0],array[1],array[2]];
                    break;
                case 6:
                    if (signature.numberOfArguments - array.count != 2)  return false;
                    viewController = [NSInvocation invocationWithTarget:target
                                                               selector:selector,array[0],array[1],array[2],array[3]];
                    break;
                case 7:
                    if (signature.numberOfArguments - array.count != 2)  return false;
                    viewController = [NSInvocation invocationWithTarget:target
                                                               selector:selector,array[0],array[1],array[2],array[3],array[4]];
                    break;
                default:
                    NSAssert(0, @"plist文件中方法的参数与传入的参数不匹配");
                    return false;
            }
            
            if (viewController == nil)  return false;
            
            if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(methodBeforeTranslationWithTarget:)]) {
                [self.routerDelegate methodBeforeTranslationWithTarget:viewController];
            } else {
                [self methodBeforeTranslationWithTarget:viewController];
            }

            if ([cls respondsToSelector:@selector(handleURL:params:)]) return [cls handleURL:url params:model.data];
            
            BOOL handled = NO;
            if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(transitionAnimateToTarget:type:)]) {
                handled = [self.routerDelegate transitionAnimateToTarget:viewController type:model.transitionType];
            }
            if (!handled) {
                [self transitionAnimateToTarget:viewController type:model.transitionType];
            }
                
            if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(methodAfterTranslationWithTarget:)]) {
                [self.routerDelegate methodAfterTranslationWithTarget:viewController];
            } else {
                [self methodAfterTranslationWithTarget:viewController];
            }
            if (completionHandler) completionHandler(viewController,model.data);
            return YES;
        }
    }
    return false;
}

- (void)clearFileCacheWithFileName:(NSString *)fileName {
    if (fileName &&  [fileName isKindOfClass:[NSString class]] &&
        fileName.length > 0 &&  plistInfoDic && plistInfoDic.count > 0) {
        if([fileName hasSuffix:@".plist"] == false) {
            fileName = [fileName stringByAppendingString:@".plist"];
        }
        [plistInfoDic removeObjectForKey:fileName];
        [self clearTempData];
    }
}

- (void)clearAllCache{
    [self clearTempData];
    [plistInfoDic removeAllObjects];
    plistInfoDic = nil;
}

- (NSMutableDictionary *)fileInfo {
    return plistInfoDic;
}

// delegate
- (void)transitionAnimateToTarget:(UIViewController *)viewController type:(TransitionType)type {
    switch (type) {
        case TransitionTypePush:
            [[UIApplication sharedApplication] pushViewController:viewController];
            break;
        case TransitionTypePresent:
            [[UIApplication sharedApplication] presentViewController:viewController animated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void)methodBeforeTranslationWithTarget:(UIViewController *)viewController {}

- (void)methodAfterTranslationWithTarget:(UIViewController *)viewController {}

@end
