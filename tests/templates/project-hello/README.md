# myapp（Shux 脚手架）

由 `scripts/shux-new.sh` 生成的最小项目。

## 运行

```bash
shux run main.sx
```

## 编译

```bash
shux build main.sx -o myapp
./myapp
echo $?   # 42
```

## 格式化（可选）

```bash
shux fmt main.sx
shux fmt --check main.sx
```
