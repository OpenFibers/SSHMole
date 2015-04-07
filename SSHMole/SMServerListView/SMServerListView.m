//
//  SMServerListViewController.m
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerListView.h"
#import "NSView+Vibrancy.h"

@interface SMServerListView () <NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation SMServerListView
{
    NSView *_innerXibTableView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
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
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 10;
}

@end
