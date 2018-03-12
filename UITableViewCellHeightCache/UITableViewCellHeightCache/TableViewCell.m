//
//  TableViewCell.m
//  UITableViewCellHeightCache
//
//  Created by 三只鸟 on 2018/3/5.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureWithText:(NSString *)text {
    self.label.text = text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = [self.label sizeThatFits:CGSizeMake(self.contentView.bounds.size.width, CGFLOAT_MAX)];
    self.label.frame = CGRectMake(self.label.frame.origin.x, self.label.frame.origin.y, size.width, size.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizes = CGSizeMake(size.width, 36 + [self.label sizeThatFits:size].height);
    NSLog(@"%@",NSStringFromCGSize(sizes));
    return sizes;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
