//
//  RZRadioStation.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/26/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RZRadioStation : NSObject
{
@private
   NSString *name_;
   NSString *stationId_;
   NSString *mediaType_;
   NSNumber *bitRate_;
   NSString *genreName_;
   NSNumber *listenerCount_;
   BOOL favorite_;
   NSError *error_;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *stationId;
@property (nonatomic, copy) NSString *mediaType;
@property (nonatomic, copy) NSNumber *bitRate;
@property (nonatomic, copy) NSString *genreName;
@property (nonatomic, copy) NSNumber *listenerCount;
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;
@property (nonatomic, retain) NSError *error;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSArray *)playlist;
- (NSDictionary *)stationDictionary;
- (BOOL)isEqualToStation:(RZRadioStation *)compareToStation;
+ (id)stationWithDictionary:(NSDictionary *)dict;

@end
