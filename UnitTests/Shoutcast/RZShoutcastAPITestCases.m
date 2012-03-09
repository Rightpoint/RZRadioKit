//
//  RZShoutcastAPITestCases.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/21/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastAPITestCases.h"
#import "RZShoutcastAPI.h"

#define kShoutcastDeveloperId @"sh1wdCBnQQWepq2k"

@implementation RZShoutcastAPITestCases

- (void)testStationsWithKeyword
{
   RZShoutcastAPI *shoutcast = [[RZShoutcastAPI alloc] initWithDeveloperId:kShoutcastDeveloperId];
   NSError *error = nil;
   NSData *data = [shoutcast stationsWithKeyword:@"industrial" error:&error];
   [shoutcast release];
   
   STAssertNotNil(data, @"No stations returned.");
   
   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   NSLog(@"Response data: %@", string);
}

- (void)testStationsWithGenre
{
   RZShoutcastAPI *shoutcast = [[RZShoutcastAPI alloc] initWithDeveloperId:kShoutcastDeveloperId];
   NSError *error = nil;
   NSData *data = [shoutcast stationsWithGenreName:@"industrial" error:&error];
   [shoutcast release];
   
   STAssertNotNil(data, @"No stations returned.");
   
   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   NSLog(@"Response data: %@", string);
}

- (void)testGenres
{
   RZShoutcastAPI *shoutcast = [[RZShoutcastAPI alloc] initWithDeveloperId:kShoutcastDeveloperId];
   NSError *error = nil;
   NSData *data = [shoutcast genresWithError:&error];
   [shoutcast release];
   
   STAssertNotNil(data, @"No genres returned.");
   
   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   NSLog(@"Response data: %@", string);
}

- (void)testPrimaryGenres
{
   RZShoutcastAPI *shoutcast = [[RZShoutcastAPI alloc] initWithDeveloperId:kShoutcastDeveloperId];
   NSError *error = nil;
   NSData *data = [shoutcast primaryGenresWithError:&error];
   [shoutcast release];
   
   STAssertNotNil(data, @"No genres returned.");
   
   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   NSLog(@"Response data: %@", string);
}

- (void)testSecondaryGenresForGenreId
{
   RZShoutcastAPI *shoutcast = [[RZShoutcastAPI alloc] initWithDeveloperId:kShoutcastDeveloperId];
   NSError *error = nil;
   NSData *data = [shoutcast secondaryGenresForGenreId:@"24" error:&error];
   [shoutcast release];
   
   STAssertNotNil(data, @"No genres returned.");
   
   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   NSLog(@"Response data: %@", string);
}

- (void)testGenreWithGenreId
{
   RZShoutcastAPI *shoutcast = [[RZShoutcastAPI alloc] initWithDeveloperId:kShoutcastDeveloperId];
   NSError *error = nil;
   NSData *data = [shoutcast genreWithGenreId:@"24" error:&error];
   [shoutcast release];
   
   STAssertNotNil(data, @"No genres returned.");
   
   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   NSLog(@"Response data: %@", string);
}

@end
