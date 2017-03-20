//
//  XMCell.m
//  仿微信阅读
//
//  Created by RenXiangDong on 17/1/10.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import "XMCell.h"

@implementation XMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 7;
    self.layer.masksToBounds = YES;
    // Initialization code
}

@end
