//
//  RZShoutcast.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/21/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcast.h"
#import "RZShoutcastAPI.h"
#import "RZShoutcastGenreParser.h"
#import "RZShoutcastStationParser.h"
#import "RZShoutcastStationPlaylistParser.h"
#import "RZShoutcastGenre.h"


@implementation RZShoutcast

@synthesize developerId = developerId_;

- (void)dealloc
{
   [developerId_ release], developerId_ = nil;
   
   [super dealloc];
}

- (id)initWithDeveloperId:(NSString *)developerId
{
   self = [super init];
   if (self) {
      [self setDeveloperId:developerId];
   }
   return self;
}

- (NSArray *)genresError:(NSError **)error
{
   NSArray *genres = nil;
   
   RZShoutcastAPI *api = [[RZShoutcastAPI alloc] initWithDeveloperId:[self developerId]];
   NSData *data = [api primaryGenresWithError:error];
   [api release];
   
   if (*error) {
      DLog(@"Error retrieving genres: %@", [*error localizedDescription]);
   } else {
      // Parse the response data into a genre array.
      RZShoutcastGenreParser *parser = [[RZShoutcastGenreParser alloc] init];
      [parser setDelegate:self];
      genres = [parser parseData:data parentGenre:nil];
      [parser release];
      
      // Remove the misc genre from the list.
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT name LIKE 'Misc'"];
      genres = [genres filteredArrayUsingPredicate:predicate];
   }
   
   return genres;
}

- (NSArray *)genresForGenre:(RZShoutcastGenre *)genre error:(NSError **)error
{
   NSArray *genres = nil;

   RZShoutcastAPI *api = [[RZShoutcastAPI alloc] initWithDeveloperId:[self developerId]];
   NSData *data = [api secondaryGenresForGenreId:[genre genreId] error:error];
   [api release];
   
   if (*error) {
      DLog(@"Error retrieving secondary genres: %@", [*error localizedDescription]);
   } else {
      // Parse the response data into a genre array.
      RZShoutcastGenreParser *parser = [[RZShoutcastGenreParser alloc] init];
      [parser setDelegate:self];
      genres = [parser parseData:data parentGenre:genre];
      [parser release];
   }
   return genres;
}

- (NSArray *)stationsWithGenre:(RZShoutcastGenre *)genre error:(NSError **)error
{
   NSArray *stations = nil;

   RZShoutcastAPI *api = [[RZShoutcastAPI alloc] initWithDeveloperId:[self developerId]];
   NSData *data = [api stationsWithGenreName:[genre name] error:error];
   [api release];
   
   if (*error) {
      DLog(@"Error retrieving stations: %@", [*error localizedDescription]);
   } else {
      // Parse the response data into a station array.
      RZShoutcastStationParser *parser = [[RZShoutcastStationParser alloc] init];
      [parser setDelegate:self];
      [parser setDefaultGenreName:[[genre parentGenre] name]];
      stations = [parser parseData:data];
      [parser release];
   }

   return stations;
}

- (NSArray *)stationsWithKeyword:(NSString *)keyword error:(NSError **)error
{
   NSArray *stations = nil;
   
   RZShoutcastAPI *api = [[RZShoutcastAPI alloc] initWithDeveloperId:[self developerId]];
   NSData *data = [api stationsWithKeyword:keyword error:error];
   [api release];
   
   if (*error) {
      DLog(@"Error retrieving stations: %@", [*error localizedDescription]);
   } else {
      // Parse the response data into a station array.
      RZShoutcastStationParser *parser = [[RZShoutcastStationParser alloc] init];
      [parser setDelegate:self];
      stations = [parser parseData:data];
      [parser release];
   }
   
   return stations;
}

- (NSArray *)playListForStationId:(NSString *)stationId error:(NSError **)error
{
   NSArray *playList = nil;
   
   RZShoutcastAPI *api = [[RZShoutcastAPI alloc] initWithDeveloperId:[self developerId]];
   NSData *data = [api playListForStationId:stationId error:error];
   [api release];
   
   if (*error) {
      DLog(@"Error retrieving stations: %@", [*error localizedDescription]);
   } else {
      // Parse the response data.
      RZShoutcastStationPlaylistParser *parser = [[RZShoutcastStationPlaylistParser alloc] init];
      [parser setDelegate:self];
      playList = [parser parseData:data];
      [parser release];
   }
   
   return playList;
}


#pragma mark -
#pragma mark RZShoutcastParserDelegate

- (NSString *)shoutcastDeveloperId
{
   return [self developerId];
}

@end
