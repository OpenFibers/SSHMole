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
#import "SMUserEventDetectingTableView.h"

@interface SMServerListView () <NSTableViewDataSource, NSTableViewDelegate, SMUserEventDetectingTableViewDelegate>
@property (nonatomic, weak) IBOutlet SMUserEventDetectingTableView *tableView;
@end

@implementation SMServerListView
{
    NSView *_innerXibTableView;
    NSMutableArray *_serverConfigs;
    NSImage *_redLightImage;
    NSImage *_yellowLightImage;
    NSImage *_greenLightImage;
    NSImage *_settingImage;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self reloadData];
        [self performSelector:@selector(loadView) withObject:nil afterDelay:0];
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
    [self.tableView.delegate tableViewSelectionDidChange:nil];
}

- (void)reloadData
{
    _serverConfigs = [[[SMServerConfigStorage defaultStorage] configs] mutableCopy];
    [self.tableView reloadData];
}

- (NSUInteger)indexOfConfig:(SMServerConfig *)config
{
    NSUInteger index = [_serverConfigs indexOfObject:config];
    return index;
}

- (void)reloadRowForServerConfig:(SMServerConfig *)config atIndex:(NSUInteger)index
{
    if (index >= _serverConfigs.count)
    {
        return;
    }
    
    [self.tableView beginUpdates];
    if (_serverConfigs[index] != config)//config object changed at this index
    {
        //change it
        [_serverConfigs replaceObjectAtIndex:index withObject:config];
    }
    NSIndexSet *rowIndexSet = [NSIndexSet indexSetWithIndex:index];
    NSIndexSet *columnIndexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadDataForRowIndexes:rowIndexSet columnIndexes:columnIndexSet];
    [self.tableView endUpdates];
}

- (void)addServerConfig:(SMServerConfig *)config
{
    [self insertServerConfig:config atIndex:_serverConfigs.count];
}

- (void)insertServerConfig:(SMServerConfig *)config atIndex:(NSUInteger)index
{
    [self.tableView beginUpdates];
    [_serverConfigs insertObject:config atIndex:index];
    NSIndexSet *addedIndex = [NSIndexSet indexSetWithIndex:_serverConfigs.count];
    [self.tableView insertRowsAtIndexes:addedIndex withAnimation:NSTableViewAnimationEffectGap];
    [self.tableView endUpdates];
}

- (void)removeServerConfig:(SMServerConfig *)config
{
    if (![_serverConfigs containsObject:config])
    {
        return;
    }
    [self.tableView beginUpdates];
    NSUInteger index = [_serverConfigs indexOfObject:config];
    NSIndexSet *removedIndex = [NSIndexSet indexSetWithIndex:index];
    [self.tableView removeRowsAtIndexes:removedIndex withAnimation:NSTableViewAnimationEffectGap];
    [_serverConfigs removeObject:config];
    [self.tableView endUpdates];
}

#pragma mark - Table view callback

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
            if (!_settingImage)
            {
                _settingImage = cellView.imageView.image;
            }
            else
            {
                cellView.imageView.image = _settingImage;
            }
        }
        else//View for added configs
        {
            SMServerConfig *config = _serverConfigs[row];
            [cellView.textField setStringValue:[config accountStringForDisplay]];
            if ([[SMSSHTaskManager defaultManager] currentConfig] == config)
            {
                switch ([[SMSSHTaskManager defaultManager] currentConnectionStatus])
                {
                    case SMSSHTaskStatusConnecting:
                        [cellView.imageView setImage:_yellowLightImage];
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
        [self.delegate serverListView:self didPickConfig:config];
    }
    else
    {
        [self.delegate serverListViewDidPickAddConfig:self];
    }
}

- (void)tableViewDeleteKeyDown:(NSTableView *)tableView
{
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < _serverConfigs.count)
    {
        SMServerConfig *config = _serverConfigs[selectedRow];
        [self.delegate serverListViewDeleteKeyDown:self onConfig:config];
    }
}

@end
