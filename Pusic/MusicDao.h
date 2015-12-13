//
//  MusicDao.h
//  Pusic
//
//  Created by peter on 15/4/1.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface MusicDao : NSObject
{
    NSString * dataBaseFilePath;
}
-(NSMutableArray *) getAllMusicList;
-(NSMutableArray *) findMusic:(NSString *) musicName;
-(void) insertMusic:(NSArray *) list;
-(void) deleteMusic:(NSArray *) list;
-(void) clearTable;
@end
