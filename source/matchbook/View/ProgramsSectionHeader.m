//
//  ProgramsSectionHeader.m
//  matchbook
//
//  Created by 彭光波 on 2017/6/24.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ProgramsSectionHeader.h"
#import <MBKit/UIImage+TDKit.h>
#import <MBKit/MBSpecs.h>
#import <MBKit/Masonry.h>

@interface ProgramsSectionHeader ()

@property (nonatomic) UIButton *titleButn;

@end

@implementation ProgramsSectionHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    [self.contentView addSubview:self.titleButn];
    [self.titleButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo([ProgramsSectionHeader intrinsicHeight]);
    }];
}

- (UIButton *)titleButn {
    if (!_titleButn) {
        _titleButn = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButn.enabled = NO;
        UIImage *bgImg = [UIImage imageNamed:@"opaque_rounded_rect_bg"];
        [_titleButn setBackgroundImage:bgImg forState:UIControlStateDisabled];
        [_titleButn setTitleColor:[MBColorSpecs app_minorTextColor] forState:UIControlStateDisabled];
        _titleButn.titleLabel.font = [MBFontSpecs small];
        [_titleButn setContentEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    }
    return _titleButn;
}

- (void)setTitleText:(NSString *)title {
    [_titleButn setTitle:title forState:UIControlStateDisabled];
}

+ (CGFloat)defaultHeight {
    return 48.f;
}

+ (CGFloat)intrinsicHeight {
    return 22.f;
}

@end
