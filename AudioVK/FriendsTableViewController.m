//
//  FriendsTableViewController.m
//  AudioVK
//
//  Created by Yurii Huber on 15.11.15.
//  Copyright © 2015 Yurii Huber. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MusicViewController.h"
#import <VKSdk/VKSdk.h>

@interface FriendsTableViewController () <VKSdkDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* friendsArray;
@property (assign, nonatomic) NSInteger countFriends;

@end

@implementation FriendsTableViewController

static NSString* ovnerId;
static bool isRenewed;
static const NSInteger countUpdateFriends = 25;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendsArray = [[NSMutableArray alloc] init];
    
    [VKSdk initializeWithDelegate:self andAppId:@"5112182"];
    
    if (![VKSdk wakeUpSession]) {
        
        NSArray *scope = @[@"friends,audio"];
        [VKSdk authorize:scope];
    }
    
    [self getFriendsFromServer:0];
    
    //    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
    //                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    //
    //    self.navigationItem.leftBarButtonItem = revealButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VKSdkDelegate

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    
}

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    
}

/**
 Notifies delegate about user authorization cancelation
 @param authorizationError error that describes authorization error
 */
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    
    NSArray *scope = @[@"friends,audio"];
    [VKSdk authorize:scope];
}

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    
    [self presentViewController:controller
                       animated:YES
                     completion:^{}];
}

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.friendsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"My music";
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
    }
    else {
        
        cell.textLabel.text = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"first_name"];
        cell.detailTextLabel.text = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"last_name"];
        
        NSString *strUrl = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"photo_50"];
        NSURL *url = [NSURL URLWithString:strUrl];
        
        NSURLRequest* request = [NSURLRequest requestWithURL: url];
        
        __weak UITableViewCell* weakCell = cell;
        
        cell.imageView.image = nil;
        
        [cell.imageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             weakCell.imageView.image = image;
             [weakCell layoutSubviews];
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ovnerId = nil;
    } else {
        ovnerId = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"id"];
    }
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"musicViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 250.0 && [self.friendsArray count] < self.countFriends && !isRenewed) {
        
        [self getFriendsFromServer:[self.friendsArray count]];
        isRenewed = YES;
    }
}

#pragma mark - MyMetod

- (void) getFriendsFromServer:(NSInteger)offset {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"name",                 @"order",
     @(countUpdateFriends),   @"count",
     @(offset),               @"offset",
     @"photo_50",             @"fields", nil];
    
    VKRequest * audioReq = [[VKApi friends] get:params];
    
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        //VKAudios *audios = [[VKAudios alloc] initWithDictionary:response.json objectClass:VKAudio.class];
        //self.musicArray = audios.items;
        //[self.tableView reloadData];
        
        [self.tableView beginUpdates];
        
        [self.friendsArray addObjectsFromArray:[response.json objectForKey:@"items"]];
        self.countFriends = [[response.json objectForKey:@"count"] integerValue];
        isRenewed = NO;
        
        NSMutableArray* newPaths = [NSMutableArray new];
        for (NSInteger i = offset; i < [self.friendsArray count]; i++) {
            [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

+ (NSString*) getOvnerId {
    
    return ovnerId;
}

@end
