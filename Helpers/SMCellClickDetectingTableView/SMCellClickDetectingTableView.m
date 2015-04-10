//
//  SMCellClickDetectingTableView.m
//  SSHMole
//
//  Created by 史江浩 on 4/10/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMCellClickDetectingTableView.h"

@implementation SMCellClickDetectingTableView

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    
    [super mouseDown:theEvent];
    
    if (clickedRow != -1)
    {
        [self.cellClickDelegate tableView:self didClickedRow:clickedRow];
    }
}

@end
