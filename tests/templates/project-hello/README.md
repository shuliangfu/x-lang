# myapp（Xlang 脚手架）

由 `scripts/xlang-new.sh` 生成的最小项目。

## 运行

```bash
xlang run main.x
```

## 编译

```bash
xlang build main.x -o myapp
./myapp
echo $?   # 42
```

## 格式化（可选）

```bash
xlang fmt main.x
xlang fmt --check main.x
```
