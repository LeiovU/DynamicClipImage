//
//  UIImage+Util.h
//  DynamicClipImage
//
//  Created by fangcy on 2019/6/11.
//  Copyright © 2019年 csii. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Util)

//设置的外围不变形内部平铺拉伸
- (UIImage*)resizeImageWithTop:(CGFloat)top andLeft:(CGFloat)left andBottom:(CGFloat)bottom andRight:(CGFloat)right;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end

NS_ASSUME_NONNULL_END
