#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static size_t fixsize(size_t size) {
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  return size+1;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    assert(IS_POWER_OF_2(n));
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

static struct Page *
buddy_alloc_pages(size_t n)
{
    assert(n > 0);
    size_t u=fixsize(n);
    if (u > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size=0xffff;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= u&&min_size>page->property) {
            page = p;
            min_size=page->property;
        }
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
            list_add(prev, &(p->page_link));
            list_add_before(next, &(q->page_link));
            page=p;
        }
        nr_free -= page->property;
        ClearPageProperty(page);
    }
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) 
{
    assert(n > 0&&IS_POWER_OF_2(n));
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
    struct Page *q=le2page(&free_list,page_link);
    while(flag==1)
    {
        if(((base-q)/base->property)&1==1)
        {
            list_entry_t* le = list_prev(&(base->page_link));
            if (le != &free_list) {
                p = le2page(le, page_link);
                if (p + p->property == base && p->property==base->property) {
                    p->property += base->property;
                    ClearPageProperty(base);
                    list_del(&(base->page_link));
                    base = p;
                }
                else flag=0;
            }
        }
        else if(((base-q)/base->property)&1==0)
        {
            list_entry_t* le = list_next(&(base->page_link));
            if (le != NULL) {
                p = le2page(le, page_link);
                if (base + base->property == p && p->property==base->property) {
                    base->property += p->property;
                    ClearPageProperty(p);
                    list_del(&(p->page_link));
                }
                else flag=0;
            }
        }
    }
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

