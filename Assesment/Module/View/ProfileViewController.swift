//
//  ProfileViewController.swift
//  Assesment
//
//  Created by Govindharaj Murugan on 06/01/21.
//

import UIKit
import Alamofire
import Kingfisher

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var lblPublicRepos: UILabel!
    @IBOutlet weak var lblPublicGist: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblUpdatedDate: UILabel!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var lblNoUserData: UILabel!
    
    @IBOutlet weak var tableViewFollow: UITableView!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    
    lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()
    
    // MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageViewAvatar.layer.roundedCorner()
        
        self.segmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        self.segmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        self.lblNoUserData.isHidden = true
        self.configureTableView()
        
        self.initViewModel()
        
    }
    
    func configureTableView() {
        self.lblNoData.isHidden = true
        self.tableViewFollow.dataSource = self
        self.tableViewFollow.delegate = self
        self.tableViewFollow.tableFooterView = UIView()
        self.tableViewFollow.separatorStyle = .none
        self.tableViewFollow.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
    }
    
    private func initViewModel() {

        self.viewModel.updateUI = {
            DispatchQueue.main.async { [weak self] in
                self?.updateUI()
            }
        }
        
        self.viewModel.reloadTableViewClosure = {
            DispatchQueue.main.async { [weak self] in
                self?.tableViewFollow.reloadData()
            }
        }

        self.viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    LoadingView.shared.show()
                }else {
                    LoadingView.shared.hide()
                }
            }
        }

        self.viewModel.showAlertClosure = { [weak self] in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(message)
                }
            }
        }
        
        self.viewModel.initFetchUserDetails()
        self.viewModel.fetchFollowers()
        self.viewModel.fetchFollowing()
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func updateUI() {
        
        if let userObj = self.viewModel.user {
            self.lblNoUserData.isHidden = true
            let url = URL(string: userObj.avatarURL ?? "")
            self.imageViewAvatar.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
            self.title = userObj.name
            
            if userObj.followers == nil  {
                self.lblFollowers.isHidden = true
            } else {
                self.lblFollowers.text = "Followers : \(userObj.followers ?? 0)"
            }
            if userObj.following == nil  {
                self.lblFollowing.isHidden = true
            } else {
                self.lblFollowing.text = "Following : \(userObj.following ?? 0)"
            }
            if userObj.publicRepos == nil  {
                self.lblPublicRepos.isHidden = true
            } else {
                self.lblPublicRepos.text = "Public repos : \(userObj.publicRepos ?? 0)"
            }
            if userObj.publicGists == nil  {
                self.lblPublicGist.isHidden = true
            } else {
                self.lblPublicGist.text = "Public gist : \(userObj.publicGists ?? 0)"
            }
            
            let date = Date().convertStringToDate(userObj.updatedAt ?? "")
            let strDate = date.convertDateToString()
            if strDate != "" {
                self.lblUpdatedDate.text = "Updated: \(strDate)"
            } else {
                self.lblUpdatedDate.isHidden = true
            }
            
        } else {
            let url = URL(string: self.viewModel.userDetails.avatarURL)
            self.imageViewAvatar.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
            self.title = self.viewModel.userDetails.login
            
            self.lblNoUserData.isHidden = false
            self.lblFollowers.isHidden = true
            self.lblFollowing.isHidden = true
            self.lblPublicRepos.isHidden = true
            self.lblPublicGist.isHidden = true
            self.lblUpdatedDate.isHidden = true
        }
        
    }
    
    
    // MARK:- UIClick action
    @IBAction func btnShare_Click(_ sender: Any) {
        let image = self.imageViewAvatar.image
        let textToShare = "Welcome to Git profile"
        let gitUrl = self.viewModel.user?.avatarURL
        let objectsToShare = [textToShare, image as Any, gitUrl as Any] as [Any]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func segmentedController_Click(_ sender: Any) {
        self.tableViewFollow.reloadData()
    }
    
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.segmentedController.selectedSegmentIndex == 0 {
            guard self.viewModel.numberOfFollowerCells > 0 else {
                self.lblNoData.isHidden = false
                self.lblNoData.text = "No followers found"
                return 0
            }
            self.lblNoData.isHidden = true
            return self.viewModel.numberOfFollowerCells
        } else  {
            guard self.viewModel.numberOfFollowingCells > 0 else {
                self.lblNoData.isHidden = false
                self.lblNoData.text = "Not following anyone"
                return 0
            }
            self.lblNoData.isHidden = true
            return self.viewModel.numberOfFollowingCells
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userCell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as? UserTableViewCell else {
            fatalError("Cell does not exist in storyboard")
        }
        userCell.setUpCell(self.viewModel.getCellViewModel(at: indexPath, segmentIndex: self.segmentedController.selectedSegmentIndex))
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewFollow.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { 
        
        if self.segmentedController.selectedSegmentIndex == 0 {
            if indexPath.row == self.viewModel.numberOfFollowerCells - 1 {
                self.viewModel.fetchFollowers()
            }
        } else {
            if indexPath.row == self.viewModel.numberOfFollowingCells - 1 {
                self.viewModel.fetchFollowing()
            }
        }
    }
    
}
