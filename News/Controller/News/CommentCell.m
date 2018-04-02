//
//  CommentCell.m
//  News
//
//  Created by ye jiawei on 2017/11/7.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCell()
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *subCommentLabel;

@end

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatar.layer.cornerRadius = self.avatar.width/2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComment:(Comment *)comment
{
    _comment = comment;
    self.name.text = comment.sender;
    self.commentLabel.text = comment.content;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:comment.avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    [self.likeBtn setTitle:[NSString stringWithFormat:@"  %d",comment.likeNum] forState:UIControlStateNormal];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (Comment *subcom in comment.subComment) {
        NSString *string = [NSString stringWithFormat:@"%@ 回复:%@",subcom.sender,subcom.content];
        [array addObject:string];
    }
    NSString *subComStr = [array componentsJoinedByString:@"\n"];
    self.subCommentLabel.text = subComStr;
}

- (IBAction)reply:(UIButton *)sender {
    [self.delegate reply:self.comment];
}

- (IBAction)likeCommon:(UIButton *)sender {
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=newsuser&op=likeComment" params:@{@"reply_id":@(self.comment.comment_id)} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            _comment.hasLike = !_comment.hasLike;
            if (_comment.hasLike) {
                _comment.likeNum++;
            }
            else{
                _comment.likeNum--;
            }
            [self.likeBtn setTitle:[NSString stringWithFormat:@"  %d",_comment.likeNum] forState:UIControlStateNormal];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

@end
