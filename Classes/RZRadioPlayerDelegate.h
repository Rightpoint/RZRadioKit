//
//  RZRadioPlayerDelegate.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/31/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RZRadioPlayer;

@protocol RZRadioPlayerDelegate <NSObject>
@optional
- (void)radioPlayer:(RZRadioPlayer *)radioPlayer didFailWithError:(NSError *)error;
- (void)radioPlayer:(RZRadioPlayer *)radioPlayer didReceiveMetadata:(NSDictionary *)metadata;
@end
