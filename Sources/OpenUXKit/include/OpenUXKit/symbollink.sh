#!/bin/bash

# 设置目标目录的相对路径，例如向上两级目录
target_dir="../.."

# 查找目标目录下的所有 .h 文件，排除 include 文件夹，并遍历处理
find "$target_dir" -name "*.h" -not -path "*/include/*" -print0 | while IFS= read -r -d $'\0' header_file; do
  # 获取 .h 文件的相对路径（使用 sed 命令处理）
  relative_path=$(echo "$header_file" | sed "s#^$PWD/##")

  # 创建符号链接，使用相对路径
  ln -s "$relative_path" .

  # 打印提示信息
  echo "Created symlink: $(basename "$header_file") -> $relative_path"
done