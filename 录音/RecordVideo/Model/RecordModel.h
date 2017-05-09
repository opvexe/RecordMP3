//
//  RecordModel.h
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordModel : NSObject

@property (nonatomic, copy) NSString *fileSize;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, copy) NSString *recordTime;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, copy) NSString *recordId;
@end
