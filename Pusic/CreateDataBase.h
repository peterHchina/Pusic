//
//  CreateDataBase.h
//  Pusic
//
//  Created by peter on 15/3/31.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateDataBase : NSObject
@property(nonatomic,copy) NSString * dataBaseFilePath;

-(void) createDataBase;
@end
