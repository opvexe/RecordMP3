//
//  Common.h
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Common : NSObject


#pragma mark 文字按钮
+ (UIButton *)createBtnFrame:(CGRect)frame type:(UIButtonType)type target:(id)target action:(SEL)action title:(NSString *)title;

#pragma mark 图片按钮
+ (UIButton *)createBtnFrame:(CGRect)frame type:(UIButtonType)type target:(id)target action:(SEL)action normalImageName:(NSString *)normalImageName touchImageName:(NSString *)touchImageName;

#pragma mark - 文本框

+ (UILabel *)createLabelFrame:(CGRect)frame text:(NSString *)text alignment:(NSTextAlignment)alignment textColor:(UIColor *)textColor font:(CGFloat)font;

#pragma mark - 设置圆角

+ (void)layerBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius forView:(UIView *)view;



@end
