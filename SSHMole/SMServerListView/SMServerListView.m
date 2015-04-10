//
//  SMServerListViewController.m
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerListView.h"
#import "NSView+Vibrancy.h"
#import "SMServerConfigStorage.h"

@interface SMServerListView () <NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation SMServerListView
{
    NSView *_innerXibTableView;
    NSArray *_serverConfigs;
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
}

- (void)reloadData
{
    _serverConfigs = [[SMServerConfigStorage defaultStorage] configs];
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
            [cellView.textField setStringValue:config.serverName];
        }
        return cellView;
    }
    return nil;
}

@end
