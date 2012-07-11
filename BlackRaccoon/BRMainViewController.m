//----------
//
//				BRMainViewController.m
//
// filename:	BRMainViewController.m
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
#import "BRMainViewController.h"



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

@implementation BRMainViewController



//-----
//
//				viewDidLoad
//
// synopsis:	[self viewDidLoad];
//
// description:	viewDidLoad is designed to
//
// errors:		none
//
// returns:		none
//

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}



//-----
//
//				viewDidUnload
//
// synopsis:	[self viewDidUnload];
//
// description:	viewDidUnload is designed to
//
// errors:		none
//
// returns:		none
//

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



//-----
//
//				shouldAutorotateToInterfaceOrientation
//
// synopsis:	retval = [self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
//					BOOL retval                                	-
//					UIInterfaceOrientation interfaceOrientation	-
//
// description:	shouldAutorotateToInterfaceOrientation is designed to
//
// errors:		none
//
// returns:		Variable of type BOOL
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - FTP examples



//-----
//
//				createDirectory
//
// synopsis:	retval = [self createDirectory:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	createDirectory is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) createDirectory:(id)sender
{
    createDir = [BRRequestCreateDirectory initWithDelegate: self];
    
    //the path needs to be absolute to the FTP root folder.
    createDir.path = path.text;
    
    createDir.hostname = host.text;
    createDir.username = username.text;
    createDir.password = password.text;
    
    //we start the request
    [createDir start];

}



//-----
//
//				deleteDirectory
//
// synopsis:	retval = [self deleteDirectory:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	deleteDirectory is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) deleteDirectory:(id)sender
{
    deleteDir = [BRRequestDelete initWithDelegate: self];
    
    //the path needs to be absolute to the FTP root folder.
    deleteDir.path = path.text;
    
    deleteDir.hostname = host.text;
    deleteDir.username = username.text;
    deleteDir.password = password.text;
    
    //we start the request
    [deleteDir start];
}



//-----
//
//				listDirectory
//
// synopsis:	retval = [self listDirectory:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	listDirectory is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) listDirectory:(id)sender
{
    listDir = [BRRequestListDirectory initWithDelegate: self];
    
    //the path needs to be absolute to the FTP root folder.
    listDir.path = path.text;
    
    listDir.hostname = host.text;
    listDir.username = username.text;
    listDir.password = password.text;
    
    [listDir start];
}



//-----
//
//				downloadFile
//
// synopsis:	retval = [self downloadFile:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	downloadFile is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) downloadFile :(id)sender
{
    downloadFile = [BRRequestDownload initWithDelegate: self];
    
    //the path needs to be absolute to the FTP root folder.
    downloadFile.path = path.text;
    
    //for anonymous login just leave the username and password nil
    downloadFile.hostname = host.text;
    downloadFile.username = username.text;
    downloadFile.password = password.text;
    
    //we start the request
    [downloadFile start];
}



//-----
//
//				uploadFile
//
// synopsis:	retval = [self uploadFile:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	uploadFile is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) uploadFile :(id)sender
{
    //----- get the file to upload as an NSData object
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat: @"%@/%@", applicationDocumentsDir, @"image.jpg"];
    NSData *dataToUpload = [NSData dataWithContentsOfFile: filepath];
    
    uploadFile = [BRRequestUpload initWithDelegate: self];
    
    uploadFile.sentData = dataToUpload;
    
    //the path needs to be absolute to the FTP root folder.
    uploadFile.path = path.text;
    
    //for anonymous login just leave the username and password nil
    uploadFile.hostname = host.text;
    uploadFile.username = username.text;
    uploadFile.password = password.text;
    
    //we start the request
    [uploadFile start];
}



//-----
//
//				deleteFile
//
// synopsis:	retval = [self deleteFile:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	deleteFile is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) deleteFile: (id) sender
{
    deleteFile = [BRRequestDelete initWithDelegate: self];
    
    //----- the path needs to be absolute to the FTP root folder.
    deleteFile.path = path.text;
    
    //----- for anonymous login just leave the username and password nil
    deleteFile.hostname = host.text;
    deleteFile.username = username.text;
    deleteFile.password = password.text;
    
    //----- we start the request
    [deleteFile start];
}



//-----
//
//				shouldOverwriteFileWithRequest
//
// synopsis:	retval = [self shouldOverwriteFileWithRequest:request];
//					BOOL retval       	-
//					BRRequest *request	-
//
// description:	shouldOverwriteFileWithRequest is designed to
//
// errors:		none
//
// returns:		Variable of type BOOL
//

-(BOOL) shouldOverwriteFileWithRequest: (BRRequest *) request
{
    //----- set this as appropriate if you want the file to be overwritten
    if (request == uploadFile)
    {
        //----- if uploading a file, we set it to YES
        return YES;
    }
    
    //----- anything else (directories, etc) we set to NO
    return NO;
}



//-----
//
//				requestCompleted
//
// synopsis:	[self requestCompleted:request];
//					BRRequest *request	-
//
// description:	requestCompleted is designed to
//
// errors:		none
//
// returns:		none
//

-(void) requestCompleted: (BRRequest *) request
{
    if (request == createDir)
    {
        NSLog(@"%@ completed!", request);
        
        createDir = nil;
    }
    
    if (request == deleteDir)
    {
        NSLog(@"%@ completed!", request);
        
        deleteDir = nil;
    }
    
    if (request == listDir)
    {
        //called after 'request' is completed successfully
        NSLog(@"%@ completed!", request);
        
        //we print each of the files name
        for (NSDictionary *file in listDir.filesInfo) 
        {
            NSLog(@"%@", [file objectForKey:(id)kCFFTPResourceName]);
            
            logview.text = [NSString stringWithFormat: @"%@\n%@", logview.text, [file objectForKey:(id)kCFFTPResourceName]];
        }
        
        logview.text = [NSString stringWithFormat: @"%@\n", logview.text];
        [logview scrollRangeToVisible: NSMakeRange([logview.text length] - 1, 1)];
        
        NSLog(@"%@", listDir.filesInfo);
        
        listDir = nil;
    }
    
    if (request == downloadFile)
    {
        //called after 'request' is completed successfully
        NSLog(@"%@ completed!", request);
        
        NSError *error;
        NSData *data = downloadFile.receivedData;
        
        //----- save the NSData as a file object
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filepath = [NSString stringWithFormat: @"%@/%@", applicationDocumentsDir, @"image.jpg"];
        
        [data writeToFile: filepath options: NSDataWritingFileProtectionNone error: &error];
        downloadFile = nil;
    }
    
    if (request == uploadFile)
    {
        NSLog(@"%@ completed!", request);
        uploadFile = nil;
    }
    
    if (request == deleteFile)
    {
        NSLog(@"%@ completed!", request);
        deleteFile = nil;
    }
    
}



//-----
//
//				requestFailed
//
// synopsis:	[self requestFailed:request];
//					BRRequest *request	-
//
// description:	requestFailed is designed to
//
// errors:		none
//
// returns:		none
//

-(void) requestFailed:(BRRequest *) request
{
    if (request == createDir)
    {
        NSLog(@"%@", request.error.message);
        
        createDir = nil;
    }
    
    if (request == deleteDir)
    {
        NSLog(@"%@", request.error.message);
        
        deleteDir = nil;
    }
    
    if (request == listDir)
    {
        logview.text = [NSString stringWithFormat: @"%@\n\nList Dir Failed with %@", logview.text, request.error.message];
        
        //called if 'request' ends in error
        //we can print the error message
        NSLog(@"%@", request.error.message);
        
        listDir = nil;
    }
    
    if (request == downloadFile)
    {
        NSLog(@"%@", request.error.message);
        
        downloadFile = nil;
    }
    
    if (request == uploadFile)
    {
        NSLog(@"%@", request.error.message);
        
        uploadFile = nil;
    }
    
    if (request == deleteFile)
    {
        NSLog(@"%@", request.error.message);
        deleteFile = nil;
    }
}




- (IBAction) clearLog: (id) button
{
    logview.text = nil;
}


@end
