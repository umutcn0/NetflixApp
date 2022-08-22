//
//  SearchViewController.swift
//  Netflix
//
//  Created by Umut Can on 11.08.2022.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titles : [Title] = [Title]()
    
    private let searchTableView : UITableView = {
        let table = UITableView()
        table.register(ComingTableViewCell.self, forCellReuseIdentifier: ComingTableViewCell.identifier)
        return table
    }()
    
    private let searchController : UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or a TV show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        searchTableView.delegate = self
        searchTableView.dataSource = self
        view.addSubview(searchTableView)
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationController?.navigationBar.tintColor = .white
        
        fetchDiscoverMovies()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTableView.frame = view.bounds
    }
    
    private func fetchDiscoverMovies(){
        APICaller.shared.getDiscoverMovies { [weak self]result in
            switch result{
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.searchTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:ComingTableViewCell.identifier , for: indexPath) as? ComingTableViewCell else {
            return UITableViewCell()
            }
        cell.configure(with: TitleViewModel(posterURL: titles[indexPath.row].poster_path ?? "", titleName: titles[indexPath.row].original_title ?? titles[indexPath.row].original_name ?? "Unknown"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate{

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else{
                return
            }
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    resultsController.titles = titles
                    resultsController.searchResultCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let titles = titles[indexPath.row]
        let model_title = self.titles[indexPath.row]
        guard let titleOverview = model_title.overview else {return}
        
        guard let titleName = titles.original_title ?? titles.original_name else {return}
        
        APICaller.shared.getMovie(with: titleName + "trailer") { result in
            switch result {
            case .success(let VideoElement):
                
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    let viewModel = TitlePreviewViewModel(title: titleName, titleOverview: titleOverview, youtubeVideo: VideoElement)
                    vc.configure(with: viewModel)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func SearchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
