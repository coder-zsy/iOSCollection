//
//  WebViewController.m
//  XYTest
//
//  Created by 张时疫 on 2019/3/25.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "WebViewController.h"
#import "AudioViewController.h"

#import <JavaScriptCore/JavaScriptCore.h>

//JS端window.WebViewJavascriptBridge
//OC端WebViewJavascriptBridge和WebViewJavascriptBridgeBase。
//#import "WebViewJavascriptBridgeBase.h"
//#import "WebViewJavascriptBridge.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UIButton * refreshButton;

@end

@implementation WebViewController
- (UIStatusBarStyle)preferredStatusBarStyle {
    /**
     * UIStatusBarStyleDefault 状态栏字体黑色
     * UIStatusBarStyleLightContent 状态栏字体白色
     */
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"UIWebView测试";
    [self initSubviews];
    
    /** 加载本地文件 */
    NSURL * localHtml = [[NSBundle mainBundle] URLForResource:@"LocalWebTest" withExtension:@"html"];
    NSURL * localWord = [[NSBundle mainBundle] URLForResource:@"LocalWord" withExtension:@"docx"];
    NSURL * localPDF = [[NSBundle mainBundle] URLForResource:@"LocalPDF" withExtension:@"pdf"];
    NSURL * localRTF = [[NSBundle mainBundle] URLForResource:@"LocalRTF" withExtension:@"rtf"];
    
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"LocalPDF" ofType:@"pdf"];
    NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
    
    self.url = localHtml;
    //    UIWebView* tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    //    NSString* userAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    //    if (![userAgent containsString:@"towkershop"] || ![userAgent containsString:@"mmb_v2.0"]) {
    //        NSString *ua = [NSString stringWithFormat:@"%@ %@ %@",
    //                        userAgent,@"towkershop",
    //                        @"mmb_v2.0"];
    //        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent" : ua}];
    //    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    // [self.webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}

- (void)initSubviews {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.webView];
    
    [self.backButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.left.equalTo(self.view).offset(10);
        make.size.equalTo(CGSizeMake(100, 44));
    }];
    [self.webView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.bottom).offset(10);
        make.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        // make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)jsBridgeMethod {
    //    [WebViewJavascriptBridge enableLogging];
    //    // 给哪个webview建立JS与OjbC的沟通桥梁
    //    WebViewJavascriptBridge  *webViewJSBridge = [WebViewJavascriptBridge bridgeForWebView:webViewS];
    //    [webViewJSBridge setWebViewDelegate:self];
}
#pragma mark --- UIWebViewDelegate ---
// 页面进行加载数据的时候调用
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"ua=======%@",[request valueForHTTPHeaderField:@"User-Agent" ]);
    NSString *url = request.URL.absoluteString;
    if ([url rangeOfString:@"LocalWebTest"].location != NSNotFound) {
        AudioViewController * vc = [[AudioViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        // 拦截 请求
        return NO;
    }
    return YES;
}
// 当页面开始加载的时候调用
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    NSData * jsData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LocalJSTest" ofType:@"js"]];
    //    NSString * jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
    //    /**
    //     * 执行 JS 代码 */
    //    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}
// 当页面加载完成的时候调用
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 获取当前网页的标题
    NSString * titleStr = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    /** 直接调用 JS 方法，并返回返回值
     * 注意这里 JS 方法的返回值只能是基本数据类型，无法获取对象类型的返回值 */
    //     NSString *returnStr = [webView stringByEvaluatingJavaScriptFromString:@"shareWebWithURL('aa')"];
    // NSLog(@"获取网页标题：%@,获取调用 JS 方法返回值：%@", titleStr, returnStr);
    
    //获取webview中的JS内容
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    /** 执行准备好的的JS代码 */
    NSData * jsData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LocalJSTest" ofType:@"js"]];
    // [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSString * jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
    [context evaluateScript:jsString];
    
    // 发现 JS 调用的方法，可以在这里准备方法给 JS 调用
    context[@"shareWebWithURL"] = ^() {
        /** JS 调用方法的参数 */
        NSArray *arguments = [JSContext currentArguments];
        for (JSValue *jsValue in arguments) {
            NSData * jsonData = [[jsValue toString] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"=======%@==========\n%@",[jsValue toString],dic);
        }
    };
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
// 页面加载失败的时候调用
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)backWebView:(UIButton *)button {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

#pragma mark --- Gatter ---
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES; // 自动对页面进行缩放以适应屏幕
        [(UIScrollView *)[[_webView subviews] objectAtIndex:0] setBounces:NO]; // 取消webView的弹簧效果
        // NSString* userAgent = [_webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        // NSString *ua = [NSString stringWithFormat:@"%@ %@ %@",
        //                        userAgent,@"towkershop",
        //                        @"mmb_v2.0"];
        // [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent" : ua}];
    }
    return _webView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setBackgroundColor:[UIColor grayColor]];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backWebView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end


