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
    createDir = [[BRRequestCreateDirectory alloc] initWithDelegate:self];
    
    createDir.hostname = host.text;
    createDir.path = path.text;
    createDir.username = username.text;
    createDir.password = password.text;
    
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
    deleteDir = [[BRRequestDelete alloc] initWithDelegate:self];
        
    deleteDir.hostname = host.text;
    deleteDir.path = path.text;
    deleteDir.username = username.text;
    deleteDir.password = password.text;
    
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
    listDir = [[BRRequestListDirectory alloc] initWithDelegate:self];
    
    listDir.hostname = host.text;
    listDir.path = path.text;
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
    downloadData = [NSMutableData dataWithCapacity: 1];
    
    downloadFile = [[BRRequestDownload alloc] initWithDelegate:self];
    downloadFile.hostname = host.text;
    downloadFile.path = path.text;
    downloadFile.username = username.text;
    downloadFile.password = password.text;
    
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
    uploadData = [NSData dataWithContentsOfFile: filepath];
    
    uploadFile = [[BRRequestUpload alloc] initWithDelegate:self];
    uploadFile.path = path.text;
    uploadFile.hostname = host.text;
    uploadFile.username = username.text;
    uploadFile.password = password.text;
    
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
    deleteFile = [[BRRequestDelete alloc] initWithDelegate:self];
    deleteFile.hostname = host.text;
    deleteFile.path = path.text;
    deleteFile.username = username.text;
    deleteFile.password = password.text;
    
    [deleteFile start];
}



//-----
//
//				cancelAction
//
// synopsis:	retval = [self cancelAction:sender];
//					IBAction retval	-
//					id sender      	-
//
// description:	cancelAction is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) cancelAction :(id)sender
{
    if (uploadFile)
    {
        uploadFile.cancelDoesNotCallDelegate = TRUE;
        [uploadFile cancelRequest];
    }
    
    if (downloadFile)
    {
        downloadFile.cancelDoesNotCallDelegate = TRUE;
        [downloadFile cancelRequest];
    }
}



//-----
//
//				requestDataAvailable
//
// synopsis:	[self requestDataAvailable:request];
//					BRRequestDownload *request	-
//
// description:	requestDataAvailable is used as part of the file download.
//
// important:   This is required to download data. If this method is missing
//              and you attempt to download, you will get a runtime error.
//
// errors:		none
//
// returns:		none
//

- (void) requestDataAvailable: (BRRequestDownload *) request;
{
    [downloadData appendData: request.receivedData];
}
     
     
     
//-----
//
//				shouldOverwriteFileWithRequest
//
// synopsis:	retval = [self shouldOverwriteFileWithRequest:request];
//					BOOL retval       	-
//					BRRequest *request	-
//
// description:	shouldOverwriteFileWithRequest is designed to determine if it is
//              okay to overwrite a file on the server. Currently, we can not
//              overwrite directories.
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
//				percentCompleted
//
// synopsis:	[self percentCompleted:request];
//					BRRequest *request	-
//
// description:	percentCompleted is designed to
//
// errors:		none
//
// returns:		none
//

- (void) percentCompleted: (BRRequest *) request
{
    NSLog(@"%f completed...", request.percentCompleted);
    NSLog(@"%ld bytes this iteration", request.bytesSent);
    NSLog(@"%ld total bytes", request.totalBytesSent);
}



//-----
//
//				requestDataSendSize
//
// synopsis:	retval = [self requestDataSendSize:request];
//					long retval             	-
//					BRRequestUpload *request	-
//
// description:	requestDataSendSize is designed to
//
// important:   This is an optional method when uploading. It is purely used
//              to help calculate the percent completed.
//
//              If this method is missing, then the send size defaults to LONG_MAX
//              or about 2 gig.
//
// errors:		none
//
// returns:		Variable of type long
//

- (long) requestDataSendSize: (BRRequestUpload *) request
{
    //----- user returns the total size of data to send. Used ONLY for percentComplete
    return [uploadData length];
}



//-----
//
//				requestDataToSend
//
// synopsis:	retval = [self requestDataToSend:request];
//					NSData *retval          	-
//					BRRequestUpload *request	-
//
// description:	requestDataToSend is designed to hand off the BR the next block
//              of data to upload to the FTP server. It continues to call this
//              method for more data until nil is returned.
//
// important:   This is a required method for uploading data to an FTP server.
//              If this method is missing, it you will get a runtime error indicating
//              this method is missing.
//
// errors:		none
//
// returns:		Variable of type NSData *
//

- (NSData *) requestDataToSend: (BRRequestUpload *) request
{
    //----- returns data object or nil when complete
    //----- basically, first time we return the pointer to the NSData.
    //----- and BR will upload the data.
    //----- Second time we return nil which means no more data to send
    NSData *temp = uploadData;                                                  // this is a shallow copy of the pointer, not a deep copy
    
    uploadData = nil;                                                           // next time around, return nil...
    
    return temp;
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
        
        //----- save the downloadData as a file object
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filepath = [NSString stringWithFormat: @"%@/%@", applicationDocumentsDir, @"image.jpg"];
        
        [downloadData writeToFile: filepath options: NSDataWritingFileProtectionNone error: &error];
        downloadData = nil;
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



//-----
//
//				clearLog
//
// synopsis:	retval = [self clearLog:button];
//					IBAction retval	-
//					id button      	-
//
// description:	clearLog is designed to
//
// errors:		none
//
// returns:		Variable of type IBAction
//

- (IBAction) clearLog: (id) button
{
    logview.text = nil;
}


@end
