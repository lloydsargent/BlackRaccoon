//----------
//
//              BRButtonController.m
//
// filename:    BRButtonController.m
//
// author:      Lloyd Sargent
//
// created:     2015 Jul 02
//
// description:
//
// notes:       none
//
// revisions:
//
// Copyright 2012 Lloyd Sargent. All rights reserved.
//



//---------- pragmas



//---------- include files
#import "BRButtonController.h"



//---------- enumerated data types



//---------- typedefs



//---------- definitions



//---------- structs



//---------- external functions



//---------- external variables



//---------- global functions



//---------- local functions



//---------- global variables



//---------- local variables



//---------- protocols



//---------- classes

#import "BRButtonController.h"

@interface BRButtonController ()

@end

@implementation BRButtonController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate buttonWasPushed: self button: indexPath.section];

}


@end
