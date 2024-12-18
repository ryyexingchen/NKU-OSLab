
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	3d250513          	addi	a0,a0,978 # ffffffffc02a1408 <edata>
ffffffffc020003e:	000ad617          	auipc	a2,0xad
ffffffffc0200042:	95a60613          	addi	a2,a2,-1702 # ffffffffc02ac998 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	38a060ef          	jal	ra,ffffffffc02063d8 <memset>
    cons_init();                // init the console
ffffffffc0200052:	588000ef          	jal	ra,ffffffffc02005da <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	7b258593          	addi	a1,a1,1970 # ffffffffc0206808 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206828 <etext+0x22>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	258000ef          	jal	ra,ffffffffc02002c2 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5c4010ef          	jal	ra,ffffffffc0201632 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5da000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	764020ef          	jal	ra,ffffffffc02027de <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	765050ef          	jal	ra,ffffffffc0205fe2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4ac000ef          	jal	ra,ffffffffc020052e <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	43e030ef          	jal	ra,ffffffffc02034c4 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4fc000ef          	jal	ra,ffffffffc0200586 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c0000ef          	jal	ra,ffffffffc020064e <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	09c060ef          	jal	ra,ffffffffc020612e <cpu_idle>

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
ffffffffc020009e:	53e000ef          	jal	ra,ffffffffc02005dc <cons_putc>
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
ffffffffc02000c4:	3aa060ef          	jal	ra,ffffffffc020646e <vprintfmt>
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
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f8:	376060ef          	jal	ra,ffffffffc020646e <vprintfmt>
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
ffffffffc0200104:	a9e1                	j	ffffffffc02005dc <cons_putc>

ffffffffc0200106 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200106:	1101                	addi	sp,sp,-32
ffffffffc0200108:	e822                	sd	s0,16(sp)
ffffffffc020010a:	ec06                	sd	ra,24(sp)
ffffffffc020010c:	e426                	sd	s1,8(sp)
ffffffffc020010e:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200110:	00054503          	lbu	a0,0(a0)
ffffffffc0200114:	c51d                	beqz	a0,ffffffffc0200142 <cputs+0x3c>
ffffffffc0200116:	0405                	addi	s0,s0,1
ffffffffc0200118:	4485                	li	s1,1
ffffffffc020011a:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011c:	4c0000ef          	jal	ra,ffffffffc02005dc <cons_putc>
    (*cnt) ++;
ffffffffc0200120:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200124:	0405                	addi	s0,s0,1
ffffffffc0200126:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012a:	f96d                	bnez	a0,ffffffffc020011c <cputs+0x16>
ffffffffc020012c:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200130:	4529                	li	a0,10
ffffffffc0200132:	4aa000ef          	jal	ra,ffffffffc02005dc <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	60e2                	ld	ra,24(sp)
ffffffffc020013a:	6442                	ld	s0,16(sp)
ffffffffc020013c:	64a2                	ld	s1,8(sp)
ffffffffc020013e:	6105                	addi	sp,sp,32
ffffffffc0200140:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200142:	4405                	li	s0,1
ffffffffc0200144:	b7f5                	j	ffffffffc0200130 <cputs+0x2a>

ffffffffc0200146 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014a:	4c6000ef          	jal	ra,ffffffffc0200610 <cons_getc>
ffffffffc020014e:	dd75                	beqz	a0,ffffffffc020014a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200150:	60a2                	ld	ra,8(sp)
ffffffffc0200152:	0141                	addi	sp,sp,16
ffffffffc0200154:	8082                	ret

ffffffffc0200156 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200156:	715d                	addi	sp,sp,-80
ffffffffc0200158:	e486                	sd	ra,72(sp)
ffffffffc020015a:	e0a2                	sd	s0,64(sp)
ffffffffc020015c:	fc26                	sd	s1,56(sp)
ffffffffc020015e:	f84a                	sd	s2,48(sp)
ffffffffc0200160:	f44e                	sd	s3,40(sp)
ffffffffc0200162:	f052                	sd	s4,32(sp)
ffffffffc0200164:	ec56                	sd	s5,24(sp)
ffffffffc0200166:	e85a                	sd	s6,16(sp)
ffffffffc0200168:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016a:	c901                	beqz	a0,ffffffffc020017a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016c:	85aa                	mv	a1,a0
ffffffffc020016e:	00006517          	auipc	a0,0x6
ffffffffc0200172:	6c250513          	addi	a0,a0,1730 # ffffffffc0206830 <etext+0x2a>
ffffffffc0200176:	f5bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200180:	4aa9                	li	s5,10
ffffffffc0200182:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200184:	000a1b97          	auipc	s7,0xa1
ffffffffc0200188:	284b8b93          	addi	s7,s7,644 # ffffffffc02a1408 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200190:	fb7ff0ef          	jal	ra,ffffffffc0200146 <getchar>
ffffffffc0200194:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200196:	00054b63          	bltz	a0,ffffffffc02001ac <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019a:	00a95b63          	bge	s2,a0,ffffffffc02001b0 <readline+0x5a>
ffffffffc020019e:	029a5463          	bge	s4,s1,ffffffffc02001c6 <readline+0x70>
        c = getchar();
ffffffffc02001a2:	fa5ff0ef          	jal	ra,ffffffffc0200146 <getchar>
ffffffffc02001a6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001a8:	fe0559e3          	bgez	a0,ffffffffc020019a <readline+0x44>
            return NULL;
ffffffffc02001ac:	4501                	li	a0,0
ffffffffc02001ae:	a099                	j	ffffffffc02001f4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b0:	03341463          	bne	s0,s3,ffffffffc02001d8 <readline+0x82>
ffffffffc02001b4:	e8b9                	bnez	s1,ffffffffc020020a <readline+0xb4>
        c = getchar();
ffffffffc02001b6:	f91ff0ef          	jal	ra,ffffffffc0200146 <getchar>
ffffffffc02001ba:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001bc:	fe0548e3          	bltz	a0,ffffffffc02001ac <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c0:	fea958e3          	bge	s2,a0,ffffffffc02001b0 <readline+0x5a>
ffffffffc02001c4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c6:	8522                	mv	a0,s0
ffffffffc02001c8:	f3dff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001cc:	009b87b3          	add	a5,s7,s1
ffffffffc02001d0:	00878023          	sb	s0,0(a5)
ffffffffc02001d4:	2485                	addiw	s1,s1,1
ffffffffc02001d6:	bf6d                	j	ffffffffc0200190 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d8:	01540463          	beq	s0,s5,ffffffffc02001e0 <readline+0x8a>
ffffffffc02001dc:	fb641ae3          	bne	s0,s6,ffffffffc0200190 <readline+0x3a>
            cputchar(c);
ffffffffc02001e0:	8522                	mv	a0,s0
ffffffffc02001e2:	f23ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e6:	000a1517          	auipc	a0,0xa1
ffffffffc02001ea:	22250513          	addi	a0,a0,546 # ffffffffc02a1408 <edata>
ffffffffc02001ee:	94aa                	add	s1,s1,a0
ffffffffc02001f0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f4:	60a6                	ld	ra,72(sp)
ffffffffc02001f6:	6406                	ld	s0,64(sp)
ffffffffc02001f8:	74e2                	ld	s1,56(sp)
ffffffffc02001fa:	7942                	ld	s2,48(sp)
ffffffffc02001fc:	79a2                	ld	s3,40(sp)
ffffffffc02001fe:	7a02                	ld	s4,32(sp)
ffffffffc0200200:	6ae2                	ld	s5,24(sp)
ffffffffc0200202:	6b42                	ld	s6,16(sp)
ffffffffc0200204:	6ba2                	ld	s7,8(sp)
ffffffffc0200206:	6161                	addi	sp,sp,80
ffffffffc0200208:	8082                	ret
            cputchar(c);
ffffffffc020020a:	4521                	li	a0,8
ffffffffc020020c:	ef9ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200210:	34fd                	addiw	s1,s1,-1
ffffffffc0200212:	bfbd                	j	ffffffffc0200190 <readline+0x3a>

ffffffffc0200214 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200214:	000ac317          	auipc	t1,0xac
ffffffffc0200218:	5f430313          	addi	t1,t1,1524 # ffffffffc02ac808 <is_panic>
ffffffffc020021c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200220:	715d                	addi	sp,sp,-80
ffffffffc0200222:	ec06                	sd	ra,24(sp)
ffffffffc0200224:	e822                	sd	s0,16(sp)
ffffffffc0200226:	f436                	sd	a3,40(sp)
ffffffffc0200228:	f83a                	sd	a4,48(sp)
ffffffffc020022a:	fc3e                	sd	a5,56(sp)
ffffffffc020022c:	e0c2                	sd	a6,64(sp)
ffffffffc020022e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200230:	02031c63          	bnez	t1,ffffffffc0200268 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200234:	4785                	li	a5,1
ffffffffc0200236:	8432                	mv	s0,a2
ffffffffc0200238:	000ac717          	auipc	a4,0xac
ffffffffc020023c:	5cf73823          	sd	a5,1488(a4) # ffffffffc02ac808 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200242:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200244:	85aa                	mv	a1,a0
ffffffffc0200246:	00006517          	auipc	a0,0x6
ffffffffc020024a:	5f250513          	addi	a0,a0,1522 # ffffffffc0206838 <etext+0x32>
    va_start(ap, fmt);
ffffffffc020024e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200250:	e81ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200254:	65a2                	ld	a1,8(sp)
ffffffffc0200256:	8522                	mv	a0,s0
ffffffffc0200258:	e59ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025c:	00007517          	auipc	a0,0x7
ffffffffc0200260:	40450513          	addi	a0,a0,1028 # ffffffffc0207660 <commands+0xce8>
ffffffffc0200264:	e6dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	4581                	li	a1,0
ffffffffc020026c:	4601                	li	a2,0
ffffffffc020026e:	48a1                	li	a7,8
ffffffffc0200270:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200274:	3e0000ef          	jal	ra,ffffffffc0200654 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200278:	4501                	li	a0,0
ffffffffc020027a:	172000ef          	jal	ra,ffffffffc02003ec <kmonitor>
ffffffffc020027e:	bfed                	j	ffffffffc0200278 <__panic+0x64>

ffffffffc0200280 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200280:	715d                	addi	sp,sp,-80
ffffffffc0200282:	e822                	sd	s0,16(sp)
ffffffffc0200284:	fc3e                	sd	a5,56(sp)
ffffffffc0200286:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200288:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028a:	862e                	mv	a2,a1
ffffffffc020028c:	85aa                	mv	a1,a0
ffffffffc020028e:	00006517          	auipc	a0,0x6
ffffffffc0200292:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206858 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200296:	ec06                	sd	ra,24(sp)
ffffffffc0200298:	f436                	sd	a3,40(sp)
ffffffffc020029a:	f83a                	sd	a4,48(sp)
ffffffffc020029c:	e0c2                	sd	a6,64(sp)
ffffffffc020029e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a0:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a2:	e2fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a6:	65a2                	ld	a1,8(sp)
ffffffffc02002a8:	8522                	mv	a0,s0
ffffffffc02002aa:	e07ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002ae:	00007517          	auipc	a0,0x7
ffffffffc02002b2:	3b250513          	addi	a0,a0,946 # ffffffffc0207660 <commands+0xce8>
ffffffffc02002b6:	e1bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002ba:	60e2                	ld	ra,24(sp)
ffffffffc02002bc:	6442                	ld	s0,16(sp)
ffffffffc02002be:	6161                	addi	sp,sp,80
ffffffffc02002c0:	8082                	ret

ffffffffc02002c2 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	5e450513          	addi	a0,a0,1508 # ffffffffc02068a8 <etext+0xa2>
void print_kerninfo(void) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002ce:	e03ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d2:	00000597          	auipc	a1,0x0
ffffffffc02002d6:	d6458593          	addi	a1,a1,-668 # ffffffffc0200036 <kern_init>
ffffffffc02002da:	00006517          	auipc	a0,0x6
ffffffffc02002de:	5ee50513          	addi	a0,a0,1518 # ffffffffc02068c8 <etext+0xc2>
ffffffffc02002e2:	defff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	52058593          	addi	a1,a1,1312 # ffffffffc0206806 <etext>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	5fa50513          	addi	a0,a0,1530 # ffffffffc02068e8 <etext+0xe2>
ffffffffc02002f6:	ddbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fa:	000a1597          	auipc	a1,0xa1
ffffffffc02002fe:	10e58593          	addi	a1,a1,270 # ffffffffc02a1408 <edata>
ffffffffc0200302:	00006517          	auipc	a0,0x6
ffffffffc0200306:	60650513          	addi	a0,a0,1542 # ffffffffc0206908 <etext+0x102>
ffffffffc020030a:	dc7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020030e:	000ac597          	auipc	a1,0xac
ffffffffc0200312:	68a58593          	addi	a1,a1,1674 # ffffffffc02ac998 <end>
ffffffffc0200316:	00006517          	auipc	a0,0x6
ffffffffc020031a:	61250513          	addi	a0,a0,1554 # ffffffffc0206928 <etext+0x122>
ffffffffc020031e:	db3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200322:	000ad597          	auipc	a1,0xad
ffffffffc0200326:	a7558593          	addi	a1,a1,-1419 # ffffffffc02acd97 <end+0x3ff>
ffffffffc020032a:	00000797          	auipc	a5,0x0
ffffffffc020032e:	d0c78793          	addi	a5,a5,-756 # ffffffffc0200036 <kern_init>
ffffffffc0200332:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200336:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200340:	95be                	add	a1,a1,a5
ffffffffc0200342:	85a9                	srai	a1,a1,0xa
ffffffffc0200344:	00006517          	auipc	a0,0x6
ffffffffc0200348:	60450513          	addi	a0,a0,1540 # ffffffffc0206948 <etext+0x142>
}
ffffffffc020034c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020034e:	b349                	j	ffffffffc02000d0 <cprintf>

ffffffffc0200350 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200350:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200352:	00006617          	auipc	a2,0x6
ffffffffc0200356:	52660613          	addi	a2,a2,1318 # ffffffffc0206878 <etext+0x72>
ffffffffc020035a:	04d00593          	li	a1,77
ffffffffc020035e:	00006517          	auipc	a0,0x6
ffffffffc0200362:	53250513          	addi	a0,a0,1330 # ffffffffc0206890 <etext+0x8a>
void print_stackframe(void) {
ffffffffc0200366:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200368:	eadff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020036c <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020036c:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020036e:	00006617          	auipc	a2,0x6
ffffffffc0200372:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206a58 <commands+0xe0>
ffffffffc0200376:	00006597          	auipc	a1,0x6
ffffffffc020037a:	70258593          	addi	a1,a1,1794 # ffffffffc0206a78 <commands+0x100>
ffffffffc020037e:	00006517          	auipc	a0,0x6
ffffffffc0200382:	70250513          	addi	a0,a0,1794 # ffffffffc0206a80 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200386:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200388:	d49ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020038c:	00006617          	auipc	a2,0x6
ffffffffc0200390:	70460613          	addi	a2,a2,1796 # ffffffffc0206a90 <commands+0x118>
ffffffffc0200394:	00006597          	auipc	a1,0x6
ffffffffc0200398:	72458593          	addi	a1,a1,1828 # ffffffffc0206ab8 <commands+0x140>
ffffffffc020039c:	00006517          	auipc	a0,0x6
ffffffffc02003a0:	6e450513          	addi	a0,a0,1764 # ffffffffc0206a80 <commands+0x108>
ffffffffc02003a4:	d2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003a8:	00006617          	auipc	a2,0x6
ffffffffc02003ac:	72060613          	addi	a2,a2,1824 # ffffffffc0206ac8 <commands+0x150>
ffffffffc02003b0:	00006597          	auipc	a1,0x6
ffffffffc02003b4:	73858593          	addi	a1,a1,1848 # ffffffffc0206ae8 <commands+0x170>
ffffffffc02003b8:	00006517          	auipc	a0,0x6
ffffffffc02003bc:	6c850513          	addi	a0,a0,1736 # ffffffffc0206a80 <commands+0x108>
ffffffffc02003c0:	d11ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c4:	60a2                	ld	ra,8(sp)
ffffffffc02003c6:	4501                	li	a0,0
ffffffffc02003c8:	0141                	addi	sp,sp,16
ffffffffc02003ca:	8082                	ret

ffffffffc02003cc <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003cc:	1141                	addi	sp,sp,-16
ffffffffc02003ce:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d0:	ef3ff0ef          	jal	ra,ffffffffc02002c2 <print_kerninfo>
    return 0;
}
ffffffffc02003d4:	60a2                	ld	ra,8(sp)
ffffffffc02003d6:	4501                	li	a0,0
ffffffffc02003d8:	0141                	addi	sp,sp,16
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003dc:	1141                	addi	sp,sp,-16
ffffffffc02003de:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e0:	f71ff0ef          	jal	ra,ffffffffc0200350 <print_stackframe>
    return 0;
}
ffffffffc02003e4:	60a2                	ld	ra,8(sp)
ffffffffc02003e6:	4501                	li	a0,0
ffffffffc02003e8:	0141                	addi	sp,sp,16
ffffffffc02003ea:	8082                	ret

ffffffffc02003ec <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	7115                	addi	sp,sp,-224
ffffffffc02003ee:	e962                	sd	s8,144(sp)
ffffffffc02003f0:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f2:	00006517          	auipc	a0,0x6
ffffffffc02003f6:	5ce50513          	addi	a0,a0,1486 # ffffffffc02069c0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fa:	ed86                	sd	ra,216(sp)
ffffffffc02003fc:	e9a2                	sd	s0,208(sp)
ffffffffc02003fe:	e5a6                	sd	s1,200(sp)
ffffffffc0200400:	e1ca                	sd	s2,192(sp)
ffffffffc0200402:	fd4e                	sd	s3,184(sp)
ffffffffc0200404:	f952                	sd	s4,176(sp)
ffffffffc0200406:	f556                	sd	s5,168(sp)
ffffffffc0200408:	f15a                	sd	s6,160(sp)
ffffffffc020040a:	ed5e                	sd	s7,152(sp)
ffffffffc020040c:	e566                	sd	s9,136(sp)
ffffffffc020040e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200410:	cc1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200414:	00006517          	auipc	a0,0x6
ffffffffc0200418:	5d450513          	addi	a0,a0,1492 # ffffffffc02069e8 <commands+0x70>
ffffffffc020041c:	cb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200420:	000c0563          	beqz	s8,ffffffffc020042a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200424:	8562                	mv	a0,s8
ffffffffc0200426:	41c000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc020042a:	00006c97          	auipc	s9,0x6
ffffffffc020042e:	54ec8c93          	addi	s9,s9,1358 # ffffffffc0206978 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200432:	00006997          	auipc	s3,0x6
ffffffffc0200436:	5de98993          	addi	s3,s3,1502 # ffffffffc0206a10 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	00006917          	auipc	s2,0x6
ffffffffc020043e:	5de90913          	addi	s2,s2,1502 # ffffffffc0206a18 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200442:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200444:	00006b17          	auipc	s6,0x6
ffffffffc0200448:	5dcb0b13          	addi	s6,s6,1500 # ffffffffc0206a20 <commands+0xa8>
    if (argc == 0) {
ffffffffc020044c:	00006a97          	auipc	s5,0x6
ffffffffc0200450:	62ca8a93          	addi	s5,s5,1580 # ffffffffc0206a78 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200454:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200456:	854e                	mv	a0,s3
ffffffffc0200458:	cffff0ef          	jal	ra,ffffffffc0200156 <readline>
ffffffffc020045c:	842a                	mv	s0,a0
ffffffffc020045e:	dd65                	beqz	a0,ffffffffc0200456 <kmonitor+0x6a>
ffffffffc0200460:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200464:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200466:	c999                	beqz	a1,ffffffffc020047c <kmonitor+0x90>
ffffffffc0200468:	854a                	mv	a0,s2
ffffffffc020046a:	751050ef          	jal	ra,ffffffffc02063ba <strchr>
ffffffffc020046e:	c925                	beqz	a0,ffffffffc02004de <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
ffffffffc0200474:	00040023          	sb	zero,0(s0)
ffffffffc0200478:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047a:	f5fd                	bnez	a1,ffffffffc0200468 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020047c:	dce9                	beqz	s1,ffffffffc0200456 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047e:	6582                	ld	a1,0(sp)
ffffffffc0200480:	00006d17          	auipc	s10,0x6
ffffffffc0200484:	4f8d0d13          	addi	s10,s10,1272 # ffffffffc0206978 <commands>
    if (argc == 0) {
ffffffffc0200488:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048a:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020048c:	0d61                	addi	s10,s10,24
ffffffffc020048e:	703050ef          	jal	ra,ffffffffc0206390 <strcmp>
ffffffffc0200492:	c919                	beqz	a0,ffffffffc02004a8 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200494:	2405                	addiw	s0,s0,1
ffffffffc0200496:	09740463          	beq	s0,s7,ffffffffc020051e <kmonitor+0x132>
ffffffffc020049a:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020049e:	6582                	ld	a1,0(sp)
ffffffffc02004a0:	0d61                	addi	s10,s10,24
ffffffffc02004a2:	6ef050ef          	jal	ra,ffffffffc0206390 <strcmp>
ffffffffc02004a6:	f57d                	bnez	a0,ffffffffc0200494 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004a8:	00141793          	slli	a5,s0,0x1
ffffffffc02004ac:	97a2                	add	a5,a5,s0
ffffffffc02004ae:	078e                	slli	a5,a5,0x3
ffffffffc02004b0:	97e6                	add	a5,a5,s9
ffffffffc02004b2:	6b9c                	ld	a5,16(a5)
ffffffffc02004b4:	8662                	mv	a2,s8
ffffffffc02004b6:	002c                	addi	a1,sp,8
ffffffffc02004b8:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004be:	f8055ce3          	bgez	a0,ffffffffc0200456 <kmonitor+0x6a>
}
ffffffffc02004c2:	60ee                	ld	ra,216(sp)
ffffffffc02004c4:	644e                	ld	s0,208(sp)
ffffffffc02004c6:	64ae                	ld	s1,200(sp)
ffffffffc02004c8:	690e                	ld	s2,192(sp)
ffffffffc02004ca:	79ea                	ld	s3,184(sp)
ffffffffc02004cc:	7a4a                	ld	s4,176(sp)
ffffffffc02004ce:	7aaa                	ld	s5,168(sp)
ffffffffc02004d0:	7b0a                	ld	s6,160(sp)
ffffffffc02004d2:	6bea                	ld	s7,152(sp)
ffffffffc02004d4:	6c4a                	ld	s8,144(sp)
ffffffffc02004d6:	6caa                	ld	s9,136(sp)
ffffffffc02004d8:	6d0a                	ld	s10,128(sp)
ffffffffc02004da:	612d                	addi	sp,sp,224
ffffffffc02004dc:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004de:	00044783          	lbu	a5,0(s0)
ffffffffc02004e2:	dfc9                	beqz	a5,ffffffffc020047c <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e4:	03448863          	beq	s1,s4,ffffffffc0200514 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004e8:	00349793          	slli	a5,s1,0x3
ffffffffc02004ec:	0118                	addi	a4,sp,128
ffffffffc02004ee:	97ba                	add	a5,a5,a4
ffffffffc02004f0:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004f8:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	e591                	bnez	a1,ffffffffc0200506 <kmonitor+0x11a>
ffffffffc02004fc:	b749                	j	ffffffffc020047e <kmonitor+0x92>
            buf ++;
ffffffffc02004fe:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200500:	00044583          	lbu	a1,0(s0)
ffffffffc0200504:	ddad                	beqz	a1,ffffffffc020047e <kmonitor+0x92>
ffffffffc0200506:	854a                	mv	a0,s2
ffffffffc0200508:	6b3050ef          	jal	ra,ffffffffc02063ba <strchr>
ffffffffc020050c:	d96d                	beqz	a0,ffffffffc02004fe <kmonitor+0x112>
ffffffffc020050e:	00044583          	lbu	a1,0(s0)
ffffffffc0200512:	bf91                	j	ffffffffc0200466 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200514:	45c1                	li	a1,16
ffffffffc0200516:	855a                	mv	a0,s6
ffffffffc0200518:	bb9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020051c:	b7f1                	j	ffffffffc02004e8 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020051e:	6582                	ld	a1,0(sp)
ffffffffc0200520:	00006517          	auipc	a0,0x6
ffffffffc0200524:	52050513          	addi	a0,a0,1312 # ffffffffc0206a40 <commands+0xc8>
ffffffffc0200528:	ba9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc020052c:	b72d                	j	ffffffffc0200456 <kmonitor+0x6a>

ffffffffc020052e <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020052e:	8082                	ret

ffffffffc0200530 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200530:	00253513          	sltiu	a0,a0,2
ffffffffc0200534:	8082                	ret

ffffffffc0200536 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200536:	03800513          	li	a0,56
ffffffffc020053a:	8082                	ret

ffffffffc020053c <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020053c:	000a1797          	auipc	a5,0xa1
ffffffffc0200540:	2cc78793          	addi	a5,a5,716 # ffffffffc02a1808 <ide>
ffffffffc0200544:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200548:	1141                	addi	sp,sp,-16
ffffffffc020054a:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	95be                	add	a1,a1,a5
ffffffffc020054e:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200552:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200554:	697050ef          	jal	ra,ffffffffc02063ea <memcpy>
    return 0;
}
ffffffffc0200558:	60a2                	ld	ra,8(sp)
ffffffffc020055a:	4501                	li	a0,0
ffffffffc020055c:	0141                	addi	sp,sp,16
ffffffffc020055e:	8082                	ret

ffffffffc0200560 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200560:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200562:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200566:	000a1517          	auipc	a0,0xa1
ffffffffc020056a:	2a250513          	addi	a0,a0,674 # ffffffffc02a1808 <ide>
                   size_t nsecs) {
ffffffffc020056e:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	00969613          	slli	a2,a3,0x9
ffffffffc0200574:	85ba                	mv	a1,a4
ffffffffc0200576:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200578:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057a:	671050ef          	jal	ra,ffffffffc02063ea <memcpy>
    return 0;
}
ffffffffc020057e:	60a2                	ld	ra,8(sp)
ffffffffc0200580:	4501                	li	a0,0
ffffffffc0200582:	0141                	addi	sp,sp,16
ffffffffc0200584:	8082                	ret

ffffffffc0200586 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200586:	67e1                	lui	a5,0x18
ffffffffc0200588:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdbd8>
ffffffffc020058c:	000ac717          	auipc	a4,0xac
ffffffffc0200590:	28f73223          	sd	a5,644(a4) # ffffffffc02ac810 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200594:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200598:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059a:	953e                	add	a0,a0,a5
ffffffffc020059c:	4601                	li	a2,0
ffffffffc020059e:	4881                	li	a7,0
ffffffffc02005a0:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a4:	02000793          	li	a5,32
ffffffffc02005a8:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005ac:	00006517          	auipc	a0,0x6
ffffffffc02005b0:	54c50513          	addi	a0,a0,1356 # ffffffffc0206af8 <commands+0x180>
    ticks = 0;
ffffffffc02005b4:	000ac797          	auipc	a5,0xac
ffffffffc02005b8:	2a07ba23          	sd	zero,692(a5) # ffffffffc02ac868 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005bc:	be11                	j	ffffffffc02000d0 <cprintf>

ffffffffc02005be <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005be:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c2:	000ac797          	auipc	a5,0xac
ffffffffc02005c6:	24e78793          	addi	a5,a5,590 # ffffffffc02ac810 <timebase>
ffffffffc02005ca:	639c                	ld	a5,0(a5)
ffffffffc02005cc:	4581                	li	a1,0
ffffffffc02005ce:	4601                	li	a2,0
ffffffffc02005d0:	953e                	add	a0,a0,a5
ffffffffc02005d2:	4881                	li	a7,0
ffffffffc02005d4:	00000073          	ecall
ffffffffc02005d8:	8082                	ret

ffffffffc02005da <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005da:	8082                	ret

ffffffffc02005dc <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005dc:	100027f3          	csrr	a5,sstatus
ffffffffc02005e0:	8b89                	andi	a5,a5,2
ffffffffc02005e2:	0ff57513          	andi	a0,a0,255
ffffffffc02005e6:	e799                	bnez	a5,ffffffffc02005f4 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005e8:	4581                	li	a1,0
ffffffffc02005ea:	4601                	li	a2,0
ffffffffc02005ec:	4885                	li	a7,1
ffffffffc02005ee:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f2:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005f4:	1101                	addi	sp,sp,-32
ffffffffc02005f6:	ec06                	sd	ra,24(sp)
ffffffffc02005f8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005fa:	05a000ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc02005fe:	6522                	ld	a0,8(sp)
ffffffffc0200600:	4581                	li	a1,0
ffffffffc0200602:	4601                	li	a2,0
ffffffffc0200604:	4885                	li	a7,1
ffffffffc0200606:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020060a:	60e2                	ld	ra,24(sp)
ffffffffc020060c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020060e:	a081                	j	ffffffffc020064e <intr_enable>

ffffffffc0200610 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200610:	100027f3          	csrr	a5,sstatus
ffffffffc0200614:	8b89                	andi	a5,a5,2
ffffffffc0200616:	eb89                	bnez	a5,ffffffffc0200628 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200618:	4501                	li	a0,0
ffffffffc020061a:	4581                	li	a1,0
ffffffffc020061c:	4601                	li	a2,0
ffffffffc020061e:	4889                	li	a7,2
ffffffffc0200620:	00000073          	ecall
ffffffffc0200624:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200626:	8082                	ret
int cons_getc(void) {
ffffffffc0200628:	1101                	addi	sp,sp,-32
ffffffffc020062a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020062c:	028000ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc0200630:	4501                	li	a0,0
ffffffffc0200632:	4581                	li	a1,0
ffffffffc0200634:	4601                	li	a2,0
ffffffffc0200636:	4889                	li	a7,2
ffffffffc0200638:	00000073          	ecall
ffffffffc020063c:	2501                	sext.w	a0,a0
ffffffffc020063e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200640:	00e000ef          	jal	ra,ffffffffc020064e <intr_enable>
}
ffffffffc0200644:	60e2                	ld	ra,24(sp)
ffffffffc0200646:	6522                	ld	a0,8(sp)
ffffffffc0200648:	6105                	addi	sp,sp,32
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	66a78793          	addi	a5,a5,1642 # ffffffffc0200cc8 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00006517          	auipc	a0,0x6
ffffffffc0200680:	7c450513          	addi	a0,a0,1988 # ffffffffc0206e40 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	a4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	7cc50513          	addi	a0,a0,1996 # ffffffffc0206e58 <commands+0x4e0>
ffffffffc0200694:	a3dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	7d650513          	addi	a0,a0,2006 # ffffffffc0206e70 <commands+0x4f8>
ffffffffc02006a2:	a2fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	7e050513          	addi	a0,a0,2016 # ffffffffc0206e88 <commands+0x510>
ffffffffc02006b0:	a21ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206ea0 <commands+0x528>
ffffffffc02006be:	a13ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	7f450513          	addi	a0,a0,2036 # ffffffffc0206eb8 <commands+0x540>
ffffffffc02006cc:	a05ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206ed0 <commands+0x558>
ffffffffc02006da:	9f7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00007517          	auipc	a0,0x7
ffffffffc02006e4:	80850513          	addi	a0,a0,-2040 # ffffffffc0206ee8 <commands+0x570>
ffffffffc02006e8:	9e9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00007517          	auipc	a0,0x7
ffffffffc02006f2:	81250513          	addi	a0,a0,-2030 # ffffffffc0206f00 <commands+0x588>
ffffffffc02006f6:	9dbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00007517          	auipc	a0,0x7
ffffffffc0200700:	81c50513          	addi	a0,a0,-2020 # ffffffffc0206f18 <commands+0x5a0>
ffffffffc0200704:	9cdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00007517          	auipc	a0,0x7
ffffffffc020070e:	82650513          	addi	a0,a0,-2010 # ffffffffc0206f30 <commands+0x5b8>
ffffffffc0200712:	9bfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00007517          	auipc	a0,0x7
ffffffffc020071c:	83050513          	addi	a0,a0,-2000 # ffffffffc0206f48 <commands+0x5d0>
ffffffffc0200720:	9b1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00007517          	auipc	a0,0x7
ffffffffc020072a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0206f60 <commands+0x5e8>
ffffffffc020072e:	9a3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00007517          	auipc	a0,0x7
ffffffffc0200738:	84450513          	addi	a0,a0,-1980 # ffffffffc0206f78 <commands+0x600>
ffffffffc020073c:	995ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00007517          	auipc	a0,0x7
ffffffffc0200746:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206f90 <commands+0x618>
ffffffffc020074a:	987ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00007517          	auipc	a0,0x7
ffffffffc0200754:	85850513          	addi	a0,a0,-1960 # ffffffffc0206fa8 <commands+0x630>
ffffffffc0200758:	979ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00007517          	auipc	a0,0x7
ffffffffc0200762:	86250513          	addi	a0,a0,-1950 # ffffffffc0206fc0 <commands+0x648>
ffffffffc0200766:	96bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00007517          	auipc	a0,0x7
ffffffffc0200770:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206fd8 <commands+0x660>
ffffffffc0200774:	95dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00007517          	auipc	a0,0x7
ffffffffc020077e:	87650513          	addi	a0,a0,-1930 # ffffffffc0206ff0 <commands+0x678>
ffffffffc0200782:	94fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00007517          	auipc	a0,0x7
ffffffffc020078c:	88050513          	addi	a0,a0,-1920 # ffffffffc0207008 <commands+0x690>
ffffffffc0200790:	941ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00007517          	auipc	a0,0x7
ffffffffc020079a:	88a50513          	addi	a0,a0,-1910 # ffffffffc0207020 <commands+0x6a8>
ffffffffc020079e:	933ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00007517          	auipc	a0,0x7
ffffffffc02007a8:	89450513          	addi	a0,a0,-1900 # ffffffffc0207038 <commands+0x6c0>
ffffffffc02007ac:	925ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00007517          	auipc	a0,0x7
ffffffffc02007b6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207050 <commands+0x6d8>
ffffffffc02007ba:	917ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00007517          	auipc	a0,0x7
ffffffffc02007c4:	8a850513          	addi	a0,a0,-1880 # ffffffffc0207068 <commands+0x6f0>
ffffffffc02007c8:	909ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00007517          	auipc	a0,0x7
ffffffffc02007d2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0207080 <commands+0x708>
ffffffffc02007d6:	8fbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00007517          	auipc	a0,0x7
ffffffffc02007e0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0207098 <commands+0x720>
ffffffffc02007e4:	8edff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00007517          	auipc	a0,0x7
ffffffffc02007ee:	8c650513          	addi	a0,a0,-1850 # ffffffffc02070b0 <commands+0x738>
ffffffffc02007f2:	8dfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00007517          	auipc	a0,0x7
ffffffffc02007fc:	8d050513          	addi	a0,a0,-1840 # ffffffffc02070c8 <commands+0x750>
ffffffffc0200800:	8d1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00007517          	auipc	a0,0x7
ffffffffc020080a:	8da50513          	addi	a0,a0,-1830 # ffffffffc02070e0 <commands+0x768>
ffffffffc020080e:	8c3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00007517          	auipc	a0,0x7
ffffffffc0200818:	8e450513          	addi	a0,a0,-1820 # ffffffffc02070f8 <commands+0x780>
ffffffffc020081c:	8b5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00007517          	auipc	a0,0x7
ffffffffc0200826:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0207110 <commands+0x798>
ffffffffc020082a:	8a7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00007517          	auipc	a0,0x7
ffffffffc0200838:	8f450513          	addi	a0,a0,-1804 # ffffffffc0207128 <commands+0x7b0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	893ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200842 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200848:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020084a:	00007517          	auipc	a0,0x7
ffffffffc020084e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207140 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	87dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00007517          	auipc	a0,0x7
ffffffffc0200866:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207158 <commands+0x7e0>
ffffffffc020086a:	867ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00007517          	auipc	a0,0x7
ffffffffc0200876:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0207170 <commands+0x7f8>
ffffffffc020087a:	857ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00007517          	auipc	a0,0x7
ffffffffc0200886:	90650513          	addi	a0,a0,-1786 # ffffffffc0207188 <commands+0x810>
ffffffffc020088a:	847ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00007517          	auipc	a0,0x7
ffffffffc020089a:	90250513          	addi	a0,a0,-1790 # ffffffffc0207198 <commands+0x820>
}
ffffffffc020089e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a0:	831ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008a4 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	1101                	addi	sp,sp,-32
ffffffffc02008a6:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a8:	000ac497          	auipc	s1,0xac
ffffffffc02008ac:	fe848493          	addi	s1,s1,-24 # ffffffffc02ac890 <check_mm_struct>
ffffffffc02008b0:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b2:	e822                	sd	s0,16(sp)
ffffffffc02008b4:	ec06                	sd	ra,24(sp)
ffffffffc02008b6:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b8:	cbbd                	beqz	a5,ffffffffc020092e <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	11053583          	ld	a1,272(a0)
ffffffffc02008c2:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c6:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ca:	cba1                	beqz	a5,ffffffffc020091a <pgfault_handler+0x76>
ffffffffc02008cc:	11843703          	ld	a4,280(s0)
ffffffffc02008d0:	47bd                	li	a5,15
ffffffffc02008d2:	05700693          	li	a3,87
ffffffffc02008d6:	00f70463          	beq	a4,a5,ffffffffc02008de <pgfault_handler+0x3a>
ffffffffc02008da:	05200693          	li	a3,82
ffffffffc02008de:	00006517          	auipc	a0,0x6
ffffffffc02008e2:	4e250513          	addi	a0,a0,1250 # ffffffffc0206dc0 <commands+0x448>
ffffffffc02008e6:	feaff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000ac797          	auipc	a5,0xac
ffffffffc02008f2:	f5a78793          	addi	a5,a5,-166 # ffffffffc02ac848 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000ac797          	auipc	a5,0xac
ffffffffc02008fc:	f5878793          	addi	a5,a5,-168 # ffffffffc02ac850 <idleproc>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	04f71763          	bne	a4,a5,ffffffffc0200950 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	11043603          	ld	a2,272(s0)
ffffffffc020090a:	11843583          	ld	a1,280(s0)
}
ffffffffc020090e:	6442                	ld	s0,16(sp)
ffffffffc0200910:	60e2                	ld	ra,24(sp)
ffffffffc0200912:	64a2                	ld	s1,8(sp)
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	3fa0206f          	j	ffffffffc0202d10 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000ac797          	auipc	a5,0xac
ffffffffc0200932:	f1a78793          	addi	a5,a5,-230 # ffffffffc02ac848 <current>
ffffffffc0200936:	639c                	ld	a5,0(a5)
ffffffffc0200938:	cf85                	beqz	a5,ffffffffc0200970 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	11043603          	ld	a2,272(s0)
ffffffffc020093e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200942:	6442                	ld	s0,16(sp)
ffffffffc0200944:	60e2                	ld	ra,24(sp)
ffffffffc0200946:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200948:	7788                	ld	a0,40(a5)
}
ffffffffc020094a:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094c:	3c40206f          	j	ffffffffc0202d10 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00006697          	auipc	a3,0x6
ffffffffc0200954:	49068693          	addi	a3,a3,1168 # ffffffffc0206de0 <commands+0x468>
ffffffffc0200958:	00006617          	auipc	a2,0x6
ffffffffc020095c:	4a060613          	addi	a2,a2,1184 # ffffffffc0206df8 <commands+0x480>
ffffffffc0200960:	06b00593          	li	a1,107
ffffffffc0200964:	00006517          	auipc	a0,0x6
ffffffffc0200968:	4ac50513          	addi	a0,a0,1196 # ffffffffc0206e10 <commands+0x498>
ffffffffc020096c:	8a9ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	ed1ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200976:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020097a:	11043583          	ld	a1,272(s0)
ffffffffc020097e:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200982:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	e399                	bnez	a5,ffffffffc020098c <pgfault_handler+0xe8>
ffffffffc0200988:	05500613          	li	a2,85
ffffffffc020098c:	11843703          	ld	a4,280(s0)
ffffffffc0200990:	47bd                	li	a5,15
ffffffffc0200992:	02f70663          	beq	a4,a5,ffffffffc02009be <pgfault_handler+0x11a>
ffffffffc0200996:	05200693          	li	a3,82
ffffffffc020099a:	00006517          	auipc	a0,0x6
ffffffffc020099e:	42650513          	addi	a0,a0,1062 # ffffffffc0206dc0 <commands+0x448>
ffffffffc02009a2:	f2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00006617          	auipc	a2,0x6
ffffffffc02009aa:	48260613          	addi	a2,a2,1154 # ffffffffc0206e28 <commands+0x4b0>
ffffffffc02009ae:	07200593          	li	a1,114
ffffffffc02009b2:	00006517          	auipc	a0,0x6
ffffffffc02009b6:	45e50513          	addi	a0,a0,1118 # ffffffffc0206e10 <commands+0x498>
ffffffffc02009ba:	85bff0ef          	jal	ra,ffffffffc0200214 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009be:	05700693          	li	a3,87
ffffffffc02009c2:	bfe1                	j	ffffffffc020099a <pgfault_handler+0xf6>

ffffffffc02009c4 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c4:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009c8:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009ca:	0786                	slli	a5,a5,0x1
ffffffffc02009cc:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009ce:	08f76763          	bltu	a4,a5,ffffffffc0200a5c <interrupt_handler+0x98>
ffffffffc02009d2:	00006717          	auipc	a4,0x6
ffffffffc02009d6:	14270713          	addi	a4,a4,322 # ffffffffc0206b14 <commands+0x19c>
ffffffffc02009da:	078a                	slli	a5,a5,0x2
ffffffffc02009dc:	97ba                	add	a5,a5,a4
ffffffffc02009de:	439c                	lw	a5,0(a5)
ffffffffc02009e0:	97ba                	add	a5,a5,a4
ffffffffc02009e2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e4:	00006517          	auipc	a0,0x6
ffffffffc02009e8:	39c50513          	addi	a0,a0,924 # ffffffffc0206d80 <commands+0x408>
ffffffffc02009ec:	ee4ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f0:	00006517          	auipc	a0,0x6
ffffffffc02009f4:	37050513          	addi	a0,a0,880 # ffffffffc0206d60 <commands+0x3e8>
ffffffffc02009f8:	ed8ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fc:	00006517          	auipc	a0,0x6
ffffffffc0200a00:	32450513          	addi	a0,a0,804 # ffffffffc0206d20 <commands+0x3a8>
ffffffffc0200a04:	eccff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a08:	00006517          	auipc	a0,0x6
ffffffffc0200a0c:	33850513          	addi	a0,a0,824 # ffffffffc0206d40 <commands+0x3c8>
ffffffffc0200a10:	ec0ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a14:	00006517          	auipc	a0,0x6
ffffffffc0200a18:	38c50513          	addi	a0,a0,908 # ffffffffc0206da0 <commands+0x428>
ffffffffc0200a1c:	eb4ff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a20:	1141                	addi	sp,sp,-16
ffffffffc0200a22:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a24:	b9bff0ef          	jal	ra,ffffffffc02005be <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a28:	000ac797          	auipc	a5,0xac
ffffffffc0200a2c:	e4078793          	addi	a5,a5,-448 # ffffffffc02ac868 <ticks>
ffffffffc0200a30:	639c                	ld	a5,0(a5)
ffffffffc0200a32:	06400713          	li	a4,100
ffffffffc0200a36:	0785                	addi	a5,a5,1
ffffffffc0200a38:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a3c:	000ac697          	auipc	a3,0xac
ffffffffc0200a40:	e2f6b623          	sd	a5,-468(a3) # ffffffffc02ac868 <ticks>
ffffffffc0200a44:	eb09                	bnez	a4,ffffffffc0200a56 <interrupt_handler+0x92>
ffffffffc0200a46:	000ac797          	auipc	a5,0xac
ffffffffc0200a4a:	e0278793          	addi	a5,a5,-510 # ffffffffc02ac848 <current>
ffffffffc0200a4e:	639c                	ld	a5,0(a5)
ffffffffc0200a50:	c399                	beqz	a5,ffffffffc0200a56 <interrupt_handler+0x92>
                current->need_resched = 1;
ffffffffc0200a52:	4705                	li	a4,1
ffffffffc0200a54:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a56:	60a2                	ld	ra,8(sp)
ffffffffc0200a58:	0141                	addi	sp,sp,16
ffffffffc0200a5a:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a5c:	b3dd                	j	ffffffffc0200842 <print_trapframe>

ffffffffc0200a5e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5e:	11853783          	ld	a5,280(a0)
ffffffffc0200a62:	473d                	li	a4,15
ffffffffc0200a64:	1af76c63          	bltu	a4,a5,ffffffffc0200c1c <exception_handler+0x1be>
ffffffffc0200a68:	00006717          	auipc	a4,0x6
ffffffffc0200a6c:	0dc70713          	addi	a4,a4,220 # ffffffffc0206b44 <commands+0x1cc>
ffffffffc0200a70:	078a                	slli	a5,a5,0x2
ffffffffc0200a72:	97ba                	add	a5,a5,a4
ffffffffc0200a74:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a76:	1101                	addi	sp,sp,-32
ffffffffc0200a78:	e822                	sd	s0,16(sp)
ffffffffc0200a7a:	ec06                	sd	ra,24(sp)
ffffffffc0200a7c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	842a                	mv	s0,a0
ffffffffc0200a82:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	1f450513          	addi	a0,a0,500 # ffffffffc0206c78 <commands+0x300>
ffffffffc0200a8c:	e44ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a90:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a94:	60e2                	ld	ra,24(sp)
ffffffffc0200a96:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a98:	0791                	addi	a5,a5,4
ffffffffc0200a9a:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9e:	6442                	ld	s0,16(sp)
ffffffffc0200aa0:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa2:	0190506f          	j	ffffffffc02062ba <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa6:	00006517          	auipc	a0,0x6
ffffffffc0200aaa:	1f250513          	addi	a0,a0,498 # ffffffffc0206c98 <commands+0x320>
}
ffffffffc0200aae:	6442                	ld	s0,16(sp)
ffffffffc0200ab0:	60e2                	ld	ra,24(sp)
ffffffffc0200ab2:	64a2                	ld	s1,8(sp)
ffffffffc0200ab4:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab6:	e1aff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aba:	00006517          	auipc	a0,0x6
ffffffffc0200abe:	1fe50513          	addi	a0,a0,510 # ffffffffc0206cb8 <commands+0x340>
ffffffffc0200ac2:	b7f5                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac4:	00006517          	auipc	a0,0x6
ffffffffc0200ac8:	21450513          	addi	a0,a0,532 # ffffffffc0206cd8 <commands+0x360>
ffffffffc0200acc:	b7cd                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ace:	00006517          	auipc	a0,0x6
ffffffffc0200ad2:	22250513          	addi	a0,a0,546 # ffffffffc0206cf0 <commands+0x378>
ffffffffc0200ad6:	dfaff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ada:	8522                	mv	a0,s0
ffffffffc0200adc:	dc9ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ae0:	84aa                	mv	s1,a0
ffffffffc0200ae2:	12051e63          	bnez	a0,ffffffffc0200c1e <exception_handler+0x1c0>
}
ffffffffc0200ae6:	60e2                	ld	ra,24(sp)
ffffffffc0200ae8:	6442                	ld	s0,16(sp)
ffffffffc0200aea:	64a2                	ld	s1,8(sp)
ffffffffc0200aec:	6105                	addi	sp,sp,32
ffffffffc0200aee:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200af0:	00006517          	auipc	a0,0x6
ffffffffc0200af4:	21850513          	addi	a0,a0,536 # ffffffffc0206d08 <commands+0x390>
ffffffffc0200af8:	dd8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afc:	8522                	mv	a0,s0
ffffffffc0200afe:	da7ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b02:	84aa                	mv	s1,a0
ffffffffc0200b04:	d16d                	beqz	a0,ffffffffc0200ae6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	d3bff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0c:	86a6                	mv	a3,s1
ffffffffc0200b0e:	00006617          	auipc	a2,0x6
ffffffffc0200b12:	11a60613          	addi	a2,a2,282 # ffffffffc0206c28 <commands+0x2b0>
ffffffffc0200b16:	0f800593          	li	a1,248
ffffffffc0200b1a:	00006517          	auipc	a0,0x6
ffffffffc0200b1e:	2f650513          	addi	a0,a0,758 # ffffffffc0206e10 <commands+0x498>
ffffffffc0200b22:	ef2ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	06250513          	addi	a0,a0,98 # ffffffffc0206b88 <commands+0x210>
ffffffffc0200b2e:	b741                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b30:	00006517          	auipc	a0,0x6
ffffffffc0200b34:	07850513          	addi	a0,a0,120 # ffffffffc0206ba8 <commands+0x230>
ffffffffc0200b38:	bf9d                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b3a:	00006517          	auipc	a0,0x6
ffffffffc0200b3e:	08e50513          	addi	a0,a0,142 # ffffffffc0206bc8 <commands+0x250>
ffffffffc0200b42:	b7b5                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b44:	00006517          	auipc	a0,0x6
ffffffffc0200b48:	09c50513          	addi	a0,a0,156 # ffffffffc0206be0 <commands+0x268>
ffffffffc0200b4c:	d84ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b50:	6458                	ld	a4,136(s0)
ffffffffc0200b52:	47a9                	li	a5,10
ffffffffc0200b54:	f8f719e3          	bne	a4,a5,ffffffffc0200ae6 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b58:	10843783          	ld	a5,264(s0)
ffffffffc0200b5c:	0791                	addi	a5,a5,4
ffffffffc0200b5e:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b62:	758050ef          	jal	ra,ffffffffc02062ba <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b66:	000ac797          	auipc	a5,0xac
ffffffffc0200b6a:	ce278793          	addi	a5,a5,-798 # ffffffffc02ac848 <current>
ffffffffc0200b6e:	639c                	ld	a5,0(a5)
ffffffffc0200b70:	8522                	mv	a0,s0
}
ffffffffc0200b72:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b74:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b76:	60e2                	ld	ra,24(sp)
ffffffffc0200b78:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7a:	6589                	lui	a1,0x2
ffffffffc0200b7c:	95be                	add	a1,a1,a5
}
ffffffffc0200b7e:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	ac19                	j	ffffffffc0200d96 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	06e50513          	addi	a0,a0,110 # ffffffffc0206bf0 <commands+0x278>
ffffffffc0200b8a:	b715                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8c:	00006517          	auipc	a0,0x6
ffffffffc0200b90:	08450513          	addi	a0,a0,132 # ffffffffc0206c10 <commands+0x298>
ffffffffc0200b94:	d3cff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	d0bff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b9e:	84aa                	mv	s1,a0
ffffffffc0200ba0:	d139                	beqz	a0,ffffffffc0200ae6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba2:	8522                	mv	a0,s0
ffffffffc0200ba4:	c9fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba8:	86a6                	mv	a3,s1
ffffffffc0200baa:	00006617          	auipc	a2,0x6
ffffffffc0200bae:	07e60613          	addi	a2,a2,126 # ffffffffc0206c28 <commands+0x2b0>
ffffffffc0200bb2:	0cd00593          	li	a1,205
ffffffffc0200bb6:	00006517          	auipc	a0,0x6
ffffffffc0200bba:	25a50513          	addi	a0,a0,602 # ffffffffc0206e10 <commands+0x498>
ffffffffc0200bbe:	e56ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc2:	00006517          	auipc	a0,0x6
ffffffffc0200bc6:	09e50513          	addi	a0,a0,158 # ffffffffc0206c60 <commands+0x2e8>
ffffffffc0200bca:	d06ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	cd5ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bd4:	84aa                	mv	s1,a0
ffffffffc0200bd6:	f00508e3          	beqz	a0,ffffffffc0200ae6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	c67ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be0:	86a6                	mv	a3,s1
ffffffffc0200be2:	00006617          	auipc	a2,0x6
ffffffffc0200be6:	04660613          	addi	a2,a2,70 # ffffffffc0206c28 <commands+0x2b0>
ffffffffc0200bea:	0d700593          	li	a1,215
ffffffffc0200bee:	00006517          	auipc	a0,0x6
ffffffffc0200bf2:	22250513          	addi	a0,a0,546 # ffffffffc0206e10 <commands+0x498>
ffffffffc0200bf6:	e1eff0ef          	jal	ra,ffffffffc0200214 <__panic>
}
ffffffffc0200bfa:	6442                	ld	s0,16(sp)
ffffffffc0200bfc:	60e2                	ld	ra,24(sp)
ffffffffc0200bfe:	64a2                	ld	s1,8(sp)
ffffffffc0200c00:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c02:	b181                	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c04:	00006617          	auipc	a2,0x6
ffffffffc0200c08:	04460613          	addi	a2,a2,68 # ffffffffc0206c48 <commands+0x2d0>
ffffffffc0200c0c:	0d100593          	li	a1,209
ffffffffc0200c10:	00006517          	auipc	a0,0x6
ffffffffc0200c14:	20050513          	addi	a0,a0,512 # ffffffffc0206e10 <commands+0x498>
ffffffffc0200c18:	dfcff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc0200c1c:	b11d                	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c1e:	8522                	mv	a0,s0
ffffffffc0200c20:	c23ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c24:	86a6                	mv	a3,s1
ffffffffc0200c26:	00006617          	auipc	a2,0x6
ffffffffc0200c2a:	00260613          	addi	a2,a2,2 # ffffffffc0206c28 <commands+0x2b0>
ffffffffc0200c2e:	0f100593          	li	a1,241
ffffffffc0200c32:	00006517          	auipc	a0,0x6
ffffffffc0200c36:	1de50513          	addi	a0,a0,478 # ffffffffc0206e10 <commands+0x498>
ffffffffc0200c3a:	ddaff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0200c3e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c3e:	1101                	addi	sp,sp,-32
ffffffffc0200c40:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c42:	000ac417          	auipc	s0,0xac
ffffffffc0200c46:	c0640413          	addi	s0,s0,-1018 # ffffffffc02ac848 <current>
ffffffffc0200c4a:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c4c:	ec06                	sd	ra,24(sp)
ffffffffc0200c4e:	e426                	sd	s1,8(sp)
ffffffffc0200c50:	e04a                	sd	s2,0(sp)
ffffffffc0200c52:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c56:	cf1d                	beqz	a4,ffffffffc0200c94 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c58:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c5c:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c60:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c62:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c66:	0206c463          	bltz	a3,ffffffffc0200c8e <trap+0x50>
        exception_handler(tf);
ffffffffc0200c6a:	df5ff0ef          	jal	ra,ffffffffc0200a5e <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c6e:	601c                	ld	a5,0(s0)
ffffffffc0200c70:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c74:	e499                	bnez	s1,ffffffffc0200c82 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c76:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c7a:	8b05                	andi	a4,a4,1
ffffffffc0200c7c:	e329                	bnez	a4,ffffffffc0200cbe <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c7e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c80:	eb85                	bnez	a5,ffffffffc0200cb0 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c82:	60e2                	ld	ra,24(sp)
ffffffffc0200c84:	6442                	ld	s0,16(sp)
ffffffffc0200c86:	64a2                	ld	s1,8(sp)
ffffffffc0200c88:	6902                	ld	s2,0(sp)
ffffffffc0200c8a:	6105                	addi	sp,sp,32
ffffffffc0200c8c:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c8e:	d37ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200c92:	bff1                	j	ffffffffc0200c6e <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c94:	0006c863          	bltz	a3,ffffffffc0200ca4 <trap+0x66>
}
ffffffffc0200c98:	6442                	ld	s0,16(sp)
ffffffffc0200c9a:	60e2                	ld	ra,24(sp)
ffffffffc0200c9c:	64a2                	ld	s1,8(sp)
ffffffffc0200c9e:	6902                	ld	s2,0(sp)
ffffffffc0200ca0:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca2:	bb75                	j	ffffffffc0200a5e <exception_handler>
}
ffffffffc0200ca4:	6442                	ld	s0,16(sp)
ffffffffc0200ca6:	60e2                	ld	ra,24(sp)
ffffffffc0200ca8:	64a2                	ld	s1,8(sp)
ffffffffc0200caa:	6902                	ld	s2,0(sp)
ffffffffc0200cac:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cae:	bb19                	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200cb0:	6442                	ld	s0,16(sp)
ffffffffc0200cb2:	60e2                	ld	ra,24(sp)
ffffffffc0200cb4:	64a2                	ld	s1,8(sp)
ffffffffc0200cb6:	6902                	ld	s2,0(sp)
ffffffffc0200cb8:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cba:	50a0506f          	j	ffffffffc02061c4 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cbe:	555d                	li	a0,-9
ffffffffc0200cc0:	171040ef          	jal	ra,ffffffffc0205630 <do_exit>
ffffffffc0200cc4:	601c                	ld	a5,0(s0)
ffffffffc0200cc6:	bf65                	j	ffffffffc0200c7e <trap+0x40>

ffffffffc0200cc8 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cc8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ccc:	00011463          	bnez	sp,ffffffffc0200cd4 <__alltraps+0xc>
ffffffffc0200cd0:	14002173          	csrr	sp,sscratch
ffffffffc0200cd4:	712d                	addi	sp,sp,-288
ffffffffc0200cd6:	e002                	sd	zero,0(sp)
ffffffffc0200cd8:	e406                	sd	ra,8(sp)
ffffffffc0200cda:	ec0e                	sd	gp,24(sp)
ffffffffc0200cdc:	f012                	sd	tp,32(sp)
ffffffffc0200cde:	f416                	sd	t0,40(sp)
ffffffffc0200ce0:	f81a                	sd	t1,48(sp)
ffffffffc0200ce2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ce4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ce6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ce8:	e8aa                	sd	a0,80(sp)
ffffffffc0200cea:	ecae                	sd	a1,88(sp)
ffffffffc0200cec:	f0b2                	sd	a2,96(sp)
ffffffffc0200cee:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cf2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cf4:	e142                	sd	a6,128(sp)
ffffffffc0200cf6:	e546                	sd	a7,136(sp)
ffffffffc0200cf8:	e94a                	sd	s2,144(sp)
ffffffffc0200cfa:	ed4e                	sd	s3,152(sp)
ffffffffc0200cfc:	f152                	sd	s4,160(sp)
ffffffffc0200cfe:	f556                	sd	s5,168(sp)
ffffffffc0200d00:	f95a                	sd	s6,176(sp)
ffffffffc0200d02:	fd5e                	sd	s7,184(sp)
ffffffffc0200d04:	e1e2                	sd	s8,192(sp)
ffffffffc0200d06:	e5e6                	sd	s9,200(sp)
ffffffffc0200d08:	e9ea                	sd	s10,208(sp)
ffffffffc0200d0a:	edee                	sd	s11,216(sp)
ffffffffc0200d0c:	f1f2                	sd	t3,224(sp)
ffffffffc0200d0e:	f5f6                	sd	t4,232(sp)
ffffffffc0200d10:	f9fa                	sd	t5,240(sp)
ffffffffc0200d12:	fdfe                	sd	t6,248(sp)
ffffffffc0200d14:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d18:	100024f3          	csrr	s1,sstatus
ffffffffc0200d1c:	14102973          	csrr	s2,sepc
ffffffffc0200d20:	143029f3          	csrr	s3,stval
ffffffffc0200d24:	14202a73          	csrr	s4,scause
ffffffffc0200d28:	e822                	sd	s0,16(sp)
ffffffffc0200d2a:	e226                	sd	s1,256(sp)
ffffffffc0200d2c:	e64a                	sd	s2,264(sp)
ffffffffc0200d2e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d30:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d32:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d34:	f0bff0ef          	jal	ra,ffffffffc0200c3e <trap>

ffffffffc0200d38 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d38:	6492                	ld	s1,256(sp)
ffffffffc0200d3a:	6932                	ld	s2,264(sp)
ffffffffc0200d3c:	1004f413          	andi	s0,s1,256
ffffffffc0200d40:	e401                	bnez	s0,ffffffffc0200d48 <__trapret+0x10>
ffffffffc0200d42:	1200                	addi	s0,sp,288
ffffffffc0200d44:	14041073          	csrw	sscratch,s0
ffffffffc0200d48:	10049073          	csrw	sstatus,s1
ffffffffc0200d4c:	14191073          	csrw	sepc,s2
ffffffffc0200d50:	60a2                	ld	ra,8(sp)
ffffffffc0200d52:	61e2                	ld	gp,24(sp)
ffffffffc0200d54:	7202                	ld	tp,32(sp)
ffffffffc0200d56:	72a2                	ld	t0,40(sp)
ffffffffc0200d58:	7342                	ld	t1,48(sp)
ffffffffc0200d5a:	73e2                	ld	t2,56(sp)
ffffffffc0200d5c:	6406                	ld	s0,64(sp)
ffffffffc0200d5e:	64a6                	ld	s1,72(sp)
ffffffffc0200d60:	6546                	ld	a0,80(sp)
ffffffffc0200d62:	65e6                	ld	a1,88(sp)
ffffffffc0200d64:	7606                	ld	a2,96(sp)
ffffffffc0200d66:	76a6                	ld	a3,104(sp)
ffffffffc0200d68:	7746                	ld	a4,112(sp)
ffffffffc0200d6a:	77e6                	ld	a5,120(sp)
ffffffffc0200d6c:	680a                	ld	a6,128(sp)
ffffffffc0200d6e:	68aa                	ld	a7,136(sp)
ffffffffc0200d70:	694a                	ld	s2,144(sp)
ffffffffc0200d72:	69ea                	ld	s3,152(sp)
ffffffffc0200d74:	7a0a                	ld	s4,160(sp)
ffffffffc0200d76:	7aaa                	ld	s5,168(sp)
ffffffffc0200d78:	7b4a                	ld	s6,176(sp)
ffffffffc0200d7a:	7bea                	ld	s7,184(sp)
ffffffffc0200d7c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d7e:	6cae                	ld	s9,200(sp)
ffffffffc0200d80:	6d4e                	ld	s10,208(sp)
ffffffffc0200d82:	6dee                	ld	s11,216(sp)
ffffffffc0200d84:	7e0e                	ld	t3,224(sp)
ffffffffc0200d86:	7eae                	ld	t4,232(sp)
ffffffffc0200d88:	7f4e                	ld	t5,240(sp)
ffffffffc0200d8a:	7fee                	ld	t6,248(sp)
ffffffffc0200d8c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d8e:	10200073          	sret

ffffffffc0200d92 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d92:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d94:	b755                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200d96 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d96:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d9a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d9e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200da2:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200da6:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200daa:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dae:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200db2:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200db6:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dba:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dbc:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dbe:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc0:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dc2:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dc4:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dc6:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dc8:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dca:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dcc:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dce:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd0:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dd2:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dd4:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dd6:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dd8:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dda:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200ddc:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dde:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200de2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200de4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200de6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200de8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dea:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dec:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dee:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200df2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200df4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200df6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200df8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dfa:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dfc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dfe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e00:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e02:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e04:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e06:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e08:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e0a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e0c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e0e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e10:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e12:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e14:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e16:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e18:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e1a:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e1c:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e1e:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e20:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e22:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e24:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e26:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e28:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e2a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e2c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e2e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e30:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e32:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e34:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e36:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e38:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e3a:	812e                	mv	sp,a1
ffffffffc0200e3c:	bdf5                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200e3e <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e3e:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e40:	00006617          	auipc	a2,0x6
ffffffffc0200e44:	41860613          	addi	a2,a2,1048 # ffffffffc0207258 <commands+0x8e0>
ffffffffc0200e48:	06200593          	li	a1,98
ffffffffc0200e4c:	00006517          	auipc	a0,0x6
ffffffffc0200e50:	42c50513          	addi	a0,a0,1068 # ffffffffc0207278 <commands+0x900>
pa2page(uintptr_t pa) {
ffffffffc0200e54:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e56:	bbeff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0200e5a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e5a:	715d                	addi	sp,sp,-80
ffffffffc0200e5c:	e0a2                	sd	s0,64(sp)
ffffffffc0200e5e:	fc26                	sd	s1,56(sp)
ffffffffc0200e60:	f84a                	sd	s2,48(sp)
ffffffffc0200e62:	f44e                	sd	s3,40(sp)
ffffffffc0200e64:	f052                	sd	s4,32(sp)
ffffffffc0200e66:	ec56                	sd	s5,24(sp)
ffffffffc0200e68:	e486                	sd	ra,72(sp)
ffffffffc0200e6a:	842a                	mv	s0,a0
ffffffffc0200e6c:	000ac497          	auipc	s1,0xac
ffffffffc0200e70:	a0448493          	addi	s1,s1,-1532 # ffffffffc02ac870 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e74:	4985                	li	s3,1
ffffffffc0200e76:	000aca17          	auipc	s4,0xac
ffffffffc0200e7a:	9caa0a13          	addi	s4,s4,-1590 # ffffffffc02ac840 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e7e:	0005091b          	sext.w	s2,a0
ffffffffc0200e82:	000aca97          	auipc	s5,0xac
ffffffffc0200e86:	a0ea8a93          	addi	s5,s5,-1522 # ffffffffc02ac890 <check_mm_struct>
ffffffffc0200e8a:	a00d                	j	ffffffffc0200eac <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e8c:	609c                	ld	a5,0(s1)
ffffffffc0200e8e:	6f9c                	ld	a5,24(a5)
ffffffffc0200e90:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e92:	4601                	li	a2,0
ffffffffc0200e94:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e96:	ed0d                	bnez	a0,ffffffffc0200ed0 <alloc_pages+0x76>
ffffffffc0200e98:	0289ec63          	bltu	s3,s0,ffffffffc0200ed0 <alloc_pages+0x76>
ffffffffc0200e9c:	000a2783          	lw	a5,0(s4)
ffffffffc0200ea0:	2781                	sext.w	a5,a5
ffffffffc0200ea2:	c79d                	beqz	a5,ffffffffc0200ed0 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ea4:	000ab503          	ld	a0,0(s5)
ffffffffc0200ea8:	5bd020ef          	jal	ra,ffffffffc0203c64 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eac:	100027f3          	csrr	a5,sstatus
ffffffffc0200eb0:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200eb2:	8522                	mv	a0,s0
ffffffffc0200eb4:	dfe1                	beqz	a5,ffffffffc0200e8c <alloc_pages+0x32>
        intr_disable();
ffffffffc0200eb6:	f9eff0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc0200eba:	609c                	ld	a5,0(s1)
ffffffffc0200ebc:	8522                	mv	a0,s0
ffffffffc0200ebe:	6f9c                	ld	a5,24(a5)
ffffffffc0200ec0:	9782                	jalr	a5
ffffffffc0200ec2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200ec4:	f8aff0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0200ec8:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eca:	4601                	li	a2,0
ffffffffc0200ecc:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ece:	d569                	beqz	a0,ffffffffc0200e98 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ed0:	60a6                	ld	ra,72(sp)
ffffffffc0200ed2:	6406                	ld	s0,64(sp)
ffffffffc0200ed4:	74e2                	ld	s1,56(sp)
ffffffffc0200ed6:	7942                	ld	s2,48(sp)
ffffffffc0200ed8:	79a2                	ld	s3,40(sp)
ffffffffc0200eda:	7a02                	ld	s4,32(sp)
ffffffffc0200edc:	6ae2                	ld	s5,24(sp)
ffffffffc0200ede:	6161                	addi	sp,sp,80
ffffffffc0200ee0:	8082                	ret

ffffffffc0200ee2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ee2:	100027f3          	csrr	a5,sstatus
ffffffffc0200ee6:	8b89                	andi	a5,a5,2
ffffffffc0200ee8:	eb89                	bnez	a5,ffffffffc0200efa <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200eea:	000ac797          	auipc	a5,0xac
ffffffffc0200eee:	98678793          	addi	a5,a5,-1658 # ffffffffc02ac870 <pmm_manager>
ffffffffc0200ef2:	639c                	ld	a5,0(a5)
ffffffffc0200ef4:	0207b303          	ld	t1,32(a5)
ffffffffc0200ef8:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200efa:	1101                	addi	sp,sp,-32
ffffffffc0200efc:	ec06                	sd	ra,24(sp)
ffffffffc0200efe:	e822                	sd	s0,16(sp)
ffffffffc0200f00:	e426                	sd	s1,8(sp)
ffffffffc0200f02:	842a                	mv	s0,a0
ffffffffc0200f04:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f06:	f4eff0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f0a:	000ac797          	auipc	a5,0xac
ffffffffc0200f0e:	96678793          	addi	a5,a5,-1690 # ffffffffc02ac870 <pmm_manager>
ffffffffc0200f12:	639c                	ld	a5,0(a5)
ffffffffc0200f14:	85a6                	mv	a1,s1
ffffffffc0200f16:	8522                	mv	a0,s0
ffffffffc0200f18:	739c                	ld	a5,32(a5)
ffffffffc0200f1a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f1c:	6442                	ld	s0,16(sp)
ffffffffc0200f1e:	60e2                	ld	ra,24(sp)
ffffffffc0200f20:	64a2                	ld	s1,8(sp)
ffffffffc0200f22:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f24:	f2aff06f          	j	ffffffffc020064e <intr_enable>

ffffffffc0200f28 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f28:	100027f3          	csrr	a5,sstatus
ffffffffc0200f2c:	8b89                	andi	a5,a5,2
ffffffffc0200f2e:	eb89                	bnez	a5,ffffffffc0200f40 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f30:	000ac797          	auipc	a5,0xac
ffffffffc0200f34:	94078793          	addi	a5,a5,-1728 # ffffffffc02ac870 <pmm_manager>
ffffffffc0200f38:	639c                	ld	a5,0(a5)
ffffffffc0200f3a:	0287b303          	ld	t1,40(a5)
ffffffffc0200f3e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200f40:	1141                	addi	sp,sp,-16
ffffffffc0200f42:	e406                	sd	ra,8(sp)
ffffffffc0200f44:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f46:	f0eff0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f4a:	000ac797          	auipc	a5,0xac
ffffffffc0200f4e:	92678793          	addi	a5,a5,-1754 # ffffffffc02ac870 <pmm_manager>
ffffffffc0200f52:	639c                	ld	a5,0(a5)
ffffffffc0200f54:	779c                	ld	a5,40(a5)
ffffffffc0200f56:	9782                	jalr	a5
ffffffffc0200f58:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f5a:	ef4ff0ef          	jal	ra,ffffffffc020064e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f5e:	8522                	mv	a0,s0
ffffffffc0200f60:	60a2                	ld	ra,8(sp)
ffffffffc0200f62:	6402                	ld	s0,0(sp)
ffffffffc0200f64:	0141                	addi	sp,sp,16
ffffffffc0200f66:	8082                	ret

ffffffffc0200f68 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f68:	7139                	addi	sp,sp,-64
ffffffffc0200f6a:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f6c:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200f70:	1ff4f493          	andi	s1,s1,511
ffffffffc0200f74:	048e                	slli	s1,s1,0x3
ffffffffc0200f76:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f78:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f7a:	f04a                	sd	s2,32(sp)
ffffffffc0200f7c:	ec4e                	sd	s3,24(sp)
ffffffffc0200f7e:	e852                	sd	s4,16(sp)
ffffffffc0200f80:	fc06                	sd	ra,56(sp)
ffffffffc0200f82:	f822                	sd	s0,48(sp)
ffffffffc0200f84:	e456                	sd	s5,8(sp)
ffffffffc0200f86:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f88:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f8c:	892e                	mv	s2,a1
ffffffffc0200f8e:	8a32                	mv	s4,a2
ffffffffc0200f90:	000ac997          	auipc	s3,0xac
ffffffffc0200f94:	89098993          	addi	s3,s3,-1904 # ffffffffc02ac820 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f98:	e7bd                	bnez	a5,ffffffffc0201006 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f9a:	12060c63          	beqz	a2,ffffffffc02010d2 <get_pte+0x16a>
ffffffffc0200f9e:	4505                	li	a0,1
ffffffffc0200fa0:	ebbff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0200fa4:	842a                	mv	s0,a0
ffffffffc0200fa6:	12050663          	beqz	a0,ffffffffc02010d2 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200faa:	000acb17          	auipc	s6,0xac
ffffffffc0200fae:	8deb0b13          	addi	s6,s6,-1826 # ffffffffc02ac888 <pages>
ffffffffc0200fb2:	000b3503          	ld	a0,0(s6)
ffffffffc0200fb6:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fba:	000ac997          	auipc	s3,0xac
ffffffffc0200fbe:	86698993          	addi	s3,s3,-1946 # ffffffffc02ac820 <npage>
ffffffffc0200fc2:	40a40533          	sub	a0,s0,a0
ffffffffc0200fc6:	8519                	srai	a0,a0,0x6
ffffffffc0200fc8:	9556                	add	a0,a0,s5
ffffffffc0200fca:	0009b703          	ld	a4,0(s3)
ffffffffc0200fce:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fd2:	4685                	li	a3,1
ffffffffc0200fd4:	c014                	sw	a3,0(s0)
ffffffffc0200fd6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fd8:	0532                	slli	a0,a0,0xc
ffffffffc0200fda:	14e7f363          	bgeu	a5,a4,ffffffffc0201120 <get_pte+0x1b8>
ffffffffc0200fde:	000ac797          	auipc	a5,0xac
ffffffffc0200fe2:	89a78793          	addi	a5,a5,-1894 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0200fe6:	639c                	ld	a5,0(a5)
ffffffffc0200fe8:	6605                	lui	a2,0x1
ffffffffc0200fea:	4581                	li	a1,0
ffffffffc0200fec:	953e                	add	a0,a0,a5
ffffffffc0200fee:	3ea050ef          	jal	ra,ffffffffc02063d8 <memset>
    return page - pages + nbase;
ffffffffc0200ff2:	000b3683          	ld	a3,0(s6)
ffffffffc0200ff6:	40d406b3          	sub	a3,s0,a3
ffffffffc0200ffa:	8699                	srai	a3,a3,0x6
ffffffffc0200ffc:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ffe:	06aa                	slli	a3,a3,0xa
ffffffffc0201000:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201004:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201006:	77fd                	lui	a5,0xfffff
ffffffffc0201008:	068a                	slli	a3,a3,0x2
ffffffffc020100a:	0009b703          	ld	a4,0(s3)
ffffffffc020100e:	8efd                	and	a3,a3,a5
ffffffffc0201010:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201014:	0ce7f163          	bgeu	a5,a4,ffffffffc02010d6 <get_pte+0x16e>
ffffffffc0201018:	000aca97          	auipc	s5,0xac
ffffffffc020101c:	860a8a93          	addi	s5,s5,-1952 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0201020:	000ab403          	ld	s0,0(s5)
ffffffffc0201024:	01595793          	srli	a5,s2,0x15
ffffffffc0201028:	1ff7f793          	andi	a5,a5,511
ffffffffc020102c:	96a2                	add	a3,a3,s0
ffffffffc020102e:	00379413          	slli	s0,a5,0x3
ffffffffc0201032:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201034:	6014                	ld	a3,0(s0)
ffffffffc0201036:	0016f793          	andi	a5,a3,1
ffffffffc020103a:	e3ad                	bnez	a5,ffffffffc020109c <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020103c:	080a0b63          	beqz	s4,ffffffffc02010d2 <get_pte+0x16a>
ffffffffc0201040:	4505                	li	a0,1
ffffffffc0201042:	e19ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201046:	84aa                	mv	s1,a0
ffffffffc0201048:	c549                	beqz	a0,ffffffffc02010d2 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020104a:	000acb17          	auipc	s6,0xac
ffffffffc020104e:	83eb0b13          	addi	s6,s6,-1986 # ffffffffc02ac888 <pages>
ffffffffc0201052:	000b3503          	ld	a0,0(s6)
ffffffffc0201056:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020105a:	0009b703          	ld	a4,0(s3)
ffffffffc020105e:	40a48533          	sub	a0,s1,a0
ffffffffc0201062:	8519                	srai	a0,a0,0x6
ffffffffc0201064:	9552                	add	a0,a0,s4
ffffffffc0201066:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020106a:	4685                	li	a3,1
ffffffffc020106c:	c094                	sw	a3,0(s1)
ffffffffc020106e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201070:	0532                	slli	a0,a0,0xc
ffffffffc0201072:	08e7fa63          	bgeu	a5,a4,ffffffffc0201106 <get_pte+0x19e>
ffffffffc0201076:	000ab783          	ld	a5,0(s5)
ffffffffc020107a:	6605                	lui	a2,0x1
ffffffffc020107c:	4581                	li	a1,0
ffffffffc020107e:	953e                	add	a0,a0,a5
ffffffffc0201080:	358050ef          	jal	ra,ffffffffc02063d8 <memset>
    return page - pages + nbase;
ffffffffc0201084:	000b3683          	ld	a3,0(s6)
ffffffffc0201088:	40d486b3          	sub	a3,s1,a3
ffffffffc020108c:	8699                	srai	a3,a3,0x6
ffffffffc020108e:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201090:	06aa                	slli	a3,a3,0xa
ffffffffc0201092:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201096:	e014                	sd	a3,0(s0)
ffffffffc0201098:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020109c:	068a                	slli	a3,a3,0x2
ffffffffc020109e:	757d                	lui	a0,0xfffff
ffffffffc02010a0:	8ee9                	and	a3,a3,a0
ffffffffc02010a2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010a6:	04e7f463          	bgeu	a5,a4,ffffffffc02010ee <get_pte+0x186>
ffffffffc02010aa:	000ab503          	ld	a0,0(s5)
ffffffffc02010ae:	00c95913          	srli	s2,s2,0xc
ffffffffc02010b2:	1ff97913          	andi	s2,s2,511
ffffffffc02010b6:	96aa                	add	a3,a3,a0
ffffffffc02010b8:	00391513          	slli	a0,s2,0x3
ffffffffc02010bc:	9536                	add	a0,a0,a3
}
ffffffffc02010be:	70e2                	ld	ra,56(sp)
ffffffffc02010c0:	7442                	ld	s0,48(sp)
ffffffffc02010c2:	74a2                	ld	s1,40(sp)
ffffffffc02010c4:	7902                	ld	s2,32(sp)
ffffffffc02010c6:	69e2                	ld	s3,24(sp)
ffffffffc02010c8:	6a42                	ld	s4,16(sp)
ffffffffc02010ca:	6aa2                	ld	s5,8(sp)
ffffffffc02010cc:	6b02                	ld	s6,0(sp)
ffffffffc02010ce:	6121                	addi	sp,sp,64
ffffffffc02010d0:	8082                	ret
            return NULL;
ffffffffc02010d2:	4501                	li	a0,0
ffffffffc02010d4:	b7ed                	j	ffffffffc02010be <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010d6:	00006617          	auipc	a2,0x6
ffffffffc02010da:	14a60613          	addi	a2,a2,330 # ffffffffc0207220 <commands+0x8a8>
ffffffffc02010de:	0e300593          	li	a1,227
ffffffffc02010e2:	00006517          	auipc	a0,0x6
ffffffffc02010e6:	16650513          	addi	a0,a0,358 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02010ea:	92aff0ef          	jal	ra,ffffffffc0200214 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ee:	00006617          	auipc	a2,0x6
ffffffffc02010f2:	13260613          	addi	a2,a2,306 # ffffffffc0207220 <commands+0x8a8>
ffffffffc02010f6:	0ee00593          	li	a1,238
ffffffffc02010fa:	00006517          	auipc	a0,0x6
ffffffffc02010fe:	14e50513          	addi	a0,a0,334 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201102:	912ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201106:	86aa                	mv	a3,a0
ffffffffc0201108:	00006617          	auipc	a2,0x6
ffffffffc020110c:	11860613          	addi	a2,a2,280 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0201110:	0eb00593          	li	a1,235
ffffffffc0201114:	00006517          	auipc	a0,0x6
ffffffffc0201118:	13450513          	addi	a0,a0,308 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020111c:	8f8ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201120:	86aa                	mv	a3,a0
ffffffffc0201122:	00006617          	auipc	a2,0x6
ffffffffc0201126:	0fe60613          	addi	a2,a2,254 # ffffffffc0207220 <commands+0x8a8>
ffffffffc020112a:	0df00593          	li	a1,223
ffffffffc020112e:	00006517          	auipc	a0,0x6
ffffffffc0201132:	11a50513          	addi	a0,a0,282 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201136:	8deff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020113a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020113a:	1141                	addi	sp,sp,-16
ffffffffc020113c:	e022                	sd	s0,0(sp)
ffffffffc020113e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201140:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201142:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201144:	e25ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201148:	c011                	beqz	s0,ffffffffc020114c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020114a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020114c:	c511                	beqz	a0,ffffffffc0201158 <get_page+0x1e>
ffffffffc020114e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201150:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201152:	0017f713          	andi	a4,a5,1
ffffffffc0201156:	e709                	bnez	a4,ffffffffc0201160 <get_page+0x26>
}
ffffffffc0201158:	60a2                	ld	ra,8(sp)
ffffffffc020115a:	6402                	ld	s0,0(sp)
ffffffffc020115c:	0141                	addi	sp,sp,16
ffffffffc020115e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201160:	000ab717          	auipc	a4,0xab
ffffffffc0201164:	6c070713          	addi	a4,a4,1728 # ffffffffc02ac820 <npage>
ffffffffc0201168:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020116a:	078a                	slli	a5,a5,0x2
ffffffffc020116c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020116e:	02e7f063          	bgeu	a5,a4,ffffffffc020118e <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0201172:	000ab717          	auipc	a4,0xab
ffffffffc0201176:	71670713          	addi	a4,a4,1814 # ffffffffc02ac888 <pages>
ffffffffc020117a:	6308                	ld	a0,0(a4)
ffffffffc020117c:	60a2                	ld	ra,8(sp)
ffffffffc020117e:	6402                	ld	s0,0(sp)
ffffffffc0201180:	fff80737          	lui	a4,0xfff80
ffffffffc0201184:	97ba                	add	a5,a5,a4
ffffffffc0201186:	079a                	slli	a5,a5,0x6
ffffffffc0201188:	953e                	add	a0,a0,a5
ffffffffc020118a:	0141                	addi	sp,sp,16
ffffffffc020118c:	8082                	ret
ffffffffc020118e:	cb1ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc0201192 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201192:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201194:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201198:	ec86                	sd	ra,88(sp)
ffffffffc020119a:	e8a2                	sd	s0,80(sp)
ffffffffc020119c:	e4a6                	sd	s1,72(sp)
ffffffffc020119e:	e0ca                	sd	s2,64(sp)
ffffffffc02011a0:	fc4e                	sd	s3,56(sp)
ffffffffc02011a2:	f852                	sd	s4,48(sp)
ffffffffc02011a4:	f456                	sd	s5,40(sp)
ffffffffc02011a6:	f05a                	sd	s6,32(sp)
ffffffffc02011a8:	ec5e                	sd	s7,24(sp)
ffffffffc02011aa:	e862                	sd	s8,16(sp)
ffffffffc02011ac:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011ae:	03479713          	slli	a4,a5,0x34
ffffffffc02011b2:	eb71                	bnez	a4,ffffffffc0201286 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02011b4:	002007b7          	lui	a5,0x200
ffffffffc02011b8:	842e                	mv	s0,a1
ffffffffc02011ba:	0af5e663          	bltu	a1,a5,ffffffffc0201266 <unmap_range+0xd4>
ffffffffc02011be:	8932                	mv	s2,a2
ffffffffc02011c0:	0ac5f363          	bgeu	a1,a2,ffffffffc0201266 <unmap_range+0xd4>
ffffffffc02011c4:	4785                	li	a5,1
ffffffffc02011c6:	07fe                	slli	a5,a5,0x1f
ffffffffc02011c8:	08c7ef63          	bltu	a5,a2,ffffffffc0201266 <unmap_range+0xd4>
ffffffffc02011cc:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011ce:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011d0:	000abc97          	auipc	s9,0xab
ffffffffc02011d4:	650c8c93          	addi	s9,s9,1616 # ffffffffc02ac820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011d8:	000abc17          	auipc	s8,0xab
ffffffffc02011dc:	6b0c0c13          	addi	s8,s8,1712 # ffffffffc02ac888 <pages>
ffffffffc02011e0:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011e4:	00200b37          	lui	s6,0x200
ffffffffc02011e8:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011ec:	4601                	li	a2,0
ffffffffc02011ee:	85a2                	mv	a1,s0
ffffffffc02011f0:	854e                	mv	a0,s3
ffffffffc02011f2:	d77ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02011f6:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011f8:	cd21                	beqz	a0,ffffffffc0201250 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02011fa:	611c                	ld	a5,0(a0)
ffffffffc02011fc:	e38d                	bnez	a5,ffffffffc020121e <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02011fe:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201200:	ff2466e3          	bltu	s0,s2,ffffffffc02011ec <unmap_range+0x5a>
}
ffffffffc0201204:	60e6                	ld	ra,88(sp)
ffffffffc0201206:	6446                	ld	s0,80(sp)
ffffffffc0201208:	64a6                	ld	s1,72(sp)
ffffffffc020120a:	6906                	ld	s2,64(sp)
ffffffffc020120c:	79e2                	ld	s3,56(sp)
ffffffffc020120e:	7a42                	ld	s4,48(sp)
ffffffffc0201210:	7aa2                	ld	s5,40(sp)
ffffffffc0201212:	7b02                	ld	s6,32(sp)
ffffffffc0201214:	6be2                	ld	s7,24(sp)
ffffffffc0201216:	6c42                	ld	s8,16(sp)
ffffffffc0201218:	6ca2                	ld	s9,8(sp)
ffffffffc020121a:	6125                	addi	sp,sp,96
ffffffffc020121c:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020121e:	0017f713          	andi	a4,a5,1
ffffffffc0201222:	df71                	beqz	a4,ffffffffc02011fe <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0201224:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201228:	078a                	slli	a5,a5,0x2
ffffffffc020122a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020122c:	06e7fd63          	bgeu	a5,a4,ffffffffc02012a6 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0201230:	000c3503          	ld	a0,0(s8)
ffffffffc0201234:	97de                	add	a5,a5,s7
ffffffffc0201236:	079a                	slli	a5,a5,0x6
ffffffffc0201238:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020123a:	411c                	lw	a5,0(a0)
ffffffffc020123c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201240:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201242:	cf11                	beqz	a4,ffffffffc020125e <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201244:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201248:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020124c:	9452                	add	s0,s0,s4
ffffffffc020124e:	bf4d                	j	ffffffffc0201200 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201250:	945a                	add	s0,s0,s6
ffffffffc0201252:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201256:	d45d                	beqz	s0,ffffffffc0201204 <unmap_range+0x72>
ffffffffc0201258:	f9246ae3          	bltu	s0,s2,ffffffffc02011ec <unmap_range+0x5a>
ffffffffc020125c:	b765                	j	ffffffffc0201204 <unmap_range+0x72>
            free_page(page);
ffffffffc020125e:	4585                	li	a1,1
ffffffffc0201260:	c83ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc0201264:	b7c5                	j	ffffffffc0201244 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0201266:	00006697          	auipc	a3,0x6
ffffffffc020126a:	5e268693          	addi	a3,a3,1506 # ffffffffc0207848 <commands+0xed0>
ffffffffc020126e:	00006617          	auipc	a2,0x6
ffffffffc0201272:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201276:	11000593          	li	a1,272
ffffffffc020127a:	00006517          	auipc	a0,0x6
ffffffffc020127e:	fce50513          	addi	a0,a0,-50 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201282:	f93fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201286:	00006697          	auipc	a3,0x6
ffffffffc020128a:	59268693          	addi	a3,a3,1426 # ffffffffc0207818 <commands+0xea0>
ffffffffc020128e:	00006617          	auipc	a2,0x6
ffffffffc0201292:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201296:	10f00593          	li	a1,271
ffffffffc020129a:	00006517          	auipc	a0,0x6
ffffffffc020129e:	fae50513          	addi	a0,a0,-82 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02012a2:	f73fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02012a6:	b99ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc02012aa <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012aa:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ac:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012b0:	fc86                	sd	ra,120(sp)
ffffffffc02012b2:	f8a2                	sd	s0,112(sp)
ffffffffc02012b4:	f4a6                	sd	s1,104(sp)
ffffffffc02012b6:	f0ca                	sd	s2,96(sp)
ffffffffc02012b8:	ecce                	sd	s3,88(sp)
ffffffffc02012ba:	e8d2                	sd	s4,80(sp)
ffffffffc02012bc:	e4d6                	sd	s5,72(sp)
ffffffffc02012be:	e0da                	sd	s6,64(sp)
ffffffffc02012c0:	fc5e                	sd	s7,56(sp)
ffffffffc02012c2:	f862                	sd	s8,48(sp)
ffffffffc02012c4:	f466                	sd	s9,40(sp)
ffffffffc02012c6:	f06a                	sd	s10,32(sp)
ffffffffc02012c8:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ca:	03479713          	slli	a4,a5,0x34
ffffffffc02012ce:	1c071163          	bnez	a4,ffffffffc0201490 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02012d2:	002007b7          	lui	a5,0x200
ffffffffc02012d6:	20f5e563          	bltu	a1,a5,ffffffffc02014e0 <exit_range+0x236>
ffffffffc02012da:	8b32                	mv	s6,a2
ffffffffc02012dc:	20c5f263          	bgeu	a1,a2,ffffffffc02014e0 <exit_range+0x236>
ffffffffc02012e0:	4785                	li	a5,1
ffffffffc02012e2:	07fe                	slli	a5,a5,0x1f
ffffffffc02012e4:	1ec7ee63          	bltu	a5,a2,ffffffffc02014e0 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02012e8:	c00009b7          	lui	s3,0xc0000
ffffffffc02012ec:	400007b7          	lui	a5,0x40000
ffffffffc02012f0:	0135f9b3          	and	s3,a1,s3
ffffffffc02012f4:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02012f6:	c0000337          	lui	t1,0xc0000
ffffffffc02012fa:	00698933          	add	s2,s3,t1
ffffffffc02012fe:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201302:	1ff97913          	andi	s2,s2,511
ffffffffc0201306:	8e2a                	mv	t3,a0
ffffffffc0201308:	090e                	slli	s2,s2,0x3
ffffffffc020130a:	9972                	add	s2,s2,t3
ffffffffc020130c:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201310:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0201314:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0201316:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020131a:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020131c:	000abd17          	auipc	s10,0xab
ffffffffc0201320:	504d0d13          	addi	s10,s10,1284 # ffffffffc02ac820 <npage>
    return KADDR(page2pa(page));
ffffffffc0201324:	00cddd93          	srli	s11,s11,0xc
ffffffffc0201328:	000ab717          	auipc	a4,0xab
ffffffffc020132c:	55070713          	addi	a4,a4,1360 # ffffffffc02ac878 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0201330:	000abe97          	auipc	t4,0xab
ffffffffc0201334:	558e8e93          	addi	t4,t4,1368 # ffffffffc02ac888 <pages>
        if (pde1&PTE_V){
ffffffffc0201338:	e79d                	bnez	a5,ffffffffc0201366 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020133a:	12098963          	beqz	s3,ffffffffc020146c <exit_range+0x1c2>
ffffffffc020133e:	400007b7          	lui	a5,0x40000
ffffffffc0201342:	84ce                	mv	s1,s3
ffffffffc0201344:	97ce                	add	a5,a5,s3
ffffffffc0201346:	1369f363          	bgeu	s3,s6,ffffffffc020146c <exit_range+0x1c2>
ffffffffc020134a:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020134c:	00698933          	add	s2,s3,t1
ffffffffc0201350:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201354:	1ff97913          	andi	s2,s2,511
ffffffffc0201358:	090e                	slli	s2,s2,0x3
ffffffffc020135a:	9972                	add	s2,s2,t3
ffffffffc020135c:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0201360:	001bf793          	andi	a5,s7,1
ffffffffc0201364:	dbf9                	beqz	a5,ffffffffc020133a <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201366:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020136a:	0b8a                	slli	s7,s7,0x2
ffffffffc020136c:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201370:	14fbfc63          	bgeu	s7,a5,ffffffffc02014c8 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201374:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201378:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020137a:	000806b7          	lui	a3,0x80
ffffffffc020137e:	96d6                	add	a3,a3,s5
ffffffffc0201380:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0201384:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0201388:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020138a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020138c:	12f67263          	bgeu	a2,a5,ffffffffc02014b0 <exit_range+0x206>
ffffffffc0201390:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0201394:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0201396:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020139a:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020139c:	00080837          	lui	a6,0x80
ffffffffc02013a0:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02013a2:	00200c37          	lui	s8,0x200
ffffffffc02013a6:	a801                	j	ffffffffc02013b6 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02013a8:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02013aa:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02013ac:	c0d9                	beqz	s1,ffffffffc0201432 <exit_range+0x188>
ffffffffc02013ae:	0934f263          	bgeu	s1,s3,ffffffffc0201432 <exit_range+0x188>
ffffffffc02013b2:	0d64fc63          	bgeu	s1,s6,ffffffffc020148a <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013b6:	0154d413          	srli	s0,s1,0x15
ffffffffc02013ba:	1ff47413          	andi	s0,s0,511
ffffffffc02013be:	040e                	slli	s0,s0,0x3
ffffffffc02013c0:	9452                	add	s0,s0,s4
ffffffffc02013c2:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02013c4:	0017f693          	andi	a3,a5,1
ffffffffc02013c8:	d2e5                	beqz	a3,ffffffffc02013a8 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02013ca:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013ce:	00279513          	slli	a0,a5,0x2
ffffffffc02013d2:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013d4:	0eb57a63          	bgeu	a0,a1,ffffffffc02014c8 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013d8:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02013da:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02013de:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02013e2:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013e6:	0cb7f563          	bgeu	a5,a1,ffffffffc02014b0 <exit_range+0x206>
ffffffffc02013ea:	631c                	ld	a5,0(a4)
ffffffffc02013ec:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013ee:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02013f2:	629c                	ld	a5,0(a3)
ffffffffc02013f4:	8b85                	andi	a5,a5,1
ffffffffc02013f6:	fbd5                	bnez	a5,ffffffffc02013aa <exit_range+0x100>
ffffffffc02013f8:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013fa:	fed59ce3          	bne	a1,a3,ffffffffc02013f2 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02013fe:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0201402:	4585                	li	a1,1
ffffffffc0201404:	e072                	sd	t3,0(sp)
ffffffffc0201406:	953e                	add	a0,a0,a5
ffffffffc0201408:	adbff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
                d0start += PTSIZE;
ffffffffc020140c:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc020140e:	00043023          	sd	zero,0(s0)
ffffffffc0201412:	000abe97          	auipc	t4,0xab
ffffffffc0201416:	476e8e93          	addi	t4,t4,1142 # ffffffffc02ac888 <pages>
ffffffffc020141a:	6e02                	ld	t3,0(sp)
ffffffffc020141c:	c0000337          	lui	t1,0xc0000
ffffffffc0201420:	fff808b7          	lui	a7,0xfff80
ffffffffc0201424:	00080837          	lui	a6,0x80
ffffffffc0201428:	000ab717          	auipc	a4,0xab
ffffffffc020142c:	45070713          	addi	a4,a4,1104 # ffffffffc02ac878 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201430:	fcbd                	bnez	s1,ffffffffc02013ae <exit_range+0x104>
            if (free_pd0) {
ffffffffc0201432:	f00c84e3          	beqz	s9,ffffffffc020133a <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201436:	000d3783          	ld	a5,0(s10)
ffffffffc020143a:	e072                	sd	t3,0(sp)
ffffffffc020143c:	08fbf663          	bgeu	s7,a5,ffffffffc02014c8 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201440:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0201444:	67a2                	ld	a5,8(sp)
ffffffffc0201446:	4585                	li	a1,1
ffffffffc0201448:	953e                	add	a0,a0,a5
ffffffffc020144a:	a99ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020144e:	00093023          	sd	zero,0(s2)
ffffffffc0201452:	000ab717          	auipc	a4,0xab
ffffffffc0201456:	42670713          	addi	a4,a4,1062 # ffffffffc02ac878 <va_pa_offset>
ffffffffc020145a:	c0000337          	lui	t1,0xc0000
ffffffffc020145e:	6e02                	ld	t3,0(sp)
ffffffffc0201460:	000abe97          	auipc	t4,0xab
ffffffffc0201464:	428e8e93          	addi	t4,t4,1064 # ffffffffc02ac888 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0201468:	ec099be3          	bnez	s3,ffffffffc020133e <exit_range+0x94>
}
ffffffffc020146c:	70e6                	ld	ra,120(sp)
ffffffffc020146e:	7446                	ld	s0,112(sp)
ffffffffc0201470:	74a6                	ld	s1,104(sp)
ffffffffc0201472:	7906                	ld	s2,96(sp)
ffffffffc0201474:	69e6                	ld	s3,88(sp)
ffffffffc0201476:	6a46                	ld	s4,80(sp)
ffffffffc0201478:	6aa6                	ld	s5,72(sp)
ffffffffc020147a:	6b06                	ld	s6,64(sp)
ffffffffc020147c:	7be2                	ld	s7,56(sp)
ffffffffc020147e:	7c42                	ld	s8,48(sp)
ffffffffc0201480:	7ca2                	ld	s9,40(sp)
ffffffffc0201482:	7d02                	ld	s10,32(sp)
ffffffffc0201484:	6de2                	ld	s11,24(sp)
ffffffffc0201486:	6109                	addi	sp,sp,128
ffffffffc0201488:	8082                	ret
            if (free_pd0) {
ffffffffc020148a:	ea0c8ae3          	beqz	s9,ffffffffc020133e <exit_range+0x94>
ffffffffc020148e:	b765                	j	ffffffffc0201436 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201490:	00006697          	auipc	a3,0x6
ffffffffc0201494:	38868693          	addi	a3,a3,904 # ffffffffc0207818 <commands+0xea0>
ffffffffc0201498:	00006617          	auipc	a2,0x6
ffffffffc020149c:	96060613          	addi	a2,a2,-1696 # ffffffffc0206df8 <commands+0x480>
ffffffffc02014a0:	12000593          	li	a1,288
ffffffffc02014a4:	00006517          	auipc	a0,0x6
ffffffffc02014a8:	da450513          	addi	a0,a0,-604 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02014ac:	d69fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc02014b0:	00006617          	auipc	a2,0x6
ffffffffc02014b4:	d7060613          	addi	a2,a2,-656 # ffffffffc0207220 <commands+0x8a8>
ffffffffc02014b8:	06900593          	li	a1,105
ffffffffc02014bc:	00006517          	auipc	a0,0x6
ffffffffc02014c0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0207278 <commands+0x900>
ffffffffc02014c4:	d51fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014c8:	00006617          	auipc	a2,0x6
ffffffffc02014cc:	d9060613          	addi	a2,a2,-624 # ffffffffc0207258 <commands+0x8e0>
ffffffffc02014d0:	06200593          	li	a1,98
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	da450513          	addi	a0,a0,-604 # ffffffffc0207278 <commands+0x900>
ffffffffc02014dc:	d39fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	36868693          	addi	a3,a3,872 # ffffffffc0207848 <commands+0xed0>
ffffffffc02014e8:	00006617          	auipc	a2,0x6
ffffffffc02014ec:	91060613          	addi	a2,a2,-1776 # ffffffffc0206df8 <commands+0x480>
ffffffffc02014f0:	12100593          	li	a1,289
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	d5450513          	addi	a0,a0,-684 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02014fc:	d19fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0201500 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201500:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201502:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201504:	e426                	sd	s1,8(sp)
ffffffffc0201506:	ec06                	sd	ra,24(sp)
ffffffffc0201508:	e822                	sd	s0,16(sp)
ffffffffc020150a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020150c:	a5dff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    if (ptep != NULL) {
ffffffffc0201510:	c511                	beqz	a0,ffffffffc020151c <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201512:	611c                	ld	a5,0(a0)
ffffffffc0201514:	842a                	mv	s0,a0
ffffffffc0201516:	0017f713          	andi	a4,a5,1
ffffffffc020151a:	e711                	bnez	a4,ffffffffc0201526 <page_remove+0x26>
}
ffffffffc020151c:	60e2                	ld	ra,24(sp)
ffffffffc020151e:	6442                	ld	s0,16(sp)
ffffffffc0201520:	64a2                	ld	s1,8(sp)
ffffffffc0201522:	6105                	addi	sp,sp,32
ffffffffc0201524:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201526:	000ab717          	auipc	a4,0xab
ffffffffc020152a:	2fa70713          	addi	a4,a4,762 # ffffffffc02ac820 <npage>
ffffffffc020152e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201530:	078a                	slli	a5,a5,0x2
ffffffffc0201532:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201534:	02e7fe63          	bgeu	a5,a4,ffffffffc0201570 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201538:	000ab717          	auipc	a4,0xab
ffffffffc020153c:	35070713          	addi	a4,a4,848 # ffffffffc02ac888 <pages>
ffffffffc0201540:	6308                	ld	a0,0(a4)
ffffffffc0201542:	fff80737          	lui	a4,0xfff80
ffffffffc0201546:	97ba                	add	a5,a5,a4
ffffffffc0201548:	079a                	slli	a5,a5,0x6
ffffffffc020154a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020154c:	411c                	lw	a5,0(a0)
ffffffffc020154e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201552:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201554:	cb11                	beqz	a4,ffffffffc0201568 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201556:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020155a:	12048073          	sfence.vma	s1
}
ffffffffc020155e:	60e2                	ld	ra,24(sp)
ffffffffc0201560:	6442                	ld	s0,16(sp)
ffffffffc0201562:	64a2                	ld	s1,8(sp)
ffffffffc0201564:	6105                	addi	sp,sp,32
ffffffffc0201566:	8082                	ret
            free_page(page);
ffffffffc0201568:	4585                	li	a1,1
ffffffffc020156a:	979ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc020156e:	b7e5                	j	ffffffffc0201556 <page_remove+0x56>
ffffffffc0201570:	8cfff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc0201574 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201574:	7179                	addi	sp,sp,-48
ffffffffc0201576:	e44e                	sd	s3,8(sp)
ffffffffc0201578:	89b2                	mv	s3,a2
ffffffffc020157a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020157c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020157e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201580:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201582:	ec26                	sd	s1,24(sp)
ffffffffc0201584:	f406                	sd	ra,40(sp)
ffffffffc0201586:	e84a                	sd	s2,16(sp)
ffffffffc0201588:	e052                	sd	s4,0(sp)
ffffffffc020158a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020158c:	9ddff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    if (ptep == NULL) {
ffffffffc0201590:	cd49                	beqz	a0,ffffffffc020162a <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201592:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201594:	611c                	ld	a5,0(a0)
ffffffffc0201596:	892a                	mv	s2,a0
ffffffffc0201598:	0016871b          	addiw	a4,a3,1
ffffffffc020159c:	c018                	sw	a4,0(s0)
ffffffffc020159e:	0017f713          	andi	a4,a5,1
ffffffffc02015a2:	ef05                	bnez	a4,ffffffffc02015da <page_insert+0x66>
ffffffffc02015a4:	000ab797          	auipc	a5,0xab
ffffffffc02015a8:	2e478793          	addi	a5,a5,740 # ffffffffc02ac888 <pages>
ffffffffc02015ac:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02015ae:	8c19                	sub	s0,s0,a4
ffffffffc02015b0:	000806b7          	lui	a3,0x80
ffffffffc02015b4:	8419                	srai	s0,s0,0x6
ffffffffc02015b6:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02015b8:	042a                	slli	s0,s0,0xa
ffffffffc02015ba:	8c45                	or	s0,s0,s1
ffffffffc02015bc:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02015c0:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015c4:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02015c8:	4501                	li	a0,0
}
ffffffffc02015ca:	70a2                	ld	ra,40(sp)
ffffffffc02015cc:	7402                	ld	s0,32(sp)
ffffffffc02015ce:	64e2                	ld	s1,24(sp)
ffffffffc02015d0:	6942                	ld	s2,16(sp)
ffffffffc02015d2:	69a2                	ld	s3,8(sp)
ffffffffc02015d4:	6a02                	ld	s4,0(sp)
ffffffffc02015d6:	6145                	addi	sp,sp,48
ffffffffc02015d8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02015da:	000ab717          	auipc	a4,0xab
ffffffffc02015de:	24670713          	addi	a4,a4,582 # ffffffffc02ac820 <npage>
ffffffffc02015e2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015e4:	078a                	slli	a5,a5,0x2
ffffffffc02015e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015e8:	04e7f363          	bgeu	a5,a4,ffffffffc020162e <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02015ec:	000aba17          	auipc	s4,0xab
ffffffffc02015f0:	29ca0a13          	addi	s4,s4,668 # ffffffffc02ac888 <pages>
ffffffffc02015f4:	000a3703          	ld	a4,0(s4)
ffffffffc02015f8:	fff80537          	lui	a0,0xfff80
ffffffffc02015fc:	953e                	add	a0,a0,a5
ffffffffc02015fe:	051a                	slli	a0,a0,0x6
ffffffffc0201600:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201602:	00a40a63          	beq	s0,a0,ffffffffc0201616 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201606:	411c                	lw	a5,0(a0)
ffffffffc0201608:	fff7869b          	addiw	a3,a5,-1
ffffffffc020160c:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc020160e:	c691                	beqz	a3,ffffffffc020161a <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201610:	12098073          	sfence.vma	s3
ffffffffc0201614:	bf69                	j	ffffffffc02015ae <page_insert+0x3a>
ffffffffc0201616:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201618:	bf59                	j	ffffffffc02015ae <page_insert+0x3a>
            free_page(page);
ffffffffc020161a:	4585                	li	a1,1
ffffffffc020161c:	8c7ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc0201620:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201624:	12098073          	sfence.vma	s3
ffffffffc0201628:	b759                	j	ffffffffc02015ae <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020162a:	5571                	li	a0,-4
ffffffffc020162c:	bf79                	j	ffffffffc02015ca <page_insert+0x56>
ffffffffc020162e:	811ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc0201632 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201632:	00007797          	auipc	a5,0x7
ffffffffc0201636:	dc678793          	addi	a5,a5,-570 # ffffffffc02083f8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020163a:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020163c:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020163e:	00006517          	auipc	a0,0x6
ffffffffc0201642:	c6250513          	addi	a0,a0,-926 # ffffffffc02072a0 <commands+0x928>
void pmm_init(void) {
ffffffffc0201646:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201648:	000ab717          	auipc	a4,0xab
ffffffffc020164c:	22f73423          	sd	a5,552(a4) # ffffffffc02ac870 <pmm_manager>
void pmm_init(void) {
ffffffffc0201650:	e0a2                	sd	s0,64(sp)
ffffffffc0201652:	fc26                	sd	s1,56(sp)
ffffffffc0201654:	f84a                	sd	s2,48(sp)
ffffffffc0201656:	f44e                	sd	s3,40(sp)
ffffffffc0201658:	f052                	sd	s4,32(sp)
ffffffffc020165a:	ec56                	sd	s5,24(sp)
ffffffffc020165c:	e85a                	sd	s6,16(sp)
ffffffffc020165e:	e45e                	sd	s7,8(sp)
ffffffffc0201660:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201662:	000ab417          	auipc	s0,0xab
ffffffffc0201666:	20e40413          	addi	s0,s0,526 # ffffffffc02ac870 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020166a:	a67fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc020166e:	601c                	ld	a5,0(s0)
ffffffffc0201670:	000ab497          	auipc	s1,0xab
ffffffffc0201674:	1b048493          	addi	s1,s1,432 # ffffffffc02ac820 <npage>
ffffffffc0201678:	000ab917          	auipc	s2,0xab
ffffffffc020167c:	21090913          	addi	s2,s2,528 # ffffffffc02ac888 <pages>
ffffffffc0201680:	679c                	ld	a5,8(a5)
ffffffffc0201682:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201684:	57f5                	li	a5,-3
ffffffffc0201686:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201688:	00006517          	auipc	a0,0x6
ffffffffc020168c:	c3050513          	addi	a0,a0,-976 # ffffffffc02072b8 <commands+0x940>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201690:	000ab717          	auipc	a4,0xab
ffffffffc0201694:	1ef73423          	sd	a5,488(a4) # ffffffffc02ac878 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201698:	a39fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020169c:	46c5                	li	a3,17
ffffffffc020169e:	06ee                	slli	a3,a3,0x1b
ffffffffc02016a0:	40100613          	li	a2,1025
ffffffffc02016a4:	16fd                	addi	a3,a3,-1
ffffffffc02016a6:	0656                	slli	a2,a2,0x15
ffffffffc02016a8:	07e005b7          	lui	a1,0x7e00
ffffffffc02016ac:	00006517          	auipc	a0,0x6
ffffffffc02016b0:	c2450513          	addi	a0,a0,-988 # ffffffffc02072d0 <commands+0x958>
ffffffffc02016b4:	a1dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016b8:	777d                	lui	a4,0xfffff
ffffffffc02016ba:	000ac797          	auipc	a5,0xac
ffffffffc02016be:	2dd78793          	addi	a5,a5,733 # ffffffffc02ad997 <end+0xfff>
ffffffffc02016c2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016c4:	00088737          	lui	a4,0x88
ffffffffc02016c8:	000ab697          	auipc	a3,0xab
ffffffffc02016cc:	14e6bc23          	sd	a4,344(a3) # ffffffffc02ac820 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016d0:	000ab717          	auipc	a4,0xab
ffffffffc02016d4:	1af73c23          	sd	a5,440(a4) # ffffffffc02ac888 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016d8:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016da:	4685                	li	a3,1
ffffffffc02016dc:	fff80837          	lui	a6,0xfff80
ffffffffc02016e0:	a019                	j	ffffffffc02016e6 <pmm_init+0xb4>
ffffffffc02016e2:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02016e6:	00671613          	slli	a2,a4,0x6
ffffffffc02016ea:	97b2                	add	a5,a5,a2
ffffffffc02016ec:	07a1                	addi	a5,a5,8
ffffffffc02016ee:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016f2:	6090                	ld	a2,0(s1)
ffffffffc02016f4:	0705                	addi	a4,a4,1
ffffffffc02016f6:	010607b3          	add	a5,a2,a6
ffffffffc02016fa:	fef764e3          	bltu	a4,a5,ffffffffc02016e2 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016fe:	00093503          	ld	a0,0(s2)
ffffffffc0201702:	fe0007b7          	lui	a5,0xfe000
ffffffffc0201706:	00661693          	slli	a3,a2,0x6
ffffffffc020170a:	97aa                	add	a5,a5,a0
ffffffffc020170c:	96be                	add	a3,a3,a5
ffffffffc020170e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201712:	7af6eb63          	bltu	a3,a5,ffffffffc0201ec8 <pmm_init+0x896>
ffffffffc0201716:	000ab997          	auipc	s3,0xab
ffffffffc020171a:	16298993          	addi	s3,s3,354 # ffffffffc02ac878 <va_pa_offset>
ffffffffc020171e:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201722:	47c5                	li	a5,17
ffffffffc0201724:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201726:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201728:	02f6f763          	bgeu	a3,a5,ffffffffc0201756 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020172c:	6585                	lui	a1,0x1
ffffffffc020172e:	15fd                	addi	a1,a1,-1
ffffffffc0201730:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0201732:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201736:	48c77863          	bgeu	a4,a2,ffffffffc0201bc6 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc020173a:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020173c:	75fd                	lui	a1,0xfffff
ffffffffc020173e:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0201740:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0201742:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201744:	40d786b3          	sub	a3,a5,a3
ffffffffc0201748:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020174a:	00c6d593          	srli	a1,a3,0xc
ffffffffc020174e:	953a                	add	a0,a0,a4
ffffffffc0201750:	9602                	jalr	a2
ffffffffc0201752:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201756:	00006517          	auipc	a0,0x6
ffffffffc020175a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0207320 <commands+0x9a8>
ffffffffc020175e:	973fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201762:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201764:	000ab417          	auipc	s0,0xab
ffffffffc0201768:	0b440413          	addi	s0,s0,180 # ffffffffc02ac818 <boot_pgdir>
    pmm_manager->check();
ffffffffc020176c:	7b9c                	ld	a5,48(a5)
ffffffffc020176e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201770:	00006517          	auipc	a0,0x6
ffffffffc0201774:	bc850513          	addi	a0,a0,-1080 # ffffffffc0207338 <commands+0x9c0>
ffffffffc0201778:	959fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020177c:	0000a697          	auipc	a3,0xa
ffffffffc0201780:	88468693          	addi	a3,a3,-1916 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0201784:	000ab797          	auipc	a5,0xab
ffffffffc0201788:	08d7ba23          	sd	a3,148(a5) # ffffffffc02ac818 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020178c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201790:	10f6e8e3          	bltu	a3,a5,ffffffffc02020a0 <pmm_init+0xa6e>
ffffffffc0201794:	0009b783          	ld	a5,0(s3)
ffffffffc0201798:	8e9d                	sub	a3,a3,a5
ffffffffc020179a:	000ab797          	auipc	a5,0xab
ffffffffc020179e:	0ed7b323          	sd	a3,230(a5) # ffffffffc02ac880 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02017a2:	f86ff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017a6:	6098                	ld	a4,0(s1)
ffffffffc02017a8:	c80007b7          	lui	a5,0xc8000
ffffffffc02017ac:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02017ae:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017b0:	0ce7e8e3          	bltu	a5,a4,ffffffffc0202080 <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02017b4:	6008                	ld	a0,0(s0)
ffffffffc02017b6:	44050263          	beqz	a0,ffffffffc0201bfa <pmm_init+0x5c8>
ffffffffc02017ba:	03451793          	slli	a5,a0,0x34
ffffffffc02017be:	42079e63          	bnez	a5,ffffffffc0201bfa <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017c2:	4601                	li	a2,0
ffffffffc02017c4:	4581                	li	a1,0
ffffffffc02017c6:	975ff0ef          	jal	ra,ffffffffc020113a <get_page>
ffffffffc02017ca:	78051b63          	bnez	a0,ffffffffc0201f60 <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02017ce:	4505                	li	a0,1
ffffffffc02017d0:	e8aff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02017d4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017d6:	6008                	ld	a0,0(s0)
ffffffffc02017d8:	4681                	li	a3,0
ffffffffc02017da:	4601                	li	a2,0
ffffffffc02017dc:	85d6                	mv	a1,s5
ffffffffc02017de:	d97ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc02017e2:	7a051f63          	bnez	a0,ffffffffc0201fa0 <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02017e6:	6008                	ld	a0,0(s0)
ffffffffc02017e8:	4601                	li	a2,0
ffffffffc02017ea:	4581                	li	a1,0
ffffffffc02017ec:	f7cff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02017f0:	78050863          	beqz	a0,ffffffffc0201f80 <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02017f4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02017f6:	0017f713          	andi	a4,a5,1
ffffffffc02017fa:	3e070463          	beqz	a4,ffffffffc0201be2 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02017fe:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201800:	078a                	slli	a5,a5,0x2
ffffffffc0201802:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201804:	3ce7f163          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201808:	00093683          	ld	a3,0(s2)
ffffffffc020180c:	fff80637          	lui	a2,0xfff80
ffffffffc0201810:	97b2                	add	a5,a5,a2
ffffffffc0201812:	079a                	slli	a5,a5,0x6
ffffffffc0201814:	97b6                	add	a5,a5,a3
ffffffffc0201816:	72fa9563          	bne	s5,a5,ffffffffc0201f40 <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc020181a:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc020181e:	4785                	li	a5,1
ffffffffc0201820:	70fb9063          	bne	s7,a5,ffffffffc0201f20 <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201824:	6008                	ld	a0,0(s0)
ffffffffc0201826:	76fd                	lui	a3,0xfffff
ffffffffc0201828:	611c                	ld	a5,0(a0)
ffffffffc020182a:	078a                	slli	a5,a5,0x2
ffffffffc020182c:	8ff5                	and	a5,a5,a3
ffffffffc020182e:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201832:	66e67e63          	bgeu	a2,a4,ffffffffc0201eae <pmm_init+0x87c>
ffffffffc0201836:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020183a:	97e2                	add	a5,a5,s8
ffffffffc020183c:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d53668>
ffffffffc0201840:	0b0a                	slli	s6,s6,0x2
ffffffffc0201842:	00db7b33          	and	s6,s6,a3
ffffffffc0201846:	00cb5793          	srli	a5,s6,0xc
ffffffffc020184a:	56e7f863          	bgeu	a5,a4,ffffffffc0201dba <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020184e:	4601                	li	a2,0
ffffffffc0201850:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201852:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201854:	f14ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201858:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020185a:	55651063          	bne	a0,s6,ffffffffc0201d9a <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc020185e:	4505                	li	a0,1
ffffffffc0201860:	dfaff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201864:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201866:	6008                	ld	a0,0(s0)
ffffffffc0201868:	46d1                	li	a3,20
ffffffffc020186a:	6605                	lui	a2,0x1
ffffffffc020186c:	85da                	mv	a1,s6
ffffffffc020186e:	d07ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0201872:	50051463          	bnez	a0,ffffffffc0201d7a <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201876:	6008                	ld	a0,0(s0)
ffffffffc0201878:	4601                	li	a2,0
ffffffffc020187a:	6585                	lui	a1,0x1
ffffffffc020187c:	eecff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0201880:	4c050d63          	beqz	a0,ffffffffc0201d5a <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc0201884:	611c                	ld	a5,0(a0)
ffffffffc0201886:	0107f713          	andi	a4,a5,16
ffffffffc020188a:	4a070863          	beqz	a4,ffffffffc0201d3a <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc020188e:	8b91                	andi	a5,a5,4
ffffffffc0201890:	48078563          	beqz	a5,ffffffffc0201d1a <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201894:	6008                	ld	a0,0(s0)
ffffffffc0201896:	611c                	ld	a5,0(a0)
ffffffffc0201898:	8bc1                	andi	a5,a5,16
ffffffffc020189a:	46078063          	beqz	a5,ffffffffc0201cfa <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc020189e:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
ffffffffc02018a2:	43779c63          	bne	a5,s7,ffffffffc0201cda <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018a6:	4681                	li	a3,0
ffffffffc02018a8:	6605                	lui	a2,0x1
ffffffffc02018aa:	85d6                	mv	a1,s5
ffffffffc02018ac:	cc9ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc02018b0:	40051563          	bnez	a0,ffffffffc0201cba <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc02018b4:	000aa703          	lw	a4,0(s5)
ffffffffc02018b8:	4789                	li	a5,2
ffffffffc02018ba:	3ef71063          	bne	a4,a5,ffffffffc0201c9a <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc02018be:	000b2783          	lw	a5,0(s6)
ffffffffc02018c2:	3a079c63          	bnez	a5,ffffffffc0201c7a <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018c6:	6008                	ld	a0,0(s0)
ffffffffc02018c8:	4601                	li	a2,0
ffffffffc02018ca:	6585                	lui	a1,0x1
ffffffffc02018cc:	e9cff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02018d0:	38050563          	beqz	a0,ffffffffc0201c5a <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc02018d4:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018d6:	00177793          	andi	a5,a4,1
ffffffffc02018da:	30078463          	beqz	a5,ffffffffc0201be2 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02018de:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02018e0:	00271793          	slli	a5,a4,0x2
ffffffffc02018e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018e6:	2ed7f063          	bgeu	a5,a3,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02018ea:	00093683          	ld	a3,0(s2)
ffffffffc02018ee:	fff80637          	lui	a2,0xfff80
ffffffffc02018f2:	97b2                	add	a5,a5,a2
ffffffffc02018f4:	079a                	slli	a5,a5,0x6
ffffffffc02018f6:	97b6                	add	a5,a5,a3
ffffffffc02018f8:	32fa9163          	bne	s5,a5,ffffffffc0201c1a <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02018fc:	8b41                	andi	a4,a4,16
ffffffffc02018fe:	70071163          	bnez	a4,ffffffffc0202000 <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201902:	6008                	ld	a0,0(s0)
ffffffffc0201904:	4581                	li	a1,0
ffffffffc0201906:	bfbff0ef          	jal	ra,ffffffffc0201500 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020190a:	000aa703          	lw	a4,0(s5)
ffffffffc020190e:	4785                	li	a5,1
ffffffffc0201910:	6cf71863          	bne	a4,a5,ffffffffc0201fe0 <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc0201914:	000b2783          	lw	a5,0(s6)
ffffffffc0201918:	6a079463          	bnez	a5,ffffffffc0201fc0 <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020191c:	6008                	ld	a0,0(s0)
ffffffffc020191e:	6585                	lui	a1,0x1
ffffffffc0201920:	be1ff0ef          	jal	ra,ffffffffc0201500 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201924:	000aa783          	lw	a5,0(s5)
ffffffffc0201928:	50079363          	bnez	a5,ffffffffc0201e2e <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc020192c:	000b2783          	lw	a5,0(s6)
ffffffffc0201930:	4c079f63          	bnez	a5,ffffffffc0201e0e <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201934:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201938:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020193a:	000b3783          	ld	a5,0(s6)
ffffffffc020193e:	078a                	slli	a5,a5,0x2
ffffffffc0201940:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201942:	28e7f263          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201946:	fff806b7          	lui	a3,0xfff80
ffffffffc020194a:	00093503          	ld	a0,0(s2)
ffffffffc020194e:	97b6                	add	a5,a5,a3
ffffffffc0201950:	079a                	slli	a5,a5,0x6
ffffffffc0201952:	00f506b3          	add	a3,a0,a5
ffffffffc0201956:	4290                	lw	a2,0(a3)
ffffffffc0201958:	4685                	li	a3,1
ffffffffc020195a:	48d61a63          	bne	a2,a3,ffffffffc0201dee <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc020195e:	8799                	srai	a5,a5,0x6
ffffffffc0201960:	00080ab7          	lui	s5,0x80
ffffffffc0201964:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201966:	00c79693          	slli	a3,a5,0xc
ffffffffc020196a:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020196c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020196e:	46e6f363          	bgeu	a3,a4,ffffffffc0201dd4 <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201972:	0009b683          	ld	a3,0(s3)
ffffffffc0201976:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201978:	639c                	ld	a5,0(a5)
ffffffffc020197a:	078a                	slli	a5,a5,0x2
ffffffffc020197c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020197e:	24e7f463          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201982:	415787b3          	sub	a5,a5,s5
ffffffffc0201986:	079a                	slli	a5,a5,0x6
ffffffffc0201988:	953e                	add	a0,a0,a5
ffffffffc020198a:	4585                	li	a1,1
ffffffffc020198c:	d56ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201990:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201994:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201996:	078a                	slli	a5,a5,0x2
ffffffffc0201998:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020199a:	22e7f663          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020199e:	00093503          	ld	a0,0(s2)
ffffffffc02019a2:	415787b3          	sub	a5,a5,s5
ffffffffc02019a6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02019a8:	953e                	add	a0,a0,a5
ffffffffc02019aa:	4585                	li	a1,1
ffffffffc02019ac:	d36ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02019b0:	601c                	ld	a5,0(s0)
ffffffffc02019b2:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02019b6:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02019ba:	d6eff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc02019be:	68aa1163          	bne	s4,a0,ffffffffc0202040 <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02019c2:	00006517          	auipc	a0,0x6
ffffffffc02019c6:	c8650513          	addi	a0,a0,-890 # ffffffffc0207648 <commands+0xcd0>
ffffffffc02019ca:	f06fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02019ce:	d5aff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019d2:	6098                	ld	a4,0(s1)
ffffffffc02019d4:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02019d8:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019da:	00c71693          	slli	a3,a4,0xc
ffffffffc02019de:	18d7f563          	bgeu	a5,a3,ffffffffc0201b68 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019e2:	83b1                	srli	a5,a5,0xc
ffffffffc02019e4:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019e6:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019ea:	1ae7f163          	bgeu	a5,a4,ffffffffc0201b8c <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02019ee:	7bfd                	lui	s7,0xfffff
ffffffffc02019f0:	6b05                	lui	s6,0x1
ffffffffc02019f2:	a029                	j	ffffffffc02019fc <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019f4:	00cad713          	srli	a4,s5,0xc
ffffffffc02019f8:	18f77a63          	bgeu	a4,a5,ffffffffc0201b8c <pmm_init+0x55a>
ffffffffc02019fc:	0009b583          	ld	a1,0(s3)
ffffffffc0201a00:	4601                	li	a2,0
ffffffffc0201a02:	95d6                	add	a1,a1,s5
ffffffffc0201a04:	d64ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0201a08:	16050263          	beqz	a0,ffffffffc0201b6c <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a0c:	611c                	ld	a5,0(a0)
ffffffffc0201a0e:	078a                	slli	a5,a5,0x2
ffffffffc0201a10:	0177f7b3          	and	a5,a5,s7
ffffffffc0201a14:	19579963          	bne	a5,s5,ffffffffc0201ba6 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a18:	609c                	ld	a5,0(s1)
ffffffffc0201a1a:	9ada                	add	s5,s5,s6
ffffffffc0201a1c:	6008                	ld	a0,0(s0)
ffffffffc0201a1e:	00c79713          	slli	a4,a5,0xc
ffffffffc0201a22:	fceae9e3          	bltu	s5,a4,ffffffffc02019f4 <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201a26:	611c                	ld	a5,0(a0)
ffffffffc0201a28:	62079c63          	bnez	a5,ffffffffc0202060 <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc0201a2c:	4505                	li	a0,1
ffffffffc0201a2e:	c2cff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201a32:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a34:	6008                	ld	a0,0(s0)
ffffffffc0201a36:	4699                	li	a3,6
ffffffffc0201a38:	10000613          	li	a2,256
ffffffffc0201a3c:	85d6                	mv	a1,s5
ffffffffc0201a3e:	b37ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0201a42:	1e051c63          	bnez	a0,ffffffffc0201c3a <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0201a46:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201a4a:	4785                	li	a5,1
ffffffffc0201a4c:	44f71163          	bne	a4,a5,ffffffffc0201e8e <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a50:	6008                	ld	a0,0(s0)
ffffffffc0201a52:	6b05                	lui	s6,0x1
ffffffffc0201a54:	4699                	li	a3,6
ffffffffc0201a56:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84c8>
ffffffffc0201a5a:	85d6                	mv	a1,s5
ffffffffc0201a5c:	b19ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0201a60:	40051763          	bnez	a0,ffffffffc0201e6e <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0201a64:	000aa703          	lw	a4,0(s5)
ffffffffc0201a68:	4789                	li	a5,2
ffffffffc0201a6a:	3ef71263          	bne	a4,a5,ffffffffc0201e4e <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201a6e:	00006597          	auipc	a1,0x6
ffffffffc0201a72:	d1258593          	addi	a1,a1,-750 # ffffffffc0207780 <commands+0xe08>
ffffffffc0201a76:	10000513          	li	a0,256
ffffffffc0201a7a:	105040ef          	jal	ra,ffffffffc020637e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201a7e:	100b0593          	addi	a1,s6,256
ffffffffc0201a82:	10000513          	li	a0,256
ffffffffc0201a86:	10b040ef          	jal	ra,ffffffffc0206390 <strcmp>
ffffffffc0201a8a:	44051b63          	bnez	a0,ffffffffc0201ee0 <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0201a8e:	00093683          	ld	a3,0(s2)
ffffffffc0201a92:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201a96:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201a98:	40da86b3          	sub	a3,s5,a3
ffffffffc0201a9c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201a9e:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201aa0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201aa2:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201aa6:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201aaa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201aac:	10f77f63          	bgeu	a4,a5,ffffffffc0201bca <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ab0:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ab4:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ab8:	96be                	add	a3,a3,a5
ffffffffc0201aba:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd3768>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201abe:	07d040ef          	jal	ra,ffffffffc020633a <strlen>
ffffffffc0201ac2:	54051f63          	bnez	a0,ffffffffc0202020 <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ac6:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201aca:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201acc:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52668>
ffffffffc0201ad0:	068a                	slli	a3,a3,0x2
ffffffffc0201ad2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ad4:	0ef6f963          	bgeu	a3,a5,ffffffffc0201bc6 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0201ad8:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201adc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ade:	0efb7663          	bgeu	s6,a5,ffffffffc0201bca <pmm_init+0x598>
ffffffffc0201ae2:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201ae6:	4585                	li	a1,1
ffffffffc0201ae8:	8556                	mv	a0,s5
ffffffffc0201aea:	99b6                	add	s3,s3,a3
ffffffffc0201aec:	bf6ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af0:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201af4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af6:	078a                	slli	a5,a5,0x2
ffffffffc0201af8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201afa:	0ce7f663          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201afe:	00093503          	ld	a0,0(s2)
ffffffffc0201b02:	fff809b7          	lui	s3,0xfff80
ffffffffc0201b06:	97ce                	add	a5,a5,s3
ffffffffc0201b08:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201b0a:	953e                	add	a0,a0,a5
ffffffffc0201b0c:	4585                	li	a1,1
ffffffffc0201b0e:	bd4ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b12:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201b16:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b18:	078a                	slli	a5,a5,0x2
ffffffffc0201b1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b1c:	0ae7f563          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b20:	00093503          	ld	a0,0(s2)
ffffffffc0201b24:	97ce                	add	a5,a5,s3
ffffffffc0201b26:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b28:	953e                	add	a0,a0,a5
ffffffffc0201b2a:	4585                	li	a1,1
ffffffffc0201b2c:	bb6ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b30:	601c                	ld	a5,0(s0)
ffffffffc0201b32:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201b36:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201b3a:	beeff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0201b3e:	3caa1163          	bne	s4,a0,ffffffffc0201f00 <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201b42:	00006517          	auipc	a0,0x6
ffffffffc0201b46:	cb650513          	addi	a0,a0,-842 # ffffffffc02077f8 <commands+0xe80>
ffffffffc0201b4a:	d86fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201b4e:	6406                	ld	s0,64(sp)
ffffffffc0201b50:	60a6                	ld	ra,72(sp)
ffffffffc0201b52:	74e2                	ld	s1,56(sp)
ffffffffc0201b54:	7942                	ld	s2,48(sp)
ffffffffc0201b56:	79a2                	ld	s3,40(sp)
ffffffffc0201b58:	7a02                	ld	s4,32(sp)
ffffffffc0201b5a:	6ae2                	ld	s5,24(sp)
ffffffffc0201b5c:	6b42                	ld	s6,16(sp)
ffffffffc0201b5e:	6ba2                	ld	s7,8(sp)
ffffffffc0201b60:	6c02                	ld	s8,0(sp)
ffffffffc0201b62:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201b64:	75c0106f          	j	ffffffffc02032c0 <kmalloc_init>
ffffffffc0201b68:	6008                	ld	a0,0(s0)
ffffffffc0201b6a:	bd75                	j	ffffffffc0201a26 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b6c:	00006697          	auipc	a3,0x6
ffffffffc0201b70:	afc68693          	addi	a3,a3,-1284 # ffffffffc0207668 <commands+0xcf0>
ffffffffc0201b74:	00005617          	auipc	a2,0x5
ffffffffc0201b78:	28460613          	addi	a2,a2,644 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201b7c:	22f00593          	li	a1,559
ffffffffc0201b80:	00005517          	auipc	a0,0x5
ffffffffc0201b84:	6c850513          	addi	a0,a0,1736 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201b88:	e8cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201b8c:	86d6                	mv	a3,s5
ffffffffc0201b8e:	00005617          	auipc	a2,0x5
ffffffffc0201b92:	69260613          	addi	a2,a2,1682 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0201b96:	22f00593          	li	a1,559
ffffffffc0201b9a:	00005517          	auipc	a0,0x5
ffffffffc0201b9e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201ba2:	e72fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ba6:	00006697          	auipc	a3,0x6
ffffffffc0201baa:	b0268693          	addi	a3,a3,-1278 # ffffffffc02076a8 <commands+0xd30>
ffffffffc0201bae:	00005617          	auipc	a2,0x5
ffffffffc0201bb2:	24a60613          	addi	a2,a2,586 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201bb6:	23000593          	li	a1,560
ffffffffc0201bba:	00005517          	auipc	a0,0x5
ffffffffc0201bbe:	68e50513          	addi	a0,a0,1678 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201bc2:	e52fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201bc6:	a78ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201bca:	00005617          	auipc	a2,0x5
ffffffffc0201bce:	65660613          	addi	a2,a2,1622 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0201bd2:	06900593          	li	a1,105
ffffffffc0201bd6:	00005517          	auipc	a0,0x5
ffffffffc0201bda:	6a250513          	addi	a0,a0,1698 # ffffffffc0207278 <commands+0x900>
ffffffffc0201bde:	e36fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201be2:	00006617          	auipc	a2,0x6
ffffffffc0201be6:	85660613          	addi	a2,a2,-1962 # ffffffffc0207438 <commands+0xac0>
ffffffffc0201bea:	07400593          	li	a1,116
ffffffffc0201bee:	00005517          	auipc	a0,0x5
ffffffffc0201bf2:	68a50513          	addi	a0,a0,1674 # ffffffffc0207278 <commands+0x900>
ffffffffc0201bf6:	e1efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201bfa:	00005697          	auipc	a3,0x5
ffffffffc0201bfe:	77e68693          	addi	a3,a3,1918 # ffffffffc0207378 <commands+0xa00>
ffffffffc0201c02:	00005617          	auipc	a2,0x5
ffffffffc0201c06:	1f660613          	addi	a2,a2,502 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201c0a:	1f300593          	li	a1,499
ffffffffc0201c0e:	00005517          	auipc	a0,0x5
ffffffffc0201c12:	63a50513          	addi	a0,a0,1594 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201c16:	dfefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c1a:	00006697          	auipc	a3,0x6
ffffffffc0201c1e:	84668693          	addi	a3,a3,-1978 # ffffffffc0207460 <commands+0xae8>
ffffffffc0201c22:	00005617          	auipc	a2,0x5
ffffffffc0201c26:	1d660613          	addi	a2,a2,470 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201c2a:	20f00593          	li	a1,527
ffffffffc0201c2e:	00005517          	auipc	a0,0x5
ffffffffc0201c32:	61a50513          	addi	a0,a0,1562 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201c36:	ddefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c3a:	00006697          	auipc	a3,0x6
ffffffffc0201c3e:	a9e68693          	addi	a3,a3,-1378 # ffffffffc02076d8 <commands+0xd60>
ffffffffc0201c42:	00005617          	auipc	a2,0x5
ffffffffc0201c46:	1b660613          	addi	a2,a2,438 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201c4a:	23800593          	li	a1,568
ffffffffc0201c4e:	00005517          	auipc	a0,0x5
ffffffffc0201c52:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201c56:	dbefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201c5a:	00006697          	auipc	a3,0x6
ffffffffc0201c5e:	89668693          	addi	a3,a3,-1898 # ffffffffc02074f0 <commands+0xb78>
ffffffffc0201c62:	00005617          	auipc	a2,0x5
ffffffffc0201c66:	19660613          	addi	a2,a2,406 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201c6a:	20e00593          	li	a1,526
ffffffffc0201c6e:	00005517          	auipc	a0,0x5
ffffffffc0201c72:	5da50513          	addi	a0,a0,1498 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201c76:	d9efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201c7a:	00006697          	auipc	a3,0x6
ffffffffc0201c7e:	93e68693          	addi	a3,a3,-1730 # ffffffffc02075b8 <commands+0xc40>
ffffffffc0201c82:	00005617          	auipc	a2,0x5
ffffffffc0201c86:	17660613          	addi	a2,a2,374 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201c8a:	20d00593          	li	a1,525
ffffffffc0201c8e:	00005517          	auipc	a0,0x5
ffffffffc0201c92:	5ba50513          	addi	a0,a0,1466 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201c96:	d7efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201c9a:	00006697          	auipc	a3,0x6
ffffffffc0201c9e:	90668693          	addi	a3,a3,-1786 # ffffffffc02075a0 <commands+0xc28>
ffffffffc0201ca2:	00005617          	auipc	a2,0x5
ffffffffc0201ca6:	15660613          	addi	a2,a2,342 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201caa:	20c00593          	li	a1,524
ffffffffc0201cae:	00005517          	auipc	a0,0x5
ffffffffc0201cb2:	59a50513          	addi	a0,a0,1434 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201cb6:	d5efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201cba:	00006697          	auipc	a3,0x6
ffffffffc0201cbe:	8b668693          	addi	a3,a3,-1866 # ffffffffc0207570 <commands+0xbf8>
ffffffffc0201cc2:	00005617          	auipc	a2,0x5
ffffffffc0201cc6:	13660613          	addi	a2,a2,310 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201cca:	20b00593          	li	a1,523
ffffffffc0201cce:	00005517          	auipc	a0,0x5
ffffffffc0201cd2:	57a50513          	addi	a0,a0,1402 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201cd6:	d3efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201cda:	00006697          	auipc	a3,0x6
ffffffffc0201cde:	87e68693          	addi	a3,a3,-1922 # ffffffffc0207558 <commands+0xbe0>
ffffffffc0201ce2:	00005617          	auipc	a2,0x5
ffffffffc0201ce6:	11660613          	addi	a2,a2,278 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201cea:	20900593          	li	a1,521
ffffffffc0201cee:	00005517          	auipc	a0,0x5
ffffffffc0201cf2:	55a50513          	addi	a0,a0,1370 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201cf6:	d1efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201cfa:	00006697          	auipc	a3,0x6
ffffffffc0201cfe:	84668693          	addi	a3,a3,-1978 # ffffffffc0207540 <commands+0xbc8>
ffffffffc0201d02:	00005617          	auipc	a2,0x5
ffffffffc0201d06:	0f660613          	addi	a2,a2,246 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201d0a:	20800593          	li	a1,520
ffffffffc0201d0e:	00005517          	auipc	a0,0x5
ffffffffc0201d12:	53a50513          	addi	a0,a0,1338 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201d16:	cfefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d1a:	00006697          	auipc	a3,0x6
ffffffffc0201d1e:	81668693          	addi	a3,a3,-2026 # ffffffffc0207530 <commands+0xbb8>
ffffffffc0201d22:	00005617          	auipc	a2,0x5
ffffffffc0201d26:	0d660613          	addi	a2,a2,214 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201d2a:	20700593          	li	a1,519
ffffffffc0201d2e:	00005517          	auipc	a0,0x5
ffffffffc0201d32:	51a50513          	addi	a0,a0,1306 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201d36:	cdefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d3a:	00005697          	auipc	a3,0x5
ffffffffc0201d3e:	7e668693          	addi	a3,a3,2022 # ffffffffc0207520 <commands+0xba8>
ffffffffc0201d42:	00005617          	auipc	a2,0x5
ffffffffc0201d46:	0b660613          	addi	a2,a2,182 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201d4a:	20600593          	li	a1,518
ffffffffc0201d4e:	00005517          	auipc	a0,0x5
ffffffffc0201d52:	4fa50513          	addi	a0,a0,1274 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201d56:	cbefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d5a:	00005697          	auipc	a3,0x5
ffffffffc0201d5e:	79668693          	addi	a3,a3,1942 # ffffffffc02074f0 <commands+0xb78>
ffffffffc0201d62:	00005617          	auipc	a2,0x5
ffffffffc0201d66:	09660613          	addi	a2,a2,150 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201d6a:	20500593          	li	a1,517
ffffffffc0201d6e:	00005517          	auipc	a0,0x5
ffffffffc0201d72:	4da50513          	addi	a0,a0,1242 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201d76:	c9efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d7a:	00005697          	auipc	a3,0x5
ffffffffc0201d7e:	73e68693          	addi	a3,a3,1854 # ffffffffc02074b8 <commands+0xb40>
ffffffffc0201d82:	00005617          	auipc	a2,0x5
ffffffffc0201d86:	07660613          	addi	a2,a2,118 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201d8a:	20400593          	li	a1,516
ffffffffc0201d8e:	00005517          	auipc	a0,0x5
ffffffffc0201d92:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201d96:	c7efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d9a:	00005697          	auipc	a3,0x5
ffffffffc0201d9e:	6f668693          	addi	a3,a3,1782 # ffffffffc0207490 <commands+0xb18>
ffffffffc0201da2:	00005617          	auipc	a2,0x5
ffffffffc0201da6:	05660613          	addi	a2,a2,86 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201daa:	20100593          	li	a1,513
ffffffffc0201dae:	00005517          	auipc	a0,0x5
ffffffffc0201db2:	49a50513          	addi	a0,a0,1178 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201db6:	c5efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201dba:	86da                	mv	a3,s6
ffffffffc0201dbc:	00005617          	auipc	a2,0x5
ffffffffc0201dc0:	46460613          	addi	a2,a2,1124 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0201dc4:	20000593          	li	a1,512
ffffffffc0201dc8:	00005517          	auipc	a0,0x5
ffffffffc0201dcc:	48050513          	addi	a0,a0,1152 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201dd0:	c44fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201dd4:	86be                	mv	a3,a5
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	44a60613          	addi	a2,a2,1098 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0201dde:	06900593          	li	a1,105
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	49650513          	addi	a0,a0,1174 # ffffffffc0207278 <commands+0x900>
ffffffffc0201dea:	c2afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dee:	00006697          	auipc	a3,0x6
ffffffffc0201df2:	81268693          	addi	a3,a3,-2030 # ffffffffc0207600 <commands+0xc88>
ffffffffc0201df6:	00005617          	auipc	a2,0x5
ffffffffc0201dfa:	00260613          	addi	a2,a2,2 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201dfe:	21a00593          	li	a1,538
ffffffffc0201e02:	00005517          	auipc	a0,0x5
ffffffffc0201e06:	44650513          	addi	a0,a0,1094 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201e0a:	c0afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e0e:	00005697          	auipc	a3,0x5
ffffffffc0201e12:	7aa68693          	addi	a3,a3,1962 # ffffffffc02075b8 <commands+0xc40>
ffffffffc0201e16:	00005617          	auipc	a2,0x5
ffffffffc0201e1a:	fe260613          	addi	a2,a2,-30 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201e1e:	21800593          	li	a1,536
ffffffffc0201e22:	00005517          	auipc	a0,0x5
ffffffffc0201e26:	42650513          	addi	a0,a0,1062 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201e2a:	beafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e2e:	00005697          	auipc	a3,0x5
ffffffffc0201e32:	7ba68693          	addi	a3,a3,1978 # ffffffffc02075e8 <commands+0xc70>
ffffffffc0201e36:	00005617          	auipc	a2,0x5
ffffffffc0201e3a:	fc260613          	addi	a2,a2,-62 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201e3e:	21700593          	li	a1,535
ffffffffc0201e42:	00005517          	auipc	a0,0x5
ffffffffc0201e46:	40650513          	addi	a0,a0,1030 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201e4a:	bcafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201e4e:	00006697          	auipc	a3,0x6
ffffffffc0201e52:	91a68693          	addi	a3,a3,-1766 # ffffffffc0207768 <commands+0xdf0>
ffffffffc0201e56:	00005617          	auipc	a2,0x5
ffffffffc0201e5a:	fa260613          	addi	a2,a2,-94 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201e5e:	23b00593          	li	a1,571
ffffffffc0201e62:	00005517          	auipc	a0,0x5
ffffffffc0201e66:	3e650513          	addi	a0,a0,998 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201e6a:	baafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e6e:	00006697          	auipc	a3,0x6
ffffffffc0201e72:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0207728 <commands+0xdb0>
ffffffffc0201e76:	00005617          	auipc	a2,0x5
ffffffffc0201e7a:	f8260613          	addi	a2,a2,-126 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201e7e:	23a00593          	li	a1,570
ffffffffc0201e82:	00005517          	auipc	a0,0x5
ffffffffc0201e86:	3c650513          	addi	a0,a0,966 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201e8a:	b8afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201e8e:	00006697          	auipc	a3,0x6
ffffffffc0201e92:	88268693          	addi	a3,a3,-1918 # ffffffffc0207710 <commands+0xd98>
ffffffffc0201e96:	00005617          	auipc	a2,0x5
ffffffffc0201e9a:	f6260613          	addi	a2,a2,-158 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201e9e:	23900593          	li	a1,569
ffffffffc0201ea2:	00005517          	auipc	a0,0x5
ffffffffc0201ea6:	3a650513          	addi	a0,a0,934 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201eaa:	b6afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201eae:	86be                	mv	a3,a5
ffffffffc0201eb0:	00005617          	auipc	a2,0x5
ffffffffc0201eb4:	37060613          	addi	a2,a2,880 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0201eb8:	1ff00593          	li	a1,511
ffffffffc0201ebc:	00005517          	auipc	a0,0x5
ffffffffc0201ec0:	38c50513          	addi	a0,a0,908 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201ec4:	b50fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201ec8:	00005617          	auipc	a2,0x5
ffffffffc0201ecc:	43060613          	addi	a2,a2,1072 # ffffffffc02072f8 <commands+0x980>
ffffffffc0201ed0:	07f00593          	li	a1,127
ffffffffc0201ed4:	00005517          	auipc	a0,0x5
ffffffffc0201ed8:	37450513          	addi	a0,a0,884 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201edc:	b38fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ee0:	00006697          	auipc	a3,0x6
ffffffffc0201ee4:	8b868693          	addi	a3,a3,-1864 # ffffffffc0207798 <commands+0xe20>
ffffffffc0201ee8:	00005617          	auipc	a2,0x5
ffffffffc0201eec:	f1060613          	addi	a2,a2,-240 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201ef0:	23f00593          	li	a1,575
ffffffffc0201ef4:	00005517          	auipc	a0,0x5
ffffffffc0201ef8:	35450513          	addi	a0,a0,852 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201efc:	b18fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201f00:	00005697          	auipc	a3,0x5
ffffffffc0201f04:	72868693          	addi	a3,a3,1832 # ffffffffc0207628 <commands+0xcb0>
ffffffffc0201f08:	00005617          	auipc	a2,0x5
ffffffffc0201f0c:	ef060613          	addi	a2,a2,-272 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201f10:	24b00593          	li	a1,587
ffffffffc0201f14:	00005517          	auipc	a0,0x5
ffffffffc0201f18:	33450513          	addi	a0,a0,820 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201f1c:	af8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201f20:	00005697          	auipc	a3,0x5
ffffffffc0201f24:	55868693          	addi	a3,a3,1368 # ffffffffc0207478 <commands+0xb00>
ffffffffc0201f28:	00005617          	auipc	a2,0x5
ffffffffc0201f2c:	ed060613          	addi	a2,a2,-304 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201f30:	1fd00593          	li	a1,509
ffffffffc0201f34:	00005517          	auipc	a0,0x5
ffffffffc0201f38:	31450513          	addi	a0,a0,788 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201f3c:	ad8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f40:	00005697          	auipc	a3,0x5
ffffffffc0201f44:	52068693          	addi	a3,a3,1312 # ffffffffc0207460 <commands+0xae8>
ffffffffc0201f48:	00005617          	auipc	a2,0x5
ffffffffc0201f4c:	eb060613          	addi	a2,a2,-336 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201f50:	1fc00593          	li	a1,508
ffffffffc0201f54:	00005517          	auipc	a0,0x5
ffffffffc0201f58:	2f450513          	addi	a0,a0,756 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201f5c:	ab8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201f60:	00005697          	auipc	a3,0x5
ffffffffc0201f64:	45068693          	addi	a3,a3,1104 # ffffffffc02073b0 <commands+0xa38>
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	e9060613          	addi	a2,a2,-368 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201f70:	1f400593          	li	a1,500
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	2d450513          	addi	a0,a0,724 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201f7c:	a98fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201f80:	00005697          	auipc	a3,0x5
ffffffffc0201f84:	48868693          	addi	a3,a3,1160 # ffffffffc0207408 <commands+0xa90>
ffffffffc0201f88:	00005617          	auipc	a2,0x5
ffffffffc0201f8c:	e7060613          	addi	a2,a2,-400 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201f90:	1fb00593          	li	a1,507
ffffffffc0201f94:	00005517          	auipc	a0,0x5
ffffffffc0201f98:	2b450513          	addi	a0,a0,692 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201f9c:	a78fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201fa0:	00005697          	auipc	a3,0x5
ffffffffc0201fa4:	43868693          	addi	a3,a3,1080 # ffffffffc02073d8 <commands+0xa60>
ffffffffc0201fa8:	00005617          	auipc	a2,0x5
ffffffffc0201fac:	e5060613          	addi	a2,a2,-432 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201fb0:	1f800593          	li	a1,504
ffffffffc0201fb4:	00005517          	auipc	a0,0x5
ffffffffc0201fb8:	29450513          	addi	a0,a0,660 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201fbc:	a58fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201fc0:	00005697          	auipc	a3,0x5
ffffffffc0201fc4:	5f868693          	addi	a3,a3,1528 # ffffffffc02075b8 <commands+0xc40>
ffffffffc0201fc8:	00005617          	auipc	a2,0x5
ffffffffc0201fcc:	e3060613          	addi	a2,a2,-464 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201fd0:	21400593          	li	a1,532
ffffffffc0201fd4:	00005517          	auipc	a0,0x5
ffffffffc0201fd8:	27450513          	addi	a0,a0,628 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201fdc:	a38fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201fe0:	00005697          	auipc	a3,0x5
ffffffffc0201fe4:	49868693          	addi	a3,a3,1176 # ffffffffc0207478 <commands+0xb00>
ffffffffc0201fe8:	00005617          	auipc	a2,0x5
ffffffffc0201fec:	e1060613          	addi	a2,a2,-496 # ffffffffc0206df8 <commands+0x480>
ffffffffc0201ff0:	21300593          	li	a1,531
ffffffffc0201ff4:	00005517          	auipc	a0,0x5
ffffffffc0201ff8:	25450513          	addi	a0,a0,596 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0201ffc:	a18fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202000:	00005697          	auipc	a3,0x5
ffffffffc0202004:	5d068693          	addi	a3,a3,1488 # ffffffffc02075d0 <commands+0xc58>
ffffffffc0202008:	00005617          	auipc	a2,0x5
ffffffffc020200c:	df060613          	addi	a2,a2,-528 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202010:	21000593          	li	a1,528
ffffffffc0202014:	00005517          	auipc	a0,0x5
ffffffffc0202018:	23450513          	addi	a0,a0,564 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020201c:	9f8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202020:	00005697          	auipc	a3,0x5
ffffffffc0202024:	7b068693          	addi	a3,a3,1968 # ffffffffc02077d0 <commands+0xe58>
ffffffffc0202028:	00005617          	auipc	a2,0x5
ffffffffc020202c:	dd060613          	addi	a2,a2,-560 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202030:	24200593          	li	a1,578
ffffffffc0202034:	00005517          	auipc	a0,0x5
ffffffffc0202038:	21450513          	addi	a0,a0,532 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020203c:	9d8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202040:	00005697          	auipc	a3,0x5
ffffffffc0202044:	5e868693          	addi	a3,a3,1512 # ffffffffc0207628 <commands+0xcb0>
ffffffffc0202048:	00005617          	auipc	a2,0x5
ffffffffc020204c:	db060613          	addi	a2,a2,-592 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202050:	22200593          	li	a1,546
ffffffffc0202054:	00005517          	auipc	a0,0x5
ffffffffc0202058:	1f450513          	addi	a0,a0,500 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020205c:	9b8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202060:	00005697          	auipc	a3,0x5
ffffffffc0202064:	66068693          	addi	a3,a3,1632 # ffffffffc02076c0 <commands+0xd48>
ffffffffc0202068:	00005617          	auipc	a2,0x5
ffffffffc020206c:	d9060613          	addi	a2,a2,-624 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202070:	23400593          	li	a1,564
ffffffffc0202074:	00005517          	auipc	a0,0x5
ffffffffc0202078:	1d450513          	addi	a0,a0,468 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020207c:	998fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202080:	00005697          	auipc	a3,0x5
ffffffffc0202084:	2d868693          	addi	a3,a3,728 # ffffffffc0207358 <commands+0x9e0>
ffffffffc0202088:	00005617          	auipc	a2,0x5
ffffffffc020208c:	d7060613          	addi	a2,a2,-656 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202090:	1f200593          	li	a1,498
ffffffffc0202094:	00005517          	auipc	a0,0x5
ffffffffc0202098:	1b450513          	addi	a0,a0,436 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020209c:	978fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	25860613          	addi	a2,a2,600 # ffffffffc02072f8 <commands+0x980>
ffffffffc02020a8:	0c100593          	li	a1,193
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	19c50513          	addi	a0,a0,412 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02020b4:	960fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02020b8 <copy_range>:
               bool share) {
ffffffffc02020b8:	7119                	addi	sp,sp,-128
ffffffffc02020ba:	f0ca                	sd	s2,96(sp)
ffffffffc02020bc:	8936                	mv	s2,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020be:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc02020c0:	fc86                	sd	ra,120(sp)
ffffffffc02020c2:	f8a2                	sd	s0,112(sp)
ffffffffc02020c4:	f4a6                	sd	s1,104(sp)
ffffffffc02020c6:	ecce                	sd	s3,88(sp)
ffffffffc02020c8:	e8d2                	sd	s4,80(sp)
ffffffffc02020ca:	e4d6                	sd	s5,72(sp)
ffffffffc02020cc:	e0da                	sd	s6,64(sp)
ffffffffc02020ce:	fc5e                	sd	s7,56(sp)
ffffffffc02020d0:	f862                	sd	s8,48(sp)
ffffffffc02020d2:	f466                	sd	s9,40(sp)
ffffffffc02020d4:	f06a                	sd	s10,32(sp)
ffffffffc02020d6:	ec6e                	sd	s11,24(sp)
ffffffffc02020d8:	e03a                	sd	a4,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020da:	03469793          	slli	a5,a3,0x34
ffffffffc02020de:	26079563          	bnez	a5,ffffffffc0202348 <copy_range+0x290>
    assert(USER_ACCESS(start, end));
ffffffffc02020e2:	00200737          	lui	a4,0x200
ffffffffc02020e6:	8db2                	mv	s11,a2
ffffffffc02020e8:	22e66463          	bltu	a2,a4,ffffffffc0202310 <copy_range+0x258>
ffffffffc02020ec:	23267263          	bgeu	a2,s2,ffffffffc0202310 <copy_range+0x258>
ffffffffc02020f0:	4705                	li	a4,1
ffffffffc02020f2:	077e                	slli	a4,a4,0x1f
ffffffffc02020f4:	21276e63          	bltu	a4,s2,ffffffffc0202310 <copy_range+0x258>
ffffffffc02020f8:	5afd                	li	s5,-1
ffffffffc02020fa:	8b2a                	mv	s6,a0
ffffffffc02020fc:	84ae                	mv	s1,a1
        start += PGSIZE;
ffffffffc02020fe:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202100:	000aac97          	auipc	s9,0xaa
ffffffffc0202104:	720c8c93          	addi	s9,s9,1824 # ffffffffc02ac820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202108:	000aac17          	auipc	s8,0xaa
ffffffffc020210c:	780c0c13          	addi	s8,s8,1920 # ffffffffc02ac888 <pages>
    return page - pages + nbase;
ffffffffc0202110:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc0202114:	00cada93          	srli	s5,s5,0xc
ffffffffc0202118:	000aad17          	auipc	s10,0xaa
ffffffffc020211c:	760d0d13          	addi	s10,s10,1888 # ffffffffc02ac878 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202120:	4601                	li	a2,0
ffffffffc0202122:	85ee                	mv	a1,s11
ffffffffc0202124:	8526                	mv	a0,s1
ffffffffc0202126:	e43fe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc020212a:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc020212c:	c179                	beqz	a0,ffffffffc02021f2 <copy_range+0x13a>
        if (*ptep & PTE_V) {
ffffffffc020212e:	6118                	ld	a4,0(a0)
ffffffffc0202130:	8b05                	andi	a4,a4,1
ffffffffc0202132:	e705                	bnez	a4,ffffffffc020215a <copy_range+0xa2>
        start += PGSIZE;
ffffffffc0202134:	9dd2                	add	s11,s11,s4
    } while (start != 0 && start < end);
ffffffffc0202136:	ff2de5e3          	bltu	s11,s2,ffffffffc0202120 <copy_range+0x68>
    return 0;
ffffffffc020213a:	4501                	li	a0,0
}
ffffffffc020213c:	70e6                	ld	ra,120(sp)
ffffffffc020213e:	7446                	ld	s0,112(sp)
ffffffffc0202140:	74a6                	ld	s1,104(sp)
ffffffffc0202142:	7906                	ld	s2,96(sp)
ffffffffc0202144:	69e6                	ld	s3,88(sp)
ffffffffc0202146:	6a46                	ld	s4,80(sp)
ffffffffc0202148:	6aa6                	ld	s5,72(sp)
ffffffffc020214a:	6b06                	ld	s6,64(sp)
ffffffffc020214c:	7be2                	ld	s7,56(sp)
ffffffffc020214e:	7c42                	ld	s8,48(sp)
ffffffffc0202150:	7ca2                	ld	s9,40(sp)
ffffffffc0202152:	7d02                	ld	s10,32(sp)
ffffffffc0202154:	6de2                	ld	s11,24(sp)
ffffffffc0202156:	6109                	addi	sp,sp,128
ffffffffc0202158:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020215a:	4605                	li	a2,1
ffffffffc020215c:	85ee                	mv	a1,s11
ffffffffc020215e:	855a                	mv	a0,s6
ffffffffc0202160:	e09fe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0202164:	12050b63          	beqz	a0,ffffffffc020229a <copy_range+0x1e2>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202168:	6018                	ld	a4,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc020216a:	00177693          	andi	a3,a4,1
ffffffffc020216e:	0007099b          	sext.w	s3,a4
ffffffffc0202172:	16068363          	beqz	a3,ffffffffc02022d8 <copy_range+0x220>
    if (PPN(pa) >= npage) {
ffffffffc0202176:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020217a:	070a                	slli	a4,a4,0x2
ffffffffc020217c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020217e:	1ad77963          	bgeu	a4,a3,ffffffffc0202330 <copy_range+0x278>
    return &pages[PPN(pa) - nbase];
ffffffffc0202182:	fff807b7          	lui	a5,0xfff80
ffffffffc0202186:	973e                	add	a4,a4,a5
ffffffffc0202188:	000c3403          	ld	s0,0(s8)
            if(share){ // COW机制启用
ffffffffc020218c:	6782                	ld	a5,0(sp)
ffffffffc020218e:	071a                	slli	a4,a4,0x6
ffffffffc0202190:	943a                	add	s0,s0,a4
ffffffffc0202192:	cfad                	beqz	a5,ffffffffc020220c <copy_range+0x154>
    return page - pages + nbase;
ffffffffc0202194:	8719                	srai	a4,a4,0x6
ffffffffc0202196:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc0202198:	01577633          	and	a2,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc020219c:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc020219e:	10d67063          	bgeu	a2,a3,ffffffffc020229e <copy_range+0x1e6>
ffffffffc02021a2:	000d3583          	ld	a1,0(s10)
                cprintf("COW sharing page at addr %x\n", page2kva(page));
ffffffffc02021a6:	00005517          	auipc	a0,0x5
ffffffffc02021aa:	00a50513          	addi	a0,a0,10 # ffffffffc02071b0 <commands+0x838>
                page_insert(from, page, start, perm & ~PTE_W); // 将父进程的页面设为只读
ffffffffc02021ae:	01b9f993          	andi	s3,s3,27
                cprintf("COW sharing page at addr %x\n", page2kva(page));
ffffffffc02021b2:	95ba                	add	a1,a1,a4
ffffffffc02021b4:	f1dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                page_insert(from, page, start, perm & ~PTE_W); // 将父进程的页面设为只读
ffffffffc02021b8:	86ce                	mv	a3,s3
ffffffffc02021ba:	866e                	mv	a2,s11
ffffffffc02021bc:	85a2                	mv	a1,s0
ffffffffc02021be:	8526                	mv	a0,s1
ffffffffc02021c0:	bb4ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
                ret = page_insert(to, page, start, perm & ~PTE_W); // 把父进程中的页面插入子进程的页表中，即子进程中共享了父进程中的页面（只读）
ffffffffc02021c4:	86ce                	mv	a3,s3
ffffffffc02021c6:	866e                	mv	a2,s11
ffffffffc02021c8:	85a2                	mv	a1,s0
ffffffffc02021ca:	855a                	mv	a0,s6
ffffffffc02021cc:	ba8ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
            assert(ret == 0);
ffffffffc02021d0:	d135                	beqz	a0,ffffffffc0202134 <copy_range+0x7c>
ffffffffc02021d2:	00005697          	auipc	a3,0x5
ffffffffc02021d6:	03e68693          	addi	a3,a3,62 # ffffffffc0207210 <commands+0x898>
ffffffffc02021da:	00005617          	auipc	a2,0x5
ffffffffc02021de:	c1e60613          	addi	a2,a2,-994 # ffffffffc0206df8 <commands+0x480>
ffffffffc02021e2:	19400593          	li	a1,404
ffffffffc02021e6:	00005517          	auipc	a0,0x5
ffffffffc02021ea:	06250513          	addi	a0,a0,98 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02021ee:	826fe0ef          	jal	ra,ffffffffc0200214 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021f2:	00200737          	lui	a4,0x200
ffffffffc02021f6:	00ed87b3          	add	a5,s11,a4
ffffffffc02021fa:	ffe00737          	lui	a4,0xffe00
ffffffffc02021fe:	00e7fdb3          	and	s11,a5,a4
    } while (start != 0 && start < end);
ffffffffc0202202:	f20d8ce3          	beqz	s11,ffffffffc020213a <copy_range+0x82>
ffffffffc0202206:	f12dede3          	bltu	s11,s2,ffffffffc0202120 <copy_range+0x68>
ffffffffc020220a:	bf05                	j	ffffffffc020213a <copy_range+0x82>
                struct Page *npage = alloc_page();
ffffffffc020220c:	4505                	li	a0,1
ffffffffc020220e:	c4dfe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
                assert(page != NULL);
ffffffffc0202212:	c05d                	beqz	s0,ffffffffc02022b8 <copy_range+0x200>
                assert(npage != NULL);
ffffffffc0202214:	cd71                	beqz	a0,ffffffffc02022f0 <copy_range+0x238>
    return page - pages + nbase;
ffffffffc0202216:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc020221a:	000cb703          	ld	a4,0(s9)
    return page - pages + nbase;
ffffffffc020221e:	40d506b3          	sub	a3,a0,a3
ffffffffc0202222:	8699                	srai	a3,a3,0x6
ffffffffc0202224:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0202226:	0156f633          	and	a2,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc020222a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020222c:	06e67a63          	bgeu	a2,a4,ffffffffc02022a0 <copy_range+0x1e8>
ffffffffc0202230:	000d3583          	ld	a1,0(s10)
ffffffffc0202234:	e42a                	sd	a0,8(sp)
                cprintf("alloc a new page at addr %x\n", page2kva(npage));
ffffffffc0202236:	00005517          	auipc	a0,0x5
ffffffffc020223a:	fba50513          	addi	a0,a0,-70 # ffffffffc02071f0 <commands+0x878>
ffffffffc020223e:	95b6                	add	a1,a1,a3
ffffffffc0202240:	e91fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return page - pages + nbase;
ffffffffc0202244:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc0202248:	000cb603          	ld	a2,0(s9)
ffffffffc020224c:	6822                	ld	a6,8(sp)
    return page - pages + nbase;
ffffffffc020224e:	40e406b3          	sub	a3,s0,a4
ffffffffc0202252:	8699                	srai	a3,a3,0x6
ffffffffc0202254:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0202256:	0156f5b3          	and	a1,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc020225a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020225c:	04c5f263          	bgeu	a1,a2,ffffffffc02022a0 <copy_range+0x1e8>
    return page - pages + nbase;
ffffffffc0202260:	40e80733          	sub	a4,a6,a4
    return KADDR(page2pa(page));
ffffffffc0202264:	000d3503          	ld	a0,0(s10)
    return page - pages + nbase;
ffffffffc0202268:	8719                	srai	a4,a4,0x6
ffffffffc020226a:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc020226c:	015778b3          	and	a7,a4,s5
ffffffffc0202270:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202274:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0202276:	02c8f463          	bgeu	a7,a2,ffffffffc020229e <copy_range+0x1e6>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE); // 复制附近成的页面内容到子进程的页面中
ffffffffc020227a:	6605                	lui	a2,0x1
ffffffffc020227c:	953a                	add	a0,a0,a4
ffffffffc020227e:	e442                	sd	a6,8(sp)
ffffffffc0202280:	16a040ef          	jal	ra,ffffffffc02063ea <memcpy>
                ret = page_insert(to, npage, start, perm); // 建立子进程页面虚拟地址到物理地址的映射关系
ffffffffc0202284:	6822                	ld	a6,8(sp)
ffffffffc0202286:	01f9f693          	andi	a3,s3,31
ffffffffc020228a:	866e                	mv	a2,s11
ffffffffc020228c:	85c2                	mv	a1,a6
ffffffffc020228e:	855a                	mv	a0,s6
ffffffffc0202290:	ae4ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
            assert(ret == 0);
ffffffffc0202294:	ea0500e3          	beqz	a0,ffffffffc0202134 <copy_range+0x7c>
ffffffffc0202298:	bf2d                	j	ffffffffc02021d2 <copy_range+0x11a>
                return -E_NO_MEM;
ffffffffc020229a:	5571                	li	a0,-4
ffffffffc020229c:	b545                	j	ffffffffc020213c <copy_range+0x84>
ffffffffc020229e:	86ba                	mv	a3,a4
ffffffffc02022a0:	00005617          	auipc	a2,0x5
ffffffffc02022a4:	f8060613          	addi	a2,a2,-128 # ffffffffc0207220 <commands+0x8a8>
ffffffffc02022a8:	06900593          	li	a1,105
ffffffffc02022ac:	00005517          	auipc	a0,0x5
ffffffffc02022b0:	fcc50513          	addi	a0,a0,-52 # ffffffffc0207278 <commands+0x900>
ffffffffc02022b4:	f61fd0ef          	jal	ra,ffffffffc0200214 <__panic>
                assert(page != NULL);
ffffffffc02022b8:	00005697          	auipc	a3,0x5
ffffffffc02022bc:	f1868693          	addi	a3,a3,-232 # ffffffffc02071d0 <commands+0x858>
ffffffffc02022c0:	00005617          	auipc	a2,0x5
ffffffffc02022c4:	b3860613          	addi	a2,a2,-1224 # ffffffffc0206df8 <commands+0x480>
ffffffffc02022c8:	17900593          	li	a1,377
ffffffffc02022cc:	00005517          	auipc	a0,0x5
ffffffffc02022d0:	f7c50513          	addi	a0,a0,-132 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02022d4:	f41fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02022d8:	00005617          	auipc	a2,0x5
ffffffffc02022dc:	16060613          	addi	a2,a2,352 # ffffffffc0207438 <commands+0xac0>
ffffffffc02022e0:	07400593          	li	a1,116
ffffffffc02022e4:	00005517          	auipc	a0,0x5
ffffffffc02022e8:	f9450513          	addi	a0,a0,-108 # ffffffffc0207278 <commands+0x900>
ffffffffc02022ec:	f29fd0ef          	jal	ra,ffffffffc0200214 <__panic>
                assert(npage != NULL);
ffffffffc02022f0:	00005697          	auipc	a3,0x5
ffffffffc02022f4:	ef068693          	addi	a3,a3,-272 # ffffffffc02071e0 <commands+0x868>
ffffffffc02022f8:	00005617          	auipc	a2,0x5
ffffffffc02022fc:	b0060613          	addi	a2,a2,-1280 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202300:	17a00593          	li	a1,378
ffffffffc0202304:	00005517          	auipc	a0,0x5
ffffffffc0202308:	f4450513          	addi	a0,a0,-188 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020230c:	f09fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202310:	00005697          	auipc	a3,0x5
ffffffffc0202314:	53868693          	addi	a3,a3,1336 # ffffffffc0207848 <commands+0xed0>
ffffffffc0202318:	00005617          	auipc	a2,0x5
ffffffffc020231c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202320:	15e00593          	li	a1,350
ffffffffc0202324:	00005517          	auipc	a0,0x5
ffffffffc0202328:	f2450513          	addi	a0,a0,-220 # ffffffffc0207248 <commands+0x8d0>
ffffffffc020232c:	ee9fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202330:	00005617          	auipc	a2,0x5
ffffffffc0202334:	f2860613          	addi	a2,a2,-216 # ffffffffc0207258 <commands+0x8e0>
ffffffffc0202338:	06200593          	li	a1,98
ffffffffc020233c:	00005517          	auipc	a0,0x5
ffffffffc0202340:	f3c50513          	addi	a0,a0,-196 # ffffffffc0207278 <commands+0x900>
ffffffffc0202344:	ed1fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202348:	00005697          	auipc	a3,0x5
ffffffffc020234c:	4d068693          	addi	a3,a3,1232 # ffffffffc0207818 <commands+0xea0>
ffffffffc0202350:	00005617          	auipc	a2,0x5
ffffffffc0202354:	aa860613          	addi	a2,a2,-1368 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202358:	15d00593          	li	a1,349
ffffffffc020235c:	00005517          	auipc	a0,0x5
ffffffffc0202360:	eec50513          	addi	a0,a0,-276 # ffffffffc0207248 <commands+0x8d0>
ffffffffc0202364:	eb1fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202368 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202368:	12058073          	sfence.vma	a1
}
ffffffffc020236c:	8082                	ret

ffffffffc020236e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020236e:	7179                	addi	sp,sp,-48
ffffffffc0202370:	e84a                	sd	s2,16(sp)
ffffffffc0202372:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202374:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202376:	f022                	sd	s0,32(sp)
ffffffffc0202378:	ec26                	sd	s1,24(sp)
ffffffffc020237a:	e44e                	sd	s3,8(sp)
ffffffffc020237c:	f406                	sd	ra,40(sp)
ffffffffc020237e:	84ae                	mv	s1,a1
ffffffffc0202380:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202382:	ad9fe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0202386:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202388:	cd1d                	beqz	a0,ffffffffc02023c6 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020238a:	85aa                	mv	a1,a0
ffffffffc020238c:	86ce                	mv	a3,s3
ffffffffc020238e:	8626                	mv	a2,s1
ffffffffc0202390:	854a                	mv	a0,s2
ffffffffc0202392:	9e2ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0202396:	e121                	bnez	a0,ffffffffc02023d6 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0202398:	000aa797          	auipc	a5,0xaa
ffffffffc020239c:	4a878793          	addi	a5,a5,1192 # ffffffffc02ac840 <swap_init_ok>
ffffffffc02023a0:	439c                	lw	a5,0(a5)
ffffffffc02023a2:	2781                	sext.w	a5,a5
ffffffffc02023a4:	c38d                	beqz	a5,ffffffffc02023c6 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02023a6:	000aa797          	auipc	a5,0xaa
ffffffffc02023aa:	4ea78793          	addi	a5,a5,1258 # ffffffffc02ac890 <check_mm_struct>
ffffffffc02023ae:	6388                	ld	a0,0(a5)
ffffffffc02023b0:	c919                	beqz	a0,ffffffffc02023c6 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02023b2:	4681                	li	a3,0
ffffffffc02023b4:	8622                	mv	a2,s0
ffffffffc02023b6:	85a6                	mv	a1,s1
ffffffffc02023b8:	09d010ef          	jal	ra,ffffffffc0203c54 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02023bc:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02023be:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02023c0:	4785                	li	a5,1
ffffffffc02023c2:	02f71063          	bne	a4,a5,ffffffffc02023e2 <pgdir_alloc_page+0x74>
}
ffffffffc02023c6:	8522                	mv	a0,s0
ffffffffc02023c8:	70a2                	ld	ra,40(sp)
ffffffffc02023ca:	7402                	ld	s0,32(sp)
ffffffffc02023cc:	64e2                	ld	s1,24(sp)
ffffffffc02023ce:	6942                	ld	s2,16(sp)
ffffffffc02023d0:	69a2                	ld	s3,8(sp)
ffffffffc02023d2:	6145                	addi	sp,sp,48
ffffffffc02023d4:	8082                	ret
            free_page(page);
ffffffffc02023d6:	8522                	mv	a0,s0
ffffffffc02023d8:	4585                	li	a1,1
ffffffffc02023da:	b09fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
            return NULL;
ffffffffc02023de:	4401                	li	s0,0
ffffffffc02023e0:	b7dd                	j	ffffffffc02023c6 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc02023e2:	00005697          	auipc	a3,0x5
ffffffffc02023e6:	ea668693          	addi	a3,a3,-346 # ffffffffc0207288 <commands+0x910>
ffffffffc02023ea:	00005617          	auipc	a2,0x5
ffffffffc02023ee:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206df8 <commands+0x480>
ffffffffc02023f2:	1d300593          	li	a1,467
ffffffffc02023f6:	00005517          	auipc	a0,0x5
ffffffffc02023fa:	e5250513          	addi	a0,a0,-430 # ffffffffc0207248 <commands+0x8d0>
ffffffffc02023fe:	e17fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202402 <check_vma_overlap.isra.1.part.2>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202402:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202404:	00005697          	auipc	a3,0x5
ffffffffc0202408:	45c68693          	addi	a3,a3,1116 # ffffffffc0207860 <commands+0xee8>
ffffffffc020240c:	00005617          	auipc	a2,0x5
ffffffffc0202410:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202414:	06d00593          	li	a1,109
ffffffffc0202418:	00005517          	auipc	a0,0x5
ffffffffc020241c:	46850513          	addi	a0,a0,1128 # ffffffffc0207880 <commands+0xf08>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202420:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0202422:	df3fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202426 <pa2page.part.3>:
pa2page(uintptr_t pa) {
ffffffffc0202426:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202428:	00005617          	auipc	a2,0x5
ffffffffc020242c:	e3060613          	addi	a2,a2,-464 # ffffffffc0207258 <commands+0x8e0>
ffffffffc0202430:	06200593          	li	a1,98
ffffffffc0202434:	00005517          	auipc	a0,0x5
ffffffffc0202438:	e4450513          	addi	a0,a0,-444 # ffffffffc0207278 <commands+0x900>
pa2page(uintptr_t pa) {
ffffffffc020243c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020243e:	dd7fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202442 <mm_create>:
mm_create(void) {
ffffffffc0202442:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202444:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0202448:	e022                	sd	s0,0(sp)
ffffffffc020244a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020244c:	699000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc0202450:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202452:	c515                	beqz	a0,ffffffffc020247e <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202454:	000aa797          	auipc	a5,0xaa
ffffffffc0202458:	3ec78793          	addi	a5,a5,1004 # ffffffffc02ac840 <swap_init_ok>
ffffffffc020245c:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020245e:	e408                	sd	a0,8(s0)
ffffffffc0202460:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0202462:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202466:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020246a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020246e:	2781                	sext.w	a5,a5
ffffffffc0202470:	ef81                	bnez	a5,ffffffffc0202488 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0202472:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0202476:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020247a:	02043c23          	sd	zero,56(s0)
}
ffffffffc020247e:	8522                	mv	a0,s0
ffffffffc0202480:	60a2                	ld	ra,8(sp)
ffffffffc0202482:	6402                	ld	s0,0(sp)
ffffffffc0202484:	0141                	addi	sp,sp,16
ffffffffc0202486:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202488:	7bc010ef          	jal	ra,ffffffffc0203c44 <swap_init_mm>
ffffffffc020248c:	b7ed                	j	ffffffffc0202476 <mm_create+0x34>

ffffffffc020248e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020248e:	1101                	addi	sp,sp,-32
ffffffffc0202490:	e04a                	sd	s2,0(sp)
ffffffffc0202492:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202494:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202498:	e822                	sd	s0,16(sp)
ffffffffc020249a:	e426                	sd	s1,8(sp)
ffffffffc020249c:	ec06                	sd	ra,24(sp)
ffffffffc020249e:	84ae                	mv	s1,a1
ffffffffc02024a0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02024a2:	643000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
    if (vma != NULL) {
ffffffffc02024a6:	c509                	beqz	a0,ffffffffc02024b0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02024a8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02024ac:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02024ae:	cd00                	sw	s0,24(a0)
}
ffffffffc02024b0:	60e2                	ld	ra,24(sp)
ffffffffc02024b2:	6442                	ld	s0,16(sp)
ffffffffc02024b4:	64a2                	ld	s1,8(sp)
ffffffffc02024b6:	6902                	ld	s2,0(sp)
ffffffffc02024b8:	6105                	addi	sp,sp,32
ffffffffc02024ba:	8082                	ret

ffffffffc02024bc <find_vma>:
    if (mm != NULL) {
ffffffffc02024bc:	c51d                	beqz	a0,ffffffffc02024ea <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02024be:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02024c0:	c781                	beqz	a5,ffffffffc02024c8 <find_vma+0xc>
ffffffffc02024c2:	6798                	ld	a4,8(a5)
ffffffffc02024c4:	02e5f663          	bgeu	a1,a4,ffffffffc02024f0 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02024c8:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02024ca:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02024cc:	00f50f63          	beq	a0,a5,ffffffffc02024ea <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02024d0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02024d4:	fee5ebe3          	bltu	a1,a4,ffffffffc02024ca <find_vma+0xe>
ffffffffc02024d8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02024dc:	fee5f7e3          	bgeu	a1,a4,ffffffffc02024ca <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02024e0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02024e2:	c781                	beqz	a5,ffffffffc02024ea <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02024e4:	e91c                	sd	a5,16(a0)
}
ffffffffc02024e6:	853e                	mv	a0,a5
ffffffffc02024e8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02024ea:	4781                	li	a5,0
}
ffffffffc02024ec:	853e                	mv	a0,a5
ffffffffc02024ee:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02024f0:	6b98                	ld	a4,16(a5)
ffffffffc02024f2:	fce5fbe3          	bgeu	a1,a4,ffffffffc02024c8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02024f6:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02024f8:	b7fd                	j	ffffffffc02024e6 <find_vma+0x2a>

ffffffffc02024fa <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02024fa:	6590                	ld	a2,8(a1)
ffffffffc02024fc:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202500:	1141                	addi	sp,sp,-16
ffffffffc0202502:	e406                	sd	ra,8(sp)
ffffffffc0202504:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202506:	01066863          	bltu	a2,a6,ffffffffc0202516 <insert_vma_struct+0x1c>
ffffffffc020250a:	a8b9                	j	ffffffffc0202568 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020250c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0202510:	04d66763          	bltu	a2,a3,ffffffffc020255e <insert_vma_struct+0x64>
ffffffffc0202514:	873e                	mv	a4,a5
ffffffffc0202516:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0202518:	fef51ae3          	bne	a0,a5,ffffffffc020250c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020251c:	02a70463          	beq	a4,a0,ffffffffc0202544 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202520:	ff073683          	ld	a3,-16(a4) # ffffffffffdffff0 <end+0x3fb53658>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202524:	fe873883          	ld	a7,-24(a4)
ffffffffc0202528:	08d8f063          	bgeu	a7,a3,ffffffffc02025a8 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020252c:	04d66e63          	bltu	a2,a3,ffffffffc0202588 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0202530:	00f50a63          	beq	a0,a5,ffffffffc0202544 <insert_vma_struct+0x4a>
ffffffffc0202534:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202538:	0506e863          	bltu	a3,a6,ffffffffc0202588 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020253c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202540:	02c6f263          	bgeu	a3,a2,ffffffffc0202564 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0202544:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0202546:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202548:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020254c:	e390                	sd	a2,0(a5)
ffffffffc020254e:	e710                	sd	a2,8(a4)
}
ffffffffc0202550:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202552:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202554:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0202556:	2685                	addiw	a3,a3,1
ffffffffc0202558:	d114                	sw	a3,32(a0)
}
ffffffffc020255a:	0141                	addi	sp,sp,16
ffffffffc020255c:	8082                	ret
    if (le_prev != list) {
ffffffffc020255e:	fca711e3          	bne	a4,a0,ffffffffc0202520 <insert_vma_struct+0x26>
ffffffffc0202562:	bfd9                	j	ffffffffc0202538 <insert_vma_struct+0x3e>
ffffffffc0202564:	e9fff0ef          	jal	ra,ffffffffc0202402 <check_vma_overlap.isra.1.part.2>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202568:	00005697          	auipc	a3,0x5
ffffffffc020256c:	47868693          	addi	a3,a3,1144 # ffffffffc02079e0 <commands+0x1068>
ffffffffc0202570:	00005617          	auipc	a2,0x5
ffffffffc0202574:	88860613          	addi	a2,a2,-1912 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202578:	07400593          	li	a1,116
ffffffffc020257c:	00005517          	auipc	a0,0x5
ffffffffc0202580:	30450513          	addi	a0,a0,772 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202584:	c91fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202588:	00005697          	auipc	a3,0x5
ffffffffc020258c:	49868693          	addi	a3,a3,1176 # ffffffffc0207a20 <commands+0x10a8>
ffffffffc0202590:	00005617          	auipc	a2,0x5
ffffffffc0202594:	86860613          	addi	a2,a2,-1944 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202598:	06c00593          	li	a1,108
ffffffffc020259c:	00005517          	auipc	a0,0x5
ffffffffc02025a0:	2e450513          	addi	a0,a0,740 # ffffffffc0207880 <commands+0xf08>
ffffffffc02025a4:	c71fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02025a8:	00005697          	auipc	a3,0x5
ffffffffc02025ac:	45868693          	addi	a3,a3,1112 # ffffffffc0207a00 <commands+0x1088>
ffffffffc02025b0:	00005617          	auipc	a2,0x5
ffffffffc02025b4:	84860613          	addi	a2,a2,-1976 # ffffffffc0206df8 <commands+0x480>
ffffffffc02025b8:	06b00593          	li	a1,107
ffffffffc02025bc:	00005517          	auipc	a0,0x5
ffffffffc02025c0:	2c450513          	addi	a0,a0,708 # ffffffffc0207880 <commands+0xf08>
ffffffffc02025c4:	c51fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02025c8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02025c8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02025ca:	1141                	addi	sp,sp,-16
ffffffffc02025cc:	e406                	sd	ra,8(sp)
ffffffffc02025ce:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02025d0:	e78d                	bnez	a5,ffffffffc02025fa <mm_destroy+0x32>
ffffffffc02025d2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02025d4:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02025d6:	00a40c63          	beq	s0,a0,ffffffffc02025ee <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02025da:	6118                	ld	a4,0(a0)
ffffffffc02025dc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02025de:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02025e0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025e2:	e398                	sd	a4,0(a5)
ffffffffc02025e4:	5bd000ef          	jal	ra,ffffffffc02033a0 <kfree>
    return listelm->next;
ffffffffc02025e8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02025ea:	fea418e3          	bne	s0,a0,ffffffffc02025da <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02025ee:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02025f0:	6402                	ld	s0,0(sp)
ffffffffc02025f2:	60a2                	ld	ra,8(sp)
ffffffffc02025f4:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02025f6:	5ab0006f          	j	ffffffffc02033a0 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02025fa:	00005697          	auipc	a3,0x5
ffffffffc02025fe:	44668693          	addi	a3,a3,1094 # ffffffffc0207a40 <commands+0x10c8>
ffffffffc0202602:	00004617          	auipc	a2,0x4
ffffffffc0202606:	7f660613          	addi	a2,a2,2038 # ffffffffc0206df8 <commands+0x480>
ffffffffc020260a:	09400593          	li	a1,148
ffffffffc020260e:	00005517          	auipc	a0,0x5
ffffffffc0202612:	27250513          	addi	a0,a0,626 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202616:	bfffd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020261a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020261a:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc020261c:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020261e:	17fd                	addi	a5,a5,-1
ffffffffc0202620:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0202622:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202624:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0202628:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020262a:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc020262c:	fc06                	sd	ra,56(sp)
ffffffffc020262e:	f04a                	sd	s2,32(sp)
ffffffffc0202630:	ec4e                	sd	s3,24(sp)
ffffffffc0202632:	e852                	sd	s4,16(sp)
ffffffffc0202634:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202636:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc020263a:	002007b7          	lui	a5,0x200
ffffffffc020263e:	01047433          	and	s0,s0,a6
ffffffffc0202642:	06f4e363          	bltu	s1,a5,ffffffffc02026a8 <mm_map+0x8e>
ffffffffc0202646:	0684f163          	bgeu	s1,s0,ffffffffc02026a8 <mm_map+0x8e>
ffffffffc020264a:	4785                	li	a5,1
ffffffffc020264c:	07fe                	slli	a5,a5,0x1f
ffffffffc020264e:	0487ed63          	bltu	a5,s0,ffffffffc02026a8 <mm_map+0x8e>
ffffffffc0202652:	89aa                	mv	s3,a0
ffffffffc0202654:	8a3a                	mv	s4,a4
ffffffffc0202656:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202658:	c931                	beqz	a0,ffffffffc02026ac <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020265a:	85a6                	mv	a1,s1
ffffffffc020265c:	e61ff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc0202660:	c501                	beqz	a0,ffffffffc0202668 <mm_map+0x4e>
ffffffffc0202662:	651c                	ld	a5,8(a0)
ffffffffc0202664:	0487e263          	bltu	a5,s0,ffffffffc02026a8 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202668:	03000513          	li	a0,48
ffffffffc020266c:	479000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc0202670:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202672:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202674:	02090163          	beqz	s2,ffffffffc0202696 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202678:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020267a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020267e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202682:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202686:	85ca                	mv	a1,s2
ffffffffc0202688:	e73ff0ef          	jal	ra,ffffffffc02024fa <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020268c:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020268e:	000a0463          	beqz	s4,ffffffffc0202696 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0202692:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>

out:
    return ret;
}
ffffffffc0202696:	70e2                	ld	ra,56(sp)
ffffffffc0202698:	7442                	ld	s0,48(sp)
ffffffffc020269a:	74a2                	ld	s1,40(sp)
ffffffffc020269c:	7902                	ld	s2,32(sp)
ffffffffc020269e:	69e2                	ld	s3,24(sp)
ffffffffc02026a0:	6a42                	ld	s4,16(sp)
ffffffffc02026a2:	6aa2                	ld	s5,8(sp)
ffffffffc02026a4:	6121                	addi	sp,sp,64
ffffffffc02026a6:	8082                	ret
        return -E_INVAL;
ffffffffc02026a8:	5575                	li	a0,-3
ffffffffc02026aa:	b7f5                	j	ffffffffc0202696 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02026ac:	00005697          	auipc	a3,0x5
ffffffffc02026b0:	3ac68693          	addi	a3,a3,940 # ffffffffc0207a58 <commands+0x10e0>
ffffffffc02026b4:	00004617          	auipc	a2,0x4
ffffffffc02026b8:	74460613          	addi	a2,a2,1860 # ffffffffc0206df8 <commands+0x480>
ffffffffc02026bc:	0a700593          	li	a1,167
ffffffffc02026c0:	00005517          	auipc	a0,0x5
ffffffffc02026c4:	1c050513          	addi	a0,a0,448 # ffffffffc0207880 <commands+0xf08>
ffffffffc02026c8:	b4dfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02026cc <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02026cc:	7139                	addi	sp,sp,-64
ffffffffc02026ce:	fc06                	sd	ra,56(sp)
ffffffffc02026d0:	f822                	sd	s0,48(sp)
ffffffffc02026d2:	f426                	sd	s1,40(sp)
ffffffffc02026d4:	f04a                	sd	s2,32(sp)
ffffffffc02026d6:	ec4e                	sd	s3,24(sp)
ffffffffc02026d8:	e852                	sd	s4,16(sp)
ffffffffc02026da:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02026dc:	c535                	beqz	a0,ffffffffc0202748 <dup_mmap+0x7c>
ffffffffc02026de:	892a                	mv	s2,a0
ffffffffc02026e0:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02026e2:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02026e4:	e59d                	bnez	a1,ffffffffc0202712 <dup_mmap+0x46>
ffffffffc02026e6:	a08d                	j	ffffffffc0202748 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02026e8:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02026ea:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5540>
        insert_vma_struct(to, nvma);
ffffffffc02026ee:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02026f0:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02026f4:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02026f8:	e03ff0ef          	jal	ra,ffffffffc02024fa <insert_vma_struct>

        bool share = 0;
        share = 1; // 将该变量设为1则开启COW机制
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02026fc:	ff043683          	ld	a3,-16(s0)
ffffffffc0202700:	fe843603          	ld	a2,-24(s0)
ffffffffc0202704:	6c8c                	ld	a1,24(s1)
ffffffffc0202706:	01893503          	ld	a0,24(s2)
ffffffffc020270a:	4705                	li	a4,1
ffffffffc020270c:	9adff0ef          	jal	ra,ffffffffc02020b8 <copy_range>
ffffffffc0202710:	e105                	bnez	a0,ffffffffc0202730 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0202712:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0202714:	02848863          	beq	s1,s0,ffffffffc0202744 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202718:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020271c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202720:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202724:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202728:	3bd000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc020272c:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc020272e:	fd4d                	bnez	a0,ffffffffc02026e8 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202730:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202732:	70e2                	ld	ra,56(sp)
ffffffffc0202734:	7442                	ld	s0,48(sp)
ffffffffc0202736:	74a2                	ld	s1,40(sp)
ffffffffc0202738:	7902                	ld	s2,32(sp)
ffffffffc020273a:	69e2                	ld	s3,24(sp)
ffffffffc020273c:	6a42                	ld	s4,16(sp)
ffffffffc020273e:	6aa2                	ld	s5,8(sp)
ffffffffc0202740:	6121                	addi	sp,sp,64
ffffffffc0202742:	8082                	ret
    return 0;
ffffffffc0202744:	4501                	li	a0,0
ffffffffc0202746:	b7f5                	j	ffffffffc0202732 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc0202748:	00005697          	auipc	a3,0x5
ffffffffc020274c:	25868693          	addi	a3,a3,600 # ffffffffc02079a0 <commands+0x1028>
ffffffffc0202750:	00004617          	auipc	a2,0x4
ffffffffc0202754:	6a860613          	addi	a2,a2,1704 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202758:	0c000593          	li	a1,192
ffffffffc020275c:	00005517          	auipc	a0,0x5
ffffffffc0202760:	12450513          	addi	a0,a0,292 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202764:	ab1fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202768 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0202768:	1101                	addi	sp,sp,-32
ffffffffc020276a:	ec06                	sd	ra,24(sp)
ffffffffc020276c:	e822                	sd	s0,16(sp)
ffffffffc020276e:	e426                	sd	s1,8(sp)
ffffffffc0202770:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202772:	c531                	beqz	a0,ffffffffc02027be <exit_mmap+0x56>
ffffffffc0202774:	591c                	lw	a5,48(a0)
ffffffffc0202776:	84aa                	mv	s1,a0
ffffffffc0202778:	e3b9                	bnez	a5,ffffffffc02027be <exit_mmap+0x56>
    return listelm->next;
ffffffffc020277a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020277c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202780:	02850663          	beq	a0,s0,ffffffffc02027ac <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202784:	ff043603          	ld	a2,-16(s0)
ffffffffc0202788:	fe843583          	ld	a1,-24(s0)
ffffffffc020278c:	854a                	mv	a0,s2
ffffffffc020278e:	a05fe0ef          	jal	ra,ffffffffc0201192 <unmap_range>
ffffffffc0202792:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202794:	fe8498e3          	bne	s1,s0,ffffffffc0202784 <exit_mmap+0x1c>
ffffffffc0202798:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020279a:	00848c63          	beq	s1,s0,ffffffffc02027b2 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020279e:	ff043603          	ld	a2,-16(s0)
ffffffffc02027a2:	fe843583          	ld	a1,-24(s0)
ffffffffc02027a6:	854a                	mv	a0,s2
ffffffffc02027a8:	b03fe0ef          	jal	ra,ffffffffc02012aa <exit_range>
ffffffffc02027ac:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02027ae:	fe8498e3          	bne	s1,s0,ffffffffc020279e <exit_mmap+0x36>
    }
}
ffffffffc02027b2:	60e2                	ld	ra,24(sp)
ffffffffc02027b4:	6442                	ld	s0,16(sp)
ffffffffc02027b6:	64a2                	ld	s1,8(sp)
ffffffffc02027b8:	6902                	ld	s2,0(sp)
ffffffffc02027ba:	6105                	addi	sp,sp,32
ffffffffc02027bc:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02027be:	00005697          	auipc	a3,0x5
ffffffffc02027c2:	20268693          	addi	a3,a3,514 # ffffffffc02079c0 <commands+0x1048>
ffffffffc02027c6:	00004617          	auipc	a2,0x4
ffffffffc02027ca:	63260613          	addi	a2,a2,1586 # ffffffffc0206df8 <commands+0x480>
ffffffffc02027ce:	0d700593          	li	a1,215
ffffffffc02027d2:	00005517          	auipc	a0,0x5
ffffffffc02027d6:	0ae50513          	addi	a0,a0,174 # ffffffffc0207880 <commands+0xf08>
ffffffffc02027da:	a3bfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02027de <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02027de:	7139                	addi	sp,sp,-64
ffffffffc02027e0:	f822                	sd	s0,48(sp)
ffffffffc02027e2:	f426                	sd	s1,40(sp)
ffffffffc02027e4:	fc06                	sd	ra,56(sp)
ffffffffc02027e6:	f04a                	sd	s2,32(sp)
ffffffffc02027e8:	ec4e                	sd	s3,24(sp)
ffffffffc02027ea:	e852                	sd	s4,16(sp)
ffffffffc02027ec:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02027ee:	c55ff0ef          	jal	ra,ffffffffc0202442 <mm_create>
    assert(mm != NULL);
ffffffffc02027f2:	842a                	mv	s0,a0
ffffffffc02027f4:	03200493          	li	s1,50
ffffffffc02027f8:	e919                	bnez	a0,ffffffffc020280e <vmm_init+0x30>
ffffffffc02027fa:	a93d                	j	ffffffffc0202c38 <vmm_init+0x45a>
        vma->vm_start = vm_start;
ffffffffc02027fc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02027fe:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202800:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202804:	14ed                	addi	s1,s1,-5
ffffffffc0202806:	8522                	mv	a0,s0
ffffffffc0202808:	cf3ff0ef          	jal	ra,ffffffffc02024fa <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020280c:	c88d                	beqz	s1,ffffffffc020283e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020280e:	03000513          	li	a0,48
ffffffffc0202812:	2d3000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc0202816:	85aa                	mv	a1,a0
ffffffffc0202818:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020281c:	f165                	bnez	a0,ffffffffc02027fc <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020281e:	00005697          	auipc	a3,0x5
ffffffffc0202822:	46268693          	addi	a3,a3,1122 # ffffffffc0207c80 <commands+0x1308>
ffffffffc0202826:	00004617          	auipc	a2,0x4
ffffffffc020282a:	5d260613          	addi	a2,a2,1490 # ffffffffc0206df8 <commands+0x480>
ffffffffc020282e:	11400593          	li	a1,276
ffffffffc0202832:	00005517          	auipc	a0,0x5
ffffffffc0202836:	04e50513          	addi	a0,a0,78 # ffffffffc0207880 <commands+0xf08>
ffffffffc020283a:	9dbfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020283e:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202842:	1f900913          	li	s2,505
ffffffffc0202846:	a819                	j	ffffffffc020285c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202848:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020284a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020284c:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202850:	0495                	addi	s1,s1,5
ffffffffc0202852:	8522                	mv	a0,s0
ffffffffc0202854:	ca7ff0ef          	jal	ra,ffffffffc02024fa <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202858:	03248a63          	beq	s1,s2,ffffffffc020288c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020285c:	03000513          	li	a0,48
ffffffffc0202860:	285000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc0202864:	85aa                	mv	a1,a0
ffffffffc0202866:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020286a:	fd79                	bnez	a0,ffffffffc0202848 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020286c:	00005697          	auipc	a3,0x5
ffffffffc0202870:	41468693          	addi	a3,a3,1044 # ffffffffc0207c80 <commands+0x1308>
ffffffffc0202874:	00004617          	auipc	a2,0x4
ffffffffc0202878:	58460613          	addi	a2,a2,1412 # ffffffffc0206df8 <commands+0x480>
ffffffffc020287c:	11a00593          	li	a1,282
ffffffffc0202880:	00005517          	auipc	a0,0x5
ffffffffc0202884:	00050513          	mv	a0,a0
ffffffffc0202888:	98dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc020288c:	6418                	ld	a4,8(s0)
ffffffffc020288e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0202890:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202894:	2ee40063          	beq	s0,a4,ffffffffc0202b74 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202898:	fe873683          	ld	a3,-24(a4)
ffffffffc020289c:	ffe78613          	addi	a2,a5,-2
ffffffffc02028a0:	24d61a63          	bne	a2,a3,ffffffffc0202af4 <vmm_init+0x316>
ffffffffc02028a4:	ff073683          	ld	a3,-16(a4)
ffffffffc02028a8:	24f69663          	bne	a3,a5,ffffffffc0202af4 <vmm_init+0x316>
ffffffffc02028ac:	0795                	addi	a5,a5,5
ffffffffc02028ae:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02028b0:	feb792e3          	bne	a5,a1,ffffffffc0202894 <vmm_init+0xb6>
ffffffffc02028b4:	491d                	li	s2,7
ffffffffc02028b6:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02028b8:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02028bc:	85a6                	mv	a1,s1
ffffffffc02028be:	8522                	mv	a0,s0
ffffffffc02028c0:	bfdff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc02028c4:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02028c6:	30050763          	beqz	a0,ffffffffc0202bd4 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02028ca:	00148593          	addi	a1,s1,1
ffffffffc02028ce:	8522                	mv	a0,s0
ffffffffc02028d0:	bedff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc02028d4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02028d6:	2c050f63          	beqz	a0,ffffffffc0202bb4 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02028da:	85ca                	mv	a1,s2
ffffffffc02028dc:	8522                	mv	a0,s0
ffffffffc02028de:	bdfff0ef          	jal	ra,ffffffffc02024bc <find_vma>
        assert(vma3 == NULL);
ffffffffc02028e2:	2a051963          	bnez	a0,ffffffffc0202b94 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02028e6:	00348593          	addi	a1,s1,3
ffffffffc02028ea:	8522                	mv	a0,s0
ffffffffc02028ec:	bd1ff0ef          	jal	ra,ffffffffc02024bc <find_vma>
        assert(vma4 == NULL);
ffffffffc02028f0:	32051263          	bnez	a0,ffffffffc0202c14 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02028f4:	00448593          	addi	a1,s1,4
ffffffffc02028f8:	8522                	mv	a0,s0
ffffffffc02028fa:	bc3ff0ef          	jal	ra,ffffffffc02024bc <find_vma>
        assert(vma5 == NULL);
ffffffffc02028fe:	2e051b63          	bnez	a0,ffffffffc0202bf4 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202902:	008a3783          	ld	a5,8(s4)
ffffffffc0202906:	20979763          	bne	a5,s1,ffffffffc0202b14 <vmm_init+0x336>
ffffffffc020290a:	010a3783          	ld	a5,16(s4)
ffffffffc020290e:	21279363          	bne	a5,s2,ffffffffc0202b14 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202912:	0089b783          	ld	a5,8(s3) # fffffffffff80008 <end+0x3fcd3670>
ffffffffc0202916:	20979f63          	bne	a5,s1,ffffffffc0202b34 <vmm_init+0x356>
ffffffffc020291a:	0109b783          	ld	a5,16(s3)
ffffffffc020291e:	21279b63          	bne	a5,s2,ffffffffc0202b34 <vmm_init+0x356>
ffffffffc0202922:	0495                	addi	s1,s1,5
ffffffffc0202924:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202926:	f9549be3          	bne	s1,s5,ffffffffc02028bc <vmm_init+0xde>
ffffffffc020292a:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020292c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020292e:	85a6                	mv	a1,s1
ffffffffc0202930:	8522                	mv	a0,s0
ffffffffc0202932:	b8bff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc0202936:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020293a:	c90d                	beqz	a0,ffffffffc020296c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020293c:	6914                	ld	a3,16(a0)
ffffffffc020293e:	6510                	ld	a2,8(a0)
ffffffffc0202940:	00005517          	auipc	a0,0x5
ffffffffc0202944:	22850513          	addi	a0,a0,552 # ffffffffc0207b68 <commands+0x11f0>
ffffffffc0202948:	f88fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020294c:	00005697          	auipc	a3,0x5
ffffffffc0202950:	24468693          	addi	a3,a3,580 # ffffffffc0207b90 <commands+0x1218>
ffffffffc0202954:	00004617          	auipc	a2,0x4
ffffffffc0202958:	4a460613          	addi	a2,a2,1188 # ffffffffc0206df8 <commands+0x480>
ffffffffc020295c:	13c00593          	li	a1,316
ffffffffc0202960:	00005517          	auipc	a0,0x5
ffffffffc0202964:	f2050513          	addi	a0,a0,-224 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202968:	8adfd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc020296c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020296e:	fd2490e3          	bne	s1,s2,ffffffffc020292e <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202972:	8522                	mv	a0,s0
ffffffffc0202974:	c55ff0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202978:	00005517          	auipc	a0,0x5
ffffffffc020297c:	23050513          	addi	a0,a0,560 # ffffffffc0207ba8 <commands+0x1230>
ffffffffc0202980:	f50fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202984:	da4fe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0202988:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020298a:	ab9ff0ef          	jal	ra,ffffffffc0202442 <mm_create>
ffffffffc020298e:	000aa797          	auipc	a5,0xaa
ffffffffc0202992:	f0a7b123          	sd	a0,-254(a5) # ffffffffc02ac890 <check_mm_struct>
ffffffffc0202996:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202998:	34050c63          	beqz	a0,ffffffffc0202cf0 <vmm_init+0x512>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020299c:	000aa797          	auipc	a5,0xaa
ffffffffc02029a0:	e7c78793          	addi	a5,a5,-388 # ffffffffc02ac818 <boot_pgdir>
ffffffffc02029a4:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02029a8:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02029ac:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02029b0:	2c079463          	bnez	a5,ffffffffc0202c78 <vmm_init+0x49a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029b4:	03000513          	li	a0,48
ffffffffc02029b8:	12d000ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc02029bc:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02029be:	18050b63          	beqz	a0,ffffffffc0202b54 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02029c2:	002007b7          	lui	a5,0x200
ffffffffc02029c6:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc02029c8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02029ca:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02029cc:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc02029ce:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc02029d0:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc02029d4:	b27ff0ef          	jal	ra,ffffffffc02024fa <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02029d8:	10000593          	li	a1,256
ffffffffc02029dc:	8526                	mv	a0,s1
ffffffffc02029de:	adfff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc02029e2:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02029e6:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02029ea:	2aa41763          	bne	s0,a0,ffffffffc0202c98 <vmm_init+0x4ba>
        *(char *)(addr + i) = i;
ffffffffc02029ee:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
        sum += i;
ffffffffc02029f2:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02029f4:	fee79de3          	bne	a5,a4,ffffffffc02029ee <vmm_init+0x210>
        sum += i;
ffffffffc02029f8:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02029fa:	10000793          	li	a5,256
        sum += i;
ffffffffc02029fe:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202a02:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202a06:	0007c683          	lbu	a3,0(a5)
ffffffffc0202a0a:	0785                	addi	a5,a5,1
ffffffffc0202a0c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202a0e:	fec79ce3          	bne	a5,a2,ffffffffc0202a06 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0202a12:	2a071f63          	bnez	a4,ffffffffc0202cd0 <vmm_init+0x4f2>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a16:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a1a:	000aaa97          	auipc	s5,0xaa
ffffffffc0202a1e:	e06a8a93          	addi	s5,s5,-506 # ffffffffc02ac820 <npage>
ffffffffc0202a22:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a26:	078a                	slli	a5,a5,0x2
ffffffffc0202a28:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a2a:	20e7f563          	bgeu	a5,a4,ffffffffc0202c34 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a2e:	00006697          	auipc	a3,0x6
ffffffffc0202a32:	55a68693          	addi	a3,a3,1370 # ffffffffc0208f88 <nbase>
ffffffffc0202a36:	0006ba03          	ld	s4,0(a3)
ffffffffc0202a3a:	414786b3          	sub	a3,a5,s4
ffffffffc0202a3e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202a40:	8699                	srai	a3,a3,0x6
ffffffffc0202a42:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202a44:	00c69793          	slli	a5,a3,0xc
ffffffffc0202a48:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a4a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a4c:	26e7f663          	bgeu	a5,a4,ffffffffc0202cb8 <vmm_init+0x4da>
ffffffffc0202a50:	000aa797          	auipc	a5,0xaa
ffffffffc0202a54:	e2878793          	addi	a5,a5,-472 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0202a58:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202a5a:	4581                	li	a1,0
ffffffffc0202a5c:	854a                	mv	a0,s2
ffffffffc0202a5e:	9436                	add	s0,s0,a3
ffffffffc0202a60:	aa1fe0ef          	jal	ra,ffffffffc0201500 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a64:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a66:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a6a:	078a                	slli	a5,a5,0x2
ffffffffc0202a6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a6e:	1ce7f363          	bgeu	a5,a4,ffffffffc0202c34 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a72:	000aa417          	auipc	s0,0xaa
ffffffffc0202a76:	e1640413          	addi	s0,s0,-490 # ffffffffc02ac888 <pages>
ffffffffc0202a7a:	6008                	ld	a0,0(s0)
ffffffffc0202a7c:	414787b3          	sub	a5,a5,s4
ffffffffc0202a80:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202a82:	953e                	add	a0,a0,a5
ffffffffc0202a84:	4585                	li	a1,1
ffffffffc0202a86:	c5cfe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a8a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a8e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a92:	078a                	slli	a5,a5,0x2
ffffffffc0202a94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a96:	18e7ff63          	bgeu	a5,a4,ffffffffc0202c34 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a9a:	6008                	ld	a0,0(s0)
ffffffffc0202a9c:	414787b3          	sub	a5,a5,s4
ffffffffc0202aa0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202aa2:	4585                	li	a1,1
ffffffffc0202aa4:	953e                	add	a0,a0,a5
ffffffffc0202aa6:	c3cfe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    pgdir[0] = 0;
ffffffffc0202aaa:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202aae:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202ab2:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202ab6:	8526                	mv	a0,s1
ffffffffc0202ab8:	b11ff0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202abc:	000aa797          	auipc	a5,0xaa
ffffffffc0202ac0:	dc07ba23          	sd	zero,-556(a5) # ffffffffc02ac890 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202ac4:	c64fe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0202ac8:	18a99863          	bne	s3,a0,ffffffffc0202c58 <vmm_init+0x47a>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202acc:	00005517          	auipc	a0,0x5
ffffffffc0202ad0:	17c50513          	addi	a0,a0,380 # ffffffffc0207c48 <commands+0x12d0>
ffffffffc0202ad4:	dfcfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202ad8:	7442                	ld	s0,48(sp)
ffffffffc0202ada:	70e2                	ld	ra,56(sp)
ffffffffc0202adc:	74a2                	ld	s1,40(sp)
ffffffffc0202ade:	7902                	ld	s2,32(sp)
ffffffffc0202ae0:	69e2                	ld	s3,24(sp)
ffffffffc0202ae2:	6a42                	ld	s4,16(sp)
ffffffffc0202ae4:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202ae6:	00005517          	auipc	a0,0x5
ffffffffc0202aea:	18250513          	addi	a0,a0,386 # ffffffffc0207c68 <commands+0x12f0>
}
ffffffffc0202aee:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202af0:	de0fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202af4:	00005697          	auipc	a3,0x5
ffffffffc0202af8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0207a80 <commands+0x1108>
ffffffffc0202afc:	00004617          	auipc	a2,0x4
ffffffffc0202b00:	2fc60613          	addi	a2,a2,764 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202b04:	12300593          	li	a1,291
ffffffffc0202b08:	00005517          	auipc	a0,0x5
ffffffffc0202b0c:	d7850513          	addi	a0,a0,-648 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202b10:	f04fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202b14:	00005697          	auipc	a3,0x5
ffffffffc0202b18:	ff468693          	addi	a3,a3,-12 # ffffffffc0207b08 <commands+0x1190>
ffffffffc0202b1c:	00004617          	auipc	a2,0x4
ffffffffc0202b20:	2dc60613          	addi	a2,a2,732 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202b24:	13300593          	li	a1,307
ffffffffc0202b28:	00005517          	auipc	a0,0x5
ffffffffc0202b2c:	d5850513          	addi	a0,a0,-680 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202b30:	ee4fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202b34:	00005697          	auipc	a3,0x5
ffffffffc0202b38:	00468693          	addi	a3,a3,4 # ffffffffc0207b38 <commands+0x11c0>
ffffffffc0202b3c:	00004617          	auipc	a2,0x4
ffffffffc0202b40:	2bc60613          	addi	a2,a2,700 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202b44:	13400593          	li	a1,308
ffffffffc0202b48:	00005517          	auipc	a0,0x5
ffffffffc0202b4c:	d3850513          	addi	a0,a0,-712 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202b50:	ec4fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(vma != NULL);
ffffffffc0202b54:	00005697          	auipc	a3,0x5
ffffffffc0202b58:	12c68693          	addi	a3,a3,300 # ffffffffc0207c80 <commands+0x1308>
ffffffffc0202b5c:	00004617          	auipc	a2,0x4
ffffffffc0202b60:	29c60613          	addi	a2,a2,668 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202b64:	15300593          	li	a1,339
ffffffffc0202b68:	00005517          	auipc	a0,0x5
ffffffffc0202b6c:	d1850513          	addi	a0,a0,-744 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202b70:	ea4fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202b74:	00005697          	auipc	a3,0x5
ffffffffc0202b78:	ef468693          	addi	a3,a3,-268 # ffffffffc0207a68 <commands+0x10f0>
ffffffffc0202b7c:	00004617          	auipc	a2,0x4
ffffffffc0202b80:	27c60613          	addi	a2,a2,636 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202b84:	12100593          	li	a1,289
ffffffffc0202b88:	00005517          	auipc	a0,0x5
ffffffffc0202b8c:	cf850513          	addi	a0,a0,-776 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202b90:	e84fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma3 == NULL);
ffffffffc0202b94:	00005697          	auipc	a3,0x5
ffffffffc0202b98:	f4468693          	addi	a3,a3,-188 # ffffffffc0207ad8 <commands+0x1160>
ffffffffc0202b9c:	00004617          	auipc	a2,0x4
ffffffffc0202ba0:	25c60613          	addi	a2,a2,604 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202ba4:	12d00593          	li	a1,301
ffffffffc0202ba8:	00005517          	auipc	a0,0x5
ffffffffc0202bac:	cd850513          	addi	a0,a0,-808 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202bb0:	e64fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2 != NULL);
ffffffffc0202bb4:	00005697          	auipc	a3,0x5
ffffffffc0202bb8:	f1468693          	addi	a3,a3,-236 # ffffffffc0207ac8 <commands+0x1150>
ffffffffc0202bbc:	00004617          	auipc	a2,0x4
ffffffffc0202bc0:	23c60613          	addi	a2,a2,572 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202bc4:	12b00593          	li	a1,299
ffffffffc0202bc8:	00005517          	auipc	a0,0x5
ffffffffc0202bcc:	cb850513          	addi	a0,a0,-840 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202bd0:	e44fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1 != NULL);
ffffffffc0202bd4:	00005697          	auipc	a3,0x5
ffffffffc0202bd8:	ee468693          	addi	a3,a3,-284 # ffffffffc0207ab8 <commands+0x1140>
ffffffffc0202bdc:	00004617          	auipc	a2,0x4
ffffffffc0202be0:	21c60613          	addi	a2,a2,540 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202be4:	12900593          	li	a1,297
ffffffffc0202be8:	00005517          	auipc	a0,0x5
ffffffffc0202bec:	c9850513          	addi	a0,a0,-872 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202bf0:	e24fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma5 == NULL);
ffffffffc0202bf4:	00005697          	auipc	a3,0x5
ffffffffc0202bf8:	f0468693          	addi	a3,a3,-252 # ffffffffc0207af8 <commands+0x1180>
ffffffffc0202bfc:	00004617          	auipc	a2,0x4
ffffffffc0202c00:	1fc60613          	addi	a2,a2,508 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202c04:	13100593          	li	a1,305
ffffffffc0202c08:	00005517          	auipc	a0,0x5
ffffffffc0202c0c:	c7850513          	addi	a0,a0,-904 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202c10:	e04fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma4 == NULL);
ffffffffc0202c14:	00005697          	auipc	a3,0x5
ffffffffc0202c18:	ed468693          	addi	a3,a3,-300 # ffffffffc0207ae8 <commands+0x1170>
ffffffffc0202c1c:	00004617          	auipc	a2,0x4
ffffffffc0202c20:	1dc60613          	addi	a2,a2,476 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202c24:	12f00593          	li	a1,303
ffffffffc0202c28:	00005517          	auipc	a0,0x5
ffffffffc0202c2c:	c5850513          	addi	a0,a0,-936 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202c30:	de4fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0202c34:	ff2ff0ef          	jal	ra,ffffffffc0202426 <pa2page.part.3>
    assert(mm != NULL);
ffffffffc0202c38:	00005697          	auipc	a3,0x5
ffffffffc0202c3c:	e2068693          	addi	a3,a3,-480 # ffffffffc0207a58 <commands+0x10e0>
ffffffffc0202c40:	00004617          	auipc	a2,0x4
ffffffffc0202c44:	1b860613          	addi	a2,a2,440 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202c48:	10d00593          	li	a1,269
ffffffffc0202c4c:	00005517          	auipc	a0,0x5
ffffffffc0202c50:	c3450513          	addi	a0,a0,-972 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202c54:	dc0fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202c58:	00005697          	auipc	a3,0x5
ffffffffc0202c5c:	fc868693          	addi	a3,a3,-56 # ffffffffc0207c20 <commands+0x12a8>
ffffffffc0202c60:	00004617          	auipc	a2,0x4
ffffffffc0202c64:	19860613          	addi	a2,a2,408 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202c68:	17100593          	li	a1,369
ffffffffc0202c6c:	00005517          	auipc	a0,0x5
ffffffffc0202c70:	c1450513          	addi	a0,a0,-1004 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202c74:	da0fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202c78:	00005697          	auipc	a3,0x5
ffffffffc0202c7c:	f6868693          	addi	a3,a3,-152 # ffffffffc0207be0 <commands+0x1268>
ffffffffc0202c80:	00004617          	auipc	a2,0x4
ffffffffc0202c84:	17860613          	addi	a2,a2,376 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202c88:	15000593          	li	a1,336
ffffffffc0202c8c:	00005517          	auipc	a0,0x5
ffffffffc0202c90:	bf450513          	addi	a0,a0,-1036 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202c94:	d80fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c98:	00005697          	auipc	a3,0x5
ffffffffc0202c9c:	f5868693          	addi	a3,a3,-168 # ffffffffc0207bf0 <commands+0x1278>
ffffffffc0202ca0:	00004617          	auipc	a2,0x4
ffffffffc0202ca4:	15860613          	addi	a2,a2,344 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202ca8:	15800593          	li	a1,344
ffffffffc0202cac:	00005517          	auipc	a0,0x5
ffffffffc0202cb0:	bd450513          	addi	a0,a0,-1068 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202cb4:	d60fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202cb8:	00004617          	auipc	a2,0x4
ffffffffc0202cbc:	56860613          	addi	a2,a2,1384 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0202cc0:	06900593          	li	a1,105
ffffffffc0202cc4:	00004517          	auipc	a0,0x4
ffffffffc0202cc8:	5b450513          	addi	a0,a0,1460 # ffffffffc0207278 <commands+0x900>
ffffffffc0202ccc:	d48fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(sum == 0);
ffffffffc0202cd0:	00005697          	auipc	a3,0x5
ffffffffc0202cd4:	f4068693          	addi	a3,a3,-192 # ffffffffc0207c10 <commands+0x1298>
ffffffffc0202cd8:	00004617          	auipc	a2,0x4
ffffffffc0202cdc:	12060613          	addi	a2,a2,288 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202ce0:	16400593          	li	a1,356
ffffffffc0202ce4:	00005517          	auipc	a0,0x5
ffffffffc0202ce8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202cec:	d28fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202cf0:	00005697          	auipc	a3,0x5
ffffffffc0202cf4:	ed868693          	addi	a3,a3,-296 # ffffffffc0207bc8 <commands+0x1250>
ffffffffc0202cf8:	00004617          	auipc	a2,0x4
ffffffffc0202cfc:	10060613          	addi	a2,a2,256 # ffffffffc0206df8 <commands+0x480>
ffffffffc0202d00:	14c00593          	li	a1,332
ffffffffc0202d04:	00005517          	auipc	a0,0x5
ffffffffc0202d08:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207880 <commands+0xf08>
ffffffffc0202d0c:	d08fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202d10 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202d10:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202d12:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202d14:	e486                	sd	ra,72(sp)
ffffffffc0202d16:	e0a2                	sd	s0,64(sp)
ffffffffc0202d18:	fc26                	sd	s1,56(sp)
ffffffffc0202d1a:	8432                	mv	s0,a2
ffffffffc0202d1c:	f84a                	sd	s2,48(sp)
ffffffffc0202d1e:	f44e                	sd	s3,40(sp)
ffffffffc0202d20:	f052                	sd	s4,32(sp)
ffffffffc0202d22:	ec56                	sd	s5,24(sp)
ffffffffc0202d24:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202d26:	f96ff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc0202d2a:	892a                	mv	s2,a0

    cprintf("test: addr = %x\n", addr);
ffffffffc0202d2c:	85a2                	mv	a1,s0
ffffffffc0202d2e:	00005517          	auipc	a0,0x5
ffffffffc0202d32:	b6250513          	addi	a0,a0,-1182 # ffffffffc0207890 <commands+0xf18>
ffffffffc0202d36:	b9afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    pgfault_num++;
ffffffffc0202d3a:	000aa797          	auipc	a5,0xaa
ffffffffc0202d3e:	aee78793          	addi	a5,a5,-1298 # ffffffffc02ac828 <pgfault_num>
ffffffffc0202d42:	439c                	lw	a5,0(a5)
ffffffffc0202d44:	2785                	addiw	a5,a5,1
ffffffffc0202d46:	000aa717          	auipc	a4,0xaa
ffffffffc0202d4a:	aef72123          	sw	a5,-1310(a4) # ffffffffc02ac828 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202d4e:	1e090363          	beqz	s2,ffffffffc0202f34 <do_pgfault+0x224>
ffffffffc0202d52:	00893783          	ld	a5,8(s2)
ffffffffc0202d56:	1af46563          	bltu	s0,a5,ffffffffc0202f00 <do_pgfault+0x1f0>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202d5a:	01892783          	lw	a5,24(s2)
    uint32_t perm = PTE_U;
ffffffffc0202d5e:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202d60:	8b89                	andi	a5,a5,2
ffffffffc0202d62:	eba5                	bnez	a5,ffffffffc0202dd2 <do_pgfault+0xc2>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202d64:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202d66:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202d68:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202d6a:	85a2                	mv	a1,s0
ffffffffc0202d6c:	4605                	li	a2,1
ffffffffc0202d6e:	9fafe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0202d72:	892a                	mv	s2,a0
ffffffffc0202d74:	1c050f63          	beqz	a0,ffffffffc0202f52 <do_pgfault+0x242>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202d78:	6110                	ld	a2,0(a0)
ffffffffc0202d7a:	12060463          	beqz	a2,ffffffffc0202ea2 <do_pgfault+0x192>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        struct Page *page = NULL;
ffffffffc0202d7e:	e402                	sd	zero,8(sp)
        if(*ptep & PTE_W){ // 如果因为页面只读进入缺页异常，我们认为时COW机制下子进程尝试写入父进程的共享页面
ffffffffc0202d80:	00467793          	andi	a5,a2,4
ffffffffc0202d84:	eba9                	bnez	a5,ffffffffc0202dd6 <do_pgfault+0xc6>
            *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
            *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
            *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
            *    swap_map_swappable ： 设置页面可交换
            */
            if (swap_init_ok) {
ffffffffc0202d86:	000aa797          	auipc	a5,0xaa
ffffffffc0202d8a:	aba78793          	addi	a5,a5,-1350 # ffffffffc02ac840 <swap_init_ok>
ffffffffc0202d8e:	439c                	lw	a5,0(a5)
ffffffffc0202d90:	2781                	sext.w	a5,a5
ffffffffc0202d92:	18078863          	beqz	a5,ffffffffc0202f22 <do_pgfault+0x212>
                //(2) According to the mm,
                //addr AND page, setup the
                //map of phy addr <--->
                //logical addr
                //(3) make the page swappable.
                swap_in(mm,addr,&page);
ffffffffc0202d96:	85a2                	mv	a1,s0
ffffffffc0202d98:	0030                	addi	a2,sp,8
ffffffffc0202d9a:	8526                	mv	a0,s1
ffffffffc0202d9c:	7dd000ef          	jal	ra,ffffffffc0203d78 <swap_in>
                page_insert(mm->pgdir,page,addr,perm);
ffffffffc0202da0:	65a2                	ld	a1,8(sp)
ffffffffc0202da2:	6c88                	ld	a0,24(s1)
ffffffffc0202da4:	86ce                	mv	a3,s3
ffffffffc0202da6:	8622                	mv	a2,s0
ffffffffc0202da8:	fccfe0ef          	jal	ra,ffffffffc0201574 <page_insert>
                swap_map_swappable(mm,addr,page,1);
ffffffffc0202dac:	6622                	ld	a2,8(sp)
ffffffffc0202dae:	4685                	li	a3,1
ffffffffc0202db0:	85a2                	mv	a1,s0
ffffffffc0202db2:	8526                	mv	a0,s1
ffffffffc0202db4:	6a1000ef          	jal	ra,ffffffffc0203c54 <swap_map_swappable>
                page->pra_vaddr = addr;
ffffffffc0202db8:	67a2                	ld	a5,8(sp)
ffffffffc0202dba:	ff80                	sd	s0,56(a5)
                goto failed;
            }
        }
        
   }
   ret = 0;
ffffffffc0202dbc:	4781                	li	a5,0
failed:
    return ret;
}
ffffffffc0202dbe:	60a6                	ld	ra,72(sp)
ffffffffc0202dc0:	6406                	ld	s0,64(sp)
ffffffffc0202dc2:	74e2                	ld	s1,56(sp)
ffffffffc0202dc4:	7942                	ld	s2,48(sp)
ffffffffc0202dc6:	79a2                	ld	s3,40(sp)
ffffffffc0202dc8:	7a02                	ld	s4,32(sp)
ffffffffc0202dca:	6ae2                	ld	s5,24(sp)
ffffffffc0202dcc:	853e                	mv	a0,a5
ffffffffc0202dce:	6161                	addi	sp,sp,80
ffffffffc0202dd0:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202dd2:	49dd                	li	s3,23
ffffffffc0202dd4:	bf41                	j	ffffffffc0202d64 <do_pgfault+0x54>
            cprintf('pgfault: COW: ptep at addr %x, pte at addr %x\n', ptep, *ptep);
ffffffffc0202dd6:	85aa                	mv	a1,a0
ffffffffc0202dd8:	20258537          	lui	a0,0x20258
ffffffffc0202ddc:	80a50513          	addi	a0,a0,-2038 # 2025780a <_binary_obj___user_exit_out_size+0x2024cd42>
ffffffffc0202de0:	af0fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            page = pte2page(*ptep); // 获取原先的只读物理页
ffffffffc0202de4:	00093783          	ld	a5,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0202de8:	0017f713          	andi	a4,a5,1
ffffffffc0202dec:	1a070463          	beqz	a4,ffffffffc0202f94 <do_pgfault+0x284>
    if (PPN(pa) >= npage) {
ffffffffc0202df0:	000aaa17          	auipc	s4,0xaa
ffffffffc0202df4:	a30a0a13          	addi	s4,s4,-1488 # ffffffffc02ac820 <npage>
ffffffffc0202df8:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dfc:	078a                	slli	a5,a5,0x2
ffffffffc0202dfe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e00:	1ae7f663          	bgeu	a5,a4,ffffffffc0202fac <do_pgfault+0x29c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e04:	00006717          	auipc	a4,0x6
ffffffffc0202e08:	18470713          	addi	a4,a4,388 # ffffffffc0208f88 <nbase>
ffffffffc0202e0c:	00073903          	ld	s2,0(a4)
ffffffffc0202e10:	000aaa97          	auipc	s5,0xaa
ffffffffc0202e14:	a78a8a93          	addi	s5,s5,-1416 # ffffffffc02ac888 <pages>
ffffffffc0202e18:	000ab583          	ld	a1,0(s5)
ffffffffc0202e1c:	412787b3          	sub	a5,a5,s2
ffffffffc0202e20:	079a                	slli	a5,a5,0x6
ffffffffc0202e22:	95be                	add	a1,a1,a5
            if(page_ref(page) > 1){
ffffffffc0202e24:	4198                	lw	a4,0(a1)
ffffffffc0202e26:	4785                	li	a5,1
            page = pte2page(*ptep); // 获取原先的只读物理页
ffffffffc0202e28:	e42e                	sd	a1,8(sp)
    return page->ref;
ffffffffc0202e2a:	6c88                	ld	a0,24(s1)
            if(page_ref(page) > 1){
ffffffffc0202e2c:	08e7db63          	bge	a5,a4,ffffffffc0202ec2 <do_pgfault+0x1b2>
                struct Page* new_page = pgdir_alloc_page(mm->pgdir, addr, perm); // 新分配一个物理页
ffffffffc0202e30:	864e                	mv	a2,s3
ffffffffc0202e32:	85a2                	mv	a1,s0
ffffffffc0202e34:	d3aff0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0202e38:	000ab683          	ld	a3,0(s5)
ffffffffc0202e3c:	69a2                	ld	s3,8(sp)
    return KADDR(page2pa(page));
ffffffffc0202e3e:	57fd                	li	a5,-1
ffffffffc0202e40:	000a3603          	ld	a2,0(s4)
    return page - pages + nbase;
ffffffffc0202e44:	40d989b3          	sub	s3,s3,a3
ffffffffc0202e48:	4069d993          	srai	s3,s3,0x6
ffffffffc0202e4c:	99ca                	add	s3,s3,s2
    return KADDR(page2pa(page));
ffffffffc0202e4e:	83b1                	srli	a5,a5,0xc
ffffffffc0202e50:	00f9f733          	and	a4,s3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e54:	09b2                	slli	s3,s3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e56:	12c77263          	bgeu	a4,a2,ffffffffc0202f7a <do_pgfault+0x26a>
    return page - pages + nbase;
ffffffffc0202e5a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202e5e:	000aa717          	auipc	a4,0xaa
ffffffffc0202e62:	a1a70713          	addi	a4,a4,-1510 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0202e66:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0202e68:	8699                	srai	a3,a3,0x6
ffffffffc0202e6a:	96ca                	add	a3,a3,s2
    return KADDR(page2pa(page));
ffffffffc0202e6c:	8ff5                	and	a5,a5,a3
ffffffffc0202e6e:	99ba                	add	s3,s3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e70:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e72:	0ec7f863          	bgeu	a5,a2,ffffffffc0202f62 <do_pgfault+0x252>
ffffffffc0202e76:	00e68933          	add	s2,a3,a4
                memcpy(dst_kva, src_kva, PGSIZE); // 将只读页的内容分配到新页中
ffffffffc0202e7a:	6605                	lui	a2,0x1
ffffffffc0202e7c:	85ce                	mv	a1,s3
ffffffffc0202e7e:	854a                	mv	a0,s2
ffffffffc0202e80:	56a030ef          	jal	ra,ffffffffc02063ea <memcpy>
                cprintf("test: srckva = %x ", src_kva);
ffffffffc0202e84:	85ce                	mv	a1,s3
ffffffffc0202e86:	00005517          	auipc	a0,0x5
ffffffffc0202e8a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02078f0 <commands+0xf78>
ffffffffc0202e8e:	a42fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                cprintf("dst_kva = %x\n", dst_kva);
ffffffffc0202e92:	85ca                	mv	a1,s2
ffffffffc0202e94:	00005517          	auipc	a0,0x5
ffffffffc0202e98:	a7450513          	addi	a0,a0,-1420 # ffffffffc0207908 <commands+0xf90>
ffffffffc0202e9c:	a34fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202ea0:	b731                	j	ffffffffc0202dac <do_pgfault+0x9c>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202ea2:	6c88                	ld	a0,24(s1)
ffffffffc0202ea4:	864e                	mv	a2,s3
ffffffffc0202ea6:	85a2                	mv	a1,s0
ffffffffc0202ea8:	cc6ff0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
   ret = 0;
ffffffffc0202eac:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202eae:	f00518e3          	bnez	a0,ffffffffc0202dbe <do_pgfault+0xae>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202eb2:	00005517          	auipc	a0,0x5
ffffffffc0202eb6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02078c8 <commands+0xf50>
ffffffffc0202eba:	a16fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202ebe:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202ec0:	bdfd                	j	ffffffffc0202dbe <do_pgfault+0xae>
                page_insert(mm->pgdir, page, addr, perm); // 直接修改该页面的权限
ffffffffc0202ec2:	86ce                	mv	a3,s3
ffffffffc0202ec4:	8622                	mv	a2,s0
ffffffffc0202ec6:	eaefe0ef          	jal	ra,ffffffffc0201574 <page_insert>
    return page - pages + nbase;
ffffffffc0202eca:	000ab783          	ld	a5,0(s5)
ffffffffc0202ece:	66a2                	ld	a3,8(sp)
    return KADDR(page2pa(page));
ffffffffc0202ed0:	000a3703          	ld	a4,0(s4)
    return page - pages + nbase;
ffffffffc0202ed4:	8e9d                	sub	a3,a3,a5
ffffffffc0202ed6:	8699                	srai	a3,a3,0x6
ffffffffc0202ed8:	96ca                	add	a3,a3,s2
    return KADDR(page2pa(page));
ffffffffc0202eda:	00c69793          	slli	a5,a3,0xc
ffffffffc0202ede:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ee0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ee2:	08e7f063          	bgeu	a5,a4,ffffffffc0202f62 <do_pgfault+0x252>
ffffffffc0202ee6:	000aa797          	auipc	a5,0xaa
ffffffffc0202eea:	99278793          	addi	a5,a5,-1646 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0202eee:	638c                	ld	a1,0(a5)
                cprintf("ttest: %x\n", page2kva(page));
ffffffffc0202ef0:	00005517          	auipc	a0,0x5
ffffffffc0202ef4:	a2850513          	addi	a0,a0,-1496 # ffffffffc0207918 <commands+0xfa0>
ffffffffc0202ef8:	95b6                	add	a1,a1,a3
ffffffffc0202efa:	9d6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202efe:	b57d                	j	ffffffffc0202dac <do_pgfault+0x9c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202f00:	85a2                	mv	a1,s0
ffffffffc0202f02:	00005517          	auipc	a0,0x5
ffffffffc0202f06:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0207950 <commands+0xfd8>
ffffffffc0202f0a:	9c6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            cprintf("test: %x\n", vma->vm_start);
ffffffffc0202f0e:	00893583          	ld	a1,8(s2)
ffffffffc0202f12:	00005517          	auipc	a0,0x5
ffffffffc0202f16:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0207990 <commands+0x1018>
ffffffffc0202f1a:	9b6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202f1e:	57f5                	li	a5,-3
    return ret;
ffffffffc0202f20:	bd79                	j	ffffffffc0202dbe <do_pgfault+0xae>
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202f22:	85b2                	mv	a1,a2
ffffffffc0202f24:	00005517          	auipc	a0,0x5
ffffffffc0202f28:	a0450513          	addi	a0,a0,-1532 # ffffffffc0207928 <commands+0xfb0>
ffffffffc0202f2c:	9a4fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202f30:	57f1                	li	a5,-4
ffffffffc0202f32:	b571                	j	ffffffffc0202dbe <do_pgfault+0xae>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202f34:	85a2                	mv	a1,s0
ffffffffc0202f36:	00005517          	auipc	a0,0x5
ffffffffc0202f3a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0207950 <commands+0xfd8>
ffffffffc0202f3e:	992fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            cprintf("vma is NULL!\n");
ffffffffc0202f42:	00005517          	auipc	a0,0x5
ffffffffc0202f46:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207980 <commands+0x1008>
ffffffffc0202f4a:	986fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202f4e:	57f5                	li	a5,-3
ffffffffc0202f50:	b5bd                	j	ffffffffc0202dbe <do_pgfault+0xae>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202f52:	00005517          	auipc	a0,0x5
ffffffffc0202f56:	95650513          	addi	a0,a0,-1706 # ffffffffc02078a8 <commands+0xf30>
ffffffffc0202f5a:	976fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202f5e:	57f1                	li	a5,-4
        goto failed;
ffffffffc0202f60:	bdb9                	j	ffffffffc0202dbe <do_pgfault+0xae>
ffffffffc0202f62:	00004617          	auipc	a2,0x4
ffffffffc0202f66:	2be60613          	addi	a2,a2,702 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0202f6a:	06900593          	li	a1,105
ffffffffc0202f6e:	00004517          	auipc	a0,0x4
ffffffffc0202f72:	30a50513          	addi	a0,a0,778 # ffffffffc0207278 <commands+0x900>
ffffffffc0202f76:	a9efd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0202f7a:	86ce                	mv	a3,s3
ffffffffc0202f7c:	00004617          	auipc	a2,0x4
ffffffffc0202f80:	2a460613          	addi	a2,a2,676 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0202f84:	06900593          	li	a1,105
ffffffffc0202f88:	00004517          	auipc	a0,0x4
ffffffffc0202f8c:	2f050513          	addi	a0,a0,752 # ffffffffc0207278 <commands+0x900>
ffffffffc0202f90:	a84fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202f94:	00004617          	auipc	a2,0x4
ffffffffc0202f98:	4a460613          	addi	a2,a2,1188 # ffffffffc0207438 <commands+0xac0>
ffffffffc0202f9c:	07400593          	li	a1,116
ffffffffc0202fa0:	00004517          	auipc	a0,0x4
ffffffffc0202fa4:	2d850513          	addi	a0,a0,728 # ffffffffc0207278 <commands+0x900>
ffffffffc0202fa8:	a6cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0202fac:	c7aff0ef          	jal	ra,ffffffffc0202426 <pa2page.part.3>

ffffffffc0202fb0 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0202fb0:	7179                	addi	sp,sp,-48
ffffffffc0202fb2:	f022                	sd	s0,32(sp)
ffffffffc0202fb4:	f406                	sd	ra,40(sp)
ffffffffc0202fb6:	ec26                	sd	s1,24(sp)
ffffffffc0202fb8:	e84a                	sd	s2,16(sp)
ffffffffc0202fba:	e44e                	sd	s3,8(sp)
ffffffffc0202fbc:	e052                	sd	s4,0(sp)
ffffffffc0202fbe:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0202fc0:	c135                	beqz	a0,ffffffffc0203024 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0202fc2:	002007b7          	lui	a5,0x200
ffffffffc0202fc6:	04f5e663          	bltu	a1,a5,ffffffffc0203012 <user_mem_check+0x62>
ffffffffc0202fca:	00c584b3          	add	s1,a1,a2
ffffffffc0202fce:	0495f263          	bgeu	a1,s1,ffffffffc0203012 <user_mem_check+0x62>
ffffffffc0202fd2:	4785                	li	a5,1
ffffffffc0202fd4:	07fe                	slli	a5,a5,0x1f
ffffffffc0202fd6:	0297ee63          	bltu	a5,s1,ffffffffc0203012 <user_mem_check+0x62>
ffffffffc0202fda:	892a                	mv	s2,a0
ffffffffc0202fdc:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202fde:	6a05                	lui	s4,0x1
ffffffffc0202fe0:	a821                	j	ffffffffc0202ff8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202fe2:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202fe6:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202fe8:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202fea:	c685                	beqz	a3,ffffffffc0203012 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202fec:	c399                	beqz	a5,ffffffffc0202ff2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202fee:	02e46263          	bltu	s0,a4,ffffffffc0203012 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0202ff2:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0202ff4:	04947663          	bgeu	s0,s1,ffffffffc0203040 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0202ff8:	85a2                	mv	a1,s0
ffffffffc0202ffa:	854a                	mv	a0,s2
ffffffffc0202ffc:	cc0ff0ef          	jal	ra,ffffffffc02024bc <find_vma>
ffffffffc0203000:	c909                	beqz	a0,ffffffffc0203012 <user_mem_check+0x62>
ffffffffc0203002:	6518                	ld	a4,8(a0)
ffffffffc0203004:	00e46763          	bltu	s0,a4,ffffffffc0203012 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0203008:	4d1c                	lw	a5,24(a0)
ffffffffc020300a:	fc099ce3          	bnez	s3,ffffffffc0202fe2 <user_mem_check+0x32>
ffffffffc020300e:	8b85                	andi	a5,a5,1
ffffffffc0203010:	f3ed                	bnez	a5,ffffffffc0202ff2 <user_mem_check+0x42>
            return 0;
ffffffffc0203012:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203014:	70a2                	ld	ra,40(sp)
ffffffffc0203016:	7402                	ld	s0,32(sp)
ffffffffc0203018:	64e2                	ld	s1,24(sp)
ffffffffc020301a:	6942                	ld	s2,16(sp)
ffffffffc020301c:	69a2                	ld	s3,8(sp)
ffffffffc020301e:	6a02                	ld	s4,0(sp)
ffffffffc0203020:	6145                	addi	sp,sp,48
ffffffffc0203022:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203024:	c02007b7          	lui	a5,0xc0200
ffffffffc0203028:	4501                	li	a0,0
ffffffffc020302a:	fef5e5e3          	bltu	a1,a5,ffffffffc0203014 <user_mem_check+0x64>
ffffffffc020302e:	962e                	add	a2,a2,a1
ffffffffc0203030:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203014 <user_mem_check+0x64>
ffffffffc0203034:	c8000537          	lui	a0,0xc8000
ffffffffc0203038:	0505                	addi	a0,a0,1
ffffffffc020303a:	00a63533          	sltu	a0,a2,a0
ffffffffc020303e:	bfd9                	j	ffffffffc0203014 <user_mem_check+0x64>
        return 1;
ffffffffc0203040:	4505                	li	a0,1
ffffffffc0203042:	bfc9                	j	ffffffffc0203014 <user_mem_check+0x64>

ffffffffc0203044 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0203044:	c125                	beqz	a0,ffffffffc02030a4 <slob_free+0x60>
		return;

	if (size)
ffffffffc0203046:	e1a5                	bnez	a1,ffffffffc02030a6 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203048:	100027f3          	csrr	a5,sstatus
ffffffffc020304c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020304e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203050:	e3bd                	bnez	a5,ffffffffc02030b6 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203052:	0009e797          	auipc	a5,0x9e
ffffffffc0203056:	3a678793          	addi	a5,a5,934 # ffffffffc02a13f8 <slobfree>
ffffffffc020305a:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020305c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020305e:	00a7fa63          	bgeu	a5,a0,ffffffffc0203072 <slob_free+0x2e>
ffffffffc0203062:	00e56c63          	bltu	a0,a4,ffffffffc020307a <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203066:	00e7fa63          	bgeu	a5,a4,ffffffffc020307a <slob_free+0x36>
    return 0;
ffffffffc020306a:	87ba                	mv	a5,a4
ffffffffc020306c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020306e:	fea7eae3          	bltu	a5,a0,ffffffffc0203062 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203072:	fee7ece3          	bltu	a5,a4,ffffffffc020306a <slob_free+0x26>
ffffffffc0203076:	fee57ae3          	bgeu	a0,a4,ffffffffc020306a <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc020307a:	4110                	lw	a2,0(a0)
ffffffffc020307c:	00461693          	slli	a3,a2,0x4
ffffffffc0203080:	96aa                	add	a3,a3,a0
ffffffffc0203082:	08d70b63          	beq	a4,a3,ffffffffc0203118 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0203086:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0203088:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020308a:	00469713          	slli	a4,a3,0x4
ffffffffc020308e:	973e                	add	a4,a4,a5
ffffffffc0203090:	08e50f63          	beq	a0,a4,ffffffffc020312e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0203094:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0203096:	0009e717          	auipc	a4,0x9e
ffffffffc020309a:	36f73123          	sd	a5,866(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc020309e:	c199                	beqz	a1,ffffffffc02030a4 <slob_free+0x60>
        intr_enable();
ffffffffc02030a0:	daefd06f          	j	ffffffffc020064e <intr_enable>
ffffffffc02030a4:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02030a6:	05bd                	addi	a1,a1,15
ffffffffc02030a8:	8191                	srli	a1,a1,0x4
ffffffffc02030aa:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030ac:	100027f3          	csrr	a5,sstatus
ffffffffc02030b0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02030b2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030b4:	dfd9                	beqz	a5,ffffffffc0203052 <slob_free+0xe>
{
ffffffffc02030b6:	1101                	addi	sp,sp,-32
ffffffffc02030b8:	e42a                	sd	a0,8(sp)
ffffffffc02030ba:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02030bc:	d98fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02030c0:	0009e797          	auipc	a5,0x9e
ffffffffc02030c4:	33878793          	addi	a5,a5,824 # ffffffffc02a13f8 <slobfree>
ffffffffc02030c8:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02030ca:	6522                	ld	a0,8(sp)
ffffffffc02030cc:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02030ce:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02030d0:	00a7fa63          	bgeu	a5,a0,ffffffffc02030e4 <slob_free+0xa0>
ffffffffc02030d4:	00e56c63          	bltu	a0,a4,ffffffffc02030ec <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02030d8:	00e7fa63          	bgeu	a5,a4,ffffffffc02030ec <slob_free+0xa8>
    return 0;
ffffffffc02030dc:	87ba                	mv	a5,a4
ffffffffc02030de:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02030e0:	fea7eae3          	bltu	a5,a0,ffffffffc02030d4 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02030e4:	fee7ece3          	bltu	a5,a4,ffffffffc02030dc <slob_free+0x98>
ffffffffc02030e8:	fee57ae3          	bgeu	a0,a4,ffffffffc02030dc <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02030ec:	4110                	lw	a2,0(a0)
ffffffffc02030ee:	00461693          	slli	a3,a2,0x4
ffffffffc02030f2:	96aa                	add	a3,a3,a0
ffffffffc02030f4:	04d70763          	beq	a4,a3,ffffffffc0203142 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02030f8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02030fa:	4394                	lw	a3,0(a5)
ffffffffc02030fc:	00469713          	slli	a4,a3,0x4
ffffffffc0203100:	973e                	add	a4,a4,a5
ffffffffc0203102:	04e50663          	beq	a0,a4,ffffffffc020314e <slob_free+0x10a>
		cur->next = b;
ffffffffc0203106:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0203108:	0009e717          	auipc	a4,0x9e
ffffffffc020310c:	2ef73823          	sd	a5,752(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0203110:	e58d                	bnez	a1,ffffffffc020313a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0203112:	60e2                	ld	ra,24(sp)
ffffffffc0203114:	6105                	addi	sp,sp,32
ffffffffc0203116:	8082                	ret
		b->units += cur->next->units;
ffffffffc0203118:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020311a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020311c:	9e35                	addw	a2,a2,a3
ffffffffc020311e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0203120:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203122:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203124:	00469713          	slli	a4,a3,0x4
ffffffffc0203128:	973e                	add	a4,a4,a5
ffffffffc020312a:	f6e515e3          	bne	a0,a4,ffffffffc0203094 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020312e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203130:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203132:	9eb9                	addw	a3,a3,a4
ffffffffc0203134:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0203136:	e790                	sd	a2,8(a5)
ffffffffc0203138:	bfb9                	j	ffffffffc0203096 <slob_free+0x52>
}
ffffffffc020313a:	60e2                	ld	ra,24(sp)
ffffffffc020313c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020313e:	d10fd06f          	j	ffffffffc020064e <intr_enable>
		b->units += cur->next->units;
ffffffffc0203142:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203144:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0203146:	9e35                	addw	a2,a2,a3
ffffffffc0203148:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc020314a:	e518                	sd	a4,8(a0)
ffffffffc020314c:	b77d                	j	ffffffffc02030fa <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020314e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203150:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203152:	9eb9                	addw	a3,a3,a4
ffffffffc0203154:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0203156:	e790                	sd	a2,8(a5)
ffffffffc0203158:	bf45                	j	ffffffffc0203108 <slob_free+0xc4>

ffffffffc020315a <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020315a:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020315c:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020315e:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203162:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203164:	cf7fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
  if(!page)
ffffffffc0203168:	cd1d                	beqz	a0,ffffffffc02031a6 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc020316a:	000a9797          	auipc	a5,0xa9
ffffffffc020316e:	71e78793          	addi	a5,a5,1822 # ffffffffc02ac888 <pages>
ffffffffc0203172:	6394                	ld	a3,0(a5)
ffffffffc0203174:	00006797          	auipc	a5,0x6
ffffffffc0203178:	e1478793          	addi	a5,a5,-492 # ffffffffc0208f88 <nbase>
ffffffffc020317c:	8d15                	sub	a0,a0,a3
ffffffffc020317e:	6394                	ld	a3,0(a5)
ffffffffc0203180:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0203182:	000a9797          	auipc	a5,0xa9
ffffffffc0203186:	69e78793          	addi	a5,a5,1694 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc020318a:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020318c:	6398                	ld	a4,0(a5)
ffffffffc020318e:	00c51793          	slli	a5,a0,0xc
ffffffffc0203192:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203194:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0203196:	00e7fb63          	bgeu	a5,a4,ffffffffc02031ac <__slob_get_free_pages.isra.0+0x52>
ffffffffc020319a:	000a9797          	auipc	a5,0xa9
ffffffffc020319e:	6de78793          	addi	a5,a5,1758 # ffffffffc02ac878 <va_pa_offset>
ffffffffc02031a2:	6394                	ld	a3,0(a5)
ffffffffc02031a4:	9536                	add	a0,a0,a3
}
ffffffffc02031a6:	60a2                	ld	ra,8(sp)
ffffffffc02031a8:	0141                	addi	sp,sp,16
ffffffffc02031aa:	8082                	ret
ffffffffc02031ac:	86aa                	mv	a3,a0
ffffffffc02031ae:	00004617          	auipc	a2,0x4
ffffffffc02031b2:	07260613          	addi	a2,a2,114 # ffffffffc0207220 <commands+0x8a8>
ffffffffc02031b6:	06900593          	li	a1,105
ffffffffc02031ba:	00004517          	auipc	a0,0x4
ffffffffc02031be:	0be50513          	addi	a0,a0,190 # ffffffffc0207278 <commands+0x900>
ffffffffc02031c2:	852fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02031c6 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02031c6:	1101                	addi	sp,sp,-32
ffffffffc02031c8:	ec06                	sd	ra,24(sp)
ffffffffc02031ca:	e822                	sd	s0,16(sp)
ffffffffc02031cc:	e426                	sd	s1,8(sp)
ffffffffc02031ce:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02031d0:	01050713          	addi	a4,a0,16
ffffffffc02031d4:	6785                	lui	a5,0x1
ffffffffc02031d6:	0cf77563          	bgeu	a4,a5,ffffffffc02032a0 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02031da:	00f50493          	addi	s1,a0,15
ffffffffc02031de:	8091                	srli	s1,s1,0x4
ffffffffc02031e0:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02031e2:	10002673          	csrr	a2,sstatus
ffffffffc02031e6:	8a09                	andi	a2,a2,2
ffffffffc02031e8:	e64d                	bnez	a2,ffffffffc0203292 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc02031ea:	0009e917          	auipc	s2,0x9e
ffffffffc02031ee:	20e90913          	addi	s2,s2,526 # ffffffffc02a13f8 <slobfree>
ffffffffc02031f2:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02031f6:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02031f8:	4398                	lw	a4,0(a5)
ffffffffc02031fa:	0a975063          	bge	a4,s1,ffffffffc020329a <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc02031fe:	00d78b63          	beq	a5,a3,ffffffffc0203214 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203202:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203204:	4018                	lw	a4,0(s0)
ffffffffc0203206:	02975a63          	bge	a4,s1,ffffffffc020323a <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc020320a:	00093683          	ld	a3,0(s2)
ffffffffc020320e:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0203210:	fed799e3          	bne	a5,a3,ffffffffc0203202 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0203214:	e225                	bnez	a2,ffffffffc0203274 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203216:	4501                	li	a0,0
ffffffffc0203218:	f43ff0ef          	jal	ra,ffffffffc020315a <__slob_get_free_pages.isra.0>
ffffffffc020321c:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020321e:	cd15                	beqz	a0,ffffffffc020325a <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203220:	6585                	lui	a1,0x1
ffffffffc0203222:	e23ff0ef          	jal	ra,ffffffffc0203044 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203226:	10002673          	csrr	a2,sstatus
ffffffffc020322a:	8a09                	andi	a2,a2,2
ffffffffc020322c:	ee15                	bnez	a2,ffffffffc0203268 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc020322e:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203232:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203234:	4018                	lw	a4,0(s0)
ffffffffc0203236:	fc974ae3          	blt	a4,s1,ffffffffc020320a <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc020323a:	04e48963          	beq	s1,a4,ffffffffc020328c <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc020323e:	00449693          	slli	a3,s1,0x4
ffffffffc0203242:	96a2                	add	a3,a3,s0
ffffffffc0203244:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0203246:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0203248:	9f05                	subw	a4,a4,s1
ffffffffc020324a:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020324c:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020324e:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0203250:	0009e717          	auipc	a4,0x9e
ffffffffc0203254:	1af73423          	sd	a5,424(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0203258:	e20d                	bnez	a2,ffffffffc020327a <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc020325a:	8522                	mv	a0,s0
ffffffffc020325c:	60e2                	ld	ra,24(sp)
ffffffffc020325e:	6442                	ld	s0,16(sp)
ffffffffc0203260:	64a2                	ld	s1,8(sp)
ffffffffc0203262:	6902                	ld	s2,0(sp)
ffffffffc0203264:	6105                	addi	sp,sp,32
ffffffffc0203266:	8082                	ret
        intr_disable();
ffffffffc0203268:	becfd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc020326c:	4605                	li	a2,1
			cur = slobfree;
ffffffffc020326e:	00093783          	ld	a5,0(s2)
ffffffffc0203272:	b7c1                	j	ffffffffc0203232 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0203274:	bdafd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203278:	bf79                	j	ffffffffc0203216 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc020327a:	bd4fd0ef          	jal	ra,ffffffffc020064e <intr_enable>
}
ffffffffc020327e:	8522                	mv	a0,s0
ffffffffc0203280:	60e2                	ld	ra,24(sp)
ffffffffc0203282:	6442                	ld	s0,16(sp)
ffffffffc0203284:	64a2                	ld	s1,8(sp)
ffffffffc0203286:	6902                	ld	s2,0(sp)
ffffffffc0203288:	6105                	addi	sp,sp,32
ffffffffc020328a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020328c:	6418                	ld	a4,8(s0)
ffffffffc020328e:	e798                	sd	a4,8(a5)
ffffffffc0203290:	b7c1                	j	ffffffffc0203250 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0203292:	bc2fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc0203296:	4605                	li	a2,1
ffffffffc0203298:	bf89                	j	ffffffffc02031ea <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020329a:	843e                	mv	s0,a5
ffffffffc020329c:	87b6                	mv	a5,a3
ffffffffc020329e:	bf71                	j	ffffffffc020323a <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02032a0:	00005697          	auipc	a3,0x5
ffffffffc02032a4:	a1068693          	addi	a3,a3,-1520 # ffffffffc0207cb0 <commands+0x1338>
ffffffffc02032a8:	00004617          	auipc	a2,0x4
ffffffffc02032ac:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206df8 <commands+0x480>
ffffffffc02032b0:	06400593          	li	a1,100
ffffffffc02032b4:	00005517          	auipc	a0,0x5
ffffffffc02032b8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207cd0 <commands+0x1358>
ffffffffc02032bc:	f59fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02032c0 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02032c0:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02032c2:	00005517          	auipc	a0,0x5
ffffffffc02032c6:	a2650513          	addi	a0,a0,-1498 # ffffffffc0207ce8 <commands+0x1370>
kmalloc_init(void) {
ffffffffc02032ca:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02032cc:	e05fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02032d0:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02032d2:	00005517          	auipc	a0,0x5
ffffffffc02032d6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0207c90 <commands+0x1318>
}
ffffffffc02032da:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02032dc:	df5fc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02032e0 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02032e0:	4501                	li	a0,0
ffffffffc02032e2:	8082                	ret

ffffffffc02032e4 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02032e4:	1101                	addi	sp,sp,-32
ffffffffc02032e6:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02032e8:	6905                	lui	s2,0x1
{
ffffffffc02032ea:	e822                	sd	s0,16(sp)
ffffffffc02032ec:	ec06                	sd	ra,24(sp)
ffffffffc02032ee:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02032f0:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc02032f4:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02032f6:	04a7fc63          	bgeu	a5,a0,ffffffffc020334e <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02032fa:	4561                	li	a0,24
ffffffffc02032fc:	ecbff0ef          	jal	ra,ffffffffc02031c6 <slob_alloc.isra.1.constprop.3>
ffffffffc0203300:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203302:	cd21                	beqz	a0,ffffffffc020335a <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0203304:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203308:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020330a:	00f95763          	bge	s2,a5,ffffffffc0203318 <kmalloc+0x34>
ffffffffc020330e:	6705                	lui	a4,0x1
ffffffffc0203310:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203312:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203314:	fef74ee3          	blt	a4,a5,ffffffffc0203310 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203318:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020331a:	e41ff0ef          	jal	ra,ffffffffc020315a <__slob_get_free_pages.isra.0>
ffffffffc020331e:	e488                	sd	a0,8(s1)
ffffffffc0203320:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203322:	c935                	beqz	a0,ffffffffc0203396 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203324:	100027f3          	csrr	a5,sstatus
ffffffffc0203328:	8b89                	andi	a5,a5,2
ffffffffc020332a:	e3a1                	bnez	a5,ffffffffc020336a <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc020332c:	000a9797          	auipc	a5,0xa9
ffffffffc0203330:	50478793          	addi	a5,a5,1284 # ffffffffc02ac830 <bigblocks>
ffffffffc0203334:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203336:	000a9717          	auipc	a4,0xa9
ffffffffc020333a:	4e973d23          	sd	s1,1274(a4) # ffffffffc02ac830 <bigblocks>
		bb->next = bigblocks;
ffffffffc020333e:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203340:	8522                	mv	a0,s0
ffffffffc0203342:	60e2                	ld	ra,24(sp)
ffffffffc0203344:	6442                	ld	s0,16(sp)
ffffffffc0203346:	64a2                	ld	s1,8(sp)
ffffffffc0203348:	6902                	ld	s2,0(sp)
ffffffffc020334a:	6105                	addi	sp,sp,32
ffffffffc020334c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020334e:	0541                	addi	a0,a0,16
ffffffffc0203350:	e77ff0ef          	jal	ra,ffffffffc02031c6 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203354:	01050413          	addi	s0,a0,16
ffffffffc0203358:	f565                	bnez	a0,ffffffffc0203340 <kmalloc+0x5c>
ffffffffc020335a:	4401                	li	s0,0
}
ffffffffc020335c:	8522                	mv	a0,s0
ffffffffc020335e:	60e2                	ld	ra,24(sp)
ffffffffc0203360:	6442                	ld	s0,16(sp)
ffffffffc0203362:	64a2                	ld	s1,8(sp)
ffffffffc0203364:	6902                	ld	s2,0(sp)
ffffffffc0203366:	6105                	addi	sp,sp,32
ffffffffc0203368:	8082                	ret
        intr_disable();
ffffffffc020336a:	aeafd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
		bb->next = bigblocks;
ffffffffc020336e:	000a9797          	auipc	a5,0xa9
ffffffffc0203372:	4c278793          	addi	a5,a5,1218 # ffffffffc02ac830 <bigblocks>
ffffffffc0203376:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203378:	000a9717          	auipc	a4,0xa9
ffffffffc020337c:	4a973c23          	sd	s1,1208(a4) # ffffffffc02ac830 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203380:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0203382:	accfd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203386:	6480                	ld	s0,8(s1)
}
ffffffffc0203388:	60e2                	ld	ra,24(sp)
ffffffffc020338a:	64a2                	ld	s1,8(sp)
ffffffffc020338c:	8522                	mv	a0,s0
ffffffffc020338e:	6442                	ld	s0,16(sp)
ffffffffc0203390:	6902                	ld	s2,0(sp)
ffffffffc0203392:	6105                	addi	sp,sp,32
ffffffffc0203394:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203396:	45e1                	li	a1,24
ffffffffc0203398:	8526                	mv	a0,s1
ffffffffc020339a:	cabff0ef          	jal	ra,ffffffffc0203044 <slob_free>
  return __kmalloc(size, 0);
ffffffffc020339e:	b74d                	j	ffffffffc0203340 <kmalloc+0x5c>

ffffffffc02033a0 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02033a0:	c175                	beqz	a0,ffffffffc0203484 <kfree+0xe4>
{
ffffffffc02033a2:	1101                	addi	sp,sp,-32
ffffffffc02033a4:	e426                	sd	s1,8(sp)
ffffffffc02033a6:	ec06                	sd	ra,24(sp)
ffffffffc02033a8:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02033aa:	03451793          	slli	a5,a0,0x34
ffffffffc02033ae:	84aa                	mv	s1,a0
ffffffffc02033b0:	eb8d                	bnez	a5,ffffffffc02033e2 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033b2:	100027f3          	csrr	a5,sstatus
ffffffffc02033b6:	8b89                	andi	a5,a5,2
ffffffffc02033b8:	efc9                	bnez	a5,ffffffffc0203452 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02033ba:	000a9797          	auipc	a5,0xa9
ffffffffc02033be:	47678793          	addi	a5,a5,1142 # ffffffffc02ac830 <bigblocks>
ffffffffc02033c2:	6394                	ld	a3,0(a5)
ffffffffc02033c4:	ce99                	beqz	a3,ffffffffc02033e2 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc02033c6:	669c                	ld	a5,8(a3)
ffffffffc02033c8:	6a80                	ld	s0,16(a3)
ffffffffc02033ca:	0af50e63          	beq	a0,a5,ffffffffc0203486 <kfree+0xe6>
    return 0;
ffffffffc02033ce:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02033d0:	c801                	beqz	s0,ffffffffc02033e0 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc02033d2:	6418                	ld	a4,8(s0)
ffffffffc02033d4:	681c                	ld	a5,16(s0)
ffffffffc02033d6:	00970f63          	beq	a4,s1,ffffffffc02033f4 <kfree+0x54>
ffffffffc02033da:	86a2                	mv	a3,s0
ffffffffc02033dc:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02033de:	f875                	bnez	s0,ffffffffc02033d2 <kfree+0x32>
    if (flag) {
ffffffffc02033e0:	e659                	bnez	a2,ffffffffc020346e <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02033e2:	6442                	ld	s0,16(sp)
ffffffffc02033e4:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02033e6:	ff048513          	addi	a0,s1,-16
}
ffffffffc02033ea:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02033ec:	4581                	li	a1,0
}
ffffffffc02033ee:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02033f0:	c55ff06f          	j	ffffffffc0203044 <slob_free>
				*last = bb->next;
ffffffffc02033f4:	ea9c                	sd	a5,16(a3)
ffffffffc02033f6:	e641                	bnez	a2,ffffffffc020347e <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02033f8:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02033fc:	4018                	lw	a4,0(s0)
ffffffffc02033fe:	08f4ea63          	bltu	s1,a5,ffffffffc0203492 <kfree+0xf2>
ffffffffc0203402:	000a9797          	auipc	a5,0xa9
ffffffffc0203406:	47678793          	addi	a5,a5,1142 # ffffffffc02ac878 <va_pa_offset>
ffffffffc020340a:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020340c:	000a9797          	auipc	a5,0xa9
ffffffffc0203410:	41478793          	addi	a5,a5,1044 # ffffffffc02ac820 <npage>
ffffffffc0203414:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0203416:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203418:	80b1                	srli	s1,s1,0xc
ffffffffc020341a:	08f4f963          	bgeu	s1,a5,ffffffffc02034ac <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc020341e:	00006797          	auipc	a5,0x6
ffffffffc0203422:	b6a78793          	addi	a5,a5,-1174 # ffffffffc0208f88 <nbase>
ffffffffc0203426:	639c                	ld	a5,0(a5)
ffffffffc0203428:	000a9697          	auipc	a3,0xa9
ffffffffc020342c:	46068693          	addi	a3,a3,1120 # ffffffffc02ac888 <pages>
ffffffffc0203430:	6288                	ld	a0,0(a3)
ffffffffc0203432:	8c9d                	sub	s1,s1,a5
ffffffffc0203434:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203436:	4585                	li	a1,1
ffffffffc0203438:	9526                	add	a0,a0,s1
ffffffffc020343a:	00e595bb          	sllw	a1,a1,a4
ffffffffc020343e:	aa5fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203442:	8522                	mv	a0,s0
}
ffffffffc0203444:	6442                	ld	s0,16(sp)
ffffffffc0203446:	60e2                	ld	ra,24(sp)
ffffffffc0203448:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020344a:	45e1                	li	a1,24
}
ffffffffc020344c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020344e:	bf7ff06f          	j	ffffffffc0203044 <slob_free>
        intr_disable();
ffffffffc0203452:	a02fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203456:	000a9797          	auipc	a5,0xa9
ffffffffc020345a:	3da78793          	addi	a5,a5,986 # ffffffffc02ac830 <bigblocks>
ffffffffc020345e:	6394                	ld	a3,0(a5)
ffffffffc0203460:	c699                	beqz	a3,ffffffffc020346e <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203462:	669c                	ld	a5,8(a3)
ffffffffc0203464:	6a80                	ld	s0,16(a3)
ffffffffc0203466:	00f48763          	beq	s1,a5,ffffffffc0203474 <kfree+0xd4>
        return 1;
ffffffffc020346a:	4605                	li	a2,1
ffffffffc020346c:	b795                	j	ffffffffc02033d0 <kfree+0x30>
        intr_enable();
ffffffffc020346e:	9e0fd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203472:	bf85                	j	ffffffffc02033e2 <kfree+0x42>
				*last = bb->next;
ffffffffc0203474:	000a9797          	auipc	a5,0xa9
ffffffffc0203478:	3a87be23          	sd	s0,956(a5) # ffffffffc02ac830 <bigblocks>
ffffffffc020347c:	8436                	mv	s0,a3
ffffffffc020347e:	9d0fd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203482:	bf9d                	j	ffffffffc02033f8 <kfree+0x58>
ffffffffc0203484:	8082                	ret
ffffffffc0203486:	000a9797          	auipc	a5,0xa9
ffffffffc020348a:	3a87b523          	sd	s0,938(a5) # ffffffffc02ac830 <bigblocks>
ffffffffc020348e:	8436                	mv	s0,a3
ffffffffc0203490:	b7a5                	j	ffffffffc02033f8 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0203492:	86a6                	mv	a3,s1
ffffffffc0203494:	00004617          	auipc	a2,0x4
ffffffffc0203498:	e6460613          	addi	a2,a2,-412 # ffffffffc02072f8 <commands+0x980>
ffffffffc020349c:	06e00593          	li	a1,110
ffffffffc02034a0:	00004517          	auipc	a0,0x4
ffffffffc02034a4:	dd850513          	addi	a0,a0,-552 # ffffffffc0207278 <commands+0x900>
ffffffffc02034a8:	d6dfc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02034ac:	00004617          	auipc	a2,0x4
ffffffffc02034b0:	dac60613          	addi	a2,a2,-596 # ffffffffc0207258 <commands+0x8e0>
ffffffffc02034b4:	06200593          	li	a1,98
ffffffffc02034b8:	00004517          	auipc	a0,0x4
ffffffffc02034bc:	dc050513          	addi	a0,a0,-576 # ffffffffc0207278 <commands+0x900>
ffffffffc02034c0:	d55fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02034c4 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02034c4:	7135                	addi	sp,sp,-160
ffffffffc02034c6:	ed06                	sd	ra,152(sp)
ffffffffc02034c8:	e922                	sd	s0,144(sp)
ffffffffc02034ca:	e526                	sd	s1,136(sp)
ffffffffc02034cc:	e14a                	sd	s2,128(sp)
ffffffffc02034ce:	fcce                	sd	s3,120(sp)
ffffffffc02034d0:	f8d2                	sd	s4,112(sp)
ffffffffc02034d2:	f4d6                	sd	s5,104(sp)
ffffffffc02034d4:	f0da                	sd	s6,96(sp)
ffffffffc02034d6:	ecde                	sd	s7,88(sp)
ffffffffc02034d8:	e8e2                	sd	s8,80(sp)
ffffffffc02034da:	e4e6                	sd	s9,72(sp)
ffffffffc02034dc:	e0ea                	sd	s10,64(sp)
ffffffffc02034de:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02034e0:	049010ef          	jal	ra,ffffffffc0204d28 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02034e4:	000a9797          	auipc	a5,0xa9
ffffffffc02034e8:	43c78793          	addi	a5,a5,1084 # ffffffffc02ac920 <max_swap_offset>
ffffffffc02034ec:	6394                	ld	a3,0(a5)
ffffffffc02034ee:	010007b7          	lui	a5,0x1000
ffffffffc02034f2:	17e1                	addi	a5,a5,-8
ffffffffc02034f4:	ff968713          	addi	a4,a3,-7
ffffffffc02034f8:	4ae7ee63          	bltu	a5,a4,ffffffffc02039b4 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02034fc:	0009e797          	auipc	a5,0x9e
ffffffffc0203500:	ebc78793          	addi	a5,a5,-324 # ffffffffc02a13b8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203504:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0203506:	000a9697          	auipc	a3,0xa9
ffffffffc020350a:	32f6b923          	sd	a5,818(a3) # ffffffffc02ac838 <sm>
     int r = sm->init();
ffffffffc020350e:	9702                	jalr	a4
ffffffffc0203510:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0203512:	c10d                	beqz	a0,ffffffffc0203534 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203514:	60ea                	ld	ra,152(sp)
ffffffffc0203516:	644a                	ld	s0,144(sp)
ffffffffc0203518:	8556                	mv	a0,s5
ffffffffc020351a:	64aa                	ld	s1,136(sp)
ffffffffc020351c:	690a                	ld	s2,128(sp)
ffffffffc020351e:	79e6                	ld	s3,120(sp)
ffffffffc0203520:	7a46                	ld	s4,112(sp)
ffffffffc0203522:	7aa6                	ld	s5,104(sp)
ffffffffc0203524:	7b06                	ld	s6,96(sp)
ffffffffc0203526:	6be6                	ld	s7,88(sp)
ffffffffc0203528:	6c46                	ld	s8,80(sp)
ffffffffc020352a:	6ca6                	ld	s9,72(sp)
ffffffffc020352c:	6d06                	ld	s10,64(sp)
ffffffffc020352e:	7de2                	ld	s11,56(sp)
ffffffffc0203530:	610d                	addi	sp,sp,160
ffffffffc0203532:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203534:	000a9797          	auipc	a5,0xa9
ffffffffc0203538:	30478793          	addi	a5,a5,772 # ffffffffc02ac838 <sm>
ffffffffc020353c:	639c                	ld	a5,0(a5)
ffffffffc020353e:	00005517          	auipc	a0,0x5
ffffffffc0203542:	84250513          	addi	a0,a0,-1982 # ffffffffc0207d80 <commands+0x1408>
ffffffffc0203546:	000a9417          	auipc	s0,0xa9
ffffffffc020354a:	41a40413          	addi	s0,s0,1050 # ffffffffc02ac960 <free_area>
ffffffffc020354e:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203550:	4785                	li	a5,1
ffffffffc0203552:	000a9717          	auipc	a4,0xa9
ffffffffc0203556:	2ef72723          	sw	a5,750(a4) # ffffffffc02ac840 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020355a:	b77fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020355e:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203560:	36878e63          	beq	a5,s0,ffffffffc02038dc <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203564:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203568:	8305                	srli	a4,a4,0x1
ffffffffc020356a:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020356c:	36070c63          	beqz	a4,ffffffffc02038e4 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203570:	4481                	li	s1,0
ffffffffc0203572:	4901                	li	s2,0
ffffffffc0203574:	a031                	j	ffffffffc0203580 <swap_init+0xbc>
ffffffffc0203576:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020357a:	8b09                	andi	a4,a4,2
ffffffffc020357c:	36070463          	beqz	a4,ffffffffc02038e4 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203580:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203584:	679c                	ld	a5,8(a5)
ffffffffc0203586:	2905                	addiw	s2,s2,1
ffffffffc0203588:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020358a:	fe8796e3          	bne	a5,s0,ffffffffc0203576 <swap_init+0xb2>
ffffffffc020358e:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203590:	999fd0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0203594:	69351863          	bne	a0,s3,ffffffffc0203c24 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203598:	8626                	mv	a2,s1
ffffffffc020359a:	85ca                	mv	a1,s2
ffffffffc020359c:	00005517          	auipc	a0,0x5
ffffffffc02035a0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207dc8 <commands+0x1450>
ffffffffc02035a4:	b2dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02035a8:	e9bfe0ef          	jal	ra,ffffffffc0202442 <mm_create>
ffffffffc02035ac:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02035ae:	60050b63          	beqz	a0,ffffffffc0203bc4 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02035b2:	000a9797          	auipc	a5,0xa9
ffffffffc02035b6:	2de78793          	addi	a5,a5,734 # ffffffffc02ac890 <check_mm_struct>
ffffffffc02035ba:	639c                	ld	a5,0(a5)
ffffffffc02035bc:	62079463          	bnez	a5,ffffffffc0203be4 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02035c0:	000a9797          	auipc	a5,0xa9
ffffffffc02035c4:	25878793          	addi	a5,a5,600 # ffffffffc02ac818 <boot_pgdir>
ffffffffc02035c8:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02035cc:	000a9797          	auipc	a5,0xa9
ffffffffc02035d0:	2ca7b223          	sd	a0,708(a5) # ffffffffc02ac890 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02035d4:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02035d8:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02035dc:	4e079863          	bnez	a5,ffffffffc0203acc <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02035e0:	6599                	lui	a1,0x6
ffffffffc02035e2:	460d                	li	a2,3
ffffffffc02035e4:	6505                	lui	a0,0x1
ffffffffc02035e6:	ea9fe0ef          	jal	ra,ffffffffc020248e <vma_create>
ffffffffc02035ea:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02035ec:	50050063          	beqz	a0,ffffffffc0203aec <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02035f0:	855e                	mv	a0,s7
ffffffffc02035f2:	f09fe0ef          	jal	ra,ffffffffc02024fa <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02035f6:	00005517          	auipc	a0,0x5
ffffffffc02035fa:	81250513          	addi	a0,a0,-2030 # ffffffffc0207e08 <commands+0x1490>
ffffffffc02035fe:	ad3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203602:	018bb503          	ld	a0,24(s7) # 80018 <_binary_obj___user_exit_out_size+0x75550>
ffffffffc0203606:	4605                	li	a2,1
ffffffffc0203608:	6585                	lui	a1,0x1
ffffffffc020360a:	95ffd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020360e:	4e050f63          	beqz	a0,ffffffffc0203b0c <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203612:	00005517          	auipc	a0,0x5
ffffffffc0203616:	84650513          	addi	a0,a0,-1978 # ffffffffc0207e58 <commands+0x14e0>
ffffffffc020361a:	000a9997          	auipc	s3,0xa9
ffffffffc020361e:	27e98993          	addi	s3,s3,638 # ffffffffc02ac898 <check_rp>
ffffffffc0203622:	aaffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203626:	000a9a17          	auipc	s4,0xa9
ffffffffc020362a:	292a0a13          	addi	s4,s4,658 # ffffffffc02ac8b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020362e:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203630:	4505                	li	a0,1
ffffffffc0203632:	829fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203636:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc020363a:	32050d63          	beqz	a0,ffffffffc0203974 <swap_init+0x4b0>
ffffffffc020363e:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203640:	8b89                	andi	a5,a5,2
ffffffffc0203642:	30079963          	bnez	a5,ffffffffc0203954 <swap_init+0x490>
ffffffffc0203646:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203648:	ff4c14e3          	bne	s8,s4,ffffffffc0203630 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc020364c:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc020364e:	000a9c17          	auipc	s8,0xa9
ffffffffc0203652:	24ac0c13          	addi	s8,s8,586 # ffffffffc02ac898 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0203656:	ec3e                	sd	a5,24(sp)
ffffffffc0203658:	641c                	ld	a5,8(s0)
ffffffffc020365a:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc020365c:	481c                	lw	a5,16(s0)
ffffffffc020365e:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203660:	000a9797          	auipc	a5,0xa9
ffffffffc0203664:	3087b423          	sd	s0,776(a5) # ffffffffc02ac968 <free_area+0x8>
ffffffffc0203668:	000a9797          	auipc	a5,0xa9
ffffffffc020366c:	2e87bc23          	sd	s0,760(a5) # ffffffffc02ac960 <free_area>
     nr_free = 0;
ffffffffc0203670:	000a9797          	auipc	a5,0xa9
ffffffffc0203674:	3007a023          	sw	zero,768(a5) # ffffffffc02ac970 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203678:	000c3503          	ld	a0,0(s8)
ffffffffc020367c:	4585                	li	a1,1
ffffffffc020367e:	0c21                	addi	s8,s8,8
ffffffffc0203680:	863fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203684:	ff4c1ae3          	bne	s8,s4,ffffffffc0203678 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203688:	01042c03          	lw	s8,16(s0)
ffffffffc020368c:	4791                	li	a5,4
ffffffffc020368e:	50fc1b63          	bne	s8,a5,ffffffffc0203ba4 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203692:	00005517          	auipc	a0,0x5
ffffffffc0203696:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207ee0 <commands+0x1568>
ffffffffc020369a:	a37fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020369e:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02036a0:	000a9797          	auipc	a5,0xa9
ffffffffc02036a4:	1807a423          	sw	zero,392(a5) # ffffffffc02ac828 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02036a8:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02036aa:	000a9797          	auipc	a5,0xa9
ffffffffc02036ae:	17e78793          	addi	a5,a5,382 # ffffffffc02ac828 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02036b2:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc02036b6:	4398                	lw	a4,0(a5)
ffffffffc02036b8:	4585                	li	a1,1
ffffffffc02036ba:	2701                	sext.w	a4,a4
ffffffffc02036bc:	38b71863          	bne	a4,a1,ffffffffc0203a4c <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02036c0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02036c4:	4394                	lw	a3,0(a5)
ffffffffc02036c6:	2681                	sext.w	a3,a3
ffffffffc02036c8:	3ae69263          	bne	a3,a4,ffffffffc0203a6c <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02036cc:	6689                	lui	a3,0x2
ffffffffc02036ce:	462d                	li	a2,11
ffffffffc02036d0:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc02036d4:	4398                	lw	a4,0(a5)
ffffffffc02036d6:	4589                	li	a1,2
ffffffffc02036d8:	2701                	sext.w	a4,a4
ffffffffc02036da:	2eb71963          	bne	a4,a1,ffffffffc02039cc <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02036de:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02036e2:	4394                	lw	a3,0(a5)
ffffffffc02036e4:	2681                	sext.w	a3,a3
ffffffffc02036e6:	30e69363          	bne	a3,a4,ffffffffc02039ec <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02036ea:	668d                	lui	a3,0x3
ffffffffc02036ec:	4631                	li	a2,12
ffffffffc02036ee:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc02036f2:	4398                	lw	a4,0(a5)
ffffffffc02036f4:	458d                	li	a1,3
ffffffffc02036f6:	2701                	sext.w	a4,a4
ffffffffc02036f8:	30b71a63          	bne	a4,a1,ffffffffc0203a0c <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02036fc:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203700:	4394                	lw	a3,0(a5)
ffffffffc0203702:	2681                	sext.w	a3,a3
ffffffffc0203704:	32e69463          	bne	a3,a4,ffffffffc0203a2c <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203708:	6691                	lui	a3,0x4
ffffffffc020370a:	4635                	li	a2,13
ffffffffc020370c:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc0203710:	4398                	lw	a4,0(a5)
ffffffffc0203712:	2701                	sext.w	a4,a4
ffffffffc0203714:	37871c63          	bne	a4,s8,ffffffffc0203a8c <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203718:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc020371c:	439c                	lw	a5,0(a5)
ffffffffc020371e:	2781                	sext.w	a5,a5
ffffffffc0203720:	38e79663          	bne	a5,a4,ffffffffc0203aac <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203724:	481c                	lw	a5,16(s0)
ffffffffc0203726:	40079363          	bnez	a5,ffffffffc0203b2c <swap_init+0x668>
ffffffffc020372a:	000a9797          	auipc	a5,0xa9
ffffffffc020372e:	18e78793          	addi	a5,a5,398 # ffffffffc02ac8b8 <swap_in_seq_no>
ffffffffc0203732:	000a9717          	auipc	a4,0xa9
ffffffffc0203736:	1ae70713          	addi	a4,a4,430 # ffffffffc02ac8e0 <swap_out_seq_no>
ffffffffc020373a:	000a9617          	auipc	a2,0xa9
ffffffffc020373e:	1a660613          	addi	a2,a2,422 # ffffffffc02ac8e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203742:	56fd                	li	a3,-1
ffffffffc0203744:	c394                	sw	a3,0(a5)
ffffffffc0203746:	c314                	sw	a3,0(a4)
ffffffffc0203748:	0791                	addi	a5,a5,4
ffffffffc020374a:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc020374c:	fef61ce3          	bne	a2,a5,ffffffffc0203744 <swap_init+0x280>
ffffffffc0203750:	000a9697          	auipc	a3,0xa9
ffffffffc0203754:	1f068693          	addi	a3,a3,496 # ffffffffc02ac940 <check_ptep>
ffffffffc0203758:	000a9817          	auipc	a6,0xa9
ffffffffc020375c:	14080813          	addi	a6,a6,320 # ffffffffc02ac898 <check_rp>
ffffffffc0203760:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203762:	000a9c97          	auipc	s9,0xa9
ffffffffc0203766:	0bec8c93          	addi	s9,s9,190 # ffffffffc02ac820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020376a:	00006d97          	auipc	s11,0x6
ffffffffc020376e:	81ed8d93          	addi	s11,s11,-2018 # ffffffffc0208f88 <nbase>
ffffffffc0203772:	000a9c17          	auipc	s8,0xa9
ffffffffc0203776:	116c0c13          	addi	s8,s8,278 # ffffffffc02ac888 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020377a:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020377e:	4601                	li	a2,0
ffffffffc0203780:	85ea                	mv	a1,s10
ffffffffc0203782:	855a                	mv	a0,s6
ffffffffc0203784:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203786:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203788:	fe0fd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc020378c:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc020378e:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203790:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203792:	20050163          	beqz	a0,ffffffffc0203994 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203796:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203798:	0017f613          	andi	a2,a5,1
ffffffffc020379c:	1a060063          	beqz	a2,ffffffffc020393c <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc02037a0:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02037a4:	078a                	slli	a5,a5,0x2
ffffffffc02037a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037a8:	14c7fe63          	bgeu	a5,a2,ffffffffc0203904 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02037ac:	000db703          	ld	a4,0(s11)
ffffffffc02037b0:	000c3603          	ld	a2,0(s8)
ffffffffc02037b4:	00083583          	ld	a1,0(a6)
ffffffffc02037b8:	8f99                	sub	a5,a5,a4
ffffffffc02037ba:	079a                	slli	a5,a5,0x6
ffffffffc02037bc:	e43a                	sd	a4,8(sp)
ffffffffc02037be:	97b2                	add	a5,a5,a2
ffffffffc02037c0:	14f59e63          	bne	a1,a5,ffffffffc020391c <swap_init+0x458>
ffffffffc02037c4:	6785                	lui	a5,0x1
ffffffffc02037c6:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037c8:	6795                	lui	a5,0x5
ffffffffc02037ca:	06a1                	addi	a3,a3,8
ffffffffc02037cc:	0821                	addi	a6,a6,8
ffffffffc02037ce:	fafd16e3          	bne	s10,a5,ffffffffc020377a <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02037d2:	00004517          	auipc	a0,0x4
ffffffffc02037d6:	7c650513          	addi	a0,a0,1990 # ffffffffc0207f98 <commands+0x1620>
ffffffffc02037da:	8f7fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc02037de:	000a9797          	auipc	a5,0xa9
ffffffffc02037e2:	05a78793          	addi	a5,a5,90 # ffffffffc02ac838 <sm>
ffffffffc02037e6:	639c                	ld	a5,0(a5)
ffffffffc02037e8:	7f9c                	ld	a5,56(a5)
ffffffffc02037ea:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02037ec:	40051c63          	bnez	a0,ffffffffc0203c04 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02037f0:	77a2                	ld	a5,40(sp)
ffffffffc02037f2:	000a9717          	auipc	a4,0xa9
ffffffffc02037f6:	16f72f23          	sw	a5,382(a4) # ffffffffc02ac970 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02037fa:	67e2                	ld	a5,24(sp)
ffffffffc02037fc:	000a9717          	auipc	a4,0xa9
ffffffffc0203800:	16f73223          	sd	a5,356(a4) # ffffffffc02ac960 <free_area>
ffffffffc0203804:	7782                	ld	a5,32(sp)
ffffffffc0203806:	000a9717          	auipc	a4,0xa9
ffffffffc020380a:	16f73123          	sd	a5,354(a4) # ffffffffc02ac968 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020380e:	0009b503          	ld	a0,0(s3)
ffffffffc0203812:	4585                	li	a1,1
ffffffffc0203814:	09a1                	addi	s3,s3,8
ffffffffc0203816:	eccfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020381a:	ff499ae3          	bne	s3,s4,ffffffffc020380e <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc020381e:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0203822:	855e                	mv	a0,s7
ffffffffc0203824:	da5fe0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203828:	000a9797          	auipc	a5,0xa9
ffffffffc020382c:	ff078793          	addi	a5,a5,-16 # ffffffffc02ac818 <boot_pgdir>
ffffffffc0203830:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203832:	000a9697          	auipc	a3,0xa9
ffffffffc0203836:	0406bf23          	sd	zero,94(a3) # ffffffffc02ac890 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc020383a:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020383e:	6394                	ld	a3,0(a5)
ffffffffc0203840:	068a                	slli	a3,a3,0x2
ffffffffc0203842:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203844:	0ce6f063          	bgeu	a3,a4,ffffffffc0203904 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203848:	67a2                	ld	a5,8(sp)
ffffffffc020384a:	000c3503          	ld	a0,0(s8)
ffffffffc020384e:	8e9d                	sub	a3,a3,a5
ffffffffc0203850:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203852:	8699                	srai	a3,a3,0x6
ffffffffc0203854:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0203856:	00c69793          	slli	a5,a3,0xc
ffffffffc020385a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020385c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020385e:	2ee7f763          	bgeu	a5,a4,ffffffffc0203b4c <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203862:	000a9797          	auipc	a5,0xa9
ffffffffc0203866:	01678793          	addi	a5,a5,22 # ffffffffc02ac878 <va_pa_offset>
ffffffffc020386a:	639c                	ld	a5,0(a5)
ffffffffc020386c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020386e:	629c                	ld	a5,0(a3)
ffffffffc0203870:	078a                	slli	a5,a5,0x2
ffffffffc0203872:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203874:	08e7f863          	bgeu	a5,a4,ffffffffc0203904 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203878:	69a2                	ld	s3,8(sp)
ffffffffc020387a:	4585                	li	a1,1
ffffffffc020387c:	413787b3          	sub	a5,a5,s3
ffffffffc0203880:	079a                	slli	a5,a5,0x6
ffffffffc0203882:	953e                	add	a0,a0,a5
ffffffffc0203884:	e5efd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203888:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020388c:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203890:	078a                	slli	a5,a5,0x2
ffffffffc0203892:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203894:	06e7f863          	bgeu	a5,a4,ffffffffc0203904 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203898:	000c3503          	ld	a0,0(s8)
ffffffffc020389c:	413787b3          	sub	a5,a5,s3
ffffffffc02038a0:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02038a2:	4585                	li	a1,1
ffffffffc02038a4:	953e                	add	a0,a0,a5
ffffffffc02038a6:	e3cfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     pgdir[0] = 0;
ffffffffc02038aa:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02038ae:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02038b2:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038b4:	00878963          	beq	a5,s0,ffffffffc02038c6 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02038b8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02038bc:	679c                	ld	a5,8(a5)
ffffffffc02038be:	397d                	addiw	s2,s2,-1
ffffffffc02038c0:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038c2:	fe879be3          	bne	a5,s0,ffffffffc02038b8 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc02038c6:	28091f63          	bnez	s2,ffffffffc0203b64 <swap_init+0x6a0>
     assert(total==0);
ffffffffc02038ca:	2a049d63          	bnez	s1,ffffffffc0203b84 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc02038ce:	00004517          	auipc	a0,0x4
ffffffffc02038d2:	71a50513          	addi	a0,a0,1818 # ffffffffc0207fe8 <commands+0x1670>
ffffffffc02038d6:	ffafc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02038da:	b92d                	j	ffffffffc0203514 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02038dc:	4481                	li	s1,0
ffffffffc02038de:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038e0:	4981                	li	s3,0
ffffffffc02038e2:	b17d                	j	ffffffffc0203590 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02038e4:	00004697          	auipc	a3,0x4
ffffffffc02038e8:	4b468693          	addi	a3,a3,1204 # ffffffffc0207d98 <commands+0x1420>
ffffffffc02038ec:	00003617          	auipc	a2,0x3
ffffffffc02038f0:	50c60613          	addi	a2,a2,1292 # ffffffffc0206df8 <commands+0x480>
ffffffffc02038f4:	0bc00593          	li	a1,188
ffffffffc02038f8:	00004517          	auipc	a0,0x4
ffffffffc02038fc:	47850513          	addi	a0,a0,1144 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203900:	915fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203904:	00004617          	auipc	a2,0x4
ffffffffc0203908:	95460613          	addi	a2,a2,-1708 # ffffffffc0207258 <commands+0x8e0>
ffffffffc020390c:	06200593          	li	a1,98
ffffffffc0203910:	00004517          	auipc	a0,0x4
ffffffffc0203914:	96850513          	addi	a0,a0,-1688 # ffffffffc0207278 <commands+0x900>
ffffffffc0203918:	8fdfc0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020391c:	00004697          	auipc	a3,0x4
ffffffffc0203920:	65468693          	addi	a3,a3,1620 # ffffffffc0207f70 <commands+0x15f8>
ffffffffc0203924:	00003617          	auipc	a2,0x3
ffffffffc0203928:	4d460613          	addi	a2,a2,1236 # ffffffffc0206df8 <commands+0x480>
ffffffffc020392c:	0fc00593          	li	a1,252
ffffffffc0203930:	00004517          	auipc	a0,0x4
ffffffffc0203934:	44050513          	addi	a0,a0,1088 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203938:	8ddfc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020393c:	00004617          	auipc	a2,0x4
ffffffffc0203940:	afc60613          	addi	a2,a2,-1284 # ffffffffc0207438 <commands+0xac0>
ffffffffc0203944:	07400593          	li	a1,116
ffffffffc0203948:	00004517          	auipc	a0,0x4
ffffffffc020394c:	93050513          	addi	a0,a0,-1744 # ffffffffc0207278 <commands+0x900>
ffffffffc0203950:	8c5fc0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203954:	00004697          	auipc	a3,0x4
ffffffffc0203958:	54468693          	addi	a3,a3,1348 # ffffffffc0207e98 <commands+0x1520>
ffffffffc020395c:	00003617          	auipc	a2,0x3
ffffffffc0203960:	49c60613          	addi	a2,a2,1180 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203964:	0dd00593          	li	a1,221
ffffffffc0203968:	00004517          	auipc	a0,0x4
ffffffffc020396c:	40850513          	addi	a0,a0,1032 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203970:	8a5fc0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203974:	00004697          	auipc	a3,0x4
ffffffffc0203978:	50c68693          	addi	a3,a3,1292 # ffffffffc0207e80 <commands+0x1508>
ffffffffc020397c:	00003617          	auipc	a2,0x3
ffffffffc0203980:	47c60613          	addi	a2,a2,1148 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203984:	0dc00593          	li	a1,220
ffffffffc0203988:	00004517          	auipc	a0,0x4
ffffffffc020398c:	3e850513          	addi	a0,a0,1000 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203990:	885fc0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203994:	00004697          	auipc	a3,0x4
ffffffffc0203998:	5c468693          	addi	a3,a3,1476 # ffffffffc0207f58 <commands+0x15e0>
ffffffffc020399c:	00003617          	auipc	a2,0x3
ffffffffc02039a0:	45c60613          	addi	a2,a2,1116 # ffffffffc0206df8 <commands+0x480>
ffffffffc02039a4:	0fb00593          	li	a1,251
ffffffffc02039a8:	00004517          	auipc	a0,0x4
ffffffffc02039ac:	3c850513          	addi	a0,a0,968 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc02039b0:	865fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02039b4:	00004617          	auipc	a2,0x4
ffffffffc02039b8:	39c60613          	addi	a2,a2,924 # ffffffffc0207d50 <commands+0x13d8>
ffffffffc02039bc:	02800593          	li	a1,40
ffffffffc02039c0:	00004517          	auipc	a0,0x4
ffffffffc02039c4:	3b050513          	addi	a0,a0,944 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc02039c8:	84dfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc02039cc:	00004697          	auipc	a3,0x4
ffffffffc02039d0:	54c68693          	addi	a3,a3,1356 # ffffffffc0207f18 <commands+0x15a0>
ffffffffc02039d4:	00003617          	auipc	a2,0x3
ffffffffc02039d8:	42460613          	addi	a2,a2,1060 # ffffffffc0206df8 <commands+0x480>
ffffffffc02039dc:	09700593          	li	a1,151
ffffffffc02039e0:	00004517          	auipc	a0,0x4
ffffffffc02039e4:	39050513          	addi	a0,a0,912 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc02039e8:	82dfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc02039ec:	00004697          	auipc	a3,0x4
ffffffffc02039f0:	52c68693          	addi	a3,a3,1324 # ffffffffc0207f18 <commands+0x15a0>
ffffffffc02039f4:	00003617          	auipc	a2,0x3
ffffffffc02039f8:	40460613          	addi	a2,a2,1028 # ffffffffc0206df8 <commands+0x480>
ffffffffc02039fc:	09900593          	li	a1,153
ffffffffc0203a00:	00004517          	auipc	a0,0x4
ffffffffc0203a04:	37050513          	addi	a0,a0,880 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203a08:	80dfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc0203a0c:	00004697          	auipc	a3,0x4
ffffffffc0203a10:	51c68693          	addi	a3,a3,1308 # ffffffffc0207f28 <commands+0x15b0>
ffffffffc0203a14:	00003617          	auipc	a2,0x3
ffffffffc0203a18:	3e460613          	addi	a2,a2,996 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203a1c:	09b00593          	li	a1,155
ffffffffc0203a20:	00004517          	auipc	a0,0x4
ffffffffc0203a24:	35050513          	addi	a0,a0,848 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203a28:	fecfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc0203a2c:	00004697          	auipc	a3,0x4
ffffffffc0203a30:	4fc68693          	addi	a3,a3,1276 # ffffffffc0207f28 <commands+0x15b0>
ffffffffc0203a34:	00003617          	auipc	a2,0x3
ffffffffc0203a38:	3c460613          	addi	a2,a2,964 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203a3c:	09d00593          	li	a1,157
ffffffffc0203a40:	00004517          	auipc	a0,0x4
ffffffffc0203a44:	33050513          	addi	a0,a0,816 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203a48:	fccfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc0203a4c:	00004697          	auipc	a3,0x4
ffffffffc0203a50:	4bc68693          	addi	a3,a3,1212 # ffffffffc0207f08 <commands+0x1590>
ffffffffc0203a54:	00003617          	auipc	a2,0x3
ffffffffc0203a58:	3a460613          	addi	a2,a2,932 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203a5c:	09300593          	li	a1,147
ffffffffc0203a60:	00004517          	auipc	a0,0x4
ffffffffc0203a64:	31050513          	addi	a0,a0,784 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203a68:	facfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc0203a6c:	00004697          	auipc	a3,0x4
ffffffffc0203a70:	49c68693          	addi	a3,a3,1180 # ffffffffc0207f08 <commands+0x1590>
ffffffffc0203a74:	00003617          	auipc	a2,0x3
ffffffffc0203a78:	38460613          	addi	a2,a2,900 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203a7c:	09500593          	li	a1,149
ffffffffc0203a80:	00004517          	auipc	a0,0x4
ffffffffc0203a84:	2f050513          	addi	a0,a0,752 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203a88:	f8cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc0203a8c:	00004697          	auipc	a3,0x4
ffffffffc0203a90:	4ac68693          	addi	a3,a3,1196 # ffffffffc0207f38 <commands+0x15c0>
ffffffffc0203a94:	00003617          	auipc	a2,0x3
ffffffffc0203a98:	36460613          	addi	a2,a2,868 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203a9c:	09f00593          	li	a1,159
ffffffffc0203aa0:	00004517          	auipc	a0,0x4
ffffffffc0203aa4:	2d050513          	addi	a0,a0,720 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203aa8:	f6cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc0203aac:	00004697          	auipc	a3,0x4
ffffffffc0203ab0:	48c68693          	addi	a3,a3,1164 # ffffffffc0207f38 <commands+0x15c0>
ffffffffc0203ab4:	00003617          	auipc	a2,0x3
ffffffffc0203ab8:	34460613          	addi	a2,a2,836 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203abc:	0a100593          	li	a1,161
ffffffffc0203ac0:	00004517          	auipc	a0,0x4
ffffffffc0203ac4:	2b050513          	addi	a0,a0,688 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203ac8:	f4cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203acc:	00004697          	auipc	a3,0x4
ffffffffc0203ad0:	11468693          	addi	a3,a3,276 # ffffffffc0207be0 <commands+0x1268>
ffffffffc0203ad4:	00003617          	auipc	a2,0x3
ffffffffc0203ad8:	32460613          	addi	a2,a2,804 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203adc:	0cc00593          	li	a1,204
ffffffffc0203ae0:	00004517          	auipc	a0,0x4
ffffffffc0203ae4:	29050513          	addi	a0,a0,656 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203ae8:	f2cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(vma != NULL);
ffffffffc0203aec:	00004697          	auipc	a3,0x4
ffffffffc0203af0:	19468693          	addi	a3,a3,404 # ffffffffc0207c80 <commands+0x1308>
ffffffffc0203af4:	00003617          	auipc	a2,0x3
ffffffffc0203af8:	30460613          	addi	a2,a2,772 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203afc:	0cf00593          	li	a1,207
ffffffffc0203b00:	00004517          	auipc	a0,0x4
ffffffffc0203b04:	27050513          	addi	a0,a0,624 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203b08:	f0cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203b0c:	00004697          	auipc	a3,0x4
ffffffffc0203b10:	33468693          	addi	a3,a3,820 # ffffffffc0207e40 <commands+0x14c8>
ffffffffc0203b14:	00003617          	auipc	a2,0x3
ffffffffc0203b18:	2e460613          	addi	a2,a2,740 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203b1c:	0d700593          	li	a1,215
ffffffffc0203b20:	00004517          	auipc	a0,0x4
ffffffffc0203b24:	25050513          	addi	a0,a0,592 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203b28:	eecfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert( nr_free == 0);         
ffffffffc0203b2c:	00004697          	auipc	a3,0x4
ffffffffc0203b30:	41c68693          	addi	a3,a3,1052 # ffffffffc0207f48 <commands+0x15d0>
ffffffffc0203b34:	00003617          	auipc	a2,0x3
ffffffffc0203b38:	2c460613          	addi	a2,a2,708 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203b3c:	0f300593          	li	a1,243
ffffffffc0203b40:	00004517          	auipc	a0,0x4
ffffffffc0203b44:	23050513          	addi	a0,a0,560 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203b48:	eccfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203b4c:	00003617          	auipc	a2,0x3
ffffffffc0203b50:	6d460613          	addi	a2,a2,1748 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0203b54:	06900593          	li	a1,105
ffffffffc0203b58:	00003517          	auipc	a0,0x3
ffffffffc0203b5c:	72050513          	addi	a0,a0,1824 # ffffffffc0207278 <commands+0x900>
ffffffffc0203b60:	eb4fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(count==0);
ffffffffc0203b64:	00004697          	auipc	a3,0x4
ffffffffc0203b68:	46468693          	addi	a3,a3,1124 # ffffffffc0207fc8 <commands+0x1650>
ffffffffc0203b6c:	00003617          	auipc	a2,0x3
ffffffffc0203b70:	28c60613          	addi	a2,a2,652 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203b74:	11d00593          	li	a1,285
ffffffffc0203b78:	00004517          	auipc	a0,0x4
ffffffffc0203b7c:	1f850513          	addi	a0,a0,504 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203b80:	e94fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total==0);
ffffffffc0203b84:	00004697          	auipc	a3,0x4
ffffffffc0203b88:	45468693          	addi	a3,a3,1108 # ffffffffc0207fd8 <commands+0x1660>
ffffffffc0203b8c:	00003617          	auipc	a2,0x3
ffffffffc0203b90:	26c60613          	addi	a2,a2,620 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203b94:	11e00593          	li	a1,286
ffffffffc0203b98:	00004517          	auipc	a0,0x4
ffffffffc0203b9c:	1d850513          	addi	a0,a0,472 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203ba0:	e74fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203ba4:	00004697          	auipc	a3,0x4
ffffffffc0203ba8:	31468693          	addi	a3,a3,788 # ffffffffc0207eb8 <commands+0x1540>
ffffffffc0203bac:	00003617          	auipc	a2,0x3
ffffffffc0203bb0:	24c60613          	addi	a2,a2,588 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203bb4:	0ea00593          	li	a1,234
ffffffffc0203bb8:	00004517          	auipc	a0,0x4
ffffffffc0203bbc:	1b850513          	addi	a0,a0,440 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203bc0:	e54fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(mm != NULL);
ffffffffc0203bc4:	00004697          	auipc	a3,0x4
ffffffffc0203bc8:	e9468693          	addi	a3,a3,-364 # ffffffffc0207a58 <commands+0x10e0>
ffffffffc0203bcc:	00003617          	auipc	a2,0x3
ffffffffc0203bd0:	22c60613          	addi	a2,a2,556 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203bd4:	0c400593          	li	a1,196
ffffffffc0203bd8:	00004517          	auipc	a0,0x4
ffffffffc0203bdc:	19850513          	addi	a0,a0,408 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203be0:	e34fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203be4:	00004697          	auipc	a3,0x4
ffffffffc0203be8:	20c68693          	addi	a3,a3,524 # ffffffffc0207df0 <commands+0x1478>
ffffffffc0203bec:	00003617          	auipc	a2,0x3
ffffffffc0203bf0:	20c60613          	addi	a2,a2,524 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203bf4:	0c700593          	li	a1,199
ffffffffc0203bf8:	00004517          	auipc	a0,0x4
ffffffffc0203bfc:	17850513          	addi	a0,a0,376 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203c00:	e14fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(ret==0);
ffffffffc0203c04:	00004697          	auipc	a3,0x4
ffffffffc0203c08:	3bc68693          	addi	a3,a3,956 # ffffffffc0207fc0 <commands+0x1648>
ffffffffc0203c0c:	00003617          	auipc	a2,0x3
ffffffffc0203c10:	1ec60613          	addi	a2,a2,492 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203c14:	10200593          	li	a1,258
ffffffffc0203c18:	00004517          	auipc	a0,0x4
ffffffffc0203c1c:	15850513          	addi	a0,a0,344 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203c20:	df4fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203c24:	00004697          	auipc	a3,0x4
ffffffffc0203c28:	18468693          	addi	a3,a3,388 # ffffffffc0207da8 <commands+0x1430>
ffffffffc0203c2c:	00003617          	auipc	a2,0x3
ffffffffc0203c30:	1cc60613          	addi	a2,a2,460 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203c34:	0bf00593          	li	a1,191
ffffffffc0203c38:	00004517          	auipc	a0,0x4
ffffffffc0203c3c:	13850513          	addi	a0,a0,312 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203c40:	dd4fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203c44 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203c44:	000a9797          	auipc	a5,0xa9
ffffffffc0203c48:	bf478793          	addi	a5,a5,-1036 # ffffffffc02ac838 <sm>
ffffffffc0203c4c:	639c                	ld	a5,0(a5)
ffffffffc0203c4e:	0107b303          	ld	t1,16(a5)
ffffffffc0203c52:	8302                	jr	t1

ffffffffc0203c54 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203c54:	000a9797          	auipc	a5,0xa9
ffffffffc0203c58:	be478793          	addi	a5,a5,-1052 # ffffffffc02ac838 <sm>
ffffffffc0203c5c:	639c                	ld	a5,0(a5)
ffffffffc0203c5e:	0207b303          	ld	t1,32(a5)
ffffffffc0203c62:	8302                	jr	t1

ffffffffc0203c64 <swap_out>:
{
ffffffffc0203c64:	711d                	addi	sp,sp,-96
ffffffffc0203c66:	ec86                	sd	ra,88(sp)
ffffffffc0203c68:	e8a2                	sd	s0,80(sp)
ffffffffc0203c6a:	e4a6                	sd	s1,72(sp)
ffffffffc0203c6c:	e0ca                	sd	s2,64(sp)
ffffffffc0203c6e:	fc4e                	sd	s3,56(sp)
ffffffffc0203c70:	f852                	sd	s4,48(sp)
ffffffffc0203c72:	f456                	sd	s5,40(sp)
ffffffffc0203c74:	f05a                	sd	s6,32(sp)
ffffffffc0203c76:	ec5e                	sd	s7,24(sp)
ffffffffc0203c78:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203c7a:	cde9                	beqz	a1,ffffffffc0203d54 <swap_out+0xf0>
ffffffffc0203c7c:	8ab2                	mv	s5,a2
ffffffffc0203c7e:	892a                	mv	s2,a0
ffffffffc0203c80:	8a2e                	mv	s4,a1
ffffffffc0203c82:	4401                	li	s0,0
ffffffffc0203c84:	000a9997          	auipc	s3,0xa9
ffffffffc0203c88:	bb498993          	addi	s3,s3,-1100 # ffffffffc02ac838 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c8c:	00004b17          	auipc	s6,0x4
ffffffffc0203c90:	3dcb0b13          	addi	s6,s6,988 # ffffffffc0208068 <commands+0x16f0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c94:	00004b97          	auipc	s7,0x4
ffffffffc0203c98:	3bcb8b93          	addi	s7,s7,956 # ffffffffc0208050 <commands+0x16d8>
ffffffffc0203c9c:	a825                	j	ffffffffc0203cd4 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c9e:	67a2                	ld	a5,8(sp)
ffffffffc0203ca0:	8626                	mv	a2,s1
ffffffffc0203ca2:	85a2                	mv	a1,s0
ffffffffc0203ca4:	7f94                	ld	a3,56(a5)
ffffffffc0203ca6:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203ca8:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203caa:	82b1                	srli	a3,a3,0xc
ffffffffc0203cac:	0685                	addi	a3,a3,1
ffffffffc0203cae:	c22fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203cb2:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203cb4:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203cb6:	7d1c                	ld	a5,56(a0)
ffffffffc0203cb8:	83b1                	srli	a5,a5,0xc
ffffffffc0203cba:	0785                	addi	a5,a5,1
ffffffffc0203cbc:	07a2                	slli	a5,a5,0x8
ffffffffc0203cbe:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203cc2:	a20fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203cc6:	01893503          	ld	a0,24(s2)
ffffffffc0203cca:	85a6                	mv	a1,s1
ffffffffc0203ccc:	e9cfe0ef          	jal	ra,ffffffffc0202368 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203cd0:	048a0d63          	beq	s4,s0,ffffffffc0203d2a <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203cd4:	0009b783          	ld	a5,0(s3)
ffffffffc0203cd8:	8656                	mv	a2,s5
ffffffffc0203cda:	002c                	addi	a1,sp,8
ffffffffc0203cdc:	7b9c                	ld	a5,48(a5)
ffffffffc0203cde:	854a                	mv	a0,s2
ffffffffc0203ce0:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203ce2:	e12d                	bnez	a0,ffffffffc0203d44 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203ce4:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ce6:	01893503          	ld	a0,24(s2)
ffffffffc0203cea:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203cec:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203cee:	85a6                	mv	a1,s1
ffffffffc0203cf0:	a78fd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203cf4:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203cf6:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203cf8:	8b85                	andi	a5,a5,1
ffffffffc0203cfa:	cfb9                	beqz	a5,ffffffffc0203d58 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203cfc:	65a2                	ld	a1,8(sp)
ffffffffc0203cfe:	7d9c                	ld	a5,56(a1)
ffffffffc0203d00:	83b1                	srli	a5,a5,0xc
ffffffffc0203d02:	00178513          	addi	a0,a5,1
ffffffffc0203d06:	0522                	slli	a0,a0,0x8
ffffffffc0203d08:	0f0010ef          	jal	ra,ffffffffc0204df8 <swapfs_write>
ffffffffc0203d0c:	d949                	beqz	a0,ffffffffc0203c9e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203d0e:	855e                	mv	a0,s7
ffffffffc0203d10:	bc0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203d14:	0009b783          	ld	a5,0(s3)
ffffffffc0203d18:	6622                	ld	a2,8(sp)
ffffffffc0203d1a:	4681                	li	a3,0
ffffffffc0203d1c:	739c                	ld	a5,32(a5)
ffffffffc0203d1e:	85a6                	mv	a1,s1
ffffffffc0203d20:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203d22:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203d24:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203d26:	fa8a17e3          	bne	s4,s0,ffffffffc0203cd4 <swap_out+0x70>
}
ffffffffc0203d2a:	8522                	mv	a0,s0
ffffffffc0203d2c:	60e6                	ld	ra,88(sp)
ffffffffc0203d2e:	6446                	ld	s0,80(sp)
ffffffffc0203d30:	64a6                	ld	s1,72(sp)
ffffffffc0203d32:	6906                	ld	s2,64(sp)
ffffffffc0203d34:	79e2                	ld	s3,56(sp)
ffffffffc0203d36:	7a42                	ld	s4,48(sp)
ffffffffc0203d38:	7aa2                	ld	s5,40(sp)
ffffffffc0203d3a:	7b02                	ld	s6,32(sp)
ffffffffc0203d3c:	6be2                	ld	s7,24(sp)
ffffffffc0203d3e:	6c42                	ld	s8,16(sp)
ffffffffc0203d40:	6125                	addi	sp,sp,96
ffffffffc0203d42:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203d44:	85a2                	mv	a1,s0
ffffffffc0203d46:	00004517          	auipc	a0,0x4
ffffffffc0203d4a:	2c250513          	addi	a0,a0,706 # ffffffffc0208008 <commands+0x1690>
ffffffffc0203d4e:	b82fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0203d52:	bfe1                	j	ffffffffc0203d2a <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203d54:	4401                	li	s0,0
ffffffffc0203d56:	bfd1                	j	ffffffffc0203d2a <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203d58:	00004697          	auipc	a3,0x4
ffffffffc0203d5c:	2e068693          	addi	a3,a3,736 # ffffffffc0208038 <commands+0x16c0>
ffffffffc0203d60:	00003617          	auipc	a2,0x3
ffffffffc0203d64:	09860613          	addi	a2,a2,152 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203d68:	06800593          	li	a1,104
ffffffffc0203d6c:	00004517          	auipc	a0,0x4
ffffffffc0203d70:	00450513          	addi	a0,a0,4 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203d74:	ca0fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203d78 <swap_in>:
{
ffffffffc0203d78:	7179                	addi	sp,sp,-48
ffffffffc0203d7a:	e84a                	sd	s2,16(sp)
ffffffffc0203d7c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203d7e:	4505                	li	a0,1
{
ffffffffc0203d80:	ec26                	sd	s1,24(sp)
ffffffffc0203d82:	e44e                	sd	s3,8(sp)
ffffffffc0203d84:	f406                	sd	ra,40(sp)
ffffffffc0203d86:	f022                	sd	s0,32(sp)
ffffffffc0203d88:	84ae                	mv	s1,a1
ffffffffc0203d8a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203d8c:	8cefd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
     assert(result!=NULL);
ffffffffc0203d90:	c129                	beqz	a0,ffffffffc0203dd2 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d92:	842a                	mv	s0,a0
ffffffffc0203d94:	01893503          	ld	a0,24(s2)
ffffffffc0203d98:	4601                	li	a2,0
ffffffffc0203d9a:	85a6                	mv	a1,s1
ffffffffc0203d9c:	9ccfd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0203da0:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203da2:	6108                	ld	a0,0(a0)
ffffffffc0203da4:	85a2                	mv	a1,s0
ffffffffc0203da6:	7bb000ef          	jal	ra,ffffffffc0204d60 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203daa:	00093583          	ld	a1,0(s2)
ffffffffc0203dae:	8626                	mv	a2,s1
ffffffffc0203db0:	00004517          	auipc	a0,0x4
ffffffffc0203db4:	f6050513          	addi	a0,a0,-160 # ffffffffc0207d10 <commands+0x1398>
ffffffffc0203db8:	81a1                	srli	a1,a1,0x8
ffffffffc0203dba:	b16fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203dbe:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203dc0:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203dc4:	7402                	ld	s0,32(sp)
ffffffffc0203dc6:	64e2                	ld	s1,24(sp)
ffffffffc0203dc8:	6942                	ld	s2,16(sp)
ffffffffc0203dca:	69a2                	ld	s3,8(sp)
ffffffffc0203dcc:	4501                	li	a0,0
ffffffffc0203dce:	6145                	addi	sp,sp,48
ffffffffc0203dd0:	8082                	ret
     assert(result!=NULL);
ffffffffc0203dd2:	00004697          	auipc	a3,0x4
ffffffffc0203dd6:	f2e68693          	addi	a3,a3,-210 # ffffffffc0207d00 <commands+0x1388>
ffffffffc0203dda:	00003617          	auipc	a2,0x3
ffffffffc0203dde:	01e60613          	addi	a2,a2,30 # ffffffffc0206df8 <commands+0x480>
ffffffffc0203de2:	07e00593          	li	a1,126
ffffffffc0203de6:	00004517          	auipc	a0,0x4
ffffffffc0203dea:	f8a50513          	addi	a0,a0,-118 # ffffffffc0207d70 <commands+0x13f8>
ffffffffc0203dee:	c26fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203df2 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203df2:	000a9797          	auipc	a5,0xa9
ffffffffc0203df6:	b6e78793          	addi	a5,a5,-1170 # ffffffffc02ac960 <free_area>
ffffffffc0203dfa:	e79c                	sd	a5,8(a5)
ffffffffc0203dfc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203dfe:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203e02:	8082                	ret

ffffffffc0203e04 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203e04:	000a9517          	auipc	a0,0xa9
ffffffffc0203e08:	b6c56503          	lwu	a0,-1172(a0) # ffffffffc02ac970 <free_area+0x10>
ffffffffc0203e0c:	8082                	ret

ffffffffc0203e0e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203e0e:	715d                	addi	sp,sp,-80
ffffffffc0203e10:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203e12:	000a9917          	auipc	s2,0xa9
ffffffffc0203e16:	b4e90913          	addi	s2,s2,-1202 # ffffffffc02ac960 <free_area>
ffffffffc0203e1a:	00893783          	ld	a5,8(s2)
ffffffffc0203e1e:	e486                	sd	ra,72(sp)
ffffffffc0203e20:	e0a2                	sd	s0,64(sp)
ffffffffc0203e22:	fc26                	sd	s1,56(sp)
ffffffffc0203e24:	f44e                	sd	s3,40(sp)
ffffffffc0203e26:	f052                	sd	s4,32(sp)
ffffffffc0203e28:	ec56                	sd	s5,24(sp)
ffffffffc0203e2a:	e85a                	sd	s6,16(sp)
ffffffffc0203e2c:	e45e                	sd	s7,8(sp)
ffffffffc0203e2e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203e30:	31278463          	beq	a5,s2,ffffffffc0204138 <default_check+0x32a>
ffffffffc0203e34:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203e38:	8305                	srli	a4,a4,0x1
ffffffffc0203e3a:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203e3c:	30070263          	beqz	a4,ffffffffc0204140 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0203e40:	4401                	li	s0,0
ffffffffc0203e42:	4481                	li	s1,0
ffffffffc0203e44:	a031                	j	ffffffffc0203e50 <default_check+0x42>
ffffffffc0203e46:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203e4a:	8b09                	andi	a4,a4,2
ffffffffc0203e4c:	2e070a63          	beqz	a4,ffffffffc0204140 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0203e50:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203e54:	679c                	ld	a5,8(a5)
ffffffffc0203e56:	2485                	addiw	s1,s1,1
ffffffffc0203e58:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203e5a:	ff2796e3          	bne	a5,s2,ffffffffc0203e46 <default_check+0x38>
ffffffffc0203e5e:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203e60:	8c8fd0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0203e64:	73351e63          	bne	a0,s3,ffffffffc02045a0 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203e68:	4505                	li	a0,1
ffffffffc0203e6a:	ff1fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e6e:	8a2a                	mv	s4,a0
ffffffffc0203e70:	46050863          	beqz	a0,ffffffffc02042e0 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203e74:	4505                	li	a0,1
ffffffffc0203e76:	fe5fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e7a:	89aa                	mv	s3,a0
ffffffffc0203e7c:	74050263          	beqz	a0,ffffffffc02045c0 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203e80:	4505                	li	a0,1
ffffffffc0203e82:	fd9fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e86:	8aaa                	mv	s5,a0
ffffffffc0203e88:	4c050c63          	beqz	a0,ffffffffc0204360 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203e8c:	2d3a0a63          	beq	s4,s3,ffffffffc0204160 <default_check+0x352>
ffffffffc0203e90:	2caa0863          	beq	s4,a0,ffffffffc0204160 <default_check+0x352>
ffffffffc0203e94:	2ca98663          	beq	s3,a0,ffffffffc0204160 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203e98:	000a2783          	lw	a5,0(s4)
ffffffffc0203e9c:	2e079263          	bnez	a5,ffffffffc0204180 <default_check+0x372>
ffffffffc0203ea0:	0009a783          	lw	a5,0(s3)
ffffffffc0203ea4:	2c079e63          	bnez	a5,ffffffffc0204180 <default_check+0x372>
ffffffffc0203ea8:	411c                	lw	a5,0(a0)
ffffffffc0203eaa:	2c079b63          	bnez	a5,ffffffffc0204180 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0203eae:	000a9797          	auipc	a5,0xa9
ffffffffc0203eb2:	9da78793          	addi	a5,a5,-1574 # ffffffffc02ac888 <pages>
ffffffffc0203eb6:	639c                	ld	a5,0(a5)
ffffffffc0203eb8:	00005717          	auipc	a4,0x5
ffffffffc0203ebc:	0d070713          	addi	a4,a4,208 # ffffffffc0208f88 <nbase>
ffffffffc0203ec0:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203ec2:	000a9717          	auipc	a4,0xa9
ffffffffc0203ec6:	95e70713          	addi	a4,a4,-1698 # ffffffffc02ac820 <npage>
ffffffffc0203eca:	6314                	ld	a3,0(a4)
ffffffffc0203ecc:	40fa0733          	sub	a4,s4,a5
ffffffffc0203ed0:	8719                	srai	a4,a4,0x6
ffffffffc0203ed2:	9732                	add	a4,a4,a2
ffffffffc0203ed4:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ed6:	0732                	slli	a4,a4,0xc
ffffffffc0203ed8:	2cd77463          	bgeu	a4,a3,ffffffffc02041a0 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0203edc:	40f98733          	sub	a4,s3,a5
ffffffffc0203ee0:	8719                	srai	a4,a4,0x6
ffffffffc0203ee2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ee4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203ee6:	4ed77d63          	bgeu	a4,a3,ffffffffc02043e0 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0203eea:	40f507b3          	sub	a5,a0,a5
ffffffffc0203eee:	8799                	srai	a5,a5,0x6
ffffffffc0203ef0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ef2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203ef4:	34d7f663          	bgeu	a5,a3,ffffffffc0204240 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0203ef8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203efa:	00093c03          	ld	s8,0(s2)
ffffffffc0203efe:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0203f02:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0203f06:	000a9797          	auipc	a5,0xa9
ffffffffc0203f0a:	a727b123          	sd	s2,-1438(a5) # ffffffffc02ac968 <free_area+0x8>
ffffffffc0203f0e:	000a9797          	auipc	a5,0xa9
ffffffffc0203f12:	a527b923          	sd	s2,-1454(a5) # ffffffffc02ac960 <free_area>
    nr_free = 0;
ffffffffc0203f16:	000a9797          	auipc	a5,0xa9
ffffffffc0203f1a:	a407ad23          	sw	zero,-1446(a5) # ffffffffc02ac970 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203f1e:	f3dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f22:	2e051f63          	bnez	a0,ffffffffc0204220 <default_check+0x412>
    free_page(p0);
ffffffffc0203f26:	4585                	li	a1,1
ffffffffc0203f28:	8552                	mv	a0,s4
ffffffffc0203f2a:	fb9fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p1);
ffffffffc0203f2e:	4585                	li	a1,1
ffffffffc0203f30:	854e                	mv	a0,s3
ffffffffc0203f32:	fb1fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0203f36:	4585                	li	a1,1
ffffffffc0203f38:	8556                	mv	a0,s5
ffffffffc0203f3a:	fa9fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(nr_free == 3);
ffffffffc0203f3e:	01092703          	lw	a4,16(s2)
ffffffffc0203f42:	478d                	li	a5,3
ffffffffc0203f44:	2af71e63          	bne	a4,a5,ffffffffc0204200 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203f48:	4505                	li	a0,1
ffffffffc0203f4a:	f11fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f4e:	89aa                	mv	s3,a0
ffffffffc0203f50:	28050863          	beqz	a0,ffffffffc02041e0 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203f54:	4505                	li	a0,1
ffffffffc0203f56:	f05fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f5a:	8aaa                	mv	s5,a0
ffffffffc0203f5c:	3e050263          	beqz	a0,ffffffffc0204340 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203f60:	4505                	li	a0,1
ffffffffc0203f62:	ef9fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f66:	8a2a                	mv	s4,a0
ffffffffc0203f68:	3a050c63          	beqz	a0,ffffffffc0204320 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0203f6c:	4505                	li	a0,1
ffffffffc0203f6e:	eedfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f72:	38051763          	bnez	a0,ffffffffc0204300 <default_check+0x4f2>
    free_page(p0);
ffffffffc0203f76:	4585                	li	a1,1
ffffffffc0203f78:	854e                	mv	a0,s3
ffffffffc0203f7a:	f69fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203f7e:	00893783          	ld	a5,8(s2)
ffffffffc0203f82:	23278f63          	beq	a5,s2,ffffffffc02041c0 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0203f86:	4505                	li	a0,1
ffffffffc0203f88:	ed3fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f8c:	32a99a63          	bne	s3,a0,ffffffffc02042c0 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0203f90:	4505                	li	a0,1
ffffffffc0203f92:	ec9fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203f96:	30051563          	bnez	a0,ffffffffc02042a0 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0203f9a:	01092783          	lw	a5,16(s2)
ffffffffc0203f9e:	2e079163          	bnez	a5,ffffffffc0204280 <default_check+0x472>
    free_page(p);
ffffffffc0203fa2:	854e                	mv	a0,s3
ffffffffc0203fa4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0203fa6:	000a9797          	auipc	a5,0xa9
ffffffffc0203faa:	9b87bd23          	sd	s8,-1606(a5) # ffffffffc02ac960 <free_area>
ffffffffc0203fae:	000a9797          	auipc	a5,0xa9
ffffffffc0203fb2:	9b77bd23          	sd	s7,-1606(a5) # ffffffffc02ac968 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0203fb6:	000a9797          	auipc	a5,0xa9
ffffffffc0203fba:	9b67ad23          	sw	s6,-1606(a5) # ffffffffc02ac970 <free_area+0x10>
    free_page(p);
ffffffffc0203fbe:	f25fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p1);
ffffffffc0203fc2:	4585                	li	a1,1
ffffffffc0203fc4:	8556                	mv	a0,s5
ffffffffc0203fc6:	f1dfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0203fca:	4585                	li	a1,1
ffffffffc0203fcc:	8552                	mv	a0,s4
ffffffffc0203fce:	f15fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0203fd2:	4515                	li	a0,5
ffffffffc0203fd4:	e87fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203fd8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0203fda:	28050363          	beqz	a0,ffffffffc0204260 <default_check+0x452>
ffffffffc0203fde:	651c                	ld	a5,8(a0)
ffffffffc0203fe0:	8385                	srli	a5,a5,0x1
ffffffffc0203fe2:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0203fe4:	54079e63          	bnez	a5,ffffffffc0204540 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0203fe8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203fea:	00093b03          	ld	s6,0(s2)
ffffffffc0203fee:	00893a83          	ld	s5,8(s2)
ffffffffc0203ff2:	000a9797          	auipc	a5,0xa9
ffffffffc0203ff6:	9727b723          	sd	s2,-1682(a5) # ffffffffc02ac960 <free_area>
ffffffffc0203ffa:	000a9797          	auipc	a5,0xa9
ffffffffc0203ffe:	9727b723          	sd	s2,-1682(a5) # ffffffffc02ac968 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0204002:	e59fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204006:	50051d63          	bnez	a0,ffffffffc0204520 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020400a:	08098a13          	addi	s4,s3,128
ffffffffc020400e:	8552                	mv	a0,s4
ffffffffc0204010:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0204012:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0204016:	000a9797          	auipc	a5,0xa9
ffffffffc020401a:	9407ad23          	sw	zero,-1702(a5) # ffffffffc02ac970 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020401e:	ec5fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0204022:	4511                	li	a0,4
ffffffffc0204024:	e37fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204028:	4c051c63          	bnez	a0,ffffffffc0204500 <default_check+0x6f2>
ffffffffc020402c:	0889b783          	ld	a5,136(s3)
ffffffffc0204030:	8385                	srli	a5,a5,0x1
ffffffffc0204032:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0204034:	4a078663          	beqz	a5,ffffffffc02044e0 <default_check+0x6d2>
ffffffffc0204038:	0909a703          	lw	a4,144(s3)
ffffffffc020403c:	478d                	li	a5,3
ffffffffc020403e:	4af71163          	bne	a4,a5,ffffffffc02044e0 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204042:	450d                	li	a0,3
ffffffffc0204044:	e17fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204048:	8c2a                	mv	s8,a0
ffffffffc020404a:	46050b63          	beqz	a0,ffffffffc02044c0 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc020404e:	4505                	li	a0,1
ffffffffc0204050:	e0bfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204054:	44051663          	bnez	a0,ffffffffc02044a0 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0204058:	438a1463          	bne	s4,s8,ffffffffc0204480 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020405c:	4585                	li	a1,1
ffffffffc020405e:	854e                	mv	a0,s3
ffffffffc0204060:	e83fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_pages(p1, 3);
ffffffffc0204064:	458d                	li	a1,3
ffffffffc0204066:	8552                	mv	a0,s4
ffffffffc0204068:	e7bfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc020406c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0204070:	04098c13          	addi	s8,s3,64
ffffffffc0204074:	8385                	srli	a5,a5,0x1
ffffffffc0204076:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204078:	3e078463          	beqz	a5,ffffffffc0204460 <default_check+0x652>
ffffffffc020407c:	0109a703          	lw	a4,16(s3)
ffffffffc0204080:	4785                	li	a5,1
ffffffffc0204082:	3cf71f63          	bne	a4,a5,ffffffffc0204460 <default_check+0x652>
ffffffffc0204086:	008a3783          	ld	a5,8(s4)
ffffffffc020408a:	8385                	srli	a5,a5,0x1
ffffffffc020408c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020408e:	3a078963          	beqz	a5,ffffffffc0204440 <default_check+0x632>
ffffffffc0204092:	010a2703          	lw	a4,16(s4)
ffffffffc0204096:	478d                	li	a5,3
ffffffffc0204098:	3af71463          	bne	a4,a5,ffffffffc0204440 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020409c:	4505                	li	a0,1
ffffffffc020409e:	dbdfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02040a2:	36a99f63          	bne	s3,a0,ffffffffc0204420 <default_check+0x612>
    free_page(p0);
ffffffffc02040a6:	4585                	li	a1,1
ffffffffc02040a8:	e3bfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02040ac:	4509                	li	a0,2
ffffffffc02040ae:	dadfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02040b2:	34aa1763          	bne	s4,a0,ffffffffc0204400 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02040b6:	4589                	li	a1,2
ffffffffc02040b8:	e2bfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc02040bc:	4585                	li	a1,1
ffffffffc02040be:	8562                	mv	a0,s8
ffffffffc02040c0:	e23fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02040c4:	4515                	li	a0,5
ffffffffc02040c6:	d95fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02040ca:	89aa                	mv	s3,a0
ffffffffc02040cc:	48050a63          	beqz	a0,ffffffffc0204560 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02040d0:	4505                	li	a0,1
ffffffffc02040d2:	d89fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02040d6:	2e051563          	bnez	a0,ffffffffc02043c0 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02040da:	01092783          	lw	a5,16(s2)
ffffffffc02040de:	2c079163          	bnez	a5,ffffffffc02043a0 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02040e2:	4595                	li	a1,5
ffffffffc02040e4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02040e6:	000a9797          	auipc	a5,0xa9
ffffffffc02040ea:	8977a523          	sw	s7,-1910(a5) # ffffffffc02ac970 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02040ee:	000a9797          	auipc	a5,0xa9
ffffffffc02040f2:	8767b923          	sd	s6,-1934(a5) # ffffffffc02ac960 <free_area>
ffffffffc02040f6:	000a9797          	auipc	a5,0xa9
ffffffffc02040fa:	8757b923          	sd	s5,-1934(a5) # ffffffffc02ac968 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02040fe:	de5fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return listelm->next;
ffffffffc0204102:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204106:	01278963          	beq	a5,s2,ffffffffc0204118 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020410a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020410e:	679c                	ld	a5,8(a5)
ffffffffc0204110:	34fd                	addiw	s1,s1,-1
ffffffffc0204112:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204114:	ff279be3          	bne	a5,s2,ffffffffc020410a <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0204118:	26049463          	bnez	s1,ffffffffc0204380 <default_check+0x572>
    assert(total == 0);
ffffffffc020411c:	46041263          	bnez	s0,ffffffffc0204580 <default_check+0x772>
}
ffffffffc0204120:	60a6                	ld	ra,72(sp)
ffffffffc0204122:	6406                	ld	s0,64(sp)
ffffffffc0204124:	74e2                	ld	s1,56(sp)
ffffffffc0204126:	7942                	ld	s2,48(sp)
ffffffffc0204128:	79a2                	ld	s3,40(sp)
ffffffffc020412a:	7a02                	ld	s4,32(sp)
ffffffffc020412c:	6ae2                	ld	s5,24(sp)
ffffffffc020412e:	6b42                	ld	s6,16(sp)
ffffffffc0204130:	6ba2                	ld	s7,8(sp)
ffffffffc0204132:	6c02                	ld	s8,0(sp)
ffffffffc0204134:	6161                	addi	sp,sp,80
ffffffffc0204136:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204138:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020413a:	4401                	li	s0,0
ffffffffc020413c:	4481                	li	s1,0
ffffffffc020413e:	b30d                	j	ffffffffc0203e60 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0204140:	00004697          	auipc	a3,0x4
ffffffffc0204144:	c5868693          	addi	a3,a3,-936 # ffffffffc0207d98 <commands+0x1420>
ffffffffc0204148:	00003617          	auipc	a2,0x3
ffffffffc020414c:	cb060613          	addi	a2,a2,-848 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204150:	0f000593          	li	a1,240
ffffffffc0204154:	00004517          	auipc	a0,0x4
ffffffffc0204158:	f5450513          	addi	a0,a0,-172 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020415c:	8b8fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204160:	00004697          	auipc	a3,0x4
ffffffffc0204164:	fc068693          	addi	a3,a3,-64 # ffffffffc0208120 <commands+0x17a8>
ffffffffc0204168:	00003617          	auipc	a2,0x3
ffffffffc020416c:	c9060613          	addi	a2,a2,-880 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204170:	0bd00593          	li	a1,189
ffffffffc0204174:	00004517          	auipc	a0,0x4
ffffffffc0204178:	f3450513          	addi	a0,a0,-204 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020417c:	898fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204180:	00004697          	auipc	a3,0x4
ffffffffc0204184:	fc868693          	addi	a3,a3,-56 # ffffffffc0208148 <commands+0x17d0>
ffffffffc0204188:	00003617          	auipc	a2,0x3
ffffffffc020418c:	c7060613          	addi	a2,a2,-912 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204190:	0be00593          	li	a1,190
ffffffffc0204194:	00004517          	auipc	a0,0x4
ffffffffc0204198:	f1450513          	addi	a0,a0,-236 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020419c:	878fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02041a0:	00004697          	auipc	a3,0x4
ffffffffc02041a4:	fe868693          	addi	a3,a3,-24 # ffffffffc0208188 <commands+0x1810>
ffffffffc02041a8:	00003617          	auipc	a2,0x3
ffffffffc02041ac:	c5060613          	addi	a2,a2,-944 # ffffffffc0206df8 <commands+0x480>
ffffffffc02041b0:	0c000593          	li	a1,192
ffffffffc02041b4:	00004517          	auipc	a0,0x4
ffffffffc02041b8:	ef450513          	addi	a0,a0,-268 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02041bc:	858fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02041c0:	00004697          	auipc	a3,0x4
ffffffffc02041c4:	05068693          	addi	a3,a3,80 # ffffffffc0208210 <commands+0x1898>
ffffffffc02041c8:	00003617          	auipc	a2,0x3
ffffffffc02041cc:	c3060613          	addi	a2,a2,-976 # ffffffffc0206df8 <commands+0x480>
ffffffffc02041d0:	0d900593          	li	a1,217
ffffffffc02041d4:	00004517          	auipc	a0,0x4
ffffffffc02041d8:	ed450513          	addi	a0,a0,-300 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02041dc:	838fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02041e0:	00004697          	auipc	a3,0x4
ffffffffc02041e4:	ee068693          	addi	a3,a3,-288 # ffffffffc02080c0 <commands+0x1748>
ffffffffc02041e8:	00003617          	auipc	a2,0x3
ffffffffc02041ec:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206df8 <commands+0x480>
ffffffffc02041f0:	0d200593          	li	a1,210
ffffffffc02041f4:	00004517          	auipc	a0,0x4
ffffffffc02041f8:	eb450513          	addi	a0,a0,-332 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02041fc:	818fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 3);
ffffffffc0204200:	00004697          	auipc	a3,0x4
ffffffffc0204204:	00068693          	mv	a3,a3
ffffffffc0204208:	00003617          	auipc	a2,0x3
ffffffffc020420c:	bf060613          	addi	a2,a2,-1040 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204210:	0d000593          	li	a1,208
ffffffffc0204214:	00004517          	auipc	a0,0x4
ffffffffc0204218:	e9450513          	addi	a0,a0,-364 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020421c:	ff9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204220:	00004697          	auipc	a3,0x4
ffffffffc0204224:	fc868693          	addi	a3,a3,-56 # ffffffffc02081e8 <commands+0x1870>
ffffffffc0204228:	00003617          	auipc	a2,0x3
ffffffffc020422c:	bd060613          	addi	a2,a2,-1072 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204230:	0cb00593          	li	a1,203
ffffffffc0204234:	00004517          	auipc	a0,0x4
ffffffffc0204238:	e7450513          	addi	a0,a0,-396 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020423c:	fd9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0204240:	00004697          	auipc	a3,0x4
ffffffffc0204244:	f8868693          	addi	a3,a3,-120 # ffffffffc02081c8 <commands+0x1850>
ffffffffc0204248:	00003617          	auipc	a2,0x3
ffffffffc020424c:	bb060613          	addi	a2,a2,-1104 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204250:	0c200593          	li	a1,194
ffffffffc0204254:	00004517          	auipc	a0,0x4
ffffffffc0204258:	e5450513          	addi	a0,a0,-428 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020425c:	fb9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != NULL);
ffffffffc0204260:	00004697          	auipc	a3,0x4
ffffffffc0204264:	fe868693          	addi	a3,a3,-24 # ffffffffc0208248 <commands+0x18d0>
ffffffffc0204268:	00003617          	auipc	a2,0x3
ffffffffc020426c:	b9060613          	addi	a2,a2,-1136 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204270:	0f800593          	li	a1,248
ffffffffc0204274:	00004517          	auipc	a0,0x4
ffffffffc0204278:	e3450513          	addi	a0,a0,-460 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020427c:	f99fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc0204280:	00004697          	auipc	a3,0x4
ffffffffc0204284:	cc868693          	addi	a3,a3,-824 # ffffffffc0207f48 <commands+0x15d0>
ffffffffc0204288:	00003617          	auipc	a2,0x3
ffffffffc020428c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204290:	0df00593          	li	a1,223
ffffffffc0204294:	00004517          	auipc	a0,0x4
ffffffffc0204298:	e1450513          	addi	a0,a0,-492 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020429c:	f79fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02042a0:	00004697          	auipc	a3,0x4
ffffffffc02042a4:	f4868693          	addi	a3,a3,-184 # ffffffffc02081e8 <commands+0x1870>
ffffffffc02042a8:	00003617          	auipc	a2,0x3
ffffffffc02042ac:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206df8 <commands+0x480>
ffffffffc02042b0:	0dd00593          	li	a1,221
ffffffffc02042b4:	00004517          	auipc	a0,0x4
ffffffffc02042b8:	df450513          	addi	a0,a0,-524 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02042bc:	f59fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02042c0:	00004697          	auipc	a3,0x4
ffffffffc02042c4:	f6868693          	addi	a3,a3,-152 # ffffffffc0208228 <commands+0x18b0>
ffffffffc02042c8:	00003617          	auipc	a2,0x3
ffffffffc02042cc:	b3060613          	addi	a2,a2,-1232 # ffffffffc0206df8 <commands+0x480>
ffffffffc02042d0:	0dc00593          	li	a1,220
ffffffffc02042d4:	00004517          	auipc	a0,0x4
ffffffffc02042d8:	dd450513          	addi	a0,a0,-556 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02042dc:	f39fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02042e0:	00004697          	auipc	a3,0x4
ffffffffc02042e4:	de068693          	addi	a3,a3,-544 # ffffffffc02080c0 <commands+0x1748>
ffffffffc02042e8:	00003617          	auipc	a2,0x3
ffffffffc02042ec:	b1060613          	addi	a2,a2,-1264 # ffffffffc0206df8 <commands+0x480>
ffffffffc02042f0:	0b900593          	li	a1,185
ffffffffc02042f4:	00004517          	auipc	a0,0x4
ffffffffc02042f8:	db450513          	addi	a0,a0,-588 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02042fc:	f19fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204300:	00004697          	auipc	a3,0x4
ffffffffc0204304:	ee868693          	addi	a3,a3,-280 # ffffffffc02081e8 <commands+0x1870>
ffffffffc0204308:	00003617          	auipc	a2,0x3
ffffffffc020430c:	af060613          	addi	a2,a2,-1296 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204310:	0d600593          	li	a1,214
ffffffffc0204314:	00004517          	auipc	a0,0x4
ffffffffc0204318:	d9450513          	addi	a0,a0,-620 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020431c:	ef9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204320:	00004697          	auipc	a3,0x4
ffffffffc0204324:	de068693          	addi	a3,a3,-544 # ffffffffc0208100 <commands+0x1788>
ffffffffc0204328:	00003617          	auipc	a2,0x3
ffffffffc020432c:	ad060613          	addi	a2,a2,-1328 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204330:	0d400593          	li	a1,212
ffffffffc0204334:	00004517          	auipc	a0,0x4
ffffffffc0204338:	d7450513          	addi	a0,a0,-652 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020433c:	ed9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204340:	00004697          	auipc	a3,0x4
ffffffffc0204344:	da068693          	addi	a3,a3,-608 # ffffffffc02080e0 <commands+0x1768>
ffffffffc0204348:	00003617          	auipc	a2,0x3
ffffffffc020434c:	ab060613          	addi	a2,a2,-1360 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204350:	0d300593          	li	a1,211
ffffffffc0204354:	00004517          	auipc	a0,0x4
ffffffffc0204358:	d5450513          	addi	a0,a0,-684 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020435c:	eb9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204360:	00004697          	auipc	a3,0x4
ffffffffc0204364:	da068693          	addi	a3,a3,-608 # ffffffffc0208100 <commands+0x1788>
ffffffffc0204368:	00003617          	auipc	a2,0x3
ffffffffc020436c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204370:	0bb00593          	li	a1,187
ffffffffc0204374:	00004517          	auipc	a0,0x4
ffffffffc0204378:	d3450513          	addi	a0,a0,-716 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020437c:	e99fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(count == 0);
ffffffffc0204380:	00004697          	auipc	a3,0x4
ffffffffc0204384:	01868693          	addi	a3,a3,24 # ffffffffc0208398 <commands+0x1a20>
ffffffffc0204388:	00003617          	auipc	a2,0x3
ffffffffc020438c:	a7060613          	addi	a2,a2,-1424 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204390:	12500593          	li	a1,293
ffffffffc0204394:	00004517          	auipc	a0,0x4
ffffffffc0204398:	d1450513          	addi	a0,a0,-748 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020439c:	e79fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc02043a0:	00004697          	auipc	a3,0x4
ffffffffc02043a4:	ba868693          	addi	a3,a3,-1112 # ffffffffc0207f48 <commands+0x15d0>
ffffffffc02043a8:	00003617          	auipc	a2,0x3
ffffffffc02043ac:	a5060613          	addi	a2,a2,-1456 # ffffffffc0206df8 <commands+0x480>
ffffffffc02043b0:	11a00593          	li	a1,282
ffffffffc02043b4:	00004517          	auipc	a0,0x4
ffffffffc02043b8:	cf450513          	addi	a0,a0,-780 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02043bc:	e59fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02043c0:	00004697          	auipc	a3,0x4
ffffffffc02043c4:	e2868693          	addi	a3,a3,-472 # ffffffffc02081e8 <commands+0x1870>
ffffffffc02043c8:	00003617          	auipc	a2,0x3
ffffffffc02043cc:	a3060613          	addi	a2,a2,-1488 # ffffffffc0206df8 <commands+0x480>
ffffffffc02043d0:	11800593          	li	a1,280
ffffffffc02043d4:	00004517          	auipc	a0,0x4
ffffffffc02043d8:	cd450513          	addi	a0,a0,-812 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02043dc:	e39fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02043e0:	00004697          	auipc	a3,0x4
ffffffffc02043e4:	dc868693          	addi	a3,a3,-568 # ffffffffc02081a8 <commands+0x1830>
ffffffffc02043e8:	00003617          	auipc	a2,0x3
ffffffffc02043ec:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206df8 <commands+0x480>
ffffffffc02043f0:	0c100593          	li	a1,193
ffffffffc02043f4:	00004517          	auipc	a0,0x4
ffffffffc02043f8:	cb450513          	addi	a0,a0,-844 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02043fc:	e19fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204400:	00004697          	auipc	a3,0x4
ffffffffc0204404:	f5868693          	addi	a3,a3,-168 # ffffffffc0208358 <commands+0x19e0>
ffffffffc0204408:	00003617          	auipc	a2,0x3
ffffffffc020440c:	9f060613          	addi	a2,a2,-1552 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204410:	11200593          	li	a1,274
ffffffffc0204414:	00004517          	auipc	a0,0x4
ffffffffc0204418:	c9450513          	addi	a0,a0,-876 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020441c:	df9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204420:	00004697          	auipc	a3,0x4
ffffffffc0204424:	f1868693          	addi	a3,a3,-232 # ffffffffc0208338 <commands+0x19c0>
ffffffffc0204428:	00003617          	auipc	a2,0x3
ffffffffc020442c:	9d060613          	addi	a2,a2,-1584 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204430:	11000593          	li	a1,272
ffffffffc0204434:	00004517          	auipc	a0,0x4
ffffffffc0204438:	c7450513          	addi	a0,a0,-908 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020443c:	dd9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204440:	00004697          	auipc	a3,0x4
ffffffffc0204444:	ed068693          	addi	a3,a3,-304 # ffffffffc0208310 <commands+0x1998>
ffffffffc0204448:	00003617          	auipc	a2,0x3
ffffffffc020444c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204450:	10e00593          	li	a1,270
ffffffffc0204454:	00004517          	auipc	a0,0x4
ffffffffc0204458:	c5450513          	addi	a0,a0,-940 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020445c:	db9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204460:	00004697          	auipc	a3,0x4
ffffffffc0204464:	e8868693          	addi	a3,a3,-376 # ffffffffc02082e8 <commands+0x1970>
ffffffffc0204468:	00003617          	auipc	a2,0x3
ffffffffc020446c:	99060613          	addi	a2,a2,-1648 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204470:	10d00593          	li	a1,269
ffffffffc0204474:	00004517          	auipc	a0,0x4
ffffffffc0204478:	c3450513          	addi	a0,a0,-972 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020447c:	d99fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204480:	00004697          	auipc	a3,0x4
ffffffffc0204484:	e5868693          	addi	a3,a3,-424 # ffffffffc02082d8 <commands+0x1960>
ffffffffc0204488:	00003617          	auipc	a2,0x3
ffffffffc020448c:	97060613          	addi	a2,a2,-1680 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204490:	10800593          	li	a1,264
ffffffffc0204494:	00004517          	auipc	a0,0x4
ffffffffc0204498:	c1450513          	addi	a0,a0,-1004 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020449c:	d79fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044a0:	00004697          	auipc	a3,0x4
ffffffffc02044a4:	d4868693          	addi	a3,a3,-696 # ffffffffc02081e8 <commands+0x1870>
ffffffffc02044a8:	00003617          	auipc	a2,0x3
ffffffffc02044ac:	95060613          	addi	a2,a2,-1712 # ffffffffc0206df8 <commands+0x480>
ffffffffc02044b0:	10700593          	li	a1,263
ffffffffc02044b4:	00004517          	auipc	a0,0x4
ffffffffc02044b8:	bf450513          	addi	a0,a0,-1036 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02044bc:	d59fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02044c0:	00004697          	auipc	a3,0x4
ffffffffc02044c4:	df868693          	addi	a3,a3,-520 # ffffffffc02082b8 <commands+0x1940>
ffffffffc02044c8:	00003617          	auipc	a2,0x3
ffffffffc02044cc:	93060613          	addi	a2,a2,-1744 # ffffffffc0206df8 <commands+0x480>
ffffffffc02044d0:	10600593          	li	a1,262
ffffffffc02044d4:	00004517          	auipc	a0,0x4
ffffffffc02044d8:	bd450513          	addi	a0,a0,-1068 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02044dc:	d39fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02044e0:	00004697          	auipc	a3,0x4
ffffffffc02044e4:	da868693          	addi	a3,a3,-600 # ffffffffc0208288 <commands+0x1910>
ffffffffc02044e8:	00003617          	auipc	a2,0x3
ffffffffc02044ec:	91060613          	addi	a2,a2,-1776 # ffffffffc0206df8 <commands+0x480>
ffffffffc02044f0:	10500593          	li	a1,261
ffffffffc02044f4:	00004517          	auipc	a0,0x4
ffffffffc02044f8:	bb450513          	addi	a0,a0,-1100 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02044fc:	d19fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0204500:	00004697          	auipc	a3,0x4
ffffffffc0204504:	d7068693          	addi	a3,a3,-656 # ffffffffc0208270 <commands+0x18f8>
ffffffffc0204508:	00003617          	auipc	a2,0x3
ffffffffc020450c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204510:	10400593          	li	a1,260
ffffffffc0204514:	00004517          	auipc	a0,0x4
ffffffffc0204518:	b9450513          	addi	a0,a0,-1132 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020451c:	cf9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204520:	00004697          	auipc	a3,0x4
ffffffffc0204524:	cc868693          	addi	a3,a3,-824 # ffffffffc02081e8 <commands+0x1870>
ffffffffc0204528:	00003617          	auipc	a2,0x3
ffffffffc020452c:	8d060613          	addi	a2,a2,-1840 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204530:	0fe00593          	li	a1,254
ffffffffc0204534:	00004517          	auipc	a0,0x4
ffffffffc0204538:	b7450513          	addi	a0,a0,-1164 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020453c:	cd9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!PageProperty(p0));
ffffffffc0204540:	00004697          	auipc	a3,0x4
ffffffffc0204544:	d1868693          	addi	a3,a3,-744 # ffffffffc0208258 <commands+0x18e0>
ffffffffc0204548:	00003617          	auipc	a2,0x3
ffffffffc020454c:	8b060613          	addi	a2,a2,-1872 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204550:	0f900593          	li	a1,249
ffffffffc0204554:	00004517          	auipc	a0,0x4
ffffffffc0204558:	b5450513          	addi	a0,a0,-1196 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020455c:	cb9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204560:	00004697          	auipc	a3,0x4
ffffffffc0204564:	e1868693          	addi	a3,a3,-488 # ffffffffc0208378 <commands+0x1a00>
ffffffffc0204568:	00003617          	auipc	a2,0x3
ffffffffc020456c:	89060613          	addi	a2,a2,-1904 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204570:	11700593          	li	a1,279
ffffffffc0204574:	00004517          	auipc	a0,0x4
ffffffffc0204578:	b3450513          	addi	a0,a0,-1228 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020457c:	c99fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == 0);
ffffffffc0204580:	00004697          	auipc	a3,0x4
ffffffffc0204584:	e2868693          	addi	a3,a3,-472 # ffffffffc02083a8 <commands+0x1a30>
ffffffffc0204588:	00003617          	auipc	a2,0x3
ffffffffc020458c:	87060613          	addi	a2,a2,-1936 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204590:	12600593          	li	a1,294
ffffffffc0204594:	00004517          	auipc	a0,0x4
ffffffffc0204598:	b1450513          	addi	a0,a0,-1260 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020459c:	c79fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == nr_free_pages());
ffffffffc02045a0:	00004697          	auipc	a3,0x4
ffffffffc02045a4:	80868693          	addi	a3,a3,-2040 # ffffffffc0207da8 <commands+0x1430>
ffffffffc02045a8:	00003617          	auipc	a2,0x3
ffffffffc02045ac:	85060613          	addi	a2,a2,-1968 # ffffffffc0206df8 <commands+0x480>
ffffffffc02045b0:	0f300593          	li	a1,243
ffffffffc02045b4:	00004517          	auipc	a0,0x4
ffffffffc02045b8:	af450513          	addi	a0,a0,-1292 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02045bc:	c59fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02045c0:	00004697          	auipc	a3,0x4
ffffffffc02045c4:	b2068693          	addi	a3,a3,-1248 # ffffffffc02080e0 <commands+0x1768>
ffffffffc02045c8:	00003617          	auipc	a2,0x3
ffffffffc02045cc:	83060613          	addi	a2,a2,-2000 # ffffffffc0206df8 <commands+0x480>
ffffffffc02045d0:	0ba00593          	li	a1,186
ffffffffc02045d4:	00004517          	auipc	a0,0x4
ffffffffc02045d8:	ad450513          	addi	a0,a0,-1324 # ffffffffc02080a8 <commands+0x1730>
ffffffffc02045dc:	c39fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02045e0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02045e0:	1141                	addi	sp,sp,-16
ffffffffc02045e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02045e4:	16058e63          	beqz	a1,ffffffffc0204760 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02045e8:	00659693          	slli	a3,a1,0x6
ffffffffc02045ec:	96aa                	add	a3,a3,a0
ffffffffc02045ee:	02d50d63          	beq	a0,a3,ffffffffc0204628 <default_free_pages+0x48>
ffffffffc02045f2:	651c                	ld	a5,8(a0)
ffffffffc02045f4:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02045f6:	14079563          	bnez	a5,ffffffffc0204740 <default_free_pages+0x160>
ffffffffc02045fa:	651c                	ld	a5,8(a0)
ffffffffc02045fc:	8385                	srli	a5,a5,0x1
ffffffffc02045fe:	8b85                	andi	a5,a5,1
ffffffffc0204600:	14079063          	bnez	a5,ffffffffc0204740 <default_free_pages+0x160>
ffffffffc0204604:	87aa                	mv	a5,a0
ffffffffc0204606:	a809                	j	ffffffffc0204618 <default_free_pages+0x38>
ffffffffc0204608:	6798                	ld	a4,8(a5)
ffffffffc020460a:	8b05                	andi	a4,a4,1
ffffffffc020460c:	12071a63          	bnez	a4,ffffffffc0204740 <default_free_pages+0x160>
ffffffffc0204610:	6798                	ld	a4,8(a5)
ffffffffc0204612:	8b09                	andi	a4,a4,2
ffffffffc0204614:	12071663          	bnez	a4,ffffffffc0204740 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0204618:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc020461c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204620:	04078793          	addi	a5,a5,64
ffffffffc0204624:	fed792e3          	bne	a5,a3,ffffffffc0204608 <default_free_pages+0x28>
    base->property = n;
ffffffffc0204628:	2581                	sext.w	a1,a1
ffffffffc020462a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020462c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204630:	4789                	li	a5,2
ffffffffc0204632:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0204636:	000a8697          	auipc	a3,0xa8
ffffffffc020463a:	32a68693          	addi	a3,a3,810 # ffffffffc02ac960 <free_area>
ffffffffc020463e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204640:	669c                	ld	a5,8(a3)
ffffffffc0204642:	9db9                	addw	a1,a1,a4
ffffffffc0204644:	000a8717          	auipc	a4,0xa8
ffffffffc0204648:	32b72623          	sw	a1,812(a4) # ffffffffc02ac970 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020464c:	0cd78163          	beq	a5,a3,ffffffffc020470e <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0204650:	fe878713          	addi	a4,a5,-24
ffffffffc0204654:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204656:	4801                	li	a6,0
ffffffffc0204658:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020465c:	00e56a63          	bltu	a0,a4,ffffffffc0204670 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0204660:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204662:	04d70f63          	beq	a4,a3,ffffffffc02046c0 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204666:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204668:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020466c:	fee57ae3          	bgeu	a0,a4,ffffffffc0204660 <default_free_pages+0x80>
ffffffffc0204670:	00080663          	beqz	a6,ffffffffc020467c <default_free_pages+0x9c>
ffffffffc0204674:	000a8817          	auipc	a6,0xa8
ffffffffc0204678:	2eb83623          	sd	a1,748(a6) # ffffffffc02ac960 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020467c:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc020467e:	e390                	sd	a2,0(a5)
ffffffffc0204680:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0204682:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204684:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0204686:	06d58a63          	beq	a1,a3,ffffffffc02046fa <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc020468a:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x85d0>
        p = le2page(le, page_link);
ffffffffc020468e:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0204692:	02061793          	slli	a5,a2,0x20
ffffffffc0204696:	83e9                	srli	a5,a5,0x1a
ffffffffc0204698:	97ba                	add	a5,a5,a4
ffffffffc020469a:	04f51b63          	bne	a0,a5,ffffffffc02046f0 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020469e:	491c                	lw	a5,16(a0)
ffffffffc02046a0:	9e3d                	addw	a2,a2,a5
ffffffffc02046a2:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02046a6:	57f5                	li	a5,-3
ffffffffc02046a8:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02046ac:	01853803          	ld	a6,24(a0)
ffffffffc02046b0:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02046b2:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc02046b4:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02046b8:	659c                	ld	a5,8(a1)
ffffffffc02046ba:	01063023          	sd	a6,0(a2)
ffffffffc02046be:	a815                	j	ffffffffc02046f2 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc02046c0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02046c2:	f114                	sd	a3,32(a0)
ffffffffc02046c4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02046c6:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02046c8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02046ca:	00d70563          	beq	a4,a3,ffffffffc02046d4 <default_free_pages+0xf4>
ffffffffc02046ce:	4805                	li	a6,1
ffffffffc02046d0:	87ba                	mv	a5,a4
ffffffffc02046d2:	bf59                	j	ffffffffc0204668 <default_free_pages+0x88>
ffffffffc02046d4:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02046d6:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02046d8:	00d78d63          	beq	a5,a3,ffffffffc02046f2 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02046dc:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02046e0:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02046e4:	02061793          	slli	a5,a2,0x20
ffffffffc02046e8:	83e9                	srli	a5,a5,0x1a
ffffffffc02046ea:	97ba                	add	a5,a5,a4
ffffffffc02046ec:	faf509e3          	beq	a0,a5,ffffffffc020469e <default_free_pages+0xbe>
ffffffffc02046f0:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02046f2:	fe878713          	addi	a4,a5,-24
ffffffffc02046f6:	00d78963          	beq	a5,a3,ffffffffc0204708 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02046fa:	4910                	lw	a2,16(a0)
ffffffffc02046fc:	02061693          	slli	a3,a2,0x20
ffffffffc0204700:	82e9                	srli	a3,a3,0x1a
ffffffffc0204702:	96aa                	add	a3,a3,a0
ffffffffc0204704:	00d70e63          	beq	a4,a3,ffffffffc0204720 <default_free_pages+0x140>
}
ffffffffc0204708:	60a2                	ld	ra,8(sp)
ffffffffc020470a:	0141                	addi	sp,sp,16
ffffffffc020470c:	8082                	ret
ffffffffc020470e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204710:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204714:	e398                	sd	a4,0(a5)
ffffffffc0204716:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204718:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020471a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020471c:	0141                	addi	sp,sp,16
ffffffffc020471e:	8082                	ret
            base->property += p->property;
ffffffffc0204720:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204724:	ff078693          	addi	a3,a5,-16
ffffffffc0204728:	9e39                	addw	a2,a2,a4
ffffffffc020472a:	c910                	sw	a2,16(a0)
ffffffffc020472c:	5775                	li	a4,-3
ffffffffc020472e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204732:	6398                	ld	a4,0(a5)
ffffffffc0204734:	679c                	ld	a5,8(a5)
}
ffffffffc0204736:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0204738:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020473a:	e398                	sd	a4,0(a5)
ffffffffc020473c:	0141                	addi	sp,sp,16
ffffffffc020473e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204740:	00004697          	auipc	a3,0x4
ffffffffc0204744:	c7868693          	addi	a3,a3,-904 # ffffffffc02083b8 <commands+0x1a40>
ffffffffc0204748:	00002617          	auipc	a2,0x2
ffffffffc020474c:	6b060613          	addi	a2,a2,1712 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204750:	08300593          	li	a1,131
ffffffffc0204754:	00004517          	auipc	a0,0x4
ffffffffc0204758:	95450513          	addi	a0,a0,-1708 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020475c:	ab9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc0204760:	00004697          	auipc	a3,0x4
ffffffffc0204764:	c8068693          	addi	a3,a3,-896 # ffffffffc02083e0 <commands+0x1a68>
ffffffffc0204768:	00002617          	auipc	a2,0x2
ffffffffc020476c:	69060613          	addi	a2,a2,1680 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204770:	08000593          	li	a1,128
ffffffffc0204774:	00004517          	auipc	a0,0x4
ffffffffc0204778:	93450513          	addi	a0,a0,-1740 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020477c:	a99fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204780 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0204780:	c959                	beqz	a0,ffffffffc0204816 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0204782:	000a8597          	auipc	a1,0xa8
ffffffffc0204786:	1de58593          	addi	a1,a1,478 # ffffffffc02ac960 <free_area>
ffffffffc020478a:	0105a803          	lw	a6,16(a1)
ffffffffc020478e:	862a                	mv	a2,a0
ffffffffc0204790:	02081793          	slli	a5,a6,0x20
ffffffffc0204794:	9381                	srli	a5,a5,0x20
ffffffffc0204796:	00a7ee63          	bltu	a5,a0,ffffffffc02047b2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020479a:	87ae                	mv	a5,a1
ffffffffc020479c:	a801                	j	ffffffffc02047ac <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020479e:	ff87a703          	lw	a4,-8(a5)
ffffffffc02047a2:	02071693          	slli	a3,a4,0x20
ffffffffc02047a6:	9281                	srli	a3,a3,0x20
ffffffffc02047a8:	00c6f763          	bgeu	a3,a2,ffffffffc02047b6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02047ac:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02047ae:	feb798e3          	bne	a5,a1,ffffffffc020479e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02047b2:	4501                	li	a0,0
}
ffffffffc02047b4:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02047b6:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02047ba:	dd6d                	beqz	a0,ffffffffc02047b4 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02047bc:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02047c0:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02047c4:	00060e1b          	sext.w	t3,a2
ffffffffc02047c8:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3670>
    next->prev = prev;
ffffffffc02047cc:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5538>
        if (page->property > n) {
ffffffffc02047d0:	02d67863          	bgeu	a2,a3,ffffffffc0204800 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02047d4:	061a                	slli	a2,a2,0x6
ffffffffc02047d6:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02047d8:	41c7073b          	subw	a4,a4,t3
ffffffffc02047dc:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02047de:	00860693          	addi	a3,a2,8
ffffffffc02047e2:	4709                	li	a4,2
ffffffffc02047e4:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02047e8:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02047ec:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02047f0:	0105a803          	lw	a6,16(a1)
ffffffffc02047f4:	e314                	sd	a3,0(a4)
ffffffffc02047f6:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02047fa:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02047fc:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0204800:	41c8083b          	subw	a6,a6,t3
ffffffffc0204804:	000a8717          	auipc	a4,0xa8
ffffffffc0204808:	17072623          	sw	a6,364(a4) # ffffffffc02ac970 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020480c:	5775                	li	a4,-3
ffffffffc020480e:	17c1                	addi	a5,a5,-16
ffffffffc0204810:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204814:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204816:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204818:	00004697          	auipc	a3,0x4
ffffffffc020481c:	bc868693          	addi	a3,a3,-1080 # ffffffffc02083e0 <commands+0x1a68>
ffffffffc0204820:	00002617          	auipc	a2,0x2
ffffffffc0204824:	5d860613          	addi	a2,a2,1496 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204828:	06200593          	li	a1,98
ffffffffc020482c:	00004517          	auipc	a0,0x4
ffffffffc0204830:	87c50513          	addi	a0,a0,-1924 # ffffffffc02080a8 <commands+0x1730>
default_alloc_pages(size_t n) {
ffffffffc0204834:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204836:	9dffb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020483a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020483a:	1141                	addi	sp,sp,-16
ffffffffc020483c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020483e:	c1ed                	beqz	a1,ffffffffc0204920 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204840:	00659693          	slli	a3,a1,0x6
ffffffffc0204844:	96aa                	add	a3,a3,a0
ffffffffc0204846:	02d50463          	beq	a0,a3,ffffffffc020486e <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020484a:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020484c:	87aa                	mv	a5,a0
ffffffffc020484e:	8b05                	andi	a4,a4,1
ffffffffc0204850:	e709                	bnez	a4,ffffffffc020485a <default_init_memmap+0x20>
ffffffffc0204852:	a07d                	j	ffffffffc0204900 <default_init_memmap+0xc6>
ffffffffc0204854:	6798                	ld	a4,8(a5)
ffffffffc0204856:	8b05                	andi	a4,a4,1
ffffffffc0204858:	c745                	beqz	a4,ffffffffc0204900 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc020485a:	0007a823          	sw	zero,16(a5)
ffffffffc020485e:	0007b423          	sd	zero,8(a5)
ffffffffc0204862:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204866:	04078793          	addi	a5,a5,64
ffffffffc020486a:	fed795e3          	bne	a5,a3,ffffffffc0204854 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc020486e:	2581                	sext.w	a1,a1
ffffffffc0204870:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204872:	4789                	li	a5,2
ffffffffc0204874:	00850713          	addi	a4,a0,8
ffffffffc0204878:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020487c:	000a8697          	auipc	a3,0xa8
ffffffffc0204880:	0e468693          	addi	a3,a3,228 # ffffffffc02ac960 <free_area>
ffffffffc0204884:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204886:	669c                	ld	a5,8(a3)
ffffffffc0204888:	9db9                	addw	a1,a1,a4
ffffffffc020488a:	000a8717          	auipc	a4,0xa8
ffffffffc020488e:	0eb72323          	sw	a1,230(a4) # ffffffffc02ac970 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204892:	04d78a63          	beq	a5,a3,ffffffffc02048e6 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204896:	fe878713          	addi	a4,a5,-24
ffffffffc020489a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020489c:	4801                	li	a6,0
ffffffffc020489e:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02048a2:	00e56a63          	bltu	a0,a4,ffffffffc02048b6 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02048a6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02048a8:	02d70563          	beq	a4,a3,ffffffffc02048d2 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02048ac:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02048ae:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02048b2:	fee57ae3          	bgeu	a0,a4,ffffffffc02048a6 <default_init_memmap+0x6c>
ffffffffc02048b6:	00080663          	beqz	a6,ffffffffc02048c2 <default_init_memmap+0x88>
ffffffffc02048ba:	000a8717          	auipc	a4,0xa8
ffffffffc02048be:	0ab73323          	sd	a1,166(a4) # ffffffffc02ac960 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02048c2:	6398                	ld	a4,0(a5)
}
ffffffffc02048c4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02048c6:	e390                	sd	a2,0(a5)
ffffffffc02048c8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02048ca:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048cc:	ed18                	sd	a4,24(a0)
ffffffffc02048ce:	0141                	addi	sp,sp,16
ffffffffc02048d0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02048d2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02048d4:	f114                	sd	a3,32(a0)
ffffffffc02048d6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02048d8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02048da:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02048dc:	00d70e63          	beq	a4,a3,ffffffffc02048f8 <default_init_memmap+0xbe>
ffffffffc02048e0:	4805                	li	a6,1
ffffffffc02048e2:	87ba                	mv	a5,a4
ffffffffc02048e4:	b7e9                	j	ffffffffc02048ae <default_init_memmap+0x74>
}
ffffffffc02048e6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02048e8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02048ec:	e398                	sd	a4,0(a5)
ffffffffc02048ee:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02048f0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048f2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02048f4:	0141                	addi	sp,sp,16
ffffffffc02048f6:	8082                	ret
ffffffffc02048f8:	60a2                	ld	ra,8(sp)
ffffffffc02048fa:	e290                	sd	a2,0(a3)
ffffffffc02048fc:	0141                	addi	sp,sp,16
ffffffffc02048fe:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204900:	00004697          	auipc	a3,0x4
ffffffffc0204904:	ae868693          	addi	a3,a3,-1304 # ffffffffc02083e8 <commands+0x1a70>
ffffffffc0204908:	00002617          	auipc	a2,0x2
ffffffffc020490c:	4f060613          	addi	a2,a2,1264 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204910:	04900593          	li	a1,73
ffffffffc0204914:	00003517          	auipc	a0,0x3
ffffffffc0204918:	79450513          	addi	a0,a0,1940 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020491c:	8f9fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc0204920:	00004697          	auipc	a3,0x4
ffffffffc0204924:	ac068693          	addi	a3,a3,-1344 # ffffffffc02083e0 <commands+0x1a68>
ffffffffc0204928:	00002617          	auipc	a2,0x2
ffffffffc020492c:	4d060613          	addi	a2,a2,1232 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204930:	04600593          	li	a1,70
ffffffffc0204934:	00003517          	auipc	a0,0x3
ffffffffc0204938:	77450513          	addi	a0,a0,1908 # ffffffffc02080a8 <commands+0x1730>
ffffffffc020493c:	8d9fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204940 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0204940:	000a8797          	auipc	a5,0xa8
ffffffffc0204944:	03878793          	addi	a5,a5,56 # ffffffffc02ac978 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0204948:	f51c                	sd	a5,40(a0)
ffffffffc020494a:	e79c                	sd	a5,8(a5)
ffffffffc020494c:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020494e:	4501                	li	a0,0
ffffffffc0204950:	8082                	ret

ffffffffc0204952 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0204952:	4501                	li	a0,0
ffffffffc0204954:	8082                	ret

ffffffffc0204956 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0204956:	4501                	li	a0,0
ffffffffc0204958:	8082                	ret

ffffffffc020495a <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020495a:	4501                	li	a0,0
ffffffffc020495c:	8082                	ret

ffffffffc020495e <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020495e:	711d                	addi	sp,sp,-96
ffffffffc0204960:	fc4e                	sd	s3,56(sp)
ffffffffc0204962:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0204964:	00004517          	auipc	a0,0x4
ffffffffc0204968:	ae450513          	addi	a0,a0,-1308 # ffffffffc0208448 <default_pmm_manager+0x50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020496c:	698d                	lui	s3,0x3
ffffffffc020496e:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0204970:	e8a2                	sd	s0,80(sp)
ffffffffc0204972:	e4a6                	sd	s1,72(sp)
ffffffffc0204974:	ec86                	sd	ra,88(sp)
ffffffffc0204976:	e0ca                	sd	s2,64(sp)
ffffffffc0204978:	f456                	sd	s5,40(sp)
ffffffffc020497a:	f05a                	sd	s6,32(sp)
ffffffffc020497c:	ec5e                	sd	s7,24(sp)
ffffffffc020497e:	e862                	sd	s8,16(sp)
ffffffffc0204980:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0204982:	000a8417          	auipc	s0,0xa8
ffffffffc0204986:	ea640413          	addi	s0,s0,-346 # ffffffffc02ac828 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020498a:	f46fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020498e:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0204992:	4004                	lw	s1,0(s0)
ffffffffc0204994:	4791                	li	a5,4
ffffffffc0204996:	2481                	sext.w	s1,s1
ffffffffc0204998:	14f49963          	bne	s1,a5,ffffffffc0204aea <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020499c:	00004517          	auipc	a0,0x4
ffffffffc02049a0:	aec50513          	addi	a0,a0,-1300 # ffffffffc0208488 <default_pmm_manager+0x90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02049a4:	6a85                	lui	s5,0x1
ffffffffc02049a6:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02049a8:	f28fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02049ac:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc02049b0:	00042903          	lw	s2,0(s0)
ffffffffc02049b4:	2901                	sext.w	s2,s2
ffffffffc02049b6:	2a991a63          	bne	s2,s1,ffffffffc0204c6a <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02049ba:	00004517          	auipc	a0,0x4
ffffffffc02049be:	af650513          	addi	a0,a0,-1290 # ffffffffc02084b0 <default_pmm_manager+0xb8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02049c2:	6b91                	lui	s7,0x4
ffffffffc02049c4:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02049c6:	f0afb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02049ca:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc02049ce:	4004                	lw	s1,0(s0)
ffffffffc02049d0:	2481                	sext.w	s1,s1
ffffffffc02049d2:	27249c63          	bne	s1,s2,ffffffffc0204c4a <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02049d6:	00004517          	auipc	a0,0x4
ffffffffc02049da:	b0250513          	addi	a0,a0,-1278 # ffffffffc02084d8 <default_pmm_manager+0xe0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02049de:	6909                	lui	s2,0x2
ffffffffc02049e0:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02049e2:	eeefb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02049e6:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc02049ea:	401c                	lw	a5,0(s0)
ffffffffc02049ec:	2781                	sext.w	a5,a5
ffffffffc02049ee:	22979e63          	bne	a5,s1,ffffffffc0204c2a <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02049f2:	00004517          	auipc	a0,0x4
ffffffffc02049f6:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0208500 <default_pmm_manager+0x108>
ffffffffc02049fa:	ed6fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02049fe:	6795                	lui	a5,0x5
ffffffffc0204a00:	4739                	li	a4,14
ffffffffc0204a02:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc0204a06:	4004                	lw	s1,0(s0)
ffffffffc0204a08:	4795                	li	a5,5
ffffffffc0204a0a:	2481                	sext.w	s1,s1
ffffffffc0204a0c:	1ef49f63          	bne	s1,a5,ffffffffc0204c0a <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0204a10:	00004517          	auipc	a0,0x4
ffffffffc0204a14:	ac850513          	addi	a0,a0,-1336 # ffffffffc02084d8 <default_pmm_manager+0xe0>
ffffffffc0204a18:	eb8fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0204a1c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0204a20:	401c                	lw	a5,0(s0)
ffffffffc0204a22:	2781                	sext.w	a5,a5
ffffffffc0204a24:	1c979363          	bne	a5,s1,ffffffffc0204bea <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204a28:	00004517          	auipc	a0,0x4
ffffffffc0204a2c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0208488 <default_pmm_manager+0x90>
ffffffffc0204a30:	ea0fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0204a34:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0204a38:	401c                	lw	a5,0(s0)
ffffffffc0204a3a:	4719                	li	a4,6
ffffffffc0204a3c:	2781                	sext.w	a5,a5
ffffffffc0204a3e:	18e79663          	bne	a5,a4,ffffffffc0204bca <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0204a42:	00004517          	auipc	a0,0x4
ffffffffc0204a46:	a9650513          	addi	a0,a0,-1386 # ffffffffc02084d8 <default_pmm_manager+0xe0>
ffffffffc0204a4a:	e86fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0204a4e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0204a52:	401c                	lw	a5,0(s0)
ffffffffc0204a54:	471d                	li	a4,7
ffffffffc0204a56:	2781                	sext.w	a5,a5
ffffffffc0204a58:	14e79963          	bne	a5,a4,ffffffffc0204baa <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0204a5c:	00004517          	auipc	a0,0x4
ffffffffc0204a60:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0208448 <default_pmm_manager+0x50>
ffffffffc0204a64:	e6cfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204a68:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0204a6c:	401c                	lw	a5,0(s0)
ffffffffc0204a6e:	4721                	li	a4,8
ffffffffc0204a70:	2781                	sext.w	a5,a5
ffffffffc0204a72:	10e79c63          	bne	a5,a4,ffffffffc0204b8a <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0204a76:	00004517          	auipc	a0,0x4
ffffffffc0204a7a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02084b0 <default_pmm_manager+0xb8>
ffffffffc0204a7e:	e52fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0204a82:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0204a86:	401c                	lw	a5,0(s0)
ffffffffc0204a88:	4725                	li	a4,9
ffffffffc0204a8a:	2781                	sext.w	a5,a5
ffffffffc0204a8c:	0ce79f63          	bne	a5,a4,ffffffffc0204b6a <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0204a90:	00004517          	auipc	a0,0x4
ffffffffc0204a94:	a7050513          	addi	a0,a0,-1424 # ffffffffc0208500 <default_pmm_manager+0x108>
ffffffffc0204a98:	e38fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0204a9c:	6795                	lui	a5,0x5
ffffffffc0204a9e:	4739                	li	a4,14
ffffffffc0204aa0:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0204aa4:	4004                	lw	s1,0(s0)
ffffffffc0204aa6:	47a9                	li	a5,10
ffffffffc0204aa8:	2481                	sext.w	s1,s1
ffffffffc0204aaa:	0af49063          	bne	s1,a5,ffffffffc0204b4a <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204aae:	00004517          	auipc	a0,0x4
ffffffffc0204ab2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0208488 <default_pmm_manager+0x90>
ffffffffc0204ab6:	e1afb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0204aba:	6785                	lui	a5,0x1
ffffffffc0204abc:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0204ac0:	06979563          	bne	a5,s1,ffffffffc0204b2a <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0204ac4:	401c                	lw	a5,0(s0)
ffffffffc0204ac6:	472d                	li	a4,11
ffffffffc0204ac8:	2781                	sext.w	a5,a5
ffffffffc0204aca:	04e79063          	bne	a5,a4,ffffffffc0204b0a <_fifo_check_swap+0x1ac>
}
ffffffffc0204ace:	60e6                	ld	ra,88(sp)
ffffffffc0204ad0:	6446                	ld	s0,80(sp)
ffffffffc0204ad2:	64a6                	ld	s1,72(sp)
ffffffffc0204ad4:	6906                	ld	s2,64(sp)
ffffffffc0204ad6:	79e2                	ld	s3,56(sp)
ffffffffc0204ad8:	7a42                	ld	s4,48(sp)
ffffffffc0204ada:	7aa2                	ld	s5,40(sp)
ffffffffc0204adc:	7b02                	ld	s6,32(sp)
ffffffffc0204ade:	6be2                	ld	s7,24(sp)
ffffffffc0204ae0:	6c42                	ld	s8,16(sp)
ffffffffc0204ae2:	6ca2                	ld	s9,8(sp)
ffffffffc0204ae4:	4501                	li	a0,0
ffffffffc0204ae6:	6125                	addi	sp,sp,96
ffffffffc0204ae8:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0204aea:	00003697          	auipc	a3,0x3
ffffffffc0204aee:	44e68693          	addi	a3,a3,1102 # ffffffffc0207f38 <commands+0x15c0>
ffffffffc0204af2:	00002617          	auipc	a2,0x2
ffffffffc0204af6:	30660613          	addi	a2,a2,774 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204afa:	05100593          	li	a1,81
ffffffffc0204afe:	00004517          	auipc	a0,0x4
ffffffffc0204b02:	97250513          	addi	a0,a0,-1678 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204b06:	f0efb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==11);
ffffffffc0204b0a:	00004697          	auipc	a3,0x4
ffffffffc0204b0e:	aa668693          	addi	a3,a3,-1370 # ffffffffc02085b0 <default_pmm_manager+0x1b8>
ffffffffc0204b12:	00002617          	auipc	a2,0x2
ffffffffc0204b16:	2e660613          	addi	a2,a2,742 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204b1a:	07300593          	li	a1,115
ffffffffc0204b1e:	00004517          	auipc	a0,0x4
ffffffffc0204b22:	95250513          	addi	a0,a0,-1710 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204b26:	eeefb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0204b2a:	00004697          	auipc	a3,0x4
ffffffffc0204b2e:	a5e68693          	addi	a3,a3,-1442 # ffffffffc0208588 <default_pmm_manager+0x190>
ffffffffc0204b32:	00002617          	auipc	a2,0x2
ffffffffc0204b36:	2c660613          	addi	a2,a2,710 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204b3a:	07100593          	li	a1,113
ffffffffc0204b3e:	00004517          	auipc	a0,0x4
ffffffffc0204b42:	93250513          	addi	a0,a0,-1742 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204b46:	ecefb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==10);
ffffffffc0204b4a:	00004697          	auipc	a3,0x4
ffffffffc0204b4e:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0208578 <default_pmm_manager+0x180>
ffffffffc0204b52:	00002617          	auipc	a2,0x2
ffffffffc0204b56:	2a660613          	addi	a2,a2,678 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204b5a:	06f00593          	li	a1,111
ffffffffc0204b5e:	00004517          	auipc	a0,0x4
ffffffffc0204b62:	91250513          	addi	a0,a0,-1774 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204b66:	eaefb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==9);
ffffffffc0204b6a:	00004697          	auipc	a3,0x4
ffffffffc0204b6e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0208568 <default_pmm_manager+0x170>
ffffffffc0204b72:	00002617          	auipc	a2,0x2
ffffffffc0204b76:	28660613          	addi	a2,a2,646 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204b7a:	06c00593          	li	a1,108
ffffffffc0204b7e:	00004517          	auipc	a0,0x4
ffffffffc0204b82:	8f250513          	addi	a0,a0,-1806 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204b86:	e8efb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==8);
ffffffffc0204b8a:	00004697          	auipc	a3,0x4
ffffffffc0204b8e:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0208558 <default_pmm_manager+0x160>
ffffffffc0204b92:	00002617          	auipc	a2,0x2
ffffffffc0204b96:	26660613          	addi	a2,a2,614 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204b9a:	06900593          	li	a1,105
ffffffffc0204b9e:	00004517          	auipc	a0,0x4
ffffffffc0204ba2:	8d250513          	addi	a0,a0,-1838 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204ba6:	e6efb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==7);
ffffffffc0204baa:	00004697          	auipc	a3,0x4
ffffffffc0204bae:	99e68693          	addi	a3,a3,-1634 # ffffffffc0208548 <default_pmm_manager+0x150>
ffffffffc0204bb2:	00002617          	auipc	a2,0x2
ffffffffc0204bb6:	24660613          	addi	a2,a2,582 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204bba:	06600593          	li	a1,102
ffffffffc0204bbe:	00004517          	auipc	a0,0x4
ffffffffc0204bc2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204bc6:	e4efb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==6);
ffffffffc0204bca:	00004697          	auipc	a3,0x4
ffffffffc0204bce:	96e68693          	addi	a3,a3,-1682 # ffffffffc0208538 <default_pmm_manager+0x140>
ffffffffc0204bd2:	00002617          	auipc	a2,0x2
ffffffffc0204bd6:	22660613          	addi	a2,a2,550 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204bda:	06300593          	li	a1,99
ffffffffc0204bde:	00004517          	auipc	a0,0x4
ffffffffc0204be2:	89250513          	addi	a0,a0,-1902 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204be6:	e2efb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc0204bea:	00004697          	auipc	a3,0x4
ffffffffc0204bee:	93e68693          	addi	a3,a3,-1730 # ffffffffc0208528 <default_pmm_manager+0x130>
ffffffffc0204bf2:	00002617          	auipc	a2,0x2
ffffffffc0204bf6:	20660613          	addi	a2,a2,518 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204bfa:	06000593          	li	a1,96
ffffffffc0204bfe:	00004517          	auipc	a0,0x4
ffffffffc0204c02:	87250513          	addi	a0,a0,-1934 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204c06:	e0efb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc0204c0a:	00004697          	auipc	a3,0x4
ffffffffc0204c0e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0208528 <default_pmm_manager+0x130>
ffffffffc0204c12:	00002617          	auipc	a2,0x2
ffffffffc0204c16:	1e660613          	addi	a2,a2,486 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204c1a:	05d00593          	li	a1,93
ffffffffc0204c1e:	00004517          	auipc	a0,0x4
ffffffffc0204c22:	85250513          	addi	a0,a0,-1966 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204c26:	deefb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0204c2a:	00003697          	auipc	a3,0x3
ffffffffc0204c2e:	30e68693          	addi	a3,a3,782 # ffffffffc0207f38 <commands+0x15c0>
ffffffffc0204c32:	00002617          	auipc	a2,0x2
ffffffffc0204c36:	1c660613          	addi	a2,a2,454 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204c3a:	05a00593          	li	a1,90
ffffffffc0204c3e:	00004517          	auipc	a0,0x4
ffffffffc0204c42:	83250513          	addi	a0,a0,-1998 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204c46:	dcefb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0204c4a:	00003697          	auipc	a3,0x3
ffffffffc0204c4e:	2ee68693          	addi	a3,a3,750 # ffffffffc0207f38 <commands+0x15c0>
ffffffffc0204c52:	00002617          	auipc	a2,0x2
ffffffffc0204c56:	1a660613          	addi	a2,a2,422 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204c5a:	05700593          	li	a1,87
ffffffffc0204c5e:	00004517          	auipc	a0,0x4
ffffffffc0204c62:	81250513          	addi	a0,a0,-2030 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204c66:	daefb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0204c6a:	00003697          	auipc	a3,0x3
ffffffffc0204c6e:	2ce68693          	addi	a3,a3,718 # ffffffffc0207f38 <commands+0x15c0>
ffffffffc0204c72:	00002617          	auipc	a2,0x2
ffffffffc0204c76:	18660613          	addi	a2,a2,390 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204c7a:	05400593          	li	a1,84
ffffffffc0204c7e:	00003517          	auipc	a0,0x3
ffffffffc0204c82:	7f250513          	addi	a0,a0,2034 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204c86:	d8efb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204c8a <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204c8a:	751c                	ld	a5,40(a0)
{
ffffffffc0204c8c:	1141                	addi	sp,sp,-16
ffffffffc0204c8e:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204c90:	cf91                	beqz	a5,ffffffffc0204cac <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0204c92:	ee0d                	bnez	a2,ffffffffc0204ccc <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0204c94:	679c                	ld	a5,8(a5)
}
ffffffffc0204c96:	60a2                	ld	ra,8(sp)
ffffffffc0204c98:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204c9a:	6394                	ld	a3,0(a5)
ffffffffc0204c9c:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204c9e:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204ca2:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204ca4:	e314                	sd	a3,0(a4)
ffffffffc0204ca6:	e19c                	sd	a5,0(a1)
}
ffffffffc0204ca8:	0141                	addi	sp,sp,16
ffffffffc0204caa:	8082                	ret
         assert(head != NULL);
ffffffffc0204cac:	00004697          	auipc	a3,0x4
ffffffffc0204cb0:	93468693          	addi	a3,a3,-1740 # ffffffffc02085e0 <default_pmm_manager+0x1e8>
ffffffffc0204cb4:	00002617          	auipc	a2,0x2
ffffffffc0204cb8:	14460613          	addi	a2,a2,324 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204cbc:	04100593          	li	a1,65
ffffffffc0204cc0:	00003517          	auipc	a0,0x3
ffffffffc0204cc4:	7b050513          	addi	a0,a0,1968 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204cc8:	d4cfb0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(in_tick==0);
ffffffffc0204ccc:	00004697          	auipc	a3,0x4
ffffffffc0204cd0:	92468693          	addi	a3,a3,-1756 # ffffffffc02085f0 <default_pmm_manager+0x1f8>
ffffffffc0204cd4:	00002617          	auipc	a2,0x2
ffffffffc0204cd8:	12460613          	addi	a2,a2,292 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204cdc:	04200593          	li	a1,66
ffffffffc0204ce0:	00003517          	auipc	a0,0x3
ffffffffc0204ce4:	79050513          	addi	a0,a0,1936 # ffffffffc0208470 <default_pmm_manager+0x78>
ffffffffc0204ce8:	d2cfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204cec <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204cec:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204cf0:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204cf2:	cb09                	beqz	a4,ffffffffc0204d04 <_fifo_map_swappable+0x18>
ffffffffc0204cf4:	cb81                	beqz	a5,ffffffffc0204d04 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204cf6:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204cf8:	e398                	sd	a4,0(a5)
}
ffffffffc0204cfa:	4501                	li	a0,0
ffffffffc0204cfc:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204cfe:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0204d00:	f614                	sd	a3,40(a2)
ffffffffc0204d02:	8082                	ret
{
ffffffffc0204d04:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204d06:	00004697          	auipc	a3,0x4
ffffffffc0204d0a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02085c0 <default_pmm_manager+0x1c8>
ffffffffc0204d0e:	00002617          	auipc	a2,0x2
ffffffffc0204d12:	0ea60613          	addi	a2,a2,234 # ffffffffc0206df8 <commands+0x480>
ffffffffc0204d16:	03200593          	li	a1,50
ffffffffc0204d1a:	00003517          	auipc	a0,0x3
ffffffffc0204d1e:	75650513          	addi	a0,a0,1878 # ffffffffc0208470 <default_pmm_manager+0x78>
{
ffffffffc0204d22:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204d24:	cf0fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204d28 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204d28:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d2a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204d2c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d2e:	803fb0ef          	jal	ra,ffffffffc0200530 <ide_device_valid>
ffffffffc0204d32:	cd01                	beqz	a0,ffffffffc0204d4a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d34:	4505                	li	a0,1
ffffffffc0204d36:	801fb0ef          	jal	ra,ffffffffc0200536 <ide_device_size>
}
ffffffffc0204d3a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d3c:	810d                	srli	a0,a0,0x3
ffffffffc0204d3e:	000a8797          	auipc	a5,0xa8
ffffffffc0204d42:	bea7b123          	sd	a0,-1054(a5) # ffffffffc02ac920 <max_swap_offset>
}
ffffffffc0204d46:	0141                	addi	sp,sp,16
ffffffffc0204d48:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204d4a:	00004617          	auipc	a2,0x4
ffffffffc0204d4e:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0208618 <default_pmm_manager+0x220>
ffffffffc0204d52:	45b5                	li	a1,13
ffffffffc0204d54:	00004517          	auipc	a0,0x4
ffffffffc0204d58:	8e450513          	addi	a0,a0,-1820 # ffffffffc0208638 <default_pmm_manager+0x240>
ffffffffc0204d5c:	cb8fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204d60 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204d60:	1141                	addi	sp,sp,-16
ffffffffc0204d62:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d64:	00855793          	srli	a5,a0,0x8
ffffffffc0204d68:	cfb9                	beqz	a5,ffffffffc0204dc6 <swapfs_read+0x66>
ffffffffc0204d6a:	000a8717          	auipc	a4,0xa8
ffffffffc0204d6e:	bb670713          	addi	a4,a4,-1098 # ffffffffc02ac920 <max_swap_offset>
ffffffffc0204d72:	6318                	ld	a4,0(a4)
ffffffffc0204d74:	04e7f963          	bgeu	a5,a4,ffffffffc0204dc6 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204d78:	000a8717          	auipc	a4,0xa8
ffffffffc0204d7c:	b1070713          	addi	a4,a4,-1264 # ffffffffc02ac888 <pages>
ffffffffc0204d80:	6310                	ld	a2,0(a4)
ffffffffc0204d82:	00004717          	auipc	a4,0x4
ffffffffc0204d86:	20670713          	addi	a4,a4,518 # ffffffffc0208f88 <nbase>
ffffffffc0204d8a:	40c58633          	sub	a2,a1,a2
ffffffffc0204d8e:	630c                	ld	a1,0(a4)
ffffffffc0204d90:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204d92:	000a8717          	auipc	a4,0xa8
ffffffffc0204d96:	a8e70713          	addi	a4,a4,-1394 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0204d9a:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204d9c:	6314                	ld	a3,0(a4)
ffffffffc0204d9e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204da2:	8331                	srli	a4,a4,0xc
ffffffffc0204da4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204da8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204daa:	02d77a63          	bgeu	a4,a3,ffffffffc0204dde <swapfs_read+0x7e>
ffffffffc0204dae:	000a8797          	auipc	a5,0xa8
ffffffffc0204db2:	aca78793          	addi	a5,a5,-1334 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0204db6:	639c                	ld	a5,0(a5)
}
ffffffffc0204db8:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dba:	46a1                	li	a3,8
ffffffffc0204dbc:	963e                	add	a2,a2,a5
ffffffffc0204dbe:	4505                	li	a0,1
}
ffffffffc0204dc0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dc2:	f7afb06f          	j	ffffffffc020053c <ide_read_secs>
ffffffffc0204dc6:	86aa                	mv	a3,a0
ffffffffc0204dc8:	00004617          	auipc	a2,0x4
ffffffffc0204dcc:	88860613          	addi	a2,a2,-1912 # ffffffffc0208650 <default_pmm_manager+0x258>
ffffffffc0204dd0:	45d1                	li	a1,20
ffffffffc0204dd2:	00004517          	auipc	a0,0x4
ffffffffc0204dd6:	86650513          	addi	a0,a0,-1946 # ffffffffc0208638 <default_pmm_manager+0x240>
ffffffffc0204dda:	c3afb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0204dde:	86b2                	mv	a3,a2
ffffffffc0204de0:	06900593          	li	a1,105
ffffffffc0204de4:	00002617          	auipc	a2,0x2
ffffffffc0204de8:	43c60613          	addi	a2,a2,1084 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0204dec:	00002517          	auipc	a0,0x2
ffffffffc0204df0:	48c50513          	addi	a0,a0,1164 # ffffffffc0207278 <commands+0x900>
ffffffffc0204df4:	c20fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204df8 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204df8:	1141                	addi	sp,sp,-16
ffffffffc0204dfa:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dfc:	00855793          	srli	a5,a0,0x8
ffffffffc0204e00:	cfb9                	beqz	a5,ffffffffc0204e5e <swapfs_write+0x66>
ffffffffc0204e02:	000a8717          	auipc	a4,0xa8
ffffffffc0204e06:	b1e70713          	addi	a4,a4,-1250 # ffffffffc02ac920 <max_swap_offset>
ffffffffc0204e0a:	6318                	ld	a4,0(a4)
ffffffffc0204e0c:	04e7f963          	bgeu	a5,a4,ffffffffc0204e5e <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204e10:	000a8717          	auipc	a4,0xa8
ffffffffc0204e14:	a7870713          	addi	a4,a4,-1416 # ffffffffc02ac888 <pages>
ffffffffc0204e18:	6310                	ld	a2,0(a4)
ffffffffc0204e1a:	00004717          	auipc	a4,0x4
ffffffffc0204e1e:	16e70713          	addi	a4,a4,366 # ffffffffc0208f88 <nbase>
ffffffffc0204e22:	40c58633          	sub	a2,a1,a2
ffffffffc0204e26:	630c                	ld	a1,0(a4)
ffffffffc0204e28:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204e2a:	000a8717          	auipc	a4,0xa8
ffffffffc0204e2e:	9f670713          	addi	a4,a4,-1546 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0204e32:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204e34:	6314                	ld	a3,0(a4)
ffffffffc0204e36:	00c61713          	slli	a4,a2,0xc
ffffffffc0204e3a:	8331                	srli	a4,a4,0xc
ffffffffc0204e3c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e40:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e42:	02d77a63          	bgeu	a4,a3,ffffffffc0204e76 <swapfs_write+0x7e>
ffffffffc0204e46:	000a8797          	auipc	a5,0xa8
ffffffffc0204e4a:	a3278793          	addi	a5,a5,-1486 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0204e4e:	639c                	ld	a5,0(a5)
}
ffffffffc0204e50:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e52:	46a1                	li	a3,8
ffffffffc0204e54:	963e                	add	a2,a2,a5
ffffffffc0204e56:	4505                	li	a0,1
}
ffffffffc0204e58:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e5a:	f06fb06f          	j	ffffffffc0200560 <ide_write_secs>
ffffffffc0204e5e:	86aa                	mv	a3,a0
ffffffffc0204e60:	00003617          	auipc	a2,0x3
ffffffffc0204e64:	7f060613          	addi	a2,a2,2032 # ffffffffc0208650 <default_pmm_manager+0x258>
ffffffffc0204e68:	45e5                	li	a1,25
ffffffffc0204e6a:	00003517          	auipc	a0,0x3
ffffffffc0204e6e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0208638 <default_pmm_manager+0x240>
ffffffffc0204e72:	ba2fb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0204e76:	86b2                	mv	a3,a2
ffffffffc0204e78:	06900593          	li	a1,105
ffffffffc0204e7c:	00002617          	auipc	a2,0x2
ffffffffc0204e80:	3a460613          	addi	a2,a2,932 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0204e84:	00002517          	auipc	a0,0x2
ffffffffc0204e88:	3f450513          	addi	a0,a0,1012 # ffffffffc0207278 <commands+0x900>
ffffffffc0204e8c:	b88fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204e90 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204e90:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204e92:	9402                	jalr	s0

	jal do_exit
ffffffffc0204e94:	79c000ef          	jal	ra,ffffffffc0205630 <do_exit>

ffffffffc0204e98 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204e98:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204e9c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204ea0:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204ea2:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204ea4:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204ea8:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204eac:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204eb0:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204eb4:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204eb8:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ebc:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204ec0:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204ec4:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204ec8:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204ecc:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204ed0:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204ed4:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204ed6:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204ed8:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204edc:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204ee0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204ee4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204ee8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204eec:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204ef0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204ef4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204ef8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204efc:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204f00:	8082                	ret

ffffffffc0204f02 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204f02:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204f04:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204f08:	e022                	sd	s0,0(sp)
ffffffffc0204f0a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204f0c:	bd8fe0ef          	jal	ra,ffffffffc02032e4 <kmalloc>
ffffffffc0204f10:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204f12:	cd29                	beqz	a0,ffffffffc0204f6c <alloc_proc+0x6a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;            // 初始化状态为未初始化
ffffffffc0204f14:	57fd                	li	a5,-1
ffffffffc0204f16:	1782                	slli	a5,a5,0x20
ffffffffc0204f18:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                       // 初始化运行时间片
        proc->kstack = 0;                     // 内核栈地址初始化为0
        proc->need_resched = 0;               // 初始时无需调度
        proc->parent = NULL;                  // 父进程为空
        proc->mm = NULL;                      // 虚拟内存管理结构为空
        memset(&(proc->context), 0, sizeof(struct context));  // 清空上下文
ffffffffc0204f1a:	07000613          	li	a2,112
ffffffffc0204f1e:	4581                	li	a1,0
        proc->runs = 0;                       // 初始化运行时间片
ffffffffc0204f20:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                     // 内核栈地址初始化为0
ffffffffc0204f24:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;               // 初始时无需调度
ffffffffc0204f28:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;                  // 父进程为空
ffffffffc0204f2c:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                      // 虚拟内存管理结构为空
ffffffffc0204f30:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));  // 清空上下文
ffffffffc0204f34:	03050513          	addi	a0,a0,48
ffffffffc0204f38:	4a0010ef          	jal	ra,ffffffffc02063d8 <memset>
        proc->tf = NULL;                      // 中断帧指针初始化为空
        proc->cr3 = boot_cr3;                 // 页表基址设置为内核页表
ffffffffc0204f3c:	000a8797          	auipc	a5,0xa8
ffffffffc0204f40:	94478793          	addi	a5,a5,-1724 # ffffffffc02ac880 <boot_cr3>
ffffffffc0204f44:	639c                	ld	a5,0(a5)
        proc->tf = NULL;                      // 中断帧指针初始化为空
ffffffffc0204f46:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                      // 标志位初始化为0
ffffffffc0204f4a:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;                 // 页表基址设置为内核页表
ffffffffc0204f4e:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN); // 清空进程名
ffffffffc0204f50:	463d                	li	a2,15
ffffffffc0204f52:	4581                	li	a1,0
ffffffffc0204f54:	0b440513          	addi	a0,s0,180
ffffffffc0204f58:	480010ef          	jal	ra,ffffffffc02063d8 <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;
ffffffffc0204f5c:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204f60:	10043023          	sd	zero,256(s0)
ffffffffc0204f64:	0e043c23          	sd	zero,248(s0)
ffffffffc0204f68:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204f6c:	8522                	mv	a0,s0
ffffffffc0204f6e:	60a2                	ld	ra,8(sp)
ffffffffc0204f70:	6402                	ld	s0,0(sp)
ffffffffc0204f72:	0141                	addi	sp,sp,16
ffffffffc0204f74:	8082                	ret

ffffffffc0204f76 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204f76:	000a8797          	auipc	a5,0xa8
ffffffffc0204f7a:	8d278793          	addi	a5,a5,-1838 # ffffffffc02ac848 <current>
ffffffffc0204f7e:	639c                	ld	a5,0(a5)
ffffffffc0204f80:	73c8                	ld	a0,160(a5)
ffffffffc0204f82:	e11fb06f          	j	ffffffffc0200d92 <forkrets>

ffffffffc0204f86 <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204f86:	000a8797          	auipc	a5,0xa8
ffffffffc0204f8a:	8c278793          	addi	a5,a5,-1854 # ffffffffc02ac848 <current>
ffffffffc0204f8e:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204f90:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204f92:	00004617          	auipc	a2,0x4
ffffffffc0204f96:	ace60613          	addi	a2,a2,-1330 # ffffffffc0208a60 <default_pmm_manager+0x668>
ffffffffc0204f9a:	43cc                	lw	a1,4(a5)
ffffffffc0204f9c:	00004517          	auipc	a0,0x4
ffffffffc0204fa0:	acc50513          	addi	a0,a0,-1332 # ffffffffc0208a68 <default_pmm_manager+0x670>
user_main(void *arg) {
ffffffffc0204fa4:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204fa6:	92afb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204faa:	00004797          	auipc	a5,0x4
ffffffffc0204fae:	ab678793          	addi	a5,a5,-1354 # ffffffffc0208a60 <default_pmm_manager+0x668>
ffffffffc0204fb2:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204fb6:	b1670713          	addi	a4,a4,-1258 # aac8 <_binary_obj___user_exit_out_size>
ffffffffc0204fba:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204fbc:	853e                	mv	a0,a5
ffffffffc0204fbe:	0004b717          	auipc	a4,0x4b
ffffffffc0204fc2:	69270713          	addi	a4,a4,1682 # ffffffffc0250650 <_binary_obj___user_exit_out_start>
ffffffffc0204fc6:	f03a                	sd	a4,32(sp)
ffffffffc0204fc8:	f43e                	sd	a5,40(sp)
ffffffffc0204fca:	e802                	sd	zero,16(sp)
ffffffffc0204fcc:	36e010ef          	jal	ra,ffffffffc020633a <strlen>
ffffffffc0204fd0:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204fd2:	4511                	li	a0,4
ffffffffc0204fd4:	55a2                	lw	a1,40(sp)
ffffffffc0204fd6:	4662                	lw	a2,24(sp)
ffffffffc0204fd8:	5682                	lw	a3,32(sp)
ffffffffc0204fda:	4722                	lw	a4,8(sp)
ffffffffc0204fdc:	48a9                	li	a7,10
ffffffffc0204fde:	9002                	ebreak
ffffffffc0204fe0:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204fe2:	65c2                	ld	a1,16(sp)
ffffffffc0204fe4:	00004517          	auipc	a0,0x4
ffffffffc0204fe8:	aac50513          	addi	a0,a0,-1364 # ffffffffc0208a90 <default_pmm_manager+0x698>
ffffffffc0204fec:	8e4fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204ff0:	00004617          	auipc	a2,0x4
ffffffffc0204ff4:	ab060613          	addi	a2,a2,-1360 # ffffffffc0208aa0 <default_pmm_manager+0x6a8>
ffffffffc0204ff8:	34800593          	li	a1,840
ffffffffc0204ffc:	00004517          	auipc	a0,0x4
ffffffffc0205000:	ac450513          	addi	a0,a0,-1340 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205004:	a10fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205008 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0205008:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc020500a:	1141                	addi	sp,sp,-16
ffffffffc020500c:	e406                	sd	ra,8(sp)
ffffffffc020500e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205012:	04f6e263          	bltu	a3,a5,ffffffffc0205056 <put_pgdir+0x4e>
ffffffffc0205016:	000a8797          	auipc	a5,0xa8
ffffffffc020501a:	86278793          	addi	a5,a5,-1950 # ffffffffc02ac878 <va_pa_offset>
ffffffffc020501e:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205020:	000a8797          	auipc	a5,0xa8
ffffffffc0205024:	80078793          	addi	a5,a5,-2048 # ffffffffc02ac820 <npage>
ffffffffc0205028:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020502a:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc020502c:	82b1                	srli	a3,a3,0xc
ffffffffc020502e:	04f6f063          	bgeu	a3,a5,ffffffffc020506e <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0205032:	00004797          	auipc	a5,0x4
ffffffffc0205036:	f5678793          	addi	a5,a5,-170 # ffffffffc0208f88 <nbase>
ffffffffc020503a:	639c                	ld	a5,0(a5)
ffffffffc020503c:	000a8717          	auipc	a4,0xa8
ffffffffc0205040:	84c70713          	addi	a4,a4,-1972 # ffffffffc02ac888 <pages>
ffffffffc0205044:	6308                	ld	a0,0(a4)
}
ffffffffc0205046:	60a2                	ld	ra,8(sp)
ffffffffc0205048:	8e9d                	sub	a3,a3,a5
ffffffffc020504a:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020504c:	4585                	li	a1,1
ffffffffc020504e:	9536                	add	a0,a0,a3
}
ffffffffc0205050:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0205052:	e91fb06f          	j	ffffffffc0200ee2 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0205056:	00002617          	auipc	a2,0x2
ffffffffc020505a:	2a260613          	addi	a2,a2,674 # ffffffffc02072f8 <commands+0x980>
ffffffffc020505e:	06e00593          	li	a1,110
ffffffffc0205062:	00002517          	auipc	a0,0x2
ffffffffc0205066:	21650513          	addi	a0,a0,534 # ffffffffc0207278 <commands+0x900>
ffffffffc020506a:	9aafb0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020506e:	00002617          	auipc	a2,0x2
ffffffffc0205072:	1ea60613          	addi	a2,a2,490 # ffffffffc0207258 <commands+0x8e0>
ffffffffc0205076:	06200593          	li	a1,98
ffffffffc020507a:	00002517          	auipc	a0,0x2
ffffffffc020507e:	1fe50513          	addi	a0,a0,510 # ffffffffc0207278 <commands+0x900>
ffffffffc0205082:	992fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205086 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0205086:	1101                	addi	sp,sp,-32
ffffffffc0205088:	e426                	sd	s1,8(sp)
ffffffffc020508a:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc020508c:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc020508e:	ec06                	sd	ra,24(sp)
ffffffffc0205090:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0205092:	dc9fb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0205096:	c125                	beqz	a0,ffffffffc02050f6 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0205098:	000a7797          	auipc	a5,0xa7
ffffffffc020509c:	7f078793          	addi	a5,a5,2032 # ffffffffc02ac888 <pages>
ffffffffc02050a0:	6394                	ld	a3,0(a5)
ffffffffc02050a2:	00004797          	auipc	a5,0x4
ffffffffc02050a6:	ee678793          	addi	a5,a5,-282 # ffffffffc0208f88 <nbase>
ffffffffc02050aa:	6380                	ld	s0,0(a5)
ffffffffc02050ac:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02050b0:	000a7797          	auipc	a5,0xa7
ffffffffc02050b4:	77078793          	addi	a5,a5,1904 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc02050b8:	8699                	srai	a3,a3,0x6
ffffffffc02050ba:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc02050bc:	6398                	ld	a4,0(a5)
ffffffffc02050be:	00c69793          	slli	a5,a3,0xc
ffffffffc02050c2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02050c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050c6:	02e7fa63          	bgeu	a5,a4,ffffffffc02050fa <setup_pgdir+0x74>
ffffffffc02050ca:	000a7797          	auipc	a5,0xa7
ffffffffc02050ce:	7ae78793          	addi	a5,a5,1966 # ffffffffc02ac878 <va_pa_offset>
ffffffffc02050d2:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02050d4:	000a7797          	auipc	a5,0xa7
ffffffffc02050d8:	74478793          	addi	a5,a5,1860 # ffffffffc02ac818 <boot_pgdir>
ffffffffc02050dc:	638c                	ld	a1,0(a5)
ffffffffc02050de:	9436                	add	s0,s0,a3
ffffffffc02050e0:	6605                	lui	a2,0x1
ffffffffc02050e2:	8522                	mv	a0,s0
ffffffffc02050e4:	306010ef          	jal	ra,ffffffffc02063ea <memcpy>
    return 0;
ffffffffc02050e8:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc02050ea:	ec80                	sd	s0,24(s1)
}
ffffffffc02050ec:	60e2                	ld	ra,24(sp)
ffffffffc02050ee:	6442                	ld	s0,16(sp)
ffffffffc02050f0:	64a2                	ld	s1,8(sp)
ffffffffc02050f2:	6105                	addi	sp,sp,32
ffffffffc02050f4:	8082                	ret
        return -E_NO_MEM;
ffffffffc02050f6:	5571                	li	a0,-4
ffffffffc02050f8:	bfd5                	j	ffffffffc02050ec <setup_pgdir+0x66>
ffffffffc02050fa:	00002617          	auipc	a2,0x2
ffffffffc02050fe:	12660613          	addi	a2,a2,294 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0205102:	06900593          	li	a1,105
ffffffffc0205106:	00002517          	auipc	a0,0x2
ffffffffc020510a:	17250513          	addi	a0,a0,370 # ffffffffc0207278 <commands+0x900>
ffffffffc020510e:	906fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205112 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205112:	1101                	addi	sp,sp,-32
ffffffffc0205114:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205116:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020511a:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020511c:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020511e:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205120:	8522                	mv	a0,s0
ffffffffc0205122:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205124:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205126:	2b2010ef          	jal	ra,ffffffffc02063d8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020512a:	8522                	mv	a0,s0
}
ffffffffc020512c:	6442                	ld	s0,16(sp)
ffffffffc020512e:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205130:	85a6                	mv	a1,s1
}
ffffffffc0205132:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205134:	463d                	li	a2,15
}
ffffffffc0205136:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205138:	2b20106f          	j	ffffffffc02063ea <memcpy>

ffffffffc020513c <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc020513c:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc020513e:	000a7797          	auipc	a5,0xa7
ffffffffc0205142:	70a78793          	addi	a5,a5,1802 # ffffffffc02ac848 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0205146:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0205148:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc020514a:	ec06                	sd	ra,24(sp)
ffffffffc020514c:	e822                	sd	s0,16(sp)
ffffffffc020514e:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0205150:	02a48b63          	beq	s1,a0,ffffffffc0205186 <proc_run+0x4a>
ffffffffc0205154:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205156:	100027f3          	csrr	a5,sstatus
ffffffffc020515a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020515c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020515e:	e3a9                	bnez	a5,ffffffffc02051a0 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0205160:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0205162:	000a7717          	auipc	a4,0xa7
ffffffffc0205166:	6e873323          	sd	s0,1766(a4) # ffffffffc02ac848 <current>
ffffffffc020516a:	577d                	li	a4,-1
ffffffffc020516c:	177e                	slli	a4,a4,0x3f
ffffffffc020516e:	83b1                	srli	a5,a5,0xc
ffffffffc0205170:	8fd9                	or	a5,a5,a4
ffffffffc0205172:	18079073          	csrw	satp,a5
            switch_to(&(temp->context),&(proc->context));            
ffffffffc0205176:	03040593          	addi	a1,s0,48
ffffffffc020517a:	03048513          	addi	a0,s1,48
ffffffffc020517e:	d1bff0ef          	jal	ra,ffffffffc0204e98 <switch_to>
    if (flag) {
ffffffffc0205182:	00091863          	bnez	s2,ffffffffc0205192 <proc_run+0x56>
}
ffffffffc0205186:	60e2                	ld	ra,24(sp)
ffffffffc0205188:	6442                	ld	s0,16(sp)
ffffffffc020518a:	64a2                	ld	s1,8(sp)
ffffffffc020518c:	6902                	ld	s2,0(sp)
ffffffffc020518e:	6105                	addi	sp,sp,32
ffffffffc0205190:	8082                	ret
ffffffffc0205192:	6442                	ld	s0,16(sp)
ffffffffc0205194:	60e2                	ld	ra,24(sp)
ffffffffc0205196:	64a2                	ld	s1,8(sp)
ffffffffc0205198:	6902                	ld	s2,0(sp)
ffffffffc020519a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020519c:	cb2fb06f          	j	ffffffffc020064e <intr_enable>
        intr_disable();
ffffffffc02051a0:	cb4fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc02051a4:	4905                	li	s2,1
ffffffffc02051a6:	bf6d                	j	ffffffffc0205160 <proc_run+0x24>

ffffffffc02051a8 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02051a8:	0005071b          	sext.w	a4,a0
ffffffffc02051ac:	6789                	lui	a5,0x2
ffffffffc02051ae:	fff7069b          	addiw	a3,a4,-1
ffffffffc02051b2:	17f9                	addi	a5,a5,-2
ffffffffc02051b4:	04d7e063          	bltu	a5,a3,ffffffffc02051f4 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02051b8:	1141                	addi	sp,sp,-16
ffffffffc02051ba:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02051bc:	45a9                	li	a1,10
ffffffffc02051be:	842a                	mv	s0,a0
ffffffffc02051c0:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02051c2:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02051c4:	62a010ef          	jal	ra,ffffffffc02067ee <hash32>
ffffffffc02051c8:	02051693          	slli	a3,a0,0x20
ffffffffc02051cc:	82f1                	srli	a3,a3,0x1c
ffffffffc02051ce:	000a3517          	auipc	a0,0xa3
ffffffffc02051d2:	63a50513          	addi	a0,a0,1594 # ffffffffc02a8808 <hash_list>
ffffffffc02051d6:	96aa                	add	a3,a3,a0
ffffffffc02051d8:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02051da:	a029                	j	ffffffffc02051e4 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc02051dc:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc02051e0:	00870c63          	beq	a4,s0,ffffffffc02051f8 <find_proc+0x50>
    return listelm->next;
ffffffffc02051e4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02051e6:	fef69be3          	bne	a3,a5,ffffffffc02051dc <find_proc+0x34>
}
ffffffffc02051ea:	60a2                	ld	ra,8(sp)
ffffffffc02051ec:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02051ee:	4501                	li	a0,0
}
ffffffffc02051f0:	0141                	addi	sp,sp,16
ffffffffc02051f2:	8082                	ret
    return NULL;
ffffffffc02051f4:	4501                	li	a0,0
}
ffffffffc02051f6:	8082                	ret
ffffffffc02051f8:	60a2                	ld	ra,8(sp)
ffffffffc02051fa:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02051fc:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205200:	0141                	addi	sp,sp,16
ffffffffc0205202:	8082                	ret

ffffffffc0205204 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205204:	7159                	addi	sp,sp,-112
ffffffffc0205206:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205208:	000a7a17          	auipc	s4,0xa7
ffffffffc020520c:	658a0a13          	addi	s4,s4,1624 # ffffffffc02ac860 <nr_process>
ffffffffc0205210:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205214:	f486                	sd	ra,104(sp)
ffffffffc0205216:	f0a2                	sd	s0,96(sp)
ffffffffc0205218:	eca6                	sd	s1,88(sp)
ffffffffc020521a:	e8ca                	sd	s2,80(sp)
ffffffffc020521c:	e4ce                	sd	s3,72(sp)
ffffffffc020521e:	fc56                	sd	s5,56(sp)
ffffffffc0205220:	f85a                	sd	s6,48(sp)
ffffffffc0205222:	f45e                	sd	s7,40(sp)
ffffffffc0205224:	f062                	sd	s8,32(sp)
ffffffffc0205226:	ec66                	sd	s9,24(sp)
ffffffffc0205228:	e86a                	sd	s10,16(sp)
ffffffffc020522a:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020522c:	6785                	lui	a5,0x1
ffffffffc020522e:	30f75a63          	bge	a4,a5,ffffffffc0205542 <do_fork+0x33e>
ffffffffc0205232:	89aa                	mv	s3,a0
ffffffffc0205234:	892e                	mv	s2,a1
ffffffffc0205236:	84b2                	mv	s1,a2
    if((proc = alloc_proc()) == NULL){
ffffffffc0205238:	ccbff0ef          	jal	ra,ffffffffc0204f02 <alloc_proc>
ffffffffc020523c:	842a                	mv	s0,a0
ffffffffc020523e:	2e050463          	beqz	a0,ffffffffc0205526 <do_fork+0x322>
    proc->parent = current;
ffffffffc0205242:	000a7c17          	auipc	s8,0xa7
ffffffffc0205246:	606c0c13          	addi	s8,s8,1542 # ffffffffc02ac848 <current>
ffffffffc020524a:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc020524e:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84dc>
    proc->parent = current;
ffffffffc0205252:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205254:	30071563          	bnez	a4,ffffffffc020555e <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205258:	4509                	li	a0,2
ffffffffc020525a:	c01fb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
    if (page != NULL) {
ffffffffc020525e:	2c050163          	beqz	a0,ffffffffc0205520 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205262:	000a7a97          	auipc	s5,0xa7
ffffffffc0205266:	626a8a93          	addi	s5,s5,1574 # ffffffffc02ac888 <pages>
ffffffffc020526a:	000ab683          	ld	a3,0(s5)
ffffffffc020526e:	00004b17          	auipc	s6,0x4
ffffffffc0205272:	d1ab0b13          	addi	s6,s6,-742 # ffffffffc0208f88 <nbase>
ffffffffc0205276:	000b3783          	ld	a5,0(s6)
ffffffffc020527a:	40d506b3          	sub	a3,a0,a3
ffffffffc020527e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205280:	000a7b97          	auipc	s7,0xa7
ffffffffc0205284:	5a0b8b93          	addi	s7,s7,1440 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0205288:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020528a:	000bb703          	ld	a4,0(s7)
ffffffffc020528e:	00c69793          	slli	a5,a3,0xc
ffffffffc0205292:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205294:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205296:	2ae7f863          	bgeu	a5,a4,ffffffffc0205546 <do_fork+0x342>
ffffffffc020529a:	000a7c97          	auipc	s9,0xa7
ffffffffc020529e:	5dec8c93          	addi	s9,s9,1502 # ffffffffc02ac878 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02052a2:	000c3703          	ld	a4,0(s8)
ffffffffc02052a6:	000cb783          	ld	a5,0(s9)
ffffffffc02052aa:	02873c03          	ld	s8,40(a4)
ffffffffc02052ae:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02052b0:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc02052b2:	020c0863          	beqz	s8,ffffffffc02052e2 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc02052b6:	1009f993          	andi	s3,s3,256
ffffffffc02052ba:	1e098163          	beqz	s3,ffffffffc020549c <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02052be:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02052c2:	018c3783          	ld	a5,24(s8)
ffffffffc02052c6:	c02006b7          	lui	a3,0xc0200
ffffffffc02052ca:	2705                	addiw	a4,a4,1
ffffffffc02052cc:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc02052d0:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02052d4:	2ad7e563          	bltu	a5,a3,ffffffffc020557e <do_fork+0x37a>
ffffffffc02052d8:	000cb703          	ld	a4,0(s9)
ffffffffc02052dc:	6814                	ld	a3,16(s0)
ffffffffc02052de:	8f99                	sub	a5,a5,a4
ffffffffc02052e0:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02052e2:	6789                	lui	a5,0x2
ffffffffc02052e4:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>
ffffffffc02052e8:	96be                	add	a3,a3,a5
ffffffffc02052ea:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02052ec:	87b6                	mv	a5,a3
ffffffffc02052ee:	12048813          	addi	a6,s1,288
ffffffffc02052f2:	6088                	ld	a0,0(s1)
ffffffffc02052f4:	648c                	ld	a1,8(s1)
ffffffffc02052f6:	6890                	ld	a2,16(s1)
ffffffffc02052f8:	6c98                	ld	a4,24(s1)
ffffffffc02052fa:	e388                	sd	a0,0(a5)
ffffffffc02052fc:	e78c                	sd	a1,8(a5)
ffffffffc02052fe:	eb90                	sd	a2,16(a5)
ffffffffc0205300:	ef98                	sd	a4,24(a5)
ffffffffc0205302:	02048493          	addi	s1,s1,32
ffffffffc0205306:	02078793          	addi	a5,a5,32
ffffffffc020530a:	ff0494e3          	bne	s1,a6,ffffffffc02052f2 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc020530e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205312:	12090e63          	beqz	s2,ffffffffc020544e <do_fork+0x24a>
ffffffffc0205316:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020531a:	00000797          	auipc	a5,0x0
ffffffffc020531e:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204f76 <forkret>
ffffffffc0205322:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205324:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205326:	100027f3          	csrr	a5,sstatus
ffffffffc020532a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020532c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020532e:	12079f63          	bnez	a5,ffffffffc020546c <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205332:	0009c797          	auipc	a5,0x9c
ffffffffc0205336:	0ce78793          	addi	a5,a5,206 # ffffffffc02a1400 <last_pid.1691>
ffffffffc020533a:	439c                	lw	a5,0(a5)
ffffffffc020533c:	6709                	lui	a4,0x2
ffffffffc020533e:	0017851b          	addiw	a0,a5,1
ffffffffc0205342:	0009c697          	auipc	a3,0x9c
ffffffffc0205346:	0aa6af23          	sw	a0,190(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020534a:	14e55263          	bge	a0,a4,ffffffffc020548e <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc020534e:	0009c797          	auipc	a5,0x9c
ffffffffc0205352:	0b678793          	addi	a5,a5,182 # ffffffffc02a1404 <next_safe.1690>
ffffffffc0205356:	439c                	lw	a5,0(a5)
ffffffffc0205358:	000a7497          	auipc	s1,0xa7
ffffffffc020535c:	63048493          	addi	s1,s1,1584 # ffffffffc02ac988 <proc_list>
ffffffffc0205360:	06f54063          	blt	a0,a5,ffffffffc02053c0 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205364:	6789                	lui	a5,0x2
ffffffffc0205366:	0009c717          	auipc	a4,0x9c
ffffffffc020536a:	08f72f23          	sw	a5,158(a4) # ffffffffc02a1404 <next_safe.1690>
ffffffffc020536e:	4581                	li	a1,0
ffffffffc0205370:	87aa                	mv	a5,a0
ffffffffc0205372:	000a7497          	auipc	s1,0xa7
ffffffffc0205376:	61648493          	addi	s1,s1,1558 # ffffffffc02ac988 <proc_list>
    repeat:
ffffffffc020537a:	6889                	lui	a7,0x2
ffffffffc020537c:	882e                	mv	a6,a1
ffffffffc020537e:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205380:	000a7697          	auipc	a3,0xa7
ffffffffc0205384:	60868693          	addi	a3,a3,1544 # ffffffffc02ac988 <proc_list>
ffffffffc0205388:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020538a:	00968f63          	beq	a3,s1,ffffffffc02053a8 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc020538e:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205392:	0ae78963          	beq	a5,a4,ffffffffc0205444 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205396:	fee7d9e3          	bge	a5,a4,ffffffffc0205388 <do_fork+0x184>
ffffffffc020539a:	fec757e3          	bge	a4,a2,ffffffffc0205388 <do_fork+0x184>
ffffffffc020539e:	6694                	ld	a3,8(a3)
ffffffffc02053a0:	863a                	mv	a2,a4
ffffffffc02053a2:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02053a4:	fe9695e3          	bne	a3,s1,ffffffffc020538e <do_fork+0x18a>
ffffffffc02053a8:	c591                	beqz	a1,ffffffffc02053b4 <do_fork+0x1b0>
ffffffffc02053aa:	0009c717          	auipc	a4,0x9c
ffffffffc02053ae:	04f72b23          	sw	a5,86(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc02053b2:	853e                	mv	a0,a5
ffffffffc02053b4:	00080663          	beqz	a6,ffffffffc02053c0 <do_fork+0x1bc>
ffffffffc02053b8:	0009c797          	auipc	a5,0x9c
ffffffffc02053bc:	04c7a623          	sw	a2,76(a5) # ffffffffc02a1404 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc02053c0:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02053c2:	45a9                	li	a1,10
ffffffffc02053c4:	2501                	sext.w	a0,a0
ffffffffc02053c6:	428010ef          	jal	ra,ffffffffc02067ee <hash32>
ffffffffc02053ca:	1502                	slli	a0,a0,0x20
ffffffffc02053cc:	000a3797          	auipc	a5,0xa3
ffffffffc02053d0:	43c78793          	addi	a5,a5,1084 # ffffffffc02a8808 <hash_list>
ffffffffc02053d4:	8171                	srli	a0,a0,0x1c
ffffffffc02053d6:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02053d8:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02053da:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02053dc:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02053e0:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02053e2:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02053e4:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02053e6:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02053e8:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02053ec:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02053ee:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02053f0:	e21c                	sd	a5,0(a2)
ffffffffc02053f2:	000a7597          	auipc	a1,0xa7
ffffffffc02053f6:	58f5bf23          	sd	a5,1438(a1) # ffffffffc02ac990 <proc_list+0x8>
    elm->next = next;
ffffffffc02053fa:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02053fc:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02053fe:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205402:	10e43023          	sd	a4,256(s0)
ffffffffc0205406:	c311                	beqz	a4,ffffffffc020540a <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc0205408:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc020540a:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc020540e:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc0205410:	2785                	addiw	a5,a5,1
ffffffffc0205412:	000a7717          	auipc	a4,0xa7
ffffffffc0205416:	44f72723          	sw	a5,1102(a4) # ffffffffc02ac860 <nr_process>
    if (flag) {
ffffffffc020541a:	10091863          	bnez	s2,ffffffffc020552a <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc020541e:	8522                	mv	a0,s0
ffffffffc0205420:	529000ef          	jal	ra,ffffffffc0206148 <wakeup_proc>
    ret = proc->pid;
ffffffffc0205424:	4048                	lw	a0,4(s0)
}
ffffffffc0205426:	70a6                	ld	ra,104(sp)
ffffffffc0205428:	7406                	ld	s0,96(sp)
ffffffffc020542a:	64e6                	ld	s1,88(sp)
ffffffffc020542c:	6946                	ld	s2,80(sp)
ffffffffc020542e:	69a6                	ld	s3,72(sp)
ffffffffc0205430:	6a06                	ld	s4,64(sp)
ffffffffc0205432:	7ae2                	ld	s5,56(sp)
ffffffffc0205434:	7b42                	ld	s6,48(sp)
ffffffffc0205436:	7ba2                	ld	s7,40(sp)
ffffffffc0205438:	7c02                	ld	s8,32(sp)
ffffffffc020543a:	6ce2                	ld	s9,24(sp)
ffffffffc020543c:	6d42                	ld	s10,16(sp)
ffffffffc020543e:	6da2                	ld	s11,8(sp)
ffffffffc0205440:	6165                	addi	sp,sp,112
ffffffffc0205442:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205444:	2785                	addiw	a5,a5,1
ffffffffc0205446:	0ec7d563          	bge	a5,a2,ffffffffc0205530 <do_fork+0x32c>
ffffffffc020544a:	4585                	li	a1,1
ffffffffc020544c:	bf35                	j	ffffffffc0205388 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020544e:	8936                	mv	s2,a3
ffffffffc0205450:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205454:	00000797          	auipc	a5,0x0
ffffffffc0205458:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204f76 <forkret>
ffffffffc020545c:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020545e:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205460:	100027f3          	csrr	a5,sstatus
ffffffffc0205464:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205466:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205468:	ec0785e3          	beqz	a5,ffffffffc0205332 <do_fork+0x12e>
        intr_disable();
ffffffffc020546c:	9e8fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205470:	0009c797          	auipc	a5,0x9c
ffffffffc0205474:	f9078793          	addi	a5,a5,-112 # ffffffffc02a1400 <last_pid.1691>
ffffffffc0205478:	439c                	lw	a5,0(a5)
ffffffffc020547a:	6709                	lui	a4,0x2
        return 1;
ffffffffc020547c:	4905                	li	s2,1
ffffffffc020547e:	0017851b          	addiw	a0,a5,1
ffffffffc0205482:	0009c697          	auipc	a3,0x9c
ffffffffc0205486:	f6a6af23          	sw	a0,-130(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020548a:	ece542e3          	blt	a0,a4,ffffffffc020534e <do_fork+0x14a>
        last_pid = 1;
ffffffffc020548e:	4785                	li	a5,1
ffffffffc0205490:	0009c717          	auipc	a4,0x9c
ffffffffc0205494:	f6f72823          	sw	a5,-144(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc0205498:	4505                	li	a0,1
ffffffffc020549a:	b5e9                	j	ffffffffc0205364 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc020549c:	fa7fc0ef          	jal	ra,ffffffffc0202442 <mm_create>
ffffffffc02054a0:	8d2a                	mv	s10,a0
ffffffffc02054a2:	c539                	beqz	a0,ffffffffc02054f0 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc02054a4:	be3ff0ef          	jal	ra,ffffffffc0205086 <setup_pgdir>
ffffffffc02054a8:	e949                	bnez	a0,ffffffffc020553a <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02054aa:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02054ae:	4785                	li	a5,1
ffffffffc02054b0:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc02054b4:	8b85                	andi	a5,a5,1
ffffffffc02054b6:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02054b8:	c799                	beqz	a5,ffffffffc02054c6 <do_fork+0x2c2>
        schedule();
ffffffffc02054ba:	50b000ef          	jal	ra,ffffffffc02061c4 <schedule>
ffffffffc02054be:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc02054c2:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02054c4:	fbfd                	bnez	a5,ffffffffc02054ba <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc02054c6:	85e2                	mv	a1,s8
ffffffffc02054c8:	856a                	mv	a0,s10
ffffffffc02054ca:	a02fd0ef          	jal	ra,ffffffffc02026cc <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02054ce:	57f9                	li	a5,-2
ffffffffc02054d0:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02054d4:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02054d6:	c3e9                	beqz	a5,ffffffffc0205598 <do_fork+0x394>
    if (ret != 0) {
ffffffffc02054d8:	8c6a                	mv	s8,s10
ffffffffc02054da:	de0502e3          	beqz	a0,ffffffffc02052be <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02054de:	856a                	mv	a0,s10
ffffffffc02054e0:	a88fd0ef          	jal	ra,ffffffffc0202768 <exit_mmap>
    put_pgdir(mm);
ffffffffc02054e4:	856a                	mv	a0,s10
ffffffffc02054e6:	b23ff0ef          	jal	ra,ffffffffc0205008 <put_pgdir>
    mm_destroy(mm);
ffffffffc02054ea:	856a                	mv	a0,s10
ffffffffc02054ec:	8dcfd0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02054f0:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02054f2:	c02007b7          	lui	a5,0xc0200
ffffffffc02054f6:	0cf6e963          	bltu	a3,a5,ffffffffc02055c8 <do_fork+0x3c4>
ffffffffc02054fa:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02054fe:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205502:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205506:	83b1                	srli	a5,a5,0xc
ffffffffc0205508:	0ae7f463          	bgeu	a5,a4,ffffffffc02055b0 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc020550c:	000b3703          	ld	a4,0(s6)
ffffffffc0205510:	000ab503          	ld	a0,0(s5)
ffffffffc0205514:	4589                	li	a1,2
ffffffffc0205516:	8f99                	sub	a5,a5,a4
ffffffffc0205518:	079a                	slli	a5,a5,0x6
ffffffffc020551a:	953e                	add	a0,a0,a5
ffffffffc020551c:	9c7fb0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    kfree(proc);
ffffffffc0205520:	8522                	mv	a0,s0
ffffffffc0205522:	e7ffd0ef          	jal	ra,ffffffffc02033a0 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205526:	5571                	li	a0,-4
    return ret;
ffffffffc0205528:	bdfd                	j	ffffffffc0205426 <do_fork+0x222>
        intr_enable();
ffffffffc020552a:	924fb0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc020552e:	bdc5                	j	ffffffffc020541e <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc0205530:	0117c363          	blt	a5,a7,ffffffffc0205536 <do_fork+0x332>
                        last_pid = 1;
ffffffffc0205534:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205536:	4585                	li	a1,1
ffffffffc0205538:	b591                	j	ffffffffc020537c <do_fork+0x178>
    mm_destroy(mm);
ffffffffc020553a:	856a                	mv	a0,s10
ffffffffc020553c:	88cfd0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
ffffffffc0205540:	bf45                	j	ffffffffc02054f0 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205542:	556d                	li	a0,-5
ffffffffc0205544:	b5cd                	j	ffffffffc0205426 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205546:	00002617          	auipc	a2,0x2
ffffffffc020554a:	cda60613          	addi	a2,a2,-806 # ffffffffc0207220 <commands+0x8a8>
ffffffffc020554e:	06900593          	li	a1,105
ffffffffc0205552:	00002517          	auipc	a0,0x2
ffffffffc0205556:	d2650513          	addi	a0,a0,-730 # ffffffffc0207278 <commands+0x900>
ffffffffc020555a:	cbbfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(current->wait_state == 0);
ffffffffc020555e:	00003697          	auipc	a3,0x3
ffffffffc0205562:	2da68693          	addi	a3,a3,730 # ffffffffc0208838 <default_pmm_manager+0x440>
ffffffffc0205566:	00002617          	auipc	a2,0x2
ffffffffc020556a:	89260613          	addi	a2,a2,-1902 # ffffffffc0206df8 <commands+0x480>
ffffffffc020556e:	1af00593          	li	a1,431
ffffffffc0205572:	00003517          	auipc	a0,0x3
ffffffffc0205576:	54e50513          	addi	a0,a0,1358 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc020557a:	c9bfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020557e:	86be                	mv	a3,a5
ffffffffc0205580:	00002617          	auipc	a2,0x2
ffffffffc0205584:	d7860613          	addi	a2,a2,-648 # ffffffffc02072f8 <commands+0x980>
ffffffffc0205588:	16200593          	li	a1,354
ffffffffc020558c:	00003517          	auipc	a0,0x3
ffffffffc0205590:	53450513          	addi	a0,a0,1332 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205594:	c81fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205598:	00003617          	auipc	a2,0x3
ffffffffc020559c:	2c060613          	addi	a2,a2,704 # ffffffffc0208858 <default_pmm_manager+0x460>
ffffffffc02055a0:	03100593          	li	a1,49
ffffffffc02055a4:	00003517          	auipc	a0,0x3
ffffffffc02055a8:	2c450513          	addi	a0,a0,708 # ffffffffc0208868 <default_pmm_manager+0x470>
ffffffffc02055ac:	c69fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02055b0:	00002617          	auipc	a2,0x2
ffffffffc02055b4:	ca860613          	addi	a2,a2,-856 # ffffffffc0207258 <commands+0x8e0>
ffffffffc02055b8:	06200593          	li	a1,98
ffffffffc02055bc:	00002517          	auipc	a0,0x2
ffffffffc02055c0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0207278 <commands+0x900>
ffffffffc02055c4:	c51fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02055c8:	00002617          	auipc	a2,0x2
ffffffffc02055cc:	d3060613          	addi	a2,a2,-720 # ffffffffc02072f8 <commands+0x980>
ffffffffc02055d0:	06e00593          	li	a1,110
ffffffffc02055d4:	00002517          	auipc	a0,0x2
ffffffffc02055d8:	ca450513          	addi	a0,a0,-860 # ffffffffc0207278 <commands+0x900>
ffffffffc02055dc:	c39fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02055e0 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02055e0:	7129                	addi	sp,sp,-320
ffffffffc02055e2:	fa22                	sd	s0,304(sp)
ffffffffc02055e4:	f626                	sd	s1,296(sp)
ffffffffc02055e6:	f24a                	sd	s2,288(sp)
ffffffffc02055e8:	84ae                	mv	s1,a1
ffffffffc02055ea:	892a                	mv	s2,a0
ffffffffc02055ec:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02055ee:	4581                	li	a1,0
ffffffffc02055f0:	12000613          	li	a2,288
ffffffffc02055f4:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02055f6:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02055f8:	5e1000ef          	jal	ra,ffffffffc02063d8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02055fc:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02055fe:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205600:	100027f3          	csrr	a5,sstatus
ffffffffc0205604:	edd7f793          	andi	a5,a5,-291
ffffffffc0205608:	1207e793          	ori	a5,a5,288
ffffffffc020560c:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020560e:	860a                	mv	a2,sp
ffffffffc0205610:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205614:	00000797          	auipc	a5,0x0
ffffffffc0205618:	87c78793          	addi	a5,a5,-1924 # ffffffffc0204e90 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020561c:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020561e:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205620:	be5ff0ef          	jal	ra,ffffffffc0205204 <do_fork>
}
ffffffffc0205624:	70f2                	ld	ra,312(sp)
ffffffffc0205626:	7452                	ld	s0,304(sp)
ffffffffc0205628:	74b2                	ld	s1,296(sp)
ffffffffc020562a:	7912                	ld	s2,288(sp)
ffffffffc020562c:	6131                	addi	sp,sp,320
ffffffffc020562e:	8082                	ret

ffffffffc0205630 <do_exit>:
do_exit(int error_code) {
ffffffffc0205630:	7179                	addi	sp,sp,-48
ffffffffc0205632:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205634:	000a7717          	auipc	a4,0xa7
ffffffffc0205638:	21c70713          	addi	a4,a4,540 # ffffffffc02ac850 <idleproc>
ffffffffc020563c:	000a7917          	auipc	s2,0xa7
ffffffffc0205640:	20c90913          	addi	s2,s2,524 # ffffffffc02ac848 <current>
ffffffffc0205644:	00093783          	ld	a5,0(s2)
ffffffffc0205648:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc020564a:	f406                	sd	ra,40(sp)
ffffffffc020564c:	f022                	sd	s0,32(sp)
ffffffffc020564e:	ec26                	sd	s1,24(sp)
ffffffffc0205650:	e44e                	sd	s3,8(sp)
ffffffffc0205652:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205654:	0ce78c63          	beq	a5,a4,ffffffffc020572c <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205658:	000a7417          	auipc	s0,0xa7
ffffffffc020565c:	20040413          	addi	s0,s0,512 # ffffffffc02ac858 <initproc>
ffffffffc0205660:	6018                	ld	a4,0(s0)
ffffffffc0205662:	0ee78b63          	beq	a5,a4,ffffffffc0205758 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205666:	7784                	ld	s1,40(a5)
ffffffffc0205668:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc020566a:	c48d                	beqz	s1,ffffffffc0205694 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc020566c:	000a7797          	auipc	a5,0xa7
ffffffffc0205670:	21478793          	addi	a5,a5,532 # ffffffffc02ac880 <boot_cr3>
ffffffffc0205674:	639c                	ld	a5,0(a5)
ffffffffc0205676:	577d                	li	a4,-1
ffffffffc0205678:	177e                	slli	a4,a4,0x3f
ffffffffc020567a:	83b1                	srli	a5,a5,0xc
ffffffffc020567c:	8fd9                	or	a5,a5,a4
ffffffffc020567e:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205682:	589c                	lw	a5,48(s1)
ffffffffc0205684:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205688:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc020568a:	cf4d                	beqz	a4,ffffffffc0205744 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020568c:	00093783          	ld	a5,0(s2)
ffffffffc0205690:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205694:	00093783          	ld	a5,0(s2)
ffffffffc0205698:	470d                	li	a4,3
ffffffffc020569a:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020569c:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02056a0:	100027f3          	csrr	a5,sstatus
ffffffffc02056a4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02056a6:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02056a8:	e7e1                	bnez	a5,ffffffffc0205770 <do_exit+0x140>
        proc = current->parent;
ffffffffc02056aa:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02056ae:	800007b7          	lui	a5,0x80000
ffffffffc02056b2:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02056b4:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02056b6:	0ec52703          	lw	a4,236(a0)
ffffffffc02056ba:	0af70f63          	beq	a4,a5,ffffffffc0205778 <do_exit+0x148>
ffffffffc02056be:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02056c2:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056c6:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02056c8:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02056ca:	7afc                	ld	a5,240(a3)
ffffffffc02056cc:	cb95                	beqz	a5,ffffffffc0205700 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02056ce:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5638>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02056d2:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02056d4:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02056d6:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02056d8:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02056dc:	10e7b023          	sd	a4,256(a5)
ffffffffc02056e0:	c311                	beqz	a4,ffffffffc02056e4 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02056e2:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056e4:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02056e6:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02056e8:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056ea:	fe9710e3          	bne	a4,s1,ffffffffc02056ca <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02056ee:	0ec52783          	lw	a5,236(a0)
ffffffffc02056f2:	fd379ce3          	bne	a5,s3,ffffffffc02056ca <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02056f6:	253000ef          	jal	ra,ffffffffc0206148 <wakeup_proc>
ffffffffc02056fa:	00093683          	ld	a3,0(s2)
ffffffffc02056fe:	b7f1                	j	ffffffffc02056ca <do_exit+0x9a>
    if (flag) {
ffffffffc0205700:	020a1363          	bnez	s4,ffffffffc0205726 <do_exit+0xf6>
    schedule();
ffffffffc0205704:	2c1000ef          	jal	ra,ffffffffc02061c4 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205708:	00093783          	ld	a5,0(s2)
ffffffffc020570c:	00003617          	auipc	a2,0x3
ffffffffc0205710:	10c60613          	addi	a2,a2,268 # ffffffffc0208818 <default_pmm_manager+0x420>
ffffffffc0205714:	1ff00593          	li	a1,511
ffffffffc0205718:	43d4                	lw	a3,4(a5)
ffffffffc020571a:	00003517          	auipc	a0,0x3
ffffffffc020571e:	3a650513          	addi	a0,a0,934 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205722:	af3fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_enable();
ffffffffc0205726:	f29fa0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc020572a:	bfe9                	j	ffffffffc0205704 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc020572c:	00003617          	auipc	a2,0x3
ffffffffc0205730:	0cc60613          	addi	a2,a2,204 # ffffffffc02087f8 <default_pmm_manager+0x400>
ffffffffc0205734:	1d300593          	li	a1,467
ffffffffc0205738:	00003517          	auipc	a0,0x3
ffffffffc020573c:	38850513          	addi	a0,a0,904 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205740:	ad5fa0ef          	jal	ra,ffffffffc0200214 <__panic>
            exit_mmap(mm);
ffffffffc0205744:	8526                	mv	a0,s1
ffffffffc0205746:	822fd0ef          	jal	ra,ffffffffc0202768 <exit_mmap>
            put_pgdir(mm);
ffffffffc020574a:	8526                	mv	a0,s1
ffffffffc020574c:	8bdff0ef          	jal	ra,ffffffffc0205008 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205750:	8526                	mv	a0,s1
ffffffffc0205752:	e77fc0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
ffffffffc0205756:	bf1d                	j	ffffffffc020568c <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205758:	00003617          	auipc	a2,0x3
ffffffffc020575c:	0b060613          	addi	a2,a2,176 # ffffffffc0208808 <default_pmm_manager+0x410>
ffffffffc0205760:	1d600593          	li	a1,470
ffffffffc0205764:	00003517          	auipc	a0,0x3
ffffffffc0205768:	35c50513          	addi	a0,a0,860 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc020576c:	aa9fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_disable();
ffffffffc0205770:	ee5fa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0205774:	4a05                	li	s4,1
ffffffffc0205776:	bf15                	j	ffffffffc02056aa <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205778:	1d1000ef          	jal	ra,ffffffffc0206148 <wakeup_proc>
ffffffffc020577c:	b789                	j	ffffffffc02056be <do_exit+0x8e>

ffffffffc020577e <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc020577e:	7139                	addi	sp,sp,-64
ffffffffc0205780:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205782:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205786:	f426                	sd	s1,40(sp)
ffffffffc0205788:	f04a                	sd	s2,32(sp)
ffffffffc020578a:	ec4e                	sd	s3,24(sp)
ffffffffc020578c:	e456                	sd	s5,8(sp)
ffffffffc020578e:	e05a                	sd	s6,0(sp)
ffffffffc0205790:	fc06                	sd	ra,56(sp)
ffffffffc0205792:	f822                	sd	s0,48(sp)
ffffffffc0205794:	89aa                	mv	s3,a0
ffffffffc0205796:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205798:	000a7917          	auipc	s2,0xa7
ffffffffc020579c:	0b090913          	addi	s2,s2,176 # ffffffffc02ac848 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02057a0:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02057a2:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02057a4:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc02057a6:	02098f63          	beqz	s3,ffffffffc02057e4 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02057aa:	854e                	mv	a0,s3
ffffffffc02057ac:	9fdff0ef          	jal	ra,ffffffffc02051a8 <find_proc>
ffffffffc02057b0:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02057b2:	12050063          	beqz	a0,ffffffffc02058d2 <do_wait.part.1+0x154>
ffffffffc02057b6:	00093703          	ld	a4,0(s2)
ffffffffc02057ba:	711c                	ld	a5,32(a0)
ffffffffc02057bc:	10e79b63          	bne	a5,a4,ffffffffc02058d2 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02057c0:	411c                	lw	a5,0(a0)
ffffffffc02057c2:	02978c63          	beq	a5,s1,ffffffffc02057fa <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02057c6:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02057ca:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02057ce:	1f7000ef          	jal	ra,ffffffffc02061c4 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02057d2:	00093783          	ld	a5,0(s2)
ffffffffc02057d6:	0b07a783          	lw	a5,176(a5)
ffffffffc02057da:	8b85                	andi	a5,a5,1
ffffffffc02057dc:	d7e9                	beqz	a5,ffffffffc02057a6 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02057de:	555d                	li	a0,-9
ffffffffc02057e0:	e51ff0ef          	jal	ra,ffffffffc0205630 <do_exit>
        proc = current->cptr;
ffffffffc02057e4:	00093703          	ld	a4,0(s2)
ffffffffc02057e8:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02057ea:	e409                	bnez	s0,ffffffffc02057f4 <do_wait.part.1+0x76>
ffffffffc02057ec:	a0dd                	j	ffffffffc02058d2 <do_wait.part.1+0x154>
ffffffffc02057ee:	10043403          	ld	s0,256(s0)
ffffffffc02057f2:	d871                	beqz	s0,ffffffffc02057c6 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02057f4:	401c                	lw	a5,0(s0)
ffffffffc02057f6:	fe979ce3          	bne	a5,s1,ffffffffc02057ee <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02057fa:	000a7797          	auipc	a5,0xa7
ffffffffc02057fe:	05678793          	addi	a5,a5,86 # ffffffffc02ac850 <idleproc>
ffffffffc0205802:	639c                	ld	a5,0(a5)
ffffffffc0205804:	0c878d63          	beq	a5,s0,ffffffffc02058de <do_wait.part.1+0x160>
ffffffffc0205808:	000a7797          	auipc	a5,0xa7
ffffffffc020580c:	05078793          	addi	a5,a5,80 # ffffffffc02ac858 <initproc>
ffffffffc0205810:	639c                	ld	a5,0(a5)
ffffffffc0205812:	0cf40663          	beq	s0,a5,ffffffffc02058de <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205816:	000b0663          	beqz	s6,ffffffffc0205822 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc020581a:	0e842783          	lw	a5,232(s0)
ffffffffc020581e:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205822:	100027f3          	csrr	a5,sstatus
ffffffffc0205826:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205828:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020582a:	e7d5                	bnez	a5,ffffffffc02058d6 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc020582c:	6c70                	ld	a2,216(s0)
ffffffffc020582e:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205830:	10043703          	ld	a4,256(s0)
ffffffffc0205834:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205836:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205838:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020583a:	6470                	ld	a2,200(s0)
ffffffffc020583c:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020583e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205840:	e290                	sd	a2,0(a3)
ffffffffc0205842:	c319                	beqz	a4,ffffffffc0205848 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205844:	ff7c                	sd	a5,248(a4)
ffffffffc0205846:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205848:	c3d1                	beqz	a5,ffffffffc02058cc <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc020584a:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020584e:	000a7797          	auipc	a5,0xa7
ffffffffc0205852:	01278793          	addi	a5,a5,18 # ffffffffc02ac860 <nr_process>
ffffffffc0205856:	439c                	lw	a5,0(a5)
ffffffffc0205858:	37fd                	addiw	a5,a5,-1
ffffffffc020585a:	000a7717          	auipc	a4,0xa7
ffffffffc020585e:	00f72323          	sw	a5,6(a4) # ffffffffc02ac860 <nr_process>
    if (flag) {
ffffffffc0205862:	e1b5                	bnez	a1,ffffffffc02058c6 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205864:	6814                	ld	a3,16(s0)
ffffffffc0205866:	c02007b7          	lui	a5,0xc0200
ffffffffc020586a:	0af6e263          	bltu	a3,a5,ffffffffc020590e <do_wait.part.1+0x190>
ffffffffc020586e:	000a7797          	auipc	a5,0xa7
ffffffffc0205872:	00a78793          	addi	a5,a5,10 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205876:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205878:	000a7797          	auipc	a5,0xa7
ffffffffc020587c:	fa878793          	addi	a5,a5,-88 # ffffffffc02ac820 <npage>
ffffffffc0205880:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205882:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205884:	82b1                	srli	a3,a3,0xc
ffffffffc0205886:	06f6f863          	bgeu	a3,a5,ffffffffc02058f6 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020588a:	00003797          	auipc	a5,0x3
ffffffffc020588e:	6fe78793          	addi	a5,a5,1790 # ffffffffc0208f88 <nbase>
ffffffffc0205892:	639c                	ld	a5,0(a5)
ffffffffc0205894:	000a7717          	auipc	a4,0xa7
ffffffffc0205898:	ff470713          	addi	a4,a4,-12 # ffffffffc02ac888 <pages>
ffffffffc020589c:	6308                	ld	a0,0(a4)
ffffffffc020589e:	8e9d                	sub	a3,a3,a5
ffffffffc02058a0:	069a                	slli	a3,a3,0x6
ffffffffc02058a2:	9536                	add	a0,a0,a3
ffffffffc02058a4:	4589                	li	a1,2
ffffffffc02058a6:	e3cfb0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    kfree(proc);
ffffffffc02058aa:	8522                	mv	a0,s0
ffffffffc02058ac:	af5fd0ef          	jal	ra,ffffffffc02033a0 <kfree>
    return 0;
ffffffffc02058b0:	4501                	li	a0,0
}
ffffffffc02058b2:	70e2                	ld	ra,56(sp)
ffffffffc02058b4:	7442                	ld	s0,48(sp)
ffffffffc02058b6:	74a2                	ld	s1,40(sp)
ffffffffc02058b8:	7902                	ld	s2,32(sp)
ffffffffc02058ba:	69e2                	ld	s3,24(sp)
ffffffffc02058bc:	6a42                	ld	s4,16(sp)
ffffffffc02058be:	6aa2                	ld	s5,8(sp)
ffffffffc02058c0:	6b02                	ld	s6,0(sp)
ffffffffc02058c2:	6121                	addi	sp,sp,64
ffffffffc02058c4:	8082                	ret
        intr_enable();
ffffffffc02058c6:	d89fa0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc02058ca:	bf69                	j	ffffffffc0205864 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02058cc:	701c                	ld	a5,32(s0)
ffffffffc02058ce:	fbf8                	sd	a4,240(a5)
ffffffffc02058d0:	bfbd                	j	ffffffffc020584e <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02058d2:	5579                	li	a0,-2
ffffffffc02058d4:	bff9                	j	ffffffffc02058b2 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02058d6:	d7ffa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc02058da:	4585                	li	a1,1
ffffffffc02058dc:	bf81                	j	ffffffffc020582c <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02058de:	00003617          	auipc	a2,0x3
ffffffffc02058e2:	fa260613          	addi	a2,a2,-94 # ffffffffc0208880 <default_pmm_manager+0x488>
ffffffffc02058e6:	2f600593          	li	a1,758
ffffffffc02058ea:	00003517          	auipc	a0,0x3
ffffffffc02058ee:	1d650513          	addi	a0,a0,470 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc02058f2:	923fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02058f6:	00002617          	auipc	a2,0x2
ffffffffc02058fa:	96260613          	addi	a2,a2,-1694 # ffffffffc0207258 <commands+0x8e0>
ffffffffc02058fe:	06200593          	li	a1,98
ffffffffc0205902:	00002517          	auipc	a0,0x2
ffffffffc0205906:	97650513          	addi	a0,a0,-1674 # ffffffffc0207278 <commands+0x900>
ffffffffc020590a:	90bfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020590e:	00002617          	auipc	a2,0x2
ffffffffc0205912:	9ea60613          	addi	a2,a2,-1558 # ffffffffc02072f8 <commands+0x980>
ffffffffc0205916:	06e00593          	li	a1,110
ffffffffc020591a:	00002517          	auipc	a0,0x2
ffffffffc020591e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0207278 <commands+0x900>
ffffffffc0205922:	8f3fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205926 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205926:	1141                	addi	sp,sp,-16
ffffffffc0205928:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020592a:	dfefb0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020592e:	9b3fd0ef          	jal	ra,ffffffffc02032e0 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205932:	4601                	li	a2,0
ffffffffc0205934:	4581                	li	a1,0
ffffffffc0205936:	fffff517          	auipc	a0,0xfffff
ffffffffc020593a:	65050513          	addi	a0,a0,1616 # ffffffffc0204f86 <user_main>
ffffffffc020593e:	ca3ff0ef          	jal	ra,ffffffffc02055e0 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205942:	00a04563          	bgtz	a0,ffffffffc020594c <init_main+0x26>
ffffffffc0205946:	a841                	j	ffffffffc02059d6 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205948:	07d000ef          	jal	ra,ffffffffc02061c4 <schedule>
    if (code_store != NULL) {
ffffffffc020594c:	4581                	li	a1,0
ffffffffc020594e:	4501                	li	a0,0
ffffffffc0205950:	e2fff0ef          	jal	ra,ffffffffc020577e <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205954:	d975                	beqz	a0,ffffffffc0205948 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205956:	00003517          	auipc	a0,0x3
ffffffffc020595a:	f6a50513          	addi	a0,a0,-150 # ffffffffc02088c0 <default_pmm_manager+0x4c8>
ffffffffc020595e:	f72fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205962:	000a7797          	auipc	a5,0xa7
ffffffffc0205966:	ef678793          	addi	a5,a5,-266 # ffffffffc02ac858 <initproc>
ffffffffc020596a:	639c                	ld	a5,0(a5)
ffffffffc020596c:	7bf8                	ld	a4,240(a5)
ffffffffc020596e:	e721                	bnez	a4,ffffffffc02059b6 <init_main+0x90>
ffffffffc0205970:	7ff8                	ld	a4,248(a5)
ffffffffc0205972:	e331                	bnez	a4,ffffffffc02059b6 <init_main+0x90>
ffffffffc0205974:	1007b703          	ld	a4,256(a5)
ffffffffc0205978:	ef1d                	bnez	a4,ffffffffc02059b6 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020597a:	000a7717          	auipc	a4,0xa7
ffffffffc020597e:	ee670713          	addi	a4,a4,-282 # ffffffffc02ac860 <nr_process>
ffffffffc0205982:	4314                	lw	a3,0(a4)
ffffffffc0205984:	4709                	li	a4,2
ffffffffc0205986:	0ae69463          	bne	a3,a4,ffffffffc0205a2e <init_main+0x108>
    return listelm->next;
ffffffffc020598a:	000a7697          	auipc	a3,0xa7
ffffffffc020598e:	ffe68693          	addi	a3,a3,-2 # ffffffffc02ac988 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205992:	6698                	ld	a4,8(a3)
ffffffffc0205994:	0c878793          	addi	a5,a5,200
ffffffffc0205998:	06f71b63          	bne	a4,a5,ffffffffc0205a0e <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020599c:	629c                	ld	a5,0(a3)
ffffffffc020599e:	04f71863          	bne	a4,a5,ffffffffc02059ee <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02059a2:	00003517          	auipc	a0,0x3
ffffffffc02059a6:	00650513          	addi	a0,a0,6 # ffffffffc02089a8 <default_pmm_manager+0x5b0>
ffffffffc02059aa:	f26fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02059ae:	60a2                	ld	ra,8(sp)
ffffffffc02059b0:	4501                	li	a0,0
ffffffffc02059b2:	0141                	addi	sp,sp,16
ffffffffc02059b4:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02059b6:	00003697          	auipc	a3,0x3
ffffffffc02059ba:	f3268693          	addi	a3,a3,-206 # ffffffffc02088e8 <default_pmm_manager+0x4f0>
ffffffffc02059be:	00001617          	auipc	a2,0x1
ffffffffc02059c2:	43a60613          	addi	a2,a2,1082 # ffffffffc0206df8 <commands+0x480>
ffffffffc02059c6:	35b00593          	li	a1,859
ffffffffc02059ca:	00003517          	auipc	a0,0x3
ffffffffc02059ce:	0f650513          	addi	a0,a0,246 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc02059d2:	843fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create user_main failed.\n");
ffffffffc02059d6:	00003617          	auipc	a2,0x3
ffffffffc02059da:	eca60613          	addi	a2,a2,-310 # ffffffffc02088a0 <default_pmm_manager+0x4a8>
ffffffffc02059de:	35300593          	li	a1,851
ffffffffc02059e2:	00003517          	auipc	a0,0x3
ffffffffc02059e6:	0de50513          	addi	a0,a0,222 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc02059ea:	82bfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02059ee:	00003697          	auipc	a3,0x3
ffffffffc02059f2:	f8a68693          	addi	a3,a3,-118 # ffffffffc0208978 <default_pmm_manager+0x580>
ffffffffc02059f6:	00001617          	auipc	a2,0x1
ffffffffc02059fa:	40260613          	addi	a2,a2,1026 # ffffffffc0206df8 <commands+0x480>
ffffffffc02059fe:	35e00593          	li	a1,862
ffffffffc0205a02:	00003517          	auipc	a0,0x3
ffffffffc0205a06:	0be50513          	addi	a0,a0,190 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205a0a:	80bfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205a0e:	00003697          	auipc	a3,0x3
ffffffffc0205a12:	f3a68693          	addi	a3,a3,-198 # ffffffffc0208948 <default_pmm_manager+0x550>
ffffffffc0205a16:	00001617          	auipc	a2,0x1
ffffffffc0205a1a:	3e260613          	addi	a2,a2,994 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205a1e:	35d00593          	li	a1,861
ffffffffc0205a22:	00003517          	auipc	a0,0x3
ffffffffc0205a26:	09e50513          	addi	a0,a0,158 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205a2a:	feafa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_process == 2);
ffffffffc0205a2e:	00003697          	auipc	a3,0x3
ffffffffc0205a32:	f0a68693          	addi	a3,a3,-246 # ffffffffc0208938 <default_pmm_manager+0x540>
ffffffffc0205a36:	00001617          	auipc	a2,0x1
ffffffffc0205a3a:	3c260613          	addi	a2,a2,962 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205a3e:	35c00593          	li	a1,860
ffffffffc0205a42:	00003517          	auipc	a0,0x3
ffffffffc0205a46:	07e50513          	addi	a0,a0,126 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205a4a:	fcafa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205a4e <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205a4e:	7135                	addi	sp,sp,-160
ffffffffc0205a50:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205a52:	000a7a17          	auipc	s4,0xa7
ffffffffc0205a56:	df6a0a13          	addi	s4,s4,-522 # ffffffffc02ac848 <current>
ffffffffc0205a5a:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205a5e:	e14a                	sd	s2,128(sp)
ffffffffc0205a60:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205a62:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205a66:	fcce                	sd	s3,120(sp)
ffffffffc0205a68:	f0da                	sd	s6,96(sp)
ffffffffc0205a6a:	89aa                	mv	s3,a0
ffffffffc0205a6c:	842e                	mv	s0,a1
ffffffffc0205a6e:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205a70:	4681                	li	a3,0
ffffffffc0205a72:	862e                	mv	a2,a1
ffffffffc0205a74:	85aa                	mv	a1,a0
ffffffffc0205a76:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205a78:	ed06                	sd	ra,152(sp)
ffffffffc0205a7a:	e526                	sd	s1,136(sp)
ffffffffc0205a7c:	f4d6                	sd	s5,104(sp)
ffffffffc0205a7e:	ecde                	sd	s7,88(sp)
ffffffffc0205a80:	e8e2                	sd	s8,80(sp)
ffffffffc0205a82:	e4e6                	sd	s9,72(sp)
ffffffffc0205a84:	e0ea                	sd	s10,64(sp)
ffffffffc0205a86:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205a88:	d28fd0ef          	jal	ra,ffffffffc0202fb0 <user_mem_check>
ffffffffc0205a8c:	40050263          	beqz	a0,ffffffffc0205e90 <do_execve+0x442>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205a90:	4641                	li	a2,16
ffffffffc0205a92:	4581                	li	a1,0
ffffffffc0205a94:	1008                	addi	a0,sp,32
ffffffffc0205a96:	143000ef          	jal	ra,ffffffffc02063d8 <memset>
    memcpy(local_name, name, len);
ffffffffc0205a9a:	47bd                	li	a5,15
ffffffffc0205a9c:	8622                	mv	a2,s0
ffffffffc0205a9e:	0687ee63          	bltu	a5,s0,ffffffffc0205b1a <do_execve+0xcc>
ffffffffc0205aa2:	85ce                	mv	a1,s3
ffffffffc0205aa4:	1008                	addi	a0,sp,32
ffffffffc0205aa6:	145000ef          	jal	ra,ffffffffc02063ea <memcpy>
    if (mm != NULL) {
ffffffffc0205aaa:	06090f63          	beqz	s2,ffffffffc0205b28 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205aae:	00002517          	auipc	a0,0x2
ffffffffc0205ab2:	faa50513          	addi	a0,a0,-86 # ffffffffc0207a58 <commands+0x10e0>
ffffffffc0205ab6:	e50fa0ef          	jal	ra,ffffffffc0200106 <cputs>
        lcr3(boot_cr3);
ffffffffc0205aba:	000a7797          	auipc	a5,0xa7
ffffffffc0205abe:	dc678793          	addi	a5,a5,-570 # ffffffffc02ac880 <boot_cr3>
ffffffffc0205ac2:	639c                	ld	a5,0(a5)
ffffffffc0205ac4:	577d                	li	a4,-1
ffffffffc0205ac6:	177e                	slli	a4,a4,0x3f
ffffffffc0205ac8:	83b1                	srli	a5,a5,0xc
ffffffffc0205aca:	8fd9                	or	a5,a5,a4
ffffffffc0205acc:	18079073          	csrw	satp,a5
ffffffffc0205ad0:	03092783          	lw	a5,48(s2)
ffffffffc0205ad4:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205ad8:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205adc:	28070c63          	beqz	a4,ffffffffc0205d74 <do_execve+0x326>
        current->mm = NULL;
ffffffffc0205ae0:	000a3783          	ld	a5,0(s4)
ffffffffc0205ae4:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205ae8:	95bfc0ef          	jal	ra,ffffffffc0202442 <mm_create>
ffffffffc0205aec:	892a                	mv	s2,a0
ffffffffc0205aee:	c135                	beqz	a0,ffffffffc0205b52 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205af0:	d96ff0ef          	jal	ra,ffffffffc0205086 <setup_pgdir>
ffffffffc0205af4:	e931                	bnez	a0,ffffffffc0205b48 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205af6:	000b2703          	lw	a4,0(s6)
ffffffffc0205afa:	464c47b7          	lui	a5,0x464c4
ffffffffc0205afe:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9ab7>
ffffffffc0205b02:	04f70a63          	beq	a4,a5,ffffffffc0205b56 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205b06:	854a                	mv	a0,s2
ffffffffc0205b08:	d00ff0ef          	jal	ra,ffffffffc0205008 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b0c:	854a                	mv	a0,s2
ffffffffc0205b0e:	abbfc0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205b12:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205b14:	854e                	mv	a0,s3
ffffffffc0205b16:	b1bff0ef          	jal	ra,ffffffffc0205630 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205b1a:	463d                	li	a2,15
ffffffffc0205b1c:	85ce                	mv	a1,s3
ffffffffc0205b1e:	1008                	addi	a0,sp,32
ffffffffc0205b20:	0cb000ef          	jal	ra,ffffffffc02063ea <memcpy>
    if (mm != NULL) {
ffffffffc0205b24:	f80915e3          	bnez	s2,ffffffffc0205aae <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205b28:	000a3783          	ld	a5,0(s4)
ffffffffc0205b2c:	779c                	ld	a5,40(a5)
ffffffffc0205b2e:	dfcd                	beqz	a5,ffffffffc0205ae8 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205b30:	00003617          	auipc	a2,0x3
ffffffffc0205b34:	b4060613          	addi	a2,a2,-1216 # ffffffffc0208670 <default_pmm_manager+0x278>
ffffffffc0205b38:	20900593          	li	a1,521
ffffffffc0205b3c:	00003517          	auipc	a0,0x3
ffffffffc0205b40:	f8450513          	addi	a0,a0,-124 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205b44:	ed0fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    mm_destroy(mm);
ffffffffc0205b48:	854a                	mv	a0,s2
ffffffffc0205b4a:	a7ffc0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205b4e:	59f1                	li	s3,-4
ffffffffc0205b50:	b7d1                	j	ffffffffc0205b14 <do_execve+0xc6>
ffffffffc0205b52:	59f1                	li	s3,-4
ffffffffc0205b54:	b7c1                	j	ffffffffc0205b14 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205b56:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205b5a:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205b5e:	00371793          	slli	a5,a4,0x3
ffffffffc0205b62:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205b64:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205b66:	078e                	slli	a5,a5,0x3
ffffffffc0205b68:	97a2                	add	a5,a5,s0
ffffffffc0205b6a:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205b6c:	02f47b63          	bgeu	s0,a5,ffffffffc0205ba2 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205b70:	5bfd                	li	s7,-1
ffffffffc0205b72:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205b76:	000a7d97          	auipc	s11,0xa7
ffffffffc0205b7a:	d12d8d93          	addi	s11,s11,-750 # ffffffffc02ac888 <pages>
ffffffffc0205b7e:	00003d17          	auipc	s10,0x3
ffffffffc0205b82:	40ad0d13          	addi	s10,s10,1034 # ffffffffc0208f88 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205b86:	e43e                	sd	a5,8(sp)
ffffffffc0205b88:	000a7c97          	auipc	s9,0xa7
ffffffffc0205b8c:	c98c8c93          	addi	s9,s9,-872 # ffffffffc02ac820 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205b90:	4018                	lw	a4,0(s0)
ffffffffc0205b92:	4785                	li	a5,1
ffffffffc0205b94:	0ef70d63          	beq	a4,a5,ffffffffc0205c8e <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205b98:	67e2                	ld	a5,24(sp)
ffffffffc0205b9a:	03840413          	addi	s0,s0,56
ffffffffc0205b9e:	fef469e3          	bltu	s0,a5,ffffffffc0205b90 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205ba2:	4701                	li	a4,0
ffffffffc0205ba4:	46ad                	li	a3,11
ffffffffc0205ba6:	00100637          	lui	a2,0x100
ffffffffc0205baa:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205bae:	854a                	mv	a0,s2
ffffffffc0205bb0:	a6bfc0ef          	jal	ra,ffffffffc020261a <mm_map>
ffffffffc0205bb4:	89aa                	mv	s3,a0
ffffffffc0205bb6:	1a051563          	bnez	a0,ffffffffc0205d60 <do_execve+0x312>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205bba:	01893503          	ld	a0,24(s2)
ffffffffc0205bbe:	467d                	li	a2,31
ffffffffc0205bc0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205bc4:	faafc0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
ffffffffc0205bc8:	36050063          	beqz	a0,ffffffffc0205f28 <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bcc:	01893503          	ld	a0,24(s2)
ffffffffc0205bd0:	467d                	li	a2,31
ffffffffc0205bd2:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205bd6:	f98fc0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
ffffffffc0205bda:	32050763          	beqz	a0,ffffffffc0205f08 <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bde:	01893503          	ld	a0,24(s2)
ffffffffc0205be2:	467d                	li	a2,31
ffffffffc0205be4:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205be8:	f86fc0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
ffffffffc0205bec:	2e050e63          	beqz	a0,ffffffffc0205ee8 <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bf0:	01893503          	ld	a0,24(s2)
ffffffffc0205bf4:	467d                	li	a2,31
ffffffffc0205bf6:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205bfa:	f74fc0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
ffffffffc0205bfe:	2c050563          	beqz	a0,ffffffffc0205ec8 <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc0205c02:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205c06:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c0a:	01893683          	ld	a3,24(s2)
ffffffffc0205c0e:	2785                	addiw	a5,a5,1
ffffffffc0205c10:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205c14:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5560>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c18:	c02007b7          	lui	a5,0xc0200
ffffffffc0205c1c:	28f6ea63          	bltu	a3,a5,ffffffffc0205eb0 <do_execve+0x462>
ffffffffc0205c20:	000a7797          	auipc	a5,0xa7
ffffffffc0205c24:	c5878793          	addi	a5,a5,-936 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205c28:	639c                	ld	a5,0(a5)
ffffffffc0205c2a:	577d                	li	a4,-1
ffffffffc0205c2c:	177e                	slli	a4,a4,0x3f
ffffffffc0205c2e:	8e9d                	sub	a3,a3,a5
ffffffffc0205c30:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205c34:	f654                	sd	a3,168(a2)
ffffffffc0205c36:	8fd9                	or	a5,a5,a4
ffffffffc0205c38:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205c3c:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205c3e:	4581                	li	a1,0
ffffffffc0205c40:	12000613          	li	a2,288
ffffffffc0205c44:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205c46:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205c4a:	78e000ef          	jal	ra,ffffffffc02063d8 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205c4e:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp=USTACKTOP;
ffffffffc0205c52:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205c54:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205c58:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp=USTACKTOP;
ffffffffc0205c5c:	07fe                	slli	a5,a5,0x1f
ffffffffc0205c5e:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205c60:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205c64:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205c68:	100c                	addi	a1,sp,32
ffffffffc0205c6a:	ca8ff0ef          	jal	ra,ffffffffc0205112 <set_proc_name>
}
ffffffffc0205c6e:	60ea                	ld	ra,152(sp)
ffffffffc0205c70:	644a                	ld	s0,144(sp)
ffffffffc0205c72:	854e                	mv	a0,s3
ffffffffc0205c74:	64aa                	ld	s1,136(sp)
ffffffffc0205c76:	690a                	ld	s2,128(sp)
ffffffffc0205c78:	79e6                	ld	s3,120(sp)
ffffffffc0205c7a:	7a46                	ld	s4,112(sp)
ffffffffc0205c7c:	7aa6                	ld	s5,104(sp)
ffffffffc0205c7e:	7b06                	ld	s6,96(sp)
ffffffffc0205c80:	6be6                	ld	s7,88(sp)
ffffffffc0205c82:	6c46                	ld	s8,80(sp)
ffffffffc0205c84:	6ca6                	ld	s9,72(sp)
ffffffffc0205c86:	6d06                	ld	s10,64(sp)
ffffffffc0205c88:	7de2                	ld	s11,56(sp)
ffffffffc0205c8a:	610d                	addi	sp,sp,160
ffffffffc0205c8c:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205c8e:	7410                	ld	a2,40(s0)
ffffffffc0205c90:	701c                	ld	a5,32(s0)
ffffffffc0205c92:	20f66163          	bltu	a2,a5,ffffffffc0205e94 <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c96:	405c                	lw	a5,4(s0)
ffffffffc0205c98:	0017f693          	andi	a3,a5,1
ffffffffc0205c9c:	c291                	beqz	a3,ffffffffc0205ca0 <do_execve+0x252>
ffffffffc0205c9e:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ca0:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ca4:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ca6:	0e071163          	bnez	a4,ffffffffc0205d88 <do_execve+0x33a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205caa:	4745                	li	a4,17
ffffffffc0205cac:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205cae:	c789                	beqz	a5,ffffffffc0205cb8 <do_execve+0x26a>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205cb0:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205cb2:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205cb6:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205cb8:	0026f793          	andi	a5,a3,2
ffffffffc0205cbc:	ebe9                	bnez	a5,ffffffffc0205d8e <do_execve+0x340>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205cbe:	0046f793          	andi	a5,a3,4
ffffffffc0205cc2:	c789                	beqz	a5,ffffffffc0205ccc <do_execve+0x27e>
ffffffffc0205cc4:	6782                	ld	a5,0(sp)
ffffffffc0205cc6:	0087e793          	ori	a5,a5,8
ffffffffc0205cca:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205ccc:	680c                	ld	a1,16(s0)
ffffffffc0205cce:	4701                	li	a4,0
ffffffffc0205cd0:	854a                	mv	a0,s2
ffffffffc0205cd2:	949fc0ef          	jal	ra,ffffffffc020261a <mm_map>
ffffffffc0205cd6:	89aa                	mv	s3,a0
ffffffffc0205cd8:	e541                	bnez	a0,ffffffffc0205d60 <do_execve+0x312>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205cda:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205cde:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ce2:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ce6:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ce8:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205cea:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205cec:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205cf0:	053bef63          	bltu	s7,s3,ffffffffc0205d4e <do_execve+0x300>
ffffffffc0205cf4:	aa61                	j	ffffffffc0205e8c <do_execve+0x43e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205cf6:	6785                	lui	a5,0x1
ffffffffc0205cf8:	418b8533          	sub	a0,s7,s8
ffffffffc0205cfc:	9c3e                	add	s8,s8,a5
ffffffffc0205cfe:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205d02:	0189f463          	bgeu	s3,s8,ffffffffc0205d0a <do_execve+0x2bc>
                size -= la - end;
ffffffffc0205d06:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205d0a:	000db683          	ld	a3,0(s11)
ffffffffc0205d0e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205d12:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205d14:	40d486b3          	sub	a3,s1,a3
ffffffffc0205d18:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205d1a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205d1e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205d20:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d24:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d26:	16c5f963          	bgeu	a1,a2,ffffffffc0205e98 <do_execve+0x44a>
ffffffffc0205d2a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d2e:	b4e78793          	addi	a5,a5,-1202 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205d32:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205d36:	85d6                	mv	a1,s5
ffffffffc0205d38:	8642                	mv	a2,a6
ffffffffc0205d3a:	96c6                	add	a3,a3,a7
ffffffffc0205d3c:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205d3e:	9bc2                	add	s7,s7,a6
ffffffffc0205d40:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205d42:	6a8000ef          	jal	ra,ffffffffc02063ea <memcpy>
            start += size, from += size;
ffffffffc0205d46:	6842                	ld	a6,16(sp)
ffffffffc0205d48:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205d4a:	053bf563          	bgeu	s7,s3,ffffffffc0205d94 <do_execve+0x346>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205d4e:	01893503          	ld	a0,24(s2)
ffffffffc0205d52:	6602                	ld	a2,0(sp)
ffffffffc0205d54:	85e2                	mv	a1,s8
ffffffffc0205d56:	e18fc0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
ffffffffc0205d5a:	84aa                	mv	s1,a0
ffffffffc0205d5c:	fd49                	bnez	a0,ffffffffc0205cf6 <do_execve+0x2a8>
        ret = -E_NO_MEM;
ffffffffc0205d5e:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205d60:	854a                	mv	a0,s2
ffffffffc0205d62:	a07fc0ef          	jal	ra,ffffffffc0202768 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205d66:	854a                	mv	a0,s2
ffffffffc0205d68:	aa0ff0ef          	jal	ra,ffffffffc0205008 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205d6c:	854a                	mv	a0,s2
ffffffffc0205d6e:	85bfc0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
    return ret;
ffffffffc0205d72:	b34d                	j	ffffffffc0205b14 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205d74:	854a                	mv	a0,s2
ffffffffc0205d76:	9f3fc0ef          	jal	ra,ffffffffc0202768 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205d7a:	854a                	mv	a0,s2
ffffffffc0205d7c:	a8cff0ef          	jal	ra,ffffffffc0205008 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205d80:	854a                	mv	a0,s2
ffffffffc0205d82:	847fc0ef          	jal	ra,ffffffffc02025c8 <mm_destroy>
ffffffffc0205d86:	bba9                	j	ffffffffc0205ae0 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205d88:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d8c:	f395                	bnez	a5,ffffffffc0205cb0 <do_execve+0x262>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205d8e:	47dd                	li	a5,23
ffffffffc0205d90:	e03e                	sd	a5,0(sp)
ffffffffc0205d92:	b735                	j	ffffffffc0205cbe <do_execve+0x270>
ffffffffc0205d94:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205d98:	7414                	ld	a3,40(s0)
ffffffffc0205d9a:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205d9c:	098bf163          	bgeu	s7,s8,ffffffffc0205e1e <do_execve+0x3d0>
            if (start == end) {
ffffffffc0205da0:	df798ce3          	beq	s3,s7,ffffffffc0205b98 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205da4:	6505                	lui	a0,0x1
ffffffffc0205da6:	955e                	add	a0,a0,s7
ffffffffc0205da8:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205dac:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205db0:	0d89fb63          	bgeu	s3,s8,ffffffffc0205e86 <do_execve+0x438>
    return page - pages + nbase;
ffffffffc0205db4:	000db683          	ld	a3,0(s11)
ffffffffc0205db8:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205dbc:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205dbe:	40d486b3          	sub	a3,s1,a3
ffffffffc0205dc2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205dc4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205dc8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205dca:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205dce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205dd0:	0cc5f463          	bgeu	a1,a2,ffffffffc0205e98 <do_execve+0x44a>
ffffffffc0205dd4:	000a7617          	auipc	a2,0xa7
ffffffffc0205dd8:	aa460613          	addi	a2,a2,-1372 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205ddc:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205de0:	4581                	li	a1,0
ffffffffc0205de2:	8656                	mv	a2,s5
ffffffffc0205de4:	96c2                	add	a3,a3,a6
ffffffffc0205de6:	9536                	add	a0,a0,a3
ffffffffc0205de8:	5f0000ef          	jal	ra,ffffffffc02063d8 <memset>
            start += size;
ffffffffc0205dec:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205df0:	0389f463          	bgeu	s3,s8,ffffffffc0205e18 <do_execve+0x3ca>
ffffffffc0205df4:	dae982e3          	beq	s3,a4,ffffffffc0205b98 <do_execve+0x14a>
ffffffffc0205df8:	00003697          	auipc	a3,0x3
ffffffffc0205dfc:	8a068693          	addi	a3,a3,-1888 # ffffffffc0208698 <default_pmm_manager+0x2a0>
ffffffffc0205e00:	00001617          	auipc	a2,0x1
ffffffffc0205e04:	ff860613          	addi	a2,a2,-8 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205e08:	25e00593          	li	a1,606
ffffffffc0205e0c:	00003517          	auipc	a0,0x3
ffffffffc0205e10:	cb450513          	addi	a0,a0,-844 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205e14:	c00fa0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0205e18:	ff8710e3          	bne	a4,s8,ffffffffc0205df8 <do_execve+0x3aa>
ffffffffc0205e1c:	8be2                	mv	s7,s8
ffffffffc0205e1e:	000a7a97          	auipc	s5,0xa7
ffffffffc0205e22:	a5aa8a93          	addi	s5,s5,-1446 # ffffffffc02ac878 <va_pa_offset>
        while (start < end) {
ffffffffc0205e26:	053be763          	bltu	s7,s3,ffffffffc0205e74 <do_execve+0x426>
ffffffffc0205e2a:	b3bd                	j	ffffffffc0205b98 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205e2c:	6785                	lui	a5,0x1
ffffffffc0205e2e:	418b8533          	sub	a0,s7,s8
ffffffffc0205e32:	9c3e                	add	s8,s8,a5
ffffffffc0205e34:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205e38:	0189f463          	bgeu	s3,s8,ffffffffc0205e40 <do_execve+0x3f2>
                size -= la - end;
ffffffffc0205e3c:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205e40:	000db683          	ld	a3,0(s11)
ffffffffc0205e44:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205e48:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205e4a:	40d486b3          	sub	a3,s1,a3
ffffffffc0205e4e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205e50:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205e54:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205e56:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205e5a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205e5c:	02b87e63          	bgeu	a6,a1,ffffffffc0205e98 <do_execve+0x44a>
ffffffffc0205e60:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205e64:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205e66:	4581                	li	a1,0
ffffffffc0205e68:	96c2                	add	a3,a3,a6
ffffffffc0205e6a:	9536                	add	a0,a0,a3
ffffffffc0205e6c:	56c000ef          	jal	ra,ffffffffc02063d8 <memset>
        while (start < end) {
ffffffffc0205e70:	d33bf4e3          	bgeu	s7,s3,ffffffffc0205b98 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205e74:	01893503          	ld	a0,24(s2)
ffffffffc0205e78:	6602                	ld	a2,0(sp)
ffffffffc0205e7a:	85e2                	mv	a1,s8
ffffffffc0205e7c:	cf2fc0ef          	jal	ra,ffffffffc020236e <pgdir_alloc_page>
ffffffffc0205e80:	84aa                	mv	s1,a0
ffffffffc0205e82:	f54d                	bnez	a0,ffffffffc0205e2c <do_execve+0x3de>
ffffffffc0205e84:	bde9                	j	ffffffffc0205d5e <do_execve+0x310>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205e86:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205e8a:	b72d                	j	ffffffffc0205db4 <do_execve+0x366>
        while (start < end) {
ffffffffc0205e8c:	89de                	mv	s3,s7
ffffffffc0205e8e:	b729                	j	ffffffffc0205d98 <do_execve+0x34a>
        return -E_INVAL;
ffffffffc0205e90:	59f5                	li	s3,-3
ffffffffc0205e92:	bbf1                	j	ffffffffc0205c6e <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205e94:	59e1                	li	s3,-8
ffffffffc0205e96:	b5e9                	j	ffffffffc0205d60 <do_execve+0x312>
ffffffffc0205e98:	00001617          	auipc	a2,0x1
ffffffffc0205e9c:	38860613          	addi	a2,a2,904 # ffffffffc0207220 <commands+0x8a8>
ffffffffc0205ea0:	06900593          	li	a1,105
ffffffffc0205ea4:	00001517          	auipc	a0,0x1
ffffffffc0205ea8:	3d450513          	addi	a0,a0,980 # ffffffffc0207278 <commands+0x900>
ffffffffc0205eac:	b68fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205eb0:	00001617          	auipc	a2,0x1
ffffffffc0205eb4:	44860613          	addi	a2,a2,1096 # ffffffffc02072f8 <commands+0x980>
ffffffffc0205eb8:	27900593          	li	a1,633
ffffffffc0205ebc:	00003517          	auipc	a0,0x3
ffffffffc0205ec0:	c0450513          	addi	a0,a0,-1020 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205ec4:	b50fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ec8:	00003697          	auipc	a3,0x3
ffffffffc0205ecc:	8e868693          	addi	a3,a3,-1816 # ffffffffc02087b0 <default_pmm_manager+0x3b8>
ffffffffc0205ed0:	00001617          	auipc	a2,0x1
ffffffffc0205ed4:	f2860613          	addi	a2,a2,-216 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205ed8:	27400593          	li	a1,628
ffffffffc0205edc:	00003517          	auipc	a0,0x3
ffffffffc0205ee0:	be450513          	addi	a0,a0,-1052 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205ee4:	b30fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ee8:	00003697          	auipc	a3,0x3
ffffffffc0205eec:	88068693          	addi	a3,a3,-1920 # ffffffffc0208768 <default_pmm_manager+0x370>
ffffffffc0205ef0:	00001617          	auipc	a2,0x1
ffffffffc0205ef4:	f0860613          	addi	a2,a2,-248 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205ef8:	27300593          	li	a1,627
ffffffffc0205efc:	00003517          	auipc	a0,0x3
ffffffffc0205f00:	bc450513          	addi	a0,a0,-1084 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205f04:	b10fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205f08:	00003697          	auipc	a3,0x3
ffffffffc0205f0c:	81868693          	addi	a3,a3,-2024 # ffffffffc0208720 <default_pmm_manager+0x328>
ffffffffc0205f10:	00001617          	auipc	a2,0x1
ffffffffc0205f14:	ee860613          	addi	a2,a2,-280 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205f18:	27200593          	li	a1,626
ffffffffc0205f1c:	00003517          	auipc	a0,0x3
ffffffffc0205f20:	ba450513          	addi	a0,a0,-1116 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205f24:	af0fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205f28:	00002697          	auipc	a3,0x2
ffffffffc0205f2c:	7b068693          	addi	a3,a3,1968 # ffffffffc02086d8 <default_pmm_manager+0x2e0>
ffffffffc0205f30:	00001617          	auipc	a2,0x1
ffffffffc0205f34:	ec860613          	addi	a2,a2,-312 # ffffffffc0206df8 <commands+0x480>
ffffffffc0205f38:	27100593          	li	a1,625
ffffffffc0205f3c:	00003517          	auipc	a0,0x3
ffffffffc0205f40:	b8450513          	addi	a0,a0,-1148 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0205f44:	ad0fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205f48 <do_yield>:
    current->need_resched = 1;
ffffffffc0205f48:	000a7797          	auipc	a5,0xa7
ffffffffc0205f4c:	90078793          	addi	a5,a5,-1792 # ffffffffc02ac848 <current>
ffffffffc0205f50:	639c                	ld	a5,0(a5)
ffffffffc0205f52:	4705                	li	a4,1
}
ffffffffc0205f54:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205f56:	ef98                	sd	a4,24(a5)
}
ffffffffc0205f58:	8082                	ret

ffffffffc0205f5a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205f5a:	1101                	addi	sp,sp,-32
ffffffffc0205f5c:	e822                	sd	s0,16(sp)
ffffffffc0205f5e:	e426                	sd	s1,8(sp)
ffffffffc0205f60:	ec06                	sd	ra,24(sp)
ffffffffc0205f62:	842e                	mv	s0,a1
ffffffffc0205f64:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205f66:	cd81                	beqz	a1,ffffffffc0205f7e <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205f68:	000a7797          	auipc	a5,0xa7
ffffffffc0205f6c:	8e078793          	addi	a5,a5,-1824 # ffffffffc02ac848 <current>
ffffffffc0205f70:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205f72:	4685                	li	a3,1
ffffffffc0205f74:	4611                	li	a2,4
ffffffffc0205f76:	7788                	ld	a0,40(a5)
ffffffffc0205f78:	838fd0ef          	jal	ra,ffffffffc0202fb0 <user_mem_check>
ffffffffc0205f7c:	c909                	beqz	a0,ffffffffc0205f8e <do_wait+0x34>
ffffffffc0205f7e:	85a2                	mv	a1,s0
}
ffffffffc0205f80:	6442                	ld	s0,16(sp)
ffffffffc0205f82:	60e2                	ld	ra,24(sp)
ffffffffc0205f84:	8526                	mv	a0,s1
ffffffffc0205f86:	64a2                	ld	s1,8(sp)
ffffffffc0205f88:	6105                	addi	sp,sp,32
ffffffffc0205f8a:	ff4ff06f          	j	ffffffffc020577e <do_wait.part.1>
ffffffffc0205f8e:	60e2                	ld	ra,24(sp)
ffffffffc0205f90:	6442                	ld	s0,16(sp)
ffffffffc0205f92:	64a2                	ld	s1,8(sp)
ffffffffc0205f94:	5575                	li	a0,-3
ffffffffc0205f96:	6105                	addi	sp,sp,32
ffffffffc0205f98:	8082                	ret

ffffffffc0205f9a <do_kill>:
do_kill(int pid) {
ffffffffc0205f9a:	1141                	addi	sp,sp,-16
ffffffffc0205f9c:	e406                	sd	ra,8(sp)
ffffffffc0205f9e:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205fa0:	a08ff0ef          	jal	ra,ffffffffc02051a8 <find_proc>
ffffffffc0205fa4:	cd0d                	beqz	a0,ffffffffc0205fde <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205fa6:	0b052703          	lw	a4,176(a0)
ffffffffc0205faa:	00177693          	andi	a3,a4,1
ffffffffc0205fae:	e695                	bnez	a3,ffffffffc0205fda <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205fb0:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205fb4:	00176713          	ori	a4,a4,1
ffffffffc0205fb8:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205fbc:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205fbe:	0006c763          	bltz	a3,ffffffffc0205fcc <do_kill+0x32>
}
ffffffffc0205fc2:	8522                	mv	a0,s0
ffffffffc0205fc4:	60a2                	ld	ra,8(sp)
ffffffffc0205fc6:	6402                	ld	s0,0(sp)
ffffffffc0205fc8:	0141                	addi	sp,sp,16
ffffffffc0205fca:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205fcc:	17c000ef          	jal	ra,ffffffffc0206148 <wakeup_proc>
}
ffffffffc0205fd0:	8522                	mv	a0,s0
ffffffffc0205fd2:	60a2                	ld	ra,8(sp)
ffffffffc0205fd4:	6402                	ld	s0,0(sp)
ffffffffc0205fd6:	0141                	addi	sp,sp,16
ffffffffc0205fd8:	8082                	ret
        return -E_KILLED;
ffffffffc0205fda:	545d                	li	s0,-9
ffffffffc0205fdc:	b7dd                	j	ffffffffc0205fc2 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205fde:	5475                	li	s0,-3
ffffffffc0205fe0:	b7cd                	j	ffffffffc0205fc2 <do_kill+0x28>

ffffffffc0205fe2 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205fe2:	000a7797          	auipc	a5,0xa7
ffffffffc0205fe6:	9a678793          	addi	a5,a5,-1626 # ffffffffc02ac988 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205fea:	1101                	addi	sp,sp,-32
ffffffffc0205fec:	000a7717          	auipc	a4,0xa7
ffffffffc0205ff0:	9af73223          	sd	a5,-1628(a4) # ffffffffc02ac990 <proc_list+0x8>
ffffffffc0205ff4:	000a7717          	auipc	a4,0xa7
ffffffffc0205ff8:	98f73a23          	sd	a5,-1644(a4) # ffffffffc02ac988 <proc_list>
ffffffffc0205ffc:	ec06                	sd	ra,24(sp)
ffffffffc0205ffe:	e822                	sd	s0,16(sp)
ffffffffc0206000:	e426                	sd	s1,8(sp)
ffffffffc0206002:	000a3797          	auipc	a5,0xa3
ffffffffc0206006:	80678793          	addi	a5,a5,-2042 # ffffffffc02a8808 <hash_list>
ffffffffc020600a:	000a6717          	auipc	a4,0xa6
ffffffffc020600e:	7fe70713          	addi	a4,a4,2046 # ffffffffc02ac808 <is_panic>
ffffffffc0206012:	e79c                	sd	a5,8(a5)
ffffffffc0206014:	e39c                	sd	a5,0(a5)
ffffffffc0206016:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0206018:	fee79de3          	bne	a5,a4,ffffffffc0206012 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020601c:	ee7fe0ef          	jal	ra,ffffffffc0204f02 <alloc_proc>
ffffffffc0206020:	000a7717          	auipc	a4,0xa7
ffffffffc0206024:	82a73823          	sd	a0,-2000(a4) # ffffffffc02ac850 <idleproc>
ffffffffc0206028:	000a7497          	auipc	s1,0xa7
ffffffffc020602c:	82848493          	addi	s1,s1,-2008 # ffffffffc02ac850 <idleproc>
ffffffffc0206030:	c559                	beqz	a0,ffffffffc02060be <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0206032:	4709                	li	a4,2
ffffffffc0206034:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0206036:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0206038:	00003717          	auipc	a4,0x3
ffffffffc020603c:	fc870713          	addi	a4,a4,-56 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0206040:	00003597          	auipc	a1,0x3
ffffffffc0206044:	9a058593          	addi	a1,a1,-1632 # ffffffffc02089e0 <default_pmm_manager+0x5e8>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0206048:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc020604a:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc020604c:	8c6ff0ef          	jal	ra,ffffffffc0205112 <set_proc_name>
    nr_process ++;
ffffffffc0206050:	000a7797          	auipc	a5,0xa7
ffffffffc0206054:	81078793          	addi	a5,a5,-2032 # ffffffffc02ac860 <nr_process>
ffffffffc0206058:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc020605a:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020605c:	4601                	li	a2,0
    nr_process ++;
ffffffffc020605e:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206060:	4581                	li	a1,0
ffffffffc0206062:	00000517          	auipc	a0,0x0
ffffffffc0206066:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205926 <init_main>
    nr_process ++;
ffffffffc020606a:	000a6697          	auipc	a3,0xa6
ffffffffc020606e:	7ef6ab23          	sw	a5,2038(a3) # ffffffffc02ac860 <nr_process>
    current = idleproc;
ffffffffc0206072:	000a6797          	auipc	a5,0xa6
ffffffffc0206076:	7ce7bb23          	sd	a4,2006(a5) # ffffffffc02ac848 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020607a:	d66ff0ef          	jal	ra,ffffffffc02055e0 <kernel_thread>
    if (pid <= 0) {
ffffffffc020607e:	08a05c63          	blez	a0,ffffffffc0206116 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0206082:	926ff0ef          	jal	ra,ffffffffc02051a8 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0206086:	00003597          	auipc	a1,0x3
ffffffffc020608a:	98258593          	addi	a1,a1,-1662 # ffffffffc0208a08 <default_pmm_manager+0x610>
    initproc = find_proc(pid);
ffffffffc020608e:	000a6797          	auipc	a5,0xa6
ffffffffc0206092:	7ca7b523          	sd	a0,1994(a5) # ffffffffc02ac858 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0206096:	87cff0ef          	jal	ra,ffffffffc0205112 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020609a:	609c                	ld	a5,0(s1)
ffffffffc020609c:	cfa9                	beqz	a5,ffffffffc02060f6 <proc_init+0x114>
ffffffffc020609e:	43dc                	lw	a5,4(a5)
ffffffffc02060a0:	ebb9                	bnez	a5,ffffffffc02060f6 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02060a2:	000a6797          	auipc	a5,0xa6
ffffffffc02060a6:	7b678793          	addi	a5,a5,1974 # ffffffffc02ac858 <initproc>
ffffffffc02060aa:	639c                	ld	a5,0(a5)
ffffffffc02060ac:	c78d                	beqz	a5,ffffffffc02060d6 <proc_init+0xf4>
ffffffffc02060ae:	43dc                	lw	a5,4(a5)
ffffffffc02060b0:	02879363          	bne	a5,s0,ffffffffc02060d6 <proc_init+0xf4>
}
ffffffffc02060b4:	60e2                	ld	ra,24(sp)
ffffffffc02060b6:	6442                	ld	s0,16(sp)
ffffffffc02060b8:	64a2                	ld	s1,8(sp)
ffffffffc02060ba:	6105                	addi	sp,sp,32
ffffffffc02060bc:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc02060be:	00003617          	auipc	a2,0x3
ffffffffc02060c2:	90a60613          	addi	a2,a2,-1782 # ffffffffc02089c8 <default_pmm_manager+0x5d0>
ffffffffc02060c6:	37000593          	li	a1,880
ffffffffc02060ca:	00003517          	auipc	a0,0x3
ffffffffc02060ce:	9f650513          	addi	a0,a0,-1546 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc02060d2:	942fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02060d6:	00003697          	auipc	a3,0x3
ffffffffc02060da:	96268693          	addi	a3,a3,-1694 # ffffffffc0208a38 <default_pmm_manager+0x640>
ffffffffc02060de:	00001617          	auipc	a2,0x1
ffffffffc02060e2:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206df8 <commands+0x480>
ffffffffc02060e6:	38500593          	li	a1,901
ffffffffc02060ea:	00003517          	auipc	a0,0x3
ffffffffc02060ee:	9d650513          	addi	a0,a0,-1578 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc02060f2:	922fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02060f6:	00003697          	auipc	a3,0x3
ffffffffc02060fa:	91a68693          	addi	a3,a3,-1766 # ffffffffc0208a10 <default_pmm_manager+0x618>
ffffffffc02060fe:	00001617          	auipc	a2,0x1
ffffffffc0206102:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206df8 <commands+0x480>
ffffffffc0206106:	38400593          	li	a1,900
ffffffffc020610a:	00003517          	auipc	a0,0x3
ffffffffc020610e:	9b650513          	addi	a0,a0,-1610 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc0206112:	902fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create init_main failed.\n");
ffffffffc0206116:	00003617          	auipc	a2,0x3
ffffffffc020611a:	8d260613          	addi	a2,a2,-1838 # ffffffffc02089e8 <default_pmm_manager+0x5f0>
ffffffffc020611e:	37e00593          	li	a1,894
ffffffffc0206122:	00003517          	auipc	a0,0x3
ffffffffc0206126:	99e50513          	addi	a0,a0,-1634 # ffffffffc0208ac0 <default_pmm_manager+0x6c8>
ffffffffc020612a:	8eafa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020612e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020612e:	1141                	addi	sp,sp,-16
ffffffffc0206130:	e022                	sd	s0,0(sp)
ffffffffc0206132:	e406                	sd	ra,8(sp)
ffffffffc0206134:	000a6417          	auipc	s0,0xa6
ffffffffc0206138:	71440413          	addi	s0,s0,1812 # ffffffffc02ac848 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020613c:	6018                	ld	a4,0(s0)
ffffffffc020613e:	6f1c                	ld	a5,24(a4)
ffffffffc0206140:	dffd                	beqz	a5,ffffffffc020613e <cpu_idle+0x10>
            schedule();
ffffffffc0206142:	082000ef          	jal	ra,ffffffffc02061c4 <schedule>
ffffffffc0206146:	bfdd                	j	ffffffffc020613c <cpu_idle+0xe>

ffffffffc0206148 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206148:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020614a:	1101                	addi	sp,sp,-32
ffffffffc020614c:	ec06                	sd	ra,24(sp)
ffffffffc020614e:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206150:	478d                	li	a5,3
ffffffffc0206152:	04f70a63          	beq	a4,a5,ffffffffc02061a6 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206156:	100027f3          	csrr	a5,sstatus
ffffffffc020615a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020615c:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020615e:	ef8d                	bnez	a5,ffffffffc0206198 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206160:	4789                	li	a5,2
ffffffffc0206162:	00f70f63          	beq	a4,a5,ffffffffc0206180 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0206166:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0206168:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc020616c:	e409                	bnez	s0,ffffffffc0206176 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020616e:	60e2                	ld	ra,24(sp)
ffffffffc0206170:	6442                	ld	s0,16(sp)
ffffffffc0206172:	6105                	addi	sp,sp,32
ffffffffc0206174:	8082                	ret
ffffffffc0206176:	6442                	ld	s0,16(sp)
ffffffffc0206178:	60e2                	ld	ra,24(sp)
ffffffffc020617a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020617c:	cd2fa06f          	j	ffffffffc020064e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206180:	00003617          	auipc	a2,0x3
ffffffffc0206184:	99060613          	addi	a2,a2,-1648 # ffffffffc0208b10 <default_pmm_manager+0x718>
ffffffffc0206188:	45c9                	li	a1,18
ffffffffc020618a:	00003517          	auipc	a0,0x3
ffffffffc020618e:	96e50513          	addi	a0,a0,-1682 # ffffffffc0208af8 <default_pmm_manager+0x700>
ffffffffc0206192:	8eefa0ef          	jal	ra,ffffffffc0200280 <__warn>
ffffffffc0206196:	bfd9                	j	ffffffffc020616c <wakeup_proc+0x24>
ffffffffc0206198:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020619a:	cbafa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc020619e:	6522                	ld	a0,8(sp)
ffffffffc02061a0:	4405                	li	s0,1
ffffffffc02061a2:	4118                	lw	a4,0(a0)
ffffffffc02061a4:	bf75                	j	ffffffffc0206160 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02061a6:	00003697          	auipc	a3,0x3
ffffffffc02061aa:	93268693          	addi	a3,a3,-1742 # ffffffffc0208ad8 <default_pmm_manager+0x6e0>
ffffffffc02061ae:	00001617          	auipc	a2,0x1
ffffffffc02061b2:	c4a60613          	addi	a2,a2,-950 # ffffffffc0206df8 <commands+0x480>
ffffffffc02061b6:	45a5                	li	a1,9
ffffffffc02061b8:	00003517          	auipc	a0,0x3
ffffffffc02061bc:	94050513          	addi	a0,a0,-1728 # ffffffffc0208af8 <default_pmm_manager+0x700>
ffffffffc02061c0:	854fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02061c4 <schedule>:

void
schedule(void) {
ffffffffc02061c4:	1141                	addi	sp,sp,-16
ffffffffc02061c6:	e406                	sd	ra,8(sp)
ffffffffc02061c8:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02061ca:	100027f3          	csrr	a5,sstatus
ffffffffc02061ce:	8b89                	andi	a5,a5,2
ffffffffc02061d0:	4401                	li	s0,0
ffffffffc02061d2:	e3d1                	bnez	a5,ffffffffc0206256 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02061d4:	000a6797          	auipc	a5,0xa6
ffffffffc02061d8:	67478793          	addi	a5,a5,1652 # ffffffffc02ac848 <current>
ffffffffc02061dc:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061e0:	000a6797          	auipc	a5,0xa6
ffffffffc02061e4:	67078793          	addi	a5,a5,1648 # ffffffffc02ac850 <idleproc>
ffffffffc02061e8:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02061ea:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b0>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061ee:	04a88e63          	beq	a7,a0,ffffffffc020624a <schedule+0x86>
ffffffffc02061f2:	0c888693          	addi	a3,a7,200
ffffffffc02061f6:	000a6617          	auipc	a2,0xa6
ffffffffc02061fa:	79260613          	addi	a2,a2,1938 # ffffffffc02ac988 <proc_list>
        le = last;
ffffffffc02061fe:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206200:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206202:	4809                	li	a6,2
    return listelm->next;
ffffffffc0206204:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206206:	00c78863          	beq	a5,a2,ffffffffc0206216 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020620a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020620e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206212:	01070463          	beq	a4,a6,ffffffffc020621a <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206216:	fef697e3          	bne	a3,a5,ffffffffc0206204 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020621a:	c589                	beqz	a1,ffffffffc0206224 <schedule+0x60>
ffffffffc020621c:	4198                	lw	a4,0(a1)
ffffffffc020621e:	4789                	li	a5,2
ffffffffc0206220:	00f70e63          	beq	a4,a5,ffffffffc020623c <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206224:	451c                	lw	a5,8(a0)
ffffffffc0206226:	2785                	addiw	a5,a5,1
ffffffffc0206228:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020622a:	00a88463          	beq	a7,a0,ffffffffc0206232 <schedule+0x6e>
            proc_run(next);
ffffffffc020622e:	f0ffe0ef          	jal	ra,ffffffffc020513c <proc_run>
    if (flag) {
ffffffffc0206232:	e419                	bnez	s0,ffffffffc0206240 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206234:	60a2                	ld	ra,8(sp)
ffffffffc0206236:	6402                	ld	s0,0(sp)
ffffffffc0206238:	0141                	addi	sp,sp,16
ffffffffc020623a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020623c:	852e                	mv	a0,a1
ffffffffc020623e:	b7dd                	j	ffffffffc0206224 <schedule+0x60>
}
ffffffffc0206240:	6402                	ld	s0,0(sp)
ffffffffc0206242:	60a2                	ld	ra,8(sp)
ffffffffc0206244:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206246:	c08fa06f          	j	ffffffffc020064e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020624a:	000a6617          	auipc	a2,0xa6
ffffffffc020624e:	73e60613          	addi	a2,a2,1854 # ffffffffc02ac988 <proc_list>
ffffffffc0206252:	86b2                	mv	a3,a2
ffffffffc0206254:	b76d                	j	ffffffffc02061fe <schedule+0x3a>
        intr_disable();
ffffffffc0206256:	bfefa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc020625a:	4405                	li	s0,1
ffffffffc020625c:	bfa5                	j	ffffffffc02061d4 <schedule+0x10>

ffffffffc020625e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020625e:	000a6797          	auipc	a5,0xa6
ffffffffc0206262:	5ea78793          	addi	a5,a5,1514 # ffffffffc02ac848 <current>
ffffffffc0206266:	639c                	ld	a5,0(a5)
}
ffffffffc0206268:	43c8                	lw	a0,4(a5)
ffffffffc020626a:	8082                	ret

ffffffffc020626c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020626c:	4501                	li	a0,0
ffffffffc020626e:	8082                	ret

ffffffffc0206270 <sys_putc>:
    cputchar(c);
ffffffffc0206270:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206272:	1141                	addi	sp,sp,-16
ffffffffc0206274:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206276:	e8ff90ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc020627a:	60a2                	ld	ra,8(sp)
ffffffffc020627c:	4501                	li	a0,0
ffffffffc020627e:	0141                	addi	sp,sp,16
ffffffffc0206280:	8082                	ret

ffffffffc0206282 <sys_kill>:
    return do_kill(pid);
ffffffffc0206282:	4108                	lw	a0,0(a0)
ffffffffc0206284:	d17ff06f          	j	ffffffffc0205f9a <do_kill>

ffffffffc0206288 <sys_yield>:
    return do_yield();
ffffffffc0206288:	cc1ff06f          	j	ffffffffc0205f48 <do_yield>

ffffffffc020628c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020628c:	6d14                	ld	a3,24(a0)
ffffffffc020628e:	6910                	ld	a2,16(a0)
ffffffffc0206290:	650c                	ld	a1,8(a0)
ffffffffc0206292:	6108                	ld	a0,0(a0)
ffffffffc0206294:	fbaff06f          	j	ffffffffc0205a4e <do_execve>

ffffffffc0206298 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206298:	650c                	ld	a1,8(a0)
ffffffffc020629a:	4108                	lw	a0,0(a0)
ffffffffc020629c:	cbfff06f          	j	ffffffffc0205f5a <do_wait>

ffffffffc02062a0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02062a0:	000a6797          	auipc	a5,0xa6
ffffffffc02062a4:	5a878793          	addi	a5,a5,1448 # ffffffffc02ac848 <current>
ffffffffc02062a8:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02062aa:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02062ac:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02062ae:	6a0c                	ld	a1,16(a2)
ffffffffc02062b0:	f55fe06f          	j	ffffffffc0205204 <do_fork>

ffffffffc02062b4 <sys_exit>:
    return do_exit(error_code);
ffffffffc02062b4:	4108                	lw	a0,0(a0)
ffffffffc02062b6:	b7aff06f          	j	ffffffffc0205630 <do_exit>

ffffffffc02062ba <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02062ba:	715d                	addi	sp,sp,-80
ffffffffc02062bc:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02062be:	000a6497          	auipc	s1,0xa6
ffffffffc02062c2:	58a48493          	addi	s1,s1,1418 # ffffffffc02ac848 <current>
ffffffffc02062c6:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02062c8:	e0a2                	sd	s0,64(sp)
ffffffffc02062ca:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02062cc:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02062ce:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02062d0:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02062d2:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02062d6:	0327ee63          	bltu	a5,s2,ffffffffc0206312 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02062da:	00391713          	slli	a4,s2,0x3
ffffffffc02062de:	00003797          	auipc	a5,0x3
ffffffffc02062e2:	89a78793          	addi	a5,a5,-1894 # ffffffffc0208b78 <syscalls>
ffffffffc02062e6:	97ba                	add	a5,a5,a4
ffffffffc02062e8:	639c                	ld	a5,0(a5)
ffffffffc02062ea:	c785                	beqz	a5,ffffffffc0206312 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02062ec:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02062ee:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02062f0:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02062f2:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02062f4:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02062f6:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02062f8:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02062fa:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02062fc:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02062fe:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206300:	0028                	addi	a0,sp,8
ffffffffc0206302:	9782                	jalr	a5
ffffffffc0206304:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206306:	60a6                	ld	ra,72(sp)
ffffffffc0206308:	6406                	ld	s0,64(sp)
ffffffffc020630a:	74e2                	ld	s1,56(sp)
ffffffffc020630c:	7942                	ld	s2,48(sp)
ffffffffc020630e:	6161                	addi	sp,sp,80
ffffffffc0206310:	8082                	ret
    print_trapframe(tf);
ffffffffc0206312:	8522                	mv	a0,s0
ffffffffc0206314:	d2efa0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206318:	609c                	ld	a5,0(s1)
ffffffffc020631a:	86ca                	mv	a3,s2
ffffffffc020631c:	00003617          	auipc	a2,0x3
ffffffffc0206320:	81460613          	addi	a2,a2,-2028 # ffffffffc0208b30 <default_pmm_manager+0x738>
ffffffffc0206324:	43d8                	lw	a4,4(a5)
ffffffffc0206326:	06300593          	li	a1,99
ffffffffc020632a:	0b478793          	addi	a5,a5,180
ffffffffc020632e:	00003517          	auipc	a0,0x3
ffffffffc0206332:	83250513          	addi	a0,a0,-1998 # ffffffffc0208b60 <default_pmm_manager+0x768>
ffffffffc0206336:	edff90ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020633a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020633a:	00054783          	lbu	a5,0(a0)
ffffffffc020633e:	cb91                	beqz	a5,ffffffffc0206352 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206340:	4781                	li	a5,0
        cnt ++;
ffffffffc0206342:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206344:	00f50733          	add	a4,a0,a5
ffffffffc0206348:	00074703          	lbu	a4,0(a4)
ffffffffc020634c:	fb7d                	bnez	a4,ffffffffc0206342 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020634e:	853e                	mv	a0,a5
ffffffffc0206350:	8082                	ret
    size_t cnt = 0;
ffffffffc0206352:	4781                	li	a5,0
}
ffffffffc0206354:	853e                	mv	a0,a5
ffffffffc0206356:	8082                	ret

ffffffffc0206358 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206358:	c185                	beqz	a1,ffffffffc0206378 <strnlen+0x20>
ffffffffc020635a:	00054783          	lbu	a5,0(a0)
ffffffffc020635e:	cf89                	beqz	a5,ffffffffc0206378 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206360:	4781                	li	a5,0
ffffffffc0206362:	a021                	j	ffffffffc020636a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206364:	00074703          	lbu	a4,0(a4)
ffffffffc0206368:	c711                	beqz	a4,ffffffffc0206374 <strnlen+0x1c>
        cnt ++;
ffffffffc020636a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020636c:	00f50733          	add	a4,a0,a5
ffffffffc0206370:	fef59ae3          	bne	a1,a5,ffffffffc0206364 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206374:	853e                	mv	a0,a5
ffffffffc0206376:	8082                	ret
    size_t cnt = 0;
ffffffffc0206378:	4781                	li	a5,0
}
ffffffffc020637a:	853e                	mv	a0,a5
ffffffffc020637c:	8082                	ret

ffffffffc020637e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020637e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206380:	0585                	addi	a1,a1,1
ffffffffc0206382:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206386:	0785                	addi	a5,a5,1
ffffffffc0206388:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020638c:	fb75                	bnez	a4,ffffffffc0206380 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020638e:	8082                	ret

ffffffffc0206390 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206390:	00054783          	lbu	a5,0(a0)
ffffffffc0206394:	0005c703          	lbu	a4,0(a1)
ffffffffc0206398:	cb91                	beqz	a5,ffffffffc02063ac <strcmp+0x1c>
ffffffffc020639a:	00e79c63          	bne	a5,a4,ffffffffc02063b2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020639e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02063a0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02063a4:	0585                	addi	a1,a1,1
ffffffffc02063a6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02063aa:	fbe5                	bnez	a5,ffffffffc020639a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02063ac:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02063ae:	9d19                	subw	a0,a0,a4
ffffffffc02063b0:	8082                	ret
ffffffffc02063b2:	0007851b          	sext.w	a0,a5
ffffffffc02063b6:	9d19                	subw	a0,a0,a4
ffffffffc02063b8:	8082                	ret

ffffffffc02063ba <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02063ba:	00054783          	lbu	a5,0(a0)
ffffffffc02063be:	cb91                	beqz	a5,ffffffffc02063d2 <strchr+0x18>
        if (*s == c) {
ffffffffc02063c0:	00b79563          	bne	a5,a1,ffffffffc02063ca <strchr+0x10>
ffffffffc02063c4:	a809                	j	ffffffffc02063d6 <strchr+0x1c>
ffffffffc02063c6:	00b78763          	beq	a5,a1,ffffffffc02063d4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02063ca:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02063cc:	00054783          	lbu	a5,0(a0)
ffffffffc02063d0:	fbfd                	bnez	a5,ffffffffc02063c6 <strchr+0xc>
    }
    return NULL;
ffffffffc02063d2:	4501                	li	a0,0
}
ffffffffc02063d4:	8082                	ret
ffffffffc02063d6:	8082                	ret

ffffffffc02063d8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02063d8:	ca01                	beqz	a2,ffffffffc02063e8 <memset+0x10>
ffffffffc02063da:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02063dc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02063de:	0785                	addi	a5,a5,1
ffffffffc02063e0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02063e4:	fec79de3          	bne	a5,a2,ffffffffc02063de <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02063e8:	8082                	ret

ffffffffc02063ea <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02063ea:	ca19                	beqz	a2,ffffffffc0206400 <memcpy+0x16>
ffffffffc02063ec:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02063ee:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02063f0:	0585                	addi	a1,a1,1
ffffffffc02063f2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02063f6:	0785                	addi	a5,a5,1
ffffffffc02063f8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02063fc:	fec59ae3          	bne	a1,a2,ffffffffc02063f0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206400:	8082                	ret

ffffffffc0206402 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206402:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206406:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206408:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020640c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020640e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206412:	f022                	sd	s0,32(sp)
ffffffffc0206414:	ec26                	sd	s1,24(sp)
ffffffffc0206416:	e84a                	sd	s2,16(sp)
ffffffffc0206418:	f406                	sd	ra,40(sp)
ffffffffc020641a:	e44e                	sd	s3,8(sp)
ffffffffc020641c:	84aa                	mv	s1,a0
ffffffffc020641e:	892e                	mv	s2,a1
ffffffffc0206420:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206424:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0206426:	03067e63          	bgeu	a2,a6,ffffffffc0206462 <printnum+0x60>
ffffffffc020642a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020642c:	00805763          	blez	s0,ffffffffc020643a <printnum+0x38>
ffffffffc0206430:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206432:	85ca                	mv	a1,s2
ffffffffc0206434:	854e                	mv	a0,s3
ffffffffc0206436:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206438:	fc65                	bnez	s0,ffffffffc0206430 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020643a:	1a02                	slli	s4,s4,0x20
ffffffffc020643c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206440:	00003797          	auipc	a5,0x3
ffffffffc0206444:	a5878793          	addi	a5,a5,-1448 # ffffffffc0208e98 <error_string+0xc8>
ffffffffc0206448:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020644a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020644c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206450:	70a2                	ld	ra,40(sp)
ffffffffc0206452:	69a2                	ld	s3,8(sp)
ffffffffc0206454:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206456:	85ca                	mv	a1,s2
ffffffffc0206458:	8326                	mv	t1,s1
}
ffffffffc020645a:	6942                	ld	s2,16(sp)
ffffffffc020645c:	64e2                	ld	s1,24(sp)
ffffffffc020645e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206460:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206462:	03065633          	divu	a2,a2,a6
ffffffffc0206466:	8722                	mv	a4,s0
ffffffffc0206468:	f9bff0ef          	jal	ra,ffffffffc0206402 <printnum>
ffffffffc020646c:	b7f9                	j	ffffffffc020643a <printnum+0x38>

ffffffffc020646e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020646e:	7119                	addi	sp,sp,-128
ffffffffc0206470:	f4a6                	sd	s1,104(sp)
ffffffffc0206472:	f0ca                	sd	s2,96(sp)
ffffffffc0206474:	e8d2                	sd	s4,80(sp)
ffffffffc0206476:	e4d6                	sd	s5,72(sp)
ffffffffc0206478:	e0da                	sd	s6,64(sp)
ffffffffc020647a:	fc5e                	sd	s7,56(sp)
ffffffffc020647c:	f862                	sd	s8,48(sp)
ffffffffc020647e:	f06a                	sd	s10,32(sp)
ffffffffc0206480:	fc86                	sd	ra,120(sp)
ffffffffc0206482:	f8a2                	sd	s0,112(sp)
ffffffffc0206484:	ecce                	sd	s3,88(sp)
ffffffffc0206486:	f466                	sd	s9,40(sp)
ffffffffc0206488:	ec6e                	sd	s11,24(sp)
ffffffffc020648a:	892a                	mv	s2,a0
ffffffffc020648c:	84ae                	mv	s1,a1
ffffffffc020648e:	8d32                	mv	s10,a2
ffffffffc0206490:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206492:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206494:	00002a17          	auipc	s4,0x2
ffffffffc0206498:	7e4a0a13          	addi	s4,s4,2020 # ffffffffc0208c78 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020649c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064a0:	00003c17          	auipc	s8,0x3
ffffffffc02064a4:	930c0c13          	addi	s8,s8,-1744 # ffffffffc0208dd0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064a8:	000d4503          	lbu	a0,0(s10)
ffffffffc02064ac:	02500793          	li	a5,37
ffffffffc02064b0:	001d0413          	addi	s0,s10,1
ffffffffc02064b4:	00f50e63          	beq	a0,a5,ffffffffc02064d0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02064b8:	c521                	beqz	a0,ffffffffc0206500 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064ba:	02500993          	li	s3,37
ffffffffc02064be:	a011                	j	ffffffffc02064c2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02064c0:	c121                	beqz	a0,ffffffffc0206500 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02064c2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064c4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02064c6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064c8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02064cc:	ff351ae3          	bne	a0,s3,ffffffffc02064c0 <vprintfmt+0x52>
ffffffffc02064d0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02064d4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02064d8:	4981                	li	s3,0
ffffffffc02064da:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02064dc:	5cfd                	li	s9,-1
ffffffffc02064de:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064e0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02064e4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064e6:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02064ea:	0ff6f693          	andi	a3,a3,255
ffffffffc02064ee:	00140d13          	addi	s10,s0,1
ffffffffc02064f2:	1ed5ef63          	bltu	a1,a3,ffffffffc02066f0 <vprintfmt+0x282>
ffffffffc02064f6:	068a                	slli	a3,a3,0x2
ffffffffc02064f8:	96d2                	add	a3,a3,s4
ffffffffc02064fa:	4294                	lw	a3,0(a3)
ffffffffc02064fc:	96d2                	add	a3,a3,s4
ffffffffc02064fe:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206500:	70e6                	ld	ra,120(sp)
ffffffffc0206502:	7446                	ld	s0,112(sp)
ffffffffc0206504:	74a6                	ld	s1,104(sp)
ffffffffc0206506:	7906                	ld	s2,96(sp)
ffffffffc0206508:	69e6                	ld	s3,88(sp)
ffffffffc020650a:	6a46                	ld	s4,80(sp)
ffffffffc020650c:	6aa6                	ld	s5,72(sp)
ffffffffc020650e:	6b06                	ld	s6,64(sp)
ffffffffc0206510:	7be2                	ld	s7,56(sp)
ffffffffc0206512:	7c42                	ld	s8,48(sp)
ffffffffc0206514:	7ca2                	ld	s9,40(sp)
ffffffffc0206516:	7d02                	ld	s10,32(sp)
ffffffffc0206518:	6de2                	ld	s11,24(sp)
ffffffffc020651a:	6109                	addi	sp,sp,128
ffffffffc020651c:	8082                	ret
            padc = '-';
ffffffffc020651e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206520:	00144603          	lbu	a2,1(s0)
ffffffffc0206524:	846a                	mv	s0,s10
ffffffffc0206526:	b7c1                	j	ffffffffc02064e6 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0206528:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020652c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206530:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206532:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206534:	fa0dd9e3          	bgez	s11,ffffffffc02064e6 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206538:	8de6                	mv	s11,s9
ffffffffc020653a:	5cfd                	li	s9,-1
ffffffffc020653c:	b76d                	j	ffffffffc02064e6 <vprintfmt+0x78>
            if (width < 0)
ffffffffc020653e:	fffdc693          	not	a3,s11
ffffffffc0206542:	96fd                	srai	a3,a3,0x3f
ffffffffc0206544:	00ddfdb3          	and	s11,s11,a3
ffffffffc0206548:	00144603          	lbu	a2,1(s0)
ffffffffc020654c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020654e:	846a                	mv	s0,s10
ffffffffc0206550:	bf59                	j	ffffffffc02064e6 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206552:	4705                	li	a4,1
ffffffffc0206554:	008a8593          	addi	a1,s5,8
ffffffffc0206558:	01074463          	blt	a4,a6,ffffffffc0206560 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc020655c:	22080863          	beqz	a6,ffffffffc020678c <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0206560:	000ab603          	ld	a2,0(s5)
ffffffffc0206564:	46c1                	li	a3,16
ffffffffc0206566:	8aae                	mv	s5,a1
ffffffffc0206568:	a291                	j	ffffffffc02066ac <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020656a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020656e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206572:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206574:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206578:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020657c:	fad56ce3          	bltu	a0,a3,ffffffffc0206534 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206580:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206582:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0206586:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020658a:	0196873b          	addw	a4,a3,s9
ffffffffc020658e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206592:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0206596:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020659a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020659e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02065a2:	fcd57fe3          	bgeu	a0,a3,ffffffffc0206580 <vprintfmt+0x112>
ffffffffc02065a6:	b779                	j	ffffffffc0206534 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc02065a8:	000aa503          	lw	a0,0(s5)
ffffffffc02065ac:	85a6                	mv	a1,s1
ffffffffc02065ae:	0aa1                	addi	s5,s5,8
ffffffffc02065b0:	9902                	jalr	s2
            break;
ffffffffc02065b2:	bddd                	j	ffffffffc02064a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02065b4:	4705                	li	a4,1
ffffffffc02065b6:	008a8993          	addi	s3,s5,8
ffffffffc02065ba:	01074463          	blt	a4,a6,ffffffffc02065c2 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02065be:	1c080463          	beqz	a6,ffffffffc0206786 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02065c2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02065c6:	1c044a63          	bltz	s0,ffffffffc020679a <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02065ca:	8622                	mv	a2,s0
ffffffffc02065cc:	8ace                	mv	s5,s3
ffffffffc02065ce:	46a9                	li	a3,10
ffffffffc02065d0:	a8f1                	j	ffffffffc02066ac <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02065d2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02065d6:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02065d8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02065da:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02065de:	8fb5                	xor	a5,a5,a3
ffffffffc02065e0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02065e4:	12d74963          	blt	a4,a3,ffffffffc0206716 <vprintfmt+0x2a8>
ffffffffc02065e8:	00369793          	slli	a5,a3,0x3
ffffffffc02065ec:	97e2                	add	a5,a5,s8
ffffffffc02065ee:	639c                	ld	a5,0(a5)
ffffffffc02065f0:	12078363          	beqz	a5,ffffffffc0206716 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02065f4:	86be                	mv	a3,a5
ffffffffc02065f6:	00000617          	auipc	a2,0x0
ffffffffc02065fa:	23a60613          	addi	a2,a2,570 # ffffffffc0206830 <etext+0x2a>
ffffffffc02065fe:	85a6                	mv	a1,s1
ffffffffc0206600:	854a                	mv	a0,s2
ffffffffc0206602:	1cc000ef          	jal	ra,ffffffffc02067ce <printfmt>
ffffffffc0206606:	b54d                	j	ffffffffc02064a8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206608:	000ab603          	ld	a2,0(s5)
ffffffffc020660c:	0aa1                	addi	s5,s5,8
ffffffffc020660e:	1a060163          	beqz	a2,ffffffffc02067b0 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0206612:	00160413          	addi	s0,a2,1
ffffffffc0206616:	15b05763          	blez	s11,ffffffffc0206764 <vprintfmt+0x2f6>
ffffffffc020661a:	02d00593          	li	a1,45
ffffffffc020661e:	10b79d63          	bne	a5,a1,ffffffffc0206738 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206622:	00064783          	lbu	a5,0(a2)
ffffffffc0206626:	0007851b          	sext.w	a0,a5
ffffffffc020662a:	c905                	beqz	a0,ffffffffc020665a <vprintfmt+0x1ec>
ffffffffc020662c:	000cc563          	bltz	s9,ffffffffc0206636 <vprintfmt+0x1c8>
ffffffffc0206630:	3cfd                	addiw	s9,s9,-1
ffffffffc0206632:	036c8263          	beq	s9,s6,ffffffffc0206656 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0206636:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206638:	14098f63          	beqz	s3,ffffffffc0206796 <vprintfmt+0x328>
ffffffffc020663c:	3781                	addiw	a5,a5,-32
ffffffffc020663e:	14fbfc63          	bgeu	s7,a5,ffffffffc0206796 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0206642:	03f00513          	li	a0,63
ffffffffc0206646:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206648:	0405                	addi	s0,s0,1
ffffffffc020664a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020664e:	3dfd                	addiw	s11,s11,-1
ffffffffc0206650:	0007851b          	sext.w	a0,a5
ffffffffc0206654:	fd61                	bnez	a0,ffffffffc020662c <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0206656:	e5b059e3          	blez	s11,ffffffffc02064a8 <vprintfmt+0x3a>
ffffffffc020665a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020665c:	85a6                	mv	a1,s1
ffffffffc020665e:	02000513          	li	a0,32
ffffffffc0206662:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206664:	e40d82e3          	beqz	s11,ffffffffc02064a8 <vprintfmt+0x3a>
ffffffffc0206668:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020666a:	85a6                	mv	a1,s1
ffffffffc020666c:	02000513          	li	a0,32
ffffffffc0206670:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206672:	fe0d94e3          	bnez	s11,ffffffffc020665a <vprintfmt+0x1ec>
ffffffffc0206676:	bd0d                	j	ffffffffc02064a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206678:	4705                	li	a4,1
ffffffffc020667a:	008a8593          	addi	a1,s5,8
ffffffffc020667e:	01074463          	blt	a4,a6,ffffffffc0206686 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0206682:	0e080863          	beqz	a6,ffffffffc0206772 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0206686:	000ab603          	ld	a2,0(s5)
ffffffffc020668a:	46a1                	li	a3,8
ffffffffc020668c:	8aae                	mv	s5,a1
ffffffffc020668e:	a839                	j	ffffffffc02066ac <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0206690:	03000513          	li	a0,48
ffffffffc0206694:	85a6                	mv	a1,s1
ffffffffc0206696:	e03e                	sd	a5,0(sp)
ffffffffc0206698:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020669a:	85a6                	mv	a1,s1
ffffffffc020669c:	07800513          	li	a0,120
ffffffffc02066a0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02066a2:	0aa1                	addi	s5,s5,8
ffffffffc02066a4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02066a8:	6782                	ld	a5,0(sp)
ffffffffc02066aa:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02066ac:	2781                	sext.w	a5,a5
ffffffffc02066ae:	876e                	mv	a4,s11
ffffffffc02066b0:	85a6                	mv	a1,s1
ffffffffc02066b2:	854a                	mv	a0,s2
ffffffffc02066b4:	d4fff0ef          	jal	ra,ffffffffc0206402 <printnum>
            break;
ffffffffc02066b8:	bbc5                	j	ffffffffc02064a8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02066ba:	00144603          	lbu	a2,1(s0)
ffffffffc02066be:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02066c0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02066c2:	b515                	j	ffffffffc02064e6 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02066c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02066c8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02066ca:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02066cc:	bd29                	j	ffffffffc02064e6 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02066ce:	85a6                	mv	a1,s1
ffffffffc02066d0:	02500513          	li	a0,37
ffffffffc02066d4:	9902                	jalr	s2
            break;
ffffffffc02066d6:	bbc9                	j	ffffffffc02064a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02066d8:	4705                	li	a4,1
ffffffffc02066da:	008a8593          	addi	a1,s5,8
ffffffffc02066de:	01074463          	blt	a4,a6,ffffffffc02066e6 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02066e2:	08080d63          	beqz	a6,ffffffffc020677c <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02066e6:	000ab603          	ld	a2,0(s5)
ffffffffc02066ea:	46a9                	li	a3,10
ffffffffc02066ec:	8aae                	mv	s5,a1
ffffffffc02066ee:	bf7d                	j	ffffffffc02066ac <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02066f0:	85a6                	mv	a1,s1
ffffffffc02066f2:	02500513          	li	a0,37
ffffffffc02066f6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02066f8:	fff44703          	lbu	a4,-1(s0)
ffffffffc02066fc:	02500793          	li	a5,37
ffffffffc0206700:	8d22                	mv	s10,s0
ffffffffc0206702:	daf703e3          	beq	a4,a5,ffffffffc02064a8 <vprintfmt+0x3a>
ffffffffc0206706:	02500713          	li	a4,37
ffffffffc020670a:	1d7d                	addi	s10,s10,-1
ffffffffc020670c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206710:	fee79de3          	bne	a5,a4,ffffffffc020670a <vprintfmt+0x29c>
ffffffffc0206714:	bb51                	j	ffffffffc02064a8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206716:	00003617          	auipc	a2,0x3
ffffffffc020671a:	86260613          	addi	a2,a2,-1950 # ffffffffc0208f78 <error_string+0x1a8>
ffffffffc020671e:	85a6                	mv	a1,s1
ffffffffc0206720:	854a                	mv	a0,s2
ffffffffc0206722:	0ac000ef          	jal	ra,ffffffffc02067ce <printfmt>
ffffffffc0206726:	b349                	j	ffffffffc02064a8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206728:	00003617          	auipc	a2,0x3
ffffffffc020672c:	84860613          	addi	a2,a2,-1976 # ffffffffc0208f70 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206730:	00003417          	auipc	s0,0x3
ffffffffc0206734:	84140413          	addi	s0,s0,-1983 # ffffffffc0208f71 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206738:	8532                	mv	a0,a2
ffffffffc020673a:	85e6                	mv	a1,s9
ffffffffc020673c:	e032                	sd	a2,0(sp)
ffffffffc020673e:	e43e                	sd	a5,8(sp)
ffffffffc0206740:	c19ff0ef          	jal	ra,ffffffffc0206358 <strnlen>
ffffffffc0206744:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206748:	6602                	ld	a2,0(sp)
ffffffffc020674a:	01b05d63          	blez	s11,ffffffffc0206764 <vprintfmt+0x2f6>
ffffffffc020674e:	67a2                	ld	a5,8(sp)
ffffffffc0206750:	2781                	sext.w	a5,a5
ffffffffc0206752:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206754:	6522                	ld	a0,8(sp)
ffffffffc0206756:	85a6                	mv	a1,s1
ffffffffc0206758:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020675a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020675c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020675e:	6602                	ld	a2,0(sp)
ffffffffc0206760:	fe0d9ae3          	bnez	s11,ffffffffc0206754 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206764:	00064783          	lbu	a5,0(a2)
ffffffffc0206768:	0007851b          	sext.w	a0,a5
ffffffffc020676c:	ec0510e3          	bnez	a0,ffffffffc020662c <vprintfmt+0x1be>
ffffffffc0206770:	bb25                	j	ffffffffc02064a8 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0206772:	000ae603          	lwu	a2,0(s5)
ffffffffc0206776:	46a1                	li	a3,8
ffffffffc0206778:	8aae                	mv	s5,a1
ffffffffc020677a:	bf0d                	j	ffffffffc02066ac <vprintfmt+0x23e>
ffffffffc020677c:	000ae603          	lwu	a2,0(s5)
ffffffffc0206780:	46a9                	li	a3,10
ffffffffc0206782:	8aae                	mv	s5,a1
ffffffffc0206784:	b725                	j	ffffffffc02066ac <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0206786:	000aa403          	lw	s0,0(s5)
ffffffffc020678a:	bd35                	j	ffffffffc02065c6 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc020678c:	000ae603          	lwu	a2,0(s5)
ffffffffc0206790:	46c1                	li	a3,16
ffffffffc0206792:	8aae                	mv	s5,a1
ffffffffc0206794:	bf21                	j	ffffffffc02066ac <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0206796:	9902                	jalr	s2
ffffffffc0206798:	bd45                	j	ffffffffc0206648 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc020679a:	85a6                	mv	a1,s1
ffffffffc020679c:	02d00513          	li	a0,45
ffffffffc02067a0:	e03e                	sd	a5,0(sp)
ffffffffc02067a2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02067a4:	8ace                	mv	s5,s3
ffffffffc02067a6:	40800633          	neg	a2,s0
ffffffffc02067aa:	46a9                	li	a3,10
ffffffffc02067ac:	6782                	ld	a5,0(sp)
ffffffffc02067ae:	bdfd                	j	ffffffffc02066ac <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02067b0:	01b05663          	blez	s11,ffffffffc02067bc <vprintfmt+0x34e>
ffffffffc02067b4:	02d00693          	li	a3,45
ffffffffc02067b8:	f6d798e3          	bne	a5,a3,ffffffffc0206728 <vprintfmt+0x2ba>
ffffffffc02067bc:	00002417          	auipc	s0,0x2
ffffffffc02067c0:	7b540413          	addi	s0,s0,1973 # ffffffffc0208f71 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02067c4:	02800513          	li	a0,40
ffffffffc02067c8:	02800793          	li	a5,40
ffffffffc02067cc:	b585                	j	ffffffffc020662c <vprintfmt+0x1be>

ffffffffc02067ce <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02067ce:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02067d0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02067d4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02067d6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02067d8:	ec06                	sd	ra,24(sp)
ffffffffc02067da:	f83a                	sd	a4,48(sp)
ffffffffc02067dc:	fc3e                	sd	a5,56(sp)
ffffffffc02067de:	e0c2                	sd	a6,64(sp)
ffffffffc02067e0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02067e2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02067e4:	c8bff0ef          	jal	ra,ffffffffc020646e <vprintfmt>
}
ffffffffc02067e8:	60e2                	ld	ra,24(sp)
ffffffffc02067ea:	6161                	addi	sp,sp,80
ffffffffc02067ec:	8082                	ret

ffffffffc02067ee <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02067ee:	9e3707b7          	lui	a5,0x9e370
ffffffffc02067f2:	2785                	addiw	a5,a5,1
ffffffffc02067f4:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02067f8:	02000793          	li	a5,32
ffffffffc02067fc:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206800:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206804:	8082                	ret
