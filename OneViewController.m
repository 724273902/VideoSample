//
//  OneViewController.m
//  Vedioudio
//
//  Created by john wall on 17/11/19.
//  Copyright © 2017年 john wall. All rights reserved.
//

#import "OneViewController.h"
#import "TwoViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


#define kMusicFile  @"陈小春 - 相依为命.mp3"

@interface OneViewController ()<AVAudioPlayerDelegate>


@property(nonatomic,strong)AVAudioPlayer *audioPlayer;

@property(nonatomic,weak)IBOutlet UILabel *controlPanel;
@property(nonatomic,weak)IBOutlet UIProgressView *progress;
@property(nonatomic,weak)IBOutlet UILabel  *singer;
@property(nonatomic,weak)IBOutlet UIButton *playOrPause;


@property(nonatomic,weak)NSTimer *timer;
@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor greenColor];
   // [self playSound:@"videoRing.caf"];
    [self setupUI];
    
    UIButton *button =[[UIButton alloc]initWithFrame:CGRectMake(100, 200, 80, 80)];
    button.backgroundColor =[UIColor blueColor];
    [button setTitle:@"next view" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goMusicPlayer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    //[self resignFirstResponder];


}



//系统声音调用
void soundCompleteCallBack(SystemSoundID soundID,void * clientData){
    
    
    NSLog(@"播放完成");
}
-(void)playSound:(NSString *)name{


    NSString *audioFile =[[NSBundle mainBundle]pathForResource:name ofType:nil];
    //NSURL *fileUrl =[NSURL fileURLWithPath:audioFile];
    
    NSURL *fileUrl =[NSURL fileURLWithPath:audioFile];
    
    SystemSoundID soundID =0;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    //如需要播放完成执行一些操作，可以用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallBack, NULL);
    
  // AudioServicesPlayAlertSound(soundID);播放音效而且震动
    AudioServicesPlaySystemSound(soundID);

}


-(void)setupUI{

self.controlPanel.text =@"相依为命";
self.singer.text =@"陈小春";



    
}

-(NSTimer *)timer{


    if (!_timer) {
        _timer  =[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
    
}

-(AVAudioPlayer *)audioPlayer{

    if (!_audioPlayer) {
        NSString *urlStr =[[NSBundle mainBundle]
                           
                           pathForResource:kMusicFile ofType:nil];
        NSURL *url =[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        
        
        _audioPlayer =[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=1;
        _audioPlayer.delegate=self;
        
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"错误信息:%@",error.localizedDescription);
            return nil;
        }
        
        
        //设置后台播放模式
        AVAudioSession *audioSession =[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [audioSession setActive:YES error:nil];
        
       //  拔出耳机后，暂停播放
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    return _audioPlayer;
}

-(void)play{




    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play] ;
        self.timer.fireDate =[NSDate distantPast];
    }
}
-(void)pause{
    if ([self.audioPlayer isPlaying ] ) {
        [self.audioPlayer pause];
        self.timer.fireDate =[NSDate distantFuture];
    }


}

-(IBAction)playClick:(UIButton *)sender{

    if(sender.tag){
        sender.tag=0;
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        [self pause];
    }else{
        sender.tag=1;
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
        [self play];
    }
}

-(void)updateProgress{

    float progress =self.audioPlayer.currentTime/self.audioPlayer.duration;
    [self.progress setProgress:progress animated:YES];



}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    NSLog(@"音乐播放完成");
    //根据实际情况，可以关闭回话，其他音频可以继续播放
    [[AVAudioSession sharedInstance]setActive:NO error:nil];


}

-(void)routeChange:(NSNotification *)noti{

    NSDictionary *dic =noti.userInfo ;
    int changeReason =[dic[AVAudioSessionRouteChangeReasonKey]intValue];
    
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription  *route =dic[AVAudioSessionRouteChangePreviousRouteKey];
        
        AVAudioSessionPortDescription  *port =[route.outputs firstObject];
        //原设备为耳机暂停
        if ([port.portType isEqualToString:@"Headphones"]) {
            [self pause];
        }

    }


        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSLog(@"%@:%@",key,obj);
        }];
}





-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self    name:AVAudioSessionRouteChangeNotification object:nil];


}


-(void)goMusicPlayer{

    TwoViewController *two =[TwoViewController new];
    
    [self presentViewController:two animated:YES
                     completion:nil];



}



















@end
