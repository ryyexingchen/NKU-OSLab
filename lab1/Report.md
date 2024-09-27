# 最小可执行程序与中断处理
## lab0.5
### 练习1: 使用GDB验证启动流程
#### 练习过程
- 启动 QEMU 和 GDB
在实验中，我们首先需要通过 make debug 启动 QEMU 并进入调试模式，然后使用 GDB 附加到 QEMU 进程中。

![image-lab0.5-1.png](image/image-lab0.5-1.png)

- RISC-V硬件加电后的几条指令

![image-lab0.5-2.png](image/image-lab0.5-2.png)

-设置断点，模拟执行
