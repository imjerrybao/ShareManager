//
//  ShareToInstagram.m
//  ShareManagerDemo
//
//  Created by apple on 9/9/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "ShareToInstagram.h"
NSString* const aInstagramAppURLString = @"instagram://app";
NSString* const aInstagramOnlyPhotoFileName = @"tempinstgramphoto.igo";

@interface ShareToInstagram ()
{
    UIDocumentInteractionController *documentInteractionController;
}
@property (nonatomic) NSString *photoFileName;
@property (nonatomic, strong) SMContent *content;
@end

@implementation ShareToInstagram

+ (ShareToInstagram *)sharedInstance
{
    static ShareToInstagram *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareToInstagram alloc] init];
    });
    return sharedInstance;
}

- (void)initInstagram
{
    self.photoFileName = aInstagramOnlyPhotoFileName;
}

+ (void) setPhotoFileName:(NSString*)fileName {
    [ShareToInstagram sharedInstance].photoFileName = fileName;
}
+ (NSString*) photoFileName {
    return [ShareToInstagram sharedInstance].photoFileName;
}

+ (BOOL) isAppInstalled {
    NSURL *appURL = [NSURL URLWithString:aInstagramAppURLString];
    return [[UIApplication sharedApplication] canOpenURL:appURL];
}

+ (BOOL) isImageCorrectSize:(UIImage*)image {
    CGImageRef cgImage = [image CGImage];
    return (CGImageGetWidth(cgImage) >= 612 && CGImageGetHeight(cgImage) >= 612);
}

- (NSString*) photoFilePath {
    return [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],self.photoFileName];
}

- (void) postImage:(UIImage*)image inView:(UIView*)view {
    [self postImage:image withCaption:nil inView:view];
}
- (void) postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view {
    [self postImage:image withCaption:caption inView:view delegate:nil];
}

- (void) postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate
{
    if (!image)
        [NSException raise:NSInternalInconsistencyException format:@"Image cannot be nil!"];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[self photoFilePath] atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:[self photoFilePath]];
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    documentInteractionController.UTI = @"com.instagram.photo"; //exclusivegram
    documentInteractionController.delegate = delegate;
    if (caption)
        documentInteractionController.annotation = [NSDictionary dictionaryWithObject:caption forKey:@"InstagramCaption"];
    [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:view animated:YES];
}

@end
