//
//  RZRadioCustomStation.m
//  RZRadioKit
//
//  Created by Kirby Turner on 2/1/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZRadioCustomStation.h"
#import "RZShoutcastStationPlaylistParser.h"


@interface RZRadioCustomStation ()
@property (nonatomic, retain) NSMutableData *receivedData;
@end

@implementation RZRadioCustomStation

@synthesize URL = URL_;
@synthesize receivedData = receivedData_;

- (void)dealloc
{
   [receivedData_ release], receivedData_ = nil;
   [URL_ release], URL_ = nil;
   [playlist_ release], playlist_ = nil;
   [super dealloc];
}

- (id)initWithURL:(NSURL *)url
{
   self = [super init];
   if (self) {
      [self setURL:url];
      [self setName:[url absoluteString]];
      [self setStationId:@""];
      [self setMediaType:@""];
      [self setGenreName:@"Unknown"];
      [self setBitRate:[NSNumber numberWithInt:-1]];
      [self setListenerCount:[NSNumber numberWithInt:-1]];
   }
   return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
   self = [super initWithDictionary:dict];
   if (self) {
      [self setURL:[dict objectForKey:@"URL"]];
   }
   return self;
}

- (NSArray *)playlist
{
   return playlist_;
}

- (NSDictionary *)stationDictionary
{
   NSDictionary *dict = [super stationDictionary];
   
   NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
   [newDict setObject:[self URL] forKey:@"URL"];
   
   NSDictionary *results = [NSDictionary dictionaryWithDictionary:newDict];
   [newDict release];
   
   return results;
}

- (void)fetchPlaylist:(id)target action:(SEL)action
{
   target_ = target;
   action_ = action;
   
   [playlist_ release];
   playlist_ = [[NSArray alloc] initWithObjects:[self URL], nil];

   
   NSMutableData *newData = [[NSMutableData alloc] init];
   [self setReceivedData:newData];
   [newData release];

   NSURLRequest *request = [NSURLRequest requestWithURL:[self URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
   NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
   if (connection) {
      [connection start];
   }
}


#pragma mark -
#pragma mark NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   [[self receivedData] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   [[self receivedData] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   [connection release];
   if (target_ && action_) {
      [target_ performSelectorOnMainThread:action_ withObject:self waitUntilDone:NO];
   }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   [connection release];
   
   NSData *data = [self receivedData];
   RZShoutcastStationPlaylistParser *parser = [[RZShoutcastStationPlaylistParser alloc] init];
   NSArray *playlist = [parser parseData:data];
   [parser release];
   
   if (playlist && [playlist count] > 0) {
      [playlist_ release];
      playlist_ = [[NSArray alloc] initWithArray:playlist];
   }

   if (target_ && action_) {
      [target_ performSelectorOnMainThread:action_ withObject:self waitUntilDone:NO];
   }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
   if (redirectResponse) {
      return nil;
   } else {
      return request;
   }
}

@end
