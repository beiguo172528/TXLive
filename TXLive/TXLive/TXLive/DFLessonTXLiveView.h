//
//  DFLessonTXLiveView.h
//  iat3
//
//  Created by DOFAR on 2020/4/13.
//  Copyright © 2020 石庆磊. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LiveType) {
    LiveTypeNone,
    LiveTypeSmall,
    LiveTypeNomal,
    LiveTypeBig,
    LiveTypeClose,
};
#define BECOME_ACTIVE @"BECOME_ACTIVE"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

NS_ASSUME_NONNULL_BEGIN

@protocol DFLessonTXLiveViewDelegate <NSObject>
- (void)changeLiveType:(LiveType)type;
- (void)reloadVCSubViews;
- (void)refreshLivePlayView;
- (void)layout;
@end

@interface DFLessonTXLiveView : UIView
@property (nonatomic, weak) id<DFLessonTXLiveViewDelegate> delegate;
- (CGFloat)getHeight;
- (void)showWithFrame:(CGRect)rect withUrl:(NSString*)url;
- (void)changeLiveType:(LiveType)type;
- (void)setLiveType:(LiveType)type withFrame:(CGRect)rect;
- (void)deallocMediaPlayer;
- (LiveType)getLiveType;
- (void)changeScreenShot:(BOOL)isShow;
- (void)goBack;
- (void)playVideo;
- (void)isShowErrorMessage;
@end

NS_ASSUME_NONNULL_END
