
obj/__user_spin.out：     文件格式 elf64-littleriscv


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
  800032:	60a50513          	addi	a0,a0,1546 # 800638 <main+0xcc>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0d8000ef          	jal	ra,80011a <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0b0000ef          	jal	ra,8000fa <vcprintf>
    cprintf("\n");
  80004e:	00000517          	auipc	a0,0x0
  800052:	60a50513          	addi	a0,a0,1546 # 800658 <main+0xec>
  800056:	0c4000ef          	jal	ra,80011a <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	060000ef          	jal	ra,8000bc <exit>

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

00000000008000b0 <sys_kill>:
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  8000b0:	85aa                	mv	a1,a0
  8000b2:	4531                	li	a0,12
  8000b4:	b775                	j	800060 <syscall>

00000000008000b6 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b6:	85aa                	mv	a1,a0
  8000b8:	4579                	li	a0,30
  8000ba:	b75d                	j	800060 <syscall>

00000000008000bc <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000bc:	1141                	addi	sp,sp,-16
  8000be:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c0:	fdbff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c4:	00000517          	auipc	a0,0x0
  8000c8:	59c50513          	addi	a0,a0,1436 # 800660 <main+0xf4>
  8000cc:	04e000ef          	jal	ra,80011a <cprintf>
    while (1);
  8000d0:	a001                	j	8000d0 <exit+0x14>

00000000008000d2 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d2:	b7f9                	j	8000a0 <sys_fork>

00000000008000d4 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d4:	bfc1                	j	8000a4 <sys_wait>

00000000008000d6 <yield>:
}

void
yield(void) {
    sys_yield();
  8000d6:	bfd9                	j	8000ac <sys_yield>

00000000008000d8 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000d8:	bfe1                	j	8000b0 <sys_kill>

00000000008000da <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000da:	074000ef          	jal	ra,80014e <umain>
1:  j 1b
  8000de:	a001                	j	8000de <_start+0x4>

00000000008000e0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e0:	1141                	addi	sp,sp,-16
  8000e2:	e022                	sd	s0,0(sp)
  8000e4:	e406                	sd	ra,8(sp)
  8000e6:	842e                	mv	s0,a1
    sys_putc(c);
  8000e8:	fcfff0ef          	jal	ra,8000b6 <sys_putc>
    (*cnt) ++;
  8000ec:	401c                	lw	a5,0(s0)
}
  8000ee:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f0:	2785                	addiw	a5,a5,1
  8000f2:	c01c                	sw	a5,0(s0)
}
  8000f4:	6402                	ld	s0,0(sp)
  8000f6:	0141                	addi	sp,sp,16
  8000f8:	8082                	ret

00000000008000fa <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000fa:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000fc:	86ae                	mv	a3,a1
  8000fe:	862a                	mv	a2,a0
  800100:	006c                	addi	a1,sp,12
  800102:	00000517          	auipc	a0,0x0
  800106:	fde50513          	addi	a0,a0,-34 # 8000e0 <cputch>
vcprintf(const char *fmt, va_list ap) {
  80010a:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010c:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010e:	0de000ef          	jal	ra,8001ec <vprintfmt>
    return cnt;
}
  800112:	60e2                	ld	ra,24(sp)
  800114:	4532                	lw	a0,12(sp)
  800116:	6105                	addi	sp,sp,32
  800118:	8082                	ret

000000000080011a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80011a:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011c:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800120:	f42e                	sd	a1,40(sp)
  800122:	f832                	sd	a2,48(sp)
  800124:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800126:	862a                	mv	a2,a0
  800128:	004c                	addi	a1,sp,4
  80012a:	00000517          	auipc	a0,0x0
  80012e:	fb650513          	addi	a0,a0,-74 # 8000e0 <cputch>
  800132:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800134:	ec06                	sd	ra,24(sp)
  800136:	e0ba                	sd	a4,64(sp)
  800138:	e4be                	sd	a5,72(sp)
  80013a:	e8c2                	sd	a6,80(sp)
  80013c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  80013e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800140:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800142:	0aa000ef          	jal	ra,8001ec <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800146:	60e2                	ld	ra,24(sp)
  800148:	4512                	lw	a0,4(sp)
  80014a:	6125                	addi	sp,sp,96
  80014c:	8082                	ret

000000000080014e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014e:	1141                	addi	sp,sp,-16
  800150:	e406                	sd	ra,8(sp)
    int ret = main();
  800152:	41a000ef          	jal	ra,80056c <main>
    exit(ret);
  800156:	f67ff0ef          	jal	ra,8000bc <exit>

000000000080015a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80015a:	c185                	beqz	a1,80017a <strnlen+0x20>
  80015c:	00054783          	lbu	a5,0(a0)
  800160:	cf89                	beqz	a5,80017a <strnlen+0x20>
    size_t cnt = 0;
  800162:	4781                	li	a5,0
  800164:	a021                	j	80016c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800166:	00074703          	lbu	a4,0(a4)
  80016a:	c711                	beqz	a4,800176 <strnlen+0x1c>
        cnt ++;
  80016c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80016e:	00f50733          	add	a4,a0,a5
  800172:	fef59ae3          	bne	a1,a5,800166 <strnlen+0xc>
    }
    return cnt;
}
  800176:	853e                	mv	a0,a5
  800178:	8082                	ret
    size_t cnt = 0;
  80017a:	4781                	li	a5,0
}
  80017c:	853e                	mv	a0,a5
  80017e:	8082                	ret

0000000000800180 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800180:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800184:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800186:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800190:	f022                	sd	s0,32(sp)
  800192:	ec26                	sd	s1,24(sp)
  800194:	e84a                	sd	s2,16(sp)
  800196:	f406                	sd	ra,40(sp)
  800198:	e44e                	sd	s3,8(sp)
  80019a:	84aa                	mv	s1,a0
  80019c:	892e                	mv	s2,a1
  80019e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001a2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001a4:	03067e63          	bgeu	a2,a6,8001e0 <printnum+0x60>
  8001a8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001aa:	00805763          	blez	s0,8001b8 <printnum+0x38>
  8001ae:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b0:	85ca                	mv	a1,s2
  8001b2:	854e                	mv	a0,s3
  8001b4:	9482                	jalr	s1
        while (-- width > 0)
  8001b6:	fc65                	bnez	s0,8001ae <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	1a02                	slli	s4,s4,0x20
  8001ba:	020a5a13          	srli	s4,s4,0x20
  8001be:	00000797          	auipc	a5,0x0
  8001c2:	6da78793          	addi	a5,a5,1754 # 800898 <error_string+0xc8>
  8001c6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ca:	000a4503          	lbu	a0,0(s4)
}
  8001ce:	70a2                	ld	ra,40(sp)
  8001d0:	69a2                	ld	s3,8(sp)
  8001d2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d4:	85ca                	mv	a1,s2
  8001d6:	8326                	mv	t1,s1
}
  8001d8:	6942                	ld	s2,16(sp)
  8001da:	64e2                	ld	s1,24(sp)
  8001dc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001de:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001e0:	03065633          	divu	a2,a2,a6
  8001e4:	8722                	mv	a4,s0
  8001e6:	f9bff0ef          	jal	ra,800180 <printnum>
  8001ea:	b7f9                	j	8001b8 <printnum+0x38>

00000000008001ec <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ec:	7119                	addi	sp,sp,-128
  8001ee:	f4a6                	sd	s1,104(sp)
  8001f0:	f0ca                	sd	s2,96(sp)
  8001f2:	e8d2                	sd	s4,80(sp)
  8001f4:	e4d6                	sd	s5,72(sp)
  8001f6:	e0da                	sd	s6,64(sp)
  8001f8:	fc5e                	sd	s7,56(sp)
  8001fa:	f862                	sd	s8,48(sp)
  8001fc:	f06a                	sd	s10,32(sp)
  8001fe:	fc86                	sd	ra,120(sp)
  800200:	f8a2                	sd	s0,112(sp)
  800202:	ecce                	sd	s3,88(sp)
  800204:	f466                	sd	s9,40(sp)
  800206:	ec6e                	sd	s11,24(sp)
  800208:	892a                	mv	s2,a0
  80020a:	84ae                	mv	s1,a1
  80020c:	8d32                	mv	s10,a2
  80020e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800210:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800212:	00000a17          	auipc	s4,0x0
  800216:	462a0a13          	addi	s4,s4,1122 # 800674 <main+0x108>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80021a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80021e:	00000c17          	auipc	s8,0x0
  800222:	5b2c0c13          	addi	s8,s8,1458 # 8007d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	000d4503          	lbu	a0,0(s10)
  80022a:	02500793          	li	a5,37
  80022e:	001d0413          	addi	s0,s10,1
  800232:	00f50e63          	beq	a0,a5,80024e <vprintfmt+0x62>
            if (ch == '\0') {
  800236:	c521                	beqz	a0,80027e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800238:	02500993          	li	s3,37
  80023c:	a011                	j	800240 <vprintfmt+0x54>
            if (ch == '\0') {
  80023e:	c121                	beqz	a0,80027e <vprintfmt+0x92>
            putch(ch, putdat);
  800240:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800242:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800244:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800246:	fff44503          	lbu	a0,-1(s0)
  80024a:	ff351ae3          	bne	a0,s3,80023e <vprintfmt+0x52>
  80024e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800252:	02000793          	li	a5,32
        lflag = altflag = 0;
  800256:	4981                	li	s3,0
  800258:	4801                	li	a6,0
        width = precision = -1;
  80025a:	5cfd                	li	s9,-1
  80025c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80025e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800262:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800264:	fdd6069b          	addiw	a3,a2,-35
  800268:	0ff6f693          	andi	a3,a3,255
  80026c:	00140d13          	addi	s10,s0,1
  800270:	1ed5ef63          	bltu	a1,a3,80046e <vprintfmt+0x282>
  800274:	068a                	slli	a3,a3,0x2
  800276:	96d2                	add	a3,a3,s4
  800278:	4294                	lw	a3,0(a3)
  80027a:	96d2                	add	a3,a3,s4
  80027c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80027e:	70e6                	ld	ra,120(sp)
  800280:	7446                	ld	s0,112(sp)
  800282:	74a6                	ld	s1,104(sp)
  800284:	7906                	ld	s2,96(sp)
  800286:	69e6                	ld	s3,88(sp)
  800288:	6a46                	ld	s4,80(sp)
  80028a:	6aa6                	ld	s5,72(sp)
  80028c:	6b06                	ld	s6,64(sp)
  80028e:	7be2                	ld	s7,56(sp)
  800290:	7c42                	ld	s8,48(sp)
  800292:	7ca2                	ld	s9,40(sp)
  800294:	7d02                	ld	s10,32(sp)
  800296:	6de2                	ld	s11,24(sp)
  800298:	6109                	addi	sp,sp,128
  80029a:	8082                	ret
            padc = '-';
  80029c:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80029e:	00144603          	lbu	a2,1(s0)
  8002a2:	846a                	mv	s0,s10
  8002a4:	b7c1                	j	800264 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  8002a6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8002aa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002ae:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002b0:	846a                	mv	s0,s10
            if (width < 0)
  8002b2:	fa0dd9e3          	bgez	s11,800264 <vprintfmt+0x78>
                width = precision, precision = -1;
  8002b6:	8de6                	mv	s11,s9
  8002b8:	5cfd                	li	s9,-1
  8002ba:	b76d                	j	800264 <vprintfmt+0x78>
            if (width < 0)
  8002bc:	fffdc693          	not	a3,s11
  8002c0:	96fd                	srai	a3,a3,0x3f
  8002c2:	00ddfdb3          	and	s11,s11,a3
  8002c6:	00144603          	lbu	a2,1(s0)
  8002ca:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002cc:	846a                	mv	s0,s10
  8002ce:	bf59                	j	800264 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002d0:	4705                	li	a4,1
  8002d2:	008a8593          	addi	a1,s5,8
  8002d6:	01074463          	blt	a4,a6,8002de <vprintfmt+0xf2>
    else if (lflag) {
  8002da:	22080863          	beqz	a6,80050a <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002de:	000ab603          	ld	a2,0(s5)
  8002e2:	46c1                	li	a3,16
  8002e4:	8aae                	mv	s5,a1
  8002e6:	a291                	j	80042a <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002e8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002ec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002f0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002f2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002fa:	fad56ce3          	bltu	a0,a3,8002b2 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002fe:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800300:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800304:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800308:	0196873b          	addw	a4,a3,s9
  80030c:	0017171b          	slliw	a4,a4,0x1
  800310:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800314:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800318:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80031c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800320:	fcd57fe3          	bgeu	a0,a3,8002fe <vprintfmt+0x112>
  800324:	b779                	j	8002b2 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800326:	000aa503          	lw	a0,0(s5)
  80032a:	85a6                	mv	a1,s1
  80032c:	0aa1                	addi	s5,s5,8
  80032e:	9902                	jalr	s2
            break;
  800330:	bddd                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800332:	4705                	li	a4,1
  800334:	008a8993          	addi	s3,s5,8
  800338:	01074463          	blt	a4,a6,800340 <vprintfmt+0x154>
    else if (lflag) {
  80033c:	1c080463          	beqz	a6,800504 <vprintfmt+0x318>
        return va_arg(*ap, long);
  800340:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800344:	1c044a63          	bltz	s0,800518 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800348:	8622                	mv	a2,s0
  80034a:	8ace                	mv	s5,s3
  80034c:	46a9                	li	a3,10
  80034e:	a8f1                	j	80042a <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800350:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800354:	4761                	li	a4,24
            err = va_arg(ap, int);
  800356:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800358:	41f7d69b          	sraiw	a3,a5,0x1f
  80035c:	8fb5                	xor	a5,a5,a3
  80035e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800362:	12d74963          	blt	a4,a3,800494 <vprintfmt+0x2a8>
  800366:	00369793          	slli	a5,a3,0x3
  80036a:	97e2                	add	a5,a5,s8
  80036c:	639c                	ld	a5,0(a5)
  80036e:	12078363          	beqz	a5,800494 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800372:	86be                	mv	a3,a5
  800374:	00000617          	auipc	a2,0x0
  800378:	61460613          	addi	a2,a2,1556 # 800988 <error_string+0x1b8>
  80037c:	85a6                	mv	a1,s1
  80037e:	854a                	mv	a0,s2
  800380:	1cc000ef          	jal	ra,80054c <printfmt>
  800384:	b54d                	j	800226 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800386:	000ab603          	ld	a2,0(s5)
  80038a:	0aa1                	addi	s5,s5,8
  80038c:	1a060163          	beqz	a2,80052e <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800390:	00160413          	addi	s0,a2,1
  800394:	15b05763          	blez	s11,8004e2 <vprintfmt+0x2f6>
  800398:	02d00593          	li	a1,45
  80039c:	10b79d63          	bne	a5,a1,8004b6 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	00064783          	lbu	a5,0(a2)
  8003a4:	0007851b          	sext.w	a0,a5
  8003a8:	c905                	beqz	a0,8003d8 <vprintfmt+0x1ec>
  8003aa:	000cc563          	bltz	s9,8003b4 <vprintfmt+0x1c8>
  8003ae:	3cfd                	addiw	s9,s9,-1
  8003b0:	036c8263          	beq	s9,s6,8003d4 <vprintfmt+0x1e8>
                    putch('?', putdat);
  8003b4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b6:	14098f63          	beqz	s3,800514 <vprintfmt+0x328>
  8003ba:	3781                	addiw	a5,a5,-32
  8003bc:	14fbfc63          	bgeu	s7,a5,800514 <vprintfmt+0x328>
                    putch('?', putdat);
  8003c0:	03f00513          	li	a0,63
  8003c4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c6:	0405                	addi	s0,s0,1
  8003c8:	fff44783          	lbu	a5,-1(s0)
  8003cc:	3dfd                	addiw	s11,s11,-1
  8003ce:	0007851b          	sext.w	a0,a5
  8003d2:	fd61                	bnez	a0,8003aa <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003d4:	e5b059e3          	blez	s11,800226 <vprintfmt+0x3a>
  8003d8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003da:	85a6                	mv	a1,s1
  8003dc:	02000513          	li	a0,32
  8003e0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e2:	e40d82e3          	beqz	s11,800226 <vprintfmt+0x3a>
  8003e6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e8:	85a6                	mv	a1,s1
  8003ea:	02000513          	li	a0,32
  8003ee:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003f0:	fe0d94e3          	bnez	s11,8003d8 <vprintfmt+0x1ec>
  8003f4:	bd0d                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f6:	4705                	li	a4,1
  8003f8:	008a8593          	addi	a1,s5,8
  8003fc:	01074463          	blt	a4,a6,800404 <vprintfmt+0x218>
    else if (lflag) {
  800400:	0e080863          	beqz	a6,8004f0 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  800404:	000ab603          	ld	a2,0(s5)
  800408:	46a1                	li	a3,8
  80040a:	8aae                	mv	s5,a1
  80040c:	a839                	j	80042a <vprintfmt+0x23e>
            putch('0', putdat);
  80040e:	03000513          	li	a0,48
  800412:	85a6                	mv	a1,s1
  800414:	e03e                	sd	a5,0(sp)
  800416:	9902                	jalr	s2
            putch('x', putdat);
  800418:	85a6                	mv	a1,s1
  80041a:	07800513          	li	a0,120
  80041e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800420:	0aa1                	addi	s5,s5,8
  800422:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800426:	6782                	ld	a5,0(sp)
  800428:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80042a:	2781                	sext.w	a5,a5
  80042c:	876e                	mv	a4,s11
  80042e:	85a6                	mv	a1,s1
  800430:	854a                	mv	a0,s2
  800432:	d4fff0ef          	jal	ra,800180 <printnum>
            break;
  800436:	bbc5                	j	800226 <vprintfmt+0x3a>
            lflag ++;
  800438:	00144603          	lbu	a2,1(s0)
  80043c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80043e:	846a                	mv	s0,s10
            goto reswitch;
  800440:	b515                	j	800264 <vprintfmt+0x78>
            goto reswitch;
  800442:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800446:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800448:	846a                	mv	s0,s10
            goto reswitch;
  80044a:	bd29                	j	800264 <vprintfmt+0x78>
            putch(ch, putdat);
  80044c:	85a6                	mv	a1,s1
  80044e:	02500513          	li	a0,37
  800452:	9902                	jalr	s2
            break;
  800454:	bbc9                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800456:	4705                	li	a4,1
  800458:	008a8593          	addi	a1,s5,8
  80045c:	01074463          	blt	a4,a6,800464 <vprintfmt+0x278>
    else if (lflag) {
  800460:	08080d63          	beqz	a6,8004fa <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800464:	000ab603          	ld	a2,0(s5)
  800468:	46a9                	li	a3,10
  80046a:	8aae                	mv	s5,a1
  80046c:	bf7d                	j	80042a <vprintfmt+0x23e>
            putch('%', putdat);
  80046e:	85a6                	mv	a1,s1
  800470:	02500513          	li	a0,37
  800474:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800476:	fff44703          	lbu	a4,-1(s0)
  80047a:	02500793          	li	a5,37
  80047e:	8d22                	mv	s10,s0
  800480:	daf703e3          	beq	a4,a5,800226 <vprintfmt+0x3a>
  800484:	02500713          	li	a4,37
  800488:	1d7d                	addi	s10,s10,-1
  80048a:	fffd4783          	lbu	a5,-1(s10)
  80048e:	fee79de3          	bne	a5,a4,800488 <vprintfmt+0x29c>
  800492:	bb51                	j	800226 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800494:	00000617          	auipc	a2,0x0
  800498:	4e460613          	addi	a2,a2,1252 # 800978 <error_string+0x1a8>
  80049c:	85a6                	mv	a1,s1
  80049e:	854a                	mv	a0,s2
  8004a0:	0ac000ef          	jal	ra,80054c <printfmt>
  8004a4:	b349                	j	800226 <vprintfmt+0x3a>
                p = "(null)";
  8004a6:	00000617          	auipc	a2,0x0
  8004aa:	4ca60613          	addi	a2,a2,1226 # 800970 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004ae:	00000417          	auipc	s0,0x0
  8004b2:	4c340413          	addi	s0,s0,1219 # 800971 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b6:	8532                	mv	a0,a2
  8004b8:	85e6                	mv	a1,s9
  8004ba:	e032                	sd	a2,0(sp)
  8004bc:	e43e                	sd	a5,8(sp)
  8004be:	c9dff0ef          	jal	ra,80015a <strnlen>
  8004c2:	40ad8dbb          	subw	s11,s11,a0
  8004c6:	6602                	ld	a2,0(sp)
  8004c8:	01b05d63          	blez	s11,8004e2 <vprintfmt+0x2f6>
  8004cc:	67a2                	ld	a5,8(sp)
  8004ce:	2781                	sext.w	a5,a5
  8004d0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004d2:	6522                	ld	a0,8(sp)
  8004d4:	85a6                	mv	a1,s1
  8004d6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004da:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004dc:	6602                	ld	a2,0(sp)
  8004de:	fe0d9ae3          	bnez	s11,8004d2 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e2:	00064783          	lbu	a5,0(a2)
  8004e6:	0007851b          	sext.w	a0,a5
  8004ea:	ec0510e3          	bnez	a0,8003aa <vprintfmt+0x1be>
  8004ee:	bb25                	j	800226 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004f0:	000ae603          	lwu	a2,0(s5)
  8004f4:	46a1                	li	a3,8
  8004f6:	8aae                	mv	s5,a1
  8004f8:	bf0d                	j	80042a <vprintfmt+0x23e>
  8004fa:	000ae603          	lwu	a2,0(s5)
  8004fe:	46a9                	li	a3,10
  800500:	8aae                	mv	s5,a1
  800502:	b725                	j	80042a <vprintfmt+0x23e>
        return va_arg(*ap, int);
  800504:	000aa403          	lw	s0,0(s5)
  800508:	bd35                	j	800344 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  80050a:	000ae603          	lwu	a2,0(s5)
  80050e:	46c1                	li	a3,16
  800510:	8aae                	mv	s5,a1
  800512:	bf21                	j	80042a <vprintfmt+0x23e>
                    putch(ch, putdat);
  800514:	9902                	jalr	s2
  800516:	bd45                	j	8003c6 <vprintfmt+0x1da>
                putch('-', putdat);
  800518:	85a6                	mv	a1,s1
  80051a:	02d00513          	li	a0,45
  80051e:	e03e                	sd	a5,0(sp)
  800520:	9902                	jalr	s2
                num = -(long long)num;
  800522:	8ace                	mv	s5,s3
  800524:	40800633          	neg	a2,s0
  800528:	46a9                	li	a3,10
  80052a:	6782                	ld	a5,0(sp)
  80052c:	bdfd                	j	80042a <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  80052e:	01b05663          	blez	s11,80053a <vprintfmt+0x34e>
  800532:	02d00693          	li	a3,45
  800536:	f6d798e3          	bne	a5,a3,8004a6 <vprintfmt+0x2ba>
  80053a:	00000417          	auipc	s0,0x0
  80053e:	43740413          	addi	s0,s0,1079 # 800971 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800542:	02800513          	li	a0,40
  800546:	02800793          	li	a5,40
  80054a:	b585                	j	8003aa <vprintfmt+0x1be>

000000000080054c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80054e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800552:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800554:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800556:	ec06                	sd	ra,24(sp)
  800558:	f83a                	sd	a4,48(sp)
  80055a:	fc3e                	sd	a5,56(sp)
  80055c:	e0c2                	sd	a6,64(sp)
  80055e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800560:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800562:	c8bff0ef          	jal	ra,8001ec <vprintfmt>
}
  800566:	60e2                	ld	ra,24(sp)
  800568:	6161                	addi	sp,sp,80
  80056a:	8082                	ret

000000000080056c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80056c:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80056e:	00000517          	auipc	a0,0x0
  800572:	42250513          	addi	a0,a0,1058 # 800990 <error_string+0x1c0>
main(void) {
  800576:	e406                	sd	ra,8(sp)
  800578:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  80057a:	ba1ff0ef          	jal	ra,80011a <cprintf>
    if ((pid = fork()) == 0) {
  80057e:	b55ff0ef          	jal	ra,8000d2 <fork>
  800582:	e901                	bnez	a0,800592 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  800584:	00000517          	auipc	a0,0x0
  800588:	43450513          	addi	a0,a0,1076 # 8009b8 <error_string+0x1e8>
  80058c:	b8fff0ef          	jal	ra,80011a <cprintf>
        while (1);
  800590:	a001                	j	800590 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  800592:	842a                	mv	s0,a0
  800594:	00000517          	auipc	a0,0x0
  800598:	44450513          	addi	a0,a0,1092 # 8009d8 <error_string+0x208>
  80059c:	b7fff0ef          	jal	ra,80011a <cprintf>

    yield();
  8005a0:	b37ff0ef          	jal	ra,8000d6 <yield>
    yield();
  8005a4:	b33ff0ef          	jal	ra,8000d6 <yield>
    yield();
  8005a8:	b2fff0ef          	jal	ra,8000d6 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005ac:	00000517          	auipc	a0,0x0
  8005b0:	45450513          	addi	a0,a0,1108 # 800a00 <error_string+0x230>
  8005b4:	b67ff0ef          	jal	ra,80011a <cprintf>

    assert((ret = kill(pid)) == 0);
  8005b8:	8522                	mv	a0,s0
  8005ba:	b1fff0ef          	jal	ra,8000d8 <kill>
  8005be:	ed31                	bnez	a0,80061a <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005c0:	4581                	li	a1,0
  8005c2:	00000517          	auipc	a0,0x0
  8005c6:	4a650513          	addi	a0,a0,1190 # 800a68 <error_string+0x298>
  8005ca:	b51ff0ef          	jal	ra,80011a <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ce:	4581                	li	a1,0
  8005d0:	8522                	mv	a0,s0
  8005d2:	b03ff0ef          	jal	ra,8000d4 <waitpid>
  8005d6:	e11d                	bnez	a0,8005fc <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005d8:	4581                	li	a1,0
  8005da:	00000517          	auipc	a0,0x0
  8005de:	4c650513          	addi	a0,a0,1222 # 800aa0 <error_string+0x2d0>
  8005e2:	b39ff0ef          	jal	ra,80011a <cprintf>

    cprintf("spin may pass.\n");
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	4d250513          	addi	a0,a0,1234 # 800ab8 <error_string+0x2e8>
  8005ee:	b2dff0ef          	jal	ra,80011a <cprintf>
    return 0;
}
  8005f2:	60a2                	ld	ra,8(sp)
  8005f4:	6402                	ld	s0,0(sp)
  8005f6:	4501                	li	a0,0
  8005f8:	0141                	addi	sp,sp,16
  8005fa:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005fc:	00000697          	auipc	a3,0x0
  800600:	48468693          	addi	a3,a3,1156 # 800a80 <error_string+0x2b0>
  800604:	00000617          	auipc	a2,0x0
  800608:	43c60613          	addi	a2,a2,1084 # 800a40 <error_string+0x270>
  80060c:	45dd                	li	a1,23
  80060e:	00000517          	auipc	a0,0x0
  800612:	44a50513          	addi	a0,a0,1098 # 800a58 <error_string+0x288>
  800616:	a0bff0ef          	jal	ra,800020 <__panic>
    assert((ret = kill(pid)) == 0);
  80061a:	00000697          	auipc	a3,0x0
  80061e:	40e68693          	addi	a3,a3,1038 # 800a28 <error_string+0x258>
  800622:	00000617          	auipc	a2,0x0
  800626:	41e60613          	addi	a2,a2,1054 # 800a40 <error_string+0x270>
  80062a:	45d1                	li	a1,20
  80062c:	00000517          	auipc	a0,0x0
  800630:	42c50513          	addi	a0,a0,1068 # 800a58 <error_string+0x288>
  800634:	9edff0ef          	jal	ra,800020 <__panic>
