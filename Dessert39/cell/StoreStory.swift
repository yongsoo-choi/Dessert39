//
//  StoreStory.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/08.
//

import UIKit

class StoreStory: UITableViewCell {

    @IBOutlet var warpView: UIView!{
        didSet{
            warpView.layer.borderWidth = 1
            warpView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            warpView.layer.cornerRadius = 5
        }
    }
    @IBOutlet var innerView: UIView!{
        didSet{
            innerView.layer.cornerRadius = 5
            innerView.clipsToBounds = true
            innerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet var numBox: UIView!{
        didSet{
            numBox.layer.cornerRadius = numBox.frame.height / 2
        }
    }
    
    @IBOutlet var label_num: UILabel!
    @IBOutlet var image_profile: UIImageView!
    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_date: UILabel!
    @IBOutlet var label_content: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var total: Int = 0
    var num: Int = 1
    var colorArr = [UIColor.gray, UIColor.blue, UIColor.cyan]
    var imgArr: NSArray?
    
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
        
        let wid = UIScreen.main.bounds.width - 60
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (wid * 335) / 160)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        NetworkUtil().request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }

}

extension StoreStory: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.imgArr != nil {
            total  = self.imgArr!.count
        }
        
        if total == 0 {
            numBox.isHidden = true
        } else {
            numBox.isHidden = false
            label_num.text = "\(num)/\(total)"
        }
        
        return total
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreStoryColCell", for: indexPath) as! StoreStoryColCell
        let obj = self.imgArr![indexPath.row] as! NSDictionary
        let imgPath = obj["imgPath"] as! String
        
        self.loadImage(urlString: imgPath) { image in

            DispatchQueue.main.async {
                cell.imageView.image = image
            }

        }
        
        return cell
        
    }
    
}

extension StoreStory: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        num = Int(ceil(x/w)) + 1
        label_num.text = "\(num)/\(total)"
        
    }
    
}
