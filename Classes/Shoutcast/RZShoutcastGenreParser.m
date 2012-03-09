//
//  RZShoutcastGenreParser.m
//  RZRadioKit
//
//  Created by Kirby Turner on 1/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZShoutcastGenreParser.h"
#import "RZShoutcastGenre.h"
#import "RZRadioGenre.h"

#define kRZShoutcastValueKeyGenre @"genre"
#define kRZShoutcastValueKeyName @"name"
#define kRZShoutcastValueKeyId @"id"
#define kRZShoutcastValueKeyHasChildren @"haschildren"
#define kRZShoutcastValueKeyParentId @"parentid"
#define kRZShoutcastValueKeyGenreList @"genrelist"

@interface RZShoutcastGenreParser ()
@property (nonatomic, retain) RZShoutcastGenre *currentGenre;
@property (nonatomic, retain) NSMutableArray *genres;
@property (nonatomic, assign) RZRadioGenre *parentGenre; 
@end

@implementation RZShoutcastGenreParser

@synthesize currentGenre = currentGenre_;
@synthesize genres = genres_;
@synthesize parentGenre = parentGenre_;
@synthesize delegate = delegate_;

- (void)dealloc
{
   [currentGenre_ release], currentGenre_ = nil;
   [genres_ release], genres_ = nil;
   
   [super dealloc];
}

- (NSArray *)parseData:(NSData *)data parentGenre:(RZRadioGenre *)genre
{
   NSMutableArray *array = [[NSMutableArray alloc] init];
   [self setGenres:array];
   [array release];
   
   [self setParentGenre:genre];
   
   NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
   [parser setDelegate:self];
   [parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
   [parser setShouldReportNamespacePrefixes:NO]; //
   [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
   
   [parser parse];
   
   [parser release];
   
   return [NSArray arrayWithArray:[self genres]];
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{

   if (qName) {
      elementName = qName;
   }
   
	if(![elementName isEqualToString:kRZShoutcastValueKeyGenre]) {
      return;
   }

   RZShoutcastGenre *genre = [[RZShoutcastGenre alloc] init];
   [genre setName:[attributeDict objectForKey:kRZShoutcastValueKeyName]];
   [genre setGenreId:[attributeDict objectForKey:kRZShoutcastValueKeyId]];
   
   BOOL hasChildren = [[attributeDict objectForKey:kRZShoutcastValueKeyHasChildren] boolValue];
   [genre setHasChildren:hasChildren];
   
   [genre setParentGenre:[self parentGenre]];
   [genre setParentId:[attributeDict objectForKey:kRZShoutcastValueKeyParentId]];
   
   ZAssert([self delegate], @"Unassigned delegate");
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(shoutcastDeveloperId)]) {
      NSString *devId = [[self delegate] shoutcastDeveloperId];
      [genre setShoutcastDeveloperId:devId];
   }
   
   [self setCurrentGenre:genre];
   [genre release];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
   
   if (qName) {
      elementName = qName;
   }
   
	if(![elementName isEqualToString:kRZShoutcastValueKeyGenre]) {
      return;
   }

   [[self genres] addObject:[self currentGenre]];
   [[self currentGenre] prefetchChildren];
   [self setCurrentGenre:nil];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
   DLog(@"Parser error: %@", [parseError localizedDescription]);
}



@end
