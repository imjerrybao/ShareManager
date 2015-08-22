//
//  ShareIcon.h
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMIcon : UIView
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *iconLbl;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *iconTitle;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;
@end
