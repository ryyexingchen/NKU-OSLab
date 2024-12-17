
obj/__user_softint.out：     文件格式 elf64-littleriscv


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

0000000000800060 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800060:	85aa                	mv	a1,a0
  800062:	4579                	li	a0,30
  800064:	bf75                	j	800020 <syscall>

0000000000800066 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800066:	1141                	addi	sp,sp,-16
  800068:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80006a:	ff1ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80006e:	00000517          	auipc	a0,0x0
  800072:	48a50513          	addi	a0,a0,1162 # 8004f8 <main+0xa>
  800076:	026000ef          	jal	ra,80009c <cprintf>
    while (1);
  80007a:	a001                	j	80007a <exit+0x14>

000000000080007c <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80007c:	054000ef          	jal	ra,8000d0 <umain>
1:  j 1b
  800080:	a001                	j	800080 <_start+0x4>

0000000000800082 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800082:	1141                	addi	sp,sp,-16
  800084:	e022                	sd	s0,0(sp)
  800086:	e406                	sd	ra,8(sp)
  800088:	842e                	mv	s0,a1
    sys_putc(c);
  80008a:	fd7ff0ef          	jal	ra,800060 <sys_putc>
    (*cnt) ++;
  80008e:	401c                	lw	a5,0(s0)
}
  800090:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800092:	2785                	addiw	a5,a5,1
  800094:	c01c                	sw	a5,0(s0)
}
  800096:	6402                	ld	s0,0(sp)
  800098:	0141                	addi	sp,sp,16
  80009a:	8082                	ret

000000000080009c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80009c:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80009e:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a2:	f42e                	sd	a1,40(sp)
  8000a4:	f832                	sd	a2,48(sp)
  8000a6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000a8:	862a                	mv	a2,a0
  8000aa:	004c                	addi	a1,sp,4
  8000ac:	00000517          	auipc	a0,0x0
  8000b0:	fd650513          	addi	a0,a0,-42 # 800082 <cputch>
  8000b4:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000b6:	ec06                	sd	ra,24(sp)
  8000b8:	e0ba                	sd	a4,64(sp)
  8000ba:	e4be                	sd	a5,72(sp)
  8000bc:	e8c2                	sd	a6,80(sp)
  8000be:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000c2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c4:	0aa000ef          	jal	ra,80016e <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000c8:	60e2                	ld	ra,24(sp)
  8000ca:	4512                	lw	a0,4(sp)
  8000cc:	6125                	addi	sp,sp,96
  8000ce:	8082                	ret

00000000008000d0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d4:	41a000ef          	jal	ra,8004ee <main>
    exit(ret);
  8000d8:	f8fff0ef          	jal	ra,800066 <exit>

00000000008000dc <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8000dc:	c185                	beqz	a1,8000fc <strnlen+0x20>
  8000de:	00054783          	lbu	a5,0(a0)
  8000e2:	cf89                	beqz	a5,8000fc <strnlen+0x20>
    size_t cnt = 0;
  8000e4:	4781                	li	a5,0
  8000e6:	a021                	j	8000ee <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8000e8:	00074703          	lbu	a4,0(a4)
  8000ec:	c711                	beqz	a4,8000f8 <strnlen+0x1c>
        cnt ++;
  8000ee:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000f0:	00f50733          	add	a4,a0,a5
  8000f4:	fef59ae3          	bne	a1,a5,8000e8 <strnlen+0xc>
    }
    return cnt;
}
  8000f8:	853e                	mv	a0,a5
  8000fa:	8082                	ret
    size_t cnt = 0;
  8000fc:	4781                	li	a5,0
}
  8000fe:	853e                	mv	a0,a5
  800100:	8082                	ret

0000000000800102 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800102:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800106:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800108:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80010c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80010e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800112:	f022                	sd	s0,32(sp)
  800114:	ec26                	sd	s1,24(sp)
  800116:	e84a                	sd	s2,16(sp)
  800118:	f406                	sd	ra,40(sp)
  80011a:	e44e                	sd	s3,8(sp)
  80011c:	84aa                	mv	s1,a0
  80011e:	892e                	mv	s2,a1
  800120:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800124:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800126:	03067e63          	bgeu	a2,a6,800162 <printnum+0x60>
  80012a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80012c:	00805763          	blez	s0,80013a <printnum+0x38>
  800130:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800132:	85ca                	mv	a1,s2
  800134:	854e                	mv	a0,s3
  800136:	9482                	jalr	s1
        while (-- width > 0)
  800138:	fc65                	bnez	s0,800130 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80013a:	1a02                	slli	s4,s4,0x20
  80013c:	020a5a13          	srli	s4,s4,0x20
  800140:	00000797          	auipc	a5,0x0
  800144:	5f078793          	addi	a5,a5,1520 # 800730 <error_string+0xc8>
  800148:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80014a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80014c:	000a4503          	lbu	a0,0(s4)
}
  800150:	70a2                	ld	ra,40(sp)
  800152:	69a2                	ld	s3,8(sp)
  800154:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800156:	85ca                	mv	a1,s2
  800158:	8326                	mv	t1,s1
}
  80015a:	6942                	ld	s2,16(sp)
  80015c:	64e2                	ld	s1,24(sp)
  80015e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800160:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800162:	03065633          	divu	a2,a2,a6
  800166:	8722                	mv	a4,s0
  800168:	f9bff0ef          	jal	ra,800102 <printnum>
  80016c:	b7f9                	j	80013a <printnum+0x38>

000000000080016e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80016e:	7119                	addi	sp,sp,-128
  800170:	f4a6                	sd	s1,104(sp)
  800172:	f0ca                	sd	s2,96(sp)
  800174:	e8d2                	sd	s4,80(sp)
  800176:	e4d6                	sd	s5,72(sp)
  800178:	e0da                	sd	s6,64(sp)
  80017a:	fc5e                	sd	s7,56(sp)
  80017c:	f862                	sd	s8,48(sp)
  80017e:	f06a                	sd	s10,32(sp)
  800180:	fc86                	sd	ra,120(sp)
  800182:	f8a2                	sd	s0,112(sp)
  800184:	ecce                	sd	s3,88(sp)
  800186:	f466                	sd	s9,40(sp)
  800188:	ec6e                	sd	s11,24(sp)
  80018a:	892a                	mv	s2,a0
  80018c:	84ae                	mv	s1,a1
  80018e:	8d32                	mv	s10,a2
  800190:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800192:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800194:	00000a17          	auipc	s4,0x0
  800198:	378a0a13          	addi	s4,s4,888 # 80050c <main+0x1e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80019c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001a0:	00000c17          	auipc	s8,0x0
  8001a4:	4c8c0c13          	addi	s8,s8,1224 # 800668 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a8:	000d4503          	lbu	a0,0(s10)
  8001ac:	02500793          	li	a5,37
  8001b0:	001d0413          	addi	s0,s10,1
  8001b4:	00f50e63          	beq	a0,a5,8001d0 <vprintfmt+0x62>
            if (ch == '\0') {
  8001b8:	c521                	beqz	a0,800200 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ba:	02500993          	li	s3,37
  8001be:	a011                	j	8001c2 <vprintfmt+0x54>
            if (ch == '\0') {
  8001c0:	c121                	beqz	a0,800200 <vprintfmt+0x92>
            putch(ch, putdat);
  8001c2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001c6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	fff44503          	lbu	a0,-1(s0)
  8001cc:	ff351ae3          	bne	a0,s3,8001c0 <vprintfmt+0x52>
  8001d0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001d4:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001d8:	4981                	li	s3,0
  8001da:	4801                	li	a6,0
        width = precision = -1;
  8001dc:	5cfd                	li	s9,-1
  8001de:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001e0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001e4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001e6:	fdd6069b          	addiw	a3,a2,-35
  8001ea:	0ff6f693          	andi	a3,a3,255
  8001ee:	00140d13          	addi	s10,s0,1
  8001f2:	1ed5ef63          	bltu	a1,a3,8003f0 <vprintfmt+0x282>
  8001f6:	068a                	slli	a3,a3,0x2
  8001f8:	96d2                	add	a3,a3,s4
  8001fa:	4294                	lw	a3,0(a3)
  8001fc:	96d2                	add	a3,a3,s4
  8001fe:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800200:	70e6                	ld	ra,120(sp)
  800202:	7446                	ld	s0,112(sp)
  800204:	74a6                	ld	s1,104(sp)
  800206:	7906                	ld	s2,96(sp)
  800208:	69e6                	ld	s3,88(sp)
  80020a:	6a46                	ld	s4,80(sp)
  80020c:	6aa6                	ld	s5,72(sp)
  80020e:	6b06                	ld	s6,64(sp)
  800210:	7be2                	ld	s7,56(sp)
  800212:	7c42                	ld	s8,48(sp)
  800214:	7ca2                	ld	s9,40(sp)
  800216:	7d02                	ld	s10,32(sp)
  800218:	6de2                	ld	s11,24(sp)
  80021a:	6109                	addi	sp,sp,128
  80021c:	8082                	ret
            padc = '-';
  80021e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	00144603          	lbu	a2,1(s0)
  800224:	846a                	mv	s0,s10
  800226:	b7c1                	j	8001e6 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800228:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80022c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800230:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	846a                	mv	s0,s10
            if (width < 0)
  800234:	fa0dd9e3          	bgez	s11,8001e6 <vprintfmt+0x78>
                width = precision, precision = -1;
  800238:	8de6                	mv	s11,s9
  80023a:	5cfd                	li	s9,-1
  80023c:	b76d                	j	8001e6 <vprintfmt+0x78>
            if (width < 0)
  80023e:	fffdc693          	not	a3,s11
  800242:	96fd                	srai	a3,a3,0x3f
  800244:	00ddfdb3          	and	s11,s11,a3
  800248:	00144603          	lbu	a2,1(s0)
  80024c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80024e:	846a                	mv	s0,s10
  800250:	bf59                	j	8001e6 <vprintfmt+0x78>
    if (lflag >= 2) {
  800252:	4705                	li	a4,1
  800254:	008a8593          	addi	a1,s5,8
  800258:	01074463          	blt	a4,a6,800260 <vprintfmt+0xf2>
    else if (lflag) {
  80025c:	22080863          	beqz	a6,80048c <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  800260:	000ab603          	ld	a2,0(s5)
  800264:	46c1                	li	a3,16
  800266:	8aae                	mv	s5,a1
  800268:	a291                	j	8003ac <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  80026a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80026e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800272:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800274:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800278:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80027c:	fad56ce3          	bltu	a0,a3,800234 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  800280:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800282:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800286:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80028a:	0196873b          	addw	a4,a3,s9
  80028e:	0017171b          	slliw	a4,a4,0x1
  800292:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800296:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80029a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80029e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002a2:	fcd57fe3          	bgeu	a0,a3,800280 <vprintfmt+0x112>
  8002a6:	b779                	j	800234 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002a8:	000aa503          	lw	a0,0(s5)
  8002ac:	85a6                	mv	a1,s1
  8002ae:	0aa1                	addi	s5,s5,8
  8002b0:	9902                	jalr	s2
            break;
  8002b2:	bddd                	j	8001a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002b4:	4705                	li	a4,1
  8002b6:	008a8993          	addi	s3,s5,8
  8002ba:	01074463          	blt	a4,a6,8002c2 <vprintfmt+0x154>
    else if (lflag) {
  8002be:	1c080463          	beqz	a6,800486 <vprintfmt+0x318>
        return va_arg(*ap, long);
  8002c2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002c6:	1c044a63          	bltz	s0,80049a <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  8002ca:	8622                	mv	a2,s0
  8002cc:	8ace                	mv	s5,s3
  8002ce:	46a9                	li	a3,10
  8002d0:	a8f1                	j	8003ac <vprintfmt+0x23e>
            err = va_arg(ap, int);
  8002d2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d6:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002d8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002da:	41f7d69b          	sraiw	a3,a5,0x1f
  8002de:	8fb5                	xor	a5,a5,a3
  8002e0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e4:	12d74963          	blt	a4,a3,800416 <vprintfmt+0x2a8>
  8002e8:	00369793          	slli	a5,a3,0x3
  8002ec:	97e2                	add	a5,a5,s8
  8002ee:	639c                	ld	a5,0(a5)
  8002f0:	12078363          	beqz	a5,800416 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  8002f4:	86be                	mv	a3,a5
  8002f6:	00000617          	auipc	a2,0x0
  8002fa:	52a60613          	addi	a2,a2,1322 # 800820 <error_string+0x1b8>
  8002fe:	85a6                	mv	a1,s1
  800300:	854a                	mv	a0,s2
  800302:	1cc000ef          	jal	ra,8004ce <printfmt>
  800306:	b54d                	j	8001a8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800308:	000ab603          	ld	a2,0(s5)
  80030c:	0aa1                	addi	s5,s5,8
  80030e:	1a060163          	beqz	a2,8004b0 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800312:	00160413          	addi	s0,a2,1
  800316:	15b05763          	blez	s11,800464 <vprintfmt+0x2f6>
  80031a:	02d00593          	li	a1,45
  80031e:	10b79d63          	bne	a5,a1,800438 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800322:	00064783          	lbu	a5,0(a2)
  800326:	0007851b          	sext.w	a0,a5
  80032a:	c905                	beqz	a0,80035a <vprintfmt+0x1ec>
  80032c:	000cc563          	bltz	s9,800336 <vprintfmt+0x1c8>
  800330:	3cfd                	addiw	s9,s9,-1
  800332:	036c8263          	beq	s9,s6,800356 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800336:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800338:	14098f63          	beqz	s3,800496 <vprintfmt+0x328>
  80033c:	3781                	addiw	a5,a5,-32
  80033e:	14fbfc63          	bgeu	s7,a5,800496 <vprintfmt+0x328>
                    putch('?', putdat);
  800342:	03f00513          	li	a0,63
  800346:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800348:	0405                	addi	s0,s0,1
  80034a:	fff44783          	lbu	a5,-1(s0)
  80034e:	3dfd                	addiw	s11,s11,-1
  800350:	0007851b          	sext.w	a0,a5
  800354:	fd61                	bnez	a0,80032c <vprintfmt+0x1be>
            for (; width > 0; width --) {
  800356:	e5b059e3          	blez	s11,8001a8 <vprintfmt+0x3a>
  80035a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80035c:	85a6                	mv	a1,s1
  80035e:	02000513          	li	a0,32
  800362:	9902                	jalr	s2
            for (; width > 0; width --) {
  800364:	e40d82e3          	beqz	s11,8001a8 <vprintfmt+0x3a>
  800368:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80036a:	85a6                	mv	a1,s1
  80036c:	02000513          	li	a0,32
  800370:	9902                	jalr	s2
            for (; width > 0; width --) {
  800372:	fe0d94e3          	bnez	s11,80035a <vprintfmt+0x1ec>
  800376:	bd0d                	j	8001a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800378:	4705                	li	a4,1
  80037a:	008a8593          	addi	a1,s5,8
  80037e:	01074463          	blt	a4,a6,800386 <vprintfmt+0x218>
    else if (lflag) {
  800382:	0e080863          	beqz	a6,800472 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  800386:	000ab603          	ld	a2,0(s5)
  80038a:	46a1                	li	a3,8
  80038c:	8aae                	mv	s5,a1
  80038e:	a839                	j	8003ac <vprintfmt+0x23e>
            putch('0', putdat);
  800390:	03000513          	li	a0,48
  800394:	85a6                	mv	a1,s1
  800396:	e03e                	sd	a5,0(sp)
  800398:	9902                	jalr	s2
            putch('x', putdat);
  80039a:	85a6                	mv	a1,s1
  80039c:	07800513          	li	a0,120
  8003a0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003a2:	0aa1                	addi	s5,s5,8
  8003a4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003a8:	6782                	ld	a5,0(sp)
  8003aa:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8003ac:	2781                	sext.w	a5,a5
  8003ae:	876e                	mv	a4,s11
  8003b0:	85a6                	mv	a1,s1
  8003b2:	854a                	mv	a0,s2
  8003b4:	d4fff0ef          	jal	ra,800102 <printnum>
            break;
  8003b8:	bbc5                	j	8001a8 <vprintfmt+0x3a>
            lflag ++;
  8003ba:	00144603          	lbu	a2,1(s0)
  8003be:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003c0:	846a                	mv	s0,s10
            goto reswitch;
  8003c2:	b515                	j	8001e6 <vprintfmt+0x78>
            goto reswitch;
  8003c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003c8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003ca:	846a                	mv	s0,s10
            goto reswitch;
  8003cc:	bd29                	j	8001e6 <vprintfmt+0x78>
            putch(ch, putdat);
  8003ce:	85a6                	mv	a1,s1
  8003d0:	02500513          	li	a0,37
  8003d4:	9902                	jalr	s2
            break;
  8003d6:	bbc9                	j	8001a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003d8:	4705                	li	a4,1
  8003da:	008a8593          	addi	a1,s5,8
  8003de:	01074463          	blt	a4,a6,8003e6 <vprintfmt+0x278>
    else if (lflag) {
  8003e2:	08080d63          	beqz	a6,80047c <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  8003e6:	000ab603          	ld	a2,0(s5)
  8003ea:	46a9                	li	a3,10
  8003ec:	8aae                	mv	s5,a1
  8003ee:	bf7d                	j	8003ac <vprintfmt+0x23e>
            putch('%', putdat);
  8003f0:	85a6                	mv	a1,s1
  8003f2:	02500513          	li	a0,37
  8003f6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003f8:	fff44703          	lbu	a4,-1(s0)
  8003fc:	02500793          	li	a5,37
  800400:	8d22                	mv	s10,s0
  800402:	daf703e3          	beq	a4,a5,8001a8 <vprintfmt+0x3a>
  800406:	02500713          	li	a4,37
  80040a:	1d7d                	addi	s10,s10,-1
  80040c:	fffd4783          	lbu	a5,-1(s10)
  800410:	fee79de3          	bne	a5,a4,80040a <vprintfmt+0x29c>
  800414:	bb51                	j	8001a8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800416:	00000617          	auipc	a2,0x0
  80041a:	3fa60613          	addi	a2,a2,1018 # 800810 <error_string+0x1a8>
  80041e:	85a6                	mv	a1,s1
  800420:	854a                	mv	a0,s2
  800422:	0ac000ef          	jal	ra,8004ce <printfmt>
  800426:	b349                	j	8001a8 <vprintfmt+0x3a>
                p = "(null)";
  800428:	00000617          	auipc	a2,0x0
  80042c:	3e060613          	addi	a2,a2,992 # 800808 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800430:	00000417          	auipc	s0,0x0
  800434:	3d940413          	addi	s0,s0,985 # 800809 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800438:	8532                	mv	a0,a2
  80043a:	85e6                	mv	a1,s9
  80043c:	e032                	sd	a2,0(sp)
  80043e:	e43e                	sd	a5,8(sp)
  800440:	c9dff0ef          	jal	ra,8000dc <strnlen>
  800444:	40ad8dbb          	subw	s11,s11,a0
  800448:	6602                	ld	a2,0(sp)
  80044a:	01b05d63          	blez	s11,800464 <vprintfmt+0x2f6>
  80044e:	67a2                	ld	a5,8(sp)
  800450:	2781                	sext.w	a5,a5
  800452:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800454:	6522                	ld	a0,8(sp)
  800456:	85a6                	mv	a1,s1
  800458:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80045c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045e:	6602                	ld	a2,0(sp)
  800460:	fe0d9ae3          	bnez	s11,800454 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800464:	00064783          	lbu	a5,0(a2)
  800468:	0007851b          	sext.w	a0,a5
  80046c:	ec0510e3          	bnez	a0,80032c <vprintfmt+0x1be>
  800470:	bb25                	j	8001a8 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  800472:	000ae603          	lwu	a2,0(s5)
  800476:	46a1                	li	a3,8
  800478:	8aae                	mv	s5,a1
  80047a:	bf0d                	j	8003ac <vprintfmt+0x23e>
  80047c:	000ae603          	lwu	a2,0(s5)
  800480:	46a9                	li	a3,10
  800482:	8aae                	mv	s5,a1
  800484:	b725                	j	8003ac <vprintfmt+0x23e>
        return va_arg(*ap, int);
  800486:	000aa403          	lw	s0,0(s5)
  80048a:	bd35                	j	8002c6 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  80048c:	000ae603          	lwu	a2,0(s5)
  800490:	46c1                	li	a3,16
  800492:	8aae                	mv	s5,a1
  800494:	bf21                	j	8003ac <vprintfmt+0x23e>
                    putch(ch, putdat);
  800496:	9902                	jalr	s2
  800498:	bd45                	j	800348 <vprintfmt+0x1da>
                putch('-', putdat);
  80049a:	85a6                	mv	a1,s1
  80049c:	02d00513          	li	a0,45
  8004a0:	e03e                	sd	a5,0(sp)
  8004a2:	9902                	jalr	s2
                num = -(long long)num;
  8004a4:	8ace                	mv	s5,s3
  8004a6:	40800633          	neg	a2,s0
  8004aa:	46a9                	li	a3,10
  8004ac:	6782                	ld	a5,0(sp)
  8004ae:	bdfd                	j	8003ac <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  8004b0:	01b05663          	blez	s11,8004bc <vprintfmt+0x34e>
  8004b4:	02d00693          	li	a3,45
  8004b8:	f6d798e3          	bne	a5,a3,800428 <vprintfmt+0x2ba>
  8004bc:	00000417          	auipc	s0,0x0
  8004c0:	34d40413          	addi	s0,s0,845 # 800809 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	02800513          	li	a0,40
  8004c8:	02800793          	li	a5,40
  8004cc:	b585                	j	80032c <vprintfmt+0x1be>

00000000008004ce <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ce:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004d0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d8:	ec06                	sd	ra,24(sp)
  8004da:	f83a                	sd	a4,48(sp)
  8004dc:	fc3e                	sd	a5,56(sp)
  8004de:	e0c2                	sd	a6,64(sp)
  8004e0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004e2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e4:	c8bff0ef          	jal	ra,80016e <vprintfmt>
}
  8004e8:	60e2                	ld	ra,24(sp)
  8004ea:	6161                	addi	sp,sp,80
  8004ec:	8082                	ret

00000000008004ee <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004ee:	1141                	addi	sp,sp,-16
	// Never mind
    // asm volatile("int $14");
    exit(0);
  8004f0:	4501                	li	a0,0
main(void) {
  8004f2:	e406                	sd	ra,8(sp)
    exit(0);
  8004f4:	b73ff0ef          	jal	ra,800066 <exit>
