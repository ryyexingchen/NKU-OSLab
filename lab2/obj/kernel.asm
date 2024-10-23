
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
ffffffffc020004a:	524010ef          	jal	ra,ffffffffc020156e <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	52e50513          	addi	a0,a0,1326 # ffffffffc0201580 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	619000ef          	jal	ra,ffffffffc0200e7e <pmm_init>

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
ffffffffc02000a6:	7d9000ef          	jal	ra,ffffffffc020107e <vprintfmt>
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
ffffffffc02000dc:	7a3000ef          	jal	ra,ffffffffc020107e <vprintfmt>
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
ffffffffc0200140:	46450513          	addi	a0,a0,1124 # ffffffffc02015a0 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	46e50513          	addi	a0,a0,1134 # ffffffffc02015c0 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	42258593          	addi	a1,a1,1058 # ffffffffc0201580 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	47a50513          	addi	a0,a0,1146 # ffffffffc02015e0 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	48650513          	addi	a0,a0,1158 # ffffffffc0201600 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2fa58593          	addi	a1,a1,762 # ffffffffc0206480 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	49250513          	addi	a0,a0,1170 # ffffffffc0201620 <etext+0xa0>
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
ffffffffc02001c0:	48450513          	addi	a0,a0,1156 # ffffffffc0201640 <etext+0xc0>
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
ffffffffc02001ce:	4a660613          	addi	a2,a2,1190 # ffffffffc0201670 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	4b250513          	addi	a0,a0,1202 # ffffffffc0201688 <etext+0x108>
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
ffffffffc02001ea:	4ba60613          	addi	a2,a2,1210 # ffffffffc02016a0 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	4d258593          	addi	a1,a1,1234 # ffffffffc02016c0 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	4d250513          	addi	a0,a0,1234 # ffffffffc02016c8 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	4d460613          	addi	a2,a2,1236 # ffffffffc02016d8 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	4f458593          	addi	a1,a1,1268 # ffffffffc0201700 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	4b450513          	addi	a0,a0,1204 # ffffffffc02016c8 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	4f060613          	addi	a2,a2,1264 # ffffffffc0201710 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	50858593          	addi	a1,a1,1288 # ffffffffc0201730 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	49850513          	addi	a0,a0,1176 # ffffffffc02016c8 <etext+0x148>
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
ffffffffc020026e:	4d650513          	addi	a0,a0,1238 # ffffffffc0201740 <etext+0x1c0>
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
ffffffffc0200290:	4dc50513          	addi	a0,a0,1244 # ffffffffc0201768 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	536c0c13          	addi	s8,s8,1334 # ffffffffc02017d8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	4e690913          	addi	s2,s2,1254 # ffffffffc0201790 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	4e648493          	addi	s1,s1,1254 # ffffffffc0201798 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	4e4b0b13          	addi	s6,s6,1252 # ffffffffc02017a0 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	3fca0a13          	addi	s4,s4,1020 # ffffffffc02016c0 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	130010ef          	jal	ra,ffffffffc0201400 <readline>
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
ffffffffc02002ea:	4f2d0d13          	addi	s10,s10,1266 # ffffffffc02017d8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	246010ef          	jal	ra,ffffffffc020153a <strcmp>
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
ffffffffc0200308:	232010ef          	jal	ra,ffffffffc020153a <strcmp>
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
ffffffffc0200346:	212010ef          	jal	ra,ffffffffc0201558 <strchr>
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
ffffffffc0200384:	1d4010ef          	jal	ra,ffffffffc0201558 <strchr>
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
ffffffffc02003a2:	42250513          	addi	a0,a0,1058 # ffffffffc02017c0 <etext+0x240>
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
ffffffffc02003de:	44650513          	addi	a0,a0,1094 # ffffffffc0201820 <commands+0x48>
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
ffffffffc02003f4:	27850513          	addi	a0,a0,632 # ffffffffc0201668 <etext+0xe8>
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
ffffffffc0200420:	0ae010ef          	jal	ra,ffffffffc02014ce <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	41250513          	addi	a0,a0,1042 # ffffffffc0201840 <commands+0x68>
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
ffffffffc0200446:	0880106f          	j	ffffffffc02014ce <sbi_set_timer>

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
ffffffffc0200450:	0640106f          	j	ffffffffc02014b4 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	0940106f          	j	ffffffffc02014e8 <sbi_console_getchar>

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
ffffffffc0200482:	3e250513          	addi	a0,a0,994 # ffffffffc0201860 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	3ea50513          	addi	a0,a0,1002 # ffffffffc0201878 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	3f450513          	addi	a0,a0,1012 # ffffffffc0201890 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	3fe50513          	addi	a0,a0,1022 # ffffffffc02018a8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	40850513          	addi	a0,a0,1032 # ffffffffc02018c0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	41250513          	addi	a0,a0,1042 # ffffffffc02018d8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	41c50513          	addi	a0,a0,1052 # ffffffffc02018f0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	42650513          	addi	a0,a0,1062 # ffffffffc0201908 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	43050513          	addi	a0,a0,1072 # ffffffffc0201920 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	43a50513          	addi	a0,a0,1082 # ffffffffc0201938 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	44450513          	addi	a0,a0,1092 # ffffffffc0201950 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	44e50513          	addi	a0,a0,1102 # ffffffffc0201968 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	45850513          	addi	a0,a0,1112 # ffffffffc0201980 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	46250513          	addi	a0,a0,1122 # ffffffffc0201998 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	46c50513          	addi	a0,a0,1132 # ffffffffc02019b0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	47650513          	addi	a0,a0,1142 # ffffffffc02019c8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	48050513          	addi	a0,a0,1152 # ffffffffc02019e0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	48a50513          	addi	a0,a0,1162 # ffffffffc02019f8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	49450513          	addi	a0,a0,1172 # ffffffffc0201a10 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	49e50513          	addi	a0,a0,1182 # ffffffffc0201a28 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	4a850513          	addi	a0,a0,1192 # ffffffffc0201a40 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	4b250513          	addi	a0,a0,1202 # ffffffffc0201a58 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	4bc50513          	addi	a0,a0,1212 # ffffffffc0201a70 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	4c650513          	addi	a0,a0,1222 # ffffffffc0201a88 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	4d050513          	addi	a0,a0,1232 # ffffffffc0201aa0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	4da50513          	addi	a0,a0,1242 # ffffffffc0201ab8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	4e450513          	addi	a0,a0,1252 # ffffffffc0201ad0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201ae8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	4f850513          	addi	a0,a0,1272 # ffffffffc0201b00 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	50250513          	addi	a0,a0,1282 # ffffffffc0201b18 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	50c50513          	addi	a0,a0,1292 # ffffffffc0201b30 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	51250513          	addi	a0,a0,1298 # ffffffffc0201b48 <commands+0x370>
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
ffffffffc020064e:	51650513          	addi	a0,a0,1302 # ffffffffc0201b60 <commands+0x388>
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
ffffffffc0200666:	51650513          	addi	a0,a0,1302 # ffffffffc0201b78 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	51e50513          	addi	a0,a0,1310 # ffffffffc0201b90 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	52650513          	addi	a0,a0,1318 # ffffffffc0201ba8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	52a50513          	addi	a0,a0,1322 # ffffffffc0201bc0 <commands+0x3e8>
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
ffffffffc02006b4:	5f070713          	addi	a4,a4,1520 # ffffffffc0201ca0 <commands+0x4c8>
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
ffffffffc02006c6:	57650513          	addi	a0,a0,1398 # ffffffffc0201c38 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	54c50513          	addi	a0,a0,1356 # ffffffffc0201c18 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	50250513          	addi	a0,a0,1282 # ffffffffc0201bd8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	57850513          	addi	a0,a0,1400 # ffffffffc0201c58 <commands+0x480>
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
ffffffffc020071a:	56a50513          	addi	a0,a0,1386 # ffffffffc0201c80 <commands+0x4a8>
ffffffffc020071e:	ba51                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	4d850513          	addi	a0,a0,1240 # ffffffffc0201bf8 <commands+0x420>
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
ffffffffc020073e:	53650513          	addi	a0,a0,1334 # ffffffffc0201c70 <commands+0x498>
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
ffffffffc0200758:	5ad0006f          	j	ffffffffc0201504 <sbi_shutdown>

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
ffffffffc0200852:	5ae000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc0200856:	842a                	mv	s0,a0
    B = alloc_pages(35);
ffffffffc0200858:	02300513          	li	a0,35
ffffffffc020085c:	5a4000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc0200860:	89aa                	mv	s3,a0
    C = alloc_pages(257);
ffffffffc0200862:	10100513          	li	a0,257
ffffffffc0200866:	59a000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc020086a:	892a                	mv	s2,a0
    D = alloc_pages(63);
ffffffffc020086c:	03f00513          	li	a0,63
ffffffffc0200870:	590000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc0200874:	84aa                	mv	s1,a0
    cprintf("A分配70，B分配35，C分配257，D分配63\n");
ffffffffc0200876:	00001517          	auipc	a0,0x1
ffffffffc020087a:	45a50513          	addi	a0,a0,1114 # ffffffffc0201cd0 <commands+0x4f8>
ffffffffc020087e:	835ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时A %p\n",A);
ffffffffc0200882:	85a2                	mv	a1,s0
ffffffffc0200884:	00001517          	auipc	a0,0x1
ffffffffc0200888:	47c50513          	addi	a0,a0,1148 # ffffffffc0201d00 <commands+0x528>
ffffffffc020088c:	827ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时B %p\n",B);
ffffffffc0200890:	85ce                	mv	a1,s3
ffffffffc0200892:	00001517          	auipc	a0,0x1
ffffffffc0200896:	47e50513          	addi	a0,a0,1150 # ffffffffc0201d10 <commands+0x538>
ffffffffc020089a:	819ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时C %p\n",C);
ffffffffc020089e:	85ca                	mv	a1,s2
ffffffffc02008a0:	00001517          	auipc	a0,0x1
ffffffffc02008a4:	48050513          	addi	a0,a0,1152 # ffffffffc0201d20 <commands+0x548>
ffffffffc02008a8:	80bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时D %p\n",D);
ffffffffc02008ac:	85a6                	mv	a1,s1
ffffffffc02008ae:	00001517          	auipc	a0,0x1
ffffffffc02008b2:	48250513          	addi	a0,a0,1154 # ffffffffc0201d30 <commands+0x558>
ffffffffc02008b6:	ffcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(B, 35);
ffffffffc02008ba:	02300593          	li	a1,35
ffffffffc02008be:	854e                	mv	a0,s3
ffffffffc02008c0:	57e000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    cprintf("B释放35\n");
ffffffffc02008c4:	00001517          	auipc	a0,0x1
ffffffffc02008c8:	47c50513          	addi	a0,a0,1148 # ffffffffc0201d40 <commands+0x568>
ffffffffc02008cc:	fe6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(D, 63);
ffffffffc02008d0:	03f00593          	li	a1,63
ffffffffc02008d4:	8526                	mv	a0,s1
ffffffffc02008d6:	568000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    cprintf("D释放63\n");
ffffffffc02008da:	00001517          	auipc	a0,0x1
ffffffffc02008de:	47650513          	addi	a0,a0,1142 # ffffffffc0201d50 <commands+0x578>
ffffffffc02008e2:	fd0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时BD应该合并\n");
ffffffffc02008e6:	00001517          	auipc	a0,0x1
ffffffffc02008ea:	47a50513          	addi	a0,a0,1146 # ffffffffc0201d60 <commands+0x588>
ffffffffc02008ee:	fc4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(A, 70);
ffffffffc02008f2:	04600593          	li	a1,70
ffffffffc02008f6:	8522                	mv	a0,s0
ffffffffc02008f8:	546000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    cprintf("A释放70\n");
ffffffffc02008fc:	00001517          	auipc	a0,0x1
ffffffffc0200900:	47c50513          	addi	a0,a0,1148 # ffffffffc0201d78 <commands+0x5a0>
ffffffffc0200904:	faeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时前512个已空，我们再分配511个的A来测试\n");
ffffffffc0200908:	00001517          	auipc	a0,0x1
ffffffffc020090c:	48050513          	addi	a0,a0,1152 # ffffffffc0201d88 <commands+0x5b0>
ffffffffc0200910:	fa2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    A = alloc_pages(511);
ffffffffc0200914:	1ff00513          	li	a0,511
ffffffffc0200918:	4e8000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc020091c:	842a                	mv	s0,a0
    cprintf("A分配511\n");
ffffffffc020091e:	00001517          	auipc	a0,0x1
ffffffffc0200922:	4aa50513          	addi	a0,a0,1194 # ffffffffc0201dc8 <commands+0x5f0>
ffffffffc0200926:	f8cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时A %p\n",A);
ffffffffc020092a:	85a2                	mv	a1,s0
ffffffffc020092c:	00001517          	auipc	a0,0x1
ffffffffc0200930:	3d450513          	addi	a0,a0,980 # ffffffffc0201d00 <commands+0x528>
ffffffffc0200934:	f7eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(A, 511);
ffffffffc0200938:	1ff00593          	li	a1,511
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	500000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    cprintf("A释放511\n");
ffffffffc0200942:	00001517          	auipc	a0,0x1
ffffffffc0200946:	49650513          	addi	a0,a0,1174 # ffffffffc0201dd8 <commands+0x600>
ffffffffc020094a:	f68ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    A = alloc_pages(255);
ffffffffc020094e:	0ff00513          	li	a0,255
ffffffffc0200952:	4ae000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc0200956:	84aa                	mv	s1,a0
    B = alloc_pages(255);
ffffffffc0200958:	0ff00513          	li	a0,255
ffffffffc020095c:	4a4000ef          	jal	ra,ffffffffc0200e00 <alloc_pages>
ffffffffc0200960:	842a                	mv	s0,a0
    cprintf("A分配255，B分配255\n");
ffffffffc0200962:	00001517          	auipc	a0,0x1
ffffffffc0200966:	48650513          	addi	a0,a0,1158 # ffffffffc0201de8 <commands+0x610>
ffffffffc020096a:	f48ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时A %p\n",A);
ffffffffc020096e:	85a6                	mv	a1,s1
ffffffffc0200970:	00001517          	auipc	a0,0x1
ffffffffc0200974:	39050513          	addi	a0,a0,912 # ffffffffc0201d00 <commands+0x528>
ffffffffc0200978:	f3aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("此时B %p\n",B);
ffffffffc020097c:	85a2                	mv	a1,s0
ffffffffc020097e:	00001517          	auipc	a0,0x1
ffffffffc0200982:	39250513          	addi	a0,a0,914 # ffffffffc0201d10 <commands+0x538>
ffffffffc0200986:	f2cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(C, 257);
ffffffffc020098a:	854a                	mv	a0,s2
ffffffffc020098c:	10100593          	li	a1,257
ffffffffc0200990:	4ae000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    free_pages(A, 255);
ffffffffc0200994:	8526                	mv	a0,s1
ffffffffc0200996:	0ff00593          	li	a1,255
ffffffffc020099a:	4a4000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    free_pages(B, 255);  
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	0ff00593          	li	a1,255
ffffffffc02009a4:	49a000ef          	jal	ra,ffffffffc0200e3e <free_pages>
    cprintf("全部释放\n");
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	46050513          	addi	a0,a0,1120 # ffffffffc0201e08 <commands+0x630>
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
ffffffffc02009c2:	45a50513          	addi	a0,a0,1114 # ffffffffc0201e18 <commands+0x640>
}
ffffffffc02009c6:	6145                	addi	sp,sp,48
    cprintf("检查完成，没有错误\n");
ffffffffc02009c8:	eeaff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc02009cc <buddy_free_pages>:
{
ffffffffc02009cc:	1141                	addi	sp,sp,-16
ffffffffc02009ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02009d0:	1e058763          	beqz	a1,ffffffffc0200bbe <buddy_free_pages+0x1f2>
    size--;
ffffffffc02009d4:	fff58793          	addi	a5,a1,-1
    while (size >= 1) {
ffffffffc02009d8:	1a078f63          	beqz	a5,ffffffffc0200b96 <buddy_free_pages+0x1ca>
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
ffffffffc02009fe:	1a071063          	bnez	a4,ffffffffc0200b9e <buddy_free_pages+0x1d2>
ffffffffc0200a02:	6798                	ld	a4,8(a5)
ffffffffc0200a04:	8b09                	andi	a4,a4,2
ffffffffc0200a06:	18071c63          	bnez	a4,ffffffffc0200b9e <buddy_free_pages+0x1d2>
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
ffffffffc0200a2a:	00005897          	auipc	a7,0x5
ffffffffc0200a2e:	5ee88893          	addi	a7,a7,1518 # ffffffffc0206018 <free_area>
ffffffffc0200a32:	0108a603          	lw	a2,16(a7)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200a36:	0088b783          	ld	a5,8(a7)
        list_add(&free_list, &(base->page_link));
ffffffffc0200a3a:	01850693          	addi	a3,a0,24
    nr_free += n;
ffffffffc0200a3e:	9f31                	addw	a4,a4,a2
ffffffffc0200a40:	00e8a823          	sw	a4,16(a7)
    if (list_empty(&free_list)) {
ffffffffc0200a44:	13178f63          	beq	a5,a7,ffffffffc0200b82 <buddy_free_pages+0x1b6>
            struct Page* page = le2page(le, page_link);
ffffffffc0200a48:	fe878713          	addi	a4,a5,-24
ffffffffc0200a4c:	0008b583          	ld	a1,0(a7)
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
ffffffffc0200a58:	11170263          	beq	a4,a7,ffffffffc0200b5c <buddy_free_pages+0x190>
    for (; p != base + n; p ++) {
ffffffffc0200a5c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200a5e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200a62:	fee57ae3          	bgeu	a0,a4,ffffffffc0200a56 <buddy_free_pages+0x8a>
ffffffffc0200a66:	c219                	beqz	a2,ffffffffc0200a6c <buddy_free_pages+0xa0>
ffffffffc0200a68:	00b8b023          	sd	a1,0(a7)
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
ffffffffc0200a72:	0088bf03          	ld	t5,8(a7)
    elm->next = next;
ffffffffc0200a76:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200a78:	ed18                	sd	a4,24(a0)
        if(((base-q)/base->property)%2==1)
ffffffffc0200a7a:	4910                	lw	a2,16(a0)
    struct Page *q=le2page(list_next(&free_list),page_link);
ffffffffc0200a7c:	1f21                	addi	t5,t5,-24
    while(flag==1)
ffffffffc0200a7e:	41e50833          	sub	a6,a0,t5
ffffffffc0200a82:	02061593          	slli	a1,a2,0x20
ffffffffc0200a86:	00001e17          	auipc	t3,0x1
ffffffffc0200a8a:	7e2e3e03          	ld	t3,2018(t3) # ffffffffc0202268 <error_string+0x38>
ffffffffc0200a8e:	9181                	srli	a1,a1,0x20
        if(((base-q)/base->property)%2==1)
ffffffffc0200a90:	4305                	li	t1,1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a92:	5ef5                	li	t4,-3
ffffffffc0200a94:	40385793          	srai	a5,a6,0x3
ffffffffc0200a98:	03c787b3          	mul	a5,a5,t3
ffffffffc0200a9c:	02b7c7b3          	div	a5,a5,a1
ffffffffc0200aa0:	03f7d693          	srli	a3,a5,0x3f
ffffffffc0200aa4:	00d78733          	add	a4,a5,a3
ffffffffc0200aa8:	8b05                	andi	a4,a4,1
ffffffffc0200aaa:	8f15                	sub	a4,a4,a3
ffffffffc0200aac:	06670163          	beq	a4,t1,ffffffffc0200b0e <buddy_free_pages+0x142>
        else if(((base-q)/base->property)%2==0)
ffffffffc0200ab0:	8b85                	andi	a5,a5,1
ffffffffc0200ab2:	f3ed                	bnez	a5,ffffffffc0200a94 <buddy_free_pages+0xc8>
    return listelm->next;
ffffffffc0200ab4:	711c                	ld	a5,32(a0)
            if (le != &free_list) {
ffffffffc0200ab6:	fd178fe3          	beq	a5,a7,ffffffffc0200a94 <buddy_free_pages+0xc8>
                if (base + base->property == p && p->property==base->property) {
ffffffffc0200aba:	00259713          	slli	a4,a1,0x2
ffffffffc0200abe:	95ba                	add	a1,a1,a4
ffffffffc0200ac0:	058e                	slli	a1,a1,0x3
ffffffffc0200ac2:	95aa                	add	a1,a1,a0
                p = le2page(le, page_link);
ffffffffc0200ac4:	fe878713          	addi	a4,a5,-24
                if (base + base->property == p && p->property==base->property) {
ffffffffc0200ac8:	0ae59563          	bne	a1,a4,ffffffffc0200b72 <buddy_free_pages+0x1a6>
ffffffffc0200acc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ad0:	0ac71163          	bne	a4,a2,ffffffffc0200b72 <buddy_free_pages+0x1a6>
                    base->property += p->property;
ffffffffc0200ad4:	0016161b          	slliw	a2,a2,0x1
ffffffffc0200ad8:	c910                	sw	a2,16(a0)
ffffffffc0200ada:	ff078713          	addi	a4,a5,-16
ffffffffc0200ade:	61d7302f          	amoand.d	zero,t4,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ae2:	6398                	ld	a4,0(a5)
ffffffffc0200ae4:	679c                	ld	a5,8(a5)
        if(((base-q)/base->property)%2==1)
ffffffffc0200ae6:	4910                	lw	a2,16(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200ae8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200aea:	e398                	sd	a4,0(a5)
ffffffffc0200aec:	40385793          	srai	a5,a6,0x3
ffffffffc0200af0:	03c787b3          	mul	a5,a5,t3
ffffffffc0200af4:	02061593          	slli	a1,a2,0x20
ffffffffc0200af8:	9181                	srli	a1,a1,0x20
ffffffffc0200afa:	02b7c7b3          	div	a5,a5,a1
ffffffffc0200afe:	03f7d693          	srli	a3,a5,0x3f
ffffffffc0200b02:	00d78733          	add	a4,a5,a3
ffffffffc0200b06:	8b05                	andi	a4,a4,1
ffffffffc0200b08:	8f15                	sub	a4,a4,a3
ffffffffc0200b0a:	fa6713e3          	bne	a4,t1,ffffffffc0200ab0 <buddy_free_pages+0xe4>
    return listelm->prev;
ffffffffc0200b0e:	6d1c                	ld	a5,24(a0)
            if (le != &free_list) {
ffffffffc0200b10:	f91782e3          	beq	a5,a7,ffffffffc0200a94 <buddy_free_pages+0xc8>
                if (p + p->property == base && p->property==base->property) {
ffffffffc0200b14:	ff87a583          	lw	a1,-8(a5)
                p = le2page(le, page_link);
ffffffffc0200b18:	fe878813          	addi	a6,a5,-24
                if (p + p->property == base && p->property==base->property) {
ffffffffc0200b1c:	02059693          	slli	a3,a1,0x20
ffffffffc0200b20:	9281                	srli	a3,a3,0x20
ffffffffc0200b22:	00269713          	slli	a4,a3,0x2
ffffffffc0200b26:	9736                	add	a4,a4,a3
ffffffffc0200b28:	070e                	slli	a4,a4,0x3
ffffffffc0200b2a:	9742                	add	a4,a4,a6
ffffffffc0200b2c:	04e51363          	bne	a0,a4,ffffffffc0200b72 <buddy_free_pages+0x1a6>
ffffffffc0200b30:	04c59163          	bne	a1,a2,ffffffffc0200b72 <buddy_free_pages+0x1a6>
                    p->property += base->property;
ffffffffc0200b34:	0016161b          	slliw	a2,a2,0x1
ffffffffc0200b38:	fec7ac23          	sw	a2,-8(a5)
ffffffffc0200b3c:	00850713          	addi	a4,a0,8
ffffffffc0200b40:	61d7302f          	amoand.d	zero,t4,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b44:	7118                	ld	a4,32(a0)
        if(((base-q)/base->property)%2==1)
ffffffffc0200b46:	ff87a603          	lw	a2,-8(a5)
                    base = p;
ffffffffc0200b4a:	8542                	mv	a0,a6
    prev->next = next;
ffffffffc0200b4c:	e798                	sd	a4,8(a5)
    next->prev = prev;
ffffffffc0200b4e:	02061593          	slli	a1,a2,0x20
ffffffffc0200b52:	e31c                	sd	a5,0(a4)
ffffffffc0200b54:	41e80833          	sub	a6,a6,t5
ffffffffc0200b58:	9181                	srli	a1,a1,0x20
ffffffffc0200b5a:	bf2d                	j	ffffffffc0200a94 <buddy_free_pages+0xc8>
    prev->next = next->prev = elm;
ffffffffc0200b5c:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0200b5e:	03153023          	sd	a7,32(a0)
    return listelm->next;
ffffffffc0200b62:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200b64:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200b66:	01170963          	beq	a4,a7,ffffffffc0200b78 <buddy_free_pages+0x1ac>
    prev->next = next->prev = elm;
ffffffffc0200b6a:	85b6                	mv	a1,a3
ffffffffc0200b6c:	4605                	li	a2,1
    for (; p != base + n; p ++) {
ffffffffc0200b6e:	87ba                	mv	a5,a4
ffffffffc0200b70:	b5fd                	j	ffffffffc0200a5e <buddy_free_pages+0x92>
}
ffffffffc0200b72:	60a2                	ld	ra,8(sp)
ffffffffc0200b74:	0141                	addi	sp,sp,16
ffffffffc0200b76:	8082                	ret
    return listelm->next;
ffffffffc0200b78:	0088bf03          	ld	t5,8(a7)
ffffffffc0200b7c:	00d8b023          	sd	a3,0(a7)
ffffffffc0200b80:	bded                	j	ffffffffc0200a7a <buddy_free_pages+0xae>
    prev->next = next->prev = elm;
ffffffffc0200b82:	00d8b023          	sd	a3,0(a7)
ffffffffc0200b86:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0200b8a:	03153023          	sd	a7,32(a0)
    elm->prev = prev;
ffffffffc0200b8e:	01153c23          	sd	a7,24(a0)
}
ffffffffc0200b92:	8f36                	mv	t5,a3
ffffffffc0200b94:	b5dd                	j	ffffffffc0200a7a <buddy_free_pages+0xae>
    while (size >= 1) {
ffffffffc0200b96:	4605                	li	a2,1
ffffffffc0200b98:	02850693          	addi	a3,a0,40
ffffffffc0200b9c:	bdb1                	j	ffffffffc02009f8 <buddy_free_pages+0x2c>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200b9e:	00001697          	auipc	a3,0x1
ffffffffc0200ba2:	2d268693          	addi	a3,a3,722 # ffffffffc0201e70 <commands+0x698>
ffffffffc0200ba6:	00001617          	auipc	a2,0x1
ffffffffc0200baa:	29a60613          	addi	a2,a2,666 # ffffffffc0201e40 <commands+0x668>
ffffffffc0200bae:	07800593          	li	a1,120
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	2a650513          	addi	a0,a0,678 # ffffffffc0201e58 <commands+0x680>
ffffffffc0200bba:	ff2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200bbe:	00001697          	auipc	a3,0x1
ffffffffc0200bc2:	27a68693          	addi	a3,a3,634 # ffffffffc0201e38 <commands+0x660>
ffffffffc0200bc6:	00001617          	auipc	a2,0x1
ffffffffc0200bca:	27a60613          	addi	a2,a2,634 # ffffffffc0201e40 <commands+0x668>
ffffffffc0200bce:	07400593          	li	a1,116
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	28650513          	addi	a0,a0,646 # ffffffffc0201e58 <commands+0x680>
ffffffffc0200bda:	fd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bde <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200bde:	c965                	beqz	a0,ffffffffc0200cce <buddy_alloc_pages+0xf0>
    size--;
ffffffffc0200be0:	157d                	addi	a0,a0,-1
    while (size >= 1) {
ffffffffc0200be2:	c565                	beqz	a0,ffffffffc0200cca <buddy_alloc_pages+0xec>
    unsigned i = 0;
ffffffffc0200be4:	4781                	li	a5,0
        size >>= 1; 
ffffffffc0200be6:	8105                	srli	a0,a0,0x1
        i++;
ffffffffc0200be8:	2785                	addiw	a5,a5,1
    while (size >= 1) {
ffffffffc0200bea:	fd75                	bnez	a0,ffffffffc0200be6 <buddy_alloc_pages+0x8>
    return 1 << i; 
ffffffffc0200bec:	4605                	li	a2,1
ffffffffc0200bee:	00f6163b          	sllw	a2,a2,a5
    if (u > nr_free) {
ffffffffc0200bf2:	00005317          	auipc	t1,0x5
ffffffffc0200bf6:	42630313          	addi	t1,t1,1062 # ffffffffc0206018 <free_area>
ffffffffc0200bfa:	01032803          	lw	a6,16(t1)
ffffffffc0200bfe:	02081793          	slli	a5,a6,0x20
ffffffffc0200c02:	9381                	srli	a5,a5,0x20
ffffffffc0200c04:	0cc7e163          	bltu	a5,a2,ffffffffc0200cc6 <buddy_alloc_pages+0xe8>
    return listelm->next;
ffffffffc0200c08:	00833783          	ld	a5,8(t1)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c0c:	0a678d63          	beq	a5,t1,ffffffffc0200cc6 <buddy_alloc_pages+0xe8>
    size_t min_size=1e9;
ffffffffc0200c10:	3b9ad6b7          	lui	a3,0x3b9ad
ffffffffc0200c14:	a0068693          	addi	a3,a3,-1536 # 3b9aca00 <kern_entry-0xffffffff84853600>
    struct Page *page = NULL;
ffffffffc0200c18:	4501                	li	a0,0
        if (p->property >= u&&min_size>p->property) {
ffffffffc0200c1a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200c1e:	00c76763          	bltu	a4,a2,ffffffffc0200c2c <buddy_alloc_pages+0x4e>
ffffffffc0200c22:	00d77563          	bgeu	a4,a3,ffffffffc0200c2c <buddy_alloc_pages+0x4e>
        struct Page *p = le2page(le, page_link);
ffffffffc0200c26:	fe878513          	addi	a0,a5,-24
ffffffffc0200c2a:	86ba                	mv	a3,a4
ffffffffc0200c2c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c2e:	fe6796e3          	bne	a5,t1,ffffffffc0200c1a <buddy_alloc_pages+0x3c>
    if (page != NULL) 
ffffffffc0200c32:	c959                	beqz	a0,ffffffffc0200cc8 <buddy_alloc_pages+0xea>
        while(page->property>=2*u)
ffffffffc0200c34:	4914                	lw	a3,16(a0)
ffffffffc0200c36:	00161593          	slli	a1,a2,0x1
    return listelm->prev;
ffffffffc0200c3a:	6d18                	ld	a4,24(a0)
ffffffffc0200c3c:	02069793          	slli	a5,a3,0x20
ffffffffc0200c40:	9381                	srli	a5,a5,0x20
    return listelm->next;
ffffffffc0200c42:	7110                	ld	a2,32(a0)
        ClearPageProperty(page);
ffffffffc0200c44:	00850e13          	addi	t3,a0,8
        while(page->property>=2*u)
ffffffffc0200c48:	06b7e563          	bltu	a5,a1,ffffffffc0200cb2 <buddy_alloc_pages+0xd4>
            list_add_before(next, &(q->page_link));
ffffffffc0200c4c:	01850f13          	addi	t5,a0,24
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c50:	4e89                	li	t4,2
            struct Page *p = page + page->property/2;
ffffffffc0200c52:	0016d81b          	srliw	a6,a3,0x1
ffffffffc0200c56:	00281793          	slli	a5,a6,0x2
ffffffffc0200c5a:	97c2                	add	a5,a5,a6
    prev->next = next;
ffffffffc0200c5c:	e710                	sd	a2,8(a4)
ffffffffc0200c5e:	078e                	slli	a5,a5,0x3
    next->prev = prev;
ffffffffc0200c60:	e218                	sd	a4,0(a2)
ffffffffc0200c62:	97aa                	add	a5,a5,a0
ffffffffc0200c64:	0016d69b          	srliw	a3,a3,0x1
            p->property=page->property/2;
ffffffffc0200c68:	cb94                	sw	a3,16(a5)
            q->property=page->property/2;
ffffffffc0200c6a:	4914                	lw	a3,16(a0)
ffffffffc0200c6c:	0016d69b          	srliw	a3,a3,0x1
ffffffffc0200c70:	c914                	sw	a3,16(a0)
ffffffffc0200c72:	00878693          	addi	a3,a5,8
ffffffffc0200c76:	41d6b02f          	amoor.d	zero,t4,(a3)
ffffffffc0200c7a:	41de302f          	amoor.d	zero,t4,(t3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c7e:	00873803          	ld	a6,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200c82:	01878893          	addi	a7,a5,24
        while(page->property>=2*u)
ffffffffc0200c86:	4914                	lw	a3,16(a0)
    prev->next = next->prev = elm;
ffffffffc0200c88:	01183023          	sd	a7,0(a6)
ffffffffc0200c8c:	01173423          	sd	a7,8(a4)
    elm->prev = prev;
ffffffffc0200c90:	ef98                	sd	a4,24(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200c92:	6218                	ld	a4,0(a2)
    elm->next = next;
ffffffffc0200c94:	0307b023          	sd	a6,32(a5)
    prev->next = next->prev = elm;
ffffffffc0200c98:	01e63023          	sd	t5,0(a2)
ffffffffc0200c9c:	01e73423          	sd	t5,8(a4)
ffffffffc0200ca0:	02069793          	slli	a5,a3,0x20
    elm->next = next;
ffffffffc0200ca4:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0200ca6:	ed18                	sd	a4,24(a0)
ffffffffc0200ca8:	9381                	srli	a5,a5,0x20
ffffffffc0200caa:	fab7f4e3          	bgeu	a5,a1,ffffffffc0200c52 <buddy_alloc_pages+0x74>
        nr_free -= page->property;
ffffffffc0200cae:	01032803          	lw	a6,16(t1)
    prev->next = next;
ffffffffc0200cb2:	e710                	sd	a2,8(a4)
    next->prev = prev;
ffffffffc0200cb4:	e218                	sd	a4,0(a2)
ffffffffc0200cb6:	40d806bb          	subw	a3,a6,a3
ffffffffc0200cba:	00d32823          	sw	a3,16(t1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200cbe:	57f5                	li	a5,-3
ffffffffc0200cc0:	60fe302f          	amoand.d	zero,a5,(t3)
}
ffffffffc0200cc4:	8082                	ret
        return NULL;
ffffffffc0200cc6:	4501                	li	a0,0
}
ffffffffc0200cc8:	8082                	ret
    while (size >= 1) {
ffffffffc0200cca:	4605                	li	a2,1
ffffffffc0200ccc:	b71d                	j	ffffffffc0200bf2 <buddy_alloc_pages+0x14>
{
ffffffffc0200cce:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200cd0:	00001697          	auipc	a3,0x1
ffffffffc0200cd4:	16868693          	addi	a3,a3,360 # ffffffffc0201e38 <commands+0x660>
ffffffffc0200cd8:	00001617          	auipc	a2,0x1
ffffffffc0200cdc:	16860613          	addi	a2,a2,360 # ffffffffc0201e40 <commands+0x668>
ffffffffc0200ce0:	04a00593          	li	a1,74
ffffffffc0200ce4:	00001517          	auipc	a0,0x1
ffffffffc0200ce8:	17450513          	addi	a0,a0,372 # ffffffffc0201e58 <commands+0x680>
{
ffffffffc0200cec:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cee:	ebeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cf2 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200cf2:	1141                	addi	sp,sp,-16
ffffffffc0200cf4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cf6:	c5f5                	beqz	a1,ffffffffc0200de2 <buddy_init_memmap+0xf0>
    size--;
ffffffffc0200cf8:	fff58793          	addi	a5,a1,-1
    while (size >= 1) {
ffffffffc0200cfc:	c3e9                	beqz	a5,ffffffffc0200dbe <buddy_init_memmap+0xcc>
    unsigned i = 0;
ffffffffc0200cfe:	4701                	li	a4,0
        size >>= 1; 
ffffffffc0200d00:	8385                	srli	a5,a5,0x1
        i++;
ffffffffc0200d02:	2705                	addiw	a4,a4,1
    while (size >= 1) {
ffffffffc0200d04:	fff5                	bnez	a5,ffffffffc0200d00 <buddy_init_memmap+0xe>
    return 1 << i; 
ffffffffc0200d06:	4605                	li	a2,1
ffffffffc0200d08:	00e6173b          	sllw	a4,a2,a4
    n=fixsize(n)/2;
ffffffffc0200d0c:	00175613          	srli	a2,a4,0x1
    for (; p != base + n; p ++) {
ffffffffc0200d10:	00261693          	slli	a3,a2,0x2
ffffffffc0200d14:	96b2                	add	a3,a3,a2
ffffffffc0200d16:	068e                	slli	a3,a3,0x3
ffffffffc0200d18:	96aa                	add	a3,a3,a0
ffffffffc0200d1a:	02d50063          	beq	a0,a3,ffffffffc0200d3a <buddy_init_memmap+0x48>
ffffffffc0200d1e:	87aa                	mv	a5,a0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d20:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200d22:	8b05                	andi	a4,a4,1
ffffffffc0200d24:	cf59                	beqz	a4,ffffffffc0200dc2 <buddy_init_memmap+0xd0>
        p->flags = p->property = 0;
ffffffffc0200d26:	0007a823          	sw	zero,16(a5)
ffffffffc0200d2a:	0007b423          	sd	zero,8(a5)
ffffffffc0200d2e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200d32:	02878793          	addi	a5,a5,40
ffffffffc0200d36:	fed795e3          	bne	a5,a3,ffffffffc0200d20 <buddy_init_memmap+0x2e>
    base->property = n;
ffffffffc0200d3a:	2601                	sext.w	a2,a2
ffffffffc0200d3c:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d3e:	4789                	li	a5,2
ffffffffc0200d40:	00850713          	addi	a4,a0,8
ffffffffc0200d44:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0200d48:	00005697          	auipc	a3,0x5
ffffffffc0200d4c:	2d068693          	addi	a3,a3,720 # ffffffffc0206018 <free_area>
ffffffffc0200d50:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200d52:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200d54:	01850593          	addi	a1,a0,24
    nr_free += n;
ffffffffc0200d58:	9e39                	addw	a2,a2,a4
ffffffffc0200d5a:	ca90                	sw	a2,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200d5c:	04d78a63          	beq	a5,a3,ffffffffc0200db0 <buddy_init_memmap+0xbe>
            struct Page* page = le2page(le, page_link);
ffffffffc0200d60:	fe878713          	addi	a4,a5,-24
ffffffffc0200d64:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200d68:	4601                	li	a2,0
            if (base < page) {
ffffffffc0200d6a:	00e56a63          	bltu	a0,a4,ffffffffc0200d7e <buddy_init_memmap+0x8c>
    return listelm->next;
ffffffffc0200d6e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200d70:	02d70263          	beq	a4,a3,ffffffffc0200d94 <buddy_init_memmap+0xa2>
    while (size >= 1) {
ffffffffc0200d74:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200d76:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200d7a:	fee57ae3          	bgeu	a0,a4,ffffffffc0200d6e <buddy_init_memmap+0x7c>
ffffffffc0200d7e:	c219                	beqz	a2,ffffffffc0200d84 <buddy_init_memmap+0x92>
ffffffffc0200d80:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d84:	6398                	ld	a4,0(a5)
}
ffffffffc0200d86:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200d88:	e38c                	sd	a1,0(a5)
ffffffffc0200d8a:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200d8c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200d8e:	ed18                	sd	a4,24(a0)
ffffffffc0200d90:	0141                	addi	sp,sp,16
ffffffffc0200d92:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200d94:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200d96:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200d98:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200d9a:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200d9c:	00d70663          	beq	a4,a3,ffffffffc0200da8 <buddy_init_memmap+0xb6>
    prev->next = next->prev = elm;
ffffffffc0200da0:	882e                	mv	a6,a1
ffffffffc0200da2:	4605                	li	a2,1
    while (size >= 1) {
ffffffffc0200da4:	87ba                	mv	a5,a4
ffffffffc0200da6:	bfc1                	j	ffffffffc0200d76 <buddy_init_memmap+0x84>
}
ffffffffc0200da8:	60a2                	ld	ra,8(sp)
ffffffffc0200daa:	e28c                	sd	a1,0(a3)
ffffffffc0200dac:	0141                	addi	sp,sp,16
ffffffffc0200dae:	8082                	ret
ffffffffc0200db0:	60a2                	ld	ra,8(sp)
ffffffffc0200db2:	e38c                	sd	a1,0(a5)
ffffffffc0200db4:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200db6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200db8:	ed1c                	sd	a5,24(a0)
ffffffffc0200dba:	0141                	addi	sp,sp,16
ffffffffc0200dbc:	8082                	ret
    while (size >= 1) {
ffffffffc0200dbe:	4601                	li	a2,0
ffffffffc0200dc0:	bfb5                	j	ffffffffc0200d3c <buddy_init_memmap+0x4a>
        assert(PageReserved(p));
ffffffffc0200dc2:	00001697          	auipc	a3,0x1
ffffffffc0200dc6:	0d668693          	addi	a3,a3,214 # ffffffffc0201e98 <commands+0x6c0>
ffffffffc0200dca:	00001617          	auipc	a2,0x1
ffffffffc0200dce:	07660613          	addi	a2,a2,118 # ffffffffc0201e40 <commands+0x668>
ffffffffc0200dd2:	02300593          	li	a1,35
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	08250513          	addi	a0,a0,130 # ffffffffc0201e58 <commands+0x680>
ffffffffc0200dde:	dceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	05668693          	addi	a3,a3,86 # ffffffffc0201e38 <commands+0x660>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	05660613          	addi	a2,a2,86 # ffffffffc0201e40 <commands+0x668>
ffffffffc0200df2:	45fd                	li	a1,31
ffffffffc0200df4:	00001517          	auipc	a0,0x1
ffffffffc0200df8:	06450513          	addi	a0,a0,100 # ffffffffc0201e58 <commands+0x680>
ffffffffc0200dfc:	db0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e00 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e00:	100027f3          	csrr	a5,sstatus
ffffffffc0200e04:	8b89                	andi	a5,a5,2
ffffffffc0200e06:	e799                	bnez	a5,ffffffffc0200e14 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e08:	00005797          	auipc	a5,0x5
ffffffffc0200e0c:	6507b783          	ld	a5,1616(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e10:	6f9c                	ld	a5,24(a5)
ffffffffc0200e12:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200e14:	1141                	addi	sp,sp,-16
ffffffffc0200e16:	e406                	sd	ra,8(sp)
ffffffffc0200e18:	e022                	sd	s0,0(sp)
ffffffffc0200e1a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e1c:	e42ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e20:	00005797          	auipc	a5,0x5
ffffffffc0200e24:	6387b783          	ld	a5,1592(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e28:	6f9c                	ld	a5,24(a5)
ffffffffc0200e2a:	8522                	mv	a0,s0
ffffffffc0200e2c:	9782                	jalr	a5
ffffffffc0200e2e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e30:	e28ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e34:	60a2                	ld	ra,8(sp)
ffffffffc0200e36:	8522                	mv	a0,s0
ffffffffc0200e38:	6402                	ld	s0,0(sp)
ffffffffc0200e3a:	0141                	addi	sp,sp,16
ffffffffc0200e3c:	8082                	ret

ffffffffc0200e3e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e3e:	100027f3          	csrr	a5,sstatus
ffffffffc0200e42:	8b89                	andi	a5,a5,2
ffffffffc0200e44:	e799                	bnez	a5,ffffffffc0200e52 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e46:	00005797          	auipc	a5,0x5
ffffffffc0200e4a:	6127b783          	ld	a5,1554(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e4e:	739c                	ld	a5,32(a5)
ffffffffc0200e50:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e52:	1101                	addi	sp,sp,-32
ffffffffc0200e54:	ec06                	sd	ra,24(sp)
ffffffffc0200e56:	e822                	sd	s0,16(sp)
ffffffffc0200e58:	e426                	sd	s1,8(sp)
ffffffffc0200e5a:	842a                	mv	s0,a0
ffffffffc0200e5c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200e5e:	e00ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200e62:	00005797          	auipc	a5,0x5
ffffffffc0200e66:	5f67b783          	ld	a5,1526(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200e6a:	739c                	ld	a5,32(a5)
ffffffffc0200e6c:	85a6                	mv	a1,s1
ffffffffc0200e6e:	8522                	mv	a0,s0
ffffffffc0200e70:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200e72:	6442                	ld	s0,16(sp)
ffffffffc0200e74:	60e2                	ld	ra,24(sp)
ffffffffc0200e76:	64a2                	ld	s1,8(sp)
ffffffffc0200e78:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200e7a:	ddeff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200e7e <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e7e:	00001797          	auipc	a5,0x1
ffffffffc0200e82:	04278793          	addi	a5,a5,66 # ffffffffc0201ec0 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e86:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e88:	1101                	addi	sp,sp,-32
ffffffffc0200e8a:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e8c:	00001517          	auipc	a0,0x1
ffffffffc0200e90:	06c50513          	addi	a0,a0,108 # ffffffffc0201ef8 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e94:	00005497          	auipc	s1,0x5
ffffffffc0200e98:	5c448493          	addi	s1,s1,1476 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e9c:	ec06                	sd	ra,24(sp)
ffffffffc0200e9e:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200ea0:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ea2:	a10ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200ea6:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ea8:	00005417          	auipc	s0,0x5
ffffffffc0200eac:	5c840413          	addi	s0,s0,1480 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200eb0:	679c                	ld	a5,8(a5)
ffffffffc0200eb2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200eb4:	57f5                	li	a5,-3
ffffffffc0200eb6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200eb8:	00001517          	auipc	a0,0x1
ffffffffc0200ebc:	05850513          	addi	a0,a0,88 # ffffffffc0201f10 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ec0:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200ec2:	9f0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200ec6:	46c5                	li	a3,17
ffffffffc0200ec8:	06ee                	slli	a3,a3,0x1b
ffffffffc0200eca:	40100613          	li	a2,1025
ffffffffc0200ece:	16fd                	addi	a3,a3,-1
ffffffffc0200ed0:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ed4:	0656                	slli	a2,a2,0x15
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	05250513          	addi	a0,a0,82 # ffffffffc0201f28 <buddy_pmm_manager+0x68>
ffffffffc0200ede:	9d4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ee2:	777d                	lui	a4,0xfffff
ffffffffc0200ee4:	00006797          	auipc	a5,0x6
ffffffffc0200ee8:	59b78793          	addi	a5,a5,1435 # ffffffffc020747f <end+0xfff>
ffffffffc0200eec:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200eee:	00005517          	auipc	a0,0x5
ffffffffc0200ef2:	55a50513          	addi	a0,a0,1370 # ffffffffc0206448 <npage>
ffffffffc0200ef6:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200efa:	00005597          	auipc	a1,0x5
ffffffffc0200efe:	55658593          	addi	a1,a1,1366 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200f02:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f04:	e19c                	sd	a5,0(a1)
ffffffffc0200f06:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f08:	4701                	li	a4,0
ffffffffc0200f0a:	4885                	li	a7,1
ffffffffc0200f0c:	fff80837          	lui	a6,0xfff80
ffffffffc0200f10:	a011                	j	ffffffffc0200f14 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200f12:	619c                	ld	a5,0(a1)
ffffffffc0200f14:	97b6                	add	a5,a5,a3
ffffffffc0200f16:	07a1                	addi	a5,a5,8
ffffffffc0200f18:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f1c:	611c                	ld	a5,0(a0)
ffffffffc0200f1e:	0705                	addi	a4,a4,1
ffffffffc0200f20:	02868693          	addi	a3,a3,40
ffffffffc0200f24:	01078633          	add	a2,a5,a6
ffffffffc0200f28:	fec765e3          	bltu	a4,a2,ffffffffc0200f12 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f2c:	6190                	ld	a2,0(a1)
ffffffffc0200f2e:	00279713          	slli	a4,a5,0x2
ffffffffc0200f32:	973e                	add	a4,a4,a5
ffffffffc0200f34:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f38:	070e                	slli	a4,a4,0x3
ffffffffc0200f3a:	96b2                	add	a3,a3,a2
ffffffffc0200f3c:	96ba                	add	a3,a3,a4
ffffffffc0200f3e:	c0200737          	lui	a4,0xc0200
ffffffffc0200f42:	08e6ef63          	bltu	a3,a4,ffffffffc0200fe0 <pmm_init+0x162>
ffffffffc0200f46:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200f48:	45c5                	li	a1,17
ffffffffc0200f4a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f4c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200f4e:	04b6e863          	bltu	a3,a1,ffffffffc0200f9e <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f52:	609c                	ld	a5,0(s1)
ffffffffc0200f54:	7b9c                	ld	a5,48(a5)
ffffffffc0200f56:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f58:	00001517          	auipc	a0,0x1
ffffffffc0200f5c:	06850513          	addi	a0,a0,104 # ffffffffc0201fc0 <buddy_pmm_manager+0x100>
ffffffffc0200f60:	952ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f64:	00004597          	auipc	a1,0x4
ffffffffc0200f68:	09c58593          	addi	a1,a1,156 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f6c:	00005797          	auipc	a5,0x5
ffffffffc0200f70:	4eb7be23          	sd	a1,1276(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f74:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f78:	08f5e063          	bltu	a1,a5,ffffffffc0200ff8 <pmm_init+0x17a>
ffffffffc0200f7c:	6010                	ld	a2,0(s0)
}
ffffffffc0200f7e:	6442                	ld	s0,16(sp)
ffffffffc0200f80:	60e2                	ld	ra,24(sp)
ffffffffc0200f82:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f84:	40c58633          	sub	a2,a1,a2
ffffffffc0200f88:	00005797          	auipc	a5,0x5
ffffffffc0200f8c:	4cc7bc23          	sd	a2,1240(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f90:	00001517          	auipc	a0,0x1
ffffffffc0200f94:	05050513          	addi	a0,a0,80 # ffffffffc0201fe0 <buddy_pmm_manager+0x120>
}
ffffffffc0200f98:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f9a:	918ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f9e:	6705                	lui	a4,0x1
ffffffffc0200fa0:	177d                	addi	a4,a4,-1
ffffffffc0200fa2:	96ba                	add	a3,a3,a4
ffffffffc0200fa4:	777d                	lui	a4,0xfffff
ffffffffc0200fa6:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200fa8:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200fac:	00f57e63          	bgeu	a0,a5,ffffffffc0200fc8 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200fb0:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200fb2:	982a                	add	a6,a6,a0
ffffffffc0200fb4:	00281513          	slli	a0,a6,0x2
ffffffffc0200fb8:	9542                	add	a0,a0,a6
ffffffffc0200fba:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200fbc:	8d95                	sub	a1,a1,a3
ffffffffc0200fbe:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200fc0:	81b1                	srli	a1,a1,0xc
ffffffffc0200fc2:	9532                	add	a0,a0,a2
ffffffffc0200fc4:	9782                	jalr	a5
}
ffffffffc0200fc6:	b771                	j	ffffffffc0200f52 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200fc8:	00001617          	auipc	a2,0x1
ffffffffc0200fcc:	fc860613          	addi	a2,a2,-56 # ffffffffc0201f90 <buddy_pmm_manager+0xd0>
ffffffffc0200fd0:	06b00593          	li	a1,107
ffffffffc0200fd4:	00001517          	auipc	a0,0x1
ffffffffc0200fd8:	fdc50513          	addi	a0,a0,-36 # ffffffffc0201fb0 <buddy_pmm_manager+0xf0>
ffffffffc0200fdc:	bd0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	f7860613          	addi	a2,a2,-136 # ffffffffc0201f58 <buddy_pmm_manager+0x98>
ffffffffc0200fe8:	07000593          	li	a1,112
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	f9450513          	addi	a0,a0,-108 # ffffffffc0201f80 <buddy_pmm_manager+0xc0>
ffffffffc0200ff4:	bb8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ff8:	86ae                	mv	a3,a1
ffffffffc0200ffa:	00001617          	auipc	a2,0x1
ffffffffc0200ffe:	f5e60613          	addi	a2,a2,-162 # ffffffffc0201f58 <buddy_pmm_manager+0x98>
ffffffffc0201002:	08b00593          	li	a1,139
ffffffffc0201006:	00001517          	auipc	a0,0x1
ffffffffc020100a:	f7a50513          	addi	a0,a0,-134 # ffffffffc0201f80 <buddy_pmm_manager+0xc0>
ffffffffc020100e:	b9eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201012 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201012:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201016:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201018:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020101c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020101e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201022:	f022                	sd	s0,32(sp)
ffffffffc0201024:	ec26                	sd	s1,24(sp)
ffffffffc0201026:	e84a                	sd	s2,16(sp)
ffffffffc0201028:	f406                	sd	ra,40(sp)
ffffffffc020102a:	e44e                	sd	s3,8(sp)
ffffffffc020102c:	84aa                	mv	s1,a0
ffffffffc020102e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201030:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201034:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201036:	03067e63          	bgeu	a2,a6,ffffffffc0201072 <printnum+0x60>
ffffffffc020103a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020103c:	00805763          	blez	s0,ffffffffc020104a <printnum+0x38>
ffffffffc0201040:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201042:	85ca                	mv	a1,s2
ffffffffc0201044:	854e                	mv	a0,s3
ffffffffc0201046:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201048:	fc65                	bnez	s0,ffffffffc0201040 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020104a:	1a02                	slli	s4,s4,0x20
ffffffffc020104c:	00001797          	auipc	a5,0x1
ffffffffc0201050:	fd478793          	addi	a5,a5,-44 # ffffffffc0202020 <buddy_pmm_manager+0x160>
ffffffffc0201054:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201058:	9a3e                	add	s4,s4,a5
}
ffffffffc020105a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020105c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201060:	70a2                	ld	ra,40(sp)
ffffffffc0201062:	69a2                	ld	s3,8(sp)
ffffffffc0201064:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201066:	85ca                	mv	a1,s2
ffffffffc0201068:	87a6                	mv	a5,s1
}
ffffffffc020106a:	6942                	ld	s2,16(sp)
ffffffffc020106c:	64e2                	ld	s1,24(sp)
ffffffffc020106e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201070:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201072:	03065633          	divu	a2,a2,a6
ffffffffc0201076:	8722                	mv	a4,s0
ffffffffc0201078:	f9bff0ef          	jal	ra,ffffffffc0201012 <printnum>
ffffffffc020107c:	b7f9                	j	ffffffffc020104a <printnum+0x38>

ffffffffc020107e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020107e:	7119                	addi	sp,sp,-128
ffffffffc0201080:	f4a6                	sd	s1,104(sp)
ffffffffc0201082:	f0ca                	sd	s2,96(sp)
ffffffffc0201084:	ecce                	sd	s3,88(sp)
ffffffffc0201086:	e8d2                	sd	s4,80(sp)
ffffffffc0201088:	e4d6                	sd	s5,72(sp)
ffffffffc020108a:	e0da                	sd	s6,64(sp)
ffffffffc020108c:	fc5e                	sd	s7,56(sp)
ffffffffc020108e:	f06a                	sd	s10,32(sp)
ffffffffc0201090:	fc86                	sd	ra,120(sp)
ffffffffc0201092:	f8a2                	sd	s0,112(sp)
ffffffffc0201094:	f862                	sd	s8,48(sp)
ffffffffc0201096:	f466                	sd	s9,40(sp)
ffffffffc0201098:	ec6e                	sd	s11,24(sp)
ffffffffc020109a:	892a                	mv	s2,a0
ffffffffc020109c:	84ae                	mv	s1,a1
ffffffffc020109e:	8d32                	mv	s10,a2
ffffffffc02010a0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010a2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02010a6:	5b7d                	li	s6,-1
ffffffffc02010a8:	00001a97          	auipc	s5,0x1
ffffffffc02010ac:	faca8a93          	addi	s5,s5,-84 # ffffffffc0202054 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010b0:	00001b97          	auipc	s7,0x1
ffffffffc02010b4:	180b8b93          	addi	s7,s7,384 # ffffffffc0202230 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010b8:	000d4503          	lbu	a0,0(s10)
ffffffffc02010bc:	001d0413          	addi	s0,s10,1
ffffffffc02010c0:	01350a63          	beq	a0,s3,ffffffffc02010d4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02010c4:	c121                	beqz	a0,ffffffffc0201104 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02010c6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010c8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010ca:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010cc:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010d0:	ff351ae3          	bne	a0,s3,ffffffffc02010c4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010d4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010d8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010dc:	4c81                	li	s9,0
ffffffffc02010de:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02010e0:	5c7d                	li	s8,-1
ffffffffc02010e2:	5dfd                	li	s11,-1
ffffffffc02010e4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02010e8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010ea:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010ee:	0ff5f593          	zext.b	a1,a1
ffffffffc02010f2:	00140d13          	addi	s10,s0,1
ffffffffc02010f6:	04b56263          	bltu	a0,a1,ffffffffc020113a <vprintfmt+0xbc>
ffffffffc02010fa:	058a                	slli	a1,a1,0x2
ffffffffc02010fc:	95d6                	add	a1,a1,s5
ffffffffc02010fe:	4194                	lw	a3,0(a1)
ffffffffc0201100:	96d6                	add	a3,a3,s5
ffffffffc0201102:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201104:	70e6                	ld	ra,120(sp)
ffffffffc0201106:	7446                	ld	s0,112(sp)
ffffffffc0201108:	74a6                	ld	s1,104(sp)
ffffffffc020110a:	7906                	ld	s2,96(sp)
ffffffffc020110c:	69e6                	ld	s3,88(sp)
ffffffffc020110e:	6a46                	ld	s4,80(sp)
ffffffffc0201110:	6aa6                	ld	s5,72(sp)
ffffffffc0201112:	6b06                	ld	s6,64(sp)
ffffffffc0201114:	7be2                	ld	s7,56(sp)
ffffffffc0201116:	7c42                	ld	s8,48(sp)
ffffffffc0201118:	7ca2                	ld	s9,40(sp)
ffffffffc020111a:	7d02                	ld	s10,32(sp)
ffffffffc020111c:	6de2                	ld	s11,24(sp)
ffffffffc020111e:	6109                	addi	sp,sp,128
ffffffffc0201120:	8082                	ret
            padc = '0';
ffffffffc0201122:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201124:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201128:	846a                	mv	s0,s10
ffffffffc020112a:	00140d13          	addi	s10,s0,1
ffffffffc020112e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201132:	0ff5f593          	zext.b	a1,a1
ffffffffc0201136:	fcb572e3          	bgeu	a0,a1,ffffffffc02010fa <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020113a:	85a6                	mv	a1,s1
ffffffffc020113c:	02500513          	li	a0,37
ffffffffc0201140:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201142:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201146:	8d22                	mv	s10,s0
ffffffffc0201148:	f73788e3          	beq	a5,s3,ffffffffc02010b8 <vprintfmt+0x3a>
ffffffffc020114c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201150:	1d7d                	addi	s10,s10,-1
ffffffffc0201152:	ff379de3          	bne	a5,s3,ffffffffc020114c <vprintfmt+0xce>
ffffffffc0201156:	b78d                	j	ffffffffc02010b8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201158:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020115c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201160:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201162:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201166:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020116a:	02d86463          	bltu	a6,a3,ffffffffc0201192 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020116e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201172:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201176:	0186873b          	addw	a4,a3,s8
ffffffffc020117a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020117e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201180:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201184:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201186:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020118a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020118e:	fed870e3          	bgeu	a6,a3,ffffffffc020116e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201192:	f40ddce3          	bgez	s11,ffffffffc02010ea <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201196:	8de2                	mv	s11,s8
ffffffffc0201198:	5c7d                	li	s8,-1
ffffffffc020119a:	bf81                	j	ffffffffc02010ea <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020119c:	fffdc693          	not	a3,s11
ffffffffc02011a0:	96fd                	srai	a3,a3,0x3f
ffffffffc02011a2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a6:	00144603          	lbu	a2,1(s0)
ffffffffc02011aa:	2d81                	sext.w	s11,s11
ffffffffc02011ac:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011ae:	bf35                	j	ffffffffc02010ea <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02011b0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02011b8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ba:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02011bc:	bfd9                	j	ffffffffc0201192 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02011be:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011c4:	01174463          	blt	a4,a7,ffffffffc02011cc <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02011c8:	1a088e63          	beqz	a7,ffffffffc0201384 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02011cc:	000a3603          	ld	a2,0(s4)
ffffffffc02011d0:	46c1                	li	a3,16
ffffffffc02011d2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011d4:	2781                	sext.w	a5,a5
ffffffffc02011d6:	876e                	mv	a4,s11
ffffffffc02011d8:	85a6                	mv	a1,s1
ffffffffc02011da:	854a                	mv	a0,s2
ffffffffc02011dc:	e37ff0ef          	jal	ra,ffffffffc0201012 <printnum>
            break;
ffffffffc02011e0:	bde1                	j	ffffffffc02010b8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02011e2:	000a2503          	lw	a0,0(s4)
ffffffffc02011e6:	85a6                	mv	a1,s1
ffffffffc02011e8:	0a21                	addi	s4,s4,8
ffffffffc02011ea:	9902                	jalr	s2
            break;
ffffffffc02011ec:	b5f1                	j	ffffffffc02010b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011f4:	01174463          	blt	a4,a7,ffffffffc02011fc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02011f8:	18088163          	beqz	a7,ffffffffc020137a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02011fc:	000a3603          	ld	a2,0(s4)
ffffffffc0201200:	46a9                	li	a3,10
ffffffffc0201202:	8a2e                	mv	s4,a1
ffffffffc0201204:	bfc1                	j	ffffffffc02011d4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201206:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020120a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020120c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020120e:	bdf1                	j	ffffffffc02010ea <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201210:	85a6                	mv	a1,s1
ffffffffc0201212:	02500513          	li	a0,37
ffffffffc0201216:	9902                	jalr	s2
            break;
ffffffffc0201218:	b545                	j	ffffffffc02010b8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020121a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020121e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201220:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201222:	b5e1                	j	ffffffffc02010ea <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201224:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201226:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020122a:	01174463          	blt	a4,a7,ffffffffc0201232 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020122e:	14088163          	beqz	a7,ffffffffc0201370 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201232:	000a3603          	ld	a2,0(s4)
ffffffffc0201236:	46a1                	li	a3,8
ffffffffc0201238:	8a2e                	mv	s4,a1
ffffffffc020123a:	bf69                	j	ffffffffc02011d4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020123c:	03000513          	li	a0,48
ffffffffc0201240:	85a6                	mv	a1,s1
ffffffffc0201242:	e03e                	sd	a5,0(sp)
ffffffffc0201244:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201246:	85a6                	mv	a1,s1
ffffffffc0201248:	07800513          	li	a0,120
ffffffffc020124c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020124e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201250:	6782                	ld	a5,0(sp)
ffffffffc0201252:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201254:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201258:	bfb5                	j	ffffffffc02011d4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020125a:	000a3403          	ld	s0,0(s4)
ffffffffc020125e:	008a0713          	addi	a4,s4,8
ffffffffc0201262:	e03a                	sd	a4,0(sp)
ffffffffc0201264:	14040263          	beqz	s0,ffffffffc02013a8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201268:	0fb05763          	blez	s11,ffffffffc0201356 <vprintfmt+0x2d8>
ffffffffc020126c:	02d00693          	li	a3,45
ffffffffc0201270:	0cd79163          	bne	a5,a3,ffffffffc0201332 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201274:	00044783          	lbu	a5,0(s0)
ffffffffc0201278:	0007851b          	sext.w	a0,a5
ffffffffc020127c:	cf85                	beqz	a5,ffffffffc02012b4 <vprintfmt+0x236>
ffffffffc020127e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201282:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201286:	000c4563          	bltz	s8,ffffffffc0201290 <vprintfmt+0x212>
ffffffffc020128a:	3c7d                	addiw	s8,s8,-1
ffffffffc020128c:	036c0263          	beq	s8,s6,ffffffffc02012b0 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201290:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201292:	0e0c8e63          	beqz	s9,ffffffffc020138e <vprintfmt+0x310>
ffffffffc0201296:	3781                	addiw	a5,a5,-32
ffffffffc0201298:	0ef47b63          	bgeu	s0,a5,ffffffffc020138e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020129c:	03f00513          	li	a0,63
ffffffffc02012a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012a2:	000a4783          	lbu	a5,0(s4)
ffffffffc02012a6:	3dfd                	addiw	s11,s11,-1
ffffffffc02012a8:	0a05                	addi	s4,s4,1
ffffffffc02012aa:	0007851b          	sext.w	a0,a5
ffffffffc02012ae:	ffe1                	bnez	a5,ffffffffc0201286 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02012b0:	01b05963          	blez	s11,ffffffffc02012c2 <vprintfmt+0x244>
ffffffffc02012b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02012b6:	85a6                	mv	a1,s1
ffffffffc02012b8:	02000513          	li	a0,32
ffffffffc02012bc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012be:	fe0d9be3          	bnez	s11,ffffffffc02012b4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012c2:	6a02                	ld	s4,0(sp)
ffffffffc02012c4:	bbd5                	j	ffffffffc02010b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012c8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02012cc:	01174463          	blt	a4,a7,ffffffffc02012d4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02012d0:	08088d63          	beqz	a7,ffffffffc020136a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02012d4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02012d8:	0a044d63          	bltz	s0,ffffffffc0201392 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02012dc:	8622                	mv	a2,s0
ffffffffc02012de:	8a66                	mv	s4,s9
ffffffffc02012e0:	46a9                	li	a3,10
ffffffffc02012e2:	bdcd                	j	ffffffffc02011d4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02012e4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012e8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02012ea:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02012ec:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02012f0:	8fb5                	xor	a5,a5,a3
ffffffffc02012f2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012f6:	02d74163          	blt	a4,a3,ffffffffc0201318 <vprintfmt+0x29a>
ffffffffc02012fa:	00369793          	slli	a5,a3,0x3
ffffffffc02012fe:	97de                	add	a5,a5,s7
ffffffffc0201300:	639c                	ld	a5,0(a5)
ffffffffc0201302:	cb99                	beqz	a5,ffffffffc0201318 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201304:	86be                	mv	a3,a5
ffffffffc0201306:	00001617          	auipc	a2,0x1
ffffffffc020130a:	d4a60613          	addi	a2,a2,-694 # ffffffffc0202050 <buddy_pmm_manager+0x190>
ffffffffc020130e:	85a6                	mv	a1,s1
ffffffffc0201310:	854a                	mv	a0,s2
ffffffffc0201312:	0ce000ef          	jal	ra,ffffffffc02013e0 <printfmt>
ffffffffc0201316:	b34d                	j	ffffffffc02010b8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201318:	00001617          	auipc	a2,0x1
ffffffffc020131c:	d2860613          	addi	a2,a2,-728 # ffffffffc0202040 <buddy_pmm_manager+0x180>
ffffffffc0201320:	85a6                	mv	a1,s1
ffffffffc0201322:	854a                	mv	a0,s2
ffffffffc0201324:	0bc000ef          	jal	ra,ffffffffc02013e0 <printfmt>
ffffffffc0201328:	bb41                	j	ffffffffc02010b8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020132a:	00001417          	auipc	s0,0x1
ffffffffc020132e:	d0e40413          	addi	s0,s0,-754 # ffffffffc0202038 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201332:	85e2                	mv	a1,s8
ffffffffc0201334:	8522                	mv	a0,s0
ffffffffc0201336:	e43e                	sd	a5,8(sp)
ffffffffc0201338:	1e6000ef          	jal	ra,ffffffffc020151e <strnlen>
ffffffffc020133c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201340:	01b05b63          	blez	s11,ffffffffc0201356 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201344:	67a2                	ld	a5,8(sp)
ffffffffc0201346:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020134a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020134c:	85a6                	mv	a1,s1
ffffffffc020134e:	8552                	mv	a0,s4
ffffffffc0201350:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201352:	fe0d9ce3          	bnez	s11,ffffffffc020134a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201356:	00044783          	lbu	a5,0(s0)
ffffffffc020135a:	00140a13          	addi	s4,s0,1
ffffffffc020135e:	0007851b          	sext.w	a0,a5
ffffffffc0201362:	d3a5                	beqz	a5,ffffffffc02012c2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201364:	05e00413          	li	s0,94
ffffffffc0201368:	bf39                	j	ffffffffc0201286 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020136a:	000a2403          	lw	s0,0(s4)
ffffffffc020136e:	b7ad                	j	ffffffffc02012d8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201370:	000a6603          	lwu	a2,0(s4)
ffffffffc0201374:	46a1                	li	a3,8
ffffffffc0201376:	8a2e                	mv	s4,a1
ffffffffc0201378:	bdb1                	j	ffffffffc02011d4 <vprintfmt+0x156>
ffffffffc020137a:	000a6603          	lwu	a2,0(s4)
ffffffffc020137e:	46a9                	li	a3,10
ffffffffc0201380:	8a2e                	mv	s4,a1
ffffffffc0201382:	bd89                	j	ffffffffc02011d4 <vprintfmt+0x156>
ffffffffc0201384:	000a6603          	lwu	a2,0(s4)
ffffffffc0201388:	46c1                	li	a3,16
ffffffffc020138a:	8a2e                	mv	s4,a1
ffffffffc020138c:	b5a1                	j	ffffffffc02011d4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020138e:	9902                	jalr	s2
ffffffffc0201390:	bf09                	j	ffffffffc02012a2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201392:	85a6                	mv	a1,s1
ffffffffc0201394:	02d00513          	li	a0,45
ffffffffc0201398:	e03e                	sd	a5,0(sp)
ffffffffc020139a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020139c:	6782                	ld	a5,0(sp)
ffffffffc020139e:	8a66                	mv	s4,s9
ffffffffc02013a0:	40800633          	neg	a2,s0
ffffffffc02013a4:	46a9                	li	a3,10
ffffffffc02013a6:	b53d                	j	ffffffffc02011d4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02013a8:	03b05163          	blez	s11,ffffffffc02013ca <vprintfmt+0x34c>
ffffffffc02013ac:	02d00693          	li	a3,45
ffffffffc02013b0:	f6d79de3          	bne	a5,a3,ffffffffc020132a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02013b4:	00001417          	auipc	s0,0x1
ffffffffc02013b8:	c8440413          	addi	s0,s0,-892 # ffffffffc0202038 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013bc:	02800793          	li	a5,40
ffffffffc02013c0:	02800513          	li	a0,40
ffffffffc02013c4:	00140a13          	addi	s4,s0,1
ffffffffc02013c8:	bd6d                	j	ffffffffc0201282 <vprintfmt+0x204>
ffffffffc02013ca:	00001a17          	auipc	s4,0x1
ffffffffc02013ce:	c6fa0a13          	addi	s4,s4,-913 # ffffffffc0202039 <buddy_pmm_manager+0x179>
ffffffffc02013d2:	02800513          	li	a0,40
ffffffffc02013d6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013da:	05e00413          	li	s0,94
ffffffffc02013de:	b565                	j	ffffffffc0201286 <vprintfmt+0x208>

ffffffffc02013e0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013e0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013e2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013e6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013e8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013ea:	ec06                	sd	ra,24(sp)
ffffffffc02013ec:	f83a                	sd	a4,48(sp)
ffffffffc02013ee:	fc3e                	sd	a5,56(sp)
ffffffffc02013f0:	e0c2                	sd	a6,64(sp)
ffffffffc02013f2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02013f4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013f6:	c89ff0ef          	jal	ra,ffffffffc020107e <vprintfmt>
}
ffffffffc02013fa:	60e2                	ld	ra,24(sp)
ffffffffc02013fc:	6161                	addi	sp,sp,80
ffffffffc02013fe:	8082                	ret

ffffffffc0201400 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201400:	715d                	addi	sp,sp,-80
ffffffffc0201402:	e486                	sd	ra,72(sp)
ffffffffc0201404:	e0a6                	sd	s1,64(sp)
ffffffffc0201406:	fc4a                	sd	s2,56(sp)
ffffffffc0201408:	f84e                	sd	s3,48(sp)
ffffffffc020140a:	f452                	sd	s4,40(sp)
ffffffffc020140c:	f056                	sd	s5,32(sp)
ffffffffc020140e:	ec5a                	sd	s6,24(sp)
ffffffffc0201410:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201412:	c901                	beqz	a0,ffffffffc0201422 <readline+0x22>
ffffffffc0201414:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201416:	00001517          	auipc	a0,0x1
ffffffffc020141a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0202050 <buddy_pmm_manager+0x190>
ffffffffc020141e:	c95fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201422:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201424:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201426:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201428:	4aa9                	li	s5,10
ffffffffc020142a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020142c:	00005b97          	auipc	s7,0x5
ffffffffc0201430:	c04b8b93          	addi	s7,s7,-1020 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201434:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201438:	cf3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020143c:	00054a63          	bltz	a0,ffffffffc0201450 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201440:	00a95a63          	bge	s2,a0,ffffffffc0201454 <readline+0x54>
ffffffffc0201444:	029a5263          	bge	s4,s1,ffffffffc0201468 <readline+0x68>
        c = getchar();
ffffffffc0201448:	ce3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020144c:	fe055ae3          	bgez	a0,ffffffffc0201440 <readline+0x40>
            return NULL;
ffffffffc0201450:	4501                	li	a0,0
ffffffffc0201452:	a091                	j	ffffffffc0201496 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201454:	03351463          	bne	a0,s3,ffffffffc020147c <readline+0x7c>
ffffffffc0201458:	e8a9                	bnez	s1,ffffffffc02014aa <readline+0xaa>
        c = getchar();
ffffffffc020145a:	cd1fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020145e:	fe0549e3          	bltz	a0,ffffffffc0201450 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201462:	fea959e3          	bge	s2,a0,ffffffffc0201454 <readline+0x54>
ffffffffc0201466:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201468:	e42a                	sd	a0,8(sp)
ffffffffc020146a:	c7ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020146e:	6522                	ld	a0,8(sp)
ffffffffc0201470:	009b87b3          	add	a5,s7,s1
ffffffffc0201474:	2485                	addiw	s1,s1,1
ffffffffc0201476:	00a78023          	sb	a0,0(a5)
ffffffffc020147a:	bf7d                	j	ffffffffc0201438 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020147c:	01550463          	beq	a0,s5,ffffffffc0201484 <readline+0x84>
ffffffffc0201480:	fb651ce3          	bne	a0,s6,ffffffffc0201438 <readline+0x38>
            cputchar(c);
ffffffffc0201484:	c65fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201488:	00005517          	auipc	a0,0x5
ffffffffc020148c:	ba850513          	addi	a0,a0,-1112 # ffffffffc0206030 <buf>
ffffffffc0201490:	94aa                	add	s1,s1,a0
ffffffffc0201492:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201496:	60a6                	ld	ra,72(sp)
ffffffffc0201498:	6486                	ld	s1,64(sp)
ffffffffc020149a:	7962                	ld	s2,56(sp)
ffffffffc020149c:	79c2                	ld	s3,48(sp)
ffffffffc020149e:	7a22                	ld	s4,40(sp)
ffffffffc02014a0:	7a82                	ld	s5,32(sp)
ffffffffc02014a2:	6b62                	ld	s6,24(sp)
ffffffffc02014a4:	6bc2                	ld	s7,16(sp)
ffffffffc02014a6:	6161                	addi	sp,sp,80
ffffffffc02014a8:	8082                	ret
            cputchar(c);
ffffffffc02014aa:	4521                	li	a0,8
ffffffffc02014ac:	c3dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02014b0:	34fd                	addiw	s1,s1,-1
ffffffffc02014b2:	b759                	j	ffffffffc0201438 <readline+0x38>

ffffffffc02014b4 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02014b4:	4781                	li	a5,0
ffffffffc02014b6:	00005717          	auipc	a4,0x5
ffffffffc02014ba:	b5273703          	ld	a4,-1198(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02014be:	88ba                	mv	a7,a4
ffffffffc02014c0:	852a                	mv	a0,a0
ffffffffc02014c2:	85be                	mv	a1,a5
ffffffffc02014c4:	863e                	mv	a2,a5
ffffffffc02014c6:	00000073          	ecall
ffffffffc02014ca:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02014cc:	8082                	ret

ffffffffc02014ce <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02014ce:	4781                	li	a5,0
ffffffffc02014d0:	00005717          	auipc	a4,0x5
ffffffffc02014d4:	fa873703          	ld	a4,-88(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc02014d8:	88ba                	mv	a7,a4
ffffffffc02014da:	852a                	mv	a0,a0
ffffffffc02014dc:	85be                	mv	a1,a5
ffffffffc02014de:	863e                	mv	a2,a5
ffffffffc02014e0:	00000073          	ecall
ffffffffc02014e4:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02014e6:	8082                	ret

ffffffffc02014e8 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02014e8:	4501                	li	a0,0
ffffffffc02014ea:	00005797          	auipc	a5,0x5
ffffffffc02014ee:	b167b783          	ld	a5,-1258(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02014f2:	88be                	mv	a7,a5
ffffffffc02014f4:	852a                	mv	a0,a0
ffffffffc02014f6:	85aa                	mv	a1,a0
ffffffffc02014f8:	862a                	mv	a2,a0
ffffffffc02014fa:	00000073          	ecall
ffffffffc02014fe:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201500:	2501                	sext.w	a0,a0
ffffffffc0201502:	8082                	ret

ffffffffc0201504 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201504:	4781                	li	a5,0
ffffffffc0201506:	00005717          	auipc	a4,0x5
ffffffffc020150a:	b0a73703          	ld	a4,-1270(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc020150e:	88ba                	mv	a7,a4
ffffffffc0201510:	853e                	mv	a0,a5
ffffffffc0201512:	85be                	mv	a1,a5
ffffffffc0201514:	863e                	mv	a2,a5
ffffffffc0201516:	00000073          	ecall
ffffffffc020151a:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc020151c:	8082                	ret

ffffffffc020151e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020151e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201520:	e589                	bnez	a1,ffffffffc020152a <strnlen+0xc>
ffffffffc0201522:	a811                	j	ffffffffc0201536 <strnlen+0x18>
        cnt ++;
ffffffffc0201524:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201526:	00f58863          	beq	a1,a5,ffffffffc0201536 <strnlen+0x18>
ffffffffc020152a:	00f50733          	add	a4,a0,a5
ffffffffc020152e:	00074703          	lbu	a4,0(a4)
ffffffffc0201532:	fb6d                	bnez	a4,ffffffffc0201524 <strnlen+0x6>
ffffffffc0201534:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201536:	852e                	mv	a0,a1
ffffffffc0201538:	8082                	ret

ffffffffc020153a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020153a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020153e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201542:	cb89                	beqz	a5,ffffffffc0201554 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201544:	0505                	addi	a0,a0,1
ffffffffc0201546:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201548:	fee789e3          	beq	a5,a4,ffffffffc020153a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020154c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201550:	9d19                	subw	a0,a0,a4
ffffffffc0201552:	8082                	ret
ffffffffc0201554:	4501                	li	a0,0
ffffffffc0201556:	bfed                	j	ffffffffc0201550 <strcmp+0x16>

ffffffffc0201558 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201558:	00054783          	lbu	a5,0(a0)
ffffffffc020155c:	c799                	beqz	a5,ffffffffc020156a <strchr+0x12>
        if (*s == c) {
ffffffffc020155e:	00f58763          	beq	a1,a5,ffffffffc020156c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201562:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201566:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201568:	fbfd                	bnez	a5,ffffffffc020155e <strchr+0x6>
    }
    return NULL;
ffffffffc020156a:	4501                	li	a0,0
}
ffffffffc020156c:	8082                	ret

ffffffffc020156e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020156e:	ca01                	beqz	a2,ffffffffc020157e <memset+0x10>
ffffffffc0201570:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201572:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201574:	0785                	addi	a5,a5,1
ffffffffc0201576:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020157a:	fec79de3          	bne	a5,a2,ffffffffc0201574 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020157e:	8082                	ret
