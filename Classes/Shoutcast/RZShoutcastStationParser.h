//
//  RZShoutcastStationParser.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZShoutcastParserDelegate.h"

@class RZShoutcastStation;

@interface RZShoutcastStationParser : NSObject <NSXMLParserDelegate>
{
@private
   id<RZShoutcastParserDelegate> delegate_;
   RZShoutcastStation *currentStation_;
   NSMutableArray *stations_;
   NSString *defaultGenreName_;
}

@property (nonatomic, assign) id<RZShoutcastParserDelegate> delegate;
@property (nonatomic, copy) NSString *defaultGenreName;

- (NSArray *)parseData:(NSData *)data;

@end
