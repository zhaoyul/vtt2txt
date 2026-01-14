(declare-project
  :name "vtt2txt"
  :description "Convert WebVTT subtitles to plain text."
  :version "0.1.0"
  :license "MIT"
  :url "https://github.com/zhaoyul/vtt2txt")

(declare-executable
  :name "vtt2txt"
  :entry "vtt2txt.janet"
  :install true)
