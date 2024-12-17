
obj/__user_yield.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800020:	7175                	addi	sp,sp,-144
  800022:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800024:	e0ba                	sd	a4,64(sp)
  800026:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  800028:	e42a                	sd	a0,8(sp)
  80002a:	ecae                	sd	a1,88(sp)
  80002c:	f0b2                	sd	a2,96(sp)
  80002e:	f4b6                	sd	a3,104(sp)
  800030:	fcbe                	sd	a5,120(sp)
  800032:	e142                	sd	a6,128(sp)
  800034:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800036:	f42e                	sd	a1,40(sp)
  800038:	f832                	sd	a2,48(sp)
  80003a:	fc36                	sd	a3,56(sp)
  80003c:	f03a                	sd	a4,32(sp)
  80003e:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800040:	6522                	ld	a0,8(sp)
  800042:	75a2                	ld	a1,40(sp)
  800044:	7642                	ld	a2,48(sp)
  800046:	76e2                	ld	a3,56(sp)
  800048:	6706                	ld	a4,64(sp)
  80004a:	67a6                	ld	a5,72(sp)
  80004c:	00000073          	ecall
  800050:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800054:	4572                	lw	a0,28(sp)
  800056:	6149                	addi	sp,sp,144
  800058:	8082                	ret

000000000080005a <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80005a:	85aa                	mv	a1,a0
  80005c:	4505                	li	a0,1
  80005e:	b7c9                	j	800020 <syscall>

0000000000800060 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800060:	4529                	li	a0,10
  800062:	bf7d                	j	800020 <syscall>

0000000000800064 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800064:	4549                	li	a0,18
  800066:	bf6d                	j	800020 <syscall>

0000000000800068 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800068:	85aa                	mv	a1,a0
  80006a:	4579                	li	a0,30
  80006c:	bf55                	j	800020 <syscall>

000000000080006e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80006e:	1141                	addi	sp,sp,-16
  800070:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800072:	fe9ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800076:	00000517          	auipc	a0,0x0
  80007a:	4f250513          	addi	a0,a0,1266 # 800568 <main+0x6e>
  80007e:	02a000ef          	jal	ra,8000a8 <cprintf>
    while (1);
  800082:	a001                	j	800082 <exit+0x14>

0000000000800084 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800084:	bff1                	j	800060 <sys_yield>

0000000000800086 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800086:	bff9                	j	800064 <sys_getpid>

0000000000800088 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800088:	054000ef          	jal	ra,8000dc <umain>
1:  j 1b
  80008c:	a001                	j	80008c <_start+0x4>

000000000080008e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80008e:	1141                	addi	sp,sp,-16
  800090:	e022                	sd	s0,0(sp)
  800092:	e406                	sd	ra,8(sp)
  800094:	842e                	mv	s0,a1
    sys_putc(c);
  800096:	fd3ff0ef          	jal	ra,800068 <sys_putc>
    (*cnt) ++;
  80009a:	401c                	lw	a5,0(s0)
}
  80009c:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  80009e:	2785                	addiw	a5,a5,1
  8000a0:	c01c                	sw	a5,0(s0)
}
  8000a2:	6402                	ld	s0,0(sp)
  8000a4:	0141                	addi	sp,sp,16
  8000a6:	8082                	ret

00000000008000a8 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a8:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000aa:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000ae:	f42e                	sd	a1,40(sp)
  8000b0:	f832                	sd	a2,48(sp)
  8000b2:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b4:	862a                	mv	a2,a0
  8000b6:	004c                	addi	a1,sp,4
  8000b8:	00000517          	auipc	a0,0x0
  8000bc:	fd650513          	addi	a0,a0,-42 # 80008e <cputch>
  8000c0:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c2:	ec06                	sd	ra,24(sp)
  8000c4:	e0ba                	sd	a4,64(sp)
  8000c6:	e4be                	sd	a5,72(sp)
  8000c8:	e8c2                	sd	a6,80(sp)
  8000ca:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000cc:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000ce:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d0:	0aa000ef          	jal	ra,80017a <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d4:	60e2                	ld	ra,24(sp)
  8000d6:	4512                	lw	a0,4(sp)
  8000d8:	6125                	addi	sp,sp,96
  8000da:	8082                	ret

00000000008000dc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000dc:	1141                	addi	sp,sp,-16
  8000de:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e0:	41a000ef          	jal	ra,8004fa <main>
    exit(ret);
  8000e4:	f8bff0ef          	jal	ra,80006e <exit>

00000000008000e8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8000e8:	c185                	beqz	a1,800108 <strnlen+0x20>
  8000ea:	00054783          	lbu	a5,0(a0)
  8000ee:	cf89                	beqz	a5,800108 <strnlen+0x20>
    size_t cnt = 0;
  8000f0:	4781                	li	a5,0
  8000f2:	a021                	j	8000fa <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8000f4:	00074703          	lbu	a4,0(a4)
  8000f8:	c711                	beqz	a4,800104 <strnlen+0x1c>
        cnt ++;
  8000fa:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000fc:	00f50733          	add	a4,a0,a5
  800100:	fef59ae3          	bne	a1,a5,8000f4 <strnlen+0xc>
    }
    return cnt;
}
  800104:	853e                	mv	a0,a5
  800106:	8082                	ret
    size_t cnt = 0;
  800108:	4781                	li	a5,0
}
  80010a:	853e                	mv	a0,a5
  80010c:	8082                	ret

000000000080010e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80010e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800112:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800114:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800118:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80011a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80011e:	f022                	sd	s0,32(sp)
  800120:	ec26                	sd	s1,24(sp)
  800122:	e84a                	sd	s2,16(sp)
  800124:	f406                	sd	ra,40(sp)
  800126:	e44e                	sd	s3,8(sp)
  800128:	84aa                	mv	s1,a0
  80012a:	892e                	mv	s2,a1
  80012c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800130:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800132:	03067e63          	bgeu	a2,a6,80016e <printnum+0x60>
  800136:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800138:	00805763          	blez	s0,800146 <printnum+0x38>
  80013c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80013e:	85ca                	mv	a1,s2
  800140:	854e                	mv	a0,s3
  800142:	9482                	jalr	s1
        while (-- width > 0)
  800144:	fc65                	bnez	s0,80013c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800146:	1a02                	slli	s4,s4,0x20
  800148:	020a5a13          	srli	s4,s4,0x20
  80014c:	00000797          	auipc	a5,0x0
  800150:	65478793          	addi	a5,a5,1620 # 8007a0 <error_string+0xc8>
  800154:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800156:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800158:	000a4503          	lbu	a0,0(s4)
}
  80015c:	70a2                	ld	ra,40(sp)
  80015e:	69a2                	ld	s3,8(sp)
  800160:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800162:	85ca                	mv	a1,s2
  800164:	8326                	mv	t1,s1
}
  800166:	6942                	ld	s2,16(sp)
  800168:	64e2                	ld	s1,24(sp)
  80016a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80016c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80016e:	03065633          	divu	a2,a2,a6
  800172:	8722                	mv	a4,s0
  800174:	f9bff0ef          	jal	ra,80010e <printnum>
  800178:	b7f9                	j	800146 <printnum+0x38>

000000000080017a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80017a:	7119                	addi	sp,sp,-128
  80017c:	f4a6                	sd	s1,104(sp)
  80017e:	f0ca                	sd	s2,96(sp)
  800180:	e8d2                	sd	s4,80(sp)
  800182:	e4d6                	sd	s5,72(sp)
  800184:	e0da                	sd	s6,64(sp)
  800186:	fc5e                	sd	s7,56(sp)
  800188:	f862                	sd	s8,48(sp)
  80018a:	f06a                	sd	s10,32(sp)
  80018c:	fc86                	sd	ra,120(sp)
  80018e:	f8a2                	sd	s0,112(sp)
  800190:	ecce                	sd	s3,88(sp)
  800192:	f466                	sd	s9,40(sp)
  800194:	ec6e                	sd	s11,24(sp)
  800196:	892a                	mv	s2,a0
  800198:	84ae                	mv	s1,a1
  80019a:	8d32                	mv	s10,a2
  80019c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80019e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001a0:	00000a17          	auipc	s4,0x0
  8001a4:	3dca0a13          	addi	s4,s4,988 # 80057c <main+0x82>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001a8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001ac:	00000c17          	auipc	s8,0x0
  8001b0:	52cc0c13          	addi	s8,s8,1324 # 8006d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b4:	000d4503          	lbu	a0,0(s10)
  8001b8:	02500793          	li	a5,37
  8001bc:	001d0413          	addi	s0,s10,1
  8001c0:	00f50e63          	beq	a0,a5,8001dc <vprintfmt+0x62>
            if (ch == '\0') {
  8001c4:	c521                	beqz	a0,80020c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c6:	02500993          	li	s3,37
  8001ca:	a011                	j	8001ce <vprintfmt+0x54>
            if (ch == '\0') {
  8001cc:	c121                	beqz	a0,80020c <vprintfmt+0x92>
            putch(ch, putdat);
  8001ce:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001d2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d4:	fff44503          	lbu	a0,-1(s0)
  8001d8:	ff351ae3          	bne	a0,s3,8001cc <vprintfmt+0x52>
  8001dc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001e0:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001e4:	4981                	li	s3,0
  8001e6:	4801                	li	a6,0
        width = precision = -1;
  8001e8:	5cfd                	li	s9,-1
  8001ea:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001ec:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001f0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001f2:	fdd6069b          	addiw	a3,a2,-35
  8001f6:	0ff6f693          	andi	a3,a3,255
  8001fa:	00140d13          	addi	s10,s0,1
  8001fe:	1ed5ef63          	bltu	a1,a3,8003fc <vprintfmt+0x282>
  800202:	068a                	slli	a3,a3,0x2
  800204:	96d2                	add	a3,a3,s4
  800206:	4294                	lw	a3,0(a3)
  800208:	96d2                	add	a3,a3,s4
  80020a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80020c:	70e6                	ld	ra,120(sp)
  80020e:	7446                	ld	s0,112(sp)
  800210:	74a6                	ld	s1,104(sp)
  800212:	7906                	ld	s2,96(sp)
  800214:	69e6                	ld	s3,88(sp)
  800216:	6a46                	ld	s4,80(sp)
  800218:	6aa6                	ld	s5,72(sp)
  80021a:	6b06                	ld	s6,64(sp)
  80021c:	7be2                	ld	s7,56(sp)
  80021e:	7c42                	ld	s8,48(sp)
  800220:	7ca2                	ld	s9,40(sp)
  800222:	7d02                	ld	s10,32(sp)
  800224:	6de2                	ld	s11,24(sp)
  800226:	6109                	addi	sp,sp,128
  800228:	8082                	ret
            padc = '-';
  80022a:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80022c:	00144603          	lbu	a2,1(s0)
  800230:	846a                	mv	s0,s10
  800232:	b7c1                	j	8001f2 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800234:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800238:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80023c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80023e:	846a                	mv	s0,s10
            if (width < 0)
  800240:	fa0dd9e3          	bgez	s11,8001f2 <vprintfmt+0x78>
                width = precision, precision = -1;
  800244:	8de6                	mv	s11,s9
  800246:	5cfd                	li	s9,-1
  800248:	b76d                	j	8001f2 <vprintfmt+0x78>
            if (width < 0)
  80024a:	fffdc693          	not	a3,s11
  80024e:	96fd                	srai	a3,a3,0x3f
  800250:	00ddfdb3          	and	s11,s11,a3
  800254:	00144603          	lbu	a2,1(s0)
  800258:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80025a:	846a                	mv	s0,s10
  80025c:	bf59                	j	8001f2 <vprintfmt+0x78>
    if (lflag >= 2) {
  80025e:	4705                	li	a4,1
  800260:	008a8593          	addi	a1,s5,8
  800264:	01074463          	blt	a4,a6,80026c <vprintfmt+0xf2>
    else if (lflag) {
  800268:	22080863          	beqz	a6,800498 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  80026c:	000ab603          	ld	a2,0(s5)
  800270:	46c1                	li	a3,16
  800272:	8aae                	mv	s5,a1
  800274:	a291                	j	8003b8 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  800276:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80027a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80027e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800280:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800284:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800288:	fad56ce3          	bltu	a0,a3,800240 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  80028c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80028e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800292:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800296:	0196873b          	addw	a4,a3,s9
  80029a:	0017171b          	slliw	a4,a4,0x1
  80029e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002a2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002a6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002aa:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002ae:	fcd57fe3          	bgeu	a0,a3,80028c <vprintfmt+0x112>
  8002b2:	b779                	j	800240 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002b4:	000aa503          	lw	a0,0(s5)
  8002b8:	85a6                	mv	a1,s1
  8002ba:	0aa1                	addi	s5,s5,8
  8002bc:	9902                	jalr	s2
            break;
  8002be:	bddd                	j	8001b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002c0:	4705                	li	a4,1
  8002c2:	008a8993          	addi	s3,s5,8
  8002c6:	01074463          	blt	a4,a6,8002ce <vprintfmt+0x154>
    else if (lflag) {
  8002ca:	1c080463          	beqz	a6,800492 <vprintfmt+0x318>
        return va_arg(*ap, long);
  8002ce:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002d2:	1c044a63          	bltz	s0,8004a6 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  8002d6:	8622                	mv	a2,s0
  8002d8:	8ace                	mv	s5,s3
  8002da:	46a9                	li	a3,10
  8002dc:	a8f1                	j	8003b8 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  8002de:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e2:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002e4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002e6:	41f7d69b          	sraiw	a3,a5,0x1f
  8002ea:	8fb5                	xor	a5,a5,a3
  8002ec:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002f0:	12d74963          	blt	a4,a3,800422 <vprintfmt+0x2a8>
  8002f4:	00369793          	slli	a5,a3,0x3
  8002f8:	97e2                	add	a5,a5,s8
  8002fa:	639c                	ld	a5,0(a5)
  8002fc:	12078363          	beqz	a5,800422 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800300:	86be                	mv	a3,a5
  800302:	00000617          	auipc	a2,0x0
  800306:	58e60613          	addi	a2,a2,1422 # 800890 <error_string+0x1b8>
  80030a:	85a6                	mv	a1,s1
  80030c:	854a                	mv	a0,s2
  80030e:	1cc000ef          	jal	ra,8004da <printfmt>
  800312:	b54d                	j	8001b4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800314:	000ab603          	ld	a2,0(s5)
  800318:	0aa1                	addi	s5,s5,8
  80031a:	1a060163          	beqz	a2,8004bc <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  80031e:	00160413          	addi	s0,a2,1
  800322:	15b05763          	blez	s11,800470 <vprintfmt+0x2f6>
  800326:	02d00593          	li	a1,45
  80032a:	10b79d63          	bne	a5,a1,800444 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032e:	00064783          	lbu	a5,0(a2)
  800332:	0007851b          	sext.w	a0,a5
  800336:	c905                	beqz	a0,800366 <vprintfmt+0x1ec>
  800338:	000cc563          	bltz	s9,800342 <vprintfmt+0x1c8>
  80033c:	3cfd                	addiw	s9,s9,-1
  80033e:	036c8263          	beq	s9,s6,800362 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800342:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800344:	14098f63          	beqz	s3,8004a2 <vprintfmt+0x328>
  800348:	3781                	addiw	a5,a5,-32
  80034a:	14fbfc63          	bgeu	s7,a5,8004a2 <vprintfmt+0x328>
                    putch('?', putdat);
  80034e:	03f00513          	li	a0,63
  800352:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800354:	0405                	addi	s0,s0,1
  800356:	fff44783          	lbu	a5,-1(s0)
  80035a:	3dfd                	addiw	s11,s11,-1
  80035c:	0007851b          	sext.w	a0,a5
  800360:	fd61                	bnez	a0,800338 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  800362:	e5b059e3          	blez	s11,8001b4 <vprintfmt+0x3a>
  800366:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800368:	85a6                	mv	a1,s1
  80036a:	02000513          	li	a0,32
  80036e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800370:	e40d82e3          	beqz	s11,8001b4 <vprintfmt+0x3a>
  800374:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800376:	85a6                	mv	a1,s1
  800378:	02000513          	li	a0,32
  80037c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80037e:	fe0d94e3          	bnez	s11,800366 <vprintfmt+0x1ec>
  800382:	bd0d                	j	8001b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800384:	4705                	li	a4,1
  800386:	008a8593          	addi	a1,s5,8
  80038a:	01074463          	blt	a4,a6,800392 <vprintfmt+0x218>
    else if (lflag) {
  80038e:	0e080863          	beqz	a6,80047e <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  800392:	000ab603          	ld	a2,0(s5)
  800396:	46a1                	li	a3,8
  800398:	8aae                	mv	s5,a1
  80039a:	a839                	j	8003b8 <vprintfmt+0x23e>
            putch('0', putdat);
  80039c:	03000513          	li	a0,48
  8003a0:	85a6                	mv	a1,s1
  8003a2:	e03e                	sd	a5,0(sp)
  8003a4:	9902                	jalr	s2
            putch('x', putdat);
  8003a6:	85a6                	mv	a1,s1
  8003a8:	07800513          	li	a0,120
  8003ac:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ae:	0aa1                	addi	s5,s5,8
  8003b0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003b4:	6782                	ld	a5,0(sp)
  8003b6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8003b8:	2781                	sext.w	a5,a5
  8003ba:	876e                	mv	a4,s11
  8003bc:	85a6                	mv	a1,s1
  8003be:	854a                	mv	a0,s2
  8003c0:	d4fff0ef          	jal	ra,80010e <printnum>
            break;
  8003c4:	bbc5                	j	8001b4 <vprintfmt+0x3a>
            lflag ++;
  8003c6:	00144603          	lbu	a2,1(s0)
  8003ca:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003cc:	846a                	mv	s0,s10
            goto reswitch;
  8003ce:	b515                	j	8001f2 <vprintfmt+0x78>
            goto reswitch;
  8003d0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003d4:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003d6:	846a                	mv	s0,s10
            goto reswitch;
  8003d8:	bd29                	j	8001f2 <vprintfmt+0x78>
            putch(ch, putdat);
  8003da:	85a6                	mv	a1,s1
  8003dc:	02500513          	li	a0,37
  8003e0:	9902                	jalr	s2
            break;
  8003e2:	bbc9                	j	8001b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003e4:	4705                	li	a4,1
  8003e6:	008a8593          	addi	a1,s5,8
  8003ea:	01074463          	blt	a4,a6,8003f2 <vprintfmt+0x278>
    else if (lflag) {
  8003ee:	08080d63          	beqz	a6,800488 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  8003f2:	000ab603          	ld	a2,0(s5)
  8003f6:	46a9                	li	a3,10
  8003f8:	8aae                	mv	s5,a1
  8003fa:	bf7d                	j	8003b8 <vprintfmt+0x23e>
            putch('%', putdat);
  8003fc:	85a6                	mv	a1,s1
  8003fe:	02500513          	li	a0,37
  800402:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800404:	fff44703          	lbu	a4,-1(s0)
  800408:	02500793          	li	a5,37
  80040c:	8d22                	mv	s10,s0
  80040e:	daf703e3          	beq	a4,a5,8001b4 <vprintfmt+0x3a>
  800412:	02500713          	li	a4,37
  800416:	1d7d                	addi	s10,s10,-1
  800418:	fffd4783          	lbu	a5,-1(s10)
  80041c:	fee79de3          	bne	a5,a4,800416 <vprintfmt+0x29c>
  800420:	bb51                	j	8001b4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800422:	00000617          	auipc	a2,0x0
  800426:	45e60613          	addi	a2,a2,1118 # 800880 <error_string+0x1a8>
  80042a:	85a6                	mv	a1,s1
  80042c:	854a                	mv	a0,s2
  80042e:	0ac000ef          	jal	ra,8004da <printfmt>
  800432:	b349                	j	8001b4 <vprintfmt+0x3a>
                p = "(null)";
  800434:	00000617          	auipc	a2,0x0
  800438:	44460613          	addi	a2,a2,1092 # 800878 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80043c:	00000417          	auipc	s0,0x0
  800440:	43d40413          	addi	s0,s0,1085 # 800879 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800444:	8532                	mv	a0,a2
  800446:	85e6                	mv	a1,s9
  800448:	e032                	sd	a2,0(sp)
  80044a:	e43e                	sd	a5,8(sp)
  80044c:	c9dff0ef          	jal	ra,8000e8 <strnlen>
  800450:	40ad8dbb          	subw	s11,s11,a0
  800454:	6602                	ld	a2,0(sp)
  800456:	01b05d63          	blez	s11,800470 <vprintfmt+0x2f6>
  80045a:	67a2                	ld	a5,8(sp)
  80045c:	2781                	sext.w	a5,a5
  80045e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800460:	6522                	ld	a0,8(sp)
  800462:	85a6                	mv	a1,s1
  800464:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800466:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800468:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046a:	6602                	ld	a2,0(sp)
  80046c:	fe0d9ae3          	bnez	s11,800460 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800470:	00064783          	lbu	a5,0(a2)
  800474:	0007851b          	sext.w	a0,a5
  800478:	ec0510e3          	bnez	a0,800338 <vprintfmt+0x1be>
  80047c:	bb25                	j	8001b4 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  80047e:	000ae603          	lwu	a2,0(s5)
  800482:	46a1                	li	a3,8
  800484:	8aae                	mv	s5,a1
  800486:	bf0d                	j	8003b8 <vprintfmt+0x23e>
  800488:	000ae603          	lwu	a2,0(s5)
  80048c:	46a9                	li	a3,10
  80048e:	8aae                	mv	s5,a1
  800490:	b725                	j	8003b8 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  800492:	000aa403          	lw	s0,0(s5)
  800496:	bd35                	j	8002d2 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800498:	000ae603          	lwu	a2,0(s5)
  80049c:	46c1                	li	a3,16
  80049e:	8aae                	mv	s5,a1
  8004a0:	bf21                	j	8003b8 <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004a2:	9902                	jalr	s2
  8004a4:	bd45                	j	800354 <vprintfmt+0x1da>
                putch('-', putdat);
  8004a6:	85a6                	mv	a1,s1
  8004a8:	02d00513          	li	a0,45
  8004ac:	e03e                	sd	a5,0(sp)
  8004ae:	9902                	jalr	s2
                num = -(long long)num;
  8004b0:	8ace                	mv	s5,s3
  8004b2:	40800633          	neg	a2,s0
  8004b6:	46a9                	li	a3,10
  8004b8:	6782                	ld	a5,0(sp)
  8004ba:	bdfd                	j	8003b8 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  8004bc:	01b05663          	blez	s11,8004c8 <vprintfmt+0x34e>
  8004c0:	02d00693          	li	a3,45
  8004c4:	f6d798e3          	bne	a5,a3,800434 <vprintfmt+0x2ba>
  8004c8:	00000417          	auipc	s0,0x0
  8004cc:	3b140413          	addi	s0,s0,945 # 800879 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d0:	02800513          	li	a0,40
  8004d4:	02800793          	li	a5,40
  8004d8:	b585                	j	800338 <vprintfmt+0x1be>

00000000008004da <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004da:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004dc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e4:	ec06                	sd	ra,24(sp)
  8004e6:	f83a                	sd	a4,48(sp)
  8004e8:	fc3e                	sd	a5,56(sp)
  8004ea:	e0c2                	sd	a6,64(sp)
  8004ec:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004ee:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f0:	c8bff0ef          	jal	ra,80017a <vprintfmt>
}
  8004f4:	60e2                	ld	ra,24(sp)
  8004f6:	6161                	addi	sp,sp,80
  8004f8:	8082                	ret

00000000008004fa <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004fa:	1101                	addi	sp,sp,-32
  8004fc:	ec06                	sd	ra,24(sp)
  8004fe:	e822                	sd	s0,16(sp)
  800500:	e426                	sd	s1,8(sp)
  800502:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  800504:	b83ff0ef          	jal	ra,800086 <getpid>
  800508:	85aa                	mv	a1,a0
  80050a:	00000517          	auipc	a0,0x0
  80050e:	38e50513          	addi	a0,a0,910 # 800898 <error_string+0x1c0>
  800512:	b97ff0ef          	jal	ra,8000a8 <cprintf>
    for (i = 0; i < 5; i ++) {
  800516:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800518:	00000917          	auipc	s2,0x0
  80051c:	3a090913          	addi	s2,s2,928 # 8008b8 <error_string+0x1e0>
    for (i = 0; i < 5; i ++) {
  800520:	4495                	li	s1,5
        yield();
  800522:	b63ff0ef          	jal	ra,800084 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800526:	b61ff0ef          	jal	ra,800086 <getpid>
  80052a:	8622                	mv	a2,s0
  80052c:	85aa                	mv	a1,a0
    for (i = 0; i < 5; i ++) {
  80052e:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800530:	854a                	mv	a0,s2
  800532:	b77ff0ef          	jal	ra,8000a8 <cprintf>
    for (i = 0; i < 5; i ++) {
  800536:	fe9416e3          	bne	s0,s1,800522 <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  80053a:	b4dff0ef          	jal	ra,800086 <getpid>
  80053e:	85aa                	mv	a1,a0
  800540:	00000517          	auipc	a0,0x0
  800544:	3a050513          	addi	a0,a0,928 # 8008e0 <error_string+0x208>
  800548:	b61ff0ef          	jal	ra,8000a8 <cprintf>
    cprintf("yield pass.\n");
  80054c:	00000517          	auipc	a0,0x0
  800550:	3b450513          	addi	a0,a0,948 # 800900 <error_string+0x228>
  800554:	b55ff0ef          	jal	ra,8000a8 <cprintf>
    return 0;
}
  800558:	60e2                	ld	ra,24(sp)
  80055a:	6442                	ld	s0,16(sp)
  80055c:	64a2                	ld	s1,8(sp)
  80055e:	6902                	ld	s2,0(sp)
  800560:	4501                	li	a0,0
  800562:	6105                	addi	sp,sp,32
  800564:	8082                	ret
