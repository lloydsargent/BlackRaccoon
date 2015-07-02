//
//  CALayer+Additions.m
//  QuickGrocery
//
//  Created by Lloyd Sargent on 7/27/14.
//  Copyright (c) 2014 Canna Software. All rights reserved.
//

#import "CALayer+Additions.h"

@implementation CALayer (Additions)

- (void)setBorderColorIB:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end
