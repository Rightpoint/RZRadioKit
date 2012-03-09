//
//  RZShoutcast.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/21/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZShoutcastParserDelegate.h"

@class RZShoutcastGenre;

@interface RZShoutcast : NSObject <RZShoutcastParserDelegate>
{
@private
   NSString *developerId_;
}

@property (nonatomic, copy) NSString *developerId;

- (id)initWithDeveloperId:(NSString *)developerId;
- (NSArray *)genresError:(NSError **)error;
- (NSArray *)genresForGenre:(RZShoutcastGenre *)genre error:(NSError **)error;
- (NSArray *)stationsWithGenre:(RZShoutcastGenre *)genre error:(NSError **)error;
- (NSArray *)stationsWithKeyword:(NSString *)keyword error:(NSError **)error;
- (NSArray *)playListForStationId:(NSString *)stationId error:(NSError **)error;

@end
