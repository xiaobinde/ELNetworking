//
//  ViewController.m
//  ELNetworkingDemo1
//
//  Created by Ocean on 8/4/16.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "ViewController.h"
#import "ELNetworking/ELNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)postSend{
    ELHTTPSessionManager *manger = [[ELHTTPSessionManager alloc] init];
//    [manger POST:@"https://api.app.net/stream/0/posts/stream/global" parameters:nil success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
//        NSLog(@"%@",error);
//    }];
        [manger GET:@"https://api.app.net/stream/0/posts/stream/global" parameters:nil success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            NSLog(@"%@",responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
            NSLog(@"%@",error);
        }];
}

- (IBAction)buttonClick:(id)sender {
    [self postSend];
}

@end
