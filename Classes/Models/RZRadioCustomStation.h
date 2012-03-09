//
//  RZRadioCustomStation.h
//  RZRadioKit
//
//  Created by Kirby Turner on 2/1/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZRadioStation.h"

/**
 This station class is used for custom URL stations. When the user
 enters a custom URL, a custom station is created for playback.
 */
@interface RZRadioCustomStation : RZRadioStation 
{
@private
   NSArray *playlist_;
   NSURL *URL_;
   NSMutableData *receivedData_;
   id target_;
   SEL action_;
}

@property (nonatomic, copy) NSURL *URL;

- (id)initWithURL:(NSURL *)url;
- (void)fetchPlaylist:(id)target action:(SEL)action;

@end
