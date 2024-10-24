#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static size_t fixsize(size_t size) {
    unsigned i = 0;
    size--;
    while (size >= 1) {
        size >>= 1; 
        i++;
    }
    return 1 << i; 
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    n=fixsize(n)/2;
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}

void print_list()
{
    list_entry_t* p=list_next(&free_list);
    while(list_next(p)!=&free_list)
    {
        struct Page *q=le2page(p,page_link);
        cprintf("%d->",q->property);
        p=list_next(p);
    }
    cprintf("\n");
    return;
}

static struct Page *
buddy_alloc_pages(size_t n)
{
    assert(n > 0);
    size_t u=fixsize(n);
    if (u > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = list_next(&free_list);
    size_t min_size=1e9;
    while (le != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= u&&min_size>p->property) {
            page = p;
            min_size=page->property;
        }
        le = list_next(le);
    }
    if (page != NULL) 
    {
        while(page->property>=2*u)
        {
            list_entry_t* prev = list_prev(&(page->page_link));
            list_entry_t* next = list_next(&(page->page_link));
            list_del(&(page->page_link));
            struct Page *p = page + page->property/2;
            struct Page *q = page;
            p->property=page->property/2;
            q->property=page->property/2;
            SetPageProperty(p);
            SetPageProperty(q);
            list_add(prev, &(q->page_link));
            list_add_before(next, &(p->page_link));
            page=q;
        }
        list_del(&(page->page_link));
        nr_free -= page->property;
        ClearPageProperty(page);
    }
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) 
{
    assert(n > 0);
    n=fixsize(n);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
    size_t flag=1;
    struct Page *q=le2page(list_next(&free_list),page_link);
    while(flag==1)
    {
        if(((base-q)/base->property)%2==1)
        {
            list_entry_t* le = list_prev(&(base->page_link));
            if (le != &free_list) {
                p = le2page(le, page_link);
                if (p + p->property == base && p->property==base->property) {
                    p->property += base->property;
                    SetPageProperty(p);
                    ClearPageProperty(base);
                    list_del(&(base->page_link));
                    base = p;
                }
                else flag=0;
            }
            else flag=0;
        }
        else if(((base-q)/base->property)%2==0)
        {
            list_entry_t* le = list_next(&(base->page_link));
            if (le != &free_list) {
                p = le2page(le, page_link);
                if (base + base->property == p && p->property==base->property) {
                    base->property += p->property;
                    SetPageProperty(base);
                    ClearPageProperty(p);
                    list_del(&(p->page_link));
                }
                else flag=0;
            }
            else flag=0;
        }
    }
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void)
{
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;
    A = alloc_pages(70);
    B = alloc_pages(35);
    C = alloc_pages(257);
    D = alloc_pages(63);
    cprintf("A分配70，B分配35，C分配257，D分配63\n");
    cprintf("此时A %p\n",A);
    cprintf("此时B %p\n",B);
    cprintf("此时C %p\n",C);
    cprintf("此时D %p\n",D);
    free_pages(B, 35);
    cprintf("B释放35\n");
    free_pages(D, 63);
    cprintf("D释放63\n");
    cprintf("此时BD应该合并\n");
    free_pages(A, 70);
    cprintf("A释放70\n");
    cprintf("此时前512个已空，我们再分配511个的A来测试\n");
    A = alloc_pages(511);
    cprintf("A分配511\n");
    cprintf("此时A %p\n",A);
    free_pages(A, 511);
    cprintf("A释放511\n");

    A = alloc_pages(255);
    B = alloc_pages(255);
    cprintf("A分配255，B分配255\n");
    cprintf("此时A %p\n",A);
    cprintf("此时B %p\n",B);
    free_pages(C, 257);
    free_pages(A, 255);
    free_pages(B, 255);  
    cprintf("全部释放\n");
    cprintf("检查完成，没有错误\n");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

