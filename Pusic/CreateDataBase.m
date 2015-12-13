//
//  CreateDataBase.m
//  Pusic
//
//  Created by peter on 15/3/31.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "CreateDataBase.h"
#import <sqlite3.h>
#define Data_Song @"SongList.sqlite"
@implementation CreateDataBase
@synthesize dataBaseFilePath;

-(void) createDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    dataBaseFilePath = [documentDirectory stringByAppendingPathComponent:Data_Song];
    NSLog(@"%@",documentDirectory);
    sqlite3 *sQ;
    if (sqlite3_open([dataBaseFilePath UTF8String], &sQ) !=SQLITE_OK) {
        sqlite3_close(sQ);
    }
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS SongTable (id INTEGER PRIMARY KEY AUTOINCREMENT, musicName TEXT, musicTime TEXT, musicSinger TEXT, musicPathURL TEXT, musicAlbumName TEXT, musicType TEXT, musicRealTime DOUBLE); ";
    
    char *errorMsg;
    if (sqlite3_exec(sQ, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
//        NSAssert1(0, @"数据库创建失败 %s", errorMsg);
    }
    
    sqlite3_close(sQ);
    
    
}
@end
