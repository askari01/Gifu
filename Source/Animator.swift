class Animator {
  public var framePreloadCount = 50
  public var needsPrescaling = false
  var frameStore: FrameStore?
  var displayLinkInitialized: Bool = false
  weak var view: GIFAnimatable!

  lazy var displayLink: CADisplayLink = { [unowned self] in
    self.displayLinkInitialized = true
    let display = CADisplayLink(target: DisplayLinkProxy(target: self), selector: #selector(DisplayLinkProxy.onScreenUpdate))
    display.isPaused = true
    return display
  }()

  var isAnimatingGIF: Bool {
    return !displayLink.isPaused
  }

  var frameCount: Int {
    return frameStore?.frameCount ?? 0
  }

  init(with view: GIFAnimatable) {
    self.view = view
  }

  func updateFrameIfNeeded() {
    guard let animator = frameStore else { return }
    animator.shouldChangeFrame(with: displayLink.duration) { hasNewFrame in
      if hasNewFrame { view.layer.setNeedsDisplay() }
    }
  }

  func prepareForAnimation(withGIFNamed imageName: String) {
    guard let extensionRemoved = imageName.components(separatedBy: ".")[safe: 0],
      let imagePath = Bundle.main.url(forResource: extensionRemoved, withExtension: "gif"),
      let data = try? Data(contentsOf: imagePath) else { return }

    prepareForAnimation(withGIFData: data)
  }

  func prepareForAnimation(withGIFData imageData: Data) {
    view.image = UIImage(data: imageData)
    frameStore = FrameStore(data: imageData, size: view.frame.size, contentMode: view.contentMode, framePreloadCount: framePreloadCount)
    frameStore?.needsPrescaling = needsPrescaling
    frameStore?.prepareFrames()
    attachDisplayLink()
  }

  func attachDisplayLink() {
    displayLink.add(to: .main, forMode: RunLoopMode.commonModes)
  }

  deinit {
    if displayLinkInitialized {
      displayLink.invalidate()
    }
  }

  public func startAnimatingGIF() {
    if frameStore?.isAnimatable ?? false {
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

  func prepareForReuse() {
    stopAnimatingGIF()
    frameStore = nil
  }

  func imageToDisplay() -> UIImage? {
    return frameStore?.currentFrameImage ?? view.image
  }
}

class DisplayLinkProxy {
  private weak var target: Animator?
  init(target: Animator) { self.target = target }
  @objc func onScreenUpdate() { target?.updateFrameIfNeeded() }
}
