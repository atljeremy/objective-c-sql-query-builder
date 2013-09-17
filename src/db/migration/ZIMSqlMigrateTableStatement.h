/*
 * Copyright 2011-2013 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "ZIMSqlStatement.h"
#import "ZIMSqlCreateTableStatement.h"

@interface ZIMSqlMigrateTableStatement : ZIMSqlCreateTableStatement <ZIMSqlStatement>

- (void)datasource:(NSString*)datasource;

/*!
 @method				addColumn:type:
 @discussion			This method rename the given table to the specified newTable name.
 @return				The SQL statement that was constructed.
 @updated				2013-09-13
 */
- (void)renameTable:(NSString*)table toTable:(NSString*)newTable;

/*!
 @method				addColumn:type:
 @discussion			This method will create the given column as the specified type.
 @return				The SQL statement that was constructed.
 @updated				2013-09-13
 */
- (void)addColumn:(NSString*)column type:(NSString*)type;

/*!
 @method				addColumn:type:
 @discussion			This method will create the given column as the specified type with the desired defaultValue.
 @return				The SQL statement that was constructed.
 @updated				2013-09-13
 */
- (void)addColumn:(NSString*)column type:(NSString*)type defaultValue:(NSString*)defaultValue;

/*!
 @method				removeColumn:type:
 @discussion			This method will remove the given column.
 @return				The SQL statement that was constructed.
 @updated				2013-09-19
 */
//- (void)removeColumn:(NSString*)column;

/*!
 @method				renameColumn:toColumn:
 @discussion			This method will update the name of the given column to the specified newColumn name.
 @return				The SQL statement that was constructed.
 @updated				2013-09-19
 */
//- (void)renameColumn:(NSString*)column toColumn:(NSString*)newColumn;

/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2013-09-13
 */
- (NSString*)statement;

@end
