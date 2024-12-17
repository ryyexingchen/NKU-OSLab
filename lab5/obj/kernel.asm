
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
ffffffffc020004e:	14c060ef          	jal	ra,ffffffffc020619a <memset>
    cons_init();                // init the console
ffffffffc0200052:	588000ef          	jal	ra,ffffffffc02005da <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	57258593          	addi	a1,a1,1394 # ffffffffc02065c8 <etext>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	58a50513          	addi	a0,a0,1418 # ffffffffc02065e8 <etext+0x20>
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
ffffffffc020007a:	6cc020ef          	jal	ra,ffffffffc0202746 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	527050ef          	jal	ra,ffffffffc0205da4 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4ac000ef          	jal	ra,ffffffffc020052e <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	200030ef          	jal	ra,ffffffffc0203286 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4fc000ef          	jal	ra,ffffffffc0200586 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c0000ef          	jal	ra,ffffffffc020064e <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	65f050ef          	jal	ra,ffffffffc0205ef0 <cpu_idle>

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
ffffffffc02000c4:	16c060ef          	jal	ra,ffffffffc0206230 <vprintfmt>
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
ffffffffc02000f8:	138060ef          	jal	ra,ffffffffc0206230 <vprintfmt>
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
ffffffffc0200172:	48250513          	addi	a0,a0,1154 # ffffffffc02065f0 <etext+0x28>
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
ffffffffc020024a:	3b250513          	addi	a0,a0,946 # ffffffffc02065f8 <etext+0x30>
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
ffffffffc0200260:	18450513          	addi	a0,a0,388 # ffffffffc02073e0 <commands+0xca8>
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
ffffffffc0200292:	38a50513          	addi	a0,a0,906 # ffffffffc0206618 <etext+0x50>
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
ffffffffc02002b2:	13250513          	addi	a0,a0,306 # ffffffffc02073e0 <commands+0xca8>
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
ffffffffc02002c8:	3a450513          	addi	a0,a0,932 # ffffffffc0206668 <etext+0xa0>
void print_kerninfo(void) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002ce:	e03ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d2:	00000597          	auipc	a1,0x0
ffffffffc02002d6:	d6458593          	addi	a1,a1,-668 # ffffffffc0200036 <kern_init>
ffffffffc02002da:	00006517          	auipc	a0,0x6
ffffffffc02002de:	3ae50513          	addi	a0,a0,942 # ffffffffc0206688 <etext+0xc0>
ffffffffc02002e2:	defff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	2e258593          	addi	a1,a1,738 # ffffffffc02065c8 <etext>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	3ba50513          	addi	a0,a0,954 # ffffffffc02066a8 <etext+0xe0>
ffffffffc02002f6:	ddbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fa:	000a1597          	auipc	a1,0xa1
ffffffffc02002fe:	10e58593          	addi	a1,a1,270 # ffffffffc02a1408 <edata>
ffffffffc0200302:	00006517          	auipc	a0,0x6
ffffffffc0200306:	3c650513          	addi	a0,a0,966 # ffffffffc02066c8 <etext+0x100>
ffffffffc020030a:	dc7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020030e:	000ac597          	auipc	a1,0xac
ffffffffc0200312:	68a58593          	addi	a1,a1,1674 # ffffffffc02ac998 <end>
ffffffffc0200316:	00006517          	auipc	a0,0x6
ffffffffc020031a:	3d250513          	addi	a0,a0,978 # ffffffffc02066e8 <etext+0x120>
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
ffffffffc0200348:	3c450513          	addi	a0,a0,964 # ffffffffc0206708 <etext+0x140>
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
ffffffffc0200356:	2e660613          	addi	a2,a2,742 # ffffffffc0206638 <etext+0x70>
ffffffffc020035a:	04d00593          	li	a1,77
ffffffffc020035e:	00006517          	auipc	a0,0x6
ffffffffc0200362:	2f250513          	addi	a0,a0,754 # ffffffffc0206650 <etext+0x88>
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
ffffffffc0200372:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206818 <commands+0xe0>
ffffffffc0200376:	00006597          	auipc	a1,0x6
ffffffffc020037a:	4c258593          	addi	a1,a1,1218 # ffffffffc0206838 <commands+0x100>
ffffffffc020037e:	00006517          	auipc	a0,0x6
ffffffffc0200382:	4c250513          	addi	a0,a0,1218 # ffffffffc0206840 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200386:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200388:	d49ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020038c:	00006617          	auipc	a2,0x6
ffffffffc0200390:	4c460613          	addi	a2,a2,1220 # ffffffffc0206850 <commands+0x118>
ffffffffc0200394:	00006597          	auipc	a1,0x6
ffffffffc0200398:	4e458593          	addi	a1,a1,1252 # ffffffffc0206878 <commands+0x140>
ffffffffc020039c:	00006517          	auipc	a0,0x6
ffffffffc02003a0:	4a450513          	addi	a0,a0,1188 # ffffffffc0206840 <commands+0x108>
ffffffffc02003a4:	d2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003a8:	00006617          	auipc	a2,0x6
ffffffffc02003ac:	4e060613          	addi	a2,a2,1248 # ffffffffc0206888 <commands+0x150>
ffffffffc02003b0:	00006597          	auipc	a1,0x6
ffffffffc02003b4:	4f858593          	addi	a1,a1,1272 # ffffffffc02068a8 <commands+0x170>
ffffffffc02003b8:	00006517          	auipc	a0,0x6
ffffffffc02003bc:	48850513          	addi	a0,a0,1160 # ffffffffc0206840 <commands+0x108>
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
ffffffffc02003f6:	38e50513          	addi	a0,a0,910 # ffffffffc0206780 <commands+0x48>
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
ffffffffc0200418:	39450513          	addi	a0,a0,916 # ffffffffc02067a8 <commands+0x70>
ffffffffc020041c:	cb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200420:	000c0563          	beqz	s8,ffffffffc020042a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200424:	8562                	mv	a0,s8
ffffffffc0200426:	41c000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc020042a:	00006c97          	auipc	s9,0x6
ffffffffc020042e:	30ec8c93          	addi	s9,s9,782 # ffffffffc0206738 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200432:	00006997          	auipc	s3,0x6
ffffffffc0200436:	39e98993          	addi	s3,s3,926 # ffffffffc02067d0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	00006917          	auipc	s2,0x6
ffffffffc020043e:	39e90913          	addi	s2,s2,926 # ffffffffc02067d8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200442:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200444:	00006b17          	auipc	s6,0x6
ffffffffc0200448:	39cb0b13          	addi	s6,s6,924 # ffffffffc02067e0 <commands+0xa8>
    if (argc == 0) {
ffffffffc020044c:	00006a97          	auipc	s5,0x6
ffffffffc0200450:	3eca8a93          	addi	s5,s5,1004 # ffffffffc0206838 <commands+0x100>
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
ffffffffc020046a:	513050ef          	jal	ra,ffffffffc020617c <strchr>
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
ffffffffc0200484:	2b8d0d13          	addi	s10,s10,696 # ffffffffc0206738 <commands>
    if (argc == 0) {
ffffffffc0200488:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048a:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020048c:	0d61                	addi	s10,s10,24
ffffffffc020048e:	4c5050ef          	jal	ra,ffffffffc0206152 <strcmp>
ffffffffc0200492:	c919                	beqz	a0,ffffffffc02004a8 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200494:	2405                	addiw	s0,s0,1
ffffffffc0200496:	09740463          	beq	s0,s7,ffffffffc020051e <kmonitor+0x132>
ffffffffc020049a:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020049e:	6582                	ld	a1,0(sp)
ffffffffc02004a0:	0d61                	addi	s10,s10,24
ffffffffc02004a2:	4b1050ef          	jal	ra,ffffffffc0206152 <strcmp>
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
ffffffffc0200508:	475050ef          	jal	ra,ffffffffc020617c <strchr>
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
ffffffffc0200524:	2e050513          	addi	a0,a0,736 # ffffffffc0206800 <commands+0xc8>
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
ffffffffc0200554:	459050ef          	jal	ra,ffffffffc02061ac <memcpy>
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
ffffffffc020057a:	433050ef          	jal	ra,ffffffffc02061ac <memcpy>
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
ffffffffc02005b0:	30c50513          	addi	a0,a0,780 # ffffffffc02068b8 <commands+0x180>
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
ffffffffc0200680:	58450513          	addi	a0,a0,1412 # ffffffffc0206c00 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	a4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	58c50513          	addi	a0,a0,1420 # ffffffffc0206c18 <commands+0x4e0>
ffffffffc0200694:	a3dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	59650513          	addi	a0,a0,1430 # ffffffffc0206c30 <commands+0x4f8>
ffffffffc02006a2:	a2fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	5a050513          	addi	a0,a0,1440 # ffffffffc0206c48 <commands+0x510>
ffffffffc02006b0:	a21ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206c60 <commands+0x528>
ffffffffc02006be:	a13ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	5b450513          	addi	a0,a0,1460 # ffffffffc0206c78 <commands+0x540>
ffffffffc02006cc:	a05ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	5be50513          	addi	a0,a0,1470 # ffffffffc0206c90 <commands+0x558>
ffffffffc02006da:	9f7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	5c850513          	addi	a0,a0,1480 # ffffffffc0206ca8 <commands+0x570>
ffffffffc02006e8:	9e9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	5d250513          	addi	a0,a0,1490 # ffffffffc0206cc0 <commands+0x588>
ffffffffc02006f6:	9dbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	5dc50513          	addi	a0,a0,1500 # ffffffffc0206cd8 <commands+0x5a0>
ffffffffc0200704:	9cdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	5e650513          	addi	a0,a0,1510 # ffffffffc0206cf0 <commands+0x5b8>
ffffffffc0200712:	9bfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	5f050513          	addi	a0,a0,1520 # ffffffffc0206d08 <commands+0x5d0>
ffffffffc0200720:	9b1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206d20 <commands+0x5e8>
ffffffffc020072e:	9a3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	60450513          	addi	a0,a0,1540 # ffffffffc0206d38 <commands+0x600>
ffffffffc020073c:	995ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	60e50513          	addi	a0,a0,1550 # ffffffffc0206d50 <commands+0x618>
ffffffffc020074a:	987ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	61850513          	addi	a0,a0,1560 # ffffffffc0206d68 <commands+0x630>
ffffffffc0200758:	979ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	62250513          	addi	a0,a0,1570 # ffffffffc0206d80 <commands+0x648>
ffffffffc0200766:	96bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	62c50513          	addi	a0,a0,1580 # ffffffffc0206d98 <commands+0x660>
ffffffffc0200774:	95dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	63650513          	addi	a0,a0,1590 # ffffffffc0206db0 <commands+0x678>
ffffffffc0200782:	94fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	64050513          	addi	a0,a0,1600 # ffffffffc0206dc8 <commands+0x690>
ffffffffc0200790:	941ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	64a50513          	addi	a0,a0,1610 # ffffffffc0206de0 <commands+0x6a8>
ffffffffc020079e:	933ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	65450513          	addi	a0,a0,1620 # ffffffffc0206df8 <commands+0x6c0>
ffffffffc02007ac:	925ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	65e50513          	addi	a0,a0,1630 # ffffffffc0206e10 <commands+0x6d8>
ffffffffc02007ba:	917ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	66850513          	addi	a0,a0,1640 # ffffffffc0206e28 <commands+0x6f0>
ffffffffc02007c8:	909ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	67250513          	addi	a0,a0,1650 # ffffffffc0206e40 <commands+0x708>
ffffffffc02007d6:	8fbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	67c50513          	addi	a0,a0,1660 # ffffffffc0206e58 <commands+0x720>
ffffffffc02007e4:	8edff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	68650513          	addi	a0,a0,1670 # ffffffffc0206e70 <commands+0x738>
ffffffffc02007f2:	8dfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	69050513          	addi	a0,a0,1680 # ffffffffc0206e88 <commands+0x750>
ffffffffc0200800:	8d1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	69a50513          	addi	a0,a0,1690 # ffffffffc0206ea0 <commands+0x768>
ffffffffc020080e:	8c3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	6a450513          	addi	a0,a0,1700 # ffffffffc0206eb8 <commands+0x780>
ffffffffc020081c:	8b5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206ed0 <commands+0x798>
ffffffffc020082a:	8a7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00006517          	auipc	a0,0x6
ffffffffc0200838:	6b450513          	addi	a0,a0,1716 # ffffffffc0206ee8 <commands+0x7b0>
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
ffffffffc020084a:	00006517          	auipc	a0,0x6
ffffffffc020084e:	6b650513          	addi	a0,a0,1718 # ffffffffc0206f00 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	87dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00006517          	auipc	a0,0x6
ffffffffc0200866:	6b650513          	addi	a0,a0,1718 # ffffffffc0206f18 <commands+0x7e0>
ffffffffc020086a:	867ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00006517          	auipc	a0,0x6
ffffffffc0200876:	6be50513          	addi	a0,a0,1726 # ffffffffc0206f30 <commands+0x7f8>
ffffffffc020087a:	857ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00006517          	auipc	a0,0x6
ffffffffc0200886:	6c650513          	addi	a0,a0,1734 # ffffffffc0206f48 <commands+0x810>
ffffffffc020088a:	847ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00006517          	auipc	a0,0x6
ffffffffc020089a:	6c250513          	addi	a0,a0,1730 # ffffffffc0206f58 <commands+0x820>
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
ffffffffc02008e2:	2a250513          	addi	a0,a0,674 # ffffffffc0206b80 <commands+0x448>
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
ffffffffc0200916:	3760206f          	j	ffffffffc0202c8c <do_pgfault>
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
ffffffffc020094c:	3400206f          	j	ffffffffc0202c8c <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00006697          	auipc	a3,0x6
ffffffffc0200954:	25068693          	addi	a3,a3,592 # ffffffffc0206ba0 <commands+0x468>
ffffffffc0200958:	00006617          	auipc	a2,0x6
ffffffffc020095c:	26060613          	addi	a2,a2,608 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0200960:	06b00593          	li	a1,107
ffffffffc0200964:	00006517          	auipc	a0,0x6
ffffffffc0200968:	26c50513          	addi	a0,a0,620 # ffffffffc0206bd0 <commands+0x498>
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
ffffffffc020099e:	1e650513          	addi	a0,a0,486 # ffffffffc0206b80 <commands+0x448>
ffffffffc02009a2:	f2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00006617          	auipc	a2,0x6
ffffffffc02009aa:	24260613          	addi	a2,a2,578 # ffffffffc0206be8 <commands+0x4b0>
ffffffffc02009ae:	07200593          	li	a1,114
ffffffffc02009b2:	00006517          	auipc	a0,0x6
ffffffffc02009b6:	21e50513          	addi	a0,a0,542 # ffffffffc0206bd0 <commands+0x498>
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
ffffffffc02009d6:	f0270713          	addi	a4,a4,-254 # ffffffffc02068d4 <commands+0x19c>
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
ffffffffc02009e8:	15c50513          	addi	a0,a0,348 # ffffffffc0206b40 <commands+0x408>
ffffffffc02009ec:	ee4ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f0:	00006517          	auipc	a0,0x6
ffffffffc02009f4:	13050513          	addi	a0,a0,304 # ffffffffc0206b20 <commands+0x3e8>
ffffffffc02009f8:	ed8ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fc:	00006517          	auipc	a0,0x6
ffffffffc0200a00:	0e450513          	addi	a0,a0,228 # ffffffffc0206ae0 <commands+0x3a8>
ffffffffc0200a04:	eccff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a08:	00006517          	auipc	a0,0x6
ffffffffc0200a0c:	0f850513          	addi	a0,a0,248 # ffffffffc0206b00 <commands+0x3c8>
ffffffffc0200a10:	ec0ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a14:	00006517          	auipc	a0,0x6
ffffffffc0200a18:	14c50513          	addi	a0,a0,332 # ffffffffc0206b60 <commands+0x428>
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
ffffffffc0200a6c:	e9c70713          	addi	a4,a4,-356 # ffffffffc0206904 <commands+0x1cc>
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
ffffffffc0200a88:	fb450513          	addi	a0,a0,-76 # ffffffffc0206a38 <commands+0x300>
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
ffffffffc0200aa2:	5da0506f          	j	ffffffffc020607c <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa6:	00006517          	auipc	a0,0x6
ffffffffc0200aaa:	fb250513          	addi	a0,a0,-78 # ffffffffc0206a58 <commands+0x320>
}
ffffffffc0200aae:	6442                	ld	s0,16(sp)
ffffffffc0200ab0:	60e2                	ld	ra,24(sp)
ffffffffc0200ab2:	64a2                	ld	s1,8(sp)
ffffffffc0200ab4:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab6:	e1aff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aba:	00006517          	auipc	a0,0x6
ffffffffc0200abe:	fbe50513          	addi	a0,a0,-66 # ffffffffc0206a78 <commands+0x340>
ffffffffc0200ac2:	b7f5                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac4:	00006517          	auipc	a0,0x6
ffffffffc0200ac8:	fd450513          	addi	a0,a0,-44 # ffffffffc0206a98 <commands+0x360>
ffffffffc0200acc:	b7cd                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ace:	00006517          	auipc	a0,0x6
ffffffffc0200ad2:	fe250513          	addi	a0,a0,-30 # ffffffffc0206ab0 <commands+0x378>
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
ffffffffc0200af4:	fd850513          	addi	a0,a0,-40 # ffffffffc0206ac8 <commands+0x390>
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
ffffffffc0200b12:	eda60613          	addi	a2,a2,-294 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200b16:	0f800593          	li	a1,248
ffffffffc0200b1a:	00006517          	auipc	a0,0x6
ffffffffc0200b1e:	0b650513          	addi	a0,a0,182 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200b22:	ef2ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	e2250513          	addi	a0,a0,-478 # ffffffffc0206948 <commands+0x210>
ffffffffc0200b2e:	b741                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b30:	00006517          	auipc	a0,0x6
ffffffffc0200b34:	e3850513          	addi	a0,a0,-456 # ffffffffc0206968 <commands+0x230>
ffffffffc0200b38:	bf9d                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b3a:	00006517          	auipc	a0,0x6
ffffffffc0200b3e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206988 <commands+0x250>
ffffffffc0200b42:	b7b5                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b44:	00006517          	auipc	a0,0x6
ffffffffc0200b48:	e5c50513          	addi	a0,a0,-420 # ffffffffc02069a0 <commands+0x268>
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
ffffffffc0200b62:	51a050ef          	jal	ra,ffffffffc020607c <syscall>
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
ffffffffc0200b86:	e2e50513          	addi	a0,a0,-466 # ffffffffc02069b0 <commands+0x278>
ffffffffc0200b8a:	b715                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8c:	00006517          	auipc	a0,0x6
ffffffffc0200b90:	e4450513          	addi	a0,a0,-444 # ffffffffc02069d0 <commands+0x298>
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
ffffffffc0200bae:	e3e60613          	addi	a2,a2,-450 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200bb2:	0cd00593          	li	a1,205
ffffffffc0200bb6:	00006517          	auipc	a0,0x6
ffffffffc0200bba:	01a50513          	addi	a0,a0,26 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200bbe:	e56ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc2:	00006517          	auipc	a0,0x6
ffffffffc0200bc6:	e5e50513          	addi	a0,a0,-418 # ffffffffc0206a20 <commands+0x2e8>
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
ffffffffc0200be6:	e0660613          	addi	a2,a2,-506 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200bea:	0d700593          	li	a1,215
ffffffffc0200bee:	00006517          	auipc	a0,0x6
ffffffffc0200bf2:	fe250513          	addi	a0,a0,-30 # ffffffffc0206bd0 <commands+0x498>
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
ffffffffc0200c08:	e0460613          	addi	a2,a2,-508 # ffffffffc0206a08 <commands+0x2d0>
ffffffffc0200c0c:	0d100593          	li	a1,209
ffffffffc0200c10:	00006517          	auipc	a0,0x6
ffffffffc0200c14:	fc050513          	addi	a0,a0,-64 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200c18:	dfcff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc0200c1c:	b11d                	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c1e:	8522                	mv	a0,s0
ffffffffc0200c20:	c23ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c24:	86a6                	mv	a3,s1
ffffffffc0200c26:	00006617          	auipc	a2,0x6
ffffffffc0200c2a:	dc260613          	addi	a2,a2,-574 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200c2e:	0f100593          	li	a1,241
ffffffffc0200c32:	00006517          	auipc	a0,0x6
ffffffffc0200c36:	f9e50513          	addi	a0,a0,-98 # ffffffffc0206bd0 <commands+0x498>
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
ffffffffc0200cba:	2cc0506f          	j	ffffffffc0205f86 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cbe:	555d                	li	a0,-9
ffffffffc0200cc0:	732040ef          	jal	ra,ffffffffc02053f2 <do_exit>
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
ffffffffc0200e44:	19860613          	addi	a2,a2,408 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc0200e48:	06200593          	li	a1,98
ffffffffc0200e4c:	00006517          	auipc	a0,0x6
ffffffffc0200e50:	1ac50513          	addi	a0,a0,428 # ffffffffc0206ff8 <commands+0x8c0>
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
ffffffffc0200ea8:	37f020ef          	jal	ra,ffffffffc0203a26 <swap_out>
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
ffffffffc0200fee:	1ac050ef          	jal	ra,ffffffffc020619a <memset>
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
ffffffffc0201080:	11a050ef          	jal	ra,ffffffffc020619a <memset>
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
ffffffffc02010da:	eca60613          	addi	a2,a2,-310 # ffffffffc0206fa0 <commands+0x868>
ffffffffc02010de:	0e300593          	li	a1,227
ffffffffc02010e2:	00006517          	auipc	a0,0x6
ffffffffc02010e6:	ee650513          	addi	a0,a0,-282 # ffffffffc0206fc8 <commands+0x890>
ffffffffc02010ea:	92aff0ef          	jal	ra,ffffffffc0200214 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ee:	00006617          	auipc	a2,0x6
ffffffffc02010f2:	eb260613          	addi	a2,a2,-334 # ffffffffc0206fa0 <commands+0x868>
ffffffffc02010f6:	0ee00593          	li	a1,238
ffffffffc02010fa:	00006517          	auipc	a0,0x6
ffffffffc02010fe:	ece50513          	addi	a0,a0,-306 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201102:	912ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201106:	86aa                	mv	a3,a0
ffffffffc0201108:	00006617          	auipc	a2,0x6
ffffffffc020110c:	e9860613          	addi	a2,a2,-360 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0201110:	0eb00593          	li	a1,235
ffffffffc0201114:	00006517          	auipc	a0,0x6
ffffffffc0201118:	eb450513          	addi	a0,a0,-332 # ffffffffc0206fc8 <commands+0x890>
ffffffffc020111c:	8f8ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201120:	86aa                	mv	a3,a0
ffffffffc0201122:	00006617          	auipc	a2,0x6
ffffffffc0201126:	e7e60613          	addi	a2,a2,-386 # ffffffffc0206fa0 <commands+0x868>
ffffffffc020112a:	0df00593          	li	a1,223
ffffffffc020112e:	00006517          	auipc	a0,0x6
ffffffffc0201132:	e9a50513          	addi	a0,a0,-358 # ffffffffc0206fc8 <commands+0x890>
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
ffffffffc020126a:	36268693          	addi	a3,a3,866 # ffffffffc02075c8 <commands+0xe90>
ffffffffc020126e:	00006617          	auipc	a2,0x6
ffffffffc0201272:	94a60613          	addi	a2,a2,-1718 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201276:	11000593          	li	a1,272
ffffffffc020127a:	00006517          	auipc	a0,0x6
ffffffffc020127e:	d4e50513          	addi	a0,a0,-690 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201282:	f93fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201286:	00006697          	auipc	a3,0x6
ffffffffc020128a:	31268693          	addi	a3,a3,786 # ffffffffc0207598 <commands+0xe60>
ffffffffc020128e:	00006617          	auipc	a2,0x6
ffffffffc0201292:	92a60613          	addi	a2,a2,-1750 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201296:	10f00593          	li	a1,271
ffffffffc020129a:	00006517          	auipc	a0,0x6
ffffffffc020129e:	d2e50513          	addi	a0,a0,-722 # ffffffffc0206fc8 <commands+0x890>
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
ffffffffc0201494:	10868693          	addi	a3,a3,264 # ffffffffc0207598 <commands+0xe60>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	72060613          	addi	a2,a2,1824 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02014a0:	12000593          	li	a1,288
ffffffffc02014a4:	00006517          	auipc	a0,0x6
ffffffffc02014a8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0206fc8 <commands+0x890>
ffffffffc02014ac:	d69fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc02014b0:	00006617          	auipc	a2,0x6
ffffffffc02014b4:	af060613          	addi	a2,a2,-1296 # ffffffffc0206fa0 <commands+0x868>
ffffffffc02014b8:	06900593          	li	a1,105
ffffffffc02014bc:	00006517          	auipc	a0,0x6
ffffffffc02014c0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02014c4:	d51fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014c8:	00006617          	auipc	a2,0x6
ffffffffc02014cc:	b1060613          	addi	a2,a2,-1264 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc02014d0:	06200593          	li	a1,98
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02014dc:	d39fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	0e868693          	addi	a3,a3,232 # ffffffffc02075c8 <commands+0xe90>
ffffffffc02014e8:	00005617          	auipc	a2,0x5
ffffffffc02014ec:	6d060613          	addi	a2,a2,1744 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02014f0:	12100593          	li	a1,289
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	ad450513          	addi	a0,a0,-1324 # ffffffffc0206fc8 <commands+0x890>
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
ffffffffc0201636:	ad678793          	addi	a5,a5,-1322 # ffffffffc0208108 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020163a:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020163c:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020163e:	00006517          	auipc	a0,0x6
ffffffffc0201642:	9e250513          	addi	a0,a0,-1566 # ffffffffc0207020 <commands+0x8e8>
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
ffffffffc020168c:	9b050513          	addi	a0,a0,-1616 # ffffffffc0207038 <commands+0x900>
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
ffffffffc02016b0:	9a450513          	addi	a0,a0,-1628 # ffffffffc0207050 <commands+0x918>
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
ffffffffc020175a:	94a50513          	addi	a0,a0,-1718 # ffffffffc02070a0 <commands+0x968>
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
ffffffffc0201774:	94850513          	addi	a0,a0,-1720 # ffffffffc02070b8 <commands+0x980>
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
ffffffffc02019c6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02073c8 <commands+0xc90>
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
ffffffffc0201a72:	a9258593          	addi	a1,a1,-1390 # ffffffffc0207500 <commands+0xdc8>
ffffffffc0201a76:	10000513          	li	a0,256
ffffffffc0201a7a:	6c6040ef          	jal	ra,ffffffffc0206140 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201a7e:	100b0593          	addi	a1,s6,256
ffffffffc0201a82:	10000513          	li	a0,256
ffffffffc0201a86:	6cc040ef          	jal	ra,ffffffffc0206152 <strcmp>
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
ffffffffc0201abe:	63e040ef          	jal	ra,ffffffffc02060fc <strlen>
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
ffffffffc0201b46:	a3650513          	addi	a0,a0,-1482 # ffffffffc0207578 <commands+0xe40>
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
ffffffffc0201b64:	51e0106f          	j	ffffffffc0203082 <kmalloc_init>
ffffffffc0201b68:	6008                	ld	a0,0(s0)
ffffffffc0201b6a:	bd75                	j	ffffffffc0201a26 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b6c:	00006697          	auipc	a3,0x6
ffffffffc0201b70:	87c68693          	addi	a3,a3,-1924 # ffffffffc02073e8 <commands+0xcb0>
ffffffffc0201b74:	00005617          	auipc	a2,0x5
ffffffffc0201b78:	04460613          	addi	a2,a2,68 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201b7c:	22800593          	li	a1,552
ffffffffc0201b80:	00005517          	auipc	a0,0x5
ffffffffc0201b84:	44850513          	addi	a0,a0,1096 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201b88:	e8cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201b8c:	86d6                	mv	a3,s5
ffffffffc0201b8e:	00005617          	auipc	a2,0x5
ffffffffc0201b92:	41260613          	addi	a2,a2,1042 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0201b96:	22800593          	li	a1,552
ffffffffc0201b9a:	00005517          	auipc	a0,0x5
ffffffffc0201b9e:	42e50513          	addi	a0,a0,1070 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201ba2:	e72fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ba6:	00006697          	auipc	a3,0x6
ffffffffc0201baa:	88268693          	addi	a3,a3,-1918 # ffffffffc0207428 <commands+0xcf0>
ffffffffc0201bae:	00005617          	auipc	a2,0x5
ffffffffc0201bb2:	00a60613          	addi	a2,a2,10 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201bb6:	22900593          	li	a1,553
ffffffffc0201bba:	00005517          	auipc	a0,0x5
ffffffffc0201bbe:	40e50513          	addi	a0,a0,1038 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201bc2:	e52fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201bc6:	a78ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201bca:	00005617          	auipc	a2,0x5
ffffffffc0201bce:	3d660613          	addi	a2,a2,982 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0201bd2:	06900593          	li	a1,105
ffffffffc0201bd6:	00005517          	auipc	a0,0x5
ffffffffc0201bda:	42250513          	addi	a0,a0,1058 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0201bde:	e36fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201be2:	00005617          	auipc	a2,0x5
ffffffffc0201be6:	5d660613          	addi	a2,a2,1494 # ffffffffc02071b8 <commands+0xa80>
ffffffffc0201bea:	07400593          	li	a1,116
ffffffffc0201bee:	00005517          	auipc	a0,0x5
ffffffffc0201bf2:	40a50513          	addi	a0,a0,1034 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0201bf6:	e1efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201bfa:	00005697          	auipc	a3,0x5
ffffffffc0201bfe:	4fe68693          	addi	a3,a3,1278 # ffffffffc02070f8 <commands+0x9c0>
ffffffffc0201c02:	00005617          	auipc	a2,0x5
ffffffffc0201c06:	fb660613          	addi	a2,a2,-74 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c0a:	1ec00593          	li	a1,492
ffffffffc0201c0e:	00005517          	auipc	a0,0x5
ffffffffc0201c12:	3ba50513          	addi	a0,a0,954 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201c16:	dfefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c1a:	00005697          	auipc	a3,0x5
ffffffffc0201c1e:	5c668693          	addi	a3,a3,1478 # ffffffffc02071e0 <commands+0xaa8>
ffffffffc0201c22:	00005617          	auipc	a2,0x5
ffffffffc0201c26:	f9660613          	addi	a2,a2,-106 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c2a:	20800593          	li	a1,520
ffffffffc0201c2e:	00005517          	auipc	a0,0x5
ffffffffc0201c32:	39a50513          	addi	a0,a0,922 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201c36:	ddefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c3a:	00006697          	auipc	a3,0x6
ffffffffc0201c3e:	81e68693          	addi	a3,a3,-2018 # ffffffffc0207458 <commands+0xd20>
ffffffffc0201c42:	00005617          	auipc	a2,0x5
ffffffffc0201c46:	f7660613          	addi	a2,a2,-138 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c4a:	23100593          	li	a1,561
ffffffffc0201c4e:	00005517          	auipc	a0,0x5
ffffffffc0201c52:	37a50513          	addi	a0,a0,890 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201c56:	dbefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201c5a:	00005697          	auipc	a3,0x5
ffffffffc0201c5e:	61668693          	addi	a3,a3,1558 # ffffffffc0207270 <commands+0xb38>
ffffffffc0201c62:	00005617          	auipc	a2,0x5
ffffffffc0201c66:	f5660613          	addi	a2,a2,-170 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c6a:	20700593          	li	a1,519
ffffffffc0201c6e:	00005517          	auipc	a0,0x5
ffffffffc0201c72:	35a50513          	addi	a0,a0,858 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201c76:	d9efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201c7a:	00005697          	auipc	a3,0x5
ffffffffc0201c7e:	6be68693          	addi	a3,a3,1726 # ffffffffc0207338 <commands+0xc00>
ffffffffc0201c82:	00005617          	auipc	a2,0x5
ffffffffc0201c86:	f3660613          	addi	a2,a2,-202 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c8a:	20600593          	li	a1,518
ffffffffc0201c8e:	00005517          	auipc	a0,0x5
ffffffffc0201c92:	33a50513          	addi	a0,a0,826 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201c96:	d7efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201c9a:	00005697          	auipc	a3,0x5
ffffffffc0201c9e:	68668693          	addi	a3,a3,1670 # ffffffffc0207320 <commands+0xbe8>
ffffffffc0201ca2:	00005617          	auipc	a2,0x5
ffffffffc0201ca6:	f1660613          	addi	a2,a2,-234 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201caa:	20500593          	li	a1,517
ffffffffc0201cae:	00005517          	auipc	a0,0x5
ffffffffc0201cb2:	31a50513          	addi	a0,a0,794 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201cb6:	d5efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201cba:	00005697          	auipc	a3,0x5
ffffffffc0201cbe:	63668693          	addi	a3,a3,1590 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0201cc2:	00005617          	auipc	a2,0x5
ffffffffc0201cc6:	ef660613          	addi	a2,a2,-266 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201cca:	20400593          	li	a1,516
ffffffffc0201cce:	00005517          	auipc	a0,0x5
ffffffffc0201cd2:	2fa50513          	addi	a0,a0,762 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201cd6:	d3efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201cda:	00005697          	auipc	a3,0x5
ffffffffc0201cde:	5fe68693          	addi	a3,a3,1534 # ffffffffc02072d8 <commands+0xba0>
ffffffffc0201ce2:	00005617          	auipc	a2,0x5
ffffffffc0201ce6:	ed660613          	addi	a2,a2,-298 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201cea:	20200593          	li	a1,514
ffffffffc0201cee:	00005517          	auipc	a0,0x5
ffffffffc0201cf2:	2da50513          	addi	a0,a0,730 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201cf6:	d1efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201cfa:	00005697          	auipc	a3,0x5
ffffffffc0201cfe:	5c668693          	addi	a3,a3,1478 # ffffffffc02072c0 <commands+0xb88>
ffffffffc0201d02:	00005617          	auipc	a2,0x5
ffffffffc0201d06:	eb660613          	addi	a2,a2,-330 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201d0a:	20100593          	li	a1,513
ffffffffc0201d0e:	00005517          	auipc	a0,0x5
ffffffffc0201d12:	2ba50513          	addi	a0,a0,698 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201d16:	cfefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d1a:	00005697          	auipc	a3,0x5
ffffffffc0201d1e:	59668693          	addi	a3,a3,1430 # ffffffffc02072b0 <commands+0xb78>
ffffffffc0201d22:	00005617          	auipc	a2,0x5
ffffffffc0201d26:	e9660613          	addi	a2,a2,-362 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201d2a:	20000593          	li	a1,512
ffffffffc0201d2e:	00005517          	auipc	a0,0x5
ffffffffc0201d32:	29a50513          	addi	a0,a0,666 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201d36:	cdefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d3a:	00005697          	auipc	a3,0x5
ffffffffc0201d3e:	56668693          	addi	a3,a3,1382 # ffffffffc02072a0 <commands+0xb68>
ffffffffc0201d42:	00005617          	auipc	a2,0x5
ffffffffc0201d46:	e7660613          	addi	a2,a2,-394 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201d4a:	1ff00593          	li	a1,511
ffffffffc0201d4e:	00005517          	auipc	a0,0x5
ffffffffc0201d52:	27a50513          	addi	a0,a0,634 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201d56:	cbefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d5a:	00005697          	auipc	a3,0x5
ffffffffc0201d5e:	51668693          	addi	a3,a3,1302 # ffffffffc0207270 <commands+0xb38>
ffffffffc0201d62:	00005617          	auipc	a2,0x5
ffffffffc0201d66:	e5660613          	addi	a2,a2,-426 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201d6a:	1fe00593          	li	a1,510
ffffffffc0201d6e:	00005517          	auipc	a0,0x5
ffffffffc0201d72:	25a50513          	addi	a0,a0,602 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201d76:	c9efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d7a:	00005697          	auipc	a3,0x5
ffffffffc0201d7e:	4be68693          	addi	a3,a3,1214 # ffffffffc0207238 <commands+0xb00>
ffffffffc0201d82:	00005617          	auipc	a2,0x5
ffffffffc0201d86:	e3660613          	addi	a2,a2,-458 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201d8a:	1fd00593          	li	a1,509
ffffffffc0201d8e:	00005517          	auipc	a0,0x5
ffffffffc0201d92:	23a50513          	addi	a0,a0,570 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201d96:	c7efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d9a:	00005697          	auipc	a3,0x5
ffffffffc0201d9e:	47668693          	addi	a3,a3,1142 # ffffffffc0207210 <commands+0xad8>
ffffffffc0201da2:	00005617          	auipc	a2,0x5
ffffffffc0201da6:	e1660613          	addi	a2,a2,-490 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201daa:	1fa00593          	li	a1,506
ffffffffc0201dae:	00005517          	auipc	a0,0x5
ffffffffc0201db2:	21a50513          	addi	a0,a0,538 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201db6:	c5efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201dba:	86da                	mv	a3,s6
ffffffffc0201dbc:	00005617          	auipc	a2,0x5
ffffffffc0201dc0:	1e460613          	addi	a2,a2,484 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0201dc4:	1f900593          	li	a1,505
ffffffffc0201dc8:	00005517          	auipc	a0,0x5
ffffffffc0201dcc:	20050513          	addi	a0,a0,512 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201dd0:	c44fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201dd4:	86be                	mv	a3,a5
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	1ca60613          	addi	a2,a2,458 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0201dde:	06900593          	li	a1,105
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	21650513          	addi	a0,a0,534 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0201dea:	c2afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dee:	00005697          	auipc	a3,0x5
ffffffffc0201df2:	59268693          	addi	a3,a3,1426 # ffffffffc0207380 <commands+0xc48>
ffffffffc0201df6:	00005617          	auipc	a2,0x5
ffffffffc0201dfa:	dc260613          	addi	a2,a2,-574 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201dfe:	21300593          	li	a1,531
ffffffffc0201e02:	00005517          	auipc	a0,0x5
ffffffffc0201e06:	1c650513          	addi	a0,a0,454 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201e0a:	c0afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e0e:	00005697          	auipc	a3,0x5
ffffffffc0201e12:	52a68693          	addi	a3,a3,1322 # ffffffffc0207338 <commands+0xc00>
ffffffffc0201e16:	00005617          	auipc	a2,0x5
ffffffffc0201e1a:	da260613          	addi	a2,a2,-606 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201e1e:	21100593          	li	a1,529
ffffffffc0201e22:	00005517          	auipc	a0,0x5
ffffffffc0201e26:	1a650513          	addi	a0,a0,422 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201e2a:	beafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e2e:	00005697          	auipc	a3,0x5
ffffffffc0201e32:	53a68693          	addi	a3,a3,1338 # ffffffffc0207368 <commands+0xc30>
ffffffffc0201e36:	00005617          	auipc	a2,0x5
ffffffffc0201e3a:	d8260613          	addi	a2,a2,-638 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201e3e:	21000593          	li	a1,528
ffffffffc0201e42:	00005517          	auipc	a0,0x5
ffffffffc0201e46:	18650513          	addi	a0,a0,390 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201e4a:	bcafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201e4e:	00005697          	auipc	a3,0x5
ffffffffc0201e52:	69a68693          	addi	a3,a3,1690 # ffffffffc02074e8 <commands+0xdb0>
ffffffffc0201e56:	00005617          	auipc	a2,0x5
ffffffffc0201e5a:	d6260613          	addi	a2,a2,-670 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201e5e:	23400593          	li	a1,564
ffffffffc0201e62:	00005517          	auipc	a0,0x5
ffffffffc0201e66:	16650513          	addi	a0,a0,358 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201e6a:	baafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e6e:	00005697          	auipc	a3,0x5
ffffffffc0201e72:	63a68693          	addi	a3,a3,1594 # ffffffffc02074a8 <commands+0xd70>
ffffffffc0201e76:	00005617          	auipc	a2,0x5
ffffffffc0201e7a:	d4260613          	addi	a2,a2,-702 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201e7e:	23300593          	li	a1,563
ffffffffc0201e82:	00005517          	auipc	a0,0x5
ffffffffc0201e86:	14650513          	addi	a0,a0,326 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201e8a:	b8afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201e8e:	00005697          	auipc	a3,0x5
ffffffffc0201e92:	60268693          	addi	a3,a3,1538 # ffffffffc0207490 <commands+0xd58>
ffffffffc0201e96:	00005617          	auipc	a2,0x5
ffffffffc0201e9a:	d2260613          	addi	a2,a2,-734 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201e9e:	23200593          	li	a1,562
ffffffffc0201ea2:	00005517          	auipc	a0,0x5
ffffffffc0201ea6:	12650513          	addi	a0,a0,294 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201eaa:	b6afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201eae:	86be                	mv	a3,a5
ffffffffc0201eb0:	00005617          	auipc	a2,0x5
ffffffffc0201eb4:	0f060613          	addi	a2,a2,240 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0201eb8:	1f800593          	li	a1,504
ffffffffc0201ebc:	00005517          	auipc	a0,0x5
ffffffffc0201ec0:	10c50513          	addi	a0,a0,268 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201ec4:	b50fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201ec8:	00005617          	auipc	a2,0x5
ffffffffc0201ecc:	1b060613          	addi	a2,a2,432 # ffffffffc0207078 <commands+0x940>
ffffffffc0201ed0:	07f00593          	li	a1,127
ffffffffc0201ed4:	00005517          	auipc	a0,0x5
ffffffffc0201ed8:	0f450513          	addi	a0,a0,244 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201edc:	b38fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ee0:	00005697          	auipc	a3,0x5
ffffffffc0201ee4:	63868693          	addi	a3,a3,1592 # ffffffffc0207518 <commands+0xde0>
ffffffffc0201ee8:	00005617          	auipc	a2,0x5
ffffffffc0201eec:	cd060613          	addi	a2,a2,-816 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201ef0:	23800593          	li	a1,568
ffffffffc0201ef4:	00005517          	auipc	a0,0x5
ffffffffc0201ef8:	0d450513          	addi	a0,a0,212 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201efc:	b18fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201f00:	00005697          	auipc	a3,0x5
ffffffffc0201f04:	4a868693          	addi	a3,a3,1192 # ffffffffc02073a8 <commands+0xc70>
ffffffffc0201f08:	00005617          	auipc	a2,0x5
ffffffffc0201f0c:	cb060613          	addi	a2,a2,-848 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201f10:	24400593          	li	a1,580
ffffffffc0201f14:	00005517          	auipc	a0,0x5
ffffffffc0201f18:	0b450513          	addi	a0,a0,180 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201f1c:	af8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201f20:	00005697          	auipc	a3,0x5
ffffffffc0201f24:	2d868693          	addi	a3,a3,728 # ffffffffc02071f8 <commands+0xac0>
ffffffffc0201f28:	00005617          	auipc	a2,0x5
ffffffffc0201f2c:	c9060613          	addi	a2,a2,-880 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201f30:	1f600593          	li	a1,502
ffffffffc0201f34:	00005517          	auipc	a0,0x5
ffffffffc0201f38:	09450513          	addi	a0,a0,148 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201f3c:	ad8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f40:	00005697          	auipc	a3,0x5
ffffffffc0201f44:	2a068693          	addi	a3,a3,672 # ffffffffc02071e0 <commands+0xaa8>
ffffffffc0201f48:	00005617          	auipc	a2,0x5
ffffffffc0201f4c:	c7060613          	addi	a2,a2,-912 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201f50:	1f500593          	li	a1,501
ffffffffc0201f54:	00005517          	auipc	a0,0x5
ffffffffc0201f58:	07450513          	addi	a0,a0,116 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201f5c:	ab8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201f60:	00005697          	auipc	a3,0x5
ffffffffc0201f64:	1d068693          	addi	a3,a3,464 # ffffffffc0207130 <commands+0x9f8>
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	c5060613          	addi	a2,a2,-944 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201f70:	1ed00593          	li	a1,493
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	05450513          	addi	a0,a0,84 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201f7c:	a98fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201f80:	00005697          	auipc	a3,0x5
ffffffffc0201f84:	20868693          	addi	a3,a3,520 # ffffffffc0207188 <commands+0xa50>
ffffffffc0201f88:	00005617          	auipc	a2,0x5
ffffffffc0201f8c:	c3060613          	addi	a2,a2,-976 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201f90:	1f400593          	li	a1,500
ffffffffc0201f94:	00005517          	auipc	a0,0x5
ffffffffc0201f98:	03450513          	addi	a0,a0,52 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201f9c:	a78fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201fa0:	00005697          	auipc	a3,0x5
ffffffffc0201fa4:	1b868693          	addi	a3,a3,440 # ffffffffc0207158 <commands+0xa20>
ffffffffc0201fa8:	00005617          	auipc	a2,0x5
ffffffffc0201fac:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201fb0:	1f100593          	li	a1,497
ffffffffc0201fb4:	00005517          	auipc	a0,0x5
ffffffffc0201fb8:	01450513          	addi	a0,a0,20 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201fbc:	a58fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201fc0:	00005697          	auipc	a3,0x5
ffffffffc0201fc4:	37868693          	addi	a3,a3,888 # ffffffffc0207338 <commands+0xc00>
ffffffffc0201fc8:	00005617          	auipc	a2,0x5
ffffffffc0201fcc:	bf060613          	addi	a2,a2,-1040 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201fd0:	20d00593          	li	a1,525
ffffffffc0201fd4:	00005517          	auipc	a0,0x5
ffffffffc0201fd8:	ff450513          	addi	a0,a0,-12 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201fdc:	a38fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201fe0:	00005697          	auipc	a3,0x5
ffffffffc0201fe4:	21868693          	addi	a3,a3,536 # ffffffffc02071f8 <commands+0xac0>
ffffffffc0201fe8:	00005617          	auipc	a2,0x5
ffffffffc0201fec:	bd060613          	addi	a2,a2,-1072 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201ff0:	20c00593          	li	a1,524
ffffffffc0201ff4:	00005517          	auipc	a0,0x5
ffffffffc0201ff8:	fd450513          	addi	a0,a0,-44 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0201ffc:	a18fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202000:	00005697          	auipc	a3,0x5
ffffffffc0202004:	35068693          	addi	a3,a3,848 # ffffffffc0207350 <commands+0xc18>
ffffffffc0202008:	00005617          	auipc	a2,0x5
ffffffffc020200c:	bb060613          	addi	a2,a2,-1104 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202010:	20900593          	li	a1,521
ffffffffc0202014:	00005517          	auipc	a0,0x5
ffffffffc0202018:	fb450513          	addi	a0,a0,-76 # ffffffffc0206fc8 <commands+0x890>
ffffffffc020201c:	9f8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202020:	00005697          	auipc	a3,0x5
ffffffffc0202024:	53068693          	addi	a3,a3,1328 # ffffffffc0207550 <commands+0xe18>
ffffffffc0202028:	00005617          	auipc	a2,0x5
ffffffffc020202c:	b9060613          	addi	a2,a2,-1136 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202030:	23b00593          	li	a1,571
ffffffffc0202034:	00005517          	auipc	a0,0x5
ffffffffc0202038:	f9450513          	addi	a0,a0,-108 # ffffffffc0206fc8 <commands+0x890>
ffffffffc020203c:	9d8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202040:	00005697          	auipc	a3,0x5
ffffffffc0202044:	36868693          	addi	a3,a3,872 # ffffffffc02073a8 <commands+0xc70>
ffffffffc0202048:	00005617          	auipc	a2,0x5
ffffffffc020204c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202050:	21b00593          	li	a1,539
ffffffffc0202054:	00005517          	auipc	a0,0x5
ffffffffc0202058:	f7450513          	addi	a0,a0,-140 # ffffffffc0206fc8 <commands+0x890>
ffffffffc020205c:	9b8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202060:	00005697          	auipc	a3,0x5
ffffffffc0202064:	3e068693          	addi	a3,a3,992 # ffffffffc0207440 <commands+0xd08>
ffffffffc0202068:	00005617          	auipc	a2,0x5
ffffffffc020206c:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202070:	22d00593          	li	a1,557
ffffffffc0202074:	00005517          	auipc	a0,0x5
ffffffffc0202078:	f5450513          	addi	a0,a0,-172 # ffffffffc0206fc8 <commands+0x890>
ffffffffc020207c:	998fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202080:	00005697          	auipc	a3,0x5
ffffffffc0202084:	05868693          	addi	a3,a3,88 # ffffffffc02070d8 <commands+0x9a0>
ffffffffc0202088:	00005617          	auipc	a2,0x5
ffffffffc020208c:	b3060613          	addi	a2,a2,-1232 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202090:	1eb00593          	li	a1,491
ffffffffc0202094:	00005517          	auipc	a0,0x5
ffffffffc0202098:	f3450513          	addi	a0,a0,-204 # ffffffffc0206fc8 <commands+0x890>
ffffffffc020209c:	978fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	fd860613          	addi	a2,a2,-40 # ffffffffc0207078 <commands+0x940>
ffffffffc02020a8:	0c100593          	li	a1,193
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	f1c50513          	addi	a0,a0,-228 # ffffffffc0206fc8 <commands+0x890>
ffffffffc02020b4:	960fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02020b8 <copy_range>:
               bool share) {
ffffffffc02020b8:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020ba:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02020be:	f486                	sd	ra,104(sp)
ffffffffc02020c0:	f0a2                	sd	s0,96(sp)
ffffffffc02020c2:	eca6                	sd	s1,88(sp)
ffffffffc02020c4:	e8ca                	sd	s2,80(sp)
ffffffffc02020c6:	e4ce                	sd	s3,72(sp)
ffffffffc02020c8:	e0d2                	sd	s4,64(sp)
ffffffffc02020ca:	fc56                	sd	s5,56(sp)
ffffffffc02020cc:	f85a                	sd	s6,48(sp)
ffffffffc02020ce:	f45e                	sd	s7,40(sp)
ffffffffc02020d0:	f062                	sd	s8,32(sp)
ffffffffc02020d2:	ec66                	sd	s9,24(sp)
ffffffffc02020d4:	e86a                	sd	s10,16(sp)
ffffffffc02020d6:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020d8:	03479713          	slli	a4,a5,0x34
ffffffffc02020dc:	1e071863          	bnez	a4,ffffffffc02022cc <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02020e0:	002007b7          	lui	a5,0x200
ffffffffc02020e4:	8432                	mv	s0,a2
ffffffffc02020e6:	16f66b63          	bltu	a2,a5,ffffffffc020225c <copy_range+0x1a4>
ffffffffc02020ea:	84b6                	mv	s1,a3
ffffffffc02020ec:	16d67863          	bgeu	a2,a3,ffffffffc020225c <copy_range+0x1a4>
ffffffffc02020f0:	4785                	li	a5,1
ffffffffc02020f2:	07fe                	slli	a5,a5,0x1f
ffffffffc02020f4:	16d7e463          	bltu	a5,a3,ffffffffc020225c <copy_range+0x1a4>
ffffffffc02020f8:	5a7d                	li	s4,-1
ffffffffc02020fa:	8aaa                	mv	s5,a0
ffffffffc02020fc:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02020fe:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202100:	000aac17          	auipc	s8,0xaa
ffffffffc0202104:	720c0c13          	addi	s8,s8,1824 # ffffffffc02ac820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202108:	000aab97          	auipc	s7,0xaa
ffffffffc020210c:	780b8b93          	addi	s7,s7,1920 # ffffffffc02ac888 <pages>
    return page - pages + nbase;
ffffffffc0202110:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202114:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202118:	4601                	li	a2,0
ffffffffc020211a:	85a2                	mv	a1,s0
ffffffffc020211c:	854a                	mv	a0,s2
ffffffffc020211e:	e4bfe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0202122:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc0202124:	c17d                	beqz	a0,ffffffffc020220a <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc0202126:	611c                	ld	a5,0(a0)
ffffffffc0202128:	8b85                	andi	a5,a5,1
ffffffffc020212a:	e785                	bnez	a5,ffffffffc0202152 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc020212c:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc020212e:	fe9465e3          	bltu	s0,s1,ffffffffc0202118 <copy_range+0x60>
    return 0;
ffffffffc0202132:	4501                	li	a0,0
}
ffffffffc0202134:	70a6                	ld	ra,104(sp)
ffffffffc0202136:	7406                	ld	s0,96(sp)
ffffffffc0202138:	64e6                	ld	s1,88(sp)
ffffffffc020213a:	6946                	ld	s2,80(sp)
ffffffffc020213c:	69a6                	ld	s3,72(sp)
ffffffffc020213e:	6a06                	ld	s4,64(sp)
ffffffffc0202140:	7ae2                	ld	s5,56(sp)
ffffffffc0202142:	7b42                	ld	s6,48(sp)
ffffffffc0202144:	7ba2                	ld	s7,40(sp)
ffffffffc0202146:	7c02                	ld	s8,32(sp)
ffffffffc0202148:	6ce2                	ld	s9,24(sp)
ffffffffc020214a:	6d42                	ld	s10,16(sp)
ffffffffc020214c:	6da2                	ld	s11,8(sp)
ffffffffc020214e:	6165                	addi	sp,sp,112
ffffffffc0202150:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0202152:	4605                	li	a2,1
ffffffffc0202154:	85a2                	mv	a1,s0
ffffffffc0202156:	8556                	mv	a0,s5
ffffffffc0202158:	e11fe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc020215c:	c169                	beqz	a0,ffffffffc020221e <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020215e:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0202162:	0017f713          	andi	a4,a5,1
ffffffffc0202166:	01f7fc93          	andi	s9,a5,31
ffffffffc020216a:	14070563          	beqz	a4,ffffffffc02022b4 <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc020216e:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202172:	078a                	slli	a5,a5,0x2
ffffffffc0202174:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202178:	12d77263          	bgeu	a4,a3,ffffffffc020229c <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc020217c:	000bb783          	ld	a5,0(s7)
ffffffffc0202180:	fff806b7          	lui	a3,0xfff80
ffffffffc0202184:	9736                	add	a4,a4,a3
ffffffffc0202186:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc0202188:	4505                	li	a0,1
ffffffffc020218a:	00e78db3          	add	s11,a5,a4
ffffffffc020218e:	ccdfe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0202192:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0202194:	0a0d8463          	beqz	s11,ffffffffc020223c <copy_range+0x184>
            assert(npage != NULL);
ffffffffc0202198:	c175                	beqz	a0,ffffffffc020227c <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc020219a:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc020219e:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02021a2:	40ed86b3          	sub	a3,s11,a4
ffffffffc02021a6:	8699                	srai	a3,a3,0x6
ffffffffc02021a8:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02021aa:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02021ae:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021b0:	06c7fa63          	bgeu	a5,a2,ffffffffc0202224 <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02021b4:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02021b8:	000aa717          	auipc	a4,0xaa
ffffffffc02021bc:	6c070713          	addi	a4,a4,1728 # ffffffffc02ac878 <va_pa_offset>
ffffffffc02021c0:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02021c2:	8799                	srai	a5,a5,0x6
ffffffffc02021c4:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02021c6:	0147f733          	and	a4,a5,s4
ffffffffc02021ca:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02021ce:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02021d0:	04c77963          	bgeu	a4,a2,ffffffffc0202222 <copy_range+0x16a>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE); // 复制附近成的页面内容到子进程的页面中
ffffffffc02021d4:	6605                	lui	a2,0x1
ffffffffc02021d6:	953e                	add	a0,a0,a5
ffffffffc02021d8:	7d5030ef          	jal	ra,ffffffffc02061ac <memcpy>
            ret = page_insert(to, npage, start, perm); // 建立子进程页面虚拟地址到物理地址的映射关系
ffffffffc02021dc:	86e6                	mv	a3,s9
ffffffffc02021de:	8622                	mv	a2,s0
ffffffffc02021e0:	85ea                	mv	a1,s10
ffffffffc02021e2:	8556                	mv	a0,s5
ffffffffc02021e4:	b90ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
            assert(ret == 0);
ffffffffc02021e8:	d131                	beqz	a0,ffffffffc020212c <copy_range+0x74>
ffffffffc02021ea:	00005697          	auipc	a3,0x5
ffffffffc02021ee:	da668693          	addi	a3,a3,-602 # ffffffffc0206f90 <commands+0x858>
ffffffffc02021f2:	00005617          	auipc	a2,0x5
ffffffffc02021f6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02021fa:	18d00593          	li	a1,397
ffffffffc02021fe:	00005517          	auipc	a0,0x5
ffffffffc0202202:	dca50513          	addi	a0,a0,-566 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0202206:	80efe0ef          	jal	ra,ffffffffc0200214 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020220a:	002007b7          	lui	a5,0x200
ffffffffc020220e:	943e                	add	s0,s0,a5
ffffffffc0202210:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202214:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0202216:	dc11                	beqz	s0,ffffffffc0202132 <copy_range+0x7a>
ffffffffc0202218:	f09460e3          	bltu	s0,s1,ffffffffc0202118 <copy_range+0x60>
ffffffffc020221c:	bf19                	j	ffffffffc0202132 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc020221e:	5571                	li	a0,-4
ffffffffc0202220:	bf11                	j	ffffffffc0202134 <copy_range+0x7c>
ffffffffc0202222:	86be                	mv	a3,a5
ffffffffc0202224:	00005617          	auipc	a2,0x5
ffffffffc0202228:	d7c60613          	addi	a2,a2,-644 # ffffffffc0206fa0 <commands+0x868>
ffffffffc020222c:	06900593          	li	a1,105
ffffffffc0202230:	00005517          	auipc	a0,0x5
ffffffffc0202234:	dc850513          	addi	a0,a0,-568 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0202238:	fddfd0ef          	jal	ra,ffffffffc0200214 <__panic>
            assert(page != NULL);
ffffffffc020223c:	00005697          	auipc	a3,0x5
ffffffffc0202240:	d3468693          	addi	a3,a3,-716 # ffffffffc0206f70 <commands+0x838>
ffffffffc0202244:	00005617          	auipc	a2,0x5
ffffffffc0202248:	97460613          	addi	a2,a2,-1676 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020224c:	17200593          	li	a1,370
ffffffffc0202250:	00005517          	auipc	a0,0x5
ffffffffc0202254:	d7850513          	addi	a0,a0,-648 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0202258:	fbdfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020225c:	00005697          	auipc	a3,0x5
ffffffffc0202260:	36c68693          	addi	a3,a3,876 # ffffffffc02075c8 <commands+0xe90>
ffffffffc0202264:	00005617          	auipc	a2,0x5
ffffffffc0202268:	95460613          	addi	a2,a2,-1708 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020226c:	15e00593          	li	a1,350
ffffffffc0202270:	00005517          	auipc	a0,0x5
ffffffffc0202274:	d5850513          	addi	a0,a0,-680 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0202278:	f9dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
            assert(npage != NULL);
ffffffffc020227c:	00005697          	auipc	a3,0x5
ffffffffc0202280:	d0468693          	addi	a3,a3,-764 # ffffffffc0206f80 <commands+0x848>
ffffffffc0202284:	00005617          	auipc	a2,0x5
ffffffffc0202288:	93460613          	addi	a2,a2,-1740 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020228c:	17300593          	li	a1,371
ffffffffc0202290:	00005517          	auipc	a0,0x5
ffffffffc0202294:	d3850513          	addi	a0,a0,-712 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0202298:	f7dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020229c:	00005617          	auipc	a2,0x5
ffffffffc02022a0:	d3c60613          	addi	a2,a2,-708 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc02022a4:	06200593          	li	a1,98
ffffffffc02022a8:	00005517          	auipc	a0,0x5
ffffffffc02022ac:	d5050513          	addi	a0,a0,-688 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02022b0:	f65fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02022b4:	00005617          	auipc	a2,0x5
ffffffffc02022b8:	f0460613          	addi	a2,a2,-252 # ffffffffc02071b8 <commands+0xa80>
ffffffffc02022bc:	07400593          	li	a1,116
ffffffffc02022c0:	00005517          	auipc	a0,0x5
ffffffffc02022c4:	d3850513          	addi	a0,a0,-712 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02022c8:	f4dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022cc:	00005697          	auipc	a3,0x5
ffffffffc02022d0:	2cc68693          	addi	a3,a3,716 # ffffffffc0207598 <commands+0xe60>
ffffffffc02022d4:	00005617          	auipc	a2,0x5
ffffffffc02022d8:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02022dc:	15d00593          	li	a1,349
ffffffffc02022e0:	00005517          	auipc	a0,0x5
ffffffffc02022e4:	ce850513          	addi	a0,a0,-792 # ffffffffc0206fc8 <commands+0x890>
ffffffffc02022e8:	f2dfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02022ec <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022ec:	12058073          	sfence.vma	a1
}
ffffffffc02022f0:	8082                	ret

ffffffffc02022f2 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02022f2:	7179                	addi	sp,sp,-48
ffffffffc02022f4:	e84a                	sd	s2,16(sp)
ffffffffc02022f6:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02022f8:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02022fa:	f022                	sd	s0,32(sp)
ffffffffc02022fc:	ec26                	sd	s1,24(sp)
ffffffffc02022fe:	e44e                	sd	s3,8(sp)
ffffffffc0202300:	f406                	sd	ra,40(sp)
ffffffffc0202302:	84ae                	mv	s1,a1
ffffffffc0202304:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202306:	b55fe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020230a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020230c:	cd1d                	beqz	a0,ffffffffc020234a <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020230e:	85aa                	mv	a1,a0
ffffffffc0202310:	86ce                	mv	a3,s3
ffffffffc0202312:	8626                	mv	a2,s1
ffffffffc0202314:	854a                	mv	a0,s2
ffffffffc0202316:	a5eff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc020231a:	e121                	bnez	a0,ffffffffc020235a <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc020231c:	000aa797          	auipc	a5,0xaa
ffffffffc0202320:	52478793          	addi	a5,a5,1316 # ffffffffc02ac840 <swap_init_ok>
ffffffffc0202324:	439c                	lw	a5,0(a5)
ffffffffc0202326:	2781                	sext.w	a5,a5
ffffffffc0202328:	c38d                	beqz	a5,ffffffffc020234a <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020232a:	000aa797          	auipc	a5,0xaa
ffffffffc020232e:	56678793          	addi	a5,a5,1382 # ffffffffc02ac890 <check_mm_struct>
ffffffffc0202332:	6388                	ld	a0,0(a5)
ffffffffc0202334:	c919                	beqz	a0,ffffffffc020234a <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202336:	4681                	li	a3,0
ffffffffc0202338:	8622                	mv	a2,s0
ffffffffc020233a:	85a6                	mv	a1,s1
ffffffffc020233c:	6da010ef          	jal	ra,ffffffffc0203a16 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0202340:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0202342:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0202344:	4785                	li	a5,1
ffffffffc0202346:	02f71063          	bne	a4,a5,ffffffffc0202366 <pgdir_alloc_page+0x74>
}
ffffffffc020234a:	8522                	mv	a0,s0
ffffffffc020234c:	70a2                	ld	ra,40(sp)
ffffffffc020234e:	7402                	ld	s0,32(sp)
ffffffffc0202350:	64e2                	ld	s1,24(sp)
ffffffffc0202352:	6942                	ld	s2,16(sp)
ffffffffc0202354:	69a2                	ld	s3,8(sp)
ffffffffc0202356:	6145                	addi	sp,sp,48
ffffffffc0202358:	8082                	ret
            free_page(page);
ffffffffc020235a:	8522                	mv	a0,s0
ffffffffc020235c:	4585                	li	a1,1
ffffffffc020235e:	b85fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
            return NULL;
ffffffffc0202362:	4401                	li	s0,0
ffffffffc0202364:	b7dd                	j	ffffffffc020234a <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0202366:	00005697          	auipc	a3,0x5
ffffffffc020236a:	ca268693          	addi	a3,a3,-862 # ffffffffc0207008 <commands+0x8d0>
ffffffffc020236e:	00005617          	auipc	a2,0x5
ffffffffc0202372:	84a60613          	addi	a2,a2,-1974 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202376:	1cc00593          	li	a1,460
ffffffffc020237a:	00005517          	auipc	a0,0x5
ffffffffc020237e:	c4e50513          	addi	a0,a0,-946 # ffffffffc0206fc8 <commands+0x890>
ffffffffc0202382:	e93fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202386 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202386:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202388:	00005697          	auipc	a3,0x5
ffffffffc020238c:	25868693          	addi	a3,a3,600 # ffffffffc02075e0 <commands+0xea8>
ffffffffc0202390:	00005617          	auipc	a2,0x5
ffffffffc0202394:	82860613          	addi	a2,a2,-2008 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202398:	06d00593          	li	a1,109
ffffffffc020239c:	00005517          	auipc	a0,0x5
ffffffffc02023a0:	26450513          	addi	a0,a0,612 # ffffffffc0207600 <commands+0xec8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02023a4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02023a6:	e6ffd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02023aa <mm_create>:
mm_create(void) {
ffffffffc02023aa:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02023ac:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02023b0:	e022                	sd	s0,0(sp)
ffffffffc02023b2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02023b4:	4f3000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc02023b8:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02023ba:	c515                	beqz	a0,ffffffffc02023e6 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023bc:	000aa797          	auipc	a5,0xaa
ffffffffc02023c0:	48478793          	addi	a5,a5,1156 # ffffffffc02ac840 <swap_init_ok>
ffffffffc02023c4:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02023c6:	e408                	sd	a0,8(s0)
ffffffffc02023c8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02023ca:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02023ce:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02023d2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023d6:	2781                	sext.w	a5,a5
ffffffffc02023d8:	ef81                	bnez	a5,ffffffffc02023f0 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02023da:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02023de:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02023e2:	02043c23          	sd	zero,56(s0)
}
ffffffffc02023e6:	8522                	mv	a0,s0
ffffffffc02023e8:	60a2                	ld	ra,8(sp)
ffffffffc02023ea:	6402                	ld	s0,0(sp)
ffffffffc02023ec:	0141                	addi	sp,sp,16
ffffffffc02023ee:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023f0:	616010ef          	jal	ra,ffffffffc0203a06 <swap_init_mm>
ffffffffc02023f4:	b7ed                	j	ffffffffc02023de <mm_create+0x34>

ffffffffc02023f6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02023f6:	1101                	addi	sp,sp,-32
ffffffffc02023f8:	e04a                	sd	s2,0(sp)
ffffffffc02023fa:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02023fc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202400:	e822                	sd	s0,16(sp)
ffffffffc0202402:	e426                	sd	s1,8(sp)
ffffffffc0202404:	ec06                	sd	ra,24(sp)
ffffffffc0202406:	84ae                	mv	s1,a1
ffffffffc0202408:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020240a:	49d000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
    if (vma != NULL) {
ffffffffc020240e:	c509                	beqz	a0,ffffffffc0202418 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202410:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202414:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202416:	cd00                	sw	s0,24(a0)
}
ffffffffc0202418:	60e2                	ld	ra,24(sp)
ffffffffc020241a:	6442                	ld	s0,16(sp)
ffffffffc020241c:	64a2                	ld	s1,8(sp)
ffffffffc020241e:	6902                	ld	s2,0(sp)
ffffffffc0202420:	6105                	addi	sp,sp,32
ffffffffc0202422:	8082                	ret

ffffffffc0202424 <find_vma>:
    if (mm != NULL) {
ffffffffc0202424:	c51d                	beqz	a0,ffffffffc0202452 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0202426:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202428:	c781                	beqz	a5,ffffffffc0202430 <find_vma+0xc>
ffffffffc020242a:	6798                	ld	a4,8(a5)
ffffffffc020242c:	02e5f663          	bgeu	a1,a4,ffffffffc0202458 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0202430:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202432:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202434:	00f50f63          	beq	a0,a5,ffffffffc0202452 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202438:	fe87b703          	ld	a4,-24(a5)
ffffffffc020243c:	fee5ebe3          	bltu	a1,a4,ffffffffc0202432 <find_vma+0xe>
ffffffffc0202440:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202444:	fee5f7e3          	bgeu	a1,a4,ffffffffc0202432 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0202448:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020244a:	c781                	beqz	a5,ffffffffc0202452 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020244c:	e91c                	sd	a5,16(a0)
}
ffffffffc020244e:	853e                	mv	a0,a5
ffffffffc0202450:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0202452:	4781                	li	a5,0
}
ffffffffc0202454:	853e                	mv	a0,a5
ffffffffc0202456:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202458:	6b98                	ld	a4,16(a5)
ffffffffc020245a:	fce5fbe3          	bgeu	a1,a4,ffffffffc0202430 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020245e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0202460:	b7fd                	j	ffffffffc020244e <find_vma+0x2a>

ffffffffc0202462 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202462:	6590                	ld	a2,8(a1)
ffffffffc0202464:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202468:	1141                	addi	sp,sp,-16
ffffffffc020246a:	e406                	sd	ra,8(sp)
ffffffffc020246c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020246e:	01066863          	bltu	a2,a6,ffffffffc020247e <insert_vma_struct+0x1c>
ffffffffc0202472:	a8b9                	j	ffffffffc02024d0 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202474:	fe87b683          	ld	a3,-24(a5)
ffffffffc0202478:	04d66763          	bltu	a2,a3,ffffffffc02024c6 <insert_vma_struct+0x64>
ffffffffc020247c:	873e                	mv	a4,a5
ffffffffc020247e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0202480:	fef51ae3          	bne	a0,a5,ffffffffc0202474 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0202484:	02a70463          	beq	a4,a0,ffffffffc02024ac <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202488:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020248c:	fe873883          	ld	a7,-24(a4)
ffffffffc0202490:	08d8f063          	bgeu	a7,a3,ffffffffc0202510 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202494:	04d66e63          	bltu	a2,a3,ffffffffc02024f0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0202498:	00f50a63          	beq	a0,a5,ffffffffc02024ac <insert_vma_struct+0x4a>
ffffffffc020249c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024a0:	0506e863          	bltu	a3,a6,ffffffffc02024f0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02024a4:	ff07b603          	ld	a2,-16(a5)
ffffffffc02024a8:	02c6f263          	bgeu	a3,a2,ffffffffc02024cc <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02024ac:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02024ae:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02024b0:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02024b4:	e390                	sd	a2,0(a5)
ffffffffc02024b6:	e710                	sd	a2,8(a4)
}
ffffffffc02024b8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02024ba:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02024bc:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02024be:	2685                	addiw	a3,a3,1
ffffffffc02024c0:	d114                	sw	a3,32(a0)
}
ffffffffc02024c2:	0141                	addi	sp,sp,16
ffffffffc02024c4:	8082                	ret
    if (le_prev != list) {
ffffffffc02024c6:	fca711e3          	bne	a4,a0,ffffffffc0202488 <insert_vma_struct+0x26>
ffffffffc02024ca:	bfd9                	j	ffffffffc02024a0 <insert_vma_struct+0x3e>
ffffffffc02024cc:	ebbff0ef          	jal	ra,ffffffffc0202386 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02024d0:	00005697          	auipc	a3,0x5
ffffffffc02024d4:	22068693          	addi	a3,a3,544 # ffffffffc02076f0 <commands+0xfb8>
ffffffffc02024d8:	00004617          	auipc	a2,0x4
ffffffffc02024dc:	6e060613          	addi	a2,a2,1760 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02024e0:	07400593          	li	a1,116
ffffffffc02024e4:	00005517          	auipc	a0,0x5
ffffffffc02024e8:	11c50513          	addi	a0,a0,284 # ffffffffc0207600 <commands+0xec8>
ffffffffc02024ec:	d29fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024f0:	00005697          	auipc	a3,0x5
ffffffffc02024f4:	24068693          	addi	a3,a3,576 # ffffffffc0207730 <commands+0xff8>
ffffffffc02024f8:	00004617          	auipc	a2,0x4
ffffffffc02024fc:	6c060613          	addi	a2,a2,1728 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202500:	06c00593          	li	a1,108
ffffffffc0202504:	00005517          	auipc	a0,0x5
ffffffffc0202508:	0fc50513          	addi	a0,a0,252 # ffffffffc0207600 <commands+0xec8>
ffffffffc020250c:	d09fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202510:	00005697          	auipc	a3,0x5
ffffffffc0202514:	20068693          	addi	a3,a3,512 # ffffffffc0207710 <commands+0xfd8>
ffffffffc0202518:	00004617          	auipc	a2,0x4
ffffffffc020251c:	6a060613          	addi	a2,a2,1696 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202520:	06b00593          	li	a1,107
ffffffffc0202524:	00005517          	auipc	a0,0x5
ffffffffc0202528:	0dc50513          	addi	a0,a0,220 # ffffffffc0207600 <commands+0xec8>
ffffffffc020252c:	ce9fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202530 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202530:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202532:	1141                	addi	sp,sp,-16
ffffffffc0202534:	e406                	sd	ra,8(sp)
ffffffffc0202536:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202538:	e78d                	bnez	a5,ffffffffc0202562 <mm_destroy+0x32>
ffffffffc020253a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020253c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020253e:	00a40c63          	beq	s0,a0,ffffffffc0202556 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202542:	6118                	ld	a4,0(a0)
ffffffffc0202544:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202546:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202548:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020254a:	e398                	sd	a4,0(a5)
ffffffffc020254c:	417000ef          	jal	ra,ffffffffc0203162 <kfree>
    return listelm->next;
ffffffffc0202550:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202552:	fea418e3          	bne	s0,a0,ffffffffc0202542 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0202556:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202558:	6402                	ld	s0,0(sp)
ffffffffc020255a:	60a2                	ld	ra,8(sp)
ffffffffc020255c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020255e:	4050006f          	j	ffffffffc0203162 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202562:	00005697          	auipc	a3,0x5
ffffffffc0202566:	1ee68693          	addi	a3,a3,494 # ffffffffc0207750 <commands+0x1018>
ffffffffc020256a:	00004617          	auipc	a2,0x4
ffffffffc020256e:	64e60613          	addi	a2,a2,1614 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202572:	09400593          	li	a1,148
ffffffffc0202576:	00005517          	auipc	a0,0x5
ffffffffc020257a:	08a50513          	addi	a0,a0,138 # ffffffffc0207600 <commands+0xec8>
ffffffffc020257e:	c97fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202582 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202582:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0202584:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202586:	17fd                	addi	a5,a5,-1
ffffffffc0202588:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020258a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020258c:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0202590:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202592:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0202594:	fc06                	sd	ra,56(sp)
ffffffffc0202596:	f04a                	sd	s2,32(sp)
ffffffffc0202598:	ec4e                	sd	s3,24(sp)
ffffffffc020259a:	e852                	sd	s4,16(sp)
ffffffffc020259c:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020259e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02025a2:	002007b7          	lui	a5,0x200
ffffffffc02025a6:	01047433          	and	s0,s0,a6
ffffffffc02025aa:	06f4e363          	bltu	s1,a5,ffffffffc0202610 <mm_map+0x8e>
ffffffffc02025ae:	0684f163          	bgeu	s1,s0,ffffffffc0202610 <mm_map+0x8e>
ffffffffc02025b2:	4785                	li	a5,1
ffffffffc02025b4:	07fe                	slli	a5,a5,0x1f
ffffffffc02025b6:	0487ed63          	bltu	a5,s0,ffffffffc0202610 <mm_map+0x8e>
ffffffffc02025ba:	89aa                	mv	s3,a0
ffffffffc02025bc:	8a3a                	mv	s4,a4
ffffffffc02025be:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02025c0:	c931                	beqz	a0,ffffffffc0202614 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02025c2:	85a6                	mv	a1,s1
ffffffffc02025c4:	e61ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc02025c8:	c501                	beqz	a0,ffffffffc02025d0 <mm_map+0x4e>
ffffffffc02025ca:	651c                	ld	a5,8(a0)
ffffffffc02025cc:	0487e263          	bltu	a5,s0,ffffffffc0202610 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02025d0:	03000513          	li	a0,48
ffffffffc02025d4:	2d3000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc02025d8:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02025da:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02025dc:	02090163          	beqz	s2,ffffffffc02025fe <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02025e0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02025e2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02025e6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02025ea:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02025ee:	85ca                	mv	a1,s2
ffffffffc02025f0:	e73ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02025f4:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02025f6:	000a0463          	beqz	s4,ffffffffc02025fe <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02025fa:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02025fe:	70e2                	ld	ra,56(sp)
ffffffffc0202600:	7442                	ld	s0,48(sp)
ffffffffc0202602:	74a2                	ld	s1,40(sp)
ffffffffc0202604:	7902                	ld	s2,32(sp)
ffffffffc0202606:	69e2                	ld	s3,24(sp)
ffffffffc0202608:	6a42                	ld	s4,16(sp)
ffffffffc020260a:	6aa2                	ld	s5,8(sp)
ffffffffc020260c:	6121                	addi	sp,sp,64
ffffffffc020260e:	8082                	ret
        return -E_INVAL;
ffffffffc0202610:	5575                	li	a0,-3
ffffffffc0202612:	b7f5                	j	ffffffffc02025fe <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0202614:	00005697          	auipc	a3,0x5
ffffffffc0202618:	15468693          	addi	a3,a3,340 # ffffffffc0207768 <commands+0x1030>
ffffffffc020261c:	00004617          	auipc	a2,0x4
ffffffffc0202620:	59c60613          	addi	a2,a2,1436 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202624:	0a700593          	li	a1,167
ffffffffc0202628:	00005517          	auipc	a0,0x5
ffffffffc020262c:	fd850513          	addi	a0,a0,-40 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202630:	be5fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202634 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202634:	7139                	addi	sp,sp,-64
ffffffffc0202636:	fc06                	sd	ra,56(sp)
ffffffffc0202638:	f822                	sd	s0,48(sp)
ffffffffc020263a:	f426                	sd	s1,40(sp)
ffffffffc020263c:	f04a                	sd	s2,32(sp)
ffffffffc020263e:	ec4e                	sd	s3,24(sp)
ffffffffc0202640:	e852                	sd	s4,16(sp)
ffffffffc0202642:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202644:	c535                	beqz	a0,ffffffffc02026b0 <dup_mmap+0x7c>
ffffffffc0202646:	892a                	mv	s2,a0
ffffffffc0202648:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020264a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020264c:	e59d                	bnez	a1,ffffffffc020267a <dup_mmap+0x46>
ffffffffc020264e:	a08d                	j	ffffffffc02026b0 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202650:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0202652:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5540>
        insert_vma_struct(to, nvma);
ffffffffc0202656:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0202658:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020265c:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0202660:	e03ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0202664:	ff043683          	ld	a3,-16(s0)
ffffffffc0202668:	fe843603          	ld	a2,-24(s0)
ffffffffc020266c:	6c8c                	ld	a1,24(s1)
ffffffffc020266e:	01893503          	ld	a0,24(s2)
ffffffffc0202672:	4701                	li	a4,0
ffffffffc0202674:	a45ff0ef          	jal	ra,ffffffffc02020b8 <copy_range>
ffffffffc0202678:	e105                	bnez	a0,ffffffffc0202698 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020267a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020267c:	02848863          	beq	s1,s0,ffffffffc02026ac <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202680:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202684:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202688:	ff043a03          	ld	s4,-16(s0)
ffffffffc020268c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202690:	217000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc0202694:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0202696:	fd4d                	bnez	a0,ffffffffc0202650 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202698:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020269a:	70e2                	ld	ra,56(sp)
ffffffffc020269c:	7442                	ld	s0,48(sp)
ffffffffc020269e:	74a2                	ld	s1,40(sp)
ffffffffc02026a0:	7902                	ld	s2,32(sp)
ffffffffc02026a2:	69e2                	ld	s3,24(sp)
ffffffffc02026a4:	6a42                	ld	s4,16(sp)
ffffffffc02026a6:	6aa2                	ld	s5,8(sp)
ffffffffc02026a8:	6121                	addi	sp,sp,64
ffffffffc02026aa:	8082                	ret
    return 0;
ffffffffc02026ac:	4501                	li	a0,0
ffffffffc02026ae:	b7f5                	j	ffffffffc020269a <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02026b0:	00005697          	auipc	a3,0x5
ffffffffc02026b4:	00068693          	mv	a3,a3
ffffffffc02026b8:	00004617          	auipc	a2,0x4
ffffffffc02026bc:	50060613          	addi	a2,a2,1280 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02026c0:	0c000593          	li	a1,192
ffffffffc02026c4:	00005517          	auipc	a0,0x5
ffffffffc02026c8:	f3c50513          	addi	a0,a0,-196 # ffffffffc0207600 <commands+0xec8>
ffffffffc02026cc:	b49fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02026d0 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02026d0:	1101                	addi	sp,sp,-32
ffffffffc02026d2:	ec06                	sd	ra,24(sp)
ffffffffc02026d4:	e822                	sd	s0,16(sp)
ffffffffc02026d6:	e426                	sd	s1,8(sp)
ffffffffc02026d8:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02026da:	c531                	beqz	a0,ffffffffc0202726 <exit_mmap+0x56>
ffffffffc02026dc:	591c                	lw	a5,48(a0)
ffffffffc02026de:	84aa                	mv	s1,a0
ffffffffc02026e0:	e3b9                	bnez	a5,ffffffffc0202726 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02026e2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02026e4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02026e8:	02850663          	beq	a0,s0,ffffffffc0202714 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02026ec:	ff043603          	ld	a2,-16(s0)
ffffffffc02026f0:	fe843583          	ld	a1,-24(s0)
ffffffffc02026f4:	854a                	mv	a0,s2
ffffffffc02026f6:	a9dfe0ef          	jal	ra,ffffffffc0201192 <unmap_range>
ffffffffc02026fa:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02026fc:	fe8498e3          	bne	s1,s0,ffffffffc02026ec <exit_mmap+0x1c>
ffffffffc0202700:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202702:	00848c63          	beq	s1,s0,ffffffffc020271a <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202706:	ff043603          	ld	a2,-16(s0)
ffffffffc020270a:	fe843583          	ld	a1,-24(s0)
ffffffffc020270e:	854a                	mv	a0,s2
ffffffffc0202710:	b9bfe0ef          	jal	ra,ffffffffc02012aa <exit_range>
ffffffffc0202714:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202716:	fe8498e3          	bne	s1,s0,ffffffffc0202706 <exit_mmap+0x36>
    }
}
ffffffffc020271a:	60e2                	ld	ra,24(sp)
ffffffffc020271c:	6442                	ld	s0,16(sp)
ffffffffc020271e:	64a2                	ld	s1,8(sp)
ffffffffc0202720:	6902                	ld	s2,0(sp)
ffffffffc0202722:	6105                	addi	sp,sp,32
ffffffffc0202724:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202726:	00005697          	auipc	a3,0x5
ffffffffc020272a:	faa68693          	addi	a3,a3,-86 # ffffffffc02076d0 <commands+0xf98>
ffffffffc020272e:	00004617          	auipc	a2,0x4
ffffffffc0202732:	48a60613          	addi	a2,a2,1162 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202736:	0d600593          	li	a1,214
ffffffffc020273a:	00005517          	auipc	a0,0x5
ffffffffc020273e:	ec650513          	addi	a0,a0,-314 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202742:	ad3fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202746 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202746:	7139                	addi	sp,sp,-64
ffffffffc0202748:	f822                	sd	s0,48(sp)
ffffffffc020274a:	f426                	sd	s1,40(sp)
ffffffffc020274c:	fc06                	sd	ra,56(sp)
ffffffffc020274e:	f04a                	sd	s2,32(sp)
ffffffffc0202750:	ec4e                	sd	s3,24(sp)
ffffffffc0202752:	e852                	sd	s4,16(sp)
ffffffffc0202754:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202756:	c55ff0ef          	jal	ra,ffffffffc02023aa <mm_create>
    assert(mm != NULL);
ffffffffc020275a:	842a                	mv	s0,a0
ffffffffc020275c:	03200493          	li	s1,50
ffffffffc0202760:	e919                	bnez	a0,ffffffffc0202776 <vmm_init+0x30>
ffffffffc0202762:	a989                	j	ffffffffc0202bb4 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0202764:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202766:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202768:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020276c:	14ed                	addi	s1,s1,-5
ffffffffc020276e:	8522                	mv	a0,s0
ffffffffc0202770:	cf3ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202774:	c88d                	beqz	s1,ffffffffc02027a6 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202776:	03000513          	li	a0,48
ffffffffc020277a:	12d000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc020277e:	85aa                	mv	a1,a0
ffffffffc0202780:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202784:	f165                	bnez	a0,ffffffffc0202764 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202786:	00005697          	auipc	a3,0x5
ffffffffc020278a:	20a68693          	addi	a3,a3,522 # ffffffffc0207990 <commands+0x1258>
ffffffffc020278e:	00004617          	auipc	a2,0x4
ffffffffc0202792:	42a60613          	addi	a2,a2,1066 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202796:	11300593          	li	a1,275
ffffffffc020279a:	00005517          	auipc	a0,0x5
ffffffffc020279e:	e6650513          	addi	a0,a0,-410 # ffffffffc0207600 <commands+0xec8>
ffffffffc02027a2:	a73fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02027a6:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02027aa:	1f900913          	li	s2,505
ffffffffc02027ae:	a819                	j	ffffffffc02027c4 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02027b0:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02027b2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02027b4:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02027b8:	0495                	addi	s1,s1,5
ffffffffc02027ba:	8522                	mv	a0,s0
ffffffffc02027bc:	ca7ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02027c0:	03248a63          	beq	s1,s2,ffffffffc02027f4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02027c4:	03000513          	li	a0,48
ffffffffc02027c8:	0df000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc02027cc:	85aa                	mv	a1,a0
ffffffffc02027ce:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02027d2:	fd79                	bnez	a0,ffffffffc02027b0 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02027d4:	00005697          	auipc	a3,0x5
ffffffffc02027d8:	1bc68693          	addi	a3,a3,444 # ffffffffc0207990 <commands+0x1258>
ffffffffc02027dc:	00004617          	auipc	a2,0x4
ffffffffc02027e0:	3dc60613          	addi	a2,a2,988 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02027e4:	11900593          	li	a1,281
ffffffffc02027e8:	00005517          	auipc	a0,0x5
ffffffffc02027ec:	e1850513          	addi	a0,a0,-488 # ffffffffc0207600 <commands+0xec8>
ffffffffc02027f0:	a25fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02027f4:	6418                	ld	a4,8(s0)
ffffffffc02027f6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02027f8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02027fc:	2ee40063          	beq	s0,a4,ffffffffc0202adc <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202800:	fe873603          	ld	a2,-24(a4)
ffffffffc0202804:	ffe78693          	addi	a3,a5,-2
ffffffffc0202808:	24d61a63          	bne	a2,a3,ffffffffc0202a5c <vmm_init+0x316>
ffffffffc020280c:	ff073683          	ld	a3,-16(a4)
ffffffffc0202810:	24f69663          	bne	a3,a5,ffffffffc0202a5c <vmm_init+0x316>
ffffffffc0202814:	0795                	addi	a5,a5,5
ffffffffc0202816:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0202818:	feb792e3          	bne	a5,a1,ffffffffc02027fc <vmm_init+0xb6>
ffffffffc020281c:	491d                	li	s2,7
ffffffffc020281e:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202820:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202824:	85a6                	mv	a1,s1
ffffffffc0202826:	8522                	mv	a0,s0
ffffffffc0202828:	bfdff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020282c:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020282e:	30050763          	beqz	a0,ffffffffc0202b3c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202832:	00148593          	addi	a1,s1,1
ffffffffc0202836:	8522                	mv	a0,s0
ffffffffc0202838:	bedff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020283c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020283e:	2c050f63          	beqz	a0,ffffffffc0202b1c <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202842:	85ca                	mv	a1,s2
ffffffffc0202844:	8522                	mv	a0,s0
ffffffffc0202846:	bdfff0ef          	jal	ra,ffffffffc0202424 <find_vma>
        assert(vma3 == NULL);
ffffffffc020284a:	2a051963          	bnez	a0,ffffffffc0202afc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020284e:	00348593          	addi	a1,s1,3
ffffffffc0202852:	8522                	mv	a0,s0
ffffffffc0202854:	bd1ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202858:	32051263          	bnez	a0,ffffffffc0202b7c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020285c:	00448593          	addi	a1,s1,4
ffffffffc0202860:	8522                	mv	a0,s0
ffffffffc0202862:	bc3ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202866:	2e051b63          	bnez	a0,ffffffffc0202b5c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020286a:	008a3783          	ld	a5,8(s4)
ffffffffc020286e:	20979763          	bne	a5,s1,ffffffffc0202a7c <vmm_init+0x336>
ffffffffc0202872:	010a3783          	ld	a5,16(s4)
ffffffffc0202876:	21279363          	bne	a5,s2,ffffffffc0202a7c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020287a:	0089b783          	ld	a5,8(s3) # 1008 <_binary_obj___user_faultread_out_size-0x85c0>
ffffffffc020287e:	20979f63          	bne	a5,s1,ffffffffc0202a9c <vmm_init+0x356>
ffffffffc0202882:	0109b783          	ld	a5,16(s3)
ffffffffc0202886:	21279b63          	bne	a5,s2,ffffffffc0202a9c <vmm_init+0x356>
ffffffffc020288a:	0495                	addi	s1,s1,5
ffffffffc020288c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020288e:	f9549be3          	bne	s1,s5,ffffffffc0202824 <vmm_init+0xde>
ffffffffc0202892:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202894:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202896:	85a6                	mv	a1,s1
ffffffffc0202898:	8522                	mv	a0,s0
ffffffffc020289a:	b8bff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020289e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02028a2:	c90d                	beqz	a0,ffffffffc02028d4 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02028a4:	6914                	ld	a3,16(a0)
ffffffffc02028a6:	6510                	ld	a2,8(a0)
ffffffffc02028a8:	00005517          	auipc	a0,0x5
ffffffffc02028ac:	fd050513          	addi	a0,a0,-48 # ffffffffc0207878 <commands+0x1140>
ffffffffc02028b0:	821fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02028b4:	00005697          	auipc	a3,0x5
ffffffffc02028b8:	fec68693          	addi	a3,a3,-20 # ffffffffc02078a0 <commands+0x1168>
ffffffffc02028bc:	00004617          	auipc	a2,0x4
ffffffffc02028c0:	2fc60613          	addi	a2,a2,764 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02028c4:	13b00593          	li	a1,315
ffffffffc02028c8:	00005517          	auipc	a0,0x5
ffffffffc02028cc:	d3850513          	addi	a0,a0,-712 # ffffffffc0207600 <commands+0xec8>
ffffffffc02028d0:	945fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02028d4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02028d6:	fd2490e3          	bne	s1,s2,ffffffffc0202896 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02028da:	8522                	mv	a0,s0
ffffffffc02028dc:	c55ff0ef          	jal	ra,ffffffffc0202530 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02028e0:	00005517          	auipc	a0,0x5
ffffffffc02028e4:	fd850513          	addi	a0,a0,-40 # ffffffffc02078b8 <commands+0x1180>
ffffffffc02028e8:	fe8fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02028ec:	e3cfe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc02028f0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02028f2:	ab9ff0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc02028f6:	000aa797          	auipc	a5,0xaa
ffffffffc02028fa:	f8a7bd23          	sd	a0,-102(a5) # ffffffffc02ac890 <check_mm_struct>
ffffffffc02028fe:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202900:	36050663          	beqz	a0,ffffffffc0202c6c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202904:	000aa797          	auipc	a5,0xaa
ffffffffc0202908:	f1478793          	addi	a5,a5,-236 # ffffffffc02ac818 <boot_pgdir>
ffffffffc020290c:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0202910:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202914:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202918:	2c079e63          	bnez	a5,ffffffffc0202bf4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020291c:	03000513          	li	a0,48
ffffffffc0202920:	786000ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc0202924:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0202926:	18050b63          	beqz	a0,ffffffffc0202abc <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc020292a:	002007b7          	lui	a5,0x200
ffffffffc020292e:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202930:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202932:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202934:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202936:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0202938:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020293c:	b27ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202940:	10000593          	li	a1,256
ffffffffc0202944:	8526                	mv	a0,s1
ffffffffc0202946:	adfff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020294a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020294e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202952:	2ca41163          	bne	s0,a0,ffffffffc0202c14 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0202956:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
        sum += i;
ffffffffc020295a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020295c:	fee79de3          	bne	a5,a4,ffffffffc0202956 <vmm_init+0x210>
        sum += i;
ffffffffc0202960:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0202962:	10000793          	li	a5,256
        sum += i;
ffffffffc0202966:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020296a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020296e:	0007c683          	lbu	a3,0(a5)
ffffffffc0202972:	0785                	addi	a5,a5,1
ffffffffc0202974:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202976:	fec79ce3          	bne	a5,a2,ffffffffc020296e <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020297a:	2c071963          	bnez	a4,ffffffffc0202c4c <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020297e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202982:	000aaa97          	auipc	s5,0xaa
ffffffffc0202986:	e9ea8a93          	addi	s5,s5,-354 # ffffffffc02ac820 <npage>
ffffffffc020298a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020298e:	078a                	slli	a5,a5,0x2
ffffffffc0202990:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202992:	20e7f563          	bgeu	a5,a4,ffffffffc0202b9c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202996:	00006697          	auipc	a3,0x6
ffffffffc020299a:	30a68693          	addi	a3,a3,778 # ffffffffc0208ca0 <nbase>
ffffffffc020299e:	0006ba03          	ld	s4,0(a3)
ffffffffc02029a2:	414786b3          	sub	a3,a5,s4
ffffffffc02029a6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02029a8:	8699                	srai	a3,a3,0x6
ffffffffc02029aa:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02029ac:	00c69793          	slli	a5,a3,0xc
ffffffffc02029b0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029b2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029b4:	28e7f063          	bgeu	a5,a4,ffffffffc0202c34 <vmm_init+0x4ee>
ffffffffc02029b8:	000aa797          	auipc	a5,0xaa
ffffffffc02029bc:	ec078793          	addi	a5,a5,-320 # ffffffffc02ac878 <va_pa_offset>
ffffffffc02029c0:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02029c2:	4581                	li	a1,0
ffffffffc02029c4:	854a                	mv	a0,s2
ffffffffc02029c6:	9436                	add	s0,s0,a3
ffffffffc02029c8:	b39fe0ef          	jal	ra,ffffffffc0201500 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029cc:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02029ce:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029d2:	078a                	slli	a5,a5,0x2
ffffffffc02029d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029d6:	1ce7f363          	bgeu	a5,a4,ffffffffc0202b9c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02029da:	000aa417          	auipc	s0,0xaa
ffffffffc02029de:	eae40413          	addi	s0,s0,-338 # ffffffffc02ac888 <pages>
ffffffffc02029e2:	6008                	ld	a0,0(s0)
ffffffffc02029e4:	414787b3          	sub	a5,a5,s4
ffffffffc02029e8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02029ea:	953e                	add	a0,a0,a5
ffffffffc02029ec:	4585                	li	a1,1
ffffffffc02029ee:	cf4fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029f2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02029f6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029fa:	078a                	slli	a5,a5,0x2
ffffffffc02029fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029fe:	18e7ff63          	bgeu	a5,a4,ffffffffc0202b9c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a02:	6008                	ld	a0,0(s0)
ffffffffc0202a04:	414787b3          	sub	a5,a5,s4
ffffffffc0202a08:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202a0a:	4585                	li	a1,1
ffffffffc0202a0c:	953e                	add	a0,a0,a5
ffffffffc0202a0e:	cd4fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    pgdir[0] = 0;
ffffffffc0202a12:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202a16:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202a1a:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202a1e:	8526                	mv	a0,s1
ffffffffc0202a20:	b11ff0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202a24:	000aa797          	auipc	a5,0xaa
ffffffffc0202a28:	e607b623          	sd	zero,-404(a5) # ffffffffc02ac890 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202a2c:	cfcfe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0202a30:	1aa99263          	bne	s3,a0,ffffffffc0202bd4 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202a34:	00005517          	auipc	a0,0x5
ffffffffc0202a38:	f2450513          	addi	a0,a0,-220 # ffffffffc0207958 <commands+0x1220>
ffffffffc0202a3c:	e94fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202a40:	7442                	ld	s0,48(sp)
ffffffffc0202a42:	70e2                	ld	ra,56(sp)
ffffffffc0202a44:	74a2                	ld	s1,40(sp)
ffffffffc0202a46:	7902                	ld	s2,32(sp)
ffffffffc0202a48:	69e2                	ld	s3,24(sp)
ffffffffc0202a4a:	6a42                	ld	s4,16(sp)
ffffffffc0202a4c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202a4e:	00005517          	auipc	a0,0x5
ffffffffc0202a52:	f2a50513          	addi	a0,a0,-214 # ffffffffc0207978 <commands+0x1240>
}
ffffffffc0202a56:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202a58:	e78fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202a5c:	00005697          	auipc	a3,0x5
ffffffffc0202a60:	d3468693          	addi	a3,a3,-716 # ffffffffc0207790 <commands+0x1058>
ffffffffc0202a64:	00004617          	auipc	a2,0x4
ffffffffc0202a68:	15460613          	addi	a2,a2,340 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202a6c:	12200593          	li	a1,290
ffffffffc0202a70:	00005517          	auipc	a0,0x5
ffffffffc0202a74:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202a78:	f9cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202a7c:	00005697          	auipc	a3,0x5
ffffffffc0202a80:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207818 <commands+0x10e0>
ffffffffc0202a84:	00004617          	auipc	a2,0x4
ffffffffc0202a88:	13460613          	addi	a2,a2,308 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202a8c:	13200593          	li	a1,306
ffffffffc0202a90:	00005517          	auipc	a0,0x5
ffffffffc0202a94:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202a98:	f7cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202a9c:	00005697          	auipc	a3,0x5
ffffffffc0202aa0:	dac68693          	addi	a3,a3,-596 # ffffffffc0207848 <commands+0x1110>
ffffffffc0202aa4:	00004617          	auipc	a2,0x4
ffffffffc0202aa8:	11460613          	addi	a2,a2,276 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202aac:	13300593          	li	a1,307
ffffffffc0202ab0:	00005517          	auipc	a0,0x5
ffffffffc0202ab4:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202ab8:	f5cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(vma != NULL);
ffffffffc0202abc:	00005697          	auipc	a3,0x5
ffffffffc0202ac0:	ed468693          	addi	a3,a3,-300 # ffffffffc0207990 <commands+0x1258>
ffffffffc0202ac4:	00004617          	auipc	a2,0x4
ffffffffc0202ac8:	0f460613          	addi	a2,a2,244 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202acc:	15200593          	li	a1,338
ffffffffc0202ad0:	00005517          	auipc	a0,0x5
ffffffffc0202ad4:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202ad8:	f3cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202adc:	00005697          	auipc	a3,0x5
ffffffffc0202ae0:	c9c68693          	addi	a3,a3,-868 # ffffffffc0207778 <commands+0x1040>
ffffffffc0202ae4:	00004617          	auipc	a2,0x4
ffffffffc0202ae8:	0d460613          	addi	a2,a2,212 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202aec:	12000593          	li	a1,288
ffffffffc0202af0:	00005517          	auipc	a0,0x5
ffffffffc0202af4:	b1050513          	addi	a0,a0,-1264 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202af8:	f1cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma3 == NULL);
ffffffffc0202afc:	00005697          	auipc	a3,0x5
ffffffffc0202b00:	cec68693          	addi	a3,a3,-788 # ffffffffc02077e8 <commands+0x10b0>
ffffffffc0202b04:	00004617          	auipc	a2,0x4
ffffffffc0202b08:	0b460613          	addi	a2,a2,180 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202b0c:	12c00593          	li	a1,300
ffffffffc0202b10:	00005517          	auipc	a0,0x5
ffffffffc0202b14:	af050513          	addi	a0,a0,-1296 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202b18:	efcfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2 != NULL);
ffffffffc0202b1c:	00005697          	auipc	a3,0x5
ffffffffc0202b20:	cbc68693          	addi	a3,a3,-836 # ffffffffc02077d8 <commands+0x10a0>
ffffffffc0202b24:	00004617          	auipc	a2,0x4
ffffffffc0202b28:	09460613          	addi	a2,a2,148 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202b2c:	12a00593          	li	a1,298
ffffffffc0202b30:	00005517          	auipc	a0,0x5
ffffffffc0202b34:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202b38:	edcfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1 != NULL);
ffffffffc0202b3c:	00005697          	auipc	a3,0x5
ffffffffc0202b40:	c8c68693          	addi	a3,a3,-884 # ffffffffc02077c8 <commands+0x1090>
ffffffffc0202b44:	00004617          	auipc	a2,0x4
ffffffffc0202b48:	07460613          	addi	a2,a2,116 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202b4c:	12800593          	li	a1,296
ffffffffc0202b50:	00005517          	auipc	a0,0x5
ffffffffc0202b54:	ab050513          	addi	a0,a0,-1360 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202b58:	ebcfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma5 == NULL);
ffffffffc0202b5c:	00005697          	auipc	a3,0x5
ffffffffc0202b60:	cac68693          	addi	a3,a3,-852 # ffffffffc0207808 <commands+0x10d0>
ffffffffc0202b64:	00004617          	auipc	a2,0x4
ffffffffc0202b68:	05460613          	addi	a2,a2,84 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202b6c:	13000593          	li	a1,304
ffffffffc0202b70:	00005517          	auipc	a0,0x5
ffffffffc0202b74:	a9050513          	addi	a0,a0,-1392 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202b78:	e9cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma4 == NULL);
ffffffffc0202b7c:	00005697          	auipc	a3,0x5
ffffffffc0202b80:	c7c68693          	addi	a3,a3,-900 # ffffffffc02077f8 <commands+0x10c0>
ffffffffc0202b84:	00004617          	auipc	a2,0x4
ffffffffc0202b88:	03460613          	addi	a2,a2,52 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202b8c:	12e00593          	li	a1,302
ffffffffc0202b90:	00005517          	auipc	a0,0x5
ffffffffc0202b94:	a7050513          	addi	a0,a0,-1424 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202b98:	e7cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202b9c:	00004617          	auipc	a2,0x4
ffffffffc0202ba0:	43c60613          	addi	a2,a2,1084 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc0202ba4:	06200593          	li	a1,98
ffffffffc0202ba8:	00004517          	auipc	a0,0x4
ffffffffc0202bac:	45050513          	addi	a0,a0,1104 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0202bb0:	e64fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(mm != NULL);
ffffffffc0202bb4:	00005697          	auipc	a3,0x5
ffffffffc0202bb8:	bb468693          	addi	a3,a3,-1100 # ffffffffc0207768 <commands+0x1030>
ffffffffc0202bbc:	00004617          	auipc	a2,0x4
ffffffffc0202bc0:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202bc4:	10c00593          	li	a1,268
ffffffffc0202bc8:	00005517          	auipc	a0,0x5
ffffffffc0202bcc:	a3850513          	addi	a0,a0,-1480 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202bd0:	e44fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202bd4:	00005697          	auipc	a3,0x5
ffffffffc0202bd8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0207930 <commands+0x11f8>
ffffffffc0202bdc:	00004617          	auipc	a2,0x4
ffffffffc0202be0:	fdc60613          	addi	a2,a2,-36 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202be4:	17000593          	li	a1,368
ffffffffc0202be8:	00005517          	auipc	a0,0x5
ffffffffc0202bec:	a1850513          	addi	a0,a0,-1512 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202bf0:	e24fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202bf4:	00005697          	auipc	a3,0x5
ffffffffc0202bf8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02078f0 <commands+0x11b8>
ffffffffc0202bfc:	00004617          	auipc	a2,0x4
ffffffffc0202c00:	fbc60613          	addi	a2,a2,-68 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202c04:	14f00593          	li	a1,335
ffffffffc0202c08:	00005517          	auipc	a0,0x5
ffffffffc0202c0c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202c10:	e04fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c14:	00005697          	auipc	a3,0x5
ffffffffc0202c18:	cec68693          	addi	a3,a3,-788 # ffffffffc0207900 <commands+0x11c8>
ffffffffc0202c1c:	00004617          	auipc	a2,0x4
ffffffffc0202c20:	f9c60613          	addi	a2,a2,-100 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202c24:	15700593          	li	a1,343
ffffffffc0202c28:	00005517          	auipc	a0,0x5
ffffffffc0202c2c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202c30:	de4fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202c34:	00004617          	auipc	a2,0x4
ffffffffc0202c38:	36c60613          	addi	a2,a2,876 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0202c3c:	06900593          	li	a1,105
ffffffffc0202c40:	00004517          	auipc	a0,0x4
ffffffffc0202c44:	3b850513          	addi	a0,a0,952 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0202c48:	dccfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(sum == 0);
ffffffffc0202c4c:	00005697          	auipc	a3,0x5
ffffffffc0202c50:	cd468693          	addi	a3,a3,-812 # ffffffffc0207920 <commands+0x11e8>
ffffffffc0202c54:	00004617          	auipc	a2,0x4
ffffffffc0202c58:	f6460613          	addi	a2,a2,-156 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202c5c:	16300593          	li	a1,355
ffffffffc0202c60:	00005517          	auipc	a0,0x5
ffffffffc0202c64:	9a050513          	addi	a0,a0,-1632 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202c68:	dacfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202c6c:	00005697          	auipc	a3,0x5
ffffffffc0202c70:	c6c68693          	addi	a3,a3,-916 # ffffffffc02078d8 <commands+0x11a0>
ffffffffc0202c74:	00004617          	auipc	a2,0x4
ffffffffc0202c78:	f4460613          	addi	a2,a2,-188 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202c7c:	14b00593          	li	a1,331
ffffffffc0202c80:	00005517          	auipc	a0,0x5
ffffffffc0202c84:	98050513          	addi	a0,a0,-1664 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202c88:	d8cfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202c8c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202c8c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202c8e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202c90:	f022                	sd	s0,32(sp)
ffffffffc0202c92:	ec26                	sd	s1,24(sp)
ffffffffc0202c94:	f406                	sd	ra,40(sp)
ffffffffc0202c96:	e84a                	sd	s2,16(sp)
ffffffffc0202c98:	8432                	mv	s0,a2
ffffffffc0202c9a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202c9c:	f88ff0ef          	jal	ra,ffffffffc0202424 <find_vma>

    pgfault_num++;
ffffffffc0202ca0:	000aa797          	auipc	a5,0xaa
ffffffffc0202ca4:	b8878793          	addi	a5,a5,-1144 # ffffffffc02ac828 <pgfault_num>
ffffffffc0202ca8:	439c                	lw	a5,0(a5)
ffffffffc0202caa:	2785                	addiw	a5,a5,1
ffffffffc0202cac:	000aa717          	auipc	a4,0xaa
ffffffffc0202cb0:	b6f72e23          	sw	a5,-1156(a4) # ffffffffc02ac828 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202cb4:	c551                	beqz	a0,ffffffffc0202d40 <do_pgfault+0xb4>
ffffffffc0202cb6:	651c                	ld	a5,8(a0)
ffffffffc0202cb8:	08f46463          	bltu	s0,a5,ffffffffc0202d40 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202cbc:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202cbe:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202cc0:	8b89                	andi	a5,a5,2
ffffffffc0202cc2:	efb1                	bnez	a5,ffffffffc0202d1e <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202cc4:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202cc6:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202cc8:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202cca:	85a2                	mv	a1,s0
ffffffffc0202ccc:	4605                	li	a2,1
ffffffffc0202cce:	a9afe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0202cd2:	c941                	beqz	a0,ffffffffc0202d62 <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202cd4:	610c                	ld	a1,0(a0)
ffffffffc0202cd6:	c5b1                	beqz	a1,ffffffffc0202d22 <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202cd8:	000aa797          	auipc	a5,0xaa
ffffffffc0202cdc:	b6878793          	addi	a5,a5,-1176 # ffffffffc02ac840 <swap_init_ok>
ffffffffc0202ce0:	439c                	lw	a5,0(a5)
ffffffffc0202ce2:	2781                	sext.w	a5,a5
ffffffffc0202ce4:	c7bd                	beqz	a5,ffffffffc0202d52 <do_pgfault+0xc6>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0202ce6:	85a2                	mv	a1,s0
ffffffffc0202ce8:	0030                	addi	a2,sp,8
ffffffffc0202cea:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202cec:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0202cee:	64d000ef          	jal	ra,ffffffffc0203b3a <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0202cf2:	65a2                	ld	a1,8(sp)
ffffffffc0202cf4:	6c88                	ld	a0,24(s1)
ffffffffc0202cf6:	86ca                	mv	a3,s2
ffffffffc0202cf8:	8622                	mv	a2,s0
ffffffffc0202cfa:	87bfe0ef          	jal	ra,ffffffffc0201574 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0202cfe:	6622                	ld	a2,8(sp)
ffffffffc0202d00:	4685                	li	a3,1
ffffffffc0202d02:	85a2                	mv	a1,s0
ffffffffc0202d04:	8526                	mv	a0,s1
ffffffffc0202d06:	511000ef          	jal	ra,ffffffffc0203a16 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202d0a:	6722                	ld	a4,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0202d0c:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0202d0e:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0202d10:	70a2                	ld	ra,40(sp)
ffffffffc0202d12:	7402                	ld	s0,32(sp)
ffffffffc0202d14:	64e2                	ld	s1,24(sp)
ffffffffc0202d16:	6942                	ld	s2,16(sp)
ffffffffc0202d18:	853e                	mv	a0,a5
ffffffffc0202d1a:	6145                	addi	sp,sp,48
ffffffffc0202d1c:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202d1e:	495d                	li	s2,23
ffffffffc0202d20:	b755                	j	ffffffffc0202cc4 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d22:	6c88                	ld	a0,24(s1)
ffffffffc0202d24:	864a                	mv	a2,s2
ffffffffc0202d26:	85a2                	mv	a1,s0
ffffffffc0202d28:	dcaff0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202d2c:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d2e:	f16d                	bnez	a0,ffffffffc0202d10 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202d30:	00005517          	auipc	a0,0x5
ffffffffc0202d34:	93050513          	addi	a0,a0,-1744 # ffffffffc0207660 <commands+0xf28>
ffffffffc0202d38:	b98fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d3c:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202d3e:	bfc9                	j	ffffffffc0202d10 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202d40:	85a2                	mv	a1,s0
ffffffffc0202d42:	00005517          	auipc	a0,0x5
ffffffffc0202d46:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0207610 <commands+0xed8>
ffffffffc0202d4a:	b86fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d4e:	57f5                	li	a5,-3
        goto failed;
ffffffffc0202d50:	b7c1                	j	ffffffffc0202d10 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202d52:	00005517          	auipc	a0,0x5
ffffffffc0202d56:	93650513          	addi	a0,a0,-1738 # ffffffffc0207688 <commands+0xf50>
ffffffffc0202d5a:	b76fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d5e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202d60:	bf45                	j	ffffffffc0202d10 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202d62:	00005517          	auipc	a0,0x5
ffffffffc0202d66:	8de50513          	addi	a0,a0,-1826 # ffffffffc0207640 <commands+0xf08>
ffffffffc0202d6a:	b66fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d6e:	57f1                	li	a5,-4
        goto failed;
ffffffffc0202d70:	b745                	j	ffffffffc0202d10 <do_pgfault+0x84>

ffffffffc0202d72 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0202d72:	7179                	addi	sp,sp,-48
ffffffffc0202d74:	f022                	sd	s0,32(sp)
ffffffffc0202d76:	f406                	sd	ra,40(sp)
ffffffffc0202d78:	ec26                	sd	s1,24(sp)
ffffffffc0202d7a:	e84a                	sd	s2,16(sp)
ffffffffc0202d7c:	e44e                	sd	s3,8(sp)
ffffffffc0202d7e:	e052                	sd	s4,0(sp)
ffffffffc0202d80:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0202d82:	c135                	beqz	a0,ffffffffc0202de6 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0202d84:	002007b7          	lui	a5,0x200
ffffffffc0202d88:	04f5e663          	bltu	a1,a5,ffffffffc0202dd4 <user_mem_check+0x62>
ffffffffc0202d8c:	00c584b3          	add	s1,a1,a2
ffffffffc0202d90:	0495f263          	bgeu	a1,s1,ffffffffc0202dd4 <user_mem_check+0x62>
ffffffffc0202d94:	4785                	li	a5,1
ffffffffc0202d96:	07fe                	slli	a5,a5,0x1f
ffffffffc0202d98:	0297ee63          	bltu	a5,s1,ffffffffc0202dd4 <user_mem_check+0x62>
ffffffffc0202d9c:	892a                	mv	s2,a0
ffffffffc0202d9e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202da0:	6a05                	lui	s4,0x1
ffffffffc0202da2:	a821                	j	ffffffffc0202dba <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202da4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202da8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202daa:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202dac:	c685                	beqz	a3,ffffffffc0202dd4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202dae:	c399                	beqz	a5,ffffffffc0202db4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202db0:	02e46263          	bltu	s0,a4,ffffffffc0202dd4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0202db4:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0202db6:	04947663          	bgeu	s0,s1,ffffffffc0202e02 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0202dba:	85a2                	mv	a1,s0
ffffffffc0202dbc:	854a                	mv	a0,s2
ffffffffc0202dbe:	e66ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc0202dc2:	c909                	beqz	a0,ffffffffc0202dd4 <user_mem_check+0x62>
ffffffffc0202dc4:	6518                	ld	a4,8(a0)
ffffffffc0202dc6:	00e46763          	bltu	s0,a4,ffffffffc0202dd4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202dca:	4d1c                	lw	a5,24(a0)
ffffffffc0202dcc:	fc099ce3          	bnez	s3,ffffffffc0202da4 <user_mem_check+0x32>
ffffffffc0202dd0:	8b85                	andi	a5,a5,1
ffffffffc0202dd2:	f3ed                	bnez	a5,ffffffffc0202db4 <user_mem_check+0x42>
            return 0;
ffffffffc0202dd4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0202dd6:	70a2                	ld	ra,40(sp)
ffffffffc0202dd8:	7402                	ld	s0,32(sp)
ffffffffc0202dda:	64e2                	ld	s1,24(sp)
ffffffffc0202ddc:	6942                	ld	s2,16(sp)
ffffffffc0202dde:	69a2                	ld	s3,8(sp)
ffffffffc0202de0:	6a02                	ld	s4,0(sp)
ffffffffc0202de2:	6145                	addi	sp,sp,48
ffffffffc0202de4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0202de6:	c02007b7          	lui	a5,0xc0200
ffffffffc0202dea:	4501                	li	a0,0
ffffffffc0202dec:	fef5e5e3          	bltu	a1,a5,ffffffffc0202dd6 <user_mem_check+0x64>
ffffffffc0202df0:	962e                	add	a2,a2,a1
ffffffffc0202df2:	fec5f2e3          	bgeu	a1,a2,ffffffffc0202dd6 <user_mem_check+0x64>
ffffffffc0202df6:	c8000537          	lui	a0,0xc8000
ffffffffc0202dfa:	0505                	addi	a0,a0,1
ffffffffc0202dfc:	00a63533          	sltu	a0,a2,a0
ffffffffc0202e00:	bfd9                	j	ffffffffc0202dd6 <user_mem_check+0x64>
        return 1;
ffffffffc0202e02:	4505                	li	a0,1
ffffffffc0202e04:	bfc9                	j	ffffffffc0202dd6 <user_mem_check+0x64>

ffffffffc0202e06 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202e06:	c125                	beqz	a0,ffffffffc0202e66 <slob_free+0x60>
		return;

	if (size)
ffffffffc0202e08:	e1a5                	bnez	a1,ffffffffc0202e68 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e0a:	100027f3          	csrr	a5,sstatus
ffffffffc0202e0e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202e10:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e12:	e3bd                	bnez	a5,ffffffffc0202e78 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e14:	0009e797          	auipc	a5,0x9e
ffffffffc0202e18:	5e478793          	addi	a5,a5,1508 # ffffffffc02a13f8 <slobfree>
ffffffffc0202e1c:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e1e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e20:	00a7fa63          	bgeu	a5,a0,ffffffffc0202e34 <slob_free+0x2e>
ffffffffc0202e24:	00e56c63          	bltu	a0,a4,ffffffffc0202e3c <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e28:	00e7fa63          	bgeu	a5,a4,ffffffffc0202e3c <slob_free+0x36>
    return 0;
ffffffffc0202e2c:	87ba                	mv	a5,a4
ffffffffc0202e2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e30:	fea7eae3          	bltu	a5,a0,ffffffffc0202e24 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e34:	fee7ece3          	bltu	a5,a4,ffffffffc0202e2c <slob_free+0x26>
ffffffffc0202e38:	fee57ae3          	bgeu	a0,a4,ffffffffc0202e2c <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202e3c:	4110                	lw	a2,0(a0)
ffffffffc0202e3e:	00461693          	slli	a3,a2,0x4
ffffffffc0202e42:	96aa                	add	a3,a3,a0
ffffffffc0202e44:	08d70b63          	beq	a4,a3,ffffffffc0202eda <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202e48:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0202e4a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202e4c:	00469713          	slli	a4,a3,0x4
ffffffffc0202e50:	973e                	add	a4,a4,a5
ffffffffc0202e52:	08e50f63          	beq	a0,a4,ffffffffc0202ef0 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202e56:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0202e58:	0009e717          	auipc	a4,0x9e
ffffffffc0202e5c:	5af73023          	sd	a5,1440(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0202e60:	c199                	beqz	a1,ffffffffc0202e66 <slob_free+0x60>
        intr_enable();
ffffffffc0202e62:	fecfd06f          	j	ffffffffc020064e <intr_enable>
ffffffffc0202e66:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202e68:	05bd                	addi	a1,a1,15
ffffffffc0202e6a:	8191                	srli	a1,a1,0x4
ffffffffc0202e6c:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e6e:	100027f3          	csrr	a5,sstatus
ffffffffc0202e72:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202e74:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e76:	dfd9                	beqz	a5,ffffffffc0202e14 <slob_free+0xe>
{
ffffffffc0202e78:	1101                	addi	sp,sp,-32
ffffffffc0202e7a:	e42a                	sd	a0,8(sp)
ffffffffc0202e7c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0202e7e:	fd6fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e82:	0009e797          	auipc	a5,0x9e
ffffffffc0202e86:	57678793          	addi	a5,a5,1398 # ffffffffc02a13f8 <slobfree>
ffffffffc0202e8a:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0202e8c:	6522                	ld	a0,8(sp)
ffffffffc0202e8e:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e90:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e92:	00a7fa63          	bgeu	a5,a0,ffffffffc0202ea6 <slob_free+0xa0>
ffffffffc0202e96:	00e56c63          	bltu	a0,a4,ffffffffc0202eae <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e9a:	00e7fa63          	bgeu	a5,a4,ffffffffc0202eae <slob_free+0xa8>
    return 0;
ffffffffc0202e9e:	87ba                	mv	a5,a4
ffffffffc0202ea0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202ea2:	fea7eae3          	bltu	a5,a0,ffffffffc0202e96 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202ea6:	fee7ece3          	bltu	a5,a4,ffffffffc0202e9e <slob_free+0x98>
ffffffffc0202eaa:	fee57ae3          	bgeu	a0,a4,ffffffffc0202e9e <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0202eae:	4110                	lw	a2,0(a0)
ffffffffc0202eb0:	00461693          	slli	a3,a2,0x4
ffffffffc0202eb4:	96aa                	add	a3,a3,a0
ffffffffc0202eb6:	04d70763          	beq	a4,a3,ffffffffc0202f04 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0202eba:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202ebc:	4394                	lw	a3,0(a5)
ffffffffc0202ebe:	00469713          	slli	a4,a3,0x4
ffffffffc0202ec2:	973e                	add	a4,a4,a5
ffffffffc0202ec4:	04e50663          	beq	a0,a4,ffffffffc0202f10 <slob_free+0x10a>
		cur->next = b;
ffffffffc0202ec8:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0202eca:	0009e717          	auipc	a4,0x9e
ffffffffc0202ece:	52f73723          	sd	a5,1326(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0202ed2:	e58d                	bnez	a1,ffffffffc0202efc <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202ed4:	60e2                	ld	ra,24(sp)
ffffffffc0202ed6:	6105                	addi	sp,sp,32
ffffffffc0202ed8:	8082                	ret
		b->units += cur->next->units;
ffffffffc0202eda:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202edc:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202ede:	9e35                	addw	a2,a2,a3
ffffffffc0202ee0:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0202ee2:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202ee4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202ee6:	00469713          	slli	a4,a3,0x4
ffffffffc0202eea:	973e                	add	a4,a4,a5
ffffffffc0202eec:	f6e515e3          	bne	a0,a4,ffffffffc0202e56 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0202ef0:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202ef2:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202ef4:	9eb9                	addw	a3,a3,a4
ffffffffc0202ef6:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202ef8:	e790                	sd	a2,8(a5)
ffffffffc0202efa:	bfb9                	j	ffffffffc0202e58 <slob_free+0x52>
}
ffffffffc0202efc:	60e2                	ld	ra,24(sp)
ffffffffc0202efe:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202f00:	f4efd06f          	j	ffffffffc020064e <intr_enable>
		b->units += cur->next->units;
ffffffffc0202f04:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202f06:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202f08:	9e35                	addw	a2,a2,a3
ffffffffc0202f0a:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0202f0c:	e518                	sd	a4,8(a0)
ffffffffc0202f0e:	b77d                	j	ffffffffc0202ebc <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0202f10:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202f12:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202f14:	9eb9                	addw	a3,a3,a4
ffffffffc0202f16:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202f18:	e790                	sd	a2,8(a5)
ffffffffc0202f1a:	bf45                	j	ffffffffc0202eca <slob_free+0xc4>

ffffffffc0202f1c <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202f1c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202f1e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202f20:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202f24:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202f26:	f35fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
  if(!page)
ffffffffc0202f2a:	cd1d                	beqz	a0,ffffffffc0202f68 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0202f2c:	000aa797          	auipc	a5,0xaa
ffffffffc0202f30:	95c78793          	addi	a5,a5,-1700 # ffffffffc02ac888 <pages>
ffffffffc0202f34:	6394                	ld	a3,0(a5)
ffffffffc0202f36:	00006797          	auipc	a5,0x6
ffffffffc0202f3a:	d6a78793          	addi	a5,a5,-662 # ffffffffc0208ca0 <nbase>
ffffffffc0202f3e:	8d15                	sub	a0,a0,a3
ffffffffc0202f40:	6394                	ld	a3,0(a5)
ffffffffc0202f42:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0202f44:	000aa797          	auipc	a5,0xaa
ffffffffc0202f48:	8dc78793          	addi	a5,a5,-1828 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0202f4c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202f4e:	6398                	ld	a4,0(a5)
ffffffffc0202f50:	00c51793          	slli	a5,a0,0xc
ffffffffc0202f54:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f56:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202f58:	00e7fb63          	bgeu	a5,a4,ffffffffc0202f6e <__slob_get_free_pages.isra.0+0x52>
ffffffffc0202f5c:	000aa797          	auipc	a5,0xaa
ffffffffc0202f60:	91c78793          	addi	a5,a5,-1764 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0202f64:	6394                	ld	a3,0(a5)
ffffffffc0202f66:	9536                	add	a0,a0,a3
}
ffffffffc0202f68:	60a2                	ld	ra,8(sp)
ffffffffc0202f6a:	0141                	addi	sp,sp,16
ffffffffc0202f6c:	8082                	ret
ffffffffc0202f6e:	86aa                	mv	a3,a0
ffffffffc0202f70:	00004617          	auipc	a2,0x4
ffffffffc0202f74:	03060613          	addi	a2,a2,48 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0202f78:	06900593          	li	a1,105
ffffffffc0202f7c:	00004517          	auipc	a0,0x4
ffffffffc0202f80:	07c50513          	addi	a0,a0,124 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0202f84:	a90fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202f88 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0202f88:	1101                	addi	sp,sp,-32
ffffffffc0202f8a:	ec06                	sd	ra,24(sp)
ffffffffc0202f8c:	e822                	sd	s0,16(sp)
ffffffffc0202f8e:	e426                	sd	s1,8(sp)
ffffffffc0202f90:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202f92:	01050713          	addi	a4,a0,16
ffffffffc0202f96:	6785                	lui	a5,0x1
ffffffffc0202f98:	0cf77563          	bgeu	a4,a5,ffffffffc0203062 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202f9c:	00f50493          	addi	s1,a0,15
ffffffffc0202fa0:	8091                	srli	s1,s1,0x4
ffffffffc0202fa2:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fa4:	10002673          	csrr	a2,sstatus
ffffffffc0202fa8:	8a09                	andi	a2,a2,2
ffffffffc0202faa:	e64d                	bnez	a2,ffffffffc0203054 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0202fac:	0009e917          	auipc	s2,0x9e
ffffffffc0202fb0:	44c90913          	addi	s2,s2,1100 # ffffffffc02a13f8 <slobfree>
ffffffffc0202fb4:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202fb8:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202fba:	4398                	lw	a4,0(a5)
ffffffffc0202fbc:	0a975063          	bge	a4,s1,ffffffffc020305c <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0202fc0:	00d78b63          	beq	a5,a3,ffffffffc0202fd6 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202fc4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202fc6:	4018                	lw	a4,0(s0)
ffffffffc0202fc8:	02975a63          	bge	a4,s1,ffffffffc0202ffc <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0202fcc:	00093683          	ld	a3,0(s2)
ffffffffc0202fd0:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0202fd2:	fed799e3          	bne	a5,a3,ffffffffc0202fc4 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0202fd6:	e225                	bnez	a2,ffffffffc0203036 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202fd8:	4501                	li	a0,0
ffffffffc0202fda:	f43ff0ef          	jal	ra,ffffffffc0202f1c <__slob_get_free_pages.isra.0>
ffffffffc0202fde:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202fe0:	cd15                	beqz	a0,ffffffffc020301c <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0202fe2:	6585                	lui	a1,0x1
ffffffffc0202fe4:	e23ff0ef          	jal	ra,ffffffffc0202e06 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fe8:	10002673          	csrr	a2,sstatus
ffffffffc0202fec:	8a09                	andi	a2,a2,2
ffffffffc0202fee:	ee15                	bnez	a2,ffffffffc020302a <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0202ff0:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202ff4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202ff6:	4018                	lw	a4,0(s0)
ffffffffc0202ff8:	fc974ae3          	blt	a4,s1,ffffffffc0202fcc <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202ffc:	04e48963          	beq	s1,a4,ffffffffc020304e <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0203000:	00449693          	slli	a3,s1,0x4
ffffffffc0203004:	96a2                	add	a3,a3,s0
ffffffffc0203006:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0203008:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc020300a:	9f05                	subw	a4,a4,s1
ffffffffc020300c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020300e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203010:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0203012:	0009e717          	auipc	a4,0x9e
ffffffffc0203016:	3ef73323          	sd	a5,998(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc020301a:	e20d                	bnez	a2,ffffffffc020303c <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc020301c:	8522                	mv	a0,s0
ffffffffc020301e:	60e2                	ld	ra,24(sp)
ffffffffc0203020:	6442                	ld	s0,16(sp)
ffffffffc0203022:	64a2                	ld	s1,8(sp)
ffffffffc0203024:	6902                	ld	s2,0(sp)
ffffffffc0203026:	6105                	addi	sp,sp,32
ffffffffc0203028:	8082                	ret
        intr_disable();
ffffffffc020302a:	e2afd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc020302e:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0203030:	00093783          	ld	a5,0(s2)
ffffffffc0203034:	b7c1                	j	ffffffffc0202ff4 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0203036:	e18fd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc020303a:	bf79                	j	ffffffffc0202fd8 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc020303c:	e12fd0ef          	jal	ra,ffffffffc020064e <intr_enable>
}
ffffffffc0203040:	8522                	mv	a0,s0
ffffffffc0203042:	60e2                	ld	ra,24(sp)
ffffffffc0203044:	6442                	ld	s0,16(sp)
ffffffffc0203046:	64a2                	ld	s1,8(sp)
ffffffffc0203048:	6902                	ld	s2,0(sp)
ffffffffc020304a:	6105                	addi	sp,sp,32
ffffffffc020304c:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020304e:	6418                	ld	a4,8(s0)
ffffffffc0203050:	e798                	sd	a4,8(a5)
ffffffffc0203052:	b7c1                	j	ffffffffc0203012 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0203054:	e00fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc0203058:	4605                	li	a2,1
ffffffffc020305a:	bf89                	j	ffffffffc0202fac <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020305c:	843e                	mv	s0,a5
ffffffffc020305e:	87b6                	mv	a5,a3
ffffffffc0203060:	bf71                	j	ffffffffc0202ffc <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203062:	00005697          	auipc	a3,0x5
ffffffffc0203066:	95e68693          	addi	a3,a3,-1698 # ffffffffc02079c0 <commands+0x1288>
ffffffffc020306a:	00004617          	auipc	a2,0x4
ffffffffc020306e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203072:	06400593          	li	a1,100
ffffffffc0203076:	00005517          	auipc	a0,0x5
ffffffffc020307a:	96a50513          	addi	a0,a0,-1686 # ffffffffc02079e0 <commands+0x12a8>
ffffffffc020307e:	996fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203082 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203082:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203084:	00005517          	auipc	a0,0x5
ffffffffc0203088:	97450513          	addi	a0,a0,-1676 # ffffffffc02079f8 <commands+0x12c0>
kmalloc_init(void) {
ffffffffc020308c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc020308e:	842fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203092:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203094:	00005517          	auipc	a0,0x5
ffffffffc0203098:	90c50513          	addi	a0,a0,-1780 # ffffffffc02079a0 <commands+0x1268>
}
ffffffffc020309c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020309e:	832fd06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02030a2 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02030a2:	4501                	li	a0,0
ffffffffc02030a4:	8082                	ret

ffffffffc02030a6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02030a6:	1101                	addi	sp,sp,-32
ffffffffc02030a8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02030aa:	6905                	lui	s2,0x1
{
ffffffffc02030ac:	e822                	sd	s0,16(sp)
ffffffffc02030ae:	ec06                	sd	ra,24(sp)
ffffffffc02030b0:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02030b2:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc02030b6:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02030b8:	04a7fc63          	bgeu	a5,a0,ffffffffc0203110 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02030bc:	4561                	li	a0,24
ffffffffc02030be:	ecbff0ef          	jal	ra,ffffffffc0202f88 <slob_alloc.isra.1.constprop.3>
ffffffffc02030c2:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02030c4:	cd21                	beqz	a0,ffffffffc020311c <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02030c6:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02030ca:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02030cc:	00f95763          	bge	s2,a5,ffffffffc02030da <kmalloc+0x34>
ffffffffc02030d0:	6705                	lui	a4,0x1
ffffffffc02030d2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02030d4:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02030d6:	fef74ee3          	blt	a4,a5,ffffffffc02030d2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02030da:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02030dc:	e41ff0ef          	jal	ra,ffffffffc0202f1c <__slob_get_free_pages.isra.0>
ffffffffc02030e0:	e488                	sd	a0,8(s1)
ffffffffc02030e2:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02030e4:	c935                	beqz	a0,ffffffffc0203158 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030e6:	100027f3          	csrr	a5,sstatus
ffffffffc02030ea:	8b89                	andi	a5,a5,2
ffffffffc02030ec:	e3a1                	bnez	a5,ffffffffc020312c <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02030ee:	000a9797          	auipc	a5,0xa9
ffffffffc02030f2:	74278793          	addi	a5,a5,1858 # ffffffffc02ac830 <bigblocks>
ffffffffc02030f6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02030f8:	000a9717          	auipc	a4,0xa9
ffffffffc02030fc:	72973c23          	sd	s1,1848(a4) # ffffffffc02ac830 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203100:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203102:	8522                	mv	a0,s0
ffffffffc0203104:	60e2                	ld	ra,24(sp)
ffffffffc0203106:	6442                	ld	s0,16(sp)
ffffffffc0203108:	64a2                	ld	s1,8(sp)
ffffffffc020310a:	6902                	ld	s2,0(sp)
ffffffffc020310c:	6105                	addi	sp,sp,32
ffffffffc020310e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203110:	0541                	addi	a0,a0,16
ffffffffc0203112:	e77ff0ef          	jal	ra,ffffffffc0202f88 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203116:	01050413          	addi	s0,a0,16
ffffffffc020311a:	f565                	bnez	a0,ffffffffc0203102 <kmalloc+0x5c>
ffffffffc020311c:	4401                	li	s0,0
}
ffffffffc020311e:	8522                	mv	a0,s0
ffffffffc0203120:	60e2                	ld	ra,24(sp)
ffffffffc0203122:	6442                	ld	s0,16(sp)
ffffffffc0203124:	64a2                	ld	s1,8(sp)
ffffffffc0203126:	6902                	ld	s2,0(sp)
ffffffffc0203128:	6105                	addi	sp,sp,32
ffffffffc020312a:	8082                	ret
        intr_disable();
ffffffffc020312c:	d28fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
		bb->next = bigblocks;
ffffffffc0203130:	000a9797          	auipc	a5,0xa9
ffffffffc0203134:	70078793          	addi	a5,a5,1792 # ffffffffc02ac830 <bigblocks>
ffffffffc0203138:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc020313a:	000a9717          	auipc	a4,0xa9
ffffffffc020313e:	6e973b23          	sd	s1,1782(a4) # ffffffffc02ac830 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203142:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0203144:	d0afd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203148:	6480                	ld	s0,8(s1)
}
ffffffffc020314a:	60e2                	ld	ra,24(sp)
ffffffffc020314c:	64a2                	ld	s1,8(sp)
ffffffffc020314e:	8522                	mv	a0,s0
ffffffffc0203150:	6442                	ld	s0,16(sp)
ffffffffc0203152:	6902                	ld	s2,0(sp)
ffffffffc0203154:	6105                	addi	sp,sp,32
ffffffffc0203156:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203158:	45e1                	li	a1,24
ffffffffc020315a:	8526                	mv	a0,s1
ffffffffc020315c:	cabff0ef          	jal	ra,ffffffffc0202e06 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203160:	b74d                	j	ffffffffc0203102 <kmalloc+0x5c>

ffffffffc0203162 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203162:	c175                	beqz	a0,ffffffffc0203246 <kfree+0xe4>
{
ffffffffc0203164:	1101                	addi	sp,sp,-32
ffffffffc0203166:	e426                	sd	s1,8(sp)
ffffffffc0203168:	ec06                	sd	ra,24(sp)
ffffffffc020316a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc020316c:	03451793          	slli	a5,a0,0x34
ffffffffc0203170:	84aa                	mv	s1,a0
ffffffffc0203172:	eb8d                	bnez	a5,ffffffffc02031a4 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203174:	100027f3          	csrr	a5,sstatus
ffffffffc0203178:	8b89                	andi	a5,a5,2
ffffffffc020317a:	efc9                	bnez	a5,ffffffffc0203214 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020317c:	000a9797          	auipc	a5,0xa9
ffffffffc0203180:	6b478793          	addi	a5,a5,1716 # ffffffffc02ac830 <bigblocks>
ffffffffc0203184:	6394                	ld	a3,0(a5)
ffffffffc0203186:	ce99                	beqz	a3,ffffffffc02031a4 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0203188:	669c                	ld	a5,8(a3)
ffffffffc020318a:	6a80                	ld	s0,16(a3)
ffffffffc020318c:	0af50e63          	beq	a0,a5,ffffffffc0203248 <kfree+0xe6>
    return 0;
ffffffffc0203190:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203192:	c801                	beqz	s0,ffffffffc02031a2 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203194:	6418                	ld	a4,8(s0)
ffffffffc0203196:	681c                	ld	a5,16(s0)
ffffffffc0203198:	00970f63          	beq	a4,s1,ffffffffc02031b6 <kfree+0x54>
ffffffffc020319c:	86a2                	mv	a3,s0
ffffffffc020319e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02031a0:	f875                	bnez	s0,ffffffffc0203194 <kfree+0x32>
    if (flag) {
ffffffffc02031a2:	e659                	bnez	a2,ffffffffc0203230 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02031a4:	6442                	ld	s0,16(sp)
ffffffffc02031a6:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02031a8:	ff048513          	addi	a0,s1,-16
}
ffffffffc02031ac:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02031ae:	4581                	li	a1,0
}
ffffffffc02031b0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02031b2:	c55ff06f          	j	ffffffffc0202e06 <slob_free>
				*last = bb->next;
ffffffffc02031b6:	ea9c                	sd	a5,16(a3)
ffffffffc02031b8:	e641                	bnez	a2,ffffffffc0203240 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02031ba:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02031be:	4018                	lw	a4,0(s0)
ffffffffc02031c0:	08f4ea63          	bltu	s1,a5,ffffffffc0203254 <kfree+0xf2>
ffffffffc02031c4:	000a9797          	auipc	a5,0xa9
ffffffffc02031c8:	6b478793          	addi	a5,a5,1716 # ffffffffc02ac878 <va_pa_offset>
ffffffffc02031cc:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02031ce:	000a9797          	auipc	a5,0xa9
ffffffffc02031d2:	65278793          	addi	a5,a5,1618 # ffffffffc02ac820 <npage>
ffffffffc02031d6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02031d8:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc02031da:	80b1                	srli	s1,s1,0xc
ffffffffc02031dc:	08f4f963          	bgeu	s1,a5,ffffffffc020326e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc02031e0:	00006797          	auipc	a5,0x6
ffffffffc02031e4:	ac078793          	addi	a5,a5,-1344 # ffffffffc0208ca0 <nbase>
ffffffffc02031e8:	639c                	ld	a5,0(a5)
ffffffffc02031ea:	000a9697          	auipc	a3,0xa9
ffffffffc02031ee:	69e68693          	addi	a3,a3,1694 # ffffffffc02ac888 <pages>
ffffffffc02031f2:	6288                	ld	a0,0(a3)
ffffffffc02031f4:	8c9d                	sub	s1,s1,a5
ffffffffc02031f6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02031f8:	4585                	li	a1,1
ffffffffc02031fa:	9526                	add	a0,a0,s1
ffffffffc02031fc:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203200:	ce3fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203204:	8522                	mv	a0,s0
}
ffffffffc0203206:	6442                	ld	s0,16(sp)
ffffffffc0203208:	60e2                	ld	ra,24(sp)
ffffffffc020320a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020320c:	45e1                	li	a1,24
}
ffffffffc020320e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203210:	bf7ff06f          	j	ffffffffc0202e06 <slob_free>
        intr_disable();
ffffffffc0203214:	c40fd0ef          	jal	ra,ffffffffc0200654 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203218:	000a9797          	auipc	a5,0xa9
ffffffffc020321c:	61878793          	addi	a5,a5,1560 # ffffffffc02ac830 <bigblocks>
ffffffffc0203220:	6394                	ld	a3,0(a5)
ffffffffc0203222:	c699                	beqz	a3,ffffffffc0203230 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203224:	669c                	ld	a5,8(a3)
ffffffffc0203226:	6a80                	ld	s0,16(a3)
ffffffffc0203228:	00f48763          	beq	s1,a5,ffffffffc0203236 <kfree+0xd4>
        return 1;
ffffffffc020322c:	4605                	li	a2,1
ffffffffc020322e:	b795                	j	ffffffffc0203192 <kfree+0x30>
        intr_enable();
ffffffffc0203230:	c1efd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203234:	bf85                	j	ffffffffc02031a4 <kfree+0x42>
				*last = bb->next;
ffffffffc0203236:	000a9797          	auipc	a5,0xa9
ffffffffc020323a:	5e87bd23          	sd	s0,1530(a5) # ffffffffc02ac830 <bigblocks>
ffffffffc020323e:	8436                	mv	s0,a3
ffffffffc0203240:	c0efd0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203244:	bf9d                	j	ffffffffc02031ba <kfree+0x58>
ffffffffc0203246:	8082                	ret
ffffffffc0203248:	000a9797          	auipc	a5,0xa9
ffffffffc020324c:	5e87b423          	sd	s0,1512(a5) # ffffffffc02ac830 <bigblocks>
ffffffffc0203250:	8436                	mv	s0,a3
ffffffffc0203252:	b7a5                	j	ffffffffc02031ba <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0203254:	86a6                	mv	a3,s1
ffffffffc0203256:	00004617          	auipc	a2,0x4
ffffffffc020325a:	e2260613          	addi	a2,a2,-478 # ffffffffc0207078 <commands+0x940>
ffffffffc020325e:	06e00593          	li	a1,110
ffffffffc0203262:	00004517          	auipc	a0,0x4
ffffffffc0203266:	d9650513          	addi	a0,a0,-618 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc020326a:	fabfc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020326e:	00004617          	auipc	a2,0x4
ffffffffc0203272:	d6a60613          	addi	a2,a2,-662 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc0203276:	06200593          	li	a1,98
ffffffffc020327a:	00004517          	auipc	a0,0x4
ffffffffc020327e:	d7e50513          	addi	a0,a0,-642 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0203282:	f93fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203286 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0203286:	7135                	addi	sp,sp,-160
ffffffffc0203288:	ed06                	sd	ra,152(sp)
ffffffffc020328a:	e922                	sd	s0,144(sp)
ffffffffc020328c:	e526                	sd	s1,136(sp)
ffffffffc020328e:	e14a                	sd	s2,128(sp)
ffffffffc0203290:	fcce                	sd	s3,120(sp)
ffffffffc0203292:	f8d2                	sd	s4,112(sp)
ffffffffc0203294:	f4d6                	sd	s5,104(sp)
ffffffffc0203296:	f0da                	sd	s6,96(sp)
ffffffffc0203298:	ecde                	sd	s7,88(sp)
ffffffffc020329a:	e8e2                	sd	s8,80(sp)
ffffffffc020329c:	e4e6                	sd	s9,72(sp)
ffffffffc020329e:	e0ea                	sd	s10,64(sp)
ffffffffc02032a0:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02032a2:	049010ef          	jal	ra,ffffffffc0204aea <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02032a6:	000a9797          	auipc	a5,0xa9
ffffffffc02032aa:	67a78793          	addi	a5,a5,1658 # ffffffffc02ac920 <max_swap_offset>
ffffffffc02032ae:	6394                	ld	a3,0(a5)
ffffffffc02032b0:	010007b7          	lui	a5,0x1000
ffffffffc02032b4:	17e1                	addi	a5,a5,-8
ffffffffc02032b6:	ff968713          	addi	a4,a3,-7
ffffffffc02032ba:	4ae7ee63          	bltu	a5,a4,ffffffffc0203776 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02032be:	0009e797          	auipc	a5,0x9e
ffffffffc02032c2:	0fa78793          	addi	a5,a5,250 # ffffffffc02a13b8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02032c6:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02032c8:	000a9697          	auipc	a3,0xa9
ffffffffc02032cc:	56f6b823          	sd	a5,1392(a3) # ffffffffc02ac838 <sm>
     int r = sm->init();
ffffffffc02032d0:	9702                	jalr	a4
ffffffffc02032d2:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02032d4:	c10d                	beqz	a0,ffffffffc02032f6 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02032d6:	60ea                	ld	ra,152(sp)
ffffffffc02032d8:	644a                	ld	s0,144(sp)
ffffffffc02032da:	8556                	mv	a0,s5
ffffffffc02032dc:	64aa                	ld	s1,136(sp)
ffffffffc02032de:	690a                	ld	s2,128(sp)
ffffffffc02032e0:	79e6                	ld	s3,120(sp)
ffffffffc02032e2:	7a46                	ld	s4,112(sp)
ffffffffc02032e4:	7aa6                	ld	s5,104(sp)
ffffffffc02032e6:	7b06                	ld	s6,96(sp)
ffffffffc02032e8:	6be6                	ld	s7,88(sp)
ffffffffc02032ea:	6c46                	ld	s8,80(sp)
ffffffffc02032ec:	6ca6                	ld	s9,72(sp)
ffffffffc02032ee:	6d06                	ld	s10,64(sp)
ffffffffc02032f0:	7de2                	ld	s11,56(sp)
ffffffffc02032f2:	610d                	addi	sp,sp,160
ffffffffc02032f4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02032f6:	000a9797          	auipc	a5,0xa9
ffffffffc02032fa:	54278793          	addi	a5,a5,1346 # ffffffffc02ac838 <sm>
ffffffffc02032fe:	639c                	ld	a5,0(a5)
ffffffffc0203300:	00004517          	auipc	a0,0x4
ffffffffc0203304:	79050513          	addi	a0,a0,1936 # ffffffffc0207a90 <commands+0x1358>
ffffffffc0203308:	000a9417          	auipc	s0,0xa9
ffffffffc020330c:	65840413          	addi	s0,s0,1624 # ffffffffc02ac960 <free_area>
ffffffffc0203310:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203312:	4785                	li	a5,1
ffffffffc0203314:	000a9717          	auipc	a4,0xa9
ffffffffc0203318:	52f72623          	sw	a5,1324(a4) # ffffffffc02ac840 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020331c:	db5fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0203320:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203322:	36878e63          	beq	a5,s0,ffffffffc020369e <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203326:	ff07b703          	ld	a4,-16(a5)
ffffffffc020332a:	8305                	srli	a4,a4,0x1
ffffffffc020332c:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020332e:	36070c63          	beqz	a4,ffffffffc02036a6 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203332:	4481                	li	s1,0
ffffffffc0203334:	4901                	li	s2,0
ffffffffc0203336:	a031                	j	ffffffffc0203342 <swap_init+0xbc>
ffffffffc0203338:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020333c:	8b09                	andi	a4,a4,2
ffffffffc020333e:	36070463          	beqz	a4,ffffffffc02036a6 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203342:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203346:	679c                	ld	a5,8(a5)
ffffffffc0203348:	2905                	addiw	s2,s2,1
ffffffffc020334a:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020334c:	fe8796e3          	bne	a5,s0,ffffffffc0203338 <swap_init+0xb2>
ffffffffc0203350:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203352:	bd7fd0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0203356:	69351863          	bne	a0,s3,ffffffffc02039e6 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020335a:	8626                	mv	a2,s1
ffffffffc020335c:	85ca                	mv	a1,s2
ffffffffc020335e:	00004517          	auipc	a0,0x4
ffffffffc0203362:	77a50513          	addi	a0,a0,1914 # ffffffffc0207ad8 <commands+0x13a0>
ffffffffc0203366:	d6bfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020336a:	840ff0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc020336e:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203370:	60050b63          	beqz	a0,ffffffffc0203986 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203374:	000a9797          	auipc	a5,0xa9
ffffffffc0203378:	51c78793          	addi	a5,a5,1308 # ffffffffc02ac890 <check_mm_struct>
ffffffffc020337c:	639c                	ld	a5,0(a5)
ffffffffc020337e:	62079463          	bnez	a5,ffffffffc02039a6 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203382:	000a9797          	auipc	a5,0xa9
ffffffffc0203386:	49678793          	addi	a5,a5,1174 # ffffffffc02ac818 <boot_pgdir>
ffffffffc020338a:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc020338e:	000a9797          	auipc	a5,0xa9
ffffffffc0203392:	50a7b123          	sd	a0,1282(a5) # ffffffffc02ac890 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0203396:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75538>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020339a:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020339e:	4e079863          	bnez	a5,ffffffffc020388e <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02033a2:	6599                	lui	a1,0x6
ffffffffc02033a4:	460d                	li	a2,3
ffffffffc02033a6:	6505                	lui	a0,0x1
ffffffffc02033a8:	84eff0ef          	jal	ra,ffffffffc02023f6 <vma_create>
ffffffffc02033ac:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02033ae:	50050063          	beqz	a0,ffffffffc02038ae <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02033b2:	855e                	mv	a0,s7
ffffffffc02033b4:	8aeff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02033b8:	00004517          	auipc	a0,0x4
ffffffffc02033bc:	76050513          	addi	a0,a0,1888 # ffffffffc0207b18 <commands+0x13e0>
ffffffffc02033c0:	d11fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02033c4:	018bb503          	ld	a0,24(s7)
ffffffffc02033c8:	4605                	li	a2,1
ffffffffc02033ca:	6585                	lui	a1,0x1
ffffffffc02033cc:	b9dfd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02033d0:	4e050f63          	beqz	a0,ffffffffc02038ce <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02033d4:	00004517          	auipc	a0,0x4
ffffffffc02033d8:	79450513          	addi	a0,a0,1940 # ffffffffc0207b68 <commands+0x1430>
ffffffffc02033dc:	000a9997          	auipc	s3,0xa9
ffffffffc02033e0:	4bc98993          	addi	s3,s3,1212 # ffffffffc02ac898 <check_rp>
ffffffffc02033e4:	cedfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02033e8:	000a9a17          	auipc	s4,0xa9
ffffffffc02033ec:	4d0a0a13          	addi	s4,s4,1232 # ffffffffc02ac8b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02033f0:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02033f2:	4505                	li	a0,1
ffffffffc02033f4:	a67fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02033f8:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02033fc:	32050d63          	beqz	a0,ffffffffc0203736 <swap_init+0x4b0>
ffffffffc0203400:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203402:	8b89                	andi	a5,a5,2
ffffffffc0203404:	30079963          	bnez	a5,ffffffffc0203716 <swap_init+0x490>
ffffffffc0203408:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020340a:	ff4c14e3          	bne	s8,s4,ffffffffc02033f2 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc020340e:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203410:	000a9c17          	auipc	s8,0xa9
ffffffffc0203414:	488c0c13          	addi	s8,s8,1160 # ffffffffc02ac898 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0203418:	ec3e                	sd	a5,24(sp)
ffffffffc020341a:	641c                	ld	a5,8(s0)
ffffffffc020341c:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc020341e:	481c                	lw	a5,16(s0)
ffffffffc0203420:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203422:	000a9797          	auipc	a5,0xa9
ffffffffc0203426:	5487b323          	sd	s0,1350(a5) # ffffffffc02ac968 <free_area+0x8>
ffffffffc020342a:	000a9797          	auipc	a5,0xa9
ffffffffc020342e:	5287bb23          	sd	s0,1334(a5) # ffffffffc02ac960 <free_area>
     nr_free = 0;
ffffffffc0203432:	000a9797          	auipc	a5,0xa9
ffffffffc0203436:	5207af23          	sw	zero,1342(a5) # ffffffffc02ac970 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020343a:	000c3503          	ld	a0,0(s8)
ffffffffc020343e:	4585                	li	a1,1
ffffffffc0203440:	0c21                	addi	s8,s8,8
ffffffffc0203442:	aa1fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203446:	ff4c1ae3          	bne	s8,s4,ffffffffc020343a <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020344a:	01042c03          	lw	s8,16(s0)
ffffffffc020344e:	4791                	li	a5,4
ffffffffc0203450:	50fc1b63          	bne	s8,a5,ffffffffc0203966 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203454:	00004517          	auipc	a0,0x4
ffffffffc0203458:	79c50513          	addi	a0,a0,1948 # ffffffffc0207bf0 <commands+0x14b8>
ffffffffc020345c:	c75fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203460:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203462:	000a9797          	auipc	a5,0xa9
ffffffffc0203466:	3c07a323          	sw	zero,966(a5) # ffffffffc02ac828 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020346a:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020346c:	000a9797          	auipc	a5,0xa9
ffffffffc0203470:	3bc78793          	addi	a5,a5,956 # ffffffffc02ac828 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203474:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc0203478:	4398                	lw	a4,0(a5)
ffffffffc020347a:	4585                	li	a1,1
ffffffffc020347c:	2701                	sext.w	a4,a4
ffffffffc020347e:	38b71863          	bne	a4,a1,ffffffffc020380e <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203482:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0203486:	4394                	lw	a3,0(a5)
ffffffffc0203488:	2681                	sext.w	a3,a3
ffffffffc020348a:	3ae69263          	bne	a3,a4,ffffffffc020382e <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020348e:	6689                	lui	a3,0x2
ffffffffc0203490:	462d                	li	a2,11
ffffffffc0203492:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc0203496:	4398                	lw	a4,0(a5)
ffffffffc0203498:	4589                	li	a1,2
ffffffffc020349a:	2701                	sext.w	a4,a4
ffffffffc020349c:	2eb71963          	bne	a4,a1,ffffffffc020378e <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02034a0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02034a4:	4394                	lw	a3,0(a5)
ffffffffc02034a6:	2681                	sext.w	a3,a3
ffffffffc02034a8:	30e69363          	bne	a3,a4,ffffffffc02037ae <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034ac:	668d                	lui	a3,0x3
ffffffffc02034ae:	4631                	li	a2,12
ffffffffc02034b0:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc02034b4:	4398                	lw	a4,0(a5)
ffffffffc02034b6:	458d                	li	a1,3
ffffffffc02034b8:	2701                	sext.w	a4,a4
ffffffffc02034ba:	30b71a63          	bne	a4,a1,ffffffffc02037ce <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02034be:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02034c2:	4394                	lw	a3,0(a5)
ffffffffc02034c4:	2681                	sext.w	a3,a3
ffffffffc02034c6:	32e69463          	bne	a3,a4,ffffffffc02037ee <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034ca:	6691                	lui	a3,0x4
ffffffffc02034cc:	4635                	li	a2,13
ffffffffc02034ce:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc02034d2:	4398                	lw	a4,0(a5)
ffffffffc02034d4:	2701                	sext.w	a4,a4
ffffffffc02034d6:	37871c63          	bne	a4,s8,ffffffffc020384e <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02034da:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02034de:	439c                	lw	a5,0(a5)
ffffffffc02034e0:	2781                	sext.w	a5,a5
ffffffffc02034e2:	38e79663          	bne	a5,a4,ffffffffc020386e <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02034e6:	481c                	lw	a5,16(s0)
ffffffffc02034e8:	40079363          	bnez	a5,ffffffffc02038ee <swap_init+0x668>
ffffffffc02034ec:	000a9797          	auipc	a5,0xa9
ffffffffc02034f0:	3cc78793          	addi	a5,a5,972 # ffffffffc02ac8b8 <swap_in_seq_no>
ffffffffc02034f4:	000a9717          	auipc	a4,0xa9
ffffffffc02034f8:	3ec70713          	addi	a4,a4,1004 # ffffffffc02ac8e0 <swap_out_seq_no>
ffffffffc02034fc:	000a9617          	auipc	a2,0xa9
ffffffffc0203500:	3e460613          	addi	a2,a2,996 # ffffffffc02ac8e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203504:	56fd                	li	a3,-1
ffffffffc0203506:	c394                	sw	a3,0(a5)
ffffffffc0203508:	c314                	sw	a3,0(a4)
ffffffffc020350a:	0791                	addi	a5,a5,4
ffffffffc020350c:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc020350e:	fef61ce3          	bne	a2,a5,ffffffffc0203506 <swap_init+0x280>
ffffffffc0203512:	000a9697          	auipc	a3,0xa9
ffffffffc0203516:	42e68693          	addi	a3,a3,1070 # ffffffffc02ac940 <check_ptep>
ffffffffc020351a:	000a9817          	auipc	a6,0xa9
ffffffffc020351e:	37e80813          	addi	a6,a6,894 # ffffffffc02ac898 <check_rp>
ffffffffc0203522:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203524:	000a9c97          	auipc	s9,0xa9
ffffffffc0203528:	2fcc8c93          	addi	s9,s9,764 # ffffffffc02ac820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020352c:	00005d97          	auipc	s11,0x5
ffffffffc0203530:	774d8d93          	addi	s11,s11,1908 # ffffffffc0208ca0 <nbase>
ffffffffc0203534:	000a9c17          	auipc	s8,0xa9
ffffffffc0203538:	354c0c13          	addi	s8,s8,852 # ffffffffc02ac888 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020353c:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203540:	4601                	li	a2,0
ffffffffc0203542:	85ea                	mv	a1,s10
ffffffffc0203544:	855a                	mv	a0,s6
ffffffffc0203546:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203548:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020354a:	a1ffd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc020354e:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203550:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203552:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203554:	20050163          	beqz	a0,ffffffffc0203756 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203558:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020355a:	0017f613          	andi	a2,a5,1
ffffffffc020355e:	1a060063          	beqz	a2,ffffffffc02036fe <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203562:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203566:	078a                	slli	a5,a5,0x2
ffffffffc0203568:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020356a:	14c7fe63          	bgeu	a5,a2,ffffffffc02036c6 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020356e:	000db703          	ld	a4,0(s11)
ffffffffc0203572:	000c3603          	ld	a2,0(s8)
ffffffffc0203576:	00083583          	ld	a1,0(a6)
ffffffffc020357a:	8f99                	sub	a5,a5,a4
ffffffffc020357c:	079a                	slli	a5,a5,0x6
ffffffffc020357e:	e43a                	sd	a4,8(sp)
ffffffffc0203580:	97b2                	add	a5,a5,a2
ffffffffc0203582:	14f59e63          	bne	a1,a5,ffffffffc02036de <swap_init+0x458>
ffffffffc0203586:	6785                	lui	a5,0x1
ffffffffc0203588:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020358a:	6795                	lui	a5,0x5
ffffffffc020358c:	06a1                	addi	a3,a3,8
ffffffffc020358e:	0821                	addi	a6,a6,8
ffffffffc0203590:	fafd16e3          	bne	s10,a5,ffffffffc020353c <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203594:	00004517          	auipc	a0,0x4
ffffffffc0203598:	71450513          	addi	a0,a0,1812 # ffffffffc0207ca8 <commands+0x1570>
ffffffffc020359c:	b35fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc02035a0:	000a9797          	auipc	a5,0xa9
ffffffffc02035a4:	29878793          	addi	a5,a5,664 # ffffffffc02ac838 <sm>
ffffffffc02035a8:	639c                	ld	a5,0(a5)
ffffffffc02035aa:	7f9c                	ld	a5,56(a5)
ffffffffc02035ac:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02035ae:	40051c63          	bnez	a0,ffffffffc02039c6 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02035b2:	77a2                	ld	a5,40(sp)
ffffffffc02035b4:	000a9717          	auipc	a4,0xa9
ffffffffc02035b8:	3af72e23          	sw	a5,956(a4) # ffffffffc02ac970 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02035bc:	67e2                	ld	a5,24(sp)
ffffffffc02035be:	000a9717          	auipc	a4,0xa9
ffffffffc02035c2:	3af73123          	sd	a5,930(a4) # ffffffffc02ac960 <free_area>
ffffffffc02035c6:	7782                	ld	a5,32(sp)
ffffffffc02035c8:	000a9717          	auipc	a4,0xa9
ffffffffc02035cc:	3af73023          	sd	a5,928(a4) # ffffffffc02ac968 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02035d0:	0009b503          	ld	a0,0(s3)
ffffffffc02035d4:	4585                	li	a1,1
ffffffffc02035d6:	09a1                	addi	s3,s3,8
ffffffffc02035d8:	90bfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035dc:	ff499ae3          	bne	s3,s4,ffffffffc02035d0 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02035e0:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02035e4:	855e                	mv	a0,s7
ffffffffc02035e6:	f4bfe0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02035ea:	000a9797          	auipc	a5,0xa9
ffffffffc02035ee:	22e78793          	addi	a5,a5,558 # ffffffffc02ac818 <boot_pgdir>
ffffffffc02035f2:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02035f4:	000a9697          	auipc	a3,0xa9
ffffffffc02035f8:	2806be23          	sd	zero,668(a3) # ffffffffc02ac890 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02035fc:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203600:	6394                	ld	a3,0(a5)
ffffffffc0203602:	068a                	slli	a3,a3,0x2
ffffffffc0203604:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203606:	0ce6f063          	bgeu	a3,a4,ffffffffc02036c6 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020360a:	67a2                	ld	a5,8(sp)
ffffffffc020360c:	000c3503          	ld	a0,0(s8)
ffffffffc0203610:	8e9d                	sub	a3,a3,a5
ffffffffc0203612:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203614:	8699                	srai	a3,a3,0x6
ffffffffc0203616:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0203618:	00c69793          	slli	a5,a3,0xc
ffffffffc020361c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020361e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203620:	2ee7f763          	bgeu	a5,a4,ffffffffc020390e <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203624:	000a9797          	auipc	a5,0xa9
ffffffffc0203628:	25478793          	addi	a5,a5,596 # ffffffffc02ac878 <va_pa_offset>
ffffffffc020362c:	639c                	ld	a5,0(a5)
ffffffffc020362e:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203630:	629c                	ld	a5,0(a3)
ffffffffc0203632:	078a                	slli	a5,a5,0x2
ffffffffc0203634:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203636:	08e7f863          	bgeu	a5,a4,ffffffffc02036c6 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020363a:	69a2                	ld	s3,8(sp)
ffffffffc020363c:	4585                	li	a1,1
ffffffffc020363e:	413787b3          	sub	a5,a5,s3
ffffffffc0203642:	079a                	slli	a5,a5,0x6
ffffffffc0203644:	953e                	add	a0,a0,a5
ffffffffc0203646:	89dfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020364a:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020364e:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203652:	078a                	slli	a5,a5,0x2
ffffffffc0203654:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203656:	06e7f863          	bgeu	a5,a4,ffffffffc02036c6 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020365a:	000c3503          	ld	a0,0(s8)
ffffffffc020365e:	413787b3          	sub	a5,a5,s3
ffffffffc0203662:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203664:	4585                	li	a1,1
ffffffffc0203666:	953e                	add	a0,a0,a5
ffffffffc0203668:	87bfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     pgdir[0] = 0;
ffffffffc020366c:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203670:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203674:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203676:	00878963          	beq	a5,s0,ffffffffc0203688 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020367a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020367e:	679c                	ld	a5,8(a5)
ffffffffc0203680:	397d                	addiw	s2,s2,-1
ffffffffc0203682:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203684:	fe879be3          	bne	a5,s0,ffffffffc020367a <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203688:	28091f63          	bnez	s2,ffffffffc0203926 <swap_init+0x6a0>
     assert(total==0);
ffffffffc020368c:	2a049d63          	bnez	s1,ffffffffc0203946 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203690:	00004517          	auipc	a0,0x4
ffffffffc0203694:	66850513          	addi	a0,a0,1640 # ffffffffc0207cf8 <commands+0x15c0>
ffffffffc0203698:	a39fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020369c:	b92d                	j	ffffffffc02032d6 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020369e:	4481                	li	s1,0
ffffffffc02036a0:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02036a2:	4981                	li	s3,0
ffffffffc02036a4:	b17d                	j	ffffffffc0203352 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02036a6:	00004697          	auipc	a3,0x4
ffffffffc02036aa:	40268693          	addi	a3,a3,1026 # ffffffffc0207aa8 <commands+0x1370>
ffffffffc02036ae:	00003617          	auipc	a2,0x3
ffffffffc02036b2:	50a60613          	addi	a2,a2,1290 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02036b6:	0bc00593          	li	a1,188
ffffffffc02036ba:	00004517          	auipc	a0,0x4
ffffffffc02036be:	3c650513          	addi	a0,a0,966 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02036c2:	b53fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02036c6:	00004617          	auipc	a2,0x4
ffffffffc02036ca:	91260613          	addi	a2,a2,-1774 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc02036ce:	06200593          	li	a1,98
ffffffffc02036d2:	00004517          	auipc	a0,0x4
ffffffffc02036d6:	92650513          	addi	a0,a0,-1754 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02036da:	b3bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02036de:	00004697          	auipc	a3,0x4
ffffffffc02036e2:	5a268693          	addi	a3,a3,1442 # ffffffffc0207c80 <commands+0x1548>
ffffffffc02036e6:	00003617          	auipc	a2,0x3
ffffffffc02036ea:	4d260613          	addi	a2,a2,1234 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02036ee:	0fc00593          	li	a1,252
ffffffffc02036f2:	00004517          	auipc	a0,0x4
ffffffffc02036f6:	38e50513          	addi	a0,a0,910 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02036fa:	b1bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02036fe:	00004617          	auipc	a2,0x4
ffffffffc0203702:	aba60613          	addi	a2,a2,-1350 # ffffffffc02071b8 <commands+0xa80>
ffffffffc0203706:	07400593          	li	a1,116
ffffffffc020370a:	00004517          	auipc	a0,0x4
ffffffffc020370e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0203712:	b03fc0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203716:	00004697          	auipc	a3,0x4
ffffffffc020371a:	49268693          	addi	a3,a3,1170 # ffffffffc0207ba8 <commands+0x1470>
ffffffffc020371e:	00003617          	auipc	a2,0x3
ffffffffc0203722:	49a60613          	addi	a2,a2,1178 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203726:	0dd00593          	li	a1,221
ffffffffc020372a:	00004517          	auipc	a0,0x4
ffffffffc020372e:	35650513          	addi	a0,a0,854 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203732:	ae3fc0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203736:	00004697          	auipc	a3,0x4
ffffffffc020373a:	45a68693          	addi	a3,a3,1114 # ffffffffc0207b90 <commands+0x1458>
ffffffffc020373e:	00003617          	auipc	a2,0x3
ffffffffc0203742:	47a60613          	addi	a2,a2,1146 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203746:	0dc00593          	li	a1,220
ffffffffc020374a:	00004517          	auipc	a0,0x4
ffffffffc020374e:	33650513          	addi	a0,a0,822 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203752:	ac3fc0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203756:	00004697          	auipc	a3,0x4
ffffffffc020375a:	51268693          	addi	a3,a3,1298 # ffffffffc0207c68 <commands+0x1530>
ffffffffc020375e:	00003617          	auipc	a2,0x3
ffffffffc0203762:	45a60613          	addi	a2,a2,1114 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203766:	0fb00593          	li	a1,251
ffffffffc020376a:	00004517          	auipc	a0,0x4
ffffffffc020376e:	31650513          	addi	a0,a0,790 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203772:	aa3fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203776:	00004617          	auipc	a2,0x4
ffffffffc020377a:	2ea60613          	addi	a2,a2,746 # ffffffffc0207a60 <commands+0x1328>
ffffffffc020377e:	02800593          	li	a1,40
ffffffffc0203782:	00004517          	auipc	a0,0x4
ffffffffc0203786:	2fe50513          	addi	a0,a0,766 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020378a:	a8bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc020378e:	00004697          	auipc	a3,0x4
ffffffffc0203792:	49a68693          	addi	a3,a3,1178 # ffffffffc0207c28 <commands+0x14f0>
ffffffffc0203796:	00003617          	auipc	a2,0x3
ffffffffc020379a:	42260613          	addi	a2,a2,1058 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020379e:	09700593          	li	a1,151
ffffffffc02037a2:	00004517          	auipc	a0,0x4
ffffffffc02037a6:	2de50513          	addi	a0,a0,734 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02037aa:	a6bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc02037ae:	00004697          	auipc	a3,0x4
ffffffffc02037b2:	47a68693          	addi	a3,a3,1146 # ffffffffc0207c28 <commands+0x14f0>
ffffffffc02037b6:	00003617          	auipc	a2,0x3
ffffffffc02037ba:	40260613          	addi	a2,a2,1026 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02037be:	09900593          	li	a1,153
ffffffffc02037c2:	00004517          	auipc	a0,0x4
ffffffffc02037c6:	2be50513          	addi	a0,a0,702 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02037ca:	a4bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc02037ce:	00004697          	auipc	a3,0x4
ffffffffc02037d2:	46a68693          	addi	a3,a3,1130 # ffffffffc0207c38 <commands+0x1500>
ffffffffc02037d6:	00003617          	auipc	a2,0x3
ffffffffc02037da:	3e260613          	addi	a2,a2,994 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02037de:	09b00593          	li	a1,155
ffffffffc02037e2:	00004517          	auipc	a0,0x4
ffffffffc02037e6:	29e50513          	addi	a0,a0,670 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02037ea:	a2bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc02037ee:	00004697          	auipc	a3,0x4
ffffffffc02037f2:	44a68693          	addi	a3,a3,1098 # ffffffffc0207c38 <commands+0x1500>
ffffffffc02037f6:	00003617          	auipc	a2,0x3
ffffffffc02037fa:	3c260613          	addi	a2,a2,962 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02037fe:	09d00593          	li	a1,157
ffffffffc0203802:	00004517          	auipc	a0,0x4
ffffffffc0203806:	27e50513          	addi	a0,a0,638 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020380a:	a0bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc020380e:	00004697          	auipc	a3,0x4
ffffffffc0203812:	40a68693          	addi	a3,a3,1034 # ffffffffc0207c18 <commands+0x14e0>
ffffffffc0203816:	00003617          	auipc	a2,0x3
ffffffffc020381a:	3a260613          	addi	a2,a2,930 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020381e:	09300593          	li	a1,147
ffffffffc0203822:	00004517          	auipc	a0,0x4
ffffffffc0203826:	25e50513          	addi	a0,a0,606 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020382a:	9ebfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc020382e:	00004697          	auipc	a3,0x4
ffffffffc0203832:	3ea68693          	addi	a3,a3,1002 # ffffffffc0207c18 <commands+0x14e0>
ffffffffc0203836:	00003617          	auipc	a2,0x3
ffffffffc020383a:	38260613          	addi	a2,a2,898 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020383e:	09500593          	li	a1,149
ffffffffc0203842:	00004517          	auipc	a0,0x4
ffffffffc0203846:	23e50513          	addi	a0,a0,574 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020384a:	9cbfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc020384e:	00004697          	auipc	a3,0x4
ffffffffc0203852:	3fa68693          	addi	a3,a3,1018 # ffffffffc0207c48 <commands+0x1510>
ffffffffc0203856:	00003617          	auipc	a2,0x3
ffffffffc020385a:	36260613          	addi	a2,a2,866 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020385e:	09f00593          	li	a1,159
ffffffffc0203862:	00004517          	auipc	a0,0x4
ffffffffc0203866:	21e50513          	addi	a0,a0,542 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020386a:	9abfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc020386e:	00004697          	auipc	a3,0x4
ffffffffc0203872:	3da68693          	addi	a3,a3,986 # ffffffffc0207c48 <commands+0x1510>
ffffffffc0203876:	00003617          	auipc	a2,0x3
ffffffffc020387a:	34260613          	addi	a2,a2,834 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020387e:	0a100593          	li	a1,161
ffffffffc0203882:	00004517          	auipc	a0,0x4
ffffffffc0203886:	1fe50513          	addi	a0,a0,510 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020388a:	98bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgdir[0] == 0);
ffffffffc020388e:	00004697          	auipc	a3,0x4
ffffffffc0203892:	06268693          	addi	a3,a3,98 # ffffffffc02078f0 <commands+0x11b8>
ffffffffc0203896:	00003617          	auipc	a2,0x3
ffffffffc020389a:	32260613          	addi	a2,a2,802 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020389e:	0cc00593          	li	a1,204
ffffffffc02038a2:	00004517          	auipc	a0,0x4
ffffffffc02038a6:	1de50513          	addi	a0,a0,478 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02038aa:	96bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(vma != NULL);
ffffffffc02038ae:	00004697          	auipc	a3,0x4
ffffffffc02038b2:	0e268693          	addi	a3,a3,226 # ffffffffc0207990 <commands+0x1258>
ffffffffc02038b6:	00003617          	auipc	a2,0x3
ffffffffc02038ba:	30260613          	addi	a2,a2,770 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02038be:	0cf00593          	li	a1,207
ffffffffc02038c2:	00004517          	auipc	a0,0x4
ffffffffc02038c6:	1be50513          	addi	a0,a0,446 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02038ca:	94bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02038ce:	00004697          	auipc	a3,0x4
ffffffffc02038d2:	28268693          	addi	a3,a3,642 # ffffffffc0207b50 <commands+0x1418>
ffffffffc02038d6:	00003617          	auipc	a2,0x3
ffffffffc02038da:	2e260613          	addi	a2,a2,738 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02038de:	0d700593          	li	a1,215
ffffffffc02038e2:	00004517          	auipc	a0,0x4
ffffffffc02038e6:	19e50513          	addi	a0,a0,414 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02038ea:	92bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert( nr_free == 0);         
ffffffffc02038ee:	00004697          	auipc	a3,0x4
ffffffffc02038f2:	36a68693          	addi	a3,a3,874 # ffffffffc0207c58 <commands+0x1520>
ffffffffc02038f6:	00003617          	auipc	a2,0x3
ffffffffc02038fa:	2c260613          	addi	a2,a2,706 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02038fe:	0f300593          	li	a1,243
ffffffffc0203902:	00004517          	auipc	a0,0x4
ffffffffc0203906:	17e50513          	addi	a0,a0,382 # ffffffffc0207a80 <commands+0x1348>
ffffffffc020390a:	90bfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc020390e:	00003617          	auipc	a2,0x3
ffffffffc0203912:	69260613          	addi	a2,a2,1682 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0203916:	06900593          	li	a1,105
ffffffffc020391a:	00003517          	auipc	a0,0x3
ffffffffc020391e:	6de50513          	addi	a0,a0,1758 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0203922:	8f3fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(count==0);
ffffffffc0203926:	00004697          	auipc	a3,0x4
ffffffffc020392a:	3b268693          	addi	a3,a3,946 # ffffffffc0207cd8 <commands+0x15a0>
ffffffffc020392e:	00003617          	auipc	a2,0x3
ffffffffc0203932:	28a60613          	addi	a2,a2,650 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203936:	11d00593          	li	a1,285
ffffffffc020393a:	00004517          	auipc	a0,0x4
ffffffffc020393e:	14650513          	addi	a0,a0,326 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203942:	8d3fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total==0);
ffffffffc0203946:	00004697          	auipc	a3,0x4
ffffffffc020394a:	3a268693          	addi	a3,a3,930 # ffffffffc0207ce8 <commands+0x15b0>
ffffffffc020394e:	00003617          	auipc	a2,0x3
ffffffffc0203952:	26a60613          	addi	a2,a2,618 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203956:	11e00593          	li	a1,286
ffffffffc020395a:	00004517          	auipc	a0,0x4
ffffffffc020395e:	12650513          	addi	a0,a0,294 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203962:	8b3fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203966:	00004697          	auipc	a3,0x4
ffffffffc020396a:	26268693          	addi	a3,a3,610 # ffffffffc0207bc8 <commands+0x1490>
ffffffffc020396e:	00003617          	auipc	a2,0x3
ffffffffc0203972:	24a60613          	addi	a2,a2,586 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203976:	0ea00593          	li	a1,234
ffffffffc020397a:	00004517          	auipc	a0,0x4
ffffffffc020397e:	10650513          	addi	a0,a0,262 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203982:	893fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(mm != NULL);
ffffffffc0203986:	00004697          	auipc	a3,0x4
ffffffffc020398a:	de268693          	addi	a3,a3,-542 # ffffffffc0207768 <commands+0x1030>
ffffffffc020398e:	00003617          	auipc	a2,0x3
ffffffffc0203992:	22a60613          	addi	a2,a2,554 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203996:	0c400593          	li	a1,196
ffffffffc020399a:	00004517          	auipc	a0,0x4
ffffffffc020399e:	0e650513          	addi	a0,a0,230 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02039a2:	873fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02039a6:	00004697          	auipc	a3,0x4
ffffffffc02039aa:	15a68693          	addi	a3,a3,346 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc02039ae:	00003617          	auipc	a2,0x3
ffffffffc02039b2:	20a60613          	addi	a2,a2,522 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02039b6:	0c700593          	li	a1,199
ffffffffc02039ba:	00004517          	auipc	a0,0x4
ffffffffc02039be:	0c650513          	addi	a0,a0,198 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02039c2:	853fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(ret==0);
ffffffffc02039c6:	00004697          	auipc	a3,0x4
ffffffffc02039ca:	30a68693          	addi	a3,a3,778 # ffffffffc0207cd0 <commands+0x1598>
ffffffffc02039ce:	00003617          	auipc	a2,0x3
ffffffffc02039d2:	1ea60613          	addi	a2,a2,490 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02039d6:	10200593          	li	a1,258
ffffffffc02039da:	00004517          	auipc	a0,0x4
ffffffffc02039de:	0a650513          	addi	a0,a0,166 # ffffffffc0207a80 <commands+0x1348>
ffffffffc02039e2:	833fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total == nr_free_pages());
ffffffffc02039e6:	00004697          	auipc	a3,0x4
ffffffffc02039ea:	0d268693          	addi	a3,a3,210 # ffffffffc0207ab8 <commands+0x1380>
ffffffffc02039ee:	00003617          	auipc	a2,0x3
ffffffffc02039f2:	1ca60613          	addi	a2,a2,458 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02039f6:	0bf00593          	li	a1,191
ffffffffc02039fa:	00004517          	auipc	a0,0x4
ffffffffc02039fe:	08650513          	addi	a0,a0,134 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203a02:	813fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203a06 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203a06:	000a9797          	auipc	a5,0xa9
ffffffffc0203a0a:	e3278793          	addi	a5,a5,-462 # ffffffffc02ac838 <sm>
ffffffffc0203a0e:	639c                	ld	a5,0(a5)
ffffffffc0203a10:	0107b303          	ld	t1,16(a5)
ffffffffc0203a14:	8302                	jr	t1

ffffffffc0203a16 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203a16:	000a9797          	auipc	a5,0xa9
ffffffffc0203a1a:	e2278793          	addi	a5,a5,-478 # ffffffffc02ac838 <sm>
ffffffffc0203a1e:	639c                	ld	a5,0(a5)
ffffffffc0203a20:	0207b303          	ld	t1,32(a5)
ffffffffc0203a24:	8302                	jr	t1

ffffffffc0203a26 <swap_out>:
{
ffffffffc0203a26:	711d                	addi	sp,sp,-96
ffffffffc0203a28:	ec86                	sd	ra,88(sp)
ffffffffc0203a2a:	e8a2                	sd	s0,80(sp)
ffffffffc0203a2c:	e4a6                	sd	s1,72(sp)
ffffffffc0203a2e:	e0ca                	sd	s2,64(sp)
ffffffffc0203a30:	fc4e                	sd	s3,56(sp)
ffffffffc0203a32:	f852                	sd	s4,48(sp)
ffffffffc0203a34:	f456                	sd	s5,40(sp)
ffffffffc0203a36:	f05a                	sd	s6,32(sp)
ffffffffc0203a38:	ec5e                	sd	s7,24(sp)
ffffffffc0203a3a:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203a3c:	cde9                	beqz	a1,ffffffffc0203b16 <swap_out+0xf0>
ffffffffc0203a3e:	8ab2                	mv	s5,a2
ffffffffc0203a40:	892a                	mv	s2,a0
ffffffffc0203a42:	8a2e                	mv	s4,a1
ffffffffc0203a44:	4401                	li	s0,0
ffffffffc0203a46:	000a9997          	auipc	s3,0xa9
ffffffffc0203a4a:	df298993          	addi	s3,s3,-526 # ffffffffc02ac838 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203a4e:	00004b17          	auipc	s6,0x4
ffffffffc0203a52:	32ab0b13          	addi	s6,s6,810 # ffffffffc0207d78 <commands+0x1640>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203a56:	00004b97          	auipc	s7,0x4
ffffffffc0203a5a:	30ab8b93          	addi	s7,s7,778 # ffffffffc0207d60 <commands+0x1628>
ffffffffc0203a5e:	a825                	j	ffffffffc0203a96 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203a60:	67a2                	ld	a5,8(sp)
ffffffffc0203a62:	8626                	mv	a2,s1
ffffffffc0203a64:	85a2                	mv	a1,s0
ffffffffc0203a66:	7f94                	ld	a3,56(a5)
ffffffffc0203a68:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203a6a:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203a6c:	82b1                	srli	a3,a3,0xc
ffffffffc0203a6e:	0685                	addi	a3,a3,1
ffffffffc0203a70:	e60fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203a74:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203a76:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203a78:	7d1c                	ld	a5,56(a0)
ffffffffc0203a7a:	83b1                	srli	a5,a5,0xc
ffffffffc0203a7c:	0785                	addi	a5,a5,1
ffffffffc0203a7e:	07a2                	slli	a5,a5,0x8
ffffffffc0203a80:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203a84:	c5efd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203a88:	01893503          	ld	a0,24(s2)
ffffffffc0203a8c:	85a6                	mv	a1,s1
ffffffffc0203a8e:	85ffe0ef          	jal	ra,ffffffffc02022ec <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203a92:	048a0d63          	beq	s4,s0,ffffffffc0203aec <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203a96:	0009b783          	ld	a5,0(s3)
ffffffffc0203a9a:	8656                	mv	a2,s5
ffffffffc0203a9c:	002c                	addi	a1,sp,8
ffffffffc0203a9e:	7b9c                	ld	a5,48(a5)
ffffffffc0203aa0:	854a                	mv	a0,s2
ffffffffc0203aa2:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203aa4:	e12d                	bnez	a0,ffffffffc0203b06 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203aa6:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203aa8:	01893503          	ld	a0,24(s2)
ffffffffc0203aac:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203aae:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ab0:	85a6                	mv	a1,s1
ffffffffc0203ab2:	cb6fd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203ab6:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ab8:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203aba:	8b85                	andi	a5,a5,1
ffffffffc0203abc:	cfb9                	beqz	a5,ffffffffc0203b1a <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203abe:	65a2                	ld	a1,8(sp)
ffffffffc0203ac0:	7d9c                	ld	a5,56(a1)
ffffffffc0203ac2:	83b1                	srli	a5,a5,0xc
ffffffffc0203ac4:	00178513          	addi	a0,a5,1
ffffffffc0203ac8:	0522                	slli	a0,a0,0x8
ffffffffc0203aca:	0f0010ef          	jal	ra,ffffffffc0204bba <swapfs_write>
ffffffffc0203ace:	d949                	beqz	a0,ffffffffc0203a60 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ad0:	855e                	mv	a0,s7
ffffffffc0203ad2:	dfefc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203ad6:	0009b783          	ld	a5,0(s3)
ffffffffc0203ada:	6622                	ld	a2,8(sp)
ffffffffc0203adc:	4681                	li	a3,0
ffffffffc0203ade:	739c                	ld	a5,32(a5)
ffffffffc0203ae0:	85a6                	mv	a1,s1
ffffffffc0203ae2:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203ae4:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203ae6:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203ae8:	fa8a17e3          	bne	s4,s0,ffffffffc0203a96 <swap_out+0x70>
}
ffffffffc0203aec:	8522                	mv	a0,s0
ffffffffc0203aee:	60e6                	ld	ra,88(sp)
ffffffffc0203af0:	6446                	ld	s0,80(sp)
ffffffffc0203af2:	64a6                	ld	s1,72(sp)
ffffffffc0203af4:	6906                	ld	s2,64(sp)
ffffffffc0203af6:	79e2                	ld	s3,56(sp)
ffffffffc0203af8:	7a42                	ld	s4,48(sp)
ffffffffc0203afa:	7aa2                	ld	s5,40(sp)
ffffffffc0203afc:	7b02                	ld	s6,32(sp)
ffffffffc0203afe:	6be2                	ld	s7,24(sp)
ffffffffc0203b00:	6c42                	ld	s8,16(sp)
ffffffffc0203b02:	6125                	addi	sp,sp,96
ffffffffc0203b04:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203b06:	85a2                	mv	a1,s0
ffffffffc0203b08:	00004517          	auipc	a0,0x4
ffffffffc0203b0c:	21050513          	addi	a0,a0,528 # ffffffffc0207d18 <commands+0x15e0>
ffffffffc0203b10:	dc0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0203b14:	bfe1                	j	ffffffffc0203aec <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203b16:	4401                	li	s0,0
ffffffffc0203b18:	bfd1                	j	ffffffffc0203aec <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b1a:	00004697          	auipc	a3,0x4
ffffffffc0203b1e:	22e68693          	addi	a3,a3,558 # ffffffffc0207d48 <commands+0x1610>
ffffffffc0203b22:	00003617          	auipc	a2,0x3
ffffffffc0203b26:	09660613          	addi	a2,a2,150 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203b2a:	06800593          	li	a1,104
ffffffffc0203b2e:	00004517          	auipc	a0,0x4
ffffffffc0203b32:	f5250513          	addi	a0,a0,-174 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203b36:	edefc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203b3a <swap_in>:
{
ffffffffc0203b3a:	7179                	addi	sp,sp,-48
ffffffffc0203b3c:	e84a                	sd	s2,16(sp)
ffffffffc0203b3e:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203b40:	4505                	li	a0,1
{
ffffffffc0203b42:	ec26                	sd	s1,24(sp)
ffffffffc0203b44:	e44e                	sd	s3,8(sp)
ffffffffc0203b46:	f406                	sd	ra,40(sp)
ffffffffc0203b48:	f022                	sd	s0,32(sp)
ffffffffc0203b4a:	84ae                	mv	s1,a1
ffffffffc0203b4c:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203b4e:	b0cfd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
     assert(result!=NULL);
ffffffffc0203b52:	c129                	beqz	a0,ffffffffc0203b94 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203b54:	842a                	mv	s0,a0
ffffffffc0203b56:	01893503          	ld	a0,24(s2)
ffffffffc0203b5a:	4601                	li	a2,0
ffffffffc0203b5c:	85a6                	mv	a1,s1
ffffffffc0203b5e:	c0afd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0203b62:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203b64:	6108                	ld	a0,0(a0)
ffffffffc0203b66:	85a2                	mv	a1,s0
ffffffffc0203b68:	7bb000ef          	jal	ra,ffffffffc0204b22 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203b6c:	00093583          	ld	a1,0(s2)
ffffffffc0203b70:	8626                	mv	a2,s1
ffffffffc0203b72:	00004517          	auipc	a0,0x4
ffffffffc0203b76:	eae50513          	addi	a0,a0,-338 # ffffffffc0207a20 <commands+0x12e8>
ffffffffc0203b7a:	81a1                	srli	a1,a1,0x8
ffffffffc0203b7c:	d54fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203b80:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203b82:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203b86:	7402                	ld	s0,32(sp)
ffffffffc0203b88:	64e2                	ld	s1,24(sp)
ffffffffc0203b8a:	6942                	ld	s2,16(sp)
ffffffffc0203b8c:	69a2                	ld	s3,8(sp)
ffffffffc0203b8e:	4501                	li	a0,0
ffffffffc0203b90:	6145                	addi	sp,sp,48
ffffffffc0203b92:	8082                	ret
     assert(result!=NULL);
ffffffffc0203b94:	00004697          	auipc	a3,0x4
ffffffffc0203b98:	e7c68693          	addi	a3,a3,-388 # ffffffffc0207a10 <commands+0x12d8>
ffffffffc0203b9c:	00003617          	auipc	a2,0x3
ffffffffc0203ba0:	01c60613          	addi	a2,a2,28 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203ba4:	07e00593          	li	a1,126
ffffffffc0203ba8:	00004517          	auipc	a0,0x4
ffffffffc0203bac:	ed850513          	addi	a0,a0,-296 # ffffffffc0207a80 <commands+0x1348>
ffffffffc0203bb0:	e64fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203bb4 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203bb4:	000a9797          	auipc	a5,0xa9
ffffffffc0203bb8:	dac78793          	addi	a5,a5,-596 # ffffffffc02ac960 <free_area>
ffffffffc0203bbc:	e79c                	sd	a5,8(a5)
ffffffffc0203bbe:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203bc0:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203bc4:	8082                	ret

ffffffffc0203bc6 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203bc6:	000a9517          	auipc	a0,0xa9
ffffffffc0203bca:	daa56503          	lwu	a0,-598(a0) # ffffffffc02ac970 <free_area+0x10>
ffffffffc0203bce:	8082                	ret

ffffffffc0203bd0 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203bd0:	715d                	addi	sp,sp,-80
ffffffffc0203bd2:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203bd4:	000a9917          	auipc	s2,0xa9
ffffffffc0203bd8:	d8c90913          	addi	s2,s2,-628 # ffffffffc02ac960 <free_area>
ffffffffc0203bdc:	00893783          	ld	a5,8(s2)
ffffffffc0203be0:	e486                	sd	ra,72(sp)
ffffffffc0203be2:	e0a2                	sd	s0,64(sp)
ffffffffc0203be4:	fc26                	sd	s1,56(sp)
ffffffffc0203be6:	f44e                	sd	s3,40(sp)
ffffffffc0203be8:	f052                	sd	s4,32(sp)
ffffffffc0203bea:	ec56                	sd	s5,24(sp)
ffffffffc0203bec:	e85a                	sd	s6,16(sp)
ffffffffc0203bee:	e45e                	sd	s7,8(sp)
ffffffffc0203bf0:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203bf2:	31278463          	beq	a5,s2,ffffffffc0203efa <default_check+0x32a>
ffffffffc0203bf6:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203bfa:	8305                	srli	a4,a4,0x1
ffffffffc0203bfc:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203bfe:	30070263          	beqz	a4,ffffffffc0203f02 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0203c02:	4401                	li	s0,0
ffffffffc0203c04:	4481                	li	s1,0
ffffffffc0203c06:	a031                	j	ffffffffc0203c12 <default_check+0x42>
ffffffffc0203c08:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203c0c:	8b09                	andi	a4,a4,2
ffffffffc0203c0e:	2e070a63          	beqz	a4,ffffffffc0203f02 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0203c12:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203c16:	679c                	ld	a5,8(a5)
ffffffffc0203c18:	2485                	addiw	s1,s1,1
ffffffffc0203c1a:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203c1c:	ff2796e3          	bne	a5,s2,ffffffffc0203c08 <default_check+0x38>
ffffffffc0203c20:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203c22:	b06fd0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0203c26:	73351e63          	bne	a0,s3,ffffffffc0204362 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203c2a:	4505                	li	a0,1
ffffffffc0203c2c:	a2efd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203c30:	8a2a                	mv	s4,a0
ffffffffc0203c32:	46050863          	beqz	a0,ffffffffc02040a2 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203c36:	4505                	li	a0,1
ffffffffc0203c38:	a22fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203c3c:	89aa                	mv	s3,a0
ffffffffc0203c3e:	74050263          	beqz	a0,ffffffffc0204382 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203c42:	4505                	li	a0,1
ffffffffc0203c44:	a16fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203c48:	8aaa                	mv	s5,a0
ffffffffc0203c4a:	4c050c63          	beqz	a0,ffffffffc0204122 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203c4e:	2d3a0a63          	beq	s4,s3,ffffffffc0203f22 <default_check+0x352>
ffffffffc0203c52:	2caa0863          	beq	s4,a0,ffffffffc0203f22 <default_check+0x352>
ffffffffc0203c56:	2ca98663          	beq	s3,a0,ffffffffc0203f22 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203c5a:	000a2783          	lw	a5,0(s4)
ffffffffc0203c5e:	2e079263          	bnez	a5,ffffffffc0203f42 <default_check+0x372>
ffffffffc0203c62:	0009a783          	lw	a5,0(s3)
ffffffffc0203c66:	2c079e63          	bnez	a5,ffffffffc0203f42 <default_check+0x372>
ffffffffc0203c6a:	411c                	lw	a5,0(a0)
ffffffffc0203c6c:	2c079b63          	bnez	a5,ffffffffc0203f42 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0203c70:	000a9797          	auipc	a5,0xa9
ffffffffc0203c74:	c1878793          	addi	a5,a5,-1000 # ffffffffc02ac888 <pages>
ffffffffc0203c78:	639c                	ld	a5,0(a5)
ffffffffc0203c7a:	00005717          	auipc	a4,0x5
ffffffffc0203c7e:	02670713          	addi	a4,a4,38 # ffffffffc0208ca0 <nbase>
ffffffffc0203c82:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203c84:	000a9717          	auipc	a4,0xa9
ffffffffc0203c88:	b9c70713          	addi	a4,a4,-1124 # ffffffffc02ac820 <npage>
ffffffffc0203c8c:	6314                	ld	a3,0(a4)
ffffffffc0203c8e:	40fa0733          	sub	a4,s4,a5
ffffffffc0203c92:	8719                	srai	a4,a4,0x6
ffffffffc0203c94:	9732                	add	a4,a4,a2
ffffffffc0203c96:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c98:	0732                	slli	a4,a4,0xc
ffffffffc0203c9a:	2cd77463          	bgeu	a4,a3,ffffffffc0203f62 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0203c9e:	40f98733          	sub	a4,s3,a5
ffffffffc0203ca2:	8719                	srai	a4,a4,0x6
ffffffffc0203ca4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ca6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203ca8:	4ed77d63          	bgeu	a4,a3,ffffffffc02041a2 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0203cac:	40f507b3          	sub	a5,a0,a5
ffffffffc0203cb0:	8799                	srai	a5,a5,0x6
ffffffffc0203cb2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cb4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203cb6:	34d7f663          	bgeu	a5,a3,ffffffffc0204002 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0203cba:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203cbc:	00093c03          	ld	s8,0(s2)
ffffffffc0203cc0:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0203cc4:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0203cc8:	000a9797          	auipc	a5,0xa9
ffffffffc0203ccc:	cb27b023          	sd	s2,-864(a5) # ffffffffc02ac968 <free_area+0x8>
ffffffffc0203cd0:	000a9797          	auipc	a5,0xa9
ffffffffc0203cd4:	c927b823          	sd	s2,-880(a5) # ffffffffc02ac960 <free_area>
    nr_free = 0;
ffffffffc0203cd8:	000a9797          	auipc	a5,0xa9
ffffffffc0203cdc:	c807ac23          	sw	zero,-872(a5) # ffffffffc02ac970 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203ce0:	97afd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203ce4:	2e051f63          	bnez	a0,ffffffffc0203fe2 <default_check+0x412>
    free_page(p0);
ffffffffc0203ce8:	4585                	li	a1,1
ffffffffc0203cea:	8552                	mv	a0,s4
ffffffffc0203cec:	9f6fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p1);
ffffffffc0203cf0:	4585                	li	a1,1
ffffffffc0203cf2:	854e                	mv	a0,s3
ffffffffc0203cf4:	9eefd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0203cf8:	4585                	li	a1,1
ffffffffc0203cfa:	8556                	mv	a0,s5
ffffffffc0203cfc:	9e6fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(nr_free == 3);
ffffffffc0203d00:	01092703          	lw	a4,16(s2)
ffffffffc0203d04:	478d                	li	a5,3
ffffffffc0203d06:	2af71e63          	bne	a4,a5,ffffffffc0203fc2 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203d0a:	4505                	li	a0,1
ffffffffc0203d0c:	94efd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d10:	89aa                	mv	s3,a0
ffffffffc0203d12:	28050863          	beqz	a0,ffffffffc0203fa2 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203d16:	4505                	li	a0,1
ffffffffc0203d18:	942fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d1c:	8aaa                	mv	s5,a0
ffffffffc0203d1e:	3e050263          	beqz	a0,ffffffffc0204102 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203d22:	4505                	li	a0,1
ffffffffc0203d24:	936fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d28:	8a2a                	mv	s4,a0
ffffffffc0203d2a:	3a050c63          	beqz	a0,ffffffffc02040e2 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0203d2e:	4505                	li	a0,1
ffffffffc0203d30:	92afd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d34:	38051763          	bnez	a0,ffffffffc02040c2 <default_check+0x4f2>
    free_page(p0);
ffffffffc0203d38:	4585                	li	a1,1
ffffffffc0203d3a:	854e                	mv	a0,s3
ffffffffc0203d3c:	9a6fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203d40:	00893783          	ld	a5,8(s2)
ffffffffc0203d44:	23278f63          	beq	a5,s2,ffffffffc0203f82 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0203d48:	4505                	li	a0,1
ffffffffc0203d4a:	910fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d4e:	32a99a63          	bne	s3,a0,ffffffffc0204082 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0203d52:	4505                	li	a0,1
ffffffffc0203d54:	906fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d58:	30051563          	bnez	a0,ffffffffc0204062 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0203d5c:	01092783          	lw	a5,16(s2)
ffffffffc0203d60:	2e079163          	bnez	a5,ffffffffc0204042 <default_check+0x472>
    free_page(p);
ffffffffc0203d64:	854e                	mv	a0,s3
ffffffffc0203d66:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0203d68:	000a9797          	auipc	a5,0xa9
ffffffffc0203d6c:	bf87bc23          	sd	s8,-1032(a5) # ffffffffc02ac960 <free_area>
ffffffffc0203d70:	000a9797          	auipc	a5,0xa9
ffffffffc0203d74:	bf77bc23          	sd	s7,-1032(a5) # ffffffffc02ac968 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0203d78:	000a9797          	auipc	a5,0xa9
ffffffffc0203d7c:	bf67ac23          	sw	s6,-1032(a5) # ffffffffc02ac970 <free_area+0x10>
    free_page(p);
ffffffffc0203d80:	962fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p1);
ffffffffc0203d84:	4585                	li	a1,1
ffffffffc0203d86:	8556                	mv	a0,s5
ffffffffc0203d88:	95afd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0203d8c:	4585                	li	a1,1
ffffffffc0203d8e:	8552                	mv	a0,s4
ffffffffc0203d90:	952fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0203d94:	4515                	li	a0,5
ffffffffc0203d96:	8c4fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203d9a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0203d9c:	28050363          	beqz	a0,ffffffffc0204022 <default_check+0x452>
ffffffffc0203da0:	651c                	ld	a5,8(a0)
ffffffffc0203da2:	8385                	srli	a5,a5,0x1
ffffffffc0203da4:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0203da6:	54079e63          	bnez	a5,ffffffffc0204302 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0203daa:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203dac:	00093b03          	ld	s6,0(s2)
ffffffffc0203db0:	00893a83          	ld	s5,8(s2)
ffffffffc0203db4:	000a9797          	auipc	a5,0xa9
ffffffffc0203db8:	bb27b623          	sd	s2,-1108(a5) # ffffffffc02ac960 <free_area>
ffffffffc0203dbc:	000a9797          	auipc	a5,0xa9
ffffffffc0203dc0:	bb27b623          	sd	s2,-1108(a5) # ffffffffc02ac968 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0203dc4:	896fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203dc8:	50051d63          	bnez	a0,ffffffffc02042e2 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0203dcc:	08098a13          	addi	s4,s3,128
ffffffffc0203dd0:	8552                	mv	a0,s4
ffffffffc0203dd2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0203dd4:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0203dd8:	000a9797          	auipc	a5,0xa9
ffffffffc0203ddc:	b807ac23          	sw	zero,-1128(a5) # ffffffffc02ac970 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203de0:	902fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203de4:	4511                	li	a0,4
ffffffffc0203de6:	874fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203dea:	4c051c63          	bnez	a0,ffffffffc02042c2 <default_check+0x6f2>
ffffffffc0203dee:	0889b783          	ld	a5,136(s3)
ffffffffc0203df2:	8385                	srli	a5,a5,0x1
ffffffffc0203df4:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203df6:	4a078663          	beqz	a5,ffffffffc02042a2 <default_check+0x6d2>
ffffffffc0203dfa:	0909a703          	lw	a4,144(s3)
ffffffffc0203dfe:	478d                	li	a5,3
ffffffffc0203e00:	4af71163          	bne	a4,a5,ffffffffc02042a2 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203e04:	450d                	li	a0,3
ffffffffc0203e06:	854fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e0a:	8c2a                	mv	s8,a0
ffffffffc0203e0c:	46050b63          	beqz	a0,ffffffffc0204282 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0203e10:	4505                	li	a0,1
ffffffffc0203e12:	848fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e16:	44051663          	bnez	a0,ffffffffc0204262 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0203e1a:	438a1463          	bne	s4,s8,ffffffffc0204242 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203e1e:	4585                	li	a1,1
ffffffffc0203e20:	854e                	mv	a0,s3
ffffffffc0203e22:	8c0fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_pages(p1, 3);
ffffffffc0203e26:	458d                	li	a1,3
ffffffffc0203e28:	8552                	mv	a0,s4
ffffffffc0203e2a:	8b8fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc0203e2e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203e32:	04098c13          	addi	s8,s3,64
ffffffffc0203e36:	8385                	srli	a5,a5,0x1
ffffffffc0203e38:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203e3a:	3e078463          	beqz	a5,ffffffffc0204222 <default_check+0x652>
ffffffffc0203e3e:	0109a703          	lw	a4,16(s3)
ffffffffc0203e42:	4785                	li	a5,1
ffffffffc0203e44:	3cf71f63          	bne	a4,a5,ffffffffc0204222 <default_check+0x652>
ffffffffc0203e48:	008a3783          	ld	a5,8(s4)
ffffffffc0203e4c:	8385                	srli	a5,a5,0x1
ffffffffc0203e4e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203e50:	3a078963          	beqz	a5,ffffffffc0204202 <default_check+0x632>
ffffffffc0203e54:	010a2703          	lw	a4,16(s4)
ffffffffc0203e58:	478d                	li	a5,3
ffffffffc0203e5a:	3af71463          	bne	a4,a5,ffffffffc0204202 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203e5e:	4505                	li	a0,1
ffffffffc0203e60:	ffbfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e64:	36a99f63          	bne	s3,a0,ffffffffc02041e2 <default_check+0x612>
    free_page(p0);
ffffffffc0203e68:	4585                	li	a1,1
ffffffffc0203e6a:	878fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203e6e:	4509                	li	a0,2
ffffffffc0203e70:	febfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e74:	34aa1763          	bne	s4,a0,ffffffffc02041c2 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0203e78:	4589                	li	a1,2
ffffffffc0203e7a:	868fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0203e7e:	4585                	li	a1,1
ffffffffc0203e80:	8562                	mv	a0,s8
ffffffffc0203e82:	860fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203e86:	4515                	li	a0,5
ffffffffc0203e88:	fd3fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e8c:	89aa                	mv	s3,a0
ffffffffc0203e8e:	48050a63          	beqz	a0,ffffffffc0204322 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0203e92:	4505                	li	a0,1
ffffffffc0203e94:	fc7fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203e98:	2e051563          	bnez	a0,ffffffffc0204182 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0203e9c:	01092783          	lw	a5,16(s2)
ffffffffc0203ea0:	2c079163          	bnez	a5,ffffffffc0204162 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203ea4:	4595                	li	a1,5
ffffffffc0203ea6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0203ea8:	000a9797          	auipc	a5,0xa9
ffffffffc0203eac:	ad77a423          	sw	s7,-1336(a5) # ffffffffc02ac970 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0203eb0:	000a9797          	auipc	a5,0xa9
ffffffffc0203eb4:	ab67b823          	sd	s6,-1360(a5) # ffffffffc02ac960 <free_area>
ffffffffc0203eb8:	000a9797          	auipc	a5,0xa9
ffffffffc0203ebc:	ab57b823          	sd	s5,-1360(a5) # ffffffffc02ac968 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0203ec0:	822fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return listelm->next;
ffffffffc0203ec4:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203ec8:	01278963          	beq	a5,s2,ffffffffc0203eda <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0203ecc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203ed0:	679c                	ld	a5,8(a5)
ffffffffc0203ed2:	34fd                	addiw	s1,s1,-1
ffffffffc0203ed4:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203ed6:	ff279be3          	bne	a5,s2,ffffffffc0203ecc <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0203eda:	26049463          	bnez	s1,ffffffffc0204142 <default_check+0x572>
    assert(total == 0);
ffffffffc0203ede:	46041263          	bnez	s0,ffffffffc0204342 <default_check+0x772>
}
ffffffffc0203ee2:	60a6                	ld	ra,72(sp)
ffffffffc0203ee4:	6406                	ld	s0,64(sp)
ffffffffc0203ee6:	74e2                	ld	s1,56(sp)
ffffffffc0203ee8:	7942                	ld	s2,48(sp)
ffffffffc0203eea:	79a2                	ld	s3,40(sp)
ffffffffc0203eec:	7a02                	ld	s4,32(sp)
ffffffffc0203eee:	6ae2                	ld	s5,24(sp)
ffffffffc0203ef0:	6b42                	ld	s6,16(sp)
ffffffffc0203ef2:	6ba2                	ld	s7,8(sp)
ffffffffc0203ef4:	6c02                	ld	s8,0(sp)
ffffffffc0203ef6:	6161                	addi	sp,sp,80
ffffffffc0203ef8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203efa:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203efc:	4401                	li	s0,0
ffffffffc0203efe:	4481                	li	s1,0
ffffffffc0203f00:	b30d                	j	ffffffffc0203c22 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203f02:	00004697          	auipc	a3,0x4
ffffffffc0203f06:	ba668693          	addi	a3,a3,-1114 # ffffffffc0207aa8 <commands+0x1370>
ffffffffc0203f0a:	00003617          	auipc	a2,0x3
ffffffffc0203f0e:	cae60613          	addi	a2,a2,-850 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203f12:	0f000593          	li	a1,240
ffffffffc0203f16:	00004517          	auipc	a0,0x4
ffffffffc0203f1a:	ea250513          	addi	a0,a0,-350 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203f1e:	af6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203f22:	00004697          	auipc	a3,0x4
ffffffffc0203f26:	f0e68693          	addi	a3,a3,-242 # ffffffffc0207e30 <commands+0x16f8>
ffffffffc0203f2a:	00003617          	auipc	a2,0x3
ffffffffc0203f2e:	c8e60613          	addi	a2,a2,-882 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203f32:	0bd00593          	li	a1,189
ffffffffc0203f36:	00004517          	auipc	a0,0x4
ffffffffc0203f3a:	e8250513          	addi	a0,a0,-382 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203f3e:	ad6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203f42:	00004697          	auipc	a3,0x4
ffffffffc0203f46:	f1668693          	addi	a3,a3,-234 # ffffffffc0207e58 <commands+0x1720>
ffffffffc0203f4a:	00003617          	auipc	a2,0x3
ffffffffc0203f4e:	c6e60613          	addi	a2,a2,-914 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203f52:	0be00593          	li	a1,190
ffffffffc0203f56:	00004517          	auipc	a0,0x4
ffffffffc0203f5a:	e6250513          	addi	a0,a0,-414 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203f5e:	ab6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203f62:	00004697          	auipc	a3,0x4
ffffffffc0203f66:	f3668693          	addi	a3,a3,-202 # ffffffffc0207e98 <commands+0x1760>
ffffffffc0203f6a:	00003617          	auipc	a2,0x3
ffffffffc0203f6e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203f72:	0c000593          	li	a1,192
ffffffffc0203f76:	00004517          	auipc	a0,0x4
ffffffffc0203f7a:	e4250513          	addi	a0,a0,-446 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203f7e:	a96fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0203f82:	00004697          	auipc	a3,0x4
ffffffffc0203f86:	f9e68693          	addi	a3,a3,-98 # ffffffffc0207f20 <commands+0x17e8>
ffffffffc0203f8a:	00003617          	auipc	a2,0x3
ffffffffc0203f8e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203f92:	0d900593          	li	a1,217
ffffffffc0203f96:	00004517          	auipc	a0,0x4
ffffffffc0203f9a:	e2250513          	addi	a0,a0,-478 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203f9e:	a76fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203fa2:	00004697          	auipc	a3,0x4
ffffffffc0203fa6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0207dd0 <commands+0x1698>
ffffffffc0203faa:	00003617          	auipc	a2,0x3
ffffffffc0203fae:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203fb2:	0d200593          	li	a1,210
ffffffffc0203fb6:	00004517          	auipc	a0,0x4
ffffffffc0203fba:	e0250513          	addi	a0,a0,-510 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203fbe:	a56fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 3);
ffffffffc0203fc2:	00004697          	auipc	a3,0x4
ffffffffc0203fc6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0207f10 <commands+0x17d8>
ffffffffc0203fca:	00003617          	auipc	a2,0x3
ffffffffc0203fce:	bee60613          	addi	a2,a2,-1042 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203fd2:	0d000593          	li	a1,208
ffffffffc0203fd6:	00004517          	auipc	a0,0x4
ffffffffc0203fda:	de250513          	addi	a0,a0,-542 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203fde:	a36fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203fe2:	00004697          	auipc	a3,0x4
ffffffffc0203fe6:	f1668693          	addi	a3,a3,-234 # ffffffffc0207ef8 <commands+0x17c0>
ffffffffc0203fea:	00003617          	auipc	a2,0x3
ffffffffc0203fee:	bce60613          	addi	a2,a2,-1074 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203ff2:	0cb00593          	li	a1,203
ffffffffc0203ff6:	00004517          	auipc	a0,0x4
ffffffffc0203ffa:	dc250513          	addi	a0,a0,-574 # ffffffffc0207db8 <commands+0x1680>
ffffffffc0203ffe:	a16fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0204002:	00004697          	auipc	a3,0x4
ffffffffc0204006:	ed668693          	addi	a3,a3,-298 # ffffffffc0207ed8 <commands+0x17a0>
ffffffffc020400a:	00003617          	auipc	a2,0x3
ffffffffc020400e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204012:	0c200593          	li	a1,194
ffffffffc0204016:	00004517          	auipc	a0,0x4
ffffffffc020401a:	da250513          	addi	a0,a0,-606 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020401e:	9f6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != NULL);
ffffffffc0204022:	00004697          	auipc	a3,0x4
ffffffffc0204026:	f3668693          	addi	a3,a3,-202 # ffffffffc0207f58 <commands+0x1820>
ffffffffc020402a:	00003617          	auipc	a2,0x3
ffffffffc020402e:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204032:	0f800593          	li	a1,248
ffffffffc0204036:	00004517          	auipc	a0,0x4
ffffffffc020403a:	d8250513          	addi	a0,a0,-638 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020403e:	9d6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc0204042:	00004697          	auipc	a3,0x4
ffffffffc0204046:	c1668693          	addi	a3,a3,-1002 # ffffffffc0207c58 <commands+0x1520>
ffffffffc020404a:	00003617          	auipc	a2,0x3
ffffffffc020404e:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204052:	0df00593          	li	a1,223
ffffffffc0204056:	00004517          	auipc	a0,0x4
ffffffffc020405a:	d6250513          	addi	a0,a0,-670 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020405e:	9b6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204062:	00004697          	auipc	a3,0x4
ffffffffc0204066:	e9668693          	addi	a3,a3,-362 # ffffffffc0207ef8 <commands+0x17c0>
ffffffffc020406a:	00003617          	auipc	a2,0x3
ffffffffc020406e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204072:	0dd00593          	li	a1,221
ffffffffc0204076:	00004517          	auipc	a0,0x4
ffffffffc020407a:	d4250513          	addi	a0,a0,-702 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020407e:	996fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0204082:	00004697          	auipc	a3,0x4
ffffffffc0204086:	eb668693          	addi	a3,a3,-330 # ffffffffc0207f38 <commands+0x1800>
ffffffffc020408a:	00003617          	auipc	a2,0x3
ffffffffc020408e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204092:	0dc00593          	li	a1,220
ffffffffc0204096:	00004517          	auipc	a0,0x4
ffffffffc020409a:	d2250513          	addi	a0,a0,-734 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020409e:	976fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02040a2:	00004697          	auipc	a3,0x4
ffffffffc02040a6:	d2e68693          	addi	a3,a3,-722 # ffffffffc0207dd0 <commands+0x1698>
ffffffffc02040aa:	00003617          	auipc	a2,0x3
ffffffffc02040ae:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02040b2:	0b900593          	li	a1,185
ffffffffc02040b6:	00004517          	auipc	a0,0x4
ffffffffc02040ba:	d0250513          	addi	a0,a0,-766 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02040be:	956fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02040c2:	00004697          	auipc	a3,0x4
ffffffffc02040c6:	e3668693          	addi	a3,a3,-458 # ffffffffc0207ef8 <commands+0x17c0>
ffffffffc02040ca:	00003617          	auipc	a2,0x3
ffffffffc02040ce:	aee60613          	addi	a2,a2,-1298 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02040d2:	0d600593          	li	a1,214
ffffffffc02040d6:	00004517          	auipc	a0,0x4
ffffffffc02040da:	ce250513          	addi	a0,a0,-798 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02040de:	936fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02040e2:	00004697          	auipc	a3,0x4
ffffffffc02040e6:	d2e68693          	addi	a3,a3,-722 # ffffffffc0207e10 <commands+0x16d8>
ffffffffc02040ea:	00003617          	auipc	a2,0x3
ffffffffc02040ee:	ace60613          	addi	a2,a2,-1330 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02040f2:	0d400593          	li	a1,212
ffffffffc02040f6:	00004517          	auipc	a0,0x4
ffffffffc02040fa:	cc250513          	addi	a0,a0,-830 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02040fe:	916fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204102:	00004697          	auipc	a3,0x4
ffffffffc0204106:	cee68693          	addi	a3,a3,-786 # ffffffffc0207df0 <commands+0x16b8>
ffffffffc020410a:	00003617          	auipc	a2,0x3
ffffffffc020410e:	aae60613          	addi	a2,a2,-1362 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204112:	0d300593          	li	a1,211
ffffffffc0204116:	00004517          	auipc	a0,0x4
ffffffffc020411a:	ca250513          	addi	a0,a0,-862 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020411e:	8f6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204122:	00004697          	auipc	a3,0x4
ffffffffc0204126:	cee68693          	addi	a3,a3,-786 # ffffffffc0207e10 <commands+0x16d8>
ffffffffc020412a:	00003617          	auipc	a2,0x3
ffffffffc020412e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204132:	0bb00593          	li	a1,187
ffffffffc0204136:	00004517          	auipc	a0,0x4
ffffffffc020413a:	c8250513          	addi	a0,a0,-894 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020413e:	8d6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(count == 0);
ffffffffc0204142:	00004697          	auipc	a3,0x4
ffffffffc0204146:	f6668693          	addi	a3,a3,-154 # ffffffffc02080a8 <commands+0x1970>
ffffffffc020414a:	00003617          	auipc	a2,0x3
ffffffffc020414e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204152:	12500593          	li	a1,293
ffffffffc0204156:	00004517          	auipc	a0,0x4
ffffffffc020415a:	c6250513          	addi	a0,a0,-926 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020415e:	8b6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc0204162:	00004697          	auipc	a3,0x4
ffffffffc0204166:	af668693          	addi	a3,a3,-1290 # ffffffffc0207c58 <commands+0x1520>
ffffffffc020416a:	00003617          	auipc	a2,0x3
ffffffffc020416e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204172:	11a00593          	li	a1,282
ffffffffc0204176:	00004517          	auipc	a0,0x4
ffffffffc020417a:	c4250513          	addi	a0,a0,-958 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020417e:	896fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204182:	00004697          	auipc	a3,0x4
ffffffffc0204186:	d7668693          	addi	a3,a3,-650 # ffffffffc0207ef8 <commands+0x17c0>
ffffffffc020418a:	00003617          	auipc	a2,0x3
ffffffffc020418e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204192:	11800593          	li	a1,280
ffffffffc0204196:	00004517          	auipc	a0,0x4
ffffffffc020419a:	c2250513          	addi	a0,a0,-990 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020419e:	876fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02041a2:	00004697          	auipc	a3,0x4
ffffffffc02041a6:	d1668693          	addi	a3,a3,-746 # ffffffffc0207eb8 <commands+0x1780>
ffffffffc02041aa:	00003617          	auipc	a2,0x3
ffffffffc02041ae:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02041b2:	0c100593          	li	a1,193
ffffffffc02041b6:	00004517          	auipc	a0,0x4
ffffffffc02041ba:	c0250513          	addi	a0,a0,-1022 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02041be:	856fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02041c2:	00004697          	auipc	a3,0x4
ffffffffc02041c6:	ea668693          	addi	a3,a3,-346 # ffffffffc0208068 <commands+0x1930>
ffffffffc02041ca:	00003617          	auipc	a2,0x3
ffffffffc02041ce:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02041d2:	11200593          	li	a1,274
ffffffffc02041d6:	00004517          	auipc	a0,0x4
ffffffffc02041da:	be250513          	addi	a0,a0,-1054 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02041de:	836fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02041e2:	00004697          	auipc	a3,0x4
ffffffffc02041e6:	e6668693          	addi	a3,a3,-410 # ffffffffc0208048 <commands+0x1910>
ffffffffc02041ea:	00003617          	auipc	a2,0x3
ffffffffc02041ee:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02041f2:	11000593          	li	a1,272
ffffffffc02041f6:	00004517          	auipc	a0,0x4
ffffffffc02041fa:	bc250513          	addi	a0,a0,-1086 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02041fe:	816fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204202:	00004697          	auipc	a3,0x4
ffffffffc0204206:	e1e68693          	addi	a3,a3,-482 # ffffffffc0208020 <commands+0x18e8>
ffffffffc020420a:	00003617          	auipc	a2,0x3
ffffffffc020420e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204212:	10e00593          	li	a1,270
ffffffffc0204216:	00004517          	auipc	a0,0x4
ffffffffc020421a:	ba250513          	addi	a0,a0,-1118 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020421e:	ff7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204222:	00004697          	auipc	a3,0x4
ffffffffc0204226:	dd668693          	addi	a3,a3,-554 # ffffffffc0207ff8 <commands+0x18c0>
ffffffffc020422a:	00003617          	auipc	a2,0x3
ffffffffc020422e:	98e60613          	addi	a2,a2,-1650 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204232:	10d00593          	li	a1,269
ffffffffc0204236:	00004517          	auipc	a0,0x4
ffffffffc020423a:	b8250513          	addi	a0,a0,-1150 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020423e:	fd7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204242:	00004697          	auipc	a3,0x4
ffffffffc0204246:	da668693          	addi	a3,a3,-602 # ffffffffc0207fe8 <commands+0x18b0>
ffffffffc020424a:	00003617          	auipc	a2,0x3
ffffffffc020424e:	96e60613          	addi	a2,a2,-1682 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204252:	10800593          	li	a1,264
ffffffffc0204256:	00004517          	auipc	a0,0x4
ffffffffc020425a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020425e:	fb7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204262:	00004697          	auipc	a3,0x4
ffffffffc0204266:	c9668693          	addi	a3,a3,-874 # ffffffffc0207ef8 <commands+0x17c0>
ffffffffc020426a:	00003617          	auipc	a2,0x3
ffffffffc020426e:	94e60613          	addi	a2,a2,-1714 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204272:	10700593          	li	a1,263
ffffffffc0204276:	00004517          	auipc	a0,0x4
ffffffffc020427a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020427e:	f97fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204282:	00004697          	auipc	a3,0x4
ffffffffc0204286:	d4668693          	addi	a3,a3,-698 # ffffffffc0207fc8 <commands+0x1890>
ffffffffc020428a:	00003617          	auipc	a2,0x3
ffffffffc020428e:	92e60613          	addi	a2,a2,-1746 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204292:	10600593          	li	a1,262
ffffffffc0204296:	00004517          	auipc	a0,0x4
ffffffffc020429a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020429e:	f77fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02042a2:	00004697          	auipc	a3,0x4
ffffffffc02042a6:	cf668693          	addi	a3,a3,-778 # ffffffffc0207f98 <commands+0x1860>
ffffffffc02042aa:	00003617          	auipc	a2,0x3
ffffffffc02042ae:	90e60613          	addi	a2,a2,-1778 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02042b2:	10500593          	li	a1,261
ffffffffc02042b6:	00004517          	auipc	a0,0x4
ffffffffc02042ba:	b0250513          	addi	a0,a0,-1278 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02042be:	f57fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02042c2:	00004697          	auipc	a3,0x4
ffffffffc02042c6:	cbe68693          	addi	a3,a3,-834 # ffffffffc0207f80 <commands+0x1848>
ffffffffc02042ca:	00003617          	auipc	a2,0x3
ffffffffc02042ce:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02042d2:	10400593          	li	a1,260
ffffffffc02042d6:	00004517          	auipc	a0,0x4
ffffffffc02042da:	ae250513          	addi	a0,a0,-1310 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02042de:	f37fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02042e2:	00004697          	auipc	a3,0x4
ffffffffc02042e6:	c1668693          	addi	a3,a3,-1002 # ffffffffc0207ef8 <commands+0x17c0>
ffffffffc02042ea:	00003617          	auipc	a2,0x3
ffffffffc02042ee:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02042f2:	0fe00593          	li	a1,254
ffffffffc02042f6:	00004517          	auipc	a0,0x4
ffffffffc02042fa:	ac250513          	addi	a0,a0,-1342 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02042fe:	f17fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!PageProperty(p0));
ffffffffc0204302:	00004697          	auipc	a3,0x4
ffffffffc0204306:	c6668693          	addi	a3,a3,-922 # ffffffffc0207f68 <commands+0x1830>
ffffffffc020430a:	00003617          	auipc	a2,0x3
ffffffffc020430e:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204312:	0f900593          	li	a1,249
ffffffffc0204316:	00004517          	auipc	a0,0x4
ffffffffc020431a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020431e:	ef7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204322:	00004697          	auipc	a3,0x4
ffffffffc0204326:	d6668693          	addi	a3,a3,-666 # ffffffffc0208088 <commands+0x1950>
ffffffffc020432a:	00003617          	auipc	a2,0x3
ffffffffc020432e:	88e60613          	addi	a2,a2,-1906 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204332:	11700593          	li	a1,279
ffffffffc0204336:	00004517          	auipc	a0,0x4
ffffffffc020433a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020433e:	ed7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == 0);
ffffffffc0204342:	00004697          	auipc	a3,0x4
ffffffffc0204346:	d7668693          	addi	a3,a3,-650 # ffffffffc02080b8 <commands+0x1980>
ffffffffc020434a:	00003617          	auipc	a2,0x3
ffffffffc020434e:	86e60613          	addi	a2,a2,-1938 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204352:	12600593          	li	a1,294
ffffffffc0204356:	00004517          	auipc	a0,0x4
ffffffffc020435a:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020435e:	eb7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == nr_free_pages());
ffffffffc0204362:	00003697          	auipc	a3,0x3
ffffffffc0204366:	75668693          	addi	a3,a3,1878 # ffffffffc0207ab8 <commands+0x1380>
ffffffffc020436a:	00003617          	auipc	a2,0x3
ffffffffc020436e:	84e60613          	addi	a2,a2,-1970 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204372:	0f300593          	li	a1,243
ffffffffc0204376:	00004517          	auipc	a0,0x4
ffffffffc020437a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020437e:	e97fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204382:	00004697          	auipc	a3,0x4
ffffffffc0204386:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0207df0 <commands+0x16b8>
ffffffffc020438a:	00003617          	auipc	a2,0x3
ffffffffc020438e:	82e60613          	addi	a2,a2,-2002 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204392:	0ba00593          	li	a1,186
ffffffffc0204396:	00004517          	auipc	a0,0x4
ffffffffc020439a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020439e:	e77fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02043a2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02043a2:	1141                	addi	sp,sp,-16
ffffffffc02043a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02043a6:	16058e63          	beqz	a1,ffffffffc0204522 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02043aa:	00659693          	slli	a3,a1,0x6
ffffffffc02043ae:	96aa                	add	a3,a3,a0
ffffffffc02043b0:	02d50d63          	beq	a0,a3,ffffffffc02043ea <default_free_pages+0x48>
ffffffffc02043b4:	651c                	ld	a5,8(a0)
ffffffffc02043b6:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02043b8:	14079563          	bnez	a5,ffffffffc0204502 <default_free_pages+0x160>
ffffffffc02043bc:	651c                	ld	a5,8(a0)
ffffffffc02043be:	8385                	srli	a5,a5,0x1
ffffffffc02043c0:	8b85                	andi	a5,a5,1
ffffffffc02043c2:	14079063          	bnez	a5,ffffffffc0204502 <default_free_pages+0x160>
ffffffffc02043c6:	87aa                	mv	a5,a0
ffffffffc02043c8:	a809                	j	ffffffffc02043da <default_free_pages+0x38>
ffffffffc02043ca:	6798                	ld	a4,8(a5)
ffffffffc02043cc:	8b05                	andi	a4,a4,1
ffffffffc02043ce:	12071a63          	bnez	a4,ffffffffc0204502 <default_free_pages+0x160>
ffffffffc02043d2:	6798                	ld	a4,8(a5)
ffffffffc02043d4:	8b09                	andi	a4,a4,2
ffffffffc02043d6:	12071663          	bnez	a4,ffffffffc0204502 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02043da:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02043de:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02043e2:	04078793          	addi	a5,a5,64
ffffffffc02043e6:	fed792e3          	bne	a5,a3,ffffffffc02043ca <default_free_pages+0x28>
    base->property = n;
ffffffffc02043ea:	2581                	sext.w	a1,a1
ffffffffc02043ec:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02043ee:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02043f2:	4789                	li	a5,2
ffffffffc02043f4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02043f8:	000a8697          	auipc	a3,0xa8
ffffffffc02043fc:	56868693          	addi	a3,a3,1384 # ffffffffc02ac960 <free_area>
ffffffffc0204400:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204402:	669c                	ld	a5,8(a3)
ffffffffc0204404:	9db9                	addw	a1,a1,a4
ffffffffc0204406:	000a8717          	auipc	a4,0xa8
ffffffffc020440a:	56b72523          	sw	a1,1386(a4) # ffffffffc02ac970 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020440e:	0cd78163          	beq	a5,a3,ffffffffc02044d0 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0204412:	fe878713          	addi	a4,a5,-24
ffffffffc0204416:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204418:	4801                	li	a6,0
ffffffffc020441a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020441e:	00e56a63          	bltu	a0,a4,ffffffffc0204432 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0204422:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204424:	04d70f63          	beq	a4,a3,ffffffffc0204482 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204428:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020442a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020442e:	fee57ae3          	bgeu	a0,a4,ffffffffc0204422 <default_free_pages+0x80>
ffffffffc0204432:	00080663          	beqz	a6,ffffffffc020443e <default_free_pages+0x9c>
ffffffffc0204436:	000a8817          	auipc	a6,0xa8
ffffffffc020443a:	52b83523          	sd	a1,1322(a6) # ffffffffc02ac960 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020443e:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204440:	e390                	sd	a2,0(a5)
ffffffffc0204442:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0204444:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204446:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0204448:	06d58a63          	beq	a1,a3,ffffffffc02044bc <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc020444c:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x85d0>
        p = le2page(le, page_link);
ffffffffc0204450:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0204454:	02061793          	slli	a5,a2,0x20
ffffffffc0204458:	83e9                	srli	a5,a5,0x1a
ffffffffc020445a:	97ba                	add	a5,a5,a4
ffffffffc020445c:	04f51b63          	bne	a0,a5,ffffffffc02044b2 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0204460:	491c                	lw	a5,16(a0)
ffffffffc0204462:	9e3d                	addw	a2,a2,a5
ffffffffc0204464:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204468:	57f5                	li	a5,-3
ffffffffc020446a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020446e:	01853803          	ld	a6,24(a0)
ffffffffc0204472:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0204474:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0204476:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020447a:	659c                	ld	a5,8(a1)
ffffffffc020447c:	01063023          	sd	a6,0(a2)
ffffffffc0204480:	a815                	j	ffffffffc02044b4 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0204482:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204484:	f114                	sd	a3,32(a0)
ffffffffc0204486:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204488:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020448a:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020448c:	00d70563          	beq	a4,a3,ffffffffc0204496 <default_free_pages+0xf4>
ffffffffc0204490:	4805                	li	a6,1
ffffffffc0204492:	87ba                	mv	a5,a4
ffffffffc0204494:	bf59                	j	ffffffffc020442a <default_free_pages+0x88>
ffffffffc0204496:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0204498:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020449a:	00d78d63          	beq	a5,a3,ffffffffc02044b4 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc020449e:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02044a2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02044a6:	02061793          	slli	a5,a2,0x20
ffffffffc02044aa:	83e9                	srli	a5,a5,0x1a
ffffffffc02044ac:	97ba                	add	a5,a5,a4
ffffffffc02044ae:	faf509e3          	beq	a0,a5,ffffffffc0204460 <default_free_pages+0xbe>
ffffffffc02044b2:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02044b4:	fe878713          	addi	a4,a5,-24
ffffffffc02044b8:	00d78963          	beq	a5,a3,ffffffffc02044ca <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02044bc:	4910                	lw	a2,16(a0)
ffffffffc02044be:	02061693          	slli	a3,a2,0x20
ffffffffc02044c2:	82e9                	srli	a3,a3,0x1a
ffffffffc02044c4:	96aa                	add	a3,a3,a0
ffffffffc02044c6:	00d70e63          	beq	a4,a3,ffffffffc02044e2 <default_free_pages+0x140>
}
ffffffffc02044ca:	60a2                	ld	ra,8(sp)
ffffffffc02044cc:	0141                	addi	sp,sp,16
ffffffffc02044ce:	8082                	ret
ffffffffc02044d0:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02044d2:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02044d6:	e398                	sd	a4,0(a5)
ffffffffc02044d8:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02044da:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02044dc:	ed1c                	sd	a5,24(a0)
}
ffffffffc02044de:	0141                	addi	sp,sp,16
ffffffffc02044e0:	8082                	ret
            base->property += p->property;
ffffffffc02044e2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02044e6:	ff078693          	addi	a3,a5,-16
ffffffffc02044ea:	9e39                	addw	a2,a2,a4
ffffffffc02044ec:	c910                	sw	a2,16(a0)
ffffffffc02044ee:	5775                	li	a4,-3
ffffffffc02044f0:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02044f4:	6398                	ld	a4,0(a5)
ffffffffc02044f6:	679c                	ld	a5,8(a5)
}
ffffffffc02044f8:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02044fa:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02044fc:	e398                	sd	a4,0(a5)
ffffffffc02044fe:	0141                	addi	sp,sp,16
ffffffffc0204500:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204502:	00004697          	auipc	a3,0x4
ffffffffc0204506:	bc668693          	addi	a3,a3,-1082 # ffffffffc02080c8 <commands+0x1990>
ffffffffc020450a:	00002617          	auipc	a2,0x2
ffffffffc020450e:	6ae60613          	addi	a2,a2,1710 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204512:	08300593          	li	a1,131
ffffffffc0204516:	00004517          	auipc	a0,0x4
ffffffffc020451a:	8a250513          	addi	a0,a0,-1886 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020451e:	cf7fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc0204522:	00004697          	auipc	a3,0x4
ffffffffc0204526:	bce68693          	addi	a3,a3,-1074 # ffffffffc02080f0 <commands+0x19b8>
ffffffffc020452a:	00002617          	auipc	a2,0x2
ffffffffc020452e:	68e60613          	addi	a2,a2,1678 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204532:	08000593          	li	a1,128
ffffffffc0204536:	00004517          	auipc	a0,0x4
ffffffffc020453a:	88250513          	addi	a0,a0,-1918 # ffffffffc0207db8 <commands+0x1680>
ffffffffc020453e:	cd7fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204542 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0204542:	c959                	beqz	a0,ffffffffc02045d8 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0204544:	000a8597          	auipc	a1,0xa8
ffffffffc0204548:	41c58593          	addi	a1,a1,1052 # ffffffffc02ac960 <free_area>
ffffffffc020454c:	0105a803          	lw	a6,16(a1)
ffffffffc0204550:	862a                	mv	a2,a0
ffffffffc0204552:	02081793          	slli	a5,a6,0x20
ffffffffc0204556:	9381                	srli	a5,a5,0x20
ffffffffc0204558:	00a7ee63          	bltu	a5,a0,ffffffffc0204574 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020455c:	87ae                	mv	a5,a1
ffffffffc020455e:	a801                	j	ffffffffc020456e <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0204560:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204564:	02071693          	slli	a3,a4,0x20
ffffffffc0204568:	9281                	srli	a3,a3,0x20
ffffffffc020456a:	00c6f763          	bgeu	a3,a2,ffffffffc0204578 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020456e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204570:	feb798e3          	bne	a5,a1,ffffffffc0204560 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0204574:	4501                	li	a0,0
}
ffffffffc0204576:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0204578:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020457c:	dd6d                	beqz	a0,ffffffffc0204576 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020457e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204582:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0204586:	00060e1b          	sext.w	t3,a2
ffffffffc020458a:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3670>
    next->prev = prev;
ffffffffc020458e:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5538>
        if (page->property > n) {
ffffffffc0204592:	02d67863          	bgeu	a2,a3,ffffffffc02045c2 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0204596:	061a                	slli	a2,a2,0x6
ffffffffc0204598:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020459a:	41c7073b          	subw	a4,a4,t3
ffffffffc020459e:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02045a0:	00860693          	addi	a3,a2,8
ffffffffc02045a4:	4709                	li	a4,2
ffffffffc02045a6:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02045aa:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02045ae:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02045b2:	0105a803          	lw	a6,16(a1)
ffffffffc02045b6:	e314                	sd	a3,0(a4)
ffffffffc02045b8:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02045bc:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02045be:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02045c2:	41c8083b          	subw	a6,a6,t3
ffffffffc02045c6:	000a8717          	auipc	a4,0xa8
ffffffffc02045ca:	3b072523          	sw	a6,938(a4) # ffffffffc02ac970 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02045ce:	5775                	li	a4,-3
ffffffffc02045d0:	17c1                	addi	a5,a5,-16
ffffffffc02045d2:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02045d6:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02045d8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02045da:	00004697          	auipc	a3,0x4
ffffffffc02045de:	b1668693          	addi	a3,a3,-1258 # ffffffffc02080f0 <commands+0x19b8>
ffffffffc02045e2:	00002617          	auipc	a2,0x2
ffffffffc02045e6:	5d660613          	addi	a2,a2,1494 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02045ea:	06200593          	li	a1,98
ffffffffc02045ee:	00003517          	auipc	a0,0x3
ffffffffc02045f2:	7ca50513          	addi	a0,a0,1994 # ffffffffc0207db8 <commands+0x1680>
default_alloc_pages(size_t n) {
ffffffffc02045f6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02045f8:	c1dfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02045fc <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02045fc:	1141                	addi	sp,sp,-16
ffffffffc02045fe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204600:	c1ed                	beqz	a1,ffffffffc02046e2 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204602:	00659693          	slli	a3,a1,0x6
ffffffffc0204606:	96aa                	add	a3,a3,a0
ffffffffc0204608:	02d50463          	beq	a0,a3,ffffffffc0204630 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020460c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020460e:	87aa                	mv	a5,a0
ffffffffc0204610:	8b05                	andi	a4,a4,1
ffffffffc0204612:	e709                	bnez	a4,ffffffffc020461c <default_init_memmap+0x20>
ffffffffc0204614:	a07d                	j	ffffffffc02046c2 <default_init_memmap+0xc6>
ffffffffc0204616:	6798                	ld	a4,8(a5)
ffffffffc0204618:	8b05                	andi	a4,a4,1
ffffffffc020461a:	c745                	beqz	a4,ffffffffc02046c2 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc020461c:	0007a823          	sw	zero,16(a5)
ffffffffc0204620:	0007b423          	sd	zero,8(a5)
ffffffffc0204624:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204628:	04078793          	addi	a5,a5,64
ffffffffc020462c:	fed795e3          	bne	a5,a3,ffffffffc0204616 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0204630:	2581                	sext.w	a1,a1
ffffffffc0204632:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204634:	4789                	li	a5,2
ffffffffc0204636:	00850713          	addi	a4,a0,8
ffffffffc020463a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020463e:	000a8697          	auipc	a3,0xa8
ffffffffc0204642:	32268693          	addi	a3,a3,802 # ffffffffc02ac960 <free_area>
ffffffffc0204646:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204648:	669c                	ld	a5,8(a3)
ffffffffc020464a:	9db9                	addw	a1,a1,a4
ffffffffc020464c:	000a8717          	auipc	a4,0xa8
ffffffffc0204650:	32b72223          	sw	a1,804(a4) # ffffffffc02ac970 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204654:	04d78a63          	beq	a5,a3,ffffffffc02046a8 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204658:	fe878713          	addi	a4,a5,-24
ffffffffc020465c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020465e:	4801                	li	a6,0
ffffffffc0204660:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204664:	00e56a63          	bltu	a0,a4,ffffffffc0204678 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0204668:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020466a:	02d70563          	beq	a4,a3,ffffffffc0204694 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020466e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204670:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204674:	fee57ae3          	bgeu	a0,a4,ffffffffc0204668 <default_init_memmap+0x6c>
ffffffffc0204678:	00080663          	beqz	a6,ffffffffc0204684 <default_init_memmap+0x88>
ffffffffc020467c:	000a8717          	auipc	a4,0xa8
ffffffffc0204680:	2eb73223          	sd	a1,740(a4) # ffffffffc02ac960 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204684:	6398                	ld	a4,0(a5)
}
ffffffffc0204686:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204688:	e390                	sd	a2,0(a5)
ffffffffc020468a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020468c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020468e:	ed18                	sd	a4,24(a0)
ffffffffc0204690:	0141                	addi	sp,sp,16
ffffffffc0204692:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204694:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204696:	f114                	sd	a3,32(a0)
ffffffffc0204698:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020469a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020469c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020469e:	00d70e63          	beq	a4,a3,ffffffffc02046ba <default_init_memmap+0xbe>
ffffffffc02046a2:	4805                	li	a6,1
ffffffffc02046a4:	87ba                	mv	a5,a4
ffffffffc02046a6:	b7e9                	j	ffffffffc0204670 <default_init_memmap+0x74>
}
ffffffffc02046a8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02046aa:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02046ae:	e398                	sd	a4,0(a5)
ffffffffc02046b0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02046b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02046b4:	ed1c                	sd	a5,24(a0)
}
ffffffffc02046b6:	0141                	addi	sp,sp,16
ffffffffc02046b8:	8082                	ret
ffffffffc02046ba:	60a2                	ld	ra,8(sp)
ffffffffc02046bc:	e290                	sd	a2,0(a3)
ffffffffc02046be:	0141                	addi	sp,sp,16
ffffffffc02046c0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02046c2:	00004697          	auipc	a3,0x4
ffffffffc02046c6:	a3668693          	addi	a3,a3,-1482 # ffffffffc02080f8 <commands+0x19c0>
ffffffffc02046ca:	00002617          	auipc	a2,0x2
ffffffffc02046ce:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02046d2:	04900593          	li	a1,73
ffffffffc02046d6:	00003517          	auipc	a0,0x3
ffffffffc02046da:	6e250513          	addi	a0,a0,1762 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02046de:	b37fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc02046e2:	00004697          	auipc	a3,0x4
ffffffffc02046e6:	a0e68693          	addi	a3,a3,-1522 # ffffffffc02080f0 <commands+0x19b8>
ffffffffc02046ea:	00002617          	auipc	a2,0x2
ffffffffc02046ee:	4ce60613          	addi	a2,a2,1230 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02046f2:	04600593          	li	a1,70
ffffffffc02046f6:	00003517          	auipc	a0,0x3
ffffffffc02046fa:	6c250513          	addi	a0,a0,1730 # ffffffffc0207db8 <commands+0x1680>
ffffffffc02046fe:	b17fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204702 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0204702:	000a8797          	auipc	a5,0xa8
ffffffffc0204706:	27678793          	addi	a5,a5,630 # ffffffffc02ac978 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020470a:	f51c                	sd	a5,40(a0)
ffffffffc020470c:	e79c                	sd	a5,8(a5)
ffffffffc020470e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0204710:	4501                	li	a0,0
ffffffffc0204712:	8082                	ret

ffffffffc0204714 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0204714:	4501                	li	a0,0
ffffffffc0204716:	8082                	ret

ffffffffc0204718 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0204718:	4501                	li	a0,0
ffffffffc020471a:	8082                	ret

ffffffffc020471c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020471c:	4501                	li	a0,0
ffffffffc020471e:	8082                	ret

ffffffffc0204720 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0204720:	711d                	addi	sp,sp,-96
ffffffffc0204722:	fc4e                	sd	s3,56(sp)
ffffffffc0204724:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0204726:	00004517          	auipc	a0,0x4
ffffffffc020472a:	a3250513          	addi	a0,a0,-1486 # ffffffffc0208158 <default_pmm_manager+0x50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020472e:	698d                	lui	s3,0x3
ffffffffc0204730:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0204732:	e8a2                	sd	s0,80(sp)
ffffffffc0204734:	e4a6                	sd	s1,72(sp)
ffffffffc0204736:	ec86                	sd	ra,88(sp)
ffffffffc0204738:	e0ca                	sd	s2,64(sp)
ffffffffc020473a:	f456                	sd	s5,40(sp)
ffffffffc020473c:	f05a                	sd	s6,32(sp)
ffffffffc020473e:	ec5e                	sd	s7,24(sp)
ffffffffc0204740:	e862                	sd	s8,16(sp)
ffffffffc0204742:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0204744:	000a8417          	auipc	s0,0xa8
ffffffffc0204748:	0e440413          	addi	s0,s0,228 # ffffffffc02ac828 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020474c:	985fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204750:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0204754:	4004                	lw	s1,0(s0)
ffffffffc0204756:	4791                	li	a5,4
ffffffffc0204758:	2481                	sext.w	s1,s1
ffffffffc020475a:	14f49963          	bne	s1,a5,ffffffffc02048ac <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020475e:	00004517          	auipc	a0,0x4
ffffffffc0204762:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0208198 <default_pmm_manager+0x90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0204766:	6a85                	lui	s5,0x1
ffffffffc0204768:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020476a:	967fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020476e:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc0204772:	00042903          	lw	s2,0(s0)
ffffffffc0204776:	2901                	sext.w	s2,s2
ffffffffc0204778:	2a991a63          	bne	s2,s1,ffffffffc0204a2c <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020477c:	00004517          	auipc	a0,0x4
ffffffffc0204780:	a4450513          	addi	a0,a0,-1468 # ffffffffc02081c0 <default_pmm_manager+0xb8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0204784:	6b91                	lui	s7,0x4
ffffffffc0204786:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0204788:	949fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020478c:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc0204790:	4004                	lw	s1,0(s0)
ffffffffc0204792:	2481                	sext.w	s1,s1
ffffffffc0204794:	27249c63          	bne	s1,s2,ffffffffc0204a0c <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0204798:	00004517          	auipc	a0,0x4
ffffffffc020479c:	a5050513          	addi	a0,a0,-1456 # ffffffffc02081e8 <default_pmm_manager+0xe0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02047a0:	6909                	lui	s2,0x2
ffffffffc02047a2:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02047a4:	92dfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02047a8:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc02047ac:	401c                	lw	a5,0(s0)
ffffffffc02047ae:	2781                	sext.w	a5,a5
ffffffffc02047b0:	22979e63          	bne	a5,s1,ffffffffc02049ec <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02047b4:	00004517          	auipc	a0,0x4
ffffffffc02047b8:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0208210 <default_pmm_manager+0x108>
ffffffffc02047bc:	915fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02047c0:	6795                	lui	a5,0x5
ffffffffc02047c2:	4739                	li	a4,14
ffffffffc02047c4:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc02047c8:	4004                	lw	s1,0(s0)
ffffffffc02047ca:	4795                	li	a5,5
ffffffffc02047cc:	2481                	sext.w	s1,s1
ffffffffc02047ce:	1ef49f63          	bne	s1,a5,ffffffffc02049cc <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02047d2:	00004517          	auipc	a0,0x4
ffffffffc02047d6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02081e8 <default_pmm_manager+0xe0>
ffffffffc02047da:	8f7fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02047de:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02047e2:	401c                	lw	a5,0(s0)
ffffffffc02047e4:	2781                	sext.w	a5,a5
ffffffffc02047e6:	1c979363          	bne	a5,s1,ffffffffc02049ac <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02047ea:	00004517          	auipc	a0,0x4
ffffffffc02047ee:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0208198 <default_pmm_manager+0x90>
ffffffffc02047f2:	8dffb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02047f6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02047fa:	401c                	lw	a5,0(s0)
ffffffffc02047fc:	4719                	li	a4,6
ffffffffc02047fe:	2781                	sext.w	a5,a5
ffffffffc0204800:	18e79663          	bne	a5,a4,ffffffffc020498c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0204804:	00004517          	auipc	a0,0x4
ffffffffc0204808:	9e450513          	addi	a0,a0,-1564 # ffffffffc02081e8 <default_pmm_manager+0xe0>
ffffffffc020480c:	8c5fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0204810:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0204814:	401c                	lw	a5,0(s0)
ffffffffc0204816:	471d                	li	a4,7
ffffffffc0204818:	2781                	sext.w	a5,a5
ffffffffc020481a:	14e79963          	bne	a5,a4,ffffffffc020496c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020481e:	00004517          	auipc	a0,0x4
ffffffffc0204822:	93a50513          	addi	a0,a0,-1734 # ffffffffc0208158 <default_pmm_manager+0x50>
ffffffffc0204826:	8abfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020482a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020482e:	401c                	lw	a5,0(s0)
ffffffffc0204830:	4721                	li	a4,8
ffffffffc0204832:	2781                	sext.w	a5,a5
ffffffffc0204834:	10e79c63          	bne	a5,a4,ffffffffc020494c <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0204838:	00004517          	auipc	a0,0x4
ffffffffc020483c:	98850513          	addi	a0,a0,-1656 # ffffffffc02081c0 <default_pmm_manager+0xb8>
ffffffffc0204840:	891fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0204844:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0204848:	401c                	lw	a5,0(s0)
ffffffffc020484a:	4725                	li	a4,9
ffffffffc020484c:	2781                	sext.w	a5,a5
ffffffffc020484e:	0ce79f63          	bne	a5,a4,ffffffffc020492c <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0204852:	00004517          	auipc	a0,0x4
ffffffffc0204856:	9be50513          	addi	a0,a0,-1602 # ffffffffc0208210 <default_pmm_manager+0x108>
ffffffffc020485a:	877fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020485e:	6795                	lui	a5,0x5
ffffffffc0204860:	4739                	li	a4,14
ffffffffc0204862:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0204866:	4004                	lw	s1,0(s0)
ffffffffc0204868:	47a9                	li	a5,10
ffffffffc020486a:	2481                	sext.w	s1,s1
ffffffffc020486c:	0af49063          	bne	s1,a5,ffffffffc020490c <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204870:	00004517          	auipc	a0,0x4
ffffffffc0204874:	92850513          	addi	a0,a0,-1752 # ffffffffc0208198 <default_pmm_manager+0x90>
ffffffffc0204878:	859fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020487c:	6785                	lui	a5,0x1
ffffffffc020487e:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0204882:	06979563          	bne	a5,s1,ffffffffc02048ec <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0204886:	401c                	lw	a5,0(s0)
ffffffffc0204888:	472d                	li	a4,11
ffffffffc020488a:	2781                	sext.w	a5,a5
ffffffffc020488c:	04e79063          	bne	a5,a4,ffffffffc02048cc <_fifo_check_swap+0x1ac>
}
ffffffffc0204890:	60e6                	ld	ra,88(sp)
ffffffffc0204892:	6446                	ld	s0,80(sp)
ffffffffc0204894:	64a6                	ld	s1,72(sp)
ffffffffc0204896:	6906                	ld	s2,64(sp)
ffffffffc0204898:	79e2                	ld	s3,56(sp)
ffffffffc020489a:	7a42                	ld	s4,48(sp)
ffffffffc020489c:	7aa2                	ld	s5,40(sp)
ffffffffc020489e:	7b02                	ld	s6,32(sp)
ffffffffc02048a0:	6be2                	ld	s7,24(sp)
ffffffffc02048a2:	6c42                	ld	s8,16(sp)
ffffffffc02048a4:	6ca2                	ld	s9,8(sp)
ffffffffc02048a6:	4501                	li	a0,0
ffffffffc02048a8:	6125                	addi	sp,sp,96
ffffffffc02048aa:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02048ac:	00003697          	auipc	a3,0x3
ffffffffc02048b0:	39c68693          	addi	a3,a3,924 # ffffffffc0207c48 <commands+0x1510>
ffffffffc02048b4:	00002617          	auipc	a2,0x2
ffffffffc02048b8:	30460613          	addi	a2,a2,772 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02048bc:	05100593          	li	a1,81
ffffffffc02048c0:	00004517          	auipc	a0,0x4
ffffffffc02048c4:	8c050513          	addi	a0,a0,-1856 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc02048c8:	94dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==11);
ffffffffc02048cc:	00004697          	auipc	a3,0x4
ffffffffc02048d0:	9f468693          	addi	a3,a3,-1548 # ffffffffc02082c0 <default_pmm_manager+0x1b8>
ffffffffc02048d4:	00002617          	auipc	a2,0x2
ffffffffc02048d8:	2e460613          	addi	a2,a2,740 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02048dc:	07300593          	li	a1,115
ffffffffc02048e0:	00004517          	auipc	a0,0x4
ffffffffc02048e4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc02048e8:	92dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02048ec:	00004697          	auipc	a3,0x4
ffffffffc02048f0:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0208298 <default_pmm_manager+0x190>
ffffffffc02048f4:	00002617          	auipc	a2,0x2
ffffffffc02048f8:	2c460613          	addi	a2,a2,708 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02048fc:	07100593          	li	a1,113
ffffffffc0204900:	00004517          	auipc	a0,0x4
ffffffffc0204904:	88050513          	addi	a0,a0,-1920 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204908:	90dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==10);
ffffffffc020490c:	00004697          	auipc	a3,0x4
ffffffffc0204910:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208288 <default_pmm_manager+0x180>
ffffffffc0204914:	00002617          	auipc	a2,0x2
ffffffffc0204918:	2a460613          	addi	a2,a2,676 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020491c:	06f00593          	li	a1,111
ffffffffc0204920:	00004517          	auipc	a0,0x4
ffffffffc0204924:	86050513          	addi	a0,a0,-1952 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204928:	8edfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==9);
ffffffffc020492c:	00004697          	auipc	a3,0x4
ffffffffc0204930:	94c68693          	addi	a3,a3,-1716 # ffffffffc0208278 <default_pmm_manager+0x170>
ffffffffc0204934:	00002617          	auipc	a2,0x2
ffffffffc0204938:	28460613          	addi	a2,a2,644 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020493c:	06c00593          	li	a1,108
ffffffffc0204940:	00004517          	auipc	a0,0x4
ffffffffc0204944:	84050513          	addi	a0,a0,-1984 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204948:	8cdfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==8);
ffffffffc020494c:	00004697          	auipc	a3,0x4
ffffffffc0204950:	91c68693          	addi	a3,a3,-1764 # ffffffffc0208268 <default_pmm_manager+0x160>
ffffffffc0204954:	00002617          	auipc	a2,0x2
ffffffffc0204958:	26460613          	addi	a2,a2,612 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020495c:	06900593          	li	a1,105
ffffffffc0204960:	00004517          	auipc	a0,0x4
ffffffffc0204964:	82050513          	addi	a0,a0,-2016 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204968:	8adfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==7);
ffffffffc020496c:	00004697          	auipc	a3,0x4
ffffffffc0204970:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0208258 <default_pmm_manager+0x150>
ffffffffc0204974:	00002617          	auipc	a2,0x2
ffffffffc0204978:	24460613          	addi	a2,a2,580 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020497c:	06600593          	li	a1,102
ffffffffc0204980:	00004517          	auipc	a0,0x4
ffffffffc0204984:	80050513          	addi	a0,a0,-2048 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204988:	88dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==6);
ffffffffc020498c:	00004697          	auipc	a3,0x4
ffffffffc0204990:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0208248 <default_pmm_manager+0x140>
ffffffffc0204994:	00002617          	auipc	a2,0x2
ffffffffc0204998:	22460613          	addi	a2,a2,548 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020499c:	06300593          	li	a1,99
ffffffffc02049a0:	00003517          	auipc	a0,0x3
ffffffffc02049a4:	7e050513          	addi	a0,a0,2016 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc02049a8:	86dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc02049ac:	00004697          	auipc	a3,0x4
ffffffffc02049b0:	88c68693          	addi	a3,a3,-1908 # ffffffffc0208238 <default_pmm_manager+0x130>
ffffffffc02049b4:	00002617          	auipc	a2,0x2
ffffffffc02049b8:	20460613          	addi	a2,a2,516 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02049bc:	06000593          	li	a1,96
ffffffffc02049c0:	00003517          	auipc	a0,0x3
ffffffffc02049c4:	7c050513          	addi	a0,a0,1984 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc02049c8:	84dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc02049cc:	00004697          	auipc	a3,0x4
ffffffffc02049d0:	86c68693          	addi	a3,a3,-1940 # ffffffffc0208238 <default_pmm_manager+0x130>
ffffffffc02049d4:	00002617          	auipc	a2,0x2
ffffffffc02049d8:	1e460613          	addi	a2,a2,484 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02049dc:	05d00593          	li	a1,93
ffffffffc02049e0:	00003517          	auipc	a0,0x3
ffffffffc02049e4:	7a050513          	addi	a0,a0,1952 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc02049e8:	82dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc02049ec:	00003697          	auipc	a3,0x3
ffffffffc02049f0:	25c68693          	addi	a3,a3,604 # ffffffffc0207c48 <commands+0x1510>
ffffffffc02049f4:	00002617          	auipc	a2,0x2
ffffffffc02049f8:	1c460613          	addi	a2,a2,452 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02049fc:	05a00593          	li	a1,90
ffffffffc0204a00:	00003517          	auipc	a0,0x3
ffffffffc0204a04:	78050513          	addi	a0,a0,1920 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204a08:	80dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0204a0c:	00003697          	auipc	a3,0x3
ffffffffc0204a10:	23c68693          	addi	a3,a3,572 # ffffffffc0207c48 <commands+0x1510>
ffffffffc0204a14:	00002617          	auipc	a2,0x2
ffffffffc0204a18:	1a460613          	addi	a2,a2,420 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a1c:	05700593          	li	a1,87
ffffffffc0204a20:	00003517          	auipc	a0,0x3
ffffffffc0204a24:	76050513          	addi	a0,a0,1888 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204a28:	fecfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0204a2c:	00003697          	auipc	a3,0x3
ffffffffc0204a30:	21c68693          	addi	a3,a3,540 # ffffffffc0207c48 <commands+0x1510>
ffffffffc0204a34:	00002617          	auipc	a2,0x2
ffffffffc0204a38:	18460613          	addi	a2,a2,388 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a3c:	05400593          	li	a1,84
ffffffffc0204a40:	00003517          	auipc	a0,0x3
ffffffffc0204a44:	74050513          	addi	a0,a0,1856 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204a48:	fccfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204a4c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204a4c:	751c                	ld	a5,40(a0)
{
ffffffffc0204a4e:	1141                	addi	sp,sp,-16
ffffffffc0204a50:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204a52:	cf91                	beqz	a5,ffffffffc0204a6e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0204a54:	ee0d                	bnez	a2,ffffffffc0204a8e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0204a56:	679c                	ld	a5,8(a5)
}
ffffffffc0204a58:	60a2                	ld	ra,8(sp)
ffffffffc0204a5a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204a5c:	6394                	ld	a3,0(a5)
ffffffffc0204a5e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204a60:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204a64:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204a66:	e314                	sd	a3,0(a4)
ffffffffc0204a68:	e19c                	sd	a5,0(a1)
}
ffffffffc0204a6a:	0141                	addi	sp,sp,16
ffffffffc0204a6c:	8082                	ret
         assert(head != NULL);
ffffffffc0204a6e:	00004697          	auipc	a3,0x4
ffffffffc0204a72:	88268693          	addi	a3,a3,-1918 # ffffffffc02082f0 <default_pmm_manager+0x1e8>
ffffffffc0204a76:	00002617          	auipc	a2,0x2
ffffffffc0204a7a:	14260613          	addi	a2,a2,322 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a7e:	04100593          	li	a1,65
ffffffffc0204a82:	00003517          	auipc	a0,0x3
ffffffffc0204a86:	6fe50513          	addi	a0,a0,1790 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204a8a:	f8afb0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(in_tick==0);
ffffffffc0204a8e:	00004697          	auipc	a3,0x4
ffffffffc0204a92:	87268693          	addi	a3,a3,-1934 # ffffffffc0208300 <default_pmm_manager+0x1f8>
ffffffffc0204a96:	00002617          	auipc	a2,0x2
ffffffffc0204a9a:	12260613          	addi	a2,a2,290 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a9e:	04200593          	li	a1,66
ffffffffc0204aa2:	00003517          	auipc	a0,0x3
ffffffffc0204aa6:	6de50513          	addi	a0,a0,1758 # ffffffffc0208180 <default_pmm_manager+0x78>
ffffffffc0204aaa:	f6afb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204aae <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204aae:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204ab2:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204ab4:	cb09                	beqz	a4,ffffffffc0204ac6 <_fifo_map_swappable+0x18>
ffffffffc0204ab6:	cb81                	beqz	a5,ffffffffc0204ac6 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204ab8:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204aba:	e398                	sd	a4,0(a5)
}
ffffffffc0204abc:	4501                	li	a0,0
ffffffffc0204abe:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204ac0:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0204ac2:	f614                	sd	a3,40(a2)
ffffffffc0204ac4:	8082                	ret
{
ffffffffc0204ac6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204ac8:	00004697          	auipc	a3,0x4
ffffffffc0204acc:	80868693          	addi	a3,a3,-2040 # ffffffffc02082d0 <default_pmm_manager+0x1c8>
ffffffffc0204ad0:	00002617          	auipc	a2,0x2
ffffffffc0204ad4:	0e860613          	addi	a2,a2,232 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204ad8:	03200593          	li	a1,50
ffffffffc0204adc:	00003517          	auipc	a0,0x3
ffffffffc0204ae0:	6a450513          	addi	a0,a0,1700 # ffffffffc0208180 <default_pmm_manager+0x78>
{
ffffffffc0204ae4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204ae6:	f2efb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204aea <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204aea:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204aec:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204aee:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204af0:	a41fb0ef          	jal	ra,ffffffffc0200530 <ide_device_valid>
ffffffffc0204af4:	cd01                	beqz	a0,ffffffffc0204b0c <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204af6:	4505                	li	a0,1
ffffffffc0204af8:	a3ffb0ef          	jal	ra,ffffffffc0200536 <ide_device_size>
}
ffffffffc0204afc:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204afe:	810d                	srli	a0,a0,0x3
ffffffffc0204b00:	000a8797          	auipc	a5,0xa8
ffffffffc0204b04:	e2a7b023          	sd	a0,-480(a5) # ffffffffc02ac920 <max_swap_offset>
}
ffffffffc0204b08:	0141                	addi	sp,sp,16
ffffffffc0204b0a:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b0c:	00004617          	auipc	a2,0x4
ffffffffc0204b10:	81c60613          	addi	a2,a2,-2020 # ffffffffc0208328 <default_pmm_manager+0x220>
ffffffffc0204b14:	45b5                	li	a1,13
ffffffffc0204b16:	00004517          	auipc	a0,0x4
ffffffffc0204b1a:	83250513          	addi	a0,a0,-1998 # ffffffffc0208348 <default_pmm_manager+0x240>
ffffffffc0204b1e:	ef6fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204b22 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b22:	1141                	addi	sp,sp,-16
ffffffffc0204b24:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b26:	00855793          	srli	a5,a0,0x8
ffffffffc0204b2a:	cfb9                	beqz	a5,ffffffffc0204b88 <swapfs_read+0x66>
ffffffffc0204b2c:	000a8717          	auipc	a4,0xa8
ffffffffc0204b30:	df470713          	addi	a4,a4,-524 # ffffffffc02ac920 <max_swap_offset>
ffffffffc0204b34:	6318                	ld	a4,0(a4)
ffffffffc0204b36:	04e7f963          	bgeu	a5,a4,ffffffffc0204b88 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b3a:	000a8717          	auipc	a4,0xa8
ffffffffc0204b3e:	d4e70713          	addi	a4,a4,-690 # ffffffffc02ac888 <pages>
ffffffffc0204b42:	6310                	ld	a2,0(a4)
ffffffffc0204b44:	00004717          	auipc	a4,0x4
ffffffffc0204b48:	15c70713          	addi	a4,a4,348 # ffffffffc0208ca0 <nbase>
ffffffffc0204b4c:	40c58633          	sub	a2,a1,a2
ffffffffc0204b50:	630c                	ld	a1,0(a4)
ffffffffc0204b52:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b54:	000a8717          	auipc	a4,0xa8
ffffffffc0204b58:	ccc70713          	addi	a4,a4,-820 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0204b5c:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b5e:	6314                	ld	a3,0(a4)
ffffffffc0204b60:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b64:	8331                	srli	a4,a4,0xc
ffffffffc0204b66:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b6a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b6c:	02d77a63          	bgeu	a4,a3,ffffffffc0204ba0 <swapfs_read+0x7e>
ffffffffc0204b70:	000a8797          	auipc	a5,0xa8
ffffffffc0204b74:	d0878793          	addi	a5,a5,-760 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0204b78:	639c                	ld	a5,0(a5)
}
ffffffffc0204b7a:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b7c:	46a1                	li	a3,8
ffffffffc0204b7e:	963e                	add	a2,a2,a5
ffffffffc0204b80:	4505                	li	a0,1
}
ffffffffc0204b82:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b84:	9b9fb06f          	j	ffffffffc020053c <ide_read_secs>
ffffffffc0204b88:	86aa                	mv	a3,a0
ffffffffc0204b8a:	00003617          	auipc	a2,0x3
ffffffffc0204b8e:	7d660613          	addi	a2,a2,2006 # ffffffffc0208360 <default_pmm_manager+0x258>
ffffffffc0204b92:	45d1                	li	a1,20
ffffffffc0204b94:	00003517          	auipc	a0,0x3
ffffffffc0204b98:	7b450513          	addi	a0,a0,1972 # ffffffffc0208348 <default_pmm_manager+0x240>
ffffffffc0204b9c:	e78fb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0204ba0:	86b2                	mv	a3,a2
ffffffffc0204ba2:	06900593          	li	a1,105
ffffffffc0204ba6:	00002617          	auipc	a2,0x2
ffffffffc0204baa:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0204bae:	00002517          	auipc	a0,0x2
ffffffffc0204bb2:	44a50513          	addi	a0,a0,1098 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0204bb6:	e5efb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204bba <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bba:	1141                	addi	sp,sp,-16
ffffffffc0204bbc:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bbe:	00855793          	srli	a5,a0,0x8
ffffffffc0204bc2:	cfb9                	beqz	a5,ffffffffc0204c20 <swapfs_write+0x66>
ffffffffc0204bc4:	000a8717          	auipc	a4,0xa8
ffffffffc0204bc8:	d5c70713          	addi	a4,a4,-676 # ffffffffc02ac920 <max_swap_offset>
ffffffffc0204bcc:	6318                	ld	a4,0(a4)
ffffffffc0204bce:	04e7f963          	bgeu	a5,a4,ffffffffc0204c20 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204bd2:	000a8717          	auipc	a4,0xa8
ffffffffc0204bd6:	cb670713          	addi	a4,a4,-842 # ffffffffc02ac888 <pages>
ffffffffc0204bda:	6310                	ld	a2,0(a4)
ffffffffc0204bdc:	00004717          	auipc	a4,0x4
ffffffffc0204be0:	0c470713          	addi	a4,a4,196 # ffffffffc0208ca0 <nbase>
ffffffffc0204be4:	40c58633          	sub	a2,a1,a2
ffffffffc0204be8:	630c                	ld	a1,0(a4)
ffffffffc0204bea:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bec:	000a8717          	auipc	a4,0xa8
ffffffffc0204bf0:	c3470713          	addi	a4,a4,-972 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0204bf4:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bf6:	6314                	ld	a3,0(a4)
ffffffffc0204bf8:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bfc:	8331                	srli	a4,a4,0xc
ffffffffc0204bfe:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c02:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c04:	02d77a63          	bgeu	a4,a3,ffffffffc0204c38 <swapfs_write+0x7e>
ffffffffc0204c08:	000a8797          	auipc	a5,0xa8
ffffffffc0204c0c:	c7078793          	addi	a5,a5,-912 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0204c10:	639c                	ld	a5,0(a5)
}
ffffffffc0204c12:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c14:	46a1                	li	a3,8
ffffffffc0204c16:	963e                	add	a2,a2,a5
ffffffffc0204c18:	4505                	li	a0,1
}
ffffffffc0204c1a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c1c:	945fb06f          	j	ffffffffc0200560 <ide_write_secs>
ffffffffc0204c20:	86aa                	mv	a3,a0
ffffffffc0204c22:	00003617          	auipc	a2,0x3
ffffffffc0204c26:	73e60613          	addi	a2,a2,1854 # ffffffffc0208360 <default_pmm_manager+0x258>
ffffffffc0204c2a:	45e5                	li	a1,25
ffffffffc0204c2c:	00003517          	auipc	a0,0x3
ffffffffc0204c30:	71c50513          	addi	a0,a0,1820 # ffffffffc0208348 <default_pmm_manager+0x240>
ffffffffc0204c34:	de0fb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0204c38:	86b2                	mv	a3,a2
ffffffffc0204c3a:	06900593          	li	a1,105
ffffffffc0204c3e:	00002617          	auipc	a2,0x2
ffffffffc0204c42:	36260613          	addi	a2,a2,866 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0204c46:	00002517          	auipc	a0,0x2
ffffffffc0204c4a:	3b250513          	addi	a0,a0,946 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0204c4e:	dc6fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204c52 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c52:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c54:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c56:	79c000ef          	jal	ra,ffffffffc02053f2 <do_exit>

ffffffffc0204c5a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204c5a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204c5e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204c62:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204c64:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204c66:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204c6a:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204c6e:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204c72:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204c76:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204c7a:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204c7e:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204c82:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204c86:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204c8a:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204c8e:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204c92:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204c96:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204c98:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204c9a:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204c9e:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204ca2:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204ca6:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204caa:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204cae:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204cb2:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204cb6:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204cba:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204cbe:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204cc2:	8082                	ret

ffffffffc0204cc4 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204cc4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cc6:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204cca:	e022                	sd	s0,0(sp)
ffffffffc0204ccc:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cce:	bd8fe0ef          	jal	ra,ffffffffc02030a6 <kmalloc>
ffffffffc0204cd2:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cd4:	cd29                	beqz	a0,ffffffffc0204d2e <alloc_proc+0x6a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;            // 初始化状态为未初始化
ffffffffc0204cd6:	57fd                	li	a5,-1
ffffffffc0204cd8:	1782                	slli	a5,a5,0x20
ffffffffc0204cda:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                       // 初始化运行时间片
        proc->kstack = 0;                     // 内核栈地址初始化为0
        proc->need_resched = 0;               // 初始时无需调度
        proc->parent = NULL;                  // 父进程为空
        proc->mm = NULL;                      // 虚拟内存管理结构为空
        memset(&(proc->context), 0, sizeof(struct context));  // 清空上下文
ffffffffc0204cdc:	07000613          	li	a2,112
ffffffffc0204ce0:	4581                	li	a1,0
        proc->runs = 0;                       // 初始化运行时间片
ffffffffc0204ce2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                     // 内核栈地址初始化为0
ffffffffc0204ce6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;               // 初始时无需调度
ffffffffc0204cea:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;                  // 父进程为空
ffffffffc0204cee:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                      // 虚拟内存管理结构为空
ffffffffc0204cf2:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));  // 清空上下文
ffffffffc0204cf6:	03050513          	addi	a0,a0,48
ffffffffc0204cfa:	4a0010ef          	jal	ra,ffffffffc020619a <memset>
        proc->tf = NULL;                      // 中断帧指针初始化为空
        proc->cr3 = boot_cr3;                 // 页表基址设置为内核页表
ffffffffc0204cfe:	000a8797          	auipc	a5,0xa8
ffffffffc0204d02:	b8278793          	addi	a5,a5,-1150 # ffffffffc02ac880 <boot_cr3>
ffffffffc0204d06:	639c                	ld	a5,0(a5)
        proc->tf = NULL;                      // 中断帧指针初始化为空
ffffffffc0204d08:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                      // 标志位初始化为0
ffffffffc0204d0c:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;                 // 页表基址设置为内核页表
ffffffffc0204d10:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN); // 清空进程名
ffffffffc0204d12:	463d                	li	a2,15
ffffffffc0204d14:	4581                	li	a1,0
ffffffffc0204d16:	0b440513          	addi	a0,s0,180
ffffffffc0204d1a:	480010ef          	jal	ra,ffffffffc020619a <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;
ffffffffc0204d1e:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204d22:	10043023          	sd	zero,256(s0)
ffffffffc0204d26:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d2a:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204d2e:	8522                	mv	a0,s0
ffffffffc0204d30:	60a2                	ld	ra,8(sp)
ffffffffc0204d32:	6402                	ld	s0,0(sp)
ffffffffc0204d34:	0141                	addi	sp,sp,16
ffffffffc0204d36:	8082                	ret

ffffffffc0204d38 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d38:	000a8797          	auipc	a5,0xa8
ffffffffc0204d3c:	b1078793          	addi	a5,a5,-1264 # ffffffffc02ac848 <current>
ffffffffc0204d40:	639c                	ld	a5,0(a5)
ffffffffc0204d42:	73c8                	ld	a0,160(a5)
ffffffffc0204d44:	84efc06f          	j	ffffffffc0200d92 <forkrets>

ffffffffc0204d48 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d48:	000a8797          	auipc	a5,0xa8
ffffffffc0204d4c:	b0078793          	addi	a5,a5,-1280 # ffffffffc02ac848 <current>
ffffffffc0204d50:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d52:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d54:	00004617          	auipc	a2,0x4
ffffffffc0204d58:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0208770 <default_pmm_manager+0x668>
ffffffffc0204d5c:	43cc                	lw	a1,4(a5)
ffffffffc0204d5e:	00004517          	auipc	a0,0x4
ffffffffc0204d62:	a2250513          	addi	a0,a0,-1502 # ffffffffc0208780 <default_pmm_manager+0x678>
user_main(void *arg) {
ffffffffc0204d66:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d68:	b68fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204d6c:	00004797          	auipc	a5,0x4
ffffffffc0204d70:	a0478793          	addi	a5,a5,-1532 # ffffffffc0208770 <default_pmm_manager+0x668>
ffffffffc0204d74:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d78:	5a470713          	addi	a4,a4,1444 # a318 <_binary_obj___user_forktest_out_size>
ffffffffc0204d7c:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d7e:	853e                	mv	a0,a5
ffffffffc0204d80:	00092717          	auipc	a4,0x92
ffffffffc0204d84:	31070713          	addi	a4,a4,784 # ffffffffc0297090 <_binary_obj___user_forktest_out_start>
ffffffffc0204d88:	f03a                	sd	a4,32(sp)
ffffffffc0204d8a:	f43e                	sd	a5,40(sp)
ffffffffc0204d8c:	e802                	sd	zero,16(sp)
ffffffffc0204d8e:	36e010ef          	jal	ra,ffffffffc02060fc <strlen>
ffffffffc0204d92:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d94:	4511                	li	a0,4
ffffffffc0204d96:	55a2                	lw	a1,40(sp)
ffffffffc0204d98:	4662                	lw	a2,24(sp)
ffffffffc0204d9a:	5682                	lw	a3,32(sp)
ffffffffc0204d9c:	4722                	lw	a4,8(sp)
ffffffffc0204d9e:	48a9                	li	a7,10
ffffffffc0204da0:	9002                	ebreak
ffffffffc0204da2:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204da4:	65c2                	ld	a1,16(sp)
ffffffffc0204da6:	00004517          	auipc	a0,0x4
ffffffffc0204daa:	a0250513          	addi	a0,a0,-1534 # ffffffffc02087a8 <default_pmm_manager+0x6a0>
ffffffffc0204dae:	b22fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204db2:	00004617          	auipc	a2,0x4
ffffffffc0204db6:	a0660613          	addi	a2,a2,-1530 # ffffffffc02087b8 <default_pmm_manager+0x6b0>
ffffffffc0204dba:	34900593          	li	a1,841
ffffffffc0204dbe:	00004517          	auipc	a0,0x4
ffffffffc0204dc2:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0204dc6:	c4efb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204dca <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dca:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dcc:	1141                	addi	sp,sp,-16
ffffffffc0204dce:	e406                	sd	ra,8(sp)
ffffffffc0204dd0:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dd4:	04f6e263          	bltu	a3,a5,ffffffffc0204e18 <put_pgdir+0x4e>
ffffffffc0204dd8:	000a8797          	auipc	a5,0xa8
ffffffffc0204ddc:	aa078793          	addi	a5,a5,-1376 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0204de0:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204de2:	000a8797          	auipc	a5,0xa8
ffffffffc0204de6:	a3e78793          	addi	a5,a5,-1474 # ffffffffc02ac820 <npage>
ffffffffc0204dea:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204dec:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204dee:	82b1                	srli	a3,a3,0xc
ffffffffc0204df0:	04f6f063          	bgeu	a3,a5,ffffffffc0204e30 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204df4:	00004797          	auipc	a5,0x4
ffffffffc0204df8:	eac78793          	addi	a5,a5,-340 # ffffffffc0208ca0 <nbase>
ffffffffc0204dfc:	639c                	ld	a5,0(a5)
ffffffffc0204dfe:	000a8717          	auipc	a4,0xa8
ffffffffc0204e02:	a8a70713          	addi	a4,a4,-1398 # ffffffffc02ac888 <pages>
ffffffffc0204e06:	6308                	ld	a0,0(a4)
}
ffffffffc0204e08:	60a2                	ld	ra,8(sp)
ffffffffc0204e0a:	8e9d                	sub	a3,a3,a5
ffffffffc0204e0c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e0e:	4585                	li	a1,1
ffffffffc0204e10:	9536                	add	a0,a0,a3
}
ffffffffc0204e12:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e14:	8cefc06f          	j	ffffffffc0200ee2 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e18:	00002617          	auipc	a2,0x2
ffffffffc0204e1c:	26060613          	addi	a2,a2,608 # ffffffffc0207078 <commands+0x940>
ffffffffc0204e20:	06e00593          	li	a1,110
ffffffffc0204e24:	00002517          	auipc	a0,0x2
ffffffffc0204e28:	1d450513          	addi	a0,a0,468 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0204e2c:	be8fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e30:	00002617          	auipc	a2,0x2
ffffffffc0204e34:	1a860613          	addi	a2,a2,424 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc0204e38:	06200593          	li	a1,98
ffffffffc0204e3c:	00002517          	auipc	a0,0x2
ffffffffc0204e40:	1bc50513          	addi	a0,a0,444 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0204e44:	bd0fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204e48 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e48:	1101                	addi	sp,sp,-32
ffffffffc0204e4a:	e426                	sd	s1,8(sp)
ffffffffc0204e4c:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e4e:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e50:	ec06                	sd	ra,24(sp)
ffffffffc0204e52:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e54:	806fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204e58:	c125                	beqz	a0,ffffffffc0204eb8 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e5a:	000a8797          	auipc	a5,0xa8
ffffffffc0204e5e:	a2e78793          	addi	a5,a5,-1490 # ffffffffc02ac888 <pages>
ffffffffc0204e62:	6394                	ld	a3,0(a5)
ffffffffc0204e64:	00004797          	auipc	a5,0x4
ffffffffc0204e68:	e3c78793          	addi	a5,a5,-452 # ffffffffc0208ca0 <nbase>
ffffffffc0204e6c:	6380                	ld	s0,0(a5)
ffffffffc0204e6e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e72:	000a8797          	auipc	a5,0xa8
ffffffffc0204e76:	9ae78793          	addi	a5,a5,-1618 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc0204e7a:	8699                	srai	a3,a3,0x6
ffffffffc0204e7c:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e7e:	6398                	ld	a4,0(a5)
ffffffffc0204e80:	00c69793          	slli	a5,a3,0xc
ffffffffc0204e84:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e88:	02e7fa63          	bgeu	a5,a4,ffffffffc0204ebc <setup_pgdir+0x74>
ffffffffc0204e8c:	000a8797          	auipc	a5,0xa8
ffffffffc0204e90:	9ec78793          	addi	a5,a5,-1556 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0204e94:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e96:	000a8797          	auipc	a5,0xa8
ffffffffc0204e9a:	98278793          	addi	a5,a5,-1662 # ffffffffc02ac818 <boot_pgdir>
ffffffffc0204e9e:	638c                	ld	a1,0(a5)
ffffffffc0204ea0:	9436                	add	s0,s0,a3
ffffffffc0204ea2:	6605                	lui	a2,0x1
ffffffffc0204ea4:	8522                	mv	a0,s0
ffffffffc0204ea6:	306010ef          	jal	ra,ffffffffc02061ac <memcpy>
    return 0;
ffffffffc0204eaa:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204eac:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eae:	60e2                	ld	ra,24(sp)
ffffffffc0204eb0:	6442                	ld	s0,16(sp)
ffffffffc0204eb2:	64a2                	ld	s1,8(sp)
ffffffffc0204eb4:	6105                	addi	sp,sp,32
ffffffffc0204eb6:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204eb8:	5571                	li	a0,-4
ffffffffc0204eba:	bfd5                	j	ffffffffc0204eae <setup_pgdir+0x66>
ffffffffc0204ebc:	00002617          	auipc	a2,0x2
ffffffffc0204ec0:	0e460613          	addi	a2,a2,228 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0204ec4:	06900593          	li	a1,105
ffffffffc0204ec8:	00002517          	auipc	a0,0x2
ffffffffc0204ecc:	13050513          	addi	a0,a0,304 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0204ed0:	b44fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204ed4 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ed4:	1101                	addi	sp,sp,-32
ffffffffc0204ed6:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ed8:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204edc:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ede:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee0:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee2:	8522                	mv	a0,s0
ffffffffc0204ee4:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee6:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee8:	2b2010ef          	jal	ra,ffffffffc020619a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204eec:	8522                	mv	a0,s0
}
ffffffffc0204eee:	6442                	ld	s0,16(sp)
ffffffffc0204ef0:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef2:	85a6                	mv	a1,s1
}
ffffffffc0204ef4:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef6:	463d                	li	a2,15
}
ffffffffc0204ef8:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204efa:	2b20106f          	j	ffffffffc02061ac <memcpy>

ffffffffc0204efe <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204efe:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f00:	000a8797          	auipc	a5,0xa8
ffffffffc0204f04:	94878793          	addi	a5,a5,-1720 # ffffffffc02ac848 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f08:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f0a:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f0c:	ec06                	sd	ra,24(sp)
ffffffffc0204f0e:	e822                	sd	s0,16(sp)
ffffffffc0204f10:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f12:	02a48b63          	beq	s1,a0,ffffffffc0204f48 <proc_run+0x4a>
ffffffffc0204f16:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f18:	100027f3          	csrr	a5,sstatus
ffffffffc0204f1c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f1e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f20:	e3a9                	bnez	a5,ffffffffc0204f62 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f22:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204f24:	000a8717          	auipc	a4,0xa8
ffffffffc0204f28:	92873223          	sd	s0,-1756(a4) # ffffffffc02ac848 <current>
ffffffffc0204f2c:	577d                	li	a4,-1
ffffffffc0204f2e:	177e                	slli	a4,a4,0x3f
ffffffffc0204f30:	83b1                	srli	a5,a5,0xc
ffffffffc0204f32:	8fd9                	or	a5,a5,a4
ffffffffc0204f34:	18079073          	csrw	satp,a5
            switch_to(&(temp->context),&(proc->context));            
ffffffffc0204f38:	03040593          	addi	a1,s0,48
ffffffffc0204f3c:	03048513          	addi	a0,s1,48
ffffffffc0204f40:	d1bff0ef          	jal	ra,ffffffffc0204c5a <switch_to>
    if (flag) {
ffffffffc0204f44:	00091863          	bnez	s2,ffffffffc0204f54 <proc_run+0x56>
}
ffffffffc0204f48:	60e2                	ld	ra,24(sp)
ffffffffc0204f4a:	6442                	ld	s0,16(sp)
ffffffffc0204f4c:	64a2                	ld	s1,8(sp)
ffffffffc0204f4e:	6902                	ld	s2,0(sp)
ffffffffc0204f50:	6105                	addi	sp,sp,32
ffffffffc0204f52:	8082                	ret
ffffffffc0204f54:	6442                	ld	s0,16(sp)
ffffffffc0204f56:	60e2                	ld	ra,24(sp)
ffffffffc0204f58:	64a2                	ld	s1,8(sp)
ffffffffc0204f5a:	6902                	ld	s2,0(sp)
ffffffffc0204f5c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f5e:	ef0fb06f          	j	ffffffffc020064e <intr_enable>
        intr_disable();
ffffffffc0204f62:	ef2fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0204f66:	4905                	li	s2,1
ffffffffc0204f68:	bf6d                	j	ffffffffc0204f22 <proc_run+0x24>

ffffffffc0204f6a <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f6a:	0005071b          	sext.w	a4,a0
ffffffffc0204f6e:	6789                	lui	a5,0x2
ffffffffc0204f70:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f74:	17f9                	addi	a5,a5,-2
ffffffffc0204f76:	04d7e063          	bltu	a5,a3,ffffffffc0204fb6 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f7a:	1141                	addi	sp,sp,-16
ffffffffc0204f7c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f7e:	45a9                	li	a1,10
ffffffffc0204f80:	842a                	mv	s0,a0
ffffffffc0204f82:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f84:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f86:	62a010ef          	jal	ra,ffffffffc02065b0 <hash32>
ffffffffc0204f8a:	02051693          	slli	a3,a0,0x20
ffffffffc0204f8e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f90:	000a4517          	auipc	a0,0xa4
ffffffffc0204f94:	87850513          	addi	a0,a0,-1928 # ffffffffc02a8808 <hash_list>
ffffffffc0204f98:	96aa                	add	a3,a3,a0
ffffffffc0204f9a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204f9c:	a029                	j	ffffffffc0204fa6 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204f9e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc0204fa2:	00870c63          	beq	a4,s0,ffffffffc0204fba <find_proc+0x50>
    return listelm->next;
ffffffffc0204fa6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fa8:	fef69be3          	bne	a3,a5,ffffffffc0204f9e <find_proc+0x34>
}
ffffffffc0204fac:	60a2                	ld	ra,8(sp)
ffffffffc0204fae:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fb0:	4501                	li	a0,0
}
ffffffffc0204fb2:	0141                	addi	sp,sp,16
ffffffffc0204fb4:	8082                	ret
    return NULL;
ffffffffc0204fb6:	4501                	li	a0,0
}
ffffffffc0204fb8:	8082                	ret
ffffffffc0204fba:	60a2                	ld	ra,8(sp)
ffffffffc0204fbc:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fbe:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fc2:	0141                	addi	sp,sp,16
ffffffffc0204fc4:	8082                	ret

ffffffffc0204fc6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fc6:	7159                	addi	sp,sp,-112
ffffffffc0204fc8:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fca:	000a8a17          	auipc	s4,0xa8
ffffffffc0204fce:	896a0a13          	addi	s4,s4,-1898 # ffffffffc02ac860 <nr_process>
ffffffffc0204fd2:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fd6:	f486                	sd	ra,104(sp)
ffffffffc0204fd8:	f0a2                	sd	s0,96(sp)
ffffffffc0204fda:	eca6                	sd	s1,88(sp)
ffffffffc0204fdc:	e8ca                	sd	s2,80(sp)
ffffffffc0204fde:	e4ce                	sd	s3,72(sp)
ffffffffc0204fe0:	fc56                	sd	s5,56(sp)
ffffffffc0204fe2:	f85a                	sd	s6,48(sp)
ffffffffc0204fe4:	f45e                	sd	s7,40(sp)
ffffffffc0204fe6:	f062                	sd	s8,32(sp)
ffffffffc0204fe8:	ec66                	sd	s9,24(sp)
ffffffffc0204fea:	e86a                	sd	s10,16(sp)
ffffffffc0204fec:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fee:	6785                	lui	a5,0x1
ffffffffc0204ff0:	30f75a63          	bge	a4,a5,ffffffffc0205304 <do_fork+0x33e>
ffffffffc0204ff4:	89aa                	mv	s3,a0
ffffffffc0204ff6:	892e                	mv	s2,a1
ffffffffc0204ff8:	84b2                	mv	s1,a2
    proc = alloc_proc();
ffffffffc0204ffa:	ccbff0ef          	jal	ra,ffffffffc0204cc4 <alloc_proc>
ffffffffc0204ffe:	842a                	mv	s0,a0
    if(proc == NULL){
ffffffffc0205000:	2e050463          	beqz	a0,ffffffffc02052e8 <do_fork+0x322>
    proc->parent = current;
ffffffffc0205004:	000a8c17          	auipc	s8,0xa8
ffffffffc0205008:	844c0c13          	addi	s8,s8,-1980 # ffffffffc02ac848 <current>
ffffffffc020500c:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0205010:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84dc>
    proc->parent = current;
ffffffffc0205014:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205016:	30071563          	bnez	a4,ffffffffc0205320 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020501a:	4509                	li	a0,2
ffffffffc020501c:	e3ffb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
    if (page != NULL) {
ffffffffc0205020:	2c050163          	beqz	a0,ffffffffc02052e2 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205024:	000a8a97          	auipc	s5,0xa8
ffffffffc0205028:	864a8a93          	addi	s5,s5,-1948 # ffffffffc02ac888 <pages>
ffffffffc020502c:	000ab683          	ld	a3,0(s5)
ffffffffc0205030:	00004b17          	auipc	s6,0x4
ffffffffc0205034:	c70b0b13          	addi	s6,s6,-912 # ffffffffc0208ca0 <nbase>
ffffffffc0205038:	000b3783          	ld	a5,0(s6)
ffffffffc020503c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205040:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205042:	000a7b97          	auipc	s7,0xa7
ffffffffc0205046:	7deb8b93          	addi	s7,s7,2014 # ffffffffc02ac820 <npage>
    return page - pages + nbase;
ffffffffc020504a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020504c:	000bb703          	ld	a4,0(s7)
ffffffffc0205050:	00c69793          	slli	a5,a3,0xc
ffffffffc0205054:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205056:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205058:	2ae7f863          	bgeu	a5,a4,ffffffffc0205308 <do_fork+0x342>
ffffffffc020505c:	000a8c97          	auipc	s9,0xa8
ffffffffc0205060:	81cc8c93          	addi	s9,s9,-2020 # ffffffffc02ac878 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205064:	000c3703          	ld	a4,0(s8)
ffffffffc0205068:	000cb783          	ld	a5,0(s9)
ffffffffc020506c:	02873c03          	ld	s8,40(a4)
ffffffffc0205070:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205072:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205074:	020c0863          	beqz	s8,ffffffffc02050a4 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205078:	1009f993          	andi	s3,s3,256
ffffffffc020507c:	1e098163          	beqz	s3,ffffffffc020525e <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205080:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205084:	018c3783          	ld	a5,24(s8)
ffffffffc0205088:	c02006b7          	lui	a3,0xc0200
ffffffffc020508c:	2705                	addiw	a4,a4,1
ffffffffc020508e:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205092:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205096:	2ad7e563          	bltu	a5,a3,ffffffffc0205340 <do_fork+0x37a>
ffffffffc020509a:	000cb703          	ld	a4,0(s9)
ffffffffc020509e:	6814                	ld	a3,16(s0)
ffffffffc02050a0:	8f99                	sub	a5,a5,a4
ffffffffc02050a2:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050a4:	6789                	lui	a5,0x2
ffffffffc02050a6:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>
ffffffffc02050aa:	96be                	add	a3,a3,a5
ffffffffc02050ac:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050ae:	87b6                	mv	a5,a3
ffffffffc02050b0:	12048813          	addi	a6,s1,288
ffffffffc02050b4:	6088                	ld	a0,0(s1)
ffffffffc02050b6:	648c                	ld	a1,8(s1)
ffffffffc02050b8:	6890                	ld	a2,16(s1)
ffffffffc02050ba:	6c98                	ld	a4,24(s1)
ffffffffc02050bc:	e388                	sd	a0,0(a5)
ffffffffc02050be:	e78c                	sd	a1,8(a5)
ffffffffc02050c0:	eb90                	sd	a2,16(a5)
ffffffffc02050c2:	ef98                	sd	a4,24(a5)
ffffffffc02050c4:	02048493          	addi	s1,s1,32
ffffffffc02050c8:	02078793          	addi	a5,a5,32
ffffffffc02050cc:	ff0494e3          	bne	s1,a6,ffffffffc02050b4 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050d0:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050d4:	12090e63          	beqz	s2,ffffffffc0205210 <do_fork+0x24a>
ffffffffc02050d8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050dc:	00000797          	auipc	a5,0x0
ffffffffc02050e0:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d38 <forkret>
ffffffffc02050e4:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050e6:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050e8:	100027f3          	csrr	a5,sstatus
ffffffffc02050ec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050ee:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050f0:	12079f63          	bnez	a5,ffffffffc020522e <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050f4:	0009c797          	auipc	a5,0x9c
ffffffffc02050f8:	30c78793          	addi	a5,a5,780 # ffffffffc02a1400 <last_pid.1691>
ffffffffc02050fc:	439c                	lw	a5,0(a5)
ffffffffc02050fe:	6709                	lui	a4,0x2
ffffffffc0205100:	0017851b          	addiw	a0,a5,1
ffffffffc0205104:	0009c697          	auipc	a3,0x9c
ffffffffc0205108:	2ea6ae23          	sw	a0,764(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020510c:	14e55263          	bge	a0,a4,ffffffffc0205250 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0205110:	0009c797          	auipc	a5,0x9c
ffffffffc0205114:	2f478793          	addi	a5,a5,756 # ffffffffc02a1404 <next_safe.1690>
ffffffffc0205118:	439c                	lw	a5,0(a5)
ffffffffc020511a:	000a8497          	auipc	s1,0xa8
ffffffffc020511e:	86e48493          	addi	s1,s1,-1938 # ffffffffc02ac988 <proc_list>
ffffffffc0205122:	06f54063          	blt	a0,a5,ffffffffc0205182 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205126:	6789                	lui	a5,0x2
ffffffffc0205128:	0009c717          	auipc	a4,0x9c
ffffffffc020512c:	2cf72e23          	sw	a5,732(a4) # ffffffffc02a1404 <next_safe.1690>
ffffffffc0205130:	4581                	li	a1,0
ffffffffc0205132:	87aa                	mv	a5,a0
ffffffffc0205134:	000a8497          	auipc	s1,0xa8
ffffffffc0205138:	85448493          	addi	s1,s1,-1964 # ffffffffc02ac988 <proc_list>
    repeat:
ffffffffc020513c:	6889                	lui	a7,0x2
ffffffffc020513e:	882e                	mv	a6,a1
ffffffffc0205140:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205142:	000a8697          	auipc	a3,0xa8
ffffffffc0205146:	84668693          	addi	a3,a3,-1978 # ffffffffc02ac988 <proc_list>
ffffffffc020514a:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020514c:	00968f63          	beq	a3,s1,ffffffffc020516a <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0205150:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205154:	0ae78963          	beq	a5,a4,ffffffffc0205206 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205158:	fee7d9e3          	bge	a5,a4,ffffffffc020514a <do_fork+0x184>
ffffffffc020515c:	fec757e3          	bge	a4,a2,ffffffffc020514a <do_fork+0x184>
ffffffffc0205160:	6694                	ld	a3,8(a3)
ffffffffc0205162:	863a                	mv	a2,a4
ffffffffc0205164:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205166:	fe9695e3          	bne	a3,s1,ffffffffc0205150 <do_fork+0x18a>
ffffffffc020516a:	c591                	beqz	a1,ffffffffc0205176 <do_fork+0x1b0>
ffffffffc020516c:	0009c717          	auipc	a4,0x9c
ffffffffc0205170:	28f72a23          	sw	a5,660(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc0205174:	853e                	mv	a0,a5
ffffffffc0205176:	00080663          	beqz	a6,ffffffffc0205182 <do_fork+0x1bc>
ffffffffc020517a:	0009c797          	auipc	a5,0x9c
ffffffffc020517e:	28c7a523          	sw	a2,650(a5) # ffffffffc02a1404 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc0205182:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205184:	45a9                	li	a1,10
ffffffffc0205186:	2501                	sext.w	a0,a0
ffffffffc0205188:	428010ef          	jal	ra,ffffffffc02065b0 <hash32>
ffffffffc020518c:	1502                	slli	a0,a0,0x20
ffffffffc020518e:	000a3797          	auipc	a5,0xa3
ffffffffc0205192:	67a78793          	addi	a5,a5,1658 # ffffffffc02a8808 <hash_list>
ffffffffc0205196:	8171                	srli	a0,a0,0x1c
ffffffffc0205198:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020519a:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020519c:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020519e:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051a2:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051a4:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02051a6:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051a8:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051aa:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02051ae:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051b0:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051b2:	e21c                	sd	a5,0(a2)
ffffffffc02051b4:	000a7597          	auipc	a1,0xa7
ffffffffc02051b8:	7cf5be23          	sd	a5,2012(a1) # ffffffffc02ac990 <proc_list+0x8>
    elm->next = next;
ffffffffc02051bc:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051be:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051c0:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051c4:	10e43023          	sd	a4,256(s0)
ffffffffc02051c8:	c311                	beqz	a4,ffffffffc02051cc <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051ca:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051cc:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051d0:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051d2:	2785                	addiw	a5,a5,1
ffffffffc02051d4:	000a7717          	auipc	a4,0xa7
ffffffffc02051d8:	68f72623          	sw	a5,1676(a4) # ffffffffc02ac860 <nr_process>
    if (flag) {
ffffffffc02051dc:	10091863          	bnez	s2,ffffffffc02052ec <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02051e0:	8522                	mv	a0,s0
ffffffffc02051e2:	529000ef          	jal	ra,ffffffffc0205f0a <wakeup_proc>
    ret = proc->pid;
ffffffffc02051e6:	4048                	lw	a0,4(s0)
}
ffffffffc02051e8:	70a6                	ld	ra,104(sp)
ffffffffc02051ea:	7406                	ld	s0,96(sp)
ffffffffc02051ec:	64e6                	ld	s1,88(sp)
ffffffffc02051ee:	6946                	ld	s2,80(sp)
ffffffffc02051f0:	69a6                	ld	s3,72(sp)
ffffffffc02051f2:	6a06                	ld	s4,64(sp)
ffffffffc02051f4:	7ae2                	ld	s5,56(sp)
ffffffffc02051f6:	7b42                	ld	s6,48(sp)
ffffffffc02051f8:	7ba2                	ld	s7,40(sp)
ffffffffc02051fa:	7c02                	ld	s8,32(sp)
ffffffffc02051fc:	6ce2                	ld	s9,24(sp)
ffffffffc02051fe:	6d42                	ld	s10,16(sp)
ffffffffc0205200:	6da2                	ld	s11,8(sp)
ffffffffc0205202:	6165                	addi	sp,sp,112
ffffffffc0205204:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205206:	2785                	addiw	a5,a5,1
ffffffffc0205208:	0ec7d563          	bge	a5,a2,ffffffffc02052f2 <do_fork+0x32c>
ffffffffc020520c:	4585                	li	a1,1
ffffffffc020520e:	bf35                	j	ffffffffc020514a <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205210:	8936                	mv	s2,a3
ffffffffc0205212:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205216:	00000797          	auipc	a5,0x0
ffffffffc020521a:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d38 <forkret>
ffffffffc020521e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205220:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205222:	100027f3          	csrr	a5,sstatus
ffffffffc0205226:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205228:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020522a:	ec0785e3          	beqz	a5,ffffffffc02050f4 <do_fork+0x12e>
        intr_disable();
ffffffffc020522e:	c26fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205232:	0009c797          	auipc	a5,0x9c
ffffffffc0205236:	1ce78793          	addi	a5,a5,462 # ffffffffc02a1400 <last_pid.1691>
ffffffffc020523a:	439c                	lw	a5,0(a5)
ffffffffc020523c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020523e:	4905                	li	s2,1
ffffffffc0205240:	0017851b          	addiw	a0,a5,1
ffffffffc0205244:	0009c697          	auipc	a3,0x9c
ffffffffc0205248:	1aa6ae23          	sw	a0,444(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020524c:	ece542e3          	blt	a0,a4,ffffffffc0205110 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205250:	4785                	li	a5,1
ffffffffc0205252:	0009c717          	auipc	a4,0x9c
ffffffffc0205256:	1af72723          	sw	a5,430(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020525a:	4505                	li	a0,1
ffffffffc020525c:	b5e9                	j	ffffffffc0205126 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc020525e:	94cfd0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc0205262:	8d2a                	mv	s10,a0
ffffffffc0205264:	c539                	beqz	a0,ffffffffc02052b2 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205266:	be3ff0ef          	jal	ra,ffffffffc0204e48 <setup_pgdir>
ffffffffc020526a:	e949                	bnez	a0,ffffffffc02052fc <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020526c:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205270:	4785                	li	a5,1
ffffffffc0205272:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205276:	8b85                	andi	a5,a5,1
ffffffffc0205278:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020527a:	c799                	beqz	a5,ffffffffc0205288 <do_fork+0x2c2>
        schedule();
ffffffffc020527c:	50b000ef          	jal	ra,ffffffffc0205f86 <schedule>
ffffffffc0205280:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205284:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205286:	fbfd                	bnez	a5,ffffffffc020527c <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205288:	85e2                	mv	a1,s8
ffffffffc020528a:	856a                	mv	a0,s10
ffffffffc020528c:	ba8fd0ef          	jal	ra,ffffffffc0202634 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205290:	57f9                	li	a5,-2
ffffffffc0205292:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205296:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205298:	c3e9                	beqz	a5,ffffffffc020535a <do_fork+0x394>
    if (ret != 0) {
ffffffffc020529a:	8c6a                	mv	s8,s10
ffffffffc020529c:	de0502e3          	beqz	a0,ffffffffc0205080 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02052a0:	856a                	mv	a0,s10
ffffffffc02052a2:	c2efd0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
    put_pgdir(mm);
ffffffffc02052a6:	856a                	mv	a0,s10
ffffffffc02052a8:	b23ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
    mm_destroy(mm);
ffffffffc02052ac:	856a                	mv	a0,s10
ffffffffc02052ae:	a82fd0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052b2:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052b4:	c02007b7          	lui	a5,0xc0200
ffffffffc02052b8:	0cf6e963          	bltu	a3,a5,ffffffffc020538a <do_fork+0x3c4>
ffffffffc02052bc:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052c0:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052c4:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052c8:	83b1                	srli	a5,a5,0xc
ffffffffc02052ca:	0ae7f463          	bgeu	a5,a4,ffffffffc0205372 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052ce:	000b3703          	ld	a4,0(s6)
ffffffffc02052d2:	000ab503          	ld	a0,0(s5)
ffffffffc02052d6:	4589                	li	a1,2
ffffffffc02052d8:	8f99                	sub	a5,a5,a4
ffffffffc02052da:	079a                	slli	a5,a5,0x6
ffffffffc02052dc:	953e                	add	a0,a0,a5
ffffffffc02052de:	c05fb0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    kfree(proc);
ffffffffc02052e2:	8522                	mv	a0,s0
ffffffffc02052e4:	e7ffd0ef          	jal	ra,ffffffffc0203162 <kfree>
    ret = -E_NO_MEM;
ffffffffc02052e8:	5571                	li	a0,-4
    return ret;
ffffffffc02052ea:	bdfd                	j	ffffffffc02051e8 <do_fork+0x222>
        intr_enable();
ffffffffc02052ec:	b62fb0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc02052f0:	bdc5                	j	ffffffffc02051e0 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02052f2:	0117c363          	blt	a5,a7,ffffffffc02052f8 <do_fork+0x332>
                        last_pid = 1;
ffffffffc02052f6:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052f8:	4585                	li	a1,1
ffffffffc02052fa:	b591                	j	ffffffffc020513e <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02052fc:	856a                	mv	a0,s10
ffffffffc02052fe:	a32fd0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
ffffffffc0205302:	bf45                	j	ffffffffc02052b2 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205304:	556d                	li	a0,-5
ffffffffc0205306:	b5cd                	j	ffffffffc02051e8 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205308:	00002617          	auipc	a2,0x2
ffffffffc020530c:	c9860613          	addi	a2,a2,-872 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0205310:	06900593          	li	a1,105
ffffffffc0205314:	00002517          	auipc	a0,0x2
ffffffffc0205318:	ce450513          	addi	a0,a0,-796 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc020531c:	ef9fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205320:	00003697          	auipc	a3,0x3
ffffffffc0205324:	22868693          	addi	a3,a3,552 # ffffffffc0208548 <default_pmm_manager+0x440>
ffffffffc0205328:	00002617          	auipc	a2,0x2
ffffffffc020532c:	89060613          	addi	a2,a2,-1904 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205330:	1b000593          	li	a1,432
ffffffffc0205334:	00003517          	auipc	a0,0x3
ffffffffc0205338:	4a450513          	addi	a0,a0,1188 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc020533c:	ed9fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205340:	86be                	mv	a3,a5
ffffffffc0205342:	00002617          	auipc	a2,0x2
ffffffffc0205346:	d3660613          	addi	a2,a2,-714 # ffffffffc0207078 <commands+0x940>
ffffffffc020534a:	16200593          	li	a1,354
ffffffffc020534e:	00003517          	auipc	a0,0x3
ffffffffc0205352:	48a50513          	addi	a0,a0,1162 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205356:	ebffa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("Unlock failed.\n");
ffffffffc020535a:	00003617          	auipc	a2,0x3
ffffffffc020535e:	20e60613          	addi	a2,a2,526 # ffffffffc0208568 <default_pmm_manager+0x460>
ffffffffc0205362:	03100593          	li	a1,49
ffffffffc0205366:	00003517          	auipc	a0,0x3
ffffffffc020536a:	21250513          	addi	a0,a0,530 # ffffffffc0208578 <default_pmm_manager+0x470>
ffffffffc020536e:	ea7fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205372:	00002617          	auipc	a2,0x2
ffffffffc0205376:	c6660613          	addi	a2,a2,-922 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc020537a:	06200593          	li	a1,98
ffffffffc020537e:	00002517          	auipc	a0,0x2
ffffffffc0205382:	c7a50513          	addi	a0,a0,-902 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0205386:	e8ffa0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020538a:	00002617          	auipc	a2,0x2
ffffffffc020538e:	cee60613          	addi	a2,a2,-786 # ffffffffc0207078 <commands+0x940>
ffffffffc0205392:	06e00593          	li	a1,110
ffffffffc0205396:	00002517          	auipc	a0,0x2
ffffffffc020539a:	c6250513          	addi	a0,a0,-926 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc020539e:	e77fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02053a2 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053a2:	7129                	addi	sp,sp,-320
ffffffffc02053a4:	fa22                	sd	s0,304(sp)
ffffffffc02053a6:	f626                	sd	s1,296(sp)
ffffffffc02053a8:	f24a                	sd	s2,288(sp)
ffffffffc02053aa:	84ae                	mv	s1,a1
ffffffffc02053ac:	892a                	mv	s2,a0
ffffffffc02053ae:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053b0:	4581                	li	a1,0
ffffffffc02053b2:	12000613          	li	a2,288
ffffffffc02053b6:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053b8:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053ba:	5e1000ef          	jal	ra,ffffffffc020619a <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053be:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053c0:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053c2:	100027f3          	csrr	a5,sstatus
ffffffffc02053c6:	edd7f793          	andi	a5,a5,-291
ffffffffc02053ca:	1207e793          	ori	a5,a5,288
ffffffffc02053ce:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d0:	860a                	mv	a2,sp
ffffffffc02053d2:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053d6:	00000797          	auipc	a5,0x0
ffffffffc02053da:	87c78793          	addi	a5,a5,-1924 # ffffffffc0204c52 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053de:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053e0:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053e2:	be5ff0ef          	jal	ra,ffffffffc0204fc6 <do_fork>
}
ffffffffc02053e6:	70f2                	ld	ra,312(sp)
ffffffffc02053e8:	7452                	ld	s0,304(sp)
ffffffffc02053ea:	74b2                	ld	s1,296(sp)
ffffffffc02053ec:	7912                	ld	s2,288(sp)
ffffffffc02053ee:	6131                	addi	sp,sp,320
ffffffffc02053f0:	8082                	ret

ffffffffc02053f2 <do_exit>:
do_exit(int error_code) {
ffffffffc02053f2:	7179                	addi	sp,sp,-48
ffffffffc02053f4:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02053f6:	000a7717          	auipc	a4,0xa7
ffffffffc02053fa:	45a70713          	addi	a4,a4,1114 # ffffffffc02ac850 <idleproc>
ffffffffc02053fe:	000a7917          	auipc	s2,0xa7
ffffffffc0205402:	44a90913          	addi	s2,s2,1098 # ffffffffc02ac848 <current>
ffffffffc0205406:	00093783          	ld	a5,0(s2)
ffffffffc020540a:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc020540c:	f406                	sd	ra,40(sp)
ffffffffc020540e:	f022                	sd	s0,32(sp)
ffffffffc0205410:	ec26                	sd	s1,24(sp)
ffffffffc0205412:	e44e                	sd	s3,8(sp)
ffffffffc0205414:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205416:	0ce78c63          	beq	a5,a4,ffffffffc02054ee <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020541a:	000a7417          	auipc	s0,0xa7
ffffffffc020541e:	43e40413          	addi	s0,s0,1086 # ffffffffc02ac858 <initproc>
ffffffffc0205422:	6018                	ld	a4,0(s0)
ffffffffc0205424:	0ee78b63          	beq	a5,a4,ffffffffc020551a <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205428:	7784                	ld	s1,40(a5)
ffffffffc020542a:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc020542c:	c48d                	beqz	s1,ffffffffc0205456 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc020542e:	000a7797          	auipc	a5,0xa7
ffffffffc0205432:	45278793          	addi	a5,a5,1106 # ffffffffc02ac880 <boot_cr3>
ffffffffc0205436:	639c                	ld	a5,0(a5)
ffffffffc0205438:	577d                	li	a4,-1
ffffffffc020543a:	177e                	slli	a4,a4,0x3f
ffffffffc020543c:	83b1                	srli	a5,a5,0xc
ffffffffc020543e:	8fd9                	or	a5,a5,a4
ffffffffc0205440:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205444:	589c                	lw	a5,48(s1)
ffffffffc0205446:	fff7871b          	addiw	a4,a5,-1
ffffffffc020544a:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc020544c:	cf4d                	beqz	a4,ffffffffc0205506 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020544e:	00093783          	ld	a5,0(s2)
ffffffffc0205452:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205456:	00093783          	ld	a5,0(s2)
ffffffffc020545a:	470d                	li	a4,3
ffffffffc020545c:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020545e:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205462:	100027f3          	csrr	a5,sstatus
ffffffffc0205466:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205468:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020546a:	e7e1                	bnez	a5,ffffffffc0205532 <do_exit+0x140>
        proc = current->parent;
ffffffffc020546c:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205470:	800007b7          	lui	a5,0x80000
ffffffffc0205474:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205476:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205478:	0ec52703          	lw	a4,236(a0)
ffffffffc020547c:	0af70f63          	beq	a4,a5,ffffffffc020553a <do_exit+0x148>
ffffffffc0205480:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205484:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205488:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020548a:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc020548c:	7afc                	ld	a5,240(a3)
ffffffffc020548e:	cb95                	beqz	a5,ffffffffc02054c2 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205490:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5638>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205494:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205496:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205498:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020549a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020549e:	10e7b023          	sd	a4,256(a5)
ffffffffc02054a2:	c311                	beqz	a4,ffffffffc02054a6 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054a4:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054a6:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054a8:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054aa:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054ac:	fe9710e3          	bne	a4,s1,ffffffffc020548c <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054b0:	0ec52783          	lw	a5,236(a0)
ffffffffc02054b4:	fd379ce3          	bne	a5,s3,ffffffffc020548c <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054b8:	253000ef          	jal	ra,ffffffffc0205f0a <wakeup_proc>
ffffffffc02054bc:	00093683          	ld	a3,0(s2)
ffffffffc02054c0:	b7f1                	j	ffffffffc020548c <do_exit+0x9a>
    if (flag) {
ffffffffc02054c2:	020a1363          	bnez	s4,ffffffffc02054e8 <do_exit+0xf6>
    schedule();
ffffffffc02054c6:	2c1000ef          	jal	ra,ffffffffc0205f86 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054ca:	00093783          	ld	a5,0(s2)
ffffffffc02054ce:	00003617          	auipc	a2,0x3
ffffffffc02054d2:	05a60613          	addi	a2,a2,90 # ffffffffc0208528 <default_pmm_manager+0x420>
ffffffffc02054d6:	20000593          	li	a1,512
ffffffffc02054da:	43d4                	lw	a3,4(a5)
ffffffffc02054dc:	00003517          	auipc	a0,0x3
ffffffffc02054e0:	2fc50513          	addi	a0,a0,764 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc02054e4:	d31fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_enable();
ffffffffc02054e8:	966fb0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc02054ec:	bfe9                	j	ffffffffc02054c6 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054ee:	00003617          	auipc	a2,0x3
ffffffffc02054f2:	01a60613          	addi	a2,a2,26 # ffffffffc0208508 <default_pmm_manager+0x400>
ffffffffc02054f6:	1d400593          	li	a1,468
ffffffffc02054fa:	00003517          	auipc	a0,0x3
ffffffffc02054fe:	2de50513          	addi	a0,a0,734 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205502:	d13fa0ef          	jal	ra,ffffffffc0200214 <__panic>
            exit_mmap(mm);
ffffffffc0205506:	8526                	mv	a0,s1
ffffffffc0205508:	9c8fd0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
            put_pgdir(mm);
ffffffffc020550c:	8526                	mv	a0,s1
ffffffffc020550e:	8bdff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
            mm_destroy(mm);
ffffffffc0205512:	8526                	mv	a0,s1
ffffffffc0205514:	81cfd0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
ffffffffc0205518:	bf1d                	j	ffffffffc020544e <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020551a:	00003617          	auipc	a2,0x3
ffffffffc020551e:	ffe60613          	addi	a2,a2,-2 # ffffffffc0208518 <default_pmm_manager+0x410>
ffffffffc0205522:	1d700593          	li	a1,471
ffffffffc0205526:	00003517          	auipc	a0,0x3
ffffffffc020552a:	2b250513          	addi	a0,a0,690 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc020552e:	ce7fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_disable();
ffffffffc0205532:	922fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0205536:	4a05                	li	s4,1
ffffffffc0205538:	bf15                	j	ffffffffc020546c <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020553a:	1d1000ef          	jal	ra,ffffffffc0205f0a <wakeup_proc>
ffffffffc020553e:	b789                	j	ffffffffc0205480 <do_exit+0x8e>

ffffffffc0205540 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205540:	7139                	addi	sp,sp,-64
ffffffffc0205542:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205544:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205548:	f426                	sd	s1,40(sp)
ffffffffc020554a:	f04a                	sd	s2,32(sp)
ffffffffc020554c:	ec4e                	sd	s3,24(sp)
ffffffffc020554e:	e456                	sd	s5,8(sp)
ffffffffc0205550:	e05a                	sd	s6,0(sp)
ffffffffc0205552:	fc06                	sd	ra,56(sp)
ffffffffc0205554:	f822                	sd	s0,48(sp)
ffffffffc0205556:	89aa                	mv	s3,a0
ffffffffc0205558:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020555a:	000a7917          	auipc	s2,0xa7
ffffffffc020555e:	2ee90913          	addi	s2,s2,750 # ffffffffc02ac848 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205562:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205564:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205566:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc0205568:	02098f63          	beqz	s3,ffffffffc02055a6 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc020556c:	854e                	mv	a0,s3
ffffffffc020556e:	9fdff0ef          	jal	ra,ffffffffc0204f6a <find_proc>
ffffffffc0205572:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205574:	12050063          	beqz	a0,ffffffffc0205694 <do_wait.part.1+0x154>
ffffffffc0205578:	00093703          	ld	a4,0(s2)
ffffffffc020557c:	711c                	ld	a5,32(a0)
ffffffffc020557e:	10e79b63          	bne	a5,a4,ffffffffc0205694 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205582:	411c                	lw	a5,0(a0)
ffffffffc0205584:	02978c63          	beq	a5,s1,ffffffffc02055bc <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205588:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc020558c:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205590:	1f7000ef          	jal	ra,ffffffffc0205f86 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205594:	00093783          	ld	a5,0(s2)
ffffffffc0205598:	0b07a783          	lw	a5,176(a5)
ffffffffc020559c:	8b85                	andi	a5,a5,1
ffffffffc020559e:	d7e9                	beqz	a5,ffffffffc0205568 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055a0:	555d                	li	a0,-9
ffffffffc02055a2:	e51ff0ef          	jal	ra,ffffffffc02053f2 <do_exit>
        proc = current->cptr;
ffffffffc02055a6:	00093703          	ld	a4,0(s2)
ffffffffc02055aa:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055ac:	e409                	bnez	s0,ffffffffc02055b6 <do_wait.part.1+0x76>
ffffffffc02055ae:	a0dd                	j	ffffffffc0205694 <do_wait.part.1+0x154>
ffffffffc02055b0:	10043403          	ld	s0,256(s0)
ffffffffc02055b4:	d871                	beqz	s0,ffffffffc0205588 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055b6:	401c                	lw	a5,0(s0)
ffffffffc02055b8:	fe979ce3          	bne	a5,s1,ffffffffc02055b0 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055bc:	000a7797          	auipc	a5,0xa7
ffffffffc02055c0:	29478793          	addi	a5,a5,660 # ffffffffc02ac850 <idleproc>
ffffffffc02055c4:	639c                	ld	a5,0(a5)
ffffffffc02055c6:	0c878d63          	beq	a5,s0,ffffffffc02056a0 <do_wait.part.1+0x160>
ffffffffc02055ca:	000a7797          	auipc	a5,0xa7
ffffffffc02055ce:	28e78793          	addi	a5,a5,654 # ffffffffc02ac858 <initproc>
ffffffffc02055d2:	639c                	ld	a5,0(a5)
ffffffffc02055d4:	0cf40663          	beq	s0,a5,ffffffffc02056a0 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055d8:	000b0663          	beqz	s6,ffffffffc02055e4 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055dc:	0e842783          	lw	a5,232(s0)
ffffffffc02055e0:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055e4:	100027f3          	csrr	a5,sstatus
ffffffffc02055e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055ea:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055ec:	e7d5                	bnez	a5,ffffffffc0205698 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055ee:	6c70                	ld	a2,216(s0)
ffffffffc02055f0:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055f2:	10043703          	ld	a4,256(s0)
ffffffffc02055f6:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055f8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055fa:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055fc:	6470                	ld	a2,200(s0)
ffffffffc02055fe:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205600:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205602:	e290                	sd	a2,0(a3)
ffffffffc0205604:	c319                	beqz	a4,ffffffffc020560a <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205606:	ff7c                	sd	a5,248(a4)
ffffffffc0205608:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc020560a:	c3d1                	beqz	a5,ffffffffc020568e <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc020560c:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205610:	000a7797          	auipc	a5,0xa7
ffffffffc0205614:	25078793          	addi	a5,a5,592 # ffffffffc02ac860 <nr_process>
ffffffffc0205618:	439c                	lw	a5,0(a5)
ffffffffc020561a:	37fd                	addiw	a5,a5,-1
ffffffffc020561c:	000a7717          	auipc	a4,0xa7
ffffffffc0205620:	24f72223          	sw	a5,580(a4) # ffffffffc02ac860 <nr_process>
    if (flag) {
ffffffffc0205624:	e1b5                	bnez	a1,ffffffffc0205688 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205626:	6814                	ld	a3,16(s0)
ffffffffc0205628:	c02007b7          	lui	a5,0xc0200
ffffffffc020562c:	0af6e263          	bltu	a3,a5,ffffffffc02056d0 <do_wait.part.1+0x190>
ffffffffc0205630:	000a7797          	auipc	a5,0xa7
ffffffffc0205634:	24878793          	addi	a5,a5,584 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205638:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020563a:	000a7797          	auipc	a5,0xa7
ffffffffc020563e:	1e678793          	addi	a5,a5,486 # ffffffffc02ac820 <npage>
ffffffffc0205642:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205644:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205646:	82b1                	srli	a3,a3,0xc
ffffffffc0205648:	06f6f863          	bgeu	a3,a5,ffffffffc02056b8 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020564c:	00003797          	auipc	a5,0x3
ffffffffc0205650:	65478793          	addi	a5,a5,1620 # ffffffffc0208ca0 <nbase>
ffffffffc0205654:	639c                	ld	a5,0(a5)
ffffffffc0205656:	000a7717          	auipc	a4,0xa7
ffffffffc020565a:	23270713          	addi	a4,a4,562 # ffffffffc02ac888 <pages>
ffffffffc020565e:	6308                	ld	a0,0(a4)
ffffffffc0205660:	8e9d                	sub	a3,a3,a5
ffffffffc0205662:	069a                	slli	a3,a3,0x6
ffffffffc0205664:	9536                	add	a0,a0,a3
ffffffffc0205666:	4589                	li	a1,2
ffffffffc0205668:	87bfb0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    kfree(proc);
ffffffffc020566c:	8522                	mv	a0,s0
ffffffffc020566e:	af5fd0ef          	jal	ra,ffffffffc0203162 <kfree>
    return 0;
ffffffffc0205672:	4501                	li	a0,0
}
ffffffffc0205674:	70e2                	ld	ra,56(sp)
ffffffffc0205676:	7442                	ld	s0,48(sp)
ffffffffc0205678:	74a2                	ld	s1,40(sp)
ffffffffc020567a:	7902                	ld	s2,32(sp)
ffffffffc020567c:	69e2                	ld	s3,24(sp)
ffffffffc020567e:	6a42                	ld	s4,16(sp)
ffffffffc0205680:	6aa2                	ld	s5,8(sp)
ffffffffc0205682:	6b02                	ld	s6,0(sp)
ffffffffc0205684:	6121                	addi	sp,sp,64
ffffffffc0205686:	8082                	ret
        intr_enable();
ffffffffc0205688:	fc7fa0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc020568c:	bf69                	j	ffffffffc0205626 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc020568e:	701c                	ld	a5,32(s0)
ffffffffc0205690:	fbf8                	sd	a4,240(a5)
ffffffffc0205692:	bfbd                	j	ffffffffc0205610 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205694:	5579                	li	a0,-2
ffffffffc0205696:	bff9                	j	ffffffffc0205674 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205698:	fbdfa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc020569c:	4585                	li	a1,1
ffffffffc020569e:	bf81                	j	ffffffffc02055ee <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056a0:	00003617          	auipc	a2,0x3
ffffffffc02056a4:	ef060613          	addi	a2,a2,-272 # ffffffffc0208590 <default_pmm_manager+0x488>
ffffffffc02056a8:	2f700593          	li	a1,759
ffffffffc02056ac:	00003517          	auipc	a0,0x3
ffffffffc02056b0:	12c50513          	addi	a0,a0,300 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc02056b4:	b61fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056b8:	00002617          	auipc	a2,0x2
ffffffffc02056bc:	92060613          	addi	a2,a2,-1760 # ffffffffc0206fd8 <commands+0x8a0>
ffffffffc02056c0:	06200593          	li	a1,98
ffffffffc02056c4:	00002517          	auipc	a0,0x2
ffffffffc02056c8:	93450513          	addi	a0,a0,-1740 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02056cc:	b49fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056d0:	00002617          	auipc	a2,0x2
ffffffffc02056d4:	9a860613          	addi	a2,a2,-1624 # ffffffffc0207078 <commands+0x940>
ffffffffc02056d8:	06e00593          	li	a1,110
ffffffffc02056dc:	00002517          	auipc	a0,0x2
ffffffffc02056e0:	91c50513          	addi	a0,a0,-1764 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc02056e4:	b31fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02056e8 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056e8:	1141                	addi	sp,sp,-16
ffffffffc02056ea:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056ec:	83dfb0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056f0:	9b3fd0ef          	jal	ra,ffffffffc02030a2 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056f4:	4601                	li	a2,0
ffffffffc02056f6:	4581                	li	a1,0
ffffffffc02056f8:	fffff517          	auipc	a0,0xfffff
ffffffffc02056fc:	65050513          	addi	a0,a0,1616 # ffffffffc0204d48 <user_main>
ffffffffc0205700:	ca3ff0ef          	jal	ra,ffffffffc02053a2 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205704:	00a04563          	bgtz	a0,ffffffffc020570e <init_main+0x26>
ffffffffc0205708:	a841                	j	ffffffffc0205798 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020570a:	07d000ef          	jal	ra,ffffffffc0205f86 <schedule>
    if (code_store != NULL) {
ffffffffc020570e:	4581                	li	a1,0
ffffffffc0205710:	4501                	li	a0,0
ffffffffc0205712:	e2fff0ef          	jal	ra,ffffffffc0205540 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205716:	d975                	beqz	a0,ffffffffc020570a <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205718:	00003517          	auipc	a0,0x3
ffffffffc020571c:	eb850513          	addi	a0,a0,-328 # ffffffffc02085d0 <default_pmm_manager+0x4c8>
ffffffffc0205720:	9b1fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205724:	000a7797          	auipc	a5,0xa7
ffffffffc0205728:	13478793          	addi	a5,a5,308 # ffffffffc02ac858 <initproc>
ffffffffc020572c:	639c                	ld	a5,0(a5)
ffffffffc020572e:	7bf8                	ld	a4,240(a5)
ffffffffc0205730:	e721                	bnez	a4,ffffffffc0205778 <init_main+0x90>
ffffffffc0205732:	7ff8                	ld	a4,248(a5)
ffffffffc0205734:	e331                	bnez	a4,ffffffffc0205778 <init_main+0x90>
ffffffffc0205736:	1007b703          	ld	a4,256(a5)
ffffffffc020573a:	ef1d                	bnez	a4,ffffffffc0205778 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020573c:	000a7717          	auipc	a4,0xa7
ffffffffc0205740:	12470713          	addi	a4,a4,292 # ffffffffc02ac860 <nr_process>
ffffffffc0205744:	4314                	lw	a3,0(a4)
ffffffffc0205746:	4709                	li	a4,2
ffffffffc0205748:	0ae69463          	bne	a3,a4,ffffffffc02057f0 <init_main+0x108>
    return listelm->next;
ffffffffc020574c:	000a7697          	auipc	a3,0xa7
ffffffffc0205750:	23c68693          	addi	a3,a3,572 # ffffffffc02ac988 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205754:	6698                	ld	a4,8(a3)
ffffffffc0205756:	0c878793          	addi	a5,a5,200
ffffffffc020575a:	06f71b63          	bne	a4,a5,ffffffffc02057d0 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020575e:	629c                	ld	a5,0(a3)
ffffffffc0205760:	04f71863          	bne	a4,a5,ffffffffc02057b0 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205764:	00003517          	auipc	a0,0x3
ffffffffc0205768:	f5450513          	addi	a0,a0,-172 # ffffffffc02086b8 <default_pmm_manager+0x5b0>
ffffffffc020576c:	965fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0205770:	60a2                	ld	ra,8(sp)
ffffffffc0205772:	4501                	li	a0,0
ffffffffc0205774:	0141                	addi	sp,sp,16
ffffffffc0205776:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205778:	00003697          	auipc	a3,0x3
ffffffffc020577c:	e8068693          	addi	a3,a3,-384 # ffffffffc02085f8 <default_pmm_manager+0x4f0>
ffffffffc0205780:	00001617          	auipc	a2,0x1
ffffffffc0205784:	43860613          	addi	a2,a2,1080 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205788:	35c00593          	li	a1,860
ffffffffc020578c:	00003517          	auipc	a0,0x3
ffffffffc0205790:	04c50513          	addi	a0,a0,76 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205794:	a81fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205798:	00003617          	auipc	a2,0x3
ffffffffc020579c:	e1860613          	addi	a2,a2,-488 # ffffffffc02085b0 <default_pmm_manager+0x4a8>
ffffffffc02057a0:	35400593          	li	a1,852
ffffffffc02057a4:	00003517          	auipc	a0,0x3
ffffffffc02057a8:	03450513          	addi	a0,a0,52 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc02057ac:	a69fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057b0:	00003697          	auipc	a3,0x3
ffffffffc02057b4:	ed868693          	addi	a3,a3,-296 # ffffffffc0208688 <default_pmm_manager+0x580>
ffffffffc02057b8:	00001617          	auipc	a2,0x1
ffffffffc02057bc:	40060613          	addi	a2,a2,1024 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02057c0:	35f00593          	li	a1,863
ffffffffc02057c4:	00003517          	auipc	a0,0x3
ffffffffc02057c8:	01450513          	addi	a0,a0,20 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc02057cc:	a49fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057d0:	00003697          	auipc	a3,0x3
ffffffffc02057d4:	e8868693          	addi	a3,a3,-376 # ffffffffc0208658 <default_pmm_manager+0x550>
ffffffffc02057d8:	00001617          	auipc	a2,0x1
ffffffffc02057dc:	3e060613          	addi	a2,a2,992 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02057e0:	35e00593          	li	a1,862
ffffffffc02057e4:	00003517          	auipc	a0,0x3
ffffffffc02057e8:	ff450513          	addi	a0,a0,-12 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc02057ec:	a29fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_process == 2);
ffffffffc02057f0:	00003697          	auipc	a3,0x3
ffffffffc02057f4:	e5868693          	addi	a3,a3,-424 # ffffffffc0208648 <default_pmm_manager+0x540>
ffffffffc02057f8:	00001617          	auipc	a2,0x1
ffffffffc02057fc:	3c060613          	addi	a2,a2,960 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205800:	35d00593          	li	a1,861
ffffffffc0205804:	00003517          	auipc	a0,0x3
ffffffffc0205808:	fd450513          	addi	a0,a0,-44 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc020580c:	a09fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205810 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205810:	7135                	addi	sp,sp,-160
ffffffffc0205812:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205814:	000a7a17          	auipc	s4,0xa7
ffffffffc0205818:	034a0a13          	addi	s4,s4,52 # ffffffffc02ac848 <current>
ffffffffc020581c:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205820:	e14a                	sd	s2,128(sp)
ffffffffc0205822:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205824:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205828:	fcce                	sd	s3,120(sp)
ffffffffc020582a:	f0da                	sd	s6,96(sp)
ffffffffc020582c:	89aa                	mv	s3,a0
ffffffffc020582e:	842e                	mv	s0,a1
ffffffffc0205830:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205832:	4681                	li	a3,0
ffffffffc0205834:	862e                	mv	a2,a1
ffffffffc0205836:	85aa                	mv	a1,a0
ffffffffc0205838:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020583a:	ed06                	sd	ra,152(sp)
ffffffffc020583c:	e526                	sd	s1,136(sp)
ffffffffc020583e:	f4d6                	sd	s5,104(sp)
ffffffffc0205840:	ecde                	sd	s7,88(sp)
ffffffffc0205842:	e8e2                	sd	s8,80(sp)
ffffffffc0205844:	e4e6                	sd	s9,72(sp)
ffffffffc0205846:	e0ea                	sd	s10,64(sp)
ffffffffc0205848:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020584a:	d28fd0ef          	jal	ra,ffffffffc0202d72 <user_mem_check>
ffffffffc020584e:	40050263          	beqz	a0,ffffffffc0205c52 <do_execve+0x442>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205852:	4641                	li	a2,16
ffffffffc0205854:	4581                	li	a1,0
ffffffffc0205856:	1008                	addi	a0,sp,32
ffffffffc0205858:	143000ef          	jal	ra,ffffffffc020619a <memset>
    memcpy(local_name, name, len);
ffffffffc020585c:	47bd                	li	a5,15
ffffffffc020585e:	8622                	mv	a2,s0
ffffffffc0205860:	0687ee63          	bltu	a5,s0,ffffffffc02058dc <do_execve+0xcc>
ffffffffc0205864:	85ce                	mv	a1,s3
ffffffffc0205866:	1008                	addi	a0,sp,32
ffffffffc0205868:	145000ef          	jal	ra,ffffffffc02061ac <memcpy>
    if (mm != NULL) {
ffffffffc020586c:	06090f63          	beqz	s2,ffffffffc02058ea <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205870:	00002517          	auipc	a0,0x2
ffffffffc0205874:	ef850513          	addi	a0,a0,-264 # ffffffffc0207768 <commands+0x1030>
ffffffffc0205878:	88ffa0ef          	jal	ra,ffffffffc0200106 <cputs>
        lcr3(boot_cr3);
ffffffffc020587c:	000a7797          	auipc	a5,0xa7
ffffffffc0205880:	00478793          	addi	a5,a5,4 # ffffffffc02ac880 <boot_cr3>
ffffffffc0205884:	639c                	ld	a5,0(a5)
ffffffffc0205886:	577d                	li	a4,-1
ffffffffc0205888:	177e                	slli	a4,a4,0x3f
ffffffffc020588a:	83b1                	srli	a5,a5,0xc
ffffffffc020588c:	8fd9                	or	a5,a5,a4
ffffffffc020588e:	18079073          	csrw	satp,a5
ffffffffc0205892:	03092783          	lw	a5,48(s2)
ffffffffc0205896:	fff7871b          	addiw	a4,a5,-1
ffffffffc020589a:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc020589e:	28070c63          	beqz	a4,ffffffffc0205b36 <do_execve+0x326>
        current->mm = NULL;
ffffffffc02058a2:	000a3783          	ld	a5,0(s4)
ffffffffc02058a6:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058aa:	b01fc0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc02058ae:	892a                	mv	s2,a0
ffffffffc02058b0:	c135                	beqz	a0,ffffffffc0205914 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058b2:	d96ff0ef          	jal	ra,ffffffffc0204e48 <setup_pgdir>
ffffffffc02058b6:	e931                	bnez	a0,ffffffffc020590a <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058b8:	000b2703          	lw	a4,0(s6)
ffffffffc02058bc:	464c47b7          	lui	a5,0x464c4
ffffffffc02058c0:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9ab7>
ffffffffc02058c4:	04f70a63          	beq	a4,a5,ffffffffc0205918 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058c8:	854a                	mv	a0,s2
ffffffffc02058ca:	d00ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
    mm_destroy(mm);
ffffffffc02058ce:	854a                	mv	a0,s2
ffffffffc02058d0:	c61fc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058d4:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058d6:	854e                	mv	a0,s3
ffffffffc02058d8:	b1bff0ef          	jal	ra,ffffffffc02053f2 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058dc:	463d                	li	a2,15
ffffffffc02058de:	85ce                	mv	a1,s3
ffffffffc02058e0:	1008                	addi	a0,sp,32
ffffffffc02058e2:	0cb000ef          	jal	ra,ffffffffc02061ac <memcpy>
    if (mm != NULL) {
ffffffffc02058e6:	f80915e3          	bnez	s2,ffffffffc0205870 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc02058ea:	000a3783          	ld	a5,0(s4)
ffffffffc02058ee:	779c                	ld	a5,40(a5)
ffffffffc02058f0:	dfcd                	beqz	a5,ffffffffc02058aa <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058f2:	00003617          	auipc	a2,0x3
ffffffffc02058f6:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0208380 <default_pmm_manager+0x278>
ffffffffc02058fa:	20a00593          	li	a1,522
ffffffffc02058fe:	00003517          	auipc	a0,0x3
ffffffffc0205902:	eda50513          	addi	a0,a0,-294 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205906:	90ffa0ef          	jal	ra,ffffffffc0200214 <__panic>
    mm_destroy(mm);
ffffffffc020590a:	854a                	mv	a0,s2
ffffffffc020590c:	c25fc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205910:	59f1                	li	s3,-4
ffffffffc0205912:	b7d1                	j	ffffffffc02058d6 <do_execve+0xc6>
ffffffffc0205914:	59f1                	li	s3,-4
ffffffffc0205916:	b7c1                	j	ffffffffc02058d6 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205918:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020591c:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205920:	00371793          	slli	a5,a4,0x3
ffffffffc0205924:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205926:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205928:	078e                	slli	a5,a5,0x3
ffffffffc020592a:	97a2                	add	a5,a5,s0
ffffffffc020592c:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020592e:	02f47b63          	bgeu	s0,a5,ffffffffc0205964 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205932:	5bfd                	li	s7,-1
ffffffffc0205934:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205938:	000a7d97          	auipc	s11,0xa7
ffffffffc020593c:	f50d8d93          	addi	s11,s11,-176 # ffffffffc02ac888 <pages>
ffffffffc0205940:	00003d17          	auipc	s10,0x3
ffffffffc0205944:	360d0d13          	addi	s10,s10,864 # ffffffffc0208ca0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205948:	e43e                	sd	a5,8(sp)
ffffffffc020594a:	000a7c97          	auipc	s9,0xa7
ffffffffc020594e:	ed6c8c93          	addi	s9,s9,-298 # ffffffffc02ac820 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205952:	4018                	lw	a4,0(s0)
ffffffffc0205954:	4785                	li	a5,1
ffffffffc0205956:	0ef70d63          	beq	a4,a5,ffffffffc0205a50 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc020595a:	67e2                	ld	a5,24(sp)
ffffffffc020595c:	03840413          	addi	s0,s0,56
ffffffffc0205960:	fef469e3          	bltu	s0,a5,ffffffffc0205952 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205964:	4701                	li	a4,0
ffffffffc0205966:	46ad                	li	a3,11
ffffffffc0205968:	00100637          	lui	a2,0x100
ffffffffc020596c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205970:	854a                	mv	a0,s2
ffffffffc0205972:	c11fc0ef          	jal	ra,ffffffffc0202582 <mm_map>
ffffffffc0205976:	89aa                	mv	s3,a0
ffffffffc0205978:	1a051563          	bnez	a0,ffffffffc0205b22 <do_execve+0x312>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020597c:	01893503          	ld	a0,24(s2)
ffffffffc0205980:	467d                	li	a2,31
ffffffffc0205982:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205986:	96dfc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc020598a:	36050063          	beqz	a0,ffffffffc0205cea <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020598e:	01893503          	ld	a0,24(s2)
ffffffffc0205992:	467d                	li	a2,31
ffffffffc0205994:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205998:	95bfc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc020599c:	32050763          	beqz	a0,ffffffffc0205cca <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059a0:	01893503          	ld	a0,24(s2)
ffffffffc02059a4:	467d                	li	a2,31
ffffffffc02059a6:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059aa:	949fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc02059ae:	2e050e63          	beqz	a0,ffffffffc0205caa <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059b2:	01893503          	ld	a0,24(s2)
ffffffffc02059b6:	467d                	li	a2,31
ffffffffc02059b8:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059bc:	937fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc02059c0:	2c050563          	beqz	a0,ffffffffc0205c8a <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc02059c4:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059c8:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059cc:	01893683          	ld	a3,24(s2)
ffffffffc02059d0:	2785                	addiw	a5,a5,1
ffffffffc02059d2:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059d6:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5560>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059da:	c02007b7          	lui	a5,0xc0200
ffffffffc02059de:	28f6ea63          	bltu	a3,a5,ffffffffc0205c72 <do_execve+0x462>
ffffffffc02059e2:	000a7797          	auipc	a5,0xa7
ffffffffc02059e6:	e9678793          	addi	a5,a5,-362 # ffffffffc02ac878 <va_pa_offset>
ffffffffc02059ea:	639c                	ld	a5,0(a5)
ffffffffc02059ec:	577d                	li	a4,-1
ffffffffc02059ee:	177e                	slli	a4,a4,0x3f
ffffffffc02059f0:	8e9d                	sub	a3,a3,a5
ffffffffc02059f2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059f6:	f654                	sd	a3,168(a2)
ffffffffc02059f8:	8fd9                	or	a5,a5,a4
ffffffffc02059fa:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059fe:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a00:	4581                	li	a1,0
ffffffffc0205a02:	12000613          	li	a2,288
ffffffffc0205a06:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a08:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a0c:	78e000ef          	jal	ra,ffffffffc020619a <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a10:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp=USTACKTOP;
ffffffffc0205a14:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a16:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a1a:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp=USTACKTOP;
ffffffffc0205a1e:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a20:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a22:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a26:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a2a:	100c                	addi	a1,sp,32
ffffffffc0205a2c:	ca8ff0ef          	jal	ra,ffffffffc0204ed4 <set_proc_name>
}
ffffffffc0205a30:	60ea                	ld	ra,152(sp)
ffffffffc0205a32:	644a                	ld	s0,144(sp)
ffffffffc0205a34:	854e                	mv	a0,s3
ffffffffc0205a36:	64aa                	ld	s1,136(sp)
ffffffffc0205a38:	690a                	ld	s2,128(sp)
ffffffffc0205a3a:	79e6                	ld	s3,120(sp)
ffffffffc0205a3c:	7a46                	ld	s4,112(sp)
ffffffffc0205a3e:	7aa6                	ld	s5,104(sp)
ffffffffc0205a40:	7b06                	ld	s6,96(sp)
ffffffffc0205a42:	6be6                	ld	s7,88(sp)
ffffffffc0205a44:	6c46                	ld	s8,80(sp)
ffffffffc0205a46:	6ca6                	ld	s9,72(sp)
ffffffffc0205a48:	6d06                	ld	s10,64(sp)
ffffffffc0205a4a:	7de2                	ld	s11,56(sp)
ffffffffc0205a4c:	610d                	addi	sp,sp,160
ffffffffc0205a4e:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a50:	7410                	ld	a2,40(s0)
ffffffffc0205a52:	701c                	ld	a5,32(s0)
ffffffffc0205a54:	20f66163          	bltu	a2,a5,ffffffffc0205c56 <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a58:	405c                	lw	a5,4(s0)
ffffffffc0205a5a:	0017f693          	andi	a3,a5,1
ffffffffc0205a5e:	c291                	beqz	a3,ffffffffc0205a62 <do_execve+0x252>
ffffffffc0205a60:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a62:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a66:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a68:	0e071163          	bnez	a4,ffffffffc0205b4a <do_execve+0x33a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a6c:	4745                	li	a4,17
ffffffffc0205a6e:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a70:	c789                	beqz	a5,ffffffffc0205a7a <do_execve+0x26a>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a72:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a74:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a78:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a7a:	0026f793          	andi	a5,a3,2
ffffffffc0205a7e:	ebe9                	bnez	a5,ffffffffc0205b50 <do_execve+0x340>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a80:	0046f793          	andi	a5,a3,4
ffffffffc0205a84:	c789                	beqz	a5,ffffffffc0205a8e <do_execve+0x27e>
ffffffffc0205a86:	6782                	ld	a5,0(sp)
ffffffffc0205a88:	0087e793          	ori	a5,a5,8
ffffffffc0205a8c:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a8e:	680c                	ld	a1,16(s0)
ffffffffc0205a90:	4701                	li	a4,0
ffffffffc0205a92:	854a                	mv	a0,s2
ffffffffc0205a94:	aeffc0ef          	jal	ra,ffffffffc0202582 <mm_map>
ffffffffc0205a98:	89aa                	mv	s3,a0
ffffffffc0205a9a:	e541                	bnez	a0,ffffffffc0205b22 <do_execve+0x312>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a9c:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aa0:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aa4:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aa8:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aaa:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aac:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aae:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205ab2:	053bef63          	bltu	s7,s3,ffffffffc0205b10 <do_execve+0x300>
ffffffffc0205ab6:	aa61                	j	ffffffffc0205c4e <do_execve+0x43e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ab8:	6785                	lui	a5,0x1
ffffffffc0205aba:	418b8533          	sub	a0,s7,s8
ffffffffc0205abe:	9c3e                	add	s8,s8,a5
ffffffffc0205ac0:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205ac4:	0189f463          	bgeu	s3,s8,ffffffffc0205acc <do_execve+0x2bc>
                size -= la - end;
ffffffffc0205ac8:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205acc:	000db683          	ld	a3,0(s11)
ffffffffc0205ad0:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ad4:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ad6:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ada:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205adc:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ae0:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205ae2:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ae6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ae8:	16c5f963          	bgeu	a1,a2,ffffffffc0205c5a <do_execve+0x44a>
ffffffffc0205aec:	000a7797          	auipc	a5,0xa7
ffffffffc0205af0:	d8c78793          	addi	a5,a5,-628 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205af4:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205af8:	85d6                	mv	a1,s5
ffffffffc0205afa:	8642                	mv	a2,a6
ffffffffc0205afc:	96c6                	add	a3,a3,a7
ffffffffc0205afe:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b00:	9bc2                	add	s7,s7,a6
ffffffffc0205b02:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b04:	6a8000ef          	jal	ra,ffffffffc02061ac <memcpy>
            start += size, from += size;
ffffffffc0205b08:	6842                	ld	a6,16(sp)
ffffffffc0205b0a:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b0c:	053bf563          	bgeu	s7,s3,ffffffffc0205b56 <do_execve+0x346>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b10:	01893503          	ld	a0,24(s2)
ffffffffc0205b14:	6602                	ld	a2,0(sp)
ffffffffc0205b16:	85e2                	mv	a1,s8
ffffffffc0205b18:	fdafc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc0205b1c:	84aa                	mv	s1,a0
ffffffffc0205b1e:	fd49                	bnez	a0,ffffffffc0205ab8 <do_execve+0x2a8>
        ret = -E_NO_MEM;
ffffffffc0205b20:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b22:	854a                	mv	a0,s2
ffffffffc0205b24:	badfc0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b28:	854a                	mv	a0,s2
ffffffffc0205b2a:	aa0ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b2e:	854a                	mv	a0,s2
ffffffffc0205b30:	a01fc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    return ret;
ffffffffc0205b34:	b34d                	j	ffffffffc02058d6 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b36:	854a                	mv	a0,s2
ffffffffc0205b38:	b99fc0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b3c:	854a                	mv	a0,s2
ffffffffc0205b3e:	a8cff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b42:	854a                	mv	a0,s2
ffffffffc0205b44:	9edfc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
ffffffffc0205b48:	bba9                	j	ffffffffc02058a2 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b4a:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b4e:	f395                	bnez	a5,ffffffffc0205a72 <do_execve+0x262>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b50:	47dd                	li	a5,23
ffffffffc0205b52:	e03e                	sd	a5,0(sp)
ffffffffc0205b54:	b735                	j	ffffffffc0205a80 <do_execve+0x270>
ffffffffc0205b56:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b5a:	7414                	ld	a3,40(s0)
ffffffffc0205b5c:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b5e:	098bf163          	bgeu	s7,s8,ffffffffc0205be0 <do_execve+0x3d0>
            if (start == end) {
ffffffffc0205b62:	df798ce3          	beq	s3,s7,ffffffffc020595a <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b66:	6505                	lui	a0,0x1
ffffffffc0205b68:	955e                	add	a0,a0,s7
ffffffffc0205b6a:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b6e:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b72:	0d89fb63          	bgeu	s3,s8,ffffffffc0205c48 <do_execve+0x438>
    return page - pages + nbase;
ffffffffc0205b76:	000db683          	ld	a3,0(s11)
ffffffffc0205b7a:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b7e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b80:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b84:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b86:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b8a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b8c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b90:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b92:	0cc5f463          	bgeu	a1,a2,ffffffffc0205c5a <do_execve+0x44a>
ffffffffc0205b96:	000a7617          	auipc	a2,0xa7
ffffffffc0205b9a:	ce260613          	addi	a2,a2,-798 # ffffffffc02ac878 <va_pa_offset>
ffffffffc0205b9e:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ba2:	4581                	li	a1,0
ffffffffc0205ba4:	8656                	mv	a2,s5
ffffffffc0205ba6:	96c2                	add	a3,a3,a6
ffffffffc0205ba8:	9536                	add	a0,a0,a3
ffffffffc0205baa:	5f0000ef          	jal	ra,ffffffffc020619a <memset>
            start += size;
ffffffffc0205bae:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bb2:	0389f463          	bgeu	s3,s8,ffffffffc0205bda <do_execve+0x3ca>
ffffffffc0205bb6:	dae982e3          	beq	s3,a4,ffffffffc020595a <do_execve+0x14a>
ffffffffc0205bba:	00002697          	auipc	a3,0x2
ffffffffc0205bbe:	7ee68693          	addi	a3,a3,2030 # ffffffffc02083a8 <default_pmm_manager+0x2a0>
ffffffffc0205bc2:	00001617          	auipc	a2,0x1
ffffffffc0205bc6:	ff660613          	addi	a2,a2,-10 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205bca:	25f00593          	li	a1,607
ffffffffc0205bce:	00003517          	auipc	a0,0x3
ffffffffc0205bd2:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205bd6:	e3efa0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0205bda:	ff8710e3          	bne	a4,s8,ffffffffc0205bba <do_execve+0x3aa>
ffffffffc0205bde:	8be2                	mv	s7,s8
ffffffffc0205be0:	000a7a97          	auipc	s5,0xa7
ffffffffc0205be4:	c98a8a93          	addi	s5,s5,-872 # ffffffffc02ac878 <va_pa_offset>
        while (start < end) {
ffffffffc0205be8:	053be763          	bltu	s7,s3,ffffffffc0205c36 <do_execve+0x426>
ffffffffc0205bec:	b3bd                	j	ffffffffc020595a <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bee:	6785                	lui	a5,0x1
ffffffffc0205bf0:	418b8533          	sub	a0,s7,s8
ffffffffc0205bf4:	9c3e                	add	s8,s8,a5
ffffffffc0205bf6:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205bfa:	0189f463          	bgeu	s3,s8,ffffffffc0205c02 <do_execve+0x3f2>
                size -= la - end;
ffffffffc0205bfe:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c02:	000db683          	ld	a3,0(s11)
ffffffffc0205c06:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c0a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c0c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c10:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c12:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c16:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c18:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c1c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c1e:	02b87e63          	bgeu	a6,a1,ffffffffc0205c5a <do_execve+0x44a>
ffffffffc0205c22:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c26:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c28:	4581                	li	a1,0
ffffffffc0205c2a:	96c2                	add	a3,a3,a6
ffffffffc0205c2c:	9536                	add	a0,a0,a3
ffffffffc0205c2e:	56c000ef          	jal	ra,ffffffffc020619a <memset>
        while (start < end) {
ffffffffc0205c32:	d33bf4e3          	bgeu	s7,s3,ffffffffc020595a <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c36:	01893503          	ld	a0,24(s2)
ffffffffc0205c3a:	6602                	ld	a2,0(sp)
ffffffffc0205c3c:	85e2                	mv	a1,s8
ffffffffc0205c3e:	eb4fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc0205c42:	84aa                	mv	s1,a0
ffffffffc0205c44:	f54d                	bnez	a0,ffffffffc0205bee <do_execve+0x3de>
ffffffffc0205c46:	bde9                	j	ffffffffc0205b20 <do_execve+0x310>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c48:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c4c:	b72d                	j	ffffffffc0205b76 <do_execve+0x366>
        while (start < end) {
ffffffffc0205c4e:	89de                	mv	s3,s7
ffffffffc0205c50:	b729                	j	ffffffffc0205b5a <do_execve+0x34a>
        return -E_INVAL;
ffffffffc0205c52:	59f5                	li	s3,-3
ffffffffc0205c54:	bbf1                	j	ffffffffc0205a30 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c56:	59e1                	li	s3,-8
ffffffffc0205c58:	b5e9                	j	ffffffffc0205b22 <do_execve+0x312>
ffffffffc0205c5a:	00001617          	auipc	a2,0x1
ffffffffc0205c5e:	34660613          	addi	a2,a2,838 # ffffffffc0206fa0 <commands+0x868>
ffffffffc0205c62:	06900593          	li	a1,105
ffffffffc0205c66:	00001517          	auipc	a0,0x1
ffffffffc0205c6a:	39250513          	addi	a0,a0,914 # ffffffffc0206ff8 <commands+0x8c0>
ffffffffc0205c6e:	da6fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c72:	00001617          	auipc	a2,0x1
ffffffffc0205c76:	40660613          	addi	a2,a2,1030 # ffffffffc0207078 <commands+0x940>
ffffffffc0205c7a:	27a00593          	li	a1,634
ffffffffc0205c7e:	00003517          	auipc	a0,0x3
ffffffffc0205c82:	b5a50513          	addi	a0,a0,-1190 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205c86:	d8efa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c8a:	00003697          	auipc	a3,0x3
ffffffffc0205c8e:	83668693          	addi	a3,a3,-1994 # ffffffffc02084c0 <default_pmm_manager+0x3b8>
ffffffffc0205c92:	00001617          	auipc	a2,0x1
ffffffffc0205c96:	f2660613          	addi	a2,a2,-218 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205c9a:	27500593          	li	a1,629
ffffffffc0205c9e:	00003517          	auipc	a0,0x3
ffffffffc0205ca2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205ca6:	d6efa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205caa:	00002697          	auipc	a3,0x2
ffffffffc0205cae:	7ce68693          	addi	a3,a3,1998 # ffffffffc0208478 <default_pmm_manager+0x370>
ffffffffc0205cb2:	00001617          	auipc	a2,0x1
ffffffffc0205cb6:	f0660613          	addi	a2,a2,-250 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205cba:	27400593          	li	a1,628
ffffffffc0205cbe:	00003517          	auipc	a0,0x3
ffffffffc0205cc2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205cc6:	d4efa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cca:	00002697          	auipc	a3,0x2
ffffffffc0205cce:	76668693          	addi	a3,a3,1894 # ffffffffc0208430 <default_pmm_manager+0x328>
ffffffffc0205cd2:	00001617          	auipc	a2,0x1
ffffffffc0205cd6:	ee660613          	addi	a2,a2,-282 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205cda:	27300593          	li	a1,627
ffffffffc0205cde:	00003517          	auipc	a0,0x3
ffffffffc0205ce2:	afa50513          	addi	a0,a0,-1286 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205ce6:	d2efa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cea:	00002697          	auipc	a3,0x2
ffffffffc0205cee:	6fe68693          	addi	a3,a3,1790 # ffffffffc02083e8 <default_pmm_manager+0x2e0>
ffffffffc0205cf2:	00001617          	auipc	a2,0x1
ffffffffc0205cf6:	ec660613          	addi	a2,a2,-314 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205cfa:	27200593          	li	a1,626
ffffffffc0205cfe:	00003517          	auipc	a0,0x3
ffffffffc0205d02:	ada50513          	addi	a0,a0,-1318 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205d06:	d0efa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205d0a <do_yield>:
    current->need_resched = 1;
ffffffffc0205d0a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d0e:	b3e78793          	addi	a5,a5,-1218 # ffffffffc02ac848 <current>
ffffffffc0205d12:	639c                	ld	a5,0(a5)
ffffffffc0205d14:	4705                	li	a4,1
}
ffffffffc0205d16:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d18:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d1a:	8082                	ret

ffffffffc0205d1c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d1c:	1101                	addi	sp,sp,-32
ffffffffc0205d1e:	e822                	sd	s0,16(sp)
ffffffffc0205d20:	e426                	sd	s1,8(sp)
ffffffffc0205d22:	ec06                	sd	ra,24(sp)
ffffffffc0205d24:	842e                	mv	s0,a1
ffffffffc0205d26:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d28:	cd81                	beqz	a1,ffffffffc0205d40 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d2a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d2e:	b1e78793          	addi	a5,a5,-1250 # ffffffffc02ac848 <current>
ffffffffc0205d32:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d34:	4685                	li	a3,1
ffffffffc0205d36:	4611                	li	a2,4
ffffffffc0205d38:	7788                	ld	a0,40(a5)
ffffffffc0205d3a:	838fd0ef          	jal	ra,ffffffffc0202d72 <user_mem_check>
ffffffffc0205d3e:	c909                	beqz	a0,ffffffffc0205d50 <do_wait+0x34>
ffffffffc0205d40:	85a2                	mv	a1,s0
}
ffffffffc0205d42:	6442                	ld	s0,16(sp)
ffffffffc0205d44:	60e2                	ld	ra,24(sp)
ffffffffc0205d46:	8526                	mv	a0,s1
ffffffffc0205d48:	64a2                	ld	s1,8(sp)
ffffffffc0205d4a:	6105                	addi	sp,sp,32
ffffffffc0205d4c:	ff4ff06f          	j	ffffffffc0205540 <do_wait.part.1>
ffffffffc0205d50:	60e2                	ld	ra,24(sp)
ffffffffc0205d52:	6442                	ld	s0,16(sp)
ffffffffc0205d54:	64a2                	ld	s1,8(sp)
ffffffffc0205d56:	5575                	li	a0,-3
ffffffffc0205d58:	6105                	addi	sp,sp,32
ffffffffc0205d5a:	8082                	ret

ffffffffc0205d5c <do_kill>:
do_kill(int pid) {
ffffffffc0205d5c:	1141                	addi	sp,sp,-16
ffffffffc0205d5e:	e406                	sd	ra,8(sp)
ffffffffc0205d60:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d62:	a08ff0ef          	jal	ra,ffffffffc0204f6a <find_proc>
ffffffffc0205d66:	cd0d                	beqz	a0,ffffffffc0205da0 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d68:	0b052703          	lw	a4,176(a0)
ffffffffc0205d6c:	00177693          	andi	a3,a4,1
ffffffffc0205d70:	e695                	bnez	a3,ffffffffc0205d9c <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d72:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d76:	00176713          	ori	a4,a4,1
ffffffffc0205d7a:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d7e:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d80:	0006c763          	bltz	a3,ffffffffc0205d8e <do_kill+0x32>
}
ffffffffc0205d84:	8522                	mv	a0,s0
ffffffffc0205d86:	60a2                	ld	ra,8(sp)
ffffffffc0205d88:	6402                	ld	s0,0(sp)
ffffffffc0205d8a:	0141                	addi	sp,sp,16
ffffffffc0205d8c:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d8e:	17c000ef          	jal	ra,ffffffffc0205f0a <wakeup_proc>
}
ffffffffc0205d92:	8522                	mv	a0,s0
ffffffffc0205d94:	60a2                	ld	ra,8(sp)
ffffffffc0205d96:	6402                	ld	s0,0(sp)
ffffffffc0205d98:	0141                	addi	sp,sp,16
ffffffffc0205d9a:	8082                	ret
        return -E_KILLED;
ffffffffc0205d9c:	545d                	li	s0,-9
ffffffffc0205d9e:	b7dd                	j	ffffffffc0205d84 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205da0:	5475                	li	s0,-3
ffffffffc0205da2:	b7cd                	j	ffffffffc0205d84 <do_kill+0x28>

ffffffffc0205da4 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205da4:	000a7797          	auipc	a5,0xa7
ffffffffc0205da8:	be478793          	addi	a5,a5,-1052 # ffffffffc02ac988 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205dac:	1101                	addi	sp,sp,-32
ffffffffc0205dae:	000a7717          	auipc	a4,0xa7
ffffffffc0205db2:	bef73123          	sd	a5,-1054(a4) # ffffffffc02ac990 <proc_list+0x8>
ffffffffc0205db6:	000a7717          	auipc	a4,0xa7
ffffffffc0205dba:	bcf73923          	sd	a5,-1070(a4) # ffffffffc02ac988 <proc_list>
ffffffffc0205dbe:	ec06                	sd	ra,24(sp)
ffffffffc0205dc0:	e822                	sd	s0,16(sp)
ffffffffc0205dc2:	e426                	sd	s1,8(sp)
ffffffffc0205dc4:	000a3797          	auipc	a5,0xa3
ffffffffc0205dc8:	a4478793          	addi	a5,a5,-1468 # ffffffffc02a8808 <hash_list>
ffffffffc0205dcc:	000a7717          	auipc	a4,0xa7
ffffffffc0205dd0:	a3c70713          	addi	a4,a4,-1476 # ffffffffc02ac808 <is_panic>
ffffffffc0205dd4:	e79c                	sd	a5,8(a5)
ffffffffc0205dd6:	e39c                	sd	a5,0(a5)
ffffffffc0205dd8:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205dda:	fee79de3          	bne	a5,a4,ffffffffc0205dd4 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205dde:	ee7fe0ef          	jal	ra,ffffffffc0204cc4 <alloc_proc>
ffffffffc0205de2:	000a7717          	auipc	a4,0xa7
ffffffffc0205de6:	a6a73723          	sd	a0,-1426(a4) # ffffffffc02ac850 <idleproc>
ffffffffc0205dea:	000a7497          	auipc	s1,0xa7
ffffffffc0205dee:	a6648493          	addi	s1,s1,-1434 # ffffffffc02ac850 <idleproc>
ffffffffc0205df2:	c559                	beqz	a0,ffffffffc0205e80 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205df4:	4709                	li	a4,2
ffffffffc0205df6:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205df8:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dfa:	00003717          	auipc	a4,0x3
ffffffffc0205dfe:	20670713          	addi	a4,a4,518 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e02:	00003597          	auipc	a1,0x3
ffffffffc0205e06:	8ee58593          	addi	a1,a1,-1810 # ffffffffc02086f0 <default_pmm_manager+0x5e8>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e0a:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e0c:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e0e:	8c6ff0ef          	jal	ra,ffffffffc0204ed4 <set_proc_name>
    nr_process ++;
ffffffffc0205e12:	000a7797          	auipc	a5,0xa7
ffffffffc0205e16:	a4e78793          	addi	a5,a5,-1458 # ffffffffc02ac860 <nr_process>
ffffffffc0205e1a:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e1c:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e1e:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e20:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e22:	4581                	li	a1,0
ffffffffc0205e24:	00000517          	auipc	a0,0x0
ffffffffc0205e28:	8c450513          	addi	a0,a0,-1852 # ffffffffc02056e8 <init_main>
    nr_process ++;
ffffffffc0205e2c:	000a7697          	auipc	a3,0xa7
ffffffffc0205e30:	a2f6aa23          	sw	a5,-1484(a3) # ffffffffc02ac860 <nr_process>
    current = idleproc;
ffffffffc0205e34:	000a7797          	auipc	a5,0xa7
ffffffffc0205e38:	a0e7ba23          	sd	a4,-1516(a5) # ffffffffc02ac848 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e3c:	d66ff0ef          	jal	ra,ffffffffc02053a2 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e40:	08a05c63          	blez	a0,ffffffffc0205ed8 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e44:	926ff0ef          	jal	ra,ffffffffc0204f6a <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e48:	00003597          	auipc	a1,0x3
ffffffffc0205e4c:	8d058593          	addi	a1,a1,-1840 # ffffffffc0208718 <default_pmm_manager+0x610>
    initproc = find_proc(pid);
ffffffffc0205e50:	000a7797          	auipc	a5,0xa7
ffffffffc0205e54:	a0a7b423          	sd	a0,-1528(a5) # ffffffffc02ac858 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e58:	87cff0ef          	jal	ra,ffffffffc0204ed4 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e5c:	609c                	ld	a5,0(s1)
ffffffffc0205e5e:	cfa9                	beqz	a5,ffffffffc0205eb8 <proc_init+0x114>
ffffffffc0205e60:	43dc                	lw	a5,4(a5)
ffffffffc0205e62:	ebb9                	bnez	a5,ffffffffc0205eb8 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e64:	000a7797          	auipc	a5,0xa7
ffffffffc0205e68:	9f478793          	addi	a5,a5,-1548 # ffffffffc02ac858 <initproc>
ffffffffc0205e6c:	639c                	ld	a5,0(a5)
ffffffffc0205e6e:	c78d                	beqz	a5,ffffffffc0205e98 <proc_init+0xf4>
ffffffffc0205e70:	43dc                	lw	a5,4(a5)
ffffffffc0205e72:	02879363          	bne	a5,s0,ffffffffc0205e98 <proc_init+0xf4>
}
ffffffffc0205e76:	60e2                	ld	ra,24(sp)
ffffffffc0205e78:	6442                	ld	s0,16(sp)
ffffffffc0205e7a:	64a2                	ld	s1,8(sp)
ffffffffc0205e7c:	6105                	addi	sp,sp,32
ffffffffc0205e7e:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e80:	00003617          	auipc	a2,0x3
ffffffffc0205e84:	85860613          	addi	a2,a2,-1960 # ffffffffc02086d8 <default_pmm_manager+0x5d0>
ffffffffc0205e88:	37100593          	li	a1,881
ffffffffc0205e8c:	00003517          	auipc	a0,0x3
ffffffffc0205e90:	94c50513          	addi	a0,a0,-1716 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205e94:	b80fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e98:	00003697          	auipc	a3,0x3
ffffffffc0205e9c:	8b068693          	addi	a3,a3,-1872 # ffffffffc0208748 <default_pmm_manager+0x640>
ffffffffc0205ea0:	00001617          	auipc	a2,0x1
ffffffffc0205ea4:	d1860613          	addi	a2,a2,-744 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205ea8:	38600593          	li	a1,902
ffffffffc0205eac:	00003517          	auipc	a0,0x3
ffffffffc0205eb0:	92c50513          	addi	a0,a0,-1748 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205eb4:	b60fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205eb8:	00003697          	auipc	a3,0x3
ffffffffc0205ebc:	86868693          	addi	a3,a3,-1944 # ffffffffc0208720 <default_pmm_manager+0x618>
ffffffffc0205ec0:	00001617          	auipc	a2,0x1
ffffffffc0205ec4:	cf860613          	addi	a2,a2,-776 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205ec8:	38500593          	li	a1,901
ffffffffc0205ecc:	00003517          	auipc	a0,0x3
ffffffffc0205ed0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205ed4:	b40fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ed8:	00003617          	auipc	a2,0x3
ffffffffc0205edc:	82060613          	addi	a2,a2,-2016 # ffffffffc02086f8 <default_pmm_manager+0x5f0>
ffffffffc0205ee0:	37f00593          	li	a1,895
ffffffffc0205ee4:	00003517          	auipc	a0,0x3
ffffffffc0205ee8:	8f450513          	addi	a0,a0,-1804 # ffffffffc02087d8 <default_pmm_manager+0x6d0>
ffffffffc0205eec:	b28fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205ef0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205ef0:	1141                	addi	sp,sp,-16
ffffffffc0205ef2:	e022                	sd	s0,0(sp)
ffffffffc0205ef4:	e406                	sd	ra,8(sp)
ffffffffc0205ef6:	000a7417          	auipc	s0,0xa7
ffffffffc0205efa:	95240413          	addi	s0,s0,-1710 # ffffffffc02ac848 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205efe:	6018                	ld	a4,0(s0)
ffffffffc0205f00:	6f1c                	ld	a5,24(a4)
ffffffffc0205f02:	dffd                	beqz	a5,ffffffffc0205f00 <cpu_idle+0x10>
            schedule();
ffffffffc0205f04:	082000ef          	jal	ra,ffffffffc0205f86 <schedule>
ffffffffc0205f08:	bfdd                	j	ffffffffc0205efe <cpu_idle+0xe>

ffffffffc0205f0a <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f0a:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f0c:	1101                	addi	sp,sp,-32
ffffffffc0205f0e:	ec06                	sd	ra,24(sp)
ffffffffc0205f10:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f12:	478d                	li	a5,3
ffffffffc0205f14:	04f70a63          	beq	a4,a5,ffffffffc0205f68 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f18:	100027f3          	csrr	a5,sstatus
ffffffffc0205f1c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f1e:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f20:	ef8d                	bnez	a5,ffffffffc0205f5a <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f22:	4789                	li	a5,2
ffffffffc0205f24:	00f70f63          	beq	a4,a5,ffffffffc0205f42 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f28:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f2a:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f2e:	e409                	bnez	s0,ffffffffc0205f38 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f30:	60e2                	ld	ra,24(sp)
ffffffffc0205f32:	6442                	ld	s0,16(sp)
ffffffffc0205f34:	6105                	addi	sp,sp,32
ffffffffc0205f36:	8082                	ret
ffffffffc0205f38:	6442                	ld	s0,16(sp)
ffffffffc0205f3a:	60e2                	ld	ra,24(sp)
ffffffffc0205f3c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f3e:	f10fa06f          	j	ffffffffc020064e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f42:	00003617          	auipc	a2,0x3
ffffffffc0205f46:	8e660613          	addi	a2,a2,-1818 # ffffffffc0208828 <default_pmm_manager+0x720>
ffffffffc0205f4a:	45c9                	li	a1,18
ffffffffc0205f4c:	00003517          	auipc	a0,0x3
ffffffffc0205f50:	8c450513          	addi	a0,a0,-1852 # ffffffffc0208810 <default_pmm_manager+0x708>
ffffffffc0205f54:	b2cfa0ef          	jal	ra,ffffffffc0200280 <__warn>
ffffffffc0205f58:	bfd9                	j	ffffffffc0205f2e <wakeup_proc+0x24>
ffffffffc0205f5a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f5c:	ef8fa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0205f60:	6522                	ld	a0,8(sp)
ffffffffc0205f62:	4405                	li	s0,1
ffffffffc0205f64:	4118                	lw	a4,0(a0)
ffffffffc0205f66:	bf75                	j	ffffffffc0205f22 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f68:	00003697          	auipc	a3,0x3
ffffffffc0205f6c:	88868693          	addi	a3,a3,-1912 # ffffffffc02087f0 <default_pmm_manager+0x6e8>
ffffffffc0205f70:	00001617          	auipc	a2,0x1
ffffffffc0205f74:	c4860613          	addi	a2,a2,-952 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205f78:	45a5                	li	a1,9
ffffffffc0205f7a:	00003517          	auipc	a0,0x3
ffffffffc0205f7e:	89650513          	addi	a0,a0,-1898 # ffffffffc0208810 <default_pmm_manager+0x708>
ffffffffc0205f82:	a92fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205f86 <schedule>:

void
schedule(void) {
ffffffffc0205f86:	1141                	addi	sp,sp,-16
ffffffffc0205f88:	e406                	sd	ra,8(sp)
ffffffffc0205f8a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f8c:	100027f3          	csrr	a5,sstatus
ffffffffc0205f90:	8b89                	andi	a5,a5,2
ffffffffc0205f92:	4401                	li	s0,0
ffffffffc0205f94:	e3d1                	bnez	a5,ffffffffc0206018 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205f96:	000a7797          	auipc	a5,0xa7
ffffffffc0205f9a:	8b278793          	addi	a5,a5,-1870 # ffffffffc02ac848 <current>
ffffffffc0205f9e:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fa2:	000a7797          	auipc	a5,0xa7
ffffffffc0205fa6:	8ae78793          	addi	a5,a5,-1874 # ffffffffc02ac850 <idleproc>
ffffffffc0205faa:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fac:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b0>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fb0:	04a88e63          	beq	a7,a0,ffffffffc020600c <schedule+0x86>
ffffffffc0205fb4:	0c888693          	addi	a3,a7,200
ffffffffc0205fb8:	000a7617          	auipc	a2,0xa7
ffffffffc0205fbc:	9d060613          	addi	a2,a2,-1584 # ffffffffc02ac988 <proc_list>
        le = last;
ffffffffc0205fc0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205fc2:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fc4:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205fc6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205fc8:	00c78863          	beq	a5,a2,ffffffffc0205fd8 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fcc:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205fd0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fd4:	01070463          	beq	a4,a6,ffffffffc0205fdc <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205fd8:	fef697e3          	bne	a3,a5,ffffffffc0205fc6 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fdc:	c589                	beqz	a1,ffffffffc0205fe6 <schedule+0x60>
ffffffffc0205fde:	4198                	lw	a4,0(a1)
ffffffffc0205fe0:	4789                	li	a5,2
ffffffffc0205fe2:	00f70e63          	beq	a4,a5,ffffffffc0205ffe <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205fe6:	451c                	lw	a5,8(a0)
ffffffffc0205fe8:	2785                	addiw	a5,a5,1
ffffffffc0205fea:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205fec:	00a88463          	beq	a7,a0,ffffffffc0205ff4 <schedule+0x6e>
            proc_run(next);
ffffffffc0205ff0:	f0ffe0ef          	jal	ra,ffffffffc0204efe <proc_run>
    if (flag) {
ffffffffc0205ff4:	e419                	bnez	s0,ffffffffc0206002 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205ff6:	60a2                	ld	ra,8(sp)
ffffffffc0205ff8:	6402                	ld	s0,0(sp)
ffffffffc0205ffa:	0141                	addi	sp,sp,16
ffffffffc0205ffc:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205ffe:	852e                	mv	a0,a1
ffffffffc0206000:	b7dd                	j	ffffffffc0205fe6 <schedule+0x60>
}
ffffffffc0206002:	6402                	ld	s0,0(sp)
ffffffffc0206004:	60a2                	ld	ra,8(sp)
ffffffffc0206006:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206008:	e46fa06f          	j	ffffffffc020064e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020600c:	000a7617          	auipc	a2,0xa7
ffffffffc0206010:	97c60613          	addi	a2,a2,-1668 # ffffffffc02ac988 <proc_list>
ffffffffc0206014:	86b2                	mv	a3,a2
ffffffffc0206016:	b76d                	j	ffffffffc0205fc0 <schedule+0x3a>
        intr_disable();
ffffffffc0206018:	e3cfa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc020601c:	4405                	li	s0,1
ffffffffc020601e:	bfa5                	j	ffffffffc0205f96 <schedule+0x10>

ffffffffc0206020 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206020:	000a7797          	auipc	a5,0xa7
ffffffffc0206024:	82878793          	addi	a5,a5,-2008 # ffffffffc02ac848 <current>
ffffffffc0206028:	639c                	ld	a5,0(a5)
}
ffffffffc020602a:	43c8                	lw	a0,4(a5)
ffffffffc020602c:	8082                	ret

ffffffffc020602e <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020602e:	4501                	li	a0,0
ffffffffc0206030:	8082                	ret

ffffffffc0206032 <sys_putc>:
    cputchar(c);
ffffffffc0206032:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206034:	1141                	addi	sp,sp,-16
ffffffffc0206036:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206038:	8ccfa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc020603c:	60a2                	ld	ra,8(sp)
ffffffffc020603e:	4501                	li	a0,0
ffffffffc0206040:	0141                	addi	sp,sp,16
ffffffffc0206042:	8082                	ret

ffffffffc0206044 <sys_kill>:
    return do_kill(pid);
ffffffffc0206044:	4108                	lw	a0,0(a0)
ffffffffc0206046:	d17ff06f          	j	ffffffffc0205d5c <do_kill>

ffffffffc020604a <sys_yield>:
    return do_yield();
ffffffffc020604a:	cc1ff06f          	j	ffffffffc0205d0a <do_yield>

ffffffffc020604e <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020604e:	6d14                	ld	a3,24(a0)
ffffffffc0206050:	6910                	ld	a2,16(a0)
ffffffffc0206052:	650c                	ld	a1,8(a0)
ffffffffc0206054:	6108                	ld	a0,0(a0)
ffffffffc0206056:	fbaff06f          	j	ffffffffc0205810 <do_execve>

ffffffffc020605a <sys_wait>:
    return do_wait(pid, store);
ffffffffc020605a:	650c                	ld	a1,8(a0)
ffffffffc020605c:	4108                	lw	a0,0(a0)
ffffffffc020605e:	cbfff06f          	j	ffffffffc0205d1c <do_wait>

ffffffffc0206062 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206062:	000a6797          	auipc	a5,0xa6
ffffffffc0206066:	7e678793          	addi	a5,a5,2022 # ffffffffc02ac848 <current>
ffffffffc020606a:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc020606c:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc020606e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206070:	6a0c                	ld	a1,16(a2)
ffffffffc0206072:	f55fe06f          	j	ffffffffc0204fc6 <do_fork>

ffffffffc0206076 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206076:	4108                	lw	a0,0(a0)
ffffffffc0206078:	b7aff06f          	j	ffffffffc02053f2 <do_exit>

ffffffffc020607c <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020607c:	715d                	addi	sp,sp,-80
ffffffffc020607e:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206080:	000a6497          	auipc	s1,0xa6
ffffffffc0206084:	7c848493          	addi	s1,s1,1992 # ffffffffc02ac848 <current>
ffffffffc0206088:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020608a:	e0a2                	sd	s0,64(sp)
ffffffffc020608c:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020608e:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206090:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206092:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0206094:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206098:	0327ee63          	bltu	a5,s2,ffffffffc02060d4 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc020609c:	00391713          	slli	a4,s2,0x3
ffffffffc02060a0:	00002797          	auipc	a5,0x2
ffffffffc02060a4:	7f078793          	addi	a5,a5,2032 # ffffffffc0208890 <syscalls>
ffffffffc02060a8:	97ba                	add	a5,a5,a4
ffffffffc02060aa:	639c                	ld	a5,0(a5)
ffffffffc02060ac:	c785                	beqz	a5,ffffffffc02060d4 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060ae:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060b0:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060b2:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060b4:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060b6:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060b8:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060ba:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060bc:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060be:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060c0:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060c2:	0028                	addi	a0,sp,8
ffffffffc02060c4:	9782                	jalr	a5
ffffffffc02060c6:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060c8:	60a6                	ld	ra,72(sp)
ffffffffc02060ca:	6406                	ld	s0,64(sp)
ffffffffc02060cc:	74e2                	ld	s1,56(sp)
ffffffffc02060ce:	7942                	ld	s2,48(sp)
ffffffffc02060d0:	6161                	addi	sp,sp,80
ffffffffc02060d2:	8082                	ret
    print_trapframe(tf);
ffffffffc02060d4:	8522                	mv	a0,s0
ffffffffc02060d6:	f6cfa0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02060da:	609c                	ld	a5,0(s1)
ffffffffc02060dc:	86ca                	mv	a3,s2
ffffffffc02060de:	00002617          	auipc	a2,0x2
ffffffffc02060e2:	76a60613          	addi	a2,a2,1898 # ffffffffc0208848 <default_pmm_manager+0x740>
ffffffffc02060e6:	43d8                	lw	a4,4(a5)
ffffffffc02060e8:	06300593          	li	a1,99
ffffffffc02060ec:	0b478793          	addi	a5,a5,180
ffffffffc02060f0:	00002517          	auipc	a0,0x2
ffffffffc02060f4:	78850513          	addi	a0,a0,1928 # ffffffffc0208878 <default_pmm_manager+0x770>
ffffffffc02060f8:	91cfa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02060fc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02060fc:	00054783          	lbu	a5,0(a0)
ffffffffc0206100:	cb91                	beqz	a5,ffffffffc0206114 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206102:	4781                	li	a5,0
        cnt ++;
ffffffffc0206104:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206106:	00f50733          	add	a4,a0,a5
ffffffffc020610a:	00074703          	lbu	a4,0(a4)
ffffffffc020610e:	fb7d                	bnez	a4,ffffffffc0206104 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206110:	853e                	mv	a0,a5
ffffffffc0206112:	8082                	ret
    size_t cnt = 0;
ffffffffc0206114:	4781                	li	a5,0
}
ffffffffc0206116:	853e                	mv	a0,a5
ffffffffc0206118:	8082                	ret

ffffffffc020611a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020611a:	c185                	beqz	a1,ffffffffc020613a <strnlen+0x20>
ffffffffc020611c:	00054783          	lbu	a5,0(a0)
ffffffffc0206120:	cf89                	beqz	a5,ffffffffc020613a <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206122:	4781                	li	a5,0
ffffffffc0206124:	a021                	j	ffffffffc020612c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206126:	00074703          	lbu	a4,0(a4)
ffffffffc020612a:	c711                	beqz	a4,ffffffffc0206136 <strnlen+0x1c>
        cnt ++;
ffffffffc020612c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020612e:	00f50733          	add	a4,a0,a5
ffffffffc0206132:	fef59ae3          	bne	a1,a5,ffffffffc0206126 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206136:	853e                	mv	a0,a5
ffffffffc0206138:	8082                	ret
    size_t cnt = 0;
ffffffffc020613a:	4781                	li	a5,0
}
ffffffffc020613c:	853e                	mv	a0,a5
ffffffffc020613e:	8082                	ret

ffffffffc0206140 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206140:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206142:	0585                	addi	a1,a1,1
ffffffffc0206144:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206148:	0785                	addi	a5,a5,1
ffffffffc020614a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020614e:	fb75                	bnez	a4,ffffffffc0206142 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206150:	8082                	ret

ffffffffc0206152 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206152:	00054783          	lbu	a5,0(a0)
ffffffffc0206156:	0005c703          	lbu	a4,0(a1)
ffffffffc020615a:	cb91                	beqz	a5,ffffffffc020616e <strcmp+0x1c>
ffffffffc020615c:	00e79c63          	bne	a5,a4,ffffffffc0206174 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206160:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206162:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0206166:	0585                	addi	a1,a1,1
ffffffffc0206168:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020616c:	fbe5                	bnez	a5,ffffffffc020615c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020616e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206170:	9d19                	subw	a0,a0,a4
ffffffffc0206172:	8082                	ret
ffffffffc0206174:	0007851b          	sext.w	a0,a5
ffffffffc0206178:	9d19                	subw	a0,a0,a4
ffffffffc020617a:	8082                	ret

ffffffffc020617c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020617c:	00054783          	lbu	a5,0(a0)
ffffffffc0206180:	cb91                	beqz	a5,ffffffffc0206194 <strchr+0x18>
        if (*s == c) {
ffffffffc0206182:	00b79563          	bne	a5,a1,ffffffffc020618c <strchr+0x10>
ffffffffc0206186:	a809                	j	ffffffffc0206198 <strchr+0x1c>
ffffffffc0206188:	00b78763          	beq	a5,a1,ffffffffc0206196 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020618c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020618e:	00054783          	lbu	a5,0(a0)
ffffffffc0206192:	fbfd                	bnez	a5,ffffffffc0206188 <strchr+0xc>
    }
    return NULL;
ffffffffc0206194:	4501                	li	a0,0
}
ffffffffc0206196:	8082                	ret
ffffffffc0206198:	8082                	ret

ffffffffc020619a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020619a:	ca01                	beqz	a2,ffffffffc02061aa <memset+0x10>
ffffffffc020619c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020619e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061a0:	0785                	addi	a5,a5,1
ffffffffc02061a2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061a6:	fec79de3          	bne	a5,a2,ffffffffc02061a0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061aa:	8082                	ret

ffffffffc02061ac <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061ac:	ca19                	beqz	a2,ffffffffc02061c2 <memcpy+0x16>
ffffffffc02061ae:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061b0:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061b2:	0585                	addi	a1,a1,1
ffffffffc02061b4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061b8:	0785                	addi	a5,a5,1
ffffffffc02061ba:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061be:	fec59ae3          	bne	a1,a2,ffffffffc02061b2 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02061c2:	8082                	ret

ffffffffc02061c4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02061c4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061c8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02061ca:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061ce:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02061d0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061d4:	f022                	sd	s0,32(sp)
ffffffffc02061d6:	ec26                	sd	s1,24(sp)
ffffffffc02061d8:	e84a                	sd	s2,16(sp)
ffffffffc02061da:	f406                	sd	ra,40(sp)
ffffffffc02061dc:	e44e                	sd	s3,8(sp)
ffffffffc02061de:	84aa                	mv	s1,a0
ffffffffc02061e0:	892e                	mv	s2,a1
ffffffffc02061e2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02061e6:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02061e8:	03067e63          	bgeu	a2,a6,ffffffffc0206224 <printnum+0x60>
ffffffffc02061ec:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02061ee:	00805763          	blez	s0,ffffffffc02061fc <printnum+0x38>
ffffffffc02061f2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02061f4:	85ca                	mv	a1,s2
ffffffffc02061f6:	854e                	mv	a0,s3
ffffffffc02061f8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02061fa:	fc65                	bnez	s0,ffffffffc02061f2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061fc:	1a02                	slli	s4,s4,0x20
ffffffffc02061fe:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206202:	00003797          	auipc	a5,0x3
ffffffffc0206206:	9ae78793          	addi	a5,a5,-1618 # ffffffffc0208bb0 <error_string+0xc8>
ffffffffc020620a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020620c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020620e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206212:	70a2                	ld	ra,40(sp)
ffffffffc0206214:	69a2                	ld	s3,8(sp)
ffffffffc0206216:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206218:	85ca                	mv	a1,s2
ffffffffc020621a:	8326                	mv	t1,s1
}
ffffffffc020621c:	6942                	ld	s2,16(sp)
ffffffffc020621e:	64e2                	ld	s1,24(sp)
ffffffffc0206220:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206222:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206224:	03065633          	divu	a2,a2,a6
ffffffffc0206228:	8722                	mv	a4,s0
ffffffffc020622a:	f9bff0ef          	jal	ra,ffffffffc02061c4 <printnum>
ffffffffc020622e:	b7f9                	j	ffffffffc02061fc <printnum+0x38>

ffffffffc0206230 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206230:	7119                	addi	sp,sp,-128
ffffffffc0206232:	f4a6                	sd	s1,104(sp)
ffffffffc0206234:	f0ca                	sd	s2,96(sp)
ffffffffc0206236:	e8d2                	sd	s4,80(sp)
ffffffffc0206238:	e4d6                	sd	s5,72(sp)
ffffffffc020623a:	e0da                	sd	s6,64(sp)
ffffffffc020623c:	fc5e                	sd	s7,56(sp)
ffffffffc020623e:	f862                	sd	s8,48(sp)
ffffffffc0206240:	f06a                	sd	s10,32(sp)
ffffffffc0206242:	fc86                	sd	ra,120(sp)
ffffffffc0206244:	f8a2                	sd	s0,112(sp)
ffffffffc0206246:	ecce                	sd	s3,88(sp)
ffffffffc0206248:	f466                	sd	s9,40(sp)
ffffffffc020624a:	ec6e                	sd	s11,24(sp)
ffffffffc020624c:	892a                	mv	s2,a0
ffffffffc020624e:	84ae                	mv	s1,a1
ffffffffc0206250:	8d32                	mv	s10,a2
ffffffffc0206252:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206254:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206256:	00002a17          	auipc	s4,0x2
ffffffffc020625a:	73aa0a13          	addi	s4,s4,1850 # ffffffffc0208990 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020625e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206262:	00003c17          	auipc	s8,0x3
ffffffffc0206266:	886c0c13          	addi	s8,s8,-1914 # ffffffffc0208ae8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020626a:	000d4503          	lbu	a0,0(s10)
ffffffffc020626e:	02500793          	li	a5,37
ffffffffc0206272:	001d0413          	addi	s0,s10,1
ffffffffc0206276:	00f50e63          	beq	a0,a5,ffffffffc0206292 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020627a:	c521                	beqz	a0,ffffffffc02062c2 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020627c:	02500993          	li	s3,37
ffffffffc0206280:	a011                	j	ffffffffc0206284 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0206282:	c121                	beqz	a0,ffffffffc02062c2 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0206284:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206286:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206288:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020628a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020628e:	ff351ae3          	bne	a0,s3,ffffffffc0206282 <vprintfmt+0x52>
ffffffffc0206292:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206296:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020629a:	4981                	li	s3,0
ffffffffc020629c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020629e:	5cfd                	li	s9,-1
ffffffffc02062a0:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062a2:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02062a6:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062a8:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02062ac:	0ff6f693          	andi	a3,a3,255
ffffffffc02062b0:	00140d13          	addi	s10,s0,1
ffffffffc02062b4:	1ed5ef63          	bltu	a1,a3,ffffffffc02064b2 <vprintfmt+0x282>
ffffffffc02062b8:	068a                	slli	a3,a3,0x2
ffffffffc02062ba:	96d2                	add	a3,a3,s4
ffffffffc02062bc:	4294                	lw	a3,0(a3)
ffffffffc02062be:	96d2                	add	a3,a3,s4
ffffffffc02062c0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062c2:	70e6                	ld	ra,120(sp)
ffffffffc02062c4:	7446                	ld	s0,112(sp)
ffffffffc02062c6:	74a6                	ld	s1,104(sp)
ffffffffc02062c8:	7906                	ld	s2,96(sp)
ffffffffc02062ca:	69e6                	ld	s3,88(sp)
ffffffffc02062cc:	6a46                	ld	s4,80(sp)
ffffffffc02062ce:	6aa6                	ld	s5,72(sp)
ffffffffc02062d0:	6b06                	ld	s6,64(sp)
ffffffffc02062d2:	7be2                	ld	s7,56(sp)
ffffffffc02062d4:	7c42                	ld	s8,48(sp)
ffffffffc02062d6:	7ca2                	ld	s9,40(sp)
ffffffffc02062d8:	7d02                	ld	s10,32(sp)
ffffffffc02062da:	6de2                	ld	s11,24(sp)
ffffffffc02062dc:	6109                	addi	sp,sp,128
ffffffffc02062de:	8082                	ret
            padc = '-';
ffffffffc02062e0:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062e2:	00144603          	lbu	a2,1(s0)
ffffffffc02062e6:	846a                	mv	s0,s10
ffffffffc02062e8:	b7c1                	j	ffffffffc02062a8 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc02062ea:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02062ee:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02062f2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062f4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02062f6:	fa0dd9e3          	bgez	s11,ffffffffc02062a8 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02062fa:	8de6                	mv	s11,s9
ffffffffc02062fc:	5cfd                	li	s9,-1
ffffffffc02062fe:	b76d                	j	ffffffffc02062a8 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0206300:	fffdc693          	not	a3,s11
ffffffffc0206304:	96fd                	srai	a3,a3,0x3f
ffffffffc0206306:	00ddfdb3          	and	s11,s11,a3
ffffffffc020630a:	00144603          	lbu	a2,1(s0)
ffffffffc020630e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206310:	846a                	mv	s0,s10
ffffffffc0206312:	bf59                	j	ffffffffc02062a8 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206314:	4705                	li	a4,1
ffffffffc0206316:	008a8593          	addi	a1,s5,8
ffffffffc020631a:	01074463          	blt	a4,a6,ffffffffc0206322 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc020631e:	22080863          	beqz	a6,ffffffffc020654e <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0206322:	000ab603          	ld	a2,0(s5)
ffffffffc0206326:	46c1                	li	a3,16
ffffffffc0206328:	8aae                	mv	s5,a1
ffffffffc020632a:	a291                	j	ffffffffc020646e <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020632c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206330:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206334:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206336:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020633a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020633e:	fad56ce3          	bltu	a0,a3,ffffffffc02062f6 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206342:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206344:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0206348:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020634c:	0196873b          	addw	a4,a3,s9
ffffffffc0206350:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206354:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0206358:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020635c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206360:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206364:	fcd57fe3          	bgeu	a0,a3,ffffffffc0206342 <vprintfmt+0x112>
ffffffffc0206368:	b779                	j	ffffffffc02062f6 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc020636a:	000aa503          	lw	a0,0(s5)
ffffffffc020636e:	85a6                	mv	a1,s1
ffffffffc0206370:	0aa1                	addi	s5,s5,8
ffffffffc0206372:	9902                	jalr	s2
            break;
ffffffffc0206374:	bddd                	j	ffffffffc020626a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206376:	4705                	li	a4,1
ffffffffc0206378:	008a8993          	addi	s3,s5,8
ffffffffc020637c:	01074463          	blt	a4,a6,ffffffffc0206384 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0206380:	1c080463          	beqz	a6,ffffffffc0206548 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0206384:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0206388:	1c044a63          	bltz	s0,ffffffffc020655c <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc020638c:	8622                	mv	a2,s0
ffffffffc020638e:	8ace                	mv	s5,s3
ffffffffc0206390:	46a9                	li	a3,10
ffffffffc0206392:	a8f1                	j	ffffffffc020646e <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0206394:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206398:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020639a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020639c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02063a0:	8fb5                	xor	a5,a5,a3
ffffffffc02063a2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063a6:	12d74963          	blt	a4,a3,ffffffffc02064d8 <vprintfmt+0x2a8>
ffffffffc02063aa:	00369793          	slli	a5,a3,0x3
ffffffffc02063ae:	97e2                	add	a5,a5,s8
ffffffffc02063b0:	639c                	ld	a5,0(a5)
ffffffffc02063b2:	12078363          	beqz	a5,ffffffffc02064d8 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02063b6:	86be                	mv	a3,a5
ffffffffc02063b8:	00000617          	auipc	a2,0x0
ffffffffc02063bc:	23860613          	addi	a2,a2,568 # ffffffffc02065f0 <etext+0x28>
ffffffffc02063c0:	85a6                	mv	a1,s1
ffffffffc02063c2:	854a                	mv	a0,s2
ffffffffc02063c4:	1cc000ef          	jal	ra,ffffffffc0206590 <printfmt>
ffffffffc02063c8:	b54d                	j	ffffffffc020626a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02063ca:	000ab603          	ld	a2,0(s5)
ffffffffc02063ce:	0aa1                	addi	s5,s5,8
ffffffffc02063d0:	1a060163          	beqz	a2,ffffffffc0206572 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02063d4:	00160413          	addi	s0,a2,1
ffffffffc02063d8:	15b05763          	blez	s11,ffffffffc0206526 <vprintfmt+0x2f6>
ffffffffc02063dc:	02d00593          	li	a1,45
ffffffffc02063e0:	10b79d63          	bne	a5,a1,ffffffffc02064fa <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063e4:	00064783          	lbu	a5,0(a2)
ffffffffc02063e8:	0007851b          	sext.w	a0,a5
ffffffffc02063ec:	c905                	beqz	a0,ffffffffc020641c <vprintfmt+0x1ec>
ffffffffc02063ee:	000cc563          	bltz	s9,ffffffffc02063f8 <vprintfmt+0x1c8>
ffffffffc02063f2:	3cfd                	addiw	s9,s9,-1
ffffffffc02063f4:	036c8263          	beq	s9,s6,ffffffffc0206418 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc02063f8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063fa:	14098f63          	beqz	s3,ffffffffc0206558 <vprintfmt+0x328>
ffffffffc02063fe:	3781                	addiw	a5,a5,-32
ffffffffc0206400:	14fbfc63          	bgeu	s7,a5,ffffffffc0206558 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0206404:	03f00513          	li	a0,63
ffffffffc0206408:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020640a:	0405                	addi	s0,s0,1
ffffffffc020640c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206410:	3dfd                	addiw	s11,s11,-1
ffffffffc0206412:	0007851b          	sext.w	a0,a5
ffffffffc0206416:	fd61                	bnez	a0,ffffffffc02063ee <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0206418:	e5b059e3          	blez	s11,ffffffffc020626a <vprintfmt+0x3a>
ffffffffc020641c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020641e:	85a6                	mv	a1,s1
ffffffffc0206420:	02000513          	li	a0,32
ffffffffc0206424:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206426:	e40d82e3          	beqz	s11,ffffffffc020626a <vprintfmt+0x3a>
ffffffffc020642a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020642c:	85a6                	mv	a1,s1
ffffffffc020642e:	02000513          	li	a0,32
ffffffffc0206432:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206434:	fe0d94e3          	bnez	s11,ffffffffc020641c <vprintfmt+0x1ec>
ffffffffc0206438:	bd0d                	j	ffffffffc020626a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020643a:	4705                	li	a4,1
ffffffffc020643c:	008a8593          	addi	a1,s5,8
ffffffffc0206440:	01074463          	blt	a4,a6,ffffffffc0206448 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0206444:	0e080863          	beqz	a6,ffffffffc0206534 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0206448:	000ab603          	ld	a2,0(s5)
ffffffffc020644c:	46a1                	li	a3,8
ffffffffc020644e:	8aae                	mv	s5,a1
ffffffffc0206450:	a839                	j	ffffffffc020646e <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0206452:	03000513          	li	a0,48
ffffffffc0206456:	85a6                	mv	a1,s1
ffffffffc0206458:	e03e                	sd	a5,0(sp)
ffffffffc020645a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020645c:	85a6                	mv	a1,s1
ffffffffc020645e:	07800513          	li	a0,120
ffffffffc0206462:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206464:	0aa1                	addi	s5,s5,8
ffffffffc0206466:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020646a:	6782                	ld	a5,0(sp)
ffffffffc020646c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020646e:	2781                	sext.w	a5,a5
ffffffffc0206470:	876e                	mv	a4,s11
ffffffffc0206472:	85a6                	mv	a1,s1
ffffffffc0206474:	854a                	mv	a0,s2
ffffffffc0206476:	d4fff0ef          	jal	ra,ffffffffc02061c4 <printnum>
            break;
ffffffffc020647a:	bbc5                	j	ffffffffc020626a <vprintfmt+0x3a>
            lflag ++;
ffffffffc020647c:	00144603          	lbu	a2,1(s0)
ffffffffc0206480:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206482:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206484:	b515                	j	ffffffffc02062a8 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0206486:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020648a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020648c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020648e:	bd29                	j	ffffffffc02062a8 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206490:	85a6                	mv	a1,s1
ffffffffc0206492:	02500513          	li	a0,37
ffffffffc0206496:	9902                	jalr	s2
            break;
ffffffffc0206498:	bbc9                	j	ffffffffc020626a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020649a:	4705                	li	a4,1
ffffffffc020649c:	008a8593          	addi	a1,s5,8
ffffffffc02064a0:	01074463          	blt	a4,a6,ffffffffc02064a8 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02064a4:	08080d63          	beqz	a6,ffffffffc020653e <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02064a8:	000ab603          	ld	a2,0(s5)
ffffffffc02064ac:	46a9                	li	a3,10
ffffffffc02064ae:	8aae                	mv	s5,a1
ffffffffc02064b0:	bf7d                	j	ffffffffc020646e <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02064b2:	85a6                	mv	a1,s1
ffffffffc02064b4:	02500513          	li	a0,37
ffffffffc02064b8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02064ba:	fff44703          	lbu	a4,-1(s0)
ffffffffc02064be:	02500793          	li	a5,37
ffffffffc02064c2:	8d22                	mv	s10,s0
ffffffffc02064c4:	daf703e3          	beq	a4,a5,ffffffffc020626a <vprintfmt+0x3a>
ffffffffc02064c8:	02500713          	li	a4,37
ffffffffc02064cc:	1d7d                	addi	s10,s10,-1
ffffffffc02064ce:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02064d2:	fee79de3          	bne	a5,a4,ffffffffc02064cc <vprintfmt+0x29c>
ffffffffc02064d6:	bb51                	j	ffffffffc020626a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02064d8:	00002617          	auipc	a2,0x2
ffffffffc02064dc:	7b860613          	addi	a2,a2,1976 # ffffffffc0208c90 <error_string+0x1a8>
ffffffffc02064e0:	85a6                	mv	a1,s1
ffffffffc02064e2:	854a                	mv	a0,s2
ffffffffc02064e4:	0ac000ef          	jal	ra,ffffffffc0206590 <printfmt>
ffffffffc02064e8:	b349                	j	ffffffffc020626a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02064ea:	00002617          	auipc	a2,0x2
ffffffffc02064ee:	79e60613          	addi	a2,a2,1950 # ffffffffc0208c88 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02064f2:	00002417          	auipc	s0,0x2
ffffffffc02064f6:	79740413          	addi	s0,s0,1943 # ffffffffc0208c89 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064fa:	8532                	mv	a0,a2
ffffffffc02064fc:	85e6                	mv	a1,s9
ffffffffc02064fe:	e032                	sd	a2,0(sp)
ffffffffc0206500:	e43e                	sd	a5,8(sp)
ffffffffc0206502:	c19ff0ef          	jal	ra,ffffffffc020611a <strnlen>
ffffffffc0206506:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020650a:	6602                	ld	a2,0(sp)
ffffffffc020650c:	01b05d63          	blez	s11,ffffffffc0206526 <vprintfmt+0x2f6>
ffffffffc0206510:	67a2                	ld	a5,8(sp)
ffffffffc0206512:	2781                	sext.w	a5,a5
ffffffffc0206514:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206516:	6522                	ld	a0,8(sp)
ffffffffc0206518:	85a6                	mv	a1,s1
ffffffffc020651a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020651c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020651e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206520:	6602                	ld	a2,0(sp)
ffffffffc0206522:	fe0d9ae3          	bnez	s11,ffffffffc0206516 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206526:	00064783          	lbu	a5,0(a2)
ffffffffc020652a:	0007851b          	sext.w	a0,a5
ffffffffc020652e:	ec0510e3          	bnez	a0,ffffffffc02063ee <vprintfmt+0x1be>
ffffffffc0206532:	bb25                	j	ffffffffc020626a <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0206534:	000ae603          	lwu	a2,0(s5)
ffffffffc0206538:	46a1                	li	a3,8
ffffffffc020653a:	8aae                	mv	s5,a1
ffffffffc020653c:	bf0d                	j	ffffffffc020646e <vprintfmt+0x23e>
ffffffffc020653e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206542:	46a9                	li	a3,10
ffffffffc0206544:	8aae                	mv	s5,a1
ffffffffc0206546:	b725                	j	ffffffffc020646e <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0206548:	000aa403          	lw	s0,0(s5)
ffffffffc020654c:	bd35                	j	ffffffffc0206388 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc020654e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206552:	46c1                	li	a3,16
ffffffffc0206554:	8aae                	mv	s5,a1
ffffffffc0206556:	bf21                	j	ffffffffc020646e <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0206558:	9902                	jalr	s2
ffffffffc020655a:	bd45                	j	ffffffffc020640a <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc020655c:	85a6                	mv	a1,s1
ffffffffc020655e:	02d00513          	li	a0,45
ffffffffc0206562:	e03e                	sd	a5,0(sp)
ffffffffc0206564:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206566:	8ace                	mv	s5,s3
ffffffffc0206568:	40800633          	neg	a2,s0
ffffffffc020656c:	46a9                	li	a3,10
ffffffffc020656e:	6782                	ld	a5,0(sp)
ffffffffc0206570:	bdfd                	j	ffffffffc020646e <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0206572:	01b05663          	blez	s11,ffffffffc020657e <vprintfmt+0x34e>
ffffffffc0206576:	02d00693          	li	a3,45
ffffffffc020657a:	f6d798e3          	bne	a5,a3,ffffffffc02064ea <vprintfmt+0x2ba>
ffffffffc020657e:	00002417          	auipc	s0,0x2
ffffffffc0206582:	70b40413          	addi	s0,s0,1803 # ffffffffc0208c89 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206586:	02800513          	li	a0,40
ffffffffc020658a:	02800793          	li	a5,40
ffffffffc020658e:	b585                	j	ffffffffc02063ee <vprintfmt+0x1be>

ffffffffc0206590 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206590:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206592:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206596:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206598:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020659a:	ec06                	sd	ra,24(sp)
ffffffffc020659c:	f83a                	sd	a4,48(sp)
ffffffffc020659e:	fc3e                	sd	a5,56(sp)
ffffffffc02065a0:	e0c2                	sd	a6,64(sp)
ffffffffc02065a2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065a4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065a6:	c8bff0ef          	jal	ra,ffffffffc0206230 <vprintfmt>
}
ffffffffc02065aa:	60e2                	ld	ra,24(sp)
ffffffffc02065ac:	6161                	addi	sp,sp,80
ffffffffc02065ae:	8082                	ret

ffffffffc02065b0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065b0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065b4:	2785                	addiw	a5,a5,1
ffffffffc02065b6:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02065ba:	02000793          	li	a5,32
ffffffffc02065be:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02065c2:	00b5553b          	srlw	a0,a0,a1
ffffffffc02065c6:	8082                	ret
