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

NSString *const SMServerListViewAnyConfigChangedNotification = @"SMServerListViewAnyConfigChangedNotification";
NSString *const SMServerListViewAnyConfigChangedNotificationServerConfigsKey = @"ServerConfigs";

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

- (void)layout
{
    _innerXibTableView.frame = self.bounds;
    [super layout];
}

- (void)reloadData
{
    _serverConfigs = [[[SMServerConfigStorage defaultStorage] configs] mutableCopy];
    [self.tableView reloadData];
    [self postServerConfigChangedNotification];
}

- (NSUInteger)indexOfConfig:(SMServerConfig *)config
{
    NSUInteger index = NSNotFound;
    for (SMServerConfig *eachConfig in _serverConfigs)
    {
        if ([config.identifierString isEqualToString:eachConfig.identifierString])
        {
            index = [_serverConfigs indexOfObject:eachConfig];
            break;
        }
    }
    return index;
}

- (NSUInteger)configCount
{
    NSUInteger serverConfigCount = _serverConfigs.count;
    return serverConfigCount;
}

- (NSUInteger)selectedIndex
{
    NSUInteger index = [self.tableView selectedRow];
    return index;
}

- (void)setSelectedIndex:(NSUInteger)index
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)reloadRowForServerConfig:(SMServerConfig *)config
{
    [self reloadRowForServerConfig:config atIndex:NSNotFound];
}

- (void)reloadRowForServerConfig:(SMServerConfig *)config atIndex:(NSUInteger)inputIndex
{
    NSUInteger actualConfigIndex = inputIndex;
    if (actualConfigIndex == NSNotFound)//if called did not give a input index
    {
        //find the actual config index
        for (SMServerConfig *eachConfig in _serverConfigs)
        {
            if ([eachConfig.identifierString isEqualToString:config.identifierString])
            {
                actualConfigIndex = [_serverConfigs indexOfObject:eachConfig];
                break;
            }
        }
    }
    
    if (actualConfigIndex == NSNotFound)//if actual config index not found, return
    {
        return;
    }
    
    [self.tableView beginUpdates];
    if (_serverConfigs[actualConfigIndex] != config)//config object changed at this index
    {
        //change it
        [_serverConfigs replaceObjectAtIndex:actualConfigIndex withObject:config];
    }
    NSIndexSet *rowIndexSet = [NSIndexSet indexSetWithIndex:actualConfigIndex];
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
    SMServerConfig *existingConfigToRemove = nil;
    NSUInteger existingIndex = NSNotFound;
    for (SMServerConfig *existingConfig in _serverConfigs)
    {
        if ([existingConfig.identifierString isEqualToString:config.identifierString])
        {
            existingConfigToRemove = existingConfig;
            existingIndex = [_serverConfigs indexOfObject:existingConfigToRemove];
            break;
        }
    }
    if (existingConfigToRemove)
    {
        [self.tableView beginUpdates];
        [_serverConfigs replaceObjectAtIndex:existingIndex withObject:config];
        NSIndexSet *reloadIndex = [NSIndexSet indexSetWithIndex:existingIndex];
        [self.tableView reloadDataForRowIndexes:reloadIndex columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self.tableView endUpdates];
        [self postServerConfigChangedNotification];
    }
    else
    {
        [self.tableView beginUpdates];
        [_serverConfigs insertObject:config atIndex:index];
        NSIndexSet *addedIndex = [NSIndexSet indexSetWithIndex:_serverConfigs.count];
        NSIndexSet *reloadIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, _serverConfigs.count - index)];
        [self.tableView insertRowsAtIndexes:addedIndex withAnimation:NSTableViewAnimationEffectFade];
        [self.tableView reloadDataForRowIndexes:reloadIndex columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self.tableView endUpdates];
        [self postServerConfigChangedNotification];
    }
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
    [self postServerConfigChangedNotification];
}

- (void)selectConfig:(SMServerConfig *)config
{
    NSUInteger index = _serverConfigs.count;
    if ([_serverConfigs containsObject:config])
    {
        [_serverConfigs indexOfObject:config];
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

#pragma mark - Any Server Config Changed

- (void)postServerConfigChangedNotification
{
    NSDictionary *userInfo = nil;
    if (_serverConfigs)
    {
        userInfo = @{SMServerListViewAnyConfigChangedNotificationServerConfigsKey : [NSArray arrayWithArray:_serverConfigs]};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SMServerListViewAnyConfigChangedNotification
                                                        object:self
                                                      userInfo:userInfo];
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
            if ([[SMSSHTaskManager defaultManager] connectingConfig] == config)
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
