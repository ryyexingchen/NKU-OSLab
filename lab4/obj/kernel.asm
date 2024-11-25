
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020a060 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5c260613          	addi	a2,a2,1474 # ffffffffc0215600 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	04f040ef          	jal	ra,ffffffffc020489c <memset>

    cons_init();                // init the console
ffffffffc0200052:	506000ef          	jal	ra,ffffffffc0200558 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	caa58593          	addi	a1,a1,-854 # ffffffffc0204d00 <etext+0x6>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	cc250513          	addi	a0,a0,-830 # ffffffffc0204d20 <etext+0x26>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ca000ef          	jal	ra,ffffffffc0200234 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	7a3000ef          	jal	ra,ffffffffc0201010 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	558000ef          	jal	ra,ffffffffc02005ca <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5d4000ef          	jal	ra,ffffffffc020064a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	48d010ef          	jal	ra,ffffffffc0201d06 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	4a2040ef          	jal	ra,ffffffffc0204520 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	42a000ef          	jal	ra,ffffffffc02004ac <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	728020ef          	jal	ra,ffffffffc02027ae <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	47a000ef          	jal	ra,ffffffffc0200504 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	53e000ef          	jal	ra,ffffffffc02005cc <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	684040ef          	jal	ra,ffffffffc0204716 <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	4bc000ef          	jal	ra,ffffffffc020055a <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	09f040ef          	jal	ra,ffffffffc0204962 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	06b040ef          	jal	ra,ffffffffc0204962 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	a999                	j	ffffffffc020055a <cons_putc>

ffffffffc0200106 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
ffffffffc0200108:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020010a:	484000ef          	jal	ra,ffffffffc020058e <cons_getc>
ffffffffc020010e:	dd75                	beqz	a0,ffffffffc020010a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200110:	60a2                	ld	ra,8(sp)
ffffffffc0200112:	0141                	addi	sp,sp,16
ffffffffc0200114:	8082                	ret

ffffffffc0200116 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200116:	715d                	addi	sp,sp,-80
ffffffffc0200118:	e486                	sd	ra,72(sp)
ffffffffc020011a:	e0a2                	sd	s0,64(sp)
ffffffffc020011c:	fc26                	sd	s1,56(sp)
ffffffffc020011e:	f84a                	sd	s2,48(sp)
ffffffffc0200120:	f44e                	sd	s3,40(sp)
ffffffffc0200122:	f052                	sd	s4,32(sp)
ffffffffc0200124:	ec56                	sd	s5,24(sp)
ffffffffc0200126:	e85a                	sd	s6,16(sp)
ffffffffc0200128:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020012a:	c901                	beqz	a0,ffffffffc020013a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020012c:	85aa                	mv	a1,a0
ffffffffc020012e:	00005517          	auipc	a0,0x5
ffffffffc0200132:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204d28 <etext+0x2e>
ffffffffc0200136:	f9bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020013a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020013c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200140:	4aa9                	li	s5,10
ffffffffc0200142:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200144:	0000ab97          	auipc	s7,0xa
ffffffffc0200148:	f1cb8b93          	addi	s7,s7,-228 # ffffffffc020a060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200150:	fb7ff0ef          	jal	ra,ffffffffc0200106 <getchar>
ffffffffc0200154:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200156:	00054b63          	bltz	a0,ffffffffc020016c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015a:	00a95b63          	bge	s2,a0,ffffffffc0200170 <readline+0x5a>
ffffffffc020015e:	029a5463          	bge	s4,s1,ffffffffc0200186 <readline+0x70>
        c = getchar();
ffffffffc0200162:	fa5ff0ef          	jal	ra,ffffffffc0200106 <getchar>
ffffffffc0200166:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200168:	fe0559e3          	bgez	a0,ffffffffc020015a <readline+0x44>
            return NULL;
ffffffffc020016c:	4501                	li	a0,0
ffffffffc020016e:	a099                	j	ffffffffc02001b4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0200170:	03341463          	bne	s0,s3,ffffffffc0200198 <readline+0x82>
ffffffffc0200174:	e8b9                	bnez	s1,ffffffffc02001ca <readline+0xb4>
        c = getchar();
ffffffffc0200176:	f91ff0ef          	jal	ra,ffffffffc0200106 <getchar>
ffffffffc020017a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020017c:	fe0548e3          	bltz	a0,ffffffffc020016c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200180:	fea958e3          	bge	s2,a0,ffffffffc0200170 <readline+0x5a>
ffffffffc0200184:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200186:	8522                	mv	a0,s0
ffffffffc0200188:	f7dff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc020018c:	009b87b3          	add	a5,s7,s1
ffffffffc0200190:	00878023          	sb	s0,0(a5)
ffffffffc0200194:	2485                	addiw	s1,s1,1
ffffffffc0200196:	bf6d                	j	ffffffffc0200150 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200198:	01540463          	beq	s0,s5,ffffffffc02001a0 <readline+0x8a>
ffffffffc020019c:	fb641ae3          	bne	s0,s6,ffffffffc0200150 <readline+0x3a>
            cputchar(c);
ffffffffc02001a0:	8522                	mv	a0,s0
ffffffffc02001a2:	f63ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001a6:	0000a517          	auipc	a0,0xa
ffffffffc02001aa:	eba50513          	addi	a0,a0,-326 # ffffffffc020a060 <edata>
ffffffffc02001ae:	94aa                	add	s1,s1,a0
ffffffffc02001b0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001b4:	60a6                	ld	ra,72(sp)
ffffffffc02001b6:	6406                	ld	s0,64(sp)
ffffffffc02001b8:	74e2                	ld	s1,56(sp)
ffffffffc02001ba:	7942                	ld	s2,48(sp)
ffffffffc02001bc:	79a2                	ld	s3,40(sp)
ffffffffc02001be:	7a02                	ld	s4,32(sp)
ffffffffc02001c0:	6ae2                	ld	s5,24(sp)
ffffffffc02001c2:	6b42                	ld	s6,16(sp)
ffffffffc02001c4:	6ba2                	ld	s7,8(sp)
ffffffffc02001c6:	6161                	addi	sp,sp,80
ffffffffc02001c8:	8082                	ret
            cputchar(c);
ffffffffc02001ca:	4521                	li	a0,8
ffffffffc02001cc:	f39ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc02001d0:	34fd                	addiw	s1,s1,-1
ffffffffc02001d2:	bfbd                	j	ffffffffc0200150 <readline+0x3a>

ffffffffc02001d4 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001d4:	00015317          	auipc	t1,0x15
ffffffffc02001d8:	29c30313          	addi	t1,t1,668 # ffffffffc0215470 <is_panic>
ffffffffc02001dc:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e0:	715d                	addi	sp,sp,-80
ffffffffc02001e2:	ec06                	sd	ra,24(sp)
ffffffffc02001e4:	e822                	sd	s0,16(sp)
ffffffffc02001e6:	f436                	sd	a3,40(sp)
ffffffffc02001e8:	f83a                	sd	a4,48(sp)
ffffffffc02001ea:	fc3e                	sd	a5,56(sp)
ffffffffc02001ec:	e0c2                	sd	a6,64(sp)
ffffffffc02001ee:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f0:	02031c63          	bnez	t1,ffffffffc0200228 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f4:	4785                	li	a5,1
ffffffffc02001f6:	8432                	mv	s0,a2
ffffffffc02001f8:	00015717          	auipc	a4,0x15
ffffffffc02001fc:	26f72c23          	sw	a5,632(a4) # ffffffffc0215470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200202:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200204:	85aa                	mv	a1,a0
ffffffffc0200206:	00005517          	auipc	a0,0x5
ffffffffc020020a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0204d30 <etext+0x36>
    va_start(ap, fmt);
ffffffffc020020e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200210:	ec1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200214:	65a2                	ld	a1,8(sp)
ffffffffc0200216:	8522                	mv	a0,s0
ffffffffc0200218:	e99ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020021c:	00006517          	auipc	a0,0x6
ffffffffc0200220:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0205ae8 <commands+0xc98>
ffffffffc0200224:	eadff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200228:	3aa000ef          	jal	ra,ffffffffc02005d2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	130000ef          	jal	ra,ffffffffc020035e <kmonitor>
ffffffffc0200232:	bfed                	j	ffffffffc020022c <__panic+0x58>

ffffffffc0200234 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200234:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200236:	00005517          	auipc	a0,0x5
ffffffffc020023a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0204d80 <etext+0x86>
void print_kerninfo(void) {
ffffffffc020023e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200240:	e91ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200244:	00000597          	auipc	a1,0x0
ffffffffc0200248:	df258593          	addi	a1,a1,-526 # ffffffffc0200036 <kern_init>
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	b5450513          	addi	a0,a0,-1196 # ffffffffc0204da0 <etext+0xa6>
ffffffffc0200254:	e7dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200258:	00005597          	auipc	a1,0x5
ffffffffc020025c:	aa258593          	addi	a1,a1,-1374 # ffffffffc0204cfa <etext>
ffffffffc0200260:	00005517          	auipc	a0,0x5
ffffffffc0200264:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204dc0 <etext+0xc6>
ffffffffc0200268:	e69ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020026c:	0000a597          	auipc	a1,0xa
ffffffffc0200270:	df458593          	addi	a1,a1,-524 # ffffffffc020a060 <edata>
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0204de0 <etext+0xe6>
ffffffffc020027c:	e55ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200280:	00015597          	auipc	a1,0x15
ffffffffc0200284:	38058593          	addi	a1,a1,896 # ffffffffc0215600 <end>
ffffffffc0200288:	00005517          	auipc	a0,0x5
ffffffffc020028c:	b7850513          	addi	a0,a0,-1160 # ffffffffc0204e00 <etext+0x106>
ffffffffc0200290:	e41ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200294:	00015597          	auipc	a1,0x15
ffffffffc0200298:	76b58593          	addi	a1,a1,1899 # ffffffffc02159ff <end+0x3ff>
ffffffffc020029c:	00000797          	auipc	a5,0x0
ffffffffc02002a0:	d9a78793          	addi	a5,a5,-614 # ffffffffc0200036 <kern_init>
ffffffffc02002a4:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a8:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002ac:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002ae:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b2:	95be                	add	a1,a1,a5
ffffffffc02002b4:	85a9                	srai	a1,a1,0xa
ffffffffc02002b6:	00005517          	auipc	a0,0x5
ffffffffc02002ba:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0204e20 <etext+0x126>
}
ffffffffc02002be:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c0:	bd01                	j	ffffffffc02000d0 <cprintf>

ffffffffc02002c2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c4:	00005617          	auipc	a2,0x5
ffffffffc02002c8:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0204d50 <etext+0x56>
ffffffffc02002cc:	04d00593          	li	a1,77
ffffffffc02002d0:	00005517          	auipc	a0,0x5
ffffffffc02002d4:	a9850513          	addi	a0,a0,-1384 # ffffffffc0204d68 <etext+0x6e>
void print_stackframe(void) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002da:	efbff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02002de <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002de:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e0:	00005617          	auipc	a2,0x5
ffffffffc02002e4:	c5060613          	addi	a2,a2,-944 # ffffffffc0204f30 <commands+0xe0>
ffffffffc02002e8:	00005597          	auipc	a1,0x5
ffffffffc02002ec:	c6858593          	addi	a1,a1,-920 # ffffffffc0204f50 <commands+0x100>
ffffffffc02002f0:	00005517          	auipc	a0,0x5
ffffffffc02002f4:	c6850513          	addi	a0,a0,-920 # ffffffffc0204f58 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002fa:	dd7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02002fe:	00005617          	auipc	a2,0x5
ffffffffc0200302:	c6a60613          	addi	a2,a2,-918 # ffffffffc0204f68 <commands+0x118>
ffffffffc0200306:	00005597          	auipc	a1,0x5
ffffffffc020030a:	c8a58593          	addi	a1,a1,-886 # ffffffffc0204f90 <commands+0x140>
ffffffffc020030e:	00005517          	auipc	a0,0x5
ffffffffc0200312:	c4a50513          	addi	a0,a0,-950 # ffffffffc0204f58 <commands+0x108>
ffffffffc0200316:	dbbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020031a:	00005617          	auipc	a2,0x5
ffffffffc020031e:	c8660613          	addi	a2,a2,-890 # ffffffffc0204fa0 <commands+0x150>
ffffffffc0200322:	00005597          	auipc	a1,0x5
ffffffffc0200326:	c9e58593          	addi	a1,a1,-866 # ffffffffc0204fc0 <commands+0x170>
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	c2e50513          	addi	a0,a0,-978 # ffffffffc0204f58 <commands+0x108>
ffffffffc0200332:	d9fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200342:	ef3ff0ef          	jal	ra,ffffffffc0200234 <print_kerninfo>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020034e:	1141                	addi	sp,sp,-16
ffffffffc0200350:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200352:	f71ff0ef          	jal	ra,ffffffffc02002c2 <print_stackframe>
    return 0;
}
ffffffffc0200356:	60a2                	ld	ra,8(sp)
ffffffffc0200358:	4501                	li	a0,0
ffffffffc020035a:	0141                	addi	sp,sp,16
ffffffffc020035c:	8082                	ret

ffffffffc020035e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020035e:	7115                	addi	sp,sp,-224
ffffffffc0200360:	e962                	sd	s8,144(sp)
ffffffffc0200362:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200364:	00005517          	auipc	a0,0x5
ffffffffc0200368:	b3450513          	addi	a0,a0,-1228 # ffffffffc0204e98 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020036c:	ed86                	sd	ra,216(sp)
ffffffffc020036e:	e9a2                	sd	s0,208(sp)
ffffffffc0200370:	e5a6                	sd	s1,200(sp)
ffffffffc0200372:	e1ca                	sd	s2,192(sp)
ffffffffc0200374:	fd4e                	sd	s3,184(sp)
ffffffffc0200376:	f952                	sd	s4,176(sp)
ffffffffc0200378:	f556                	sd	s5,168(sp)
ffffffffc020037a:	f15a                	sd	s6,160(sp)
ffffffffc020037c:	ed5e                	sd	s7,152(sp)
ffffffffc020037e:	e566                	sd	s9,136(sp)
ffffffffc0200380:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200382:	d4fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200386:	00005517          	auipc	a0,0x5
ffffffffc020038a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0204ec0 <commands+0x70>
ffffffffc020038e:	d43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200392:	000c0563          	beqz	s8,ffffffffc020039c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200396:	8562                	mv	a0,s8
ffffffffc0200398:	49a000ef          	jal	ra,ffffffffc0200832 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020039c:	4501                	li	a0,0
ffffffffc020039e:	4581                	li	a1,0
ffffffffc02003a0:	4601                	li	a2,0
ffffffffc02003a2:	48a1                	li	a7,8
ffffffffc02003a4:	00000073          	ecall
ffffffffc02003a8:	00005c97          	auipc	s9,0x5
ffffffffc02003ac:	aa8c8c93          	addi	s9,s9,-1368 # ffffffffc0204e50 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b0:	00005997          	auipc	s3,0x5
ffffffffc02003b4:	b3898993          	addi	s3,s3,-1224 # ffffffffc0204ee8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	00005917          	auipc	s2,0x5
ffffffffc02003bc:	b3890913          	addi	s2,s2,-1224 # ffffffffc0204ef0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02003c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c2:	00005b17          	auipc	s6,0x5
ffffffffc02003c6:	b36b0b13          	addi	s6,s6,-1226 # ffffffffc0204ef8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003ca:	00005a97          	auipc	s5,0x5
ffffffffc02003ce:	b86a8a93          	addi	s5,s5,-1146 # ffffffffc0204f50 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003d4:	854e                	mv	a0,s3
ffffffffc02003d6:	d41ff0ef          	jal	ra,ffffffffc0200116 <readline>
ffffffffc02003da:	842a                	mv	s0,a0
ffffffffc02003dc:	dd65                	beqz	a0,ffffffffc02003d4 <kmonitor+0x76>
ffffffffc02003de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e4:	c999                	beqz	a1,ffffffffc02003fa <kmonitor+0x9c>
ffffffffc02003e6:	854a                	mv	a0,s2
ffffffffc02003e8:	496040ef          	jal	ra,ffffffffc020487e <strchr>
ffffffffc02003ec:	c925                	beqz	a0,ffffffffc020045c <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc02003ee:	00144583          	lbu	a1,1(s0)
ffffffffc02003f2:	00040023          	sb	zero,0(s0)
ffffffffc02003f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f8:	f5fd                	bnez	a1,ffffffffc02003e6 <kmonitor+0x88>
    if (argc == 0) {
ffffffffc02003fa:	dce9                	beqz	s1,ffffffffc02003d4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00005d17          	auipc	s10,0x5
ffffffffc0200402:	a52d0d13          	addi	s10,s10,-1454 # ffffffffc0204e50 <commands>
    if (argc == 0) {
ffffffffc0200406:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200408:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040a:	0d61                	addi	s10,s10,24
ffffffffc020040c:	448040ef          	jal	ra,ffffffffc0204854 <strcmp>
ffffffffc0200410:	c919                	beqz	a0,ffffffffc0200426 <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200412:	2405                	addiw	s0,s0,1
ffffffffc0200414:	09740463          	beq	s0,s7,ffffffffc020049c <kmonitor+0x13e>
ffffffffc0200418:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020041c:	6582                	ld	a1,0(sp)
ffffffffc020041e:	0d61                	addi	s10,s10,24
ffffffffc0200420:	434040ef          	jal	ra,ffffffffc0204854 <strcmp>
ffffffffc0200424:	f57d                	bnez	a0,ffffffffc0200412 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200426:	00141793          	slli	a5,s0,0x1
ffffffffc020042a:	97a2                	add	a5,a5,s0
ffffffffc020042c:	078e                	slli	a5,a5,0x3
ffffffffc020042e:	97e6                	add	a5,a5,s9
ffffffffc0200430:	6b9c                	ld	a5,16(a5)
ffffffffc0200432:	8662                	mv	a2,s8
ffffffffc0200434:	002c                	addi	a1,sp,8
ffffffffc0200436:	fff4851b          	addiw	a0,s1,-1
ffffffffc020043a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020043c:	f8055ce3          	bgez	a0,ffffffffc02003d4 <kmonitor+0x76>
}
ffffffffc0200440:	60ee                	ld	ra,216(sp)
ffffffffc0200442:	644e                	ld	s0,208(sp)
ffffffffc0200444:	64ae                	ld	s1,200(sp)
ffffffffc0200446:	690e                	ld	s2,192(sp)
ffffffffc0200448:	79ea                	ld	s3,184(sp)
ffffffffc020044a:	7a4a                	ld	s4,176(sp)
ffffffffc020044c:	7aaa                	ld	s5,168(sp)
ffffffffc020044e:	7b0a                	ld	s6,160(sp)
ffffffffc0200450:	6bea                	ld	s7,152(sp)
ffffffffc0200452:	6c4a                	ld	s8,144(sp)
ffffffffc0200454:	6caa                	ld	s9,136(sp)
ffffffffc0200456:	6d0a                	ld	s10,128(sp)
ffffffffc0200458:	612d                	addi	sp,sp,224
ffffffffc020045a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020045c:	00044783          	lbu	a5,0(s0)
ffffffffc0200460:	dfc9                	beqz	a5,ffffffffc02003fa <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200462:	03448863          	beq	s1,s4,ffffffffc0200492 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc0200466:	00349793          	slli	a5,s1,0x3
ffffffffc020046a:	0118                	addi	a4,sp,128
ffffffffc020046c:	97ba                	add	a5,a5,a4
ffffffffc020046e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200472:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200476:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200478:	e591                	bnez	a1,ffffffffc0200484 <kmonitor+0x126>
ffffffffc020047a:	b749                	j	ffffffffc02003fc <kmonitor+0x9e>
            buf ++;
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047e:	00044583          	lbu	a1,0(s0)
ffffffffc0200482:	ddad                	beqz	a1,ffffffffc02003fc <kmonitor+0x9e>
ffffffffc0200484:	854a                	mv	a0,s2
ffffffffc0200486:	3f8040ef          	jal	ra,ffffffffc020487e <strchr>
ffffffffc020048a:	d96d                	beqz	a0,ffffffffc020047c <kmonitor+0x11e>
ffffffffc020048c:	00044583          	lbu	a1,0(s0)
ffffffffc0200490:	bf91                	j	ffffffffc02003e4 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200492:	45c1                	li	a1,16
ffffffffc0200494:	855a                	mv	a0,s6
ffffffffc0200496:	c3bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020049a:	b7f1                	j	ffffffffc0200466 <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020049c:	6582                	ld	a1,0(sp)
ffffffffc020049e:	00005517          	auipc	a0,0x5
ffffffffc02004a2:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0204f18 <commands+0xc8>
ffffffffc02004a6:	c2bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc02004aa:	b72d                	j	ffffffffc02003d4 <kmonitor+0x76>

ffffffffc02004ac <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004ac:	8082                	ret

ffffffffc02004ae <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004ae:	00253513          	sltiu	a0,a0,2
ffffffffc02004b2:	8082                	ret

ffffffffc02004b4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004b4:	03800513          	li	a0,56
ffffffffc02004b8:	8082                	ret

ffffffffc02004ba <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	0000a797          	auipc	a5,0xa
ffffffffc02004be:	fa678793          	addi	a5,a5,-90 # ffffffffc020a460 <ide>
ffffffffc02004c2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004c6:	1141                	addi	sp,sp,-16
ffffffffc02004c8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ca:	95be                	add	a1,a1,a5
ffffffffc02004cc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004d0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004d2:	3dc040ef          	jal	ra,ffffffffc02048ae <memcpy>
    return 0;
}
ffffffffc02004d6:	60a2                	ld	ra,8(sp)
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	0141                	addi	sp,sp,16
ffffffffc02004dc:	8082                	ret

ffffffffc02004de <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004de:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004e4:	0000a517          	auipc	a0,0xa
ffffffffc02004e8:	f7c50513          	addi	a0,a0,-132 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004ec:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ee:	00969613          	slli	a2,a3,0x9
ffffffffc02004f2:	85ba                	mv	a1,a4
ffffffffc02004f4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004f6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004f8:	3b6040ef          	jal	ra,ffffffffc02048ae <memcpy>
    return 0;
}
ffffffffc02004fc:	60a2                	ld	ra,8(sp)
ffffffffc02004fe:	4501                	li	a0,0
ffffffffc0200500:	0141                	addi	sp,sp,16
ffffffffc0200502:	8082                	ret

ffffffffc0200504 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200504:	67e1                	lui	a5,0x18
ffffffffc0200506:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020050a:	00015717          	auipc	a4,0x15
ffffffffc020050e:	f6f73723          	sd	a5,-146(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200512:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200516:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200518:	953e                	add	a0,a0,a5
ffffffffc020051a:	4601                	li	a2,0
ffffffffc020051c:	4881                	li	a7,0
ffffffffc020051e:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200522:	02000793          	li	a5,32
ffffffffc0200526:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020052a:	00005517          	auipc	a0,0x5
ffffffffc020052e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0204fd0 <commands+0x180>
    ticks = 0;
ffffffffc0200532:	00015797          	auipc	a5,0x15
ffffffffc0200536:	f807bf23          	sd	zero,-98(a5) # ffffffffc02154d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020053a:	be59                	j	ffffffffc02000d0 <cprintf>

ffffffffc020053c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200540:	00015797          	auipc	a5,0x15
ffffffffc0200544:	f3878793          	addi	a5,a5,-200 # ffffffffc0215478 <timebase>
ffffffffc0200548:	639c                	ld	a5,0(a5)
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	953e                	add	a0,a0,a5
ffffffffc0200550:	4881                	li	a7,0
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200558:	8082                	ret

ffffffffc020055a <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020055a:	100027f3          	csrr	a5,sstatus
ffffffffc020055e:	8b89                	andi	a5,a5,2
ffffffffc0200560:	0ff57513          	andi	a0,a0,255
ffffffffc0200564:	e799                	bnez	a5,ffffffffc0200572 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4885                	li	a7,1
ffffffffc020056c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200570:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200572:	1101                	addi	sp,sp,-32
ffffffffc0200574:	ec06                	sd	ra,24(sp)
ffffffffc0200576:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200578:	05a000ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc020057c:	6522                	ld	a0,8(sp)
ffffffffc020057e:	4581                	li	a1,0
ffffffffc0200580:	4601                	li	a2,0
ffffffffc0200582:	4885                	li	a7,1
ffffffffc0200584:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200588:	60e2                	ld	ra,24(sp)
ffffffffc020058a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020058c:	a081                	j	ffffffffc02005cc <intr_enable>

ffffffffc020058e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058e:	100027f3          	csrr	a5,sstatus
ffffffffc0200592:	8b89                	andi	a5,a5,2
ffffffffc0200594:	eb89                	bnez	a5,ffffffffc02005a6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200596:	4501                	li	a0,0
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4889                	li	a7,2
ffffffffc020059e:	00000073          	ecall
ffffffffc02005a2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005a4:	8082                	ret
int cons_getc(void) {
ffffffffc02005a6:	1101                	addi	sp,sp,-32
ffffffffc02005a8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005aa:	028000ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc02005ae:	4501                	li	a0,0
ffffffffc02005b0:	4581                	li	a1,0
ffffffffc02005b2:	4601                	li	a2,0
ffffffffc02005b4:	4889                	li	a7,2
ffffffffc02005b6:	00000073          	ecall
ffffffffc02005ba:	2501                	sext.w	a0,a0
ffffffffc02005bc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005be:	00e000ef          	jal	ra,ffffffffc02005cc <intr_enable>
}
ffffffffc02005c2:	60e2                	ld	ra,24(sp)
ffffffffc02005c4:	6522                	ld	a0,8(sp)
ffffffffc02005c6:	6105                	addi	sp,sp,32
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005ca:	8082                	ret

ffffffffc02005cc <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005cc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d8:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	1141                	addi	sp,sp,-16
ffffffffc02005de:	e022                	sd	s0,0(sp)
ffffffffc02005e0:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e2:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e6:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005e8:	11053583          	ld	a1,272(a0)
ffffffffc02005ec:	05500613          	li	a2,85
ffffffffc02005f0:	c399                	beqz	a5,ffffffffc02005f6 <pgfault_handler+0x1e>
ffffffffc02005f2:	04b00613          	li	a2,75
ffffffffc02005f6:	11843703          	ld	a4,280(s0)
ffffffffc02005fa:	47bd                	li	a5,15
ffffffffc02005fc:	05700693          	li	a3,87
ffffffffc0200600:	00f70463          	beq	a4,a5,ffffffffc0200608 <pgfault_handler+0x30>
ffffffffc0200604:	05200693          	li	a3,82
ffffffffc0200608:	00005517          	auipc	a0,0x5
ffffffffc020060c:	cc050513          	addi	a0,a0,-832 # ffffffffc02052c8 <commands+0x478>
ffffffffc0200610:	ac1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200614:	00015797          	auipc	a5,0x15
ffffffffc0200618:	ee478793          	addi	a5,a5,-284 # ffffffffc02154f8 <check_mm_struct>
ffffffffc020061c:	6388                	ld	a0,0(a5)
ffffffffc020061e:	c911                	beqz	a0,ffffffffc0200632 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200620:	11043603          	ld	a2,272(s0)
ffffffffc0200624:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200628:	6402                	ld	s0,0(sp)
ffffffffc020062a:	60a2                	ld	ra,8(sp)
ffffffffc020062c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020062e:	41f0106f          	j	ffffffffc020224c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200632:	00005617          	auipc	a2,0x5
ffffffffc0200636:	cb660613          	addi	a2,a2,-842 # ffffffffc02052e8 <commands+0x498>
ffffffffc020063a:	06200593          	li	a1,98
ffffffffc020063e:	00005517          	auipc	a0,0x5
ffffffffc0200642:	cc250513          	addi	a0,a0,-830 # ffffffffc0205300 <commands+0x4b0>
ffffffffc0200646:	b8fff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020064a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020064a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020064e:	00000797          	auipc	a5,0x0
ffffffffc0200652:	48278793          	addi	a5,a5,1154 # ffffffffc0200ad0 <__alltraps>
ffffffffc0200656:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065a:	000407b7          	lui	a5,0x40
ffffffffc020065e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200662:	8082                	ret

ffffffffc0200664 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200664:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200666:	1141                	addi	sp,sp,-16
ffffffffc0200668:	e022                	sd	s0,0(sp)
ffffffffc020066a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	cac50513          	addi	a0,a0,-852 # ffffffffc0205318 <commands+0x4c8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200674:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200676:	a5bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067a:	640c                	ld	a1,8(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	cb450513          	addi	a0,a0,-844 # ffffffffc0205330 <commands+0x4e0>
ffffffffc0200684:	a4dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200688:	680c                	ld	a1,16(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0205348 <commands+0x4f8>
ffffffffc0200692:	a3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200696:	6c0c                	ld	a1,24(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	cc850513          	addi	a0,a0,-824 # ffffffffc0205360 <commands+0x510>
ffffffffc02006a0:	a31ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a4:	700c                	ld	a1,32(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	cd250513          	addi	a0,a0,-814 # ffffffffc0205378 <commands+0x528>
ffffffffc02006ae:	a23ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b2:	740c                	ld	a1,40(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205390 <commands+0x540>
ffffffffc02006bc:	a15ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c0:	780c                	ld	a1,48(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	ce650513          	addi	a0,a0,-794 # ffffffffc02053a8 <commands+0x558>
ffffffffc02006ca:	a07ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ce:	7c0c                	ld	a1,56(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	cf050513          	addi	a0,a0,-784 # ffffffffc02053c0 <commands+0x570>
ffffffffc02006d8:	9f9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006dc:	602c                	ld	a1,64(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	cfa50513          	addi	a0,a0,-774 # ffffffffc02053d8 <commands+0x588>
ffffffffc02006e6:	9ebff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ea:	642c                	ld	a1,72(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	d0450513          	addi	a0,a0,-764 # ffffffffc02053f0 <commands+0x5a0>
ffffffffc02006f4:	9ddff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f8:	682c                	ld	a1,80(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	d0e50513          	addi	a0,a0,-754 # ffffffffc0205408 <commands+0x5b8>
ffffffffc0200702:	9cfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200706:	6c2c                	ld	a1,88(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	d1850513          	addi	a0,a0,-744 # ffffffffc0205420 <commands+0x5d0>
ffffffffc0200710:	9c1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200714:	702c                	ld	a1,96(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	d2250513          	addi	a0,a0,-734 # ffffffffc0205438 <commands+0x5e8>
ffffffffc020071e:	9b3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200722:	742c                	ld	a1,104(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205450 <commands+0x600>
ffffffffc020072c:	9a5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200730:	782c                	ld	a1,112(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	d3650513          	addi	a0,a0,-714 # ffffffffc0205468 <commands+0x618>
ffffffffc020073a:	997ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073e:	7c2c                	ld	a1,120(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	d4050513          	addi	a0,a0,-704 # ffffffffc0205480 <commands+0x630>
ffffffffc0200748:	989ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074c:	604c                	ld	a1,128(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	d4a50513          	addi	a0,a0,-694 # ffffffffc0205498 <commands+0x648>
ffffffffc0200756:	97bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075a:	644c                	ld	a1,136(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	d5450513          	addi	a0,a0,-684 # ffffffffc02054b0 <commands+0x660>
ffffffffc0200764:	96dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200768:	684c                	ld	a1,144(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	d5e50513          	addi	a0,a0,-674 # ffffffffc02054c8 <commands+0x678>
ffffffffc0200772:	95fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200776:	6c4c                	ld	a1,152(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	d6850513          	addi	a0,a0,-664 # ffffffffc02054e0 <commands+0x690>
ffffffffc0200780:	951ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200784:	704c                	ld	a1,160(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	d7250513          	addi	a0,a0,-654 # ffffffffc02054f8 <commands+0x6a8>
ffffffffc020078e:	943ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200792:	744c                	ld	a1,168(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	d7c50513          	addi	a0,a0,-644 # ffffffffc0205510 <commands+0x6c0>
ffffffffc020079c:	935ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a0:	784c                	ld	a1,176(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	d8650513          	addi	a0,a0,-634 # ffffffffc0205528 <commands+0x6d8>
ffffffffc02007aa:	927ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ae:	7c4c                	ld	a1,184(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	d9050513          	addi	a0,a0,-624 # ffffffffc0205540 <commands+0x6f0>
ffffffffc02007b8:	919ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007bc:	606c                	ld	a1,192(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	d9a50513          	addi	a0,a0,-614 # ffffffffc0205558 <commands+0x708>
ffffffffc02007c6:	90bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ca:	646c                	ld	a1,200(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	da450513          	addi	a0,a0,-604 # ffffffffc0205570 <commands+0x720>
ffffffffc02007d4:	8fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d8:	686c                	ld	a1,208(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	dae50513          	addi	a0,a0,-594 # ffffffffc0205588 <commands+0x738>
ffffffffc02007e2:	8efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e6:	6c6c                	ld	a1,216(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	db850513          	addi	a0,a0,-584 # ffffffffc02055a0 <commands+0x750>
ffffffffc02007f0:	8e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f4:	706c                	ld	a1,224(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	dc250513          	addi	a0,a0,-574 # ffffffffc02055b8 <commands+0x768>
ffffffffc02007fe:	8d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200802:	746c                	ld	a1,232(s0)
ffffffffc0200804:	00005517          	auipc	a0,0x5
ffffffffc0200808:	dcc50513          	addi	a0,a0,-564 # ffffffffc02055d0 <commands+0x780>
ffffffffc020080c:	8c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200810:	786c                	ld	a1,240(s0)
ffffffffc0200812:	00005517          	auipc	a0,0x5
ffffffffc0200816:	dd650513          	addi	a0,a0,-554 # ffffffffc02055e8 <commands+0x798>
ffffffffc020081a:	8b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200820:	6402                	ld	s0,0(sp)
ffffffffc0200822:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200824:	00005517          	auipc	a0,0x5
ffffffffc0200828:	ddc50513          	addi	a0,a0,-548 # ffffffffc0205600 <commands+0x7b0>
}
ffffffffc020082c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	8a3ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200832 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200832:	1141                	addi	sp,sp,-16
ffffffffc0200834:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200836:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200838:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	00005517          	auipc	a0,0x5
ffffffffc020083e:	dde50513          	addi	a0,a0,-546 # ffffffffc0205618 <commands+0x7c8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200844:	88dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200848:	8522                	mv	a0,s0
ffffffffc020084a:	e1bff0ef          	jal	ra,ffffffffc0200664 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084e:	10043583          	ld	a1,256(s0)
ffffffffc0200852:	00005517          	auipc	a0,0x5
ffffffffc0200856:	dde50513          	addi	a0,a0,-546 # ffffffffc0205630 <commands+0x7e0>
ffffffffc020085a:	877ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085e:	10843583          	ld	a1,264(s0)
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	de650513          	addi	a0,a0,-538 # ffffffffc0205648 <commands+0x7f8>
ffffffffc020086a:	867ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020086e:	11043583          	ld	a1,272(s0)
ffffffffc0200872:	00005517          	auipc	a0,0x5
ffffffffc0200876:	dee50513          	addi	a0,a0,-530 # ffffffffc0205660 <commands+0x810>
ffffffffc020087a:	857ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200882:	6402                	ld	s0,0(sp)
ffffffffc0200884:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	00005517          	auipc	a0,0x5
ffffffffc020088a:	df250513          	addi	a0,a0,-526 # ffffffffc0205678 <commands+0x828>
}
ffffffffc020088e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200890:	841ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200894 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200894:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc0200898:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089a:	0786                	slli	a5,a5,0x1
ffffffffc020089c:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc020089e:	06f76f63          	bltu	a4,a5,ffffffffc020091c <interrupt_handler+0x88>
ffffffffc02008a2:	00004717          	auipc	a4,0x4
ffffffffc02008a6:	74a70713          	addi	a4,a4,1866 # ffffffffc0204fec <commands+0x19c>
ffffffffc02008aa:	078a                	slli	a5,a5,0x2
ffffffffc02008ac:	97ba                	add	a5,a5,a4
ffffffffc02008ae:	439c                	lw	a5,0(a5)
ffffffffc02008b0:	97ba                	add	a5,a5,a4
ffffffffc02008b2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008b4:	00005517          	auipc	a0,0x5
ffffffffc02008b8:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205278 <commands+0x428>
ffffffffc02008bc:	815ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008c0:	00005517          	auipc	a0,0x5
ffffffffc02008c4:	99850513          	addi	a0,a0,-1640 # ffffffffc0205258 <commands+0x408>
ffffffffc02008c8:	809ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008cc:	00005517          	auipc	a0,0x5
ffffffffc02008d0:	94c50513          	addi	a0,a0,-1716 # ffffffffc0205218 <commands+0x3c8>
ffffffffc02008d4:	ffcff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008d8:	00005517          	auipc	a0,0x5
ffffffffc02008dc:	96050513          	addi	a0,a0,-1696 # ffffffffc0205238 <commands+0x3e8>
ffffffffc02008e0:	ff0ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008e4:	00005517          	auipc	a0,0x5
ffffffffc02008e8:	9c450513          	addi	a0,a0,-1596 # ffffffffc02052a8 <commands+0x458>
ffffffffc02008ec:	fe4ff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008f0:	1141                	addi	sp,sp,-16
ffffffffc02008f2:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008f4:	c49ff0ef          	jal	ra,ffffffffc020053c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008f8:	00015797          	auipc	a5,0x15
ffffffffc02008fc:	bd878793          	addi	a5,a5,-1064 # ffffffffc02154d0 <ticks>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	06400713          	li	a4,100
ffffffffc0200906:	0785                	addi	a5,a5,1
ffffffffc0200908:	02e7f733          	remu	a4,a5,a4
ffffffffc020090c:	00015697          	auipc	a3,0x15
ffffffffc0200910:	bcf6b223          	sd	a5,-1084(a3) # ffffffffc02154d0 <ticks>
ffffffffc0200914:	c709                	beqz	a4,ffffffffc020091e <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200916:	60a2                	ld	ra,8(sp)
ffffffffc0200918:	0141                	addi	sp,sp,16
ffffffffc020091a:	8082                	ret
            print_trapframe(tf);
ffffffffc020091c:	bf19                	j	ffffffffc0200832 <print_trapframe>
}
ffffffffc020091e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200920:	06400593          	li	a1,100
ffffffffc0200924:	00005517          	auipc	a0,0x5
ffffffffc0200928:	97450513          	addi	a0,a0,-1676 # ffffffffc0205298 <commands+0x448>
}
ffffffffc020092c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092e:	fa2ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200932 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200932:	11853783          	ld	a5,280(a0)
ffffffffc0200936:	473d                	li	a4,15
ffffffffc0200938:	16f76463          	bltu	a4,a5,ffffffffc0200aa0 <exception_handler+0x16e>
ffffffffc020093c:	00004717          	auipc	a4,0x4
ffffffffc0200940:	6e070713          	addi	a4,a4,1760 # ffffffffc020501c <commands+0x1cc>
ffffffffc0200944:	078a                	slli	a5,a5,0x2
ffffffffc0200946:	97ba                	add	a5,a5,a4
ffffffffc0200948:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020094a:	1101                	addi	sp,sp,-32
ffffffffc020094c:	e822                	sd	s0,16(sp)
ffffffffc020094e:	ec06                	sd	ra,24(sp)
ffffffffc0200950:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200952:	97ba                	add	a5,a5,a4
ffffffffc0200954:	842a                	mv	s0,a0
ffffffffc0200956:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200958:	00005517          	auipc	a0,0x5
ffffffffc020095c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0205200 <commands+0x3b0>
ffffffffc0200960:	f70ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200964:	8522                	mv	a0,s0
ffffffffc0200966:	c73ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc020096a:	84aa                	mv	s1,a0
ffffffffc020096c:	12051b63          	bnez	a0,ffffffffc0200aa2 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200970:	60e2                	ld	ra,24(sp)
ffffffffc0200972:	6442                	ld	s0,16(sp)
ffffffffc0200974:	64a2                	ld	s1,8(sp)
ffffffffc0200976:	6105                	addi	sp,sp,32
ffffffffc0200978:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	6e650513          	addi	a0,a0,1766 # ffffffffc0205060 <commands+0x210>
}
ffffffffc0200982:	6442                	ld	s0,16(sp)
ffffffffc0200984:	60e2                	ld	ra,24(sp)
ffffffffc0200986:	64a2                	ld	s1,8(sp)
ffffffffc0200988:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020098a:	f46ff06f          	j	ffffffffc02000d0 <cprintf>
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	6f250513          	addi	a0,a0,1778 # ffffffffc0205080 <commands+0x230>
ffffffffc0200996:	b7f5                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	70850513          	addi	a0,a0,1800 # ffffffffc02050a0 <commands+0x250>
ffffffffc02009a0:	b7cd                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009a2:	00004517          	auipc	a0,0x4
ffffffffc02009a6:	71650513          	addi	a0,a0,1814 # ffffffffc02050b8 <commands+0x268>
ffffffffc02009aa:	bfe1                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009ac:	00004517          	auipc	a0,0x4
ffffffffc02009b0:	71c50513          	addi	a0,a0,1820 # ffffffffc02050c8 <commands+0x278>
ffffffffc02009b4:	b7f9                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009b6:	00004517          	auipc	a0,0x4
ffffffffc02009ba:	73250513          	addi	a0,a0,1842 # ffffffffc02050e8 <commands+0x298>
ffffffffc02009be:	f12ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c2:	8522                	mv	a0,s0
ffffffffc02009c4:	c15ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc02009c8:	84aa                	mv	s1,a0
ffffffffc02009ca:	d15d                	beqz	a0,ffffffffc0200970 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009cc:	8522                	mv	a0,s0
ffffffffc02009ce:	e65ff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d2:	86a6                	mv	a3,s1
ffffffffc02009d4:	00004617          	auipc	a2,0x4
ffffffffc02009d8:	72c60613          	addi	a2,a2,1836 # ffffffffc0205100 <commands+0x2b0>
ffffffffc02009dc:	0b300593          	li	a1,179
ffffffffc02009e0:	00005517          	auipc	a0,0x5
ffffffffc02009e4:	92050513          	addi	a0,a0,-1760 # ffffffffc0205300 <commands+0x4b0>
ffffffffc02009e8:	fecff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009ec:	00004517          	auipc	a0,0x4
ffffffffc02009f0:	73450513          	addi	a0,a0,1844 # ffffffffc0205120 <commands+0x2d0>
ffffffffc02009f4:	b779                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009f6:	00004517          	auipc	a0,0x4
ffffffffc02009fa:	74250513          	addi	a0,a0,1858 # ffffffffc0205138 <commands+0x2e8>
ffffffffc02009fe:	ed2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a02:	8522                	mv	a0,s0
ffffffffc0200a04:	bd5ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a08:	84aa                	mv	s1,a0
ffffffffc0200a0a:	d13d                	beqz	a0,ffffffffc0200970 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a0c:	8522                	mv	a0,s0
ffffffffc0200a0e:	e25ff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a12:	86a6                	mv	a3,s1
ffffffffc0200a14:	00004617          	auipc	a2,0x4
ffffffffc0200a18:	6ec60613          	addi	a2,a2,1772 # ffffffffc0205100 <commands+0x2b0>
ffffffffc0200a1c:	0bd00593          	li	a1,189
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205300 <commands+0x4b0>
ffffffffc0200a28:	facff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a2c:	00004517          	auipc	a0,0x4
ffffffffc0200a30:	72450513          	addi	a0,a0,1828 # ffffffffc0205150 <commands+0x300>
ffffffffc0200a34:	b7b9                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a36:	00004517          	auipc	a0,0x4
ffffffffc0200a3a:	73a50513          	addi	a0,a0,1850 # ffffffffc0205170 <commands+0x320>
ffffffffc0200a3e:	b791                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a40:	00004517          	auipc	a0,0x4
ffffffffc0200a44:	75050513          	addi	a0,a0,1872 # ffffffffc0205190 <commands+0x340>
ffffffffc0200a48:	bf2d                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a4a:	00004517          	auipc	a0,0x4
ffffffffc0200a4e:	76650513          	addi	a0,a0,1894 # ffffffffc02051b0 <commands+0x360>
ffffffffc0200a52:	bf05                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a54:	00004517          	auipc	a0,0x4
ffffffffc0200a58:	77c50513          	addi	a0,a0,1916 # ffffffffc02051d0 <commands+0x380>
ffffffffc0200a5c:	b71d                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a5e:	00004517          	auipc	a0,0x4
ffffffffc0200a62:	78a50513          	addi	a0,a0,1930 # ffffffffc02051e8 <commands+0x398>
ffffffffc0200a66:	e6aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a6a:	8522                	mv	a0,s0
ffffffffc0200a6c:	b6dff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a70:	84aa                	mv	s1,a0
ffffffffc0200a72:	ee050fe3          	beqz	a0,ffffffffc0200970 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a76:	8522                	mv	a0,s0
ffffffffc0200a78:	dbbff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a7c:	86a6                	mv	a3,s1
ffffffffc0200a7e:	00004617          	auipc	a2,0x4
ffffffffc0200a82:	68260613          	addi	a2,a2,1666 # ffffffffc0205100 <commands+0x2b0>
ffffffffc0200a86:	0d300593          	li	a1,211
ffffffffc0200a8a:	00005517          	auipc	a0,0x5
ffffffffc0200a8e:	87650513          	addi	a0,a0,-1930 # ffffffffc0205300 <commands+0x4b0>
ffffffffc0200a92:	f42ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
}
ffffffffc0200a96:	6442                	ld	s0,16(sp)
ffffffffc0200a98:	60e2                	ld	ra,24(sp)
ffffffffc0200a9a:	64a2                	ld	s1,8(sp)
ffffffffc0200a9c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a9e:	bb51                	j	ffffffffc0200832 <print_trapframe>
ffffffffc0200aa0:	bb49                	j	ffffffffc0200832 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200aa2:	8522                	mv	a0,s0
ffffffffc0200aa4:	d8fff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aa8:	86a6                	mv	a3,s1
ffffffffc0200aaa:	00004617          	auipc	a2,0x4
ffffffffc0200aae:	65660613          	addi	a2,a2,1622 # ffffffffc0205100 <commands+0x2b0>
ffffffffc0200ab2:	0da00593          	li	a1,218
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	84a50513          	addi	a0,a0,-1974 # ffffffffc0205300 <commands+0x4b0>
ffffffffc0200abe:	f16ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200ac2 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ac2:	11853783          	ld	a5,280(a0)
ffffffffc0200ac6:	0007c363          	bltz	a5,ffffffffc0200acc <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200aca:	b5a5                	j	ffffffffc0200932 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200acc:	b3e1                	j	ffffffffc0200894 <interrupt_handler>
	...

ffffffffc0200ad0 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ad0:	14011073          	csrw	sscratch,sp
ffffffffc0200ad4:	712d                	addi	sp,sp,-288
ffffffffc0200ad6:	e406                	sd	ra,8(sp)
ffffffffc0200ad8:	ec0e                	sd	gp,24(sp)
ffffffffc0200ada:	f012                	sd	tp,32(sp)
ffffffffc0200adc:	f416                	sd	t0,40(sp)
ffffffffc0200ade:	f81a                	sd	t1,48(sp)
ffffffffc0200ae0:	fc1e                	sd	t2,56(sp)
ffffffffc0200ae2:	e0a2                	sd	s0,64(sp)
ffffffffc0200ae4:	e4a6                	sd	s1,72(sp)
ffffffffc0200ae6:	e8aa                	sd	a0,80(sp)
ffffffffc0200ae8:	ecae                	sd	a1,88(sp)
ffffffffc0200aea:	f0b2                	sd	a2,96(sp)
ffffffffc0200aec:	f4b6                	sd	a3,104(sp)
ffffffffc0200aee:	f8ba                	sd	a4,112(sp)
ffffffffc0200af0:	fcbe                	sd	a5,120(sp)
ffffffffc0200af2:	e142                	sd	a6,128(sp)
ffffffffc0200af4:	e546                	sd	a7,136(sp)
ffffffffc0200af6:	e94a                	sd	s2,144(sp)
ffffffffc0200af8:	ed4e                	sd	s3,152(sp)
ffffffffc0200afa:	f152                	sd	s4,160(sp)
ffffffffc0200afc:	f556                	sd	s5,168(sp)
ffffffffc0200afe:	f95a                	sd	s6,176(sp)
ffffffffc0200b00:	fd5e                	sd	s7,184(sp)
ffffffffc0200b02:	e1e2                	sd	s8,192(sp)
ffffffffc0200b04:	e5e6                	sd	s9,200(sp)
ffffffffc0200b06:	e9ea                	sd	s10,208(sp)
ffffffffc0200b08:	edee                	sd	s11,216(sp)
ffffffffc0200b0a:	f1f2                	sd	t3,224(sp)
ffffffffc0200b0c:	f5f6                	sd	t4,232(sp)
ffffffffc0200b0e:	f9fa                	sd	t5,240(sp)
ffffffffc0200b10:	fdfe                	sd	t6,248(sp)
ffffffffc0200b12:	14002473          	csrr	s0,sscratch
ffffffffc0200b16:	100024f3          	csrr	s1,sstatus
ffffffffc0200b1a:	14102973          	csrr	s2,sepc
ffffffffc0200b1e:	143029f3          	csrr	s3,stval
ffffffffc0200b22:	14202a73          	csrr	s4,scause
ffffffffc0200b26:	e822                	sd	s0,16(sp)
ffffffffc0200b28:	e226                	sd	s1,256(sp)
ffffffffc0200b2a:	e64a                	sd	s2,264(sp)
ffffffffc0200b2c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b2e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b30:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b32:	f91ff0ef          	jal	ra,ffffffffc0200ac2 <trap>

ffffffffc0200b36 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b36:	6492                	ld	s1,256(sp)
ffffffffc0200b38:	6932                	ld	s2,264(sp)
ffffffffc0200b3a:	10049073          	csrw	sstatus,s1
ffffffffc0200b3e:	14191073          	csrw	sepc,s2
ffffffffc0200b42:	60a2                	ld	ra,8(sp)
ffffffffc0200b44:	61e2                	ld	gp,24(sp)
ffffffffc0200b46:	7202                	ld	tp,32(sp)
ffffffffc0200b48:	72a2                	ld	t0,40(sp)
ffffffffc0200b4a:	7342                	ld	t1,48(sp)
ffffffffc0200b4c:	73e2                	ld	t2,56(sp)
ffffffffc0200b4e:	6406                	ld	s0,64(sp)
ffffffffc0200b50:	64a6                	ld	s1,72(sp)
ffffffffc0200b52:	6546                	ld	a0,80(sp)
ffffffffc0200b54:	65e6                	ld	a1,88(sp)
ffffffffc0200b56:	7606                	ld	a2,96(sp)
ffffffffc0200b58:	76a6                	ld	a3,104(sp)
ffffffffc0200b5a:	7746                	ld	a4,112(sp)
ffffffffc0200b5c:	77e6                	ld	a5,120(sp)
ffffffffc0200b5e:	680a                	ld	a6,128(sp)
ffffffffc0200b60:	68aa                	ld	a7,136(sp)
ffffffffc0200b62:	694a                	ld	s2,144(sp)
ffffffffc0200b64:	69ea                	ld	s3,152(sp)
ffffffffc0200b66:	7a0a                	ld	s4,160(sp)
ffffffffc0200b68:	7aaa                	ld	s5,168(sp)
ffffffffc0200b6a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b6c:	7bea                	ld	s7,184(sp)
ffffffffc0200b6e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b70:	6cae                	ld	s9,200(sp)
ffffffffc0200b72:	6d4e                	ld	s10,208(sp)
ffffffffc0200b74:	6dee                	ld	s11,216(sp)
ffffffffc0200b76:	7e0e                	ld	t3,224(sp)
ffffffffc0200b78:	7eae                	ld	t4,232(sp)
ffffffffc0200b7a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b7c:	7fee                	ld	t6,248(sp)
ffffffffc0200b7e:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b80:	10200073          	sret

ffffffffc0200b84 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b84:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b86:	bf45                	j	ffffffffc0200b36 <__trapret>
	...

ffffffffc0200b8a <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200b8a:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200b8c:	00005617          	auipc	a2,0x5
ffffffffc0200b90:	b3c60613          	addi	a2,a2,-1220 # ffffffffc02056c8 <commands+0x878>
ffffffffc0200b94:	06200593          	li	a1,98
ffffffffc0200b98:	00005517          	auipc	a0,0x5
ffffffffc0200b9c:	b5050513          	addi	a0,a0,-1200 # ffffffffc02056e8 <commands+0x898>
pa2page(uintptr_t pa) {
ffffffffc0200ba0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ba2:	e32ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200ba6 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200ba6:	715d                	addi	sp,sp,-80
ffffffffc0200ba8:	e0a2                	sd	s0,64(sp)
ffffffffc0200baa:	fc26                	sd	s1,56(sp)
ffffffffc0200bac:	f84a                	sd	s2,48(sp)
ffffffffc0200bae:	f44e                	sd	s3,40(sp)
ffffffffc0200bb0:	f052                	sd	s4,32(sp)
ffffffffc0200bb2:	ec56                	sd	s5,24(sp)
ffffffffc0200bb4:	e486                	sd	ra,72(sp)
ffffffffc0200bb6:	842a                	mv	s0,a0
ffffffffc0200bb8:	00015497          	auipc	s1,0x15
ffffffffc0200bbc:	92048493          	addi	s1,s1,-1760 # ffffffffc02154d8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bc0:	4985                	li	s3,1
ffffffffc0200bc2:	00015a17          	auipc	s4,0x15
ffffffffc0200bc6:	8e6a0a13          	addi	s4,s4,-1818 # ffffffffc02154a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bca:	0005091b          	sext.w	s2,a0
ffffffffc0200bce:	00015a97          	auipc	s5,0x15
ffffffffc0200bd2:	92aa8a93          	addi	s5,s5,-1750 # ffffffffc02154f8 <check_mm_struct>
ffffffffc0200bd6:	a00d                	j	ffffffffc0200bf8 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bd8:	609c                	ld	a5,0(s1)
ffffffffc0200bda:	6f9c                	ld	a5,24(a5)
ffffffffc0200bdc:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bde:	4601                	li	a2,0
ffffffffc0200be0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200be2:	ed0d                	bnez	a0,ffffffffc0200c1c <alloc_pages+0x76>
ffffffffc0200be4:	0289ec63          	bltu	s3,s0,ffffffffc0200c1c <alloc_pages+0x76>
ffffffffc0200be8:	000a2783          	lw	a5,0(s4)
ffffffffc0200bec:	2781                	sext.w	a5,a5
ffffffffc0200bee:	c79d                	beqz	a5,ffffffffc0200c1c <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bf0:	000ab503          	ld	a0,0(s5)
ffffffffc0200bf4:	34e020ef          	jal	ra,ffffffffc0202f42 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bf8:	100027f3          	csrr	a5,sstatus
ffffffffc0200bfc:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bfe:	8522                	mv	a0,s0
ffffffffc0200c00:	dfe1                	beqz	a5,ffffffffc0200bd8 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200c02:	9d1ff0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc0200c06:	609c                	ld	a5,0(s1)
ffffffffc0200c08:	8522                	mv	a0,s0
ffffffffc0200c0a:	6f9c                	ld	a5,24(a5)
ffffffffc0200c0c:	9782                	jalr	a5
ffffffffc0200c0e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200c10:	9bdff0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0200c14:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c16:	4601                	li	a2,0
ffffffffc0200c18:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c1a:	d569                	beqz	a0,ffffffffc0200be4 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200c1c:	60a6                	ld	ra,72(sp)
ffffffffc0200c1e:	6406                	ld	s0,64(sp)
ffffffffc0200c20:	74e2                	ld	s1,56(sp)
ffffffffc0200c22:	7942                	ld	s2,48(sp)
ffffffffc0200c24:	79a2                	ld	s3,40(sp)
ffffffffc0200c26:	7a02                	ld	s4,32(sp)
ffffffffc0200c28:	6ae2                	ld	s5,24(sp)
ffffffffc0200c2a:	6161                	addi	sp,sp,80
ffffffffc0200c2c:	8082                	ret

ffffffffc0200c2e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c2e:	100027f3          	csrr	a5,sstatus
ffffffffc0200c32:	8b89                	andi	a5,a5,2
ffffffffc0200c34:	eb89                	bnez	a5,ffffffffc0200c46 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200c36:	00015797          	auipc	a5,0x15
ffffffffc0200c3a:	8a278793          	addi	a5,a5,-1886 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c3e:	639c                	ld	a5,0(a5)
ffffffffc0200c40:	0207b303          	ld	t1,32(a5)
ffffffffc0200c44:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200c46:	1101                	addi	sp,sp,-32
ffffffffc0200c48:	ec06                	sd	ra,24(sp)
ffffffffc0200c4a:	e822                	sd	s0,16(sp)
ffffffffc0200c4c:	e426                	sd	s1,8(sp)
ffffffffc0200c4e:	842a                	mv	s0,a0
ffffffffc0200c50:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200c52:	981ff0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200c56:	00015797          	auipc	a5,0x15
ffffffffc0200c5a:	88278793          	addi	a5,a5,-1918 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c5e:	639c                	ld	a5,0(a5)
ffffffffc0200c60:	85a6                	mv	a1,s1
ffffffffc0200c62:	8522                	mv	a0,s0
ffffffffc0200c64:	739c                	ld	a5,32(a5)
ffffffffc0200c66:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	60e2                	ld	ra,24(sp)
ffffffffc0200c6c:	64a2                	ld	s1,8(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200c70:	95dff06f          	j	ffffffffc02005cc <intr_enable>

ffffffffc0200c74 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c74:	100027f3          	csrr	a5,sstatus
ffffffffc0200c78:	8b89                	andi	a5,a5,2
ffffffffc0200c7a:	eb89                	bnez	a5,ffffffffc0200c8c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c7c:	00015797          	auipc	a5,0x15
ffffffffc0200c80:	85c78793          	addi	a5,a5,-1956 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c84:	639c                	ld	a5,0(a5)
ffffffffc0200c86:	0287b303          	ld	t1,40(a5)
ffffffffc0200c8a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200c8c:	1141                	addi	sp,sp,-16
ffffffffc0200c8e:	e406                	sd	ra,8(sp)
ffffffffc0200c90:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200c92:	941ff0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c96:	00015797          	auipc	a5,0x15
ffffffffc0200c9a:	84278793          	addi	a5,a5,-1982 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c9e:	639c                	ld	a5,0(a5)
ffffffffc0200ca0:	779c                	ld	a5,40(a5)
ffffffffc0200ca2:	9782                	jalr	a5
ffffffffc0200ca4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200ca6:	927ff0ef          	jal	ra,ffffffffc02005cc <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200caa:	8522                	mv	a0,s0
ffffffffc0200cac:	60a2                	ld	ra,8(sp)
ffffffffc0200cae:	6402                	ld	s0,0(sp)
ffffffffc0200cb0:	0141                	addi	sp,sp,16
ffffffffc0200cb2:	8082                	ret

ffffffffc0200cb4 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cb4:	7139                	addi	sp,sp,-64
ffffffffc0200cb6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200cb8:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200cbc:	1ff4f493          	andi	s1,s1,511
ffffffffc0200cc0:	048e                	slli	s1,s1,0x3
ffffffffc0200cc2:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cc4:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cc6:	f04a                	sd	s2,32(sp)
ffffffffc0200cc8:	ec4e                	sd	s3,24(sp)
ffffffffc0200cca:	e852                	sd	s4,16(sp)
ffffffffc0200ccc:	fc06                	sd	ra,56(sp)
ffffffffc0200cce:	f822                	sd	s0,48(sp)
ffffffffc0200cd0:	e456                	sd	s5,8(sp)
ffffffffc0200cd2:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cd4:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cd8:	892e                	mv	s2,a1
ffffffffc0200cda:	8a32                	mv	s4,a2
ffffffffc0200cdc:	00014997          	auipc	s3,0x14
ffffffffc0200ce0:	7ac98993          	addi	s3,s3,1964 # ffffffffc0215488 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200ce4:	e7bd                	bnez	a5,ffffffffc0200d52 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200ce6:	12060c63          	beqz	a2,ffffffffc0200e1e <get_pte+0x16a>
ffffffffc0200cea:	4505                	li	a0,1
ffffffffc0200cec:	ebbff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0200cf0:	842a                	mv	s0,a0
ffffffffc0200cf2:	12050663          	beqz	a0,ffffffffc0200e1e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200cf6:	00014b17          	auipc	s6,0x14
ffffffffc0200cfa:	7fab0b13          	addi	s6,s6,2042 # ffffffffc02154f0 <pages>
ffffffffc0200cfe:	000b3503          	ld	a0,0(s6)
ffffffffc0200d02:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d06:	00014997          	auipc	s3,0x14
ffffffffc0200d0a:	78298993          	addi	s3,s3,1922 # ffffffffc0215488 <npage>
ffffffffc0200d0e:	40a40533          	sub	a0,s0,a0
ffffffffc0200d12:	8519                	srai	a0,a0,0x6
ffffffffc0200d14:	9556                	add	a0,a0,s5
ffffffffc0200d16:	0009b703          	ld	a4,0(s3)
ffffffffc0200d1a:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200d1e:	4685                	li	a3,1
ffffffffc0200d20:	c014                	sw	a3,0(s0)
ffffffffc0200d22:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d24:	0532                	slli	a0,a0,0xc
ffffffffc0200d26:	14e7f363          	bgeu	a5,a4,ffffffffc0200e6c <get_pte+0x1b8>
ffffffffc0200d2a:	00014797          	auipc	a5,0x14
ffffffffc0200d2e:	7b678793          	addi	a5,a5,1974 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0200d32:	639c                	ld	a5,0(a5)
ffffffffc0200d34:	6605                	lui	a2,0x1
ffffffffc0200d36:	4581                	li	a1,0
ffffffffc0200d38:	953e                	add	a0,a0,a5
ffffffffc0200d3a:	363030ef          	jal	ra,ffffffffc020489c <memset>
    return page - pages + nbase;
ffffffffc0200d3e:	000b3683          	ld	a3,0(s6)
ffffffffc0200d42:	40d406b3          	sub	a3,s0,a3
ffffffffc0200d46:	8699                	srai	a3,a3,0x6
ffffffffc0200d48:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d4a:	06aa                	slli	a3,a3,0xa
ffffffffc0200d4c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d50:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d52:	77fd                	lui	a5,0xfffff
ffffffffc0200d54:	068a                	slli	a3,a3,0x2
ffffffffc0200d56:	0009b703          	ld	a4,0(s3)
ffffffffc0200d5a:	8efd                	and	a3,a3,a5
ffffffffc0200d5c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d60:	0ce7f163          	bgeu	a5,a4,ffffffffc0200e22 <get_pte+0x16e>
ffffffffc0200d64:	00014a97          	auipc	s5,0x14
ffffffffc0200d68:	77ca8a93          	addi	s5,s5,1916 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0200d6c:	000ab403          	ld	s0,0(s5)
ffffffffc0200d70:	01595793          	srli	a5,s2,0x15
ffffffffc0200d74:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d78:	96a2                	add	a3,a3,s0
ffffffffc0200d7a:	00379413          	slli	s0,a5,0x3
ffffffffc0200d7e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200d80:	6014                	ld	a3,0(s0)
ffffffffc0200d82:	0016f793          	andi	a5,a3,1
ffffffffc0200d86:	e3ad                	bnez	a5,ffffffffc0200de8 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d88:	080a0b63          	beqz	s4,ffffffffc0200e1e <get_pte+0x16a>
ffffffffc0200d8c:	4505                	li	a0,1
ffffffffc0200d8e:	e19ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0200d92:	84aa                	mv	s1,a0
ffffffffc0200d94:	c549                	beqz	a0,ffffffffc0200e1e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200d96:	00014b17          	auipc	s6,0x14
ffffffffc0200d9a:	75ab0b13          	addi	s6,s6,1882 # ffffffffc02154f0 <pages>
ffffffffc0200d9e:	000b3503          	ld	a0,0(s6)
ffffffffc0200da2:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200da6:	0009b703          	ld	a4,0(s3)
ffffffffc0200daa:	40a48533          	sub	a0,s1,a0
ffffffffc0200dae:	8519                	srai	a0,a0,0x6
ffffffffc0200db0:	9552                	add	a0,a0,s4
ffffffffc0200db2:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0200db6:	4685                	li	a3,1
ffffffffc0200db8:	c094                	sw	a3,0(s1)
ffffffffc0200dba:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200dbc:	0532                	slli	a0,a0,0xc
ffffffffc0200dbe:	08e7fa63          	bgeu	a5,a4,ffffffffc0200e52 <get_pte+0x19e>
ffffffffc0200dc2:	000ab783          	ld	a5,0(s5)
ffffffffc0200dc6:	6605                	lui	a2,0x1
ffffffffc0200dc8:	4581                	li	a1,0
ffffffffc0200dca:	953e                	add	a0,a0,a5
ffffffffc0200dcc:	2d1030ef          	jal	ra,ffffffffc020489c <memset>
    return page - pages + nbase;
ffffffffc0200dd0:	000b3683          	ld	a3,0(s6)
ffffffffc0200dd4:	40d486b3          	sub	a3,s1,a3
ffffffffc0200dd8:	8699                	srai	a3,a3,0x6
ffffffffc0200dda:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ddc:	06aa                	slli	a3,a3,0xa
ffffffffc0200dde:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200de2:	e014                	sd	a3,0(s0)
ffffffffc0200de4:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200de8:	068a                	slli	a3,a3,0x2
ffffffffc0200dea:	757d                	lui	a0,0xfffff
ffffffffc0200dec:	8ee9                	and	a3,a3,a0
ffffffffc0200dee:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200df2:	04e7f463          	bgeu	a5,a4,ffffffffc0200e3a <get_pte+0x186>
ffffffffc0200df6:	000ab503          	ld	a0,0(s5)
ffffffffc0200dfa:	00c95913          	srli	s2,s2,0xc
ffffffffc0200dfe:	1ff97913          	andi	s2,s2,511
ffffffffc0200e02:	96aa                	add	a3,a3,a0
ffffffffc0200e04:	00391513          	slli	a0,s2,0x3
ffffffffc0200e08:	9536                	add	a0,a0,a3
}
ffffffffc0200e0a:	70e2                	ld	ra,56(sp)
ffffffffc0200e0c:	7442                	ld	s0,48(sp)
ffffffffc0200e0e:	74a2                	ld	s1,40(sp)
ffffffffc0200e10:	7902                	ld	s2,32(sp)
ffffffffc0200e12:	69e2                	ld	s3,24(sp)
ffffffffc0200e14:	6a42                	ld	s4,16(sp)
ffffffffc0200e16:	6aa2                	ld	s5,8(sp)
ffffffffc0200e18:	6b02                	ld	s6,0(sp)
ffffffffc0200e1a:	6121                	addi	sp,sp,64
ffffffffc0200e1c:	8082                	ret
            return NULL;
ffffffffc0200e1e:	4501                	li	a0,0
ffffffffc0200e20:	b7ed                	j	ffffffffc0200e0a <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200e22:	00005617          	auipc	a2,0x5
ffffffffc0200e26:	86e60613          	addi	a2,a2,-1938 # ffffffffc0205690 <commands+0x840>
ffffffffc0200e2a:	0e400593          	li	a1,228
ffffffffc0200e2e:	00005517          	auipc	a0,0x5
ffffffffc0200e32:	88a50513          	addi	a0,a0,-1910 # ffffffffc02056b8 <commands+0x868>
ffffffffc0200e36:	b9eff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e3a:	00005617          	auipc	a2,0x5
ffffffffc0200e3e:	85660613          	addi	a2,a2,-1962 # ffffffffc0205690 <commands+0x840>
ffffffffc0200e42:	0ef00593          	li	a1,239
ffffffffc0200e46:	00005517          	auipc	a0,0x5
ffffffffc0200e4a:	87250513          	addi	a0,a0,-1934 # ffffffffc02056b8 <commands+0x868>
ffffffffc0200e4e:	b86ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e52:	86aa                	mv	a3,a0
ffffffffc0200e54:	00005617          	auipc	a2,0x5
ffffffffc0200e58:	83c60613          	addi	a2,a2,-1988 # ffffffffc0205690 <commands+0x840>
ffffffffc0200e5c:	0ec00593          	li	a1,236
ffffffffc0200e60:	00005517          	auipc	a0,0x5
ffffffffc0200e64:	85850513          	addi	a0,a0,-1960 # ffffffffc02056b8 <commands+0x868>
ffffffffc0200e68:	b6cff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e6c:	86aa                	mv	a3,a0
ffffffffc0200e6e:	00005617          	auipc	a2,0x5
ffffffffc0200e72:	82260613          	addi	a2,a2,-2014 # ffffffffc0205690 <commands+0x840>
ffffffffc0200e76:	0e100593          	li	a1,225
ffffffffc0200e7a:	00005517          	auipc	a0,0x5
ffffffffc0200e7e:	83e50513          	addi	a0,a0,-1986 # ffffffffc02056b8 <commands+0x868>
ffffffffc0200e82:	b52ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200e86 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e86:	1141                	addi	sp,sp,-16
ffffffffc0200e88:	e022                	sd	s0,0(sp)
ffffffffc0200e8a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e8c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e8e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e90:	e25ff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e94:	c011                	beqz	s0,ffffffffc0200e98 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e96:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e98:	c511                	beqz	a0,ffffffffc0200ea4 <get_page+0x1e>
ffffffffc0200e9a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e9c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e9e:	0017f713          	andi	a4,a5,1
ffffffffc0200ea2:	e709                	bnez	a4,ffffffffc0200eac <get_page+0x26>
}
ffffffffc0200ea4:	60a2                	ld	ra,8(sp)
ffffffffc0200ea6:	6402                	ld	s0,0(sp)
ffffffffc0200ea8:	0141                	addi	sp,sp,16
ffffffffc0200eaa:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200eac:	00014717          	auipc	a4,0x14
ffffffffc0200eb0:	5dc70713          	addi	a4,a4,1500 # ffffffffc0215488 <npage>
ffffffffc0200eb4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200eb6:	078a                	slli	a5,a5,0x2
ffffffffc0200eb8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eba:	02e7f063          	bgeu	a5,a4,ffffffffc0200eda <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ebe:	00014717          	auipc	a4,0x14
ffffffffc0200ec2:	63270713          	addi	a4,a4,1586 # ffffffffc02154f0 <pages>
ffffffffc0200ec6:	6308                	ld	a0,0(a4)
ffffffffc0200ec8:	60a2                	ld	ra,8(sp)
ffffffffc0200eca:	6402                	ld	s0,0(sp)
ffffffffc0200ecc:	fff80737          	lui	a4,0xfff80
ffffffffc0200ed0:	97ba                	add	a5,a5,a4
ffffffffc0200ed2:	079a                	slli	a5,a5,0x6
ffffffffc0200ed4:	953e                	add	a0,a0,a5
ffffffffc0200ed6:	0141                	addi	sp,sp,16
ffffffffc0200ed8:	8082                	ret
ffffffffc0200eda:	cb1ff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>

ffffffffc0200ede <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ede:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ee0:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ee2:	e426                	sd	s1,8(sp)
ffffffffc0200ee4:	ec06                	sd	ra,24(sp)
ffffffffc0200ee6:	e822                	sd	s0,16(sp)
ffffffffc0200ee8:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200eea:	dcbff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    if (ptep != NULL) {
ffffffffc0200eee:	c511                	beqz	a0,ffffffffc0200efa <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200ef0:	611c                	ld	a5,0(a0)
ffffffffc0200ef2:	842a                	mv	s0,a0
ffffffffc0200ef4:	0017f713          	andi	a4,a5,1
ffffffffc0200ef8:	e711                	bnez	a4,ffffffffc0200f04 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200efa:	60e2                	ld	ra,24(sp)
ffffffffc0200efc:	6442                	ld	s0,16(sp)
ffffffffc0200efe:	64a2                	ld	s1,8(sp)
ffffffffc0200f00:	6105                	addi	sp,sp,32
ffffffffc0200f02:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f04:	00014717          	auipc	a4,0x14
ffffffffc0200f08:	58470713          	addi	a4,a4,1412 # ffffffffc0215488 <npage>
ffffffffc0200f0c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f0e:	078a                	slli	a5,a5,0x2
ffffffffc0200f10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f12:	02e7fe63          	bgeu	a5,a4,ffffffffc0200f4e <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f16:	00014717          	auipc	a4,0x14
ffffffffc0200f1a:	5da70713          	addi	a4,a4,1498 # ffffffffc02154f0 <pages>
ffffffffc0200f1e:	6308                	ld	a0,0(a4)
ffffffffc0200f20:	fff80737          	lui	a4,0xfff80
ffffffffc0200f24:	97ba                	add	a5,a5,a4
ffffffffc0200f26:	079a                	slli	a5,a5,0x6
ffffffffc0200f28:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200f2a:	411c                	lw	a5,0(a0)
ffffffffc0200f2c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f30:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f32:	cb11                	beqz	a4,ffffffffc0200f46 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f34:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f38:	12048073          	sfence.vma	s1
}
ffffffffc0200f3c:	60e2                	ld	ra,24(sp)
ffffffffc0200f3e:	6442                	ld	s0,16(sp)
ffffffffc0200f40:	64a2                	ld	s1,8(sp)
ffffffffc0200f42:	6105                	addi	sp,sp,32
ffffffffc0200f44:	8082                	ret
            free_page(page);
ffffffffc0200f46:	4585                	li	a1,1
ffffffffc0200f48:	ce7ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
ffffffffc0200f4c:	b7e5                	j	ffffffffc0200f34 <page_remove+0x56>
ffffffffc0200f4e:	c3dff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>

ffffffffc0200f52 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f52:	7179                	addi	sp,sp,-48
ffffffffc0200f54:	e44e                	sd	s3,8(sp)
ffffffffc0200f56:	89b2                	mv	s3,a2
ffffffffc0200f58:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f5a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f5c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f5e:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f60:	ec26                	sd	s1,24(sp)
ffffffffc0200f62:	f406                	sd	ra,40(sp)
ffffffffc0200f64:	e84a                	sd	s2,16(sp)
ffffffffc0200f66:	e052                	sd	s4,0(sp)
ffffffffc0200f68:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f6a:	d4bff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    if (ptep == NULL) {
ffffffffc0200f6e:	cd49                	beqz	a0,ffffffffc0201008 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0200f70:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0200f72:	611c                	ld	a5,0(a0)
ffffffffc0200f74:	892a                	mv	s2,a0
ffffffffc0200f76:	0016871b          	addiw	a4,a3,1
ffffffffc0200f7a:	c018                	sw	a4,0(s0)
ffffffffc0200f7c:	0017f713          	andi	a4,a5,1
ffffffffc0200f80:	ef05                	bnez	a4,ffffffffc0200fb8 <page_insert+0x66>
ffffffffc0200f82:	00014797          	auipc	a5,0x14
ffffffffc0200f86:	56e78793          	addi	a5,a5,1390 # ffffffffc02154f0 <pages>
ffffffffc0200f8a:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0200f8c:	8c19                	sub	s0,s0,a4
ffffffffc0200f8e:	000806b7          	lui	a3,0x80
ffffffffc0200f92:	8419                	srai	s0,s0,0x6
ffffffffc0200f94:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f96:	042a                	slli	s0,s0,0xa
ffffffffc0200f98:	8c45                	or	s0,s0,s1
ffffffffc0200f9a:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f9e:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fa2:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0200fa6:	4501                	li	a0,0
}
ffffffffc0200fa8:	70a2                	ld	ra,40(sp)
ffffffffc0200faa:	7402                	ld	s0,32(sp)
ffffffffc0200fac:	64e2                	ld	s1,24(sp)
ffffffffc0200fae:	6942                	ld	s2,16(sp)
ffffffffc0200fb0:	69a2                	ld	s3,8(sp)
ffffffffc0200fb2:	6a02                	ld	s4,0(sp)
ffffffffc0200fb4:	6145                	addi	sp,sp,48
ffffffffc0200fb6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200fb8:	00014717          	auipc	a4,0x14
ffffffffc0200fbc:	4d070713          	addi	a4,a4,1232 # ffffffffc0215488 <npage>
ffffffffc0200fc0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200fc2:	078a                	slli	a5,a5,0x2
ffffffffc0200fc4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fc6:	04e7f363          	bgeu	a5,a4,ffffffffc020100c <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fca:	00014a17          	auipc	s4,0x14
ffffffffc0200fce:	526a0a13          	addi	s4,s4,1318 # ffffffffc02154f0 <pages>
ffffffffc0200fd2:	000a3703          	ld	a4,0(s4)
ffffffffc0200fd6:	fff80537          	lui	a0,0xfff80
ffffffffc0200fda:	953e                	add	a0,a0,a5
ffffffffc0200fdc:	051a                	slli	a0,a0,0x6
ffffffffc0200fde:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0200fe0:	00a40a63          	beq	s0,a0,ffffffffc0200ff4 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0200fe4:	411c                	lw	a5,0(a0)
ffffffffc0200fe6:	fff7869b          	addiw	a3,a5,-1
ffffffffc0200fea:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0200fec:	c691                	beqz	a3,ffffffffc0200ff8 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fee:	12098073          	sfence.vma	s3
ffffffffc0200ff2:	bf69                	j	ffffffffc0200f8c <page_insert+0x3a>
ffffffffc0200ff4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200ff6:	bf59                	j	ffffffffc0200f8c <page_insert+0x3a>
            free_page(page);
ffffffffc0200ff8:	4585                	li	a1,1
ffffffffc0200ffa:	c35ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
ffffffffc0200ffe:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201002:	12098073          	sfence.vma	s3
ffffffffc0201006:	b759                	j	ffffffffc0200f8c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201008:	5571                	li	a0,-4
ffffffffc020100a:	bf79                	j	ffffffffc0200fa8 <page_insert+0x56>
ffffffffc020100c:	b7fff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>

ffffffffc0201010 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201010:	00005797          	auipc	a5,0x5
ffffffffc0201014:	76078793          	addi	a5,a5,1888 # ffffffffc0206770 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201018:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020101a:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	6f450513          	addi	a0,a0,1780 # ffffffffc0205710 <commands+0x8c0>
void pmm_init(void) {
ffffffffc0201024:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201026:	00014717          	auipc	a4,0x14
ffffffffc020102a:	4af73923          	sd	a5,1202(a4) # ffffffffc02154d8 <pmm_manager>
void pmm_init(void) {
ffffffffc020102e:	e0a2                	sd	s0,64(sp)
ffffffffc0201030:	fc26                	sd	s1,56(sp)
ffffffffc0201032:	f84a                	sd	s2,48(sp)
ffffffffc0201034:	f44e                	sd	s3,40(sp)
ffffffffc0201036:	f052                	sd	s4,32(sp)
ffffffffc0201038:	ec56                	sd	s5,24(sp)
ffffffffc020103a:	e85a                	sd	s6,16(sp)
ffffffffc020103c:	e45e                	sd	s7,8(sp)
ffffffffc020103e:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201040:	00014417          	auipc	s0,0x14
ffffffffc0201044:	49840413          	addi	s0,s0,1176 # ffffffffc02154d8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201048:	888ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc020104c:	601c                	ld	a5,0(s0)
ffffffffc020104e:	00014497          	auipc	s1,0x14
ffffffffc0201052:	43a48493          	addi	s1,s1,1082 # ffffffffc0215488 <npage>
ffffffffc0201056:	00014917          	auipc	s2,0x14
ffffffffc020105a:	49a90913          	addi	s2,s2,1178 # ffffffffc02154f0 <pages>
ffffffffc020105e:	679c                	ld	a5,8(a5)
ffffffffc0201060:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201062:	57f5                	li	a5,-3
ffffffffc0201064:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	6c250513          	addi	a0,a0,1730 # ffffffffc0205728 <commands+0x8d8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020106e:	00014717          	auipc	a4,0x14
ffffffffc0201072:	46f73923          	sd	a5,1138(a4) # ffffffffc02154e0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201076:	85aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020107a:	46c5                	li	a3,17
ffffffffc020107c:	06ee                	slli	a3,a3,0x1b
ffffffffc020107e:	40100613          	li	a2,1025
ffffffffc0201082:	16fd                	addi	a3,a3,-1
ffffffffc0201084:	0656                	slli	a2,a2,0x15
ffffffffc0201086:	07e005b7          	lui	a1,0x7e00
ffffffffc020108a:	00004517          	auipc	a0,0x4
ffffffffc020108e:	6b650513          	addi	a0,a0,1718 # ffffffffc0205740 <commands+0x8f0>
ffffffffc0201092:	83eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201096:	777d                	lui	a4,0xfffff
ffffffffc0201098:	00015797          	auipc	a5,0x15
ffffffffc020109c:	56778793          	addi	a5,a5,1383 # ffffffffc02165ff <end+0xfff>
ffffffffc02010a0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010a2:	00088737          	lui	a4,0x88
ffffffffc02010a6:	00014697          	auipc	a3,0x14
ffffffffc02010aa:	3ee6b123          	sd	a4,994(a3) # ffffffffc0215488 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010ae:	00014717          	auipc	a4,0x14
ffffffffc02010b2:	44f73123          	sd	a5,1090(a4) # ffffffffc02154f0 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010b6:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010b8:	4685                	li	a3,1
ffffffffc02010ba:	fff80837          	lui	a6,0xfff80
ffffffffc02010be:	a019                	j	ffffffffc02010c4 <pmm_init+0xb4>
ffffffffc02010c0:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02010c4:	00671613          	slli	a2,a4,0x6
ffffffffc02010c8:	97b2                	add	a5,a5,a2
ffffffffc02010ca:	07a1                	addi	a5,a5,8
ffffffffc02010cc:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010d0:	6090                	ld	a2,0(s1)
ffffffffc02010d2:	0705                	addi	a4,a4,1
ffffffffc02010d4:	010607b3          	add	a5,a2,a6
ffffffffc02010d8:	fef764e3          	bltu	a4,a5,ffffffffc02010c0 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010dc:	00093503          	ld	a0,0(s2)
ffffffffc02010e0:	fe0007b7          	lui	a5,0xfe000
ffffffffc02010e4:	00661693          	slli	a3,a2,0x6
ffffffffc02010e8:	97aa                	add	a5,a5,a0
ffffffffc02010ea:	96be                	add	a3,a3,a5
ffffffffc02010ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02010f0:	7af6eb63          	bltu	a3,a5,ffffffffc02018a6 <pmm_init+0x896>
ffffffffc02010f4:	00014997          	auipc	s3,0x14
ffffffffc02010f8:	3ec98993          	addi	s3,s3,1004 # ffffffffc02154e0 <va_pa_offset>
ffffffffc02010fc:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201100:	47c5                	li	a5,17
ffffffffc0201102:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201104:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201106:	02f6f763          	bgeu	a3,a5,ffffffffc0201134 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020110a:	6585                	lui	a1,0x1
ffffffffc020110c:	15fd                	addi	a1,a1,-1
ffffffffc020110e:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0201110:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201114:	48c77863          	bgeu	a4,a2,ffffffffc02015a4 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc0201118:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020111a:	75fd                	lui	a1,0xfffff
ffffffffc020111c:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020111e:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0201120:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201122:	40d786b3          	sub	a3,a5,a3
ffffffffc0201126:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0201128:	00c6d593          	srli	a1,a3,0xc
ffffffffc020112c:	953a                	add	a0,a0,a4
ffffffffc020112e:	9602                	jalr	a2
ffffffffc0201130:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201134:	00004517          	auipc	a0,0x4
ffffffffc0201138:	65c50513          	addi	a0,a0,1628 # ffffffffc0205790 <commands+0x940>
ffffffffc020113c:	f95fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201140:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201142:	00014417          	auipc	s0,0x14
ffffffffc0201146:	33e40413          	addi	s0,s0,830 # ffffffffc0215480 <boot_pgdir>
    pmm_manager->check();
ffffffffc020114a:	7b9c                	ld	a5,48(a5)
ffffffffc020114c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020114e:	00004517          	auipc	a0,0x4
ffffffffc0201152:	65a50513          	addi	a0,a0,1626 # ffffffffc02057a8 <commands+0x958>
ffffffffc0201156:	f7bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020115a:	00008697          	auipc	a3,0x8
ffffffffc020115e:	ea668693          	addi	a3,a3,-346 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201162:	00014797          	auipc	a5,0x14
ffffffffc0201166:	30d7bf23          	sd	a3,798(a5) # ffffffffc0215480 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020116a:	c02007b7          	lui	a5,0xc0200
ffffffffc020116e:	10f6e8e3          	bltu	a3,a5,ffffffffc0201a7e <pmm_init+0xa6e>
ffffffffc0201172:	0009b783          	ld	a5,0(s3)
ffffffffc0201176:	8e9d                	sub	a3,a3,a5
ffffffffc0201178:	00014797          	auipc	a5,0x14
ffffffffc020117c:	36d7b823          	sd	a3,880(a5) # ffffffffc02154e8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201180:	af5ff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201184:	6098                	ld	a4,0(s1)
ffffffffc0201186:	c80007b7          	lui	a5,0xc8000
ffffffffc020118a:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020118c:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020118e:	0ce7e8e3          	bltu	a5,a4,ffffffffc0201a5e <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201192:	6008                	ld	a0,0(s0)
ffffffffc0201194:	44050263          	beqz	a0,ffffffffc02015d8 <pmm_init+0x5c8>
ffffffffc0201198:	03451793          	slli	a5,a0,0x34
ffffffffc020119c:	42079e63          	bnez	a5,ffffffffc02015d8 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02011a0:	4601                	li	a2,0
ffffffffc02011a2:	4581                	li	a1,0
ffffffffc02011a4:	ce3ff0ef          	jal	ra,ffffffffc0200e86 <get_page>
ffffffffc02011a8:	78051b63          	bnez	a0,ffffffffc020193e <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02011ac:	4505                	li	a0,1
ffffffffc02011ae:	9f9ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02011b2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02011b4:	6008                	ld	a0,0(s0)
ffffffffc02011b6:	4681                	li	a3,0
ffffffffc02011b8:	4601                	li	a2,0
ffffffffc02011ba:	85d6                	mv	a1,s5
ffffffffc02011bc:	d97ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc02011c0:	7a051f63          	bnez	a0,ffffffffc020197e <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02011c4:	6008                	ld	a0,0(s0)
ffffffffc02011c6:	4601                	li	a2,0
ffffffffc02011c8:	4581                	li	a1,0
ffffffffc02011ca:	aebff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc02011ce:	78050863          	beqz	a0,ffffffffc020195e <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02011d2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02011d4:	0017f713          	andi	a4,a5,1
ffffffffc02011d8:	3e070463          	beqz	a4,ffffffffc02015c0 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02011dc:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02011de:	078a                	slli	a5,a5,0x2
ffffffffc02011e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011e2:	3ce7f163          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02011e6:	00093683          	ld	a3,0(s2)
ffffffffc02011ea:	fff80637          	lui	a2,0xfff80
ffffffffc02011ee:	97b2                	add	a5,a5,a2
ffffffffc02011f0:	079a                	slli	a5,a5,0x6
ffffffffc02011f2:	97b6                	add	a5,a5,a3
ffffffffc02011f4:	72fa9563          	bne	s5,a5,ffffffffc020191e <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02011f8:	000aab83          	lw	s7,0(s5)
ffffffffc02011fc:	4785                	li	a5,1
ffffffffc02011fe:	70fb9063          	bne	s7,a5,ffffffffc02018fe <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201202:	6008                	ld	a0,0(s0)
ffffffffc0201204:	76fd                	lui	a3,0xfffff
ffffffffc0201206:	611c                	ld	a5,0(a0)
ffffffffc0201208:	078a                	slli	a5,a5,0x2
ffffffffc020120a:	8ff5                	and	a5,a5,a3
ffffffffc020120c:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201210:	66e67e63          	bgeu	a2,a4,ffffffffc020188c <pmm_init+0x87c>
ffffffffc0201214:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201218:	97e2                	add	a5,a5,s8
ffffffffc020121a:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deaa00>
ffffffffc020121e:	0b0a                	slli	s6,s6,0x2
ffffffffc0201220:	00db7b33          	and	s6,s6,a3
ffffffffc0201224:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201228:	56e7f863          	bgeu	a5,a4,ffffffffc0201798 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020122c:	4601                	li	a2,0
ffffffffc020122e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201230:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201232:	a83ff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201236:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201238:	55651063          	bne	a0,s6,ffffffffc0201778 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc020123c:	4505                	li	a0,1
ffffffffc020123e:	969ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0201242:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201244:	6008                	ld	a0,0(s0)
ffffffffc0201246:	46d1                	li	a3,20
ffffffffc0201248:	6605                	lui	a2,0x1
ffffffffc020124a:	85da                	mv	a1,s6
ffffffffc020124c:	d07ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc0201250:	50051463          	bnez	a0,ffffffffc0201758 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201254:	6008                	ld	a0,0(s0)
ffffffffc0201256:	4601                	li	a2,0
ffffffffc0201258:	6585                	lui	a1,0x1
ffffffffc020125a:	a5bff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc020125e:	4c050d63          	beqz	a0,ffffffffc0201738 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc0201262:	611c                	ld	a5,0(a0)
ffffffffc0201264:	0107f713          	andi	a4,a5,16
ffffffffc0201268:	4a070863          	beqz	a4,ffffffffc0201718 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc020126c:	8b91                	andi	a5,a5,4
ffffffffc020126e:	48078563          	beqz	a5,ffffffffc02016f8 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201272:	6008                	ld	a0,0(s0)
ffffffffc0201274:	611c                	ld	a5,0(a0)
ffffffffc0201276:	8bc1                	andi	a5,a5,16
ffffffffc0201278:	46078063          	beqz	a5,ffffffffc02016d8 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc020127c:	000b2783          	lw	a5,0(s6)
ffffffffc0201280:	43779c63          	bne	a5,s7,ffffffffc02016b8 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201284:	4681                	li	a3,0
ffffffffc0201286:	6605                	lui	a2,0x1
ffffffffc0201288:	85d6                	mv	a1,s5
ffffffffc020128a:	cc9ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc020128e:	40051563          	bnez	a0,ffffffffc0201698 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc0201292:	000aa703          	lw	a4,0(s5)
ffffffffc0201296:	4789                	li	a5,2
ffffffffc0201298:	3ef71063          	bne	a4,a5,ffffffffc0201678 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc020129c:	000b2783          	lw	a5,0(s6)
ffffffffc02012a0:	3a079c63          	bnez	a5,ffffffffc0201658 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02012a4:	6008                	ld	a0,0(s0)
ffffffffc02012a6:	4601                	li	a2,0
ffffffffc02012a8:	6585                	lui	a1,0x1
ffffffffc02012aa:	a0bff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc02012ae:	38050563          	beqz	a0,ffffffffc0201638 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc02012b2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02012b4:	00177793          	andi	a5,a4,1
ffffffffc02012b8:	30078463          	beqz	a5,ffffffffc02015c0 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02012bc:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02012be:	00271793          	slli	a5,a4,0x2
ffffffffc02012c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012c4:	2ed7f063          	bgeu	a5,a3,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02012c8:	00093683          	ld	a3,0(s2)
ffffffffc02012cc:	fff80637          	lui	a2,0xfff80
ffffffffc02012d0:	97b2                	add	a5,a5,a2
ffffffffc02012d2:	079a                	slli	a5,a5,0x6
ffffffffc02012d4:	97b6                	add	a5,a5,a3
ffffffffc02012d6:	32fa9163          	bne	s5,a5,ffffffffc02015f8 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02012da:	8b41                	andi	a4,a4,16
ffffffffc02012dc:	70071163          	bnez	a4,ffffffffc02019de <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02012e0:	6008                	ld	a0,0(s0)
ffffffffc02012e2:	4581                	li	a1,0
ffffffffc02012e4:	bfbff0ef          	jal	ra,ffffffffc0200ede <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02012e8:	000aa703          	lw	a4,0(s5)
ffffffffc02012ec:	4785                	li	a5,1
ffffffffc02012ee:	6cf71863          	bne	a4,a5,ffffffffc02019be <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02012f2:	000b2783          	lw	a5,0(s6)
ffffffffc02012f6:	6a079463          	bnez	a5,ffffffffc020199e <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012fa:	6008                	ld	a0,0(s0)
ffffffffc02012fc:	6585                	lui	a1,0x1
ffffffffc02012fe:	be1ff0ef          	jal	ra,ffffffffc0200ede <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201302:	000aa783          	lw	a5,0(s5)
ffffffffc0201306:	50079363          	bnez	a5,ffffffffc020180c <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc020130a:	000b2783          	lw	a5,0(s6)
ffffffffc020130e:	4c079f63          	bnez	a5,ffffffffc02017ec <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201312:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201316:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201318:	000b3783          	ld	a5,0(s6)
ffffffffc020131c:	078a                	slli	a5,a5,0x2
ffffffffc020131e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201320:	28e7f263          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201324:	fff806b7          	lui	a3,0xfff80
ffffffffc0201328:	00093503          	ld	a0,0(s2)
ffffffffc020132c:	97b6                	add	a5,a5,a3
ffffffffc020132e:	079a                	slli	a5,a5,0x6
ffffffffc0201330:	00f506b3          	add	a3,a0,a5
ffffffffc0201334:	4290                	lw	a2,0(a3)
ffffffffc0201336:	4685                	li	a3,1
ffffffffc0201338:	48d61a63          	bne	a2,a3,ffffffffc02017cc <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc020133c:	8799                	srai	a5,a5,0x6
ffffffffc020133e:	00080ab7          	lui	s5,0x80
ffffffffc0201342:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201344:	00c79693          	slli	a3,a5,0xc
ffffffffc0201348:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020134a:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020134c:	46e6f363          	bgeu	a3,a4,ffffffffc02017b2 <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201350:	0009b683          	ld	a3,0(s3)
ffffffffc0201354:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201356:	639c                	ld	a5,0(a5)
ffffffffc0201358:	078a                	slli	a5,a5,0x2
ffffffffc020135a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020135c:	24e7f463          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201360:	415787b3          	sub	a5,a5,s5
ffffffffc0201364:	079a                	slli	a5,a5,0x6
ffffffffc0201366:	953e                	add	a0,a0,a5
ffffffffc0201368:	4585                	li	a1,1
ffffffffc020136a:	8c5ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020136e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201372:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201374:	078a                	slli	a5,a5,0x2
ffffffffc0201376:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201378:	22e7f663          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020137c:	00093503          	ld	a0,0(s2)
ffffffffc0201380:	415787b3          	sub	a5,a5,s5
ffffffffc0201384:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201386:	953e                	add	a0,a0,a5
ffffffffc0201388:	4585                	li	a1,1
ffffffffc020138a:	8a5ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020138e:	601c                	ld	a5,0(s0)
ffffffffc0201390:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201394:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201398:	8ddff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc020139c:	68aa1163          	bne	s4,a0,ffffffffc0201a1e <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02013a0:	00004517          	auipc	a0,0x4
ffffffffc02013a4:	73050513          	addi	a0,a0,1840 # ffffffffc0205ad0 <commands+0xc80>
ffffffffc02013a8:	d29fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02013ac:	8c9ff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013b0:	6098                	ld	a4,0(s1)
ffffffffc02013b2:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02013b6:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013b8:	00c71693          	slli	a3,a4,0xc
ffffffffc02013bc:	18d7f563          	bgeu	a5,a3,ffffffffc0201546 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013c0:	83b1                	srli	a5,a5,0xc
ffffffffc02013c2:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013c4:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013c8:	1ae7f163          	bgeu	a5,a4,ffffffffc020156a <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013cc:	7bfd                	lui	s7,0xfffff
ffffffffc02013ce:	6b05                	lui	s6,0x1
ffffffffc02013d0:	a029                	j	ffffffffc02013da <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013d2:	00cad713          	srli	a4,s5,0xc
ffffffffc02013d6:	18f77a63          	bgeu	a4,a5,ffffffffc020156a <pmm_init+0x55a>
ffffffffc02013da:	0009b583          	ld	a1,0(s3)
ffffffffc02013de:	4601                	li	a2,0
ffffffffc02013e0:	95d6                	add	a1,a1,s5
ffffffffc02013e2:	8d3ff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc02013e6:	16050263          	beqz	a0,ffffffffc020154a <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013ea:	611c                	ld	a5,0(a0)
ffffffffc02013ec:	078a                	slli	a5,a5,0x2
ffffffffc02013ee:	0177f7b3          	and	a5,a5,s7
ffffffffc02013f2:	19579963          	bne	a5,s5,ffffffffc0201584 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013f6:	609c                	ld	a5,0(s1)
ffffffffc02013f8:	9ada                	add	s5,s5,s6
ffffffffc02013fa:	6008                	ld	a0,0(s0)
ffffffffc02013fc:	00c79713          	slli	a4,a5,0xc
ffffffffc0201400:	fceae9e3          	bltu	s5,a4,ffffffffc02013d2 <pmm_init+0x3c2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0201404:	611c                	ld	a5,0(a0)
ffffffffc0201406:	62079c63          	bnez	a5,ffffffffc0201a3e <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc020140a:	4505                	li	a0,1
ffffffffc020140c:	f9aff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0201410:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201412:	6008                	ld	a0,0(s0)
ffffffffc0201414:	4699                	li	a3,6
ffffffffc0201416:	10000613          	li	a2,256
ffffffffc020141a:	85d6                	mv	a1,s5
ffffffffc020141c:	b37ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc0201420:	1e051c63          	bnez	a0,ffffffffc0201618 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0201424:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201428:	4785                	li	a5,1
ffffffffc020142a:	44f71163          	bne	a4,a5,ffffffffc020186c <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020142e:	6008                	ld	a0,0(s0)
ffffffffc0201430:	6b05                	lui	s6,0x1
ffffffffc0201432:	4699                	li	a3,6
ffffffffc0201434:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201438:	85d6                	mv	a1,s5
ffffffffc020143a:	b19ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc020143e:	40051763          	bnez	a0,ffffffffc020184c <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0201442:	000aa703          	lw	a4,0(s5)
ffffffffc0201446:	4789                	li	a5,2
ffffffffc0201448:	3ef71263          	bne	a4,a5,ffffffffc020182c <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020144c:	00004597          	auipc	a1,0x4
ffffffffc0201450:	7bc58593          	addi	a1,a1,1980 # ffffffffc0205c08 <commands+0xdb8>
ffffffffc0201454:	10000513          	li	a0,256
ffffffffc0201458:	3ea030ef          	jal	ra,ffffffffc0204842 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020145c:	100b0593          	addi	a1,s6,256
ffffffffc0201460:	10000513          	li	a0,256
ffffffffc0201464:	3f0030ef          	jal	ra,ffffffffc0204854 <strcmp>
ffffffffc0201468:	44051b63          	bnez	a0,ffffffffc02018be <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc020146c:	00093683          	ld	a3,0(s2)
ffffffffc0201470:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201474:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201476:	40da86b3          	sub	a3,s5,a3
ffffffffc020147a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020147c:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020147e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201480:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201484:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201488:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020148a:	10f77f63          	bgeu	a4,a5,ffffffffc02015a8 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020148e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201492:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201496:	96be                	add	a3,a3,a5
ffffffffc0201498:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6ab00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020149c:	362030ef          	jal	ra,ffffffffc02047fe <strlen>
ffffffffc02014a0:	54051f63          	bnez	a0,ffffffffc02019fe <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02014a4:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02014a8:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014aa:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a00>
ffffffffc02014ae:	068a                	slli	a3,a3,0x2
ffffffffc02014b0:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014b2:	0ef6f963          	bgeu	a3,a5,ffffffffc02015a4 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc02014b6:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02014ba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02014bc:	0efb7663          	bgeu	s6,a5,ffffffffc02015a8 <pmm_init+0x598>
ffffffffc02014c0:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02014c4:	4585                	li	a1,1
ffffffffc02014c6:	8556                	mv	a0,s5
ffffffffc02014c8:	99b6                	add	s3,s3,a3
ffffffffc02014ca:	f64ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ce:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02014d2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014d4:	078a                	slli	a5,a5,0x2
ffffffffc02014d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014d8:	0ce7f663          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02014dc:	00093503          	ld	a0,0(s2)
ffffffffc02014e0:	fff809b7          	lui	s3,0xfff80
ffffffffc02014e4:	97ce                	add	a5,a5,s3
ffffffffc02014e6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02014e8:	953e                	add	a0,a0,a5
ffffffffc02014ea:	4585                	li	a1,1
ffffffffc02014ec:	f42ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014f0:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02014f4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014f6:	078a                	slli	a5,a5,0x2
ffffffffc02014f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014fa:	0ae7f563          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02014fe:	00093503          	ld	a0,0(s2)
ffffffffc0201502:	97ce                	add	a5,a5,s3
ffffffffc0201504:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201506:	953e                	add	a0,a0,a5
ffffffffc0201508:	4585                	li	a1,1
ffffffffc020150a:	f24ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020150e:	601c                	ld	a5,0(s0)
ffffffffc0201510:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201514:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201518:	f5cff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc020151c:	3caa1163          	bne	s4,a0,ffffffffc02018de <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201520:	00004517          	auipc	a0,0x4
ffffffffc0201524:	76050513          	addi	a0,a0,1888 # ffffffffc0205c80 <commands+0xe30>
ffffffffc0201528:	ba9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020152c:	6406                	ld	s0,64(sp)
ffffffffc020152e:	60a6                	ld	ra,72(sp)
ffffffffc0201530:	74e2                	ld	s1,56(sp)
ffffffffc0201532:	7942                	ld	s2,48(sp)
ffffffffc0201534:	79a2                	ld	s3,40(sp)
ffffffffc0201536:	7a02                	ld	s4,32(sp)
ffffffffc0201538:	6ae2                	ld	s5,24(sp)
ffffffffc020153a:	6b42                	ld	s6,16(sp)
ffffffffc020153c:	6ba2                	ld	s7,8(sp)
ffffffffc020153e:	6c02                	ld	s8,0(sp)
ffffffffc0201540:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201542:	06c0106f          	j	ffffffffc02025ae <kmalloc_init>
ffffffffc0201546:	6008                	ld	a0,0(s0)
ffffffffc0201548:	bd75                	j	ffffffffc0201404 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020154a:	00004697          	auipc	a3,0x4
ffffffffc020154e:	5a668693          	addi	a3,a3,1446 # ffffffffc0205af0 <commands+0xca0>
ffffffffc0201552:	00004617          	auipc	a2,0x4
ffffffffc0201556:	29660613          	addi	a2,a2,662 # ffffffffc02057e8 <commands+0x998>
ffffffffc020155a:	19d00593          	li	a1,413
ffffffffc020155e:	00004517          	auipc	a0,0x4
ffffffffc0201562:	15a50513          	addi	a0,a0,346 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201566:	c6ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc020156a:	86d6                	mv	a3,s5
ffffffffc020156c:	00004617          	auipc	a2,0x4
ffffffffc0201570:	12460613          	addi	a2,a2,292 # ffffffffc0205690 <commands+0x840>
ffffffffc0201574:	19d00593          	li	a1,413
ffffffffc0201578:	00004517          	auipc	a0,0x4
ffffffffc020157c:	14050513          	addi	a0,a0,320 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201580:	c55fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201584:	00004697          	auipc	a3,0x4
ffffffffc0201588:	5ac68693          	addi	a3,a3,1452 # ffffffffc0205b30 <commands+0xce0>
ffffffffc020158c:	00004617          	auipc	a2,0x4
ffffffffc0201590:	25c60613          	addi	a2,a2,604 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201594:	19e00593          	li	a1,414
ffffffffc0201598:	00004517          	auipc	a0,0x4
ffffffffc020159c:	12050513          	addi	a0,a0,288 # ffffffffc02056b8 <commands+0x868>
ffffffffc02015a0:	c35fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc02015a4:	de6ff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	0e860613          	addi	a2,a2,232 # ffffffffc0205690 <commands+0x840>
ffffffffc02015b0:	06900593          	li	a1,105
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	13450513          	addi	a0,a0,308 # ffffffffc02056e8 <commands+0x898>
ffffffffc02015bc:	c19fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02015c0:	00004617          	auipc	a2,0x4
ffffffffc02015c4:	30060613          	addi	a2,a2,768 # ffffffffc02058c0 <commands+0xa70>
ffffffffc02015c8:	07400593          	li	a1,116
ffffffffc02015cc:	00004517          	auipc	a0,0x4
ffffffffc02015d0:	11c50513          	addi	a0,a0,284 # ffffffffc02056e8 <commands+0x898>
ffffffffc02015d4:	c01fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02015d8:	00004697          	auipc	a3,0x4
ffffffffc02015dc:	22868693          	addi	a3,a3,552 # ffffffffc0205800 <commands+0x9b0>
ffffffffc02015e0:	00004617          	auipc	a2,0x4
ffffffffc02015e4:	20860613          	addi	a2,a2,520 # ffffffffc02057e8 <commands+0x998>
ffffffffc02015e8:	16100593          	li	a1,353
ffffffffc02015ec:	00004517          	auipc	a0,0x4
ffffffffc02015f0:	0cc50513          	addi	a0,a0,204 # ffffffffc02056b8 <commands+0x868>
ffffffffc02015f4:	be1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02015f8:	00004697          	auipc	a3,0x4
ffffffffc02015fc:	2f068693          	addi	a3,a3,752 # ffffffffc02058e8 <commands+0xa98>
ffffffffc0201600:	00004617          	auipc	a2,0x4
ffffffffc0201604:	1e860613          	addi	a2,a2,488 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201608:	17d00593          	li	a1,381
ffffffffc020160c:	00004517          	auipc	a0,0x4
ffffffffc0201610:	0ac50513          	addi	a0,a0,172 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201614:	bc1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201618:	00004697          	auipc	a3,0x4
ffffffffc020161c:	54868693          	addi	a3,a3,1352 # ffffffffc0205b60 <commands+0xd10>
ffffffffc0201620:	00004617          	auipc	a2,0x4
ffffffffc0201624:	1c860613          	addi	a2,a2,456 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201628:	1a500593          	li	a1,421
ffffffffc020162c:	00004517          	auipc	a0,0x4
ffffffffc0201630:	08c50513          	addi	a0,a0,140 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201634:	ba1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201638:	00004697          	auipc	a3,0x4
ffffffffc020163c:	34068693          	addi	a3,a3,832 # ffffffffc0205978 <commands+0xb28>
ffffffffc0201640:	00004617          	auipc	a2,0x4
ffffffffc0201644:	1a860613          	addi	a2,a2,424 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201648:	17c00593          	li	a1,380
ffffffffc020164c:	00004517          	auipc	a0,0x4
ffffffffc0201650:	06c50513          	addi	a0,a0,108 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201654:	b81fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201658:	00004697          	auipc	a3,0x4
ffffffffc020165c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205a40 <commands+0xbf0>
ffffffffc0201660:	00004617          	auipc	a2,0x4
ffffffffc0201664:	18860613          	addi	a2,a2,392 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201668:	17b00593          	li	a1,379
ffffffffc020166c:	00004517          	auipc	a0,0x4
ffffffffc0201670:	04c50513          	addi	a0,a0,76 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201674:	b61fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201678:	00004697          	auipc	a3,0x4
ffffffffc020167c:	3b068693          	addi	a3,a3,944 # ffffffffc0205a28 <commands+0xbd8>
ffffffffc0201680:	00004617          	auipc	a2,0x4
ffffffffc0201684:	16860613          	addi	a2,a2,360 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201688:	17a00593          	li	a1,378
ffffffffc020168c:	00004517          	auipc	a0,0x4
ffffffffc0201690:	02c50513          	addi	a0,a0,44 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201694:	b41fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201698:	00004697          	auipc	a3,0x4
ffffffffc020169c:	36068693          	addi	a3,a3,864 # ffffffffc02059f8 <commands+0xba8>
ffffffffc02016a0:	00004617          	auipc	a2,0x4
ffffffffc02016a4:	14860613          	addi	a2,a2,328 # ffffffffc02057e8 <commands+0x998>
ffffffffc02016a8:	17900593          	li	a1,377
ffffffffc02016ac:	00004517          	auipc	a0,0x4
ffffffffc02016b0:	00c50513          	addi	a0,a0,12 # ffffffffc02056b8 <commands+0x868>
ffffffffc02016b4:	b21fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02016b8:	00004697          	auipc	a3,0x4
ffffffffc02016bc:	32868693          	addi	a3,a3,808 # ffffffffc02059e0 <commands+0xb90>
ffffffffc02016c0:	00004617          	auipc	a2,0x4
ffffffffc02016c4:	12860613          	addi	a2,a2,296 # ffffffffc02057e8 <commands+0x998>
ffffffffc02016c8:	17700593          	li	a1,375
ffffffffc02016cc:	00004517          	auipc	a0,0x4
ffffffffc02016d0:	fec50513          	addi	a0,a0,-20 # ffffffffc02056b8 <commands+0x868>
ffffffffc02016d4:	b01fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02016d8:	00004697          	auipc	a3,0x4
ffffffffc02016dc:	2f068693          	addi	a3,a3,752 # ffffffffc02059c8 <commands+0xb78>
ffffffffc02016e0:	00004617          	auipc	a2,0x4
ffffffffc02016e4:	10860613          	addi	a2,a2,264 # ffffffffc02057e8 <commands+0x998>
ffffffffc02016e8:	17600593          	li	a1,374
ffffffffc02016ec:	00004517          	auipc	a0,0x4
ffffffffc02016f0:	fcc50513          	addi	a0,a0,-52 # ffffffffc02056b8 <commands+0x868>
ffffffffc02016f4:	ae1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02016f8:	00004697          	auipc	a3,0x4
ffffffffc02016fc:	2c068693          	addi	a3,a3,704 # ffffffffc02059b8 <commands+0xb68>
ffffffffc0201700:	00004617          	auipc	a2,0x4
ffffffffc0201704:	0e860613          	addi	a2,a2,232 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201708:	17500593          	li	a1,373
ffffffffc020170c:	00004517          	auipc	a0,0x4
ffffffffc0201710:	fac50513          	addi	a0,a0,-84 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201714:	ac1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201718:	00004697          	auipc	a3,0x4
ffffffffc020171c:	29068693          	addi	a3,a3,656 # ffffffffc02059a8 <commands+0xb58>
ffffffffc0201720:	00004617          	auipc	a2,0x4
ffffffffc0201724:	0c860613          	addi	a2,a2,200 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201728:	17400593          	li	a1,372
ffffffffc020172c:	00004517          	auipc	a0,0x4
ffffffffc0201730:	f8c50513          	addi	a0,a0,-116 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201734:	aa1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201738:	00004697          	auipc	a3,0x4
ffffffffc020173c:	24068693          	addi	a3,a3,576 # ffffffffc0205978 <commands+0xb28>
ffffffffc0201740:	00004617          	auipc	a2,0x4
ffffffffc0201744:	0a860613          	addi	a2,a2,168 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201748:	17300593          	li	a1,371
ffffffffc020174c:	00004517          	auipc	a0,0x4
ffffffffc0201750:	f6c50513          	addi	a0,a0,-148 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201754:	a81fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201758:	00004697          	auipc	a3,0x4
ffffffffc020175c:	1e868693          	addi	a3,a3,488 # ffffffffc0205940 <commands+0xaf0>
ffffffffc0201760:	00004617          	auipc	a2,0x4
ffffffffc0201764:	08860613          	addi	a2,a2,136 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201768:	17200593          	li	a1,370
ffffffffc020176c:	00004517          	auipc	a0,0x4
ffffffffc0201770:	f4c50513          	addi	a0,a0,-180 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201774:	a61fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201778:	00004697          	auipc	a3,0x4
ffffffffc020177c:	1a068693          	addi	a3,a3,416 # ffffffffc0205918 <commands+0xac8>
ffffffffc0201780:	00004617          	auipc	a2,0x4
ffffffffc0201784:	06860613          	addi	a2,a2,104 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201788:	16f00593          	li	a1,367
ffffffffc020178c:	00004517          	auipc	a0,0x4
ffffffffc0201790:	f2c50513          	addi	a0,a0,-212 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201794:	a41fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201798:	86da                	mv	a3,s6
ffffffffc020179a:	00004617          	auipc	a2,0x4
ffffffffc020179e:	ef660613          	addi	a2,a2,-266 # ffffffffc0205690 <commands+0x840>
ffffffffc02017a2:	16e00593          	li	a1,366
ffffffffc02017a6:	00004517          	auipc	a0,0x4
ffffffffc02017aa:	f1250513          	addi	a0,a0,-238 # ffffffffc02056b8 <commands+0x868>
ffffffffc02017ae:	a27fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02017b2:	86be                	mv	a3,a5
ffffffffc02017b4:	00004617          	auipc	a2,0x4
ffffffffc02017b8:	edc60613          	addi	a2,a2,-292 # ffffffffc0205690 <commands+0x840>
ffffffffc02017bc:	06900593          	li	a1,105
ffffffffc02017c0:	00004517          	auipc	a0,0x4
ffffffffc02017c4:	f2850513          	addi	a0,a0,-216 # ffffffffc02056e8 <commands+0x898>
ffffffffc02017c8:	a0dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02017cc:	00004697          	auipc	a3,0x4
ffffffffc02017d0:	2bc68693          	addi	a3,a3,700 # ffffffffc0205a88 <commands+0xc38>
ffffffffc02017d4:	00004617          	auipc	a2,0x4
ffffffffc02017d8:	01460613          	addi	a2,a2,20 # ffffffffc02057e8 <commands+0x998>
ffffffffc02017dc:	18800593          	li	a1,392
ffffffffc02017e0:	00004517          	auipc	a0,0x4
ffffffffc02017e4:	ed850513          	addi	a0,a0,-296 # ffffffffc02056b8 <commands+0x868>
ffffffffc02017e8:	9edfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02017ec:	00004697          	auipc	a3,0x4
ffffffffc02017f0:	25468693          	addi	a3,a3,596 # ffffffffc0205a40 <commands+0xbf0>
ffffffffc02017f4:	00004617          	auipc	a2,0x4
ffffffffc02017f8:	ff460613          	addi	a2,a2,-12 # ffffffffc02057e8 <commands+0x998>
ffffffffc02017fc:	18600593          	li	a1,390
ffffffffc0201800:	00004517          	auipc	a0,0x4
ffffffffc0201804:	eb850513          	addi	a0,a0,-328 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201808:	9cdfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020180c:	00004697          	auipc	a3,0x4
ffffffffc0201810:	26468693          	addi	a3,a3,612 # ffffffffc0205a70 <commands+0xc20>
ffffffffc0201814:	00004617          	auipc	a2,0x4
ffffffffc0201818:	fd460613          	addi	a2,a2,-44 # ffffffffc02057e8 <commands+0x998>
ffffffffc020181c:	18500593          	li	a1,389
ffffffffc0201820:	00004517          	auipc	a0,0x4
ffffffffc0201824:	e9850513          	addi	a0,a0,-360 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201828:	9adfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020182c:	00004697          	auipc	a3,0x4
ffffffffc0201830:	3c468693          	addi	a3,a3,964 # ffffffffc0205bf0 <commands+0xda0>
ffffffffc0201834:	00004617          	auipc	a2,0x4
ffffffffc0201838:	fb460613          	addi	a2,a2,-76 # ffffffffc02057e8 <commands+0x998>
ffffffffc020183c:	1a800593          	li	a1,424
ffffffffc0201840:	00004517          	auipc	a0,0x4
ffffffffc0201844:	e7850513          	addi	a0,a0,-392 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201848:	98dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020184c:	00004697          	auipc	a3,0x4
ffffffffc0201850:	36468693          	addi	a3,a3,868 # ffffffffc0205bb0 <commands+0xd60>
ffffffffc0201854:	00004617          	auipc	a2,0x4
ffffffffc0201858:	f9460613          	addi	a2,a2,-108 # ffffffffc02057e8 <commands+0x998>
ffffffffc020185c:	1a700593          	li	a1,423
ffffffffc0201860:	00004517          	auipc	a0,0x4
ffffffffc0201864:	e5850513          	addi	a0,a0,-424 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201868:	96dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020186c:	00004697          	auipc	a3,0x4
ffffffffc0201870:	32c68693          	addi	a3,a3,812 # ffffffffc0205b98 <commands+0xd48>
ffffffffc0201874:	00004617          	auipc	a2,0x4
ffffffffc0201878:	f7460613          	addi	a2,a2,-140 # ffffffffc02057e8 <commands+0x998>
ffffffffc020187c:	1a600593          	li	a1,422
ffffffffc0201880:	00004517          	auipc	a0,0x4
ffffffffc0201884:	e3850513          	addi	a0,a0,-456 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201888:	94dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020188c:	86be                	mv	a3,a5
ffffffffc020188e:	00004617          	auipc	a2,0x4
ffffffffc0201892:	e0260613          	addi	a2,a2,-510 # ffffffffc0205690 <commands+0x840>
ffffffffc0201896:	16d00593          	li	a1,365
ffffffffc020189a:	00004517          	auipc	a0,0x4
ffffffffc020189e:	e1e50513          	addi	a0,a0,-482 # ffffffffc02056b8 <commands+0x868>
ffffffffc02018a2:	933fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018a6:	00004617          	auipc	a2,0x4
ffffffffc02018aa:	ec260613          	addi	a2,a2,-318 # ffffffffc0205768 <commands+0x918>
ffffffffc02018ae:	07f00593          	li	a1,127
ffffffffc02018b2:	00004517          	auipc	a0,0x4
ffffffffc02018b6:	e0650513          	addi	a0,a0,-506 # ffffffffc02056b8 <commands+0x868>
ffffffffc02018ba:	91bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02018be:	00004697          	auipc	a3,0x4
ffffffffc02018c2:	36268693          	addi	a3,a3,866 # ffffffffc0205c20 <commands+0xdd0>
ffffffffc02018c6:	00004617          	auipc	a2,0x4
ffffffffc02018ca:	f2260613          	addi	a2,a2,-222 # ffffffffc02057e8 <commands+0x998>
ffffffffc02018ce:	1ac00593          	li	a1,428
ffffffffc02018d2:	00004517          	auipc	a0,0x4
ffffffffc02018d6:	de650513          	addi	a0,a0,-538 # ffffffffc02056b8 <commands+0x868>
ffffffffc02018da:	8fbfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02018de:	00004697          	auipc	a3,0x4
ffffffffc02018e2:	1d268693          	addi	a3,a3,466 # ffffffffc0205ab0 <commands+0xc60>
ffffffffc02018e6:	00004617          	auipc	a2,0x4
ffffffffc02018ea:	f0260613          	addi	a2,a2,-254 # ffffffffc02057e8 <commands+0x998>
ffffffffc02018ee:	1b800593          	li	a1,440
ffffffffc02018f2:	00004517          	auipc	a0,0x4
ffffffffc02018f6:	dc650513          	addi	a0,a0,-570 # ffffffffc02056b8 <commands+0x868>
ffffffffc02018fa:	8dbfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02018fe:	00004697          	auipc	a3,0x4
ffffffffc0201902:	00268693          	addi	a3,a3,2 # ffffffffc0205900 <commands+0xab0>
ffffffffc0201906:	00004617          	auipc	a2,0x4
ffffffffc020190a:	ee260613          	addi	a2,a2,-286 # ffffffffc02057e8 <commands+0x998>
ffffffffc020190e:	16b00593          	li	a1,363
ffffffffc0201912:	00004517          	auipc	a0,0x4
ffffffffc0201916:	da650513          	addi	a0,a0,-602 # ffffffffc02056b8 <commands+0x868>
ffffffffc020191a:	8bbfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020191e:	00004697          	auipc	a3,0x4
ffffffffc0201922:	fca68693          	addi	a3,a3,-54 # ffffffffc02058e8 <commands+0xa98>
ffffffffc0201926:	00004617          	auipc	a2,0x4
ffffffffc020192a:	ec260613          	addi	a2,a2,-318 # ffffffffc02057e8 <commands+0x998>
ffffffffc020192e:	16a00593          	li	a1,362
ffffffffc0201932:	00004517          	auipc	a0,0x4
ffffffffc0201936:	d8650513          	addi	a0,a0,-634 # ffffffffc02056b8 <commands+0x868>
ffffffffc020193a:	89bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020193e:	00004697          	auipc	a3,0x4
ffffffffc0201942:	efa68693          	addi	a3,a3,-262 # ffffffffc0205838 <commands+0x9e8>
ffffffffc0201946:	00004617          	auipc	a2,0x4
ffffffffc020194a:	ea260613          	addi	a2,a2,-350 # ffffffffc02057e8 <commands+0x998>
ffffffffc020194e:	16200593          	li	a1,354
ffffffffc0201952:	00004517          	auipc	a0,0x4
ffffffffc0201956:	d6650513          	addi	a0,a0,-666 # ffffffffc02056b8 <commands+0x868>
ffffffffc020195a:	87bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020195e:	00004697          	auipc	a3,0x4
ffffffffc0201962:	f3268693          	addi	a3,a3,-206 # ffffffffc0205890 <commands+0xa40>
ffffffffc0201966:	00004617          	auipc	a2,0x4
ffffffffc020196a:	e8260613          	addi	a2,a2,-382 # ffffffffc02057e8 <commands+0x998>
ffffffffc020196e:	16900593          	li	a1,361
ffffffffc0201972:	00004517          	auipc	a0,0x4
ffffffffc0201976:	d4650513          	addi	a0,a0,-698 # ffffffffc02056b8 <commands+0x868>
ffffffffc020197a:	85bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020197e:	00004697          	auipc	a3,0x4
ffffffffc0201982:	ee268693          	addi	a3,a3,-286 # ffffffffc0205860 <commands+0xa10>
ffffffffc0201986:	00004617          	auipc	a2,0x4
ffffffffc020198a:	e6260613          	addi	a2,a2,-414 # ffffffffc02057e8 <commands+0x998>
ffffffffc020198e:	16600593          	li	a1,358
ffffffffc0201992:	00004517          	auipc	a0,0x4
ffffffffc0201996:	d2650513          	addi	a0,a0,-730 # ffffffffc02056b8 <commands+0x868>
ffffffffc020199a:	83bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020199e:	00004697          	auipc	a3,0x4
ffffffffc02019a2:	0a268693          	addi	a3,a3,162 # ffffffffc0205a40 <commands+0xbf0>
ffffffffc02019a6:	00004617          	auipc	a2,0x4
ffffffffc02019aa:	e4260613          	addi	a2,a2,-446 # ffffffffc02057e8 <commands+0x998>
ffffffffc02019ae:	18200593          	li	a1,386
ffffffffc02019b2:	00004517          	auipc	a0,0x4
ffffffffc02019b6:	d0650513          	addi	a0,a0,-762 # ffffffffc02056b8 <commands+0x868>
ffffffffc02019ba:	81bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02019be:	00004697          	auipc	a3,0x4
ffffffffc02019c2:	f4268693          	addi	a3,a3,-190 # ffffffffc0205900 <commands+0xab0>
ffffffffc02019c6:	00004617          	auipc	a2,0x4
ffffffffc02019ca:	e2260613          	addi	a2,a2,-478 # ffffffffc02057e8 <commands+0x998>
ffffffffc02019ce:	18100593          	li	a1,385
ffffffffc02019d2:	00004517          	auipc	a0,0x4
ffffffffc02019d6:	ce650513          	addi	a0,a0,-794 # ffffffffc02056b8 <commands+0x868>
ffffffffc02019da:	ffafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019de:	00004697          	auipc	a3,0x4
ffffffffc02019e2:	07a68693          	addi	a3,a3,122 # ffffffffc0205a58 <commands+0xc08>
ffffffffc02019e6:	00004617          	auipc	a2,0x4
ffffffffc02019ea:	e0260613          	addi	a2,a2,-510 # ffffffffc02057e8 <commands+0x998>
ffffffffc02019ee:	17e00593          	li	a1,382
ffffffffc02019f2:	00004517          	auipc	a0,0x4
ffffffffc02019f6:	cc650513          	addi	a0,a0,-826 # ffffffffc02056b8 <commands+0x868>
ffffffffc02019fa:	fdafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02019fe:	00004697          	auipc	a3,0x4
ffffffffc0201a02:	25a68693          	addi	a3,a3,602 # ffffffffc0205c58 <commands+0xe08>
ffffffffc0201a06:	00004617          	auipc	a2,0x4
ffffffffc0201a0a:	de260613          	addi	a2,a2,-542 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201a0e:	1af00593          	li	a1,431
ffffffffc0201a12:	00004517          	auipc	a0,0x4
ffffffffc0201a16:	ca650513          	addi	a0,a0,-858 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201a1a:	fbafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201a1e:	00004697          	auipc	a3,0x4
ffffffffc0201a22:	09268693          	addi	a3,a3,146 # ffffffffc0205ab0 <commands+0xc60>
ffffffffc0201a26:	00004617          	auipc	a2,0x4
ffffffffc0201a2a:	dc260613          	addi	a2,a2,-574 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201a2e:	19000593          	li	a1,400
ffffffffc0201a32:	00004517          	auipc	a0,0x4
ffffffffc0201a36:	c8650513          	addi	a0,a0,-890 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201a3a:	f9afe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a3e:	00004697          	auipc	a3,0x4
ffffffffc0201a42:	10a68693          	addi	a3,a3,266 # ffffffffc0205b48 <commands+0xcf8>
ffffffffc0201a46:	00004617          	auipc	a2,0x4
ffffffffc0201a4a:	da260613          	addi	a2,a2,-606 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201a4e:	1a100593          	li	a1,417
ffffffffc0201a52:	00004517          	auipc	a0,0x4
ffffffffc0201a56:	c6650513          	addi	a0,a0,-922 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201a5a:	f7afe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201a5e:	00004697          	auipc	a3,0x4
ffffffffc0201a62:	d6a68693          	addi	a3,a3,-662 # ffffffffc02057c8 <commands+0x978>
ffffffffc0201a66:	00004617          	auipc	a2,0x4
ffffffffc0201a6a:	d8260613          	addi	a2,a2,-638 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201a6e:	16000593          	li	a1,352
ffffffffc0201a72:	00004517          	auipc	a0,0x4
ffffffffc0201a76:	c4650513          	addi	a0,a0,-954 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201a7a:	f5afe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201a7e:	00004617          	auipc	a2,0x4
ffffffffc0201a82:	cea60613          	addi	a2,a2,-790 # ffffffffc0205768 <commands+0x918>
ffffffffc0201a86:	0c300593          	li	a1,195
ffffffffc0201a8a:	00004517          	auipc	a0,0x4
ffffffffc0201a8e:	c2e50513          	addi	a0,a0,-978 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201a92:	f42fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201a96 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201a96:	12058073          	sfence.vma	a1
}
ffffffffc0201a9a:	8082                	ret

ffffffffc0201a9c <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a9c:	7179                	addi	sp,sp,-48
ffffffffc0201a9e:	e84a                	sd	s2,16(sp)
ffffffffc0201aa0:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201aa2:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201aa4:	f022                	sd	s0,32(sp)
ffffffffc0201aa6:	ec26                	sd	s1,24(sp)
ffffffffc0201aa8:	e44e                	sd	s3,8(sp)
ffffffffc0201aaa:	f406                	sd	ra,40(sp)
ffffffffc0201aac:	84ae                	mv	s1,a1
ffffffffc0201aae:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201ab0:	8f6ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0201ab4:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201ab6:	cd19                	beqz	a0,ffffffffc0201ad4 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201ab8:	85aa                	mv	a1,a0
ffffffffc0201aba:	86ce                	mv	a3,s3
ffffffffc0201abc:	8626                	mv	a2,s1
ffffffffc0201abe:	854a                	mv	a0,s2
ffffffffc0201ac0:	c92ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc0201ac4:	ed39                	bnez	a0,ffffffffc0201b22 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201ac6:	00014797          	auipc	a5,0x14
ffffffffc0201aca:	9e278793          	addi	a5,a5,-1566 # ffffffffc02154a8 <swap_init_ok>
ffffffffc0201ace:	439c                	lw	a5,0(a5)
ffffffffc0201ad0:	2781                	sext.w	a5,a5
ffffffffc0201ad2:	eb89                	bnez	a5,ffffffffc0201ae4 <pgdir_alloc_page+0x48>
}
ffffffffc0201ad4:	8522                	mv	a0,s0
ffffffffc0201ad6:	70a2                	ld	ra,40(sp)
ffffffffc0201ad8:	7402                	ld	s0,32(sp)
ffffffffc0201ada:	64e2                	ld	s1,24(sp)
ffffffffc0201adc:	6942                	ld	s2,16(sp)
ffffffffc0201ade:	69a2                	ld	s3,8(sp)
ffffffffc0201ae0:	6145                	addi	sp,sp,48
ffffffffc0201ae2:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201ae4:	00014797          	auipc	a5,0x14
ffffffffc0201ae8:	a1478793          	addi	a5,a5,-1516 # ffffffffc02154f8 <check_mm_struct>
ffffffffc0201aec:	6388                	ld	a0,0(a5)
ffffffffc0201aee:	4681                	li	a3,0
ffffffffc0201af0:	8622                	mv	a2,s0
ffffffffc0201af2:	85a6                	mv	a1,s1
ffffffffc0201af4:	43e010ef          	jal	ra,ffffffffc0202f32 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201af8:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201afa:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0201afc:	4785                	li	a5,1
ffffffffc0201afe:	fcf70be3          	beq	a4,a5,ffffffffc0201ad4 <pgdir_alloc_page+0x38>
ffffffffc0201b02:	00004697          	auipc	a3,0x4
ffffffffc0201b06:	bf668693          	addi	a3,a3,-1034 # ffffffffc02056f8 <commands+0x8a8>
ffffffffc0201b0a:	00004617          	auipc	a2,0x4
ffffffffc0201b0e:	cde60613          	addi	a2,a2,-802 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201b12:	14800593          	li	a1,328
ffffffffc0201b16:	00004517          	auipc	a0,0x4
ffffffffc0201b1a:	ba250513          	addi	a0,a0,-1118 # ffffffffc02056b8 <commands+0x868>
ffffffffc0201b1e:	eb6fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
            free_page(page);
ffffffffc0201b22:	8522                	mv	a0,s0
ffffffffc0201b24:	4585                	li	a1,1
ffffffffc0201b26:	908ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
            return NULL;
ffffffffc0201b2a:	4401                	li	s0,0
ffffffffc0201b2c:	b765                	j	ffffffffc0201ad4 <pgdir_alloc_page+0x38>

ffffffffc0201b2e <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201b2e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201b30:	00004697          	auipc	a3,0x4
ffffffffc0201b34:	17068693          	addi	a3,a3,368 # ffffffffc0205ca0 <commands+0xe50>
ffffffffc0201b38:	00004617          	auipc	a2,0x4
ffffffffc0201b3c:	cb060613          	addi	a2,a2,-848 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201b40:	07e00593          	li	a1,126
ffffffffc0201b44:	00004517          	auipc	a0,0x4
ffffffffc0201b48:	17c50513          	addi	a0,a0,380 # ffffffffc0205cc0 <commands+0xe70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201b4c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201b4e:	e86fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201b52 <mm_create>:
mm_create(void) {
ffffffffc0201b52:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201b54:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201b58:	e022                	sd	s0,0(sp)
ffffffffc0201b5a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201b5c:	273000ef          	jal	ra,ffffffffc02025ce <kmalloc>
ffffffffc0201b60:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201b62:	c115                	beqz	a0,ffffffffc0201b86 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b64:	00014797          	auipc	a5,0x14
ffffffffc0201b68:	94478793          	addi	a5,a5,-1724 # ffffffffc02154a8 <swap_init_ok>
ffffffffc0201b6c:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201b6e:	e408                	sd	a0,8(s0)
ffffffffc0201b70:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201b72:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201b76:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201b7a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b7e:	2781                	sext.w	a5,a5
ffffffffc0201b80:	eb81                	bnez	a5,ffffffffc0201b90 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201b82:	02053423          	sd	zero,40(a0)
}
ffffffffc0201b86:	8522                	mv	a0,s0
ffffffffc0201b88:	60a2                	ld	ra,8(sp)
ffffffffc0201b8a:	6402                	ld	s0,0(sp)
ffffffffc0201b8c:	0141                	addi	sp,sp,16
ffffffffc0201b8e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b90:	392010ef          	jal	ra,ffffffffc0202f22 <swap_init_mm>
}
ffffffffc0201b94:	8522                	mv	a0,s0
ffffffffc0201b96:	60a2                	ld	ra,8(sp)
ffffffffc0201b98:	6402                	ld	s0,0(sp)
ffffffffc0201b9a:	0141                	addi	sp,sp,16
ffffffffc0201b9c:	8082                	ret

ffffffffc0201b9e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201b9e:	1101                	addi	sp,sp,-32
ffffffffc0201ba0:	e04a                	sd	s2,0(sp)
ffffffffc0201ba2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201ba4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201ba8:	e822                	sd	s0,16(sp)
ffffffffc0201baa:	e426                	sd	s1,8(sp)
ffffffffc0201bac:	ec06                	sd	ra,24(sp)
ffffffffc0201bae:	84ae                	mv	s1,a1
ffffffffc0201bb0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201bb2:	21d000ef          	jal	ra,ffffffffc02025ce <kmalloc>
    if (vma != NULL) {
ffffffffc0201bb6:	c509                	beqz	a0,ffffffffc0201bc0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201bb8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201bbc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201bbe:	cd00                	sw	s0,24(a0)
}
ffffffffc0201bc0:	60e2                	ld	ra,24(sp)
ffffffffc0201bc2:	6442                	ld	s0,16(sp)
ffffffffc0201bc4:	64a2                	ld	s1,8(sp)
ffffffffc0201bc6:	6902                	ld	s2,0(sp)
ffffffffc0201bc8:	6105                	addi	sp,sp,32
ffffffffc0201bca:	8082                	ret

ffffffffc0201bcc <find_vma>:
    if (mm != NULL) {
ffffffffc0201bcc:	c51d                	beqz	a0,ffffffffc0201bfa <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201bce:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201bd0:	c781                	beqz	a5,ffffffffc0201bd8 <find_vma+0xc>
ffffffffc0201bd2:	6798                	ld	a4,8(a5)
ffffffffc0201bd4:	02e5f663          	bgeu	a1,a4,ffffffffc0201c00 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201bd8:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201bda:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201bdc:	00f50f63          	beq	a0,a5,ffffffffc0201bfa <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201be0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201be4:	fee5ebe3          	bltu	a1,a4,ffffffffc0201bda <find_vma+0xe>
ffffffffc0201be8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201bec:	fee5f7e3          	bgeu	a1,a4,ffffffffc0201bda <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201bf0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201bf2:	c781                	beqz	a5,ffffffffc0201bfa <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201bf4:	e91c                	sd	a5,16(a0)
}
ffffffffc0201bf6:	853e                	mv	a0,a5
ffffffffc0201bf8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201bfa:	4781                	li	a5,0
}
ffffffffc0201bfc:	853e                	mv	a0,a5
ffffffffc0201bfe:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201c00:	6b98                	ld	a4,16(a5)
ffffffffc0201c02:	fce5fbe3          	bgeu	a1,a4,ffffffffc0201bd8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201c06:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201c08:	b7fd                	j	ffffffffc0201bf6 <find_vma+0x2a>

ffffffffc0201c0a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c0a:	6590                	ld	a2,8(a1)
ffffffffc0201c0c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201c10:	1141                	addi	sp,sp,-16
ffffffffc0201c12:	e406                	sd	ra,8(sp)
ffffffffc0201c14:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c16:	01066863          	bltu	a2,a6,ffffffffc0201c26 <insert_vma_struct+0x1c>
ffffffffc0201c1a:	a8b9                	j	ffffffffc0201c78 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201c1c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201c20:	04d66763          	bltu	a2,a3,ffffffffc0201c6e <insert_vma_struct+0x64>
ffffffffc0201c24:	873e                	mv	a4,a5
ffffffffc0201c26:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201c28:	fef51ae3          	bne	a0,a5,ffffffffc0201c1c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201c2c:	02a70463          	beq	a4,a0,ffffffffc0201c54 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201c30:	ff073683          	ld	a3,-16(a4) # 7fff0 <BASE_ADDRESS-0xffffffffc0180010>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201c34:	fe873883          	ld	a7,-24(a4)
ffffffffc0201c38:	08d8f063          	bgeu	a7,a3,ffffffffc0201cb8 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c3c:	04d66e63          	bltu	a2,a3,ffffffffc0201c98 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201c40:	00f50a63          	beq	a0,a5,ffffffffc0201c54 <insert_vma_struct+0x4a>
ffffffffc0201c44:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c48:	0506e863          	bltu	a3,a6,ffffffffc0201c98 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201c4c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201c50:	02c6f263          	bgeu	a3,a2,ffffffffc0201c74 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201c54:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201c56:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201c58:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201c5c:	e390                	sd	a2,0(a5)
ffffffffc0201c5e:	e710                	sd	a2,8(a4)
}
ffffffffc0201c60:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201c62:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201c64:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201c66:	2685                	addiw	a3,a3,1
ffffffffc0201c68:	d114                	sw	a3,32(a0)
}
ffffffffc0201c6a:	0141                	addi	sp,sp,16
ffffffffc0201c6c:	8082                	ret
    if (le_prev != list) {
ffffffffc0201c6e:	fca711e3          	bne	a4,a0,ffffffffc0201c30 <insert_vma_struct+0x26>
ffffffffc0201c72:	bfd9                	j	ffffffffc0201c48 <insert_vma_struct+0x3e>
ffffffffc0201c74:	ebbff0ef          	jal	ra,ffffffffc0201b2e <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c78:	00004697          	auipc	a3,0x4
ffffffffc0201c7c:	0f868693          	addi	a3,a3,248 # ffffffffc0205d70 <commands+0xf20>
ffffffffc0201c80:	00004617          	auipc	a2,0x4
ffffffffc0201c84:	b6860613          	addi	a2,a2,-1176 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201c88:	08500593          	li	a1,133
ffffffffc0201c8c:	00004517          	auipc	a0,0x4
ffffffffc0201c90:	03450513          	addi	a0,a0,52 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0201c94:	d40fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c98:	00004697          	auipc	a3,0x4
ffffffffc0201c9c:	11868693          	addi	a3,a3,280 # ffffffffc0205db0 <commands+0xf60>
ffffffffc0201ca0:	00004617          	auipc	a2,0x4
ffffffffc0201ca4:	b4860613          	addi	a2,a2,-1208 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201ca8:	07d00593          	li	a1,125
ffffffffc0201cac:	00004517          	auipc	a0,0x4
ffffffffc0201cb0:	01450513          	addi	a0,a0,20 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0201cb4:	d20fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201cb8:	00004697          	auipc	a3,0x4
ffffffffc0201cbc:	0d868693          	addi	a3,a3,216 # ffffffffc0205d90 <commands+0xf40>
ffffffffc0201cc0:	00004617          	auipc	a2,0x4
ffffffffc0201cc4:	b2860613          	addi	a2,a2,-1240 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201cc8:	07c00593          	li	a1,124
ffffffffc0201ccc:	00004517          	auipc	a0,0x4
ffffffffc0201cd0:	ff450513          	addi	a0,a0,-12 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0201cd4:	d00fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201cd8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201cd8:	1141                	addi	sp,sp,-16
ffffffffc0201cda:	e022                	sd	s0,0(sp)
ffffffffc0201cdc:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201cde:	6508                	ld	a0,8(a0)
ffffffffc0201ce0:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201ce2:	00a40c63          	beq	s0,a0,ffffffffc0201cfa <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ce6:	6118                	ld	a4,0(a0)
ffffffffc0201ce8:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201cea:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201cec:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201cee:	e398                	sd	a4,0(a5)
ffffffffc0201cf0:	19b000ef          	jal	ra,ffffffffc020268a <kfree>
    return listelm->next;
ffffffffc0201cf4:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201cf6:	fea418e3          	bne	s0,a0,ffffffffc0201ce6 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0201cfa:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201cfc:	6402                	ld	s0,0(sp)
ffffffffc0201cfe:	60a2                	ld	ra,8(sp)
ffffffffc0201d00:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0201d02:	1890006f          	j	ffffffffc020268a <kfree>

ffffffffc0201d06 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201d06:	7139                	addi	sp,sp,-64
ffffffffc0201d08:	f822                	sd	s0,48(sp)
ffffffffc0201d0a:	f426                	sd	s1,40(sp)
ffffffffc0201d0c:	fc06                	sd	ra,56(sp)
ffffffffc0201d0e:	f04a                	sd	s2,32(sp)
ffffffffc0201d10:	ec4e                	sd	s3,24(sp)
ffffffffc0201d12:	e852                	sd	s4,16(sp)
ffffffffc0201d14:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0201d16:	e3dff0ef          	jal	ra,ffffffffc0201b52 <mm_create>
    assert(mm != NULL);
ffffffffc0201d1a:	842a                	mv	s0,a0
ffffffffc0201d1c:	03200493          	li	s1,50
ffffffffc0201d20:	e919                	bnez	a0,ffffffffc0201d36 <vmm_init+0x30>
ffffffffc0201d22:	a989                	j	ffffffffc0202174 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0201d24:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d26:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d28:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201d2c:	14ed                	addi	s1,s1,-5
ffffffffc0201d2e:	8522                	mv	a0,s0
ffffffffc0201d30:	edbff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201d34:	c88d                	beqz	s1,ffffffffc0201d66 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d36:	03000513          	li	a0,48
ffffffffc0201d3a:	095000ef          	jal	ra,ffffffffc02025ce <kmalloc>
ffffffffc0201d3e:	85aa                	mv	a1,a0
ffffffffc0201d40:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201d44:	f165                	bnez	a0,ffffffffc0201d24 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201d46:	00004697          	auipc	a3,0x4
ffffffffc0201d4a:	2b268693          	addi	a3,a3,690 # ffffffffc0205ff8 <commands+0x11a8>
ffffffffc0201d4e:	00004617          	auipc	a2,0x4
ffffffffc0201d52:	a9a60613          	addi	a2,a2,-1382 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201d56:	0c900593          	li	a1,201
ffffffffc0201d5a:	00004517          	auipc	a0,0x4
ffffffffc0201d5e:	f6650513          	addi	a0,a0,-154 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0201d62:	c72fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201d66:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201d6a:	1f900913          	li	s2,505
ffffffffc0201d6e:	a819                	j	ffffffffc0201d84 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201d70:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d72:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d74:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201d78:	0495                	addi	s1,s1,5
ffffffffc0201d7a:	8522                	mv	a0,s0
ffffffffc0201d7c:	e8fff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201d80:	03248a63          	beq	s1,s2,ffffffffc0201db4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d84:	03000513          	li	a0,48
ffffffffc0201d88:	047000ef          	jal	ra,ffffffffc02025ce <kmalloc>
ffffffffc0201d8c:	85aa                	mv	a1,a0
ffffffffc0201d8e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201d92:	fd79                	bnez	a0,ffffffffc0201d70 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201d94:	00004697          	auipc	a3,0x4
ffffffffc0201d98:	26468693          	addi	a3,a3,612 # ffffffffc0205ff8 <commands+0x11a8>
ffffffffc0201d9c:	00004617          	auipc	a2,0x4
ffffffffc0201da0:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201da4:	0cf00593          	li	a1,207
ffffffffc0201da8:	00004517          	auipc	a0,0x4
ffffffffc0201dac:	f1850513          	addi	a0,a0,-232 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0201db0:	c24fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201db4:	6418                	ld	a4,8(s0)
ffffffffc0201db6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201db8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201dbc:	2ee40063          	beq	s0,a4,ffffffffc020209c <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201dc0:	fe873603          	ld	a2,-24(a4)
ffffffffc0201dc4:	ffe78693          	addi	a3,a5,-2
ffffffffc0201dc8:	24d61a63          	bne	a2,a3,ffffffffc020201c <vmm_init+0x316>
ffffffffc0201dcc:	ff073683          	ld	a3,-16(a4)
ffffffffc0201dd0:	24f69663          	bne	a3,a5,ffffffffc020201c <vmm_init+0x316>
ffffffffc0201dd4:	0795                	addi	a5,a5,5
ffffffffc0201dd6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201dd8:	feb792e3          	bne	a5,a1,ffffffffc0201dbc <vmm_init+0xb6>
ffffffffc0201ddc:	491d                	li	s2,7
ffffffffc0201dde:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201de0:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201de4:	85a6                	mv	a1,s1
ffffffffc0201de6:	8522                	mv	a0,s0
ffffffffc0201de8:	de5ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201dec:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0201dee:	30050763          	beqz	a0,ffffffffc02020fc <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201df2:	00148593          	addi	a1,s1,1
ffffffffc0201df6:	8522                	mv	a0,s0
ffffffffc0201df8:	dd5ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201dfc:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201dfe:	2c050f63          	beqz	a0,ffffffffc02020dc <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201e02:	85ca                	mv	a1,s2
ffffffffc0201e04:	8522                	mv	a0,s0
ffffffffc0201e06:	dc7ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
        assert(vma3 == NULL);
ffffffffc0201e0a:	2a051963          	bnez	a0,ffffffffc02020bc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201e0e:	00348593          	addi	a1,s1,3
ffffffffc0201e12:	8522                	mv	a0,s0
ffffffffc0201e14:	db9ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
        assert(vma4 == NULL);
ffffffffc0201e18:	32051263          	bnez	a0,ffffffffc020213c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201e1c:	00448593          	addi	a1,s1,4
ffffffffc0201e20:	8522                	mv	a0,s0
ffffffffc0201e22:	dabff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
        assert(vma5 == NULL);
ffffffffc0201e26:	2e051b63          	bnez	a0,ffffffffc020211c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201e2a:	008a3783          	ld	a5,8(s4)
ffffffffc0201e2e:	20979763          	bne	a5,s1,ffffffffc020203c <vmm_init+0x336>
ffffffffc0201e32:	010a3783          	ld	a5,16(s4)
ffffffffc0201e36:	21279363          	bne	a5,s2,ffffffffc020203c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201e3a:	0089b783          	ld	a5,8(s3) # fffffffffff80008 <end+0x3fd6aa08>
ffffffffc0201e3e:	20979f63          	bne	a5,s1,ffffffffc020205c <vmm_init+0x356>
ffffffffc0201e42:	0109b783          	ld	a5,16(s3)
ffffffffc0201e46:	21279b63          	bne	a5,s2,ffffffffc020205c <vmm_init+0x356>
ffffffffc0201e4a:	0495                	addi	s1,s1,5
ffffffffc0201e4c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201e4e:	f9549be3          	bne	s1,s5,ffffffffc0201de4 <vmm_init+0xde>
ffffffffc0201e52:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201e54:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201e56:	85a6                	mv	a1,s1
ffffffffc0201e58:	8522                	mv	a0,s0
ffffffffc0201e5a:	d73ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201e5e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201e62:	c90d                	beqz	a0,ffffffffc0201e94 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201e64:	6914                	ld	a3,16(a0)
ffffffffc0201e66:	6510                	ld	a2,8(a0)
ffffffffc0201e68:	00004517          	auipc	a0,0x4
ffffffffc0201e6c:	07850513          	addi	a0,a0,120 # ffffffffc0205ee0 <commands+0x1090>
ffffffffc0201e70:	a60fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201e74:	00004697          	auipc	a3,0x4
ffffffffc0201e78:	09468693          	addi	a3,a3,148 # ffffffffc0205f08 <commands+0x10b8>
ffffffffc0201e7c:	00004617          	auipc	a2,0x4
ffffffffc0201e80:	96c60613          	addi	a2,a2,-1684 # ffffffffc02057e8 <commands+0x998>
ffffffffc0201e84:	0f100593          	li	a1,241
ffffffffc0201e88:	00004517          	auipc	a0,0x4
ffffffffc0201e8c:	e3850513          	addi	a0,a0,-456 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0201e90:	b44fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201e94:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0201e96:	fd2490e3          	bne	s1,s2,ffffffffc0201e56 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201e9a:	8522                	mv	a0,s0
ffffffffc0201e9c:	e3dff0ef          	jal	ra,ffffffffc0201cd8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201ea0:	00004517          	auipc	a0,0x4
ffffffffc0201ea4:	08050513          	addi	a0,a0,128 # ffffffffc0205f20 <commands+0x10d0>
ffffffffc0201ea8:	a28fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201eac:	dc9fe0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc0201eb0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0201eb2:	ca1ff0ef          	jal	ra,ffffffffc0201b52 <mm_create>
ffffffffc0201eb6:	00013797          	auipc	a5,0x13
ffffffffc0201eba:	64a7b123          	sd	a0,1602(a5) # ffffffffc02154f8 <check_mm_struct>
ffffffffc0201ebe:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0201ec0:	36050663          	beqz	a0,ffffffffc020222c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ec4:	00013797          	auipc	a5,0x13
ffffffffc0201ec8:	5bc78793          	addi	a5,a5,1468 # ffffffffc0215480 <boot_pgdir>
ffffffffc0201ecc:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0201ed0:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ed4:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0201ed8:	2c079e63          	bnez	a5,ffffffffc02021b4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201edc:	03000513          	li	a0,48
ffffffffc0201ee0:	6ee000ef          	jal	ra,ffffffffc02025ce <kmalloc>
ffffffffc0201ee4:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0201ee6:	18050b63          	beqz	a0,ffffffffc020207c <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0201eea:	002007b7          	lui	a5,0x200
ffffffffc0201eee:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0201ef0:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201ef2:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201ef4:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201ef6:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0201ef8:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201efc:	d0fff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201f00:	10000593          	li	a1,256
ffffffffc0201f04:	8526                	mv	a0,s1
ffffffffc0201f06:	cc7ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201f0a:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0201f0e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201f12:	2ca41163          	bne	s0,a0,ffffffffc02021d4 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0201f16:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0201f1a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0201f1c:	fee79de3          	bne	a5,a4,ffffffffc0201f16 <vmm_init+0x210>
        sum += i;
ffffffffc0201f20:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201f22:	10000793          	li	a5,256
        sum += i;
ffffffffc0201f26:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201f2a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201f2e:	0007c683          	lbu	a3,0(a5)
ffffffffc0201f32:	0785                	addi	a5,a5,1
ffffffffc0201f34:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201f36:	fec79ce3          	bne	a5,a2,ffffffffc0201f2e <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0201f3a:	2c071963          	bnez	a4,ffffffffc020220c <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f3e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201f42:	00013a97          	auipc	s5,0x13
ffffffffc0201f46:	546a8a93          	addi	s5,s5,1350 # ffffffffc0215488 <npage>
ffffffffc0201f4a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f4e:	078a                	slli	a5,a5,0x2
ffffffffc0201f50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f52:	20e7f563          	bgeu	a5,a4,ffffffffc020215c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f56:	00005697          	auipc	a3,0x5
ffffffffc0201f5a:	e8a68693          	addi	a3,a3,-374 # ffffffffc0206de0 <nbase>
ffffffffc0201f5e:	0006ba03          	ld	s4,0(a3)
ffffffffc0201f62:	414786b3          	sub	a3,a5,s4
ffffffffc0201f66:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201f68:	8699                	srai	a3,a3,0x6
ffffffffc0201f6a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201f6c:	00c69793          	slli	a5,a3,0xc
ffffffffc0201f70:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f72:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f74:	28e7f063          	bgeu	a5,a4,ffffffffc02021f4 <vmm_init+0x4ee>
ffffffffc0201f78:	00013797          	auipc	a5,0x13
ffffffffc0201f7c:	56878793          	addi	a5,a5,1384 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0201f80:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201f82:	4581                	li	a1,0
ffffffffc0201f84:	854a                	mv	a0,s2
ffffffffc0201f86:	9436                	add	s0,s0,a3
ffffffffc0201f88:	f57fe0ef          	jal	ra,ffffffffc0200ede <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f8c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201f8e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f92:	078a                	slli	a5,a5,0x2
ffffffffc0201f94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f96:	1ce7f363          	bgeu	a5,a4,ffffffffc020215c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f9a:	00013417          	auipc	s0,0x13
ffffffffc0201f9e:	55640413          	addi	s0,s0,1366 # ffffffffc02154f0 <pages>
ffffffffc0201fa2:	6008                	ld	a0,0(s0)
ffffffffc0201fa4:	414787b3          	sub	a5,a5,s4
ffffffffc0201fa8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201faa:	953e                	add	a0,a0,a5
ffffffffc0201fac:	4585                	li	a1,1
ffffffffc0201fae:	c81fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fb2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fb6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fba:	078a                	slli	a5,a5,0x2
ffffffffc0201fbc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fbe:	18e7ff63          	bgeu	a5,a4,ffffffffc020215c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc2:	6008                	ld	a0,0(s0)
ffffffffc0201fc4:	414787b3          	sub	a5,a5,s4
ffffffffc0201fc8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201fca:	4585                	li	a1,1
ffffffffc0201fcc:	953e                	add	a0,a0,a5
ffffffffc0201fce:	c61fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    pgdir[0] = 0;
ffffffffc0201fd2:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0201fd6:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201fda:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0201fde:	8526                	mv	a0,s1
ffffffffc0201fe0:	cf9ff0ef          	jal	ra,ffffffffc0201cd8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0201fe4:	00013797          	auipc	a5,0x13
ffffffffc0201fe8:	5007ba23          	sd	zero,1300(a5) # ffffffffc02154f8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201fec:	c89fe0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc0201ff0:	1aa99263          	bne	s3,a0,ffffffffc0202194 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201ff4:	00004517          	auipc	a0,0x4
ffffffffc0201ff8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0205fc0 <commands+0x1170>
ffffffffc0201ffc:	8d4fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202000:	7442                	ld	s0,48(sp)
ffffffffc0202002:	70e2                	ld	ra,56(sp)
ffffffffc0202004:	74a2                	ld	s1,40(sp)
ffffffffc0202006:	7902                	ld	s2,32(sp)
ffffffffc0202008:	69e2                	ld	s3,24(sp)
ffffffffc020200a:	6a42                	ld	s4,16(sp)
ffffffffc020200c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020200e:	00004517          	auipc	a0,0x4
ffffffffc0202012:	fd250513          	addi	a0,a0,-46 # ffffffffc0205fe0 <commands+0x1190>
}
ffffffffc0202016:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202018:	8b8fe06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020201c:	00004697          	auipc	a3,0x4
ffffffffc0202020:	ddc68693          	addi	a3,a3,-548 # ffffffffc0205df8 <commands+0xfa8>
ffffffffc0202024:	00003617          	auipc	a2,0x3
ffffffffc0202028:	7c460613          	addi	a2,a2,1988 # ffffffffc02057e8 <commands+0x998>
ffffffffc020202c:	0d800593          	li	a1,216
ffffffffc0202030:	00004517          	auipc	a0,0x4
ffffffffc0202034:	c9050513          	addi	a0,a0,-880 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202038:	99cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020203c:	00004697          	auipc	a3,0x4
ffffffffc0202040:	e4468693          	addi	a3,a3,-444 # ffffffffc0205e80 <commands+0x1030>
ffffffffc0202044:	00003617          	auipc	a2,0x3
ffffffffc0202048:	7a460613          	addi	a2,a2,1956 # ffffffffc02057e8 <commands+0x998>
ffffffffc020204c:	0e800593          	li	a1,232
ffffffffc0202050:	00004517          	auipc	a0,0x4
ffffffffc0202054:	c7050513          	addi	a0,a0,-912 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202058:	97cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020205c:	00004697          	auipc	a3,0x4
ffffffffc0202060:	e5468693          	addi	a3,a3,-428 # ffffffffc0205eb0 <commands+0x1060>
ffffffffc0202064:	00003617          	auipc	a2,0x3
ffffffffc0202068:	78460613          	addi	a2,a2,1924 # ffffffffc02057e8 <commands+0x998>
ffffffffc020206c:	0e900593          	li	a1,233
ffffffffc0202070:	00004517          	auipc	a0,0x4
ffffffffc0202074:	c5050513          	addi	a0,a0,-944 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202078:	95cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(vma != NULL);
ffffffffc020207c:	00004697          	auipc	a3,0x4
ffffffffc0202080:	f7c68693          	addi	a3,a3,-132 # ffffffffc0205ff8 <commands+0x11a8>
ffffffffc0202084:	00003617          	auipc	a2,0x3
ffffffffc0202088:	76460613          	addi	a2,a2,1892 # ffffffffc02057e8 <commands+0x998>
ffffffffc020208c:	10800593          	li	a1,264
ffffffffc0202090:	00004517          	auipc	a0,0x4
ffffffffc0202094:	c3050513          	addi	a0,a0,-976 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202098:	93cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020209c:	00004697          	auipc	a3,0x4
ffffffffc02020a0:	d4468693          	addi	a3,a3,-700 # ffffffffc0205de0 <commands+0xf90>
ffffffffc02020a4:	00003617          	auipc	a2,0x3
ffffffffc02020a8:	74460613          	addi	a2,a2,1860 # ffffffffc02057e8 <commands+0x998>
ffffffffc02020ac:	0d600593          	li	a1,214
ffffffffc02020b0:	00004517          	auipc	a0,0x4
ffffffffc02020b4:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc02020b8:	91cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma3 == NULL);
ffffffffc02020bc:	00004697          	auipc	a3,0x4
ffffffffc02020c0:	d9468693          	addi	a3,a3,-620 # ffffffffc0205e50 <commands+0x1000>
ffffffffc02020c4:	00003617          	auipc	a2,0x3
ffffffffc02020c8:	72460613          	addi	a2,a2,1828 # ffffffffc02057e8 <commands+0x998>
ffffffffc02020cc:	0e200593          	li	a1,226
ffffffffc02020d0:	00004517          	auipc	a0,0x4
ffffffffc02020d4:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc02020d8:	8fcfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2 != NULL);
ffffffffc02020dc:	00004697          	auipc	a3,0x4
ffffffffc02020e0:	d6468693          	addi	a3,a3,-668 # ffffffffc0205e40 <commands+0xff0>
ffffffffc02020e4:	00003617          	auipc	a2,0x3
ffffffffc02020e8:	70460613          	addi	a2,a2,1796 # ffffffffc02057e8 <commands+0x998>
ffffffffc02020ec:	0e000593          	li	a1,224
ffffffffc02020f0:	00004517          	auipc	a0,0x4
ffffffffc02020f4:	bd050513          	addi	a0,a0,-1072 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc02020f8:	8dcfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1 != NULL);
ffffffffc02020fc:	00004697          	auipc	a3,0x4
ffffffffc0202100:	d3468693          	addi	a3,a3,-716 # ffffffffc0205e30 <commands+0xfe0>
ffffffffc0202104:	00003617          	auipc	a2,0x3
ffffffffc0202108:	6e460613          	addi	a2,a2,1764 # ffffffffc02057e8 <commands+0x998>
ffffffffc020210c:	0de00593          	li	a1,222
ffffffffc0202110:	00004517          	auipc	a0,0x4
ffffffffc0202114:	bb050513          	addi	a0,a0,-1104 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202118:	8bcfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma5 == NULL);
ffffffffc020211c:	00004697          	auipc	a3,0x4
ffffffffc0202120:	d5468693          	addi	a3,a3,-684 # ffffffffc0205e70 <commands+0x1020>
ffffffffc0202124:	00003617          	auipc	a2,0x3
ffffffffc0202128:	6c460613          	addi	a2,a2,1732 # ffffffffc02057e8 <commands+0x998>
ffffffffc020212c:	0e600593          	li	a1,230
ffffffffc0202130:	00004517          	auipc	a0,0x4
ffffffffc0202134:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202138:	89cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma4 == NULL);
ffffffffc020213c:	00004697          	auipc	a3,0x4
ffffffffc0202140:	d2468693          	addi	a3,a3,-732 # ffffffffc0205e60 <commands+0x1010>
ffffffffc0202144:	00003617          	auipc	a2,0x3
ffffffffc0202148:	6a460613          	addi	a2,a2,1700 # ffffffffc02057e8 <commands+0x998>
ffffffffc020214c:	0e400593          	li	a1,228
ffffffffc0202150:	00004517          	auipc	a0,0x4
ffffffffc0202154:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202158:	87cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020215c:	00003617          	auipc	a2,0x3
ffffffffc0202160:	56c60613          	addi	a2,a2,1388 # ffffffffc02056c8 <commands+0x878>
ffffffffc0202164:	06200593          	li	a1,98
ffffffffc0202168:	00003517          	auipc	a0,0x3
ffffffffc020216c:	58050513          	addi	a0,a0,1408 # ffffffffc02056e8 <commands+0x898>
ffffffffc0202170:	864fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(mm != NULL);
ffffffffc0202174:	00004697          	auipc	a3,0x4
ffffffffc0202178:	c5c68693          	addi	a3,a3,-932 # ffffffffc0205dd0 <commands+0xf80>
ffffffffc020217c:	00003617          	auipc	a2,0x3
ffffffffc0202180:	66c60613          	addi	a2,a2,1644 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202184:	0c200593          	li	a1,194
ffffffffc0202188:	00004517          	auipc	a0,0x4
ffffffffc020218c:	b3850513          	addi	a0,a0,-1224 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202190:	844fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202194:	00004697          	auipc	a3,0x4
ffffffffc0202198:	e0468693          	addi	a3,a3,-508 # ffffffffc0205f98 <commands+0x1148>
ffffffffc020219c:	00003617          	auipc	a2,0x3
ffffffffc02021a0:	64c60613          	addi	a2,a2,1612 # ffffffffc02057e8 <commands+0x998>
ffffffffc02021a4:	12400593          	li	a1,292
ffffffffc02021a8:	00004517          	auipc	a0,0x4
ffffffffc02021ac:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc02021b0:	824fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02021b4:	00004697          	auipc	a3,0x4
ffffffffc02021b8:	da468693          	addi	a3,a3,-604 # ffffffffc0205f58 <commands+0x1108>
ffffffffc02021bc:	00003617          	auipc	a2,0x3
ffffffffc02021c0:	62c60613          	addi	a2,a2,1580 # ffffffffc02057e8 <commands+0x998>
ffffffffc02021c4:	10500593          	li	a1,261
ffffffffc02021c8:	00004517          	auipc	a0,0x4
ffffffffc02021cc:	af850513          	addi	a0,a0,-1288 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc02021d0:	804fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02021d4:	00004697          	auipc	a3,0x4
ffffffffc02021d8:	d9468693          	addi	a3,a3,-620 # ffffffffc0205f68 <commands+0x1118>
ffffffffc02021dc:	00003617          	auipc	a2,0x3
ffffffffc02021e0:	60c60613          	addi	a2,a2,1548 # ffffffffc02057e8 <commands+0x998>
ffffffffc02021e4:	10d00593          	li	a1,269
ffffffffc02021e8:	00004517          	auipc	a0,0x4
ffffffffc02021ec:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc02021f0:	fe5fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02021f4:	00003617          	auipc	a2,0x3
ffffffffc02021f8:	49c60613          	addi	a2,a2,1180 # ffffffffc0205690 <commands+0x840>
ffffffffc02021fc:	06900593          	li	a1,105
ffffffffc0202200:	00003517          	auipc	a0,0x3
ffffffffc0202204:	4e850513          	addi	a0,a0,1256 # ffffffffc02056e8 <commands+0x898>
ffffffffc0202208:	fcdfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(sum == 0);
ffffffffc020220c:	00004697          	auipc	a3,0x4
ffffffffc0202210:	d7c68693          	addi	a3,a3,-644 # ffffffffc0205f88 <commands+0x1138>
ffffffffc0202214:	00003617          	auipc	a2,0x3
ffffffffc0202218:	5d460613          	addi	a2,a2,1492 # ffffffffc02057e8 <commands+0x998>
ffffffffc020221c:	11700593          	li	a1,279
ffffffffc0202220:	00004517          	auipc	a0,0x4
ffffffffc0202224:	aa050513          	addi	a0,a0,-1376 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202228:	fadfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020222c:	00004697          	auipc	a3,0x4
ffffffffc0202230:	d1468693          	addi	a3,a3,-748 # ffffffffc0205f40 <commands+0x10f0>
ffffffffc0202234:	00003617          	auipc	a2,0x3
ffffffffc0202238:	5b460613          	addi	a2,a2,1460 # ffffffffc02057e8 <commands+0x998>
ffffffffc020223c:	10100593          	li	a1,257
ffffffffc0202240:	00004517          	auipc	a0,0x4
ffffffffc0202244:	a8050513          	addi	a0,a0,-1408 # ffffffffc0205cc0 <commands+0xe70>
ffffffffc0202248:	f8dfd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020224c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020224c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020224e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202250:	f022                	sd	s0,32(sp)
ffffffffc0202252:	ec26                	sd	s1,24(sp)
ffffffffc0202254:	f406                	sd	ra,40(sp)
ffffffffc0202256:	e84a                	sd	s2,16(sp)
ffffffffc0202258:	8432                	mv	s0,a2
ffffffffc020225a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020225c:	971ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>

    pgfault_num++;
ffffffffc0202260:	00013797          	auipc	a5,0x13
ffffffffc0202264:	23078793          	addi	a5,a5,560 # ffffffffc0215490 <pgfault_num>
ffffffffc0202268:	439c                	lw	a5,0(a5)
ffffffffc020226a:	2785                	addiw	a5,a5,1
ffffffffc020226c:	00013717          	auipc	a4,0x13
ffffffffc0202270:	22f72223          	sw	a5,548(a4) # ffffffffc0215490 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202274:	c551                	beqz	a0,ffffffffc0202300 <do_pgfault+0xb4>
ffffffffc0202276:	651c                	ld	a5,8(a0)
ffffffffc0202278:	08f46463          	bltu	s0,a5,ffffffffc0202300 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020227c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020227e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202280:	8b89                	andi	a5,a5,2
ffffffffc0202282:	efb1                	bnez	a5,ffffffffc02022de <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202284:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202286:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202288:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020228a:	85a2                	mv	a1,s0
ffffffffc020228c:	4605                	li	a2,1
ffffffffc020228e:	a27fe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc0202292:	c941                	beqz	a0,ffffffffc0202322 <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202294:	610c                	ld	a1,0(a0)
ffffffffc0202296:	c5b1                	beqz	a1,ffffffffc02022e2 <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202298:	00013797          	auipc	a5,0x13
ffffffffc020229c:	21078793          	addi	a5,a5,528 # ffffffffc02154a8 <swap_init_ok>
ffffffffc02022a0:	439c                	lw	a5,0(a5)
ffffffffc02022a2:	2781                	sext.w	a5,a5
ffffffffc02022a4:	c7bd                	beqz	a5,ffffffffc0202312 <do_pgfault+0xc6>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc02022a6:	85a2                	mv	a1,s0
ffffffffc02022a8:	0030                	addi	a2,sp,8
ffffffffc02022aa:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02022ac:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc02022ae:	5a9000ef          	jal	ra,ffffffffc0203056 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02022b2:	65a2                	ld	a1,8(sp)
ffffffffc02022b4:	6c88                	ld	a0,24(s1)
ffffffffc02022b6:	86ca                	mv	a3,s2
ffffffffc02022b8:	8622                	mv	a2,s0
ffffffffc02022ba:	c99fe0ef          	jal	ra,ffffffffc0200f52 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02022be:	6622                	ld	a2,8(sp)
ffffffffc02022c0:	4685                	li	a3,1
ffffffffc02022c2:	85a2                	mv	a1,s0
ffffffffc02022c4:	8526                	mv	a0,s1
ffffffffc02022c6:	46d000ef          	jal	ra,ffffffffc0202f32 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02022ca:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02022cc:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc02022ce:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc02022d0:	70a2                	ld	ra,40(sp)
ffffffffc02022d2:	7402                	ld	s0,32(sp)
ffffffffc02022d4:	64e2                	ld	s1,24(sp)
ffffffffc02022d6:	6942                	ld	s2,16(sp)
ffffffffc02022d8:	853e                	mv	a0,a5
ffffffffc02022da:	6145                	addi	sp,sp,48
ffffffffc02022dc:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02022de:	495d                	li	s2,23
ffffffffc02022e0:	b755                	j	ffffffffc0202284 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02022e2:	6c88                	ld	a0,24(s1)
ffffffffc02022e4:	864a                	mv	a2,s2
ffffffffc02022e6:	85a2                	mv	a1,s0
ffffffffc02022e8:	fb4ff0ef          	jal	ra,ffffffffc0201a9c <pgdir_alloc_page>
   ret = 0;
ffffffffc02022ec:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02022ee:	f16d                	bnez	a0,ffffffffc02022d0 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02022f0:	00004517          	auipc	a0,0x4
ffffffffc02022f4:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205d20 <commands+0xed0>
ffffffffc02022f8:	dd9fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02022fc:	57f1                	li	a5,-4
            goto failed;
ffffffffc02022fe:	bfc9                	j	ffffffffc02022d0 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202300:	85a2                	mv	a1,s0
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0205cd0 <commands+0xe80>
ffffffffc020230a:	dc7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc020230e:	57f5                	li	a5,-3
        goto failed;
ffffffffc0202310:	b7c1                	j	ffffffffc02022d0 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202312:	00004517          	auipc	a0,0x4
ffffffffc0202316:	a3650513          	addi	a0,a0,-1482 # ffffffffc0205d48 <commands+0xef8>
ffffffffc020231a:	db7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020231e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202320:	bf45                	j	ffffffffc02022d0 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	9de50513          	addi	a0,a0,-1570 # ffffffffc0205d00 <commands+0xeb0>
ffffffffc020232a:	da7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020232e:	57f1                	li	a5,-4
        goto failed;
ffffffffc0202330:	b745                	j	ffffffffc02022d0 <do_pgfault+0x84>

ffffffffc0202332 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202332:	c125                	beqz	a0,ffffffffc0202392 <slob_free+0x60>
		return;

	if (size)
ffffffffc0202334:	e1a5                	bnez	a1,ffffffffc0202394 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202336:	100027f3          	csrr	a5,sstatus
ffffffffc020233a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020233c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020233e:	e3bd                	bnez	a5,ffffffffc02023a4 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202340:	00008797          	auipc	a5,0x8
ffffffffc0202344:	d1078793          	addi	a5,a5,-752 # ffffffffc020a050 <slobfree>
ffffffffc0202348:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020234a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020234c:	00a7fa63          	bgeu	a5,a0,ffffffffc0202360 <slob_free+0x2e>
ffffffffc0202350:	00e56c63          	bltu	a0,a4,ffffffffc0202368 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202354:	00e7fa63          	bgeu	a5,a4,ffffffffc0202368 <slob_free+0x36>
    return 0;
ffffffffc0202358:	87ba                	mv	a5,a4
ffffffffc020235a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020235c:	fea7eae3          	bltu	a5,a0,ffffffffc0202350 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202360:	fee7ece3          	bltu	a5,a4,ffffffffc0202358 <slob_free+0x26>
ffffffffc0202364:	fee57ae3          	bgeu	a0,a4,ffffffffc0202358 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202368:	4110                	lw	a2,0(a0)
ffffffffc020236a:	00461693          	slli	a3,a2,0x4
ffffffffc020236e:	96aa                	add	a3,a3,a0
ffffffffc0202370:	08d70b63          	beq	a4,a3,ffffffffc0202406 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202374:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0202376:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202378:	00469713          	slli	a4,a3,0x4
ffffffffc020237c:	973e                	add	a4,a4,a5
ffffffffc020237e:	08e50f63          	beq	a0,a4,ffffffffc020241c <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202382:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0202384:	00008717          	auipc	a4,0x8
ffffffffc0202388:	ccf73623          	sd	a5,-820(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc020238c:	c199                	beqz	a1,ffffffffc0202392 <slob_free+0x60>
        intr_enable();
ffffffffc020238e:	a3efe06f          	j	ffffffffc02005cc <intr_enable>
ffffffffc0202392:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202394:	05bd                	addi	a1,a1,15
ffffffffc0202396:	8191                	srli	a1,a1,0x4
ffffffffc0202398:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020239a:	100027f3          	csrr	a5,sstatus
ffffffffc020239e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02023a0:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023a2:	dfd9                	beqz	a5,ffffffffc0202340 <slob_free+0xe>
{
ffffffffc02023a4:	1101                	addi	sp,sp,-32
ffffffffc02023a6:	e42a                	sd	a0,8(sp)
ffffffffc02023a8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02023aa:	a28fe0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02023ae:	00008797          	auipc	a5,0x8
ffffffffc02023b2:	ca278793          	addi	a5,a5,-862 # ffffffffc020a050 <slobfree>
ffffffffc02023b6:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02023b8:	6522                	ld	a0,8(sp)
ffffffffc02023ba:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02023bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02023be:	00a7fa63          	bgeu	a5,a0,ffffffffc02023d2 <slob_free+0xa0>
ffffffffc02023c2:	00e56c63          	bltu	a0,a4,ffffffffc02023da <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02023c6:	00e7fa63          	bgeu	a5,a4,ffffffffc02023da <slob_free+0xa8>
    return 0;
ffffffffc02023ca:	87ba                	mv	a5,a4
ffffffffc02023cc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02023ce:	fea7eae3          	bltu	a5,a0,ffffffffc02023c2 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02023d2:	fee7ece3          	bltu	a5,a4,ffffffffc02023ca <slob_free+0x98>
ffffffffc02023d6:	fee57ae3          	bgeu	a0,a4,ffffffffc02023ca <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02023da:	4110                	lw	a2,0(a0)
ffffffffc02023dc:	00461693          	slli	a3,a2,0x4
ffffffffc02023e0:	96aa                	add	a3,a3,a0
ffffffffc02023e2:	04d70763          	beq	a4,a3,ffffffffc0202430 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02023e6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02023e8:	4394                	lw	a3,0(a5)
ffffffffc02023ea:	00469713          	slli	a4,a3,0x4
ffffffffc02023ee:	973e                	add	a4,a4,a5
ffffffffc02023f0:	04e50663          	beq	a0,a4,ffffffffc020243c <slob_free+0x10a>
		cur->next = b;
ffffffffc02023f4:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02023f6:	00008717          	auipc	a4,0x8
ffffffffc02023fa:	c4f73d23          	sd	a5,-934(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02023fe:	e58d                	bnez	a1,ffffffffc0202428 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202400:	60e2                	ld	ra,24(sp)
ffffffffc0202402:	6105                	addi	sp,sp,32
ffffffffc0202404:	8082                	ret
		b->units += cur->next->units;
ffffffffc0202406:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202408:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020240a:	9e35                	addw	a2,a2,a3
ffffffffc020240c:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc020240e:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202410:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202412:	00469713          	slli	a4,a3,0x4
ffffffffc0202416:	973e                	add	a4,a4,a5
ffffffffc0202418:	f6e515e3          	bne	a0,a4,ffffffffc0202382 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020241c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020241e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202420:	9eb9                	addw	a3,a3,a4
ffffffffc0202422:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202424:	e790                	sd	a2,8(a5)
ffffffffc0202426:	bfb9                	j	ffffffffc0202384 <slob_free+0x52>
}
ffffffffc0202428:	60e2                	ld	ra,24(sp)
ffffffffc020242a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020242c:	9a0fe06f          	j	ffffffffc02005cc <intr_enable>
		b->units += cur->next->units;
ffffffffc0202430:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202432:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202434:	9e35                	addw	a2,a2,a3
ffffffffc0202436:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0202438:	e518                	sd	a4,8(a0)
ffffffffc020243a:	b77d                	j	ffffffffc02023e8 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020243c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020243e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202440:	9eb9                	addw	a3,a3,a4
ffffffffc0202442:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202444:	e790                	sd	a2,8(a5)
ffffffffc0202446:	bf45                	j	ffffffffc02023f6 <slob_free+0xc4>

ffffffffc0202448 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202448:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020244a:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020244c:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202450:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202452:	f54fe0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
  if(!page)
ffffffffc0202456:	cd1d                	beqz	a0,ffffffffc0202494 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0202458:	00013797          	auipc	a5,0x13
ffffffffc020245c:	09878793          	addi	a5,a5,152 # ffffffffc02154f0 <pages>
ffffffffc0202460:	6394                	ld	a3,0(a5)
ffffffffc0202462:	00005797          	auipc	a5,0x5
ffffffffc0202466:	97e78793          	addi	a5,a5,-1666 # ffffffffc0206de0 <nbase>
ffffffffc020246a:	8d15                	sub	a0,a0,a3
ffffffffc020246c:	6394                	ld	a3,0(a5)
ffffffffc020246e:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0202470:	00013797          	auipc	a5,0x13
ffffffffc0202474:	01878793          	addi	a5,a5,24 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0202478:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020247a:	6398                	ld	a4,0(a5)
ffffffffc020247c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202480:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202482:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202484:	00e7fb63          	bgeu	a5,a4,ffffffffc020249a <__slob_get_free_pages.isra.0+0x52>
ffffffffc0202488:	00013797          	auipc	a5,0x13
ffffffffc020248c:	05878793          	addi	a5,a5,88 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0202490:	6394                	ld	a3,0(a5)
ffffffffc0202492:	9536                	add	a0,a0,a3
}
ffffffffc0202494:	60a2                	ld	ra,8(sp)
ffffffffc0202496:	0141                	addi	sp,sp,16
ffffffffc0202498:	8082                	ret
ffffffffc020249a:	86aa                	mv	a3,a0
ffffffffc020249c:	00003617          	auipc	a2,0x3
ffffffffc02024a0:	1f460613          	addi	a2,a2,500 # ffffffffc0205690 <commands+0x840>
ffffffffc02024a4:	06900593          	li	a1,105
ffffffffc02024a8:	00003517          	auipc	a0,0x3
ffffffffc02024ac:	24050513          	addi	a0,a0,576 # ffffffffc02056e8 <commands+0x898>
ffffffffc02024b0:	d25fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02024b4 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02024b4:	1101                	addi	sp,sp,-32
ffffffffc02024b6:	ec06                	sd	ra,24(sp)
ffffffffc02024b8:	e822                	sd	s0,16(sp)
ffffffffc02024ba:	e426                	sd	s1,8(sp)
ffffffffc02024bc:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02024be:	01050713          	addi	a4,a0,16
ffffffffc02024c2:	6785                	lui	a5,0x1
ffffffffc02024c4:	0cf77563          	bgeu	a4,a5,ffffffffc020258e <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02024c8:	00f50493          	addi	s1,a0,15
ffffffffc02024cc:	8091                	srli	s1,s1,0x4
ffffffffc02024ce:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02024d0:	10002673          	csrr	a2,sstatus
ffffffffc02024d4:	8a09                	andi	a2,a2,2
ffffffffc02024d6:	e64d                	bnez	a2,ffffffffc0202580 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc02024d8:	00008917          	auipc	s2,0x8
ffffffffc02024dc:	b7890913          	addi	s2,s2,-1160 # ffffffffc020a050 <slobfree>
ffffffffc02024e0:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02024e4:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02024e6:	4398                	lw	a4,0(a5)
ffffffffc02024e8:	0a975063          	bge	a4,s1,ffffffffc0202588 <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc02024ec:	00d78b63          	beq	a5,a3,ffffffffc0202502 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02024f0:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02024f2:	4018                	lw	a4,0(s0)
ffffffffc02024f4:	02975a63          	bge	a4,s1,ffffffffc0202528 <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc02024f8:	00093683          	ld	a3,0(s2)
ffffffffc02024fc:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc02024fe:	fed799e3          	bne	a5,a3,ffffffffc02024f0 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0202502:	e225                	bnez	a2,ffffffffc0202562 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202504:	4501                	li	a0,0
ffffffffc0202506:	f43ff0ef          	jal	ra,ffffffffc0202448 <__slob_get_free_pages.isra.0>
ffffffffc020250a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020250c:	cd15                	beqz	a0,ffffffffc0202548 <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc020250e:	6585                	lui	a1,0x1
ffffffffc0202510:	e23ff0ef          	jal	ra,ffffffffc0202332 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202514:	10002673          	csrr	a2,sstatus
ffffffffc0202518:	8a09                	andi	a2,a2,2
ffffffffc020251a:	ee15                	bnez	a2,ffffffffc0202556 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc020251c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202520:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202522:	4018                	lw	a4,0(s0)
ffffffffc0202524:	fc974ae3          	blt	a4,s1,ffffffffc02024f8 <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202528:	04e48963          	beq	s1,a4,ffffffffc020257a <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc020252c:	00449693          	slli	a3,s1,0x4
ffffffffc0202530:	96a2                	add	a3,a3,s0
ffffffffc0202532:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202534:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202536:	9f05                	subw	a4,a4,s1
ffffffffc0202538:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020253a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020253c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020253e:	00008717          	auipc	a4,0x8
ffffffffc0202542:	b0f73923          	sd	a5,-1262(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202546:	e20d                	bnez	a2,ffffffffc0202568 <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0202548:	8522                	mv	a0,s0
ffffffffc020254a:	60e2                	ld	ra,24(sp)
ffffffffc020254c:	6442                	ld	s0,16(sp)
ffffffffc020254e:	64a2                	ld	s1,8(sp)
ffffffffc0202550:	6902                	ld	s2,0(sp)
ffffffffc0202552:	6105                	addi	sp,sp,32
ffffffffc0202554:	8082                	ret
        intr_disable();
ffffffffc0202556:	87cfe0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc020255a:	4605                	li	a2,1
			cur = slobfree;
ffffffffc020255c:	00093783          	ld	a5,0(s2)
ffffffffc0202560:	b7c1                	j	ffffffffc0202520 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0202562:	86afe0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0202566:	bf79                	j	ffffffffc0202504 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0202568:	864fe0ef          	jal	ra,ffffffffc02005cc <intr_enable>
}
ffffffffc020256c:	8522                	mv	a0,s0
ffffffffc020256e:	60e2                	ld	ra,24(sp)
ffffffffc0202570:	6442                	ld	s0,16(sp)
ffffffffc0202572:	64a2                	ld	s1,8(sp)
ffffffffc0202574:	6902                	ld	s2,0(sp)
ffffffffc0202576:	6105                	addi	sp,sp,32
ffffffffc0202578:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020257a:	6418                	ld	a4,8(s0)
ffffffffc020257c:	e798                	sd	a4,8(a5)
ffffffffc020257e:	b7c1                	j	ffffffffc020253e <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0202580:	852fe0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc0202584:	4605                	li	a2,1
ffffffffc0202586:	bf89                	j	ffffffffc02024d8 <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202588:	843e                	mv	s0,a5
ffffffffc020258a:	87b6                	mv	a5,a3
ffffffffc020258c:	bf71                	j	ffffffffc0202528 <slob_alloc.isra.1.constprop.3+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020258e:	00004697          	auipc	a3,0x4
ffffffffc0202592:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0206028 <commands+0x11d8>
ffffffffc0202596:	00003617          	auipc	a2,0x3
ffffffffc020259a:	25260613          	addi	a2,a2,594 # ffffffffc02057e8 <commands+0x998>
ffffffffc020259e:	06300593          	li	a1,99
ffffffffc02025a2:	00004517          	auipc	a0,0x4
ffffffffc02025a6:	aa650513          	addi	a0,a0,-1370 # ffffffffc0206048 <commands+0x11f8>
ffffffffc02025aa:	c2bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02025ae <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02025ae:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02025b0:	00004517          	auipc	a0,0x4
ffffffffc02025b4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0206060 <commands+0x1210>
kmalloc_init(void) {
ffffffffc02025b8:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02025ba:	b17fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02025be:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02025c0:	00004517          	auipc	a0,0x4
ffffffffc02025c4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0206008 <commands+0x11b8>
}
ffffffffc02025c8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02025ca:	b07fd06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02025ce <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02025ce:	1101                	addi	sp,sp,-32
ffffffffc02025d0:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02025d2:	6905                	lui	s2,0x1
{
ffffffffc02025d4:	e822                	sd	s0,16(sp)
ffffffffc02025d6:	ec06                	sd	ra,24(sp)
ffffffffc02025d8:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02025da:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc02025de:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02025e0:	04a7fc63          	bgeu	a5,a0,ffffffffc0202638 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02025e4:	4561                	li	a0,24
ffffffffc02025e6:	ecfff0ef          	jal	ra,ffffffffc02024b4 <slob_alloc.isra.1.constprop.3>
ffffffffc02025ea:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02025ec:	cd21                	beqz	a0,ffffffffc0202644 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02025ee:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02025f2:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02025f4:	00f95763          	bge	s2,a5,ffffffffc0202602 <kmalloc+0x34>
ffffffffc02025f8:	6705                	lui	a4,0x1
ffffffffc02025fa:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02025fc:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02025fe:	fef74ee3          	blt	a4,a5,ffffffffc02025fa <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202602:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202604:	e45ff0ef          	jal	ra,ffffffffc0202448 <__slob_get_free_pages.isra.0>
ffffffffc0202608:	e488                	sd	a0,8(s1)
ffffffffc020260a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc020260c:	c935                	beqz	a0,ffffffffc0202680 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020260e:	100027f3          	csrr	a5,sstatus
ffffffffc0202612:	8b89                	andi	a5,a5,2
ffffffffc0202614:	e3a1                	bnez	a5,ffffffffc0202654 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0202616:	00013797          	auipc	a5,0x13
ffffffffc020261a:	e8278793          	addi	a5,a5,-382 # ffffffffc0215498 <bigblocks>
ffffffffc020261e:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202620:	00013717          	auipc	a4,0x13
ffffffffc0202624:	e6973c23          	sd	s1,-392(a4) # ffffffffc0215498 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202628:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc020262a:	8522                	mv	a0,s0
ffffffffc020262c:	60e2                	ld	ra,24(sp)
ffffffffc020262e:	6442                	ld	s0,16(sp)
ffffffffc0202630:	64a2                	ld	s1,8(sp)
ffffffffc0202632:	6902                	ld	s2,0(sp)
ffffffffc0202634:	6105                	addi	sp,sp,32
ffffffffc0202636:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202638:	0541                	addi	a0,a0,16
ffffffffc020263a:	e7bff0ef          	jal	ra,ffffffffc02024b4 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc020263e:	01050413          	addi	s0,a0,16
ffffffffc0202642:	f565                	bnez	a0,ffffffffc020262a <kmalloc+0x5c>
ffffffffc0202644:	4401                	li	s0,0
}
ffffffffc0202646:	8522                	mv	a0,s0
ffffffffc0202648:	60e2                	ld	ra,24(sp)
ffffffffc020264a:	6442                	ld	s0,16(sp)
ffffffffc020264c:	64a2                	ld	s1,8(sp)
ffffffffc020264e:	6902                	ld	s2,0(sp)
ffffffffc0202650:	6105                	addi	sp,sp,32
ffffffffc0202652:	8082                	ret
        intr_disable();
ffffffffc0202654:	f7ffd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202658:	00013797          	auipc	a5,0x13
ffffffffc020265c:	e4078793          	addi	a5,a5,-448 # ffffffffc0215498 <bigblocks>
ffffffffc0202660:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202662:	00013717          	auipc	a4,0x13
ffffffffc0202666:	e2973b23          	sd	s1,-458(a4) # ffffffffc0215498 <bigblocks>
		bb->next = bigblocks;
ffffffffc020266a:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc020266c:	f61fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0202670:	6480                	ld	s0,8(s1)
}
ffffffffc0202672:	60e2                	ld	ra,24(sp)
ffffffffc0202674:	64a2                	ld	s1,8(sp)
ffffffffc0202676:	8522                	mv	a0,s0
ffffffffc0202678:	6442                	ld	s0,16(sp)
ffffffffc020267a:	6902                	ld	s2,0(sp)
ffffffffc020267c:	6105                	addi	sp,sp,32
ffffffffc020267e:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202680:	45e1                	li	a1,24
ffffffffc0202682:	8526                	mv	a0,s1
ffffffffc0202684:	cafff0ef          	jal	ra,ffffffffc0202332 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202688:	b74d                	j	ffffffffc020262a <kmalloc+0x5c>

ffffffffc020268a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020268a:	c175                	beqz	a0,ffffffffc020276e <kfree+0xe4>
{
ffffffffc020268c:	1101                	addi	sp,sp,-32
ffffffffc020268e:	e426                	sd	s1,8(sp)
ffffffffc0202690:	ec06                	sd	ra,24(sp)
ffffffffc0202692:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202694:	03451793          	slli	a5,a0,0x34
ffffffffc0202698:	84aa                	mv	s1,a0
ffffffffc020269a:	eb8d                	bnez	a5,ffffffffc02026cc <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020269c:	100027f3          	csrr	a5,sstatus
ffffffffc02026a0:	8b89                	andi	a5,a5,2
ffffffffc02026a2:	efc9                	bnez	a5,ffffffffc020273c <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02026a4:	00013797          	auipc	a5,0x13
ffffffffc02026a8:	df478793          	addi	a5,a5,-524 # ffffffffc0215498 <bigblocks>
ffffffffc02026ac:	6394                	ld	a3,0(a5)
ffffffffc02026ae:	ce99                	beqz	a3,ffffffffc02026cc <kfree+0x42>
			if (bb->pages == block) {
ffffffffc02026b0:	669c                	ld	a5,8(a3)
ffffffffc02026b2:	6a80                	ld	s0,16(a3)
ffffffffc02026b4:	0af50e63          	beq	a0,a5,ffffffffc0202770 <kfree+0xe6>
    return 0;
ffffffffc02026b8:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02026ba:	c801                	beqz	s0,ffffffffc02026ca <kfree+0x40>
			if (bb->pages == block) {
ffffffffc02026bc:	6418                	ld	a4,8(s0)
ffffffffc02026be:	681c                	ld	a5,16(s0)
ffffffffc02026c0:	00970f63          	beq	a4,s1,ffffffffc02026de <kfree+0x54>
ffffffffc02026c4:	86a2                	mv	a3,s0
ffffffffc02026c6:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02026c8:	f875                	bnez	s0,ffffffffc02026bc <kfree+0x32>
    if (flag) {
ffffffffc02026ca:	e659                	bnez	a2,ffffffffc0202758 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02026cc:	6442                	ld	s0,16(sp)
ffffffffc02026ce:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02026d0:	ff048513          	addi	a0,s1,-16
}
ffffffffc02026d4:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02026d6:	4581                	li	a1,0
}
ffffffffc02026d8:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02026da:	c59ff06f          	j	ffffffffc0202332 <slob_free>
				*last = bb->next;
ffffffffc02026de:	ea9c                	sd	a5,16(a3)
ffffffffc02026e0:	e641                	bnez	a2,ffffffffc0202768 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02026e2:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02026e6:	4018                	lw	a4,0(s0)
ffffffffc02026e8:	08f4ea63          	bltu	s1,a5,ffffffffc020277c <kfree+0xf2>
ffffffffc02026ec:	00013797          	auipc	a5,0x13
ffffffffc02026f0:	df478793          	addi	a5,a5,-524 # ffffffffc02154e0 <va_pa_offset>
ffffffffc02026f4:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02026f6:	00013797          	auipc	a5,0x13
ffffffffc02026fa:	d9278793          	addi	a5,a5,-622 # ffffffffc0215488 <npage>
ffffffffc02026fe:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0202700:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0202702:	80b1                	srli	s1,s1,0xc
ffffffffc0202704:	08f4f963          	bgeu	s1,a5,ffffffffc0202796 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202708:	00004797          	auipc	a5,0x4
ffffffffc020270c:	6d878793          	addi	a5,a5,1752 # ffffffffc0206de0 <nbase>
ffffffffc0202710:	639c                	ld	a5,0(a5)
ffffffffc0202712:	00013697          	auipc	a3,0x13
ffffffffc0202716:	dde68693          	addi	a3,a3,-546 # ffffffffc02154f0 <pages>
ffffffffc020271a:	6288                	ld	a0,0(a3)
ffffffffc020271c:	8c9d                	sub	s1,s1,a5
ffffffffc020271e:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202720:	4585                	li	a1,1
ffffffffc0202722:	9526                	add	a0,a0,s1
ffffffffc0202724:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202728:	d06fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020272c:	8522                	mv	a0,s0
}
ffffffffc020272e:	6442                	ld	s0,16(sp)
ffffffffc0202730:	60e2                	ld	ra,24(sp)
ffffffffc0202732:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202734:	45e1                	li	a1,24
}
ffffffffc0202736:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202738:	bfbff06f          	j	ffffffffc0202332 <slob_free>
        intr_disable();
ffffffffc020273c:	e97fd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202740:	00013797          	auipc	a5,0x13
ffffffffc0202744:	d5878793          	addi	a5,a5,-680 # ffffffffc0215498 <bigblocks>
ffffffffc0202748:	6394                	ld	a3,0(a5)
ffffffffc020274a:	c699                	beqz	a3,ffffffffc0202758 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc020274c:	669c                	ld	a5,8(a3)
ffffffffc020274e:	6a80                	ld	s0,16(a3)
ffffffffc0202750:	00f48763          	beq	s1,a5,ffffffffc020275e <kfree+0xd4>
        return 1;
ffffffffc0202754:	4605                	li	a2,1
ffffffffc0202756:	b795                	j	ffffffffc02026ba <kfree+0x30>
        intr_enable();
ffffffffc0202758:	e75fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc020275c:	bf85                	j	ffffffffc02026cc <kfree+0x42>
				*last = bb->next;
ffffffffc020275e:	00013797          	auipc	a5,0x13
ffffffffc0202762:	d287bd23          	sd	s0,-710(a5) # ffffffffc0215498 <bigblocks>
ffffffffc0202766:	8436                	mv	s0,a3
ffffffffc0202768:	e65fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc020276c:	bf9d                	j	ffffffffc02026e2 <kfree+0x58>
ffffffffc020276e:	8082                	ret
ffffffffc0202770:	00013797          	auipc	a5,0x13
ffffffffc0202774:	d287b423          	sd	s0,-728(a5) # ffffffffc0215498 <bigblocks>
ffffffffc0202778:	8436                	mv	s0,a3
ffffffffc020277a:	b7a5                	j	ffffffffc02026e2 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc020277c:	86a6                	mv	a3,s1
ffffffffc020277e:	00003617          	auipc	a2,0x3
ffffffffc0202782:	fea60613          	addi	a2,a2,-22 # ffffffffc0205768 <commands+0x918>
ffffffffc0202786:	06e00593          	li	a1,110
ffffffffc020278a:	00003517          	auipc	a0,0x3
ffffffffc020278e:	f5e50513          	addi	a0,a0,-162 # ffffffffc02056e8 <commands+0x898>
ffffffffc0202792:	a43fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202796:	00003617          	auipc	a2,0x3
ffffffffc020279a:	f3260613          	addi	a2,a2,-206 # ffffffffc02056c8 <commands+0x878>
ffffffffc020279e:	06200593          	li	a1,98
ffffffffc02027a2:	00003517          	auipc	a0,0x3
ffffffffc02027a6:	f4650513          	addi	a0,a0,-186 # ffffffffc02056e8 <commands+0x898>
ffffffffc02027aa:	a2bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02027ae <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02027ae:	7135                	addi	sp,sp,-160
ffffffffc02027b0:	ed06                	sd	ra,152(sp)
ffffffffc02027b2:	e922                	sd	s0,144(sp)
ffffffffc02027b4:	e526                	sd	s1,136(sp)
ffffffffc02027b6:	e14a                	sd	s2,128(sp)
ffffffffc02027b8:	fcce                	sd	s3,120(sp)
ffffffffc02027ba:	f8d2                	sd	s4,112(sp)
ffffffffc02027bc:	f4d6                	sd	s5,104(sp)
ffffffffc02027be:	f0da                	sd	s6,96(sp)
ffffffffc02027c0:	ecde                	sd	s7,88(sp)
ffffffffc02027c2:	e8e2                	sd	s8,80(sp)
ffffffffc02027c4:	e4e6                	sd	s9,72(sp)
ffffffffc02027c6:	e0ea                	sd	s10,64(sp)
ffffffffc02027c8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02027ca:	03d010ef          	jal	ra,ffffffffc0204006 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02027ce:	00013797          	auipc	a5,0x13
ffffffffc02027d2:	dba78793          	addi	a5,a5,-582 # ffffffffc0215588 <max_swap_offset>
ffffffffc02027d6:	6394                	ld	a3,0(a5)
ffffffffc02027d8:	010007b7          	lui	a5,0x1000
ffffffffc02027dc:	17e1                	addi	a5,a5,-8
ffffffffc02027de:	ff968713          	addi	a4,a3,-7
ffffffffc02027e2:	4ae7e863          	bltu	a5,a4,ffffffffc0202c92 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc02027e6:	00008797          	auipc	a5,0x8
ffffffffc02027ea:	82a78793          	addi	a5,a5,-2006 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02027ee:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02027f0:	00013697          	auipc	a3,0x13
ffffffffc02027f4:	caf6b823          	sd	a5,-848(a3) # ffffffffc02154a0 <sm>
     int r = sm->init();
ffffffffc02027f8:	9702                	jalr	a4
ffffffffc02027fa:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02027fc:	c10d                	beqz	a0,ffffffffc020281e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02027fe:	60ea                	ld	ra,152(sp)
ffffffffc0202800:	644a                	ld	s0,144(sp)
ffffffffc0202802:	8556                	mv	a0,s5
ffffffffc0202804:	64aa                	ld	s1,136(sp)
ffffffffc0202806:	690a                	ld	s2,128(sp)
ffffffffc0202808:	79e6                	ld	s3,120(sp)
ffffffffc020280a:	7a46                	ld	s4,112(sp)
ffffffffc020280c:	7aa6                	ld	s5,104(sp)
ffffffffc020280e:	7b06                	ld	s6,96(sp)
ffffffffc0202810:	6be6                	ld	s7,88(sp)
ffffffffc0202812:	6c46                	ld	s8,80(sp)
ffffffffc0202814:	6ca6                	ld	s9,72(sp)
ffffffffc0202816:	6d06                	ld	s10,64(sp)
ffffffffc0202818:	7de2                	ld	s11,56(sp)
ffffffffc020281a:	610d                	addi	sp,sp,160
ffffffffc020281c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020281e:	00013797          	auipc	a5,0x13
ffffffffc0202822:	c8278793          	addi	a5,a5,-894 # ffffffffc02154a0 <sm>
ffffffffc0202826:	639c                	ld	a5,0(a5)
ffffffffc0202828:	00004517          	auipc	a0,0x4
ffffffffc020282c:	8d050513          	addi	a0,a0,-1840 # ffffffffc02060f8 <commands+0x12a8>
ffffffffc0202830:	00013417          	auipc	s0,0x13
ffffffffc0202834:	d9840413          	addi	s0,s0,-616 # ffffffffc02155c8 <free_area>
ffffffffc0202838:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020283a:	4785                	li	a5,1
ffffffffc020283c:	00013717          	auipc	a4,0x13
ffffffffc0202840:	c6f72623          	sw	a5,-916(a4) # ffffffffc02154a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202844:	88dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202848:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020284a:	36878863          	beq	a5,s0,ffffffffc0202bba <swap_init+0x40c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020284e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202852:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202854:	8b05                	andi	a4,a4,1
ffffffffc0202856:	36070663          	beqz	a4,ffffffffc0202bc2 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc020285a:	4481                	li	s1,0
ffffffffc020285c:	4901                	li	s2,0
ffffffffc020285e:	a031                	j	ffffffffc020286a <swap_init+0xbc>
ffffffffc0202860:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202864:	8b09                	andi	a4,a4,2
ffffffffc0202866:	34070e63          	beqz	a4,ffffffffc0202bc2 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc020286a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020286e:	679c                	ld	a5,8(a5)
ffffffffc0202870:	2905                	addiw	s2,s2,1
ffffffffc0202872:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202874:	fe8796e3          	bne	a5,s0,ffffffffc0202860 <swap_init+0xb2>
ffffffffc0202878:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020287a:	bfafe0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc020287e:	69351263          	bne	a0,s3,ffffffffc0202f02 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202882:	8626                	mv	a2,s1
ffffffffc0202884:	85ca                	mv	a1,s2
ffffffffc0202886:	00004517          	auipc	a0,0x4
ffffffffc020288a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020288e:	843fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202892:	ac0ff0ef          	jal	ra,ffffffffc0201b52 <mm_create>
ffffffffc0202896:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202898:	60050563          	beqz	a0,ffffffffc0202ea2 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020289c:	00013797          	auipc	a5,0x13
ffffffffc02028a0:	c5c78793          	addi	a5,a5,-932 # ffffffffc02154f8 <check_mm_struct>
ffffffffc02028a4:	639c                	ld	a5,0(a5)
ffffffffc02028a6:	60079e63          	bnez	a5,ffffffffc0202ec2 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028aa:	00013797          	auipc	a5,0x13
ffffffffc02028ae:	bd678793          	addi	a5,a5,-1066 # ffffffffc0215480 <boot_pgdir>
ffffffffc02028b2:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02028b6:	00013797          	auipc	a5,0x13
ffffffffc02028ba:	c4a7b123          	sd	a0,-958(a5) # ffffffffc02154f8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02028be:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028c2:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02028c6:	4e079263          	bnez	a5,ffffffffc0202daa <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02028ca:	6599                	lui	a1,0x6
ffffffffc02028cc:	460d                	li	a2,3
ffffffffc02028ce:	6505                	lui	a0,0x1
ffffffffc02028d0:	aceff0ef          	jal	ra,ffffffffc0201b9e <vma_create>
ffffffffc02028d4:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02028d6:	4e050a63          	beqz	a0,ffffffffc0202dca <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc02028da:	855e                	mv	a0,s7
ffffffffc02028dc:	b2eff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02028e0:	00004517          	auipc	a0,0x4
ffffffffc02028e4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0206180 <commands+0x1330>
ffffffffc02028e8:	fe8fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02028ec:	018bb503          	ld	a0,24(s7)
ffffffffc02028f0:	4605                	li	a2,1
ffffffffc02028f2:	6585                	lui	a1,0x1
ffffffffc02028f4:	bc0fe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02028f8:	4e050963          	beqz	a0,ffffffffc0202dea <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02028fc:	00004517          	auipc	a0,0x4
ffffffffc0202900:	8d450513          	addi	a0,a0,-1836 # ffffffffc02061d0 <commands+0x1380>
ffffffffc0202904:	00013997          	auipc	s3,0x13
ffffffffc0202908:	bfc98993          	addi	s3,s3,-1028 # ffffffffc0215500 <check_rp>
ffffffffc020290c:	fc4fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202910:	00013a17          	auipc	s4,0x13
ffffffffc0202914:	c10a0a13          	addi	s4,s4,-1008 # ffffffffc0215520 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202918:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc020291a:	4505                	li	a0,1
ffffffffc020291c:	a8afe0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0202920:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202924:	32050763          	beqz	a0,ffffffffc0202c52 <swap_init+0x4a4>
ffffffffc0202928:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc020292a:	8b89                	andi	a5,a5,2
ffffffffc020292c:	30079363          	bnez	a5,ffffffffc0202c32 <swap_init+0x484>
ffffffffc0202930:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202932:	ff4c14e3          	bne	s8,s4,ffffffffc020291a <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202936:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202938:	00013c17          	auipc	s8,0x13
ffffffffc020293c:	bc8c0c13          	addi	s8,s8,-1080 # ffffffffc0215500 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202940:	ec3e                	sd	a5,24(sp)
ffffffffc0202942:	641c                	ld	a5,8(s0)
ffffffffc0202944:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202946:	481c                	lw	a5,16(s0)
ffffffffc0202948:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc020294a:	00013797          	auipc	a5,0x13
ffffffffc020294e:	c887b323          	sd	s0,-890(a5) # ffffffffc02155d0 <free_area+0x8>
ffffffffc0202952:	00013797          	auipc	a5,0x13
ffffffffc0202956:	c687bb23          	sd	s0,-906(a5) # ffffffffc02155c8 <free_area>
     nr_free = 0;
ffffffffc020295a:	00013797          	auipc	a5,0x13
ffffffffc020295e:	c607af23          	sw	zero,-898(a5) # ffffffffc02155d8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202962:	000c3503          	ld	a0,0(s8)
ffffffffc0202966:	4585                	li	a1,1
ffffffffc0202968:	0c21                	addi	s8,s8,8
ffffffffc020296a:	ac4fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020296e:	ff4c1ae3          	bne	s8,s4,ffffffffc0202962 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202972:	01042c03          	lw	s8,16(s0)
ffffffffc0202976:	4791                	li	a5,4
ffffffffc0202978:	50fc1563          	bne	s8,a5,ffffffffc0202e82 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020297c:	00004517          	auipc	a0,0x4
ffffffffc0202980:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0206258 <commands+0x1408>
ffffffffc0202984:	f4cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202988:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020298a:	00013797          	auipc	a5,0x13
ffffffffc020298e:	b007a323          	sw	zero,-1274(a5) # ffffffffc0215490 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202992:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202994:	00013797          	auipc	a5,0x13
ffffffffc0202998:	afc78793          	addi	a5,a5,-1284 # ffffffffc0215490 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020299c:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02029a0:	4398                	lw	a4,0(a5)
ffffffffc02029a2:	4585                	li	a1,1
ffffffffc02029a4:	2701                	sext.w	a4,a4
ffffffffc02029a6:	38b71263          	bne	a4,a1,ffffffffc0202d2a <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02029aa:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02029ae:	4394                	lw	a3,0(a5)
ffffffffc02029b0:	2681                	sext.w	a3,a3
ffffffffc02029b2:	38e69c63          	bne	a3,a4,ffffffffc0202d4a <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02029b6:	6689                	lui	a3,0x2
ffffffffc02029b8:	462d                	li	a2,11
ffffffffc02029ba:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02029be:	4398                	lw	a4,0(a5)
ffffffffc02029c0:	4589                	li	a1,2
ffffffffc02029c2:	2701                	sext.w	a4,a4
ffffffffc02029c4:	2eb71363          	bne	a4,a1,ffffffffc0202caa <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02029c8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02029cc:	4394                	lw	a3,0(a5)
ffffffffc02029ce:	2681                	sext.w	a3,a3
ffffffffc02029d0:	2ee69d63          	bne	a3,a4,ffffffffc0202cca <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02029d4:	668d                	lui	a3,0x3
ffffffffc02029d6:	4631                	li	a2,12
ffffffffc02029d8:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02029dc:	4398                	lw	a4,0(a5)
ffffffffc02029de:	458d                	li	a1,3
ffffffffc02029e0:	2701                	sext.w	a4,a4
ffffffffc02029e2:	30b71463          	bne	a4,a1,ffffffffc0202cea <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02029e6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02029ea:	4394                	lw	a3,0(a5)
ffffffffc02029ec:	2681                	sext.w	a3,a3
ffffffffc02029ee:	30e69e63          	bne	a3,a4,ffffffffc0202d0a <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02029f2:	6691                	lui	a3,0x4
ffffffffc02029f4:	4635                	li	a2,13
ffffffffc02029f6:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02029fa:	4398                	lw	a4,0(a5)
ffffffffc02029fc:	2701                	sext.w	a4,a4
ffffffffc02029fe:	37871663          	bne	a4,s8,ffffffffc0202d6a <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a02:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a06:	439c                	lw	a5,0(a5)
ffffffffc0202a08:	2781                	sext.w	a5,a5
ffffffffc0202a0a:	38e79063          	bne	a5,a4,ffffffffc0202d8a <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a0e:	481c                	lw	a5,16(s0)
ffffffffc0202a10:	3e079d63          	bnez	a5,ffffffffc0202e0a <swap_init+0x65c>
ffffffffc0202a14:	00013797          	auipc	a5,0x13
ffffffffc0202a18:	b0c78793          	addi	a5,a5,-1268 # ffffffffc0215520 <swap_in_seq_no>
ffffffffc0202a1c:	00013717          	auipc	a4,0x13
ffffffffc0202a20:	b2c70713          	addi	a4,a4,-1236 # ffffffffc0215548 <swap_out_seq_no>
ffffffffc0202a24:	00013617          	auipc	a2,0x13
ffffffffc0202a28:	b2460613          	addi	a2,a2,-1244 # ffffffffc0215548 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a2c:	56fd                	li	a3,-1
ffffffffc0202a2e:	c394                	sw	a3,0(a5)
ffffffffc0202a30:	c314                	sw	a3,0(a4)
ffffffffc0202a32:	0791                	addi	a5,a5,4
ffffffffc0202a34:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202a36:	fef61ce3          	bne	a2,a5,ffffffffc0202a2e <swap_init+0x280>
ffffffffc0202a3a:	00013697          	auipc	a3,0x13
ffffffffc0202a3e:	b6e68693          	addi	a3,a3,-1170 # ffffffffc02155a8 <check_ptep>
ffffffffc0202a42:	00013817          	auipc	a6,0x13
ffffffffc0202a46:	abe80813          	addi	a6,a6,-1346 # ffffffffc0215500 <check_rp>
ffffffffc0202a4a:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202a4c:	00013c97          	auipc	s9,0x13
ffffffffc0202a50:	a3cc8c93          	addi	s9,s9,-1476 # ffffffffc0215488 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a54:	00004d97          	auipc	s11,0x4
ffffffffc0202a58:	38cd8d93          	addi	s11,s11,908 # ffffffffc0206de0 <nbase>
ffffffffc0202a5c:	00013c17          	auipc	s8,0x13
ffffffffc0202a60:	a94c0c13          	addi	s8,s8,-1388 # ffffffffc02154f0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202a64:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a68:	4601                	li	a2,0
ffffffffc0202a6a:	85ea                	mv	a1,s10
ffffffffc0202a6c:	855a                	mv	a0,s6
ffffffffc0202a6e:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202a70:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a72:	a42fe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc0202a76:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202a78:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a7a:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202a7c:	1e050b63          	beqz	a0,ffffffffc0202c72 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202a80:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202a82:	0017f613          	andi	a2,a5,1
ffffffffc0202a86:	18060a63          	beqz	a2,ffffffffc0202c1a <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202a8a:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a8e:	078a                	slli	a5,a5,0x2
ffffffffc0202a90:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a92:	14c7f863          	bgeu	a5,a2,ffffffffc0202be2 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a96:	000db703          	ld	a4,0(s11)
ffffffffc0202a9a:	000c3603          	ld	a2,0(s8)
ffffffffc0202a9e:	00083583          	ld	a1,0(a6)
ffffffffc0202aa2:	8f99                	sub	a5,a5,a4
ffffffffc0202aa4:	079a                	slli	a5,a5,0x6
ffffffffc0202aa6:	e43a                	sd	a4,8(sp)
ffffffffc0202aa8:	97b2                	add	a5,a5,a2
ffffffffc0202aaa:	14f59863          	bne	a1,a5,ffffffffc0202bfa <swap_init+0x44c>
ffffffffc0202aae:	6785                	lui	a5,0x1
ffffffffc0202ab0:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ab2:	6795                	lui	a5,0x5
ffffffffc0202ab4:	06a1                	addi	a3,a3,8
ffffffffc0202ab6:	0821                	addi	a6,a6,8
ffffffffc0202ab8:	fafd16e3          	bne	s10,a5,ffffffffc0202a64 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202abc:	00004517          	auipc	a0,0x4
ffffffffc0202ac0:	85450513          	addi	a0,a0,-1964 # ffffffffc0206310 <commands+0x14c0>
ffffffffc0202ac4:	e0cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202ac8:	00013797          	auipc	a5,0x13
ffffffffc0202acc:	9d878793          	addi	a5,a5,-1576 # ffffffffc02154a0 <sm>
ffffffffc0202ad0:	639c                	ld	a5,0(a5)
ffffffffc0202ad2:	7f9c                	ld	a5,56(a5)
ffffffffc0202ad4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202ad6:	40051663          	bnez	a0,ffffffffc0202ee2 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202ada:	77a2                	ld	a5,40(sp)
ffffffffc0202adc:	00013717          	auipc	a4,0x13
ffffffffc0202ae0:	aef72e23          	sw	a5,-1284(a4) # ffffffffc02155d8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202ae4:	67e2                	ld	a5,24(sp)
ffffffffc0202ae6:	00013717          	auipc	a4,0x13
ffffffffc0202aea:	aef73123          	sd	a5,-1310(a4) # ffffffffc02155c8 <free_area>
ffffffffc0202aee:	7782                	ld	a5,32(sp)
ffffffffc0202af0:	00013717          	auipc	a4,0x13
ffffffffc0202af4:	aef73023          	sd	a5,-1312(a4) # ffffffffc02155d0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202af8:	0009b503          	ld	a0,0(s3)
ffffffffc0202afc:	4585                	li	a1,1
ffffffffc0202afe:	09a1                	addi	s3,s3,8
ffffffffc0202b00:	92efe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b04:	ff499ae3          	bne	s3,s4,ffffffffc0202af8 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b08:	855e                	mv	a0,s7
ffffffffc0202b0a:	9ceff0ef          	jal	ra,ffffffffc0201cd8 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202b0e:	00013797          	auipc	a5,0x13
ffffffffc0202b12:	97278793          	addi	a5,a5,-1678 # ffffffffc0215480 <boot_pgdir>
ffffffffc0202b16:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202b18:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b1c:	6394                	ld	a3,0(a5)
ffffffffc0202b1e:	068a                	slli	a3,a3,0x2
ffffffffc0202b20:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b22:	0ce6f063          	bgeu	a3,a4,ffffffffc0202be2 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b26:	67a2                	ld	a5,8(sp)
ffffffffc0202b28:	000c3503          	ld	a0,0(s8)
ffffffffc0202b2c:	8e9d                	sub	a3,a3,a5
ffffffffc0202b2e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202b30:	8699                	srai	a3,a3,0x6
ffffffffc0202b32:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202b34:	00c69793          	slli	a5,a3,0xc
ffffffffc0202b38:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b3a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b3c:	2ee7f763          	bgeu	a5,a4,ffffffffc0202e2a <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202b40:	00013797          	auipc	a5,0x13
ffffffffc0202b44:	9a078793          	addi	a5,a5,-1632 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0202b48:	639c                	ld	a5,0(a5)
ffffffffc0202b4a:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b4c:	629c                	ld	a5,0(a3)
ffffffffc0202b4e:	078a                	slli	a5,a5,0x2
ffffffffc0202b50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b52:	08e7f863          	bgeu	a5,a4,ffffffffc0202be2 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b56:	69a2                	ld	s3,8(sp)
ffffffffc0202b58:	4585                	li	a1,1
ffffffffc0202b5a:	413787b3          	sub	a5,a5,s3
ffffffffc0202b5e:	079a                	slli	a5,a5,0x6
ffffffffc0202b60:	953e                	add	a0,a0,a5
ffffffffc0202b62:	8ccfe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b66:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202b6a:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b6e:	078a                	slli	a5,a5,0x2
ffffffffc0202b70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b72:	06e7f863          	bgeu	a5,a4,ffffffffc0202be2 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b76:	000c3503          	ld	a0,0(s8)
ffffffffc0202b7a:	413787b3          	sub	a5,a5,s3
ffffffffc0202b7e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202b80:	4585                	li	a1,1
ffffffffc0202b82:	953e                	add	a0,a0,a5
ffffffffc0202b84:	8aafe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
     pgdir[0] = 0;
ffffffffc0202b88:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202b8c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202b90:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b92:	00878963          	beq	a5,s0,ffffffffc0202ba4 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b96:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202b9a:	679c                	ld	a5,8(a5)
ffffffffc0202b9c:	397d                	addiw	s2,s2,-1
ffffffffc0202b9e:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ba0:	fe879be3          	bne	a5,s0,ffffffffc0202b96 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202ba4:	28091f63          	bnez	s2,ffffffffc0202e42 <swap_init+0x694>
     assert(total==0);
ffffffffc0202ba8:	2a049d63          	bnez	s1,ffffffffc0202e62 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202bac:	00003517          	auipc	a0,0x3
ffffffffc0202bb0:	7b450513          	addi	a0,a0,1972 # ffffffffc0206360 <commands+0x1510>
ffffffffc0202bb4:	d1cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202bb8:	b199                	j	ffffffffc02027fe <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bba:	4481                	li	s1,0
ffffffffc0202bbc:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bbe:	4981                	li	s3,0
ffffffffc0202bc0:	b96d                	j	ffffffffc020287a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202bc2:	00003697          	auipc	a3,0x3
ffffffffc0202bc6:	54e68693          	addi	a3,a3,1358 # ffffffffc0206110 <commands+0x12c0>
ffffffffc0202bca:	00003617          	auipc	a2,0x3
ffffffffc0202bce:	c1e60613          	addi	a2,a2,-994 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202bd2:	0bd00593          	li	a1,189
ffffffffc0202bd6:	00003517          	auipc	a0,0x3
ffffffffc0202bda:	51250513          	addi	a0,a0,1298 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202bde:	df6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202be2:	00003617          	auipc	a2,0x3
ffffffffc0202be6:	ae660613          	addi	a2,a2,-1306 # ffffffffc02056c8 <commands+0x878>
ffffffffc0202bea:	06200593          	li	a1,98
ffffffffc0202bee:	00003517          	auipc	a0,0x3
ffffffffc0202bf2:	afa50513          	addi	a0,a0,-1286 # ffffffffc02056e8 <commands+0x898>
ffffffffc0202bf6:	ddefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bfa:	00003697          	auipc	a3,0x3
ffffffffc0202bfe:	6ee68693          	addi	a3,a3,1774 # ffffffffc02062e8 <commands+0x1498>
ffffffffc0202c02:	00003617          	auipc	a2,0x3
ffffffffc0202c06:	be660613          	addi	a2,a2,-1050 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202c0a:	0fd00593          	li	a1,253
ffffffffc0202c0e:	00003517          	auipc	a0,0x3
ffffffffc0202c12:	4da50513          	addi	a0,a0,1242 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202c16:	dbefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c1a:	00003617          	auipc	a2,0x3
ffffffffc0202c1e:	ca660613          	addi	a2,a2,-858 # ffffffffc02058c0 <commands+0xa70>
ffffffffc0202c22:	07400593          	li	a1,116
ffffffffc0202c26:	00003517          	auipc	a0,0x3
ffffffffc0202c2a:	ac250513          	addi	a0,a0,-1342 # ffffffffc02056e8 <commands+0x898>
ffffffffc0202c2e:	da6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c32:	00003697          	auipc	a3,0x3
ffffffffc0202c36:	5de68693          	addi	a3,a3,1502 # ffffffffc0206210 <commands+0x13c0>
ffffffffc0202c3a:	00003617          	auipc	a2,0x3
ffffffffc0202c3e:	bae60613          	addi	a2,a2,-1106 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202c42:	0de00593          	li	a1,222
ffffffffc0202c46:	00003517          	auipc	a0,0x3
ffffffffc0202c4a:	4a250513          	addi	a0,a0,1186 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202c4e:	d86fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c52:	00003697          	auipc	a3,0x3
ffffffffc0202c56:	5a668693          	addi	a3,a3,1446 # ffffffffc02061f8 <commands+0x13a8>
ffffffffc0202c5a:	00003617          	auipc	a2,0x3
ffffffffc0202c5e:	b8e60613          	addi	a2,a2,-1138 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202c62:	0dd00593          	li	a1,221
ffffffffc0202c66:	00003517          	auipc	a0,0x3
ffffffffc0202c6a:	48250513          	addi	a0,a0,1154 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202c6e:	d66fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c72:	00003697          	auipc	a3,0x3
ffffffffc0202c76:	65e68693          	addi	a3,a3,1630 # ffffffffc02062d0 <commands+0x1480>
ffffffffc0202c7a:	00003617          	auipc	a2,0x3
ffffffffc0202c7e:	b6e60613          	addi	a2,a2,-1170 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202c82:	0fc00593          	li	a1,252
ffffffffc0202c86:	00003517          	auipc	a0,0x3
ffffffffc0202c8a:	46250513          	addi	a0,a0,1122 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202c8e:	d46fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c92:	00003617          	auipc	a2,0x3
ffffffffc0202c96:	43660613          	addi	a2,a2,1078 # ffffffffc02060c8 <commands+0x1278>
ffffffffc0202c9a:	02a00593          	li	a1,42
ffffffffc0202c9e:	00003517          	auipc	a0,0x3
ffffffffc0202ca2:	44a50513          	addi	a0,a0,1098 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202ca6:	d2efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc0202caa:	00003697          	auipc	a3,0x3
ffffffffc0202cae:	5e668693          	addi	a3,a3,1510 # ffffffffc0206290 <commands+0x1440>
ffffffffc0202cb2:	00003617          	auipc	a2,0x3
ffffffffc0202cb6:	b3660613          	addi	a2,a2,-1226 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202cba:	09800593          	li	a1,152
ffffffffc0202cbe:	00003517          	auipc	a0,0x3
ffffffffc0202cc2:	42a50513          	addi	a0,a0,1066 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202cc6:	d0efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cca:	00003697          	auipc	a3,0x3
ffffffffc0202cce:	5c668693          	addi	a3,a3,1478 # ffffffffc0206290 <commands+0x1440>
ffffffffc0202cd2:	00003617          	auipc	a2,0x3
ffffffffc0202cd6:	b1660613          	addi	a2,a2,-1258 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202cda:	09a00593          	li	a1,154
ffffffffc0202cde:	00003517          	auipc	a0,0x3
ffffffffc0202ce2:	40a50513          	addi	a0,a0,1034 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202ce6:	ceefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cea:	00003697          	auipc	a3,0x3
ffffffffc0202cee:	5b668693          	addi	a3,a3,1462 # ffffffffc02062a0 <commands+0x1450>
ffffffffc0202cf2:	00003617          	auipc	a2,0x3
ffffffffc0202cf6:	af660613          	addi	a2,a2,-1290 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202cfa:	09c00593          	li	a1,156
ffffffffc0202cfe:	00003517          	auipc	a0,0x3
ffffffffc0202d02:	3ea50513          	addi	a0,a0,1002 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202d06:	ccefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d0a:	00003697          	auipc	a3,0x3
ffffffffc0202d0e:	59668693          	addi	a3,a3,1430 # ffffffffc02062a0 <commands+0x1450>
ffffffffc0202d12:	00003617          	auipc	a2,0x3
ffffffffc0202d16:	ad660613          	addi	a2,a2,-1322 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202d1a:	09e00593          	li	a1,158
ffffffffc0202d1e:	00003517          	auipc	a0,0x3
ffffffffc0202d22:	3ca50513          	addi	a0,a0,970 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202d26:	caefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d2a:	00003697          	auipc	a3,0x3
ffffffffc0202d2e:	55668693          	addi	a3,a3,1366 # ffffffffc0206280 <commands+0x1430>
ffffffffc0202d32:	00003617          	auipc	a2,0x3
ffffffffc0202d36:	ab660613          	addi	a2,a2,-1354 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202d3a:	09400593          	li	a1,148
ffffffffc0202d3e:	00003517          	auipc	a0,0x3
ffffffffc0202d42:	3aa50513          	addi	a0,a0,938 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202d46:	c8efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d4a:	00003697          	auipc	a3,0x3
ffffffffc0202d4e:	53668693          	addi	a3,a3,1334 # ffffffffc0206280 <commands+0x1430>
ffffffffc0202d52:	00003617          	auipc	a2,0x3
ffffffffc0202d56:	a9660613          	addi	a2,a2,-1386 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202d5a:	09600593          	li	a1,150
ffffffffc0202d5e:	00003517          	auipc	a0,0x3
ffffffffc0202d62:	38a50513          	addi	a0,a0,906 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202d66:	c6efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d6a:	00003697          	auipc	a3,0x3
ffffffffc0202d6e:	54668693          	addi	a3,a3,1350 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0202d72:	00003617          	auipc	a2,0x3
ffffffffc0202d76:	a7660613          	addi	a2,a2,-1418 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202d7a:	0a000593          	li	a1,160
ffffffffc0202d7e:	00003517          	auipc	a0,0x3
ffffffffc0202d82:	36a50513          	addi	a0,a0,874 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202d86:	c4efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d8a:	00003697          	auipc	a3,0x3
ffffffffc0202d8e:	52668693          	addi	a3,a3,1318 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0202d92:	00003617          	auipc	a2,0x3
ffffffffc0202d96:	a5660613          	addi	a2,a2,-1450 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202d9a:	0a200593          	li	a1,162
ffffffffc0202d9e:	00003517          	auipc	a0,0x3
ffffffffc0202da2:	34a50513          	addi	a0,a0,842 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202da6:	c2efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202daa:	00003697          	auipc	a3,0x3
ffffffffc0202dae:	1ae68693          	addi	a3,a3,430 # ffffffffc0205f58 <commands+0x1108>
ffffffffc0202db2:	00003617          	auipc	a2,0x3
ffffffffc0202db6:	a3660613          	addi	a2,a2,-1482 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202dba:	0cd00593          	li	a1,205
ffffffffc0202dbe:	00003517          	auipc	a0,0x3
ffffffffc0202dc2:	32a50513          	addi	a0,a0,810 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202dc6:	c0efd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(vma != NULL);
ffffffffc0202dca:	00003697          	auipc	a3,0x3
ffffffffc0202dce:	22e68693          	addi	a3,a3,558 # ffffffffc0205ff8 <commands+0x11a8>
ffffffffc0202dd2:	00003617          	auipc	a2,0x3
ffffffffc0202dd6:	a1660613          	addi	a2,a2,-1514 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202dda:	0d000593          	li	a1,208
ffffffffc0202dde:	00003517          	auipc	a0,0x3
ffffffffc0202de2:	30a50513          	addi	a0,a0,778 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202de6:	beefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202dea:	00003697          	auipc	a3,0x3
ffffffffc0202dee:	3ce68693          	addi	a3,a3,974 # ffffffffc02061b8 <commands+0x1368>
ffffffffc0202df2:	00003617          	auipc	a2,0x3
ffffffffc0202df6:	9f660613          	addi	a2,a2,-1546 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202dfa:	0d800593          	li	a1,216
ffffffffc0202dfe:	00003517          	auipc	a0,0x3
ffffffffc0202e02:	2ea50513          	addi	a0,a0,746 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202e06:	bcefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e0a:	00003697          	auipc	a3,0x3
ffffffffc0202e0e:	4b668693          	addi	a3,a3,1206 # ffffffffc02062c0 <commands+0x1470>
ffffffffc0202e12:	00003617          	auipc	a2,0x3
ffffffffc0202e16:	9d660613          	addi	a2,a2,-1578 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202e1a:	0f400593          	li	a1,244
ffffffffc0202e1e:	00003517          	auipc	a0,0x3
ffffffffc0202e22:	2ca50513          	addi	a0,a0,714 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202e26:	baefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e2a:	00003617          	auipc	a2,0x3
ffffffffc0202e2e:	86660613          	addi	a2,a2,-1946 # ffffffffc0205690 <commands+0x840>
ffffffffc0202e32:	06900593          	li	a1,105
ffffffffc0202e36:	00003517          	auipc	a0,0x3
ffffffffc0202e3a:	8b250513          	addi	a0,a0,-1870 # ffffffffc02056e8 <commands+0x898>
ffffffffc0202e3e:	b96fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(count==0);
ffffffffc0202e42:	00003697          	auipc	a3,0x3
ffffffffc0202e46:	4fe68693          	addi	a3,a3,1278 # ffffffffc0206340 <commands+0x14f0>
ffffffffc0202e4a:	00003617          	auipc	a2,0x3
ffffffffc0202e4e:	99e60613          	addi	a2,a2,-1634 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202e52:	11c00593          	li	a1,284
ffffffffc0202e56:	00003517          	auipc	a0,0x3
ffffffffc0202e5a:	29250513          	addi	a0,a0,658 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202e5e:	b76fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total==0);
ffffffffc0202e62:	00003697          	auipc	a3,0x3
ffffffffc0202e66:	4ee68693          	addi	a3,a3,1262 # ffffffffc0206350 <commands+0x1500>
ffffffffc0202e6a:	00003617          	auipc	a2,0x3
ffffffffc0202e6e:	97e60613          	addi	a2,a2,-1666 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202e72:	11d00593          	li	a1,285
ffffffffc0202e76:	00003517          	auipc	a0,0x3
ffffffffc0202e7a:	27250513          	addi	a0,a0,626 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202e7e:	b56fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202e82:	00003697          	auipc	a3,0x3
ffffffffc0202e86:	3ae68693          	addi	a3,a3,942 # ffffffffc0206230 <commands+0x13e0>
ffffffffc0202e8a:	00003617          	auipc	a2,0x3
ffffffffc0202e8e:	95e60613          	addi	a2,a2,-1698 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202e92:	0eb00593          	li	a1,235
ffffffffc0202e96:	00003517          	auipc	a0,0x3
ffffffffc0202e9a:	25250513          	addi	a0,a0,594 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202e9e:	b36fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(mm != NULL);
ffffffffc0202ea2:	00003697          	auipc	a3,0x3
ffffffffc0202ea6:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205dd0 <commands+0xf80>
ffffffffc0202eaa:	00003617          	auipc	a2,0x3
ffffffffc0202eae:	93e60613          	addi	a2,a2,-1730 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202eb2:	0c500593          	li	a1,197
ffffffffc0202eb6:	00003517          	auipc	a0,0x3
ffffffffc0202eba:	23250513          	addi	a0,a0,562 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202ebe:	b16fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202ec2:	00003697          	auipc	a3,0x3
ffffffffc0202ec6:	2a668693          	addi	a3,a3,678 # ffffffffc0206168 <commands+0x1318>
ffffffffc0202eca:	00003617          	auipc	a2,0x3
ffffffffc0202ece:	91e60613          	addi	a2,a2,-1762 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202ed2:	0c800593          	li	a1,200
ffffffffc0202ed6:	00003517          	auipc	a0,0x3
ffffffffc0202eda:	21250513          	addi	a0,a0,530 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202ede:	af6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(ret==0);
ffffffffc0202ee2:	00003697          	auipc	a3,0x3
ffffffffc0202ee6:	45668693          	addi	a3,a3,1110 # ffffffffc0206338 <commands+0x14e8>
ffffffffc0202eea:	00003617          	auipc	a2,0x3
ffffffffc0202eee:	8fe60613          	addi	a2,a2,-1794 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202ef2:	10300593          	li	a1,259
ffffffffc0202ef6:	00003517          	auipc	a0,0x3
ffffffffc0202efa:	1f250513          	addi	a0,a0,498 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202efe:	ad6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202f02:	00003697          	auipc	a3,0x3
ffffffffc0202f06:	21e68693          	addi	a3,a3,542 # ffffffffc0206120 <commands+0x12d0>
ffffffffc0202f0a:	00003617          	auipc	a2,0x3
ffffffffc0202f0e:	8de60613          	addi	a2,a2,-1826 # ffffffffc02057e8 <commands+0x998>
ffffffffc0202f12:	0c000593          	li	a1,192
ffffffffc0202f16:	00003517          	auipc	a0,0x3
ffffffffc0202f1a:	1d250513          	addi	a0,a0,466 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0202f1e:	ab6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202f22 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f22:	00012797          	auipc	a5,0x12
ffffffffc0202f26:	57e78793          	addi	a5,a5,1406 # ffffffffc02154a0 <sm>
ffffffffc0202f2a:	639c                	ld	a5,0(a5)
ffffffffc0202f2c:	0107b303          	ld	t1,16(a5)
ffffffffc0202f30:	8302                	jr	t1

ffffffffc0202f32 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f32:	00012797          	auipc	a5,0x12
ffffffffc0202f36:	56e78793          	addi	a5,a5,1390 # ffffffffc02154a0 <sm>
ffffffffc0202f3a:	639c                	ld	a5,0(a5)
ffffffffc0202f3c:	0207b303          	ld	t1,32(a5)
ffffffffc0202f40:	8302                	jr	t1

ffffffffc0202f42 <swap_out>:
{
ffffffffc0202f42:	711d                	addi	sp,sp,-96
ffffffffc0202f44:	ec86                	sd	ra,88(sp)
ffffffffc0202f46:	e8a2                	sd	s0,80(sp)
ffffffffc0202f48:	e4a6                	sd	s1,72(sp)
ffffffffc0202f4a:	e0ca                	sd	s2,64(sp)
ffffffffc0202f4c:	fc4e                	sd	s3,56(sp)
ffffffffc0202f4e:	f852                	sd	s4,48(sp)
ffffffffc0202f50:	f456                	sd	s5,40(sp)
ffffffffc0202f52:	f05a                	sd	s6,32(sp)
ffffffffc0202f54:	ec5e                	sd	s7,24(sp)
ffffffffc0202f56:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f58:	cde9                	beqz	a1,ffffffffc0203032 <swap_out+0xf0>
ffffffffc0202f5a:	8ab2                	mv	s5,a2
ffffffffc0202f5c:	892a                	mv	s2,a0
ffffffffc0202f5e:	8a2e                	mv	s4,a1
ffffffffc0202f60:	4401                	li	s0,0
ffffffffc0202f62:	00012997          	auipc	s3,0x12
ffffffffc0202f66:	53e98993          	addi	s3,s3,1342 # ffffffffc02154a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f6a:	00003b17          	auipc	s6,0x3
ffffffffc0202f6e:	476b0b13          	addi	s6,s6,1142 # ffffffffc02063e0 <commands+0x1590>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f72:	00003b97          	auipc	s7,0x3
ffffffffc0202f76:	456b8b93          	addi	s7,s7,1110 # ffffffffc02063c8 <commands+0x1578>
ffffffffc0202f7a:	a825                	j	ffffffffc0202fb2 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f7c:	67a2                	ld	a5,8(sp)
ffffffffc0202f7e:	8626                	mv	a2,s1
ffffffffc0202f80:	85a2                	mv	a1,s0
ffffffffc0202f82:	7f94                	ld	a3,56(a5)
ffffffffc0202f84:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f86:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f88:	82b1                	srli	a3,a3,0xc
ffffffffc0202f8a:	0685                	addi	a3,a3,1
ffffffffc0202f8c:	944fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f90:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f92:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f94:	7d1c                	ld	a5,56(a0)
ffffffffc0202f96:	83b1                	srli	a5,a5,0xc
ffffffffc0202f98:	0785                	addi	a5,a5,1
ffffffffc0202f9a:	07a2                	slli	a5,a5,0x8
ffffffffc0202f9c:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202fa0:	c8ffd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202fa4:	01893503          	ld	a0,24(s2)
ffffffffc0202fa8:	85a6                	mv	a1,s1
ffffffffc0202faa:	aedfe0ef          	jal	ra,ffffffffc0201a96 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202fae:	048a0d63          	beq	s4,s0,ffffffffc0203008 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202fb2:	0009b783          	ld	a5,0(s3)
ffffffffc0202fb6:	8656                	mv	a2,s5
ffffffffc0202fb8:	002c                	addi	a1,sp,8
ffffffffc0202fba:	7b9c                	ld	a5,48(a5)
ffffffffc0202fbc:	854a                	mv	a0,s2
ffffffffc0202fbe:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202fc0:	e12d                	bnez	a0,ffffffffc0203022 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202fc2:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fc4:	01893503          	ld	a0,24(s2)
ffffffffc0202fc8:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202fca:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fcc:	85a6                	mv	a1,s1
ffffffffc0202fce:	ce7fd0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fd2:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fd4:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fd6:	8b85                	andi	a5,a5,1
ffffffffc0202fd8:	cfb9                	beqz	a5,ffffffffc0203036 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fda:	65a2                	ld	a1,8(sp)
ffffffffc0202fdc:	7d9c                	ld	a5,56(a1)
ffffffffc0202fde:	83b1                	srli	a5,a5,0xc
ffffffffc0202fe0:	00178513          	addi	a0,a5,1
ffffffffc0202fe4:	0522                	slli	a0,a0,0x8
ffffffffc0202fe6:	0f0010ef          	jal	ra,ffffffffc02040d6 <swapfs_write>
ffffffffc0202fea:	d949                	beqz	a0,ffffffffc0202f7c <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fec:	855e                	mv	a0,s7
ffffffffc0202fee:	8e2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ff2:	0009b783          	ld	a5,0(s3)
ffffffffc0202ff6:	6622                	ld	a2,8(sp)
ffffffffc0202ff8:	4681                	li	a3,0
ffffffffc0202ffa:	739c                	ld	a5,32(a5)
ffffffffc0202ffc:	85a6                	mv	a1,s1
ffffffffc0202ffe:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203000:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203002:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203004:	fa8a17e3          	bne	s4,s0,ffffffffc0202fb2 <swap_out+0x70>
}
ffffffffc0203008:	8522                	mv	a0,s0
ffffffffc020300a:	60e6                	ld	ra,88(sp)
ffffffffc020300c:	6446                	ld	s0,80(sp)
ffffffffc020300e:	64a6                	ld	s1,72(sp)
ffffffffc0203010:	6906                	ld	s2,64(sp)
ffffffffc0203012:	79e2                	ld	s3,56(sp)
ffffffffc0203014:	7a42                	ld	s4,48(sp)
ffffffffc0203016:	7aa2                	ld	s5,40(sp)
ffffffffc0203018:	7b02                	ld	s6,32(sp)
ffffffffc020301a:	6be2                	ld	s7,24(sp)
ffffffffc020301c:	6c42                	ld	s8,16(sp)
ffffffffc020301e:	6125                	addi	sp,sp,96
ffffffffc0203020:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203022:	85a2                	mv	a1,s0
ffffffffc0203024:	00003517          	auipc	a0,0x3
ffffffffc0203028:	35c50513          	addi	a0,a0,860 # ffffffffc0206380 <commands+0x1530>
ffffffffc020302c:	8a4fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0203030:	bfe1                	j	ffffffffc0203008 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203032:	4401                	li	s0,0
ffffffffc0203034:	bfd1                	j	ffffffffc0203008 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203036:	00003697          	auipc	a3,0x3
ffffffffc020303a:	37a68693          	addi	a3,a3,890 # ffffffffc02063b0 <commands+0x1560>
ffffffffc020303e:	00002617          	auipc	a2,0x2
ffffffffc0203042:	7aa60613          	addi	a2,a2,1962 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203046:	06900593          	li	a1,105
ffffffffc020304a:	00003517          	auipc	a0,0x3
ffffffffc020304e:	09e50513          	addi	a0,a0,158 # ffffffffc02060e8 <commands+0x1298>
ffffffffc0203052:	982fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203056 <swap_in>:
{
ffffffffc0203056:	7179                	addi	sp,sp,-48
ffffffffc0203058:	e84a                	sd	s2,16(sp)
ffffffffc020305a:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020305c:	4505                	li	a0,1
{
ffffffffc020305e:	ec26                	sd	s1,24(sp)
ffffffffc0203060:	e44e                	sd	s3,8(sp)
ffffffffc0203062:	f406                	sd	ra,40(sp)
ffffffffc0203064:	f022                	sd	s0,32(sp)
ffffffffc0203066:	84ae                	mv	s1,a1
ffffffffc0203068:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020306a:	b3dfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
     assert(result!=NULL);
ffffffffc020306e:	c129                	beqz	a0,ffffffffc02030b0 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203070:	842a                	mv	s0,a0
ffffffffc0203072:	01893503          	ld	a0,24(s2)
ffffffffc0203076:	4601                	li	a2,0
ffffffffc0203078:	85a6                	mv	a1,s1
ffffffffc020307a:	c3bfd0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc020307e:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203080:	6108                	ld	a0,0(a0)
ffffffffc0203082:	85a2                	mv	a1,s0
ffffffffc0203084:	7bb000ef          	jal	ra,ffffffffc020403e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203088:	00093583          	ld	a1,0(s2)
ffffffffc020308c:	8626                	mv	a2,s1
ffffffffc020308e:	00003517          	auipc	a0,0x3
ffffffffc0203092:	ffa50513          	addi	a0,a0,-6 # ffffffffc0206088 <commands+0x1238>
ffffffffc0203096:	81a1                	srli	a1,a1,0x8
ffffffffc0203098:	838fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020309c:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020309e:	0089b023          	sd	s0,0(s3)
}
ffffffffc02030a2:	7402                	ld	s0,32(sp)
ffffffffc02030a4:	64e2                	ld	s1,24(sp)
ffffffffc02030a6:	6942                	ld	s2,16(sp)
ffffffffc02030a8:	69a2                	ld	s3,8(sp)
ffffffffc02030aa:	4501                	li	a0,0
ffffffffc02030ac:	6145                	addi	sp,sp,48
ffffffffc02030ae:	8082                	ret
     assert(result!=NULL);
ffffffffc02030b0:	00003697          	auipc	a3,0x3
ffffffffc02030b4:	fc868693          	addi	a3,a3,-56 # ffffffffc0206078 <commands+0x1228>
ffffffffc02030b8:	00002617          	auipc	a2,0x2
ffffffffc02030bc:	73060613          	addi	a2,a2,1840 # ffffffffc02057e8 <commands+0x998>
ffffffffc02030c0:	07f00593          	li	a1,127
ffffffffc02030c4:	00003517          	auipc	a0,0x3
ffffffffc02030c8:	02450513          	addi	a0,a0,36 # ffffffffc02060e8 <commands+0x1298>
ffffffffc02030cc:	908fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02030d0 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02030d0:	00012797          	auipc	a5,0x12
ffffffffc02030d4:	4f878793          	addi	a5,a5,1272 # ffffffffc02155c8 <free_area>
ffffffffc02030d8:	e79c                	sd	a5,8(a5)
ffffffffc02030da:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02030dc:	0007a823          	sw	zero,16(a5)
}
ffffffffc02030e0:	8082                	ret

ffffffffc02030e2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02030e2:	00012517          	auipc	a0,0x12
ffffffffc02030e6:	4f656503          	lwu	a0,1270(a0) # ffffffffc02155d8 <free_area+0x10>
ffffffffc02030ea:	8082                	ret

ffffffffc02030ec <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02030ec:	715d                	addi	sp,sp,-80
ffffffffc02030ee:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02030f0:	00012917          	auipc	s2,0x12
ffffffffc02030f4:	4d890913          	addi	s2,s2,1240 # ffffffffc02155c8 <free_area>
ffffffffc02030f8:	00893783          	ld	a5,8(s2)
ffffffffc02030fc:	e486                	sd	ra,72(sp)
ffffffffc02030fe:	e0a2                	sd	s0,64(sp)
ffffffffc0203100:	fc26                	sd	s1,56(sp)
ffffffffc0203102:	f44e                	sd	s3,40(sp)
ffffffffc0203104:	f052                	sd	s4,32(sp)
ffffffffc0203106:	ec56                	sd	s5,24(sp)
ffffffffc0203108:	e85a                	sd	s6,16(sp)
ffffffffc020310a:	e45e                	sd	s7,8(sp)
ffffffffc020310c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020310e:	31278463          	beq	a5,s2,ffffffffc0203416 <default_check+0x32a>
ffffffffc0203112:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203116:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203118:	8b05                	andi	a4,a4,1
ffffffffc020311a:	30070263          	beqz	a4,ffffffffc020341e <default_check+0x332>
    int count = 0, total = 0;
ffffffffc020311e:	4401                	li	s0,0
ffffffffc0203120:	4481                	li	s1,0
ffffffffc0203122:	a031                	j	ffffffffc020312e <default_check+0x42>
ffffffffc0203124:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203128:	8b09                	andi	a4,a4,2
ffffffffc020312a:	2e070a63          	beqz	a4,ffffffffc020341e <default_check+0x332>
        count ++, total += p->property;
ffffffffc020312e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203132:	679c                	ld	a5,8(a5)
ffffffffc0203134:	2485                	addiw	s1,s1,1
ffffffffc0203136:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203138:	ff2796e3          	bne	a5,s2,ffffffffc0203124 <default_check+0x38>
ffffffffc020313c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020313e:	b37fd0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc0203142:	73351e63          	bne	a0,s3,ffffffffc020387e <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203146:	4505                	li	a0,1
ffffffffc0203148:	a5ffd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020314c:	8a2a                	mv	s4,a0
ffffffffc020314e:	46050863          	beqz	a0,ffffffffc02035be <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203152:	4505                	li	a0,1
ffffffffc0203154:	a53fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203158:	89aa                	mv	s3,a0
ffffffffc020315a:	74050263          	beqz	a0,ffffffffc020389e <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020315e:	4505                	li	a0,1
ffffffffc0203160:	a47fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203164:	8aaa                	mv	s5,a0
ffffffffc0203166:	4c050c63          	beqz	a0,ffffffffc020363e <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020316a:	2d3a0a63          	beq	s4,s3,ffffffffc020343e <default_check+0x352>
ffffffffc020316e:	2caa0863          	beq	s4,a0,ffffffffc020343e <default_check+0x352>
ffffffffc0203172:	2ca98663          	beq	s3,a0,ffffffffc020343e <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203176:	000a2783          	lw	a5,0(s4)
ffffffffc020317a:	2e079263          	bnez	a5,ffffffffc020345e <default_check+0x372>
ffffffffc020317e:	0009a783          	lw	a5,0(s3)
ffffffffc0203182:	2c079e63          	bnez	a5,ffffffffc020345e <default_check+0x372>
ffffffffc0203186:	411c                	lw	a5,0(a0)
ffffffffc0203188:	2c079b63          	bnez	a5,ffffffffc020345e <default_check+0x372>
    return page - pages + nbase;
ffffffffc020318c:	00012797          	auipc	a5,0x12
ffffffffc0203190:	36478793          	addi	a5,a5,868 # ffffffffc02154f0 <pages>
ffffffffc0203194:	639c                	ld	a5,0(a5)
ffffffffc0203196:	00004717          	auipc	a4,0x4
ffffffffc020319a:	c4a70713          	addi	a4,a4,-950 # ffffffffc0206de0 <nbase>
ffffffffc020319e:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02031a0:	00012717          	auipc	a4,0x12
ffffffffc02031a4:	2e870713          	addi	a4,a4,744 # ffffffffc0215488 <npage>
ffffffffc02031a8:	6314                	ld	a3,0(a4)
ffffffffc02031aa:	40fa0733          	sub	a4,s4,a5
ffffffffc02031ae:	8719                	srai	a4,a4,0x6
ffffffffc02031b0:	9732                	add	a4,a4,a2
ffffffffc02031b2:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b4:	0732                	slli	a4,a4,0xc
ffffffffc02031b6:	2cd77463          	bgeu	a4,a3,ffffffffc020347e <default_check+0x392>
    return page - pages + nbase;
ffffffffc02031ba:	40f98733          	sub	a4,s3,a5
ffffffffc02031be:	8719                	srai	a4,a4,0x6
ffffffffc02031c0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02031c4:	4ed77d63          	bgeu	a4,a3,ffffffffc02036be <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02031c8:	40f507b3          	sub	a5,a0,a5
ffffffffc02031cc:	8799                	srai	a5,a5,0x6
ffffffffc02031ce:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02031d0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02031d2:	34d7f663          	bgeu	a5,a3,ffffffffc020351e <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02031d6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02031d8:	00093c03          	ld	s8,0(s2)
ffffffffc02031dc:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02031e0:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02031e4:	00012797          	auipc	a5,0x12
ffffffffc02031e8:	3f27b623          	sd	s2,1004(a5) # ffffffffc02155d0 <free_area+0x8>
ffffffffc02031ec:	00012797          	auipc	a5,0x12
ffffffffc02031f0:	3d27be23          	sd	s2,988(a5) # ffffffffc02155c8 <free_area>
    nr_free = 0;
ffffffffc02031f4:	00012797          	auipc	a5,0x12
ffffffffc02031f8:	3e07a223          	sw	zero,996(a5) # ffffffffc02155d8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02031fc:	9abfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203200:	2e051f63          	bnez	a0,ffffffffc02034fe <default_check+0x412>
    free_page(p0);
ffffffffc0203204:	4585                	li	a1,1
ffffffffc0203206:	8552                	mv	a0,s4
ffffffffc0203208:	a27fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p1);
ffffffffc020320c:	4585                	li	a1,1
ffffffffc020320e:	854e                	mv	a0,s3
ffffffffc0203210:	a1ffd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p2);
ffffffffc0203214:	4585                	li	a1,1
ffffffffc0203216:	8556                	mv	a0,s5
ffffffffc0203218:	a17fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert(nr_free == 3);
ffffffffc020321c:	01092703          	lw	a4,16(s2)
ffffffffc0203220:	478d                	li	a5,3
ffffffffc0203222:	2af71e63          	bne	a4,a5,ffffffffc02034de <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203226:	4505                	li	a0,1
ffffffffc0203228:	97ffd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020322c:	89aa                	mv	s3,a0
ffffffffc020322e:	28050863          	beqz	a0,ffffffffc02034be <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203232:	4505                	li	a0,1
ffffffffc0203234:	973fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203238:	8aaa                	mv	s5,a0
ffffffffc020323a:	3e050263          	beqz	a0,ffffffffc020361e <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020323e:	4505                	li	a0,1
ffffffffc0203240:	967fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203244:	8a2a                	mv	s4,a0
ffffffffc0203246:	3a050c63          	beqz	a0,ffffffffc02035fe <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc020324a:	4505                	li	a0,1
ffffffffc020324c:	95bfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203250:	38051763          	bnez	a0,ffffffffc02035de <default_check+0x4f2>
    free_page(p0);
ffffffffc0203254:	4585                	li	a1,1
ffffffffc0203256:	854e                	mv	a0,s3
ffffffffc0203258:	9d7fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020325c:	00893783          	ld	a5,8(s2)
ffffffffc0203260:	23278f63          	beq	a5,s2,ffffffffc020349e <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0203264:	4505                	li	a0,1
ffffffffc0203266:	941fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020326a:	32a99a63          	bne	s3,a0,ffffffffc020359e <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc020326e:	4505                	li	a0,1
ffffffffc0203270:	937fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203274:	30051563          	bnez	a0,ffffffffc020357e <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0203278:	01092783          	lw	a5,16(s2)
ffffffffc020327c:	2e079163          	bnez	a5,ffffffffc020355e <default_check+0x472>
    free_page(p);
ffffffffc0203280:	854e                	mv	a0,s3
ffffffffc0203282:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0203284:	00012797          	auipc	a5,0x12
ffffffffc0203288:	3587b223          	sd	s8,836(a5) # ffffffffc02155c8 <free_area>
ffffffffc020328c:	00012797          	auipc	a5,0x12
ffffffffc0203290:	3577b223          	sd	s7,836(a5) # ffffffffc02155d0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0203294:	00012797          	auipc	a5,0x12
ffffffffc0203298:	3567a223          	sw	s6,836(a5) # ffffffffc02155d8 <free_area+0x10>
    free_page(p);
ffffffffc020329c:	993fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p1);
ffffffffc02032a0:	4585                	li	a1,1
ffffffffc02032a2:	8556                	mv	a0,s5
ffffffffc02032a4:	98bfd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p2);
ffffffffc02032a8:	4585                	li	a1,1
ffffffffc02032aa:	8552                	mv	a0,s4
ffffffffc02032ac:	983fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02032b0:	4515                	li	a0,5
ffffffffc02032b2:	8f5fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02032b6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02032b8:	28050363          	beqz	a0,ffffffffc020353e <default_check+0x452>
ffffffffc02032bc:	651c                	ld	a5,8(a0)
ffffffffc02032be:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02032c0:	8b85                	andi	a5,a5,1
ffffffffc02032c2:	54079e63          	bnez	a5,ffffffffc020381e <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02032c6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02032c8:	00093b03          	ld	s6,0(s2)
ffffffffc02032cc:	00893a83          	ld	s5,8(s2)
ffffffffc02032d0:	00012797          	auipc	a5,0x12
ffffffffc02032d4:	2f27bc23          	sd	s2,760(a5) # ffffffffc02155c8 <free_area>
ffffffffc02032d8:	00012797          	auipc	a5,0x12
ffffffffc02032dc:	2f27bc23          	sd	s2,760(a5) # ffffffffc02155d0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02032e0:	8c7fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02032e4:	50051d63          	bnez	a0,ffffffffc02037fe <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02032e8:	08098a13          	addi	s4,s3,128
ffffffffc02032ec:	8552                	mv	a0,s4
ffffffffc02032ee:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02032f0:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02032f4:	00012797          	auipc	a5,0x12
ffffffffc02032f8:	2e07a223          	sw	zero,740(a5) # ffffffffc02155d8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02032fc:	933fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203300:	4511                	li	a0,4
ffffffffc0203302:	8a5fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203306:	4c051c63          	bnez	a0,ffffffffc02037de <default_check+0x6f2>
ffffffffc020330a:	0889b783          	ld	a5,136(s3)
ffffffffc020330e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203310:	8b85                	andi	a5,a5,1
ffffffffc0203312:	4a078663          	beqz	a5,ffffffffc02037be <default_check+0x6d2>
ffffffffc0203316:	0909a703          	lw	a4,144(s3)
ffffffffc020331a:	478d                	li	a5,3
ffffffffc020331c:	4af71163          	bne	a4,a5,ffffffffc02037be <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203320:	450d                	li	a0,3
ffffffffc0203322:	885fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203326:	8c2a                	mv	s8,a0
ffffffffc0203328:	46050b63          	beqz	a0,ffffffffc020379e <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc020332c:	4505                	li	a0,1
ffffffffc020332e:	879fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203332:	44051663          	bnez	a0,ffffffffc020377e <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0203336:	438a1463          	bne	s4,s8,ffffffffc020375e <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020333a:	4585                	li	a1,1
ffffffffc020333c:	854e                	mv	a0,s3
ffffffffc020333e:	8f1fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_pages(p1, 3);
ffffffffc0203342:	458d                	li	a1,3
ffffffffc0203344:	8552                	mv	a0,s4
ffffffffc0203346:	8e9fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
ffffffffc020334a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020334e:	04098c13          	addi	s8,s3,64
ffffffffc0203352:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203354:	8b85                	andi	a5,a5,1
ffffffffc0203356:	3e078463          	beqz	a5,ffffffffc020373e <default_check+0x652>
ffffffffc020335a:	0109a703          	lw	a4,16(s3)
ffffffffc020335e:	4785                	li	a5,1
ffffffffc0203360:	3cf71f63          	bne	a4,a5,ffffffffc020373e <default_check+0x652>
ffffffffc0203364:	008a3783          	ld	a5,8(s4)
ffffffffc0203368:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020336a:	8b85                	andi	a5,a5,1
ffffffffc020336c:	3a078963          	beqz	a5,ffffffffc020371e <default_check+0x632>
ffffffffc0203370:	010a2703          	lw	a4,16(s4)
ffffffffc0203374:	478d                	li	a5,3
ffffffffc0203376:	3af71463          	bne	a4,a5,ffffffffc020371e <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020337a:	4505                	li	a0,1
ffffffffc020337c:	82bfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203380:	36a99f63          	bne	s3,a0,ffffffffc02036fe <default_check+0x612>
    free_page(p0);
ffffffffc0203384:	4585                	li	a1,1
ffffffffc0203386:	8a9fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020338a:	4509                	li	a0,2
ffffffffc020338c:	81bfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203390:	34aa1763          	bne	s4,a0,ffffffffc02036de <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0203394:	4589                	li	a1,2
ffffffffc0203396:	899fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p2);
ffffffffc020339a:	4585                	li	a1,1
ffffffffc020339c:	8562                	mv	a0,s8
ffffffffc020339e:	891fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02033a2:	4515                	li	a0,5
ffffffffc02033a4:	803fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02033a8:	89aa                	mv	s3,a0
ffffffffc02033aa:	48050a63          	beqz	a0,ffffffffc020383e <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02033ae:	4505                	li	a0,1
ffffffffc02033b0:	ff6fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02033b4:	2e051563          	bnez	a0,ffffffffc020369e <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02033b8:	01092783          	lw	a5,16(s2)
ffffffffc02033bc:	2c079163          	bnez	a5,ffffffffc020367e <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02033c0:	4595                	li	a1,5
ffffffffc02033c2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02033c4:	00012797          	auipc	a5,0x12
ffffffffc02033c8:	2177aa23          	sw	s7,532(a5) # ffffffffc02155d8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02033cc:	00012797          	auipc	a5,0x12
ffffffffc02033d0:	1f67be23          	sd	s6,508(a5) # ffffffffc02155c8 <free_area>
ffffffffc02033d4:	00012797          	auipc	a5,0x12
ffffffffc02033d8:	1f57be23          	sd	s5,508(a5) # ffffffffc02155d0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02033dc:	853fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return listelm->next;
ffffffffc02033e0:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02033e4:	01278963          	beq	a5,s2,ffffffffc02033f6 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02033e8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033ec:	679c                	ld	a5,8(a5)
ffffffffc02033ee:	34fd                	addiw	s1,s1,-1
ffffffffc02033f0:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02033f2:	ff279be3          	bne	a5,s2,ffffffffc02033e8 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc02033f6:	26049463          	bnez	s1,ffffffffc020365e <default_check+0x572>
    assert(total == 0);
ffffffffc02033fa:	46041263          	bnez	s0,ffffffffc020385e <default_check+0x772>
}
ffffffffc02033fe:	60a6                	ld	ra,72(sp)
ffffffffc0203400:	6406                	ld	s0,64(sp)
ffffffffc0203402:	74e2                	ld	s1,56(sp)
ffffffffc0203404:	7942                	ld	s2,48(sp)
ffffffffc0203406:	79a2                	ld	s3,40(sp)
ffffffffc0203408:	7a02                	ld	s4,32(sp)
ffffffffc020340a:	6ae2                	ld	s5,24(sp)
ffffffffc020340c:	6b42                	ld	s6,16(sp)
ffffffffc020340e:	6ba2                	ld	s7,8(sp)
ffffffffc0203410:	6c02                	ld	s8,0(sp)
ffffffffc0203412:	6161                	addi	sp,sp,80
ffffffffc0203414:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203416:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203418:	4401                	li	s0,0
ffffffffc020341a:	4481                	li	s1,0
ffffffffc020341c:	b30d                	j	ffffffffc020313e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc020341e:	00003697          	auipc	a3,0x3
ffffffffc0203422:	cf268693          	addi	a3,a3,-782 # ffffffffc0206110 <commands+0x12c0>
ffffffffc0203426:	00002617          	auipc	a2,0x2
ffffffffc020342a:	3c260613          	addi	a2,a2,962 # ffffffffc02057e8 <commands+0x998>
ffffffffc020342e:	0f000593          	li	a1,240
ffffffffc0203432:	00003517          	auipc	a0,0x3
ffffffffc0203436:	fee50513          	addi	a0,a0,-18 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020343a:	d9bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020343e:	00003697          	auipc	a3,0x3
ffffffffc0203442:	05a68693          	addi	a3,a3,90 # ffffffffc0206498 <commands+0x1648>
ffffffffc0203446:	00002617          	auipc	a2,0x2
ffffffffc020344a:	3a260613          	addi	a2,a2,930 # ffffffffc02057e8 <commands+0x998>
ffffffffc020344e:	0bd00593          	li	a1,189
ffffffffc0203452:	00003517          	auipc	a0,0x3
ffffffffc0203456:	fce50513          	addi	a0,a0,-50 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020345a:	d7bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020345e:	00003697          	auipc	a3,0x3
ffffffffc0203462:	06268693          	addi	a3,a3,98 # ffffffffc02064c0 <commands+0x1670>
ffffffffc0203466:	00002617          	auipc	a2,0x2
ffffffffc020346a:	38260613          	addi	a2,a2,898 # ffffffffc02057e8 <commands+0x998>
ffffffffc020346e:	0be00593          	li	a1,190
ffffffffc0203472:	00003517          	auipc	a0,0x3
ffffffffc0203476:	fae50513          	addi	a0,a0,-82 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020347a:	d5bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020347e:	00003697          	auipc	a3,0x3
ffffffffc0203482:	08268693          	addi	a3,a3,130 # ffffffffc0206500 <commands+0x16b0>
ffffffffc0203486:	00002617          	auipc	a2,0x2
ffffffffc020348a:	36260613          	addi	a2,a2,866 # ffffffffc02057e8 <commands+0x998>
ffffffffc020348e:	0c000593          	li	a1,192
ffffffffc0203492:	00003517          	auipc	a0,0x3
ffffffffc0203496:	f8e50513          	addi	a0,a0,-114 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020349a:	d3bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020349e:	00003697          	auipc	a3,0x3
ffffffffc02034a2:	0ea68693          	addi	a3,a3,234 # ffffffffc0206588 <commands+0x1738>
ffffffffc02034a6:	00002617          	auipc	a2,0x2
ffffffffc02034aa:	34260613          	addi	a2,a2,834 # ffffffffc02057e8 <commands+0x998>
ffffffffc02034ae:	0d900593          	li	a1,217
ffffffffc02034b2:	00003517          	auipc	a0,0x3
ffffffffc02034b6:	f6e50513          	addi	a0,a0,-146 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02034ba:	d1bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02034be:	00003697          	auipc	a3,0x3
ffffffffc02034c2:	f7a68693          	addi	a3,a3,-134 # ffffffffc0206438 <commands+0x15e8>
ffffffffc02034c6:	00002617          	auipc	a2,0x2
ffffffffc02034ca:	32260613          	addi	a2,a2,802 # ffffffffc02057e8 <commands+0x998>
ffffffffc02034ce:	0d200593          	li	a1,210
ffffffffc02034d2:	00003517          	auipc	a0,0x3
ffffffffc02034d6:	f4e50513          	addi	a0,a0,-178 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02034da:	cfbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 3);
ffffffffc02034de:	00003697          	auipc	a3,0x3
ffffffffc02034e2:	09a68693          	addi	a3,a3,154 # ffffffffc0206578 <commands+0x1728>
ffffffffc02034e6:	00002617          	auipc	a2,0x2
ffffffffc02034ea:	30260613          	addi	a2,a2,770 # ffffffffc02057e8 <commands+0x998>
ffffffffc02034ee:	0d000593          	li	a1,208
ffffffffc02034f2:	00003517          	auipc	a0,0x3
ffffffffc02034f6:	f2e50513          	addi	a0,a0,-210 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02034fa:	cdbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02034fe:	00003697          	auipc	a3,0x3
ffffffffc0203502:	06268693          	addi	a3,a3,98 # ffffffffc0206560 <commands+0x1710>
ffffffffc0203506:	00002617          	auipc	a2,0x2
ffffffffc020350a:	2e260613          	addi	a2,a2,738 # ffffffffc02057e8 <commands+0x998>
ffffffffc020350e:	0cb00593          	li	a1,203
ffffffffc0203512:	00003517          	auipc	a0,0x3
ffffffffc0203516:	f0e50513          	addi	a0,a0,-242 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020351a:	cbbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020351e:	00003697          	auipc	a3,0x3
ffffffffc0203522:	02268693          	addi	a3,a3,34 # ffffffffc0206540 <commands+0x16f0>
ffffffffc0203526:	00002617          	auipc	a2,0x2
ffffffffc020352a:	2c260613          	addi	a2,a2,706 # ffffffffc02057e8 <commands+0x998>
ffffffffc020352e:	0c200593          	li	a1,194
ffffffffc0203532:	00003517          	auipc	a0,0x3
ffffffffc0203536:	eee50513          	addi	a0,a0,-274 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020353a:	c9bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != NULL);
ffffffffc020353e:	00003697          	auipc	a3,0x3
ffffffffc0203542:	08268693          	addi	a3,a3,130 # ffffffffc02065c0 <commands+0x1770>
ffffffffc0203546:	00002617          	auipc	a2,0x2
ffffffffc020354a:	2a260613          	addi	a2,a2,674 # ffffffffc02057e8 <commands+0x998>
ffffffffc020354e:	0f800593          	li	a1,248
ffffffffc0203552:	00003517          	auipc	a0,0x3
ffffffffc0203556:	ece50513          	addi	a0,a0,-306 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020355a:	c7bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc020355e:	00003697          	auipc	a3,0x3
ffffffffc0203562:	d6268693          	addi	a3,a3,-670 # ffffffffc02062c0 <commands+0x1470>
ffffffffc0203566:	00002617          	auipc	a2,0x2
ffffffffc020356a:	28260613          	addi	a2,a2,642 # ffffffffc02057e8 <commands+0x998>
ffffffffc020356e:	0df00593          	li	a1,223
ffffffffc0203572:	00003517          	auipc	a0,0x3
ffffffffc0203576:	eae50513          	addi	a0,a0,-338 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020357a:	c5bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020357e:	00003697          	auipc	a3,0x3
ffffffffc0203582:	fe268693          	addi	a3,a3,-30 # ffffffffc0206560 <commands+0x1710>
ffffffffc0203586:	00002617          	auipc	a2,0x2
ffffffffc020358a:	26260613          	addi	a2,a2,610 # ffffffffc02057e8 <commands+0x998>
ffffffffc020358e:	0dd00593          	li	a1,221
ffffffffc0203592:	00003517          	auipc	a0,0x3
ffffffffc0203596:	e8e50513          	addi	a0,a0,-370 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020359a:	c3bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020359e:	00003697          	auipc	a3,0x3
ffffffffc02035a2:	00268693          	addi	a3,a3,2 # ffffffffc02065a0 <commands+0x1750>
ffffffffc02035a6:	00002617          	auipc	a2,0x2
ffffffffc02035aa:	24260613          	addi	a2,a2,578 # ffffffffc02057e8 <commands+0x998>
ffffffffc02035ae:	0dc00593          	li	a1,220
ffffffffc02035b2:	00003517          	auipc	a0,0x3
ffffffffc02035b6:	e6e50513          	addi	a0,a0,-402 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02035ba:	c1bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02035be:	00003697          	auipc	a3,0x3
ffffffffc02035c2:	e7a68693          	addi	a3,a3,-390 # ffffffffc0206438 <commands+0x15e8>
ffffffffc02035c6:	00002617          	auipc	a2,0x2
ffffffffc02035ca:	22260613          	addi	a2,a2,546 # ffffffffc02057e8 <commands+0x998>
ffffffffc02035ce:	0b900593          	li	a1,185
ffffffffc02035d2:	00003517          	auipc	a0,0x3
ffffffffc02035d6:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02035da:	bfbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02035de:	00003697          	auipc	a3,0x3
ffffffffc02035e2:	f8268693          	addi	a3,a3,-126 # ffffffffc0206560 <commands+0x1710>
ffffffffc02035e6:	00002617          	auipc	a2,0x2
ffffffffc02035ea:	20260613          	addi	a2,a2,514 # ffffffffc02057e8 <commands+0x998>
ffffffffc02035ee:	0d600593          	li	a1,214
ffffffffc02035f2:	00003517          	auipc	a0,0x3
ffffffffc02035f6:	e2e50513          	addi	a0,a0,-466 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02035fa:	bdbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02035fe:	00003697          	auipc	a3,0x3
ffffffffc0203602:	e7a68693          	addi	a3,a3,-390 # ffffffffc0206478 <commands+0x1628>
ffffffffc0203606:	00002617          	auipc	a2,0x2
ffffffffc020360a:	1e260613          	addi	a2,a2,482 # ffffffffc02057e8 <commands+0x998>
ffffffffc020360e:	0d400593          	li	a1,212
ffffffffc0203612:	00003517          	auipc	a0,0x3
ffffffffc0203616:	e0e50513          	addi	a0,a0,-498 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020361a:	bbbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020361e:	00003697          	auipc	a3,0x3
ffffffffc0203622:	e3a68693          	addi	a3,a3,-454 # ffffffffc0206458 <commands+0x1608>
ffffffffc0203626:	00002617          	auipc	a2,0x2
ffffffffc020362a:	1c260613          	addi	a2,a2,450 # ffffffffc02057e8 <commands+0x998>
ffffffffc020362e:	0d300593          	li	a1,211
ffffffffc0203632:	00003517          	auipc	a0,0x3
ffffffffc0203636:	dee50513          	addi	a0,a0,-530 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020363a:	b9bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020363e:	00003697          	auipc	a3,0x3
ffffffffc0203642:	e3a68693          	addi	a3,a3,-454 # ffffffffc0206478 <commands+0x1628>
ffffffffc0203646:	00002617          	auipc	a2,0x2
ffffffffc020364a:	1a260613          	addi	a2,a2,418 # ffffffffc02057e8 <commands+0x998>
ffffffffc020364e:	0bb00593          	li	a1,187
ffffffffc0203652:	00003517          	auipc	a0,0x3
ffffffffc0203656:	dce50513          	addi	a0,a0,-562 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020365a:	b7bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(count == 0);
ffffffffc020365e:	00003697          	auipc	a3,0x3
ffffffffc0203662:	0b268693          	addi	a3,a3,178 # ffffffffc0206710 <commands+0x18c0>
ffffffffc0203666:	00002617          	auipc	a2,0x2
ffffffffc020366a:	18260613          	addi	a2,a2,386 # ffffffffc02057e8 <commands+0x998>
ffffffffc020366e:	12500593          	li	a1,293
ffffffffc0203672:	00003517          	auipc	a0,0x3
ffffffffc0203676:	dae50513          	addi	a0,a0,-594 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020367a:	b5bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc020367e:	00003697          	auipc	a3,0x3
ffffffffc0203682:	c4268693          	addi	a3,a3,-958 # ffffffffc02062c0 <commands+0x1470>
ffffffffc0203686:	00002617          	auipc	a2,0x2
ffffffffc020368a:	16260613          	addi	a2,a2,354 # ffffffffc02057e8 <commands+0x998>
ffffffffc020368e:	11a00593          	li	a1,282
ffffffffc0203692:	00003517          	auipc	a0,0x3
ffffffffc0203696:	d8e50513          	addi	a0,a0,-626 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020369a:	b3bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020369e:	00003697          	auipc	a3,0x3
ffffffffc02036a2:	ec268693          	addi	a3,a3,-318 # ffffffffc0206560 <commands+0x1710>
ffffffffc02036a6:	00002617          	auipc	a2,0x2
ffffffffc02036aa:	14260613          	addi	a2,a2,322 # ffffffffc02057e8 <commands+0x998>
ffffffffc02036ae:	11800593          	li	a1,280
ffffffffc02036b2:	00003517          	auipc	a0,0x3
ffffffffc02036b6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02036ba:	b1bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02036be:	00003697          	auipc	a3,0x3
ffffffffc02036c2:	e6268693          	addi	a3,a3,-414 # ffffffffc0206520 <commands+0x16d0>
ffffffffc02036c6:	00002617          	auipc	a2,0x2
ffffffffc02036ca:	12260613          	addi	a2,a2,290 # ffffffffc02057e8 <commands+0x998>
ffffffffc02036ce:	0c100593          	li	a1,193
ffffffffc02036d2:	00003517          	auipc	a0,0x3
ffffffffc02036d6:	d4e50513          	addi	a0,a0,-690 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02036da:	afbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02036de:	00003697          	auipc	a3,0x3
ffffffffc02036e2:	ff268693          	addi	a3,a3,-14 # ffffffffc02066d0 <commands+0x1880>
ffffffffc02036e6:	00002617          	auipc	a2,0x2
ffffffffc02036ea:	10260613          	addi	a2,a2,258 # ffffffffc02057e8 <commands+0x998>
ffffffffc02036ee:	11200593          	li	a1,274
ffffffffc02036f2:	00003517          	auipc	a0,0x3
ffffffffc02036f6:	d2e50513          	addi	a0,a0,-722 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02036fa:	adbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02036fe:	00003697          	auipc	a3,0x3
ffffffffc0203702:	fb268693          	addi	a3,a3,-78 # ffffffffc02066b0 <commands+0x1860>
ffffffffc0203706:	00002617          	auipc	a2,0x2
ffffffffc020370a:	0e260613          	addi	a2,a2,226 # ffffffffc02057e8 <commands+0x998>
ffffffffc020370e:	11000593          	li	a1,272
ffffffffc0203712:	00003517          	auipc	a0,0x3
ffffffffc0203716:	d0e50513          	addi	a0,a0,-754 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020371a:	abbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020371e:	00003697          	auipc	a3,0x3
ffffffffc0203722:	f6a68693          	addi	a3,a3,-150 # ffffffffc0206688 <commands+0x1838>
ffffffffc0203726:	00002617          	auipc	a2,0x2
ffffffffc020372a:	0c260613          	addi	a2,a2,194 # ffffffffc02057e8 <commands+0x998>
ffffffffc020372e:	10e00593          	li	a1,270
ffffffffc0203732:	00003517          	auipc	a0,0x3
ffffffffc0203736:	cee50513          	addi	a0,a0,-786 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020373a:	a9bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020373e:	00003697          	auipc	a3,0x3
ffffffffc0203742:	f2268693          	addi	a3,a3,-222 # ffffffffc0206660 <commands+0x1810>
ffffffffc0203746:	00002617          	auipc	a2,0x2
ffffffffc020374a:	0a260613          	addi	a2,a2,162 # ffffffffc02057e8 <commands+0x998>
ffffffffc020374e:	10d00593          	li	a1,269
ffffffffc0203752:	00003517          	auipc	a0,0x3
ffffffffc0203756:	cce50513          	addi	a0,a0,-818 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020375a:	a7bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020375e:	00003697          	auipc	a3,0x3
ffffffffc0203762:	ef268693          	addi	a3,a3,-270 # ffffffffc0206650 <commands+0x1800>
ffffffffc0203766:	00002617          	auipc	a2,0x2
ffffffffc020376a:	08260613          	addi	a2,a2,130 # ffffffffc02057e8 <commands+0x998>
ffffffffc020376e:	10800593          	li	a1,264
ffffffffc0203772:	00003517          	auipc	a0,0x3
ffffffffc0203776:	cae50513          	addi	a0,a0,-850 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020377a:	a5bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020377e:	00003697          	auipc	a3,0x3
ffffffffc0203782:	de268693          	addi	a3,a3,-542 # ffffffffc0206560 <commands+0x1710>
ffffffffc0203786:	00002617          	auipc	a2,0x2
ffffffffc020378a:	06260613          	addi	a2,a2,98 # ffffffffc02057e8 <commands+0x998>
ffffffffc020378e:	10700593          	li	a1,263
ffffffffc0203792:	00003517          	auipc	a0,0x3
ffffffffc0203796:	c8e50513          	addi	a0,a0,-882 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020379a:	a3bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020379e:	00003697          	auipc	a3,0x3
ffffffffc02037a2:	e9268693          	addi	a3,a3,-366 # ffffffffc0206630 <commands+0x17e0>
ffffffffc02037a6:	00002617          	auipc	a2,0x2
ffffffffc02037aa:	04260613          	addi	a2,a2,66 # ffffffffc02057e8 <commands+0x998>
ffffffffc02037ae:	10600593          	li	a1,262
ffffffffc02037b2:	00003517          	auipc	a0,0x3
ffffffffc02037b6:	c6e50513          	addi	a0,a0,-914 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02037ba:	a1bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02037be:	00003697          	auipc	a3,0x3
ffffffffc02037c2:	e4268693          	addi	a3,a3,-446 # ffffffffc0206600 <commands+0x17b0>
ffffffffc02037c6:	00002617          	auipc	a2,0x2
ffffffffc02037ca:	02260613          	addi	a2,a2,34 # ffffffffc02057e8 <commands+0x998>
ffffffffc02037ce:	10500593          	li	a1,261
ffffffffc02037d2:	00003517          	auipc	a0,0x3
ffffffffc02037d6:	c4e50513          	addi	a0,a0,-946 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02037da:	9fbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02037de:	00003697          	auipc	a3,0x3
ffffffffc02037e2:	e0a68693          	addi	a3,a3,-502 # ffffffffc02065e8 <commands+0x1798>
ffffffffc02037e6:	00002617          	auipc	a2,0x2
ffffffffc02037ea:	00260613          	addi	a2,a2,2 # ffffffffc02057e8 <commands+0x998>
ffffffffc02037ee:	10400593          	li	a1,260
ffffffffc02037f2:	00003517          	auipc	a0,0x3
ffffffffc02037f6:	c2e50513          	addi	a0,a0,-978 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02037fa:	9dbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02037fe:	00003697          	auipc	a3,0x3
ffffffffc0203802:	d6268693          	addi	a3,a3,-670 # ffffffffc0206560 <commands+0x1710>
ffffffffc0203806:	00002617          	auipc	a2,0x2
ffffffffc020380a:	fe260613          	addi	a2,a2,-30 # ffffffffc02057e8 <commands+0x998>
ffffffffc020380e:	0fe00593          	li	a1,254
ffffffffc0203812:	00003517          	auipc	a0,0x3
ffffffffc0203816:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020381a:	9bbfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!PageProperty(p0));
ffffffffc020381e:	00003697          	auipc	a3,0x3
ffffffffc0203822:	db268693          	addi	a3,a3,-590 # ffffffffc02065d0 <commands+0x1780>
ffffffffc0203826:	00002617          	auipc	a2,0x2
ffffffffc020382a:	fc260613          	addi	a2,a2,-62 # ffffffffc02057e8 <commands+0x998>
ffffffffc020382e:	0f900593          	li	a1,249
ffffffffc0203832:	00003517          	auipc	a0,0x3
ffffffffc0203836:	bee50513          	addi	a0,a0,-1042 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020383a:	99bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020383e:	00003697          	auipc	a3,0x3
ffffffffc0203842:	eb268693          	addi	a3,a3,-334 # ffffffffc02066f0 <commands+0x18a0>
ffffffffc0203846:	00002617          	auipc	a2,0x2
ffffffffc020384a:	fa260613          	addi	a2,a2,-94 # ffffffffc02057e8 <commands+0x998>
ffffffffc020384e:	11700593          	li	a1,279
ffffffffc0203852:	00003517          	auipc	a0,0x3
ffffffffc0203856:	bce50513          	addi	a0,a0,-1074 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020385a:	97bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == 0);
ffffffffc020385e:	00003697          	auipc	a3,0x3
ffffffffc0203862:	ec268693          	addi	a3,a3,-318 # ffffffffc0206720 <commands+0x18d0>
ffffffffc0203866:	00002617          	auipc	a2,0x2
ffffffffc020386a:	f8260613          	addi	a2,a2,-126 # ffffffffc02057e8 <commands+0x998>
ffffffffc020386e:	12600593          	li	a1,294
ffffffffc0203872:	00003517          	auipc	a0,0x3
ffffffffc0203876:	bae50513          	addi	a0,a0,-1106 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020387a:	95bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == nr_free_pages());
ffffffffc020387e:	00003697          	auipc	a3,0x3
ffffffffc0203882:	8a268693          	addi	a3,a3,-1886 # ffffffffc0206120 <commands+0x12d0>
ffffffffc0203886:	00002617          	auipc	a2,0x2
ffffffffc020388a:	f6260613          	addi	a2,a2,-158 # ffffffffc02057e8 <commands+0x998>
ffffffffc020388e:	0f300593          	li	a1,243
ffffffffc0203892:	00003517          	auipc	a0,0x3
ffffffffc0203896:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0206420 <commands+0x15d0>
ffffffffc020389a:	93bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020389e:	00003697          	auipc	a3,0x3
ffffffffc02038a2:	bba68693          	addi	a3,a3,-1094 # ffffffffc0206458 <commands+0x1608>
ffffffffc02038a6:	00002617          	auipc	a2,0x2
ffffffffc02038aa:	f4260613          	addi	a2,a2,-190 # ffffffffc02057e8 <commands+0x998>
ffffffffc02038ae:	0ba00593          	li	a1,186
ffffffffc02038b2:	00003517          	auipc	a0,0x3
ffffffffc02038b6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0206420 <commands+0x15d0>
ffffffffc02038ba:	91bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02038be <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02038be:	1141                	addi	sp,sp,-16
ffffffffc02038c0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02038c2:	16058e63          	beqz	a1,ffffffffc0203a3e <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02038c6:	00659693          	slli	a3,a1,0x6
ffffffffc02038ca:	96aa                	add	a3,a3,a0
ffffffffc02038cc:	02d50d63          	beq	a0,a3,ffffffffc0203906 <default_free_pages+0x48>
ffffffffc02038d0:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02038d2:	8b85                	andi	a5,a5,1
ffffffffc02038d4:	14079563          	bnez	a5,ffffffffc0203a1e <default_free_pages+0x160>
ffffffffc02038d8:	651c                	ld	a5,8(a0)
ffffffffc02038da:	8385                	srli	a5,a5,0x1
ffffffffc02038dc:	8b85                	andi	a5,a5,1
ffffffffc02038de:	14079063          	bnez	a5,ffffffffc0203a1e <default_free_pages+0x160>
ffffffffc02038e2:	87aa                	mv	a5,a0
ffffffffc02038e4:	a809                	j	ffffffffc02038f6 <default_free_pages+0x38>
ffffffffc02038e6:	6798                	ld	a4,8(a5)
ffffffffc02038e8:	8b05                	andi	a4,a4,1
ffffffffc02038ea:	12071a63          	bnez	a4,ffffffffc0203a1e <default_free_pages+0x160>
ffffffffc02038ee:	6798                	ld	a4,8(a5)
ffffffffc02038f0:	8b09                	andi	a4,a4,2
ffffffffc02038f2:	12071663          	bnez	a4,ffffffffc0203a1e <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02038f6:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02038fa:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02038fe:	04078793          	addi	a5,a5,64
ffffffffc0203902:	fed792e3          	bne	a5,a3,ffffffffc02038e6 <default_free_pages+0x28>
    base->property = n;
ffffffffc0203906:	2581                	sext.w	a1,a1
ffffffffc0203908:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020390a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020390e:	4789                	li	a5,2
ffffffffc0203910:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203914:	00012697          	auipc	a3,0x12
ffffffffc0203918:	cb468693          	addi	a3,a3,-844 # ffffffffc02155c8 <free_area>
ffffffffc020391c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020391e:	669c                	ld	a5,8(a3)
ffffffffc0203920:	9db9                	addw	a1,a1,a4
ffffffffc0203922:	00012717          	auipc	a4,0x12
ffffffffc0203926:	cab72b23          	sw	a1,-842(a4) # ffffffffc02155d8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020392a:	0cd78163          	beq	a5,a3,ffffffffc02039ec <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc020392e:	fe878713          	addi	a4,a5,-24
ffffffffc0203932:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203934:	4801                	li	a6,0
ffffffffc0203936:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020393a:	00e56a63          	bltu	a0,a4,ffffffffc020394e <default_free_pages+0x90>
    return listelm->next;
ffffffffc020393e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203940:	04d70f63          	beq	a4,a3,ffffffffc020399e <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203944:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203946:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020394a:	fee57ae3          	bgeu	a0,a4,ffffffffc020393e <default_free_pages+0x80>
ffffffffc020394e:	00080663          	beqz	a6,ffffffffc020395a <default_free_pages+0x9c>
ffffffffc0203952:	00012817          	auipc	a6,0x12
ffffffffc0203956:	c6b83b23          	sd	a1,-906(a6) # ffffffffc02155c8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020395a:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc020395c:	e390                	sd	a2,0(a5)
ffffffffc020395e:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203960:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203962:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0203964:	06d58a63          	beq	a1,a3,ffffffffc02039d8 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0203968:	ff85a603          	lw	a2,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc020396c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203970:	02061793          	slli	a5,a2,0x20
ffffffffc0203974:	83e9                	srli	a5,a5,0x1a
ffffffffc0203976:	97ba                	add	a5,a5,a4
ffffffffc0203978:	04f51b63          	bne	a0,a5,ffffffffc02039ce <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020397c:	491c                	lw	a5,16(a0)
ffffffffc020397e:	9e3d                	addw	a2,a2,a5
ffffffffc0203980:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203984:	57f5                	li	a5,-3
ffffffffc0203986:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020398a:	01853803          	ld	a6,24(a0)
ffffffffc020398e:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0203990:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0203992:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0203996:	659c                	ld	a5,8(a1)
ffffffffc0203998:	01063023          	sd	a6,0(a2)
ffffffffc020399c:	a815                	j	ffffffffc02039d0 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020399e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02039a0:	f114                	sd	a3,32(a0)
ffffffffc02039a2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02039a4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02039a6:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02039a8:	00d70563          	beq	a4,a3,ffffffffc02039b2 <default_free_pages+0xf4>
ffffffffc02039ac:	4805                	li	a6,1
ffffffffc02039ae:	87ba                	mv	a5,a4
ffffffffc02039b0:	bf59                	j	ffffffffc0203946 <default_free_pages+0x88>
ffffffffc02039b2:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02039b4:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02039b6:	00d78d63          	beq	a5,a3,ffffffffc02039d0 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02039ba:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02039be:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02039c2:	02061793          	slli	a5,a2,0x20
ffffffffc02039c6:	83e9                	srli	a5,a5,0x1a
ffffffffc02039c8:	97ba                	add	a5,a5,a4
ffffffffc02039ca:	faf509e3          	beq	a0,a5,ffffffffc020397c <default_free_pages+0xbe>
ffffffffc02039ce:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02039d0:	fe878713          	addi	a4,a5,-24
ffffffffc02039d4:	00d78963          	beq	a5,a3,ffffffffc02039e6 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02039d8:	4910                	lw	a2,16(a0)
ffffffffc02039da:	02061693          	slli	a3,a2,0x20
ffffffffc02039de:	82e9                	srli	a3,a3,0x1a
ffffffffc02039e0:	96aa                	add	a3,a3,a0
ffffffffc02039e2:	00d70e63          	beq	a4,a3,ffffffffc02039fe <default_free_pages+0x140>
}
ffffffffc02039e6:	60a2                	ld	ra,8(sp)
ffffffffc02039e8:	0141                	addi	sp,sp,16
ffffffffc02039ea:	8082                	ret
ffffffffc02039ec:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02039ee:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02039f2:	e398                	sd	a4,0(a5)
ffffffffc02039f4:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02039f6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02039f8:	ed1c                	sd	a5,24(a0)
}
ffffffffc02039fa:	0141                	addi	sp,sp,16
ffffffffc02039fc:	8082                	ret
            base->property += p->property;
ffffffffc02039fe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203a02:	ff078693          	addi	a3,a5,-16
ffffffffc0203a06:	9e39                	addw	a2,a2,a4
ffffffffc0203a08:	c910                	sw	a2,16(a0)
ffffffffc0203a0a:	5775                	li	a4,-3
ffffffffc0203a0c:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a10:	6398                	ld	a4,0(a5)
ffffffffc0203a12:	679c                	ld	a5,8(a5)
}
ffffffffc0203a14:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203a16:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a18:	e398                	sd	a4,0(a5)
ffffffffc0203a1a:	0141                	addi	sp,sp,16
ffffffffc0203a1c:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203a1e:	00003697          	auipc	a3,0x3
ffffffffc0203a22:	d1268693          	addi	a3,a3,-750 # ffffffffc0206730 <commands+0x18e0>
ffffffffc0203a26:	00002617          	auipc	a2,0x2
ffffffffc0203a2a:	dc260613          	addi	a2,a2,-574 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203a2e:	08300593          	li	a1,131
ffffffffc0203a32:	00003517          	auipc	a0,0x3
ffffffffc0203a36:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0206420 <commands+0x15d0>
ffffffffc0203a3a:	f9afc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0203a3e:	00003697          	auipc	a3,0x3
ffffffffc0203a42:	d1a68693          	addi	a3,a3,-742 # ffffffffc0206758 <commands+0x1908>
ffffffffc0203a46:	00002617          	auipc	a2,0x2
ffffffffc0203a4a:	da260613          	addi	a2,a2,-606 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203a4e:	08000593          	li	a1,128
ffffffffc0203a52:	00003517          	auipc	a0,0x3
ffffffffc0203a56:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0206420 <commands+0x15d0>
ffffffffc0203a5a:	f7afc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203a5e <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203a5e:	c959                	beqz	a0,ffffffffc0203af4 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0203a60:	00012597          	auipc	a1,0x12
ffffffffc0203a64:	b6858593          	addi	a1,a1,-1176 # ffffffffc02155c8 <free_area>
ffffffffc0203a68:	0105a803          	lw	a6,16(a1)
ffffffffc0203a6c:	862a                	mv	a2,a0
ffffffffc0203a6e:	02081793          	slli	a5,a6,0x20
ffffffffc0203a72:	9381                	srli	a5,a5,0x20
ffffffffc0203a74:	00a7ee63          	bltu	a5,a0,ffffffffc0203a90 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203a78:	87ae                	mv	a5,a1
ffffffffc0203a7a:	a801                	j	ffffffffc0203a8a <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203a7c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203a80:	02071693          	slli	a3,a4,0x20
ffffffffc0203a84:	9281                	srli	a3,a3,0x20
ffffffffc0203a86:	00c6f763          	bgeu	a3,a2,ffffffffc0203a94 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203a8a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203a8c:	feb798e3          	bne	a5,a1,ffffffffc0203a7c <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203a90:	4501                	li	a0,0
}
ffffffffc0203a92:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203a94:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0203a98:	dd6d                	beqz	a0,ffffffffc0203a92 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203a9a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a9e:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0203aa2:	00060e1b          	sext.w	t3,a2
ffffffffc0203aa6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203aaa:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203aae:	02d67863          	bgeu	a2,a3,ffffffffc0203ade <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0203ab2:	061a                	slli	a2,a2,0x6
ffffffffc0203ab4:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0203ab6:	41c7073b          	subw	a4,a4,t3
ffffffffc0203aba:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203abc:	00860693          	addi	a3,a2,8
ffffffffc0203ac0:	4709                	li	a4,2
ffffffffc0203ac2:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203ac6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203aca:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0203ace:	0105a803          	lw	a6,16(a1)
ffffffffc0203ad2:	e314                	sd	a3,0(a4)
ffffffffc0203ad4:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0203ad8:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0203ada:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0203ade:	41c8083b          	subw	a6,a6,t3
ffffffffc0203ae2:	00012717          	auipc	a4,0x12
ffffffffc0203ae6:	af072b23          	sw	a6,-1290(a4) # ffffffffc02155d8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203aea:	5775                	li	a4,-3
ffffffffc0203aec:	17c1                	addi	a5,a5,-16
ffffffffc0203aee:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0203af2:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203af4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203af6:	00003697          	auipc	a3,0x3
ffffffffc0203afa:	c6268693          	addi	a3,a3,-926 # ffffffffc0206758 <commands+0x1908>
ffffffffc0203afe:	00002617          	auipc	a2,0x2
ffffffffc0203b02:	cea60613          	addi	a2,a2,-790 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203b06:	06200593          	li	a1,98
ffffffffc0203b0a:	00003517          	auipc	a0,0x3
ffffffffc0203b0e:	91650513          	addi	a0,a0,-1770 # ffffffffc0206420 <commands+0x15d0>
default_alloc_pages(size_t n) {
ffffffffc0203b12:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203b14:	ec0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203b18 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203b18:	1141                	addi	sp,sp,-16
ffffffffc0203b1a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203b1c:	c1ed                	beqz	a1,ffffffffc0203bfe <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0203b1e:	00659693          	slli	a3,a1,0x6
ffffffffc0203b22:	96aa                	add	a3,a3,a0
ffffffffc0203b24:	02d50463          	beq	a0,a3,ffffffffc0203b4c <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203b28:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0203b2a:	87aa                	mv	a5,a0
ffffffffc0203b2c:	8b05                	andi	a4,a4,1
ffffffffc0203b2e:	e709                	bnez	a4,ffffffffc0203b38 <default_init_memmap+0x20>
ffffffffc0203b30:	a07d                	j	ffffffffc0203bde <default_init_memmap+0xc6>
ffffffffc0203b32:	6798                	ld	a4,8(a5)
ffffffffc0203b34:	8b05                	andi	a4,a4,1
ffffffffc0203b36:	c745                	beqz	a4,ffffffffc0203bde <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0203b38:	0007a823          	sw	zero,16(a5)
ffffffffc0203b3c:	0007b423          	sd	zero,8(a5)
ffffffffc0203b40:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203b44:	04078793          	addi	a5,a5,64
ffffffffc0203b48:	fed795e3          	bne	a5,a3,ffffffffc0203b32 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0203b4c:	2581                	sext.w	a1,a1
ffffffffc0203b4e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203b50:	4789                	li	a5,2
ffffffffc0203b52:	00850713          	addi	a4,a0,8
ffffffffc0203b56:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203b5a:	00012697          	auipc	a3,0x12
ffffffffc0203b5e:	a6e68693          	addi	a3,a3,-1426 # ffffffffc02155c8 <free_area>
ffffffffc0203b62:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203b64:	669c                	ld	a5,8(a3)
ffffffffc0203b66:	9db9                	addw	a1,a1,a4
ffffffffc0203b68:	00012717          	auipc	a4,0x12
ffffffffc0203b6c:	a6b72823          	sw	a1,-1424(a4) # ffffffffc02155d8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203b70:	04d78a63          	beq	a5,a3,ffffffffc0203bc4 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0203b74:	fe878713          	addi	a4,a5,-24
ffffffffc0203b78:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203b7a:	4801                	li	a6,0
ffffffffc0203b7c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203b80:	00e56a63          	bltu	a0,a4,ffffffffc0203b94 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0203b84:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203b86:	02d70563          	beq	a4,a3,ffffffffc0203bb0 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203b8a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203b8c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203b90:	fee57ae3          	bgeu	a0,a4,ffffffffc0203b84 <default_init_memmap+0x6c>
ffffffffc0203b94:	00080663          	beqz	a6,ffffffffc0203ba0 <default_init_memmap+0x88>
ffffffffc0203b98:	00012717          	auipc	a4,0x12
ffffffffc0203b9c:	a2b73823          	sd	a1,-1488(a4) # ffffffffc02155c8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203ba0:	6398                	ld	a4,0(a5)
}
ffffffffc0203ba2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203ba4:	e390                	sd	a2,0(a5)
ffffffffc0203ba6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203ba8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203baa:	ed18                	sd	a4,24(a0)
ffffffffc0203bac:	0141                	addi	sp,sp,16
ffffffffc0203bae:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203bb0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203bb2:	f114                	sd	a3,32(a0)
ffffffffc0203bb4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203bb6:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203bb8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203bba:	00d70e63          	beq	a4,a3,ffffffffc0203bd6 <default_init_memmap+0xbe>
ffffffffc0203bbe:	4805                	li	a6,1
ffffffffc0203bc0:	87ba                	mv	a5,a4
ffffffffc0203bc2:	b7e9                	j	ffffffffc0203b8c <default_init_memmap+0x74>
}
ffffffffc0203bc4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203bc6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203bca:	e398                	sd	a4,0(a5)
ffffffffc0203bcc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203bce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203bd0:	ed1c                	sd	a5,24(a0)
}
ffffffffc0203bd2:	0141                	addi	sp,sp,16
ffffffffc0203bd4:	8082                	ret
ffffffffc0203bd6:	60a2                	ld	ra,8(sp)
ffffffffc0203bd8:	e290                	sd	a2,0(a3)
ffffffffc0203bda:	0141                	addi	sp,sp,16
ffffffffc0203bdc:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203bde:	00003697          	auipc	a3,0x3
ffffffffc0203be2:	b8268693          	addi	a3,a3,-1150 # ffffffffc0206760 <commands+0x1910>
ffffffffc0203be6:	00002617          	auipc	a2,0x2
ffffffffc0203bea:	c0260613          	addi	a2,a2,-1022 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203bee:	04900593          	li	a1,73
ffffffffc0203bf2:	00003517          	auipc	a0,0x3
ffffffffc0203bf6:	82e50513          	addi	a0,a0,-2002 # ffffffffc0206420 <commands+0x15d0>
ffffffffc0203bfa:	ddafc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0203bfe:	00003697          	auipc	a3,0x3
ffffffffc0203c02:	b5a68693          	addi	a3,a3,-1190 # ffffffffc0206758 <commands+0x1908>
ffffffffc0203c06:	00002617          	auipc	a2,0x2
ffffffffc0203c0a:	be260613          	addi	a2,a2,-1054 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203c0e:	04600593          	li	a1,70
ffffffffc0203c12:	00003517          	auipc	a0,0x3
ffffffffc0203c16:	80e50513          	addi	a0,a0,-2034 # ffffffffc0206420 <commands+0x15d0>
ffffffffc0203c1a:	dbafc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203c1e <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c1e:	00012797          	auipc	a5,0x12
ffffffffc0203c22:	9c278793          	addi	a5,a5,-1598 # ffffffffc02155e0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203c26:	f51c                	sd	a5,40(a0)
ffffffffc0203c28:	e79c                	sd	a5,8(a5)
ffffffffc0203c2a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203c2c:	4501                	li	a0,0
ffffffffc0203c2e:	8082                	ret

ffffffffc0203c30 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203c30:	4501                	li	a0,0
ffffffffc0203c32:	8082                	ret

ffffffffc0203c34 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203c34:	4501                	li	a0,0
ffffffffc0203c36:	8082                	ret

ffffffffc0203c38 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203c38:	4501                	li	a0,0
ffffffffc0203c3a:	8082                	ret

ffffffffc0203c3c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203c3c:	711d                	addi	sp,sp,-96
ffffffffc0203c3e:	fc4e                	sd	s3,56(sp)
ffffffffc0203c40:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c42:	00003517          	auipc	a0,0x3
ffffffffc0203c46:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02067c0 <default_pmm_manager+0x50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c4a:	698d                	lui	s3,0x3
ffffffffc0203c4c:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c4e:	e8a2                	sd	s0,80(sp)
ffffffffc0203c50:	e4a6                	sd	s1,72(sp)
ffffffffc0203c52:	ec86                	sd	ra,88(sp)
ffffffffc0203c54:	e0ca                	sd	s2,64(sp)
ffffffffc0203c56:	f456                	sd	s5,40(sp)
ffffffffc0203c58:	f05a                	sd	s6,32(sp)
ffffffffc0203c5a:	ec5e                	sd	s7,24(sp)
ffffffffc0203c5c:	e862                	sd	s8,16(sp)
ffffffffc0203c5e:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c60:	00012417          	auipc	s0,0x12
ffffffffc0203c64:	83040413          	addi	s0,s0,-2000 # ffffffffc0215490 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c68:	c68fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c6c:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203c70:	4004                	lw	s1,0(s0)
ffffffffc0203c72:	4791                	li	a5,4
ffffffffc0203c74:	2481                	sext.w	s1,s1
ffffffffc0203c76:	14f49963          	bne	s1,a5,ffffffffc0203dc8 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c7a:	00003517          	auipc	a0,0x3
ffffffffc0203c7e:	b8650513          	addi	a0,a0,-1146 # ffffffffc0206800 <default_pmm_manager+0x90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c82:	6a85                	lui	s5,0x1
ffffffffc0203c84:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c86:	c4afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c8a:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203c8e:	00042903          	lw	s2,0(s0)
ffffffffc0203c92:	2901                	sext.w	s2,s2
ffffffffc0203c94:	2a991a63          	bne	s2,s1,ffffffffc0203f48 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c98:	00003517          	auipc	a0,0x3
ffffffffc0203c9c:	b9050513          	addi	a0,a0,-1136 # ffffffffc0206828 <default_pmm_manager+0xb8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ca0:	6b91                	lui	s7,0x4
ffffffffc0203ca2:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203ca4:	c2cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ca8:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203cac:	4004                	lw	s1,0(s0)
ffffffffc0203cae:	2481                	sext.w	s1,s1
ffffffffc0203cb0:	27249c63          	bne	s1,s2,ffffffffc0203f28 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cb4:	00003517          	auipc	a0,0x3
ffffffffc0203cb8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0206850 <default_pmm_manager+0xe0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cbc:	6909                	lui	s2,0x2
ffffffffc0203cbe:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cc0:	c10fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cc4:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203cc8:	401c                	lw	a5,0(s0)
ffffffffc0203cca:	2781                	sext.w	a5,a5
ffffffffc0203ccc:	22979e63          	bne	a5,s1,ffffffffc0203f08 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203cd0:	00003517          	auipc	a0,0x3
ffffffffc0203cd4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0206878 <default_pmm_manager+0x108>
ffffffffc0203cd8:	bf8fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203cdc:	6795                	lui	a5,0x5
ffffffffc0203cde:	4739                	li	a4,14
ffffffffc0203ce0:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203ce4:	4004                	lw	s1,0(s0)
ffffffffc0203ce6:	4795                	li	a5,5
ffffffffc0203ce8:	2481                	sext.w	s1,s1
ffffffffc0203cea:	1ef49f63          	bne	s1,a5,ffffffffc0203ee8 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cee:	00003517          	auipc	a0,0x3
ffffffffc0203cf2:	b6250513          	addi	a0,a0,-1182 # ffffffffc0206850 <default_pmm_manager+0xe0>
ffffffffc0203cf6:	bdafc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cfa:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203cfe:	401c                	lw	a5,0(s0)
ffffffffc0203d00:	2781                	sext.w	a5,a5
ffffffffc0203d02:	1c979363          	bne	a5,s1,ffffffffc0203ec8 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0206800 <default_pmm_manager+0x90>
ffffffffc0203d0e:	bc2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d12:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d16:	401c                	lw	a5,0(s0)
ffffffffc0203d18:	4719                	li	a4,6
ffffffffc0203d1a:	2781                	sext.w	a5,a5
ffffffffc0203d1c:	18e79663          	bne	a5,a4,ffffffffc0203ea8 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d20:	00003517          	auipc	a0,0x3
ffffffffc0203d24:	b3050513          	addi	a0,a0,-1232 # ffffffffc0206850 <default_pmm_manager+0xe0>
ffffffffc0203d28:	ba8fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d2c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203d30:	401c                	lw	a5,0(s0)
ffffffffc0203d32:	471d                	li	a4,7
ffffffffc0203d34:	2781                	sext.w	a5,a5
ffffffffc0203d36:	14e79963          	bne	a5,a4,ffffffffc0203e88 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d3a:	00003517          	auipc	a0,0x3
ffffffffc0203d3e:	a8650513          	addi	a0,a0,-1402 # ffffffffc02067c0 <default_pmm_manager+0x50>
ffffffffc0203d42:	b8efc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d46:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d4a:	401c                	lw	a5,0(s0)
ffffffffc0203d4c:	4721                	li	a4,8
ffffffffc0203d4e:	2781                	sext.w	a5,a5
ffffffffc0203d50:	10e79c63          	bne	a5,a4,ffffffffc0203e68 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d54:	00003517          	auipc	a0,0x3
ffffffffc0203d58:	ad450513          	addi	a0,a0,-1324 # ffffffffc0206828 <default_pmm_manager+0xb8>
ffffffffc0203d5c:	b74fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d60:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d64:	401c                	lw	a5,0(s0)
ffffffffc0203d66:	4725                	li	a4,9
ffffffffc0203d68:	2781                	sext.w	a5,a5
ffffffffc0203d6a:	0ce79f63          	bne	a5,a4,ffffffffc0203e48 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d6e:	00003517          	auipc	a0,0x3
ffffffffc0203d72:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0206878 <default_pmm_manager+0x108>
ffffffffc0203d76:	b5afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d7a:	6795                	lui	a5,0x5
ffffffffc0203d7c:	4739                	li	a4,14
ffffffffc0203d7e:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203d82:	4004                	lw	s1,0(s0)
ffffffffc0203d84:	47a9                	li	a5,10
ffffffffc0203d86:	2481                	sext.w	s1,s1
ffffffffc0203d88:	0af49063          	bne	s1,a5,ffffffffc0203e28 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d8c:	00003517          	auipc	a0,0x3
ffffffffc0203d90:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206800 <default_pmm_manager+0x90>
ffffffffc0203d94:	b3cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d98:	6785                	lui	a5,0x1
ffffffffc0203d9a:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203d9e:	06979563          	bne	a5,s1,ffffffffc0203e08 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203da2:	401c                	lw	a5,0(s0)
ffffffffc0203da4:	472d                	li	a4,11
ffffffffc0203da6:	2781                	sext.w	a5,a5
ffffffffc0203da8:	04e79063          	bne	a5,a4,ffffffffc0203de8 <_fifo_check_swap+0x1ac>
}
ffffffffc0203dac:	60e6                	ld	ra,88(sp)
ffffffffc0203dae:	6446                	ld	s0,80(sp)
ffffffffc0203db0:	64a6                	ld	s1,72(sp)
ffffffffc0203db2:	6906                	ld	s2,64(sp)
ffffffffc0203db4:	79e2                	ld	s3,56(sp)
ffffffffc0203db6:	7a42                	ld	s4,48(sp)
ffffffffc0203db8:	7aa2                	ld	s5,40(sp)
ffffffffc0203dba:	7b02                	ld	s6,32(sp)
ffffffffc0203dbc:	6be2                	ld	s7,24(sp)
ffffffffc0203dbe:	6c42                	ld	s8,16(sp)
ffffffffc0203dc0:	6ca2                	ld	s9,8(sp)
ffffffffc0203dc2:	4501                	li	a0,0
ffffffffc0203dc4:	6125                	addi	sp,sp,96
ffffffffc0203dc6:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203dc8:	00002697          	auipc	a3,0x2
ffffffffc0203dcc:	4e868693          	addi	a3,a3,1256 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0203dd0:	00002617          	auipc	a2,0x2
ffffffffc0203dd4:	a1860613          	addi	a2,a2,-1512 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203dd8:	05100593          	li	a1,81
ffffffffc0203ddc:	00003517          	auipc	a0,0x3
ffffffffc0203de0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203de4:	bf0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==11);
ffffffffc0203de8:	00003697          	auipc	a3,0x3
ffffffffc0203dec:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206928 <default_pmm_manager+0x1b8>
ffffffffc0203df0:	00002617          	auipc	a2,0x2
ffffffffc0203df4:	9f860613          	addi	a2,a2,-1544 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203df8:	07300593          	li	a1,115
ffffffffc0203dfc:	00003517          	auipc	a0,0x3
ffffffffc0203e00:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203e04:	bd0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e08:	00003697          	auipc	a3,0x3
ffffffffc0203e0c:	af868693          	addi	a3,a3,-1288 # ffffffffc0206900 <default_pmm_manager+0x190>
ffffffffc0203e10:	00002617          	auipc	a2,0x2
ffffffffc0203e14:	9d860613          	addi	a2,a2,-1576 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203e18:	07100593          	li	a1,113
ffffffffc0203e1c:	00003517          	auipc	a0,0x3
ffffffffc0203e20:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203e24:	bb0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==10);
ffffffffc0203e28:	00003697          	auipc	a3,0x3
ffffffffc0203e2c:	ac868693          	addi	a3,a3,-1336 # ffffffffc02068f0 <default_pmm_manager+0x180>
ffffffffc0203e30:	00002617          	auipc	a2,0x2
ffffffffc0203e34:	9b860613          	addi	a2,a2,-1608 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203e38:	06f00593          	li	a1,111
ffffffffc0203e3c:	00003517          	auipc	a0,0x3
ffffffffc0203e40:	9ac50513          	addi	a0,a0,-1620 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203e44:	b90fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e48:	00003697          	auipc	a3,0x3
ffffffffc0203e4c:	a9868693          	addi	a3,a3,-1384 # ffffffffc02068e0 <default_pmm_manager+0x170>
ffffffffc0203e50:	00002617          	auipc	a2,0x2
ffffffffc0203e54:	99860613          	addi	a2,a2,-1640 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203e58:	06c00593          	li	a1,108
ffffffffc0203e5c:	00003517          	auipc	a0,0x3
ffffffffc0203e60:	98c50513          	addi	a0,a0,-1652 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203e64:	b70fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e68:	00003697          	auipc	a3,0x3
ffffffffc0203e6c:	a6868693          	addi	a3,a3,-1432 # ffffffffc02068d0 <default_pmm_manager+0x160>
ffffffffc0203e70:	00002617          	auipc	a2,0x2
ffffffffc0203e74:	97860613          	addi	a2,a2,-1672 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203e78:	06900593          	li	a1,105
ffffffffc0203e7c:	00003517          	auipc	a0,0x3
ffffffffc0203e80:	96c50513          	addi	a0,a0,-1684 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203e84:	b50fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e88:	00003697          	auipc	a3,0x3
ffffffffc0203e8c:	a3868693          	addi	a3,a3,-1480 # ffffffffc02068c0 <default_pmm_manager+0x150>
ffffffffc0203e90:	00002617          	auipc	a2,0x2
ffffffffc0203e94:	95860613          	addi	a2,a2,-1704 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203e98:	06600593          	li	a1,102
ffffffffc0203e9c:	00003517          	auipc	a0,0x3
ffffffffc0203ea0:	94c50513          	addi	a0,a0,-1716 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203ea4:	b30fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==6);
ffffffffc0203ea8:	00003697          	auipc	a3,0x3
ffffffffc0203eac:	a0868693          	addi	a3,a3,-1528 # ffffffffc02068b0 <default_pmm_manager+0x140>
ffffffffc0203eb0:	00002617          	auipc	a2,0x2
ffffffffc0203eb4:	93860613          	addi	a2,a2,-1736 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203eb8:	06300593          	li	a1,99
ffffffffc0203ebc:	00003517          	auipc	a0,0x3
ffffffffc0203ec0:	92c50513          	addi	a0,a0,-1748 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203ec4:	b10fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ec8:	00003697          	auipc	a3,0x3
ffffffffc0203ecc:	9d868693          	addi	a3,a3,-1576 # ffffffffc02068a0 <default_pmm_manager+0x130>
ffffffffc0203ed0:	00002617          	auipc	a2,0x2
ffffffffc0203ed4:	91860613          	addi	a2,a2,-1768 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203ed8:	06000593          	li	a1,96
ffffffffc0203edc:	00003517          	auipc	a0,0x3
ffffffffc0203ee0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203ee4:	af0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ee8:	00003697          	auipc	a3,0x3
ffffffffc0203eec:	9b868693          	addi	a3,a3,-1608 # ffffffffc02068a0 <default_pmm_manager+0x130>
ffffffffc0203ef0:	00002617          	auipc	a2,0x2
ffffffffc0203ef4:	8f860613          	addi	a2,a2,-1800 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203ef8:	05d00593          	li	a1,93
ffffffffc0203efc:	00003517          	auipc	a0,0x3
ffffffffc0203f00:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203f04:	ad0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f08:	00002697          	auipc	a3,0x2
ffffffffc0203f0c:	3a868693          	addi	a3,a3,936 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0203f10:	00002617          	auipc	a2,0x2
ffffffffc0203f14:	8d860613          	addi	a2,a2,-1832 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203f18:	05a00593          	li	a1,90
ffffffffc0203f1c:	00003517          	auipc	a0,0x3
ffffffffc0203f20:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203f24:	ab0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f28:	00002697          	auipc	a3,0x2
ffffffffc0203f2c:	38868693          	addi	a3,a3,904 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0203f30:	00002617          	auipc	a2,0x2
ffffffffc0203f34:	8b860613          	addi	a2,a2,-1864 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203f38:	05700593          	li	a1,87
ffffffffc0203f3c:	00003517          	auipc	a0,0x3
ffffffffc0203f40:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203f44:	a90fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f48:	00002697          	auipc	a3,0x2
ffffffffc0203f4c:	36868693          	addi	a3,a3,872 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0203f50:	00002617          	auipc	a2,0x2
ffffffffc0203f54:	89860613          	addi	a2,a2,-1896 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203f58:	05400593          	li	a1,84
ffffffffc0203f5c:	00003517          	auipc	a0,0x3
ffffffffc0203f60:	88c50513          	addi	a0,a0,-1908 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203f64:	a70fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203f68 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f68:	751c                	ld	a5,40(a0)
{
ffffffffc0203f6a:	1141                	addi	sp,sp,-16
ffffffffc0203f6c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f6e:	cf91                	beqz	a5,ffffffffc0203f8a <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f70:	ee0d                	bnez	a2,ffffffffc0203faa <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f72:	679c                	ld	a5,8(a5)
}
ffffffffc0203f74:	60a2                	ld	ra,8(sp)
ffffffffc0203f76:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f78:	6394                	ld	a3,0(a5)
ffffffffc0203f7a:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f7c:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f80:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f82:	e314                	sd	a3,0(a4)
ffffffffc0203f84:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f86:	0141                	addi	sp,sp,16
ffffffffc0203f88:	8082                	ret
         assert(head != NULL);
ffffffffc0203f8a:	00003697          	auipc	a3,0x3
ffffffffc0203f8e:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0206958 <default_pmm_manager+0x1e8>
ffffffffc0203f92:	00002617          	auipc	a2,0x2
ffffffffc0203f96:	85660613          	addi	a2,a2,-1962 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203f9a:	04100593          	li	a1,65
ffffffffc0203f9e:	00003517          	auipc	a0,0x3
ffffffffc0203fa2:	84a50513          	addi	a0,a0,-1974 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203fa6:	a2efc0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(in_tick==0);
ffffffffc0203faa:	00003697          	auipc	a3,0x3
ffffffffc0203fae:	9be68693          	addi	a3,a3,-1602 # ffffffffc0206968 <default_pmm_manager+0x1f8>
ffffffffc0203fb2:	00002617          	auipc	a2,0x2
ffffffffc0203fb6:	83660613          	addi	a2,a2,-1994 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203fba:	04200593          	li	a1,66
ffffffffc0203fbe:	00003517          	auipc	a0,0x3
ffffffffc0203fc2:	82a50513          	addi	a0,a0,-2006 # ffffffffc02067e8 <default_pmm_manager+0x78>
ffffffffc0203fc6:	a0efc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203fca <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203fca:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fce:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203fd0:	cb09                	beqz	a4,ffffffffc0203fe2 <_fifo_map_swappable+0x18>
ffffffffc0203fd2:	cb81                	beqz	a5,ffffffffc0203fe2 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203fd4:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203fd6:	e398                	sd	a4,0(a5)
}
ffffffffc0203fd8:	4501                	li	a0,0
ffffffffc0203fda:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203fdc:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203fde:	f614                	sd	a3,40(a2)
ffffffffc0203fe0:	8082                	ret
{
ffffffffc0203fe2:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203fe4:	00003697          	auipc	a3,0x3
ffffffffc0203fe8:	95468693          	addi	a3,a3,-1708 # ffffffffc0206938 <default_pmm_manager+0x1c8>
ffffffffc0203fec:	00001617          	auipc	a2,0x1
ffffffffc0203ff0:	7fc60613          	addi	a2,a2,2044 # ffffffffc02057e8 <commands+0x998>
ffffffffc0203ff4:	03200593          	li	a1,50
ffffffffc0203ff8:	00002517          	auipc	a0,0x2
ffffffffc0203ffc:	7f050513          	addi	a0,a0,2032 # ffffffffc02067e8 <default_pmm_manager+0x78>
{
ffffffffc0204000:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204002:	9d2fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204006 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204006:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204008:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc020400a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020400c:	ca2fc0ef          	jal	ra,ffffffffc02004ae <ide_device_valid>
ffffffffc0204010:	cd01                	beqz	a0,ffffffffc0204028 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204012:	4505                	li	a0,1
ffffffffc0204014:	ca0fc0ef          	jal	ra,ffffffffc02004b4 <ide_device_size>
}
ffffffffc0204018:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020401a:	810d                	srli	a0,a0,0x3
ffffffffc020401c:	00011797          	auipc	a5,0x11
ffffffffc0204020:	56a7b623          	sd	a0,1388(a5) # ffffffffc0215588 <max_swap_offset>
}
ffffffffc0204024:	0141                	addi	sp,sp,16
ffffffffc0204026:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204028:	00003617          	auipc	a2,0x3
ffffffffc020402c:	96860613          	addi	a2,a2,-1688 # ffffffffc0206990 <default_pmm_manager+0x220>
ffffffffc0204030:	45b5                	li	a1,13
ffffffffc0204032:	00003517          	auipc	a0,0x3
ffffffffc0204036:	97e50513          	addi	a0,a0,-1666 # ffffffffc02069b0 <default_pmm_manager+0x240>
ffffffffc020403a:	99afc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020403e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc020403e:	1141                	addi	sp,sp,-16
ffffffffc0204040:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204042:	00855793          	srli	a5,a0,0x8
ffffffffc0204046:	cfb9                	beqz	a5,ffffffffc02040a4 <swapfs_read+0x66>
ffffffffc0204048:	00011717          	auipc	a4,0x11
ffffffffc020404c:	54070713          	addi	a4,a4,1344 # ffffffffc0215588 <max_swap_offset>
ffffffffc0204050:	6318                	ld	a4,0(a4)
ffffffffc0204052:	04e7f963          	bgeu	a5,a4,ffffffffc02040a4 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204056:	00011717          	auipc	a4,0x11
ffffffffc020405a:	49a70713          	addi	a4,a4,1178 # ffffffffc02154f0 <pages>
ffffffffc020405e:	6310                	ld	a2,0(a4)
ffffffffc0204060:	00003717          	auipc	a4,0x3
ffffffffc0204064:	d8070713          	addi	a4,a4,-640 # ffffffffc0206de0 <nbase>
ffffffffc0204068:	40c58633          	sub	a2,a1,a2
ffffffffc020406c:	630c                	ld	a1,0(a4)
ffffffffc020406e:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204070:	00011717          	auipc	a4,0x11
ffffffffc0204074:	41870713          	addi	a4,a4,1048 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0204078:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020407a:	6314                	ld	a3,0(a4)
ffffffffc020407c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204080:	8331                	srli	a4,a4,0xc
ffffffffc0204082:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204086:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204088:	02d77a63          	bgeu	a4,a3,ffffffffc02040bc <swapfs_read+0x7e>
ffffffffc020408c:	00011797          	auipc	a5,0x11
ffffffffc0204090:	45478793          	addi	a5,a5,1108 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0204094:	639c                	ld	a5,0(a5)
}
ffffffffc0204096:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204098:	46a1                	li	a3,8
ffffffffc020409a:	963e                	add	a2,a2,a5
ffffffffc020409c:	4505                	li	a0,1
}
ffffffffc020409e:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040a0:	c1afc06f          	j	ffffffffc02004ba <ide_read_secs>
ffffffffc02040a4:	86aa                	mv	a3,a0
ffffffffc02040a6:	00003617          	auipc	a2,0x3
ffffffffc02040aa:	92260613          	addi	a2,a2,-1758 # ffffffffc02069c8 <default_pmm_manager+0x258>
ffffffffc02040ae:	45d1                	li	a1,20
ffffffffc02040b0:	00003517          	auipc	a0,0x3
ffffffffc02040b4:	90050513          	addi	a0,a0,-1792 # ffffffffc02069b0 <default_pmm_manager+0x240>
ffffffffc02040b8:	91cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc02040bc:	86b2                	mv	a3,a2
ffffffffc02040be:	06900593          	li	a1,105
ffffffffc02040c2:	00001617          	auipc	a2,0x1
ffffffffc02040c6:	5ce60613          	addi	a2,a2,1486 # ffffffffc0205690 <commands+0x840>
ffffffffc02040ca:	00001517          	auipc	a0,0x1
ffffffffc02040ce:	61e50513          	addi	a0,a0,1566 # ffffffffc02056e8 <commands+0x898>
ffffffffc02040d2:	902fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02040d6 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02040d6:	1141                	addi	sp,sp,-16
ffffffffc02040d8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040da:	00855793          	srli	a5,a0,0x8
ffffffffc02040de:	cfb9                	beqz	a5,ffffffffc020413c <swapfs_write+0x66>
ffffffffc02040e0:	00011717          	auipc	a4,0x11
ffffffffc02040e4:	4a870713          	addi	a4,a4,1192 # ffffffffc0215588 <max_swap_offset>
ffffffffc02040e8:	6318                	ld	a4,0(a4)
ffffffffc02040ea:	04e7f963          	bgeu	a5,a4,ffffffffc020413c <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc02040ee:	00011717          	auipc	a4,0x11
ffffffffc02040f2:	40270713          	addi	a4,a4,1026 # ffffffffc02154f0 <pages>
ffffffffc02040f6:	6310                	ld	a2,0(a4)
ffffffffc02040f8:	00003717          	auipc	a4,0x3
ffffffffc02040fc:	ce870713          	addi	a4,a4,-792 # ffffffffc0206de0 <nbase>
ffffffffc0204100:	40c58633          	sub	a2,a1,a2
ffffffffc0204104:	630c                	ld	a1,0(a4)
ffffffffc0204106:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204108:	00011717          	auipc	a4,0x11
ffffffffc020410c:	38070713          	addi	a4,a4,896 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0204110:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204112:	6314                	ld	a3,0(a4)
ffffffffc0204114:	00c61713          	slli	a4,a2,0xc
ffffffffc0204118:	8331                	srli	a4,a4,0xc
ffffffffc020411a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020411e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204120:	02d77a63          	bgeu	a4,a3,ffffffffc0204154 <swapfs_write+0x7e>
ffffffffc0204124:	00011797          	auipc	a5,0x11
ffffffffc0204128:	3bc78793          	addi	a5,a5,956 # ffffffffc02154e0 <va_pa_offset>
ffffffffc020412c:	639c                	ld	a5,0(a5)
}
ffffffffc020412e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204130:	46a1                	li	a3,8
ffffffffc0204132:	963e                	add	a2,a2,a5
ffffffffc0204134:	4505                	li	a0,1
}
ffffffffc0204136:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204138:	ba6fc06f          	j	ffffffffc02004de <ide_write_secs>
ffffffffc020413c:	86aa                	mv	a3,a0
ffffffffc020413e:	00003617          	auipc	a2,0x3
ffffffffc0204142:	88a60613          	addi	a2,a2,-1910 # ffffffffc02069c8 <default_pmm_manager+0x258>
ffffffffc0204146:	45e5                	li	a1,25
ffffffffc0204148:	00003517          	auipc	a0,0x3
ffffffffc020414c:	86850513          	addi	a0,a0,-1944 # ffffffffc02069b0 <default_pmm_manager+0x240>
ffffffffc0204150:	884fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0204154:	86b2                	mv	a3,a2
ffffffffc0204156:	06900593          	li	a1,105
ffffffffc020415a:	00001617          	auipc	a2,0x1
ffffffffc020415e:	53660613          	addi	a2,a2,1334 # ffffffffc0205690 <commands+0x840>
ffffffffc0204162:	00001517          	auipc	a0,0x1
ffffffffc0204166:	58650513          	addi	a0,a0,1414 # ffffffffc02056e8 <commands+0x898>
ffffffffc020416a:	86afc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020416e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020416e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204170:	9402                	jalr	s0

	jal do_exit
ffffffffc0204172:	392000ef          	jal	ra,ffffffffc0204504 <do_exit>

ffffffffc0204176 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204176:	00011797          	auipc	a5,0x11
ffffffffc020417a:	33a78793          	addi	a5,a5,826 # ffffffffc02154b0 <current>
ffffffffc020417e:	639c                	ld	a5,0(a5)
ffffffffc0204180:	73c8                	ld	a0,160(a5)
ffffffffc0204182:	a03fc06f          	j	ffffffffc0200b84 <forkrets>

ffffffffc0204186 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204186:	1101                	addi	sp,sp,-32
ffffffffc0204188:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020418a:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020418e:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204190:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204192:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204194:	8522                	mv	a0,s0
ffffffffc0204196:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204198:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020419a:	702000ef          	jal	ra,ffffffffc020489c <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020419e:	8522                	mv	a0,s0
}
ffffffffc02041a0:	6442                	ld	s0,16(sp)
ffffffffc02041a2:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02041a4:	85a6                	mv	a1,s1
}
ffffffffc02041a6:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02041a8:	463d                	li	a2,15
}
ffffffffc02041aa:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02041ac:	a709                	j	ffffffffc02048ae <memcpy>

ffffffffc02041ae <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc02041ae:	1101                	addi	sp,sp,-32
ffffffffc02041b0:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc02041b2:	00011417          	auipc	s0,0x11
ffffffffc02041b6:	2ae40413          	addi	s0,s0,686 # ffffffffc0215460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc02041ba:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc02041bc:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc02041be:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc02041c0:	4581                	li	a1,0
ffffffffc02041c2:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc02041c4:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02041c6:	6d6000ef          	jal	ra,ffffffffc020489c <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02041ca:	8522                	mv	a0,s0
}
ffffffffc02041cc:	6442                	ld	s0,16(sp)
ffffffffc02041ce:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02041d0:	0b448593          	addi	a1,s1,180
}
ffffffffc02041d4:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02041d6:	463d                	li	a2,15
}
ffffffffc02041d8:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02041da:	add1                	j	ffffffffc02048ae <memcpy>

ffffffffc02041dc <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041dc:	00011797          	auipc	a5,0x11
ffffffffc02041e0:	2d478793          	addi	a5,a5,724 # ffffffffc02154b0 <current>
ffffffffc02041e4:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02041e6:	1101                	addi	sp,sp,-32
ffffffffc02041e8:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041ea:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02041ec:	e822                	sd	s0,16(sp)
ffffffffc02041ee:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041f0:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02041f2:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041f4:	fbbff0ef          	jal	ra,ffffffffc02041ae <get_proc_name>
ffffffffc02041f8:	862a                	mv	a2,a0
ffffffffc02041fa:	85a6                	mv	a1,s1
ffffffffc02041fc:	00003517          	auipc	a0,0x3
ffffffffc0204200:	83450513          	addi	a0,a0,-1996 # ffffffffc0206a30 <default_pmm_manager+0x2c0>
ffffffffc0204204:	ecdfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204208:	85a2                	mv	a1,s0
ffffffffc020420a:	00003517          	auipc	a0,0x3
ffffffffc020420e:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206a58 <default_pmm_manager+0x2e8>
ffffffffc0204212:	ebffb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204216:	00003517          	auipc	a0,0x3
ffffffffc020421a:	85250513          	addi	a0,a0,-1966 # ffffffffc0206a68 <default_pmm_manager+0x2f8>
ffffffffc020421e:	eb3fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0204222:	60e2                	ld	ra,24(sp)
ffffffffc0204224:	6442                	ld	s0,16(sp)
ffffffffc0204226:	64a2                	ld	s1,8(sp)
ffffffffc0204228:	4501                	li	a0,0
ffffffffc020422a:	6105                	addi	sp,sp,32
ffffffffc020422c:	8082                	ret

ffffffffc020422e <proc_run>:
}
ffffffffc020422e:	8082                	ret

ffffffffc0204230 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204230:	0005071b          	sext.w	a4,a0
ffffffffc0204234:	6789                	lui	a5,0x2
ffffffffc0204236:	fff7069b          	addiw	a3,a4,-1
ffffffffc020423a:	17f9                	addi	a5,a5,-2
ffffffffc020423c:	04d7e063          	bltu	a5,a3,ffffffffc020427c <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204240:	1141                	addi	sp,sp,-16
ffffffffc0204242:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204244:	45a9                	li	a1,10
ffffffffc0204246:	842a                	mv	s0,a0
ffffffffc0204248:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020424a:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020424c:	297000ef          	jal	ra,ffffffffc0204ce2 <hash32>
ffffffffc0204250:	02051693          	slli	a3,a0,0x20
ffffffffc0204254:	82f1                	srli	a3,a3,0x1c
ffffffffc0204256:	0000d517          	auipc	a0,0xd
ffffffffc020425a:	20a50513          	addi	a0,a0,522 # ffffffffc0211460 <hash_list>
ffffffffc020425e:	96aa                	add	a3,a3,a0
ffffffffc0204260:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204262:	a029                	j	ffffffffc020426c <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204264:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc0204268:	00870c63          	beq	a4,s0,ffffffffc0204280 <find_proc+0x50>
    return listelm->next;
ffffffffc020426c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020426e:	fef69be3          	bne	a3,a5,ffffffffc0204264 <find_proc+0x34>
}
ffffffffc0204272:	60a2                	ld	ra,8(sp)
ffffffffc0204274:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204276:	4501                	li	a0,0
}
ffffffffc0204278:	0141                	addi	sp,sp,16
ffffffffc020427a:	8082                	ret
    return NULL;
ffffffffc020427c:	4501                	li	a0,0
}
ffffffffc020427e:	8082                	ret
ffffffffc0204280:	60a2                	ld	ra,8(sp)
ffffffffc0204282:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204284:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204288:	0141                	addi	sp,sp,16
ffffffffc020428a:	8082                	ret

ffffffffc020428c <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc020428c:	00011797          	auipc	a5,0x11
ffffffffc0204290:	23c78793          	addi	a5,a5,572 # ffffffffc02154c8 <nr_process>
ffffffffc0204294:	4398                	lw	a4,0(a5)
ffffffffc0204296:	6785                	lui	a5,0x1
ffffffffc0204298:	1cf75e63          	bge	a4,a5,ffffffffc0204474 <do_fork+0x1e8>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020429c:	7179                	addi	sp,sp,-48
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020429e:	0e800513          	li	a0,232
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02042a2:	f022                	sd	s0,32(sp)
ffffffffc02042a4:	ec26                	sd	s1,24(sp)
ffffffffc02042a6:	e84a                	sd	s2,16(sp)
ffffffffc02042a8:	f406                	sd	ra,40(sp)
ffffffffc02042aa:	e44e                	sd	s3,8(sp)
ffffffffc02042ac:	892e                	mv	s2,a1
ffffffffc02042ae:	84b2                	mv	s1,a2
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02042b0:	b1efe0ef          	jal	ra,ffffffffc02025ce <kmalloc>
ffffffffc02042b4:	842a                	mv	s0,a0
    if(proc == NULL){
ffffffffc02042b6:	1c050163          	beqz	a0,ffffffffc0204478 <do_fork+0x1ec>
    proc->parent = current;
ffffffffc02042ba:	00011997          	auipc	s3,0x11
ffffffffc02042be:	1f698993          	addi	s3,s3,502 # ffffffffc02154b0 <current>
ffffffffc02042c2:	0009b783          	ld	a5,0(s3)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02042c6:	4509                	li	a0,2
    proc->parent = current;
ffffffffc02042c8:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02042ca:	8ddfc0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
    if (page != NULL) {
ffffffffc02042ce:	18050e63          	beqz	a0,ffffffffc020446a <do_fork+0x1de>
    return page - pages + nbase;
ffffffffc02042d2:	00011797          	auipc	a5,0x11
ffffffffc02042d6:	21e78793          	addi	a5,a5,542 # ffffffffc02154f0 <pages>
ffffffffc02042da:	6394                	ld	a3,0(a5)
ffffffffc02042dc:	00003797          	auipc	a5,0x3
ffffffffc02042e0:	b0478793          	addi	a5,a5,-1276 # ffffffffc0206de0 <nbase>
ffffffffc02042e4:	40d506b3          	sub	a3,a0,a3
ffffffffc02042e8:	6388                	ld	a0,0(a5)
ffffffffc02042ea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02042ec:	00011797          	auipc	a5,0x11
ffffffffc02042f0:	19c78793          	addi	a5,a5,412 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc02042f4:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02042f6:	6398                	ld	a4,0(a5)
ffffffffc02042f8:	00c69793          	slli	a5,a3,0xc
ffffffffc02042fc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02042fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204300:	18e7fe63          	bgeu	a5,a4,ffffffffc020449c <do_fork+0x210>
    assert(current->mm == NULL);
ffffffffc0204304:	0009b783          	ld	a5,0(s3)
ffffffffc0204308:	00011717          	auipc	a4,0x11
ffffffffc020430c:	1d870713          	addi	a4,a4,472 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0204310:	6318                	ld	a4,0(a4)
ffffffffc0204312:	779c                	ld	a5,40(a5)
ffffffffc0204314:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204316:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204318:	16079263          	bnez	a5,ffffffffc020447c <do_fork+0x1f0>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020431c:	6789                	lui	a5,0x2
ffffffffc020431e:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc0204322:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204324:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204326:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204328:	87b6                	mv	a5,a3
ffffffffc020432a:	12048893          	addi	a7,s1,288
ffffffffc020432e:	00063803          	ld	a6,0(a2)
ffffffffc0204332:	6608                	ld	a0,8(a2)
ffffffffc0204334:	6a0c                	ld	a1,16(a2)
ffffffffc0204336:	6e18                	ld	a4,24(a2)
ffffffffc0204338:	0107b023          	sd	a6,0(a5)
ffffffffc020433c:	e788                	sd	a0,8(a5)
ffffffffc020433e:	eb8c                	sd	a1,16(a5)
ffffffffc0204340:	ef98                	sd	a4,24(a5)
ffffffffc0204342:	02060613          	addi	a2,a2,32
ffffffffc0204346:	02078793          	addi	a5,a5,32
ffffffffc020434a:	ff1612e3          	bne	a2,a7,ffffffffc020432e <do_fork+0xa2>
    proc->tf->gpr.a0 = 0;
ffffffffc020434e:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204352:	0e090e63          	beqz	s2,ffffffffc020444e <do_fork+0x1c2>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204356:	00006797          	auipc	a5,0x6
ffffffffc020435a:	d0278793          	addi	a5,a5,-766 # ffffffffc020a058 <last_pid.1575>
ffffffffc020435e:	439c                	lw	a5,0(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204360:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204364:	00000717          	auipc	a4,0x0
ffffffffc0204368:	e1270713          	addi	a4,a4,-494 # ffffffffc0204176 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc020436c:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204370:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204372:	fc14                	sd	a3,56(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204374:	00006717          	auipc	a4,0x6
ffffffffc0204378:	cea72223          	sw	a0,-796(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc020437c:	6789                	lui	a5,0x2
ffffffffc020437e:	0cf55a63          	bge	a0,a5,ffffffffc0204452 <do_fork+0x1c6>
    if (last_pid >= next_safe) {
ffffffffc0204382:	00006797          	auipc	a5,0x6
ffffffffc0204386:	cda78793          	addi	a5,a5,-806 # ffffffffc020a05c <next_safe.1574>
ffffffffc020438a:	439c                	lw	a5,0(a5)
ffffffffc020438c:	00011497          	auipc	s1,0x11
ffffffffc0204390:	26448493          	addi	s1,s1,612 # ffffffffc02155f0 <proc_list>
ffffffffc0204394:	06f54063          	blt	a0,a5,ffffffffc02043f4 <do_fork+0x168>
        next_safe = MAX_PID;
ffffffffc0204398:	6789                	lui	a5,0x2
ffffffffc020439a:	00006717          	auipc	a4,0x6
ffffffffc020439e:	ccf72123          	sw	a5,-830(a4) # ffffffffc020a05c <next_safe.1574>
ffffffffc02043a2:	4581                	li	a1,0
ffffffffc02043a4:	87aa                	mv	a5,a0
ffffffffc02043a6:	00011497          	auipc	s1,0x11
ffffffffc02043aa:	24a48493          	addi	s1,s1,586 # ffffffffc02155f0 <proc_list>
    repeat:
ffffffffc02043ae:	6889                	lui	a7,0x2
ffffffffc02043b0:	882e                	mv	a6,a1
ffffffffc02043b2:	6609                	lui	a2,0x2
        le = list;
ffffffffc02043b4:	00011697          	auipc	a3,0x11
ffffffffc02043b8:	23c68693          	addi	a3,a3,572 # ffffffffc02155f0 <proc_list>
ffffffffc02043bc:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02043be:	00968f63          	beq	a3,s1,ffffffffc02043dc <do_fork+0x150>
            if (proc->pid == last_pid) {
ffffffffc02043c2:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02043c6:	06e78f63          	beq	a5,a4,ffffffffc0204444 <do_fork+0x1b8>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02043ca:	fee7d9e3          	bge	a5,a4,ffffffffc02043bc <do_fork+0x130>
ffffffffc02043ce:	fec757e3          	bge	a4,a2,ffffffffc02043bc <do_fork+0x130>
ffffffffc02043d2:	6694                	ld	a3,8(a3)
ffffffffc02043d4:	863a                	mv	a2,a4
ffffffffc02043d6:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02043d8:	fe9695e3          	bne	a3,s1,ffffffffc02043c2 <do_fork+0x136>
ffffffffc02043dc:	c591                	beqz	a1,ffffffffc02043e8 <do_fork+0x15c>
ffffffffc02043de:	00006717          	auipc	a4,0x6
ffffffffc02043e2:	c6f72d23          	sw	a5,-902(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02043e6:	853e                	mv	a0,a5
ffffffffc02043e8:	00080663          	beqz	a6,ffffffffc02043f4 <do_fork+0x168>
ffffffffc02043ec:	00006797          	auipc	a5,0x6
ffffffffc02043f0:	c6c7a823          	sw	a2,-912(a5) # ffffffffc020a05c <next_safe.1574>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02043f4:	45a9                	li	a1,10
    proc->pid = get_pid();
ffffffffc02043f6:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02043f8:	2501                	sext.w	a0,a0
ffffffffc02043fa:	0e9000ef          	jal	ra,ffffffffc0204ce2 <hash32>
ffffffffc02043fe:	1502                	slli	a0,a0,0x20
ffffffffc0204400:	0000d797          	auipc	a5,0xd
ffffffffc0204404:	06078793          	addi	a5,a5,96 # ffffffffc0211460 <hash_list>
ffffffffc0204408:	8171                	srli	a0,a0,0x1c
ffffffffc020440a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020440c:	651c                	ld	a5,8(a0)
ffffffffc020440e:	0d840693          	addi	a3,s0,216
ffffffffc0204412:	6498                	ld	a4,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204414:	e394                	sd	a3,0(a5)
ffffffffc0204416:	e514                	sd	a3,8(a0)
    elm->next = next;
ffffffffc0204418:	f07c                	sd	a5,224(s0)
    elm->prev = prev;
ffffffffc020441a:	ec68                	sd	a0,216(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020441c:	0c840793          	addi	a5,s0,200
    prev->next = next->prev = elm;
ffffffffc0204420:	e31c                	sd	a5,0(a4)
    elm->next = next;
ffffffffc0204422:	e878                	sd	a4,208(s0)
    wakeup_proc(proc);
ffffffffc0204424:	8522                	mv	a0,s0
    elm->prev = prev;
ffffffffc0204426:	e464                	sd	s1,200(s0)
    prev->next = next->prev = elm;
ffffffffc0204428:	00011717          	auipc	a4,0x11
ffffffffc020442c:	1cf73823          	sd	a5,464(a4) # ffffffffc02155f8 <proc_list+0x8>
ffffffffc0204430:	302000ef          	jal	ra,ffffffffc0204732 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204434:	4048                	lw	a0,4(s0)
}
ffffffffc0204436:	70a2                	ld	ra,40(sp)
ffffffffc0204438:	7402                	ld	s0,32(sp)
ffffffffc020443a:	64e2                	ld	s1,24(sp)
ffffffffc020443c:	6942                	ld	s2,16(sp)
ffffffffc020443e:	69a2                	ld	s3,8(sp)
ffffffffc0204440:	6145                	addi	sp,sp,48
ffffffffc0204442:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204444:	2785                	addiw	a5,a5,1
ffffffffc0204446:	00c7dd63          	bge	a5,a2,ffffffffc0204460 <do_fork+0x1d4>
ffffffffc020444a:	4585                	li	a1,1
ffffffffc020444c:	bf85                	j	ffffffffc02043bc <do_fork+0x130>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020444e:	8936                	mv	s2,a3
ffffffffc0204450:	b719                	j	ffffffffc0204356 <do_fork+0xca>
        last_pid = 1;
ffffffffc0204452:	4785                	li	a5,1
ffffffffc0204454:	00006717          	auipc	a4,0x6
ffffffffc0204458:	c0f72223          	sw	a5,-1020(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc020445c:	4505                	li	a0,1
ffffffffc020445e:	bf2d                	j	ffffffffc0204398 <do_fork+0x10c>
                    if (last_pid >= MAX_PID) {
ffffffffc0204460:	0117c363          	blt	a5,a7,ffffffffc0204466 <do_fork+0x1da>
                        last_pid = 1;
ffffffffc0204464:	4785                	li	a5,1
                    goto repeat;
ffffffffc0204466:	4585                	li	a1,1
ffffffffc0204468:	b7a1                	j	ffffffffc02043b0 <do_fork+0x124>
    kfree(proc);
ffffffffc020446a:	8522                	mv	a0,s0
ffffffffc020446c:	a1efe0ef          	jal	ra,ffffffffc020268a <kfree>
    ret = -E_NO_MEM;
ffffffffc0204470:	5571                	li	a0,-4
    goto fork_out;
ffffffffc0204472:	b7d1                	j	ffffffffc0204436 <do_fork+0x1aa>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204474:	556d                	li	a0,-5
}
ffffffffc0204476:	8082                	ret
    ret = -E_NO_MEM;
ffffffffc0204478:	5571                	li	a0,-4
ffffffffc020447a:	bf75                	j	ffffffffc0204436 <do_fork+0x1aa>
    assert(current->mm == NULL);
ffffffffc020447c:	00002697          	auipc	a3,0x2
ffffffffc0204480:	58468693          	addi	a3,a3,1412 # ffffffffc0206a00 <default_pmm_manager+0x290>
ffffffffc0204484:	00001617          	auipc	a2,0x1
ffffffffc0204488:	36460613          	addi	a2,a2,868 # ffffffffc02057e8 <commands+0x998>
ffffffffc020448c:	0f300593          	li	a1,243
ffffffffc0204490:	00002517          	auipc	a0,0x2
ffffffffc0204494:	58850513          	addi	a0,a0,1416 # ffffffffc0206a18 <default_pmm_manager+0x2a8>
ffffffffc0204498:	d3dfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc020449c:	00001617          	auipc	a2,0x1
ffffffffc02044a0:	1f460613          	addi	a2,a2,500 # ffffffffc0205690 <commands+0x840>
ffffffffc02044a4:	06900593          	li	a1,105
ffffffffc02044a8:	00001517          	auipc	a0,0x1
ffffffffc02044ac:	24050513          	addi	a0,a0,576 # ffffffffc02056e8 <commands+0x898>
ffffffffc02044b0:	d25fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02044b4 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02044b4:	7129                	addi	sp,sp,-320
ffffffffc02044b6:	fa22                	sd	s0,304(sp)
ffffffffc02044b8:	f626                	sd	s1,296(sp)
ffffffffc02044ba:	f24a                	sd	s2,288(sp)
ffffffffc02044bc:	84ae                	mv	s1,a1
ffffffffc02044be:	892a                	mv	s2,a0
ffffffffc02044c0:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02044c2:	4581                	li	a1,0
ffffffffc02044c4:	12000613          	li	a2,288
ffffffffc02044c8:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02044ca:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02044cc:	3d0000ef          	jal	ra,ffffffffc020489c <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02044d0:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02044d2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02044d4:	100027f3          	csrr	a5,sstatus
ffffffffc02044d8:	edd7f793          	andi	a5,a5,-291
ffffffffc02044dc:	1207e793          	ori	a5,a5,288
ffffffffc02044e0:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044e2:	860a                	mv	a2,sp
ffffffffc02044e4:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044e8:	00000797          	auipc	a5,0x0
ffffffffc02044ec:	c8678793          	addi	a5,a5,-890 # ffffffffc020416e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044f0:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044f2:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044f4:	d99ff0ef          	jal	ra,ffffffffc020428c <do_fork>
}
ffffffffc02044f8:	70f2                	ld	ra,312(sp)
ffffffffc02044fa:	7452                	ld	s0,304(sp)
ffffffffc02044fc:	74b2                	ld	s1,296(sp)
ffffffffc02044fe:	7912                	ld	s2,288(sp)
ffffffffc0204500:	6131                	addi	sp,sp,320
ffffffffc0204502:	8082                	ret

ffffffffc0204504 <do_exit>:
do_exit(int error_code) {
ffffffffc0204504:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204506:	00002617          	auipc	a2,0x2
ffffffffc020450a:	4e260613          	addi	a2,a2,1250 # ffffffffc02069e8 <default_pmm_manager+0x278>
ffffffffc020450e:	14f00593          	li	a1,335
ffffffffc0204512:	00002517          	auipc	a0,0x2
ffffffffc0204516:	50650513          	addi	a0,a0,1286 # ffffffffc0206a18 <default_pmm_manager+0x2a8>
do_exit(int error_code) {
ffffffffc020451a:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc020451c:	cb9fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204520 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0204520:	00011797          	auipc	a5,0x11
ffffffffc0204524:	0d078793          	addi	a5,a5,208 # ffffffffc02155f0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204528:	1101                	addi	sp,sp,-32
ffffffffc020452a:	00011717          	auipc	a4,0x11
ffffffffc020452e:	0cf73723          	sd	a5,206(a4) # ffffffffc02155f8 <proc_list+0x8>
ffffffffc0204532:	00011717          	auipc	a4,0x11
ffffffffc0204536:	0af73f23          	sd	a5,190(a4) # ffffffffc02155f0 <proc_list>
ffffffffc020453a:	ec06                	sd	ra,24(sp)
ffffffffc020453c:	e822                	sd	s0,16(sp)
ffffffffc020453e:	e426                	sd	s1,8(sp)
ffffffffc0204540:	e04a                	sd	s2,0(sp)
ffffffffc0204542:	0000d797          	auipc	a5,0xd
ffffffffc0204546:	f1e78793          	addi	a5,a5,-226 # ffffffffc0211460 <hash_list>
ffffffffc020454a:	00011717          	auipc	a4,0x11
ffffffffc020454e:	f1670713          	addi	a4,a4,-234 # ffffffffc0215460 <name.1565>
ffffffffc0204552:	e79c                	sd	a5,8(a5)
ffffffffc0204554:	e39c                	sd	a5,0(a5)
ffffffffc0204556:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204558:	fee79de3          	bne	a5,a4,ffffffffc0204552 <proc_init+0x32>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020455c:	0e800513          	li	a0,232
ffffffffc0204560:	86efe0ef          	jal	ra,ffffffffc02025ce <kmalloc>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204564:	00011797          	auipc	a5,0x11
ffffffffc0204568:	f4a7ba23          	sd	a0,-172(a5) # ffffffffc02154b8 <idleproc>
ffffffffc020456c:	00011417          	auipc	s0,0x11
ffffffffc0204570:	f4c40413          	addi	s0,s0,-180 # ffffffffc02154b8 <idleproc>
ffffffffc0204574:	12050963          	beqz	a0,ffffffffc02046a6 <proc_init+0x186>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204578:	07000513          	li	a0,112
ffffffffc020457c:	852fe0ef          	jal	ra,ffffffffc02025ce <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204580:	07000613          	li	a2,112
ffffffffc0204584:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204586:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204588:	314000ef          	jal	ra,ffffffffc020489c <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020458c:	6008                	ld	a0,0(s0)
ffffffffc020458e:	85a6                	mv	a1,s1
ffffffffc0204590:	07000613          	li	a2,112
ffffffffc0204594:	03050513          	addi	a0,a0,48
ffffffffc0204598:	32e000ef          	jal	ra,ffffffffc02048c6 <memcmp>
ffffffffc020459c:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020459e:	453d                	li	a0,15
ffffffffc02045a0:	82efe0ef          	jal	ra,ffffffffc02025ce <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02045a4:	463d                	li	a2,15
ffffffffc02045a6:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02045a8:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02045aa:	2f2000ef          	jal	ra,ffffffffc020489c <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02045ae:	6008                	ld	a0,0(s0)
ffffffffc02045b0:	463d                	li	a2,15
ffffffffc02045b2:	85a6                	mv	a1,s1
ffffffffc02045b4:	0b450513          	addi	a0,a0,180
ffffffffc02045b8:	30e000ef          	jal	ra,ffffffffc02048c6 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02045bc:	601c                	ld	a5,0(s0)
ffffffffc02045be:	00011717          	auipc	a4,0x11
ffffffffc02045c2:	f2a70713          	addi	a4,a4,-214 # ffffffffc02154e8 <boot_cr3>
ffffffffc02045c6:	6318                	ld	a4,0(a4)
ffffffffc02045c8:	77d4                	ld	a3,168(a5)
ffffffffc02045ca:	08e68d63          	beq	a3,a4,ffffffffc0204664 <proc_init+0x144>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02045ce:	4709                	li	a4,2
ffffffffc02045d0:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc02045d2:	4485                	li	s1,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02045d4:	00003717          	auipc	a4,0x3
ffffffffc02045d8:	a2c70713          	addi	a4,a4,-1492 # ffffffffc0207000 <bootstack>
ffffffffc02045dc:	eb98                	sd	a4,16(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02045de:	00002597          	auipc	a1,0x2
ffffffffc02045e2:	4da58593          	addi	a1,a1,1242 # ffffffffc0206ab8 <default_pmm_manager+0x348>
    idleproc->need_resched = 1;
ffffffffc02045e6:	cf84                	sw	s1,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02045e8:	853e                	mv	a0,a5
ffffffffc02045ea:	b9dff0ef          	jal	ra,ffffffffc0204186 <set_proc_name>
    nr_process ++;
ffffffffc02045ee:	00011797          	auipc	a5,0x11
ffffffffc02045f2:	eda78793          	addi	a5,a5,-294 # ffffffffc02154c8 <nr_process>
ffffffffc02045f6:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02045f8:	6018                	ld	a4,0(s0)
    
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02045fa:	4601                	li	a2,0
    nr_process ++;
ffffffffc02045fc:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02045fe:	00002597          	auipc	a1,0x2
ffffffffc0204602:	4c258593          	addi	a1,a1,1218 # ffffffffc0206ac0 <default_pmm_manager+0x350>
ffffffffc0204606:	00000517          	auipc	a0,0x0
ffffffffc020460a:	bd650513          	addi	a0,a0,-1066 # ffffffffc02041dc <init_main>
    nr_process ++;
ffffffffc020460e:	00011697          	auipc	a3,0x11
ffffffffc0204612:	eaf6ad23          	sw	a5,-326(a3) # ffffffffc02154c8 <nr_process>
    current = idleproc;
ffffffffc0204616:	00011797          	auipc	a5,0x11
ffffffffc020461a:	e8e7bd23          	sd	a4,-358(a5) # ffffffffc02154b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020461e:	e97ff0ef          	jal	ra,ffffffffc02044b4 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204622:	0ca05e63          	blez	a0,ffffffffc02046fe <proc_init+0x1de>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204626:	c0bff0ef          	jal	ra,ffffffffc0204230 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc020462a:	00002597          	auipc	a1,0x2
ffffffffc020462e:	4c658593          	addi	a1,a1,1222 # ffffffffc0206af0 <default_pmm_manager+0x380>
    initproc = find_proc(pid);
ffffffffc0204632:	00011797          	auipc	a5,0x11
ffffffffc0204636:	e8a7b723          	sd	a0,-370(a5) # ffffffffc02154c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc020463a:	b4dff0ef          	jal	ra,ffffffffc0204186 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020463e:	601c                	ld	a5,0(s0)
ffffffffc0204640:	cfd9                	beqz	a5,ffffffffc02046de <proc_init+0x1be>
ffffffffc0204642:	43dc                	lw	a5,4(a5)
ffffffffc0204644:	efc9                	bnez	a5,ffffffffc02046de <proc_init+0x1be>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204646:	00011797          	auipc	a5,0x11
ffffffffc020464a:	e7a78793          	addi	a5,a5,-390 # ffffffffc02154c0 <initproc>
ffffffffc020464e:	639c                	ld	a5,0(a5)
ffffffffc0204650:	c7bd                	beqz	a5,ffffffffc02046be <proc_init+0x19e>
ffffffffc0204652:	43dc                	lw	a5,4(a5)
ffffffffc0204654:	06979563          	bne	a5,s1,ffffffffc02046be <proc_init+0x19e>
}
ffffffffc0204658:	60e2                	ld	ra,24(sp)
ffffffffc020465a:	6442                	ld	s0,16(sp)
ffffffffc020465c:	64a2                	ld	s1,8(sp)
ffffffffc020465e:	6902                	ld	s2,0(sp)
ffffffffc0204660:	6105                	addi	sp,sp,32
ffffffffc0204662:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204664:	73d8                	ld	a4,160(a5)
ffffffffc0204666:	f725                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
ffffffffc0204668:	f60913e3          	bnez	s2,ffffffffc02045ce <proc_init+0xae>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc020466c:	6394                	ld	a3,0(a5)
ffffffffc020466e:	577d                	li	a4,-1
ffffffffc0204670:	1702                	slli	a4,a4,0x20
ffffffffc0204672:	f4e69ee3          	bne	a3,a4,ffffffffc02045ce <proc_init+0xae>
ffffffffc0204676:	4798                	lw	a4,8(a5)
ffffffffc0204678:	fb39                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc020467a:	6b98                	ld	a4,16(a5)
ffffffffc020467c:	fb29                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
ffffffffc020467e:	4f98                	lw	a4,24(a5)
ffffffffc0204680:	2701                	sext.w	a4,a4
ffffffffc0204682:	f731                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
ffffffffc0204684:	7398                	ld	a4,32(a5)
ffffffffc0204686:	f721                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204688:	7798                	ld	a4,40(a5)
ffffffffc020468a:	f331                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
ffffffffc020468c:	0b07a703          	lw	a4,176(a5)
ffffffffc0204690:	8f49                	or	a4,a4,a0
ffffffffc0204692:	2701                	sext.w	a4,a4
ffffffffc0204694:	ff0d                	bnez	a4,ffffffffc02045ce <proc_init+0xae>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204696:	00002517          	auipc	a0,0x2
ffffffffc020469a:	40a50513          	addi	a0,a0,1034 # ffffffffc0206aa0 <default_pmm_manager+0x330>
ffffffffc020469e:	a33fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02046a2:	601c                	ld	a5,0(s0)
ffffffffc02046a4:	b72d                	j	ffffffffc02045ce <proc_init+0xae>
        panic("cannot alloc idleproc.\n");
ffffffffc02046a6:	00002617          	auipc	a2,0x2
ffffffffc02046aa:	3e260613          	addi	a2,a2,994 # ffffffffc0206a88 <default_pmm_manager+0x318>
ffffffffc02046ae:	16700593          	li	a1,359
ffffffffc02046b2:	00002517          	auipc	a0,0x2
ffffffffc02046b6:	36650513          	addi	a0,a0,870 # ffffffffc0206a18 <default_pmm_manager+0x2a8>
ffffffffc02046ba:	b1bfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02046be:	00002697          	auipc	a3,0x2
ffffffffc02046c2:	46268693          	addi	a3,a3,1122 # ffffffffc0206b20 <default_pmm_manager+0x3b0>
ffffffffc02046c6:	00001617          	auipc	a2,0x1
ffffffffc02046ca:	12260613          	addi	a2,a2,290 # ffffffffc02057e8 <commands+0x998>
ffffffffc02046ce:	18e00593          	li	a1,398
ffffffffc02046d2:	00002517          	auipc	a0,0x2
ffffffffc02046d6:	34650513          	addi	a0,a0,838 # ffffffffc0206a18 <default_pmm_manager+0x2a8>
ffffffffc02046da:	afbfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02046de:	00002697          	auipc	a3,0x2
ffffffffc02046e2:	41a68693          	addi	a3,a3,1050 # ffffffffc0206af8 <default_pmm_manager+0x388>
ffffffffc02046e6:	00001617          	auipc	a2,0x1
ffffffffc02046ea:	10260613          	addi	a2,a2,258 # ffffffffc02057e8 <commands+0x998>
ffffffffc02046ee:	18d00593          	li	a1,397
ffffffffc02046f2:	00002517          	auipc	a0,0x2
ffffffffc02046f6:	32650513          	addi	a0,a0,806 # ffffffffc0206a18 <default_pmm_manager+0x2a8>
ffffffffc02046fa:	adbfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("create init_main failed.\n");
ffffffffc02046fe:	00002617          	auipc	a2,0x2
ffffffffc0204702:	3d260613          	addi	a2,a2,978 # ffffffffc0206ad0 <default_pmm_manager+0x360>
ffffffffc0204706:	18700593          	li	a1,391
ffffffffc020470a:	00002517          	auipc	a0,0x2
ffffffffc020470e:	30e50513          	addi	a0,a0,782 # ffffffffc0206a18 <default_pmm_manager+0x2a8>
ffffffffc0204712:	ac3fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204716 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204716:	1141                	addi	sp,sp,-16
ffffffffc0204718:	e022                	sd	s0,0(sp)
ffffffffc020471a:	e406                	sd	ra,8(sp)
ffffffffc020471c:	00011417          	auipc	s0,0x11
ffffffffc0204720:	d9440413          	addi	s0,s0,-620 # ffffffffc02154b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204724:	6018                	ld	a4,0(s0)
ffffffffc0204726:	4f1c                	lw	a5,24(a4)
ffffffffc0204728:	2781                	sext.w	a5,a5
ffffffffc020472a:	dff5                	beqz	a5,ffffffffc0204726 <cpu_idle+0x10>
            schedule();
ffffffffc020472c:	038000ef          	jal	ra,ffffffffc0204764 <schedule>
ffffffffc0204730:	bfd5                	j	ffffffffc0204724 <cpu_idle+0xe>

ffffffffc0204732 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204732:	411c                	lw	a5,0(a0)
ffffffffc0204734:	4705                	li	a4,1
ffffffffc0204736:	37f9                	addiw	a5,a5,-2
ffffffffc0204738:	00f77563          	bgeu	a4,a5,ffffffffc0204742 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc020473c:	4789                	li	a5,2
ffffffffc020473e:	c11c                	sw	a5,0(a0)
ffffffffc0204740:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204742:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204744:	00002697          	auipc	a3,0x2
ffffffffc0204748:	40468693          	addi	a3,a3,1028 # ffffffffc0206b48 <default_pmm_manager+0x3d8>
ffffffffc020474c:	00001617          	auipc	a2,0x1
ffffffffc0204750:	09c60613          	addi	a2,a2,156 # ffffffffc02057e8 <commands+0x998>
ffffffffc0204754:	45a5                	li	a1,9
ffffffffc0204756:	00002517          	auipc	a0,0x2
ffffffffc020475a:	43250513          	addi	a0,a0,1074 # ffffffffc0206b88 <default_pmm_manager+0x418>
wakeup_proc(struct proc_struct *proc) {
ffffffffc020475e:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204760:	a75fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204764 <schedule>:
}

void
schedule(void) {
ffffffffc0204764:	1141                	addi	sp,sp,-16
ffffffffc0204766:	e406                	sd	ra,8(sp)
ffffffffc0204768:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020476a:	100027f3          	csrr	a5,sstatus
ffffffffc020476e:	8b89                	andi	a5,a5,2
ffffffffc0204770:	4401                	li	s0,0
ffffffffc0204772:	e3d1                	bnez	a5,ffffffffc02047f6 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204774:	00011797          	auipc	a5,0x11
ffffffffc0204778:	d3c78793          	addi	a5,a5,-708 # ffffffffc02154b0 <current>
ffffffffc020477c:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204780:	00011797          	auipc	a5,0x11
ffffffffc0204784:	d3878793          	addi	a5,a5,-712 # ffffffffc02154b8 <idleproc>
ffffffffc0204788:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc020478a:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020478e:	04a88e63          	beq	a7,a0,ffffffffc02047ea <schedule+0x86>
ffffffffc0204792:	0c888693          	addi	a3,a7,200
ffffffffc0204796:	00011617          	auipc	a2,0x11
ffffffffc020479a:	e5a60613          	addi	a2,a2,-422 # ffffffffc02155f0 <proc_list>
        le = last;
ffffffffc020479e:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02047a0:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047a2:	4809                	li	a6,2
    return listelm->next;
ffffffffc02047a4:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02047a6:	00c78863          	beq	a5,a2,ffffffffc02047b6 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047aa:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02047ae:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047b2:	01070463          	beq	a4,a6,ffffffffc02047ba <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02047b6:	fef697e3          	bne	a3,a5,ffffffffc02047a4 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02047ba:	c589                	beqz	a1,ffffffffc02047c4 <schedule+0x60>
ffffffffc02047bc:	4198                	lw	a4,0(a1)
ffffffffc02047be:	4789                	li	a5,2
ffffffffc02047c0:	00f70e63          	beq	a4,a5,ffffffffc02047dc <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02047c4:	451c                	lw	a5,8(a0)
ffffffffc02047c6:	2785                	addiw	a5,a5,1
ffffffffc02047c8:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02047ca:	00a88463          	beq	a7,a0,ffffffffc02047d2 <schedule+0x6e>
            proc_run(next);
ffffffffc02047ce:	a61ff0ef          	jal	ra,ffffffffc020422e <proc_run>
    if (flag) {
ffffffffc02047d2:	e419                	bnez	s0,ffffffffc02047e0 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02047d4:	60a2                	ld	ra,8(sp)
ffffffffc02047d6:	6402                	ld	s0,0(sp)
ffffffffc02047d8:	0141                	addi	sp,sp,16
ffffffffc02047da:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02047dc:	852e                	mv	a0,a1
ffffffffc02047de:	b7dd                	j	ffffffffc02047c4 <schedule+0x60>
}
ffffffffc02047e0:	6402                	ld	s0,0(sp)
ffffffffc02047e2:	60a2                	ld	ra,8(sp)
ffffffffc02047e4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02047e6:	de7fb06f          	j	ffffffffc02005cc <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02047ea:	00011617          	auipc	a2,0x11
ffffffffc02047ee:	e0660613          	addi	a2,a2,-506 # ffffffffc02155f0 <proc_list>
ffffffffc02047f2:	86b2                	mv	a3,a2
ffffffffc02047f4:	b76d                	j	ffffffffc020479e <schedule+0x3a>
        intr_disable();
ffffffffc02047f6:	dddfb0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        return 1;
ffffffffc02047fa:	4405                	li	s0,1
ffffffffc02047fc:	bfa5                	j	ffffffffc0204774 <schedule+0x10>

ffffffffc02047fe <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02047fe:	00054783          	lbu	a5,0(a0)
ffffffffc0204802:	cb91                	beqz	a5,ffffffffc0204816 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204804:	4781                	li	a5,0
        cnt ++;
ffffffffc0204806:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204808:	00f50733          	add	a4,a0,a5
ffffffffc020480c:	00074703          	lbu	a4,0(a4)
ffffffffc0204810:	fb7d                	bnez	a4,ffffffffc0204806 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204812:	853e                	mv	a0,a5
ffffffffc0204814:	8082                	ret
    size_t cnt = 0;
ffffffffc0204816:	4781                	li	a5,0
}
ffffffffc0204818:	853e                	mv	a0,a5
ffffffffc020481a:	8082                	ret

ffffffffc020481c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020481c:	c185                	beqz	a1,ffffffffc020483c <strnlen+0x20>
ffffffffc020481e:	00054783          	lbu	a5,0(a0)
ffffffffc0204822:	cf89                	beqz	a5,ffffffffc020483c <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204824:	4781                	li	a5,0
ffffffffc0204826:	a021                	j	ffffffffc020482e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204828:	00074703          	lbu	a4,0(a4)
ffffffffc020482c:	c711                	beqz	a4,ffffffffc0204838 <strnlen+0x1c>
        cnt ++;
ffffffffc020482e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204830:	00f50733          	add	a4,a0,a5
ffffffffc0204834:	fef59ae3          	bne	a1,a5,ffffffffc0204828 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204838:	853e                	mv	a0,a5
ffffffffc020483a:	8082                	ret
    size_t cnt = 0;
ffffffffc020483c:	4781                	li	a5,0
}
ffffffffc020483e:	853e                	mv	a0,a5
ffffffffc0204840:	8082                	ret

ffffffffc0204842 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204842:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204844:	0585                	addi	a1,a1,1
ffffffffc0204846:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020484a:	0785                	addi	a5,a5,1
ffffffffc020484c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204850:	fb75                	bnez	a4,ffffffffc0204844 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204852:	8082                	ret

ffffffffc0204854 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204854:	00054783          	lbu	a5,0(a0)
ffffffffc0204858:	0005c703          	lbu	a4,0(a1)
ffffffffc020485c:	cb91                	beqz	a5,ffffffffc0204870 <strcmp+0x1c>
ffffffffc020485e:	00e79c63          	bne	a5,a4,ffffffffc0204876 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204862:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204864:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204868:	0585                	addi	a1,a1,1
ffffffffc020486a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020486e:	fbe5                	bnez	a5,ffffffffc020485e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204870:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204872:	9d19                	subw	a0,a0,a4
ffffffffc0204874:	8082                	ret
ffffffffc0204876:	0007851b          	sext.w	a0,a5
ffffffffc020487a:	9d19                	subw	a0,a0,a4
ffffffffc020487c:	8082                	ret

ffffffffc020487e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020487e:	00054783          	lbu	a5,0(a0)
ffffffffc0204882:	cb91                	beqz	a5,ffffffffc0204896 <strchr+0x18>
        if (*s == c) {
ffffffffc0204884:	00b79563          	bne	a5,a1,ffffffffc020488e <strchr+0x10>
ffffffffc0204888:	a809                	j	ffffffffc020489a <strchr+0x1c>
ffffffffc020488a:	00b78763          	beq	a5,a1,ffffffffc0204898 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020488e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204890:	00054783          	lbu	a5,0(a0)
ffffffffc0204894:	fbfd                	bnez	a5,ffffffffc020488a <strchr+0xc>
    }
    return NULL;
ffffffffc0204896:	4501                	li	a0,0
}
ffffffffc0204898:	8082                	ret
ffffffffc020489a:	8082                	ret

ffffffffc020489c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020489c:	ca01                	beqz	a2,ffffffffc02048ac <memset+0x10>
ffffffffc020489e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02048a0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02048a2:	0785                	addi	a5,a5,1
ffffffffc02048a4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02048a8:	fec79de3          	bne	a5,a2,ffffffffc02048a2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02048ac:	8082                	ret

ffffffffc02048ae <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02048ae:	ca19                	beqz	a2,ffffffffc02048c4 <memcpy+0x16>
ffffffffc02048b0:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02048b2:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02048b4:	0585                	addi	a1,a1,1
ffffffffc02048b6:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02048ba:	0785                	addi	a5,a5,1
ffffffffc02048bc:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02048c0:	fec59ae3          	bne	a1,a2,ffffffffc02048b4 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02048c4:	8082                	ret

ffffffffc02048c6 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc02048c6:	c21d                	beqz	a2,ffffffffc02048ec <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc02048c8:	00054783          	lbu	a5,0(a0)
ffffffffc02048cc:	0005c703          	lbu	a4,0(a1)
ffffffffc02048d0:	962a                	add	a2,a2,a0
ffffffffc02048d2:	00f70963          	beq	a4,a5,ffffffffc02048e4 <memcmp+0x1e>
ffffffffc02048d6:	a829                	j	ffffffffc02048f0 <memcmp+0x2a>
ffffffffc02048d8:	00054783          	lbu	a5,0(a0)
ffffffffc02048dc:	0005c703          	lbu	a4,0(a1)
ffffffffc02048e0:	00e79863          	bne	a5,a4,ffffffffc02048f0 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc02048e4:	0505                	addi	a0,a0,1
ffffffffc02048e6:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc02048e8:	fea618e3          	bne	a2,a0,ffffffffc02048d8 <memcmp+0x12>
    }
    return 0;
ffffffffc02048ec:	4501                	li	a0,0
}
ffffffffc02048ee:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02048f0:	40e7853b          	subw	a0,a5,a4
ffffffffc02048f4:	8082                	ret

ffffffffc02048f6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02048f6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02048fa:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02048fc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204900:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204902:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204906:	f022                	sd	s0,32(sp)
ffffffffc0204908:	ec26                	sd	s1,24(sp)
ffffffffc020490a:	e84a                	sd	s2,16(sp)
ffffffffc020490c:	f406                	sd	ra,40(sp)
ffffffffc020490e:	e44e                	sd	s3,8(sp)
ffffffffc0204910:	84aa                	mv	s1,a0
ffffffffc0204912:	892e                	mv	s2,a1
ffffffffc0204914:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204918:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020491a:	03067e63          	bgeu	a2,a6,ffffffffc0204956 <printnum+0x60>
ffffffffc020491e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204920:	00805763          	blez	s0,ffffffffc020492e <printnum+0x38>
ffffffffc0204924:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204926:	85ca                	mv	a1,s2
ffffffffc0204928:	854e                	mv	a0,s3
ffffffffc020492a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020492c:	fc65                	bnez	s0,ffffffffc0204924 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020492e:	1a02                	slli	s4,s4,0x20
ffffffffc0204930:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204934:	00002797          	auipc	a5,0x2
ffffffffc0204938:	3fc78793          	addi	a5,a5,1020 # ffffffffc0206d30 <error_string+0x38>
ffffffffc020493c:	9a3e                	add	s4,s4,a5
}
ffffffffc020493e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204940:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204944:	70a2                	ld	ra,40(sp)
ffffffffc0204946:	69a2                	ld	s3,8(sp)
ffffffffc0204948:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020494a:	85ca                	mv	a1,s2
ffffffffc020494c:	8326                	mv	t1,s1
}
ffffffffc020494e:	6942                	ld	s2,16(sp)
ffffffffc0204950:	64e2                	ld	s1,24(sp)
ffffffffc0204952:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204954:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204956:	03065633          	divu	a2,a2,a6
ffffffffc020495a:	8722                	mv	a4,s0
ffffffffc020495c:	f9bff0ef          	jal	ra,ffffffffc02048f6 <printnum>
ffffffffc0204960:	b7f9                	j	ffffffffc020492e <printnum+0x38>

ffffffffc0204962 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204962:	7119                	addi	sp,sp,-128
ffffffffc0204964:	f4a6                	sd	s1,104(sp)
ffffffffc0204966:	f0ca                	sd	s2,96(sp)
ffffffffc0204968:	e8d2                	sd	s4,80(sp)
ffffffffc020496a:	e4d6                	sd	s5,72(sp)
ffffffffc020496c:	e0da                	sd	s6,64(sp)
ffffffffc020496e:	fc5e                	sd	s7,56(sp)
ffffffffc0204970:	f862                	sd	s8,48(sp)
ffffffffc0204972:	f06a                	sd	s10,32(sp)
ffffffffc0204974:	fc86                	sd	ra,120(sp)
ffffffffc0204976:	f8a2                	sd	s0,112(sp)
ffffffffc0204978:	ecce                	sd	s3,88(sp)
ffffffffc020497a:	f466                	sd	s9,40(sp)
ffffffffc020497c:	ec6e                	sd	s11,24(sp)
ffffffffc020497e:	892a                	mv	s2,a0
ffffffffc0204980:	84ae                	mv	s1,a1
ffffffffc0204982:	8d32                	mv	s10,a2
ffffffffc0204984:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204986:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204988:	00002a17          	auipc	s4,0x2
ffffffffc020498c:	218a0a13          	addi	s4,s4,536 # ffffffffc0206ba0 <default_pmm_manager+0x430>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204990:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204994:	00002c17          	auipc	s8,0x2
ffffffffc0204998:	364c0c13          	addi	s8,s8,868 # ffffffffc0206cf8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020499c:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02049a0:	02500793          	li	a5,37
ffffffffc02049a4:	001d0413          	addi	s0,s10,1
ffffffffc02049a8:	00f50e63          	beq	a0,a5,ffffffffc02049c4 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02049ac:	c521                	beqz	a0,ffffffffc02049f4 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02049ae:	02500993          	li	s3,37
ffffffffc02049b2:	a011                	j	ffffffffc02049b6 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02049b4:	c121                	beqz	a0,ffffffffc02049f4 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02049b6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02049b8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02049ba:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02049bc:	fff44503          	lbu	a0,-1(s0)
ffffffffc02049c0:	ff351ae3          	bne	a0,s3,ffffffffc02049b4 <vprintfmt+0x52>
ffffffffc02049c4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02049c8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02049cc:	4981                	li	s3,0
ffffffffc02049ce:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02049d0:	5cfd                	li	s9,-1
ffffffffc02049d2:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049d4:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02049d8:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049da:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02049de:	0ff6f693          	andi	a3,a3,255
ffffffffc02049e2:	00140d13          	addi	s10,s0,1
ffffffffc02049e6:	1ed5ef63          	bltu	a1,a3,ffffffffc0204be4 <vprintfmt+0x282>
ffffffffc02049ea:	068a                	slli	a3,a3,0x2
ffffffffc02049ec:	96d2                	add	a3,a3,s4
ffffffffc02049ee:	4294                	lw	a3,0(a3)
ffffffffc02049f0:	96d2                	add	a3,a3,s4
ffffffffc02049f2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02049f4:	70e6                	ld	ra,120(sp)
ffffffffc02049f6:	7446                	ld	s0,112(sp)
ffffffffc02049f8:	74a6                	ld	s1,104(sp)
ffffffffc02049fa:	7906                	ld	s2,96(sp)
ffffffffc02049fc:	69e6                	ld	s3,88(sp)
ffffffffc02049fe:	6a46                	ld	s4,80(sp)
ffffffffc0204a00:	6aa6                	ld	s5,72(sp)
ffffffffc0204a02:	6b06                	ld	s6,64(sp)
ffffffffc0204a04:	7be2                	ld	s7,56(sp)
ffffffffc0204a06:	7c42                	ld	s8,48(sp)
ffffffffc0204a08:	7ca2                	ld	s9,40(sp)
ffffffffc0204a0a:	7d02                	ld	s10,32(sp)
ffffffffc0204a0c:	6de2                	ld	s11,24(sp)
ffffffffc0204a0e:	6109                	addi	sp,sp,128
ffffffffc0204a10:	8082                	ret
            padc = '-';
ffffffffc0204a12:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a14:	00144603          	lbu	a2,1(s0)
ffffffffc0204a18:	846a                	mv	s0,s10
ffffffffc0204a1a:	b7c1                	j	ffffffffc02049da <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0204a1c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204a20:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204a24:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a26:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204a28:	fa0dd9e3          	bgez	s11,ffffffffc02049da <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204a2c:	8de6                	mv	s11,s9
ffffffffc0204a2e:	5cfd                	li	s9,-1
ffffffffc0204a30:	b76d                	j	ffffffffc02049da <vprintfmt+0x78>
            if (width < 0)
ffffffffc0204a32:	fffdc693          	not	a3,s11
ffffffffc0204a36:	96fd                	srai	a3,a3,0x3f
ffffffffc0204a38:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204a3c:	00144603          	lbu	a2,1(s0)
ffffffffc0204a40:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a42:	846a                	mv	s0,s10
ffffffffc0204a44:	bf59                	j	ffffffffc02049da <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204a46:	4705                	li	a4,1
ffffffffc0204a48:	008a8593          	addi	a1,s5,8
ffffffffc0204a4c:	01074463          	blt	a4,a6,ffffffffc0204a54 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0204a50:	22080863          	beqz	a6,ffffffffc0204c80 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0204a54:	000ab603          	ld	a2,0(s5)
ffffffffc0204a58:	46c1                	li	a3,16
ffffffffc0204a5a:	8aae                	mv	s5,a1
ffffffffc0204a5c:	a291                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0204a5e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204a62:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a66:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204a68:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204a6c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204a70:	fad56ce3          	bltu	a0,a3,ffffffffc0204a28 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204a74:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204a76:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204a7a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204a7e:	0196873b          	addw	a4,a3,s9
ffffffffc0204a82:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204a86:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204a8a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204a8e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204a92:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204a96:	fcd57fe3          	bgeu	a0,a3,ffffffffc0204a74 <vprintfmt+0x112>
ffffffffc0204a9a:	b779                	j	ffffffffc0204a28 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0204a9c:	000aa503          	lw	a0,0(s5)
ffffffffc0204aa0:	85a6                	mv	a1,s1
ffffffffc0204aa2:	0aa1                	addi	s5,s5,8
ffffffffc0204aa4:	9902                	jalr	s2
            break;
ffffffffc0204aa6:	bddd                	j	ffffffffc020499c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204aa8:	4705                	li	a4,1
ffffffffc0204aaa:	008a8993          	addi	s3,s5,8
ffffffffc0204aae:	01074463          	blt	a4,a6,ffffffffc0204ab6 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0204ab2:	1c080463          	beqz	a6,ffffffffc0204c7a <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0204ab6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204aba:	1c044a63          	bltz	s0,ffffffffc0204c8e <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0204abe:	8622                	mv	a2,s0
ffffffffc0204ac0:	8ace                	mv	s5,s3
ffffffffc0204ac2:	46a9                	li	a3,10
ffffffffc0204ac4:	a8f1                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0204ac6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204aca:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204acc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204ace:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204ad2:	8fb5                	xor	a5,a5,a3
ffffffffc0204ad4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204ad8:	12d74963          	blt	a4,a3,ffffffffc0204c0a <vprintfmt+0x2a8>
ffffffffc0204adc:	00369793          	slli	a5,a3,0x3
ffffffffc0204ae0:	97e2                	add	a5,a5,s8
ffffffffc0204ae2:	639c                	ld	a5,0(a5)
ffffffffc0204ae4:	12078363          	beqz	a5,ffffffffc0204c0a <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204ae8:	86be                	mv	a3,a5
ffffffffc0204aea:	00000617          	auipc	a2,0x0
ffffffffc0204aee:	23e60613          	addi	a2,a2,574 # ffffffffc0204d28 <etext+0x2e>
ffffffffc0204af2:	85a6                	mv	a1,s1
ffffffffc0204af4:	854a                	mv	a0,s2
ffffffffc0204af6:	1cc000ef          	jal	ra,ffffffffc0204cc2 <printfmt>
ffffffffc0204afa:	b54d                	j	ffffffffc020499c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204afc:	000ab603          	ld	a2,0(s5)
ffffffffc0204b00:	0aa1                	addi	s5,s5,8
ffffffffc0204b02:	1a060163          	beqz	a2,ffffffffc0204ca4 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0204b06:	00160413          	addi	s0,a2,1
ffffffffc0204b0a:	15b05763          	blez	s11,ffffffffc0204c58 <vprintfmt+0x2f6>
ffffffffc0204b0e:	02d00593          	li	a1,45
ffffffffc0204b12:	10b79d63          	bne	a5,a1,ffffffffc0204c2c <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b16:	00064783          	lbu	a5,0(a2)
ffffffffc0204b1a:	0007851b          	sext.w	a0,a5
ffffffffc0204b1e:	c905                	beqz	a0,ffffffffc0204b4e <vprintfmt+0x1ec>
ffffffffc0204b20:	000cc563          	bltz	s9,ffffffffc0204b2a <vprintfmt+0x1c8>
ffffffffc0204b24:	3cfd                	addiw	s9,s9,-1
ffffffffc0204b26:	036c8263          	beq	s9,s6,ffffffffc0204b4a <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0204b2a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b2c:	14098f63          	beqz	s3,ffffffffc0204c8a <vprintfmt+0x328>
ffffffffc0204b30:	3781                	addiw	a5,a5,-32
ffffffffc0204b32:	14fbfc63          	bgeu	s7,a5,ffffffffc0204c8a <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0204b36:	03f00513          	li	a0,63
ffffffffc0204b3a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b3c:	0405                	addi	s0,s0,1
ffffffffc0204b3e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204b42:	3dfd                	addiw	s11,s11,-1
ffffffffc0204b44:	0007851b          	sext.w	a0,a5
ffffffffc0204b48:	fd61                	bnez	a0,ffffffffc0204b20 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0204b4a:	e5b059e3          	blez	s11,ffffffffc020499c <vprintfmt+0x3a>
ffffffffc0204b4e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204b50:	85a6                	mv	a1,s1
ffffffffc0204b52:	02000513          	li	a0,32
ffffffffc0204b56:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204b58:	e40d82e3          	beqz	s11,ffffffffc020499c <vprintfmt+0x3a>
ffffffffc0204b5c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204b5e:	85a6                	mv	a1,s1
ffffffffc0204b60:	02000513          	li	a0,32
ffffffffc0204b64:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204b66:	fe0d94e3          	bnez	s11,ffffffffc0204b4e <vprintfmt+0x1ec>
ffffffffc0204b6a:	bd0d                	j	ffffffffc020499c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204b6c:	4705                	li	a4,1
ffffffffc0204b6e:	008a8593          	addi	a1,s5,8
ffffffffc0204b72:	01074463          	blt	a4,a6,ffffffffc0204b7a <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0204b76:	0e080863          	beqz	a6,ffffffffc0204c66 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0204b7a:	000ab603          	ld	a2,0(s5)
ffffffffc0204b7e:	46a1                	li	a3,8
ffffffffc0204b80:	8aae                	mv	s5,a1
ffffffffc0204b82:	a839                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0204b84:	03000513          	li	a0,48
ffffffffc0204b88:	85a6                	mv	a1,s1
ffffffffc0204b8a:	e03e                	sd	a5,0(sp)
ffffffffc0204b8c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204b8e:	85a6                	mv	a1,s1
ffffffffc0204b90:	07800513          	li	a0,120
ffffffffc0204b94:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204b96:	0aa1                	addi	s5,s5,8
ffffffffc0204b98:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204b9c:	6782                	ld	a5,0(sp)
ffffffffc0204b9e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204ba0:	2781                	sext.w	a5,a5
ffffffffc0204ba2:	876e                	mv	a4,s11
ffffffffc0204ba4:	85a6                	mv	a1,s1
ffffffffc0204ba6:	854a                	mv	a0,s2
ffffffffc0204ba8:	d4fff0ef          	jal	ra,ffffffffc02048f6 <printnum>
            break;
ffffffffc0204bac:	bbc5                	j	ffffffffc020499c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204bae:	00144603          	lbu	a2,1(s0)
ffffffffc0204bb2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bb4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bb6:	b515                	j	ffffffffc02049da <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204bb8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204bbc:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bbe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bc0:	bd29                	j	ffffffffc02049da <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204bc2:	85a6                	mv	a1,s1
ffffffffc0204bc4:	02500513          	li	a0,37
ffffffffc0204bc8:	9902                	jalr	s2
            break;
ffffffffc0204bca:	bbc9                	j	ffffffffc020499c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204bcc:	4705                	li	a4,1
ffffffffc0204bce:	008a8593          	addi	a1,s5,8
ffffffffc0204bd2:	01074463          	blt	a4,a6,ffffffffc0204bda <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0204bd6:	08080d63          	beqz	a6,ffffffffc0204c70 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0204bda:	000ab603          	ld	a2,0(s5)
ffffffffc0204bde:	46a9                	li	a3,10
ffffffffc0204be0:	8aae                	mv	s5,a1
ffffffffc0204be2:	bf7d                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0204be4:	85a6                	mv	a1,s1
ffffffffc0204be6:	02500513          	li	a0,37
ffffffffc0204bea:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204bec:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204bf0:	02500793          	li	a5,37
ffffffffc0204bf4:	8d22                	mv	s10,s0
ffffffffc0204bf6:	daf703e3          	beq	a4,a5,ffffffffc020499c <vprintfmt+0x3a>
ffffffffc0204bfa:	02500713          	li	a4,37
ffffffffc0204bfe:	1d7d                	addi	s10,s10,-1
ffffffffc0204c00:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204c04:	fee79de3          	bne	a5,a4,ffffffffc0204bfe <vprintfmt+0x29c>
ffffffffc0204c08:	bb51                	j	ffffffffc020499c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204c0a:	00002617          	auipc	a2,0x2
ffffffffc0204c0e:	1c660613          	addi	a2,a2,454 # ffffffffc0206dd0 <error_string+0xd8>
ffffffffc0204c12:	85a6                	mv	a1,s1
ffffffffc0204c14:	854a                	mv	a0,s2
ffffffffc0204c16:	0ac000ef          	jal	ra,ffffffffc0204cc2 <printfmt>
ffffffffc0204c1a:	b349                	j	ffffffffc020499c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204c1c:	00002617          	auipc	a2,0x2
ffffffffc0204c20:	1ac60613          	addi	a2,a2,428 # ffffffffc0206dc8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204c24:	00002417          	auipc	s0,0x2
ffffffffc0204c28:	1a540413          	addi	s0,s0,421 # ffffffffc0206dc9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c2c:	8532                	mv	a0,a2
ffffffffc0204c2e:	85e6                	mv	a1,s9
ffffffffc0204c30:	e032                	sd	a2,0(sp)
ffffffffc0204c32:	e43e                	sd	a5,8(sp)
ffffffffc0204c34:	be9ff0ef          	jal	ra,ffffffffc020481c <strnlen>
ffffffffc0204c38:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204c3c:	6602                	ld	a2,0(sp)
ffffffffc0204c3e:	01b05d63          	blez	s11,ffffffffc0204c58 <vprintfmt+0x2f6>
ffffffffc0204c42:	67a2                	ld	a5,8(sp)
ffffffffc0204c44:	2781                	sext.w	a5,a5
ffffffffc0204c46:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204c48:	6522                	ld	a0,8(sp)
ffffffffc0204c4a:	85a6                	mv	a1,s1
ffffffffc0204c4c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c4e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204c50:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c52:	6602                	ld	a2,0(sp)
ffffffffc0204c54:	fe0d9ae3          	bnez	s11,ffffffffc0204c48 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c58:	00064783          	lbu	a5,0(a2)
ffffffffc0204c5c:	0007851b          	sext.w	a0,a5
ffffffffc0204c60:	ec0510e3          	bnez	a0,ffffffffc0204b20 <vprintfmt+0x1be>
ffffffffc0204c64:	bb25                	j	ffffffffc020499c <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0204c66:	000ae603          	lwu	a2,0(s5)
ffffffffc0204c6a:	46a1                	li	a3,8
ffffffffc0204c6c:	8aae                	mv	s5,a1
ffffffffc0204c6e:	bf0d                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
ffffffffc0204c70:	000ae603          	lwu	a2,0(s5)
ffffffffc0204c74:	46a9                	li	a3,10
ffffffffc0204c76:	8aae                	mv	s5,a1
ffffffffc0204c78:	b725                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0204c7a:	000aa403          	lw	s0,0(s5)
ffffffffc0204c7e:	bd35                	j	ffffffffc0204aba <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0204c80:	000ae603          	lwu	a2,0(s5)
ffffffffc0204c84:	46c1                	li	a3,16
ffffffffc0204c86:	8aae                	mv	s5,a1
ffffffffc0204c88:	bf21                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0204c8a:	9902                	jalr	s2
ffffffffc0204c8c:	bd45                	j	ffffffffc0204b3c <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0204c8e:	85a6                	mv	a1,s1
ffffffffc0204c90:	02d00513          	li	a0,45
ffffffffc0204c94:	e03e                	sd	a5,0(sp)
ffffffffc0204c96:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204c98:	8ace                	mv	s5,s3
ffffffffc0204c9a:	40800633          	neg	a2,s0
ffffffffc0204c9e:	46a9                	li	a3,10
ffffffffc0204ca0:	6782                	ld	a5,0(sp)
ffffffffc0204ca2:	bdfd                	j	ffffffffc0204ba0 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0204ca4:	01b05663          	blez	s11,ffffffffc0204cb0 <vprintfmt+0x34e>
ffffffffc0204ca8:	02d00693          	li	a3,45
ffffffffc0204cac:	f6d798e3          	bne	a5,a3,ffffffffc0204c1c <vprintfmt+0x2ba>
ffffffffc0204cb0:	00002417          	auipc	s0,0x2
ffffffffc0204cb4:	11940413          	addi	s0,s0,281 # ffffffffc0206dc9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cb8:	02800513          	li	a0,40
ffffffffc0204cbc:	02800793          	li	a5,40
ffffffffc0204cc0:	b585                	j	ffffffffc0204b20 <vprintfmt+0x1be>

ffffffffc0204cc2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204cc2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204cc4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204cc8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204cca:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ccc:	ec06                	sd	ra,24(sp)
ffffffffc0204cce:	f83a                	sd	a4,48(sp)
ffffffffc0204cd0:	fc3e                	sd	a5,56(sp)
ffffffffc0204cd2:	e0c2                	sd	a6,64(sp)
ffffffffc0204cd4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204cd6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204cd8:	c8bff0ef          	jal	ra,ffffffffc0204962 <vprintfmt>
}
ffffffffc0204cdc:	60e2                	ld	ra,24(sp)
ffffffffc0204cde:	6161                	addi	sp,sp,80
ffffffffc0204ce0:	8082                	ret

ffffffffc0204ce2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204ce2:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204ce6:	2785                	addiw	a5,a5,1
ffffffffc0204ce8:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204cec:	02000793          	li	a5,32
ffffffffc0204cf0:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204cf4:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204cf8:	8082                	ret
