//
//  ViewController.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "ViewController.h"
#import "SMServerConfigStorage.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)addServerConfig
{
    SMServerConfig *config = [[SMServerConfig alloc] init];
    config.serverName = @"123123";
    config.account = @"root";
    config.password = @"123123";
    config.serverPort = 22;
    config.localPort = 7070;
    [[SMServerConfigStorage defaultStorage] addConfig:config];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
