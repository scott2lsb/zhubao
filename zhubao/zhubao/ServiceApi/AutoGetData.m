//
//  AutoGetData.m
//  zhubao
//
//  Created by moko on 14-6-4.
//  Copyright (c) 2014年 SUNYEARS___FULLUSERNAME. All rights reserved.
//

#import "AutoGetData.h"

@implementation AutoGetData


//同步数据到数据库里面
-(NSString *)getDataInsertTable
{
    getNowTime * time=[[getNowTime alloc] init];
    NSString * nowt=[time nowTime];
    
    [self getProduct:nowt];//同步商品数据
    [self getProductdia:nowt];//裸钻数据获取
    [self getproductphotos:nowt];//3D旋转ZIP套图数据获取
    [self getwithmouth:nowt];//镶口数据获取

    return @"";
}


//商品数据获取
-(BOOL *)getProduct:(NSString *)Nowt
{
    @try {
        //NSString * adminss=[Commons md5:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"0",@"100",@"0",apikey,@"1402023598",@"0"]];
        
    sqlService *sqlser= [[sqlService alloc]init];
    
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString * timecode=@"producttime";
    
    NSString * uId=myDelegate.entityl.uId;
    NSString * Upt=[sqlser getUpdateTime:timecode];//获取上一次的更新时间
    
    //Kstr=md5(uId|type|Upt|Key|Nowt|cid)
    NSString * Kstr=[Commons md5:[NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@",uId,@"100",Upt,apikey,Nowt,@"0"]];
    
    NSString * surl = [NSString stringWithFormat:@"/app/appinterface.php?uId=%@&type=100&Upt=%@&Nowt=%@&Kstr=%@&cid=0",uId,Upt,Nowt,Kstr];
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",domainser,surl];
    
    NSMutableDictionary * dict = [DataService GetDataService:URL];
  //{"status":"true","uptime":1401886947,"result":[["36530","S000001W","C20454992","18K\u94bb\u77f3\u5973\u6212","0","1","1","/files/3DNewa/1/3C0158E/3C0158E_thumb_1.jpg","/files/3DNewa/1/3C0158E/3C0158E.jpg","0","","0","0","3C0158E","0","2014 \u4e00\u6708 23 17:56","2","0.0","0","0","0","60","0.0","0.0","0","0","0","0","0","0","0","1","","1","0.385","I-J","","SI",""," ","0.0","0","","0","0.0",""," ",""," ","","0.0",""," ",""," ",""," ","0","0",""," ","2","0.0","0.0","{14}","0.0","60.0000","0",null,"0.22","1.92","2.52"]]}
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        error = nil;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonObject != nil && error == nil){
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *d = (NSDictionary *)jsonObject;
                NSString * status=[d objectForKey:@"status"];
                if ([status isEqualToString:@"false"]) {
                    return FALSE;
                }
                NSArray * objArray=[d objectForKey:@"result"];
                for(int i = 0 ; i < objArray.count ; i++){
                    
                    NSArray * valuearray = objArray[i];
                    //NSString *values = [objArray[i] componentsJoinedByString:@","];
                    NSMutableString *values=[[NSMutableString alloc] init];
                    for (int j = 0 ; j < valuearray.count ; j++) {
                        if(j>0)[values appendString:[NSString stringWithFormat:@","]];
                        [values appendString:[NSString stringWithFormat:@"'%@'",valuearray[j]]];
                    }
                    
                    NSString *tablekey=@"Id,Pro_model,Pro_number,Pro_name,Pro_State,Pro_Class,Pro_Type,Pro_smallpic,Pro_bigpic,Pro_typeWenProId,Pro_info,Pro_lock,Pro_IsDel,Pro_author,Pro_Order,Pro_addtime,Pro_goldType,Pro_goldWeight,Pro_goldsize,Pro_goldset,Pro_FingerSize,Pro_gongfei,Pro_MarketPrice,Pro_price,Pro_OKdays,Pro_Salenums,Pro_hotA,Pro_hotB,Pro_hotC,Pro_hotD,Pro_hotE,Pro_Z_count,Pro_Z_GIA,Pro_Z_number,Pro_Z_weight,Pro_Z_color,Pro_Z_cut,Pro_Z_clarity,Pro_Z_polish,Pro_Z_pair,Pro_Z_price,Pro_f_count,Pro_F_GIA,Pro_f_number,Pro_f_weight,Pro_f_color,Pro_f_cut,Pro_f_clarity,Pro_f_polish,Pro_f_pair,Pro_f_price,Pro_D_Hand,Pro_D_Width,Pro_D_Dia,Pro_D_Bangle,Pro_D_Ear,Pro_D_Height,Pro_SmallClass,IsCaijin,Di_DiaShape,Pro_GroupSerial,Pro_FactoryNumber,Pro_domondB,Pro_domondE,Pro_ChiCun,Pro_goldWeightB,Pro_gongfeiB,Pro_zhuanti,location,zWeight,AuWeight,ptWeight";
                    
                    NSString * sql=[NSString stringWithFormat:@"insert into product(%@)values(%@)",tablekey,(NSString *)values];
                    
                    NSLog(@"--------------:%@",sql);
                    
                    [sqlser HandleSql:sql];

                }
                //先删除之前的更新时间
                [sqlser HandleSql:[NSString stringWithFormat:@"delete from updatetime where updateCode='%@'",timecode]];
                
                NSString * uptime=[d objectForKey:@"uptime"];
                //更新时间表记录
                NSString * sql1=[NSString stringWithFormat:@"insert into updatetime(updateCode,updatetime)values('%@','%@')",timecode,uptime];
                
                NSLog(@"--------------:%@",sql1);
                
                [sqlser HandleSql:sql1];
                
            }else if ([jsonObject isKindOfClass:[NSArray class]]){
//                NSArray * objArray = (NSArray *)jsonObject;
//                
//                for(int i = 0 ; i < objArray.count ; i++)
//                {
//                    
//                }
                
            }
            else {
                NSLog(@"无法解析的数据结构.");
            }
            
            return TRUE;
        }
        else if (error != nil){
            NSLog(@"%@",error);
        }
    }
    else if ([jsonData length] == 0 &&error == nil){
        NSLog(@"空的数据集.");
    }
    else if (error != nil){
        NSLog(@"发生致命错误：%@", error);
    }
    
    }@catch (NSException *exception) {
            
    }
    @finally {
            
    }
    return FALSE;
}

//裸钻数据获取
-(BOOL *)getProductdia:(NSString *)Nowt
{
    @try {
    
    sqlService *sqlser= [[sqlService alloc]init];
    
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString * timecode=@"productdiatime";
    
    NSString * uId=myDelegate.entityl.uId;
    NSString * Upt=[sqlser getUpdateTime:timecode];//获取上一次的更新时间
    
    //Kstr=md5(uId|type|Upt|Key|Nowt)
    NSString * Kstr=[Commons md5:[NSString stringWithFormat:@"%@|%@|%@|%@|%@",uId,@"101",Upt,apikey,Nowt]];
    
    NSString * surl = [NSString stringWithFormat:@"/app/appinterface.php?uId=%@&type=101&Upt=%@&Nowt=%@&Kstr=%@",uId,Upt,Nowt,Kstr];
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",domainser,surl];
    
    NSMutableDictionary * dict = [DataService GetDataService:URL];
    //{"status":"true","uptime":1401886947,"result":[["36530","S000001W","C20454992","18K\u94bb\u77f3\u5973\u6212","0","1","1","/files/3DNewa/1/3C0158E/3C0158E_thumb_1.jpg","/files/3DNewa/1/3C0158E/3C0158E.jpg","0","","0","0","3C0158E","0","2014 \u4e00\u6708 23 17:56","2","0.0","0","0","0","60","0.0","0.0","0","0","0","0","0","0","0","1","","1","0.385","I-J","","SI",""," ","0.0","0","","0","0.0",""," ",""," ","","0.0",""," ",""," ",""," ","0","0",""," ","2","0.0","0.0","{14}","0.0","60.0000","0",null,"0.22","1.92","2.52"]]}
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        error = nil;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonObject != nil && error == nil){
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *d = (NSDictionary *)jsonObject;
                NSString * status=[d objectForKey:@"status"];
                if ([status isEqualToString:@"false"]) {
                    return FALSE;
                }
                NSArray * objArray=[d objectForKey:@"result"];
                for(int i = 0 ; i < objArray.count ; i++){
                    
                    NSArray * valuearray = objArray[i];
                    //NSString *values = [objArray[i] componentsJoinedByString:@","];
                    NSMutableString *values=[[NSMutableString alloc] init];
                    for (int j = 0 ; j < valuearray.count ; j++) {
                        if(j>0)[values appendString:[NSString stringWithFormat:@","]];
                        [values appendString:[NSString stringWithFormat:@"'%@'",valuearray[j]]];
                    }
                    
                    NSString *tablekey=@"Id,Dia_Lab,Dia_CertNo,Dia_Carat,Dia_Clar,Dia_Col,Dia_Cut,Dia_Pol,Dia_Sym,Dia_Shape,Dia_Dep,Dia_Tab,Dia_Meas,Dia_Flor,Dia_Price,Dia_Cost,Dia_ART,Dia_Corp,Dia_Theonly,Dia_Out,Dia_Tj,Dia_Addtime,Dia_XH,ColStep,ColCream,BackFlaw,TabFlaw,location,colordesc";
                    
                    NSString * sql=[NSString stringWithFormat:@"insert into productdia(%@)values(%@)",tablekey,(NSString *)values];
                    
                    NSLog(@"--------------:%@",sql);
                    
                    [sqlser HandleSql:sql];
                    
                }
                //先删除之前的更新时间
                [sqlser HandleSql:[NSString stringWithFormat:@"delete from updatetime where updateCode='%@'",timecode]];
                
                NSString * uptime=[d objectForKey:@"uptime"];
                //更新时间表记录
                NSString * sql1=[NSString stringWithFormat:@"insert into updatetime(updateCode,updatetime)values('%@','%@')",timecode,uptime];
                
                NSLog(@"--------------:%@",sql1);
                
                [sqlser HandleSql:sql1];
                
            }else if ([jsonObject isKindOfClass:[NSArray class]]){
                //                NSArray * objArray = (NSArray *)jsonObject;
                //
                //                for(int i = 0 ; i < objArray.count ; i++)
                //                {
                //
                //                }
                
            }
            else {
                NSLog(@"无法解析的数据结构.");
            }
            
            return TRUE;
        }
        else if (error != nil){
            NSLog(@"%@",error);
        }
    }
    else if ([jsonData length] == 0 &&error == nil){
        NSLog(@"空的数据集.");
    }
    else if (error != nil){
        NSLog(@"发生致命错误：%@", error);
    }
        
    }@catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return FALSE;
}

//3D旋转ZIP套图数据获取
-(BOOL *)getproductphotos:(NSString *)Nowt
{
    @try {
    sqlService *sqlser= [[sqlService alloc]init];
    
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString * timecode=@"productphotos";
    
    NSString * uId=myDelegate.entityl.uId;
    NSString * Upt=[sqlser getUpdateTime:timecode];//获取上一次的更新时间
    
    //Kstr=md5(uId|type|Upt|Key|Nowt)
    NSString * Kstr=[Commons md5:[NSString stringWithFormat:@"%@|%@|%@|%@|%@",uId,@"103",Upt,apikey,Nowt]];
    
    NSString * surl = [NSString stringWithFormat:@"/app/appinterface.php?uId=%@&type=103&Upt=%@&Nowt=%@&Kstr=%@",uId,Upt,Nowt,Kstr];
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",domainser,surl];
    
    NSMutableDictionary * dict = [DataService GetDataService:URL];
    //{"status":"true","uptime":1401886947,"result":[["36530","S000001W","C20454992","18K\u94bb\u77f3\u5973\u6212","0","1","1","/files/3DNewa/1/3C0158E/3C0158E_thumb_1.jpg","/files/3DNewa/1/3C0158E/3C0158E.jpg","0","","0","0","3C0158E","0","2014 \u4e00\u6708 23 17:56","2","0.0","0","0","0","60","0.0","0.0","0","0","0","0","0","0","0","1","","1","0.385","I-J","","SI",""," ","0.0","0","","0","0.0",""," ",""," ","","0.0",""," ",""," ",""," ","0","0",""," ","2","0.0","0.0","{14}","0.0","60.0000","0",null,"0.22","1.92","2.52"]]}
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        error = nil;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonObject != nil && error == nil){
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *d = (NSDictionary *)jsonObject;
                NSString * status=[d objectForKey:@"status"];
                if ([status isEqualToString:@"false"]) {
                    return FALSE;
                }
                NSArray * objArray=[d objectForKey:@"result"];
                for(int i = 0 ; i < objArray.count ; i++){
                    
                    NSArray * valuearray = objArray[i];
                    //NSString *values = [objArray[i] componentsJoinedByString:@","];
                    NSMutableString *values=[[NSMutableString alloc] init];
                    for (int j = 0 ; j < valuearray.count ; j++) {
                        if(j>0)[values appendString:[NSString stringWithFormat:@","]];
                        [values appendString:[NSString stringWithFormat:@"'%@'",valuearray[j]]];
                    }
                    
                    NSString *tablekey=@"Id,zipUrl";
                    
                    NSString * sql=[NSString stringWithFormat:@"insert into productphotos(%@)values(%@)",tablekey,(NSString *)values];
                    
                    NSLog(@"--------------:%@",sql);
                    
                    [sqlser HandleSql:sql];
                    
                }
                //先删除之前的更新时间
                [sqlser HandleSql:[NSString stringWithFormat:@"delete from updatetime where updateCode='%@'",timecode]];
                
                NSString * uptime=[d objectForKey:@"uptime"];
                //更新时间表记录
                NSString * sql1=[NSString stringWithFormat:@"insert into updatetime(updateCode,updatetime)values('%@','%@')",timecode,uptime];
                
                NSLog(@"--------------:%@",sql1);
                
                [sqlser HandleSql:sql1];
                
            }else if ([jsonObject isKindOfClass:[NSArray class]]){
                //                NSArray * objArray = (NSArray *)jsonObject;
                //
                //                for(int i = 0 ; i < objArray.count ; i++)
                //                {
                //
                //                }
                
            }
            else {
                NSLog(@"无法解析的数据结构.");
            }
            
            return TRUE;
        }
        else if (error != nil){
            NSLog(@"%@",error);
        }
    }
    else if ([jsonData length] == 0 &&error == nil){
        NSLog(@"空的数据集.");
    }
    else if (error != nil){
        NSLog(@"发生致命错误：%@", error);
    }
    
    }@catch (NSException *exception) {
    
    }
    @finally {
    
    }

    return FALSE;
}

//镶口数据获取
-(BOOL *)getwithmouth:(NSString *)Nowt
{
    @try {
    
    sqlService *sqlser= [[sqlService alloc]init];
    
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString * timecode=@"withmouth";
    
    NSString * uId=myDelegate.entityl.uId;
    NSString * Upt=[sqlser getUpdateTime:timecode];//获取上一次的更新时间
    
    //Kstr=md5(uId|type|Upt|Key|Nowt)
    NSString * Kstr=[Commons md5:[NSString stringWithFormat:@"%@|%@|%@|%@|%@",uId,@"102",Upt,apikey,Nowt]];
    
    NSString * surl = [NSString stringWithFormat:@"/app/appinterface.php?uId=%@&type=102&Upt=%@&Nowt=%@&Kstr=%@",uId,Upt,Nowt,Kstr];
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",domainser,surl];
    
    NSMutableDictionary * dict = [DataService GetDataService:URL];
    //{"status":"true","uptime":1401886947,"result":[["36530","S000001W","C20454992","18K\u94bb\u77f3\u5973\u6212","0","1","1","/files/3DNewa/1/3C0158E/3C0158E_thumb_1.jpg","/files/3DNewa/1/3C0158E/3C0158E.jpg","0","","0","0","3C0158E","0","2014 \u4e00\u6708 23 17:56","2","0.0","0","0","0","60","0.0","0.0","0","0","0","0","0","0","0","1","","1","0.385","I-J","","SI",""," ","0.0","0","","0","0.0",""," ",""," ","","0.0",""," ",""," ",""," ","0","0",""," ","2","0.0","0.0","{14}","0.0","60.0000","0",null,"0.22","1.92","2.52"]]}
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        error = nil;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonObject != nil && error == nil){
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *d = (NSDictionary *)jsonObject;
                NSString * status=[d objectForKey:@"status"];
                if ([status isEqualToString:@"false"]) {
                    return FALSE;
                }
                NSArray * objArray=[d objectForKey:@"result"];
                for(int i = 0 ; i < objArray.count ; i++){
                    
                    NSArray * valuearray = objArray[i];
                    //NSString *values = [objArray[i] componentsJoinedByString:@","];
                    NSMutableString *values=[[NSMutableString alloc] init];
                    for (int j = 0 ; j < valuearray.count ; j++) {
                        if(j>0)[values appendString:[NSString stringWithFormat:@","]];
                        [values appendString:[NSString stringWithFormat:@"'%@'",valuearray[j]]];
                    }
                    
                    NSString *tablekey=@"Id,Proid,zWeight,AuWeight,ptWeight,IsComm";
                    
                    NSString * sql=[NSString stringWithFormat:@"insert into withmouth(%@)values(%@)",tablekey,(NSString *)values];
                    
                    NSLog(@"--------------:%@",sql);
                    
                    [sqlser HandleSql:sql];
                    
                }
                //先删除之前的更新时间
                [sqlser HandleSql:[NSString stringWithFormat:@"delete from updatetime where updateCode='%@'",timecode]];
                
                NSString * uptime=[d objectForKey:@"uptime"];
                //更新时间表记录
                NSString * sql1=[NSString stringWithFormat:@"insert into updatetime(updateCode,updatetime)values('%@','%@')",timecode,uptime];
                
                NSLog(@"--------------:%@",sql1);
                
                [sqlser HandleSql:sql1];
                
            }else if ([jsonObject isKindOfClass:[NSArray class]]){
                //                NSArray * objArray = (NSArray *)jsonObject;
                //
                //                for(int i = 0 ; i < objArray.count ; i++)
                //                {
                //
                //                }
                
            }
            else {
                NSLog(@"无法解析的数据结构.");
            }
            
            return TRUE;
        }
        else if (error != nil){
            NSLog(@"%@",error);
        }
    }
    else if ([jsonData length] == 0 &&error == nil){
        NSLog(@"空的数据集.");
    }
    else if (error != nil){
        NSLog(@"发生致命错误：%@", error);
    }
    
    }@catch (NSException *exception) {
        
    }
    @finally {
        
    }
        
    return FALSE;
}

@end
