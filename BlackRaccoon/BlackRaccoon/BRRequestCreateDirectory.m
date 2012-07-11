//----------
//
//				BRRequestCreateDirectory.m
//
// filename:	BRRequestCreateDirectory.m
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
#import "BRRequestCreateDirectory.h"



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

@implementation BRRequestCreateDirectory

+ (BRRequestCreateDirectory *) initWithDelegate: (id) inDelegate
{
    BRRequestCreateDirectory *createDir = [[BRRequestCreateDirectory alloc] init];
    if (createDir)
        createDir.delegate = inDelegate;
    
    return createDir;
}

- (BRRequestTypes) type 
{
    return kBRCreateDirectoryRequest;
}

- (NSString *)path 
{
    //  the path will always point to a directory, so we add the final slash to it (if there was one before escaping/standardizing, it's *gone* now)
    NSString * directoryPath = [super path];
    if (![directoryPath isEqualToString:@""]) 
    {
        directoryPath = [directoryPath stringByAppendingString:@"/"];
    }
    return directoryPath;
}

- (void) upload 
{
    CFWriteStreamRef writeStreamRef = CFWriteStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) self.fullURL);
    self.streamInfo.writeStream = ( __bridge_transfer NSOutputStream *) writeStreamRef;
    
    if (self.streamInfo.writeStream == nil) 
    {
        InfoLog(@"Can't open the write stream! Possibly wrong URL!");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientCantOpenStream;
        [self.delegate requestFailed:self];
        return;
    }
    
    self.streamInfo.writeStream.delegate = self;
    [self.streamInfo.writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.streamInfo.writeStream open];
    
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
        } 
        break;
            
        case NSStreamEventHasBytesAvailable: 
        {
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
            [self destroy];
        } 
        break;
            
        case NSStreamEventEndEncountered: 
        {
            [self.delegate requestCompleted:self];
            [self destroy];
        } 
        break;
    }
}


@end
