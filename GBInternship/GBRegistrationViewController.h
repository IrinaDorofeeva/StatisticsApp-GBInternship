//
//  GBRegistrationViewController.h
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 3/23/17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GBRegistrationViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UITextField *usernameFld;
@property (weak, nonatomic) IBOutlet UITextField *passwordFld;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPasswordFld;

- (IBAction)registerUser:(id)sender;

@end
