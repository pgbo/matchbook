//
//  UIImage+TDKit.h
//  tinyDict
//
//  Created by guangbool on 2017/4/21.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TDKit)

/**
 Create and return a 1x1 point size image with the given color.
 
 @param color  The color.
 */
+ (nullable UIImage *)imageWithColor:(nullable UIColor *)color;

/**
 Create and return a pure color image with the given color and size.
 
 @param color  The color.
 @param size   New image's type.
 */
+ (nullable UIImage *)imageWithColor:(nullable UIColor *)color size:(CGSize)size;

/**
 Tint the image in alpha channel with the given color.
 
 @param color  The color.
 */
- (nullable UIImage *)imageByTintColor:(nonnull UIColor *)color;

/**
 Returns a new rotated image (relative to the center).
 
 @param radians   Rotated radians in counterclockwise.⟲
 
 @param fitSize   YES: new image's size is extend to fit all content.
 NO: image's size will not change, content may be clipped.
 */
- (nullable UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

/**
 Returns a new image rotated counterclockwise by a quarter‑turn (90°). ⤺
 The width and height will be exchanged.
 */
- (nullable UIImage *)imageByRotateLeft90;

/**
 Returns a new image rotated clockwise by a quarter‑turn (90°). ⤼
 The width and height will be exchanged.
 */
- (nullable UIImage *)imageByRotateRight90;

/**
 Returns a new image rotated 180° . ↻
 */
- (nullable UIImage *)imageByRotate180;

/**
 Returns a vertically flipped image. ⥯
 */
- (nullable UIImage *)imageByFlipVertical;

/**
 Returns a horizontally flipped image. ⇋
 */
- (nullable UIImage *)imageByFlipHorizontal;


/**
 Draws the entire image in the specified rectangle, content changed with
 the contentMode.
 
 @discussion This method draws the entire image in the current graphics context,
 respecting the image's orientation setting. In the default coordinate system,
 images are situated down and to the right of the origin of the specified
 rectangle. This method respects any transforms applied to the current graphics
 context, however.
 
 @param rect        The rectangle in which to draw the image.
 
 @param contentMode Draw content mode
 
 @param clips       A Boolean value that determines whether content are confined to the rect.
 */
- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

/**
 Returns a new image which is scaled from this image.
 The image will be stretched as needed.
 
 @param size  The new size to be scaled, values should be positive.
 
 @return      The new image with the given size.
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size;

/**
 Returns a new image which is scaled from this image.
 The image content will be changed with thencontentMode.
 
 @param size        The new size to be scaled, values should be positive.
 
 @param contentMode The content mode for image content.
 
 @return The new image with the given size.
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

@end
