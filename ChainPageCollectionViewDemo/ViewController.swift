//
//  ViewController.swift
//  ChainPageCollectionViewDemo
//
//  Created by yansong li on 2017-07-23.
//  Copyright © 2017 yansong li. All rights reserved.
//

import UIKit
import ChainPageCollectionView

class ViewController: UIViewController {
  
  let parentDataSource = ["yelp", "facebook", "netflix", "yahoo", "google", "indeed", "ritual",
                          "sina", "new york time", "gilt"]
  let childImages = ["c1", "c2", "c3", "c4", "c5", "c6"]
  
  var parentIndex: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    chainCollectionView.delegate = self
    chainCollectionView.backgroundColor = UIColor(red: 237 / 255.0,
                                                  green: 231 / 255.0,
                                                  blue: 206 / 255.0,
                                                  alpha: 1.0)
    chainCollectionView.parentCollectionView.register(ImageCardCollectionViewCell.self,
                                                      forCellWithReuseIdentifier: String(describing: ImageCardCollectionViewCell.self))
    chainCollectionView.childCollectionView.register(ImageCardCollectionViewCell.self,
                                                     forCellWithReuseIdentifier: String(describing: ImageCardCollectionViewCell.self))
    self.navigationController?.navigationBar.isHidden = false
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func loadView() {
    let chainView = ChainPageCollectionView(viewType: .customParentHeight(28, 12))
    chainView.parentCollectionViewItemSize = CGSize(width: 260, height: 390)
    view = chainView
  }
  
  var chainCollectionView: ChainPageCollectionView {
    return view as! ChainPageCollectionView
  }
}

extension ViewController: ChainPageCollectionViewProtocol {
  func parentCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return parentDataSource.count
  }
  
  func parentCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCardCollectionViewCell.self), for: indexPath)
    if let vCell = cell as? ImageCardCollectionViewCell {
      vCell.backGroundImageView.image = UIImage(named: parentDataSource[indexPath.row])
    }
    return cell
  }
  
  
  func childCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return childImages.count
  }
  
  func childCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCardCollectionViewCell.self), for: indexPath)
    if let vCell = cell as? ImageCardCollectionViewCell {
      if indexPath.row == 0 {
        vCell.backGroundImageView.image = UIImage(named: parentDataSource[self.parentIndex])
      } else {
        vCell.backGroundImageView.image = UIImage(named: childImages[indexPath.row])
      }
    }
    return cell
  }
  
  func childCollectionView(_ collectionView: UICollectionView, parentCollectionViewIndex: Int) {
    //chainCollectionView.childCollectionViewDataReady = true
    // NOTE: Add a little delay to let childCollectionView/layout updates its data.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
      self.parentIndex = parentCollectionViewIndex
      self.chainCollectionView.childCollectionViewDataReady = true
    })
  }
}

