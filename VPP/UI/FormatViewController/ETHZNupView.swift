//
//  ETHZNupView.swift
//  VPP
//
//  Created by Nicolas Märki on 03.11.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

import UIKit

class ETHZNupView: UIImageView {
    
    

    required init?(coder aDecoder: NSCoder) {
        
        one = UILabel()
        one.text = "1"
        one.textAlignment = .Center
        
        two = UILabel()
        two.text = "2"
        two.textAlignment = .Center
        
        three = UILabel()
        three.text = "3"
        three.textAlignment = .Center
        
        four = UILabel()
        four.text = "4"
        four.textAlignment = .Center
        
        
        super.init(coder: aDecoder)
        
        
        addSubview(one)
        addSubview(two)
        addSubview(three)
        addSubview(four)
        
        self.updateNumberViews()
        
    }
    
    func updateNumberViews() {
        let job = ETHZPrintJob.sharedPrintJob()
        
        
        if job.pagesPerSheet == 1 {
            self.one.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/2-15, 30, 30)
            self.two.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/2-15, 30, 30)
            self.three.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/2-15, 30, 30)
            self.four.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/2-15, 30, 30)
            self.one.alpha = 1
            self.two.alpha = 0
            self.three.alpha = 0
            self.four.alpha = 0
        }
        else if job.pagesPerSheet == 2 {
            
            if self.frame.size.width < self.frame.size.height {
                self.one.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/4-15, 30, 30)
                self.two.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/4*3-15, 30, 30)
                self.three.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/4-15, 30, 30)
                self.four.frame = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/4*3-15, 30, 30)
                
            }
            else {
                self.one.frame = CGRectMake(self.frame.size.width/3-15, self.frame.size.height/2-15, 30, 30)
                self.two.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/2-15, 30, 30)
                self.three.frame = CGRectMake(self.frame.size.width/3-15, self.frame.size.height/2-15, 30, 30)
                self.four.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/2-15, 30, 30)
            }
            
            self.one.alpha = 1
            self.two.alpha = 1
            self.three.alpha = -1
            self.four.alpha = -1
        }
            
        else {
            
            if job.pagesPerSheet4Landscape {
                if self.frame.size.width < self.frame.size.height {
                    self.one.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4-15, 30, 30)
                    self.two.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4-15, 30, 30)
                    self.three.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4*3-15, 30, 30)
                    self.four.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4*3-15, 30, 30)
                    
                }
                else {
                    self.one.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4-15, 30, 30)
                    self.two.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4-15, 30, 30)
                    self.three.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4*3-15, 30, 30)
                    self.four.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4*3-15, 30, 30)
                }
            }
            else {
                if self.frame.size.width < self.frame.size.height {
                    self.one.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4-15, 30, 30)
                    self.two.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4-15, 30, 30)
                    self.three.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4*3-15, 30, 30)
                    self.four.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4*3-15, 30, 30)
                    
                }
                else {
                    self.one.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4*3-15, 30, 30)
                    self.two.frame = CGRectMake(self.frame.size.width/4-15, self.frame.size.height/4-15, 30, 30)
                    self.three.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4*3-15, 30, 30)
                    self.four.frame = CGRectMake(self.frame.size.width/4*3-15, self.frame.size.height/4-15, 30, 30)
                }
            }
            
            self.one.alpha = 1
            self.two.alpha = 1
            self.three.alpha = 1
            self.four.alpha = 1
        }
    }

    func updateNumbers() {
        
        
     
        
        
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.updateNumberViews()
            
            }, completion: nil)
    }



    
    let one:UILabel
    let two:UILabel
    let three:UILabel
    let four:UILabel
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
