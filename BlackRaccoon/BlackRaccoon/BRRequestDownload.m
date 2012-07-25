//----------
//
//				BRRequestDownload.m
//
// filename:	BRRequestDownload.m
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
#import "BRRequestDownload.h"



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

@implementation BRRequestDownload

@synthesize receivedData;

+ (BRRequestDownload *) initWithDelegate: (id) inDelegate
{
    BRRequestDownload *downloadFile = [[BRRequestDownload alloc] init];
    if (downloadFile)
        downloadFile.delegate = inDelegate;
    
    return downloadFile;
}

-(BRRequestTypes)type 
{
    return kBRDownloadRequest;
}



-(void) start
{
    
    if (self.hostname==nil) 
    {
        InfoLog(@"The host name is nil!");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientHostnameIsNil;
        [self.delegate requestFailed:self];
        return;
    }
    
    // a little bit of C because I was not able to make NSInputStream play nice
    CFReadStreamRef readStreamRef = CFReadStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef)self.fullURL);
    self.streamInfo.readStream = ( __bridge_transfer NSInputStream *) readStreamRef;
    
    //----- set the username and the password
    [self.streamInfo.readStream setProperty: self.username forKey:(id)kCFStreamPropertyFTPUserName]; 
    [self.streamInfo.readStream setProperty: self.password forKey:(id)kCFStreamPropertyFTPPassword];     
    
    if (self.streamInfo.readStream==nil) 
    {
        InfoLog(@"Can't open the read stream! Possibly wrong URL");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientCantOpenStream;
        [self.delegate requestFailed:self];
        return;
    }
    
    
    self.streamInfo.readStream.delegate = self;
	[self.streamInfo.readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.streamInfo.readStream open];
    
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
            self.receivedData = [NSMutableData data];
        } 
        break;
            
        case NSStreamEventHasBytesAvailable: 
        {
            
            self.streamInfo.bytesConsumedThisIteration = [self.streamInfo.readStream read:self.streamInfo.buffer maxLength:kBRDefaultBufferSize];
            
            if (self.streamInfo.bytesConsumedThisIteration!=-1) 
            {
                if (self.streamInfo.bytesConsumedThisIteration!=0) 
                {
                    
                    NSMutableData * recivedDataWithNewBytes = [self.receivedData mutableCopy];                    
                    [recivedDataWithNewBytes appendBytes:self.streamInfo.buffer length:self.streamInfo.bytesConsumedThisIteration];
                    
                    self.receivedData = [NSData dataWithData:recivedDataWithNewBytes];
                    
                    recivedDataWithNewBytes = nil;                  
                }
            }
            else
            {
                InfoLog(@"Stream opened, but failed while trying to read from it.");
                self.error = [[BRRequestError alloc] init];
                self.error.errorCode = kBRFTPClientCantReadStream;
                [self.delegate requestFailed:self];
                [self destroy];
            }
            
        } 
        break;
            
        case NSStreamEventHasSpaceAvailable: 
        {
            
        } 
        break;
            
        case NSStreamEventErrorOccurred: 
        {
            self.error = [[BRRequestError alloc] init];
            self.error.errorCode = [self.error errorCodeWithError:[theStream streamError]];
            InfoLog(@"%@", self.error.message);
            [self.delegate requestFailed:self];
            self.streamInfo = nil;
            [self destroy];
        } 
        break;
            
        case NSStreamEventEndEncountered: 
        {
            [self.delegate requestCompleted:self];
            self.streamInfo = nil;
            [self destroy];
        } 
        break;
    }
}

-(void) destroy{
    
    if (self.streamInfo.readStream) 
    {
        [self.streamInfo.readStream close];
        [self.streamInfo.readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.streamInfo.readStream = nil;
    }
    
    [super destroy];
}


@end
