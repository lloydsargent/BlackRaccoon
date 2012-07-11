//----------
//
//				BRRequestListDirectory.m
//
// filename:	BRRequestListDirectory.m
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
#import "BRRequestListDirectory.h"



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

@implementation BRRequestListDirectory

@synthesize filesInfo;

+ (BRRequestListDirectory *) initWithDelegate: (id) inDelegate
{
    BRRequestListDirectory *listDir = [[BRRequestListDirectory alloc] init];
    if (listDir)
        listDir.delegate = inDelegate;
    
    return listDir;
}

- (BRRequestTypes) type 
{
    return kBRListDirectoryRequest;
}

-(NSString *)path 
{
    //  the path will always point to a directory, so we add the final slash to it (if there was one before escaping/standardizing, it's *gone* now)
    NSString * directoryPath = [super path];
    if (![directoryPath isEqualToString:@""]) 
    {
        directoryPath = [directoryPath stringByAppendingString:@"/"];
    }
    return directoryPath;
}

-(void) start 
{
    if (self.hostname == nil) 
    {
        InfoLog(@"The host name is not valid!");
        self.error = [[BRRequestError alloc] init];
        self.error.errorCode = kBRFTPClientHostnameIsNil;
        [self.delegate requestFailed:self];
        return;
    }
    
    //----- a little bit of C because I was not able to make NSInputStream play nice
    CFReadStreamRef readStreamRef = CFReadStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) self.fullURL);
    self.streamInfo.readStream = ( __bridge_transfer NSInputStream *) readStreamRef;
    
    if (self.streamInfo.readStream == nil) 
    {
        InfoLog(@"Can't open the write stream! Possibly wrong URL!");
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
        if (!self.didManagedToOpenStream && self.error ==nil) 
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
- (void) stream: (NSStream *) theStream handleEvent: (NSStreamEvent) streamEvent 
{
NSLog(@"BRRequestListDir event");
    switch (streamEvent) 
    {
        case NSStreamEventOpenCompleted: 
        {
			self.filesInfo = [NSMutableArray array];
            self.didManagedToOpenStream = YES;
        } break;
            
        case NSStreamEventHasBytesAvailable: 
        {
            self.streamInfo.bytesConsumedThisIteration = [self.streamInfo.readStream read:self.streamInfo.buffer maxLength:kBRDefaultBufferSize];
            
            if (self.streamInfo.bytesConsumedThisIteration != -1) 
            {
                if (self.streamInfo.bytesConsumedThisIteration != 0) 
                {
                    NSUInteger  offset = 0;
                    CFIndex     parsedBytes;
                    
                    do 
                    {        
                        CFDictionaryRef listingEntity = NULL;
                        
                        parsedBytes = CFFTPCreateParsedResourceListing(NULL, &self.streamInfo.buffer[offset], self.streamInfo.bytesConsumedThisIteration - offset, &listingEntity);
                        
                        if (parsedBytes > 0) 
                        {
                            if (listingEntity != NULL) 
                            {
                                //----- July 10, 2012: CFFTPCreateParsedResourceListing had a bug that had the date over retained
                                //----- in order to fix this, we release it once. However, just as a precaution, we check to see what
                                //----- the retain count might be (this isn't guaranteed to work).
                                id date = [(__bridge NSDictionary *) listingEntity objectForKey: (id) kCFFTPResourceModDate];
                                if (CFGetRetainCount((__bridge CFTypeRef) date) >= 2)
                                    CFRelease((__bridge CFTypeRef) date);

                                //----- transfer the directory into an ARC maintained array
                                self.filesInfo = [self.filesInfo arrayByAddingObject: (__bridge_transfer NSDictionary *) listingEntity];                            
                            }            
                            offset += parsedBytes;            
                        }
                        
                    } while (parsedBytes>0); 
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
            [self destroy];
        } 
        break;
            
        case NSStreamEventEndEncountered: 
        {            
            [BRBase addFoldersToCache:self.filesInfo forParentFolderPath:self.path];
            [self.delegate requestCompleted:self]; 
            [self destroy];
        } 
        break;
    }
}


@end
