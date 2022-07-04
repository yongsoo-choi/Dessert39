//
//  UserSoundPages.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/01.
//

import UIKit

class UserSoundPages: UIPageViewController {
    
    var completeHandler : ((Int)->())?
        
    lazy var VCArray: [UIViewController] = {
        return [self.VCInstance(name: "Ask"),
                self.VCInstance(name: "AskList")]
    }()
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    var currentIndex : Int {
        guard let vc = viewControllers?.first else { return 0 }
        return VCArray.firstIndex(of: vc) ?? 0
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        
        if let firstVC = VCArray.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        removeSwipeGesture()
        
    }
    
    func removeSwipeGesture(){
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }

}

extension UserSoundPages: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
        guard let viewControllerIndex = VCArray.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            store.userSoundIndex = VCArray.count - 1
            return VCArray.last
        } else {
            store.userSoundIndex = previousIndex
            return VCArray[previousIndex]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCArray.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex >= VCArray.count {
            store.userSoundIndex = 0
            return VCArray.first
        } else {
            store.userSoundIndex = nextIndex
            return VCArray[nextIndex]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            completeHandler?(currentIndex)
        }
        
    }
    
}
