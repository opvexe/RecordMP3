//
//  Common.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (UIButton *)createBtnFrame:(CGRect)frame type:(UIButtonType)type target:(id)target action:(SEL)action title:(NSString *)title {
    
    UIButton *btn = [UIButton buttonWithType:type];
    btn.frame = frame;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)createBtnFrame:(CGRect)frame type:(UIButtonType)type target:(id)target action:(SEL)action normalImageName:(NSString *)normalImageName touchImageName:(NSString *)touchImageName {
    
    UIButton *btn = [Common createBtnFrame:frame type:type target:target action:action title:nil];
    if (normalImageName) {
        
        [btn setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    }
    if (touchImageName) {
        
        [btn setImage:[UIImage imageNamed:touchImageName] forState:UIControlStateNormal];
    }
    return btn;
}


+ (CGFloat)heightLabelText:(NSString *)text width:(CGFloat)width font:(CGFloat)font {
    
    NSInteger w = width;
    
    CGFloat contentH = [text boundingRectWithSize:CGSizeMake(w, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size.height;
    
    return contentH;
}



+ (UILabel *)createLabelFrame:(CGRect)frame text:(NSString *)text alignment:(NSTextAlignment)alignment textColor:(UIColor *)textColor font:(CGFloat)font {
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = alignment;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:font];
    return label;
}

+ (void)layerBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius forView:(UIView *)view {
    
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.CGColor;
    view.layer.cornerRadius = cornerRadius;
}

@end
