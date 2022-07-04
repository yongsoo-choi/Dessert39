//
//  StoreInfoCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/08.
//

import UIKit

class StoreInfoCell: UITableViewCell {
    
    @IBOutlet var mapView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var numBox: UIView!{
        didSet{
            numBox.layer.cornerRadius = numBox.frame.height / 2
        }
    }
    @IBOutlet var label_num: UILabel!
    
    var networkUtil = NetworkUtil()
    
    var imageArr: NSArray?
    var total: Int = 0
    var num: Int = 1
    var colorArr = [UIColor.gray, UIColor.blue, UIColor.cyan]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        setCollectionView()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionView() {
        
        let wid = UIScreen.main.bounds.width - 40
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (wid * 335) / 198)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        networkUtil.request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }
    
}

extension StoreInfoCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if imageArr!.count == 0 {
            numBox.isHidden = true
        } else {
            numBox.isHidden = false
            label_num.text = "\(num)/\(imageArr!.count)"
        }
        
        return imageArr!.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreInfoColCell", for: indexPath) as! StoreInfoColCell
        
        if imageArr!.count != 0 {
            
            if let images = imageArr![indexPath.row] as? NSDictionary {
                
                let imgPath = images["imgPath"] as! String
                
                self.loadImage(urlString: imgPath) { image in

                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }

                }
                
            }
            
        }
//        cell.imageView.backgroundColor = colorArr[indexPath.row]
        
        return cell
        
    }
    
}

extension StoreInfoCell: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        num = Int(ceil(x/w)) + 1
        label_num.text = "\(num)/\(imageArr!.count)"
        
    }
    
}

