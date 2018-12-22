//
//  URLRouterModel.m
//  MMURLRouter
//
//  Created by 王庐厅 on 2017/6/15.
//  Copyright © 2017年 HaiNa. All rights reserved.
//

#import "URLRouterModel.h"
#import <WWBaseLib/DataHelp.h>

@implementation URLRouterModel

- (NSString *)configURLWithFileName:(NSString *)fileName
                            agreement:(NSString *)agreement
                            domain:(NSString *)domain
                            action:(NSString *)action
                    transitionType:(uint)transitionType
                              data:(id)data {
    
    if ( validString(agreement) == false) return  nil;
    if ( validString(domain) == false ) return  nil;
    if ( validString(fileName) == false )  return  nil;
    if ( validString(action) == false ) return  nil;
    
    self.agreement = agreement;
    self.domain = domain;
    self.fileName = safeString(fileName);
    self.action = safeString(action);
    self.transitionType = transitionType;
    self.data = data?:@"";
    NSDictionary * param = @{@"default":@{@"transitionType":@(self.transitionType),
                                          @"fileName":fileName },
                             @"data":self.data,
                             @"action":self.action };
    NSString * jsonString = [self dictionaryTransJsonWithDic:param];
    if (validString(jsonString) ==  false)  return  nil;
    
    return [NSString stringWithFormat:@"%@://%@?params=%@",self.agreement,self.domain,jsonString];
}

- (NSString * _Nullable)dictionaryTransJsonWithDic:(NSDictionary * _Nonnull)dic {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if(error){
        NSLog(@"%s:%@",__func__,error.localizedDescription);
        return nil;
    }
    return  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}
@end
