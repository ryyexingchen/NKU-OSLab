# Lab3:缺页异常和页面置换
## 一、实验目的

 * 了解虚拟内存的Page Fault异常处理实现
 * 了解页替换算法在操作系统中的实现
 * 学会如何使用多级页表，处理缺页异常（Page Fault），实现页面置换算法。

## 二、实验过程

### 练习1：分配并初始化一个进程控制块（需要编码）

`alloc_proc`函数（位于`kern/process/proc.c`中）负责分配并返回一个新的`struct proc_struct`结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

> 【提示】: 在`alloc_proc`函数的实现中，需要初始化的`proc_struct`结构中的成员变量至少包括：`state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name`。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：
- 请说明`proc_struct`中 `struct context context` 和 `struct trapframe *tf` 成员变量含义和在本实验中的作用是什么？（提示通过查看代码和编程调试可以判断出来）



#### （1）分配并初始化进程控制块的实现

在`alloc_proc`函数中，我们的主要目标是分配一个`proc_struct`结构并初始化其各个成员变量。以下是`proc_struct`结构体的定义：

```c
struct proc_struct {  // 进程控制块结构
    enum proc_state state;                     // 进程状态
    int pid;                                   // 进程标识符
    int runs;                                  // 进程运行时间片
    uintptr_t kstack;                          // 内核栈地址
    volatile bool need_resched;                // 调度标志
    struct proc_struct *parent;                // 父进程指针
    struct mm_struct *mm;                      // 进程的虚拟内存管理结构
    struct context context;                    // 进程上下文信息
    struct trapframe *tf;                      // 中断帧指针
    uintptr_t cr3;                             // 页表基址
    uint32_t flags;                            // 进程标志位
    char name[PROC_NAME_LEN + 1];              // 进程名称
    list_entry_t list_link;                    // 进程链表节点
    list_entry_t hash_link;                    // 进程哈希链表节点
};
```

在`alloc_proc`函数中，我们逐一初始化这些成员变量，代码示例如下：

```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct)); // 分配PCB内存
    if (proc != NULL) {
        proc->state = PROC_UNINIT;            // 初始化状态为未初始化
        proc->pid = -1;                       // 默认PID为-1
        proc->runs = 0;                       // 初始化运行时间片
        proc->kstack = 0;                     // 内核栈地址初始化为0
        proc->need_resched = 0;               // 初始时无需调度
        proc->parent = NULL;                  // 父进程为空
        proc->mm = NULL;                      // 虚拟内存管理结构为空
        memset(&(proc->context), 0, sizeof(struct context));  // 清空上下文
        proc->tf = NULL;                      // 中断帧指针初始化为空
        proc->cr3 = boot_cr3;                 // 页表基址设置为内核页表
        proc->flags = 0;                      // 标志位初始化为0
        memset(proc->name, 0, PROC_NAME_LEN); // 清空进程名
    }
    return proc;
}
```

具体实现说明如下：

- `state`：表示进程当前的状态，初始为`PROC_UNINIT`，即未初始化。
- `pid`：进程的唯一标识符，初始值为-1，表示尚未分配。
- `runs`：记录进程的运行时间片，初始为0。
- `kstack`：用于存储内核栈的起始地址，初始值为0。
- `need_resched`：标记是否需要重新调度，初始值为0（表示不需要）。
- `parent`：指向父进程的指针，初始为空。
- `mm`：指向虚拟内存管理结构的指针，初始为空。
- `context`：保存上下文信息的结构体，用于进程切换，初始化为0。
- `tf`：指向中断帧的指针，初始值为空。
- `cr3`：进程使用的页表基地址，初始值设置为内核页表基地址`boot_cr3`。
- `flags`：存储进程的标志位，初始值为0。
- `name`：进程名称，初始化为空字符串。

#### （2）`context` 和 `tf` 的作用

1. **`context` 的作用**：
   - `context` 是一个结构体，用于保存进程的寄存器状态，在进程上下文切换时用于恢复现场。
   - 它包含程序计数器（`eip`）、栈指针（`esp`）以及其他重要寄存器。
   - 进程切换时，当前进程的上下文被保存到`context`中，切换回该进程时通过加载`context`恢复寄存器状态。

2. **`tf` 的作用**：
   - `tf` 指向中断帧的结构体，保存了进程在中断或陷入内核态时的寄存器状态。
   - 当用户态进程进入内核态时，CPU会自动将寄存器状态保存到中断帧中。
   - 内核通过修改`tf`结构的内容，可以实现从中断或系统调用返回时恢复用户态进程的执行。

通过`context`和`tf`，可以实现进程的上下文切换以及中断处理机制，保证了多任务环境下进程的正常运行。
