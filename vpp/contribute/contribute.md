### 1. how to contribute code for vpp

```bash
# 创建wiki账号和gitrrio账号, 参考这个教程
https://www.mail-archive.com/vpp-dev@lists.fd.io/
# 配置ssh公钥和私钥, 提交公钥到gitrrio的账户settings上

# 拷贝代码
git clone "https://gerrit.fd.io/r/vpp"

# 设置上游分支
git branch --set-upstream-to=origin/master master

# 设置reviewer
git config --global --add gitreview.username "fenglei"
git config --global user.email "1579628578@qq.com"
git config --global user.name "fenglei"
git config --global --list

# 显示当前的上游分支
git branch -vv

# 检查代码格式
make checkstyle

# 检查所有格式
make checkstyle-all

# 修复代码格式
extras/scripts/checkstyle.sh --fix
or
make fixstyle

# 修复单元测试
make fixstyle-python

# 检查所有
make checkstyle-all

# 添加修改文件
git add xxx

# 消除文件结尾空白符
sed -i 's/[[:space:]]*$//' 

# 提交格式参考文档
git commit -s

# 检查提交格式
make checkstyle-commit

# git review 必须保证用户名, 邮箱和gitrrio上的账号保持一致
git review

# 这个命令将 HEAD 指针回退到上一个提交，但保留工作目录和暂存区的状态, 这样你就可以重新提交或者修改提交
git reset --soft HEAD^

# 这将彻底撤销最后一次提交，并且不会在工作目录中保留任何更改。
git reset --hard HEAD^

# 提交完返回master分支
git reset --hard origin/master

# 使用gitk[简洁]工具来阅读git log, 客户端使用需要配置x11

# 修改提交过, 但未合入的patch
git review -d <change number>
git status
git diff
git add <filename>
git commit --amend
git review

# 单元测试调试[release和debug]
# release
make test-start-vpp-in-gdb DEBUG=core TEST=test_dns
make test DEBUG=attach TEST=test_dns

# debug
make test-start-vpp-debug-in-gdb DEBUG=core TEST=test_dns
make test DEBUG=attach TEST=test_dns
```

### 2. commit external patches

```bash
# 给vpp制作外部项目的patch
git format-patch <基于分支/标签/提交>..<目标分支/标签/提交>
git format-patch HEAD~2..HEAD

# 指定起始数字
git format-patch HEAD~2..HEAD --start-number=3

# 以xdp为例
git clone git@github.com:nanfengnan1/document.git
cd xdp-tools
git add 
git commit -s
# 生成两个patch文件
git format-patch HEAD~2..HEAD
cp 0002-lib-common.mk-add-Wno-uninitialized-flags-for-gcc-an.patch ../vpp/build/external/patches/xdp-tools_1.2.9/
cp 0001-xdpdump-A-variable-sized-type-which-should-be-placed.patch ../vpp/build/external/patches/xdp-tools_1.2.9/


# 然后在vpp的pathes/xdp-tools_1.2.9目录提交新的pathes文件即可
```

### 4. commit docs

vpp document system based sphinx tools.

```bash
make docs
make docs-spell

# if commit, suggest to use make checkstyle-all
```

### 3. reference

[官方文档](https://s3-docs.fd.io/vpp/25.02/contributing/gitreview.html)

