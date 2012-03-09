//
//  RZShoutcastGenre.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZRadioGenre.h"


@interface RZShoutcastGenre : RZRadioGenre
{
@private
   BOOL hasChildren_;
   NSMutableArray *children_;
   NSMutableArray *stations_;
      
      
   NSString *parentId_;
   NSString *shoutcastDeveloperId_;
}

@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *shoutcastDeveloperId;

- (void)setHasChildren:(BOOL)hasChildren;

/**
 Downloads children genres if and only if this genre has children.
 This method is called by RZShoutcastGenreParser and only under 
 Mac OS X.
 */
- (void)prefetchChildren;

@end
