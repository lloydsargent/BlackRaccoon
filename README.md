## General Notes

BlackRaccoon is a collection of routines used to act as an FTP client. It was specifically
designed to work correctly under ARC and to "fix" a leak in the listing of directories.

With BlackRaccoon you can:

*	Download a file
*	Upload a file
*	Delete a file
*	Create a directory
*	Delete a directory
*	List a directory

A function to queue requests has been left in the code, but has not been tested. As this
is not a normal FTP function, the user should assume it is deprecated and will be removed
from future releases.

As with WhiteRaccoon, the user needs to assure that the **CFNetwork** framework has been
added to the project.

### Differences Between WhiteRaccoon and BlackRaccoon

BlackRaccoon works correctly with ARC. A lot of time and effort went in to assure there
were no leaks.

BlackRaccoon, unlike WhiteRaccoon, breaks up files by objects. This is for this author's
convenience. If you wish to combine them again, feel free.

BlackRaccoon has been tested with an unencrypted FTP server. However, it has NOT been
tested with all manner of usernames and passwords.

Added helper function *initWithDelegate* to major classes.

All FTP operations will either call RequestCompleted for a positive response or
RequestFailed if it is a negative response.

Made the shouldOverwriteFileWithRequest a required implementation in the code. 

Added an optional percentCompleted to the protocol. It also exists as a float from 0 to 1.0
to indicate completion.


### Usage

The following code assumes the following:

	@interface myclass : NSObject <BRRequestDelegate>
	{
		BRRequestCreateDirectory *createDir;
		BRRequestDelete * deleteDir;
		BRRequestListDirectory *listDir;
		
		BRRequestDownload *downloadFile;
		BRRequestUpload *uploadFile;
		BRRequestDelete *deleteFile;
	}



#### Create Directory

	- (IBAction) createDirectory:(id)sender
	{
    	createDir = [BRRequestCreateDirectory initWithDelegate: self];
				
		//----- for anonymous login just leave the username and password nil
		createDir.path = @"/home/user/newdirectory/;
		createDir.hostname = @"192.168.1.100";
		createDir.username = @"yourusername";
		createDir.password = @"yourpassword";
		
		//we start the request
		[createDir start];
	}

#### Delete Directory

	- (IBAction) deleteDirectory:(id)sender
	{
		deleteDir = [BRRequestDelete initWithDelegate: self];
		
		//----- for anonymous login just leave the username and password nil
		deleteDir.path = @"/home/user/newdirectory/;
		deleteDir.hostname = @"192.168.1.100";
		deleteDir.username = @"yourusername";
		deleteDir.password = @"yourpassword";
		
		//we start the request
		[deleteDir start];
	}

#### List Directory

	- (IBAction) listDirectory:(id)sender
	{
		listDir = [BRRequestListDirectory initWithDelegate: self];	
				
		//----- for anonymous login just leave the username and password nil
		listDir.path = @"/home/user/newdirectory/;
		listDir.hostname = @"192.168.1.100";
		listDir.username = @"yourusername";
		listDir.password = @"yourpassword";
		
		[listDir start];
	}

#### Download a File

	- (IBAction) downloadFile :(id)sender
	{
		downloadFile = [BRRequestDownload initWithDelegate: self];
		
		//----- for anonymous login just leave the username and password nil
		downloadFile.path = @"/home/user/myfile.txt";	
		downloadFile.hostname = @"192.168.1.100";
		downloadFile.username = @"yourusername";
		downloadFile.password = @"yourpassword";
		
		//we start the request
		[downloadFile start];
	}

#### Upload a File

	- (IBAction) uploadFile :(id)sender
	{
		//----- get the file to upload as an NSData object
		NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *filepath = [NSString stringWithFormat: @"%@/%@", applicationDocumentsDir, @"file.text"];
		NSData *dataToUpload = [NSData dataWithContentsOfFile: filepath];
		
		uploadFile = [BRRequestUpload initWithDelegate: self];
		
		//----- for anonymous login just leave the username and password nil
		uploadFile.sentData = dataToUpload;		
		uploadFile.path = @"/home/user/myfile.txt";		
		uploadFile.hostname = @"192.168.1.100";
		uploadFile.username = @"yourusername";
		uploadFile.password = @"yourpassword";
		
		//we start the request
		[uploadFile start];
	}

#### Delete a File

	- (IBAction) deleteFile: (id) sender
	{
		deleteFile = [BRRequestDelete initWithDelegate: self];
				
		//----- for anonymous login just leave the username and password nil
		deleteFile.path = @"/home/user/myfile.txt";
		deleteFile.hostname = @"192.168.1.100";
		deleteFile.username = @"yourusername";
		deleteFile.password = @"yourpassword";
		
		//----- we start the request
		[deleteFile start];
	}

#### Delegate callback to determine if something should be overwritten REQUIRED

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

#### Request Completed REQUIRED

	-(void) requestCompleted: (BRRequest *) request
	{
		//----- handle Create Directory
		if (request == createDir)
		{
			NSLog(@"%@ completed!", request);
			
			createDir = nil;
		}
		
		//----- handle Delete Directory
		if (request == deleteDir)
		{
			NSLog(@"%@ completed!", request);
			
			deleteDir = nil;
		}
		
		//----- handle List Directory
		if (request == listDir)
		{
			//----- called after 'request' is completed successfully
			NSLog(@"%@ completed!", request);
			
			//----- we print each of the file names
			for (NSDictionary *file in listDir.filesInfo) 
			{
				NSLog(@"%@", [file objectForKey: (id) kCFFTPResourceName]);
			}
			
			logview.text = [NSString stringWithFormat: @"%@\n", logview.text];
			[logview scrollRangeToVisible: NSMakeRange([logview.text length] - 1, 1)];
						
			listDir = nil;
		}
		
		//----- handle Download File
		if (request == downloadFile)
		{
			//called after 'request' is completed successfully
			NSLog(@"%@ completed!", request);
			
			NSData *data = downloadFile.receivedData;
			
			//----- save the NSData as a file object
			NSError *error;
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

#### Request Failed REQUIRED

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
    
#### Percent Completed OPTIONAL
    
    - (void) percentCompleted: (BRRequest *) request
    {
        NSLog(@"%f completed...", request.percentCompleted);
    }

