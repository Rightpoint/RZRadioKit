//
//  RZShoutcast.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class RZShoutcast;

@interface RZShoutcastTestCases : SenTestCase 
{
@private
   RZShoutcast *shoutcast_;
}

- (void)setUp;
- (void)tearDown;
- (void)testGenres;
- (void)testGenresForGenre;
- (void)testStationsWithGenre;
- (void)testStationPlayList;

@end
