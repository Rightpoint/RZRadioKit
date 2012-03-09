//
//  RZShoutcastStationPlaylistParser.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/29/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZShoutcastParserDelegate.h"


@interface RZShoutcastStationPlaylistParser : NSObject 
{
@private
   id<RZShoutcastParserDelegate> delegate_;
}

@property (nonatomic, assign) id<RZShoutcastParserDelegate> delegate;

- (NSArray *)parseData:(NSData *)data;

@end
