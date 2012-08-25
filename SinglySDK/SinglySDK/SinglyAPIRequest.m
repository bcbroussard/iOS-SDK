//
//  SinglyAPIRequest.m
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/24/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "SinglyAPIRequest.h"

@interface SinglyAPIRequest()
{
    NSDictionary* _parameters;
}
-(NSString*)escapeString:(NSString*)rawString;
@end


@implementation SinglyAPIRequest

@synthesize body = _body, method = _method, endpoint = _endpoint;

+(SinglyAPIRequest*)apiRequestForEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)parameters;
{
    return [[SinglyAPIRequest alloc] initWithEndpoint:endpoint andParameters:parameters];
}

+(SinglyAPIRequest*)apiRequestForEndpoint:(NSString *)endpoint;
{
    return [SinglyAPIRequest apiRequestForEndpoint:endpoint withParameters:nil];
}

-(id)initWithEndpoint:(NSString *)endpoint andParameters:(NSDictionary *)parameters;
{
    self = [super init];
    if (self) {
        self.method = @"GET";
        // Ignore the / if it's there
        _endpoint = [endpoint characterAtIndex:0] == '/' ? [endpoint substringFromIndex:1] : endpoint;
        _parameters = parameters;
    }
    return self;
}

-(NSString*)escapeString:(NSString*)rawString;
{
    CFStringRef originalString = (__bridge_retained CFStringRef)rawString;
    NSString* finalString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, originalString, NULL, NULL, kCFStringEncodingUTF8);
    CFRelease(originalString);
    return finalString;
}

-(NSString*)completeURLForToken:(NSString *)accessToken;
{
    NSString* apiURLStr = [NSString stringWithFormat:@"https://api.singly.com/v0/%@?access_token=%@", _endpoint, accessToken];
    if (_parameters) {
        NSMutableString* paramString = [NSMutableString string];
        [_parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (![obj isKindOfClass:[NSNull class]]) {
                [paramString appendFormat:@"&%@=%@", [self escapeString:key], [self escapeString:obj]];
            }
        }];
        apiURLStr = [apiURLStr stringByAppendingString:paramString];
    }
    return apiURLStr;
}
@end
