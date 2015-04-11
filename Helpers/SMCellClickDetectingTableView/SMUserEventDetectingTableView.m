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
        if ([self.userEventDelegate respondsToSelector:@selector(tableView:didClickedRow:)])
        {
            [self.userEventDelegate tableView:self didClickedRow:clickedRow];
        }
    }
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if((key == NSDeleteCharacter) || //backspace
       (key == NSDeleteFunctionKey) || //delete
       (key == NSDeleteCharFunctionKey) || //delete
       (key == 'd' && ([event modifierFlags] & NSControlKeyMask)) //control - D
       )
    {
        if([self selectedRow] == -1)
        {
            NSBeep();
        }
        else
        {
            if ([self.userEventDelegate respondsToSelector:@selector(tableViewDeleteKeyDown:)])
            {
                [self.userEventDelegate tableViewDeleteKeyDown:self];
            }
        }
    }
    
    [super keyDown:event];
}


@end
