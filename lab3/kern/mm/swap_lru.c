#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

extern list_entry_t pra_list_head;
list_entry_t *curr_ptr;
/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_lru_init_mm(struct mm_struct *mm)
{     
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
    curr_ptr=&pra_list_head;
    return 0;
}

static int 
_lru_operate(struct mm_struct *mm, uintptr_t addr){
    // 该函数的作用是，如果访问的页在链表中，那么就将其挪到队尾
    list_entry_t *head=(list_entry_t*) mm->sm_priv;

    // 通过输入的地址获取Page结构体的地址
    addr = ROUNDDOWN(addr, PGSIZE);
    //cprintf("LRU operation: addr=%x\n",addr);
    pte_t *ptep = get_pte(mm->pgdir, addr, 1);
    //cprintf("LRU operation: pte=%x ,*pte=%x\n", ptep, *ptep);
    struct Page *page = pte2page(*ptep);

    list_entry_t *entry=&(page->pra_page_link);

    //遍历链表，如果entry在链表中，那么就将其挪到队尾
    curr_ptr = list_next(head);
    while(curr_ptr != head){// 遍历链表
        if(le2page(curr_ptr, pra_page_link) == page){//如果这个page在链表中，采用先删除后添加的方式
            list_del(curr_ptr);
            break;
        }
        curr_ptr = list_next(curr_ptr);
    }
    list_add(head, entry);
    return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation

    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    cprintf("curr_ptr %p\n", entry);
    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

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


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
