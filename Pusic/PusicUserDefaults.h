//
//  PusicUserDefaults.h
//  Pusic
//
//  Created by peter on 15/4/14.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const BNRLastTimePlayingSong;
extern NSString * const BNRIsCirculate;
extern NSString *  const BNRIsRandom;
extern NSString *  const BNRIsList;
extern NSString *  const BNRTheme;
@interface PusicUserDefaults : NSObject
+(void) registerUserDefaults;
+( void) setCirculate :(BOOL) circulate;
+(BOOL) getCirculate;
+( void) setRandom :(BOOL) random;
+(BOOL) getRandom;
+( void) setLastPlaySongPosition :(NSUInteger) position;
+(int) getLastPlaySongPosition;
+( void) setList :(BOOL) list;
+(BOOL) getList;
+( void) setTheme :(NSInteger) theme;
+(NSInteger) getTheme;
@end
