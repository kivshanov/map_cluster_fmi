//
//  BZBRequest.h
//  BuzzBank
//
//  Created by Nikolay Kivshanov on 3/29/13.
//  Copyright (c) 2013 Nikolay Kivshanov. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FMI_Request
{
    COFFES = 0,
    PARKS ,
    RESTAURANTS
} ;
@protocol BZBRequestDataDelegate;

@interface FMIRequest : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSDictionary *getParams;
@property (nonatomic, strong) NSDictionary *postParams;
@property (nonatomic, assign) enum FMI_Request requestName;
@property (nonatomic, strong) id <BZBRequestDataDelegate> delegate;

- (void)send;
+ (NSString *)cuurentSurver;
+ (NSString *)serverBase;
@end

@protocol BZBRequestDataDelegate <NSObject>

@optional

- (void)request:(enum FMI_Request)name didReceiveData:(id)response;

@end

