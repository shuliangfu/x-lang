# myapp（Shulang 脚手架）

由 `scripts/shu-new.sh` 生成的最小项目。

## 运行

```bash
shu run main.su
```

## 编译

```bash
shu build main.su -o myapp
./myapp
echo $?   # 42
```

## 格式化（可选）

```bash
shu fmt main.su
shu fmt --check main.su
```
