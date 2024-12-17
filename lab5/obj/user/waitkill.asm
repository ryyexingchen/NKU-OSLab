
obj/__user_waitkill.out：     文件格式 elf64-littleriscv


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
  800032:	68250513          	addi	a0,a0,1666 # 8006b0 <main+0xb2>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0de000ef          	jal	ra,800120 <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0b6000ef          	jal	ra,800100 <vcprintf>
    cprintf("\n");
  80004e:	00001517          	auipc	a0,0x1
  800052:	9ba50513          	addi	a0,a0,-1606 # 800a08 <error_string+0x1c8>
  800056:	0ca000ef          	jal	ra,800120 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	064000ef          	jal	ra,8000c0 <exit>

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

00000000008000b6 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b6:	4549                	li	a0,18
  8000b8:	b765                	j	800060 <syscall>

00000000008000ba <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000ba:	85aa                	mv	a1,a0
  8000bc:	4579                	li	a0,30
  8000be:	b74d                	j	800060 <syscall>

00000000008000c0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c4:	fd7ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c8:	00000517          	auipc	a0,0x0
  8000cc:	60850513          	addi	a0,a0,1544 # 8006d0 <main+0xd2>
  8000d0:	050000ef          	jal	ra,800120 <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d6:	b7e9                	j	8000a0 <sys_fork>

00000000008000d8 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d8:	b7f1                	j	8000a4 <sys_wait>

00000000008000da <yield>:
}

void
yield(void) {
    sys_yield();
  8000da:	bfc9                	j	8000ac <sys_yield>

00000000008000dc <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000dc:	bfd1                	j	8000b0 <sys_kill>

00000000008000de <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000de:	bfe1                	j	8000b6 <sys_getpid>

00000000008000e0 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000e0:	074000ef          	jal	ra,800154 <umain>
1:  j 1b
  8000e4:	a001                	j	8000e4 <_start+0x4>

00000000008000e6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e6:	1141                	addi	sp,sp,-16
  8000e8:	e022                	sd	s0,0(sp)
  8000ea:	e406                	sd	ra,8(sp)
  8000ec:	842e                	mv	s0,a1
    sys_putc(c);
  8000ee:	fcdff0ef          	jal	ra,8000ba <sys_putc>
    (*cnt) ++;
  8000f2:	401c                	lw	a5,0(s0)
}
  8000f4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f6:	2785                	addiw	a5,a5,1
  8000f8:	c01c                	sw	a5,0(s0)
}
  8000fa:	6402                	ld	s0,0(sp)
  8000fc:	0141                	addi	sp,sp,16
  8000fe:	8082                	ret

0000000000800100 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800100:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800102:	86ae                	mv	a3,a1
  800104:	862a                	mv	a2,a0
  800106:	006c                	addi	a1,sp,12
  800108:	00000517          	auipc	a0,0x0
  80010c:	fde50513          	addi	a0,a0,-34 # 8000e6 <cputch>
vcprintf(const char *fmt, va_list ap) {
  800110:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800112:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800114:	0de000ef          	jal	ra,8001f2 <vprintfmt>
    return cnt;
}
  800118:	60e2                	ld	ra,24(sp)
  80011a:	4532                	lw	a0,12(sp)
  80011c:	6105                	addi	sp,sp,32
  80011e:	8082                	ret

0000000000800120 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800120:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800122:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800126:	f42e                	sd	a1,40(sp)
  800128:	f832                	sd	a2,48(sp)
  80012a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012c:	862a                	mv	a2,a0
  80012e:	004c                	addi	a1,sp,4
  800130:	00000517          	auipc	a0,0x0
  800134:	fb650513          	addi	a0,a0,-74 # 8000e6 <cputch>
  800138:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80013a:	ec06                	sd	ra,24(sp)
  80013c:	e0ba                	sd	a4,64(sp)
  80013e:	e4be                	sd	a5,72(sp)
  800140:	e8c2                	sd	a6,80(sp)
  800142:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800144:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800146:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800148:	0aa000ef          	jal	ra,8001f2 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80014c:	60e2                	ld	ra,24(sp)
  80014e:	4512                	lw	a0,4(sp)
  800150:	6125                	addi	sp,sp,96
  800152:	8082                	ret

0000000000800154 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800154:	1141                	addi	sp,sp,-16
  800156:	e406                	sd	ra,8(sp)
    int ret = main();
  800158:	4a6000ef          	jal	ra,8005fe <main>
    exit(ret);
  80015c:	f65ff0ef          	jal	ra,8000c0 <exit>

0000000000800160 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800160:	c185                	beqz	a1,800180 <strnlen+0x20>
  800162:	00054783          	lbu	a5,0(a0)
  800166:	cf89                	beqz	a5,800180 <strnlen+0x20>
    size_t cnt = 0;
  800168:	4781                	li	a5,0
  80016a:	a021                	j	800172 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80016c:	00074703          	lbu	a4,0(a4)
  800170:	c711                	beqz	a4,80017c <strnlen+0x1c>
        cnt ++;
  800172:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800174:	00f50733          	add	a4,a0,a5
  800178:	fef59ae3          	bne	a1,a5,80016c <strnlen+0xc>
    }
    return cnt;
}
  80017c:	853e                	mv	a0,a5
  80017e:	8082                	ret
    size_t cnt = 0;
  800180:	4781                	li	a5,0
}
  800182:	853e                	mv	a0,a5
  800184:	8082                	ret

0000000000800186 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800186:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80018c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800190:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800192:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800196:	f022                	sd	s0,32(sp)
  800198:	ec26                	sd	s1,24(sp)
  80019a:	e84a                	sd	s2,16(sp)
  80019c:	f406                	sd	ra,40(sp)
  80019e:	e44e                	sd	s3,8(sp)
  8001a0:	84aa                	mv	s1,a0
  8001a2:	892e                	mv	s2,a1
  8001a4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001a8:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001aa:	03067e63          	bgeu	a2,a6,8001e6 <printnum+0x60>
  8001ae:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001b0:	00805763          	blez	s0,8001be <printnum+0x38>
  8001b4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b6:	85ca                	mv	a1,s2
  8001b8:	854e                	mv	a0,s3
  8001ba:	9482                	jalr	s1
        while (-- width > 0)
  8001bc:	fc65                	bnez	s0,8001b4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001be:	1a02                	slli	s4,s4,0x20
  8001c0:	020a5a13          	srli	s4,s4,0x20
  8001c4:	00000797          	auipc	a5,0x0
  8001c8:	74478793          	addi	a5,a5,1860 # 800908 <error_string+0xc8>
  8001cc:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ce:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d0:	000a4503          	lbu	a0,0(s4)
}
  8001d4:	70a2                	ld	ra,40(sp)
  8001d6:	69a2                	ld	s3,8(sp)
  8001d8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001da:	85ca                	mv	a1,s2
  8001dc:	8326                	mv	t1,s1
}
  8001de:	6942                	ld	s2,16(sp)
  8001e0:	64e2                	ld	s1,24(sp)
  8001e2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001e4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001e6:	03065633          	divu	a2,a2,a6
  8001ea:	8722                	mv	a4,s0
  8001ec:	f9bff0ef          	jal	ra,800186 <printnum>
  8001f0:	b7f9                	j	8001be <printnum+0x38>

00000000008001f2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001f2:	7119                	addi	sp,sp,-128
  8001f4:	f4a6                	sd	s1,104(sp)
  8001f6:	f0ca                	sd	s2,96(sp)
  8001f8:	e8d2                	sd	s4,80(sp)
  8001fa:	e4d6                	sd	s5,72(sp)
  8001fc:	e0da                	sd	s6,64(sp)
  8001fe:	fc5e                	sd	s7,56(sp)
  800200:	f862                	sd	s8,48(sp)
  800202:	f06a                	sd	s10,32(sp)
  800204:	fc86                	sd	ra,120(sp)
  800206:	f8a2                	sd	s0,112(sp)
  800208:	ecce                	sd	s3,88(sp)
  80020a:	f466                	sd	s9,40(sp)
  80020c:	ec6e                	sd	s11,24(sp)
  80020e:	892a                	mv	s2,a0
  800210:	84ae                	mv	s1,a1
  800212:	8d32                	mv	s10,a2
  800214:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800216:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	00000a17          	auipc	s4,0x0
  80021c:	4cca0a13          	addi	s4,s4,1228 # 8006e4 <main+0xe6>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800220:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800224:	00000c17          	auipc	s8,0x0
  800228:	61cc0c13          	addi	s8,s8,1564 # 800840 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022c:	000d4503          	lbu	a0,0(s10)
  800230:	02500793          	li	a5,37
  800234:	001d0413          	addi	s0,s10,1
  800238:	00f50e63          	beq	a0,a5,800254 <vprintfmt+0x62>
            if (ch == '\0') {
  80023c:	c521                	beqz	a0,800284 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023e:	02500993          	li	s3,37
  800242:	a011                	j	800246 <vprintfmt+0x54>
            if (ch == '\0') {
  800244:	c121                	beqz	a0,800284 <vprintfmt+0x92>
            putch(ch, putdat);
  800246:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800248:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80024a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80024c:	fff44503          	lbu	a0,-1(s0)
  800250:	ff351ae3          	bne	a0,s3,800244 <vprintfmt+0x52>
  800254:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800258:	02000793          	li	a5,32
        lflag = altflag = 0;
  80025c:	4981                	li	s3,0
  80025e:	4801                	li	a6,0
        width = precision = -1;
  800260:	5cfd                	li	s9,-1
  800262:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800264:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800268:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80026a:	fdd6069b          	addiw	a3,a2,-35
  80026e:	0ff6f693          	andi	a3,a3,255
  800272:	00140d13          	addi	s10,s0,1
  800276:	1ed5ef63          	bltu	a1,a3,800474 <vprintfmt+0x282>
  80027a:	068a                	slli	a3,a3,0x2
  80027c:	96d2                	add	a3,a3,s4
  80027e:	4294                	lw	a3,0(a3)
  800280:	96d2                	add	a3,a3,s4
  800282:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800284:	70e6                	ld	ra,120(sp)
  800286:	7446                	ld	s0,112(sp)
  800288:	74a6                	ld	s1,104(sp)
  80028a:	7906                	ld	s2,96(sp)
  80028c:	69e6                	ld	s3,88(sp)
  80028e:	6a46                	ld	s4,80(sp)
  800290:	6aa6                	ld	s5,72(sp)
  800292:	6b06                	ld	s6,64(sp)
  800294:	7be2                	ld	s7,56(sp)
  800296:	7c42                	ld	s8,48(sp)
  800298:	7ca2                	ld	s9,40(sp)
  80029a:	7d02                	ld	s10,32(sp)
  80029c:	6de2                	ld	s11,24(sp)
  80029e:	6109                	addi	sp,sp,128
  8002a0:	8082                	ret
            padc = '-';
  8002a2:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002a4:	00144603          	lbu	a2,1(s0)
  8002a8:	846a                	mv	s0,s10
  8002aa:	b7c1                	j	80026a <vprintfmt+0x78>
            precision = va_arg(ap, int);
  8002ac:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8002b0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002b4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002b6:	846a                	mv	s0,s10
            if (width < 0)
  8002b8:	fa0dd9e3          	bgez	s11,80026a <vprintfmt+0x78>
                width = precision, precision = -1;
  8002bc:	8de6                	mv	s11,s9
  8002be:	5cfd                	li	s9,-1
  8002c0:	b76d                	j	80026a <vprintfmt+0x78>
            if (width < 0)
  8002c2:	fffdc693          	not	a3,s11
  8002c6:	96fd                	srai	a3,a3,0x3f
  8002c8:	00ddfdb3          	and	s11,s11,a3
  8002cc:	00144603          	lbu	a2,1(s0)
  8002d0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002d2:	846a                	mv	s0,s10
  8002d4:	bf59                	j	80026a <vprintfmt+0x78>
    if (lflag >= 2) {
  8002d6:	4705                	li	a4,1
  8002d8:	008a8593          	addi	a1,s5,8
  8002dc:	01074463          	blt	a4,a6,8002e4 <vprintfmt+0xf2>
    else if (lflag) {
  8002e0:	22080863          	beqz	a6,800510 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002e4:	000ab603          	ld	a2,0(s5)
  8002e8:	46c1                	li	a3,16
  8002ea:	8aae                	mv	s5,a1
  8002ec:	a291                	j	800430 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002ee:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002f2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002f6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002f8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002fc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800300:	fad56ce3          	bltu	a0,a3,8002b8 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  800304:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800306:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80030a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80030e:	0196873b          	addw	a4,a3,s9
  800312:	0017171b          	slliw	a4,a4,0x1
  800316:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80031a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80031e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800322:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800326:	fcd57fe3          	bgeu	a0,a3,800304 <vprintfmt+0x112>
  80032a:	b779                	j	8002b8 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  80032c:	000aa503          	lw	a0,0(s5)
  800330:	85a6                	mv	a1,s1
  800332:	0aa1                	addi	s5,s5,8
  800334:	9902                	jalr	s2
            break;
  800336:	bddd                	j	80022c <vprintfmt+0x3a>
    if (lflag >= 2) {
  800338:	4705                	li	a4,1
  80033a:	008a8993          	addi	s3,s5,8
  80033e:	01074463          	blt	a4,a6,800346 <vprintfmt+0x154>
    else if (lflag) {
  800342:	1c080463          	beqz	a6,80050a <vprintfmt+0x318>
        return va_arg(*ap, long);
  800346:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80034a:	1c044a63          	bltz	s0,80051e <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  80034e:	8622                	mv	a2,s0
  800350:	8ace                	mv	s5,s3
  800352:	46a9                	li	a3,10
  800354:	a8f1                	j	800430 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800356:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80035a:	4761                	li	a4,24
            err = va_arg(ap, int);
  80035c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80035e:	41f7d69b          	sraiw	a3,a5,0x1f
  800362:	8fb5                	xor	a5,a5,a3
  800364:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800368:	12d74963          	blt	a4,a3,80049a <vprintfmt+0x2a8>
  80036c:	00369793          	slli	a5,a3,0x3
  800370:	97e2                	add	a5,a5,s8
  800372:	639c                	ld	a5,0(a5)
  800374:	12078363          	beqz	a5,80049a <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800378:	86be                	mv	a3,a5
  80037a:	00000617          	auipc	a2,0x0
  80037e:	67e60613          	addi	a2,a2,1662 # 8009f8 <error_string+0x1b8>
  800382:	85a6                	mv	a1,s1
  800384:	854a                	mv	a0,s2
  800386:	1cc000ef          	jal	ra,800552 <printfmt>
  80038a:	b54d                	j	80022c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80038c:	000ab603          	ld	a2,0(s5)
  800390:	0aa1                	addi	s5,s5,8
  800392:	1a060163          	beqz	a2,800534 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800396:	00160413          	addi	s0,a2,1
  80039a:	15b05763          	blez	s11,8004e8 <vprintfmt+0x2f6>
  80039e:	02d00593          	li	a1,45
  8003a2:	10b79d63          	bne	a5,a1,8004bc <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a6:	00064783          	lbu	a5,0(a2)
  8003aa:	0007851b          	sext.w	a0,a5
  8003ae:	c905                	beqz	a0,8003de <vprintfmt+0x1ec>
  8003b0:	000cc563          	bltz	s9,8003ba <vprintfmt+0x1c8>
  8003b4:	3cfd                	addiw	s9,s9,-1
  8003b6:	036c8263          	beq	s9,s6,8003da <vprintfmt+0x1e8>
                    putch('?', putdat);
  8003ba:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003bc:	14098f63          	beqz	s3,80051a <vprintfmt+0x328>
  8003c0:	3781                	addiw	a5,a5,-32
  8003c2:	14fbfc63          	bgeu	s7,a5,80051a <vprintfmt+0x328>
                    putch('?', putdat);
  8003c6:	03f00513          	li	a0,63
  8003ca:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003cc:	0405                	addi	s0,s0,1
  8003ce:	fff44783          	lbu	a5,-1(s0)
  8003d2:	3dfd                	addiw	s11,s11,-1
  8003d4:	0007851b          	sext.w	a0,a5
  8003d8:	fd61                	bnez	a0,8003b0 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003da:	e5b059e3          	blez	s11,80022c <vprintfmt+0x3a>
  8003de:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e0:	85a6                	mv	a1,s1
  8003e2:	02000513          	li	a0,32
  8003e6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e8:	e40d82e3          	beqz	s11,80022c <vprintfmt+0x3a>
  8003ec:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ee:	85a6                	mv	a1,s1
  8003f0:	02000513          	li	a0,32
  8003f4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003f6:	fe0d94e3          	bnez	s11,8003de <vprintfmt+0x1ec>
  8003fa:	bd0d                	j	80022c <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003fc:	4705                	li	a4,1
  8003fe:	008a8593          	addi	a1,s5,8
  800402:	01074463          	blt	a4,a6,80040a <vprintfmt+0x218>
    else if (lflag) {
  800406:	0e080863          	beqz	a6,8004f6 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  80040a:	000ab603          	ld	a2,0(s5)
  80040e:	46a1                	li	a3,8
  800410:	8aae                	mv	s5,a1
  800412:	a839                	j	800430 <vprintfmt+0x23e>
            putch('0', putdat);
  800414:	03000513          	li	a0,48
  800418:	85a6                	mv	a1,s1
  80041a:	e03e                	sd	a5,0(sp)
  80041c:	9902                	jalr	s2
            putch('x', putdat);
  80041e:	85a6                	mv	a1,s1
  800420:	07800513          	li	a0,120
  800424:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800426:	0aa1                	addi	s5,s5,8
  800428:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80042c:	6782                	ld	a5,0(sp)
  80042e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800430:	2781                	sext.w	a5,a5
  800432:	876e                	mv	a4,s11
  800434:	85a6                	mv	a1,s1
  800436:	854a                	mv	a0,s2
  800438:	d4fff0ef          	jal	ra,800186 <printnum>
            break;
  80043c:	bbc5                	j	80022c <vprintfmt+0x3a>
            lflag ++;
  80043e:	00144603          	lbu	a2,1(s0)
  800442:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800444:	846a                	mv	s0,s10
            goto reswitch;
  800446:	b515                	j	80026a <vprintfmt+0x78>
            goto reswitch;
  800448:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80044c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80044e:	846a                	mv	s0,s10
            goto reswitch;
  800450:	bd29                	j	80026a <vprintfmt+0x78>
            putch(ch, putdat);
  800452:	85a6                	mv	a1,s1
  800454:	02500513          	li	a0,37
  800458:	9902                	jalr	s2
            break;
  80045a:	bbc9                	j	80022c <vprintfmt+0x3a>
    if (lflag >= 2) {
  80045c:	4705                	li	a4,1
  80045e:	008a8593          	addi	a1,s5,8
  800462:	01074463          	blt	a4,a6,80046a <vprintfmt+0x278>
    else if (lflag) {
  800466:	08080d63          	beqz	a6,800500 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  80046a:	000ab603          	ld	a2,0(s5)
  80046e:	46a9                	li	a3,10
  800470:	8aae                	mv	s5,a1
  800472:	bf7d                	j	800430 <vprintfmt+0x23e>
            putch('%', putdat);
  800474:	85a6                	mv	a1,s1
  800476:	02500513          	li	a0,37
  80047a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80047c:	fff44703          	lbu	a4,-1(s0)
  800480:	02500793          	li	a5,37
  800484:	8d22                	mv	s10,s0
  800486:	daf703e3          	beq	a4,a5,80022c <vprintfmt+0x3a>
  80048a:	02500713          	li	a4,37
  80048e:	1d7d                	addi	s10,s10,-1
  800490:	fffd4783          	lbu	a5,-1(s10)
  800494:	fee79de3          	bne	a5,a4,80048e <vprintfmt+0x29c>
  800498:	bb51                	j	80022c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80049a:	00000617          	auipc	a2,0x0
  80049e:	54e60613          	addi	a2,a2,1358 # 8009e8 <error_string+0x1a8>
  8004a2:	85a6                	mv	a1,s1
  8004a4:	854a                	mv	a0,s2
  8004a6:	0ac000ef          	jal	ra,800552 <printfmt>
  8004aa:	b349                	j	80022c <vprintfmt+0x3a>
                p = "(null)";
  8004ac:	00000617          	auipc	a2,0x0
  8004b0:	53460613          	addi	a2,a2,1332 # 8009e0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004b4:	00000417          	auipc	s0,0x0
  8004b8:	52d40413          	addi	s0,s0,1325 # 8009e1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004bc:	8532                	mv	a0,a2
  8004be:	85e6                	mv	a1,s9
  8004c0:	e032                	sd	a2,0(sp)
  8004c2:	e43e                	sd	a5,8(sp)
  8004c4:	c9dff0ef          	jal	ra,800160 <strnlen>
  8004c8:	40ad8dbb          	subw	s11,s11,a0
  8004cc:	6602                	ld	a2,0(sp)
  8004ce:	01b05d63          	blez	s11,8004e8 <vprintfmt+0x2f6>
  8004d2:	67a2                	ld	a5,8(sp)
  8004d4:	2781                	sext.w	a5,a5
  8004d6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004d8:	6522                	ld	a0,8(sp)
  8004da:	85a6                	mv	a1,s1
  8004dc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	6602                	ld	a2,0(sp)
  8004e4:	fe0d9ae3          	bnez	s11,8004d8 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	00064783          	lbu	a5,0(a2)
  8004ec:	0007851b          	sext.w	a0,a5
  8004f0:	ec0510e3          	bnez	a0,8003b0 <vprintfmt+0x1be>
  8004f4:	bb25                	j	80022c <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004f6:	000ae603          	lwu	a2,0(s5)
  8004fa:	46a1                	li	a3,8
  8004fc:	8aae                	mv	s5,a1
  8004fe:	bf0d                	j	800430 <vprintfmt+0x23e>
  800500:	000ae603          	lwu	a2,0(s5)
  800504:	46a9                	li	a3,10
  800506:	8aae                	mv	s5,a1
  800508:	b725                	j	800430 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  80050a:	000aa403          	lw	s0,0(s5)
  80050e:	bd35                	j	80034a <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800510:	000ae603          	lwu	a2,0(s5)
  800514:	46c1                	li	a3,16
  800516:	8aae                	mv	s5,a1
  800518:	bf21                	j	800430 <vprintfmt+0x23e>
                    putch(ch, putdat);
  80051a:	9902                	jalr	s2
  80051c:	bd45                	j	8003cc <vprintfmt+0x1da>
                putch('-', putdat);
  80051e:	85a6                	mv	a1,s1
  800520:	02d00513          	li	a0,45
  800524:	e03e                	sd	a5,0(sp)
  800526:	9902                	jalr	s2
                num = -(long long)num;
  800528:	8ace                	mv	s5,s3
  80052a:	40800633          	neg	a2,s0
  80052e:	46a9                	li	a3,10
  800530:	6782                	ld	a5,0(sp)
  800532:	bdfd                	j	800430 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800534:	01b05663          	blez	s11,800540 <vprintfmt+0x34e>
  800538:	02d00693          	li	a3,45
  80053c:	f6d798e3          	bne	a5,a3,8004ac <vprintfmt+0x2ba>
  800540:	00000417          	auipc	s0,0x0
  800544:	4a140413          	addi	s0,s0,1185 # 8009e1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800548:	02800513          	li	a0,40
  80054c:	02800793          	li	a5,40
  800550:	b585                	j	8003b0 <vprintfmt+0x1be>

0000000000800552 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800552:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800554:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800558:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80055c:	ec06                	sd	ra,24(sp)
  80055e:	f83a                	sd	a4,48(sp)
  800560:	fc3e                	sd	a5,56(sp)
  800562:	e0c2                	sd	a6,64(sp)
  800564:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800566:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800568:	c8bff0ef          	jal	ra,8001f2 <vprintfmt>
}
  80056c:	60e2                	ld	ra,24(sp)
  80056e:	6161                	addi	sp,sp,80
  800570:	8082                	ret

0000000000800572 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800572:	1141                	addi	sp,sp,-16
  800574:	e406                	sd	ra,8(sp)
    yield();
  800576:	b65ff0ef          	jal	ra,8000da <yield>
    yield();
  80057a:	b61ff0ef          	jal	ra,8000da <yield>
    yield();
  80057e:	b5dff0ef          	jal	ra,8000da <yield>
    yield();
  800582:	b59ff0ef          	jal	ra,8000da <yield>
    yield();
  800586:	b55ff0ef          	jal	ra,8000da <yield>
    yield();
}
  80058a:	60a2                	ld	ra,8(sp)
  80058c:	0141                	addi	sp,sp,16
    yield();
  80058e:	b6b1                	j	8000da <yield>

0000000000800590 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  800590:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  800592:	00000517          	auipc	a0,0x0
  800596:	46e50513          	addi	a0,a0,1134 # 800a00 <error_string+0x1c0>
loop(void) {
  80059a:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  80059c:	b85ff0ef          	jal	ra,800120 <cprintf>
    while (1);
  8005a0:	a001                	j	8005a0 <loop+0x10>

00000000008005a2 <work>:
}

void
work(void) {
  8005a2:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	4dc50513          	addi	a0,a0,1244 # 800a80 <error_string+0x240>
work(void) {
  8005ac:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005ae:	b73ff0ef          	jal	ra,800120 <cprintf>
    do_yield();
  8005b2:	fc1ff0ef          	jal	ra,800572 <do_yield>
    if (kill(parent) == 0) {
  8005b6:	00001797          	auipc	a5,0x1
  8005ba:	a4a78793          	addi	a5,a5,-1462 # 801000 <parent>
  8005be:	4388                	lw	a0,0(a5)
  8005c0:	b1dff0ef          	jal	ra,8000dc <kill>
  8005c4:	e10d                	bnez	a0,8005e6 <work+0x44>
        cprintf("kill parent ok.\n");
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	4ca50513          	addi	a0,a0,1226 # 800a90 <error_string+0x250>
  8005ce:	b53ff0ef          	jal	ra,800120 <cprintf>
        do_yield();
  8005d2:	fa1ff0ef          	jal	ra,800572 <do_yield>
        if (kill(pid1) == 0) {
  8005d6:	00001797          	auipc	a5,0x1
  8005da:	a3278793          	addi	a5,a5,-1486 # 801008 <pid1>
  8005de:	4388                	lw	a0,0(a5)
  8005e0:	afdff0ef          	jal	ra,8000dc <kill>
  8005e4:	c501                	beqz	a0,8005ec <work+0x4a>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005e6:	557d                	li	a0,-1
  8005e8:	ad9ff0ef          	jal	ra,8000c0 <exit>
            cprintf("kill child1 ok.\n");
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	4bc50513          	addi	a0,a0,1212 # 800aa8 <error_string+0x268>
  8005f4:	b2dff0ef          	jal	ra,800120 <cprintf>
            exit(0);
  8005f8:	4501                	li	a0,0
  8005fa:	ac7ff0ef          	jal	ra,8000c0 <exit>

00000000008005fe <main>:
}

int
main(void) {
  8005fe:	1141                	addi	sp,sp,-16
  800600:	e406                	sd	ra,8(sp)
  800602:	e022                	sd	s0,0(sp)
    parent = getpid();
  800604:	adbff0ef          	jal	ra,8000de <getpid>
  800608:	00001797          	auipc	a5,0x1
  80060c:	9ea7ac23          	sw	a0,-1544(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800610:	ac7ff0ef          	jal	ra,8000d6 <fork>
  800614:	00001797          	auipc	a5,0x1
  800618:	9ea7aa23          	sw	a0,-1548(a5) # 801008 <pid1>
  80061c:	c53d                	beqz	a0,80068a <main+0x8c>
        loop();
    }

    assert(pid1 > 0);
  80061e:	04a05663          	blez	a0,80066a <main+0x6c>

    if ((pid2 = fork()) == 0) {
  800622:	ab5ff0ef          	jal	ra,8000d6 <fork>
  800626:	00001797          	auipc	a5,0x1
  80062a:	9ca7af23          	sw	a0,-1570(a5) # 801004 <pid2>
  80062e:	cd3d                	beqz	a0,8006ac <main+0xae>
  800630:	00001417          	auipc	s0,0x1
  800634:	9d840413          	addi	s0,s0,-1576 # 801008 <pid1>
        work();
    }
    if (pid2 > 0) {
  800638:	04a05b63          	blez	a0,80068e <main+0x90>
        cprintf("wait child 1.\n");
  80063c:	00000517          	auipc	a0,0x0
  800640:	40c50513          	addi	a0,a0,1036 # 800a48 <error_string+0x208>
  800644:	addff0ef          	jal	ra,800120 <cprintf>
        waitpid(pid1, NULL);
  800648:	4008                	lw	a0,0(s0)
  80064a:	4581                	li	a1,0
  80064c:	a8dff0ef          	jal	ra,8000d8 <waitpid>
        panic("waitpid %d returns\n", pid1);
  800650:	4014                	lw	a3,0(s0)
  800652:	00000617          	auipc	a2,0x0
  800656:	40660613          	addi	a2,a2,1030 # 800a58 <error_string+0x218>
  80065a:	03400593          	li	a1,52
  80065e:	00000517          	auipc	a0,0x0
  800662:	3da50513          	addi	a0,a0,986 # 800a38 <error_string+0x1f8>
  800666:	9bbff0ef          	jal	ra,800020 <__panic>
    assert(pid1 > 0);
  80066a:	00000697          	auipc	a3,0x0
  80066e:	3a668693          	addi	a3,a3,934 # 800a10 <error_string+0x1d0>
  800672:	00000617          	auipc	a2,0x0
  800676:	3ae60613          	addi	a2,a2,942 # 800a20 <error_string+0x1e0>
  80067a:	02c00593          	li	a1,44
  80067e:	00000517          	auipc	a0,0x0
  800682:	3ba50513          	addi	a0,a0,954 # 800a38 <error_string+0x1f8>
  800686:	99bff0ef          	jal	ra,800020 <__panic>
        loop();
  80068a:	f07ff0ef          	jal	ra,800590 <loop>
    }
    else {
        kill(pid1);
  80068e:	4008                	lw	a0,0(s0)
  800690:	a4dff0ef          	jal	ra,8000dc <kill>
    }
    panic("FAIL: T.T\n");
  800694:	00000617          	auipc	a2,0x0
  800698:	3dc60613          	addi	a2,a2,988 # 800a70 <error_string+0x230>
  80069c:	03900593          	li	a1,57
  8006a0:	00000517          	auipc	a0,0x0
  8006a4:	39850513          	addi	a0,a0,920 # 800a38 <error_string+0x1f8>
  8006a8:	979ff0ef          	jal	ra,800020 <__panic>
        work();
  8006ac:	ef7ff0ef          	jal	ra,8005a2 <work>
