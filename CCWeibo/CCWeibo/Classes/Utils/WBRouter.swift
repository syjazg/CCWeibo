//
//  WBRouter.swift
//  CCWeibo
//
//  Created by 徐才超 on 16/2/6.
//  Copyright © 2016年 徐才超. All rights reserved.
//

import Foundation
import Alamofire

enum WBRouter: URLRequestConvertible {
    static let baseURLString = "https://api.weibo.com/"
    /// oauth2/access_token: OAuth2的access_token接口
    case FetchAccessToken(code: String)
    /// 2/statuses/home_timeline.json: 获取当前登录用户及其所关注（授权）用户的最新微博
    case FetchNewWeibo(accessToken: String, sinceId: Int?, maxId: Int?)
    /// 2/users/show.json: 根据用户ID获取用户信息
    case FetchUserInfo(accessToken: String, uid: String)
    /// 2/statuses/update.json: 发布一条文字微博
    case PostNewTextWeibo(accessToken: String, status: String)
    /// 2/statuses/upload.json: 发布一条图片微博，仅支持一张图片上传
    case PostNewImgWeibo(accessToken: String, status: String)
    
    
    
    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject], method: String) = {
            switch self {
            case .FetchAccessToken(let code):
                return ("oauth2/access_token", ["client_id": WBKeys.AppKey, "client_secret": WBKeys.AppSecret, "grant_type": WBKeys.GrantType, "code": code, "redirect_uri": WBKeys.RedirectURI], "POST")
            case .FetchNewWeibo(let accessToken, var sinceId, var maxId):
                sinceId = sinceId ?? 0
                maxId = maxId ?? 0
                return ("2/statuses/home_timeline.json", ["access_token": accessToken, "since_id": sinceId!, "max_id": maxId!], "GET")
            case .FetchUserInfo(let accessToken, let uid):
                return ("2/users/show.json", ["access_token": accessToken, "uid": uid], "GET")
            case .PostNewTextWeibo(let accessToken, let status):
                return ("2/statuses/update.json", ["access_token": accessToken, "status": status], "POST")
            case .PostNewImgWeibo(let accessToken, let status):
                return ("2/statuses/upload.json", ["access_token": accessToken, "status": status], "POST")
                
            }
            
        }()
        
        let URL = NSURL(string: WBRouter.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        // 新浪微博API限制，HTTP-Header中的Content-Type必须这样设置，否则请求不会成功
        URLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let encoding = Alamofire.ParameterEncoding.URL
        let request = encoding.encode(URLRequest, parameters: result.parameters).0
        request.HTTPMethod = result.method
        return request
    }
}
