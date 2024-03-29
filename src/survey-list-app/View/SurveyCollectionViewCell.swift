//
//  SurveyCollectionViewCell.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import UIKit

// SurveyCollectionViewCell is the cell that displays a venue to take a survey for
class SurveyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var tappedTakeSurveyAction: ((Survey)->())?
    private var survey: Survey?
    private let gradient = CAGradientLayer()
    
    @IBAction func tappedTakeSurvey(_ sender: Any) {
        guard let survey = survey else {
            return
        }
        tappedTakeSurveyAction?(survey)
    }
    
    // add gradient overlay
    override func awakeFromNib() {
        super.awakeFromNib()
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.opacity = 0.4
        imageView.layer.addSublayer(gradient)
    }
    
    // layout gradient
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 0.5)
    }
    
    func populate(survey: Survey, action: @escaping (Survey)->()) {
        if let imageURL = URL(string: survey.coverImageUrlLarge) {
            // some surveys' images point to unavailable cloudfront bucket so it displays nothing
            imageView.sd_setImage(with: imageURL)
        } else {
            imageView.sd_setImage(with: nil)
        }
        titleLabel.text = survey.title
        descriptionLabel.text = survey.description
        self.survey = survey
        tappedTakeSurveyAction = action
    }
}
