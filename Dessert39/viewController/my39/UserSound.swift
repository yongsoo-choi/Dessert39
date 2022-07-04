//
//  UserSound.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/01.
//

import UIKit

class UserSound: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    private let items: [String] = ["문의하기", "문의내역"]
    var currentIndex : Int = 0 {
        didSet{
            changeBtn()
        }
    }
    var pageViewController : UserSoundPages!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "고객의소리")
        navigationController?.isNavigationBarHidden = false
        
        setupCollectionView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PageViewController" {
            guard let vc = segue.destination as? UserSoundPages else {return}
            pageViewController = vc
            
            pageViewController.completeHandler = { (result) in
                self.currentIndex = result
            }
            
        }
        
    }
    
    private func setupCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = 22
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 5, left: 16, bottom: 0, right: 16)
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(OrderMenuCell.self, forCellWithReuseIdentifier: "OrderMenuCell")
        
        collectionView.layer.masksToBounds = false
        collectionView.layer.shadowColor = UIColor.gray.cgColor
        collectionView.layer.shadowOpacity = 0.1
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowRadius = 2
        
    }
    
    func changeBtn() {
        
        for index in 0..<items.count {
            let cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))
            cell?.isSelected = false
            
            if index == currentIndex {
                cell?.isSelected = true
            }
            
            collectionView.selectItem(at: IndexPath(row: currentIndex, section: 0), animated: true, scrollPosition: .init(rawValue: 100))
        }
        
    }
    
}


extension UserSound: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if currentIndex < indexPath.row {
            pageViewController.setViewControllers([pageViewController.VCArray[indexPath.row]], direction: .forward, animated: true, completion: nil)
        } else {
            pageViewController.setViewControllers([pageViewController.VCArray[indexPath.row]], direction: .reverse, animated: true, completion: nil)
        }
        currentIndex = indexPath.row
        store.userSoundIndex = currentIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderMenuCell", for: indexPath) as! OrderMenuCell
        cell.configure(name: items[indexPath.item])
        
        if indexPath.item == currentIndex {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
        } else {
            cell.isSelected = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return OrderMenuCell.fittingSize(availableHeight: 25, name: items[indexPath.item])
    }
    
}
