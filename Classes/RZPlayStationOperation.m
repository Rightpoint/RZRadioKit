//
//  RZPlayStationOperation.m
//  RZRadioKit
//
//  Created by Kirby Turner on 3/20/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZPlayStationOperation.h"
#import "RZRadioPlayer.h"
#import "RZRadioStation.h"
#import "RZRadioPlayerErrors.h"
#import "AudioStreamer.h"


@implementation RZPlayStationOperation

- (void)dealloc
{
   [station_ release];
   [super dealloc];
}

- (id)initWithRadioPlayer:(RZRadioPlayer *)radioPlayer playlistIndex:(NSInteger)playlistIndex;
{
   self = [super init];
   if (self) {
      station_ = [[radioPlayer station] retain];
      playlistIndex_ = playlistIndex;
      radioPlayer_ = radioPlayer;
   }
   return self;
}

- (void)reportErrorOnMainThread:(NSError*)error
{
   if (![self isCancelled]) {
      [radioPlayer_ performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:NO];
   }
}

- (void)startPlaybackOnMainThread:(AudioStreamer *)streamer
{
   if (![self isCancelled]) {
      [radioPlayer_ performSelectorOnMainThread:@selector(startPlaybackOnMainThread:) withObject:streamer waitUntilDone:NO];
   }
}

- (void)main
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   
   if ([self isCancelled]) {
      [pool drain];
      return;
   }
   
   NSArray *playlist = [station_ playlist];
   if ([station_ error]) {
      [self reportErrorOnMainThread:[station_ error]];
      [pool drain];
      return;
   }
   
   if (![self isCancelled] && playlistIndex_ < [playlist count]) {
      NSURL *url = [playlist objectAtIndex:playlistIndex_];
      AudioStreamer *newStreamer = [[[AudioStreamer alloc] initWithURL:url] autorelease];
      [newStreamer setRetrieveShoutcastMetaData:YES];
      
      [self startPlaybackOnMainThread:newStreamer];
      
   } else if (![self isCancelled]) {
      NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Station currently unavailable. Try again later.", @"message", nil];
      NSError *error = [NSError errorWithDomain:RZRadioPlayerErrorDomain code:RZRadioPlayerNoPlaylist userInfo:userInfo];
      [self reportErrorOnMainThread:error];
   }
   
   [pool drain];
}


@end
