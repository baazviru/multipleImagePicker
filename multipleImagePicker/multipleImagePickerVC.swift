//
//  multipleImagePickerVC.swift
//  Muslify
//
//  Created by mac on 16/10/20.
//  Copyright © 2020 MAC . All rights reserved.
//

import UIKit
import Photos

class multipleImagePickerVC: UIViewController {
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var contentainerView: UIView!
    
    var selected : [SelectedImages] = []
    var grid : [Images] = []
    
    var ProductImages = [UIImage]()
    var show = false
    var canSelectImage = 0
    
    var simpleClosure:([UIImage]) -> () = {_ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentainerView.zoomOut()
        checkPhotoLibraryPermission()
        activity.startAnimating()
        collection.dataSource = self
        collection.delegate = self
       
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.activity.stopAnimating()
            self.activity.isHidden = true
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        contentainerView.zoomIn()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.getAllImages()
            break
        case .denied, .restricted :
            print("denied, .restricted")
        //handle denied status
        case .notDetermined:
            showPopup()
            print("notDetermined")
            
        @unknown default:
            print("@unknown default")
        }
    }
    
    func showPopup(){
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized{
                DispatchQueue.main.sync {
                    self.getAllImages()
                }
            }
        }
    }
    
    
    @IBAction func doneActionBtn(_ sender:UIButton){
        contentainerView.zoomOut()
        let selectedImg = grid.filter({$0.selected == true})
        grid = selectedImg
        ProductImages.removeAll()
        _ = grid.filter { (img) -> Bool in
            ProductImages.append(img.image)
            return true
        }
        simpleClosure(ProductImages)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelActionBtn(_ sender:UIButton){
        contentainerView.zoomOut()
        dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK:- load collection view for  images
extension multipleImagePickerVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return grid.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imgVIew = cell.contentView.viewWithTag(12) as? UIImageView
        
        let imgSelected = cell.contentView.viewWithTag(13) as? UIButton
        // let checkMark = cell.contentView.viewWithTag(14) as? UIImageView
        
        imgVIew?.image = grid[indexPath.row].image
        
        if grid[indexPath.row].selected{
            imgSelected?.isHidden = false
            
        }else{
            imgSelected?.isHidden = true
            
        }
        
        return cell
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width/3-15, height: collectionView.frame.size.width/3-15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  
        if grid[indexPath.row].selected{
            grid[indexPath.row].selected = false
        }else{
            grid[indexPath.row].selected = true
        }
        collection.reloadItems(at: [indexPath])
    }

    
}

//MARK:- select multiple images stuff
extension multipleImagePickerVC{
    func getAllImages(){
        
        let opt = PHFetchOptions()
        opt.includeHiddenAssets = false
        let req = PHAsset.fetchAssets(with: .image, options: .none)
        //  DispatchQueue.global(qos: .background).async {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        // New Method For Generating Grid Without Refreshing....
        for i in stride(from: 0, to: req.count, by: 3){
            // var iteration : [Images] = []
            for j in i..<i+3{
                if j < req.count{
                    PHCachingImageManager.default().requestImage(for: req[j], targetSize: CGSize(width: 150, height: 150), contentMode: .default, options: options) { (image, _) in
                        
                        let data1 = Images(image: image!, selected: false, asset: req[j])
                        self.grid.append(data1)
                        // iteration.append(data1)
                    }
                }
            }
            // self.grid.append(iteration)
        }
        collection.reloadData()
        //}
    }
}


struct Images: Hashable {
    var image : UIImage
    var selected : Bool
    var asset : PHAsset
}

struct SelectedImages: Hashable{
    var asset : PHAsset
    var image : UIImage
}






extension UIView{
    func zoomIn(){
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
    func zoomOut(){
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: nil)
    }

    
    
    func fromTop(){
        
        self.transform = CGAffineTransform(translationX: 0, y: -200)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
    }
    func fromBottom(){
        
        self.transform = CGAffineTransform(translationX: 0, y: 500)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
        
    }
    func fromLeft(){
        
        self.transform = CGAffineTransform(translationX: -500, y: 0)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
        
    }
    func fromRight(){
        self.transform = CGAffineTransform(translationX: self.frame.size.width+320, y: 0)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
        
    }
    
    func toRight(){
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform(translationX: self.frame.size.width+320, y: 0)
        }, completion: nil)
        
    }
    
    func toLeft(){

        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform(translationX: -500, y: 0)
        }, completion: nil)
        
    }
    
    func toBottom(){
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 500)
        }, completion: nil)
        
    }
    func toTop(){
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -200)
        }, completion: nil)
    }
    
}

