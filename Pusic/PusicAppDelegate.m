//
//  PusicAppDelegate.m
//  Pusic
//
//  Created by peter on 15/3/16.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PusicAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Music.h"
#import "CreateDataBase.h"
#import "MusicDao.h"
#import "PusicAlert.h"
#import "PusicUserDefaults.h"
#import "PusicRHStatusItemView.h"
double i = 0;
NSString * const PusicViewControllerPlayOne = @"PusicViewControllerPlayOne" ;
NSString * const PusicViewControllerPlayList =@"PusicViewControllerPlayList";
NSString * const PusicViewControllerProRadom=@"PusicViewControllerProRadom" ;

@implementation PusicAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    [self initButton];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window makeKeyAndOrderFront:nil];
    });
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
    [_statusItem setHighlightMode:YES];
    _statusView = [[PusicRHStatusItemView alloc] initWithStatusBarItem:_statusItem];
    _statusItem.view = _statusView;
    _statusView.target =self;
    _statusView.action = @selector(mouseClick:);
    popOverDelagate =[[PusicPopOverViewDelagate alloc] init];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    [self setStatusImageAndToolTip];
    [_musicTableView reloadData];
//    [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(count:) userInfo:nil repeats:YES];
}



-(void)count :(double) percent{
    if (percent<= 100) {
        [_indicator setDoubleValue:percent];
    }
}


-(void) mouseClick:(id) sender
{
    
    [popOverDelagate showPopover:sender musicInfo:[songList objectAtIndex:musicPlayingPosition]];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)setStatusImageAndToolTip
{
    
    NSImage *image = [NSImage imageNamed:@"status"];
//    CGFloat length = image.size.width / image.size.height * statusBarHeight * 0.8;
//    [image setSize:NSMakeSize(length, statusBarHeight * 0.8)];
    _statusView.image = image;
    _statusView.alternateImage = image;
    [_statusView.alternateImage setTemplate:YES];
//    _statusItem.length = length;
   
}

+(void) initialize
{
    [PusicUserDefaults registerUserDefaults];
    
}

- (void)setButtonColor:(NSButton *)button andColor:(NSColor *)color {
    if (color == nil) {
        color = [NSColor redColor];
    }
    
    int fontSize = 14;
    NSFont *font = [NSFont systemFontOfSize:fontSize];
    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:font,
                            NSFontAttributeName,
                            color,
                            NSForegroundColorAttributeName,
                            nil];
    
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:[button title] attributes:attrs];
//    [attributedString setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [attributedString length])];
//    [button setAttributedTitle:attributedString];
    [button setAttributedAlternateTitle:attributedString];
    
}

-(void) initButton
{
    [self setButtonColor:_makeUnarrylist andColor:[NSColor redColor]];
    [self setButtonColor:_clearButton andColor:[NSColor redColor]];
}


-(void)  awakeFromNib
{
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
     [self setupNotifications];
     popOverDelagate.viewController.player = self.player;
    
    isCirculate = [PusicUserDefaults getCirculate ];
    self.player.shouldLoop = isCirculate;
     [self setCriculateButtonState:isCirculate];
        isRandom = [PusicUserDefaults getRandom];
   
    [self setRandomButtonState:isRandom];

     [[[CreateDataBase alloc] init] createDataBase];
    musicDao = [[MusicDao alloc] init];
    songList = [musicDao getAllMusicList];
    [_songNumber setStringValue:[NSString stringWithFormat:@"(%ld)",[songList count]]];
    musicPlayingPosition = [PusicUserDefaults getLastPlaySongPosition];
    if (songList.count>0 && songList[musicPlayingPosition]!=nil) {
        currentMusic = songList[musicPlayingPosition];
        [self setAudioPlayerFile:musicPlayingPosition];
        [_musicTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:musicPlayingPosition] byExtendingSelection:YES];
        [_musicTableView setTarget:self];
        [_musicTableView setDoubleAction:@selector(playMusic)];
        [_musicTableView scrollRowToVisible:musicPlayingPosition+10];
    }
   

}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
    
    // This notification will only trigger if the player's shouldLoop property is set to NO
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:self.player];
    // play button notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerPlayNext)
                                                 name:PusicStatusBarViewControllerPlayNext
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerPause)
                                                 name:PusicStatusBarViewControllerPause
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerPlayPro)
                                                 name:PusicStatusBarViewControllerProNext
                                               object:nil];

}


//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
//    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
//    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidReachEndOfFile:(NSNotification *)notification
{
//    NSLog(@"Player did reach end of file!");
    if (!isCirculate) {
        if (isRandom) {
            musicPlayingPosition = arc4random()%[songList count];
        }else {
            musicPlayingPosition+=1;
        }
        currentMusic  = [songList objectAtIndex:(musicPlayingPosition)];
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
        [self setAudioPlayerFile:musicPlayingPosition];
        [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
        [_musicTableView scrollRowToVisible:musicPlayingPosition];
        [PusicUserDefaults setLastPlaySongPosition:musicPlayingPosition];
        [self.player play];
    }
    
}

-(void) audioPlayerPlayNext
{
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
    [self audioPlay:musicPlayingPosition+1];

}

-(void) audioPlayerPause
{
      [self audioPlay:musicPlayingPosition];
}

-(void) audioPlayerPlayPro
{
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
    [self audioPlay:musicPlayingPosition-1];

}

-(void) setAudioPlayerFile:(NSUInteger) position
{
    NSString *path = [(Music *)songList[position] musicPathURL];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioFile = [EZAudioFile audioFileWithURL:url];
    [self.player setAudioFile:self.audioFile];
    if(position<songList.count){
        currentMusic = [songList objectAtIndex:position];

    }
   }


- (IBAction)buttonPlay:(id)sender {
    
         [self audioPlay:musicPlayingPosition];
//         [self updatePlayProgress];

}
-(void)removeCurrentTime
{
    if (!currentTimer) {
        [currentTimer invalidate];
        //把定时器清空
        currentTimer=nil;
    }
    
}

-(void)seekToFrame:(id)sender
{
    double value = [(NSSlider*)sender doubleValue];
    [self.player seekToFrame:(SInt64)value];
    
}

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.indicator.doubleValue = (self.player.currentTime/currentMusic.musicRealTime)*100;
            weakSelf.musicTime.stringValue = [NSString stringWithFormat:@"%@/%@",[self getFormateTimeString:self.player.currentTime],currentMusic.musicTime];
    });
}



-(void) updateMusicPlayingTime : (NSInteger) time
{
    Music *music = songList[musicPlayingPosition];
    NSInteger currentTime = [musicPlayer currentTime];
    [_musicTime setStringValue:[NSString stringWithFormat:@"%@/%@",[self getFormateTimeString:currentTime],music.musicTime]];
    double percent = currentTime/(music.musicRealTime)*100;
    [self count:percent];
}
-(void) playMusic
{
    NSInteger row = [_musicTableView clickedRow];
    [self audioPlay:row];
//    [self updatePlayProgress];
    
}

-(void) play : (NSInteger) position
{
    if (position < songList.count && songList!=nil) {
        Music *music = [songList objectAtIndex:position];
        [_window setTitle:[music musicName]];
        NSString *path = [music musicPathURL];
        NSURL *url = [NSURL fileURLWithPath:path];
        if (musicPlayer) {
            if (musicPlayingPosition == position) {
                if ([musicPlayer isPlaying]) {
                    [musicPlayer pause];
                }else
                {
                    [musicPlayer play];
                    
                }
            }else
            {
                musicPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil] ;
                musicPlayer.delegate=self;
                [musicPlayer play];
                [musicPlayer setVolume:[_volumeSlider floatValue]];
                musicPlayingPosition = position;
                NSLog(@"time : %@",music.musicTime);
                [_musicTime setStringValue:[NSString stringWithFormat:@"%@/%@",[self getFormateTimeString:[musicPlayer currentTime]],music.musicTime]];

                
            }
        }
        else
        {
            musicPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil] ;
            musicPlayer.delegate=self;
            [musicPlayer play];
            [musicPlayer setVolume:[_volumeSlider floatValue]];
            musicPlayingPosition = position;
            [_musicTime setStringValue:[NSString stringWithFormat:@"%@/%@",[self getFormateTimeString:[musicPlayer currentTime]],music.musicTime]];
        }

    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
    [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
    [_musicTableView scrollRowToVisible:musicPlayingPosition];

    if ([musicPlayer isPlaying]) {
        [_playButton setImage:[NSImage imageNamed:@"play_normal"]];
        [_playButton setAlternateImage:[NSImage imageNamed:@"play_pressed"]];
    }else
    {
        [_playButton setImage:[NSImage imageNamed:@"stop_normal"]];
        [_playButton setAlternateImage:[NSImage imageNamed:@"stop_pressed"]];
    }

    [PusicUserDefaults setLastPlaySongPosition:(int)position];
    [_musicTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:musicPlayingPosition] byExtendingSelection:NO];
    
}


-(void) audioPlay: (NSInteger) position
{
      if (position < songList.count && songList!=nil) {
         
         if (musicPlayingPosition == position) {
                 if ([self.player isPlaying]) {
                         [self.player pause];
                 }else
                     {
                         [self.player play];
                    }
           }else
           {
               musicPlayingPosition = position;
                [PusicUserDefaults setLastPlaySongPosition:musicPlayingPosition];
               [self setAudioPlayerFile:musicPlayingPosition];
               [self.player play];
               
               NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
               [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
               [_musicTableView scrollRowToVisible:musicPlayingPosition];

           }
      }
    
    
    if ([self.player isPlaying]) {
        [_playButton setImage:[NSImage imageNamed:@"play_normal"]];
        [_playButton setAlternateImage:[NSImage imageNamed:@"play_pressed"]];
    }else
    {
        [_playButton setImage:[NSImage imageNamed:@"stop_normal"]];
        [_playButton setAlternateImage:[NSImage imageNamed:@"stop_pressed"]];
    }
     [_window setTitle:[currentMusic musicName]];
   
    [_musicTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:musicPlayingPosition] byExtendingSelection:NO];

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
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
    [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
    [_musicTableView scrollRowToVisible:musicPlayingPosition];
    NSString *path = [(Music *)songList[musicPlayingPosition] musicPathURL];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    musicPlayer = [[AVAudioPlayer alloc ]initWithContentsOfURL:url error:nil];
    musicPlayer.delegate=self;
    [musicPlayer setVolume:[_volumeSlider floatValue]];
    [_window setTitle:[[songList objectAtIndex:musicPlayingPosition] musicName]];
    [musicPlayer play];
}

- (IBAction)next:(id)sender {
    
    
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
        [self audioPlay:musicPlayingPosition+1];
    
//    [self updatePlayProgress];
    //    [[NSRunLoop mainRunLoop] addTimer:currentTimer forMode:NSRunLoopCommonModes];

}

-(void) updatePlayProgress
{
    [self removeCurrentTime];
    if (!currentTimer) {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateMusicPlayingTime:) userInfo:nil repeats:YES];

    }
    
}


- (void)openFile:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.delegate = self;
    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSArray *selectedFiles = [openDlg URLs];
        [self openFileWithFilePathURL:selectedFiles.firstObject];
    }
}


- (IBAction)addFolder:(id)sender {
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setTitle:@"选择歌曲所在文件夹"];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger resault)
     {
         if (resault== NSModalResponseOK) {
             [self performSelectorInBackground:@selector(backgroundOperation:) withObject:panel];
         }
         panel = nil;
         
         
     }];

}


- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    NSArray *fileTypes = [EZAudioFile supportedAudioFileTypes];
    BOOL isDirectory = [ext isEqualToString:@""];
    return [fileTypes containsObject:ext] || isDirectory;
}



-(void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    //
    // Stop playback
    //
    [self.player pause];
    //
    // Load the audio file and customize the UI
    //
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    self.playButton.state = NSOffState;
    //
    // Play the audio file
    //
    [self.player setAudioFile:self.audioFile];
}


- (IBAction)clear:(id)sender {
    PusicAlert *alert = [PusicAlert alertWithTitle:@"列表清除警告!" MessageText:@"是否要清除当前歌曲列表？"  okButton:@"确定" cancelButton:@"取消" otherButton:nil imagePath:nil] ;
    
    NSInteger action = [alert RunModel];
    if(action == PusicAlertOkReturn)
    {
       
        [self clearAllData:[alert isDelete] ];
        
    }
    else if(action == PusicAlertCancelReturn )
    {
        NSLog(@"SYXAlertCancelButton clicked!");
    }

}

- (IBAction)disSort:(id)sender {
    isRandom = !isRandom;
    [PusicUserDefaults setRandom:isRandom];
    [self setRandomButtonState:isRandom];
    if (isCirculate) {
        isCirculate = !isCirculate;
        [PusicUserDefaults setCirculate:isCirculate];
        [self setCriculateButtonState:isCirculate];
        self.player.shouldLoop = isCirculate;
    }
   [[NSNotificationCenter defaultCenter] postNotificationName:PusicViewControllerProRadom object:nil];
}

- (IBAction)addSong:(id)sender {
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setTitle:@"选择歌曲"];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp3",@"wmv", nil]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger resault)
     {
         if (resault== NSModalResponseOK) {
             [self performSelectorInBackground:@selector(backgroundOperation:) withObject:panel];
         }
         panel = nil;
         
         
     }];

    
}


- (IBAction)adjustVolume:(id)sender {
        [self.player setVolume:[_volumeSlider floatValue]];
}

- (IBAction)playOneSong:(id)sender {
    isCirculate = !isCirculate;
    [PusicUserDefaults setCirculate:isCirculate];
    [self setCriculateButtonState:isCirculate];
    self.player.shouldLoop = isCirculate;
    if(isRandom)
    {
    isRandom = !isRandom;
    [PusicUserDefaults setRandom:isRandom];
    [self setRandomButtonState:isRandom];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PusicViewControllerPlayOne object:nil];
}



-(void) backgroundOperation:(id) unused
{
    NSArray * arry = [songList copy];
    NSFileManager *fileManger = [NSFileManager new];
    NSURL *path2;
    NSString *basePath ;
    if ([unused  isKindOfClass:[NSPanel class]]) {
        path2 = [unused URL];
        basePath = [path2 path];
    }else if ([unused isKindOfClass:[NSString class]])
    {
        basePath=unused;
    }
    NSLog(@"%@",basePath);
    NSDirectoryEnumerator *filearry = [fileManger  enumeratorAtPath:basePath];
    for (NSString *file in filearry) {
        NSString *fullPath =[basePath stringByAppendingPathComponent:file];
        NSURL *musicURL;
        if ([[fullPath pathExtension] isEqualToString:@"mp3"] || [[fullPath pathExtension] isEqualToString:@"wmv"]) {
            NSString * musicType =[fullPath pathExtension];
            musicURL = [NSURL fileURLWithPath:fullPath];
            AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            Music *music = [[Music alloc] init];
            [music setMusicTime:[self getSongTime: musicAsset :music]];
            [music setMusicPathURL:fullPath];
            NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
            
//            AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            
            //    NSLog(@"%@",mp3Asset);
            
            for (NSString *format in [musicAsset availableMetadataFormats]) {
                for (AVMetadataItem *metadataItem in [musicAsset metadataForFormat:format]) {
                    
                    if(metadataItem.commonKey)
                        [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
                    
                }
            }
            NSString * musicName = [NSString stringWithFormat:@"%@-%@",[retDic objectForKey:@"title"],[retDic objectForKey:@"artist"]];
            
            [music setMusicName:musicName];
            [music setMusicType:musicType];
            [music setMusicSinger:[retDic objectForKey:@"artist"]];
            [music setMusicAlbumName:[retDic objectForKey:@"albumName"]];
            //            [music setMusicCoverImage:[[retDic objectForKey:@"artwork"] objectForKey:@"data"]];
            int flag=0;
            if (arry.count>0 ) {
                for (Music *m in songList) {
                    if ([[m musicName] isEqualToString:[music musicName]]) {
                        flag=1;
                    }
                }
            }
            if (flag==0) {
                [songList addObject:music];
                
            }
            
        }
        
    }
    [self performSelectorOnMainThread:@selector(updateWithResults) withObject:nil waitUntilDone:YES];
    
    
}
-(void) updateWithResults
{
//    NSLog(@"NSUserDefaults66 %@",[[NSUserDefaults standardUserDefaults] objectForKey:BNRRecentFileFolder]);
    [_songNumber setStringValue:[NSString stringWithFormat:@"(%ld)",[songList count]]];
    if (songList.count>0) {
        [musicDao clearTable];
        [musicDao insertMusic:songList];
    }
    
    [_musicTableView reloadData];
}

-(void) clearAllData:(BOOL) state
{
    if(musicPlayer.isPlaying)
    {
        [musicPlayer stop];
        musicPlayingPosition = 0;
       
    }
     [musicDao clearTable ];
    if(state == YES)
    {
        [self deleteFile:songList];
    }
    [songList removeAllObjects];
    
    [_musicTableView reloadData];
}

-(void) clearSingleSongData:(BOOL) state
{
    if(musicPlayer.isPlaying)
    {
        [musicPlayer stop];
        musicPlayingPosition = 0;
        
    }
    [musicDao deleteMusic:[NSArray arrayWithObject:songList[[_musicTableView selectedColumn] ]]];
    

    if(state == YES)
    {
    [self deleteFile:[NSArray arrayWithObject:songList[[_musicTableView selectedColumn]] ]];
    [songList removeObjectAtIndex:[_musicTableView selectedColumn]];
     }
    [_musicTableView reloadData];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"%ld",[songList count]);
    return [songList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Music * music = (Music *)songList[row];
    return [music valueForKey:[ tableColumn identifier]];
    
}

-(NSString *) getSongTime:(AVURLAsset *) urlAsset :(Music *) music
{
    
    if(urlAsset)
    {
        double musicTime = urlAsset.duration.value/urlAsset.duration.timescale;
        [music setMusicRealTime:musicTime];
       return  [self getFormateTimeString:(int)musicTime];
    }
    return @"0s";
}

-(NSString *) getFormateTimeString : (NSInteger ) time
{
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
-(IBAction)deleteSong:(id)sender
{
    
    Music *music = [songList objectAtIndex:musicPlayingPosition];
    NSString *name = [music musicName];
    PusicAlert *alert = [PusicAlert alertWithTitle:@"删除警告!" MessageText:[NSString stringWithFormat:@"是否要删除歌曲：%@",name]   okButton:@"确定" cancelButton:@"取消" otherButton:nil imagePath:nil] ;
    
    NSInteger action = [alert RunModel];
    if(action == PusicAlertOkReturn)
    {
        [self clearSingleSongData:[alert isDelete]];
    }
    else if(action == PusicAlertCancelReturn )
    {
        NSLog(@"SYXAlertCancelButton clicked!");
    }

    
}

-(void) backgroundAddSong:(id) sender
{
    NSArray * arry = [songList copy];
    NSURL *path2;
    NSString *basePath ;
    if ([sender isKindOfClass:[NSPanel class]]) {
        path2 = [sender URL];
        basePath = [path2 path];
    }
   
        NSURL *musicURL;
        if ([[basePath pathExtension] isEqualToString:@"mp3"] || [[basePath pathExtension] isEqualToString:@"wmv"]) {
            NSString * musicType =[basePath pathExtension];
            musicURL = [NSURL fileURLWithPath:basePath];
            AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            Music *music = [[Music alloc] init];
            [music setMusicTime:[self getSongTime: musicAsset :music]];
            [music setMusicPathURL:basePath];
            NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
            
            AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            
            //    NSLog(@"%@",mp3Asset);
            
            for (NSString *format in [mp3Asset availableMetadataFormats]) {
                for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
                    
                    if(metadataItem.commonKey)
                        [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
                    
                }
            }
            NSString * musicName = [NSString stringWithFormat:@"%@-%@",[retDic objectForKey:@"title"],[retDic objectForKey:@"artist"]];
            NSLog(@"%@",musicName);
            [music setMusicName:musicName];
            [music setMusicType:musicType];
            [music setMusicSinger:[retDic objectForKey:@"artist"]];
            [music setMusicAlbumName:[retDic objectForKey:@"albumName"]];
            //            [music setMusicCoverImage:[[retDic objectForKey:@"artwork"] objectForKey:@"data"]];
            int flag=0;
            if (arry.count>0 ) {
                for (Music *m in songList) {
                    if ([[m musicName] isEqualToString:[music musicName]]) {
                        flag=1;
                    }
                }
            }
            if (flag==0) {
                [songList addObject:music];
                
            }
            
        
        
    }
    [self performSelectorOnMainThread:@selector(updateWithResults) withObject:nil waitUntilDone:YES];
}

-(void) setCriculateButtonState:(BOOL) state
{
    if (state == YES) {
        [_circulateButton setImage:[NSImage imageNamed:@"select_button"]];
    }else
    {
        [_circulateButton setImage:[NSImage imageNamed:@"small_button_normal"]];
    }
    
}

-(void) setRandomButtonState:(BOOL) state
{
    if (state == YES) {
        [_randomButton setImage:[NSImage imageNamed:@"select_random_button"]];
    }else
    {
        [_randomButton setImage:[NSImage imageNamed:@"small_button_normal"]];
    }
    
}

-(void) deleteFile:(NSArray *) list
{
    NSFileManager *manger = [NSFileManager defaultManager];
    if (list!=nil && list.count>0) {
        for(Music * music in list)
        {
        [manger removeItemAtPath:music.musicPathURL error:NULL];
        }
    }
    
}


- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification{
    
}
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}
@end
