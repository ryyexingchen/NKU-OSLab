
obj/__user_forktree.out：     文件格式 elf64-littleriscv


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

0000000000800060 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800060:	4509                	li	a0,2
  800062:	bf7d                	j	800020 <syscall>

0000000000800064 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800064:	4529                	li	a0,10
  800066:	bf6d                	j	800020 <syscall>

0000000000800068 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800068:	4549                	li	a0,18
  80006a:	bf5d                	j	800020 <syscall>

000000000080006c <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80006c:	85aa                	mv	a1,a0
  80006e:	4579                	li	a0,30
  800070:	bf45                	j	800020 <syscall>

0000000000800072 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800072:	1141                	addi	sp,sp,-16
  800074:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800076:	fe5ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80007a:	00000517          	auipc	a0,0x0
  80007e:	5ae50513          	addi	a0,a0,1454 # 800628 <main+0x1e>
  800082:	02c000ef          	jal	ra,8000ae <cprintf>
    while (1);
  800086:	a001                	j	800086 <exit+0x14>

0000000000800088 <fork>:
}

int
fork(void) {
    return sys_fork();
  800088:	bfe1                	j	800060 <sys_fork>

000000000080008a <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  80008a:	bfe9                	j	800064 <sys_yield>

000000000080008c <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  80008c:	bff1                	j	800068 <sys_getpid>

000000000080008e <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80008e:	054000ef          	jal	ra,8000e2 <umain>
1:  j 1b
  800092:	a001                	j	800092 <_start+0x4>

0000000000800094 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800094:	1141                	addi	sp,sp,-16
  800096:	e022                	sd	s0,0(sp)
  800098:	e406                	sd	ra,8(sp)
  80009a:	842e                	mv	s0,a1
    sys_putc(c);
  80009c:	fd1ff0ef          	jal	ra,80006c <sys_putc>
    (*cnt) ++;
  8000a0:	401c                	lw	a5,0(s0)
}
  8000a2:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000a4:	2785                	addiw	a5,a5,1
  8000a6:	c01c                	sw	a5,0(s0)
}
  8000a8:	6402                	ld	s0,0(sp)
  8000aa:	0141                	addi	sp,sp,16
  8000ac:	8082                	ret

00000000008000ae <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000ae:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000b0:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000b4:	f42e                	sd	a1,40(sp)
  8000b6:	f832                	sd	a2,48(sp)
  8000b8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ba:	862a                	mv	a2,a0
  8000bc:	004c                	addi	a1,sp,4
  8000be:	00000517          	auipc	a0,0x0
  8000c2:	fd650513          	addi	a0,a0,-42 # 800094 <cputch>
  8000c6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c8:	ec06                	sd	ra,24(sp)
  8000ca:	e0ba                	sd	a4,64(sp)
  8000cc:	e4be                	sd	a5,72(sp)
  8000ce:	e8c2                	sd	a6,80(sp)
  8000d0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000d2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000d4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d6:	0e2000ef          	jal	ra,8001b8 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000da:	60e2                	ld	ra,24(sp)
  8000dc:	4512                	lw	a0,4(sp)
  8000de:	6125                	addi	sp,sp,96
  8000e0:	8082                	ret

00000000008000e2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e6:	524000ef          	jal	ra,80060a <main>
    exit(ret);
  8000ea:	f89ff0ef          	jal	ra,800072 <exit>

00000000008000ee <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8000ee:	00054783          	lbu	a5,0(a0)
  8000f2:	cb91                	beqz	a5,800106 <strlen+0x18>
    size_t cnt = 0;
  8000f4:	4781                	li	a5,0
        cnt ++;
  8000f6:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  8000f8:	00f50733          	add	a4,a0,a5
  8000fc:	00074703          	lbu	a4,0(a4)
  800100:	fb7d                	bnez	a4,8000f6 <strlen+0x8>
    }
    return cnt;
}
  800102:	853e                	mv	a0,a5
  800104:	8082                	ret
    size_t cnt = 0;
  800106:	4781                	li	a5,0
}
  800108:	853e                	mv	a0,a5
  80010a:	8082                	ret

000000000080010c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80010c:	c185                	beqz	a1,80012c <strnlen+0x20>
  80010e:	00054783          	lbu	a5,0(a0)
  800112:	cf89                	beqz	a5,80012c <strnlen+0x20>
    size_t cnt = 0;
  800114:	4781                	li	a5,0
  800116:	a021                	j	80011e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800118:	00074703          	lbu	a4,0(a4)
  80011c:	c711                	beqz	a4,800128 <strnlen+0x1c>
        cnt ++;
  80011e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800120:	00f50733          	add	a4,a0,a5
  800124:	fef59ae3          	bne	a1,a5,800118 <strnlen+0xc>
    }
    return cnt;
}
  800128:	853e                	mv	a0,a5
  80012a:	8082                	ret
    size_t cnt = 0;
  80012c:	4781                	li	a5,0
}
  80012e:	853e                	mv	a0,a5
  800130:	8082                	ret

0000000000800132 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800132:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800136:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800138:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80013c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80013e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800142:	f022                	sd	s0,32(sp)
  800144:	ec26                	sd	s1,24(sp)
  800146:	e84a                	sd	s2,16(sp)
  800148:	f406                	sd	ra,40(sp)
  80014a:	e44e                	sd	s3,8(sp)
  80014c:	84aa                	mv	s1,a0
  80014e:	892e                	mv	s2,a1
  800150:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800154:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800156:	03067e63          	bgeu	a2,a6,800192 <printnum+0x60>
  80015a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80015c:	00805763          	blez	s0,80016a <printnum+0x38>
  800160:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800162:	85ca                	mv	a1,s2
  800164:	854e                	mv	a0,s3
  800166:	9482                	jalr	s1
        while (-- width > 0)
  800168:	fc65                	bnez	s0,800160 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80016a:	1a02                	slli	s4,s4,0x20
  80016c:	020a5a13          	srli	s4,s4,0x20
  800170:	00000797          	auipc	a5,0x0
  800174:	6f078793          	addi	a5,a5,1776 # 800860 <error_string+0xc8>
  800178:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80017a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80017c:	000a4503          	lbu	a0,0(s4)
}
  800180:	70a2                	ld	ra,40(sp)
  800182:	69a2                	ld	s3,8(sp)
  800184:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800186:	85ca                	mv	a1,s2
  800188:	8326                	mv	t1,s1
}
  80018a:	6942                	ld	s2,16(sp)
  80018c:	64e2                	ld	s1,24(sp)
  80018e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800190:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800192:	03065633          	divu	a2,a2,a6
  800196:	8722                	mv	a4,s0
  800198:	f9bff0ef          	jal	ra,800132 <printnum>
  80019c:	b7f9                	j	80016a <printnum+0x38>

000000000080019e <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  80019e:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  8001a0:	6198                	ld	a4,0(a1)
  8001a2:	6594                	ld	a3,8(a1)
    b->cnt ++;
  8001a4:	2785                	addiw	a5,a5,1
  8001a6:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  8001a8:	00d77763          	bgeu	a4,a3,8001b6 <sprintputch+0x18>
        *b->buf ++ = ch;
  8001ac:	00170793          	addi	a5,a4,1
  8001b0:	e19c                	sd	a5,0(a1)
  8001b2:	00a70023          	sb	a0,0(a4)
    }
}
  8001b6:	8082                	ret

00000000008001b8 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001b8:	7119                	addi	sp,sp,-128
  8001ba:	f4a6                	sd	s1,104(sp)
  8001bc:	f0ca                	sd	s2,96(sp)
  8001be:	e8d2                	sd	s4,80(sp)
  8001c0:	e4d6                	sd	s5,72(sp)
  8001c2:	e0da                	sd	s6,64(sp)
  8001c4:	fc5e                	sd	s7,56(sp)
  8001c6:	f862                	sd	s8,48(sp)
  8001c8:	f06a                	sd	s10,32(sp)
  8001ca:	fc86                	sd	ra,120(sp)
  8001cc:	f8a2                	sd	s0,112(sp)
  8001ce:	ecce                	sd	s3,88(sp)
  8001d0:	f466                	sd	s9,40(sp)
  8001d2:	ec6e                	sd	s11,24(sp)
  8001d4:	892a                	mv	s2,a0
  8001d6:	84ae                	mv	s1,a1
  8001d8:	8d32                	mv	s10,a2
  8001da:	8ab6                	mv	s5,a3
        width = precision = -1;
  8001dc:	5b7d                	li	s6,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001de:	00000a17          	auipc	s4,0x0
  8001e2:	45ea0a13          	addi	s4,s4,1118 # 80063c <main+0x32>
                if (altflag && (ch < ' ' || ch > '~')) {
  8001e6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001ea:	00000c17          	auipc	s8,0x0
  8001ee:	5aec0c13          	addi	s8,s8,1454 # 800798 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f2:	000d4503          	lbu	a0,0(s10)
  8001f6:	02500793          	li	a5,37
  8001fa:	001d0413          	addi	s0,s10,1
  8001fe:	00f50e63          	beq	a0,a5,80021a <vprintfmt+0x62>
            if (ch == '\0') {
  800202:	c521                	beqz	a0,80024a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800204:	02500993          	li	s3,37
  800208:	a011                	j	80020c <vprintfmt+0x54>
            if (ch == '\0') {
  80020a:	c121                	beqz	a0,80024a <vprintfmt+0x92>
            putch(ch, putdat);
  80020c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800210:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	fff44503          	lbu	a0,-1(s0)
  800216:	ff351ae3          	bne	a0,s3,80020a <vprintfmt+0x52>
  80021a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80021e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800222:	4981                	li	s3,0
  800224:	4801                	li	a6,0
        width = precision = -1;
  800226:	5cfd                	li	s9,-1
  800228:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80022a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80022e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800230:	fdd6069b          	addiw	a3,a2,-35
  800234:	0ff6f693          	andi	a3,a3,255
  800238:	00140d13          	addi	s10,s0,1
  80023c:	1ed5ef63          	bltu	a1,a3,80043a <vprintfmt+0x282>
  800240:	068a                	slli	a3,a3,0x2
  800242:	96d2                	add	a3,a3,s4
  800244:	4294                	lw	a3,0(a3)
  800246:	96d2                	add	a3,a3,s4
  800248:	8682                	jr	a3
}
  80024a:	70e6                	ld	ra,120(sp)
  80024c:	7446                	ld	s0,112(sp)
  80024e:	74a6                	ld	s1,104(sp)
  800250:	7906                	ld	s2,96(sp)
  800252:	69e6                	ld	s3,88(sp)
  800254:	6a46                	ld	s4,80(sp)
  800256:	6aa6                	ld	s5,72(sp)
  800258:	6b06                	ld	s6,64(sp)
  80025a:	7be2                	ld	s7,56(sp)
  80025c:	7c42                	ld	s8,48(sp)
  80025e:	7ca2                	ld	s9,40(sp)
  800260:	7d02                	ld	s10,32(sp)
  800262:	6de2                	ld	s11,24(sp)
  800264:	6109                	addi	sp,sp,128
  800266:	8082                	ret
            padc = '-';
  800268:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80026a:	00144603          	lbu	a2,1(s0)
  80026e:	846a                	mv	s0,s10
  800270:	b7c1                	j	800230 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800272:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800276:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80027a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80027c:	846a                	mv	s0,s10
            if (width < 0)
  80027e:	fa0dd9e3          	bgez	s11,800230 <vprintfmt+0x78>
                width = precision, precision = -1;
  800282:	8de6                	mv	s11,s9
  800284:	5cfd                	li	s9,-1
  800286:	b76d                	j	800230 <vprintfmt+0x78>
            if (width < 0)
  800288:	fffdc693          	not	a3,s11
  80028c:	96fd                	srai	a3,a3,0x3f
  80028e:	00ddfdb3          	and	s11,s11,a3
  800292:	00144603          	lbu	a2,1(s0)
  800296:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800298:	846a                	mv	s0,s10
  80029a:	bf59                	j	800230 <vprintfmt+0x78>
    if (lflag >= 2) {
  80029c:	4705                	li	a4,1
  80029e:	008a8593          	addi	a1,s5,8
  8002a2:	01074463          	blt	a4,a6,8002aa <vprintfmt+0xf2>
    else if (lflag) {
  8002a6:	22080863          	beqz	a6,8004d6 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002aa:	000ab603          	ld	a2,0(s5)
  8002ae:	46c1                	li	a3,16
  8002b0:	8aae                	mv	s5,a1
  8002b2:	a291                	j	8003f6 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002b4:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002b8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002bc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002be:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002c2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002c6:	fad56ce3          	bltu	a0,a3,80027e <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002ca:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002cc:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002d0:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002d4:	0196873b          	addw	a4,a3,s9
  8002d8:	0017171b          	slliw	a4,a4,0x1
  8002dc:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002e0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002e4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002e8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002ec:	fcd57fe3          	bgeu	a0,a3,8002ca <vprintfmt+0x112>
  8002f0:	b779                	j	80027e <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002f2:	000aa503          	lw	a0,0(s5)
  8002f6:	85a6                	mv	a1,s1
  8002f8:	0aa1                	addi	s5,s5,8
  8002fa:	9902                	jalr	s2
            break;
  8002fc:	bddd                	j	8001f2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002fe:	4705                	li	a4,1
  800300:	008a8993          	addi	s3,s5,8
  800304:	01074463          	blt	a4,a6,80030c <vprintfmt+0x154>
    else if (lflag) {
  800308:	1c080463          	beqz	a6,8004d0 <vprintfmt+0x318>
        return va_arg(*ap, long);
  80030c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800310:	1c044a63          	bltz	s0,8004e4 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800314:	8622                	mv	a2,s0
  800316:	8ace                	mv	s5,s3
  800318:	46a9                	li	a3,10
  80031a:	a8f1                	j	8003f6 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  80031c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800320:	4761                	li	a4,24
            err = va_arg(ap, int);
  800322:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800324:	41f7d69b          	sraiw	a3,a5,0x1f
  800328:	8fb5                	xor	a5,a5,a3
  80032a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80032e:	12d74963          	blt	a4,a3,800460 <vprintfmt+0x2a8>
  800332:	00369793          	slli	a5,a3,0x3
  800336:	97e2                	add	a5,a5,s8
  800338:	639c                	ld	a5,0(a5)
  80033a:	12078363          	beqz	a5,800460 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  80033e:	86be                	mv	a3,a5
  800340:	00000617          	auipc	a2,0x0
  800344:	61060613          	addi	a2,a2,1552 # 800950 <error_string+0x1b8>
  800348:	85a6                	mv	a1,s1
  80034a:	854a                	mv	a0,s2
  80034c:	1cc000ef          	jal	ra,800518 <printfmt>
  800350:	b54d                	j	8001f2 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800352:	000ab603          	ld	a2,0(s5)
  800356:	0aa1                	addi	s5,s5,8
  800358:	1a060163          	beqz	a2,8004fa <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  80035c:	00160413          	addi	s0,a2,1
  800360:	15b05763          	blez	s11,8004ae <vprintfmt+0x2f6>
  800364:	02d00593          	li	a1,45
  800368:	10b79d63          	bne	a5,a1,800482 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036c:	00064783          	lbu	a5,0(a2)
  800370:	0007851b          	sext.w	a0,a5
  800374:	c905                	beqz	a0,8003a4 <vprintfmt+0x1ec>
  800376:	000cc563          	bltz	s9,800380 <vprintfmt+0x1c8>
  80037a:	3cfd                	addiw	s9,s9,-1
  80037c:	036c8263          	beq	s9,s6,8003a0 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800380:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800382:	14098f63          	beqz	s3,8004e0 <vprintfmt+0x328>
  800386:	3781                	addiw	a5,a5,-32
  800388:	14fbfc63          	bgeu	s7,a5,8004e0 <vprintfmt+0x328>
                    putch('?', putdat);
  80038c:	03f00513          	li	a0,63
  800390:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800392:	0405                	addi	s0,s0,1
  800394:	fff44783          	lbu	a5,-1(s0)
  800398:	3dfd                	addiw	s11,s11,-1
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	fd61                	bnez	a0,800376 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003a0:	e5b059e3          	blez	s11,8001f2 <vprintfmt+0x3a>
  8003a4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a6:	85a6                	mv	a1,s1
  8003a8:	02000513          	li	a0,32
  8003ac:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ae:	e40d82e3          	beqz	s11,8001f2 <vprintfmt+0x3a>
  8003b2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	02000513          	li	a0,32
  8003ba:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003bc:	fe0d94e3          	bnez	s11,8003a4 <vprintfmt+0x1ec>
  8003c0:	bd0d                	j	8001f2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c2:	4705                	li	a4,1
  8003c4:	008a8593          	addi	a1,s5,8
  8003c8:	01074463          	blt	a4,a6,8003d0 <vprintfmt+0x218>
    else if (lflag) {
  8003cc:	0e080863          	beqz	a6,8004bc <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003d0:	000ab603          	ld	a2,0(s5)
  8003d4:	46a1                	li	a3,8
  8003d6:	8aae                	mv	s5,a1
  8003d8:	a839                	j	8003f6 <vprintfmt+0x23e>
            putch('0', putdat);
  8003da:	03000513          	li	a0,48
  8003de:	85a6                	mv	a1,s1
  8003e0:	e03e                	sd	a5,0(sp)
  8003e2:	9902                	jalr	s2
            putch('x', putdat);
  8003e4:	85a6                	mv	a1,s1
  8003e6:	07800513          	li	a0,120
  8003ea:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ec:	0aa1                	addi	s5,s5,8
  8003ee:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003f2:	6782                	ld	a5,0(sp)
  8003f4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8003f6:	2781                	sext.w	a5,a5
  8003f8:	876e                	mv	a4,s11
  8003fa:	85a6                	mv	a1,s1
  8003fc:	854a                	mv	a0,s2
  8003fe:	d35ff0ef          	jal	ra,800132 <printnum>
            break;
  800402:	bbc5                	j	8001f2 <vprintfmt+0x3a>
            lflag ++;
  800404:	00144603          	lbu	a2,1(s0)
  800408:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80040a:	846a                	mv	s0,s10
            goto reswitch;
  80040c:	b515                	j	800230 <vprintfmt+0x78>
            goto reswitch;
  80040e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800412:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800414:	846a                	mv	s0,s10
            goto reswitch;
  800416:	bd29                	j	800230 <vprintfmt+0x78>
            putch(ch, putdat);
  800418:	85a6                	mv	a1,s1
  80041a:	02500513          	li	a0,37
  80041e:	9902                	jalr	s2
            break;
  800420:	bbc9                	j	8001f2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800422:	4705                	li	a4,1
  800424:	008a8593          	addi	a1,s5,8
  800428:	01074463          	blt	a4,a6,800430 <vprintfmt+0x278>
    else if (lflag) {
  80042c:	08080d63          	beqz	a6,8004c6 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800430:	000ab603          	ld	a2,0(s5)
  800434:	46a9                	li	a3,10
  800436:	8aae                	mv	s5,a1
  800438:	bf7d                	j	8003f6 <vprintfmt+0x23e>
            putch('%', putdat);
  80043a:	85a6                	mv	a1,s1
  80043c:	02500513          	li	a0,37
  800440:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800442:	fff44703          	lbu	a4,-1(s0)
  800446:	02500793          	li	a5,37
  80044a:	8d22                	mv	s10,s0
  80044c:	daf703e3          	beq	a4,a5,8001f2 <vprintfmt+0x3a>
  800450:	02500713          	li	a4,37
  800454:	1d7d                	addi	s10,s10,-1
  800456:	fffd4783          	lbu	a5,-1(s10)
  80045a:	fee79de3          	bne	a5,a4,800454 <vprintfmt+0x29c>
  80045e:	bb51                	j	8001f2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800460:	00000617          	auipc	a2,0x0
  800464:	4e060613          	addi	a2,a2,1248 # 800940 <error_string+0x1a8>
  800468:	85a6                	mv	a1,s1
  80046a:	854a                	mv	a0,s2
  80046c:	0ac000ef          	jal	ra,800518 <printfmt>
  800470:	b349                	j	8001f2 <vprintfmt+0x3a>
                p = "(null)";
  800472:	00000617          	auipc	a2,0x0
  800476:	4c660613          	addi	a2,a2,1222 # 800938 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80047a:	00000417          	auipc	s0,0x0
  80047e:	4bf40413          	addi	s0,s0,1215 # 800939 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800482:	8532                	mv	a0,a2
  800484:	85e6                	mv	a1,s9
  800486:	e032                	sd	a2,0(sp)
  800488:	e43e                	sd	a5,8(sp)
  80048a:	c83ff0ef          	jal	ra,80010c <strnlen>
  80048e:	40ad8dbb          	subw	s11,s11,a0
  800492:	6602                	ld	a2,0(sp)
  800494:	01b05d63          	blez	s11,8004ae <vprintfmt+0x2f6>
  800498:	67a2                	ld	a5,8(sp)
  80049a:	2781                	sext.w	a5,a5
  80049c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80049e:	6522                	ld	a0,8(sp)
  8004a0:	85a6                	mv	a1,s1
  8004a2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004a6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	6602                	ld	a2,0(sp)
  8004aa:	fe0d9ae3          	bnez	s11,80049e <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ae:	00064783          	lbu	a5,0(a2)
  8004b2:	0007851b          	sext.w	a0,a5
  8004b6:	ec0510e3          	bnez	a0,800376 <vprintfmt+0x1be>
  8004ba:	bb25                	j	8001f2 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004bc:	000ae603          	lwu	a2,0(s5)
  8004c0:	46a1                	li	a3,8
  8004c2:	8aae                	mv	s5,a1
  8004c4:	bf0d                	j	8003f6 <vprintfmt+0x23e>
  8004c6:	000ae603          	lwu	a2,0(s5)
  8004ca:	46a9                	li	a3,10
  8004cc:	8aae                	mv	s5,a1
  8004ce:	b725                	j	8003f6 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004d0:	000aa403          	lw	s0,0(s5)
  8004d4:	bd35                	j	800310 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004d6:	000ae603          	lwu	a2,0(s5)
  8004da:	46c1                	li	a3,16
  8004dc:	8aae                	mv	s5,a1
  8004de:	bf21                	j	8003f6 <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004e0:	9902                	jalr	s2
  8004e2:	bd45                	j	800392 <vprintfmt+0x1da>
                putch('-', putdat);
  8004e4:	85a6                	mv	a1,s1
  8004e6:	02d00513          	li	a0,45
  8004ea:	e03e                	sd	a5,0(sp)
  8004ec:	9902                	jalr	s2
                num = -(long long)num;
  8004ee:	8ace                	mv	s5,s3
  8004f0:	40800633          	neg	a2,s0
  8004f4:	46a9                	li	a3,10
  8004f6:	6782                	ld	a5,0(sp)
  8004f8:	bdfd                	j	8003f6 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  8004fa:	01b05663          	blez	s11,800506 <vprintfmt+0x34e>
  8004fe:	02d00693          	li	a3,45
  800502:	f6d798e3          	bne	a5,a3,800472 <vprintfmt+0x2ba>
  800506:	00000417          	auipc	s0,0x0
  80050a:	43340413          	addi	s0,s0,1075 # 800939 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050e:	02800513          	li	a0,40
  800512:	02800793          	li	a5,40
  800516:	b585                	j	800376 <vprintfmt+0x1be>

0000000000800518 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80051a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800520:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	ec06                	sd	ra,24(sp)
  800524:	f83a                	sd	a4,48(sp)
  800526:	fc3e                	sd	a5,56(sp)
  800528:	e0c2                	sd	a6,64(sp)
  80052a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80052c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052e:	c8bff0ef          	jal	ra,8001b8 <vprintfmt>
}
  800532:	60e2                	ld	ra,24(sp)
  800534:	6161                	addi	sp,sp,80
  800536:	8082                	ret

0000000000800538 <vsnprintf>:
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  800538:	15fd                	addi	a1,a1,-1
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  80053a:	7179                	addi	sp,sp,-48
    struct sprintbuf b = {str, str + size - 1, 0};
  80053c:	95aa                	add	a1,a1,a0
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  80053e:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800540:	e42a                	sd	a0,8(sp)
  800542:	e82e                	sd	a1,16(sp)
  800544:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  800546:	c10d                	beqz	a0,800568 <vsnprintf+0x30>
  800548:	02a5e063          	bltu	a1,a0,800568 <vsnprintf+0x30>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  80054c:	00000517          	auipc	a0,0x0
  800550:	c5250513          	addi	a0,a0,-942 # 80019e <sprintputch>
  800554:	002c                	addi	a1,sp,8
  800556:	c63ff0ef          	jal	ra,8001b8 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  80055a:	67a2                	ld	a5,8(sp)
  80055c:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800560:	4562                	lw	a0,24(sp)
}
  800562:	70a2                	ld	ra,40(sp)
  800564:	6145                	addi	sp,sp,48
  800566:	8082                	ret
        return -E_INVAL;
  800568:	5575                	li	a0,-3
  80056a:	bfe5                	j	800562 <vsnprintf+0x2a>

000000000080056c <snprintf>:
snprintf(char *str, size_t size, const char *fmt, ...) {
  80056c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80056e:	02810313          	addi	t1,sp,40
snprintf(char *str, size_t size, const char *fmt, ...) {
  800572:	f436                	sd	a3,40(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  800574:	869a                	mv	a3,t1
snprintf(char *str, size_t size, const char *fmt, ...) {
  800576:	ec06                	sd	ra,24(sp)
  800578:	f83a                	sd	a4,48(sp)
  80057a:	fc3e                	sd	a5,56(sp)
  80057c:	e0c2                	sd	a6,64(sp)
  80057e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800580:	e41a                	sd	t1,8(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  800582:	fb7ff0ef          	jal	ra,800538 <vsnprintf>
}
  800586:	60e2                	ld	ra,24(sp)
  800588:	6161                	addi	sp,sp,80
  80058a:	8082                	ret

000000000080058c <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80058c:	1141                	addi	sp,sp,-16
  80058e:	e406                	sd	ra,8(sp)
  800590:	e022                	sd	s0,0(sp)
  800592:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800594:	af9ff0ef          	jal	ra,80008c <getpid>
  800598:	8622                	mv	a2,s0
  80059a:	85aa                	mv	a1,a0
  80059c:	00000517          	auipc	a0,0x0
  8005a0:	3c450513          	addi	a0,a0,964 # 800960 <error_string+0x1c8>
  8005a4:	b0bff0ef          	jal	ra,8000ae <cprintf>

    forkchild(cur, '0');
  8005a8:	8522                	mv	a0,s0
  8005aa:	03000593          	li	a1,48
  8005ae:	012000ef          	jal	ra,8005c0 <forkchild>
    forkchild(cur, '1');
  8005b2:	8522                	mv	a0,s0
}
  8005b4:	6402                	ld	s0,0(sp)
  8005b6:	60a2                	ld	ra,8(sp)
    forkchild(cur, '1');
  8005b8:	03100593          	li	a1,49
}
  8005bc:	0141                	addi	sp,sp,16
    forkchild(cur, '1');
  8005be:	a009                	j	8005c0 <forkchild>

00000000008005c0 <forkchild>:
forkchild(const char *cur, char branch) {
  8005c0:	7179                	addi	sp,sp,-48
  8005c2:	f022                	sd	s0,32(sp)
  8005c4:	ec26                	sd	s1,24(sp)
  8005c6:	f406                	sd	ra,40(sp)
  8005c8:	842a                	mv	s0,a0
  8005ca:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005cc:	b23ff0ef          	jal	ra,8000ee <strlen>
  8005d0:	478d                	li	a5,3
  8005d2:	00a7f763          	bgeu	a5,a0,8005e0 <forkchild+0x20>
}
  8005d6:	70a2                	ld	ra,40(sp)
  8005d8:	7402                	ld	s0,32(sp)
  8005da:	64e2                	ld	s1,24(sp)
  8005dc:	6145                	addi	sp,sp,48
  8005de:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005e0:	8726                	mv	a4,s1
  8005e2:	86a2                	mv	a3,s0
  8005e4:	00000617          	auipc	a2,0x0
  8005e8:	37460613          	addi	a2,a2,884 # 800958 <error_string+0x1c0>
  8005ec:	4595                	li	a1,5
  8005ee:	0028                	addi	a0,sp,8
  8005f0:	f7dff0ef          	jal	ra,80056c <snprintf>
    if (fork() == 0) {
  8005f4:	a95ff0ef          	jal	ra,800088 <fork>
  8005f8:	fd79                	bnez	a0,8005d6 <forkchild+0x16>
        forktree(nxt);
  8005fa:	0028                	addi	a0,sp,8
  8005fc:	f91ff0ef          	jal	ra,80058c <forktree>
        yield();
  800600:	a8bff0ef          	jal	ra,80008a <yield>
        exit(0);
  800604:	4501                	li	a0,0
  800606:	a6dff0ef          	jal	ra,800072 <exit>

000000000080060a <main>:

int
main(void) {
  80060a:	1141                	addi	sp,sp,-16
    forktree("");
  80060c:	00000517          	auipc	a0,0x0
  800610:	36450513          	addi	a0,a0,868 # 800970 <error_string+0x1d8>
main(void) {
  800614:	e406                	sd	ra,8(sp)
    forktree("");
  800616:	f77ff0ef          	jal	ra,80058c <forktree>
    return 0;
}
  80061a:	60a2                	ld	ra,8(sp)
  80061c:	4501                	li	a0,0
  80061e:	0141                	addi	sp,sp,16
  800620:	8082                	ret
