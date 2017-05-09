//
//  RecordController.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "RecordController.h"
#import "PlayRecordController.h"

@interface RecordController ()
{
    NSTimer *_timer;   //计时器
    UILabel *_timerLabel;
    NSInteger _second;
    
    UIButton *_startOrPauseBtn;
    UIButton *_setUpBtn;    //重置按钮
    UIButton *_saveBtn;     //保存按钮
    
    NSString *_mp3FileName;
    BOOL _isRecording;
    
    AVAudioPlayer *_player;
    NSString *_mp3FilePath;
    NSURL *_mp3Url;
    NSURL *_recordUrl;
    Waver *_waver;
    
    AVAudioSession *_session;
}
@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, strong) AVAudioRecorder *recorder;  //录音

@end
static const CGFloat TimerLabelH = 60;
static const CGFloat startBtnWidth = 120;
static const CGFloat otherBtnWidth = 60;
static const CGFloat btnSpace = 20;

@implementation RecordController

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self unEnbleBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    _second = 0;
    _timerLabel.text = @"00:00:00";
}

- (void)addWaveView {
    
    _waver = [[Waver alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100.0)];
    _waver.center = self.view.center;
    _waver.backgroundColor  = [UIColor redColor];
    [self stopWave];
    [self.view addSubview:_waver];
}

- (void)startWave {
    
    __block AVAudioRecorder *weakRecorder = _recorder;
    
    _waver.waverLevelCallback = ^(Waver * waver) {
        
        [weakRecorder updateMeters];
        
        //pow (a, b),即a的b次方，如pow (2, 3) = 8
        //[weakRecorder averagePowerForChannel:0]:指定通道的测量平均值，注意只有调用完updateMeters才有值，值的取值范围为(-160, 0);
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:1] / 40);
        //
        waver.level = normalizedValue;
    };
}

- (void)stopWave {
    
    _waver.waverLevelCallback = ^(Waver * waver) {
        
        waver.level = 0;
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self initNavgationItem];
    
    _isRecording = NO;
    [self addTimerLabel];
    [self initRecordView];
    [self addWaveView];
}

-(void)initNavgationItem{
    self.navigationItem.title = @"录音";
    self.view.backgroundColor  = [UIColor whiteColor];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"录音目录" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = right;
    UIBarButtonItem *left= [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    self.navigationItem.leftBarButtonItem = left;
}

-(void)rightAction{
    PlayRecordController *pvc =[[PlayRecordController alloc]init];
    [self.navigationController pushViewController:pvc animated:YES];
}

-(void)leftAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark

-(void)initRecordView{
    CGPoint startCenter = CGPointMake(kScreenWidth / 2, kScreenHeight - 30 - startBtnWidth / 2);
    CGPoint setUpCenter = CGPointMake(startCenter.x - btnSpace - (startBtnWidth + otherBtnWidth) / 2, startCenter.y);
    CGPoint saveCenter = CGPointMake(startCenter.x + btnSpace + (startBtnWidth + otherBtnWidth) / 2, startCenter.y);
    
    _startOrPauseBtn = [Common createBtnFrame:CGRectMake(0, 0, startBtnWidth, startBtnWidth) type:UIButtonTypeCustom target:self action:@selector(stratOrPauseRecord:) title:@"开始"];
    _startOrPauseBtn.backgroundColor = [UIColor blackColor];
    [_startOrPauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startOrPauseBtn.titleLabel.font = [UIFont systemFontOfSize:startBtnWidth / 3];
    _startOrPauseBtn.showsTouchWhenHighlighted = YES;
    _startOrPauseBtn.center = startCenter;
    
    _setUpBtn = [Common createBtnFrame:CGRectMake(0 , 0, otherBtnWidth, otherBtnWidth) type:UIButtonTypeCustom target:self action:@selector(setUpRecord:) title:@"重置"];
    
    [_setUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _setUpBtn.showsTouchWhenHighlighted = YES;
    _setUpBtn.center = setUpCenter;
    
    _saveBtn = [Common createBtnFrame:CGRectMake(0, 0, otherBtnWidth, otherBtnWidth) type:UIButtonTypeCustom target:self action:@selector(saveRecord:) title:@"保存"];
    
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _saveBtn.showsTouchWhenHighlighted = YES;
    _saveBtn.center = saveCenter;
    
    [Common layerBorderWidth:1.0 borderColor:ILColor(0, 0, 0) cornerRadius:startBtnWidth / 2 forView:_startOrPauseBtn];
    [Common layerBorderWidth:1.0 borderColor:ILColor(0, 0, 0) cornerRadius:otherBtnWidth / 2 forView:_setUpBtn];
    [Common layerBorderWidth:1.0 borderColor:ILColor(0, 0, 0) cornerRadius:otherBtnWidth / 2 forView:_saveBtn];
    
    [self.view addSubview:_startOrPauseBtn];
    [self.view addSubview:_setUpBtn];
    [self.view addSubview:_saveBtn];
    
    _recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"record.caf"];
    //创建临时文件来存放录音文件
    _recordUrl = [NSURL fileURLWithPath:self.recordFilePath];
}

#pragma mark - 计时器的添加和相应方法
- (void)addTimerLabel {
    
    _timerLabel = [Common createLabelFrame:CGRectMake(20, 120, kScreenWidth - 40, TimerLabelH) text:@"00:00:00" alignment:NSTextAlignmentCenter textColor:[UIColor greenColor] font:TimerLabelH];
    [self.view addSubview:_timerLabel];
}

- (void)startTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSecond:) userInfo:nil repeats:YES];
}

- (void)updateSecond:(NSTimer *)timer {
    
    _second ++;
    if (_second == 1) {
        
        [self enbleBtn];
    }
    NSString *timerStr = [self convertTimeToString:_second];
    _timerLabel.text = timerStr;
}
//录音按钮方法的实现
- (void)stratOrPauseRecord:(UIButton *)btn {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                
                // 用户同意获取麦克风
                dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queueOne, ^{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //在主线程中执行UI
                        [self record];
                    });
                });
            } else {
                
                // 用户不同意获取麦克风
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"麦克风不可用" message:@"请在“设置 - 隐私 - 麦克风”中允许思美访问你的麦克风" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"前往开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    /*
                     *iOS10 开始苹果禁止应用直接跳转到系统单个设置页面，只能跳转到应用所有设置页面
                     *iOS10以下可以添加单个设置的系统路径，并在info里添加URL Type，将URL schemes 设置路径prefs即可
                     *@"prefs:root=Sounds"
                     */
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }];
                
                [alertController addAction:openAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }];
    }
}

- (void)record {
    
    //判断当录音状态为不录音的时候
    if (_isRecording) {
        
        _isRecording = NO;
        [self stopWave];
        //录音状态 点击录音按钮 停止录音
        [_startOrPauseBtn setTitle:@"开始" forState:UIControlStateNormal];
        
        //停止录音
        [_recorder pause];
        [_timer pauseTimer];
        [_session setActive:NO error:nil];
        
        long long pathSize = [self fileSizeAtPath:self.recordFilePath];
        NSLog(@"systemPathSize == %lld", pathSize);
    } else {
        
        _isRecording = YES;
        
        //设置后台播放,下面这段是录音和播放录音的设置
        _session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        //判断后台有没有播放
        if (_session == nil) {
            
            NSLog(@"Error creating sessing:%@", [sessionError description]);
        } else {
            //关闭其他音频播放，把自己设为活跃状态
            [_session setActive:YES error:nil];
        }
        
        if (![_timer isValid]) {
            
            [self startTimer];
        } else {
            
            [_timer continueTimer];
        }
        
        //将录音按钮变为停止
        [_startOrPauseBtn setTitle:@"停止" forState:UIControlStateNormal];
        
        if (!self.recorder) {
            
            NSDictionary *settings = @{AVFormatIDKey  :  @(kAudioFormatLinearPCM), AVSampleRateKey : @(11025.0), AVNumberOfChannelsKey :@2, AVEncoderBitDepthHintKey : @16, AVEncoderAudioQualityKey : @(AVAudioQualityHigh)};
            
            //开始录音,将所获取到得录音存到文件里
            self.recorder = [[AVAudioRecorder alloc] initWithURL:_recordUrl settings:settings error:nil];
            
            /*
             * settings 参数
             1.AVNumberOfChannelsKey 通道数 通常为双声道 值2
             2.AVSampleRateKey 采样率 单位HZ 通常设置成44100 也就是44.1k,采样率必须要设为11025才能使转化成mp3格式后不会失真
             3.AVLinearPCMBitDepthKey 比特率 8 16 24 32
             4.AVEncoderAudioQualityKey 声音质量
             ① AVAudioQualityMin  = 0, 最小的质量
             ② AVAudioQualityLow  = 0x20, 比较低的质量
             ③ AVAudioQualityMedium = 0x40, 中间的质量
             ④ AVAudioQualityHigh  = 0x60,高的质量
             ⑤ AVAudioQualityMax  = 0x7F 最好的质量
             5.AVEncoderBitRateKey 音频编码的比特率 单位Kbps 传输的速率 一般设置128000 也就是128kbps
             
             */
        }
        
        //准备记录录音
        [_recorder prepareToRecord];
        
        //开启仪表计数功能,必须开启这个功能，才能检测音频值
        [_recorder setMeteringEnabled:YES];
        //启动或者恢复记录的录音文件
        [_recorder record];
        
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            //开个异步线程，否则主线程会卡死
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //                [self transformCAFToMP3];
        //            });
        //        });
        
        [self startWave];
    }
}

- (void)setUpRecord:(UIButton *)btn {
    //重置计时器
    _second = 0;
    _timerLabel.text = @"00:00:00";
    [self stopRecord];
    [self unEnbleBtn];
}

- (void)saveRecord:(UIButton *)btn {
    
    [self stopRecord];
    //一定要在录音停止以后再关闭音频会话管理，此时会延续后台音乐播放
    [self transformCAFToMP3];
}

- (void)enbleBtn {
    
    _saveBtn.backgroundColor = [UIColor blackColor];
    _saveBtn.enabled = YES;
    _setUpBtn.backgroundColor = [UIColor blackColor];
    _setUpBtn.enabled = YES;
}

- (void)unEnbleBtn {
    
    _saveBtn.backgroundColor = ILColor(111, 111, 111);
    _saveBtn.enabled = NO;
    _setUpBtn.backgroundColor = ILColor(111, 111, 111);
    _setUpBtn.enabled = NO;
}

- (void)stopRecord {
    
    [_timer invalidate];
    [_recorder stop];
    _recorder = nil;
    _isRecording = NO;
    [_session setActive:NO error:nil];
    [_startOrPauseBtn setTitle:@"开始" forState:UIControlStateNormal];
    [self stopWave];
}

- (void)transformCAFToMP3 {
    
    NSString *nowTime = [self nowTime];
    //保存到Document中
    NSString *fileName = [NSString stringWithFormat:@"/%@.mp3", nowTime];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:fileName];
    _mp3Url = [NSURL URLWithString:filePath];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([_recordFilePath cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4 * 1024, SEEK_CUR);//删除头，否则在前一秒钟会有杂音
        FILE *mp3 = fopen([filePath cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功!!!");
        
        //要将录音文件保存到chache中
        [self saveData:filePath fileName:fileName];
        
        PlayRecordController  *PVC = [[PlayRecordController alloc] init];
        [self.navigationController pushViewController:PVC animated:YES];
    }
}

- (void)saveData:(NSString *)filePath fileName:(NSString *)fileName {
    
    long long fileSize = [self fileSizeAtPath:filePath];
    NSLog(@"mp3 == %lld", fileSize);
    
    NSString *fileSizeStr = [NSString stringWithFormat:@"%lld", fileSize];
    
    if (fileSizeStr.integerValue < 1024) {
        
        fileSizeStr = [NSString stringWithFormat:@"%ldB", fileSizeStr.integerValue];
    } else if (fileSizeStr.integerValue < 1024 * 1024) {
        
        fileSizeStr = [NSString stringWithFormat:@"%ldKB", fileSizeStr.integerValue / 1024];
    } else if (fileSizeStr.integerValue < 1024 * 1024 * 1024) {
        
        fileSizeStr = [NSString stringWithFormat:@"%ldMB", fileSizeStr.integerValue / 1024 / 1024];
    }
    
    NSString *createTime = [self nowTime];
    RecordModel *model = [[RecordModel alloc] init];
    model.fileName = @"录音";
    model.fileSize = fileSizeStr;
    model.recordTime = [self convertTimeToString:_second];
    model.createTime = createTime;
    model.filePath = fileName;
    DBManager *manager = [DBManager sharedManager];
    [manager addRecordModel:model];
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [_timer invalidate];
    //    [_convertFormatTimer invalidate];
    [_startOrPauseBtn setTitle:@"开始" forState:UIControlStateNormal];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"录音内存太大，请保存或删除再进行下一段录音" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:saveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 时间格式
- (NSString *)convertTimeToString:(NSInteger)second {
    //    NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [formatter dateFromString:@"00:00:00"];
    date = [date dateByAddingTimeInterval:second];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}

#pragma mark 读取文件大小
- (long long)fileSizeAtPath:(NSString *)filePath {
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (NSString *)nowTime {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yy-MM-dd_HH:mm:ss";
    NSString *nowTime = [format stringFromDate:[NSDate date]];
    return nowTime;
}


@end
