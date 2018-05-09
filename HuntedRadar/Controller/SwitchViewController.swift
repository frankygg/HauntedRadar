//
//  SwitchViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class SwitchViewController: UIViewController, TapSwitchCellDelegate {

    weak var delegate: SwitchViewDelegate?
    let dangerous = ["凶宅", "毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    let dangerousimage: [String: String] = ["凶宅": "ghost", "毒品": "needle", "強制性交": "sexual_abuse", "強盜": "rob", "搶奪": "steal", "住宅竊盜": "homesteal", "汽車竊盜": "carsteal", "機車竊盜": "motorcycle_steal"]
    @IBOutlet weak var collectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.register(UINib(nibName: "SwitchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SwitchCollectionViewCell")

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension SwitchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    // 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    // 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if self.view.frame.size.width > 320 {
            return 5
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if self.view.frame.size.width > 320 {
            return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        } else {
            return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("frame width \(self.view.frame.size)")
        if self.view.frame.size.width > 320 {
        return CGSize(width: (self.view.frame.size.width - 15) / 2, height: (self.view.frame.size.height - 30) / 4)
        } else {
            return CGSize(width: (self.view.frame.size.width) / 2, height: (self.view.frame.size.height - 30) / 4)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchCollectionViewCell", for: indexPath) as? SwitchCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
            cell.dangerousImage.image = UIImage(named: dangerousimage[dangerous[indexPath.row]]!)
            cell.dangerousLabel.text = dangerous[indexPath.row]
        
        return cell
    }

    func tapSwitchCell(_ sender: SwitchCollectionViewCell) {
        guard let tappedIndexPath = self.collectionview.indexPath(for: sender) else { return }
        delegate?.deliverSwitchState(sender, tappedIndexPath.row)

        print(tappedIndexPath.section, tappedIndexPath.row)

    }
}

protocol SwitchViewDelegate: class {
    func deliverSwitchState(_ sender: SwitchCollectionViewCell, _ rowAt: Int)
}
