//
//  URLRouterModel.h
//  MMURLRouter
//
//  Created by 王庐厅 on 2017/6/15.
//  Copyright © 2017年 HaiNa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLRouterModel : NSObject

@property (nonatomic,copy)NSString * agreement;  // 协议

@property (nonatomic,copy)NSString * domain;     //域名描述

@property (nonatomic,copy)NSString * action;     // targetClass rename

@property (nonatomic,copy)NSString *fileName;    // 文件名

@property (nonatomic,assign)uint  transitionType;

@property (nonatomic,strong)id data;

- (NSString *)configURLWithFileName:(NSString *)fileName
                         agreement:(NSString *)agreement
                            domain:(NSString *)domain
                            action:(NSString *)action
                    transitionType:(uint)transitionType
                              data:(id)data ;

@end
