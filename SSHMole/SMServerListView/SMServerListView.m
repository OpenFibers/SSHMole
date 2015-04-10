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
#import "SMCellClickDetectingTableView.h"

@interface SMServerListView () <NSTableViewDataSource, NSTableViewDelegate, SMCellClickDetectingTableViewDelegate>

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
    
    //Load images
    _redLightImage = [NSImage imageNamed:@"ServerListRedLight"];
    _yellowLightImage = [NSImage imageNamed:@"ServerListYellowLight"];
    _greenLightImage = [NSImage imageNamed:@"ServerListGreenLight"];
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
            [cellView.imageView setImage:_redLightImage];
        }
        return cellView;
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row
{
    NSLog(@"%zd", row);
}

@end
