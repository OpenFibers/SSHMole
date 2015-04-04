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

- (void)viewDidLoad {
    [super viewDidLoad];

    [SMServerConfigStorage defaultStorage];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
