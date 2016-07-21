//
//  Node.m
//  Vlow
//
//  Created by Joseph Constantakis on 12/31/14.
//  Copyright (c) 2014 Chelseph. All rights reserved.
//

#import "VlowNode.h"
#import "ObjectiveSugar.h"
#import "ReactiveCocoa.h"
#import "PdBase.h"
#import "PdFile.h"

PdFile *openPatch(NSString *name) {
    NSString *resourcePath = [[NSBundle bundleForClass:VlowNode.class] resourcePath];
    return [PdFile openFileNamed:[name stringByAppendingString:@".pd"]
                            path:resourcePath];
}

@implementation VlowNode

+ (instancetype)node:(NSString *)name
{
    VlowNode *node = [[VlowNode alloc] initWithName:name];
    return node;
}

- (instancetype)initWithName:(NSString *)name
{
    if (!(self = [super init]))
        return nil;
    
    self.name = name;
    
    return self;
}

- (void)activate
{
    self.patch = self.patch ?: openPatch(self.name);
}

- (NSString *)description
{
    return self.name;
}

- (void)setParameter:(NSString *)paramName toValue:(id)value
{
    if (!value || !paramName || paramName.length == 0) {
        return;
    }
    NSString *receiver = [NSString stringWithFormat:@"%@-%d",
                          paramName, self.patch.dollarZero];
    if ([value isKindOfClass:[NSNumber class]]) {
        [PdBase sendFloat:[value floatValue] toReceiver:receiver];
    } else if ([value isKindOfClass:[NSString class]]) {
        [PdBase sendMessage:value withArguments:nil
                 toReceiver:receiver];
    } else if ([value isKindOfClass:[NSArray class]]) {
        [PdBase sendList:value toReceiver:receiver];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    VlowNode *copy = [[[self class] allocWithZone:zone] init];
    copy.name = self.name;
    copy.patch = openPatch(self.name);
    return copy;
}

@end
