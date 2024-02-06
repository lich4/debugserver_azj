## 说明

安装本插件后，可以用Xcode调试任意iOS进程，相关帖子见<https://www.52pojie.cn/thread-1808827-1-1.html>。(支持无根越狱,支持arm64e,iOS9-iOS15已测试过)

(This tweak is used to debug any iOS process with XCode)  

* 安装完本插件需要重新插拔USB，以便注入到lockdownd生效。  
* 若App有反调试，需要先想办法去除反调试  
* 若调试老型号手机出现Jetsam相关错误，为调试时内存占用过大被系统kill，需要开发tweak使用memorystatus_control修改下进程权限。这种情况笔者在分析iOS10的SpringBoard界面元素时遇到过  
* 附加时间: iOS15 > iOS13/14 > iOS12 ... ；iOS15上附加进程速度会比较慢，笔者测附加Safari在2分钟左右  
* XCode12.x附加调试iOS15的SpringBoard会因为时间过长而导致桌面被系统kill，但XCode13.x却可以  
* 本插件只增强附加调试，会影响XCode调试普通App，所以代码中设置last_inst_time用于记录IPA安装时间避开XCode安装调试。(其实也可以在设置里增加开关来控制是否root身份启动debugserver不过那样更麻烦一些)。

## 生成可用的debugserver

只需生成一次,确认debugserver满足以下条件直接跳过这一步
1. debugserver必须支持lockdown和frontboard模式:`debugserver --lockdown --launch=frontboard`  
2. bingner源中的debugserver无法满足要求  
 
### 挂载/Developer分区

1. 连接XCode调试后会自动挂载
2. 手动挂载失败原因:系统版本不匹配/Developer目录不为空/已经挂载成功

手动挂载:

```
cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/12.4
ideviceimagemounter -d -t Developer DeveloperDiskImage.dmg DeveloperDiskImage.dmg.signature
deviceconsole | grep MobileStorageMounter # 查看错误
```

### 重签名

由于Developer的debugserver权限不够,无法调试第三方进程,因此需要重签名: 

## 执行签名并归位

ida的ios debugger使用lockdown服务,会操作/Developer/usr/bin/debugserver

```bash
cp -f /Developer/usr/bin/debugserver debugserver
ldid -S1.xml debugserver
umount /Developer # 操作前关闭包括debugserver在内的关联进程
mkdir -p /Developer/usr/bin
cp debugserver /Developer/usr/bin/

kernel(AppleMobileFileIntegrity)[0] <Notice>: AMFI: '/usr/bin/debugserver_azj' has no CMS blob?
kernel(AppleMobileFileIntegrity)[0] <Notice>: AMFI: '/usr/bin/debugserver_azj': Unrecoverable CT signature issue, bailing out.
kernel(AppleMobileFileIntegrity)[0] <Notice>: AMFI: code signature validation failed.
此错误需要在Mac上执行ldid -S
```

## ida查看进程列表

todo

## 编译 

```bash
make package
make -f MakefileRootless package  # rootless
```

注意rootless的包为`***_iphoneos-arm64.deb`


![](https://raw.githubusercontent.com/lich4/debugserver_azj/main/screenshot.png)

