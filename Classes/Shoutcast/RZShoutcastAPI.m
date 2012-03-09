//
//  RZShoutcastAPI.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/21/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastAPI.h"


NSString * const kRZShoutcastResponseFormatXml = @"xml";
NSString * const kRZShoutcastResponseFormatJson = @"json";
NSString * const kRZShoutcastResponseFormatRss = @"rss";

NSString * const kRZShoutcastBaseURL = @"http://api.shoutcast.com/%@";
NSString * const kRZShoutcastStationsWithKeyword = @"legacy/stationsearch?k=%@&search=%@";
NSString * const kRZShoutcastStationsWithGenre = @"legacy/genresearch?k=%@&genre=%@";
NSString * const kRZShoutcastGenres = @"legacy/genrelist?k=%@";
NSString * const kRZShoutcastPrimaryGenres = @"genre/primary?k=%@&f=%@";
NSString * const kRZShoutcastSecondaryGenres = @"genre/secondary?parentid=%@&k=%@&f=%@";
NSString * const kRZShoutcastGenreDetails = @"genre/secondary?id=%@&k=%@&f=%@";

NSString * const kRZShoutcastTuneInURL = @"http://yp.shoutcast.com/sbin/tunein-station.pls?id=%@&k=%@";

@implementation RZShoutcastAPI

@synthesize developerId = developerId_;
@synthesize responseFormat = responseFormat_;

- (void)dealloc
{
   [developerId_ release], developerId_ = nil;
   [responseFormat_ release], responseFormat_ = nil;
   
   [super dealloc];
}

- (id)init
{
   self = [super init];
   if (self) {
      [self setResponseFormat:kRZShoutcastResponseFormatXml];
   }
   return self;
}

- (id)initWithDeveloperId:(NSString *)developerId;
{
   self = [super init];
   if (self) {
      [self setResponseFormat:kRZShoutcastResponseFormatXml];
      [self setDeveloperId:developerId];
   }
   return self;
}

- (NSString *)encodedString:(NSString *)string
{
   return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)callShoutcastWithURL:(NSURL *)url error:(NSError **)error
{
   NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
   
   NSURLResponse *response = nil;
   NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
   
#ifdef DEBUG
   if (*error) {
      DLog(@"NSURLConnection error: %@", [*error localizedDescription]);
   }
#endif
   
   return data;
}

#pragma mark -
#pragma mark Stations

- (NSData *)stationsWithKeyword:(NSString *)keyword error:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");
   
   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedKeyword = [self encodedString:keyword];
   
   NSString *urlString = [NSString stringWithFormat:kRZShoutcastBaseURL, kRZShoutcastStationsWithKeyword];
   urlString = [NSString stringWithFormat:urlString, devId, encodedKeyword];

   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}

- (NSData *)stationsWithGenreName:(NSString *)genreName error:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");
   
   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedGenreName = [self encodedString:genreName];
   
   NSString *urlString = [NSString stringWithFormat:kRZShoutcastBaseURL, kRZShoutcastStationsWithGenre];
   urlString = [NSString stringWithFormat:urlString, devId, encodedGenreName];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}

#pragma mark -
#pragma mark Genres

- (NSData *)genresWithError:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");
   
   NSString *devId = [self encodedString:[self developerId]];

   NSString *urlString = [NSString stringWithFormat:kRZShoutcastBaseURL, kRZShoutcastGenres];
   urlString = [NSString stringWithFormat:urlString, devId];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}

- (NSData *)primaryGenresWithError:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");
   
   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedFormat = [self encodedString:[self responseFormat]];
   
   NSString *urlString = [NSString stringWithFormat:kRZShoutcastBaseURL, kRZShoutcastPrimaryGenres];
   urlString = [NSString stringWithFormat:urlString, devId, encodedFormat];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}

- (NSData *)secondaryGenresForGenreId:(NSString *)genreId error:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");

   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedFormat = [self encodedString:[self responseFormat]];
   NSString *encodedGenreId = [self encodedString:genreId];

   NSString *urlString = [NSString stringWithFormat:kRZShoutcastBaseURL, kRZShoutcastSecondaryGenres];
   urlString = [NSString stringWithFormat:urlString, encodedGenreId, devId, encodedFormat];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}

- (NSData *)genreWithGenreId:(NSString *)genreId error:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");
   
   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedFormat = [self encodedString:[self responseFormat]];
   NSString *encodedGenreId = [self encodedString:genreId];

   NSString *urlString = [NSString stringWithFormat:kRZShoutcastBaseURL, kRZShoutcastGenreDetails];
   urlString = [NSString stringWithFormat:urlString, encodedGenreId, devId, encodedFormat];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}

- (NSURL *)tuneInURLWithStation:(NSString *)stationId
{
   ZAssert([self developerId], @"Unassigned developer id.");

   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedStationId = [self encodedString:stationId];
   
   NSString *urlString = [NSString stringWithFormat:kRZShoutcastTuneInURL, encodedStationId, devId];
   
   NSURL *url = [NSURL URLWithString:urlString];
   return url;
}

- (NSData *)playListForStationId:(NSString *)stationId error:(NSError **)error
{
   ZAssert([self developerId], @"Unassigned developer id.");
   
   NSString *devId = [self encodedString:[self developerId]];
   NSString *encodedStationId = [self encodedString:stationId];
   
   NSString *urlString = [NSString stringWithFormat:kRZShoutcastTuneInURL, encodedStationId, devId];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSData *data = [self callShoutcastWithURL:url error:error];
   return data;
}


@end
