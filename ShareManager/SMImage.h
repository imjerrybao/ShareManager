//
//  SMImage.h
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SMImage : NSObject

@property (nonatomic, strong) NSData *compressedData;
@property (nonatomic, strong) UIImage *compressedImage;

- (instancetype)initWithImageUrl:(NSString *)imageUrl;
- (instancetype)initWithImage:(UIImage *)image;

@end
