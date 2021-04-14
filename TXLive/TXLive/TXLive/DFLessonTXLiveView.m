//
//  DFLessonTXLiveView.m
//  iat3
//
//  Created by DOFAR on 2020/4/13.
//  Copyright © 2020 石庆磊. All rights reserved.
//

#import "DFLessonTXLiveView.h"
#import <TXLivePlayer.h>
#import "Masonry.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define CACHE_TIME_FAST             1.0f
#define CACHE_TIME_SMOOTH           1.0f

@interface DFLessonTXLiveView()<UITextFieldDelegate,TXLivePlayListener>{
    LiveType    _type;
    LiveType    _oldType;
    BOOL        _isShowMessage;
    CGRect      _smallFrame;
    CGRect      _nomalFrame;
    BOOL        _isChangeFrame;
    UIDeviceOrientation _orientation;
    TX_Enum_PlayType     _playType;               // 播放类型
}
@property (weak, nonatomic) IBOutlet UIView *topHud;
@property (weak, nonatomic) IBOutlet UIStackView *bigSV;
@property (weak, nonatomic) IBOutlet UIStackView *nomalSV;
@property (weak, nonatomic) IBOutlet UILabel *liveLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeUnfoldBtn;
@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (strong, nonatomic) UIView *playView;
@property (strong, nonatomic) TXLivePlayer *txLivePlayer;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) UIActivityIndicatorView *activityIV;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation DFLessonTXLiveView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self addNotif];
    self.playView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.playView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMidView)];
    self.tapView.userInteractionEnabled = YES;
    [self.tapView addGestureRecognizer:tap];
    _isShowMessage = NO;
    _type = LiveTypeNomal;
    _oldType = LiveTypeNomal;
    _topHud.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotif{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

+ (CGFloat)getHeightWithType:(LiveType)type{
    switch (type) {
        case LiveTypeSmall:
            return 80;
        case LiveTypeNomal:
            return ScreenWidth*9/16;
        default:
            return ScreenWidth;
    }
}

- (CGFloat)getHeight{
    switch (_type) {
        case LiveTypeSmall:
            return 80;
        case LiveTypeNomal:
            return ScreenWidth*9/16;
        default:
            return ScreenWidth;
    }
}

- (void)showWithFrame:(CGRect)rect withUrl:(NSString*)url{
    self.frame = rect;
    _nomalFrame = rect;
    if ([self.url isEqualToString:url]) {
        return;
    }
    else if ([self isStringEmpty:self.url]){
        self.url = url;
        UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
        win.windowLevel = UIWindowLevelNormal;
        [win addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
            make.top.equalTo(@(0));
            make.height.equalTo(@(self->_nomalFrame.size.height));
        }];
        [self changeFrame:_type];
    }
    else {
        self.url = url;
        [self deallocMediaPlayer];
        [self changeFrame:_type];
    }
}

- (void)changeLiveType:(LiveType)type{
    [self changeFrame:type];
}

- (void)setLiveType:(LiveType)type withFrame:(CGRect)rect{
    if (type == LiveTypeSmall) {
        _smallFrame = rect;
    }
    else if (type == LiveTypeNomal){
        _nomalFrame = rect;
    }
}

- (void)isShowErrorMessage{
    _isShowMessage = YES;
}

- (LiveType)getLiveType{
    return _type;
}

#pragma mark - mediaPlayer
- (void)createMediaPlayer{
    if (!_txLivePlayer) {
        NSLog(@"mediaPlayer-url:%@",self.url);
        [self insertSubview:self.playView atIndex:0];
        self.txLivePlayer = [[TXLivePlayer alloc]init];
        TXLivePlayConfig* config = self.txLivePlayer.config;
//        config.enableMessage = YES;
        config.bAutoAdjustCacheTime = YES;
        config.minAutoAdjustCacheTime = CACHE_TIME_FAST;
        config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
        [self.txLivePlayer setConfig:config];
        [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
            make.top.equalTo(@(0));
            make.bottom.equalTo(@(0));
        }];
        self.txLivePlayer.delegate = self;
        [self.txLivePlayer setupVideoWidget:CGRectMake(0, 0, 10, 10) containView:self.playView insertIndex:0];
        [self.liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@(0));
            make.centerY.equalTo(@(0));
        }];
        if ([self checkPlayUrl:self.url]) {
            [self replayMedia];
        }
        
    }
}


- (void)changeFrame:(LiveType)type{
    if (![[[UIApplication sharedApplication] windows] firstObject]) {
        return;
    }
    if (!self || !self.superview) {
        return;
    }
    
    [self createMediaPlayer];
    if (!self.txLivePlayer || !self.playView) {
        return;
    }
    switch (type) {
        case LiveTypeSmall:{
//            self.frame = _smallFrame;
            [self.playView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(5));
                make.top.equalTo(@(5));
                make.bottom.equalTo(@(5));
                make.width.equalTo(@([self getHeight]*(16/9)));
            }];
            [self.liveLabel setHidden:NO];
            [self.liveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.playView.mas_right).offset(8);
                make.centerY.equalTo(@(0));
            }];
            [self.topHud setHidden:YES];
            [self.nomalSV setHidden:NO];
            [self hiddenLineView];
            break;
        }
        case LiveTypeNomal:{
//            self.frame = _nomalFrame;
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(0));
                make.right.equalTo(@(0));
                make.top.equalTo(@(self->_nomalFrame.origin.y));
                make.height.equalTo(@(self->_nomalFrame.size.height));
            }];
            [self.playView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(0));
                make.right.equalTo(@(0));
                make.top.equalTo(@(0));
                make.height.equalTo(@(self->_nomalFrame.size.height));
//                make.bottom.equalTo(@(0));
            }];
            [self.nomalSV setHidden:NO];
            [self.bigSV setHidden:YES];
            [self.topHud setHidden:YES];
            [self.liveLabel setHidden:NO];
            [self.liveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(16));
                make.top.equalTo(@(16));
            }];
            [self showLineView];
            break;
        }
        case LiveTypeBig:{
//            self.frame = [[UIScreen mainScreen]bounds];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(0));
                make.right.equalTo(@(0));
                make.top.equalTo(@(0));
                make.bottom.equalTo(@(0));
            }];
            [self.playView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(0));
                make.right.equalTo(@(0));
                make.top.equalTo(@(0));
                make.bottom.equalTo(@(0));
            }];
            [self.topHud setHidden:NO];
            [self.bigSV setHidden:NO];
            [self.nomalSV setHidden:YES];
            [self.liveLabel setHidden:YES];
            [self hiddenLineView];
            break;
        }
        default:
            break;
    }
    _type = type;
    [self layoutSubviews];
    [self layoutIfNeeded];
    [self showOrHidden];
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadVCSubViews)]) {
        [self.delegate reloadVCSubViews];
    }
//    [self.txLivePlayer setupVideoWidget:CGRectMake(0, 0, 10, 10) containView:self.playView insertIndex:0];
//    [self layoutMySubVs];
//    [self performSelector:@selector(layoutMySubVs) withObject:nil afterDelay:1];
}

- (void)layoutMySubVs{
    [self layoutSubviews];
}

- (void)reloadMediaPlayer{
    [self deallocMediaPlayer];
    [self removePlayNotif];
    [self changeFrame:_type];
    [self showLoadingView];
}

- (void)playOnceAgain{
    [self changeFrame:_type];
}

- (void)deallocMediaPlayer{
    if (self.txLivePlayer) {
        [self.txLivePlayer stopPlay];
        [self.playView removeFromSuperview];
        [self.txLivePlayer removeVideoWidget];
        self.txLivePlayer = nil;
    }
}

- (void)replayMedia{
    if (self.txLivePlayer) {
        int ret = [self.txLivePlayer startPlay:self.url type:_playType];
        if (ret != 0) {
            NSLog(@"播放器启动失败");
        }
        [self showLoadingView];
    }
}

- (void)showOrHidden{
//    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    if ([[app currentViewController] isKindOfClass:[LessonViewController class]]) {
//        [self setHidden:NO];
//    }
//    else {
//        [self setHidden:YES];
//    }
}


#pragma mark - Loading View
- (void)showLoadingView{
    if (!self.activityIV) {
        self.activityIV = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(ScreenWidth - 40, 10, 20, 20)];
        [self.activityIV startAnimating];
        self.activityIV.color = [UIColor colorWithRed:187/255.f green:187/255.f blue:187/255.f alpha:1];
        [self addSubview:self.activityIV];
        [self.activityIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@(0));
            make.centerY.equalTo(@(0));
        }];
    }
    [self.activityIV setHidden:NO];
}

- (void)endLoadingView{
    if (self.txLivePlayer && self.txLivePlayer.isPlaying) {
        [self.activityIV setHidden:YES];
    }
}

- (void)showLiveErrMessage{
    if (!_isShowMessage) {
        return;
    }
    _isShowMessage = NO;
    [SVProgressHUD showImage:[UIImage imageNamed:@"随便乱写"] status:NSLocalizedString(@"If the live broadcast is abnormal, please pull down or click refresh", nil)];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD dismissWithDelay:3];
}

- (void)showLineView{
    if (!self.lineView) {
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.lineView.backgroundColor = [UIColor colorWithRed:34.0/255.0f green:34.0/255.0f blue:34.0/255.0f alpha:1.0f];
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
            make.bottom.equalTo(@(0));
            make.height.equalTo(@(1));
        }];
    }
    [self.lineView setHidden:NO];
}

- (void)hiddenLineView{
    [self.lineView setHidden:YES];
}

#pragma mark - IJKFFMoviePlayerController Notif
- (void)addPlayNotif{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:BECOME_ACTIVE object:nil];
}

- (void)removePlayNotif{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BECOME_ACTIVE object:nil];
}


#pragma mark 后台前台切换
- (void)becomeActive:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = note.userInfo[@"BECOME_ACTIVE"];
        if ([str isEqualToString:@"YES"]) {
            [self refreshLive];
            
        }
        else if ([str isEqualToString:@"NO"]){
//            [self goBack];
            if (self->_type == LiveTypeBig) {
                [self onClickBackBtn:nil];
            }
            if (self.txLivePlayer) {
                [self.txLivePlayer stopPlay];
                [self.txLivePlayer removeVideoWidget];
            }
        }
    });
}

- (void)refreshLive {
    [self deallocMediaPlayer];
    [self removePlayNotif];
    [self changeFrame:_type];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshLivePlayView)]) {
//        [self.delegate refreshLivePlayView];
//    }
}

#pragma mark - 各个按钮点击
- (IBAction)onClickBackBtn:(id)sender {
    if (_type != LiveTypeBig) {
        return;
    }
    _isChangeFrame = YES;
    [self forceOrientationPortrait];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLiveType:)]) {
        [self.delegate changeLiveType:LiveTypeNomal];
    }
}


- (IBAction)onClickRefreshBtn:(id)sender {
    [self refreshLive];
}

- (IBAction)onClickBigBtn:(UIButton*)sender {
    _isChangeFrame = YES;
    [self forceOrientationLandscape];
    [self performSelector:@selector(forceOrientationLandscape) withObject:nil afterDelay:0.5];
//    [self forceOrientationLandscape];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLiveType:)]) {
        [self.delegate changeLiveType:LiveTypeBig];
    }
    [sender setEnabled:!sender.enabled];
    [self performSelector:@selector(changeBtnisEnable:) withObject:sender afterDelay:2.5];
}

- (void)changeBtnisEnable:(UIButton*)btn{
    [btn setEnabled:YES];
}

- (IBAction)onClickCloseBtn:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLiveType:)]) {
        [self.delegate changeLiveType:LiveTypeClose];
    }
}


- (IBAction)onClickChangeUnfold:(UIButton *)sender {
    _type = _type == LiveTypeNomal ? LiveTypeSmall : LiveTypeNomal;
    [self changeFrame:_type];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLiveType:)]){
        [self.delegate changeLiveType:_type];
    }
}

#pragma mark - 最大化相关
- (void)tapMidView{
    if (_type == LiveTypeBig) {
        [self.topHud setHidden:!self.topHud.isHidden];
    }
}

- (void)keyBoardWillShow:(NSNotification*)notif{
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {}];
}

- (void)keyBoardWillHide:(NSNotification*)notif{
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {}];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    textField.text = @"";
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - 屏幕方向
// 横屏 home键在右边
-(void)forceOrientationLandscape{
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=NO;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
    UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
    NSLog(@"orientChange->%ld",(long)orient);
    if (orient == UIDeviceOrientationLandscapeLeft) {
        _isChangeFrame = NO;
    }
    else if (orient == UIDeviceOrientationLandscapeRight){
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
    }
    else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
    [self layoutMy];
}
// 竖屏
- (void)forceOrientationPortrait{
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    appdelegate.isForceLandscape=NO;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
    //强制翻转屏幕
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
    [self layoutMy];
}

- (void)orientChange:(NSNotification*)notif{
    NSLog(@"-----orientChange-----:%ld",(long)[[UIDevice currentDevice] orientation]);
    _orientation = [[UIDevice currentDevice] orientation];
    if (!_isChangeFrame) {
        return;
    }
    _isChangeFrame = NO;
    [self layoutMy];
}

- (void)layoutMy{
    [self layoutWinView];
    [self performSelector:@selector(layoutWinView) withObject:nil afterDelay:0.3];
    [self layoutMySubVs];
    [self performSelector:@selector(layoutMySubVs) withObject:nil afterDelay:1];
    [self layoutIfNeeded];
}

- (void)layoutWinView{
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        _type = LiveTypeNomal;
        [self changeFrame:_type];
    } else{
        _oldType = _type;
        _type = LiveTypeBig;
        [self changeFrame:_type];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(layout)]) {
        [self.delegate layout];
    }
}

#pragma mark - 上层通知
- (void)changeScreenShot:(BOOL)isShow{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
        }];
    });
}

- (void)goBack{
    if (_type != LiveTypeBig) {
        return;
    }
//    if (self.mediaPlayer && self.mediaPlayer.isPlaying) {
//        [self.mediaPlayer pause];
//    }
//    [self onClickBackBtn:nil];
    [self performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:0.5];
//    [self performSelector:@selector(layoutIfNeeded) withObject:nil afterDelay:1];
}

- (void)playVideo{
    if (self.txLivePlayer && !self.txLivePlayer.isPlaying) {
        [self.txLivePlayer startPlay:self.url type:PLAY_TYPE_LIVE_RTMP];
    }
}

- (BOOL)checkPlayUrl:(NSString*)playUrl {
    if ([playUrl hasPrefix:@"rtmp:"]) {
        _playType = PLAY_TYPE_LIVE_RTMP;
    } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && ([playUrl rangeOfString:@".flv"].length > 0)) {
        _playType = PLAY_TYPE_LIVE_FLV;
    } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".m3u8"].length > 0) {
        _playType = PLAY_TYPE_VOD_HLS;
    } else{
        [SVProgressHUD showErrorWithStatus:@"播放地址不合法，直播目前仅支持rtmp,flv播放方式!"];
         [SVProgressHUD dismissWithDelay:1.5];
        return NO;
    }
    
    return YES;
}

#pragma mark - TXLivePlayListener

- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    NSDictionary *dict = param;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_BEGIN) {
            [self endLoadingView];
            NSLog(@"PLAY_EVT_PLAY_BEGIN");
            
        } else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END) {
            // 断开连接时，模拟点击一次关闭播放
//            [self clickPlay:_btnPlay];
            
            if (EvtID == PLAY_ERR_NET_DISCONNECT) {
                NSString *msg = (NSString*)[dict valueForKey:EVT_MSG];
//                [self toastTip:msg];
                NSLog(@"PLAY_ERR_NET_DISCONNECT msg:%@",msg);
            }
            else {
                NSLog(@"PLAY_EVT_PLAY_END");
            }
        } else if (EvtID == PLAY_EVT_PLAY_LOADING){
            [self showLoadingView];
            NSLog(@"PLAY_EVT_PLAY_LOADING");
        } else if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"PLAY_EVT_CONNECT_SUCC");
//            BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
//            if (!isWifi) {
//                __weak __typeof(self) weakSelf = self;
//                [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//                    if (weakSelf.playUrl.length == 0) {
//                        return;
//                    }
//                    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
//                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
//                                                                                       message:@"您要切换到Wifi再观看吗?"
//                                                                                preferredStyle:UIAlertControllerStyleAlert];
//                        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                            [alert dismissViewControllerAnimated:YES completion:nil];
//
//                            // 先停止，再重新播放
//                            [weakSelf stopPlay];
//                            [weakSelf startPlay];
//                        }]];
//                        [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                            [alert dismissViewControllerAnimated:YES completion:nil];
//                        }]];
//                        [weakSelf presentViewController:alert animated:YES completion:nil];
//                    }
//                }];
//            }
        }
        else if (EvtID == EVT_PLAY_GET_MESSAGE) {
            NSData* msgData = param[@"EVT_GET_MSG"];
            NSString* msg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
//            [self toastTip:msg];
            NSLog(@"EVT_PLAY_GET_MESSAGE msg:%@",msg);
        }
    });
}

- (void)onNetStatus:(NSDictionary *)param {
    
}

- (BOOL)isStringEmpty:(NSString *)string {
    if (string == nil) {
        return YES;
    }
    if ([string length] == 0) { //string is empty or nil
        return YES;
    }
    if (![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return YES;
    }
    return NO;
}

@end
