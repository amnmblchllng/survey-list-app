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
    
    var tappedTakeSurveyAction: ((Survey)->())?
    var survey: Survey!
    let gradient = CAGradientLayer()
    
    @IBAction func tappedTakeSurvey(_ sender: Any) {
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
        gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 0.5)
    }
    
    func populate(survey: Survey, action: @escaping (Survey)->()) {
        // some surveys' images point to unavailable cloudfront bucket so it displays nothing
        let imageURL = URL(string: survey.coverImageUrlLarge)!
        self.imageView.sd_setImage(with: imageURL)
        self.titleLabel.text = survey.title
        self.descriptionLabel.text = survey.description
        self.survey = survey
        self.tappedTakeSurveyAction = action
    }
}
