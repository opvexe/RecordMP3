//
//  PlayRecordController.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "PlayRecordController.h"
#import "PlayRecordCell.h"

@interface PlayRecordController ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
{
    BOOL _isPlaying;
    NSUInteger _lastIndex;
    AVAudioPlayer *_player;
    AVAudioSession *_session;
}
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *playRecordTableview;
@end

@implementation PlayRecordController

- (void)viewDidLoad {
    [super viewDidLoad];

     _isPlaying = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.playRecordTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    self.playRecordTableview.delegate = self;
    self.playRecordTableview.dataSource = self;
    self.playRecordTableview.showsVerticalScrollIndicator = NO;
    self.playRecordTableview.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.playRecordTableview];
    
    self.dataArray = [NSMutableArray array];
    DBManager *manager = [DBManager sharedManager];
    NSArray *array = [manager searchAllRecordData];
    [self.dataArray addObjectsFromArray:array];
}


#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayRecordCell *cell = [PlayRecordCell cellWithTableView:tableView];
    RecordModel *model = self.dataArray[indexPath.row];
    [cell InitDataViewModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_lastIndex != indexPath.row) {
        
        _isPlaying = NO;
        [_player stop];
        _player = nil;
        [_session setActive:NO error:nil];
    }
    if (!_isPlaying) {
        
        _isPlaying = YES;
        RecordModel *model = self.dataArray[indexPath.row];
        NSError *playError;
        NSString *filePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:model.filePath];
        NSURL *url = [NSURL URLWithString:filePath];
        //播放录音
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&playError];
        //当播放录音为空, 打印错误信息
        if (_player == nil) {
            NSLog(@"Error crenting player: %@", [playError description]);
        }
        _player.delegate = self;
        [_player play];
        //播放音频时一定要重新设置session，否则出来的声音很小
        _session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [_session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        //判断后台播放管理
        if (_session == nil) {
            
            NSLog(@"Error creating sessing:%@", [sessionError description]);
        } else {
            
            [_session setActive:YES error:nil];
        }
    } else {
        
        _isPlaying = NO;
        [_player stop];
        _player = nil;
        [_session setActive:NO error:nil];
    }
    _lastIndex = indexPath.row;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DBManager *manager = [DBManager sharedManager];
    RecordModel *model = self.dataArray[indexPath.row];
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [manager deleteRecord:model.filePath];
        [self deleteFile:model.filePath];
    }];
    return @[deleteRowAction];
}


#pragma mark - playerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        
        player = nil;
        _isPlaying = NO;
        [_session setActive:NO error:nil];
    }
}

- (void)deleteFile:(NSString *)fileName {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *uniquePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!isExist) return;
    
    NSError *error;
    BOOL isDelete = [fileManager removeItemAtPath:uniquePath error:&error];
    if (isDelete) {
        NSLog(@"delete success");
    }else {
        NSLog(@"delete fail %@", error.description);
    }
}


@end
