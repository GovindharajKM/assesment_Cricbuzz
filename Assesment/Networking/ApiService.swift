//
//  ApiService.swift
//  Assesment
//
//  Created by Govindharaj Murugan on 10/01/21.
//

import Foundation
import Alamofire


enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

typealias WebServiceCallBack = (_ success : Bool, _ response : Any?, _ error : APIError? ) -> Void

class ApiService {
    
    init() { }
    
    // Fetch all Users ans Search users by keyword
    func fetchAllUsers(_ pageIndex: Int = 0, searchText: String = "", complete: @escaping WebServiceCallBack) {
        guard Reachability.isConnectedToNetwork() else {
            complete(false, nil, .noNetwork)
            return
        }
        var url = "https://api.github.com/search/users?q=type:user&page=\(pageIndex)"
        if searchText != "" {
            url = "https://api.github.com/search/users?q=\(searchText)&page=\(pageIndex)"
        }
        
        AF.request(url).validate().responseDecodable(of: UserList.self) { (response) in
            DispatchQueue.main.async {
                guard let users = response.value else {
                    complete(false, UserList() as AnyObject?, .serverOverload)
                    return
                }
                UserListModel().insertListOfUsers(users.items)
                complete(true, users as AnyObject?, nil)
            }
        }
    }
    
    // Fetch particular user details
    func fetchUserDetails(_ url: String, complete: @escaping WebServiceCallBack) {
        guard Reachability.isConnectedToNetwork() else {
            complete(false, UserList() as AnyObject?, .noNetwork)
            return
        }
        AF.request(url).validate().responseDecodable(of: User.self) { (response) in
            DispatchQueue.main.async {
                guard let userDetails = response.value else {
                    complete(false, nil, .serverOverload)
                    return
                }
                complete(true, userDetails, nil)
            }
        }
    }
    
    // Fetch followers of the particular user
    func fetchFollowers(_ pageIndex: Int = 0, url: String, complete: @escaping WebServiceCallBack) {
        
        guard Reachability.isConnectedToNetwork() else {
            complete(false, nil, .noNetwork)
            return
        }

        AF.request("\(url+"?page=\(pageIndex)")").validate().responseDecodable(of: [Follow].self) { (response) in
            DispatchQueue.main.async {
                guard let followers = response.value else {
                    complete(false, nil, .serverOverload)
                    return
                }
                complete(true, followers, nil)
            }
        }
        
    }
    
    // Fetch following user list
    func fetchFollowing(_ pageIndex: Int = 0, url: String, complete: @escaping WebServiceCallBack) {
        
        guard Reachability.isConnectedToNetwork() else {
            complete(false, nil, .noNetwork)
            return
        }
        
        AF.request("\(url + "/following?page=\(pageIndex)")").validate().responseDecodable(of: [Follow].self) { (response) in
            DispatchQueue.main.async {
                guard let following = response.value else {
                    complete(false, nil, .serverOverload)
                    return
                }
                complete(false, following, nil)
               
            }
        }
    }
    
}
