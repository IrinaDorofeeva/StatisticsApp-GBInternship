//
//  AppDelegate.h
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 13.03.17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *sitesArray;
@property (strong, nonatomic) NSArray *personsArray;
@property (strong, nonatomic) NSArray *statisticArray;

@end

