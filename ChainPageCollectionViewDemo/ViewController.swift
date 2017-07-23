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
  
  let parentDataSource = ["Yelp", "Facebook", "Netflix", "Yahoo", "Google", "Indeed", "Ritual",
                          "Sina", "New York Times", "Firefox", "Gilt"]
  
  let childDataSouce = [["Yelp has a big news 1", "Yelp has a big news 2", "Yelp has a big news 3", "Yelp has a big news 4", "Yelp has a big news 5", "Yelp has a big news 6"],
                        ["Facebook has a big news 1", "Facebook has a big news 2", "Facebook has a big news 3", "Facebook has a big news 4", "Facebook has a big news 5", "YeFacebooklp has a big news 6"],
                        ["Netflix has a big news 1", "Netflix has a big news 2", "Netflix has a big news 3", "Netflix has a big news 4", "Netflix has a big news 5", "Netflix has a big news 6"],
                        ["Yahoo has a big news 1", "Yahoo has a big news 2", "Yahoo has a big news 3", "Yahoo has a big news 4", "Yahoo has a big news 5", "Yahoo has a big news 6"],
                        ["Google has a big news 1", "Google has a big news 2", "Google has a big news 3", "Google has a big news 4", "Google has a big news 5", "Google has a big news 6"],
                        ["Indeed has a big news 1", "Indeed has a big news 2", "Indeed has a big news 3", "Indeed has a big news 4", "Indeed has a big news 5", "Indeed has a big news 6"],
                        ["Ritual has a big news 1", "Ritual has a big news 2", "Ritual has a big news 3", "Ritual has a big news 4", "Ritual has a big news 5", "Ritual has a big news 6"],
                        ["Sina has a big news 1", "Sina has a big news 2", "Sina has a big news 3", "Sina has a big news 4", "Sina has a big news 5", "Sina has a big news 6"],
                        ["New York Times has a big news 1", "New York Times has a big news 2", "New York Times has a big news 3", "New York Times has a big news 4", "New York Times has a big news 5", "New York Times has a big news 6"],
                        ["Firefox has a big news 1", "Firefox has a big news 2", "Firefox has a big news 3", "Firefox has a big news 4", "Firefox has a big news 5", "Firefox has a big news 6"],
                        ["Gilt has a big news 1", "Gilt has a big news 2", "Gilt has a big news 3", "Gilt has a big news 4", "Gilt has a big news 5", "Gilt has a big news 6"]]
  
  var parentIndex: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    chainCollectionView.delegate = self
    chainCollectionView.parentCollectionView.register(BaseCardCollectionCell.self,
                                                      forCellWithReuseIdentifier: String(describing: BaseCardCollectionCell.self))
    chainCollectionView.childCollectionView.register(BaseCardCollectionCell.self,
                                                     forCellWithReuseIdentifier: String(describing: BaseCardCollectionCell.self))
    self.navigationController?.navigationBar.isHidden = false
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func loadView() {
    let chainView = ChainPageCollectionView(viewType: .normal)
    chainView.parentCollectionViewItemSize = CGSize(width: 230, height: 300)
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BaseCardCollectionCell.self), for: indexPath)
    if let vCell = cell as? BaseCardCollectionCell {
      vCell.textLabel.text = parentDataSource[indexPath.row]
    }
    return cell
  }
  
  
  func childCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return childDataSouce[parentIndex].count
  }
  
  func childCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BaseCardCollectionCell.self), for: indexPath)
    if let vCell = cell as? BaseCardCollectionCell {
      vCell.textLabel.text = childDataSouce[parentIndex][indexPath.row]
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

