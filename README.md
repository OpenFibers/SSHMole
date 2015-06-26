#SSHMole

OSX 下使用 ssh 穿越功夫网。  

##使用说明
没那么多乱七八糟的规则，填上 ssh 帐号就开启穿越之旅。目前仅支持全局代理。  

![demo](https://raw.githubusercontent.com/OpenFibers/SSHMole/master/demo.png)

##已编译好的App下载链接
[SSHMole v0.1](https://github.com/OpenFibers/SSHMole/raw/master/Product/SSHMole_v0.1.zip)

##TODO
1. 编辑好pac后，切到off mode再切回auto mode，强制系统刷新pac
2. helper增加版本号函数，以便升级后更新。另外需要支持传入proxy uri
3. 使用不同的uri表示黑名单和白名单pac，以便切换mode时，系统能够刷新缓存
4. server config增加id
5. server list bug，更改local port会往keychain里写入重复条目
