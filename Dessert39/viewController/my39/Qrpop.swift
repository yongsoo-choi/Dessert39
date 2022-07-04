//
//  Qrpop.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/12.
//

import UIKit

class Qrpop: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_another: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label_addr: UILabel!
    @IBOutlet var titleSend: UILabel!
    @IBOutlet var titleCreate: UILabel!
    
    var filter = CIFilter(name: "CIQRCodeGenerator")
    var networkUtil = NetworkUtil()
    var coinWalletAddr: String?
    var isOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height)
        backgroundView.alpha = 0
        
        setting()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetY.constant = 0
            self.backgroundView.alpha = 0.7
            self.view.layoutIfNeeded()
        }

        setButton()
        generateCode()
        
    }
    
    func generateCode() {

        guard let filter = filter, let data = coinWalletAddr!.data(using: .isoLatin1, allowLossyConversion: false) else {
            return
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else {
            return
        }

        let transformed = ciImage.transformed(by: CGAffineTransform.init(scaleX: 10, y: 10))

        let invertFilter = CIFilter(name: "CIColorInvert")
        invertFilter?.setValue(transformed, forKey: kCIInputImageKey)

        let alphaFilter = CIFilter(name: "CIMaskToAlpha")
        alphaFilter?.setValue(invertFilter?.outputImage, forKey: kCIInputImageKey)

        if let ouputImage = alphaFilter?.outputImage {
            imageView.tintColor = .black
            imageView.backgroundColor = .white

            imageView.image = UIImage(ciImage: ouputImage, scale: 2.0, orientation: .up).withRenderingMode(.alwaysTemplate)
        } else {
            return
        }
        
    }
    
    func setting() {
        
        label_addr.text = coinWalletAddr!
        
        if isOn {
            titleCreate.isHidden = false
            titleSend.isHidden = true
        } else {
            titleCreate.isHidden = true
            titleSend.isHidden = false
        }
        
    }
    
    func setButton() {
        
        btn_another.layer.cornerRadius = btn_another.frame.height / 2
        btn_cancel.layer.cornerRadius = btn_cancel.frame.height / 2
        btn_cancel.layer.borderWidth = 1
        btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        
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
    
    @IBAction func closeHAndler(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -(self.bottomSheetView.frame.size.height)
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func copyAddress(_ sender: UIButton) {
        
        let addr = coinWalletAddr!
        
        UIPasteboard.general.string = addr
        AlertUtil().oneItem(self, title: "주소가 복사 되었습니다.", message: "")
        
        
    }

    @IBAction func socialAddr(_ sender: UIButton) {
        
        let addr = coinWalletAddr!
        
        let activityViewController = UIActivityViewController(activityItems: [addr], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
    }
}

