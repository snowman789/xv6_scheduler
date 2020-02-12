
_shutdown:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  shutdown();
  11:	e8 3a 02 00 00       	call   250 <shutdown>
  exit();
  16:	e8 8d 01 00 00       	call   1a8 <exit>

0000001b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  1b:	55                   	push   %ebp
  1c:	89 e5                	mov    %esp,%ebp
  1e:	53                   	push   %ebx
  1f:	8b 45 08             	mov    0x8(%ebp),%eax
  22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  25:	89 c2                	mov    %eax,%edx
  27:	0f b6 19             	movzbl (%ecx),%ebx
  2a:	88 1a                	mov    %bl,(%edx)
  2c:	8d 52 01             	lea    0x1(%edx),%edx
  2f:	8d 49 01             	lea    0x1(%ecx),%ecx
  32:	84 db                	test   %bl,%bl
  34:	75 f1                	jne    27 <strcpy+0xc>
    ;
  return os;
}
  36:	5b                   	pop    %ebx
  37:	5d                   	pop    %ebp
  38:	c3                   	ret    

00000039 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  39:	55                   	push   %ebp
  3a:	89 e5                	mov    %esp,%ebp
  3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  42:	eb 06                	jmp    4a <strcmp+0x11>
    p++, q++;
  44:	83 c1 01             	add    $0x1,%ecx
  47:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  4a:	0f b6 01             	movzbl (%ecx),%eax
  4d:	84 c0                	test   %al,%al
  4f:	74 04                	je     55 <strcmp+0x1c>
  51:	3a 02                	cmp    (%edx),%al
  53:	74 ef                	je     44 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  55:	0f b6 c0             	movzbl %al,%eax
  58:	0f b6 12             	movzbl (%edx),%edx
  5b:	29 d0                	sub    %edx,%eax
}
  5d:	5d                   	pop    %ebp
  5e:	c3                   	ret    

0000005f <strlen>:

uint
strlen(const char *s)
{
  5f:	55                   	push   %ebp
  60:	89 e5                	mov    %esp,%ebp
  62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  65:	ba 00 00 00 00       	mov    $0x0,%edx
  6a:	eb 03                	jmp    6f <strlen+0x10>
  6c:	83 c2 01             	add    $0x1,%edx
  6f:	89 d0                	mov    %edx,%eax
  71:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  75:	75 f5                	jne    6c <strlen+0xd>
    ;
  return n;
}
  77:	5d                   	pop    %ebp
  78:	c3                   	ret    

00000079 <memset>:

void*
memset(void *dst, int c, uint n)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	57                   	push   %edi
  7d:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  80:	89 d7                	mov    %edx,%edi
  82:	8b 4d 10             	mov    0x10(%ebp),%ecx
  85:	8b 45 0c             	mov    0xc(%ebp),%eax
  88:	fc                   	cld    
  89:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  8b:	89 d0                	mov    %edx,%eax
  8d:	5f                   	pop    %edi
  8e:	5d                   	pop    %ebp
  8f:	c3                   	ret    

00000090 <strchr>:

char*
strchr(const char *s, char c)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  9a:	0f b6 10             	movzbl (%eax),%edx
  9d:	84 d2                	test   %dl,%dl
  9f:	74 09                	je     aa <strchr+0x1a>
    if(*s == c)
  a1:	38 ca                	cmp    %cl,%dl
  a3:	74 0a                	je     af <strchr+0x1f>
  for(; *s; s++)
  a5:	83 c0 01             	add    $0x1,%eax
  a8:	eb f0                	jmp    9a <strchr+0xa>
      return (char*)s;
  return 0;
  aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  af:	5d                   	pop    %ebp
  b0:	c3                   	ret    

000000b1 <gets>:

char*
gets(char *buf, int max)
{
  b1:	55                   	push   %ebp
  b2:	89 e5                	mov    %esp,%ebp
  b4:	57                   	push   %edi
  b5:	56                   	push   %esi
  b6:	53                   	push   %ebx
  b7:	83 ec 1c             	sub    $0x1c,%esp
  ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  c2:	8d 73 01             	lea    0x1(%ebx),%esi
  c5:	3b 75 0c             	cmp    0xc(%ebp),%esi
  c8:	7d 2e                	jge    f8 <gets+0x47>
    cc = read(0, &c, 1);
  ca:	83 ec 04             	sub    $0x4,%esp
  cd:	6a 01                	push   $0x1
  cf:	8d 45 e7             	lea    -0x19(%ebp),%eax
  d2:	50                   	push   %eax
  d3:	6a 00                	push   $0x0
  d5:	e8 e6 00 00 00       	call   1c0 <read>
    if(cc < 1)
  da:	83 c4 10             	add    $0x10,%esp
  dd:	85 c0                	test   %eax,%eax
  df:	7e 17                	jle    f8 <gets+0x47>
      break;
    buf[i++] = c;
  e1:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  e5:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  e8:	3c 0a                	cmp    $0xa,%al
  ea:	0f 94 c2             	sete   %dl
  ed:	3c 0d                	cmp    $0xd,%al
  ef:	0f 94 c0             	sete   %al
    buf[i++] = c;
  f2:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
  f4:	08 c2                	or     %al,%dl
  f6:	74 ca                	je     c2 <gets+0x11>
      break;
  }
  buf[i] = '\0';
  f8:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
  fc:	89 f8                	mov    %edi,%eax
  fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
 101:	5b                   	pop    %ebx
 102:	5e                   	pop    %esi
 103:	5f                   	pop    %edi
 104:	5d                   	pop    %ebp
 105:	c3                   	ret    

00000106 <stat>:

int
stat(const char *n, struct stat *st)
{
 106:	55                   	push   %ebp
 107:	89 e5                	mov    %esp,%ebp
 109:	56                   	push   %esi
 10a:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 10b:	83 ec 08             	sub    $0x8,%esp
 10e:	6a 00                	push   $0x0
 110:	ff 75 08             	pushl  0x8(%ebp)
 113:	e8 d0 00 00 00       	call   1e8 <open>
  if(fd < 0)
 118:	83 c4 10             	add    $0x10,%esp
 11b:	85 c0                	test   %eax,%eax
 11d:	78 24                	js     143 <stat+0x3d>
 11f:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 121:	83 ec 08             	sub    $0x8,%esp
 124:	ff 75 0c             	pushl  0xc(%ebp)
 127:	50                   	push   %eax
 128:	e8 d3 00 00 00       	call   200 <fstat>
 12d:	89 c6                	mov    %eax,%esi
  close(fd);
 12f:	89 1c 24             	mov    %ebx,(%esp)
 132:	e8 99 00 00 00       	call   1d0 <close>
  return r;
 137:	83 c4 10             	add    $0x10,%esp
}
 13a:	89 f0                	mov    %esi,%eax
 13c:	8d 65 f8             	lea    -0x8(%ebp),%esp
 13f:	5b                   	pop    %ebx
 140:	5e                   	pop    %esi
 141:	5d                   	pop    %ebp
 142:	c3                   	ret    
    return -1;
 143:	be ff ff ff ff       	mov    $0xffffffff,%esi
 148:	eb f0                	jmp    13a <stat+0x34>

0000014a <atoi>:

int
atoi(const char *s)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	53                   	push   %ebx
 14e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 151:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 156:	eb 10                	jmp    168 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 158:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 15b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 15e:	83 c1 01             	add    $0x1,%ecx
 161:	0f be d2             	movsbl %dl,%edx
 164:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 168:	0f b6 11             	movzbl (%ecx),%edx
 16b:	8d 5a d0             	lea    -0x30(%edx),%ebx
 16e:	80 fb 09             	cmp    $0x9,%bl
 171:	76 e5                	jbe    158 <atoi+0xe>
  return n;
}
 173:	5b                   	pop    %ebx
 174:	5d                   	pop    %ebp
 175:	c3                   	ret    

00000176 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	56                   	push   %esi
 17a:	53                   	push   %ebx
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 181:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 184:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 186:	eb 0d                	jmp    195 <memmove+0x1f>
    *dst++ = *src++;
 188:	0f b6 13             	movzbl (%ebx),%edx
 18b:	88 11                	mov    %dl,(%ecx)
 18d:	8d 5b 01             	lea    0x1(%ebx),%ebx
 190:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 193:	89 f2                	mov    %esi,%edx
 195:	8d 72 ff             	lea    -0x1(%edx),%esi
 198:	85 d2                	test   %edx,%edx
 19a:	7f ec                	jg     188 <memmove+0x12>
  return vdst;
}
 19c:	5b                   	pop    %ebx
 19d:	5e                   	pop    %esi
 19e:	5d                   	pop    %ebp
 19f:	c3                   	ret    

000001a0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1a0:	b8 01 00 00 00       	mov    $0x1,%eax
 1a5:	cd 40                	int    $0x40
 1a7:	c3                   	ret    

000001a8 <exit>:
SYSCALL(exit)
 1a8:	b8 02 00 00 00       	mov    $0x2,%eax
 1ad:	cd 40                	int    $0x40
 1af:	c3                   	ret    

000001b0 <wait>:
SYSCALL(wait)
 1b0:	b8 03 00 00 00       	mov    $0x3,%eax
 1b5:	cd 40                	int    $0x40
 1b7:	c3                   	ret    

000001b8 <pipe>:
SYSCALL(pipe)
 1b8:	b8 04 00 00 00       	mov    $0x4,%eax
 1bd:	cd 40                	int    $0x40
 1bf:	c3                   	ret    

000001c0 <read>:
SYSCALL(read)
 1c0:	b8 05 00 00 00       	mov    $0x5,%eax
 1c5:	cd 40                	int    $0x40
 1c7:	c3                   	ret    

000001c8 <write>:
SYSCALL(write)
 1c8:	b8 10 00 00 00       	mov    $0x10,%eax
 1cd:	cd 40                	int    $0x40
 1cf:	c3                   	ret    

000001d0 <close>:
SYSCALL(close)
 1d0:	b8 15 00 00 00       	mov    $0x15,%eax
 1d5:	cd 40                	int    $0x40
 1d7:	c3                   	ret    

000001d8 <kill>:
SYSCALL(kill)
 1d8:	b8 06 00 00 00       	mov    $0x6,%eax
 1dd:	cd 40                	int    $0x40
 1df:	c3                   	ret    

000001e0 <exec>:
SYSCALL(exec)
 1e0:	b8 07 00 00 00       	mov    $0x7,%eax
 1e5:	cd 40                	int    $0x40
 1e7:	c3                   	ret    

000001e8 <open>:
SYSCALL(open)
 1e8:	b8 0f 00 00 00       	mov    $0xf,%eax
 1ed:	cd 40                	int    $0x40
 1ef:	c3                   	ret    

000001f0 <mknod>:
SYSCALL(mknod)
 1f0:	b8 11 00 00 00       	mov    $0x11,%eax
 1f5:	cd 40                	int    $0x40
 1f7:	c3                   	ret    

000001f8 <unlink>:
SYSCALL(unlink)
 1f8:	b8 12 00 00 00       	mov    $0x12,%eax
 1fd:	cd 40                	int    $0x40
 1ff:	c3                   	ret    

00000200 <fstat>:
SYSCALL(fstat)
 200:	b8 08 00 00 00       	mov    $0x8,%eax
 205:	cd 40                	int    $0x40
 207:	c3                   	ret    

00000208 <link>:
SYSCALL(link)
 208:	b8 13 00 00 00       	mov    $0x13,%eax
 20d:	cd 40                	int    $0x40
 20f:	c3                   	ret    

00000210 <mkdir>:
SYSCALL(mkdir)
 210:	b8 14 00 00 00       	mov    $0x14,%eax
 215:	cd 40                	int    $0x40
 217:	c3                   	ret    

00000218 <chdir>:
SYSCALL(chdir)
 218:	b8 09 00 00 00       	mov    $0x9,%eax
 21d:	cd 40                	int    $0x40
 21f:	c3                   	ret    

00000220 <dup>:
SYSCALL(dup)
 220:	b8 0a 00 00 00       	mov    $0xa,%eax
 225:	cd 40                	int    $0x40
 227:	c3                   	ret    

00000228 <getpid>:
SYSCALL(getpid)
 228:	b8 0b 00 00 00       	mov    $0xb,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <sbrk>:
SYSCALL(sbrk)
 230:	b8 0c 00 00 00       	mov    $0xc,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <sleep>:
SYSCALL(sleep)
 238:	b8 0d 00 00 00       	mov    $0xd,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <uptime>:
SYSCALL(uptime)
 240:	b8 0e 00 00 00       	mov    $0xe,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <yield>:
SYSCALL(yield)
 248:	b8 16 00 00 00       	mov    $0x16,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <shutdown>:
SYSCALL(shutdown)
 250:	b8 17 00 00 00       	mov    $0x17,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <writecount>:
SYSCALL(writecount)
 258:	b8 18 00 00 00       	mov    $0x18,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <setwritecount>:
SYSCALL(setwritecount)
 260:	b8 19 00 00 00       	mov    $0x19,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <settickets>:
SYSCALL(settickets)
 268:	b8 1a 00 00 00       	mov    $0x1a,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <getprocessesinfo>:
 270:	b8 1b 00 00 00       	mov    $0x1b,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 278:	55                   	push   %ebp
 279:	89 e5                	mov    %esp,%ebp
 27b:	83 ec 1c             	sub    $0x1c,%esp
 27e:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 281:	6a 01                	push   $0x1
 283:	8d 55 f4             	lea    -0xc(%ebp),%edx
 286:	52                   	push   %edx
 287:	50                   	push   %eax
 288:	e8 3b ff ff ff       	call   1c8 <write>
}
 28d:	83 c4 10             	add    $0x10,%esp
 290:	c9                   	leave  
 291:	c3                   	ret    

00000292 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp
 295:	57                   	push   %edi
 296:	56                   	push   %esi
 297:	53                   	push   %ebx
 298:	83 ec 2c             	sub    $0x2c,%esp
 29b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 29d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2a1:	0f 95 c3             	setne  %bl
 2a4:	89 d0                	mov    %edx,%eax
 2a6:	c1 e8 1f             	shr    $0x1f,%eax
 2a9:	84 c3                	test   %al,%bl
 2ab:	74 10                	je     2bd <printint+0x2b>
    neg = 1;
    x = -xx;
 2ad:	f7 da                	neg    %edx
    neg = 1;
 2af:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2b6:	be 00 00 00 00       	mov    $0x0,%esi
 2bb:	eb 0b                	jmp    2c8 <printint+0x36>
  neg = 0;
 2bd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2c4:	eb f0                	jmp    2b6 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2c6:	89 c6                	mov    %eax,%esi
 2c8:	89 d0                	mov    %edx,%eax
 2ca:	ba 00 00 00 00       	mov    $0x0,%edx
 2cf:	f7 f1                	div    %ecx
 2d1:	89 c3                	mov    %eax,%ebx
 2d3:	8d 46 01             	lea    0x1(%esi),%eax
 2d6:	0f b6 92 d4 05 00 00 	movzbl 0x5d4(%edx),%edx
 2dd:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2e1:	89 da                	mov    %ebx,%edx
 2e3:	85 db                	test   %ebx,%ebx
 2e5:	75 df                	jne    2c6 <printint+0x34>
 2e7:	89 c3                	mov    %eax,%ebx
  if(neg)
 2e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2ed:	74 16                	je     305 <printint+0x73>
    buf[i++] = '-';
 2ef:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2f4:	8d 5e 02             	lea    0x2(%esi),%ebx
 2f7:	eb 0c                	jmp    305 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2f9:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 2fe:	89 f8                	mov    %edi,%eax
 300:	e8 73 ff ff ff       	call   278 <putc>
  while(--i >= 0)
 305:	83 eb 01             	sub    $0x1,%ebx
 308:	79 ef                	jns    2f9 <printint+0x67>
}
 30a:	83 c4 2c             	add    $0x2c,%esp
 30d:	5b                   	pop    %ebx
 30e:	5e                   	pop    %esi
 30f:	5f                   	pop    %edi
 310:	5d                   	pop    %ebp
 311:	c3                   	ret    

00000312 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 312:	55                   	push   %ebp
 313:	89 e5                	mov    %esp,%ebp
 315:	57                   	push   %edi
 316:	56                   	push   %esi
 317:	53                   	push   %ebx
 318:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 31b:	8d 45 10             	lea    0x10(%ebp),%eax
 31e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 321:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 326:	bb 00 00 00 00       	mov    $0x0,%ebx
 32b:	eb 14                	jmp    341 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 32d:	89 fa                	mov    %edi,%edx
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	e8 41 ff ff ff       	call   278 <putc>
 337:	eb 05                	jmp    33e <printf+0x2c>
      }
    } else if(state == '%'){
 339:	83 fe 25             	cmp    $0x25,%esi
 33c:	74 25                	je     363 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 33e:	83 c3 01             	add    $0x1,%ebx
 341:	8b 45 0c             	mov    0xc(%ebp),%eax
 344:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 348:	84 c0                	test   %al,%al
 34a:	0f 84 23 01 00 00    	je     473 <printf+0x161>
    c = fmt[i] & 0xff;
 350:	0f be f8             	movsbl %al,%edi
 353:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 356:	85 f6                	test   %esi,%esi
 358:	75 df                	jne    339 <printf+0x27>
      if(c == '%'){
 35a:	83 f8 25             	cmp    $0x25,%eax
 35d:	75 ce                	jne    32d <printf+0x1b>
        state = '%';
 35f:	89 c6                	mov    %eax,%esi
 361:	eb db                	jmp    33e <printf+0x2c>
      if(c == 'd'){
 363:	83 f8 64             	cmp    $0x64,%eax
 366:	74 49                	je     3b1 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 368:	83 f8 78             	cmp    $0x78,%eax
 36b:	0f 94 c1             	sete   %cl
 36e:	83 f8 70             	cmp    $0x70,%eax
 371:	0f 94 c2             	sete   %dl
 374:	08 d1                	or     %dl,%cl
 376:	75 63                	jne    3db <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 378:	83 f8 73             	cmp    $0x73,%eax
 37b:	0f 84 84 00 00 00    	je     405 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 381:	83 f8 63             	cmp    $0x63,%eax
 384:	0f 84 b7 00 00 00    	je     441 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 38a:	83 f8 25             	cmp    $0x25,%eax
 38d:	0f 84 cc 00 00 00    	je     45f <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 393:	ba 25 00 00 00       	mov    $0x25,%edx
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	e8 d8 fe ff ff       	call   278 <putc>
        putc(fd, c);
 3a0:	89 fa                	mov    %edi,%edx
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	e8 ce fe ff ff       	call   278 <putc>
      }
      state = 0;
 3aa:	be 00 00 00 00       	mov    $0x0,%esi
 3af:	eb 8d                	jmp    33e <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3b4:	8b 17                	mov    (%edi),%edx
 3b6:	83 ec 0c             	sub    $0xc,%esp
 3b9:	6a 01                	push   $0x1
 3bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	e8 ca fe ff ff       	call   292 <printint>
        ap++;
 3c8:	83 c7 04             	add    $0x4,%edi
 3cb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3ce:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3d1:	be 00 00 00 00       	mov    $0x0,%esi
 3d6:	e9 63 ff ff ff       	jmp    33e <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3de:	8b 17                	mov    (%edi),%edx
 3e0:	83 ec 0c             	sub    $0xc,%esp
 3e3:	6a 00                	push   $0x0
 3e5:	b9 10 00 00 00       	mov    $0x10,%ecx
 3ea:	8b 45 08             	mov    0x8(%ebp),%eax
 3ed:	e8 a0 fe ff ff       	call   292 <printint>
        ap++;
 3f2:	83 c7 04             	add    $0x4,%edi
 3f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3f8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3fb:	be 00 00 00 00       	mov    $0x0,%esi
 400:	e9 39 ff ff ff       	jmp    33e <printf+0x2c>
        s = (char*)*ap;
 405:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 408:	8b 30                	mov    (%eax),%esi
        ap++;
 40a:	83 c0 04             	add    $0x4,%eax
 40d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 410:	85 f6                	test   %esi,%esi
 412:	75 28                	jne    43c <printf+0x12a>
          s = "(null)";
 414:	be cc 05 00 00       	mov    $0x5cc,%esi
 419:	8b 7d 08             	mov    0x8(%ebp),%edi
 41c:	eb 0d                	jmp    42b <printf+0x119>
          putc(fd, *s);
 41e:	0f be d2             	movsbl %dl,%edx
 421:	89 f8                	mov    %edi,%eax
 423:	e8 50 fe ff ff       	call   278 <putc>
          s++;
 428:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 42b:	0f b6 16             	movzbl (%esi),%edx
 42e:	84 d2                	test   %dl,%dl
 430:	75 ec                	jne    41e <printf+0x10c>
      state = 0;
 432:	be 00 00 00 00       	mov    $0x0,%esi
 437:	e9 02 ff ff ff       	jmp    33e <printf+0x2c>
 43c:	8b 7d 08             	mov    0x8(%ebp),%edi
 43f:	eb ea                	jmp    42b <printf+0x119>
        putc(fd, *ap);
 441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 444:	0f be 17             	movsbl (%edi),%edx
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	e8 29 fe ff ff       	call   278 <putc>
        ap++;
 44f:	83 c7 04             	add    $0x4,%edi
 452:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 455:	be 00 00 00 00       	mov    $0x0,%esi
 45a:	e9 df fe ff ff       	jmp    33e <printf+0x2c>
        putc(fd, c);
 45f:	89 fa                	mov    %edi,%edx
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	e8 0f fe ff ff       	call   278 <putc>
      state = 0;
 469:	be 00 00 00 00       	mov    $0x0,%esi
 46e:	e9 cb fe ff ff       	jmp    33e <printf+0x2c>
    }
  }
}
 473:	8d 65 f4             	lea    -0xc(%ebp),%esp
 476:	5b                   	pop    %ebx
 477:	5e                   	pop    %esi
 478:	5f                   	pop    %edi
 479:	5d                   	pop    %ebp
 47a:	c3                   	ret    

0000047b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 47b:	55                   	push   %ebp
 47c:	89 e5                	mov    %esp,%ebp
 47e:	57                   	push   %edi
 47f:	56                   	push   %esi
 480:	53                   	push   %ebx
 481:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 484:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 487:	a1 6c 08 00 00       	mov    0x86c,%eax
 48c:	eb 02                	jmp    490 <free+0x15>
 48e:	89 d0                	mov    %edx,%eax
 490:	39 c8                	cmp    %ecx,%eax
 492:	73 04                	jae    498 <free+0x1d>
 494:	39 08                	cmp    %ecx,(%eax)
 496:	77 12                	ja     4aa <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 498:	8b 10                	mov    (%eax),%edx
 49a:	39 c2                	cmp    %eax,%edx
 49c:	77 f0                	ja     48e <free+0x13>
 49e:	39 c8                	cmp    %ecx,%eax
 4a0:	72 08                	jb     4aa <free+0x2f>
 4a2:	39 ca                	cmp    %ecx,%edx
 4a4:	77 04                	ja     4aa <free+0x2f>
 4a6:	89 d0                	mov    %edx,%eax
 4a8:	eb e6                	jmp    490 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4aa:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4ad:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b0:	8b 10                	mov    (%eax),%edx
 4b2:	39 d7                	cmp    %edx,%edi
 4b4:	74 19                	je     4cf <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4b6:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4b9:	8b 50 04             	mov    0x4(%eax),%edx
 4bc:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4bf:	39 ce                	cmp    %ecx,%esi
 4c1:	74 1b                	je     4de <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4c3:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4c5:	a3 6c 08 00 00       	mov    %eax,0x86c
}
 4ca:	5b                   	pop    %ebx
 4cb:	5e                   	pop    %esi
 4cc:	5f                   	pop    %edi
 4cd:	5d                   	pop    %ebp
 4ce:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4cf:	03 72 04             	add    0x4(%edx),%esi
 4d2:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4d5:	8b 10                	mov    (%eax),%edx
 4d7:	8b 12                	mov    (%edx),%edx
 4d9:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4dc:	eb db                	jmp    4b9 <free+0x3e>
    p->s.size += bp->s.size;
 4de:	03 53 fc             	add    -0x4(%ebx),%edx
 4e1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4e4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4e7:	89 10                	mov    %edx,(%eax)
 4e9:	eb da                	jmp    4c5 <free+0x4a>

000004eb <morecore>:

static Header*
morecore(uint nu)
{
 4eb:	55                   	push   %ebp
 4ec:	89 e5                	mov    %esp,%ebp
 4ee:	53                   	push   %ebx
 4ef:	83 ec 04             	sub    $0x4,%esp
 4f2:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4f4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4f9:	77 05                	ja     500 <morecore+0x15>
    nu = 4096;
 4fb:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 500:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 507:	83 ec 0c             	sub    $0xc,%esp
 50a:	50                   	push   %eax
 50b:	e8 20 fd ff ff       	call   230 <sbrk>
  if(p == (char*)-1)
 510:	83 c4 10             	add    $0x10,%esp
 513:	83 f8 ff             	cmp    $0xffffffff,%eax
 516:	74 1c                	je     534 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 518:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 51b:	83 c0 08             	add    $0x8,%eax
 51e:	83 ec 0c             	sub    $0xc,%esp
 521:	50                   	push   %eax
 522:	e8 54 ff ff ff       	call   47b <free>
  return freep;
 527:	a1 6c 08 00 00       	mov    0x86c,%eax
 52c:	83 c4 10             	add    $0x10,%esp
}
 52f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 532:	c9                   	leave  
 533:	c3                   	ret    
    return 0;
 534:	b8 00 00 00 00       	mov    $0x0,%eax
 539:	eb f4                	jmp    52f <morecore+0x44>

0000053b <malloc>:

void*
malloc(uint nbytes)
{
 53b:	55                   	push   %ebp
 53c:	89 e5                	mov    %esp,%ebp
 53e:	53                   	push   %ebx
 53f:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 542:	8b 45 08             	mov    0x8(%ebp),%eax
 545:	8d 58 07             	lea    0x7(%eax),%ebx
 548:	c1 eb 03             	shr    $0x3,%ebx
 54b:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 54e:	8b 0d 6c 08 00 00    	mov    0x86c,%ecx
 554:	85 c9                	test   %ecx,%ecx
 556:	74 04                	je     55c <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 558:	8b 01                	mov    (%ecx),%eax
 55a:	eb 4d                	jmp    5a9 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 55c:	c7 05 6c 08 00 00 70 	movl   $0x870,0x86c
 563:	08 00 00 
 566:	c7 05 70 08 00 00 70 	movl   $0x870,0x870
 56d:	08 00 00 
    base.s.size = 0;
 570:	c7 05 74 08 00 00 00 	movl   $0x0,0x874
 577:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 57a:	b9 70 08 00 00       	mov    $0x870,%ecx
 57f:	eb d7                	jmp    558 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 581:	39 da                	cmp    %ebx,%edx
 583:	74 1a                	je     59f <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 585:	29 da                	sub    %ebx,%edx
 587:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 58a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 58d:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 590:	89 0d 6c 08 00 00    	mov    %ecx,0x86c
      return (void*)(p + 1);
 596:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 599:	83 c4 04             	add    $0x4,%esp
 59c:	5b                   	pop    %ebx
 59d:	5d                   	pop    %ebp
 59e:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 59f:	8b 10                	mov    (%eax),%edx
 5a1:	89 11                	mov    %edx,(%ecx)
 5a3:	eb eb                	jmp    590 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5a5:	89 c1                	mov    %eax,%ecx
 5a7:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5a9:	8b 50 04             	mov    0x4(%eax),%edx
 5ac:	39 da                	cmp    %ebx,%edx
 5ae:	73 d1                	jae    581 <malloc+0x46>
    if(p == freep)
 5b0:	39 05 6c 08 00 00    	cmp    %eax,0x86c
 5b6:	75 ed                	jne    5a5 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5b8:	89 d8                	mov    %ebx,%eax
 5ba:	e8 2c ff ff ff       	call   4eb <morecore>
 5bf:	85 c0                	test   %eax,%eax
 5c1:	75 e2                	jne    5a5 <malloc+0x6a>
        return 0;
 5c3:	b8 00 00 00 00       	mov    $0x0,%eax
 5c8:	eb cf                	jmp    599 <malloc+0x5e>
