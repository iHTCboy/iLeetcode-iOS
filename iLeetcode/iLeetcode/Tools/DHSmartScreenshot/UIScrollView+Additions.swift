//
// rfe: https://github.com/davidman/DHSmartScreenshot

import Foundation
import UIKit

extension UIScrollView {
    
    var screenshotOfVisibleContent : UIImage? {
        var croppingRect = self.bounds
        croppingRect.origin = self.contentOffset
        return self.screenshotForCroppingRect(croppingRect: croppingRect)
    }
    
    var screenshotImage : UIImage? {
        let image: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.contentSize, false, 0.0)
        
        //先保存原始的格式
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        //移设置为零
        self.contentOffset = CGPoint.zero
        //设置大小
        self.frame = CGRect.init(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
            
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        
    
        self.contentOffset = savedContentOffset
        self.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        if (image != nil) {
            return image
        }
        return nil
    }
    
    // rfe: https://juejin.im/post/5b9d145ae51d450e7579d1e5
    public func takeScreenshotOfFullContent(_ completion: @escaping ((UIImage?) -> Void)) {
        // 分页绘制内容到ImageContext
        let originalOffset = self.contentOffset

        // 当contentSize.height<bounds.height时，保证至少有1页的内容绘制
        var pageNum = 1
        if self.contentSize.height > self.bounds.height {
            pageNum = Int(floorf(Float(self.contentSize.height / self.bounds.height)))
        }

        let backgroundColor = self.backgroundColor ?? UIColor.white

        UIGraphicsBeginImageContextWithOptions(self.contentSize, true, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil)
            return
        }
        context.setFillColor(backgroundColor.cgColor)
        context.setStrokeColor(backgroundColor.cgColor)

        self.drawScreenshotOfPageContent(0, maxIndex: pageNum) {
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.contentOffset = originalOffset
            completion(image)
        }
    }

    fileprivate func drawScreenshotOfPageContent(_ index: Int, maxIndex: Int, completion: @escaping () -> Void) {

        self.setContentOffset(CGPoint(x: 0, y: CGFloat(index) * self.frame.size.height), animated: false)
        let pageFrame = CGRect(x: 0, y: CGFloat(index) * self.frame.size.height, width: self.bounds.size.width, height: self.bounds.size.height)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.drawHierarchy(in: pageFrame, afterScreenUpdates: true)

            if index < maxIndex {
                self.drawScreenshotOfPageContent(index + 1, maxIndex: maxIndex, completion: completion)
            }else{
                completion()
            }
        }
    }

}
