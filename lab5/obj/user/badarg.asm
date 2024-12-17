
obj/__user_badarg.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	fc3e                	sd	a5,56(sp)
  800026:	8432                	mv	s0,a2
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800028:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	62250513          	addi	a0,a0,1570 # 800650 <main+0xec>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0d0000ef          	jal	ra,800112 <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0a8000ef          	jal	ra,8000f2 <vcprintf>
    cprintf("\n");
  80004e:	00001517          	auipc	a0,0x1
  800052:	95a50513          	addi	a0,a0,-1702 # 8009a8 <error_string+0x1c8>
  800056:	0bc000ef          	jal	ra,800112 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	05a000ef          	jal	ra,8000b6 <exit>

0000000000800060 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800060:	7175                	addi	sp,sp,-144
  800062:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800064:	e0ba                	sd	a4,64(sp)
  800066:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  800068:	e42a                	sd	a0,8(sp)
  80006a:	ecae                	sd	a1,88(sp)
  80006c:	f0b2                	sd	a2,96(sp)
  80006e:	f4b6                	sd	a3,104(sp)
  800070:	fcbe                	sd	a5,120(sp)
  800072:	e142                	sd	a6,128(sp)
  800074:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800076:	f42e                	sd	a1,40(sp)
  800078:	f832                	sd	a2,48(sp)
  80007a:	fc36                	sd	a3,56(sp)
  80007c:	f03a                	sd	a4,32(sp)
  80007e:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800080:	6522                	ld	a0,8(sp)
  800082:	75a2                	ld	a1,40(sp)
  800084:	7642                	ld	a2,48(sp)
  800086:	76e2                	ld	a3,56(sp)
  800088:	6706                	ld	a4,64(sp)
  80008a:	67a6                	ld	a5,72(sp)
  80008c:	00000073          	ecall
  800090:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800094:	4572                	lw	a0,28(sp)
  800096:	6149                	addi	sp,sp,144
  800098:	8082                	ret

000000000080009a <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80009a:	85aa                	mv	a1,a0
  80009c:	4505                	li	a0,1
  80009e:	b7c9                	j	800060 <syscall>

00000000008000a0 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000a0:	4509                	li	a0,2
  8000a2:	bf7d                	j	800060 <syscall>

00000000008000a4 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
  8000a4:	862e                	mv	a2,a1
  8000a6:	85aa                	mv	a1,a0
  8000a8:	450d                	li	a0,3
  8000aa:	bf5d                	j	800060 <syscall>

00000000008000ac <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000ac:	4529                	li	a0,10
  8000ae:	bf4d                	j	800060 <syscall>

00000000008000b0 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b0:	85aa                	mv	a1,a0
  8000b2:	4579                	li	a0,30
  8000b4:	b775                	j	800060 <syscall>

00000000008000b6 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000b6:	1141                	addi	sp,sp,-16
  8000b8:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ba:	fe1ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000be:	00000517          	auipc	a0,0x0
  8000c2:	5b250513          	addi	a0,a0,1458 # 800670 <main+0x10c>
  8000c6:	04c000ef          	jal	ra,800112 <cprintf>
    while (1);
  8000ca:	a001                	j	8000ca <exit+0x14>

00000000008000cc <fork>:
}

int
fork(void) {
    return sys_fork();
  8000cc:	bfd1                	j	8000a0 <sys_fork>

00000000008000ce <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000ce:	bfd9                	j	8000a4 <sys_wait>

00000000008000d0 <yield>:
}

void
yield(void) {
    sys_yield();
  8000d0:	bff1                	j	8000ac <sys_yield>

00000000008000d2 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000d2:	074000ef          	jal	ra,800146 <umain>
1:  j 1b
  8000d6:	a001                	j	8000d6 <_start+0x4>

00000000008000d8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000d8:	1141                	addi	sp,sp,-16
  8000da:	e022                	sd	s0,0(sp)
  8000dc:	e406                	sd	ra,8(sp)
  8000de:	842e                	mv	s0,a1
    sys_putc(c);
  8000e0:	fd1ff0ef          	jal	ra,8000b0 <sys_putc>
    (*cnt) ++;
  8000e4:	401c                	lw	a5,0(s0)
}
  8000e6:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000e8:	2785                	addiw	a5,a5,1
  8000ea:	c01c                	sw	a5,0(s0)
}
  8000ec:	6402                	ld	s0,0(sp)
  8000ee:	0141                	addi	sp,sp,16
  8000f0:	8082                	ret

00000000008000f2 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000f2:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f4:	86ae                	mv	a3,a1
  8000f6:	862a                	mv	a2,a0
  8000f8:	006c                	addi	a1,sp,12
  8000fa:	00000517          	auipc	a0,0x0
  8000fe:	fde50513          	addi	a0,a0,-34 # 8000d8 <cputch>
vcprintf(const char *fmt, va_list ap) {
  800102:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800104:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800106:	0de000ef          	jal	ra,8001e4 <vprintfmt>
    return cnt;
}
  80010a:	60e2                	ld	ra,24(sp)
  80010c:	4532                	lw	a0,12(sp)
  80010e:	6105                	addi	sp,sp,32
  800110:	8082                	ret

0000000000800112 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800112:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800114:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800118:	f42e                	sd	a1,40(sp)
  80011a:	f832                	sd	a2,48(sp)
  80011c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80011e:	862a                	mv	a2,a0
  800120:	004c                	addi	a1,sp,4
  800122:	00000517          	auipc	a0,0x0
  800126:	fb650513          	addi	a0,a0,-74 # 8000d8 <cputch>
  80012a:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80012c:	ec06                	sd	ra,24(sp)
  80012e:	e0ba                	sd	a4,64(sp)
  800130:	e4be                	sd	a5,72(sp)
  800132:	e8c2                	sd	a6,80(sp)
  800134:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800136:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800138:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80013a:	0aa000ef          	jal	ra,8001e4 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80013e:	60e2                	ld	ra,24(sp)
  800140:	4512                	lw	a0,4(sp)
  800142:	6125                	addi	sp,sp,96
  800144:	8082                	ret

0000000000800146 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800146:	1141                	addi	sp,sp,-16
  800148:	e406                	sd	ra,8(sp)
    int ret = main();
  80014a:	41a000ef          	jal	ra,800564 <main>
    exit(ret);
  80014e:	f69ff0ef          	jal	ra,8000b6 <exit>

0000000000800152 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800152:	c185                	beqz	a1,800172 <strnlen+0x20>
  800154:	00054783          	lbu	a5,0(a0)
  800158:	cf89                	beqz	a5,800172 <strnlen+0x20>
    size_t cnt = 0;
  80015a:	4781                	li	a5,0
  80015c:	a021                	j	800164 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80015e:	00074703          	lbu	a4,0(a4)
  800162:	c711                	beqz	a4,80016e <strnlen+0x1c>
        cnt ++;
  800164:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800166:	00f50733          	add	a4,a0,a5
  80016a:	fef59ae3          	bne	a1,a5,80015e <strnlen+0xc>
    }
    return cnt;
}
  80016e:	853e                	mv	a0,a5
  800170:	8082                	ret
    size_t cnt = 0;
  800172:	4781                	li	a5,0
}
  800174:	853e                	mv	a0,a5
  800176:	8082                	ret

0000000000800178 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800178:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80017e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800184:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	f022                	sd	s0,32(sp)
  80018a:	ec26                	sd	s1,24(sp)
  80018c:	e84a                	sd	s2,16(sp)
  80018e:	f406                	sd	ra,40(sp)
  800190:	e44e                	sd	s3,8(sp)
  800192:	84aa                	mv	s1,a0
  800194:	892e                	mv	s2,a1
  800196:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80019a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80019c:	03067e63          	bgeu	a2,a6,8001d8 <printnum+0x60>
  8001a0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001a2:	00805763          	blez	s0,8001b0 <printnum+0x38>
  8001a6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a8:	85ca                	mv	a1,s2
  8001aa:	854e                	mv	a0,s3
  8001ac:	9482                	jalr	s1
        while (-- width > 0)
  8001ae:	fc65                	bnez	s0,8001a6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	1a02                	slli	s4,s4,0x20
  8001b2:	020a5a13          	srli	s4,s4,0x20
  8001b6:	00000797          	auipc	a5,0x0
  8001ba:	6f278793          	addi	a5,a5,1778 # 8008a8 <error_string+0xc8>
  8001be:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	000a4503          	lbu	a0,0(s4)
}
  8001c6:	70a2                	ld	ra,40(sp)
  8001c8:	69a2                	ld	s3,8(sp)
  8001ca:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	85ca                	mv	a1,s2
  8001ce:	8326                	mv	t1,s1
}
  8001d0:	6942                	ld	s2,16(sp)
  8001d2:	64e2                	ld	s1,24(sp)
  8001d4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d8:	03065633          	divu	a2,a2,a6
  8001dc:	8722                	mv	a4,s0
  8001de:	f9bff0ef          	jal	ra,800178 <printnum>
  8001e2:	b7f9                	j	8001b0 <printnum+0x38>

00000000008001e4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e4:	7119                	addi	sp,sp,-128
  8001e6:	f4a6                	sd	s1,104(sp)
  8001e8:	f0ca                	sd	s2,96(sp)
  8001ea:	e8d2                	sd	s4,80(sp)
  8001ec:	e4d6                	sd	s5,72(sp)
  8001ee:	e0da                	sd	s6,64(sp)
  8001f0:	fc5e                	sd	s7,56(sp)
  8001f2:	f862                	sd	s8,48(sp)
  8001f4:	f06a                	sd	s10,32(sp)
  8001f6:	fc86                	sd	ra,120(sp)
  8001f8:	f8a2                	sd	s0,112(sp)
  8001fa:	ecce                	sd	s3,88(sp)
  8001fc:	f466                	sd	s9,40(sp)
  8001fe:	ec6e                	sd	s11,24(sp)
  800200:	892a                	mv	s2,a0
  800202:	84ae                	mv	s1,a1
  800204:	8d32                	mv	s10,a2
  800206:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800208:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80020a:	00000a17          	auipc	s4,0x0
  80020e:	47aa0a13          	addi	s4,s4,1146 # 800684 <main+0x120>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800212:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800216:	00000c17          	auipc	s8,0x0
  80021a:	5cac0c13          	addi	s8,s8,1482 # 8007e0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	000d4503          	lbu	a0,0(s10)
  800222:	02500793          	li	a5,37
  800226:	001d0413          	addi	s0,s10,1
  80022a:	00f50e63          	beq	a0,a5,800246 <vprintfmt+0x62>
            if (ch == '\0') {
  80022e:	c521                	beqz	a0,800276 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800230:	02500993          	li	s3,37
  800234:	a011                	j	800238 <vprintfmt+0x54>
            if (ch == '\0') {
  800236:	c121                	beqz	a0,800276 <vprintfmt+0x92>
            putch(ch, putdat);
  800238:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80023c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023e:	fff44503          	lbu	a0,-1(s0)
  800242:	ff351ae3          	bne	a0,s3,800236 <vprintfmt+0x52>
  800246:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80024a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80024e:	4981                	li	s3,0
  800250:	4801                	li	a6,0
        width = precision = -1;
  800252:	5cfd                	li	s9,-1
  800254:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80025a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80025c:	fdd6069b          	addiw	a3,a2,-35
  800260:	0ff6f693          	andi	a3,a3,255
  800264:	00140d13          	addi	s10,s0,1
  800268:	1ed5ef63          	bltu	a1,a3,800466 <vprintfmt+0x282>
  80026c:	068a                	slli	a3,a3,0x2
  80026e:	96d2                	add	a3,a3,s4
  800270:	4294                	lw	a3,0(a3)
  800272:	96d2                	add	a3,a3,s4
  800274:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800276:	70e6                	ld	ra,120(sp)
  800278:	7446                	ld	s0,112(sp)
  80027a:	74a6                	ld	s1,104(sp)
  80027c:	7906                	ld	s2,96(sp)
  80027e:	69e6                	ld	s3,88(sp)
  800280:	6a46                	ld	s4,80(sp)
  800282:	6aa6                	ld	s5,72(sp)
  800284:	6b06                	ld	s6,64(sp)
  800286:	7be2                	ld	s7,56(sp)
  800288:	7c42                	ld	s8,48(sp)
  80028a:	7ca2                	ld	s9,40(sp)
  80028c:	7d02                	ld	s10,32(sp)
  80028e:	6de2                	ld	s11,24(sp)
  800290:	6109                	addi	sp,sp,128
  800292:	8082                	ret
            padc = '-';
  800294:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	00144603          	lbu	a2,1(s0)
  80029a:	846a                	mv	s0,s10
  80029c:	b7c1                	j	80025c <vprintfmt+0x78>
            precision = va_arg(ap, int);
  80029e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8002a2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002a6:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002a8:	846a                	mv	s0,s10
            if (width < 0)
  8002aa:	fa0dd9e3          	bgez	s11,80025c <vprintfmt+0x78>
                width = precision, precision = -1;
  8002ae:	8de6                	mv	s11,s9
  8002b0:	5cfd                	li	s9,-1
  8002b2:	b76d                	j	80025c <vprintfmt+0x78>
            if (width < 0)
  8002b4:	fffdc693          	not	a3,s11
  8002b8:	96fd                	srai	a3,a3,0x3f
  8002ba:	00ddfdb3          	and	s11,s11,a3
  8002be:	00144603          	lbu	a2,1(s0)
  8002c2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002c4:	846a                	mv	s0,s10
  8002c6:	bf59                	j	80025c <vprintfmt+0x78>
    if (lflag >= 2) {
  8002c8:	4705                	li	a4,1
  8002ca:	008a8593          	addi	a1,s5,8
  8002ce:	01074463          	blt	a4,a6,8002d6 <vprintfmt+0xf2>
    else if (lflag) {
  8002d2:	22080863          	beqz	a6,800502 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002d6:	000ab603          	ld	a2,0(s5)
  8002da:	46c1                	li	a3,16
  8002dc:	8aae                	mv	s5,a1
  8002de:	a291                	j	800422 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002e0:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002e4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ea:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002ee:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002f2:	fad56ce3          	bltu	a0,a3,8002aa <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002f6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002f8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002fc:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800300:	0196873b          	addw	a4,a3,s9
  800304:	0017171b          	slliw	a4,a4,0x1
  800308:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80030c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800310:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800314:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800318:	fcd57fe3          	bgeu	a0,a3,8002f6 <vprintfmt+0x112>
  80031c:	b779                	j	8002aa <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  80031e:	000aa503          	lw	a0,0(s5)
  800322:	85a6                	mv	a1,s1
  800324:	0aa1                	addi	s5,s5,8
  800326:	9902                	jalr	s2
            break;
  800328:	bddd                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  80032a:	4705                	li	a4,1
  80032c:	008a8993          	addi	s3,s5,8
  800330:	01074463          	blt	a4,a6,800338 <vprintfmt+0x154>
    else if (lflag) {
  800334:	1c080463          	beqz	a6,8004fc <vprintfmt+0x318>
        return va_arg(*ap, long);
  800338:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80033c:	1c044a63          	bltz	s0,800510 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800340:	8622                	mv	a2,s0
  800342:	8ace                	mv	s5,s3
  800344:	46a9                	li	a3,10
  800346:	a8f1                	j	800422 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800348:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80034c:	4761                	li	a4,24
            err = va_arg(ap, int);
  80034e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800350:	41f7d69b          	sraiw	a3,a5,0x1f
  800354:	8fb5                	xor	a5,a5,a3
  800356:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80035a:	12d74963          	blt	a4,a3,80048c <vprintfmt+0x2a8>
  80035e:	00369793          	slli	a5,a3,0x3
  800362:	97e2                	add	a5,a5,s8
  800364:	639c                	ld	a5,0(a5)
  800366:	12078363          	beqz	a5,80048c <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  80036a:	86be                	mv	a3,a5
  80036c:	00000617          	auipc	a2,0x0
  800370:	62c60613          	addi	a2,a2,1580 # 800998 <error_string+0x1b8>
  800374:	85a6                	mv	a1,s1
  800376:	854a                	mv	a0,s2
  800378:	1cc000ef          	jal	ra,800544 <printfmt>
  80037c:	b54d                	j	80021e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80037e:	000ab603          	ld	a2,0(s5)
  800382:	0aa1                	addi	s5,s5,8
  800384:	1a060163          	beqz	a2,800526 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800388:	00160413          	addi	s0,a2,1
  80038c:	15b05763          	blez	s11,8004da <vprintfmt+0x2f6>
  800390:	02d00593          	li	a1,45
  800394:	10b79d63          	bne	a5,a1,8004ae <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800398:	00064783          	lbu	a5,0(a2)
  80039c:	0007851b          	sext.w	a0,a5
  8003a0:	c905                	beqz	a0,8003d0 <vprintfmt+0x1ec>
  8003a2:	000cc563          	bltz	s9,8003ac <vprintfmt+0x1c8>
  8003a6:	3cfd                	addiw	s9,s9,-1
  8003a8:	036c8263          	beq	s9,s6,8003cc <vprintfmt+0x1e8>
                    putch('?', putdat);
  8003ac:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ae:	14098f63          	beqz	s3,80050c <vprintfmt+0x328>
  8003b2:	3781                	addiw	a5,a5,-32
  8003b4:	14fbfc63          	bgeu	s7,a5,80050c <vprintfmt+0x328>
                    putch('?', putdat);
  8003b8:	03f00513          	li	a0,63
  8003bc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003be:	0405                	addi	s0,s0,1
  8003c0:	fff44783          	lbu	a5,-1(s0)
  8003c4:	3dfd                	addiw	s11,s11,-1
  8003c6:	0007851b          	sext.w	a0,a5
  8003ca:	fd61                	bnez	a0,8003a2 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003cc:	e5b059e3          	blez	s11,80021e <vprintfmt+0x3a>
  8003d0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003d2:	85a6                	mv	a1,s1
  8003d4:	02000513          	li	a0,32
  8003d8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003da:	e40d82e3          	beqz	s11,80021e <vprintfmt+0x3a>
  8003de:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e0:	85a6                	mv	a1,s1
  8003e2:	02000513          	li	a0,32
  8003e6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e8:	fe0d94e3          	bnez	s11,8003d0 <vprintfmt+0x1ec>
  8003ec:	bd0d                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ee:	4705                	li	a4,1
  8003f0:	008a8593          	addi	a1,s5,8
  8003f4:	01074463          	blt	a4,a6,8003fc <vprintfmt+0x218>
    else if (lflag) {
  8003f8:	0e080863          	beqz	a6,8004e8 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003fc:	000ab603          	ld	a2,0(s5)
  800400:	46a1                	li	a3,8
  800402:	8aae                	mv	s5,a1
  800404:	a839                	j	800422 <vprintfmt+0x23e>
            putch('0', putdat);
  800406:	03000513          	li	a0,48
  80040a:	85a6                	mv	a1,s1
  80040c:	e03e                	sd	a5,0(sp)
  80040e:	9902                	jalr	s2
            putch('x', putdat);
  800410:	85a6                	mv	a1,s1
  800412:	07800513          	li	a0,120
  800416:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800418:	0aa1                	addi	s5,s5,8
  80041a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80041e:	6782                	ld	a5,0(sp)
  800420:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800422:	2781                	sext.w	a5,a5
  800424:	876e                	mv	a4,s11
  800426:	85a6                	mv	a1,s1
  800428:	854a                	mv	a0,s2
  80042a:	d4fff0ef          	jal	ra,800178 <printnum>
            break;
  80042e:	bbc5                	j	80021e <vprintfmt+0x3a>
            lflag ++;
  800430:	00144603          	lbu	a2,1(s0)
  800434:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800436:	846a                	mv	s0,s10
            goto reswitch;
  800438:	b515                	j	80025c <vprintfmt+0x78>
            goto reswitch;
  80043a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80043e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800440:	846a                	mv	s0,s10
            goto reswitch;
  800442:	bd29                	j	80025c <vprintfmt+0x78>
            putch(ch, putdat);
  800444:	85a6                	mv	a1,s1
  800446:	02500513          	li	a0,37
  80044a:	9902                	jalr	s2
            break;
  80044c:	bbc9                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  80044e:	4705                	li	a4,1
  800450:	008a8593          	addi	a1,s5,8
  800454:	01074463          	blt	a4,a6,80045c <vprintfmt+0x278>
    else if (lflag) {
  800458:	08080d63          	beqz	a6,8004f2 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  80045c:	000ab603          	ld	a2,0(s5)
  800460:	46a9                	li	a3,10
  800462:	8aae                	mv	s5,a1
  800464:	bf7d                	j	800422 <vprintfmt+0x23e>
            putch('%', putdat);
  800466:	85a6                	mv	a1,s1
  800468:	02500513          	li	a0,37
  80046c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80046e:	fff44703          	lbu	a4,-1(s0)
  800472:	02500793          	li	a5,37
  800476:	8d22                	mv	s10,s0
  800478:	daf703e3          	beq	a4,a5,80021e <vprintfmt+0x3a>
  80047c:	02500713          	li	a4,37
  800480:	1d7d                	addi	s10,s10,-1
  800482:	fffd4783          	lbu	a5,-1(s10)
  800486:	fee79de3          	bne	a5,a4,800480 <vprintfmt+0x29c>
  80048a:	bb51                	j	80021e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80048c:	00000617          	auipc	a2,0x0
  800490:	4fc60613          	addi	a2,a2,1276 # 800988 <error_string+0x1a8>
  800494:	85a6                	mv	a1,s1
  800496:	854a                	mv	a0,s2
  800498:	0ac000ef          	jal	ra,800544 <printfmt>
  80049c:	b349                	j	80021e <vprintfmt+0x3a>
                p = "(null)";
  80049e:	00000617          	auipc	a2,0x0
  8004a2:	4e260613          	addi	a2,a2,1250 # 800980 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004a6:	00000417          	auipc	s0,0x0
  8004aa:	4db40413          	addi	s0,s0,1243 # 800981 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ae:	8532                	mv	a0,a2
  8004b0:	85e6                	mv	a1,s9
  8004b2:	e032                	sd	a2,0(sp)
  8004b4:	e43e                	sd	a5,8(sp)
  8004b6:	c9dff0ef          	jal	ra,800152 <strnlen>
  8004ba:	40ad8dbb          	subw	s11,s11,a0
  8004be:	6602                	ld	a2,0(sp)
  8004c0:	01b05d63          	blez	s11,8004da <vprintfmt+0x2f6>
  8004c4:	67a2                	ld	a5,8(sp)
  8004c6:	2781                	sext.w	a5,a5
  8004c8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ca:	6522                	ld	a0,8(sp)
  8004cc:	85a6                	mv	a1,s1
  8004ce:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004d2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d4:	6602                	ld	a2,0(sp)
  8004d6:	fe0d9ae3          	bnez	s11,8004ca <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004da:	00064783          	lbu	a5,0(a2)
  8004de:	0007851b          	sext.w	a0,a5
  8004e2:	ec0510e3          	bnez	a0,8003a2 <vprintfmt+0x1be>
  8004e6:	bb25                	j	80021e <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004e8:	000ae603          	lwu	a2,0(s5)
  8004ec:	46a1                	li	a3,8
  8004ee:	8aae                	mv	s5,a1
  8004f0:	bf0d                	j	800422 <vprintfmt+0x23e>
  8004f2:	000ae603          	lwu	a2,0(s5)
  8004f6:	46a9                	li	a3,10
  8004f8:	8aae                	mv	s5,a1
  8004fa:	b725                	j	800422 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004fc:	000aa403          	lw	s0,0(s5)
  800500:	bd35                	j	80033c <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800502:	000ae603          	lwu	a2,0(s5)
  800506:	46c1                	li	a3,16
  800508:	8aae                	mv	s5,a1
  80050a:	bf21                	j	800422 <vprintfmt+0x23e>
                    putch(ch, putdat);
  80050c:	9902                	jalr	s2
  80050e:	bd45                	j	8003be <vprintfmt+0x1da>
                putch('-', putdat);
  800510:	85a6                	mv	a1,s1
  800512:	02d00513          	li	a0,45
  800516:	e03e                	sd	a5,0(sp)
  800518:	9902                	jalr	s2
                num = -(long long)num;
  80051a:	8ace                	mv	s5,s3
  80051c:	40800633          	neg	a2,s0
  800520:	46a9                	li	a3,10
  800522:	6782                	ld	a5,0(sp)
  800524:	bdfd                	j	800422 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800526:	01b05663          	blez	s11,800532 <vprintfmt+0x34e>
  80052a:	02d00693          	li	a3,45
  80052e:	f6d798e3          	bne	a5,a3,80049e <vprintfmt+0x2ba>
  800532:	00000417          	auipc	s0,0x0
  800536:	44f40413          	addi	s0,s0,1103 # 800981 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80053a:	02800513          	li	a0,40
  80053e:	02800793          	li	a5,40
  800542:	b585                	j	8003a2 <vprintfmt+0x1be>

0000000000800544 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800544:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800546:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	ec06                	sd	ra,24(sp)
  800550:	f83a                	sd	a4,48(sp)
  800552:	fc3e                	sd	a5,56(sp)
  800554:	e0c2                	sd	a6,64(sp)
  800556:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800558:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055a:	c8bff0ef          	jal	ra,8001e4 <vprintfmt>
}
  80055e:	60e2                	ld	ra,24(sp)
  800560:	6161                	addi	sp,sp,80
  800562:	8082                	ret

0000000000800564 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800564:	1101                	addi	sp,sp,-32
  800566:	ec06                	sd	ra,24(sp)
  800568:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  80056a:	b63ff0ef          	jal	ra,8000cc <fork>
  80056e:	c169                	beqz	a0,800630 <main+0xcc>
  800570:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  800572:	0aa05063          	blez	a0,800612 <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800576:	4581                	li	a1,0
  800578:	557d                	li	a0,-1
  80057a:	b55ff0ef          	jal	ra,8000ce <waitpid>
  80057e:	c93d                	beqz	a0,8005f4 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  800580:	458d                	li	a1,3
  800582:	05fa                	slli	a1,a1,0x1e
  800584:	8522                	mv	a0,s0
  800586:	b49ff0ef          	jal	ra,8000ce <waitpid>
  80058a:	c531                	beqz	a0,8005d6 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  80058c:	006c                	addi	a1,sp,12
  80058e:	8522                	mv	a0,s0
  800590:	b3fff0ef          	jal	ra,8000ce <waitpid>
  800594:	e115                	bnez	a0,8005b8 <main+0x54>
  800596:	4732                	lw	a4,12(sp)
  800598:	67b1                	lui	a5,0xc
  80059a:	eaf78793          	addi	a5,a5,-337 # beaf <__panic-0x7f4171>
  80059e:	00f71d63          	bne	a4,a5,8005b8 <main+0x54>
    cprintf("badarg pass.\n");
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	4b650513          	addi	a0,a0,1206 # 800a58 <error_string+0x278>
  8005aa:	b69ff0ef          	jal	ra,800112 <cprintf>
    return 0;
}
  8005ae:	60e2                	ld	ra,24(sp)
  8005b0:	6442                	ld	s0,16(sp)
  8005b2:	4501                	li	a0,0
  8005b4:	6105                	addi	sp,sp,32
  8005b6:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005b8:	00000697          	auipc	a3,0x0
  8005bc:	46868693          	addi	a3,a3,1128 # 800a20 <error_string+0x240>
  8005c0:	00000617          	auipc	a2,0x0
  8005c4:	3f860613          	addi	a2,a2,1016 # 8009b8 <error_string+0x1d8>
  8005c8:	45c9                	li	a1,18
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	40650513          	addi	a0,a0,1030 # 8009d0 <error_string+0x1f0>
  8005d2:	a4fff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005d6:	00000697          	auipc	a3,0x0
  8005da:	42268693          	addi	a3,a3,1058 # 8009f8 <error_string+0x218>
  8005de:	00000617          	auipc	a2,0x0
  8005e2:	3da60613          	addi	a2,a2,986 # 8009b8 <error_string+0x1d8>
  8005e6:	45c5                	li	a1,17
  8005e8:	00000517          	auipc	a0,0x0
  8005ec:	3e850513          	addi	a0,a0,1000 # 8009d0 <error_string+0x1f0>
  8005f0:	a31ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8005f4:	00000697          	auipc	a3,0x0
  8005f8:	3ec68693          	addi	a3,a3,1004 # 8009e0 <error_string+0x200>
  8005fc:	00000617          	auipc	a2,0x0
  800600:	3bc60613          	addi	a2,a2,956 # 8009b8 <error_string+0x1d8>
  800604:	45c1                	li	a1,16
  800606:	00000517          	auipc	a0,0x0
  80060a:	3ca50513          	addi	a0,a0,970 # 8009d0 <error_string+0x1f0>
  80060e:	a13ff0ef          	jal	ra,800020 <__panic>
    assert(pid > 0);
  800612:	00000697          	auipc	a3,0x0
  800616:	39e68693          	addi	a3,a3,926 # 8009b0 <error_string+0x1d0>
  80061a:	00000617          	auipc	a2,0x0
  80061e:	39e60613          	addi	a2,a2,926 # 8009b8 <error_string+0x1d8>
  800622:	45bd                	li	a1,15
  800624:	00000517          	auipc	a0,0x0
  800628:	3ac50513          	addi	a0,a0,940 # 8009d0 <error_string+0x1f0>
  80062c:	9f5ff0ef          	jal	ra,800020 <__panic>
        cprintf("fork ok.\n");
  800630:	00000517          	auipc	a0,0x0
  800634:	37050513          	addi	a0,a0,880 # 8009a0 <error_string+0x1c0>
  800638:	adbff0ef          	jal	ra,800112 <cprintf>
  80063c:	4429                	li	s0,10
            yield();
  80063e:	347d                	addiw	s0,s0,-1
  800640:	a91ff0ef          	jal	ra,8000d0 <yield>
        for (i = 0; i < 10; i ++) {
  800644:	fc6d                	bnez	s0,80063e <main+0xda>
        exit(0xbeaf);
  800646:	6531                	lui	a0,0xc
  800648:	eaf50513          	addi	a0,a0,-337 # beaf <__panic-0x7f4171>
  80064c:	a6bff0ef          	jal	ra,8000b6 <exit>
