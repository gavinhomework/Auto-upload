#!/bin/bash

# 执行 CloudflareST 测试并生成 cdnip.csv 文件
./CloudflareST --allip -n 200 --httping-code 200 -sl 3 -tl 300 -o cdnip.csv

# 使用 grep 提取 IP 地址并写入到 cdnip.txt 文件中
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' cdnip.csv > cdnip.txt || { echo "Error: Failed to extract IP addresses from cdnip.csv" ; exit 1; }

# 使用 sed 在 cdnip.txt 文件中每行末尾添加文字，并输出到 proxyip.txt 文件中
sed 's/$:2096等/#后修改为你想要添加的文字/' cdnip.txt > proxyip.txt || { echo "Error: Failed to add text to cdnip.txt" ; exit 1; } #默认443，可以添加

# 提示完成
echo "IP 地址提取并添加完成，请查看 proxyip.txt 文件。"

# 导出 LANG 变量
export LANG=zh_CN.UTF-8

# 定义 Cloudflare KV 相关信息
DOMAIN="填写KV库的pages地址"
TOKEN="填写KV密码"

# 检查是否有传入文件名参数
if [ -n "$1" ]; then 
  FILENAME="$1"
else
  echo "请输入要上传的文件名"
  exit 1
fi

# 验证文件是否存在
if [ ! -f "$FILENAME" ]; then
  echo "Error: File $FILENAME does not exist."
  exit 1
fi

# 使用 head 命令读取文件前 65 行，并转换为 Base64 编码
BASE64_TEXT=$(head -n 65 "$FILENAME" | base64 -w 0) || { echo "Error: Failed to read and base64 encode the file" ; exit 1; }

# 使用 curl 命令上传文件到 Cloudflare KV 存储
UPLOAD_RESULT=$(curl -k "https://$DOMAIN/$FILENAME?token=$TOKEN&b64=$BASE64_TEXT") || { echo "Error: Failed to upload the file to Cloudflare KV" ; exit 1; }

# 输出上传结果
echo "文件上传结果：$UPLOAD_RESULT"

# 提示完成
echo "更新数据完成"

# 读取 liantong.txt 文件的内容
MESSAGE=$(cat proxyip.txt)


# 定义 Telegram 机器人的 API Token 和 Chat ID
TELEGRAM_API_TOKEN="你的电报APIkey"
CHAT_ID="你的chatid"

# 验证 Telegram API Token 和 Chat ID 是否有效
if [ -z "$TELEGRAM_API_TOKEN" ] || [ -z "$CHAT_ID" ]; then
  echo "Error: Invalid Telegram API Token or Chat ID"
  exit 1
fi

# 使用 curl 命令向 Telegram 发送消息
curl -s -X POST "https://telegram.neobirdfly.eu.org/bot${TELEGRAM_API_TOKEN}/sendMessage" \
     -d "chat_id=${CHAT_ID}" \
     -d "text=${MESSAGE}" || { echo "Error: Failed to send message to Telegram" ; exit 1; }

# 提示完成
echo "大爷！已经完活儿了，回见吧您嘞！"
