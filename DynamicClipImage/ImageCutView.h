//
//  ImageCutView.h
//  DynamicClipImage
//
//  Created by fangcy on 2019/6/11.
//  Copyright © 2019年 csii. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCutView : UIView

@property (nonatomic,strong) UIImage * mTargetImage;
@property (nonatomic,strong) UIImage * mResultImage;
@property (nonatomic,assign) CGFloat ImgCutHeight;
@property (nonatomic,assign) CGSize originalImageViewSize;

-(void) showCoverViewWithTargetImg;

//frame 相对于当前屏幕坐标 当前屏幕当中的裁剪范围
-(UIImage*) cutImageWithSpecificRect:(CGRect)frame;


@end

NS_ASSUME_NONNULL_END
