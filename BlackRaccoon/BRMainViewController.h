//----------
//
//				BRMainViewController.h
//
// filename:	BRMainViewController.h
//
// author:		Lloyd Sargent
//
// created:		Jul 11, 2012
//
// description:	
//
// notes:		none
//
// revisions:	
//
// Copyright (c) 2012 Canna Software. All rights reserved.
//



//---------- pragmas



//---------- include files
#import "BRRequestListDirectory.h"
#import "BRRequestCreateDirectory.h"
#import "BRRequestUpload.h"
#import "BRRequestDownload.h"
#import "BRRequestDelete.h"
#import "BRRequest+_UserData.h"
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

@interface BRMainViewController : UIViewController <BRRequestDelegate, BRButtonControllerProtocol>
{
    BRRequestCreateDirectory *createDir;
    BRRequestDelete * deleteDir;
    BRRequestListDirectory *listDir;
    
    BRRequestDownload * downloadFile;
    BRRequestUpload *uploadFile;
    BRRequestDelete *deleteFile;
    
    __weak IBOutlet UITextField *host;
    __weak IBOutlet UITextField *path;
    __weak IBOutlet UITextField *username;
    __weak IBOutlet UITextField *password;
    
    __weak IBOutlet UITextView *logview;
    
    __weak IBOutlet UIView *buttonContainerView;
    
    NSMutableData *downloadData;
    NSData *uploadData;
}

- (void) createDirectory;
- (void) deleteDirectory;
- (void) listDirectory;
- (void) downloadFile;
- (void) uploadFile;
- (void) deleteFile;
- (void) cancelAction;


@end
