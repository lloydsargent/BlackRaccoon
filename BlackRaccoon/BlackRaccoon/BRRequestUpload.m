//----------
//
//				BRRequestUpload.m
//
// filename:	BRRequestUpload.m
//
// author:		Created by Valentin Radu on 8/23/11.
//              Copyright 2011 Valentin Radu. All rights reserved.
//
//              Modified and/or redesigned by Lloyd Sargent to be ARC compliant.
//              Copyright 2012 Lloyd Sargent. All rights reserved.
//
// created:		Jul 04, 2012
//
// description:	
//
// notes:		none
//
// revisions:	
//
// license:     Permission is hereby granted, free of charge, to any person obtaining a copy
//              of this software and associated documentation files (the "Software"), to deal
//              in the Software without restriction, including without limitation the rights
//              to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//              copies of the Software, and to permit persons to whom the Software is
//              furnished to do so, subject to the following conditions:
//
//              The above copyright notice and this permission notice shall be included in
//              all copies or substantial portions of the Software.
//
//              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//              IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//              FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//              AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//              LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//              OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//              THE SOFTWARE.
//



//---------- pragmas



//---------- include files
#import "BRRequestUpload.h"



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

@interface BRRequestUpload () //note the empty category name
-(void)upload;
@end

@implementation BRRequestUpload

@synthesize listrequest;
@synthesize sentData;

+ (BRRequestUpload *) initWithDelegate: (id) inDelegate
{
    BRRequestUpload *uploadFile = [[BRRequestUpload alloc] init];
    if (uploadFile)
        uploadFile.delegate = inDelegate;
    
    return uploadFile;
}

-(BRRequestTypes)type 
{
    return kBRUploadRequest;
}

-(void) start
{
    self.maximumSize = [self.sentData length];
    
    if (self.hostname==nil) 
    {
        InfoLog(@"The host name is nil!");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientHostnameIsNil;
        [self.delegate requestFailed:self];
        return;
    }   
    
    //we first list the directory to see if our folder is up already
    
    self.listrequest = [[BRRequestListDirectory alloc] init];    
    self.listrequest.path = [self.path stringByDeletingLastPathComponent];
    self.listrequest.hostname = self.hostname;
    self.listrequest.username = self.username;
    self.listrequest.password = self.password;
    self.listrequest.delegate = self;
    [self.listrequest start];
}

-(void) requestCompleted: (BRRequest *) request
{
    
    BOOL fileAlreadyExists = NO;
    NSString * fileName = [[self.path lastPathComponent] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    
    for (NSDictionary * file in self.listrequest.filesInfo) 
    {
        NSString * name = [file objectForKey:(id)kCFFTPResourceName];
        if ([fileName isEqualToString:name]) 
        {
            fileAlreadyExists = YES;
        }
    }
    
    if (fileAlreadyExists) 
    {
        if (![self.delegate shouldOverwriteFileWithRequest:self]) 
        {
            InfoLog(@"There is already a file/folder with that name and the delegate decided not to overwrite!");
            self.error = [[BRRequestError alloc] init];
            self.error.errorCode = kBRFTPClientFileAlreadyExists;
            [self.delegate requestFailed:self];
            [self destroy];
        }
        
        else
        {
            //unfortunately, for FTP there is no current solution for deleting/overwriting a folder (or I was not able to find one yet)
            //it will fail with permission error
            
            if (self.type!=kBRCreateDirectoryRequest) 
            {
                [self upload];
            }
            else
            {
                InfoLog(@"Unfortunately, at this point, the library doesn't support directory overwriting.");
                self.error = [[BRRequestError alloc] init];
                self.error.errorCode = kBRFTPClientCantOverwriteDirectory;
                [self.delegate requestFailed:self];
                [self destroy];
            }
        }
    }
    
    else
    {
        [self upload];
    }    
}


-(void) requestFailed:(BRRequest *) request
{
    [self.delegate requestFailed:request];
}

-(BOOL) shouldOverwriteFileWithRequest:(BRRequest *) request
{
    return [self.delegate shouldOverwriteFileWithRequest: request];
}

-(void)upload 
{
    // a little bit of C because I was not able to make NSInputStream play nice
    CFWriteStreamRef writeStreamRef = CFWriteStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) self.fullURL);
    
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPUsePassiveMode, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanFalse);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPUserName, (__bridge CFStringRef) self.username);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPPassword, (__bridge CFStringRef) self.password);

    self.streamInfo.writeStream = ( __bridge_transfer NSOutputStream *)writeStreamRef;
     
    if (self.streamInfo.writeStream == nil) 
    {
        InfoLog(@"Can't open the write stream! Possibly wrong URL!");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientCantOpenStream;
        [self.delegate requestFailed:self];
        return;
    }
    
    
    if (self.sentData==nil) 
    {
        InfoLog(@"Trying to send nil data? No way. Abort");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientSentDataIsNil;
        [self.delegate requestFailed:self];
        [self destroy];
    }
    else
    {
        self.streamInfo.writeStream.delegate = self;
        [self.streamInfo.writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.streamInfo.writeStream open];
    }
    
    
    self.didManagedToOpenStream = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kBRDefaultTimeout * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        if (!self.didManagedToOpenStream&&self.error==nil) 
        {
            InfoLog(@"No response from the server. Timeout.");
            self.error = [[BRRequestError alloc] init];
            self.error.errorCode = kBRFTPClientStreamTimedOut;
            [self.delegate requestFailed:self];
            [self destroy];
        }
    });
}


//stream delegate
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent 
{
    
    switch (streamEvent) 
    {
        case NSStreamEventOpenCompleted: 
        {
            self.didManagedToOpenStream = YES;
            self.streamInfo.bytesConsumedInTotal = 0;            
        } 
        break;
            
        case NSStreamEventHasBytesAvailable: 
        {
        } 
        break;
            
        case NSStreamEventHasSpaceAvailable: 
        {
            uint8_t * nextPackage;
            NSUInteger nextPackageLength = MIN(kBRDefaultBufferSize, self.sentData.length-self.streamInfo.bytesConsumedInTotal);
            
            nextPackage = malloc(nextPackageLength);
            
            [self.sentData getBytes:nextPackage range:NSMakeRange(self.streamInfo.bytesConsumedInTotal, nextPackageLength)];            
            self.streamInfo.bytesConsumedThisIteration = [self.streamInfo.writeStream write:nextPackage maxLength:nextPackageLength];
            
            free(nextPackage);
            
            if (self.streamInfo.bytesConsumedThisIteration!=-1) 
            {
                if (self.streamInfo.bytesConsumedInTotal + self.streamInfo.bytesConsumedThisIteration<self.sentData.length) 
                {
                    self.streamInfo.bytesConsumedInTotal += self.streamInfo.bytesConsumedThisIteration;
                    
                    self.percentCompleted = self.streamInfo.bytesConsumedInTotal / self.maximumSize;
                    if ([self.delegate respondsToSelector:@selector(percentCompleted:)]) 
                    {
                        [self.delegate percentCompleted: self];
                    }
                }
                else
                {
                    self.percentCompleted = 1.0;
                    if ([self.delegate respondsToSelector:@selector(percentCompleted:)]) 
                    {
                        [self.delegate percentCompleted: self];
                    }
                    
                    [self.delegate requestCompleted:self]; 
                    self.sentData =nil;
                    [self destroy];
                }
            }
            else
            {
                InfoLog(@"");
                self.error = [[BRRequestError alloc] init];
                self.error.errorCode = kBRFTPClientCantWriteStream;
                [self.delegate requestFailed:self];
                [self destroy];
            }
            
        } 
        break;
            
        case NSStreamEventErrorOccurred: 
        {
            self.error = [[BRRequestError alloc] init];
            self.error.errorCode = [self.error errorCodeWithError:[theStream streamError]];
            InfoLog(@"%@", self.error.message);
            [self.delegate requestFailed:self];
            [self destroy];
        } 
        break;
            
        case NSStreamEventEndEncountered: 
        {
            InfoLog(@"The stream was closed by server while we were uploading the data. Upload failed!");
            self.error = [[BRRequestError alloc] init];
            self.error.errorCode = kBRFTPServerAbortedTransfer;
            [self.delegate requestFailed:self];
            [self destroy];
        } 
        break;
    }
}


-(void) destroy
{    
    if (self.streamInfo.writeStream) 
    {
        [self.streamInfo.writeStream close];
        [self.streamInfo.writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.streamInfo.writeStream = nil;
    }
    
    self.streamInfo = nil;
    
    [super destroy];
}


@end
