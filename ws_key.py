#!/usr/bin/env python3
# _*_ coding:utf-8 _*_

import subprocess
import os

# 创建任何 task ws_key.py，定时对CK检查错开 5 钟左右

JD_COOKIE = os.getenv('JD_COOKIE')
if JD_COOKIE is None:
    print('Try to update JD_COOKIE.')

    cmdline = 'bash /usr/bin/task /ql/data/repo/shufflewzc_faker3_main/jd_wskey.py'
    result = subprocess.getoutput(cmdline)

    message = ''
    if '账号启用' in result:
        message = 'JD_COOKIE 失效了，账号重新启用成功'
    else:
        print(result)

    if message:
        print(message)
else:
    print('JD_COOKIE is OK.')
