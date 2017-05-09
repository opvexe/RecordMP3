//
//  DBManager.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager
{
      FMDatabase *_dataBase;
}

+ (DBManager *)sharedManager {
    
    static DBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self createClockDataBase];
    }
    return self;
}

- (void)createClockDataBase {
    
    NSString *clockPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/clock.sqlite"];
    _dataBase = [[FMDatabase alloc] initWithPath:clockPath];
    BOOL ret = [_dataBase open];
    if (ret) {
        
        
        //录音表myRecord
        NSString *recordSql = @"create table if not exists myRecord (kRecordId integer primary key autoincrement, fileSize varchar(255), createTime varchar(255), recordTime varchar(255), fileName varchar(255), filePath varchar(255))";
        
        BOOL recordFlag = [_dataBase executeUpdate:recordSql];
        if (!recordFlag) {
            
            NSLog(@"error == %@", _dataBase.lastErrorMessage);
        } else {
            
            NSLog(@"创建表成功");
        }
    } else {
        
        NSLog(@"打开数据库失败");
    }
    [_dataBase close];
}

#pragma mark - 录音数据库
- (void)addRecordModel:(RecordModel *)model {
    
    BOOL ret = [_dataBase open];
    NSString *sql = @"";
    if (ret) {
        
        sql = @"insert into myRecord (fileSize, createTime, recordTime, fileName, filePath) values (?, ?, ?, ?, ?)";
        BOOL flag = [_dataBase executeUpdate:sql, model.fileSize, model.createTime, model.recordTime, model.fileName, model.filePath];
        if (!flag) {
            
            NSLog(@"addError == %@",_dataBase.lastErrorMessage);
        }
    }
    [_dataBase close];
    
}

- (NSArray *)searchAllRecordData {
    
    BOOL ret = [_dataBase open];
    NSMutableArray *array = [NSMutableArray array];
    if (ret) {
        
        NSString *sql = @"select * from myRecord order by kRecordId desc";
        FMResultSet *rs = [_dataBase executeQuery:sql];
        while ([rs next]) {
            
            RecordModel *model = [[RecordModel alloc] init];
            model.fileSize = [rs stringForColumn:@"fileSize"];
            model.createTime = [rs stringForColumn:@"createTime"];
            model.recordTime = [rs stringForColumn:@"recordTime"];
            model.fileName = [rs stringForColumn:@"fileName"];
            model.filePath = [rs stringForColumn:@"filePath"];
            [array addObject:model];
        }
    }
    [_dataBase close];
    return array;
}

- (void)deleteAllRecordData {
    
    BOOL ret = [_dataBase open];
    if(ret) {
        
        [_dataBase executeUpdate:@"DELETE FROM myRecord"];
        [_dataBase executeUpdate:@"UPDATE sqlite_sequence set seq=0 where name='myRecord'"];
    }
    [_dataBase close];
}

- (void)deleteRecord:(NSString *)filePath {
    
    BOOL ret = [_dataBase open];
    if (ret) {
        
        BOOL flag = [_dataBase executeUpdateWithFormat:@"delete from myRecord where filePath = %@",filePath];
        if (!flag) {
            
            NSLog(@"==%@",_dataBase.lastErrorMessage);
        }
    }
    [_dataBase close];
}

@end
