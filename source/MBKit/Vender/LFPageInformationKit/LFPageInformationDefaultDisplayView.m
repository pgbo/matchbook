//
//  LFPageInformationDefaultDisplayView.m
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import "LFPageInformationDefaultDisplayView.h"

@implementation LFPageInformationDefaultDisplayView

- (instancetype)initWithFrame:(CGRect)frame layout:(LFPageInformationDefaultDisplayViewLayout *)layout
{
    if (self = [super initWithFrame:frame]) {
        _layout = layout;
        _lfpi_hideBeforeAddIntoContainerView = YES;
        _lfpi_aliginCenter = YES;
        _lfpi_removeFromSuperViewWhenHide = YES;
        [self setupDefaultDisplayView];
    }
    return self;
}

- (void)updateTextLabelPreferredMaxLayoutWidth
{
    _textLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.frame) - _layout.textLabelInsets.left - _layout.textLabelInsets.right;
}

- (void)setupDefaultDisplayView
{
    _imageView = [[UIImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
    
    _textLabel = [[UILabel alloc]init];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.numberOfLines = 0;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textLabel];
    
    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actionButton.layer.cornerRadius = 4;
    _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_actionButton];
    
    NSDictionary *views = @{@"imageView":_imageView,
                            @"textLabel":_textLabel,
                            @"actionButton":_actionButton};
    NSDictionary *metrics = @{@"imageTop":@( _layout.imageViewInsets.top),
                              @"labelTop":@(_layout.imageViewInsets.bottom + _layout.textLabelInsets.top),
                              @"buttonTop":@(_layout.textLabelInsets.bottom + _layout.actionButtonInsets.top),
                              @"imageLeading":@(_layout.imageViewInsets.left),
                              @"imageTrailing":@(_layout.imageViewInsets.right),
                              @"labelLeading":@(_layout.textLabelInsets.left),
                              @"labelTrailing":@(_layout.textLabelInsets.right),
                              @"buttonLeading":@(_layout.actionButtonInsets.left),
                              @"buttonTrailing":@(_layout.actionButtonInsets.right),
                              @"imageHeight":@(_layout.imageViewHeight),
                              @"buttonHeight":@(_layout.actionButtonHeight)};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-imageTop-[imageView(imageHeight)]-labelTop-[textLabel]-buttonTop-[actionButton(buttonHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-imageLeading-[imageView]-imageTrailing-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-labelLeading-[textLabel]-labelTrailing-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-buttonLeading-[actionButton]-buttonTrailing-|" options:0 metrics:metrics views:views]];
    
    [self updateTextLabelPreferredMaxLayoutWidth];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateTextLabelPreferredMaxLayoutWidth];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateTextLabelPreferredMaxLayoutWidth];
}

#pragma mark - LFPageInformationDisplayView

- (CGSize)lfpi_intrinsicContentSize
{
    CGFloat height = 0;
    height += _layout.imageViewInsets.top;
    height += _layout.imageViewHeight;
    height += _layout.imageViewInsets.bottom;
    height += _layout.textLabelInsets.top;
    // 计算label 高度
    height += [_textLabel intrinsicContentSize].height;
    height += _layout.textLabelInsets.bottom;
    height += _layout.actionButtonInsets.top;
    height += _layout.actionButtonHeight;
    height += _layout.actionButtonInsets.bottom;
    
    return CGSizeMake(CGRectGetWidth(self.bounds), height);
}

@end


@implementation LFPageInformationDefaultDisplayViewLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _imageViewInsets = [aDecoder decodeUIEdgeInsetsForKey:NSStringFromSelector(@selector(imageViewInsets))];
        _imageViewHeight = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(imageViewHeight))];
        _textLabelInsets = [aDecoder decodeUIEdgeInsetsForKey:NSStringFromSelector(@selector(textLabelInsets))];
        _actionButtonInsets = [aDecoder decodeUIEdgeInsetsForKey:NSStringFromSelector(@selector(actionButtonInsets))];
        _actionButtonHeight = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(actionButtonHeight))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeUIEdgeInsets:_imageViewInsets forKey:NSStringFromSelector(@selector(imageViewInsets))];
    [aCoder encodeFloat:_imageViewHeight forKey:NSStringFromSelector(@selector(imageViewHeight))];
    [aCoder encodeUIEdgeInsets:_textLabelInsets forKey:NSStringFromSelector(@selector(textLabelInsets))];
    [aCoder encodeUIEdgeInsets:_actionButtonInsets forKey:NSStringFromSelector(@selector(actionButtonInsets))];
    [aCoder encodeFloat:_actionButtonHeight forKey:NSStringFromSelector(@selector(actionButtonHeight))];
}

- (id)copyWithZone:(NSZone *)zone
{
    LFPageInformationDefaultDisplayViewLayout *copyItem = [[LFPageInformationDefaultDisplayViewLayout allocWithZone:zone]init];
    copyItem.imageViewInsets = _imageViewInsets;
    copyItem.imageViewHeight = _imageViewHeight;
    copyItem.textLabelInsets = _textLabelInsets;
    copyItem.actionButtonInsets = _actionButtonInsets;
    copyItem.actionButtonHeight = _actionButtonHeight;
    return copyItem;
}

@end
