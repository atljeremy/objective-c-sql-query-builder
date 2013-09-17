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

#import "ZIMSqlMigrateTableStatement.h"
#import "ZIMDbConnection.h"

@interface ZIMSqlMigrateTableStatement()
@property (nonatomic, strong) NSString* updatedTableName;
@property (nonatomic, strong) NSString* updatedColumnName;
@property (nonatomic, strong) NSString* datasource;
@property (nonatomic, assign, getter=isAddingColumn) BOOL addingColumn;
@property (nonatomic, assign, getter=isRenamingColumn) BOOL renamingColumn;
@property (nonatomic, assign, getter=isRemovingColumn) BOOL removingColumn;
@property (nonatomic, assign, getter=isRenamingTable) BOOL renamingTable;
@end

@implementation ZIMSqlMigrateTableStatement

- (id)init {
    if (self = [super init]) {
        _updatedTableName  = nil;
        _updatedColumnName = nil;
        _datasource        = nil;
        _addingColumn      = NO;
        _renamingColumn    = NO;
        _removingColumn    = NO;
        _renamingTable     = NO;
    }
    return self;
}

- (void)datasource:(NSString*)datasource {
    _datasource = datasource;
}

- (void)renameTable:(NSString*)table toTable:(NSString*)newTable {
    self.renamingTable = YES;
    self.updatedTableName = [ZIMSqlExpression prepareIdentifier:newTable];
    _table = [ZIMSqlExpression prepareIdentifier:table];
}

- (void)addColumn:(NSString*)column type:(NSString*)type {
    self.addingColumn = YES;
    [self column:column type:type];
}

- (void)addColumn:(NSString*)column type:(NSString*)type defaultValue:(NSString*)defaultvalue {
    self.addingColumn = YES;
    [self column:column type:type defaultValue:defaultvalue];
}

// FUTURE IMPLEMENTAION--------------------------------------
//
//- (void)removeColumn:(NSString*)column {
//    self.removingColumn = YES;
//    column = [ZIMSqlExpression prepareIdentifier:column];
//    if (![_columnDictionary objectForKey:column]) {
//        [_columnArray addObject:column];
//    }
//    [_columnDictionary setObject:column forKey:column];
//}
//
//- (void)renameColumn:(NSString*)column toColumn:(NSString*)newColumn {
//    self.renamingColumn = YES;
//    self.updatedColumnName = [ZIMSqlExpression prepareIdentifier:newColumn];
//    column = [ZIMSqlExpression prepareIdentifier:column];
//    if (![_columnDictionary objectForKey:column]) {
//        [_columnArray addObject:column];
//    }
//    [_columnDictionary setObject:[NSString stringWithFormat:@"%@ %@", column, type] forKey:column];
//}
//
// ----------------------------------------------------------

- (NSString*)statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	
    if (self.isRenamingTable) {
        [sql appendFormat:@"ALTER TABLE %@ RENAME TO %@;", _table, self.updatedTableName];
        return sql;
    }
    
    if (self.isRenamingColumn) {
        // If we're renaming a column...
        // 1. we must first create a copy of the table in which the column exists.
        // 2. We then create a new table based on the temp (original) table but with the renamed column
        // 3. Then we copy the contents of the temp (original) table to the new table
        // 4. Finally we delete the temp (original) table
        // Reference: http://stackoverflow.com/questions/805363/how-do-i-rename-a-column-in-a-sqlite-database-table
        
        NSString* tempTableName = [NSString stringWithFormat:@"temp_%@", _table];
        
        /* Step #1 */ [sql appendFormat:@"ALTER TABLE %@ RENAME TO %@; ", _table, tempTableName];
        
        /* Step #2 */ [sql appendFormat:@"%@; ", [self getOriginalSQLStatement]];
        
        /* Step #3 */ [sql appendFormat:@"INSERT INTO %@(col_a, col_b) SELECT col_a, colb FROM %@;", _table, tempTableName];
    
        /* Step #4 */ [sql appendFormat:@"DROP TABLE %@; ", tempTableName];
    }
    
	[sql appendString:@"ALTER"];
    
	if (_temporary) {
		[sql appendString: @" TEMPORARY"];
	}
	
	[sql appendFormat:@" TABLE %@ ", _table];
    
    if (self.isAddingColumn) {
        [sql appendString:@" ADD COLUMN "];
    }
    
	int i = 0;
	for (NSString *column in _columnArray) {
		if (i > 0) {
			[sql appendFormat: @", %@", (NSString *)[_columnDictionary objectForKey: column]];
		}
		else {
			[sql appendString: (NSString *)[_columnDictionary objectForKey: column]];
		}
		i++;
	}
    
	if (_primaryKey != nil) {
		[sql appendFormat: @", %@", _primaryKey];
	}
    
	if (_unique != nil) {
		[sql appendFormat: @", %@", _unique];
	}
    
	[sql appendString: @";"];
	
	return sql;
}

- (NSString*)getOriginalSQLStatement {
    NSString* sqlCreate = [NSString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE type='table' AND name='%@'", _table];
    NSArray* results = [ZIMDbConnection dataSource:self.datasource query:sqlCreate];
    if (results && results.count == 1) {
        sqlCreate = results.lastObject;
    }
    NSLog(@"%@", sqlCreate);
    return nil;
}

@end
