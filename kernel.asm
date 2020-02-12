
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 a1 2a 10 80       	mov    $0x80102aa1,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 c0 b5 10 80       	push   $0x8010b5c0
80100046:	e8 d7 3b 00 00       	call   80103c22 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 c0 b5 10 80       	push   $0x8010b5c0
8010007c:	e8 06 3c 00 00       	call   80103c87 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 82 39 00 00       	call   80103a0e <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 c0 b5 10 80       	push   $0x8010b5c0
801000ca:	e8 b8 3b 00 00       	call   80103c87 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 34 39 00 00       	call   80103a0e <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 00 67 10 80       	push   $0x80106700
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 11 67 10 80       	push   $0x80106711
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 dc 39 00 00       	call   80103ae6 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100111:	fc 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
8010011b:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 18 67 10 80       	push   $0x80106718
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 93 38 00 00       	call   801039db <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 65 1c 00 00       	call   80101dfa <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 eb 38 00 00       	call   80103a98 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 3a 1c 00 00       	call   80101dfa <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 1f 67 10 80       	push   $0x8010671f
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 af 38 00 00       	call   80103a98 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 64 38 00 00       	call   80103a5d <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 1d 3a 00 00       	call   80103c22 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 c0 b5 10 80       	push   $0x8010b5c0
8010024c:	e8 36 3a 00 00       	call   80103c87 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 26 67 10 80       	push   $0x80106726
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 b1 13 00 00       	call   80101631 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028a:	e8 93 39 00 00       	call   80103c22 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 ab 2f 00 00       	call   80103257 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 10 80       	push   $0x8010a520
801002ba:	68 a0 ff 10 80       	push   $0x8010ffa0
801002bf:	e8 5b 34 00 00       	call   8010371f <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 b1 39 00 00       	call   80103c87 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 91 12 00 00       	call   8010156f <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 a0 ff 10 80    	mov    %edx,0x8010ffa0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 20 ff 10 80 	movzbl -0x7fef00e0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 10 80       	push   $0x8010a520
80100331:	e8 51 39 00 00       	call   80103c87 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 31 12 00 00       	call   8010156f <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 43 20 00 00       	call   801023a2 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 2d 67 10 80       	push   $0x8010672d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 4f 71 10 80 	movl   $0x8010714f,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 6d 37 00 00       	call   80103b01 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 41 67 10 80       	push   $0x80106741
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 45 67 10 80       	push   $0x80106745
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 8a 38 00 00       	call   80103d49 <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 f0 37 00 00       	call   80103cce <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 cc 4c 00 00       	call   801051d7 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 b3 4c 00 00       	call   801051d7 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 a7 4c 00 00       	call   801051d7 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 9b 4c 00 00       	call   801051d7 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 70 67 10 80 	movzbl -0x7fef9890(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 6e 10 00 00       	call   80101631 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ca:	e8 53 36 00 00       	call   80103c22 <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 a5 10 80       	push   $0x8010a520
801005f1:	e8 91 36 00 00       	call   80103c87 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 6e 0f 00 00       	call   8010156f <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 a5 10 80       	mov    0x8010a554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 a5 10 80       	push   $0x8010a520
80100638:	e8 e5 35 00 00       	call   80103c22 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 5f 67 10 80       	push   $0x8010675f
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be 58 67 10 80       	mov    $0x80106758,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 a5 10 80       	push   $0x8010a520
80100734:	e8 4e 35 00 00       	call   80103c87 <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 ce 34 00 00       	call   80103c22 <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 a8 ff 10 80    	mov    %edx,0x8010ffa8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 20 ff 10 80    	mov    %cl,-0x7fef00e0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 a8 ff 10 80    	cmp    %eax,0x8010ffa8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007d1:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 a0 ff 10 80       	push   $0x8010ffa0
801007de:	e8 a4 30 00 00       	call   80103887 <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007fc:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010084f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 10 80       	push   $0x8010a520
80100873:	e8 0f 34 00 00       	call   80103c87 <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 9a 30 00 00       	call   80103926 <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 68 67 10 80       	push   $0x80106768
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 43 32 00 00       	call   80103ae6 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 6c 09 11 80 ac 	movl   $0x801005ac,0x8011096c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 68 09 11 80 68 	movl   $0x80100268,0x80110968
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 9f 16 00 00       	call   80101f6c <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 74 29 00 00       	call   80103257 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 e4 1e 00 00       	call   801027d2 <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 d6 12 00 00       	call   80101bcf <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 64 0c 00 00       	call   8010156f <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 45 0e 00 00       	call   80101761 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 dd 02 00 00    	je     80100c09 <exec+0x337>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 e1 0d 00 00       	call   80101716 <iunlockput>
    end_op();
80100935:	e8 12 1f 00 00       	call   8010284c <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 fd 1e 00 00       	call   8010284c <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 81 67 10 80       	push   $0x80106781
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 dd 5a 00 00       	call   80106454 <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 06 01 00 00    	je     80100a8b <exec+0x1b9>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 98 00 00 00    	jle    80100a4a <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 99 0d 00 00       	call   80101761 <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 b7 00 00 00    	jne    80100a8b <exec+0x1b9>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 9c 00 00 00    	jb     80100a8b <exec+0x1b9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 90 00 00 00    	jb     80100a8b <exec+0x1b9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009fb:	83 ec 04             	sub    $0x4,%esp
801009fe:	50                   	push   %eax
801009ff:	57                   	push   %edi
80100a00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a06:	e8 c3 58 00 00       	call   801062ce <allocuvm>
80100a0b:	89 c7                	mov    %eax,%edi
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	85 c0                	test   %eax,%eax
80100a12:	74 77                	je     80100a8b <exec+0x1b9>
    if(ph.vaddr % PGSIZE != 0)
80100a14:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a1a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1f:	75 6a                	jne    80100a8b <exec+0x1b9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a21:	83 ec 0c             	sub    $0xc,%esp
80100a24:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a2a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a30:	53                   	push   %ebx
80100a31:	50                   	push   %eax
80100a32:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a38:	e8 37 57 00 00       	call   80106174 <loaduvm>
80100a3d:	83 c4 20             	add    $0x20,%esp
80100a40:	85 c0                	test   %eax,%eax
80100a42:	0f 89 4f ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a48:	eb 41                	jmp    80100a8b <exec+0x1b9>
  iunlockput(ip);
80100a4a:	83 ec 0c             	sub    $0xc,%esp
80100a4d:	53                   	push   %ebx
80100a4e:	e8 c3 0c 00 00       	call   80101716 <iunlockput>
  end_op();
80100a53:	e8 f4 1d 00 00       	call   8010284c <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 55 58 00 00       	call   801062ce <allocuvm>
80100a79:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a7f:	83 c4 10             	add    $0x10,%esp
80100a82:	85 c0                	test   %eax,%eax
80100a84:	75 24                	jne    80100aaa <exec+0x1d8>
  ip = 0;
80100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a91:	85 c0                	test   %eax,%eax
80100a93:	0f 84 8b fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100a99:	83 ec 0c             	sub    $0xc,%esp
80100a9c:	50                   	push   %eax
80100a9d:	e8 2e 59 00 00       	call   801063d0 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 18 5a 00 00       	call   801064d9 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	83 c4 10             	add    $0x10,%esp
80100ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100acc:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100acf:	8b 06                	mov    (%esi),%eax
80100ad1:	85 c0                	test   %eax,%eax
80100ad3:	74 4d                	je     80100b22 <exec+0x250>
    if(argc >= MAXARG)
80100ad5:	83 fb 1f             	cmp    $0x1f,%ebx
80100ad8:	0f 87 0d 01 00 00    	ja     80100beb <exec+0x319>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 89 33 00 00       	call   80103e70 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 77 33 00 00       	call   80103e70 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 5e 5b 00 00       	call   80106669 <copyout>
80100b0b:	83 c4 20             	add    $0x20,%esp
80100b0e:	85 c0                	test   %eax,%eax
80100b10:	0f 88 df 00 00 00    	js     80100bf5 <exec+0x323>
    ustack[3+argc] = sp;
80100b16:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b1d:	83 c3 01             	add    $0x1,%ebx
80100b20:	eb a7                	jmp    80100ac9 <exec+0x1f7>
  ustack[3+argc] = 0;
80100b22:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b29:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2d:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b34:	ff ff ff 
  ustack[1] = argc;
80100b37:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b44:	89 f9                	mov    %edi,%ecx
80100b46:	29 c1                	sub    %eax,%ecx
80100b48:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b4e:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b55:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b57:	50                   	push   %eax
80100b58:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b5e:	50                   	push   %eax
80100b5f:	57                   	push   %edi
80100b60:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b66:	e8 fe 5a 00 00       	call   80106669 <copyout>
80100b6b:	83 c4 10             	add    $0x10,%esp
80100b6e:	85 c0                	test   %eax,%eax
80100b70:	0f 88 89 00 00 00    	js     80100bff <exec+0x32d>
  for(last=s=path; *s; s++)
80100b76:	8b 55 08             	mov    0x8(%ebp),%edx
80100b79:	89 d0                	mov    %edx,%eax
80100b7b:	eb 03                	jmp    80100b80 <exec+0x2ae>
80100b7d:	83 c0 01             	add    $0x1,%eax
80100b80:	0f b6 08             	movzbl (%eax),%ecx
80100b83:	84 c9                	test   %cl,%cl
80100b85:	74 0a                	je     80100b91 <exec+0x2bf>
    if(*s == '/')
80100b87:	80 f9 2f             	cmp    $0x2f,%cl
80100b8a:	75 f1                	jne    80100b7d <exec+0x2ab>
      last = s+1;
80100b8c:	8d 50 01             	lea    0x1(%eax),%edx
80100b8f:	eb ec                	jmp    80100b7d <exec+0x2ab>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b91:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100b97:	89 f0                	mov    %esi,%eax
80100b99:	83 c0 6c             	add    $0x6c,%eax
80100b9c:	83 ec 04             	sub    $0x4,%esp
80100b9f:	6a 10                	push   $0x10
80100ba1:	52                   	push   %edx
80100ba2:	50                   	push   %eax
80100ba3:	e8 8d 32 00 00       	call   80103e35 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bab:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bb1:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bb4:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bba:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bbc:	8b 46 18             	mov    0x18(%esi),%eax
80100bbf:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bce:	89 34 24             	mov    %esi,(%esp)
80100bd1:	e8 f1 53 00 00       	call   80105fc7 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 f2 57 00 00       	call   801063d0 <freevm>
  return 0;
80100bde:	83 c4 10             	add    $0x10,%esp
80100be1:	b8 00 00 00 00       	mov    $0x0,%eax
80100be6:	e9 57 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf0:	e9 96 fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfa:	e9 8c fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 82 fe ff ff       	jmp    80100a8b <exec+0x1b9>
  return -1;
80100c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0e:	e9 2f fd ff ff       	jmp    80100942 <exec+0x70>

80100c13 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c19:	68 8d 67 10 80       	push   $0x8010678d
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 be 2e 00 00       	call   80103ae6 <initlock>
}
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	c9                   	leave  
80100c2c:	c3                   	ret    

80100c2d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c2d:	55                   	push   %ebp
80100c2e:	89 e5                	mov    %esp,%ebp
80100c30:	53                   	push   %ebx
80100c31:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c34:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c39:	e8 e4 2f 00 00       	call   80103c22 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
80100c46:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100c4c:	73 29                	jae    80100c77 <filealloc+0x4a>
    if(f->ref == 0){
80100c4e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c52:	74 05                	je     80100c59 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c54:	83 c3 18             	add    $0x18,%ebx
80100c57:	eb ed                	jmp    80100c46 <filealloc+0x19>
      f->ref = 1;
80100c59:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c60:	83 ec 0c             	sub    $0xc,%esp
80100c63:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c68:	e8 1a 30 00 00       	call   80103c87 <release>
      return f;
80100c6d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c70:	89 d8                	mov    %ebx,%eax
80100c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c75:	c9                   	leave  
80100c76:	c3                   	ret    
  release(&ftable.lock);
80100c77:	83 ec 0c             	sub    $0xc,%esp
80100c7a:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c7f:	e8 03 30 00 00       	call   80103c87 <release>
  return 0;
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c8c:	eb e2                	jmp    80100c70 <filealloc+0x43>

80100c8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	53                   	push   %ebx
80100c92:	83 ec 10             	sub    $0x10,%esp
80100c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c98:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c9d:	e8 80 2f 00 00       	call   80103c22 <acquire>
  if(f->ref < 1)
80100ca2:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca5:	83 c4 10             	add    $0x10,%esp
80100ca8:	85 c0                	test   %eax,%eax
80100caa:	7e 1a                	jle    80100cc6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cac:	83 c0 01             	add    $0x1,%eax
80100caf:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cb2:	83 ec 0c             	sub    $0xc,%esp
80100cb5:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cba:	e8 c8 2f 00 00       	call   80103c87 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 94 67 10 80       	push   $0x80106794
80100cce:	e8 75 f6 ff ff       	call   80100348 <panic>

80100cd3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cd3:	55                   	push   %ebp
80100cd4:	89 e5                	mov    %esp,%ebp
80100cd6:	53                   	push   %ebx
80100cd7:	83 ec 30             	sub    $0x30,%esp
80100cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cdd:	68 c0 ff 10 80       	push   $0x8010ffc0
80100ce2:	e8 3b 2f 00 00       	call   80103c22 <acquire>
  if(f->ref < 1)
80100ce7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cea:	83 c4 10             	add    $0x10,%esp
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 1f                	jle    80100d10 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cf1:	83 e8 01             	sub    $0x1,%eax
80100cf4:	89 43 04             	mov    %eax,0x4(%ebx)
80100cf7:	85 c0                	test   %eax,%eax
80100cf9:	7e 22                	jle    80100d1d <fileclose+0x4a>
    release(&ftable.lock);
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d03:	e8 7f 2f 00 00       	call   80103c87 <release>
    return;
80100d08:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d0e:	c9                   	leave  
80100d0f:	c3                   	ret    
    panic("fileclose");
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 9c 67 10 80       	push   $0x8010679c
80100d18:	e8 2b f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d1d:	8b 03                	mov    (%ebx),%eax
80100d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d22:	8b 43 08             	mov    0x8(%ebx),%eax
80100d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d28:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d2e:	8b 43 10             	mov    0x10(%ebx),%eax
80100d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d34:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d49:	e8 39 2f 00 00       	call   80103c87 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 6f 1a 00 00       	call   801027d2 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 08 09 00 00       	call   80101676 <iput>
    end_op();
80100d6e:	e8 d9 1a 00 00       	call   8010284c <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 f5 20 00 00       	call   80102e7d <pipeclose>
80100d88:	83 c4 10             	add    $0x10,%esp
80100d8b:	e9 7b ff ff ff       	jmp    80100d0b <fileclose+0x38>

80100d90 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d90:	55                   	push   %ebp
80100d91:	89 e5                	mov    %esp,%ebp
80100d93:	53                   	push   %ebx
80100d94:	83 ec 04             	sub    $0x4,%esp
80100d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d9a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d9d:	75 31                	jne    80100dd0 <filestat+0x40>
    ilock(f->ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 73 10             	pushl  0x10(%ebx)
80100da5:	e8 c5 07 00 00       	call   8010156f <ilock>
    stati(f->ip, st);
80100daa:	83 c4 08             	add    $0x8,%esp
80100dad:	ff 75 0c             	pushl  0xc(%ebp)
80100db0:	ff 73 10             	pushl  0x10(%ebx)
80100db3:	e8 7e 09 00 00       	call   80101736 <stati>
    iunlock(f->ip);
80100db8:	83 c4 04             	add    $0x4,%esp
80100dbb:	ff 73 10             	pushl  0x10(%ebx)
80100dbe:	e8 6e 08 00 00       	call   80101631 <iunlock>
    return 0;
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dce:	c9                   	leave  
80100dcf:	c3                   	ret    
  return -1;
80100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dd5:	eb f4                	jmp    80100dcb <filestat+0x3b>

80100dd7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd7:	55                   	push   %ebp
80100dd8:	89 e5                	mov    %esp,%ebp
80100dda:	56                   	push   %esi
80100ddb:	53                   	push   %ebx
80100ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100ddf:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100de3:	74 70                	je     80100e55 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100de5:	8b 03                	mov    (%ebx),%eax
80100de7:	83 f8 01             	cmp    $0x1,%eax
80100dea:	74 44                	je     80100e30 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100dec:	83 f8 02             	cmp    $0x2,%eax
80100def:	75 57                	jne    80100e48 <fileread+0x71>
    ilock(f->ip);
80100df1:	83 ec 0c             	sub    $0xc,%esp
80100df4:	ff 73 10             	pushl  0x10(%ebx)
80100df7:	e8 73 07 00 00       	call   8010156f <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dfc:	ff 75 10             	pushl  0x10(%ebp)
80100dff:	ff 73 14             	pushl  0x14(%ebx)
80100e02:	ff 75 0c             	pushl  0xc(%ebp)
80100e05:	ff 73 10             	pushl  0x10(%ebx)
80100e08:	e8 54 09 00 00       	call   80101761 <readi>
80100e0d:	89 c6                	mov    %eax,%esi
80100e0f:	83 c4 20             	add    $0x20,%esp
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7e 03                	jle    80100e19 <fileread+0x42>
      f->off += r;
80100e16:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 73 10             	pushl  0x10(%ebx)
80100e1f:	e8 0d 08 00 00       	call   80101631 <iunlock>
    return r;
80100e24:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e27:	89 f0                	mov    %esi,%eax
80100e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e2c:	5b                   	pop    %ebx
80100e2d:	5e                   	pop    %esi
80100e2e:	5d                   	pop    %ebp
80100e2f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e30:	83 ec 04             	sub    $0x4,%esp
80100e33:	ff 75 10             	pushl  0x10(%ebp)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 0c             	pushl  0xc(%ebx)
80100e3c:	e8 94 21 00 00       	call   80102fd5 <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 a6 67 10 80       	push   $0x801067a6
80100e50:	e8 f3 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e55:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e5a:	eb cb                	jmp    80100e27 <fileread+0x50>

80100e5c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	57                   	push   %edi
80100e60:	56                   	push   %esi
80100e61:	53                   	push   %ebx
80100e62:	83 ec 1c             	sub    $0x1c,%esp
80100e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e6c:	0f 84 c5 00 00 00    	je     80100f37 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e72:	8b 03                	mov    (%ebx),%eax
80100e74:	83 f8 01             	cmp    $0x1,%eax
80100e77:	74 10                	je     80100e89 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e79:	83 f8 02             	cmp    $0x2,%eax
80100e7c:	0f 85 a8 00 00 00    	jne    80100f2a <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e82:	bf 00 00 00 00       	mov    $0x0,%edi
80100e87:	eb 67                	jmp    80100ef0 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e89:	83 ec 04             	sub    $0x4,%esp
80100e8c:	ff 75 10             	pushl  0x10(%ebp)
80100e8f:	ff 75 0c             	pushl  0xc(%ebp)
80100e92:	ff 73 0c             	pushl  0xc(%ebx)
80100e95:	e8 6f 20 00 00       	call   80102f09 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 2b 19 00 00       	call   801027d2 <begin_op>
      ilock(f->ip);
80100ea7:	83 ec 0c             	sub    $0xc,%esp
80100eaa:	ff 73 10             	pushl  0x10(%ebx)
80100ead:	e8 bd 06 00 00       	call   8010156f <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100eb2:	89 f8                	mov    %edi,%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eba:	ff 73 14             	pushl  0x14(%ebx)
80100ebd:	50                   	push   %eax
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 98 09 00 00       	call   8010185e <writei>
80100ec6:	89 c6                	mov    %eax,%esi
80100ec8:	83 c4 20             	add    $0x20,%esp
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	7e 03                	jle    80100ed2 <filewrite+0x76>
        f->off += r;
80100ecf:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ed2:	83 ec 0c             	sub    $0xc,%esp
80100ed5:	ff 73 10             	pushl  0x10(%ebx)
80100ed8:	e8 54 07 00 00       	call   80101631 <iunlock>
      end_op();
80100edd:	e8 6a 19 00 00       	call   8010284c <end_op>

      if(r < 0)
80100ee2:	83 c4 10             	add    $0x10,%esp
80100ee5:	85 f6                	test   %esi,%esi
80100ee7:	78 31                	js     80100f1a <filewrite+0xbe>
        break;
      if(r != n1)
80100ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100eec:	75 1f                	jne    80100f0d <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eee:	01 f7                	add    %esi,%edi
    while(i < n){
80100ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ef3:	7d 25                	jge    80100f1a <filewrite+0xbe>
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 9e                	jle    80100ea2 <filewrite+0x46>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f0b:	eb 95                	jmp    80100ea2 <filewrite+0x46>
        panic("short filewrite");
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	68 af 67 10 80       	push   $0x801067af
80100f15:	e8 2e f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f1d:	75 1f                	jne    80100f3e <filewrite+0xe2>
80100f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f25:	5b                   	pop    %ebx
80100f26:	5e                   	pop    %esi
80100f27:	5f                   	pop    %edi
80100f28:	5d                   	pop    %ebp
80100f29:	c3                   	ret    
  panic("filewrite");
80100f2a:	83 ec 0c             	sub    $0xc,%esp
80100f2d:	68 b5 67 10 80       	push   $0x801067b5
80100f32:	e8 11 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3c:	eb e4                	jmp    80100f22 <filewrite+0xc6>
    return i == n ? n : -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f43:	eb dd                	jmp    80100f22 <filewrite+0xc6>

80100f45 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	57                   	push   %edi
80100f49:	56                   	push   %esi
80100f4a:	53                   	push   %ebx
80100f4b:	83 ec 0c             	sub    $0xc,%esp
80100f4e:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f50:	eb 03                	jmp    80100f55 <skipelem+0x10>
    path++;
80100f52:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f55:	0f b6 10             	movzbl (%eax),%edx
80100f58:	80 fa 2f             	cmp    $0x2f,%dl
80100f5b:	74 f5                	je     80100f52 <skipelem+0xd>
  if(*path == 0)
80100f5d:	84 d2                	test   %dl,%dl
80100f5f:	74 59                	je     80100fba <skipelem+0x75>
80100f61:	89 c3                	mov    %eax,%ebx
80100f63:	eb 03                	jmp    80100f68 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f65:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f68:	0f b6 13             	movzbl (%ebx),%edx
80100f6b:	80 fa 2f             	cmp    $0x2f,%dl
80100f6e:	0f 95 c1             	setne  %cl
80100f71:	84 d2                	test   %dl,%dl
80100f73:	0f 95 c2             	setne  %dl
80100f76:	84 d1                	test   %dl,%cl
80100f78:	75 eb                	jne    80100f65 <skipelem+0x20>
  len = path - s;
80100f7a:	89 de                	mov    %ebx,%esi
80100f7c:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f7e:	83 fe 0d             	cmp    $0xd,%esi
80100f81:	7e 11                	jle    80100f94 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f83:	83 ec 04             	sub    $0x4,%esp
80100f86:	6a 0e                	push   $0xe
80100f88:	50                   	push   %eax
80100f89:	57                   	push   %edi
80100f8a:	e8 ba 2d 00 00       	call   80103d49 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 aa 2d 00 00       	call   80103d49 <memmove>
    name[len] = 0;
80100f9f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 03                	jmp    80100fab <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fa8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fab:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fae:	74 f8                	je     80100fa8 <skipelem+0x63>
  return path;
}
80100fb0:	89 d8                	mov    %ebx,%eax
80100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb5:	5b                   	pop    %ebx
80100fb6:	5e                   	pop    %esi
80100fb7:	5f                   	pop    %edi
80100fb8:	5d                   	pop    %ebp
80100fb9:	c3                   	ret    
    return 0;
80100fba:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fbf:	eb ef                	jmp    80100fb0 <skipelem+0x6b>

80100fc1 <bzero>:
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	53                   	push   %ebx
80100fc5:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fc8:	52                   	push   %edx
80100fc9:	50                   	push   %eax
80100fca:	e8 9d f1 ff ff       	call   8010016c <bread>
80100fcf:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fd1:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fd4:	83 c4 0c             	add    $0xc,%esp
80100fd7:	68 00 02 00 00       	push   $0x200
80100fdc:	6a 00                	push   $0x0
80100fde:	50                   	push   %eax
80100fdf:	e8 ea 2c 00 00       	call   80103cce <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 0f 19 00 00       	call   801028fb <log_write>
  brelse(bp);
80100fec:	89 1c 24             	mov    %ebx,(%esp)
80100fef:	e8 e1 f1 ff ff       	call   801001d5 <brelse>
}
80100ff4:	83 c4 10             	add    $0x10,%esp
80100ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <bfree>:
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	56                   	push   %esi
80101000:	53                   	push   %ebx
80101001:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
80101003:	c1 ea 0c             	shr    $0xc,%edx
80101006:	03 15 d8 09 11 80    	add    0x801109d8,%edx
8010100c:	83 ec 08             	sub    $0x8,%esp
8010100f:	52                   	push   %edx
80101010:	50                   	push   %eax
80101011:	e8 56 f1 ff ff       	call   8010016c <bread>
80101016:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101018:	89 d9                	mov    %ebx,%ecx
8010101a:	83 e1 07             	and    $0x7,%ecx
8010101d:	b8 01 00 00 00       	mov    $0x1,%eax
80101022:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101024:	83 c4 10             	add    $0x10,%esp
80101027:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
8010102d:	c1 fb 03             	sar    $0x3,%ebx
80101030:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
80101035:	0f b6 ca             	movzbl %dl,%ecx
80101038:	85 c1                	test   %eax,%ecx
8010103a:	74 23                	je     8010105f <bfree+0x63>
  bp->data[bi/8] &= ~m;
8010103c:	f7 d0                	not    %eax
8010103e:	21 d0                	and    %edx,%eax
80101040:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
80101044:	83 ec 0c             	sub    $0xc,%esp
80101047:	56                   	push   %esi
80101048:	e8 ae 18 00 00       	call   801028fb <log_write>
  brelse(bp);
8010104d:	89 34 24             	mov    %esi,(%esp)
80101050:	e8 80 f1 ff ff       	call   801001d5 <brelse>
}
80101055:	83 c4 10             	add    $0x10,%esp
80101058:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010105b:	5b                   	pop    %ebx
8010105c:	5e                   	pop    %esi
8010105d:	5d                   	pop    %ebp
8010105e:	c3                   	ret    
    panic("freeing free block");
8010105f:	83 ec 0c             	sub    $0xc,%esp
80101062:	68 bf 67 10 80       	push   $0x801067bf
80101067:	e8 dc f2 ff ff       	call   80100348 <panic>

8010106c <balloc>:
{
8010106c:	55                   	push   %ebp
8010106d:	89 e5                	mov    %esp,%ebp
8010106f:	57                   	push   %edi
80101070:	56                   	push   %esi
80101071:	53                   	push   %ebx
80101072:	83 ec 1c             	sub    $0x1c,%esp
80101075:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101078:	be 00 00 00 00       	mov    $0x0,%esi
8010107d:	eb 14                	jmp    80101093 <balloc+0x27>
    brelse(bp);
8010107f:	83 ec 0c             	sub    $0xc,%esp
80101082:	ff 75 e4             	pushl  -0x1c(%ebp)
80101085:	e8 4b f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010108a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101090:	83 c4 10             	add    $0x10,%esp
80101093:	39 35 c0 09 11 80    	cmp    %esi,0x801109c0
80101099:	76 75                	jbe    80101110 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010109b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
801010a1:	85 f6                	test   %esi,%esi
801010a3:	0f 49 c6             	cmovns %esi,%eax
801010a6:	c1 f8 0c             	sar    $0xc,%eax
801010a9:	03 05 d8 09 11 80    	add    0x801109d8,%eax
801010af:	83 ec 08             	sub    $0x8,%esp
801010b2:	50                   	push   %eax
801010b3:	ff 75 d8             	pushl  -0x28(%ebp)
801010b6:	e8 b1 f0 ff ff       	call   8010016c <bread>
801010bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010be:	83 c4 10             	add    $0x10,%esp
801010c1:	b8 00 00 00 00       	mov    $0x0,%eax
801010c6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801010cb:	7f b2                	jg     8010107f <balloc+0x13>
801010cd:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
801010d0:	89 5d e0             	mov    %ebx,-0x20(%ebp)
801010d3:	3b 1d c0 09 11 80    	cmp    0x801109c0,%ebx
801010d9:	73 a4                	jae    8010107f <balloc+0x13>
      m = 1 << (bi % 8);
801010db:	99                   	cltd   
801010dc:	c1 ea 1d             	shr    $0x1d,%edx
801010df:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801010e2:	83 e1 07             	and    $0x7,%ecx
801010e5:	29 d1                	sub    %edx,%ecx
801010e7:	ba 01 00 00 00       	mov    $0x1,%edx
801010ec:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801010ee:	8d 48 07             	lea    0x7(%eax),%ecx
801010f1:	85 c0                	test   %eax,%eax
801010f3:	0f 49 c8             	cmovns %eax,%ecx
801010f6:	c1 f9 03             	sar    $0x3,%ecx
801010f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801010fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801010ff:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101104:	0f b6 f9             	movzbl %cl,%edi
80101107:	85 d7                	test   %edx,%edi
80101109:	74 12                	je     8010111d <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010110b:	83 c0 01             	add    $0x1,%eax
8010110e:	eb b6                	jmp    801010c6 <balloc+0x5a>
  panic("balloc: out of blocks");
80101110:	83 ec 0c             	sub    $0xc,%esp
80101113:	68 d2 67 10 80       	push   $0x801067d2
80101118:	e8 2b f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
8010111d:	09 ca                	or     %ecx,%edx
8010111f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101122:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101125:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
80101129:	83 ec 0c             	sub    $0xc,%esp
8010112c:	89 c6                	mov    %eax,%esi
8010112e:	50                   	push   %eax
8010112f:	e8 c7 17 00 00       	call   801028fb <log_write>
        brelse(bp);
80101134:	89 34 24             	mov    %esi,(%esp)
80101137:	e8 99 f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
8010113c:	89 da                	mov    %ebx,%edx
8010113e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101141:	e8 7b fe ff ff       	call   80100fc1 <bzero>
}
80101146:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101149:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114c:	5b                   	pop    %ebx
8010114d:	5e                   	pop    %esi
8010114e:	5f                   	pop    %edi
8010114f:	5d                   	pop    %ebp
80101150:	c3                   	ret    

80101151 <bmap>:
{
80101151:	55                   	push   %ebp
80101152:	89 e5                	mov    %esp,%ebp
80101154:	57                   	push   %edi
80101155:	56                   	push   %esi
80101156:	53                   	push   %ebx
80101157:	83 ec 1c             	sub    $0x1c,%esp
8010115a:	89 c6                	mov    %eax,%esi
8010115c:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
8010115e:	83 fa 0b             	cmp    $0xb,%edx
80101161:	77 17                	ja     8010117a <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
80101163:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
80101167:	85 db                	test   %ebx,%ebx
80101169:	75 4a                	jne    801011b5 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010116b:	8b 00                	mov    (%eax),%eax
8010116d:	e8 fa fe ff ff       	call   8010106c <balloc>
80101172:	89 c3                	mov    %eax,%ebx
80101174:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101178:	eb 3b                	jmp    801011b5 <bmap+0x64>
  bn -= NDIRECT;
8010117a:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010117d:	83 fb 7f             	cmp    $0x7f,%ebx
80101180:	77 68                	ja     801011ea <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101182:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101188:	85 c0                	test   %eax,%eax
8010118a:	74 33                	je     801011bf <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010118c:	83 ec 08             	sub    $0x8,%esp
8010118f:	50                   	push   %eax
80101190:	ff 36                	pushl  (%esi)
80101192:	e8 d5 ef ff ff       	call   8010016c <bread>
80101197:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101199:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
8010119d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801011a0:	8b 18                	mov    (%eax),%ebx
801011a2:	83 c4 10             	add    $0x10,%esp
801011a5:	85 db                	test   %ebx,%ebx
801011a7:	74 25                	je     801011ce <bmap+0x7d>
    brelse(bp);
801011a9:	83 ec 0c             	sub    $0xc,%esp
801011ac:	57                   	push   %edi
801011ad:	e8 23 f0 ff ff       	call   801001d5 <brelse>
    return addr;
801011b2:	83 c4 10             	add    $0x10,%esp
}
801011b5:	89 d8                	mov    %ebx,%eax
801011b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011ba:	5b                   	pop    %ebx
801011bb:	5e                   	pop    %esi
801011bc:	5f                   	pop    %edi
801011bd:	5d                   	pop    %ebp
801011be:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801011bf:	8b 06                	mov    (%esi),%eax
801011c1:	e8 a6 fe ff ff       	call   8010106c <balloc>
801011c6:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801011cc:	eb be                	jmp    8010118c <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
801011ce:	8b 06                	mov    (%esi),%eax
801011d0:	e8 97 fe ff ff       	call   8010106c <balloc>
801011d5:	89 c3                	mov    %eax,%ebx
801011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011da:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	57                   	push   %edi
801011e0:	e8 16 17 00 00       	call   801028fb <log_write>
801011e5:	83 c4 10             	add    $0x10,%esp
801011e8:	eb bf                	jmp    801011a9 <bmap+0x58>
  panic("bmap: out of range");
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	68 e8 67 10 80       	push   $0x801067e8
801011f2:	e8 51 f1 ff ff       	call   80100348 <panic>

801011f7 <iget>:
{
801011f7:	55                   	push   %ebp
801011f8:	89 e5                	mov    %esp,%ebp
801011fa:	57                   	push   %edi
801011fb:	56                   	push   %esi
801011fc:	53                   	push   %ebx
801011fd:	83 ec 28             	sub    $0x28,%esp
80101200:	89 c7                	mov    %eax,%edi
80101202:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101205:	68 e0 09 11 80       	push   $0x801109e0
8010120a:	e8 13 2a 00 00       	call   80103c22 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010120f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101212:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101217:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
8010121c:	eb 0a                	jmp    80101228 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010121e:	85 f6                	test   %esi,%esi
80101220:	74 3b                	je     8010125d <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101222:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101228:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
8010122e:	73 35                	jae    80101265 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101230:	8b 43 08             	mov    0x8(%ebx),%eax
80101233:	85 c0                	test   %eax,%eax
80101235:	7e e7                	jle    8010121e <iget+0x27>
80101237:	39 3b                	cmp    %edi,(%ebx)
80101239:	75 e3                	jne    8010121e <iget+0x27>
8010123b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010123e:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101241:	75 db                	jne    8010121e <iget+0x27>
      ip->ref++;
80101243:	83 c0 01             	add    $0x1,%eax
80101246:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101249:	83 ec 0c             	sub    $0xc,%esp
8010124c:	68 e0 09 11 80       	push   $0x801109e0
80101251:	e8 31 2a 00 00       	call   80103c87 <release>
      return ip;
80101256:	83 c4 10             	add    $0x10,%esp
80101259:	89 de                	mov    %ebx,%esi
8010125b:	eb 32                	jmp    8010128f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010125d:	85 c0                	test   %eax,%eax
8010125f:	75 c1                	jne    80101222 <iget+0x2b>
      empty = ip;
80101261:	89 de                	mov    %ebx,%esi
80101263:	eb bd                	jmp    80101222 <iget+0x2b>
  if(empty == 0)
80101265:	85 f6                	test   %esi,%esi
80101267:	74 30                	je     80101299 <iget+0xa2>
  ip->dev = dev;
80101269:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010126b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010126e:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101271:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101278:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010127f:	83 ec 0c             	sub    $0xc,%esp
80101282:	68 e0 09 11 80       	push   $0x801109e0
80101287:	e8 fb 29 00 00       	call   80103c87 <release>
  return ip;
8010128c:	83 c4 10             	add    $0x10,%esp
}
8010128f:	89 f0                	mov    %esi,%eax
80101291:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101294:	5b                   	pop    %ebx
80101295:	5e                   	pop    %esi
80101296:	5f                   	pop    %edi
80101297:	5d                   	pop    %ebp
80101298:	c3                   	ret    
    panic("iget: no inodes");
80101299:	83 ec 0c             	sub    $0xc,%esp
8010129c:	68 fb 67 10 80       	push   $0x801067fb
801012a1:	e8 a2 f0 ff ff       	call   80100348 <panic>

801012a6 <readsb>:
{
801012a6:	55                   	push   %ebp
801012a7:	89 e5                	mov    %esp,%ebp
801012a9:	53                   	push   %ebx
801012aa:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801012ad:	6a 01                	push   $0x1
801012af:	ff 75 08             	pushl  0x8(%ebp)
801012b2:	e8 b5 ee ff ff       	call   8010016c <bread>
801012b7:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801012b9:	8d 40 5c             	lea    0x5c(%eax),%eax
801012bc:	83 c4 0c             	add    $0xc,%esp
801012bf:	6a 1c                	push   $0x1c
801012c1:	50                   	push   %eax
801012c2:	ff 75 0c             	pushl  0xc(%ebp)
801012c5:	e8 7f 2a 00 00       	call   80103d49 <memmove>
  brelse(bp);
801012ca:	89 1c 24             	mov    %ebx,(%esp)
801012cd:	e8 03 ef ff ff       	call   801001d5 <brelse>
}
801012d2:	83 c4 10             	add    $0x10,%esp
801012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801012d8:	c9                   	leave  
801012d9:	c3                   	ret    

801012da <iinit>:
{
801012da:	55                   	push   %ebp
801012db:	89 e5                	mov    %esp,%ebp
801012dd:	53                   	push   %ebx
801012de:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012e1:	68 0b 68 10 80       	push   $0x8010680b
801012e6:	68 e0 09 11 80       	push   $0x801109e0
801012eb:	e8 f6 27 00 00       	call   80103ae6 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 12 68 10 80       	push   $0x80106812
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 20 0a 11 80       	add    $0x80110a20,%eax
8010130f:	50                   	push   %eax
80101310:	e8 c6 26 00 00       	call   801039db <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101315:	83 c3 01             	add    $0x1,%ebx
80101318:	83 c4 10             	add    $0x10,%esp
8010131b:	83 fb 31             	cmp    $0x31,%ebx
8010131e:	7e da                	jle    801012fa <iinit+0x20>
  readsb(dev, &sb);
80101320:	83 ec 08             	sub    $0x8,%esp
80101323:	68 c0 09 11 80       	push   $0x801109c0
80101328:	ff 75 08             	pushl  0x8(%ebp)
8010132b:	e8 76 ff ff ff       	call   801012a6 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101330:	ff 35 d8 09 11 80    	pushl  0x801109d8
80101336:	ff 35 d4 09 11 80    	pushl  0x801109d4
8010133c:	ff 35 d0 09 11 80    	pushl  0x801109d0
80101342:	ff 35 cc 09 11 80    	pushl  0x801109cc
80101348:	ff 35 c8 09 11 80    	pushl  0x801109c8
8010134e:	ff 35 c4 09 11 80    	pushl  0x801109c4
80101354:	ff 35 c0 09 11 80    	pushl  0x801109c0
8010135a:	68 78 68 10 80       	push   $0x80106878
8010135f:	e8 a7 f2 ff ff       	call   8010060b <cprintf>
}
80101364:	83 c4 30             	add    $0x30,%esp
80101367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010136a:	c9                   	leave  
8010136b:	c3                   	ret    

8010136c <ialloc>:
{
8010136c:	55                   	push   %ebp
8010136d:	89 e5                	mov    %esp,%ebp
8010136f:	57                   	push   %edi
80101370:	56                   	push   %esi
80101371:	53                   	push   %ebx
80101372:	83 ec 1c             	sub    $0x1c,%esp
80101375:	8b 45 0c             	mov    0xc(%ebp),%eax
80101378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010137b:	bb 01 00 00 00       	mov    $0x1,%ebx
80101380:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101383:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
80101389:	76 3f                	jbe    801013ca <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010138b:	89 d8                	mov    %ebx,%eax
8010138d:	c1 e8 03             	shr    $0x3,%eax
80101390:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101396:	83 ec 08             	sub    $0x8,%esp
80101399:	50                   	push   %eax
8010139a:	ff 75 08             	pushl  0x8(%ebp)
8010139d:	e8 ca ed ff ff       	call   8010016c <bread>
801013a2:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013a4:	89 d8                	mov    %ebx,%eax
801013a6:	83 e0 07             	and    $0x7,%eax
801013a9:	c1 e0 06             	shl    $0x6,%eax
801013ac:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013b0:	83 c4 10             	add    $0x10,%esp
801013b3:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013b7:	74 1e                	je     801013d7 <ialloc+0x6b>
    brelse(bp);
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	56                   	push   %esi
801013bd:	e8 13 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013c2:	83 c3 01             	add    $0x1,%ebx
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	eb b6                	jmp    80101380 <ialloc+0x14>
  panic("ialloc: no inodes");
801013ca:	83 ec 0c             	sub    $0xc,%esp
801013cd:	68 18 68 10 80       	push   $0x80106818
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 ea 28 00 00       	call   80103cce <memset>
      dip->type = type;
801013e4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013e8:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013eb:	89 34 24             	mov    %esi,(%esp)
801013ee:	e8 08 15 00 00       	call   801028fb <log_write>
      brelse(bp);
801013f3:	89 34 24             	mov    %esi,(%esp)
801013f6:	e8 da ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
801013fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	e8 f1 fd ff ff       	call   801011f7 <iget>
}
80101406:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101409:	5b                   	pop    %ebx
8010140a:	5e                   	pop    %esi
8010140b:	5f                   	pop    %edi
8010140c:	5d                   	pop    %ebp
8010140d:	c3                   	ret    

8010140e <iupdate>:
{
8010140e:	55                   	push   %ebp
8010140f:	89 e5                	mov    %esp,%ebp
80101411:	56                   	push   %esi
80101412:	53                   	push   %ebx
80101413:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101416:	8b 43 04             	mov    0x4(%ebx),%eax
80101419:	c1 e8 03             	shr    $0x3,%eax
8010141c:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101422:	83 ec 08             	sub    $0x8,%esp
80101425:	50                   	push   %eax
80101426:	ff 33                	pushl  (%ebx)
80101428:	e8 3f ed ff ff       	call   8010016c <bread>
8010142d:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010142f:	8b 43 04             	mov    0x4(%ebx),%eax
80101432:	83 e0 07             	and    $0x7,%eax
80101435:	c1 e0 06             	shl    $0x6,%eax
80101438:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010143c:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101440:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101443:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101447:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010144b:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010144f:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101453:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101457:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010145b:	8b 53 58             	mov    0x58(%ebx),%edx
8010145e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101461:	83 c3 5c             	add    $0x5c,%ebx
80101464:	83 c0 0c             	add    $0xc,%eax
80101467:	83 c4 0c             	add    $0xc,%esp
8010146a:	6a 34                	push   $0x34
8010146c:	53                   	push   %ebx
8010146d:	50                   	push   %eax
8010146e:	e8 d6 28 00 00       	call   80103d49 <memmove>
  log_write(bp);
80101473:	89 34 24             	mov    %esi,(%esp)
80101476:	e8 80 14 00 00       	call   801028fb <log_write>
  brelse(bp);
8010147b:	89 34 24             	mov    %esi,(%esp)
8010147e:	e8 52 ed ff ff       	call   801001d5 <brelse>
}
80101483:	83 c4 10             	add    $0x10,%esp
80101486:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101489:	5b                   	pop    %ebx
8010148a:	5e                   	pop    %esi
8010148b:	5d                   	pop    %ebp
8010148c:	c3                   	ret    

8010148d <itrunc>:
{
8010148d:	55                   	push   %ebp
8010148e:	89 e5                	mov    %esp,%ebp
80101490:	57                   	push   %edi
80101491:	56                   	push   %esi
80101492:	53                   	push   %ebx
80101493:	83 ec 1c             	sub    $0x1c,%esp
80101496:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
80101498:	bb 00 00 00 00       	mov    $0x0,%ebx
8010149d:	eb 03                	jmp    801014a2 <itrunc+0x15>
8010149f:	83 c3 01             	add    $0x1,%ebx
801014a2:	83 fb 0b             	cmp    $0xb,%ebx
801014a5:	7f 19                	jg     801014c0 <itrunc+0x33>
    if(ip->addrs[i]){
801014a7:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014ab:	85 d2                	test   %edx,%edx
801014ad:	74 f0                	je     8010149f <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014af:	8b 06                	mov    (%esi),%eax
801014b1:	e8 46 fb ff ff       	call   80100ffc <bfree>
      ip->addrs[i] = 0;
801014b6:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014bd:	00 
801014be:	eb df                	jmp    8010149f <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014c0:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014c6:	85 c0                	test   %eax,%eax
801014c8:	75 1b                	jne    801014e5 <itrunc+0x58>
  ip->size = 0;
801014ca:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014d1:	83 ec 0c             	sub    $0xc,%esp
801014d4:	56                   	push   %esi
801014d5:	e8 34 ff ff ff       	call   8010140e <iupdate>
}
801014da:	83 c4 10             	add    $0x10,%esp
801014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014e0:	5b                   	pop    %ebx
801014e1:	5e                   	pop    %esi
801014e2:	5f                   	pop    %edi
801014e3:	5d                   	pop    %ebp
801014e4:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014e5:	83 ec 08             	sub    $0x8,%esp
801014e8:	50                   	push   %eax
801014e9:	ff 36                	pushl  (%esi)
801014eb:	e8 7c ec ff ff       	call   8010016c <bread>
801014f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801014f3:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
801014f6:	83 c4 10             	add    $0x10,%esp
801014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801014fe:	eb 03                	jmp    80101503 <itrunc+0x76>
80101500:	83 c3 01             	add    $0x1,%ebx
80101503:	83 fb 7f             	cmp    $0x7f,%ebx
80101506:	77 10                	ja     80101518 <itrunc+0x8b>
      if(a[j])
80101508:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010150b:	85 d2                	test   %edx,%edx
8010150d:	74 f1                	je     80101500 <itrunc+0x73>
        bfree(ip->dev, a[j]);
8010150f:	8b 06                	mov    (%esi),%eax
80101511:	e8 e6 fa ff ff       	call   80100ffc <bfree>
80101516:	eb e8                	jmp    80101500 <itrunc+0x73>
    brelse(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010151e:	e8 b2 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101523:	8b 06                	mov    (%esi),%eax
80101525:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010152b:	e8 cc fa ff ff       	call   80100ffc <bfree>
    ip->addrs[NDIRECT] = 0;
80101530:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101537:	00 00 00 
8010153a:	83 c4 10             	add    $0x10,%esp
8010153d:	eb 8b                	jmp    801014ca <itrunc+0x3d>

8010153f <idup>:
{
8010153f:	55                   	push   %ebp
80101540:	89 e5                	mov    %esp,%ebp
80101542:	53                   	push   %ebx
80101543:	83 ec 10             	sub    $0x10,%esp
80101546:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101549:	68 e0 09 11 80       	push   $0x801109e0
8010154e:	e8 cf 26 00 00       	call   80103c22 <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101563:	e8 1f 27 00 00       	call   80103c87 <release>
}
80101568:	89 d8                	mov    %ebx,%eax
8010156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010156d:	c9                   	leave  
8010156e:	c3                   	ret    

8010156f <ilock>:
{
8010156f:	55                   	push   %ebp
80101570:	89 e5                	mov    %esp,%ebp
80101572:	56                   	push   %esi
80101573:	53                   	push   %ebx
80101574:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101577:	85 db                	test   %ebx,%ebx
80101579:	74 22                	je     8010159d <ilock+0x2e>
8010157b:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010157f:	7e 1c                	jle    8010159d <ilock+0x2e>
  acquiresleep(&ip->lock);
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	8d 43 0c             	lea    0xc(%ebx),%eax
80101587:	50                   	push   %eax
80101588:	e8 81 24 00 00       	call   80103a0e <acquiresleep>
  if(ip->valid == 0){
8010158d:	83 c4 10             	add    $0x10,%esp
80101590:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101594:	74 14                	je     801015aa <ilock+0x3b>
}
80101596:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101599:	5b                   	pop    %ebx
8010159a:	5e                   	pop    %esi
8010159b:	5d                   	pop    %ebp
8010159c:	c3                   	ret    
    panic("ilock");
8010159d:	83 ec 0c             	sub    $0xc,%esp
801015a0:	68 2a 68 10 80       	push   $0x8010682a
801015a5:	e8 9e ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015aa:	8b 43 04             	mov    0x4(%ebx),%eax
801015ad:	c1 e8 03             	shr    $0x3,%eax
801015b0:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801015b6:	83 ec 08             	sub    $0x8,%esp
801015b9:	50                   	push   %eax
801015ba:	ff 33                	pushl  (%ebx)
801015bc:	e8 ab eb ff ff       	call   8010016c <bread>
801015c1:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015c3:	8b 43 04             	mov    0x4(%ebx),%eax
801015c6:	83 e0 07             	and    $0x7,%eax
801015c9:	c1 e0 06             	shl    $0x6,%eax
801015cc:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015d0:	0f b7 10             	movzwl (%eax),%edx
801015d3:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015d7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015db:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015df:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015e3:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015eb:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801015ef:	8b 50 08             	mov    0x8(%eax),%edx
801015f2:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015f5:	83 c0 0c             	add    $0xc,%eax
801015f8:	8d 53 5c             	lea    0x5c(%ebx),%edx
801015fb:	83 c4 0c             	add    $0xc,%esp
801015fe:	6a 34                	push   $0x34
80101600:	50                   	push   %eax
80101601:	52                   	push   %edx
80101602:	e8 42 27 00 00       	call   80103d49 <memmove>
    brelse(bp);
80101607:	89 34 24             	mov    %esi,(%esp)
8010160a:	e8 c6 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
8010160f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101616:	83 c4 10             	add    $0x10,%esp
80101619:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010161e:	0f 85 72 ff ff ff    	jne    80101596 <ilock+0x27>
      panic("ilock: no type");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 30 68 10 80       	push   $0x80106830
8010162c:	e8 17 ed ff ff       	call   80100348 <panic>

80101631 <iunlock>:
{
80101631:	55                   	push   %ebp
80101632:	89 e5                	mov    %esp,%ebp
80101634:	56                   	push   %esi
80101635:	53                   	push   %ebx
80101636:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101639:	85 db                	test   %ebx,%ebx
8010163b:	74 2c                	je     80101669 <iunlock+0x38>
8010163d:	8d 73 0c             	lea    0xc(%ebx),%esi
80101640:	83 ec 0c             	sub    $0xc,%esp
80101643:	56                   	push   %esi
80101644:	e8 4f 24 00 00       	call   80103a98 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 fe 23 00 00       	call   80103a5d <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 3f 68 10 80       	push   $0x8010683f
80101671:	e8 d2 ec ff ff       	call   80100348 <panic>

80101676 <iput>:
{
80101676:	55                   	push   %ebp
80101677:	89 e5                	mov    %esp,%ebp
80101679:	57                   	push   %edi
8010167a:	56                   	push   %esi
8010167b:	53                   	push   %ebx
8010167c:	83 ec 18             	sub    $0x18,%esp
8010167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101682:	8d 73 0c             	lea    0xc(%ebx),%esi
80101685:	56                   	push   %esi
80101686:	e8 83 23 00 00       	call   80103a0e <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 b9 23 00 00       	call   80103a5d <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016ab:	e8 72 25 00 00       	call   80103c22 <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016c0:	e8 c2 25 00 00       	call   80103c87 <release>
}
801016c5:	83 c4 10             	add    $0x10,%esp
801016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016cb:	5b                   	pop    %ebx
801016cc:	5e                   	pop    %esi
801016cd:	5f                   	pop    %edi
801016ce:	5d                   	pop    %ebp
801016cf:	c3                   	ret    
    acquire(&icache.lock);
801016d0:	83 ec 0c             	sub    $0xc,%esp
801016d3:	68 e0 09 11 80       	push   $0x801109e0
801016d8:	e8 45 25 00 00       	call   80103c22 <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016e7:	e8 9b 25 00 00       	call   80103c87 <release>
    if(r == 1){
801016ec:	83 c4 10             	add    $0x10,%esp
801016ef:	83 ff 01             	cmp    $0x1,%edi
801016f2:	75 a7                	jne    8010169b <iput+0x25>
      itrunc(ip);
801016f4:	89 d8                	mov    %ebx,%eax
801016f6:	e8 92 fd ff ff       	call   8010148d <itrunc>
      ip->type = 0;
801016fb:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101701:	83 ec 0c             	sub    $0xc,%esp
80101704:	53                   	push   %ebx
80101705:	e8 04 fd ff ff       	call   8010140e <iupdate>
      ip->valid = 0;
8010170a:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101711:	83 c4 10             	add    $0x10,%esp
80101714:	eb 85                	jmp    8010169b <iput+0x25>

80101716 <iunlockput>:
{
80101716:	55                   	push   %ebp
80101717:	89 e5                	mov    %esp,%ebp
80101719:	53                   	push   %ebx
8010171a:	83 ec 10             	sub    $0x10,%esp
8010171d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101720:	53                   	push   %ebx
80101721:	e8 0b ff ff ff       	call   80101631 <iunlock>
  iput(ip);
80101726:	89 1c 24             	mov    %ebx,(%esp)
80101729:	e8 48 ff ff ff       	call   80101676 <iput>
}
8010172e:	83 c4 10             	add    $0x10,%esp
80101731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101734:	c9                   	leave  
80101735:	c3                   	ret    

80101736 <stati>:
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	8b 55 08             	mov    0x8(%ebp),%edx
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
8010173f:	8b 0a                	mov    (%edx),%ecx
80101741:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101744:	8b 4a 04             	mov    0x4(%edx),%ecx
80101747:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010174a:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010174e:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101751:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101755:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101759:	8b 52 58             	mov    0x58(%edx),%edx
8010175c:	89 50 10             	mov    %edx,0x10(%eax)
}
8010175f:	5d                   	pop    %ebp
80101760:	c3                   	ret    

80101761 <readi>:
{
80101761:	55                   	push   %ebp
80101762:	89 e5                	mov    %esp,%ebp
80101764:	57                   	push   %edi
80101765:	56                   	push   %esi
80101766:	53                   	push   %ebx
80101767:	83 ec 1c             	sub    $0x1c,%esp
8010176a:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010176d:	8b 45 08             	mov    0x8(%ebp),%eax
80101770:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101775:	74 2c                	je     801017a3 <readi+0x42>
  if(off > ip->size || off + n < off)
80101777:	8b 45 08             	mov    0x8(%ebp),%eax
8010177a:	8b 40 58             	mov    0x58(%eax),%eax
8010177d:	39 f8                	cmp    %edi,%eax
8010177f:	0f 82 cb 00 00 00    	jb     80101850 <readi+0xef>
80101785:	89 fa                	mov    %edi,%edx
80101787:	03 55 14             	add    0x14(%ebp),%edx
8010178a:	0f 82 c7 00 00 00    	jb     80101857 <readi+0xf6>
  if(off + n > ip->size)
80101790:	39 d0                	cmp    %edx,%eax
80101792:	73 05                	jae    80101799 <readi+0x38>
    n = ip->size - off;
80101794:	29 f8                	sub    %edi,%eax
80101796:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101799:	be 00 00 00 00       	mov    $0x0,%esi
8010179e:	e9 8f 00 00 00       	jmp    80101832 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017a3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017a7:	66 83 f8 09          	cmp    $0x9,%ax
801017ab:	0f 87 91 00 00 00    	ja     80101842 <readi+0xe1>
801017b1:	98                   	cwtl   
801017b2:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
801017b9:	85 c0                	test   %eax,%eax
801017bb:	0f 84 88 00 00 00    	je     80101849 <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017c1:	83 ec 04             	sub    $0x4,%esp
801017c4:	ff 75 14             	pushl  0x14(%ebp)
801017c7:	ff 75 0c             	pushl  0xc(%ebp)
801017ca:	ff 75 08             	pushl  0x8(%ebp)
801017cd:	ff d0                	call   *%eax
801017cf:	83 c4 10             	add    $0x10,%esp
801017d2:	eb 66                	jmp    8010183a <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017d4:	89 fa                	mov    %edi,%edx
801017d6:	c1 ea 09             	shr    $0x9,%edx
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	e8 70 f9 ff ff       	call   80101151 <bmap>
801017e1:	83 ec 08             	sub    $0x8,%esp
801017e4:	50                   	push   %eax
801017e5:	8b 45 08             	mov    0x8(%ebp),%eax
801017e8:	ff 30                	pushl  (%eax)
801017ea:	e8 7d e9 ff ff       	call   8010016c <bread>
801017ef:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
801017f1:	89 f8                	mov    %edi,%eax
801017f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801017f8:	bb 00 02 00 00       	mov    $0x200,%ebx
801017fd:	29 c3                	sub    %eax,%ebx
801017ff:	8b 55 14             	mov    0x14(%ebp),%edx
80101802:	29 f2                	sub    %esi,%edx
80101804:	83 c4 0c             	add    $0xc,%esp
80101807:	39 d3                	cmp    %edx,%ebx
80101809:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010180c:	53                   	push   %ebx
8010180d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101810:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101814:	50                   	push   %eax
80101815:	ff 75 0c             	pushl  0xc(%ebp)
80101818:	e8 2c 25 00 00       	call   80103d49 <memmove>
    brelse(bp);
8010181d:	83 c4 04             	add    $0x4,%esp
80101820:	ff 75 e4             	pushl  -0x1c(%ebp)
80101823:	e8 ad e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101828:	01 de                	add    %ebx,%esi
8010182a:	01 df                	add    %ebx,%edi
8010182c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010182f:	83 c4 10             	add    $0x10,%esp
80101832:	39 75 14             	cmp    %esi,0x14(%ebp)
80101835:	77 9d                	ja     801017d4 <readi+0x73>
  return n;
80101837:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010183a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010183d:	5b                   	pop    %ebx
8010183e:	5e                   	pop    %esi
8010183f:	5f                   	pop    %edi
80101840:	5d                   	pop    %ebp
80101841:	c3                   	ret    
      return -1;
80101842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101847:	eb f1                	jmp    8010183a <readi+0xd9>
80101849:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010184e:	eb ea                	jmp    8010183a <readi+0xd9>
    return -1;
80101850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101855:	eb e3                	jmp    8010183a <readi+0xd9>
80101857:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010185c:	eb dc                	jmp    8010183a <readi+0xd9>

8010185e <writei>:
{
8010185e:	55                   	push   %ebp
8010185f:	89 e5                	mov    %esp,%ebp
80101861:	57                   	push   %edi
80101862:	56                   	push   %esi
80101863:	53                   	push   %ebx
80101864:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010186f:	74 2f                	je     801018a0 <writei+0x42>
  if(off > ip->size || off + n < off)
80101871:	8b 45 08             	mov    0x8(%ebp),%eax
80101874:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101877:	39 48 58             	cmp    %ecx,0x58(%eax)
8010187a:	0f 82 f4 00 00 00    	jb     80101974 <writei+0x116>
80101880:	89 c8                	mov    %ecx,%eax
80101882:	03 45 14             	add    0x14(%ebp),%eax
80101885:	0f 82 f0 00 00 00    	jb     8010197b <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
8010188b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101890:	0f 87 ec 00 00 00    	ja     80101982 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101896:	be 00 00 00 00       	mov    $0x0,%esi
8010189b:	e9 94 00 00 00       	jmp    80101934 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018a0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018a4:	66 83 f8 09          	cmp    $0x9,%ax
801018a8:	0f 87 b8 00 00 00    	ja     80101966 <writei+0x108>
801018ae:	98                   	cwtl   
801018af:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
801018b6:	85 c0                	test   %eax,%eax
801018b8:	0f 84 af 00 00 00    	je     8010196d <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018be:	83 ec 04             	sub    $0x4,%esp
801018c1:	ff 75 14             	pushl  0x14(%ebp)
801018c4:	ff 75 0c             	pushl  0xc(%ebp)
801018c7:	ff 75 08             	pushl  0x8(%ebp)
801018ca:	ff d0                	call   *%eax
801018cc:	83 c4 10             	add    $0x10,%esp
801018cf:	eb 7c                	jmp    8010194d <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018d1:	8b 55 10             	mov    0x10(%ebp),%edx
801018d4:	c1 ea 09             	shr    $0x9,%edx
801018d7:	8b 45 08             	mov    0x8(%ebp),%eax
801018da:	e8 72 f8 ff ff       	call   80101151 <bmap>
801018df:	83 ec 08             	sub    $0x8,%esp
801018e2:	50                   	push   %eax
801018e3:	8b 45 08             	mov    0x8(%ebp),%eax
801018e6:	ff 30                	pushl  (%eax)
801018e8:	e8 7f e8 ff ff       	call   8010016c <bread>
801018ed:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
801018ef:	8b 45 10             	mov    0x10(%ebp),%eax
801018f2:	25 ff 01 00 00       	and    $0x1ff,%eax
801018f7:	bb 00 02 00 00       	mov    $0x200,%ebx
801018fc:	29 c3                	sub    %eax,%ebx
801018fe:	8b 55 14             	mov    0x14(%ebp),%edx
80101901:	29 f2                	sub    %esi,%edx
80101903:	83 c4 0c             	add    $0xc,%esp
80101906:	39 d3                	cmp    %edx,%ebx
80101908:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010190b:	53                   	push   %ebx
8010190c:	ff 75 0c             	pushl  0xc(%ebp)
8010190f:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101913:	50                   	push   %eax
80101914:	e8 30 24 00 00       	call   80103d49 <memmove>
    log_write(bp);
80101919:	89 3c 24             	mov    %edi,(%esp)
8010191c:	e8 da 0f 00 00       	call   801028fb <log_write>
    brelse(bp);
80101921:	89 3c 24             	mov    %edi,(%esp)
80101924:	e8 ac e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101929:	01 de                	add    %ebx,%esi
8010192b:	01 5d 10             	add    %ebx,0x10(%ebp)
8010192e:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101931:	83 c4 10             	add    $0x10,%esp
80101934:	3b 75 14             	cmp    0x14(%ebp),%esi
80101937:	72 98                	jb     801018d1 <writei+0x73>
  if(n > 0 && off > ip->size){
80101939:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010193d:	74 0b                	je     8010194a <writei+0xec>
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101945:	39 48 58             	cmp    %ecx,0x58(%eax)
80101948:	72 0b                	jb     80101955 <writei+0xf7>
  return n;
8010194a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010194d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101950:	5b                   	pop    %ebx
80101951:	5e                   	pop    %esi
80101952:	5f                   	pop    %edi
80101953:	5d                   	pop    %ebp
80101954:	c3                   	ret    
    ip->size = off;
80101955:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
80101958:	83 ec 0c             	sub    $0xc,%esp
8010195b:	50                   	push   %eax
8010195c:	e8 ad fa ff ff       	call   8010140e <iupdate>
80101961:	83 c4 10             	add    $0x10,%esp
80101964:	eb e4                	jmp    8010194a <writei+0xec>
      return -1;
80101966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010196b:	eb e0                	jmp    8010194d <writei+0xef>
8010196d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101972:	eb d9                	jmp    8010194d <writei+0xef>
    return -1;
80101974:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101979:	eb d2                	jmp    8010194d <writei+0xef>
8010197b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101980:	eb cb                	jmp    8010194d <writei+0xef>
    return -1;
80101982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101987:	eb c4                	jmp    8010194d <writei+0xef>

80101989 <namecmp>:
{
80101989:	55                   	push   %ebp
8010198a:	89 e5                	mov    %esp,%ebp
8010198c:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
8010198f:	6a 0e                	push   $0xe
80101991:	ff 75 0c             	pushl  0xc(%ebp)
80101994:	ff 75 08             	pushl  0x8(%ebp)
80101997:	e8 14 24 00 00       	call   80103db0 <strncmp>
}
8010199c:	c9                   	leave  
8010199d:	c3                   	ret    

8010199e <dirlookup>:
{
8010199e:	55                   	push   %ebp
8010199f:	89 e5                	mov    %esp,%ebp
801019a1:	57                   	push   %edi
801019a2:	56                   	push   %esi
801019a3:	53                   	push   %ebx
801019a4:	83 ec 1c             	sub    $0x1c,%esp
801019a7:	8b 75 08             	mov    0x8(%ebp),%esi
801019aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019ad:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019b2:	75 07                	jne    801019bb <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019b4:	bb 00 00 00 00       	mov    $0x0,%ebx
801019b9:	eb 1d                	jmp    801019d8 <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019bb:	83 ec 0c             	sub    $0xc,%esp
801019be:	68 47 68 10 80       	push   $0x80106847
801019c3:	e8 80 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 59 68 10 80       	push   $0x80106859
801019d0:	e8 73 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019d5:	83 c3 10             	add    $0x10,%ebx
801019d8:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019db:	76 48                	jbe    80101a25 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019dd:	6a 10                	push   $0x10
801019df:	53                   	push   %ebx
801019e0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019e3:	50                   	push   %eax
801019e4:	56                   	push   %esi
801019e5:	e8 77 fd ff ff       	call   80101761 <readi>
801019ea:	83 c4 10             	add    $0x10,%esp
801019ed:	83 f8 10             	cmp    $0x10,%eax
801019f0:	75 d6                	jne    801019c8 <dirlookup+0x2a>
    if(de.inum == 0)
801019f2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801019f7:	74 dc                	je     801019d5 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
801019f9:	83 ec 08             	sub    $0x8,%esp
801019fc:	8d 45 da             	lea    -0x26(%ebp),%eax
801019ff:	50                   	push   %eax
80101a00:	57                   	push   %edi
80101a01:	e8 83 ff ff ff       	call   80101989 <namecmp>
80101a06:	83 c4 10             	add    $0x10,%esp
80101a09:	85 c0                	test   %eax,%eax
80101a0b:	75 c8                	jne    801019d5 <dirlookup+0x37>
      if(poff)
80101a0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a11:	74 05                	je     80101a18 <dirlookup+0x7a>
        *poff = off;
80101a13:	8b 45 10             	mov    0x10(%ebp),%eax
80101a16:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a18:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a1c:	8b 06                	mov    (%esi),%eax
80101a1e:	e8 d4 f7 ff ff       	call   801011f7 <iget>
80101a23:	eb 05                	jmp    80101a2a <dirlookup+0x8c>
  return 0;
80101a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2d:	5b                   	pop    %ebx
80101a2e:	5e                   	pop    %esi
80101a2f:	5f                   	pop    %edi
80101a30:	5d                   	pop    %ebp
80101a31:	c3                   	ret    

80101a32 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a32:	55                   	push   %ebp
80101a33:	89 e5                	mov    %esp,%ebp
80101a35:	57                   	push   %edi
80101a36:	56                   	push   %esi
80101a37:	53                   	push   %ebx
80101a38:	83 ec 1c             	sub    $0x1c,%esp
80101a3b:	89 c6                	mov    %eax,%esi
80101a3d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a40:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a43:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a46:	74 17                	je     80101a5f <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a48:	e8 0a 18 00 00       	call   80103257 <myproc>
80101a4d:	83 ec 0c             	sub    $0xc,%esp
80101a50:	ff 70 68             	pushl  0x68(%eax)
80101a53:	e8 e7 fa ff ff       	call   8010153f <idup>
80101a58:	89 c3                	mov    %eax,%ebx
80101a5a:	83 c4 10             	add    $0x10,%esp
80101a5d:	eb 53                	jmp    80101ab2 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a5f:	ba 01 00 00 00       	mov    $0x1,%edx
80101a64:	b8 01 00 00 00       	mov    $0x1,%eax
80101a69:	e8 89 f7 ff ff       	call   801011f7 <iget>
80101a6e:	89 c3                	mov    %eax,%ebx
80101a70:	eb 40                	jmp    80101ab2 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	53                   	push   %ebx
80101a76:	e8 9b fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101a7b:	83 c4 10             	add    $0x10,%esp
80101a7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a83:	89 d8                	mov    %ebx,%eax
80101a85:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a88:	5b                   	pop    %ebx
80101a89:	5e                   	pop    %esi
80101a8a:	5f                   	pop    %edi
80101a8b:	5d                   	pop    %ebp
80101a8c:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a8d:	83 ec 04             	sub    $0x4,%esp
80101a90:	6a 00                	push   $0x0
80101a92:	ff 75 e4             	pushl  -0x1c(%ebp)
80101a95:	53                   	push   %ebx
80101a96:	e8 03 ff ff ff       	call   8010199e <dirlookup>
80101a9b:	89 c7                	mov    %eax,%edi
80101a9d:	83 c4 10             	add    $0x10,%esp
80101aa0:	85 c0                	test   %eax,%eax
80101aa2:	74 4a                	je     80101aee <namex+0xbc>
    iunlockput(ip);
80101aa4:	83 ec 0c             	sub    $0xc,%esp
80101aa7:	53                   	push   %ebx
80101aa8:	e8 69 fc ff ff       	call   80101716 <iunlockput>
    ip = next;
80101aad:	83 c4 10             	add    $0x10,%esp
80101ab0:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ab2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ab5:	89 f0                	mov    %esi,%eax
80101ab7:	e8 89 f4 ff ff       	call   80100f45 <skipelem>
80101abc:	89 c6                	mov    %eax,%esi
80101abe:	85 c0                	test   %eax,%eax
80101ac0:	74 3c                	je     80101afe <namex+0xcc>
    ilock(ip);
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	53                   	push   %ebx
80101ac6:	e8 a4 fa ff ff       	call   8010156f <ilock>
    if(ip->type != T_DIR){
80101acb:	83 c4 10             	add    $0x10,%esp
80101ace:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ad3:	75 9d                	jne    80101a72 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ad5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ad9:	74 b2                	je     80101a8d <namex+0x5b>
80101adb:	80 3e 00             	cmpb   $0x0,(%esi)
80101ade:	75 ad                	jne    80101a8d <namex+0x5b>
      iunlock(ip);
80101ae0:	83 ec 0c             	sub    $0xc,%esp
80101ae3:	53                   	push   %ebx
80101ae4:	e8 48 fb ff ff       	call   80101631 <iunlock>
      return ip;
80101ae9:	83 c4 10             	add    $0x10,%esp
80101aec:	eb 95                	jmp    80101a83 <namex+0x51>
      iunlockput(ip);
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	53                   	push   %ebx
80101af2:	e8 1f fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101af7:	83 c4 10             	add    $0x10,%esp
80101afa:	89 fb                	mov    %edi,%ebx
80101afc:	eb 85                	jmp    80101a83 <namex+0x51>
  if(nameiparent){
80101afe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b02:	0f 84 7b ff ff ff    	je     80101a83 <namex+0x51>
    iput(ip);
80101b08:	83 ec 0c             	sub    $0xc,%esp
80101b0b:	53                   	push   %ebx
80101b0c:	e8 65 fb ff ff       	call   80101676 <iput>
    return 0;
80101b11:	83 c4 10             	add    $0x10,%esp
80101b14:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b19:	e9 65 ff ff ff       	jmp    80101a83 <namex+0x51>

80101b1e <dirlink>:
{
80101b1e:	55                   	push   %ebp
80101b1f:	89 e5                	mov    %esp,%ebp
80101b21:	57                   	push   %edi
80101b22:	56                   	push   %esi
80101b23:	53                   	push   %ebx
80101b24:	83 ec 20             	sub    $0x20,%esp
80101b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b2d:	6a 00                	push   $0x0
80101b2f:	57                   	push   %edi
80101b30:	53                   	push   %ebx
80101b31:	e8 68 fe ff ff       	call   8010199e <dirlookup>
80101b36:	83 c4 10             	add    $0x10,%esp
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	75 2d                	jne    80101b6a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b3d:	b8 00 00 00 00       	mov    $0x0,%eax
80101b42:	89 c6                	mov    %eax,%esi
80101b44:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b47:	76 41                	jbe    80101b8a <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b49:	6a 10                	push   $0x10
80101b4b:	50                   	push   %eax
80101b4c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b4f:	50                   	push   %eax
80101b50:	53                   	push   %ebx
80101b51:	e8 0b fc ff ff       	call   80101761 <readi>
80101b56:	83 c4 10             	add    $0x10,%esp
80101b59:	83 f8 10             	cmp    $0x10,%eax
80101b5c:	75 1f                	jne    80101b7d <dirlink+0x5f>
    if(de.inum == 0)
80101b5e:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b63:	74 25                	je     80101b8a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b65:	8d 46 10             	lea    0x10(%esi),%eax
80101b68:	eb d8                	jmp    80101b42 <dirlink+0x24>
    iput(ip);
80101b6a:	83 ec 0c             	sub    $0xc,%esp
80101b6d:	50                   	push   %eax
80101b6e:	e8 03 fb ff ff       	call   80101676 <iput>
    return -1;
80101b73:	83 c4 10             	add    $0x10,%esp
80101b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b7b:	eb 3d                	jmp    80101bba <dirlink+0x9c>
      panic("dirlink read");
80101b7d:	83 ec 0c             	sub    $0xc,%esp
80101b80:	68 68 68 10 80       	push   $0x80106868
80101b85:	e8 be e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b8a:	83 ec 04             	sub    $0x4,%esp
80101b8d:	6a 0e                	push   $0xe
80101b8f:	57                   	push   %edi
80101b90:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b93:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b96:	50                   	push   %eax
80101b97:	e8 51 22 00 00       	call   80103ded <strncpy>
  de.inum = inum;
80101b9c:	8b 45 10             	mov    0x10(%ebp),%eax
80101b9f:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ba3:	6a 10                	push   $0x10
80101ba5:	56                   	push   %esi
80101ba6:	57                   	push   %edi
80101ba7:	53                   	push   %ebx
80101ba8:	e8 b1 fc ff ff       	call   8010185e <writei>
80101bad:	83 c4 20             	add    $0x20,%esp
80101bb0:	83 f8 10             	cmp    $0x10,%eax
80101bb3:	75 0d                	jne    80101bc2 <dirlink+0xa4>
  return 0;
80101bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bbd:	5b                   	pop    %ebx
80101bbe:	5e                   	pop    %esi
80101bbf:	5f                   	pop    %edi
80101bc0:	5d                   	pop    %ebp
80101bc1:	c3                   	ret    
    panic("dirlink");
80101bc2:	83 ec 0c             	sub    $0xc,%esp
80101bc5:	68 48 6f 10 80       	push   $0x80106f48
80101bca:	e8 79 e7 ff ff       	call   80100348 <panic>

80101bcf <namei>:

struct inode*
namei(char *path)
{
80101bcf:	55                   	push   %ebp
80101bd0:	89 e5                	mov    %esp,%ebp
80101bd2:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bd5:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bd8:	ba 00 00 00 00       	mov    $0x0,%edx
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	e8 4d fe ff ff       	call   80101a32 <namex>
}
80101be5:	c9                   	leave  
80101be6:	c3                   	ret    

80101be7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101be7:	55                   	push   %ebp
80101be8:	89 e5                	mov    %esp,%ebp
80101bea:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101bf0:	ba 01 00 00 00       	mov    $0x1,%edx
80101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf8:	e8 35 fe ff ff       	call   80101a32 <namex>
}
80101bfd:	c9                   	leave  
80101bfe:	c3                   	ret    

80101bff <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101bff:	55                   	push   %ebp
80101c00:	89 e5                	mov    %esp,%ebp
80101c02:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c04:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c09:	ec                   	in     (%dx),%al
80101c0a:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c0c:	83 e0 c0             	and    $0xffffffc0,%eax
80101c0f:	3c 40                	cmp    $0x40,%al
80101c11:	75 f1                	jne    80101c04 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c13:	85 c9                	test   %ecx,%ecx
80101c15:	74 0c                	je     80101c23 <idewait+0x24>
80101c17:	f6 c2 21             	test   $0x21,%dl
80101c1a:	75 0e                	jne    80101c2a <idewait+0x2b>
    return -1;
  return 0;
80101c1c:	b8 00 00 00 00       	mov    $0x0,%eax
80101c21:	eb 05                	jmp    80101c28 <idewait+0x29>
80101c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c28:	5d                   	pop    %ebp
80101c29:	c3                   	ret    
    return -1;
80101c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c2f:	eb f7                	jmp    80101c28 <idewait+0x29>

80101c31 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c31:	55                   	push   %ebp
80101c32:	89 e5                	mov    %esp,%ebp
80101c34:	56                   	push   %esi
80101c35:	53                   	push   %ebx
  if(b == 0)
80101c36:	85 c0                	test   %eax,%eax
80101c38:	74 7d                	je     80101cb7 <idestart+0x86>
80101c3a:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c3c:	8b 58 08             	mov    0x8(%eax),%ebx
80101c3f:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101c45:	77 7d                	ja     80101cc4 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c47:	b8 00 00 00 00       	mov    $0x0,%eax
80101c4c:	e8 ae ff ff ff       	call   80101bff <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c51:	b8 00 00 00 00       	mov    $0x0,%eax
80101c56:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c5b:	ee                   	out    %al,(%dx)
80101c5c:	b8 01 00 00 00       	mov    $0x1,%eax
80101c61:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c66:	ee                   	out    %al,(%dx)
80101c67:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c6c:	89 d8                	mov    %ebx,%eax
80101c6e:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c6f:	89 d8                	mov    %ebx,%eax
80101c71:	c1 f8 08             	sar    $0x8,%eax
80101c74:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c79:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c7a:	89 d8                	mov    %ebx,%eax
80101c7c:	c1 f8 10             	sar    $0x10,%eax
80101c7f:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c84:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c85:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c89:	c1 e0 04             	shl    $0x4,%eax
80101c8c:	83 e0 10             	and    $0x10,%eax
80101c8f:	c1 fb 18             	sar    $0x18,%ebx
80101c92:	83 e3 0f             	and    $0xf,%ebx
80101c95:	09 d8                	or     %ebx,%eax
80101c97:	83 c8 e0             	or     $0xffffffe0,%eax
80101c9a:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c9f:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101ca0:	f6 06 04             	testb  $0x4,(%esi)
80101ca3:	75 2c                	jne    80101cd1 <idestart+0xa0>
80101ca5:	b8 20 00 00 00       	mov    $0x20,%eax
80101caa:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101caf:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cb3:	5b                   	pop    %ebx
80101cb4:	5e                   	pop    %esi
80101cb5:	5d                   	pop    %ebp
80101cb6:	c3                   	ret    
    panic("idestart");
80101cb7:	83 ec 0c             	sub    $0xc,%esp
80101cba:	68 cb 68 10 80       	push   $0x801068cb
80101cbf:	e8 84 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 d4 68 10 80       	push   $0x801068d4
80101ccc:	e8 77 e6 ff ff       	call   80100348 <panic>
80101cd1:	b8 30 00 00 00       	mov    $0x30,%eax
80101cd6:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cdb:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cdc:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cdf:	b9 80 00 00 00       	mov    $0x80,%ecx
80101ce4:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101ce9:	fc                   	cld    
80101cea:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101cec:	eb c2                	jmp    80101cb0 <idestart+0x7f>

80101cee <ideinit>:
{
80101cee:	55                   	push   %ebp
80101cef:	89 e5                	mov    %esp,%ebp
80101cf1:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101cf4:	68 e6 68 10 80       	push   $0x801068e6
80101cf9:	68 80 a5 10 80       	push   $0x8010a580
80101cfe:	e8 e3 1d 00 00       	call   80103ae6 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d03:	83 c4 08             	add    $0x8,%esp
80101d06:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80101d0b:	83 e8 01             	sub    $0x1,%eax
80101d0e:	50                   	push   %eax
80101d0f:	6a 0e                	push   $0xe
80101d11:	e8 56 02 00 00       	call   80101f6c <ioapicenable>
  idewait(0);
80101d16:	b8 00 00 00 00       	mov    $0x0,%eax
80101d1b:	e8 df fe ff ff       	call   80101bff <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d20:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d25:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d2a:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d2b:	83 c4 10             	add    $0x10,%esp
80101d2e:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d33:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d39:	7f 19                	jg     80101d54 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d3b:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d40:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d41:	84 c0                	test   %al,%al
80101d43:	75 05                	jne    80101d4a <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d45:	83 c1 01             	add    $0x1,%ecx
80101d48:	eb e9                	jmp    80101d33 <ideinit+0x45>
      havedisk1 = 1;
80101d4a:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101d51:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d54:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d59:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d5e:	ee                   	out    %al,(%dx)
}
80101d5f:	c9                   	leave  
80101d60:	c3                   	ret    

80101d61 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
80101d64:	57                   	push   %edi
80101d65:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	68 80 a5 10 80       	push   $0x8010a580
80101d6e:	e8 af 1e 00 00       	call   80103c22 <acquire>

  if((b = idequeue) == 0){
80101d73:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101d79:	83 c4 10             	add    $0x10,%esp
80101d7c:	85 db                	test   %ebx,%ebx
80101d7e:	74 48                	je     80101dc8 <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d80:	8b 43 58             	mov    0x58(%ebx),%eax
80101d83:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d88:	f6 03 04             	testb  $0x4,(%ebx)
80101d8b:	74 4d                	je     80101dda <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d8d:	8b 03                	mov    (%ebx),%eax
80101d8f:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101d92:	83 e0 fb             	and    $0xfffffffb,%eax
80101d95:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d97:	83 ec 0c             	sub    $0xc,%esp
80101d9a:	53                   	push   %ebx
80101d9b:	e8 e7 1a 00 00       	call   80103887 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101da0:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101da5:	83 c4 10             	add    $0x10,%esp
80101da8:	85 c0                	test   %eax,%eax
80101daa:	74 05                	je     80101db1 <ideintr+0x50>
    idestart(idequeue);
80101dac:	e8 80 fe ff ff       	call   80101c31 <idestart>

  release(&idelock);
80101db1:	83 ec 0c             	sub    $0xc,%esp
80101db4:	68 80 a5 10 80       	push   $0x8010a580
80101db9:	e8 c9 1e 00 00       	call   80103c87 <release>
80101dbe:	83 c4 10             	add    $0x10,%esp
}
80101dc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dc4:	5b                   	pop    %ebx
80101dc5:	5f                   	pop    %edi
80101dc6:	5d                   	pop    %ebp
80101dc7:	c3                   	ret    
    release(&idelock);
80101dc8:	83 ec 0c             	sub    $0xc,%esp
80101dcb:	68 80 a5 10 80       	push   $0x8010a580
80101dd0:	e8 b2 1e 00 00       	call   80103c87 <release>
    return;
80101dd5:	83 c4 10             	add    $0x10,%esp
80101dd8:	eb e7                	jmp    80101dc1 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dda:	b8 01 00 00 00       	mov    $0x1,%eax
80101ddf:	e8 1b fe ff ff       	call   80101bff <idewait>
80101de4:	85 c0                	test   %eax,%eax
80101de6:	78 a5                	js     80101d8d <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101de8:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101deb:	b9 80 00 00 00       	mov    $0x80,%ecx
80101df0:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101df5:	fc                   	cld    
80101df6:	f3 6d                	rep insl (%dx),%es:(%edi)
80101df8:	eb 93                	jmp    80101d8d <ideintr+0x2c>

80101dfa <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101dfa:	55                   	push   %ebp
80101dfb:	89 e5                	mov    %esp,%ebp
80101dfd:	53                   	push   %ebx
80101dfe:	83 ec 10             	sub    $0x10,%esp
80101e01:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e04:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e07:	50                   	push   %eax
80101e08:	e8 8b 1c 00 00       	call   80103a98 <holdingsleep>
80101e0d:	83 c4 10             	add    $0x10,%esp
80101e10:	85 c0                	test   %eax,%eax
80101e12:	74 37                	je     80101e4b <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e14:	8b 03                	mov    (%ebx),%eax
80101e16:	83 e0 06             	and    $0x6,%eax
80101e19:	83 f8 02             	cmp    $0x2,%eax
80101e1c:	74 3a                	je     80101e58 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e1e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e22:	74 09                	je     80101e2d <iderw+0x33>
80101e24:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101e2b:	74 38                	je     80101e65 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e2d:	83 ec 0c             	sub    $0xc,%esp
80101e30:	68 80 a5 10 80       	push   $0x8010a580
80101e35:	e8 e8 1d 00 00       	call   80103c22 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e3a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e49:	eb 2a                	jmp    80101e75 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 ea 68 10 80       	push   $0x801068ea
80101e53:	e8 f0 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e58:	83 ec 0c             	sub    $0xc,%esp
80101e5b:	68 00 69 10 80       	push   $0x80106900
80101e60:	e8 e3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e65:	83 ec 0c             	sub    $0xc,%esp
80101e68:	68 15 69 10 80       	push   $0x80106915
80101e6d:	e8 d6 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e72:	8d 50 58             	lea    0x58(%eax),%edx
80101e75:	8b 02                	mov    (%edx),%eax
80101e77:	85 c0                	test   %eax,%eax
80101e79:	75 f7                	jne    80101e72 <iderw+0x78>
    ;
  *pp = b;
80101e7b:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e7d:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101e83:	75 1a                	jne    80101e9f <iderw+0xa5>
    idestart(b);
80101e85:	89 d8                	mov    %ebx,%eax
80101e87:	e8 a5 fd ff ff       	call   80101c31 <idestart>
80101e8c:	eb 11                	jmp    80101e9f <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e8e:	83 ec 08             	sub    $0x8,%esp
80101e91:	68 80 a5 10 80       	push   $0x8010a580
80101e96:	53                   	push   %ebx
80101e97:	e8 83 18 00 00       	call   8010371f <sleep>
80101e9c:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e9f:	8b 03                	mov    (%ebx),%eax
80101ea1:	83 e0 06             	and    $0x6,%eax
80101ea4:	83 f8 02             	cmp    $0x2,%eax
80101ea7:	75 e5                	jne    80101e8e <iderw+0x94>
  }


  release(&idelock);
80101ea9:	83 ec 0c             	sub    $0xc,%esp
80101eac:	68 80 a5 10 80       	push   $0x8010a580
80101eb1:	e8 d1 1d 00 00       	call   80103c87 <release>
}
80101eb6:	83 c4 10             	add    $0x10,%esp
80101eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ebc:	c9                   	leave  
80101ebd:	c3                   	ret    

80101ebe <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ebe:	55                   	push   %ebp
80101ebf:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ec1:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101ec7:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ec9:	a1 34 26 11 80       	mov    0x80112634,%eax
80101ece:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ed1:	5d                   	pop    %ebp
80101ed2:	c3                   	ret    

80101ed3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ed3:	55                   	push   %ebp
80101ed4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ed6:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101edc:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ede:	a1 34 26 11 80       	mov    0x80112634,%eax
80101ee3:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ee6:	5d                   	pop    %ebp
80101ee7:	c3                   	ret    

80101ee8 <ioapicinit>:

void
ioapicinit(void)
{
80101ee8:	55                   	push   %ebp
80101ee9:	89 e5                	mov    %esp,%ebp
80101eeb:	57                   	push   %edi
80101eec:	56                   	push   %esi
80101eed:	53                   	push   %ebx
80101eee:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101ef1:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
80101ef8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101efb:	b8 01 00 00 00       	mov    $0x1,%eax
80101f00:	e8 b9 ff ff ff       	call   80101ebe <ioapicread>
80101f05:	c1 e8 10             	shr    $0x10,%eax
80101f08:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f0b:	b8 00 00 00 00       	mov    $0x0,%eax
80101f10:	e8 a9 ff ff ff       	call   80101ebe <ioapicread>
80101f15:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f18:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
80101f1f:	39 c2                	cmp    %eax,%edx
80101f21:	75 07                	jne    80101f2a <ioapicinit+0x42>
{
80101f23:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f28:	eb 36                	jmp    80101f60 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f2a:	83 ec 0c             	sub    $0xc,%esp
80101f2d:	68 34 69 10 80       	push   $0x80106934
80101f32:	e8 d4 e6 ff ff       	call   8010060b <cprintf>
80101f37:	83 c4 10             	add    $0x10,%esp
80101f3a:	eb e7                	jmp    80101f23 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f3c:	8d 53 20             	lea    0x20(%ebx),%edx
80101f3f:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f45:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f49:	89 f0                	mov    %esi,%eax
80101f4b:	e8 83 ff ff ff       	call   80101ed3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f50:	8d 46 01             	lea    0x1(%esi),%eax
80101f53:	ba 00 00 00 00       	mov    $0x0,%edx
80101f58:	e8 76 ff ff ff       	call   80101ed3 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f5d:	83 c3 01             	add    $0x1,%ebx
80101f60:	39 fb                	cmp    %edi,%ebx
80101f62:	7e d8                	jle    80101f3c <ioapicinit+0x54>
  }
}
80101f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f67:	5b                   	pop    %ebx
80101f68:	5e                   	pop    %esi
80101f69:	5f                   	pop    %edi
80101f6a:	5d                   	pop    %ebp
80101f6b:	c3                   	ret    

80101f6c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f6c:	55                   	push   %ebp
80101f6d:	89 e5                	mov    %esp,%ebp
80101f6f:	53                   	push   %ebx
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f73:	8d 50 20             	lea    0x20(%eax),%edx
80101f76:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f7a:	89 d8                	mov    %ebx,%eax
80101f7c:	e8 52 ff ff ff       	call   80101ed3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f84:	c1 e2 18             	shl    $0x18,%edx
80101f87:	8d 43 01             	lea    0x1(%ebx),%eax
80101f8a:	e8 44 ff ff ff       	call   80101ed3 <ioapicwrite>
}
80101f8f:	5b                   	pop    %ebx
80101f90:	5d                   	pop    %ebp
80101f91:	c3                   	ret    

80101f92 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f92:	55                   	push   %ebp
80101f93:	89 e5                	mov    %esp,%ebp
80101f95:	53                   	push   %ebx
80101f96:	83 ec 04             	sub    $0x4,%esp
80101f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f9c:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fa2:	75 61                	jne    80102005 <kfree+0x73>
80101fa4:	81 fb a8 56 11 80    	cmp    $0x801156a8,%ebx
80101faa:	72 59                	jb     80102005 <kfree+0x73>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
80101fac:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80101fb2:	76 44                	jbe    80101ff8 <kfree+0x66>
        panic("V2P on address < KERNBASE "
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
80101fb4:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fba:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fbf:	77 44                	ja     80102005 <kfree+0x73>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fc1:	83 ec 04             	sub    $0x4,%esp
80101fc4:	68 00 10 00 00       	push   $0x1000
80101fc9:	6a 01                	push   $0x1
80101fcb:	53                   	push   %ebx
80101fcc:	e8 fd 1c 00 00       	call   80103cce <memset>

  if(kmem.use_lock)
80101fd1:	83 c4 10             	add    $0x10,%esp
80101fd4:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101fdb:	75 35                	jne    80102012 <kfree+0x80>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fdd:	a1 78 26 11 80       	mov    0x80112678,%eax
80101fe2:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fe4:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
80101fea:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101ff1:	75 31                	jne    80102024 <kfree+0x92>
    release(&kmem.lock);
}
80101ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ff6:	c9                   	leave  
80101ff7:	c3                   	ret    
        panic("V2P on address < KERNBASE "
80101ff8:	83 ec 0c             	sub    $0xc,%esp
80101ffb:	68 68 69 10 80       	push   $0x80106968
80102000:	e8 43 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80102005:	83 ec 0c             	sub    $0xc,%esp
80102008:	68 f6 69 10 80       	push   $0x801069f6
8010200d:	e8 36 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102012:	83 ec 0c             	sub    $0xc,%esp
80102015:	68 40 26 11 80       	push   $0x80112640
8010201a:	e8 03 1c 00 00       	call   80103c22 <acquire>
8010201f:	83 c4 10             	add    $0x10,%esp
80102022:	eb b9                	jmp    80101fdd <kfree+0x4b>
    release(&kmem.lock);
80102024:	83 ec 0c             	sub    $0xc,%esp
80102027:	68 40 26 11 80       	push   $0x80112640
8010202c:	e8 56 1c 00 00       	call   80103c87 <release>
80102031:	83 c4 10             	add    $0x10,%esp
}
80102034:	eb bd                	jmp    80101ff3 <kfree+0x61>

80102036 <freerange>:
{
80102036:	55                   	push   %ebp
80102037:	89 e5                	mov    %esp,%ebp
80102039:	56                   	push   %esi
8010203a:	53                   	push   %ebx
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (vend < vstart) panic("freerange");
80102041:	39 c3                	cmp    %eax,%ebx
80102043:	72 0c                	jb     80102051 <freerange+0x1b>
  p = (char*)PGROUNDUP((uint)vstart);
80102045:	05 ff 0f 00 00       	add    $0xfff,%eax
8010204a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010204f:	eb 1b                	jmp    8010206c <freerange+0x36>
  if (vend < vstart) panic("freerange");
80102051:	83 ec 0c             	sub    $0xc,%esp
80102054:	68 fc 69 10 80       	push   $0x801069fc
80102059:	e8 ea e2 ff ff       	call   80100348 <panic>
    kfree(p);
8010205e:	83 ec 0c             	sub    $0xc,%esp
80102061:	50                   	push   %eax
80102062:	e8 2b ff ff ff       	call   80101f92 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	89 f0                	mov    %esi,%eax
8010206c:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80102072:	39 de                	cmp    %ebx,%esi
80102074:	76 e8                	jbe    8010205e <freerange+0x28>
}
80102076:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102079:	5b                   	pop    %ebx
8010207a:	5e                   	pop    %esi
8010207b:	5d                   	pop    %ebp
8010207c:	c3                   	ret    

8010207d <kinit1>:
{
8010207d:	55                   	push   %ebp
8010207e:	89 e5                	mov    %esp,%ebp
80102080:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80102083:	68 06 6a 10 80       	push   $0x80106a06
80102088:	68 40 26 11 80       	push   $0x80112640
8010208d:	e8 54 1a 00 00       	call   80103ae6 <initlock>
  kmem.use_lock = 0;
80102092:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102099:	00 00 00 
  freerange(vstart, vend);
8010209c:	83 c4 08             	add    $0x8,%esp
8010209f:	ff 75 0c             	pushl  0xc(%ebp)
801020a2:	ff 75 08             	pushl  0x8(%ebp)
801020a5:	e8 8c ff ff ff       	call   80102036 <freerange>
}
801020aa:	83 c4 10             	add    $0x10,%esp
801020ad:	c9                   	leave  
801020ae:	c3                   	ret    

801020af <kinit2>:
{
801020af:	55                   	push   %ebp
801020b0:	89 e5                	mov    %esp,%ebp
801020b2:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020b5:	ff 75 0c             	pushl  0xc(%ebp)
801020b8:	ff 75 08             	pushl  0x8(%ebp)
801020bb:	e8 76 ff ff ff       	call   80102036 <freerange>
  kmem.use_lock = 1;
801020c0:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
801020c7:	00 00 00 
}
801020ca:	83 c4 10             	add    $0x10,%esp
801020cd:	c9                   	leave  
801020ce:	c3                   	ret    

801020cf <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020cf:	55                   	push   %ebp
801020d0:	89 e5                	mov    %esp,%ebp
801020d2:	53                   	push   %ebx
801020d3:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020d6:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801020dd:	75 21                	jne    80102100 <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020df:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
801020e5:	85 db                	test   %ebx,%ebx
801020e7:	74 07                	je     801020f0 <kalloc+0x21>
    kmem.freelist = r->next;
801020e9:	8b 03                	mov    (%ebx),%eax
801020eb:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
801020f0:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801020f7:	75 19                	jne    80102112 <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020f9:	89 d8                	mov    %ebx,%eax
801020fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020fe:	c9                   	leave  
801020ff:	c3                   	ret    
    acquire(&kmem.lock);
80102100:	83 ec 0c             	sub    $0xc,%esp
80102103:	68 40 26 11 80       	push   $0x80112640
80102108:	e8 15 1b 00 00       	call   80103c22 <acquire>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	eb cd                	jmp    801020df <kalloc+0x10>
    release(&kmem.lock);
80102112:	83 ec 0c             	sub    $0xc,%esp
80102115:	68 40 26 11 80       	push   $0x80112640
8010211a:	e8 68 1b 00 00       	call   80103c87 <release>
8010211f:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102122:	eb d5                	jmp    801020f9 <kalloc+0x2a>

80102124 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102124:	55                   	push   %ebp
80102125:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102127:	ba 64 00 00 00       	mov    $0x64,%edx
8010212c:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010212d:	a8 01                	test   $0x1,%al
8010212f:	0f 84 b5 00 00 00    	je     801021ea <kbdgetc+0xc6>
80102135:	ba 60 00 00 00       	mov    $0x60,%edx
8010213a:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
8010213b:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010213e:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102144:	74 5c                	je     801021a2 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102146:	84 c0                	test   %al,%al
80102148:	78 66                	js     801021b0 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010214a:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102150:	f6 c1 40             	test   $0x40,%cl
80102153:	74 0f                	je     80102164 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102155:	83 c8 80             	or     $0xffffff80,%eax
80102158:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
8010215b:	83 e1 bf             	and    $0xffffffbf,%ecx
8010215e:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102164:	0f b6 8a 40 6b 10 80 	movzbl -0x7fef94c0(%edx),%ecx
8010216b:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
80102171:	0f b6 82 40 6a 10 80 	movzbl -0x7fef95c0(%edx),%eax
80102178:	31 c1                	xor    %eax,%ecx
8010217a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102180:	89 c8                	mov    %ecx,%eax
80102182:	83 e0 03             	and    $0x3,%eax
80102185:	8b 04 85 20 6a 10 80 	mov    -0x7fef95e0(,%eax,4),%eax
8010218c:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102190:	f6 c1 08             	test   $0x8,%cl
80102193:	74 19                	je     801021ae <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102195:	8d 50 9f             	lea    -0x61(%eax),%edx
80102198:	83 fa 19             	cmp    $0x19,%edx
8010219b:	77 40                	ja     801021dd <kbdgetc+0xb9>
      c += 'A' - 'a';
8010219d:	83 e8 20             	sub    $0x20,%eax
801021a0:	eb 0c                	jmp    801021ae <kbdgetc+0x8a>
    shift |= E0ESC;
801021a2:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
801021a9:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801021ae:	5d                   	pop    %ebp
801021af:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021b0:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801021b6:	f6 c1 40             	test   $0x40,%cl
801021b9:	75 05                	jne    801021c0 <kbdgetc+0x9c>
801021bb:	89 c2                	mov    %eax,%edx
801021bd:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801021c0:	0f b6 82 40 6b 10 80 	movzbl -0x7fef94c0(%edx),%eax
801021c7:	83 c8 40             	or     $0x40,%eax
801021ca:	0f b6 c0             	movzbl %al,%eax
801021cd:	f7 d0                	not    %eax
801021cf:	21 c8                	and    %ecx,%eax
801021d1:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
801021d6:	b8 00 00 00 00       	mov    $0x0,%eax
801021db:	eb d1                	jmp    801021ae <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801021dd:	8d 50 bf             	lea    -0x41(%eax),%edx
801021e0:	83 fa 19             	cmp    $0x19,%edx
801021e3:	77 c9                	ja     801021ae <kbdgetc+0x8a>
      c += 'a' - 'A';
801021e5:	83 c0 20             	add    $0x20,%eax
  return c;
801021e8:	eb c4                	jmp    801021ae <kbdgetc+0x8a>
    return -1;
801021ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ef:	eb bd                	jmp    801021ae <kbdgetc+0x8a>

801021f1 <kbdintr>:

void
kbdintr(void)
{
801021f1:	55                   	push   %ebp
801021f2:	89 e5                	mov    %esp,%ebp
801021f4:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021f7:	68 24 21 10 80       	push   $0x80102124
801021fc:	e8 3d e5 ff ff       	call   8010073e <consoleintr>
}
80102201:	83 c4 10             	add    $0x10,%esp
80102204:	c9                   	leave  
80102205:	c3                   	ret    

80102206 <shutdown>:
#include "types.h"
#include "x86.h"

void
shutdown(void)
{
80102206:	55                   	push   %ebp
80102207:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102209:	b8 00 00 00 00       	mov    $0x0,%eax
8010220e:	ba 01 05 00 00       	mov    $0x501,%edx
80102213:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
80102214:	5d                   	pop    %ebp
80102215:	c3                   	ret    

80102216 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102216:	55                   	push   %ebp
80102217:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102219:	8b 0d 7c 26 11 80    	mov    0x8011267c,%ecx
8010221f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102222:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102224:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102229:	8b 40 20             	mov    0x20(%eax),%eax
}
8010222c:	5d                   	pop    %ebp
8010222d:	c3                   	ret    

8010222e <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010222e:	55                   	push   %ebp
8010222f:	89 e5                	mov    %esp,%ebp
80102231:	ba 70 00 00 00       	mov    $0x70,%edx
80102236:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102237:	ba 71 00 00 00       	mov    $0x71,%edx
8010223c:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010223d:	0f b6 c0             	movzbl %al,%eax
}
80102240:	5d                   	pop    %ebp
80102241:	c3                   	ret    

80102242 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102242:	55                   	push   %ebp
80102243:	89 e5                	mov    %esp,%ebp
80102245:	53                   	push   %ebx
80102246:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102248:	b8 00 00 00 00       	mov    $0x0,%eax
8010224d:	e8 dc ff ff ff       	call   8010222e <cmos_read>
80102252:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102254:	b8 02 00 00 00       	mov    $0x2,%eax
80102259:	e8 d0 ff ff ff       	call   8010222e <cmos_read>
8010225e:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102261:	b8 04 00 00 00       	mov    $0x4,%eax
80102266:	e8 c3 ff ff ff       	call   8010222e <cmos_read>
8010226b:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010226e:	b8 07 00 00 00       	mov    $0x7,%eax
80102273:	e8 b6 ff ff ff       	call   8010222e <cmos_read>
80102278:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
8010227b:	b8 08 00 00 00       	mov    $0x8,%eax
80102280:	e8 a9 ff ff ff       	call   8010222e <cmos_read>
80102285:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102288:	b8 09 00 00 00       	mov    $0x9,%eax
8010228d:	e8 9c ff ff ff       	call   8010222e <cmos_read>
80102292:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102295:	5b                   	pop    %ebx
80102296:	5d                   	pop    %ebp
80102297:	c3                   	ret    

80102298 <lapicinit>:
  if(!lapic)
80102298:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
8010229f:	0f 84 fb 00 00 00    	je     801023a0 <lapicinit+0x108>
{
801022a5:	55                   	push   %ebp
801022a6:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801022a8:	ba 3f 01 00 00       	mov    $0x13f,%edx
801022ad:	b8 3c 00 00 00       	mov    $0x3c,%eax
801022b2:	e8 5f ff ff ff       	call   80102216 <lapicw>
  lapicw(TDCR, X1);
801022b7:	ba 0b 00 00 00       	mov    $0xb,%edx
801022bc:	b8 f8 00 00 00       	mov    $0xf8,%eax
801022c1:	e8 50 ff ff ff       	call   80102216 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022c6:	ba 20 00 02 00       	mov    $0x20020,%edx
801022cb:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022d0:	e8 41 ff ff ff       	call   80102216 <lapicw>
  lapicw(TICR, 10000000);
801022d5:	ba 80 96 98 00       	mov    $0x989680,%edx
801022da:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022df:	e8 32 ff ff ff       	call   80102216 <lapicw>
  lapicw(LINT0, MASKED);
801022e4:	ba 00 00 01 00       	mov    $0x10000,%edx
801022e9:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022ee:	e8 23 ff ff ff       	call   80102216 <lapicw>
  lapicw(LINT1, MASKED);
801022f3:	ba 00 00 01 00       	mov    $0x10000,%edx
801022f8:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022fd:	e8 14 ff ff ff       	call   80102216 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102302:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102307:	8b 40 30             	mov    0x30(%eax),%eax
8010230a:	c1 e8 10             	shr    $0x10,%eax
8010230d:	3c 03                	cmp    $0x3,%al
8010230f:	77 7b                	ja     8010238c <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102311:	ba 33 00 00 00       	mov    $0x33,%edx
80102316:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010231b:	e8 f6 fe ff ff       	call   80102216 <lapicw>
  lapicw(ESR, 0);
80102320:	ba 00 00 00 00       	mov    $0x0,%edx
80102325:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010232a:	e8 e7 fe ff ff       	call   80102216 <lapicw>
  lapicw(ESR, 0);
8010232f:	ba 00 00 00 00       	mov    $0x0,%edx
80102334:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102339:	e8 d8 fe ff ff       	call   80102216 <lapicw>
  lapicw(EOI, 0);
8010233e:	ba 00 00 00 00       	mov    $0x0,%edx
80102343:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102348:	e8 c9 fe ff ff       	call   80102216 <lapicw>
  lapicw(ICRHI, 0);
8010234d:	ba 00 00 00 00       	mov    $0x0,%edx
80102352:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102357:	e8 ba fe ff ff       	call   80102216 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010235c:	ba 00 85 08 00       	mov    $0x88500,%edx
80102361:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102366:	e8 ab fe ff ff       	call   80102216 <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010236b:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102370:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102376:	f6 c4 10             	test   $0x10,%ah
80102379:	75 f0                	jne    8010236b <lapicinit+0xd3>
  lapicw(TPR, 0);
8010237b:	ba 00 00 00 00       	mov    $0x0,%edx
80102380:	b8 20 00 00 00       	mov    $0x20,%eax
80102385:	e8 8c fe ff ff       	call   80102216 <lapicw>
}
8010238a:	5d                   	pop    %ebp
8010238b:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010238c:	ba 00 00 01 00       	mov    $0x10000,%edx
80102391:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102396:	e8 7b fe ff ff       	call   80102216 <lapicw>
8010239b:	e9 71 ff ff ff       	jmp    80102311 <lapicinit+0x79>
801023a0:	f3 c3                	repz ret 

801023a2 <lapicid>:
{
801023a2:	55                   	push   %ebp
801023a3:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801023a5:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801023aa:	85 c0                	test   %eax,%eax
801023ac:	74 08                	je     801023b6 <lapicid+0x14>
  return lapic[ID] >> 24;
801023ae:	8b 40 20             	mov    0x20(%eax),%eax
801023b1:	c1 e8 18             	shr    $0x18,%eax
}
801023b4:	5d                   	pop    %ebp
801023b5:	c3                   	ret    
    return 0;
801023b6:	b8 00 00 00 00       	mov    $0x0,%eax
801023bb:	eb f7                	jmp    801023b4 <lapicid+0x12>

801023bd <lapiceoi>:
  if(lapic)
801023bd:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
801023c4:	74 14                	je     801023da <lapiceoi+0x1d>
{
801023c6:	55                   	push   %ebp
801023c7:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801023c9:	ba 00 00 00 00       	mov    $0x0,%edx
801023ce:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023d3:	e8 3e fe ff ff       	call   80102216 <lapicw>
}
801023d8:	5d                   	pop    %ebp
801023d9:	c3                   	ret    
801023da:	f3 c3                	repz ret 

801023dc <microdelay>:
{
801023dc:	55                   	push   %ebp
801023dd:	89 e5                	mov    %esp,%ebp
}
801023df:	5d                   	pop    %ebp
801023e0:	c3                   	ret    

801023e1 <lapicstartap>:
{
801023e1:	55                   	push   %ebp
801023e2:	89 e5                	mov    %esp,%ebp
801023e4:	57                   	push   %edi
801023e5:	56                   	push   %esi
801023e6:	53                   	push   %ebx
801023e7:	8b 75 08             	mov    0x8(%ebp),%esi
801023ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023ed:	b8 0f 00 00 00       	mov    $0xf,%eax
801023f2:	ba 70 00 00 00       	mov    $0x70,%edx
801023f7:	ee                   	out    %al,(%dx)
801023f8:	b8 0a 00 00 00       	mov    $0xa,%eax
801023fd:	ba 71 00 00 00       	mov    $0x71,%edx
80102402:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102403:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010240a:	00 00 
  wrv[1] = addr >> 4;
8010240c:	89 f8                	mov    %edi,%eax
8010240e:	c1 e8 04             	shr    $0x4,%eax
80102411:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102417:	c1 e6 18             	shl    $0x18,%esi
8010241a:	89 f2                	mov    %esi,%edx
8010241c:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102421:	e8 f0 fd ff ff       	call   80102216 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102426:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010242b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102430:	e8 e1 fd ff ff       	call   80102216 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102435:	ba 00 85 00 00       	mov    $0x8500,%edx
8010243a:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010243f:	e8 d2 fd ff ff       	call   80102216 <lapicw>
  for(i = 0; i < 2; i++){
80102444:	bb 00 00 00 00       	mov    $0x0,%ebx
80102449:	eb 21                	jmp    8010246c <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
8010244b:	89 f2                	mov    %esi,%edx
8010244d:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102452:	e8 bf fd ff ff       	call   80102216 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102457:	89 fa                	mov    %edi,%edx
80102459:	c1 ea 0c             	shr    $0xc,%edx
8010245c:	80 ce 06             	or     $0x6,%dh
8010245f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102464:	e8 ad fd ff ff       	call   80102216 <lapicw>
  for(i = 0; i < 2; i++){
80102469:	83 c3 01             	add    $0x1,%ebx
8010246c:	83 fb 01             	cmp    $0x1,%ebx
8010246f:	7e da                	jle    8010244b <lapicstartap+0x6a>
}
80102471:	5b                   	pop    %ebx
80102472:	5e                   	pop    %esi
80102473:	5f                   	pop    %edi
80102474:	5d                   	pop    %ebp
80102475:	c3                   	ret    

80102476 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102476:	55                   	push   %ebp
80102477:	89 e5                	mov    %esp,%ebp
80102479:	57                   	push   %edi
8010247a:	56                   	push   %esi
8010247b:	53                   	push   %ebx
8010247c:	83 ec 3c             	sub    $0x3c,%esp
8010247f:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102482:	b8 0b 00 00 00       	mov    $0xb,%eax
80102487:	e8 a2 fd ff ff       	call   8010222e <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010248c:	83 e0 04             	and    $0x4,%eax
8010248f:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102491:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102494:	e8 a9 fd ff ff       	call   80102242 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102499:	b8 0a 00 00 00       	mov    $0xa,%eax
8010249e:	e8 8b fd ff ff       	call   8010222e <cmos_read>
801024a3:	a8 80                	test   $0x80,%al
801024a5:	75 ea                	jne    80102491 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801024a7:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801024aa:	89 d8                	mov    %ebx,%eax
801024ac:	e8 91 fd ff ff       	call   80102242 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801024b1:	83 ec 04             	sub    $0x4,%esp
801024b4:	6a 18                	push   $0x18
801024b6:	53                   	push   %ebx
801024b7:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024ba:	50                   	push   %eax
801024bb:	e8 54 18 00 00       	call   80103d14 <memcmp>
801024c0:	83 c4 10             	add    $0x10,%esp
801024c3:	85 c0                	test   %eax,%eax
801024c5:	75 ca                	jne    80102491 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024c7:	85 ff                	test   %edi,%edi
801024c9:	0f 85 84 00 00 00    	jne    80102553 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
801024d2:	89 d0                	mov    %edx,%eax
801024d4:	c1 e8 04             	shr    $0x4,%eax
801024d7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024da:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024dd:	83 e2 0f             	and    $0xf,%edx
801024e0:	01 d0                	add    %edx,%eax
801024e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801024e8:	89 d0                	mov    %edx,%eax
801024ea:	c1 e8 04             	shr    $0x4,%eax
801024ed:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024f0:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024f3:	83 e2 0f             	and    $0xf,%edx
801024f6:	01 d0                	add    %edx,%eax
801024f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801024fe:	89 d0                	mov    %edx,%eax
80102500:	c1 e8 04             	shr    $0x4,%eax
80102503:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102506:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102509:	83 e2 0f             	and    $0xf,%edx
8010250c:	01 d0                	add    %edx,%eax
8010250e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102511:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102514:	89 d0                	mov    %edx,%eax
80102516:	c1 e8 04             	shr    $0x4,%eax
80102519:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010251c:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010251f:	83 e2 0f             	and    $0xf,%edx
80102522:	01 d0                	add    %edx,%eax
80102524:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102527:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010252a:	89 d0                	mov    %edx,%eax
8010252c:	c1 e8 04             	shr    $0x4,%eax
8010252f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102532:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102535:	83 e2 0f             	and    $0xf,%edx
80102538:	01 d0                	add    %edx,%eax
8010253a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010253d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102540:	89 d0                	mov    %edx,%eax
80102542:	c1 e8 04             	shr    $0x4,%eax
80102545:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102548:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010254b:	83 e2 0f             	and    $0xf,%edx
8010254e:	01 d0                	add    %edx,%eax
80102550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102553:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102556:	89 06                	mov    %eax,(%esi)
80102558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010255b:	89 46 04             	mov    %eax,0x4(%esi)
8010255e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102561:	89 46 08             	mov    %eax,0x8(%esi)
80102564:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102567:	89 46 0c             	mov    %eax,0xc(%esi)
8010256a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010256d:	89 46 10             	mov    %eax,0x10(%esi)
80102570:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102573:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102576:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010257d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102580:	5b                   	pop    %ebx
80102581:	5e                   	pop    %esi
80102582:	5f                   	pop    %edi
80102583:	5d                   	pop    %ebp
80102584:	c3                   	ret    

80102585 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102585:	55                   	push   %ebp
80102586:	89 e5                	mov    %esp,%ebp
80102588:	53                   	push   %ebx
80102589:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010258c:	ff 35 b4 26 11 80    	pushl  0x801126b4
80102592:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102598:	e8 cf db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010259d:	8b 58 5c             	mov    0x5c(%eax),%ebx
801025a0:	89 1d c8 26 11 80    	mov    %ebx,0x801126c8
  for (i = 0; i < log.lh.n; i++) {
801025a6:	83 c4 10             	add    $0x10,%esp
801025a9:	ba 00 00 00 00       	mov    $0x0,%edx
801025ae:	eb 0e                	jmp    801025be <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801025b0:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801025b4:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801025bb:	83 c2 01             	add    $0x1,%edx
801025be:	39 d3                	cmp    %edx,%ebx
801025c0:	7f ee                	jg     801025b0 <read_head+0x2b>
  }
  brelse(buf);
801025c2:	83 ec 0c             	sub    $0xc,%esp
801025c5:	50                   	push   %eax
801025c6:	e8 0a dc ff ff       	call   801001d5 <brelse>
}
801025cb:	83 c4 10             	add    $0x10,%esp
801025ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025d1:	c9                   	leave  
801025d2:	c3                   	ret    

801025d3 <install_trans>:
{
801025d3:	55                   	push   %ebp
801025d4:	89 e5                	mov    %esp,%ebp
801025d6:	57                   	push   %edi
801025d7:	56                   	push   %esi
801025d8:	53                   	push   %ebx
801025d9:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025dc:	bb 00 00 00 00       	mov    $0x0,%ebx
801025e1:	eb 66                	jmp    80102649 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025e3:	89 d8                	mov    %ebx,%eax
801025e5:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801025eb:	83 c0 01             	add    $0x1,%eax
801025ee:	83 ec 08             	sub    $0x8,%esp
801025f1:	50                   	push   %eax
801025f2:	ff 35 c4 26 11 80    	pushl  0x801126c4
801025f8:	e8 6f db ff ff       	call   8010016c <bread>
801025fd:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025ff:	83 c4 08             	add    $0x8,%esp
80102602:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
80102609:	ff 35 c4 26 11 80    	pushl  0x801126c4
8010260f:	e8 58 db ff ff       	call   8010016c <bread>
80102614:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102616:	8d 57 5c             	lea    0x5c(%edi),%edx
80102619:	8d 40 5c             	lea    0x5c(%eax),%eax
8010261c:	83 c4 0c             	add    $0xc,%esp
8010261f:	68 00 02 00 00       	push   $0x200
80102624:	52                   	push   %edx
80102625:	50                   	push   %eax
80102626:	e8 1e 17 00 00       	call   80103d49 <memmove>
    bwrite(dbuf);  // write dst to disk
8010262b:	89 34 24             	mov    %esi,(%esp)
8010262e:	e8 67 db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102633:	89 3c 24             	mov    %edi,(%esp)
80102636:	e8 9a db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
8010263b:	89 34 24             	mov    %esi,(%esp)
8010263e:	e8 92 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102643:	83 c3 01             	add    $0x1,%ebx
80102646:	83 c4 10             	add    $0x10,%esp
80102649:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
8010264f:	7f 92                	jg     801025e3 <install_trans+0x10>
}
80102651:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102654:	5b                   	pop    %ebx
80102655:	5e                   	pop    %esi
80102656:	5f                   	pop    %edi
80102657:	5d                   	pop    %ebp
80102658:	c3                   	ret    

80102659 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102659:	55                   	push   %ebp
8010265a:	89 e5                	mov    %esp,%ebp
8010265c:	53                   	push   %ebx
8010265d:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102660:	ff 35 b4 26 11 80    	pushl  0x801126b4
80102666:	ff 35 c4 26 11 80    	pushl  0x801126c4
8010266c:	e8 fb da ff ff       	call   8010016c <bread>
80102671:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102673:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
80102679:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010267c:	83 c4 10             	add    $0x10,%esp
8010267f:	b8 00 00 00 00       	mov    $0x0,%eax
80102684:	eb 0e                	jmp    80102694 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102686:	8b 14 85 cc 26 11 80 	mov    -0x7feed934(,%eax,4),%edx
8010268d:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102691:	83 c0 01             	add    $0x1,%eax
80102694:	39 c1                	cmp    %eax,%ecx
80102696:	7f ee                	jg     80102686 <write_head+0x2d>
  }
  bwrite(buf);
80102698:	83 ec 0c             	sub    $0xc,%esp
8010269b:	53                   	push   %ebx
8010269c:	e8 f9 da ff ff       	call   8010019a <bwrite>
  brelse(buf);
801026a1:	89 1c 24             	mov    %ebx,(%esp)
801026a4:	e8 2c db ff ff       	call   801001d5 <brelse>
}
801026a9:	83 c4 10             	add    $0x10,%esp
801026ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026af:	c9                   	leave  
801026b0:	c3                   	ret    

801026b1 <recover_from_log>:

static void
recover_from_log(void)
{
801026b1:	55                   	push   %ebp
801026b2:	89 e5                	mov    %esp,%ebp
801026b4:	83 ec 08             	sub    $0x8,%esp
  read_head();
801026b7:	e8 c9 fe ff ff       	call   80102585 <read_head>
  install_trans(); // if committed, copy from log to disk
801026bc:	e8 12 ff ff ff       	call   801025d3 <install_trans>
  log.lh.n = 0;
801026c1:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
801026c8:	00 00 00 
  write_head(); // clear the log
801026cb:	e8 89 ff ff ff       	call   80102659 <write_head>
}
801026d0:	c9                   	leave  
801026d1:	c3                   	ret    

801026d2 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026d2:	55                   	push   %ebp
801026d3:	89 e5                	mov    %esp,%ebp
801026d5:	57                   	push   %edi
801026d6:	56                   	push   %esi
801026d7:	53                   	push   %ebx
801026d8:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026db:	bb 00 00 00 00       	mov    $0x0,%ebx
801026e0:	eb 66                	jmp    80102748 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026e2:	89 d8                	mov    %ebx,%eax
801026e4:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801026ea:	83 c0 01             	add    $0x1,%eax
801026ed:	83 ec 08             	sub    $0x8,%esp
801026f0:	50                   	push   %eax
801026f1:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026f7:	e8 70 da ff ff       	call   8010016c <bread>
801026fc:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026fe:	83 c4 08             	add    $0x8,%esp
80102701:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
80102708:	ff 35 c4 26 11 80    	pushl  0x801126c4
8010270e:	e8 59 da ff ff       	call   8010016c <bread>
80102713:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102715:	8d 50 5c             	lea    0x5c(%eax),%edx
80102718:	8d 46 5c             	lea    0x5c(%esi),%eax
8010271b:	83 c4 0c             	add    $0xc,%esp
8010271e:	68 00 02 00 00       	push   $0x200
80102723:	52                   	push   %edx
80102724:	50                   	push   %eax
80102725:	e8 1f 16 00 00       	call   80103d49 <memmove>
    bwrite(to);  // write the log
8010272a:	89 34 24             	mov    %esi,(%esp)
8010272d:	e8 68 da ff ff       	call   8010019a <bwrite>
    brelse(from);
80102732:	89 3c 24             	mov    %edi,(%esp)
80102735:	e8 9b da ff ff       	call   801001d5 <brelse>
    brelse(to);
8010273a:	89 34 24             	mov    %esi,(%esp)
8010273d:	e8 93 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102742:	83 c3 01             	add    $0x1,%ebx
80102745:	83 c4 10             	add    $0x10,%esp
80102748:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
8010274e:	7f 92                	jg     801026e2 <write_log+0x10>
  }
}
80102750:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102753:	5b                   	pop    %ebx
80102754:	5e                   	pop    %esi
80102755:	5f                   	pop    %edi
80102756:	5d                   	pop    %ebp
80102757:	c3                   	ret    

80102758 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102758:	83 3d c8 26 11 80 00 	cmpl   $0x0,0x801126c8
8010275f:	7e 26                	jle    80102787 <commit+0x2f>
{
80102761:	55                   	push   %ebp
80102762:	89 e5                	mov    %esp,%ebp
80102764:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102767:	e8 66 ff ff ff       	call   801026d2 <write_log>
    write_head();    // Write header to disk -- the real commit
8010276c:	e8 e8 fe ff ff       	call   80102659 <write_head>
    install_trans(); // Now install writes to home locations
80102771:	e8 5d fe ff ff       	call   801025d3 <install_trans>
    log.lh.n = 0;
80102776:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
8010277d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102780:	e8 d4 fe ff ff       	call   80102659 <write_head>
  }
}
80102785:	c9                   	leave  
80102786:	c3                   	ret    
80102787:	f3 c3                	repz ret 

80102789 <initlog>:
{
80102789:	55                   	push   %ebp
8010278a:	89 e5                	mov    %esp,%ebp
8010278c:	53                   	push   %ebx
8010278d:	83 ec 2c             	sub    $0x2c,%esp
80102790:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102793:	68 40 6c 10 80       	push   $0x80106c40
80102798:	68 80 26 11 80       	push   $0x80112680
8010279d:	e8 44 13 00 00       	call   80103ae6 <initlock>
  readsb(dev, &sb);
801027a2:	83 c4 08             	add    $0x8,%esp
801027a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801027a8:	50                   	push   %eax
801027a9:	53                   	push   %ebx
801027aa:	e8 f7 ea ff ff       	call   801012a6 <readsb>
  log.start = sb.logstart;
801027af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027b2:	a3 b4 26 11 80       	mov    %eax,0x801126b4
  log.size = sb.nlog;
801027b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027ba:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  log.dev = dev;
801027bf:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4
  recover_from_log();
801027c5:	e8 e7 fe ff ff       	call   801026b1 <recover_from_log>
}
801027ca:	83 c4 10             	add    $0x10,%esp
801027cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027d0:	c9                   	leave  
801027d1:	c3                   	ret    

801027d2 <begin_op>:
{
801027d2:	55                   	push   %ebp
801027d3:	89 e5                	mov    %esp,%ebp
801027d5:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027d8:	68 80 26 11 80       	push   $0x80112680
801027dd:	e8 40 14 00 00       	call   80103c22 <acquire>
801027e2:	83 c4 10             	add    $0x10,%esp
801027e5:	eb 15                	jmp    801027fc <begin_op+0x2a>
      sleep(&log, &log.lock);
801027e7:	83 ec 08             	sub    $0x8,%esp
801027ea:	68 80 26 11 80       	push   $0x80112680
801027ef:	68 80 26 11 80       	push   $0x80112680
801027f4:	e8 26 0f 00 00       	call   8010371f <sleep>
801027f9:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027fc:	83 3d c0 26 11 80 00 	cmpl   $0x0,0x801126c0
80102803:	75 e2                	jne    801027e7 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102805:	a1 bc 26 11 80       	mov    0x801126bc,%eax
8010280a:	83 c0 01             	add    $0x1,%eax
8010280d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102810:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102813:	03 15 c8 26 11 80    	add    0x801126c8,%edx
80102819:	83 fa 1e             	cmp    $0x1e,%edx
8010281c:	7e 17                	jle    80102835 <begin_op+0x63>
      sleep(&log, &log.lock);
8010281e:	83 ec 08             	sub    $0x8,%esp
80102821:	68 80 26 11 80       	push   $0x80112680
80102826:	68 80 26 11 80       	push   $0x80112680
8010282b:	e8 ef 0e 00 00       	call   8010371f <sleep>
80102830:	83 c4 10             	add    $0x10,%esp
80102833:	eb c7                	jmp    801027fc <begin_op+0x2a>
      log.outstanding += 1;
80102835:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	68 80 26 11 80       	push   $0x80112680
80102842:	e8 40 14 00 00       	call   80103c87 <release>
}
80102847:	83 c4 10             	add    $0x10,%esp
8010284a:	c9                   	leave  
8010284b:	c3                   	ret    

8010284c <end_op>:
{
8010284c:	55                   	push   %ebp
8010284d:	89 e5                	mov    %esp,%ebp
8010284f:	53                   	push   %ebx
80102850:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102853:	68 80 26 11 80       	push   $0x80112680
80102858:	e8 c5 13 00 00       	call   80103c22 <acquire>
  log.outstanding -= 1;
8010285d:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102862:	83 e8 01             	sub    $0x1,%eax
80102865:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(log.committing)
8010286a:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
80102870:	83 c4 10             	add    $0x10,%esp
80102873:	85 db                	test   %ebx,%ebx
80102875:	75 2c                	jne    801028a3 <end_op+0x57>
  if(log.outstanding == 0){
80102877:	85 c0                	test   %eax,%eax
80102879:	75 35                	jne    801028b0 <end_op+0x64>
    log.committing = 1;
8010287b:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
80102882:	00 00 00 
    do_commit = 1;
80102885:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
8010288a:	83 ec 0c             	sub    $0xc,%esp
8010288d:	68 80 26 11 80       	push   $0x80112680
80102892:	e8 f0 13 00 00       	call   80103c87 <release>
  if(do_commit){
80102897:	83 c4 10             	add    $0x10,%esp
8010289a:	85 db                	test   %ebx,%ebx
8010289c:	75 24                	jne    801028c2 <end_op+0x76>
}
8010289e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028a1:	c9                   	leave  
801028a2:	c3                   	ret    
    panic("log.committing");
801028a3:	83 ec 0c             	sub    $0xc,%esp
801028a6:	68 44 6c 10 80       	push   $0x80106c44
801028ab:	e8 98 da ff ff       	call   80100348 <panic>
    wakeup(&log);
801028b0:	83 ec 0c             	sub    $0xc,%esp
801028b3:	68 80 26 11 80       	push   $0x80112680
801028b8:	e8 ca 0f 00 00       	call   80103887 <wakeup>
801028bd:	83 c4 10             	add    $0x10,%esp
801028c0:	eb c8                	jmp    8010288a <end_op+0x3e>
    commit();
801028c2:	e8 91 fe ff ff       	call   80102758 <commit>
    acquire(&log.lock);
801028c7:	83 ec 0c             	sub    $0xc,%esp
801028ca:	68 80 26 11 80       	push   $0x80112680
801028cf:	e8 4e 13 00 00       	call   80103c22 <acquire>
    log.committing = 0;
801028d4:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
801028db:	00 00 00 
    wakeup(&log);
801028de:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028e5:	e8 9d 0f 00 00       	call   80103887 <wakeup>
    release(&log.lock);
801028ea:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028f1:	e8 91 13 00 00       	call   80103c87 <release>
801028f6:	83 c4 10             	add    $0x10,%esp
}
801028f9:	eb a3                	jmp    8010289e <end_op+0x52>

801028fb <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028fb:	55                   	push   %ebp
801028fc:	89 e5                	mov    %esp,%ebp
801028fe:	53                   	push   %ebx
801028ff:	83 ec 04             	sub    $0x4,%esp
80102902:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102905:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
8010290b:	83 fa 1d             	cmp    $0x1d,%edx
8010290e:	7f 45                	jg     80102955 <log_write+0x5a>
80102910:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102915:	83 e8 01             	sub    $0x1,%eax
80102918:	39 c2                	cmp    %eax,%edx
8010291a:	7d 39                	jge    80102955 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010291c:	83 3d bc 26 11 80 00 	cmpl   $0x0,0x801126bc
80102923:	7e 3d                	jle    80102962 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102925:	83 ec 0c             	sub    $0xc,%esp
80102928:	68 80 26 11 80       	push   $0x80112680
8010292d:	e8 f0 12 00 00       	call   80103c22 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102932:	83 c4 10             	add    $0x10,%esp
80102935:	b8 00 00 00 00       	mov    $0x0,%eax
8010293a:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102940:	39 c2                	cmp    %eax,%edx
80102942:	7e 2b                	jle    8010296f <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102944:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102947:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
8010294e:	74 1f                	je     8010296f <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102950:	83 c0 01             	add    $0x1,%eax
80102953:	eb e5                	jmp    8010293a <log_write+0x3f>
    panic("too big a transaction");
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	68 53 6c 10 80       	push   $0x80106c53
8010295d:	e8 e6 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102962:	83 ec 0c             	sub    $0xc,%esp
80102965:	68 69 6c 10 80       	push   $0x80106c69
8010296a:	e8 d9 d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
8010296f:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102972:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
  if (i == log.lh.n)
80102979:	39 c2                	cmp    %eax,%edx
8010297b:	74 18                	je     80102995 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010297d:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102980:	83 ec 0c             	sub    $0xc,%esp
80102983:	68 80 26 11 80       	push   $0x80112680
80102988:	e8 fa 12 00 00       	call   80103c87 <release>
}
8010298d:	83 c4 10             	add    $0x10,%esp
80102990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102993:	c9                   	leave  
80102994:	c3                   	ret    
    log.lh.n++;
80102995:	83 c2 01             	add    $0x1,%edx
80102998:	89 15 c8 26 11 80    	mov    %edx,0x801126c8
8010299e:	eb dd                	jmp    8010297d <log_write+0x82>

801029a0 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801029a0:	55                   	push   %ebp
801029a1:	89 e5                	mov    %esp,%ebp
801029a3:	53                   	push   %ebx
801029a4:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801029a7:	68 8a 00 00 00       	push   $0x8a
801029ac:	68 8c a4 10 80       	push   $0x8010a48c
801029b1:	68 00 70 00 80       	push   $0x80007000
801029b6:	e8 8e 13 00 00       	call   80103d49 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801029bb:	83 c4 10             	add    $0x10,%esp
801029be:	bb 80 27 11 80       	mov    $0x80112780,%ebx
801029c3:	eb 13                	jmp    801029d8 <startothers+0x38>
801029c5:	83 ec 0c             	sub    $0xc,%esp
801029c8:	68 68 69 10 80       	push   $0x80106968
801029cd:	e8 76 d9 ff ff       	call   80100348 <panic>
801029d2:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029d8:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
801029df:	00 00 00 
801029e2:	05 80 27 11 80       	add    $0x80112780,%eax
801029e7:	39 d8                	cmp    %ebx,%eax
801029e9:	76 58                	jbe    80102a43 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
801029eb:	e8 f0 07 00 00       	call   801031e0 <mycpu>
801029f0:	39 d8                	cmp    %ebx,%eax
801029f2:	74 de                	je     801029d2 <startothers+0x32>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029f4:	e8 d6 f6 ff ff       	call   801020cf <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029f9:	05 00 10 00 00       	add    $0x1000,%eax
801029fe:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102a03:	c7 05 f8 6f 00 80 87 	movl   $0x80102a87,0x80006ff8
80102a0a:	2a 10 80 
    if (a < (void*) KERNBASE)
80102a0d:	b8 00 90 10 80       	mov    $0x80109000,%eax
80102a12:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80102a17:	76 ac                	jbe    801029c5 <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102a19:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102a20:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a23:	83 ec 08             	sub    $0x8,%esp
80102a26:	68 00 70 00 00       	push   $0x7000
80102a2b:	0f b6 03             	movzbl (%ebx),%eax
80102a2e:	50                   	push   %eax
80102a2f:	e8 ad f9 ff ff       	call   801023e1 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a34:	83 c4 10             	add    $0x10,%esp
80102a37:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a3d:	85 c0                	test   %eax,%eax
80102a3f:	74 f6                	je     80102a37 <startothers+0x97>
80102a41:	eb 8f                	jmp    801029d2 <startothers+0x32>
      ;
  }
}
80102a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a46:	c9                   	leave  
80102a47:	c3                   	ret    

80102a48 <mpmain>:
{
80102a48:	55                   	push   %ebp
80102a49:	89 e5                	mov    %esp,%ebp
80102a4b:	53                   	push   %ebx
80102a4c:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a4f:	e8 e8 07 00 00       	call   8010323c <cpuid>
80102a54:	89 c3                	mov    %eax,%ebx
80102a56:	e8 e1 07 00 00       	call   8010323c <cpuid>
80102a5b:	83 ec 04             	sub    $0x4,%esp
80102a5e:	53                   	push   %ebx
80102a5f:	50                   	push   %eax
80102a60:	68 84 6c 10 80       	push   $0x80106c84
80102a65:	e8 a1 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a6a:	e8 00 25 00 00       	call   80104f6f <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a6f:	e8 6c 07 00 00       	call   801031e0 <mycpu>
80102a74:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a76:	b8 01 00 00 00       	mov    $0x1,%eax
80102a7b:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a82:	e8 64 0a 00 00       	call   801034eb <scheduler>

80102a87 <mpenter>:
{
80102a87:	55                   	push   %ebp
80102a88:	89 e5                	mov    %esp,%ebp
80102a8a:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a8d:	e8 10 35 00 00       	call   80105fa2 <switchkvm>
  seginit();
80102a92:	e8 bf 33 00 00       	call   80105e56 <seginit>
  lapicinit();
80102a97:	e8 fc f7 ff ff       	call   80102298 <lapicinit>
  mpmain();
80102a9c:	e8 a7 ff ff ff       	call   80102a48 <mpmain>

80102aa1 <main>:
{
80102aa1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102aa5:	83 e4 f0             	and    $0xfffffff0,%esp
80102aa8:	ff 71 fc             	pushl  -0x4(%ecx)
80102aab:	55                   	push   %ebp
80102aac:	89 e5                	mov    %esp,%ebp
80102aae:	51                   	push   %ecx
80102aaf:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102ab2:	68 00 00 40 80       	push   $0x80400000
80102ab7:	68 a8 56 11 80       	push   $0x801156a8
80102abc:	e8 bc f5 ff ff       	call   8010207d <kinit1>
  kvmalloc();      // kernel page table
80102ac1:	e8 fc 39 00 00       	call   801064c2 <kvmalloc>
  mpinit();        // detect other processors
80102ac6:	e8 e7 01 00 00       	call   80102cb2 <mpinit>
  lapicinit();     // interrupt controller
80102acb:	e8 c8 f7 ff ff       	call   80102298 <lapicinit>
  seginit();       // segment descriptors
80102ad0:	e8 81 33 00 00       	call   80105e56 <seginit>
  picinit();       // disable pic
80102ad5:	e8 a0 02 00 00       	call   80102d7a <picinit>
  ioapicinit();    // another interrupt controller
80102ada:	e8 09 f4 ff ff       	call   80101ee8 <ioapicinit>
  consoleinit();   // console hardware
80102adf:	e8 aa dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102ae4:	e8 34 27 00 00       	call   8010521d <uartinit>
  pinit();         // process table
80102ae9:	e8 d8 06 00 00       	call   801031c6 <pinit>
  tvinit();        // trap vectors
80102aee:	e8 cb 23 00 00       	call   80104ebe <tvinit>
  binit();         // buffer cache
80102af3:	e8 fc d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102af8:	e8 16 e1 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102afd:	e8 ec f1 ff ff       	call   80101cee <ideinit>
  startothers();   // start other processors
80102b02:	e8 99 fe ff ff       	call   801029a0 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b07:	83 c4 08             	add    $0x8,%esp
80102b0a:	68 00 00 00 8e       	push   $0x8e000000
80102b0f:	68 00 00 40 80       	push   $0x80400000
80102b14:	e8 96 f5 ff ff       	call   801020af <kinit2>
  userinit();      // first user process
80102b19:	e8 5d 07 00 00       	call   8010327b <userinit>
  mpmain();        // finish this processor's setup
80102b1e:	e8 25 ff ff ff       	call   80102a48 <mpmain>

80102b23 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b23:	55                   	push   %ebp
80102b24:	89 e5                	mov    %esp,%ebp
80102b26:	56                   	push   %esi
80102b27:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102b28:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102b2d:	b9 00 00 00 00       	mov    $0x0,%ecx
80102b32:	eb 09                	jmp    80102b3d <sum+0x1a>
    sum += addr[i];
80102b34:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102b38:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102b3a:	83 c1 01             	add    $0x1,%ecx
80102b3d:	39 d1                	cmp    %edx,%ecx
80102b3f:	7c f3                	jl     80102b34 <sum+0x11>
  return sum;
}
80102b41:	89 d8                	mov    %ebx,%eax
80102b43:	5b                   	pop    %ebx
80102b44:	5e                   	pop    %esi
80102b45:	5d                   	pop    %ebp
80102b46:	c3                   	ret    

80102b47 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b47:	55                   	push   %ebp
80102b48:	89 e5                	mov    %esp,%ebp
80102b4a:	56                   	push   %esi
80102b4b:	53                   	push   %ebx
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102b4c:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102b51:	77 0b                	ja     80102b5e <mpsearch1+0x17>
        panic("P2V on address > KERNBASE");
    return (char*)a + KERNBASE;
80102b53:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102b59:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b5c:	eb 10                	jmp    80102b6e <mpsearch1+0x27>
        panic("P2V on address > KERNBASE");
80102b5e:	83 ec 0c             	sub    $0xc,%esp
80102b61:	68 98 6c 10 80       	push   $0x80106c98
80102b66:	e8 dd d7 ff ff       	call   80100348 <panic>
80102b6b:	83 c3 10             	add    $0x10,%ebx
80102b6e:	39 f3                	cmp    %esi,%ebx
80102b70:	73 29                	jae    80102b9b <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b72:	83 ec 04             	sub    $0x4,%esp
80102b75:	6a 04                	push   $0x4
80102b77:	68 b2 6c 10 80       	push   $0x80106cb2
80102b7c:	53                   	push   %ebx
80102b7d:	e8 92 11 00 00       	call   80103d14 <memcmp>
80102b82:	83 c4 10             	add    $0x10,%esp
80102b85:	85 c0                	test   %eax,%eax
80102b87:	75 e2                	jne    80102b6b <mpsearch1+0x24>
80102b89:	ba 10 00 00 00       	mov    $0x10,%edx
80102b8e:	89 d8                	mov    %ebx,%eax
80102b90:	e8 8e ff ff ff       	call   80102b23 <sum>
80102b95:	84 c0                	test   %al,%al
80102b97:	75 d2                	jne    80102b6b <mpsearch1+0x24>
80102b99:	eb 05                	jmp    80102ba0 <mpsearch1+0x59>
      return (struct mp*)p;
  return 0;
80102b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102ba0:	89 d8                	mov    %ebx,%eax
80102ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102ba5:	5b                   	pop    %ebx
80102ba6:	5e                   	pop    %esi
80102ba7:	5d                   	pop    %ebp
80102ba8:	c3                   	ret    

80102ba9 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102ba9:	55                   	push   %ebp
80102baa:	89 e5                	mov    %esp,%ebp
80102bac:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102baf:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102bb6:	c1 e0 08             	shl    $0x8,%eax
80102bb9:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102bc0:	09 d0                	or     %edx,%eax
80102bc2:	c1 e0 04             	shl    $0x4,%eax
80102bc5:	85 c0                	test   %eax,%eax
80102bc7:	74 1f                	je     80102be8 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102bc9:	ba 00 04 00 00       	mov    $0x400,%edx
80102bce:	e8 74 ff ff ff       	call   80102b47 <mpsearch1>
80102bd3:	85 c0                	test   %eax,%eax
80102bd5:	75 0f                	jne    80102be6 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102bd7:	ba 00 00 01 00       	mov    $0x10000,%edx
80102bdc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102be1:	e8 61 ff ff ff       	call   80102b47 <mpsearch1>
}
80102be6:	c9                   	leave  
80102be7:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102be8:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102bef:	c1 e0 08             	shl    $0x8,%eax
80102bf2:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102bf9:	09 d0                	or     %edx,%eax
80102bfb:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bfe:	2d 00 04 00 00       	sub    $0x400,%eax
80102c03:	ba 00 04 00 00       	mov    $0x400,%edx
80102c08:	e8 3a ff ff ff       	call   80102b47 <mpsearch1>
80102c0d:	85 c0                	test   %eax,%eax
80102c0f:	75 d5                	jne    80102be6 <mpsearch+0x3d>
80102c11:	eb c4                	jmp    80102bd7 <mpsearch+0x2e>

80102c13 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102c13:	55                   	push   %ebp
80102c14:	89 e5                	mov    %esp,%ebp
80102c16:	57                   	push   %edi
80102c17:	56                   	push   %esi
80102c18:	53                   	push   %ebx
80102c19:	83 ec 0c             	sub    $0xc,%esp
80102c1c:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c1e:	e8 86 ff ff ff       	call   80102ba9 <mpsearch>
80102c23:	85 c0                	test   %eax,%eax
80102c25:	74 68                	je     80102c8f <mpconfig+0x7c>
80102c27:	89 c6                	mov    %eax,%esi
80102c29:	8b 58 04             	mov    0x4(%eax),%ebx
80102c2c:	85 db                	test   %ebx,%ebx
80102c2e:	74 66                	je     80102c96 <mpconfig+0x83>
    if (a > KERNBASE)
80102c30:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102c36:	77 4a                	ja     80102c82 <mpconfig+0x6f>
    return (char*)a + KERNBASE;
80102c38:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102c3e:	83 ec 04             	sub    $0x4,%esp
80102c41:	6a 04                	push   $0x4
80102c43:	68 b7 6c 10 80       	push   $0x80106cb7
80102c48:	53                   	push   %ebx
80102c49:	e8 c6 10 00 00       	call   80103d14 <memcmp>
80102c4e:	83 c4 10             	add    $0x10,%esp
80102c51:	85 c0                	test   %eax,%eax
80102c53:	75 48                	jne    80102c9d <mpconfig+0x8a>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c55:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102c59:	3c 01                	cmp    $0x1,%al
80102c5b:	0f 95 c2             	setne  %dl
80102c5e:	3c 04                	cmp    $0x4,%al
80102c60:	0f 95 c0             	setne  %al
80102c63:	84 c2                	test   %al,%dl
80102c65:	75 3d                	jne    80102ca4 <mpconfig+0x91>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c67:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102c6b:	89 d8                	mov    %ebx,%eax
80102c6d:	e8 b1 fe ff ff       	call   80102b23 <sum>
80102c72:	84 c0                	test   %al,%al
80102c74:	75 35                	jne    80102cab <mpconfig+0x98>
    return 0;
  *pmp = mp;
80102c76:	89 37                	mov    %esi,(%edi)
  return conf;
}
80102c78:	89 d8                	mov    %ebx,%eax
80102c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c7d:	5b                   	pop    %ebx
80102c7e:	5e                   	pop    %esi
80102c7f:	5f                   	pop    %edi
80102c80:	5d                   	pop    %ebp
80102c81:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80102c82:	83 ec 0c             	sub    $0xc,%esp
80102c85:	68 98 6c 10 80       	push   $0x80106c98
80102c8a:	e8 b9 d6 ff ff       	call   80100348 <panic>
    return 0;
80102c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c94:	eb e2                	jmp    80102c78 <mpconfig+0x65>
80102c96:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c9b:	eb db                	jmp    80102c78 <mpconfig+0x65>
    return 0;
80102c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102ca2:	eb d4                	jmp    80102c78 <mpconfig+0x65>
    return 0;
80102ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
80102ca9:	eb cd                	jmp    80102c78 <mpconfig+0x65>
    return 0;
80102cab:	bb 00 00 00 00       	mov    $0x0,%ebx
80102cb0:	eb c6                	jmp    80102c78 <mpconfig+0x65>

80102cb2 <mpinit>:

void
mpinit(void)
{
80102cb2:	55                   	push   %ebp
80102cb3:	89 e5                	mov    %esp,%ebp
80102cb5:	57                   	push   %edi
80102cb6:	56                   	push   %esi
80102cb7:	53                   	push   %ebx
80102cb8:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102cbb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102cbe:	e8 50 ff ff ff       	call   80102c13 <mpconfig>
80102cc3:	85 c0                	test   %eax,%eax
80102cc5:	74 19                	je     80102ce0 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102cc7:	8b 50 24             	mov    0x24(%eax),%edx
80102cca:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cd0:	8d 50 2c             	lea    0x2c(%eax),%edx
80102cd3:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102cd7:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102cd9:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cde:	eb 34                	jmp    80102d14 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102ce0:	83 ec 0c             	sub    $0xc,%esp
80102ce3:	68 bc 6c 10 80       	push   $0x80106cbc
80102ce8:	e8 5b d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102ced:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
80102cf3:	83 fe 07             	cmp    $0x7,%esi
80102cf6:	7f 19                	jg     80102d11 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cf8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cfc:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102d02:	88 87 80 27 11 80    	mov    %al,-0x7feed880(%edi)
        ncpu++;
80102d08:	83 c6 01             	add    $0x1,%esi
80102d0b:	89 35 00 2d 11 80    	mov    %esi,0x80112d00
      }
      p += sizeof(struct mpproc);
80102d11:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d14:	39 ca                	cmp    %ecx,%edx
80102d16:	73 2b                	jae    80102d43 <mpinit+0x91>
    switch(*p){
80102d18:	0f b6 02             	movzbl (%edx),%eax
80102d1b:	3c 04                	cmp    $0x4,%al
80102d1d:	77 1d                	ja     80102d3c <mpinit+0x8a>
80102d1f:	0f b6 c0             	movzbl %al,%eax
80102d22:	ff 24 85 f4 6c 10 80 	jmp    *-0x7fef930c(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102d29:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d2d:	a2 60 27 11 80       	mov    %al,0x80112760
      p += sizeof(struct mpioapic);
80102d32:	83 c2 08             	add    $0x8,%edx
      continue;
80102d35:	eb dd                	jmp    80102d14 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d37:	83 c2 08             	add    $0x8,%edx
      continue;
80102d3a:	eb d8                	jmp    80102d14 <mpinit+0x62>
    default:
      ismp = 0;
80102d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d41:	eb d1                	jmp    80102d14 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102d43:	85 db                	test   %ebx,%ebx
80102d45:	74 26                	je     80102d6d <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d4a:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d4e:	74 15                	je     80102d65 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d50:	b8 70 00 00 00       	mov    $0x70,%eax
80102d55:	ba 22 00 00 00       	mov    $0x22,%edx
80102d5a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d5b:	ba 23 00 00 00       	mov    $0x23,%edx
80102d60:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d61:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d64:	ee                   	out    %al,(%dx)
  }
}
80102d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d68:	5b                   	pop    %ebx
80102d69:	5e                   	pop    %esi
80102d6a:	5f                   	pop    %edi
80102d6b:	5d                   	pop    %ebp
80102d6c:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d6d:	83 ec 0c             	sub    $0xc,%esp
80102d70:	68 d4 6c 10 80       	push   $0x80106cd4
80102d75:	e8 ce d5 ff ff       	call   80100348 <panic>

80102d7a <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d7a:	55                   	push   %ebp
80102d7b:	89 e5                	mov    %esp,%ebp
80102d7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d82:	ba 21 00 00 00       	mov    $0x21,%edx
80102d87:	ee                   	out    %al,(%dx)
80102d88:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d8d:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d8e:	5d                   	pop    %ebp
80102d8f:	c3                   	ret    

80102d90 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d90:	55                   	push   %ebp
80102d91:	89 e5                	mov    %esp,%ebp
80102d93:	57                   	push   %edi
80102d94:	56                   	push   %esi
80102d95:	53                   	push   %ebx
80102d96:	83 ec 0c             	sub    $0xc,%esp
80102d99:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d9f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102da5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102dab:	e8 7d de ff ff       	call   80100c2d <filealloc>
80102db0:	89 03                	mov    %eax,(%ebx)
80102db2:	85 c0                	test   %eax,%eax
80102db4:	74 16                	je     80102dcc <pipealloc+0x3c>
80102db6:	e8 72 de ff ff       	call   80100c2d <filealloc>
80102dbb:	89 06                	mov    %eax,(%esi)
80102dbd:	85 c0                	test   %eax,%eax
80102dbf:	74 0b                	je     80102dcc <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102dc1:	e8 09 f3 ff ff       	call   801020cf <kalloc>
80102dc6:	89 c7                	mov    %eax,%edi
80102dc8:	85 c0                	test   %eax,%eax
80102dca:	75 35                	jne    80102e01 <pipealloc+0x71>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102dcc:	8b 03                	mov    (%ebx),%eax
80102dce:	85 c0                	test   %eax,%eax
80102dd0:	74 0c                	je     80102dde <pipealloc+0x4e>
    fileclose(*f0);
80102dd2:	83 ec 0c             	sub    $0xc,%esp
80102dd5:	50                   	push   %eax
80102dd6:	e8 f8 de ff ff       	call   80100cd3 <fileclose>
80102ddb:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102dde:	8b 06                	mov    (%esi),%eax
80102de0:	85 c0                	test   %eax,%eax
80102de2:	0f 84 8b 00 00 00    	je     80102e73 <pipealloc+0xe3>
    fileclose(*f1);
80102de8:	83 ec 0c             	sub    $0xc,%esp
80102deb:	50                   	push   %eax
80102dec:	e8 e2 de ff ff       	call   80100cd3 <fileclose>
80102df1:	83 c4 10             	add    $0x10,%esp
  return -1;
80102df4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dfc:	5b                   	pop    %ebx
80102dfd:	5e                   	pop    %esi
80102dfe:	5f                   	pop    %edi
80102dff:	5d                   	pop    %ebp
80102e00:	c3                   	ret    
  p->readopen = 1;
80102e01:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102e08:	00 00 00 
  p->writeopen = 1;
80102e0b:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102e12:	00 00 00 
  p->nwrite = 0;
80102e15:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e1c:	00 00 00 
  p->nread = 0;
80102e1f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e26:	00 00 00 
  initlock(&p->lock, "pipe");
80102e29:	83 ec 08             	sub    $0x8,%esp
80102e2c:	68 08 6d 10 80       	push   $0x80106d08
80102e31:	50                   	push   %eax
80102e32:	e8 af 0c 00 00       	call   80103ae6 <initlock>
  (*f0)->type = FD_PIPE;
80102e37:	8b 03                	mov    (%ebx),%eax
80102e39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102e3f:	8b 03                	mov    (%ebx),%eax
80102e41:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102e45:	8b 03                	mov    (%ebx),%eax
80102e47:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102e4b:	8b 03                	mov    (%ebx),%eax
80102e4d:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102e50:	8b 06                	mov    (%esi),%eax
80102e52:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e58:	8b 06                	mov    (%esi),%eax
80102e5a:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e5e:	8b 06                	mov    (%esi),%eax
80102e60:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e64:	8b 06                	mov    (%esi),%eax
80102e66:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e69:	83 c4 10             	add    $0x10,%esp
80102e6c:	b8 00 00 00 00       	mov    $0x0,%eax
80102e71:	eb 86                	jmp    80102df9 <pipealloc+0x69>
  return -1;
80102e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e78:	e9 7c ff ff ff       	jmp    80102df9 <pipealloc+0x69>

80102e7d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e7d:	55                   	push   %ebp
80102e7e:	89 e5                	mov    %esp,%ebp
80102e80:	53                   	push   %ebx
80102e81:	83 ec 10             	sub    $0x10,%esp
80102e84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e87:	53                   	push   %ebx
80102e88:	e8 95 0d 00 00       	call   80103c22 <acquire>
  if(writable){
80102e8d:	83 c4 10             	add    $0x10,%esp
80102e90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e94:	74 3f                	je     80102ed5 <pipeclose+0x58>
    p->writeopen = 0;
80102e96:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e9d:	00 00 00 
    wakeup(&p->nread);
80102ea0:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ea6:	83 ec 0c             	sub    $0xc,%esp
80102ea9:	50                   	push   %eax
80102eaa:	e8 d8 09 00 00       	call   80103887 <wakeup>
80102eaf:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102eb2:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102eb9:	75 09                	jne    80102ec4 <pipeclose+0x47>
80102ebb:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102ec2:	74 2f                	je     80102ef3 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102ec4:	83 ec 0c             	sub    $0xc,%esp
80102ec7:	53                   	push   %ebx
80102ec8:	e8 ba 0d 00 00       	call   80103c87 <release>
80102ecd:	83 c4 10             	add    $0x10,%esp
}
80102ed0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ed3:	c9                   	leave  
80102ed4:	c3                   	ret    
    p->readopen = 0;
80102ed5:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102edc:	00 00 00 
    wakeup(&p->nwrite);
80102edf:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102ee5:	83 ec 0c             	sub    $0xc,%esp
80102ee8:	50                   	push   %eax
80102ee9:	e8 99 09 00 00       	call   80103887 <wakeup>
80102eee:	83 c4 10             	add    $0x10,%esp
80102ef1:	eb bf                	jmp    80102eb2 <pipeclose+0x35>
    release(&p->lock);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	53                   	push   %ebx
80102ef7:	e8 8b 0d 00 00       	call   80103c87 <release>
    kfree((char*)p);
80102efc:	89 1c 24             	mov    %ebx,(%esp)
80102eff:	e8 8e f0 ff ff       	call   80101f92 <kfree>
80102f04:	83 c4 10             	add    $0x10,%esp
80102f07:	eb c7                	jmp    80102ed0 <pipeclose+0x53>

80102f09 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102f09:	55                   	push   %ebp
80102f0a:	89 e5                	mov    %esp,%ebp
80102f0c:	57                   	push   %edi
80102f0d:	56                   	push   %esi
80102f0e:	53                   	push   %ebx
80102f0f:	83 ec 18             	sub    $0x18,%esp
80102f12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f15:	89 de                	mov    %ebx,%esi
80102f17:	53                   	push   %ebx
80102f18:	e8 05 0d 00 00       	call   80103c22 <acquire>
  for(i = 0; i < n; i++){
80102f1d:	83 c4 10             	add    $0x10,%esp
80102f20:	bf 00 00 00 00       	mov    $0x0,%edi
80102f25:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102f28:	0f 8d 88 00 00 00    	jge    80102fb6 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f2e:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102f34:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f3a:	05 00 02 00 00       	add    $0x200,%eax
80102f3f:	39 c2                	cmp    %eax,%edx
80102f41:	75 51                	jne    80102f94 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102f43:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f4a:	74 2f                	je     80102f7b <pipewrite+0x72>
80102f4c:	e8 06 03 00 00       	call   80103257 <myproc>
80102f51:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f55:	75 24                	jne    80102f7b <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f57:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f5d:	83 ec 0c             	sub    $0xc,%esp
80102f60:	50                   	push   %eax
80102f61:	e8 21 09 00 00       	call   80103887 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f66:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f6c:	83 c4 08             	add    $0x8,%esp
80102f6f:	56                   	push   %esi
80102f70:	50                   	push   %eax
80102f71:	e8 a9 07 00 00       	call   8010371f <sleep>
80102f76:	83 c4 10             	add    $0x10,%esp
80102f79:	eb b3                	jmp    80102f2e <pipewrite+0x25>
        release(&p->lock);
80102f7b:	83 ec 0c             	sub    $0xc,%esp
80102f7e:	53                   	push   %ebx
80102f7f:	e8 03 0d 00 00       	call   80103c87 <release>
        return -1;
80102f84:	83 c4 10             	add    $0x10,%esp
80102f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f8f:	5b                   	pop    %ebx
80102f90:	5e                   	pop    %esi
80102f91:	5f                   	pop    %edi
80102f92:	5d                   	pop    %ebp
80102f93:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f94:	8d 42 01             	lea    0x1(%edx),%eax
80102f97:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f9d:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fa6:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102faa:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102fae:	83 c7 01             	add    $0x1,%edi
80102fb1:	e9 6f ff ff ff       	jmp    80102f25 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102fb6:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fbc:	83 ec 0c             	sub    $0xc,%esp
80102fbf:	50                   	push   %eax
80102fc0:	e8 c2 08 00 00       	call   80103887 <wakeup>
  release(&p->lock);
80102fc5:	89 1c 24             	mov    %ebx,(%esp)
80102fc8:	e8 ba 0c 00 00       	call   80103c87 <release>
  return n;
80102fcd:	83 c4 10             	add    $0x10,%esp
80102fd0:	8b 45 10             	mov    0x10(%ebp),%eax
80102fd3:	eb b7                	jmp    80102f8c <pipewrite+0x83>

80102fd5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102fd5:	55                   	push   %ebp
80102fd6:	89 e5                	mov    %esp,%ebp
80102fd8:	57                   	push   %edi
80102fd9:	56                   	push   %esi
80102fda:	53                   	push   %ebx
80102fdb:	83 ec 18             	sub    $0x18,%esp
80102fde:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102fe1:	89 df                	mov    %ebx,%edi
80102fe3:	53                   	push   %ebx
80102fe4:	e8 39 0c 00 00       	call   80103c22 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fe9:	83 c4 10             	add    $0x10,%esp
80102fec:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ff2:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102ff8:	75 3d                	jne    80103037 <piperead+0x62>
80102ffa:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103000:	85 f6                	test   %esi,%esi
80103002:	74 38                	je     8010303c <piperead+0x67>
    if(myproc()->killed){
80103004:	e8 4e 02 00 00       	call   80103257 <myproc>
80103009:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010300d:	75 15                	jne    80103024 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010300f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103015:	83 ec 08             	sub    $0x8,%esp
80103018:	57                   	push   %edi
80103019:	50                   	push   %eax
8010301a:	e8 00 07 00 00       	call   8010371f <sleep>
8010301f:	83 c4 10             	add    $0x10,%esp
80103022:	eb c8                	jmp    80102fec <piperead+0x17>
      release(&p->lock);
80103024:	83 ec 0c             	sub    $0xc,%esp
80103027:	53                   	push   %ebx
80103028:	e8 5a 0c 00 00       	call   80103c87 <release>
      return -1;
8010302d:	83 c4 10             	add    $0x10,%esp
80103030:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103035:	eb 50                	jmp    80103087 <piperead+0xb2>
80103037:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010303c:	3b 75 10             	cmp    0x10(%ebp),%esi
8010303f:	7d 2c                	jge    8010306d <piperead+0x98>
    if(p->nread == p->nwrite)
80103041:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103047:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
8010304d:	74 1e                	je     8010306d <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010304f:	8d 50 01             	lea    0x1(%eax),%edx
80103052:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103058:	25 ff 01 00 00       	and    $0x1ff,%eax
8010305d:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103065:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103068:	83 c6 01             	add    $0x1,%esi
8010306b:	eb cf                	jmp    8010303c <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010306d:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103073:	83 ec 0c             	sub    $0xc,%esp
80103076:	50                   	push   %eax
80103077:	e8 0b 08 00 00       	call   80103887 <wakeup>
  release(&p->lock);
8010307c:	89 1c 24             	mov    %ebx,(%esp)
8010307f:	e8 03 0c 00 00       	call   80103c87 <release>
  return i;
80103084:	83 c4 10             	add    $0x10,%esp
}
80103087:	89 f0                	mov    %esi,%eax
80103089:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010308c:	5b                   	pop    %ebx
8010308d:	5e                   	pop    %esi
8010308e:	5f                   	pop    %edi
8010308f:	5d                   	pop    %ebp
80103090:	c3                   	ret    

80103091 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103091:	55                   	push   %ebp
80103092:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103094:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103099:	eb 06                	jmp    801030a1 <wakeup1+0x10>
8010309b:	81 c2 84 00 00 00    	add    $0x84,%edx
801030a1:	81 fa 54 4e 11 80    	cmp    $0x80114e54,%edx
801030a7:	73 14                	jae    801030bd <wakeup1+0x2c>
    if(p->state == SLEEPING && p->chan == chan)
801030a9:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801030ad:	75 ec                	jne    8010309b <wakeup1+0xa>
801030af:	39 42 20             	cmp    %eax,0x20(%edx)
801030b2:	75 e7                	jne    8010309b <wakeup1+0xa>
      p->state = RUNNABLE;
801030b4:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801030bb:	eb de                	jmp    8010309b <wakeup1+0xa>
}
801030bd:	5d                   	pop    %ebp
801030be:	c3                   	ret    

801030bf <allocproc>:
{
801030bf:	55                   	push   %ebp
801030c0:	89 e5                	mov    %esp,%ebp
801030c2:	53                   	push   %ebx
801030c3:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801030c6:	68 20 2d 11 80       	push   $0x80112d20
801030cb:	e8 52 0b 00 00       	call   80103c22 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030d0:	83 c4 10             	add    $0x10,%esp
801030d3:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801030d8:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
801030de:	73 0e                	jae    801030ee <allocproc+0x2f>
    if(p->state == UNUSED)
801030e0:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801030e4:	74 1f                	je     80103105 <allocproc+0x46>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030e6:	81 c3 84 00 00 00    	add    $0x84,%ebx
801030ec:	eb ea                	jmp    801030d8 <allocproc+0x19>
  release(&ptable.lock);
801030ee:	83 ec 0c             	sub    $0xc,%esp
801030f1:	68 20 2d 11 80       	push   $0x80112d20
801030f6:	e8 8c 0b 00 00       	call   80103c87 <release>
  return 0;
801030fb:	83 c4 10             	add    $0x10,%esp
801030fe:	bb 00 00 00 00       	mov    $0x0,%ebx
80103103:	eb 69                	jmp    8010316e <allocproc+0xaf>
  p->state = EMBRYO;
80103105:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
8010310c:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103111:	8d 50 01             	lea    0x1(%eax),%edx
80103114:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
8010311a:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010311d:	83 ec 0c             	sub    $0xc,%esp
80103120:	68 20 2d 11 80       	push   $0x80112d20
80103125:	e8 5d 0b 00 00       	call   80103c87 <release>
  if((p->kstack = kalloc()) == 0){
8010312a:	e8 a0 ef ff ff       	call   801020cf <kalloc>
8010312f:	89 43 08             	mov    %eax,0x8(%ebx)
80103132:	83 c4 10             	add    $0x10,%esp
80103135:	85 c0                	test   %eax,%eax
80103137:	74 3c                	je     80103175 <allocproc+0xb6>
  sp -= sizeof *p->tf;
80103139:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010313f:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103142:	c7 80 b0 0f 00 00 b3 	movl   $0x80104eb3,0xfb0(%eax)
80103149:	4e 10 80 
  sp -= sizeof *p->context;
8010314c:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103151:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103154:	83 ec 04             	sub    $0x4,%esp
80103157:	6a 14                	push   $0x14
80103159:	6a 00                	push   $0x0
8010315b:	50                   	push   %eax
8010315c:	e8 6d 0b 00 00       	call   80103cce <memset>
  p->context->eip = (uint)forkret;
80103161:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103164:	c7 40 10 83 31 10 80 	movl   $0x80103183,0x10(%eax)
  return p;
8010316b:	83 c4 10             	add    $0x10,%esp
}
8010316e:	89 d8                	mov    %ebx,%eax
80103170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103173:	c9                   	leave  
80103174:	c3                   	ret    
    p->state = UNUSED;
80103175:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
8010317c:	bb 00 00 00 00       	mov    $0x0,%ebx
80103181:	eb eb                	jmp    8010316e <allocproc+0xaf>

80103183 <forkret>:
{
80103183:	55                   	push   %ebp
80103184:	89 e5                	mov    %esp,%ebp
80103186:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103189:	68 20 2d 11 80       	push   $0x80112d20
8010318e:	e8 f4 0a 00 00       	call   80103c87 <release>
  if (first) {
80103193:	83 c4 10             	add    $0x10,%esp
80103196:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010319d:	75 02                	jne    801031a1 <forkret+0x1e>
}
8010319f:	c9                   	leave  
801031a0:	c3                   	ret    
    first = 0;
801031a1:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801031a8:	00 00 00 
    iinit(ROOTDEV);
801031ab:	83 ec 0c             	sub    $0xc,%esp
801031ae:	6a 01                	push   $0x1
801031b0:	e8 25 e1 ff ff       	call   801012da <iinit>
    initlog(ROOTDEV);
801031b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031bc:	e8 c8 f5 ff ff       	call   80102789 <initlog>
801031c1:	83 c4 10             	add    $0x10,%esp
}
801031c4:	eb d9                	jmp    8010319f <forkret+0x1c>

801031c6 <pinit>:
{
801031c6:	55                   	push   %ebp
801031c7:	89 e5                	mov    %esp,%ebp
801031c9:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801031cc:	68 0d 6d 10 80       	push   $0x80106d0d
801031d1:	68 20 2d 11 80       	push   $0x80112d20
801031d6:	e8 0b 09 00 00       	call   80103ae6 <initlock>
}
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	c9                   	leave  
801031df:	c3                   	ret    

801031e0 <mycpu>:
{
801031e0:	55                   	push   %ebp
801031e1:	89 e5                	mov    %esp,%ebp
801031e3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031e6:	9c                   	pushf  
801031e7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801031e8:	f6 c4 02             	test   $0x2,%ah
801031eb:	75 28                	jne    80103215 <mycpu+0x35>
  apicid = lapicid();
801031ed:	e8 b0 f1 ff ff       	call   801023a2 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801031f2:	ba 00 00 00 00       	mov    $0x0,%edx
801031f7:	39 15 00 2d 11 80    	cmp    %edx,0x80112d00
801031fd:	7e 23                	jle    80103222 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801031ff:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103205:	0f b6 89 80 27 11 80 	movzbl -0x7feed880(%ecx),%ecx
8010320c:	39 c1                	cmp    %eax,%ecx
8010320e:	74 1f                	je     8010322f <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103210:	83 c2 01             	add    $0x1,%edx
80103213:	eb e2                	jmp    801031f7 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103215:	83 ec 0c             	sub    $0xc,%esp
80103218:	68 f0 6d 10 80       	push   $0x80106df0
8010321d:	e8 26 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	68 14 6d 10 80       	push   $0x80106d14
8010322a:	e8 19 d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
8010322f:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103235:	05 80 27 11 80       	add    $0x80112780,%eax
}
8010323a:	c9                   	leave  
8010323b:	c3                   	ret    

8010323c <cpuid>:
cpuid() {
8010323c:	55                   	push   %ebp
8010323d:	89 e5                	mov    %esp,%ebp
8010323f:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103242:	e8 99 ff ff ff       	call   801031e0 <mycpu>
80103247:	2d 80 27 11 80       	sub    $0x80112780,%eax
8010324c:	c1 f8 04             	sar    $0x4,%eax
8010324f:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <myproc>:
myproc(void) {
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	53                   	push   %ebx
8010325b:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010325e:	e8 e2 08 00 00       	call   80103b45 <pushcli>
  c = mycpu();
80103263:	e8 78 ff ff ff       	call   801031e0 <mycpu>
  p = c->proc;
80103268:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010326e:	e8 0f 09 00 00       	call   80103b82 <popcli>
}
80103273:	89 d8                	mov    %ebx,%eax
80103275:	83 c4 04             	add    $0x4,%esp
80103278:	5b                   	pop    %ebx
80103279:	5d                   	pop    %ebp
8010327a:	c3                   	ret    

8010327b <userinit>:
{
8010327b:	55                   	push   %ebp
8010327c:	89 e5                	mov    %esp,%ebp
8010327e:	53                   	push   %ebx
8010327f:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103282:	e8 38 fe ff ff       	call   801030bf <allocproc>
80103287:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103289:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
8010328e:	e8 c1 31 00 00       	call   80106454 <setupkvm>
80103293:	89 43 04             	mov    %eax,0x4(%ebx)
80103296:	85 c0                	test   %eax,%eax
80103298:	0f 84 b7 00 00 00    	je     80103355 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010329e:	83 ec 04             	sub    $0x4,%esp
801032a1:	68 2c 00 00 00       	push   $0x2c
801032a6:	68 60 a4 10 80       	push   $0x8010a460
801032ab:	50                   	push   %eax
801032ac:	e8 42 2e 00 00       	call   801060f3 <inituvm>
  p->sz = PGSIZE;
801032b1:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801032b7:	83 c4 0c             	add    $0xc,%esp
801032ba:	6a 4c                	push   $0x4c
801032bc:	6a 00                	push   $0x0
801032be:	ff 73 18             	pushl  0x18(%ebx)
801032c1:	e8 08 0a 00 00       	call   80103cce <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801032c6:	8b 43 18             	mov    0x18(%ebx),%eax
801032c9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801032cf:	8b 43 18             	mov    0x18(%ebx),%eax
801032d2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801032d8:	8b 43 18             	mov    0x18(%ebx),%eax
801032db:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032df:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801032e3:	8b 43 18             	mov    0x18(%ebx),%eax
801032e6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032ea:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801032ee:	8b 43 18             	mov    0x18(%ebx),%eax
801032f1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801032f8:	8b 43 18             	mov    0x18(%ebx),%eax
801032fb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103302:	8b 43 18             	mov    0x18(%ebx),%eax
80103305:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010330c:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010330f:	83 c4 0c             	add    $0xc,%esp
80103312:	6a 10                	push   $0x10
80103314:	68 3d 6d 10 80       	push   $0x80106d3d
80103319:	50                   	push   %eax
8010331a:	e8 16 0b 00 00       	call   80103e35 <safestrcpy>
  p->cwd = namei("/");
8010331f:	c7 04 24 46 6d 10 80 	movl   $0x80106d46,(%esp)
80103326:	e8 a4 e8 ff ff       	call   80101bcf <namei>
8010332b:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010332e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103335:	e8 e8 08 00 00       	call   80103c22 <acquire>
  p->state = RUNNABLE;
8010333a:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103341:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103348:	e8 3a 09 00 00       	call   80103c87 <release>
}
8010334d:	83 c4 10             	add    $0x10,%esp
80103350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103353:	c9                   	leave  
80103354:	c3                   	ret    
    panic("userinit: out of memory?");
80103355:	83 ec 0c             	sub    $0xc,%esp
80103358:	68 24 6d 10 80       	push   $0x80106d24
8010335d:	e8 e6 cf ff ff       	call   80100348 <panic>

80103362 <growproc>:
{
80103362:	55                   	push   %ebp
80103363:	89 e5                	mov    %esp,%ebp
80103365:	56                   	push   %esi
80103366:	53                   	push   %ebx
80103367:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010336a:	e8 e8 fe ff ff       	call   80103257 <myproc>
8010336f:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103371:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103373:	85 f6                	test   %esi,%esi
80103375:	7f 21                	jg     80103398 <growproc+0x36>
  } else if(n < 0){
80103377:	85 f6                	test   %esi,%esi
80103379:	79 33                	jns    801033ae <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010337b:	83 ec 04             	sub    $0x4,%esp
8010337e:	01 c6                	add    %eax,%esi
80103380:	56                   	push   %esi
80103381:	50                   	push   %eax
80103382:	ff 73 04             	pushl  0x4(%ebx)
80103385:	e8 9e 2e 00 00       	call   80106228 <deallocuvm>
8010338a:	83 c4 10             	add    $0x10,%esp
8010338d:	85 c0                	test   %eax,%eax
8010338f:	75 1d                	jne    801033ae <growproc+0x4c>
      return -1;
80103391:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103396:	eb 29                	jmp    801033c1 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103398:	83 ec 04             	sub    $0x4,%esp
8010339b:	01 c6                	add    %eax,%esi
8010339d:	56                   	push   %esi
8010339e:	50                   	push   %eax
8010339f:	ff 73 04             	pushl  0x4(%ebx)
801033a2:	e8 27 2f 00 00       	call   801062ce <allocuvm>
801033a7:	83 c4 10             	add    $0x10,%esp
801033aa:	85 c0                	test   %eax,%eax
801033ac:	74 1a                	je     801033c8 <growproc+0x66>
  curproc->sz = sz;
801033ae:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801033b0:	83 ec 0c             	sub    $0xc,%esp
801033b3:	53                   	push   %ebx
801033b4:	e8 0e 2c 00 00       	call   80105fc7 <switchuvm>
  return 0;
801033b9:	83 c4 10             	add    $0x10,%esp
801033bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033c4:	5b                   	pop    %ebx
801033c5:	5e                   	pop    %esi
801033c6:	5d                   	pop    %ebp
801033c7:	c3                   	ret    
      return -1;
801033c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033cd:	eb f2                	jmp    801033c1 <growproc+0x5f>

801033cf <fork>:
{
801033cf:	55                   	push   %ebp
801033d0:	89 e5                	mov    %esp,%ebp
801033d2:	57                   	push   %edi
801033d3:	56                   	push   %esi
801033d4:	53                   	push   %ebx
801033d5:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801033d8:	e8 7a fe ff ff       	call   80103257 <myproc>
801033dd:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033df:	e8 db fc ff ff       	call   801030bf <allocproc>
801033e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033e7:	85 c0                	test   %eax,%eax
801033e9:	0f 84 f5 00 00 00    	je     801034e4 <fork+0x115>
801033ef:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801033f1:	83 ec 08             	sub    $0x8,%esp
801033f4:	ff 33                	pushl  (%ebx)
801033f6:	ff 73 04             	pushl  0x4(%ebx)
801033f9:	e8 07 31 00 00       	call   80106505 <copyuvm>
801033fe:	89 47 04             	mov    %eax,0x4(%edi)
80103401:	83 c4 10             	add    $0x10,%esp
80103404:	85 c0                	test   %eax,%eax
80103406:	74 3f                	je     80103447 <fork+0x78>
  np->sz = curproc->sz;
80103408:	8b 03                	mov    (%ebx),%eax
8010340a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010340d:	89 07                	mov    %eax,(%edi)
  np->parent = curproc;
8010340f:	89 f8                	mov    %edi,%eax
80103411:	89 5f 14             	mov    %ebx,0x14(%edi)
  *np->tf = *curproc->tf;
80103414:	8b 73 18             	mov    0x18(%ebx),%esi
80103417:	8b 7f 18             	mov    0x18(%edi),%edi
8010341a:	b9 13 00 00 00       	mov    $0x13,%ecx
8010341f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->num_times_scheduled = 0;
80103421:	89 c1                	mov    %eax,%ecx
80103423:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  np->tickets = curproc->tickets;
8010342a:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
80103430:	89 81 80 00 00 00    	mov    %eax,0x80(%ecx)
  np->tf->eax = 0;
80103436:	8b 41 18             	mov    0x18(%ecx),%eax
80103439:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103440:	be 00 00 00 00       	mov    $0x0,%esi
80103445:	eb 29                	jmp    80103470 <fork+0xa1>
    kfree(np->kstack);
80103447:	83 ec 0c             	sub    $0xc,%esp
8010344a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010344d:	ff 73 08             	pushl  0x8(%ebx)
80103450:	e8 3d eb ff ff       	call   80101f92 <kfree>
    np->kstack = 0;
80103455:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010345c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103463:	83 c4 10             	add    $0x10,%esp
80103466:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010346b:	eb 6d                	jmp    801034da <fork+0x10b>
  for(i = 0; i < NOFILE; i++)
8010346d:	83 c6 01             	add    $0x1,%esi
80103470:	83 fe 0f             	cmp    $0xf,%esi
80103473:	7f 1d                	jg     80103492 <fork+0xc3>
    if(curproc->ofile[i])
80103475:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103479:	85 c0                	test   %eax,%eax
8010347b:	74 f0                	je     8010346d <fork+0x9e>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010347d:	83 ec 0c             	sub    $0xc,%esp
80103480:	50                   	push   %eax
80103481:	e8 08 d8 ff ff       	call   80100c8e <filedup>
80103486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103489:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
8010348d:	83 c4 10             	add    $0x10,%esp
80103490:	eb db                	jmp    8010346d <fork+0x9e>
  np->cwd = idup(curproc->cwd);
80103492:	83 ec 0c             	sub    $0xc,%esp
80103495:	ff 73 68             	pushl  0x68(%ebx)
80103498:	e8 a2 e0 ff ff       	call   8010153f <idup>
8010349d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801034a0:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034a3:	83 c3 6c             	add    $0x6c,%ebx
801034a6:	8d 47 6c             	lea    0x6c(%edi),%eax
801034a9:	83 c4 0c             	add    $0xc,%esp
801034ac:	6a 10                	push   $0x10
801034ae:	53                   	push   %ebx
801034af:	50                   	push   %eax
801034b0:	e8 80 09 00 00       	call   80103e35 <safestrcpy>
  pid = np->pid;
801034b5:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801034b8:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801034bf:	e8 5e 07 00 00       	call   80103c22 <acquire>
  np->state = RUNNABLE;
801034c4:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801034cb:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801034d2:	e8 b0 07 00 00       	call   80103c87 <release>
  return pid;
801034d7:	83 c4 10             	add    $0x10,%esp
}
801034da:	89 d8                	mov    %ebx,%eax
801034dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034df:	5b                   	pop    %ebx
801034e0:	5e                   	pop    %esi
801034e1:	5f                   	pop    %edi
801034e2:	5d                   	pop    %ebp
801034e3:	c3                   	ret    
    return -1;
801034e4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034e9:	eb ef                	jmp    801034da <fork+0x10b>

801034eb <scheduler>:
{
801034eb:	55                   	push   %ebp
801034ec:	89 e5                	mov    %esp,%ebp
801034ee:	56                   	push   %esi
801034ef:	53                   	push   %ebx
  struct cpu *c = mycpu();
801034f0:	e8 eb fc ff ff       	call   801031e0 <mycpu>
801034f5:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801034f7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801034fe:	00 00 00 
80103501:	eb 66                	jmp    80103569 <scheduler+0x7e>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103503:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103509:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
8010350f:	73 48                	jae    80103559 <scheduler+0x6e>
      if(p->state != RUNNABLE)
80103511:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103515:	75 ec                	jne    80103503 <scheduler+0x18>
      c->proc = p;
80103517:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010351d:	83 ec 0c             	sub    $0xc,%esp
80103520:	53                   	push   %ebx
80103521:	e8 a1 2a 00 00       	call   80105fc7 <switchuvm>
      p->state = RUNNING;
80103526:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      p->num_times_scheduled++;
8010352d:	8b 43 7c             	mov    0x7c(%ebx),%eax
80103530:	83 c0 01             	add    $0x1,%eax
80103533:	89 43 7c             	mov    %eax,0x7c(%ebx)
      swtch(&(c->scheduler), p->context);
80103536:	83 c4 08             	add    $0x8,%esp
80103539:	ff 73 1c             	pushl  0x1c(%ebx)
8010353c:	8d 46 04             	lea    0x4(%esi),%eax
8010353f:	50                   	push   %eax
80103540:	e8 43 09 00 00       	call   80103e88 <swtch>
      switchkvm();
80103545:	e8 58 2a 00 00       	call   80105fa2 <switchkvm>
      c->proc = 0;
8010354a:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103551:	00 00 00 
80103554:	83 c4 10             	add    $0x10,%esp
80103557:	eb aa                	jmp    80103503 <scheduler+0x18>
    release(&ptable.lock);
80103559:	83 ec 0c             	sub    $0xc,%esp
8010355c:	68 20 2d 11 80       	push   $0x80112d20
80103561:	e8 21 07 00 00       	call   80103c87 <release>
    sti();
80103566:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103569:	fb                   	sti    
    acquire(&ptable.lock);
8010356a:	83 ec 0c             	sub    $0xc,%esp
8010356d:	68 20 2d 11 80       	push   $0x80112d20
80103572:	e8 ab 06 00 00       	call   80103c22 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103577:	83 c4 10             	add    $0x10,%esp
8010357a:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010357f:	eb 88                	jmp    80103509 <scheduler+0x1e>

80103581 <sched>:
{
80103581:	55                   	push   %ebp
80103582:	89 e5                	mov    %esp,%ebp
80103584:	56                   	push   %esi
80103585:	53                   	push   %ebx
  struct proc *p = myproc();
80103586:	e8 cc fc ff ff       	call   80103257 <myproc>
8010358b:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010358d:	83 ec 0c             	sub    $0xc,%esp
80103590:	68 20 2d 11 80       	push   $0x80112d20
80103595:	e8 48 06 00 00       	call   80103be2 <holding>
8010359a:	83 c4 10             	add    $0x10,%esp
8010359d:	85 c0                	test   %eax,%eax
8010359f:	74 4f                	je     801035f0 <sched+0x6f>
  if(mycpu()->ncli != 1)
801035a1:	e8 3a fc ff ff       	call   801031e0 <mycpu>
801035a6:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801035ad:	75 4e                	jne    801035fd <sched+0x7c>
  if(p->state == RUNNING)
801035af:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801035b3:	74 55                	je     8010360a <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035b5:	9c                   	pushf  
801035b6:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801035b7:	f6 c4 02             	test   $0x2,%ah
801035ba:	75 5b                	jne    80103617 <sched+0x96>
  intena = mycpu()->intena;
801035bc:	e8 1f fc ff ff       	call   801031e0 <mycpu>
801035c1:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801035c7:	e8 14 fc ff ff       	call   801031e0 <mycpu>
801035cc:	83 ec 08             	sub    $0x8,%esp
801035cf:	ff 70 04             	pushl  0x4(%eax)
801035d2:	83 c3 1c             	add    $0x1c,%ebx
801035d5:	53                   	push   %ebx
801035d6:	e8 ad 08 00 00       	call   80103e88 <swtch>
  mycpu()->intena = intena;
801035db:	e8 00 fc ff ff       	call   801031e0 <mycpu>
801035e0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801035e6:	83 c4 10             	add    $0x10,%esp
801035e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035ec:	5b                   	pop    %ebx
801035ed:	5e                   	pop    %esi
801035ee:	5d                   	pop    %ebp
801035ef:	c3                   	ret    
    panic("sched ptable.lock");
801035f0:	83 ec 0c             	sub    $0xc,%esp
801035f3:	68 48 6d 10 80       	push   $0x80106d48
801035f8:	e8 4b cd ff ff       	call   80100348 <panic>
    panic("sched locks");
801035fd:	83 ec 0c             	sub    $0xc,%esp
80103600:	68 5a 6d 10 80       	push   $0x80106d5a
80103605:	e8 3e cd ff ff       	call   80100348 <panic>
    panic("sched running");
8010360a:	83 ec 0c             	sub    $0xc,%esp
8010360d:	68 66 6d 10 80       	push   $0x80106d66
80103612:	e8 31 cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103617:	83 ec 0c             	sub    $0xc,%esp
8010361a:	68 74 6d 10 80       	push   $0x80106d74
8010361f:	e8 24 cd ff ff       	call   80100348 <panic>

80103624 <exit>:
{
80103624:	55                   	push   %ebp
80103625:	89 e5                	mov    %esp,%ebp
80103627:	56                   	push   %esi
80103628:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103629:	e8 29 fc ff ff       	call   80103257 <myproc>
  if(curproc == initproc)
8010362e:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
80103634:	74 09                	je     8010363f <exit+0x1b>
80103636:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103638:	bb 00 00 00 00       	mov    $0x0,%ebx
8010363d:	eb 10                	jmp    8010364f <exit+0x2b>
    panic("init exiting");
8010363f:	83 ec 0c             	sub    $0xc,%esp
80103642:	68 88 6d 10 80       	push   $0x80106d88
80103647:	e8 fc cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010364c:	83 c3 01             	add    $0x1,%ebx
8010364f:	83 fb 0f             	cmp    $0xf,%ebx
80103652:	7f 1e                	jg     80103672 <exit+0x4e>
    if(curproc->ofile[fd]){
80103654:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103658:	85 c0                	test   %eax,%eax
8010365a:	74 f0                	je     8010364c <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010365c:	83 ec 0c             	sub    $0xc,%esp
8010365f:	50                   	push   %eax
80103660:	e8 6e d6 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103665:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010366c:	00 
8010366d:	83 c4 10             	add    $0x10,%esp
80103670:	eb da                	jmp    8010364c <exit+0x28>
  begin_op();
80103672:	e8 5b f1 ff ff       	call   801027d2 <begin_op>
  iput(curproc->cwd);
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	ff 76 68             	pushl  0x68(%esi)
8010367d:	e8 f4 df ff ff       	call   80101676 <iput>
  end_op();
80103682:	e8 c5 f1 ff ff       	call   8010284c <end_op>
  curproc->cwd = 0;
80103687:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010368e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103695:	e8 88 05 00 00       	call   80103c22 <acquire>
  wakeup1(curproc->parent);
8010369a:	8b 46 14             	mov    0x14(%esi),%eax
8010369d:	e8 ef f9 ff ff       	call   80103091 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036a2:	83 c4 10             	add    $0x10,%esp
801036a5:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801036aa:	eb 06                	jmp    801036b2 <exit+0x8e>
801036ac:	81 c3 84 00 00 00    	add    $0x84,%ebx
801036b2:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
801036b8:	73 1a                	jae    801036d4 <exit+0xb0>
    if(p->parent == curproc){
801036ba:	39 73 14             	cmp    %esi,0x14(%ebx)
801036bd:	75 ed                	jne    801036ac <exit+0x88>
      p->parent = initproc;
801036bf:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801036c4:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801036c7:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801036cb:	75 df                	jne    801036ac <exit+0x88>
        wakeup1(initproc);
801036cd:	e8 bf f9 ff ff       	call   80103091 <wakeup1>
801036d2:	eb d8                	jmp    801036ac <exit+0x88>
  curproc->state = ZOMBIE;
801036d4:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801036db:	e8 a1 fe ff ff       	call   80103581 <sched>
  panic("zombie exit");
801036e0:	83 ec 0c             	sub    $0xc,%esp
801036e3:	68 95 6d 10 80       	push   $0x80106d95
801036e8:	e8 5b cc ff ff       	call   80100348 <panic>

801036ed <yield>:
{
801036ed:	55                   	push   %ebp
801036ee:	89 e5                	mov    %esp,%ebp
801036f0:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801036f3:	68 20 2d 11 80       	push   $0x80112d20
801036f8:	e8 25 05 00 00       	call   80103c22 <acquire>
  myproc()->state = RUNNABLE;
801036fd:	e8 55 fb ff ff       	call   80103257 <myproc>
80103702:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103709:	e8 73 fe ff ff       	call   80103581 <sched>
  release(&ptable.lock);
8010370e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103715:	e8 6d 05 00 00       	call   80103c87 <release>
}
8010371a:	83 c4 10             	add    $0x10,%esp
8010371d:	c9                   	leave  
8010371e:	c3                   	ret    

8010371f <sleep>:
{
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	56                   	push   %esi
80103723:	53                   	push   %ebx
80103724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103727:	e8 2b fb ff ff       	call   80103257 <myproc>
  if(p == 0)
8010372c:	85 c0                	test   %eax,%eax
8010372e:	74 66                	je     80103796 <sleep+0x77>
80103730:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103732:	85 db                	test   %ebx,%ebx
80103734:	74 6d                	je     801037a3 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103736:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
8010373c:	74 18                	je     80103756 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010373e:	83 ec 0c             	sub    $0xc,%esp
80103741:	68 20 2d 11 80       	push   $0x80112d20
80103746:	e8 d7 04 00 00       	call   80103c22 <acquire>
    release(lk);
8010374b:	89 1c 24             	mov    %ebx,(%esp)
8010374e:	e8 34 05 00 00       	call   80103c87 <release>
80103753:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103756:	8b 45 08             	mov    0x8(%ebp),%eax
80103759:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
8010375c:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103763:	e8 19 fe ff ff       	call   80103581 <sched>
  p->chan = 0;
80103768:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010376f:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
80103775:	74 18                	je     8010378f <sleep+0x70>
    release(&ptable.lock);
80103777:	83 ec 0c             	sub    $0xc,%esp
8010377a:	68 20 2d 11 80       	push   $0x80112d20
8010377f:	e8 03 05 00 00       	call   80103c87 <release>
    acquire(lk);
80103784:	89 1c 24             	mov    %ebx,(%esp)
80103787:	e8 96 04 00 00       	call   80103c22 <acquire>
8010378c:	83 c4 10             	add    $0x10,%esp
}
8010378f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103792:	5b                   	pop    %ebx
80103793:	5e                   	pop    %esi
80103794:	5d                   	pop    %ebp
80103795:	c3                   	ret    
    panic("sleep");
80103796:	83 ec 0c             	sub    $0xc,%esp
80103799:	68 a1 6d 10 80       	push   $0x80106da1
8010379e:	e8 a5 cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801037a3:	83 ec 0c             	sub    $0xc,%esp
801037a6:	68 a7 6d 10 80       	push   $0x80106da7
801037ab:	e8 98 cb ff ff       	call   80100348 <panic>

801037b0 <wait>:
{
801037b0:	55                   	push   %ebp
801037b1:	89 e5                	mov    %esp,%ebp
801037b3:	56                   	push   %esi
801037b4:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037b5:	e8 9d fa ff ff       	call   80103257 <myproc>
801037ba:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801037bc:	83 ec 0c             	sub    $0xc,%esp
801037bf:	68 20 2d 11 80       	push   $0x80112d20
801037c4:	e8 59 04 00 00       	call   80103c22 <acquire>
801037c9:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801037cc:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037d1:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801037d6:	eb 5e                	jmp    80103836 <wait+0x86>
        pid = p->pid;
801037d8:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801037db:	83 ec 0c             	sub    $0xc,%esp
801037de:	ff 73 08             	pushl  0x8(%ebx)
801037e1:	e8 ac e7 ff ff       	call   80101f92 <kfree>
        p->kstack = 0;
801037e6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801037ed:	83 c4 04             	add    $0x4,%esp
801037f0:	ff 73 04             	pushl  0x4(%ebx)
801037f3:	e8 d8 2b 00 00       	call   801063d0 <freevm>
        p->pid = 0;
801037f8:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801037ff:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103806:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
8010380a:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103811:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103818:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010381f:	e8 63 04 00 00       	call   80103c87 <release>
        return pid;
80103824:	83 c4 10             	add    $0x10,%esp
}
80103827:	89 f0                	mov    %esi,%eax
80103829:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010382c:	5b                   	pop    %ebx
8010382d:	5e                   	pop    %esi
8010382e:	5d                   	pop    %ebp
8010382f:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103830:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103836:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
8010383c:	73 12                	jae    80103850 <wait+0xa0>
      if(p->parent != curproc)
8010383e:	39 73 14             	cmp    %esi,0x14(%ebx)
80103841:	75 ed                	jne    80103830 <wait+0x80>
      if(p->state == ZOMBIE){
80103843:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103847:	74 8f                	je     801037d8 <wait+0x28>
      havekids = 1;
80103849:	b8 01 00 00 00       	mov    $0x1,%eax
8010384e:	eb e0                	jmp    80103830 <wait+0x80>
    if(!havekids || curproc->killed){
80103850:	85 c0                	test   %eax,%eax
80103852:	74 06                	je     8010385a <wait+0xaa>
80103854:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103858:	74 17                	je     80103871 <wait+0xc1>
      release(&ptable.lock);
8010385a:	83 ec 0c             	sub    $0xc,%esp
8010385d:	68 20 2d 11 80       	push   $0x80112d20
80103862:	e8 20 04 00 00       	call   80103c87 <release>
      return -1;
80103867:	83 c4 10             	add    $0x10,%esp
8010386a:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010386f:	eb b6                	jmp    80103827 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103871:	83 ec 08             	sub    $0x8,%esp
80103874:	68 20 2d 11 80       	push   $0x80112d20
80103879:	56                   	push   %esi
8010387a:	e8 a0 fe ff ff       	call   8010371f <sleep>
    havekids = 0;
8010387f:	83 c4 10             	add    $0x10,%esp
80103882:	e9 45 ff ff ff       	jmp    801037cc <wait+0x1c>

80103887 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103887:	55                   	push   %ebp
80103888:	89 e5                	mov    %esp,%ebp
8010388a:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010388d:	68 20 2d 11 80       	push   $0x80112d20
80103892:	e8 8b 03 00 00       	call   80103c22 <acquire>
  wakeup1(chan);
80103897:	8b 45 08             	mov    0x8(%ebp),%eax
8010389a:	e8 f2 f7 ff ff       	call   80103091 <wakeup1>
  release(&ptable.lock);
8010389f:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038a6:	e8 dc 03 00 00       	call   80103c87 <release>
}
801038ab:	83 c4 10             	add    $0x10,%esp
801038ae:	c9                   	leave  
801038af:	c3                   	ret    

801038b0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801038b0:	55                   	push   %ebp
801038b1:	89 e5                	mov    %esp,%ebp
801038b3:	53                   	push   %ebx
801038b4:	83 ec 10             	sub    $0x10,%esp
801038b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038ba:	68 20 2d 11 80       	push   $0x80112d20
801038bf:	e8 5e 03 00 00       	call   80103c22 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038c4:	83 c4 10             	add    $0x10,%esp
801038c7:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
801038cc:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
801038d1:	73 3c                	jae    8010390f <kill+0x5f>
    if(p->pid == pid){
801038d3:	39 58 10             	cmp    %ebx,0x10(%eax)
801038d6:	74 07                	je     801038df <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038d8:	05 84 00 00 00       	add    $0x84,%eax
801038dd:	eb ed                	jmp    801038cc <kill+0x1c>
      p->killed = 1;
801038df:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801038e6:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801038ea:	74 1a                	je     80103906 <kill+0x56>
        p->state = RUNNABLE;
      release(&ptable.lock);
801038ec:	83 ec 0c             	sub    $0xc,%esp
801038ef:	68 20 2d 11 80       	push   $0x80112d20
801038f4:	e8 8e 03 00 00       	call   80103c87 <release>
      return 0;
801038f9:	83 c4 10             	add    $0x10,%esp
801038fc:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103904:	c9                   	leave  
80103905:	c3                   	ret    
        p->state = RUNNABLE;
80103906:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
8010390d:	eb dd                	jmp    801038ec <kill+0x3c>
  release(&ptable.lock);
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	68 20 2d 11 80       	push   $0x80112d20
80103917:	e8 6b 03 00 00       	call   80103c87 <release>
  return -1;
8010391c:	83 c4 10             	add    $0x10,%esp
8010391f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103924:	eb db                	jmp    80103901 <kill+0x51>

80103926 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103926:	55                   	push   %ebp
80103927:	89 e5                	mov    %esp,%ebp
80103929:	56                   	push   %esi
8010392a:	53                   	push   %ebx
8010392b:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010392e:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103933:	eb 36                	jmp    8010396b <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103935:	b8 b8 6d 10 80       	mov    $0x80106db8,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010393a:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010393d:	52                   	push   %edx
8010393e:	50                   	push   %eax
8010393f:	ff 73 10             	pushl  0x10(%ebx)
80103942:	68 bc 6d 10 80       	push   $0x80106dbc
80103947:	e8 bf cc ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
8010394c:	83 c4 10             	add    $0x10,%esp
8010394f:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103953:	74 3c                	je     80103991 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103955:	83 ec 0c             	sub    $0xc,%esp
80103958:	68 4f 71 10 80       	push   $0x8010714f
8010395d:	e8 a9 cc ff ff       	call   8010060b <cprintf>
80103962:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103965:	81 c3 84 00 00 00    	add    $0x84,%ebx
8010396b:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103971:	73 61                	jae    801039d4 <procdump+0xae>
    if(p->state == UNUSED)
80103973:	8b 43 0c             	mov    0xc(%ebx),%eax
80103976:	85 c0                	test   %eax,%eax
80103978:	74 eb                	je     80103965 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010397a:	83 f8 05             	cmp    $0x5,%eax
8010397d:	77 b6                	ja     80103935 <procdump+0xf>
8010397f:	8b 04 85 18 6e 10 80 	mov    -0x7fef91e8(,%eax,4),%eax
80103986:	85 c0                	test   %eax,%eax
80103988:	75 b0                	jne    8010393a <procdump+0x14>
      state = "???";
8010398a:	b8 b8 6d 10 80       	mov    $0x80106db8,%eax
8010398f:	eb a9                	jmp    8010393a <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103991:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103994:	8b 40 0c             	mov    0xc(%eax),%eax
80103997:	83 c0 08             	add    $0x8,%eax
8010399a:	83 ec 08             	sub    $0x8,%esp
8010399d:	8d 55 d0             	lea    -0x30(%ebp),%edx
801039a0:	52                   	push   %edx
801039a1:	50                   	push   %eax
801039a2:	e8 5a 01 00 00       	call   80103b01 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801039a7:	83 c4 10             	add    $0x10,%esp
801039aa:	be 00 00 00 00       	mov    $0x0,%esi
801039af:	eb 14                	jmp    801039c5 <procdump+0x9f>
        cprintf(" %p", pc[i]);
801039b1:	83 ec 08             	sub    $0x8,%esp
801039b4:	50                   	push   %eax
801039b5:	68 41 67 10 80       	push   $0x80106741
801039ba:	e8 4c cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801039bf:	83 c6 01             	add    $0x1,%esi
801039c2:	83 c4 10             	add    $0x10,%esp
801039c5:	83 fe 09             	cmp    $0x9,%esi
801039c8:	7f 8b                	jg     80103955 <procdump+0x2f>
801039ca:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
801039ce:	85 c0                	test   %eax,%eax
801039d0:	75 df                	jne    801039b1 <procdump+0x8b>
801039d2:	eb 81                	jmp    80103955 <procdump+0x2f>
  }
}
801039d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039d7:	5b                   	pop    %ebx
801039d8:	5e                   	pop    %esi
801039d9:	5d                   	pop    %ebp
801039da:	c3                   	ret    

801039db <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801039db:	55                   	push   %ebp
801039dc:	89 e5                	mov    %esp,%ebp
801039de:	53                   	push   %ebx
801039df:	83 ec 0c             	sub    $0xc,%esp
801039e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801039e5:	68 30 6e 10 80       	push   $0x80106e30
801039ea:	8d 43 04             	lea    0x4(%ebx),%eax
801039ed:	50                   	push   %eax
801039ee:	e8 f3 00 00 00       	call   80103ae6 <initlock>
  lk->name = name;
801039f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801039f6:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
801039f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801039ff:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a06:	83 c4 10             	add    $0x10,%esp
80103a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a0c:	c9                   	leave  
80103a0d:	c3                   	ret    

80103a0e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a0e:	55                   	push   %ebp
80103a0f:	89 e5                	mov    %esp,%ebp
80103a11:	56                   	push   %esi
80103a12:	53                   	push   %ebx
80103a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a16:	8d 73 04             	lea    0x4(%ebx),%esi
80103a19:	83 ec 0c             	sub    $0xc,%esp
80103a1c:	56                   	push   %esi
80103a1d:	e8 00 02 00 00       	call   80103c22 <acquire>
  while (lk->locked) {
80103a22:	83 c4 10             	add    $0x10,%esp
80103a25:	eb 0d                	jmp    80103a34 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103a27:	83 ec 08             	sub    $0x8,%esp
80103a2a:	56                   	push   %esi
80103a2b:	53                   	push   %ebx
80103a2c:	e8 ee fc ff ff       	call   8010371f <sleep>
80103a31:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103a34:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a37:	75 ee                	jne    80103a27 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103a39:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103a3f:	e8 13 f8 ff ff       	call   80103257 <myproc>
80103a44:	8b 40 10             	mov    0x10(%eax),%eax
80103a47:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103a4a:	83 ec 0c             	sub    $0xc,%esp
80103a4d:	56                   	push   %esi
80103a4e:	e8 34 02 00 00       	call   80103c87 <release>
}
80103a53:	83 c4 10             	add    $0x10,%esp
80103a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a59:	5b                   	pop    %ebx
80103a5a:	5e                   	pop    %esi
80103a5b:	5d                   	pop    %ebp
80103a5c:	c3                   	ret    

80103a5d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103a5d:	55                   	push   %ebp
80103a5e:	89 e5                	mov    %esp,%ebp
80103a60:	56                   	push   %esi
80103a61:	53                   	push   %ebx
80103a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a65:	8d 73 04             	lea    0x4(%ebx),%esi
80103a68:	83 ec 0c             	sub    $0xc,%esp
80103a6b:	56                   	push   %esi
80103a6c:	e8 b1 01 00 00       	call   80103c22 <acquire>
  lk->locked = 0;
80103a71:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a77:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103a7e:	89 1c 24             	mov    %ebx,(%esp)
80103a81:	e8 01 fe ff ff       	call   80103887 <wakeup>
  release(&lk->lk);
80103a86:	89 34 24             	mov    %esi,(%esp)
80103a89:	e8 f9 01 00 00       	call   80103c87 <release>
}
80103a8e:	83 c4 10             	add    $0x10,%esp
80103a91:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a94:	5b                   	pop    %ebx
80103a95:	5e                   	pop    %esi
80103a96:	5d                   	pop    %ebp
80103a97:	c3                   	ret    

80103a98 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103a98:	55                   	push   %ebp
80103a99:	89 e5                	mov    %esp,%ebp
80103a9b:	56                   	push   %esi
80103a9c:	53                   	push   %ebx
80103a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103aa0:	8d 73 04             	lea    0x4(%ebx),%esi
80103aa3:	83 ec 0c             	sub    $0xc,%esp
80103aa6:	56                   	push   %esi
80103aa7:	e8 76 01 00 00       	call   80103c22 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103aac:	83 c4 10             	add    $0x10,%esp
80103aaf:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ab2:	75 17                	jne    80103acb <holdingsleep+0x33>
80103ab4:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103ab9:	83 ec 0c             	sub    $0xc,%esp
80103abc:	56                   	push   %esi
80103abd:	e8 c5 01 00 00       	call   80103c87 <release>
  return r;
}
80103ac2:	89 d8                	mov    %ebx,%eax
80103ac4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ac7:	5b                   	pop    %ebx
80103ac8:	5e                   	pop    %esi
80103ac9:	5d                   	pop    %ebp
80103aca:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103acb:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103ace:	e8 84 f7 ff ff       	call   80103257 <myproc>
80103ad3:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ad6:	74 07                	je     80103adf <holdingsleep+0x47>
80103ad8:	bb 00 00 00 00       	mov    $0x0,%ebx
80103add:	eb da                	jmp    80103ab9 <holdingsleep+0x21>
80103adf:	bb 01 00 00 00       	mov    $0x1,%ebx
80103ae4:	eb d3                	jmp    80103ab9 <holdingsleep+0x21>

80103ae6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103ae6:	55                   	push   %ebp
80103ae7:	89 e5                	mov    %esp,%ebp
80103ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103aec:	8b 55 0c             	mov    0xc(%ebp),%edx
80103aef:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103af2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103af8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103aff:	5d                   	pop    %ebp
80103b00:	c3                   	ret    

80103b01 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b01:	55                   	push   %ebp
80103b02:	89 e5                	mov    %esp,%ebp
80103b04:	53                   	push   %ebx
80103b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b08:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0b:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b0e:	b8 00 00 00 00       	mov    $0x0,%eax
80103b13:	83 f8 09             	cmp    $0x9,%eax
80103b16:	7f 25                	jg     80103b3d <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b18:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b1e:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b24:	77 17                	ja     80103b3d <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b26:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b29:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b2c:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b2e:	83 c0 01             	add    $0x1,%eax
80103b31:	eb e0                	jmp    80103b13 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b33:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b3a:	83 c0 01             	add    $0x1,%eax
80103b3d:	83 f8 09             	cmp    $0x9,%eax
80103b40:	7e f1                	jle    80103b33 <getcallerpcs+0x32>
}
80103b42:	5b                   	pop    %ebx
80103b43:	5d                   	pop    %ebp
80103b44:	c3                   	ret    

80103b45 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b45:	55                   	push   %ebp
80103b46:	89 e5                	mov    %esp,%ebp
80103b48:	53                   	push   %ebx
80103b49:	83 ec 04             	sub    $0x4,%esp
80103b4c:	9c                   	pushf  
80103b4d:	5b                   	pop    %ebx
  asm volatile("cli");
80103b4e:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b4f:	e8 8c f6 ff ff       	call   801031e0 <mycpu>
80103b54:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b5b:	74 12                	je     80103b6f <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103b5d:	e8 7e f6 ff ff       	call   801031e0 <mycpu>
80103b62:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103b69:	83 c4 04             	add    $0x4,%esp
80103b6c:	5b                   	pop    %ebx
80103b6d:	5d                   	pop    %ebp
80103b6e:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103b6f:	e8 6c f6 ff ff       	call   801031e0 <mycpu>
80103b74:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103b7a:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103b80:	eb db                	jmp    80103b5d <pushcli+0x18>

80103b82 <popcli>:

void
popcli(void)
{
80103b82:	55                   	push   %ebp
80103b83:	89 e5                	mov    %esp,%ebp
80103b85:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b88:	9c                   	pushf  
80103b89:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103b8a:	f6 c4 02             	test   $0x2,%ah
80103b8d:	75 28                	jne    80103bb7 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103b8f:	e8 4c f6 ff ff       	call   801031e0 <mycpu>
80103b94:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103b9a:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103b9d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103ba3:	85 d2                	test   %edx,%edx
80103ba5:	78 1d                	js     80103bc4 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103ba7:	e8 34 f6 ff ff       	call   801031e0 <mycpu>
80103bac:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bb3:	74 1c                	je     80103bd1 <popcli+0x4f>
    sti();
}
80103bb5:	c9                   	leave  
80103bb6:	c3                   	ret    
    panic("popcli - interruptible");
80103bb7:	83 ec 0c             	sub    $0xc,%esp
80103bba:	68 3b 6e 10 80       	push   $0x80106e3b
80103bbf:	e8 84 c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103bc4:	83 ec 0c             	sub    $0xc,%esp
80103bc7:	68 52 6e 10 80       	push   $0x80106e52
80103bcc:	e8 77 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bd1:	e8 0a f6 ff ff       	call   801031e0 <mycpu>
80103bd6:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103bdd:	74 d6                	je     80103bb5 <popcli+0x33>
  asm volatile("sti");
80103bdf:	fb                   	sti    
}
80103be0:	eb d3                	jmp    80103bb5 <popcli+0x33>

80103be2 <holding>:
{
80103be2:	55                   	push   %ebp
80103be3:	89 e5                	mov    %esp,%ebp
80103be5:	53                   	push   %ebx
80103be6:	83 ec 04             	sub    $0x4,%esp
80103be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103bec:	e8 54 ff ff ff       	call   80103b45 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103bf1:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bf4:	75 12                	jne    80103c08 <holding+0x26>
80103bf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103bfb:	e8 82 ff ff ff       	call   80103b82 <popcli>
}
80103c00:	89 d8                	mov    %ebx,%eax
80103c02:	83 c4 04             	add    $0x4,%esp
80103c05:	5b                   	pop    %ebx
80103c06:	5d                   	pop    %ebp
80103c07:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c08:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c0b:	e8 d0 f5 ff ff       	call   801031e0 <mycpu>
80103c10:	39 c3                	cmp    %eax,%ebx
80103c12:	74 07                	je     80103c1b <holding+0x39>
80103c14:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c19:	eb e0                	jmp    80103bfb <holding+0x19>
80103c1b:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c20:	eb d9                	jmp    80103bfb <holding+0x19>

80103c22 <acquire>:
{
80103c22:	55                   	push   %ebp
80103c23:	89 e5                	mov    %esp,%ebp
80103c25:	53                   	push   %ebx
80103c26:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c29:	e8 17 ff ff ff       	call   80103b45 <pushcli>
  if(holding(lk))
80103c2e:	83 ec 0c             	sub    $0xc,%esp
80103c31:	ff 75 08             	pushl  0x8(%ebp)
80103c34:	e8 a9 ff ff ff       	call   80103be2 <holding>
80103c39:	83 c4 10             	add    $0x10,%esp
80103c3c:	85 c0                	test   %eax,%eax
80103c3e:	75 3a                	jne    80103c7a <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103c40:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103c43:	b8 01 00 00 00       	mov    $0x1,%eax
80103c48:	f0 87 02             	lock xchg %eax,(%edx)
80103c4b:	85 c0                	test   %eax,%eax
80103c4d:	75 f1                	jne    80103c40 <acquire+0x1e>
  __sync_synchronize();
80103c4f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103c54:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c57:	e8 84 f5 ff ff       	call   801031e0 <mycpu>
80103c5c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c62:	83 c0 0c             	add    $0xc,%eax
80103c65:	83 ec 08             	sub    $0x8,%esp
80103c68:	50                   	push   %eax
80103c69:	8d 45 08             	lea    0x8(%ebp),%eax
80103c6c:	50                   	push   %eax
80103c6d:	e8 8f fe ff ff       	call   80103b01 <getcallerpcs>
}
80103c72:	83 c4 10             	add    $0x10,%esp
80103c75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c78:	c9                   	leave  
80103c79:	c3                   	ret    
    panic("acquire");
80103c7a:	83 ec 0c             	sub    $0xc,%esp
80103c7d:	68 59 6e 10 80       	push   $0x80106e59
80103c82:	e8 c1 c6 ff ff       	call   80100348 <panic>

80103c87 <release>:
{
80103c87:	55                   	push   %ebp
80103c88:	89 e5                	mov    %esp,%ebp
80103c8a:	53                   	push   %ebx
80103c8b:	83 ec 10             	sub    $0x10,%esp
80103c8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103c91:	53                   	push   %ebx
80103c92:	e8 4b ff ff ff       	call   80103be2 <holding>
80103c97:	83 c4 10             	add    $0x10,%esp
80103c9a:	85 c0                	test   %eax,%eax
80103c9c:	74 23                	je     80103cc1 <release+0x3a>
  lk->pcs[0] = 0;
80103c9e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103ca5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103cac:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103cb1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103cb7:	e8 c6 fe ff ff       	call   80103b82 <popcli>
}
80103cbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cbf:	c9                   	leave  
80103cc0:	c3                   	ret    
    panic("release");
80103cc1:	83 ec 0c             	sub    $0xc,%esp
80103cc4:	68 61 6e 10 80       	push   $0x80106e61
80103cc9:	e8 7a c6 ff ff       	call   80100348 <panic>

80103cce <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103cce:	55                   	push   %ebp
80103ccf:	89 e5                	mov    %esp,%ebp
80103cd1:	57                   	push   %edi
80103cd2:	53                   	push   %ebx
80103cd3:	8b 55 08             	mov    0x8(%ebp),%edx
80103cd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103cd9:	f6 c2 03             	test   $0x3,%dl
80103cdc:	75 05                	jne    80103ce3 <memset+0x15>
80103cde:	f6 c1 03             	test   $0x3,%cl
80103ce1:	74 0e                	je     80103cf1 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103ce3:	89 d7                	mov    %edx,%edi
80103ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce8:	fc                   	cld    
80103ce9:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103ceb:	89 d0                	mov    %edx,%eax
80103ced:	5b                   	pop    %ebx
80103cee:	5f                   	pop    %edi
80103cef:	5d                   	pop    %ebp
80103cf0:	c3                   	ret    
    c &= 0xFF;
80103cf1:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103cf5:	c1 e9 02             	shr    $0x2,%ecx
80103cf8:	89 f8                	mov    %edi,%eax
80103cfa:	c1 e0 18             	shl    $0x18,%eax
80103cfd:	89 fb                	mov    %edi,%ebx
80103cff:	c1 e3 10             	shl    $0x10,%ebx
80103d02:	09 d8                	or     %ebx,%eax
80103d04:	89 fb                	mov    %edi,%ebx
80103d06:	c1 e3 08             	shl    $0x8,%ebx
80103d09:	09 d8                	or     %ebx,%eax
80103d0b:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103d0d:	89 d7                	mov    %edx,%edi
80103d0f:	fc                   	cld    
80103d10:	f3 ab                	rep stos %eax,%es:(%edi)
80103d12:	eb d7                	jmp    80103ceb <memset+0x1d>

80103d14 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103d14:	55                   	push   %ebp
80103d15:	89 e5                	mov    %esp,%ebp
80103d17:	56                   	push   %esi
80103d18:	53                   	push   %ebx
80103d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d1f:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103d22:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d25:	85 c0                	test   %eax,%eax
80103d27:	74 1c                	je     80103d45 <memcmp+0x31>
    if(*s1 != *s2)
80103d29:	0f b6 01             	movzbl (%ecx),%eax
80103d2c:	0f b6 1a             	movzbl (%edx),%ebx
80103d2f:	38 d8                	cmp    %bl,%al
80103d31:	75 0a                	jne    80103d3d <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103d33:	83 c1 01             	add    $0x1,%ecx
80103d36:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103d39:	89 f0                	mov    %esi,%eax
80103d3b:	eb e5                	jmp    80103d22 <memcmp+0xe>
      return *s1 - *s2;
80103d3d:	0f b6 c0             	movzbl %al,%eax
80103d40:	0f b6 db             	movzbl %bl,%ebx
80103d43:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103d45:	5b                   	pop    %ebx
80103d46:	5e                   	pop    %esi
80103d47:	5d                   	pop    %ebp
80103d48:	c3                   	ret    

80103d49 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103d49:	55                   	push   %ebp
80103d4a:	89 e5                	mov    %esp,%ebp
80103d4c:	56                   	push   %esi
80103d4d:	53                   	push   %ebx
80103d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d54:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103d57:	39 c1                	cmp    %eax,%ecx
80103d59:	73 3a                	jae    80103d95 <memmove+0x4c>
80103d5b:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103d5e:	39 c3                	cmp    %eax,%ebx
80103d60:	76 37                	jbe    80103d99 <memmove+0x50>
    s += n;
    d += n;
80103d62:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103d65:	eb 0d                	jmp    80103d74 <memmove+0x2b>
      *--d = *--s;
80103d67:	83 eb 01             	sub    $0x1,%ebx
80103d6a:	83 e9 01             	sub    $0x1,%ecx
80103d6d:	0f b6 13             	movzbl (%ebx),%edx
80103d70:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103d72:	89 f2                	mov    %esi,%edx
80103d74:	8d 72 ff             	lea    -0x1(%edx),%esi
80103d77:	85 d2                	test   %edx,%edx
80103d79:	75 ec                	jne    80103d67 <memmove+0x1e>
80103d7b:	eb 14                	jmp    80103d91 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103d7d:	0f b6 11             	movzbl (%ecx),%edx
80103d80:	88 13                	mov    %dl,(%ebx)
80103d82:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103d85:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103d88:	89 f2                	mov    %esi,%edx
80103d8a:	8d 72 ff             	lea    -0x1(%edx),%esi
80103d8d:	85 d2                	test   %edx,%edx
80103d8f:	75 ec                	jne    80103d7d <memmove+0x34>

  return dst;
}
80103d91:	5b                   	pop    %ebx
80103d92:	5e                   	pop    %esi
80103d93:	5d                   	pop    %ebp
80103d94:	c3                   	ret    
80103d95:	89 c3                	mov    %eax,%ebx
80103d97:	eb f1                	jmp    80103d8a <memmove+0x41>
80103d99:	89 c3                	mov    %eax,%ebx
80103d9b:	eb ed                	jmp    80103d8a <memmove+0x41>

80103d9d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103d9d:	55                   	push   %ebp
80103d9e:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103da0:	ff 75 10             	pushl  0x10(%ebp)
80103da3:	ff 75 0c             	pushl  0xc(%ebp)
80103da6:	ff 75 08             	pushl  0x8(%ebp)
80103da9:	e8 9b ff ff ff       	call   80103d49 <memmove>
}
80103dae:	c9                   	leave  
80103daf:	c3                   	ret    

80103db0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103db0:	55                   	push   %ebp
80103db1:	89 e5                	mov    %esp,%ebp
80103db3:	53                   	push   %ebx
80103db4:	8b 55 08             	mov    0x8(%ebp),%edx
80103db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103dba:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103dbd:	eb 09                	jmp    80103dc8 <strncmp+0x18>
    n--, p++, q++;
80103dbf:	83 e8 01             	sub    $0x1,%eax
80103dc2:	83 c2 01             	add    $0x1,%edx
80103dc5:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103dc8:	85 c0                	test   %eax,%eax
80103dca:	74 0b                	je     80103dd7 <strncmp+0x27>
80103dcc:	0f b6 1a             	movzbl (%edx),%ebx
80103dcf:	84 db                	test   %bl,%bl
80103dd1:	74 04                	je     80103dd7 <strncmp+0x27>
80103dd3:	3a 19                	cmp    (%ecx),%bl
80103dd5:	74 e8                	je     80103dbf <strncmp+0xf>
  if(n == 0)
80103dd7:	85 c0                	test   %eax,%eax
80103dd9:	74 0b                	je     80103de6 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103ddb:	0f b6 02             	movzbl (%edx),%eax
80103dde:	0f b6 11             	movzbl (%ecx),%edx
80103de1:	29 d0                	sub    %edx,%eax
}
80103de3:	5b                   	pop    %ebx
80103de4:	5d                   	pop    %ebp
80103de5:	c3                   	ret    
    return 0;
80103de6:	b8 00 00 00 00       	mov    $0x0,%eax
80103deb:	eb f6                	jmp    80103de3 <strncmp+0x33>

80103ded <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103ded:	55                   	push   %ebp
80103dee:	89 e5                	mov    %esp,%ebp
80103df0:	57                   	push   %edi
80103df1:	56                   	push   %esi
80103df2:	53                   	push   %ebx
80103df3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103df6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103df9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dfc:	eb 04                	jmp    80103e02 <strncpy+0x15>
80103dfe:	89 fb                	mov    %edi,%ebx
80103e00:	89 f0                	mov    %esi,%eax
80103e02:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e05:	85 c9                	test   %ecx,%ecx
80103e07:	7e 1d                	jle    80103e26 <strncpy+0x39>
80103e09:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e0c:	8d 70 01             	lea    0x1(%eax),%esi
80103e0f:	0f b6 1b             	movzbl (%ebx),%ebx
80103e12:	88 18                	mov    %bl,(%eax)
80103e14:	89 d1                	mov    %edx,%ecx
80103e16:	84 db                	test   %bl,%bl
80103e18:	75 e4                	jne    80103dfe <strncpy+0x11>
80103e1a:	89 f0                	mov    %esi,%eax
80103e1c:	eb 08                	jmp    80103e26 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103e1e:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103e21:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103e23:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103e26:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e29:	85 d2                	test   %edx,%edx
80103e2b:	7f f1                	jg     80103e1e <strncpy+0x31>
  return os;
}
80103e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e30:	5b                   	pop    %ebx
80103e31:	5e                   	pop    %esi
80103e32:	5f                   	pop    %edi
80103e33:	5d                   	pop    %ebp
80103e34:	c3                   	ret    

80103e35 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103e35:	55                   	push   %ebp
80103e36:	89 e5                	mov    %esp,%ebp
80103e38:	57                   	push   %edi
80103e39:	56                   	push   %esi
80103e3a:	53                   	push   %ebx
80103e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e41:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103e44:	85 d2                	test   %edx,%edx
80103e46:	7e 23                	jle    80103e6b <safestrcpy+0x36>
80103e48:	89 c1                	mov    %eax,%ecx
80103e4a:	eb 04                	jmp    80103e50 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103e4c:	89 fb                	mov    %edi,%ebx
80103e4e:	89 f1                	mov    %esi,%ecx
80103e50:	83 ea 01             	sub    $0x1,%edx
80103e53:	85 d2                	test   %edx,%edx
80103e55:	7e 11                	jle    80103e68 <safestrcpy+0x33>
80103e57:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e5a:	8d 71 01             	lea    0x1(%ecx),%esi
80103e5d:	0f b6 1b             	movzbl (%ebx),%ebx
80103e60:	88 19                	mov    %bl,(%ecx)
80103e62:	84 db                	test   %bl,%bl
80103e64:	75 e6                	jne    80103e4c <safestrcpy+0x17>
80103e66:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103e68:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103e6b:	5b                   	pop    %ebx
80103e6c:	5e                   	pop    %esi
80103e6d:	5f                   	pop    %edi
80103e6e:	5d                   	pop    %ebp
80103e6f:	c3                   	ret    

80103e70 <strlen>:

int
strlen(const char *s)
{
80103e70:	55                   	push   %ebp
80103e71:	89 e5                	mov    %esp,%ebp
80103e73:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103e76:	b8 00 00 00 00       	mov    $0x0,%eax
80103e7b:	eb 03                	jmp    80103e80 <strlen+0x10>
80103e7d:	83 c0 01             	add    $0x1,%eax
80103e80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103e84:	75 f7                	jne    80103e7d <strlen+0xd>
    ;
  return n;
}
80103e86:	5d                   	pop    %ebp
80103e87:	c3                   	ret    

80103e88 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103e88:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103e8c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103e90:	55                   	push   %ebp
  pushl %ebx
80103e91:	53                   	push   %ebx
  pushl %esi
80103e92:	56                   	push   %esi
  pushl %edi
80103e93:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103e94:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103e96:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103e98:	5f                   	pop    %edi
  popl %esi
80103e99:	5e                   	pop    %esi
  popl %ebx
80103e9a:	5b                   	pop    %ebx
  popl %ebp
80103e9b:	5d                   	pop    %ebp
  ret
80103e9c:	c3                   	ret    

80103e9d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103e9d:	55                   	push   %ebp
80103e9e:	89 e5                	mov    %esp,%ebp
80103ea0:	53                   	push   %ebx
80103ea1:	83 ec 04             	sub    $0x4,%esp
80103ea4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ea7:	e8 ab f3 ff ff       	call   80103257 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103eac:	8b 00                	mov    (%eax),%eax
80103eae:	39 d8                	cmp    %ebx,%eax
80103eb0:	76 19                	jbe    80103ecb <fetchint+0x2e>
80103eb2:	8d 53 04             	lea    0x4(%ebx),%edx
80103eb5:	39 d0                	cmp    %edx,%eax
80103eb7:	72 19                	jb     80103ed2 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103eb9:	8b 13                	mov    (%ebx),%edx
80103ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ebe:	89 10                	mov    %edx,(%eax)
  return 0;
80103ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ec5:	83 c4 04             	add    $0x4,%esp
80103ec8:	5b                   	pop    %ebx
80103ec9:	5d                   	pop    %ebp
80103eca:	c3                   	ret    
    return -1;
80103ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ed0:	eb f3                	jmp    80103ec5 <fetchint+0x28>
80103ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ed7:	eb ec                	jmp    80103ec5 <fetchint+0x28>

80103ed9 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103ed9:	55                   	push   %ebp
80103eda:	89 e5                	mov    %esp,%ebp
80103edc:	53                   	push   %ebx
80103edd:	83 ec 04             	sub    $0x4,%esp
80103ee0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103ee3:	e8 6f f3 ff ff       	call   80103257 <myproc>

  if(addr >= curproc->sz)
80103ee8:	39 18                	cmp    %ebx,(%eax)
80103eea:	76 26                	jbe    80103f12 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103eec:	8b 55 0c             	mov    0xc(%ebp),%edx
80103eef:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103ef1:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103ef3:	89 d8                	mov    %ebx,%eax
80103ef5:	39 d0                	cmp    %edx,%eax
80103ef7:	73 0e                	jae    80103f07 <fetchstr+0x2e>
    if(*s == 0)
80103ef9:	80 38 00             	cmpb   $0x0,(%eax)
80103efc:	74 05                	je     80103f03 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103efe:	83 c0 01             	add    $0x1,%eax
80103f01:	eb f2                	jmp    80103ef5 <fetchstr+0x1c>
      return s - *pp;
80103f03:	29 d8                	sub    %ebx,%eax
80103f05:	eb 05                	jmp    80103f0c <fetchstr+0x33>
  }
  return -1;
80103f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f0c:	83 c4 04             	add    $0x4,%esp
80103f0f:	5b                   	pop    %ebx
80103f10:	5d                   	pop    %ebp
80103f11:	c3                   	ret    
    return -1;
80103f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f17:	eb f3                	jmp    80103f0c <fetchstr+0x33>

80103f19 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f19:	55                   	push   %ebp
80103f1a:	89 e5                	mov    %esp,%ebp
80103f1c:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f1f:	e8 33 f3 ff ff       	call   80103257 <myproc>
80103f24:	8b 50 18             	mov    0x18(%eax),%edx
80103f27:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2a:	c1 e0 02             	shl    $0x2,%eax
80103f2d:	03 42 44             	add    0x44(%edx),%eax
80103f30:	83 ec 08             	sub    $0x8,%esp
80103f33:	ff 75 0c             	pushl  0xc(%ebp)
80103f36:	83 c0 04             	add    $0x4,%eax
80103f39:	50                   	push   %eax
80103f3a:	e8 5e ff ff ff       	call   80103e9d <fetchint>
}
80103f3f:	c9                   	leave  
80103f40:	c3                   	ret    

80103f41 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f41:	55                   	push   %ebp
80103f42:	89 e5                	mov    %esp,%ebp
80103f44:	56                   	push   %esi
80103f45:	53                   	push   %ebx
80103f46:	83 ec 10             	sub    $0x10,%esp
80103f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103f4c:	e8 06 f3 ff ff       	call   80103257 <myproc>
80103f51:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103f53:	83 ec 08             	sub    $0x8,%esp
80103f56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f59:	50                   	push   %eax
80103f5a:	ff 75 08             	pushl  0x8(%ebp)
80103f5d:	e8 b7 ff ff ff       	call   80103f19 <argint>
80103f62:	83 c4 10             	add    $0x10,%esp
80103f65:	85 c0                	test   %eax,%eax
80103f67:	78 24                	js     80103f8d <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103f69:	85 db                	test   %ebx,%ebx
80103f6b:	78 27                	js     80103f94 <argptr+0x53>
80103f6d:	8b 16                	mov    (%esi),%edx
80103f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f72:	39 c2                	cmp    %eax,%edx
80103f74:	76 25                	jbe    80103f9b <argptr+0x5a>
80103f76:	01 c3                	add    %eax,%ebx
80103f78:	39 da                	cmp    %ebx,%edx
80103f7a:	72 26                	jb     80103fa2 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f7f:	89 02                	mov    %eax,(%edx)
  return 0;
80103f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f86:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f89:	5b                   	pop    %ebx
80103f8a:	5e                   	pop    %esi
80103f8b:	5d                   	pop    %ebp
80103f8c:	c3                   	ret    
    return -1;
80103f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f92:	eb f2                	jmp    80103f86 <argptr+0x45>
    return -1;
80103f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f99:	eb eb                	jmp    80103f86 <argptr+0x45>
80103f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa0:	eb e4                	jmp    80103f86 <argptr+0x45>
80103fa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa7:	eb dd                	jmp    80103f86 <argptr+0x45>

80103fa9 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103fa9:	55                   	push   %ebp
80103faa:	89 e5                	mov    %esp,%ebp
80103fac:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fb2:	50                   	push   %eax
80103fb3:	ff 75 08             	pushl  0x8(%ebp)
80103fb6:	e8 5e ff ff ff       	call   80103f19 <argint>
80103fbb:	83 c4 10             	add    $0x10,%esp
80103fbe:	85 c0                	test   %eax,%eax
80103fc0:	78 13                	js     80103fd5 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103fc2:	83 ec 08             	sub    $0x8,%esp
80103fc5:	ff 75 0c             	pushl  0xc(%ebp)
80103fc8:	ff 75 f4             	pushl  -0xc(%ebp)
80103fcb:	e8 09 ff ff ff       	call   80103ed9 <fetchstr>
80103fd0:	83 c4 10             	add    $0x10,%esp
}
80103fd3:	c9                   	leave  
80103fd4:	c3                   	ret    
    return -1;
80103fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fda:	eb f7                	jmp    80103fd3 <argstr+0x2a>

80103fdc <syscall>:
[SYS_getprocessesinfo] sys_getprocessesinfo,
};

void
syscall(void)
{
80103fdc:	55                   	push   %ebp
80103fdd:	89 e5                	mov    %esp,%ebp
80103fdf:	53                   	push   %ebx
80103fe0:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103fe3:	e8 6f f2 ff ff       	call   80103257 <myproc>
80103fe8:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103fea:	8b 40 18             	mov    0x18(%eax),%eax
80103fed:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103ff0:	8d 50 ff             	lea    -0x1(%eax),%edx
80103ff3:	83 fa 1a             	cmp    $0x1a,%edx
80103ff6:	77 18                	ja     80104010 <syscall+0x34>
80103ff8:	8b 14 85 a0 6e 10 80 	mov    -0x7fef9160(,%eax,4),%edx
80103fff:	85 d2                	test   %edx,%edx
80104001:	74 0d                	je     80104010 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104003:	ff d2                	call   *%edx
80104005:	8b 53 18             	mov    0x18(%ebx),%edx
80104008:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010400b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010400e:	c9                   	leave  
8010400f:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104010:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104013:	50                   	push   %eax
80104014:	52                   	push   %edx
80104015:	ff 73 10             	pushl  0x10(%ebx)
80104018:	68 69 6e 10 80       	push   $0x80106e69
8010401d:	e8 e9 c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104022:	8b 43 18             	mov    0x18(%ebx),%eax
80104025:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010402c:	83 c4 10             	add    $0x10,%esp
}
8010402f:	eb da                	jmp    8010400b <syscall+0x2f>

80104031 <argfd>:
uint writeCount_global;
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104031:	55                   	push   %ebp
80104032:	89 e5                	mov    %esp,%ebp
80104034:	56                   	push   %esi
80104035:	53                   	push   %ebx
80104036:	83 ec 18             	sub    $0x18,%esp
80104039:	89 d6                	mov    %edx,%esi
8010403b:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010403d:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104040:	52                   	push   %edx
80104041:	50                   	push   %eax
80104042:	e8 d2 fe ff ff       	call   80103f19 <argint>
80104047:	83 c4 10             	add    $0x10,%esp
8010404a:	85 c0                	test   %eax,%eax
8010404c:	78 2e                	js     8010407c <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010404e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104052:	77 2f                	ja     80104083 <argfd+0x52>
80104054:	e8 fe f1 ff ff       	call   80103257 <myproc>
80104059:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104060:	85 c0                	test   %eax,%eax
80104062:	74 26                	je     8010408a <argfd+0x59>
    return -1;
  if(pfd)
80104064:	85 f6                	test   %esi,%esi
80104066:	74 02                	je     8010406a <argfd+0x39>
    *pfd = fd;
80104068:	89 16                	mov    %edx,(%esi)
  if(pf)
8010406a:	85 db                	test   %ebx,%ebx
8010406c:	74 23                	je     80104091 <argfd+0x60>
    *pf = f;
8010406e:	89 03                	mov    %eax,(%ebx)
  return 0;
80104070:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104075:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104078:	5b                   	pop    %ebx
80104079:	5e                   	pop    %esi
8010407a:	5d                   	pop    %ebp
8010407b:	c3                   	ret    
    return -1;
8010407c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104081:	eb f2                	jmp    80104075 <argfd+0x44>
    return -1;
80104083:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104088:	eb eb                	jmp    80104075 <argfd+0x44>
8010408a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010408f:	eb e4                	jmp    80104075 <argfd+0x44>
  return 0;
80104091:	b8 00 00 00 00       	mov    $0x0,%eax
80104096:	eb dd                	jmp    80104075 <argfd+0x44>

80104098 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104098:	55                   	push   %ebp
80104099:	89 e5                	mov    %esp,%ebp
8010409b:	53                   	push   %ebx
8010409c:	83 ec 04             	sub    $0x4,%esp
8010409f:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801040a1:	e8 b1 f1 ff ff       	call   80103257 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801040a6:	ba 00 00 00 00       	mov    $0x0,%edx
801040ab:	83 fa 0f             	cmp    $0xf,%edx
801040ae:	7f 18                	jg     801040c8 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801040b0:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801040b5:	74 05                	je     801040bc <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801040b7:	83 c2 01             	add    $0x1,%edx
801040ba:	eb ef                	jmp    801040ab <fdalloc+0x13>
      curproc->ofile[fd] = f;
801040bc:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801040c0:	89 d0                	mov    %edx,%eax
801040c2:	83 c4 04             	add    $0x4,%esp
801040c5:	5b                   	pop    %ebx
801040c6:	5d                   	pop    %ebp
801040c7:	c3                   	ret    
  return -1;
801040c8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801040cd:	eb f1                	jmp    801040c0 <fdalloc+0x28>

801040cf <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801040cf:	55                   	push   %ebp
801040d0:	89 e5                	mov    %esp,%ebp
801040d2:	56                   	push   %esi
801040d3:	53                   	push   %ebx
801040d4:	83 ec 10             	sub    $0x10,%esp
801040d7:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801040d9:	b8 20 00 00 00       	mov    $0x20,%eax
801040de:	89 c6                	mov    %eax,%esi
801040e0:	39 43 58             	cmp    %eax,0x58(%ebx)
801040e3:	76 2e                	jbe    80104113 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801040e5:	6a 10                	push   $0x10
801040e7:	50                   	push   %eax
801040e8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801040eb:	50                   	push   %eax
801040ec:	53                   	push   %ebx
801040ed:	e8 6f d6 ff ff       	call   80101761 <readi>
801040f2:	83 c4 10             	add    $0x10,%esp
801040f5:	83 f8 10             	cmp    $0x10,%eax
801040f8:	75 0c                	jne    80104106 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801040fa:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801040ff:	75 1e                	jne    8010411f <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104101:	8d 46 10             	lea    0x10(%esi),%eax
80104104:	eb d8                	jmp    801040de <isdirempty+0xf>
      panic("isdirempty: readi");
80104106:	83 ec 0c             	sub    $0xc,%esp
80104109:	68 10 6f 10 80       	push   $0x80106f10
8010410e:	e8 35 c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104113:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104118:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010411b:	5b                   	pop    %ebx
8010411c:	5e                   	pop    %esi
8010411d:	5d                   	pop    %ebp
8010411e:	c3                   	ret    
      return 0;
8010411f:	b8 00 00 00 00       	mov    $0x0,%eax
80104124:	eb f2                	jmp    80104118 <isdirempty+0x49>

80104126 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104126:	55                   	push   %ebp
80104127:	89 e5                	mov    %esp,%ebp
80104129:	57                   	push   %edi
8010412a:	56                   	push   %esi
8010412b:	53                   	push   %ebx
8010412c:	83 ec 34             	sub    $0x34,%esp
8010412f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104132:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104135:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104138:	8d 55 da             	lea    -0x26(%ebp),%edx
8010413b:	52                   	push   %edx
8010413c:	50                   	push   %eax
8010413d:	e8 a5 da ff ff       	call   80101be7 <nameiparent>
80104142:	89 c6                	mov    %eax,%esi
80104144:	83 c4 10             	add    $0x10,%esp
80104147:	85 c0                	test   %eax,%eax
80104149:	0f 84 38 01 00 00    	je     80104287 <create+0x161>
    return 0;
  ilock(dp);
8010414f:	83 ec 0c             	sub    $0xc,%esp
80104152:	50                   	push   %eax
80104153:	e8 17 d4 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104158:	83 c4 0c             	add    $0xc,%esp
8010415b:	6a 00                	push   $0x0
8010415d:	8d 45 da             	lea    -0x26(%ebp),%eax
80104160:	50                   	push   %eax
80104161:	56                   	push   %esi
80104162:	e8 37 d8 ff ff       	call   8010199e <dirlookup>
80104167:	89 c3                	mov    %eax,%ebx
80104169:	83 c4 10             	add    $0x10,%esp
8010416c:	85 c0                	test   %eax,%eax
8010416e:	74 3f                	je     801041af <create+0x89>
    iunlockput(dp);
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	56                   	push   %esi
80104174:	e8 9d d5 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
80104179:	89 1c 24             	mov    %ebx,(%esp)
8010417c:	e8 ee d3 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104181:	83 c4 10             	add    $0x10,%esp
80104184:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104189:	75 11                	jne    8010419c <create+0x76>
8010418b:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104190:	75 0a                	jne    8010419c <create+0x76>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104192:	89 d8                	mov    %ebx,%eax
80104194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104197:	5b                   	pop    %ebx
80104198:	5e                   	pop    %esi
80104199:	5f                   	pop    %edi
8010419a:	5d                   	pop    %ebp
8010419b:	c3                   	ret    
    iunlockput(ip);
8010419c:	83 ec 0c             	sub    $0xc,%esp
8010419f:	53                   	push   %ebx
801041a0:	e8 71 d5 ff ff       	call   80101716 <iunlockput>
    return 0;
801041a5:	83 c4 10             	add    $0x10,%esp
801041a8:	bb 00 00 00 00       	mov    $0x0,%ebx
801041ad:	eb e3                	jmp    80104192 <create+0x6c>
  if((ip = ialloc(dp->dev, type)) == 0)
801041af:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
801041b3:	83 ec 08             	sub    $0x8,%esp
801041b6:	50                   	push   %eax
801041b7:	ff 36                	pushl  (%esi)
801041b9:	e8 ae d1 ff ff       	call   8010136c <ialloc>
801041be:	89 c3                	mov    %eax,%ebx
801041c0:	83 c4 10             	add    $0x10,%esp
801041c3:	85 c0                	test   %eax,%eax
801041c5:	74 55                	je     8010421c <create+0xf6>
  ilock(ip);
801041c7:	83 ec 0c             	sub    $0xc,%esp
801041ca:	50                   	push   %eax
801041cb:	e8 9f d3 ff ff       	call   8010156f <ilock>
  ip->major = major;
801041d0:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
801041d4:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801041d8:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801041dc:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801041e2:	89 1c 24             	mov    %ebx,(%esp)
801041e5:	e8 24 d2 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801041ea:	83 c4 10             	add    $0x10,%esp
801041ed:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801041f2:	74 35                	je     80104229 <create+0x103>
  if(dirlink(dp, name, ip->inum) < 0)
801041f4:	83 ec 04             	sub    $0x4,%esp
801041f7:	ff 73 04             	pushl  0x4(%ebx)
801041fa:	8d 45 da             	lea    -0x26(%ebp),%eax
801041fd:	50                   	push   %eax
801041fe:	56                   	push   %esi
801041ff:	e8 1a d9 ff ff       	call   80101b1e <dirlink>
80104204:	83 c4 10             	add    $0x10,%esp
80104207:	85 c0                	test   %eax,%eax
80104209:	78 6f                	js     8010427a <create+0x154>
  iunlockput(dp);
8010420b:	83 ec 0c             	sub    $0xc,%esp
8010420e:	56                   	push   %esi
8010420f:	e8 02 d5 ff ff       	call   80101716 <iunlockput>
  return ip;
80104214:	83 c4 10             	add    $0x10,%esp
80104217:	e9 76 ff ff ff       	jmp    80104192 <create+0x6c>
    panic("create: ialloc");
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	68 22 6f 10 80       	push   $0x80106f22
80104224:	e8 1f c1 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104229:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010422d:	83 c0 01             	add    $0x1,%eax
80104230:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104234:	83 ec 0c             	sub    $0xc,%esp
80104237:	56                   	push   %esi
80104238:	e8 d1 d1 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010423d:	83 c4 0c             	add    $0xc,%esp
80104240:	ff 73 04             	pushl  0x4(%ebx)
80104243:	68 32 6f 10 80       	push   $0x80106f32
80104248:	53                   	push   %ebx
80104249:	e8 d0 d8 ff ff       	call   80101b1e <dirlink>
8010424e:	83 c4 10             	add    $0x10,%esp
80104251:	85 c0                	test   %eax,%eax
80104253:	78 18                	js     8010426d <create+0x147>
80104255:	83 ec 04             	sub    $0x4,%esp
80104258:	ff 76 04             	pushl  0x4(%esi)
8010425b:	68 31 6f 10 80       	push   $0x80106f31
80104260:	53                   	push   %ebx
80104261:	e8 b8 d8 ff ff       	call   80101b1e <dirlink>
80104266:	83 c4 10             	add    $0x10,%esp
80104269:	85 c0                	test   %eax,%eax
8010426b:	79 87                	jns    801041f4 <create+0xce>
      panic("create dots");
8010426d:	83 ec 0c             	sub    $0xc,%esp
80104270:	68 34 6f 10 80       	push   $0x80106f34
80104275:	e8 ce c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010427a:	83 ec 0c             	sub    $0xc,%esp
8010427d:	68 40 6f 10 80       	push   $0x80106f40
80104282:	e8 c1 c0 ff ff       	call   80100348 <panic>
    return 0;
80104287:	89 c3                	mov    %eax,%ebx
80104289:	e9 04 ff ff ff       	jmp    80104192 <create+0x6c>

8010428e <sys_dup>:
{
8010428e:	55                   	push   %ebp
8010428f:	89 e5                	mov    %esp,%ebp
80104291:	53                   	push   %ebx
80104292:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104295:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104298:	ba 00 00 00 00       	mov    $0x0,%edx
8010429d:	b8 00 00 00 00       	mov    $0x0,%eax
801042a2:	e8 8a fd ff ff       	call   80104031 <argfd>
801042a7:	85 c0                	test   %eax,%eax
801042a9:	78 23                	js     801042ce <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ae:	e8 e5 fd ff ff       	call   80104098 <fdalloc>
801042b3:	89 c3                	mov    %eax,%ebx
801042b5:	85 c0                	test   %eax,%eax
801042b7:	78 1c                	js     801042d5 <sys_dup+0x47>
  filedup(f);
801042b9:	83 ec 0c             	sub    $0xc,%esp
801042bc:	ff 75 f4             	pushl  -0xc(%ebp)
801042bf:	e8 ca c9 ff ff       	call   80100c8e <filedup>
  return fd;
801042c4:	83 c4 10             	add    $0x10,%esp
}
801042c7:	89 d8                	mov    %ebx,%eax
801042c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042cc:	c9                   	leave  
801042cd:	c3                   	ret    
    return -1;
801042ce:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042d3:	eb f2                	jmp    801042c7 <sys_dup+0x39>
    return -1;
801042d5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042da:	eb eb                	jmp    801042c7 <sys_dup+0x39>

801042dc <sys_read>:
{
801042dc:	55                   	push   %ebp
801042dd:	89 e5                	mov    %esp,%ebp
801042df:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801042e2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042e5:	ba 00 00 00 00       	mov    $0x0,%edx
801042ea:	b8 00 00 00 00       	mov    $0x0,%eax
801042ef:	e8 3d fd ff ff       	call   80104031 <argfd>
801042f4:	85 c0                	test   %eax,%eax
801042f6:	78 43                	js     8010433b <sys_read+0x5f>
801042f8:	83 ec 08             	sub    $0x8,%esp
801042fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801042fe:	50                   	push   %eax
801042ff:	6a 02                	push   $0x2
80104301:	e8 13 fc ff ff       	call   80103f19 <argint>
80104306:	83 c4 10             	add    $0x10,%esp
80104309:	85 c0                	test   %eax,%eax
8010430b:	78 35                	js     80104342 <sys_read+0x66>
8010430d:	83 ec 04             	sub    $0x4,%esp
80104310:	ff 75 f0             	pushl  -0x10(%ebp)
80104313:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104316:	50                   	push   %eax
80104317:	6a 01                	push   $0x1
80104319:	e8 23 fc ff ff       	call   80103f41 <argptr>
8010431e:	83 c4 10             	add    $0x10,%esp
80104321:	85 c0                	test   %eax,%eax
80104323:	78 24                	js     80104349 <sys_read+0x6d>
  return fileread(f, p, n);
80104325:	83 ec 04             	sub    $0x4,%esp
80104328:	ff 75 f0             	pushl  -0x10(%ebp)
8010432b:	ff 75 ec             	pushl  -0x14(%ebp)
8010432e:	ff 75 f4             	pushl  -0xc(%ebp)
80104331:	e8 a1 ca ff ff       	call   80100dd7 <fileread>
80104336:	83 c4 10             	add    $0x10,%esp
}
80104339:	c9                   	leave  
8010433a:	c3                   	ret    
    return -1;
8010433b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104340:	eb f7                	jmp    80104339 <sys_read+0x5d>
80104342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104347:	eb f0                	jmp    80104339 <sys_read+0x5d>
80104349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010434e:	eb e9                	jmp    80104339 <sys_read+0x5d>

80104350 <sys_write>:
{
80104350:	55                   	push   %ebp
80104351:	89 e5                	mov    %esp,%ebp
80104353:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104356:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104359:	ba 00 00 00 00       	mov    $0x0,%edx
8010435e:	b8 00 00 00 00       	mov    $0x0,%eax
80104363:	e8 c9 fc ff ff       	call   80104031 <argfd>
80104368:	85 c0                	test   %eax,%eax
8010436a:	78 4a                	js     801043b6 <sys_write+0x66>
8010436c:	83 ec 08             	sub    $0x8,%esp
8010436f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104372:	50                   	push   %eax
80104373:	6a 02                	push   $0x2
80104375:	e8 9f fb ff ff       	call   80103f19 <argint>
8010437a:	83 c4 10             	add    $0x10,%esp
8010437d:	85 c0                	test   %eax,%eax
8010437f:	78 3c                	js     801043bd <sys_write+0x6d>
80104381:	83 ec 04             	sub    $0x4,%esp
80104384:	ff 75 f0             	pushl  -0x10(%ebp)
80104387:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010438a:	50                   	push   %eax
8010438b:	6a 01                	push   $0x1
8010438d:	e8 af fb ff ff       	call   80103f41 <argptr>
80104392:	83 c4 10             	add    $0x10,%esp
80104395:	85 c0                	test   %eax,%eax
80104397:	78 2b                	js     801043c4 <sys_write+0x74>
      writeCount_global++;
80104399:	83 05 54 4e 11 80 01 	addl   $0x1,0x80114e54
  return filewrite(f, p, n);
801043a0:	83 ec 04             	sub    $0x4,%esp
801043a3:	ff 75 f0             	pushl  -0x10(%ebp)
801043a6:	ff 75 ec             	pushl  -0x14(%ebp)
801043a9:	ff 75 f4             	pushl  -0xc(%ebp)
801043ac:	e8 ab ca ff ff       	call   80100e5c <filewrite>
801043b1:	83 c4 10             	add    $0x10,%esp
}
801043b4:	c9                   	leave  
801043b5:	c3                   	ret    
    return -1;
801043b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043bb:	eb f7                	jmp    801043b4 <sys_write+0x64>
801043bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c2:	eb f0                	jmp    801043b4 <sys_write+0x64>
801043c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c9:	eb e9                	jmp    801043b4 <sys_write+0x64>

801043cb <sys_close>:
{
801043cb:	55                   	push   %ebp
801043cc:	89 e5                	mov    %esp,%ebp
801043ce:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801043d1:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801043d4:	8d 55 f4             	lea    -0xc(%ebp),%edx
801043d7:	b8 00 00 00 00       	mov    $0x0,%eax
801043dc:	e8 50 fc ff ff       	call   80104031 <argfd>
801043e1:	85 c0                	test   %eax,%eax
801043e3:	78 25                	js     8010440a <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801043e5:	e8 6d ee ff ff       	call   80103257 <myproc>
801043ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ed:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801043f4:	00 
  fileclose(f);
801043f5:	83 ec 0c             	sub    $0xc,%esp
801043f8:	ff 75 f0             	pushl  -0x10(%ebp)
801043fb:	e8 d3 c8 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104400:	83 c4 10             	add    $0x10,%esp
80104403:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104408:	c9                   	leave  
80104409:	c3                   	ret    
    return -1;
8010440a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010440f:	eb f7                	jmp    80104408 <sys_close+0x3d>

80104411 <sys_fstat>:
{
80104411:	55                   	push   %ebp
80104412:	89 e5                	mov    %esp,%ebp
80104414:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104417:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010441a:	ba 00 00 00 00       	mov    $0x0,%edx
8010441f:	b8 00 00 00 00       	mov    $0x0,%eax
80104424:	e8 08 fc ff ff       	call   80104031 <argfd>
80104429:	85 c0                	test   %eax,%eax
8010442b:	78 2a                	js     80104457 <sys_fstat+0x46>
8010442d:	83 ec 04             	sub    $0x4,%esp
80104430:	6a 14                	push   $0x14
80104432:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104435:	50                   	push   %eax
80104436:	6a 01                	push   $0x1
80104438:	e8 04 fb ff ff       	call   80103f41 <argptr>
8010443d:	83 c4 10             	add    $0x10,%esp
80104440:	85 c0                	test   %eax,%eax
80104442:	78 1a                	js     8010445e <sys_fstat+0x4d>
  return filestat(f, st);
80104444:	83 ec 08             	sub    $0x8,%esp
80104447:	ff 75 f0             	pushl  -0x10(%ebp)
8010444a:	ff 75 f4             	pushl  -0xc(%ebp)
8010444d:	e8 3e c9 ff ff       	call   80100d90 <filestat>
80104452:	83 c4 10             	add    $0x10,%esp
}
80104455:	c9                   	leave  
80104456:	c3                   	ret    
    return -1;
80104457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010445c:	eb f7                	jmp    80104455 <sys_fstat+0x44>
8010445e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104463:	eb f0                	jmp    80104455 <sys_fstat+0x44>

80104465 <sys_link>:
{
80104465:	55                   	push   %ebp
80104466:	89 e5                	mov    %esp,%ebp
80104468:	56                   	push   %esi
80104469:	53                   	push   %ebx
8010446a:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010446d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104470:	50                   	push   %eax
80104471:	6a 00                	push   $0x0
80104473:	e8 31 fb ff ff       	call   80103fa9 <argstr>
80104478:	83 c4 10             	add    $0x10,%esp
8010447b:	85 c0                	test   %eax,%eax
8010447d:	0f 88 32 01 00 00    	js     801045b5 <sys_link+0x150>
80104483:	83 ec 08             	sub    $0x8,%esp
80104486:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104489:	50                   	push   %eax
8010448a:	6a 01                	push   $0x1
8010448c:	e8 18 fb ff ff       	call   80103fa9 <argstr>
80104491:	83 c4 10             	add    $0x10,%esp
80104494:	85 c0                	test   %eax,%eax
80104496:	0f 88 20 01 00 00    	js     801045bc <sys_link+0x157>
  begin_op();
8010449c:	e8 31 e3 ff ff       	call   801027d2 <begin_op>
  if((ip = namei(old)) == 0){
801044a1:	83 ec 0c             	sub    $0xc,%esp
801044a4:	ff 75 e0             	pushl  -0x20(%ebp)
801044a7:	e8 23 d7 ff ff       	call   80101bcf <namei>
801044ac:	89 c3                	mov    %eax,%ebx
801044ae:	83 c4 10             	add    $0x10,%esp
801044b1:	85 c0                	test   %eax,%eax
801044b3:	0f 84 99 00 00 00    	je     80104552 <sys_link+0xed>
  ilock(ip);
801044b9:	83 ec 0c             	sub    $0xc,%esp
801044bc:	50                   	push   %eax
801044bd:	e8 ad d0 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
801044c2:	83 c4 10             	add    $0x10,%esp
801044c5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801044ca:	0f 84 8e 00 00 00    	je     8010455e <sys_link+0xf9>
  ip->nlink++;
801044d0:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801044d4:	83 c0 01             	add    $0x1,%eax
801044d7:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044db:	83 ec 0c             	sub    $0xc,%esp
801044de:	53                   	push   %ebx
801044df:	e8 2a cf ff ff       	call   8010140e <iupdate>
  iunlock(ip);
801044e4:	89 1c 24             	mov    %ebx,(%esp)
801044e7:	e8 45 d1 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801044ec:	83 c4 08             	add    $0x8,%esp
801044ef:	8d 45 ea             	lea    -0x16(%ebp),%eax
801044f2:	50                   	push   %eax
801044f3:	ff 75 e4             	pushl  -0x1c(%ebp)
801044f6:	e8 ec d6 ff ff       	call   80101be7 <nameiparent>
801044fb:	89 c6                	mov    %eax,%esi
801044fd:	83 c4 10             	add    $0x10,%esp
80104500:	85 c0                	test   %eax,%eax
80104502:	74 7e                	je     80104582 <sys_link+0x11d>
  ilock(dp);
80104504:	83 ec 0c             	sub    $0xc,%esp
80104507:	50                   	push   %eax
80104508:	e8 62 d0 ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010450d:	83 c4 10             	add    $0x10,%esp
80104510:	8b 03                	mov    (%ebx),%eax
80104512:	39 06                	cmp    %eax,(%esi)
80104514:	75 60                	jne    80104576 <sys_link+0x111>
80104516:	83 ec 04             	sub    $0x4,%esp
80104519:	ff 73 04             	pushl  0x4(%ebx)
8010451c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010451f:	50                   	push   %eax
80104520:	56                   	push   %esi
80104521:	e8 f8 d5 ff ff       	call   80101b1e <dirlink>
80104526:	83 c4 10             	add    $0x10,%esp
80104529:	85 c0                	test   %eax,%eax
8010452b:	78 49                	js     80104576 <sys_link+0x111>
  iunlockput(dp);
8010452d:	83 ec 0c             	sub    $0xc,%esp
80104530:	56                   	push   %esi
80104531:	e8 e0 d1 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104536:	89 1c 24             	mov    %ebx,(%esp)
80104539:	e8 38 d1 ff ff       	call   80101676 <iput>
  end_op();
8010453e:	e8 09 e3 ff ff       	call   8010284c <end_op>
  return 0;
80104543:	83 c4 10             	add    $0x10,%esp
80104546:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010454b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010454e:	5b                   	pop    %ebx
8010454f:	5e                   	pop    %esi
80104550:	5d                   	pop    %ebp
80104551:	c3                   	ret    
    end_op();
80104552:	e8 f5 e2 ff ff       	call   8010284c <end_op>
    return -1;
80104557:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010455c:	eb ed                	jmp    8010454b <sys_link+0xe6>
    iunlockput(ip);
8010455e:	83 ec 0c             	sub    $0xc,%esp
80104561:	53                   	push   %ebx
80104562:	e8 af d1 ff ff       	call   80101716 <iunlockput>
    end_op();
80104567:	e8 e0 e2 ff ff       	call   8010284c <end_op>
    return -1;
8010456c:	83 c4 10             	add    $0x10,%esp
8010456f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104574:	eb d5                	jmp    8010454b <sys_link+0xe6>
    iunlockput(dp);
80104576:	83 ec 0c             	sub    $0xc,%esp
80104579:	56                   	push   %esi
8010457a:	e8 97 d1 ff ff       	call   80101716 <iunlockput>
    goto bad;
8010457f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104582:	83 ec 0c             	sub    $0xc,%esp
80104585:	53                   	push   %ebx
80104586:	e8 e4 cf ff ff       	call   8010156f <ilock>
  ip->nlink--;
8010458b:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010458f:	83 e8 01             	sub    $0x1,%eax
80104592:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104596:	89 1c 24             	mov    %ebx,(%esp)
80104599:	e8 70 ce ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
8010459e:	89 1c 24             	mov    %ebx,(%esp)
801045a1:	e8 70 d1 ff ff       	call   80101716 <iunlockput>
  end_op();
801045a6:	e8 a1 e2 ff ff       	call   8010284c <end_op>
  return -1;
801045ab:	83 c4 10             	add    $0x10,%esp
801045ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b3:	eb 96                	jmp    8010454b <sys_link+0xe6>
    return -1;
801045b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ba:	eb 8f                	jmp    8010454b <sys_link+0xe6>
801045bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c1:	eb 88                	jmp    8010454b <sys_link+0xe6>

801045c3 <sys_unlink>:
{
801045c3:	55                   	push   %ebp
801045c4:	89 e5                	mov    %esp,%ebp
801045c6:	57                   	push   %edi
801045c7:	56                   	push   %esi
801045c8:	53                   	push   %ebx
801045c9:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801045cc:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801045cf:	50                   	push   %eax
801045d0:	6a 00                	push   $0x0
801045d2:	e8 d2 f9 ff ff       	call   80103fa9 <argstr>
801045d7:	83 c4 10             	add    $0x10,%esp
801045da:	85 c0                	test   %eax,%eax
801045dc:	0f 88 83 01 00 00    	js     80104765 <sys_unlink+0x1a2>
  begin_op();
801045e2:	e8 eb e1 ff ff       	call   801027d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801045e7:	83 ec 08             	sub    $0x8,%esp
801045ea:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045ed:	50                   	push   %eax
801045ee:	ff 75 c4             	pushl  -0x3c(%ebp)
801045f1:	e8 f1 d5 ff ff       	call   80101be7 <nameiparent>
801045f6:	89 c6                	mov    %eax,%esi
801045f8:	83 c4 10             	add    $0x10,%esp
801045fb:	85 c0                	test   %eax,%eax
801045fd:	0f 84 ed 00 00 00    	je     801046f0 <sys_unlink+0x12d>
  ilock(dp);
80104603:	83 ec 0c             	sub    $0xc,%esp
80104606:	50                   	push   %eax
80104607:	e8 63 cf ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010460c:	83 c4 08             	add    $0x8,%esp
8010460f:	68 32 6f 10 80       	push   $0x80106f32
80104614:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104617:	50                   	push   %eax
80104618:	e8 6c d3 ff ff       	call   80101989 <namecmp>
8010461d:	83 c4 10             	add    $0x10,%esp
80104620:	85 c0                	test   %eax,%eax
80104622:	0f 84 fc 00 00 00    	je     80104724 <sys_unlink+0x161>
80104628:	83 ec 08             	sub    $0x8,%esp
8010462b:	68 31 6f 10 80       	push   $0x80106f31
80104630:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104633:	50                   	push   %eax
80104634:	e8 50 d3 ff ff       	call   80101989 <namecmp>
80104639:	83 c4 10             	add    $0x10,%esp
8010463c:	85 c0                	test   %eax,%eax
8010463e:	0f 84 e0 00 00 00    	je     80104724 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104644:	83 ec 04             	sub    $0x4,%esp
80104647:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010464a:	50                   	push   %eax
8010464b:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010464e:	50                   	push   %eax
8010464f:	56                   	push   %esi
80104650:	e8 49 d3 ff ff       	call   8010199e <dirlookup>
80104655:	89 c3                	mov    %eax,%ebx
80104657:	83 c4 10             	add    $0x10,%esp
8010465a:	85 c0                	test   %eax,%eax
8010465c:	0f 84 c2 00 00 00    	je     80104724 <sys_unlink+0x161>
  ilock(ip);
80104662:	83 ec 0c             	sub    $0xc,%esp
80104665:	50                   	push   %eax
80104666:	e8 04 cf ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
8010466b:	83 c4 10             	add    $0x10,%esp
8010466e:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104673:	0f 8e 83 00 00 00    	jle    801046fc <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104679:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010467e:	0f 84 85 00 00 00    	je     80104709 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104684:	83 ec 04             	sub    $0x4,%esp
80104687:	6a 10                	push   $0x10
80104689:	6a 00                	push   $0x0
8010468b:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010468e:	57                   	push   %edi
8010468f:	e8 3a f6 ff ff       	call   80103cce <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104694:	6a 10                	push   $0x10
80104696:	ff 75 c0             	pushl  -0x40(%ebp)
80104699:	57                   	push   %edi
8010469a:	56                   	push   %esi
8010469b:	e8 be d1 ff ff       	call   8010185e <writei>
801046a0:	83 c4 20             	add    $0x20,%esp
801046a3:	83 f8 10             	cmp    $0x10,%eax
801046a6:	0f 85 90 00 00 00    	jne    8010473c <sys_unlink+0x179>
  if(ip->type == T_DIR){
801046ac:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046b1:	0f 84 92 00 00 00    	je     80104749 <sys_unlink+0x186>
  iunlockput(dp);
801046b7:	83 ec 0c             	sub    $0xc,%esp
801046ba:	56                   	push   %esi
801046bb:	e8 56 d0 ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
801046c0:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046c4:	83 e8 01             	sub    $0x1,%eax
801046c7:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046cb:	89 1c 24             	mov    %ebx,(%esp)
801046ce:	e8 3b cd ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801046d3:	89 1c 24             	mov    %ebx,(%esp)
801046d6:	e8 3b d0 ff ff       	call   80101716 <iunlockput>
  end_op();
801046db:	e8 6c e1 ff ff       	call   8010284c <end_op>
  return 0;
801046e0:	83 c4 10             	add    $0x10,%esp
801046e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046eb:	5b                   	pop    %ebx
801046ec:	5e                   	pop    %esi
801046ed:	5f                   	pop    %edi
801046ee:	5d                   	pop    %ebp
801046ef:	c3                   	ret    
    end_op();
801046f0:	e8 57 e1 ff ff       	call   8010284c <end_op>
    return -1;
801046f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046fa:	eb ec                	jmp    801046e8 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801046fc:	83 ec 0c             	sub    $0xc,%esp
801046ff:	68 50 6f 10 80       	push   $0x80106f50
80104704:	e8 3f bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104709:	89 d8                	mov    %ebx,%eax
8010470b:	e8 bf f9 ff ff       	call   801040cf <isdirempty>
80104710:	85 c0                	test   %eax,%eax
80104712:	0f 85 6c ff ff ff    	jne    80104684 <sys_unlink+0xc1>
    iunlockput(ip);
80104718:	83 ec 0c             	sub    $0xc,%esp
8010471b:	53                   	push   %ebx
8010471c:	e8 f5 cf ff ff       	call   80101716 <iunlockput>
    goto bad;
80104721:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104724:	83 ec 0c             	sub    $0xc,%esp
80104727:	56                   	push   %esi
80104728:	e8 e9 cf ff ff       	call   80101716 <iunlockput>
  end_op();
8010472d:	e8 1a e1 ff ff       	call   8010284c <end_op>
  return -1;
80104732:	83 c4 10             	add    $0x10,%esp
80104735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010473a:	eb ac                	jmp    801046e8 <sys_unlink+0x125>
    panic("unlink: writei");
8010473c:	83 ec 0c             	sub    $0xc,%esp
8010473f:	68 62 6f 10 80       	push   $0x80106f62
80104744:	e8 ff bb ff ff       	call   80100348 <panic>
    dp->nlink--;
80104749:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010474d:	83 e8 01             	sub    $0x1,%eax
80104750:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104754:	83 ec 0c             	sub    $0xc,%esp
80104757:	56                   	push   %esi
80104758:	e8 b1 cc ff ff       	call   8010140e <iupdate>
8010475d:	83 c4 10             	add    $0x10,%esp
80104760:	e9 52 ff ff ff       	jmp    801046b7 <sys_unlink+0xf4>
    return -1;
80104765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476a:	e9 79 ff ff ff       	jmp    801046e8 <sys_unlink+0x125>

8010476f <sys_open>:

int
sys_open(void)
{
8010476f:	55                   	push   %ebp
80104770:	89 e5                	mov    %esp,%ebp
80104772:	57                   	push   %edi
80104773:	56                   	push   %esi
80104774:	53                   	push   %ebx
80104775:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104778:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010477b:	50                   	push   %eax
8010477c:	6a 00                	push   $0x0
8010477e:	e8 26 f8 ff ff       	call   80103fa9 <argstr>
80104783:	83 c4 10             	add    $0x10,%esp
80104786:	85 c0                	test   %eax,%eax
80104788:	0f 88 30 01 00 00    	js     801048be <sys_open+0x14f>
8010478e:	83 ec 08             	sub    $0x8,%esp
80104791:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104794:	50                   	push   %eax
80104795:	6a 01                	push   $0x1
80104797:	e8 7d f7 ff ff       	call   80103f19 <argint>
8010479c:	83 c4 10             	add    $0x10,%esp
8010479f:	85 c0                	test   %eax,%eax
801047a1:	0f 88 21 01 00 00    	js     801048c8 <sys_open+0x159>
    return -1;

  begin_op();
801047a7:	e8 26 e0 ff ff       	call   801027d2 <begin_op>

  if(omode & O_CREATE){
801047ac:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801047b0:	0f 84 84 00 00 00    	je     8010483a <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801047b6:	83 ec 0c             	sub    $0xc,%esp
801047b9:	6a 00                	push   $0x0
801047bb:	b9 00 00 00 00       	mov    $0x0,%ecx
801047c0:	ba 02 00 00 00       	mov    $0x2,%edx
801047c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047c8:	e8 59 f9 ff ff       	call   80104126 <create>
801047cd:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801047cf:	83 c4 10             	add    $0x10,%esp
801047d2:	85 c0                	test   %eax,%eax
801047d4:	74 58                	je     8010482e <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801047d6:	e8 52 c4 ff ff       	call   80100c2d <filealloc>
801047db:	89 c3                	mov    %eax,%ebx
801047dd:	85 c0                	test   %eax,%eax
801047df:	0f 84 ae 00 00 00    	je     80104893 <sys_open+0x124>
801047e5:	e8 ae f8 ff ff       	call   80104098 <fdalloc>
801047ea:	89 c7                	mov    %eax,%edi
801047ec:	85 c0                	test   %eax,%eax
801047ee:	0f 88 9f 00 00 00    	js     80104893 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801047f4:	83 ec 0c             	sub    $0xc,%esp
801047f7:	56                   	push   %esi
801047f8:	e8 34 ce ff ff       	call   80101631 <iunlock>
  end_op();
801047fd:	e8 4a e0 ff ff       	call   8010284c <end_op>

  f->type = FD_INODE;
80104802:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104808:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010480b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104812:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104815:	83 c4 10             	add    $0x10,%esp
80104818:	a8 01                	test   $0x1,%al
8010481a:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010481e:	a8 03                	test   $0x3,%al
80104820:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104824:	89 f8                	mov    %edi,%eax
80104826:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104829:	5b                   	pop    %ebx
8010482a:	5e                   	pop    %esi
8010482b:	5f                   	pop    %edi
8010482c:	5d                   	pop    %ebp
8010482d:	c3                   	ret    
      end_op();
8010482e:	e8 19 e0 ff ff       	call   8010284c <end_op>
      return -1;
80104833:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104838:	eb ea                	jmp    80104824 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
8010483a:	83 ec 0c             	sub    $0xc,%esp
8010483d:	ff 75 e4             	pushl  -0x1c(%ebp)
80104840:	e8 8a d3 ff ff       	call   80101bcf <namei>
80104845:	89 c6                	mov    %eax,%esi
80104847:	83 c4 10             	add    $0x10,%esp
8010484a:	85 c0                	test   %eax,%eax
8010484c:	74 39                	je     80104887 <sys_open+0x118>
    ilock(ip);
8010484e:	83 ec 0c             	sub    $0xc,%esp
80104851:	50                   	push   %eax
80104852:	e8 18 cd ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104857:	83 c4 10             	add    $0x10,%esp
8010485a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010485f:	0f 85 71 ff ff ff    	jne    801047d6 <sys_open+0x67>
80104865:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104869:	0f 84 67 ff ff ff    	je     801047d6 <sys_open+0x67>
      iunlockput(ip);
8010486f:	83 ec 0c             	sub    $0xc,%esp
80104872:	56                   	push   %esi
80104873:	e8 9e ce ff ff       	call   80101716 <iunlockput>
      end_op();
80104878:	e8 cf df ff ff       	call   8010284c <end_op>
      return -1;
8010487d:	83 c4 10             	add    $0x10,%esp
80104880:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104885:	eb 9d                	jmp    80104824 <sys_open+0xb5>
      end_op();
80104887:	e8 c0 df ff ff       	call   8010284c <end_op>
      return -1;
8010488c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104891:	eb 91                	jmp    80104824 <sys_open+0xb5>
    if(f)
80104893:	85 db                	test   %ebx,%ebx
80104895:	74 0c                	je     801048a3 <sys_open+0x134>
      fileclose(f);
80104897:	83 ec 0c             	sub    $0xc,%esp
8010489a:	53                   	push   %ebx
8010489b:	e8 33 c4 ff ff       	call   80100cd3 <fileclose>
801048a0:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801048a3:	83 ec 0c             	sub    $0xc,%esp
801048a6:	56                   	push   %esi
801048a7:	e8 6a ce ff ff       	call   80101716 <iunlockput>
    end_op();
801048ac:	e8 9b df ff ff       	call   8010284c <end_op>
    return -1;
801048b1:	83 c4 10             	add    $0x10,%esp
801048b4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048b9:	e9 66 ff ff ff       	jmp    80104824 <sys_open+0xb5>
    return -1;
801048be:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048c3:	e9 5c ff ff ff       	jmp    80104824 <sys_open+0xb5>
801048c8:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048cd:	e9 52 ff ff ff       	jmp    80104824 <sys_open+0xb5>

801048d2 <sys_mkdir>:

int
sys_mkdir(void)
{
801048d2:	55                   	push   %ebp
801048d3:	89 e5                	mov    %esp,%ebp
801048d5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801048d8:	e8 f5 de ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801048dd:	83 ec 08             	sub    $0x8,%esp
801048e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048e3:	50                   	push   %eax
801048e4:	6a 00                	push   $0x0
801048e6:	e8 be f6 ff ff       	call   80103fa9 <argstr>
801048eb:	83 c4 10             	add    $0x10,%esp
801048ee:	85 c0                	test   %eax,%eax
801048f0:	78 36                	js     80104928 <sys_mkdir+0x56>
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	6a 00                	push   $0x0
801048f7:	b9 00 00 00 00       	mov    $0x0,%ecx
801048fc:	ba 01 00 00 00       	mov    $0x1,%edx
80104901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104904:	e8 1d f8 ff ff       	call   80104126 <create>
80104909:	83 c4 10             	add    $0x10,%esp
8010490c:	85 c0                	test   %eax,%eax
8010490e:	74 18                	je     80104928 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104910:	83 ec 0c             	sub    $0xc,%esp
80104913:	50                   	push   %eax
80104914:	e8 fd cd ff ff       	call   80101716 <iunlockput>
  end_op();
80104919:	e8 2e df ff ff       	call   8010284c <end_op>
  return 0;
8010491e:	83 c4 10             	add    $0x10,%esp
80104921:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104926:	c9                   	leave  
80104927:	c3                   	ret    
    end_op();
80104928:	e8 1f df ff ff       	call   8010284c <end_op>
    return -1;
8010492d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104932:	eb f2                	jmp    80104926 <sys_mkdir+0x54>

80104934 <sys_mknod>:

int
sys_mknod(void)
{
80104934:	55                   	push   %ebp
80104935:	89 e5                	mov    %esp,%ebp
80104937:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010493a:	e8 93 de ff ff       	call   801027d2 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010493f:	83 ec 08             	sub    $0x8,%esp
80104942:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104945:	50                   	push   %eax
80104946:	6a 00                	push   $0x0
80104948:	e8 5c f6 ff ff       	call   80103fa9 <argstr>
8010494d:	83 c4 10             	add    $0x10,%esp
80104950:	85 c0                	test   %eax,%eax
80104952:	78 62                	js     801049b6 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104954:	83 ec 08             	sub    $0x8,%esp
80104957:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010495a:	50                   	push   %eax
8010495b:	6a 01                	push   $0x1
8010495d:	e8 b7 f5 ff ff       	call   80103f19 <argint>
  if((argstr(0, &path)) < 0 ||
80104962:	83 c4 10             	add    $0x10,%esp
80104965:	85 c0                	test   %eax,%eax
80104967:	78 4d                	js     801049b6 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104969:	83 ec 08             	sub    $0x8,%esp
8010496c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010496f:	50                   	push   %eax
80104970:	6a 02                	push   $0x2
80104972:	e8 a2 f5 ff ff       	call   80103f19 <argint>
     argint(1, &major) < 0 ||
80104977:	83 c4 10             	add    $0x10,%esp
8010497a:	85 c0                	test   %eax,%eax
8010497c:	78 38                	js     801049b6 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010497e:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104982:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104986:	83 ec 0c             	sub    $0xc,%esp
80104989:	50                   	push   %eax
8010498a:	ba 03 00 00 00       	mov    $0x3,%edx
8010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104992:	e8 8f f7 ff ff       	call   80104126 <create>
80104997:	83 c4 10             	add    $0x10,%esp
8010499a:	85 c0                	test   %eax,%eax
8010499c:	74 18                	je     801049b6 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010499e:	83 ec 0c             	sub    $0xc,%esp
801049a1:	50                   	push   %eax
801049a2:	e8 6f cd ff ff       	call   80101716 <iunlockput>
  end_op();
801049a7:	e8 a0 de ff ff       	call   8010284c <end_op>
  return 0;
801049ac:	83 c4 10             	add    $0x10,%esp
801049af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049b4:	c9                   	leave  
801049b5:	c3                   	ret    
    end_op();
801049b6:	e8 91 de ff ff       	call   8010284c <end_op>
    return -1;
801049bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c0:	eb f2                	jmp    801049b4 <sys_mknod+0x80>

801049c2 <sys_chdir>:

int
sys_chdir(void)
{
801049c2:	55                   	push   %ebp
801049c3:	89 e5                	mov    %esp,%ebp
801049c5:	56                   	push   %esi
801049c6:	53                   	push   %ebx
801049c7:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801049ca:	e8 88 e8 ff ff       	call   80103257 <myproc>
801049cf:	89 c6                	mov    %eax,%esi
  
  begin_op();
801049d1:	e8 fc dd ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801049d6:	83 ec 08             	sub    $0x8,%esp
801049d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049dc:	50                   	push   %eax
801049dd:	6a 00                	push   $0x0
801049df:	e8 c5 f5 ff ff       	call   80103fa9 <argstr>
801049e4:	83 c4 10             	add    $0x10,%esp
801049e7:	85 c0                	test   %eax,%eax
801049e9:	78 52                	js     80104a3d <sys_chdir+0x7b>
801049eb:	83 ec 0c             	sub    $0xc,%esp
801049ee:	ff 75 f4             	pushl  -0xc(%ebp)
801049f1:	e8 d9 d1 ff ff       	call   80101bcf <namei>
801049f6:	89 c3                	mov    %eax,%ebx
801049f8:	83 c4 10             	add    $0x10,%esp
801049fb:	85 c0                	test   %eax,%eax
801049fd:	74 3e                	je     80104a3d <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
801049ff:	83 ec 0c             	sub    $0xc,%esp
80104a02:	50                   	push   %eax
80104a03:	e8 67 cb ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104a08:	83 c4 10             	add    $0x10,%esp
80104a0b:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a10:	75 37                	jne    80104a49 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a12:	83 ec 0c             	sub    $0xc,%esp
80104a15:	53                   	push   %ebx
80104a16:	e8 16 cc ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104a1b:	83 c4 04             	add    $0x4,%esp
80104a1e:	ff 76 68             	pushl  0x68(%esi)
80104a21:	e8 50 cc ff ff       	call   80101676 <iput>
  end_op();
80104a26:	e8 21 de ff ff       	call   8010284c <end_op>
  curproc->cwd = ip;
80104a2b:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a2e:	83 c4 10             	add    $0x10,%esp
80104a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a36:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a39:	5b                   	pop    %ebx
80104a3a:	5e                   	pop    %esi
80104a3b:	5d                   	pop    %ebp
80104a3c:	c3                   	ret    
    end_op();
80104a3d:	e8 0a de ff ff       	call   8010284c <end_op>
    return -1;
80104a42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a47:	eb ed                	jmp    80104a36 <sys_chdir+0x74>
    iunlockput(ip);
80104a49:	83 ec 0c             	sub    $0xc,%esp
80104a4c:	53                   	push   %ebx
80104a4d:	e8 c4 cc ff ff       	call   80101716 <iunlockput>
    end_op();
80104a52:	e8 f5 dd ff ff       	call   8010284c <end_op>
    return -1;
80104a57:	83 c4 10             	add    $0x10,%esp
80104a5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a5f:	eb d5                	jmp    80104a36 <sys_chdir+0x74>

80104a61 <sys_exec>:

int
sys_exec(void)
{
80104a61:	55                   	push   %ebp
80104a62:	89 e5                	mov    %esp,%ebp
80104a64:	53                   	push   %ebx
80104a65:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a6e:	50                   	push   %eax
80104a6f:	6a 00                	push   $0x0
80104a71:	e8 33 f5 ff ff       	call   80103fa9 <argstr>
80104a76:	83 c4 10             	add    $0x10,%esp
80104a79:	85 c0                	test   %eax,%eax
80104a7b:	0f 88 a8 00 00 00    	js     80104b29 <sys_exec+0xc8>
80104a81:	83 ec 08             	sub    $0x8,%esp
80104a84:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104a8a:	50                   	push   %eax
80104a8b:	6a 01                	push   $0x1
80104a8d:	e8 87 f4 ff ff       	call   80103f19 <argint>
80104a92:	83 c4 10             	add    $0x10,%esp
80104a95:	85 c0                	test   %eax,%eax
80104a97:	0f 88 93 00 00 00    	js     80104b30 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104a9d:	83 ec 04             	sub    $0x4,%esp
80104aa0:	68 80 00 00 00       	push   $0x80
80104aa5:	6a 00                	push   $0x0
80104aa7:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104aad:	50                   	push   %eax
80104aae:	e8 1b f2 ff ff       	call   80103cce <memset>
80104ab3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104ab6:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104abb:	83 fb 1f             	cmp    $0x1f,%ebx
80104abe:	77 77                	ja     80104b37 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104ac0:	83 ec 08             	sub    $0x8,%esp
80104ac3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104ac9:	50                   	push   %eax
80104aca:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104ad0:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104ad3:	50                   	push   %eax
80104ad4:	e8 c4 f3 ff ff       	call   80103e9d <fetchint>
80104ad9:	83 c4 10             	add    $0x10,%esp
80104adc:	85 c0                	test   %eax,%eax
80104ade:	78 5e                	js     80104b3e <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104ae0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104ae6:	85 c0                	test   %eax,%eax
80104ae8:	74 1d                	je     80104b07 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104aea:	83 ec 08             	sub    $0x8,%esp
80104aed:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104af4:	52                   	push   %edx
80104af5:	50                   	push   %eax
80104af6:	e8 de f3 ff ff       	call   80103ed9 <fetchstr>
80104afb:	83 c4 10             	add    $0x10,%esp
80104afe:	85 c0                	test   %eax,%eax
80104b00:	78 46                	js     80104b48 <sys_exec+0xe7>
  for(i=0;; i++){
80104b02:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104b05:	eb b4                	jmp    80104abb <sys_exec+0x5a>
      argv[i] = 0;
80104b07:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b0e:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104b12:	83 ec 08             	sub    $0x8,%esp
80104b15:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b1b:	50                   	push   %eax
80104b1c:	ff 75 f4             	pushl  -0xc(%ebp)
80104b1f:	e8 ae bd ff ff       	call   801008d2 <exec>
80104b24:	83 c4 10             	add    $0x10,%esp
80104b27:	eb 1a                	jmp    80104b43 <sys_exec+0xe2>
    return -1;
80104b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b2e:	eb 13                	jmp    80104b43 <sys_exec+0xe2>
80104b30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b35:	eb 0c                	jmp    80104b43 <sys_exec+0xe2>
      return -1;
80104b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3c:	eb 05                	jmp    80104b43 <sys_exec+0xe2>
      return -1;
80104b3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b46:	c9                   	leave  
80104b47:	c3                   	ret    
      return -1;
80104b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b4d:	eb f4                	jmp    80104b43 <sys_exec+0xe2>

80104b4f <sys_pipe>:

int
sys_pipe(void)
{
80104b4f:	55                   	push   %ebp
80104b50:	89 e5                	mov    %esp,%ebp
80104b52:	53                   	push   %ebx
80104b53:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b56:	6a 08                	push   $0x8
80104b58:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b5b:	50                   	push   %eax
80104b5c:	6a 00                	push   $0x0
80104b5e:	e8 de f3 ff ff       	call   80103f41 <argptr>
80104b63:	83 c4 10             	add    $0x10,%esp
80104b66:	85 c0                	test   %eax,%eax
80104b68:	78 77                	js     80104be1 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104b6a:	83 ec 08             	sub    $0x8,%esp
80104b6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b70:	50                   	push   %eax
80104b71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b74:	50                   	push   %eax
80104b75:	e8 16 e2 ff ff       	call   80102d90 <pipealloc>
80104b7a:	83 c4 10             	add    $0x10,%esp
80104b7d:	85 c0                	test   %eax,%eax
80104b7f:	78 67                	js     80104be8 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b84:	e8 0f f5 ff ff       	call   80104098 <fdalloc>
80104b89:	89 c3                	mov    %eax,%ebx
80104b8b:	85 c0                	test   %eax,%eax
80104b8d:	78 21                	js     80104bb0 <sys_pipe+0x61>
80104b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b92:	e8 01 f5 ff ff       	call   80104098 <fdalloc>
80104b97:	85 c0                	test   %eax,%eax
80104b99:	78 15                	js     80104bb0 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104b9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b9e:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104ba0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ba3:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104ba6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bae:	c9                   	leave  
80104baf:	c3                   	ret    
    if(fd0 >= 0)
80104bb0:	85 db                	test   %ebx,%ebx
80104bb2:	78 0d                	js     80104bc1 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104bb4:	e8 9e e6 ff ff       	call   80103257 <myproc>
80104bb9:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104bc0:	00 
    fileclose(rf);
80104bc1:	83 ec 0c             	sub    $0xc,%esp
80104bc4:	ff 75 f0             	pushl  -0x10(%ebp)
80104bc7:	e8 07 c1 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104bcc:	83 c4 04             	add    $0x4,%esp
80104bcf:	ff 75 ec             	pushl  -0x14(%ebp)
80104bd2:	e8 fc c0 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104bd7:	83 c4 10             	add    $0x10,%esp
80104bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bdf:	eb ca                	jmp    80104bab <sys_pipe+0x5c>
    return -1;
80104be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104be6:	eb c3                	jmp    80104bab <sys_pipe+0x5c>
    return -1;
80104be8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bed:	eb bc                	jmp    80104bab <sys_pipe+0x5c>

80104bef <sys_writecount>:

int
sys_writecount(void){
80104bef:	55                   	push   %ebp
80104bf0:	89 e5                	mov    %esp,%ebp
  uint myWriteCount;
  myWriteCount = writeCount_global;
  return myWriteCount;
}
80104bf2:	a1 54 4e 11 80       	mov    0x80114e54,%eax
80104bf7:	5d                   	pop    %ebp
80104bf8:	c3                   	ret    

80104bf9 <sys_setwritecount>:

int
sys_setwritecount(void){
80104bf9:	55                   	push   %ebp
80104bfa:	89 e5                	mov    %esp,%ebp
80104bfc:	83 ec 20             	sub    $0x20,%esp
   int pid;
  

  if(argint(0, &pid) < 0)
80104bff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c02:	50                   	push   %eax
80104c03:	6a 00                	push   $0x0
80104c05:	e8 0f f3 ff ff       	call   80103f19 <argint>
80104c0a:	83 c4 10             	add    $0x10,%esp
80104c0d:	85 c0                	test   %eax,%eax
80104c0f:	78 0f                	js     80104c20 <sys_setwritecount+0x27>
    return -1;
  writeCount_global = (uint) pid;
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	a3 54 4e 11 80       	mov    %eax,0x80114e54
  return 0;
80104c19:	b8 00 00 00 00       	mov    $0x0,%eax
80104c1e:	c9                   	leave  
80104c1f:	c3                   	ret    
    return -1;
80104c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c25:	eb f7                	jmp    80104c1e <sys_setwritecount+0x25>

80104c27 <sys_fork>:



int
sys_fork(void)
{
80104c27:	55                   	push   %ebp
80104c28:	89 e5                	mov    %esp,%ebp
80104c2a:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c2d:	e8 9d e7 ff ff       	call   801033cf <fork>
}
80104c32:	c9                   	leave  
80104c33:	c3                   	ret    

80104c34 <sys_exit>:

int
sys_exit(void)
{
80104c34:	55                   	push   %ebp
80104c35:	89 e5                	mov    %esp,%ebp
80104c37:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c3a:	e8 e5 e9 ff ff       	call   80103624 <exit>
  return 0;  // not reached
}
80104c3f:	b8 00 00 00 00       	mov    $0x0,%eax
80104c44:	c9                   	leave  
80104c45:	c3                   	ret    

80104c46 <sys_wait>:

int
sys_wait(void)
{
80104c46:	55                   	push   %ebp
80104c47:	89 e5                	mov    %esp,%ebp
80104c49:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c4c:	e8 5f eb ff ff       	call   801037b0 <wait>
}
80104c51:	c9                   	leave  
80104c52:	c3                   	ret    

80104c53 <sys_kill>:

int
sys_kill(void)
{
80104c53:	55                   	push   %ebp
80104c54:	89 e5                	mov    %esp,%ebp
80104c56:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c59:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c5c:	50                   	push   %eax
80104c5d:	6a 00                	push   $0x0
80104c5f:	e8 b5 f2 ff ff       	call   80103f19 <argint>
80104c64:	83 c4 10             	add    $0x10,%esp
80104c67:	85 c0                	test   %eax,%eax
80104c69:	78 10                	js     80104c7b <sys_kill+0x28>
    return -1;
  return kill(pid);
80104c6b:	83 ec 0c             	sub    $0xc,%esp
80104c6e:	ff 75 f4             	pushl  -0xc(%ebp)
80104c71:	e8 3a ec ff ff       	call   801038b0 <kill>
80104c76:	83 c4 10             	add    $0x10,%esp
}
80104c79:	c9                   	leave  
80104c7a:	c3                   	ret    
    return -1;
80104c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c80:	eb f7                	jmp    80104c79 <sys_kill+0x26>

80104c82 <sys_getpid>:

int
sys_getpid(void)
{
80104c82:	55                   	push   %ebp
80104c83:	89 e5                	mov    %esp,%ebp
80104c85:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c88:	e8 ca e5 ff ff       	call   80103257 <myproc>
80104c8d:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c90:	c9                   	leave  
80104c91:	c3                   	ret    

80104c92 <sys_sbrk>:

int
sys_sbrk(void)
{
80104c92:	55                   	push   %ebp
80104c93:	89 e5                	mov    %esp,%ebp
80104c95:	53                   	push   %ebx
80104c96:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c99:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c9c:	50                   	push   %eax
80104c9d:	6a 00                	push   $0x0
80104c9f:	e8 75 f2 ff ff       	call   80103f19 <argint>
80104ca4:	83 c4 10             	add    $0x10,%esp
80104ca7:	85 c0                	test   %eax,%eax
80104ca9:	78 27                	js     80104cd2 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104cab:	e8 a7 e5 ff ff       	call   80103257 <myproc>
80104cb0:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104cb2:	83 ec 0c             	sub    $0xc,%esp
80104cb5:	ff 75 f4             	pushl  -0xc(%ebp)
80104cb8:	e8 a5 e6 ff ff       	call   80103362 <growproc>
80104cbd:	83 c4 10             	add    $0x10,%esp
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	78 07                	js     80104ccb <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104cc4:	89 d8                	mov    %ebx,%eax
80104cc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cc9:	c9                   	leave  
80104cca:	c3                   	ret    
    return -1;
80104ccb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cd0:	eb f2                	jmp    80104cc4 <sys_sbrk+0x32>
    return -1;
80104cd2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cd7:	eb eb                	jmp    80104cc4 <sys_sbrk+0x32>

80104cd9 <sys_sleep>:

int
sys_sleep(void)
{
80104cd9:	55                   	push   %ebp
80104cda:	89 e5                	mov    %esp,%ebp
80104cdc:	53                   	push   %ebx
80104cdd:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104ce0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ce3:	50                   	push   %eax
80104ce4:	6a 00                	push   $0x0
80104ce6:	e8 2e f2 ff ff       	call   80103f19 <argint>
80104ceb:	83 c4 10             	add    $0x10,%esp
80104cee:	85 c0                	test   %eax,%eax
80104cf0:	78 75                	js     80104d67 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104cf2:	83 ec 0c             	sub    $0xc,%esp
80104cf5:	68 60 4e 11 80       	push   $0x80114e60
80104cfa:	e8 23 ef ff ff       	call   80103c22 <acquire>
  ticks0 = ticks;
80104cff:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  while(ticks - ticks0 < n){
80104d05:	83 c4 10             	add    $0x10,%esp
80104d08:	a1 a0 56 11 80       	mov    0x801156a0,%eax
80104d0d:	29 d8                	sub    %ebx,%eax
80104d0f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d12:	73 39                	jae    80104d4d <sys_sleep+0x74>
    if(myproc()->killed){
80104d14:	e8 3e e5 ff ff       	call   80103257 <myproc>
80104d19:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104d1d:	75 17                	jne    80104d36 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104d1f:	83 ec 08             	sub    $0x8,%esp
80104d22:	68 60 4e 11 80       	push   $0x80114e60
80104d27:	68 a0 56 11 80       	push   $0x801156a0
80104d2c:	e8 ee e9 ff ff       	call   8010371f <sleep>
80104d31:	83 c4 10             	add    $0x10,%esp
80104d34:	eb d2                	jmp    80104d08 <sys_sleep+0x2f>
      release(&tickslock);
80104d36:	83 ec 0c             	sub    $0xc,%esp
80104d39:	68 60 4e 11 80       	push   $0x80114e60
80104d3e:	e8 44 ef ff ff       	call   80103c87 <release>
      return -1;
80104d43:	83 c4 10             	add    $0x10,%esp
80104d46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4b:	eb 15                	jmp    80104d62 <sys_sleep+0x89>
  }
  release(&tickslock);
80104d4d:	83 ec 0c             	sub    $0xc,%esp
80104d50:	68 60 4e 11 80       	push   $0x80114e60
80104d55:	e8 2d ef ff ff       	call   80103c87 <release>
  return 0;
80104d5a:	83 c4 10             	add    $0x10,%esp
80104d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d65:	c9                   	leave  
80104d66:	c3                   	ret    
    return -1;
80104d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6c:	eb f4                	jmp    80104d62 <sys_sleep+0x89>

80104d6e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d6e:	55                   	push   %ebp
80104d6f:	89 e5                	mov    %esp,%ebp
80104d71:	53                   	push   %ebx
80104d72:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104d75:	68 60 4e 11 80       	push   $0x80114e60
80104d7a:	e8 a3 ee ff ff       	call   80103c22 <acquire>
  xticks = ticks;
80104d7f:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  release(&tickslock);
80104d85:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80104d8c:	e8 f6 ee ff ff       	call   80103c87 <release>
  return xticks;
}
80104d91:	89 d8                	mov    %ebx,%eax
80104d93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d96:	c9                   	leave  
80104d97:	c3                   	ret    

80104d98 <sys_yield>:

int
sys_yield(void)
{
80104d98:	55                   	push   %ebp
80104d99:	89 e5                	mov    %esp,%ebp
80104d9b:	83 ec 08             	sub    $0x8,%esp
  yield();
80104d9e:	e8 4a e9 ff ff       	call   801036ed <yield>
  return 0;
}
80104da3:	b8 00 00 00 00       	mov    $0x0,%eax
80104da8:	c9                   	leave  
80104da9:	c3                   	ret    

80104daa <sys_shutdown>:

int sys_shutdown(void)
{
80104daa:	55                   	push   %ebp
80104dab:	89 e5                	mov    %esp,%ebp
80104dad:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104db0:	e8 51 d4 ff ff       	call   80102206 <shutdown>
  return 0;
}
80104db5:	b8 00 00 00 00       	mov    $0x0,%eax
80104dba:	c9                   	leave  
80104dbb:	c3                   	ret    

80104dbc <sys_settickets>:

int sys_settickets(void){
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	53                   	push   %ebx
80104dc0:	83 ec 14             	sub    $0x14,%esp
  int tickets;
  struct proc *curproc = myproc();
80104dc3:	e8 8f e4 ff ff       	call   80103257 <myproc>
80104dc8:	89 c3                	mov    %eax,%ebx

  if(argint(0, &tickets) < 0)
80104dca:	83 ec 08             	sub    $0x8,%esp
80104dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd0:	50                   	push   %eax
80104dd1:	6a 00                	push   $0x0
80104dd3:	e8 41 f1 ff ff       	call   80103f19 <argint>
80104dd8:	83 c4 10             	add    $0x10,%esp
80104ddb:	85 c0                	test   %eax,%eax
80104ddd:	78 13                	js     80104df2 <sys_settickets+0x36>
    return -1;

  curproc->tickets = tickets;
80104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)

  
  
  return 0;
80104de8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ded:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104df0:	c9                   	leave  
80104df1:	c3                   	ret    
    return -1;
80104df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104df7:	eb f4                	jmp    80104ded <sys_settickets+0x31>

80104df9 <sys_getprocessesinfo>:

int sys_getprocessesinfo(){
80104df9:	55                   	push   %ebp
80104dfa:	89 e5                	mov    %esp,%ebp
80104dfc:	53                   	push   %ebx
80104dfd:	83 ec 20             	sub    $0x20,%esp
  struct processes_info *process_info;
  //int x;
  struct proc *p;


  acquire(&ptable.lock);
80104e00:	68 20 2d 11 80       	push   $0x80112d20
80104e05:	e8 18 ee ff ff       	call   80103c22 <acquire>
  if( argptr(0, (void*) &process_info, sizeof(*process_info)) < 0){
80104e0a:	83 c4 0c             	add    $0xc,%esp
80104e0d:	68 04 03 00 00       	push   $0x304
80104e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e15:	50                   	push   %eax
80104e16:	6a 00                	push   $0x0
80104e18:	e8 24 f1 ff ff       	call   80103f41 <argptr>
80104e1d:	83 c4 10             	add    $0x10,%esp
80104e20:	85 c0                	test   %eax,%eax
80104e22:	78 0c                	js     80104e30 <sys_getprocessesinfo+0x37>
    release(&ptable.lock);
    return -1;
  }

  int i = 0;
80104e24:	ba 00 00 00 00       	mov    $0x0,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e29:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80104e2e:	eb 1c                	jmp    80104e4c <sys_getprocessesinfo+0x53>
    release(&ptable.lock);
80104e30:	83 ec 0c             	sub    $0xc,%esp
80104e33:	68 20 2d 11 80       	push   $0x80112d20
80104e38:	e8 4a ee ff ff       	call   80103c87 <release>
    return -1;
80104e3d:	83 c4 10             	add    $0x10,%esp
80104e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e45:	eb 4f                	jmp    80104e96 <sys_getprocessesinfo+0x9d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e47:	05 84 00 00 00       	add    $0x84,%eax
80104e4c:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
80104e51:	73 2e                	jae    80104e81 <sys_getprocessesinfo+0x88>
    if(p->state != UNUSED){
80104e53:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
80104e57:	74 ee                	je     80104e47 <sys_getprocessesinfo+0x4e>
      //cprintf("PID %d has %d tickets! \n", p->pid, p->tickets);
      process_info->pids[i] = p->pid;
80104e59:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104e5c:	8b 58 10             	mov    0x10(%eax),%ebx
80104e5f:	89 5c 91 04          	mov    %ebx,0x4(%ecx,%edx,4)
      process_info->tickets[i] = p->tickets;
80104e63:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
80104e69:	89 9c 91 04 02 00 00 	mov    %ebx,0x204(%ecx,%edx,4)
      process_info->times_scheduled[i] = p->num_times_scheduled;
80104e70:	8b 58 7c             	mov    0x7c(%eax),%ebx
80104e73:	89 9c 91 04 01 00 00 	mov    %ebx,0x104(%ecx,%edx,4)
      process_info->num_processes = ++i;
80104e7a:	83 c2 01             	add    $0x1,%edx
80104e7d:	89 11                	mov    %edx,(%ecx)
80104e7f:	eb c6                	jmp    80104e47 <sys_getprocessesinfo+0x4e>
  }
  
  
  

  release(&ptable.lock);
80104e81:	83 ec 0c             	sub    $0xc,%esp
80104e84:	68 20 2d 11 80       	push   $0x80112d20
80104e89:	e8 f9 ed ff ff       	call   80103c87 <release>
  return 0;
80104e8e:	83 c4 10             	add    $0x10,%esp
80104e91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e99:	c9                   	leave  
80104e9a:	c3                   	ret    

80104e9b <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104e9b:	1e                   	push   %ds
  pushl %es
80104e9c:	06                   	push   %es
  pushl %fs
80104e9d:	0f a0                	push   %fs
  pushl %gs
80104e9f:	0f a8                	push   %gs
  pushal
80104ea1:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104ea2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104ea6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104ea8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104eaa:	54                   	push   %esp
  call trap
80104eab:	e8 e3 00 00 00       	call   80104f93 <trap>
  addl $4, %esp
80104eb0:	83 c4 04             	add    $0x4,%esp

80104eb3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104eb3:	61                   	popa   
  popl %gs
80104eb4:	0f a9                	pop    %gs
  popl %fs
80104eb6:	0f a1                	pop    %fs
  popl %es
80104eb8:	07                   	pop    %es
  popl %ds
80104eb9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104eba:	83 c4 08             	add    $0x8,%esp
  iret
80104ebd:	cf                   	iret   

80104ebe <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104ebe:	55                   	push   %ebp
80104ebf:	89 e5                	mov    %esp,%ebp
80104ec1:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104ec4:	b8 00 00 00 00       	mov    $0x0,%eax
80104ec9:	eb 4a                	jmp    80104f15 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104ecb:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104ed2:	66 89 0c c5 a0 4e 11 	mov    %cx,-0x7feeb160(,%eax,8)
80104ed9:	80 
80104eda:	66 c7 04 c5 a2 4e 11 	movw   $0x8,-0x7feeb15e(,%eax,8)
80104ee1:	80 08 00 
80104ee4:	c6 04 c5 a4 4e 11 80 	movb   $0x0,-0x7feeb15c(,%eax,8)
80104eeb:	00 
80104eec:	0f b6 14 c5 a5 4e 11 	movzbl -0x7feeb15b(,%eax,8),%edx
80104ef3:	80 
80104ef4:	83 e2 f0             	and    $0xfffffff0,%edx
80104ef7:	83 ca 0e             	or     $0xe,%edx
80104efa:	83 e2 8f             	and    $0xffffff8f,%edx
80104efd:	83 ca 80             	or     $0xffffff80,%edx
80104f00:	88 14 c5 a5 4e 11 80 	mov    %dl,-0x7feeb15b(,%eax,8)
80104f07:	c1 e9 10             	shr    $0x10,%ecx
80104f0a:	66 89 0c c5 a6 4e 11 	mov    %cx,-0x7feeb15a(,%eax,8)
80104f11:	80 
  for(i = 0; i < 256; i++)
80104f12:	83 c0 01             	add    $0x1,%eax
80104f15:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f1a:	7e af                	jle    80104ecb <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f1c:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f22:	66 89 15 a0 50 11 80 	mov    %dx,0x801150a0
80104f29:	66 c7 05 a2 50 11 80 	movw   $0x8,0x801150a2
80104f30:	08 00 
80104f32:	c6 05 a4 50 11 80 00 	movb   $0x0,0x801150a4
80104f39:	0f b6 05 a5 50 11 80 	movzbl 0x801150a5,%eax
80104f40:	83 c8 0f             	or     $0xf,%eax
80104f43:	83 e0 ef             	and    $0xffffffef,%eax
80104f46:	83 c8 e0             	or     $0xffffffe0,%eax
80104f49:	a2 a5 50 11 80       	mov    %al,0x801150a5
80104f4e:	c1 ea 10             	shr    $0x10,%edx
80104f51:	66 89 15 a6 50 11 80 	mov    %dx,0x801150a6

  initlock(&tickslock, "time");
80104f58:	83 ec 08             	sub    $0x8,%esp
80104f5b:	68 71 6f 10 80       	push   $0x80106f71
80104f60:	68 60 4e 11 80       	push   $0x80114e60
80104f65:	e8 7c eb ff ff       	call   80103ae6 <initlock>
}
80104f6a:	83 c4 10             	add    $0x10,%esp
80104f6d:	c9                   	leave  
80104f6e:	c3                   	ret    

80104f6f <idtinit>:

void
idtinit(void)
{
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
80104f72:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104f75:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104f7b:	b8 a0 4e 11 80       	mov    $0x80114ea0,%eax
80104f80:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104f84:	c1 e8 10             	shr    $0x10,%eax
80104f87:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104f8b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104f8e:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104f91:	c9                   	leave  
80104f92:	c3                   	ret    

80104f93 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104f93:	55                   	push   %ebp
80104f94:	89 e5                	mov    %esp,%ebp
80104f96:	57                   	push   %edi
80104f97:	56                   	push   %esi
80104f98:	53                   	push   %ebx
80104f99:	83 ec 1c             	sub    $0x1c,%esp
80104f9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104f9f:	8b 43 30             	mov    0x30(%ebx),%eax
80104fa2:	83 f8 40             	cmp    $0x40,%eax
80104fa5:	74 13                	je     80104fba <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104fa7:	83 e8 20             	sub    $0x20,%eax
80104faa:	83 f8 1f             	cmp    $0x1f,%eax
80104fad:	0f 87 3a 01 00 00    	ja     801050ed <trap+0x15a>
80104fb3:	ff 24 85 18 70 10 80 	jmp    *-0x7fef8fe8(,%eax,4)
    if(myproc()->killed)
80104fba:	e8 98 e2 ff ff       	call   80103257 <myproc>
80104fbf:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fc3:	75 1f                	jne    80104fe4 <trap+0x51>
    myproc()->tf = tf;
80104fc5:	e8 8d e2 ff ff       	call   80103257 <myproc>
80104fca:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104fcd:	e8 0a f0 ff ff       	call   80103fdc <syscall>
    if(myproc()->killed)
80104fd2:	e8 80 e2 ff ff       	call   80103257 <myproc>
80104fd7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fdb:	74 7e                	je     8010505b <trap+0xc8>
      exit();
80104fdd:	e8 42 e6 ff ff       	call   80103624 <exit>
80104fe2:	eb 77                	jmp    8010505b <trap+0xc8>
      exit();
80104fe4:	e8 3b e6 ff ff       	call   80103624 <exit>
80104fe9:	eb da                	jmp    80104fc5 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104feb:	e8 4c e2 ff ff       	call   8010323c <cpuid>
80104ff0:	85 c0                	test   %eax,%eax
80104ff2:	74 6f                	je     80105063 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104ff4:	e8 c4 d3 ff ff       	call   801023bd <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ff9:	e8 59 e2 ff ff       	call   80103257 <myproc>
80104ffe:	85 c0                	test   %eax,%eax
80105000:	74 1c                	je     8010501e <trap+0x8b>
80105002:	e8 50 e2 ff ff       	call   80103257 <myproc>
80105007:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010500b:	74 11                	je     8010501e <trap+0x8b>
8010500d:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105011:	83 e0 03             	and    $0x3,%eax
80105014:	66 83 f8 03          	cmp    $0x3,%ax
80105018:	0f 84 62 01 00 00    	je     80105180 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010501e:	e8 34 e2 ff ff       	call   80103257 <myproc>
80105023:	85 c0                	test   %eax,%eax
80105025:	74 0f                	je     80105036 <trap+0xa3>
80105027:	e8 2b e2 ff ff       	call   80103257 <myproc>
8010502c:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105030:	0f 84 54 01 00 00    	je     8010518a <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105036:	e8 1c e2 ff ff       	call   80103257 <myproc>
8010503b:	85 c0                	test   %eax,%eax
8010503d:	74 1c                	je     8010505b <trap+0xc8>
8010503f:	e8 13 e2 ff ff       	call   80103257 <myproc>
80105044:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105048:	74 11                	je     8010505b <trap+0xc8>
8010504a:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010504e:	83 e0 03             	and    $0x3,%eax
80105051:	66 83 f8 03          	cmp    $0x3,%ax
80105055:	0f 84 43 01 00 00    	je     8010519e <trap+0x20b>
    exit();
}
8010505b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010505e:	5b                   	pop    %ebx
8010505f:	5e                   	pop    %esi
80105060:	5f                   	pop    %edi
80105061:	5d                   	pop    %ebp
80105062:	c3                   	ret    
      acquire(&tickslock);
80105063:	83 ec 0c             	sub    $0xc,%esp
80105066:	68 60 4e 11 80       	push   $0x80114e60
8010506b:	e8 b2 eb ff ff       	call   80103c22 <acquire>
      ticks++;
80105070:	83 05 a0 56 11 80 01 	addl   $0x1,0x801156a0
      wakeup(&ticks);
80105077:	c7 04 24 a0 56 11 80 	movl   $0x801156a0,(%esp)
8010507e:	e8 04 e8 ff ff       	call   80103887 <wakeup>
      release(&tickslock);
80105083:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
8010508a:	e8 f8 eb ff ff       	call   80103c87 <release>
8010508f:	83 c4 10             	add    $0x10,%esp
80105092:	e9 5d ff ff ff       	jmp    80104ff4 <trap+0x61>
    ideintr();
80105097:	e8 c5 cc ff ff       	call   80101d61 <ideintr>
    lapiceoi();
8010509c:	e8 1c d3 ff ff       	call   801023bd <lapiceoi>
    break;
801050a1:	e9 53 ff ff ff       	jmp    80104ff9 <trap+0x66>
    kbdintr();
801050a6:	e8 46 d1 ff ff       	call   801021f1 <kbdintr>
    lapiceoi();
801050ab:	e8 0d d3 ff ff       	call   801023bd <lapiceoi>
    break;
801050b0:	e9 44 ff ff ff       	jmp    80104ff9 <trap+0x66>
    uartintr();
801050b5:	e8 05 02 00 00       	call   801052bf <uartintr>
    lapiceoi();
801050ba:	e8 fe d2 ff ff       	call   801023bd <lapiceoi>
    break;
801050bf:	e9 35 ff ff ff       	jmp    80104ff9 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050c4:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801050c7:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050cb:	e8 6c e1 ff ff       	call   8010323c <cpuid>
801050d0:	57                   	push   %edi
801050d1:	0f b7 f6             	movzwl %si,%esi
801050d4:	56                   	push   %esi
801050d5:	50                   	push   %eax
801050d6:	68 7c 6f 10 80       	push   $0x80106f7c
801050db:	e8 2b b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
801050e0:	e8 d8 d2 ff ff       	call   801023bd <lapiceoi>
    break;
801050e5:	83 c4 10             	add    $0x10,%esp
801050e8:	e9 0c ff ff ff       	jmp    80104ff9 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801050ed:	e8 65 e1 ff ff       	call   80103257 <myproc>
801050f2:	85 c0                	test   %eax,%eax
801050f4:	74 5f                	je     80105155 <trap+0x1c2>
801050f6:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801050fa:	74 59                	je     80105155 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801050fc:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801050ff:	8b 43 38             	mov    0x38(%ebx),%eax
80105102:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105105:	e8 32 e1 ff ff       	call   8010323c <cpuid>
8010510a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010510d:	8b 53 34             	mov    0x34(%ebx),%edx
80105110:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105113:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105116:	e8 3c e1 ff ff       	call   80103257 <myproc>
8010511b:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010511e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105121:	e8 31 e1 ff ff       	call   80103257 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105126:	57                   	push   %edi
80105127:	ff 75 e4             	pushl  -0x1c(%ebp)
8010512a:	ff 75 e0             	pushl  -0x20(%ebp)
8010512d:	ff 75 dc             	pushl  -0x24(%ebp)
80105130:	56                   	push   %esi
80105131:	ff 75 d8             	pushl  -0x28(%ebp)
80105134:	ff 70 10             	pushl  0x10(%eax)
80105137:	68 d4 6f 10 80       	push   $0x80106fd4
8010513c:	e8 ca b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105141:	83 c4 20             	add    $0x20,%esp
80105144:	e8 0e e1 ff ff       	call   80103257 <myproc>
80105149:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105150:	e9 a4 fe ff ff       	jmp    80104ff9 <trap+0x66>
80105155:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105158:	8b 73 38             	mov    0x38(%ebx),%esi
8010515b:	e8 dc e0 ff ff       	call   8010323c <cpuid>
80105160:	83 ec 0c             	sub    $0xc,%esp
80105163:	57                   	push   %edi
80105164:	56                   	push   %esi
80105165:	50                   	push   %eax
80105166:	ff 73 30             	pushl  0x30(%ebx)
80105169:	68 a0 6f 10 80       	push   $0x80106fa0
8010516e:	e8 98 b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105173:	83 c4 14             	add    $0x14,%esp
80105176:	68 76 6f 10 80       	push   $0x80106f76
8010517b:	e8 c8 b1 ff ff       	call   80100348 <panic>
    exit();
80105180:	e8 9f e4 ff ff       	call   80103624 <exit>
80105185:	e9 94 fe ff ff       	jmp    8010501e <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010518a:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010518e:	0f 85 a2 fe ff ff    	jne    80105036 <trap+0xa3>
    yield();
80105194:	e8 54 e5 ff ff       	call   801036ed <yield>
80105199:	e9 98 fe ff ff       	jmp    80105036 <trap+0xa3>
    exit();
8010519e:	e8 81 e4 ff ff       	call   80103624 <exit>
801051a3:	e9 b3 fe ff ff       	jmp    8010505b <trap+0xc8>

801051a8 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801051a8:	55                   	push   %ebp
801051a9:	89 e5                	mov    %esp,%ebp
  if(!uart)
801051ab:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051b2:	74 15                	je     801051c9 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051b4:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051b9:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051ba:	a8 01                	test   $0x1,%al
801051bc:	74 12                	je     801051d0 <uartgetc+0x28>
801051be:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051c3:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801051c4:	0f b6 c0             	movzbl %al,%eax
}
801051c7:	5d                   	pop    %ebp
801051c8:	c3                   	ret    
    return -1;
801051c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ce:	eb f7                	jmp    801051c7 <uartgetc+0x1f>
    return -1;
801051d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d5:	eb f0                	jmp    801051c7 <uartgetc+0x1f>

801051d7 <uartputc>:
  if(!uart)
801051d7:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051de:	74 3b                	je     8010521b <uartputc+0x44>
{
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	53                   	push   %ebx
801051e4:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051e7:	bb 00 00 00 00       	mov    $0x0,%ebx
801051ec:	eb 10                	jmp    801051fe <uartputc+0x27>
    microdelay(10);
801051ee:	83 ec 0c             	sub    $0xc,%esp
801051f1:	6a 0a                	push   $0xa
801051f3:	e8 e4 d1 ff ff       	call   801023dc <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051f8:	83 c3 01             	add    $0x1,%ebx
801051fb:	83 c4 10             	add    $0x10,%esp
801051fe:	83 fb 7f             	cmp    $0x7f,%ebx
80105201:	7f 0a                	jg     8010520d <uartputc+0x36>
80105203:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105208:	ec                   	in     (%dx),%al
80105209:	a8 20                	test   $0x20,%al
8010520b:	74 e1                	je     801051ee <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010520d:	8b 45 08             	mov    0x8(%ebp),%eax
80105210:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105215:	ee                   	out    %al,(%dx)
}
80105216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105219:	c9                   	leave  
8010521a:	c3                   	ret    
8010521b:	f3 c3                	repz ret 

8010521d <uartinit>:
{
8010521d:	55                   	push   %ebp
8010521e:	89 e5                	mov    %esp,%ebp
80105220:	56                   	push   %esi
80105221:	53                   	push   %ebx
80105222:	b9 00 00 00 00       	mov    $0x0,%ecx
80105227:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010522c:	89 c8                	mov    %ecx,%eax
8010522e:	ee                   	out    %al,(%dx)
8010522f:	be fb 03 00 00       	mov    $0x3fb,%esi
80105234:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105239:	89 f2                	mov    %esi,%edx
8010523b:	ee                   	out    %al,(%dx)
8010523c:	b8 0c 00 00 00       	mov    $0xc,%eax
80105241:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105246:	ee                   	out    %al,(%dx)
80105247:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010524c:	89 c8                	mov    %ecx,%eax
8010524e:	89 da                	mov    %ebx,%edx
80105250:	ee                   	out    %al,(%dx)
80105251:	b8 03 00 00 00       	mov    $0x3,%eax
80105256:	89 f2                	mov    %esi,%edx
80105258:	ee                   	out    %al,(%dx)
80105259:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010525e:	89 c8                	mov    %ecx,%eax
80105260:	ee                   	out    %al,(%dx)
80105261:	b8 01 00 00 00       	mov    $0x1,%eax
80105266:	89 da                	mov    %ebx,%edx
80105268:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105269:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010526e:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010526f:	3c ff                	cmp    $0xff,%al
80105271:	74 45                	je     801052b8 <uartinit+0x9b>
  uart = 1;
80105273:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
8010527a:	00 00 00 
8010527d:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105282:	ec                   	in     (%dx),%al
80105283:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105288:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105289:	83 ec 08             	sub    $0x8,%esp
8010528c:	6a 00                	push   $0x0
8010528e:	6a 04                	push   $0x4
80105290:	e8 d7 cc ff ff       	call   80101f6c <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105295:	83 c4 10             	add    $0x10,%esp
80105298:	bb 98 70 10 80       	mov    $0x80107098,%ebx
8010529d:	eb 12                	jmp    801052b1 <uartinit+0x94>
    uartputc(*p);
8010529f:	83 ec 0c             	sub    $0xc,%esp
801052a2:	0f be c0             	movsbl %al,%eax
801052a5:	50                   	push   %eax
801052a6:	e8 2c ff ff ff       	call   801051d7 <uartputc>
  for(p="xv6...\n"; *p; p++)
801052ab:	83 c3 01             	add    $0x1,%ebx
801052ae:	83 c4 10             	add    $0x10,%esp
801052b1:	0f b6 03             	movzbl (%ebx),%eax
801052b4:	84 c0                	test   %al,%al
801052b6:	75 e7                	jne    8010529f <uartinit+0x82>
}
801052b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052bb:	5b                   	pop    %ebx
801052bc:	5e                   	pop    %esi
801052bd:	5d                   	pop    %ebp
801052be:	c3                   	ret    

801052bf <uartintr>:

void
uartintr(void)
{
801052bf:	55                   	push   %ebp
801052c0:	89 e5                	mov    %esp,%ebp
801052c2:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801052c5:	68 a8 51 10 80       	push   $0x801051a8
801052ca:	e8 6f b4 ff ff       	call   8010073e <consoleintr>
}
801052cf:	83 c4 10             	add    $0x10,%esp
801052d2:	c9                   	leave  
801052d3:	c3                   	ret    

801052d4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801052d4:	6a 00                	push   $0x0
  pushl $0
801052d6:	6a 00                	push   $0x0
  jmp alltraps
801052d8:	e9 be fb ff ff       	jmp    80104e9b <alltraps>

801052dd <vector1>:
.globl vector1
vector1:
  pushl $0
801052dd:	6a 00                	push   $0x0
  pushl $1
801052df:	6a 01                	push   $0x1
  jmp alltraps
801052e1:	e9 b5 fb ff ff       	jmp    80104e9b <alltraps>

801052e6 <vector2>:
.globl vector2
vector2:
  pushl $0
801052e6:	6a 00                	push   $0x0
  pushl $2
801052e8:	6a 02                	push   $0x2
  jmp alltraps
801052ea:	e9 ac fb ff ff       	jmp    80104e9b <alltraps>

801052ef <vector3>:
.globl vector3
vector3:
  pushl $0
801052ef:	6a 00                	push   $0x0
  pushl $3
801052f1:	6a 03                	push   $0x3
  jmp alltraps
801052f3:	e9 a3 fb ff ff       	jmp    80104e9b <alltraps>

801052f8 <vector4>:
.globl vector4
vector4:
  pushl $0
801052f8:	6a 00                	push   $0x0
  pushl $4
801052fa:	6a 04                	push   $0x4
  jmp alltraps
801052fc:	e9 9a fb ff ff       	jmp    80104e9b <alltraps>

80105301 <vector5>:
.globl vector5
vector5:
  pushl $0
80105301:	6a 00                	push   $0x0
  pushl $5
80105303:	6a 05                	push   $0x5
  jmp alltraps
80105305:	e9 91 fb ff ff       	jmp    80104e9b <alltraps>

8010530a <vector6>:
.globl vector6
vector6:
  pushl $0
8010530a:	6a 00                	push   $0x0
  pushl $6
8010530c:	6a 06                	push   $0x6
  jmp alltraps
8010530e:	e9 88 fb ff ff       	jmp    80104e9b <alltraps>

80105313 <vector7>:
.globl vector7
vector7:
  pushl $0
80105313:	6a 00                	push   $0x0
  pushl $7
80105315:	6a 07                	push   $0x7
  jmp alltraps
80105317:	e9 7f fb ff ff       	jmp    80104e9b <alltraps>

8010531c <vector8>:
.globl vector8
vector8:
  pushl $8
8010531c:	6a 08                	push   $0x8
  jmp alltraps
8010531e:	e9 78 fb ff ff       	jmp    80104e9b <alltraps>

80105323 <vector9>:
.globl vector9
vector9:
  pushl $0
80105323:	6a 00                	push   $0x0
  pushl $9
80105325:	6a 09                	push   $0x9
  jmp alltraps
80105327:	e9 6f fb ff ff       	jmp    80104e9b <alltraps>

8010532c <vector10>:
.globl vector10
vector10:
  pushl $10
8010532c:	6a 0a                	push   $0xa
  jmp alltraps
8010532e:	e9 68 fb ff ff       	jmp    80104e9b <alltraps>

80105333 <vector11>:
.globl vector11
vector11:
  pushl $11
80105333:	6a 0b                	push   $0xb
  jmp alltraps
80105335:	e9 61 fb ff ff       	jmp    80104e9b <alltraps>

8010533a <vector12>:
.globl vector12
vector12:
  pushl $12
8010533a:	6a 0c                	push   $0xc
  jmp alltraps
8010533c:	e9 5a fb ff ff       	jmp    80104e9b <alltraps>

80105341 <vector13>:
.globl vector13
vector13:
  pushl $13
80105341:	6a 0d                	push   $0xd
  jmp alltraps
80105343:	e9 53 fb ff ff       	jmp    80104e9b <alltraps>

80105348 <vector14>:
.globl vector14
vector14:
  pushl $14
80105348:	6a 0e                	push   $0xe
  jmp alltraps
8010534a:	e9 4c fb ff ff       	jmp    80104e9b <alltraps>

8010534f <vector15>:
.globl vector15
vector15:
  pushl $0
8010534f:	6a 00                	push   $0x0
  pushl $15
80105351:	6a 0f                	push   $0xf
  jmp alltraps
80105353:	e9 43 fb ff ff       	jmp    80104e9b <alltraps>

80105358 <vector16>:
.globl vector16
vector16:
  pushl $0
80105358:	6a 00                	push   $0x0
  pushl $16
8010535a:	6a 10                	push   $0x10
  jmp alltraps
8010535c:	e9 3a fb ff ff       	jmp    80104e9b <alltraps>

80105361 <vector17>:
.globl vector17
vector17:
  pushl $17
80105361:	6a 11                	push   $0x11
  jmp alltraps
80105363:	e9 33 fb ff ff       	jmp    80104e9b <alltraps>

80105368 <vector18>:
.globl vector18
vector18:
  pushl $0
80105368:	6a 00                	push   $0x0
  pushl $18
8010536a:	6a 12                	push   $0x12
  jmp alltraps
8010536c:	e9 2a fb ff ff       	jmp    80104e9b <alltraps>

80105371 <vector19>:
.globl vector19
vector19:
  pushl $0
80105371:	6a 00                	push   $0x0
  pushl $19
80105373:	6a 13                	push   $0x13
  jmp alltraps
80105375:	e9 21 fb ff ff       	jmp    80104e9b <alltraps>

8010537a <vector20>:
.globl vector20
vector20:
  pushl $0
8010537a:	6a 00                	push   $0x0
  pushl $20
8010537c:	6a 14                	push   $0x14
  jmp alltraps
8010537e:	e9 18 fb ff ff       	jmp    80104e9b <alltraps>

80105383 <vector21>:
.globl vector21
vector21:
  pushl $0
80105383:	6a 00                	push   $0x0
  pushl $21
80105385:	6a 15                	push   $0x15
  jmp alltraps
80105387:	e9 0f fb ff ff       	jmp    80104e9b <alltraps>

8010538c <vector22>:
.globl vector22
vector22:
  pushl $0
8010538c:	6a 00                	push   $0x0
  pushl $22
8010538e:	6a 16                	push   $0x16
  jmp alltraps
80105390:	e9 06 fb ff ff       	jmp    80104e9b <alltraps>

80105395 <vector23>:
.globl vector23
vector23:
  pushl $0
80105395:	6a 00                	push   $0x0
  pushl $23
80105397:	6a 17                	push   $0x17
  jmp alltraps
80105399:	e9 fd fa ff ff       	jmp    80104e9b <alltraps>

8010539e <vector24>:
.globl vector24
vector24:
  pushl $0
8010539e:	6a 00                	push   $0x0
  pushl $24
801053a0:	6a 18                	push   $0x18
  jmp alltraps
801053a2:	e9 f4 fa ff ff       	jmp    80104e9b <alltraps>

801053a7 <vector25>:
.globl vector25
vector25:
  pushl $0
801053a7:	6a 00                	push   $0x0
  pushl $25
801053a9:	6a 19                	push   $0x19
  jmp alltraps
801053ab:	e9 eb fa ff ff       	jmp    80104e9b <alltraps>

801053b0 <vector26>:
.globl vector26
vector26:
  pushl $0
801053b0:	6a 00                	push   $0x0
  pushl $26
801053b2:	6a 1a                	push   $0x1a
  jmp alltraps
801053b4:	e9 e2 fa ff ff       	jmp    80104e9b <alltraps>

801053b9 <vector27>:
.globl vector27
vector27:
  pushl $0
801053b9:	6a 00                	push   $0x0
  pushl $27
801053bb:	6a 1b                	push   $0x1b
  jmp alltraps
801053bd:	e9 d9 fa ff ff       	jmp    80104e9b <alltraps>

801053c2 <vector28>:
.globl vector28
vector28:
  pushl $0
801053c2:	6a 00                	push   $0x0
  pushl $28
801053c4:	6a 1c                	push   $0x1c
  jmp alltraps
801053c6:	e9 d0 fa ff ff       	jmp    80104e9b <alltraps>

801053cb <vector29>:
.globl vector29
vector29:
  pushl $0
801053cb:	6a 00                	push   $0x0
  pushl $29
801053cd:	6a 1d                	push   $0x1d
  jmp alltraps
801053cf:	e9 c7 fa ff ff       	jmp    80104e9b <alltraps>

801053d4 <vector30>:
.globl vector30
vector30:
  pushl $0
801053d4:	6a 00                	push   $0x0
  pushl $30
801053d6:	6a 1e                	push   $0x1e
  jmp alltraps
801053d8:	e9 be fa ff ff       	jmp    80104e9b <alltraps>

801053dd <vector31>:
.globl vector31
vector31:
  pushl $0
801053dd:	6a 00                	push   $0x0
  pushl $31
801053df:	6a 1f                	push   $0x1f
  jmp alltraps
801053e1:	e9 b5 fa ff ff       	jmp    80104e9b <alltraps>

801053e6 <vector32>:
.globl vector32
vector32:
  pushl $0
801053e6:	6a 00                	push   $0x0
  pushl $32
801053e8:	6a 20                	push   $0x20
  jmp alltraps
801053ea:	e9 ac fa ff ff       	jmp    80104e9b <alltraps>

801053ef <vector33>:
.globl vector33
vector33:
  pushl $0
801053ef:	6a 00                	push   $0x0
  pushl $33
801053f1:	6a 21                	push   $0x21
  jmp alltraps
801053f3:	e9 a3 fa ff ff       	jmp    80104e9b <alltraps>

801053f8 <vector34>:
.globl vector34
vector34:
  pushl $0
801053f8:	6a 00                	push   $0x0
  pushl $34
801053fa:	6a 22                	push   $0x22
  jmp alltraps
801053fc:	e9 9a fa ff ff       	jmp    80104e9b <alltraps>

80105401 <vector35>:
.globl vector35
vector35:
  pushl $0
80105401:	6a 00                	push   $0x0
  pushl $35
80105403:	6a 23                	push   $0x23
  jmp alltraps
80105405:	e9 91 fa ff ff       	jmp    80104e9b <alltraps>

8010540a <vector36>:
.globl vector36
vector36:
  pushl $0
8010540a:	6a 00                	push   $0x0
  pushl $36
8010540c:	6a 24                	push   $0x24
  jmp alltraps
8010540e:	e9 88 fa ff ff       	jmp    80104e9b <alltraps>

80105413 <vector37>:
.globl vector37
vector37:
  pushl $0
80105413:	6a 00                	push   $0x0
  pushl $37
80105415:	6a 25                	push   $0x25
  jmp alltraps
80105417:	e9 7f fa ff ff       	jmp    80104e9b <alltraps>

8010541c <vector38>:
.globl vector38
vector38:
  pushl $0
8010541c:	6a 00                	push   $0x0
  pushl $38
8010541e:	6a 26                	push   $0x26
  jmp alltraps
80105420:	e9 76 fa ff ff       	jmp    80104e9b <alltraps>

80105425 <vector39>:
.globl vector39
vector39:
  pushl $0
80105425:	6a 00                	push   $0x0
  pushl $39
80105427:	6a 27                	push   $0x27
  jmp alltraps
80105429:	e9 6d fa ff ff       	jmp    80104e9b <alltraps>

8010542e <vector40>:
.globl vector40
vector40:
  pushl $0
8010542e:	6a 00                	push   $0x0
  pushl $40
80105430:	6a 28                	push   $0x28
  jmp alltraps
80105432:	e9 64 fa ff ff       	jmp    80104e9b <alltraps>

80105437 <vector41>:
.globl vector41
vector41:
  pushl $0
80105437:	6a 00                	push   $0x0
  pushl $41
80105439:	6a 29                	push   $0x29
  jmp alltraps
8010543b:	e9 5b fa ff ff       	jmp    80104e9b <alltraps>

80105440 <vector42>:
.globl vector42
vector42:
  pushl $0
80105440:	6a 00                	push   $0x0
  pushl $42
80105442:	6a 2a                	push   $0x2a
  jmp alltraps
80105444:	e9 52 fa ff ff       	jmp    80104e9b <alltraps>

80105449 <vector43>:
.globl vector43
vector43:
  pushl $0
80105449:	6a 00                	push   $0x0
  pushl $43
8010544b:	6a 2b                	push   $0x2b
  jmp alltraps
8010544d:	e9 49 fa ff ff       	jmp    80104e9b <alltraps>

80105452 <vector44>:
.globl vector44
vector44:
  pushl $0
80105452:	6a 00                	push   $0x0
  pushl $44
80105454:	6a 2c                	push   $0x2c
  jmp alltraps
80105456:	e9 40 fa ff ff       	jmp    80104e9b <alltraps>

8010545b <vector45>:
.globl vector45
vector45:
  pushl $0
8010545b:	6a 00                	push   $0x0
  pushl $45
8010545d:	6a 2d                	push   $0x2d
  jmp alltraps
8010545f:	e9 37 fa ff ff       	jmp    80104e9b <alltraps>

80105464 <vector46>:
.globl vector46
vector46:
  pushl $0
80105464:	6a 00                	push   $0x0
  pushl $46
80105466:	6a 2e                	push   $0x2e
  jmp alltraps
80105468:	e9 2e fa ff ff       	jmp    80104e9b <alltraps>

8010546d <vector47>:
.globl vector47
vector47:
  pushl $0
8010546d:	6a 00                	push   $0x0
  pushl $47
8010546f:	6a 2f                	push   $0x2f
  jmp alltraps
80105471:	e9 25 fa ff ff       	jmp    80104e9b <alltraps>

80105476 <vector48>:
.globl vector48
vector48:
  pushl $0
80105476:	6a 00                	push   $0x0
  pushl $48
80105478:	6a 30                	push   $0x30
  jmp alltraps
8010547a:	e9 1c fa ff ff       	jmp    80104e9b <alltraps>

8010547f <vector49>:
.globl vector49
vector49:
  pushl $0
8010547f:	6a 00                	push   $0x0
  pushl $49
80105481:	6a 31                	push   $0x31
  jmp alltraps
80105483:	e9 13 fa ff ff       	jmp    80104e9b <alltraps>

80105488 <vector50>:
.globl vector50
vector50:
  pushl $0
80105488:	6a 00                	push   $0x0
  pushl $50
8010548a:	6a 32                	push   $0x32
  jmp alltraps
8010548c:	e9 0a fa ff ff       	jmp    80104e9b <alltraps>

80105491 <vector51>:
.globl vector51
vector51:
  pushl $0
80105491:	6a 00                	push   $0x0
  pushl $51
80105493:	6a 33                	push   $0x33
  jmp alltraps
80105495:	e9 01 fa ff ff       	jmp    80104e9b <alltraps>

8010549a <vector52>:
.globl vector52
vector52:
  pushl $0
8010549a:	6a 00                	push   $0x0
  pushl $52
8010549c:	6a 34                	push   $0x34
  jmp alltraps
8010549e:	e9 f8 f9 ff ff       	jmp    80104e9b <alltraps>

801054a3 <vector53>:
.globl vector53
vector53:
  pushl $0
801054a3:	6a 00                	push   $0x0
  pushl $53
801054a5:	6a 35                	push   $0x35
  jmp alltraps
801054a7:	e9 ef f9 ff ff       	jmp    80104e9b <alltraps>

801054ac <vector54>:
.globl vector54
vector54:
  pushl $0
801054ac:	6a 00                	push   $0x0
  pushl $54
801054ae:	6a 36                	push   $0x36
  jmp alltraps
801054b0:	e9 e6 f9 ff ff       	jmp    80104e9b <alltraps>

801054b5 <vector55>:
.globl vector55
vector55:
  pushl $0
801054b5:	6a 00                	push   $0x0
  pushl $55
801054b7:	6a 37                	push   $0x37
  jmp alltraps
801054b9:	e9 dd f9 ff ff       	jmp    80104e9b <alltraps>

801054be <vector56>:
.globl vector56
vector56:
  pushl $0
801054be:	6a 00                	push   $0x0
  pushl $56
801054c0:	6a 38                	push   $0x38
  jmp alltraps
801054c2:	e9 d4 f9 ff ff       	jmp    80104e9b <alltraps>

801054c7 <vector57>:
.globl vector57
vector57:
  pushl $0
801054c7:	6a 00                	push   $0x0
  pushl $57
801054c9:	6a 39                	push   $0x39
  jmp alltraps
801054cb:	e9 cb f9 ff ff       	jmp    80104e9b <alltraps>

801054d0 <vector58>:
.globl vector58
vector58:
  pushl $0
801054d0:	6a 00                	push   $0x0
  pushl $58
801054d2:	6a 3a                	push   $0x3a
  jmp alltraps
801054d4:	e9 c2 f9 ff ff       	jmp    80104e9b <alltraps>

801054d9 <vector59>:
.globl vector59
vector59:
  pushl $0
801054d9:	6a 00                	push   $0x0
  pushl $59
801054db:	6a 3b                	push   $0x3b
  jmp alltraps
801054dd:	e9 b9 f9 ff ff       	jmp    80104e9b <alltraps>

801054e2 <vector60>:
.globl vector60
vector60:
  pushl $0
801054e2:	6a 00                	push   $0x0
  pushl $60
801054e4:	6a 3c                	push   $0x3c
  jmp alltraps
801054e6:	e9 b0 f9 ff ff       	jmp    80104e9b <alltraps>

801054eb <vector61>:
.globl vector61
vector61:
  pushl $0
801054eb:	6a 00                	push   $0x0
  pushl $61
801054ed:	6a 3d                	push   $0x3d
  jmp alltraps
801054ef:	e9 a7 f9 ff ff       	jmp    80104e9b <alltraps>

801054f4 <vector62>:
.globl vector62
vector62:
  pushl $0
801054f4:	6a 00                	push   $0x0
  pushl $62
801054f6:	6a 3e                	push   $0x3e
  jmp alltraps
801054f8:	e9 9e f9 ff ff       	jmp    80104e9b <alltraps>

801054fd <vector63>:
.globl vector63
vector63:
  pushl $0
801054fd:	6a 00                	push   $0x0
  pushl $63
801054ff:	6a 3f                	push   $0x3f
  jmp alltraps
80105501:	e9 95 f9 ff ff       	jmp    80104e9b <alltraps>

80105506 <vector64>:
.globl vector64
vector64:
  pushl $0
80105506:	6a 00                	push   $0x0
  pushl $64
80105508:	6a 40                	push   $0x40
  jmp alltraps
8010550a:	e9 8c f9 ff ff       	jmp    80104e9b <alltraps>

8010550f <vector65>:
.globl vector65
vector65:
  pushl $0
8010550f:	6a 00                	push   $0x0
  pushl $65
80105511:	6a 41                	push   $0x41
  jmp alltraps
80105513:	e9 83 f9 ff ff       	jmp    80104e9b <alltraps>

80105518 <vector66>:
.globl vector66
vector66:
  pushl $0
80105518:	6a 00                	push   $0x0
  pushl $66
8010551a:	6a 42                	push   $0x42
  jmp alltraps
8010551c:	e9 7a f9 ff ff       	jmp    80104e9b <alltraps>

80105521 <vector67>:
.globl vector67
vector67:
  pushl $0
80105521:	6a 00                	push   $0x0
  pushl $67
80105523:	6a 43                	push   $0x43
  jmp alltraps
80105525:	e9 71 f9 ff ff       	jmp    80104e9b <alltraps>

8010552a <vector68>:
.globl vector68
vector68:
  pushl $0
8010552a:	6a 00                	push   $0x0
  pushl $68
8010552c:	6a 44                	push   $0x44
  jmp alltraps
8010552e:	e9 68 f9 ff ff       	jmp    80104e9b <alltraps>

80105533 <vector69>:
.globl vector69
vector69:
  pushl $0
80105533:	6a 00                	push   $0x0
  pushl $69
80105535:	6a 45                	push   $0x45
  jmp alltraps
80105537:	e9 5f f9 ff ff       	jmp    80104e9b <alltraps>

8010553c <vector70>:
.globl vector70
vector70:
  pushl $0
8010553c:	6a 00                	push   $0x0
  pushl $70
8010553e:	6a 46                	push   $0x46
  jmp alltraps
80105540:	e9 56 f9 ff ff       	jmp    80104e9b <alltraps>

80105545 <vector71>:
.globl vector71
vector71:
  pushl $0
80105545:	6a 00                	push   $0x0
  pushl $71
80105547:	6a 47                	push   $0x47
  jmp alltraps
80105549:	e9 4d f9 ff ff       	jmp    80104e9b <alltraps>

8010554e <vector72>:
.globl vector72
vector72:
  pushl $0
8010554e:	6a 00                	push   $0x0
  pushl $72
80105550:	6a 48                	push   $0x48
  jmp alltraps
80105552:	e9 44 f9 ff ff       	jmp    80104e9b <alltraps>

80105557 <vector73>:
.globl vector73
vector73:
  pushl $0
80105557:	6a 00                	push   $0x0
  pushl $73
80105559:	6a 49                	push   $0x49
  jmp alltraps
8010555b:	e9 3b f9 ff ff       	jmp    80104e9b <alltraps>

80105560 <vector74>:
.globl vector74
vector74:
  pushl $0
80105560:	6a 00                	push   $0x0
  pushl $74
80105562:	6a 4a                	push   $0x4a
  jmp alltraps
80105564:	e9 32 f9 ff ff       	jmp    80104e9b <alltraps>

80105569 <vector75>:
.globl vector75
vector75:
  pushl $0
80105569:	6a 00                	push   $0x0
  pushl $75
8010556b:	6a 4b                	push   $0x4b
  jmp alltraps
8010556d:	e9 29 f9 ff ff       	jmp    80104e9b <alltraps>

80105572 <vector76>:
.globl vector76
vector76:
  pushl $0
80105572:	6a 00                	push   $0x0
  pushl $76
80105574:	6a 4c                	push   $0x4c
  jmp alltraps
80105576:	e9 20 f9 ff ff       	jmp    80104e9b <alltraps>

8010557b <vector77>:
.globl vector77
vector77:
  pushl $0
8010557b:	6a 00                	push   $0x0
  pushl $77
8010557d:	6a 4d                	push   $0x4d
  jmp alltraps
8010557f:	e9 17 f9 ff ff       	jmp    80104e9b <alltraps>

80105584 <vector78>:
.globl vector78
vector78:
  pushl $0
80105584:	6a 00                	push   $0x0
  pushl $78
80105586:	6a 4e                	push   $0x4e
  jmp alltraps
80105588:	e9 0e f9 ff ff       	jmp    80104e9b <alltraps>

8010558d <vector79>:
.globl vector79
vector79:
  pushl $0
8010558d:	6a 00                	push   $0x0
  pushl $79
8010558f:	6a 4f                	push   $0x4f
  jmp alltraps
80105591:	e9 05 f9 ff ff       	jmp    80104e9b <alltraps>

80105596 <vector80>:
.globl vector80
vector80:
  pushl $0
80105596:	6a 00                	push   $0x0
  pushl $80
80105598:	6a 50                	push   $0x50
  jmp alltraps
8010559a:	e9 fc f8 ff ff       	jmp    80104e9b <alltraps>

8010559f <vector81>:
.globl vector81
vector81:
  pushl $0
8010559f:	6a 00                	push   $0x0
  pushl $81
801055a1:	6a 51                	push   $0x51
  jmp alltraps
801055a3:	e9 f3 f8 ff ff       	jmp    80104e9b <alltraps>

801055a8 <vector82>:
.globl vector82
vector82:
  pushl $0
801055a8:	6a 00                	push   $0x0
  pushl $82
801055aa:	6a 52                	push   $0x52
  jmp alltraps
801055ac:	e9 ea f8 ff ff       	jmp    80104e9b <alltraps>

801055b1 <vector83>:
.globl vector83
vector83:
  pushl $0
801055b1:	6a 00                	push   $0x0
  pushl $83
801055b3:	6a 53                	push   $0x53
  jmp alltraps
801055b5:	e9 e1 f8 ff ff       	jmp    80104e9b <alltraps>

801055ba <vector84>:
.globl vector84
vector84:
  pushl $0
801055ba:	6a 00                	push   $0x0
  pushl $84
801055bc:	6a 54                	push   $0x54
  jmp alltraps
801055be:	e9 d8 f8 ff ff       	jmp    80104e9b <alltraps>

801055c3 <vector85>:
.globl vector85
vector85:
  pushl $0
801055c3:	6a 00                	push   $0x0
  pushl $85
801055c5:	6a 55                	push   $0x55
  jmp alltraps
801055c7:	e9 cf f8 ff ff       	jmp    80104e9b <alltraps>

801055cc <vector86>:
.globl vector86
vector86:
  pushl $0
801055cc:	6a 00                	push   $0x0
  pushl $86
801055ce:	6a 56                	push   $0x56
  jmp alltraps
801055d0:	e9 c6 f8 ff ff       	jmp    80104e9b <alltraps>

801055d5 <vector87>:
.globl vector87
vector87:
  pushl $0
801055d5:	6a 00                	push   $0x0
  pushl $87
801055d7:	6a 57                	push   $0x57
  jmp alltraps
801055d9:	e9 bd f8 ff ff       	jmp    80104e9b <alltraps>

801055de <vector88>:
.globl vector88
vector88:
  pushl $0
801055de:	6a 00                	push   $0x0
  pushl $88
801055e0:	6a 58                	push   $0x58
  jmp alltraps
801055e2:	e9 b4 f8 ff ff       	jmp    80104e9b <alltraps>

801055e7 <vector89>:
.globl vector89
vector89:
  pushl $0
801055e7:	6a 00                	push   $0x0
  pushl $89
801055e9:	6a 59                	push   $0x59
  jmp alltraps
801055eb:	e9 ab f8 ff ff       	jmp    80104e9b <alltraps>

801055f0 <vector90>:
.globl vector90
vector90:
  pushl $0
801055f0:	6a 00                	push   $0x0
  pushl $90
801055f2:	6a 5a                	push   $0x5a
  jmp alltraps
801055f4:	e9 a2 f8 ff ff       	jmp    80104e9b <alltraps>

801055f9 <vector91>:
.globl vector91
vector91:
  pushl $0
801055f9:	6a 00                	push   $0x0
  pushl $91
801055fb:	6a 5b                	push   $0x5b
  jmp alltraps
801055fd:	e9 99 f8 ff ff       	jmp    80104e9b <alltraps>

80105602 <vector92>:
.globl vector92
vector92:
  pushl $0
80105602:	6a 00                	push   $0x0
  pushl $92
80105604:	6a 5c                	push   $0x5c
  jmp alltraps
80105606:	e9 90 f8 ff ff       	jmp    80104e9b <alltraps>

8010560b <vector93>:
.globl vector93
vector93:
  pushl $0
8010560b:	6a 00                	push   $0x0
  pushl $93
8010560d:	6a 5d                	push   $0x5d
  jmp alltraps
8010560f:	e9 87 f8 ff ff       	jmp    80104e9b <alltraps>

80105614 <vector94>:
.globl vector94
vector94:
  pushl $0
80105614:	6a 00                	push   $0x0
  pushl $94
80105616:	6a 5e                	push   $0x5e
  jmp alltraps
80105618:	e9 7e f8 ff ff       	jmp    80104e9b <alltraps>

8010561d <vector95>:
.globl vector95
vector95:
  pushl $0
8010561d:	6a 00                	push   $0x0
  pushl $95
8010561f:	6a 5f                	push   $0x5f
  jmp alltraps
80105621:	e9 75 f8 ff ff       	jmp    80104e9b <alltraps>

80105626 <vector96>:
.globl vector96
vector96:
  pushl $0
80105626:	6a 00                	push   $0x0
  pushl $96
80105628:	6a 60                	push   $0x60
  jmp alltraps
8010562a:	e9 6c f8 ff ff       	jmp    80104e9b <alltraps>

8010562f <vector97>:
.globl vector97
vector97:
  pushl $0
8010562f:	6a 00                	push   $0x0
  pushl $97
80105631:	6a 61                	push   $0x61
  jmp alltraps
80105633:	e9 63 f8 ff ff       	jmp    80104e9b <alltraps>

80105638 <vector98>:
.globl vector98
vector98:
  pushl $0
80105638:	6a 00                	push   $0x0
  pushl $98
8010563a:	6a 62                	push   $0x62
  jmp alltraps
8010563c:	e9 5a f8 ff ff       	jmp    80104e9b <alltraps>

80105641 <vector99>:
.globl vector99
vector99:
  pushl $0
80105641:	6a 00                	push   $0x0
  pushl $99
80105643:	6a 63                	push   $0x63
  jmp alltraps
80105645:	e9 51 f8 ff ff       	jmp    80104e9b <alltraps>

8010564a <vector100>:
.globl vector100
vector100:
  pushl $0
8010564a:	6a 00                	push   $0x0
  pushl $100
8010564c:	6a 64                	push   $0x64
  jmp alltraps
8010564e:	e9 48 f8 ff ff       	jmp    80104e9b <alltraps>

80105653 <vector101>:
.globl vector101
vector101:
  pushl $0
80105653:	6a 00                	push   $0x0
  pushl $101
80105655:	6a 65                	push   $0x65
  jmp alltraps
80105657:	e9 3f f8 ff ff       	jmp    80104e9b <alltraps>

8010565c <vector102>:
.globl vector102
vector102:
  pushl $0
8010565c:	6a 00                	push   $0x0
  pushl $102
8010565e:	6a 66                	push   $0x66
  jmp alltraps
80105660:	e9 36 f8 ff ff       	jmp    80104e9b <alltraps>

80105665 <vector103>:
.globl vector103
vector103:
  pushl $0
80105665:	6a 00                	push   $0x0
  pushl $103
80105667:	6a 67                	push   $0x67
  jmp alltraps
80105669:	e9 2d f8 ff ff       	jmp    80104e9b <alltraps>

8010566e <vector104>:
.globl vector104
vector104:
  pushl $0
8010566e:	6a 00                	push   $0x0
  pushl $104
80105670:	6a 68                	push   $0x68
  jmp alltraps
80105672:	e9 24 f8 ff ff       	jmp    80104e9b <alltraps>

80105677 <vector105>:
.globl vector105
vector105:
  pushl $0
80105677:	6a 00                	push   $0x0
  pushl $105
80105679:	6a 69                	push   $0x69
  jmp alltraps
8010567b:	e9 1b f8 ff ff       	jmp    80104e9b <alltraps>

80105680 <vector106>:
.globl vector106
vector106:
  pushl $0
80105680:	6a 00                	push   $0x0
  pushl $106
80105682:	6a 6a                	push   $0x6a
  jmp alltraps
80105684:	e9 12 f8 ff ff       	jmp    80104e9b <alltraps>

80105689 <vector107>:
.globl vector107
vector107:
  pushl $0
80105689:	6a 00                	push   $0x0
  pushl $107
8010568b:	6a 6b                	push   $0x6b
  jmp alltraps
8010568d:	e9 09 f8 ff ff       	jmp    80104e9b <alltraps>

80105692 <vector108>:
.globl vector108
vector108:
  pushl $0
80105692:	6a 00                	push   $0x0
  pushl $108
80105694:	6a 6c                	push   $0x6c
  jmp alltraps
80105696:	e9 00 f8 ff ff       	jmp    80104e9b <alltraps>

8010569b <vector109>:
.globl vector109
vector109:
  pushl $0
8010569b:	6a 00                	push   $0x0
  pushl $109
8010569d:	6a 6d                	push   $0x6d
  jmp alltraps
8010569f:	e9 f7 f7 ff ff       	jmp    80104e9b <alltraps>

801056a4 <vector110>:
.globl vector110
vector110:
  pushl $0
801056a4:	6a 00                	push   $0x0
  pushl $110
801056a6:	6a 6e                	push   $0x6e
  jmp alltraps
801056a8:	e9 ee f7 ff ff       	jmp    80104e9b <alltraps>

801056ad <vector111>:
.globl vector111
vector111:
  pushl $0
801056ad:	6a 00                	push   $0x0
  pushl $111
801056af:	6a 6f                	push   $0x6f
  jmp alltraps
801056b1:	e9 e5 f7 ff ff       	jmp    80104e9b <alltraps>

801056b6 <vector112>:
.globl vector112
vector112:
  pushl $0
801056b6:	6a 00                	push   $0x0
  pushl $112
801056b8:	6a 70                	push   $0x70
  jmp alltraps
801056ba:	e9 dc f7 ff ff       	jmp    80104e9b <alltraps>

801056bf <vector113>:
.globl vector113
vector113:
  pushl $0
801056bf:	6a 00                	push   $0x0
  pushl $113
801056c1:	6a 71                	push   $0x71
  jmp alltraps
801056c3:	e9 d3 f7 ff ff       	jmp    80104e9b <alltraps>

801056c8 <vector114>:
.globl vector114
vector114:
  pushl $0
801056c8:	6a 00                	push   $0x0
  pushl $114
801056ca:	6a 72                	push   $0x72
  jmp alltraps
801056cc:	e9 ca f7 ff ff       	jmp    80104e9b <alltraps>

801056d1 <vector115>:
.globl vector115
vector115:
  pushl $0
801056d1:	6a 00                	push   $0x0
  pushl $115
801056d3:	6a 73                	push   $0x73
  jmp alltraps
801056d5:	e9 c1 f7 ff ff       	jmp    80104e9b <alltraps>

801056da <vector116>:
.globl vector116
vector116:
  pushl $0
801056da:	6a 00                	push   $0x0
  pushl $116
801056dc:	6a 74                	push   $0x74
  jmp alltraps
801056de:	e9 b8 f7 ff ff       	jmp    80104e9b <alltraps>

801056e3 <vector117>:
.globl vector117
vector117:
  pushl $0
801056e3:	6a 00                	push   $0x0
  pushl $117
801056e5:	6a 75                	push   $0x75
  jmp alltraps
801056e7:	e9 af f7 ff ff       	jmp    80104e9b <alltraps>

801056ec <vector118>:
.globl vector118
vector118:
  pushl $0
801056ec:	6a 00                	push   $0x0
  pushl $118
801056ee:	6a 76                	push   $0x76
  jmp alltraps
801056f0:	e9 a6 f7 ff ff       	jmp    80104e9b <alltraps>

801056f5 <vector119>:
.globl vector119
vector119:
  pushl $0
801056f5:	6a 00                	push   $0x0
  pushl $119
801056f7:	6a 77                	push   $0x77
  jmp alltraps
801056f9:	e9 9d f7 ff ff       	jmp    80104e9b <alltraps>

801056fe <vector120>:
.globl vector120
vector120:
  pushl $0
801056fe:	6a 00                	push   $0x0
  pushl $120
80105700:	6a 78                	push   $0x78
  jmp alltraps
80105702:	e9 94 f7 ff ff       	jmp    80104e9b <alltraps>

80105707 <vector121>:
.globl vector121
vector121:
  pushl $0
80105707:	6a 00                	push   $0x0
  pushl $121
80105709:	6a 79                	push   $0x79
  jmp alltraps
8010570b:	e9 8b f7 ff ff       	jmp    80104e9b <alltraps>

80105710 <vector122>:
.globl vector122
vector122:
  pushl $0
80105710:	6a 00                	push   $0x0
  pushl $122
80105712:	6a 7a                	push   $0x7a
  jmp alltraps
80105714:	e9 82 f7 ff ff       	jmp    80104e9b <alltraps>

80105719 <vector123>:
.globl vector123
vector123:
  pushl $0
80105719:	6a 00                	push   $0x0
  pushl $123
8010571b:	6a 7b                	push   $0x7b
  jmp alltraps
8010571d:	e9 79 f7 ff ff       	jmp    80104e9b <alltraps>

80105722 <vector124>:
.globl vector124
vector124:
  pushl $0
80105722:	6a 00                	push   $0x0
  pushl $124
80105724:	6a 7c                	push   $0x7c
  jmp alltraps
80105726:	e9 70 f7 ff ff       	jmp    80104e9b <alltraps>

8010572b <vector125>:
.globl vector125
vector125:
  pushl $0
8010572b:	6a 00                	push   $0x0
  pushl $125
8010572d:	6a 7d                	push   $0x7d
  jmp alltraps
8010572f:	e9 67 f7 ff ff       	jmp    80104e9b <alltraps>

80105734 <vector126>:
.globl vector126
vector126:
  pushl $0
80105734:	6a 00                	push   $0x0
  pushl $126
80105736:	6a 7e                	push   $0x7e
  jmp alltraps
80105738:	e9 5e f7 ff ff       	jmp    80104e9b <alltraps>

8010573d <vector127>:
.globl vector127
vector127:
  pushl $0
8010573d:	6a 00                	push   $0x0
  pushl $127
8010573f:	6a 7f                	push   $0x7f
  jmp alltraps
80105741:	e9 55 f7 ff ff       	jmp    80104e9b <alltraps>

80105746 <vector128>:
.globl vector128
vector128:
  pushl $0
80105746:	6a 00                	push   $0x0
  pushl $128
80105748:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010574d:	e9 49 f7 ff ff       	jmp    80104e9b <alltraps>

80105752 <vector129>:
.globl vector129
vector129:
  pushl $0
80105752:	6a 00                	push   $0x0
  pushl $129
80105754:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105759:	e9 3d f7 ff ff       	jmp    80104e9b <alltraps>

8010575e <vector130>:
.globl vector130
vector130:
  pushl $0
8010575e:	6a 00                	push   $0x0
  pushl $130
80105760:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105765:	e9 31 f7 ff ff       	jmp    80104e9b <alltraps>

8010576a <vector131>:
.globl vector131
vector131:
  pushl $0
8010576a:	6a 00                	push   $0x0
  pushl $131
8010576c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105771:	e9 25 f7 ff ff       	jmp    80104e9b <alltraps>

80105776 <vector132>:
.globl vector132
vector132:
  pushl $0
80105776:	6a 00                	push   $0x0
  pushl $132
80105778:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010577d:	e9 19 f7 ff ff       	jmp    80104e9b <alltraps>

80105782 <vector133>:
.globl vector133
vector133:
  pushl $0
80105782:	6a 00                	push   $0x0
  pushl $133
80105784:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105789:	e9 0d f7 ff ff       	jmp    80104e9b <alltraps>

8010578e <vector134>:
.globl vector134
vector134:
  pushl $0
8010578e:	6a 00                	push   $0x0
  pushl $134
80105790:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105795:	e9 01 f7 ff ff       	jmp    80104e9b <alltraps>

8010579a <vector135>:
.globl vector135
vector135:
  pushl $0
8010579a:	6a 00                	push   $0x0
  pushl $135
8010579c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057a1:	e9 f5 f6 ff ff       	jmp    80104e9b <alltraps>

801057a6 <vector136>:
.globl vector136
vector136:
  pushl $0
801057a6:	6a 00                	push   $0x0
  pushl $136
801057a8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057ad:	e9 e9 f6 ff ff       	jmp    80104e9b <alltraps>

801057b2 <vector137>:
.globl vector137
vector137:
  pushl $0
801057b2:	6a 00                	push   $0x0
  pushl $137
801057b4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057b9:	e9 dd f6 ff ff       	jmp    80104e9b <alltraps>

801057be <vector138>:
.globl vector138
vector138:
  pushl $0
801057be:	6a 00                	push   $0x0
  pushl $138
801057c0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801057c5:	e9 d1 f6 ff ff       	jmp    80104e9b <alltraps>

801057ca <vector139>:
.globl vector139
vector139:
  pushl $0
801057ca:	6a 00                	push   $0x0
  pushl $139
801057cc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801057d1:	e9 c5 f6 ff ff       	jmp    80104e9b <alltraps>

801057d6 <vector140>:
.globl vector140
vector140:
  pushl $0
801057d6:	6a 00                	push   $0x0
  pushl $140
801057d8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801057dd:	e9 b9 f6 ff ff       	jmp    80104e9b <alltraps>

801057e2 <vector141>:
.globl vector141
vector141:
  pushl $0
801057e2:	6a 00                	push   $0x0
  pushl $141
801057e4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801057e9:	e9 ad f6 ff ff       	jmp    80104e9b <alltraps>

801057ee <vector142>:
.globl vector142
vector142:
  pushl $0
801057ee:	6a 00                	push   $0x0
  pushl $142
801057f0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801057f5:	e9 a1 f6 ff ff       	jmp    80104e9b <alltraps>

801057fa <vector143>:
.globl vector143
vector143:
  pushl $0
801057fa:	6a 00                	push   $0x0
  pushl $143
801057fc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105801:	e9 95 f6 ff ff       	jmp    80104e9b <alltraps>

80105806 <vector144>:
.globl vector144
vector144:
  pushl $0
80105806:	6a 00                	push   $0x0
  pushl $144
80105808:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010580d:	e9 89 f6 ff ff       	jmp    80104e9b <alltraps>

80105812 <vector145>:
.globl vector145
vector145:
  pushl $0
80105812:	6a 00                	push   $0x0
  pushl $145
80105814:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105819:	e9 7d f6 ff ff       	jmp    80104e9b <alltraps>

8010581e <vector146>:
.globl vector146
vector146:
  pushl $0
8010581e:	6a 00                	push   $0x0
  pushl $146
80105820:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105825:	e9 71 f6 ff ff       	jmp    80104e9b <alltraps>

8010582a <vector147>:
.globl vector147
vector147:
  pushl $0
8010582a:	6a 00                	push   $0x0
  pushl $147
8010582c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105831:	e9 65 f6 ff ff       	jmp    80104e9b <alltraps>

80105836 <vector148>:
.globl vector148
vector148:
  pushl $0
80105836:	6a 00                	push   $0x0
  pushl $148
80105838:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010583d:	e9 59 f6 ff ff       	jmp    80104e9b <alltraps>

80105842 <vector149>:
.globl vector149
vector149:
  pushl $0
80105842:	6a 00                	push   $0x0
  pushl $149
80105844:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105849:	e9 4d f6 ff ff       	jmp    80104e9b <alltraps>

8010584e <vector150>:
.globl vector150
vector150:
  pushl $0
8010584e:	6a 00                	push   $0x0
  pushl $150
80105850:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105855:	e9 41 f6 ff ff       	jmp    80104e9b <alltraps>

8010585a <vector151>:
.globl vector151
vector151:
  pushl $0
8010585a:	6a 00                	push   $0x0
  pushl $151
8010585c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105861:	e9 35 f6 ff ff       	jmp    80104e9b <alltraps>

80105866 <vector152>:
.globl vector152
vector152:
  pushl $0
80105866:	6a 00                	push   $0x0
  pushl $152
80105868:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010586d:	e9 29 f6 ff ff       	jmp    80104e9b <alltraps>

80105872 <vector153>:
.globl vector153
vector153:
  pushl $0
80105872:	6a 00                	push   $0x0
  pushl $153
80105874:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105879:	e9 1d f6 ff ff       	jmp    80104e9b <alltraps>

8010587e <vector154>:
.globl vector154
vector154:
  pushl $0
8010587e:	6a 00                	push   $0x0
  pushl $154
80105880:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105885:	e9 11 f6 ff ff       	jmp    80104e9b <alltraps>

8010588a <vector155>:
.globl vector155
vector155:
  pushl $0
8010588a:	6a 00                	push   $0x0
  pushl $155
8010588c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105891:	e9 05 f6 ff ff       	jmp    80104e9b <alltraps>

80105896 <vector156>:
.globl vector156
vector156:
  pushl $0
80105896:	6a 00                	push   $0x0
  pushl $156
80105898:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010589d:	e9 f9 f5 ff ff       	jmp    80104e9b <alltraps>

801058a2 <vector157>:
.globl vector157
vector157:
  pushl $0
801058a2:	6a 00                	push   $0x0
  pushl $157
801058a4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058a9:	e9 ed f5 ff ff       	jmp    80104e9b <alltraps>

801058ae <vector158>:
.globl vector158
vector158:
  pushl $0
801058ae:	6a 00                	push   $0x0
  pushl $158
801058b0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058b5:	e9 e1 f5 ff ff       	jmp    80104e9b <alltraps>

801058ba <vector159>:
.globl vector159
vector159:
  pushl $0
801058ba:	6a 00                	push   $0x0
  pushl $159
801058bc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801058c1:	e9 d5 f5 ff ff       	jmp    80104e9b <alltraps>

801058c6 <vector160>:
.globl vector160
vector160:
  pushl $0
801058c6:	6a 00                	push   $0x0
  pushl $160
801058c8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801058cd:	e9 c9 f5 ff ff       	jmp    80104e9b <alltraps>

801058d2 <vector161>:
.globl vector161
vector161:
  pushl $0
801058d2:	6a 00                	push   $0x0
  pushl $161
801058d4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801058d9:	e9 bd f5 ff ff       	jmp    80104e9b <alltraps>

801058de <vector162>:
.globl vector162
vector162:
  pushl $0
801058de:	6a 00                	push   $0x0
  pushl $162
801058e0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801058e5:	e9 b1 f5 ff ff       	jmp    80104e9b <alltraps>

801058ea <vector163>:
.globl vector163
vector163:
  pushl $0
801058ea:	6a 00                	push   $0x0
  pushl $163
801058ec:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801058f1:	e9 a5 f5 ff ff       	jmp    80104e9b <alltraps>

801058f6 <vector164>:
.globl vector164
vector164:
  pushl $0
801058f6:	6a 00                	push   $0x0
  pushl $164
801058f8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801058fd:	e9 99 f5 ff ff       	jmp    80104e9b <alltraps>

80105902 <vector165>:
.globl vector165
vector165:
  pushl $0
80105902:	6a 00                	push   $0x0
  pushl $165
80105904:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105909:	e9 8d f5 ff ff       	jmp    80104e9b <alltraps>

8010590e <vector166>:
.globl vector166
vector166:
  pushl $0
8010590e:	6a 00                	push   $0x0
  pushl $166
80105910:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105915:	e9 81 f5 ff ff       	jmp    80104e9b <alltraps>

8010591a <vector167>:
.globl vector167
vector167:
  pushl $0
8010591a:	6a 00                	push   $0x0
  pushl $167
8010591c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105921:	e9 75 f5 ff ff       	jmp    80104e9b <alltraps>

80105926 <vector168>:
.globl vector168
vector168:
  pushl $0
80105926:	6a 00                	push   $0x0
  pushl $168
80105928:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010592d:	e9 69 f5 ff ff       	jmp    80104e9b <alltraps>

80105932 <vector169>:
.globl vector169
vector169:
  pushl $0
80105932:	6a 00                	push   $0x0
  pushl $169
80105934:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105939:	e9 5d f5 ff ff       	jmp    80104e9b <alltraps>

8010593e <vector170>:
.globl vector170
vector170:
  pushl $0
8010593e:	6a 00                	push   $0x0
  pushl $170
80105940:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105945:	e9 51 f5 ff ff       	jmp    80104e9b <alltraps>

8010594a <vector171>:
.globl vector171
vector171:
  pushl $0
8010594a:	6a 00                	push   $0x0
  pushl $171
8010594c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105951:	e9 45 f5 ff ff       	jmp    80104e9b <alltraps>

80105956 <vector172>:
.globl vector172
vector172:
  pushl $0
80105956:	6a 00                	push   $0x0
  pushl $172
80105958:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010595d:	e9 39 f5 ff ff       	jmp    80104e9b <alltraps>

80105962 <vector173>:
.globl vector173
vector173:
  pushl $0
80105962:	6a 00                	push   $0x0
  pushl $173
80105964:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105969:	e9 2d f5 ff ff       	jmp    80104e9b <alltraps>

8010596e <vector174>:
.globl vector174
vector174:
  pushl $0
8010596e:	6a 00                	push   $0x0
  pushl $174
80105970:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105975:	e9 21 f5 ff ff       	jmp    80104e9b <alltraps>

8010597a <vector175>:
.globl vector175
vector175:
  pushl $0
8010597a:	6a 00                	push   $0x0
  pushl $175
8010597c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105981:	e9 15 f5 ff ff       	jmp    80104e9b <alltraps>

80105986 <vector176>:
.globl vector176
vector176:
  pushl $0
80105986:	6a 00                	push   $0x0
  pushl $176
80105988:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010598d:	e9 09 f5 ff ff       	jmp    80104e9b <alltraps>

80105992 <vector177>:
.globl vector177
vector177:
  pushl $0
80105992:	6a 00                	push   $0x0
  pushl $177
80105994:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105999:	e9 fd f4 ff ff       	jmp    80104e9b <alltraps>

8010599e <vector178>:
.globl vector178
vector178:
  pushl $0
8010599e:	6a 00                	push   $0x0
  pushl $178
801059a0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801059a5:	e9 f1 f4 ff ff       	jmp    80104e9b <alltraps>

801059aa <vector179>:
.globl vector179
vector179:
  pushl $0
801059aa:	6a 00                	push   $0x0
  pushl $179
801059ac:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059b1:	e9 e5 f4 ff ff       	jmp    80104e9b <alltraps>

801059b6 <vector180>:
.globl vector180
vector180:
  pushl $0
801059b6:	6a 00                	push   $0x0
  pushl $180
801059b8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801059bd:	e9 d9 f4 ff ff       	jmp    80104e9b <alltraps>

801059c2 <vector181>:
.globl vector181
vector181:
  pushl $0
801059c2:	6a 00                	push   $0x0
  pushl $181
801059c4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801059c9:	e9 cd f4 ff ff       	jmp    80104e9b <alltraps>

801059ce <vector182>:
.globl vector182
vector182:
  pushl $0
801059ce:	6a 00                	push   $0x0
  pushl $182
801059d0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801059d5:	e9 c1 f4 ff ff       	jmp    80104e9b <alltraps>

801059da <vector183>:
.globl vector183
vector183:
  pushl $0
801059da:	6a 00                	push   $0x0
  pushl $183
801059dc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801059e1:	e9 b5 f4 ff ff       	jmp    80104e9b <alltraps>

801059e6 <vector184>:
.globl vector184
vector184:
  pushl $0
801059e6:	6a 00                	push   $0x0
  pushl $184
801059e8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801059ed:	e9 a9 f4 ff ff       	jmp    80104e9b <alltraps>

801059f2 <vector185>:
.globl vector185
vector185:
  pushl $0
801059f2:	6a 00                	push   $0x0
  pushl $185
801059f4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801059f9:	e9 9d f4 ff ff       	jmp    80104e9b <alltraps>

801059fe <vector186>:
.globl vector186
vector186:
  pushl $0
801059fe:	6a 00                	push   $0x0
  pushl $186
80105a00:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a05:	e9 91 f4 ff ff       	jmp    80104e9b <alltraps>

80105a0a <vector187>:
.globl vector187
vector187:
  pushl $0
80105a0a:	6a 00                	push   $0x0
  pushl $187
80105a0c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a11:	e9 85 f4 ff ff       	jmp    80104e9b <alltraps>

80105a16 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a16:	6a 00                	push   $0x0
  pushl $188
80105a18:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a1d:	e9 79 f4 ff ff       	jmp    80104e9b <alltraps>

80105a22 <vector189>:
.globl vector189
vector189:
  pushl $0
80105a22:	6a 00                	push   $0x0
  pushl $189
80105a24:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a29:	e9 6d f4 ff ff       	jmp    80104e9b <alltraps>

80105a2e <vector190>:
.globl vector190
vector190:
  pushl $0
80105a2e:	6a 00                	push   $0x0
  pushl $190
80105a30:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a35:	e9 61 f4 ff ff       	jmp    80104e9b <alltraps>

80105a3a <vector191>:
.globl vector191
vector191:
  pushl $0
80105a3a:	6a 00                	push   $0x0
  pushl $191
80105a3c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a41:	e9 55 f4 ff ff       	jmp    80104e9b <alltraps>

80105a46 <vector192>:
.globl vector192
vector192:
  pushl $0
80105a46:	6a 00                	push   $0x0
  pushl $192
80105a48:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a4d:	e9 49 f4 ff ff       	jmp    80104e9b <alltraps>

80105a52 <vector193>:
.globl vector193
vector193:
  pushl $0
80105a52:	6a 00                	push   $0x0
  pushl $193
80105a54:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a59:	e9 3d f4 ff ff       	jmp    80104e9b <alltraps>

80105a5e <vector194>:
.globl vector194
vector194:
  pushl $0
80105a5e:	6a 00                	push   $0x0
  pushl $194
80105a60:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105a65:	e9 31 f4 ff ff       	jmp    80104e9b <alltraps>

80105a6a <vector195>:
.globl vector195
vector195:
  pushl $0
80105a6a:	6a 00                	push   $0x0
  pushl $195
80105a6c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105a71:	e9 25 f4 ff ff       	jmp    80104e9b <alltraps>

80105a76 <vector196>:
.globl vector196
vector196:
  pushl $0
80105a76:	6a 00                	push   $0x0
  pushl $196
80105a78:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105a7d:	e9 19 f4 ff ff       	jmp    80104e9b <alltraps>

80105a82 <vector197>:
.globl vector197
vector197:
  pushl $0
80105a82:	6a 00                	push   $0x0
  pushl $197
80105a84:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105a89:	e9 0d f4 ff ff       	jmp    80104e9b <alltraps>

80105a8e <vector198>:
.globl vector198
vector198:
  pushl $0
80105a8e:	6a 00                	push   $0x0
  pushl $198
80105a90:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105a95:	e9 01 f4 ff ff       	jmp    80104e9b <alltraps>

80105a9a <vector199>:
.globl vector199
vector199:
  pushl $0
80105a9a:	6a 00                	push   $0x0
  pushl $199
80105a9c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105aa1:	e9 f5 f3 ff ff       	jmp    80104e9b <alltraps>

80105aa6 <vector200>:
.globl vector200
vector200:
  pushl $0
80105aa6:	6a 00                	push   $0x0
  pushl $200
80105aa8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105aad:	e9 e9 f3 ff ff       	jmp    80104e9b <alltraps>

80105ab2 <vector201>:
.globl vector201
vector201:
  pushl $0
80105ab2:	6a 00                	push   $0x0
  pushl $201
80105ab4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105ab9:	e9 dd f3 ff ff       	jmp    80104e9b <alltraps>

80105abe <vector202>:
.globl vector202
vector202:
  pushl $0
80105abe:	6a 00                	push   $0x0
  pushl $202
80105ac0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105ac5:	e9 d1 f3 ff ff       	jmp    80104e9b <alltraps>

80105aca <vector203>:
.globl vector203
vector203:
  pushl $0
80105aca:	6a 00                	push   $0x0
  pushl $203
80105acc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105ad1:	e9 c5 f3 ff ff       	jmp    80104e9b <alltraps>

80105ad6 <vector204>:
.globl vector204
vector204:
  pushl $0
80105ad6:	6a 00                	push   $0x0
  pushl $204
80105ad8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105add:	e9 b9 f3 ff ff       	jmp    80104e9b <alltraps>

80105ae2 <vector205>:
.globl vector205
vector205:
  pushl $0
80105ae2:	6a 00                	push   $0x0
  pushl $205
80105ae4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105ae9:	e9 ad f3 ff ff       	jmp    80104e9b <alltraps>

80105aee <vector206>:
.globl vector206
vector206:
  pushl $0
80105aee:	6a 00                	push   $0x0
  pushl $206
80105af0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105af5:	e9 a1 f3 ff ff       	jmp    80104e9b <alltraps>

80105afa <vector207>:
.globl vector207
vector207:
  pushl $0
80105afa:	6a 00                	push   $0x0
  pushl $207
80105afc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b01:	e9 95 f3 ff ff       	jmp    80104e9b <alltraps>

80105b06 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b06:	6a 00                	push   $0x0
  pushl $208
80105b08:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b0d:	e9 89 f3 ff ff       	jmp    80104e9b <alltraps>

80105b12 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b12:	6a 00                	push   $0x0
  pushl $209
80105b14:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b19:	e9 7d f3 ff ff       	jmp    80104e9b <alltraps>

80105b1e <vector210>:
.globl vector210
vector210:
  pushl $0
80105b1e:	6a 00                	push   $0x0
  pushl $210
80105b20:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b25:	e9 71 f3 ff ff       	jmp    80104e9b <alltraps>

80105b2a <vector211>:
.globl vector211
vector211:
  pushl $0
80105b2a:	6a 00                	push   $0x0
  pushl $211
80105b2c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b31:	e9 65 f3 ff ff       	jmp    80104e9b <alltraps>

80105b36 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b36:	6a 00                	push   $0x0
  pushl $212
80105b38:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b3d:	e9 59 f3 ff ff       	jmp    80104e9b <alltraps>

80105b42 <vector213>:
.globl vector213
vector213:
  pushl $0
80105b42:	6a 00                	push   $0x0
  pushl $213
80105b44:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b49:	e9 4d f3 ff ff       	jmp    80104e9b <alltraps>

80105b4e <vector214>:
.globl vector214
vector214:
  pushl $0
80105b4e:	6a 00                	push   $0x0
  pushl $214
80105b50:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b55:	e9 41 f3 ff ff       	jmp    80104e9b <alltraps>

80105b5a <vector215>:
.globl vector215
vector215:
  pushl $0
80105b5a:	6a 00                	push   $0x0
  pushl $215
80105b5c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105b61:	e9 35 f3 ff ff       	jmp    80104e9b <alltraps>

80105b66 <vector216>:
.globl vector216
vector216:
  pushl $0
80105b66:	6a 00                	push   $0x0
  pushl $216
80105b68:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105b6d:	e9 29 f3 ff ff       	jmp    80104e9b <alltraps>

80105b72 <vector217>:
.globl vector217
vector217:
  pushl $0
80105b72:	6a 00                	push   $0x0
  pushl $217
80105b74:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105b79:	e9 1d f3 ff ff       	jmp    80104e9b <alltraps>

80105b7e <vector218>:
.globl vector218
vector218:
  pushl $0
80105b7e:	6a 00                	push   $0x0
  pushl $218
80105b80:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105b85:	e9 11 f3 ff ff       	jmp    80104e9b <alltraps>

80105b8a <vector219>:
.globl vector219
vector219:
  pushl $0
80105b8a:	6a 00                	push   $0x0
  pushl $219
80105b8c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105b91:	e9 05 f3 ff ff       	jmp    80104e9b <alltraps>

80105b96 <vector220>:
.globl vector220
vector220:
  pushl $0
80105b96:	6a 00                	push   $0x0
  pushl $220
80105b98:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105b9d:	e9 f9 f2 ff ff       	jmp    80104e9b <alltraps>

80105ba2 <vector221>:
.globl vector221
vector221:
  pushl $0
80105ba2:	6a 00                	push   $0x0
  pushl $221
80105ba4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105ba9:	e9 ed f2 ff ff       	jmp    80104e9b <alltraps>

80105bae <vector222>:
.globl vector222
vector222:
  pushl $0
80105bae:	6a 00                	push   $0x0
  pushl $222
80105bb0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105bb5:	e9 e1 f2 ff ff       	jmp    80104e9b <alltraps>

80105bba <vector223>:
.globl vector223
vector223:
  pushl $0
80105bba:	6a 00                	push   $0x0
  pushl $223
80105bbc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105bc1:	e9 d5 f2 ff ff       	jmp    80104e9b <alltraps>

80105bc6 <vector224>:
.globl vector224
vector224:
  pushl $0
80105bc6:	6a 00                	push   $0x0
  pushl $224
80105bc8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105bcd:	e9 c9 f2 ff ff       	jmp    80104e9b <alltraps>

80105bd2 <vector225>:
.globl vector225
vector225:
  pushl $0
80105bd2:	6a 00                	push   $0x0
  pushl $225
80105bd4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105bd9:	e9 bd f2 ff ff       	jmp    80104e9b <alltraps>

80105bde <vector226>:
.globl vector226
vector226:
  pushl $0
80105bde:	6a 00                	push   $0x0
  pushl $226
80105be0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105be5:	e9 b1 f2 ff ff       	jmp    80104e9b <alltraps>

80105bea <vector227>:
.globl vector227
vector227:
  pushl $0
80105bea:	6a 00                	push   $0x0
  pushl $227
80105bec:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105bf1:	e9 a5 f2 ff ff       	jmp    80104e9b <alltraps>

80105bf6 <vector228>:
.globl vector228
vector228:
  pushl $0
80105bf6:	6a 00                	push   $0x0
  pushl $228
80105bf8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105bfd:	e9 99 f2 ff ff       	jmp    80104e9b <alltraps>

80105c02 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c02:	6a 00                	push   $0x0
  pushl $229
80105c04:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c09:	e9 8d f2 ff ff       	jmp    80104e9b <alltraps>

80105c0e <vector230>:
.globl vector230
vector230:
  pushl $0
80105c0e:	6a 00                	push   $0x0
  pushl $230
80105c10:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c15:	e9 81 f2 ff ff       	jmp    80104e9b <alltraps>

80105c1a <vector231>:
.globl vector231
vector231:
  pushl $0
80105c1a:	6a 00                	push   $0x0
  pushl $231
80105c1c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c21:	e9 75 f2 ff ff       	jmp    80104e9b <alltraps>

80105c26 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c26:	6a 00                	push   $0x0
  pushl $232
80105c28:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c2d:	e9 69 f2 ff ff       	jmp    80104e9b <alltraps>

80105c32 <vector233>:
.globl vector233
vector233:
  pushl $0
80105c32:	6a 00                	push   $0x0
  pushl $233
80105c34:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c39:	e9 5d f2 ff ff       	jmp    80104e9b <alltraps>

80105c3e <vector234>:
.globl vector234
vector234:
  pushl $0
80105c3e:	6a 00                	push   $0x0
  pushl $234
80105c40:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c45:	e9 51 f2 ff ff       	jmp    80104e9b <alltraps>

80105c4a <vector235>:
.globl vector235
vector235:
  pushl $0
80105c4a:	6a 00                	push   $0x0
  pushl $235
80105c4c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c51:	e9 45 f2 ff ff       	jmp    80104e9b <alltraps>

80105c56 <vector236>:
.globl vector236
vector236:
  pushl $0
80105c56:	6a 00                	push   $0x0
  pushl $236
80105c58:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105c5d:	e9 39 f2 ff ff       	jmp    80104e9b <alltraps>

80105c62 <vector237>:
.globl vector237
vector237:
  pushl $0
80105c62:	6a 00                	push   $0x0
  pushl $237
80105c64:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105c69:	e9 2d f2 ff ff       	jmp    80104e9b <alltraps>

80105c6e <vector238>:
.globl vector238
vector238:
  pushl $0
80105c6e:	6a 00                	push   $0x0
  pushl $238
80105c70:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105c75:	e9 21 f2 ff ff       	jmp    80104e9b <alltraps>

80105c7a <vector239>:
.globl vector239
vector239:
  pushl $0
80105c7a:	6a 00                	push   $0x0
  pushl $239
80105c7c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105c81:	e9 15 f2 ff ff       	jmp    80104e9b <alltraps>

80105c86 <vector240>:
.globl vector240
vector240:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $240
80105c88:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105c8d:	e9 09 f2 ff ff       	jmp    80104e9b <alltraps>

80105c92 <vector241>:
.globl vector241
vector241:
  pushl $0
80105c92:	6a 00                	push   $0x0
  pushl $241
80105c94:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105c99:	e9 fd f1 ff ff       	jmp    80104e9b <alltraps>

80105c9e <vector242>:
.globl vector242
vector242:
  pushl $0
80105c9e:	6a 00                	push   $0x0
  pushl $242
80105ca0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105ca5:	e9 f1 f1 ff ff       	jmp    80104e9b <alltraps>

80105caa <vector243>:
.globl vector243
vector243:
  pushl $0
80105caa:	6a 00                	push   $0x0
  pushl $243
80105cac:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cb1:	e9 e5 f1 ff ff       	jmp    80104e9b <alltraps>

80105cb6 <vector244>:
.globl vector244
vector244:
  pushl $0
80105cb6:	6a 00                	push   $0x0
  pushl $244
80105cb8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105cbd:	e9 d9 f1 ff ff       	jmp    80104e9b <alltraps>

80105cc2 <vector245>:
.globl vector245
vector245:
  pushl $0
80105cc2:	6a 00                	push   $0x0
  pushl $245
80105cc4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105cc9:	e9 cd f1 ff ff       	jmp    80104e9b <alltraps>

80105cce <vector246>:
.globl vector246
vector246:
  pushl $0
80105cce:	6a 00                	push   $0x0
  pushl $246
80105cd0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105cd5:	e9 c1 f1 ff ff       	jmp    80104e9b <alltraps>

80105cda <vector247>:
.globl vector247
vector247:
  pushl $0
80105cda:	6a 00                	push   $0x0
  pushl $247
80105cdc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105ce1:	e9 b5 f1 ff ff       	jmp    80104e9b <alltraps>

80105ce6 <vector248>:
.globl vector248
vector248:
  pushl $0
80105ce6:	6a 00                	push   $0x0
  pushl $248
80105ce8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105ced:	e9 a9 f1 ff ff       	jmp    80104e9b <alltraps>

80105cf2 <vector249>:
.globl vector249
vector249:
  pushl $0
80105cf2:	6a 00                	push   $0x0
  pushl $249
80105cf4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105cf9:	e9 9d f1 ff ff       	jmp    80104e9b <alltraps>

80105cfe <vector250>:
.globl vector250
vector250:
  pushl $0
80105cfe:	6a 00                	push   $0x0
  pushl $250
80105d00:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d05:	e9 91 f1 ff ff       	jmp    80104e9b <alltraps>

80105d0a <vector251>:
.globl vector251
vector251:
  pushl $0
80105d0a:	6a 00                	push   $0x0
  pushl $251
80105d0c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d11:	e9 85 f1 ff ff       	jmp    80104e9b <alltraps>

80105d16 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d16:	6a 00                	push   $0x0
  pushl $252
80105d18:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d1d:	e9 79 f1 ff ff       	jmp    80104e9b <alltraps>

80105d22 <vector253>:
.globl vector253
vector253:
  pushl $0
80105d22:	6a 00                	push   $0x0
  pushl $253
80105d24:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d29:	e9 6d f1 ff ff       	jmp    80104e9b <alltraps>

80105d2e <vector254>:
.globl vector254
vector254:
  pushl $0
80105d2e:	6a 00                	push   $0x0
  pushl $254
80105d30:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d35:	e9 61 f1 ff ff       	jmp    80104e9b <alltraps>

80105d3a <vector255>:
.globl vector255
vector255:
  pushl $0
80105d3a:	6a 00                	push   $0x0
  pushl $255
80105d3c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d41:	e9 55 f1 ff ff       	jmp    80104e9b <alltraps>

80105d46 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d46:	55                   	push   %ebp
80105d47:	89 e5                	mov    %esp,%ebp
80105d49:	57                   	push   %edi
80105d4a:	56                   	push   %esi
80105d4b:	53                   	push   %ebx
80105d4c:	83 ec 0c             	sub    $0xc,%esp
80105d4f:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d51:	c1 ea 16             	shr    $0x16,%edx
80105d54:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d57:	8b 1f                	mov    (%edi),%ebx
80105d59:	f6 c3 01             	test   $0x1,%bl
80105d5c:	74 37                	je     80105d95 <walkpgdir+0x4f>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105d5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
80105d64:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80105d6a:	77 1c                	ja     80105d88 <walkpgdir+0x42>
    return (char*)a + KERNBASE;
80105d6c:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105d72:	c1 ee 0c             	shr    $0xc,%esi
80105d75:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105d7b:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105d7e:	89 d8                	mov    %ebx,%eax
80105d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d83:	5b                   	pop    %ebx
80105d84:	5e                   	pop    %esi
80105d85:	5f                   	pop    %edi
80105d86:	5d                   	pop    %ebp
80105d87:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105d88:	83 ec 0c             	sub    $0xc,%esp
80105d8b:	68 98 6c 10 80       	push   $0x80106c98
80105d90:	e8 b3 a5 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105d95:	85 c9                	test   %ecx,%ecx
80105d97:	74 40                	je     80105dd9 <walkpgdir+0x93>
80105d99:	e8 31 c3 ff ff       	call   801020cf <kalloc>
80105d9e:	89 c3                	mov    %eax,%ebx
80105da0:	85 c0                	test   %eax,%eax
80105da2:	74 da                	je     80105d7e <walkpgdir+0x38>
    memset(pgtab, 0, PGSIZE);
80105da4:	83 ec 04             	sub    $0x4,%esp
80105da7:	68 00 10 00 00       	push   $0x1000
80105dac:	6a 00                	push   $0x0
80105dae:	50                   	push   %eax
80105daf:	e8 1a df ff ff       	call   80103cce <memset>
    if (a < (void*) KERNBASE)
80105db4:	83 c4 10             	add    $0x10,%esp
80105db7:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80105dbd:	76 0d                	jbe    80105dcc <walkpgdir+0x86>
    return (uint)a - KERNBASE;
80105dbf:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105dc5:	83 c8 07             	or     $0x7,%eax
80105dc8:	89 07                	mov    %eax,(%edi)
80105dca:	eb a6                	jmp    80105d72 <walkpgdir+0x2c>
        panic("V2P on address < KERNBASE "
80105dcc:	83 ec 0c             	sub    $0xc,%esp
80105dcf:	68 68 69 10 80       	push   $0x80106968
80105dd4:	e8 6f a5 ff ff       	call   80100348 <panic>
      return 0;
80105dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
80105dde:	eb 9e                	jmp    80105d7e <walkpgdir+0x38>

80105de0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105de0:	55                   	push   %ebp
80105de1:	89 e5                	mov    %esp,%ebp
80105de3:	57                   	push   %edi
80105de4:	56                   	push   %esi
80105de5:	53                   	push   %ebx
80105de6:	83 ec 1c             	sub    $0x1c,%esp
80105de9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105dec:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105def:	89 d3                	mov    %edx,%ebx
80105df1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105df7:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105dfb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e01:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e06:	89 da                	mov    %ebx,%edx
80105e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e0b:	e8 36 ff ff ff       	call   80105d46 <walkpgdir>
80105e10:	85 c0                	test   %eax,%eax
80105e12:	74 2e                	je     80105e42 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e14:	f6 00 01             	testb  $0x1,(%eax)
80105e17:	75 1c                	jne    80105e35 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e19:	89 f2                	mov    %esi,%edx
80105e1b:	0b 55 0c             	or     0xc(%ebp),%edx
80105e1e:	83 ca 01             	or     $0x1,%edx
80105e21:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e23:	39 fb                	cmp    %edi,%ebx
80105e25:	74 28                	je     80105e4f <mappages+0x6f>
      break;
    a += PGSIZE;
80105e27:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e2d:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e33:	eb cc                	jmp    80105e01 <mappages+0x21>
      panic("remap");
80105e35:	83 ec 0c             	sub    $0xc,%esp
80105e38:	68 a0 70 10 80       	push   $0x801070a0
80105e3d:	e8 06 a5 ff ff       	call   80100348 <panic>
      return -1;
80105e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e4a:	5b                   	pop    %ebx
80105e4b:	5e                   	pop    %esi
80105e4c:	5f                   	pop    %edi
80105e4d:	5d                   	pop    %ebp
80105e4e:	c3                   	ret    
  return 0;
80105e4f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e54:	eb f1                	jmp    80105e47 <mappages+0x67>

80105e56 <seginit>:
{
80105e56:	55                   	push   %ebp
80105e57:	89 e5                	mov    %esp,%ebp
80105e59:	53                   	push   %ebx
80105e5a:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e5d:	e8 da d3 ff ff       	call   8010323c <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e62:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e68:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
80105e6f:	ff ff 
80105e71:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80105e78:	00 00 
80105e7a:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
80105e81:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
80105e88:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e8b:	83 c9 1a             	or     $0x1a,%ecx
80105e8e:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e91:	83 c9 80             	or     $0xffffff80,%ecx
80105e94:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
80105e9a:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
80105ea1:	83 c9 0f             	or     $0xf,%ecx
80105ea4:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ea7:	83 c9 c0             	or     $0xffffffc0,%ecx
80105eaa:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
80105eb0:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105eb7:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
80105ebe:	ff ff 
80105ec0:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
80105ec7:	00 00 
80105ec9:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80105ed0:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
80105ed7:	83 e1 f0             	and    $0xfffffff0,%ecx
80105eda:	83 c9 12             	or     $0x12,%ecx
80105edd:	83 e1 9f             	and    $0xffffff9f,%ecx
80105ee0:	83 c9 80             	or     $0xffffff80,%ecx
80105ee3:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80105ee9:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80105ef0:	83 c9 0f             	or     $0xf,%ecx
80105ef3:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ef6:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ef9:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
80105eff:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f06:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80105f0d:	ff ff 
80105f0f:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
80105f16:	00 00 
80105f18:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
80105f1f:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
80105f26:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
80105f2d:	83 c9 0f             	or     $0xf,%ecx
80105f30:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f33:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f36:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
80105f3c:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f43:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
80105f4a:	ff ff 
80105f4c:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
80105f53:	00 00 
80105f55:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
80105f5c:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
80105f63:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
80105f6a:	83 c9 0f             	or     $0xf,%ecx
80105f6d:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f70:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f73:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
80105f79:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105f80:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
80105f85:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105f8b:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105f8f:	c1 e8 10             	shr    $0x10,%eax
80105f92:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105f96:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105f99:	0f 01 10             	lgdtl  (%eax)
}
80105f9c:	83 c4 14             	add    $0x14,%esp
80105f9f:	5b                   	pop    %ebx
80105fa0:	5d                   	pop    %ebp
80105fa1:	c3                   	ret    

80105fa2 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105fa2:	a1 a4 56 11 80       	mov    0x801156a4,%eax
    if (a < (void*) KERNBASE)
80105fa7:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80105fac:	76 09                	jbe    80105fb7 <switchkvm+0x15>
    return (uint)a - KERNBASE;
80105fae:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fb3:	0f 22 d8             	mov    %eax,%cr3
80105fb6:	c3                   	ret    
{
80105fb7:	55                   	push   %ebp
80105fb8:	89 e5                	mov    %esp,%ebp
80105fba:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
80105fbd:	68 68 69 10 80       	push   $0x80106968
80105fc2:	e8 81 a3 ff ff       	call   80100348 <panic>

80105fc7 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fc7:	55                   	push   %ebp
80105fc8:	89 e5                	mov    %esp,%ebp
80105fca:	57                   	push   %edi
80105fcb:	56                   	push   %esi
80105fcc:	53                   	push   %ebx
80105fcd:	83 ec 1c             	sub    $0x1c,%esp
80105fd0:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105fd3:	85 f6                	test   %esi,%esi
80105fd5:	0f 84 e4 00 00 00    	je     801060bf <switchuvm+0xf8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105fdb:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105fdf:	0f 84 e7 00 00 00    	je     801060cc <switchuvm+0x105>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105fe5:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105fe9:	0f 84 ea 00 00 00    	je     801060d9 <switchuvm+0x112>
    panic("switchuvm: no pgdir");

  pushcli();
80105fef:	e8 51 db ff ff       	call   80103b45 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105ff4:	e8 e7 d1 ff ff       	call   801031e0 <mycpu>
80105ff9:	89 c3                	mov    %eax,%ebx
80105ffb:	e8 e0 d1 ff ff       	call   801031e0 <mycpu>
80106000:	8d 78 08             	lea    0x8(%eax),%edi
80106003:	e8 d8 d1 ff ff       	call   801031e0 <mycpu>
80106008:	83 c0 08             	add    $0x8,%eax
8010600b:	c1 e8 10             	shr    $0x10,%eax
8010600e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106011:	e8 ca d1 ff ff       	call   801031e0 <mycpu>
80106016:	83 c0 08             	add    $0x8,%eax
80106019:	c1 e8 18             	shr    $0x18,%eax
8010601c:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106023:	67 00 
80106025:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010602c:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106030:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106036:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010603d:	83 e2 f0             	and    $0xfffffff0,%edx
80106040:	83 ca 19             	or     $0x19,%edx
80106043:	83 e2 9f             	and    $0xffffff9f,%edx
80106046:	83 ca 80             	or     $0xffffff80,%edx
80106049:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010604f:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106056:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010605c:	e8 7f d1 ff ff       	call   801031e0 <mycpu>
80106061:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106068:	83 e2 ef             	and    $0xffffffef,%edx
8010606b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106071:	e8 6a d1 ff ff       	call   801031e0 <mycpu>
80106076:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010607c:	8b 5e 08             	mov    0x8(%esi),%ebx
8010607f:	e8 5c d1 ff ff       	call   801031e0 <mycpu>
80106084:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010608a:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010608d:	e8 4e d1 ff ff       	call   801031e0 <mycpu>
80106092:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106098:	b8 28 00 00 00       	mov    $0x28,%eax
8010609d:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801060a0:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
801060a3:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801060a8:	76 3c                	jbe    801060e6 <switchuvm+0x11f>
    return (uint)a - KERNBASE;
801060aa:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060af:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060b2:	e8 cb da ff ff       	call   80103b82 <popcli>
}
801060b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060ba:	5b                   	pop    %ebx
801060bb:	5e                   	pop    %esi
801060bc:	5f                   	pop    %edi
801060bd:	5d                   	pop    %ebp
801060be:	c3                   	ret    
    panic("switchuvm: no process");
801060bf:	83 ec 0c             	sub    $0xc,%esp
801060c2:	68 a6 70 10 80       	push   $0x801070a6
801060c7:	e8 7c a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801060cc:	83 ec 0c             	sub    $0xc,%esp
801060cf:	68 bc 70 10 80       	push   $0x801070bc
801060d4:	e8 6f a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060d9:	83 ec 0c             	sub    $0xc,%esp
801060dc:	68 d1 70 10 80       	push   $0x801070d1
801060e1:	e8 62 a2 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801060e6:	83 ec 0c             	sub    $0xc,%esp
801060e9:	68 68 69 10 80       	push   $0x80106968
801060ee:	e8 55 a2 ff ff       	call   80100348 <panic>

801060f3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801060f3:	55                   	push   %ebp
801060f4:	89 e5                	mov    %esp,%ebp
801060f6:	56                   	push   %esi
801060f7:	53                   	push   %ebx
801060f8:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801060fb:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106101:	77 57                	ja     8010615a <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
80106103:	e8 c7 bf ff ff       	call   801020cf <kalloc>
80106108:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010610a:	83 ec 04             	sub    $0x4,%esp
8010610d:	68 00 10 00 00       	push   $0x1000
80106112:	6a 00                	push   $0x0
80106114:	50                   	push   %eax
80106115:	e8 b4 db ff ff       	call   80103cce <memset>
    if (a < (void*) KERNBASE)
8010611a:	83 c4 10             	add    $0x10,%esp
8010611d:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106123:	76 42                	jbe    80106167 <inituvm+0x74>
    return (uint)a - KERNBASE;
80106125:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010612b:	83 ec 08             	sub    $0x8,%esp
8010612e:	6a 06                	push   $0x6
80106130:	50                   	push   %eax
80106131:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106136:	ba 00 00 00 00       	mov    $0x0,%edx
8010613b:	8b 45 08             	mov    0x8(%ebp),%eax
8010613e:	e8 9d fc ff ff       	call   80105de0 <mappages>
  memmove(mem, init, sz);
80106143:	83 c4 0c             	add    $0xc,%esp
80106146:	56                   	push   %esi
80106147:	ff 75 0c             	pushl  0xc(%ebp)
8010614a:	53                   	push   %ebx
8010614b:	e8 f9 db ff ff       	call   80103d49 <memmove>
}
80106150:	83 c4 10             	add    $0x10,%esp
80106153:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106156:	5b                   	pop    %ebx
80106157:	5e                   	pop    %esi
80106158:	5d                   	pop    %ebp
80106159:	c3                   	ret    
    panic("inituvm: more than a page");
8010615a:	83 ec 0c             	sub    $0xc,%esp
8010615d:	68 e5 70 10 80       	push   $0x801070e5
80106162:	e8 e1 a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106167:	83 ec 0c             	sub    $0xc,%esp
8010616a:	68 68 69 10 80       	push   $0x80106968
8010616f:	e8 d4 a1 ff ff       	call   80100348 <panic>

80106174 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106174:	55                   	push   %ebp
80106175:	89 e5                	mov    %esp,%ebp
80106177:	57                   	push   %edi
80106178:	56                   	push   %esi
80106179:	53                   	push   %ebx
8010617a:	83 ec 0c             	sub    $0xc,%esp
8010617d:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106180:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106187:	75 07                	jne    80106190 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106189:	bb 00 00 00 00       	mov    $0x0,%ebx
8010618e:	eb 43                	jmp    801061d3 <loaduvm+0x5f>
    panic("loaduvm: addr must be page aligned");
80106190:	83 ec 0c             	sub    $0xc,%esp
80106193:	68 a0 71 10 80       	push   $0x801071a0
80106198:	e8 ab a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010619d:	83 ec 0c             	sub    $0xc,%esp
801061a0:	68 ff 70 10 80       	push   $0x801070ff
801061a5:	e8 9e a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801061aa:	89 da                	mov    %ebx,%edx
801061ac:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
801061af:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801061b4:	77 51                	ja     80106207 <loaduvm+0x93>
    return (char*)a + KERNBASE;
801061b6:	05 00 00 00 80       	add    $0x80000000,%eax
801061bb:	56                   	push   %esi
801061bc:	52                   	push   %edx
801061bd:	50                   	push   %eax
801061be:	ff 75 10             	pushl  0x10(%ebp)
801061c1:	e8 9b b5 ff ff       	call   80101761 <readi>
801061c6:	83 c4 10             	add    $0x10,%esp
801061c9:	39 f0                	cmp    %esi,%eax
801061cb:	75 54                	jne    80106221 <loaduvm+0xad>
  for(i = 0; i < sz; i += PGSIZE){
801061cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061d3:	39 fb                	cmp    %edi,%ebx
801061d5:	73 3d                	jae    80106214 <loaduvm+0xa0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061d7:	89 da                	mov    %ebx,%edx
801061d9:	03 55 0c             	add    0xc(%ebp),%edx
801061dc:	b9 00 00 00 00       	mov    $0x0,%ecx
801061e1:	8b 45 08             	mov    0x8(%ebp),%eax
801061e4:	e8 5d fb ff ff       	call   80105d46 <walkpgdir>
801061e9:	85 c0                	test   %eax,%eax
801061eb:	74 b0                	je     8010619d <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061ed:	8b 00                	mov    (%eax),%eax
801061ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061f4:	89 fe                	mov    %edi,%esi
801061f6:	29 de                	sub    %ebx,%esi
801061f8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061fe:	76 aa                	jbe    801061aa <loaduvm+0x36>
      n = PGSIZE;
80106200:	be 00 10 00 00       	mov    $0x1000,%esi
80106205:	eb a3                	jmp    801061aa <loaduvm+0x36>
        panic("P2V on address > KERNBASE");
80106207:	83 ec 0c             	sub    $0xc,%esp
8010620a:	68 98 6c 10 80       	push   $0x80106c98
8010620f:	e8 34 a1 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
80106214:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106219:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010621c:	5b                   	pop    %ebx
8010621d:	5e                   	pop    %esi
8010621e:	5f                   	pop    %edi
8010621f:	5d                   	pop    %ebp
80106220:	c3                   	ret    
      return -1;
80106221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106226:	eb f1                	jmp    80106219 <loaduvm+0xa5>

80106228 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106228:	55                   	push   %ebp
80106229:	89 e5                	mov    %esp,%ebp
8010622b:	57                   	push   %edi
8010622c:	56                   	push   %esi
8010622d:	53                   	push   %ebx
8010622e:	83 ec 0c             	sub    $0xc,%esp
80106231:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106234:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106237:	73 11                	jae    8010624a <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106239:	8b 45 10             	mov    0x10(%ebp),%eax
8010623c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106242:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106248:	eb 19                	jmp    80106263 <deallocuvm+0x3b>
    return oldsz;
8010624a:	89 f8                	mov    %edi,%eax
8010624c:	eb 78                	jmp    801062c6 <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010624e:	c1 eb 16             	shr    $0x16,%ebx
80106251:	83 c3 01             	add    $0x1,%ebx
80106254:	c1 e3 16             	shl    $0x16,%ebx
80106257:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010625d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106263:	39 fb                	cmp    %edi,%ebx
80106265:	73 5c                	jae    801062c3 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106267:	b9 00 00 00 00       	mov    $0x0,%ecx
8010626c:	89 da                	mov    %ebx,%edx
8010626e:	8b 45 08             	mov    0x8(%ebp),%eax
80106271:	e8 d0 fa ff ff       	call   80105d46 <walkpgdir>
80106276:	89 c6                	mov    %eax,%esi
    if(!pte)
80106278:	85 c0                	test   %eax,%eax
8010627a:	74 d2                	je     8010624e <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010627c:	8b 00                	mov    (%eax),%eax
8010627e:	a8 01                	test   $0x1,%al
80106280:	74 db                	je     8010625d <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106282:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106287:	74 20                	je     801062a9 <deallocuvm+0x81>
    if (a > KERNBASE)
80106289:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010628e:	77 26                	ja     801062b6 <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
80106290:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106295:	83 ec 0c             	sub    $0xc,%esp
80106298:	50                   	push   %eax
80106299:	e8 f4 bc ff ff       	call   80101f92 <kfree>
      *pte = 0;
8010629e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801062a4:	83 c4 10             	add    $0x10,%esp
801062a7:	eb b4                	jmp    8010625d <deallocuvm+0x35>
        panic("kfree");
801062a9:	83 ec 0c             	sub    $0xc,%esp
801062ac:	68 f6 69 10 80       	push   $0x801069f6
801062b1:	e8 92 a0 ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801062b6:	83 ec 0c             	sub    $0xc,%esp
801062b9:	68 98 6c 10 80       	push   $0x80106c98
801062be:	e8 85 a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801062c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801062c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c9:	5b                   	pop    %ebx
801062ca:	5e                   	pop    %esi
801062cb:	5f                   	pop    %edi
801062cc:	5d                   	pop    %ebp
801062cd:	c3                   	ret    

801062ce <allocuvm>:
{
801062ce:	55                   	push   %ebp
801062cf:	89 e5                	mov    %esp,%ebp
801062d1:	57                   	push   %edi
801062d2:	56                   	push   %esi
801062d3:	53                   	push   %ebx
801062d4:	83 ec 1c             	sub    $0x1c,%esp
801062d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801062da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801062dd:	85 ff                	test   %edi,%edi
801062df:	0f 88 d9 00 00 00    	js     801063be <allocuvm+0xf0>
  if(newsz < oldsz)
801062e5:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062e8:	72 67                	jb     80106351 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
801062ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801062ed:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801062f3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801062f9:	39 fe                	cmp    %edi,%esi
801062fb:	0f 83 c4 00 00 00    	jae    801063c5 <allocuvm+0xf7>
    mem = kalloc();
80106301:	e8 c9 bd ff ff       	call   801020cf <kalloc>
80106306:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106308:	85 c0                	test   %eax,%eax
8010630a:	74 4d                	je     80106359 <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
8010630c:	83 ec 04             	sub    $0x4,%esp
8010630f:	68 00 10 00 00       	push   $0x1000
80106314:	6a 00                	push   $0x0
80106316:	50                   	push   %eax
80106317:	e8 b2 d9 ff ff       	call   80103cce <memset>
    if (a < (void*) KERNBASE)
8010631c:	83 c4 10             	add    $0x10,%esp
8010631f:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106325:	76 5a                	jbe    80106381 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106327:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010632d:	83 ec 08             	sub    $0x8,%esp
80106330:	6a 06                	push   $0x6
80106332:	50                   	push   %eax
80106333:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106338:	89 f2                	mov    %esi,%edx
8010633a:	8b 45 08             	mov    0x8(%ebp),%eax
8010633d:	e8 9e fa ff ff       	call   80105de0 <mappages>
80106342:	83 c4 10             	add    $0x10,%esp
80106345:	85 c0                	test   %eax,%eax
80106347:	78 45                	js     8010638e <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80106349:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010634f:	eb a8                	jmp    801062f9 <allocuvm+0x2b>
    return oldsz;
80106351:	8b 45 0c             	mov    0xc(%ebp),%eax
80106354:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106357:	eb 6c                	jmp    801063c5 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
80106359:	83 ec 0c             	sub    $0xc,%esp
8010635c:	68 1d 71 10 80       	push   $0x8010711d
80106361:	e8 a5 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106366:	83 c4 0c             	add    $0xc,%esp
80106369:	ff 75 0c             	pushl  0xc(%ebp)
8010636c:	57                   	push   %edi
8010636d:	ff 75 08             	pushl  0x8(%ebp)
80106370:	e8 b3 fe ff ff       	call   80106228 <deallocuvm>
      return 0;
80106375:	83 c4 10             	add    $0x10,%esp
80106378:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010637f:	eb 44                	jmp    801063c5 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
80106381:	83 ec 0c             	sub    $0xc,%esp
80106384:	68 68 69 10 80       	push   $0x80106968
80106389:	e8 ba 9f ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
8010638e:	83 ec 0c             	sub    $0xc,%esp
80106391:	68 35 71 10 80       	push   $0x80107135
80106396:	e8 70 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010639b:	83 c4 0c             	add    $0xc,%esp
8010639e:	ff 75 0c             	pushl  0xc(%ebp)
801063a1:	57                   	push   %edi
801063a2:	ff 75 08             	pushl  0x8(%ebp)
801063a5:	e8 7e fe ff ff       	call   80106228 <deallocuvm>
      kfree(mem);
801063aa:	89 1c 24             	mov    %ebx,(%esp)
801063ad:	e8 e0 bb ff ff       	call   80101f92 <kfree>
      return 0;
801063b2:	83 c4 10             	add    $0x10,%esp
801063b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801063bc:	eb 07                	jmp    801063c5 <allocuvm+0xf7>
    return 0;
801063be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801063c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063cb:	5b                   	pop    %ebx
801063cc:	5e                   	pop    %esi
801063cd:	5f                   	pop    %edi
801063ce:	5d                   	pop    %ebp
801063cf:	c3                   	ret    

801063d0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801063d0:	55                   	push   %ebp
801063d1:	89 e5                	mov    %esp,%ebp
801063d3:	56                   	push   %esi
801063d4:	53                   	push   %ebx
801063d5:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801063d8:	85 f6                	test   %esi,%esi
801063da:	74 1a                	je     801063f6 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801063dc:	83 ec 04             	sub    $0x4,%esp
801063df:	6a 00                	push   $0x0
801063e1:	68 00 00 00 80       	push   $0x80000000
801063e6:	56                   	push   %esi
801063e7:	e8 3c fe ff ff       	call   80106228 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801063ec:	83 c4 10             	add    $0x10,%esp
801063ef:	bb 00 00 00 00       	mov    $0x0,%ebx
801063f4:	eb 1d                	jmp    80106413 <freevm+0x43>
    panic("freevm: no pgdir");
801063f6:	83 ec 0c             	sub    $0xc,%esp
801063f9:	68 51 71 10 80       	push   $0x80107151
801063fe:	e8 45 9f ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106403:	83 ec 0c             	sub    $0xc,%esp
80106406:	68 98 6c 10 80       	push   $0x80106c98
8010640b:	e8 38 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106410:	83 c3 01             	add    $0x1,%ebx
80106413:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106419:	77 26                	ja     80106441 <freevm+0x71>
    if(pgdir[i] & PTE_P){
8010641b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
8010641e:	a8 01                	test   $0x1,%al
80106420:	74 ee                	je     80106410 <freevm+0x40>
80106422:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106427:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010642c:	77 d5                	ja     80106403 <freevm+0x33>
    return (char*)a + KERNBASE;
8010642e:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106433:	83 ec 0c             	sub    $0xc,%esp
80106436:	50                   	push   %eax
80106437:	e8 56 bb ff ff       	call   80101f92 <kfree>
8010643c:	83 c4 10             	add    $0x10,%esp
8010643f:	eb cf                	jmp    80106410 <freevm+0x40>
    }
  }
  kfree((char*)pgdir);
80106441:	83 ec 0c             	sub    $0xc,%esp
80106444:	56                   	push   %esi
80106445:	e8 48 bb ff ff       	call   80101f92 <kfree>
}
8010644a:	83 c4 10             	add    $0x10,%esp
8010644d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106450:	5b                   	pop    %ebx
80106451:	5e                   	pop    %esi
80106452:	5d                   	pop    %ebp
80106453:	c3                   	ret    

80106454 <setupkvm>:
{
80106454:	55                   	push   %ebp
80106455:	89 e5                	mov    %esp,%ebp
80106457:	56                   	push   %esi
80106458:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106459:	e8 71 bc ff ff       	call   801020cf <kalloc>
8010645e:	89 c6                	mov    %eax,%esi
80106460:	85 c0                	test   %eax,%eax
80106462:	74 55                	je     801064b9 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106464:	83 ec 04             	sub    $0x4,%esp
80106467:	68 00 10 00 00       	push   $0x1000
8010646c:	6a 00                	push   $0x0
8010646e:	50                   	push   %eax
8010646f:	e8 5a d8 ff ff       	call   80103cce <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106474:	83 c4 10             	add    $0x10,%esp
80106477:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010647c:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106482:	73 35                	jae    801064b9 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106484:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106487:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010648a:	29 c1                	sub    %eax,%ecx
8010648c:	83 ec 08             	sub    $0x8,%esp
8010648f:	ff 73 0c             	pushl  0xc(%ebx)
80106492:	50                   	push   %eax
80106493:	8b 13                	mov    (%ebx),%edx
80106495:	89 f0                	mov    %esi,%eax
80106497:	e8 44 f9 ff ff       	call   80105de0 <mappages>
8010649c:	83 c4 10             	add    $0x10,%esp
8010649f:	85 c0                	test   %eax,%eax
801064a1:	78 05                	js     801064a8 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801064a3:	83 c3 10             	add    $0x10,%ebx
801064a6:	eb d4                	jmp    8010647c <setupkvm+0x28>
      freevm(pgdir);
801064a8:	83 ec 0c             	sub    $0xc,%esp
801064ab:	56                   	push   %esi
801064ac:	e8 1f ff ff ff       	call   801063d0 <freevm>
      return 0;
801064b1:	83 c4 10             	add    $0x10,%esp
801064b4:	be 00 00 00 00       	mov    $0x0,%esi
}
801064b9:	89 f0                	mov    %esi,%eax
801064bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064be:	5b                   	pop    %ebx
801064bf:	5e                   	pop    %esi
801064c0:	5d                   	pop    %ebp
801064c1:	c3                   	ret    

801064c2 <kvmalloc>:
{
801064c2:	55                   	push   %ebp
801064c3:	89 e5                	mov    %esp,%ebp
801064c5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801064c8:	e8 87 ff ff ff       	call   80106454 <setupkvm>
801064cd:	a3 a4 56 11 80       	mov    %eax,0x801156a4
  switchkvm();
801064d2:	e8 cb fa ff ff       	call   80105fa2 <switchkvm>
}
801064d7:	c9                   	leave  
801064d8:	c3                   	ret    

801064d9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801064d9:	55                   	push   %ebp
801064da:	89 e5                	mov    %esp,%ebp
801064dc:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801064df:	b9 00 00 00 00       	mov    $0x0,%ecx
801064e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801064e7:	8b 45 08             	mov    0x8(%ebp),%eax
801064ea:	e8 57 f8 ff ff       	call   80105d46 <walkpgdir>
  if(pte == 0)
801064ef:	85 c0                	test   %eax,%eax
801064f1:	74 05                	je     801064f8 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801064f3:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801064f6:	c9                   	leave  
801064f7:	c3                   	ret    
    panic("clearpteu");
801064f8:	83 ec 0c             	sub    $0xc,%esp
801064fb:	68 62 71 10 80       	push   $0x80107162
80106500:	e8 43 9e ff ff       	call   80100348 <panic>

80106505 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106505:	55                   	push   %ebp
80106506:	89 e5                	mov    %esp,%ebp
80106508:	57                   	push   %edi
80106509:	56                   	push   %esi
8010650a:	53                   	push   %ebx
8010650b:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010650e:	e8 41 ff ff ff       	call   80106454 <setupkvm>
80106513:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106516:	85 c0                	test   %eax,%eax
80106518:	0f 84 f2 00 00 00    	je     80106610 <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010651e:	bb 00 00 00 00       	mov    $0x0,%ebx
80106523:	eb 3a                	jmp    8010655f <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106525:	83 ec 0c             	sub    $0xc,%esp
80106528:	68 6c 71 10 80       	push   $0x8010716c
8010652d:	e8 16 9e ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106532:	83 ec 0c             	sub    $0xc,%esp
80106535:	68 86 71 10 80       	push   $0x80107186
8010653a:	e8 09 9e ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
8010653f:	83 ec 0c             	sub    $0xc,%esp
80106542:	68 98 6c 10 80       	push   $0x80106c98
80106547:	e8 fc 9d ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010654c:	83 ec 0c             	sub    $0xc,%esp
8010654f:	68 68 69 10 80       	push   $0x80106968
80106554:	e8 ef 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106559:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010655f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
80106562:	0f 83 a8 00 00 00    	jae    80106610 <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106568:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010656b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106570:	89 da                	mov    %ebx,%edx
80106572:	8b 45 08             	mov    0x8(%ebp),%eax
80106575:	e8 cc f7 ff ff       	call   80105d46 <walkpgdir>
8010657a:	85 c0                	test   %eax,%eax
8010657c:	74 a7                	je     80106525 <copyuvm+0x20>
    if(!(*pte & PTE_P))
8010657e:	8b 00                	mov    (%eax),%eax
80106580:	a8 01                	test   $0x1,%al
80106582:	74 ae                	je     80106532 <copyuvm+0x2d>
80106584:	89 c6                	mov    %eax,%esi
80106586:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
8010658c:	25 ff 0f 00 00       	and    $0xfff,%eax
80106591:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106594:	e8 36 bb ff ff       	call   801020cf <kalloc>
80106599:	89 c7                	mov    %eax,%edi
8010659b:	85 c0                	test   %eax,%eax
8010659d:	74 5c                	je     801065fb <copyuvm+0xf6>
    if (a > KERNBASE)
8010659f:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801065a5:	77 98                	ja     8010653f <copyuvm+0x3a>
    return (char*)a + KERNBASE;
801065a7:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801065ad:	83 ec 04             	sub    $0x4,%esp
801065b0:	68 00 10 00 00       	push   $0x1000
801065b5:	56                   	push   %esi
801065b6:	50                   	push   %eax
801065b7:	e8 8d d7 ff ff       	call   80103d49 <memmove>
    if (a < (void*) KERNBASE)
801065bc:	83 c4 10             	add    $0x10,%esp
801065bf:	81 ff ff ff ff 7f    	cmp    $0x7fffffff,%edi
801065c5:	76 85                	jbe    8010654c <copyuvm+0x47>
    return (uint)a - KERNBASE;
801065c7:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801065cd:	83 ec 08             	sub    $0x8,%esp
801065d0:	ff 75 e0             	pushl  -0x20(%ebp)
801065d3:	50                   	push   %eax
801065d4:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801065dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065df:	e8 fc f7 ff ff       	call   80105de0 <mappages>
801065e4:	83 c4 10             	add    $0x10,%esp
801065e7:	85 c0                	test   %eax,%eax
801065e9:	0f 89 6a ff ff ff    	jns    80106559 <copyuvm+0x54>
      kfree(mem);
801065ef:	83 ec 0c             	sub    $0xc,%esp
801065f2:	57                   	push   %edi
801065f3:	e8 9a b9 ff ff       	call   80101f92 <kfree>
      goto bad;
801065f8:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
801065fb:	83 ec 0c             	sub    $0xc,%esp
801065fe:	ff 75 dc             	pushl  -0x24(%ebp)
80106601:	e8 ca fd ff ff       	call   801063d0 <freevm>
  return 0;
80106606:	83 c4 10             	add    $0x10,%esp
80106609:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106610:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106613:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106616:	5b                   	pop    %ebx
80106617:	5e                   	pop    %esi
80106618:	5f                   	pop    %edi
80106619:	5d                   	pop    %ebp
8010661a:	c3                   	ret    

8010661b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010661b:	55                   	push   %ebp
8010661c:	89 e5                	mov    %esp,%ebp
8010661e:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106621:	b9 00 00 00 00       	mov    $0x0,%ecx
80106626:	8b 55 0c             	mov    0xc(%ebp),%edx
80106629:	8b 45 08             	mov    0x8(%ebp),%eax
8010662c:	e8 15 f7 ff ff       	call   80105d46 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106631:	8b 00                	mov    (%eax),%eax
80106633:	a8 01                	test   $0x1,%al
80106635:	74 24                	je     8010665b <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
80106637:	a8 04                	test   $0x4,%al
80106639:	74 27                	je     80106662 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
8010663b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106640:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106645:	77 07                	ja     8010664e <uva2ka+0x33>
    return (char*)a + KERNBASE;
80106647:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
8010664c:	c9                   	leave  
8010664d:	c3                   	ret    
        panic("P2V on address > KERNBASE");
8010664e:	83 ec 0c             	sub    $0xc,%esp
80106651:	68 98 6c 10 80       	push   $0x80106c98
80106656:	e8 ed 9c ff ff       	call   80100348 <panic>
    return 0;
8010665b:	b8 00 00 00 00       	mov    $0x0,%eax
80106660:	eb ea                	jmp    8010664c <uva2ka+0x31>
    return 0;
80106662:	b8 00 00 00 00       	mov    $0x0,%eax
80106667:	eb e3                	jmp    8010664c <uva2ka+0x31>

80106669 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106669:	55                   	push   %ebp
8010666a:	89 e5                	mov    %esp,%ebp
8010666c:	57                   	push   %edi
8010666d:	56                   	push   %esi
8010666e:	53                   	push   %ebx
8010666f:	83 ec 0c             	sub    $0xc,%esp
80106672:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106675:	eb 25                	jmp    8010669c <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106677:	8b 55 0c             	mov    0xc(%ebp),%edx
8010667a:	29 f2                	sub    %esi,%edx
8010667c:	01 d0                	add    %edx,%eax
8010667e:	83 ec 04             	sub    $0x4,%esp
80106681:	53                   	push   %ebx
80106682:	ff 75 10             	pushl  0x10(%ebp)
80106685:	50                   	push   %eax
80106686:	e8 be d6 ff ff       	call   80103d49 <memmove>
    len -= n;
8010668b:	29 df                	sub    %ebx,%edi
    buf += n;
8010668d:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106690:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106696:	89 45 0c             	mov    %eax,0xc(%ebp)
80106699:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010669c:	85 ff                	test   %edi,%edi
8010669e:	74 2f                	je     801066cf <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801066a0:	8b 75 0c             	mov    0xc(%ebp),%esi
801066a3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801066a9:	83 ec 08             	sub    $0x8,%esp
801066ac:	56                   	push   %esi
801066ad:	ff 75 08             	pushl  0x8(%ebp)
801066b0:	e8 66 ff ff ff       	call   8010661b <uva2ka>
    if(pa0 == 0)
801066b5:	83 c4 10             	add    $0x10,%esp
801066b8:	85 c0                	test   %eax,%eax
801066ba:	74 20                	je     801066dc <copyout+0x73>
    n = PGSIZE - (va - va0);
801066bc:	89 f3                	mov    %esi,%ebx
801066be:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801066c1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801066c7:	39 df                	cmp    %ebx,%edi
801066c9:	73 ac                	jae    80106677 <copyout+0xe>
      n = len;
801066cb:	89 fb                	mov    %edi,%ebx
801066cd:	eb a8                	jmp    80106677 <copyout+0xe>
  }
  return 0;
801066cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066d7:	5b                   	pop    %ebx
801066d8:	5e                   	pop    %esi
801066d9:	5f                   	pop    %edi
801066da:	5d                   	pop    %ebp
801066db:	c3                   	ret    
      return -1;
801066dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e1:	eb f1                	jmp    801066d4 <copyout+0x6b>
