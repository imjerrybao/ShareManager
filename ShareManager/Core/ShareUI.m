//
//  ShareUI.m
//  ShareManager
//
//  Created by Jerry on 12/31/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareUI.h"
#define ShareWindowHeight 295

@interface ShareUI ()
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation ShareUI
+ (ShareUI *)sharedInstance
{
    static ShareUI   *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareUI alloc] init];
    });
    return sharedInstance;
}

- (void)showShareWindowWithImageList:(NSArray *)shareImageList titleList:(NSArray *)shareTitleList tagList:(NSArray *)shareTagList
{
    UIView *shareWindowBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _shareWindowBackView = shareWindowBackView;
    _shareWindowBackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:_shareWindowBackView];
    
    UIView *shareWindow = [[UIView alloc] initWithFrame:CGRectMake(5, SCREEN_HEIGHT, SCREEN_WIDTH-10, ShareWindowHeight)];
    _shareWindow = shareWindow;
    _shareWindow.backgroundColor = [UIColor clearColor];
    [_shareWindowBackView addSubview:_shareWindow];
    
    UIView *shareWindowArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _shareWindow.width, _shareWindow.height-50)];
    _shareWindowArea = shareWindowArea;
    _shareWindowArea.backgroundColor = [UIColor whiteColor];
    _shareWindowArea.layer.cornerRadius = 5;
    [_shareWindow addSubview:_shareWindowArea];
    
    UILabel *shareTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _shareWindowArea.width, 20)];
    shareTitleLbl.text = Locale(@"sm.select.platform");
    shareTitleLbl.textColor = [UIColor colorWithHex:0x8f8f8f];
    shareTitleLbl.textAlignment = NSTextAlignmentCenter;
    shareTitleLbl.font = [UIFont systemFontOfSize:17];
    [_shareWindowArea addSubview:shareTitleLbl];
    
    int row = 0;
    for (int i=0; i<shareImageList.count; i++) {
        if (i % 3 == 0) {
            row++;
        }
        SMIcon *icon = [[SMIcon alloc] initWithTitle:shareTitleList[i] image:LoadImage(shareImageList[i])]];
        icon.backgroundColor = [UIColor clearColor];
        if (i % 3 == 0) {
            icon.frame = CGRectMake((_shareWindowArea.width/3-58)/2, 25+20+(row-1)*88, 58, 83);
        } else if (i % 3 == 1) {
            icon.frame = CGRectMake((_shareWindowArea.width-58)/2, 25+20+(row-1)*88, 58, 83);
        }else if (i % 3 == 2) {
            icon.frame = CGRectMake(5*_shareWindowArea.width/6-58/2, 25+20+(row-1)*88, 58, 83);
        }
        icon.tag = [shareTagList[i] integerValue];
        icon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareAction:)];
        tapGuesture.numberOfTapsRequired = 1;
        [icon addGestureRecognizer:tapGuesture];
        [_shareWindowArea addSubview:icon];
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, _shareWindow.height-45, _shareWindow.width, 40);
    [cancelBtn setTitle:Locale(@"sm.general.cancel") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHex:0x007aff] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.layer.cornerRadius = 5;
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_shareWindow addSubview:cancelBtn];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _shareWindow.frame = CGRectMake(5, SCREEN_HEIGHT-ShareWindowHeight-5, SCREEN_WIDTH-10, ShareWindowHeight+5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _shareWindow.frame = CGRectMake(5, SCREEN_HEIGHT-ShareWindowHeight, SCREEN_WIDTH-10, ShareWindowHeight);
        }];
    }];
}

- (void)cancelAction
{
    _shareWindowBackView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2 animations:^{
        _shareWindowBackView.frame = CGRectMake(15, SCREEN_HEIGHT, SCREEN_WIDTH-30, ShareWindowHeight);
    } completion:^(BOOL finished) {
        [_shareWindowBackView removeFromSuperview];
    }];
}
- (void)shareAction:(UITapGestureRecognizer *)recognizer
{
    [self.delegate shareToPlatform:recognizer.view.tag];
}

@end
