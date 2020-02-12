
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  if(fork() > 0)
  11:	e8 9d 01 00 00       	call   1b3 <fork>
  16:	85 c0                	test   %eax,%eax
  18:	7f 05                	jg     1f <main+0x1f>
    sleep(5);  // Let child exit before parent.
  exit();
  1a:	e8 9c 01 00 00       	call   1bb <exit>
    sleep(5);  // Let child exit before parent.
  1f:	83 ec 0c             	sub    $0xc,%esp
  22:	6a 05                	push   $0x5
  24:	e8 22 02 00 00       	call   24b <sleep>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	eb ec                	jmp    1a <main+0x1a>

0000002e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  2e:	55                   	push   %ebp
  2f:	89 e5                	mov    %esp,%ebp
  31:	53                   	push   %ebx
  32:	8b 45 08             	mov    0x8(%ebp),%eax
  35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  38:	89 c2                	mov    %eax,%edx
  3a:	0f b6 19             	movzbl (%ecx),%ebx
  3d:	88 1a                	mov    %bl,(%edx)
  3f:	8d 52 01             	lea    0x1(%edx),%edx
  42:	8d 49 01             	lea    0x1(%ecx),%ecx
  45:	84 db                	test   %bl,%bl
  47:	75 f1                	jne    3a <strcpy+0xc>
    ;
  return os;
}
  49:	5b                   	pop    %ebx
  4a:	5d                   	pop    %ebp
  4b:	c3                   	ret    

0000004c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  52:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  55:	eb 06                	jmp    5d <strcmp+0x11>
    p++, q++;
  57:	83 c1 01             	add    $0x1,%ecx
  5a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  5d:	0f b6 01             	movzbl (%ecx),%eax
  60:	84 c0                	test   %al,%al
  62:	74 04                	je     68 <strcmp+0x1c>
  64:	3a 02                	cmp    (%edx),%al
  66:	74 ef                	je     57 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  68:	0f b6 c0             	movzbl %al,%eax
  6b:	0f b6 12             	movzbl (%edx),%edx
  6e:	29 d0                	sub    %edx,%eax
}
  70:	5d                   	pop    %ebp
  71:	c3                   	ret    

00000072 <strlen>:

uint
strlen(const char *s)
{
  72:	55                   	push   %ebp
  73:	89 e5                	mov    %esp,%ebp
  75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  78:	ba 00 00 00 00       	mov    $0x0,%edx
  7d:	eb 03                	jmp    82 <strlen+0x10>
  7f:	83 c2 01             	add    $0x1,%edx
  82:	89 d0                	mov    %edx,%eax
  84:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  88:	75 f5                	jne    7f <strlen+0xd>
    ;
  return n;
}
  8a:	5d                   	pop    %ebp
  8b:	c3                   	ret    

0000008c <memset>:

void*
memset(void *dst, int c, uint n)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	57                   	push   %edi
  90:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  93:	89 d7                	mov    %edx,%edi
  95:	8b 4d 10             	mov    0x10(%ebp),%ecx
  98:	8b 45 0c             	mov    0xc(%ebp),%eax
  9b:	fc                   	cld    
  9c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  9e:	89 d0                	mov    %edx,%eax
  a0:	5f                   	pop    %edi
  a1:	5d                   	pop    %ebp
  a2:	c3                   	ret    

000000a3 <strchr>:

char*
strchr(const char *s, char c)
{
  a3:	55                   	push   %ebp
  a4:	89 e5                	mov    %esp,%ebp
  a6:	8b 45 08             	mov    0x8(%ebp),%eax
  a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  ad:	0f b6 10             	movzbl (%eax),%edx
  b0:	84 d2                	test   %dl,%dl
  b2:	74 09                	je     bd <strchr+0x1a>
    if(*s == c)
  b4:	38 ca                	cmp    %cl,%dl
  b6:	74 0a                	je     c2 <strchr+0x1f>
  for(; *s; s++)
  b8:	83 c0 01             	add    $0x1,%eax
  bb:	eb f0                	jmp    ad <strchr+0xa>
      return (char*)s;
  return 0;
  bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c2:	5d                   	pop    %ebp
  c3:	c3                   	ret    

000000c4 <gets>:

char*
gets(char *buf, int max)
{
  c4:	55                   	push   %ebp
  c5:	89 e5                	mov    %esp,%ebp
  c7:	57                   	push   %edi
  c8:	56                   	push   %esi
  c9:	53                   	push   %ebx
  ca:	83 ec 1c             	sub    $0x1c,%esp
  cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  d5:	8d 73 01             	lea    0x1(%ebx),%esi
  d8:	3b 75 0c             	cmp    0xc(%ebp),%esi
  db:	7d 2e                	jge    10b <gets+0x47>
    cc = read(0, &c, 1);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	6a 01                	push   $0x1
  e2:	8d 45 e7             	lea    -0x19(%ebp),%eax
  e5:	50                   	push   %eax
  e6:	6a 00                	push   $0x0
  e8:	e8 e6 00 00 00       	call   1d3 <read>
    if(cc < 1)
  ed:	83 c4 10             	add    $0x10,%esp
  f0:	85 c0                	test   %eax,%eax
  f2:	7e 17                	jle    10b <gets+0x47>
      break;
    buf[i++] = c;
  f4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  f8:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  fb:	3c 0a                	cmp    $0xa,%al
  fd:	0f 94 c2             	sete   %dl
 100:	3c 0d                	cmp    $0xd,%al
 102:	0f 94 c0             	sete   %al
    buf[i++] = c;
 105:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 107:	08 c2                	or     %al,%dl
 109:	74 ca                	je     d5 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 10b:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 10f:	89 f8                	mov    %edi,%eax
 111:	8d 65 f4             	lea    -0xc(%ebp),%esp
 114:	5b                   	pop    %ebx
 115:	5e                   	pop    %esi
 116:	5f                   	pop    %edi
 117:	5d                   	pop    %ebp
 118:	c3                   	ret    

00000119 <stat>:

int
stat(const char *n, struct stat *st)
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	56                   	push   %esi
 11d:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 11e:	83 ec 08             	sub    $0x8,%esp
 121:	6a 00                	push   $0x0
 123:	ff 75 08             	pushl  0x8(%ebp)
 126:	e8 d0 00 00 00       	call   1fb <open>
  if(fd < 0)
 12b:	83 c4 10             	add    $0x10,%esp
 12e:	85 c0                	test   %eax,%eax
 130:	78 24                	js     156 <stat+0x3d>
 132:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 134:	83 ec 08             	sub    $0x8,%esp
 137:	ff 75 0c             	pushl  0xc(%ebp)
 13a:	50                   	push   %eax
 13b:	e8 d3 00 00 00       	call   213 <fstat>
 140:	89 c6                	mov    %eax,%esi
  close(fd);
 142:	89 1c 24             	mov    %ebx,(%esp)
 145:	e8 99 00 00 00       	call   1e3 <close>
  return r;
 14a:	83 c4 10             	add    $0x10,%esp
}
 14d:	89 f0                	mov    %esi,%eax
 14f:	8d 65 f8             	lea    -0x8(%ebp),%esp
 152:	5b                   	pop    %ebx
 153:	5e                   	pop    %esi
 154:	5d                   	pop    %ebp
 155:	c3                   	ret    
    return -1;
 156:	be ff ff ff ff       	mov    $0xffffffff,%esi
 15b:	eb f0                	jmp    14d <stat+0x34>

0000015d <atoi>:

int
atoi(const char *s)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	53                   	push   %ebx
 161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 164:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 169:	eb 10                	jmp    17b <atoi+0x1e>
    n = n*10 + *s++ - '0';
 16b:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 16e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 171:	83 c1 01             	add    $0x1,%ecx
 174:	0f be d2             	movsbl %dl,%edx
 177:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 17b:	0f b6 11             	movzbl (%ecx),%edx
 17e:	8d 5a d0             	lea    -0x30(%edx),%ebx
 181:	80 fb 09             	cmp    $0x9,%bl
 184:	76 e5                	jbe    16b <atoi+0xe>
  return n;
}
 186:	5b                   	pop    %ebx
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    

00000189 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	56                   	push   %esi
 18d:	53                   	push   %ebx
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 194:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 197:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 199:	eb 0d                	jmp    1a8 <memmove+0x1f>
    *dst++ = *src++;
 19b:	0f b6 13             	movzbl (%ebx),%edx
 19e:	88 11                	mov    %dl,(%ecx)
 1a0:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1a3:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1a6:	89 f2                	mov    %esi,%edx
 1a8:	8d 72 ff             	lea    -0x1(%edx),%esi
 1ab:	85 d2                	test   %edx,%edx
 1ad:	7f ec                	jg     19b <memmove+0x12>
  return vdst;
}
 1af:	5b                   	pop    %ebx
 1b0:	5e                   	pop    %esi
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    

000001b3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1b3:	b8 01 00 00 00       	mov    $0x1,%eax
 1b8:	cd 40                	int    $0x40
 1ba:	c3                   	ret    

000001bb <exit>:
SYSCALL(exit)
 1bb:	b8 02 00 00 00       	mov    $0x2,%eax
 1c0:	cd 40                	int    $0x40
 1c2:	c3                   	ret    

000001c3 <wait>:
SYSCALL(wait)
 1c3:	b8 03 00 00 00       	mov    $0x3,%eax
 1c8:	cd 40                	int    $0x40
 1ca:	c3                   	ret    

000001cb <pipe>:
SYSCALL(pipe)
 1cb:	b8 04 00 00 00       	mov    $0x4,%eax
 1d0:	cd 40                	int    $0x40
 1d2:	c3                   	ret    

000001d3 <read>:
SYSCALL(read)
 1d3:	b8 05 00 00 00       	mov    $0x5,%eax
 1d8:	cd 40                	int    $0x40
 1da:	c3                   	ret    

000001db <write>:
SYSCALL(write)
 1db:	b8 10 00 00 00       	mov    $0x10,%eax
 1e0:	cd 40                	int    $0x40
 1e2:	c3                   	ret    

000001e3 <close>:
SYSCALL(close)
 1e3:	b8 15 00 00 00       	mov    $0x15,%eax
 1e8:	cd 40                	int    $0x40
 1ea:	c3                   	ret    

000001eb <kill>:
SYSCALL(kill)
 1eb:	b8 06 00 00 00       	mov    $0x6,%eax
 1f0:	cd 40                	int    $0x40
 1f2:	c3                   	ret    

000001f3 <exec>:
SYSCALL(exec)
 1f3:	b8 07 00 00 00       	mov    $0x7,%eax
 1f8:	cd 40                	int    $0x40
 1fa:	c3                   	ret    

000001fb <open>:
SYSCALL(open)
 1fb:	b8 0f 00 00 00       	mov    $0xf,%eax
 200:	cd 40                	int    $0x40
 202:	c3                   	ret    

00000203 <mknod>:
SYSCALL(mknod)
 203:	b8 11 00 00 00       	mov    $0x11,%eax
 208:	cd 40                	int    $0x40
 20a:	c3                   	ret    

0000020b <unlink>:
SYSCALL(unlink)
 20b:	b8 12 00 00 00       	mov    $0x12,%eax
 210:	cd 40                	int    $0x40
 212:	c3                   	ret    

00000213 <fstat>:
SYSCALL(fstat)
 213:	b8 08 00 00 00       	mov    $0x8,%eax
 218:	cd 40                	int    $0x40
 21a:	c3                   	ret    

0000021b <link>:
SYSCALL(link)
 21b:	b8 13 00 00 00       	mov    $0x13,%eax
 220:	cd 40                	int    $0x40
 222:	c3                   	ret    

00000223 <mkdir>:
SYSCALL(mkdir)
 223:	b8 14 00 00 00       	mov    $0x14,%eax
 228:	cd 40                	int    $0x40
 22a:	c3                   	ret    

0000022b <chdir>:
SYSCALL(chdir)
 22b:	b8 09 00 00 00       	mov    $0x9,%eax
 230:	cd 40                	int    $0x40
 232:	c3                   	ret    

00000233 <dup>:
SYSCALL(dup)
 233:	b8 0a 00 00 00       	mov    $0xa,%eax
 238:	cd 40                	int    $0x40
 23a:	c3                   	ret    

0000023b <getpid>:
SYSCALL(getpid)
 23b:	b8 0b 00 00 00       	mov    $0xb,%eax
 240:	cd 40                	int    $0x40
 242:	c3                   	ret    

00000243 <sbrk>:
SYSCALL(sbrk)
 243:	b8 0c 00 00 00       	mov    $0xc,%eax
 248:	cd 40                	int    $0x40
 24a:	c3                   	ret    

0000024b <sleep>:
SYSCALL(sleep)
 24b:	b8 0d 00 00 00       	mov    $0xd,%eax
 250:	cd 40                	int    $0x40
 252:	c3                   	ret    

00000253 <uptime>:
SYSCALL(uptime)
 253:	b8 0e 00 00 00       	mov    $0xe,%eax
 258:	cd 40                	int    $0x40
 25a:	c3                   	ret    

0000025b <yield>:
SYSCALL(yield)
 25b:	b8 16 00 00 00       	mov    $0x16,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <shutdown>:
SYSCALL(shutdown)
 263:	b8 17 00 00 00       	mov    $0x17,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <writecount>:
SYSCALL(writecount)
 26b:	b8 18 00 00 00       	mov    $0x18,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <setwritecount>:
SYSCALL(setwritecount)
 273:	b8 19 00 00 00       	mov    $0x19,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <settickets>:
SYSCALL(settickets)
 27b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <getprocessesinfo>:
 283:	b8 1b 00 00 00       	mov    $0x1b,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 28b:	55                   	push   %ebp
 28c:	89 e5                	mov    %esp,%ebp
 28e:	83 ec 1c             	sub    $0x1c,%esp
 291:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 294:	6a 01                	push   $0x1
 296:	8d 55 f4             	lea    -0xc(%ebp),%edx
 299:	52                   	push   %edx
 29a:	50                   	push   %eax
 29b:	e8 3b ff ff ff       	call   1db <write>
}
 2a0:	83 c4 10             	add    $0x10,%esp
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	57                   	push   %edi
 2a9:	56                   	push   %esi
 2aa:	53                   	push   %ebx
 2ab:	83 ec 2c             	sub    $0x2c,%esp
 2ae:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2b4:	0f 95 c3             	setne  %bl
 2b7:	89 d0                	mov    %edx,%eax
 2b9:	c1 e8 1f             	shr    $0x1f,%eax
 2bc:	84 c3                	test   %al,%bl
 2be:	74 10                	je     2d0 <printint+0x2b>
    neg = 1;
    x = -xx;
 2c0:	f7 da                	neg    %edx
    neg = 1;
 2c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2c9:	be 00 00 00 00       	mov    $0x0,%esi
 2ce:	eb 0b                	jmp    2db <printint+0x36>
  neg = 0;
 2d0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2d7:	eb f0                	jmp    2c9 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2d9:	89 c6                	mov    %eax,%esi
 2db:	89 d0                	mov    %edx,%eax
 2dd:	ba 00 00 00 00       	mov    $0x0,%edx
 2e2:	f7 f1                	div    %ecx
 2e4:	89 c3                	mov    %eax,%ebx
 2e6:	8d 46 01             	lea    0x1(%esi),%eax
 2e9:	0f b6 92 e8 05 00 00 	movzbl 0x5e8(%edx),%edx
 2f0:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2f4:	89 da                	mov    %ebx,%edx
 2f6:	85 db                	test   %ebx,%ebx
 2f8:	75 df                	jne    2d9 <printint+0x34>
 2fa:	89 c3                	mov    %eax,%ebx
  if(neg)
 2fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 300:	74 16                	je     318 <printint+0x73>
    buf[i++] = '-';
 302:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 307:	8d 5e 02             	lea    0x2(%esi),%ebx
 30a:	eb 0c                	jmp    318 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 30c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 311:	89 f8                	mov    %edi,%eax
 313:	e8 73 ff ff ff       	call   28b <putc>
  while(--i >= 0)
 318:	83 eb 01             	sub    $0x1,%ebx
 31b:	79 ef                	jns    30c <printint+0x67>
}
 31d:	83 c4 2c             	add    $0x2c,%esp
 320:	5b                   	pop    %ebx
 321:	5e                   	pop    %esi
 322:	5f                   	pop    %edi
 323:	5d                   	pop    %ebp
 324:	c3                   	ret    

00000325 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	57                   	push   %edi
 329:	56                   	push   %esi
 32a:	53                   	push   %ebx
 32b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 32e:	8d 45 10             	lea    0x10(%ebp),%eax
 331:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 334:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 339:	bb 00 00 00 00       	mov    $0x0,%ebx
 33e:	eb 14                	jmp    354 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 340:	89 fa                	mov    %edi,%edx
 342:	8b 45 08             	mov    0x8(%ebp),%eax
 345:	e8 41 ff ff ff       	call   28b <putc>
 34a:	eb 05                	jmp    351 <printf+0x2c>
      }
    } else if(state == '%'){
 34c:	83 fe 25             	cmp    $0x25,%esi
 34f:	74 25                	je     376 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 351:	83 c3 01             	add    $0x1,%ebx
 354:	8b 45 0c             	mov    0xc(%ebp),%eax
 357:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 35b:	84 c0                	test   %al,%al
 35d:	0f 84 23 01 00 00    	je     486 <printf+0x161>
    c = fmt[i] & 0xff;
 363:	0f be f8             	movsbl %al,%edi
 366:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 369:	85 f6                	test   %esi,%esi
 36b:	75 df                	jne    34c <printf+0x27>
      if(c == '%'){
 36d:	83 f8 25             	cmp    $0x25,%eax
 370:	75 ce                	jne    340 <printf+0x1b>
        state = '%';
 372:	89 c6                	mov    %eax,%esi
 374:	eb db                	jmp    351 <printf+0x2c>
      if(c == 'd'){
 376:	83 f8 64             	cmp    $0x64,%eax
 379:	74 49                	je     3c4 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 37b:	83 f8 78             	cmp    $0x78,%eax
 37e:	0f 94 c1             	sete   %cl
 381:	83 f8 70             	cmp    $0x70,%eax
 384:	0f 94 c2             	sete   %dl
 387:	08 d1                	or     %dl,%cl
 389:	75 63                	jne    3ee <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 38b:	83 f8 73             	cmp    $0x73,%eax
 38e:	0f 84 84 00 00 00    	je     418 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 394:	83 f8 63             	cmp    $0x63,%eax
 397:	0f 84 b7 00 00 00    	je     454 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 39d:	83 f8 25             	cmp    $0x25,%eax
 3a0:	0f 84 cc 00 00 00    	je     472 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3a6:	ba 25 00 00 00       	mov    $0x25,%edx
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	e8 d8 fe ff ff       	call   28b <putc>
        putc(fd, c);
 3b3:	89 fa                	mov    %edi,%edx
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	e8 ce fe ff ff       	call   28b <putc>
      }
      state = 0;
 3bd:	be 00 00 00 00       	mov    $0x0,%esi
 3c2:	eb 8d                	jmp    351 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3c7:	8b 17                	mov    (%edi),%edx
 3c9:	83 ec 0c             	sub    $0xc,%esp
 3cc:	6a 01                	push   $0x1
 3ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	e8 ca fe ff ff       	call   2a5 <printint>
        ap++;
 3db:	83 c7 04             	add    $0x4,%edi
 3de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3e1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3e4:	be 00 00 00 00       	mov    $0x0,%esi
 3e9:	e9 63 ff ff ff       	jmp    351 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f1:	8b 17                	mov    (%edi),%edx
 3f3:	83 ec 0c             	sub    $0xc,%esp
 3f6:	6a 00                	push   $0x0
 3f8:	b9 10 00 00 00       	mov    $0x10,%ecx
 3fd:	8b 45 08             	mov    0x8(%ebp),%eax
 400:	e8 a0 fe ff ff       	call   2a5 <printint>
        ap++;
 405:	83 c7 04             	add    $0x4,%edi
 408:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 40b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 40e:	be 00 00 00 00       	mov    $0x0,%esi
 413:	e9 39 ff ff ff       	jmp    351 <printf+0x2c>
        s = (char*)*ap;
 418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 41b:	8b 30                	mov    (%eax),%esi
        ap++;
 41d:	83 c0 04             	add    $0x4,%eax
 420:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 423:	85 f6                	test   %esi,%esi
 425:	75 28                	jne    44f <printf+0x12a>
          s = "(null)";
 427:	be e0 05 00 00       	mov    $0x5e0,%esi
 42c:	8b 7d 08             	mov    0x8(%ebp),%edi
 42f:	eb 0d                	jmp    43e <printf+0x119>
          putc(fd, *s);
 431:	0f be d2             	movsbl %dl,%edx
 434:	89 f8                	mov    %edi,%eax
 436:	e8 50 fe ff ff       	call   28b <putc>
          s++;
 43b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 43e:	0f b6 16             	movzbl (%esi),%edx
 441:	84 d2                	test   %dl,%dl
 443:	75 ec                	jne    431 <printf+0x10c>
      state = 0;
 445:	be 00 00 00 00       	mov    $0x0,%esi
 44a:	e9 02 ff ff ff       	jmp    351 <printf+0x2c>
 44f:	8b 7d 08             	mov    0x8(%ebp),%edi
 452:	eb ea                	jmp    43e <printf+0x119>
        putc(fd, *ap);
 454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 457:	0f be 17             	movsbl (%edi),%edx
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	e8 29 fe ff ff       	call   28b <putc>
        ap++;
 462:	83 c7 04             	add    $0x4,%edi
 465:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 468:	be 00 00 00 00       	mov    $0x0,%esi
 46d:	e9 df fe ff ff       	jmp    351 <printf+0x2c>
        putc(fd, c);
 472:	89 fa                	mov    %edi,%edx
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	e8 0f fe ff ff       	call   28b <putc>
      state = 0;
 47c:	be 00 00 00 00       	mov    $0x0,%esi
 481:	e9 cb fe ff ff       	jmp    351 <printf+0x2c>
    }
  }
}
 486:	8d 65 f4             	lea    -0xc(%ebp),%esp
 489:	5b                   	pop    %ebx
 48a:	5e                   	pop    %esi
 48b:	5f                   	pop    %edi
 48c:	5d                   	pop    %ebp
 48d:	c3                   	ret    

0000048e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 48e:	55                   	push   %ebp
 48f:	89 e5                	mov    %esp,%ebp
 491:	57                   	push   %edi
 492:	56                   	push   %esi
 493:	53                   	push   %ebx
 494:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 497:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 49a:	a1 80 08 00 00       	mov    0x880,%eax
 49f:	eb 02                	jmp    4a3 <free+0x15>
 4a1:	89 d0                	mov    %edx,%eax
 4a3:	39 c8                	cmp    %ecx,%eax
 4a5:	73 04                	jae    4ab <free+0x1d>
 4a7:	39 08                	cmp    %ecx,(%eax)
 4a9:	77 12                	ja     4bd <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4ab:	8b 10                	mov    (%eax),%edx
 4ad:	39 c2                	cmp    %eax,%edx
 4af:	77 f0                	ja     4a1 <free+0x13>
 4b1:	39 c8                	cmp    %ecx,%eax
 4b3:	72 08                	jb     4bd <free+0x2f>
 4b5:	39 ca                	cmp    %ecx,%edx
 4b7:	77 04                	ja     4bd <free+0x2f>
 4b9:	89 d0                	mov    %edx,%eax
 4bb:	eb e6                	jmp    4a3 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4bd:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4c0:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4c3:	8b 10                	mov    (%eax),%edx
 4c5:	39 d7                	cmp    %edx,%edi
 4c7:	74 19                	je     4e2 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4c9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4cc:	8b 50 04             	mov    0x4(%eax),%edx
 4cf:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4d2:	39 ce                	cmp    %ecx,%esi
 4d4:	74 1b                	je     4f1 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4d6:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4d8:	a3 80 08 00 00       	mov    %eax,0x880
}
 4dd:	5b                   	pop    %ebx
 4de:	5e                   	pop    %esi
 4df:	5f                   	pop    %edi
 4e0:	5d                   	pop    %ebp
 4e1:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4e2:	03 72 04             	add    0x4(%edx),%esi
 4e5:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4e8:	8b 10                	mov    (%eax),%edx
 4ea:	8b 12                	mov    (%edx),%edx
 4ec:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4ef:	eb db                	jmp    4cc <free+0x3e>
    p->s.size += bp->s.size;
 4f1:	03 53 fc             	add    -0x4(%ebx),%edx
 4f4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4f7:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4fa:	89 10                	mov    %edx,(%eax)
 4fc:	eb da                	jmp    4d8 <free+0x4a>

000004fe <morecore>:

static Header*
morecore(uint nu)
{
 4fe:	55                   	push   %ebp
 4ff:	89 e5                	mov    %esp,%ebp
 501:	53                   	push   %ebx
 502:	83 ec 04             	sub    $0x4,%esp
 505:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 507:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 50c:	77 05                	ja     513 <morecore+0x15>
    nu = 4096;
 50e:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 513:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 51a:	83 ec 0c             	sub    $0xc,%esp
 51d:	50                   	push   %eax
 51e:	e8 20 fd ff ff       	call   243 <sbrk>
  if(p == (char*)-1)
 523:	83 c4 10             	add    $0x10,%esp
 526:	83 f8 ff             	cmp    $0xffffffff,%eax
 529:	74 1c                	je     547 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 52b:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 52e:	83 c0 08             	add    $0x8,%eax
 531:	83 ec 0c             	sub    $0xc,%esp
 534:	50                   	push   %eax
 535:	e8 54 ff ff ff       	call   48e <free>
  return freep;
 53a:	a1 80 08 00 00       	mov    0x880,%eax
 53f:	83 c4 10             	add    $0x10,%esp
}
 542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 545:	c9                   	leave  
 546:	c3                   	ret    
    return 0;
 547:	b8 00 00 00 00       	mov    $0x0,%eax
 54c:	eb f4                	jmp    542 <morecore+0x44>

0000054e <malloc>:

void*
malloc(uint nbytes)
{
 54e:	55                   	push   %ebp
 54f:	89 e5                	mov    %esp,%ebp
 551:	53                   	push   %ebx
 552:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	8d 58 07             	lea    0x7(%eax),%ebx
 55b:	c1 eb 03             	shr    $0x3,%ebx
 55e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 561:	8b 0d 80 08 00 00    	mov    0x880,%ecx
 567:	85 c9                	test   %ecx,%ecx
 569:	74 04                	je     56f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 56b:	8b 01                	mov    (%ecx),%eax
 56d:	eb 4d                	jmp    5bc <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 56f:	c7 05 80 08 00 00 84 	movl   $0x884,0x880
 576:	08 00 00 
 579:	c7 05 84 08 00 00 84 	movl   $0x884,0x884
 580:	08 00 00 
    base.s.size = 0;
 583:	c7 05 88 08 00 00 00 	movl   $0x0,0x888
 58a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 58d:	b9 84 08 00 00       	mov    $0x884,%ecx
 592:	eb d7                	jmp    56b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 594:	39 da                	cmp    %ebx,%edx
 596:	74 1a                	je     5b2 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 598:	29 da                	sub    %ebx,%edx
 59a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 59d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5a0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5a3:	89 0d 80 08 00 00    	mov    %ecx,0x880
      return (void*)(p + 1);
 5a9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5ac:	83 c4 04             	add    $0x4,%esp
 5af:	5b                   	pop    %ebx
 5b0:	5d                   	pop    %ebp
 5b1:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5b2:	8b 10                	mov    (%eax),%edx
 5b4:	89 11                	mov    %edx,(%ecx)
 5b6:	eb eb                	jmp    5a3 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5b8:	89 c1                	mov    %eax,%ecx
 5ba:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5bc:	8b 50 04             	mov    0x4(%eax),%edx
 5bf:	39 da                	cmp    %ebx,%edx
 5c1:	73 d1                	jae    594 <malloc+0x46>
    if(p == freep)
 5c3:	39 05 80 08 00 00    	cmp    %eax,0x880
 5c9:	75 ed                	jne    5b8 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5cb:	89 d8                	mov    %ebx,%eax
 5cd:	e8 2c ff ff ff       	call   4fe <morecore>
 5d2:	85 c0                	test   %eax,%eax
 5d4:	75 e2                	jne    5b8 <malloc+0x6a>
        return 0;
 5d6:	b8 00 00 00 00       	mov    $0x0,%eax
 5db:	eb cf                	jmp    5ac <malloc+0x5e>
