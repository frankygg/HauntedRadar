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

    func addArticleQuestion(uploadimage: [UIImage], uploadArticle article: Article, handler: @escaping () -> Void = { return}) {
//        var textArray: [String] = []
//        var fileNameArray: [String] = []
        if  let uid = Auth.auth().currentUser?.uid {
            var userName = ""
            ref.child("users/\(uid)/username").observe(.value) { (snapshot) in
                if let value = snapshot.value as? String {
                    userName = value
                }
            }

            uploadMultiPhoto(uploadimage: uploadimage) { fileNameArray, textArray in
                let reference = self.ref.child("article").childByAutoId()
                let articleKey = reference.key
                reference.setValue(["imageUrl": textArray, "userName": userName, "uid": uid, "reason": article.reason, "address": article.address, "title": article.title, "createdTime": article.createdTime, "articleKey": articleKey, "imageName": fileNameArray])
                handler()
            }
        }
    }

    func uploadMultiPhoto(uploadimage: [UIImage], completion: @escaping ([String], [String]) -> Void) {
        var fileNameArray = [String]()
        var textArray = [String]()

        let dispatchGroup = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue.global(qos: .utility)

        queue.async {

            for image in uploadimage {
//                dispatchGroup.enter()
                semaphore.wait()
                let filename = "\(NSUUID().uuidString)"
                fileNameArray.append(filename)
                guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
                    return
                }
                let uploadImageRef = self.imageReference.child(filename)
                let metadata = StorageMetadata()
                metadata.contentType = "image/png"
                _ = uploadImageRef.putData(imageData, metadata: metadata, completion: {(_, error) in
                    if error == nil {
                        uploadImageRef.downloadURL(completion: { (url, error) in
                            if error == nil, let url = url {
                                let text = url.absoluteString
                                textArray.append(text)
                                semaphore.signal()
//                                dispatchGroup.leave()
                                //更新
                                //                            self.ref.child("article/\(uid)").updateChildValues(["image": text])
                            }
                        })
                    }
                })
            }
//            dispatchGroup.notify(queue: .main) {
//                completion(fileNameArray, textArray)
//                print("Both functions complete 👍")
//            }
            semaphore.wait()
            DispatchQueue.main.async {

                completion(fileNameArray, textArray)
                print("Both functions complete 👍")
            }
            semaphore.signal()

    }

    }

    func loadArticle(completion: @escaping([Article]) -> Void) {
        ref.child("article").observe(.value, with: {snapshot in
            DispatchQueue.main.async {

            var articles = [Article]()
            guard let values = snapshot.value as? NSDictionary else {
                completion(articles)
                return
            }
                for (_, obj) in values {
                    guard let obj = obj as? NSDictionary else {
                        return
                    }
                    let article = Article(uid: (obj.object(forKey: "uid") as? String)!, userName: (obj.object(forKey: "userName") as? String)!, imageUrl: (obj.object(forKey: "imageUrl") as? [String])!, address: (obj.object(forKey: "address") as? String)!, reason: (obj.object(forKey: "reason") as? String)!, title: (obj.object(forKey: "title") as? String)!, createdTime: (obj.object(forKey: "createdTime") as? Int)!, articleKey: (obj.object(forKey: "articleKey") as? String)!, imageName: (obj.object(forKey: "imageName") as? [String])!)
                    articles.append(article)
//                    print("================")
//                    print(obj)
                }
                //確認是否有被封鎖用戶
                let defaults = UserDefaults.standard
                let myarray = defaults.stringArray(forKey: "Forbidden") ?? [String]()
                for arr in myarray {
                    articles = articles.filter({$0.userName != arr})
                }
                articles.sort(by: {$0.createdTime > $1.createdTime})

                completion(articles)
            }

        })
    }

    func deleteArticle(article: Article) {
        ref.child("article").child(article.articleKey).setValue(nil)

        for imageName in article.imageName {
        imageReference.child(imageName).delete(completion: { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
            }
        })
    }
    }

    func editArticle(uploadimage: [UIImage], article: Article, handler: @escaping () -> Void ) {

        //清storage
        for imageName in article.imageName {
            imageReference.child(imageName).delete(completion: { error in
                if let error = error {
                    print(error)
                } else {
                    // File deleted successfully
                }
            })
        }

        uploadMultiPhoto(uploadimage: uploadimage) { fileNameArray, textArray in
            self.ref.child("article").child(article.articleKey).updateChildValues(["imageUrl": textArray, "reason": article.reason, "address": article.address, "title": article.title, "createdTime": article.createdTime, "imageName": fileNameArray])
                                        handler()

        }
//        let filename = article.imageName
//        if let image = uploadimage, let imageData = UIImageJPEGRepresentation(image, 0.1) {
//            let uploadImageRef = imageReference.child(filename)
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/png"
//            _ = uploadImageRef.putData(imageData, metadata: metadata, completion: {(_, error) in
//                if error == nil {
//                    uploadImageRef.downloadURL(completion: { (url, error) in
//                        if error == nil, let url = url {
//                            let text = url.absoluteString
//                            self.ref.child("article").child(article.articleKey).updateChildValues(["imageUrl": text, "reason": article.reason, "address": article.address, "title": article.title, "createdTime": article.createdTime])
//                            handler()
//                        }
//                    })
//                }
//            })
//        }

    }

    func getUserName(completion: @escaping(String) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
        ref.child("users/\(uid)/username").observe(.value) { (snapshot) in
            DispatchQueue.main.async {

            if let value = snapshot.value as? String {
                completion(value)
            }
            }
        }
    }
    }

    func addComment(comment: String, articleId: String) {
        var username = ""
        getUserName(completion: { name in
            username = name
            if let uid = Auth.auth().currentUser?.uid {
                let anotherRef = self.ref.child("users/\(uid)/message").childByAutoId()
                anotherRef.setValue(comment)
                let key  = anotherRef.key

//                self.ref.child("article").child(articleId).child("message").child(key).setValue([username: text])
                self.ref.child("article").child(articleId).child("message").child(key).setValue(["userName": username, "comment": comment, "createdTime": Int(NSDate().timeIntervalSince1970), "commentKey": key])

            }
        })
    }

    func loadComment(articleId: String, completion: @escaping ([Comment]) -> Void) {
        ref.child("article").child(articleId).child("message").observe(.value, with: {snapshot in
            DispatchQueue.main.async {

            var comments = [Comment]()
            guard let values = snapshot.value as? NSDictionary else {
                completion(comments)
                return
            }
//                for obj in values.allKeys {
//                    print("##############")
//                    print(obj)
//                }
                for obj in values.allValues {
                    guard let obj = obj as? NSDictionary else {
                        completion(comments)
                        return
                    }
                    let comment = Comment(userName: (obj.object(forKey: "userName") as? String)!, comment: (obj.object(forKey: "comment") as? String)!, createdTime: (obj.object(forKey: "createdTime") as? Int)!, commentKey: (obj.object(forKey: "commentKey") as? String)!)

                    comments.append(comment)
//                    print("================")
//                    print(obj)
                }
                //確認是否有被封鎖用戶
                let defaults = UserDefaults.standard
                let myarray = defaults.stringArray(forKey: "Forbidden") ?? [String]()
                for arr in myarray {
                    comments = comments.filter({$0.userName != arr})
                }
                comments.sort(by: { $0.createdTime < $1.createdTime})

                completion(comments)
                 }

        })
    }

    func deleteComment(articleKey: String, commentKey: String) {
        ref.child("article").child(articleKey).child("message").child(commentKey).setValue(nil)
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        ref.child("users/\(uid)/message/\(commentKey)").setValue(nil)

    }

    func forbid(userName: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let reference = ref.child("users/\(uid)/forbid/").childByAutoId()
        let key = reference.key
        reference.setValue(["userName": userName, "forbidKey": key])
    }

    func loadForbidUsers(completion: @escaping ([Forbid]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
         ref.child("users/\(uid)/forbid/").observe(.value, with: {snapshot in
            DispatchQueue.main.async {

            var forbids = [Forbid]()
            var forbidUserArray = [String]()
            guard let values = snapshot.value as? NSDictionary else {
                completion(forbids)
                return
            }
            for obj in values.allValues {
                guard let obj = obj as? NSDictionary else {
                    return
                }
                let forbid = Forbid(userName: (obj.object(forKey: "userName") as? String)!, forbidKey: (obj.object(forKey: "forbidKey") as? String)!)
                forbids.append(forbid)
                forbidUserArray.append((obj.object(forKey: "userName") as? String)!)
            }
            let userdefault = UserDefaults.standard

            userdefault.set(forbidUserArray, forKey: "Forbidden")
            completion(forbids)
            }
        })
    }

    func deleteForbidUser(forbidUser: Forbid) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        ref.child("users/\(uid)/forbid/").child(forbidUser.forbidKey).setValue(nil)
        // 處理userdefault
        let userDefault = UserDefaults.standard
        guard var forbidArray = userDefault.stringArray(forKey: "Forbidden") else {
            return
        }
        forbidArray = forbidArray.filter({$0 != forbidUser.userName})
        userDefault.set(forbidArray, forKey: "Forbidden")

    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "這個信箱已經被另一個帳號註冊！"
        case .userNotFound:
            return "無此帳號，請檢查並重新嘗試！"
        case .userDisabled:
            return "您的帳號已被封鎖，請聯繫管理員！"
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "請輸入有效的信箱！"
        case .networkError:
            return "網路錯誤！請稍後嘗試！"
        case .weakPassword:
            return "您的密碼長度不足，密碼長度需大於六位數！"
        case .wrongPassword:
            return "您輸入的密碼錯誤！"
        case .missingEmail: return "請您提供信箱地址！"
        default:
            return "發生不明錯誤！"
        }
    }
}
