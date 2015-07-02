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

BlackRaccoon has been tested with an unencrypted FTP server. However, it has NOT been
tested with all manner of usernames and passwords.

Added helper function *initWithDelegate* to major classes.

All FTP operations will either call RequestCompleted for a positive response or
RequestFailed if it is a negative response.

The shouldOverwriteFileWithRequest method is now a required implementation in the code. 

### Added Features

Black Raccoon expands the delegate protocol by adding the following OPTIONAL methods:

    - (void) percentCompleted: (BRRequest *) request;

This is an optional method that allows Black Raccoon to send regular updates
to the user indicating the percent completed. This is from 0.0 to 1.0 and is
accessed via *request.percentCompleted* If you wish to know how much data was
transfered in the last read/write then you can access *request.bytesThisIteration*.
For total bytes it wold be *request.bytesTotal*.

    - (void) requestDataAvailable: (BRRequestDownload *) request;
    
Download now requires a new method. Black Raccoon will have an NSData object in 
*request.receivedData* that the user can then store in a file, another stream, 
or log.
    
Uploading a file has two methods, only one of which is required.

    - (long) requestDataSendSize: (BRRequestUpload *) request
    
This tells Black Raccoon the total size in bytes that will be sent. It is only
used to assure that percentComplete is correct and not in actual transfer of data.
    
    - (NSData *) requestDataToSend: (BRRequestUpload *) request
    
Each block of data is returned as a block of NSData. When done, nil is returned.    
    
### User Defined Functions

There are cases where the user needs to have variables follow the BRRequest. In order to allow this a category was created called BRRequest+_UserData.m and BRRequest+_UserData.h These files have a couple of examples that show how you can add variables as well as methods to BRRequest.

"Add variables? You can't add variables to a category" - technically, no, but you can make it APPEAR as if you did using a dictionary for that purpose. See the example file for details.

### Required Frameworks

BlackRaccoon requires the CFNetwork.framework in order to build correctly.

### iOS 6 and iOS 7

Code has now been implemented to assure proper functionality under iOS 6 and iOS 7.

Unlike some implementations, this checks what version is running before implementing the fix to the leak in Apple's iOS 5 and iOS 6.

### iOS 8 and iOS 9

Currently Black Raccoon (as does most of the Raccoons) deletes files using the *CFURLDestroyResource* method. This method was deprecated in iOS 7. It is this author's opinion that unencrypted FTP will eventually be removed as it poses a risk.

### The Future

If you are currently looking at FTP services, I would would look at full featured FTP packages that were written from the ground up to support FTP. However, if you wish to use Black Raccoon, then read below. 


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
        
        NSMutableData *downloadData;
        NSData *uploadData;
	}



#### Create Directory

	- (IBAction) createDirectory:(id)sender
	{
    	createDir = [[BRRequestCreateDirectory alloc] initWithDelegate: self];
				
		//----- for anonymous login just leave the username and password nil
		createDir.path = @"/home/user/newdirectory/";
		createDir.hostname = @"192.168.1.100";
		createDir.username = @"yourusername";
		createDir.password = @"yourpassword";
		
		//we start the request
		[createDir start];
	}

#### Delete Directory

	- (IBAction) deleteDirectory:(id)sender
	{
		deleteDir = [[BRRequestDelete alloc] initWithDelegate: self];
		
		//----- for anonymous login just leave the username and password nil
		deleteDir.path = @"/home/user/newdirectory/";
		deleteDir.hostname = @"192.168.1.100";
		deleteDir.username = @"yourusername";
		deleteDir.password = @"yourpassword";
		
		//we start the request
		[deleteDir start];
	}

#### List Directory

	- (IBAction) listDirectory:(id)sender
	{
		listDir = [[BRRequestListDirectory alloc] initWithDelegate: self];	
				
		//----- for anonymous login just leave the username and password nil
		listDir.path = @"/home/user/newdirectory/";
		listDir.hostname = @"192.168.1.100";
		listDir.username = @"yourusername";
		listDir.password = @"yourpassword";
		
		[listDir start];
	}

#### Download a File

	- (IBAction) downloadFile :(id)sender
	{
        downloadData = [NSMutableData dataWithCapacity: 1];
    
		downloadFile = [[BRRequestDownload alloc] initWithDelegate: self];
		
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
		uploadData = [NSData dataWithContentsOfFile: filepath];
		
		uploadFile = [[BRRequestUpload alloc] initWithDelegate: self];
		
		//----- for anonymous login just leave the username and password nil
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
		deleteFile = [[BRRequestDelete alloc] initWithDelegate: self];
				
		//----- for anonymous login just leave the username and password nil
		deleteFile.path = @"/home/user/myfile.txt";
		deleteFile.hostname = @"192.168.1.100";
		deleteFile.username = @"yourusername";
		deleteFile.password = @"yourpassword";
		
		//----- we start the request
		[deleteFile start];
	}

    
#### Cancel Upload or Download

    - (IBAction) cancelAction :(id)sender
    {
        if (uploadFile)
        {
            //----- Remove comment if you do not want success delegate called
            //----- upon completion of the cancel
            // uploadFile.cancelDoesNotCallDelegate = TRUE;
            [uploadFile cancelRequest];
        }
        
        if (downloadFile)
        {
            //----- Remove comment if you do not want success delegate called
            //----- upon completion of the cancel
            // downloadFile.cancelDoesNotCallDelegate = TRUE;
            [downloadFile cancelRequest];
        }
    }


#### Delegate callback required to download a file REQUIRED TO DOWNLOAD

    - (void) requestDataAvailable: (BRRequestDownload *) request;
    {
        [downloadData appendData: request.receivedData];
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
    
    
#### Delegate callback to get percent upload, download or directory OPTIONAL
    
    - (void) percentCompleted: (BRRequest *) request
    {
        NSLog(@"%f completed...", request.percentCompleted);
    }


#### Delegate callback to upload a file OPTIONAL TO UPLOAD

    - (long) requestDataSendSize: (BRRequestUpload *) request
    {
        //----- user returns the total size of data to send. Used ONLY for percentComplete
        return [uploadData length];
    }


#### Delegate callback required to upload a file REQUIRED TO UPLOAD

    - (NSData *) requestDataToSend: (BRRequestUpload *) request
    {
        //----- returns data object or nil when complete
        //----- basically, first time we return the pointer to the NSData.
        //----- and BR will upload the data.
        //----- Second time we return nil which means no more data to send
        NSData *temp = uploadData;   // this is a shallow copy of the pointer
        
        uploadData = nil;            // next time around, return nil...
        
        return temp;
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
    
