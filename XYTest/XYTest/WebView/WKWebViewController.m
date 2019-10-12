//
//  WKWebViewController.m
//  XYTest
//
//  Created by 张时疫 on 2019/3/25.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import "AudioViewController.h"
#import "HierarchyStructure.h"
@interface WKWebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, strong) UIButton * nativeInvokeJSButton;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"WKWebView测试";
    self.view.backgroundColor = HEXCOLOR(0xf9f9f9);
    [self initSubviews];
    
    self.url = [[NSBundle mainBundle] URLForResource:@"LocalWebTest" withExtension:@"html"];
    self.urlString = [[NSBundle mainBundle] pathForResource:@"LocalWebTest" ofType:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    // 添加监测网页加载进度的观察者
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    // 添加监测网页标题title的观察者
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

//kvo 监听进度 必须实现此方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        NSLog(@"网页加载进度 = %f",self.webView.estimatedProgress);
    } else if ([keyPath isEqualToString:@"title"] && object == self.webView) {
        self.navigationItem.title = self.webView.title;
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)nativeInvokeJS:(UIButton *)button {
    HierarchyStructure * hierarchyStructure = [[HierarchyStructure alloc] init];
    NSString * buttonStructure = [hierarchyStructure getHierarchyStructureOfView:button];
    [hierarchyStructure dumpViews:self.view text:@"====" indent:@"###"];
    NSLog(@"打印视图层级结构：%@", buttonStructure);
    
    // OC调用JS  changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@', %@)", @"Js参数", @{@"test":@"test"}];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"改变HTML的背景色");
    }];
    // 改变字体大小 调用原生JS方法
    // NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", arc4random()%99 + 100];
    // [self.webView evaluateJavaScript:jsFont completionHandler:nil];
}
/**
 * JS 调用 OC 方法
 */
- (void)JSInvoteNative:(id)param {
    NSLog(@"JS 调用 OC 方法");
}

- (void)initSubviews {
    [self.view addSubview:self.nativeInvokeJSButton];
    [self.view addSubview:self.webView];
    [self.nativeInvokeJSButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).insets(UIEdgeInsetsMake(UI_NAVIGATION_HEIGHT + 10, 10, 0, 10));
        make.width.equalTo(120);
        make.height.equalTo(44);
    }];
    [self.webView makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.top.equalTo(self.nativeInvokeJSButton.bottom).offset(10);
    }];
}


#pragma mark --- WKScriptMessageHandler ---
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"userContentController:didReceiveScriptMessage: \n message.name:%@\n  message.body:%@\n message.frameInfo:%@\n",message.name,message.body,message.frameInfo);
    // 用message.body获得JS传出的参数体
    id parameter = message.body;
//    NSData *jsonData = [message.body dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary * shareParamDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    // JS调用OC
    if([message.name isEqualToString:@"JSInvoteNative"]){
        NSLog(@"JavaScript 调用 OC 方法测试:%@\n%@", message.body, parameter);
    }
}

#pragma mark --- WKNavigationDelegate ---
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // 页面开始加载时调用
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    // 页面加载失败时调用
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    // 当内容开始返回时调用
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 页面加载完成之后调用
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // 提交发生错误时调用
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    // 接收到服务器跳转请求即服务重定向时之后调用
}
/**
 * 类似 UIWebView 的 webView:shouldStartLoadWithRequest:navigationType: 方法，可用于网页请求的拦截
 * */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
    NSString * url = navigationAction.request.URL.absoluteString;
    if ([url rangeOfString:@"LocalWebTest"].location != NSNotFound) {
        // 拦截 URL
        // decisionHandler(WKNavigationActionPolicyCancel);
        // AudioViewController * vc = [[AudioViewController alloc] init];
        // [self.navigationController pushViewController:vc animated:YES];
        // return;
    }
    if ([navigationAction.request.URL.scheme isEqualToString:@"tel"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSString * mutStr = [NSString stringWithFormat:@"telprompt://%@",navigationAction.request.URL.resourceSpecifier];
        NSLog(@"网页想打电话：：%@", navigationAction.request);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    //需要响应身份验证时调用 同样在block中需要传入用户身份凭证
    //用户身份信息
    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
}
//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}

#pragma mark --- WKUIDelegate ---
/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark --- dealloc ---
- (void)dealloc {
    // [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"方法名"];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark --- Gatter ---
- (UIButton *)nativeInvokeJSButton {
    if (!_nativeInvokeJSButton) {
        _nativeInvokeJSButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nativeInvokeJSButton setTitle:@"OC Invoke JS" forState:UIControlStateNormal];
        [_nativeInvokeJSButton setBackgroundColor:[UIColor greenColor]];
        [_nativeInvokeJSButton addTarget:self action:@selector(nativeInvokeJS:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nativeInvokeJSButton;
}

- (WKWebView *)webView {
    if (!_webView) {
        NSData * jsData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LocalJSTest" ofType:@"js"]];
        NSString * jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
        // 用于进行JavaScript注入
        WKUserScript * userScript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:userScript];
        // 注册一个name为testOCMethod的js方法
         [wkUController addScriptMessageHandler:self name:@"JSInvoteNative"];

        WKWebViewConfiguration * webViewConfig = [[WKWebViewConfiguration alloc] init];
        webViewConfig.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        //用完记得移除
        //移除注册的js方法
        //        [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
        //        [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
    }
    return _webView;
}


@end
