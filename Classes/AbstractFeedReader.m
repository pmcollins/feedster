//
//  FeedParser.m
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "AbstractFeedReader.h"

@implementation AbstractFeedReader

- (id)init
{
    self = [super init];

    _unchartedDepth = 0;
    _nodeStack = [[NSMutableArray alloc] init];

    _currNodeHandler = _rootNodeHandler = [[NodeHandler alloc] init];

    _rssRdfNodeHandler = [[NodeHandler alloc] init];
    [_rootNodeHandler setChildHandler:_rssRdfNodeHandler forKey:@"rss"];
    [_rootNodeHandler setChildHandler:_rssRdfNodeHandler forKey:@"rdf:RDF"];
    
    _channelHandler = [[NodeHandler alloc] init];
    [_rssRdfNodeHandler setChildHandler:_channelHandler forKey:@"channel"];

    _atomFeedHandler = [[NodeHandler alloc] init];
    [_rootNodeHandler setChildHandler:_atomFeedHandler forKey:@"feed"];

    return self;
}

- (void)setDelegate:(id <FeedExplorerDelegate>)d
{
    _delegate = d;
}

- (void)loadDocument:(NSString *)doc
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[doc dataUsingEncoding:NSUTF8StringEncoding]];
    [xmlParser setDelegate:self];
    [xmlParser parse];
}

#pragma - Delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if (_unchartedDepth) {
        _unchartedDepth++;
        return;
    }
    NodeHandler *child = [_currNodeHandler childForKey:elementName];
    if (child) {
        [child tagStartedWithAttributes: attributeDict];
        _currNodeHandler = child;
        [_nodeStack addObject:child];
    } else {
        _unchartedDepth++;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currNodeHandler foundCharacters:string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (_unchartedDepth) {
        _unchartedDepth--;
        return;
    }
    [_currNodeHandler tagEnded];
    if ([_nodeStack count]) {
        [_nodeStack removeLastObject];
        _currNodeHandler = [_nodeStack lastObject];
    } else {
        _currNodeHandler = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    _errorOccurred = YES;
    [_delegate explorerExploded:[NSString stringWithFormat:@"parseErrorOccurred: %@", parseError]];
}

- (BOOL)errorOccurred
{
    return _errorOccurred;
}

@end
