//
//  RZShoutcastGenre.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastGenre.h"
#import "RZShoutcast.h"
#import "RZRadioStation.h"

@interface RZShoutcastGenre ()
- (void)fetchChildrenGenres;
- (NSArray *)fetchGenreStations;
@end

@implementation RZShoutcastGenre

@synthesize parentId = parentId_;
@synthesize shoutcastDeveloperId = shoutcastDeveloperId_;

- (void)dealloc
{
   [parentId_ release], parentId_ = nil;
   [shoutcastDeveloperId_ release], shoutcastDeveloperId_ = nil;
   [children_ release], children_ = nil;
   [stations_ release], stations_ = nil;
   
   [super dealloc];
}

- (BOOL)hasChildren
{
   return hasChildren_;
}

- (void)setHasChildren:(BOOL)hasChildren
{
   if (hasChildren_ != hasChildren) {
      [self willChangeValueForKey:@"hasChildren"];
      hasChildren_ = hasChildren;
      [self didChangeValueForKey:@"hasChildren"];
   }
}

- (NSMutableArray *)children
{
   if (children_ && [children_ count] > 0) return children_;
   
   [children_ autorelease];   // Autorelease in case someone outside as retained it.
   children_ = [[NSMutableArray alloc] init];
   [self performSelectorInBackground:@selector(fetchChildrenGenres) withObject:nil];
   return children_;
}

- (void)prefetchChildren
{
#if TARGET_OS_IPHONE
   return;
#else
   [self children];
#endif
}

- (void)fetchChildrenGenres
{
   // Shoutcast tells us if the genre has children. No need to
   // waste a network call if we know there are no children.
   if ([self hasChildren] == NO) return;

   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   
   RZShoutcast *shoutcast = [[RZShoutcast alloc] initWithDeveloperId:[self shoutcastDeveloperId]];
   NSError *error = nil;
   NSArray *genres = [shoutcast genresForGenre:self error:&error];
   [self setError:error];
   [shoutcast release];

   [self willChangeValueForKey:@"children"];
   [children_ addObjectsFromArray:genres];
   [self didChangeValueForKey:@"children"];
   
   [pool drain];
}

- (BOOL)hasStations
{
   BOOL result = ([[self stations] count] > 0);
   return result;
}

- (NSArray *)stations
{
   if (stations_ && [stations_ count] > 0) {
      return stations_;
   }
   
   NSArray *genreStations = [self fetchGenreStations];
   stations_ = [[NSMutableArray alloc] initWithArray:genreStations];
   return stations_;
}

- (NSArray *)fetchGenreStations
{
   RZShoutcast *shoutcast = [[RZShoutcast alloc] initWithDeveloperId:[self shoutcastDeveloperId]];
   NSError *error = nil;
   NSArray *genreStations = [shoutcast stationsWithGenre:self error:&error];
   [self setError:error];
   [shoutcast release];
   
   return genreStations;
}

-(void) requestStationsWithDelegate:(id<RZRadioStationsDelegate>)delegate
{
    if (stations_ && [stations_ count] > 0) {
        [delegate stationsReceived:stations_ forGenre:self];
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(queue, ^{
            NSArray* stations = [self fetchGenreStations];
            if (nil != stations) {
                stations_ = [[NSMutableArray alloc] initWithArray:stations];
            }
            
            [delegate stationsReceived:stations_ forGenre:self];
        });
    }

    
}

@end
