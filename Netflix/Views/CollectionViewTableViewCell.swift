//
//  CollectiobViewTableViewCell.swift
//  Netflix
//
//  Created by Umut Can on 11.08.2022.
//

import UIKit

protocol CollectionViewTableViewCellDelegate : AnyObject {
    func CollectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {
    // We are defining Collection view for table view custom cell.
    static let identifier = "CollectionViewTableViewCell"
    
    private var title : [Title] = [Title]()
    weak var delegate : CollectionViewTableViewCellDelegate?
    
    private let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200) // İtem sizes for each box.
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout) // Will define frame later.
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // The default implementation uses any constraints you have set to determine the size and position of any subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with titles:[Title]){
        self.title = titles
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    @objc public func downloadTitleAt(_ indexPath : IndexPath){
        DataPersistenceManager.shared.downloadTitleWith(model: title[indexPath.row]) { result in
            switch result {
            case .success():
                print("Downloaded Item")
                NotificationCenter.default.post(name: NSNotification.Name("newItem"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return title.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        guard let titlePath = title[indexPath.row].poster_path else {return UICollectionViewCell()}
        cell.configure(with: titlePath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let titles = title[indexPath.row]
        guard let titleName = titles.original_title ?? titles.original_name else {return}
        
        APICaller.shared.getMovie(with: titleName + "trailer") { result in
            switch result {
            case .success(let VideoElement):
                
                let model_title = self.title[indexPath.row]
                guard let titleOverview = model_title.overview else {return}
                
                let viewModel = TitlePreviewViewModel(title: titleName, titleOverview: titleOverview, youtubeVideo: VideoElement)
                self.delegate?.CollectionViewTableViewCellDidTapCell(self, viewModel: viewModel)
            
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) {[weak self] _ in
                let downloadAction = UIAction(title: "Download", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                    self?.downloadTitleAt(indexPath)
                }
                return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
            }
        return config
    }
    
}
