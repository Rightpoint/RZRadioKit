//
//  RZShoutcastGenreParser.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZShoutcastParserDelegate.h"

@class RZRadioGenre;
@class RZShoutcastGenre;

@interface RZShoutcastGenreParser : NSObject <NSXMLParserDelegate>
{
@private
   id<RZShoutcastParserDelegate> delegate_;
   RZShoutcastGenre *currentGenre_;
   NSMutableArray *genres_;
   RZRadioGenre *parentGenre_; 
}

@property (nonatomic, assign) id<RZShoutcastParserDelegate> delegate;

- (NSArray *)parseData:(NSData *)data parentGenre:(RZRadioGenre *)genre;

@end
