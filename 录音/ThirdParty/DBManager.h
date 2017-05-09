//
//  DBManager.h
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordModel.h"

@interface DBManager : NSObject

#pragma mark 单例
+ (DBManager *)sharedManager;

- (void)addRecordModel:(RecordModel *)model;
- (NSArray *)searchAllRecordData;
- (void)deleteAllRecordData;
- (void)deleteRecord:(NSString *)recordId;

@end
