//
//  pictureCell.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/14/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    @IBOutlet weak var picImg: UIImageView!
    
    
    //default func 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //aligment
        let width = UIScreen.mainScreen().bounds.width
        
        picImg.frame=CGRectMake(0, 0, width/3, width/3)
    }
}
