//
//  sqlService.h
//  ACS
//
//  Created by 陈 星 on 13-5-2.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "productEntity.h"
#import "productdia.h"
#import "buyproduct.h"
#import "productphotos.h"
#import "customer.h"

@interface sqlService : NSObject
{
    sqlite3 *_database;
}

@property (nonatomic) sqlite3 *_database;

-(BOOL) initializeDb;
-(BOOL) openDB;
-(BOOL) HandleSql:(NSString*)sql;
-(BOOL) execSql:(NSString*)sql;


//查询商品列表
-(NSMutableArray*)GetProductList:(NSString *)type1 type2:(NSString *)type2 type3:(NSString *)type3 type4:(NSString *)type4 page:(int)page pageSize:(int)pageSize;

//查询商品明细
-(productEntity*)GetProductDetail:(NSString *)pid;

//新加商品
-(productEntity*)saveProduct:(productEntity *)entity;

//查询裸钻列表
-(NSMutableArray*)GetProductdiaList:(NSString *)type1 type2:(NSString *)type2 type3:(NSString *)type3 type4:(NSString *)type4 type5:(NSString *)type5 type6:(NSString *)type6 type7:(NSString *)type7 type8:(NSString *)type8 type9:(NSString *)type9 type10:(NSString *)type10 type11:(NSString *)type11 page:(int)page pageSize:(int)pageSize;

//查询裸钻明细
-(productdia*)GetProductdiaDetail:(NSString *)pid;

//查询用户的购物车信息
-(NSMutableArray*)GetBuyproductList:(NSString *)customerid;

//新加到购物车信息
-(buyproduct*)addToBuyproduct:(buyproduct *)entity;

//查询商品的3d图片
-(NSMutableArray*)getProductRAR:(NSString *)pid;

//查询当前用户的基本信息
-(customer*)getCustomer:(NSString *)uid;

//根据编号查询上次更新数据的时间
-(NSString*)getUpdateTime:(NSString *)code;

@end
