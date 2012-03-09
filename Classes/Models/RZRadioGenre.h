//
//  RZRadioGenre.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/26/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RZRadioGenre : NSObject 
{
@private
   NSString *name_;
   NSString *genreId_;
   RZRadioGenre *parentGenre_;
   NSError *error_;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *genreId;
@property (nonatomic, assign) RZRadioGenre *parentGenre;
@property (nonatomic, retain) NSError *error;

- (BOOL)hasChildren;
- (NSMutableArray *)children;

- (BOOL) hasStations;
- (NSMutableArray *)stations;

@end
