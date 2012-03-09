//
//  RZRadioPlayer.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZRadioPlayerDelegate.h"

extern NSString * const kRZRadioPlayerMetadataArtist;
extern NSString * const kRZRadioPlayerMetadataTitle;
extern NSString * const kRZRadioPlayerMetadataUrl;
extern NSString * const kRZRadioPlayerMetadataStreamTitle;
extern NSString * const kRZRadioPlayerMetadataStreamUrl;
extern NSString * const kRZRadioPlayerMetadataArtistTitle;

typedef enum
{
	RZ_IDLED = 0,
	RZ_WAITING,
	RZ_PLAYING,
	RZ_PAUSED,
   RZ_STOPPING,
   RZ_STOPPED,
   RZ_ERROR
} RZRadioPlayerState;

@class RZRadioStation;
@class AudioStreamer;
@protocol RZRadioGenreDelegate;

@interface RZRadioPlayer : NSObject 
{
@private
   id<RZRadioPlayerDelegate> delegate_;
   RZRadioStation *station_;
   NSString *shoutcastDeveloperId_;
   AudioStreamer *audioStreamer_;
   NSInteger playlistIndex_;
   NSInteger favoritesPlayIndex_;
   
   NSMutableArray *favoriteStations_;
   NSArray *genres_;
   NSString *currentTrackName_;
   
   RZRadioPlayerState state_;
   NSOperationQueue *operationQueue_;   // Used to initialize the audio streamer and start playback.
}

@property (assign) id<RZRadioPlayerDelegate> delegate;
@property (retain) RZRadioStation *station;
@property (copy) NSString *shoutcastDeveloperId;
@property (copy) NSString *currentTrackName;
@property (readonly) RZRadioPlayerState state;

- (BOOL)isPlaying;
- (void)play;
- (NSArray *)favoriteStations;
- (BOOL)isFavoriteStation:(RZRadioStation *)radioStation;
- (void)toggleFavoriteStation:(RZRadioStation *)radioStation;
- (void)addFavoriteStation:(RZRadioStation *)radioStation;
- (void)removeFavoriteStation:(RZRadioStation *)radioStation;
- (void)playStationAtURL:(NSURL*)url;
- (void)playNextFavorite;
- (void)playPreviousFavorite;
- (NSArray *)stationsByKeywordSearch:(NSString *)keyword;
- (BOOL)isPlayingStation:(RZRadioStation *)radioStation;

- (void)reportError:(NSError *)error;  // Used internally. Do not call this method outside RZRadioKit.
- (void)startPlaybackOnMainThread:(id)audioStreamer;  // Used internally. Do not call this metho outside RZRadioKit.


/**
 Returns an array of RZRadioGenre.
 */
- (NSArray *)genres;

/**
 Requests a genres asynchronously
 */
-(void) requestGenresWithDelegate:(id<RZRadioGenreDelegate>)delegate;

/**
 Level Metering
 */
- (NSInteger)numberOfChannels;
- (BOOL)isMeteringEnabled;
- (float)peakPowerForChannel:(NSUInteger)channelNumber;
- (float)averagePowerForChannel:(NSUInteger)channelNumber;


@end
