//
//  FriendsViewController.h
//  xmppios
//
//  Created by Vic on 13-12-2.
//  Copyright (c) 2013年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewController : UITableViewController
+(NSMutableArray *) myArray;
+(FriendsViewController *)initonce;

@end
