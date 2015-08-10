//
//  ShareIcon.m
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "SMIcon.h"
#import "UIView+size.h"

@implementation SMIcon

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image
{
    self = [super init];
    if (self) {
        _iconTitle = title;
        _iconImage = image;
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    _iconImageView.frame = CGRectMake(0, 0, 58, 58);
    _iconImageView.image = _iconImage;
    _iconImageView.backgroundColor = [UIColor clearColor];
    _iconImageView.userInteractionEnabled = NO;
    [self addSubview:_iconImageView];
    
    _iconLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconImageView.bottom+5, _iconImageView.width, 20)];
    _iconLbl.text = _iconTitle;
    _iconLbl.font = [UIFont systemFontOfSize:10];
    _iconLbl.textAlignment = NSTextAlignmentCenter;
    _iconLbl.backgroundColor = [UIColor clearColor];
    _iconLbl.userInteractionEnabled = NO;
    [self addSubview:_iconLbl];
}

@end
