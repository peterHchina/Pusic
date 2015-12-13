//
//  PusicAlert.h
//  Pusic
//
//  Created by peter on 15/4/2.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>
enum {
    PusicAlertOkReturn=1000,
    PusicAlertCancelReturn=1001,
    PusicAlertotherReturn=1002,
};
@interface PusicAlert : NSObject
{
    BOOL isSheetModel;
    id sheetDelegate;
    SEL sheetdidEnd;
}
@property (strong) IBOutlet NSImageView *alertImage;
@property (strong) IBOutlet NSTextField *alertMessage;
@property (strong) IBOutlet NSButton *alertCancleButton;
@property (strong) IBOutlet NSButton *alertOkButton;
@property (strong) IBOutlet NSButton *alertOtherButton;
@property (strong) IBOutlet NSTextFieldCell *alertTitle;
@property (strong) IBOutlet NSWindow *Window;
@property (strong) IBOutlet NSButton *alertDelate;

- (BOOL) isDelete;
+(PusicAlert *) alertWithTitle:(NSString *) titleText MessageText:(NSString *)messageText okButton:(NSString *)okTitle cancelButton:(NSString *)cancelTitle otherButton:(NSString *) otherText imagePath:(NSString *) path;

-(void)beginSheetModalForWindow:(NSWindow *)window modalDelegate:delegate didEndSelector:(SEL)selector contextInfo:(void *)info;
-(NSInteger) RunModel;
@end
