//
//  SMCellClickDetectingTableView.m
//  SSHMole
//
//  Created by 史江浩 on 4/10/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMUserEventDetectingTableView.h"

@implementation SMUserEventDetectingTableView

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    
    [super mouseDown:theEvent];
    
    if (clickedRow != -1)
    {
        [self.userEventDelegate tableView:self didClickedRow:clickedRow];
    }
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        if([self selectedRow] == -1)
        {
            NSBeep();
        }
        else
        {
            [self.userEventDelegate tableViewDeleteKeyDown:self];
        }
    }
    
    [super keyDown:event];
}


@end
