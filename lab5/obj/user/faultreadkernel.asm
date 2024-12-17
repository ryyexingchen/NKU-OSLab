
obj/__user_faultreadkernel.out：     文件格式 elf64-littleriscv


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
  800032:	55250513          	addi	a0,a0,1362 # 800580 <main+0x32>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0ba000ef          	jal	ra,8000fc <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	092000ef          	jal	ra,8000dc <vcprintf>
    cprintf("\n");
  80004e:	00000517          	auipc	a0,0x0
  800052:	55250513          	addi	a0,a0,1362 # 8005a0 <main+0x52>
  800056:	0a6000ef          	jal	ra,8000fc <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	04a000ef          	jal	ra,8000a6 <exit>

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

00000000008000a0 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000a0:	85aa                	mv	a1,a0
  8000a2:	4579                	li	a0,30
  8000a4:	bf75                	j	800060 <syscall>

00000000008000a6 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000a6:	1141                	addi	sp,sp,-16
  8000a8:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000aa:	ff1ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ae:	00000517          	auipc	a0,0x0
  8000b2:	4fa50513          	addi	a0,a0,1274 # 8005a8 <main+0x5a>
  8000b6:	046000ef          	jal	ra,8000fc <cprintf>
    while (1);
  8000ba:	a001                	j	8000ba <exit+0x14>

00000000008000bc <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000bc:	074000ef          	jal	ra,800130 <umain>
1:  j 1b
  8000c0:	a001                	j	8000c0 <_start+0x4>

00000000008000c2 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e022                	sd	s0,0(sp)
  8000c6:	e406                	sd	ra,8(sp)
  8000c8:	842e                	mv	s0,a1
    sys_putc(c);
  8000ca:	fd7ff0ef          	jal	ra,8000a0 <sys_putc>
    (*cnt) ++;
  8000ce:	401c                	lw	a5,0(s0)
}
  8000d0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000d2:	2785                	addiw	a5,a5,1
  8000d4:	c01c                	sw	a5,0(s0)
}
  8000d6:	6402                	ld	s0,0(sp)
  8000d8:	0141                	addi	sp,sp,16
  8000da:	8082                	ret

00000000008000dc <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000dc:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000de:	86ae                	mv	a3,a1
  8000e0:	862a                	mv	a2,a0
  8000e2:	006c                	addi	a1,sp,12
  8000e4:	00000517          	auipc	a0,0x0
  8000e8:	fde50513          	addi	a0,a0,-34 # 8000c2 <cputch>
vcprintf(const char *fmt, va_list ap) {
  8000ec:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  8000ee:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f0:	0de000ef          	jal	ra,8001ce <vprintfmt>
    return cnt;
}
  8000f4:	60e2                	ld	ra,24(sp)
  8000f6:	4532                	lw	a0,12(sp)
  8000f8:	6105                	addi	sp,sp,32
  8000fa:	8082                	ret

00000000008000fc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000fc:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000fe:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800102:	f42e                	sd	a1,40(sp)
  800104:	f832                	sd	a2,48(sp)
  800106:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800108:	862a                	mv	a2,a0
  80010a:	004c                	addi	a1,sp,4
  80010c:	00000517          	auipc	a0,0x0
  800110:	fb650513          	addi	a0,a0,-74 # 8000c2 <cputch>
  800114:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800116:	ec06                	sd	ra,24(sp)
  800118:	e0ba                	sd	a4,64(sp)
  80011a:	e4be                	sd	a5,72(sp)
  80011c:	e8c2                	sd	a6,80(sp)
  80011e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800120:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800122:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800124:	0aa000ef          	jal	ra,8001ce <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800128:	60e2                	ld	ra,24(sp)
  80012a:	4512                	lw	a0,4(sp)
  80012c:	6125                	addi	sp,sp,96
  80012e:	8082                	ret

0000000000800130 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    int ret = main();
  800134:	41a000ef          	jal	ra,80054e <main>
    exit(ret);
  800138:	f6fff0ef          	jal	ra,8000a6 <exit>

000000000080013c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80013c:	c185                	beqz	a1,80015c <strnlen+0x20>
  80013e:	00054783          	lbu	a5,0(a0)
  800142:	cf89                	beqz	a5,80015c <strnlen+0x20>
    size_t cnt = 0;
  800144:	4781                	li	a5,0
  800146:	a021                	j	80014e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800148:	00074703          	lbu	a4,0(a4)
  80014c:	c711                	beqz	a4,800158 <strnlen+0x1c>
        cnt ++;
  80014e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800150:	00f50733          	add	a4,a0,a5
  800154:	fef59ae3          	bne	a1,a5,800148 <strnlen+0xc>
    }
    return cnt;
}
  800158:	853e                	mv	a0,a5
  80015a:	8082                	ret
    size_t cnt = 0;
  80015c:	4781                	li	a5,0
}
  80015e:	853e                	mv	a0,a5
  800160:	8082                	ret

0000000000800162 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800162:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800168:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	f022                	sd	s0,32(sp)
  800174:	ec26                	sd	s1,24(sp)
  800176:	e84a                	sd	s2,16(sp)
  800178:	f406                	sd	ra,40(sp)
  80017a:	e44e                	sd	s3,8(sp)
  80017c:	84aa                	mv	s1,a0
  80017e:	892e                	mv	s2,a1
  800180:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800184:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800186:	03067e63          	bgeu	a2,a6,8001c2 <printnum+0x60>
  80018a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018c:	00805763          	blez	s0,80019a <printnum+0x38>
  800190:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800192:	85ca                	mv	a1,s2
  800194:	854e                	mv	a0,s3
  800196:	9482                	jalr	s1
        while (-- width > 0)
  800198:	fc65                	bnez	s0,800190 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019a:	1a02                	slli	s4,s4,0x20
  80019c:	020a5a13          	srli	s4,s4,0x20
  8001a0:	00000797          	auipc	a5,0x0
  8001a4:	64078793          	addi	a5,a5,1600 # 8007e0 <error_string+0xc8>
  8001a8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001aa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ac:	000a4503          	lbu	a0,0(s4)
}
  8001b0:	70a2                	ld	ra,40(sp)
  8001b2:	69a2                	ld	s3,8(sp)
  8001b4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	85ca                	mv	a1,s2
  8001b8:	8326                	mv	t1,s1
}
  8001ba:	6942                	ld	s2,16(sp)
  8001bc:	64e2                	ld	s1,24(sp)
  8001be:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c2:	03065633          	divu	a2,a2,a6
  8001c6:	8722                	mv	a4,s0
  8001c8:	f9bff0ef          	jal	ra,800162 <printnum>
  8001cc:	b7f9                	j	80019a <printnum+0x38>

00000000008001ce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ce:	7119                	addi	sp,sp,-128
  8001d0:	f4a6                	sd	s1,104(sp)
  8001d2:	f0ca                	sd	s2,96(sp)
  8001d4:	e8d2                	sd	s4,80(sp)
  8001d6:	e4d6                	sd	s5,72(sp)
  8001d8:	e0da                	sd	s6,64(sp)
  8001da:	fc5e                	sd	s7,56(sp)
  8001dc:	f862                	sd	s8,48(sp)
  8001de:	f06a                	sd	s10,32(sp)
  8001e0:	fc86                	sd	ra,120(sp)
  8001e2:	f8a2                	sd	s0,112(sp)
  8001e4:	ecce                	sd	s3,88(sp)
  8001e6:	f466                	sd	s9,40(sp)
  8001e8:	ec6e                	sd	s11,24(sp)
  8001ea:	892a                	mv	s2,a0
  8001ec:	84ae                	mv	s1,a1
  8001ee:	8d32                	mv	s10,a2
  8001f0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f4:	00000a17          	auipc	s4,0x0
  8001f8:	3c8a0a13          	addi	s4,s4,968 # 8005bc <main+0x6e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001fc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800200:	00000c17          	auipc	s8,0x0
  800204:	518c0c13          	addi	s8,s8,1304 # 800718 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800208:	000d4503          	lbu	a0,0(s10)
  80020c:	02500793          	li	a5,37
  800210:	001d0413          	addi	s0,s10,1
  800214:	00f50e63          	beq	a0,a5,800230 <vprintfmt+0x62>
            if (ch == '\0') {
  800218:	c521                	beqz	a0,800260 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021a:	02500993          	li	s3,37
  80021e:	a011                	j	800222 <vprintfmt+0x54>
            if (ch == '\0') {
  800220:	c121                	beqz	a0,800260 <vprintfmt+0x92>
            putch(ch, putdat);
  800222:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800224:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800226:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	fff44503          	lbu	a0,-1(s0)
  80022c:	ff351ae3          	bne	a0,s3,800220 <vprintfmt+0x52>
  800230:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800234:	02000793          	li	a5,32
        lflag = altflag = 0;
  800238:	4981                	li	s3,0
  80023a:	4801                	li	a6,0
        width = precision = -1;
  80023c:	5cfd                	li	s9,-1
  80023e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800244:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800246:	fdd6069b          	addiw	a3,a2,-35
  80024a:	0ff6f693          	andi	a3,a3,255
  80024e:	00140d13          	addi	s10,s0,1
  800252:	1ed5ef63          	bltu	a1,a3,800450 <vprintfmt+0x282>
  800256:	068a                	slli	a3,a3,0x2
  800258:	96d2                	add	a3,a3,s4
  80025a:	4294                	lw	a3,0(a3)
  80025c:	96d2                	add	a3,a3,s4
  80025e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800260:	70e6                	ld	ra,120(sp)
  800262:	7446                	ld	s0,112(sp)
  800264:	74a6                	ld	s1,104(sp)
  800266:	7906                	ld	s2,96(sp)
  800268:	69e6                	ld	s3,88(sp)
  80026a:	6a46                	ld	s4,80(sp)
  80026c:	6aa6                	ld	s5,72(sp)
  80026e:	6b06                	ld	s6,64(sp)
  800270:	7be2                	ld	s7,56(sp)
  800272:	7c42                	ld	s8,48(sp)
  800274:	7ca2                	ld	s9,40(sp)
  800276:	7d02                	ld	s10,32(sp)
  800278:	6de2                	ld	s11,24(sp)
  80027a:	6109                	addi	sp,sp,128
  80027c:	8082                	ret
            padc = '-';
  80027e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800280:	00144603          	lbu	a2,1(s0)
  800284:	846a                	mv	s0,s10
  800286:	b7c1                	j	800246 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800288:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80028c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800290:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800292:	846a                	mv	s0,s10
            if (width < 0)
  800294:	fa0dd9e3          	bgez	s11,800246 <vprintfmt+0x78>
                width = precision, precision = -1;
  800298:	8de6                	mv	s11,s9
  80029a:	5cfd                	li	s9,-1
  80029c:	b76d                	j	800246 <vprintfmt+0x78>
            if (width < 0)
  80029e:	fffdc693          	not	a3,s11
  8002a2:	96fd                	srai	a3,a3,0x3f
  8002a4:	00ddfdb3          	and	s11,s11,a3
  8002a8:	00144603          	lbu	a2,1(s0)
  8002ac:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002ae:	846a                	mv	s0,s10
  8002b0:	bf59                	j	800246 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002b2:	4705                	li	a4,1
  8002b4:	008a8593          	addi	a1,s5,8
  8002b8:	01074463          	blt	a4,a6,8002c0 <vprintfmt+0xf2>
    else if (lflag) {
  8002bc:	22080863          	beqz	a6,8004ec <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002c0:	000ab603          	ld	a2,0(s5)
  8002c4:	46c1                	li	a3,16
  8002c6:	8aae                	mv	s5,a1
  8002c8:	a291                	j	80040c <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002ca:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002ce:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002d2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002d4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002d8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002dc:	fad56ce3          	bltu	a0,a3,800294 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002e0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002e2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002e6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002ea:	0196873b          	addw	a4,a3,s9
  8002ee:	0017171b          	slliw	a4,a4,0x1
  8002f2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002f6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002fa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002fe:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800302:	fcd57fe3          	bgeu	a0,a3,8002e0 <vprintfmt+0x112>
  800306:	b779                	j	800294 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800308:	000aa503          	lw	a0,0(s5)
  80030c:	85a6                	mv	a1,s1
  80030e:	0aa1                	addi	s5,s5,8
  800310:	9902                	jalr	s2
            break;
  800312:	bddd                	j	800208 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800314:	4705                	li	a4,1
  800316:	008a8993          	addi	s3,s5,8
  80031a:	01074463          	blt	a4,a6,800322 <vprintfmt+0x154>
    else if (lflag) {
  80031e:	1c080463          	beqz	a6,8004e6 <vprintfmt+0x318>
        return va_arg(*ap, long);
  800322:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800326:	1c044a63          	bltz	s0,8004fa <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  80032a:	8622                	mv	a2,s0
  80032c:	8ace                	mv	s5,s3
  80032e:	46a9                	li	a3,10
  800330:	a8f1                	j	80040c <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800332:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800336:	4761                	li	a4,24
            err = va_arg(ap, int);
  800338:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80033a:	41f7d69b          	sraiw	a3,a5,0x1f
  80033e:	8fb5                	xor	a5,a5,a3
  800340:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800344:	12d74963          	blt	a4,a3,800476 <vprintfmt+0x2a8>
  800348:	00369793          	slli	a5,a3,0x3
  80034c:	97e2                	add	a5,a5,s8
  80034e:	639c                	ld	a5,0(a5)
  800350:	12078363          	beqz	a5,800476 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800354:	86be                	mv	a3,a5
  800356:	00000617          	auipc	a2,0x0
  80035a:	57a60613          	addi	a2,a2,1402 # 8008d0 <error_string+0x1b8>
  80035e:	85a6                	mv	a1,s1
  800360:	854a                	mv	a0,s2
  800362:	1cc000ef          	jal	ra,80052e <printfmt>
  800366:	b54d                	j	800208 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800368:	000ab603          	ld	a2,0(s5)
  80036c:	0aa1                	addi	s5,s5,8
  80036e:	1a060163          	beqz	a2,800510 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800372:	00160413          	addi	s0,a2,1
  800376:	15b05763          	blez	s11,8004c4 <vprintfmt+0x2f6>
  80037a:	02d00593          	li	a1,45
  80037e:	10b79d63          	bne	a5,a1,800498 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	00064783          	lbu	a5,0(a2)
  800386:	0007851b          	sext.w	a0,a5
  80038a:	c905                	beqz	a0,8003ba <vprintfmt+0x1ec>
  80038c:	000cc563          	bltz	s9,800396 <vprintfmt+0x1c8>
  800390:	3cfd                	addiw	s9,s9,-1
  800392:	036c8263          	beq	s9,s6,8003b6 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800396:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800398:	14098f63          	beqz	s3,8004f6 <vprintfmt+0x328>
  80039c:	3781                	addiw	a5,a5,-32
  80039e:	14fbfc63          	bgeu	s7,a5,8004f6 <vprintfmt+0x328>
                    putch('?', putdat);
  8003a2:	03f00513          	li	a0,63
  8003a6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a8:	0405                	addi	s0,s0,1
  8003aa:	fff44783          	lbu	a5,-1(s0)
  8003ae:	3dfd                	addiw	s11,s11,-1
  8003b0:	0007851b          	sext.w	a0,a5
  8003b4:	fd61                	bnez	a0,80038c <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003b6:	e5b059e3          	blez	s11,800208 <vprintfmt+0x3a>
  8003ba:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003bc:	85a6                	mv	a1,s1
  8003be:	02000513          	li	a0,32
  8003c2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c4:	e40d82e3          	beqz	s11,800208 <vprintfmt+0x3a>
  8003c8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ca:	85a6                	mv	a1,s1
  8003cc:	02000513          	li	a0,32
  8003d0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003d2:	fe0d94e3          	bnez	s11,8003ba <vprintfmt+0x1ec>
  8003d6:	bd0d                	j	800208 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003d8:	4705                	li	a4,1
  8003da:	008a8593          	addi	a1,s5,8
  8003de:	01074463          	blt	a4,a6,8003e6 <vprintfmt+0x218>
    else if (lflag) {
  8003e2:	0e080863          	beqz	a6,8004d2 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003e6:	000ab603          	ld	a2,0(s5)
  8003ea:	46a1                	li	a3,8
  8003ec:	8aae                	mv	s5,a1
  8003ee:	a839                	j	80040c <vprintfmt+0x23e>
            putch('0', putdat);
  8003f0:	03000513          	li	a0,48
  8003f4:	85a6                	mv	a1,s1
  8003f6:	e03e                	sd	a5,0(sp)
  8003f8:	9902                	jalr	s2
            putch('x', putdat);
  8003fa:	85a6                	mv	a1,s1
  8003fc:	07800513          	li	a0,120
  800400:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800402:	0aa1                	addi	s5,s5,8
  800404:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800408:	6782                	ld	a5,0(sp)
  80040a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80040c:	2781                	sext.w	a5,a5
  80040e:	876e                	mv	a4,s11
  800410:	85a6                	mv	a1,s1
  800412:	854a                	mv	a0,s2
  800414:	d4fff0ef          	jal	ra,800162 <printnum>
            break;
  800418:	bbc5                	j	800208 <vprintfmt+0x3a>
            lflag ++;
  80041a:	00144603          	lbu	a2,1(s0)
  80041e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800420:	846a                	mv	s0,s10
            goto reswitch;
  800422:	b515                	j	800246 <vprintfmt+0x78>
            goto reswitch;
  800424:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800428:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80042a:	846a                	mv	s0,s10
            goto reswitch;
  80042c:	bd29                	j	800246 <vprintfmt+0x78>
            putch(ch, putdat);
  80042e:	85a6                	mv	a1,s1
  800430:	02500513          	li	a0,37
  800434:	9902                	jalr	s2
            break;
  800436:	bbc9                	j	800208 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800438:	4705                	li	a4,1
  80043a:	008a8593          	addi	a1,s5,8
  80043e:	01074463          	blt	a4,a6,800446 <vprintfmt+0x278>
    else if (lflag) {
  800442:	08080d63          	beqz	a6,8004dc <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800446:	000ab603          	ld	a2,0(s5)
  80044a:	46a9                	li	a3,10
  80044c:	8aae                	mv	s5,a1
  80044e:	bf7d                	j	80040c <vprintfmt+0x23e>
            putch('%', putdat);
  800450:	85a6                	mv	a1,s1
  800452:	02500513          	li	a0,37
  800456:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800458:	fff44703          	lbu	a4,-1(s0)
  80045c:	02500793          	li	a5,37
  800460:	8d22                	mv	s10,s0
  800462:	daf703e3          	beq	a4,a5,800208 <vprintfmt+0x3a>
  800466:	02500713          	li	a4,37
  80046a:	1d7d                	addi	s10,s10,-1
  80046c:	fffd4783          	lbu	a5,-1(s10)
  800470:	fee79de3          	bne	a5,a4,80046a <vprintfmt+0x29c>
  800474:	bb51                	j	800208 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800476:	00000617          	auipc	a2,0x0
  80047a:	44a60613          	addi	a2,a2,1098 # 8008c0 <error_string+0x1a8>
  80047e:	85a6                	mv	a1,s1
  800480:	854a                	mv	a0,s2
  800482:	0ac000ef          	jal	ra,80052e <printfmt>
  800486:	b349                	j	800208 <vprintfmt+0x3a>
                p = "(null)";
  800488:	00000617          	auipc	a2,0x0
  80048c:	43060613          	addi	a2,a2,1072 # 8008b8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800490:	00000417          	auipc	s0,0x0
  800494:	42940413          	addi	s0,s0,1065 # 8008b9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800498:	8532                	mv	a0,a2
  80049a:	85e6                	mv	a1,s9
  80049c:	e032                	sd	a2,0(sp)
  80049e:	e43e                	sd	a5,8(sp)
  8004a0:	c9dff0ef          	jal	ra,80013c <strnlen>
  8004a4:	40ad8dbb          	subw	s11,s11,a0
  8004a8:	6602                	ld	a2,0(sp)
  8004aa:	01b05d63          	blez	s11,8004c4 <vprintfmt+0x2f6>
  8004ae:	67a2                	ld	a5,8(sp)
  8004b0:	2781                	sext.w	a5,a5
  8004b2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004b4:	6522                	ld	a0,8(sp)
  8004b6:	85a6                	mv	a1,s1
  8004b8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ba:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004bc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004be:	6602                	ld	a2,0(sp)
  8004c0:	fe0d9ae3          	bnez	s11,8004b4 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	00064783          	lbu	a5,0(a2)
  8004c8:	0007851b          	sext.w	a0,a5
  8004cc:	ec0510e3          	bnez	a0,80038c <vprintfmt+0x1be>
  8004d0:	bb25                	j	800208 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004d2:	000ae603          	lwu	a2,0(s5)
  8004d6:	46a1                	li	a3,8
  8004d8:	8aae                	mv	s5,a1
  8004da:	bf0d                	j	80040c <vprintfmt+0x23e>
  8004dc:	000ae603          	lwu	a2,0(s5)
  8004e0:	46a9                	li	a3,10
  8004e2:	8aae                	mv	s5,a1
  8004e4:	b725                	j	80040c <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004e6:	000aa403          	lw	s0,0(s5)
  8004ea:	bd35                	j	800326 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004ec:	000ae603          	lwu	a2,0(s5)
  8004f0:	46c1                	li	a3,16
  8004f2:	8aae                	mv	s5,a1
  8004f4:	bf21                	j	80040c <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004f6:	9902                	jalr	s2
  8004f8:	bd45                	j	8003a8 <vprintfmt+0x1da>
                putch('-', putdat);
  8004fa:	85a6                	mv	a1,s1
  8004fc:	02d00513          	li	a0,45
  800500:	e03e                	sd	a5,0(sp)
  800502:	9902                	jalr	s2
                num = -(long long)num;
  800504:	8ace                	mv	s5,s3
  800506:	40800633          	neg	a2,s0
  80050a:	46a9                	li	a3,10
  80050c:	6782                	ld	a5,0(sp)
  80050e:	bdfd                	j	80040c <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800510:	01b05663          	blez	s11,80051c <vprintfmt+0x34e>
  800514:	02d00693          	li	a3,45
  800518:	f6d798e3          	bne	a5,a3,800488 <vprintfmt+0x2ba>
  80051c:	00000417          	auipc	s0,0x0
  800520:	39d40413          	addi	s0,s0,925 # 8008b9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800524:	02800513          	li	a0,40
  800528:	02800793          	li	a5,40
  80052c:	b585                	j	80038c <vprintfmt+0x1be>

000000000080052e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800530:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800534:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800536:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800538:	ec06                	sd	ra,24(sp)
  80053a:	f83a                	sd	a4,48(sp)
  80053c:	fc3e                	sd	a5,56(sp)
  80053e:	e0c2                	sd	a6,64(sp)
  800540:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800542:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800544:	c8bff0ef          	jal	ra,8001ce <vprintfmt>
}
  800548:	60e2                	ld	ra,24(sp)
  80054a:	6161                	addi	sp,sp,80
  80054c:	8082                	ret

000000000080054e <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  80054e:	3eb00793          	li	a5,1003
  800552:	07da                	slli	a5,a5,0x16
  800554:	438c                	lw	a1,0(a5)
main(void) {
  800556:	1141                	addi	sp,sp,-16
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800558:	00000517          	auipc	a0,0x0
  80055c:	38050513          	addi	a0,a0,896 # 8008d8 <error_string+0x1c0>
main(void) {
  800560:	e406                	sd	ra,8(sp)
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800562:	b9bff0ef          	jal	ra,8000fc <cprintf>
    panic("FAIL: T.T\n");
  800566:	00000617          	auipc	a2,0x0
  80056a:	39260613          	addi	a2,a2,914 # 8008f8 <error_string+0x1e0>
  80056e:	459d                	li	a1,7
  800570:	00000517          	auipc	a0,0x0
  800574:	39850513          	addi	a0,a0,920 # 800908 <error_string+0x1f0>
  800578:	aa9ff0ef          	jal	ra,800020 <__panic>
