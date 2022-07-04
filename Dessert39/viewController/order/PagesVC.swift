//
//  PagesVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/05.
//

import UIKit

class PagesVC: UIPageViewController {
    
    var completeHandler : ((Int)->())?
        
    lazy var VCArray: [UIViewController] = {
        return [self.VCInstance(name: "RecommendVC"),
                self.VCInstance(name: "DessertVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuDefaultVC"),
                self.VCInstance(name: "MenuBookmark")]
    }()
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Order", bundle: nil).instantiateViewController(identifier: name)
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

extension PagesVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
        guard let viewControllerIndex = VCArray.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            store.orderIndex = VCArray.count - 1
            return VCArray.last
        } else {
            store.orderIndex = previousIndex
            return VCArray[previousIndex]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCArray.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex >= VCArray.count {
            store.orderIndex = 0
            return VCArray.first
        } else {
            store.orderIndex = nextIndex
            return VCArray[nextIndex]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            DispatchQueue.main.async {

                self.completeHandler?(self.currentIndex)

            }
            
        }
        
    }
    
}

