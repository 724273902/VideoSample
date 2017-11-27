//
//  fiveViewController.m
//  Vedioudio
//
//  Created by john wall on 17/11/20.
//  Copyright © 2017年 john wall. All rights reserved.
//

#import "fiveViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface fiveViewController ()


@property(nonatomic,strong)AVPlayer *player;




@property (weak, nonatomic) IBOutlet UIView *viewMovie;


@property (weak, nonatomic) IBOutlet UIButton*playorpause;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;


@end

@implementation fiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//self.view.backgroundColor =[UIColor grayColor];
    
    [self setupUI    ];
 

}

-(void)dealloc{
    [self removeObserverFromPlayerItem:_player.currentItem];
    [self removeNotification];
}


-(void)setupUI{

    AVPlayerLayer *playerlayer=[AVPlayerLayer  playerLayerWithPlayer:_player];
    playerlayer.frame= self.viewMovie.frame;
    playerlayer.videoGravity=AVLayerVideoGravityResizeAspect;
    
    [self.viewMovie.layer addSublayer:playerlayer];
    
    
    
    
 
    
    
    //播放视频
    [_player play];

}


-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *item =[self getplayItem  ];
        _player =[AVPlayer playerWithPlayerItem:item];
        
        [self addProgressObserver];
        [self addObserverToPlayerItem:item];
        
     
        
        
        
    }
    return _player;
}



-(AVPlayerItem *)getplayItem{

//    NSString *str =[NSString stringWithFormat:@"welcome%lu.mp4",videoIndex];
//    str =[str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    NSURL *url =[NSURL fileURLWithPath:str];
    
    //NSString *str=  [[NSBundle mainBundle]pathForResource: [NSString stringWithFormat:@"welcome%lu.mp4",videoIndex] ofType:nil];
    
    //NSURL *url =[NSURL URLWithString:str];
    
    NSString *str = [[NSBundle mainBundle] pathForResource:@"welcome0" ofType:@"mp4"];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"loginmovie.mp4" ofType:@"mp4"];
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"loginmovie.mp4" withExtension:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:str]];
   
    return playerItem;
    
    
   
    


}


-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}
-(void)playbackFinished:(NSNotification *)noti{

    NSLog(@"play done");
    NSLog(@"%@",noti.userInfo);

}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addProgressObserver{

    AVPlayerItem *playitem =_player.currentItem;
    
    UIProgressView *progresses =self.progress;
    
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {;
        float current =CMTimeGetSeconds(time);
        float total =CMTimeGetSeconds([playitem duration]);
        NSLog(@"已经播放了%3.2fs",current);
        if (current) {
            [progresses setProgress:(current/total) animated:YES ];
        }
        
    }];


}

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

#pragma mark
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    
    AVPlayerItem *playerItem =object;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status =[[change objectForKey:@"new"]intValue];
        
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"total progress %.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
    
    
        NSArray *Array =playerItem.loadedTimeRanges;
    
        CMTimeRange timerange =[Array.firstObject  CMTimeRangeValue];
        float start =CMTimeGetSeconds(timerange.start);
        float durations =CMTimeGetSeconds(timerange.duration);
        
        NSTimeInterval totalBuffer =start +durations;
        NSLog(@"缓冲的时间%.2f",totalBuffer);
    }
 }
    - (IBAction)playClick:(UIButton *)sender {
        //    AVPlayerItemDidPlayToEndTimeNotification
        //AVPlayerItem *playerItem= self.player.currentItem;
        if(_player.rate==0){ //说明时暂停
           
            [_player play];
        }else if(_player.rate==1){//正在播放
            
            [_player pause];
           
        }
    }



- (IBAction)navigationButtonClick:(UIButton *)sender {
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    
    AVPlayerItem *playerItem=[self getplayItem];
    [self addObserverToPlayerItem:playerItem];
    //切换视频
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addNotification];
}













- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
