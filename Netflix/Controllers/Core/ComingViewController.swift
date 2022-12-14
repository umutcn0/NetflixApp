//
//  ComingViewController.swift
//  Netflix
//
//  Created by Umut Can on 11.08.2022.
//

import UIKit

class ComingViewController: UIViewController {
    
    var titles : [Title] = [Title]()
    
    private let upcomingTable : UITableView = {
        let table = UITableView()
        table.register(ComingTableViewCell.self, forCellReuseIdentifier: ComingTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .always
        
        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        fetchUpcomingMovies()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
    }
    
    func fetchUpcomingMovies(){
        APICaller.shared.getUpcomingMovies { result in
            switch result{
            case .success(let title):
                self.titles = title
                DispatchQueue.main.async { [weak self] in
                    self?.upcomingTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    

}

extension ComingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
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
    
    
}
