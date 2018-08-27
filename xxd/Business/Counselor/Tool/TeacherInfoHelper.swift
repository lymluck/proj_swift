//
//  TeacherInfoHelper.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/4.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

let TeacherInfoKey = "TeacherInfoKey"

struct TeacherInfo {
    var id: String // ryid
    var name: String?
    var title: String?
    var workYear: String?
    var avatar: String?
    var status: Int?
    var company: String?
    var companySubTitle: String?
    var companyLogo: String?
    var companyDesc: String?
    var schoolCertified: Bool?
    var school: String?
    var likesNum: Int?
    var video: String?
}

extension TeacherInfo: Equatable {
    static func ==(lhs: TeacherInfo, rhs: TeacherInfo) -> Bool {
        if lhs.id != rhs.id { return false }
        if lhs.name != rhs.name { return false }
        if lhs.title != rhs.title { return false }
        if lhs.workYear != rhs.workYear { return false }
        if lhs.avatar != rhs.avatar { return false }
        if lhs.status != rhs.status { return false }
        if lhs.company != rhs.company { return false }
        if lhs.companySubTitle != rhs.companySubTitle { return false }
        if lhs.companyLogo != rhs.companyLogo { return false }
        if lhs.companyDesc != rhs.companyDesc { return false }
        if lhs.schoolCertified != rhs.schoolCertified { return false }
        if lhs.school != rhs.school { return false }
        if lhs.likesNum != rhs.likesNum { return false }
        if lhs.video != rhs.video { return false }
        return true
    }
}

extension TeacherInfo {
    func toModel() -> TeacherInfoModel {
        let model = TeacherInfoModel()
        model.id = id
        model.name = name
        model.title = title
        model.workYear = workYear
        model.avatar = avatar
        model.status = status ?? 0
        model.company = company
        model.companySubTitle = companySubTitle
        model.companyLogo = companyLogo
        model.companyDesc = companyDesc
        model.schoolCertified = schoolCertified ?? false
        model.school = school
        model.likesCount = likesNum ?? 0
        model.video = video
        return model
    }
}

class TeacherInfoModel: Object {
    @objc dynamic var id: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var title: String? = nil
    @objc dynamic var workYear: String? = nil
    @objc dynamic var avatar: String? = nil
    @objc dynamic var status: Int = 0
    @objc dynamic var company: String? = nil
    @objc dynamic var companySubTitle: String? = nil
    @objc dynamic var companyLogo: String? = nil
    @objc dynamic var companyDesc: String? = nil
    @objc dynamic var schoolCertified: Bool = false
    @objc dynamic var school: String? = nil
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var video: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension TeacherInfoModel {
    func toInfo() -> TeacherInfo? {
        guard let id = id else {
            assert(false, "id can not be nil")
            return nil
        }
        let info = TeacherInfo(id: id,
                               name: name,
                               title: title,
                               workYear: workYear,
                               avatar: avatar,
                               status: status,
                               company: company,
                               companySubTitle: companySubTitle,
                               companyLogo: companyLogo,
                               companyDesc: companyDesc,
                               schoolCertified: schoolCertified,
                               school: school,
                               likesNum: likesCount,
                               video: video)
        return info
    }
}

class TeacherInfoHelper {
    static var shared = TeacherInfoHelper()
    
    let realm: Realm = {
        let config = Realm.Configuration(
            // 设置新的架构版本。必须大于之前所使用的
            // （如果之前从未设置过架构版本，那么当前的架构版本为 0）
            schemaVersion: 5,
            
            // 设置模块，如果 Realm 的架构版本低于上面所定义的版本，
            // 那么这段代码就会自动调用
            migrationBlock: { migration, oldSchemaVersion in
//                // 我们目前还未执行过迁移，因此 oldSchemaVersion == 0
//                if (oldSchemaVersion < 3) {
//                    // 没有什么要做的！
//                    // Realm 会自行检测新增和被移除的属性
//                    // 然后会自动更新磁盘上的架构
//                }
        })
        
        // 通知 Realm 为默认的 Realm 数据库使用这个新的配置对象
        Realm.Configuration.defaultConfiguration = config
        
        do {
            try Realm()
        } catch {
            print(error)
        }
        
        return try! Realm()
    }()
    
    var teacherInfos: [String: TeacherInfo] = [:]
    var inUpdataingIds: Set<String> = [] // 标记正在请求的id
    
    private init() {}
    
    /// 批量更新教师信息, 并数据库存储
    ///
    /// - Parameters:
    ///   - ids: 教师id数组
    ///   - completion: 完成回调
    func updateTeacherInfos(_ ids: [String],
                            completion: (([TeacherInfo]?) -> ())? = nil) {
        // 过滤正在请求的用户
        let filterIds = ids.filter { !inUpdataingIds.contains($0) }
        let idsStr = filterIds.joined(separator: ",")
        // 加入到正在请求的用户id中
        filterIds.forEach { inUpdataingIds.insert($0) }
        guard filterIds.count > 0 else {
            completion?(nil)
            return
        }
        
        SSNetworkManager.shared().get(XD_FETCH_TEACHER_INFOS,
                                      parameters: ["ids": idsStr],
                                      success: { [weak self] (_, response) in
            filterIds.forEach { self?.inUpdataingIds.remove($0) }
            guard let res = response else { return }
            let json = JSON(res)["data"]
            let teacherInfos = json.map { (key, value) -> TeacherInfo in
                                    let info = TeacherInfo(id: key,
                                                           name: value["name"].stringValue,
                                                           title: value["title"].stringValue,
                                                           workYear: value["yearsOfWorking"].stringValue,
                                                           avatar: value["avatar"].stringValue,
                                                           status: value["status"].intValue,
                                                           company: nil,
                                                           companySubTitle: nil,
                                                           companyLogo: nil,
                                                           companyDesc: nil,
                                                           schoolCertified: nil,
                                                           school: nil,
                                                           likesNum: value["likesCount"].intValue,
                                                           video: value["video"].stringValue)
                                    // 存到内存
                                    self?.insertTeacherInfo(info)
                                    return info
                                }
            let models = teacherInfos.map { $0.toModel() }
            // 存入数据库
            
            try! self?.realm.write {
                self?.realm.add(models, update: true)
            }
            completion?(teacherInfos)
            teacherInfos.forEach {
                NotificationCenter.default.post(name: .TeacherInfoUpdated, object: nil, userInfo: [TeacherInfoKey: $0])
                
            }
            }, failure: { (_, error) in
                filterIds.forEach { self.inUpdataingIds.remove($0) }
                SSLog(error.localizedDescription)
        })
        
        
//        APIClient.request(.fetchStudentInfos(ids: idsStr)) { (result) in
//            // 移出正在请求集合
//            filterIds.forEach { self.inUpdataingIds.remove($0) }
//            switch result {
//            case let .success(response):
//                let json: JSON = JSON(response.response)["data"]
//                let studentInfos = json.map({ (key, value) -> TeacherInfo in
//                    let info = TeacherInfo(id: key,
//                                           nickName: value["name"].string,
//                                           admissionTime: value["admissionTime"].stringValue,
//                                           targetCountry: value["targetCountry"].string,
//                                           targetDegree: value["targetDegree"].string,
//                                           avatar: value["avatar"].string)
//                    
//                    // 存到内存
//                    self.insertStudentInfo(info)
//                    return info
//                })
//                let models = studentInfos.map { $0.toModel() }
//                
//                
//                // 存入数据库
//                    let realm = try! Realm()
//                    try! realm.write {
//                        realm.add(models, update: true)
//                }
//                completion?(studentInfos)
//                studentInfos.forEach {
//                    NotificationCenter.default.post(name: .TeacherInfoUpdated, object: nil, userInfo: [TeacherInfoKey: $0])
//                }
//            case let .failure(error):
//                TSLog(error)
//            }
//        }
    }
    

    /// 获取教师信息
    ///
    /// - Parameters:
    ///   - id: 教师id
    ///   - forceUpdate: 是否强制从网络更新, 如果为true, 则completion为异步回调
    ///   - completion: 获取教师信息回调
    func teacherInfo(_ id: String, needCompany: Bool = false, completion: @escaping (TeacherInfo?) -> ()) {
        if let info = teacherInfos[id], (!needCompany || info.company != nil) {
            completion(info) // 内存获取
        } else {
            guard !inUpdataingIds.contains(id) else {
                // 用户信息正在请求
                SSLog("用户信息正在请求")
                return
            }
            inUpdataingIds.insert(id)
            
            SSNetworkManager.shared().get(XD_FETCH_TEACHER_INFO,
                                          parameters: ["imUserId": id],
                                          success: { [weak self] (_, response) in
                                            self?.inUpdataingIds.remove(id)
                                            guard let res = response else { return }
                                            let json = JSON(res)["data"]
                                            let info = TeacherInfo(id: id,
                                                                   name: json["name"].stringValue,
                                                                   title: json["title"].stringValue,
                                                                   workYear: json["yearsOfWorking"].stringValue,
                                                                   avatar: json["avatar"].stringValue,
                                                                   status: json["status"].intValue,
                                                                   company: json["organization"]["name"].stringValue,
                                                                   companySubTitle: json["organization"]["subtitle"].stringValue,
                                                                   companyLogo: json["organization"]["logo"].stringValue,
                                                                   companyDesc: json["organization"]["introduction"].stringValue,
                                                                   schoolCertified: json["schoolCertified"].boolValue,
                                                                   school: json["school"].stringValue,
                                                                   likesNum: json["likesCount"].intValue,
                                                                   video: json["video"].stringValue)
                                            self?.insertTeacherInfo(info, storage: true)
                                            NotificationCenter.default.post(name: .TeacherInfoUpdated, object: nil, userInfo: [TeacherInfoKey: info])
                                            completion(info)
                                            //MARK: 崩溃出现的地方
                }, failure: { [weak self] (_, error) in
                    guard let sSelf = self else { return }
                    sSelf.inUpdataingIds.remove(id)
                    // 尝试数据库获取
                    if let infoModel = sSelf.realm.objects(TeacherInfoModel.self).filter("id = '\(id)'").first, (!needCompany || infoModel.company != nil) {
                        sSelf.teacherInfos[id] = infoModel.toInfo()
                        completion(infoModel.toInfo())
                    }
                    SSLog(error.localizedDescription)
            })
            
        }
    }
    
    private func insertTeacherInfo(_ teacherInfo: TeacherInfo, storage: Bool = false) {
        teacherInfos[teacherInfo.id] = teacherInfo
        if storage {
            try? realm.write {
                realm.add(teacherInfo.toModel(), update: true)
            }
        }
    }
}

extension Notification.Name {
    public static let TeacherInfoUpdated: NSNotification.Name = NSNotification.Name("TeacherInfoUpdated")
}
