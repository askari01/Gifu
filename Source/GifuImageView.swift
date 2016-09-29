import UIKit

public class GifuImageView: UIImageView, GIFAnimatable {
  var animator: Animator?

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animator = Animator(with: self)
  }

  public override func display(_ layer: CALayer) {
    image = animator?.imageToDisplay()
  }
}
