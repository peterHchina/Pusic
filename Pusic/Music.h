//
//  Music.h
//  Scattered
//
//  Created by peter on 15/2/27.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject
@property (nonatomic) int Id;
@property (nonatomic,retain) NSString *musicName;
@property (nonatomic,retain) NSString *musicTime;
@property (nonatomic,retain) NSString *musicSinger;
@property (nonatomic,retain) NSString *musicPathURL;
@property (nonatomic,retain) NSString *musicAlbumName;
@property (nonatomic,retain) NSImage *musicCoverImage;
@property (nonatomic,retain) NSString *musicType;
@property (nonatomic) double musicRealTime;
@end
