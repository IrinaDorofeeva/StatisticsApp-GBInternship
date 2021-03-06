//
//  GBRegistrationViewController.m
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 3/23/17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBRegistrationViewController.h"
#import "GBLoginViewController.h"
#import "GBStatisticsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "GBPersistentManager.h"

@interface GBRegistrationViewController ()  <UITextFieldDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;
@property (weak, nonatomic) IBOutlet UIStackView *textFieldsStackOutlet;

@end

@implementation GBRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usernameFld.delegate = self;
    _passwordFld.delegate = self;
    _reEnterPasswordFld.delegate =self;
}

//Register user
- (IBAction)registerUser:(id)sender {
    
    //Check for full fields and show alert
    if ([self.usernameFld.text isEqualToString:@""] || [self.passwordFld.text isEqualToString:@""]) {
        
        // empty fields alert
        [self emptyFieldsAlert];
        
    } else {
        
        //Check password and re-Enter password fields
        [self checkPasswordsMatch];
    }
}


- (void) checkPasswordsMatch {
    
    if ([self.passwordFld.text isEqualToString:self.reEnterPasswordFld.text]) {
        NSLog(@"passwords match!");
        [self registerNewUser:self.usernameFld.text andPassword:self.passwordFld.text];
        
    } else {
        //doesn't match passwords
        [self doesntMatchPasswordsAlert];
    }
}


- (void) registerNewUser:(NSString*)login andPassword:(NSString*)password {
    NSString* url = @"https://52.89.213.205:8443/rest/user/signup";
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
    self.sessionManager.securityPolicy.validatesDomainName = NO;
    [self.sessionManager.requestSerializer
     setAuthorizationHeaderFieldWithUsername:@"user@gmail.com"
     password:@"user"];
    [self.sessionManager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *postDictAFN = [[NSMutableDictionary alloc] init];
    [postDictAFN setValue:login forKey:@"userName"];
    [postDictAFN setValue:password forKey:@"password"];
    
    [self.sessionManager POST:url
                   parameters:postDictAFN
                     progress:nil
                      success:^(NSURLSessionDataTask* task, id responseObject) {
                          
                          //successfully registered user alert
                          [self successfullyRegisteredAlert];
                          [[GBPersistentManager sharedManager] saveUserWithLogin:login andPassword:password];
                      } failure:^(NSURLSessionDataTask* task, NSError* error) {
                          NSError* dict1 = [[error userInfo] objectForKey:@"NSUnderlyingError"];
                          NSString* errorStr = [[dict1 userInfo] objectForKey:@"NSLocalizedDescription"];
                          NSLog(@"errorStr: %@", errorStr);
                          if ([errorStr isEqualToString:@"Request failed: conflict (409)"]){
                              
                              SEL selector = @selector(userAlreadyExistsAlert);
                              [self shakeFiledsStackWithErrorMethod:selector];
                          } else if ([errorStr isEqualToString:@"Request failed: bad request (400)"]) {
                              SEL selector = @selector(loginFieldRequirements);
                              [self shakeFiledsStackWithErrorMethod:selector];
                              
                          }
                      }];
    
}

- (void) openStatisticsView {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GBStatisticsViewController* vc = [sb instantiateViewControllerWithIdentifier:@"GBStatisticsNavigationController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) openLoginView {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GBLoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"GBLoginViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameFld]) {
        [self.passwordFld becomeFirstResponder];
    } else if ([textField isEqual:self.passwordFld]) {
        [self.reEnterPasswordFld becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self registerNewUser:self.usernameFld.text andPassword:self.passwordFld.text];
    }
    
    return YES;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

#pragma mark - Help methods -
- (void) emptyFieldsAlert {
    
    UIAlertController* error =
    [UIAlertController alertControllerWithTitle:@"Oooops"
                                        message:@"You must complete all fields"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"ОК"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [error addAction:okAction];
    [self presentViewController:error animated:YES completion:nil];
}

- (void) loginFieldRequirements {
    
    UIAlertController* error =
    [UIAlertController alertControllerWithTitle:@"Wrong registration fields!"
                                        message:@"Your login must meet these requirements: must be at least 3 characters, include @ symbol and domain postfix.\nPassword must be at least 4 characters.\nFor example: ben@jail.com"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"ОК"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [error addAction:okAction];
    [self presentViewController:error animated:YES completion:nil];
}

- (void) doesntMatchPasswordsAlert {
    NSLog(@"passwords don't match");
    UIAlertController* error =
    [UIAlertController alertControllerWithTitle:@"Oooops"
                                        message:@"Your entered passwords do not match"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"ОК"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [error addAction:okAction];
    [self presentViewController:error animated:YES completion:nil];
}

- (void) successfullyRegisteredAlert {
    
    UIAlertController* success =
    [UIAlertController alertControllerWithTitle:@"Success"
                                        message:@"You are registered as a new user.\nUse your login & password to authorize in app."
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction =
    [UIAlertAction actionWithTitle:@"ОК"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction* action) {
                               [[GBPersistentManager sharedManager] saveUserWithLogin:self.usernameFld.text andPassword:self.passwordFld.text];
                               [self openLoginView];
                           }];
    [success addAction:okAction];
    [self presentViewController:success animated:YES completion:nil];
}

- (void) userAlreadyExistsAlert {
    
    UIAlertController* exists =
    [UIAlertController alertControllerWithTitle:@"User exists"
                                        message:@"You have entered login that already in use! Please register with other login."
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction =
    [UIAlertAction actionWithTitle:@"ОК"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction* action) {
                               
                           }];
    UIAlertAction* tryLogin =
    [UIAlertAction actionWithTitle:@"Try to login"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction* action) {
                               [self openLoginView];
                           }];
    [exists addAction:okAction];
    [exists addAction:tryLogin];
    [self presentViewController:exists animated:YES completion:nil];
}

- (void) shakeFiledsStackWithErrorMethod:(SEL)method {
    
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.07];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.textFieldsStackOutlet center].x - 10.0f, [self.textFieldsStackOutlet center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.textFieldsStackOutlet center].x + 10.0f, [self.textFieldsStackOutlet center].y)]];
    [CATransaction setCompletionBlock:^{
        [self performSelector:method withObject:nil afterDelay:0];
    }];
    [[self.textFieldsStackOutlet layer] addAnimation:animation forKey:@"position"];
}


@end
