//
//  ELURLSessionManager.h
//  ELNetworkingDemo1
//
//  Created by Ocean on 8/4/16.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELURLSessionManager : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end
