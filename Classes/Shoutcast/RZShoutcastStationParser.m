//
//  RZShoutcastStationParser.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastStationParser.h"
#import "RZShoutcastStation.h"


#define kRZShoutcastValueKeyStation @"station"
#define kRZShoutcastValueKeyName @"name"
#define kRZShoutcastValueKeyId @"id"
#define kRZShoutcastValueKeyMediaType @"mt"
#define kRZShoutcastValueKeyBitRate @"br"
#define kRZShoutcastValueKeyListenerCount @"lc"
#define kRZShoutcastValueKeyGenreName @"genre"

@interface RZShoutcastStationParser ()
@property (nonatomic, retain) RZShoutcastStation *currentStation;
@property (nonatomic, retain) NSMutableArray *stations;
@end

@implementation RZShoutcastStationParser

@synthesize delegate = delegate_;
@synthesize currentStation = currentStation_;
@synthesize stations = stations_;
@synthesize defaultGenreName = defaultGenreName_;

- (void)dealloc
{
   [currentStation_ release], currentStation_ = nil;
   [stations_ release], stations_ = nil;
   [defaultGenreName_ release], defaultGenreName_ = nil;
   
   [super dealloc];
}

- (NSArray *)parseData:(NSData *)data
{
   NSMutableArray *array = [[NSMutableArray alloc] init];
   [self setStations:array];
   [array release];
   
   NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
   [parser setDelegate:self];
   [parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
   [parser setShouldReportNamespacePrefixes:NO]; //
   [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
   
   [parser parse];
   
   [parser release];
   
   return [NSArray arrayWithArray:[self stations]];
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
   
   if (qName) {
      elementName = qName;
   }
   
	if(![elementName isEqualToString:kRZShoutcastValueKeyStation]) {
      return;
   }
   
   RZShoutcastStation *station = [[RZShoutcastStation alloc] init];
   [station setName:[attributeDict objectForKey:kRZShoutcastValueKeyName]];
   [station setStationId:[attributeDict objectForKey:kRZShoutcastValueKeyId]];
   [station setMediaType:[attributeDict objectForKey:kRZShoutcastValueKeyMediaType]];
   if (defaultGenreName_) {
      [station setGenreName:defaultGenreName_]; // Always use the default genre name if we have one.
   } else {
      [station setGenreName:[attributeDict objectForKey:kRZShoutcastValueKeyGenreName]];
   }
   [station setListenerCount:[NSNumber numberWithInteger:[[attributeDict objectForKey:kRZShoutcastValueKeyListenerCount] intValue]]];

   [station setBitRate:[NSNumber numberWithInteger:[[attributeDict objectForKey:kRZShoutcastValueKeyBitRate] intValue]]];

   ZAssert([self delegate], @"Unassigned delegate");
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(shoutcastDeveloperId)]) {
      NSString *devId = [[self delegate] shoutcastDeveloperId];
      [station setShoutcastDeveloperId:devId];
   }
   
   [self setCurrentStation:station];
   [station release];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
   
   if (qName) {
      elementName = qName;
   }
   
	if(![elementName isEqualToString:kRZShoutcastValueKeyStation]) {
      return;
   }
   
   [[self stations] addObject:[self currentStation]];
   [self setCurrentStation:nil];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
   DLog(@"Parser error: %@", [parseError localizedDescription]);
}


@end
