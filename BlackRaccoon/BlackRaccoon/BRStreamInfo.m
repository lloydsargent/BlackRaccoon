//----------
//
//				BRStreamInfo.m
//
// filename:	BRStreamInfo.m
//
// author:      Created by Lloyd Sargent for ARC compliance.
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
#import "BRStreamInfo.h"
//#import "memory.h"
#import "BRRequest.h"



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

@implementation BRStreamInfo

@synthesize writeStream;    
@synthesize readStream;
@synthesize bytesThisIteration;
@synthesize bytesTotal;
@synthesize size;
@synthesize bufferObject;



//-----
//
//				init
//
// synopsis:	retval = [self init];
//					id retval	-
//
// description:	init is designed to
//
// errors:		none
//
// returns:		Variable of type id
//

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.bufferObject = [NSMutableData dataWithLength: kBRDefaultBufferSize];
    }
    return self;
}



//-----
//
//				openRead
//
// synopsis:	[self openRead:request];
//					BRRequest *request	-
//
// description:	openRead is designed to
//
// errors:		none
//
// returns:		none
//

- (void) openRead: (BRRequest *) request
{
    if (request.hostname==nil)
    {
        InfoLog(@"The host name is nil!");
        request.error = [[BRRequestError alloc] init];
        request.error.errorCode = kBRFTPClientHostnameIsNil;
        [request.delegate requestFailed: request];
        [request.streamInfo close: request];
        return;
    }
    
    // a little bit of C because I was not able to make NSInputStream play nice
    CFReadStreamRef readStreamRef = CFReadStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) request.fullURL);
    
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPUsePassiveMode, kCFBooleanTrue);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanFalse);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPUserName, (__bridge CFStringRef) request.username);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPPassword, (__bridge CFStringRef) request.password);
    readStream = ( __bridge_transfer NSInputStream *) readStreamRef;
    
    if (readStream==nil)
    {
        InfoLog(@"Can't open the read stream! Possibly wrong URL");
        request.error = [[BRRequestError alloc] init];
        request.error.errorCode = kBRFTPClientCantOpenStream;
        [request.delegate requestFailed: request];
        [request.streamInfo close: request];
        return;
    }
    
    readStream.delegate = request;
	[readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[readStream open];
    
    request.didManagedToOpenStream = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kBRDefaultTimeout * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        if (!request.didManagedToOpenStream && request.error == nil)
        {
            InfoLog(@"No response from the server. Timeout.");
            request.error = [[BRRequestError alloc] init];
            request.error.errorCode = kBRFTPClientStreamTimedOut;
            [request.delegate requestFailed: request];
            [request.streamInfo close: request];
        }
    });
}



//-----
//
//				openWrite
//
// synopsis:	[self openWrite:request];
//					BRRequest *request	-
//
// description:	openWrite is designed to
//
// errors:		none
//
// returns:		none
//

- (void) openWrite: (BRRequest *) request
{
    if (request.hostname==nil)
    {
        InfoLog(@"The host name is nil!");
        request.error = [[BRRequestError alloc] init];
        request.error.errorCode = kBRFTPClientHostnameIsNil;
        [request.delegate requestFailed: request];
        [request.streamInfo close: request];
        return;
    }
    
    CFWriteStreamRef writeStreamRef = CFWriteStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) request.fullURL);
    
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPUsePassiveMode, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanFalse);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPUserName, (__bridge CFStringRef) request.username);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPPassword, (__bridge CFStringRef) request.password);
    
    writeStream = ( __bridge_transfer NSOutputStream *) writeStreamRef;
    
    if (writeStream == nil)
    {
        InfoLog(@"Can't open the write stream! Possibly wrong URL!");
        request.error = [[BRRequestError alloc] init];
        request.error.errorCode = kBRFTPClientCantOpenStream;
        [request.delegate requestFailed: request];
        [request.streamInfo close: request];
        return;
    }
    
    writeStream.delegate = request;
    [writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [writeStream open];
    
    request.didManagedToOpenStream = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kBRDefaultTimeout * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        if (!request.didManagedToOpenStream && request.error==nil)
        {
            InfoLog(@"No response from the server. Timeout.");
            request.error = [[BRRequestError alloc] init];
            request.error.errorCode = kBRFTPClientStreamTimedOut;
            [request.delegate requestFailed:request];
            [request.streamInfo close: request];
        }
    });
}



//-----
//
//				read
//
// synopsis:	retval = [self read:request];
//					NSData *retval    	-
//					BRRequest *request	-
//
// description:	read is designed to
//
// errors:		none
//
// returns:		Variable of type NSData *
//

- (NSData *) read: (BRRequest *) request
{
    NSData *data;
    
    bytesThisIteration = [readStream read: self.buffer maxLength:kBRDefaultBufferSize];
    bytesTotal += bytesThisIteration;
    
    //----- return the data
    if (bytesThisIteration > 0)
    {
        data = [NSData dataWithBytes: self.buffer length: bytesThisIteration];
        
        request.percentCompleted = bytesTotal / request.maximumSize;
        
        if ([request.delegate respondsToSelector:@selector(percentCompleted:)])
        {
            [request.delegate percentCompleted: request];
        }
        
        return data;
    }
    
    //----- return no data, but this isn't an error... just the end of the file
    else if (bytesThisIteration == 0)
        return [NSData data];                                                   // returns empty data object - means no error, but no data 
    
    //----- otherwise we had an error, return an error
    [self streamError: request errorCode: kBRFTPClientCantReadStream];
    InfoLog(@"%@", request.error.message);
    
    return nil;
}

- (BOOL) write: (BRRequest *) request data: (NSData *) data
{
    bytesThisIteration = [writeStream write: [data bytes] maxLength: [data length]];
    bytesTotal += bytesThisIteration;
            
    if (bytesThisIteration > 0)
    {
        request.percentCompleted = bytesTotal / request.maximumSize;
        if ([request.delegate respondsToSelector:@selector(percentCompleted:)])
        {
            [request.delegate percentCompleted: request];
        }
        
        return TRUE;
    }
    
    if (bytesThisIteration == 0)
        return TRUE;
    
    [self streamError: request errorCode: kBRFTPClientCantWriteStream]; // perform callbacks and close out streams
    InfoLog(@"%@", request.error.message);

    return FALSE;
}


- (void) streamError: (BRRequest *) request errorCode: (enum BRErrorCodes) errorCode
{
    request.error = [[BRRequestError alloc] init];
    request.error.errorCode = errorCode;
    [request.delegate requestFailed: request];
    [request.streamInfo close: request];
}

- (void) streamComplete: (BRRequest *) request
{
    [request.delegate requestCompleted: request];
    [request.streamInfo close: request];
}



//-----
//
//				close
//
// synopsis:	[self close:request];
//					BRRequest *request	-
//
// description:	close is designed to
//
// errors:		none
//
// returns:		none
//

- (void) close: (BRRequest *) request
{
    if (readStream)
    {
        [readStream close];
        [readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        readStream = nil;
    }
    
    if (writeStream)
    {
        [writeStream close];
        [writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        writeStream = nil;
    }
    
    bufferObject = nil;
    request.streamInfo = nil;
}



//-----
//
//				buffer
//
// synopsis:	retval = [self buffer];
//					UInt8 *retval	-
//
// description:	buffer is designed to
//
// errors:		none
//
// returns:		Variable of type UInt8 *
//

- (UInt8 *) buffer
{
    return (UInt8 *) [bufferObject bytes];
}



//-----
//
//				setBuffer
//
// synopsis:	[self setBuffer:buffer];
//					UInt8 *buffer	-
//
// description:	setBuffer is designed to do nothing but make ARC happy.
//
// errors:		none
//
// returns:		none
//

- (void) setBuffer: (UInt8 *) buffer
{
}

@end
