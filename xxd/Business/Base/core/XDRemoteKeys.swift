//
//  XDRemoteConfig.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

// 首页
let XD_API_INDEX = "view/app/tab/index"
// 美高首页
let XD_API_INDEX_HIGHSCHOOL = "view/app/tab/index/highschool"
// 首页广告
let XD_API_HOME_BANNER = "business/app-index-banner"
// 启动广告页
let XD_API_LAUNCH_AD = "business/launch"
// 综合搜索
let XD_API_SEARCH = "search"
// 院校列表
let XD_API_COLLEGE_LIST = "schools"
// 排名大全
let XD_API_RANK_CATEGORIES = "rank/categories/index"
// 排名目录搜索
let XD_API_RANK_CATEGORIES_SEARCH = "rank/categories"
// 大学排名列表
let XD_API_COLLEGE_RANKS = "ranks"
// 世界专业排名列表
let XD_API_WORLD_MAJOR_RANKS = "lov/data/DATA_WORLD_MAJOR_RANKINGS/value"
// 美国专业排名列表
let XD_API_US_MAJOR_RANKS = "lov/data/DATA_USA_MAJOR_RANKINGS/value"
// 根据大类分的热门专业
let XD_API_HOT_MAJOR_BYC = "major_lib/major/hottest/by_category"
// 获取全球专业排名列表
let XD_API_MAJOR_GLOBAL = "rank/categories/major/global"
// 获取美本排名列表
let XD_API_MAJOR_USA_BACHELOR = "rank/categories/major/us/undergraduate"
// 获取美国研究生排名列表
let XD_API_MAJOR_USA_MASTER = "rank/categories/major/us/graduate"
// 艺术专业排名
let XD_API_ART_RANKS = "arts/ranked/majors"
// 艺术专业院校排名
let XD_API_ART_MAJOR_COLLEGE_RANKS = "arts/ranked/programs"
// 专业库列表
let XD_API_MAJOR_LIB_LIST = "major_lib/majors"
// 项目库列表
let XD_API_PROGRAM_LIST = "major_lib/programs"
// 项目相关院校列表
let XD_API_PROGRAM_COLLEGE_LIST = "major_lib/program/%zd/schools"
// 获取指定tag的资讯列表
let XD_API_INFO_WITH_TAG = "news"
// 获取用户浏览的学校数据
let XD_API_INDEX_COLLEGE_HISTORY = "schools/viewed"

// 我的信息
let XD_API_PERSONAL_INFO = "personal/info"
// 个人信息选项
let XD_API_PERSONAL_OPTIONS = "personal/info/options"
// 完善个人信息选项
let XD_API_COMPLETION_OPTIONS = "personal/info/v2/init/options"
// 我的信息v2,包括个人信息选项
let XD_API_PERSONAL_INFO_V2 = "personal/info/v2"
// 查看其他用户信息
let XD_API_OTHER_PERSONAL_INFO = "user/%zd/info/v2"
// 获取验证码
let XD_API_GET_CAPTCHA = "user/captcha"
// 注册
let XD_API_USER_REGISTER = "user/register"
// logout
let XD_API_USER_LOGOUT = "user/logout"
// 意见反馈
let XD_API_FEEDBACK_EDIT = "feedback"
// 版本检测
let XD_API_VERSION_CHECK = "ios/version/check/%@"

// 二维码验证
let XD_API_QRCODE_VERIFY = "user/qrcode/verify"
// 二维码确认登录
let XD_API_QRCODE_CONFIRM_LOGIN = "user/qrcode/confirm"

// 问答列表
let XD_API_QUESTION_LIST = "questions/v2/list"
// 推荐问答列表
let XD_API_RECOMMEND_QUESTION_LIST = "questions/v2/list/recommended"
// 我的问答列表
let XD_API_MY_QUESTION_LIST = "questions/v2/list/mine"
// 问答详情
let XD_API_QUESTION_DETAIL = "questions/v2/%zd"
// 顾问详情
let XD_API_COUNSELLOR_DETAIL = "counsellor/user"
// 追问
let XD_API_SUB_QUESTION_APPEND = "questions/v2/%zd/answer/%zd/sub_question"
// 对老师的回复进行评价
let XD_API_RATE_QUESTION = "questions/v2/%zd/answer/%zd/rating"
// 将学生的完善信息发送给老师
let XD_API_QUESTION_REQUESTINFO = "questions/v2/%zd/requestInfo/%zd/info"
// 获取提问时需要携带的国家和项目选项
let XD_API_ASK_OPTIONS = "questions/v2/post/options"
// 提问
let XD_API_ASK_QUESTION = "questions/v2"
// 我的收藏
let XD_API_MY_FAVORITE_LIST = "collection/composite"
// 添加收藏
let XD_API_ADD_FAVORITE = "collection/%@/%@"
// 通用的点赞接口
let XD_API_GENERAL_LIKE = "favorite/%@/%@"

// 课程列表
let XD_API_COURSE_LIST = "course/list"
// 分组课程列表
let XD_API_COURSE_GROUP_LIST = "course/list/grouped"
// 课程简要信息
let XD_API_COURSE_BRIEF = "course/%zd/brief"
// 课程介绍
let XD_API_COURSE_INTRO = "course/%zd/introduction"
// 课程大纲
let XD_API_COURSE_OUTLINE = "course/%zd/outline"
// 获取课程播放地址
let XD_API_FETCH_COURSE_PLAY_URL = "course/play"
// 课程评价列表
let XD_API_COURSE_EVALUATION = "course/%zd/comments"
// 提交课程评价
let XD_API_COURSE_SUBMIT_EVALUATION = "course/%zd/comment"
// 关闭某门课程的推荐
let XD_API_COURSE_CLOSE_RECOMMEND = "course/recommended/%zd"

// 我的选校
let XD_API_MY_COLLEGE = "match_school/list"
// 我的选校修改
let XD_API_MY_COLLEGE_EDIT = "match_school"
// 我的选校删除
let XD_API_MY_COLLEGE_REMOVE = "match_school/%zd"

// 录取率测试
let XD_API_ADMISSION_RATE = "admission_rate"
// 录取率测试选项数据
let XD_API_ADMISSION_RATE_OPTIONS = "admission_rate/options"
// 录取率测试次数
let XD_API_ADMISSION_TEST_COUNT = "admission_rate/test_count"
// 智能选校
let XD_API_SMART_COLLEGE = "match_school/match"
// 智能选校选项数据
let XD_API_SMART_COLLEGE_OPTIONS = "match_school/options"
// 智能选校次数
let XD_API_SMART_COLLEGE_COUNT = "match_school/test_count"
// 智能选专业问题
let XD_API_SMART_MAJOR_QUESTIONS = "major_test/questions"
// 智能选专业
let XD_API_SMART_MAJOR_ANSWER = "major_test/answer"
// 智能选专业次数
let XD_API_SMART_MAJOR_COUNT = "major_test/test_count"

// 获取约答卡
let XD_API_CARD_APPOINTMENT = "card/appointment"
// 使用约答卡
let XD_API_CARD_APPOINTMENT_USE = "card/appointment/use"
// 获取约答卡信息
let XD_API_CARD_APPOINTMENT_USAGE = "card/appointment/usage"

// 获取指定tag的资讯列表
let XD_API_VISA_INFO = "stage/visa/news"
// 新首页
let XD_API_STUDY_ABROAD = "view/app/tab/index"
// 消息中心
let XD_API_MESSAGE_CENTER_LIST = "notification/list"

// 院校详情简介页
let XD_API_COLLEGE_INTRO = "view/school/brief"
// 院校详情页
let XD_API_COLLEGE_DETAIL = "view/school/index"
// 院校纠错
let XD_API_COLLEGE_CORRECTION = "correction"
// 美高详情页
let XD_API_HIGHSCHOOL_DETAIL = "highschool/%zd"

// 专题中心
let XD_API_SPECIAL_LIST = "subject/list"

// 留学签证列表
let XD_API_VISA_LIST = "stage/visa/"
// 留学签证常见问题
let XD_API_VISA_FAQ = "stage/visa/faq"
// 留学签证地址
let XD_API_VISA_CENTERS = "stage/visa/centers"
// IDFA
let XD_API_IDFA_CHECK = "idfa"

// GPA计算
let XD_API_GPA_CALCULATE = "tool/gpa_calc"
// GPA算法
let XD_API_GPA_ALGORITHMS = "tool/gpa_calc/algorithms"

// 留学规划
let XD_API_ABROAD_TIMELINES = "abroad_plan/timelines"
// 留学规划选项
let XD_API_ABROAD_TIMELINES_OPTIONS = "abroad_plan/timelines/options"

// 活动库列表
let XD_API_ACTIVITY_LIST = "activity/project/list"
// 活动详情
let XD_API_ACTIVITY_DETAIL = "activity/project/%zd"

// 考试时间表
let XD_API_EXAM_SCHEDULE = "exam_schedule"
// 我的考试计划
let XD_API_EXAM_SCHEDULE_MINE = "exam_schedule/mine"
let XD_API_EXAM_SCHEDULE_OPERATE = "exam_schedule/mine/%zd"
let XD_API_EXAM_SCHEDULE_CHECKIN = "exam_schedule/%zd/checkin"
// 查看参加某次考试的用户列表
let XD_API_EXAM_SCHEDULE_OTHERS = "exam_schedule/%zd/examinee"

// app下载地址
let XD_WEB_APP_DOWNLOAD_URL = "https://itunes.apple.com/cn/app/id1230298344"
// app评分地址
let XD_WEB_APP_GRADE_URL = "itms-apps://itunes.apple.com/cn/app/id1230298344?action=write-review"
// 斩托福下载地址
let XD_WEB_TOEFL_DOWNLOAD_URL = "itms-apps://itunes.apple.com/cn/app/id1140024057"
// 斩雅思下载地址
let XD_WEB_IELTS_DOWNLOAD_URL = "itms-apps://itunes.apple.com/cn/app/id1126218840"
// 智课名师课下载地址
let XD_WEB_ZKMSK_DOWNLOAD_URL = "itms-apps://itunes.apple.com/cn/app/id1279236686"
// 学校详情
let XD_WEB_COLLEGE_DETAIL = "school/%zd.html"
// 本科申请
let XD_WEB_UNDERGRADUATE = "school/%zd/undergraduate-application-department-first.html"
// 研究生申请
let XD_WEB_GRADUATE = "school/%zd/graduate-application-department-first.html"
// 资讯详情
let XD_WEB_NEWS_DETAIL = "news/detail-%zd.html"
// 用户协议
let XD_WEB_AGREEMENT = "user-agreement.html"
// 录取率测试分享
let XD_WEB_ADMISSION_RATE_RESULT = "tool/admission-rate-result/%zd.html"
// 智能选校分享
let XD_WEB_SMART_COLLEGE_RESULT = "tool/match-school-result-%@.html"
// 智能选专业分享
let XD_WEB_SMART_MAJOR_RESULT = "tool/holland-major-test-result-%zd.html"
// 专业详情
let XD_WEB_MAJOR_DETAIL = "major-lib/%zd.html"
// 高中意向地对比
let XD_WEB_HIGHSCHOOL_REFER_DETAIL = "compare-highschool-countries.html"
// 本科意向地对比
let XD_WEB_UNDERGRADUATE_REFER_DETAIL = "compare-undergraduate-countries.html"
// 研究生意向地对比
let XD_WEB_GRADUATE_REFER_DETAIL = "compare-graduate-countries.html"
// 院校详情介绍页
let XD_WEB_COLLEGE_DETAIL_INTRO = "school/%zd/introduction.html"
// 院校详情页本科生
let XD_WEB_COLLEGE_DETAIL_BACHELOR = "school/%zd/undergraduate-application-department-first.html"
// 院校详情页研究生页
let XD_WEB_COLLEGE_DETAIL_MASTER = "school/%zd/graduate-application-department-first.html"
// 院校详情艺术生页
let XD_WEB_COLLEGE_DETAIL_ART = "school/%zd/sia"
// 院校详情页问答页
let XD_WEB_COLLEGE_DETAIL_QUESTION = "qs/questions-1.html"
// 留学服务
let XD_WEB_VISA_SERVICE = "study-abroad-service"
// 课程推荐
let XD_WEB_COURSE_RECOMMEND = "https://www.smartstudy.com/%@/course"

// IM
let XD_IM_TEACHER_LIST = "counsellor/list"
let XD_REFRESH_IM_TOKEN = "user/im/refresh"
let XD_FETCH_TEACHER_INFOS = "counsellor/bulk"
let XD_FETCH_TEACHER_INFO = "counsellor/user"
let XD_FETCH_REPORT_REASONS = "counsellor/inform/reasons"
let XD_SUBMIT_REPORT = "counsellor/inform"
let XD_LIKE_FOR_TEACHER = "counsellor/user/like"

//美高
// 获取美高排名数据
let XD_HSAPI_RANK_LIST = "highschool/list"
// 获取美高排行筛选条件
let XD_HSAPI_RANK_OPTIONS = "/highschool/list/options/app"
// 获取美高排行分类
let XD_HSAPI_RANK_CATEGORIES = "/highschool/ranks"
// 获取特定分类的美高排行
let XD_HSAPI_SPEC_RANK_LIST = "/highschool/rank/%zd/schools"

//
// 获取某选校的选校数据
let XD_TARGET_COLLEGE_STAT = "school/%zd/watchers/stat"
// 获取选择了某所大学的学生的其它选校信息
let XD_TARGET_COLLEGE_OTHERS = "school/%zd/watchers"
// 获取某个用户的选校信息
let XD_TARGET_COLLEGE_OTHER_DETAIL = "user/%zd/watch/data"
// 获取某个用户选校信息主页中的评论数据
let XD_TARGET_COLLEGE_OTHER_COMMENTS = "user/%zd/watch/comments"
// 设置自己的选校信息是否对其他用户可见
let XD_TARGET_COLLEGE_SET_PRIVACY = "user/info/watch/visibility"
// 对其他用户的选校点赞
let XD_TARGET_COLLEGE_LIKE = "user/%zd/watch/like"
// 对用户的选校评论
let XD_TARGET_COLLEGE_COMMENT = "user/%zd/watch/comment"

// 研究生专业相关
// 获取热门专业及其分类
let XD_MASTER_MAJOR_CATEGORIES = "school_major/categories"
// 获取某个专业的详情
let XD_MASTER_MAJOR_DETAITL = "school_major/category/%zd"
// 获取某个专业的项目列表
let XD_MASTER_PROGRAM_LIST = "school_major/programs"
// 获取某个项目的详情
let XD_MASTER_PROGRAM_DETAIL = "school_major/program/%zd"

// 专栏
// 获取专栏文章列表
let XD_COLUMN_LIST = "column/news"
// 获取专栏文章
let XD_COLUMN_DETAIL = "column/news/%zd"
// 获取文章的评论列表
let XD_COLUMN_COMMNET_LIST = "column/news/%zd/comments"
// 发表相关评论
let XD_COMLUMN_POST_COMMNET = "column/news/%zd/comments"

