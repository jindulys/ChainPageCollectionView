<h3 align="center">
    <img src="Images/chainpageview.png" width=540/>
</h3>

# PageKit
A custom View with fancy collectionView animation

## Demo

<img src="https://raw.githubusercontent.com/jindulys/ChainPageCollectionView/master/Images/latest.gif" alt="Demo" title="Demo" width="330"/>         <img src="https://raw.githubusercontent.com/jindulys/ChainPageCollectionView/master/Images/shrink.gif" alt="Demo" title="Demo" width="330"/>

## Requirements

- iOS 9.0+
- Xcode 8

## Installation

### CocoaPods

Update your Podfile to include the following:

```ruby
pod 'ChainPageCollectionView', '~> 1.0'
```
Run `pod install`.

NOTE: If you can not find the pod target. Please follow: https://stackoverflow.com/questions/31065447/no-such-module-when-i-use-cocoapods to build your pod target.

## Usage

### Basic Usage

```swift
import ChainPageCollectionView
```

1. Create ChainPageCollectionView
```swift
// chainView is this view controller's property.
chainView = ChainPageCollectionView(viewType: .normal)
chainView.delegate = self
```
2. Register cells for `parentCollectionView` and `childCollectionView`
```swift
chainView.parentCollectionView.register(#cellType, forCellWithReuseIdentifier:#cellIdentifier)
chainView.childCollectionView.register(#cellType, forCellWithReuseIdentifier:#cellIdentifier)
```

3. Implement `ChainPageCollectionViewProtocol`
```swift
func parentCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  // return your parent data source count.
}

func parenCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  // Dequeue and configure your parent collectionview cell
}

func childCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  // return your child data source count.
}

func childCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  // Dequeue and configure your child collectionview cell
}
```

4. Update child collection view data source when parent index has changed.
```swift
// You will get notified by following protocol method.
func childCollectionView(_ collectionView: UICollectionView, parentCollectionViewIndex: Int) {
  // When parent collection view scrolls, this will get called when it stops with new parent collectionview's index.
  // You can use this message as a trigger to fetch related child collection view's information.
  
  // Once you have the latest child collection view's data, set `childCollectionViewDataReady` to `true`.
  // NOTE: This is important to be set, otherwise your child collection view propably will not show up again.
  chainView.childCollectionViewDataReady = true
}
```

### Customization

#### Layout

You can customize the layout objects used by `parentCollectionView` and `childCollectionView` by
```swift
let chainView = ChainPageCollectionView(viewType: .normal, 
                                        parentColectionViewLayout: #yourlayout, 
                                        childCollectionViewLayout: #yourlayout)
```
#### ItemSize

You can use `parentCollectionViewItemSize` and `childCollectionViewItemSize` to set the desired itemSize.

#### Screen Ratio

The default behaviour of this view is that parent collection view will take 3/4 of this view's height and child collection view takes the rest. You can set `viewType` to a customized ration with type `customParentHeight(#SomeInt, #SomeInt)`

## License

Expanding collection is released under the MIT license.
See [LICENSE](./LICENSE) for details.


