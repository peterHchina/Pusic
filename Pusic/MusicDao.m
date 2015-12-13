//
//  MusicDao.m
//  Pusic
//
//  Created by peter on 15/4/1.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "MusicDao.h"
#import <sqlite3.h>
#import "Music.h"
#define Data_Song @"SongList.sqlite"
@implementation MusicDao
-(id) init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentDirectory = [paths objectAtIndex:0];
        dataBaseFilePath = [[NSBundle mainBundle] pathForResource:@"SongList" ofType:@"sqlite"];
        
    }
    return self;
}
-(NSMutableArray *) getAllMusicList
{
    sqlite3 * dataBase;
    if (sqlite3_open([dataBaseFilePath UTF8String], &dataBase) !=SQLITE_OK ) {
        sqlite3_close(dataBase);
    }
    
    NSMutableArray * sonlist = [[NSMutableArray alloc] init];;
    NSString * sql = @"SELECT * FROM SongTable ORDER BY id";

    sqlite3_stmt *sqlite;
    if (sqlite3_prepare(dataBase, [sql UTF8String], -1, &sqlite, nil) == SQLITE_OK) {
        while (sqlite3_step(sqlite) == SQLITE_ROW) {
            Music* music = [[Music alloc] init];
            
            int Id = sqlite3_column_int(sqlite, 0);
            [music setId:Id];
            NSString * musicName = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(sqlite, 1)];
            [music setMusicName:musicName];
            
            NSString * musicTime = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(sqlite, 2)];
            [music setMusicTime:musicTime];
            
            NSString * musicSinger = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(sqlite, 3)];
            [music setMusicSinger:musicSinger];
            
            NSString * musicPathURL = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(sqlite, 4)];
            [music setMusicPathURL:musicPathURL];
            NSString * musicAlbumName;
            if ((char *)sqlite3_column_text(sqlite, 5)  == NULL) {
                musicAlbumName =NULL;
            }else
            {
             musicAlbumName= [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(sqlite, 5)];
            }
            [music setMusicAlbumName:musicAlbumName];
            NSString * musicType = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(sqlite, 6)];
            [music setMusicType:musicType];
            
            double musicRealTime = sqlite3_column_double(sqlite, 7);
            [music setMusicRealTime:musicRealTime];
            [sonlist addObject:music];
        }
        sqlite3_finalize(sqlite);
    }
    sqlite3_close(dataBase);
    return sonlist;
}

-(void) insertMusic:(NSArray *)list
{
    sqlite3 * dataBase;
    if (sqlite3_open([dataBaseFilePath UTF8String], &dataBase) !=SQLITE_OK ) {
        sqlite3_close(dataBase);
    }
     NSLog(@"test2");
    
    for (Music * music in list) {
       
        NSString * sql = @"INSERT INTO SongTable (musicName, musicTime, musicSinger, musicPathURL, musicAlbumName, musicType, musicRealTime) VALUES (?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(dataBase, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            NSLog(@"%s",[sql UTF8String]);
            sqlite3_bind_text(stmt, 1, [music.musicName UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [music.musicTime UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [music.musicSinger UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [music.musicPathURL UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [music.musicAlbumName UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [music.musicType UTF8String], -1, NULL);
            sqlite3_bind_double(stmt, 7,music.musicRealTime);
            
        }else
            
        {
            NSLog(@"test1");

        }
        
        char *errorMsg = NULL;
        if (sqlite3_step(stmt) !=SQLITE_DONE) {
//            NSAssert1(0, @"数据库更新失败 %s", errorMsg);
            NSLog(@"test3");

        }
        sqlite3_finalize(stmt);
    }
    sqlite3_close(dataBase);
}

-(void) deleteMusic:(NSArray *)list
{
    sqlite3 * dataBase;
    if (sqlite3_open([dataBaseFilePath UTF8String], &dataBase) !=SQLITE_OK ) {
        sqlite3_close(dataBase);
    }
    char * sql = "DELETE FROM SongTable WHERE id = ?";
    sqlite3_stmt *stmt;
    if (list !=nil && list.count>0) {
        for (Music *music in list) {
            if (sqlite3_prepare(dataBase, sql, -1, &stmt, NULL) == SQLITE_OK) {
                sqlite3_bind_int(stmt, 0, [music Id]);
            }
            char * errorMsg;
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                NSAssert1(0, @"数据库删除失败 %s", errorMsg);
            }
            sqlite3_finalize(stmt);
        }
        sqlite3_close(dataBase);
    }
}

-(NSMutableArray *) findMusic:(NSString *) musicName
{
    NSMutableArray * musicList = [[NSMutableArray alloc] init];
    
    sqlite3 * dataBase;
    if (sqlite3_open([dataBaseFilePath UTF8String], &dataBase) !=SQLITE_OK ) {
        sqlite3_close(dataBase);
    }
    char * sql = "select * FROM SongTable WHERE musicName = ? ORDER BY id";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare(dataBase, sql, -1, &stmt, nil) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            Music* music = [[Music alloc] init];
            
            int Id = sqlite3_column_int(stmt, 0);
            [music setId:Id];
            NSString * musicName = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
            [music setMusicName:musicName];
            
            NSString * musicTime = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];
            [music setMusicTime:musicTime];
            
            NSString * musicSinger = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 3)];
            [music setMusicSinger:musicSinger];
            
            NSString * musicPathURL = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 4)];
            [music setMusicPathURL:musicPathURL];
            
            NSString * musicAlbumName;
            if ((char *)sqlite3_column_text(stmt, 5)  == NULL) {
                musicAlbumName =NULL;
            }else
            {
                musicAlbumName= [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 5)];
            }

            [music setMusicAlbumName:musicAlbumName];
            NSString * musicType = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 6)];
            [music setMusicType:musicType];
            
            double musicRealTime = sqlite3_column_double(stmt, 7);
            [music setMusicRealTime:musicRealTime];
            [musicList addObject:music];
        }
        sqlite3_finalize(stmt);
    }
    sqlite3_close(dataBase);
    return musicList;
}

-(void) clearTable
{
    sqlite3 * dataBase;
    if (sqlite3_open([dataBaseFilePath UTF8String], &dataBase) !=SQLITE_OK ) {
        sqlite3_close(dataBase);
    }
     char * sql = "DELETE FROM SongTable";
    char * errorMsg;
    if(sqlite3_exec(dataBase, sql, nil, NULL, &errorMsg)!=SQLITE_OK)
    {
        
    }
    sqlite3_close(dataBase);

}
@end
