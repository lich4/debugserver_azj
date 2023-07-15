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

