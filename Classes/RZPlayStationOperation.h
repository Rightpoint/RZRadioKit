//
//  RZPlayStationOperation.h
//  RZRadioKit
//
//  Created by Kirby Turner on 3/20/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RZRadioPlayer;
@class RZRadioStation;

@interface RZPlayStationOperation : NSOperation 
{
@private
   RZRadioStation *station_;
   RZRadioPlayer *radioPlayer_;
   NSInteger playlistIndex_;
}

/**
 Designated initializer.
 */
- (id)initWithRadioPlayer:(RZRadioPlayer *)radioPlayer playlistIndex:(NSInteger)playlistIndex;

@end
