//
//  RZRadioPlayer.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZRadioPlayer.h"
#import "RZRadioPlayerErrors.h"
#import "RZRadioGenre.h"
#import "RZRadioStation.h"
#import "RZShoutcast.h"
#import "AudioStreamer.h"
#import "RZRadioCustomStation.h"
#import "RZPlayStationOperation.h"


NSString * const kRZRadioPlayerMetadataArtist = @"artist";
NSString * const kRZRadioPlayerMetadataTitle = @"title";
NSString * const kRZRadioPlayerMetadataUrl = @"url";
NSString * const kRZRadioPlayerMetadataStreamTitle = @"StreamTitle";
NSString * const kRZRadioPlayerMetadataStreamUrl = @"StreamUrl";
NSString * const kRZRadioPlayerMetadataArtistTitle = @"artistTitle";
NSString * const kRZRadioPlayerNotificationStateChanged = @"RZRadioPlayerStateChanged";


#define FAVORITES_FILE_NAME @"favorites"
#define RZRADIO_DIRECTORY_NAME @"RZ Radio"

@interface RZRadioPlayer ()
@property (assign) NSInteger playlistIndex;
@property (assign) NSInteger favoritesPlayIndex;
@property (retain) AudioStreamer *audioStreamer;
@property (retain) NSOperationQueue *operationQueue;

- (NSInteger)favoritesIndexOfStation:(RZRadioStation *)radioStation;
- (NSArray *)favoriteStationsWithStationId:(NSString *)stationId;
- (void)loadFavorites;
- (void)saveFavorites;
- (NSString *)favoritesDirectory;
- (BOOL)ensureDirectory:(NSString *)path;
- (void)destroyAudioStreamer;
- (void)setState:(RZRadioPlayerState)newState;
- (void)incrementPlaylistIndex;
@end


@implementation RZRadioPlayer

@synthesize delegate = delegate_;
@synthesize shoutcastDeveloperId = shoutcastDeveloperId_;
@synthesize playlistIndex = playlistIndex_;
@synthesize favoritesPlayIndex = favoritesPlayIndex_;
@synthesize currentTrackName = currentTrackName_;
@synthesize state = state_;
@synthesize audioStreamer = audioStreamer_;
@synthesize operationQueue = operationQueue_;

@dynamic station;

- (void)dealloc
{
   [self destroyAudioStreamer];
   
   [audioStreamer_ release], audioStreamer_ = nil;
   [station_ release], station_ = nil;
   [favoriteStations_ release], favoriteStations_ = nil;
   [genres_ release], genres_ = nil;
   [shoutcastDeveloperId_ release], shoutcastDeveloperId_ = nil;
   [currentTrackName_ release], currentTrackName_ = nil;
   [operationQueue_ release], operationQueue_ = nil;
   
   [super dealloc];
}

- (id)init
{
   self = [super init];
   if (self) {
      state_ = RZ_IDLED;
      favoriteStations_ = [[NSMutableArray alloc] init];
      [self setPlaylistIndex:0];
      [self performSelectorInBackground:@selector(loadFavorites) withObject:nil];
      
      NSOperationQueue *newQueue = [[NSOperationQueue alloc] init];
      [self setOperationQueue:newQueue];
      [newQueue release];
   }
   return self;
}

- (BOOL)ensureDirectory:(NSString *)path
{
   BOOL success = YES;
   NSError *error = nil;
   NSFileManager *fm = [[NSFileManager alloc] init];
   if ([fm fileExistsAtPath:path] == NO) {
      if ([fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error] == NO) {
         DLog(@"Error creating directory %@ : %@", path, error);
         success = NO;
      }
   }
   [fm release];
   
   return success;
}

- (void)reportError:(NSError *)error
{
   [self setState:RZ_ERROR];

   // Treat all alert notifcations as an error.
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(radioPlayer:didFailWithError:)]) {
      [[self delegate] radioPlayer:self didFailWithError:error];
   }
}

- (void)incrementPlaylistIndex
{
   [self setPlaylistIndex:[self playlistIndex]+1];
}


#pragma mark -
#pragma mark Playback Management

- (BOOL)isPlaying
{
   return ([self state] == RZ_PLAYING || [self state] == RZ_WAITING);
}

- (void)playStationAtURL:(NSURL*)url
{
   RZRadioCustomStation *newStation = [[[RZRadioCustomStation alloc] initWithURL:url] autorelease];
   [newStation fetchPlaylist:self action:@selector(customStationDidFetchPlaylist:)];
}

- (void)customStationDidFetchPlaylist:(RZRadioCustomStation *)customStation
{
   [self setStation:customStation];
   [self play];
}

- (void)playNextFavorite
{
   NSInteger index = [self favoritesIndexOfStation:[self station]] + 1;
   if (index < 0) index = [favoriteStations_ count] - 1;;
   if (index >= [favoriteStations_ count]) index = 0;
   
   if (index < [favoriteStations_ count]) {
      // Remember the current play state.
      BOOL playing = [self isPlaying];
      [self setStation:[favoriteStations_ objectAtIndex:index]];
      // Reset the play state if previous station was playing.
      if (playing) {
         [self play];
      }
   }
}

- (void)playPreviousFavorite
{
   NSInteger index = [self favoritesIndexOfStation:[self station]] - 1;
   if (index < 0) index = [favoriteStations_ count] - 1;;
   if (index > [favoriteStations_ count]) index = 0;
   
   if (index < [favoriteStations_ count]) {
      // Remember the current play state.
      BOOL playing = [self isPlaying];
      [self setStation:[favoriteStations_ objectAtIndex:index]];
      // Reset the play state if previous station was playing.
      if (playing) {
         [self play];
      }
   }
}

- (void)play
{
   if (![self station]) return;
   
   if ([self audioStreamer]) {
      if ([self state] == RZ_PAUSED || [self state] == RZ_PLAYING || [self state] == RZ_WAITING) {
         [[self audioStreamer] pause];
      }
      return;
   }
   
   [self setState:RZ_WAITING];
   [[self operationQueue] cancelAllOperations];
   RZPlayStationOperation *newOperation = [[RZPlayStationOperation alloc] initWithRadioPlayer:self playlistIndex:[self playlistIndex]];
   [[self operationQueue] addOperation:newOperation];
   [newOperation release];
}

// This method is called by RZPlayStationOperation.
- (void)startPlaybackOnMainThread:(id)audioStreamer
{
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc addObserver:self selector:@selector(audioStreamerStateChanged:) name:ASStatusChangedNotification object:audioStreamer];
   [nc addObserver:self selector:@selector(audioStreamerAlertReceived:) name:ASPresentAlertWithTitleNotification object:audioStreamer];
   [nc addObserver:self selector:@selector(audioStreamerMetadataReceived:) name:ASUpdateMetadataNotification object:audioStreamer];

   [self setAudioStreamer:audioStreamer];
   [audioStreamer start];
}

- (void)tryNextPlaylistURL
{
   [self destroyAudioStreamer];
   [self play];
}

- (void)setState:(RZRadioPlayerState)newState
{
   if (state_ != newState)
   {
      [self willChangeValueForKey:@"state"];
      state_ = newState;
      [self didChangeValueForKey:@"state"];
   }
}

#pragma mark -
#pragma mark Favorites

- (NSArray *)favoriteStations
{
   NSArray *favorites;
   favorites = [favoriteStations_ copy];

   return [favorites autorelease];
}

- (NSInteger)favoritesIndexOfStation:(RZRadioStation *)radioStation
{
   NSInteger index = -1;    // Return -1 if the station is not a favorite.
   NSArray *favorites = [self favoriteStationsWithStationId:[radioStation stationId]];
   if ([favorites count] > 0) {
      index = [favoriteStations_ indexOfObject:[favorites objectAtIndex:0]];
   }
   return index;
}

- (NSArray *)favoriteStationsWithStationId:(NSString *)stationId
{
   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationId LIKE %@", stationId];
   NSArray *results = [favoriteStations_ filteredArrayUsingPredicate:predicate];
   return results;
}

- (BOOL)isFavoriteStation:(RZRadioStation *)radioStation
{
   NSArray *results = [self favoriteStationsWithStationId:[radioStation stationId]];
   BOOL isFavorite = ([results count] > 0);

   return isFavorite;
}

- (void)toggleFavoriteStation:(RZRadioStation *)radioStation
{
   if (!radioStation) return;
   
   if ([self isFavoriteStation:radioStation]) {
      [self removeFavoriteStation:radioStation];
   } else {
      [self addFavoriteStation:radioStation];
   }
}

- (void)addFavoriteStation:(RZRadioStation *)radioStation
{
   if (!radioStation) return;
   
   NSInteger index = [favoriteStations_ count];
   NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
   [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"favoriteStations"];      
   
   [favoriteStations_ addObject:radioStation];
   [radioStation setFavorite:YES];
   [self performSelectorInBackground:@selector(saveFavorites) withObject:nil];
   
   [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"favoriteStations"];      
}

- (void)removeFavoriteStation:(RZRadioStation *)radioStation
{
   if (!radioStation) return;
   if (![favoriteStations_ containsObject:radioStation]) return;

   NSInteger index = [favoriteStations_ indexOfObject:radioStation];
   NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
   [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"favoriteStations"];      
   
   NSArray *results = [self favoriteStationsWithStationId:[radioStation stationId]];
   for (RZRadioStation *stationToRemove in results) {
      [stationToRemove setFavorite:NO];
      [favoriteStations_ removeObject:stationToRemove];
   }
   
   [radioStation setFavorite:NO];
   [self performSelectorInBackground:@selector(saveFavorites) withObject:nil];
   
   [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"favoriteStations"];      
}

- (void)loadFavorites
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

   [self willChangeValueForKey:@"favoriteStations"];
   NSString *path = [self favoritesDirectory];
   if ([self ensureDirectory:path]) {
      NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:FAVORITES_FILE_NAME]];
      NSArray *favoritesData = [NSArray arrayWithContentsOfURL:url];
      for (NSDictionary *dict in favoritesData) {
         RZRadioStation *newStation = [RZRadioStation stationWithDictionary:dict];
         [favoriteStations_ addObject:newStation];
      }
   }
   [self didChangeValueForKey:@"favoriteStations"];
   
   [pool drain];
}

- (void)saveFavorites
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

   NSString *path = [self favoritesDirectory];
   if ([self ensureDirectory:path]) {
      
      // Copy the data to a dictionary. It's a poor man's approach to
      // archiving.
      NSMutableArray *favoritesToSave = [[NSMutableArray alloc] initWithCapacity:[favoriteStations_ count]];
      for (RZRadioStation *station in favoriteStations_)
      {
         if (station && [station respondsToSelector:@selector(stationDictionary)]) {
            NSDictionary *dict = [ station stationDictionary];
            [favoritesToSave addObject:dict];
         }
      }
      
      NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:FAVORITES_FILE_NAME]];
#if TARGET_OS_IPHONE
      NSError *error = nil;
      if (![favoritesToSave writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
         DLog(@"Error saving favorites: %@", [error localizedDescription]);
      }
#else
      if (![favoritesToSave writeToURL:url atomically:YES]) {
         DLog(@"Error saving favorites : %@", favoritesToSave);
      }
#endif
      
      [favoritesToSave release];
   } else {
      DLog(@"Unable to save favorites.");
   }
   
   [pool drain];
}

- (NSString *)favoritesDirectory
{
#if TARGET_OS_IPHONE
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   return [paths objectAtIndex:0];
#else
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
   NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
   return [basePath stringByAppendingPathComponent:RZRADIO_DIRECTORY_NAME];
#endif
}


#pragma mark -
#pragma mark Stations

- (RZRadioStation *)station
{
   return station_;
}

- (void)setStation:(RZRadioStation *)newStation
{
   if (![station_ isEqualToStation:newStation]) {

      [self destroyAudioStreamer];

      [self willChangeValueForKey:@"station"];
      [station_ autorelease];
      station_ = [newStation retain];
      [self setPlaylistIndex:0];
      [self setCurrentTrackName:nil];
      [self didChangeValueForKey:@"station"];
   }
}

- (NSArray *)stationsByKeywordSearch:(NSString *)keyword
{
   NSString *devId = [self shoutcastDeveloperId];
   RZShoutcast *shoutcast = [[RZShoutcast alloc] initWithDeveloperId:devId];
   NSError *error = nil;
   NSArray *stations = [shoutcast stationsWithKeyword:keyword error:&error];
   [shoutcast release];
   
   return stations;
}

- (BOOL)isPlayingStation:(RZRadioStation *)radioStation
{
   BOOL playing = NO;
   if ([[self station] isEqualToStation:radioStation]) {
      playing = [self isPlaying];
   }
   return playing;
}


#pragma mark -
#pragma mark Genres

- (NSArray *)genres
{
   if (genres_ && [genres_ count] > 0) {
      return genres_;
   }
   
   NSString *devId = [self shoutcastDeveloperId];
   RZShoutcast *shoutcast = [[RZShoutcast alloc] initWithDeveloperId:devId];
   NSError *error = nil;
   genres_ = [[shoutcast genresError:&error] retain];
   [shoutcast release];
   
   if (error) {
      [self reportError:error];
   }
   
   return genres_;
}

-(void) requestGenresWithDelegate:(id<RZRadioGenreDelegate>)delegate
{
    if (genres_ && [genres_ count] > 0) {
        [delegate genresReceived:genres_];
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(queue, ^{
            NSArray* genres = self.genres; 
            if (genres && [genres count] > 0) {
                [delegate genresReceived:genres];
            }
            else {
                [delegate genresReceived:nil];
            }
        });
   }
}

#pragma mark -
#pragma mark AudioStreamer

- (void)destroyAudioStreamer
{
   [self setState:RZ_STOPPING];

   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc removeObserver:self];
   
   // If we try stopping while the audio queue is starting then
   // a race condition occurs. Loop while waiting for the audio queue
   // to start then stop it immediately.
   while ([[self audioStreamer] state] == AS_WAITING_FOR_QUEUE_TO_START) {
      DLog(@"I'm stuck");
      [NSThread sleepForTimeInterval:0.1];
   }

   [[self audioStreamer] stop];
   [self setAudioStreamer:nil];
   
   
   [self setState:RZ_IDLED];
}

- (void)audioStreamerStateChanged:(NSNotification *)notification
{
   if ([[self audioStreamer] state] == AS_WAITING_FOR_QUEUE_TO_START) {
      // When the user is radip firing the radio player with 
      // play requests, it's possible to cause a delay starting
      // the audio queue. This happen in AudioStreamer enqueueBuffer.
      // To try overcoming this problem, we check to see if we
      // are waiting for the audio queue to start. By not doing
      // anything else to the AudioStreamer instance, we avoid
      // the race condition.
      [self setState:RZ_WAITING];
   }
   else if ([[self audioStreamer] isWaiting])
	{
      DLog(@"State change: waiting");
      [self setState:RZ_WAITING];
		[[self audioStreamer] setMeteringEnabled:NO];
	}
	else if ([[self audioStreamer] isPlaying])
	{
      DLog(@"State change: playing");
      [self setState:RZ_PLAYING];
		[[self audioStreamer] setMeteringEnabled:YES];
	}
   else if ([[self audioStreamer] isPaused]) {
      DLog(@"State change: paused");
      [self setState:RZ_PAUSED];
   }
	else if ([[self audioStreamer] isIdle])
	{
      DLog(@"State change: idle");
      [self setState:RZ_IDLED];
      [self destroyAudioStreamer];
	}
   
   // #####
#ifdef DEBUG
   switch ([[self audioStreamer] state]) {
      case AS_INITIALIZED:
         DLog(@"AS_INITIALIZED");
         break;
      case AS_STARTING_FILE_THREAD:
         DLog(@"AS_STARTING_FILE_THREAD");
         break;
      case AS_WAITING_FOR_DATA:
         DLog(@"AS_WAITING_FOR_DATA");
         break;
      case AS_FLUSHING_EOF:
         DLog(@"AS_FLUSHING_EOF");
         break;
      case AS_WAITING_FOR_QUEUE_TO_START:
         DLog(@"AS_WAITING_FOR_QUEUE_TO_START");
         break;
      case AS_PLAYING:
         DLog(@"AS_PLAYING");
         break;
      case AS_BUFFERING:
         DLog(@"AS_BUFFERING");
         break;
      case AS_STOPPING:
         DLog(@"AS_STOPPING");
         break;
      case AS_STOPPED:
         DLog(@"AS_STOPPED");
         break;
      case AS_PAUSED:
         DLog(@"AS_PAUSED");
         break;
   }
#endif
}

- (void)audioStreamerAlertReceived:(NSNotification *)notification
{
   DLog(@"Audio Streamer error: %@", [notification userInfo]);
   
   

   [self incrementPlaylistIndex];
   NSInteger index = [self playlistIndex];
   NSInteger count = [[[self station] playlist] count];
   DLog(@"playlistIndex: %i count: %i", index, count);
   
   if (index < count) {
      [self performSelectorOnMainThread:@selector(tryNextPlaylistURL) withObject:nil waitUntilDone:NO];
      
   } else {
      // Reset the play list index. Causes the play list
      // to start from the beginning after reporting any
      // errors.
      [self setPlaylistIndex:0];

      // Treat all alert notifcations as an error.
      NSError *error = [NSError errorWithDomain:RZRadioPlayerErrorDomain code:RZRadioPlayerError userInfo:[notification userInfo]];
      [self reportError:error];
   }
}

- (NSDictionary *)dictionaryFromMetadata:(NSString *)metadata
{
   /** Example metadata
    * 
    StreamTitle='Kim Sozzi / Amuka / Livvi Franc - Secret Love / It's Over / Automatik',
    StreamUrl='&artist=Kim%20Sozzi%20%2F%20Amuka%20%2F%20Livvi%20Franc&title=Secret%20Love%20%2F%20It%27s%20Over%20%2F%20Automatik&album=&duration=1133453&songtype=S&overlay=no&buycd=&website=&picture=',
    
    Format is generally "Artist hypen Title" although servers may deliver only one. This code assumes 1 field is artist.
    */

   NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
   NSArray *metaParts = [metadata componentsSeparatedByString:@";"];
   for (NSString *item in metaParts) {
      // Split the key/value pair.
      NSArray *pair = [item componentsSeparatedByString:@"="];

      // Don't bother with bad metadata.
      if ([pair count] == 2) {
         NSString *key = [pair objectAtIndex:0];
         NSString *value = [pair objectAtIndex:1];

         [dict setObject:value forKey:key];
         if ([key isEqualToString:kRZRadioPlayerMetadataStreamTitle]) {
            // Separate the artist and title.
            NSString *streamTitle = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
            NSArray *streamParts = [streamTitle componentsSeparatedByString:@" - "];
            NSString *artist = @"";
            NSString *title = @"";
            if ([streamParts count] > 0) {
               artist = [streamParts objectAtIndex:0];
            }
            // this looks odd but not every server will have all artist hyphen title
            if ([streamParts count] >= 2) {
               title = [streamParts objectAtIndex:1];
            }
            
            NSString *artistTitleFormat = @"%@";
            if ([title length] > 1) {
               artistTitleFormat = @"%@ - %@";
            }
            NSString *artistTitle = [NSString stringWithFormat:artistTitleFormat, artist, title];
            
            [dict setObject:artist forKey:kRZRadioPlayerMetadataArtist];
            [dict setObject:title forKey:kRZRadioPlayerMetadataTitle];
            [dict setObject:artistTitle forKey:kRZRadioPlayerMetadataArtistTitle];
         }
         if ([key isEqualToString:kRZRadioPlayerMetadataStreamUrl]) {
            // Remove the ticks surrounding the url.
            NSString *urlString = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
            [dict setObject:urlString forKey:kRZRadioPlayerMetadataUrl];
         }
      }
   }
   
   NSDictionary *results = [NSDictionary dictionaryWithDictionary:dict];
   [dict release];
   
   return results;
}

- (void)audioStreamerMetadataReceived:(NSNotification *)notification
{
   // Save the current track name.
   NSString *metadata = [[notification userInfo] objectForKey:@"metadata"];
   NSDictionary *dict = [self dictionaryFromMetadata:metadata];
   
   NSString *trackName = nil;
   if (dict) {
      trackName = [dict objectForKey:kRZRadioPlayerMetadataArtistTitle];
   }
   [self setCurrentTrackName:trackName];

   
   // Tell the world about the new metadata.
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(radioPlayer:didReceiveMetadata:)]) {
      [[self delegate] radioPlayer:self didReceiveMetadata:dict];
   }
}


#pragma mark -
#pragma mark Level Metering

- (NSInteger)numberOfChannels
{
   return [[self audioStreamer] numberOfChannels];
}

- (BOOL)isMeteringEnabled
{
   if ([self isPlaying] == NO) return NO;
   
   return [[self audioStreamer] isMeteringEnabled];
}

- (float)peakPowerForChannel:(NSUInteger)channelNumber
{
   return [[self audioStreamer] peakPowerForChannel:channelNumber];
}

- (float)averagePowerForChannel:(NSUInteger)channelNumber
{
   return [[self audioStreamer] averagePowerForChannel:channelNumber];
}


#pragma mark -
#pragma mark RZRadioCustomStationDelegate

- (void)customStationDidLoadPlaylist:(RZRadioCustomStation *)station
{
   
}


@end
