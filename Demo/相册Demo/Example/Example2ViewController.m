//
//  Example2ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-4-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example2ViewController.h"
#import "UIImage+ZLPhotoLib.h"
#import "ZLPhoto.h"
#import "UIButton+WebCache.h"

@interface Example2ViewController () <ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic , strong) NSMutableArray *assets;
@property (nonatomic , strong) NSMutableArray *photos;

@property (weak,nonatomic) UIScrollView *scrollView;

@end

@implementation Example2ViewController

- (NSMutableArray *)assets{
    if (!_assets) {
        
        NSArray *urls = @[
                          @"http://imgsrc.baidu.com/forum/w%3D580/sign=515dae6de7dde711e7d243fe97eecef4/6c236b600c3387446fc73114530fd9f9d72aa05b.jpg",
                          @"http://imgsrc.baidu.com/forum/w%3D580/sign=1875d6474334970a47731027a5cbd1c0/51e876094b36acaf9e7b88947ed98d1000e99cc2.jpg",
                          @"http://imgsrc.baidu.com/forum/w%3D580/sign=67ef9ea341166d223877159c76230945/e2f7f736afc3793138419f41e9c4b74543a911b7.jpg",
                          @"http://imgsrc.baidu.com/forum/w%3D580/sign=a18485594e086e066aa83f4332087b5a/4a110924ab18972bcd1a19a2e4cd7b899e510ab8.jpg",
                          @"http://imgsrc.baidu.com/forum/w%3D580/sign=42d17a169058d109c4e3a9bae159ccd0/61f5b2119313b07e550549600ed7912397dd8c21.jpg",
                          ];
        
        _assets = urls.mutableCopy;
        
        for (NSString *url in urls) {
            ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
            photo.photoURL = [NSURL URLWithString:url];
            [self.photos addObject:photo];
        }
    }
    return _assets;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photos = @[].mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    // 这个属性不能少
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    [self.view addSubview:scrollView];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView = scrollView;
    
    // 属性scrollView
    [self reloadScrollView];
}

- (void)reloadScrollView{
    
    // 先移除，后添加
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger column = 3;
    // 加一是为了有个添加button
    NSUInteger assetCount = self.assets.count + 1;
    
    CGFloat width = self.view.frame.size.width / column;
    for (NSInteger i = 0; i < assetCount; i++) {
        
        NSInteger row = i / column;
        NSInteger col = i % column;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake(width * col, row * width, width, width);
        
        // UIButton
        if (i == self.assets.count){
            // 最后一个Button
            [btn setImage:[UIImage ml_imageFromBundleNamed:@"camera"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(takeCamera) forControlEvents:UIControlEventTouchUpInside];
        }else{
            // 如果是本地ZLPhotoAssets就从本地取，否则从网络取
            if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLCamera class]]) {
                [btn setImage:[self.assets[i] thumbImage] forState:UIControlStateNormal];
            }else if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]]) {
                [btn setImage:[self.assets[i] thumbImage] forState:UIControlStateNormal];
            }else if ([self.assets[i] isKindOfClass:[NSString class]]){
                [btn sd_setImageWithURL:[NSURL URLWithString:self.assets[i]] forState:UIControlStateNormal];
            }else if([self.assets[i] isKindOfClass:[ZLPhotoPickerBrowserPhoto class]]){
                ZLPhotoPickerBrowserPhoto *photo = self.assets[i];
                photo.toView = btn.imageView;
                [btn sd_setImageWithURL:photo.photoURL forState:UIControlStateNormal];
            }
            btn.tag = i;
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.scrollView addSubview:btn];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY([[self.scrollView.subviews lastObject] frame]));
}

#pragma mark - 选择图片
- (void)takeCamera{
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    // MaxCount, Default = 9
    // CallBack
    cameraVc.callback = ^(NSArray *status){
        
        self.assets = status.mutableCopy;
        [self reloadScrollView];
        
        for (ZLPhotoAssets *asset in status) {
            ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
            if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
                photo.asset = asset;
            }else if ([asset isKindOfClass:[ZLCamera class]]){
                ZLCamera *camera = (ZLCamera *)asset;
                photo.thumbImage = [camera thumbImage];
            }
            [self.photos addObject:photo];
        }
    };
    [cameraVc showPickerVc:self];
}

- (void)tapBrowser:(UIButton *)btn{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 数据源/delegate
    pickerBrowser.photos = self.photos;
    // 能够删除
    pickerBrowser.delegate = self;
    // 当前选中的值
    pickerBrowser.currentIndex = indexPath.row;
    // 展示控制器
    [pickerBrowser showPickerVc:self];
}

@end
