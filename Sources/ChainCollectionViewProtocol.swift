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

/// The protocol of ChainCollectionView.
@objc public protocol ChainCollectionViewProtocol: UICollectionViewDelegate {
  
  func parentCollectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int
  
  func parentCollectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  
  @objc optional func parentCollectionView(_ collectionView: UICollectionView,
                                           willDisplay cell: UICollectionViewCell,
                                           forItemAt indexPath: IndexPath)
  
  @objc optional func parentCollectionView(_ collectionView: UICollectionView,
                                           canMoveItemAt indexPath: IndexPath) -> Bool
  
  @objc optional func parentCollectionView(_ collectionView: UICollectionView,
                                           moveItemAt sourceIndexPath: IndexPath,
                                           to destinationIndexPath: IndexPath)
  
  @objc optional func parentCollectionView(_ collectionView: UICollectionView,
                                           didSelectItemAt indexPath: IndexPath)
  
  func childCollectionView(_ collectionView: UICollectionView,
                           numberOfItemsInSection section: Int) -> Int
  
  func childCollectionView(_ collectionView: UICollectionView,
                           cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  
  @objc optional func childCollectionView(_ collectionView: UICollectionView,
                                          didSelectItemAt indexPath: IndexPath)
  
  @objc optional func childCollectionView(_ collectionView: UICollectionView,
                                          willDisplay cell: UICollectionViewCell,
                                          forItemAt indexPath: IndexPath)
  
  @objc optional func childCollectionView(_ collectionView: UICollectionView,
                                          canMoveItemAt indexPath: IndexPath) -> Bool
  
  @objc optional func childCollectionView(_ collectionView: UICollectionView,
                                          moveItemAt sourceIndexPath: IndexPath,
                                          to destinationIndexPath: IndexPath)
  
  /// Let childCollectionView reload data with current parent collection view index.
  func childCollectionView(_ collectionView: UICollectionView, parenCollectionViewIndex: Int)
}
