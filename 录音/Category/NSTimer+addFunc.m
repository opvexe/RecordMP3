//
//  NSTimer+addFunc.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "NSTimer+addFunc.h"

@implementation NSTimer (addFunc)

- (void)pauseTimer {
    
    //如果已被释放则return！isValid对应invalidate
    if (![self isValid]) return;
    //启动时间为很久以后
    [self setFireDate:[NSDate distantFuture]];
}

- (void)continueTimer {
    
    if (![self isValid]) return;
    //启动时间为现在
    [self setFireDate:[NSDate date]];
}

@end
