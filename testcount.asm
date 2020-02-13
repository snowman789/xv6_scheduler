
_testcount:     file format elf32-i386


Disassembly of section .text:

00000000 <lcg_parkmiller>:
static unsigned random_seed = 1;

//#define RANDOM_MAX ((1u << 31u) - 1u)
#define RANDOM_MAX  100000
unsigned lcg_parkmiller(unsigned *state)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	8b 4d 08             	mov    0x8(%ebp),%ecx
        Therefore:
          rem*G - div*(N%G) === state*G  (mod N)

        Add N if necessary so that the result is between 1 and N-1.
    */
    unsigned div = *state / (N / G);  /* max : 2,147,483,646 / 44,488 = 48,271 */
   7:	8b 19                	mov    (%ecx),%ebx
   9:	ba 91 13 8f bc       	mov    $0xbc8f1391,%edx
   e:	89 d8                	mov    %ebx,%eax
  10:	f7 e2                	mul    %edx
  12:	c1 ea 0f             	shr    $0xf,%edx
    unsigned rem = *state % (N / G);  /* max : 2,147,483,646 % 44,488 = 44,487 */
  15:	69 c2 c8 ad 00 00    	imul   $0xadc8,%edx,%eax
  1b:	29 c3                	sub    %eax,%ebx

    unsigned a = rem * G;        /* max : 44,487 * 48,271 = 2,147,431,977 */
  1d:	69 c3 8f bc 00 00    	imul   $0xbc8f,%ebx,%eax
    unsigned b = div * (N % G);  /* max : 48,271 * 3,399 = 164,073,129 */
  23:	69 d2 47 0d 00 00    	imul   $0xd47,%edx,%edx

    return *state = (a > b) ? (a - b) : (a + (N - b)) ;
  29:	39 d0                	cmp    %edx,%eax
  2b:	77 0c                	ja     39 <lcg_parkmiller+0x39>
  2d:	29 d0                	sub    %edx,%eax
  2f:	05 ff ff ff 7f       	add    $0x7fffffff,%eax
  34:	89 01                	mov    %eax,(%ecx)
}
  36:	5b                   	pop    %ebx
  37:	5d                   	pop    %ebp
  38:	c3                   	ret    
    return *state = (a > b) ? (a - b) : (a + (N - b)) ;
  39:	29 d0                	sub    %edx,%eax
  3b:	eb f7                	jmp    34 <lcg_parkmiller+0x34>

0000003d <next_random>:

unsigned next_random() {
  3d:	55                   	push   %ebp
  3e:	89 e5                	mov    %esp,%ebp
    return lcg_parkmiller(&random_seed);
  40:	68 ac 09 00 00       	push   $0x9ac
  45:	e8 b6 ff ff ff       	call   0 <lcg_parkmiller>
  4a:	89 c1                	mov    %eax,%ecx
  4c:	c1 e8 05             	shr    $0x5,%eax
  4f:	ba c5 5a 7c 0a       	mov    $0xa7c5ac5,%edx
  54:	f7 e2                	mul    %edx
  56:	89 d0                	mov    %edx,%eax
  58:	c1 e8 07             	shr    $0x7,%eax
  5b:	69 c0 a0 86 01 00    	imul   $0x186a0,%eax,%eax
  61:	29 c1                	sub    %eax,%ecx
  63:	89 c8                	mov    %ecx,%eax
}
  65:	c9                   	leave  
  66:	c3                   	ret    

00000067 <main>:
#include "user.h"
#include "random_num.c"

int
main(int argc, char *argv[])
{
  67:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	ff 71 fc             	pushl  -0x4(%ecx)
  71:	55                   	push   %ebp
  72:	89 e5                	mov    %esp,%ebp
  74:	53                   	push   %ebx
  75:	51                   	push   %ecx
  76:	81 ec 18 03 00 00    	sub    $0x318,%esp

    //test setwritecount works
    printf(1,"Testing Num times process run \n");
  7c:	68 88 06 00 00       	push   $0x688
  81:	6a 01                	push   $0x1
  83:	e8 46 03 00 00       	call   3ce <printf>
    // printf(1,"this is a test \n");
    // printf(1, "%d\n", writecount() );
    
  struct processes_info myInfo;
  struct processes_info *myProcess = &myInfo;
    getprocessesinfo(myProcess);
  88:	8d 9d f4 fc ff ff    	lea    -0x30c(%ebp),%ebx
  8e:	89 1c 24             	mov    %ebx,(%esp)
  91:	e8 96 02 00 00       	call   32c <getprocessesinfo>
    settickets(69);
  96:	c7 04 24 45 00 00 00 	movl   $0x45,(%esp)
  9d:	e8 82 02 00 00       	call   324 <settickets>
    getprocessesinfo(myProcess);
  a2:	89 1c 24             	mov    %ebx,(%esp)
  a5:	e8 82 02 00 00       	call   32c <getprocessesinfo>
  for(int i = 0; i < 10; i++){
  aa:	83 c4 10             	add    $0x10,%esp
  ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  b2:	eb 19                	jmp    cd <main+0x66>
    unsigned myRandom = next_random();
  b4:	e8 84 ff ff ff       	call   3d <next_random>
    //myRandom = 113;
    printf(1, "Random number %d is %d \n", i , (int) myRandom);
  b9:	50                   	push   %eax
  ba:	53                   	push   %ebx
  bb:	68 a8 06 00 00       	push   $0x6a8
  c0:	6a 01                	push   $0x1
  c2:	e8 07 03 00 00       	call   3ce <printf>
  for(int i = 0; i < 10; i++){
  c7:	83 c3 01             	add    $0x1,%ebx
  ca:	83 c4 10             	add    $0x10,%esp
  cd:	83 fb 09             	cmp    $0x9,%ebx
  d0:	7e e2                	jle    b4 <main+0x4d>
  }

  exit();
  d2:	e8 8d 01 00 00       	call   264 <exit>

000000d7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  d7:	55                   	push   %ebp
  d8:	89 e5                	mov    %esp,%ebp
  da:	53                   	push   %ebx
  db:	8b 45 08             	mov    0x8(%ebp),%eax
  de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e1:	89 c2                	mov    %eax,%edx
  e3:	0f b6 19             	movzbl (%ecx),%ebx
  e6:	88 1a                	mov    %bl,(%edx)
  e8:	8d 52 01             	lea    0x1(%edx),%edx
  eb:	8d 49 01             	lea    0x1(%ecx),%ecx
  ee:	84 db                	test   %bl,%bl
  f0:	75 f1                	jne    e3 <strcpy+0xc>
    ;
  return os;
}
  f2:	5b                   	pop    %ebx
  f3:	5d                   	pop    %ebp
  f4:	c3                   	ret    

000000f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f5:	55                   	push   %ebp
  f6:	89 e5                	mov    %esp,%ebp
  f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  fe:	eb 06                	jmp    106 <strcmp+0x11>
    p++, q++;
 100:	83 c1 01             	add    $0x1,%ecx
 103:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 106:	0f b6 01             	movzbl (%ecx),%eax
 109:	84 c0                	test   %al,%al
 10b:	74 04                	je     111 <strcmp+0x1c>
 10d:	3a 02                	cmp    (%edx),%al
 10f:	74 ef                	je     100 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 111:	0f b6 c0             	movzbl %al,%eax
 114:	0f b6 12             	movzbl (%edx),%edx
 117:	29 d0                	sub    %edx,%eax
}
 119:	5d                   	pop    %ebp
 11a:	c3                   	ret    

0000011b <strlen>:

uint
strlen(const char *s)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
 11e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 121:	ba 00 00 00 00       	mov    $0x0,%edx
 126:	eb 03                	jmp    12b <strlen+0x10>
 128:	83 c2 01             	add    $0x1,%edx
 12b:	89 d0                	mov    %edx,%eax
 12d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 131:	75 f5                	jne    128 <strlen+0xd>
    ;
  return n;
}
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <memset>:

void*
memset(void *dst, int c, uint n)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	57                   	push   %edi
 139:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 13c:	89 d7                	mov    %edx,%edi
 13e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 141:	8b 45 0c             	mov    0xc(%ebp),%eax
 144:	fc                   	cld    
 145:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 147:	89 d0                	mov    %edx,%eax
 149:	5f                   	pop    %edi
 14a:	5d                   	pop    %ebp
 14b:	c3                   	ret    

0000014c <strchr>:

char*
strchr(const char *s, char c)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 156:	0f b6 10             	movzbl (%eax),%edx
 159:	84 d2                	test   %dl,%dl
 15b:	74 09                	je     166 <strchr+0x1a>
    if(*s == c)
 15d:	38 ca                	cmp    %cl,%dl
 15f:	74 0a                	je     16b <strchr+0x1f>
  for(; *s; s++)
 161:	83 c0 01             	add    $0x1,%eax
 164:	eb f0                	jmp    156 <strchr+0xa>
      return (char*)s;
  return 0;
 166:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16b:	5d                   	pop    %ebp
 16c:	c3                   	ret    

0000016d <gets>:

char*
gets(char *buf, int max)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
 170:	57                   	push   %edi
 171:	56                   	push   %esi
 172:	53                   	push   %ebx
 173:	83 ec 1c             	sub    $0x1c,%esp
 176:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 179:	bb 00 00 00 00       	mov    $0x0,%ebx
 17e:	8d 73 01             	lea    0x1(%ebx),%esi
 181:	3b 75 0c             	cmp    0xc(%ebp),%esi
 184:	7d 2e                	jge    1b4 <gets+0x47>
    cc = read(0, &c, 1);
 186:	83 ec 04             	sub    $0x4,%esp
 189:	6a 01                	push   $0x1
 18b:	8d 45 e7             	lea    -0x19(%ebp),%eax
 18e:	50                   	push   %eax
 18f:	6a 00                	push   $0x0
 191:	e8 e6 00 00 00       	call   27c <read>
    if(cc < 1)
 196:	83 c4 10             	add    $0x10,%esp
 199:	85 c0                	test   %eax,%eax
 19b:	7e 17                	jle    1b4 <gets+0x47>
      break;
    buf[i++] = c;
 19d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a1:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1a4:	3c 0a                	cmp    $0xa,%al
 1a6:	0f 94 c2             	sete   %dl
 1a9:	3c 0d                	cmp    $0xd,%al
 1ab:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1ae:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1b0:	08 c2                	or     %al,%dl
 1b2:	74 ca                	je     17e <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1b4:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1b8:	89 f8                	mov    %edi,%eax
 1ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1bd:	5b                   	pop    %ebx
 1be:	5e                   	pop    %esi
 1bf:	5f                   	pop    %edi
 1c0:	5d                   	pop    %ebp
 1c1:	c3                   	ret    

000001c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	56                   	push   %esi
 1c6:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c7:	83 ec 08             	sub    $0x8,%esp
 1ca:	6a 00                	push   $0x0
 1cc:	ff 75 08             	pushl  0x8(%ebp)
 1cf:	e8 d0 00 00 00       	call   2a4 <open>
  if(fd < 0)
 1d4:	83 c4 10             	add    $0x10,%esp
 1d7:	85 c0                	test   %eax,%eax
 1d9:	78 24                	js     1ff <stat+0x3d>
 1db:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1dd:	83 ec 08             	sub    $0x8,%esp
 1e0:	ff 75 0c             	pushl  0xc(%ebp)
 1e3:	50                   	push   %eax
 1e4:	e8 d3 00 00 00       	call   2bc <fstat>
 1e9:	89 c6                	mov    %eax,%esi
  close(fd);
 1eb:	89 1c 24             	mov    %ebx,(%esp)
 1ee:	e8 99 00 00 00       	call   28c <close>
  return r;
 1f3:	83 c4 10             	add    $0x10,%esp
}
 1f6:	89 f0                	mov    %esi,%eax
 1f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1fb:	5b                   	pop    %ebx
 1fc:	5e                   	pop    %esi
 1fd:	5d                   	pop    %ebp
 1fe:	c3                   	ret    
    return -1;
 1ff:	be ff ff ff ff       	mov    $0xffffffff,%esi
 204:	eb f0                	jmp    1f6 <stat+0x34>

00000206 <atoi>:

int
atoi(const char *s)
{
 206:	55                   	push   %ebp
 207:	89 e5                	mov    %esp,%ebp
 209:	53                   	push   %ebx
 20a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 20d:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 212:	eb 10                	jmp    224 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 214:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 217:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 21a:	83 c1 01             	add    $0x1,%ecx
 21d:	0f be d2             	movsbl %dl,%edx
 220:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 224:	0f b6 11             	movzbl (%ecx),%edx
 227:	8d 5a d0             	lea    -0x30(%edx),%ebx
 22a:	80 fb 09             	cmp    $0x9,%bl
 22d:	76 e5                	jbe    214 <atoi+0xe>
  return n;
}
 22f:	5b                   	pop    %ebx
 230:	5d                   	pop    %ebp
 231:	c3                   	ret    

00000232 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 232:	55                   	push   %ebp
 233:	89 e5                	mov    %esp,%ebp
 235:	56                   	push   %esi
 236:	53                   	push   %ebx
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 23d:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 240:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 242:	eb 0d                	jmp    251 <memmove+0x1f>
    *dst++ = *src++;
 244:	0f b6 13             	movzbl (%ebx),%edx
 247:	88 11                	mov    %dl,(%ecx)
 249:	8d 5b 01             	lea    0x1(%ebx),%ebx
 24c:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 24f:	89 f2                	mov    %esi,%edx
 251:	8d 72 ff             	lea    -0x1(%edx),%esi
 254:	85 d2                	test   %edx,%edx
 256:	7f ec                	jg     244 <memmove+0x12>
  return vdst;
}
 258:	5b                   	pop    %ebx
 259:	5e                   	pop    %esi
 25a:	5d                   	pop    %ebp
 25b:	c3                   	ret    

0000025c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 25c:	b8 01 00 00 00       	mov    $0x1,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <exit>:
SYSCALL(exit)
 264:	b8 02 00 00 00       	mov    $0x2,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <wait>:
SYSCALL(wait)
 26c:	b8 03 00 00 00       	mov    $0x3,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <pipe>:
SYSCALL(pipe)
 274:	b8 04 00 00 00       	mov    $0x4,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <read>:
SYSCALL(read)
 27c:	b8 05 00 00 00       	mov    $0x5,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <write>:
SYSCALL(write)
 284:	b8 10 00 00 00       	mov    $0x10,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <close>:
SYSCALL(close)
 28c:	b8 15 00 00 00       	mov    $0x15,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <kill>:
SYSCALL(kill)
 294:	b8 06 00 00 00       	mov    $0x6,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <exec>:
SYSCALL(exec)
 29c:	b8 07 00 00 00       	mov    $0x7,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <open>:
SYSCALL(open)
 2a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <mknod>:
SYSCALL(mknod)
 2ac:	b8 11 00 00 00       	mov    $0x11,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <unlink>:
SYSCALL(unlink)
 2b4:	b8 12 00 00 00       	mov    $0x12,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <fstat>:
SYSCALL(fstat)
 2bc:	b8 08 00 00 00       	mov    $0x8,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <link>:
SYSCALL(link)
 2c4:	b8 13 00 00 00       	mov    $0x13,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <mkdir>:
SYSCALL(mkdir)
 2cc:	b8 14 00 00 00       	mov    $0x14,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <chdir>:
SYSCALL(chdir)
 2d4:	b8 09 00 00 00       	mov    $0x9,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <dup>:
SYSCALL(dup)
 2dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <getpid>:
SYSCALL(getpid)
 2e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <sbrk>:
SYSCALL(sbrk)
 2ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <sleep>:
SYSCALL(sleep)
 2f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <uptime>:
SYSCALL(uptime)
 2fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <yield>:
SYSCALL(yield)
 304:	b8 16 00 00 00       	mov    $0x16,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <shutdown>:
SYSCALL(shutdown)
 30c:	b8 17 00 00 00       	mov    $0x17,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <writecount>:
SYSCALL(writecount)
 314:	b8 18 00 00 00       	mov    $0x18,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <setwritecount>:
SYSCALL(setwritecount)
 31c:	b8 19 00 00 00       	mov    $0x19,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <settickets>:
SYSCALL(settickets)
 324:	b8 1a 00 00 00       	mov    $0x1a,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <getprocessesinfo>:
 32c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 334:	55                   	push   %ebp
 335:	89 e5                	mov    %esp,%ebp
 337:	83 ec 1c             	sub    $0x1c,%esp
 33a:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 33d:	6a 01                	push   $0x1
 33f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 342:	52                   	push   %edx
 343:	50                   	push   %eax
 344:	e8 3b ff ff ff       	call   284 <write>
}
 349:	83 c4 10             	add    $0x10,%esp
 34c:	c9                   	leave  
 34d:	c3                   	ret    

0000034e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	57                   	push   %edi
 352:	56                   	push   %esi
 353:	53                   	push   %ebx
 354:	83 ec 2c             	sub    $0x2c,%esp
 357:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 359:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 35d:	0f 95 c3             	setne  %bl
 360:	89 d0                	mov    %edx,%eax
 362:	c1 e8 1f             	shr    $0x1f,%eax
 365:	84 c3                	test   %al,%bl
 367:	74 10                	je     379 <printint+0x2b>
    neg = 1;
    x = -xx;
 369:	f7 da                	neg    %edx
    neg = 1;
 36b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 372:	be 00 00 00 00       	mov    $0x0,%esi
 377:	eb 0b                	jmp    384 <printint+0x36>
  neg = 0;
 379:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 380:	eb f0                	jmp    372 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 382:	89 c6                	mov    %eax,%esi
 384:	89 d0                	mov    %edx,%eax
 386:	ba 00 00 00 00       	mov    $0x0,%edx
 38b:	f7 f1                	div    %ecx
 38d:	89 c3                	mov    %eax,%ebx
 38f:	8d 46 01             	lea    0x1(%esi),%eax
 392:	0f b6 92 c8 06 00 00 	movzbl 0x6c8(%edx),%edx
 399:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 39d:	89 da                	mov    %ebx,%edx
 39f:	85 db                	test   %ebx,%ebx
 3a1:	75 df                	jne    382 <printint+0x34>
 3a3:	89 c3                	mov    %eax,%ebx
  if(neg)
 3a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3a9:	74 16                	je     3c1 <printint+0x73>
    buf[i++] = '-';
 3ab:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3b0:	8d 5e 02             	lea    0x2(%esi),%ebx
 3b3:	eb 0c                	jmp    3c1 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3b5:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3ba:	89 f8                	mov    %edi,%eax
 3bc:	e8 73 ff ff ff       	call   334 <putc>
  while(--i >= 0)
 3c1:	83 eb 01             	sub    $0x1,%ebx
 3c4:	79 ef                	jns    3b5 <printint+0x67>
}
 3c6:	83 c4 2c             	add    $0x2c,%esp
 3c9:	5b                   	pop    %ebx
 3ca:	5e                   	pop    %esi
 3cb:	5f                   	pop    %edi
 3cc:	5d                   	pop    %ebp
 3cd:	c3                   	ret    

000003ce <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3ce:	55                   	push   %ebp
 3cf:	89 e5                	mov    %esp,%ebp
 3d1:	57                   	push   %edi
 3d2:	56                   	push   %esi
 3d3:	53                   	push   %ebx
 3d4:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3d7:	8d 45 10             	lea    0x10(%ebp),%eax
 3da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3dd:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3e2:	bb 00 00 00 00       	mov    $0x0,%ebx
 3e7:	eb 14                	jmp    3fd <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3e9:	89 fa                	mov    %edi,%edx
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	e8 41 ff ff ff       	call   334 <putc>
 3f3:	eb 05                	jmp    3fa <printf+0x2c>
      }
    } else if(state == '%'){
 3f5:	83 fe 25             	cmp    $0x25,%esi
 3f8:	74 25                	je     41f <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3fa:	83 c3 01             	add    $0x1,%ebx
 3fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 400:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 404:	84 c0                	test   %al,%al
 406:	0f 84 23 01 00 00    	je     52f <printf+0x161>
    c = fmt[i] & 0xff;
 40c:	0f be f8             	movsbl %al,%edi
 40f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 412:	85 f6                	test   %esi,%esi
 414:	75 df                	jne    3f5 <printf+0x27>
      if(c == '%'){
 416:	83 f8 25             	cmp    $0x25,%eax
 419:	75 ce                	jne    3e9 <printf+0x1b>
        state = '%';
 41b:	89 c6                	mov    %eax,%esi
 41d:	eb db                	jmp    3fa <printf+0x2c>
      if(c == 'd'){
 41f:	83 f8 64             	cmp    $0x64,%eax
 422:	74 49                	je     46d <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 424:	83 f8 78             	cmp    $0x78,%eax
 427:	0f 94 c1             	sete   %cl
 42a:	83 f8 70             	cmp    $0x70,%eax
 42d:	0f 94 c2             	sete   %dl
 430:	08 d1                	or     %dl,%cl
 432:	75 63                	jne    497 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 434:	83 f8 73             	cmp    $0x73,%eax
 437:	0f 84 84 00 00 00    	je     4c1 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 43d:	83 f8 63             	cmp    $0x63,%eax
 440:	0f 84 b7 00 00 00    	je     4fd <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 446:	83 f8 25             	cmp    $0x25,%eax
 449:	0f 84 cc 00 00 00    	je     51b <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 44f:	ba 25 00 00 00       	mov    $0x25,%edx
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	e8 d8 fe ff ff       	call   334 <putc>
        putc(fd, c);
 45c:	89 fa                	mov    %edi,%edx
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	e8 ce fe ff ff       	call   334 <putc>
      }
      state = 0;
 466:	be 00 00 00 00       	mov    $0x0,%esi
 46b:	eb 8d                	jmp    3fa <printf+0x2c>
        printint(fd, *ap, 10, 1);
 46d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 470:	8b 17                	mov    (%edi),%edx
 472:	83 ec 0c             	sub    $0xc,%esp
 475:	6a 01                	push   $0x1
 477:	b9 0a 00 00 00       	mov    $0xa,%ecx
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
 47f:	e8 ca fe ff ff       	call   34e <printint>
        ap++;
 484:	83 c7 04             	add    $0x4,%edi
 487:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 48a:	83 c4 10             	add    $0x10,%esp
      state = 0;
 48d:	be 00 00 00 00       	mov    $0x0,%esi
 492:	e9 63 ff ff ff       	jmp    3fa <printf+0x2c>
        printint(fd, *ap, 16, 0);
 497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 49a:	8b 17                	mov    (%edi),%edx
 49c:	83 ec 0c             	sub    $0xc,%esp
 49f:	6a 00                	push   $0x0
 4a1:	b9 10 00 00 00       	mov    $0x10,%ecx
 4a6:	8b 45 08             	mov    0x8(%ebp),%eax
 4a9:	e8 a0 fe ff ff       	call   34e <printint>
        ap++;
 4ae:	83 c7 04             	add    $0x4,%edi
 4b1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4b4:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4b7:	be 00 00 00 00       	mov    $0x0,%esi
 4bc:	e9 39 ff ff ff       	jmp    3fa <printf+0x2c>
        s = (char*)*ap;
 4c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c4:	8b 30                	mov    (%eax),%esi
        ap++;
 4c6:	83 c0 04             	add    $0x4,%eax
 4c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4cc:	85 f6                	test   %esi,%esi
 4ce:	75 28                	jne    4f8 <printf+0x12a>
          s = "(null)";
 4d0:	be c1 06 00 00       	mov    $0x6c1,%esi
 4d5:	8b 7d 08             	mov    0x8(%ebp),%edi
 4d8:	eb 0d                	jmp    4e7 <printf+0x119>
          putc(fd, *s);
 4da:	0f be d2             	movsbl %dl,%edx
 4dd:	89 f8                	mov    %edi,%eax
 4df:	e8 50 fe ff ff       	call   334 <putc>
          s++;
 4e4:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4e7:	0f b6 16             	movzbl (%esi),%edx
 4ea:	84 d2                	test   %dl,%dl
 4ec:	75 ec                	jne    4da <printf+0x10c>
      state = 0;
 4ee:	be 00 00 00 00       	mov    $0x0,%esi
 4f3:	e9 02 ff ff ff       	jmp    3fa <printf+0x2c>
 4f8:	8b 7d 08             	mov    0x8(%ebp),%edi
 4fb:	eb ea                	jmp    4e7 <printf+0x119>
        putc(fd, *ap);
 4fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 500:	0f be 17             	movsbl (%edi),%edx
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	e8 29 fe ff ff       	call   334 <putc>
        ap++;
 50b:	83 c7 04             	add    $0x4,%edi
 50e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 511:	be 00 00 00 00       	mov    $0x0,%esi
 516:	e9 df fe ff ff       	jmp    3fa <printf+0x2c>
        putc(fd, c);
 51b:	89 fa                	mov    %edi,%edx
 51d:	8b 45 08             	mov    0x8(%ebp),%eax
 520:	e8 0f fe ff ff       	call   334 <putc>
      state = 0;
 525:	be 00 00 00 00       	mov    $0x0,%esi
 52a:	e9 cb fe ff ff       	jmp    3fa <printf+0x2c>
    }
  }
}
 52f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 532:	5b                   	pop    %ebx
 533:	5e                   	pop    %esi
 534:	5f                   	pop    %edi
 535:	5d                   	pop    %ebp
 536:	c3                   	ret    

00000537 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 537:	55                   	push   %ebp
 538:	89 e5                	mov    %esp,%ebp
 53a:	57                   	push   %edi
 53b:	56                   	push   %esi
 53c:	53                   	push   %ebx
 53d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 540:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 543:	a1 b0 09 00 00       	mov    0x9b0,%eax
 548:	eb 02                	jmp    54c <free+0x15>
 54a:	89 d0                	mov    %edx,%eax
 54c:	39 c8                	cmp    %ecx,%eax
 54e:	73 04                	jae    554 <free+0x1d>
 550:	39 08                	cmp    %ecx,(%eax)
 552:	77 12                	ja     566 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 554:	8b 10                	mov    (%eax),%edx
 556:	39 c2                	cmp    %eax,%edx
 558:	77 f0                	ja     54a <free+0x13>
 55a:	39 c8                	cmp    %ecx,%eax
 55c:	72 08                	jb     566 <free+0x2f>
 55e:	39 ca                	cmp    %ecx,%edx
 560:	77 04                	ja     566 <free+0x2f>
 562:	89 d0                	mov    %edx,%eax
 564:	eb e6                	jmp    54c <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 566:	8b 73 fc             	mov    -0x4(%ebx),%esi
 569:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 56c:	8b 10                	mov    (%eax),%edx
 56e:	39 d7                	cmp    %edx,%edi
 570:	74 19                	je     58b <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 572:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 575:	8b 50 04             	mov    0x4(%eax),%edx
 578:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 57b:	39 ce                	cmp    %ecx,%esi
 57d:	74 1b                	je     59a <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 57f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 581:	a3 b0 09 00 00       	mov    %eax,0x9b0
}
 586:	5b                   	pop    %ebx
 587:	5e                   	pop    %esi
 588:	5f                   	pop    %edi
 589:	5d                   	pop    %ebp
 58a:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 58b:	03 72 04             	add    0x4(%edx),%esi
 58e:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 591:	8b 10                	mov    (%eax),%edx
 593:	8b 12                	mov    (%edx),%edx
 595:	89 53 f8             	mov    %edx,-0x8(%ebx)
 598:	eb db                	jmp    575 <free+0x3e>
    p->s.size += bp->s.size;
 59a:	03 53 fc             	add    -0x4(%ebx),%edx
 59d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5a0:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5a3:	89 10                	mov    %edx,(%eax)
 5a5:	eb da                	jmp    581 <free+0x4a>

000005a7 <morecore>:

static Header*
morecore(uint nu)
{
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	53                   	push   %ebx
 5ab:	83 ec 04             	sub    $0x4,%esp
 5ae:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5b0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5b5:	77 05                	ja     5bc <morecore+0x15>
    nu = 4096;
 5b7:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5bc:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5c3:	83 ec 0c             	sub    $0xc,%esp
 5c6:	50                   	push   %eax
 5c7:	e8 20 fd ff ff       	call   2ec <sbrk>
  if(p == (char*)-1)
 5cc:	83 c4 10             	add    $0x10,%esp
 5cf:	83 f8 ff             	cmp    $0xffffffff,%eax
 5d2:	74 1c                	je     5f0 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5d4:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5d7:	83 c0 08             	add    $0x8,%eax
 5da:	83 ec 0c             	sub    $0xc,%esp
 5dd:	50                   	push   %eax
 5de:	e8 54 ff ff ff       	call   537 <free>
  return freep;
 5e3:	a1 b0 09 00 00       	mov    0x9b0,%eax
 5e8:	83 c4 10             	add    $0x10,%esp
}
 5eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5ee:	c9                   	leave  
 5ef:	c3                   	ret    
    return 0;
 5f0:	b8 00 00 00 00       	mov    $0x0,%eax
 5f5:	eb f4                	jmp    5eb <morecore+0x44>

000005f7 <malloc>:

void*
malloc(uint nbytes)
{
 5f7:	55                   	push   %ebp
 5f8:	89 e5                	mov    %esp,%ebp
 5fa:	53                   	push   %ebx
 5fb:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5fe:	8b 45 08             	mov    0x8(%ebp),%eax
 601:	8d 58 07             	lea    0x7(%eax),%ebx
 604:	c1 eb 03             	shr    $0x3,%ebx
 607:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 60a:	8b 0d b0 09 00 00    	mov    0x9b0,%ecx
 610:	85 c9                	test   %ecx,%ecx
 612:	74 04                	je     618 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 614:	8b 01                	mov    (%ecx),%eax
 616:	eb 4d                	jmp    665 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 618:	c7 05 b0 09 00 00 b4 	movl   $0x9b4,0x9b0
 61f:	09 00 00 
 622:	c7 05 b4 09 00 00 b4 	movl   $0x9b4,0x9b4
 629:	09 00 00 
    base.s.size = 0;
 62c:	c7 05 b8 09 00 00 00 	movl   $0x0,0x9b8
 633:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 636:	b9 b4 09 00 00       	mov    $0x9b4,%ecx
 63b:	eb d7                	jmp    614 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 63d:	39 da                	cmp    %ebx,%edx
 63f:	74 1a                	je     65b <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 641:	29 da                	sub    %ebx,%edx
 643:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 646:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 649:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 64c:	89 0d b0 09 00 00    	mov    %ecx,0x9b0
      return (void*)(p + 1);
 652:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 655:	83 c4 04             	add    $0x4,%esp
 658:	5b                   	pop    %ebx
 659:	5d                   	pop    %ebp
 65a:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 65b:	8b 10                	mov    (%eax),%edx
 65d:	89 11                	mov    %edx,(%ecx)
 65f:	eb eb                	jmp    64c <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 661:	89 c1                	mov    %eax,%ecx
 663:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 665:	8b 50 04             	mov    0x4(%eax),%edx
 668:	39 da                	cmp    %ebx,%edx
 66a:	73 d1                	jae    63d <malloc+0x46>
    if(p == freep)
 66c:	39 05 b0 09 00 00    	cmp    %eax,0x9b0
 672:	75 ed                	jne    661 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 674:	89 d8                	mov    %ebx,%eax
 676:	e8 2c ff ff ff       	call   5a7 <morecore>
 67b:	85 c0                	test   %eax,%eax
 67d:	75 e2                	jne    661 <malloc+0x6a>
        return 0;
 67f:	b8 00 00 00 00       	mov    $0x0,%eax
 684:	eb cf                	jmp    655 <malloc+0x5e>
