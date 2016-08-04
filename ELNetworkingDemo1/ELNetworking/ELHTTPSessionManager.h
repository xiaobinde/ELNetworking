//
//  ELHTTPSessionManager.h
//  ELNetworkingDemo1
//
//  Created by Ocean on 8/4/16.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "ELURLSessionManager.h"

@interface ELHTTPSessionManager : ELURLSessionManager

- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end
