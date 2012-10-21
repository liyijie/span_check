IE工具生成和校验

配置文件放置的目录和路径：
1. xml文件放置路径和说明
  目录：sample
  文件：IEConfig.xml, IEList.xml
  说明：放置目前最新的配置文件，会对原来的内容进行保留

2. 文档放置路径和说明
  目录：doc/iemap，doc/ieconfig
  说明：这两个目录中是可以放多个配置文件，进行合并生成
      其中ieconfig第一个sheet页可以是硬编码的说明，iemap的最后一个sheet页可以是其他说明


1. 生成IE相关文件（note：需要保证原来使用的短名称映射不进行变化，因为代码和报表模板中都有进行使用）
  IEConfig.xml        界面使用
  IEList.xml          所有IE全名和短名称的映射
  LogFormat.xml       Log日志记录使用对于IE进行分组的信息
  LC_LTE_IE.xml       手机结构解析和IE表达式的配置文件
  TableIEsConfig.ini  数据库关联文件

2. 检验功能
  

安装
gem install parseexcel
gem install builder
gem install nokogiri
