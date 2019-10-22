//
//  TakeSurveyButton.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import UIKit

// TakeSurveyButton is a rounded button for taking a survey of a venue
class TakeSurveyButton: UIButton {
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? UIColor(red: 0xCA/255.0, green: 0x29/255.0, blue: 0x68/255.0, alpha: 1)
                : UIColor(red: 0xCA/255.0, green: 0x20/255.0, blue: 0x2E/255.0, alpha: 1)
        }
    }
}
