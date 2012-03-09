//
//  RZShoutcast.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastTestCases.h"
#import "RZRadioKit.h"
#import "RZShoutcast.h"
#import "RZShoutcastGenre.h"

#define kShoutcastDeveloperId @"sh1wdCBnQQWepq2k"

@interface RZShoutcastTestCases ()
@property (nonatomic, retain) RZShoutcast *shoutcast;
@end

@implementation RZShoutcastTestCases

@synthesize shoutcast = shoutcast_;

- (void)setUp
{
   RZShoutcast *s = [[RZShoutcast alloc] init];
   [s setDeveloperId:kShoutcastDeveloperId];
   [self setShoutcast:s];
   [s release];
}

- (void)tearDown
{
   [self setShoutcast:nil];
}

- (void)testGenres
{
   NSArray *genres = [[self shoutcast] genres];
   STAssertNotNil(genres, @"Unassigned genre array returned.");
   STAssertTrue([genres count] > 0, @"No genres found.");
}

- (void)testGenresForGenre
{
   NSArray *genres = [[self shoutcast] genres];
   
   BOOL foundGenreWithChildren = NO;
   RZShoutcastGenre *parentGenre = nil;
   for (parentGenre in genres) {
      if ([parentGenre hasChildren]) {
         foundGenreWithChildren = YES;
         break;
      }
   }
   
   if (!foundGenreWithChildren) {
      STFail(@"Cannot find a genre with children. Cannot complete test.");
   }
   
   NSArray *secondaryGenres = [[self shoutcast] genresForGenre:parentGenre];
   STAssertNotNil(secondaryGenres, @"Unassigned secondary genre array returned.");
   STAssertTrue([secondaryGenres count] > 0, @"No secondary genres found.");
   
   for (RZShoutcastGenre *genre in secondaryGenres) {
      STAssertTrue([[genre parentId] isEqualToString:[parentGenre genreId]], @"Genre is not a child genre.");
   }
}

- (void)testStationsWithGenre
{
   NSArray *genres = [[self shoutcast] genres];
   RZShoutcastGenre *genre = [genres lastObject];

   NSArray *stations = [[self shoutcast] stationsWithGenre:genre];
   STAssertNotNil(stations, @"Unassigned stations array returned.");
   STAssertTrue([stations count] > 0, @"No stations found.");
}

- (void)testStationPlayList
{
   // Grab a random station.
   NSArray *genres = [[self shoutcast] genres];
   RZShoutcastGenre *genre = [genres lastObject];
   
   NSArray *stations = [[self shoutcast] stationsWithGenre:genre];
   RZRadioStation *station = [stations lastObject];
   
   STAssertNotNil([station playlist], @"Unassigned playlist array.");
}


@end
