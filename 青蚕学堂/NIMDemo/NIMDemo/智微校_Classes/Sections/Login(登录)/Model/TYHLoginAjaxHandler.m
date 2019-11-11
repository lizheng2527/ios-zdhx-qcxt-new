//
//  TYHLoginAjaxHandler.m
//  NIM
//
//  Created by 中电和讯 on 16/12/5.
//  Copyright © 2016年 Netease. All rights reserved.
//


#import "TYHLoginAjaxHandler.h"
#import "TYHHttpTool.h"
#import <MJExtension.h>
#import "TYHLoginInfoModel.h"
#import "NSString+NTES.h"

#define OrganizationJsonURL @"bd/mobile/getOrganizationJson"
#define UserInfoJson @"/bd/mobile/mobileLogin"
#define submitLoginStatus @"/bd/loginRecord/saveOrUpdate"

@implementation TYHLoginAjaxHandler

//获取组织机构(学校)信息
-(void)getOrganizationArrayWithStatus:(void (^)(BOOL ,NSMutableArray *))status failure:(void (^)(NSError *error))failure
{
    NSString *requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,OrganizationJsonURL];
    [TYHHttpTool get:requestURL params:nil success:^(id json) {
        NSMutableArray * blockArray = [NSMutableArray arrayWithArray:[TYHOranizationModel mj_objectArrayWithKeyValuesArray:json]];
        status(YES,blockArray);
    } failure:^(NSError *error) {
        status(NO,[NSMutableArray array]);
        UIView *view = [UIApplication sharedApplication].keyWindow;
        [view makeToast:@"无法获取学校数据" duration:2 position:CSToastPositionCenter];
    }];
}

//获取登录信息
-(void)LoginWithUserName:(NSString *)username Password:(NSString *)password OrganizationID:(NSString *)organizationId andStatus:(void (^)(BOOL ,TYHLoginInfoModel *))status failure:(void (^)(NSError *error))failure
{
//    NSDictionary *dic = @{@"sys_auto_authenticate":@"true",@"sys_username":[NSString stringWithFormat:@"%@",username],@"sys_password":password,@"organizationId":organizationId};
    
    NSDictionary *dic = @{@"loginName":username.length?username:@"",@"password":password.length?password:@"",@"code":organizationId.length?organizationId:@"",@"terminal":@"iOS"};
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,UserInfoJson];
    
    [TYHHttpTool get:requestURL params:dic success:^(id json) {
        TYHLoginInfoModel *loginModel = [TYHLoginInfoModel new];
        loginModel = [TYHLoginInfoModel mj_objectWithKeyValues:json];
        
        
        loginModel.userID = [json objectForKey:@"id"];
        loginModel.v3Id =[json objectForKey:@"id"];
        loginModel.v3Id =[json objectForKey:@"id"];
        loginModel.token = [json objectForKey:@"sys_token"];
        loginModel.dataSourceName = @"dataSourceName";
        loginModel.v3pwd = @"password";
        
//        [[NSUserDefaults standardUserDefaults] setValue:loginModel.token forKey:USER_DEFAULT_TOKEN];
//        [[NSUserDefaults standardUserDefaults] setValue:loginModel.v3pwd forKey:USER_DEFAULT_V3PWD];
//        [[NSUserDefaults standardUserDefaults]setValue:loginModel.dataSourceName forKey:USER_DEFAULT_DataSourceName];
//        [[NSUserDefaults standardUserDefaults] setValue:loginModel.v3Id forKey:USER_DEFAULT_V3ID];
//        [[NSUserDefaults standardUserDefaults]setValue:loginModel.kind forKey:USER_DEFAULT_KIND];
//        [[NSUserDefaults standardUserDefaults]setValue:loginModel.name forKey:USER_DEFAULT_USERNAME];
//        [[NSUserDefaults standardUserDefaults]setValue:loginModel.userID forKey:USER_DEFAULT_USERID];
        
        
        
//        userName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_LOGINNAME];
//        password = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_V3PWD];
//        organizationID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ORIGANIZATION_ID];
//        dataSourceName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_DataSourceName];
//        token = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_TOKEN];
//
//        dataSourceName = dataSourceName.length?dataSourceName:@"";
//        userID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_V3ID];
        
        
        //登录失败时
        if ([[json objectForKey:@"successStatus"] isEqualToString:@"1"]) {
            loginModel = [TYHLoginInfoModel mj_objectWithKeyValues:json];
        }
        
        
//        loginModel.qcxtUrl = @"http://192.168.1.119:18000/dubbo-wisdomclass/";
//        loginModel.token = @"20181227162130531682211138191929";
        
        
        status(YES,loginModel);
    } failure:^(NSError *error) {
        status(NO,[TYHLoginInfoModel new]);
    }];
}

//验证服务器地址
+(BOOL)AjaxURL:(NSString *)url
{
    NSString *ContactUrl = [NSString stringWithFormat:@"%@%@",url,OrganizationJsonURL];
    ContactUrl = [ContactUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[
                                                    NSURL URLWithString:ContactUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    request.HTTPMethod = @"GET";
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    [request setTimeoutInterval:8.0f];

    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    if(!error && data && response.statusCode==200)
        return YES;
    else
        return NO;
    
}

//统计登录
-(void)submitLoginStatusWithLoginName:(NSString *)userName PassWord:(NSString *)password UserID:(NSString *)userID terminalStatus:(NSString *)terminal
{
//    terminal     android 0, ios 1, pc 2
    
    NSDictionary *userInfoDic = @{@"sys_auto_authenticate":@"true",@"sys_username":[NSString stringWithFormat:@"%@",userName],@"sys_password":password,@"userId":userID,@"terminal":terminal};
    NSString *requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,submitLoginStatus];
    [TYHHttpTool gets:requestURL params:userInfoDic success:^(id json) {
        
        NSString *string = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        if ([string isEqualToString:@"ok"]) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

//修改手机号
-(void)changeMobiePhoneNum:(NSString *)phoneNum andStatus:(void (^)(BOOL successful))status failure:(void (^)(NSError *error))failure
{
    NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_LOGINNAME];
    NSString *password = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_PASSWORD];
    NSString *orgId = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ORIGANIZATION_ID];
    
    NSString *dataSourceName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_DataSourceName];
    dataSourceName = dataSourceName.length?dataSourceName:@"";
    
    
    NSString *imToken = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_TOKEN];
    NSString *userID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERID];
    NSDictionary *userInfoDic = [NSDictionary dictionary];
    userInfoDic = @{@"sys_auto_authenticate":@"true",@"sys_username":[NSString stringWithFormat:@"%@,%@",userName,orgId],@"sys_password":password,@"dataSourceName":dataSourceName,@"userId":userID,@"mobileNum":phoneNum,@"imToken":imToken,@"sys_Token":imToken};
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,@"/bd/user/updateMobileNum"];
    
    [TYHHttpTool gets:requestURL params:userInfoDic success:^(id json) {
        
       NSString *resultSrting = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        if ([resultSrting isEqualToString:@"success"]) {
            status(YES);
        }else status(NO);
        
    } failure:^(NSError *error) {
        status(NO);
    }];
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
