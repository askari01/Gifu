import UIKit

public class AnimatableImageView: UIImageView, AnimatableImage {
  var animator: AnimationProxy?

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animator = AnimationProxy(with: self)
  }

  public override func display(_ layer: CALayer) {
    image = animator?.imageToDisplay()
  }
}
