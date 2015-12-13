//
//  PusicStatusBarViewController.h
//  Pusic
//
//  Created by peter on 15/4/22.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Music.h"
#import "AYProgressIndicator.h"
#import "MusicDao.h"
#import <AVFoundation/AVFoundation.h>
#import "PusicUserDefaults.h"
#import "EZAudio.h"
NSString * const PusicStatusBarViewControllerPlayNext ;
NSString * const PusicStatusBarViewControllerPause ;
NSString * const PusicStatusBarViewControllerProNext ;
@interface PusicStatusBarViewController : NSViewController<AVAudioPlayerDelegate>
{
    NSTimer *refreshTimer;
    NSTimer *currentTimer;
    AYProgressIndicator *progressIndicator;
    NSMutableArray * songList;
    NSInteger musicPlayingPosition;
    BOOL isCirculate ;
    BOOL isRandom;
    BOOL isList;
    MusicDao * musicDao;
    AVAudioPlayer *musicPlayer;
    PusicUserDefaults *defaults;

    
}
@property (strong) IBOutlet NSImageView *musicCover;
@property (strong) IBOutlet NSTextField *musicName;
@property (strong) IBOutlet NSTextField *songerName;
@property (strong) IBOutlet NSTextField *musicAlbume;
@property (strong) IBOutlet NSTextField *musicTime;
@property (strong) IBOutlet NSTextField *currentTime;
@property (strong) IBOutlet NSButton *play;
@property (strong) IBOutlet NSButton *pro;
@property (strong) IBOutlet NSButton *next;
- (IBAction)shufflePlay:(id)sender;
- (IBAction)listPlay:(id)sender;
- (IBAction)repeatPlay:(id)sender;
@property (strong) IBOutlet NSButton *shuffleButton;
@property (strong) IBOutlet NSButton *repeatButton;
@property (strong) IBOutlet NSButton *songListButton;
- (IBAction)proMusic:(id)sender;
- (IBAction)palyMuisc:(id)sender;
- (IBAction)nextMusic:(id)sender;
@property (weak) Music *music;
@property (nonatomic,retain) EZAudioPlayer *player;
@end
