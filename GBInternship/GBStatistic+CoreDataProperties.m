//
//  GBStatistic+CoreDataProperties.m
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 23.03.17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBStatistic+CoreDataProperties.h"

@implementation GBStatistic (CoreDataProperties)

+ (NSFetchRequest<GBStatistic *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GBStatistic"];
}

@dynamic date;
@dynamic rank;
@dynamic startDate;
@dynamic persons;
@dynamic sites;

- (void)bindServerModel:(id)model {
    
    //self.sites = model.site;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqual:@"mean"]) {
        key = @"average";
    }
    
    [super setValue:value forKey:key];
}
@end
