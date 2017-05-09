//
//  baseDefine.h
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#ifndef baseDefine_h
#define baseDefine_h

#ifndef DDLog
#if DEBUG
#define DDLog(xxx, ...) NSLog((@"%s [%d行]: " xxx), __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DDLog(xxx, ...)
#endif
#endif

#ifdef __OBJC__

#import "MYKit.h"



#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define ILColor(r,g,b) ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1])
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self



#endif
#endif /* baseDefine_h */
