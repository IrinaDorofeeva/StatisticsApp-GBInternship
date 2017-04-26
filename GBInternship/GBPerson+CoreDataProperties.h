//
//  GBPerson+CoreDataProperties.h
//  GBInternship
//
//  Created by Irina Dorofeeva and Stanly Shiyanovskiy on 23.03.17.
//  Copyright © 2017 Irina Dorofeeva and Stanly Shiyanovskiy. All rights reserved.
//

#import "GBPerson+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GBPerson (CoreDataProperties)

+ (NSFetchRequest<GBPerson *> *)fetchRequest;

@property (nonatomic) int16_t personID;
@property (nullable, nonatomic, copy) NSString *personName;
@property (nullable, nonatomic, retain) NSSet<GBStatistic *> *statistic;

@end

@interface GBPerson (CoreDataGeneratedAccessors)

- (void)addStatisticObject:(GBStatistic *)value;
- (void)removeStatisticObject:(GBStatistic *)value;
- (void)addStatistic:(NSSet<GBStatistic *> *)values;
- (void)removeStatistic:(NSSet<GBStatistic *> *)values;

@end

NS_ASSUME_NONNULL_END
