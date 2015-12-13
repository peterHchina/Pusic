//
//  PusicPopOverViewDelagate.m
//  Pusic
//
//  Created by peter on 15/4/22.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PusicPopOverViewDelagate.h"
#import "PusicStatusBarViewController.h"
@implementation PusicPopOverViewDelagate
@synthesize popOver;
-(id) init
{
    self = [super init];
    if (self) {
        _viewController = [[PusicStatusBarViewController alloc] initWithNibName:@"PusicStatusBarViewController" bundle:[NSBundle mainBundle]];
    }
    return self;
}
-(void) showPopover:(id)sender musicInfo:(Music *)music
{
    if (popOver ==nil) {
        popOver = [NSPopover new];
        popOver.delegate =self;
        popOver.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        popOver.contentViewController = _viewController;
        popOver.behavior = NSPopoverBehaviorTransient;
    }
    NSLog(@"musicName:%@",music.musicName);
    _viewController.music = music;
    [popOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
    popOver = nil;
}

//- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
//    return detachWindow;
//}

- (BOOL)popoverShouldDetach:(NSPopover *)popover {
    return YES;
}
@end
