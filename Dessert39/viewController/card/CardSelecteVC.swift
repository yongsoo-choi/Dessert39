//
//  CardSelecteVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/28.
//

import UIKit
import PhotosUI
import AVFoundation
import Alamofire

class CardSelecteVC: UIViewController {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var selectedTitle: UILabel!
    
    var fetchResult:PHFetchResult<PHAsset>?
    var isFirst: Bool = false
    
    var networkUtil = NetworkUtil()
    var saveCardModel: SaveCardModel?
    var cardListModel: NSArray?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? CardCharging {
            if segue.identifier == "cardCharging"{
                segueVC.parentView = "cardSelecteVC"
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "카드선택")
        
        setCardList()
        
        store.cardName = nil
        store.cardPath = nil
        store.cardNo = nil
        
    }
    
    func setCardList() {
        
        ShowLoading.loadingStart(uiView: self.view)
        
        let cmd = "get_card_list"
        let strCode: String = "<CMD>\(cmd)</CMD><DATA></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            ShowLoading.loadingStop()
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    self.cardListModel = jsonResult["cardList"] as? NSArray
                    
                    DispatchQueue.main.async {

                        if jsonResult["errCode"] as? String == "0000" {

                            self.setTableView()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    func setTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if isFirst {
            textViewTop.constant = 0
            setSelectedCard()
        } else {
            textViewTop.constant = -128
        }
        
    }
    
    func setSelectedCard() {
        
        if let image = store.userCardPath {
         
            self.loadImage(urlString: image) { image in

                DispatchQueue.main.async {
                    self.selectedImage.image = image
                }

            }
            
        }
        
    }
    
    func checkPermission() {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited {
            DispatchQueue.main.async {
                self.showGallery()
            }
        } else if PHPhotoLibrary.authorizationStatus() == .denied {
            DispatchQueue.main.async {
                self.showAuthoriaztionDeninedAlert()
            }
        } else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                self.checkPermission()
            }
        }
        
    }
    
    func showAuthoriaztionDeninedAlert() {
        
        let alert = UIAlertController(title: "접근권한을 설정해 주세요.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "설정으로 가기", style: .default, handler: { action in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showGallery() {
        
        let library = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: library)
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    func checkCameraPermission(){
        
       AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
           if granted {
               DispatchQueue.main.async {
                   self.openCamera()
               }
           } else {
               DispatchQueue.main.async {
                   self.showAuthoriaztionDeninedAlert()
               }
           }
       })
        
    }
    
    func openCamera(){
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
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
    
    func saveCard() {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let cmd = "set_user_card"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let no = store.cardNo ?? ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NO>\(no)</NO></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(encryped)"
//        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: store.configUrl)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()
        
        httpBody.appendString(convertFormField(named: "code", value: urlString, using: boundary))

        if let imageData = store.cameraImage?.jpegData(compressionQuality: 1) {
            httpBody.append(convertFileData(fieldName: "CARDIMG", fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "multipart/form-data", fileData: imageData, using: boundary))
        }

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        
        session.dataTask(with: request) { data, response, error in
            print("status : \((response as! HTTPURLResponse).statusCode)")
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!

                    self.saveCardModel = try JSONDecoder().decode(SaveCardModel.self, from: decrypedData)

                    DispatchQueue.main.async {

                        if self.saveCardModel!.errCode == "0000" {
                            store.userCardPath = self.saveCardModel!.cardImg
                            self.navigationController?.popToRootViewController(animated: true)
                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
        
        }.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        
        let mimeType = "application/json"
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: \(mimeType)\r\n\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
        
    }

    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      
        let data = NSMutableData()
                
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
        
    }

}

extension CardSelecteVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFirst {
            return (self.cardListModel!.count * 2) + 2 + 1
        } else {
            return (self.cardListModel!.count * 2) + 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CardButtonCell", for: indexPath) as! CardButtonCell
                cell.btn_change.addTarget(self, action: #selector(cardChange(sender:)), for: .touchUpInside)
                
                cell.selectionStyle = .none
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CardHeaderCell", for: indexPath) as! CardHeaderCell
                let ind = indexPath.row / 2
                
                if ind < (self.cardListModel!.count) {
                    
                    let obj = self.cardListModel![ind] as! NSDictionary
                    let cateName = obj["cateName"] as! String
                    cell.headerTitle.text = cateName
                    
                } else {
                    cell.headerTitle.text = "Custom Design"
                }
                
                cell.selectionStyle = .none
                return cell
                
            }
            
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
            cell.indexPathRow = indexPath.row
            
            if isFirst {
                
                if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 {
                    cell.lastIndex = true
                } else {
                    
                    let ind = indexPath.row / 2
                    let obj = self.cardListModel![ind] as! NSDictionary
                    let cards = obj["cards"] as! NSArray
                    cell.cards = cards
                    
                }
                
            } else {
                
                if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                    cell.lastIndex = true
                } else {
                    
                    let ind = indexPath.row / 2
                    let obj = self.cardListModel![ind] as! NSDictionary
                    let cards = obj["cards"] as! NSArray
                    cell.cards = cards
                    
                }
                
            }
            
            cell.delegate = self
            
            cell.selectionStyle = .none
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return 120
            } else {
                return 55
            }
            
        } else {
            let wid = UIScreen.main.bounds.width / 1.8 - 15
            return (wid * 128) / 205 + 1
        }
        
    }
    
    @objc func cardChange(sender: UIButton) {
        
        saveCard()
        
    }
    
}

extension CardSelecteVC: cameraDelegate {
    
    func selectedCamera() {
        
        let alert = UIAlertController(title: "카드선택", message: "Custom Design 미디어를 선택하세요", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "사진앨범", style: .default) { (action) in
            self.checkPermission()
        }
        let camera = UIAlertAction(title: "카메라", style: .default) { (action) in
            self.checkCameraPermission()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectedImage(sect: Int, row: Int) {
        
        store.cameraImage = nil
        
        if isFirst {
            
            let cardSec = self.cardListModel![(sect - 1) / 2] as! NSDictionary
            let cards = cardSec["cards"] as! NSArray
            let obj = cards[row] as! NSDictionary

            store.cardName = obj["cardName"] as? String
            store.cardNo = obj["cardNo"] as? String
            store.cardPath = obj["cardPath"] as? String
            
            self.loadImage(urlString: store.cardPath!) { image in

                DispatchQueue.main.async {
                    self.selectedImage.image = image
                }

            }
            
            selectedTitle.text = store.cardName
            
        } else {
            
            let cardSec = self.cardListModel![(sect - 1) / 2] as! NSDictionary
            let cards = cardSec["cards"] as! NSArray
            let obj = cards[row] as! NSDictionary

            store.cardName = obj["cardName"] as? String
            store.cardNo = obj["cardNo"] as? String
            store.cardPath = obj["cardPath"] as? String

            performSegue(withIdentifier: "cardCharging", sender: self)
            
        }
        
    }
    
}

extension CardSelecteVC: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let identifires = results.map{ $0.assetIdentifier ?? "" }
        
        self.fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifires, options: nil)
        let asset = self.fetchResult?[0]
        let imageManager = PHImageManager()
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: 150 * scale, height: 150 * scale)
        
        imageManager.requestImage(for: asset!, targetSize: imageSize, contentMode: .aspectFill, options: nil) { image, info in
            store.cameraImage = image
        }
        
        self.dismiss(animated: true) {
            
            if self.isFirst {
                self.selectedImage.image = store.cameraImage
                self.selectedTitle.text = "Custom Design"
            } else {
                self.performSegue(withIdentifier: "cardCharging", sender: self)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            store.cameraImage = image
        }
        
        picker.dismiss(animated: true) {
            
            if self.isFirst {
                self.selectedImage.image = store.cameraImage
                self.selectedTitle.text = "Custom Design"
            } else {
                self.performSegue(withIdentifier: "cardCharging", sender: self)
            }
        }
        
    }
    
}


extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
