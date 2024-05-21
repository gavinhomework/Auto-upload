1. 将Auto_upload_to_KV.sh下载到CloudflareST文件夹中，chmod +x Auto_upload_to_KV.sh 然后执行 ./Auto_upload_to_KV.sh proxyip.txt 将自动完成测速并上传到KV库中。可以选择电报通知。

2. YXYM-upload.sh是测速并批量上传A记录到CF中的脚本。
3. 请确保你已经替换以下信息：
API_TOKEN：你的 Cloudflare API 令牌
ZONE_ID：你的 Cloudflare Zone ID
SUBDOMAIN：你的二级域名（例如 sub）
DOMAIN：你的主域名（例如 example.com）
说明
删除现有的 A 记录：脚本首先获取所有现有的 A 记录 ID，并逐一删除这些记录。
添加新的 A 记录：在删除所有旧记录后，脚本读取 yuming.txt 文件中的每个 IP 地址并创建新的 A 记录。
检查删除操作：删除操作是不可逆的，请确保你确实希望删除现有的所有 A 记录。
运行这个脚本后，所有该二级域名下现有的 A 记录将被删除，并根据 yuming.txt 文件中的 IP 地址重新创建新的 A 记录。

