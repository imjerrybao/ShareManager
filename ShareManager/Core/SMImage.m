//
//  SMImage.m
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "SMImage.h"

@implementation SMImage

- (instancetype)initWithImageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _compressedData = UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]], 0.3);
            _compressedImage = [UIImage imageWithData:_compressedData];
        });
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _compressedData = UIImageJPEGRepresentation(image, 0.3);
        _compressedImage = [UIImage imageWithData:_compressedData];
    }
    return self;
}

@end
