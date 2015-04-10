//
//  SMCellClickDetectingTableView.h
//  SSHMole
//
//  Created by 史江浩 on 4/10/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@protocol SMCellClickDetectingTableViewDelegate <NSObject>

- (void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row;

@end

@interface SMCellClickDetectingTableView : NSTableView

@property (nonatomic, weak) IBOutlet id <SMCellClickDetectingTableViewDelegate> cellClickDelegate;

@end
