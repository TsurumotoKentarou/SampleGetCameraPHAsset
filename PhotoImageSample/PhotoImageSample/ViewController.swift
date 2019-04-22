//
//  ViewController.swift
//  PhotoImageSample
//
//  Created by 鶴本賢太朗 on 2019/04/22.
//  Copyright © 2019 Kentarou. All rights reserved.
//

import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 写真のアクセス許可ダイアログを表示する
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                break;
            default:
                break
            }
            
        }
    }
    
    @IBAction func didTapBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController {
    private func showImage(asset: PHAsset) {
        let manager: PHImageManager = PHImageManager()
        let option: PHImageRequestOptions = .init()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        // 読み込む画像のサイズを指定する
        let imageSize: CGSize = self.getThumbnailSize()
        // 画像取得処理を開始する
        manager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option, resultHandler: { [weak self] (image, info) in
            if let loadedImage: UIImage = image {
                self?.imageView.image = loadedImage
            }
        })
    }
    // サムネイルの画像サイズを取得する
    // セルのサイズに画面解像度の倍率をかける
    private func getThumbnailSize() -> CGSize {
        var thumbnailSize: CGSize = self.imageView.frame.size
        thumbnailSize.width *= UIScreen.main.scale
        thumbnailSize.height *= UIScreen.main.scale
        return thumbnailSize
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 撮影時に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            // 撮影した写真
            guard let tempImage: UIImage = info[.originalImage] as? UIImage else { return }
            // 撮影した写真のローカルId
            var localIdentifier: String?
            PHPhotoLibrary.shared().performChanges({
                // 撮影した写真を保存する
                let request: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: tempImage)
                // 撮影した写真のローカルidを取得する
                if let placeHolder: PHObjectPlaceholder = request.placeholderForCreatedAsset {
                    localIdentifier = placeHolder.localIdentifier
                }
            }) { [weak self] (isSuccess, error) in
                if isSuccess {
                    if let localIdentifier: String = localIdentifier {
                        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject!
                        DispatchQueue.main.async {
                            self?.showImage(asset: asset)
                        }
                    }
                } else {
                    // 保存失敗
                }
            }
        }
    }
}
