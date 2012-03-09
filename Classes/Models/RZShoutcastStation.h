//
//  RZShoutcastStation.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZRadioStation.h"


@interface RZShoutcastStation : RZRadioStation
{
@private
   NSString *shoutcastDeveloperId_;
   NSArray *playlist_;
}

@property (nonatomic, copy) NSString *shoutcastDeveloperId;

@end
