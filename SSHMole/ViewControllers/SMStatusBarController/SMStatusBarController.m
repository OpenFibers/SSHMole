//
//  SMStatusBarController.m
//  SSHMole
//
//  Created by 史江浩 on 6/25/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMStatusBarController.h"
#import <AppKit/AppKit.h>

@interface SMStatusBarController ()
@property (nonatomic, strong) NSStatusItem *statusBar;
@end

@implementation SMStatusBarController
{
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initStatusBarIcon];
    }
    return self;
}

- (void)initStatusBarIcon
{
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:44];
    
    self.statusBar.title = @"";
    
    NSImage *statusBarImage = [NSImage imageNamed:@"StatusBarPawIcon"];
    [statusBarImage setTemplate:YES];
    self.statusBar.image = statusBarImage;
    
//    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}

@end
