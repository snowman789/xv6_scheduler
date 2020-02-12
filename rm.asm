
_rm:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 01                	mov    (%ecx),%eax
  16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  19:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  if(argc < 2){
  1c:	83 f8 01             	cmp    $0x1,%eax
  1f:	7e 23                	jle    44 <main+0x44>
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  21:	bb 01 00 00 00       	mov    $0x1,%ebx
  26:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  29:	7d 41                	jge    6c <main+0x6c>
    if(unlink(argv[i]) < 0){
  2b:	8d 34 9f             	lea    (%edi,%ebx,4),%esi
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	ff 36                	pushl  (%esi)
  33:	e8 16 02 00 00       	call   24e <unlink>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	85 c0                	test   %eax,%eax
  3d:	78 19                	js     58 <main+0x58>
  for(i = 1; i < argc; i++){
  3f:	83 c3 01             	add    $0x1,%ebx
  42:	eb e2                	jmp    26 <main+0x26>
    printf(2, "Usage: rm files...\n");
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 20 06 00 00       	push   $0x620
  4c:	6a 02                	push   $0x2
  4e:	e8 15 03 00 00       	call   368 <printf>
    exit();
  53:	e8 a6 01 00 00       	call   1fe <exit>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  58:	83 ec 04             	sub    $0x4,%esp
  5b:	ff 36                	pushl  (%esi)
  5d:	68 34 06 00 00       	push   $0x634
  62:	6a 02                	push   $0x2
  64:	e8 ff 02 00 00       	call   368 <printf>
      break;
  69:	83 c4 10             	add    $0x10,%esp
    }
  }

  exit();
  6c:	e8 8d 01 00 00       	call   1fe <exit>

00000071 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  71:	55                   	push   %ebp
  72:	89 e5                	mov    %esp,%ebp
  74:	53                   	push   %ebx
  75:	8b 45 08             	mov    0x8(%ebp),%eax
  78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7b:	89 c2                	mov    %eax,%edx
  7d:	0f b6 19             	movzbl (%ecx),%ebx
  80:	88 1a                	mov    %bl,(%edx)
  82:	8d 52 01             	lea    0x1(%edx),%edx
  85:	8d 49 01             	lea    0x1(%ecx),%ecx
  88:	84 db                	test   %bl,%bl
  8a:	75 f1                	jne    7d <strcpy+0xc>
    ;
  return os;
}
  8c:	5b                   	pop    %ebx
  8d:	5d                   	pop    %ebp
  8e:	c3                   	ret    

0000008f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8f:	55                   	push   %ebp
  90:	89 e5                	mov    %esp,%ebp
  92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  95:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  98:	eb 06                	jmp    a0 <strcmp+0x11>
    p++, q++;
  9a:	83 c1 01             	add    $0x1,%ecx
  9d:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  a0:	0f b6 01             	movzbl (%ecx),%eax
  a3:	84 c0                	test   %al,%al
  a5:	74 04                	je     ab <strcmp+0x1c>
  a7:	3a 02                	cmp    (%edx),%al
  a9:	74 ef                	je     9a <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  ab:	0f b6 c0             	movzbl %al,%eax
  ae:	0f b6 12             	movzbl (%edx),%edx
  b1:	29 d0                	sub    %edx,%eax
}
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strlen>:

uint
strlen(const char *s)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  bb:	ba 00 00 00 00       	mov    $0x0,%edx
  c0:	eb 03                	jmp    c5 <strlen+0x10>
  c2:	83 c2 01             	add    $0x1,%edx
  c5:	89 d0                	mov    %edx,%eax
  c7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  cb:	75 f5                	jne    c2 <strlen+0xd>
    ;
  return n;
}
  cd:	5d                   	pop    %ebp
  ce:	c3                   	ret    

000000cf <memset>:

void*
memset(void *dst, int c, uint n)
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  d2:	57                   	push   %edi
  d3:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  d6:	89 d7                	mov    %edx,%edi
  d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  db:	8b 45 0c             	mov    0xc(%ebp),%eax
  de:	fc                   	cld    
  df:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  e1:	89 d0                	mov    %edx,%eax
  e3:	5f                   	pop    %edi
  e4:	5d                   	pop    %ebp
  e5:	c3                   	ret    

000000e6 <strchr>:

char*
strchr(const char *s, char c)
{
  e6:	55                   	push   %ebp
  e7:	89 e5                	mov    %esp,%ebp
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  f0:	0f b6 10             	movzbl (%eax),%edx
  f3:	84 d2                	test   %dl,%dl
  f5:	74 09                	je     100 <strchr+0x1a>
    if(*s == c)
  f7:	38 ca                	cmp    %cl,%dl
  f9:	74 0a                	je     105 <strchr+0x1f>
  for(; *s; s++)
  fb:	83 c0 01             	add    $0x1,%eax
  fe:	eb f0                	jmp    f0 <strchr+0xa>
      return (char*)s;
  return 0;
 100:	b8 00 00 00 00       	mov    $0x0,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <gets>:

char*
gets(char *buf, int max)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	57                   	push   %edi
 10b:	56                   	push   %esi
 10c:	53                   	push   %ebx
 10d:	83 ec 1c             	sub    $0x1c,%esp
 110:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 113:	bb 00 00 00 00       	mov    $0x0,%ebx
 118:	8d 73 01             	lea    0x1(%ebx),%esi
 11b:	3b 75 0c             	cmp    0xc(%ebp),%esi
 11e:	7d 2e                	jge    14e <gets+0x47>
    cc = read(0, &c, 1);
 120:	83 ec 04             	sub    $0x4,%esp
 123:	6a 01                	push   $0x1
 125:	8d 45 e7             	lea    -0x19(%ebp),%eax
 128:	50                   	push   %eax
 129:	6a 00                	push   $0x0
 12b:	e8 e6 00 00 00       	call   216 <read>
    if(cc < 1)
 130:	83 c4 10             	add    $0x10,%esp
 133:	85 c0                	test   %eax,%eax
 135:	7e 17                	jle    14e <gets+0x47>
      break;
    buf[i++] = c;
 137:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 13b:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 13e:	3c 0a                	cmp    $0xa,%al
 140:	0f 94 c2             	sete   %dl
 143:	3c 0d                	cmp    $0xd,%al
 145:	0f 94 c0             	sete   %al
    buf[i++] = c;
 148:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 14a:	08 c2                	or     %al,%dl
 14c:	74 ca                	je     118 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 14e:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 152:	89 f8                	mov    %edi,%eax
 154:	8d 65 f4             	lea    -0xc(%ebp),%esp
 157:	5b                   	pop    %ebx
 158:	5e                   	pop    %esi
 159:	5f                   	pop    %edi
 15a:	5d                   	pop    %ebp
 15b:	c3                   	ret    

0000015c <stat>:

int
stat(const char *n, struct stat *st)
{
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
 15f:	56                   	push   %esi
 160:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 161:	83 ec 08             	sub    $0x8,%esp
 164:	6a 00                	push   $0x0
 166:	ff 75 08             	pushl  0x8(%ebp)
 169:	e8 d0 00 00 00       	call   23e <open>
  if(fd < 0)
 16e:	83 c4 10             	add    $0x10,%esp
 171:	85 c0                	test   %eax,%eax
 173:	78 24                	js     199 <stat+0x3d>
 175:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 177:	83 ec 08             	sub    $0x8,%esp
 17a:	ff 75 0c             	pushl  0xc(%ebp)
 17d:	50                   	push   %eax
 17e:	e8 d3 00 00 00       	call   256 <fstat>
 183:	89 c6                	mov    %eax,%esi
  close(fd);
 185:	89 1c 24             	mov    %ebx,(%esp)
 188:	e8 99 00 00 00       	call   226 <close>
  return r;
 18d:	83 c4 10             	add    $0x10,%esp
}
 190:	89 f0                	mov    %esi,%eax
 192:	8d 65 f8             	lea    -0x8(%ebp),%esp
 195:	5b                   	pop    %ebx
 196:	5e                   	pop    %esi
 197:	5d                   	pop    %ebp
 198:	c3                   	ret    
    return -1;
 199:	be ff ff ff ff       	mov    $0xffffffff,%esi
 19e:	eb f0                	jmp    190 <stat+0x34>

000001a0 <atoi>:

int
atoi(const char *s)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	53                   	push   %ebx
 1a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1a7:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1ac:	eb 10                	jmp    1be <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1ae:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1b1:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1b4:	83 c1 01             	add    $0x1,%ecx
 1b7:	0f be d2             	movsbl %dl,%edx
 1ba:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1be:	0f b6 11             	movzbl (%ecx),%edx
 1c1:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1c4:	80 fb 09             	cmp    $0x9,%bl
 1c7:	76 e5                	jbe    1ae <atoi+0xe>
  return n;
}
 1c9:	5b                   	pop    %ebx
 1ca:	5d                   	pop    %ebp
 1cb:	c3                   	ret    

000001cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
 1cf:	56                   	push   %esi
 1d0:	53                   	push   %ebx
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1d7:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1da:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1dc:	eb 0d                	jmp    1eb <memmove+0x1f>
    *dst++ = *src++;
 1de:	0f b6 13             	movzbl (%ebx),%edx
 1e1:	88 11                	mov    %dl,(%ecx)
 1e3:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1e6:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1e9:	89 f2                	mov    %esi,%edx
 1eb:	8d 72 ff             	lea    -0x1(%edx),%esi
 1ee:	85 d2                	test   %edx,%edx
 1f0:	7f ec                	jg     1de <memmove+0x12>
  return vdst;
}
 1f2:	5b                   	pop    %ebx
 1f3:	5e                   	pop    %esi
 1f4:	5d                   	pop    %ebp
 1f5:	c3                   	ret    

000001f6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1f6:	b8 01 00 00 00       	mov    $0x1,%eax
 1fb:	cd 40                	int    $0x40
 1fd:	c3                   	ret    

000001fe <exit>:
SYSCALL(exit)
 1fe:	b8 02 00 00 00       	mov    $0x2,%eax
 203:	cd 40                	int    $0x40
 205:	c3                   	ret    

00000206 <wait>:
SYSCALL(wait)
 206:	b8 03 00 00 00       	mov    $0x3,%eax
 20b:	cd 40                	int    $0x40
 20d:	c3                   	ret    

0000020e <pipe>:
SYSCALL(pipe)
 20e:	b8 04 00 00 00       	mov    $0x4,%eax
 213:	cd 40                	int    $0x40
 215:	c3                   	ret    

00000216 <read>:
SYSCALL(read)
 216:	b8 05 00 00 00       	mov    $0x5,%eax
 21b:	cd 40                	int    $0x40
 21d:	c3                   	ret    

0000021e <write>:
SYSCALL(write)
 21e:	b8 10 00 00 00       	mov    $0x10,%eax
 223:	cd 40                	int    $0x40
 225:	c3                   	ret    

00000226 <close>:
SYSCALL(close)
 226:	b8 15 00 00 00       	mov    $0x15,%eax
 22b:	cd 40                	int    $0x40
 22d:	c3                   	ret    

0000022e <kill>:
SYSCALL(kill)
 22e:	b8 06 00 00 00       	mov    $0x6,%eax
 233:	cd 40                	int    $0x40
 235:	c3                   	ret    

00000236 <exec>:
SYSCALL(exec)
 236:	b8 07 00 00 00       	mov    $0x7,%eax
 23b:	cd 40                	int    $0x40
 23d:	c3                   	ret    

0000023e <open>:
SYSCALL(open)
 23e:	b8 0f 00 00 00       	mov    $0xf,%eax
 243:	cd 40                	int    $0x40
 245:	c3                   	ret    

00000246 <mknod>:
SYSCALL(mknod)
 246:	b8 11 00 00 00       	mov    $0x11,%eax
 24b:	cd 40                	int    $0x40
 24d:	c3                   	ret    

0000024e <unlink>:
SYSCALL(unlink)
 24e:	b8 12 00 00 00       	mov    $0x12,%eax
 253:	cd 40                	int    $0x40
 255:	c3                   	ret    

00000256 <fstat>:
SYSCALL(fstat)
 256:	b8 08 00 00 00       	mov    $0x8,%eax
 25b:	cd 40                	int    $0x40
 25d:	c3                   	ret    

0000025e <link>:
SYSCALL(link)
 25e:	b8 13 00 00 00       	mov    $0x13,%eax
 263:	cd 40                	int    $0x40
 265:	c3                   	ret    

00000266 <mkdir>:
SYSCALL(mkdir)
 266:	b8 14 00 00 00       	mov    $0x14,%eax
 26b:	cd 40                	int    $0x40
 26d:	c3                   	ret    

0000026e <chdir>:
SYSCALL(chdir)
 26e:	b8 09 00 00 00       	mov    $0x9,%eax
 273:	cd 40                	int    $0x40
 275:	c3                   	ret    

00000276 <dup>:
SYSCALL(dup)
 276:	b8 0a 00 00 00       	mov    $0xa,%eax
 27b:	cd 40                	int    $0x40
 27d:	c3                   	ret    

0000027e <getpid>:
SYSCALL(getpid)
 27e:	b8 0b 00 00 00       	mov    $0xb,%eax
 283:	cd 40                	int    $0x40
 285:	c3                   	ret    

00000286 <sbrk>:
SYSCALL(sbrk)
 286:	b8 0c 00 00 00       	mov    $0xc,%eax
 28b:	cd 40                	int    $0x40
 28d:	c3                   	ret    

0000028e <sleep>:
SYSCALL(sleep)
 28e:	b8 0d 00 00 00       	mov    $0xd,%eax
 293:	cd 40                	int    $0x40
 295:	c3                   	ret    

00000296 <uptime>:
SYSCALL(uptime)
 296:	b8 0e 00 00 00       	mov    $0xe,%eax
 29b:	cd 40                	int    $0x40
 29d:	c3                   	ret    

0000029e <yield>:
SYSCALL(yield)
 29e:	b8 16 00 00 00       	mov    $0x16,%eax
 2a3:	cd 40                	int    $0x40
 2a5:	c3                   	ret    

000002a6 <shutdown>:
SYSCALL(shutdown)
 2a6:	b8 17 00 00 00       	mov    $0x17,%eax
 2ab:	cd 40                	int    $0x40
 2ad:	c3                   	ret    

000002ae <writecount>:
SYSCALL(writecount)
 2ae:	b8 18 00 00 00       	mov    $0x18,%eax
 2b3:	cd 40                	int    $0x40
 2b5:	c3                   	ret    

000002b6 <setwritecount>:
SYSCALL(setwritecount)
 2b6:	b8 19 00 00 00       	mov    $0x19,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <settickets>:
SYSCALL(settickets)
 2be:	b8 1a 00 00 00       	mov    $0x1a,%eax
 2c3:	cd 40                	int    $0x40
 2c5:	c3                   	ret    

000002c6 <getprocessesinfo>:
 2c6:	b8 1b 00 00 00       	mov    $0x1b,%eax
 2cb:	cd 40                	int    $0x40
 2cd:	c3                   	ret    

000002ce <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2ce:	55                   	push   %ebp
 2cf:	89 e5                	mov    %esp,%ebp
 2d1:	83 ec 1c             	sub    $0x1c,%esp
 2d4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2d7:	6a 01                	push   $0x1
 2d9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2dc:	52                   	push   %edx
 2dd:	50                   	push   %eax
 2de:	e8 3b ff ff ff       	call   21e <write>
}
 2e3:	83 c4 10             	add    $0x10,%esp
 2e6:	c9                   	leave  
 2e7:	c3                   	ret    

000002e8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	57                   	push   %edi
 2ec:	56                   	push   %esi
 2ed:	53                   	push   %ebx
 2ee:	83 ec 2c             	sub    $0x2c,%esp
 2f1:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2f7:	0f 95 c3             	setne  %bl
 2fa:	89 d0                	mov    %edx,%eax
 2fc:	c1 e8 1f             	shr    $0x1f,%eax
 2ff:	84 c3                	test   %al,%bl
 301:	74 10                	je     313 <printint+0x2b>
    neg = 1;
    x = -xx;
 303:	f7 da                	neg    %edx
    neg = 1;
 305:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 30c:	be 00 00 00 00       	mov    $0x0,%esi
 311:	eb 0b                	jmp    31e <printint+0x36>
  neg = 0;
 313:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 31a:	eb f0                	jmp    30c <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 31c:	89 c6                	mov    %eax,%esi
 31e:	89 d0                	mov    %edx,%eax
 320:	ba 00 00 00 00       	mov    $0x0,%edx
 325:	f7 f1                	div    %ecx
 327:	89 c3                	mov    %eax,%ebx
 329:	8d 46 01             	lea    0x1(%esi),%eax
 32c:	0f b6 92 54 06 00 00 	movzbl 0x654(%edx),%edx
 333:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 337:	89 da                	mov    %ebx,%edx
 339:	85 db                	test   %ebx,%ebx
 33b:	75 df                	jne    31c <printint+0x34>
 33d:	89 c3                	mov    %eax,%ebx
  if(neg)
 33f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 343:	74 16                	je     35b <printint+0x73>
    buf[i++] = '-';
 345:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 34a:	8d 5e 02             	lea    0x2(%esi),%ebx
 34d:	eb 0c                	jmp    35b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 34f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 354:	89 f8                	mov    %edi,%eax
 356:	e8 73 ff ff ff       	call   2ce <putc>
  while(--i >= 0)
 35b:	83 eb 01             	sub    $0x1,%ebx
 35e:	79 ef                	jns    34f <printint+0x67>
}
 360:	83 c4 2c             	add    $0x2c,%esp
 363:	5b                   	pop    %ebx
 364:	5e                   	pop    %esi
 365:	5f                   	pop    %edi
 366:	5d                   	pop    %ebp
 367:	c3                   	ret    

00000368 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	57                   	push   %edi
 36c:	56                   	push   %esi
 36d:	53                   	push   %ebx
 36e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 371:	8d 45 10             	lea    0x10(%ebp),%eax
 374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 377:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 37c:	bb 00 00 00 00       	mov    $0x0,%ebx
 381:	eb 14                	jmp    397 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 383:	89 fa                	mov    %edi,%edx
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	e8 41 ff ff ff       	call   2ce <putc>
 38d:	eb 05                	jmp    394 <printf+0x2c>
      }
    } else if(state == '%'){
 38f:	83 fe 25             	cmp    $0x25,%esi
 392:	74 25                	je     3b9 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 394:	83 c3 01             	add    $0x1,%ebx
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 39e:	84 c0                	test   %al,%al
 3a0:	0f 84 23 01 00 00    	je     4c9 <printf+0x161>
    c = fmt[i] & 0xff;
 3a6:	0f be f8             	movsbl %al,%edi
 3a9:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3ac:	85 f6                	test   %esi,%esi
 3ae:	75 df                	jne    38f <printf+0x27>
      if(c == '%'){
 3b0:	83 f8 25             	cmp    $0x25,%eax
 3b3:	75 ce                	jne    383 <printf+0x1b>
        state = '%';
 3b5:	89 c6                	mov    %eax,%esi
 3b7:	eb db                	jmp    394 <printf+0x2c>
      if(c == 'd'){
 3b9:	83 f8 64             	cmp    $0x64,%eax
 3bc:	74 49                	je     407 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3be:	83 f8 78             	cmp    $0x78,%eax
 3c1:	0f 94 c1             	sete   %cl
 3c4:	83 f8 70             	cmp    $0x70,%eax
 3c7:	0f 94 c2             	sete   %dl
 3ca:	08 d1                	or     %dl,%cl
 3cc:	75 63                	jne    431 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3ce:	83 f8 73             	cmp    $0x73,%eax
 3d1:	0f 84 84 00 00 00    	je     45b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3d7:	83 f8 63             	cmp    $0x63,%eax
 3da:	0f 84 b7 00 00 00    	je     497 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3e0:	83 f8 25             	cmp    $0x25,%eax
 3e3:	0f 84 cc 00 00 00    	je     4b5 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3e9:	ba 25 00 00 00       	mov    $0x25,%edx
 3ee:	8b 45 08             	mov    0x8(%ebp),%eax
 3f1:	e8 d8 fe ff ff       	call   2ce <putc>
        putc(fd, c);
 3f6:	89 fa                	mov    %edi,%edx
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
 3fb:	e8 ce fe ff ff       	call   2ce <putc>
      }
      state = 0;
 400:	be 00 00 00 00       	mov    $0x0,%esi
 405:	eb 8d                	jmp    394 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 40a:	8b 17                	mov    (%edi),%edx
 40c:	83 ec 0c             	sub    $0xc,%esp
 40f:	6a 01                	push   $0x1
 411:	b9 0a 00 00 00       	mov    $0xa,%ecx
 416:	8b 45 08             	mov    0x8(%ebp),%eax
 419:	e8 ca fe ff ff       	call   2e8 <printint>
        ap++;
 41e:	83 c7 04             	add    $0x4,%edi
 421:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 424:	83 c4 10             	add    $0x10,%esp
      state = 0;
 427:	be 00 00 00 00       	mov    $0x0,%esi
 42c:	e9 63 ff ff ff       	jmp    394 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 434:	8b 17                	mov    (%edi),%edx
 436:	83 ec 0c             	sub    $0xc,%esp
 439:	6a 00                	push   $0x0
 43b:	b9 10 00 00 00       	mov    $0x10,%ecx
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	e8 a0 fe ff ff       	call   2e8 <printint>
        ap++;
 448:	83 c7 04             	add    $0x4,%edi
 44b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 44e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 451:	be 00 00 00 00       	mov    $0x0,%esi
 456:	e9 39 ff ff ff       	jmp    394 <printf+0x2c>
        s = (char*)*ap;
 45b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 45e:	8b 30                	mov    (%eax),%esi
        ap++;
 460:	83 c0 04             	add    $0x4,%eax
 463:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 466:	85 f6                	test   %esi,%esi
 468:	75 28                	jne    492 <printf+0x12a>
          s = "(null)";
 46a:	be 4d 06 00 00       	mov    $0x64d,%esi
 46f:	8b 7d 08             	mov    0x8(%ebp),%edi
 472:	eb 0d                	jmp    481 <printf+0x119>
          putc(fd, *s);
 474:	0f be d2             	movsbl %dl,%edx
 477:	89 f8                	mov    %edi,%eax
 479:	e8 50 fe ff ff       	call   2ce <putc>
          s++;
 47e:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 481:	0f b6 16             	movzbl (%esi),%edx
 484:	84 d2                	test   %dl,%dl
 486:	75 ec                	jne    474 <printf+0x10c>
      state = 0;
 488:	be 00 00 00 00       	mov    $0x0,%esi
 48d:	e9 02 ff ff ff       	jmp    394 <printf+0x2c>
 492:	8b 7d 08             	mov    0x8(%ebp),%edi
 495:	eb ea                	jmp    481 <printf+0x119>
        putc(fd, *ap);
 497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 49a:	0f be 17             	movsbl (%edi),%edx
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	e8 29 fe ff ff       	call   2ce <putc>
        ap++;
 4a5:	83 c7 04             	add    $0x4,%edi
 4a8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4ab:	be 00 00 00 00       	mov    $0x0,%esi
 4b0:	e9 df fe ff ff       	jmp    394 <printf+0x2c>
        putc(fd, c);
 4b5:	89 fa                	mov    %edi,%edx
 4b7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ba:	e8 0f fe ff ff       	call   2ce <putc>
      state = 0;
 4bf:	be 00 00 00 00       	mov    $0x0,%esi
 4c4:	e9 cb fe ff ff       	jmp    394 <printf+0x2c>
    }
  }
}
 4c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4cc:	5b                   	pop    %ebx
 4cd:	5e                   	pop    %esi
 4ce:	5f                   	pop    %edi
 4cf:	5d                   	pop    %ebp
 4d0:	c3                   	ret    

000004d1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4d1:	55                   	push   %ebp
 4d2:	89 e5                	mov    %esp,%ebp
 4d4:	57                   	push   %edi
 4d5:	56                   	push   %esi
 4d6:	53                   	push   %ebx
 4d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4da:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4dd:	a1 f8 08 00 00       	mov    0x8f8,%eax
 4e2:	eb 02                	jmp    4e6 <free+0x15>
 4e4:	89 d0                	mov    %edx,%eax
 4e6:	39 c8                	cmp    %ecx,%eax
 4e8:	73 04                	jae    4ee <free+0x1d>
 4ea:	39 08                	cmp    %ecx,(%eax)
 4ec:	77 12                	ja     500 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4ee:	8b 10                	mov    (%eax),%edx
 4f0:	39 c2                	cmp    %eax,%edx
 4f2:	77 f0                	ja     4e4 <free+0x13>
 4f4:	39 c8                	cmp    %ecx,%eax
 4f6:	72 08                	jb     500 <free+0x2f>
 4f8:	39 ca                	cmp    %ecx,%edx
 4fa:	77 04                	ja     500 <free+0x2f>
 4fc:	89 d0                	mov    %edx,%eax
 4fe:	eb e6                	jmp    4e6 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 500:	8b 73 fc             	mov    -0x4(%ebx),%esi
 503:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 506:	8b 10                	mov    (%eax),%edx
 508:	39 d7                	cmp    %edx,%edi
 50a:	74 19                	je     525 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 50c:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 50f:	8b 50 04             	mov    0x4(%eax),%edx
 512:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 515:	39 ce                	cmp    %ecx,%esi
 517:	74 1b                	je     534 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 519:	89 08                	mov    %ecx,(%eax)
  freep = p;
 51b:	a3 f8 08 00 00       	mov    %eax,0x8f8
}
 520:	5b                   	pop    %ebx
 521:	5e                   	pop    %esi
 522:	5f                   	pop    %edi
 523:	5d                   	pop    %ebp
 524:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 525:	03 72 04             	add    0x4(%edx),%esi
 528:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 52b:	8b 10                	mov    (%eax),%edx
 52d:	8b 12                	mov    (%edx),%edx
 52f:	89 53 f8             	mov    %edx,-0x8(%ebx)
 532:	eb db                	jmp    50f <free+0x3e>
    p->s.size += bp->s.size;
 534:	03 53 fc             	add    -0x4(%ebx),%edx
 537:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 53a:	8b 53 f8             	mov    -0x8(%ebx),%edx
 53d:	89 10                	mov    %edx,(%eax)
 53f:	eb da                	jmp    51b <free+0x4a>

00000541 <morecore>:

static Header*
morecore(uint nu)
{
 541:	55                   	push   %ebp
 542:	89 e5                	mov    %esp,%ebp
 544:	53                   	push   %ebx
 545:	83 ec 04             	sub    $0x4,%esp
 548:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 54a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 54f:	77 05                	ja     556 <morecore+0x15>
    nu = 4096;
 551:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 556:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 55d:	83 ec 0c             	sub    $0xc,%esp
 560:	50                   	push   %eax
 561:	e8 20 fd ff ff       	call   286 <sbrk>
  if(p == (char*)-1)
 566:	83 c4 10             	add    $0x10,%esp
 569:	83 f8 ff             	cmp    $0xffffffff,%eax
 56c:	74 1c                	je     58a <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 56e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 571:	83 c0 08             	add    $0x8,%eax
 574:	83 ec 0c             	sub    $0xc,%esp
 577:	50                   	push   %eax
 578:	e8 54 ff ff ff       	call   4d1 <free>
  return freep;
 57d:	a1 f8 08 00 00       	mov    0x8f8,%eax
 582:	83 c4 10             	add    $0x10,%esp
}
 585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 588:	c9                   	leave  
 589:	c3                   	ret    
    return 0;
 58a:	b8 00 00 00 00       	mov    $0x0,%eax
 58f:	eb f4                	jmp    585 <morecore+0x44>

00000591 <malloc>:

void*
malloc(uint nbytes)
{
 591:	55                   	push   %ebp
 592:	89 e5                	mov    %esp,%ebp
 594:	53                   	push   %ebx
 595:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	8d 58 07             	lea    0x7(%eax),%ebx
 59e:	c1 eb 03             	shr    $0x3,%ebx
 5a1:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5a4:	8b 0d f8 08 00 00    	mov    0x8f8,%ecx
 5aa:	85 c9                	test   %ecx,%ecx
 5ac:	74 04                	je     5b2 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ae:	8b 01                	mov    (%ecx),%eax
 5b0:	eb 4d                	jmp    5ff <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5b2:	c7 05 f8 08 00 00 fc 	movl   $0x8fc,0x8f8
 5b9:	08 00 00 
 5bc:	c7 05 fc 08 00 00 fc 	movl   $0x8fc,0x8fc
 5c3:	08 00 00 
    base.s.size = 0;
 5c6:	c7 05 00 09 00 00 00 	movl   $0x0,0x900
 5cd:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5d0:	b9 fc 08 00 00       	mov    $0x8fc,%ecx
 5d5:	eb d7                	jmp    5ae <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5d7:	39 da                	cmp    %ebx,%edx
 5d9:	74 1a                	je     5f5 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5db:	29 da                	sub    %ebx,%edx
 5dd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5e0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5e3:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5e6:	89 0d f8 08 00 00    	mov    %ecx,0x8f8
      return (void*)(p + 1);
 5ec:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5ef:	83 c4 04             	add    $0x4,%esp
 5f2:	5b                   	pop    %ebx
 5f3:	5d                   	pop    %ebp
 5f4:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5f5:	8b 10                	mov    (%eax),%edx
 5f7:	89 11                	mov    %edx,(%ecx)
 5f9:	eb eb                	jmp    5e6 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5fb:	89 c1                	mov    %eax,%ecx
 5fd:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ff:	8b 50 04             	mov    0x4(%eax),%edx
 602:	39 da                	cmp    %ebx,%edx
 604:	73 d1                	jae    5d7 <malloc+0x46>
    if(p == freep)
 606:	39 05 f8 08 00 00    	cmp    %eax,0x8f8
 60c:	75 ed                	jne    5fb <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 60e:	89 d8                	mov    %ebx,%eax
 610:	e8 2c ff ff ff       	call   541 <morecore>
 615:	85 c0                	test   %eax,%eax
 617:	75 e2                	jne    5fb <malloc+0x6a>
        return 0;
 619:	b8 00 00 00 00       	mov    $0x0,%eax
 61e:	eb cf                	jmp    5ef <malloc+0x5e>
