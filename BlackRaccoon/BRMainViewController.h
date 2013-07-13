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

@interface BRMainViewController : UIViewController <BRRequestDelegate>
{
    BRRequestCreateDirectory *createDir;
    BRRequestDelete * deleteDir;
    BRRequestListDirectory *listDir;
    
    BRRequestDownload * downloadFile;
    BRRequestUpload *uploadFile;
    BRRequestDelete *deleteFile;
    
    IBOutlet UITextField *host;
    IBOutlet UITextField *path;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    
    IBOutlet UITextView *logview;
    
    NSMutableData *downloadData;
    NSData *uploadData;
}


@end
