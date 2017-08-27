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

private let defaultParentChildRatio: CGFloat = 3 / 4
private var defaultParentCellVerticalPadding: CGFloat = 50
private var defaultParentCellWidthHeightRatio: CGFloat = 3 / 4
private var defaultChildCellVerticalPadding: CGFloat = 12
private var defaultChildCellWidthHeightRatio: CGFloat = 3 / 4
private let defaultFadeOutDuration: TimeInterval = 0.2
private let defaultFadeInDuration: TimeInterval = 0.2

public enum ChainPageCollectionViewType {

  /// normal type splits the height to 3 : 1
  case normal

  /// customParentHeight type will splits the screen to custom ratio.
  case customParentHeight(Int, Int)

  func viewHeightRatio() -> CGFloat {
    switch self {
    case .normal:
      return defaultParentChildRatio
    case let .customParentHeight(pInt, cInt):
      guard pInt > 0, cInt > 0 else {
        return defaultParentChildRatio
      }
      let total = CGFloat(pInt + cInt)
      return CGFloat(pInt) / total
    }
  }
}

public enum ChainPageChildAnimationType {
  case slideOutSlideIn
  case shrinkOutExpandIn
}

fileprivate enum ChildAnimationState {
  case initial
  case fadeOutChild
  case fadeOutComplete
  case fadeInChild
  indirect case toProcess(ChildAnimationState, ChildAnimationState)
}

/// The view which contains chained collectionViews.
/// The change of parent view can reload its child collectionView.
open class ChainPageCollectionView: UIView {
  
  /// The parent collection view.
  public var parentCollectionView: UICollectionView!

  /// The child collection view.
  public var childCollectionView: UICollectionView!
  
  public var parentCollectionViewItemSize: CGSize = .zero
  
  public var childCollectionViewItemSize: CGSize = .zero

  public var childAnimationType: ChainPageChildAnimationType
  
  public weak var delegate: ChainPageCollectionViewProtocol?
  
  fileprivate var parentIndexChangeDuringFadeIn: Bool = false
  
  fileprivate var preprocessBeforeChildCollectionViewReload: (()->())?
  
  fileprivate var lastTimeViewHeight: CGFloat = 0.0
  
  fileprivate let viewType: ChainPageCollectionViewType
  
  fileprivate var state: ChildAnimationState = .initial
  
  /// The selection index of parentCollectionView.
  public var parentCollectionViewIndex: Int = 0 {
    didSet {
      if parentCollectionViewIndex == oldValue {
        return
      }
      delegate?.childCollectionView(childCollectionView,
                                    parentCollectionViewIndex: parentCollectionViewIndex)
      self <= .fadeOutChild
    }
  }
  
  public var childCollectionViewDataReady: Bool = false {
    didSet {
      // NOTE: Whenever user of this view sets this field to `true`, it means new data has come
      // we need to update UI according to current state.
      if childCollectionViewDataReady {
        switch self.state {
        case .initial:
          self <= .fadeOutChild
        case .fadeInChild:
          self <= .fadeOutChild
        case .fadeOutComplete:
          self <= .fadeInChild
        default:
          break
        }
      }
    }
  }

  public init(viewType: ChainPageCollectionViewType,
              parentCollectionViewLayout: UICollectionViewFlowLayout = CentralCardLayout(scaled: true),
              childCollectionViewLayout: UICollectionViewFlowLayout = EdgeCardLayout(),
              childAnimationType: ChainPageChildAnimationType = .slideOutSlideIn) {
    self.viewType = viewType
    self.childAnimationType = childAnimationType

    parentCollectionView =
        UICollectionView(frame: .zero,
                         collectionViewLayout: parentCollectionViewLayout)
    parentCollectionView.backgroundColor = .clear
    parentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast

    let childCollectionViewLayout = childCollectionViewLayout
    childCollectionViewLayout.scrollDirection = .horizontal
    childCollectionViewLayout.minimumLineSpacing = 16
    childCollectionView = UICollectionView(frame: .zero,
                                           collectionViewLayout: childCollectionViewLayout)
    childCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    childCollectionView.backgroundColor = .clear

    super.init(frame: .zero)
    parentCollectionView.translatesAutoresizingMaskIntoConstraints = false
    childCollectionView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(parentCollectionView)
    addSubview(childCollectionView)
    parentCollectionView.dataSource = self
    parentCollectionView.delegate = self
    childCollectionView.dataSource = self
    childCollectionView.delegate = self
    buildConstraints()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    let viewHeight = bounds.size.height
    if viewHeight != lastTimeViewHeight {
      lastTimeViewHeight = bounds.size.height
      let parentHeightRatio = viewType.viewHeightRatio()
      
      // Adjust parentCollectionViewItemSize.
      var validParentItemSize: CGSize = .zero
      if (parentCollectionViewItemSize == .zero ||
        parentCollectionViewItemSize.height > viewHeight * parentHeightRatio) {
        let parentItemHeight = viewHeight * parentHeightRatio - 2 * defaultParentCellVerticalPadding
        validParentItemSize =
            CGSize(width: parentItemHeight * defaultParentCellWidthHeightRatio,
                   height: parentItemHeight)
      } else {
        // Restore user's setting. e.g: Rotate to horizontal then rotate back.
        validParentItemSize = parentCollectionViewItemSize
      }
      if let parentLayout = parentCollectionView.collectionViewLayout as? CentralCardLayout {
        parentLayout.itemSize = validParentItemSize
      }
      
      // Adjust childCollectionViewItemSize.
      var validChildItemSize: CGSize = .zero
      if childCollectionViewItemSize == .zero ||
        childCollectionViewItemSize.height > viewHeight * (1 - parentHeightRatio) {
        let childItemHeight =
            viewHeight * (1 - parentHeightRatio) - 2 * defaultChildCellVerticalPadding
        validChildItemSize = CGSize(width: childItemHeight * defaultChildCellWidthHeightRatio,
                                    height: childItemHeight)
      } else {
        validChildItemSize = childCollectionViewItemSize
      }
      if let childLayout = childCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        childLayout.itemSize = validChildItemSize
      }
    }
  }
}

// MARK: - Helpers

extension ChainPageCollectionView {
  fileprivate static func <=(left: ChainPageCollectionView, right: ChildAnimationState) {
    switch (left.state, right) {
    
    case (.initial, .fadeOutChild):
      left.state = .fadeOutChild
      left.childCollectionView.isUserInteractionEnabled = false
      left.childCollectionViewFadeOut()
      
    case (.fadeOutChild, .fadeOutComplete):
      left.state = .fadeOutComplete
    
    case (.fadeOutComplete, .fadeInChild):
      if left.childCollectionViewDataReady {
        left.state = .fadeInChild
        left.childCollectionViewReload()
      }
    
    case (.fadeInChild, .fadeOutChild):
      left.state = .toProcess(.fadeInChild, .fadeOutChild)
      left.parentIndexChangeDuringFadeIn = true
      
    case let(.toProcess(originalState, nextState), .initial):
      left.state = originalState
      left <= .initial
      left <= nextState
      
    case (.fadeInChild, .initial):
      left.state = .initial
      left.childCollectionView.isUserInteractionEnabled = true
      if left.parentIndexChangeDuringFadeIn {
        left.parentIndexChangeDuringFadeIn = false
      } else {
        left.childCollectionViewDataReady = false
      }
      left.preprocessBeforeChildCollectionViewReload = nil
    
    default:
      break
    }
  }
  
  func childCollectionViewFadeOut() {
    /// Animate out currently child collection view cells.
    addChildCollectionViewFadeOutAnimation() { finish in
      self <= .fadeOutComplete
      self <= .fadeInChild
    }
  }
  
  public func childCollectionViewReload() {
    preprocessBeforeChildCollectionViewReload?()
    self.childCollectionView.reloadData()
    if let childCollectionViewLayout =
      self.childCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      self.childCollectionView.contentOffset =
        CGPoint(x: -childCollectionViewLayout.minimumLineSpacing, y: 0)
    }
    // NOTE: Add a little delay to let childCollectionView/layout updates its data.
    DispatchQueue.main.async{
      self.addChildCollectionViewFadeInAnimation() { finish in
        self <= .initial
      }
    }
  }
  
  func addChildCollectionViewFadeOutAnimation(completionBlock: ((Bool)->())? = nil) {
    let indexPaths = childCollectionView.indexPathsForVisibleItems.sorted { $0.row < $1.row }
    var restoreCellBlocks: [() -> ()] = []
    
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      // NOTE: Since we are always using childCollectionView and we changed
      // cell's metrics manually, we should restore cell metrics to avoid
      // incorrect cell state when dequeued.
      self.preprocessBeforeChildCollectionViewReload = {
        restoreCellBlocks.forEach { $0() }
      }
      completionBlock?(true)
    }
    for (i, index) in indexPaths.enumerated() {
      if let cell = self.childCollectionView.cellForItem(at: index) {
        var animationBlock: ()->() = {}
        var restoreBlock: ()->() = {}
        switch self.childAnimationType {
        case .slideOutSlideIn:
          let originalFrame = cell.frame
          animationBlock = {
            var newFrame = cell.frame
            newFrame.origin.y =
              self.childCollectionView.frame.size.height
            cell.frame = newFrame
            cell.alpha = 0.0
          }
          restoreBlock = {
            cell.frame = originalFrame
            cell.alpha = 1.0
          }
        case .shrinkOutExpandIn:
          animationBlock = {
            cell.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            cell.alpha = 0.0
          }
          restoreBlock = {
            cell.transform = .identity
            cell.alpha = 1.0
          }
        }
        restoreCellBlocks.append(restoreBlock)
        UIView.animate(withDuration: defaultFadeOutDuration,
                       delay: Double(i)*0.1,
                       options: [],
                       animations: animationBlock,
                       completion: nil)
      }
    }
    CATransaction.commit()
  }
  
  func addChildCollectionViewFadeInAnimation(completionBlock: ((Bool)->())? = nil) {
    let indexPaths = self.childCollectionViewFadeInCellIndexes()
    CATransaction.begin()
    CATransaction.setCompletionBlock { 
      completionBlock?(true)
    }
    for (i, indexPath) in indexPaths.enumerated() {
      if let cell = self.childCollectionView.cellForItem(at: indexPath) {
        var animationBlock: ()->() = {}
        switch self.childAnimationType {
        case .slideOutSlideIn:
          var newFrame = cell.frame
          newFrame.origin.y = self.childCollectionView.frame.size.height
          cell.frame = newFrame
          animationBlock = {
            newFrame.origin.y = defaultChildCellVerticalPadding
            cell.frame = newFrame
            cell.alpha = 1.0
          }
        case .shrinkOutExpandIn:
          cell.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
          animationBlock = {
            cell.transform = .identity
            cell.alpha = 1.0
          }
        }
        UIView.animate(withDuration: defaultFadeInDuration,
                       delay: Double(i)*0.17,
                       options: [],
                       animations: animationBlock,
                       completion: nil)
      }
    }
    CATransaction.commit()
  }
}

extension ChainPageCollectionView {
  func buildConstraints() {
    parentCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    parentCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    parentCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    parentCollectionView.heightAnchor.constraint(equalTo: heightAnchor,
                                                 multiplier: viewType.viewHeightRatio()).isActive = true
    childCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    childCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    childCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    childCollectionView.topAnchor.constraint(equalTo: parentCollectionView.bottomAnchor).isActive = true
  }
  
  func childCollectionViewFadeInCellIndexes() -> [IndexPath] {
    guard let layout = childCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
      return []
    }
    let visibleCellsCount =
      Int(ceil((childCollectionView.frame.size.width - childCollectionView.contentInset.left) /
        (layout.itemSize.width + layout.minimumLineSpacing)))
    
    var indexPaths: [IndexPath] = []
    for i in 0..<visibleCellsCount {
      indexPaths.append(IndexPath(row: i, section: 0))
    }
    return indexPaths
  }
}

// MARK: - Protocol
// MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension ChainPageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {

  public func collectionView(_ collectionView: UICollectionView,
                             numberOfItemsInSection section: Int) -> Int {
    guard let validDelegate = delegate else {
      assert(false, "Need delegate!")
      return 0
    }
    if collectionView == parentCollectionView {
      return validDelegate.parentCollectionView(parentCollectionView, numberOfItemsInSection: section)
    } else {
      return validDelegate.childCollectionView(childCollectionView, numberOfItemsInSection: section)
    }
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    // NOT support multiple sections.
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let validDelegate = delegate else {
      assert(false, "Need delegate!")
      return UICollectionViewCell()
    }
    if collectionView == parentCollectionView {
      return validDelegate.parentCollectionView(parentCollectionView, cellForItemAt: indexPath)
    } else {
      return validDelegate.childCollectionView(childCollectionView, cellForItemAt: indexPath)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             canMoveItemAt indexPath: IndexPath)-> Bool {
    guard let validDelegate = delegate else {
      assert(false, "Need delegate!")
      return true
    }
    if collectionView == parentCollectionView,
      let result = validDelegate.parentCollectionView?(parentCollectionView,
                                                       canMoveItemAt: indexPath) {
      return result
    } else if collectionView == childCollectionView,
      let result = validDelegate.childCollectionView?(childCollectionView,
                                                      canMoveItemAt: indexPath) {
      return result
    }
    return true
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             moveItemAt sourceIndexPath: IndexPath,
                             to destinationIndexPath: IndexPath) {
    guard let validDelegate = delegate else {
      assert(false, "Need delegate!")
      return
    }
    if collectionView == parentCollectionView {
      validDelegate.parentCollectionView?(parentCollectionView,
                                          moveItemAt: sourceIndexPath,
                                          to: destinationIndexPath)
    } else if collectionView == childCollectionView {
      validDelegate.parentCollectionView?(parentCollectionView,
                                          moveItemAt: sourceIndexPath,
                                          to: destinationIndexPath)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath) {
    guard let validDelegate = delegate else {
      assert(false, "Need delegate!")
      return
    }
    if collectionView == parentCollectionView {
      print("Will display cell:\(cell)")
      validDelegate.parentCollectionView?(parentCollectionView, willDisplay: cell,
                                          forItemAt: indexPath)
    } else {
      let animatedIndexPaths = childCollectionViewFadeInCellIndexes()
      // NOTE: During animation, only change those animated cell's alpha to 0.0
      switch self.state {
      case .fadeInChild:
        if animatedIndexPaths.contains(indexPath) {
          cell.alpha = 0.0
        }
      default:
        break
      }
      validDelegate.childCollectionView?(childCollectionView, willDisplay: cell,
                                         forItemAt: indexPath)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath) {
    guard let validDelegate = delegate else {
      assert(false, "Need delegate!")
      return
    }
    if collectionView == parentCollectionView {
      validDelegate.parentCollectionView?(parentCollectionView, didSelectItemAt: indexPath)
    } else if collectionView == childCollectionView {
      validDelegate.childCollectionView?(childCollectionView, didSelectItemAt: indexPath)
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let collectionView = scrollView as? UICollectionView,
      collectionView == parentCollectionView,
      let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }
    let initialOffset = (collectionView.bounds.size.width - layout.itemSize.width) / 2
    let currentItemCentralX =
        collectionView.contentOffset.x + initialOffset + layout.itemSize.width / 2
    let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
    parentCollectionViewIndex = Int(currentItemCentralX / pageWidth)
  }
}
