//
//  ComingTableViewCell.swift
//  Netflix
//
//  Created by Umut Can on 16.08.2022.
//

import UIKit
import SDWebImage

class ComingTableViewCell: UITableViewCell {
    
    static let identifier = "ComingTableViewCell"
    
    private let playButton : UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
        
    }()
    
    private let posterTitleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let posterImageView : UIImageView = {
        let posterImage = UIImageView()
        posterImage.contentMode = .scaleAspectFill
        posterImage.translatesAutoresizingMaskIntoConstraints = false
        posterImage.clipsToBounds = true
        return posterImage
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(posterImageView)
        contentView.addSubview(posterTitleLabel)
        contentView.addSubview(playButton)
        applyConstraints()
        
    }
    
    private func applyConstraints(){
        let posterImageViewConstraints = [
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            posterImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            posterImageView.widthAnchor.constraint(equalToConstant: 100)
        ]
        
        let posterTitleLabelConstraints = [
            posterTitleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 20),
            posterTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ]
        
        let playButtonConstraints = [
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ]
        
        NSLayoutConstraint.activate(posterImageViewConstraints)
        NSLayoutConstraint.activate(posterTitleLabelConstraints)
        NSLayoutConstraint.activate(playButtonConstraints)
    }
    
    public func configure (with model: TitleViewModel){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(model.posterURL)") else {return}
        posterImageView.sd_setImage(with: url)
        posterTitleLabel.text = model.titleName.maxLength(length: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}


