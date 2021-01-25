//
//  ViewController.swift
//  Assesment
//
//  Created by Govindharaj Murugan on 06/01/21.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableViewUser: UITableView!
    
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel()
    }()
    
    // MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingView.shared.show()
        
        self.configureTableView()
        self.addSearchBar()
        
        self.initViewModel()
    }
    
    func configureTableView() {
        self.tableViewUser.dataSource = self
        self.tableViewUser.delegate = self
        self.tableViewUser.tableFooterView = UIView()
        self.tableViewUser.separatorStyle = .none
        self.tableViewUser.keyboardDismissMode = .onDrag
        self.tableViewUser.register(UINib(nibName: UserTableViewCell.cellIdentifier(), bundle: nil), forCellReuseIdentifier: UserTableViewCell.cellIdentifier())
    }
    
    func addSearchBar() {
        self.viewModel.searchBar.delegate = self
        self.tableViewUser.tableHeaderView = self.viewModel.searchBar
    }
    
    private func initViewModel() {

        self.viewModel.reloadTableViewClosure = {
            DispatchQueue.main.async { [weak self] in
                self?.tableViewUser.reloadData()
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
        
        self.viewModel.initFetch()
        self.viewModel.getSearchBar()
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK:- UISearchBarDelegate
extension HomeViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.searchTextDidChange(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.searchBar.endEditing(true)
    }

}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.viewModel.numberOfCells > 0 else { return 0 }
        return self.viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userCell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellIdentifier()) as? UserTableViewCell else {
            fatalError("Cell does not exist in storyboard")
        }
        
        userCell.setUpCell(self.viewModel.getCellViewModel(at: indexPath))
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.viewModel.searchBar.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profileview = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileview.viewModel.userDetails = self.viewModel.getDataSource(at: indexPath)
        self.navigationController?.pushViewController(profileview, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.numberOfCells - 1 {
            self.viewModel.initFetch()
        }
    }
}

