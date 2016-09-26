class AnimationProxy {
  init(with view: AnimatableImage) {
    self.view = view
  }

  class TargetProxy {
    private weak var target: AnimationProxy?

    init(target: AnimationProxy) {
      self.target = target
    }

    @objc func onScreenUpdate() {
      target?.updateFrameIfNeeded()
    }
  }

  func updateFrameIfNeeded() {
    guard let animator = animator else { return }
    animator.shouldChangeFrame(with: displayLink.duration) { hasNewFrame in
      if hasNewFrame { view.layer.setNeedsDisplay() }
    }
  }


  var animator: Animator?
  var displayLinkInitialized: Bool = false
  weak var view: AnimatableImage!

  lazy var displayLink: CADisplayLink = { [unowned self] in
    self.displayLinkInitialized = true
    let display = CADisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
    display.isPaused = true
    return display
  }()

  func prepareForAnimation(withGIFNamed imageName: String) {
    guard let extensionRemoved = imageName.components(separatedBy: ".")[safe: 0],
      let imagePath = Bundle.main.url(forResource: extensionRemoved, withExtension: "gif"),
      let data = try? Data(contentsOf: imagePath) else { return }

    prepareForAnimation(withGIFData: data)
  }

  func prepareForAnimation(withGIFData imageData: Data) {
    view.image = UIImage(data: imageData)
    animator = Animator(data: imageData, size: view.frame.size, contentMode: view.contentMode, framePreloadCount: framePreloadCount)
    animator?.needsPrescaling = needsPrescaling
    animator?.prepareFrames()
    attachDisplayLink()
  }


  var isAnimatingGIF: Bool {
    return !displayLink.isPaused
  }

  var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  public var framePreloadCount = 50

  public var needsPrescaling = false

  func attachDisplayLink() {
    displayLink.add(to: .main, forMode: RunLoopMode.commonModes)
  }

  deinit {
    if displayLinkInitialized {
      displayLink.invalidate()
    }
  }

  public func startAnimatingGIF() {
    if animator?.isAnimatable ?? false {
      displayLink.isPaused = false
    }
  }

  /// Stops the image view animation.
  public func stopAnimatingGIF() {
    displayLink.isPaused = true
  }

  func animate(withGIFNamed imageName: String) {
    prepareForAnimation(withGIFNamed: imageName)
    startAnimatingGIF()
  }

  func animate(withGIFData data: Data) {
    prepareForAnimation(withGIFData: data)
    startAnimatingGIF()
  }

  /// Reset the image view values.
  func prepareForReuse() {
    stopAnimatingGIF()
    animator = nil
  }

  func imageToDisplay() -> UIImage? {
    return animator?.currentFrameImage ?? view.image
  }
}

protocol AnimatableImage: class {
  var animator: AnimationProxy? { get set }
  var image: UIImage? { get set }
  var layer: CALayer { get }
  var frame: CGRect { get set }
  var contentMode: UIViewContentMode { get set }
  func display(_ layer: CALayer)
}

extension AnimatableImage {
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
    prepareForAnimation(withGIFNamed: imageName)
  }

  public func prepareForAnimation(withGIFData imageData: Data) {
    prepareForAnimation(withGIFData: imageData)
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

  /// Stops the image view animation.
  public func stopAnimatingGIF() {
    animator?.stopAnimatingGIF()
  }
}
