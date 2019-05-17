//
//  MBDataRequestStatusView.m
//  matchbook
//
//  Created by guangbool on 2017/6/27.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBDataRequestStatusView.h"
#import "Masonry.h"

@interface MBDataRequestStatusView ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *textLabel;

@end

@implementation MBDataRequestStatusView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (void)configureViews {
    [self addSubview:self.imageView];
    [self addSubview:self.textLabel];
    
    MBDataRequestStatusViewLayout *layout = [self.layout copy];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(layout.imageViewInsets.top);
        make.leading.mas_equalTo(layout.imageViewInsets.left);
        make.trailing.mas_equalTo(-layout.imageViewInsets.right);
        make.height.mas_equalTo(layout.imageViewHeight);
    }];
    
    __weak typeof(self)weakSelf = self;
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imageView.mas_bottom).offset(layout.imageViewInsets.bottom + layout.textLabelInsets.top);
        make.leading.mas_equalTo(layout.textLabelInsets.left);
        make.trailing.mas_equalTo(-layout.textLabelInsets.right);
    }];
    
    [self updateTextLabelPreferredMaxLayoutWidth];
}

- (void)updateTextLabelPreferredMaxLayoutWidth {
    MBDataRequestStatusViewLayout *layout = [self.layout copy];
    CGFloat pml_width = layout.width - (layout.textLabelInsets.left + layout.textLabelInsets.right);
    if (pml_width < 0) pml_width = 0;
    _textLabel.preferredMaxLayoutWidth = pml_width;
}

- (void)setLayout:(MBDataRequestStatusViewLayout *)layout {
    _layout = [layout copy];
    
    [_imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(layout.imageViewInsets.top);
        make.leading.mas_equalTo(layout.imageViewInsets.left);
        make.trailing.mas_equalTo(-layout.imageViewInsets.right);
        make.height.mas_equalTo(layout.imageViewHeight);
    }];
    
    __weak typeof(self)weakSelf = self;
    [_textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imageView.mas_bottom).offset(layout.imageViewInsets.bottom + layout.textLabelInsets.top);
        make.leading.mas_equalTo(layout.textLabelInsets.left);
        make.trailing.mas_equalTo(-layout.textLabelInsets.right);
    }];
    
    [self updateTextLabelPreferredMaxLayoutWidth];
    [self invalidateIntrinsicContentSize];
}

- (void)invalidateIntrinsicContentSize {
    [super invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    MBDataRequestStatusViewLayout *layout = [self.layout copy];
    CGFloat w = layout.width;
    CGFloat h = 0;
    h += layout.imageViewInsets.top;
    h += layout.imageViewHeight;
    h += layout.imageViewInsets.bottom;
    h += layout.textLabelInsets.top;
    h += [_textLabel intrinsicContentSize].height;
    h += layout.textLabelInsets.bottom;
    return CGSizeMake(w, h);
}

@end

@implementation MBDataRequestStatusViewLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _width = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(width))];
        _imageViewInsets = [aDecoder decodeUIEdgeInsetsForKey:NSStringFromSelector(@selector(imageViewInsets))];
        _imageViewHeight = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(imageViewHeight))];
        _textLabelInsets = [aDecoder decodeUIEdgeInsetsForKey:NSStringFromSelector(@selector(textLabelInsets))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:_width forKey:NSStringFromSelector(@selector(width))];
    [aCoder encodeUIEdgeInsets:_imageViewInsets forKey:NSStringFromSelector(@selector(imageViewInsets))];
    [aCoder encodeFloat:_imageViewHeight forKey:NSStringFromSelector(@selector(imageViewHeight))];
    [aCoder encodeUIEdgeInsets:_textLabelInsets forKey:NSStringFromSelector(@selector(textLabelInsets))];
}

- (id)copyWithZone:(NSZone *)zone
{
    MBDataRequestStatusViewLayout *copyItem = [[MBDataRequestStatusViewLayout allocWithZone:zone]init];
    copyItem.width = _width;
    copyItem.imageViewInsets = _imageViewInsets;
    copyItem.imageViewHeight = _imageViewHeight;
    copyItem.textLabelInsets = _textLabelInsets;
    return copyItem;
}

@end
