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




//-----
//
//				initialize
//
// synopsis:	[BRBase initialize];
//
// description:	initialize is designed to
//
// errors:		none
//
// returns:		none
//

+ (void)initialize
{    
    static BOOL isCacheInitalized = NO;
    if(!isCacheInitalized)
    {
        isCacheInitalized = YES;
        folders = [[NSMutableDictionary alloc] init];
    }
}



//-----
//
//				cachedFolders
//
// synopsis:	retval = [BRBase cachedFolders];
//					NSDictionary *retval	-
//
// description:	cachedFolders is designed to
//
// errors:		none
//
// returns:		Variable of type NSDictionary *
//

+(NSDictionary *) cachedFolders
{
    return folders;
}



//-----
//
//				addFoldersToCache
//
// synopsis:	[BRBase addFoldersToCache:foldersArray forParentFolderPath:key];
//					NSArray *foldersArray	-
//					NSString *key        	-
//
// description:	addFoldersToCache is designed to
//
// errors:		none
//
// returns:		none
//

+(void) addFoldersToCache:(NSArray *) foldersArray forParentFolderPath:(NSString *) key
{
    [folders setObject:foldersArray forKey:key];
}



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



//-----
//
//				fullURL
//
// synopsis:	retval = [self fullURL];
//					NSURL*retval	-
//
// description:	fullURL is designed to
//
// errors:		none
//
// returns:		Variable of type NSURL*
//

-(NSURL*) fullURL
{
    NSString * fullURLString = [self.scheme stringByAppendingFormat:@"%@%@%@", @"://", self.hostname, self.path];
    
    NSLog(@"fullURLString = %@", fullURLString);
    
    return [NSURL URLWithString: fullURLString];
}



//-----
//
//				fullURLWithEscape
//
// synopsis:	retval = [self fullURLWithEscape];
//					NSURL *retval	-
//
// description:	fullURLWithEscape is designed to
//
// errors:		none
//
// returns:		Variable of type NSURL *
//

- (NSURL *) fullURLWithEscape
{
    
    NSString * fullURLString = [self.scheme stringByAppendingFormat:@"%@%@%@%@", @"://", self.credentials, self.hostname, self.path];
    
    NSLog(@"fullURLString = %@", fullURLString);
    
    return [NSURL URLWithString: fullURLString];
    
}




//-----
//
//				path
//
// synopsis:	retval = [self path];
//					NSString *retval	-
//
// description:	path is designed to
//
// errors:		none
//
// returns:		Variable of type NSString *
//

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



//-----
//
//				setPath
//
// synopsis:	[self setPath:directoryPathLocal];
//					NSString *directoryPathLocal	-
//
// description:	setPath is designed to
//
// errors:		none
//
// returns:		none
//

-(void) setPath: (NSString *) directoryPathLocal
{
    path = directoryPathLocal;
}



//-----
//
//				scheme
//
// synopsis:	retval = [self scheme];
//					NSString *retval	-
//
// description:	scheme is designed to
//
// errors:		none
//
// returns:		Variable of type NSString *
//

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



//-----
//
//				hostname
//
// synopsis:	retval = [self hostname];
//					NSString *retval	-
//
// description:	hostname is designed to
//
// errors:		none
//
// returns:		Variable of type NSString *
//

-(NSString *) hostname
{
    return [hostname stringByStandardizingPath];
}



//-----
//
//				setHostname
//
// synopsis:	[self setHostname:hostnamelocal];
//					NSString *hostnamelocal	-
//
// description:	setHostname is designed to
//
// errors:		none
//
// returns:		none
//

-(void)setHostname:(NSString *)hostnamelocal
{
    hostname = hostnamelocal;
}



//-----
//
//				credentials
//
// synopsis:	retval = [self credentials];
//					NSString *retval	-
//
// description:	credentials is designed to
//
// errors:		none
//
// returns:		Variable of type NSString *
//

-(NSString *) credentials
{    
    NSString *escapedUsername = [self encodeString: username];
    NSString *escapedPassword = [self encodeString: password];
    NSString *cred;
    
    if (escapedUsername != nil) 
    {
        if (escapedPassword != nil) 
        {
            cred = [NSString stringWithFormat:@"%@:%@@", escapedUsername, escapedPassword];
        }else
        {
            cred = [NSString stringWithFormat:@"%@@", escapedUsername];
        }
    }
    else
    {
        cred = @"";
    }
    
    return [cred stringByStandardizingPath];
}



//-----
//
//				encodeString
//
// synopsis:	retval = [self encodeString:string];
//					NSString *retval	-
//					NSString *string	-
//
// description:	encodeString is designed to
//
// errors:		none
//
// returns:		Variable of type NSString *
//

- (NSString *)encodeString: (NSString *) string;
{
    NSString *urlEncoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         NULL, 
                                                         (__bridge CFStringRef) string, 
                                                         NULL, 
                                                         (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", 
                                                         kCFStringEncodingUTF8);    
    return urlEncoded;
}  



//-----
//
//				start
//
// synopsis:	[self start];
//
// description:	start is designed to
//
// errors:		none
//
// returns:		none
//

-(void) start
{
}



//-----
//
//				destroy
//
// synopsis:	[self destroy];
//
// description:	destroy is designed to
//
// errors:		none
//
// returns:		none
//

-(void) destroy
{
}


@end
