### 开启Cloud Kit示例
> 对创建项目时选择了`Host in CloudKit`的项目，按下述步骤开启Cloudkit订阅：
>  * + 在app id中启动iCloud 和 Push Notifications *
>  * + 在xcode 项目capabilities中启动 `CloutKit` 和 `remoto notifications` *
>  * + 在Cloud Kit中添加 ` Record Type` *
>  * + 在获取` remote notification`权限 *
>  * + 检查` CloudKit` 状态 *
>  * + 订阅CloutKit消息 *

#### 1. 启用iCloud
当前使用的app id中，启用`Push notifications` 和icloud下的`include cloudkit support` 功能
<img width="853" alt="image" src="https://user-images.githubusercontent.com/29822398/156935795-a037da87-8d51-4243-84ea-8f8ca7b12411.png">

#### 2. 在项目的capabilities中启用`remote notifications`和`cloudkit`
<img width="936" alt="image" src="https://user-images.githubusercontent.com/29822398/156936067-f44e08f2-3f6d-4d36-be48-cd626ca8d977.png">

#### 3. 在Cloud console中，添加Record Type
#### 4. 权限获取
```
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
```
#### 5. 检查icloud status
```
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
```
#### 6. 消息订阅
```
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
```



