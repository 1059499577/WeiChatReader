//
//  ViewController.m
//  仿微信阅读
//
//  Created by RenXiangDong on 17/1/10.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "ViewController.h"
#import "XMLayout.h"
#import "XMCell.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
{
    NSIndexPath *_currentIndexpath;
    XMCell *_currentCell;
    UIImageView *_currentImageVeiw;
    CGFloat lastY;
    CGRect _oraginalFrame;
    int _dataNumber;
}
@property (nonatomic, retain) UICollectionView *collectionVeiw;
@property (nonatomic, retain) XMLayout *layout;
@property (nonatomic,retain)UILabel *titleLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataNumber = 20;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.collectionVeiw];
    [self.view addSubview:self.titleLabel];
    [self sayWorlds:@"长按可以删除"];
 
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XMCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XMCell" forIndexPath:indexPath];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5;
    [cell addGestureRecognizer:longPress];
    cell.hidden = NO;

    return cell;
}

- (void)longPress:(UILongPressGestureRecognizer*)press{
    if (press.state == UIGestureRecognizerStateBegan) {
        _currentCell = (XMCell*)press.view;
        _currentIndexpath = [_collectionVeiw indexPathForCell:_currentCell];
        _currentImageVeiw = [self customSnapshoFromView:_currentCell];
        [self.view addSubview:_currentImageVeiw];
        [self.view bringSubviewToFront:self.titleLabel];
        self.titleLabel.alpha = 1;
        _currentCell.hidden = YES;
        _oraginalFrame = _currentImageVeiw.frame;
        lastY = [press locationInView:self.view].y;
        [self sayWorlds:@"上滑删除"];
    } else if (press.state == UIGestureRecognizerStateEnded) {
        _titleLabel.alpha = 0;
        if (_currentImageVeiw.frame.origin.y < -20) {
            /* 要删除 */
            [UIView animateWithDuration:0.3 animations:^{
                _currentImageVeiw.frame = CGRectMake(_currentImageVeiw.frame.origin.x, -kScreenHeight, _currentImageVeiw.frame.size.width, _currentImageVeiw.frame.size.height);
            } completion:^(BOOL finished) {
                _dataNumber--;
                [_currentImageVeiw removeFromSuperview];
                [_collectionVeiw deleteItemsAtIndexPaths:@[_currentIndexpath]];
                [_collectionVeiw performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
                [self sayWorlds:@"删除了"];
            }];
            
        } else {
            [UIView animateWithDuration:0.4 animations:^{
                _currentImageVeiw.frame =_oraginalFrame;
            } completion:^(BOOL finished) {
                [_currentImageVeiw removeFromSuperview];
                _currentCell.hidden = NO;
                 [self sayWorlds:@"下滑无效"];
            }];
        }
    } else {
      CGFloat newY = [press locationInView:self.view].y;
        CGFloat offSet = newY - lastY;
         _currentImageVeiw.transform = CGAffineTransformTranslate(_currentImageVeiw.transform, 0, offSet);
        lastY = newY;
        CGFloat off = _oraginalFrame.origin.y - _currentImageVeiw.frame.origin.y;
        off = off < 0 ? 0:off;
        off = off > 30 ? 30:off;
        _titleLabel.alpha = 1 - off/30.0;
    }
}


- (UICollectionView *)collectionVeiw {
    if (!_collectionVeiw) {
        _collectionVeiw = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight - 60) collectionViewLayout:self.layout];
        _collectionVeiw.dataSource = self;
        _collectionVeiw.delegate = self;
        [_collectionVeiw registerNib:[UINib nibWithNibName:@"XMCell" bundle:nil] forCellWithReuseIdentifier:@"XMCell"];
        _collectionVeiw.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _collectionVeiw;
}

- (XMLayout *)layout {
    if (!_layout) {
        _layout = [[XMLayout alloc] init];
        _layout.itemSize = CGSizeMake(kScreenWidth * 0.8, kScreenHeight * 0.83);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = 5;
    }
    return _layout;
}

- (UIImageView *)customSnapshoFromView:(UIView *)inputView {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.frame = [_collectionVeiw convertRect:inputView.frame toView:self.view];
    snapshot.userInteractionEnabled = YES;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 7;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 7.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}
-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, kScreenWidth, 30)];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"上滑删除";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.alpha = 0;
    }
    return _titleLabel;
}
- (void)sayWorlds:(NSString*)worlds{
    AVSpeechSynthesizer *synthesizerr = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:worlds];
//    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@""];
    [synthesizerr speakUtterance:utterance];
}

@end
