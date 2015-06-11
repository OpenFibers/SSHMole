//
//  SMCellClickDetectingTableView.h
//  SSHMole
//
//  Created by openthread on 4/10/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@protocol SMUserEventDetectingTableViewDelegate <NSObject>

@optional
- (void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row;
- (void)tableViewDeleteKeyDown:(NSTableView *)tableView;

@end

@interface SMUserEventDetectingTableView : NSTableView

@property (nonatomic, weak) IBOutlet id <SMUserEventDetectingTableViewDelegate> userEventDelegate;

@end
