//
//  XYImagePickerController.m
//  XYTest
//
//  Created by 张时疫 on 2019/4/22.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "XYImagePickerController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "PermissionUtils.h"
#import "UIImage+operate.h"
#import "ImagePickerUtils.h"

//#import <MobileCoreServices/MobileCoreServices.h>
@import MobileCoreServices;

@interface XYImagePickerController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *picker;
/** 相机类型
 * 用于拍照或摄像
 **/
@property (nonatomic, assign) XYCameraType curType;
@property (nonatomic, strong) NSDictionary * options;
@property (nonatomic, strong) ImagePickerResult response;

@end

@implementation XYImagePickerController

#pragma mark --- life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片/视频选择器";
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"拍照/视频" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(100, 44));
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(100);
    }];
    
}



- (void)buttonAction:(UIButton *)button {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"图片、视频选择" message:@"使用系统自带的图片、视频选择器选择" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * pictureAction = [UIAlertAction actionWithTitle:@"从图库选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraWithType:XYCameraTypeLibrary options:nil callback:^(UIImage * _Nonnull image, NSURL * _Nonnull imageURL, NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction * shootingAction = [UIAlertAction actionWithTitle:@"拍摄照片" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraWithType:XYCameraTypeShooting options:nil callback:^(UIImage * _Nonnull image, NSURL * _Nonnull imageURL, NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction * videoAction = [UIAlertAction actionWithTitle:@"拍摄视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraWithType:XYCameraTypeVideo options:nil callback:^(UIImage * _Nonnull image, NSURL * _Nonnull imageURL, NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:pictureAction];
    [alertController addAction:shootingAction];
    [alertController addAction:videoAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openCameraWithType:(XYCameraType)type options:(NSDictionary *)options callback:(ImagePickerResult)callback {
    if (type > 2) {
        NSLog(@"参数配置错误");
        return;
    }
    self.options = options;
    self.curType = type;
    self.response = callback;
    [[PermissionUtils sharedManager] checkCameraAuthorWithCallback:^(XYAuthorizationStatus status) {
        if (status == XYAuthorizationStatusRestricted || status == XYAuthorizationStatusUnable) {
            // 不可用
            NSLog(@"您的设备不支持相机");
        } else if (status == XYAuthorizationStatusWhenInUse || status == XYAuthorizationStatusAuthorized) {
            [self openCamera];
        } else {
            NSLog(@"无法使用相机,请在iPhone的""设置-隐私-相册""中允许访问相册");
        }
    }];
}

- (void)openCamera {
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"无法使用相机,模拟器中无法打开照相机,请在真机中使用");
        return;
    }
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"无法使用图库");
        return;
    }
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        NSLog(@"无法使用相册");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (rootViewController.presentedViewController != nil) {
            rootViewController = rootViewController.presentedViewController;
        }
        if (self.curType == XYCameraTypeLibrary) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

        } else if (self.curType == XYCameraTypeShooting) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        } else if (self.curType == XYCameraTypeVideo) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            self.picker.videoMaximumDuration = [[self.options valueForKey:@"maxDuration"] integerValue] ? [[self.options valueForKey:@"maxDuration"] integerValue] : 60;;//10分钟
        }
        [rootViewController presentViewController:self.picker animated:YES completion:nil];
    });
    
}

#pragma mark --- UIImagePickerControllerDelegate  start ---
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (self.curType == XYCameraTypeLibrary) {
        NSLog(@"XYCameraTypeLibrary=======%@", info);
    } else if (self.curType == XYCameraTypeShooting) {
        NSLog(@"XYCameraTypeShooting=======%@", info);
        UIImage *image;
        if ([[self.options objectForKey:@"allowsEditing"] boolValue]) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        image = [UIImage downscaleImageIfNecessary:image maxWidth:1000 maxHeight:1000];
        __block NSURL * imageUrl = nil;
        [ImagePickerUtils saveImageToAlbum:image success:^(NSURL * _Nonnull url) {
            imageUrl = url;
        } fail:^(NSString * _Nonnull errMsg) {
            XYLog(@"图片保存失败");
        }];
        NSDictionary * resDic = [ImagePickerUtils exportImageInfoWithImage:image URL:imageUrl];
        // self.callback(@[ @{@"didImageResponse": @[resDic] } ]);
    } else if (self.curType == XYCameraTypeVideo) {
        NSLog(@"XYCameraTypeVideo=======%@", info);
        NSURL * sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString * urlStr = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
//             UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
        [ImagePickerUtils exportVideoWithAsset:avAsset success:^(NSDictionary * _Nonnull resultDic) {
            // self.callback(@[ @{@"didVideoResponse": @[resultDic] } ]);
        } failure:^(NSString * _Nonnull errorMessage, NSError * _Nonnull error) {
            // self.callback(@[ @{@"errorState": @"videoExportFailure", @"msg":errorMessage } ]);
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- getter
- (UIImagePickerController *)picker {
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.allowsEditing = YES;
        _picker.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        // _picker.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        // _picker.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
    return _picker;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
