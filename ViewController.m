//
//  ViewController.m
//  Vedioudio
//
//  Created by john wall on 17/11/17.
//  Copyright © 2017年 john wall. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"
#import  "fiveViewController.h"
#import "fourViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController (){


    AVPlayer *player;


}
@property (nonatomic, strong) MPMoviePlayerController *playerController;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 120, 100);
    button.backgroundColor =[UIColor blueColor];
    [button setTitle:@"AVPlayer" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(demo1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(240, 100, 100, 100);
    button1.backgroundColor =[UIColor blueColor];
    [button1 setTitle:@"控制器" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(demo2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 100, 80, 80);
    button2.backgroundColor =[UIColor redColor];
    [button2 setTitle:@"one" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(0, 350, 100, 100);
    button3.backgroundColor =[UIColor redColor];
    [button3 setTitle:@"four" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(gofourView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(120, 350, 100, 100);
    button4.backgroundColor =[UIColor redColor];
    [button4 setTitle:@"five" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(gofiveView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)demo1{
    
    
    NSString *str = [[NSBundle mainBundle] pathForResource:@"loginmovie" ofType:@"mp4"];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"loginmovie.mp4" ofType:@"mp4"];
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"loginmovie.mp4" withExtension:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:str]];
    //2、创建播放器
    player = [AVPlayer playerWithPlayerItem:playerItem];

    
    //3.创建视频显示的图层
    AVPlayerLayer *layer =[AVPlayerLayer playerLayerWithPlayer:player];
    
    layer.frame =self.view.frame;
    [self.view.layer addSublayer:layer];
    
    
    //播放视频
    [player play];
    
    //获得播放结束的状态 -> 通过发送通知的形式获得 ->AVPlayerItemDidPlayToEndTimeNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //只要可以获得到当前视频元素准备好的状态 就可以得到总时长
    //采取KVO的形式获得视频总时长
    //通过监视status 判断是否准备好 -> 获得
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    

}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    
    NSLog(@"%@",change[@"new"]);
    
  AVPlayerItemStatus status = [change[@"new"] integerValue];
  switch (status) {
    case AVPlayerItemStatusUnknown: {
        NSLog(@"未知状态");
        break;
    }
    case AVPlayerItemStatusReadyToPlay: {
        NSLog(@"视频的总时长%f", CMTimeGetSeconds(player.currentItem.duration));
        
        break;
    }
    case AVPlayerItemStatusFailed: {
        NSLog(@"加载失败");
        break;
    }
}
}
//    快进
    -( void)moved{
        //快进
        //跳到某一个进度的方法：seekToTime:
        //得到当前的时间 + 快进的时间
        
        
        //获得当前播放的时间 （秒）
        Float64 cur =  CMTimeGetSeconds(player.currentTime);
        cur ++;
        [player seekToTime:CMTimeMake(cur, 1)];
        
    }

   

    -(void)itemDidPlayToEndTime:(NSNotification *)not{
        NSLog(@"播放结束");
        [player seekToTime:kCMTimeZero];
        
    }



-(void)demo2{
    
    //1、创建AVPlayer
    /*
     本地视频
     NSURL *url = [[NSBundle mainBundle]URLForResource:@"IMG_9638.m4v" withExtension:nil];
     AVPlayer *player = [AVPlayer playerWithURL:url];
     */
    //网页视频
    NSString *str = [[NSBundle mainBundle] pathForResource:@"loginmovie" ofType:@"mp4"];
    NSURL *url = [NSURL URLWithString:@"http://v1.mukewang.com/19954d8f-e2c2-4c0a-b8c1-a4c826b5ca8b/L.mp4"];
    
    
    AVPlayer *player1 = [AVPlayer playerWithURL:url];
    //2、创建视频播放视图的控制器
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
    
    //3、将创建的AVPlayer赋值给控制器自带的player
    playerVC.player = player1;
    
    //4、跳转到控制器播放
    [self presentViewController:playerVC animated:YES completion:nil];
    
    [playerVC.player play];
    
    
    
    
    
    
    }







- (MPMoviePlayerController *)playerController
{
    if (_playerController == nil) {
        
        // 1.创建视频的资源
        NSURL *url = [NSURL URLWithString:@"http://v1.mukewang.com/19954d8f-e2c2-4c0a-b8c1-a4c826b5ca8b/L.mp4"];
        
        // 2.创建播放器
        _playerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
        _playerController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
        [self.view addSubview:_playerController.view];
        
        // 3.取消工具栏
        _playerController.controlStyle = MPMovieControlStyleNone;
        
    }
    return _playerController;
}




-(void)goNextView{

    OneViewController *OneView  =[[OneViewController alloc]init];
    
[self presentViewController:OneView animated:YES
                 completion:nil];



}
-(void)gofourView{
    
    fourViewController *View4  =[[fourViewController alloc]init];
    
    [self presentViewController:View4 animated:YES
                     completion:nil];
    
    
    
}



-(void)gofiveView{
    
    fiveViewController *View5  =[[fiveViewController alloc]init];
    
    [self presentViewController:View5 animated:YES
                     completion:nil];
    
    
    
}


















@end
