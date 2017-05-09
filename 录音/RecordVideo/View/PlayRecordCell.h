//
//  PlayRecordCell.h
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayRecordCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

-(void)InitDataViewModel:(RecordModel *)model;
@end
