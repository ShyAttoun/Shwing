//
//  InboxTableViewCell.swift
//  Shwing
//
//  Created by shy attoun on 17/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import AVFoundation

class StorageService {
    
    static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let ref = Ref().storageSpecificVideoMessage(id: id)
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            ref.downloadURL(completion: { (videoUrl, error) in
                if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                    StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                        if let dict = value as? Dictionary<String, Any> {
                            var dictValue = dict
                            if let videoUrlString = videoUrl?.absoluteString {
                                dictValue["videoUrl"] = videoUrlString
                            }
                            onSuccess(dictValue)
                        }
                    }, onError: { (errorMessage) in
                        onError(errorMessage)
                    })
                }
            })
        }
    }
    
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        if let imagePhoto = image {
            let ref = Ref().storageSpecificImageMessage(id: id)
            if let data = imagePhoto.jpegData(compressionQuality: 0.5) {
                
                ref.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    ref.downloadURL(completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": imagePhoto.size.width as Any,
                                "text": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    })
                }
            }
        }
    }
    static func savePhotoProfile(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificProfile(uid: "profile")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
 
        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                    Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([PROFILE_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    
    static func savePhotoProfile1(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificProfile(uid: "profile1")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                    Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([PROFILE_FIRST_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    
    static func savePhotoProfile2(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
          guard let imageData = image.jpegData(compressionQuality: 0.4) else {
              return
          }
          
        let storageProfileRef = Ref().storageSpecificProfile(uid:"profile2")
          
          let metadata = StorageMetadata()
          metadata.contentType = "image/jpg"
     
          storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
              if error != nil {
                  onError(error!.localizedDescription)
                  return
              }
              
              storageProfileRef.downloadURL(completion: { (url, error) in
                  if let metaImageUrl = url?.absoluteString {
                      
                      if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                          changeRequest.photoURL = url
                          changeRequest.commitChanges(completion: { (error) in
                              if let error = error {
                                  ProgressHUD.showError(error.localizedDescription)
                              }
                          })
                      }
                      
                    Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([PROFILE_SECOND_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                          if error == nil {
                              
                              onSuccess()
                          } else {
                              onError(error!.localizedDescription)
                          }
                      })
                  }
              })
              
          })
          
          
      }
    static func savePhotoProfile3(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
          guard let imageData = image.jpegData(compressionQuality: 0.4) else {
              return
          }
          
          let storageProfileRef = Ref().storageSpecificProfile(uid: "profile3")
          
          let metadata = StorageMetadata()
          metadata.contentType = "image/jpg"

          storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
              if error != nil {
                  onError(error!.localizedDescription)
                  return
              }
              
              storageProfileRef.downloadURL(completion: { (url, error) in
                  if let metaImageUrl = url?.absoluteString {
                      
                      if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                          changeRequest.photoURL = url
                          changeRequest.commitChanges(completion: { (error) in
                              if let error = error {
                                  ProgressHUD.showError(error.localizedDescription)
                              }
                          })
                      }
                      
                    Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([PROFILE_THIRD_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                          if error == nil {
                              
                              onSuccess()
                          } else {
                              onError(error!.localizedDescription)
                          }
                      })
                  }
              })
              
          })
          
          
      }
    static func savePhotoProfile4(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
          guard let imageData = image.jpegData(compressionQuality: 0.4) else {
              return
          }
          
          let storageProfileRef = Ref().storageSpecificProfile(uid: "profile4")
          
          let metadata = StorageMetadata()
          metadata.contentType = "image/jpg"

          storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
              if error != nil {
                  onError(error!.localizedDescription)
                  return
              }
              
              storageProfileRef.downloadURL(completion: { (url, error) in
                  if let metaImageUrl = url?.absoluteString {
                      
                      if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                          changeRequest.photoURL = url
                          changeRequest.commitChanges(completion: { (error) in
                              if let error = error {
                                  ProgressHUD.showError(error.localizedDescription)
                              }
                          })
                      }
                      
                    Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([PROFILE_FOURTH_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                          if error == nil {
                              
                              onSuccess()
                          } else {
                              onError(error!.localizedDescription)
                          }
                      })
                  }
              })
              
          })
          
          
      }
    static func saveLogoImageProfile(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        let storageProfileRef = Ref().storageSpecificBuissProfile(uid: "logo image")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                  Ref().databaseSpecificBuisUser(uid: Api.BuisUser.currentUserId).updateChildValues([LOGO_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    static func saveInteriorImageProfile(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificBuissProfile(uid: "interior image")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                  Ref().databaseSpecificBuisUser(uid: Api.BuisUser.currentUserId).updateChildValues([INTERIOR_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    static func saveEntranceImageProfile(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificBuissProfile(uid: "entrance image")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                  Ref().databaseSpecificBuisUser(uid: Api.BuisUser.currentUserId).updateChildValues([ENTRANCE_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    static func saveConceptImageProfile(image: UIImage, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificBuissProfile(uid: "concept image")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                  Ref().databaseSpecificBuisUser(uid: Api.BuisUser.currentUserId).updateChildValues([CONCEPT_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    static func savePhoto(username: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        storageProfileRef.putData(data, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        
                        })
                    }
                    
                    var dictTemp = dict
                    dictTemp["profileImageurl"] = metaImageUrl
                    
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp, withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
    }
}
