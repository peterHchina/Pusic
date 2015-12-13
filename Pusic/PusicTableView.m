//
//  PusicTableView.m
//  Pusic
//
//  Created by peter on 15/4/20.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PusicTableView.h"

@implementation PusicTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect bounds = [self bounds];
    [bgColor set];
    [NSBezierPath fillRect:bounds];
    
    // Draw gradient background if highlighted
    if (highlighted) {
        NSGradient *gr;
        gr = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor]
                                           endingColor:bgColor];
        [gr drawInRect:bounds relativeCenterPosition:NSZeroPoint];
    } else {
        [bgColor set];
        [NSBezierPath fillRect:bounds];
    }
    // Am I the window's first responder?
    if (([[self window] firstResponder] == self) &&[NSGraphicsContext currentContextDrawingToScreen])
    {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [NSBezierPath fillRect:bounds];
        [NSGraphicsContext restoreGraphicsState];
    }

    // Drawing code here.
}

-(id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
        if (self) {
            NSLog(@"initializing view");
           bgColor = [NSColor yellowColor];
            [self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeString]];
        }
        
        return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingEntered:");
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    highlighted = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSDragOperation op = [sender draggingSourceOperationMask];
    NSLog(@"operation mask = %ld", op);
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    return NSDragOperationCopy;
}
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingExited:");
    highlighted = NO;
    [self setNeedsDisplay:YES];
}
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    if(![self readFromPasteboard:pb]) {
        NSLog(@"Error: Could not read from dragging pasteboard");
        return NO;
    }
    return YES;
}
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSLog(@"concludeDragOperation:");
    highlighted = NO;
    [self setNeedsDisplay:YES];
}


- (BOOL)readFromPasteboard:(NSPasteboard *)pb
{
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSArray *objects = [pb readObjectsForClasses:classes
                                         options:nil];
    if ([objects count] > 0)
    {
        // Read the string from the pasteboard
        NSString *value = [objects objectAtIndex:0];
        
        NSLog(@"%@",value);
        return YES;
    }
    return NO; 
}
@end
