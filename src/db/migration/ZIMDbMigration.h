//
//  ZIMDbMigration.h
//  RPiOSMobileAPI
//
//  Created by Jeremy Fox on 9/16/13.
//  Copyright (c) 2013 RentPath. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZIMDbMigrationDelegate;

/*!
 @class					ZIMDbMigration
 @discussion			This class is an assistant used to help manage database migration.
 @updated				2013-09-16
 */
@interface ZIMDbMigration : NSObject

- (instancetype)initWithDataSource:(NSString*)dataSource andDelegate:(id<ZIMDbMigrationDelegate>)delegate;
- (void)performMigrationIfRequireForVersion:(NSInteger)newVersion;

@end


@protocol ZIMDbMigrationDelegate <NSObject>

@required
- (void)migratingDataSource:(NSString*)dataSource fromVersion:(NSInteger)oldVersion toVersion:(NSInteger)newVersion;

@end
