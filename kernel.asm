
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
80100046:	e8 3f 3c 00 00       	call   80103c8a <acquire>

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
8010007c:	e8 6e 3c 00 00       	call   80103cef <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 ea 39 00 00       	call   80103a76 <acquiresleep>
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
801000ca:	e8 20 3c 00 00       	call   80103cef <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 9c 39 00 00       	call   80103a76 <acquiresleep>
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
801000ea:	68 e0 66 10 80       	push   $0x801066e0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 f1 66 10 80       	push   $0x801066f1
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 44 3a 00 00       	call   80103b4e <initlock>
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
8010013a:	68 f8 66 10 80       	push   $0x801066f8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 fb 38 00 00       	call   80103a43 <initsleeplock>
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
801001a8:	e8 53 39 00 00       	call   80103b00 <holdingsleep>
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
801001cb:	68 ff 66 10 80       	push   $0x801066ff
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
801001e4:	e8 17 39 00 00       	call   80103b00 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 cc 38 00 00       	call   80103ac5 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 85 3a 00 00       	call   80103c8a <acquire>
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
8010024c:	e8 9e 3a 00 00       	call   80103cef <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 06 67 10 80       	push   $0x80106706
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
8010028a:	e8 fb 39 00 00       	call   80103c8a <acquire>
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
801002bf:	e8 52 34 00 00       	call   80103716 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 19 3a 00 00       	call   80103cef <release>
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
80100331:	e8 b9 39 00 00       	call   80103cef <release>
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
80100363:	68 0d 67 10 80       	push   $0x8010670d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 2f 71 10 80 	movl   $0x8010712f,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 d5 37 00 00       	call   80103b69 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 21 67 10 80       	push   $0x80106721
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
8010049e:	68 25 67 10 80       	push   $0x80106725
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 f2 38 00 00       	call   80103db1 <memmove>
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
801004d9:	e8 58 38 00 00       	call   80103d36 <memset>
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
80100506:	e8 c6 4c 00 00       	call   801051d1 <uartputc>
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
8010051f:	e8 ad 4c 00 00       	call   801051d1 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 a1 4c 00 00       	call   801051d1 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 95 4c 00 00       	call   801051d1 <uartputc>
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
80100576:	0f b6 92 50 67 10 80 	movzbl -0x7fef98b0(%edx),%edx
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
801005ca:	e8 bb 36 00 00       	call   80103c8a <acquire>
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
801005f1:	e8 f9 36 00 00       	call   80103cef <release>
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
80100638:	e8 4d 36 00 00       	call   80103c8a <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 3f 67 10 80       	push   $0x8010673f
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
801006ee:	be 38 67 10 80       	mov    $0x80106738,%esi
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
80100734:	e8 b6 35 00 00       	call   80103cef <release>
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
8010074f:	e8 36 35 00 00       	call   80103c8a <acquire>
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
801007de:	e8 9b 30 00 00       	call   8010387e <wakeup>
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
80100873:	e8 77 34 00 00       	call   80103cef <release>
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
80100887:	e8 91 30 00 00       	call   8010391d <procdump>
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
80100894:	68 48 67 10 80       	push   $0x80106748
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 ab 32 00 00       	call   80103b4e <initlock>

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
80100952:	68 61 67 10 80       	push   $0x80106761
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
80100972:	e8 d7 5a 00 00       	call   8010644e <setupkvm>
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
80100a06:	e8 bd 58 00 00       	call   801062c8 <allocuvm>
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
80100a38:	e8 31 57 00 00       	call   8010616e <loaduvm>
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
80100a74:	e8 4f 58 00 00       	call   801062c8 <allocuvm>
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
80100a9d:	e8 28 59 00 00       	call   801063ca <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 12 5a 00 00       	call   801064d3 <clearpteu>
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
80100ae2:	e8 f1 33 00 00       	call   80103ed8 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 df 33 00 00       	call   80103ed8 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 58 5b 00 00       	call   80106663 <copyout>
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
80100b66:	e8 f8 5a 00 00       	call   80106663 <copyout>
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
80100ba3:	e8 f5 32 00 00       	call   80103e9d <safestrcpy>
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
80100bd1:	e8 eb 53 00 00       	call   80105fc1 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 ec 57 00 00       	call   801063ca <freevm>
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
80100c19:	68 6d 67 10 80       	push   $0x8010676d
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 26 2f 00 00       	call   80103b4e <initlock>
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
80100c39:	e8 4c 30 00 00       	call   80103c8a <acquire>
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
80100c68:	e8 82 30 00 00       	call   80103cef <release>
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
80100c7f:	e8 6b 30 00 00       	call   80103cef <release>
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
80100c9d:	e8 e8 2f 00 00       	call   80103c8a <acquire>
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
80100cba:	e8 30 30 00 00       	call   80103cef <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 74 67 10 80       	push   $0x80106774
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
80100ce2:	e8 a3 2f 00 00       	call   80103c8a <acquire>
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
80100d03:	e8 e7 2f 00 00       	call   80103cef <release>
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
80100d13:	68 7c 67 10 80       	push   $0x8010677c
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
80100d49:	e8 a1 2f 00 00       	call   80103cef <release>
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
80100e4b:	68 86 67 10 80       	push   $0x80106786
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
80100f10:	68 8f 67 10 80       	push   $0x8010678f
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
80100f2d:	68 95 67 10 80       	push   $0x80106795
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
80100f8a:	e8 22 2e 00 00       	call   80103db1 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 12 2e 00 00       	call   80103db1 <memmove>
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
80100fdf:	e8 52 2d 00 00       	call   80103d36 <memset>
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
80101062:	68 9f 67 10 80       	push   $0x8010679f
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
80101113:	68 b2 67 10 80       	push   $0x801067b2
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
801011ed:	68 c8 67 10 80       	push   $0x801067c8
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
8010120a:	e8 7b 2a 00 00       	call   80103c8a <acquire>
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
80101251:	e8 99 2a 00 00       	call   80103cef <release>
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
80101287:	e8 63 2a 00 00       	call   80103cef <release>
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
8010129c:	68 db 67 10 80       	push   $0x801067db
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
801012c5:	e8 e7 2a 00 00       	call   80103db1 <memmove>
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
801012e1:	68 eb 67 10 80       	push   $0x801067eb
801012e6:	68 e0 09 11 80       	push   $0x801109e0
801012eb:	e8 5e 28 00 00       	call   80103b4e <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 f2 67 10 80       	push   $0x801067f2
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 20 0a 11 80       	add    $0x80110a20,%eax
8010130f:	50                   	push   %eax
80101310:	e8 2e 27 00 00       	call   80103a43 <initsleeplock>
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
8010135a:	68 58 68 10 80       	push   $0x80106858
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
801013cd:	68 f8 67 10 80       	push   $0x801067f8
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 52 29 00 00       	call   80103d36 <memset>
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
8010146e:	e8 3e 29 00 00       	call   80103db1 <memmove>
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
8010154e:	e8 37 27 00 00       	call   80103c8a <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101563:	e8 87 27 00 00       	call   80103cef <release>
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
80101588:	e8 e9 24 00 00       	call   80103a76 <acquiresleep>
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
801015a0:	68 0a 68 10 80       	push   $0x8010680a
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
80101602:	e8 aa 27 00 00       	call   80103db1 <memmove>
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
80101627:	68 10 68 10 80       	push   $0x80106810
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
80101644:	e8 b7 24 00 00       	call   80103b00 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 66 24 00 00       	call   80103ac5 <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 1f 68 10 80       	push   $0x8010681f
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
80101686:	e8 eb 23 00 00       	call   80103a76 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 21 24 00 00       	call   80103ac5 <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016ab:	e8 da 25 00 00       	call   80103c8a <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016c0:	e8 2a 26 00 00       	call   80103cef <release>
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
801016d8:	e8 ad 25 00 00       	call   80103c8a <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016e7:	e8 03 26 00 00       	call   80103cef <release>
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
80101818:	e8 94 25 00 00       	call   80103db1 <memmove>
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
80101914:	e8 98 24 00 00       	call   80103db1 <memmove>
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
80101997:	e8 7c 24 00 00       	call   80103e18 <strncmp>
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
801019be:	68 27 68 10 80       	push   $0x80106827
801019c3:	e8 80 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 39 68 10 80       	push   $0x80106839
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
80101b80:	68 48 68 10 80       	push   $0x80106848
80101b85:	e8 be e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b8a:	83 ec 04             	sub    $0x4,%esp
80101b8d:	6a 0e                	push   $0xe
80101b8f:	57                   	push   %edi
80101b90:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b93:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b96:	50                   	push   %eax
80101b97:	e8 b9 22 00 00       	call   80103e55 <strncpy>
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
80101bc5:	68 28 6f 10 80       	push   $0x80106f28
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
80101cba:	68 ab 68 10 80       	push   $0x801068ab
80101cbf:	e8 84 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 b4 68 10 80       	push   $0x801068b4
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
80101cf4:	68 c6 68 10 80       	push   $0x801068c6
80101cf9:	68 80 a5 10 80       	push   $0x8010a580
80101cfe:	e8 4b 1e 00 00       	call   80103b4e <initlock>
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
80101d6e:	e8 17 1f 00 00       	call   80103c8a <acquire>

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
80101d9b:	e8 de 1a 00 00       	call   8010387e <wakeup>

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
80101db9:	e8 31 1f 00 00       	call   80103cef <release>
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
80101dd0:	e8 1a 1f 00 00       	call   80103cef <release>
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
80101e08:	e8 f3 1c 00 00       	call   80103b00 <holdingsleep>
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
80101e35:	e8 50 1e 00 00       	call   80103c8a <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e3a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e49:	eb 2a                	jmp    80101e75 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 ca 68 10 80       	push   $0x801068ca
80101e53:	e8 f0 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e58:	83 ec 0c             	sub    $0xc,%esp
80101e5b:	68 e0 68 10 80       	push   $0x801068e0
80101e60:	e8 e3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e65:	83 ec 0c             	sub    $0xc,%esp
80101e68:	68 f5 68 10 80       	push   $0x801068f5
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
80101e97:	e8 7a 18 00 00       	call   80103716 <sleep>
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
80101eb1:	e8 39 1e 00 00       	call   80103cef <release>
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
80101f2d:	68 14 69 10 80       	push   $0x80106914
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
80101fcc:	e8 65 1d 00 00       	call   80103d36 <memset>

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
80101ffb:	68 48 69 10 80       	push   $0x80106948
80102000:	e8 43 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80102005:	83 ec 0c             	sub    $0xc,%esp
80102008:	68 d6 69 10 80       	push   $0x801069d6
8010200d:	e8 36 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102012:	83 ec 0c             	sub    $0xc,%esp
80102015:	68 40 26 11 80       	push   $0x80112640
8010201a:	e8 6b 1c 00 00       	call   80103c8a <acquire>
8010201f:	83 c4 10             	add    $0x10,%esp
80102022:	eb b9                	jmp    80101fdd <kfree+0x4b>
    release(&kmem.lock);
80102024:	83 ec 0c             	sub    $0xc,%esp
80102027:	68 40 26 11 80       	push   $0x80112640
8010202c:	e8 be 1c 00 00       	call   80103cef <release>
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
80102054:	68 dc 69 10 80       	push   $0x801069dc
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
80102083:	68 e6 69 10 80       	push   $0x801069e6
80102088:	68 40 26 11 80       	push   $0x80112640
8010208d:	e8 bc 1a 00 00       	call   80103b4e <initlock>
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
80102108:	e8 7d 1b 00 00       	call   80103c8a <acquire>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	eb cd                	jmp    801020df <kalloc+0x10>
    release(&kmem.lock);
80102112:	83 ec 0c             	sub    $0xc,%esp
80102115:	68 40 26 11 80       	push   $0x80112640
8010211a:	e8 d0 1b 00 00       	call   80103cef <release>
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
static inline uchar
inb(ushort port)
{
  uchar data;

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
80102164:	0f b6 8a 20 6b 10 80 	movzbl -0x7fef94e0(%edx),%ecx
8010216b:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
80102171:	0f b6 82 20 6a 10 80 	movzbl -0x7fef95e0(%edx),%eax
80102178:	31 c1                	xor    %eax,%ecx
8010217a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102180:	89 c8                	mov    %ecx,%eax
80102182:	83 e0 03             	and    $0x3,%eax
80102185:	8b 04 85 00 6a 10 80 	mov    -0x7fef9600(,%eax,4),%eax
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
801021c0:	0f b6 82 20 6b 10 80 	movzbl -0x7fef94e0(%edx),%eax
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
}

static inline void
outb(ushort port, uchar data)
{
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
801024bb:	e8 bc 18 00 00       	call   80103d7c <memcmp>
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
80102626:	e8 86 17 00 00       	call   80103db1 <memmove>
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
80102725:	e8 87 16 00 00       	call   80103db1 <memmove>
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
80102793:	68 20 6c 10 80       	push   $0x80106c20
80102798:	68 80 26 11 80       	push   $0x80112680
8010279d:	e8 ac 13 00 00       	call   80103b4e <initlock>
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
801027dd:	e8 a8 14 00 00       	call   80103c8a <acquire>
801027e2:	83 c4 10             	add    $0x10,%esp
801027e5:	eb 15                	jmp    801027fc <begin_op+0x2a>
      sleep(&log, &log.lock);
801027e7:	83 ec 08             	sub    $0x8,%esp
801027ea:	68 80 26 11 80       	push   $0x80112680
801027ef:	68 80 26 11 80       	push   $0x80112680
801027f4:	e8 1d 0f 00 00       	call   80103716 <sleep>
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
8010282b:	e8 e6 0e 00 00       	call   80103716 <sleep>
80102830:	83 c4 10             	add    $0x10,%esp
80102833:	eb c7                	jmp    801027fc <begin_op+0x2a>
      log.outstanding += 1;
80102835:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	68 80 26 11 80       	push   $0x80112680
80102842:	e8 a8 14 00 00       	call   80103cef <release>
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
80102858:	e8 2d 14 00 00       	call   80103c8a <acquire>
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
80102892:	e8 58 14 00 00       	call   80103cef <release>
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
801028a6:	68 24 6c 10 80       	push   $0x80106c24
801028ab:	e8 98 da ff ff       	call   80100348 <panic>
    wakeup(&log);
801028b0:	83 ec 0c             	sub    $0xc,%esp
801028b3:	68 80 26 11 80       	push   $0x80112680
801028b8:	e8 c1 0f 00 00       	call   8010387e <wakeup>
801028bd:	83 c4 10             	add    $0x10,%esp
801028c0:	eb c8                	jmp    8010288a <end_op+0x3e>
    commit();
801028c2:	e8 91 fe ff ff       	call   80102758 <commit>
    acquire(&log.lock);
801028c7:	83 ec 0c             	sub    $0xc,%esp
801028ca:	68 80 26 11 80       	push   $0x80112680
801028cf:	e8 b6 13 00 00       	call   80103c8a <acquire>
    log.committing = 0;
801028d4:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
801028db:	00 00 00 
    wakeup(&log);
801028de:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028e5:	e8 94 0f 00 00       	call   8010387e <wakeup>
    release(&log.lock);
801028ea:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028f1:	e8 f9 13 00 00       	call   80103cef <release>
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
8010292d:	e8 58 13 00 00       	call   80103c8a <acquire>
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
80102958:	68 33 6c 10 80       	push   $0x80106c33
8010295d:	e8 e6 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102962:	83 ec 0c             	sub    $0xc,%esp
80102965:	68 49 6c 10 80       	push   $0x80106c49
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
80102988:	e8 62 13 00 00       	call   80103cef <release>
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
801029b6:	e8 f6 13 00 00       	call   80103db1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801029bb:	83 c4 10             	add    $0x10,%esp
801029be:	bb 80 27 11 80       	mov    $0x80112780,%ebx
801029c3:	eb 13                	jmp    801029d8 <startothers+0x38>
// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
        panic("V2P on address < KERNBASE "
801029c5:	83 ec 0c             	sub    $0xc,%esp
801029c8:	68 48 69 10 80       	push   $0x80106948
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
80102a60:	68 64 6c 10 80       	push   $0x80106c64
80102a65:	e8 a1 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a6a:	e8 fa 24 00 00       	call   80104f69 <idtinit>
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
80102a8d:	e8 0a 35 00 00       	call   80105f9c <switchkvm>
  seginit();
80102a92:	e8 b9 33 00 00       	call   80105e50 <seginit>
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
80102ac1:	e8 f6 39 00 00       	call   801064bc <kvmalloc>
  mpinit();        // detect other processors
80102ac6:	e8 e7 01 00 00       	call   80102cb2 <mpinit>
  lapicinit();     // interrupt controller
80102acb:	e8 c8 f7 ff ff       	call   80102298 <lapicinit>
  seginit();       // segment descriptors
80102ad0:	e8 7b 33 00 00       	call   80105e50 <seginit>
  picinit();       // disable pic
80102ad5:	e8 a0 02 00 00       	call   80102d7a <picinit>
  ioapicinit();    // another interrupt controller
80102ada:	e8 09 f4 ff ff       	call   80101ee8 <ioapicinit>
  consoleinit();   // console hardware
80102adf:	e8 aa dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102ae4:	e8 2e 27 00 00       	call   80105217 <uartinit>
  pinit();         // process table
80102ae9:	e8 d8 06 00 00       	call   801031c6 <pinit>
  tvinit();        // trap vectors
80102aee:	e8 c5 23 00 00       	call   80104eb8 <tvinit>
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
80102b61:	68 78 6c 10 80       	push   $0x80106c78
80102b66:	e8 dd d7 ff ff       	call   80100348 <panic>
80102b6b:	83 c3 10             	add    $0x10,%ebx
80102b6e:	39 f3                	cmp    %esi,%ebx
80102b70:	73 29                	jae    80102b9b <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b72:	83 ec 04             	sub    $0x4,%esp
80102b75:	6a 04                	push   $0x4
80102b77:	68 92 6c 10 80       	push   $0x80106c92
80102b7c:	53                   	push   %ebx
80102b7d:	e8 fa 11 00 00       	call   80103d7c <memcmp>
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
80102c43:	68 97 6c 10 80       	push   $0x80106c97
80102c48:	53                   	push   %ebx
80102c49:	e8 2e 11 00 00       	call   80103d7c <memcmp>
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
80102c85:	68 78 6c 10 80       	push   $0x80106c78
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
80102ce3:	68 9c 6c 10 80       	push   $0x80106c9c
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
80102d22:	ff 24 85 d4 6c 10 80 	jmp    *-0x7fef932c(,%eax,4)
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
80102d70:	68 b4 6c 10 80       	push   $0x80106cb4
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
80102e2c:	68 e8 6c 10 80       	push   $0x80106ce8
80102e31:	50                   	push   %eax
80102e32:	e8 17 0d 00 00       	call   80103b4e <initlock>
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
80102e88:	e8 fd 0d 00 00       	call   80103c8a <acquire>
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
80102eaa:	e8 cf 09 00 00       	call   8010387e <wakeup>
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
80102ec8:	e8 22 0e 00 00       	call   80103cef <release>
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
80102ee9:	e8 90 09 00 00       	call   8010387e <wakeup>
80102eee:	83 c4 10             	add    $0x10,%esp
80102ef1:	eb bf                	jmp    80102eb2 <pipeclose+0x35>
    release(&p->lock);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	53                   	push   %ebx
80102ef7:	e8 f3 0d 00 00       	call   80103cef <release>
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
80102f18:	e8 6d 0d 00 00       	call   80103c8a <acquire>
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
80102f61:	e8 18 09 00 00       	call   8010387e <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f66:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f6c:	83 c4 08             	add    $0x8,%esp
80102f6f:	56                   	push   %esi
80102f70:	50                   	push   %eax
80102f71:	e8 a0 07 00 00       	call   80103716 <sleep>
80102f76:	83 c4 10             	add    $0x10,%esp
80102f79:	eb b3                	jmp    80102f2e <pipewrite+0x25>
        release(&p->lock);
80102f7b:	83 ec 0c             	sub    $0xc,%esp
80102f7e:	53                   	push   %ebx
80102f7f:	e8 6b 0d 00 00       	call   80103cef <release>
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
80102fc0:	e8 b9 08 00 00       	call   8010387e <wakeup>
  release(&p->lock);
80102fc5:	89 1c 24             	mov    %ebx,(%esp)
80102fc8:	e8 22 0d 00 00       	call   80103cef <release>
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
80102fe4:	e8 a1 0c 00 00       	call   80103c8a <acquire>
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
8010301a:	e8 f7 06 00 00       	call   80103716 <sleep>
8010301f:	83 c4 10             	add    $0x10,%esp
80103022:	eb c8                	jmp    80102fec <piperead+0x17>
      release(&p->lock);
80103024:	83 ec 0c             	sub    $0xc,%esp
80103027:	53                   	push   %ebx
80103028:	e8 c2 0c 00 00       	call   80103cef <release>
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
80103077:	e8 02 08 00 00       	call   8010387e <wakeup>
  release(&p->lock);
8010307c:	89 1c 24             	mov    %ebx,(%esp)
8010307f:	e8 6b 0c 00 00       	call   80103cef <release>
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
801030cb:	e8 ba 0b 00 00       	call   80103c8a <acquire>
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
801030f6:	e8 f4 0b 00 00       	call   80103cef <release>
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
80103125:	e8 c5 0b 00 00       	call   80103cef <release>
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
80103142:	c7 80 b0 0f 00 00 ad 	movl   $0x80104ead,0xfb0(%eax)
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
8010315c:	e8 d5 0b 00 00       	call   80103d36 <memset>
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
8010318e:	e8 5c 0b 00 00       	call   80103cef <release>
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
801031cc:	68 ed 6c 10 80       	push   $0x80106ced
801031d1:	68 20 2d 11 80       	push   $0x80112d20
801031d6:	e8 73 09 00 00       	call   80103b4e <initlock>
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
80103218:	68 d0 6d 10 80       	push   $0x80106dd0
8010321d:	e8 26 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	68 f4 6c 10 80       	push   $0x80106cf4
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
8010325e:	e8 4a 09 00 00       	call   80103bad <pushcli>
  c = mycpu();
80103263:	e8 78 ff ff ff       	call   801031e0 <mycpu>
  p = c->proc;
80103268:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010326e:	e8 77 09 00 00       	call   80103bea <popcli>
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
8010328e:	e8 bb 31 00 00       	call   8010644e <setupkvm>
80103293:	89 43 04             	mov    %eax,0x4(%ebx)
80103296:	85 c0                	test   %eax,%eax
80103298:	0f 84 b7 00 00 00    	je     80103355 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010329e:	83 ec 04             	sub    $0x4,%esp
801032a1:	68 2c 00 00 00       	push   $0x2c
801032a6:	68 60 a4 10 80       	push   $0x8010a460
801032ab:	50                   	push   %eax
801032ac:	e8 3c 2e 00 00       	call   801060ed <inituvm>
  p->sz = PGSIZE;
801032b1:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801032b7:	83 c4 0c             	add    $0xc,%esp
801032ba:	6a 4c                	push   $0x4c
801032bc:	6a 00                	push   $0x0
801032be:	ff 73 18             	pushl  0x18(%ebx)
801032c1:	e8 70 0a 00 00       	call   80103d36 <memset>
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
80103314:	68 1d 6d 10 80       	push   $0x80106d1d
80103319:	50                   	push   %eax
8010331a:	e8 7e 0b 00 00       	call   80103e9d <safestrcpy>
  p->cwd = namei("/");
8010331f:	c7 04 24 26 6d 10 80 	movl   $0x80106d26,(%esp)
80103326:	e8 a4 e8 ff ff       	call   80101bcf <namei>
8010332b:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010332e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103335:	e8 50 09 00 00       	call   80103c8a <acquire>
  p->state = RUNNABLE;
8010333a:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103341:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103348:	e8 a2 09 00 00       	call   80103cef <release>
}
8010334d:	83 c4 10             	add    $0x10,%esp
80103350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103353:	c9                   	leave  
80103354:	c3                   	ret    
    panic("userinit: out of memory?");
80103355:	83 ec 0c             	sub    $0xc,%esp
80103358:	68 04 6d 10 80       	push   $0x80106d04
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
80103385:	e8 98 2e 00 00       	call   80106222 <deallocuvm>
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
801033a2:	e8 21 2f 00 00       	call   801062c8 <allocuvm>
801033a7:	83 c4 10             	add    $0x10,%esp
801033aa:	85 c0                	test   %eax,%eax
801033ac:	74 1a                	je     801033c8 <growproc+0x66>
  curproc->sz = sz;
801033ae:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801033b0:	83 ec 0c             	sub    $0xc,%esp
801033b3:	53                   	push   %ebx
801033b4:	e8 08 2c 00 00       	call   80105fc1 <switchuvm>
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
801033f9:	e8 01 31 00 00       	call   801064ff <copyuvm>
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
801034b0:	e8 e8 09 00 00       	call   80103e9d <safestrcpy>
  pid = np->pid;
801034b5:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801034b8:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801034bf:	e8 c6 07 00 00       	call   80103c8a <acquire>
  np->state = RUNNABLE;
801034c4:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801034cb:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801034d2:	e8 18 08 00 00       	call   80103cef <release>
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
80103501:	eb 5d                	jmp    80103560 <scheduler+0x75>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103503:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103509:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
8010350f:	73 3f                	jae    80103550 <scheduler+0x65>
      if(p->state != RUNNABLE)
80103511:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103515:	75 ec                	jne    80103503 <scheduler+0x18>
      c->proc = p;
80103517:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010351d:	83 ec 0c             	sub    $0xc,%esp
80103520:	53                   	push   %ebx
80103521:	e8 9b 2a 00 00       	call   80105fc1 <switchuvm>
      p->state = RUNNING;
80103526:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
8010352d:	83 c4 08             	add    $0x8,%esp
80103530:	ff 73 1c             	pushl  0x1c(%ebx)
80103533:	8d 46 04             	lea    0x4(%esi),%eax
80103536:	50                   	push   %eax
80103537:	e8 b4 09 00 00       	call   80103ef0 <swtch>
      switchkvm();
8010353c:	e8 5b 2a 00 00       	call   80105f9c <switchkvm>
      c->proc = 0;
80103541:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103548:	00 00 00 
8010354b:	83 c4 10             	add    $0x10,%esp
8010354e:	eb b3                	jmp    80103503 <scheduler+0x18>
    release(&ptable.lock);
80103550:	83 ec 0c             	sub    $0xc,%esp
80103553:	68 20 2d 11 80       	push   $0x80112d20
80103558:	e8 92 07 00 00       	call   80103cef <release>
    sti();
8010355d:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103560:	fb                   	sti    
    acquire(&ptable.lock);
80103561:	83 ec 0c             	sub    $0xc,%esp
80103564:	68 20 2d 11 80       	push   $0x80112d20
80103569:	e8 1c 07 00 00       	call   80103c8a <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010356e:	83 c4 10             	add    $0x10,%esp
80103571:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103576:	eb 91                	jmp    80103509 <scheduler+0x1e>

80103578 <sched>:
{
80103578:	55                   	push   %ebp
80103579:	89 e5                	mov    %esp,%ebp
8010357b:	56                   	push   %esi
8010357c:	53                   	push   %ebx
  struct proc *p = myproc();
8010357d:	e8 d5 fc ff ff       	call   80103257 <myproc>
80103582:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103584:	83 ec 0c             	sub    $0xc,%esp
80103587:	68 20 2d 11 80       	push   $0x80112d20
8010358c:	e8 b9 06 00 00       	call   80103c4a <holding>
80103591:	83 c4 10             	add    $0x10,%esp
80103594:	85 c0                	test   %eax,%eax
80103596:	74 4f                	je     801035e7 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103598:	e8 43 fc ff ff       	call   801031e0 <mycpu>
8010359d:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801035a4:	75 4e                	jne    801035f4 <sched+0x7c>
  if(p->state == RUNNING)
801035a6:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801035aa:	74 55                	je     80103601 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035ac:	9c                   	pushf  
801035ad:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801035ae:	f6 c4 02             	test   $0x2,%ah
801035b1:	75 5b                	jne    8010360e <sched+0x96>
  intena = mycpu()->intena;
801035b3:	e8 28 fc ff ff       	call   801031e0 <mycpu>
801035b8:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801035be:	e8 1d fc ff ff       	call   801031e0 <mycpu>
801035c3:	83 ec 08             	sub    $0x8,%esp
801035c6:	ff 70 04             	pushl  0x4(%eax)
801035c9:	83 c3 1c             	add    $0x1c,%ebx
801035cc:	53                   	push   %ebx
801035cd:	e8 1e 09 00 00       	call   80103ef0 <swtch>
  mycpu()->intena = intena;
801035d2:	e8 09 fc ff ff       	call   801031e0 <mycpu>
801035d7:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801035dd:	83 c4 10             	add    $0x10,%esp
801035e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035e3:	5b                   	pop    %ebx
801035e4:	5e                   	pop    %esi
801035e5:	5d                   	pop    %ebp
801035e6:	c3                   	ret    
    panic("sched ptable.lock");
801035e7:	83 ec 0c             	sub    $0xc,%esp
801035ea:	68 28 6d 10 80       	push   $0x80106d28
801035ef:	e8 54 cd ff ff       	call   80100348 <panic>
    panic("sched locks");
801035f4:	83 ec 0c             	sub    $0xc,%esp
801035f7:	68 3a 6d 10 80       	push   $0x80106d3a
801035fc:	e8 47 cd ff ff       	call   80100348 <panic>
    panic("sched running");
80103601:	83 ec 0c             	sub    $0xc,%esp
80103604:	68 46 6d 10 80       	push   $0x80106d46
80103609:	e8 3a cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
8010360e:	83 ec 0c             	sub    $0xc,%esp
80103611:	68 54 6d 10 80       	push   $0x80106d54
80103616:	e8 2d cd ff ff       	call   80100348 <panic>

8010361b <exit>:
{
8010361b:	55                   	push   %ebp
8010361c:	89 e5                	mov    %esp,%ebp
8010361e:	56                   	push   %esi
8010361f:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103620:	e8 32 fc ff ff       	call   80103257 <myproc>
  if(curproc == initproc)
80103625:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
8010362b:	74 09                	je     80103636 <exit+0x1b>
8010362d:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
8010362f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103634:	eb 10                	jmp    80103646 <exit+0x2b>
    panic("init exiting");
80103636:	83 ec 0c             	sub    $0xc,%esp
80103639:	68 68 6d 10 80       	push   $0x80106d68
8010363e:	e8 05 cd ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103643:	83 c3 01             	add    $0x1,%ebx
80103646:	83 fb 0f             	cmp    $0xf,%ebx
80103649:	7f 1e                	jg     80103669 <exit+0x4e>
    if(curproc->ofile[fd]){
8010364b:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010364f:	85 c0                	test   %eax,%eax
80103651:	74 f0                	je     80103643 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103653:	83 ec 0c             	sub    $0xc,%esp
80103656:	50                   	push   %eax
80103657:	e8 77 d6 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
8010365c:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103663:	00 
80103664:	83 c4 10             	add    $0x10,%esp
80103667:	eb da                	jmp    80103643 <exit+0x28>
  begin_op();
80103669:	e8 64 f1 ff ff       	call   801027d2 <begin_op>
  iput(curproc->cwd);
8010366e:	83 ec 0c             	sub    $0xc,%esp
80103671:	ff 76 68             	pushl  0x68(%esi)
80103674:	e8 fd df ff ff       	call   80101676 <iput>
  end_op();
80103679:	e8 ce f1 ff ff       	call   8010284c <end_op>
  curproc->cwd = 0;
8010367e:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103685:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010368c:	e8 f9 05 00 00       	call   80103c8a <acquire>
  wakeup1(curproc->parent);
80103691:	8b 46 14             	mov    0x14(%esi),%eax
80103694:	e8 f8 f9 ff ff       	call   80103091 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103699:	83 c4 10             	add    $0x10,%esp
8010369c:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801036a1:	eb 06                	jmp    801036a9 <exit+0x8e>
801036a3:	81 c3 84 00 00 00    	add    $0x84,%ebx
801036a9:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
801036af:	73 1a                	jae    801036cb <exit+0xb0>
    if(p->parent == curproc){
801036b1:	39 73 14             	cmp    %esi,0x14(%ebx)
801036b4:	75 ed                	jne    801036a3 <exit+0x88>
      p->parent = initproc;
801036b6:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801036bb:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801036be:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801036c2:	75 df                	jne    801036a3 <exit+0x88>
        wakeup1(initproc);
801036c4:	e8 c8 f9 ff ff       	call   80103091 <wakeup1>
801036c9:	eb d8                	jmp    801036a3 <exit+0x88>
  curproc->state = ZOMBIE;
801036cb:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801036d2:	e8 a1 fe ff ff       	call   80103578 <sched>
  panic("zombie exit");
801036d7:	83 ec 0c             	sub    $0xc,%esp
801036da:	68 75 6d 10 80       	push   $0x80106d75
801036df:	e8 64 cc ff ff       	call   80100348 <panic>

801036e4 <yield>:
{
801036e4:	55                   	push   %ebp
801036e5:	89 e5                	mov    %esp,%ebp
801036e7:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801036ea:	68 20 2d 11 80       	push   $0x80112d20
801036ef:	e8 96 05 00 00       	call   80103c8a <acquire>
  myproc()->state = RUNNABLE;
801036f4:	e8 5e fb ff ff       	call   80103257 <myproc>
801036f9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103700:	e8 73 fe ff ff       	call   80103578 <sched>
  release(&ptable.lock);
80103705:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010370c:	e8 de 05 00 00       	call   80103cef <release>
}
80103711:	83 c4 10             	add    $0x10,%esp
80103714:	c9                   	leave  
80103715:	c3                   	ret    

80103716 <sleep>:
{
80103716:	55                   	push   %ebp
80103717:	89 e5                	mov    %esp,%ebp
80103719:	56                   	push   %esi
8010371a:	53                   	push   %ebx
8010371b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
8010371e:	e8 34 fb ff ff       	call   80103257 <myproc>
  if(p == 0)
80103723:	85 c0                	test   %eax,%eax
80103725:	74 66                	je     8010378d <sleep+0x77>
80103727:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103729:	85 db                	test   %ebx,%ebx
8010372b:	74 6d                	je     8010379a <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010372d:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
80103733:	74 18                	je     8010374d <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103735:	83 ec 0c             	sub    $0xc,%esp
80103738:	68 20 2d 11 80       	push   $0x80112d20
8010373d:	e8 48 05 00 00       	call   80103c8a <acquire>
    release(lk);
80103742:	89 1c 24             	mov    %ebx,(%esp)
80103745:	e8 a5 05 00 00       	call   80103cef <release>
8010374a:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010374d:	8b 45 08             	mov    0x8(%ebp),%eax
80103750:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103753:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010375a:	e8 19 fe ff ff       	call   80103578 <sched>
  p->chan = 0;
8010375f:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103766:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
8010376c:	74 18                	je     80103786 <sleep+0x70>
    release(&ptable.lock);
8010376e:	83 ec 0c             	sub    $0xc,%esp
80103771:	68 20 2d 11 80       	push   $0x80112d20
80103776:	e8 74 05 00 00       	call   80103cef <release>
    acquire(lk);
8010377b:	89 1c 24             	mov    %ebx,(%esp)
8010377e:	e8 07 05 00 00       	call   80103c8a <acquire>
80103783:	83 c4 10             	add    $0x10,%esp
}
80103786:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103789:	5b                   	pop    %ebx
8010378a:	5e                   	pop    %esi
8010378b:	5d                   	pop    %ebp
8010378c:	c3                   	ret    
    panic("sleep");
8010378d:	83 ec 0c             	sub    $0xc,%esp
80103790:	68 81 6d 10 80       	push   $0x80106d81
80103795:	e8 ae cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010379a:	83 ec 0c             	sub    $0xc,%esp
8010379d:	68 87 6d 10 80       	push   $0x80106d87
801037a2:	e8 a1 cb ff ff       	call   80100348 <panic>

801037a7 <wait>:
{
801037a7:	55                   	push   %ebp
801037a8:	89 e5                	mov    %esp,%ebp
801037aa:	56                   	push   %esi
801037ab:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037ac:	e8 a6 fa ff ff       	call   80103257 <myproc>
801037b1:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801037b3:	83 ec 0c             	sub    $0xc,%esp
801037b6:	68 20 2d 11 80       	push   $0x80112d20
801037bb:	e8 ca 04 00 00       	call   80103c8a <acquire>
801037c0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801037c3:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037c8:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801037cd:	eb 5e                	jmp    8010382d <wait+0x86>
        pid = p->pid;
801037cf:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801037d2:	83 ec 0c             	sub    $0xc,%esp
801037d5:	ff 73 08             	pushl  0x8(%ebx)
801037d8:	e8 b5 e7 ff ff       	call   80101f92 <kfree>
        p->kstack = 0;
801037dd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801037e4:	83 c4 04             	add    $0x4,%esp
801037e7:	ff 73 04             	pushl  0x4(%ebx)
801037ea:	e8 db 2b 00 00       	call   801063ca <freevm>
        p->pid = 0;
801037ef:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801037f6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801037fd:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103801:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103808:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010380f:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103816:	e8 d4 04 00 00       	call   80103cef <release>
        return pid;
8010381b:	83 c4 10             	add    $0x10,%esp
}
8010381e:	89 f0                	mov    %esi,%eax
80103820:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103823:	5b                   	pop    %ebx
80103824:	5e                   	pop    %esi
80103825:	5d                   	pop    %ebp
80103826:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103827:	81 c3 84 00 00 00    	add    $0x84,%ebx
8010382d:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103833:	73 12                	jae    80103847 <wait+0xa0>
      if(p->parent != curproc)
80103835:	39 73 14             	cmp    %esi,0x14(%ebx)
80103838:	75 ed                	jne    80103827 <wait+0x80>
      if(p->state == ZOMBIE){
8010383a:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010383e:	74 8f                	je     801037cf <wait+0x28>
      havekids = 1;
80103840:	b8 01 00 00 00       	mov    $0x1,%eax
80103845:	eb e0                	jmp    80103827 <wait+0x80>
    if(!havekids || curproc->killed){
80103847:	85 c0                	test   %eax,%eax
80103849:	74 06                	je     80103851 <wait+0xaa>
8010384b:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010384f:	74 17                	je     80103868 <wait+0xc1>
      release(&ptable.lock);
80103851:	83 ec 0c             	sub    $0xc,%esp
80103854:	68 20 2d 11 80       	push   $0x80112d20
80103859:	e8 91 04 00 00       	call   80103cef <release>
      return -1;
8010385e:	83 c4 10             	add    $0x10,%esp
80103861:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103866:	eb b6                	jmp    8010381e <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103868:	83 ec 08             	sub    $0x8,%esp
8010386b:	68 20 2d 11 80       	push   $0x80112d20
80103870:	56                   	push   %esi
80103871:	e8 a0 fe ff ff       	call   80103716 <sleep>
    havekids = 0;
80103876:	83 c4 10             	add    $0x10,%esp
80103879:	e9 45 ff ff ff       	jmp    801037c3 <wait+0x1c>

8010387e <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010387e:	55                   	push   %ebp
8010387f:	89 e5                	mov    %esp,%ebp
80103881:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103884:	68 20 2d 11 80       	push   $0x80112d20
80103889:	e8 fc 03 00 00       	call   80103c8a <acquire>
  wakeup1(chan);
8010388e:	8b 45 08             	mov    0x8(%ebp),%eax
80103891:	e8 fb f7 ff ff       	call   80103091 <wakeup1>
  release(&ptable.lock);
80103896:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010389d:	e8 4d 04 00 00       	call   80103cef <release>
}
801038a2:	83 c4 10             	add    $0x10,%esp
801038a5:	c9                   	leave  
801038a6:	c3                   	ret    

801038a7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801038a7:	55                   	push   %ebp
801038a8:	89 e5                	mov    %esp,%ebp
801038aa:	53                   	push   %ebx
801038ab:	83 ec 10             	sub    $0x10,%esp
801038ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038b1:	68 20 2d 11 80       	push   $0x80112d20
801038b6:	e8 cf 03 00 00       	call   80103c8a <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038bb:	83 c4 10             	add    $0x10,%esp
801038be:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
801038c3:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
801038c8:	73 3c                	jae    80103906 <kill+0x5f>
    if(p->pid == pid){
801038ca:	39 58 10             	cmp    %ebx,0x10(%eax)
801038cd:	74 07                	je     801038d6 <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038cf:	05 84 00 00 00       	add    $0x84,%eax
801038d4:	eb ed                	jmp    801038c3 <kill+0x1c>
      p->killed = 1;
801038d6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801038dd:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801038e1:	74 1a                	je     801038fd <kill+0x56>
        p->state = RUNNABLE;
      release(&ptable.lock);
801038e3:	83 ec 0c             	sub    $0xc,%esp
801038e6:	68 20 2d 11 80       	push   $0x80112d20
801038eb:	e8 ff 03 00 00       	call   80103cef <release>
      return 0;
801038f0:	83 c4 10             	add    $0x10,%esp
801038f3:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801038f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038fb:	c9                   	leave  
801038fc:	c3                   	ret    
        p->state = RUNNABLE;
801038fd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103904:	eb dd                	jmp    801038e3 <kill+0x3c>
  release(&ptable.lock);
80103906:	83 ec 0c             	sub    $0xc,%esp
80103909:	68 20 2d 11 80       	push   $0x80112d20
8010390e:	e8 dc 03 00 00       	call   80103cef <release>
  return -1;
80103913:	83 c4 10             	add    $0x10,%esp
80103916:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010391b:	eb db                	jmp    801038f8 <kill+0x51>

8010391d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010391d:	55                   	push   %ebp
8010391e:	89 e5                	mov    %esp,%ebp
80103920:	56                   	push   %esi
80103921:	53                   	push   %ebx
80103922:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103925:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010392a:	eb 36                	jmp    80103962 <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
8010392c:	b8 98 6d 10 80       	mov    $0x80106d98,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103931:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103934:	52                   	push   %edx
80103935:	50                   	push   %eax
80103936:	ff 73 10             	pushl  0x10(%ebx)
80103939:	68 9c 6d 10 80       	push   $0x80106d9c
8010393e:	e8 c8 cc ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103943:	83 c4 10             	add    $0x10,%esp
80103946:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
8010394a:	74 3c                	je     80103988 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010394c:	83 ec 0c             	sub    $0xc,%esp
8010394f:	68 2f 71 10 80       	push   $0x8010712f
80103954:	e8 b2 cc ff ff       	call   8010060b <cprintf>
80103959:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010395c:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103962:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103968:	73 61                	jae    801039cb <procdump+0xae>
    if(p->state == UNUSED)
8010396a:	8b 43 0c             	mov    0xc(%ebx),%eax
8010396d:	85 c0                	test   %eax,%eax
8010396f:	74 eb                	je     8010395c <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103971:	83 f8 05             	cmp    $0x5,%eax
80103974:	77 b6                	ja     8010392c <procdump+0xf>
80103976:	8b 04 85 f8 6d 10 80 	mov    -0x7fef9208(,%eax,4),%eax
8010397d:	85 c0                	test   %eax,%eax
8010397f:	75 b0                	jne    80103931 <procdump+0x14>
      state = "???";
80103981:	b8 98 6d 10 80       	mov    $0x80106d98,%eax
80103986:	eb a9                	jmp    80103931 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103988:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010398b:	8b 40 0c             	mov    0xc(%eax),%eax
8010398e:	83 c0 08             	add    $0x8,%eax
80103991:	83 ec 08             	sub    $0x8,%esp
80103994:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103997:	52                   	push   %edx
80103998:	50                   	push   %eax
80103999:	e8 cb 01 00 00       	call   80103b69 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010399e:	83 c4 10             	add    $0x10,%esp
801039a1:	be 00 00 00 00       	mov    $0x0,%esi
801039a6:	eb 14                	jmp    801039bc <procdump+0x9f>
        cprintf(" %p", pc[i]);
801039a8:	83 ec 08             	sub    $0x8,%esp
801039ab:	50                   	push   %eax
801039ac:	68 21 67 10 80       	push   $0x80106721
801039b1:	e8 55 cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801039b6:	83 c6 01             	add    $0x1,%esi
801039b9:	83 c4 10             	add    $0x10,%esp
801039bc:	83 fe 09             	cmp    $0x9,%esi
801039bf:	7f 8b                	jg     8010394c <procdump+0x2f>
801039c1:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
801039c5:	85 c0                	test   %eax,%eax
801039c7:	75 df                	jne    801039a8 <procdump+0x8b>
801039c9:	eb 81                	jmp    8010394c <procdump+0x2f>
  }
}
801039cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039ce:	5b                   	pop    %ebx
801039cf:	5e                   	pop    %esi
801039d0:	5d                   	pop    %ebp
801039d1:	c3                   	ret    

801039d2 <getprocessesinfo_helper>:

int getprocessesinfo_helper(struct processes_info *my_process_info){
801039d2:	55                   	push   %ebp
801039d3:	89 e5                	mov    %esp,%ebp
801039d5:	53                   	push   %ebx
801039d6:	83 ec 10             	sub    $0x10,%esp
801039d9:	8b 5d 08             	mov    0x8(%ebp),%ebx

  struct proc *p;

  acquire(&ptable.lock);
801039dc:	68 20 2d 11 80       	push   $0x80112d20
801039e1:	e8 a4 02 00 00       	call   80103c8a <acquire>
  int i = 0;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039e6:	83 c4 10             	add    $0x10,%esp
  int i = 0;
801039e9:	ba 00 00 00 00       	mov    $0x0,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ee:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
801039f3:	eb 05                	jmp    801039fa <getprocessesinfo_helper+0x28>
801039f5:	05 84 00 00 00       	add    $0x84,%eax
801039fa:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
801039ff:	73 2b                	jae    80103a2c <getprocessesinfo_helper+0x5a>
    if(p->state != UNUSED){
80103a01:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
80103a05:	74 ee                	je     801039f5 <getprocessesinfo_helper+0x23>
      //cprintf("PID %d has %d tickets! \n", p->pid, p->tickets);
      my_process_info->pids[i] = p->pid;
80103a07:	8b 48 10             	mov    0x10(%eax),%ecx
80103a0a:	89 4c 93 04          	mov    %ecx,0x4(%ebx,%edx,4)
      my_process_info->tickets[i] = p->tickets;
80103a0e:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80103a14:	89 8c 93 04 02 00 00 	mov    %ecx,0x204(%ebx,%edx,4)
      my_process_info->times_scheduled[i] = p->num_times_scheduled;
80103a1b:	8b 48 7c             	mov    0x7c(%eax),%ecx
80103a1e:	89 8c 93 04 01 00 00 	mov    %ecx,0x104(%ebx,%edx,4)
      my_process_info->num_processes = ++i;
80103a25:	83 c2 01             	add    $0x1,%edx
80103a28:	89 13                	mov    %edx,(%ebx)
80103a2a:	eb c9                	jmp    801039f5 <getprocessesinfo_helper+0x23>

    }
    
  }
  
  release(&ptable.lock);
80103a2c:	83 ec 0c             	sub    $0xc,%esp
80103a2f:	68 20 2d 11 80       	push   $0x80112d20
80103a34:	e8 b6 02 00 00       	call   80103cef <release>
  return 0;
}
80103a39:	b8 00 00 00 00       	mov    $0x0,%eax
80103a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a41:	c9                   	leave  
80103a42:	c3                   	ret    

80103a43 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103a43:	55                   	push   %ebp
80103a44:	89 e5                	mov    %esp,%ebp
80103a46:	53                   	push   %ebx
80103a47:	83 ec 0c             	sub    $0xc,%esp
80103a4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a4d:	68 10 6e 10 80       	push   $0x80106e10
80103a52:	8d 43 04             	lea    0x4(%ebx),%eax
80103a55:	50                   	push   %eax
80103a56:	e8 f3 00 00 00       	call   80103b4e <initlock>
  lk->name = name;
80103a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a5e:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a61:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a67:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a6e:	83 c4 10             	add    $0x10,%esp
80103a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a74:	c9                   	leave  
80103a75:	c3                   	ret    

80103a76 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a76:	55                   	push   %ebp
80103a77:	89 e5                	mov    %esp,%ebp
80103a79:	56                   	push   %esi
80103a7a:	53                   	push   %ebx
80103a7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a7e:	8d 73 04             	lea    0x4(%ebx),%esi
80103a81:	83 ec 0c             	sub    $0xc,%esp
80103a84:	56                   	push   %esi
80103a85:	e8 00 02 00 00       	call   80103c8a <acquire>
  while (lk->locked) {
80103a8a:	83 c4 10             	add    $0x10,%esp
80103a8d:	eb 0d                	jmp    80103a9c <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103a8f:	83 ec 08             	sub    $0x8,%esp
80103a92:	56                   	push   %esi
80103a93:	53                   	push   %ebx
80103a94:	e8 7d fc ff ff       	call   80103716 <sleep>
80103a99:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103a9c:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a9f:	75 ee                	jne    80103a8f <acquiresleep+0x19>
  }
  lk->locked = 1;
80103aa1:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103aa7:	e8 ab f7 ff ff       	call   80103257 <myproc>
80103aac:	8b 40 10             	mov    0x10(%eax),%eax
80103aaf:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103ab2:	83 ec 0c             	sub    $0xc,%esp
80103ab5:	56                   	push   %esi
80103ab6:	e8 34 02 00 00       	call   80103cef <release>
}
80103abb:	83 c4 10             	add    $0x10,%esp
80103abe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ac1:	5b                   	pop    %ebx
80103ac2:	5e                   	pop    %esi
80103ac3:	5d                   	pop    %ebp
80103ac4:	c3                   	ret    

80103ac5 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103ac5:	55                   	push   %ebp
80103ac6:	89 e5                	mov    %esp,%ebp
80103ac8:	56                   	push   %esi
80103ac9:	53                   	push   %ebx
80103aca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103acd:	8d 73 04             	lea    0x4(%ebx),%esi
80103ad0:	83 ec 0c             	sub    $0xc,%esp
80103ad3:	56                   	push   %esi
80103ad4:	e8 b1 01 00 00       	call   80103c8a <acquire>
  lk->locked = 0;
80103ad9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103adf:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ae6:	89 1c 24             	mov    %ebx,(%esp)
80103ae9:	e8 90 fd ff ff       	call   8010387e <wakeup>
  release(&lk->lk);
80103aee:	89 34 24             	mov    %esi,(%esp)
80103af1:	e8 f9 01 00 00       	call   80103cef <release>
}
80103af6:	83 c4 10             	add    $0x10,%esp
80103af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103afc:	5b                   	pop    %ebx
80103afd:	5e                   	pop    %esi
80103afe:	5d                   	pop    %ebp
80103aff:	c3                   	ret    

80103b00 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103b00:	55                   	push   %ebp
80103b01:	89 e5                	mov    %esp,%ebp
80103b03:	56                   	push   %esi
80103b04:	53                   	push   %ebx
80103b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103b08:	8d 73 04             	lea    0x4(%ebx),%esi
80103b0b:	83 ec 0c             	sub    $0xc,%esp
80103b0e:	56                   	push   %esi
80103b0f:	e8 76 01 00 00       	call   80103c8a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103b14:	83 c4 10             	add    $0x10,%esp
80103b17:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b1a:	75 17                	jne    80103b33 <holdingsleep+0x33>
80103b1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103b21:	83 ec 0c             	sub    $0xc,%esp
80103b24:	56                   	push   %esi
80103b25:	e8 c5 01 00 00       	call   80103cef <release>
  return r;
}
80103b2a:	89 d8                	mov    %ebx,%eax
80103b2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b2f:	5b                   	pop    %ebx
80103b30:	5e                   	pop    %esi
80103b31:	5d                   	pop    %ebp
80103b32:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103b33:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103b36:	e8 1c f7 ff ff       	call   80103257 <myproc>
80103b3b:	3b 58 10             	cmp    0x10(%eax),%ebx
80103b3e:	74 07                	je     80103b47 <holdingsleep+0x47>
80103b40:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b45:	eb da                	jmp    80103b21 <holdingsleep+0x21>
80103b47:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b4c:	eb d3                	jmp    80103b21 <holdingsleep+0x21>

80103b4e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b54:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b57:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b60:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b67:	5d                   	pop    %ebp
80103b68:	c3                   	ret    

80103b69 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b69:	55                   	push   %ebp
80103b6a:	89 e5                	mov    %esp,%ebp
80103b6c:	53                   	push   %ebx
80103b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b70:	8b 45 08             	mov    0x8(%ebp),%eax
80103b73:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b76:	b8 00 00 00 00       	mov    $0x0,%eax
80103b7b:	83 f8 09             	cmp    $0x9,%eax
80103b7e:	7f 25                	jg     80103ba5 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b80:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b86:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b8c:	77 17                	ja     80103ba5 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b8e:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b91:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b94:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b96:	83 c0 01             	add    $0x1,%eax
80103b99:	eb e0                	jmp    80103b7b <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b9b:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103ba2:	83 c0 01             	add    $0x1,%eax
80103ba5:	83 f8 09             	cmp    $0x9,%eax
80103ba8:	7e f1                	jle    80103b9b <getcallerpcs+0x32>
}
80103baa:	5b                   	pop    %ebx
80103bab:	5d                   	pop    %ebp
80103bac:	c3                   	ret    

80103bad <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	53                   	push   %ebx
80103bb1:	83 ec 04             	sub    $0x4,%esp
80103bb4:	9c                   	pushf  
80103bb5:	5b                   	pop    %ebx
  asm volatile("cli");
80103bb6:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103bb7:	e8 24 f6 ff ff       	call   801031e0 <mycpu>
80103bbc:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bc3:	74 12                	je     80103bd7 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103bc5:	e8 16 f6 ff ff       	call   801031e0 <mycpu>
80103bca:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103bd1:	83 c4 04             	add    $0x4,%esp
80103bd4:	5b                   	pop    %ebx
80103bd5:	5d                   	pop    %ebp
80103bd6:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103bd7:	e8 04 f6 ff ff       	call   801031e0 <mycpu>
80103bdc:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103be2:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103be8:	eb db                	jmp    80103bc5 <pushcli+0x18>

80103bea <popcli>:

void
popcli(void)
{
80103bea:	55                   	push   %ebp
80103beb:	89 e5                	mov    %esp,%ebp
80103bed:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103bf0:	9c                   	pushf  
80103bf1:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103bf2:	f6 c4 02             	test   $0x2,%ah
80103bf5:	75 28                	jne    80103c1f <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103bf7:	e8 e4 f5 ff ff       	call   801031e0 <mycpu>
80103bfc:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103c02:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103c05:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103c0b:	85 d2                	test   %edx,%edx
80103c0d:	78 1d                	js     80103c2c <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c0f:	e8 cc f5 ff ff       	call   801031e0 <mycpu>
80103c14:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c1b:	74 1c                	je     80103c39 <popcli+0x4f>
    sti();
}
80103c1d:	c9                   	leave  
80103c1e:	c3                   	ret    
    panic("popcli - interruptible");
80103c1f:	83 ec 0c             	sub    $0xc,%esp
80103c22:	68 1b 6e 10 80       	push   $0x80106e1b
80103c27:	e8 1c c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103c2c:	83 ec 0c             	sub    $0xc,%esp
80103c2f:	68 32 6e 10 80       	push   $0x80106e32
80103c34:	e8 0f c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c39:	e8 a2 f5 ff ff       	call   801031e0 <mycpu>
80103c3e:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c45:	74 d6                	je     80103c1d <popcli+0x33>
  asm volatile("sti");
80103c47:	fb                   	sti    
}
80103c48:	eb d3                	jmp    80103c1d <popcli+0x33>

80103c4a <holding>:
{
80103c4a:	55                   	push   %ebp
80103c4b:	89 e5                	mov    %esp,%ebp
80103c4d:	53                   	push   %ebx
80103c4e:	83 ec 04             	sub    $0x4,%esp
80103c51:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c54:	e8 54 ff ff ff       	call   80103bad <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c59:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c5c:	75 12                	jne    80103c70 <holding+0x26>
80103c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c63:	e8 82 ff ff ff       	call   80103bea <popcli>
}
80103c68:	89 d8                	mov    %ebx,%eax
80103c6a:	83 c4 04             	add    $0x4,%esp
80103c6d:	5b                   	pop    %ebx
80103c6e:	5d                   	pop    %ebp
80103c6f:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c70:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c73:	e8 68 f5 ff ff       	call   801031e0 <mycpu>
80103c78:	39 c3                	cmp    %eax,%ebx
80103c7a:	74 07                	je     80103c83 <holding+0x39>
80103c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c81:	eb e0                	jmp    80103c63 <holding+0x19>
80103c83:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c88:	eb d9                	jmp    80103c63 <holding+0x19>

80103c8a <acquire>:
{
80103c8a:	55                   	push   %ebp
80103c8b:	89 e5                	mov    %esp,%ebp
80103c8d:	53                   	push   %ebx
80103c8e:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c91:	e8 17 ff ff ff       	call   80103bad <pushcli>
  if(holding(lk))
80103c96:	83 ec 0c             	sub    $0xc,%esp
80103c99:	ff 75 08             	pushl  0x8(%ebp)
80103c9c:	e8 a9 ff ff ff       	call   80103c4a <holding>
80103ca1:	83 c4 10             	add    $0x10,%esp
80103ca4:	85 c0                	test   %eax,%eax
80103ca6:	75 3a                	jne    80103ce2 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103cab:	b8 01 00 00 00       	mov    $0x1,%eax
80103cb0:	f0 87 02             	lock xchg %eax,(%edx)
80103cb3:	85 c0                	test   %eax,%eax
80103cb5:	75 f1                	jne    80103ca8 <acquire+0x1e>
  __sync_synchronize();
80103cb7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103cbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103cbf:	e8 1c f5 ff ff       	call   801031e0 <mycpu>
80103cc4:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103cca:	83 c0 0c             	add    $0xc,%eax
80103ccd:	83 ec 08             	sub    $0x8,%esp
80103cd0:	50                   	push   %eax
80103cd1:	8d 45 08             	lea    0x8(%ebp),%eax
80103cd4:	50                   	push   %eax
80103cd5:	e8 8f fe ff ff       	call   80103b69 <getcallerpcs>
}
80103cda:	83 c4 10             	add    $0x10,%esp
80103cdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ce0:	c9                   	leave  
80103ce1:	c3                   	ret    
    panic("acquire");
80103ce2:	83 ec 0c             	sub    $0xc,%esp
80103ce5:	68 39 6e 10 80       	push   $0x80106e39
80103cea:	e8 59 c6 ff ff       	call   80100348 <panic>

80103cef <release>:
{
80103cef:	55                   	push   %ebp
80103cf0:	89 e5                	mov    %esp,%ebp
80103cf2:	53                   	push   %ebx
80103cf3:	83 ec 10             	sub    $0x10,%esp
80103cf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103cf9:	53                   	push   %ebx
80103cfa:	e8 4b ff ff ff       	call   80103c4a <holding>
80103cff:	83 c4 10             	add    $0x10,%esp
80103d02:	85 c0                	test   %eax,%eax
80103d04:	74 23                	je     80103d29 <release+0x3a>
  lk->pcs[0] = 0;
80103d06:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103d0d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103d14:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103d19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103d1f:	e8 c6 fe ff ff       	call   80103bea <popcli>
}
80103d24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d27:	c9                   	leave  
80103d28:	c3                   	ret    
    panic("release");
80103d29:	83 ec 0c             	sub    $0xc,%esp
80103d2c:	68 41 6e 10 80       	push   $0x80106e41
80103d31:	e8 12 c6 ff ff       	call   80100348 <panic>

80103d36 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103d36:	55                   	push   %ebp
80103d37:	89 e5                	mov    %esp,%ebp
80103d39:	57                   	push   %edi
80103d3a:	53                   	push   %ebx
80103d3b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103d41:	f6 c2 03             	test   $0x3,%dl
80103d44:	75 05                	jne    80103d4b <memset+0x15>
80103d46:	f6 c1 03             	test   $0x3,%cl
80103d49:	74 0e                	je     80103d59 <memset+0x23>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80103d4b:	89 d7                	mov    %edx,%edi
80103d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d50:	fc                   	cld    
80103d51:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103d53:	89 d0                	mov    %edx,%eax
80103d55:	5b                   	pop    %ebx
80103d56:	5f                   	pop    %edi
80103d57:	5d                   	pop    %ebp
80103d58:	c3                   	ret    
    c &= 0xFF;
80103d59:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103d5d:	c1 e9 02             	shr    $0x2,%ecx
80103d60:	89 f8                	mov    %edi,%eax
80103d62:	c1 e0 18             	shl    $0x18,%eax
80103d65:	89 fb                	mov    %edi,%ebx
80103d67:	c1 e3 10             	shl    $0x10,%ebx
80103d6a:	09 d8                	or     %ebx,%eax
80103d6c:	89 fb                	mov    %edi,%ebx
80103d6e:	c1 e3 08             	shl    $0x8,%ebx
80103d71:	09 d8                	or     %ebx,%eax
80103d73:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80103d75:	89 d7                	mov    %edx,%edi
80103d77:	fc                   	cld    
80103d78:	f3 ab                	rep stos %eax,%es:(%edi)
80103d7a:	eb d7                	jmp    80103d53 <memset+0x1d>

80103d7c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103d7c:	55                   	push   %ebp
80103d7d:	89 e5                	mov    %esp,%ebp
80103d7f:	56                   	push   %esi
80103d80:	53                   	push   %ebx
80103d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d84:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d87:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103d8a:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d8d:	85 c0                	test   %eax,%eax
80103d8f:	74 1c                	je     80103dad <memcmp+0x31>
    if(*s1 != *s2)
80103d91:	0f b6 01             	movzbl (%ecx),%eax
80103d94:	0f b6 1a             	movzbl (%edx),%ebx
80103d97:	38 d8                	cmp    %bl,%al
80103d99:	75 0a                	jne    80103da5 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103d9b:	83 c1 01             	add    $0x1,%ecx
80103d9e:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103da1:	89 f0                	mov    %esi,%eax
80103da3:	eb e5                	jmp    80103d8a <memcmp+0xe>
      return *s1 - *s2;
80103da5:	0f b6 c0             	movzbl %al,%eax
80103da8:	0f b6 db             	movzbl %bl,%ebx
80103dab:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103dad:	5b                   	pop    %ebx
80103dae:	5e                   	pop    %esi
80103daf:	5d                   	pop    %ebp
80103db0:	c3                   	ret    

80103db1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	56                   	push   %esi
80103db5:	53                   	push   %ebx
80103db6:	8b 45 08             	mov    0x8(%ebp),%eax
80103db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103dbc:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103dbf:	39 c1                	cmp    %eax,%ecx
80103dc1:	73 3a                	jae    80103dfd <memmove+0x4c>
80103dc3:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103dc6:	39 c3                	cmp    %eax,%ebx
80103dc8:	76 37                	jbe    80103e01 <memmove+0x50>
    s += n;
    d += n;
80103dca:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103dcd:	eb 0d                	jmp    80103ddc <memmove+0x2b>
      *--d = *--s;
80103dcf:	83 eb 01             	sub    $0x1,%ebx
80103dd2:	83 e9 01             	sub    $0x1,%ecx
80103dd5:	0f b6 13             	movzbl (%ebx),%edx
80103dd8:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103dda:	89 f2                	mov    %esi,%edx
80103ddc:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ddf:	85 d2                	test   %edx,%edx
80103de1:	75 ec                	jne    80103dcf <memmove+0x1e>
80103de3:	eb 14                	jmp    80103df9 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103de5:	0f b6 11             	movzbl (%ecx),%edx
80103de8:	88 13                	mov    %dl,(%ebx)
80103dea:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103ded:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103df0:	89 f2                	mov    %esi,%edx
80103df2:	8d 72 ff             	lea    -0x1(%edx),%esi
80103df5:	85 d2                	test   %edx,%edx
80103df7:	75 ec                	jne    80103de5 <memmove+0x34>

  return dst;
}
80103df9:	5b                   	pop    %ebx
80103dfa:	5e                   	pop    %esi
80103dfb:	5d                   	pop    %ebp
80103dfc:	c3                   	ret    
80103dfd:	89 c3                	mov    %eax,%ebx
80103dff:	eb f1                	jmp    80103df2 <memmove+0x41>
80103e01:	89 c3                	mov    %eax,%ebx
80103e03:	eb ed                	jmp    80103df2 <memmove+0x41>

80103e05 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103e05:	55                   	push   %ebp
80103e06:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103e08:	ff 75 10             	pushl  0x10(%ebp)
80103e0b:	ff 75 0c             	pushl  0xc(%ebp)
80103e0e:	ff 75 08             	pushl  0x8(%ebp)
80103e11:	e8 9b ff ff ff       	call   80103db1 <memmove>
}
80103e16:	c9                   	leave  
80103e17:	c3                   	ret    

80103e18 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103e18:	55                   	push   %ebp
80103e19:	89 e5                	mov    %esp,%ebp
80103e1b:	53                   	push   %ebx
80103e1c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e22:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103e25:	eb 09                	jmp    80103e30 <strncmp+0x18>
    n--, p++, q++;
80103e27:	83 e8 01             	sub    $0x1,%eax
80103e2a:	83 c2 01             	add    $0x1,%edx
80103e2d:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103e30:	85 c0                	test   %eax,%eax
80103e32:	74 0b                	je     80103e3f <strncmp+0x27>
80103e34:	0f b6 1a             	movzbl (%edx),%ebx
80103e37:	84 db                	test   %bl,%bl
80103e39:	74 04                	je     80103e3f <strncmp+0x27>
80103e3b:	3a 19                	cmp    (%ecx),%bl
80103e3d:	74 e8                	je     80103e27 <strncmp+0xf>
  if(n == 0)
80103e3f:	85 c0                	test   %eax,%eax
80103e41:	74 0b                	je     80103e4e <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103e43:	0f b6 02             	movzbl (%edx),%eax
80103e46:	0f b6 11             	movzbl (%ecx),%edx
80103e49:	29 d0                	sub    %edx,%eax
}
80103e4b:	5b                   	pop    %ebx
80103e4c:	5d                   	pop    %ebp
80103e4d:	c3                   	ret    
    return 0;
80103e4e:	b8 00 00 00 00       	mov    $0x0,%eax
80103e53:	eb f6                	jmp    80103e4b <strncmp+0x33>

80103e55 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103e55:	55                   	push   %ebp
80103e56:	89 e5                	mov    %esp,%ebp
80103e58:	57                   	push   %edi
80103e59:	56                   	push   %esi
80103e5a:	53                   	push   %ebx
80103e5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103e61:	8b 45 08             	mov    0x8(%ebp),%eax
80103e64:	eb 04                	jmp    80103e6a <strncpy+0x15>
80103e66:	89 fb                	mov    %edi,%ebx
80103e68:	89 f0                	mov    %esi,%eax
80103e6a:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e6d:	85 c9                	test   %ecx,%ecx
80103e6f:	7e 1d                	jle    80103e8e <strncpy+0x39>
80103e71:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e74:	8d 70 01             	lea    0x1(%eax),%esi
80103e77:	0f b6 1b             	movzbl (%ebx),%ebx
80103e7a:	88 18                	mov    %bl,(%eax)
80103e7c:	89 d1                	mov    %edx,%ecx
80103e7e:	84 db                	test   %bl,%bl
80103e80:	75 e4                	jne    80103e66 <strncpy+0x11>
80103e82:	89 f0                	mov    %esi,%eax
80103e84:	eb 08                	jmp    80103e8e <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103e86:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103e89:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103e8b:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103e8e:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e91:	85 d2                	test   %edx,%edx
80103e93:	7f f1                	jg     80103e86 <strncpy+0x31>
  return os;
}
80103e95:	8b 45 08             	mov    0x8(%ebp),%eax
80103e98:	5b                   	pop    %ebx
80103e99:	5e                   	pop    %esi
80103e9a:	5f                   	pop    %edi
80103e9b:	5d                   	pop    %ebp
80103e9c:	c3                   	ret    

80103e9d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103e9d:	55                   	push   %ebp
80103e9e:	89 e5                	mov    %esp,%ebp
80103ea0:	57                   	push   %edi
80103ea1:	56                   	push   %esi
80103ea2:	53                   	push   %ebx
80103ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103ea9:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103eac:	85 d2                	test   %edx,%edx
80103eae:	7e 23                	jle    80103ed3 <safestrcpy+0x36>
80103eb0:	89 c1                	mov    %eax,%ecx
80103eb2:	eb 04                	jmp    80103eb8 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103eb4:	89 fb                	mov    %edi,%ebx
80103eb6:	89 f1                	mov    %esi,%ecx
80103eb8:	83 ea 01             	sub    $0x1,%edx
80103ebb:	85 d2                	test   %edx,%edx
80103ebd:	7e 11                	jle    80103ed0 <safestrcpy+0x33>
80103ebf:	8d 7b 01             	lea    0x1(%ebx),%edi
80103ec2:	8d 71 01             	lea    0x1(%ecx),%esi
80103ec5:	0f b6 1b             	movzbl (%ebx),%ebx
80103ec8:	88 19                	mov    %bl,(%ecx)
80103eca:	84 db                	test   %bl,%bl
80103ecc:	75 e6                	jne    80103eb4 <safestrcpy+0x17>
80103ece:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103ed0:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103ed3:	5b                   	pop    %ebx
80103ed4:	5e                   	pop    %esi
80103ed5:	5f                   	pop    %edi
80103ed6:	5d                   	pop    %ebp
80103ed7:	c3                   	ret    

80103ed8 <strlen>:

int
strlen(const char *s)
{
80103ed8:	55                   	push   %ebp
80103ed9:	89 e5                	mov    %esp,%ebp
80103edb:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103ede:	b8 00 00 00 00       	mov    $0x0,%eax
80103ee3:	eb 03                	jmp    80103ee8 <strlen+0x10>
80103ee5:	83 c0 01             	add    $0x1,%eax
80103ee8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103eec:	75 f7                	jne    80103ee5 <strlen+0xd>
    ;
  return n;
}
80103eee:	5d                   	pop    %ebp
80103eef:	c3                   	ret    

80103ef0 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103ef0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103ef4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103ef8:	55                   	push   %ebp
  pushl %ebx
80103ef9:	53                   	push   %ebx
  pushl %esi
80103efa:	56                   	push   %esi
  pushl %edi
80103efb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103efc:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103efe:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103f00:	5f                   	pop    %edi
  popl %esi
80103f01:	5e                   	pop    %esi
  popl %ebx
80103f02:	5b                   	pop    %ebx
  popl %ebp
80103f03:	5d                   	pop    %ebp
  ret
80103f04:	c3                   	ret    

80103f05 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103f05:	55                   	push   %ebp
80103f06:	89 e5                	mov    %esp,%ebp
80103f08:	53                   	push   %ebx
80103f09:	83 ec 04             	sub    $0x4,%esp
80103f0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103f0f:	e8 43 f3 ff ff       	call   80103257 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103f14:	8b 00                	mov    (%eax),%eax
80103f16:	39 d8                	cmp    %ebx,%eax
80103f18:	76 19                	jbe    80103f33 <fetchint+0x2e>
80103f1a:	8d 53 04             	lea    0x4(%ebx),%edx
80103f1d:	39 d0                	cmp    %edx,%eax
80103f1f:	72 19                	jb     80103f3a <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103f21:	8b 13                	mov    (%ebx),%edx
80103f23:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f26:	89 10                	mov    %edx,(%eax)
  return 0;
80103f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f2d:	83 c4 04             	add    $0x4,%esp
80103f30:	5b                   	pop    %ebx
80103f31:	5d                   	pop    %ebp
80103f32:	c3                   	ret    
    return -1;
80103f33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f38:	eb f3                	jmp    80103f2d <fetchint+0x28>
80103f3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3f:	eb ec                	jmp    80103f2d <fetchint+0x28>

80103f41 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103f41:	55                   	push   %ebp
80103f42:	89 e5                	mov    %esp,%ebp
80103f44:	53                   	push   %ebx
80103f45:	83 ec 04             	sub    $0x4,%esp
80103f48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f4b:	e8 07 f3 ff ff       	call   80103257 <myproc>

  if(addr >= curproc->sz)
80103f50:	39 18                	cmp    %ebx,(%eax)
80103f52:	76 26                	jbe    80103f7a <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103f54:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f57:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f59:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103f5b:	89 d8                	mov    %ebx,%eax
80103f5d:	39 d0                	cmp    %edx,%eax
80103f5f:	73 0e                	jae    80103f6f <fetchstr+0x2e>
    if(*s == 0)
80103f61:	80 38 00             	cmpb   $0x0,(%eax)
80103f64:	74 05                	je     80103f6b <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103f66:	83 c0 01             	add    $0x1,%eax
80103f69:	eb f2                	jmp    80103f5d <fetchstr+0x1c>
      return s - *pp;
80103f6b:	29 d8                	sub    %ebx,%eax
80103f6d:	eb 05                	jmp    80103f74 <fetchstr+0x33>
  }
  return -1;
80103f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f74:	83 c4 04             	add    $0x4,%esp
80103f77:	5b                   	pop    %ebx
80103f78:	5d                   	pop    %ebp
80103f79:	c3                   	ret    
    return -1;
80103f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f7f:	eb f3                	jmp    80103f74 <fetchstr+0x33>

80103f81 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f81:	55                   	push   %ebp
80103f82:	89 e5                	mov    %esp,%ebp
80103f84:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f87:	e8 cb f2 ff ff       	call   80103257 <myproc>
80103f8c:	8b 50 18             	mov    0x18(%eax),%edx
80103f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f92:	c1 e0 02             	shl    $0x2,%eax
80103f95:	03 42 44             	add    0x44(%edx),%eax
80103f98:	83 ec 08             	sub    $0x8,%esp
80103f9b:	ff 75 0c             	pushl  0xc(%ebp)
80103f9e:	83 c0 04             	add    $0x4,%eax
80103fa1:	50                   	push   %eax
80103fa2:	e8 5e ff ff ff       	call   80103f05 <fetchint>
}
80103fa7:	c9                   	leave  
80103fa8:	c3                   	ret    

80103fa9 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103fa9:	55                   	push   %ebp
80103faa:	89 e5                	mov    %esp,%ebp
80103fac:	56                   	push   %esi
80103fad:	53                   	push   %ebx
80103fae:	83 ec 10             	sub    $0x10,%esp
80103fb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103fb4:	e8 9e f2 ff ff       	call   80103257 <myproc>
80103fb9:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103fbb:	83 ec 08             	sub    $0x8,%esp
80103fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fc1:	50                   	push   %eax
80103fc2:	ff 75 08             	pushl  0x8(%ebp)
80103fc5:	e8 b7 ff ff ff       	call   80103f81 <argint>
80103fca:	83 c4 10             	add    $0x10,%esp
80103fcd:	85 c0                	test   %eax,%eax
80103fcf:	78 24                	js     80103ff5 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103fd1:	85 db                	test   %ebx,%ebx
80103fd3:	78 27                	js     80103ffc <argptr+0x53>
80103fd5:	8b 16                	mov    (%esi),%edx
80103fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fda:	39 c2                	cmp    %eax,%edx
80103fdc:	76 25                	jbe    80104003 <argptr+0x5a>
80103fde:	01 c3                	add    %eax,%ebx
80103fe0:	39 da                	cmp    %ebx,%edx
80103fe2:	72 26                	jb     8010400a <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fe7:	89 02                	mov    %eax,(%edx)
  return 0;
80103fe9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fee:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ff1:	5b                   	pop    %ebx
80103ff2:	5e                   	pop    %esi
80103ff3:	5d                   	pop    %ebp
80103ff4:	c3                   	ret    
    return -1;
80103ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffa:	eb f2                	jmp    80103fee <argptr+0x45>
    return -1;
80103ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104001:	eb eb                	jmp    80103fee <argptr+0x45>
80104003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104008:	eb e4                	jmp    80103fee <argptr+0x45>
8010400a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010400f:	eb dd                	jmp    80103fee <argptr+0x45>

80104011 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104011:	55                   	push   %ebp
80104012:	89 e5                	mov    %esp,%ebp
80104014:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104017:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010401a:	50                   	push   %eax
8010401b:	ff 75 08             	pushl  0x8(%ebp)
8010401e:	e8 5e ff ff ff       	call   80103f81 <argint>
80104023:	83 c4 10             	add    $0x10,%esp
80104026:	85 c0                	test   %eax,%eax
80104028:	78 13                	js     8010403d <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
8010402a:	83 ec 08             	sub    $0x8,%esp
8010402d:	ff 75 0c             	pushl  0xc(%ebp)
80104030:	ff 75 f4             	pushl  -0xc(%ebp)
80104033:	e8 09 ff ff ff       	call   80103f41 <fetchstr>
80104038:	83 c4 10             	add    $0x10,%esp
}
8010403b:	c9                   	leave  
8010403c:	c3                   	ret    
    return -1;
8010403d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104042:	eb f7                	jmp    8010403b <argstr+0x2a>

80104044 <syscall>:
[SYS_getprocessesinfo] sys_getprocessesinfo,
};

void
syscall(void)
{
80104044:	55                   	push   %ebp
80104045:	89 e5                	mov    %esp,%ebp
80104047:	53                   	push   %ebx
80104048:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010404b:	e8 07 f2 ff ff       	call   80103257 <myproc>
80104050:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104052:	8b 40 18             	mov    0x18(%eax),%eax
80104055:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104058:	8d 50 ff             	lea    -0x1(%eax),%edx
8010405b:	83 fa 1a             	cmp    $0x1a,%edx
8010405e:	77 18                	ja     80104078 <syscall+0x34>
80104060:	8b 14 85 80 6e 10 80 	mov    -0x7fef9180(,%eax,4),%edx
80104067:	85 d2                	test   %edx,%edx
80104069:	74 0d                	je     80104078 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
8010406b:	ff d2                	call   *%edx
8010406d:	8b 53 18             	mov    0x18(%ebx),%edx
80104070:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104076:	c9                   	leave  
80104077:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104078:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010407b:	50                   	push   %eax
8010407c:	52                   	push   %edx
8010407d:	ff 73 10             	pushl  0x10(%ebx)
80104080:	68 49 6e 10 80       	push   $0x80106e49
80104085:	e8 81 c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
8010408a:	8b 43 18             	mov    0x18(%ebx),%eax
8010408d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104094:	83 c4 10             	add    $0x10,%esp
}
80104097:	eb da                	jmp    80104073 <syscall+0x2f>

80104099 <argfd>:
uint writeCount_global;
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104099:	55                   	push   %ebp
8010409a:	89 e5                	mov    %esp,%ebp
8010409c:	56                   	push   %esi
8010409d:	53                   	push   %ebx
8010409e:	83 ec 18             	sub    $0x18,%esp
801040a1:	89 d6                	mov    %edx,%esi
801040a3:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801040a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
801040a8:	52                   	push   %edx
801040a9:	50                   	push   %eax
801040aa:	e8 d2 fe ff ff       	call   80103f81 <argint>
801040af:	83 c4 10             	add    $0x10,%esp
801040b2:	85 c0                	test   %eax,%eax
801040b4:	78 2e                	js     801040e4 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801040b6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040ba:	77 2f                	ja     801040eb <argfd+0x52>
801040bc:	e8 96 f1 ff ff       	call   80103257 <myproc>
801040c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040c4:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801040c8:	85 c0                	test   %eax,%eax
801040ca:	74 26                	je     801040f2 <argfd+0x59>
    return -1;
  if(pfd)
801040cc:	85 f6                	test   %esi,%esi
801040ce:	74 02                	je     801040d2 <argfd+0x39>
    *pfd = fd;
801040d0:	89 16                	mov    %edx,(%esi)
  if(pf)
801040d2:	85 db                	test   %ebx,%ebx
801040d4:	74 23                	je     801040f9 <argfd+0x60>
    *pf = f;
801040d6:	89 03                	mov    %eax,(%ebx)
  return 0;
801040d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040e0:	5b                   	pop    %ebx
801040e1:	5e                   	pop    %esi
801040e2:	5d                   	pop    %ebp
801040e3:	c3                   	ret    
    return -1;
801040e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e9:	eb f2                	jmp    801040dd <argfd+0x44>
    return -1;
801040eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f0:	eb eb                	jmp    801040dd <argfd+0x44>
801040f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f7:	eb e4                	jmp    801040dd <argfd+0x44>
  return 0;
801040f9:	b8 00 00 00 00       	mov    $0x0,%eax
801040fe:	eb dd                	jmp    801040dd <argfd+0x44>

80104100 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104100:	55                   	push   %ebp
80104101:	89 e5                	mov    %esp,%ebp
80104103:	53                   	push   %ebx
80104104:	83 ec 04             	sub    $0x4,%esp
80104107:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104109:	e8 49 f1 ff ff       	call   80103257 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
8010410e:	ba 00 00 00 00       	mov    $0x0,%edx
80104113:	83 fa 0f             	cmp    $0xf,%edx
80104116:	7f 18                	jg     80104130 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
80104118:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
8010411d:	74 05                	je     80104124 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
8010411f:	83 c2 01             	add    $0x1,%edx
80104122:	eb ef                	jmp    80104113 <fdalloc+0x13>
      curproc->ofile[fd] = f;
80104124:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
80104128:	89 d0                	mov    %edx,%eax
8010412a:	83 c4 04             	add    $0x4,%esp
8010412d:	5b                   	pop    %ebx
8010412e:	5d                   	pop    %ebp
8010412f:	c3                   	ret    
  return -1;
80104130:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80104135:	eb f1                	jmp    80104128 <fdalloc+0x28>

80104137 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104137:	55                   	push   %ebp
80104138:	89 e5                	mov    %esp,%ebp
8010413a:	56                   	push   %esi
8010413b:	53                   	push   %ebx
8010413c:	83 ec 10             	sub    $0x10,%esp
8010413f:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104141:	b8 20 00 00 00       	mov    $0x20,%eax
80104146:	89 c6                	mov    %eax,%esi
80104148:	39 43 58             	cmp    %eax,0x58(%ebx)
8010414b:	76 2e                	jbe    8010417b <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010414d:	6a 10                	push   $0x10
8010414f:	50                   	push   %eax
80104150:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104153:	50                   	push   %eax
80104154:	53                   	push   %ebx
80104155:	e8 07 d6 ff ff       	call   80101761 <readi>
8010415a:	83 c4 10             	add    $0x10,%esp
8010415d:	83 f8 10             	cmp    $0x10,%eax
80104160:	75 0c                	jne    8010416e <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104162:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104167:	75 1e                	jne    80104187 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104169:	8d 46 10             	lea    0x10(%esi),%eax
8010416c:	eb d8                	jmp    80104146 <isdirempty+0xf>
      panic("isdirempty: readi");
8010416e:	83 ec 0c             	sub    $0xc,%esp
80104171:	68 f0 6e 10 80       	push   $0x80106ef0
80104176:	e8 cd c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
8010417b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104180:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104183:	5b                   	pop    %ebx
80104184:	5e                   	pop    %esi
80104185:	5d                   	pop    %ebp
80104186:	c3                   	ret    
      return 0;
80104187:	b8 00 00 00 00       	mov    $0x0,%eax
8010418c:	eb f2                	jmp    80104180 <isdirempty+0x49>

8010418e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
8010418e:	55                   	push   %ebp
8010418f:	89 e5                	mov    %esp,%ebp
80104191:	57                   	push   %edi
80104192:	56                   	push   %esi
80104193:	53                   	push   %ebx
80104194:	83 ec 34             	sub    $0x34,%esp
80104197:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010419a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010419d:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801041a0:	8d 55 da             	lea    -0x26(%ebp),%edx
801041a3:	52                   	push   %edx
801041a4:	50                   	push   %eax
801041a5:	e8 3d da ff ff       	call   80101be7 <nameiparent>
801041aa:	89 c6                	mov    %eax,%esi
801041ac:	83 c4 10             	add    $0x10,%esp
801041af:	85 c0                	test   %eax,%eax
801041b1:	0f 84 38 01 00 00    	je     801042ef <create+0x161>
    return 0;
  ilock(dp);
801041b7:	83 ec 0c             	sub    $0xc,%esp
801041ba:	50                   	push   %eax
801041bb:	e8 af d3 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801041c0:	83 c4 0c             	add    $0xc,%esp
801041c3:	6a 00                	push   $0x0
801041c5:	8d 45 da             	lea    -0x26(%ebp),%eax
801041c8:	50                   	push   %eax
801041c9:	56                   	push   %esi
801041ca:	e8 cf d7 ff ff       	call   8010199e <dirlookup>
801041cf:	89 c3                	mov    %eax,%ebx
801041d1:	83 c4 10             	add    $0x10,%esp
801041d4:	85 c0                	test   %eax,%eax
801041d6:	74 3f                	je     80104217 <create+0x89>
    iunlockput(dp);
801041d8:	83 ec 0c             	sub    $0xc,%esp
801041db:	56                   	push   %esi
801041dc:	e8 35 d5 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
801041e1:	89 1c 24             	mov    %ebx,(%esp)
801041e4:	e8 86 d3 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801041e9:	83 c4 10             	add    $0x10,%esp
801041ec:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801041f1:	75 11                	jne    80104204 <create+0x76>
801041f3:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041f8:	75 0a                	jne    80104204 <create+0x76>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041fa:	89 d8                	mov    %ebx,%eax
801041fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801041ff:	5b                   	pop    %ebx
80104200:	5e                   	pop    %esi
80104201:	5f                   	pop    %edi
80104202:	5d                   	pop    %ebp
80104203:	c3                   	ret    
    iunlockput(ip);
80104204:	83 ec 0c             	sub    $0xc,%esp
80104207:	53                   	push   %ebx
80104208:	e8 09 d5 ff ff       	call   80101716 <iunlockput>
    return 0;
8010420d:	83 c4 10             	add    $0x10,%esp
80104210:	bb 00 00 00 00       	mov    $0x0,%ebx
80104215:	eb e3                	jmp    801041fa <create+0x6c>
  if((ip = ialloc(dp->dev, type)) == 0)
80104217:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
8010421b:	83 ec 08             	sub    $0x8,%esp
8010421e:	50                   	push   %eax
8010421f:	ff 36                	pushl  (%esi)
80104221:	e8 46 d1 ff ff       	call   8010136c <ialloc>
80104226:	89 c3                	mov    %eax,%ebx
80104228:	83 c4 10             	add    $0x10,%esp
8010422b:	85 c0                	test   %eax,%eax
8010422d:	74 55                	je     80104284 <create+0xf6>
  ilock(ip);
8010422f:	83 ec 0c             	sub    $0xc,%esp
80104232:	50                   	push   %eax
80104233:	e8 37 d3 ff ff       	call   8010156f <ilock>
  ip->major = major;
80104238:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
8010423c:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104240:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104244:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
8010424a:	89 1c 24             	mov    %ebx,(%esp)
8010424d:	e8 bc d1 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104252:	83 c4 10             	add    $0x10,%esp
80104255:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010425a:	74 35                	je     80104291 <create+0x103>
  if(dirlink(dp, name, ip->inum) < 0)
8010425c:	83 ec 04             	sub    $0x4,%esp
8010425f:	ff 73 04             	pushl  0x4(%ebx)
80104262:	8d 45 da             	lea    -0x26(%ebp),%eax
80104265:	50                   	push   %eax
80104266:	56                   	push   %esi
80104267:	e8 b2 d8 ff ff       	call   80101b1e <dirlink>
8010426c:	83 c4 10             	add    $0x10,%esp
8010426f:	85 c0                	test   %eax,%eax
80104271:	78 6f                	js     801042e2 <create+0x154>
  iunlockput(dp);
80104273:	83 ec 0c             	sub    $0xc,%esp
80104276:	56                   	push   %esi
80104277:	e8 9a d4 ff ff       	call   80101716 <iunlockput>
  return ip;
8010427c:	83 c4 10             	add    $0x10,%esp
8010427f:	e9 76 ff ff ff       	jmp    801041fa <create+0x6c>
    panic("create: ialloc");
80104284:	83 ec 0c             	sub    $0xc,%esp
80104287:	68 02 6f 10 80       	push   $0x80106f02
8010428c:	e8 b7 c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104291:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104295:	83 c0 01             	add    $0x1,%eax
80104298:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010429c:	83 ec 0c             	sub    $0xc,%esp
8010429f:	56                   	push   %esi
801042a0:	e8 69 d1 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801042a5:	83 c4 0c             	add    $0xc,%esp
801042a8:	ff 73 04             	pushl  0x4(%ebx)
801042ab:	68 12 6f 10 80       	push   $0x80106f12
801042b0:	53                   	push   %ebx
801042b1:	e8 68 d8 ff ff       	call   80101b1e <dirlink>
801042b6:	83 c4 10             	add    $0x10,%esp
801042b9:	85 c0                	test   %eax,%eax
801042bb:	78 18                	js     801042d5 <create+0x147>
801042bd:	83 ec 04             	sub    $0x4,%esp
801042c0:	ff 76 04             	pushl  0x4(%esi)
801042c3:	68 11 6f 10 80       	push   $0x80106f11
801042c8:	53                   	push   %ebx
801042c9:	e8 50 d8 ff ff       	call   80101b1e <dirlink>
801042ce:	83 c4 10             	add    $0x10,%esp
801042d1:	85 c0                	test   %eax,%eax
801042d3:	79 87                	jns    8010425c <create+0xce>
      panic("create dots");
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	68 14 6f 10 80       	push   $0x80106f14
801042dd:	e8 66 c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801042e2:	83 ec 0c             	sub    $0xc,%esp
801042e5:	68 20 6f 10 80       	push   $0x80106f20
801042ea:	e8 59 c0 ff ff       	call   80100348 <panic>
    return 0;
801042ef:	89 c3                	mov    %eax,%ebx
801042f1:	e9 04 ff ff ff       	jmp    801041fa <create+0x6c>

801042f6 <sys_dup>:
{
801042f6:	55                   	push   %ebp
801042f7:	89 e5                	mov    %esp,%ebp
801042f9:	53                   	push   %ebx
801042fa:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042fd:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104300:	ba 00 00 00 00       	mov    $0x0,%edx
80104305:	b8 00 00 00 00       	mov    $0x0,%eax
8010430a:	e8 8a fd ff ff       	call   80104099 <argfd>
8010430f:	85 c0                	test   %eax,%eax
80104311:	78 23                	js     80104336 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104316:	e8 e5 fd ff ff       	call   80104100 <fdalloc>
8010431b:	89 c3                	mov    %eax,%ebx
8010431d:	85 c0                	test   %eax,%eax
8010431f:	78 1c                	js     8010433d <sys_dup+0x47>
  filedup(f);
80104321:	83 ec 0c             	sub    $0xc,%esp
80104324:	ff 75 f4             	pushl  -0xc(%ebp)
80104327:	e8 62 c9 ff ff       	call   80100c8e <filedup>
  return fd;
8010432c:	83 c4 10             	add    $0x10,%esp
}
8010432f:	89 d8                	mov    %ebx,%eax
80104331:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104334:	c9                   	leave  
80104335:	c3                   	ret    
    return -1;
80104336:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010433b:	eb f2                	jmp    8010432f <sys_dup+0x39>
    return -1;
8010433d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104342:	eb eb                	jmp    8010432f <sys_dup+0x39>

80104344 <sys_read>:
{
80104344:	55                   	push   %ebp
80104345:	89 e5                	mov    %esp,%ebp
80104347:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010434a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010434d:	ba 00 00 00 00       	mov    $0x0,%edx
80104352:	b8 00 00 00 00       	mov    $0x0,%eax
80104357:	e8 3d fd ff ff       	call   80104099 <argfd>
8010435c:	85 c0                	test   %eax,%eax
8010435e:	78 43                	js     801043a3 <sys_read+0x5f>
80104360:	83 ec 08             	sub    $0x8,%esp
80104363:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104366:	50                   	push   %eax
80104367:	6a 02                	push   $0x2
80104369:	e8 13 fc ff ff       	call   80103f81 <argint>
8010436e:	83 c4 10             	add    $0x10,%esp
80104371:	85 c0                	test   %eax,%eax
80104373:	78 35                	js     801043aa <sys_read+0x66>
80104375:	83 ec 04             	sub    $0x4,%esp
80104378:	ff 75 f0             	pushl  -0x10(%ebp)
8010437b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010437e:	50                   	push   %eax
8010437f:	6a 01                	push   $0x1
80104381:	e8 23 fc ff ff       	call   80103fa9 <argptr>
80104386:	83 c4 10             	add    $0x10,%esp
80104389:	85 c0                	test   %eax,%eax
8010438b:	78 24                	js     801043b1 <sys_read+0x6d>
  return fileread(f, p, n);
8010438d:	83 ec 04             	sub    $0x4,%esp
80104390:	ff 75 f0             	pushl  -0x10(%ebp)
80104393:	ff 75 ec             	pushl  -0x14(%ebp)
80104396:	ff 75 f4             	pushl  -0xc(%ebp)
80104399:	e8 39 ca ff ff       	call   80100dd7 <fileread>
8010439e:	83 c4 10             	add    $0x10,%esp
}
801043a1:	c9                   	leave  
801043a2:	c3                   	ret    
    return -1;
801043a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a8:	eb f7                	jmp    801043a1 <sys_read+0x5d>
801043aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043af:	eb f0                	jmp    801043a1 <sys_read+0x5d>
801043b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b6:	eb e9                	jmp    801043a1 <sys_read+0x5d>

801043b8 <sys_write>:
{
801043b8:	55                   	push   %ebp
801043b9:	89 e5                	mov    %esp,%ebp
801043bb:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043be:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043c1:	ba 00 00 00 00       	mov    $0x0,%edx
801043c6:	b8 00 00 00 00       	mov    $0x0,%eax
801043cb:	e8 c9 fc ff ff       	call   80104099 <argfd>
801043d0:	85 c0                	test   %eax,%eax
801043d2:	78 4a                	js     8010441e <sys_write+0x66>
801043d4:	83 ec 08             	sub    $0x8,%esp
801043d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043da:	50                   	push   %eax
801043db:	6a 02                	push   $0x2
801043dd:	e8 9f fb ff ff       	call   80103f81 <argint>
801043e2:	83 c4 10             	add    $0x10,%esp
801043e5:	85 c0                	test   %eax,%eax
801043e7:	78 3c                	js     80104425 <sys_write+0x6d>
801043e9:	83 ec 04             	sub    $0x4,%esp
801043ec:	ff 75 f0             	pushl  -0x10(%ebp)
801043ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043f2:	50                   	push   %eax
801043f3:	6a 01                	push   $0x1
801043f5:	e8 af fb ff ff       	call   80103fa9 <argptr>
801043fa:	83 c4 10             	add    $0x10,%esp
801043fd:	85 c0                	test   %eax,%eax
801043ff:	78 2b                	js     8010442c <sys_write+0x74>
      writeCount_global++;
80104401:	83 05 54 4e 11 80 01 	addl   $0x1,0x80114e54
  return filewrite(f, p, n);
80104408:	83 ec 04             	sub    $0x4,%esp
8010440b:	ff 75 f0             	pushl  -0x10(%ebp)
8010440e:	ff 75 ec             	pushl  -0x14(%ebp)
80104411:	ff 75 f4             	pushl  -0xc(%ebp)
80104414:	e8 43 ca ff ff       	call   80100e5c <filewrite>
80104419:	83 c4 10             	add    $0x10,%esp
}
8010441c:	c9                   	leave  
8010441d:	c3                   	ret    
    return -1;
8010441e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104423:	eb f7                	jmp    8010441c <sys_write+0x64>
80104425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010442a:	eb f0                	jmp    8010441c <sys_write+0x64>
8010442c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104431:	eb e9                	jmp    8010441c <sys_write+0x64>

80104433 <sys_close>:
{
80104433:	55                   	push   %ebp
80104434:	89 e5                	mov    %esp,%ebp
80104436:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104439:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010443c:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010443f:	b8 00 00 00 00       	mov    $0x0,%eax
80104444:	e8 50 fc ff ff       	call   80104099 <argfd>
80104449:	85 c0                	test   %eax,%eax
8010444b:	78 25                	js     80104472 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010444d:	e8 05 ee ff ff       	call   80103257 <myproc>
80104452:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104455:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010445c:	00 
  fileclose(f);
8010445d:	83 ec 0c             	sub    $0xc,%esp
80104460:	ff 75 f0             	pushl  -0x10(%ebp)
80104463:	e8 6b c8 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104468:	83 c4 10             	add    $0x10,%esp
8010446b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104470:	c9                   	leave  
80104471:	c3                   	ret    
    return -1;
80104472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104477:	eb f7                	jmp    80104470 <sys_close+0x3d>

80104479 <sys_fstat>:
{
80104479:	55                   	push   %ebp
8010447a:	89 e5                	mov    %esp,%ebp
8010447c:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010447f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104482:	ba 00 00 00 00       	mov    $0x0,%edx
80104487:	b8 00 00 00 00       	mov    $0x0,%eax
8010448c:	e8 08 fc ff ff       	call   80104099 <argfd>
80104491:	85 c0                	test   %eax,%eax
80104493:	78 2a                	js     801044bf <sys_fstat+0x46>
80104495:	83 ec 04             	sub    $0x4,%esp
80104498:	6a 14                	push   $0x14
8010449a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010449d:	50                   	push   %eax
8010449e:	6a 01                	push   $0x1
801044a0:	e8 04 fb ff ff       	call   80103fa9 <argptr>
801044a5:	83 c4 10             	add    $0x10,%esp
801044a8:	85 c0                	test   %eax,%eax
801044aa:	78 1a                	js     801044c6 <sys_fstat+0x4d>
  return filestat(f, st);
801044ac:	83 ec 08             	sub    $0x8,%esp
801044af:	ff 75 f0             	pushl  -0x10(%ebp)
801044b2:	ff 75 f4             	pushl  -0xc(%ebp)
801044b5:	e8 d6 c8 ff ff       	call   80100d90 <filestat>
801044ba:	83 c4 10             	add    $0x10,%esp
}
801044bd:	c9                   	leave  
801044be:	c3                   	ret    
    return -1;
801044bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c4:	eb f7                	jmp    801044bd <sys_fstat+0x44>
801044c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044cb:	eb f0                	jmp    801044bd <sys_fstat+0x44>

801044cd <sys_link>:
{
801044cd:	55                   	push   %ebp
801044ce:	89 e5                	mov    %esp,%ebp
801044d0:	56                   	push   %esi
801044d1:	53                   	push   %ebx
801044d2:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801044d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044d8:	50                   	push   %eax
801044d9:	6a 00                	push   $0x0
801044db:	e8 31 fb ff ff       	call   80104011 <argstr>
801044e0:	83 c4 10             	add    $0x10,%esp
801044e3:	85 c0                	test   %eax,%eax
801044e5:	0f 88 32 01 00 00    	js     8010461d <sys_link+0x150>
801044eb:	83 ec 08             	sub    $0x8,%esp
801044ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801044f1:	50                   	push   %eax
801044f2:	6a 01                	push   $0x1
801044f4:	e8 18 fb ff ff       	call   80104011 <argstr>
801044f9:	83 c4 10             	add    $0x10,%esp
801044fc:	85 c0                	test   %eax,%eax
801044fe:	0f 88 20 01 00 00    	js     80104624 <sys_link+0x157>
  begin_op();
80104504:	e8 c9 e2 ff ff       	call   801027d2 <begin_op>
  if((ip = namei(old)) == 0){
80104509:	83 ec 0c             	sub    $0xc,%esp
8010450c:	ff 75 e0             	pushl  -0x20(%ebp)
8010450f:	e8 bb d6 ff ff       	call   80101bcf <namei>
80104514:	89 c3                	mov    %eax,%ebx
80104516:	83 c4 10             	add    $0x10,%esp
80104519:	85 c0                	test   %eax,%eax
8010451b:	0f 84 99 00 00 00    	je     801045ba <sys_link+0xed>
  ilock(ip);
80104521:	83 ec 0c             	sub    $0xc,%esp
80104524:	50                   	push   %eax
80104525:	e8 45 d0 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
8010452a:	83 c4 10             	add    $0x10,%esp
8010452d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104532:	0f 84 8e 00 00 00    	je     801045c6 <sys_link+0xf9>
  ip->nlink++;
80104538:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010453c:	83 c0 01             	add    $0x1,%eax
8010453f:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104543:	83 ec 0c             	sub    $0xc,%esp
80104546:	53                   	push   %ebx
80104547:	e8 c2 ce ff ff       	call   8010140e <iupdate>
  iunlock(ip);
8010454c:	89 1c 24             	mov    %ebx,(%esp)
8010454f:	e8 dd d0 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104554:	83 c4 08             	add    $0x8,%esp
80104557:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010455a:	50                   	push   %eax
8010455b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010455e:	e8 84 d6 ff ff       	call   80101be7 <nameiparent>
80104563:	89 c6                	mov    %eax,%esi
80104565:	83 c4 10             	add    $0x10,%esp
80104568:	85 c0                	test   %eax,%eax
8010456a:	74 7e                	je     801045ea <sys_link+0x11d>
  ilock(dp);
8010456c:	83 ec 0c             	sub    $0xc,%esp
8010456f:	50                   	push   %eax
80104570:	e8 fa cf ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104575:	83 c4 10             	add    $0x10,%esp
80104578:	8b 03                	mov    (%ebx),%eax
8010457a:	39 06                	cmp    %eax,(%esi)
8010457c:	75 60                	jne    801045de <sys_link+0x111>
8010457e:	83 ec 04             	sub    $0x4,%esp
80104581:	ff 73 04             	pushl  0x4(%ebx)
80104584:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104587:	50                   	push   %eax
80104588:	56                   	push   %esi
80104589:	e8 90 d5 ff ff       	call   80101b1e <dirlink>
8010458e:	83 c4 10             	add    $0x10,%esp
80104591:	85 c0                	test   %eax,%eax
80104593:	78 49                	js     801045de <sys_link+0x111>
  iunlockput(dp);
80104595:	83 ec 0c             	sub    $0xc,%esp
80104598:	56                   	push   %esi
80104599:	e8 78 d1 ff ff       	call   80101716 <iunlockput>
  iput(ip);
8010459e:	89 1c 24             	mov    %ebx,(%esp)
801045a1:	e8 d0 d0 ff ff       	call   80101676 <iput>
  end_op();
801045a6:	e8 a1 e2 ff ff       	call   8010284c <end_op>
  return 0;
801045ab:	83 c4 10             	add    $0x10,%esp
801045ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801045b6:	5b                   	pop    %ebx
801045b7:	5e                   	pop    %esi
801045b8:	5d                   	pop    %ebp
801045b9:	c3                   	ret    
    end_op();
801045ba:	e8 8d e2 ff ff       	call   8010284c <end_op>
    return -1;
801045bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c4:	eb ed                	jmp    801045b3 <sys_link+0xe6>
    iunlockput(ip);
801045c6:	83 ec 0c             	sub    $0xc,%esp
801045c9:	53                   	push   %ebx
801045ca:	e8 47 d1 ff ff       	call   80101716 <iunlockput>
    end_op();
801045cf:	e8 78 e2 ff ff       	call   8010284c <end_op>
    return -1;
801045d4:	83 c4 10             	add    $0x10,%esp
801045d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045dc:	eb d5                	jmp    801045b3 <sys_link+0xe6>
    iunlockput(dp);
801045de:	83 ec 0c             	sub    $0xc,%esp
801045e1:	56                   	push   %esi
801045e2:	e8 2f d1 ff ff       	call   80101716 <iunlockput>
    goto bad;
801045e7:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	53                   	push   %ebx
801045ee:	e8 7c cf ff ff       	call   8010156f <ilock>
  ip->nlink--;
801045f3:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045f7:	83 e8 01             	sub    $0x1,%eax
801045fa:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045fe:	89 1c 24             	mov    %ebx,(%esp)
80104601:	e8 08 ce ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104606:	89 1c 24             	mov    %ebx,(%esp)
80104609:	e8 08 d1 ff ff       	call   80101716 <iunlockput>
  end_op();
8010460e:	e8 39 e2 ff ff       	call   8010284c <end_op>
  return -1;
80104613:	83 c4 10             	add    $0x10,%esp
80104616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010461b:	eb 96                	jmp    801045b3 <sys_link+0xe6>
    return -1;
8010461d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104622:	eb 8f                	jmp    801045b3 <sys_link+0xe6>
80104624:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104629:	eb 88                	jmp    801045b3 <sys_link+0xe6>

8010462b <sys_unlink>:
{
8010462b:	55                   	push   %ebp
8010462c:	89 e5                	mov    %esp,%ebp
8010462e:	57                   	push   %edi
8010462f:	56                   	push   %esi
80104630:	53                   	push   %ebx
80104631:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104634:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104637:	50                   	push   %eax
80104638:	6a 00                	push   $0x0
8010463a:	e8 d2 f9 ff ff       	call   80104011 <argstr>
8010463f:	83 c4 10             	add    $0x10,%esp
80104642:	85 c0                	test   %eax,%eax
80104644:	0f 88 83 01 00 00    	js     801047cd <sys_unlink+0x1a2>
  begin_op();
8010464a:	e8 83 e1 ff ff       	call   801027d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010464f:	83 ec 08             	sub    $0x8,%esp
80104652:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104655:	50                   	push   %eax
80104656:	ff 75 c4             	pushl  -0x3c(%ebp)
80104659:	e8 89 d5 ff ff       	call   80101be7 <nameiparent>
8010465e:	89 c6                	mov    %eax,%esi
80104660:	83 c4 10             	add    $0x10,%esp
80104663:	85 c0                	test   %eax,%eax
80104665:	0f 84 ed 00 00 00    	je     80104758 <sys_unlink+0x12d>
  ilock(dp);
8010466b:	83 ec 0c             	sub    $0xc,%esp
8010466e:	50                   	push   %eax
8010466f:	e8 fb ce ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104674:	83 c4 08             	add    $0x8,%esp
80104677:	68 12 6f 10 80       	push   $0x80106f12
8010467c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010467f:	50                   	push   %eax
80104680:	e8 04 d3 ff ff       	call   80101989 <namecmp>
80104685:	83 c4 10             	add    $0x10,%esp
80104688:	85 c0                	test   %eax,%eax
8010468a:	0f 84 fc 00 00 00    	je     8010478c <sys_unlink+0x161>
80104690:	83 ec 08             	sub    $0x8,%esp
80104693:	68 11 6f 10 80       	push   $0x80106f11
80104698:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010469b:	50                   	push   %eax
8010469c:	e8 e8 d2 ff ff       	call   80101989 <namecmp>
801046a1:	83 c4 10             	add    $0x10,%esp
801046a4:	85 c0                	test   %eax,%eax
801046a6:	0f 84 e0 00 00 00    	je     8010478c <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
801046ac:	83 ec 04             	sub    $0x4,%esp
801046af:	8d 45 c0             	lea    -0x40(%ebp),%eax
801046b2:	50                   	push   %eax
801046b3:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046b6:	50                   	push   %eax
801046b7:	56                   	push   %esi
801046b8:	e8 e1 d2 ff ff       	call   8010199e <dirlookup>
801046bd:	89 c3                	mov    %eax,%ebx
801046bf:	83 c4 10             	add    $0x10,%esp
801046c2:	85 c0                	test   %eax,%eax
801046c4:	0f 84 c2 00 00 00    	je     8010478c <sys_unlink+0x161>
  ilock(ip);
801046ca:	83 ec 0c             	sub    $0xc,%esp
801046cd:	50                   	push   %eax
801046ce:	e8 9c ce ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
801046d3:	83 c4 10             	add    $0x10,%esp
801046d6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801046db:	0f 8e 83 00 00 00    	jle    80104764 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801046e1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046e6:	0f 84 85 00 00 00    	je     80104771 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801046ec:	83 ec 04             	sub    $0x4,%esp
801046ef:	6a 10                	push   $0x10
801046f1:	6a 00                	push   $0x0
801046f3:	8d 7d d8             	lea    -0x28(%ebp),%edi
801046f6:	57                   	push   %edi
801046f7:	e8 3a f6 ff ff       	call   80103d36 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046fc:	6a 10                	push   $0x10
801046fe:	ff 75 c0             	pushl  -0x40(%ebp)
80104701:	57                   	push   %edi
80104702:	56                   	push   %esi
80104703:	e8 56 d1 ff ff       	call   8010185e <writei>
80104708:	83 c4 20             	add    $0x20,%esp
8010470b:	83 f8 10             	cmp    $0x10,%eax
8010470e:	0f 85 90 00 00 00    	jne    801047a4 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104714:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104719:	0f 84 92 00 00 00    	je     801047b1 <sys_unlink+0x186>
  iunlockput(dp);
8010471f:	83 ec 0c             	sub    $0xc,%esp
80104722:	56                   	push   %esi
80104723:	e8 ee cf ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80104728:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010472c:	83 e8 01             	sub    $0x1,%eax
8010472f:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104733:	89 1c 24             	mov    %ebx,(%esp)
80104736:	e8 d3 cc ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
8010473b:	89 1c 24             	mov    %ebx,(%esp)
8010473e:	e8 d3 cf ff ff       	call   80101716 <iunlockput>
  end_op();
80104743:	e8 04 e1 ff ff       	call   8010284c <end_op>
  return 0;
80104748:	83 c4 10             	add    $0x10,%esp
8010474b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104750:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104753:	5b                   	pop    %ebx
80104754:	5e                   	pop    %esi
80104755:	5f                   	pop    %edi
80104756:	5d                   	pop    %ebp
80104757:	c3                   	ret    
    end_op();
80104758:	e8 ef e0 ff ff       	call   8010284c <end_op>
    return -1;
8010475d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104762:	eb ec                	jmp    80104750 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	68 30 6f 10 80       	push   $0x80106f30
8010476c:	e8 d7 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104771:	89 d8                	mov    %ebx,%eax
80104773:	e8 bf f9 ff ff       	call   80104137 <isdirempty>
80104778:	85 c0                	test   %eax,%eax
8010477a:	0f 85 6c ff ff ff    	jne    801046ec <sys_unlink+0xc1>
    iunlockput(ip);
80104780:	83 ec 0c             	sub    $0xc,%esp
80104783:	53                   	push   %ebx
80104784:	e8 8d cf ff ff       	call   80101716 <iunlockput>
    goto bad;
80104789:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010478c:	83 ec 0c             	sub    $0xc,%esp
8010478f:	56                   	push   %esi
80104790:	e8 81 cf ff ff       	call   80101716 <iunlockput>
  end_op();
80104795:	e8 b2 e0 ff ff       	call   8010284c <end_op>
  return -1;
8010479a:	83 c4 10             	add    $0x10,%esp
8010479d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a2:	eb ac                	jmp    80104750 <sys_unlink+0x125>
    panic("unlink: writei");
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	68 42 6f 10 80       	push   $0x80106f42
801047ac:	e8 97 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
801047b1:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801047b5:	83 e8 01             	sub    $0x1,%eax
801047b8:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801047bc:	83 ec 0c             	sub    $0xc,%esp
801047bf:	56                   	push   %esi
801047c0:	e8 49 cc ff ff       	call   8010140e <iupdate>
801047c5:	83 c4 10             	add    $0x10,%esp
801047c8:	e9 52 ff ff ff       	jmp    8010471f <sys_unlink+0xf4>
    return -1;
801047cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d2:	e9 79 ff ff ff       	jmp    80104750 <sys_unlink+0x125>

801047d7 <sys_open>:

int
sys_open(void)
{
801047d7:	55                   	push   %ebp
801047d8:	89 e5                	mov    %esp,%ebp
801047da:	57                   	push   %edi
801047db:	56                   	push   %esi
801047dc:	53                   	push   %ebx
801047dd:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801047e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047e3:	50                   	push   %eax
801047e4:	6a 00                	push   $0x0
801047e6:	e8 26 f8 ff ff       	call   80104011 <argstr>
801047eb:	83 c4 10             	add    $0x10,%esp
801047ee:	85 c0                	test   %eax,%eax
801047f0:	0f 88 30 01 00 00    	js     80104926 <sys_open+0x14f>
801047f6:	83 ec 08             	sub    $0x8,%esp
801047f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047fc:	50                   	push   %eax
801047fd:	6a 01                	push   $0x1
801047ff:	e8 7d f7 ff ff       	call   80103f81 <argint>
80104804:	83 c4 10             	add    $0x10,%esp
80104807:	85 c0                	test   %eax,%eax
80104809:	0f 88 21 01 00 00    	js     80104930 <sys_open+0x159>
    return -1;

  begin_op();
8010480f:	e8 be df ff ff       	call   801027d2 <begin_op>

  if(omode & O_CREATE){
80104814:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104818:	0f 84 84 00 00 00    	je     801048a2 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
8010481e:	83 ec 0c             	sub    $0xc,%esp
80104821:	6a 00                	push   $0x0
80104823:	b9 00 00 00 00       	mov    $0x0,%ecx
80104828:	ba 02 00 00 00       	mov    $0x2,%edx
8010482d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104830:	e8 59 f9 ff ff       	call   8010418e <create>
80104835:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104837:	83 c4 10             	add    $0x10,%esp
8010483a:	85 c0                	test   %eax,%eax
8010483c:	74 58                	je     80104896 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010483e:	e8 ea c3 ff ff       	call   80100c2d <filealloc>
80104843:	89 c3                	mov    %eax,%ebx
80104845:	85 c0                	test   %eax,%eax
80104847:	0f 84 ae 00 00 00    	je     801048fb <sys_open+0x124>
8010484d:	e8 ae f8 ff ff       	call   80104100 <fdalloc>
80104852:	89 c7                	mov    %eax,%edi
80104854:	85 c0                	test   %eax,%eax
80104856:	0f 88 9f 00 00 00    	js     801048fb <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010485c:	83 ec 0c             	sub    $0xc,%esp
8010485f:	56                   	push   %esi
80104860:	e8 cc cd ff ff       	call   80101631 <iunlock>
  end_op();
80104865:	e8 e2 df ff ff       	call   8010284c <end_op>

  f->type = FD_INODE;
8010486a:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104870:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104873:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010487a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487d:	83 c4 10             	add    $0x10,%esp
80104880:	a8 01                	test   $0x1,%al
80104882:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104886:	a8 03                	test   $0x3,%al
80104888:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010488c:	89 f8                	mov    %edi,%eax
8010488e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104891:	5b                   	pop    %ebx
80104892:	5e                   	pop    %esi
80104893:	5f                   	pop    %edi
80104894:	5d                   	pop    %ebp
80104895:	c3                   	ret    
      end_op();
80104896:	e8 b1 df ff ff       	call   8010284c <end_op>
      return -1;
8010489b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048a0:	eb ea                	jmp    8010488c <sys_open+0xb5>
    if((ip = namei(path)) == 0){
801048a2:	83 ec 0c             	sub    $0xc,%esp
801048a5:	ff 75 e4             	pushl  -0x1c(%ebp)
801048a8:	e8 22 d3 ff ff       	call   80101bcf <namei>
801048ad:	89 c6                	mov    %eax,%esi
801048af:	83 c4 10             	add    $0x10,%esp
801048b2:	85 c0                	test   %eax,%eax
801048b4:	74 39                	je     801048ef <sys_open+0x118>
    ilock(ip);
801048b6:	83 ec 0c             	sub    $0xc,%esp
801048b9:	50                   	push   %eax
801048ba:	e8 b0 cc ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801048bf:	83 c4 10             	add    $0x10,%esp
801048c2:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801048c7:	0f 85 71 ff ff ff    	jne    8010483e <sys_open+0x67>
801048cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048d1:	0f 84 67 ff ff ff    	je     8010483e <sys_open+0x67>
      iunlockput(ip);
801048d7:	83 ec 0c             	sub    $0xc,%esp
801048da:	56                   	push   %esi
801048db:	e8 36 ce ff ff       	call   80101716 <iunlockput>
      end_op();
801048e0:	e8 67 df ff ff       	call   8010284c <end_op>
      return -1;
801048e5:	83 c4 10             	add    $0x10,%esp
801048e8:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048ed:	eb 9d                	jmp    8010488c <sys_open+0xb5>
      end_op();
801048ef:	e8 58 df ff ff       	call   8010284c <end_op>
      return -1;
801048f4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048f9:	eb 91                	jmp    8010488c <sys_open+0xb5>
    if(f)
801048fb:	85 db                	test   %ebx,%ebx
801048fd:	74 0c                	je     8010490b <sys_open+0x134>
      fileclose(f);
801048ff:	83 ec 0c             	sub    $0xc,%esp
80104902:	53                   	push   %ebx
80104903:	e8 cb c3 ff ff       	call   80100cd3 <fileclose>
80104908:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010490b:	83 ec 0c             	sub    $0xc,%esp
8010490e:	56                   	push   %esi
8010490f:	e8 02 ce ff ff       	call   80101716 <iunlockput>
    end_op();
80104914:	e8 33 df ff ff       	call   8010284c <end_op>
    return -1;
80104919:	83 c4 10             	add    $0x10,%esp
8010491c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104921:	e9 66 ff ff ff       	jmp    8010488c <sys_open+0xb5>
    return -1;
80104926:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010492b:	e9 5c ff ff ff       	jmp    8010488c <sys_open+0xb5>
80104930:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104935:	e9 52 ff ff ff       	jmp    8010488c <sys_open+0xb5>

8010493a <sys_mkdir>:

int
sys_mkdir(void)
{
8010493a:	55                   	push   %ebp
8010493b:	89 e5                	mov    %esp,%ebp
8010493d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104940:	e8 8d de ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104945:	83 ec 08             	sub    $0x8,%esp
80104948:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010494b:	50                   	push   %eax
8010494c:	6a 00                	push   $0x0
8010494e:	e8 be f6 ff ff       	call   80104011 <argstr>
80104953:	83 c4 10             	add    $0x10,%esp
80104956:	85 c0                	test   %eax,%eax
80104958:	78 36                	js     80104990 <sys_mkdir+0x56>
8010495a:	83 ec 0c             	sub    $0xc,%esp
8010495d:	6a 00                	push   $0x0
8010495f:	b9 00 00 00 00       	mov    $0x0,%ecx
80104964:	ba 01 00 00 00       	mov    $0x1,%edx
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	e8 1d f8 ff ff       	call   8010418e <create>
80104971:	83 c4 10             	add    $0x10,%esp
80104974:	85 c0                	test   %eax,%eax
80104976:	74 18                	je     80104990 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104978:	83 ec 0c             	sub    $0xc,%esp
8010497b:	50                   	push   %eax
8010497c:	e8 95 cd ff ff       	call   80101716 <iunlockput>
  end_op();
80104981:	e8 c6 de ff ff       	call   8010284c <end_op>
  return 0;
80104986:	83 c4 10             	add    $0x10,%esp
80104989:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010498e:	c9                   	leave  
8010498f:	c3                   	ret    
    end_op();
80104990:	e8 b7 de ff ff       	call   8010284c <end_op>
    return -1;
80104995:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010499a:	eb f2                	jmp    8010498e <sys_mkdir+0x54>

8010499c <sys_mknod>:

int
sys_mknod(void)
{
8010499c:	55                   	push   %ebp
8010499d:	89 e5                	mov    %esp,%ebp
8010499f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801049a2:	e8 2b de ff ff       	call   801027d2 <begin_op>
  if((argstr(0, &path)) < 0 ||
801049a7:	83 ec 08             	sub    $0x8,%esp
801049aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049ad:	50                   	push   %eax
801049ae:	6a 00                	push   $0x0
801049b0:	e8 5c f6 ff ff       	call   80104011 <argstr>
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	85 c0                	test   %eax,%eax
801049ba:	78 62                	js     80104a1e <sys_mknod+0x82>
     argint(1, &major) < 0 ||
801049bc:	83 ec 08             	sub    $0x8,%esp
801049bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801049c2:	50                   	push   %eax
801049c3:	6a 01                	push   $0x1
801049c5:	e8 b7 f5 ff ff       	call   80103f81 <argint>
  if((argstr(0, &path)) < 0 ||
801049ca:	83 c4 10             	add    $0x10,%esp
801049cd:	85 c0                	test   %eax,%eax
801049cf:	78 4d                	js     80104a1e <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
801049d1:	83 ec 08             	sub    $0x8,%esp
801049d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801049d7:	50                   	push   %eax
801049d8:	6a 02                	push   $0x2
801049da:	e8 a2 f5 ff ff       	call   80103f81 <argint>
     argint(1, &major) < 0 ||
801049df:	83 c4 10             	add    $0x10,%esp
801049e2:	85 c0                	test   %eax,%eax
801049e4:	78 38                	js     80104a1e <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
801049e6:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801049ea:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801049ee:	83 ec 0c             	sub    $0xc,%esp
801049f1:	50                   	push   %eax
801049f2:	ba 03 00 00 00       	mov    $0x3,%edx
801049f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fa:	e8 8f f7 ff ff       	call   8010418e <create>
801049ff:	83 c4 10             	add    $0x10,%esp
80104a02:	85 c0                	test   %eax,%eax
80104a04:	74 18                	je     80104a1e <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a06:	83 ec 0c             	sub    $0xc,%esp
80104a09:	50                   	push   %eax
80104a0a:	e8 07 cd ff ff       	call   80101716 <iunlockput>
  end_op();
80104a0f:	e8 38 de ff ff       	call   8010284c <end_op>
  return 0;
80104a14:	83 c4 10             	add    $0x10,%esp
80104a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a1c:	c9                   	leave  
80104a1d:	c3                   	ret    
    end_op();
80104a1e:	e8 29 de ff ff       	call   8010284c <end_op>
    return -1;
80104a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a28:	eb f2                	jmp    80104a1c <sys_mknod+0x80>

80104a2a <sys_chdir>:

int
sys_chdir(void)
{
80104a2a:	55                   	push   %ebp
80104a2b:	89 e5                	mov    %esp,%ebp
80104a2d:	56                   	push   %esi
80104a2e:	53                   	push   %ebx
80104a2f:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a32:	e8 20 e8 ff ff       	call   80103257 <myproc>
80104a37:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104a39:	e8 94 dd ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a3e:	83 ec 08             	sub    $0x8,%esp
80104a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a44:	50                   	push   %eax
80104a45:	6a 00                	push   $0x0
80104a47:	e8 c5 f5 ff ff       	call   80104011 <argstr>
80104a4c:	83 c4 10             	add    $0x10,%esp
80104a4f:	85 c0                	test   %eax,%eax
80104a51:	78 52                	js     80104aa5 <sys_chdir+0x7b>
80104a53:	83 ec 0c             	sub    $0xc,%esp
80104a56:	ff 75 f4             	pushl  -0xc(%ebp)
80104a59:	e8 71 d1 ff ff       	call   80101bcf <namei>
80104a5e:	89 c3                	mov    %eax,%ebx
80104a60:	83 c4 10             	add    $0x10,%esp
80104a63:	85 c0                	test   %eax,%eax
80104a65:	74 3e                	je     80104aa5 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	50                   	push   %eax
80104a6b:	e8 ff ca ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104a70:	83 c4 10             	add    $0x10,%esp
80104a73:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a78:	75 37                	jne    80104ab1 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a7a:	83 ec 0c             	sub    $0xc,%esp
80104a7d:	53                   	push   %ebx
80104a7e:	e8 ae cb ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104a83:	83 c4 04             	add    $0x4,%esp
80104a86:	ff 76 68             	pushl  0x68(%esi)
80104a89:	e8 e8 cb ff ff       	call   80101676 <iput>
  end_op();
80104a8e:	e8 b9 dd ff ff       	call   8010284c <end_op>
  curproc->cwd = ip;
80104a93:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a96:	83 c4 10             	add    $0x10,%esp
80104a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104aa1:	5b                   	pop    %ebx
80104aa2:	5e                   	pop    %esi
80104aa3:	5d                   	pop    %ebp
80104aa4:	c3                   	ret    
    end_op();
80104aa5:	e8 a2 dd ff ff       	call   8010284c <end_op>
    return -1;
80104aaa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aaf:	eb ed                	jmp    80104a9e <sys_chdir+0x74>
    iunlockput(ip);
80104ab1:	83 ec 0c             	sub    $0xc,%esp
80104ab4:	53                   	push   %ebx
80104ab5:	e8 5c cc ff ff       	call   80101716 <iunlockput>
    end_op();
80104aba:	e8 8d dd ff ff       	call   8010284c <end_op>
    return -1;
80104abf:	83 c4 10             	add    $0x10,%esp
80104ac2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ac7:	eb d5                	jmp    80104a9e <sys_chdir+0x74>

80104ac9 <sys_exec>:

int
sys_exec(void)
{
80104ac9:	55                   	push   %ebp
80104aca:	89 e5                	mov    %esp,%ebp
80104acc:	53                   	push   %ebx
80104acd:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104ad3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ad6:	50                   	push   %eax
80104ad7:	6a 00                	push   $0x0
80104ad9:	e8 33 f5 ff ff       	call   80104011 <argstr>
80104ade:	83 c4 10             	add    $0x10,%esp
80104ae1:	85 c0                	test   %eax,%eax
80104ae3:	0f 88 a8 00 00 00    	js     80104b91 <sys_exec+0xc8>
80104ae9:	83 ec 08             	sub    $0x8,%esp
80104aec:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104af2:	50                   	push   %eax
80104af3:	6a 01                	push   $0x1
80104af5:	e8 87 f4 ff ff       	call   80103f81 <argint>
80104afa:	83 c4 10             	add    $0x10,%esp
80104afd:	85 c0                	test   %eax,%eax
80104aff:	0f 88 93 00 00 00    	js     80104b98 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104b05:	83 ec 04             	sub    $0x4,%esp
80104b08:	68 80 00 00 00       	push   $0x80
80104b0d:	6a 00                	push   $0x0
80104b0f:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b15:	50                   	push   %eax
80104b16:	e8 1b f2 ff ff       	call   80103d36 <memset>
80104b1b:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104b23:	83 fb 1f             	cmp    $0x1f,%ebx
80104b26:	77 77                	ja     80104b9f <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b28:	83 ec 08             	sub    $0x8,%esp
80104b2b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b31:	50                   	push   %eax
80104b32:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b38:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b3b:	50                   	push   %eax
80104b3c:	e8 c4 f3 ff ff       	call   80103f05 <fetchint>
80104b41:	83 c4 10             	add    $0x10,%esp
80104b44:	85 c0                	test   %eax,%eax
80104b46:	78 5e                	js     80104ba6 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104b48:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b4e:	85 c0                	test   %eax,%eax
80104b50:	74 1d                	je     80104b6f <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104b52:	83 ec 08             	sub    $0x8,%esp
80104b55:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b5c:	52                   	push   %edx
80104b5d:	50                   	push   %eax
80104b5e:	e8 de f3 ff ff       	call   80103f41 <fetchstr>
80104b63:	83 c4 10             	add    $0x10,%esp
80104b66:	85 c0                	test   %eax,%eax
80104b68:	78 46                	js     80104bb0 <sys_exec+0xe7>
  for(i=0;; i++){
80104b6a:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104b6d:	eb b4                	jmp    80104b23 <sys_exec+0x5a>
      argv[i] = 0;
80104b6f:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b76:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104b7a:	83 ec 08             	sub    $0x8,%esp
80104b7d:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b83:	50                   	push   %eax
80104b84:	ff 75 f4             	pushl  -0xc(%ebp)
80104b87:	e8 46 bd ff ff       	call   801008d2 <exec>
80104b8c:	83 c4 10             	add    $0x10,%esp
80104b8f:	eb 1a                	jmp    80104bab <sys_exec+0xe2>
    return -1;
80104b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b96:	eb 13                	jmp    80104bab <sys_exec+0xe2>
80104b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b9d:	eb 0c                	jmp    80104bab <sys_exec+0xe2>
      return -1;
80104b9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba4:	eb 05                	jmp    80104bab <sys_exec+0xe2>
      return -1;
80104ba6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bae:	c9                   	leave  
80104baf:	c3                   	ret    
      return -1;
80104bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb5:	eb f4                	jmp    80104bab <sys_exec+0xe2>

80104bb7 <sys_pipe>:

int
sys_pipe(void)
{
80104bb7:	55                   	push   %ebp
80104bb8:	89 e5                	mov    %esp,%ebp
80104bba:	53                   	push   %ebx
80104bbb:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104bbe:	6a 08                	push   $0x8
80104bc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bc3:	50                   	push   %eax
80104bc4:	6a 00                	push   $0x0
80104bc6:	e8 de f3 ff ff       	call   80103fa9 <argptr>
80104bcb:	83 c4 10             	add    $0x10,%esp
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	78 77                	js     80104c49 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104bd2:	83 ec 08             	sub    $0x8,%esp
80104bd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104bd8:	50                   	push   %eax
80104bd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bdc:	50                   	push   %eax
80104bdd:	e8 ae e1 ff ff       	call   80102d90 <pipealloc>
80104be2:	83 c4 10             	add    $0x10,%esp
80104be5:	85 c0                	test   %eax,%eax
80104be7:	78 67                	js     80104c50 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bec:	e8 0f f5 ff ff       	call   80104100 <fdalloc>
80104bf1:	89 c3                	mov    %eax,%ebx
80104bf3:	85 c0                	test   %eax,%eax
80104bf5:	78 21                	js     80104c18 <sys_pipe+0x61>
80104bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bfa:	e8 01 f5 ff ff       	call   80104100 <fdalloc>
80104bff:	85 c0                	test   %eax,%eax
80104c01:	78 15                	js     80104c18 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c06:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c0b:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c16:	c9                   	leave  
80104c17:	c3                   	ret    
    if(fd0 >= 0)
80104c18:	85 db                	test   %ebx,%ebx
80104c1a:	78 0d                	js     80104c29 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104c1c:	e8 36 e6 ff ff       	call   80103257 <myproc>
80104c21:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104c28:	00 
    fileclose(rf);
80104c29:	83 ec 0c             	sub    $0xc,%esp
80104c2c:	ff 75 f0             	pushl  -0x10(%ebp)
80104c2f:	e8 9f c0 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104c34:	83 c4 04             	add    $0x4,%esp
80104c37:	ff 75 ec             	pushl  -0x14(%ebp)
80104c3a:	e8 94 c0 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104c3f:	83 c4 10             	add    $0x10,%esp
80104c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c47:	eb ca                	jmp    80104c13 <sys_pipe+0x5c>
    return -1;
80104c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c4e:	eb c3                	jmp    80104c13 <sys_pipe+0x5c>
    return -1;
80104c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c55:	eb bc                	jmp    80104c13 <sys_pipe+0x5c>

80104c57 <sys_writecount>:

int
sys_writecount(void){
80104c57:	55                   	push   %ebp
80104c58:	89 e5                	mov    %esp,%ebp
  uint myWriteCount;
  myWriteCount = writeCount_global;
  return myWriteCount;
}
80104c5a:	a1 54 4e 11 80       	mov    0x80114e54,%eax
80104c5f:	5d                   	pop    %ebp
80104c60:	c3                   	ret    

80104c61 <sys_setwritecount>:

int
sys_setwritecount(void){
80104c61:	55                   	push   %ebp
80104c62:	89 e5                	mov    %esp,%ebp
80104c64:	83 ec 20             	sub    $0x20,%esp
   int pid;
  

  if(argint(0, &pid) < 0)
80104c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c6a:	50                   	push   %eax
80104c6b:	6a 00                	push   $0x0
80104c6d:	e8 0f f3 ff ff       	call   80103f81 <argint>
80104c72:	83 c4 10             	add    $0x10,%esp
80104c75:	85 c0                	test   %eax,%eax
80104c77:	78 0f                	js     80104c88 <sys_setwritecount+0x27>
    return -1;
  writeCount_global = (uint) pid;
80104c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7c:	a3 54 4e 11 80       	mov    %eax,0x80114e54
  return 0;
80104c81:	b8 00 00 00 00       	mov    $0x0,%eax
80104c86:	c9                   	leave  
80104c87:	c3                   	ret    
    return -1;
80104c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c8d:	eb f7                	jmp    80104c86 <sys_setwritecount+0x25>

80104c8f <sys_fork>:



int
sys_fork(void)
{
80104c8f:	55                   	push   %ebp
80104c90:	89 e5                	mov    %esp,%ebp
80104c92:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c95:	e8 35 e7 ff ff       	call   801033cf <fork>
}
80104c9a:	c9                   	leave  
80104c9b:	c3                   	ret    

80104c9c <sys_exit>:

int
sys_exit(void)
{
80104c9c:	55                   	push   %ebp
80104c9d:	89 e5                	mov    %esp,%ebp
80104c9f:	83 ec 08             	sub    $0x8,%esp
  exit();
80104ca2:	e8 74 e9 ff ff       	call   8010361b <exit>
  return 0;  // not reached
}
80104ca7:	b8 00 00 00 00       	mov    $0x0,%eax
80104cac:	c9                   	leave  
80104cad:	c3                   	ret    

80104cae <sys_wait>:

int
sys_wait(void)
{
80104cae:	55                   	push   %ebp
80104caf:	89 e5                	mov    %esp,%ebp
80104cb1:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104cb4:	e8 ee ea ff ff       	call   801037a7 <wait>
}
80104cb9:	c9                   	leave  
80104cba:	c3                   	ret    

80104cbb <sys_kill>:

int
sys_kill(void)
{
80104cbb:	55                   	push   %ebp
80104cbc:	89 e5                	mov    %esp,%ebp
80104cbe:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cc4:	50                   	push   %eax
80104cc5:	6a 00                	push   $0x0
80104cc7:	e8 b5 f2 ff ff       	call   80103f81 <argint>
80104ccc:	83 c4 10             	add    $0x10,%esp
80104ccf:	85 c0                	test   %eax,%eax
80104cd1:	78 10                	js     80104ce3 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104cd3:	83 ec 0c             	sub    $0xc,%esp
80104cd6:	ff 75 f4             	pushl  -0xc(%ebp)
80104cd9:	e8 c9 eb ff ff       	call   801038a7 <kill>
80104cde:	83 c4 10             	add    $0x10,%esp
}
80104ce1:	c9                   	leave  
80104ce2:	c3                   	ret    
    return -1;
80104ce3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce8:	eb f7                	jmp    80104ce1 <sys_kill+0x26>

80104cea <sys_getpid>:

int
sys_getpid(void)
{
80104cea:	55                   	push   %ebp
80104ceb:	89 e5                	mov    %esp,%ebp
80104ced:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104cf0:	e8 62 e5 ff ff       	call   80103257 <myproc>
80104cf5:	8b 40 10             	mov    0x10(%eax),%eax
}
80104cf8:	c9                   	leave  
80104cf9:	c3                   	ret    

80104cfa <sys_sbrk>:

int
sys_sbrk(void)
{
80104cfa:	55                   	push   %ebp
80104cfb:	89 e5                	mov    %esp,%ebp
80104cfd:	53                   	push   %ebx
80104cfe:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d04:	50                   	push   %eax
80104d05:	6a 00                	push   $0x0
80104d07:	e8 75 f2 ff ff       	call   80103f81 <argint>
80104d0c:	83 c4 10             	add    $0x10,%esp
80104d0f:	85 c0                	test   %eax,%eax
80104d11:	78 27                	js     80104d3a <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104d13:	e8 3f e5 ff ff       	call   80103257 <myproc>
80104d18:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104d1a:	83 ec 0c             	sub    $0xc,%esp
80104d1d:	ff 75 f4             	pushl  -0xc(%ebp)
80104d20:	e8 3d e6 ff ff       	call   80103362 <growproc>
80104d25:	83 c4 10             	add    $0x10,%esp
80104d28:	85 c0                	test   %eax,%eax
80104d2a:	78 07                	js     80104d33 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104d2c:	89 d8                	mov    %ebx,%eax
80104d2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d31:	c9                   	leave  
80104d32:	c3                   	ret    
    return -1;
80104d33:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104d38:	eb f2                	jmp    80104d2c <sys_sbrk+0x32>
    return -1;
80104d3a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104d3f:	eb eb                	jmp    80104d2c <sys_sbrk+0x32>

80104d41 <sys_sleep>:

int
sys_sleep(void)
{
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
80104d44:	53                   	push   %ebx
80104d45:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4b:	50                   	push   %eax
80104d4c:	6a 00                	push   $0x0
80104d4e:	e8 2e f2 ff ff       	call   80103f81 <argint>
80104d53:	83 c4 10             	add    $0x10,%esp
80104d56:	85 c0                	test   %eax,%eax
80104d58:	78 75                	js     80104dcf <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104d5a:	83 ec 0c             	sub    $0xc,%esp
80104d5d:	68 60 4e 11 80       	push   $0x80114e60
80104d62:	e8 23 ef ff ff       	call   80103c8a <acquire>
  ticks0 = ticks;
80104d67:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  while(ticks - ticks0 < n){
80104d6d:	83 c4 10             	add    $0x10,%esp
80104d70:	a1 a0 56 11 80       	mov    0x801156a0,%eax
80104d75:	29 d8                	sub    %ebx,%eax
80104d77:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d7a:	73 39                	jae    80104db5 <sys_sleep+0x74>
    if(myproc()->killed){
80104d7c:	e8 d6 e4 ff ff       	call   80103257 <myproc>
80104d81:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104d85:	75 17                	jne    80104d9e <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104d87:	83 ec 08             	sub    $0x8,%esp
80104d8a:	68 60 4e 11 80       	push   $0x80114e60
80104d8f:	68 a0 56 11 80       	push   $0x801156a0
80104d94:	e8 7d e9 ff ff       	call   80103716 <sleep>
80104d99:	83 c4 10             	add    $0x10,%esp
80104d9c:	eb d2                	jmp    80104d70 <sys_sleep+0x2f>
      release(&tickslock);
80104d9e:	83 ec 0c             	sub    $0xc,%esp
80104da1:	68 60 4e 11 80       	push   $0x80114e60
80104da6:	e8 44 ef ff ff       	call   80103cef <release>
      return -1;
80104dab:	83 c4 10             	add    $0x10,%esp
80104dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104db3:	eb 15                	jmp    80104dca <sys_sleep+0x89>
  }
  release(&tickslock);
80104db5:	83 ec 0c             	sub    $0xc,%esp
80104db8:	68 60 4e 11 80       	push   $0x80114e60
80104dbd:	e8 2d ef ff ff       	call   80103cef <release>
  return 0;
80104dc2:	83 c4 10             	add    $0x10,%esp
80104dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dcd:	c9                   	leave  
80104dce:	c3                   	ret    
    return -1;
80104dcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd4:	eb f4                	jmp    80104dca <sys_sleep+0x89>

80104dd6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104dd6:	55                   	push   %ebp
80104dd7:	89 e5                	mov    %esp,%ebp
80104dd9:	53                   	push   %ebx
80104dda:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104ddd:	68 60 4e 11 80       	push   $0x80114e60
80104de2:	e8 a3 ee ff ff       	call   80103c8a <acquire>
  xticks = ticks;
80104de7:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  release(&tickslock);
80104ded:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80104df4:	e8 f6 ee ff ff       	call   80103cef <release>
  return xticks;
}
80104df9:	89 d8                	mov    %ebx,%eax
80104dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dfe:	c9                   	leave  
80104dff:	c3                   	ret    

80104e00 <sys_yield>:

int
sys_yield(void)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	83 ec 08             	sub    $0x8,%esp
  yield();
80104e06:	e8 d9 e8 ff ff       	call   801036e4 <yield>
  return 0;
}
80104e0b:	b8 00 00 00 00       	mov    $0x0,%eax
80104e10:	c9                   	leave  
80104e11:	c3                   	ret    

80104e12 <sys_shutdown>:

int sys_shutdown(void)
{
80104e12:	55                   	push   %ebp
80104e13:	89 e5                	mov    %esp,%ebp
80104e15:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104e18:	e8 e9 d3 ff ff       	call   80102206 <shutdown>
  return 0;
}
80104e1d:	b8 00 00 00 00       	mov    $0x0,%eax
80104e22:	c9                   	leave  
80104e23:	c3                   	ret    

80104e24 <sys_settickets>:

int sys_settickets(void){
80104e24:	55                   	push   %ebp
80104e25:	89 e5                	mov    %esp,%ebp
80104e27:	53                   	push   %ebx
80104e28:	83 ec 14             	sub    $0x14,%esp
  int tickets;
  struct proc *curproc = myproc();
80104e2b:	e8 27 e4 ff ff       	call   80103257 <myproc>
80104e30:	89 c3                	mov    %eax,%ebx

  if(argint(0, &tickets) < 0)
80104e32:	83 ec 08             	sub    $0x8,%esp
80104e35:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e38:	50                   	push   %eax
80104e39:	6a 00                	push   $0x0
80104e3b:	e8 41 f1 ff ff       	call   80103f81 <argint>
80104e40:	83 c4 10             	add    $0x10,%esp
80104e43:	85 c0                	test   %eax,%eax
80104e45:	78 13                	js     80104e5a <sys_settickets+0x36>
    return -1;

  curproc->tickets = tickets;
80104e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)

  
  
  return 0;
80104e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e58:	c9                   	leave  
80104e59:	c3                   	ret    
    return -1;
80104e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e5f:	eb f4                	jmp    80104e55 <sys_settickets+0x31>

80104e61 <sys_getprocessesinfo>:

int sys_getprocessesinfo(){
80104e61:	55                   	push   %ebp
80104e62:	89 e5                	mov    %esp,%ebp
80104e64:	83 ec 1c             	sub    $0x1c,%esp
  //int x;
  


  
  if( argptr(0, (void*) &my_process_info, sizeof(*my_process_info)) < 0){
80104e67:	68 04 03 00 00       	push   $0x304
80104e6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e6f:	50                   	push   %eax
80104e70:	6a 00                	push   $0x0
80104e72:	e8 32 f1 ff ff       	call   80103fa9 <argptr>
80104e77:	83 c4 10             	add    $0x10,%esp
80104e7a:	85 c0                	test   %eax,%eax
80104e7c:	78 10                	js     80104e8e <sys_getprocessesinfo+0x2d>
  }




  return getprocessesinfo_helper(my_process_info);
80104e7e:	83 ec 0c             	sub    $0xc,%esp
80104e81:	ff 75 f4             	pushl  -0xc(%ebp)
80104e84:	e8 49 eb ff ff       	call   801039d2 <getprocessesinfo_helper>
80104e89:	83 c4 10             	add    $0x10,%esp
}
80104e8c:	c9                   	leave  
80104e8d:	c3                   	ret    
    return -1;
80104e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e93:	eb f7                	jmp    80104e8c <sys_getprocessesinfo+0x2b>

80104e95 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104e95:	1e                   	push   %ds
  pushl %es
80104e96:	06                   	push   %es
  pushl %fs
80104e97:	0f a0                	push   %fs
  pushl %gs
80104e99:	0f a8                	push   %gs
  pushal
80104e9b:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104e9c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104ea0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104ea2:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104ea4:	54                   	push   %esp
  call trap
80104ea5:	e8 e3 00 00 00       	call   80104f8d <trap>
  addl $4, %esp
80104eaa:	83 c4 04             	add    $0x4,%esp

80104ead <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104ead:	61                   	popa   
  popl %gs
80104eae:	0f a9                	pop    %gs
  popl %fs
80104eb0:	0f a1                	pop    %fs
  popl %es
80104eb2:	07                   	pop    %es
  popl %ds
80104eb3:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104eb4:	83 c4 08             	add    $0x8,%esp
  iret
80104eb7:	cf                   	iret   

80104eb8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104eb8:	55                   	push   %ebp
80104eb9:	89 e5                	mov    %esp,%ebp
80104ebb:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104ebe:	b8 00 00 00 00       	mov    $0x0,%eax
80104ec3:	eb 4a                	jmp    80104f0f <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104ec5:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104ecc:	66 89 0c c5 a0 4e 11 	mov    %cx,-0x7feeb160(,%eax,8)
80104ed3:	80 
80104ed4:	66 c7 04 c5 a2 4e 11 	movw   $0x8,-0x7feeb15e(,%eax,8)
80104edb:	80 08 00 
80104ede:	c6 04 c5 a4 4e 11 80 	movb   $0x0,-0x7feeb15c(,%eax,8)
80104ee5:	00 
80104ee6:	0f b6 14 c5 a5 4e 11 	movzbl -0x7feeb15b(,%eax,8),%edx
80104eed:	80 
80104eee:	83 e2 f0             	and    $0xfffffff0,%edx
80104ef1:	83 ca 0e             	or     $0xe,%edx
80104ef4:	83 e2 8f             	and    $0xffffff8f,%edx
80104ef7:	83 ca 80             	or     $0xffffff80,%edx
80104efa:	88 14 c5 a5 4e 11 80 	mov    %dl,-0x7feeb15b(,%eax,8)
80104f01:	c1 e9 10             	shr    $0x10,%ecx
80104f04:	66 89 0c c5 a6 4e 11 	mov    %cx,-0x7feeb15a(,%eax,8)
80104f0b:	80 
  for(i = 0; i < 256; i++)
80104f0c:	83 c0 01             	add    $0x1,%eax
80104f0f:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f14:	7e af                	jle    80104ec5 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f16:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f1c:	66 89 15 a0 50 11 80 	mov    %dx,0x801150a0
80104f23:	66 c7 05 a2 50 11 80 	movw   $0x8,0x801150a2
80104f2a:	08 00 
80104f2c:	c6 05 a4 50 11 80 00 	movb   $0x0,0x801150a4
80104f33:	0f b6 05 a5 50 11 80 	movzbl 0x801150a5,%eax
80104f3a:	83 c8 0f             	or     $0xf,%eax
80104f3d:	83 e0 ef             	and    $0xffffffef,%eax
80104f40:	83 c8 e0             	or     $0xffffffe0,%eax
80104f43:	a2 a5 50 11 80       	mov    %al,0x801150a5
80104f48:	c1 ea 10             	shr    $0x10,%edx
80104f4b:	66 89 15 a6 50 11 80 	mov    %dx,0x801150a6

  initlock(&tickslock, "time");
80104f52:	83 ec 08             	sub    $0x8,%esp
80104f55:	68 51 6f 10 80       	push   $0x80106f51
80104f5a:	68 60 4e 11 80       	push   $0x80114e60
80104f5f:	e8 ea eb ff ff       	call   80103b4e <initlock>
}
80104f64:	83 c4 10             	add    $0x10,%esp
80104f67:	c9                   	leave  
80104f68:	c3                   	ret    

80104f69 <idtinit>:

void
idtinit(void)
{
80104f69:	55                   	push   %ebp
80104f6a:	89 e5                	mov    %esp,%ebp
80104f6c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104f6f:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104f75:	b8 a0 4e 11 80       	mov    $0x80114ea0,%eax
80104f7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104f7e:	c1 e8 10             	shr    $0x10,%eax
80104f81:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104f85:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104f88:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104f8b:	c9                   	leave  
80104f8c:	c3                   	ret    

80104f8d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	57                   	push   %edi
80104f91:	56                   	push   %esi
80104f92:	53                   	push   %ebx
80104f93:	83 ec 1c             	sub    $0x1c,%esp
80104f96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104f99:	8b 43 30             	mov    0x30(%ebx),%eax
80104f9c:	83 f8 40             	cmp    $0x40,%eax
80104f9f:	74 13                	je     80104fb4 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104fa1:	83 e8 20             	sub    $0x20,%eax
80104fa4:	83 f8 1f             	cmp    $0x1f,%eax
80104fa7:	0f 87 3a 01 00 00    	ja     801050e7 <trap+0x15a>
80104fad:	ff 24 85 f8 6f 10 80 	jmp    *-0x7fef9008(,%eax,4)
    if(myproc()->killed)
80104fb4:	e8 9e e2 ff ff       	call   80103257 <myproc>
80104fb9:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fbd:	75 1f                	jne    80104fde <trap+0x51>
    myproc()->tf = tf;
80104fbf:	e8 93 e2 ff ff       	call   80103257 <myproc>
80104fc4:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104fc7:	e8 78 f0 ff ff       	call   80104044 <syscall>
    if(myproc()->killed)
80104fcc:	e8 86 e2 ff ff       	call   80103257 <myproc>
80104fd1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fd5:	74 7e                	je     80105055 <trap+0xc8>
      exit();
80104fd7:	e8 3f e6 ff ff       	call   8010361b <exit>
80104fdc:	eb 77                	jmp    80105055 <trap+0xc8>
      exit();
80104fde:	e8 38 e6 ff ff       	call   8010361b <exit>
80104fe3:	eb da                	jmp    80104fbf <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104fe5:	e8 52 e2 ff ff       	call   8010323c <cpuid>
80104fea:	85 c0                	test   %eax,%eax
80104fec:	74 6f                	je     8010505d <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104fee:	e8 ca d3 ff ff       	call   801023bd <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ff3:	e8 5f e2 ff ff       	call   80103257 <myproc>
80104ff8:	85 c0                	test   %eax,%eax
80104ffa:	74 1c                	je     80105018 <trap+0x8b>
80104ffc:	e8 56 e2 ff ff       	call   80103257 <myproc>
80105001:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105005:	74 11                	je     80105018 <trap+0x8b>
80105007:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010500b:	83 e0 03             	and    $0x3,%eax
8010500e:	66 83 f8 03          	cmp    $0x3,%ax
80105012:	0f 84 62 01 00 00    	je     8010517a <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105018:	e8 3a e2 ff ff       	call   80103257 <myproc>
8010501d:	85 c0                	test   %eax,%eax
8010501f:	74 0f                	je     80105030 <trap+0xa3>
80105021:	e8 31 e2 ff ff       	call   80103257 <myproc>
80105026:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010502a:	0f 84 54 01 00 00    	je     80105184 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105030:	e8 22 e2 ff ff       	call   80103257 <myproc>
80105035:	85 c0                	test   %eax,%eax
80105037:	74 1c                	je     80105055 <trap+0xc8>
80105039:	e8 19 e2 ff ff       	call   80103257 <myproc>
8010503e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105042:	74 11                	je     80105055 <trap+0xc8>
80105044:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105048:	83 e0 03             	and    $0x3,%eax
8010504b:	66 83 f8 03          	cmp    $0x3,%ax
8010504f:	0f 84 43 01 00 00    	je     80105198 <trap+0x20b>
    exit();
}
80105055:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105058:	5b                   	pop    %ebx
80105059:	5e                   	pop    %esi
8010505a:	5f                   	pop    %edi
8010505b:	5d                   	pop    %ebp
8010505c:	c3                   	ret    
      acquire(&tickslock);
8010505d:	83 ec 0c             	sub    $0xc,%esp
80105060:	68 60 4e 11 80       	push   $0x80114e60
80105065:	e8 20 ec ff ff       	call   80103c8a <acquire>
      ticks++;
8010506a:	83 05 a0 56 11 80 01 	addl   $0x1,0x801156a0
      wakeup(&ticks);
80105071:	c7 04 24 a0 56 11 80 	movl   $0x801156a0,(%esp)
80105078:	e8 01 e8 ff ff       	call   8010387e <wakeup>
      release(&tickslock);
8010507d:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80105084:	e8 66 ec ff ff       	call   80103cef <release>
80105089:	83 c4 10             	add    $0x10,%esp
8010508c:	e9 5d ff ff ff       	jmp    80104fee <trap+0x61>
    ideintr();
80105091:	e8 cb cc ff ff       	call   80101d61 <ideintr>
    lapiceoi();
80105096:	e8 22 d3 ff ff       	call   801023bd <lapiceoi>
    break;
8010509b:	e9 53 ff ff ff       	jmp    80104ff3 <trap+0x66>
    kbdintr();
801050a0:	e8 4c d1 ff ff       	call   801021f1 <kbdintr>
    lapiceoi();
801050a5:	e8 13 d3 ff ff       	call   801023bd <lapiceoi>
    break;
801050aa:	e9 44 ff ff ff       	jmp    80104ff3 <trap+0x66>
    uartintr();
801050af:	e8 05 02 00 00       	call   801052b9 <uartintr>
    lapiceoi();
801050b4:	e8 04 d3 ff ff       	call   801023bd <lapiceoi>
    break;
801050b9:	e9 35 ff ff ff       	jmp    80104ff3 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050be:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801050c1:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050c5:	e8 72 e1 ff ff       	call   8010323c <cpuid>
801050ca:	57                   	push   %edi
801050cb:	0f b7 f6             	movzwl %si,%esi
801050ce:	56                   	push   %esi
801050cf:	50                   	push   %eax
801050d0:	68 5c 6f 10 80       	push   $0x80106f5c
801050d5:	e8 31 b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
801050da:	e8 de d2 ff ff       	call   801023bd <lapiceoi>
    break;
801050df:	83 c4 10             	add    $0x10,%esp
801050e2:	e9 0c ff ff ff       	jmp    80104ff3 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801050e7:	e8 6b e1 ff ff       	call   80103257 <myproc>
801050ec:	85 c0                	test   %eax,%eax
801050ee:	74 5f                	je     8010514f <trap+0x1c2>
801050f0:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801050f4:	74 59                	je     8010514f <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801050f6:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801050f9:	8b 43 38             	mov    0x38(%ebx),%eax
801050fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801050ff:	e8 38 e1 ff ff       	call   8010323c <cpuid>
80105104:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105107:	8b 53 34             	mov    0x34(%ebx),%edx
8010510a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010510d:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105110:	e8 42 e1 ff ff       	call   80103257 <myproc>
80105115:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105118:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010511b:	e8 37 e1 ff ff       	call   80103257 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105120:	57                   	push   %edi
80105121:	ff 75 e4             	pushl  -0x1c(%ebp)
80105124:	ff 75 e0             	pushl  -0x20(%ebp)
80105127:	ff 75 dc             	pushl  -0x24(%ebp)
8010512a:	56                   	push   %esi
8010512b:	ff 75 d8             	pushl  -0x28(%ebp)
8010512e:	ff 70 10             	pushl  0x10(%eax)
80105131:	68 b4 6f 10 80       	push   $0x80106fb4
80105136:	e8 d0 b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
8010513b:	83 c4 20             	add    $0x20,%esp
8010513e:	e8 14 e1 ff ff       	call   80103257 <myproc>
80105143:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010514a:	e9 a4 fe ff ff       	jmp    80104ff3 <trap+0x66>
8010514f:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105152:	8b 73 38             	mov    0x38(%ebx),%esi
80105155:	e8 e2 e0 ff ff       	call   8010323c <cpuid>
8010515a:	83 ec 0c             	sub    $0xc,%esp
8010515d:	57                   	push   %edi
8010515e:	56                   	push   %esi
8010515f:	50                   	push   %eax
80105160:	ff 73 30             	pushl  0x30(%ebx)
80105163:	68 80 6f 10 80       	push   $0x80106f80
80105168:	e8 9e b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
8010516d:	83 c4 14             	add    $0x14,%esp
80105170:	68 56 6f 10 80       	push   $0x80106f56
80105175:	e8 ce b1 ff ff       	call   80100348 <panic>
    exit();
8010517a:	e8 9c e4 ff ff       	call   8010361b <exit>
8010517f:	e9 94 fe ff ff       	jmp    80105018 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105184:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105188:	0f 85 a2 fe ff ff    	jne    80105030 <trap+0xa3>
    yield();
8010518e:	e8 51 e5 ff ff       	call   801036e4 <yield>
80105193:	e9 98 fe ff ff       	jmp    80105030 <trap+0xa3>
    exit();
80105198:	e8 7e e4 ff ff       	call   8010361b <exit>
8010519d:	e9 b3 fe ff ff       	jmp    80105055 <trap+0xc8>

801051a2 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801051a2:	55                   	push   %ebp
801051a3:	89 e5                	mov    %esp,%ebp
  if(!uart)
801051a5:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051ac:	74 15                	je     801051c3 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051ae:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051b3:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051b4:	a8 01                	test   $0x1,%al
801051b6:	74 12                	je     801051ca <uartgetc+0x28>
801051b8:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051bd:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801051be:	0f b6 c0             	movzbl %al,%eax
}
801051c1:	5d                   	pop    %ebp
801051c2:	c3                   	ret    
    return -1;
801051c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c8:	eb f7                	jmp    801051c1 <uartgetc+0x1f>
    return -1;
801051ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051cf:	eb f0                	jmp    801051c1 <uartgetc+0x1f>

801051d1 <uartputc>:
  if(!uart)
801051d1:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051d8:	74 3b                	je     80105215 <uartputc+0x44>
{
801051da:	55                   	push   %ebp
801051db:	89 e5                	mov    %esp,%ebp
801051dd:	53                   	push   %ebx
801051de:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051e1:	bb 00 00 00 00       	mov    $0x0,%ebx
801051e6:	eb 10                	jmp    801051f8 <uartputc+0x27>
    microdelay(10);
801051e8:	83 ec 0c             	sub    $0xc,%esp
801051eb:	6a 0a                	push   $0xa
801051ed:	e8 ea d1 ff ff       	call   801023dc <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051f2:	83 c3 01             	add    $0x1,%ebx
801051f5:	83 c4 10             	add    $0x10,%esp
801051f8:	83 fb 7f             	cmp    $0x7f,%ebx
801051fb:	7f 0a                	jg     80105207 <uartputc+0x36>
801051fd:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105202:	ec                   	in     (%dx),%al
80105203:	a8 20                	test   $0x20,%al
80105205:	74 e1                	je     801051e8 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105207:	8b 45 08             	mov    0x8(%ebp),%eax
8010520a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010520f:	ee                   	out    %al,(%dx)
}
80105210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105213:	c9                   	leave  
80105214:	c3                   	ret    
80105215:	f3 c3                	repz ret 

80105217 <uartinit>:
{
80105217:	55                   	push   %ebp
80105218:	89 e5                	mov    %esp,%ebp
8010521a:	56                   	push   %esi
8010521b:	53                   	push   %ebx
8010521c:	b9 00 00 00 00       	mov    $0x0,%ecx
80105221:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105226:	89 c8                	mov    %ecx,%eax
80105228:	ee                   	out    %al,(%dx)
80105229:	be fb 03 00 00       	mov    $0x3fb,%esi
8010522e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105233:	89 f2                	mov    %esi,%edx
80105235:	ee                   	out    %al,(%dx)
80105236:	b8 0c 00 00 00       	mov    $0xc,%eax
8010523b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105240:	ee                   	out    %al,(%dx)
80105241:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105246:	89 c8                	mov    %ecx,%eax
80105248:	89 da                	mov    %ebx,%edx
8010524a:	ee                   	out    %al,(%dx)
8010524b:	b8 03 00 00 00       	mov    $0x3,%eax
80105250:	89 f2                	mov    %esi,%edx
80105252:	ee                   	out    %al,(%dx)
80105253:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105258:	89 c8                	mov    %ecx,%eax
8010525a:	ee                   	out    %al,(%dx)
8010525b:	b8 01 00 00 00       	mov    $0x1,%eax
80105260:	89 da                	mov    %ebx,%edx
80105262:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105263:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105268:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105269:	3c ff                	cmp    $0xff,%al
8010526b:	74 45                	je     801052b2 <uartinit+0x9b>
  uart = 1;
8010526d:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105274:	00 00 00 
80105277:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010527c:	ec                   	in     (%dx),%al
8010527d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105282:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105283:	83 ec 08             	sub    $0x8,%esp
80105286:	6a 00                	push   $0x0
80105288:	6a 04                	push   $0x4
8010528a:	e8 dd cc ff ff       	call   80101f6c <ioapicenable>
  for(p="xv6...\n"; *p; p++)
8010528f:	83 c4 10             	add    $0x10,%esp
80105292:	bb 78 70 10 80       	mov    $0x80107078,%ebx
80105297:	eb 12                	jmp    801052ab <uartinit+0x94>
    uartputc(*p);
80105299:	83 ec 0c             	sub    $0xc,%esp
8010529c:	0f be c0             	movsbl %al,%eax
8010529f:	50                   	push   %eax
801052a0:	e8 2c ff ff ff       	call   801051d1 <uartputc>
  for(p="xv6...\n"; *p; p++)
801052a5:	83 c3 01             	add    $0x1,%ebx
801052a8:	83 c4 10             	add    $0x10,%esp
801052ab:	0f b6 03             	movzbl (%ebx),%eax
801052ae:	84 c0                	test   %al,%al
801052b0:	75 e7                	jne    80105299 <uartinit+0x82>
}
801052b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052b5:	5b                   	pop    %ebx
801052b6:	5e                   	pop    %esi
801052b7:	5d                   	pop    %ebp
801052b8:	c3                   	ret    

801052b9 <uartintr>:

void
uartintr(void)
{
801052b9:	55                   	push   %ebp
801052ba:	89 e5                	mov    %esp,%ebp
801052bc:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801052bf:	68 a2 51 10 80       	push   $0x801051a2
801052c4:	e8 75 b4 ff ff       	call   8010073e <consoleintr>
}
801052c9:	83 c4 10             	add    $0x10,%esp
801052cc:	c9                   	leave  
801052cd:	c3                   	ret    

801052ce <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801052ce:	6a 00                	push   $0x0
  pushl $0
801052d0:	6a 00                	push   $0x0
  jmp alltraps
801052d2:	e9 be fb ff ff       	jmp    80104e95 <alltraps>

801052d7 <vector1>:
.globl vector1
vector1:
  pushl $0
801052d7:	6a 00                	push   $0x0
  pushl $1
801052d9:	6a 01                	push   $0x1
  jmp alltraps
801052db:	e9 b5 fb ff ff       	jmp    80104e95 <alltraps>

801052e0 <vector2>:
.globl vector2
vector2:
  pushl $0
801052e0:	6a 00                	push   $0x0
  pushl $2
801052e2:	6a 02                	push   $0x2
  jmp alltraps
801052e4:	e9 ac fb ff ff       	jmp    80104e95 <alltraps>

801052e9 <vector3>:
.globl vector3
vector3:
  pushl $0
801052e9:	6a 00                	push   $0x0
  pushl $3
801052eb:	6a 03                	push   $0x3
  jmp alltraps
801052ed:	e9 a3 fb ff ff       	jmp    80104e95 <alltraps>

801052f2 <vector4>:
.globl vector4
vector4:
  pushl $0
801052f2:	6a 00                	push   $0x0
  pushl $4
801052f4:	6a 04                	push   $0x4
  jmp alltraps
801052f6:	e9 9a fb ff ff       	jmp    80104e95 <alltraps>

801052fb <vector5>:
.globl vector5
vector5:
  pushl $0
801052fb:	6a 00                	push   $0x0
  pushl $5
801052fd:	6a 05                	push   $0x5
  jmp alltraps
801052ff:	e9 91 fb ff ff       	jmp    80104e95 <alltraps>

80105304 <vector6>:
.globl vector6
vector6:
  pushl $0
80105304:	6a 00                	push   $0x0
  pushl $6
80105306:	6a 06                	push   $0x6
  jmp alltraps
80105308:	e9 88 fb ff ff       	jmp    80104e95 <alltraps>

8010530d <vector7>:
.globl vector7
vector7:
  pushl $0
8010530d:	6a 00                	push   $0x0
  pushl $7
8010530f:	6a 07                	push   $0x7
  jmp alltraps
80105311:	e9 7f fb ff ff       	jmp    80104e95 <alltraps>

80105316 <vector8>:
.globl vector8
vector8:
  pushl $8
80105316:	6a 08                	push   $0x8
  jmp alltraps
80105318:	e9 78 fb ff ff       	jmp    80104e95 <alltraps>

8010531d <vector9>:
.globl vector9
vector9:
  pushl $0
8010531d:	6a 00                	push   $0x0
  pushl $9
8010531f:	6a 09                	push   $0x9
  jmp alltraps
80105321:	e9 6f fb ff ff       	jmp    80104e95 <alltraps>

80105326 <vector10>:
.globl vector10
vector10:
  pushl $10
80105326:	6a 0a                	push   $0xa
  jmp alltraps
80105328:	e9 68 fb ff ff       	jmp    80104e95 <alltraps>

8010532d <vector11>:
.globl vector11
vector11:
  pushl $11
8010532d:	6a 0b                	push   $0xb
  jmp alltraps
8010532f:	e9 61 fb ff ff       	jmp    80104e95 <alltraps>

80105334 <vector12>:
.globl vector12
vector12:
  pushl $12
80105334:	6a 0c                	push   $0xc
  jmp alltraps
80105336:	e9 5a fb ff ff       	jmp    80104e95 <alltraps>

8010533b <vector13>:
.globl vector13
vector13:
  pushl $13
8010533b:	6a 0d                	push   $0xd
  jmp alltraps
8010533d:	e9 53 fb ff ff       	jmp    80104e95 <alltraps>

80105342 <vector14>:
.globl vector14
vector14:
  pushl $14
80105342:	6a 0e                	push   $0xe
  jmp alltraps
80105344:	e9 4c fb ff ff       	jmp    80104e95 <alltraps>

80105349 <vector15>:
.globl vector15
vector15:
  pushl $0
80105349:	6a 00                	push   $0x0
  pushl $15
8010534b:	6a 0f                	push   $0xf
  jmp alltraps
8010534d:	e9 43 fb ff ff       	jmp    80104e95 <alltraps>

80105352 <vector16>:
.globl vector16
vector16:
  pushl $0
80105352:	6a 00                	push   $0x0
  pushl $16
80105354:	6a 10                	push   $0x10
  jmp alltraps
80105356:	e9 3a fb ff ff       	jmp    80104e95 <alltraps>

8010535b <vector17>:
.globl vector17
vector17:
  pushl $17
8010535b:	6a 11                	push   $0x11
  jmp alltraps
8010535d:	e9 33 fb ff ff       	jmp    80104e95 <alltraps>

80105362 <vector18>:
.globl vector18
vector18:
  pushl $0
80105362:	6a 00                	push   $0x0
  pushl $18
80105364:	6a 12                	push   $0x12
  jmp alltraps
80105366:	e9 2a fb ff ff       	jmp    80104e95 <alltraps>

8010536b <vector19>:
.globl vector19
vector19:
  pushl $0
8010536b:	6a 00                	push   $0x0
  pushl $19
8010536d:	6a 13                	push   $0x13
  jmp alltraps
8010536f:	e9 21 fb ff ff       	jmp    80104e95 <alltraps>

80105374 <vector20>:
.globl vector20
vector20:
  pushl $0
80105374:	6a 00                	push   $0x0
  pushl $20
80105376:	6a 14                	push   $0x14
  jmp alltraps
80105378:	e9 18 fb ff ff       	jmp    80104e95 <alltraps>

8010537d <vector21>:
.globl vector21
vector21:
  pushl $0
8010537d:	6a 00                	push   $0x0
  pushl $21
8010537f:	6a 15                	push   $0x15
  jmp alltraps
80105381:	e9 0f fb ff ff       	jmp    80104e95 <alltraps>

80105386 <vector22>:
.globl vector22
vector22:
  pushl $0
80105386:	6a 00                	push   $0x0
  pushl $22
80105388:	6a 16                	push   $0x16
  jmp alltraps
8010538a:	e9 06 fb ff ff       	jmp    80104e95 <alltraps>

8010538f <vector23>:
.globl vector23
vector23:
  pushl $0
8010538f:	6a 00                	push   $0x0
  pushl $23
80105391:	6a 17                	push   $0x17
  jmp alltraps
80105393:	e9 fd fa ff ff       	jmp    80104e95 <alltraps>

80105398 <vector24>:
.globl vector24
vector24:
  pushl $0
80105398:	6a 00                	push   $0x0
  pushl $24
8010539a:	6a 18                	push   $0x18
  jmp alltraps
8010539c:	e9 f4 fa ff ff       	jmp    80104e95 <alltraps>

801053a1 <vector25>:
.globl vector25
vector25:
  pushl $0
801053a1:	6a 00                	push   $0x0
  pushl $25
801053a3:	6a 19                	push   $0x19
  jmp alltraps
801053a5:	e9 eb fa ff ff       	jmp    80104e95 <alltraps>

801053aa <vector26>:
.globl vector26
vector26:
  pushl $0
801053aa:	6a 00                	push   $0x0
  pushl $26
801053ac:	6a 1a                	push   $0x1a
  jmp alltraps
801053ae:	e9 e2 fa ff ff       	jmp    80104e95 <alltraps>

801053b3 <vector27>:
.globl vector27
vector27:
  pushl $0
801053b3:	6a 00                	push   $0x0
  pushl $27
801053b5:	6a 1b                	push   $0x1b
  jmp alltraps
801053b7:	e9 d9 fa ff ff       	jmp    80104e95 <alltraps>

801053bc <vector28>:
.globl vector28
vector28:
  pushl $0
801053bc:	6a 00                	push   $0x0
  pushl $28
801053be:	6a 1c                	push   $0x1c
  jmp alltraps
801053c0:	e9 d0 fa ff ff       	jmp    80104e95 <alltraps>

801053c5 <vector29>:
.globl vector29
vector29:
  pushl $0
801053c5:	6a 00                	push   $0x0
  pushl $29
801053c7:	6a 1d                	push   $0x1d
  jmp alltraps
801053c9:	e9 c7 fa ff ff       	jmp    80104e95 <alltraps>

801053ce <vector30>:
.globl vector30
vector30:
  pushl $0
801053ce:	6a 00                	push   $0x0
  pushl $30
801053d0:	6a 1e                	push   $0x1e
  jmp alltraps
801053d2:	e9 be fa ff ff       	jmp    80104e95 <alltraps>

801053d7 <vector31>:
.globl vector31
vector31:
  pushl $0
801053d7:	6a 00                	push   $0x0
  pushl $31
801053d9:	6a 1f                	push   $0x1f
  jmp alltraps
801053db:	e9 b5 fa ff ff       	jmp    80104e95 <alltraps>

801053e0 <vector32>:
.globl vector32
vector32:
  pushl $0
801053e0:	6a 00                	push   $0x0
  pushl $32
801053e2:	6a 20                	push   $0x20
  jmp alltraps
801053e4:	e9 ac fa ff ff       	jmp    80104e95 <alltraps>

801053e9 <vector33>:
.globl vector33
vector33:
  pushl $0
801053e9:	6a 00                	push   $0x0
  pushl $33
801053eb:	6a 21                	push   $0x21
  jmp alltraps
801053ed:	e9 a3 fa ff ff       	jmp    80104e95 <alltraps>

801053f2 <vector34>:
.globl vector34
vector34:
  pushl $0
801053f2:	6a 00                	push   $0x0
  pushl $34
801053f4:	6a 22                	push   $0x22
  jmp alltraps
801053f6:	e9 9a fa ff ff       	jmp    80104e95 <alltraps>

801053fb <vector35>:
.globl vector35
vector35:
  pushl $0
801053fb:	6a 00                	push   $0x0
  pushl $35
801053fd:	6a 23                	push   $0x23
  jmp alltraps
801053ff:	e9 91 fa ff ff       	jmp    80104e95 <alltraps>

80105404 <vector36>:
.globl vector36
vector36:
  pushl $0
80105404:	6a 00                	push   $0x0
  pushl $36
80105406:	6a 24                	push   $0x24
  jmp alltraps
80105408:	e9 88 fa ff ff       	jmp    80104e95 <alltraps>

8010540d <vector37>:
.globl vector37
vector37:
  pushl $0
8010540d:	6a 00                	push   $0x0
  pushl $37
8010540f:	6a 25                	push   $0x25
  jmp alltraps
80105411:	e9 7f fa ff ff       	jmp    80104e95 <alltraps>

80105416 <vector38>:
.globl vector38
vector38:
  pushl $0
80105416:	6a 00                	push   $0x0
  pushl $38
80105418:	6a 26                	push   $0x26
  jmp alltraps
8010541a:	e9 76 fa ff ff       	jmp    80104e95 <alltraps>

8010541f <vector39>:
.globl vector39
vector39:
  pushl $0
8010541f:	6a 00                	push   $0x0
  pushl $39
80105421:	6a 27                	push   $0x27
  jmp alltraps
80105423:	e9 6d fa ff ff       	jmp    80104e95 <alltraps>

80105428 <vector40>:
.globl vector40
vector40:
  pushl $0
80105428:	6a 00                	push   $0x0
  pushl $40
8010542a:	6a 28                	push   $0x28
  jmp alltraps
8010542c:	e9 64 fa ff ff       	jmp    80104e95 <alltraps>

80105431 <vector41>:
.globl vector41
vector41:
  pushl $0
80105431:	6a 00                	push   $0x0
  pushl $41
80105433:	6a 29                	push   $0x29
  jmp alltraps
80105435:	e9 5b fa ff ff       	jmp    80104e95 <alltraps>

8010543a <vector42>:
.globl vector42
vector42:
  pushl $0
8010543a:	6a 00                	push   $0x0
  pushl $42
8010543c:	6a 2a                	push   $0x2a
  jmp alltraps
8010543e:	e9 52 fa ff ff       	jmp    80104e95 <alltraps>

80105443 <vector43>:
.globl vector43
vector43:
  pushl $0
80105443:	6a 00                	push   $0x0
  pushl $43
80105445:	6a 2b                	push   $0x2b
  jmp alltraps
80105447:	e9 49 fa ff ff       	jmp    80104e95 <alltraps>

8010544c <vector44>:
.globl vector44
vector44:
  pushl $0
8010544c:	6a 00                	push   $0x0
  pushl $44
8010544e:	6a 2c                	push   $0x2c
  jmp alltraps
80105450:	e9 40 fa ff ff       	jmp    80104e95 <alltraps>

80105455 <vector45>:
.globl vector45
vector45:
  pushl $0
80105455:	6a 00                	push   $0x0
  pushl $45
80105457:	6a 2d                	push   $0x2d
  jmp alltraps
80105459:	e9 37 fa ff ff       	jmp    80104e95 <alltraps>

8010545e <vector46>:
.globl vector46
vector46:
  pushl $0
8010545e:	6a 00                	push   $0x0
  pushl $46
80105460:	6a 2e                	push   $0x2e
  jmp alltraps
80105462:	e9 2e fa ff ff       	jmp    80104e95 <alltraps>

80105467 <vector47>:
.globl vector47
vector47:
  pushl $0
80105467:	6a 00                	push   $0x0
  pushl $47
80105469:	6a 2f                	push   $0x2f
  jmp alltraps
8010546b:	e9 25 fa ff ff       	jmp    80104e95 <alltraps>

80105470 <vector48>:
.globl vector48
vector48:
  pushl $0
80105470:	6a 00                	push   $0x0
  pushl $48
80105472:	6a 30                	push   $0x30
  jmp alltraps
80105474:	e9 1c fa ff ff       	jmp    80104e95 <alltraps>

80105479 <vector49>:
.globl vector49
vector49:
  pushl $0
80105479:	6a 00                	push   $0x0
  pushl $49
8010547b:	6a 31                	push   $0x31
  jmp alltraps
8010547d:	e9 13 fa ff ff       	jmp    80104e95 <alltraps>

80105482 <vector50>:
.globl vector50
vector50:
  pushl $0
80105482:	6a 00                	push   $0x0
  pushl $50
80105484:	6a 32                	push   $0x32
  jmp alltraps
80105486:	e9 0a fa ff ff       	jmp    80104e95 <alltraps>

8010548b <vector51>:
.globl vector51
vector51:
  pushl $0
8010548b:	6a 00                	push   $0x0
  pushl $51
8010548d:	6a 33                	push   $0x33
  jmp alltraps
8010548f:	e9 01 fa ff ff       	jmp    80104e95 <alltraps>

80105494 <vector52>:
.globl vector52
vector52:
  pushl $0
80105494:	6a 00                	push   $0x0
  pushl $52
80105496:	6a 34                	push   $0x34
  jmp alltraps
80105498:	e9 f8 f9 ff ff       	jmp    80104e95 <alltraps>

8010549d <vector53>:
.globl vector53
vector53:
  pushl $0
8010549d:	6a 00                	push   $0x0
  pushl $53
8010549f:	6a 35                	push   $0x35
  jmp alltraps
801054a1:	e9 ef f9 ff ff       	jmp    80104e95 <alltraps>

801054a6 <vector54>:
.globl vector54
vector54:
  pushl $0
801054a6:	6a 00                	push   $0x0
  pushl $54
801054a8:	6a 36                	push   $0x36
  jmp alltraps
801054aa:	e9 e6 f9 ff ff       	jmp    80104e95 <alltraps>

801054af <vector55>:
.globl vector55
vector55:
  pushl $0
801054af:	6a 00                	push   $0x0
  pushl $55
801054b1:	6a 37                	push   $0x37
  jmp alltraps
801054b3:	e9 dd f9 ff ff       	jmp    80104e95 <alltraps>

801054b8 <vector56>:
.globl vector56
vector56:
  pushl $0
801054b8:	6a 00                	push   $0x0
  pushl $56
801054ba:	6a 38                	push   $0x38
  jmp alltraps
801054bc:	e9 d4 f9 ff ff       	jmp    80104e95 <alltraps>

801054c1 <vector57>:
.globl vector57
vector57:
  pushl $0
801054c1:	6a 00                	push   $0x0
  pushl $57
801054c3:	6a 39                	push   $0x39
  jmp alltraps
801054c5:	e9 cb f9 ff ff       	jmp    80104e95 <alltraps>

801054ca <vector58>:
.globl vector58
vector58:
  pushl $0
801054ca:	6a 00                	push   $0x0
  pushl $58
801054cc:	6a 3a                	push   $0x3a
  jmp alltraps
801054ce:	e9 c2 f9 ff ff       	jmp    80104e95 <alltraps>

801054d3 <vector59>:
.globl vector59
vector59:
  pushl $0
801054d3:	6a 00                	push   $0x0
  pushl $59
801054d5:	6a 3b                	push   $0x3b
  jmp alltraps
801054d7:	e9 b9 f9 ff ff       	jmp    80104e95 <alltraps>

801054dc <vector60>:
.globl vector60
vector60:
  pushl $0
801054dc:	6a 00                	push   $0x0
  pushl $60
801054de:	6a 3c                	push   $0x3c
  jmp alltraps
801054e0:	e9 b0 f9 ff ff       	jmp    80104e95 <alltraps>

801054e5 <vector61>:
.globl vector61
vector61:
  pushl $0
801054e5:	6a 00                	push   $0x0
  pushl $61
801054e7:	6a 3d                	push   $0x3d
  jmp alltraps
801054e9:	e9 a7 f9 ff ff       	jmp    80104e95 <alltraps>

801054ee <vector62>:
.globl vector62
vector62:
  pushl $0
801054ee:	6a 00                	push   $0x0
  pushl $62
801054f0:	6a 3e                	push   $0x3e
  jmp alltraps
801054f2:	e9 9e f9 ff ff       	jmp    80104e95 <alltraps>

801054f7 <vector63>:
.globl vector63
vector63:
  pushl $0
801054f7:	6a 00                	push   $0x0
  pushl $63
801054f9:	6a 3f                	push   $0x3f
  jmp alltraps
801054fb:	e9 95 f9 ff ff       	jmp    80104e95 <alltraps>

80105500 <vector64>:
.globl vector64
vector64:
  pushl $0
80105500:	6a 00                	push   $0x0
  pushl $64
80105502:	6a 40                	push   $0x40
  jmp alltraps
80105504:	e9 8c f9 ff ff       	jmp    80104e95 <alltraps>

80105509 <vector65>:
.globl vector65
vector65:
  pushl $0
80105509:	6a 00                	push   $0x0
  pushl $65
8010550b:	6a 41                	push   $0x41
  jmp alltraps
8010550d:	e9 83 f9 ff ff       	jmp    80104e95 <alltraps>

80105512 <vector66>:
.globl vector66
vector66:
  pushl $0
80105512:	6a 00                	push   $0x0
  pushl $66
80105514:	6a 42                	push   $0x42
  jmp alltraps
80105516:	e9 7a f9 ff ff       	jmp    80104e95 <alltraps>

8010551b <vector67>:
.globl vector67
vector67:
  pushl $0
8010551b:	6a 00                	push   $0x0
  pushl $67
8010551d:	6a 43                	push   $0x43
  jmp alltraps
8010551f:	e9 71 f9 ff ff       	jmp    80104e95 <alltraps>

80105524 <vector68>:
.globl vector68
vector68:
  pushl $0
80105524:	6a 00                	push   $0x0
  pushl $68
80105526:	6a 44                	push   $0x44
  jmp alltraps
80105528:	e9 68 f9 ff ff       	jmp    80104e95 <alltraps>

8010552d <vector69>:
.globl vector69
vector69:
  pushl $0
8010552d:	6a 00                	push   $0x0
  pushl $69
8010552f:	6a 45                	push   $0x45
  jmp alltraps
80105531:	e9 5f f9 ff ff       	jmp    80104e95 <alltraps>

80105536 <vector70>:
.globl vector70
vector70:
  pushl $0
80105536:	6a 00                	push   $0x0
  pushl $70
80105538:	6a 46                	push   $0x46
  jmp alltraps
8010553a:	e9 56 f9 ff ff       	jmp    80104e95 <alltraps>

8010553f <vector71>:
.globl vector71
vector71:
  pushl $0
8010553f:	6a 00                	push   $0x0
  pushl $71
80105541:	6a 47                	push   $0x47
  jmp alltraps
80105543:	e9 4d f9 ff ff       	jmp    80104e95 <alltraps>

80105548 <vector72>:
.globl vector72
vector72:
  pushl $0
80105548:	6a 00                	push   $0x0
  pushl $72
8010554a:	6a 48                	push   $0x48
  jmp alltraps
8010554c:	e9 44 f9 ff ff       	jmp    80104e95 <alltraps>

80105551 <vector73>:
.globl vector73
vector73:
  pushl $0
80105551:	6a 00                	push   $0x0
  pushl $73
80105553:	6a 49                	push   $0x49
  jmp alltraps
80105555:	e9 3b f9 ff ff       	jmp    80104e95 <alltraps>

8010555a <vector74>:
.globl vector74
vector74:
  pushl $0
8010555a:	6a 00                	push   $0x0
  pushl $74
8010555c:	6a 4a                	push   $0x4a
  jmp alltraps
8010555e:	e9 32 f9 ff ff       	jmp    80104e95 <alltraps>

80105563 <vector75>:
.globl vector75
vector75:
  pushl $0
80105563:	6a 00                	push   $0x0
  pushl $75
80105565:	6a 4b                	push   $0x4b
  jmp alltraps
80105567:	e9 29 f9 ff ff       	jmp    80104e95 <alltraps>

8010556c <vector76>:
.globl vector76
vector76:
  pushl $0
8010556c:	6a 00                	push   $0x0
  pushl $76
8010556e:	6a 4c                	push   $0x4c
  jmp alltraps
80105570:	e9 20 f9 ff ff       	jmp    80104e95 <alltraps>

80105575 <vector77>:
.globl vector77
vector77:
  pushl $0
80105575:	6a 00                	push   $0x0
  pushl $77
80105577:	6a 4d                	push   $0x4d
  jmp alltraps
80105579:	e9 17 f9 ff ff       	jmp    80104e95 <alltraps>

8010557e <vector78>:
.globl vector78
vector78:
  pushl $0
8010557e:	6a 00                	push   $0x0
  pushl $78
80105580:	6a 4e                	push   $0x4e
  jmp alltraps
80105582:	e9 0e f9 ff ff       	jmp    80104e95 <alltraps>

80105587 <vector79>:
.globl vector79
vector79:
  pushl $0
80105587:	6a 00                	push   $0x0
  pushl $79
80105589:	6a 4f                	push   $0x4f
  jmp alltraps
8010558b:	e9 05 f9 ff ff       	jmp    80104e95 <alltraps>

80105590 <vector80>:
.globl vector80
vector80:
  pushl $0
80105590:	6a 00                	push   $0x0
  pushl $80
80105592:	6a 50                	push   $0x50
  jmp alltraps
80105594:	e9 fc f8 ff ff       	jmp    80104e95 <alltraps>

80105599 <vector81>:
.globl vector81
vector81:
  pushl $0
80105599:	6a 00                	push   $0x0
  pushl $81
8010559b:	6a 51                	push   $0x51
  jmp alltraps
8010559d:	e9 f3 f8 ff ff       	jmp    80104e95 <alltraps>

801055a2 <vector82>:
.globl vector82
vector82:
  pushl $0
801055a2:	6a 00                	push   $0x0
  pushl $82
801055a4:	6a 52                	push   $0x52
  jmp alltraps
801055a6:	e9 ea f8 ff ff       	jmp    80104e95 <alltraps>

801055ab <vector83>:
.globl vector83
vector83:
  pushl $0
801055ab:	6a 00                	push   $0x0
  pushl $83
801055ad:	6a 53                	push   $0x53
  jmp alltraps
801055af:	e9 e1 f8 ff ff       	jmp    80104e95 <alltraps>

801055b4 <vector84>:
.globl vector84
vector84:
  pushl $0
801055b4:	6a 00                	push   $0x0
  pushl $84
801055b6:	6a 54                	push   $0x54
  jmp alltraps
801055b8:	e9 d8 f8 ff ff       	jmp    80104e95 <alltraps>

801055bd <vector85>:
.globl vector85
vector85:
  pushl $0
801055bd:	6a 00                	push   $0x0
  pushl $85
801055bf:	6a 55                	push   $0x55
  jmp alltraps
801055c1:	e9 cf f8 ff ff       	jmp    80104e95 <alltraps>

801055c6 <vector86>:
.globl vector86
vector86:
  pushl $0
801055c6:	6a 00                	push   $0x0
  pushl $86
801055c8:	6a 56                	push   $0x56
  jmp alltraps
801055ca:	e9 c6 f8 ff ff       	jmp    80104e95 <alltraps>

801055cf <vector87>:
.globl vector87
vector87:
  pushl $0
801055cf:	6a 00                	push   $0x0
  pushl $87
801055d1:	6a 57                	push   $0x57
  jmp alltraps
801055d3:	e9 bd f8 ff ff       	jmp    80104e95 <alltraps>

801055d8 <vector88>:
.globl vector88
vector88:
  pushl $0
801055d8:	6a 00                	push   $0x0
  pushl $88
801055da:	6a 58                	push   $0x58
  jmp alltraps
801055dc:	e9 b4 f8 ff ff       	jmp    80104e95 <alltraps>

801055e1 <vector89>:
.globl vector89
vector89:
  pushl $0
801055e1:	6a 00                	push   $0x0
  pushl $89
801055e3:	6a 59                	push   $0x59
  jmp alltraps
801055e5:	e9 ab f8 ff ff       	jmp    80104e95 <alltraps>

801055ea <vector90>:
.globl vector90
vector90:
  pushl $0
801055ea:	6a 00                	push   $0x0
  pushl $90
801055ec:	6a 5a                	push   $0x5a
  jmp alltraps
801055ee:	e9 a2 f8 ff ff       	jmp    80104e95 <alltraps>

801055f3 <vector91>:
.globl vector91
vector91:
  pushl $0
801055f3:	6a 00                	push   $0x0
  pushl $91
801055f5:	6a 5b                	push   $0x5b
  jmp alltraps
801055f7:	e9 99 f8 ff ff       	jmp    80104e95 <alltraps>

801055fc <vector92>:
.globl vector92
vector92:
  pushl $0
801055fc:	6a 00                	push   $0x0
  pushl $92
801055fe:	6a 5c                	push   $0x5c
  jmp alltraps
80105600:	e9 90 f8 ff ff       	jmp    80104e95 <alltraps>

80105605 <vector93>:
.globl vector93
vector93:
  pushl $0
80105605:	6a 00                	push   $0x0
  pushl $93
80105607:	6a 5d                	push   $0x5d
  jmp alltraps
80105609:	e9 87 f8 ff ff       	jmp    80104e95 <alltraps>

8010560e <vector94>:
.globl vector94
vector94:
  pushl $0
8010560e:	6a 00                	push   $0x0
  pushl $94
80105610:	6a 5e                	push   $0x5e
  jmp alltraps
80105612:	e9 7e f8 ff ff       	jmp    80104e95 <alltraps>

80105617 <vector95>:
.globl vector95
vector95:
  pushl $0
80105617:	6a 00                	push   $0x0
  pushl $95
80105619:	6a 5f                	push   $0x5f
  jmp alltraps
8010561b:	e9 75 f8 ff ff       	jmp    80104e95 <alltraps>

80105620 <vector96>:
.globl vector96
vector96:
  pushl $0
80105620:	6a 00                	push   $0x0
  pushl $96
80105622:	6a 60                	push   $0x60
  jmp alltraps
80105624:	e9 6c f8 ff ff       	jmp    80104e95 <alltraps>

80105629 <vector97>:
.globl vector97
vector97:
  pushl $0
80105629:	6a 00                	push   $0x0
  pushl $97
8010562b:	6a 61                	push   $0x61
  jmp alltraps
8010562d:	e9 63 f8 ff ff       	jmp    80104e95 <alltraps>

80105632 <vector98>:
.globl vector98
vector98:
  pushl $0
80105632:	6a 00                	push   $0x0
  pushl $98
80105634:	6a 62                	push   $0x62
  jmp alltraps
80105636:	e9 5a f8 ff ff       	jmp    80104e95 <alltraps>

8010563b <vector99>:
.globl vector99
vector99:
  pushl $0
8010563b:	6a 00                	push   $0x0
  pushl $99
8010563d:	6a 63                	push   $0x63
  jmp alltraps
8010563f:	e9 51 f8 ff ff       	jmp    80104e95 <alltraps>

80105644 <vector100>:
.globl vector100
vector100:
  pushl $0
80105644:	6a 00                	push   $0x0
  pushl $100
80105646:	6a 64                	push   $0x64
  jmp alltraps
80105648:	e9 48 f8 ff ff       	jmp    80104e95 <alltraps>

8010564d <vector101>:
.globl vector101
vector101:
  pushl $0
8010564d:	6a 00                	push   $0x0
  pushl $101
8010564f:	6a 65                	push   $0x65
  jmp alltraps
80105651:	e9 3f f8 ff ff       	jmp    80104e95 <alltraps>

80105656 <vector102>:
.globl vector102
vector102:
  pushl $0
80105656:	6a 00                	push   $0x0
  pushl $102
80105658:	6a 66                	push   $0x66
  jmp alltraps
8010565a:	e9 36 f8 ff ff       	jmp    80104e95 <alltraps>

8010565f <vector103>:
.globl vector103
vector103:
  pushl $0
8010565f:	6a 00                	push   $0x0
  pushl $103
80105661:	6a 67                	push   $0x67
  jmp alltraps
80105663:	e9 2d f8 ff ff       	jmp    80104e95 <alltraps>

80105668 <vector104>:
.globl vector104
vector104:
  pushl $0
80105668:	6a 00                	push   $0x0
  pushl $104
8010566a:	6a 68                	push   $0x68
  jmp alltraps
8010566c:	e9 24 f8 ff ff       	jmp    80104e95 <alltraps>

80105671 <vector105>:
.globl vector105
vector105:
  pushl $0
80105671:	6a 00                	push   $0x0
  pushl $105
80105673:	6a 69                	push   $0x69
  jmp alltraps
80105675:	e9 1b f8 ff ff       	jmp    80104e95 <alltraps>

8010567a <vector106>:
.globl vector106
vector106:
  pushl $0
8010567a:	6a 00                	push   $0x0
  pushl $106
8010567c:	6a 6a                	push   $0x6a
  jmp alltraps
8010567e:	e9 12 f8 ff ff       	jmp    80104e95 <alltraps>

80105683 <vector107>:
.globl vector107
vector107:
  pushl $0
80105683:	6a 00                	push   $0x0
  pushl $107
80105685:	6a 6b                	push   $0x6b
  jmp alltraps
80105687:	e9 09 f8 ff ff       	jmp    80104e95 <alltraps>

8010568c <vector108>:
.globl vector108
vector108:
  pushl $0
8010568c:	6a 00                	push   $0x0
  pushl $108
8010568e:	6a 6c                	push   $0x6c
  jmp alltraps
80105690:	e9 00 f8 ff ff       	jmp    80104e95 <alltraps>

80105695 <vector109>:
.globl vector109
vector109:
  pushl $0
80105695:	6a 00                	push   $0x0
  pushl $109
80105697:	6a 6d                	push   $0x6d
  jmp alltraps
80105699:	e9 f7 f7 ff ff       	jmp    80104e95 <alltraps>

8010569e <vector110>:
.globl vector110
vector110:
  pushl $0
8010569e:	6a 00                	push   $0x0
  pushl $110
801056a0:	6a 6e                	push   $0x6e
  jmp alltraps
801056a2:	e9 ee f7 ff ff       	jmp    80104e95 <alltraps>

801056a7 <vector111>:
.globl vector111
vector111:
  pushl $0
801056a7:	6a 00                	push   $0x0
  pushl $111
801056a9:	6a 6f                	push   $0x6f
  jmp alltraps
801056ab:	e9 e5 f7 ff ff       	jmp    80104e95 <alltraps>

801056b0 <vector112>:
.globl vector112
vector112:
  pushl $0
801056b0:	6a 00                	push   $0x0
  pushl $112
801056b2:	6a 70                	push   $0x70
  jmp alltraps
801056b4:	e9 dc f7 ff ff       	jmp    80104e95 <alltraps>

801056b9 <vector113>:
.globl vector113
vector113:
  pushl $0
801056b9:	6a 00                	push   $0x0
  pushl $113
801056bb:	6a 71                	push   $0x71
  jmp alltraps
801056bd:	e9 d3 f7 ff ff       	jmp    80104e95 <alltraps>

801056c2 <vector114>:
.globl vector114
vector114:
  pushl $0
801056c2:	6a 00                	push   $0x0
  pushl $114
801056c4:	6a 72                	push   $0x72
  jmp alltraps
801056c6:	e9 ca f7 ff ff       	jmp    80104e95 <alltraps>

801056cb <vector115>:
.globl vector115
vector115:
  pushl $0
801056cb:	6a 00                	push   $0x0
  pushl $115
801056cd:	6a 73                	push   $0x73
  jmp alltraps
801056cf:	e9 c1 f7 ff ff       	jmp    80104e95 <alltraps>

801056d4 <vector116>:
.globl vector116
vector116:
  pushl $0
801056d4:	6a 00                	push   $0x0
  pushl $116
801056d6:	6a 74                	push   $0x74
  jmp alltraps
801056d8:	e9 b8 f7 ff ff       	jmp    80104e95 <alltraps>

801056dd <vector117>:
.globl vector117
vector117:
  pushl $0
801056dd:	6a 00                	push   $0x0
  pushl $117
801056df:	6a 75                	push   $0x75
  jmp alltraps
801056e1:	e9 af f7 ff ff       	jmp    80104e95 <alltraps>

801056e6 <vector118>:
.globl vector118
vector118:
  pushl $0
801056e6:	6a 00                	push   $0x0
  pushl $118
801056e8:	6a 76                	push   $0x76
  jmp alltraps
801056ea:	e9 a6 f7 ff ff       	jmp    80104e95 <alltraps>

801056ef <vector119>:
.globl vector119
vector119:
  pushl $0
801056ef:	6a 00                	push   $0x0
  pushl $119
801056f1:	6a 77                	push   $0x77
  jmp alltraps
801056f3:	e9 9d f7 ff ff       	jmp    80104e95 <alltraps>

801056f8 <vector120>:
.globl vector120
vector120:
  pushl $0
801056f8:	6a 00                	push   $0x0
  pushl $120
801056fa:	6a 78                	push   $0x78
  jmp alltraps
801056fc:	e9 94 f7 ff ff       	jmp    80104e95 <alltraps>

80105701 <vector121>:
.globl vector121
vector121:
  pushl $0
80105701:	6a 00                	push   $0x0
  pushl $121
80105703:	6a 79                	push   $0x79
  jmp alltraps
80105705:	e9 8b f7 ff ff       	jmp    80104e95 <alltraps>

8010570a <vector122>:
.globl vector122
vector122:
  pushl $0
8010570a:	6a 00                	push   $0x0
  pushl $122
8010570c:	6a 7a                	push   $0x7a
  jmp alltraps
8010570e:	e9 82 f7 ff ff       	jmp    80104e95 <alltraps>

80105713 <vector123>:
.globl vector123
vector123:
  pushl $0
80105713:	6a 00                	push   $0x0
  pushl $123
80105715:	6a 7b                	push   $0x7b
  jmp alltraps
80105717:	e9 79 f7 ff ff       	jmp    80104e95 <alltraps>

8010571c <vector124>:
.globl vector124
vector124:
  pushl $0
8010571c:	6a 00                	push   $0x0
  pushl $124
8010571e:	6a 7c                	push   $0x7c
  jmp alltraps
80105720:	e9 70 f7 ff ff       	jmp    80104e95 <alltraps>

80105725 <vector125>:
.globl vector125
vector125:
  pushl $0
80105725:	6a 00                	push   $0x0
  pushl $125
80105727:	6a 7d                	push   $0x7d
  jmp alltraps
80105729:	e9 67 f7 ff ff       	jmp    80104e95 <alltraps>

8010572e <vector126>:
.globl vector126
vector126:
  pushl $0
8010572e:	6a 00                	push   $0x0
  pushl $126
80105730:	6a 7e                	push   $0x7e
  jmp alltraps
80105732:	e9 5e f7 ff ff       	jmp    80104e95 <alltraps>

80105737 <vector127>:
.globl vector127
vector127:
  pushl $0
80105737:	6a 00                	push   $0x0
  pushl $127
80105739:	6a 7f                	push   $0x7f
  jmp alltraps
8010573b:	e9 55 f7 ff ff       	jmp    80104e95 <alltraps>

80105740 <vector128>:
.globl vector128
vector128:
  pushl $0
80105740:	6a 00                	push   $0x0
  pushl $128
80105742:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105747:	e9 49 f7 ff ff       	jmp    80104e95 <alltraps>

8010574c <vector129>:
.globl vector129
vector129:
  pushl $0
8010574c:	6a 00                	push   $0x0
  pushl $129
8010574e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105753:	e9 3d f7 ff ff       	jmp    80104e95 <alltraps>

80105758 <vector130>:
.globl vector130
vector130:
  pushl $0
80105758:	6a 00                	push   $0x0
  pushl $130
8010575a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010575f:	e9 31 f7 ff ff       	jmp    80104e95 <alltraps>

80105764 <vector131>:
.globl vector131
vector131:
  pushl $0
80105764:	6a 00                	push   $0x0
  pushl $131
80105766:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010576b:	e9 25 f7 ff ff       	jmp    80104e95 <alltraps>

80105770 <vector132>:
.globl vector132
vector132:
  pushl $0
80105770:	6a 00                	push   $0x0
  pushl $132
80105772:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105777:	e9 19 f7 ff ff       	jmp    80104e95 <alltraps>

8010577c <vector133>:
.globl vector133
vector133:
  pushl $0
8010577c:	6a 00                	push   $0x0
  pushl $133
8010577e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105783:	e9 0d f7 ff ff       	jmp    80104e95 <alltraps>

80105788 <vector134>:
.globl vector134
vector134:
  pushl $0
80105788:	6a 00                	push   $0x0
  pushl $134
8010578a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010578f:	e9 01 f7 ff ff       	jmp    80104e95 <alltraps>

80105794 <vector135>:
.globl vector135
vector135:
  pushl $0
80105794:	6a 00                	push   $0x0
  pushl $135
80105796:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010579b:	e9 f5 f6 ff ff       	jmp    80104e95 <alltraps>

801057a0 <vector136>:
.globl vector136
vector136:
  pushl $0
801057a0:	6a 00                	push   $0x0
  pushl $136
801057a2:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057a7:	e9 e9 f6 ff ff       	jmp    80104e95 <alltraps>

801057ac <vector137>:
.globl vector137
vector137:
  pushl $0
801057ac:	6a 00                	push   $0x0
  pushl $137
801057ae:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057b3:	e9 dd f6 ff ff       	jmp    80104e95 <alltraps>

801057b8 <vector138>:
.globl vector138
vector138:
  pushl $0
801057b8:	6a 00                	push   $0x0
  pushl $138
801057ba:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801057bf:	e9 d1 f6 ff ff       	jmp    80104e95 <alltraps>

801057c4 <vector139>:
.globl vector139
vector139:
  pushl $0
801057c4:	6a 00                	push   $0x0
  pushl $139
801057c6:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801057cb:	e9 c5 f6 ff ff       	jmp    80104e95 <alltraps>

801057d0 <vector140>:
.globl vector140
vector140:
  pushl $0
801057d0:	6a 00                	push   $0x0
  pushl $140
801057d2:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801057d7:	e9 b9 f6 ff ff       	jmp    80104e95 <alltraps>

801057dc <vector141>:
.globl vector141
vector141:
  pushl $0
801057dc:	6a 00                	push   $0x0
  pushl $141
801057de:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801057e3:	e9 ad f6 ff ff       	jmp    80104e95 <alltraps>

801057e8 <vector142>:
.globl vector142
vector142:
  pushl $0
801057e8:	6a 00                	push   $0x0
  pushl $142
801057ea:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801057ef:	e9 a1 f6 ff ff       	jmp    80104e95 <alltraps>

801057f4 <vector143>:
.globl vector143
vector143:
  pushl $0
801057f4:	6a 00                	push   $0x0
  pushl $143
801057f6:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801057fb:	e9 95 f6 ff ff       	jmp    80104e95 <alltraps>

80105800 <vector144>:
.globl vector144
vector144:
  pushl $0
80105800:	6a 00                	push   $0x0
  pushl $144
80105802:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105807:	e9 89 f6 ff ff       	jmp    80104e95 <alltraps>

8010580c <vector145>:
.globl vector145
vector145:
  pushl $0
8010580c:	6a 00                	push   $0x0
  pushl $145
8010580e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105813:	e9 7d f6 ff ff       	jmp    80104e95 <alltraps>

80105818 <vector146>:
.globl vector146
vector146:
  pushl $0
80105818:	6a 00                	push   $0x0
  pushl $146
8010581a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010581f:	e9 71 f6 ff ff       	jmp    80104e95 <alltraps>

80105824 <vector147>:
.globl vector147
vector147:
  pushl $0
80105824:	6a 00                	push   $0x0
  pushl $147
80105826:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010582b:	e9 65 f6 ff ff       	jmp    80104e95 <alltraps>

80105830 <vector148>:
.globl vector148
vector148:
  pushl $0
80105830:	6a 00                	push   $0x0
  pushl $148
80105832:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105837:	e9 59 f6 ff ff       	jmp    80104e95 <alltraps>

8010583c <vector149>:
.globl vector149
vector149:
  pushl $0
8010583c:	6a 00                	push   $0x0
  pushl $149
8010583e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105843:	e9 4d f6 ff ff       	jmp    80104e95 <alltraps>

80105848 <vector150>:
.globl vector150
vector150:
  pushl $0
80105848:	6a 00                	push   $0x0
  pushl $150
8010584a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010584f:	e9 41 f6 ff ff       	jmp    80104e95 <alltraps>

80105854 <vector151>:
.globl vector151
vector151:
  pushl $0
80105854:	6a 00                	push   $0x0
  pushl $151
80105856:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010585b:	e9 35 f6 ff ff       	jmp    80104e95 <alltraps>

80105860 <vector152>:
.globl vector152
vector152:
  pushl $0
80105860:	6a 00                	push   $0x0
  pushl $152
80105862:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105867:	e9 29 f6 ff ff       	jmp    80104e95 <alltraps>

8010586c <vector153>:
.globl vector153
vector153:
  pushl $0
8010586c:	6a 00                	push   $0x0
  pushl $153
8010586e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105873:	e9 1d f6 ff ff       	jmp    80104e95 <alltraps>

80105878 <vector154>:
.globl vector154
vector154:
  pushl $0
80105878:	6a 00                	push   $0x0
  pushl $154
8010587a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010587f:	e9 11 f6 ff ff       	jmp    80104e95 <alltraps>

80105884 <vector155>:
.globl vector155
vector155:
  pushl $0
80105884:	6a 00                	push   $0x0
  pushl $155
80105886:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010588b:	e9 05 f6 ff ff       	jmp    80104e95 <alltraps>

80105890 <vector156>:
.globl vector156
vector156:
  pushl $0
80105890:	6a 00                	push   $0x0
  pushl $156
80105892:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105897:	e9 f9 f5 ff ff       	jmp    80104e95 <alltraps>

8010589c <vector157>:
.globl vector157
vector157:
  pushl $0
8010589c:	6a 00                	push   $0x0
  pushl $157
8010589e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058a3:	e9 ed f5 ff ff       	jmp    80104e95 <alltraps>

801058a8 <vector158>:
.globl vector158
vector158:
  pushl $0
801058a8:	6a 00                	push   $0x0
  pushl $158
801058aa:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058af:	e9 e1 f5 ff ff       	jmp    80104e95 <alltraps>

801058b4 <vector159>:
.globl vector159
vector159:
  pushl $0
801058b4:	6a 00                	push   $0x0
  pushl $159
801058b6:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801058bb:	e9 d5 f5 ff ff       	jmp    80104e95 <alltraps>

801058c0 <vector160>:
.globl vector160
vector160:
  pushl $0
801058c0:	6a 00                	push   $0x0
  pushl $160
801058c2:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801058c7:	e9 c9 f5 ff ff       	jmp    80104e95 <alltraps>

801058cc <vector161>:
.globl vector161
vector161:
  pushl $0
801058cc:	6a 00                	push   $0x0
  pushl $161
801058ce:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801058d3:	e9 bd f5 ff ff       	jmp    80104e95 <alltraps>

801058d8 <vector162>:
.globl vector162
vector162:
  pushl $0
801058d8:	6a 00                	push   $0x0
  pushl $162
801058da:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801058df:	e9 b1 f5 ff ff       	jmp    80104e95 <alltraps>

801058e4 <vector163>:
.globl vector163
vector163:
  pushl $0
801058e4:	6a 00                	push   $0x0
  pushl $163
801058e6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801058eb:	e9 a5 f5 ff ff       	jmp    80104e95 <alltraps>

801058f0 <vector164>:
.globl vector164
vector164:
  pushl $0
801058f0:	6a 00                	push   $0x0
  pushl $164
801058f2:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801058f7:	e9 99 f5 ff ff       	jmp    80104e95 <alltraps>

801058fc <vector165>:
.globl vector165
vector165:
  pushl $0
801058fc:	6a 00                	push   $0x0
  pushl $165
801058fe:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105903:	e9 8d f5 ff ff       	jmp    80104e95 <alltraps>

80105908 <vector166>:
.globl vector166
vector166:
  pushl $0
80105908:	6a 00                	push   $0x0
  pushl $166
8010590a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010590f:	e9 81 f5 ff ff       	jmp    80104e95 <alltraps>

80105914 <vector167>:
.globl vector167
vector167:
  pushl $0
80105914:	6a 00                	push   $0x0
  pushl $167
80105916:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010591b:	e9 75 f5 ff ff       	jmp    80104e95 <alltraps>

80105920 <vector168>:
.globl vector168
vector168:
  pushl $0
80105920:	6a 00                	push   $0x0
  pushl $168
80105922:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105927:	e9 69 f5 ff ff       	jmp    80104e95 <alltraps>

8010592c <vector169>:
.globl vector169
vector169:
  pushl $0
8010592c:	6a 00                	push   $0x0
  pushl $169
8010592e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105933:	e9 5d f5 ff ff       	jmp    80104e95 <alltraps>

80105938 <vector170>:
.globl vector170
vector170:
  pushl $0
80105938:	6a 00                	push   $0x0
  pushl $170
8010593a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010593f:	e9 51 f5 ff ff       	jmp    80104e95 <alltraps>

80105944 <vector171>:
.globl vector171
vector171:
  pushl $0
80105944:	6a 00                	push   $0x0
  pushl $171
80105946:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010594b:	e9 45 f5 ff ff       	jmp    80104e95 <alltraps>

80105950 <vector172>:
.globl vector172
vector172:
  pushl $0
80105950:	6a 00                	push   $0x0
  pushl $172
80105952:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105957:	e9 39 f5 ff ff       	jmp    80104e95 <alltraps>

8010595c <vector173>:
.globl vector173
vector173:
  pushl $0
8010595c:	6a 00                	push   $0x0
  pushl $173
8010595e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105963:	e9 2d f5 ff ff       	jmp    80104e95 <alltraps>

80105968 <vector174>:
.globl vector174
vector174:
  pushl $0
80105968:	6a 00                	push   $0x0
  pushl $174
8010596a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010596f:	e9 21 f5 ff ff       	jmp    80104e95 <alltraps>

80105974 <vector175>:
.globl vector175
vector175:
  pushl $0
80105974:	6a 00                	push   $0x0
  pushl $175
80105976:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010597b:	e9 15 f5 ff ff       	jmp    80104e95 <alltraps>

80105980 <vector176>:
.globl vector176
vector176:
  pushl $0
80105980:	6a 00                	push   $0x0
  pushl $176
80105982:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105987:	e9 09 f5 ff ff       	jmp    80104e95 <alltraps>

8010598c <vector177>:
.globl vector177
vector177:
  pushl $0
8010598c:	6a 00                	push   $0x0
  pushl $177
8010598e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105993:	e9 fd f4 ff ff       	jmp    80104e95 <alltraps>

80105998 <vector178>:
.globl vector178
vector178:
  pushl $0
80105998:	6a 00                	push   $0x0
  pushl $178
8010599a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010599f:	e9 f1 f4 ff ff       	jmp    80104e95 <alltraps>

801059a4 <vector179>:
.globl vector179
vector179:
  pushl $0
801059a4:	6a 00                	push   $0x0
  pushl $179
801059a6:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059ab:	e9 e5 f4 ff ff       	jmp    80104e95 <alltraps>

801059b0 <vector180>:
.globl vector180
vector180:
  pushl $0
801059b0:	6a 00                	push   $0x0
  pushl $180
801059b2:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801059b7:	e9 d9 f4 ff ff       	jmp    80104e95 <alltraps>

801059bc <vector181>:
.globl vector181
vector181:
  pushl $0
801059bc:	6a 00                	push   $0x0
  pushl $181
801059be:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801059c3:	e9 cd f4 ff ff       	jmp    80104e95 <alltraps>

801059c8 <vector182>:
.globl vector182
vector182:
  pushl $0
801059c8:	6a 00                	push   $0x0
  pushl $182
801059ca:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801059cf:	e9 c1 f4 ff ff       	jmp    80104e95 <alltraps>

801059d4 <vector183>:
.globl vector183
vector183:
  pushl $0
801059d4:	6a 00                	push   $0x0
  pushl $183
801059d6:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801059db:	e9 b5 f4 ff ff       	jmp    80104e95 <alltraps>

801059e0 <vector184>:
.globl vector184
vector184:
  pushl $0
801059e0:	6a 00                	push   $0x0
  pushl $184
801059e2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801059e7:	e9 a9 f4 ff ff       	jmp    80104e95 <alltraps>

801059ec <vector185>:
.globl vector185
vector185:
  pushl $0
801059ec:	6a 00                	push   $0x0
  pushl $185
801059ee:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801059f3:	e9 9d f4 ff ff       	jmp    80104e95 <alltraps>

801059f8 <vector186>:
.globl vector186
vector186:
  pushl $0
801059f8:	6a 00                	push   $0x0
  pushl $186
801059fa:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801059ff:	e9 91 f4 ff ff       	jmp    80104e95 <alltraps>

80105a04 <vector187>:
.globl vector187
vector187:
  pushl $0
80105a04:	6a 00                	push   $0x0
  pushl $187
80105a06:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a0b:	e9 85 f4 ff ff       	jmp    80104e95 <alltraps>

80105a10 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a10:	6a 00                	push   $0x0
  pushl $188
80105a12:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a17:	e9 79 f4 ff ff       	jmp    80104e95 <alltraps>

80105a1c <vector189>:
.globl vector189
vector189:
  pushl $0
80105a1c:	6a 00                	push   $0x0
  pushl $189
80105a1e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a23:	e9 6d f4 ff ff       	jmp    80104e95 <alltraps>

80105a28 <vector190>:
.globl vector190
vector190:
  pushl $0
80105a28:	6a 00                	push   $0x0
  pushl $190
80105a2a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a2f:	e9 61 f4 ff ff       	jmp    80104e95 <alltraps>

80105a34 <vector191>:
.globl vector191
vector191:
  pushl $0
80105a34:	6a 00                	push   $0x0
  pushl $191
80105a36:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a3b:	e9 55 f4 ff ff       	jmp    80104e95 <alltraps>

80105a40 <vector192>:
.globl vector192
vector192:
  pushl $0
80105a40:	6a 00                	push   $0x0
  pushl $192
80105a42:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a47:	e9 49 f4 ff ff       	jmp    80104e95 <alltraps>

80105a4c <vector193>:
.globl vector193
vector193:
  pushl $0
80105a4c:	6a 00                	push   $0x0
  pushl $193
80105a4e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a53:	e9 3d f4 ff ff       	jmp    80104e95 <alltraps>

80105a58 <vector194>:
.globl vector194
vector194:
  pushl $0
80105a58:	6a 00                	push   $0x0
  pushl $194
80105a5a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105a5f:	e9 31 f4 ff ff       	jmp    80104e95 <alltraps>

80105a64 <vector195>:
.globl vector195
vector195:
  pushl $0
80105a64:	6a 00                	push   $0x0
  pushl $195
80105a66:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105a6b:	e9 25 f4 ff ff       	jmp    80104e95 <alltraps>

80105a70 <vector196>:
.globl vector196
vector196:
  pushl $0
80105a70:	6a 00                	push   $0x0
  pushl $196
80105a72:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105a77:	e9 19 f4 ff ff       	jmp    80104e95 <alltraps>

80105a7c <vector197>:
.globl vector197
vector197:
  pushl $0
80105a7c:	6a 00                	push   $0x0
  pushl $197
80105a7e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105a83:	e9 0d f4 ff ff       	jmp    80104e95 <alltraps>

80105a88 <vector198>:
.globl vector198
vector198:
  pushl $0
80105a88:	6a 00                	push   $0x0
  pushl $198
80105a8a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105a8f:	e9 01 f4 ff ff       	jmp    80104e95 <alltraps>

80105a94 <vector199>:
.globl vector199
vector199:
  pushl $0
80105a94:	6a 00                	push   $0x0
  pushl $199
80105a96:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105a9b:	e9 f5 f3 ff ff       	jmp    80104e95 <alltraps>

80105aa0 <vector200>:
.globl vector200
vector200:
  pushl $0
80105aa0:	6a 00                	push   $0x0
  pushl $200
80105aa2:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105aa7:	e9 e9 f3 ff ff       	jmp    80104e95 <alltraps>

80105aac <vector201>:
.globl vector201
vector201:
  pushl $0
80105aac:	6a 00                	push   $0x0
  pushl $201
80105aae:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105ab3:	e9 dd f3 ff ff       	jmp    80104e95 <alltraps>

80105ab8 <vector202>:
.globl vector202
vector202:
  pushl $0
80105ab8:	6a 00                	push   $0x0
  pushl $202
80105aba:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105abf:	e9 d1 f3 ff ff       	jmp    80104e95 <alltraps>

80105ac4 <vector203>:
.globl vector203
vector203:
  pushl $0
80105ac4:	6a 00                	push   $0x0
  pushl $203
80105ac6:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105acb:	e9 c5 f3 ff ff       	jmp    80104e95 <alltraps>

80105ad0 <vector204>:
.globl vector204
vector204:
  pushl $0
80105ad0:	6a 00                	push   $0x0
  pushl $204
80105ad2:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105ad7:	e9 b9 f3 ff ff       	jmp    80104e95 <alltraps>

80105adc <vector205>:
.globl vector205
vector205:
  pushl $0
80105adc:	6a 00                	push   $0x0
  pushl $205
80105ade:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105ae3:	e9 ad f3 ff ff       	jmp    80104e95 <alltraps>

80105ae8 <vector206>:
.globl vector206
vector206:
  pushl $0
80105ae8:	6a 00                	push   $0x0
  pushl $206
80105aea:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105aef:	e9 a1 f3 ff ff       	jmp    80104e95 <alltraps>

80105af4 <vector207>:
.globl vector207
vector207:
  pushl $0
80105af4:	6a 00                	push   $0x0
  pushl $207
80105af6:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105afb:	e9 95 f3 ff ff       	jmp    80104e95 <alltraps>

80105b00 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b00:	6a 00                	push   $0x0
  pushl $208
80105b02:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b07:	e9 89 f3 ff ff       	jmp    80104e95 <alltraps>

80105b0c <vector209>:
.globl vector209
vector209:
  pushl $0
80105b0c:	6a 00                	push   $0x0
  pushl $209
80105b0e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b13:	e9 7d f3 ff ff       	jmp    80104e95 <alltraps>

80105b18 <vector210>:
.globl vector210
vector210:
  pushl $0
80105b18:	6a 00                	push   $0x0
  pushl $210
80105b1a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b1f:	e9 71 f3 ff ff       	jmp    80104e95 <alltraps>

80105b24 <vector211>:
.globl vector211
vector211:
  pushl $0
80105b24:	6a 00                	push   $0x0
  pushl $211
80105b26:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b2b:	e9 65 f3 ff ff       	jmp    80104e95 <alltraps>

80105b30 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b30:	6a 00                	push   $0x0
  pushl $212
80105b32:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b37:	e9 59 f3 ff ff       	jmp    80104e95 <alltraps>

80105b3c <vector213>:
.globl vector213
vector213:
  pushl $0
80105b3c:	6a 00                	push   $0x0
  pushl $213
80105b3e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b43:	e9 4d f3 ff ff       	jmp    80104e95 <alltraps>

80105b48 <vector214>:
.globl vector214
vector214:
  pushl $0
80105b48:	6a 00                	push   $0x0
  pushl $214
80105b4a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b4f:	e9 41 f3 ff ff       	jmp    80104e95 <alltraps>

80105b54 <vector215>:
.globl vector215
vector215:
  pushl $0
80105b54:	6a 00                	push   $0x0
  pushl $215
80105b56:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105b5b:	e9 35 f3 ff ff       	jmp    80104e95 <alltraps>

80105b60 <vector216>:
.globl vector216
vector216:
  pushl $0
80105b60:	6a 00                	push   $0x0
  pushl $216
80105b62:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105b67:	e9 29 f3 ff ff       	jmp    80104e95 <alltraps>

80105b6c <vector217>:
.globl vector217
vector217:
  pushl $0
80105b6c:	6a 00                	push   $0x0
  pushl $217
80105b6e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105b73:	e9 1d f3 ff ff       	jmp    80104e95 <alltraps>

80105b78 <vector218>:
.globl vector218
vector218:
  pushl $0
80105b78:	6a 00                	push   $0x0
  pushl $218
80105b7a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105b7f:	e9 11 f3 ff ff       	jmp    80104e95 <alltraps>

80105b84 <vector219>:
.globl vector219
vector219:
  pushl $0
80105b84:	6a 00                	push   $0x0
  pushl $219
80105b86:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105b8b:	e9 05 f3 ff ff       	jmp    80104e95 <alltraps>

80105b90 <vector220>:
.globl vector220
vector220:
  pushl $0
80105b90:	6a 00                	push   $0x0
  pushl $220
80105b92:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105b97:	e9 f9 f2 ff ff       	jmp    80104e95 <alltraps>

80105b9c <vector221>:
.globl vector221
vector221:
  pushl $0
80105b9c:	6a 00                	push   $0x0
  pushl $221
80105b9e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105ba3:	e9 ed f2 ff ff       	jmp    80104e95 <alltraps>

80105ba8 <vector222>:
.globl vector222
vector222:
  pushl $0
80105ba8:	6a 00                	push   $0x0
  pushl $222
80105baa:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105baf:	e9 e1 f2 ff ff       	jmp    80104e95 <alltraps>

80105bb4 <vector223>:
.globl vector223
vector223:
  pushl $0
80105bb4:	6a 00                	push   $0x0
  pushl $223
80105bb6:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105bbb:	e9 d5 f2 ff ff       	jmp    80104e95 <alltraps>

80105bc0 <vector224>:
.globl vector224
vector224:
  pushl $0
80105bc0:	6a 00                	push   $0x0
  pushl $224
80105bc2:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105bc7:	e9 c9 f2 ff ff       	jmp    80104e95 <alltraps>

80105bcc <vector225>:
.globl vector225
vector225:
  pushl $0
80105bcc:	6a 00                	push   $0x0
  pushl $225
80105bce:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105bd3:	e9 bd f2 ff ff       	jmp    80104e95 <alltraps>

80105bd8 <vector226>:
.globl vector226
vector226:
  pushl $0
80105bd8:	6a 00                	push   $0x0
  pushl $226
80105bda:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105bdf:	e9 b1 f2 ff ff       	jmp    80104e95 <alltraps>

80105be4 <vector227>:
.globl vector227
vector227:
  pushl $0
80105be4:	6a 00                	push   $0x0
  pushl $227
80105be6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105beb:	e9 a5 f2 ff ff       	jmp    80104e95 <alltraps>

80105bf0 <vector228>:
.globl vector228
vector228:
  pushl $0
80105bf0:	6a 00                	push   $0x0
  pushl $228
80105bf2:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105bf7:	e9 99 f2 ff ff       	jmp    80104e95 <alltraps>

80105bfc <vector229>:
.globl vector229
vector229:
  pushl $0
80105bfc:	6a 00                	push   $0x0
  pushl $229
80105bfe:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c03:	e9 8d f2 ff ff       	jmp    80104e95 <alltraps>

80105c08 <vector230>:
.globl vector230
vector230:
  pushl $0
80105c08:	6a 00                	push   $0x0
  pushl $230
80105c0a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c0f:	e9 81 f2 ff ff       	jmp    80104e95 <alltraps>

80105c14 <vector231>:
.globl vector231
vector231:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $231
80105c16:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c1b:	e9 75 f2 ff ff       	jmp    80104e95 <alltraps>

80105c20 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c20:	6a 00                	push   $0x0
  pushl $232
80105c22:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c27:	e9 69 f2 ff ff       	jmp    80104e95 <alltraps>

80105c2c <vector233>:
.globl vector233
vector233:
  pushl $0
80105c2c:	6a 00                	push   $0x0
  pushl $233
80105c2e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c33:	e9 5d f2 ff ff       	jmp    80104e95 <alltraps>

80105c38 <vector234>:
.globl vector234
vector234:
  pushl $0
80105c38:	6a 00                	push   $0x0
  pushl $234
80105c3a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c3f:	e9 51 f2 ff ff       	jmp    80104e95 <alltraps>

80105c44 <vector235>:
.globl vector235
vector235:
  pushl $0
80105c44:	6a 00                	push   $0x0
  pushl $235
80105c46:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c4b:	e9 45 f2 ff ff       	jmp    80104e95 <alltraps>

80105c50 <vector236>:
.globl vector236
vector236:
  pushl $0
80105c50:	6a 00                	push   $0x0
  pushl $236
80105c52:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105c57:	e9 39 f2 ff ff       	jmp    80104e95 <alltraps>

80105c5c <vector237>:
.globl vector237
vector237:
  pushl $0
80105c5c:	6a 00                	push   $0x0
  pushl $237
80105c5e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105c63:	e9 2d f2 ff ff       	jmp    80104e95 <alltraps>

80105c68 <vector238>:
.globl vector238
vector238:
  pushl $0
80105c68:	6a 00                	push   $0x0
  pushl $238
80105c6a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105c6f:	e9 21 f2 ff ff       	jmp    80104e95 <alltraps>

80105c74 <vector239>:
.globl vector239
vector239:
  pushl $0
80105c74:	6a 00                	push   $0x0
  pushl $239
80105c76:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105c7b:	e9 15 f2 ff ff       	jmp    80104e95 <alltraps>

80105c80 <vector240>:
.globl vector240
vector240:
  pushl $0
80105c80:	6a 00                	push   $0x0
  pushl $240
80105c82:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105c87:	e9 09 f2 ff ff       	jmp    80104e95 <alltraps>

80105c8c <vector241>:
.globl vector241
vector241:
  pushl $0
80105c8c:	6a 00                	push   $0x0
  pushl $241
80105c8e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105c93:	e9 fd f1 ff ff       	jmp    80104e95 <alltraps>

80105c98 <vector242>:
.globl vector242
vector242:
  pushl $0
80105c98:	6a 00                	push   $0x0
  pushl $242
80105c9a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105c9f:	e9 f1 f1 ff ff       	jmp    80104e95 <alltraps>

80105ca4 <vector243>:
.globl vector243
vector243:
  pushl $0
80105ca4:	6a 00                	push   $0x0
  pushl $243
80105ca6:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cab:	e9 e5 f1 ff ff       	jmp    80104e95 <alltraps>

80105cb0 <vector244>:
.globl vector244
vector244:
  pushl $0
80105cb0:	6a 00                	push   $0x0
  pushl $244
80105cb2:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105cb7:	e9 d9 f1 ff ff       	jmp    80104e95 <alltraps>

80105cbc <vector245>:
.globl vector245
vector245:
  pushl $0
80105cbc:	6a 00                	push   $0x0
  pushl $245
80105cbe:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105cc3:	e9 cd f1 ff ff       	jmp    80104e95 <alltraps>

80105cc8 <vector246>:
.globl vector246
vector246:
  pushl $0
80105cc8:	6a 00                	push   $0x0
  pushl $246
80105cca:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105ccf:	e9 c1 f1 ff ff       	jmp    80104e95 <alltraps>

80105cd4 <vector247>:
.globl vector247
vector247:
  pushl $0
80105cd4:	6a 00                	push   $0x0
  pushl $247
80105cd6:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105cdb:	e9 b5 f1 ff ff       	jmp    80104e95 <alltraps>

80105ce0 <vector248>:
.globl vector248
vector248:
  pushl $0
80105ce0:	6a 00                	push   $0x0
  pushl $248
80105ce2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105ce7:	e9 a9 f1 ff ff       	jmp    80104e95 <alltraps>

80105cec <vector249>:
.globl vector249
vector249:
  pushl $0
80105cec:	6a 00                	push   $0x0
  pushl $249
80105cee:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105cf3:	e9 9d f1 ff ff       	jmp    80104e95 <alltraps>

80105cf8 <vector250>:
.globl vector250
vector250:
  pushl $0
80105cf8:	6a 00                	push   $0x0
  pushl $250
80105cfa:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105cff:	e9 91 f1 ff ff       	jmp    80104e95 <alltraps>

80105d04 <vector251>:
.globl vector251
vector251:
  pushl $0
80105d04:	6a 00                	push   $0x0
  pushl $251
80105d06:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d0b:	e9 85 f1 ff ff       	jmp    80104e95 <alltraps>

80105d10 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d10:	6a 00                	push   $0x0
  pushl $252
80105d12:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d17:	e9 79 f1 ff ff       	jmp    80104e95 <alltraps>

80105d1c <vector253>:
.globl vector253
vector253:
  pushl $0
80105d1c:	6a 00                	push   $0x0
  pushl $253
80105d1e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d23:	e9 6d f1 ff ff       	jmp    80104e95 <alltraps>

80105d28 <vector254>:
.globl vector254
vector254:
  pushl $0
80105d28:	6a 00                	push   $0x0
  pushl $254
80105d2a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d2f:	e9 61 f1 ff ff       	jmp    80104e95 <alltraps>

80105d34 <vector255>:
.globl vector255
vector255:
  pushl $0
80105d34:	6a 00                	push   $0x0
  pushl $255
80105d36:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d3b:	e9 55 f1 ff ff       	jmp    80104e95 <alltraps>

80105d40 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
80105d43:	57                   	push   %edi
80105d44:	56                   	push   %esi
80105d45:	53                   	push   %ebx
80105d46:	83 ec 0c             	sub    $0xc,%esp
80105d49:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d4b:	c1 ea 16             	shr    $0x16,%edx
80105d4e:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d51:	8b 1f                	mov    (%edi),%ebx
80105d53:	f6 c3 01             	test   $0x1,%bl
80105d56:	74 37                	je     80105d8f <walkpgdir+0x4f>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105d58:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
80105d5e:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80105d64:	77 1c                	ja     80105d82 <walkpgdir+0x42>
    return (char*)a + KERNBASE;
80105d66:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105d6c:	c1 ee 0c             	shr    $0xc,%esi
80105d6f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105d75:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105d78:	89 d8                	mov    %ebx,%eax
80105d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d7d:	5b                   	pop    %ebx
80105d7e:	5e                   	pop    %esi
80105d7f:	5f                   	pop    %edi
80105d80:	5d                   	pop    %ebp
80105d81:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	68 78 6c 10 80       	push   $0x80106c78
80105d8a:	e8 b9 a5 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105d8f:	85 c9                	test   %ecx,%ecx
80105d91:	74 40                	je     80105dd3 <walkpgdir+0x93>
80105d93:	e8 37 c3 ff ff       	call   801020cf <kalloc>
80105d98:	89 c3                	mov    %eax,%ebx
80105d9a:	85 c0                	test   %eax,%eax
80105d9c:	74 da                	je     80105d78 <walkpgdir+0x38>
    memset(pgtab, 0, PGSIZE);
80105d9e:	83 ec 04             	sub    $0x4,%esp
80105da1:	68 00 10 00 00       	push   $0x1000
80105da6:	6a 00                	push   $0x0
80105da8:	50                   	push   %eax
80105da9:	e8 88 df ff ff       	call   80103d36 <memset>
    if (a < (void*) KERNBASE)
80105dae:	83 c4 10             	add    $0x10,%esp
80105db1:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80105db7:	76 0d                	jbe    80105dc6 <walkpgdir+0x86>
    return (uint)a - KERNBASE;
80105db9:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105dbf:	83 c8 07             	or     $0x7,%eax
80105dc2:	89 07                	mov    %eax,(%edi)
80105dc4:	eb a6                	jmp    80105d6c <walkpgdir+0x2c>
        panic("V2P on address < KERNBASE "
80105dc6:	83 ec 0c             	sub    $0xc,%esp
80105dc9:	68 48 69 10 80       	push   $0x80106948
80105dce:	e8 75 a5 ff ff       	call   80100348 <panic>
      return 0;
80105dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
80105dd8:	eb 9e                	jmp    80105d78 <walkpgdir+0x38>

80105dda <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105dda:	55                   	push   %ebp
80105ddb:	89 e5                	mov    %esp,%ebp
80105ddd:	57                   	push   %edi
80105dde:	56                   	push   %esi
80105ddf:	53                   	push   %ebx
80105de0:	83 ec 1c             	sub    $0x1c,%esp
80105de3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105de6:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105de9:	89 d3                	mov    %edx,%ebx
80105deb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105df1:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105df5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105dfb:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e00:	89 da                	mov    %ebx,%edx
80105e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e05:	e8 36 ff ff ff       	call   80105d40 <walkpgdir>
80105e0a:	85 c0                	test   %eax,%eax
80105e0c:	74 2e                	je     80105e3c <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e0e:	f6 00 01             	testb  $0x1,(%eax)
80105e11:	75 1c                	jne    80105e2f <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e13:	89 f2                	mov    %esi,%edx
80105e15:	0b 55 0c             	or     0xc(%ebp),%edx
80105e18:	83 ca 01             	or     $0x1,%edx
80105e1b:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e1d:	39 fb                	cmp    %edi,%ebx
80105e1f:	74 28                	je     80105e49 <mappages+0x6f>
      break;
    a += PGSIZE;
80105e21:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e27:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e2d:	eb cc                	jmp    80105dfb <mappages+0x21>
      panic("remap");
80105e2f:	83 ec 0c             	sub    $0xc,%esp
80105e32:	68 80 70 10 80       	push   $0x80107080
80105e37:	e8 0c a5 ff ff       	call   80100348 <panic>
      return -1;
80105e3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e44:	5b                   	pop    %ebx
80105e45:	5e                   	pop    %esi
80105e46:	5f                   	pop    %edi
80105e47:	5d                   	pop    %ebp
80105e48:	c3                   	ret    
  return 0;
80105e49:	b8 00 00 00 00       	mov    $0x0,%eax
80105e4e:	eb f1                	jmp    80105e41 <mappages+0x67>

80105e50 <seginit>:
{
80105e50:	55                   	push   %ebp
80105e51:	89 e5                	mov    %esp,%ebp
80105e53:	53                   	push   %ebx
80105e54:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e57:	e8 e0 d3 ff ff       	call   8010323c <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e5c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e62:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
80105e69:	ff ff 
80105e6b:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80105e72:	00 00 
80105e74:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
80105e7b:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
80105e82:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e85:	83 c9 1a             	or     $0x1a,%ecx
80105e88:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e8b:	83 c9 80             	or     $0xffffff80,%ecx
80105e8e:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
80105e94:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
80105e9b:	83 c9 0f             	or     $0xf,%ecx
80105e9e:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ea1:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ea4:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
80105eaa:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105eb1:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
80105eb8:	ff ff 
80105eba:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
80105ec1:	00 00 
80105ec3:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80105eca:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
80105ed1:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ed4:	83 c9 12             	or     $0x12,%ecx
80105ed7:	83 e1 9f             	and    $0xffffff9f,%ecx
80105eda:	83 c9 80             	or     $0xffffff80,%ecx
80105edd:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80105ee3:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80105eea:	83 c9 0f             	or     $0xf,%ecx
80105eed:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ef0:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ef3:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
80105ef9:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f00:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80105f07:	ff ff 
80105f09:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
80105f10:	00 00 
80105f12:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
80105f19:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
80105f20:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
80105f27:	83 c9 0f             	or     $0xf,%ecx
80105f2a:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f2d:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f30:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
80105f36:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f3d:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
80105f44:	ff ff 
80105f46:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
80105f4d:	00 00 
80105f4f:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
80105f56:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
80105f5d:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
80105f64:	83 c9 0f             	or     $0xf,%ecx
80105f67:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f6a:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f6d:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
80105f73:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105f7a:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
80105f7f:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105f85:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105f89:	c1 e8 10             	shr    $0x10,%eax
80105f8c:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105f90:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105f93:	0f 01 10             	lgdtl  (%eax)
}
80105f96:	83 c4 14             	add    $0x14,%esp
80105f99:	5b                   	pop    %ebx
80105f9a:	5d                   	pop    %ebp
80105f9b:	c3                   	ret    

80105f9c <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105f9c:	a1 a4 56 11 80       	mov    0x801156a4,%eax
    if (a < (void*) KERNBASE)
80105fa1:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80105fa6:	76 09                	jbe    80105fb1 <switchkvm+0x15>
    return (uint)a - KERNBASE;
80105fa8:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fad:	0f 22 d8             	mov    %eax,%cr3
80105fb0:	c3                   	ret    
{
80105fb1:	55                   	push   %ebp
80105fb2:	89 e5                	mov    %esp,%ebp
80105fb4:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
80105fb7:	68 48 69 10 80       	push   $0x80106948
80105fbc:	e8 87 a3 ff ff       	call   80100348 <panic>

80105fc1 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fc1:	55                   	push   %ebp
80105fc2:	89 e5                	mov    %esp,%ebp
80105fc4:	57                   	push   %edi
80105fc5:	56                   	push   %esi
80105fc6:	53                   	push   %ebx
80105fc7:	83 ec 1c             	sub    $0x1c,%esp
80105fca:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105fcd:	85 f6                	test   %esi,%esi
80105fcf:	0f 84 e4 00 00 00    	je     801060b9 <switchuvm+0xf8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105fd5:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105fd9:	0f 84 e7 00 00 00    	je     801060c6 <switchuvm+0x105>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105fdf:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105fe3:	0f 84 ea 00 00 00    	je     801060d3 <switchuvm+0x112>
    panic("switchuvm: no pgdir");

  pushcli();
80105fe9:	e8 bf db ff ff       	call   80103bad <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105fee:	e8 ed d1 ff ff       	call   801031e0 <mycpu>
80105ff3:	89 c3                	mov    %eax,%ebx
80105ff5:	e8 e6 d1 ff ff       	call   801031e0 <mycpu>
80105ffa:	8d 78 08             	lea    0x8(%eax),%edi
80105ffd:	e8 de d1 ff ff       	call   801031e0 <mycpu>
80106002:	83 c0 08             	add    $0x8,%eax
80106005:	c1 e8 10             	shr    $0x10,%eax
80106008:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010600b:	e8 d0 d1 ff ff       	call   801031e0 <mycpu>
80106010:	83 c0 08             	add    $0x8,%eax
80106013:	c1 e8 18             	shr    $0x18,%eax
80106016:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010601d:	67 00 
8010601f:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106026:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010602a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106030:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106037:	83 e2 f0             	and    $0xfffffff0,%edx
8010603a:	83 ca 19             	or     $0x19,%edx
8010603d:	83 e2 9f             	and    $0xffffff9f,%edx
80106040:	83 ca 80             	or     $0xffffff80,%edx
80106043:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106049:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106050:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106056:	e8 85 d1 ff ff       	call   801031e0 <mycpu>
8010605b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106062:	83 e2 ef             	and    $0xffffffef,%edx
80106065:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010606b:	e8 70 d1 ff ff       	call   801031e0 <mycpu>
80106070:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106076:	8b 5e 08             	mov    0x8(%esi),%ebx
80106079:	e8 62 d1 ff ff       	call   801031e0 <mycpu>
8010607e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106084:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106087:	e8 54 d1 ff ff       	call   801031e0 <mycpu>
8010608c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106092:	b8 28 00 00 00       	mov    $0x28,%eax
80106097:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010609a:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
8010609d:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801060a2:	76 3c                	jbe    801060e0 <switchuvm+0x11f>
    return (uint)a - KERNBASE;
801060a4:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060a9:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060ac:	e8 39 db ff ff       	call   80103bea <popcli>
}
801060b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060b4:	5b                   	pop    %ebx
801060b5:	5e                   	pop    %esi
801060b6:	5f                   	pop    %edi
801060b7:	5d                   	pop    %ebp
801060b8:	c3                   	ret    
    panic("switchuvm: no process");
801060b9:	83 ec 0c             	sub    $0xc,%esp
801060bc:	68 86 70 10 80       	push   $0x80107086
801060c1:	e8 82 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	68 9c 70 10 80       	push   $0x8010709c
801060ce:	e8 75 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060d3:	83 ec 0c             	sub    $0xc,%esp
801060d6:	68 b1 70 10 80       	push   $0x801070b1
801060db:	e8 68 a2 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801060e0:	83 ec 0c             	sub    $0xc,%esp
801060e3:	68 48 69 10 80       	push   $0x80106948
801060e8:	e8 5b a2 ff ff       	call   80100348 <panic>

801060ed <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801060ed:	55                   	push   %ebp
801060ee:	89 e5                	mov    %esp,%ebp
801060f0:	56                   	push   %esi
801060f1:	53                   	push   %ebx
801060f2:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801060f5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060fb:	77 57                	ja     80106154 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
801060fd:	e8 cd bf ff ff       	call   801020cf <kalloc>
80106102:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106104:	83 ec 04             	sub    $0x4,%esp
80106107:	68 00 10 00 00       	push   $0x1000
8010610c:	6a 00                	push   $0x0
8010610e:	50                   	push   %eax
8010610f:	e8 22 dc ff ff       	call   80103d36 <memset>
    if (a < (void*) KERNBASE)
80106114:	83 c4 10             	add    $0x10,%esp
80106117:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010611d:	76 42                	jbe    80106161 <inituvm+0x74>
    return (uint)a - KERNBASE;
8010611f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106125:	83 ec 08             	sub    $0x8,%esp
80106128:	6a 06                	push   $0x6
8010612a:	50                   	push   %eax
8010612b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106130:	ba 00 00 00 00       	mov    $0x0,%edx
80106135:	8b 45 08             	mov    0x8(%ebp),%eax
80106138:	e8 9d fc ff ff       	call   80105dda <mappages>
  memmove(mem, init, sz);
8010613d:	83 c4 0c             	add    $0xc,%esp
80106140:	56                   	push   %esi
80106141:	ff 75 0c             	pushl  0xc(%ebp)
80106144:	53                   	push   %ebx
80106145:	e8 67 dc ff ff       	call   80103db1 <memmove>
}
8010614a:	83 c4 10             	add    $0x10,%esp
8010614d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106150:	5b                   	pop    %ebx
80106151:	5e                   	pop    %esi
80106152:	5d                   	pop    %ebp
80106153:	c3                   	ret    
    panic("inituvm: more than a page");
80106154:	83 ec 0c             	sub    $0xc,%esp
80106157:	68 c5 70 10 80       	push   $0x801070c5
8010615c:	e8 e7 a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106161:	83 ec 0c             	sub    $0xc,%esp
80106164:	68 48 69 10 80       	push   $0x80106948
80106169:	e8 da a1 ff ff       	call   80100348 <panic>

8010616e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010616e:	55                   	push   %ebp
8010616f:	89 e5                	mov    %esp,%ebp
80106171:	57                   	push   %edi
80106172:	56                   	push   %esi
80106173:	53                   	push   %ebx
80106174:	83 ec 0c             	sub    $0xc,%esp
80106177:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010617a:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106181:	75 07                	jne    8010618a <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106183:	bb 00 00 00 00       	mov    $0x0,%ebx
80106188:	eb 43                	jmp    801061cd <loaduvm+0x5f>
    panic("loaduvm: addr must be page aligned");
8010618a:	83 ec 0c             	sub    $0xc,%esp
8010618d:	68 80 71 10 80       	push   $0x80107180
80106192:	e8 b1 a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106197:	83 ec 0c             	sub    $0xc,%esp
8010619a:	68 df 70 10 80       	push   $0x801070df
8010619f:	e8 a4 a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801061a4:	89 da                	mov    %ebx,%edx
801061a6:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
801061a9:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801061ae:	77 51                	ja     80106201 <loaduvm+0x93>
    return (char*)a + KERNBASE;
801061b0:	05 00 00 00 80       	add    $0x80000000,%eax
801061b5:	56                   	push   %esi
801061b6:	52                   	push   %edx
801061b7:	50                   	push   %eax
801061b8:	ff 75 10             	pushl  0x10(%ebp)
801061bb:	e8 a1 b5 ff ff       	call   80101761 <readi>
801061c0:	83 c4 10             	add    $0x10,%esp
801061c3:	39 f0                	cmp    %esi,%eax
801061c5:	75 54                	jne    8010621b <loaduvm+0xad>
  for(i = 0; i < sz; i += PGSIZE){
801061c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061cd:	39 fb                	cmp    %edi,%ebx
801061cf:	73 3d                	jae    8010620e <loaduvm+0xa0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061d1:	89 da                	mov    %ebx,%edx
801061d3:	03 55 0c             	add    0xc(%ebp),%edx
801061d6:	b9 00 00 00 00       	mov    $0x0,%ecx
801061db:	8b 45 08             	mov    0x8(%ebp),%eax
801061de:	e8 5d fb ff ff       	call   80105d40 <walkpgdir>
801061e3:	85 c0                	test   %eax,%eax
801061e5:	74 b0                	je     80106197 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061e7:	8b 00                	mov    (%eax),%eax
801061e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061ee:	89 fe                	mov    %edi,%esi
801061f0:	29 de                	sub    %ebx,%esi
801061f2:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061f8:	76 aa                	jbe    801061a4 <loaduvm+0x36>
      n = PGSIZE;
801061fa:	be 00 10 00 00       	mov    $0x1000,%esi
801061ff:	eb a3                	jmp    801061a4 <loaduvm+0x36>
        panic("P2V on address > KERNBASE");
80106201:	83 ec 0c             	sub    $0xc,%esp
80106204:	68 78 6c 10 80       	push   $0x80106c78
80106209:	e8 3a a1 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
8010620e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106213:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106216:	5b                   	pop    %ebx
80106217:	5e                   	pop    %esi
80106218:	5f                   	pop    %edi
80106219:	5d                   	pop    %ebp
8010621a:	c3                   	ret    
      return -1;
8010621b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106220:	eb f1                	jmp    80106213 <loaduvm+0xa5>

80106222 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106222:	55                   	push   %ebp
80106223:	89 e5                	mov    %esp,%ebp
80106225:	57                   	push   %edi
80106226:	56                   	push   %esi
80106227:	53                   	push   %ebx
80106228:	83 ec 0c             	sub    $0xc,%esp
8010622b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010622e:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106231:	73 11                	jae    80106244 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106233:	8b 45 10             	mov    0x10(%ebp),%eax
80106236:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010623c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106242:	eb 19                	jmp    8010625d <deallocuvm+0x3b>
    return oldsz;
80106244:	89 f8                	mov    %edi,%eax
80106246:	eb 78                	jmp    801062c0 <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106248:	c1 eb 16             	shr    $0x16,%ebx
8010624b:	83 c3 01             	add    $0x1,%ebx
8010624e:	c1 e3 16             	shl    $0x16,%ebx
80106251:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106257:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010625d:	39 fb                	cmp    %edi,%ebx
8010625f:	73 5c                	jae    801062bd <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106261:	b9 00 00 00 00       	mov    $0x0,%ecx
80106266:	89 da                	mov    %ebx,%edx
80106268:	8b 45 08             	mov    0x8(%ebp),%eax
8010626b:	e8 d0 fa ff ff       	call   80105d40 <walkpgdir>
80106270:	89 c6                	mov    %eax,%esi
    if(!pte)
80106272:	85 c0                	test   %eax,%eax
80106274:	74 d2                	je     80106248 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106276:	8b 00                	mov    (%eax),%eax
80106278:	a8 01                	test   $0x1,%al
8010627a:	74 db                	je     80106257 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010627c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106281:	74 20                	je     801062a3 <deallocuvm+0x81>
    if (a > KERNBASE)
80106283:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106288:	77 26                	ja     801062b0 <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
8010628a:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
8010628f:	83 ec 0c             	sub    $0xc,%esp
80106292:	50                   	push   %eax
80106293:	e8 fa bc ff ff       	call   80101f92 <kfree>
      *pte = 0;
80106298:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010629e:	83 c4 10             	add    $0x10,%esp
801062a1:	eb b4                	jmp    80106257 <deallocuvm+0x35>
        panic("kfree");
801062a3:	83 ec 0c             	sub    $0xc,%esp
801062a6:	68 d6 69 10 80       	push   $0x801069d6
801062ab:	e8 98 a0 ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801062b0:	83 ec 0c             	sub    $0xc,%esp
801062b3:	68 78 6c 10 80       	push   $0x80106c78
801062b8:	e8 8b a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801062bd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801062c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c3:	5b                   	pop    %ebx
801062c4:	5e                   	pop    %esi
801062c5:	5f                   	pop    %edi
801062c6:	5d                   	pop    %ebp
801062c7:	c3                   	ret    

801062c8 <allocuvm>:
{
801062c8:	55                   	push   %ebp
801062c9:	89 e5                	mov    %esp,%ebp
801062cb:	57                   	push   %edi
801062cc:	56                   	push   %esi
801062cd:	53                   	push   %ebx
801062ce:	83 ec 1c             	sub    $0x1c,%esp
801062d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801062d4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801062d7:	85 ff                	test   %edi,%edi
801062d9:	0f 88 d9 00 00 00    	js     801063b8 <allocuvm+0xf0>
  if(newsz < oldsz)
801062df:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062e2:	72 67                	jb     8010634b <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
801062e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801062e7:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801062ed:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801062f3:	39 fe                	cmp    %edi,%esi
801062f5:	0f 83 c4 00 00 00    	jae    801063bf <allocuvm+0xf7>
    mem = kalloc();
801062fb:	e8 cf bd ff ff       	call   801020cf <kalloc>
80106300:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106302:	85 c0                	test   %eax,%eax
80106304:	74 4d                	je     80106353 <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
80106306:	83 ec 04             	sub    $0x4,%esp
80106309:	68 00 10 00 00       	push   $0x1000
8010630e:	6a 00                	push   $0x0
80106310:	50                   	push   %eax
80106311:	e8 20 da ff ff       	call   80103d36 <memset>
    if (a < (void*) KERNBASE)
80106316:	83 c4 10             	add    $0x10,%esp
80106319:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010631f:	76 5a                	jbe    8010637b <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106321:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106327:	83 ec 08             	sub    $0x8,%esp
8010632a:	6a 06                	push   $0x6
8010632c:	50                   	push   %eax
8010632d:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106332:	89 f2                	mov    %esi,%edx
80106334:	8b 45 08             	mov    0x8(%ebp),%eax
80106337:	e8 9e fa ff ff       	call   80105dda <mappages>
8010633c:	83 c4 10             	add    $0x10,%esp
8010633f:	85 c0                	test   %eax,%eax
80106341:	78 45                	js     80106388 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80106343:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106349:	eb a8                	jmp    801062f3 <allocuvm+0x2b>
    return oldsz;
8010634b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010634e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106351:	eb 6c                	jmp    801063bf <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
80106353:	83 ec 0c             	sub    $0xc,%esp
80106356:	68 fd 70 10 80       	push   $0x801070fd
8010635b:	e8 ab a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106360:	83 c4 0c             	add    $0xc,%esp
80106363:	ff 75 0c             	pushl  0xc(%ebp)
80106366:	57                   	push   %edi
80106367:	ff 75 08             	pushl  0x8(%ebp)
8010636a:	e8 b3 fe ff ff       	call   80106222 <deallocuvm>
      return 0;
8010636f:	83 c4 10             	add    $0x10,%esp
80106372:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106379:	eb 44                	jmp    801063bf <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
8010637b:	83 ec 0c             	sub    $0xc,%esp
8010637e:	68 48 69 10 80       	push   $0x80106948
80106383:	e8 c0 9f ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
80106388:	83 ec 0c             	sub    $0xc,%esp
8010638b:	68 15 71 10 80       	push   $0x80107115
80106390:	e8 76 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106395:	83 c4 0c             	add    $0xc,%esp
80106398:	ff 75 0c             	pushl  0xc(%ebp)
8010639b:	57                   	push   %edi
8010639c:	ff 75 08             	pushl  0x8(%ebp)
8010639f:	e8 7e fe ff ff       	call   80106222 <deallocuvm>
      kfree(mem);
801063a4:	89 1c 24             	mov    %ebx,(%esp)
801063a7:	e8 e6 bb ff ff       	call   80101f92 <kfree>
      return 0;
801063ac:	83 c4 10             	add    $0x10,%esp
801063af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801063b6:	eb 07                	jmp    801063bf <allocuvm+0xf7>
    return 0;
801063b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801063bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063c5:	5b                   	pop    %ebx
801063c6:	5e                   	pop    %esi
801063c7:	5f                   	pop    %edi
801063c8:	5d                   	pop    %ebp
801063c9:	c3                   	ret    

801063ca <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801063ca:	55                   	push   %ebp
801063cb:	89 e5                	mov    %esp,%ebp
801063cd:	56                   	push   %esi
801063ce:	53                   	push   %ebx
801063cf:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801063d2:	85 f6                	test   %esi,%esi
801063d4:	74 1a                	je     801063f0 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801063d6:	83 ec 04             	sub    $0x4,%esp
801063d9:	6a 00                	push   $0x0
801063db:	68 00 00 00 80       	push   $0x80000000
801063e0:	56                   	push   %esi
801063e1:	e8 3c fe ff ff       	call   80106222 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801063e6:	83 c4 10             	add    $0x10,%esp
801063e9:	bb 00 00 00 00       	mov    $0x0,%ebx
801063ee:	eb 1d                	jmp    8010640d <freevm+0x43>
    panic("freevm: no pgdir");
801063f0:	83 ec 0c             	sub    $0xc,%esp
801063f3:	68 31 71 10 80       	push   $0x80107131
801063f8:	e8 4b 9f ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801063fd:	83 ec 0c             	sub    $0xc,%esp
80106400:	68 78 6c 10 80       	push   $0x80106c78
80106405:	e8 3e 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
8010640a:	83 c3 01             	add    $0x1,%ebx
8010640d:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106413:	77 26                	ja     8010643b <freevm+0x71>
    if(pgdir[i] & PTE_P){
80106415:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106418:	a8 01                	test   $0x1,%al
8010641a:	74 ee                	je     8010640a <freevm+0x40>
8010641c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106421:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106426:	77 d5                	ja     801063fd <freevm+0x33>
    return (char*)a + KERNBASE;
80106428:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
8010642d:	83 ec 0c             	sub    $0xc,%esp
80106430:	50                   	push   %eax
80106431:	e8 5c bb ff ff       	call   80101f92 <kfree>
80106436:	83 c4 10             	add    $0x10,%esp
80106439:	eb cf                	jmp    8010640a <freevm+0x40>
    }
  }
  kfree((char*)pgdir);
8010643b:	83 ec 0c             	sub    $0xc,%esp
8010643e:	56                   	push   %esi
8010643f:	e8 4e bb ff ff       	call   80101f92 <kfree>
}
80106444:	83 c4 10             	add    $0x10,%esp
80106447:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010644a:	5b                   	pop    %ebx
8010644b:	5e                   	pop    %esi
8010644c:	5d                   	pop    %ebp
8010644d:	c3                   	ret    

8010644e <setupkvm>:
{
8010644e:	55                   	push   %ebp
8010644f:	89 e5                	mov    %esp,%ebp
80106451:	56                   	push   %esi
80106452:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106453:	e8 77 bc ff ff       	call   801020cf <kalloc>
80106458:	89 c6                	mov    %eax,%esi
8010645a:	85 c0                	test   %eax,%eax
8010645c:	74 55                	je     801064b3 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
8010645e:	83 ec 04             	sub    $0x4,%esp
80106461:	68 00 10 00 00       	push   $0x1000
80106466:	6a 00                	push   $0x0
80106468:	50                   	push   %eax
80106469:	e8 c8 d8 ff ff       	call   80103d36 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010646e:	83 c4 10             	add    $0x10,%esp
80106471:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106476:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
8010647c:	73 35                	jae    801064b3 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
8010647e:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106481:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106484:	29 c1                	sub    %eax,%ecx
80106486:	83 ec 08             	sub    $0x8,%esp
80106489:	ff 73 0c             	pushl  0xc(%ebx)
8010648c:	50                   	push   %eax
8010648d:	8b 13                	mov    (%ebx),%edx
8010648f:	89 f0                	mov    %esi,%eax
80106491:	e8 44 f9 ff ff       	call   80105dda <mappages>
80106496:	83 c4 10             	add    $0x10,%esp
80106499:	85 c0                	test   %eax,%eax
8010649b:	78 05                	js     801064a2 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010649d:	83 c3 10             	add    $0x10,%ebx
801064a0:	eb d4                	jmp    80106476 <setupkvm+0x28>
      freevm(pgdir);
801064a2:	83 ec 0c             	sub    $0xc,%esp
801064a5:	56                   	push   %esi
801064a6:	e8 1f ff ff ff       	call   801063ca <freevm>
      return 0;
801064ab:	83 c4 10             	add    $0x10,%esp
801064ae:	be 00 00 00 00       	mov    $0x0,%esi
}
801064b3:	89 f0                	mov    %esi,%eax
801064b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064b8:	5b                   	pop    %ebx
801064b9:	5e                   	pop    %esi
801064ba:	5d                   	pop    %ebp
801064bb:	c3                   	ret    

801064bc <kvmalloc>:
{
801064bc:	55                   	push   %ebp
801064bd:	89 e5                	mov    %esp,%ebp
801064bf:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801064c2:	e8 87 ff ff ff       	call   8010644e <setupkvm>
801064c7:	a3 a4 56 11 80       	mov    %eax,0x801156a4
  switchkvm();
801064cc:	e8 cb fa ff ff       	call   80105f9c <switchkvm>
}
801064d1:	c9                   	leave  
801064d2:	c3                   	ret    

801064d3 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801064d3:	55                   	push   %ebp
801064d4:	89 e5                	mov    %esp,%ebp
801064d6:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801064d9:	b9 00 00 00 00       	mov    $0x0,%ecx
801064de:	8b 55 0c             	mov    0xc(%ebp),%edx
801064e1:	8b 45 08             	mov    0x8(%ebp),%eax
801064e4:	e8 57 f8 ff ff       	call   80105d40 <walkpgdir>
  if(pte == 0)
801064e9:	85 c0                	test   %eax,%eax
801064eb:	74 05                	je     801064f2 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801064ed:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801064f0:	c9                   	leave  
801064f1:	c3                   	ret    
    panic("clearpteu");
801064f2:	83 ec 0c             	sub    $0xc,%esp
801064f5:	68 42 71 10 80       	push   $0x80107142
801064fa:	e8 49 9e ff ff       	call   80100348 <panic>

801064ff <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801064ff:	55                   	push   %ebp
80106500:	89 e5                	mov    %esp,%ebp
80106502:	57                   	push   %edi
80106503:	56                   	push   %esi
80106504:	53                   	push   %ebx
80106505:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106508:	e8 41 ff ff ff       	call   8010644e <setupkvm>
8010650d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106510:	85 c0                	test   %eax,%eax
80106512:	0f 84 f2 00 00 00    	je     8010660a <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106518:	bb 00 00 00 00       	mov    $0x0,%ebx
8010651d:	eb 3a                	jmp    80106559 <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010651f:	83 ec 0c             	sub    $0xc,%esp
80106522:	68 4c 71 10 80       	push   $0x8010714c
80106527:	e8 1c 9e ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
8010652c:	83 ec 0c             	sub    $0xc,%esp
8010652f:	68 66 71 10 80       	push   $0x80107166
80106534:	e8 0f 9e ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106539:	83 ec 0c             	sub    $0xc,%esp
8010653c:	68 78 6c 10 80       	push   $0x80106c78
80106541:	e8 02 9e ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106546:	83 ec 0c             	sub    $0xc,%esp
80106549:	68 48 69 10 80       	push   $0x80106948
8010654e:	e8 f5 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106553:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106559:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
8010655c:	0f 83 a8 00 00 00    	jae    8010660a <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106562:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106565:	b9 00 00 00 00       	mov    $0x0,%ecx
8010656a:	89 da                	mov    %ebx,%edx
8010656c:	8b 45 08             	mov    0x8(%ebp),%eax
8010656f:	e8 cc f7 ff ff       	call   80105d40 <walkpgdir>
80106574:	85 c0                	test   %eax,%eax
80106576:	74 a7                	je     8010651f <copyuvm+0x20>
    if(!(*pte & PTE_P))
80106578:	8b 00                	mov    (%eax),%eax
8010657a:	a8 01                	test   $0x1,%al
8010657c:	74 ae                	je     8010652c <copyuvm+0x2d>
8010657e:	89 c6                	mov    %eax,%esi
80106580:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
80106586:	25 ff 0f 00 00       	and    $0xfff,%eax
8010658b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
8010658e:	e8 3c bb ff ff       	call   801020cf <kalloc>
80106593:	89 c7                	mov    %eax,%edi
80106595:	85 c0                	test   %eax,%eax
80106597:	74 5c                	je     801065f5 <copyuvm+0xf6>
    if (a > KERNBASE)
80106599:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
8010659f:	77 98                	ja     80106539 <copyuvm+0x3a>
    return (char*)a + KERNBASE;
801065a1:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801065a7:	83 ec 04             	sub    $0x4,%esp
801065aa:	68 00 10 00 00       	push   $0x1000
801065af:	56                   	push   %esi
801065b0:	50                   	push   %eax
801065b1:	e8 fb d7 ff ff       	call   80103db1 <memmove>
    if (a < (void*) KERNBASE)
801065b6:	83 c4 10             	add    $0x10,%esp
801065b9:	81 ff ff ff ff 7f    	cmp    $0x7fffffff,%edi
801065bf:	76 85                	jbe    80106546 <copyuvm+0x47>
    return (uint)a - KERNBASE;
801065c1:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801065c7:	83 ec 08             	sub    $0x8,%esp
801065ca:	ff 75 e0             	pushl  -0x20(%ebp)
801065cd:	50                   	push   %eax
801065ce:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801065d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065d9:	e8 fc f7 ff ff       	call   80105dda <mappages>
801065de:	83 c4 10             	add    $0x10,%esp
801065e1:	85 c0                	test   %eax,%eax
801065e3:	0f 89 6a ff ff ff    	jns    80106553 <copyuvm+0x54>
      kfree(mem);
801065e9:	83 ec 0c             	sub    $0xc,%esp
801065ec:	57                   	push   %edi
801065ed:	e8 a0 b9 ff ff       	call   80101f92 <kfree>
      goto bad;
801065f2:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
801065f5:	83 ec 0c             	sub    $0xc,%esp
801065f8:	ff 75 dc             	pushl  -0x24(%ebp)
801065fb:	e8 ca fd ff ff       	call   801063ca <freevm>
  return 0;
80106600:	83 c4 10             	add    $0x10,%esp
80106603:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010660a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010660d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106610:	5b                   	pop    %ebx
80106611:	5e                   	pop    %esi
80106612:	5f                   	pop    %edi
80106613:	5d                   	pop    %ebp
80106614:	c3                   	ret    

80106615 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106615:	55                   	push   %ebp
80106616:	89 e5                	mov    %esp,%ebp
80106618:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010661b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106620:	8b 55 0c             	mov    0xc(%ebp),%edx
80106623:	8b 45 08             	mov    0x8(%ebp),%eax
80106626:	e8 15 f7 ff ff       	call   80105d40 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010662b:	8b 00                	mov    (%eax),%eax
8010662d:	a8 01                	test   $0x1,%al
8010662f:	74 24                	je     80106655 <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
80106631:	a8 04                	test   $0x4,%al
80106633:	74 27                	je     8010665c <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106635:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010663a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010663f:	77 07                	ja     80106648 <uva2ka+0x33>
    return (char*)a + KERNBASE;
80106641:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106646:	c9                   	leave  
80106647:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80106648:	83 ec 0c             	sub    $0xc,%esp
8010664b:	68 78 6c 10 80       	push   $0x80106c78
80106650:	e8 f3 9c ff ff       	call   80100348 <panic>
    return 0;
80106655:	b8 00 00 00 00       	mov    $0x0,%eax
8010665a:	eb ea                	jmp    80106646 <uva2ka+0x31>
    return 0;
8010665c:	b8 00 00 00 00       	mov    $0x0,%eax
80106661:	eb e3                	jmp    80106646 <uva2ka+0x31>

80106663 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	57                   	push   %edi
80106667:	56                   	push   %esi
80106668:	53                   	push   %ebx
80106669:	83 ec 0c             	sub    $0xc,%esp
8010666c:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010666f:	eb 25                	jmp    80106696 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106671:	8b 55 0c             	mov    0xc(%ebp),%edx
80106674:	29 f2                	sub    %esi,%edx
80106676:	01 d0                	add    %edx,%eax
80106678:	83 ec 04             	sub    $0x4,%esp
8010667b:	53                   	push   %ebx
8010667c:	ff 75 10             	pushl  0x10(%ebp)
8010667f:	50                   	push   %eax
80106680:	e8 2c d7 ff ff       	call   80103db1 <memmove>
    len -= n;
80106685:	29 df                	sub    %ebx,%edi
    buf += n;
80106687:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
8010668a:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106690:	89 45 0c             	mov    %eax,0xc(%ebp)
80106693:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106696:	85 ff                	test   %edi,%edi
80106698:	74 2f                	je     801066c9 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
8010669a:	8b 75 0c             	mov    0xc(%ebp),%esi
8010669d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801066a3:	83 ec 08             	sub    $0x8,%esp
801066a6:	56                   	push   %esi
801066a7:	ff 75 08             	pushl  0x8(%ebp)
801066aa:	e8 66 ff ff ff       	call   80106615 <uva2ka>
    if(pa0 == 0)
801066af:	83 c4 10             	add    $0x10,%esp
801066b2:	85 c0                	test   %eax,%eax
801066b4:	74 20                	je     801066d6 <copyout+0x73>
    n = PGSIZE - (va - va0);
801066b6:	89 f3                	mov    %esi,%ebx
801066b8:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801066bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801066c1:	39 df                	cmp    %ebx,%edi
801066c3:	73 ac                	jae    80106671 <copyout+0xe>
      n = len;
801066c5:	89 fb                	mov    %edi,%ebx
801066c7:	eb a8                	jmp    80106671 <copyout+0xe>
  }
  return 0;
801066c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066d1:	5b                   	pop    %ebx
801066d2:	5e                   	pop    %esi
801066d3:	5f                   	pop    %edi
801066d4:	5d                   	pop    %ebp
801066d5:	c3                   	ret    
      return -1;
801066d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066db:	eb f1                	jmp    801066ce <copyout+0x6b>
