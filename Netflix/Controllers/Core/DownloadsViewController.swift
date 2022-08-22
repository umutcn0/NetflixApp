//
//  DownloadsViewController.swift
//  Netflix
//
//  Created by Umut Can on 11.08.2022.
//

import UIKit

class DownloadsViewController: UIViewController {
    
    private var titles: [TitleItem] = [TitleItem]()

    private let downloadsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ComingTableViewCell.self, forCellReuseIdentifier: ComingTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        
        view.addSubview(downloadsTableView)
        
        downloadsTableView.delegate = self
        downloadsTableView.dataSource = self
        
        fetchDataFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("newItem"), object: nil, queue: nil) { _ in
            self.fetchDataFromDatabase()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadsTableView.frame = view.bounds
    }
    
    func fetchDataFromDatabase(){
        DataPersistenceManager.shared.fetchTitleFromDatabase { [weak self]result in
            switch result{
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.downloadsTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ComingTableViewCell.identifier, for: indexPath) as? ComingTableViewCell else{
                return UITableViewCell()
            }
        
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(posterURL: title.poster_path ?? "", titleName: title.original_name ?? title.original_title ?? "Unknown"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            
            DataPersistenceManager.shared.deleteDataFromDatabase(model: titles[indexPath.row]) { result in
                switch result{
                case .success(()):
                    print("Selected Item Deleted")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self.titles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
    
    
}
