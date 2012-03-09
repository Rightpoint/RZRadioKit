//
//  RZShoutcastStation.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastStation.h"
#import "RZShoutcast.h"


@implementation RZShoutcastStation

@synthesize shoutcastDeveloperId = shoutcastDeveloperId_;

- (void)dealloc
{
   [shoutcastDeveloperId_ release], shoutcastDeveloperId_ = nil;
   
   [super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
   self = [super initWithDictionary:dict];
   if (self) {
      [self setShoutcastDeveloperId:[dict objectForKey:@"shoutcastDeveloperId"]];
   }
   return self;
}

- (NSArray *)playlist
{
   if (playlist_ && [playlist_ count] > 0) {
      return playlist_;
   }
   
   RZShoutcast *shoutcast = [[RZShoutcast alloc] initWithDeveloperId:[self shoutcastDeveloperId]];
   NSError *error = nil;
   NSArray *playlist = [shoutcast playListForStationId:[self stationId] error:&error];
   [shoutcast release];
   
   if (error) {
      [self setError:error];
   } else {
      playlist_ = [playlist retain];
   }
   
   return playlist_;
}

- (NSDictionary *)stationDictionary
{
   NSDictionary *dict = [super stationDictionary];
   
   NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
   [newDict setObject:[self shoutcastDeveloperId] forKey:@"shoutcastDeveloperId"];
   
   NSDictionary *results = [NSDictionary dictionaryWithDictionary:newDict];
   [newDict release];
   
   return results;
}


@end
