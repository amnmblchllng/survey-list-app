//
//  SurveyListViewController.swift
//  survey-list-app
//
//  Created by amnmblchllng on 10.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import UIKit
import SDWebImage

// SurveyListViewController is the default view controller; it lists the surveys
class SurveyListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let api = APISurveyProvider(api: API())
    private var surveys: [Survey] = []
    private var refreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SURVEYS"
        
        // styling
        view.backgroundColor = UIColor(hexRgba: 0x1B284BFF)
        pageControl.transform = pageControl.transform.rotated(by: .pi/2)
        collectionView.backgroundColor = view.backgroundColor
        
        // action buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "🍔", style: .plain, target: nil, action: nil)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        refreshFromAPI()
    }
    
    // layout page control because auto layout doesn't seem to handle rotation well
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageControl.frame = CGRect(x: view.bounds.width - 20, y: 0, width: 20, height: view.bounds.height)
    }
    
    @objc private func refresh() {
        refreshFromAPI()
    }
    
    private func refreshFromAPI(page: Int? = nil) {
        if page == nil {
            // first iteration
            if refreshing {
                return
            }
            refreshing = true
            surveys = []
            collectionView.reloadData()
            activityIndicator.startAnimating()
        }
        let page = page ?? 1
        api.getSurveys(page: page, perPage: 20) { (error, surveys) in
            guard let surveys = surveys, error == nil else {
                self.showError("Error loading surveys. Please retry refreshing")
                self.activityIndicator.stopAnimating()
                self.refreshing = false
                return
            }
            if surveys.count == 0 {
                // last iteration
                self.activityIndicator.stopAnimating()
                self.refreshing = false
                return
            }
            self.surveys.append(contentsOf: surveys)
            self.collectionView.reloadData()
            self.refreshFromAPI(page: page + 1)
        }
    }
    
    // show error message in alert box
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // set current page of page control
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (collectionView.frame.height > 0) {
            pageControl.currentPage = Int(collectionView.contentOffset.y + collectionView.frame.height / 2) / Int(collectionView.frame.height)
        } else {
            pageControl.currentPage = 0
        }
    }
    
    // numbers of pages and set page control number of pages
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = surveys.count
        pageControl.numberOfPages = number
        return number
    }
    
    // get current cell and populate with data
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SurveyCollectionViewCell
        let row = indexPath.row
        let survey = surveys[row]
        cell.populate(survey: survey, action: { [weak self] survey in
            if let s = self {
                s.performSegue(withIdentifier: "tappedTakeSurveySegue", sender: s)
            }
        })
        return cell
    }
    
    // no space between cells #1
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // no space between cells #2
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // sets full screen cell size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }

}


