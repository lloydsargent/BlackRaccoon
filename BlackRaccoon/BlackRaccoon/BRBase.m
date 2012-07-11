//----------
//
//				BRBase.m
//
// filename:	BRBase.m
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
#import "BRBase.h"



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

@implementation BRBase

@synthesize passive;
@synthesize password;
@synthesize username;
@synthesize schemeId;
@synthesize error;



static NSMutableDictionary *folders;

+ (void)initialize
{    
    static BOOL isCacheInitalized = NO;
    if(!isCacheInitalized)
    {
        isCacheInitalized = YES;
        folders = [[NSMutableDictionary alloc] init];
    }
}


+(NSDictionary *) cachedFolders 
{
    return folders;
}

+(void) addFoldersToCache:(NSArray *) foldersArray forParentFolderPath:(NSString *) key 
{
    [folders setObject:foldersArray forKey:key];
}


- (id)init 
{
    self = [super init];
    if (self) {
        self.schemeId = kBRFTP;
        self.passive = NO;
        self.password = nil;
        self.username = nil;
        self.hostname = nil;
        self.path = @"";
    }
    return self;
}

-(NSURL*) fullURL 
{
    // first we merge all the url parts into one big and beautiful url
    NSString * fullURLString = [self.scheme stringByAppendingFormat:@"%@%@%@%@", @"://", self.credentials, self.hostname, self.path];
    
    NSLog(@"credentials: %@ hostname: %@ path: %@", self.credentials, self.hostname, self.path);
    
    return [NSURL URLWithString:[fullURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

-(NSString *)path 
{
    //  we remove all the extra slashes from the directory path, including the last one (if there is one)
    //  we also escape it
    NSString * escapedPath = [path stringByStandardizingPath];   
    
    
    //  we need the path to be absolute, if it's not, we *make* it
    if (![escapedPath isAbsolutePath]) 
    {
        escapedPath = [@"/" stringByAppendingString:escapedPath];
    }
    
    return escapedPath;
}


-(void) setPath: (NSString *) directoryPathLocal 
{
    path = directoryPathLocal;
}



-(NSString *)scheme 
{
    switch (self.schemeId) 
    {
        case kBRFTP:
            return @"ftp";
            break;
            
        default:
            InfoLog(@"The scheme id was not recognized! Default FTP set!");
            return @"ftp";
            break;
    }
    
    return @"";
}

-(NSString *) hostname 
{
    return [hostname stringByStandardizingPath];
}

-(void)setHostname:(NSString *)hostnamelocal 
{
    hostname = hostnamelocal;
}

-(NSString *) credentials 
{    
    
    NSString * cred;
    
    if (self.username!=nil) 
    {
        if (self.password!=nil) 
        {
            cred = [NSString stringWithFormat:@"%@:%@@", self.username, self.password];
        }else
        {
            cred = [NSString stringWithFormat:@"%@@", self.username];
        }
    }
    else
    {
        cred = @"";
    }
    
    return [cred stringByStandardizingPath];
}

-(void) start
{
}

-(void) destroy
{
    
}


@end
