/// To enable animated GIF support, you need to extend `UIImageView` or conform your subclass to this protocol.
protocol GIFAnimatable: class {
  var animator: Animator? { get set }
  var image: UIImage? { get set }
  var layer: CALayer { get }
  var frame: CGRect { get set }
  var contentMode: UIViewContentMode { get set }
  func display(_ layer: CALayer)
}

extension GIFAnimatable {
  public var intrinsicContentSize: CGSize {
    return image?.size ?? CGSize.zero
  }

  public func animate(withGIFNamed imageName: String) {
    animator?.animate(withGIFNamed: imageName)
  }

  public var isAnimatingGIF: Bool {
    return animator?.isAnimatingGIF ?? false
  }

  public func prepareForAnimation(withGIFNamed imageName: String) {
    animator?.prepareForAnimation(withGIFNamed: imageName)
  }

  public func prepareForAnimation(withGIFData imageData: Data) {
    animator?.prepareForAnimation(withGIFData: imageData)
  }

  public var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  public func prepareForReuse() {
    animator?.prepareForReuse()
  }

  public func startAnimatingGIF() {
    animator?.startAnimatingGIF()
  }

  public func stopAnimatingGIF() {
    animator?.stopAnimatingGIF()
  }
}
