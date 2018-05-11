//
//  ListTableViewCell.swift
//  BiBitto
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var baseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(cardData: CardData) {

        if cardData.category == Category.continents[0] {
            categoryImageView.image = UIImage(named: "orange")
        }else if cardData.category == Category.continents[1] {
            categoryImageView.image = UIImage(named: "pink")
        }else if cardData.category == Category.continents[2] {
            categoryImageView.image = UIImage(named: "green")
        }else if cardData.category == Category.continents[3] {
            categoryImageView.image = UIImage(named: "blue")
        }else if cardData.category == Category.continents[4] {
            categoryImageView.image = UIImage(named: "purple")
        }
        
        //baseView.layer.borderWidth = 1
        noLabel.text =  String(format: "%03d", cardData.no)
        wordLabel.text = cardData.text //cardData.text.replacingOccurrences(of: "\n", with: "")
        
    }
}
