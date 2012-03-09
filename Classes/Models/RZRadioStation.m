//
//  RZRadioStation.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/31/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZRadioStation.h"


@implementation RZRadioStation

@synthesize name = name_;
@synthesize stationId = stationId_;
@synthesize mediaType = mediaType_;
@synthesize bitRate = bitRate_;
@synthesize genreName = genreName_;
@synthesize listenerCount = listenerCount_;
@synthesize favorite = favorite_;
@synthesize error = error_;

- (void)dealloc
{
   [error_ release], error_ = nil;
   [name_ release], name_ = nil;
   [stationId_ release], stationId_ = nil;
   [mediaType_ release], mediaType_ = nil;
   [bitRate_ release], bitRate_ = nil;
   [genreName_ release], genreName_ = nil;
   [listenerCount_ release], listenerCount_ = nil;
   
   [super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
   self = [super init];
   if (self) {
      [self setName:[dict objectForKey:@"name"]];
      [self setStationId:[dict objectForKey:@"stationId"]];
      [self setMediaType:[dict objectForKey:@"mediaType"]];
      [self setBitRate:[dict objectForKey:@"bitRate"]];
      [self setGenreName:[dict objectForKey:@"genreName"]];
      [self setListenerCount:[dict objectForKey:@"listenerCount"]];
   }
   return self;
}

//- (NSString *)description
//{
//   NSString *descr = [NSString stringWithFormat:@"{name='%@', stationId='%@', mediaType='%@', bitRate=%@, listenerCount=%@, genreName='%@', isFavorite=%@, playList=%@", [self name], [self stationId], [self mediaType], [self bitRate], [self listenerCount], [self genreName], [self isFavorite] ? @"YES" : @"NO", [self playlist]];
//   return descr;
//}

- (NSArray *)playlist
{
   return [NSArray array];
}

- (NSDictionary *)stationDictionary
{
   NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
   [dict setObject:@"1.0" forKey:@"version"];
   [dict setObject:NSStringFromClass([self class]) forKey:@"className"];
   [dict setObject:[self name] forKey:@"name"];
   [dict setObject:[self stationId] forKey:@"stationId"];
   [dict setObject:[self mediaType] forKey:@"mediaType"];
   [dict setObject:[self bitRate] forKey:@"bitRate"];
   [dict setObject:[self genreName] forKey:@"genreName"];
   [dict setObject:[self listenerCount] forKey:@"listenerCount"];
   
   NSDictionary *results = [NSDictionary dictionaryWithDictionary:dict];
   [dict release];
   
   return results;
}

- (BOOL)isEqualToStation:(RZRadioStation *)compareToStation
{ 
   BOOL isEqual = [[self stationId] isEqualToString:[compareToStation stationId]];
   return isEqual;
}

+ (id)stationWithDictionary:(NSDictionary *)dict
{
   id newStation = nil;
   
   NSString *className = [dict objectForKey:@"className"];
   Class stationClass = NSClassFromString(className);
   if (stationClass) {
      newStation = [[stationClass alloc] initWithDictionary:dict];
   }
   
   return [newStation autorelease];
}

@end
