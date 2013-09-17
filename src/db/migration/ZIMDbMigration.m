//
//  ZIMDbMigration.m
//  RPiOSMobileAPI
//
//  Created by Jeremy Fox on 9/16/13.
//  Copyright (c) 2013 RentPath. All rights reserved.
//

#import "ZIMDbMigration.h"
#import "ZIMDbConnection.h"
#import "ZIMSqlPreparedStatement.h"

static NSString* const USER_VERSION_KEY = @"user_version";

@interface ZIMDbMigration()
@property (nonatomic, weak) id<ZIMDbMigrationDelegate> delegate;
@property (nonatomic, strong) NSString* dataSource;
@end

@implementation ZIMDbMigration

- (id)init {
    @throw [NSException exceptionWithName:@"ZIMDbMigration Exception" reason:@"Invalid initialization. Must use initWithDataSource:andDelegate:." userInfo:nil];
}

- (instancetype)initWithDataSource:(NSString*)dataSource andDelegate:(id<ZIMDbMigrationDelegate>)delegate {
    if (self = [super init]) {
        _dataSource = dataSource;
        _delegate = delegate;
    }
    return self;
}

- (void)performMigrationIfRequireForVersion:(NSInteger)newVersion {
    if (newVersion != NSNotFound) {
        
        NSInteger currentVersion = [self currentDataSourceUserVersion];
        if ((currentVersion < newVersion) &&
            self.delegate &&
            [self.delegate respondsToSelector:@selector(migratingDataSource:fromVersion:toVersion:)]) {
            
            [self.delegate migratingDataSource:self.dataSource fromVersion:currentVersion toVersion:newVersion];
            [self updateDataSourceUserVersionToVersion:newVersion];
            
        }
    }
}

- (void)updateDataSourceUserVersionToVersion:(NSInteger)version {
    NSString* sql = [NSString stringWithFormat:@"PRAGMA user_version = %d;", version];
    ZIMSqlPreparedStatement* statement = [[ZIMSqlPreparedStatement alloc] initWithSqlStatement:sql];
    ZIMDbConnection* connection = [[ZIMDbConnection alloc] initWithDataSource:self.dataSource];
    NSNumber* updated = [connection execute:[statement statement]];
    if (![updated boolValue]) {
        @throw [NSException exceptionWithName:@"ZIMDbMigration Exception" reason:@"An error occurred while updating the user_version." userInfo:nil];
    }
}

- (NSInteger)currentDataSourceUserVersion {
    ZIMSqlPreparedStatement* statement = [[ZIMSqlPreparedStatement alloc] initWithSqlStatement:@"PRAGMA user_version;"];
    ZIMDbConnection* connection = [[ZIMDbConnection alloc] initWithDataSource:self.dataSource];
    NSArray* userVersion = [connection query:[statement statement]];
    NSNumber* version = nil;
    if (userVersion && userVersion.count > 0) {
        version = [[userVersion lastObject] objectForKey:USER_VERSION_KEY];
        NSLog(@"User Version = %d", [version integerValue]);
    }
    return (version) ? [version integerValue] : NSNotFound;
}

@end
