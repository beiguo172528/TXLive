//
//  ViewController.m
//  TXLive
//
//  Created by DOFAR on 2021/4/14.
//

#import "ViewController.h"
#import "DFLessonTXLiveView.h"

@interface ViewController ()<DFLessonTXLiveViewDelegate>
@property (nonatomic, strong) DFLessonTXLiveView  *rtmpLiveView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onClickBtn:(id)sender {
    self.rtmpLiveView = [[NSBundle mainBundle]loadNibNamed:@"DFLessonTXLiveView" owner:self options:nil].firstObject;
    self.rtmpLiveView.delegate = self;
    [self.rtmpLiveView showWithFrame:CGRectMake(0, 44, ScreenWidth, [self.rtmpLiveView getHeight]) withUrl:@"rtmp://58.200.131.2:1935/livetv/hunantv"];
}

- (void)deallocPlayerView{
    if (!self.rtmpLiveView) {
        return;
    }
    else {
        [self.rtmpLiveView goBack];
        [self.rtmpLiveView deallocMediaPlayer];
        [self.rtmpLiveView removeFromSuperview];
        self.rtmpLiveView = nil;
    }
}


- (void)changeLiveType:(LiveType)type{
    switch (type) {
        case LiveTypeBig:
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            break;
        case LiveTypeClose:
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            [self.rtmpLiveView setHidden:YES];
            [self deallocPlayerView];
        default:
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            break;
    }
    
    if (self.rtmpLiveView) {
        [self.rtmpLiveView performSelector:@selector(playVideo) withObject:nil afterDelay:1];
    }
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    [win layoutIfNeeded];
}

- (void)reloadVCSubViews{}
- (void)refreshLivePlayView{}
- (void)layout{}

@end
