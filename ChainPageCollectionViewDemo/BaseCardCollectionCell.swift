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

/// The base card collection cell.
open class BaseCardCollectionCell: UICollectionViewCell {

  open var textLabel: UILabel!

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.cornerRadius = 6.0
    textLabel = UILabel()
    textLabel.numberOfLines = 0
    textLabel.layer.cornerRadius = 6.0
    textLabel.clipsToBounds = true
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.textAlignment = .center
    textLabel.textColor = UIColor.white
    textLabel.font = UIFont.systemFont(ofSize: 18.0)
    self.addSubview(textLabel)
    textLabel.backgroundColor = UIColor.randomColor()
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
  }
}
