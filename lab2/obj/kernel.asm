
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44660613          	addi	a2,a2,1094 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	53a010ef          	jal	ra,ffffffffc0201584 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	54650513          	addi	a0,a0,1350 # ffffffffc0201598 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	62f000ef          	jal	ra,ffffffffc0200e94 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	7ef000ef          	jal	ra,ffffffffc0201094 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	7b9000ef          	jal	ra,ffffffffc0201094 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	47c50513          	addi	a0,a0,1148 # ffffffffc02015b8 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	48650513          	addi	a0,a0,1158 # ffffffffc02015d8 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	43858593          	addi	a1,a1,1080 # ffffffffc0201596 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	49250513          	addi	a0,a0,1170 # ffffffffc02015f8 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	49e50513          	addi	a0,a0,1182 # ffffffffc0201618 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2fa58593          	addi	a1,a1,762 # ffffffffc0206480 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	4aa50513          	addi	a0,a0,1194 # ffffffffc0201638 <etext+0xa2>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6e558593          	addi	a1,a1,1765 # ffffffffc020687f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	49c50513          	addi	a0,a0,1180 # ffffffffc0201658 <etext+0xc2>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	4be60613          	addi	a2,a2,1214 # ffffffffc0201688 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	4ca50513          	addi	a0,a0,1226 # ffffffffc02016a0 <etext+0x10a>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	4d260613          	addi	a2,a2,1234 # ffffffffc02016b8 <etext+0x122>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	4ea58593          	addi	a1,a1,1258 # ffffffffc02016d8 <etext+0x142>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	4ea50513          	addi	a0,a0,1258 # ffffffffc02016e0 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	4ec60613          	addi	a2,a2,1260 # ffffffffc02016f0 <etext+0x15a>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	50c58593          	addi	a1,a1,1292 # ffffffffc0201718 <etext+0x182>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	4cc50513          	addi	a0,a0,1228 # ffffffffc02016e0 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	50860613          	addi	a2,a2,1288 # ffffffffc0201728 <etext+0x192>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	52058593          	addi	a1,a1,1312 # ffffffffc0201748 <etext+0x1b2>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	4b050513          	addi	a0,a0,1200 # ffffffffc02016e0 <etext+0x14a>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201758 <etext+0x1c2>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	4f450513          	addi	a0,a0,1268 # ffffffffc0201780 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	54ec0c13          	addi	s8,s8,1358 # ffffffffc02017f0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	4fe90913          	addi	s2,s2,1278 # ffffffffc02017a8 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	4fe48493          	addi	s1,s1,1278 # ffffffffc02017b0 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	4fcb0b13          	addi	s6,s6,1276 # ffffffffc02017b8 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	414a0a13          	addi	s4,s4,1044 # ffffffffc02016d8 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	146010ef          	jal	ra,ffffffffc0201416 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	50ad0d13          	addi	s10,s10,1290 # ffffffffc02017f0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	25c010ef          	jal	ra,ffffffffc0201550 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	248010ef          	jal	ra,ffffffffc0201550 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	228010ef          	jal	ra,ffffffffc020156e <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	1ea010ef          	jal	ra,ffffffffc020156e <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	43a50513          	addi	a0,a0,1082 # ffffffffc02017d8 <etext+0x242>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	08430313          	addi	t1,t1,132 # ffffffffc0206430 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	45e50513          	addi	a0,a0,1118 # ffffffffc0201838 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	29050513          	addi	a0,a0,656 # ffffffffc0201680 <etext+0xea>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	0c4010ef          	jal	ra,ffffffffc02014e4 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	42a50513          	addi	a0,a0,1066 # ffffffffc0201858 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	09e0106f          	j	ffffffffc02014e4 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	07a0106f          	j	ffffffffc02014ca <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	0aa0106f          	j	ffffffffc02014fe <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	30878793          	addi	a5,a5,776 # ffffffffc0200770 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	3fa50513          	addi	a0,a0,1018 # ffffffffc0201878 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	40250513          	addi	a0,a0,1026 # ffffffffc0201890 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	40c50513          	addi	a0,a0,1036 # ffffffffc02018a8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	41650513          	addi	a0,a0,1046 # ffffffffc02018c0 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	42050513          	addi	a0,a0,1056 # ffffffffc02018d8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	42a50513          	addi	a0,a0,1066 # ffffffffc02018f0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	43450513          	addi	a0,a0,1076 # ffffffffc0201908 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	43e50513          	addi	a0,a0,1086 # ffffffffc0201920 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	44850513          	addi	a0,a0,1096 # ffffffffc0201938 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	45250513          	addi	a0,a0,1106 # ffffffffc0201950 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	45c50513          	addi	a0,a0,1116 # ffffffffc0201968 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	46650513          	addi	a0,a0,1126 # ffffffffc0201980 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	47050513          	addi	a0,a0,1136 # ffffffffc0201998 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	47a50513          	addi	a0,a0,1146 # ffffffffc02019b0 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	48450513          	addi	a0,a0,1156 # ffffffffc02019c8 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	48e50513          	addi	a0,a0,1166 # ffffffffc02019e0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	49850513          	addi	a0,a0,1176 # ffffffffc02019f8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	4a250513          	addi	a0,a0,1186 # ffffffffc0201a10 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201a28 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	4b650513          	addi	a0,a0,1206 # ffffffffc0201a40 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	4c050513          	addi	a0,a0,1216 # ffffffffc0201a58 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	4ca50513          	addi	a0,a0,1226 # ffffffffc0201a70 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	4d450513          	addi	a0,a0,1236 # ffffffffc0201a88 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	4de50513          	addi	a0,a0,1246 # ffffffffc0201aa0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	4e850513          	addi	a0,a0,1256 # ffffffffc0201ab8 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	4f250513          	addi	a0,a0,1266 # ffffffffc0201ad0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201ae8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	50650513          	addi	a0,a0,1286 # ffffffffc0201b00 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	51050513          	addi	a0,a0,1296 # ffffffffc0201b18 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	51a50513          	addi	a0,a0,1306 # ffffffffc0201b30 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	52450513          	addi	a0,a0,1316 # ffffffffc0201b48 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	52a50513          	addi	a0,a0,1322 # ffffffffc0201b60 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	52e50513          	addi	a0,a0,1326 # ffffffffc0201b78 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	52e50513          	addi	a0,a0,1326 # ffffffffc0201b90 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	53650513          	addi	a0,a0,1334 # ffffffffc0201ba8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	53e50513          	addi	a0,a0,1342 # ffffffffc0201bc0 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	54250513          	addi	a0,a0,1346 # ffffffffc0201bd8 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76f63          	bltu	a4,a5,ffffffffc020072a <interrupt_handler+0x88>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	60870713          	addi	a4,a4,1544 # ffffffffc0201cb8 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	58e50513          	addi	a0,a0,1422 # ffffffffc0201c50 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	56450513          	addi	a0,a0,1380 # ffffffffc0201c30 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	51a50513          	addi	a0,a0,1306 # ffffffffc0201bf0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	59050513          	addi	a0,a0,1424 # ffffffffc0201c70 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
ffffffffc02006ee:	e022                	sd	s0,0(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006f0:	d4bff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            ticks+=1;
ffffffffc02006f4:	00006797          	auipc	a5,0x6
ffffffffc02006f8:	d4478793          	addi	a5,a5,-700 # ffffffffc0206438 <ticks>
ffffffffc02006fc:	6398                	ld	a4,0(a5)
ffffffffc02006fe:	0705                	addi	a4,a4,1
ffffffffc0200700:	e398                	sd	a4,0(a5)
            if(ticks%100==0)
ffffffffc0200702:	639c                	ld	a5,0(a5)
ffffffffc0200704:	06400713          	li	a4,100
ffffffffc0200708:	02e7f7b3          	remu	a5,a5,a4
ffffffffc020070c:	c385                	beqz	a5,ffffffffc020072c <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070e:	60a2                	ld	ra,8(sp)
ffffffffc0200710:	6402                	ld	s0,0(sp)
ffffffffc0200712:	0141                	addi	sp,sp,16
ffffffffc0200714:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200716:	00001517          	auipc	a0,0x1
ffffffffc020071a:	58250513          	addi	a0,a0,1410 # ffffffffc0201c98 <commands+0x4a8>
ffffffffc020071e:	ba51                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	4f050513          	addi	a0,a0,1264 # ffffffffc0201c10 <commands+0x420>
ffffffffc0200728:	b269                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc020072a:	bf21                	j	ffffffffc0200642 <print_trapframe>
                num+=1;
ffffffffc020072c:	00006417          	auipc	s0,0x6
ffffffffc0200730:	d1440413          	addi	s0,s0,-748 # ffffffffc0206440 <num>
ffffffffc0200734:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	06400593          	li	a1,100
ffffffffc020073a:	00001517          	auipc	a0,0x1
ffffffffc020073e:	54e50513          	addi	a0,a0,1358 # ffffffffc0201c88 <commands+0x498>
                num+=1;
ffffffffc0200742:	0785                	addi	a5,a5,1
ffffffffc0200744:	e01c                	sd	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200746:	96dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                if(num==10)
ffffffffc020074a:	6018                	ld	a4,0(s0)
ffffffffc020074c:	47a9                	li	a5,10
ffffffffc020074e:	fcf710e3          	bne	a4,a5,ffffffffc020070e <interrupt_handler+0x6c>
}
ffffffffc0200752:	6402                	ld	s0,0(sp)
ffffffffc0200754:	60a2                	ld	ra,8(sp)
ffffffffc0200756:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc0200758:	5c30006f          	j	ffffffffc020151a <sbi_shutdown>

ffffffffc020075c <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075c:	11853783          	ld	a5,280(a0)
ffffffffc0200760:	0007c763          	bltz	a5,ffffffffc020076e <trap+0x12>
    switch (tf->cause) {
ffffffffc0200764:	472d                	li	a4,11
ffffffffc0200766:	00f76363          	bltu	a4,a5,ffffffffc020076c <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020076a:	8082                	ret
            print_trapframe(tf);
ffffffffc020076c:	bdd9                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	bf15                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc0200770 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200770:	14011073          	csrw	sscratch,sp
ffffffffc0200774:	712d                	addi	sp,sp,-288
ffffffffc0200776:	e002                	sd	zero,0(sp)
ffffffffc0200778:	e406                	sd	ra,8(sp)
ffffffffc020077a:	ec0e                	sd	gp,24(sp)
ffffffffc020077c:	f012                	sd	tp,32(sp)
ffffffffc020077e:	f416                	sd	t0,40(sp)
ffffffffc0200780:	f81a                	sd	t1,48(sp)
ffffffffc0200782:	fc1e                	sd	t2,56(sp)
ffffffffc0200784:	e0a2                	sd	s0,64(sp)
ffffffffc0200786:	e4a6                	sd	s1,72(sp)
ffffffffc0200788:	e8aa                	sd	a0,80(sp)
ffffffffc020078a:	ecae                	sd	a1,88(sp)
ffffffffc020078c:	f0b2                	sd	a2,96(sp)
ffffffffc020078e:	f4b6                	sd	a3,104(sp)
ffffffffc0200790:	f8ba                	sd	a4,112(sp)
ffffffffc0200792:	fcbe                	sd	a5,120(sp)
ffffffffc0200794:	e142                	sd	a6,128(sp)
ffffffffc0200796:	e546                	sd	a7,136(sp)
ffffffffc0200798:	e94a                	sd	s2,144(sp)
ffffffffc020079a:	ed4e                	sd	s3,152(sp)
ffffffffc020079c:	f152                	sd	s4,160(sp)
ffffffffc020079e:	f556                	sd	s5,168(sp)
ffffffffc02007a0:	f95a                	sd	s6,176(sp)
ffffffffc02007a2:	fd5e                	sd	s7,184(sp)
ffffffffc02007a4:	e1e2                	sd	s8,192(sp)
ffffffffc02007a6:	e5e6                	sd	s9,200(sp)
ffffffffc02007a8:	e9ea                	sd	s10,208(sp)
ffffffffc02007aa:	edee                	sd	s11,216(sp)
ffffffffc02007ac:	f1f2                	sd	t3,224(sp)
ffffffffc02007ae:	f5f6                	sd	t4,232(sp)
ffffffffc02007b0:	f9fa                	sd	t5,240(sp)
ffffffffc02007b2:	fdfe                	sd	t6,248(sp)
ffffffffc02007b4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007b8:	100024f3          	csrr	s1,sstatus
ffffffffc02007bc:	14102973          	csrr	s2,sepc
ffffffffc02007c0:	143029f3          	csrr	s3,stval
ffffffffc02007c4:	14202a73          	csrr	s4,scause
ffffffffc02007c8:	e822                	sd	s0,16(sp)
ffffffffc02007ca:	e226                	sd	s1,256(sp)
ffffffffc02007cc:	e64a                	sd	s2,264(sp)
ffffffffc02007ce:	ea4e                	sd	s3,272(sp)
ffffffffc02007d0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d2:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d4:	f89ff0ef          	jal	ra,ffffffffc020075c <trap>

ffffffffc02007d8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007d8:	6492                	ld	s1,256(sp)
ffffffffc02007da:	6932                	ld	s2,264(sp)
ffffffffc02007dc:	10049073          	csrw	sstatus,s1
ffffffffc02007e0:	14191073          	csrw	sepc,s2
ffffffffc02007e4:	60a2                	ld	ra,8(sp)
ffffffffc02007e6:	61e2                	ld	gp,24(sp)
ffffffffc02007e8:	7202                	ld	tp,32(sp)
ffffffffc02007ea:	72a2                	ld	t0,40(sp)
ffffffffc02007ec:	7342                	ld	t1,48(sp)
ffffffffc02007ee:	73e2                	ld	t2,56(sp)
ffffffffc02007f0:	6406                	ld	s0,64(sp)
ffffffffc02007f2:	64a6                	ld	s1,72(sp)
ffffffffc02007f4:	6546                	ld	a0,80(sp)
ffffffffc02007f6:	65e6                	ld	a1,88(sp)
ffffffffc02007f8:	7606                	ld	a2,96(sp)
ffffffffc02007fa:	76a6                	ld	a3,104(sp)
ffffffffc02007fc:	7746                	ld	a4,112(sp)
ffffffffc02007fe:	77e6                	ld	a5,120(sp)
ffffffffc0200800:	680a                	ld	a6,128(sp)
ffffffffc0200802:	68aa                	ld	a7,136(sp)
ffffffffc0200804:	694a                	ld	s2,144(sp)
ffffffffc0200806:	69ea                	ld	s3,152(sp)
ffffffffc0200808:	7a0a                	ld	s4,160(sp)
ffffffffc020080a:	7aaa                	ld	s5,168(sp)
ffffffffc020080c:	7b4a                	ld	s6,176(sp)
ffffffffc020080e:	7bea                	ld	s7,184(sp)
ffffffffc0200810:	6c0e                	ld	s8,192(sp)
ffffffffc0200812:	6cae                	ld	s9,200(sp)
ffffffffc0200814:	6d4e                	ld	s10,208(sp)
ffffffffc0200816:	6dee                	ld	s11,216(sp)
ffffffffc0200818:	7e0e                	ld	t3,224(sp)
ffffffffc020081a:	7eae                	ld	t4,232(sp)
ffffffffc020081c:	7f4e                	ld	t5,240(sp)
ffffffffc020081e:	7fee                	ld	t6,248(sp)
ffffffffc0200820:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200822:	10200073          	sret

ffffffffc0200826 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200826:	00005797          	auipc	a5,0x5
ffffffffc020082a:	7f278793          	addi	a5,a5,2034 # ffffffffc0206018 <free_area>
ffffffffc020082e:	e79c                	sd	a5,8(a5)
ffffffffc0200830:	e39c                	sd	a5,0(a5)
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200832:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200836:	8082                	ret

ffffffffc0200838 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200838:	00005517          	auipc	a0,0x5
ffffffffc020083c:	7f056503          	lwu	a0,2032(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200840:	8082                	ret

ffffffffc0200842 <buddy_check>:

static void
buddy_check(void)
{
ffffffffc0200842:	7179                	addi	sp,sp,-48
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;
    A = alloc_pages(70);
ffffffffc0200844:	04600513          	li	a0,70
{
ffffffffc0200848:	f406                	sd	ra,40(sp)
ffffffffc020084a:	f022                	sd	s0,32(sp)
ffffffffc020084c:	ec26                	sd	s1,24(sp)
ffffffffc020084e:	e84a                	sd	s2,16(sp)
ffffffffc0200850:	e44e                	sd	s3,8(sp)
    A = alloc_pages(70);
ffffffffc0200852:	5c4000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc0200856:	842a                	mv	s0,a0
    B = alloc_pages(35);
ffffffffc0200858:	02300513          	li	a0,35
ffffffffc020085c:	5ba000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc0200860:	89aa                	mv	s3,a0
    C = alloc_pages(257);
ffffffffc0200862:	10100513          	li	a0,257
ffffffffc0200866:	5b0000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc020086a:	892a                	mv	s2,a0
    D = alloc_pages(63);
ffffffffc020086c:	03f00513          	li	a0,63
ffffffffc0200870:	5a6000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc0200874:	84aa                	mv	s1,a0
    cprintf("A分配70，B分配35，C分配257，D分配63\n");
ffffffffc0200876:	00001517          	auipc	a0,0x1
ffffffffc020087a:	47250513          	addi	a0,a0,1138 # ffffffffc0201ce8 <commands+0x4f8>
ffffffffc020087e:	835ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时A %p\n",A);
ffffffffc0200882:	85a2                	mv	a1,s0
ffffffffc0200884:	00001517          	auipc	a0,0x1
ffffffffc0200888:	49450513          	addi	a0,a0,1172 # ffffffffc0201d18 <commands+0x528>
ffffffffc020088c:	827ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时B %p\n",B);
ffffffffc0200890:	85ce                	mv	a1,s3
ffffffffc0200892:	00001517          	auipc	a0,0x1
ffffffffc0200896:	49650513          	addi	a0,a0,1174 # ffffffffc0201d28 <commands+0x538>
ffffffffc020089a:	819ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时C %p\n",C);
ffffffffc020089e:	85ca                	mv	a1,s2
ffffffffc02008a0:	00001517          	auipc	a0,0x1
ffffffffc02008a4:	49850513          	addi	a0,a0,1176 # ffffffffc0201d38 <commands+0x548>
ffffffffc02008a8:	80bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时D %p\n",D);
ffffffffc02008ac:	85a6                	mv	a1,s1
ffffffffc02008ae:	00001517          	auipc	a0,0x1
ffffffffc02008b2:	49a50513          	addi	a0,a0,1178 # ffffffffc0201d48 <commands+0x558>
ffffffffc02008b6:	ffcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(B, 35);
ffffffffc02008ba:	02300593          	li	a1,35
ffffffffc02008be:	854e                	mv	a0,s3
ffffffffc02008c0:	594000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    cprintf("B释放35\n");
ffffffffc02008c4:	00001517          	auipc	a0,0x1
ffffffffc02008c8:	49450513          	addi	a0,a0,1172 # ffffffffc0201d58 <commands+0x568>
ffffffffc02008cc:	fe6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(D, 63);
ffffffffc02008d0:	03f00593          	li	a1,63
ffffffffc02008d4:	8526                	mv	a0,s1
ffffffffc02008d6:	57e000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    cprintf("D释放63\n");
ffffffffc02008da:	00001517          	auipc	a0,0x1
ffffffffc02008de:	48e50513          	addi	a0,a0,1166 # ffffffffc0201d68 <commands+0x578>
ffffffffc02008e2:	fd0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时BD应该合并\n");
ffffffffc02008e6:	00001517          	auipc	a0,0x1
ffffffffc02008ea:	49250513          	addi	a0,a0,1170 # ffffffffc0201d78 <commands+0x588>
ffffffffc02008ee:	fc4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(A, 70);
ffffffffc02008f2:	04600593          	li	a1,70
ffffffffc02008f6:	8522                	mv	a0,s0
ffffffffc02008f8:	55c000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    cprintf("A释放70\n");
ffffffffc02008fc:	00001517          	auipc	a0,0x1
ffffffffc0200900:	49450513          	addi	a0,a0,1172 # ffffffffc0201d90 <commands+0x5a0>
ffffffffc0200904:	faeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时前512个已空，我们再分配511个的A来测试\n");
ffffffffc0200908:	00001517          	auipc	a0,0x1
ffffffffc020090c:	49850513          	addi	a0,a0,1176 # ffffffffc0201da0 <commands+0x5b0>
ffffffffc0200910:	fa2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    A = alloc_pages(511);
ffffffffc0200914:	1ff00513          	li	a0,511
ffffffffc0200918:	4fe000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc020091c:	842a                	mv	s0,a0
    cprintf("A分配511\n");
ffffffffc020091e:	00001517          	auipc	a0,0x1
ffffffffc0200922:	4c250513          	addi	a0,a0,1218 # ffffffffc0201de0 <commands+0x5f0>
ffffffffc0200926:	f8cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时A %p\n",A);
ffffffffc020092a:	85a2                	mv	a1,s0
ffffffffc020092c:	00001517          	auipc	a0,0x1
ffffffffc0200930:	3ec50513          	addi	a0,a0,1004 # ffffffffc0201d18 <commands+0x528>
ffffffffc0200934:	f7eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(A, 511);
ffffffffc0200938:	1ff00593          	li	a1,511
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	516000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    cprintf("A释放511\n");
ffffffffc0200942:	00001517          	auipc	a0,0x1
ffffffffc0200946:	4ae50513          	addi	a0,a0,1198 # ffffffffc0201df0 <commands+0x600>
ffffffffc020094a:	f68ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    A = alloc_pages(255);
ffffffffc020094e:	0ff00513          	li	a0,255
ffffffffc0200952:	4c4000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc0200956:	84aa                	mv	s1,a0
    B = alloc_pages(255);
ffffffffc0200958:	0ff00513          	li	a0,255
ffffffffc020095c:	4ba000ef          	jal	ra,ffffffffc0200e16 <alloc_pages>
ffffffffc0200960:	842a                	mv	s0,a0
    cprintf("A分配255，B分配255\n");
ffffffffc0200962:	00001517          	auipc	a0,0x1
ffffffffc0200966:	49e50513          	addi	a0,a0,1182 # ffffffffc0201e00 <commands+0x610>
ffffffffc020096a:	f48ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时A %p\n",A);
ffffffffc020096e:	85a6                	mv	a1,s1
ffffffffc0200970:	00001517          	auipc	a0,0x1
ffffffffc0200974:	3a850513          	addi	a0,a0,936 # ffffffffc0201d18 <commands+0x528>
ffffffffc0200978:	f3aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时B %p\n",B);
ffffffffc020097c:	85a2                	mv	a1,s0
ffffffffc020097e:	00001517          	auipc	a0,0x1
ffffffffc0200982:	3aa50513          	addi	a0,a0,938 # ffffffffc0201d28 <commands+0x538>
ffffffffc0200986:	f2cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(C, 257);
ffffffffc020098a:	854a                	mv	a0,s2
ffffffffc020098c:	10100593          	li	a1,257
ffffffffc0200990:	4c4000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    free_pages(A, 255);
ffffffffc0200994:	8526                	mv	a0,s1
ffffffffc0200996:	0ff00593          	li	a1,255
ffffffffc020099a:	4ba000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    free_pages(B, 255);  
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	0ff00593          	li	a1,255
ffffffffc02009a4:	4b0000ef          	jal	ra,ffffffffc0200e54 <free_pages>
    cprintf("全部释放\n");
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	47850513          	addi	a0,a0,1144 # ffffffffc0201e20 <commands+0x630>
ffffffffc02009b0:	f02ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("检查完成，没有错误\n");
}
ffffffffc02009b4:	7402                	ld	s0,32(sp)
ffffffffc02009b6:	70a2                	ld	ra,40(sp)
ffffffffc02009b8:	64e2                	ld	s1,24(sp)
ffffffffc02009ba:	6942                	ld	s2,16(sp)
ffffffffc02009bc:	69a2                	ld	s3,8(sp)
    cprintf("检查完成，没有错误\n");
ffffffffc02009be:	00001517          	auipc	a0,0x1
ffffffffc02009c2:	47250513          	addi	a0,a0,1138 # ffffffffc0201e30 <commands+0x640>
}
ffffffffc02009c6:	6145                	addi	sp,sp,48
    cprintf("检查完成，没有错误\n");
ffffffffc02009c8:	eeaff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc02009cc <buddy_free_pages>:
{
ffffffffc02009cc:	1141                	addi	sp,sp,-16
ffffffffc02009ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02009d0:	20058063          	beqz	a1,ffffffffc0200bd0 <buddy_free_pages+0x204>
    size--;
ffffffffc02009d4:	fff58793          	addi	a5,a1,-1
    while (size >= 1) {
ffffffffc02009d8:	1c078863          	beqz	a5,ffffffffc0200ba8 <buddy_free_pages+0x1dc>
    unsigned i = 0;
ffffffffc02009dc:	4701                	li	a4,0
        size >>= 1; 
ffffffffc02009de:	8385                	srli	a5,a5,0x1
        i++;
ffffffffc02009e0:	2705                	addiw	a4,a4,1
    while (size >= 1) {
ffffffffc02009e2:	fff5                	bnez	a5,ffffffffc02009de <buddy_free_pages+0x12>
    return 1 << i; 
ffffffffc02009e4:	4605                	li	a2,1
ffffffffc02009e6:	00e6163b          	sllw	a2,a2,a4
    for (; p != base + n; p ++) {
ffffffffc02009ea:	00261693          	slli	a3,a2,0x2
ffffffffc02009ee:	96b2                	add	a3,a3,a2
ffffffffc02009f0:	068e                	slli	a3,a3,0x3
ffffffffc02009f2:	96aa                	add	a3,a3,a0
ffffffffc02009f4:	02d50363          	beq	a0,a3,ffffffffc0200a1a <buddy_free_pages+0x4e>
ffffffffc02009f8:	87aa                	mv	a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009fa:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02009fc:	8b05                	andi	a4,a4,1
ffffffffc02009fe:	1a071963          	bnez	a4,ffffffffc0200bb0 <buddy_free_pages+0x1e4>
ffffffffc0200a02:	6798                	ld	a4,8(a5)
ffffffffc0200a04:	8b09                	andi	a4,a4,2
ffffffffc0200a06:	1a071563          	bnez	a4,ffffffffc0200bb0 <buddy_free_pages+0x1e4>
        p->flags = 0;
ffffffffc0200a0a:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a0e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200a12:	02878793          	addi	a5,a5,40
ffffffffc0200a16:	fed792e3          	bne	a5,a3,ffffffffc02009fa <buddy_free_pages+0x2e>
    base->property = n;
ffffffffc0200a1a:	0006071b          	sext.w	a4,a2
ffffffffc0200a1e:	c918                	sw	a4,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a20:	4789                	li	a5,2
ffffffffc0200a22:	00850693          	addi	a3,a0,8
ffffffffc0200a26:	40f6b02f          	amoor.d	zero,a5,(a3)
    nr_free += n;
ffffffffc0200a2a:	00005817          	auipc	a6,0x5
ffffffffc0200a2e:	5ee80813          	addi	a6,a6,1518 # ffffffffc0206018 <free_area>
ffffffffc0200a32:	01082603          	lw	a2,16(a6)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200a36:	00883783          	ld	a5,8(a6)
        list_add(&free_list, &(base->page_link));
ffffffffc0200a3a:	01850693          	addi	a3,a0,24
    nr_free += n;
ffffffffc0200a3e:	9f31                	addw	a4,a4,a2
ffffffffc0200a40:	00e82823          	sw	a4,16(a6)
    if (list_empty(&free_list)) {
ffffffffc0200a44:	15078863          	beq	a5,a6,ffffffffc0200b94 <buddy_free_pages+0x1c8>
            struct Page* page = le2page(le, page_link);
ffffffffc0200a48:	fe878713          	addi	a4,a5,-24
ffffffffc0200a4c:	00083583          	ld	a1,0(a6)
    if (list_empty(&free_list)) {
ffffffffc0200a50:	4601                	li	a2,0
            if (base < page) {
ffffffffc0200a52:	00e56a63          	bltu	a0,a4,ffffffffc0200a66 <buddy_free_pages+0x9a>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200a56:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200a58:	11070b63          	beq	a4,a6,ffffffffc0200b6e <buddy_free_pages+0x1a2>
    for (; p != base + n; p ++) {
ffffffffc0200a5c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200a5e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200a62:	fee57ae3          	bgeu	a0,a4,ffffffffc0200a56 <buddy_free_pages+0x8a>
ffffffffc0200a66:	c219                	beqz	a2,ffffffffc0200a6c <buddy_free_pages+0xa0>
ffffffffc0200a68:	00b83023          	sd	a1,0(a6)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200a6c:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200a6e:	e394                	sd	a3,0(a5)
ffffffffc0200a70:	e714                	sd	a3,8(a4)
    return listelm->next;
ffffffffc0200a72:	00883f03          	ld	t5,8(a6)
    elm->next = next;
ffffffffc0200a76:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200a78:	ed18                	sd	a4,24(a0)
        if(((base-q)/base->property)%2==1)
ffffffffc0200a7a:	4914                	lw	a3,16(a0)
    struct Page *q=le2page(list_next(&free_list),page_link);
ffffffffc0200a7c:	1f21                	addi	t5,t5,-24
    while(flag==1)
ffffffffc0200a7e:	41e50fb3          	sub	t6,a0,t5
ffffffffc0200a82:	02069593          	slli	a1,a3,0x20
ffffffffc0200a86:	00001317          	auipc	t1,0x1
ffffffffc0200a8a:	7fa33303          	ld	t1,2042(t1) # ffffffffc0202280 <error_string+0x38>
ffffffffc0200a8e:	9181                	srli	a1,a1,0x20
        if(((base-q)/base->property)%2==1)
ffffffffc0200a90:	4885                	li	a7,1
ffffffffc0200a92:	4e89                	li	t4,2
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a94:	5e75                	li	t3,-3
ffffffffc0200a96:	403fd793          	srai	a5,t6,0x3
ffffffffc0200a9a:	026787b3          	mul	a5,a5,t1
ffffffffc0200a9e:	02b7c7b3          	div	a5,a5,a1
ffffffffc0200aa2:	03f7d613          	srli	a2,a5,0x3f
ffffffffc0200aa6:	00c78733          	add	a4,a5,a2
ffffffffc0200aaa:	8b05                	andi	a4,a4,1
ffffffffc0200aac:	8f11                	sub	a4,a4,a2
ffffffffc0200aae:	07170563          	beq	a4,a7,ffffffffc0200b18 <buddy_free_pages+0x14c>
        else if(((base-q)/base->property)%2==0)
ffffffffc0200ab2:	8b85                	andi	a5,a5,1
ffffffffc0200ab4:	f3ed                	bnez	a5,ffffffffc0200a96 <buddy_free_pages+0xca>
    return listelm->next;
ffffffffc0200ab6:	7118                	ld	a4,32(a0)
            if (le != &free_list) {
ffffffffc0200ab8:	0d070663          	beq	a4,a6,ffffffffc0200b84 <buddy_free_pages+0x1b8>
                if (base + base->property == p && p->property==base->property) {
ffffffffc0200abc:	00259793          	slli	a5,a1,0x2
ffffffffc0200ac0:	97ae                	add	a5,a5,a1
ffffffffc0200ac2:	078e                	slli	a5,a5,0x3
ffffffffc0200ac4:	97aa                	add	a5,a5,a0
                p = le2page(le, page_link);
ffffffffc0200ac6:	fe870613          	addi	a2,a4,-24
                if (base + base->property == p && p->property==base->property) {
ffffffffc0200aca:	0ac79d63          	bne	a5,a2,ffffffffc0200b84 <buddy_free_pages+0x1b8>
ffffffffc0200ace:	ff872783          	lw	a5,-8(a4)
ffffffffc0200ad2:	0ad79963          	bne	a5,a3,ffffffffc0200b84 <buddy_free_pages+0x1b8>
                    base->property += p->property;
ffffffffc0200ad6:	0016969b          	slliw	a3,a3,0x1
ffffffffc0200ada:	c914                	sw	a3,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200adc:	00850793          	addi	a5,a0,8
ffffffffc0200ae0:	41d7b02f          	amoor.d	zero,t4,(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ae4:	ff070793          	addi	a5,a4,-16
ffffffffc0200ae8:	61c7b02f          	amoand.d	zero,t3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200aec:	6310                	ld	a2,0(a4)
ffffffffc0200aee:	671c                	ld	a5,8(a4)
        if(((base-q)/base->property)%2==1)
ffffffffc0200af0:	4914                	lw	a3,16(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200af2:	e61c                	sd	a5,8(a2)
    next->prev = prev;
ffffffffc0200af4:	e390                	sd	a2,0(a5)
ffffffffc0200af6:	403fd793          	srai	a5,t6,0x3
ffffffffc0200afa:	026787b3          	mul	a5,a5,t1
ffffffffc0200afe:	02069593          	slli	a1,a3,0x20
ffffffffc0200b02:	9181                	srli	a1,a1,0x20
ffffffffc0200b04:	02b7c7b3          	div	a5,a5,a1
ffffffffc0200b08:	03f7d613          	srli	a2,a5,0x3f
ffffffffc0200b0c:	00c78733          	add	a4,a5,a2
ffffffffc0200b10:	8b05                	andi	a4,a4,1
ffffffffc0200b12:	8f11                	sub	a4,a4,a2
ffffffffc0200b14:	f9171fe3          	bne	a4,a7,ffffffffc0200ab2 <buddy_free_pages+0xe6>
    return listelm->prev;
ffffffffc0200b18:	6d1c                	ld	a5,24(a0)
            if (le != &free_list) {
ffffffffc0200b1a:	07078563          	beq	a5,a6,ffffffffc0200b84 <buddy_free_pages+0x1b8>
                if (p + p->property == base && p->property==base->property) {
ffffffffc0200b1e:	ff87a583          	lw	a1,-8(a5)
                p = le2page(le, page_link);
ffffffffc0200b22:	fe878f93          	addi	t6,a5,-24
                if (p + p->property == base && p->property==base->property) {
ffffffffc0200b26:	02059613          	slli	a2,a1,0x20
ffffffffc0200b2a:	9201                	srli	a2,a2,0x20
ffffffffc0200b2c:	00261713          	slli	a4,a2,0x2
ffffffffc0200b30:	9732                	add	a4,a4,a2
ffffffffc0200b32:	070e                	slli	a4,a4,0x3
ffffffffc0200b34:	977e                	add	a4,a4,t6
ffffffffc0200b36:	04e51763          	bne	a0,a4,ffffffffc0200b84 <buddy_free_pages+0x1b8>
ffffffffc0200b3a:	04d59563          	bne	a1,a3,ffffffffc0200b84 <buddy_free_pages+0x1b8>
                    p->property += base->property;
ffffffffc0200b3e:	0016969b          	slliw	a3,a3,0x1
ffffffffc0200b42:	fed7ac23          	sw	a3,-8(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b46:	ff078713          	addi	a4,a5,-16
ffffffffc0200b4a:	41d7302f          	amoor.d	zero,t4,(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b4e:	00850713          	addi	a4,a0,8
ffffffffc0200b52:	61c7302f          	amoand.d	zero,t3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b56:	7118                	ld	a4,32(a0)
        if(((base-q)/base->property)%2==1)
ffffffffc0200b58:	ff87a683          	lw	a3,-8(a5)
                    base = p;
ffffffffc0200b5c:	857e                	mv	a0,t6
    prev->next = next;
ffffffffc0200b5e:	e798                	sd	a4,8(a5)
    next->prev = prev;
ffffffffc0200b60:	02069593          	slli	a1,a3,0x20
ffffffffc0200b64:	e31c                	sd	a5,0(a4)
ffffffffc0200b66:	41ef8fb3          	sub	t6,t6,t5
ffffffffc0200b6a:	9181                	srli	a1,a1,0x20
ffffffffc0200b6c:	b72d                	j	ffffffffc0200a96 <buddy_free_pages+0xca>
    prev->next = next->prev = elm;
ffffffffc0200b6e:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0200b70:	03053023          	sd	a6,32(a0)
    return listelm->next;
ffffffffc0200b74:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200b76:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200b78:	01070963          	beq	a4,a6,ffffffffc0200b8a <buddy_free_pages+0x1be>
    prev->next = next->prev = elm;
ffffffffc0200b7c:	85b6                	mv	a1,a3
ffffffffc0200b7e:	4605                	li	a2,1
    for (; p != base + n; p ++) {
ffffffffc0200b80:	87ba                	mv	a5,a4
ffffffffc0200b82:	bdf1                	j	ffffffffc0200a5e <buddy_free_pages+0x92>
}
ffffffffc0200b84:	60a2                	ld	ra,8(sp)
ffffffffc0200b86:	0141                	addi	sp,sp,16
ffffffffc0200b88:	8082                	ret
    return listelm->next;
ffffffffc0200b8a:	00883f03          	ld	t5,8(a6)
ffffffffc0200b8e:	00d83023          	sd	a3,0(a6)
ffffffffc0200b92:	b5e5                	j	ffffffffc0200a7a <buddy_free_pages+0xae>
    prev->next = next->prev = elm;
ffffffffc0200b94:	00d83023          	sd	a3,0(a6)
ffffffffc0200b98:	00d83423          	sd	a3,8(a6)
    elm->next = next;
ffffffffc0200b9c:	03053023          	sd	a6,32(a0)
    elm->prev = prev;
ffffffffc0200ba0:	01053c23          	sd	a6,24(a0)
}
ffffffffc0200ba4:	8f36                	mv	t5,a3
ffffffffc0200ba6:	bdd1                	j	ffffffffc0200a7a <buddy_free_pages+0xae>
    while (size >= 1) {
ffffffffc0200ba8:	4605                	li	a2,1
ffffffffc0200baa:	02850693          	addi	a3,a0,40
ffffffffc0200bae:	b5a9                	j	ffffffffc02009f8 <buddy_free_pages+0x2c>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200bb0:	00001697          	auipc	a3,0x1
ffffffffc0200bb4:	2d868693          	addi	a3,a3,728 # ffffffffc0201e88 <commands+0x698>
ffffffffc0200bb8:	00001617          	auipc	a2,0x1
ffffffffc0200bbc:	2a060613          	addi	a2,a2,672 # ffffffffc0201e58 <commands+0x668>
ffffffffc0200bc0:	07900593          	li	a1,121
ffffffffc0200bc4:	00001517          	auipc	a0,0x1
ffffffffc0200bc8:	2ac50513          	addi	a0,a0,684 # ffffffffc0201e70 <commands+0x680>
ffffffffc0200bcc:	fe0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200bd0:	00001697          	auipc	a3,0x1
ffffffffc0200bd4:	28068693          	addi	a3,a3,640 # ffffffffc0201e50 <commands+0x660>
ffffffffc0200bd8:	00001617          	auipc	a2,0x1
ffffffffc0200bdc:	28060613          	addi	a2,a2,640 # ffffffffc0201e58 <commands+0x668>
ffffffffc0200be0:	07500593          	li	a1,117
ffffffffc0200be4:	00001517          	auipc	a0,0x1
ffffffffc0200be8:	28c50513          	addi	a0,a0,652 # ffffffffc0201e70 <commands+0x680>
ffffffffc0200bec:	fc0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bf0 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200bf0:	c975                	beqz	a0,ffffffffc0200ce4 <buddy_alloc_pages+0xf4>
    size--;
ffffffffc0200bf2:	157d                	addi	a0,a0,-1
    while (size >= 1) {
ffffffffc0200bf4:	c575                	beqz	a0,ffffffffc0200ce0 <buddy_alloc_pages+0xf0>
    unsigned i = 0;
ffffffffc0200bf6:	4781                	li	a5,0
        size >>= 1; 
ffffffffc0200bf8:	8105                	srli	a0,a0,0x1
        i++;
ffffffffc0200bfa:	2785                	addiw	a5,a5,1
    while (size >= 1) {
ffffffffc0200bfc:	fd75                	bnez	a0,ffffffffc0200bf8 <buddy_alloc_pages+0x8>
    return 1 << i; 
ffffffffc0200bfe:	4685                	li	a3,1
ffffffffc0200c00:	00f696bb          	sllw	a3,a3,a5
    if (u > nr_free) {
ffffffffc0200c04:	00005317          	auipc	t1,0x5
ffffffffc0200c08:	41430313          	addi	t1,t1,1044 # ffffffffc0206018 <free_area>
ffffffffc0200c0c:	01032803          	lw	a6,16(t1)
ffffffffc0200c10:	02081793          	slli	a5,a6,0x20
ffffffffc0200c14:	9381                	srli	a5,a5,0x20
ffffffffc0200c16:	0cd7e363          	bltu	a5,a3,ffffffffc0200cdc <buddy_alloc_pages+0xec>
    return listelm->next;
ffffffffc0200c1a:	00833783          	ld	a5,8(t1)
    while (le != &free_list) {
ffffffffc0200c1e:	0a678f63          	beq	a5,t1,ffffffffc0200cdc <buddy_alloc_pages+0xec>
    size_t min_size=1e9;
ffffffffc0200c22:	3b9ad637          	lui	a2,0x3b9ad
ffffffffc0200c26:	a0060613          	addi	a2,a2,-1536 # 3b9aca00 <kern_entry-0xffffffff84853600>
    struct Page *page = NULL;
ffffffffc0200c2a:	4501                	li	a0,0
        if (p->property >= u&&min_size>p->property) {
ffffffffc0200c2c:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200c30:	00d76763          	bltu	a4,a3,ffffffffc0200c3e <buddy_alloc_pages+0x4e>
ffffffffc0200c34:	00c77563          	bgeu	a4,a2,ffffffffc0200c3e <buddy_alloc_pages+0x4e>
        struct Page *p = le2page(le, page_link);
ffffffffc0200c38:	fe878513          	addi	a0,a5,-24
ffffffffc0200c3c:	863a                	mv	a2,a4
ffffffffc0200c3e:	679c                	ld	a5,8(a5)
    while (le != &free_list) {
ffffffffc0200c40:	fe6796e3          	bne	a5,t1,ffffffffc0200c2c <buddy_alloc_pages+0x3c>
    if (page != NULL) 
ffffffffc0200c44:	cd49                	beqz	a0,ffffffffc0200cde <buddy_alloc_pages+0xee>
        while(page->property>=2*u)
ffffffffc0200c46:	4918                	lw	a4,16(a0)
ffffffffc0200c48:	00169593          	slli	a1,a3,0x1
        ClearPageProperty(page);
ffffffffc0200c4c:	00850e13          	addi	t3,a0,8
        while(page->property>=2*u)
ffffffffc0200c50:	02071793          	slli	a5,a4,0x20
ffffffffc0200c54:	9381                	srli	a5,a5,0x20
ffffffffc0200c56:	06b7e763          	bltu	a5,a1,ffffffffc0200cc4 <buddy_alloc_pages+0xd4>
            list_add(prev, &(q->page_link));
ffffffffc0200c5a:	01850f13          	addi	t5,a0,24
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c5e:	4e89                	li	t4,2
    return listelm->prev;
ffffffffc0200c60:	6d10                	ld	a2,24(a0)
    return listelm->next;
ffffffffc0200c62:	7114                	ld	a3,32(a0)
            struct Page *p = page + page->property/2;
ffffffffc0200c64:	0017581b          	srliw	a6,a4,0x1
ffffffffc0200c68:	00281793          	slli	a5,a6,0x2
ffffffffc0200c6c:	97c2                	add	a5,a5,a6
    prev->next = next;
ffffffffc0200c6e:	e614                	sd	a3,8(a2)
ffffffffc0200c70:	078e                	slli	a5,a5,0x3
    next->prev = prev;
ffffffffc0200c72:	e290                	sd	a2,0(a3)
ffffffffc0200c74:	97aa                	add	a5,a5,a0
ffffffffc0200c76:	0017571b          	srliw	a4,a4,0x1
            p->property=page->property/2;
ffffffffc0200c7a:	cb98                	sw	a4,16(a5)
            q->property=page->property/2;
ffffffffc0200c7c:	4918                	lw	a4,16(a0)
ffffffffc0200c7e:	0017571b          	srliw	a4,a4,0x1
ffffffffc0200c82:	c918                	sw	a4,16(a0)
ffffffffc0200c84:	00878713          	addi	a4,a5,8
ffffffffc0200c88:	41d7302f          	amoor.d	zero,t4,(a4)
ffffffffc0200c8c:	41de302f          	amoor.d	zero,t4,(t3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c90:	00863883          	ld	a7,8(a2)
        while(page->property>=2*u)
ffffffffc0200c94:	4918                	lw	a4,16(a0)
            list_add_before(next, &(p->page_link));
ffffffffc0200c96:	01878813          	addi	a6,a5,24
    prev->next = next->prev = elm;
ffffffffc0200c9a:	01e8b023          	sd	t5,0(a7)
ffffffffc0200c9e:	01e63423          	sd	t5,8(a2)
    elm->prev = prev;
ffffffffc0200ca2:	ed10                	sd	a2,24(a0)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200ca4:	6290                	ld	a2,0(a3)
    elm->next = next;
ffffffffc0200ca6:	03153023          	sd	a7,32(a0)
    prev->next = next->prev = elm;
ffffffffc0200caa:	0106b023          	sd	a6,0(a3)
ffffffffc0200cae:	01063423          	sd	a6,8(a2)
    elm->next = next;
ffffffffc0200cb2:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200cb4:	ef90                	sd	a2,24(a5)
        while(page->property>=2*u)
ffffffffc0200cb6:	02071793          	slli	a5,a4,0x20
ffffffffc0200cba:	9381                	srli	a5,a5,0x20
ffffffffc0200cbc:	fab7f2e3          	bgeu	a5,a1,ffffffffc0200c60 <buddy_alloc_pages+0x70>
        nr_free -= page->property;
ffffffffc0200cc0:	01032803          	lw	a6,16(t1)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200cc4:	711c                	ld	a5,32(a0)
ffffffffc0200cc6:	6d14                	ld	a3,24(a0)
ffffffffc0200cc8:	40e8073b          	subw	a4,a6,a4
    prev->next = next;
ffffffffc0200ccc:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200cce:	e394                	sd	a3,0(a5)
ffffffffc0200cd0:	00e32823          	sw	a4,16(t1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200cd4:	57f5                	li	a5,-3
ffffffffc0200cd6:	60fe302f          	amoand.d	zero,a5,(t3)
}
ffffffffc0200cda:	8082                	ret
        return NULL;
ffffffffc0200cdc:	4501                	li	a0,0
}
ffffffffc0200cde:	8082                	ret
    while (size >= 1) {
ffffffffc0200ce0:	4685                	li	a3,1
ffffffffc0200ce2:	b70d                	j	ffffffffc0200c04 <buddy_alloc_pages+0x14>
{
ffffffffc0200ce4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200ce6:	00001697          	auipc	a3,0x1
ffffffffc0200cea:	16a68693          	addi	a3,a3,362 # ffffffffc0201e50 <commands+0x660>
ffffffffc0200cee:	00001617          	auipc	a2,0x1
ffffffffc0200cf2:	16a60613          	addi	a2,a2,362 # ffffffffc0201e58 <commands+0x668>
ffffffffc0200cf6:	04a00593          	li	a1,74
ffffffffc0200cfa:	00001517          	auipc	a0,0x1
ffffffffc0200cfe:	17650513          	addi	a0,a0,374 # ffffffffc0201e70 <commands+0x680>
{
ffffffffc0200d02:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d04:	ea8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d08 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d08:	1141                	addi	sp,sp,-16
ffffffffc0200d0a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d0c:	c5f5                	beqz	a1,ffffffffc0200df8 <buddy_init_memmap+0xf0>
    size--;
ffffffffc0200d0e:	fff58793          	addi	a5,a1,-1
    while (size >= 1) {
ffffffffc0200d12:	c3e9                	beqz	a5,ffffffffc0200dd4 <buddy_init_memmap+0xcc>
    unsigned i = 0;
ffffffffc0200d14:	4701                	li	a4,0
        size >>= 1; 
ffffffffc0200d16:	8385                	srli	a5,a5,0x1
        i++;
ffffffffc0200d18:	2705                	addiw	a4,a4,1
    while (size >= 1) {
ffffffffc0200d1a:	fff5                	bnez	a5,ffffffffc0200d16 <buddy_init_memmap+0xe>
    return 1 << i; 
ffffffffc0200d1c:	4605                	li	a2,1
ffffffffc0200d1e:	00e6173b          	sllw	a4,a2,a4
    n=fixsize(n)/2;
ffffffffc0200d22:	00175613          	srli	a2,a4,0x1
    for (; p != base + n; p ++) {
ffffffffc0200d26:	00261693          	slli	a3,a2,0x2
ffffffffc0200d2a:	96b2                	add	a3,a3,a2
ffffffffc0200d2c:	068e                	slli	a3,a3,0x3
ffffffffc0200d2e:	96aa                	add	a3,a3,a0
ffffffffc0200d30:	02d50063          	beq	a0,a3,ffffffffc0200d50 <buddy_init_memmap+0x48>
ffffffffc0200d34:	87aa                	mv	a5,a0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d36:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200d38:	8b05                	andi	a4,a4,1
ffffffffc0200d3a:	cf59                	beqz	a4,ffffffffc0200dd8 <buddy_init_memmap+0xd0>
        p->flags = p->property = 0;
ffffffffc0200d3c:	0007a823          	sw	zero,16(a5)
ffffffffc0200d40:	0007b423          	sd	zero,8(a5)
ffffffffc0200d44:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200d48:	02878793          	addi	a5,a5,40
ffffffffc0200d4c:	fed795e3          	bne	a5,a3,ffffffffc0200d36 <buddy_init_memmap+0x2e>
    base->property = n;
ffffffffc0200d50:	2601                	sext.w	a2,a2
ffffffffc0200d52:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d54:	4789                	li	a5,2
ffffffffc0200d56:	00850713          	addi	a4,a0,8
ffffffffc0200d5a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0200d5e:	00005697          	auipc	a3,0x5
ffffffffc0200d62:	2ba68693          	addi	a3,a3,698 # ffffffffc0206018 <free_area>
ffffffffc0200d66:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200d68:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200d6a:	01850593          	addi	a1,a0,24
    nr_free += n;
ffffffffc0200d6e:	9e39                	addw	a2,a2,a4
ffffffffc0200d70:	ca90                	sw	a2,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200d72:	04d78a63          	beq	a5,a3,ffffffffc0200dc6 <buddy_init_memmap+0xbe>
            struct Page* page = le2page(le, page_link);
ffffffffc0200d76:	fe878713          	addi	a4,a5,-24
ffffffffc0200d7a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200d7e:	4601                	li	a2,0
            if (base < page) {
ffffffffc0200d80:	00e56a63          	bltu	a0,a4,ffffffffc0200d94 <buddy_init_memmap+0x8c>
    return listelm->next;
ffffffffc0200d84:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200d86:	02d70263          	beq	a4,a3,ffffffffc0200daa <buddy_init_memmap+0xa2>
    while (size >= 1) {
ffffffffc0200d8a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200d8c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200d90:	fee57ae3          	bgeu	a0,a4,ffffffffc0200d84 <buddy_init_memmap+0x7c>
ffffffffc0200d94:	c219                	beqz	a2,ffffffffc0200d9a <buddy_init_memmap+0x92>
ffffffffc0200d96:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d9a:	6398                	ld	a4,0(a5)
}
ffffffffc0200d9c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200d9e:	e38c                	sd	a1,0(a5)
ffffffffc0200da0:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200da2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200da4:	ed18                	sd	a4,24(a0)
ffffffffc0200da6:	0141                	addi	sp,sp,16
ffffffffc0200da8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200daa:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200dac:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200dae:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200db0:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200db2:	00d70663          	beq	a4,a3,ffffffffc0200dbe <buddy_init_memmap+0xb6>
    prev->next = next->prev = elm;
ffffffffc0200db6:	882e                	mv	a6,a1
ffffffffc0200db8:	4605                	li	a2,1
    while (size >= 1) {
ffffffffc0200dba:	87ba                	mv	a5,a4
ffffffffc0200dbc:	bfc1                	j	ffffffffc0200d8c <buddy_init_memmap+0x84>
}
ffffffffc0200dbe:	60a2                	ld	ra,8(sp)
ffffffffc0200dc0:	e28c                	sd	a1,0(a3)
ffffffffc0200dc2:	0141                	addi	sp,sp,16
ffffffffc0200dc4:	8082                	ret
ffffffffc0200dc6:	60a2                	ld	ra,8(sp)
ffffffffc0200dc8:	e38c                	sd	a1,0(a5)
ffffffffc0200dca:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200dcc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200dce:	ed1c                	sd	a5,24(a0)
ffffffffc0200dd0:	0141                	addi	sp,sp,16
ffffffffc0200dd2:	8082                	ret
    while (size >= 1) {
ffffffffc0200dd4:	4601                	li	a2,0
ffffffffc0200dd6:	bfb5                	j	ffffffffc0200d52 <buddy_init_memmap+0x4a>
        assert(PageReserved(p));
ffffffffc0200dd8:	00001697          	auipc	a3,0x1
ffffffffc0200ddc:	0d868693          	addi	a3,a3,216 # ffffffffc0201eb0 <commands+0x6c0>
ffffffffc0200de0:	00001617          	auipc	a2,0x1
ffffffffc0200de4:	07860613          	addi	a2,a2,120 # ffffffffc0201e58 <commands+0x668>
ffffffffc0200de8:	02300593          	li	a1,35
ffffffffc0200dec:	00001517          	auipc	a0,0x1
ffffffffc0200df0:	08450513          	addi	a0,a0,132 # ffffffffc0201e70 <commands+0x680>
ffffffffc0200df4:	db8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200df8:	00001697          	auipc	a3,0x1
ffffffffc0200dfc:	05868693          	addi	a3,a3,88 # ffffffffc0201e50 <commands+0x660>
ffffffffc0200e00:	00001617          	auipc	a2,0x1
ffffffffc0200e04:	05860613          	addi	a2,a2,88 # ffffffffc0201e58 <commands+0x668>
ffffffffc0200e08:	45fd                	li	a1,31
ffffffffc0200e0a:	00001517          	auipc	a0,0x1
ffffffffc0200e0e:	06650513          	addi	a0,a0,102 # ffffffffc0201e70 <commands+0x680>
ffffffffc0200e12:	d9aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e16 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e16:	100027f3          	csrr	a5,sstatus
ffffffffc0200e1a:	8b89                	andi	a5,a5,2
ffffffffc0200e1c:	e799                	bnez	a5,ffffffffc0200e2a <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e1e:	00005797          	auipc	a5,0x5
ffffffffc0200e22:	63a7b783          	ld	a5,1594(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e26:	6f9c                	ld	a5,24(a5)
ffffffffc0200e28:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200e2a:	1141                	addi	sp,sp,-16
ffffffffc0200e2c:	e406                	sd	ra,8(sp)
ffffffffc0200e2e:	e022                	sd	s0,0(sp)
ffffffffc0200e30:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e32:	e2cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e36:	00005797          	auipc	a5,0x5
ffffffffc0200e3a:	6227b783          	ld	a5,1570(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e3e:	6f9c                	ld	a5,24(a5)
ffffffffc0200e40:	8522                	mv	a0,s0
ffffffffc0200e42:	9782                	jalr	a5
ffffffffc0200e44:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e46:	e12ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e4a:	60a2                	ld	ra,8(sp)
ffffffffc0200e4c:	8522                	mv	a0,s0
ffffffffc0200e4e:	6402                	ld	s0,0(sp)
ffffffffc0200e50:	0141                	addi	sp,sp,16
ffffffffc0200e52:	8082                	ret

ffffffffc0200e54 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e54:	100027f3          	csrr	a5,sstatus
ffffffffc0200e58:	8b89                	andi	a5,a5,2
ffffffffc0200e5a:	e799                	bnez	a5,ffffffffc0200e68 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e5c:	00005797          	auipc	a5,0x5
ffffffffc0200e60:	5fc7b783          	ld	a5,1532(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e64:	739c                	ld	a5,32(a5)
ffffffffc0200e66:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e68:	1101                	addi	sp,sp,-32
ffffffffc0200e6a:	ec06                	sd	ra,24(sp)
ffffffffc0200e6c:	e822                	sd	s0,16(sp)
ffffffffc0200e6e:	e426                	sd	s1,8(sp)
ffffffffc0200e70:	842a                	mv	s0,a0
ffffffffc0200e72:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200e74:	deaff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200e78:	00005797          	auipc	a5,0x5
ffffffffc0200e7c:	5e07b783          	ld	a5,1504(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e80:	739c                	ld	a5,32(a5)
ffffffffc0200e82:	85a6                	mv	a1,s1
ffffffffc0200e84:	8522                	mv	a0,s0
ffffffffc0200e86:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200e88:	6442                	ld	s0,16(sp)
ffffffffc0200e8a:	60e2                	ld	ra,24(sp)
ffffffffc0200e8c:	64a2                	ld	s1,8(sp)
ffffffffc0200e8e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200e90:	dc8ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200e94 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e94:	00001797          	auipc	a5,0x1
ffffffffc0200e98:	04478793          	addi	a5,a5,68 # ffffffffc0201ed8 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e9c:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e9e:	1101                	addi	sp,sp,-32
ffffffffc0200ea0:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ea2:	00001517          	auipc	a0,0x1
ffffffffc0200ea6:	06e50513          	addi	a0,a0,110 # ffffffffc0201f10 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200eaa:	00005497          	auipc	s1,0x5
ffffffffc0200eae:	5ae48493          	addi	s1,s1,1454 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0200eb2:	ec06                	sd	ra,24(sp)
ffffffffc0200eb4:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200eb6:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200eb8:	9faff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200ebc:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ebe:	00005417          	auipc	s0,0x5
ffffffffc0200ec2:	5b240413          	addi	s0,s0,1458 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200ec6:	679c                	ld	a5,8(a5)
ffffffffc0200ec8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200eca:	57f5                	li	a5,-3
ffffffffc0200ecc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200ece:	00001517          	auipc	a0,0x1
ffffffffc0200ed2:	05a50513          	addi	a0,a0,90 # ffffffffc0201f28 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ed6:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200ed8:	9daff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200edc:	46c5                	li	a3,17
ffffffffc0200ede:	06ee                	slli	a3,a3,0x1b
ffffffffc0200ee0:	40100613          	li	a2,1025
ffffffffc0200ee4:	16fd                	addi	a3,a3,-1
ffffffffc0200ee6:	07e005b7          	lui	a1,0x7e00
ffffffffc0200eea:	0656                	slli	a2,a2,0x15
ffffffffc0200eec:	00001517          	auipc	a0,0x1
ffffffffc0200ef0:	05450513          	addi	a0,a0,84 # ffffffffc0201f40 <buddy_pmm_manager+0x68>
ffffffffc0200ef4:	9beff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ef8:	777d                	lui	a4,0xfffff
ffffffffc0200efa:	00006797          	auipc	a5,0x6
ffffffffc0200efe:	58578793          	addi	a5,a5,1413 # ffffffffc020747f <end+0xfff>
ffffffffc0200f02:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200f04:	00005517          	auipc	a0,0x5
ffffffffc0200f08:	54450513          	addi	a0,a0,1348 # ffffffffc0206448 <npage>
ffffffffc0200f0c:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f10:	00005597          	auipc	a1,0x5
ffffffffc0200f14:	54058593          	addi	a1,a1,1344 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200f18:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f1a:	e19c                	sd	a5,0(a1)
ffffffffc0200f1c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f1e:	4701                	li	a4,0
ffffffffc0200f20:	4885                	li	a7,1
ffffffffc0200f22:	fff80837          	lui	a6,0xfff80
ffffffffc0200f26:	a011                	j	ffffffffc0200f2a <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200f28:	619c                	ld	a5,0(a1)
ffffffffc0200f2a:	97b6                	add	a5,a5,a3
ffffffffc0200f2c:	07a1                	addi	a5,a5,8
ffffffffc0200f2e:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f32:	611c                	ld	a5,0(a0)
ffffffffc0200f34:	0705                	addi	a4,a4,1
ffffffffc0200f36:	02868693          	addi	a3,a3,40
ffffffffc0200f3a:	01078633          	add	a2,a5,a6
ffffffffc0200f3e:	fec765e3          	bltu	a4,a2,ffffffffc0200f28 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f42:	6190                	ld	a2,0(a1)
ffffffffc0200f44:	00279713          	slli	a4,a5,0x2
ffffffffc0200f48:	973e                	add	a4,a4,a5
ffffffffc0200f4a:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f4e:	070e                	slli	a4,a4,0x3
ffffffffc0200f50:	96b2                	add	a3,a3,a2
ffffffffc0200f52:	96ba                	add	a3,a3,a4
ffffffffc0200f54:	c0200737          	lui	a4,0xc0200
ffffffffc0200f58:	08e6ef63          	bltu	a3,a4,ffffffffc0200ff6 <pmm_init+0x162>
ffffffffc0200f5c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200f5e:	45c5                	li	a1,17
ffffffffc0200f60:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f62:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200f64:	04b6e863          	bltu	a3,a1,ffffffffc0200fb4 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f68:	609c                	ld	a5,0(s1)
ffffffffc0200f6a:	7b9c                	ld	a5,48(a5)
ffffffffc0200f6c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	06a50513          	addi	a0,a0,106 # ffffffffc0201fd8 <buddy_pmm_manager+0x100>
ffffffffc0200f76:	93cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f7a:	00004597          	auipc	a1,0x4
ffffffffc0200f7e:	08658593          	addi	a1,a1,134 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f82:	00005797          	auipc	a5,0x5
ffffffffc0200f86:	4eb7b323          	sd	a1,1254(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f8a:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f8e:	08f5e063          	bltu	a1,a5,ffffffffc020100e <pmm_init+0x17a>
ffffffffc0200f92:	6010                	ld	a2,0(s0)
}
ffffffffc0200f94:	6442                	ld	s0,16(sp)
ffffffffc0200f96:	60e2                	ld	ra,24(sp)
ffffffffc0200f98:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f9a:	40c58633          	sub	a2,a1,a2
ffffffffc0200f9e:	00005797          	auipc	a5,0x5
ffffffffc0200fa2:	4cc7b123          	sd	a2,1218(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fa6:	00001517          	auipc	a0,0x1
ffffffffc0200faa:	05250513          	addi	a0,a0,82 # ffffffffc0201ff8 <buddy_pmm_manager+0x120>
}
ffffffffc0200fae:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fb0:	902ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200fb4:	6705                	lui	a4,0x1
ffffffffc0200fb6:	177d                	addi	a4,a4,-1
ffffffffc0200fb8:	96ba                	add	a3,a3,a4
ffffffffc0200fba:	777d                	lui	a4,0xfffff
ffffffffc0200fbc:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200fbe:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200fc2:	00f57e63          	bgeu	a0,a5,ffffffffc0200fde <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200fc6:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200fc8:	982a                	add	a6,a6,a0
ffffffffc0200fca:	00281513          	slli	a0,a6,0x2
ffffffffc0200fce:	9542                	add	a0,a0,a6
ffffffffc0200fd0:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200fd2:	8d95                	sub	a1,a1,a3
ffffffffc0200fd4:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200fd6:	81b1                	srli	a1,a1,0xc
ffffffffc0200fd8:	9532                	add	a0,a0,a2
ffffffffc0200fda:	9782                	jalr	a5
}
ffffffffc0200fdc:	b771                	j	ffffffffc0200f68 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200fde:	00001617          	auipc	a2,0x1
ffffffffc0200fe2:	fca60613          	addi	a2,a2,-54 # ffffffffc0201fa8 <buddy_pmm_manager+0xd0>
ffffffffc0200fe6:	06b00593          	li	a1,107
ffffffffc0200fea:	00001517          	auipc	a0,0x1
ffffffffc0200fee:	fde50513          	addi	a0,a0,-34 # ffffffffc0201fc8 <buddy_pmm_manager+0xf0>
ffffffffc0200ff2:	bbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ff6:	00001617          	auipc	a2,0x1
ffffffffc0200ffa:	f7a60613          	addi	a2,a2,-134 # ffffffffc0201f70 <buddy_pmm_manager+0x98>
ffffffffc0200ffe:	06f00593          	li	a1,111
ffffffffc0201002:	00001517          	auipc	a0,0x1
ffffffffc0201006:	f9650513          	addi	a0,a0,-106 # ffffffffc0201f98 <buddy_pmm_manager+0xc0>
ffffffffc020100a:	ba2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020100e:	86ae                	mv	a3,a1
ffffffffc0201010:	00001617          	auipc	a2,0x1
ffffffffc0201014:	f6060613          	addi	a2,a2,-160 # ffffffffc0201f70 <buddy_pmm_manager+0x98>
ffffffffc0201018:	08a00593          	li	a1,138
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	f7c50513          	addi	a0,a0,-132 # ffffffffc0201f98 <buddy_pmm_manager+0xc0>
ffffffffc0201024:	b88ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201028 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201028:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020102c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020102e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201032:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201034:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201038:	f022                	sd	s0,32(sp)
ffffffffc020103a:	ec26                	sd	s1,24(sp)
ffffffffc020103c:	e84a                	sd	s2,16(sp)
ffffffffc020103e:	f406                	sd	ra,40(sp)
ffffffffc0201040:	e44e                	sd	s3,8(sp)
ffffffffc0201042:	84aa                	mv	s1,a0
ffffffffc0201044:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201046:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020104a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020104c:	03067e63          	bgeu	a2,a6,ffffffffc0201088 <printnum+0x60>
ffffffffc0201050:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201052:	00805763          	blez	s0,ffffffffc0201060 <printnum+0x38>
ffffffffc0201056:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201058:	85ca                	mv	a1,s2
ffffffffc020105a:	854e                	mv	a0,s3
ffffffffc020105c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020105e:	fc65                	bnez	s0,ffffffffc0201056 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201060:	1a02                	slli	s4,s4,0x20
ffffffffc0201062:	00001797          	auipc	a5,0x1
ffffffffc0201066:	fd678793          	addi	a5,a5,-42 # ffffffffc0202038 <buddy_pmm_manager+0x160>
ffffffffc020106a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020106e:	9a3e                	add	s4,s4,a5
}
ffffffffc0201070:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201072:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201076:	70a2                	ld	ra,40(sp)
ffffffffc0201078:	69a2                	ld	s3,8(sp)
ffffffffc020107a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020107c:	85ca                	mv	a1,s2
ffffffffc020107e:	87a6                	mv	a5,s1
}
ffffffffc0201080:	6942                	ld	s2,16(sp)
ffffffffc0201082:	64e2                	ld	s1,24(sp)
ffffffffc0201084:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201086:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201088:	03065633          	divu	a2,a2,a6
ffffffffc020108c:	8722                	mv	a4,s0
ffffffffc020108e:	f9bff0ef          	jal	ra,ffffffffc0201028 <printnum>
ffffffffc0201092:	b7f9                	j	ffffffffc0201060 <printnum+0x38>

ffffffffc0201094 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201094:	7119                	addi	sp,sp,-128
ffffffffc0201096:	f4a6                	sd	s1,104(sp)
ffffffffc0201098:	f0ca                	sd	s2,96(sp)
ffffffffc020109a:	ecce                	sd	s3,88(sp)
ffffffffc020109c:	e8d2                	sd	s4,80(sp)
ffffffffc020109e:	e4d6                	sd	s5,72(sp)
ffffffffc02010a0:	e0da                	sd	s6,64(sp)
ffffffffc02010a2:	fc5e                	sd	s7,56(sp)
ffffffffc02010a4:	f06a                	sd	s10,32(sp)
ffffffffc02010a6:	fc86                	sd	ra,120(sp)
ffffffffc02010a8:	f8a2                	sd	s0,112(sp)
ffffffffc02010aa:	f862                	sd	s8,48(sp)
ffffffffc02010ac:	f466                	sd	s9,40(sp)
ffffffffc02010ae:	ec6e                	sd	s11,24(sp)
ffffffffc02010b0:	892a                	mv	s2,a0
ffffffffc02010b2:	84ae                	mv	s1,a1
ffffffffc02010b4:	8d32                	mv	s10,a2
ffffffffc02010b6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010b8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02010bc:	5b7d                	li	s6,-1
ffffffffc02010be:	00001a97          	auipc	s5,0x1
ffffffffc02010c2:	faea8a93          	addi	s5,s5,-82 # ffffffffc020206c <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010c6:	00001b97          	auipc	s7,0x1
ffffffffc02010ca:	182b8b93          	addi	s7,s7,386 # ffffffffc0202248 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010ce:	000d4503          	lbu	a0,0(s10)
ffffffffc02010d2:	001d0413          	addi	s0,s10,1
ffffffffc02010d6:	01350a63          	beq	a0,s3,ffffffffc02010ea <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02010da:	c121                	beqz	a0,ffffffffc020111a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02010dc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010de:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010e0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010e2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010e6:	ff351ae3          	bne	a0,s3,ffffffffc02010da <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010ea:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010ee:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010f2:	4c81                	li	s9,0
ffffffffc02010f4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02010f6:	5c7d                	li	s8,-1
ffffffffc02010f8:	5dfd                	li	s11,-1
ffffffffc02010fa:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02010fe:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201100:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201104:	0ff5f593          	zext.b	a1,a1
ffffffffc0201108:	00140d13          	addi	s10,s0,1
ffffffffc020110c:	04b56263          	bltu	a0,a1,ffffffffc0201150 <vprintfmt+0xbc>
ffffffffc0201110:	058a                	slli	a1,a1,0x2
ffffffffc0201112:	95d6                	add	a1,a1,s5
ffffffffc0201114:	4194                	lw	a3,0(a1)
ffffffffc0201116:	96d6                	add	a3,a3,s5
ffffffffc0201118:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020111a:	70e6                	ld	ra,120(sp)
ffffffffc020111c:	7446                	ld	s0,112(sp)
ffffffffc020111e:	74a6                	ld	s1,104(sp)
ffffffffc0201120:	7906                	ld	s2,96(sp)
ffffffffc0201122:	69e6                	ld	s3,88(sp)
ffffffffc0201124:	6a46                	ld	s4,80(sp)
ffffffffc0201126:	6aa6                	ld	s5,72(sp)
ffffffffc0201128:	6b06                	ld	s6,64(sp)
ffffffffc020112a:	7be2                	ld	s7,56(sp)
ffffffffc020112c:	7c42                	ld	s8,48(sp)
ffffffffc020112e:	7ca2                	ld	s9,40(sp)
ffffffffc0201130:	7d02                	ld	s10,32(sp)
ffffffffc0201132:	6de2                	ld	s11,24(sp)
ffffffffc0201134:	6109                	addi	sp,sp,128
ffffffffc0201136:	8082                	ret
            padc = '0';
ffffffffc0201138:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020113a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020113e:	846a                	mv	s0,s10
ffffffffc0201140:	00140d13          	addi	s10,s0,1
ffffffffc0201144:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201148:	0ff5f593          	zext.b	a1,a1
ffffffffc020114c:	fcb572e3          	bgeu	a0,a1,ffffffffc0201110 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201150:	85a6                	mv	a1,s1
ffffffffc0201152:	02500513          	li	a0,37
ffffffffc0201156:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201158:	fff44783          	lbu	a5,-1(s0)
ffffffffc020115c:	8d22                	mv	s10,s0
ffffffffc020115e:	f73788e3          	beq	a5,s3,ffffffffc02010ce <vprintfmt+0x3a>
ffffffffc0201162:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201166:	1d7d                	addi	s10,s10,-1
ffffffffc0201168:	ff379de3          	bne	a5,s3,ffffffffc0201162 <vprintfmt+0xce>
ffffffffc020116c:	b78d                	j	ffffffffc02010ce <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020116e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201172:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201176:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201178:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020117c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201180:	02d86463          	bltu	a6,a3,ffffffffc02011a8 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201184:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201188:	002c169b          	slliw	a3,s8,0x2
ffffffffc020118c:	0186873b          	addw	a4,a3,s8
ffffffffc0201190:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201194:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201196:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020119a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020119c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02011a0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02011a4:	fed870e3          	bgeu	a6,a3,ffffffffc0201184 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02011a8:	f40ddce3          	bgez	s11,ffffffffc0201100 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02011ac:	8de2                	mv	s11,s8
ffffffffc02011ae:	5c7d                	li	s8,-1
ffffffffc02011b0:	bf81                	j	ffffffffc0201100 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02011b2:	fffdc693          	not	a3,s11
ffffffffc02011b6:	96fd                	srai	a3,a3,0x3f
ffffffffc02011b8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011bc:	00144603          	lbu	a2,1(s0)
ffffffffc02011c0:	2d81                	sext.w	s11,s11
ffffffffc02011c2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011c4:	bf35                	j	ffffffffc0201100 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02011c6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ca:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02011ce:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011d0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02011d2:	bfd9                	j	ffffffffc02011a8 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02011d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011d6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011da:	01174463          	blt	a4,a7,ffffffffc02011e2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02011de:	1a088e63          	beqz	a7,ffffffffc020139a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02011e2:	000a3603          	ld	a2,0(s4)
ffffffffc02011e6:	46c1                	li	a3,16
ffffffffc02011e8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011ea:	2781                	sext.w	a5,a5
ffffffffc02011ec:	876e                	mv	a4,s11
ffffffffc02011ee:	85a6                	mv	a1,s1
ffffffffc02011f0:	854a                	mv	a0,s2
ffffffffc02011f2:	e37ff0ef          	jal	ra,ffffffffc0201028 <printnum>
            break;
ffffffffc02011f6:	bde1                	j	ffffffffc02010ce <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02011f8:	000a2503          	lw	a0,0(s4)
ffffffffc02011fc:	85a6                	mv	a1,s1
ffffffffc02011fe:	0a21                	addi	s4,s4,8
ffffffffc0201200:	9902                	jalr	s2
            break;
ffffffffc0201202:	b5f1                	j	ffffffffc02010ce <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201204:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201206:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020120a:	01174463          	blt	a4,a7,ffffffffc0201212 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020120e:	18088163          	beqz	a7,ffffffffc0201390 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201212:	000a3603          	ld	a2,0(s4)
ffffffffc0201216:	46a9                	li	a3,10
ffffffffc0201218:	8a2e                	mv	s4,a1
ffffffffc020121a:	bfc1                	j	ffffffffc02011ea <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020121c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201220:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201222:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201224:	bdf1                	j	ffffffffc0201100 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201226:	85a6                	mv	a1,s1
ffffffffc0201228:	02500513          	li	a0,37
ffffffffc020122c:	9902                	jalr	s2
            break;
ffffffffc020122e:	b545                	j	ffffffffc02010ce <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201230:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201234:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201236:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201238:	b5e1                	j	ffffffffc0201100 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020123a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020123c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201240:	01174463          	blt	a4,a7,ffffffffc0201248 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201244:	14088163          	beqz	a7,ffffffffc0201386 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201248:	000a3603          	ld	a2,0(s4)
ffffffffc020124c:	46a1                	li	a3,8
ffffffffc020124e:	8a2e                	mv	s4,a1
ffffffffc0201250:	bf69                	j	ffffffffc02011ea <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201252:	03000513          	li	a0,48
ffffffffc0201256:	85a6                	mv	a1,s1
ffffffffc0201258:	e03e                	sd	a5,0(sp)
ffffffffc020125a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020125c:	85a6                	mv	a1,s1
ffffffffc020125e:	07800513          	li	a0,120
ffffffffc0201262:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201264:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201266:	6782                	ld	a5,0(sp)
ffffffffc0201268:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020126a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020126e:	bfb5                	j	ffffffffc02011ea <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201270:	000a3403          	ld	s0,0(s4)
ffffffffc0201274:	008a0713          	addi	a4,s4,8
ffffffffc0201278:	e03a                	sd	a4,0(sp)
ffffffffc020127a:	14040263          	beqz	s0,ffffffffc02013be <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020127e:	0fb05763          	blez	s11,ffffffffc020136c <vprintfmt+0x2d8>
ffffffffc0201282:	02d00693          	li	a3,45
ffffffffc0201286:	0cd79163          	bne	a5,a3,ffffffffc0201348 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020128a:	00044783          	lbu	a5,0(s0)
ffffffffc020128e:	0007851b          	sext.w	a0,a5
ffffffffc0201292:	cf85                	beqz	a5,ffffffffc02012ca <vprintfmt+0x236>
ffffffffc0201294:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201298:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020129c:	000c4563          	bltz	s8,ffffffffc02012a6 <vprintfmt+0x212>
ffffffffc02012a0:	3c7d                	addiw	s8,s8,-1
ffffffffc02012a2:	036c0263          	beq	s8,s6,ffffffffc02012c6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02012a6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012a8:	0e0c8e63          	beqz	s9,ffffffffc02013a4 <vprintfmt+0x310>
ffffffffc02012ac:	3781                	addiw	a5,a5,-32
ffffffffc02012ae:	0ef47b63          	bgeu	s0,a5,ffffffffc02013a4 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02012b2:	03f00513          	li	a0,63
ffffffffc02012b6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012b8:	000a4783          	lbu	a5,0(s4)
ffffffffc02012bc:	3dfd                	addiw	s11,s11,-1
ffffffffc02012be:	0a05                	addi	s4,s4,1
ffffffffc02012c0:	0007851b          	sext.w	a0,a5
ffffffffc02012c4:	ffe1                	bnez	a5,ffffffffc020129c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02012c6:	01b05963          	blez	s11,ffffffffc02012d8 <vprintfmt+0x244>
ffffffffc02012ca:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02012cc:	85a6                	mv	a1,s1
ffffffffc02012ce:	02000513          	li	a0,32
ffffffffc02012d2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012d4:	fe0d9be3          	bnez	s11,ffffffffc02012ca <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012d8:	6a02                	ld	s4,0(sp)
ffffffffc02012da:	bbd5                	j	ffffffffc02010ce <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012de:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02012e2:	01174463          	blt	a4,a7,ffffffffc02012ea <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02012e6:	08088d63          	beqz	a7,ffffffffc0201380 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02012ea:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02012ee:	0a044d63          	bltz	s0,ffffffffc02013a8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02012f2:	8622                	mv	a2,s0
ffffffffc02012f4:	8a66                	mv	s4,s9
ffffffffc02012f6:	46a9                	li	a3,10
ffffffffc02012f8:	bdcd                	j	ffffffffc02011ea <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02012fa:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012fe:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201300:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201302:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201306:	8fb5                	xor	a5,a5,a3
ffffffffc0201308:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020130c:	02d74163          	blt	a4,a3,ffffffffc020132e <vprintfmt+0x29a>
ffffffffc0201310:	00369793          	slli	a5,a3,0x3
ffffffffc0201314:	97de                	add	a5,a5,s7
ffffffffc0201316:	639c                	ld	a5,0(a5)
ffffffffc0201318:	cb99                	beqz	a5,ffffffffc020132e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020131a:	86be                	mv	a3,a5
ffffffffc020131c:	00001617          	auipc	a2,0x1
ffffffffc0201320:	d4c60613          	addi	a2,a2,-692 # ffffffffc0202068 <buddy_pmm_manager+0x190>
ffffffffc0201324:	85a6                	mv	a1,s1
ffffffffc0201326:	854a                	mv	a0,s2
ffffffffc0201328:	0ce000ef          	jal	ra,ffffffffc02013f6 <printfmt>
ffffffffc020132c:	b34d                	j	ffffffffc02010ce <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020132e:	00001617          	auipc	a2,0x1
ffffffffc0201332:	d2a60613          	addi	a2,a2,-726 # ffffffffc0202058 <buddy_pmm_manager+0x180>
ffffffffc0201336:	85a6                	mv	a1,s1
ffffffffc0201338:	854a                	mv	a0,s2
ffffffffc020133a:	0bc000ef          	jal	ra,ffffffffc02013f6 <printfmt>
ffffffffc020133e:	bb41                	j	ffffffffc02010ce <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201340:	00001417          	auipc	s0,0x1
ffffffffc0201344:	d1040413          	addi	s0,s0,-752 # ffffffffc0202050 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201348:	85e2                	mv	a1,s8
ffffffffc020134a:	8522                	mv	a0,s0
ffffffffc020134c:	e43e                	sd	a5,8(sp)
ffffffffc020134e:	1e6000ef          	jal	ra,ffffffffc0201534 <strnlen>
ffffffffc0201352:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201356:	01b05b63          	blez	s11,ffffffffc020136c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020135a:	67a2                	ld	a5,8(sp)
ffffffffc020135c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201360:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201362:	85a6                	mv	a1,s1
ffffffffc0201364:	8552                	mv	a0,s4
ffffffffc0201366:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201368:	fe0d9ce3          	bnez	s11,ffffffffc0201360 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020136c:	00044783          	lbu	a5,0(s0)
ffffffffc0201370:	00140a13          	addi	s4,s0,1
ffffffffc0201374:	0007851b          	sext.w	a0,a5
ffffffffc0201378:	d3a5                	beqz	a5,ffffffffc02012d8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020137a:	05e00413          	li	s0,94
ffffffffc020137e:	bf39                	j	ffffffffc020129c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201380:	000a2403          	lw	s0,0(s4)
ffffffffc0201384:	b7ad                	j	ffffffffc02012ee <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201386:	000a6603          	lwu	a2,0(s4)
ffffffffc020138a:	46a1                	li	a3,8
ffffffffc020138c:	8a2e                	mv	s4,a1
ffffffffc020138e:	bdb1                	j	ffffffffc02011ea <vprintfmt+0x156>
ffffffffc0201390:	000a6603          	lwu	a2,0(s4)
ffffffffc0201394:	46a9                	li	a3,10
ffffffffc0201396:	8a2e                	mv	s4,a1
ffffffffc0201398:	bd89                	j	ffffffffc02011ea <vprintfmt+0x156>
ffffffffc020139a:	000a6603          	lwu	a2,0(s4)
ffffffffc020139e:	46c1                	li	a3,16
ffffffffc02013a0:	8a2e                	mv	s4,a1
ffffffffc02013a2:	b5a1                	j	ffffffffc02011ea <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02013a4:	9902                	jalr	s2
ffffffffc02013a6:	bf09                	j	ffffffffc02012b8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02013a8:	85a6                	mv	a1,s1
ffffffffc02013aa:	02d00513          	li	a0,45
ffffffffc02013ae:	e03e                	sd	a5,0(sp)
ffffffffc02013b0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02013b2:	6782                	ld	a5,0(sp)
ffffffffc02013b4:	8a66                	mv	s4,s9
ffffffffc02013b6:	40800633          	neg	a2,s0
ffffffffc02013ba:	46a9                	li	a3,10
ffffffffc02013bc:	b53d                	j	ffffffffc02011ea <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02013be:	03b05163          	blez	s11,ffffffffc02013e0 <vprintfmt+0x34c>
ffffffffc02013c2:	02d00693          	li	a3,45
ffffffffc02013c6:	f6d79de3          	bne	a5,a3,ffffffffc0201340 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02013ca:	00001417          	auipc	s0,0x1
ffffffffc02013ce:	c8640413          	addi	s0,s0,-890 # ffffffffc0202050 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013d2:	02800793          	li	a5,40
ffffffffc02013d6:	02800513          	li	a0,40
ffffffffc02013da:	00140a13          	addi	s4,s0,1
ffffffffc02013de:	bd6d                	j	ffffffffc0201298 <vprintfmt+0x204>
ffffffffc02013e0:	00001a17          	auipc	s4,0x1
ffffffffc02013e4:	c71a0a13          	addi	s4,s4,-911 # ffffffffc0202051 <buddy_pmm_manager+0x179>
ffffffffc02013e8:	02800513          	li	a0,40
ffffffffc02013ec:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013f0:	05e00413          	li	s0,94
ffffffffc02013f4:	b565                	j	ffffffffc020129c <vprintfmt+0x208>

ffffffffc02013f6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013f6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013f8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013fc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013fe:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201400:	ec06                	sd	ra,24(sp)
ffffffffc0201402:	f83a                	sd	a4,48(sp)
ffffffffc0201404:	fc3e                	sd	a5,56(sp)
ffffffffc0201406:	e0c2                	sd	a6,64(sp)
ffffffffc0201408:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020140a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020140c:	c89ff0ef          	jal	ra,ffffffffc0201094 <vprintfmt>
}
ffffffffc0201410:	60e2                	ld	ra,24(sp)
ffffffffc0201412:	6161                	addi	sp,sp,80
ffffffffc0201414:	8082                	ret

ffffffffc0201416 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201416:	715d                	addi	sp,sp,-80
ffffffffc0201418:	e486                	sd	ra,72(sp)
ffffffffc020141a:	e0a6                	sd	s1,64(sp)
ffffffffc020141c:	fc4a                	sd	s2,56(sp)
ffffffffc020141e:	f84e                	sd	s3,48(sp)
ffffffffc0201420:	f452                	sd	s4,40(sp)
ffffffffc0201422:	f056                	sd	s5,32(sp)
ffffffffc0201424:	ec5a                	sd	s6,24(sp)
ffffffffc0201426:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201428:	c901                	beqz	a0,ffffffffc0201438 <readline+0x22>
ffffffffc020142a:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020142c:	00001517          	auipc	a0,0x1
ffffffffc0201430:	c3c50513          	addi	a0,a0,-964 # ffffffffc0202068 <buddy_pmm_manager+0x190>
ffffffffc0201434:	c7ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201438:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020143a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020143c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020143e:	4aa9                	li	s5,10
ffffffffc0201440:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201442:	00005b97          	auipc	s7,0x5
ffffffffc0201446:	beeb8b93          	addi	s7,s7,-1042 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020144a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020144e:	cddfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201452:	00054a63          	bltz	a0,ffffffffc0201466 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201456:	00a95a63          	bge	s2,a0,ffffffffc020146a <readline+0x54>
ffffffffc020145a:	029a5263          	bge	s4,s1,ffffffffc020147e <readline+0x68>
        c = getchar();
ffffffffc020145e:	ccdfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201462:	fe055ae3          	bgez	a0,ffffffffc0201456 <readline+0x40>
            return NULL;
ffffffffc0201466:	4501                	li	a0,0
ffffffffc0201468:	a091                	j	ffffffffc02014ac <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020146a:	03351463          	bne	a0,s3,ffffffffc0201492 <readline+0x7c>
ffffffffc020146e:	e8a9                	bnez	s1,ffffffffc02014c0 <readline+0xaa>
        c = getchar();
ffffffffc0201470:	cbbfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201474:	fe0549e3          	bltz	a0,ffffffffc0201466 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201478:	fea959e3          	bge	s2,a0,ffffffffc020146a <readline+0x54>
ffffffffc020147c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020147e:	e42a                	sd	a0,8(sp)
ffffffffc0201480:	c69fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201484:	6522                	ld	a0,8(sp)
ffffffffc0201486:	009b87b3          	add	a5,s7,s1
ffffffffc020148a:	2485                	addiw	s1,s1,1
ffffffffc020148c:	00a78023          	sb	a0,0(a5)
ffffffffc0201490:	bf7d                	j	ffffffffc020144e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201492:	01550463          	beq	a0,s5,ffffffffc020149a <readline+0x84>
ffffffffc0201496:	fb651ce3          	bne	a0,s6,ffffffffc020144e <readline+0x38>
            cputchar(c);
ffffffffc020149a:	c4ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020149e:	00005517          	auipc	a0,0x5
ffffffffc02014a2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0206030 <buf>
ffffffffc02014a6:	94aa                	add	s1,s1,a0
ffffffffc02014a8:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02014ac:	60a6                	ld	ra,72(sp)
ffffffffc02014ae:	6486                	ld	s1,64(sp)
ffffffffc02014b0:	7962                	ld	s2,56(sp)
ffffffffc02014b2:	79c2                	ld	s3,48(sp)
ffffffffc02014b4:	7a22                	ld	s4,40(sp)
ffffffffc02014b6:	7a82                	ld	s5,32(sp)
ffffffffc02014b8:	6b62                	ld	s6,24(sp)
ffffffffc02014ba:	6bc2                	ld	s7,16(sp)
ffffffffc02014bc:	6161                	addi	sp,sp,80
ffffffffc02014be:	8082                	ret
            cputchar(c);
ffffffffc02014c0:	4521                	li	a0,8
ffffffffc02014c2:	c27fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02014c6:	34fd                	addiw	s1,s1,-1
ffffffffc02014c8:	b759                	j	ffffffffc020144e <readline+0x38>

ffffffffc02014ca <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02014ca:	4781                	li	a5,0
ffffffffc02014cc:	00005717          	auipc	a4,0x5
ffffffffc02014d0:	b3c73703          	ld	a4,-1220(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02014d4:	88ba                	mv	a7,a4
ffffffffc02014d6:	852a                	mv	a0,a0
ffffffffc02014d8:	85be                	mv	a1,a5
ffffffffc02014da:	863e                	mv	a2,a5
ffffffffc02014dc:	00000073          	ecall
ffffffffc02014e0:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02014e2:	8082                	ret

ffffffffc02014e4 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02014e4:	4781                	li	a5,0
ffffffffc02014e6:	00005717          	auipc	a4,0x5
ffffffffc02014ea:	f9273703          	ld	a4,-110(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc02014ee:	88ba                	mv	a7,a4
ffffffffc02014f0:	852a                	mv	a0,a0
ffffffffc02014f2:	85be                	mv	a1,a5
ffffffffc02014f4:	863e                	mv	a2,a5
ffffffffc02014f6:	00000073          	ecall
ffffffffc02014fa:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02014fc:	8082                	ret

ffffffffc02014fe <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02014fe:	4501                	li	a0,0
ffffffffc0201500:	00005797          	auipc	a5,0x5
ffffffffc0201504:	b007b783          	ld	a5,-1280(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201508:	88be                	mv	a7,a5
ffffffffc020150a:	852a                	mv	a0,a0
ffffffffc020150c:	85aa                	mv	a1,a0
ffffffffc020150e:	862a                	mv	a2,a0
ffffffffc0201510:	00000073          	ecall
ffffffffc0201514:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201516:	2501                	sext.w	a0,a0
ffffffffc0201518:	8082                	ret

ffffffffc020151a <sbi_shutdown>:
    __asm__ volatile (
ffffffffc020151a:	4781                	li	a5,0
ffffffffc020151c:	00005717          	auipc	a4,0x5
ffffffffc0201520:	af473703          	ld	a4,-1292(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201524:	88ba                	mv	a7,a4
ffffffffc0201526:	853e                	mv	a0,a5
ffffffffc0201528:	85be                	mv	a1,a5
ffffffffc020152a:	863e                	mv	a2,a5
ffffffffc020152c:	00000073          	ecall
ffffffffc0201530:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201532:	8082                	ret

ffffffffc0201534 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201534:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201536:	e589                	bnez	a1,ffffffffc0201540 <strnlen+0xc>
ffffffffc0201538:	a811                	j	ffffffffc020154c <strnlen+0x18>
        cnt ++;
ffffffffc020153a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020153c:	00f58863          	beq	a1,a5,ffffffffc020154c <strnlen+0x18>
ffffffffc0201540:	00f50733          	add	a4,a0,a5
ffffffffc0201544:	00074703          	lbu	a4,0(a4)
ffffffffc0201548:	fb6d                	bnez	a4,ffffffffc020153a <strnlen+0x6>
ffffffffc020154a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020154c:	852e                	mv	a0,a1
ffffffffc020154e:	8082                	ret

ffffffffc0201550 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201550:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201554:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201558:	cb89                	beqz	a5,ffffffffc020156a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020155a:	0505                	addi	a0,a0,1
ffffffffc020155c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020155e:	fee789e3          	beq	a5,a4,ffffffffc0201550 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201562:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201566:	9d19                	subw	a0,a0,a4
ffffffffc0201568:	8082                	ret
ffffffffc020156a:	4501                	li	a0,0
ffffffffc020156c:	bfed                	j	ffffffffc0201566 <strcmp+0x16>

ffffffffc020156e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020156e:	00054783          	lbu	a5,0(a0)
ffffffffc0201572:	c799                	beqz	a5,ffffffffc0201580 <strchr+0x12>
        if (*s == c) {
ffffffffc0201574:	00f58763          	beq	a1,a5,ffffffffc0201582 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201578:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020157c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020157e:	fbfd                	bnez	a5,ffffffffc0201574 <strchr+0x6>
    }
    return NULL;
ffffffffc0201580:	4501                	li	a0,0
}
ffffffffc0201582:	8082                	ret

ffffffffc0201584 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201584:	ca01                	beqz	a2,ffffffffc0201594 <memset+0x10>
ffffffffc0201586:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201588:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020158a:	0785                	addi	a5,a5,1
ffffffffc020158c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201590:	fec79de3          	bne	a5,a2,ffffffffc020158a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201594:	8082                	ret
