//
//  RZShoutcastStationPlaylistParser.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/29/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastStationPlaylistParser.h"


@implementation RZShoutcastStationPlaylistParser

@synthesize delegate = delegate_;

- (NSArray *)parseData:(NSData *)data
{
   NSMutableArray *playlist = [[NSMutableArray alloc] init];
   
   NSString *playlistString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   DLog(@"Playlist data: %@", playlistString);
   
	// break the string into its components. 
	NSArray* components = [playlistString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	DLog(@"Components: %@", components);
	
	NSRange fileRage;
	fileRage.location = 0;
	fileRage.length = 4;
	
	// logic for pls files
	for(int index = 0; index < components.count; index++)
	{
		NSString* currentComponent = [components objectAtIndex:index];
		NSArray* subComponents = [currentComponent componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
		
		if(subComponents.count == 2)
		{
			if(NSOrderedSame ==[[subComponents objectAtIndex:0] compare:@"File" options:NSCaseInsensitiveSearch range:fileRage])
			{
				
				NSString *escapedValue =
				[(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                 nil,
                                                                 (CFStringRef)[subComponents objectAtIndex:1],
                                                                 NULL,
                                                                 NULL,
                                                                 kCFStringEncodingUTF8)
				 autorelease];
				
				NSURL *url = [NSURL URLWithString:escapedValue];
				
				[playlist addObject:url /*[NSURL URLWithString:[subComponents objectAtIndex:1]]*/ ];
			}
		}
	}
	
	
	// logic for m3u files
	if([playlist count] <= 0)
	{
		for(int index = 0; index < components.count; index++)
		{
			NSString* currentComponent = [components objectAtIndex:index];
			if(currentComponent.length > 0)
			{
				// check the component for http as well as the presence of at least one dot
				NSRange httpRange  = [currentComponent rangeOfString:@"http://"  options:NSCaseInsensitiveSearch];
				NSRange httpsRange = [currentComponent rangeOfString:@"https://" options:NSCaseInsensitiveSearch];
				NSRange dotRange   = [currentComponent rangeOfString:@"." options:NSCaseInsensitiveSearch];
				
				if(NSNotFound == dotRange.location ||
					(NSNotFound == httpRange.location &&
                NSNotFound == httpsRange.location))
				{
					continue;
				}
				
				NSURL* url = [NSURL URLWithString:currentComponent];
            
				if(nil != url)
					[playlist addObject:url];
			}
		}
	}
	
	DLog(@"Playlist: %@", playlist);
	
   NSArray *result = [NSArray arrayWithArray:playlist];
   [playlist release];
   [playlistString release];
   
   return result;
}

@end
