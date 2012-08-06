//----------
//
//				BRRequestQueue.m
//
// filename:	BRRequestQueue.m
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
#import "BRRequestQueue.h"



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

@implementation BRRequestQueue

@synthesize queueDelegate;

- (id)init 
{
    self = [super init];
    if (self) {
        headRequest = nil;
        tailRequest = nil;
    }
    return self;
}

-(void) addRequest: (BRRequest *) request
{
    request.delegate = self;
    
    if (!request.passive)
        request.passive = self.passive;
    if (!request.password)
        request.password = self.password;
    if (!request.username)
        request.username = self.username;
    if (!request.hostname)
        request.hostname = self.hostname;
    
    if (tailRequest == nil)
    {
        tailRequest = request;
    }
    else
    {
        tailRequest.nextRequest = request;
        request.prevRequest = tailRequest;
        tailRequest = request;
    }
    
    if (headRequest == nil) 
    {
        headRequest = tailRequest;        
    }    
}

-(void) addRequestInFront: (BRRequest *) request 
{
    request.delegate = self;
    if(!request.passive)
        request.passive = self.passive;
    if(!request.password)
        request.password = self.password;
    if(!request.username)
        request.username = self.username;
    if(!request.hostname)
        request.hostname = self.hostname;
    
    if (headRequest != nil) 
    {
        request.nextRequest = headRequest.nextRequest;
        request.nextRequest.prevRequest = request;
        
        headRequest.nextRequest = request;
        request.prevRequest = headRequest.nextRequest;
    }
    else
    {
        InfoLog(@"Adding in front of the queue request at least one element already in the queue. Use 'addRequest' otherwise.");
        return;
    }
    
    if (tailRequest == nil) 
    {
        tailRequest = request;        
    }
}


-(void) addRequestsFromArray: (NSArray *) array
{
    //TBD
}

-(void) removeRequestFromQueue: (BRRequest *) request 
{
    
    if ([headRequest isEqual:request]) 
    {
        headRequest = request.nextRequest;
    }
    
    if ([tailRequest isEqual:request]) 
    {
        tailRequest = request.prevRequest;
    }
    
    request.prevRequest.nextRequest = request.nextRequest;
    request.nextRequest.prevRequest = request.prevRequest;
    
    request.nextRequest = nil;
    request.prevRequest = nil;
}

-(void) start
{
    [headRequest start];
}



// delegate methods

-(void) requestCompleted: (BRRequest *) request 
{
    
    [self.queueDelegate requestCompleted:request];
    
    headRequest = headRequest.nextRequest;
    
    if (headRequest==nil)
    {
        [self.queueDelegate queueCompleted:self];
    }
    else
    {
        [headRequest start]; 
    }
    
    
}

-(void) requestFailed: (BRRequest *) request
{    
    [self.queueDelegate requestFailed:request];
    
    headRequest = headRequest.nextRequest;    
    
    [headRequest start];
}

-(BOOL) shouldOverwriteFileWithRequest: (BRRequest *)request 
{
    if (![self.queueDelegate respondsToSelector:@selector(shouldOverwriteFileWithRequest:)]) 
    {
        return NO;
    }
    else
    {
        return [self.queueDelegate shouldOverwriteFileWithRequest:request];
    }
}


@end
