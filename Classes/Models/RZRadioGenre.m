//
//  RZRadioGenre.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/26/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZRadioGenre.h"

@implementation RZRadioGenre

@synthesize name = name_;
@synthesize genreId = genreId_;
@synthesize parentGenre = parentGenre_;
@synthesize error = error_;

- (void)dealloc
{
   [error_ release], error_ = nil;
   [name_ release], name_ = nil;
   [genreId_ release], genreId_ = nil;
   
   [super dealloc];
}

- (BOOL)hasChildren
{
   return NO;
}

- (NSMutableArray *)children
{
   return [NSMutableArray array];
}

- (BOOL) hasStations
{
   return NO;
}

- (NSMutableArray *)stations
{
   return [NSMutableArray array];
}

@end