/**
 * Copyright (c) 2017 Yansong Li
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

/// The layout that can place a card at the left edge of screen.
public class EdgeCardLayout: UICollectionViewFlowLayout {
  
  fileprivate var lastCollectionViewSize: CGSize = CGSize.zero
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  override init() {
    super.init()
    scrollDirection = .horizontal
    minimumLineSpacing = 25
  }
  
  public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    super.invalidateLayout(with: context)
    
    guard let collectionView = collectionView else { return }
    
    if collectionView.bounds.size != lastCollectionViewSize {
      configureInset()
      lastCollectionViewSize = collectionView.bounds.size
    }
  }
  
  public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                           withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else {
      return proposedContentOffset
    }
    
    let proposedRect = CGRect(x: proposedContentOffset.x,
                              y: 0,
                              width: collectionView.bounds.width,
                              height: collectionView.bounds.height)
    guard var layoutAttributes = layoutAttributesForElements(in: proposedRect) else {
      return proposedContentOffset
    }
    
    layoutAttributes = layoutAttributes.sorted { $0.frame.origin.x < $1.frame.origin.x }
    let leftMostAttribute = layoutAttributes[0]
    
    if leftMostAttribute.frame.origin.x > proposedContentOffset.x {
      return CGPoint(x: leftMostAttribute.frame.origin.x - minimumLineSpacing,
                     y: proposedContentOffset.y)
    }
    
    if velocity.x > 0 {
      if fabs(leftMostAttribute.frame.origin.x - proposedContentOffset.x) > (itemSize.width / 2)
        || velocity.x > 0.3 {
        return CGPoint(x: leftMostAttribute.frame.maxX, y: proposedContentOffset.y)
      } else {
        return CGPoint(x: leftMostAttribute.frame.origin.x - minimumLineSpacing,
                       y: proposedContentOffset.y)
      }
    }
    if velocity.x < 0 {
      if fabs(leftMostAttribute.frame.origin.x - proposedContentOffset.x) <= (itemSize.width / 2)
        || velocity.x < -0.3 {
        return CGPoint(x: leftMostAttribute.frame.origin.x - minimumLineSpacing,
                       y: proposedContentOffset.y)
      } else {
        return CGPoint(x: leftMostAttribute.frame.maxX, y: proposedContentOffset.y)
      }
    }

    return proposedContentOffset
  }
}

// MARK: helpers

extension EdgeCardLayout {
  
  fileprivate func configureInset() -> Void {
    guard let collectionView = collectionView else {
      return
    }
    let inset = minimumLineSpacing
    collectionView.contentInset  = UIEdgeInsetsMake(0, inset, 0, inset)
    collectionView.contentOffset = CGPoint(x: -inset, y: 0)
  }
}

