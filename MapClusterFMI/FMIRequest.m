//
//  BZBRequest.m
//  BuzzBank
//
//  Created by Nikolay Kivshanov on 3/29/13.
//  Copyright (c) 2013 Nikolay Kivshanov. All rights reserved.
//

#import "FMIRequest.h"

#define SERVER @"https://api.foursquare.com/"
#define SERVER_BASE @"api.foursquare.com"

static char *requestsTypesArray[] =
{
    "v2/venues/search",
    "v2/venues/search",
    "v2/venues/search"
};

@implementation FMIRequest {
     
    NSMutableURLRequest *request;
}

+ (NSString *)cuurentSurver {
    return SERVER;
}

+ (NSString *)serverBase {
    return SERVER_BASE;
}

@synthesize method,getParams,postParams,requestName,delegate;

- (void)send {
    // construct request
    
    if(self.getParams) {
        NSString *getParamString = [self constructGetParametersString];
        NSString *URLString = [NSString stringWithFormat:@"%@%@?%@",[FMIRequest cuurentSurver], [NSString stringWithUTF8String:requestsTypesArray[requestName]] ,getParamString];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]
                                          cachePolicy:NSURLCacheStorageNotAllowed
                                      timeoutInterval:30];
    }
    else{
        NSString *URLString = [NSString stringWithFormat:@"%@%@",[FMIRequest cuurentSurver], [NSString stringWithUTF8String:requestsTypesArray[requestName]]];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]
                                          cachePolicy:NSURLCacheStorageNotAllowed
                                      timeoutInterval:30];
    }
    
    
    [request setHTTPMethod:method];
    if(self.postParams) {
    
        [request addValue:@"application/x-www-form-urlencoded"
       forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[self postParamDataFromDictionary:self.postParams]];
    }
    
    [request setTimeoutInterval:30];
    
    [self start];
}

- (void)start {

    
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSLog(@"sending request: %@\n with post params %@",request.URL,self.postParams);
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *resposne, NSData * data, NSError *error) {
            
            if(data) {
            
                id json = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:kNilOptions
                                 error:&error];
                NSLog(@"response for request: %@ : %@\n",request.URL,json);
                [delegate request:requestName didReceiveData:json];
            }
            else{
                dispatch_sync(dispatch_get_main_queue(), ^{

                
                    NSLog(@"ERROR : %@ ",[error description]);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLoading" object:nil];
                    if(error.code==-1001) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time out" message:@"The server timed out. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        
                        [alert show];
                    }
                    else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"There was an unexpected error.Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        
                        [alert show];
                    }
                });
            }
            
            
        }];

}

- (NSString*)constructGetParametersString {
    
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    for (id key in self.getParams) {
        [parameters addObject:[NSString stringWithFormat:@"%@=%@",key,[self.getParams objectForKey:key]]];
    }
    return [parameters componentsJoinedByString:@"&"];
}

- (NSData*)postParamDataFromDictionary:(NSDictionary *)postParameters {
    
    NSMutableString *body = [NSMutableString string];
    
    for (id key in postParameters) {
        id val = [postParameters objectForKey:key];
        if([val isKindOfClass:[NSArray class]]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:val options:kNilOptions error:NULL];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if ([body length])
                [body appendString:@"&"];
            [body appendFormat:@"%@=%@",key, jsonString];
        }
        else{
            if ([body length])
                [body appendString:@"&"];
            [body appendFormat:@"%@=%@",key, val];
        }
    }
    NSLog(@"post body : %@",body);
    NSData *result = [[NSData alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    return result;
}

@end
