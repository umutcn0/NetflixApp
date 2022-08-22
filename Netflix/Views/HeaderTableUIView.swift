//
//  HeaderTableUIView.swift
//  Netflix
//
//  Created by Umut Can on 12.08.2022.
//

import UIKit

protocol HeaderTableUIViewDelegate: AnyObject{
    func downloadButtonDidTaped()
    func playButtonDidTapped()
}

class HeaderTableUIView: UIView {
    
    weak var delegate: HeaderTableUIViewDelegate?
    
    //Button defining
    private let downloadButton : UIButton = {
        
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playButton : UIButton = {
        
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

        //Defining image for the table header.
    private let headerTableImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Dune")
        return imageView
    }()
    
    //Adding gradient for the photo (Geçişli gölgelendirme) 
    private func addGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerTableImage)
        addGradient()
        addSubview(playButton)
        addSubview(downloadButton)
        applyContraints()
    }
    
    //Button Constraints
    private func applyContraints(){
        let playButtonConstraints = [
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            playButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let downloadButtonConstraints = [
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        NSLayoutConstraint.activate(playButtonConstraints) // Activating the constraints of buttons.
        NSLayoutConstraint.activate(downloadButtonConstraints)
    }
    
    // Giving frame value for our image.
    override func layoutSubviews() {
        super.layoutSubviews()
        headerTableImage.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func configure(_ model : TitleViewModel){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(model.posterURL)") else {return}
        headerTableImage.sd_setImage(with: url)
    }
    
    public func configureButtons() {
        downloadButton.addTarget(self, action: #selector(didTapDownload), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)

    }
    
    @objc private func didTapDownload() {
        delegate?.downloadButtonDidTaped()
    }
    
    @objc private func didTapPlay() {
        delegate?.playButtonDidTapped()
    }

}
