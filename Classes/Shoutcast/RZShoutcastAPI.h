//
//  RZShoutcastAPI.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/21/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kRZShoutcastResponseFormatXml;
extern NSString * const kRZShoutcastResponseFormatJson;
extern NSString * const kRZShoutcastResponseFormatRss;

@interface RZShoutcastAPI : NSObject 
{
@private
   NSString *developerId_;
   NSString *responseFormat_;
}

/**
 Shoutcast API developer key.
 */
@property (nonatomic, copy) NSString *developerId;

/**
 Valid values are xml, json, and rss. 
 Recommend using the constants kRZShoutcastResponseFormat*.
 */
@property (nonatomic, copy) NSString *responseFormat;

/**
 Initialized the instance of RZShoutcastAPI with the developerId.
 */
- (id)initWithDeveloperId:(NSString *)developerId;

/**
 Get stations which match the keyword searched on SHOUTcast Radio Directory.
 Returns the response data from the web service call.
 */
- (NSData *)stationsWithKeyword:(NSString *)keyword error:(NSError **)error;

/**
 Get stations which match the genre specified as query.
 Returns the response data from the web service call.
 */
- (NSData *)stationsWithGenreName:(NSString *)genreName error:(NSError **)error;

/**
 Get all the genres on SHOUTcast Radio Directory.
 Returns the response data from the web service call.
 */
- (NSData *)genresWithError:(NSError **)error;

/**
 Get only the Primary Genres on SHOUTcast Radio Directory.
 Returns the response data from the web service call.
 */
- (NSData *)primaryGenresWithError:(NSError **)error;

/**
 Get secondary genre list (if present) for a specified primary genre.
 Returns the response data from the web service call.
 */
- (NSData *)secondaryGenresForGenreId:(NSString *)genreId error:(NSError **)error;

/**
 Get details such as Genre Name, Sub Genres (if its a primary genre), has children by passing the genre-id.
 Returns the response data from the web service call.
 */
- (NSData *)genreWithGenreId:(NSString *)genreId error:(NSError **)error;

/**
 Gets the tune-in playlist from Shoutcast.
 */
- (NSData *)playListForStationId:(NSString *)stationId error:(NSError **)error;

@end
