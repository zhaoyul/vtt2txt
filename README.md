# vtt2txt
Janet语言项目, 处理vtt字幕到 txt 文本.

## 用法

确保已安装 [Janet](https://janet-lang.org/), 然后运行:

```bash
janet vtt2txt.janet input.vtt output.txt
```

* 如果省略 `output.txt`, 转换结果会直接打印到标准输出。
* 脚本会去除 `WEBVTT` 头、编号、时间戳以及 `NOTE`/`STYLE`/`REGION` 块，只保留字幕文本。
