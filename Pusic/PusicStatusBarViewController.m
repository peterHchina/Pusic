//
//  PusicStatusBarViewController.m
//  Pusic
//
//  Created by peter on 15/4/22.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PusicStatusBarViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AYProgressIndicator.h"
NSString * const PusicStatusBarViewControllerPlayNext = @"PusicStatusBarViewControllerPlayNext";
NSString * const PusicStatusBarViewControllerPause = @"PusicStatusBarViewControllerPause";
NSString * const PusicStatusBarViewControllerProNext = @"PusicStatusBarViewControllerProNext";
@interface PusicStatusBarViewController ()

@end

@implementation PusicStatusBarViewController


@synthesize player;
@synthesize music;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        progressIndicator = [[AYProgressIndicator alloc] initWithFrame:NSMakeRect(268, 38, 50, 2)
                                                         progressColor:[NSColor redColor]
                                                            emptyColor:[NSColor blackColor]
                                                              minValue:0
                                                              maxValue:100
                                                          currentValue:0];
         [self setupNotifications];

        
    }
    return self;
}

-(void) viewDidAppear
{
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateInfo) userInfo:nil repeats:YES];
}

-(void)  awakeFromNib
{
    isCirculate = [PusicUserDefaults getCirculate ];
    [self setCriculateButtonState:isCirculate];
    isRandom = [PusicUserDefaults getRandom];
    [self setRandomButtonState:isRandom];
    isList = [PusicUserDefaults getList];
    [self setSonglistButtonState:isList];
    [self.view addSubview:progressIndicator];
    [self initPlayButtonState];
    musicDao = [[MusicDao alloc] init];
    songList = [musicDao getAllMusicList];

}

- (IBAction)shufflePlay:(id)sender {
    if (isRandom) {
        
        
    }else{
        isRandom = !isRandom;
        if (isCirculate) {
            isCirculate = !isCirculate;
            [PusicUserDefaults setCirculate:isCirculate];
            [self setCriculateButtonState:isCirculate];
        }
        
        if (isList) {
            isList = !isList;
            [PusicUserDefaults setList:isList];
            [self setSonglistButtonState:isList];
        }
        
        
        [PusicUserDefaults setRandom:isRandom];
        
        [self setRandomButtonState:isRandom];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangePlayStateNotification object:self];
    
}

- (IBAction)listPlay:(id)sender {
    if (isList) {
        
    }else {
        isList = !isList;
        if (isRandom) {
            isRandom = !isRandom;
            [PusicUserDefaults setRandom:isRandom];
            [self setRandomButtonState:isRandom];
        }
        
        if (isCirculate) {
            isCirculate = !isCirculate;
            [PusicUserDefaults setCirculate:isCirculate];
            [self setCriculateButtonState:isCirculate];
        }
        
        
        [PusicUserDefaults setList:isList];
        
        [self setSonglistButtonState:isList];
    }
    
}


- (IBAction)repeatPlay:(id)sender {
    if (isCirculate) {
        
    }else {
        isCirculate = !isCirculate;
        if (isRandom) {
            isRandom = !isRandom;
            [PusicUserDefaults setRandom:isRandom];
            [self setRandomButtonState:isRandom];
        }
        
        if (isList) {
            isList = !isList;
            [PusicUserDefaults setList:isList];
            [self setSonglistButtonState:isList];
        }
        
        [PusicUserDefaults setCirculate:isCirculate];
        
        [self setCriculateButtonState:isCirculate];
    }
    
    
}
-(void) setCriculateButtonState:(BOOL) state
{
    if (state == YES) {
        [_repeatButton setImage:[NSImage imageNamed:@"Repeat_press"]];
    }else
    {
        [_repeatButton setImage:[NSImage imageNamed:@"Repeat_normal"]];
    }
    
}

-(void) setSonglistButtonState:(BOOL) state
{
    if (state == YES) {
        [_songListButton setImage:[NSImage imageNamed:@"Songlist_press"]];
    }else
    {
        [_songListButton setImage:[NSImage imageNamed:@"Songlist_normal"]];
    }
    
}

-(void) setRandomButtonState:(BOOL) state
{
    if (state == YES) {
        [_shuffleButton setImage:[NSImage imageNamed:@"Shuffle_press"]];
    }else
    {
        [_shuffleButton setImage:[NSImage imageNamed:@"Shuffle_normal"]];
    }
    
}


-(void)viewWillAppear
{
    [refreshTimer invalidate];
    refreshTimer = nil;
     [self.view addSubview:progressIndicator];
}

- (IBAction)proMusic:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PusicStatusBarViewControllerProNext
                                                        object:[ NSNumber numberWithInteger:musicPlayingPosition-1]];
}

- (IBAction)palyMuisc:(id)sender {
    [self play:musicPlayingPosition];
    [self updatePlayProgress];

}

- (IBAction)nextMusic:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PusicStatusBarViewControllerPlayNext
                                                        object:nil];
}

-(void)updateInfo
{
    if (music!=nil) {
        _musicCover.image = [self getSongCoverImage:music];
        _musicName.stringValue = music.musicName;
        _musicAlbume.stringValue = music.musicAlbumName;
        _songerName.stringValue = music.musicSinger;
        _musicTime.stringValue = music.musicTime;
    }
}

-(NSImage *) getSongCoverImage:(Music * )m
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    NSURL *musicURL = [NSURL fileURLWithPath:m.musicPathURL];
    NSImage *image ;
    AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
    
    //    NSLog(@"%@",mp3Asset);
    
    for (NSString *format in [musicAsset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [musicAsset metadataForFormat:format]) {
            
            if(metadataItem.commonKey )
                [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
            
        }
    }
    NSData *data =[retDic objectForKey:@"artwork"] ;
    image =[[NSImage alloc] initWithData:data];
    return image;

}



-(NSString *) getFormateTimeString : (NSInteger ) time
{
    NSLog(@"time %ld",time);
    int minute=0;
    int second=0;
    if (time>=60) {
        int index = (int)time/60;
        minute = index;
        second=(int)time -60*index;
    }else
    {
        second = (int)time;
    }
    NSString *minuteString=@"00";
    NSString *secondString=@"00";
    
    if (minute<10) {
        minuteString= [NSString stringWithFormat:@"%d",minute];
    }
    else
    {
        minuteString= [NSString stringWithFormat:@"%d",minute];
        
    }
    if (second<10) {
        secondString=[NSString stringWithFormat:@"0%d",second];
        
    }else
    {
        secondString=[NSString stringWithFormat:@"%d",second];
    }
    
    
    
    return  [NSString stringWithFormat:@"%@:%@",minuteString,secondString];
    
}


-(void)count :(double) percent{
    NSLog(@"%lf",percent);
    if (percent<= 100) {
        [progressIndicator setProgressValue:  percent];
    }
    
}

-(void) play : (NSInteger) position
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PusicStatusBarViewControllerPause
                                                        object:[ NSNumber numberWithInteger:position]];

    
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (!isCirculate) {
        if (isRandom) {
            musicPlayingPosition = arc4random()%[songList count];
        }else {
            musicPlayingPosition+=1;
        }
        
        
        
    }
    music  = [songList objectAtIndex:(musicPlayingPosition)];
    [self updateInfo];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
    //    [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
    NSString *path = [(Music *)songList[musicPlayingPosition] musicPathURL];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    musicPlayer = [[AVAudioPlayer alloc ]initWithContentsOfURL:url error:nil];
    musicPlayer.delegate=self;
    //    [musicPlayer setVolume:[_volumeSlider floatValue]];
 
    [musicPlayer play];
    [PusicUserDefaults setLastPlaySongPosition:musicPlayingPosition];
}

-(void)removeCurrentTime
{
    if (!currentTimer) {
        [currentTimer invalidate];
        //把定时器清空
        currentTimer=nil;
    }
    
}

-(void) updatePlayProgress
{
    [self removeCurrentTime];
    if (!currentTimer && player.isPlaying) {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateMusicPlayingTime:) userInfo:nil repeats:YES];
        
    }
    
}

-(void) reInitButtonState
{
    isCirculate = [PusicUserDefaults getCirculate ];
    [self setCriculateButtonState:isCirculate];
    isRandom = [PusicUserDefaults getRandom];
    [self setRandomButtonState:isRandom];
    isList = [PusicUserDefaults getList];
    [self setSonglistButtonState:isList];
}

-(void) updateMusicPlayingTime : (NSInteger) time
{
    NSInteger currentTime = [player currentTime];
    [_musicTime setStringValue:[NSString stringWithFormat:@"%@",music.musicTime]];
    [_currentTime setStringValue:[self getFormateTimeString:currentTime]];
    double percent = (currentTime/music.musicRealTime)*100;
    [self count:percent];
}
-(void) playMusic
{
    [self play:musicPlayingPosition];
    [self updatePlayProgress];
    
}


- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:nil];
    
    
    // This notification will only trigger if the player's shouldLoop property is set to NO
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeRepeatButton)
                                                 name:@"PusicViewControllerPlayOne"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeListButton)
                                                 name:@"PusicViewControllerPlayList"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeShufferButton)
                                                 name:@"PusicViewControllerProRadom"
                                               object:nil];
    
   
    
}

-(void) changeShufferButton
{
    [self reInitButtonState];
}

-(void) changeRepeatButton
{
      [self reInitButtonState];
}

-(void) changeListButton
{
      [self reInitButtonState];
}
//------------------------------------------------------------------------------

- (void)audioPlayerChangeAudioFile:(NSNotification *)notification
{
    player = [notification object];
    musicPlayingPosition = [PusicUserDefaults getLastPlaySongPosition];
    music  = [songList objectAtIndex:(musicPlayingPosition)];

    [self updateInfo];
    [self updatePlayProgress];
    NSLog(@"Player changed audio file============: %@", [player audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerChangeOutputDevice:(NSNotification *)notification
{
    player = [notification object];
    
    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerChangePlayState:(NSNotification *)notification
{
    player = [notification object];
    [self initPlayButtonState];
    musicPlayingPosition = [PusicUserDefaults getLastPlaySongPosition];
    music  = [songList objectAtIndex:(musicPlayingPosition)];
    [self updatePlayProgress];
}

//------------------------------------------------------------------------------

-(void) initPlayButtonState
{
  
        if ([player isPlaying]) {
            [_play setImage:[NSImage imageNamed:@"state_play_puse_normal"]];
            [_play setAlternateImage:[NSImage imageNamed:@"state_play_puse_pressed"]];
        }else
        {
            [_play setImage:[NSImage imageNamed:@"state_play_normal"]];
            [_play setAlternateImage:[NSImage imageNamed:@"state_play_pressed"]];
        }
    
}

- (void)audioPlayerDidReachEndOfFile:(NSNotification *)notification
{
    NSLog(@"Player did reach end of file!");
    [self updateInfo];
    musicPlayingPosition = [PusicUserDefaults getLastPlaySongPosition];
    [self updatePlayProgress];
//    if (!isCirculate) {
//        if (isRandom) {
//            musicPlayingPosition = arc4random()%[songList count];
//        }else {
//            musicPlayingPosition+=1;
//        }
//        currentMusic  = [songList objectAtIndex:(musicPlayingPosition)];
//        NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
//        [self setAudioPlayerFile:musicPlayingPosition];
//        [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
//        [_musicTableView scrollRowToVisible:musicPlayingPosition];
//        [PusicUserDefaults setLastPlaySongPosition:musicPlayingPosition];
//        [self.player play];
//    }
    
}


@end
