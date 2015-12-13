//
//  PusicAppDelegate.h
//  Pusic
//
//  Created by peter on 15/3/16.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LBProgressBar.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicDao.h"
#import "PusicUserDefaults.h"
#import "PusicRHStatusItemView.h"
#import "PusicPopOverViewDelagate.h"
#import "EZAudio.h"
NSString * const PusicViewControllerPlayOne ;
NSString * const PusicViewControllerPlayList ;
NSString * const PusicViewControllerProRadom ;
@interface PusicAppDelegate : NSObject <NSApplicationDelegate,AVAudioPlayerDelegate,NSUserNotificationCenterDelegate,NSOpenSavePanelDelegate,EZAudioPlayerDelegate>
{
    NSMutableArray * songList;
    AVAudioPlayer *musicPlayer;
    NSInteger musicPlayingPosition;
    NSTimer *currentTimer;
    MusicDao * musicDao;
    BOOL isCirculate ;
    BOOL isRandom;
    PusicPopOverViewDelagate * popOverDelagate;
    PusicUserDefaults *defaults;
    Music * currentMusic;
}
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *deleteSong;
@property (weak) IBOutlet NSButton *addSong;
@property (weak) IBOutlet NSButton *makeUnarrylist;
@property (weak) IBOutlet NSButton *clearButton;
@property (assign) IBOutlet LBProgressBar* indicator;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *musicTime;
@property (weak) IBOutlet NSTextField *songNumber;
@property (weak) IBOutlet NSTableView *musicTableView;
@property (weak) IBOutlet NSButton *circulateButton;
@property (weak) IBOutlet NSButton *randomButton;
@property PusicRHStatusItemView *statusView;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, strong) EZAudioPlayer *player;
@property NSStatusItem *statusItem;
- (IBAction)buttonPlay:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)addFolder:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)disSort:(id)sender;
- (IBAction)addSong:(id)sender;
- (IBAction)deleteSong:(id)sender;
- (IBAction)adjustVolume:(id)sender;
- (IBAction)playOneSong:(id)sender;
-(void) playMusic;
-(void) play:(NSInteger) position;

@end
