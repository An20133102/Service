//
//  ViewController.m
//  Service
//
//  Created by 小龙 on 2019/1/2.
//  Copyright © 2019年 L. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController ()<GCDAsyncUdpSocketDelegate>{
    UILabel *lb;
    GCDAsyncUdpSocket * socket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"服务器端";
    self.view.backgroundColor=[UIColor whiteColor];
    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0, 200, KUIScreenWidth, 40)];
    [self.view addSubview:btn];
    btn.tag=50;
    btn.backgroundColor=[UIColor grayColor];
    [btn setTitle:@"服务器端send" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    
    lb=[[UILabel alloc] initWithFrame:CGRectMake(0, 250, KUIScreenWidth, 40)];
    lb.backgroundColor=[UIColor grayColor];
    lb.textColor=[UIColor whiteColor];
    lb.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:lb];
    
    //初始化
    socket=[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError * error;
    //绑定端口
    [socket bindToPort:KSOCKET_Port error:&error];
    //开启广播
    [socket enableBroadcast:YES error:&error];
    //开启接收数据
    [socket beginReceiving:&error];
    
}
-(void)btnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 50:
        {
            NSString *str=[NSString stringWithFormat:@"%u",arc4random()%10000];
            [btn setTitle:[NSString stringWithFormat:@"服务器端send:%@",str] forState:UIControlStateNormal];
            [socket sendData:[str dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:KSOCKET_Port withTimeout:-1 tag:0];
        }
            break;
        case 100:
        {
          
        }
            break;
            
        default:
            break;
    }
    
    
}


//发送失败回调方法
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送失败");
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"连接失败");
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送成功");
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"收到消息");
    NSString *sendMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSLog(@"接收到%@的消息,\n解析到的数据[%@:%d]",sendMessage,ip,port);
    __weak  typeof(self) weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf=weakSelf;
        strongSelf->lb.text=[NSString stringWithFormat:@"服务端收到：%@",sendMessage];
    });
    
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
    NSLog(@"%s",__FUNCTION__);
}

@end
