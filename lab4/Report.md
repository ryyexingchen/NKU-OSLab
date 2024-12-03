# Lab4:进程管理
## 一、实验目的

 * 了解内核线程创建/执行的管理过程
 * 了解内核线程的切换和基本调度过程

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

### 练习2：为新创建的内核线程分配资源
#### (1)设计实现过程

其实实验要求中已经把实验流程说得非常清楚了。主要是编写`do_work`函数，完成具体内核线程的创建工作。流程如下：
   - 调用`alloc_proc`，获得一块用户信息块
   - 为进程分配一个内核栈
   - 复制原进程的内存管理信息到新进程
   - 复制原进程上下文到新进程
   - 将新进程添加到进程列表
   - 唤醒新进程
   - 返回新进程号
根据以上流程编写的`do_work`函数如下：
```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    // 1、调用alloc_proc，获得一块用户信息块
    proc = alloc_proc();
    if(proc == NULL){
        goto fork_out;
    }
    // 2、为进程分配一个内核栈
    proc->parent = current;
    if(setup_kstack(proc) != 0){
        goto bad_fork_cleanup_proc; // 这个地方需要把刚才分配给进程的内存释放掉
    }
    // 3、复制原进程的内存管理信息到新进程
    if(copy_mm(clone_flags, proc) != 0){
        goto bad_fork_cleanup_kstack; // 这个地方还需要把刚才分配的内核栈释放掉
    }
    // 4、复制原进程上下文到新进程
    copy_thread(proc, stack, tf);
    proc->pid = get_pid(); // 获取新进程号
    // 5、将新进程添加到进程列表
    hash_proc(proc); // 添加到hash表中
    list_add(&proc_list, &(proc->list_link)); // 添加到链表中
    // 6、唤醒新进程
    wakeup_proc(proc);
    // 7、返回新进程号
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```
#### (2)请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

先说结论：ucore确实做到了给每个新fork线程分配一个唯一的id，分配id的主要逻辑在`get_pid`函数中得以体现。`get_pid`函数的实现如下：
```c
// get_pid - alloc a unique pid for process
static int get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

接下来，我来对这个函数的核心逻辑进行分析：
   - 函数中的next_safe和last_pid是static局部变量，这意味着其在函数调用之间保持状态。这两个变量分别记录了下一个安全的pid和上一次分配的pid。由于其保存了上一次函数调用的结果，因此在next_safe和last_pid之间的任何值都是未被占用的，因此可以作为合法的pid。
   - 当`last_pid + 1 < next_safe`时，表明当前的`last_pid + 1`是合法的、未被使用的、唯一的pid，可以直接返回。
   - 如果`last_pid + 1 >= next_safe`或者`last_pid + 1 > MAX_PID`时，函数将遍历进程列表proc_list以寻找一个新的合适的区间。
   - 在上述遍历寻找新区间的过程中，如果发现last_pid已经被占用（对应函数中的`proc->pid == last_pid`），则last_pid会递增，直到找到下一个合适的区间为止。如果last_pid超过了MAX_PID，则会将last_pid重置为1，next_safe设置为MAX_PID，重新开始遍历整个区间。
   - 在完整遍历链表后，如果没有发生任何冲突，我们就可以得到一个合适的区间`[last_pid, next_safe)`，在这个区间内的所有pid都是未被使用过的、可以用来分配的pid。最终，函数会选择last_pid作为新线程的pid。

因此，通过队以上逻辑分析，`get_pid`函数为新fork线程获取了一个唯一的id。

### 练习3：编写proc_run 函数

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
```c
if (proc != current)
```
- 禁用中断
```c
local_intr_save(intr_flag);
```
- 切换当前进程为要运行的进程
```c
current = proc;
```
- 切换页表，以便使用新进程的地址空间。
```c
lcr3(proc->cr3);
```
- 实现上下文切换。
```c
switch_to(&(temp->context),&(proc->context));
```
- 允许中断。
```c
local_intr_restore(intr_flag);  
```
#### 在本实验的执行过程中，创建且运行了几个内核线程？
本次实验创建并运行了两个内核线程，即idleproc和initproc。

### Challenge

#### 说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？

两函数核心函数如下：
```c
/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
```
其作用就是设置sstatus寄存器的SIE二进制位，将其设置为0时，会将S态运行的程序禁用全部中断，将其设置为1时，会将S态运行的程序启用中断。
