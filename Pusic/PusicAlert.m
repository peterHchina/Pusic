//
//  PusicAlert.m
//  Pusic
//
//  Created by peter on 15/4/2.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PusicAlert.h"

@implementation PusicAlert
-(id) init
{
    return [self initWithWindowNibName:@"PusicAlert"];
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
	self = [super init];
	if (self) {
        if (!_Window)
        {
            [[NSBundle mainBundle] loadNibNamed:windowNibName owner:self topLevelObjects:nil];
        }
    }
    return self;
}
-(BOOL) isDelete
{
    return _alertDelate.state;
}

+(PusicAlert *) alertWithTitle:(NSString *)titleText MessageText:(NSString *)messageText okButton:(NSString *)okTitle cancelButton:(NSString *)cancelTitle otherButton:(NSString *)otherText imagePath:(NSString *)path
{
    PusicAlert * alert = [[PusicAlert alloc] init] ;
    alert.alertTitle.stringValue = titleText;
    alert.alertMessage.stringValue=messageText;
    if (okTitle == nil) {
        okTitle =@"ok";
    }
    [alert.alertOkButton setTitle:okTitle];
    [alert.alertOkButton setTarget:alert];
    [alert.alertOkButton setAction:@selector(Action:)];
    [alert.alertOkButton setTag:PusicAlertOkReturn];
    
    if (cancelTitle == nil) {
        cancelTitle =@"cancel";
    }
    [alert.alertCancleButton setTitle:cancelTitle];
    [alert.alertCancleButton setTarget:alert];
    [alert.alertCancleButton setAction:@selector(Action:)];
    [alert.alertCancleButton setTag:PusicAlertCancelReturn];
    
    if (otherText == nil) {
        [alert.alertOtherButton setHidden:YES];
    }else
    {
        [alert.alertOtherButton setTitle:otherText];
        [alert.alertOtherButton setTarget:alert];
        [alert.alertOtherButton setAction:@selector(Action:)];
        [alert.alertOtherButton setTag:PusicAlertotherReturn];
    }
    
    if (path == nil) {
        [alert.alertImage setImage:[NSImage imageNamed:@"warning_default"]];
    }else
    {
       [alert.alertImage setImage:[NSImage imageNamed:path]];
    }

    return alert;
    
}

-(void) Action: (id ) sender
{
    if(isSheetModel)
        [NSApp endSheet:_Window returnCode:[sender tag]];
    else
        [NSApp stopModalWithCode:[sender tag]];
    [_Window close];
}

-(NSInteger) RunModel
{
    isSheetModel = NO;
    return [NSApp runModalForWindow:_Window];
    
}

-(void) awakeFromNib
{
    [_Window setDefaultButtonCell:[self.alertOkButton cell]];
}
-(void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    typedef void (*alertDidEnd)(id,SEL,PusicAlert *,int,void *);
    if (isSheetModel) {
        alertDidEnd endFunction=(alertDidEnd)[sheetDelegate methodForSelector:sheetdidEnd];
        endFunction(sheetDelegate,sheetdidEnd,self,returnCode,contextInfo);
    }
    
}

-(void)beginSheetModalForWindow:(NSWindow *)window modalDelegate:delegate didEndSelector:(SEL)selector contextInfo:(void *)info {
    isSheetModel = YES;
    sheetDelegate=delegate;
    sheetdidEnd=selector;
    //设置按钮高亮
    [NSApp beginSheet:_Window modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:info];

}
@end
