//
//  ProfileViewModel.swift
//  Assesment
//
//  Created by Govindharaj Murugan on 10/01/21.
//

import UIKit

class ProfileViewModel {
    
    var apiService: ApiService = { return ApiService()}()
    
    lazy var userDetails = Item()
    lazy var followerPageIndex = 0
    lazy var followingPageIndex = 0
    lazy var rowHeight: CGFloat = 70
    
    var user : User?
    
    var updateUI: (()->())?
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var showAlertClosure: (()->())?
    
    private var arrFollowers:[Follow] = [Follow]() {
        didSet {
            var arrViewModel = [UserTableCellViewModel]()
            for follower in arrFollowers {
                arrViewModel.append(self.createCellViewModel(item: follower))
            }
            self.arrUserFollowerCellModel = arrViewModel
        }
    }
    
    private var arrFollowing:[Follow] = [Follow]() {
        didSet {
            var arrViewModel = [UserTableCellViewModel]()
            for following in arrFollowing {
                arrViewModel.append(self.createCellViewModel(item: following))
            }
            self.arrUserFollowingCellModel = arrViewModel
        }
    }
    
    private var arrUserFollowerCellModel: [UserTableCellViewModel] = [UserTableCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    private var arrUserFollowingCellModel: [UserTableCellViewModel] = [UserTableCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    func createCellViewModel(item: Follow) -> UserTableCellViewModel {
        return UserTableCellViewModel(userName: item.login, id: item.id, imageUrl: item.avatarURL)
    }
    
    var numberOfFollowerCells: Int {
        return arrFollowers.count
    }
    
    var numberOfFollowingCells: Int {
        return arrFollowing.count
    }
    
    func getCellViewModel(at indexPath: IndexPath, segmentIndex: Int) -> UserTableCellViewModel {
        if segmentIndex == 0 {
            return self.arrUserFollowerCellModel[indexPath.row]
        } else {
            return self.arrUserFollowingCellModel[indexPath.row]
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    // MARK:- API requests
    func initFetchUserDetails() {
        self.isLoading = true
        self.apiService.fetchUserDetails(self.userDetails.url) { [weak self] (success, userDetails, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.user = userDetails as? User
            }
            self?.updateUI?()
        }
    }
    
    func fetchFollowers() {
        if self.followerPageIndex == 0 || (self.user?.followers ?? 0) > self.arrFollowers.count {
            self.followerPageIndex += 1
        } else if (self.user?.followers ?? 0) == self.arrFollowers.count {
            return
        }
        self.isLoading = true
        self.apiService.fetchFollowers(self.followerPageIndex, url: self.userDetails.followersURL) { [weak self] (success, follower, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                if self?.arrFollowers.count == 0 {
                    self?.arrFollowers = follower as! [Follow]
                } else {
                    self?.arrFollowers += follower as! [Follow]
                }
            }
        }
    }
    
    func fetchFollowing() {
        
        if self.followingPageIndex == 0 || (self.user?.following ?? 0) > self.arrFollowing.count {
            self.followingPageIndex += 1
        } else if (self.user?.following ?? 0) == self.arrFollowing.count {
            return
        }
        
        self.isLoading = true
        self.apiService.fetchFollowing(self.followingPageIndex, url: self.userDetails.url) { [weak self] (success, following, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                if self?.arrFollowing.count == 0 {
                    self?.arrFollowing = following as! [Follow]
                } else {
                    self?.arrFollowing += following as! [Follow]
                }
            }
        }
    }
}
