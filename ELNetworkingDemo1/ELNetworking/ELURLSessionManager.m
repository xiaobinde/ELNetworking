//
//  ELURLSessionManager.m
//  ELNetworkingDemo1
//
//  Created by Ocean on 8/4/16.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "ELURLSessionManager.h"

typedef void(^ELURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

@interface ELURLSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property(nonatomic,strong) ELURLSessionTaskCompletionHandler completionHandler;

@property(nonatomic,strong)NSMutableData *mutableData;
@end



@implementation ELURLSessionManagerTaskDelegate

-(instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.mutableData = [[NSMutableData alloc] init];
    return self;
}

#pragma mark - NSURLSessionTaskDelegate 数据完全接受完成调用
- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    
    __block id responseObject = nil;
    
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        self.mutableData = nil;
    }
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response,responseObject,error);
            }
        });
    }else{
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response,responseObject,error);
            }
        });
    }
}

#pragma mark - NSURLSessionDataTaskDelegate
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.mutableData appendData:data];
}

@end


@interface ELURLSessionManager ()

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) NSURLSession *session;

@property (readwrite, nonatomic, strong) NSLock *lock;

@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
@end

@implementation ELURLSessionManager

- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    self.sessionConfiguration = configuration;
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
     self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
    
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDataTask *task in dataTasks) {
            [self addDelegateForDataTask:task completionHandler:nil];
        }
    }];

    

    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
   NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    
    [self addDelegateForDataTask:dataTask completionHandler:completionHandler];
    
    return dataTask;
}

-(void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    ELURLSessionManagerTaskDelegate *delegate = [[ELURLSessionManagerTaskDelegate alloc] init];
    delegate.completionHandler = completionHandler;
    [self setDelegate:delegate forTask:dataTask];
}

- (void)setDelegate:(ELURLSessionManagerTaskDelegate *)delegate
            forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    
    [self.lock lock];
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    [self.lock unlock];
}

- (ELURLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    ELURLSessionManagerTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return delegate;
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    ELURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    [delegate URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSURLRequest *redirectRequest = request;
    
    if (completionHandler) {
        completionHandler(redirectRequest);
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    ELURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];
}



@end
