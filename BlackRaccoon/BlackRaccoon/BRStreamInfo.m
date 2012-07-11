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
#import "memory.h"



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
@synthesize bytesConsumedThisIteration;    
@synthesize bytesConsumedInTotal;
@synthesize size;
@synthesize bufferObject;

//@synthesize buffer;


- (id)init
{
    self = [super init];
    if (self) 
    {
        self.bufferObject = [NSMutableData dataWithLength: kBRDefaultBufferSize];
    }
    return self;
}


- (void) destroy
{
    self.writeStream = nil;    
    self.readStream = nil;
//    free(self.buffer);
    bufferObject = nil;
}


- (UInt8 *) buffer
{
    return (UInt8 *) [bufferObject bytes];
}

- (void) setBuffer: (UInt8 *)buffer
{
}

@end
