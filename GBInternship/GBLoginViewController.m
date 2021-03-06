//
//  GBLoginViewController.m
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 3/23/17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBLoginViewController.h"
#import "GBStatisticsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "GBPersistentManager.h"

@interface GBLoginViewController ()

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;
@property (weak, nonatomic) IBOutlet UIStackView *filedsOutlet;

@end

@implementation GBLoginViewController



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.usernameFld.text = nil;
    self.passwordFld.text = nil;
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usernameFld.delegate = self;
    _passwordFld.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

#pragma mark - Actions
- (IBAction)tryLoginByServer:(id)sender {
   
    NSString* login = [NSString stringWithFormat:@"%@", self.usernameFld.text];
    NSString* pass = [NSString stringWithFormat:@"%@", self.passwordFld.text];
    
    [self isCorrectLogin:login AndPassword:pass];
}

- (void) openStatisticsView {
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GBStatisticsViewController* vc = [sb instantiateViewControllerWithIdentifier:@"GBStatisticsNavigationController"];
    [self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameFld]) {
        [self.passwordFld becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self tryLoginByServer:(self)];
    }
    
    return YES;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardSize.height= 2*keyboardSize.height/3;

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
- (BOOL) isCorrectLogin:(NSString*)login AndPassword:(NSString*)password {
    
    __block BOOL isVerified = NO;
    
    if ([self connectedToInternet]) {
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://52.89.213.205:8443/rest/user/"]];
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
        self.sessionManager.securityPolicy.validatesDomainName = NO;
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:login
                                                                              password:password];
        [self.sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        
        [self.sessionManager GET:@"sites"
                      parameters:nil
                        progress:nil
         
                         success:^(NSURLSessionDataTask* task, id responseObject) {
                             isVerified = YES;
                             [[GBPersistentManager sharedManager] saveUserWithLogin:login andPassword:password];
                             [self helloAlert:login];
                         }
         
                         failure:^(NSURLSessionDataTask* task, NSError* error) {
                             NSLog(@"%@", error);
                             NSDictionary* dict = [error userInfo];
                             NSString* errorStr = [dict objectForKey:@"NSLocalizedDescription"];
                             
                             if ([errorStr isEqualToString:@"Request failed: unauthorized (401)"]){
                                 // обработка неправильного ввода логина/пароля
                                 // case of wrong login/password
                                 [self shakeFiledsStack];
                             }
                             
                         }];
    }
    
    else {
        
        if ([self isHasDBLogin:login andPassword:password]) {
            isVerified = YES;
            [self helloAlert:login];
        } else {
            isVerified = NO;
            [self alertBadLogin];
        }
    }
    return isVerified ? YES : NO;
}

- (void) shakeFiledsStack {
    
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.07];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.filedsOutlet center].x - 10.0f, [self.filedsOutlet center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.filedsOutlet center].x + 10.0f, [self.filedsOutlet center].y)]];
    [CATransaction setCompletionBlock:^{
        [self alertBadLogin];
    }];
    [[self.filedsOutlet layer] addAnimation:animation forKey:@"position"];
}

- (void) alertBadLogin {
    UIAlertController* error =
    [UIAlertController alertControllerWithTitle:@"Oooops"
                                        message:@"Your username and password does not match"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction =
    [UIAlertAction actionWithTitle:@"ОК"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction* action) {
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }];
    [error addAction:okAction];
    [self presentViewController:error animated:YES completion:nil];
}

- (void) helloAlert: (NSString*) login {
    // установка пользователю значения "текущий"
    // setting user current state
    [[GBPersistentManager sharedManager] setUserCurrentState:login];
    // получение значения "последний визит" для определения срока отсутствия пользователя
    // getting user last visit date
    NSString* lastVisit = [[GBPersistentManager sharedManager] userLastVisitDate:login];
    NSString* message;
    // вывод сообщения в алерте в зависимости от того, авторизировался ли такой пользователь уже через мобильное приложение
    if ([lastVisit isEqualToString:@"nil"]) {
        message = @"Greetings! You're using this app for the first time!";
    } else {
        message = [NSString stringWithFormat:@"Hello again, your last visit was:\n%@ ago", lastVisit ];
    }
    
    UIAlertController* hello =
    [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Hello, dear %@", login]
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:hello animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [hello dismissViewControllerAnimated:YES completion:^{
            [self openStatisticsView];
        }];
        
    });
    
}

- (BOOL) connectedToInternet {
    
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"] encoding:NSASCIIStringEncoding error:nil];
    
    ( URLString != NULL ) ? NSLog(@"connection good") : NSLog(@"connection bad");
    return ( URLString != NULL ) ? YES : NO;
}

// метод для работы с БД на случай отсутствия интернет соединения
- (BOOL) isHasDBLogin:(NSString*)login andPassword:(NSString*) password {
    
    BOOL exists = [[GBPersistentManager sharedManager] isUserExistAndCheckLogin:login andPassword:password];
    
    if (exists) {
        self.usernameFld.text = nil;
        self.passwordFld.text = nil;
        return YES;
    } else {
        
        return NO;
    }
    
    return 0;
}

@end
