//
//  FirebaseManager.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/17.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    lazy var ref = Database.database().reference()
    lazy var storageRef = Storage.storage().reference()

    private init() {}

    var imageReference: StorageReference {
        return storageRef.child("image")
    }

    func addArticleQuestion(uploadimage: UIImage?, uploadArticle article: Article, handler: @escaping () -> Void = { return}) {
        let filename = "\(NSUUID().uuidString)"
        if let image = uploadimage, let imageData = UIImageJPEGRepresentation(image, 0.1), let uid = Auth.auth().currentUser?.uid {
            let uploadImageRef = imageReference.child(filename)
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            var userName = ""
            ref.child("users/\(uid)/username").observe(.value) { (snapshot) in
                if let value = snapshot.value as? String {
                   userName = value
                }
            }
            _ = uploadImageRef.putData(imageData, metadata: metadata, completion: {(_, error) in
                if error == nil {
                    uploadImageRef.downloadURL(completion: { (url, error) in
                        if error == nil, let url = url {
                            let text = url.absoluteString
                            self.ref.child("article").childByAutoId().setValue(["imageUrl": text, "userName": userName, "uid": uid, "reason": article.reason, "address": article.address, "memo": article.memo])
                            handler()
                            //更新
//                            self.ref.child("article/\(uid)").updateChildValues(["image": text])
                        }
                    })
                }
            })
        }
    }

    func loadArticle(completion: @escaping([Article]) -> Void) {
        ref.child("article").observe(.value, with: {snapshot in

            var articles = [Article]()
            if let values = snapshot.value as? NSDictionary {
                for obj in values.allValues {
                    guard let obj = obj as? NSDictionary else {
                        return
                    }
                    let article = Article(uid: (obj.object(forKey: "uid") as? String)!, userName: (obj.object(forKey: "userName") as? String)!, imageUrl: (obj.object(forKey: "imageUrl") as? String)!, address: (obj.object(forKey: "address") as? String)!, reason: (obj.object(forKey: "reason") as? String)!, memo: (obj.object(forKey: "memo") as? String)!)

                    articles.append(article)
                    print("================")
                    print(obj)
                }

                completion(articles)
            }

        })
    }
}
