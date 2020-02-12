
_testcount:     file format elf32-i386


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
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	81 ec 18 03 00 00    	sub    $0x318,%esp

    //test setwritecount works
    printf(1,"Testing Num times process run \n");
  15:	68 f8 05 00 00       	push   $0x5f8
  1a:	6a 01                	push   $0x1
  1c:	e8 1e 03 00 00       	call   33f <printf>
    // printf(1,"this is a test \n");
    // printf(1, "%d\n", writecount() );
    
  struct processes_info myInfo;
  struct processes_info *myProcess = &myInfo;
    getprocessesinfo(myProcess);
  21:	8d 9d f4 fc ff ff    	lea    -0x30c(%ebp),%ebx
  27:	89 1c 24             	mov    %ebx,(%esp)
  2a:	e8 6e 02 00 00       	call   29d <getprocessesinfo>
    settickets(69);
  2f:	c7 04 24 45 00 00 00 	movl   $0x45,(%esp)
  36:	e8 5a 02 00 00       	call   295 <settickets>
    getprocessesinfo(myProcess);
  3b:	89 1c 24             	mov    %ebx,(%esp)
  3e:	e8 5a 02 00 00       	call   29d <getprocessesinfo>
  exit();
  43:	e8 8d 01 00 00       	call   1d5 <exit>

00000048 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  48:	55                   	push   %ebp
  49:	89 e5                	mov    %esp,%ebp
  4b:	53                   	push   %ebx
  4c:	8b 45 08             	mov    0x8(%ebp),%eax
  4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  52:	89 c2                	mov    %eax,%edx
  54:	0f b6 19             	movzbl (%ecx),%ebx
  57:	88 1a                	mov    %bl,(%edx)
  59:	8d 52 01             	lea    0x1(%edx),%edx
  5c:	8d 49 01             	lea    0x1(%ecx),%ecx
  5f:	84 db                	test   %bl,%bl
  61:	75 f1                	jne    54 <strcpy+0xc>
    ;
  return os;
}
  63:	5b                   	pop    %ebx
  64:	5d                   	pop    %ebp
  65:	c3                   	ret    

00000066 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  66:	55                   	push   %ebp
  67:	89 e5                	mov    %esp,%ebp
  69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  6f:	eb 06                	jmp    77 <strcmp+0x11>
    p++, q++;
  71:	83 c1 01             	add    $0x1,%ecx
  74:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  77:	0f b6 01             	movzbl (%ecx),%eax
  7a:	84 c0                	test   %al,%al
  7c:	74 04                	je     82 <strcmp+0x1c>
  7e:	3a 02                	cmp    (%edx),%al
  80:	74 ef                	je     71 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  82:	0f b6 c0             	movzbl %al,%eax
  85:	0f b6 12             	movzbl (%edx),%edx
  88:	29 d0                	sub    %edx,%eax
}
  8a:	5d                   	pop    %ebp
  8b:	c3                   	ret    

0000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  92:	ba 00 00 00 00       	mov    $0x0,%edx
  97:	eb 03                	jmp    9c <strlen+0x10>
  99:	83 c2 01             	add    $0x1,%edx
  9c:	89 d0                	mov    %edx,%eax
  9e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  a2:	75 f5                	jne    99 <strlen+0xd>
    ;
  return n;
}
  a4:	5d                   	pop    %ebp
  a5:	c3                   	ret    

000000a6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a6:	55                   	push   %ebp
  a7:	89 e5                	mov    %esp,%ebp
  a9:	57                   	push   %edi
  aa:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  ad:	89 d7                	mov    %edx,%edi
  af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  b5:	fc                   	cld    
  b6:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  b8:	89 d0                	mov    %edx,%eax
  ba:	5f                   	pop    %edi
  bb:	5d                   	pop    %ebp
  bc:	c3                   	ret    

000000bd <strchr>:

char*
strchr(const char *s, char c)
{
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  c0:	8b 45 08             	mov    0x8(%ebp),%eax
  c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  c7:	0f b6 10             	movzbl (%eax),%edx
  ca:	84 d2                	test   %dl,%dl
  cc:	74 09                	je     d7 <strchr+0x1a>
    if(*s == c)
  ce:	38 ca                	cmp    %cl,%dl
  d0:	74 0a                	je     dc <strchr+0x1f>
  for(; *s; s++)
  d2:	83 c0 01             	add    $0x1,%eax
  d5:	eb f0                	jmp    c7 <strchr+0xa>
      return (char*)s;
  return 0;
  d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  dc:	5d                   	pop    %ebp
  dd:	c3                   	ret    

000000de <gets>:

char*
gets(char *buf, int max)
{
  de:	55                   	push   %ebp
  df:	89 e5                	mov    %esp,%ebp
  e1:	57                   	push   %edi
  e2:	56                   	push   %esi
  e3:	53                   	push   %ebx
  e4:	83 ec 1c             	sub    $0x1c,%esp
  e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  ef:	8d 73 01             	lea    0x1(%ebx),%esi
  f2:	3b 75 0c             	cmp    0xc(%ebp),%esi
  f5:	7d 2e                	jge    125 <gets+0x47>
    cc = read(0, &c, 1);
  f7:	83 ec 04             	sub    $0x4,%esp
  fa:	6a 01                	push   $0x1
  fc:	8d 45 e7             	lea    -0x19(%ebp),%eax
  ff:	50                   	push   %eax
 100:	6a 00                	push   $0x0
 102:	e8 e6 00 00 00       	call   1ed <read>
    if(cc < 1)
 107:	83 c4 10             	add    $0x10,%esp
 10a:	85 c0                	test   %eax,%eax
 10c:	7e 17                	jle    125 <gets+0x47>
      break;
    buf[i++] = c;
 10e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 112:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 115:	3c 0a                	cmp    $0xa,%al
 117:	0f 94 c2             	sete   %dl
 11a:	3c 0d                	cmp    $0xd,%al
 11c:	0f 94 c0             	sete   %al
    buf[i++] = c;
 11f:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 121:	08 c2                	or     %al,%dl
 123:	74 ca                	je     ef <gets+0x11>
      break;
  }
  buf[i] = '\0';
 125:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 129:	89 f8                	mov    %edi,%eax
 12b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 12e:	5b                   	pop    %ebx
 12f:	5e                   	pop    %esi
 130:	5f                   	pop    %edi
 131:	5d                   	pop    %ebp
 132:	c3                   	ret    

00000133 <stat>:

int
stat(const char *n, struct stat *st)
{
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	56                   	push   %esi
 137:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 138:	83 ec 08             	sub    $0x8,%esp
 13b:	6a 00                	push   $0x0
 13d:	ff 75 08             	pushl  0x8(%ebp)
 140:	e8 d0 00 00 00       	call   215 <open>
  if(fd < 0)
 145:	83 c4 10             	add    $0x10,%esp
 148:	85 c0                	test   %eax,%eax
 14a:	78 24                	js     170 <stat+0x3d>
 14c:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 14e:	83 ec 08             	sub    $0x8,%esp
 151:	ff 75 0c             	pushl  0xc(%ebp)
 154:	50                   	push   %eax
 155:	e8 d3 00 00 00       	call   22d <fstat>
 15a:	89 c6                	mov    %eax,%esi
  close(fd);
 15c:	89 1c 24             	mov    %ebx,(%esp)
 15f:	e8 99 00 00 00       	call   1fd <close>
  return r;
 164:	83 c4 10             	add    $0x10,%esp
}
 167:	89 f0                	mov    %esi,%eax
 169:	8d 65 f8             	lea    -0x8(%ebp),%esp
 16c:	5b                   	pop    %ebx
 16d:	5e                   	pop    %esi
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret    
    return -1;
 170:	be ff ff ff ff       	mov    $0xffffffff,%esi
 175:	eb f0                	jmp    167 <stat+0x34>

00000177 <atoi>:

int
atoi(const char *s)
{
 177:	55                   	push   %ebp
 178:	89 e5                	mov    %esp,%ebp
 17a:	53                   	push   %ebx
 17b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 17e:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 183:	eb 10                	jmp    195 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 185:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 188:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 18b:	83 c1 01             	add    $0x1,%ecx
 18e:	0f be d2             	movsbl %dl,%edx
 191:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 195:	0f b6 11             	movzbl (%ecx),%edx
 198:	8d 5a d0             	lea    -0x30(%edx),%ebx
 19b:	80 fb 09             	cmp    $0x9,%bl
 19e:	76 e5                	jbe    185 <atoi+0xe>
  return n;
}
 1a0:	5b                   	pop    %ebx
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	56                   	push   %esi
 1a7:	53                   	push   %ebx
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1ae:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1b1:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1b3:	eb 0d                	jmp    1c2 <memmove+0x1f>
    *dst++ = *src++;
 1b5:	0f b6 13             	movzbl (%ebx),%edx
 1b8:	88 11                	mov    %dl,(%ecx)
 1ba:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1bd:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1c0:	89 f2                	mov    %esi,%edx
 1c2:	8d 72 ff             	lea    -0x1(%edx),%esi
 1c5:	85 d2                	test   %edx,%edx
 1c7:	7f ec                	jg     1b5 <memmove+0x12>
  return vdst;
}
 1c9:	5b                   	pop    %ebx
 1ca:	5e                   	pop    %esi
 1cb:	5d                   	pop    %ebp
 1cc:	c3                   	ret    

000001cd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1cd:	b8 01 00 00 00       	mov    $0x1,%eax
 1d2:	cd 40                	int    $0x40
 1d4:	c3                   	ret    

000001d5 <exit>:
SYSCALL(exit)
 1d5:	b8 02 00 00 00       	mov    $0x2,%eax
 1da:	cd 40                	int    $0x40
 1dc:	c3                   	ret    

000001dd <wait>:
SYSCALL(wait)
 1dd:	b8 03 00 00 00       	mov    $0x3,%eax
 1e2:	cd 40                	int    $0x40
 1e4:	c3                   	ret    

000001e5 <pipe>:
SYSCALL(pipe)
 1e5:	b8 04 00 00 00       	mov    $0x4,%eax
 1ea:	cd 40                	int    $0x40
 1ec:	c3                   	ret    

000001ed <read>:
SYSCALL(read)
 1ed:	b8 05 00 00 00       	mov    $0x5,%eax
 1f2:	cd 40                	int    $0x40
 1f4:	c3                   	ret    

000001f5 <write>:
SYSCALL(write)
 1f5:	b8 10 00 00 00       	mov    $0x10,%eax
 1fa:	cd 40                	int    $0x40
 1fc:	c3                   	ret    

000001fd <close>:
SYSCALL(close)
 1fd:	b8 15 00 00 00       	mov    $0x15,%eax
 202:	cd 40                	int    $0x40
 204:	c3                   	ret    

00000205 <kill>:
SYSCALL(kill)
 205:	b8 06 00 00 00       	mov    $0x6,%eax
 20a:	cd 40                	int    $0x40
 20c:	c3                   	ret    

0000020d <exec>:
SYSCALL(exec)
 20d:	b8 07 00 00 00       	mov    $0x7,%eax
 212:	cd 40                	int    $0x40
 214:	c3                   	ret    

00000215 <open>:
SYSCALL(open)
 215:	b8 0f 00 00 00       	mov    $0xf,%eax
 21a:	cd 40                	int    $0x40
 21c:	c3                   	ret    

0000021d <mknod>:
SYSCALL(mknod)
 21d:	b8 11 00 00 00       	mov    $0x11,%eax
 222:	cd 40                	int    $0x40
 224:	c3                   	ret    

00000225 <unlink>:
SYSCALL(unlink)
 225:	b8 12 00 00 00       	mov    $0x12,%eax
 22a:	cd 40                	int    $0x40
 22c:	c3                   	ret    

0000022d <fstat>:
SYSCALL(fstat)
 22d:	b8 08 00 00 00       	mov    $0x8,%eax
 232:	cd 40                	int    $0x40
 234:	c3                   	ret    

00000235 <link>:
SYSCALL(link)
 235:	b8 13 00 00 00       	mov    $0x13,%eax
 23a:	cd 40                	int    $0x40
 23c:	c3                   	ret    

0000023d <mkdir>:
SYSCALL(mkdir)
 23d:	b8 14 00 00 00       	mov    $0x14,%eax
 242:	cd 40                	int    $0x40
 244:	c3                   	ret    

00000245 <chdir>:
SYSCALL(chdir)
 245:	b8 09 00 00 00       	mov    $0x9,%eax
 24a:	cd 40                	int    $0x40
 24c:	c3                   	ret    

0000024d <dup>:
SYSCALL(dup)
 24d:	b8 0a 00 00 00       	mov    $0xa,%eax
 252:	cd 40                	int    $0x40
 254:	c3                   	ret    

00000255 <getpid>:
SYSCALL(getpid)
 255:	b8 0b 00 00 00       	mov    $0xb,%eax
 25a:	cd 40                	int    $0x40
 25c:	c3                   	ret    

0000025d <sbrk>:
SYSCALL(sbrk)
 25d:	b8 0c 00 00 00       	mov    $0xc,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <sleep>:
SYSCALL(sleep)
 265:	b8 0d 00 00 00       	mov    $0xd,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <uptime>:
SYSCALL(uptime)
 26d:	b8 0e 00 00 00       	mov    $0xe,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <yield>:
SYSCALL(yield)
 275:	b8 16 00 00 00       	mov    $0x16,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <shutdown>:
SYSCALL(shutdown)
 27d:	b8 17 00 00 00       	mov    $0x17,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <writecount>:
SYSCALL(writecount)
 285:	b8 18 00 00 00       	mov    $0x18,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <setwritecount>:
SYSCALL(setwritecount)
 28d:	b8 19 00 00 00       	mov    $0x19,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <settickets>:
SYSCALL(settickets)
 295:	b8 1a 00 00 00       	mov    $0x1a,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <getprocessesinfo>:
 29d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 1c             	sub    $0x1c,%esp
 2ab:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2ae:	6a 01                	push   $0x1
 2b0:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2b3:	52                   	push   %edx
 2b4:	50                   	push   %eax
 2b5:	e8 3b ff ff ff       	call   1f5 <write>
}
 2ba:	83 c4 10             	add    $0x10,%esp
 2bd:	c9                   	leave  
 2be:	c3                   	ret    

000002bf <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	57                   	push   %edi
 2c3:	56                   	push   %esi
 2c4:	53                   	push   %ebx
 2c5:	83 ec 2c             	sub    $0x2c,%esp
 2c8:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2ce:	0f 95 c3             	setne  %bl
 2d1:	89 d0                	mov    %edx,%eax
 2d3:	c1 e8 1f             	shr    $0x1f,%eax
 2d6:	84 c3                	test   %al,%bl
 2d8:	74 10                	je     2ea <printint+0x2b>
    neg = 1;
    x = -xx;
 2da:	f7 da                	neg    %edx
    neg = 1;
 2dc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2e3:	be 00 00 00 00       	mov    $0x0,%esi
 2e8:	eb 0b                	jmp    2f5 <printint+0x36>
  neg = 0;
 2ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2f1:	eb f0                	jmp    2e3 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2f3:	89 c6                	mov    %eax,%esi
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	ba 00 00 00 00       	mov    $0x0,%edx
 2fc:	f7 f1                	div    %ecx
 2fe:	89 c3                	mov    %eax,%ebx
 300:	8d 46 01             	lea    0x1(%esi),%eax
 303:	0f b6 92 20 06 00 00 	movzbl 0x620(%edx),%edx
 30a:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 30e:	89 da                	mov    %ebx,%edx
 310:	85 db                	test   %ebx,%ebx
 312:	75 df                	jne    2f3 <printint+0x34>
 314:	89 c3                	mov    %eax,%ebx
  if(neg)
 316:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 31a:	74 16                	je     332 <printint+0x73>
    buf[i++] = '-';
 31c:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 321:	8d 5e 02             	lea    0x2(%esi),%ebx
 324:	eb 0c                	jmp    332 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 326:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 32b:	89 f8                	mov    %edi,%eax
 32d:	e8 73 ff ff ff       	call   2a5 <putc>
  while(--i >= 0)
 332:	83 eb 01             	sub    $0x1,%ebx
 335:	79 ef                	jns    326 <printint+0x67>
}
 337:	83 c4 2c             	add    $0x2c,%esp
 33a:	5b                   	pop    %ebx
 33b:	5e                   	pop    %esi
 33c:	5f                   	pop    %edi
 33d:	5d                   	pop    %ebp
 33e:	c3                   	ret    

0000033f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 33f:	55                   	push   %ebp
 340:	89 e5                	mov    %esp,%ebp
 342:	57                   	push   %edi
 343:	56                   	push   %esi
 344:	53                   	push   %ebx
 345:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 348:	8d 45 10             	lea    0x10(%ebp),%eax
 34b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 34e:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 353:	bb 00 00 00 00       	mov    $0x0,%ebx
 358:	eb 14                	jmp    36e <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 35a:	89 fa                	mov    %edi,%edx
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	e8 41 ff ff ff       	call   2a5 <putc>
 364:	eb 05                	jmp    36b <printf+0x2c>
      }
    } else if(state == '%'){
 366:	83 fe 25             	cmp    $0x25,%esi
 369:	74 25                	je     390 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 36b:	83 c3 01             	add    $0x1,%ebx
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 375:	84 c0                	test   %al,%al
 377:	0f 84 23 01 00 00    	je     4a0 <printf+0x161>
    c = fmt[i] & 0xff;
 37d:	0f be f8             	movsbl %al,%edi
 380:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 383:	85 f6                	test   %esi,%esi
 385:	75 df                	jne    366 <printf+0x27>
      if(c == '%'){
 387:	83 f8 25             	cmp    $0x25,%eax
 38a:	75 ce                	jne    35a <printf+0x1b>
        state = '%';
 38c:	89 c6                	mov    %eax,%esi
 38e:	eb db                	jmp    36b <printf+0x2c>
      if(c == 'd'){
 390:	83 f8 64             	cmp    $0x64,%eax
 393:	74 49                	je     3de <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 395:	83 f8 78             	cmp    $0x78,%eax
 398:	0f 94 c1             	sete   %cl
 39b:	83 f8 70             	cmp    $0x70,%eax
 39e:	0f 94 c2             	sete   %dl
 3a1:	08 d1                	or     %dl,%cl
 3a3:	75 63                	jne    408 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3a5:	83 f8 73             	cmp    $0x73,%eax
 3a8:	0f 84 84 00 00 00    	je     432 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3ae:	83 f8 63             	cmp    $0x63,%eax
 3b1:	0f 84 b7 00 00 00    	je     46e <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3b7:	83 f8 25             	cmp    $0x25,%eax
 3ba:	0f 84 cc 00 00 00    	je     48c <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3c0:	ba 25 00 00 00       	mov    $0x25,%edx
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	e8 d8 fe ff ff       	call   2a5 <putc>
        putc(fd, c);
 3cd:	89 fa                	mov    %edi,%edx
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	e8 ce fe ff ff       	call   2a5 <putc>
      }
      state = 0;
 3d7:	be 00 00 00 00       	mov    $0x0,%esi
 3dc:	eb 8d                	jmp    36b <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e1:	8b 17                	mov    (%edi),%edx
 3e3:	83 ec 0c             	sub    $0xc,%esp
 3e6:	6a 01                	push   $0x1
 3e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	e8 ca fe ff ff       	call   2bf <printint>
        ap++;
 3f5:	83 c7 04             	add    $0x4,%edi
 3f8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fb:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3fe:	be 00 00 00 00       	mov    $0x0,%esi
 403:	e9 63 ff ff ff       	jmp    36b <printf+0x2c>
        printint(fd, *ap, 16, 0);
 408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 40b:	8b 17                	mov    (%edi),%edx
 40d:	83 ec 0c             	sub    $0xc,%esp
 410:	6a 00                	push   $0x0
 412:	b9 10 00 00 00       	mov    $0x10,%ecx
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	e8 a0 fe ff ff       	call   2bf <printint>
        ap++;
 41f:	83 c7 04             	add    $0x4,%edi
 422:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 425:	83 c4 10             	add    $0x10,%esp
      state = 0;
 428:	be 00 00 00 00       	mov    $0x0,%esi
 42d:	e9 39 ff ff ff       	jmp    36b <printf+0x2c>
        s = (char*)*ap;
 432:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 435:	8b 30                	mov    (%eax),%esi
        ap++;
 437:	83 c0 04             	add    $0x4,%eax
 43a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 43d:	85 f6                	test   %esi,%esi
 43f:	75 28                	jne    469 <printf+0x12a>
          s = "(null)";
 441:	be 18 06 00 00       	mov    $0x618,%esi
 446:	8b 7d 08             	mov    0x8(%ebp),%edi
 449:	eb 0d                	jmp    458 <printf+0x119>
          putc(fd, *s);
 44b:	0f be d2             	movsbl %dl,%edx
 44e:	89 f8                	mov    %edi,%eax
 450:	e8 50 fe ff ff       	call   2a5 <putc>
          s++;
 455:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 458:	0f b6 16             	movzbl (%esi),%edx
 45b:	84 d2                	test   %dl,%dl
 45d:	75 ec                	jne    44b <printf+0x10c>
      state = 0;
 45f:	be 00 00 00 00       	mov    $0x0,%esi
 464:	e9 02 ff ff ff       	jmp    36b <printf+0x2c>
 469:	8b 7d 08             	mov    0x8(%ebp),%edi
 46c:	eb ea                	jmp    458 <printf+0x119>
        putc(fd, *ap);
 46e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 471:	0f be 17             	movsbl (%edi),%edx
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	e8 29 fe ff ff       	call   2a5 <putc>
        ap++;
 47c:	83 c7 04             	add    $0x4,%edi
 47f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 482:	be 00 00 00 00       	mov    $0x0,%esi
 487:	e9 df fe ff ff       	jmp    36b <printf+0x2c>
        putc(fd, c);
 48c:	89 fa                	mov    %edi,%edx
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	e8 0f fe ff ff       	call   2a5 <putc>
      state = 0;
 496:	be 00 00 00 00       	mov    $0x0,%esi
 49b:	e9 cb fe ff ff       	jmp    36b <printf+0x2c>
    }
  }
}
 4a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4a3:	5b                   	pop    %ebx
 4a4:	5e                   	pop    %esi
 4a5:	5f                   	pop    %edi
 4a6:	5d                   	pop    %ebp
 4a7:	c3                   	ret    

000004a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a8:	55                   	push   %ebp
 4a9:	89 e5                	mov    %esp,%ebp
 4ab:	57                   	push   %edi
 4ac:	56                   	push   %esi
 4ad:	53                   	push   %ebx
 4ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4b1:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b4:	a1 bc 08 00 00       	mov    0x8bc,%eax
 4b9:	eb 02                	jmp    4bd <free+0x15>
 4bb:	89 d0                	mov    %edx,%eax
 4bd:	39 c8                	cmp    %ecx,%eax
 4bf:	73 04                	jae    4c5 <free+0x1d>
 4c1:	39 08                	cmp    %ecx,(%eax)
 4c3:	77 12                	ja     4d7 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4c5:	8b 10                	mov    (%eax),%edx
 4c7:	39 c2                	cmp    %eax,%edx
 4c9:	77 f0                	ja     4bb <free+0x13>
 4cb:	39 c8                	cmp    %ecx,%eax
 4cd:	72 08                	jb     4d7 <free+0x2f>
 4cf:	39 ca                	cmp    %ecx,%edx
 4d1:	77 04                	ja     4d7 <free+0x2f>
 4d3:	89 d0                	mov    %edx,%eax
 4d5:	eb e6                	jmp    4bd <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d7:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4da:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4dd:	8b 10                	mov    (%eax),%edx
 4df:	39 d7                	cmp    %edx,%edi
 4e1:	74 19                	je     4fc <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4e3:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4e6:	8b 50 04             	mov    0x4(%eax),%edx
 4e9:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4ec:	39 ce                	cmp    %ecx,%esi
 4ee:	74 1b                	je     50b <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4f0:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4f2:	a3 bc 08 00 00       	mov    %eax,0x8bc
}
 4f7:	5b                   	pop    %ebx
 4f8:	5e                   	pop    %esi
 4f9:	5f                   	pop    %edi
 4fa:	5d                   	pop    %ebp
 4fb:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4fc:	03 72 04             	add    0x4(%edx),%esi
 4ff:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 502:	8b 10                	mov    (%eax),%edx
 504:	8b 12                	mov    (%edx),%edx
 506:	89 53 f8             	mov    %edx,-0x8(%ebx)
 509:	eb db                	jmp    4e6 <free+0x3e>
    p->s.size += bp->s.size;
 50b:	03 53 fc             	add    -0x4(%ebx),%edx
 50e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 511:	8b 53 f8             	mov    -0x8(%ebx),%edx
 514:	89 10                	mov    %edx,(%eax)
 516:	eb da                	jmp    4f2 <free+0x4a>

00000518 <morecore>:

static Header*
morecore(uint nu)
{
 518:	55                   	push   %ebp
 519:	89 e5                	mov    %esp,%ebp
 51b:	53                   	push   %ebx
 51c:	83 ec 04             	sub    $0x4,%esp
 51f:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 521:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 526:	77 05                	ja     52d <morecore+0x15>
    nu = 4096;
 528:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 52d:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 534:	83 ec 0c             	sub    $0xc,%esp
 537:	50                   	push   %eax
 538:	e8 20 fd ff ff       	call   25d <sbrk>
  if(p == (char*)-1)
 53d:	83 c4 10             	add    $0x10,%esp
 540:	83 f8 ff             	cmp    $0xffffffff,%eax
 543:	74 1c                	je     561 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 545:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 548:	83 c0 08             	add    $0x8,%eax
 54b:	83 ec 0c             	sub    $0xc,%esp
 54e:	50                   	push   %eax
 54f:	e8 54 ff ff ff       	call   4a8 <free>
  return freep;
 554:	a1 bc 08 00 00       	mov    0x8bc,%eax
 559:	83 c4 10             	add    $0x10,%esp
}
 55c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 55f:	c9                   	leave  
 560:	c3                   	ret    
    return 0;
 561:	b8 00 00 00 00       	mov    $0x0,%eax
 566:	eb f4                	jmp    55c <morecore+0x44>

00000568 <malloc>:

void*
malloc(uint nbytes)
{
 568:	55                   	push   %ebp
 569:	89 e5                	mov    %esp,%ebp
 56b:	53                   	push   %ebx
 56c:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	8d 58 07             	lea    0x7(%eax),%ebx
 575:	c1 eb 03             	shr    $0x3,%ebx
 578:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 57b:	8b 0d bc 08 00 00    	mov    0x8bc,%ecx
 581:	85 c9                	test   %ecx,%ecx
 583:	74 04                	je     589 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 585:	8b 01                	mov    (%ecx),%eax
 587:	eb 4d                	jmp    5d6 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 589:	c7 05 bc 08 00 00 c0 	movl   $0x8c0,0x8bc
 590:	08 00 00 
 593:	c7 05 c0 08 00 00 c0 	movl   $0x8c0,0x8c0
 59a:	08 00 00 
    base.s.size = 0;
 59d:	c7 05 c4 08 00 00 00 	movl   $0x0,0x8c4
 5a4:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5a7:	b9 c0 08 00 00       	mov    $0x8c0,%ecx
 5ac:	eb d7                	jmp    585 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5ae:	39 da                	cmp    %ebx,%edx
 5b0:	74 1a                	je     5cc <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5b2:	29 da                	sub    %ebx,%edx
 5b4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5b7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5ba:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5bd:	89 0d bc 08 00 00    	mov    %ecx,0x8bc
      return (void*)(p + 1);
 5c3:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5c6:	83 c4 04             	add    $0x4,%esp
 5c9:	5b                   	pop    %ebx
 5ca:	5d                   	pop    %ebp
 5cb:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5cc:	8b 10                	mov    (%eax),%edx
 5ce:	89 11                	mov    %edx,(%ecx)
 5d0:	eb eb                	jmp    5bd <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5d2:	89 c1                	mov    %eax,%ecx
 5d4:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5d6:	8b 50 04             	mov    0x4(%eax),%edx
 5d9:	39 da                	cmp    %ebx,%edx
 5db:	73 d1                	jae    5ae <malloc+0x46>
    if(p == freep)
 5dd:	39 05 bc 08 00 00    	cmp    %eax,0x8bc
 5e3:	75 ed                	jne    5d2 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5e5:	89 d8                	mov    %ebx,%eax
 5e7:	e8 2c ff ff ff       	call   518 <morecore>
 5ec:	85 c0                	test   %eax,%eax
 5ee:	75 e2                	jne    5d2 <malloc+0x6a>
        return 0;
 5f0:	b8 00 00 00 00       	mov    $0x0,%eax
 5f5:	eb cf                	jmp    5c6 <malloc+0x5e>
