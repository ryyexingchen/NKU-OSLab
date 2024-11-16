# Lab3:缺页异常和页面置换
## 一、实验目的

  * 了解虚拟内存的Page Fault异常处理实现 
  * 了解页替换算法在操作系统中的实现 
  * 学会如何使用多级页表，处理缺页异常（Page Fault），实现页面置换算法。 

## 二、实验过程

### 练习1：理解基于FIFO的页面替换算法（思考题）

*描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）*

*至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数。*

#### 回答（按调用顺序）：

- **`do_pgfault()`**

  发生页面缺失时，进入该函数进行初步处理，捕捉缺页中断并开始页面换入流程。

  ```c
  static int
  do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
      ...
      // 处理页面缺失，进行换入等操作
  }
  ```

- **`assert()`**

  在执行过程中对每个关键步骤进行检查，以确保页面替换流程无误。若发现问题，触发断言中断程序执行。

  ```c
  assert(condition);
  ```

- **`find_vma()`**

  检查触发缺页的虚拟地址是否在当前进程的合法虚拟地址范围内，确保访问地址的合法性。

  ```c
  struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr) {
      // 地址合法性检查
  }
  ```

- **`get_pte()`**

  获取或分配虚拟地址对应的页表项，逐层定位页表项并在必要时创建新项以建立页表结构。

  ```c
  pte_t *get_pte(pde_t *pgdir, uintptr_t va, bool create) {
      // 获取或创建页表项
  }
  ```

- **`pgdir_alloc_page()` / `alloc_page()`**

  如果页表项为空，则分配一个新的物理页并为该虚拟地址建立物理地址映射。

  ```c
  struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t va, uint32_t perm) {
      struct Page *page = alloc_page();
      // 分配物理页
  }
  ```

- **`swap_in()` / `swap_out()`**

  `swap_in()` 用于缺页异常时从硬盘换入页面，而 `swap_out()` 在内存不足时将页面换出至硬盘。

  ```c
  int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result) {
      // 从硬盘换入页面
  }
  
  int swap_out(struct mm_struct *mm, int n) {
      // 将页面换出至硬盘
  }
  ```

- **`alloc_page()`**

  分配一个空页来存储从硬盘读取的页面数据，以便后续建立虚拟地址到物理页的映射关系。

  ```c
  struct Page *alloc_page(void) {
      // 分配物理页
  }
  ```

- **`swapfs_read()`**

  通过内存和硬盘的I/O接口，将硬盘中的页面数据加载到物理内存，实现从硬盘到内存的页面换入。

  ```c
  int swapfs_read(struct Page *page, off_t offset) {
      // 从硬盘读取页面数据
  }
  ```

- **`page_insert()`**

  将换入的页面插入页表项，建立虚拟地址到物理页的映射，完成页面与虚拟地址的绑定并刷新TLB。

  ```c
  int page_insert(pde_t *pgdir, struct Page *page, uintptr_t va, uint32_t perm) {
      // 建立页表项映射并刷新TLB
  }
  ```

- **`swap_map_swappable()`**

  将换入的页面加入FIFO页面替换队列，以便未来需要时按照FIFO策略进行页面替换。

  ```c
  int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
      // 将页面加入替换队列
  }
  ```

- **`_fifo_init_mm()`**

  初始化FIFO页面置换的队列结构，函数中通过 `list_init()` 初始化双向链表 `pra_list_head`，并将`mm->sm_priv`指向该链表头。

  ```c
  static int
  _fifo_init_mm(struct mm_struct *mm) {     
      list_init(&pra_list_head);
      mm->sm_priv = &pra_list_head;
      return 0;
  }
  ```

- **`_fifo_map_swappable()`**

  该函数根据FIFO策略将新页面插入至 `pra_list_head` 队列的尾部，记录页面到达顺序。

  ```c
  static int
  _fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
      list_entry_t *head = (list_entry_t*) mm->sm_priv;
      list_entry_t *entry = &(page->pra_page_link);
      assert(entry != NULL && head != NULL);
      list_add(head, entry);  // 插入队列尾部
      return 0;
  }
  ```

- **`_fifo_swap_out_victim()`**

  使用FIFO策略选择换出页面，函数通过`list_prev()`选择最早进入的页面并从链表中删除。

  ```c
  static int
  _fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
      list_entry_t *head = (list_entry_t*) mm->sm_priv;
      list_entry_t *entry = list_prev(head);
      if (entry != head) {
          list_del(entry);
          *ptr_page = le2page(entry, pra_page_link);
      } else {
          *ptr_page = NULL;
      }
      return 0;
  }
  ```

- **`swapfs_write()`**

  将换出的页面内容写回硬盘，以保存页面数据，确保日后需要时可以从硬盘重新加载。

  ```c
  int swapfs_write(struct Page *page, off_t offset) {
      // 将页面数据写入硬盘
  }
  ```

- **`free_page()`**

  释放已经换出到硬盘的页面，回收内存空间。

  ```c
  void free_page(struct Page *page) {
      // 释放内存页
  }
  ```

- **`tlb_invalidate()`**

  刷新TLB，确保换出或换入的页面映射得到及时更新。

  ```c
  void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
      // 刷新TLB条目
  }
  ```

- **`list_add()`**

  用于FIFO实现中，将新页面插入FIFO队列中，记录页面顺序。

  ```c
  static inline void list_add(list_entry_t *head, list_entry_t *elm) {
      // 插入到链表中
  }
  ```

---

### 练习2：深入理解不同分页模式的工作原理（思考题）

`get_pte()`函数（位于 `kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

#### 1. get_pte() 函数中两段形式类似的代码原因分析

##### 1.1 sv32、sv39 和 sv48 页表的异同点

- **不同点：**
  - **Sv32** 使用两级页表，适合 32 位系统，结构为 10+10+12 位（VPN1 + VPN0 + 偏移量），总共可支持 4GB 的虚拟地址空间。
  - **Sv39** 和 **Sv48** 适合 64 位系统。Sv39 使用三级页表，虚拟地址结构为 9+9+9+12 位，虚拟地址空间最大 512GB；Sv48 增加一级页表，虚拟地址结构为 9+9+9+9+12 位，最大虚拟地址空间为 256TB。
  
- **相同点：**
  - 这三种页表格式都遵循逐级索引的机制，从最顶层页目录项开始逐级定位，直到最终找到目标页表项。每一层级的页表项都包含权限位等控制信息。无论是两级、三级还是四级页表，最终都会指向由操作系统分配的物理地址，实际的索引方式一致。

##### 1.2 代码相似性的原因

在 RISC-V 的多级页表设计中，地址转换过程的每一步操作相同，差异仅在于页表的层数。因此，在不同的页表机制中，每次 `get_pte()` 查询页表条目的方式相似，只是根据页表层数重复次数不同。例如：

- 在 **sv39** 中，三级结构对应三级查找，形成两段几乎相同的代码片段来处理虚拟地址的逐级转换。
- 在 **sv48** 中，四级结构则需要再多一层查找，形成三段类似的代码。

这种相似性源于 RISC-V 页表机制的层次化设计，使得代码在结构上具有一致性并易于扩展，以适应不同页表结构需求。

---

#### 2. get_pte() 中查找和分配操作合并的合理性

当前的 `get_pte()` 函数将查找和分配操作合并在一个函数中，一次调用即可完成所有页表层次的检查、创建并返回页表项的功能。这样的设计具备以下优点：

- **完整性保证**：  
  查找和分配合并确保每次查询的页表项都有效。若某一级页表条目无效，函数会立即进行分配，确保该级页表结构完整，从而避免了中间缺失页表导致的进一步错误。

- **减少冗余代码，提高维护性**：  
  这种设计使得调用者在使用时无需关心页表的层次关系，只需一次调用即可获得相应页表项，从而提高了代码的可读性和维护性。将查找和分配拆开会导致代码中多层检查逻辑的冗余，同时调用者还需手动处理每一级页表项的有效性。

- **逻辑一致性**：  
  函数封装确保了虚拟地址查询逻辑的连续性和一致性，避免了返回 `NULL` 时调用者无法确定具体缺失页表级别的问题。

**总结**：  
将查找和分配合并在一个函数中是合理且高效的设计。拆分查找和分配会增加查询的复杂性，且容易引入错误，因此没有必要将这两个功能拆开。

--- 

### 练习3：给未被映射的地址映射上物理页（需要编程）

补充完成 do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页

面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。

**实现过程**：

补充do_pgdefault函数，这个函数用于处理缺页异常：

```c
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        /*LAB3 EXERCISE 3: 2213748
        * 请你根据以下信息提示，补充函数
        * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
        * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
        *
        *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
        *  宏或函数:
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
            page_insert(mm->pgdir,page,addr,perm);
            swap_map_swappable(mm,addr,page,1);
            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
failed:
    return ret;
}
```

#### 整体代码实现过程分析

`do_pgfault` 函数是 uCore 中用于处理缺页异常的关键函数。当程序访问到一个尚未映射的虚拟地址时，将触发缺页异常，进入 `do_pgfault` 进行处理。以下是 `do_pgfault` 的代码分析：

1. **VMA 查找与地址范围检查**：
   - 函数首先通过 `find_vma` 查找包含缺页地址的 VMA（虚拟内存区域）。
   - 如果 `vma` 返回 `NULL` 或者缺页地址不在 `vma` 的起始地址范围内，说明该地址不属于进程的合法地址范围，直接返回错误。

2. **权限设置**：
   - 根据 VMA 中的标志位确定该页面的访问权限。基本权限设置为 `PTE_U`，表示用户模式可访问。
   - 如果 VMA 的 `VM_WRITE` 标志位被设置，表示该页面可写入，进一步设置 `PTE_R | PTE_W`（可读写权限）。

3. **获取页表项**：
   - 调用 `get_pte` 获取该线性地址的页表项。如果页表尚不存在，函数会自动分配新的页表。这样确保页表结构完整，为后续的映射做好准备。

4. **判断页表项内容**：
   - 如果页表项内容为 0（即页面尚未映射），调用 `pgdir_alloc_page` 分配一个新的物理页并将其映射到指定的虚拟地址。
   - 如果页表项内容非 0 且 `swap_init_ok` 标志为真，则表示该页面已被换出到磁盘，此时需要通过补充代码部分从磁盘加载页面。

---

#### 补充代码分析

在 `do_pgfault` 函数中，补充了以下三行代码，以处理已经被换出的页面，将其重新加载到内存中，并进行相关的页表设置和标记：

```c
swap_in(mm, addr, &page);
page_insert(mm->pgdir, page, addr, perm);
swap_map_swappable(mm, addr, page, 1);
```

1. **`swap_in(mm, addr, &page);`**
   - 调用 `swap_in` 函数，将地址 `addr` 对应的页面从磁盘的交换区加载到内存。
   - 通过该操作，我们将原本在磁盘中的页面内容加载到物理内存，并将页面的物理地址存储到 `page` 中。
   - 这一步骤完成后，页面内容已经恢复到内存，但尚未建立与虚拟地址的映射关系。

2. **`page_insert(mm->pgdir, page, addr, perm);`**
   - 调用 `page_insert` 函数，在页表中建立从线性地址 `addr` 到物理页 `page` 的映射关系，并设置访问权限 `perm`。
   - 这一步确保程序在访问 `addr` 时可以正确映射到 `page` 所指向的物理地址，从而解决缺页问题。

3. **`swap_map_swappable(mm, addr, page, 1);`**
   - 调用 `swap_map_swappable` 函数，将页面 `page` 标记为可交换，并将其插入页面替换算法的管理队列中。
   - 通过该函数，页面 `page` 被标记为可交换页面（`1` 表示可交换）。当内存不足时，操作系统可以选择该页面进行换出。


补充的代码在 `do_pgfault` 函数中实现了以下功能：
- 从磁盘加载被换出的页面内容；
- 建立页面与虚拟地址的映射；
- 将页面标记为可交换，便于后续管理。

这三行代码确保缺页异常处理中对换出页面的正确处理，使得系统可以在缺页时恢复页面的内存映射，同时保持页面的可交换性。


---

• **请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对 uCore 实现页替换算法的潜在用处。**

**答**：  
在 uCore 的页面替换算法中，页目录项（PDE）和页表项（PTE）包含了多个关键标志位，这些标志位可以支持实现更加高效的页面替换算法。

- **访问位（Accessed Bit，PTE_A）**：用于表示页面是否被访问过。页面替换算法可以利用这个位来追踪页面的访问频率，例如在 Clock 算法中，优先选择最近未访问的页面进行替换，从而减少活跃页面被替换的几率。

- **修改位（Dirty Bit，PTE_D）**：用于表示页面内容是否被修改过。通过该位，操作系统可以识别哪些页面已经被修改，避免对未修改页面的多余写回操作，从而减少换出过程中的磁盘写操作。

- **未使用位（P 位为 0）**：当 PTE 的有效位为 0 时，CPU 将忽略该 PTE，操作系统可利用这些空闲位记录交换分区的相关信息，从而在页替换时记录和恢复页面在交换分区中的位置。

---

• **如果 uCore 的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**

**答**：  
如果缺页服务例程在执行期间访问了无效的内存地址，会触发新的页面访问异常。此时，硬件将执行以下步骤：

1. **保存异常地址**：将引发异常的地址保存至专用寄存器（如 `cr2` 寄存器或等效寄存器），供操作系统查询。
  
2. **生成异常代码**：记录异常原因，提供访问类型、缺页原因等信息。

3. **进入异常处理程序**：触发操作系统的异常处理流程，进入 `do_pgfault` 函数，查找相应页面并更新页表映射。

---

• **数据结构 Page 的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？**

**答**：  
在 uCore 中，`Page` 结构体数组的每一项表示一个物理页帧，管理页表和物理内存的映射，`Page` 结构中的部分字段和页表相关信息的对应关系如下：

- **`visited` 字段**：用于记录页面是否被访问过，类似于 PTE 的访问位（PTE_A）。在页替换算法中，`visited` 字段可以结合 PTE_A 位一起使用来判断页面的访问频率，以便于选择合适的页面进行替换。

- **`flags` 和 `ref` 字段**：用于表示页面状态和引用次数。通过这些信息，系统可以判断页面是否处于空闲状态、是否需要保留等，从而在换入和换出操作时使用这些标志位辅助管理页面。

---
### 练习4：补充完成Clock页替换算法
通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

比较Clock页替换算法和FIFO算法的不同。

**实现过程**：

向_clock_init_mm函数中添加内容，设置页面置换算法所需的链表头 pra_list_head，并将 curr_ptr 指针指向链表头，用于后续的页面替换操作。
```c
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: 2213107*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     curr_ptr=&pra_list_head;
     return 0;
}
```

修改_clock_map_swappable函数，将新页面插入到链表的末尾，并将页面的 visited 标志设置为 1，表示页面已经被访问。
```c
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2213107*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_add(head, entry);
    page->visited=1;
    cprintf("curr_ptr %p\n", curr_ptr);
    return 0;
}
```

修改_clock_swap_out_victim函数，它会从链表的头部开始查找，找到第一个 visited 标志为 0 的页面，将其从链表中删除，并返回这个页面作为被置换的页面。如果页面的 visited 标志为 1，则将其重置为 0，并继续查找。
```c
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
     assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     curr_ptr = head;
    while ((curr_ptr = list_prev(curr_ptr))) {
        /*LAB3 EXERCISE 4: 2213107*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        struct Page *p = le2page(curr_ptr, pra_page_link);
        if (p->visited==0) {
        list_del(curr_ptr);
        *ptr_page = le2page(curr_ptr, pra_page_link);
        break;
        }
        else {
            p->visited=0;
        }
    }
    return 0;
}
```

• **比较Clock页替换算法和FIFO算法的不同。**

**答**：  
Clock页替换算法和FIFO（First-In, First-Out）页替换算法都是用于操作系统中管理内存页面的算法，但它们在选择被替换页面的策略上有所不同：

1. **FIFO算法**：
   - FIFO算法是最简单的页面替换算法之一。
   - 它按照页面进入内存的顺序进行替换，即最早进入内存的页面将最先被替换出去。
   - FIFO算法使用一个队列来跟踪所有可替换的页面，新页面被添加到队列的末尾，而页面替换时总是从队列的头部移除页面。
   - FIFO算法容易实现，但可能不是最优的，因为它不考虑页面的使用频率或最近是否被访问过。

2. **Clock算法**：
   - Clock算法是一种近似LRU（Least Recently Used）算法，它试图通过跟踪页面的使用情况来模拟LRU算法的行为。
   - 在Clock算法中，每个页面都有一个“使用”标志（通常是一个位），操作系统维护一个循环链表，链表中的每个节点代表一个页面。
   - 当需要替换页面时，操作系统从链表的当前位置开始，检查每个页面的使用标志。如果标志为0，该页面将被替换；如果标志为1，则将标志重置为0，并移动到下一个页面继续检查。
   - 这个过程类似于时钟的指针在页面链表上移动，因此得名“Clock”算法。
   - Clock算法比FIFO算法更灵活，因为它考虑了页面的使用情况，但实现起来比FIFO算法复杂。

总的来说，Clock算法通过使用标志和循环检查来提供一种更接近LRU的页面替换策略，而FIFO算法则简单地根据页面进入内存的顺序进行替换。Clock算法通常比FIFO算法有更好的性能，因为它试图保留最近被访问过的页面，这些页面更有可能在未来被再次访问。

---

### 练习5：阅读代码和实现手册，理解页表映射方式相关知识

• **如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？**

**答**：

**好处和优势**：

1. **减少页表项**：大页可以减少所需的页表项数量，因为一个大页可以映射更多的内存空间。这减少了页表的大小，从而减少了页表本身的内存占用。

2. **减少TLB压力**：由于页表项减少，CPU的TLB缓存可以更有效地工作，因为更少的页表项意味着更高的TLB命中率，减少了页表查找的延迟。

3. **提高性能**：对于访问大量连续内存的应用程序（如数据库、大型数据处理等），使用大页可以减少页表查找次数，从而提高性能。

5. **简化内存管理**：对于操作系统来说，管理大页比管理大量小页更简单，因为需要跟踪的页数减少了。

**坏处和风险**：

1. **内存浪费**：如果应用程序不需要那么大的内存块，使用大页可能导致内存空间的浪费，因为未使用的内存空间不能被其他应用程序利用。

2. **灵活性降低**：大页不适合所有类型的应用程序，特别是那些需要频繁分配和释放小块内存的应用程序。大页可能导致内存分配不够灵活。

3. **增加页错误处理成本**：当发生页错误时，操作系统需要处理更大的内存块，这可能增加页错误处理的复杂性和成本。

总的来说，使用大页的页表映射方式在某些场景下可以提供性能优势，尤其是在处理大量连续内存访问时。然而，它也可能导致内存浪费和灵活性降低，因此在选择使用大页时需要根据具体的应用程序和工作负载特性来决定。

---

### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法

#### LRU页面置换算法介绍

LRU(Least Recently Used)算法，即最久未使用算法。基于局部性原理，当发生缺页异常时，系统会选择最近最远未访问过的进行替换。

#### LRU页面置换算法设计与实现

LRU一般的做法是，记录每个页面最后访问的时间，每次发生缺页异常时，需要找到所有页面中时间最早的页面进行替换。

可是基于给定的FIFO算法实例（用一个双向链表实现的队列），我们可以很自然地想到一个更简单的实现方式（不要求时间复杂度）：每当页面被访问时，我们都去遍历一遍这个链表，如果这个页面在链表中，那么就把它重新排到队尾，这样每次发生缺页异常时，从队首取出的自然就是最久未访问过的页面。

由于不考虑时间复杂度，为了方便考虑，在将链表内元素从队中移动到队尾时，直接调用了list_del和list_add函数，采用先删除后添加的方式替代了移动的过程。我把LRU算法操作的过程实现为了_lru_operate函数：

```c
static int 
_lru_operate(struct mm_struct *mm, uintptr_t addr){
    // 该函数的作用是，如果访问的页在链表中，那么就将其挪到队尾
    bool judge = false; //判断页是否在链表中
    list_entry_t *head=(list_entry_t*) mm->sm_priv;

    // 寻找物理地址对应的页
    addr = ROUNDDOWN(addr, PGSIZE);
    pte_t *ptep = get_pte(mm->pgdir, addr, 1);
    struct Page *page = pte2page(*ptep);

    list_entry_t *entry=&(page->pra_page_link);

    //遍历链表，如果entry在链表中，那么就将其挪到队尾
    curr_ptr = list_next(head);
    while(curr_ptr != head){// 遍历链表
        if(le2page(curr_ptr, pra_page_link) == page){//如果这个page在链表中，采用先删除后添加的方式
            judge = true;
            list_del(curr_ptr);
            break;
        }
        curr_ptr = list_next(curr_ptr);
    }
    if(judge){
        list_add(head, entry);
    }
    return 0;
}
```

函数的输入是相应的mm_struct指针和访问的物理地址，函数做了两件事：找到物理地址对应的页，检查页是否在链表中。其中需要注意的是，在寻找物理地址对应的页的过程中，首先要将物理地址按照PGSIZE向下取整对齐，然后利用get_pte函数拿到该物理地址对应的页表项的地址，最后再利用pte2page函数找到其对应的页。

可是又出现了一个大问题：我们无法找到页是何时何地在内核中被访问的。如果把这段函数放入_lru_map_swappable函数中，会出现问题：该函数只有当发生缺页异常时才会被调用，页命中时不会进入该函数。所以我们无奈地手动修改check函数（只修改了LRU算法的check函数，fifo和clock算法的check函数没有进行任何修改），在每次访问页后手动调用_lru_operate函数，模拟LRU算法的过程。修改后的check函数和测试样例如下一节所示。


#### 测试样例与测试结果

我编写的LRU算法的测试样例沿用了fifo算法的测试样例：

__初始化：abcd (调用顺序从左到右，下同)__

__check函数：cadbebabcdea__

__队列长度：4，总页面个数：5 (a、b、c、d、e)__

与fifo算法不同的是，为在每个页面访问后调用了_lru_operate函数模拟LRU算法过程，因此缺页情况与fifo算法有所不同，缺页数量也比fifo算法少很多。我将LRU算法的理论结果以注释形式标注在了函数中，注释的内容为进行完成当次页操作后，队列中的情况和是否引发缺页异常，函数如下所示：（初始化函数没有发生任何改变，不进行展示）

```c
static int
_lru_check_swap(struct mm_struct *mm) {
    // 队列中已经存在的元素：abcd（队首->队尾）
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    _lru_operate(mm, 0x3000); // Queue:abdc, hit
    assert(pgfault_num==4);
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    _lru_operate(mm, 0x1000); // Queue:bdca, hit
    assert(pgfault_num==4);
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    _lru_operate(mm, 0x4000); // Queue:bcad, hit
    assert(pgfault_num==4);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    _lru_operate(mm, 0x2000); // Queue:cadb, hit
    assert(pgfault_num==4);
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    _lru_operate(mm, 0x5000); // Queue:adbe, miss
    assert(pgfault_num==5);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    _lru_operate(mm, 0x2000); // Queue:adeb, hit
    assert(pgfault_num==5);
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    _lru_operate(mm, 0x1000); // Queue:deba, hit
    assert(pgfault_num==5);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    _lru_operate(mm, 0x2000); // Queue:deab, hit
    assert(pgfault_num==5);
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    _lru_operate(mm, 0x3000); // Queue:eabc, miss
    assert(pgfault_num==6);
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    _lru_operate(mm, 0x4000); // Queue:abcd, miss
    assert(pgfault_num==7);
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    _lru_operate(mm, 0x5000); // Queue:bcde, miss
    assert(pgfault_num==8);
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    _lru_operate(mm, 0x5000); // Queue:cdea, miss
    assert(pgfault_num==9);
    return 0;
}
```

函数中的assert断言判读缺页数量是否正确，每一次miss后pgfault_num加一。

对上述LRU算法进行测试，得到的结果如下图所示：

![alt text](./image/lru_result.png)

check_swap阶段的日志(位于.qemu.out)如下所示：(//后为后加的注释，原始文件中没有)
```
BEGIN check_swap: count 2, total 31661
setup Page Table for vaddr 0X1000, so alloc a page
setup Page Table vaddr 0~4MB OVER!
set up init env for check_swap begin! // 初始化阶段，顺序访问页abcd
Store/AMO page fault                  // 初始化访问a,miss,队列：a（队首->队尾）
page fault at 0x00001000: K/W
curr_ptr 0xffffffffc02258a8
Store/AMO page fault                  // 初始化访问b,miss,队列：ab
page fault at 0x00002000: K/W
curr_ptr 0xffffffffc02258f0
Store/AMO page fault                  // 初始化访问c,miss,队列：abc
page fault at 0x00003000: K/W
curr_ptr 0xffffffffc0225938
Store/AMO page fault                  // 初始化访问d,miss,队列：abcd
page fault at 0x00004000: K/W
curr_ptr 0xffffffffc0225980
set up init env for check_swap over!  // 初始化完毕，下面开始测试
write Virt Page c in lru_check_swap   // 访问c,hit ,队列：abdc
write Virt Page a in lru_check_swap   // 访问a,hit ,队列：bdca
write Virt Page d in lru_check_swap   // 访问d,hit ,队列：bcad
write Virt Page b in lru_check_swap   // 访问b,hit ,队列：cadb
write Virt Page e in lru_check_swap   // 访问e,miss,队列：adbe
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x3000 to disk swap entry 4
curr_ptr 0xffffffffc0225938
write Virt Page b in lru_check_swap   // 访问b,hit ,队列：adeb
write Virt Page a in lru_check_swap   // 访问a,hit ,队列：deba
write Virt Page b in lru_check_swap   // 访问b,hit ,队列：deab
write Virt Page c in lru_check_swap   // 访问c,miss,队列：eabc
Store/AMO page fault
page fault at 0x00003000: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
swap_in: load disk swap entry 4 with swap_page in vadr 0x3000
curr_ptr 0xffffffffc0225980
write Virt Page d in lru_check_swap   // 访问d,miss,队列：abcd
Store/AMO page fault
page fault at 0x00004000: K/W
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
curr_ptr 0xffffffffc0225938
write Virt Page e in lru_check_swap   // 访问e,miss,队列：bcde
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
curr_ptr 0xffffffffc02258a8
write Virt Page a in lru_check_swap   // 访问a,miss,队列：cdea
Load page fault
page fault at 0x00001000: K/R
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
curr_ptr 0xffffffffc02258f0
count is 1, total is 8
check_swap() succeeded!
```

