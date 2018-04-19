# TrOne 一键脚本
Transmission 与 Flexget 的一键脚本，仅支持centos。

# 要求 

centos

# 使用

<pre><code> wget https://github.com/Haknima/TrOne/raw/master/TrOne.sh && bash TrOne.sh </code></pre>

#transmission 管理命令

<pre><code> 
  service transmissiond {start|stop|restart|status}
  或者
  systemctl {start|stop|restart|status} transmissiond.service
</code></pre>

默认账号： zhanghao
<br/>
默认密码： mima
<br/>
默认端口： 9091

## flexget 注意事项

flexget 配置文件存放在 /root/flexget/config.yml 修改文件需遵循YAML语法，不能使用tab，要用空格来缩进，每个层级要用两个空格缩进。
</br>
现只加入简单rss功能，其他配置可参考官方文档：https://flexget.com/Plugins
