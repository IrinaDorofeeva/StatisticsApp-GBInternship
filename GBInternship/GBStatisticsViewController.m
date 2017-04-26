//
//  GBStatisticsViewController.m
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 3/23/17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBStatisticsViewController.h"
#import "GBLoginViewController.h"
#import "GBPersistentManager.h"

@interface GBStatisticsViewController ()

@property (strong, nonatomic) GBUser* currentUser;

@end

@implementation GBStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUser = [[GBPersistentManager sharedManager] currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)logOutAction:(id)sender {
   
    [[GBPersistentManager sharedManager] saveUserLastDateWithLogin:self.currentUser.loginName];
    [self byeAlert];
    
}

- (void) byeAlert {
    UIAlertController* bye =
    [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Dear %@, already leaving?", self.currentUser.loginName]
                                        message:@"Hope to see you soon!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:bye animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [bye dismissViewControllerAnimated:YES completion:^{
            [[GBPersistentManager sharedManager] setAllUsersStatesToNO];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    });
}
@end
