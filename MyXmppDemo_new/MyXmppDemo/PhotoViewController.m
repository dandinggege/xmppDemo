//
//  PhotoViewController.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/8.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "PhotoViewController.h"

#import "MyMusicPlayer.h"

#import "MyUIFactory.h"

#import "XMPPManager.h"

@interface PhotoViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImgV;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTF;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - 用户按钮 -

- (IBAction)choosePhotoBtnClicked:(id)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[MyMusicPlayer player]playWater0];
    UIAlertController * alertC=[UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //
    __weak typeof(self) weakSelf = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction * cameraBtn=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showPictureView:0];
        }];
        [alertC addAction: cameraBtn];
    }
    UIAlertAction * pictureBtn=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [weakSelf showPictureView:1];
    }];
    [alertC addAction:pictureBtn];
    UIAlertAction * cancelBtn=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
    }];
    [alertC addAction:cancelBtn];
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

- (IBAction)updataPhotoBtnClicked:(id)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[MyMusicPlayer player]playWater0];
    if (self.nickNameTF.text==nil ||
        [self.nickNameTF.text isEqualToString:@""]) {
        [MyUIFactory showMsg:@"请输入昵称" withVC:self];
        return;
    }
    [[XMPPManager manager]updateHeadImage:[MyUIFactory scaleImage:[UIImage imageNamed:@"headPhoto.png"] toSize:CGSizeMake(120, 120)] name:nil nickName:self.nickNameTF.text email:nil address:nil];
}


#pragma mark - 辅助方法 -

//显示照片选择
-(void)showPictureView:(int)flag{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 判断是否支持相机
    if (flag==0)
        sourceType = UIImagePickerControllerSourceTypeCamera;
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    // 展示
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}


#pragma mark - 用户选择了图片的代理方法 -

//获取到照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    self.photoImgV.image=image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
