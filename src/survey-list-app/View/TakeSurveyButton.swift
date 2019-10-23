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
                ? UIColor(hexRgba: 0xCA2968FF)
                : UIColor(hexRgba: 0xCA202EFF)
        }
    }
}
