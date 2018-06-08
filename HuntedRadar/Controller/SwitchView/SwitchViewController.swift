//
//  SwitchViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class SwitchViewController: UIViewController {

    //IBOutlet var
    @IBOutlet weak var collectionview: UICollectionView!

    //local var
    weak var delegate: SwitchViewDelegate?
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

extension SwitchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, TapSwitchCellDelegate {
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
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        } else {
            return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
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
            cell.dangerousImage.image = UIImage(named: MapViewConstants.dangerousimage[MapViewConstants.dangerous[indexPath.row]]!)
            cell.dangerousLabel.text = MapViewConstants.dangerous[indexPath.row]

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
