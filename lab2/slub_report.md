# slub算法

## 前言(小吐槽)

实验指导手册里面直接给出了一个去往代码仓库的链接，代码足足有7446行，根本看不完也看不明白！
为此，我去网上找了一些博客资料（类似于伙伴系统里面的那种），我认为讲的比较清楚，展示在下面:

### 究极详细的博客: `https://segmentfault.com/a/1190000043626203#item-9 `（这篇博客的上一篇就是将伙伴系统的，讲的也很详细，强力推荐给学弟学妹们这篇文章作参考）

### 这篇博客里面也有详细图解: `https://www.cnblogs.com/LoyenWang/p/11922887.html`

### 这篇B站图文讲解也可以，但是不如其他详细: `https://www.bilibili.com/read/cv35002973/`

由于本算法的简化版依然比较复杂，因此我并没有给出完整的代码，而是把已经完成的片段代码方在了下面的实验报告中。由于slub算法本身就很复杂，简化的方式也比较复杂，因此本篇的篇幅会比较长，敬请谅解。

## 整体设计思想

由于利用伙伴系统分配内存空间时，不满一页均按照一页的大小分配，因此在分配不足4K的内存时会出现大量浪费。而slub算法就是为了解决这种情况而被设计出来的。其将内存划分成更小的单位object，当分配的内存不足一页时，就会调用slub系统，对其分配object对象。

在完整学过slub算法的原理之后，我发觉就这个小小的ucore内核实现slub算法是不现实的，因此需要提取思想将其简化。先附上一张slub总体结构图:（图中的slab看成slub就行）

![slub总体结构图](./image/slub.webp)

可以看到图中重要的数据结构有kmem_cache(链表)、percpu、slub_page和NUMA_node。这些实现太复杂了，肯定不可能都实现，因此需要简化。

在实验指导书中将slub算法的原理概括成了两层:

 `第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。` 
 
 毕竟是实验指导书，不可能花费大量的篇幅去描述slub算法的思想。因此我参照“究极详细的博客”中对slub原理的概括: 

`slab 首先会向伙伴系统一次性申请一个或者多个物理内存页面，正是这些物理内存页组成了 slab 内存池。`

`随后 slab 内存池会将这些连续的物理内存页面划分成多个大小相同的小内存块出来，同一种 slab 内存池下，划分出来的小内存块尺寸是一样的。内核会针对不同尺寸的小内存分配需求，预先创建出多个 slab 内存池出来。`


`既然 slab 专门是用于小内存块分配与回收的，那么内核很自然的就会想到，分别为每一个需要被内核频繁创建和释放的核心对象创建一个专属的 slab 对象池，这些内核对象专属的 slab 对象池会根据其所管理的具体内核对象所占用内存的大小 size，将一个或者多个完整的物理内存页按照这个 size 划分出多个大小相同的小内存块出来，每个小内存块用于存储预先创建好的内核对象。`

把任务目标简化如下：

### (1)设计object和slub页的结构，并设计接口从伙伴系统中存取Page。当slub池中empty的页面过多时，就把slub页（转换成正常页）放回伙伴系统；如果slub池中页面不够，则利用伙伴系统取出几个空闲页作为slub页。

### (2)将slub页切实划分成多个object。（注意同一个slub页中的object大小是固定的）

### (3)管理slub页的状态（分为三种，empty、full和partial，表示空闲、满和部分占用三种状态）

### (4)实现分配和实现(快慢路径)

但是就算把目标简化成上述四条，对于这个小小的ucore还是过于复杂了，因此我在数据结构上也进行了简化:将与cpu相关的部分删去，只保留free_list、partial_list等必要的数据结构。详细设计将在下文中说明。

## object设计

在传统slub算法中，object有两种形式:普通object和POISON object（毒化）。如下图所示:

![object结构](./image/object.webp)

可以看到里面有不同的部分。最重要的部分是object_size、freepointer和redzone(起padding作用，实际上还有防止溢出的作用)。

要简化object结构，可以保留object_size和freepointer即可，必要时可以增加padding填充。object对象的大小最小为8 Bytes，最大不超过一个page的大小（4KB）。

## slub页设计

slub页需要实现几个功能:保存页状态（empty、full或者是partial）、页大小（定值，可以不用写进结构体中）、object大小或者是object个数（object_size * object_num = page_size = 4K）

```c
struct SlubPage {
    struct slub_cache *p_slub_cache;// 指向对应的slub_cache
    size_t free_object_num;         // 保存剩余objects的数量
    uintptr_t freelist;             // 指向第一个空闲object

    // 下面的是原先的页实现的部分
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // 可以利用原先的free_list指针指向free、full和partial链表
};
```

这里注意没有把object_size加进去是由于简化考虑，将其定义放在了slub_cache中，下文会提及。于是我们拿到伙伴系统分配的一个页后需要将Page类型转化为SlubPage类型，转化函数如下:

```c
static struct SlubPage *
PagetoSlub(struct Page* page, struct slub_cache *cache){
    struct SlubPage *slub = malloc(sizeof(struct SlubPage));
    slub->p_slub_cache = cache;
    slub->free_object_num = 4096 / cache->object_size;
    slub->freelist = page2pa(struct Page *page);    // 空表的第一个object即为空的
    // 剩下的将page的成员copy过来
    slub->ref = page->ref;
    slub->flags = page->flags;
    slub->property = page->property;
    slub->page_link = page->page_link;
    return slub;
}
```

相应的，将slub页释放回伙伴系统时，需要将SlabPage类型转化为Page类型，转化函数如下:

```c
static struct Page *
SlubtoPage(struct SlubPage* slub){
    struct Page *page = malloc(sizeof(struct Page));
    page->ref = slub->ref;
    page->flags = slub->flags;
    page->property = slub->property;
    page->page_link = slub->page_link;
    return page;
}
```

## slub_cache设计
在原先的设计中，slub_cache中有一个指向kmem_cache_cpu的指针，而kmem_cache_cpu结构大致如下图所示:

![kmem_cache_cpu结构](./image/kmem_cache_cpu.webp)

从上图中可以看到，kmem_cache_cpu中最重要的部分就是freelist指针、page指针和partial指针。其中freelist指针和page指针相当与一个一级cache，是用于快速路径的，partial指针相当于后面的二级三级cache（NUMA NODE的那套机制相当于是内存，由于太复杂了不考虑实现）

实际上kmem_cache_cpu是为了不同的cpu而设计的，slub_cache的设想也是凌驾于所有cpu之上，通过NUMA机制在不同cpu之间调节slub内存。但是为了简化，我们不涉及NUMA机制，也就不需要这么复杂的数据结构，因此为将kmem_cache_cpu与slub_cache合并，并去除了不必要的成员（如cpu的id等），只保留kmem_cache的核心功能，设计的数据结构如下:

```c
struct kmem_cache{
    uint64_t freelist;          // 与SlubPage中的freelist用处一致
    uint64_t object_size;       // 用于保存该cache下的object大小
    struct SlubPage *page;      // 指向快速路径的slub_page
    list_entry_t full;          // 指向full区域的第一个成员
    list_entry_t partial;       // 指向慢速缓存的slub_page中的第一个成员（后面的成员用链表连接）
};
```

下图是简化前的kmem_cache结构，我将kmem_cache_cpu的部分删去并将其成员freelist、page和partial放入cache中并替代先前指向kmem_cache_cpu的指针。

![kmem_cache结构](./image/kmem_cache.webp)

由于我们打算使用数组方式进行管理（而不是双向链表），因此没有next和prev成员。而且为了简化实现，我们打算利用类似于伙伴系统的机制: 

##### (1) 由于page单位为 4KB = 4096 Bytes，所以我打算新建一个kmem_cache类型的数组，每一个kmem_cache元素对应固定大小object的slub页缓存池。我们规定object对象的大小为 [8 Bytes, 4096 Bytes），因此数组个数有9个，分别对应 8 Bytes、16 Bytes、32 Bytes、64 Bytes、128 Bytes、256 Bytes、512 Bytes、1024 Bytes、2048 Bytes的对象池。这样固定object的大小是为了考虑slub页内的内存对齐。

##### (2) 与伙伴系统不同的是，object对象不存在合并和分裂的情况，所以我们认为任意内存对2取对数、向上取整再减去3即为其对应的cache编号（小于8 Bytes认为编号为0）。利用公式可以表示成: `cache_no =  [log2(n)] - 3`。例如，如果要分配 1000 Bytes内存，所以其对应的cache编号为7。当需要分配的内存大于4096 Bytes时，理论上来说应该先利用伙伴系统分配page，剩下的内存根据大小进行判断，如果剩下的内存不超过半页（2048 Bytes），我们就利用slub算法分配object，如果大于半页，那么我们还是利用伙伴系统分配一个整页给他。

计算cache_no的函数如下:
```c
unsigned int getCacheNo(size_t n){
    if(n < 16){
        return 0;
    }
    else{
        unsigned int cache_no = 0;
        unsigned int i = 1;
        while (i < n) {
            i <<= 1;
            cache_no++;
        }
        return cache_no - 3;
    }   
}

```

## 内存分配
在分配object时，需要考虑两种情况: 如果当前cache中没有合适的object分配，需要从伙伴系统重新分配一个页，并将其划为object（实际的slub算法中支持多个页，出于简化考虑每次只分配一个页）；如果cache中有空闲的object可以分配，那么就直接将其分配给内存即可。

```c
static uintptr_t kmem_alloc(size_t n){
    unsigned int cache_no = getCacheNo(n);
    assert(cache_no > 8);// 只接受小于一页的内存分配
    kmem_cache* p_cache = &kmem_slub_cache[cache_no];

    // 情况1:如果当前slub_cache为空或者没有空闲的object
    size_t offset = p_cache->object_size / 8;
    if(p_cache->page === NULL || p_cache->page->free_object_num == 0){
        while(!list_empty(&p_cache->partial)){
            list_entry_t* le = &p_cache->partial;
            if((le = list_next(le)) != &p_cache->partial){
                p_cache->page = le2page(le,page_link);
                p_cache->page->freelist = (uintptr_t)KADDR(page2pa((p_cache->page)));
                if(p_cache->free_object_num == p_cache->page->free_object_num + 1){
                    pmm_manager->free_pages(p_cache->page,1);
                }
            }
        }
        //如果没有空闲的slubpage了，那么请pmm_manager分配一个新页
        p_cache->page = PagetoSlub(pmm_manager->alloc_pages(1),p_cache);
        
        //将新分配好的放入freelist中
        p_cache->page->freelist = (uintptr_t)KADDR(page2pa((p_cache->page)));
        uint64_t* p = (uint64_t*)p_cache->page->freelist;
        for(size_t i = 0;i < p_cache->free_object_num; i++){
            if(i != p_cache->free_object_num - 1){
                *(p + i * offset) = (uintptr_t)(p + (i + 1) * offset);
            }else *(p + i * offset) = 0;
        }
        p_cache->page->free_object_num = p_cache->free_object_num;
    }

    // 情况2：直接从freelist中找到合适的object
    uint64_t* result = (uint64_t*)p_cache->page->freelist;
    if(*(result) == 0){
        p_cache->page->freelist = 0;
        list_add(&p_cache->full,&(p_cache->page->page_link));
    }else{
        p_cache->page->freelist = *(uint64_t* )(p_cache->page->freelist);
    }
    p_cache->page->free_object_num--;
    return (uintptr_t)result;
}
```
## 内存释放

在内存释放时，需要考虑页面的状态，如从full变成partial或者从partial变成empty。如果变成了空页面，我们就将其释放到伙伴系统中。

```c
static void kmem_free(uintptr_t base,size_t n){
     unsigned int cache_no = getCacheNo(n);
    assert(cache_no > 8);
    kmem_cache* p_cache = &kmem_slub_cache[cache_no];

    uintptr_t pa = PADDR(base);
    struct SlubPage* page = PagetoSlub(pa2page(pa),p_cache);

    if(page == p_cache->page){// 如果从快速路径释放缓存
        p_cache->page->free_object_num++;
        if(p_cache->free_object_num == p_cache->page->free_object_num){// 如果释放后的page为空页面
            p_cache->page = NULL;
            pmm_manager->free_pages(SlubtoPage(page),1);// 利用伙伴系统将空页释放回去
        }
        *(uint64_t*)base = p_cache->page->freelist;
        p_cache->page->freelist = base;
    }else{// 如果从慢速路径释放缓存
        list_entry_t* le = &page->page_link;
        while (le != &p_cache->full && le != &p_cache->partial) {
             le = list_next(le);
        }
        if(le == &p_cache->full){// 被释放的object来自full状态的slub_page
            // 把
            list_del(&(page->page_link));
            list_add(&(p_cache->partial),&(page->page_link));
            page->free_object_num++;

            if(p_cache->free_object_num == page->free_object_num){// 如果释放后的page为空页面
                list_del(&page->page_link);
                pmm_manager->free_pages(SlubtoPage(page),1);// 利用伙伴系统将空页释放回去
            }
        }
        else{ // 被释放的object来自partial状态的slub_page
            page->free_object_num++;
            if(p_cache->free_object_num == page->free_object_num){
                list_del(&page->page_link);
                pmm_manager->free_pages(SlubtoPage(page),1);// 利用伙伴系统将空页释放回去
            }
        }
    }
}
```

## 实现时遇到的困难
但即使把实现方式简化到上述的程度，实现还是非常困难。主要的困难来源有以下几点:

### (1) object在内存中的实际分配。我们注意到每个object里面都有一个指针，指向下一个空闲的object。但实际上，在这个ucore的框架下，我们很难去直接修改其内存，控制我们规定的空闲的object中的free_list指针的指向（换句话来说，该内核框架只支持以页为单位的调度，很难实现以object为单位的调度）。

### (2) 由于我们很难为每一个object分配freelist指针，因此寻找下一个空闲的object就会变得比较困难。（因为没有办法通过指针直接寻找下一个空闲object的位置，因此需要逐个遍历，这会使时间复杂度从o(1)增加到o(n)。）

### (3) slub算法要求，在空slub页（状态为empty的slub页）超过一个阈值时，需要将多余的slub页还给操作系统；在slub页不足时向伙伴系统申请一个新页。但是由于实验框架所限，很难实现slub算法与伙伴系统之间的沟通，因此在此框架下实际实现比较困难。

只要把这些问题解决了，那么实现一个简化版的slub算法相对来说就会容易很多。


