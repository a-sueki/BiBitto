//
//  SecondViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class HomeViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ヘッダ
        categoryLabel.text = "MIND"
        authorNameLabel.text = "SHOIN YOSHIDA"
        noLabel.text = "034"

        // 縦書き対応(本文)
        print(view.frame)
        view.backgroundColor = UIColor.gray
        let titleLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/20 * 8, //y
            y: view.frame.height/10 * 7,//x
            width: view.frame.height/2 , //h
            height: view.frame.width/10 * 1)) //w
        titleLabel.backgroundColor = UIColor.red
        view.addSubview(titleLabel)
        print(titleLabel.frame)

        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.verticalAlignment = .top
        // ラベルを90°回転させる
        let angle = Double.pi/2
        titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        let title = "行動力を生む心がけ"
        titleLabel.setText(title) { (mutableAttributedString) -> NSMutableAttributedString! in
            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
            return mutableAttributedString
        }

        // 縦書き対応(本文)
        print(view.frame)
        let textLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/10,
            y: view.frame.height/20 * 3,
            width: view.frame.width/5 * 2,
            height: view.frame.height/2))
        textLabel.backgroundColor = UIColor.yellow
        view.addSubview(textLabel)
        print(textLabel.frame)

        textLabel.textColor = UIColor.black
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.verticalAlignment = .top
        // ラベルを90°回転させる
        textLabel.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        let text = "国境の長いトンネルを抜けると雪国であった。夜の底が白くなった。信号所に汽車が止まった。\n向側の座席から娘が立って来て、島村の前のガラス窓を落した。雪の冷気が流れこんだ。娘は窓いっぱいに乗り出して、遠くへ叫ぶように、\n「駅長さあん、駅長さあん。」\n明りをさげてゆっくり雪を踏んで来た男は、襟巻で鼻の上まで包み、耳に帽子の毛皮を垂れていた。qaqqqqqqqqqqqあああああああああああああああああああああ"
        textLabel.setText(text) { (mutableAttributedString) -> NSMutableAttributedString! in
            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
            return mutableAttributedString
        }
 
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

