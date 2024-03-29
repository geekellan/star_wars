//
//  SearchPersonVC.swift
//  TheStarWars
//
//  Created by Ellan Esenaliev on 6/3/19.
//  Copyright © 2019 Ellan Esenaliev. All rights reserved.
//

import UIKit

class SearchPersonVC: UIViewController {
    
    enum SearchPersonVCSection: Int {
        case cashing
        case searching
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var charactersTableView: UITableView! {
        didSet {
            charactersTableView.delegate = self
            charactersTableView.dataSource = self
            charactersTableView.tableFooterView = UIView(frame: .zero)
            charactersTableView.register(CharacterTVCell.nib, forCellReuseIdentifier: CharacterTVCell.identifier)
        }
    }
    
    var viewModel: SearchPersonVM? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = SearchPersonVM()
    }
    
}

extension SearchPersonVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel?.search(text: searchText)
        self.viewModel?.loadCharacters(text: searchText)
    }
}

extension SearchPersonVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CharacterTVC") as! CharacterTVC
        vc.character = self.viewModel!.characters[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel else { return }
        if indexPath.row == viewModel.characters.count - 1 {
            viewModel.loadCharactersNextPage()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
}

extension SearchPersonVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SearchPersonVCSection(rawValue: section)! {
        case .cashing:
            return self.viewModel?.chachedCharacters.count ?? 0
        case .searching:
            return self.viewModel?.characters.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTVCell.identifier) as! CharacterTVCell
        switch SearchPersonVCSection(rawValue: indexPath.section)! {
        case .cashing:
            cell.setup(character: self.viewModel!.chachedCharacters[indexPath.row])
        case .searching:
            cell.setup(character: self.viewModel!.characters[indexPath.row])
        }
        return cell
    }
}

extension SearchPersonVC: SearchPersonVMDelegate {
    
    func searchPersonVM(_ class: SearchPersonVM, didUpdateCachingCharacters characters: [Character]) {
        self.charactersTableView.reloadSections(IndexSet([0]), with: .automatic)
    }
    
    func searchPersonVM(_ class: SearchPersonVM, didLoadCharacters character: [Character]) {
        self.charactersTableView.reloadSections(IndexSet([1]), with: .automatic)
    }
    
    func searchPersonVM(_ class: SearchPersonVM, didRecieveError message: String) {
        self.showAlert(message: message)
    }
}
