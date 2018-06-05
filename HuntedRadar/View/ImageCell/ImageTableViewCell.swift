//
//  ImageTableViewCell.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/21.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var imageUrlView: UIImageView!
    
    var pageControl = UIPageControl()
    // 取得螢幕的尺寸
    let fullSize = UIScreen.main.bounds.size
    override func awakeFromNib() {
        
        
        
        
        //
        // 設置尺寸 也就是可見視圖範圍
        myScrollView.frame = CGRect(
            x: 0, y: 0,
            width: fullSize.width, height: myScrollView.frame.height)
        
        // 實際視圖範圍
        myScrollView.contentSize = CGSize(
            width: fullSize.width * CGFloat(imagePhotoUrls.count), height: fullSize.height / 5)
        
        // 是否顯示滑動條
        myScrollView.showsHorizontalScrollIndicator = false
        myScrollView.showsVerticalScrollIndicator = false
        
        // 滑動超過範圍時是否使用彈回效果
        //        myScrollView.bounces = true
        myScrollView.alwaysBounceVertical = false
        myScrollView.alwaysBounceHorizontal = true
        
        // 設置委任對象
        myScrollView.delegate = self
        
        // 以一頁為單位滑動
        myScrollView.isPagingEnabled = true
        
        // 建立 UIPageControl 設置位置及尺寸
        pageControl = UIPageControl(frame: CGRect(
            x: 0, y: 0, width: fullSize.width * 0.85, height: 50))
        pageControl.center = CGPoint(
            x: self.contentView.frame.width * 0.5, y: myScrollView.frame.height + 7.5)
        
        // 有幾頁 就是有幾個點點
        pageControl.numberOfPages = imagePhotoUrls.count
        
        // 起始預設的頁數
        pageControl.currentPage = 0
        
        // 目前所在頁數的點點顏色
        pageControl.currentPageIndicatorTintColor =
            UIColor(displayP3Red: 11 / 255, green: 170 / 255, blue: 229 / 255, alpha: 1)
        
        // 其餘頁數的點點顏色
        pageControl.pageIndicatorTintColor = UIColor(displayP3Red: 205 / 255, green: 205 / 255, blue: 205 / 255, alpha: 1)
        
        // 增加一個值改變時的事件
        pageControl.addTarget(
            self,
            action: #selector(pageChanged),
            for: .valueChanged)
        
        // 加入到基底的視圖中 (不是加到 UIScrollView 裡)
        // 因為比較後面加入 所以會蓋在 UIScrollView 上面
        
        // 加入到畫面中
        //        pageTableView.addSubview(myScrollView)
        //        self.view.addSubview(myScrollView)
        
        var icount = 0
        for url in imagePhotoUrls {
            let image = UIImageView()
            image.contentMode = UIViewContentMode.scaleAspectFill
            image.layer.masksToBounds = true
            
            image.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "adjust_picture"))
            //                let xCoordinate = view.frame.midX + view.frame.width * CGFloat(i)
            //                contentWidth += view.frame.width
            
            image.frame = CGRect(x: 0, y: 0, width: fullSize.width, height: myScrollView.frame.height)
            image.center = CGPoint(x: fullSize.width * (0.5 + CGFloat(icount)), y: myScrollView.frame.height / 2 )
            myScrollView.addSubview(image)
            icount += 1
        }
        //
        //        pageTableView.addSubview(pageControl)
        ////        self.view.addSubview(pageControl)
        //
//        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        
        
//        self.contentView.addSubview(myScrollView)
        self.contentView.addSubview(pageControl)
        
        
        
        
       
        
    }
    //UIScrollViewDelegate方法，每次滚动结束后调用
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 左右滑動到新頁時 更新 UIPageControl 顯示的頁數
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = page
    }
    
    // 點擊點點換頁
    @objc func pageChanged(sender: UIPageControl) {
        // 依照目前圓點在的頁數算出位置
        var frame = self.myScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        
        // 再將 UIScrollView 滑動到該點
        myScrollView.scrollRectToVisible(frame, animated:true)
    }
    
    @objc func moveToNextPage (){
        
        let pageWidth:CGFloat = self.myScrollView.frame.width
        let maxWidth:CGFloat = pageWidth * CGFloat(imagePhotoUrls.count)
        let contentOffset:CGFloat = self.myScrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth
        {
            slideToX = 0
        }
        self.myScrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.myScrollView.frame.height), animated: true)
        let page = Int(slideToX / myScrollView.frame.size.width)
        self.pageControl.currentPage = page
        
    }
    
  

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
