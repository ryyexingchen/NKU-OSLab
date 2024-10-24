#ifndef __KERN_MM_SLUB_H__ 
#define __KERN_MM_SLUB_H__  

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>


struct kmem_cache_node
{
    list_entry_t full_area;
    list_entry_t partial_area;
};

typedef struct{
    size_t object_size;
    size_t block_num;

    struct Page *page;
    struct kmem_cache_node *node;
}kmem_cache;

extern const struct slub_manager slub;



#endif /* __KERN_MM_SLUB_H__ */