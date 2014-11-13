//
//  PickerViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PickerViewShowStatusGroup = 0, // default display groups .
    PickerViewShowStatusSavePhotos
} PickerViewShowStatus;

@protocol PickerViewControllerDelegate <NSObject>

/**
 *  返回所有的图片对象
 */
- (void) pickerViewControllerDonePictures : (NSArray *) images;

@end

@interface PickerViewController : UIViewController

@property (nonatomic , weak) id<PickerViewControllerDelegate> delegate;
@property (nonatomic , assign) PickerViewShowStatus status;


@end
