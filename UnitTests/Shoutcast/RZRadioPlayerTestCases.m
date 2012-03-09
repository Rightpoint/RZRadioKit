//
//  RZRadioPlayer.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZRadioPlayerTestCases.h"
#import "RZRadioKit.h"
#import "RZShoutcast.h"

#define SHOUTCAST_DEV_ID @"sh1wdCBnQQWepq2k"

@implementation RZRadioPlayerTestCases

- (void)testPlayer
{
   RZRadioPlayer *player = [[RZRadioPlayer alloc] init];
   STAssertFalse([player isPlaying], @"Player should not be playing.");
   
   // Test player with no current station.
   [player setStation:nil];
   STAssertFalse([player isPlaying], @"Player should not be playing.");
   [player play];
   STAssertFalse([player isPlaying], @"Player should not be playing.");
   
   
   // Test player with a station.
   RZShoutcast *shoutcast = [[RZShoutcast alloc] init];
   [shoutcast setDeveloperId:SHOUTCAST_DEV_ID];
   NSArray *genres = [shoutcast genres];
   RZShoutcastGenre *genre = [genres lastObject];
   NSArray *stations = [shoutcast stationsWithGenre:genre];
   RZRadioStation *station = [stations lastObject];
   
   [player setStation:station];
   [player play];
   STAssertTrue([player isPlaying], @"Player should be playing.");
   
   [player release];
}

- (void)testFavorites
{
   RZRadioPlayer *player = [[RZRadioPlayer alloc] init];
   [player setShoutcastDeveloperId:SHOUTCAST_DEV_ID];
   
   RZRadioStation *station = nil;
   
   // Find a genre with a station. Note: Do not do this
   // in a production app as it might be slow.
   for (RZRadioGenre *genre in [player genres]) {
      if ([genre hasStations]) {
         station = [[genre stations] lastObject];
      } else {
         for (RZRadioGenre *childGenre in [genre children]) {
            if ([childGenre hasStations]) {
               station = [[childGenre stations] lastObject];
            }
         }
      }
      
      // Exit loop if we have a station.
      if (station) {
         break;
      }
   }
   
   STAssertNotNil(station, @"Did not find a station.");
   [player addFavoriteStation:station];
   STAssertTrue([[player favoriteStations] count] > 0, @"Favorite station not added.");
   [player removeFavoriteStation:station];
   
   [player release];
}

- (void)testGenres
{
   RZRadioPlayer *player = [[RZRadioPlayer alloc] init];
   [player setShoutcastDeveloperId:SHOUTCAST_DEV_ID];

   // Returns top level genres.
   NSArray *genres = [player genres];
   STAssertNotNil(genres, @"Unassigned array of top level genres.");
   STAssertTrue([genres count] > 0, @"No genres returned.");
   
   for (RZRadioGenre *genre in genres) {
      if ([genre hasChildren]) {
         NSArray *childrenGenres = [genre children];
         STAssertNotNil(childrenGenres, @"Unassigned array of children (secondary) genres.");
         STAssertTrue([childrenGenres count] > 0, @"No children genres returned.");
         
      }
   }
   
   [player release];
}



@end
