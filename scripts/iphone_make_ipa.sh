
#!/bin/bash
set -e

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

PWD_STR=`pwd`
SCRIPT_NAME=$(basename $0)
IS_ENV_RVM=`[ $SCRIPT_NAME == "rvm_build" ] && echo true || echo false`

if [[ $PWD_STR =~ "/scripts" ]]; then
  echo ""
  echo "ERROR:  You should not call iphone_make_ipa.sh within DIR: scripts"
  echo "SYNTAX: bash script/iphone_make_ipa.sh"
  echo ""
  exit -1
fi

## 参考: http://stackoverflow.com/questions/14793329/fixing-file-project-pch-has-been-modified-since-the-precompiled-header-was-bui

## 1. 读取用户以及应用程序的配置

source scripts/adhoc_deploy.config

touch ${PCH_FILE}

PRODUCT_NAME="${TARGET_NAME}_${RELEASE_OR_DEBUG}"

## 1.4 清除历史
if [ -d build ]; then
    rm -rf build
fi

# 确保ruby用的是系统版本
if $IS_ENV_RVM ; then
    echo "rvm use system"
    rvm use system
fi

# 首先clean一下
xcodebuild clean -project ${TARGET_NAME}.xcodeproj -configuration ${RELEASE_OR_DEBUG} -alltargets

# archive文件路径
ARCHIVE_PATH="${PWD_STR}/build/${TARGET_NAME}.xcarchive"
# .ipa文件生成路径
IPA_PATH="${PWD_STR}/build/${PRODUCT_NAME}"

# 获取项目info.plist文件路径
appInfoPlistPath="${PWD_STR}/${TARGET_NAME}/Info.plist"
# 获取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${appInfoPlistPath})
#获取build版本号
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${appInfoPlistPath})

# 生成archive文件
xcodebuild archive -workspace ${TARGET_NAME}.xcworkspace -scheme ${TARGET_NAME} -archivePath ${ARCHIVE_PATH}
echo "create achieve success"

# 签名并且导出ipa文件
xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} -exportPath ${IPA_PATH} -exportOptionsPlist ${EXPORT_OPTIONS_PATH}
echo "create ipa success"

cd "${PWD_STR}"


## 上传到fir.im
IPA="${IPA_PATH}/${TARGET_NAME}.ipa"
 
if [ -z "$IPA" ]
then
	echo "Syntax: upload_fir.sh {my-application.ipa}"
	exit 1
fi

USER_TOKEN=${FIR_USER_TOKEN}
APP_ID=${FIR_APP_ID}
 
echo "getting token"
 
echo url http://api.fir.im/apps/${APP_ID}/releases?api_token=${USER_TOKEN}

INFO=`curl -F "api_token=${USER_TOKEN}" http://api.fir.im/apps/${APP_ID}/releases`

#echo response ${INFO}

KEY=$(echo ${INFO} | grep "binary.*upload_url" -o | grep "key.*$" -o | awk -F '"' '{print $3;}')
TOKEN=$(echo ${INFO} | grep "binary.*upload_url" -o | grep "token.*$" -o | awk -F '"' '{print $3;}')
UPLOADURL=$(echo ${INFO} | grep "binary.*" -o | grep "upload_url.*$" -o | awk -F '"' '{print $3;}')

echo key ${KEY}
echo token ${TOKEN}
echo upload_url ${UPLOADURL}

echo "uploading to fir"
APP_INFO=`curl -# -F file=@${IPA} -F "key=${KEY}" -F "token=${TOKEN}" -F "x:version=${bundleShortVersion}" -F "x:build=${bundleVersion}" —F "x:name=${TARGET_NAME}" ${UPLOADURL}`
 
if [ $? != 0 ]
then
	echo "upload to fir error"
	exit 1
fi

echo ${APP_INFO}

#上传到蒲公英
API_KEY=${PGY_API_KEY}
USER_KEY=${PGY_USER_KEY}
PGY_URL="https://qiniu-storage.pgyer.com/apiv1/app/upload"

echo "uploading to pgy"
APP_INFO=`curl -# -F file=@${IPA} -F uKey=${USER_KEY} -F _api_key=${API_KEY} ${PGY_URL}`



if [ $? != 0 ]
then
echo "upload to pgy error"
exit 1
fi

echo ${APP_INFO}

echo "/n upload success"

