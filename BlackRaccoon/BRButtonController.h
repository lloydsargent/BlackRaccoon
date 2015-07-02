//----------
//
//              BRButtonController.h
//
// filename:    BRButtonController.h
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
@class BRButtonController;
@protocol BRButtonControllerProtocol <NSObject>

- (void) buttonWasPushed: (BRButtonController *) controller button: (NSInteger) button;

@end



//---------- classes
#import <UIKit/UIKit.h>

@interface BRButtonController : UITableViewController

@property (weak) id <BRButtonControllerProtocol> delegate;

@end
