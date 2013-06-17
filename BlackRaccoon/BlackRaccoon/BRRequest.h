//----------
//
//				BRRequest.h
//
// filename:	BRRequest.h
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
#import "BRGlobal.h"
#import "BRRequestError.h"
#import "BRStreamInfo.h"


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
@class BRRequest;
@class BRRequestDownload;
@class BRRequestUpload;
@protocol BRRequestDelegate  <NSObject>

@required
- (void)requestCompleted:(BRRequest *)request;
- (void)requestFailed:(BRRequest *)request;
- (BOOL)shouldOverwriteFileWithRequest:(BRRequest *)request;

@optional
- (void)percentCompleted:(BRRequest *) request;
- (void)requestDataAvailable:(BRRequestDownload *)request;
- (long)requestDataSendSize:(BRRequestUpload *)request;
- (NSData *)requestDataToSend:(BRRequestUpload *)request;
@end

//---------- classes

@interface BRRequest : NSObject <NSStreamDelegate>
{
@protected
    NSString * path;
    NSString * hostname;
    
    BRRequestError *error;
}
@property NSString *username;
@property NSString *password;
@property NSString *hostname;
@property (readonly) NSURL *fullURL;
@property NSString *path;
@property (strong) BRRequestError *error;
@property float maximumSize;
@property float percentCompleted;
@property long timeout;

@property BRRequest *nextRequest;
@property BRRequest *prevRequest;
@property (weak) id <BRRequestDelegate> delegate;
@property  BRStreamInfo *streamInfo;
@property BOOL didOpenStream;                                                   // whether the stream opened or not
@property (readonly) long bytesSent;                                            // will have bytes from the last FTP call
@property (readonly) long totalBytesSent;                                       // will have bytes total sent
@property BOOL cancelDoesNotCallDelegate;                                       // cancel closes stream without calling delegate

- (NSURL *)fullURLWithEscape;

- (instancetype)initWithDelegate:(id)delegate;

- (void)start;
- (void)cancelRequest;

@end
