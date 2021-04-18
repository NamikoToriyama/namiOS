# namiOS
作って理解するOSのコード([amazon](https://amzn.to/2Qzoq7m))

Support page:
https://gihyo.jp/book/2019/978-4-297-10847-2/support

## qemu
```c
qemu-system-i386 boot.img
```

## bochs
```c
bochs -q -f ../../env/.bochsrc -rc ../../env/cmd.init
```

## アセンブル
```
../../env/mk.sh
```

## プログラム終了
```
ctl + alt + End(fn + →)
```