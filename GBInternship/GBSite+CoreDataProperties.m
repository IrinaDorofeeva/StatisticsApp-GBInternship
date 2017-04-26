//
//  GBSite+CoreDataProperties.m
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 23.03.17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBSite+CoreDataProperties.h"

@implementation GBSite (CoreDataProperties)

+ (NSFetchRequest<GBSite *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GBSite"];
}

@dynamic siteID;
@dynamic siteURL;
@dynamic statistic;

@end
