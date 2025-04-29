# Git Hooks

## Pre Hook

github 非付费组织无法开启「在 server 端保护私有项目的 main 分支」。

稳妥起见，可在项目本地增加一个 pre-push hook，避免误操作：

```bash
cp pre-push $repo/.git/hooks/
```
