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


@synthesize listrequest;

+ (BRRequestCreateDirectory *) initWithDelegate: (id) inDelegate
{
    BRRequestCreateDirectory *createDir = [[BRRequestCreateDirectory alloc] init];
    if (createDir)
        createDir.delegate = inDelegate;
    
    return createDir;
}


- (NSString *)path
{
    //  the path will always point to a directory, so we add the final slash to it (if there was one before escaping/standardizing, it's *gone* now)
    NSString * directoryPath = [super path];
    if (![directoryPath hasSuffix: @"/"])
    {
        directoryPath = [directoryPath stringByAppendingString:@"/"];
    }
    return directoryPath;
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
    
    //-----we first list the directory to see if our folder is up already
    self.listrequest = [BRRequestListDirectory initWithDelegate: self];
    self.listrequest.path = [self.path stringByDeletingLastPathComponent];
    self.listrequest.hostname = self.hostname;
    self.listrequest.username = self.username;
    self.listrequest.password = self.password;
    [self.listrequest start];
}

-(void) requestCompleted: (BRRequest *) request
{
    NSString *directoryName = [[self.path lastPathComponent] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];

    if ([self.listrequest fileExists: directoryName])
    {
        InfoLog(@"Unfortunately, at this point, the library doesn't support directory overwriting.");
        [self.streamInfo streamError: self errorCode: kBRFTPClientCantOverwriteDirectory];
    }
    
    else
    {
        //----- open the write stream and check for errors calling delegate methods
        //----- if things fail. This encapsulates the streamInfo object and cleans up our code.
        [self.streamInfo openWrite: self];
    }
}

-(void) requestFailed:(BRRequest *) request
{
    [self.delegate requestFailed:request];
}

- (BOOL) shouldOverwriteFileWithRequest: (BRRequest *)request
{
    return NO;
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
            [self.streamInfo streamError: self errorCode: [BRRequestError errorCodeWithError: [theStream streamError]]]; // perform callbacks and close out streams
            InfoLog(@"%@", self.error.message);
        }
            break;
            
        case NSStreamEventEndEncountered:
        {
            [self.streamInfo streamComplete: self];                             // perform callbacks and close out streams
        }
            break;
    }
}

@end
