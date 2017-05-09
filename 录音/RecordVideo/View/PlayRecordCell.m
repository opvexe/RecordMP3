//
//  PlayRecordCell.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "PlayRecordCell.h"

@interface PlayRecordCell ()

@property (strong, nonatomic)  UIImageView *recordImageView;
@property (strong, nonatomic)  UILabel *createTimeLabel;
@property (strong, nonatomic)  UILabel *fileSizeLabel;
@property (strong, nonatomic)  UILabel *recordTimeLabel;
@end
@implementation PlayRecordCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"PlayRecordCell";
    
    PlayRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        
        cell = [[PlayRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle  =UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
      
        _recordImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.recordImageView];
        
        _createTimeLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.createTimeLabel];
        
        _fileSizeLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.fileSizeLabel];
        
        _recordTimeLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.recordTimeLabel];
    }
    return self;
}

-(void)InitDataViewModel:(RecordModel *)model{
    
    self.recordImageView.image = [UIImage imageNamed:@""];
    self.recordImageView.frame = CGRectMake(20, 15, 20, 20);
    
    self.createTimeLabel.text = model.createTime;
    self.createTimeLabel.frame = CGRectMake(50, 5, 120, 15);
    
    self.fileSizeLabel.text = model.fileSize;
    self.fileSizeLabel.frame = CGRectMake(50, 30, 120, 15);
    
    self.recordTimeLabel.text = model.recordTime;
    self.recordTimeLabel.frame = CGRectMake(kScreenWidth - 120, 15, 100, 20);
}

@end
