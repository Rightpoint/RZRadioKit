//
//  RZShoutcastAPITestCases.h
//  RZRadioKit
//
//  Created by Kirby Turner on 1/21/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface RZShoutcastAPITestCases : SenTestCase 
{

}

- (void)testStationsWithKeyword;
- (void)testStationsWithGenre;
- (void)testGenres;
- (void)testPrimaryGenres;
- (void)testSecondaryGenresForGenreId;
- (void)testGenreWithGenreId;


@end
