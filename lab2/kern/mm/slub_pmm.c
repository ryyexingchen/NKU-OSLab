#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>
#include <stdio.h>

/*96,192,2^3~2^11*/
#define MAX_ORDER_OF_AN_OBJECT 11

/*
some globel value
*/
kmem_cache kmem_slub_cache[MAX_ORDER_OF_AN_OBJECT];
//struct Page cpu[MAX_ORDER_OF_AN_OBJECT];
struct kmem_cache_node kmem_cache_node[MAX_ORDER_OF_AN_OBJECT];

/*this is just a simple slub, if we need a more effient slub,we should allow to create new cache
kmem_cache kmem_create_cache(char* name,size_t object_size)
*/

unsigned int CalculateOrder(size_t n){ // order = log2(n)向上取整 且 order >= 3
    unsigned int order = 0;
    unsigned int i = 1;
    while (i < n) {
        i <<= 1;
        order++;
    }
    return (order < 3) ? 3 : order; // 规定最小为8字节，因此order不能小于3，小于3时当作3处理
}

kmem_cache* get_suit_cache(size_t n){// 找到一个合适的cache分组
    kmem_cache* p_cache;
    if(n > 64 && n < 96){   
        p_cache = &kmem_slub_cache[0];
    }else if (n > 128 && n < 192){
        p_cache = &kmem_slub_cache[1];
    }else{
        unsigned int order = CalculateOrder(n); 
        p_cache = &kmem_slub_cache[order - 1];
    }
    return p_cache;
}

/*init all of lists and the size of objects*/
static void slub_init(){
    for (size_t i = 0; i < MAX_ORDER_OF_AN_OBJECT; i++){
        //init the object size
        if (i==0){
            kmem_slub_cache[i].object_size = 96;
        }
        else if(i==1){
            kmem_slub_cache[i].object_size = 192;
        }
        else{
            kmem_slub_cache[i].object_size = 2<<i;
        }
        //init lists
        kmem_slub_cache[i].node = &kmem_cache_node[i];
        //list_init(&kmem_slub_cache[i].cpu->cpu_free_blocks);

        //kmem_slub_cache[i].cpu->free_blocks = 0;
        //cprintf("%d\n",kmem_slub_cache[i].cpu);
        kmem_slub_cache[i].block_num = PGSIZE/kmem_slub_cache[i].object_size;
        //kmem_slub_cache[i].cpu->free_blocks_num = 0;
        list_init(&kmem_slub_cache[i].node->full_area);
        list_init(&kmem_slub_cache[i].node->partial_area);
    }
}

/*should I define another type*/
static uintptr_t kmem_alloc(size_t n){
    unsigned int order = CalculateOrder(n);
    assert(order < 12);//it'a simple slub, we don't treat the applyments which larger than 1 page
    /*find a suitable cache in needed*/
    kmem_cache* p_cache = get_suit_cache(n);


    size_t offset = p_cache->object_size / 8;//move through the object and find the next object

    if(p_cache->page == 0||p_cache->page->free_blocks_num == 0){
        while(!list_empty(&p_cache->page->partial_area)){
            list_entry_t* le = &p_cache->page->partial_area;
            if((le = list_next(le)) != &p_cache->page->partial_area){
                p_cache->page = le2page(le,page_link);
                p_cache->page->free_blocks = (uintptr_t)KADDR(page2pa((p_cache->page)));
                if(p_cache->block_num==p_cache->cpu->free_blocks_num + 1){
                    pmm_manager->free_pages(p_cache->page,1);//reback the page to pmm
                }
            }
        }

        /*if we have no page,apply for pmm*/
        p_cache->page = pmm_manager->alloc_pages(1);
        //we should set the blocks into free_list
        p_cache->page->free_blocks = (uintptr_t)KADDR(page2pa((p_cache->page)));
        uint64_t* my_pointer = (uint64_t*)p_cache->page->free_blocks;
        //we also need to set posion data, but we don't finish it now, since we just need a simple slub
        //so we just link those blocks
        for(size_t i = 0;i < p_cache->block_num; i++){
            if(i != p_cache->block_num - 1){
                *(my_pointer+i*offset) = (uintptr_t)(my_pointer + (i+1)*offset);
            }else *(my_pointer+i*offset) = 0;
        }
        p_cache->cpu->free_blocks_num = p_cache->block_num;//all of the blocks are free
    }
    //go to free_list to find a needed free block
    uint64_t* result = (uint64_t*)p_cache->page->free_blocks;
    if(*(result) == 0){
        p_cache->page->free_blocks = 0;
        list_add(&p_cache->page->full_area,&(p_cache->page->page_link));//when the free list is empty, means slub is full
    }else{
        p_cache->page->free_blocks = *(uint64_t* )(p_cache->page->free_blocks);
    }
    p_cache->cpu->free_blocks_num--;

    //we should set the red-zone, but again, this just a simple slub
    //it should be a va, right?
    return (uintptr_t)result;
}

static int where_is_the_block(struct Page* page,kmem_cache* p_cache){
    int flag;
    if(page == p_cache->page){
        flag = 2;
    }else{
        list_entry_t* le = &page->page_link;
        while (le != &p_cache->page->full_area && le != &p_cache->page->partial_area) {
             le = list_next(le);
             //cprintf("in flag\n");
        }
            //if free from full
        if(le == &p_cache->page->full_area){
        flag = 1;
        }
        //if free from partial
        else flag = 0;
    }
    return flag;
}

static void kmem_free(uintptr_t base,size_t n){
    unsigned int order = CalculateOrder(n);
    assert(order < 12);
    kmem_cache* p_cache = get_suit_cache(n);

    //find the target is on which list
    uintptr_t pa = PADDR(base);
    struct Page* page = pa2page(pa);
    //find the list, to find the target you need
    int flag = where_is_the_block(page,p_cache);

    //if it's free on cpu_slab
    if(flag==2){
        p_cache->cpu->free_blocks_num ++;
        if(p_cache->block_num == p_cache->cpu->free_blocks_num){
            p_cache->cpu = NULL;
            pmm_manager->free_pages(page,1);//reback the page to pmm
        }
        *(uint64_t*)base = p_cache->cpu->free_blocks;//point to next
        p_cache->cpu->free_blocks = base; //point to this
    //if it's free on full
    }else if (flag==1){
        //give it to partial, then solve
        list_del(&(page->page_link));
        list_add(&(p_cache->page->partial_area),&(page->page_link));
        page->free_blocks_num ++;

        /*maybe just one block*/
        if(p_cache->block_num == page->free_blocks_num){
            list_del(&page->page_link);
            pmm_manager->free_pages(page,1);//reback the page to pmm
        }
    //if it's free on partial
    }else{
        page->free_blocks_num ++;
        /*maybe just one block*/
        if(p_cache->block_num == page->free_blocks_num){
            list_del(&page->page_link);
            pmm_manager->free_pages(page,1);//reback the page to pmm
        }
    }
}

static void
kmem_check(void){
    uintptr_t A = slub_manager->kmalloc(5);
    uintptr_t B = slub_manager->kmalloc(3);
    uintptr_t C = slub_manager->kmalloc(1025);
    uintptr_t D = slub_manager->kmalloc(1111);
    uintptr_t E = slub_manager->kmalloc(2047);
    cprintf("alloc 5 bytes: %x\n",PADDR(A));
    cprintf("alloc 3 bytes: %x\n",PADDR(B));
    cprintf("alloc 1025 bytes: %x\n",PADDR(C));
    cprintf("alloc 1111 bytes: %x\n",PADDR(D));
    cprintf("alloc 2047 bytes: %x\n",PADDR(E));
    struct Page* page = le2page(kmem_slub_cache[10].node->full_area.next,page_link);
    uint64_t fulltest = page2pa(page);
    cprintf("the_first_slab_on_full_list(1024): %x\n",fulltest);
    
    slub_manager->kmfree(D,1111);
    page = le2page(kmem_slub_cache[10].node->partial_area.next,page_link);
    uint64_t partialtest = page2pa(page);   
    cprintf("the_first_slab_on_partial_list(1024): %x\n",partialtest);
    slub_manager->kmfree(C,1025);
    if(kmem_slub_cache[10].node->partial_area.next == &kmem_slub_cache[10].node->partial_area)
    {
        cprintf("empty partial list\n");   
    }

    cprintf("current cpu_free_list of 8bytes slab: %x\n",PADDR(kmem_slub_cache[2].cpu->free_blocks));
    slub_manager->kmfree(A,5);
    cprintf("cpu_free_list of 8bytes slab after free: %x\n",PADDR(kmem_slub_cache[2].cpu->free_blocks));
    asm volatile ("ebreak");
}

const struct slub_manager slub = {
    .name = "simple_slub",
    .init = slub_init,
    .kmalloc = kmem_alloc,
    .kmfree = kmem_free,
    .check = kmem_check,
};