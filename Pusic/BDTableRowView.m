//
//  BDTableRowView.m
//  CustomCellView
//
//  Created by Beidou on 15/4/24.
//  Copyright (c) 2015年 Beidou. All rights reserved.
//

#import "BDTableRowView.h"

static BDTableRowView* instance = nil;

@implementation BDTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    [[NSColor grayColor] setFill];
    NSRectFill(dirtyRect);
}


- (void)drawBackgroundInRect:(NSRect)dirtyRect{
    [[NSColor gridColor] setFill];
    NSRectFill(dirtyRect);

}
- (NSRect)separatorRect {
    NSRect separatorRect = self.bounds;
    separatorRect.origin.y = NSMaxY(separatorRect) - 1;
    separatorRect.size.height = 1;
    return separatorRect;
}

- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleLight;
}
static NSGradient *gradientWithTargetColor(NSColor *targetColor) {
    NSArray *colors = [NSArray arrayWithObjects:[targetColor colorWithAlphaComponent:0], targetColor, targetColor, [targetColor colorWithAlphaComponent:0], nil];
    const CGFloat locations[4] = { 0.0, 0.35, 0.65, 1.0 };
    return [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];
}

//初始化分割线
//- (void)drawSeparatorInRect:(NSRect)dirtyRect{
//    [[NSColor greenColor] setFill];
//        NSRectFill([self separatorRect]);
//   //    DrawSeparatorInRect([self separatorRect]);
//
//}
//-(void) DrawSeparatorInRect:(NSRect) rect {
//    // Cache the gradient for performance
//    static NSGradient *gradient = nil;
//    if (gradient == nil) {
//        gradient = gradientWithTargetColor([NSColor colorWithSRGBRed:.80 green:.80 blue:.80 alpha:1]);
//    }
//    [gradient drawInRect:rect angle:0];
//    
//}

@end
void DrawSeparatorInRect(NSRect rect) {
    // Cache the gradient for performance
    static NSGradient *gradient = nil;
    if (gradient == nil) {
        gradient = gradientWithTargetColor([NSColor colorWithSRGBRed:.180 green:.180 blue:.180 alpha:1]);
    }
    [gradient drawInRect:rect angle:0];
    
}