//
//  ImageCardCollectionCell.swift
//  ChainPageCollectionView
//
//  Created by yansong li on 2017-07-23.
//  Copyright © 2017 yansong li. All rights reserved.
//

import UIKit

/// The base card collection cell.
public class ImageCardCollectionViewCell: UICollectionViewCell {
  
  public var textLabel: UILabel!
  
  public var backGroundImageView: UIImageView!
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.cornerRadius = 6.0
    self.clipsToBounds = true
    textLabel = UILabel()
    textLabel.numberOfLines = 0
    textLabel.clipsToBounds = true
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.textAlignment = .center
    textLabel.textColor = UIColor.white
    textLabel.font = UIFont.systemFont(ofSize: 30.0)
    backGroundImageView = UIImageView()
    backGroundImageView.contentMode = .scaleAspectFill
    backGroundImageView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(backGroundImageView)
    self.addSubview(textLabel)
    buildConstraint()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func buildConstraint() {
    textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    textLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    backGroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    backGroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    backGroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    backGroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
  }
}

