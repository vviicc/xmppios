//
//  LoginViewController.m
//  xmppios
//
//  Created by Vic on 13-11-29.
//  Copyright (c) 2013年 vic. All rights reserved.
//

#import "LoginViewController.h"
#import "FriendsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

UITextField *jidField;
UITextField *pwdField;
XMPPStream *stream;
FriendsViewController *friendsViewCtrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    UILabel *jidLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.view.bounds.size.height/2 - 60, 40, 30)];
    jidLabel.text = @"   jid:";
    [self.view addSubview:jidLabel];
    jidField = [[UITextField alloc]initWithFrame:CGRectMake(90, self.view.bounds.size.height/2 - 60, 200, 30)];
    jidField.placeholder = @"格式：id@domian";
    jidField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:jidField];
    UILabel *pwdLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.view.bounds.size.height/2 - 15, 40, 30)];
    pwdLabel.text = @"密码:";
    [self.view addSubview:pwdLabel];
    pwdField = [[UITextField alloc]initWithFrame:CGRectMake(90, self.view.bounds.size.height/2 - 15, 200, 30)];
    pwdField.secureTextEntry = YES;
    pwdField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:pwdField];
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, self.view.bounds.size.height/2 + 30, 60, 40)];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登 陆" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login{
    NSString *jidString = [jidField text];
    NSString *pwdString = [pwdField text];
    stream = [[XMPPStream alloc]init];
    [stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [stream setMyJID:[XMPPJID jidWithString:jidString]];
    [stream setHostName:@"pengweitekimacbook-air.local"];
    NSError *error = nil;
    if (![stream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"fail to connect,error:%@",[error localizedFailureReason]);
    }
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"didconnect");
    NSError *error = nil;
    NSString *pwdString =[pwdField text];
    if (![stream authenticateWithPassword:pwdString error:&error]) {
        NSLog(@"fail to authenticate,error:%@",[error localizedFailureReason]);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    NSLog(@"didAuthenticate");
    XMPPPresence *presence = [XMPPPresence presence];
    [stream sendElement:presence];
    [self.navigationController pushViewController:[FriendsViewController initonce] animated:YES];
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *presentType = [presence type];
    NSString *presentUser = [[presence from] user];
    NSString *senderUser = [[sender myJID]user];
    NSString *presentFrom = [[presence from]full];
    NSString *presentTo = [[presence to]full];
    if (![senderUser isEqualToString:presentUser]) {
        if (![presentType isEqualToString:@"unavailable"] ) {
            NSDictionary *friendDict = [NSDictionary dictionaryWithObjectsAndKeys:presentUser,@"user",presentFrom,@"from",presentTo,@"to", nil];
            [[FriendsViewController myArray] addObject:friendDict];
            [[FriendsViewController initonce].tableView reloadData];
        }
        else{
            NSLog(@"else in");
            NSMutableArray *removeArray = [NSMutableArray array];
            for (NSDictionary *friend in [FriendsViewController myArray]) {
                NSLog(@"for in");
                if ([[friend objectForKey:@"user"] isEqualToString:presentUser]) {
                    NSLog(@"in in");
                    [removeArray addObject:friend];
                    //[[FriendsViewController myArray] removeObject:friend];
                }
            }
            [[FriendsViewController myArray] removeObjectsInArray:removeArray];
            [[FriendsViewController initonce].tableView reloadData];
        }
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
