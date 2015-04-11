//
//  SMServerListViewController.m
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerListView.h"
#import "SMServerConfigStorage.h"
#import "SMSSHTaskManager.h"

@interface SMServerListView () <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@end

@implementation SMServerListView
{
    NSView *_innerXibTableView;
    NSArray *_serverConfigs;
    NSImage *_redLightImage;
    NSImage *_yellowLightImage;
    NSImage *_greenLightImage;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self loadView];
        [self reloadData];
    }
    return self;
}

- (void)loadView
{
    //Load table from xib
    NSArray *array = nil;
    [[NSBundle mainBundle] loadNibNamed:@"ServerListTable" owner:self topLevelObjects:&array];
    for (NSView *subObject in array)
    {
        if ([subObject isKindOfClass:[NSView class]])
        {
            _innerXibTableView = subObject;
            _innerXibTableView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            [self addSubview:subObject];
            break;
        }
    }
    
    //Set auto-save properties
    [self.tableView setAutosaveName:@"ServerListTableView"];
    [self.tableView setAutosaveTableColumns:YES];
    
    //Load images
    _redLightImage = [NSImage imageNamed:@"ServerListRedLight"];
    _yellowLightImage = [NSImage imageNamed:@"ServerListYellowLight"];
    _greenLightImage = [NSImage imageNamed:@"ServerListGreenLight"];
    
    //Set initial table selected index
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)reloadData
{
    _serverConfigs = [[SMServerConfigStorage defaultStorage] configs];
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _serverConfigs.count + 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:@"ServerListColumn"])
    {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"ServerListCellView" owner:self];
        if (row >= _serverConfigs.count)//View for "Add new config"
        {
            [cellView.textField setStringValue:@"Add new config"];
        }
        else//View for added configs
        {
            SMServerConfig *config = _serverConfigs[row];
            [cellView.textField setStringValue:config.serverAddress];
            if ([[SMSSHTaskManager defaultManager] currentConfig] == config)
            {
                switch ([[SMSSHTaskManager defaultManager] currentConnectionStatus])
                {
                    case SMSSHTaskStatusConnecting:
                        [cellView.imageView setImage:_redLightImage];
                        break;
                    case SMSSHTaskStatusConnected:
                        [cellView.imageView setImage:_greenLightImage];
                        break;
                    case SMSSHTaskStatusDisconnected:
                    case SMSSHTaskStatusErrorOccured:
                        [cellView.imageView setImage:_redLightImage];
                        break;
                }
            }
            else
            {
                [cellView.imageView setImage:_redLightImage];
            }
        }
        return cellView;
    }
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < _serverConfigs.count)
    {
        SMServerConfig *config = _serverConfigs[selectedRow];
        [self.delegate serverListView:self didPickAddConfig:config];
    }
    else
    {
        [self.delegate serverListViewDidPickAddConfig:self];
    }
}

@end
