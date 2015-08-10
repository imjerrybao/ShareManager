//
//  SMWebViewController.h
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@protocol SMWebViewControllerDelegate <NSObject>
- (void)SMWebClose;
@end
@interface SMWebViewController : UINavigationController
@property (nonatomic, assign) id webDelegate;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) UILabel *titleLbl;
@property (nonatomic, strong) NSString *titleText;
- (instancetype)initWithTitle:(NSString *)title;
- (void)dismiss;
- (void)stopLoading;
@end
