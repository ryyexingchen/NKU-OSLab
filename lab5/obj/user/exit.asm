
obj/__user_exit.out：     文件格式 elf64-littleriscv


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
  800032:	65250513          	addi	a0,a0,1618 # 800680 <main+0x116>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0d6000ef          	jal	ra,800118 <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0ae000ef          	jal	ra,8000f8 <vcprintf>
    cprintf("\n");
  80004e:	00001517          	auipc	a0,0x1
  800052:	9e250513          	addi	a0,a0,-1566 # 800a30 <error_string+0x220>
  800056:	0c2000ef          	jal	ra,800118 <cprintf>
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
  8000c2:	5e250513          	addi	a0,a0,1506 # 8006a0 <main+0x136>
  8000c6:	052000ef          	jal	ra,800118 <cprintf>
    while (1);
  8000ca:	a001                	j	8000ca <exit+0x14>

00000000008000cc <fork>:
}

int
fork(void) {
    return sys_fork();
  8000cc:	bfd1                	j	8000a0 <sys_fork>

00000000008000ce <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000ce:	4581                	li	a1,0
  8000d0:	4501                	li	a0,0
  8000d2:	bfc9                	j	8000a4 <sys_wait>

00000000008000d4 <waitpid>:
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

00000000008000d8 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000d8:	074000ef          	jal	ra,80014c <umain>
1:  j 1b
  8000dc:	a001                	j	8000dc <_start+0x4>

00000000008000de <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000de:	1141                	addi	sp,sp,-16
  8000e0:	e022                	sd	s0,0(sp)
  8000e2:	e406                	sd	ra,8(sp)
  8000e4:	842e                	mv	s0,a1
    sys_putc(c);
  8000e6:	fcbff0ef          	jal	ra,8000b0 <sys_putc>
    (*cnt) ++;
  8000ea:	401c                	lw	a5,0(s0)
}
  8000ec:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000ee:	2785                	addiw	a5,a5,1
  8000f0:	c01c                	sw	a5,0(s0)
}
  8000f2:	6402                	ld	s0,0(sp)
  8000f4:	0141                	addi	sp,sp,16
  8000f6:	8082                	ret

00000000008000f8 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000f8:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000fa:	86ae                	mv	a3,a1
  8000fc:	862a                	mv	a2,a0
  8000fe:	006c                	addi	a1,sp,12
  800100:	00000517          	auipc	a0,0x0
  800104:	fde50513          	addi	a0,a0,-34 # 8000de <cputch>
vcprintf(const char *fmt, va_list ap) {
  800108:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010c:	0de000ef          	jal	ra,8001ea <vprintfmt>
    return cnt;
}
  800110:	60e2                	ld	ra,24(sp)
  800112:	4532                	lw	a0,12(sp)
  800114:	6105                	addi	sp,sp,32
  800116:	8082                	ret

0000000000800118 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800118:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011a:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  80011e:	f42e                	sd	a1,40(sp)
  800120:	f832                	sd	a2,48(sp)
  800122:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800124:	862a                	mv	a2,a0
  800126:	004c                	addi	a1,sp,4
  800128:	00000517          	auipc	a0,0x0
  80012c:	fb650513          	addi	a0,a0,-74 # 8000de <cputch>
  800130:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800132:	ec06                	sd	ra,24(sp)
  800134:	e0ba                	sd	a4,64(sp)
  800136:	e4be                	sd	a5,72(sp)
  800138:	e8c2                	sd	a6,80(sp)
  80013a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  80013c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  80013e:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800140:	0aa000ef          	jal	ra,8001ea <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800144:	60e2                	ld	ra,24(sp)
  800146:	4512                	lw	a0,4(sp)
  800148:	6125                	addi	sp,sp,96
  80014a:	8082                	ret

000000000080014c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014c:	1141                	addi	sp,sp,-16
  80014e:	e406                	sd	ra,8(sp)
    int ret = main();
  800150:	41a000ef          	jal	ra,80056a <main>
    exit(ret);
  800154:	f63ff0ef          	jal	ra,8000b6 <exit>

0000000000800158 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800158:	c185                	beqz	a1,800178 <strnlen+0x20>
  80015a:	00054783          	lbu	a5,0(a0)
  80015e:	cf89                	beqz	a5,800178 <strnlen+0x20>
    size_t cnt = 0;
  800160:	4781                	li	a5,0
  800162:	a021                	j	80016a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800164:	00074703          	lbu	a4,0(a4)
  800168:	c711                	beqz	a4,800174 <strnlen+0x1c>
        cnt ++;
  80016a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80016c:	00f50733          	add	a4,a0,a5
  800170:	fef59ae3          	bne	a1,a5,800164 <strnlen+0xc>
    }
    return cnt;
}
  800174:	853e                	mv	a0,a5
  800176:	8082                	ret
    size_t cnt = 0;
  800178:	4781                	li	a5,0
}
  80017a:	853e                	mv	a0,a5
  80017c:	8082                	ret

000000000080017e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80017e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800184:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80018e:	f022                	sd	s0,32(sp)
  800190:	ec26                	sd	s1,24(sp)
  800192:	e84a                	sd	s2,16(sp)
  800194:	f406                	sd	ra,40(sp)
  800196:	e44e                	sd	s3,8(sp)
  800198:	84aa                	mv	s1,a0
  80019a:	892e                	mv	s2,a1
  80019c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001a0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001a2:	03067e63          	bgeu	a2,a6,8001de <printnum+0x60>
  8001a6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001a8:	00805763          	blez	s0,8001b6 <printnum+0x38>
  8001ac:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	854e                	mv	a0,s3
  8001b2:	9482                	jalr	s1
        while (-- width > 0)
  8001b4:	fc65                	bnez	s0,8001ac <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	1a02                	slli	s4,s4,0x20
  8001b8:	020a5a13          	srli	s4,s4,0x20
  8001bc:	00000797          	auipc	a5,0x0
  8001c0:	71c78793          	addi	a5,a5,1820 # 8008d8 <error_string+0xc8>
  8001c4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c8:	000a4503          	lbu	a0,0(s4)
}
  8001cc:	70a2                	ld	ra,40(sp)
  8001ce:	69a2                	ld	s3,8(sp)
  8001d0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d2:	85ca                	mv	a1,s2
  8001d4:	8326                	mv	t1,s1
}
  8001d6:	6942                	ld	s2,16(sp)
  8001d8:	64e2                	ld	s1,24(sp)
  8001da:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001dc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001de:	03065633          	divu	a2,a2,a6
  8001e2:	8722                	mv	a4,s0
  8001e4:	f9bff0ef          	jal	ra,80017e <printnum>
  8001e8:	b7f9                	j	8001b6 <printnum+0x38>

00000000008001ea <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ea:	7119                	addi	sp,sp,-128
  8001ec:	f4a6                	sd	s1,104(sp)
  8001ee:	f0ca                	sd	s2,96(sp)
  8001f0:	e8d2                	sd	s4,80(sp)
  8001f2:	e4d6                	sd	s5,72(sp)
  8001f4:	e0da                	sd	s6,64(sp)
  8001f6:	fc5e                	sd	s7,56(sp)
  8001f8:	f862                	sd	s8,48(sp)
  8001fa:	f06a                	sd	s10,32(sp)
  8001fc:	fc86                	sd	ra,120(sp)
  8001fe:	f8a2                	sd	s0,112(sp)
  800200:	ecce                	sd	s3,88(sp)
  800202:	f466                	sd	s9,40(sp)
  800204:	ec6e                	sd	s11,24(sp)
  800206:	892a                	mv	s2,a0
  800208:	84ae                	mv	s1,a1
  80020a:	8d32                	mv	s10,a2
  80020c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80020e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800210:	00000a17          	auipc	s4,0x0
  800214:	4a4a0a13          	addi	s4,s4,1188 # 8006b4 <main+0x14a>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800218:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80021c:	00000c17          	auipc	s8,0x0
  800220:	5f4c0c13          	addi	s8,s8,1524 # 800810 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800224:	000d4503          	lbu	a0,0(s10)
  800228:	02500793          	li	a5,37
  80022c:	001d0413          	addi	s0,s10,1
  800230:	00f50e63          	beq	a0,a5,80024c <vprintfmt+0x62>
            if (ch == '\0') {
  800234:	c521                	beqz	a0,80027c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800236:	02500993          	li	s3,37
  80023a:	a011                	j	80023e <vprintfmt+0x54>
            if (ch == '\0') {
  80023c:	c121                	beqz	a0,80027c <vprintfmt+0x92>
            putch(ch, putdat);
  80023e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800240:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800242:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800244:	fff44503          	lbu	a0,-1(s0)
  800248:	ff351ae3          	bne	a0,s3,80023c <vprintfmt+0x52>
  80024c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800250:	02000793          	li	a5,32
        lflag = altflag = 0;
  800254:	4981                	li	s3,0
  800256:	4801                	li	a6,0
        width = precision = -1;
  800258:	5cfd                	li	s9,-1
  80025a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80025c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800260:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800262:	fdd6069b          	addiw	a3,a2,-35
  800266:	0ff6f693          	andi	a3,a3,255
  80026a:	00140d13          	addi	s10,s0,1
  80026e:	1ed5ef63          	bltu	a1,a3,80046c <vprintfmt+0x282>
  800272:	068a                	slli	a3,a3,0x2
  800274:	96d2                	add	a3,a3,s4
  800276:	4294                	lw	a3,0(a3)
  800278:	96d2                	add	a3,a3,s4
  80027a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80027c:	70e6                	ld	ra,120(sp)
  80027e:	7446                	ld	s0,112(sp)
  800280:	74a6                	ld	s1,104(sp)
  800282:	7906                	ld	s2,96(sp)
  800284:	69e6                	ld	s3,88(sp)
  800286:	6a46                	ld	s4,80(sp)
  800288:	6aa6                	ld	s5,72(sp)
  80028a:	6b06                	ld	s6,64(sp)
  80028c:	7be2                	ld	s7,56(sp)
  80028e:	7c42                	ld	s8,48(sp)
  800290:	7ca2                	ld	s9,40(sp)
  800292:	7d02                	ld	s10,32(sp)
  800294:	6de2                	ld	s11,24(sp)
  800296:	6109                	addi	sp,sp,128
  800298:	8082                	ret
            padc = '-';
  80029a:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80029c:	00144603          	lbu	a2,1(s0)
  8002a0:	846a                	mv	s0,s10
  8002a2:	b7c1                	j	800262 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  8002a4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8002a8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002ac:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002ae:	846a                	mv	s0,s10
            if (width < 0)
  8002b0:	fa0dd9e3          	bgez	s11,800262 <vprintfmt+0x78>
                width = precision, precision = -1;
  8002b4:	8de6                	mv	s11,s9
  8002b6:	5cfd                	li	s9,-1
  8002b8:	b76d                	j	800262 <vprintfmt+0x78>
            if (width < 0)
  8002ba:	fffdc693          	not	a3,s11
  8002be:	96fd                	srai	a3,a3,0x3f
  8002c0:	00ddfdb3          	and	s11,s11,a3
  8002c4:	00144603          	lbu	a2,1(s0)
  8002c8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002ca:	846a                	mv	s0,s10
  8002cc:	bf59                	j	800262 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002ce:	4705                	li	a4,1
  8002d0:	008a8593          	addi	a1,s5,8
  8002d4:	01074463          	blt	a4,a6,8002dc <vprintfmt+0xf2>
    else if (lflag) {
  8002d8:	22080863          	beqz	a6,800508 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002dc:	000ab603          	ld	a2,0(s5)
  8002e0:	46c1                	li	a3,16
  8002e2:	8aae                	mv	s5,a1
  8002e4:	a291                	j	800428 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002e6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002ea:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ee:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002f0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002f4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002f8:	fad56ce3          	bltu	a0,a3,8002b0 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002fc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002fe:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800302:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800306:	0196873b          	addw	a4,a3,s9
  80030a:	0017171b          	slliw	a4,a4,0x1
  80030e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800312:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800316:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80031a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80031e:	fcd57fe3          	bgeu	a0,a3,8002fc <vprintfmt+0x112>
  800322:	b779                	j	8002b0 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800324:	000aa503          	lw	a0,0(s5)
  800328:	85a6                	mv	a1,s1
  80032a:	0aa1                	addi	s5,s5,8
  80032c:	9902                	jalr	s2
            break;
  80032e:	bddd                	j	800224 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800330:	4705                	li	a4,1
  800332:	008a8993          	addi	s3,s5,8
  800336:	01074463          	blt	a4,a6,80033e <vprintfmt+0x154>
    else if (lflag) {
  80033a:	1c080463          	beqz	a6,800502 <vprintfmt+0x318>
        return va_arg(*ap, long);
  80033e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800342:	1c044a63          	bltz	s0,800516 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800346:	8622                	mv	a2,s0
  800348:	8ace                	mv	s5,s3
  80034a:	46a9                	li	a3,10
  80034c:	a8f1                	j	800428 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  80034e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800352:	4761                	li	a4,24
            err = va_arg(ap, int);
  800354:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800356:	41f7d69b          	sraiw	a3,a5,0x1f
  80035a:	8fb5                	xor	a5,a5,a3
  80035c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800360:	12d74963          	blt	a4,a3,800492 <vprintfmt+0x2a8>
  800364:	00369793          	slli	a5,a3,0x3
  800368:	97e2                	add	a5,a5,s8
  80036a:	639c                	ld	a5,0(a5)
  80036c:	12078363          	beqz	a5,800492 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800370:	86be                	mv	a3,a5
  800372:	00000617          	auipc	a2,0x0
  800376:	65660613          	addi	a2,a2,1622 # 8009c8 <error_string+0x1b8>
  80037a:	85a6                	mv	a1,s1
  80037c:	854a                	mv	a0,s2
  80037e:	1cc000ef          	jal	ra,80054a <printfmt>
  800382:	b54d                	j	800224 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800384:	000ab603          	ld	a2,0(s5)
  800388:	0aa1                	addi	s5,s5,8
  80038a:	1a060163          	beqz	a2,80052c <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  80038e:	00160413          	addi	s0,a2,1
  800392:	15b05763          	blez	s11,8004e0 <vprintfmt+0x2f6>
  800396:	02d00593          	li	a1,45
  80039a:	10b79d63          	bne	a5,a1,8004b4 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039e:	00064783          	lbu	a5,0(a2)
  8003a2:	0007851b          	sext.w	a0,a5
  8003a6:	c905                	beqz	a0,8003d6 <vprintfmt+0x1ec>
  8003a8:	000cc563          	bltz	s9,8003b2 <vprintfmt+0x1c8>
  8003ac:	3cfd                	addiw	s9,s9,-1
  8003ae:	036c8263          	beq	s9,s6,8003d2 <vprintfmt+0x1e8>
                    putch('?', putdat);
  8003b2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b4:	14098f63          	beqz	s3,800512 <vprintfmt+0x328>
  8003b8:	3781                	addiw	a5,a5,-32
  8003ba:	14fbfc63          	bgeu	s7,a5,800512 <vprintfmt+0x328>
                    putch('?', putdat);
  8003be:	03f00513          	li	a0,63
  8003c2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c4:	0405                	addi	s0,s0,1
  8003c6:	fff44783          	lbu	a5,-1(s0)
  8003ca:	3dfd                	addiw	s11,s11,-1
  8003cc:	0007851b          	sext.w	a0,a5
  8003d0:	fd61                	bnez	a0,8003a8 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003d2:	e5b059e3          	blez	s11,800224 <vprintfmt+0x3a>
  8003d6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003d8:	85a6                	mv	a1,s1
  8003da:	02000513          	li	a0,32
  8003de:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e0:	e40d82e3          	beqz	s11,800224 <vprintfmt+0x3a>
  8003e4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e6:	85a6                	mv	a1,s1
  8003e8:	02000513          	li	a0,32
  8003ec:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ee:	fe0d94e3          	bnez	s11,8003d6 <vprintfmt+0x1ec>
  8003f2:	bd0d                	j	800224 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f4:	4705                	li	a4,1
  8003f6:	008a8593          	addi	a1,s5,8
  8003fa:	01074463          	blt	a4,a6,800402 <vprintfmt+0x218>
    else if (lflag) {
  8003fe:	0e080863          	beqz	a6,8004ee <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  800402:	000ab603          	ld	a2,0(s5)
  800406:	46a1                	li	a3,8
  800408:	8aae                	mv	s5,a1
  80040a:	a839                	j	800428 <vprintfmt+0x23e>
            putch('0', putdat);
  80040c:	03000513          	li	a0,48
  800410:	85a6                	mv	a1,s1
  800412:	e03e                	sd	a5,0(sp)
  800414:	9902                	jalr	s2
            putch('x', putdat);
  800416:	85a6                	mv	a1,s1
  800418:	07800513          	li	a0,120
  80041c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80041e:	0aa1                	addi	s5,s5,8
  800420:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800424:	6782                	ld	a5,0(sp)
  800426:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800428:	2781                	sext.w	a5,a5
  80042a:	876e                	mv	a4,s11
  80042c:	85a6                	mv	a1,s1
  80042e:	854a                	mv	a0,s2
  800430:	d4fff0ef          	jal	ra,80017e <printnum>
            break;
  800434:	bbc5                	j	800224 <vprintfmt+0x3a>
            lflag ++;
  800436:	00144603          	lbu	a2,1(s0)
  80043a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80043c:	846a                	mv	s0,s10
            goto reswitch;
  80043e:	b515                	j	800262 <vprintfmt+0x78>
            goto reswitch;
  800440:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800444:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800446:	846a                	mv	s0,s10
            goto reswitch;
  800448:	bd29                	j	800262 <vprintfmt+0x78>
            putch(ch, putdat);
  80044a:	85a6                	mv	a1,s1
  80044c:	02500513          	li	a0,37
  800450:	9902                	jalr	s2
            break;
  800452:	bbc9                	j	800224 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800454:	4705                	li	a4,1
  800456:	008a8593          	addi	a1,s5,8
  80045a:	01074463          	blt	a4,a6,800462 <vprintfmt+0x278>
    else if (lflag) {
  80045e:	08080d63          	beqz	a6,8004f8 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800462:	000ab603          	ld	a2,0(s5)
  800466:	46a9                	li	a3,10
  800468:	8aae                	mv	s5,a1
  80046a:	bf7d                	j	800428 <vprintfmt+0x23e>
            putch('%', putdat);
  80046c:	85a6                	mv	a1,s1
  80046e:	02500513          	li	a0,37
  800472:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800474:	fff44703          	lbu	a4,-1(s0)
  800478:	02500793          	li	a5,37
  80047c:	8d22                	mv	s10,s0
  80047e:	daf703e3          	beq	a4,a5,800224 <vprintfmt+0x3a>
  800482:	02500713          	li	a4,37
  800486:	1d7d                	addi	s10,s10,-1
  800488:	fffd4783          	lbu	a5,-1(s10)
  80048c:	fee79de3          	bne	a5,a4,800486 <vprintfmt+0x29c>
  800490:	bb51                	j	800224 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800492:	00000617          	auipc	a2,0x0
  800496:	52660613          	addi	a2,a2,1318 # 8009b8 <error_string+0x1a8>
  80049a:	85a6                	mv	a1,s1
  80049c:	854a                	mv	a0,s2
  80049e:	0ac000ef          	jal	ra,80054a <printfmt>
  8004a2:	b349                	j	800224 <vprintfmt+0x3a>
                p = "(null)";
  8004a4:	00000617          	auipc	a2,0x0
  8004a8:	50c60613          	addi	a2,a2,1292 # 8009b0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004ac:	00000417          	auipc	s0,0x0
  8004b0:	50540413          	addi	s0,s0,1285 # 8009b1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b4:	8532                	mv	a0,a2
  8004b6:	85e6                	mv	a1,s9
  8004b8:	e032                	sd	a2,0(sp)
  8004ba:	e43e                	sd	a5,8(sp)
  8004bc:	c9dff0ef          	jal	ra,800158 <strnlen>
  8004c0:	40ad8dbb          	subw	s11,s11,a0
  8004c4:	6602                	ld	a2,0(sp)
  8004c6:	01b05d63          	blez	s11,8004e0 <vprintfmt+0x2f6>
  8004ca:	67a2                	ld	a5,8(sp)
  8004cc:	2781                	sext.w	a5,a5
  8004ce:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004d0:	6522                	ld	a0,8(sp)
  8004d2:	85a6                	mv	a1,s1
  8004d4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004d8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004da:	6602                	ld	a2,0(sp)
  8004dc:	fe0d9ae3          	bnez	s11,8004d0 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e0:	00064783          	lbu	a5,0(a2)
  8004e4:	0007851b          	sext.w	a0,a5
  8004e8:	ec0510e3          	bnez	a0,8003a8 <vprintfmt+0x1be>
  8004ec:	bb25                	j	800224 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004ee:	000ae603          	lwu	a2,0(s5)
  8004f2:	46a1                	li	a3,8
  8004f4:	8aae                	mv	s5,a1
  8004f6:	bf0d                	j	800428 <vprintfmt+0x23e>
  8004f8:	000ae603          	lwu	a2,0(s5)
  8004fc:	46a9                	li	a3,10
  8004fe:	8aae                	mv	s5,a1
  800500:	b725                	j	800428 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  800502:	000aa403          	lw	s0,0(s5)
  800506:	bd35                	j	800342 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800508:	000ae603          	lwu	a2,0(s5)
  80050c:	46c1                	li	a3,16
  80050e:	8aae                	mv	s5,a1
  800510:	bf21                	j	800428 <vprintfmt+0x23e>
                    putch(ch, putdat);
  800512:	9902                	jalr	s2
  800514:	bd45                	j	8003c4 <vprintfmt+0x1da>
                putch('-', putdat);
  800516:	85a6                	mv	a1,s1
  800518:	02d00513          	li	a0,45
  80051c:	e03e                	sd	a5,0(sp)
  80051e:	9902                	jalr	s2
                num = -(long long)num;
  800520:	8ace                	mv	s5,s3
  800522:	40800633          	neg	a2,s0
  800526:	46a9                	li	a3,10
  800528:	6782                	ld	a5,0(sp)
  80052a:	bdfd                	j	800428 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  80052c:	01b05663          	blez	s11,800538 <vprintfmt+0x34e>
  800530:	02d00693          	li	a3,45
  800534:	f6d798e3          	bne	a5,a3,8004a4 <vprintfmt+0x2ba>
  800538:	00000417          	auipc	s0,0x0
  80053c:	47940413          	addi	s0,s0,1145 # 8009b1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800540:	02800513          	li	a0,40
  800544:	02800793          	li	a5,40
  800548:	b585                	j	8003a8 <vprintfmt+0x1be>

000000000080054a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80054c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800550:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800552:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800554:	ec06                	sd	ra,24(sp)
  800556:	f83a                	sd	a4,48(sp)
  800558:	fc3e                	sd	a5,56(sp)
  80055a:	e0c2                	sd	a6,64(sp)
  80055c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80055e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800560:	c8bff0ef          	jal	ra,8001ea <vprintfmt>
}
  800564:	60e2                	ld	ra,24(sp)
  800566:	6161                	addi	sp,sp,80
  800568:	8082                	ret

000000000080056a <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  80056a:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  80056c:	00000517          	auipc	a0,0x0
  800570:	46450513          	addi	a0,a0,1124 # 8009d0 <error_string+0x1c0>
main(void) {
  800574:	ec06                	sd	ra,24(sp)
  800576:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800578:	ba1ff0ef          	jal	ra,800118 <cprintf>
    if ((pid = fork()) == 0) {
  80057c:	b51ff0ef          	jal	ra,8000cc <fork>
  800580:	c569                	beqz	a0,80064a <main+0xe0>
  800582:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  800584:	85aa                	mv	a1,a0
  800586:	00000517          	auipc	a0,0x0
  80058a:	48a50513          	addi	a0,a0,1162 # 800a10 <error_string+0x200>
  80058e:	b8bff0ef          	jal	ra,800118 <cprintf>
    }
    assert(pid > 0);
  800592:	08805d63          	blez	s0,80062c <main+0xc2>
    cprintf("I am the parent, waiting now..\n");
  800596:	00000517          	auipc	a0,0x0
  80059a:	4d250513          	addi	a0,a0,1234 # 800a68 <error_string+0x258>
  80059e:	b7bff0ef          	jal	ra,800118 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  8005a2:	006c                	addi	a1,sp,12
  8005a4:	8522                	mv	a0,s0
  8005a6:	b2fff0ef          	jal	ra,8000d4 <waitpid>
  8005aa:	e139                	bnez	a0,8005f0 <main+0x86>
  8005ac:	00001797          	auipc	a5,0x1
  8005b0:	a5478793          	addi	a5,a5,-1452 # 801000 <magic>
  8005b4:	4732                	lw	a4,12(sp)
  8005b6:	439c                	lw	a5,0(a5)
  8005b8:	02f71c63          	bne	a4,a5,8005f0 <main+0x86>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005bc:	006c                	addi	a1,sp,12
  8005be:	8522                	mv	a0,s0
  8005c0:	b15ff0ef          	jal	ra,8000d4 <waitpid>
  8005c4:	c529                	beqz	a0,80060e <main+0xa4>
  8005c6:	b09ff0ef          	jal	ra,8000ce <wait>
  8005ca:	c131                	beqz	a0,80060e <main+0xa4>
    cprintf("waitpid %d ok.\n", pid);
  8005cc:	85a2                	mv	a1,s0
  8005ce:	00000517          	auipc	a0,0x0
  8005d2:	51250513          	addi	a0,a0,1298 # 800ae0 <error_string+0x2d0>
  8005d6:	b43ff0ef          	jal	ra,800118 <cprintf>

    cprintf("exit pass.\n");
  8005da:	00000517          	auipc	a0,0x0
  8005de:	51650513          	addi	a0,a0,1302 # 800af0 <error_string+0x2e0>
  8005e2:	b37ff0ef          	jal	ra,800118 <cprintf>
    return 0;
}
  8005e6:	60e2                	ld	ra,24(sp)
  8005e8:	6442                	ld	s0,16(sp)
  8005ea:	4501                	li	a0,0
  8005ec:	6105                	addi	sp,sp,32
  8005ee:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005f0:	00000697          	auipc	a3,0x0
  8005f4:	49868693          	addi	a3,a3,1176 # 800a88 <error_string+0x278>
  8005f8:	00000617          	auipc	a2,0x0
  8005fc:	44860613          	addi	a2,a2,1096 # 800a40 <error_string+0x230>
  800600:	45ed                	li	a1,27
  800602:	00000517          	auipc	a0,0x0
  800606:	45650513          	addi	a0,a0,1110 # 800a58 <error_string+0x248>
  80060a:	a17ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  80060e:	00000697          	auipc	a3,0x0
  800612:	4aa68693          	addi	a3,a3,1194 # 800ab8 <error_string+0x2a8>
  800616:	00000617          	auipc	a2,0x0
  80061a:	42a60613          	addi	a2,a2,1066 # 800a40 <error_string+0x230>
  80061e:	45f1                	li	a1,28
  800620:	00000517          	auipc	a0,0x0
  800624:	43850513          	addi	a0,a0,1080 # 800a58 <error_string+0x248>
  800628:	9f9ff0ef          	jal	ra,800020 <__panic>
    assert(pid > 0);
  80062c:	00000697          	auipc	a3,0x0
  800630:	40c68693          	addi	a3,a3,1036 # 800a38 <error_string+0x228>
  800634:	00000617          	auipc	a2,0x0
  800638:	40c60613          	addi	a2,a2,1036 # 800a40 <error_string+0x230>
  80063c:	45e1                	li	a1,24
  80063e:	00000517          	auipc	a0,0x0
  800642:	41a50513          	addi	a0,a0,1050 # 800a58 <error_string+0x248>
  800646:	9dbff0ef          	jal	ra,800020 <__panic>
        cprintf("I am the child.\n");
  80064a:	00000517          	auipc	a0,0x0
  80064e:	3ae50513          	addi	a0,a0,942 # 8009f8 <error_string+0x1e8>
  800652:	ac7ff0ef          	jal	ra,800118 <cprintf>
        yield();
  800656:	a81ff0ef          	jal	ra,8000d6 <yield>
        yield();
  80065a:	a7dff0ef          	jal	ra,8000d6 <yield>
        yield();
  80065e:	a79ff0ef          	jal	ra,8000d6 <yield>
        yield();
  800662:	a75ff0ef          	jal	ra,8000d6 <yield>
        yield();
  800666:	a71ff0ef          	jal	ra,8000d6 <yield>
        yield();
  80066a:	a6dff0ef          	jal	ra,8000d6 <yield>
        yield();
  80066e:	a69ff0ef          	jal	ra,8000d6 <yield>
        exit(magic);
  800672:	00001797          	auipc	a5,0x1
  800676:	98e78793          	addi	a5,a5,-1650 # 801000 <magic>
  80067a:	4388                	lw	a0,0(a5)
  80067c:	a3bff0ef          	jal	ra,8000b6 <exit>
