//
//  RecordController.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Waver : UIView

@property (nonatomic, copy) void (^waverLevelCallback)(Waver * waver);

@property (nonatomic) NSUInteger numberOfWaves;

@property (nonatomic) UIColor * waveColor;

@property (nonatomic) CGFloat level;

@property (nonatomic) CGFloat mainWaveWidth;

@property (nonatomic) CGFloat decorativeWavesWidth;

@property (nonatomic) CGFloat idleAmplitude;

@property (nonatomic) CGFloat frequency;

@property (nonatomic, readonly) CGFloat amplitude;

@property (nonatomic) CGFloat density;

@property (nonatomic) CGFloat phaseShift;

@property (nonatomic, readonly) NSMutableArray * waves;

@end
