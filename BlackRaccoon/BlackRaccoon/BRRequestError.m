//----------
//
//				BRRequestError.m
//
// filename:	BRRequestError.m
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
#import "BRRequestError.h"



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

@implementation BRRequestError

@synthesize errorCode;

- (id)init 
{
    self = [super init];
    if (self) {
        self.errorCode = 0;
    }
    return self;
}

-(NSString *) message 
{
    NSString * mess;
    switch (self.errorCode) 
    {
            //Client errors
        case kBRFTPClientCantOpenStream:
            mess = @"Can't open stream, probably the URL is wrong.";
            break;
            
        case kBRFTPClientStreamTimedOut:
            mess = @"No response from the server. Timeout.";
            break;
            
        case kBRFTPClientCantReadStream:
            mess = @"Stream opened, but failed while trying to read from it.";
            break;
            
        case kBRFTPClientCantWriteStream:
            mess = @"The write stream had opened, but it failed when we tried to write data on it!";
            break;
            
        case kBRFTPClientHostnameIsNil:
            mess = @"Hostname can't be nil.";
            break;
            
        case kBRFTPClientSentDataIsNil:
            mess = @"You need some data to send. Why is 'sentData' nil?";
            break;
            
        case kBRFTPClientCantOverwriteDirectory:
            mess = @"Can't overwrite directory!";
            break;
            
        case kBRFTPClientFileAlreadyExists:
            mess = @"File already exists!";
            break;
            
            //Server errors    
        case kBRFTPServerAbortedTransfer:
            mess = @"Server connection interrupted.";
            break;
            
        case kBRFTPServerCantOpenDataConnection:
            mess = @"Server can't open data connection.";
            break;
            
        case kBRFTPServerFileNotAvailable:
            mess = @"No such file or directory on server.";
            break;
            
        case kBRFTPServerIllegalFileName:
            mess = @"File name has illegal characters.";
            break;
            
        case kBRFTPServerResourceBusy:
            mess = @"Resource busy! Try later!";
            break;
            
        case kBRFTPServerStorageAllocationExceeded:
            mess = @"Server storage exceeded!";
            break;
            
        case kBRFTPServerUnknownError:
            mess = @"Unknown FTP error!";
            break;
            
        case kBRFTPServerUserNotLoggedIn:
            mess = @"Not logged in.";
            break;
            
        default:
            mess = @"Unknown error!";
            break;
    }
    
    return mess;
}


-(BRErrorCodes) errorCodeWithError: (NSError *) error 
{
    //----- As suggested by RMaddy
    NSDictionary *userInfo = error.userInfo;
    NSNumber *code = [userInfo objectForKey:(id)kCFFTPStatusCodeKey];
    
    if (code)
    {
        return [code intValue];
    }
    
    else
    {
        return 0;
    }
}



@end
