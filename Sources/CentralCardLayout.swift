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

/// The layout that can place a card at the central of the screen.
public class CentralCardLayout: UICollectionViewFlowLayout {

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
    guard let layoutAttributes = layoutAttributesForElements(in: proposedRect) else {
      return proposedContentOffset
    }

    var shouldBeChosenAttributes: UICollectionViewLayoutAttributes?
    var shouldBeChosenIndex: Int = -1

    let proposedCenterX = proposedRect.midX
    
    for (i, attributes) in layoutAttributes.enumerated() {
      guard attributes .representedElementCategory == .cell else {
        continue
      }
      guard let currentChosenAttributes = shouldBeChosenAttributes else {
        shouldBeChosenAttributes = attributes
        shouldBeChosenIndex = i
        continue
      }
      if (fabs(attributes.frame.midX - proposedCenterX) < fabs(currentChosenAttributes.frame.midX - proposedCenterX)) {
        shouldBeChosenAttributes = attributes
        shouldBeChosenIndex = i
      }
    }
    // Adjust the case where a quick but small scroll occurs.
    if (fabs(collectionView.contentOffset.x - proposedContentOffset.x) < itemSize.width) {
      if velocity.x < -0.3 {
        shouldBeChosenIndex = shouldBeChosenIndex > 0 ? shouldBeChosenIndex - 1 : shouldBeChosenIndex
      } else if velocity.x > 0.3 {
        shouldBeChosenIndex = shouldBeChosenIndex < layoutAttributes.count - 1 ?
          shouldBeChosenIndex + 1 : shouldBeChosenIndex
      }
      shouldBeChosenAttributes = layoutAttributes[shouldBeChosenIndex]
    }
    guard let finalAttributes = shouldBeChosenAttributes else {
      return proposedContentOffset
    }
    return CGPoint(x: finalAttributes.frame.midX - collectionView.bounds.size.width / 2,
                   y: proposedContentOffset.y)
  }
}

// MARK: helpers

extension CentralCardLayout {
  
  fileprivate func configureInset() -> Void {
    guard let collectionView = collectionView else {
      return
    }
    let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2
    collectionView.contentInset  = UIEdgeInsetsMake(0, inset, 0, inset)
    collectionView.contentOffset = CGPoint(x: -inset, y: 0)
  }
}
