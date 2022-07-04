//
//  CardCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/28.
//

import UIKit

protocol cameraDelegate {
    func selectedCamera()
    func selectedImage(sect: Int, row: Int)
}

class CardCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var lastIndex: Bool = false
    var indexPathRow: Int?
    var cards: NSArray?
    var delegate: cameraDelegate?
    
    var networkUtil = NetworkUtil()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setCollectionView()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionView() {
        
        let wid = UIScreen.main.bounds.width / 1.8 - 15
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (wid * 128) / 205)
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        
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

extension CardCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if lastIndex {
            return 1
        } else {
            return cards!.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardImageCell", for: indexPath) as! CardImageCell
        cell.imageView.layer.cornerRadius = 10
        
        if lastIndex {
            cell.imageView.image = UIImage(named: "customCard")
        } else {
            
            let obj = self.cards![indexPath.row] as! NSDictionary
            let cardPath = obj["cardPath"] as! String
            
            self.loadImage(urlString: cardPath) { image in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }

            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if lastIndex {
            if let delegate = delegate {
                delegate.selectedCamera()
            }
        } else {
            delegate?.selectedImage(sect: indexPathRow!, row: indexPath.row)
        }
        
    }
    
}
