//
//  Home.swift
//  NewCap
//
//  Created by 唐明华 on 2022/3/3.
//

import SwiftUI
import CloudKit

@MainActor
class NotifyModel: ObservableObject{

    @Published var isSignin = false
    @Published var isPermision = false
    @Published var errorMessage = ""
    @Published var userName = ""


    init(){
        getiCloudStatus()
        requestPermission()
        fetchRecordID()
    }

    /// 获取权限
    func requestPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            if let error = error{
                self.errorMessage = "权限获取失败"
                print("\(error),\(error.localizedDescription)")
            }else if granted{
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { permimitionStatus, error in
            DispatchQueue.main.async {
                if permimitionStatus == .granted{
                    self.isPermision = true
                }else{
                    self.isPermision = false
                }
            }
        }
    }


    /// 消息订阅
    func subscribeNotifications(){
        let predication = NSPredicate(value: true)
        let sub = CKQuerySubscription(recordType: "Blogs",
                                      predicate: predication,
                                      subscriptionID: "news agent",
                                      options: .firesOnRecordCreation)
        let notification = CKSubscription.NotificationInfo()
        notification.title = "News"
        notification.alertBody = "This is really I'm not cared?"

        sub.notificationInfo = notification

        CKContainer.default().publicCloudDatabase.save(sub) { returned, error in
            if let error = error {
                print("出错了,咋办\(error),\(error.localizedDescription)？")
            }else{
                print("订阅成功？")
            }
        }
    }

    func fetchRecordID(){
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let id = recordID{
                self.fetchUserName(id: id)
            }
        }
    }

    func fetchUserName(id: CKRecord.ID){
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { userID, error in
            DispatchQueue.main.async {
                if let error = error{
                    print(error)
                }else{
                    self.userName = userID?.nameComponents?.givenName ?? ""
                }
            }

        }
    }
    /// 查询iCoud状态
    func getiCloudStatus(){
        CKContainer.default().accountStatus { stat, error in
            DispatchQueue.main.async {
                switch stat {
                case .couldNotDetermine:
                    self.errorMessage = "不确定"
                case .available:
                    self.errorMessage = "可以使用"
                case .restricted:
                    self.errorMessage = "限制使用"

                case .noAccount:
                    self.errorMessage = "无帐号"

                case .temporarilyUnavailable:
                    self.errorMessage = "暂时不能用"

                }
            }

        }
    }
}

struct Home: View {

    @StateObject var model = NotifyModel()

    var body: some View {
        VStack(spacing:44){

            Text(model.isPermision ? "可以访问" : "不能访问")
            Text("\(model.errorMessage),\(model.userName)")


            Button("权限请求"){
                model.requestPermission()
            }
            Button("消息订阅"){
                model.subscribeNotifications()
            }


        }
    }
}
