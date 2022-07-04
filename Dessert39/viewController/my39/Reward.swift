//
//  Reward.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/23.
//

import UIKit

class Reward: UIViewController {

    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var btn_gradeInfo: UIButton!
    @IBOutlet var gradeImage: UIImageView!
    @IBOutlet weak var perRewardLabel: UILabel!
    @IBOutlet var perRewardTotal: UILabel!
    @IBOutlet weak var label_limit: UILabel!
    
    let ANIMATION_DURATION: CGFloat = 1.4
    
    var slices: [Slice]?
    var sliceIndex: Int = 0
    var currentPercent: CGFloat = 0.0
    
    var rewardNum: CGFloat = 50
    var rewardTotal: Int = 10
    var drawTimer:Timer?
    var timeLeft = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "REWARD")
        navigationController?.isNavigationBarHidden = false
        
        rewardNum = CGFloat((store.userReward! as NSString).floatValue)
        rewardNum = 5
        
        self.canvasView.layer.sublayers = nil
        
//        var btnImage = UIImage()
        
        if rewardNum < 10 {
            rewardTotal = 10
            btn_gradeInfo.setTitle("씨앗", for: .normal)
//            btnImage = UIImage(named: "reward/0")!.resize(newWidth: 22)
            gradeImage.image = UIImage(named: "reward/0")
            rewardImageView.image = UIImage(named: "reward/0")
            perRewardTotal.isHidden = false
        }
        
        if rewardNum > 9 {
            rewardTotal = 30
            btn_gradeInfo.setTitle("새싹", for: .normal)
            gradeImage.image = UIImage(named: "reward/1")
            rewardImageView.image = UIImage(named: "reward/1")
            perRewardTotal.isHidden = false
        }
        
        if rewardNum > 29 {
            rewardTotal = 50
            btn_gradeInfo.setTitle("나무", for: .normal)
            gradeImage.image = UIImage(named: "reward/2")
            rewardImageView.image = UIImage(named: "reward/2")
            perRewardTotal.isHidden = false
        }
        
        if rewardNum > 49 {
            rewardTotal = 100
            btn_gradeInfo.setTitle("열매", for: .normal)
            gradeImage.image = UIImage(named: "reward/3")
            rewardImageView.image = UIImage(named: "reward/3")
            perRewardTotal.isHidden = false
        }
        
        if rewardNum > 99 {
            rewardTotal = Int(rewardNum)
            btn_gradeInfo.setTitle("지구", for: .normal)
            gradeImage.image = UIImage(named: "reward/4")
            rewardImageView.image = UIImage(named: "reward/4")
            perRewardTotal.isHidden = true
        }
        
//        btn_gradeInfo.setImage(btnImage, for: .normal)
        perRewardTotal.text = "/ \(rewardTotal)"
        
        slices = [Slice(percent: rewardNum / CGFloat(rewardTotal), color: UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000))]
        
        let num: Int = rewardTotal - Int(rewardNum)
        label_limit.text = "다음 등급까지 친환경 스탬프 \(num)개 남았습니다 :)"
        
        if store.nick != "" {
            
            let nick: String = store.nick!
            label_name.text = "\(nick)님의 등급"
            
        } else if store.name != "" {
            
            let name: String = store.name!
            label_name.text = "\(name)님의 등급"
            
        } else {
            
            let id: String = store.nick!
            label_name.text = "\(id)님의 등급"
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateChart()
    }
    
    func getDuration(_ slice: Slice) -> CFTimeInterval {
        return CFTimeInterval(slice.percent / 1.0 * self.ANIMATION_DURATION)
    }
    
    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        
        //Because angle starts wtih X positive axis, add 270 degrees to rotate it to Y positive axis.
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        
        return angle * CGFloat.pi / 180.0
        
    }
    
    func addSlice(_ slice: Slice) {
        print("draw circle")
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = self.getDuration(slice)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        
        let canvasWidth = self.canvasView.frame.width
        let path = UIBezierPath(arcCenter: CGPoint(x: self.canvasView.frame.size.width  / 2, y: self.canvasView.frame.size.height / 2),
                                radius: canvasWidth / 2,
                                startAngle: self.percentToRadian(self.currentPercent),
                                endAngle: self.percentToRadian(self.currentPercent + slice.percent),
                                clockwise: true)
        
        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = slice.color.cgColor
        sliceLayer.lineWidth = 2
        sliceLayer.strokeEnd = 1
        sliceLayer.add(animation, forKey: animation.keyPath)
        
        self.canvasView.layer.addSublayer(sliceLayer)
        
    }
    
    @objc func onTimerFires() {
        
        timeLeft += 1
        
        if timeLeft < 10 {
            self.perRewardLabel.text = "0\(timeLeft)"
        } else {
            self.perRewardLabel.text = "\(timeLeft)"
        }
        
        if timeLeft >= Int(self.slices![0].percent * CGFloat(self.rewardTotal)) {
            drawTimer?.invalidate()
            drawTimer = nil
        }
        
    }
    
    func animateChart() {
        
        self.sliceIndex = 0
        self.currentPercent = 0.0
        self.canvasView.layer.sublayers = nil
        
        if self.slices != nil && self.slices!.count > 0 {
            let firstSlice = self.slices![0]
            self.addSlice(firstSlice)
        }
        
        timeLeft = 0
        if rewardNum > 0 {
            drawTimer = Timer.scheduledTimer(timeInterval: (self.getDuration(self.slices![0]) / rewardNum), target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        }
        
    }

}

extension Reward: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            currentPercent += slices![sliceIndex].percent
            sliceIndex += 1
            if sliceIndex < slices!.count {
                let nextSlice = slices![sliceIndex]
                addSlice(nextSlice)
            }
        }
    }
    
}

extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
            
        }
        print("화면 배율: \(UIScreen.main.scale)")// 배수
        print("origin: \(self), resize: \(renderImage)")
        
        return renderImage
        
    }
    
}
