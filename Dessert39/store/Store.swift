//
//  Store.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/01.
//

import UIKit
import Foundation
import PhotosUI

class store {
    
    static var configUrl: String = "http://dessert39.com/api/index.php"
    static var authPwUrl: String = "http://dessert39.com/plugin/nice_auth/auth_pw.php?os=I"
    static var authRegUrl: String = "http://dessert39.com/plugin/nice_auth/auth_reg.php?os=I"
    static var authMyUrl: String = "http://dessert39.com/plugin/nice_auth/auth_info.php?os=I"
    static var uploadUrl: String = "http://dessert39.com/api/file_upload.php"
    static var payUrl: String = "http://dessert39.com/plugin/kis/payRequest.php"
//    static var payUrl: String = "https://api.kispg.co.kr/orderSample.html"
    
// MARK: - REAPPAY API - TEST
    static var reappayUrl: String = "https://api-dev-pg.reappay.net/api/v1/"
    static var reappayID: String = "coehdus11"
    static var reappayPW: String = "1q2w3e4r5t!!"
    
    static var metr: Double = 1000000000
    static var copyAddr: String?

// MARK: - AES256 key & IV
    static var AESKey: String = "dI@7ZmVPsozXXss8Yt2upyk62gPSVVnD"
    static var AESIv: String = "LoG!R$hFr$AHw7yY"
    
    static var fcmToken: String = ""
    
// MARK: - Login & Join
    static var login: LoginModel?
    static var id: String?
    static var sns: String?
    static var email: String?
    static var name: String?
    static var nick: String?
    static var birth: String?
    static var hp: String?
    static var regPart: String?
    static var isJoin: Bool = false
    static var isFindId: Bool = false
    static var isFindPw: Bool = false
    static var isMarketing: String = "N"
    static var userPoint: String?
    static var userReward: String?
    static var userLevelName: String?
    static var userLevelImg: String?
    static var userImg: String?
    static var couponList: NSArray?
    static var leave: String?
    
// MARK: - Card
    static var fetchResult:PHFetchResult<PHAsset>?
    static var cameraImage: UIImage?
    static var cardName: String?
    static var cardNo: String?
    static var cardPath: String?
    static var userCardName: String?
    static var userCardNo: String?
    static var userCardPath: String?
    static var userCash: String?

    
// MARK: - Order
    static var isStore: Bool = false
    static var storeNo: String?
    static var storeName: String = ""
    static var storeAddress: String = ""
    static var orderIndex: Int?
    static var basketArr: [BasketModel] = []
    static var isOtherMenu: Bool = false
    static var option : [String : Int] = ["shot":0, "special":0, "decaffein":0, "strong":0, "vanilla":0, "hazel":0, "caramel":0, "pearl":0, "coco":0]
    static var orderNo: String?
    static var isPay: Bool = false
    static var billpayID: String?
    static var billpayPW: String?
    
    static var dummybillpayId: String?
    static var dummybillpayPW: String?
    static var dummyNo: String?
    static var dummyName: String?
    static var dummyAddress: String?
    static var dummyTime: String?
    static var dummyDist: String?
    static var dummyImg: NSArray?
    static var dummyItem: NSDictionary?
    static var dummyItemNo: String?
    
    static var dummySyrup: Int?
    static var dummyShot: Int?
    static var dummySpecial: Int?
    static var dummyDecaffeine: Int?
    static var dummyHard: Int?
    static var dummyPearl: Int?
    static var dummyNatadcoco: Int?
    
    static var couponName: String = ""
    static var couponNo: String = ""
    static var couponPer: String = ""
    static var couponPrice: String = ""
    static var couponMax: String = ""
    static var couponMin: String = ""
    static var couponMenu: String = ""
    static var couponOwner: String = ""
    
    
    static var isBasket: Bool = false
    
    
// MARK: - My39
    static var orderListSetDate: Int?
    static var startDate: String?
    static var endDate: String?
    static var isPop: Bool = false
    static var userSoundIndex: Int?
    static var askType: String?
    static var askTitle: String?
    static var askContents: String?
    static var storeInfoIndex: Int?
    static var goEvent: Int = 0
    static var goNotice: Int = 0
    static var goMyOrder: Int = 0
    static var receiptNo: String?
    static var isAsk: Bool = false
    
    static var dummyBoard: NSDictionary?
    static var dummyStroe: String?
    static var dummyBoardNo: String?
    
    
    static var weather: WeatherModel?
    
    
    static var ordNo: String?
    
    static var dummySns: String?
    
    
    
    static var alarmBage: Bool = false
    
    static func alarmBageCheck(chk :Bool?){
        
        self.alarmBage = chk!
        
    }
    
    
}
