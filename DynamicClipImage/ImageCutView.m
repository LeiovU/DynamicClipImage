//
//  ImageCutView.m
//  DynamicClipImage
//
//  Created by fangcy on 2019/6/11.
//  Copyright © 2019年 csii. All rights reserved.
//

#import "ImageCutView.h"
#import "UIImage+Util.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation ImageCutView {
    UIView *_mImageBgView;
}

-(instancetype)init {
    if (self = [super init]) {
        [self initUI];
        return self;
    }
    return nil;
}

-(void)initUI {
    self.backgroundColor = [UIColor blackColor];
}

-(void)showCoverViewWithTargetImg {
    [_mImageBgView setBackgroundColor:[UIColor clearColor]];
    float scaleValue = [self getScaleNum:_mTargetImage];
    _mTargetImage = [self scaleImage:_mTargetImage toScale:scaleValue];
    if (_mTargetImage != nil)
    {
        _mImageBgView = [[UIImageView alloc] initWithImage:_mTargetImage];
    }
    float _imageScale = self.frame.size.width / _mTargetImage.size.width;
    _mImageBgView.frame = CGRectMake(0, 0, _mTargetImage.size.width*_imageScale, _mTargetImage.size.height*_imageScale);
    _originalImageViewSize = CGSizeMake(_mTargetImage.size.width*_imageScale, _mTargetImage.size.height*_imageScale);
    _mImageBgView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    [self addSubview:_mImageBgView];
    [self addCoverView];
    [self setUserGesture];

}

- (void)addCoverView{
    UIImageView * coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    UIImage * image = [UIImage imageNamed:@"zhezhao"];
    image = [image resizeImageWithTop:0.9 andLeft:0 andBottom:0.95 andRight:0];
    coverImage.image = image;
    [self addSubview:coverImage];
}

-(void) setUserGesture
{
    [_mImageBgView setUserInteractionEnabled:YES];
    //添加移动手势
    UIPanGestureRecognizer *moveGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    [moveGes setMinimumNumberOfTouches:1];
    [moveGes setMaximumNumberOfTouches:1];
    [_mImageBgView addGestureRecognizer:moveGes];
    //添加缩放手势
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    [_mImageBgView addGestureRecognizer:scaleGes];
    //    //添加旋转手势
    UIRotationGestureRecognizer *rotateGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
    [_mImageBgView addGestureRecognizer:rotateGes];
}

float _lastTransX = 0.0, _lastTransY = 0.0;
- (void)moveImage:(UIPanGestureRecognizer *)sender
{
    CGPoint translatedPoint = [sender translationInView:self];
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        _lastTransX = 0.0;
        _lastTransY = 0.0;
    }
    
    CGAffineTransform trans = CGAffineTransformMakeTranslation(translatedPoint.x - _lastTransX, translatedPoint.y - _lastTransY);
    CGAffineTransform newTransform = CGAffineTransformConcat(_mImageBgView.transform, trans);
    _lastTransX = translatedPoint.x;
    _lastTransY = translatedPoint.y;
    
    if ([self isCanMove:newTransform])
    {
        _mImageBgView.transform = newTransform;
    }
    
}


float _lastScale = 1.0;
- (void)scaleImage:(UIPinchGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateBegan) {
        
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = [sender scale]/_lastScale;
    
    CGAffineTransform currentTransform = _mImageBgView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [_mImageBgView setTransform:newTransform];
    
    _lastScale = [sender scale];
}

float _lastRotation = 0.0;
- (void)rotateImage:(UIRotationGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateEnded) {
        
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = -_lastRotation + [sender rotation];
    
    CGAffineTransform currentTransform = _mImageBgView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    [_mImageBgView setTransform:newTransform];
    
    _lastRotation = [sender rotation];
    
}


/***
 方法名称：cutImageWithSpecificRect
 方法用途：根据特定的区域对图片进行裁剪
 方法说明：核心裁剪方法CGImageCreateWithImageInRect(CGImageRef image,CGRect rect)
 ***/
-(UIImage*) cutImageWithSpecificRect:(CGRect)frame;
{
    float zoomScale = [[_mImageBgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    float rotate = [[_mImageBgView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    float _imageScale = _mTargetImage.size.width/_originalImageViewSize.width;
    //裁剪区域的Size
    // CGSize cropSize = CGSizeMake(320.0/zoomScale, 120.0/zoomScale);
    CGSize cropSize = CGSizeMake(frame.size.width/zoomScale, frame.size.height/zoomScale);
    //裁剪区域的Origin
    // CGPoint cropperViewOrigin = CGPointMake((0.0 - _mCameraBgView.frame.origin.x)/zoomScale,
    //                                         ((JYScreen_height - _ImgCutHeight)/2 - _mCameraBgView.frame.origin.y)/zoomScale);
    CGPoint cropperViewOrigin = CGPointMake((0.0 - _mImageBgView.frame.origin.x + frame.origin.x)/zoomScale,
                                            (-_mImageBgView.frame.origin.y)/zoomScale + frame.origin.y/zoomScale);
    
    if((NSInteger)cropSize.width % 2 == 1)
    {
        cropSize.width = ceil(cropSize.width);
    }
    if((NSInteger)cropSize.height % 2 == 1)
    {
        cropSize.height = ceil(cropSize.height);
    }
    
    CGRect CropRectinImage = CGRectMake((NSInteger)(cropperViewOrigin.x*_imageScale) ,(NSInteger)( cropperViewOrigin.y*_imageScale), (NSInteger)(cropSize.width*_imageScale),(NSInteger)(cropSize.height*_imageScale));
    
    UIImage *rotInputImage = [_mTargetImage imageRotatedByRadians:rotate];
    CGImageRef tmp = CGImageCreateWithImageInRect([rotInputImage CGImage], CropRectinImage);
    self.mResultImage = [UIImage imageWithCGImage:tmp scale:_mTargetImage.scale orientation:_mTargetImage.imageOrientation];
    CGImageRelease(tmp);
    return self.mResultImage;
}

-(BOOL) isCanMove:(CGAffineTransform ) newTransform
{
    if (_mImageBgView.frame.size.height/2  - fabs(newTransform.ty)<=0 ||
        _mImageBgView.frame.size.width/2 - fabs(newTransform.tx)  <=0)
    {
        return NO;
        
    } else
    {
        return YES;
    }
    
}

/***
 方法名称：scaleImage:toScale:
 方法用途：图片的伸缩处理
 方法说明：scaleSize:放大或缩小的倍数
 ***/
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
/***
 方法名称：getScaleNum:
 方法用途：根据图片的宽度为基准，来获取图片伸缩放大的倍数
 方法说明：
 ***/
-(float) getScaleNum:(UIImage *) targetImg
{
    CGRect r = [UIScreen mainScreen].bounds;
    float preWidth = targetImg.size.width;
    float scaleValue = 1;
    
    scaleValue = r.size.width/preWidth;
    
    return scaleValue;
}
//图片复原
- (void)reset
{
    _mImageBgView.transform = CGAffineTransformIdentity;
}




@end
