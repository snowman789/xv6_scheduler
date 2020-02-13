
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
80100046:	e8 29 3d 00 00       	call   80103d74 <acquire>

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
8010007c:	e8 58 3d 00 00       	call   80103dd9 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 d4 3a 00 00       	call   80103b60 <acquiresleep>
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
801000ca:	e8 0a 3d 00 00       	call   80103dd9 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 86 3a 00 00       	call   80103b60 <acquiresleep>
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
801000ea:	68 e0 67 10 80       	push   $0x801067e0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 f1 67 10 80       	push   $0x801067f1
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 2e 3b 00 00       	call   80103c38 <initlock>
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
8010013a:	68 f8 67 10 80       	push   $0x801067f8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 e5 39 00 00       	call   80103b2d <initsleeplock>
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
801001a8:	e8 3d 3a 00 00       	call   80103bea <holdingsleep>
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
801001cb:	68 ff 67 10 80       	push   $0x801067ff
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
801001e4:	e8 01 3a 00 00       	call   80103bea <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 b6 39 00 00       	call   80103baf <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 6f 3b 00 00       	call   80103d74 <acquire>
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
8010024c:	e8 88 3b 00 00       	call   80103dd9 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 06 68 10 80       	push   $0x80106806
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
8010028a:	e8 e5 3a 00 00       	call   80103d74 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 f7 2f 00 00       	call   801032a3 <myproc>
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
801002bf:	e8 3c 35 00 00       	call   80103800 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 03 3b 00 00       	call   80103dd9 <release>
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
80100331:	e8 a3 3a 00 00       	call   80103dd9 <release>
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
80100363:	68 0d 68 10 80       	push   $0x8010680d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 42 6e 10 80 	movl   $0x80106e42,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 bf 38 00 00       	call   80103c53 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 21 68 10 80       	push   $0x80106821
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
8010049e:	68 25 68 10 80       	push   $0x80106825
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 dc 39 00 00       	call   80103e9b <memmove>
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
801004d9:	e8 42 39 00 00       	call   80103e20 <memset>
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
80100506:	e8 b0 4d 00 00       	call   801052bb <uartputc>
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
8010051f:	e8 97 4d 00 00       	call   801052bb <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 8b 4d 00 00       	call   801052bb <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 7f 4d 00 00       	call   801052bb <uartputc>
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
80100576:	0f b6 92 50 68 10 80 	movzbl -0x7fef97b0(%edx),%edx
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
801005ca:	e8 a5 37 00 00       	call   80103d74 <acquire>
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
801005f1:	e8 e3 37 00 00       	call   80103dd9 <release>
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
80100638:	e8 37 37 00 00       	call   80103d74 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 3f 68 10 80       	push   $0x8010683f
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
801006ee:	be 38 68 10 80       	mov    $0x80106838,%esi
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
80100734:	e8 a0 36 00 00       	call   80103dd9 <release>
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
8010074f:	e8 20 36 00 00       	call   80103d74 <acquire>
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
801007de:	e8 85 31 00 00       	call   80103968 <wakeup>
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
80100873:	e8 61 35 00 00       	call   80103dd9 <release>
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
80100887:	e8 7b 31 00 00       	call   80103a07 <procdump>
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
80100894:	68 48 68 10 80       	push   $0x80106848
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 95 33 00 00       	call   80103c38 <initlock>

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
801008de:	e8 c0 29 00 00       	call   801032a3 <myproc>
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
80100952:	68 61 68 10 80       	push   $0x80106861
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
80100972:	e8 c1 5b 00 00       	call   80106538 <setupkvm>
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
80100a06:	e8 a7 59 00 00       	call   801063b2 <allocuvm>
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
80100a38:	e8 1b 58 00 00       	call   80106258 <loaduvm>
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
80100a74:	e8 39 59 00 00       	call   801063b2 <allocuvm>
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
80100a9d:	e8 12 5a 00 00       	call   801064b4 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 fc 5a 00 00       	call   801065bd <clearpteu>
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
80100ae2:	e8 db 34 00 00       	call   80103fc2 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 c9 34 00 00       	call   80103fc2 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 42 5c 00 00       	call   8010674d <copyout>
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
80100b66:	e8 e2 5b 00 00       	call   8010674d <copyout>
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
80100ba3:	e8 df 33 00 00       	call   80103f87 <safestrcpy>
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
80100bd1:	e8 d5 54 00 00       	call   801060ab <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 d6 58 00 00       	call   801064b4 <freevm>
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
80100c19:	68 6d 68 10 80       	push   $0x8010686d
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 10 30 00 00       	call   80103c38 <initlock>
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
80100c39:	e8 36 31 00 00       	call   80103d74 <acquire>
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
80100c68:	e8 6c 31 00 00       	call   80103dd9 <release>
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
80100c7f:	e8 55 31 00 00       	call   80103dd9 <release>
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
80100c9d:	e8 d2 30 00 00       	call   80103d74 <acquire>
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
80100cba:	e8 1a 31 00 00       	call   80103dd9 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 74 68 10 80       	push   $0x80106874
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
80100ce2:	e8 8d 30 00 00       	call   80103d74 <acquire>
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
80100d03:	e8 d1 30 00 00       	call   80103dd9 <release>
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
80100d13:	68 7c 68 10 80       	push   $0x8010687c
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
80100d49:	e8 8b 30 00 00       	call   80103dd9 <release>
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
80100e4b:	68 86 68 10 80       	push   $0x80106886
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
80100f10:	68 8f 68 10 80       	push   $0x8010688f
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
80100f2d:	68 95 68 10 80       	push   $0x80106895
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
80100f8a:	e8 0c 2f 00 00       	call   80103e9b <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 fc 2e 00 00       	call   80103e9b <memmove>
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
80100fdf:	e8 3c 2e 00 00       	call   80103e20 <memset>
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
80101062:	68 9f 68 10 80       	push   $0x8010689f
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
80101113:	68 b2 68 10 80       	push   $0x801068b2
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
801011ed:	68 c8 68 10 80       	push   $0x801068c8
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
8010120a:	e8 65 2b 00 00       	call   80103d74 <acquire>
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
80101251:	e8 83 2b 00 00       	call   80103dd9 <release>
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
80101287:	e8 4d 2b 00 00       	call   80103dd9 <release>
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
8010129c:	68 db 68 10 80       	push   $0x801068db
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
801012c5:	e8 d1 2b 00 00       	call   80103e9b <memmove>
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
801012e1:	68 eb 68 10 80       	push   $0x801068eb
801012e6:	68 e0 09 11 80       	push   $0x801109e0
801012eb:	e8 48 29 00 00       	call   80103c38 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 f2 68 10 80       	push   $0x801068f2
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 20 0a 11 80       	add    $0x80110a20,%eax
8010130f:	50                   	push   %eax
80101310:	e8 18 28 00 00       	call   80103b2d <initsleeplock>
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
8010135a:	68 58 69 10 80       	push   $0x80106958
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
801013cd:	68 f8 68 10 80       	push   $0x801068f8
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 3c 2a 00 00       	call   80103e20 <memset>
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
8010146e:	e8 28 2a 00 00       	call   80103e9b <memmove>
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
8010154e:	e8 21 28 00 00       	call   80103d74 <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101563:	e8 71 28 00 00       	call   80103dd9 <release>
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
80101588:	e8 d3 25 00 00       	call   80103b60 <acquiresleep>
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
801015a0:	68 0a 69 10 80       	push   $0x8010690a
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
80101602:	e8 94 28 00 00       	call   80103e9b <memmove>
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
80101627:	68 10 69 10 80       	push   $0x80106910
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
80101644:	e8 a1 25 00 00       	call   80103bea <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 50 25 00 00       	call   80103baf <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 1f 69 10 80       	push   $0x8010691f
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
80101686:	e8 d5 24 00 00       	call   80103b60 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 0b 25 00 00       	call   80103baf <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016ab:	e8 c4 26 00 00       	call   80103d74 <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016c0:	e8 14 27 00 00       	call   80103dd9 <release>
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
801016d8:	e8 97 26 00 00       	call   80103d74 <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016e7:	e8 ed 26 00 00       	call   80103dd9 <release>
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
80101818:	e8 7e 26 00 00       	call   80103e9b <memmove>
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
80101914:	e8 82 25 00 00       	call   80103e9b <memmove>
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
80101997:	e8 66 25 00 00       	call   80103f02 <strncmp>
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
801019be:	68 27 69 10 80       	push   $0x80106927
801019c3:	e8 80 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 39 69 10 80       	push   $0x80106939
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
80101a48:	e8 56 18 00 00       	call   801032a3 <myproc>
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
80101b80:	68 48 69 10 80       	push   $0x80106948
80101b85:	e8 be e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b8a:	83 ec 04             	sub    $0x4,%esp
80101b8d:	6a 0e                	push   $0xe
80101b8f:	57                   	push   %edi
80101b90:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b93:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b96:	50                   	push   %eax
80101b97:	e8 a3 23 00 00       	call   80103f3f <strncpy>
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
80101bc5:	68 48 70 10 80       	push   $0x80107048
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
80101cba:	68 ab 69 10 80       	push   $0x801069ab
80101cbf:	e8 84 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 b4 69 10 80       	push   $0x801069b4
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
80101cf4:	68 c6 69 10 80       	push   $0x801069c6
80101cf9:	68 80 a5 10 80       	push   $0x8010a580
80101cfe:	e8 35 1f 00 00       	call   80103c38 <initlock>
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
80101d6e:	e8 01 20 00 00       	call   80103d74 <acquire>

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
80101d9b:	e8 c8 1b 00 00       	call   80103968 <wakeup>

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
80101db9:	e8 1b 20 00 00       	call   80103dd9 <release>
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
80101dd0:	e8 04 20 00 00       	call   80103dd9 <release>
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
80101e08:	e8 dd 1d 00 00       	call   80103bea <holdingsleep>
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
80101e35:	e8 3a 1f 00 00       	call   80103d74 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e3a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e49:	eb 2a                	jmp    80101e75 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 ca 69 10 80       	push   $0x801069ca
80101e53:	e8 f0 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e58:	83 ec 0c             	sub    $0xc,%esp
80101e5b:	68 e0 69 10 80       	push   $0x801069e0
80101e60:	e8 e3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e65:	83 ec 0c             	sub    $0xc,%esp
80101e68:	68 f5 69 10 80       	push   $0x801069f5
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
80101e97:	e8 64 19 00 00       	call   80103800 <sleep>
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
80101eb1:	e8 23 1f 00 00       	call   80103dd9 <release>
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
80101f2d:	68 14 6a 10 80       	push   $0x80106a14
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
80101fcc:	e8 4f 1e 00 00       	call   80103e20 <memset>

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
80101ffb:	68 48 6a 10 80       	push   $0x80106a48
80102000:	e8 43 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80102005:	83 ec 0c             	sub    $0xc,%esp
80102008:	68 d6 6a 10 80       	push   $0x80106ad6
8010200d:	e8 36 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102012:	83 ec 0c             	sub    $0xc,%esp
80102015:	68 40 26 11 80       	push   $0x80112640
8010201a:	e8 55 1d 00 00       	call   80103d74 <acquire>
8010201f:	83 c4 10             	add    $0x10,%esp
80102022:	eb b9                	jmp    80101fdd <kfree+0x4b>
    release(&kmem.lock);
80102024:	83 ec 0c             	sub    $0xc,%esp
80102027:	68 40 26 11 80       	push   $0x80112640
8010202c:	e8 a8 1d 00 00       	call   80103dd9 <release>
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
80102054:	68 dc 6a 10 80       	push   $0x80106adc
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
80102083:	68 e6 6a 10 80       	push   $0x80106ae6
80102088:	68 40 26 11 80       	push   $0x80112640
8010208d:	e8 a6 1b 00 00       	call   80103c38 <initlock>
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
80102108:	e8 67 1c 00 00       	call   80103d74 <acquire>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	eb cd                	jmp    801020df <kalloc+0x10>
    release(&kmem.lock);
80102112:	83 ec 0c             	sub    $0xc,%esp
80102115:	68 40 26 11 80       	push   $0x80112640
8010211a:	e8 ba 1c 00 00       	call   80103dd9 <release>
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
80102164:	0f b6 8a 20 6c 10 80 	movzbl -0x7fef93e0(%edx),%ecx
8010216b:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
80102171:	0f b6 82 20 6b 10 80 	movzbl -0x7fef94e0(%edx),%eax
80102178:	31 c1                	xor    %eax,%ecx
8010217a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102180:	89 c8                	mov    %ecx,%eax
80102182:	83 e0 03             	and    $0x3,%eax
80102185:	8b 04 85 00 6b 10 80 	mov    -0x7fef9500(,%eax,4),%eax
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
801021c0:	0f b6 82 20 6c 10 80 	movzbl -0x7fef93e0(%edx),%eax
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
801024bb:	e8 a6 19 00 00       	call   80103e66 <memcmp>
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
80102626:	e8 70 18 00 00       	call   80103e9b <memmove>
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
80102725:	e8 71 17 00 00       	call   80103e9b <memmove>
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
80102793:	68 20 6d 10 80       	push   $0x80106d20
80102798:	68 80 26 11 80       	push   $0x80112680
8010279d:	e8 96 14 00 00       	call   80103c38 <initlock>
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
801027dd:	e8 92 15 00 00       	call   80103d74 <acquire>
801027e2:	83 c4 10             	add    $0x10,%esp
801027e5:	eb 15                	jmp    801027fc <begin_op+0x2a>
      sleep(&log, &log.lock);
801027e7:	83 ec 08             	sub    $0x8,%esp
801027ea:	68 80 26 11 80       	push   $0x80112680
801027ef:	68 80 26 11 80       	push   $0x80112680
801027f4:	e8 07 10 00 00       	call   80103800 <sleep>
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
8010282b:	e8 d0 0f 00 00       	call   80103800 <sleep>
80102830:	83 c4 10             	add    $0x10,%esp
80102833:	eb c7                	jmp    801027fc <begin_op+0x2a>
      log.outstanding += 1;
80102835:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	68 80 26 11 80       	push   $0x80112680
80102842:	e8 92 15 00 00       	call   80103dd9 <release>
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
80102858:	e8 17 15 00 00       	call   80103d74 <acquire>
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
80102892:	e8 42 15 00 00       	call   80103dd9 <release>
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
801028a6:	68 24 6d 10 80       	push   $0x80106d24
801028ab:	e8 98 da ff ff       	call   80100348 <panic>
    wakeup(&log);
801028b0:	83 ec 0c             	sub    $0xc,%esp
801028b3:	68 80 26 11 80       	push   $0x80112680
801028b8:	e8 ab 10 00 00       	call   80103968 <wakeup>
801028bd:	83 c4 10             	add    $0x10,%esp
801028c0:	eb c8                	jmp    8010288a <end_op+0x3e>
    commit();
801028c2:	e8 91 fe ff ff       	call   80102758 <commit>
    acquire(&log.lock);
801028c7:	83 ec 0c             	sub    $0xc,%esp
801028ca:	68 80 26 11 80       	push   $0x80112680
801028cf:	e8 a0 14 00 00       	call   80103d74 <acquire>
    log.committing = 0;
801028d4:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
801028db:	00 00 00 
    wakeup(&log);
801028de:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028e5:	e8 7e 10 00 00       	call   80103968 <wakeup>
    release(&log.lock);
801028ea:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028f1:	e8 e3 14 00 00       	call   80103dd9 <release>
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
8010292d:	e8 42 14 00 00       	call   80103d74 <acquire>
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
80102958:	68 33 6d 10 80       	push   $0x80106d33
8010295d:	e8 e6 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102962:	83 ec 0c             	sub    $0xc,%esp
80102965:	68 49 6d 10 80       	push   $0x80106d49
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
80102988:	e8 4c 14 00 00       	call   80103dd9 <release>
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
801029b6:	e8 e0 14 00 00       	call   80103e9b <memmove>

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
801029c8:	68 48 6a 10 80       	push   $0x80106a48
801029cd:	e8 76 d9 ff ff       	call   80100348 <panic>
801029d2:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029d8:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
801029df:	00 00 00 
801029e2:	05 80 27 11 80       	add    $0x80112780,%eax
801029e7:	39 d8                	cmp    %ebx,%eax
801029e9:	76 58                	jbe    80102a43 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
801029eb:	e8 3c 08 00 00       	call   8010322c <mycpu>
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
80102a4f:	e8 34 08 00 00       	call   80103288 <cpuid>
80102a54:	89 c3                	mov    %eax,%ebx
80102a56:	e8 2d 08 00 00       	call   80103288 <cpuid>
80102a5b:	83 ec 04             	sub    $0x4,%esp
80102a5e:	53                   	push   %ebx
80102a5f:	50                   	push   %eax
80102a60:	68 64 6d 10 80       	push   $0x80106d64
80102a65:	e8 a1 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a6a:	e8 e4 25 00 00       	call   80105053 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a6f:	e8 b8 07 00 00       	call   8010322c <mycpu>
80102a74:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a76:	b8 01 00 00 00       	mov    $0x1,%eax
80102a7b:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a82:	e8 ba 0a 00 00       	call   80103541 <scheduler>

80102a87 <mpenter>:
{
80102a87:	55                   	push   %ebp
80102a88:	89 e5                	mov    %esp,%ebp
80102a8a:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a8d:	e8 f4 35 00 00       	call   80106086 <switchkvm>
  seginit();
80102a92:	e8 a3 34 00 00       	call   80105f3a <seginit>
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
80102ac1:	e8 e0 3a 00 00       	call   801065a6 <kvmalloc>
  mpinit();        // detect other processors
80102ac6:	e8 e7 01 00 00       	call   80102cb2 <mpinit>
  lapicinit();     // interrupt controller
80102acb:	e8 c8 f7 ff ff       	call   80102298 <lapicinit>
  seginit();       // segment descriptors
80102ad0:	e8 65 34 00 00       	call   80105f3a <seginit>
  picinit();       // disable pic
80102ad5:	e8 a0 02 00 00       	call   80102d7a <picinit>
  ioapicinit();    // another interrupt controller
80102ada:	e8 09 f4 ff ff       	call   80101ee8 <ioapicinit>
  consoleinit();   // console hardware
80102adf:	e8 aa dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102ae4:	e8 18 28 00 00       	call   80105301 <uartinit>
  pinit();         // process table
80102ae9:	e8 24 07 00 00       	call   80103212 <pinit>
  tvinit();        // trap vectors
80102aee:	e8 af 24 00 00       	call   80104fa2 <tvinit>
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
80102b19:	e8 a9 07 00 00       	call   801032c7 <userinit>
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
80102b61:	68 78 6d 10 80       	push   $0x80106d78
80102b66:	e8 dd d7 ff ff       	call   80100348 <panic>
80102b6b:	83 c3 10             	add    $0x10,%ebx
80102b6e:	39 f3                	cmp    %esi,%ebx
80102b70:	73 29                	jae    80102b9b <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b72:	83 ec 04             	sub    $0x4,%esp
80102b75:	6a 04                	push   $0x4
80102b77:	68 92 6d 10 80       	push   $0x80106d92
80102b7c:	53                   	push   %ebx
80102b7d:	e8 e4 12 00 00       	call   80103e66 <memcmp>
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
80102c43:	68 97 6d 10 80       	push   $0x80106d97
80102c48:	53                   	push   %ebx
80102c49:	e8 18 12 00 00       	call   80103e66 <memcmp>
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
80102c85:	68 78 6d 10 80       	push   $0x80106d78
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
80102ce3:	68 9c 6d 10 80       	push   $0x80106d9c
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
80102d22:	ff 24 85 d4 6d 10 80 	jmp    *-0x7fef922c(,%eax,4)
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
80102d70:	68 b4 6d 10 80       	push   $0x80106db4
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
80102e2c:	68 e8 6d 10 80       	push   $0x80106de8
80102e31:	50                   	push   %eax
80102e32:	e8 01 0e 00 00       	call   80103c38 <initlock>
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
80102e88:	e8 e7 0e 00 00       	call   80103d74 <acquire>
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
80102eaa:	e8 b9 0a 00 00       	call   80103968 <wakeup>
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
80102ec8:	e8 0c 0f 00 00       	call   80103dd9 <release>
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
80102ee9:	e8 7a 0a 00 00       	call   80103968 <wakeup>
80102eee:	83 c4 10             	add    $0x10,%esp
80102ef1:	eb bf                	jmp    80102eb2 <pipeclose+0x35>
    release(&p->lock);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	53                   	push   %ebx
80102ef7:	e8 dd 0e 00 00       	call   80103dd9 <release>
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
80102f18:	e8 57 0e 00 00       	call   80103d74 <acquire>
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
80102f4c:	e8 52 03 00 00       	call   801032a3 <myproc>
80102f51:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f55:	75 24                	jne    80102f7b <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f57:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f5d:	83 ec 0c             	sub    $0xc,%esp
80102f60:	50                   	push   %eax
80102f61:	e8 02 0a 00 00       	call   80103968 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f66:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f6c:	83 c4 08             	add    $0x8,%esp
80102f6f:	56                   	push   %esi
80102f70:	50                   	push   %eax
80102f71:	e8 8a 08 00 00       	call   80103800 <sleep>
80102f76:	83 c4 10             	add    $0x10,%esp
80102f79:	eb b3                	jmp    80102f2e <pipewrite+0x25>
        release(&p->lock);
80102f7b:	83 ec 0c             	sub    $0xc,%esp
80102f7e:	53                   	push   %ebx
80102f7f:	e8 55 0e 00 00       	call   80103dd9 <release>
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
80102fc0:	e8 a3 09 00 00       	call   80103968 <wakeup>
  release(&p->lock);
80102fc5:	89 1c 24             	mov    %ebx,(%esp)
80102fc8:	e8 0c 0e 00 00       	call   80103dd9 <release>
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
80102fe4:	e8 8b 0d 00 00       	call   80103d74 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fe9:	83 c4 10             	add    $0x10,%esp
80102fec:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ff2:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102ff8:	75 3d                	jne    80103037 <piperead+0x62>
80102ffa:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103000:	85 f6                	test   %esi,%esi
80103002:	74 38                	je     8010303c <piperead+0x67>
    if(myproc()->killed){
80103004:	e8 9a 02 00 00       	call   801032a3 <myproc>
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
8010301a:	e8 e1 07 00 00       	call   80103800 <sleep>
8010301f:	83 c4 10             	add    $0x10,%esp
80103022:	eb c8                	jmp    80102fec <piperead+0x17>
      release(&p->lock);
80103024:	83 ec 0c             	sub    $0xc,%esp
80103027:	53                   	push   %ebx
80103028:	e8 ac 0d 00 00       	call   80103dd9 <release>
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
80103077:	e8 ec 08 00 00       	call   80103968 <wakeup>
  release(&p->lock);
8010307c:	89 1c 24             	mov    %ebx,(%esp)
8010307f:	e8 55 0d 00 00       	call   80103dd9 <release>
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
801030cb:	e8 a4 0c 00 00       	call   80103d74 <acquire>
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
801030f6:	e8 de 0c 00 00       	call   80103dd9 <release>
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
80103125:	e8 af 0c 00 00       	call   80103dd9 <release>
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
80103142:	c7 80 b0 0f 00 00 97 	movl   $0x80104f97,0xfb0(%eax)
80103149:	4f 10 80 
  sp -= sizeof *p->context;
8010314c:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103151:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103154:	83 ec 04             	sub    $0x4,%esp
80103157:	6a 14                	push   $0x14
80103159:	6a 00                	push   $0x0
8010315b:	50                   	push   %eax
8010315c:	e8 bf 0c 00 00       	call   80103e20 <memset>
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
8010318e:	e8 46 0c 00 00       	call   80103dd9 <release>
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

801031c6 <lcg_parkmiller>:
static unsigned random_seed = 1;

//#define RANDOM_MAX ((1u << 31u) - 1u)
#define RANDOM_MAX  100000
unsigned lcg_parkmiller(unsigned *state)
{
801031c6:	55                   	push   %ebp
801031c7:	89 e5                	mov    %esp,%ebp
801031c9:	53                   	push   %ebx
801031ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
        Therefore:
          rem*G - div*(N%G) === state*G  (mod N)

        Add N if necessary so that the result is between 1 and N-1.
    */
    unsigned div = *state / (N / G);  /* max : 2,147,483,646 / 44,488 = 48,271 */
801031cd:	8b 19                	mov    (%ecx),%ebx
801031cf:	ba 91 13 8f bc       	mov    $0xbc8f1391,%edx
801031d4:	89 d8                	mov    %ebx,%eax
801031d6:	f7 e2                	mul    %edx
801031d8:	c1 ea 0f             	shr    $0xf,%edx
    unsigned rem = *state % (N / G);  /* max : 2,147,483,646 % 44,488 = 44,487 */
801031db:	69 c2 c8 ad 00 00    	imul   $0xadc8,%edx,%eax
801031e1:	29 c3                	sub    %eax,%ebx

    unsigned a = rem * G;        /* max : 44,487 * 48,271 = 2,147,431,977 */
801031e3:	69 c3 8f bc 00 00    	imul   $0xbc8f,%ebx,%eax
    unsigned b = div * (N % G);  /* max : 48,271 * 3,399 = 164,073,129 */
801031e9:	69 d2 47 0d 00 00    	imul   $0xd47,%edx,%edx

    return *state = (a > b) ? (a - b) : (a + (N - b)) ;
801031ef:	39 d0                	cmp    %edx,%eax
801031f1:	77 0c                	ja     801031ff <lcg_parkmiller+0x39>
801031f3:	29 d0                	sub    %edx,%eax
801031f5:	05 ff ff ff 7f       	add    $0x7fffffff,%eax
801031fa:	89 01                	mov    %eax,(%ecx)
}
801031fc:	5b                   	pop    %ebx
801031fd:	5d                   	pop    %ebp
801031fe:	c3                   	ret    
    return *state = (a > b) ? (a - b) : (a + (N - b)) ;
801031ff:	29 d0                	sub    %edx,%eax
80103201:	eb f7                	jmp    801031fa <lcg_parkmiller+0x34>

80103203 <next_random>:

unsigned next_random() {
80103203:	55                   	push   %ebp
80103204:	89 e5                	mov    %esp,%ebp
    return lcg_parkmiller(&random_seed);
80103206:	68 08 a0 10 80       	push   $0x8010a008
8010320b:	e8 b6 ff ff ff       	call   801031c6 <lcg_parkmiller>
}
80103210:	c9                   	leave  
80103211:	c3                   	ret    

80103212 <pinit>:
{
80103212:	55                   	push   %ebp
80103213:	89 e5                	mov    %esp,%ebp
80103215:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103218:	68 ed 6d 10 80       	push   $0x80106ded
8010321d:	68 20 2d 11 80       	push   $0x80112d20
80103222:	e8 11 0a 00 00       	call   80103c38 <initlock>
}
80103227:	83 c4 10             	add    $0x10,%esp
8010322a:	c9                   	leave  
8010322b:	c3                   	ret    

8010322c <mycpu>:
{
8010322c:	55                   	push   %ebp
8010322d:	89 e5                	mov    %esp,%ebp
8010322f:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103232:	9c                   	pushf  
80103233:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103234:	f6 c4 02             	test   $0x2,%ah
80103237:	75 28                	jne    80103261 <mycpu+0x35>
  apicid = lapicid();
80103239:	e8 64 f1 ff ff       	call   801023a2 <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010323e:	ba 00 00 00 00       	mov    $0x0,%edx
80103243:	39 15 00 2d 11 80    	cmp    %edx,0x80112d00
80103249:	7e 23                	jle    8010326e <mycpu+0x42>
    if (cpus[i].apicid == apicid)
8010324b:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103251:	0f b6 89 80 27 11 80 	movzbl -0x7feed880(%ecx),%ecx
80103258:	39 c1                	cmp    %eax,%ecx
8010325a:	74 1f                	je     8010327b <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010325c:	83 c2 01             	add    $0x1,%edx
8010325f:	eb e2                	jmp    80103243 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 ec 6e 10 80       	push   $0x80106eec
80103269:	e8 da d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010326e:	83 ec 0c             	sub    $0xc,%esp
80103271:	68 f4 6d 10 80       	push   $0x80106df4
80103276:	e8 cd d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
8010327b:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103281:	05 80 27 11 80       	add    $0x80112780,%eax
}
80103286:	c9                   	leave  
80103287:	c3                   	ret    

80103288 <cpuid>:
cpuid() {
80103288:	55                   	push   %ebp
80103289:	89 e5                	mov    %esp,%ebp
8010328b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010328e:	e8 99 ff ff ff       	call   8010322c <mycpu>
80103293:	2d 80 27 11 80       	sub    $0x80112780,%eax
80103298:	c1 f8 04             	sar    $0x4,%eax
8010329b:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032a1:	c9                   	leave  
801032a2:	c3                   	ret    

801032a3 <myproc>:
myproc(void) {
801032a3:	55                   	push   %ebp
801032a4:	89 e5                	mov    %esp,%ebp
801032a6:	53                   	push   %ebx
801032a7:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032aa:	e8 e8 09 00 00       	call   80103c97 <pushcli>
  c = mycpu();
801032af:	e8 78 ff ff ff       	call   8010322c <mycpu>
  p = c->proc;
801032b4:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032ba:	e8 15 0a 00 00       	call   80103cd4 <popcli>
}
801032bf:	89 d8                	mov    %ebx,%eax
801032c1:	83 c4 04             	add    $0x4,%esp
801032c4:	5b                   	pop    %ebx
801032c5:	5d                   	pop    %ebp
801032c6:	c3                   	ret    

801032c7 <userinit>:
{
801032c7:	55                   	push   %ebp
801032c8:	89 e5                	mov    %esp,%ebp
801032ca:	53                   	push   %ebx
801032cb:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801032ce:	e8 ec fd ff ff       	call   801030bf <allocproc>
801032d3:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032d5:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
801032da:	e8 59 32 00 00       	call   80106538 <setupkvm>
801032df:	89 43 04             	mov    %eax,0x4(%ebx)
801032e2:	85 c0                	test   %eax,%eax
801032e4:	0f 84 c1 00 00 00    	je     801033ab <userinit+0xe4>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032ea:	83 ec 04             	sub    $0x4,%esp
801032ed:	68 2c 00 00 00       	push   $0x2c
801032f2:	68 60 a4 10 80       	push   $0x8010a460
801032f7:	50                   	push   %eax
801032f8:	e8 da 2e 00 00       	call   801061d7 <inituvm>
  p->sz = PGSIZE;
801032fd:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103303:	83 c4 0c             	add    $0xc,%esp
80103306:	6a 4c                	push   $0x4c
80103308:	6a 00                	push   $0x0
8010330a:	ff 73 18             	pushl  0x18(%ebx)
8010330d:	e8 0e 0b 00 00       	call   80103e20 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103312:	8b 43 18             	mov    0x18(%ebx),%eax
80103315:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010331b:	8b 43 18             	mov    0x18(%ebx),%eax
8010331e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103324:	8b 43 18             	mov    0x18(%ebx),%eax
80103327:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010332b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010332f:	8b 43 18             	mov    0x18(%ebx),%eax
80103332:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103336:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010333a:	8b 43 18             	mov    0x18(%ebx),%eax
8010333d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103344:	8b 43 18             	mov    0x18(%ebx),%eax
80103347:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010334e:	8b 43 18             	mov    0x18(%ebx),%eax
80103351:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  p->tickets = 10;
80103358:	c7 83 80 00 00 00 0a 	movl   $0xa,0x80(%ebx)
8010335f:	00 00 00 
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103362:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103365:	83 c4 0c             	add    $0xc,%esp
80103368:	6a 10                	push   $0x10
8010336a:	68 1d 6e 10 80       	push   $0x80106e1d
8010336f:	50                   	push   %eax
80103370:	e8 12 0c 00 00       	call   80103f87 <safestrcpy>
  p->cwd = namei("/");
80103375:	c7 04 24 26 6e 10 80 	movl   $0x80106e26,(%esp)
8010337c:	e8 4e e8 ff ff       	call   80101bcf <namei>
80103381:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103384:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010338b:	e8 e4 09 00 00       	call   80103d74 <acquire>
  p->state = RUNNABLE;
80103390:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103397:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010339e:	e8 36 0a 00 00       	call   80103dd9 <release>
}
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033a9:	c9                   	leave  
801033aa:	c3                   	ret    
    panic("userinit: out of memory?");
801033ab:	83 ec 0c             	sub    $0xc,%esp
801033ae:	68 04 6e 10 80       	push   $0x80106e04
801033b3:	e8 90 cf ff ff       	call   80100348 <panic>

801033b8 <growproc>:
{
801033b8:	55                   	push   %ebp
801033b9:	89 e5                	mov    %esp,%ebp
801033bb:	56                   	push   %esi
801033bc:	53                   	push   %ebx
801033bd:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033c0:	e8 de fe ff ff       	call   801032a3 <myproc>
801033c5:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033c7:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033c9:	85 f6                	test   %esi,%esi
801033cb:	7f 21                	jg     801033ee <growproc+0x36>
  } else if(n < 0){
801033cd:	85 f6                	test   %esi,%esi
801033cf:	79 33                	jns    80103404 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033d1:	83 ec 04             	sub    $0x4,%esp
801033d4:	01 c6                	add    %eax,%esi
801033d6:	56                   	push   %esi
801033d7:	50                   	push   %eax
801033d8:	ff 73 04             	pushl  0x4(%ebx)
801033db:	e8 2c 2f 00 00       	call   8010630c <deallocuvm>
801033e0:	83 c4 10             	add    $0x10,%esp
801033e3:	85 c0                	test   %eax,%eax
801033e5:	75 1d                	jne    80103404 <growproc+0x4c>
      return -1;
801033e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033ec:	eb 29                	jmp    80103417 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033ee:	83 ec 04             	sub    $0x4,%esp
801033f1:	01 c6                	add    %eax,%esi
801033f3:	56                   	push   %esi
801033f4:	50                   	push   %eax
801033f5:	ff 73 04             	pushl  0x4(%ebx)
801033f8:	e8 b5 2f 00 00       	call   801063b2 <allocuvm>
801033fd:	83 c4 10             	add    $0x10,%esp
80103400:	85 c0                	test   %eax,%eax
80103402:	74 1a                	je     8010341e <growproc+0x66>
  curproc->sz = sz;
80103404:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103406:	83 ec 0c             	sub    $0xc,%esp
80103409:	53                   	push   %ebx
8010340a:	e8 9c 2c 00 00       	call   801060ab <switchuvm>
  return 0;
8010340f:	83 c4 10             	add    $0x10,%esp
80103412:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103417:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010341a:	5b                   	pop    %ebx
8010341b:	5e                   	pop    %esi
8010341c:	5d                   	pop    %ebp
8010341d:	c3                   	ret    
      return -1;
8010341e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103423:	eb f2                	jmp    80103417 <growproc+0x5f>

80103425 <fork>:
{
80103425:	55                   	push   %ebp
80103426:	89 e5                	mov    %esp,%ebp
80103428:	57                   	push   %edi
80103429:	56                   	push   %esi
8010342a:	53                   	push   %ebx
8010342b:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010342e:	e8 70 fe ff ff       	call   801032a3 <myproc>
80103433:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103435:	e8 85 fc ff ff       	call   801030bf <allocproc>
8010343a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010343d:	85 c0                	test   %eax,%eax
8010343f:	0f 84 f5 00 00 00    	je     8010353a <fork+0x115>
80103445:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103447:	83 ec 08             	sub    $0x8,%esp
8010344a:	ff 33                	pushl  (%ebx)
8010344c:	ff 73 04             	pushl  0x4(%ebx)
8010344f:	e8 95 31 00 00       	call   801065e9 <copyuvm>
80103454:	89 47 04             	mov    %eax,0x4(%edi)
80103457:	83 c4 10             	add    $0x10,%esp
8010345a:	85 c0                	test   %eax,%eax
8010345c:	74 3f                	je     8010349d <fork+0x78>
  np->sz = curproc->sz;
8010345e:	8b 03                	mov    (%ebx),%eax
80103460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103463:	89 07                	mov    %eax,(%edi)
  np->parent = curproc;
80103465:	89 f8                	mov    %edi,%eax
80103467:	89 5f 14             	mov    %ebx,0x14(%edi)
  *np->tf = *curproc->tf;
8010346a:	8b 73 18             	mov    0x18(%ebx),%esi
8010346d:	8b 7f 18             	mov    0x18(%edi),%edi
80103470:	b9 13 00 00 00       	mov    $0x13,%ecx
80103475:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->num_times_scheduled = 0;
80103477:	89 c1                	mov    %eax,%ecx
80103479:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  np->tickets = curproc->tickets;
80103480:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
80103486:	89 81 80 00 00 00    	mov    %eax,0x80(%ecx)
  np->tf->eax = 0;
8010348c:	8b 41 18             	mov    0x18(%ecx),%eax
8010348f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103496:	be 00 00 00 00       	mov    $0x0,%esi
8010349b:	eb 29                	jmp    801034c6 <fork+0xa1>
    kfree(np->kstack);
8010349d:	83 ec 0c             	sub    $0xc,%esp
801034a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801034a3:	ff 73 08             	pushl  0x8(%ebx)
801034a6:	e8 e7 ea ff ff       	call   80101f92 <kfree>
    np->kstack = 0;
801034ab:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801034b2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801034b9:	83 c4 10             	add    $0x10,%esp
801034bc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034c1:	eb 6d                	jmp    80103530 <fork+0x10b>
  for(i = 0; i < NOFILE; i++)
801034c3:	83 c6 01             	add    $0x1,%esi
801034c6:	83 fe 0f             	cmp    $0xf,%esi
801034c9:	7f 1d                	jg     801034e8 <fork+0xc3>
    if(curproc->ofile[i])
801034cb:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034cf:	85 c0                	test   %eax,%eax
801034d1:	74 f0                	je     801034c3 <fork+0x9e>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034d3:	83 ec 0c             	sub    $0xc,%esp
801034d6:	50                   	push   %eax
801034d7:	e8 b2 d7 ff ff       	call   80100c8e <filedup>
801034dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034df:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801034e3:	83 c4 10             	add    $0x10,%esp
801034e6:	eb db                	jmp    801034c3 <fork+0x9e>
  np->cwd = idup(curproc->cwd);
801034e8:	83 ec 0c             	sub    $0xc,%esp
801034eb:	ff 73 68             	pushl  0x68(%ebx)
801034ee:	e8 4c e0 ff ff       	call   8010153f <idup>
801034f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801034f6:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034f9:	83 c3 6c             	add    $0x6c,%ebx
801034fc:	8d 47 6c             	lea    0x6c(%edi),%eax
801034ff:	83 c4 0c             	add    $0xc,%esp
80103502:	6a 10                	push   $0x10
80103504:	53                   	push   %ebx
80103505:	50                   	push   %eax
80103506:	e8 7c 0a 00 00       	call   80103f87 <safestrcpy>
  pid = np->pid;
8010350b:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010350e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103515:	e8 5a 08 00 00       	call   80103d74 <acquire>
  np->state = RUNNABLE;
8010351a:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103521:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103528:	e8 ac 08 00 00       	call   80103dd9 <release>
  return pid;
8010352d:	83 c4 10             	add    $0x10,%esp
}
80103530:	89 d8                	mov    %ebx,%eax
80103532:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103535:	5b                   	pop    %ebx
80103536:	5e                   	pop    %esi
80103537:	5f                   	pop    %edi
80103538:	5d                   	pop    %ebp
80103539:	c3                   	ret    
    return -1;
8010353a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010353f:	eb ef                	jmp    80103530 <fork+0x10b>

80103541 <scheduler>:
{
80103541:	55                   	push   %ebp
80103542:	89 e5                	mov    %esp,%ebp
80103544:	57                   	push   %edi
80103545:	56                   	push   %esi
80103546:	53                   	push   %ebx
80103547:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
8010354a:	e8 dd fc ff ff       	call   8010322c <mycpu>
8010354f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
80103552:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103559:	00 00 00 
8010355c:	e9 dc 00 00 00       	jmp    8010363d <scheduler+0xfc>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103561:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103567:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
8010356d:	73 27                	jae    80103596 <scheduler+0x55>
      if(p->state != RUNNABLE)
8010356f:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103573:	75 ec                	jne    80103561 <scheduler+0x20>
      runnable_processes++;
80103575:	83 c6 01             	add    $0x1,%esi
      total_tickets += p->tickets;
80103578:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
8010357e:	01 c7                	add    %eax,%edi
      cprintf("process %d has %d tickets \n", p->pid, p->tickets);
80103580:	83 ec 04             	sub    $0x4,%esp
80103583:	50                   	push   %eax
80103584:	ff 73 10             	pushl  0x10(%ebx)
80103587:	68 28 6e 10 80       	push   $0x80106e28
8010358c:	e8 7a d0 ff ff       	call   8010060b <cprintf>
80103591:	83 c4 10             	add    $0x10,%esp
80103594:	eb cb                	jmp    80103561 <scheduler+0x20>
    if(runnable_processes == 0){
80103596:	85 f6                	test   %esi,%esi
80103598:	74 21                	je     801035bb <scheduler+0x7a>
    unsigned myRandom = next_random();
8010359a:	e8 64 fc ff ff       	call   80103203 <next_random>
    myRandom = myRandom % total_tickets;
8010359f:	ba 00 00 00 00       	mov    $0x0,%edx
801035a4:	f7 f7                	div    %edi
801035a6:	89 d7                	mov    %edx,%edi
    if(myRandom == 0) myRandom++;
801035a8:	85 d2                	test   %edx,%edx
801035aa:	75 03                	jne    801035af <scheduler+0x6e>
801035ac:	8d 7a 01             	lea    0x1(%edx),%edi
    int tick_index = 0;
801035af:	be 00 00 00 00       	mov    $0x0,%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035b4:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801035b9:	eb 18                	jmp    801035d3 <scheduler+0x92>
      release(&ptable.lock);
801035bb:	83 ec 0c             	sub    $0xc,%esp
801035be:	68 20 2d 11 80       	push   $0x80112d20
801035c3:	e8 11 08 00 00       	call   80103dd9 <release>
      continue;
801035c8:	83 c4 10             	add    $0x10,%esp
801035cb:	eb 70                	jmp    8010363d <scheduler+0xfc>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035cd:	81 c3 84 00 00 00    	add    $0x84,%ebx
801035d3:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
801035d9:	73 52                	jae    8010362d <scheduler+0xec>
      if(p->state != RUNNABLE) continue;
801035db:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035df:	75 ec                	jne    801035cd <scheduler+0x8c>
      tick_index += p->tickets;
801035e1:	03 b3 80 00 00 00    	add    0x80(%ebx),%esi
      if(tick_index < myRandInt) continue;
801035e7:	39 f7                	cmp    %esi,%edi
801035e9:	7f e2                	jg     801035cd <scheduler+0x8c>
      c->proc = p;
801035eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801035ee:	89 98 ac 00 00 00    	mov    %ebx,0xac(%eax)
      switchuvm(p);
801035f4:	83 ec 0c             	sub    $0xc,%esp
801035f7:	53                   	push   %ebx
801035f8:	e8 ae 2a 00 00       	call   801060ab <switchuvm>
      p->state = RUNNING;
801035fd:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103604:	83 c4 08             	add    $0x8,%esp
80103607:	ff 73 1c             	pushl  0x1c(%ebx)
8010360a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010360d:	83 c0 04             	add    $0x4,%eax
80103610:	50                   	push   %eax
80103611:	e8 c4 09 00 00       	call   80103fda <swtch>
      switchkvm();
80103616:	e8 6b 2a 00 00       	call   80106086 <switchkvm>
      c->proc = 0;
8010361b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010361e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103625:	00 00 00 
80103628:	83 c4 10             	add    $0x10,%esp
8010362b:	eb a0                	jmp    801035cd <scheduler+0x8c>
    release(&ptable.lock);
8010362d:	83 ec 0c             	sub    $0xc,%esp
80103630:	68 20 2d 11 80       	push   $0x80112d20
80103635:	e8 9f 07 00 00       	call   80103dd9 <release>
8010363a:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
8010363d:	fb                   	sti    
    acquire(&ptable.lock);
8010363e:	83 ec 0c             	sub    $0xc,%esp
80103641:	68 20 2d 11 80       	push   $0x80112d20
80103646:	e8 29 07 00 00       	call   80103d74 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010364b:	83 c4 10             	add    $0x10,%esp
    int runnable_processes = 0;
8010364e:	be 00 00 00 00       	mov    $0x0,%esi
    int total_tickets = 0;
80103653:	bf 00 00 00 00       	mov    $0x0,%edi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103658:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010365d:	e9 05 ff ff ff       	jmp    80103567 <scheduler+0x26>

80103662 <sched>:
{
80103662:	55                   	push   %ebp
80103663:	89 e5                	mov    %esp,%ebp
80103665:	56                   	push   %esi
80103666:	53                   	push   %ebx
  struct proc *p = myproc();
80103667:	e8 37 fc ff ff       	call   801032a3 <myproc>
8010366c:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010366e:	83 ec 0c             	sub    $0xc,%esp
80103671:	68 20 2d 11 80       	push   $0x80112d20
80103676:	e8 b9 06 00 00       	call   80103d34 <holding>
8010367b:	83 c4 10             	add    $0x10,%esp
8010367e:	85 c0                	test   %eax,%eax
80103680:	74 4f                	je     801036d1 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103682:	e8 a5 fb ff ff       	call   8010322c <mycpu>
80103687:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010368e:	75 4e                	jne    801036de <sched+0x7c>
  if(p->state == RUNNING)
80103690:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103694:	74 55                	je     801036eb <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103696:	9c                   	pushf  
80103697:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103698:	f6 c4 02             	test   $0x2,%ah
8010369b:	75 5b                	jne    801036f8 <sched+0x96>
  intena = mycpu()->intena;
8010369d:	e8 8a fb ff ff       	call   8010322c <mycpu>
801036a2:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801036a8:	e8 7f fb ff ff       	call   8010322c <mycpu>
801036ad:	83 ec 08             	sub    $0x8,%esp
801036b0:	ff 70 04             	pushl  0x4(%eax)
801036b3:	83 c3 1c             	add    $0x1c,%ebx
801036b6:	53                   	push   %ebx
801036b7:	e8 1e 09 00 00       	call   80103fda <swtch>
  mycpu()->intena = intena;
801036bc:	e8 6b fb ff ff       	call   8010322c <mycpu>
801036c1:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801036c7:	83 c4 10             	add    $0x10,%esp
801036ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036cd:	5b                   	pop    %ebx
801036ce:	5e                   	pop    %esi
801036cf:	5d                   	pop    %ebp
801036d0:	c3                   	ret    
    panic("sched ptable.lock");
801036d1:	83 ec 0c             	sub    $0xc,%esp
801036d4:	68 44 6e 10 80       	push   $0x80106e44
801036d9:	e8 6a cc ff ff       	call   80100348 <panic>
    panic("sched locks");
801036de:	83 ec 0c             	sub    $0xc,%esp
801036e1:	68 56 6e 10 80       	push   $0x80106e56
801036e6:	e8 5d cc ff ff       	call   80100348 <panic>
    panic("sched running");
801036eb:	83 ec 0c             	sub    $0xc,%esp
801036ee:	68 62 6e 10 80       	push   $0x80106e62
801036f3:	e8 50 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801036f8:	83 ec 0c             	sub    $0xc,%esp
801036fb:	68 70 6e 10 80       	push   $0x80106e70
80103700:	e8 43 cc ff ff       	call   80100348 <panic>

80103705 <exit>:
{
80103705:	55                   	push   %ebp
80103706:	89 e5                	mov    %esp,%ebp
80103708:	56                   	push   %esi
80103709:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010370a:	e8 94 fb ff ff       	call   801032a3 <myproc>
  if(curproc == initproc)
8010370f:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
80103715:	74 09                	je     80103720 <exit+0x1b>
80103717:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103719:	bb 00 00 00 00       	mov    $0x0,%ebx
8010371e:	eb 10                	jmp    80103730 <exit+0x2b>
    panic("init exiting");
80103720:	83 ec 0c             	sub    $0xc,%esp
80103723:	68 84 6e 10 80       	push   $0x80106e84
80103728:	e8 1b cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010372d:	83 c3 01             	add    $0x1,%ebx
80103730:	83 fb 0f             	cmp    $0xf,%ebx
80103733:	7f 1e                	jg     80103753 <exit+0x4e>
    if(curproc->ofile[fd]){
80103735:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103739:	85 c0                	test   %eax,%eax
8010373b:	74 f0                	je     8010372d <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010373d:	83 ec 0c             	sub    $0xc,%esp
80103740:	50                   	push   %eax
80103741:	e8 8d d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103746:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010374d:	00 
8010374e:	83 c4 10             	add    $0x10,%esp
80103751:	eb da                	jmp    8010372d <exit+0x28>
  begin_op();
80103753:	e8 7a f0 ff ff       	call   801027d2 <begin_op>
  iput(curproc->cwd);
80103758:	83 ec 0c             	sub    $0xc,%esp
8010375b:	ff 76 68             	pushl  0x68(%esi)
8010375e:	e8 13 df ff ff       	call   80101676 <iput>
  end_op();
80103763:	e8 e4 f0 ff ff       	call   8010284c <end_op>
  curproc->cwd = 0;
80103768:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010376f:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103776:	e8 f9 05 00 00       	call   80103d74 <acquire>
  wakeup1(curproc->parent);
8010377b:	8b 46 14             	mov    0x14(%esi),%eax
8010377e:	e8 0e f9 ff ff       	call   80103091 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103783:	83 c4 10             	add    $0x10,%esp
80103786:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010378b:	eb 06                	jmp    80103793 <exit+0x8e>
8010378d:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103793:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103799:	73 1a                	jae    801037b5 <exit+0xb0>
    if(p->parent == curproc){
8010379b:	39 73 14             	cmp    %esi,0x14(%ebx)
8010379e:	75 ed                	jne    8010378d <exit+0x88>
      p->parent = initproc;
801037a0:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801037a5:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801037a8:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037ac:	75 df                	jne    8010378d <exit+0x88>
        wakeup1(initproc);
801037ae:	e8 de f8 ff ff       	call   80103091 <wakeup1>
801037b3:	eb d8                	jmp    8010378d <exit+0x88>
  curproc->state = ZOMBIE;
801037b5:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801037bc:	e8 a1 fe ff ff       	call   80103662 <sched>
  panic("zombie exit");
801037c1:	83 ec 0c             	sub    $0xc,%esp
801037c4:	68 91 6e 10 80       	push   $0x80106e91
801037c9:	e8 7a cb ff ff       	call   80100348 <panic>

801037ce <yield>:
{
801037ce:	55                   	push   %ebp
801037cf:	89 e5                	mov    %esp,%ebp
801037d1:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801037d4:	68 20 2d 11 80       	push   $0x80112d20
801037d9:	e8 96 05 00 00       	call   80103d74 <acquire>
  myproc()->state = RUNNABLE;
801037de:	e8 c0 fa ff ff       	call   801032a3 <myproc>
801037e3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801037ea:	e8 73 fe ff ff       	call   80103662 <sched>
  release(&ptable.lock);
801037ef:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037f6:	e8 de 05 00 00       	call   80103dd9 <release>
}
801037fb:	83 c4 10             	add    $0x10,%esp
801037fe:	c9                   	leave  
801037ff:	c3                   	ret    

80103800 <sleep>:
{
80103800:	55                   	push   %ebp
80103801:	89 e5                	mov    %esp,%ebp
80103803:	56                   	push   %esi
80103804:	53                   	push   %ebx
80103805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103808:	e8 96 fa ff ff       	call   801032a3 <myproc>
  if(p == 0)
8010380d:	85 c0                	test   %eax,%eax
8010380f:	74 66                	je     80103877 <sleep+0x77>
80103811:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103813:	85 db                	test   %ebx,%ebx
80103815:	74 6d                	je     80103884 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103817:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
8010381d:	74 18                	je     80103837 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010381f:	83 ec 0c             	sub    $0xc,%esp
80103822:	68 20 2d 11 80       	push   $0x80112d20
80103827:	e8 48 05 00 00       	call   80103d74 <acquire>
    release(lk);
8010382c:	89 1c 24             	mov    %ebx,(%esp)
8010382f:	e8 a5 05 00 00       	call   80103dd9 <release>
80103834:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103837:	8b 45 08             	mov    0x8(%ebp),%eax
8010383a:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
8010383d:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103844:	e8 19 fe ff ff       	call   80103662 <sched>
  p->chan = 0;
80103849:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103850:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
80103856:	74 18                	je     80103870 <sleep+0x70>
    release(&ptable.lock);
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	68 20 2d 11 80       	push   $0x80112d20
80103860:	e8 74 05 00 00       	call   80103dd9 <release>
    acquire(lk);
80103865:	89 1c 24             	mov    %ebx,(%esp)
80103868:	e8 07 05 00 00       	call   80103d74 <acquire>
8010386d:	83 c4 10             	add    $0x10,%esp
}
80103870:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103873:	5b                   	pop    %ebx
80103874:	5e                   	pop    %esi
80103875:	5d                   	pop    %ebp
80103876:	c3                   	ret    
    panic("sleep");
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	68 9d 6e 10 80       	push   $0x80106e9d
8010387f:	e8 c4 ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103884:	83 ec 0c             	sub    $0xc,%esp
80103887:	68 a3 6e 10 80       	push   $0x80106ea3
8010388c:	e8 b7 ca ff ff       	call   80100348 <panic>

80103891 <wait>:
{
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	56                   	push   %esi
80103895:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103896:	e8 08 fa ff ff       	call   801032a3 <myproc>
8010389b:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010389d:	83 ec 0c             	sub    $0xc,%esp
801038a0:	68 20 2d 11 80       	push   $0x80112d20
801038a5:	e8 ca 04 00 00       	call   80103d74 <acquire>
801038aa:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801038ad:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038b2:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801038b7:	eb 5e                	jmp    80103917 <wait+0x86>
        pid = p->pid;
801038b9:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801038bc:	83 ec 0c             	sub    $0xc,%esp
801038bf:	ff 73 08             	pushl  0x8(%ebx)
801038c2:	e8 cb e6 ff ff       	call   80101f92 <kfree>
        p->kstack = 0;
801038c7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801038ce:	83 c4 04             	add    $0x4,%esp
801038d1:	ff 73 04             	pushl  0x4(%ebx)
801038d4:	e8 db 2b 00 00       	call   801064b4 <freevm>
        p->pid = 0;
801038d9:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801038e0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038e7:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038eb:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038f2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801038f9:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103900:	e8 d4 04 00 00       	call   80103dd9 <release>
        return pid;
80103905:	83 c4 10             	add    $0x10,%esp
}
80103908:	89 f0                	mov    %esi,%eax
8010390a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010390d:	5b                   	pop    %ebx
8010390e:	5e                   	pop    %esi
8010390f:	5d                   	pop    %ebp
80103910:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103911:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103917:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
8010391d:	73 12                	jae    80103931 <wait+0xa0>
      if(p->parent != curproc)
8010391f:	39 73 14             	cmp    %esi,0x14(%ebx)
80103922:	75 ed                	jne    80103911 <wait+0x80>
      if(p->state == ZOMBIE){
80103924:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103928:	74 8f                	je     801038b9 <wait+0x28>
      havekids = 1;
8010392a:	b8 01 00 00 00       	mov    $0x1,%eax
8010392f:	eb e0                	jmp    80103911 <wait+0x80>
    if(!havekids || curproc->killed){
80103931:	85 c0                	test   %eax,%eax
80103933:	74 06                	je     8010393b <wait+0xaa>
80103935:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103939:	74 17                	je     80103952 <wait+0xc1>
      release(&ptable.lock);
8010393b:	83 ec 0c             	sub    $0xc,%esp
8010393e:	68 20 2d 11 80       	push   $0x80112d20
80103943:	e8 91 04 00 00       	call   80103dd9 <release>
      return -1;
80103948:	83 c4 10             	add    $0x10,%esp
8010394b:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103950:	eb b6                	jmp    80103908 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103952:	83 ec 08             	sub    $0x8,%esp
80103955:	68 20 2d 11 80       	push   $0x80112d20
8010395a:	56                   	push   %esi
8010395b:	e8 a0 fe ff ff       	call   80103800 <sleep>
    havekids = 0;
80103960:	83 c4 10             	add    $0x10,%esp
80103963:	e9 45 ff ff ff       	jmp    801038ad <wait+0x1c>

80103968 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010396e:	68 20 2d 11 80       	push   $0x80112d20
80103973:	e8 fc 03 00 00       	call   80103d74 <acquire>
  wakeup1(chan);
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	e8 11 f7 ff ff       	call   80103091 <wakeup1>
  release(&ptable.lock);
80103980:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103987:	e8 4d 04 00 00       	call   80103dd9 <release>
}
8010398c:	83 c4 10             	add    $0x10,%esp
8010398f:	c9                   	leave  
80103990:	c3                   	ret    

80103991 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103991:	55                   	push   %ebp
80103992:	89 e5                	mov    %esp,%ebp
80103994:	53                   	push   %ebx
80103995:	83 ec 10             	sub    $0x10,%esp
80103998:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010399b:	68 20 2d 11 80       	push   $0x80112d20
801039a0:	e8 cf 03 00 00       	call   80103d74 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039a5:	83 c4 10             	add    $0x10,%esp
801039a8:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
801039ad:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
801039b2:	73 3c                	jae    801039f0 <kill+0x5f>
    if(p->pid == pid){
801039b4:	39 58 10             	cmp    %ebx,0x10(%eax)
801039b7:	74 07                	je     801039c0 <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039b9:	05 84 00 00 00       	add    $0x84,%eax
801039be:	eb ed                	jmp    801039ad <kill+0x1c>
      p->killed = 1;
801039c0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801039c7:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801039cb:	74 1a                	je     801039e7 <kill+0x56>
        p->state = RUNNABLE;
      release(&ptable.lock);
801039cd:	83 ec 0c             	sub    $0xc,%esp
801039d0:	68 20 2d 11 80       	push   $0x80112d20
801039d5:	e8 ff 03 00 00       	call   80103dd9 <release>
      return 0;
801039da:	83 c4 10             	add    $0x10,%esp
801039dd:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039e5:	c9                   	leave  
801039e6:	c3                   	ret    
        p->state = RUNNABLE;
801039e7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801039ee:	eb dd                	jmp    801039cd <kill+0x3c>
  release(&ptable.lock);
801039f0:	83 ec 0c             	sub    $0xc,%esp
801039f3:	68 20 2d 11 80       	push   $0x80112d20
801039f8:	e8 dc 03 00 00       	call   80103dd9 <release>
  return -1;
801039fd:	83 c4 10             	add    $0x10,%esp
80103a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a05:	eb db                	jmp    801039e2 <kill+0x51>

80103a07 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a07:	55                   	push   %ebp
80103a08:	89 e5                	mov    %esp,%ebp
80103a0a:	56                   	push   %esi
80103a0b:	53                   	push   %ebx
80103a0c:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a0f:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103a14:	eb 36                	jmp    80103a4c <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a16:	b8 b4 6e 10 80       	mov    $0x80106eb4,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a1b:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a1e:	52                   	push   %edx
80103a1f:	50                   	push   %eax
80103a20:	ff 73 10             	pushl  0x10(%ebx)
80103a23:	68 b8 6e 10 80       	push   $0x80106eb8
80103a28:	e8 de cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a2d:	83 c4 10             	add    $0x10,%esp
80103a30:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a34:	74 3c                	je     80103a72 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a36:	83 ec 0c             	sub    $0xc,%esp
80103a39:	68 42 6e 10 80       	push   $0x80106e42
80103a3e:	e8 c8 cb ff ff       	call   8010060b <cprintf>
80103a43:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a46:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103a4c:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103a52:	73 61                	jae    80103ab5 <procdump+0xae>
    if(p->state == UNUSED)
80103a54:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a57:	85 c0                	test   %eax,%eax
80103a59:	74 eb                	je     80103a46 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a5b:	83 f8 05             	cmp    $0x5,%eax
80103a5e:	77 b6                	ja     80103a16 <procdump+0xf>
80103a60:	8b 04 85 14 6f 10 80 	mov    -0x7fef90ec(,%eax,4),%eax
80103a67:	85 c0                	test   %eax,%eax
80103a69:	75 b0                	jne    80103a1b <procdump+0x14>
      state = "???";
80103a6b:	b8 b4 6e 10 80       	mov    $0x80106eb4,%eax
80103a70:	eb a9                	jmp    80103a1b <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a72:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a75:	8b 40 0c             	mov    0xc(%eax),%eax
80103a78:	83 c0 08             	add    $0x8,%eax
80103a7b:	83 ec 08             	sub    $0x8,%esp
80103a7e:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a81:	52                   	push   %edx
80103a82:	50                   	push   %eax
80103a83:	e8 cb 01 00 00       	call   80103c53 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a88:	83 c4 10             	add    $0x10,%esp
80103a8b:	be 00 00 00 00       	mov    $0x0,%esi
80103a90:	eb 14                	jmp    80103aa6 <procdump+0x9f>
        cprintf(" %p", pc[i]);
80103a92:	83 ec 08             	sub    $0x8,%esp
80103a95:	50                   	push   %eax
80103a96:	68 21 68 10 80       	push   $0x80106821
80103a9b:	e8 6b cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103aa0:	83 c6 01             	add    $0x1,%esi
80103aa3:	83 c4 10             	add    $0x10,%esp
80103aa6:	83 fe 09             	cmp    $0x9,%esi
80103aa9:	7f 8b                	jg     80103a36 <procdump+0x2f>
80103aab:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103aaf:	85 c0                	test   %eax,%eax
80103ab1:	75 df                	jne    80103a92 <procdump+0x8b>
80103ab3:	eb 81                	jmp    80103a36 <procdump+0x2f>
  }
}
80103ab5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ab8:	5b                   	pop    %ebx
80103ab9:	5e                   	pop    %esi
80103aba:	5d                   	pop    %ebp
80103abb:	c3                   	ret    

80103abc <getprocessesinfo_helper>:

int getprocessesinfo_helper(struct processes_info *my_process_info){
80103abc:	55                   	push   %ebp
80103abd:	89 e5                	mov    %esp,%ebp
80103abf:	53                   	push   %ebx
80103ac0:	83 ec 10             	sub    $0x10,%esp
80103ac3:	8b 5d 08             	mov    0x8(%ebp),%ebx

  struct proc *p;

  acquire(&ptable.lock);
80103ac6:	68 20 2d 11 80       	push   $0x80112d20
80103acb:	e8 a4 02 00 00       	call   80103d74 <acquire>
  int i = 0;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ad0:	83 c4 10             	add    $0x10,%esp
  int i = 0;
80103ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ad8:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103add:	eb 05                	jmp    80103ae4 <getprocessesinfo_helper+0x28>
80103adf:	05 84 00 00 00       	add    $0x84,%eax
80103ae4:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
80103ae9:	73 2b                	jae    80103b16 <getprocessesinfo_helper+0x5a>
    if(p->state != UNUSED){
80103aeb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
80103aef:	74 ee                	je     80103adf <getprocessesinfo_helper+0x23>
      //cprintf("PID %d has %d tickets! \n", p->pid, p->tickets);
      my_process_info->pids[i] = p->pid;
80103af1:	8b 48 10             	mov    0x10(%eax),%ecx
80103af4:	89 4c 93 04          	mov    %ecx,0x4(%ebx,%edx,4)
      my_process_info->tickets[i] = p->tickets;
80103af8:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80103afe:	89 8c 93 04 02 00 00 	mov    %ecx,0x204(%ebx,%edx,4)
      my_process_info->times_scheduled[i] = p->num_times_scheduled;
80103b05:	8b 48 7c             	mov    0x7c(%eax),%ecx
80103b08:	89 8c 93 04 01 00 00 	mov    %ecx,0x104(%ebx,%edx,4)
      my_process_info->num_processes = ++i;
80103b0f:	83 c2 01             	add    $0x1,%edx
80103b12:	89 13                	mov    %edx,(%ebx)
80103b14:	eb c9                	jmp    80103adf <getprocessesinfo_helper+0x23>

    }
    
  }
  
  release(&ptable.lock);
80103b16:	83 ec 0c             	sub    $0xc,%esp
80103b19:	68 20 2d 11 80       	push   $0x80112d20
80103b1e:	e8 b6 02 00 00       	call   80103dd9 <release>
  return 0;
}
80103b23:	b8 00 00 00 00       	mov    $0x0,%eax
80103b28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b2b:	c9                   	leave  
80103b2c:	c3                   	ret    

80103b2d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103b2d:	55                   	push   %ebp
80103b2e:	89 e5                	mov    %esp,%ebp
80103b30:	53                   	push   %ebx
80103b31:	83 ec 0c             	sub    $0xc,%esp
80103b34:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103b37:	68 2c 6f 10 80       	push   $0x80106f2c
80103b3c:	8d 43 04             	lea    0x4(%ebx),%eax
80103b3f:	50                   	push   %eax
80103b40:	e8 f3 00 00 00       	call   80103c38 <initlock>
  lk->name = name;
80103b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b48:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b4b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b51:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b58:	83 c4 10             	add    $0x10,%esp
80103b5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b5e:	c9                   	leave  
80103b5f:	c3                   	ret    

80103b60 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b60:	55                   	push   %ebp
80103b61:	89 e5                	mov    %esp,%ebp
80103b63:	56                   	push   %esi
80103b64:	53                   	push   %ebx
80103b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b68:	8d 73 04             	lea    0x4(%ebx),%esi
80103b6b:	83 ec 0c             	sub    $0xc,%esp
80103b6e:	56                   	push   %esi
80103b6f:	e8 00 02 00 00       	call   80103d74 <acquire>
  while (lk->locked) {
80103b74:	83 c4 10             	add    $0x10,%esp
80103b77:	eb 0d                	jmp    80103b86 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b79:	83 ec 08             	sub    $0x8,%esp
80103b7c:	56                   	push   %esi
80103b7d:	53                   	push   %ebx
80103b7e:	e8 7d fc ff ff       	call   80103800 <sleep>
80103b83:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b86:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b89:	75 ee                	jne    80103b79 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b8b:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b91:	e8 0d f7 ff ff       	call   801032a3 <myproc>
80103b96:	8b 40 10             	mov    0x10(%eax),%eax
80103b99:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b9c:	83 ec 0c             	sub    $0xc,%esp
80103b9f:	56                   	push   %esi
80103ba0:	e8 34 02 00 00       	call   80103dd9 <release>
}
80103ba5:	83 c4 10             	add    $0x10,%esp
80103ba8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bab:	5b                   	pop    %ebx
80103bac:	5e                   	pop    %esi
80103bad:	5d                   	pop    %ebp
80103bae:	c3                   	ret    

80103baf <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103baf:	55                   	push   %ebp
80103bb0:	89 e5                	mov    %esp,%ebp
80103bb2:	56                   	push   %esi
80103bb3:	53                   	push   %ebx
80103bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103bb7:	8d 73 04             	lea    0x4(%ebx),%esi
80103bba:	83 ec 0c             	sub    $0xc,%esp
80103bbd:	56                   	push   %esi
80103bbe:	e8 b1 01 00 00       	call   80103d74 <acquire>
  lk->locked = 0;
80103bc3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103bc9:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103bd0:	89 1c 24             	mov    %ebx,(%esp)
80103bd3:	e8 90 fd ff ff       	call   80103968 <wakeup>
  release(&lk->lk);
80103bd8:	89 34 24             	mov    %esi,(%esp)
80103bdb:	e8 f9 01 00 00       	call   80103dd9 <release>
}
80103be0:	83 c4 10             	add    $0x10,%esp
80103be3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103be6:	5b                   	pop    %ebx
80103be7:	5e                   	pop    %esi
80103be8:	5d                   	pop    %ebp
80103be9:	c3                   	ret    

80103bea <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bea:	55                   	push   %ebp
80103beb:	89 e5                	mov    %esp,%ebp
80103bed:	56                   	push   %esi
80103bee:	53                   	push   %ebx
80103bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103bf2:	8d 73 04             	lea    0x4(%ebx),%esi
80103bf5:	83 ec 0c             	sub    $0xc,%esp
80103bf8:	56                   	push   %esi
80103bf9:	e8 76 01 00 00       	call   80103d74 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bfe:	83 c4 10             	add    $0x10,%esp
80103c01:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c04:	75 17                	jne    80103c1d <holdingsleep+0x33>
80103c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103c0b:	83 ec 0c             	sub    $0xc,%esp
80103c0e:	56                   	push   %esi
80103c0f:	e8 c5 01 00 00       	call   80103dd9 <release>
  return r;
}
80103c14:	89 d8                	mov    %ebx,%eax
80103c16:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c19:	5b                   	pop    %ebx
80103c1a:	5e                   	pop    %esi
80103c1b:	5d                   	pop    %ebp
80103c1c:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103c1d:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103c20:	e8 7e f6 ff ff       	call   801032a3 <myproc>
80103c25:	3b 58 10             	cmp    0x10(%eax),%ebx
80103c28:	74 07                	je     80103c31 <holdingsleep+0x47>
80103c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c2f:	eb da                	jmp    80103c0b <holdingsleep+0x21>
80103c31:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c36:	eb d3                	jmp    80103c0b <holdingsleep+0x21>

80103c38 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103c38:	55                   	push   %ebp
80103c39:	89 e5                	mov    %esp,%ebp
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c41:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c4a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c51:	5d                   	pop    %ebp
80103c52:	c3                   	ret    

80103c53 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c53:	55                   	push   %ebp
80103c54:	89 e5                	mov    %esp,%ebp
80103c56:	53                   	push   %ebx
80103c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5d:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c60:	b8 00 00 00 00       	mov    $0x0,%eax
80103c65:	83 f8 09             	cmp    $0x9,%eax
80103c68:	7f 25                	jg     80103c8f <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c6a:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c70:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c76:	77 17                	ja     80103c8f <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c78:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c7b:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c7e:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c80:	83 c0 01             	add    $0x1,%eax
80103c83:	eb e0                	jmp    80103c65 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c85:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c8c:	83 c0 01             	add    $0x1,%eax
80103c8f:	83 f8 09             	cmp    $0x9,%eax
80103c92:	7e f1                	jle    80103c85 <getcallerpcs+0x32>
}
80103c94:	5b                   	pop    %ebx
80103c95:	5d                   	pop    %ebp
80103c96:	c3                   	ret    

80103c97 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	53                   	push   %ebx
80103c9b:	83 ec 04             	sub    $0x4,%esp
80103c9e:	9c                   	pushf  
80103c9f:	5b                   	pop    %ebx
  asm volatile("cli");
80103ca0:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103ca1:	e8 86 f5 ff ff       	call   8010322c <mycpu>
80103ca6:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cad:	74 12                	je     80103cc1 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103caf:	e8 78 f5 ff ff       	call   8010322c <mycpu>
80103cb4:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103cbb:	83 c4 04             	add    $0x4,%esp
80103cbe:	5b                   	pop    %ebx
80103cbf:	5d                   	pop    %ebp
80103cc0:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103cc1:	e8 66 f5 ff ff       	call   8010322c <mycpu>
80103cc6:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ccc:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103cd2:	eb db                	jmp    80103caf <pushcli+0x18>

80103cd4 <popcli>:

void
popcli(void)
{
80103cd4:	55                   	push   %ebp
80103cd5:	89 e5                	mov    %esp,%ebp
80103cd7:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cda:	9c                   	pushf  
80103cdb:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cdc:	f6 c4 02             	test   $0x2,%ah
80103cdf:	75 28                	jne    80103d09 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103ce1:	e8 46 f5 ff ff       	call   8010322c <mycpu>
80103ce6:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cec:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cef:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103cf5:	85 d2                	test   %edx,%edx
80103cf7:	78 1d                	js     80103d16 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cf9:	e8 2e f5 ff ff       	call   8010322c <mycpu>
80103cfe:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d05:	74 1c                	je     80103d23 <popcli+0x4f>
    sti();
}
80103d07:	c9                   	leave  
80103d08:	c3                   	ret    
    panic("popcli - interruptible");
80103d09:	83 ec 0c             	sub    $0xc,%esp
80103d0c:	68 37 6f 10 80       	push   $0x80106f37
80103d11:	e8 32 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103d16:	83 ec 0c             	sub    $0xc,%esp
80103d19:	68 4e 6f 10 80       	push   $0x80106f4e
80103d1e:	e8 25 c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d23:	e8 04 f5 ff ff       	call   8010322c <mycpu>
80103d28:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103d2f:	74 d6                	je     80103d07 <popcli+0x33>
  asm volatile("sti");
80103d31:	fb                   	sti    
}
80103d32:	eb d3                	jmp    80103d07 <popcli+0x33>

80103d34 <holding>:
{
80103d34:	55                   	push   %ebp
80103d35:	89 e5                	mov    %esp,%ebp
80103d37:	53                   	push   %ebx
80103d38:	83 ec 04             	sub    $0x4,%esp
80103d3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103d3e:	e8 54 ff ff ff       	call   80103c97 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d43:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d46:	75 12                	jne    80103d5a <holding+0x26>
80103d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d4d:	e8 82 ff ff ff       	call   80103cd4 <popcli>
}
80103d52:	89 d8                	mov    %ebx,%eax
80103d54:	83 c4 04             	add    $0x4,%esp
80103d57:	5b                   	pop    %ebx
80103d58:	5d                   	pop    %ebp
80103d59:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d5a:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d5d:	e8 ca f4 ff ff       	call   8010322c <mycpu>
80103d62:	39 c3                	cmp    %eax,%ebx
80103d64:	74 07                	je     80103d6d <holding+0x39>
80103d66:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d6b:	eb e0                	jmp    80103d4d <holding+0x19>
80103d6d:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d72:	eb d9                	jmp    80103d4d <holding+0x19>

80103d74 <acquire>:
{
80103d74:	55                   	push   %ebp
80103d75:	89 e5                	mov    %esp,%ebp
80103d77:	53                   	push   %ebx
80103d78:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d7b:	e8 17 ff ff ff       	call   80103c97 <pushcli>
  if(holding(lk))
80103d80:	83 ec 0c             	sub    $0xc,%esp
80103d83:	ff 75 08             	pushl  0x8(%ebp)
80103d86:	e8 a9 ff ff ff       	call   80103d34 <holding>
80103d8b:	83 c4 10             	add    $0x10,%esp
80103d8e:	85 c0                	test   %eax,%eax
80103d90:	75 3a                	jne    80103dcc <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d92:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d95:	b8 01 00 00 00       	mov    $0x1,%eax
80103d9a:	f0 87 02             	lock xchg %eax,(%edx)
80103d9d:	85 c0                	test   %eax,%eax
80103d9f:	75 f1                	jne    80103d92 <acquire+0x1e>
  __sync_synchronize();
80103da1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103da6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103da9:	e8 7e f4 ff ff       	call   8010322c <mycpu>
80103dae:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103db1:	8b 45 08             	mov    0x8(%ebp),%eax
80103db4:	83 c0 0c             	add    $0xc,%eax
80103db7:	83 ec 08             	sub    $0x8,%esp
80103dba:	50                   	push   %eax
80103dbb:	8d 45 08             	lea    0x8(%ebp),%eax
80103dbe:	50                   	push   %eax
80103dbf:	e8 8f fe ff ff       	call   80103c53 <getcallerpcs>
}
80103dc4:	83 c4 10             	add    $0x10,%esp
80103dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dca:	c9                   	leave  
80103dcb:	c3                   	ret    
    panic("acquire");
80103dcc:	83 ec 0c             	sub    $0xc,%esp
80103dcf:	68 55 6f 10 80       	push   $0x80106f55
80103dd4:	e8 6f c5 ff ff       	call   80100348 <panic>

80103dd9 <release>:
{
80103dd9:	55                   	push   %ebp
80103dda:	89 e5                	mov    %esp,%ebp
80103ddc:	53                   	push   %ebx
80103ddd:	83 ec 10             	sub    $0x10,%esp
80103de0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103de3:	53                   	push   %ebx
80103de4:	e8 4b ff ff ff       	call   80103d34 <holding>
80103de9:	83 c4 10             	add    $0x10,%esp
80103dec:	85 c0                	test   %eax,%eax
80103dee:	74 23                	je     80103e13 <release+0x3a>
  lk->pcs[0] = 0;
80103df0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103df7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dfe:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103e03:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103e09:	e8 c6 fe ff ff       	call   80103cd4 <popcli>
}
80103e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e11:	c9                   	leave  
80103e12:	c3                   	ret    
    panic("release");
80103e13:	83 ec 0c             	sub    $0xc,%esp
80103e16:	68 5d 6f 10 80       	push   $0x80106f5d
80103e1b:	e8 28 c5 ff ff       	call   80100348 <panic>

80103e20 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103e20:	55                   	push   %ebp
80103e21:	89 e5                	mov    %esp,%ebp
80103e23:	57                   	push   %edi
80103e24:	53                   	push   %ebx
80103e25:	8b 55 08             	mov    0x8(%ebp),%edx
80103e28:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103e2b:	f6 c2 03             	test   $0x3,%dl
80103e2e:	75 05                	jne    80103e35 <memset+0x15>
80103e30:	f6 c1 03             	test   $0x3,%cl
80103e33:	74 0e                	je     80103e43 <memset+0x23>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80103e35:	89 d7                	mov    %edx,%edi
80103e37:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e3a:	fc                   	cld    
80103e3b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103e3d:	89 d0                	mov    %edx,%eax
80103e3f:	5b                   	pop    %ebx
80103e40:	5f                   	pop    %edi
80103e41:	5d                   	pop    %ebp
80103e42:	c3                   	ret    
    c &= 0xFF;
80103e43:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e47:	c1 e9 02             	shr    $0x2,%ecx
80103e4a:	89 f8                	mov    %edi,%eax
80103e4c:	c1 e0 18             	shl    $0x18,%eax
80103e4f:	89 fb                	mov    %edi,%ebx
80103e51:	c1 e3 10             	shl    $0x10,%ebx
80103e54:	09 d8                	or     %ebx,%eax
80103e56:	89 fb                	mov    %edi,%ebx
80103e58:	c1 e3 08             	shl    $0x8,%ebx
80103e5b:	09 d8                	or     %ebx,%eax
80103e5d:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80103e5f:	89 d7                	mov    %edx,%edi
80103e61:	fc                   	cld    
80103e62:	f3 ab                	rep stos %eax,%es:(%edi)
80103e64:	eb d7                	jmp    80103e3d <memset+0x1d>

80103e66 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e66:	55                   	push   %ebp
80103e67:	89 e5                	mov    %esp,%ebp
80103e69:	56                   	push   %esi
80103e6a:	53                   	push   %ebx
80103e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e71:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e74:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e77:	85 c0                	test   %eax,%eax
80103e79:	74 1c                	je     80103e97 <memcmp+0x31>
    if(*s1 != *s2)
80103e7b:	0f b6 01             	movzbl (%ecx),%eax
80103e7e:	0f b6 1a             	movzbl (%edx),%ebx
80103e81:	38 d8                	cmp    %bl,%al
80103e83:	75 0a                	jne    80103e8f <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e85:	83 c1 01             	add    $0x1,%ecx
80103e88:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e8b:	89 f0                	mov    %esi,%eax
80103e8d:	eb e5                	jmp    80103e74 <memcmp+0xe>
      return *s1 - *s2;
80103e8f:	0f b6 c0             	movzbl %al,%eax
80103e92:	0f b6 db             	movzbl %bl,%ebx
80103e95:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e97:	5b                   	pop    %ebx
80103e98:	5e                   	pop    %esi
80103e99:	5d                   	pop    %ebp
80103e9a:	c3                   	ret    

80103e9b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e9b:	55                   	push   %ebp
80103e9c:	89 e5                	mov    %esp,%ebp
80103e9e:	56                   	push   %esi
80103e9f:	53                   	push   %ebx
80103ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ea6:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103ea9:	39 c1                	cmp    %eax,%ecx
80103eab:	73 3a                	jae    80103ee7 <memmove+0x4c>
80103ead:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103eb0:	39 c3                	cmp    %eax,%ebx
80103eb2:	76 37                	jbe    80103eeb <memmove+0x50>
    s += n;
    d += n;
80103eb4:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103eb7:	eb 0d                	jmp    80103ec6 <memmove+0x2b>
      *--d = *--s;
80103eb9:	83 eb 01             	sub    $0x1,%ebx
80103ebc:	83 e9 01             	sub    $0x1,%ecx
80103ebf:	0f b6 13             	movzbl (%ebx),%edx
80103ec2:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103ec4:	89 f2                	mov    %esi,%edx
80103ec6:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ec9:	85 d2                	test   %edx,%edx
80103ecb:	75 ec                	jne    80103eb9 <memmove+0x1e>
80103ecd:	eb 14                	jmp    80103ee3 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103ecf:	0f b6 11             	movzbl (%ecx),%edx
80103ed2:	88 13                	mov    %dl,(%ebx)
80103ed4:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103ed7:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103eda:	89 f2                	mov    %esi,%edx
80103edc:	8d 72 ff             	lea    -0x1(%edx),%esi
80103edf:	85 d2                	test   %edx,%edx
80103ee1:	75 ec                	jne    80103ecf <memmove+0x34>

  return dst;
}
80103ee3:	5b                   	pop    %ebx
80103ee4:	5e                   	pop    %esi
80103ee5:	5d                   	pop    %ebp
80103ee6:	c3                   	ret    
80103ee7:	89 c3                	mov    %eax,%ebx
80103ee9:	eb f1                	jmp    80103edc <memmove+0x41>
80103eeb:	89 c3                	mov    %eax,%ebx
80103eed:	eb ed                	jmp    80103edc <memmove+0x41>

80103eef <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103eef:	55                   	push   %ebp
80103ef0:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103ef2:	ff 75 10             	pushl  0x10(%ebp)
80103ef5:	ff 75 0c             	pushl  0xc(%ebp)
80103ef8:	ff 75 08             	pushl  0x8(%ebp)
80103efb:	e8 9b ff ff ff       	call   80103e9b <memmove>
}
80103f00:	c9                   	leave  
80103f01:	c3                   	ret    

80103f02 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103f02:	55                   	push   %ebp
80103f03:	89 e5                	mov    %esp,%ebp
80103f05:	53                   	push   %ebx
80103f06:	8b 55 08             	mov    0x8(%ebp),%edx
80103f09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f0c:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103f0f:	eb 09                	jmp    80103f1a <strncmp+0x18>
    n--, p++, q++;
80103f11:	83 e8 01             	sub    $0x1,%eax
80103f14:	83 c2 01             	add    $0x1,%edx
80103f17:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103f1a:	85 c0                	test   %eax,%eax
80103f1c:	74 0b                	je     80103f29 <strncmp+0x27>
80103f1e:	0f b6 1a             	movzbl (%edx),%ebx
80103f21:	84 db                	test   %bl,%bl
80103f23:	74 04                	je     80103f29 <strncmp+0x27>
80103f25:	3a 19                	cmp    (%ecx),%bl
80103f27:	74 e8                	je     80103f11 <strncmp+0xf>
  if(n == 0)
80103f29:	85 c0                	test   %eax,%eax
80103f2b:	74 0b                	je     80103f38 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103f2d:	0f b6 02             	movzbl (%edx),%eax
80103f30:	0f b6 11             	movzbl (%ecx),%edx
80103f33:	29 d0                	sub    %edx,%eax
}
80103f35:	5b                   	pop    %ebx
80103f36:	5d                   	pop    %ebp
80103f37:	c3                   	ret    
    return 0;
80103f38:	b8 00 00 00 00       	mov    $0x0,%eax
80103f3d:	eb f6                	jmp    80103f35 <strncmp+0x33>

80103f3f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f3f:	55                   	push   %ebp
80103f40:	89 e5                	mov    %esp,%ebp
80103f42:	57                   	push   %edi
80103f43:	56                   	push   %esi
80103f44:	53                   	push   %ebx
80103f45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f48:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4e:	eb 04                	jmp    80103f54 <strncpy+0x15>
80103f50:	89 fb                	mov    %edi,%ebx
80103f52:	89 f0                	mov    %esi,%eax
80103f54:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f57:	85 c9                	test   %ecx,%ecx
80103f59:	7e 1d                	jle    80103f78 <strncpy+0x39>
80103f5b:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f5e:	8d 70 01             	lea    0x1(%eax),%esi
80103f61:	0f b6 1b             	movzbl (%ebx),%ebx
80103f64:	88 18                	mov    %bl,(%eax)
80103f66:	89 d1                	mov    %edx,%ecx
80103f68:	84 db                	test   %bl,%bl
80103f6a:	75 e4                	jne    80103f50 <strncpy+0x11>
80103f6c:	89 f0                	mov    %esi,%eax
80103f6e:	eb 08                	jmp    80103f78 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f70:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f73:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f75:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f78:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f7b:	85 d2                	test   %edx,%edx
80103f7d:	7f f1                	jg     80103f70 <strncpy+0x31>
  return os;
}
80103f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f82:	5b                   	pop    %ebx
80103f83:	5e                   	pop    %esi
80103f84:	5f                   	pop    %edi
80103f85:	5d                   	pop    %ebp
80103f86:	c3                   	ret    

80103f87 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f87:	55                   	push   %ebp
80103f88:	89 e5                	mov    %esp,%ebp
80103f8a:	57                   	push   %edi
80103f8b:	56                   	push   %esi
80103f8c:	53                   	push   %ebx
80103f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f93:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f96:	85 d2                	test   %edx,%edx
80103f98:	7e 23                	jle    80103fbd <safestrcpy+0x36>
80103f9a:	89 c1                	mov    %eax,%ecx
80103f9c:	eb 04                	jmp    80103fa2 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f9e:	89 fb                	mov    %edi,%ebx
80103fa0:	89 f1                	mov    %esi,%ecx
80103fa2:	83 ea 01             	sub    $0x1,%edx
80103fa5:	85 d2                	test   %edx,%edx
80103fa7:	7e 11                	jle    80103fba <safestrcpy+0x33>
80103fa9:	8d 7b 01             	lea    0x1(%ebx),%edi
80103fac:	8d 71 01             	lea    0x1(%ecx),%esi
80103faf:	0f b6 1b             	movzbl (%ebx),%ebx
80103fb2:	88 19                	mov    %bl,(%ecx)
80103fb4:	84 db                	test   %bl,%bl
80103fb6:	75 e6                	jne    80103f9e <safestrcpy+0x17>
80103fb8:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103fba:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103fbd:	5b                   	pop    %ebx
80103fbe:	5e                   	pop    %esi
80103fbf:	5f                   	pop    %edi
80103fc0:	5d                   	pop    %ebp
80103fc1:	c3                   	ret    

80103fc2 <strlen>:

int
strlen(const char *s)
{
80103fc2:	55                   	push   %ebp
80103fc3:	89 e5                	mov    %esp,%ebp
80103fc5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103fc8:	b8 00 00 00 00       	mov    $0x0,%eax
80103fcd:	eb 03                	jmp    80103fd2 <strlen+0x10>
80103fcf:	83 c0 01             	add    $0x1,%eax
80103fd2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103fd6:	75 f7                	jne    80103fcf <strlen+0xd>
    ;
  return n;
}
80103fd8:	5d                   	pop    %ebp
80103fd9:	c3                   	ret    

80103fda <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103fda:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103fde:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fe2:	55                   	push   %ebp
  pushl %ebx
80103fe3:	53                   	push   %ebx
  pushl %esi
80103fe4:	56                   	push   %esi
  pushl %edi
80103fe5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fe6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fe8:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fea:	5f                   	pop    %edi
  popl %esi
80103feb:	5e                   	pop    %esi
  popl %ebx
80103fec:	5b                   	pop    %ebx
  popl %ebp
80103fed:	5d                   	pop    %ebp
  ret
80103fee:	c3                   	ret    

80103fef <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fef:	55                   	push   %ebp
80103ff0:	89 e5                	mov    %esp,%ebp
80103ff2:	53                   	push   %ebx
80103ff3:	83 ec 04             	sub    $0x4,%esp
80103ff6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ff9:	e8 a5 f2 ff ff       	call   801032a3 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103ffe:	8b 00                	mov    (%eax),%eax
80104000:	39 d8                	cmp    %ebx,%eax
80104002:	76 19                	jbe    8010401d <fetchint+0x2e>
80104004:	8d 53 04             	lea    0x4(%ebx),%edx
80104007:	39 d0                	cmp    %edx,%eax
80104009:	72 19                	jb     80104024 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
8010400b:	8b 13                	mov    (%ebx),%edx
8010400d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104010:	89 10                	mov    %edx,(%eax)
  return 0;
80104012:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104017:	83 c4 04             	add    $0x4,%esp
8010401a:	5b                   	pop    %ebx
8010401b:	5d                   	pop    %ebp
8010401c:	c3                   	ret    
    return -1;
8010401d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104022:	eb f3                	jmp    80104017 <fetchint+0x28>
80104024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104029:	eb ec                	jmp    80104017 <fetchint+0x28>

8010402b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010402b:	55                   	push   %ebp
8010402c:	89 e5                	mov    %esp,%ebp
8010402e:	53                   	push   %ebx
8010402f:	83 ec 04             	sub    $0x4,%esp
80104032:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104035:	e8 69 f2 ff ff       	call   801032a3 <myproc>

  if(addr >= curproc->sz)
8010403a:	39 18                	cmp    %ebx,(%eax)
8010403c:	76 26                	jbe    80104064 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
8010403e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104041:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104043:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104045:	89 d8                	mov    %ebx,%eax
80104047:	39 d0                	cmp    %edx,%eax
80104049:	73 0e                	jae    80104059 <fetchstr+0x2e>
    if(*s == 0)
8010404b:	80 38 00             	cmpb   $0x0,(%eax)
8010404e:	74 05                	je     80104055 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104050:	83 c0 01             	add    $0x1,%eax
80104053:	eb f2                	jmp    80104047 <fetchstr+0x1c>
      return s - *pp;
80104055:	29 d8                	sub    %ebx,%eax
80104057:	eb 05                	jmp    8010405e <fetchstr+0x33>
  }
  return -1;
80104059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010405e:	83 c4 04             	add    $0x4,%esp
80104061:	5b                   	pop    %ebx
80104062:	5d                   	pop    %ebp
80104063:	c3                   	ret    
    return -1;
80104064:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104069:	eb f3                	jmp    8010405e <fetchstr+0x33>

8010406b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010406b:	55                   	push   %ebp
8010406c:	89 e5                	mov    %esp,%ebp
8010406e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104071:	e8 2d f2 ff ff       	call   801032a3 <myproc>
80104076:	8b 50 18             	mov    0x18(%eax),%edx
80104079:	8b 45 08             	mov    0x8(%ebp),%eax
8010407c:	c1 e0 02             	shl    $0x2,%eax
8010407f:	03 42 44             	add    0x44(%edx),%eax
80104082:	83 ec 08             	sub    $0x8,%esp
80104085:	ff 75 0c             	pushl  0xc(%ebp)
80104088:	83 c0 04             	add    $0x4,%eax
8010408b:	50                   	push   %eax
8010408c:	e8 5e ff ff ff       	call   80103fef <fetchint>
}
80104091:	c9                   	leave  
80104092:	c3                   	ret    

80104093 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104093:	55                   	push   %ebp
80104094:	89 e5                	mov    %esp,%ebp
80104096:	56                   	push   %esi
80104097:	53                   	push   %ebx
80104098:	83 ec 10             	sub    $0x10,%esp
8010409b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010409e:	e8 00 f2 ff ff       	call   801032a3 <myproc>
801040a3:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801040a5:	83 ec 08             	sub    $0x8,%esp
801040a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040ab:	50                   	push   %eax
801040ac:	ff 75 08             	pushl  0x8(%ebp)
801040af:	e8 b7 ff ff ff       	call   8010406b <argint>
801040b4:	83 c4 10             	add    $0x10,%esp
801040b7:	85 c0                	test   %eax,%eax
801040b9:	78 24                	js     801040df <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801040bb:	85 db                	test   %ebx,%ebx
801040bd:	78 27                	js     801040e6 <argptr+0x53>
801040bf:	8b 16                	mov    (%esi),%edx
801040c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c4:	39 c2                	cmp    %eax,%edx
801040c6:	76 25                	jbe    801040ed <argptr+0x5a>
801040c8:	01 c3                	add    %eax,%ebx
801040ca:	39 da                	cmp    %ebx,%edx
801040cc:	72 26                	jb     801040f4 <argptr+0x61>
    return -1;
  *pp = (char*)i;
801040ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801040d1:	89 02                	mov    %eax,(%edx)
  return 0;
801040d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040db:	5b                   	pop    %ebx
801040dc:	5e                   	pop    %esi
801040dd:	5d                   	pop    %ebp
801040de:	c3                   	ret    
    return -1;
801040df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e4:	eb f2                	jmp    801040d8 <argptr+0x45>
    return -1;
801040e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040eb:	eb eb                	jmp    801040d8 <argptr+0x45>
801040ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f2:	eb e4                	jmp    801040d8 <argptr+0x45>
801040f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f9:	eb dd                	jmp    801040d8 <argptr+0x45>

801040fb <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040fb:	55                   	push   %ebp
801040fc:	89 e5                	mov    %esp,%ebp
801040fe:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104101:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104104:	50                   	push   %eax
80104105:	ff 75 08             	pushl  0x8(%ebp)
80104108:	e8 5e ff ff ff       	call   8010406b <argint>
8010410d:	83 c4 10             	add    $0x10,%esp
80104110:	85 c0                	test   %eax,%eax
80104112:	78 13                	js     80104127 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104114:	83 ec 08             	sub    $0x8,%esp
80104117:	ff 75 0c             	pushl  0xc(%ebp)
8010411a:	ff 75 f4             	pushl  -0xc(%ebp)
8010411d:	e8 09 ff ff ff       	call   8010402b <fetchstr>
80104122:	83 c4 10             	add    $0x10,%esp
}
80104125:	c9                   	leave  
80104126:	c3                   	ret    
    return -1;
80104127:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010412c:	eb f7                	jmp    80104125 <argstr+0x2a>

8010412e <syscall>:
[SYS_getprocessesinfo] sys_getprocessesinfo,
};

void
syscall(void)
{
8010412e:	55                   	push   %ebp
8010412f:	89 e5                	mov    %esp,%ebp
80104131:	53                   	push   %ebx
80104132:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104135:	e8 69 f1 ff ff       	call   801032a3 <myproc>
8010413a:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010413c:	8b 40 18             	mov    0x18(%eax),%eax
8010413f:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104142:	8d 50 ff             	lea    -0x1(%eax),%edx
80104145:	83 fa 1a             	cmp    $0x1a,%edx
80104148:	77 18                	ja     80104162 <syscall+0x34>
8010414a:	8b 14 85 a0 6f 10 80 	mov    -0x7fef9060(,%eax,4),%edx
80104151:	85 d2                	test   %edx,%edx
80104153:	74 0d                	je     80104162 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104155:	ff d2                	call   *%edx
80104157:	8b 53 18             	mov    0x18(%ebx),%edx
8010415a:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010415d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104160:	c9                   	leave  
80104161:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104162:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104165:	50                   	push   %eax
80104166:	52                   	push   %edx
80104167:	ff 73 10             	pushl  0x10(%ebx)
8010416a:	68 65 6f 10 80       	push   $0x80106f65
8010416f:	e8 97 c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104174:	8b 43 18             	mov    0x18(%ebx),%eax
80104177:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010417e:	83 c4 10             	add    $0x10,%esp
}
80104181:	eb da                	jmp    8010415d <syscall+0x2f>

80104183 <argfd>:
uint writeCount_global;
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104183:	55                   	push   %ebp
80104184:	89 e5                	mov    %esp,%ebp
80104186:	56                   	push   %esi
80104187:	53                   	push   %ebx
80104188:	83 ec 18             	sub    $0x18,%esp
8010418b:	89 d6                	mov    %edx,%esi
8010418d:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010418f:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104192:	52                   	push   %edx
80104193:	50                   	push   %eax
80104194:	e8 d2 fe ff ff       	call   8010406b <argint>
80104199:	83 c4 10             	add    $0x10,%esp
8010419c:	85 c0                	test   %eax,%eax
8010419e:	78 2e                	js     801041ce <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801041a0:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801041a4:	77 2f                	ja     801041d5 <argfd+0x52>
801041a6:	e8 f8 f0 ff ff       	call   801032a3 <myproc>
801041ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ae:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801041b2:	85 c0                	test   %eax,%eax
801041b4:	74 26                	je     801041dc <argfd+0x59>
    return -1;
  if(pfd)
801041b6:	85 f6                	test   %esi,%esi
801041b8:	74 02                	je     801041bc <argfd+0x39>
    *pfd = fd;
801041ba:	89 16                	mov    %edx,(%esi)
  if(pf)
801041bc:	85 db                	test   %ebx,%ebx
801041be:	74 23                	je     801041e3 <argfd+0x60>
    *pf = f;
801041c0:	89 03                	mov    %eax,(%ebx)
  return 0;
801041c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041ca:	5b                   	pop    %ebx
801041cb:	5e                   	pop    %esi
801041cc:	5d                   	pop    %ebp
801041cd:	c3                   	ret    
    return -1;
801041ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041d3:	eb f2                	jmp    801041c7 <argfd+0x44>
    return -1;
801041d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041da:	eb eb                	jmp    801041c7 <argfd+0x44>
801041dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e1:	eb e4                	jmp    801041c7 <argfd+0x44>
  return 0;
801041e3:	b8 00 00 00 00       	mov    $0x0,%eax
801041e8:	eb dd                	jmp    801041c7 <argfd+0x44>

801041ea <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041ea:	55                   	push   %ebp
801041eb:	89 e5                	mov    %esp,%ebp
801041ed:	53                   	push   %ebx
801041ee:	83 ec 04             	sub    $0x4,%esp
801041f1:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041f3:	e8 ab f0 ff ff       	call   801032a3 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041f8:	ba 00 00 00 00       	mov    $0x0,%edx
801041fd:	83 fa 0f             	cmp    $0xf,%edx
80104200:	7f 18                	jg     8010421a <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
80104202:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104207:	74 05                	je     8010420e <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104209:	83 c2 01             	add    $0x1,%edx
8010420c:	eb ef                	jmp    801041fd <fdalloc+0x13>
      curproc->ofile[fd] = f;
8010420e:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
80104212:	89 d0                	mov    %edx,%eax
80104214:	83 c4 04             	add    $0x4,%esp
80104217:	5b                   	pop    %ebx
80104218:	5d                   	pop    %ebp
80104219:	c3                   	ret    
  return -1;
8010421a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010421f:	eb f1                	jmp    80104212 <fdalloc+0x28>

80104221 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104221:	55                   	push   %ebp
80104222:	89 e5                	mov    %esp,%ebp
80104224:	56                   	push   %esi
80104225:	53                   	push   %ebx
80104226:	83 ec 10             	sub    $0x10,%esp
80104229:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010422b:	b8 20 00 00 00       	mov    $0x20,%eax
80104230:	89 c6                	mov    %eax,%esi
80104232:	39 43 58             	cmp    %eax,0x58(%ebx)
80104235:	76 2e                	jbe    80104265 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104237:	6a 10                	push   $0x10
80104239:	50                   	push   %eax
8010423a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010423d:	50                   	push   %eax
8010423e:	53                   	push   %ebx
8010423f:	e8 1d d5 ff ff       	call   80101761 <readi>
80104244:	83 c4 10             	add    $0x10,%esp
80104247:	83 f8 10             	cmp    $0x10,%eax
8010424a:	75 0c                	jne    80104258 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010424c:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104251:	75 1e                	jne    80104271 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104253:	8d 46 10             	lea    0x10(%esi),%eax
80104256:	eb d8                	jmp    80104230 <isdirempty+0xf>
      panic("isdirempty: readi");
80104258:	83 ec 0c             	sub    $0xc,%esp
8010425b:	68 10 70 10 80       	push   $0x80107010
80104260:	e8 e3 c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104265:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010426a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010426d:	5b                   	pop    %ebx
8010426e:	5e                   	pop    %esi
8010426f:	5d                   	pop    %ebp
80104270:	c3                   	ret    
      return 0;
80104271:	b8 00 00 00 00       	mov    $0x0,%eax
80104276:	eb f2                	jmp    8010426a <isdirempty+0x49>

80104278 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104278:	55                   	push   %ebp
80104279:	89 e5                	mov    %esp,%ebp
8010427b:	57                   	push   %edi
8010427c:	56                   	push   %esi
8010427d:	53                   	push   %ebx
8010427e:	83 ec 34             	sub    $0x34,%esp
80104281:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104284:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104287:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010428a:	8d 55 da             	lea    -0x26(%ebp),%edx
8010428d:	52                   	push   %edx
8010428e:	50                   	push   %eax
8010428f:	e8 53 d9 ff ff       	call   80101be7 <nameiparent>
80104294:	89 c6                	mov    %eax,%esi
80104296:	83 c4 10             	add    $0x10,%esp
80104299:	85 c0                	test   %eax,%eax
8010429b:	0f 84 38 01 00 00    	je     801043d9 <create+0x161>
    return 0;
  ilock(dp);
801042a1:	83 ec 0c             	sub    $0xc,%esp
801042a4:	50                   	push   %eax
801042a5:	e8 c5 d2 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801042aa:	83 c4 0c             	add    $0xc,%esp
801042ad:	6a 00                	push   $0x0
801042af:	8d 45 da             	lea    -0x26(%ebp),%eax
801042b2:	50                   	push   %eax
801042b3:	56                   	push   %esi
801042b4:	e8 e5 d6 ff ff       	call   8010199e <dirlookup>
801042b9:	89 c3                	mov    %eax,%ebx
801042bb:	83 c4 10             	add    $0x10,%esp
801042be:	85 c0                	test   %eax,%eax
801042c0:	74 3f                	je     80104301 <create+0x89>
    iunlockput(dp);
801042c2:	83 ec 0c             	sub    $0xc,%esp
801042c5:	56                   	push   %esi
801042c6:	e8 4b d4 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
801042cb:	89 1c 24             	mov    %ebx,(%esp)
801042ce:	e8 9c d2 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042d3:	83 c4 10             	add    $0x10,%esp
801042d6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801042db:	75 11                	jne    801042ee <create+0x76>
801042dd:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042e2:	75 0a                	jne    801042ee <create+0x76>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042e4:	89 d8                	mov    %ebx,%eax
801042e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042e9:	5b                   	pop    %ebx
801042ea:	5e                   	pop    %esi
801042eb:	5f                   	pop    %edi
801042ec:	5d                   	pop    %ebp
801042ed:	c3                   	ret    
    iunlockput(ip);
801042ee:	83 ec 0c             	sub    $0xc,%esp
801042f1:	53                   	push   %ebx
801042f2:	e8 1f d4 ff ff       	call   80101716 <iunlockput>
    return 0;
801042f7:	83 c4 10             	add    $0x10,%esp
801042fa:	bb 00 00 00 00       	mov    $0x0,%ebx
801042ff:	eb e3                	jmp    801042e4 <create+0x6c>
  if((ip = ialloc(dp->dev, type)) == 0)
80104301:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104305:	83 ec 08             	sub    $0x8,%esp
80104308:	50                   	push   %eax
80104309:	ff 36                	pushl  (%esi)
8010430b:	e8 5c d0 ff ff       	call   8010136c <ialloc>
80104310:	89 c3                	mov    %eax,%ebx
80104312:	83 c4 10             	add    $0x10,%esp
80104315:	85 c0                	test   %eax,%eax
80104317:	74 55                	je     8010436e <create+0xf6>
  ilock(ip);
80104319:	83 ec 0c             	sub    $0xc,%esp
8010431c:	50                   	push   %eax
8010431d:	e8 4d d2 ff ff       	call   8010156f <ilock>
  ip->major = major;
80104322:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104326:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010432a:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010432e:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104334:	89 1c 24             	mov    %ebx,(%esp)
80104337:	e8 d2 d0 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010433c:	83 c4 10             	add    $0x10,%esp
8010433f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104344:	74 35                	je     8010437b <create+0x103>
  if(dirlink(dp, name, ip->inum) < 0)
80104346:	83 ec 04             	sub    $0x4,%esp
80104349:	ff 73 04             	pushl  0x4(%ebx)
8010434c:	8d 45 da             	lea    -0x26(%ebp),%eax
8010434f:	50                   	push   %eax
80104350:	56                   	push   %esi
80104351:	e8 c8 d7 ff ff       	call   80101b1e <dirlink>
80104356:	83 c4 10             	add    $0x10,%esp
80104359:	85 c0                	test   %eax,%eax
8010435b:	78 6f                	js     801043cc <create+0x154>
  iunlockput(dp);
8010435d:	83 ec 0c             	sub    $0xc,%esp
80104360:	56                   	push   %esi
80104361:	e8 b0 d3 ff ff       	call   80101716 <iunlockput>
  return ip;
80104366:	83 c4 10             	add    $0x10,%esp
80104369:	e9 76 ff ff ff       	jmp    801042e4 <create+0x6c>
    panic("create: ialloc");
8010436e:	83 ec 0c             	sub    $0xc,%esp
80104371:	68 22 70 10 80       	push   $0x80107022
80104376:	e8 cd bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010437b:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010437f:	83 c0 01             	add    $0x1,%eax
80104382:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104386:	83 ec 0c             	sub    $0xc,%esp
80104389:	56                   	push   %esi
8010438a:	e8 7f d0 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010438f:	83 c4 0c             	add    $0xc,%esp
80104392:	ff 73 04             	pushl  0x4(%ebx)
80104395:	68 32 70 10 80       	push   $0x80107032
8010439a:	53                   	push   %ebx
8010439b:	e8 7e d7 ff ff       	call   80101b1e <dirlink>
801043a0:	83 c4 10             	add    $0x10,%esp
801043a3:	85 c0                	test   %eax,%eax
801043a5:	78 18                	js     801043bf <create+0x147>
801043a7:	83 ec 04             	sub    $0x4,%esp
801043aa:	ff 76 04             	pushl  0x4(%esi)
801043ad:	68 31 70 10 80       	push   $0x80107031
801043b2:	53                   	push   %ebx
801043b3:	e8 66 d7 ff ff       	call   80101b1e <dirlink>
801043b8:	83 c4 10             	add    $0x10,%esp
801043bb:	85 c0                	test   %eax,%eax
801043bd:	79 87                	jns    80104346 <create+0xce>
      panic("create dots");
801043bf:	83 ec 0c             	sub    $0xc,%esp
801043c2:	68 34 70 10 80       	push   $0x80107034
801043c7:	e8 7c bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801043cc:	83 ec 0c             	sub    $0xc,%esp
801043cf:	68 40 70 10 80       	push   $0x80107040
801043d4:	e8 6f bf ff ff       	call   80100348 <panic>
    return 0;
801043d9:	89 c3                	mov    %eax,%ebx
801043db:	e9 04 ff ff ff       	jmp    801042e4 <create+0x6c>

801043e0 <sys_dup>:
{
801043e0:	55                   	push   %ebp
801043e1:	89 e5                	mov    %esp,%ebp
801043e3:	53                   	push   %ebx
801043e4:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043e7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043ea:	ba 00 00 00 00       	mov    $0x0,%edx
801043ef:	b8 00 00 00 00       	mov    $0x0,%eax
801043f4:	e8 8a fd ff ff       	call   80104183 <argfd>
801043f9:	85 c0                	test   %eax,%eax
801043fb:	78 23                	js     80104420 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104400:	e8 e5 fd ff ff       	call   801041ea <fdalloc>
80104405:	89 c3                	mov    %eax,%ebx
80104407:	85 c0                	test   %eax,%eax
80104409:	78 1c                	js     80104427 <sys_dup+0x47>
  filedup(f);
8010440b:	83 ec 0c             	sub    $0xc,%esp
8010440e:	ff 75 f4             	pushl  -0xc(%ebp)
80104411:	e8 78 c8 ff ff       	call   80100c8e <filedup>
  return fd;
80104416:	83 c4 10             	add    $0x10,%esp
}
80104419:	89 d8                	mov    %ebx,%eax
8010441b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010441e:	c9                   	leave  
8010441f:	c3                   	ret    
    return -1;
80104420:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104425:	eb f2                	jmp    80104419 <sys_dup+0x39>
    return -1;
80104427:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010442c:	eb eb                	jmp    80104419 <sys_dup+0x39>

8010442e <sys_read>:
{
8010442e:	55                   	push   %ebp
8010442f:	89 e5                	mov    %esp,%ebp
80104431:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104434:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104437:	ba 00 00 00 00       	mov    $0x0,%edx
8010443c:	b8 00 00 00 00       	mov    $0x0,%eax
80104441:	e8 3d fd ff ff       	call   80104183 <argfd>
80104446:	85 c0                	test   %eax,%eax
80104448:	78 43                	js     8010448d <sys_read+0x5f>
8010444a:	83 ec 08             	sub    $0x8,%esp
8010444d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104450:	50                   	push   %eax
80104451:	6a 02                	push   $0x2
80104453:	e8 13 fc ff ff       	call   8010406b <argint>
80104458:	83 c4 10             	add    $0x10,%esp
8010445b:	85 c0                	test   %eax,%eax
8010445d:	78 35                	js     80104494 <sys_read+0x66>
8010445f:	83 ec 04             	sub    $0x4,%esp
80104462:	ff 75 f0             	pushl  -0x10(%ebp)
80104465:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104468:	50                   	push   %eax
80104469:	6a 01                	push   $0x1
8010446b:	e8 23 fc ff ff       	call   80104093 <argptr>
80104470:	83 c4 10             	add    $0x10,%esp
80104473:	85 c0                	test   %eax,%eax
80104475:	78 24                	js     8010449b <sys_read+0x6d>
  return fileread(f, p, n);
80104477:	83 ec 04             	sub    $0x4,%esp
8010447a:	ff 75 f0             	pushl  -0x10(%ebp)
8010447d:	ff 75 ec             	pushl  -0x14(%ebp)
80104480:	ff 75 f4             	pushl  -0xc(%ebp)
80104483:	e8 4f c9 ff ff       	call   80100dd7 <fileread>
80104488:	83 c4 10             	add    $0x10,%esp
}
8010448b:	c9                   	leave  
8010448c:	c3                   	ret    
    return -1;
8010448d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104492:	eb f7                	jmp    8010448b <sys_read+0x5d>
80104494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104499:	eb f0                	jmp    8010448b <sys_read+0x5d>
8010449b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044a0:	eb e9                	jmp    8010448b <sys_read+0x5d>

801044a2 <sys_write>:
{
801044a2:	55                   	push   %ebp
801044a3:	89 e5                	mov    %esp,%ebp
801044a5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044a8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044ab:	ba 00 00 00 00       	mov    $0x0,%edx
801044b0:	b8 00 00 00 00       	mov    $0x0,%eax
801044b5:	e8 c9 fc ff ff       	call   80104183 <argfd>
801044ba:	85 c0                	test   %eax,%eax
801044bc:	78 4a                	js     80104508 <sys_write+0x66>
801044be:	83 ec 08             	sub    $0x8,%esp
801044c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044c4:	50                   	push   %eax
801044c5:	6a 02                	push   $0x2
801044c7:	e8 9f fb ff ff       	call   8010406b <argint>
801044cc:	83 c4 10             	add    $0x10,%esp
801044cf:	85 c0                	test   %eax,%eax
801044d1:	78 3c                	js     8010450f <sys_write+0x6d>
801044d3:	83 ec 04             	sub    $0x4,%esp
801044d6:	ff 75 f0             	pushl  -0x10(%ebp)
801044d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044dc:	50                   	push   %eax
801044dd:	6a 01                	push   $0x1
801044df:	e8 af fb ff ff       	call   80104093 <argptr>
801044e4:	83 c4 10             	add    $0x10,%esp
801044e7:	85 c0                	test   %eax,%eax
801044e9:	78 2b                	js     80104516 <sys_write+0x74>
      writeCount_global++;
801044eb:	83 05 54 4e 11 80 01 	addl   $0x1,0x80114e54
  return filewrite(f, p, n);
801044f2:	83 ec 04             	sub    $0x4,%esp
801044f5:	ff 75 f0             	pushl  -0x10(%ebp)
801044f8:	ff 75 ec             	pushl  -0x14(%ebp)
801044fb:	ff 75 f4             	pushl  -0xc(%ebp)
801044fe:	e8 59 c9 ff ff       	call   80100e5c <filewrite>
80104503:	83 c4 10             	add    $0x10,%esp
}
80104506:	c9                   	leave  
80104507:	c3                   	ret    
    return -1;
80104508:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010450d:	eb f7                	jmp    80104506 <sys_write+0x64>
8010450f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104514:	eb f0                	jmp    80104506 <sys_write+0x64>
80104516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010451b:	eb e9                	jmp    80104506 <sys_write+0x64>

8010451d <sys_close>:
{
8010451d:	55                   	push   %ebp
8010451e:	89 e5                	mov    %esp,%ebp
80104520:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104523:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104526:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104529:	b8 00 00 00 00       	mov    $0x0,%eax
8010452e:	e8 50 fc ff ff       	call   80104183 <argfd>
80104533:	85 c0                	test   %eax,%eax
80104535:	78 25                	js     8010455c <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104537:	e8 67 ed ff ff       	call   801032a3 <myproc>
8010453c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453f:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104546:	00 
  fileclose(f);
80104547:	83 ec 0c             	sub    $0xc,%esp
8010454a:	ff 75 f0             	pushl  -0x10(%ebp)
8010454d:	e8 81 c7 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104552:	83 c4 10             	add    $0x10,%esp
80104555:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010455a:	c9                   	leave  
8010455b:	c3                   	ret    
    return -1;
8010455c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104561:	eb f7                	jmp    8010455a <sys_close+0x3d>

80104563 <sys_fstat>:
{
80104563:	55                   	push   %ebp
80104564:	89 e5                	mov    %esp,%ebp
80104566:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104569:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010456c:	ba 00 00 00 00       	mov    $0x0,%edx
80104571:	b8 00 00 00 00       	mov    $0x0,%eax
80104576:	e8 08 fc ff ff       	call   80104183 <argfd>
8010457b:	85 c0                	test   %eax,%eax
8010457d:	78 2a                	js     801045a9 <sys_fstat+0x46>
8010457f:	83 ec 04             	sub    $0x4,%esp
80104582:	6a 14                	push   $0x14
80104584:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104587:	50                   	push   %eax
80104588:	6a 01                	push   $0x1
8010458a:	e8 04 fb ff ff       	call   80104093 <argptr>
8010458f:	83 c4 10             	add    $0x10,%esp
80104592:	85 c0                	test   %eax,%eax
80104594:	78 1a                	js     801045b0 <sys_fstat+0x4d>
  return filestat(f, st);
80104596:	83 ec 08             	sub    $0x8,%esp
80104599:	ff 75 f0             	pushl  -0x10(%ebp)
8010459c:	ff 75 f4             	pushl  -0xc(%ebp)
8010459f:	e8 ec c7 ff ff       	call   80100d90 <filestat>
801045a4:	83 c4 10             	add    $0x10,%esp
}
801045a7:	c9                   	leave  
801045a8:	c3                   	ret    
    return -1;
801045a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ae:	eb f7                	jmp    801045a7 <sys_fstat+0x44>
801045b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b5:	eb f0                	jmp    801045a7 <sys_fstat+0x44>

801045b7 <sys_link>:
{
801045b7:	55                   	push   %ebp
801045b8:	89 e5                	mov    %esp,%ebp
801045ba:	56                   	push   %esi
801045bb:	53                   	push   %ebx
801045bc:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801045bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801045c2:	50                   	push   %eax
801045c3:	6a 00                	push   $0x0
801045c5:	e8 31 fb ff ff       	call   801040fb <argstr>
801045ca:	83 c4 10             	add    $0x10,%esp
801045cd:	85 c0                	test   %eax,%eax
801045cf:	0f 88 32 01 00 00    	js     80104707 <sys_link+0x150>
801045d5:	83 ec 08             	sub    $0x8,%esp
801045d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045db:	50                   	push   %eax
801045dc:	6a 01                	push   $0x1
801045de:	e8 18 fb ff ff       	call   801040fb <argstr>
801045e3:	83 c4 10             	add    $0x10,%esp
801045e6:	85 c0                	test   %eax,%eax
801045e8:	0f 88 20 01 00 00    	js     8010470e <sys_link+0x157>
  begin_op();
801045ee:	e8 df e1 ff ff       	call   801027d2 <begin_op>
  if((ip = namei(old)) == 0){
801045f3:	83 ec 0c             	sub    $0xc,%esp
801045f6:	ff 75 e0             	pushl  -0x20(%ebp)
801045f9:	e8 d1 d5 ff ff       	call   80101bcf <namei>
801045fe:	89 c3                	mov    %eax,%ebx
80104600:	83 c4 10             	add    $0x10,%esp
80104603:	85 c0                	test   %eax,%eax
80104605:	0f 84 99 00 00 00    	je     801046a4 <sys_link+0xed>
  ilock(ip);
8010460b:	83 ec 0c             	sub    $0xc,%esp
8010460e:	50                   	push   %eax
8010460f:	e8 5b cf ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
80104614:	83 c4 10             	add    $0x10,%esp
80104617:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010461c:	0f 84 8e 00 00 00    	je     801046b0 <sys_link+0xf9>
  ip->nlink++;
80104622:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104626:	83 c0 01             	add    $0x1,%eax
80104629:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010462d:	83 ec 0c             	sub    $0xc,%esp
80104630:	53                   	push   %ebx
80104631:	e8 d8 cd ff ff       	call   8010140e <iupdate>
  iunlock(ip);
80104636:	89 1c 24             	mov    %ebx,(%esp)
80104639:	e8 f3 cf ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
8010463e:	83 c4 08             	add    $0x8,%esp
80104641:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104644:	50                   	push   %eax
80104645:	ff 75 e4             	pushl  -0x1c(%ebp)
80104648:	e8 9a d5 ff ff       	call   80101be7 <nameiparent>
8010464d:	89 c6                	mov    %eax,%esi
8010464f:	83 c4 10             	add    $0x10,%esp
80104652:	85 c0                	test   %eax,%eax
80104654:	74 7e                	je     801046d4 <sys_link+0x11d>
  ilock(dp);
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	50                   	push   %eax
8010465a:	e8 10 cf ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010465f:	83 c4 10             	add    $0x10,%esp
80104662:	8b 03                	mov    (%ebx),%eax
80104664:	39 06                	cmp    %eax,(%esi)
80104666:	75 60                	jne    801046c8 <sys_link+0x111>
80104668:	83 ec 04             	sub    $0x4,%esp
8010466b:	ff 73 04             	pushl  0x4(%ebx)
8010466e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104671:	50                   	push   %eax
80104672:	56                   	push   %esi
80104673:	e8 a6 d4 ff ff       	call   80101b1e <dirlink>
80104678:	83 c4 10             	add    $0x10,%esp
8010467b:	85 c0                	test   %eax,%eax
8010467d:	78 49                	js     801046c8 <sys_link+0x111>
  iunlockput(dp);
8010467f:	83 ec 0c             	sub    $0xc,%esp
80104682:	56                   	push   %esi
80104683:	e8 8e d0 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104688:	89 1c 24             	mov    %ebx,(%esp)
8010468b:	e8 e6 cf ff ff       	call   80101676 <iput>
  end_op();
80104690:	e8 b7 e1 ff ff       	call   8010284c <end_op>
  return 0;
80104695:	83 c4 10             	add    $0x10,%esp
80104698:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010469d:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046a0:	5b                   	pop    %ebx
801046a1:	5e                   	pop    %esi
801046a2:	5d                   	pop    %ebp
801046a3:	c3                   	ret    
    end_op();
801046a4:	e8 a3 e1 ff ff       	call   8010284c <end_op>
    return -1;
801046a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ae:	eb ed                	jmp    8010469d <sys_link+0xe6>
    iunlockput(ip);
801046b0:	83 ec 0c             	sub    $0xc,%esp
801046b3:	53                   	push   %ebx
801046b4:	e8 5d d0 ff ff       	call   80101716 <iunlockput>
    end_op();
801046b9:	e8 8e e1 ff ff       	call   8010284c <end_op>
    return -1;
801046be:	83 c4 10             	add    $0x10,%esp
801046c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c6:	eb d5                	jmp    8010469d <sys_link+0xe6>
    iunlockput(dp);
801046c8:	83 ec 0c             	sub    $0xc,%esp
801046cb:	56                   	push   %esi
801046cc:	e8 45 d0 ff ff       	call   80101716 <iunlockput>
    goto bad;
801046d1:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	53                   	push   %ebx
801046d8:	e8 92 ce ff ff       	call   8010156f <ilock>
  ip->nlink--;
801046dd:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046e1:	83 e8 01             	sub    $0x1,%eax
801046e4:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046e8:	89 1c 24             	mov    %ebx,(%esp)
801046eb:	e8 1e cd ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801046f0:	89 1c 24             	mov    %ebx,(%esp)
801046f3:	e8 1e d0 ff ff       	call   80101716 <iunlockput>
  end_op();
801046f8:	e8 4f e1 ff ff       	call   8010284c <end_op>
  return -1;
801046fd:	83 c4 10             	add    $0x10,%esp
80104700:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104705:	eb 96                	jmp    8010469d <sys_link+0xe6>
    return -1;
80104707:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010470c:	eb 8f                	jmp    8010469d <sys_link+0xe6>
8010470e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104713:	eb 88                	jmp    8010469d <sys_link+0xe6>

80104715 <sys_unlink>:
{
80104715:	55                   	push   %ebp
80104716:	89 e5                	mov    %esp,%ebp
80104718:	57                   	push   %edi
80104719:	56                   	push   %esi
8010471a:	53                   	push   %ebx
8010471b:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010471e:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104721:	50                   	push   %eax
80104722:	6a 00                	push   $0x0
80104724:	e8 d2 f9 ff ff       	call   801040fb <argstr>
80104729:	83 c4 10             	add    $0x10,%esp
8010472c:	85 c0                	test   %eax,%eax
8010472e:	0f 88 83 01 00 00    	js     801048b7 <sys_unlink+0x1a2>
  begin_op();
80104734:	e8 99 e0 ff ff       	call   801027d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104739:	83 ec 08             	sub    $0x8,%esp
8010473c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010473f:	50                   	push   %eax
80104740:	ff 75 c4             	pushl  -0x3c(%ebp)
80104743:	e8 9f d4 ff ff       	call   80101be7 <nameiparent>
80104748:	89 c6                	mov    %eax,%esi
8010474a:	83 c4 10             	add    $0x10,%esp
8010474d:	85 c0                	test   %eax,%eax
8010474f:	0f 84 ed 00 00 00    	je     80104842 <sys_unlink+0x12d>
  ilock(dp);
80104755:	83 ec 0c             	sub    $0xc,%esp
80104758:	50                   	push   %eax
80104759:	e8 11 ce ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010475e:	83 c4 08             	add    $0x8,%esp
80104761:	68 32 70 10 80       	push   $0x80107032
80104766:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104769:	50                   	push   %eax
8010476a:	e8 1a d2 ff ff       	call   80101989 <namecmp>
8010476f:	83 c4 10             	add    $0x10,%esp
80104772:	85 c0                	test   %eax,%eax
80104774:	0f 84 fc 00 00 00    	je     80104876 <sys_unlink+0x161>
8010477a:	83 ec 08             	sub    $0x8,%esp
8010477d:	68 31 70 10 80       	push   $0x80107031
80104782:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104785:	50                   	push   %eax
80104786:	e8 fe d1 ff ff       	call   80101989 <namecmp>
8010478b:	83 c4 10             	add    $0x10,%esp
8010478e:	85 c0                	test   %eax,%eax
80104790:	0f 84 e0 00 00 00    	je     80104876 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104796:	83 ec 04             	sub    $0x4,%esp
80104799:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010479c:	50                   	push   %eax
8010479d:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047a0:	50                   	push   %eax
801047a1:	56                   	push   %esi
801047a2:	e8 f7 d1 ff ff       	call   8010199e <dirlookup>
801047a7:	89 c3                	mov    %eax,%ebx
801047a9:	83 c4 10             	add    $0x10,%esp
801047ac:	85 c0                	test   %eax,%eax
801047ae:	0f 84 c2 00 00 00    	je     80104876 <sys_unlink+0x161>
  ilock(ip);
801047b4:	83 ec 0c             	sub    $0xc,%esp
801047b7:	50                   	push   %eax
801047b8:	e8 b2 cd ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
801047bd:	83 c4 10             	add    $0x10,%esp
801047c0:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801047c5:	0f 8e 83 00 00 00    	jle    8010484e <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047cb:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047d0:	0f 84 85 00 00 00    	je     8010485b <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801047d6:	83 ec 04             	sub    $0x4,%esp
801047d9:	6a 10                	push   $0x10
801047db:	6a 00                	push   $0x0
801047dd:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047e0:	57                   	push   %edi
801047e1:	e8 3a f6 ff ff       	call   80103e20 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047e6:	6a 10                	push   $0x10
801047e8:	ff 75 c0             	pushl  -0x40(%ebp)
801047eb:	57                   	push   %edi
801047ec:	56                   	push   %esi
801047ed:	e8 6c d0 ff ff       	call   8010185e <writei>
801047f2:	83 c4 20             	add    $0x20,%esp
801047f5:	83 f8 10             	cmp    $0x10,%eax
801047f8:	0f 85 90 00 00 00    	jne    8010488e <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047fe:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104803:	0f 84 92 00 00 00    	je     8010489b <sys_unlink+0x186>
  iunlockput(dp);
80104809:	83 ec 0c             	sub    $0xc,%esp
8010480c:	56                   	push   %esi
8010480d:	e8 04 cf ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80104812:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104816:	83 e8 01             	sub    $0x1,%eax
80104819:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010481d:	89 1c 24             	mov    %ebx,(%esp)
80104820:	e8 e9 cb ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104825:	89 1c 24             	mov    %ebx,(%esp)
80104828:	e8 e9 ce ff ff       	call   80101716 <iunlockput>
  end_op();
8010482d:	e8 1a e0 ff ff       	call   8010284c <end_op>
  return 0;
80104832:	83 c4 10             	add    $0x10,%esp
80104835:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010483a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010483d:	5b                   	pop    %ebx
8010483e:	5e                   	pop    %esi
8010483f:	5f                   	pop    %edi
80104840:	5d                   	pop    %ebp
80104841:	c3                   	ret    
    end_op();
80104842:	e8 05 e0 ff ff       	call   8010284c <end_op>
    return -1;
80104847:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010484c:	eb ec                	jmp    8010483a <sys_unlink+0x125>
    panic("unlink: nlink < 1");
8010484e:	83 ec 0c             	sub    $0xc,%esp
80104851:	68 50 70 10 80       	push   $0x80107050
80104856:	e8 ed ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010485b:	89 d8                	mov    %ebx,%eax
8010485d:	e8 bf f9 ff ff       	call   80104221 <isdirempty>
80104862:	85 c0                	test   %eax,%eax
80104864:	0f 85 6c ff ff ff    	jne    801047d6 <sys_unlink+0xc1>
    iunlockput(ip);
8010486a:	83 ec 0c             	sub    $0xc,%esp
8010486d:	53                   	push   %ebx
8010486e:	e8 a3 ce ff ff       	call   80101716 <iunlockput>
    goto bad;
80104873:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104876:	83 ec 0c             	sub    $0xc,%esp
80104879:	56                   	push   %esi
8010487a:	e8 97 ce ff ff       	call   80101716 <iunlockput>
  end_op();
8010487f:	e8 c8 df ff ff       	call   8010284c <end_op>
  return -1;
80104884:	83 c4 10             	add    $0x10,%esp
80104887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010488c:	eb ac                	jmp    8010483a <sys_unlink+0x125>
    panic("unlink: writei");
8010488e:	83 ec 0c             	sub    $0xc,%esp
80104891:	68 62 70 10 80       	push   $0x80107062
80104896:	e8 ad ba ff ff       	call   80100348 <panic>
    dp->nlink--;
8010489b:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010489f:	83 e8 01             	sub    $0x1,%eax
801048a2:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801048a6:	83 ec 0c             	sub    $0xc,%esp
801048a9:	56                   	push   %esi
801048aa:	e8 5f cb ff ff       	call   8010140e <iupdate>
801048af:	83 c4 10             	add    $0x10,%esp
801048b2:	e9 52 ff ff ff       	jmp    80104809 <sys_unlink+0xf4>
    return -1;
801048b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048bc:	e9 79 ff ff ff       	jmp    8010483a <sys_unlink+0x125>

801048c1 <sys_open>:

int
sys_open(void)
{
801048c1:	55                   	push   %ebp
801048c2:	89 e5                	mov    %esp,%ebp
801048c4:	57                   	push   %edi
801048c5:	56                   	push   %esi
801048c6:	53                   	push   %ebx
801048c7:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801048ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048cd:	50                   	push   %eax
801048ce:	6a 00                	push   $0x0
801048d0:	e8 26 f8 ff ff       	call   801040fb <argstr>
801048d5:	83 c4 10             	add    $0x10,%esp
801048d8:	85 c0                	test   %eax,%eax
801048da:	0f 88 30 01 00 00    	js     80104a10 <sys_open+0x14f>
801048e0:	83 ec 08             	sub    $0x8,%esp
801048e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048e6:	50                   	push   %eax
801048e7:	6a 01                	push   $0x1
801048e9:	e8 7d f7 ff ff       	call   8010406b <argint>
801048ee:	83 c4 10             	add    $0x10,%esp
801048f1:	85 c0                	test   %eax,%eax
801048f3:	0f 88 21 01 00 00    	js     80104a1a <sys_open+0x159>
    return -1;

  begin_op();
801048f9:	e8 d4 de ff ff       	call   801027d2 <begin_op>

  if(omode & O_CREATE){
801048fe:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104902:	0f 84 84 00 00 00    	je     8010498c <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104908:	83 ec 0c             	sub    $0xc,%esp
8010490b:	6a 00                	push   $0x0
8010490d:	b9 00 00 00 00       	mov    $0x0,%ecx
80104912:	ba 02 00 00 00       	mov    $0x2,%edx
80104917:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010491a:	e8 59 f9 ff ff       	call   80104278 <create>
8010491f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104921:	83 c4 10             	add    $0x10,%esp
80104924:	85 c0                	test   %eax,%eax
80104926:	74 58                	je     80104980 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104928:	e8 00 c3 ff ff       	call   80100c2d <filealloc>
8010492d:	89 c3                	mov    %eax,%ebx
8010492f:	85 c0                	test   %eax,%eax
80104931:	0f 84 ae 00 00 00    	je     801049e5 <sys_open+0x124>
80104937:	e8 ae f8 ff ff       	call   801041ea <fdalloc>
8010493c:	89 c7                	mov    %eax,%edi
8010493e:	85 c0                	test   %eax,%eax
80104940:	0f 88 9f 00 00 00    	js     801049e5 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	56                   	push   %esi
8010494a:	e8 e2 cc ff ff       	call   80101631 <iunlock>
  end_op();
8010494f:	e8 f8 de ff ff       	call   8010284c <end_op>

  f->type = FD_INODE;
80104954:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
8010495a:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010495d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104964:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104967:	83 c4 10             	add    $0x10,%esp
8010496a:	a8 01                	test   $0x1,%al
8010496c:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104970:	a8 03                	test   $0x3,%al
80104972:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104976:	89 f8                	mov    %edi,%eax
80104978:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010497b:	5b                   	pop    %ebx
8010497c:	5e                   	pop    %esi
8010497d:	5f                   	pop    %edi
8010497e:	5d                   	pop    %ebp
8010497f:	c3                   	ret    
      end_op();
80104980:	e8 c7 de ff ff       	call   8010284c <end_op>
      return -1;
80104985:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010498a:	eb ea                	jmp    80104976 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
8010498c:	83 ec 0c             	sub    $0xc,%esp
8010498f:	ff 75 e4             	pushl  -0x1c(%ebp)
80104992:	e8 38 d2 ff ff       	call   80101bcf <namei>
80104997:	89 c6                	mov    %eax,%esi
80104999:	83 c4 10             	add    $0x10,%esp
8010499c:	85 c0                	test   %eax,%eax
8010499e:	74 39                	je     801049d9 <sys_open+0x118>
    ilock(ip);
801049a0:	83 ec 0c             	sub    $0xc,%esp
801049a3:	50                   	push   %eax
801049a4:	e8 c6 cb ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801049a9:	83 c4 10             	add    $0x10,%esp
801049ac:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801049b1:	0f 85 71 ff ff ff    	jne    80104928 <sys_open+0x67>
801049b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801049bb:	0f 84 67 ff ff ff    	je     80104928 <sys_open+0x67>
      iunlockput(ip);
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	56                   	push   %esi
801049c5:	e8 4c cd ff ff       	call   80101716 <iunlockput>
      end_op();
801049ca:	e8 7d de ff ff       	call   8010284c <end_op>
      return -1;
801049cf:	83 c4 10             	add    $0x10,%esp
801049d2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049d7:	eb 9d                	jmp    80104976 <sys_open+0xb5>
      end_op();
801049d9:	e8 6e de ff ff       	call   8010284c <end_op>
      return -1;
801049de:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049e3:	eb 91                	jmp    80104976 <sys_open+0xb5>
    if(f)
801049e5:	85 db                	test   %ebx,%ebx
801049e7:	74 0c                	je     801049f5 <sys_open+0x134>
      fileclose(f);
801049e9:	83 ec 0c             	sub    $0xc,%esp
801049ec:	53                   	push   %ebx
801049ed:	e8 e1 c2 ff ff       	call   80100cd3 <fileclose>
801049f2:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049f5:	83 ec 0c             	sub    $0xc,%esp
801049f8:	56                   	push   %esi
801049f9:	e8 18 cd ff ff       	call   80101716 <iunlockput>
    end_op();
801049fe:	e8 49 de ff ff       	call   8010284c <end_op>
    return -1;
80104a03:	83 c4 10             	add    $0x10,%esp
80104a06:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a0b:	e9 66 ff ff ff       	jmp    80104976 <sys_open+0xb5>
    return -1;
80104a10:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a15:	e9 5c ff ff ff       	jmp    80104976 <sys_open+0xb5>
80104a1a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a1f:	e9 52 ff ff ff       	jmp    80104976 <sys_open+0xb5>

80104a24 <sys_mkdir>:

int
sys_mkdir(void)
{
80104a24:	55                   	push   %ebp
80104a25:	89 e5                	mov    %esp,%ebp
80104a27:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a2a:	e8 a3 dd ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a2f:	83 ec 08             	sub    $0x8,%esp
80104a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a35:	50                   	push   %eax
80104a36:	6a 00                	push   $0x0
80104a38:	e8 be f6 ff ff       	call   801040fb <argstr>
80104a3d:	83 c4 10             	add    $0x10,%esp
80104a40:	85 c0                	test   %eax,%eax
80104a42:	78 36                	js     80104a7a <sys_mkdir+0x56>
80104a44:	83 ec 0c             	sub    $0xc,%esp
80104a47:	6a 00                	push   $0x0
80104a49:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a4e:	ba 01 00 00 00       	mov    $0x1,%edx
80104a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a56:	e8 1d f8 ff ff       	call   80104278 <create>
80104a5b:	83 c4 10             	add    $0x10,%esp
80104a5e:	85 c0                	test   %eax,%eax
80104a60:	74 18                	je     80104a7a <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a62:	83 ec 0c             	sub    $0xc,%esp
80104a65:	50                   	push   %eax
80104a66:	e8 ab cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104a6b:	e8 dc dd ff ff       	call   8010284c <end_op>
  return 0;
80104a70:	83 c4 10             	add    $0x10,%esp
80104a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a78:	c9                   	leave  
80104a79:	c3                   	ret    
    end_op();
80104a7a:	e8 cd dd ff ff       	call   8010284c <end_op>
    return -1;
80104a7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a84:	eb f2                	jmp    80104a78 <sys_mkdir+0x54>

80104a86 <sys_mknod>:

int
sys_mknod(void)
{
80104a86:	55                   	push   %ebp
80104a87:	89 e5                	mov    %esp,%ebp
80104a89:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a8c:	e8 41 dd ff ff       	call   801027d2 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a91:	83 ec 08             	sub    $0x8,%esp
80104a94:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a97:	50                   	push   %eax
80104a98:	6a 00                	push   $0x0
80104a9a:	e8 5c f6 ff ff       	call   801040fb <argstr>
80104a9f:	83 c4 10             	add    $0x10,%esp
80104aa2:	85 c0                	test   %eax,%eax
80104aa4:	78 62                	js     80104b08 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104aa6:	83 ec 08             	sub    $0x8,%esp
80104aa9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104aac:	50                   	push   %eax
80104aad:	6a 01                	push   $0x1
80104aaf:	e8 b7 f5 ff ff       	call   8010406b <argint>
  if((argstr(0, &path)) < 0 ||
80104ab4:	83 c4 10             	add    $0x10,%esp
80104ab7:	85 c0                	test   %eax,%eax
80104ab9:	78 4d                	js     80104b08 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104abb:	83 ec 08             	sub    $0x8,%esp
80104abe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ac1:	50                   	push   %eax
80104ac2:	6a 02                	push   $0x2
80104ac4:	e8 a2 f5 ff ff       	call   8010406b <argint>
     argint(1, &major) < 0 ||
80104ac9:	83 c4 10             	add    $0x10,%esp
80104acc:	85 c0                	test   %eax,%eax
80104ace:	78 38                	js     80104b08 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104ad0:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104ad4:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104ad8:	83 ec 0c             	sub    $0xc,%esp
80104adb:	50                   	push   %eax
80104adc:	ba 03 00 00 00       	mov    $0x3,%edx
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	e8 8f f7 ff ff       	call   80104278 <create>
80104ae9:	83 c4 10             	add    $0x10,%esp
80104aec:	85 c0                	test   %eax,%eax
80104aee:	74 18                	je     80104b08 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104af0:	83 ec 0c             	sub    $0xc,%esp
80104af3:	50                   	push   %eax
80104af4:	e8 1d cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104af9:	e8 4e dd ff ff       	call   8010284c <end_op>
  return 0;
80104afe:	83 c4 10             	add    $0x10,%esp
80104b01:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b06:	c9                   	leave  
80104b07:	c3                   	ret    
    end_op();
80104b08:	e8 3f dd ff ff       	call   8010284c <end_op>
    return -1;
80104b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b12:	eb f2                	jmp    80104b06 <sys_mknod+0x80>

80104b14 <sys_chdir>:

int
sys_chdir(void)
{
80104b14:	55                   	push   %ebp
80104b15:	89 e5                	mov    %esp,%ebp
80104b17:	56                   	push   %esi
80104b18:	53                   	push   %ebx
80104b19:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104b1c:	e8 82 e7 ff ff       	call   801032a3 <myproc>
80104b21:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104b23:	e8 aa dc ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b28:	83 ec 08             	sub    $0x8,%esp
80104b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b2e:	50                   	push   %eax
80104b2f:	6a 00                	push   $0x0
80104b31:	e8 c5 f5 ff ff       	call   801040fb <argstr>
80104b36:	83 c4 10             	add    $0x10,%esp
80104b39:	85 c0                	test   %eax,%eax
80104b3b:	78 52                	js     80104b8f <sys_chdir+0x7b>
80104b3d:	83 ec 0c             	sub    $0xc,%esp
80104b40:	ff 75 f4             	pushl  -0xc(%ebp)
80104b43:	e8 87 d0 ff ff       	call   80101bcf <namei>
80104b48:	89 c3                	mov    %eax,%ebx
80104b4a:	83 c4 10             	add    $0x10,%esp
80104b4d:	85 c0                	test   %eax,%eax
80104b4f:	74 3e                	je     80104b8f <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b51:	83 ec 0c             	sub    $0xc,%esp
80104b54:	50                   	push   %eax
80104b55:	e8 15 ca ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104b5a:	83 c4 10             	add    $0x10,%esp
80104b5d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b62:	75 37                	jne    80104b9b <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b64:	83 ec 0c             	sub    $0xc,%esp
80104b67:	53                   	push   %ebx
80104b68:	e8 c4 ca ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104b6d:	83 c4 04             	add    $0x4,%esp
80104b70:	ff 76 68             	pushl  0x68(%esi)
80104b73:	e8 fe ca ff ff       	call   80101676 <iput>
  end_op();
80104b78:	e8 cf dc ff ff       	call   8010284c <end_op>
  curproc->cwd = ip;
80104b7d:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b80:	83 c4 10             	add    $0x10,%esp
80104b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b88:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b8b:	5b                   	pop    %ebx
80104b8c:	5e                   	pop    %esi
80104b8d:	5d                   	pop    %ebp
80104b8e:	c3                   	ret    
    end_op();
80104b8f:	e8 b8 dc ff ff       	call   8010284c <end_op>
    return -1;
80104b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b99:	eb ed                	jmp    80104b88 <sys_chdir+0x74>
    iunlockput(ip);
80104b9b:	83 ec 0c             	sub    $0xc,%esp
80104b9e:	53                   	push   %ebx
80104b9f:	e8 72 cb ff ff       	call   80101716 <iunlockput>
    end_op();
80104ba4:	e8 a3 dc ff ff       	call   8010284c <end_op>
    return -1;
80104ba9:	83 c4 10             	add    $0x10,%esp
80104bac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb1:	eb d5                	jmp    80104b88 <sys_chdir+0x74>

80104bb3 <sys_exec>:

int
sys_exec(void)
{
80104bb3:	55                   	push   %ebp
80104bb4:	89 e5                	mov    %esp,%ebp
80104bb6:	53                   	push   %ebx
80104bb7:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104bbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bc0:	50                   	push   %eax
80104bc1:	6a 00                	push   $0x0
80104bc3:	e8 33 f5 ff ff       	call   801040fb <argstr>
80104bc8:	83 c4 10             	add    $0x10,%esp
80104bcb:	85 c0                	test   %eax,%eax
80104bcd:	0f 88 a8 00 00 00    	js     80104c7b <sys_exec+0xc8>
80104bd3:	83 ec 08             	sub    $0x8,%esp
80104bd6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bdc:	50                   	push   %eax
80104bdd:	6a 01                	push   $0x1
80104bdf:	e8 87 f4 ff ff       	call   8010406b <argint>
80104be4:	83 c4 10             	add    $0x10,%esp
80104be7:	85 c0                	test   %eax,%eax
80104be9:	0f 88 93 00 00 00    	js     80104c82 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bef:	83 ec 04             	sub    $0x4,%esp
80104bf2:	68 80 00 00 00       	push   $0x80
80104bf7:	6a 00                	push   $0x0
80104bf9:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bff:	50                   	push   %eax
80104c00:	e8 1b f2 ff ff       	call   80103e20 <memset>
80104c05:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104c08:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104c0d:	83 fb 1f             	cmp    $0x1f,%ebx
80104c10:	77 77                	ja     80104c89 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104c12:	83 ec 08             	sub    $0x8,%esp
80104c15:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104c1b:	50                   	push   %eax
80104c1c:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104c22:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104c25:	50                   	push   %eax
80104c26:	e8 c4 f3 ff ff       	call   80103fef <fetchint>
80104c2b:	83 c4 10             	add    $0x10,%esp
80104c2e:	85 c0                	test   %eax,%eax
80104c30:	78 5e                	js     80104c90 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104c32:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c38:	85 c0                	test   %eax,%eax
80104c3a:	74 1d                	je     80104c59 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104c3c:	83 ec 08             	sub    $0x8,%esp
80104c3f:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c46:	52                   	push   %edx
80104c47:	50                   	push   %eax
80104c48:	e8 de f3 ff ff       	call   8010402b <fetchstr>
80104c4d:	83 c4 10             	add    $0x10,%esp
80104c50:	85 c0                	test   %eax,%eax
80104c52:	78 46                	js     80104c9a <sys_exec+0xe7>
  for(i=0;; i++){
80104c54:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c57:	eb b4                	jmp    80104c0d <sys_exec+0x5a>
      argv[i] = 0;
80104c59:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c60:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c64:	83 ec 08             	sub    $0x8,%esp
80104c67:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c6d:	50                   	push   %eax
80104c6e:	ff 75 f4             	pushl  -0xc(%ebp)
80104c71:	e8 5c bc ff ff       	call   801008d2 <exec>
80104c76:	83 c4 10             	add    $0x10,%esp
80104c79:	eb 1a                	jmp    80104c95 <sys_exec+0xe2>
    return -1;
80104c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c80:	eb 13                	jmp    80104c95 <sys_exec+0xe2>
80104c82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c87:	eb 0c                	jmp    80104c95 <sys_exec+0xe2>
      return -1;
80104c89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c8e:	eb 05                	jmp    80104c95 <sys_exec+0xe2>
      return -1;
80104c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c98:	c9                   	leave  
80104c99:	c3                   	ret    
      return -1;
80104c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c9f:	eb f4                	jmp    80104c95 <sys_exec+0xe2>

80104ca1 <sys_pipe>:

int
sys_pipe(void)
{
80104ca1:	55                   	push   %ebp
80104ca2:	89 e5                	mov    %esp,%ebp
80104ca4:	53                   	push   %ebx
80104ca5:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104ca8:	6a 08                	push   $0x8
80104caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cad:	50                   	push   %eax
80104cae:	6a 00                	push   $0x0
80104cb0:	e8 de f3 ff ff       	call   80104093 <argptr>
80104cb5:	83 c4 10             	add    $0x10,%esp
80104cb8:	85 c0                	test   %eax,%eax
80104cba:	78 77                	js     80104d33 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104cbc:	83 ec 08             	sub    $0x8,%esp
80104cbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104cc2:	50                   	push   %eax
80104cc3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cc6:	50                   	push   %eax
80104cc7:	e8 c4 e0 ff ff       	call   80102d90 <pipealloc>
80104ccc:	83 c4 10             	add    $0x10,%esp
80104ccf:	85 c0                	test   %eax,%eax
80104cd1:	78 67                	js     80104d3a <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd6:	e8 0f f5 ff ff       	call   801041ea <fdalloc>
80104cdb:	89 c3                	mov    %eax,%ebx
80104cdd:	85 c0                	test   %eax,%eax
80104cdf:	78 21                	js     80104d02 <sys_pipe+0x61>
80104ce1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ce4:	e8 01 f5 ff ff       	call   801041ea <fdalloc>
80104ce9:	85 c0                	test   %eax,%eax
80104ceb:	78 15                	js     80104d02 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cf0:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cf5:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104cf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d00:	c9                   	leave  
80104d01:	c3                   	ret    
    if(fd0 >= 0)
80104d02:	85 db                	test   %ebx,%ebx
80104d04:	78 0d                	js     80104d13 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104d06:	e8 98 e5 ff ff       	call   801032a3 <myproc>
80104d0b:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104d12:	00 
    fileclose(rf);
80104d13:	83 ec 0c             	sub    $0xc,%esp
80104d16:	ff 75 f0             	pushl  -0x10(%ebp)
80104d19:	e8 b5 bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104d1e:	83 c4 04             	add    $0x4,%esp
80104d21:	ff 75 ec             	pushl  -0x14(%ebp)
80104d24:	e8 aa bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104d29:	83 c4 10             	add    $0x10,%esp
80104d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d31:	eb ca                	jmp    80104cfd <sys_pipe+0x5c>
    return -1;
80104d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d38:	eb c3                	jmp    80104cfd <sys_pipe+0x5c>
    return -1;
80104d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3f:	eb bc                	jmp    80104cfd <sys_pipe+0x5c>

80104d41 <sys_writecount>:

int
sys_writecount(void){
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
  uint myWriteCount;
  myWriteCount = writeCount_global;
  return myWriteCount;
}
80104d44:	a1 54 4e 11 80       	mov    0x80114e54,%eax
80104d49:	5d                   	pop    %ebp
80104d4a:	c3                   	ret    

80104d4b <sys_setwritecount>:

int
sys_setwritecount(void){
80104d4b:	55                   	push   %ebp
80104d4c:	89 e5                	mov    %esp,%ebp
80104d4e:	83 ec 20             	sub    $0x20,%esp
   int pid;
  

  if(argint(0, &pid) < 0)
80104d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d54:	50                   	push   %eax
80104d55:	6a 00                	push   $0x0
80104d57:	e8 0f f3 ff ff       	call   8010406b <argint>
80104d5c:	83 c4 10             	add    $0x10,%esp
80104d5f:	85 c0                	test   %eax,%eax
80104d61:	78 0f                	js     80104d72 <sys_setwritecount+0x27>
    return -1;
  writeCount_global = (uint) pid;
80104d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d66:	a3 54 4e 11 80       	mov    %eax,0x80114e54
  return 0;
80104d6b:	b8 00 00 00 00       	mov    $0x0,%eax
80104d70:	c9                   	leave  
80104d71:	c3                   	ret    
    return -1;
80104d72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d77:	eb f7                	jmp    80104d70 <sys_setwritecount+0x25>

80104d79 <sys_fork>:



int
sys_fork(void)
{
80104d79:	55                   	push   %ebp
80104d7a:	89 e5                	mov    %esp,%ebp
80104d7c:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d7f:	e8 a1 e6 ff ff       	call   80103425 <fork>
}
80104d84:	c9                   	leave  
80104d85:	c3                   	ret    

80104d86 <sys_exit>:

int
sys_exit(void)
{
80104d86:	55                   	push   %ebp
80104d87:	89 e5                	mov    %esp,%ebp
80104d89:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d8c:	e8 74 e9 ff ff       	call   80103705 <exit>
  return 0;  // not reached
}
80104d91:	b8 00 00 00 00       	mov    $0x0,%eax
80104d96:	c9                   	leave  
80104d97:	c3                   	ret    

80104d98 <sys_wait>:

int
sys_wait(void)
{
80104d98:	55                   	push   %ebp
80104d99:	89 e5                	mov    %esp,%ebp
80104d9b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d9e:	e8 ee ea ff ff       	call   80103891 <wait>
}
80104da3:	c9                   	leave  
80104da4:	c3                   	ret    

80104da5 <sys_kill>:

int
sys_kill(void)
{
80104da5:	55                   	push   %ebp
80104da6:	89 e5                	mov    %esp,%ebp
80104da8:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104dab:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dae:	50                   	push   %eax
80104daf:	6a 00                	push   $0x0
80104db1:	e8 b5 f2 ff ff       	call   8010406b <argint>
80104db6:	83 c4 10             	add    $0x10,%esp
80104db9:	85 c0                	test   %eax,%eax
80104dbb:	78 10                	js     80104dcd <sys_kill+0x28>
    return -1;
  return kill(pid);
80104dbd:	83 ec 0c             	sub    $0xc,%esp
80104dc0:	ff 75 f4             	pushl  -0xc(%ebp)
80104dc3:	e8 c9 eb ff ff       	call   80103991 <kill>
80104dc8:	83 c4 10             	add    $0x10,%esp
}
80104dcb:	c9                   	leave  
80104dcc:	c3                   	ret    
    return -1;
80104dcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd2:	eb f7                	jmp    80104dcb <sys_kill+0x26>

80104dd4 <sys_getpid>:

int
sys_getpid(void)
{
80104dd4:	55                   	push   %ebp
80104dd5:	89 e5                	mov    %esp,%ebp
80104dd7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104dda:	e8 c4 e4 ff ff       	call   801032a3 <myproc>
80104ddf:	8b 40 10             	mov    0x10(%eax),%eax
}
80104de2:	c9                   	leave  
80104de3:	c3                   	ret    

80104de4 <sys_sbrk>:

int
sys_sbrk(void)
{
80104de4:	55                   	push   %ebp
80104de5:	89 e5                	mov    %esp,%ebp
80104de7:	53                   	push   %ebx
80104de8:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104deb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dee:	50                   	push   %eax
80104def:	6a 00                	push   $0x0
80104df1:	e8 75 f2 ff ff       	call   8010406b <argint>
80104df6:	83 c4 10             	add    $0x10,%esp
80104df9:	85 c0                	test   %eax,%eax
80104dfb:	78 27                	js     80104e24 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104dfd:	e8 a1 e4 ff ff       	call   801032a3 <myproc>
80104e02:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104e04:	83 ec 0c             	sub    $0xc,%esp
80104e07:	ff 75 f4             	pushl  -0xc(%ebp)
80104e0a:	e8 a9 e5 ff ff       	call   801033b8 <growproc>
80104e0f:	83 c4 10             	add    $0x10,%esp
80104e12:	85 c0                	test   %eax,%eax
80104e14:	78 07                	js     80104e1d <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104e16:	89 d8                	mov    %ebx,%eax
80104e18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e1b:	c9                   	leave  
80104e1c:	c3                   	ret    
    return -1;
80104e1d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e22:	eb f2                	jmp    80104e16 <sys_sbrk+0x32>
    return -1;
80104e24:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e29:	eb eb                	jmp    80104e16 <sys_sbrk+0x32>

80104e2b <sys_sleep>:

int
sys_sleep(void)
{
80104e2b:	55                   	push   %ebp
80104e2c:	89 e5                	mov    %esp,%ebp
80104e2e:	53                   	push   %ebx
80104e2f:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e35:	50                   	push   %eax
80104e36:	6a 00                	push   $0x0
80104e38:	e8 2e f2 ff ff       	call   8010406b <argint>
80104e3d:	83 c4 10             	add    $0x10,%esp
80104e40:	85 c0                	test   %eax,%eax
80104e42:	78 75                	js     80104eb9 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e44:	83 ec 0c             	sub    $0xc,%esp
80104e47:	68 60 4e 11 80       	push   $0x80114e60
80104e4c:	e8 23 ef ff ff       	call   80103d74 <acquire>
  ticks0 = ticks;
80104e51:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  while(ticks - ticks0 < n){
80104e57:	83 c4 10             	add    $0x10,%esp
80104e5a:	a1 a0 56 11 80       	mov    0x801156a0,%eax
80104e5f:	29 d8                	sub    %ebx,%eax
80104e61:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e64:	73 39                	jae    80104e9f <sys_sleep+0x74>
    if(myproc()->killed){
80104e66:	e8 38 e4 ff ff       	call   801032a3 <myproc>
80104e6b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e6f:	75 17                	jne    80104e88 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e71:	83 ec 08             	sub    $0x8,%esp
80104e74:	68 60 4e 11 80       	push   $0x80114e60
80104e79:	68 a0 56 11 80       	push   $0x801156a0
80104e7e:	e8 7d e9 ff ff       	call   80103800 <sleep>
80104e83:	83 c4 10             	add    $0x10,%esp
80104e86:	eb d2                	jmp    80104e5a <sys_sleep+0x2f>
      release(&tickslock);
80104e88:	83 ec 0c             	sub    $0xc,%esp
80104e8b:	68 60 4e 11 80       	push   $0x80114e60
80104e90:	e8 44 ef ff ff       	call   80103dd9 <release>
      return -1;
80104e95:	83 c4 10             	add    $0x10,%esp
80104e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e9d:	eb 15                	jmp    80104eb4 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e9f:	83 ec 0c             	sub    $0xc,%esp
80104ea2:	68 60 4e 11 80       	push   $0x80114e60
80104ea7:	e8 2d ef ff ff       	call   80103dd9 <release>
  return 0;
80104eac:	83 c4 10             	add    $0x10,%esp
80104eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104eb7:	c9                   	leave  
80104eb8:	c3                   	ret    
    return -1;
80104eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ebe:	eb f4                	jmp    80104eb4 <sys_sleep+0x89>

80104ec0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104ec0:	55                   	push   %ebp
80104ec1:	89 e5                	mov    %esp,%ebp
80104ec3:	53                   	push   %ebx
80104ec4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104ec7:	68 60 4e 11 80       	push   $0x80114e60
80104ecc:	e8 a3 ee ff ff       	call   80103d74 <acquire>
  xticks = ticks;
80104ed1:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  release(&tickslock);
80104ed7:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80104ede:	e8 f6 ee ff ff       	call   80103dd9 <release>
  return xticks;
}
80104ee3:	89 d8                	mov    %ebx,%eax
80104ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ee8:	c9                   	leave  
80104ee9:	c3                   	ret    

80104eea <sys_yield>:

int
sys_yield(void)
{
80104eea:	55                   	push   %ebp
80104eeb:	89 e5                	mov    %esp,%ebp
80104eed:	83 ec 08             	sub    $0x8,%esp
  yield();
80104ef0:	e8 d9 e8 ff ff       	call   801037ce <yield>
  return 0;
}
80104ef5:	b8 00 00 00 00       	mov    $0x0,%eax
80104efa:	c9                   	leave  
80104efb:	c3                   	ret    

80104efc <sys_shutdown>:

int sys_shutdown(void)
{
80104efc:	55                   	push   %ebp
80104efd:	89 e5                	mov    %esp,%ebp
80104eff:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104f02:	e8 ff d2 ff ff       	call   80102206 <shutdown>
  return 0;
}
80104f07:	b8 00 00 00 00       	mov    $0x0,%eax
80104f0c:	c9                   	leave  
80104f0d:	c3                   	ret    

80104f0e <sys_settickets>:

int sys_settickets(void){
80104f0e:	55                   	push   %ebp
80104f0f:	89 e5                	mov    %esp,%ebp
80104f11:	53                   	push   %ebx
80104f12:	83 ec 14             	sub    $0x14,%esp
  int tickets;
  struct proc *curproc = myproc();
80104f15:	e8 89 e3 ff ff       	call   801032a3 <myproc>
80104f1a:	89 c3                	mov    %eax,%ebx

  if(argint(0, &tickets) < 0)
80104f1c:	83 ec 08             	sub    $0x8,%esp
80104f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f22:	50                   	push   %eax
80104f23:	6a 00                	push   $0x0
80104f25:	e8 41 f1 ff ff       	call   8010406b <argint>
80104f2a:	83 c4 10             	add    $0x10,%esp
80104f2d:	85 c0                	test   %eax,%eax
80104f2f:	78 13                	js     80104f44 <sys_settickets+0x36>
    return -1;

  curproc->tickets = tickets;
80104f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)

  
  
  return 0;
80104f3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f42:	c9                   	leave  
80104f43:	c3                   	ret    
    return -1;
80104f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f49:	eb f4                	jmp    80104f3f <sys_settickets+0x31>

80104f4b <sys_getprocessesinfo>:

int sys_getprocessesinfo(void){
80104f4b:	55                   	push   %ebp
80104f4c:	89 e5                	mov    %esp,%ebp
80104f4e:	83 ec 1c             	sub    $0x1c,%esp
  //int x;
  


  
  if( argptr(0, (void*) &my_process_info, sizeof(*my_process_info)) < 0){
80104f51:	68 04 03 00 00       	push   $0x304
80104f56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f59:	50                   	push   %eax
80104f5a:	6a 00                	push   $0x0
80104f5c:	e8 32 f1 ff ff       	call   80104093 <argptr>
80104f61:	83 c4 10             	add    $0x10,%esp
80104f64:	85 c0                	test   %eax,%eax
80104f66:	78 10                	js     80104f78 <sys_getprocessesinfo+0x2d>
    return -1;
  }

  return getprocessesinfo_helper(my_process_info);
80104f68:	83 ec 0c             	sub    $0xc,%esp
80104f6b:	ff 75 f4             	pushl  -0xc(%ebp)
80104f6e:	e8 49 eb ff ff       	call   80103abc <getprocessesinfo_helper>
80104f73:	83 c4 10             	add    $0x10,%esp
}
80104f76:	c9                   	leave  
80104f77:	c3                   	ret    
    return -1;
80104f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f7d:	eb f7                	jmp    80104f76 <sys_getprocessesinfo+0x2b>

80104f7f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104f7f:	1e                   	push   %ds
  pushl %es
80104f80:	06                   	push   %es
  pushl %fs
80104f81:	0f a0                	push   %fs
  pushl %gs
80104f83:	0f a8                	push   %gs
  pushal
80104f85:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f86:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f8a:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f8c:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f8e:	54                   	push   %esp
  call trap
80104f8f:	e8 e3 00 00 00       	call   80105077 <trap>
  addl $4, %esp
80104f94:	83 c4 04             	add    $0x4,%esp

80104f97 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f97:	61                   	popa   
  popl %gs
80104f98:	0f a9                	pop    %gs
  popl %fs
80104f9a:	0f a1                	pop    %fs
  popl %es
80104f9c:	07                   	pop    %es
  popl %ds
80104f9d:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f9e:	83 c4 08             	add    $0x8,%esp
  iret
80104fa1:	cf                   	iret   

80104fa2 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104fa2:	55                   	push   %ebp
80104fa3:	89 e5                	mov    %esp,%ebp
80104fa5:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104fa8:	b8 00 00 00 00       	mov    $0x0,%eax
80104fad:	eb 4a                	jmp    80104ff9 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104faf:	8b 0c 85 0c a0 10 80 	mov    -0x7fef5ff4(,%eax,4),%ecx
80104fb6:	66 89 0c c5 a0 4e 11 	mov    %cx,-0x7feeb160(,%eax,8)
80104fbd:	80 
80104fbe:	66 c7 04 c5 a2 4e 11 	movw   $0x8,-0x7feeb15e(,%eax,8)
80104fc5:	80 08 00 
80104fc8:	c6 04 c5 a4 4e 11 80 	movb   $0x0,-0x7feeb15c(,%eax,8)
80104fcf:	00 
80104fd0:	0f b6 14 c5 a5 4e 11 	movzbl -0x7feeb15b(,%eax,8),%edx
80104fd7:	80 
80104fd8:	83 e2 f0             	and    $0xfffffff0,%edx
80104fdb:	83 ca 0e             	or     $0xe,%edx
80104fde:	83 e2 8f             	and    $0xffffff8f,%edx
80104fe1:	83 ca 80             	or     $0xffffff80,%edx
80104fe4:	88 14 c5 a5 4e 11 80 	mov    %dl,-0x7feeb15b(,%eax,8)
80104feb:	c1 e9 10             	shr    $0x10,%ecx
80104fee:	66 89 0c c5 a6 4e 11 	mov    %cx,-0x7feeb15a(,%eax,8)
80104ff5:	80 
  for(i = 0; i < 256; i++)
80104ff6:	83 c0 01             	add    $0x1,%eax
80104ff9:	3d ff 00 00 00       	cmp    $0xff,%eax
80104ffe:	7e af                	jle    80104faf <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105000:	8b 15 0c a1 10 80    	mov    0x8010a10c,%edx
80105006:	66 89 15 a0 50 11 80 	mov    %dx,0x801150a0
8010500d:	66 c7 05 a2 50 11 80 	movw   $0x8,0x801150a2
80105014:	08 00 
80105016:	c6 05 a4 50 11 80 00 	movb   $0x0,0x801150a4
8010501d:	0f b6 05 a5 50 11 80 	movzbl 0x801150a5,%eax
80105024:	83 c8 0f             	or     $0xf,%eax
80105027:	83 e0 ef             	and    $0xffffffef,%eax
8010502a:	83 c8 e0             	or     $0xffffffe0,%eax
8010502d:	a2 a5 50 11 80       	mov    %al,0x801150a5
80105032:	c1 ea 10             	shr    $0x10,%edx
80105035:	66 89 15 a6 50 11 80 	mov    %dx,0x801150a6

  initlock(&tickslock, "time");
8010503c:	83 ec 08             	sub    $0x8,%esp
8010503f:	68 71 70 10 80       	push   $0x80107071
80105044:	68 60 4e 11 80       	push   $0x80114e60
80105049:	e8 ea eb ff ff       	call   80103c38 <initlock>
}
8010504e:	83 c4 10             	add    $0x10,%esp
80105051:	c9                   	leave  
80105052:	c3                   	ret    

80105053 <idtinit>:

void
idtinit(void)
{
80105053:	55                   	push   %ebp
80105054:	89 e5                	mov    %esp,%ebp
80105056:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105059:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
8010505f:	b8 a0 4e 11 80       	mov    $0x80114ea0,%eax
80105064:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105068:	c1 e8 10             	shr    $0x10,%eax
8010506b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010506f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105072:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105075:	c9                   	leave  
80105076:	c3                   	ret    

80105077 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105077:	55                   	push   %ebp
80105078:	89 e5                	mov    %esp,%ebp
8010507a:	57                   	push   %edi
8010507b:	56                   	push   %esi
8010507c:	53                   	push   %ebx
8010507d:	83 ec 1c             	sub    $0x1c,%esp
80105080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105083:	8b 43 30             	mov    0x30(%ebx),%eax
80105086:	83 f8 40             	cmp    $0x40,%eax
80105089:	74 13                	je     8010509e <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010508b:	83 e8 20             	sub    $0x20,%eax
8010508e:	83 f8 1f             	cmp    $0x1f,%eax
80105091:	0f 87 3a 01 00 00    	ja     801051d1 <trap+0x15a>
80105097:	ff 24 85 18 71 10 80 	jmp    *-0x7fef8ee8(,%eax,4)
    if(myproc()->killed)
8010509e:	e8 00 e2 ff ff       	call   801032a3 <myproc>
801050a3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050a7:	75 1f                	jne    801050c8 <trap+0x51>
    myproc()->tf = tf;
801050a9:	e8 f5 e1 ff ff       	call   801032a3 <myproc>
801050ae:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801050b1:	e8 78 f0 ff ff       	call   8010412e <syscall>
    if(myproc()->killed)
801050b6:	e8 e8 e1 ff ff       	call   801032a3 <myproc>
801050bb:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050bf:	74 7e                	je     8010513f <trap+0xc8>
      exit();
801050c1:	e8 3f e6 ff ff       	call   80103705 <exit>
801050c6:	eb 77                	jmp    8010513f <trap+0xc8>
      exit();
801050c8:	e8 38 e6 ff ff       	call   80103705 <exit>
801050cd:	eb da                	jmp    801050a9 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801050cf:	e8 b4 e1 ff ff       	call   80103288 <cpuid>
801050d4:	85 c0                	test   %eax,%eax
801050d6:	74 6f                	je     80105147 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801050d8:	e8 e0 d2 ff ff       	call   801023bd <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050dd:	e8 c1 e1 ff ff       	call   801032a3 <myproc>
801050e2:	85 c0                	test   %eax,%eax
801050e4:	74 1c                	je     80105102 <trap+0x8b>
801050e6:	e8 b8 e1 ff ff       	call   801032a3 <myproc>
801050eb:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050ef:	74 11                	je     80105102 <trap+0x8b>
801050f1:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050f5:	83 e0 03             	and    $0x3,%eax
801050f8:	66 83 f8 03          	cmp    $0x3,%ax
801050fc:	0f 84 62 01 00 00    	je     80105264 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105102:	e8 9c e1 ff ff       	call   801032a3 <myproc>
80105107:	85 c0                	test   %eax,%eax
80105109:	74 0f                	je     8010511a <trap+0xa3>
8010510b:	e8 93 e1 ff ff       	call   801032a3 <myproc>
80105110:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105114:	0f 84 54 01 00 00    	je     8010526e <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010511a:	e8 84 e1 ff ff       	call   801032a3 <myproc>
8010511f:	85 c0                	test   %eax,%eax
80105121:	74 1c                	je     8010513f <trap+0xc8>
80105123:	e8 7b e1 ff ff       	call   801032a3 <myproc>
80105128:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010512c:	74 11                	je     8010513f <trap+0xc8>
8010512e:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105132:	83 e0 03             	and    $0x3,%eax
80105135:	66 83 f8 03          	cmp    $0x3,%ax
80105139:	0f 84 43 01 00 00    	je     80105282 <trap+0x20b>
    exit();
}
8010513f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105142:	5b                   	pop    %ebx
80105143:	5e                   	pop    %esi
80105144:	5f                   	pop    %edi
80105145:	5d                   	pop    %ebp
80105146:	c3                   	ret    
      acquire(&tickslock);
80105147:	83 ec 0c             	sub    $0xc,%esp
8010514a:	68 60 4e 11 80       	push   $0x80114e60
8010514f:	e8 20 ec ff ff       	call   80103d74 <acquire>
      ticks++;
80105154:	83 05 a0 56 11 80 01 	addl   $0x1,0x801156a0
      wakeup(&ticks);
8010515b:	c7 04 24 a0 56 11 80 	movl   $0x801156a0,(%esp)
80105162:	e8 01 e8 ff ff       	call   80103968 <wakeup>
      release(&tickslock);
80105167:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
8010516e:	e8 66 ec ff ff       	call   80103dd9 <release>
80105173:	83 c4 10             	add    $0x10,%esp
80105176:	e9 5d ff ff ff       	jmp    801050d8 <trap+0x61>
    ideintr();
8010517b:	e8 e1 cb ff ff       	call   80101d61 <ideintr>
    lapiceoi();
80105180:	e8 38 d2 ff ff       	call   801023bd <lapiceoi>
    break;
80105185:	e9 53 ff ff ff       	jmp    801050dd <trap+0x66>
    kbdintr();
8010518a:	e8 62 d0 ff ff       	call   801021f1 <kbdintr>
    lapiceoi();
8010518f:	e8 29 d2 ff ff       	call   801023bd <lapiceoi>
    break;
80105194:	e9 44 ff ff ff       	jmp    801050dd <trap+0x66>
    uartintr();
80105199:	e8 05 02 00 00       	call   801053a3 <uartintr>
    lapiceoi();
8010519e:	e8 1a d2 ff ff       	call   801023bd <lapiceoi>
    break;
801051a3:	e9 35 ff ff ff       	jmp    801050dd <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051a8:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801051ab:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051af:	e8 d4 e0 ff ff       	call   80103288 <cpuid>
801051b4:	57                   	push   %edi
801051b5:	0f b7 f6             	movzwl %si,%esi
801051b8:	56                   	push   %esi
801051b9:	50                   	push   %eax
801051ba:	68 7c 70 10 80       	push   $0x8010707c
801051bf:	e8 47 b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
801051c4:	e8 f4 d1 ff ff       	call   801023bd <lapiceoi>
    break;
801051c9:	83 c4 10             	add    $0x10,%esp
801051cc:	e9 0c ff ff ff       	jmp    801050dd <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801051d1:	e8 cd e0 ff ff       	call   801032a3 <myproc>
801051d6:	85 c0                	test   %eax,%eax
801051d8:	74 5f                	je     80105239 <trap+0x1c2>
801051da:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801051de:	74 59                	je     80105239 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801051e0:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051e3:	8b 43 38             	mov    0x38(%ebx),%eax
801051e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801051e9:	e8 9a e0 ff ff       	call   80103288 <cpuid>
801051ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
801051f1:	8b 53 34             	mov    0x34(%ebx),%edx
801051f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
801051f7:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801051fa:	e8 a4 e0 ff ff       	call   801032a3 <myproc>
801051ff:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105202:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105205:	e8 99 e0 ff ff       	call   801032a3 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010520a:	57                   	push   %edi
8010520b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010520e:	ff 75 e0             	pushl  -0x20(%ebp)
80105211:	ff 75 dc             	pushl  -0x24(%ebp)
80105214:	56                   	push   %esi
80105215:	ff 75 d8             	pushl  -0x28(%ebp)
80105218:	ff 70 10             	pushl  0x10(%eax)
8010521b:	68 d4 70 10 80       	push   $0x801070d4
80105220:	e8 e6 b3 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105225:	83 c4 20             	add    $0x20,%esp
80105228:	e8 76 e0 ff ff       	call   801032a3 <myproc>
8010522d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105234:	e9 a4 fe ff ff       	jmp    801050dd <trap+0x66>
80105239:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010523c:	8b 73 38             	mov    0x38(%ebx),%esi
8010523f:	e8 44 e0 ff ff       	call   80103288 <cpuid>
80105244:	83 ec 0c             	sub    $0xc,%esp
80105247:	57                   	push   %edi
80105248:	56                   	push   %esi
80105249:	50                   	push   %eax
8010524a:	ff 73 30             	pushl  0x30(%ebx)
8010524d:	68 a0 70 10 80       	push   $0x801070a0
80105252:	e8 b4 b3 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105257:	83 c4 14             	add    $0x14,%esp
8010525a:	68 76 70 10 80       	push   $0x80107076
8010525f:	e8 e4 b0 ff ff       	call   80100348 <panic>
    exit();
80105264:	e8 9c e4 ff ff       	call   80103705 <exit>
80105269:	e9 94 fe ff ff       	jmp    80105102 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010526e:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105272:	0f 85 a2 fe ff ff    	jne    8010511a <trap+0xa3>
    yield();
80105278:	e8 51 e5 ff ff       	call   801037ce <yield>
8010527d:	e9 98 fe ff ff       	jmp    8010511a <trap+0xa3>
    exit();
80105282:	e8 7e e4 ff ff       	call   80103705 <exit>
80105287:	e9 b3 fe ff ff       	jmp    8010513f <trap+0xc8>

8010528c <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010528c:	55                   	push   %ebp
8010528d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010528f:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105296:	74 15                	je     801052ad <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105298:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010529d:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010529e:	a8 01                	test   $0x1,%al
801052a0:	74 12                	je     801052b4 <uartgetc+0x28>
801052a2:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052a7:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801052a8:	0f b6 c0             	movzbl %al,%eax
}
801052ab:	5d                   	pop    %ebp
801052ac:	c3                   	ret    
    return -1;
801052ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b2:	eb f7                	jmp    801052ab <uartgetc+0x1f>
    return -1;
801052b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b9:	eb f0                	jmp    801052ab <uartgetc+0x1f>

801052bb <uartputc>:
  if(!uart)
801052bb:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801052c2:	74 3b                	je     801052ff <uartputc+0x44>
{
801052c4:	55                   	push   %ebp
801052c5:	89 e5                	mov    %esp,%ebp
801052c7:	53                   	push   %ebx
801052c8:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801052cb:	bb 00 00 00 00       	mov    $0x0,%ebx
801052d0:	eb 10                	jmp    801052e2 <uartputc+0x27>
    microdelay(10);
801052d2:	83 ec 0c             	sub    $0xc,%esp
801052d5:	6a 0a                	push   $0xa
801052d7:	e8 00 d1 ff ff       	call   801023dc <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801052dc:	83 c3 01             	add    $0x1,%ebx
801052df:	83 c4 10             	add    $0x10,%esp
801052e2:	83 fb 7f             	cmp    $0x7f,%ebx
801052e5:	7f 0a                	jg     801052f1 <uartputc+0x36>
801052e7:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052ec:	ec                   	in     (%dx),%al
801052ed:	a8 20                	test   $0x20,%al
801052ef:	74 e1                	je     801052d2 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801052f1:	8b 45 08             	mov    0x8(%ebp),%eax
801052f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052f9:	ee                   	out    %al,(%dx)
}
801052fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052fd:	c9                   	leave  
801052fe:	c3                   	ret    
801052ff:	f3 c3                	repz ret 

80105301 <uartinit>:
{
80105301:	55                   	push   %ebp
80105302:	89 e5                	mov    %esp,%ebp
80105304:	56                   	push   %esi
80105305:	53                   	push   %ebx
80105306:	b9 00 00 00 00       	mov    $0x0,%ecx
8010530b:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105310:	89 c8                	mov    %ecx,%eax
80105312:	ee                   	out    %al,(%dx)
80105313:	be fb 03 00 00       	mov    $0x3fb,%esi
80105318:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010531d:	89 f2                	mov    %esi,%edx
8010531f:	ee                   	out    %al,(%dx)
80105320:	b8 0c 00 00 00       	mov    $0xc,%eax
80105325:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010532a:	ee                   	out    %al,(%dx)
8010532b:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105330:	89 c8                	mov    %ecx,%eax
80105332:	89 da                	mov    %ebx,%edx
80105334:	ee                   	out    %al,(%dx)
80105335:	b8 03 00 00 00       	mov    $0x3,%eax
8010533a:	89 f2                	mov    %esi,%edx
8010533c:	ee                   	out    %al,(%dx)
8010533d:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105342:	89 c8                	mov    %ecx,%eax
80105344:	ee                   	out    %al,(%dx)
80105345:	b8 01 00 00 00       	mov    $0x1,%eax
8010534a:	89 da                	mov    %ebx,%edx
8010534c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010534d:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105352:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105353:	3c ff                	cmp    $0xff,%al
80105355:	74 45                	je     8010539c <uartinit+0x9b>
  uart = 1;
80105357:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
8010535e:	00 00 00 
80105361:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105366:	ec                   	in     (%dx),%al
80105367:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010536c:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010536d:	83 ec 08             	sub    $0x8,%esp
80105370:	6a 00                	push   $0x0
80105372:	6a 04                	push   $0x4
80105374:	e8 f3 cb ff ff       	call   80101f6c <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105379:	83 c4 10             	add    $0x10,%esp
8010537c:	bb 98 71 10 80       	mov    $0x80107198,%ebx
80105381:	eb 12                	jmp    80105395 <uartinit+0x94>
    uartputc(*p);
80105383:	83 ec 0c             	sub    $0xc,%esp
80105386:	0f be c0             	movsbl %al,%eax
80105389:	50                   	push   %eax
8010538a:	e8 2c ff ff ff       	call   801052bb <uartputc>
  for(p="xv6...\n"; *p; p++)
8010538f:	83 c3 01             	add    $0x1,%ebx
80105392:	83 c4 10             	add    $0x10,%esp
80105395:	0f b6 03             	movzbl (%ebx),%eax
80105398:	84 c0                	test   %al,%al
8010539a:	75 e7                	jne    80105383 <uartinit+0x82>
}
8010539c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010539f:	5b                   	pop    %ebx
801053a0:	5e                   	pop    %esi
801053a1:	5d                   	pop    %ebp
801053a2:	c3                   	ret    

801053a3 <uartintr>:

void
uartintr(void)
{
801053a3:	55                   	push   %ebp
801053a4:	89 e5                	mov    %esp,%ebp
801053a6:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801053a9:	68 8c 52 10 80       	push   $0x8010528c
801053ae:	e8 8b b3 ff ff       	call   8010073e <consoleintr>
}
801053b3:	83 c4 10             	add    $0x10,%esp
801053b6:	c9                   	leave  
801053b7:	c3                   	ret    

801053b8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801053b8:	6a 00                	push   $0x0
  pushl $0
801053ba:	6a 00                	push   $0x0
  jmp alltraps
801053bc:	e9 be fb ff ff       	jmp    80104f7f <alltraps>

801053c1 <vector1>:
.globl vector1
vector1:
  pushl $0
801053c1:	6a 00                	push   $0x0
  pushl $1
801053c3:	6a 01                	push   $0x1
  jmp alltraps
801053c5:	e9 b5 fb ff ff       	jmp    80104f7f <alltraps>

801053ca <vector2>:
.globl vector2
vector2:
  pushl $0
801053ca:	6a 00                	push   $0x0
  pushl $2
801053cc:	6a 02                	push   $0x2
  jmp alltraps
801053ce:	e9 ac fb ff ff       	jmp    80104f7f <alltraps>

801053d3 <vector3>:
.globl vector3
vector3:
  pushl $0
801053d3:	6a 00                	push   $0x0
  pushl $3
801053d5:	6a 03                	push   $0x3
  jmp alltraps
801053d7:	e9 a3 fb ff ff       	jmp    80104f7f <alltraps>

801053dc <vector4>:
.globl vector4
vector4:
  pushl $0
801053dc:	6a 00                	push   $0x0
  pushl $4
801053de:	6a 04                	push   $0x4
  jmp alltraps
801053e0:	e9 9a fb ff ff       	jmp    80104f7f <alltraps>

801053e5 <vector5>:
.globl vector5
vector5:
  pushl $0
801053e5:	6a 00                	push   $0x0
  pushl $5
801053e7:	6a 05                	push   $0x5
  jmp alltraps
801053e9:	e9 91 fb ff ff       	jmp    80104f7f <alltraps>

801053ee <vector6>:
.globl vector6
vector6:
  pushl $0
801053ee:	6a 00                	push   $0x0
  pushl $6
801053f0:	6a 06                	push   $0x6
  jmp alltraps
801053f2:	e9 88 fb ff ff       	jmp    80104f7f <alltraps>

801053f7 <vector7>:
.globl vector7
vector7:
  pushl $0
801053f7:	6a 00                	push   $0x0
  pushl $7
801053f9:	6a 07                	push   $0x7
  jmp alltraps
801053fb:	e9 7f fb ff ff       	jmp    80104f7f <alltraps>

80105400 <vector8>:
.globl vector8
vector8:
  pushl $8
80105400:	6a 08                	push   $0x8
  jmp alltraps
80105402:	e9 78 fb ff ff       	jmp    80104f7f <alltraps>

80105407 <vector9>:
.globl vector9
vector9:
  pushl $0
80105407:	6a 00                	push   $0x0
  pushl $9
80105409:	6a 09                	push   $0x9
  jmp alltraps
8010540b:	e9 6f fb ff ff       	jmp    80104f7f <alltraps>

80105410 <vector10>:
.globl vector10
vector10:
  pushl $10
80105410:	6a 0a                	push   $0xa
  jmp alltraps
80105412:	e9 68 fb ff ff       	jmp    80104f7f <alltraps>

80105417 <vector11>:
.globl vector11
vector11:
  pushl $11
80105417:	6a 0b                	push   $0xb
  jmp alltraps
80105419:	e9 61 fb ff ff       	jmp    80104f7f <alltraps>

8010541e <vector12>:
.globl vector12
vector12:
  pushl $12
8010541e:	6a 0c                	push   $0xc
  jmp alltraps
80105420:	e9 5a fb ff ff       	jmp    80104f7f <alltraps>

80105425 <vector13>:
.globl vector13
vector13:
  pushl $13
80105425:	6a 0d                	push   $0xd
  jmp alltraps
80105427:	e9 53 fb ff ff       	jmp    80104f7f <alltraps>

8010542c <vector14>:
.globl vector14
vector14:
  pushl $14
8010542c:	6a 0e                	push   $0xe
  jmp alltraps
8010542e:	e9 4c fb ff ff       	jmp    80104f7f <alltraps>

80105433 <vector15>:
.globl vector15
vector15:
  pushl $0
80105433:	6a 00                	push   $0x0
  pushl $15
80105435:	6a 0f                	push   $0xf
  jmp alltraps
80105437:	e9 43 fb ff ff       	jmp    80104f7f <alltraps>

8010543c <vector16>:
.globl vector16
vector16:
  pushl $0
8010543c:	6a 00                	push   $0x0
  pushl $16
8010543e:	6a 10                	push   $0x10
  jmp alltraps
80105440:	e9 3a fb ff ff       	jmp    80104f7f <alltraps>

80105445 <vector17>:
.globl vector17
vector17:
  pushl $17
80105445:	6a 11                	push   $0x11
  jmp alltraps
80105447:	e9 33 fb ff ff       	jmp    80104f7f <alltraps>

8010544c <vector18>:
.globl vector18
vector18:
  pushl $0
8010544c:	6a 00                	push   $0x0
  pushl $18
8010544e:	6a 12                	push   $0x12
  jmp alltraps
80105450:	e9 2a fb ff ff       	jmp    80104f7f <alltraps>

80105455 <vector19>:
.globl vector19
vector19:
  pushl $0
80105455:	6a 00                	push   $0x0
  pushl $19
80105457:	6a 13                	push   $0x13
  jmp alltraps
80105459:	e9 21 fb ff ff       	jmp    80104f7f <alltraps>

8010545e <vector20>:
.globl vector20
vector20:
  pushl $0
8010545e:	6a 00                	push   $0x0
  pushl $20
80105460:	6a 14                	push   $0x14
  jmp alltraps
80105462:	e9 18 fb ff ff       	jmp    80104f7f <alltraps>

80105467 <vector21>:
.globl vector21
vector21:
  pushl $0
80105467:	6a 00                	push   $0x0
  pushl $21
80105469:	6a 15                	push   $0x15
  jmp alltraps
8010546b:	e9 0f fb ff ff       	jmp    80104f7f <alltraps>

80105470 <vector22>:
.globl vector22
vector22:
  pushl $0
80105470:	6a 00                	push   $0x0
  pushl $22
80105472:	6a 16                	push   $0x16
  jmp alltraps
80105474:	e9 06 fb ff ff       	jmp    80104f7f <alltraps>

80105479 <vector23>:
.globl vector23
vector23:
  pushl $0
80105479:	6a 00                	push   $0x0
  pushl $23
8010547b:	6a 17                	push   $0x17
  jmp alltraps
8010547d:	e9 fd fa ff ff       	jmp    80104f7f <alltraps>

80105482 <vector24>:
.globl vector24
vector24:
  pushl $0
80105482:	6a 00                	push   $0x0
  pushl $24
80105484:	6a 18                	push   $0x18
  jmp alltraps
80105486:	e9 f4 fa ff ff       	jmp    80104f7f <alltraps>

8010548b <vector25>:
.globl vector25
vector25:
  pushl $0
8010548b:	6a 00                	push   $0x0
  pushl $25
8010548d:	6a 19                	push   $0x19
  jmp alltraps
8010548f:	e9 eb fa ff ff       	jmp    80104f7f <alltraps>

80105494 <vector26>:
.globl vector26
vector26:
  pushl $0
80105494:	6a 00                	push   $0x0
  pushl $26
80105496:	6a 1a                	push   $0x1a
  jmp alltraps
80105498:	e9 e2 fa ff ff       	jmp    80104f7f <alltraps>

8010549d <vector27>:
.globl vector27
vector27:
  pushl $0
8010549d:	6a 00                	push   $0x0
  pushl $27
8010549f:	6a 1b                	push   $0x1b
  jmp alltraps
801054a1:	e9 d9 fa ff ff       	jmp    80104f7f <alltraps>

801054a6 <vector28>:
.globl vector28
vector28:
  pushl $0
801054a6:	6a 00                	push   $0x0
  pushl $28
801054a8:	6a 1c                	push   $0x1c
  jmp alltraps
801054aa:	e9 d0 fa ff ff       	jmp    80104f7f <alltraps>

801054af <vector29>:
.globl vector29
vector29:
  pushl $0
801054af:	6a 00                	push   $0x0
  pushl $29
801054b1:	6a 1d                	push   $0x1d
  jmp alltraps
801054b3:	e9 c7 fa ff ff       	jmp    80104f7f <alltraps>

801054b8 <vector30>:
.globl vector30
vector30:
  pushl $0
801054b8:	6a 00                	push   $0x0
  pushl $30
801054ba:	6a 1e                	push   $0x1e
  jmp alltraps
801054bc:	e9 be fa ff ff       	jmp    80104f7f <alltraps>

801054c1 <vector31>:
.globl vector31
vector31:
  pushl $0
801054c1:	6a 00                	push   $0x0
  pushl $31
801054c3:	6a 1f                	push   $0x1f
  jmp alltraps
801054c5:	e9 b5 fa ff ff       	jmp    80104f7f <alltraps>

801054ca <vector32>:
.globl vector32
vector32:
  pushl $0
801054ca:	6a 00                	push   $0x0
  pushl $32
801054cc:	6a 20                	push   $0x20
  jmp alltraps
801054ce:	e9 ac fa ff ff       	jmp    80104f7f <alltraps>

801054d3 <vector33>:
.globl vector33
vector33:
  pushl $0
801054d3:	6a 00                	push   $0x0
  pushl $33
801054d5:	6a 21                	push   $0x21
  jmp alltraps
801054d7:	e9 a3 fa ff ff       	jmp    80104f7f <alltraps>

801054dc <vector34>:
.globl vector34
vector34:
  pushl $0
801054dc:	6a 00                	push   $0x0
  pushl $34
801054de:	6a 22                	push   $0x22
  jmp alltraps
801054e0:	e9 9a fa ff ff       	jmp    80104f7f <alltraps>

801054e5 <vector35>:
.globl vector35
vector35:
  pushl $0
801054e5:	6a 00                	push   $0x0
  pushl $35
801054e7:	6a 23                	push   $0x23
  jmp alltraps
801054e9:	e9 91 fa ff ff       	jmp    80104f7f <alltraps>

801054ee <vector36>:
.globl vector36
vector36:
  pushl $0
801054ee:	6a 00                	push   $0x0
  pushl $36
801054f0:	6a 24                	push   $0x24
  jmp alltraps
801054f2:	e9 88 fa ff ff       	jmp    80104f7f <alltraps>

801054f7 <vector37>:
.globl vector37
vector37:
  pushl $0
801054f7:	6a 00                	push   $0x0
  pushl $37
801054f9:	6a 25                	push   $0x25
  jmp alltraps
801054fb:	e9 7f fa ff ff       	jmp    80104f7f <alltraps>

80105500 <vector38>:
.globl vector38
vector38:
  pushl $0
80105500:	6a 00                	push   $0x0
  pushl $38
80105502:	6a 26                	push   $0x26
  jmp alltraps
80105504:	e9 76 fa ff ff       	jmp    80104f7f <alltraps>

80105509 <vector39>:
.globl vector39
vector39:
  pushl $0
80105509:	6a 00                	push   $0x0
  pushl $39
8010550b:	6a 27                	push   $0x27
  jmp alltraps
8010550d:	e9 6d fa ff ff       	jmp    80104f7f <alltraps>

80105512 <vector40>:
.globl vector40
vector40:
  pushl $0
80105512:	6a 00                	push   $0x0
  pushl $40
80105514:	6a 28                	push   $0x28
  jmp alltraps
80105516:	e9 64 fa ff ff       	jmp    80104f7f <alltraps>

8010551b <vector41>:
.globl vector41
vector41:
  pushl $0
8010551b:	6a 00                	push   $0x0
  pushl $41
8010551d:	6a 29                	push   $0x29
  jmp alltraps
8010551f:	e9 5b fa ff ff       	jmp    80104f7f <alltraps>

80105524 <vector42>:
.globl vector42
vector42:
  pushl $0
80105524:	6a 00                	push   $0x0
  pushl $42
80105526:	6a 2a                	push   $0x2a
  jmp alltraps
80105528:	e9 52 fa ff ff       	jmp    80104f7f <alltraps>

8010552d <vector43>:
.globl vector43
vector43:
  pushl $0
8010552d:	6a 00                	push   $0x0
  pushl $43
8010552f:	6a 2b                	push   $0x2b
  jmp alltraps
80105531:	e9 49 fa ff ff       	jmp    80104f7f <alltraps>

80105536 <vector44>:
.globl vector44
vector44:
  pushl $0
80105536:	6a 00                	push   $0x0
  pushl $44
80105538:	6a 2c                	push   $0x2c
  jmp alltraps
8010553a:	e9 40 fa ff ff       	jmp    80104f7f <alltraps>

8010553f <vector45>:
.globl vector45
vector45:
  pushl $0
8010553f:	6a 00                	push   $0x0
  pushl $45
80105541:	6a 2d                	push   $0x2d
  jmp alltraps
80105543:	e9 37 fa ff ff       	jmp    80104f7f <alltraps>

80105548 <vector46>:
.globl vector46
vector46:
  pushl $0
80105548:	6a 00                	push   $0x0
  pushl $46
8010554a:	6a 2e                	push   $0x2e
  jmp alltraps
8010554c:	e9 2e fa ff ff       	jmp    80104f7f <alltraps>

80105551 <vector47>:
.globl vector47
vector47:
  pushl $0
80105551:	6a 00                	push   $0x0
  pushl $47
80105553:	6a 2f                	push   $0x2f
  jmp alltraps
80105555:	e9 25 fa ff ff       	jmp    80104f7f <alltraps>

8010555a <vector48>:
.globl vector48
vector48:
  pushl $0
8010555a:	6a 00                	push   $0x0
  pushl $48
8010555c:	6a 30                	push   $0x30
  jmp alltraps
8010555e:	e9 1c fa ff ff       	jmp    80104f7f <alltraps>

80105563 <vector49>:
.globl vector49
vector49:
  pushl $0
80105563:	6a 00                	push   $0x0
  pushl $49
80105565:	6a 31                	push   $0x31
  jmp alltraps
80105567:	e9 13 fa ff ff       	jmp    80104f7f <alltraps>

8010556c <vector50>:
.globl vector50
vector50:
  pushl $0
8010556c:	6a 00                	push   $0x0
  pushl $50
8010556e:	6a 32                	push   $0x32
  jmp alltraps
80105570:	e9 0a fa ff ff       	jmp    80104f7f <alltraps>

80105575 <vector51>:
.globl vector51
vector51:
  pushl $0
80105575:	6a 00                	push   $0x0
  pushl $51
80105577:	6a 33                	push   $0x33
  jmp alltraps
80105579:	e9 01 fa ff ff       	jmp    80104f7f <alltraps>

8010557e <vector52>:
.globl vector52
vector52:
  pushl $0
8010557e:	6a 00                	push   $0x0
  pushl $52
80105580:	6a 34                	push   $0x34
  jmp alltraps
80105582:	e9 f8 f9 ff ff       	jmp    80104f7f <alltraps>

80105587 <vector53>:
.globl vector53
vector53:
  pushl $0
80105587:	6a 00                	push   $0x0
  pushl $53
80105589:	6a 35                	push   $0x35
  jmp alltraps
8010558b:	e9 ef f9 ff ff       	jmp    80104f7f <alltraps>

80105590 <vector54>:
.globl vector54
vector54:
  pushl $0
80105590:	6a 00                	push   $0x0
  pushl $54
80105592:	6a 36                	push   $0x36
  jmp alltraps
80105594:	e9 e6 f9 ff ff       	jmp    80104f7f <alltraps>

80105599 <vector55>:
.globl vector55
vector55:
  pushl $0
80105599:	6a 00                	push   $0x0
  pushl $55
8010559b:	6a 37                	push   $0x37
  jmp alltraps
8010559d:	e9 dd f9 ff ff       	jmp    80104f7f <alltraps>

801055a2 <vector56>:
.globl vector56
vector56:
  pushl $0
801055a2:	6a 00                	push   $0x0
  pushl $56
801055a4:	6a 38                	push   $0x38
  jmp alltraps
801055a6:	e9 d4 f9 ff ff       	jmp    80104f7f <alltraps>

801055ab <vector57>:
.globl vector57
vector57:
  pushl $0
801055ab:	6a 00                	push   $0x0
  pushl $57
801055ad:	6a 39                	push   $0x39
  jmp alltraps
801055af:	e9 cb f9 ff ff       	jmp    80104f7f <alltraps>

801055b4 <vector58>:
.globl vector58
vector58:
  pushl $0
801055b4:	6a 00                	push   $0x0
  pushl $58
801055b6:	6a 3a                	push   $0x3a
  jmp alltraps
801055b8:	e9 c2 f9 ff ff       	jmp    80104f7f <alltraps>

801055bd <vector59>:
.globl vector59
vector59:
  pushl $0
801055bd:	6a 00                	push   $0x0
  pushl $59
801055bf:	6a 3b                	push   $0x3b
  jmp alltraps
801055c1:	e9 b9 f9 ff ff       	jmp    80104f7f <alltraps>

801055c6 <vector60>:
.globl vector60
vector60:
  pushl $0
801055c6:	6a 00                	push   $0x0
  pushl $60
801055c8:	6a 3c                	push   $0x3c
  jmp alltraps
801055ca:	e9 b0 f9 ff ff       	jmp    80104f7f <alltraps>

801055cf <vector61>:
.globl vector61
vector61:
  pushl $0
801055cf:	6a 00                	push   $0x0
  pushl $61
801055d1:	6a 3d                	push   $0x3d
  jmp alltraps
801055d3:	e9 a7 f9 ff ff       	jmp    80104f7f <alltraps>

801055d8 <vector62>:
.globl vector62
vector62:
  pushl $0
801055d8:	6a 00                	push   $0x0
  pushl $62
801055da:	6a 3e                	push   $0x3e
  jmp alltraps
801055dc:	e9 9e f9 ff ff       	jmp    80104f7f <alltraps>

801055e1 <vector63>:
.globl vector63
vector63:
  pushl $0
801055e1:	6a 00                	push   $0x0
  pushl $63
801055e3:	6a 3f                	push   $0x3f
  jmp alltraps
801055e5:	e9 95 f9 ff ff       	jmp    80104f7f <alltraps>

801055ea <vector64>:
.globl vector64
vector64:
  pushl $0
801055ea:	6a 00                	push   $0x0
  pushl $64
801055ec:	6a 40                	push   $0x40
  jmp alltraps
801055ee:	e9 8c f9 ff ff       	jmp    80104f7f <alltraps>

801055f3 <vector65>:
.globl vector65
vector65:
  pushl $0
801055f3:	6a 00                	push   $0x0
  pushl $65
801055f5:	6a 41                	push   $0x41
  jmp alltraps
801055f7:	e9 83 f9 ff ff       	jmp    80104f7f <alltraps>

801055fc <vector66>:
.globl vector66
vector66:
  pushl $0
801055fc:	6a 00                	push   $0x0
  pushl $66
801055fe:	6a 42                	push   $0x42
  jmp alltraps
80105600:	e9 7a f9 ff ff       	jmp    80104f7f <alltraps>

80105605 <vector67>:
.globl vector67
vector67:
  pushl $0
80105605:	6a 00                	push   $0x0
  pushl $67
80105607:	6a 43                	push   $0x43
  jmp alltraps
80105609:	e9 71 f9 ff ff       	jmp    80104f7f <alltraps>

8010560e <vector68>:
.globl vector68
vector68:
  pushl $0
8010560e:	6a 00                	push   $0x0
  pushl $68
80105610:	6a 44                	push   $0x44
  jmp alltraps
80105612:	e9 68 f9 ff ff       	jmp    80104f7f <alltraps>

80105617 <vector69>:
.globl vector69
vector69:
  pushl $0
80105617:	6a 00                	push   $0x0
  pushl $69
80105619:	6a 45                	push   $0x45
  jmp alltraps
8010561b:	e9 5f f9 ff ff       	jmp    80104f7f <alltraps>

80105620 <vector70>:
.globl vector70
vector70:
  pushl $0
80105620:	6a 00                	push   $0x0
  pushl $70
80105622:	6a 46                	push   $0x46
  jmp alltraps
80105624:	e9 56 f9 ff ff       	jmp    80104f7f <alltraps>

80105629 <vector71>:
.globl vector71
vector71:
  pushl $0
80105629:	6a 00                	push   $0x0
  pushl $71
8010562b:	6a 47                	push   $0x47
  jmp alltraps
8010562d:	e9 4d f9 ff ff       	jmp    80104f7f <alltraps>

80105632 <vector72>:
.globl vector72
vector72:
  pushl $0
80105632:	6a 00                	push   $0x0
  pushl $72
80105634:	6a 48                	push   $0x48
  jmp alltraps
80105636:	e9 44 f9 ff ff       	jmp    80104f7f <alltraps>

8010563b <vector73>:
.globl vector73
vector73:
  pushl $0
8010563b:	6a 00                	push   $0x0
  pushl $73
8010563d:	6a 49                	push   $0x49
  jmp alltraps
8010563f:	e9 3b f9 ff ff       	jmp    80104f7f <alltraps>

80105644 <vector74>:
.globl vector74
vector74:
  pushl $0
80105644:	6a 00                	push   $0x0
  pushl $74
80105646:	6a 4a                	push   $0x4a
  jmp alltraps
80105648:	e9 32 f9 ff ff       	jmp    80104f7f <alltraps>

8010564d <vector75>:
.globl vector75
vector75:
  pushl $0
8010564d:	6a 00                	push   $0x0
  pushl $75
8010564f:	6a 4b                	push   $0x4b
  jmp alltraps
80105651:	e9 29 f9 ff ff       	jmp    80104f7f <alltraps>

80105656 <vector76>:
.globl vector76
vector76:
  pushl $0
80105656:	6a 00                	push   $0x0
  pushl $76
80105658:	6a 4c                	push   $0x4c
  jmp alltraps
8010565a:	e9 20 f9 ff ff       	jmp    80104f7f <alltraps>

8010565f <vector77>:
.globl vector77
vector77:
  pushl $0
8010565f:	6a 00                	push   $0x0
  pushl $77
80105661:	6a 4d                	push   $0x4d
  jmp alltraps
80105663:	e9 17 f9 ff ff       	jmp    80104f7f <alltraps>

80105668 <vector78>:
.globl vector78
vector78:
  pushl $0
80105668:	6a 00                	push   $0x0
  pushl $78
8010566a:	6a 4e                	push   $0x4e
  jmp alltraps
8010566c:	e9 0e f9 ff ff       	jmp    80104f7f <alltraps>

80105671 <vector79>:
.globl vector79
vector79:
  pushl $0
80105671:	6a 00                	push   $0x0
  pushl $79
80105673:	6a 4f                	push   $0x4f
  jmp alltraps
80105675:	e9 05 f9 ff ff       	jmp    80104f7f <alltraps>

8010567a <vector80>:
.globl vector80
vector80:
  pushl $0
8010567a:	6a 00                	push   $0x0
  pushl $80
8010567c:	6a 50                	push   $0x50
  jmp alltraps
8010567e:	e9 fc f8 ff ff       	jmp    80104f7f <alltraps>

80105683 <vector81>:
.globl vector81
vector81:
  pushl $0
80105683:	6a 00                	push   $0x0
  pushl $81
80105685:	6a 51                	push   $0x51
  jmp alltraps
80105687:	e9 f3 f8 ff ff       	jmp    80104f7f <alltraps>

8010568c <vector82>:
.globl vector82
vector82:
  pushl $0
8010568c:	6a 00                	push   $0x0
  pushl $82
8010568e:	6a 52                	push   $0x52
  jmp alltraps
80105690:	e9 ea f8 ff ff       	jmp    80104f7f <alltraps>

80105695 <vector83>:
.globl vector83
vector83:
  pushl $0
80105695:	6a 00                	push   $0x0
  pushl $83
80105697:	6a 53                	push   $0x53
  jmp alltraps
80105699:	e9 e1 f8 ff ff       	jmp    80104f7f <alltraps>

8010569e <vector84>:
.globl vector84
vector84:
  pushl $0
8010569e:	6a 00                	push   $0x0
  pushl $84
801056a0:	6a 54                	push   $0x54
  jmp alltraps
801056a2:	e9 d8 f8 ff ff       	jmp    80104f7f <alltraps>

801056a7 <vector85>:
.globl vector85
vector85:
  pushl $0
801056a7:	6a 00                	push   $0x0
  pushl $85
801056a9:	6a 55                	push   $0x55
  jmp alltraps
801056ab:	e9 cf f8 ff ff       	jmp    80104f7f <alltraps>

801056b0 <vector86>:
.globl vector86
vector86:
  pushl $0
801056b0:	6a 00                	push   $0x0
  pushl $86
801056b2:	6a 56                	push   $0x56
  jmp alltraps
801056b4:	e9 c6 f8 ff ff       	jmp    80104f7f <alltraps>

801056b9 <vector87>:
.globl vector87
vector87:
  pushl $0
801056b9:	6a 00                	push   $0x0
  pushl $87
801056bb:	6a 57                	push   $0x57
  jmp alltraps
801056bd:	e9 bd f8 ff ff       	jmp    80104f7f <alltraps>

801056c2 <vector88>:
.globl vector88
vector88:
  pushl $0
801056c2:	6a 00                	push   $0x0
  pushl $88
801056c4:	6a 58                	push   $0x58
  jmp alltraps
801056c6:	e9 b4 f8 ff ff       	jmp    80104f7f <alltraps>

801056cb <vector89>:
.globl vector89
vector89:
  pushl $0
801056cb:	6a 00                	push   $0x0
  pushl $89
801056cd:	6a 59                	push   $0x59
  jmp alltraps
801056cf:	e9 ab f8 ff ff       	jmp    80104f7f <alltraps>

801056d4 <vector90>:
.globl vector90
vector90:
  pushl $0
801056d4:	6a 00                	push   $0x0
  pushl $90
801056d6:	6a 5a                	push   $0x5a
  jmp alltraps
801056d8:	e9 a2 f8 ff ff       	jmp    80104f7f <alltraps>

801056dd <vector91>:
.globl vector91
vector91:
  pushl $0
801056dd:	6a 00                	push   $0x0
  pushl $91
801056df:	6a 5b                	push   $0x5b
  jmp alltraps
801056e1:	e9 99 f8 ff ff       	jmp    80104f7f <alltraps>

801056e6 <vector92>:
.globl vector92
vector92:
  pushl $0
801056e6:	6a 00                	push   $0x0
  pushl $92
801056e8:	6a 5c                	push   $0x5c
  jmp alltraps
801056ea:	e9 90 f8 ff ff       	jmp    80104f7f <alltraps>

801056ef <vector93>:
.globl vector93
vector93:
  pushl $0
801056ef:	6a 00                	push   $0x0
  pushl $93
801056f1:	6a 5d                	push   $0x5d
  jmp alltraps
801056f3:	e9 87 f8 ff ff       	jmp    80104f7f <alltraps>

801056f8 <vector94>:
.globl vector94
vector94:
  pushl $0
801056f8:	6a 00                	push   $0x0
  pushl $94
801056fa:	6a 5e                	push   $0x5e
  jmp alltraps
801056fc:	e9 7e f8 ff ff       	jmp    80104f7f <alltraps>

80105701 <vector95>:
.globl vector95
vector95:
  pushl $0
80105701:	6a 00                	push   $0x0
  pushl $95
80105703:	6a 5f                	push   $0x5f
  jmp alltraps
80105705:	e9 75 f8 ff ff       	jmp    80104f7f <alltraps>

8010570a <vector96>:
.globl vector96
vector96:
  pushl $0
8010570a:	6a 00                	push   $0x0
  pushl $96
8010570c:	6a 60                	push   $0x60
  jmp alltraps
8010570e:	e9 6c f8 ff ff       	jmp    80104f7f <alltraps>

80105713 <vector97>:
.globl vector97
vector97:
  pushl $0
80105713:	6a 00                	push   $0x0
  pushl $97
80105715:	6a 61                	push   $0x61
  jmp alltraps
80105717:	e9 63 f8 ff ff       	jmp    80104f7f <alltraps>

8010571c <vector98>:
.globl vector98
vector98:
  pushl $0
8010571c:	6a 00                	push   $0x0
  pushl $98
8010571e:	6a 62                	push   $0x62
  jmp alltraps
80105720:	e9 5a f8 ff ff       	jmp    80104f7f <alltraps>

80105725 <vector99>:
.globl vector99
vector99:
  pushl $0
80105725:	6a 00                	push   $0x0
  pushl $99
80105727:	6a 63                	push   $0x63
  jmp alltraps
80105729:	e9 51 f8 ff ff       	jmp    80104f7f <alltraps>

8010572e <vector100>:
.globl vector100
vector100:
  pushl $0
8010572e:	6a 00                	push   $0x0
  pushl $100
80105730:	6a 64                	push   $0x64
  jmp alltraps
80105732:	e9 48 f8 ff ff       	jmp    80104f7f <alltraps>

80105737 <vector101>:
.globl vector101
vector101:
  pushl $0
80105737:	6a 00                	push   $0x0
  pushl $101
80105739:	6a 65                	push   $0x65
  jmp alltraps
8010573b:	e9 3f f8 ff ff       	jmp    80104f7f <alltraps>

80105740 <vector102>:
.globl vector102
vector102:
  pushl $0
80105740:	6a 00                	push   $0x0
  pushl $102
80105742:	6a 66                	push   $0x66
  jmp alltraps
80105744:	e9 36 f8 ff ff       	jmp    80104f7f <alltraps>

80105749 <vector103>:
.globl vector103
vector103:
  pushl $0
80105749:	6a 00                	push   $0x0
  pushl $103
8010574b:	6a 67                	push   $0x67
  jmp alltraps
8010574d:	e9 2d f8 ff ff       	jmp    80104f7f <alltraps>

80105752 <vector104>:
.globl vector104
vector104:
  pushl $0
80105752:	6a 00                	push   $0x0
  pushl $104
80105754:	6a 68                	push   $0x68
  jmp alltraps
80105756:	e9 24 f8 ff ff       	jmp    80104f7f <alltraps>

8010575b <vector105>:
.globl vector105
vector105:
  pushl $0
8010575b:	6a 00                	push   $0x0
  pushl $105
8010575d:	6a 69                	push   $0x69
  jmp alltraps
8010575f:	e9 1b f8 ff ff       	jmp    80104f7f <alltraps>

80105764 <vector106>:
.globl vector106
vector106:
  pushl $0
80105764:	6a 00                	push   $0x0
  pushl $106
80105766:	6a 6a                	push   $0x6a
  jmp alltraps
80105768:	e9 12 f8 ff ff       	jmp    80104f7f <alltraps>

8010576d <vector107>:
.globl vector107
vector107:
  pushl $0
8010576d:	6a 00                	push   $0x0
  pushl $107
8010576f:	6a 6b                	push   $0x6b
  jmp alltraps
80105771:	e9 09 f8 ff ff       	jmp    80104f7f <alltraps>

80105776 <vector108>:
.globl vector108
vector108:
  pushl $0
80105776:	6a 00                	push   $0x0
  pushl $108
80105778:	6a 6c                	push   $0x6c
  jmp alltraps
8010577a:	e9 00 f8 ff ff       	jmp    80104f7f <alltraps>

8010577f <vector109>:
.globl vector109
vector109:
  pushl $0
8010577f:	6a 00                	push   $0x0
  pushl $109
80105781:	6a 6d                	push   $0x6d
  jmp alltraps
80105783:	e9 f7 f7 ff ff       	jmp    80104f7f <alltraps>

80105788 <vector110>:
.globl vector110
vector110:
  pushl $0
80105788:	6a 00                	push   $0x0
  pushl $110
8010578a:	6a 6e                	push   $0x6e
  jmp alltraps
8010578c:	e9 ee f7 ff ff       	jmp    80104f7f <alltraps>

80105791 <vector111>:
.globl vector111
vector111:
  pushl $0
80105791:	6a 00                	push   $0x0
  pushl $111
80105793:	6a 6f                	push   $0x6f
  jmp alltraps
80105795:	e9 e5 f7 ff ff       	jmp    80104f7f <alltraps>

8010579a <vector112>:
.globl vector112
vector112:
  pushl $0
8010579a:	6a 00                	push   $0x0
  pushl $112
8010579c:	6a 70                	push   $0x70
  jmp alltraps
8010579e:	e9 dc f7 ff ff       	jmp    80104f7f <alltraps>

801057a3 <vector113>:
.globl vector113
vector113:
  pushl $0
801057a3:	6a 00                	push   $0x0
  pushl $113
801057a5:	6a 71                	push   $0x71
  jmp alltraps
801057a7:	e9 d3 f7 ff ff       	jmp    80104f7f <alltraps>

801057ac <vector114>:
.globl vector114
vector114:
  pushl $0
801057ac:	6a 00                	push   $0x0
  pushl $114
801057ae:	6a 72                	push   $0x72
  jmp alltraps
801057b0:	e9 ca f7 ff ff       	jmp    80104f7f <alltraps>

801057b5 <vector115>:
.globl vector115
vector115:
  pushl $0
801057b5:	6a 00                	push   $0x0
  pushl $115
801057b7:	6a 73                	push   $0x73
  jmp alltraps
801057b9:	e9 c1 f7 ff ff       	jmp    80104f7f <alltraps>

801057be <vector116>:
.globl vector116
vector116:
  pushl $0
801057be:	6a 00                	push   $0x0
  pushl $116
801057c0:	6a 74                	push   $0x74
  jmp alltraps
801057c2:	e9 b8 f7 ff ff       	jmp    80104f7f <alltraps>

801057c7 <vector117>:
.globl vector117
vector117:
  pushl $0
801057c7:	6a 00                	push   $0x0
  pushl $117
801057c9:	6a 75                	push   $0x75
  jmp alltraps
801057cb:	e9 af f7 ff ff       	jmp    80104f7f <alltraps>

801057d0 <vector118>:
.globl vector118
vector118:
  pushl $0
801057d0:	6a 00                	push   $0x0
  pushl $118
801057d2:	6a 76                	push   $0x76
  jmp alltraps
801057d4:	e9 a6 f7 ff ff       	jmp    80104f7f <alltraps>

801057d9 <vector119>:
.globl vector119
vector119:
  pushl $0
801057d9:	6a 00                	push   $0x0
  pushl $119
801057db:	6a 77                	push   $0x77
  jmp alltraps
801057dd:	e9 9d f7 ff ff       	jmp    80104f7f <alltraps>

801057e2 <vector120>:
.globl vector120
vector120:
  pushl $0
801057e2:	6a 00                	push   $0x0
  pushl $120
801057e4:	6a 78                	push   $0x78
  jmp alltraps
801057e6:	e9 94 f7 ff ff       	jmp    80104f7f <alltraps>

801057eb <vector121>:
.globl vector121
vector121:
  pushl $0
801057eb:	6a 00                	push   $0x0
  pushl $121
801057ed:	6a 79                	push   $0x79
  jmp alltraps
801057ef:	e9 8b f7 ff ff       	jmp    80104f7f <alltraps>

801057f4 <vector122>:
.globl vector122
vector122:
  pushl $0
801057f4:	6a 00                	push   $0x0
  pushl $122
801057f6:	6a 7a                	push   $0x7a
  jmp alltraps
801057f8:	e9 82 f7 ff ff       	jmp    80104f7f <alltraps>

801057fd <vector123>:
.globl vector123
vector123:
  pushl $0
801057fd:	6a 00                	push   $0x0
  pushl $123
801057ff:	6a 7b                	push   $0x7b
  jmp alltraps
80105801:	e9 79 f7 ff ff       	jmp    80104f7f <alltraps>

80105806 <vector124>:
.globl vector124
vector124:
  pushl $0
80105806:	6a 00                	push   $0x0
  pushl $124
80105808:	6a 7c                	push   $0x7c
  jmp alltraps
8010580a:	e9 70 f7 ff ff       	jmp    80104f7f <alltraps>

8010580f <vector125>:
.globl vector125
vector125:
  pushl $0
8010580f:	6a 00                	push   $0x0
  pushl $125
80105811:	6a 7d                	push   $0x7d
  jmp alltraps
80105813:	e9 67 f7 ff ff       	jmp    80104f7f <alltraps>

80105818 <vector126>:
.globl vector126
vector126:
  pushl $0
80105818:	6a 00                	push   $0x0
  pushl $126
8010581a:	6a 7e                	push   $0x7e
  jmp alltraps
8010581c:	e9 5e f7 ff ff       	jmp    80104f7f <alltraps>

80105821 <vector127>:
.globl vector127
vector127:
  pushl $0
80105821:	6a 00                	push   $0x0
  pushl $127
80105823:	6a 7f                	push   $0x7f
  jmp alltraps
80105825:	e9 55 f7 ff ff       	jmp    80104f7f <alltraps>

8010582a <vector128>:
.globl vector128
vector128:
  pushl $0
8010582a:	6a 00                	push   $0x0
  pushl $128
8010582c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105831:	e9 49 f7 ff ff       	jmp    80104f7f <alltraps>

80105836 <vector129>:
.globl vector129
vector129:
  pushl $0
80105836:	6a 00                	push   $0x0
  pushl $129
80105838:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010583d:	e9 3d f7 ff ff       	jmp    80104f7f <alltraps>

80105842 <vector130>:
.globl vector130
vector130:
  pushl $0
80105842:	6a 00                	push   $0x0
  pushl $130
80105844:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105849:	e9 31 f7 ff ff       	jmp    80104f7f <alltraps>

8010584e <vector131>:
.globl vector131
vector131:
  pushl $0
8010584e:	6a 00                	push   $0x0
  pushl $131
80105850:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105855:	e9 25 f7 ff ff       	jmp    80104f7f <alltraps>

8010585a <vector132>:
.globl vector132
vector132:
  pushl $0
8010585a:	6a 00                	push   $0x0
  pushl $132
8010585c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105861:	e9 19 f7 ff ff       	jmp    80104f7f <alltraps>

80105866 <vector133>:
.globl vector133
vector133:
  pushl $0
80105866:	6a 00                	push   $0x0
  pushl $133
80105868:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010586d:	e9 0d f7 ff ff       	jmp    80104f7f <alltraps>

80105872 <vector134>:
.globl vector134
vector134:
  pushl $0
80105872:	6a 00                	push   $0x0
  pushl $134
80105874:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105879:	e9 01 f7 ff ff       	jmp    80104f7f <alltraps>

8010587e <vector135>:
.globl vector135
vector135:
  pushl $0
8010587e:	6a 00                	push   $0x0
  pushl $135
80105880:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105885:	e9 f5 f6 ff ff       	jmp    80104f7f <alltraps>

8010588a <vector136>:
.globl vector136
vector136:
  pushl $0
8010588a:	6a 00                	push   $0x0
  pushl $136
8010588c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105891:	e9 e9 f6 ff ff       	jmp    80104f7f <alltraps>

80105896 <vector137>:
.globl vector137
vector137:
  pushl $0
80105896:	6a 00                	push   $0x0
  pushl $137
80105898:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010589d:	e9 dd f6 ff ff       	jmp    80104f7f <alltraps>

801058a2 <vector138>:
.globl vector138
vector138:
  pushl $0
801058a2:	6a 00                	push   $0x0
  pushl $138
801058a4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801058a9:	e9 d1 f6 ff ff       	jmp    80104f7f <alltraps>

801058ae <vector139>:
.globl vector139
vector139:
  pushl $0
801058ae:	6a 00                	push   $0x0
  pushl $139
801058b0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801058b5:	e9 c5 f6 ff ff       	jmp    80104f7f <alltraps>

801058ba <vector140>:
.globl vector140
vector140:
  pushl $0
801058ba:	6a 00                	push   $0x0
  pushl $140
801058bc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801058c1:	e9 b9 f6 ff ff       	jmp    80104f7f <alltraps>

801058c6 <vector141>:
.globl vector141
vector141:
  pushl $0
801058c6:	6a 00                	push   $0x0
  pushl $141
801058c8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801058cd:	e9 ad f6 ff ff       	jmp    80104f7f <alltraps>

801058d2 <vector142>:
.globl vector142
vector142:
  pushl $0
801058d2:	6a 00                	push   $0x0
  pushl $142
801058d4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801058d9:	e9 a1 f6 ff ff       	jmp    80104f7f <alltraps>

801058de <vector143>:
.globl vector143
vector143:
  pushl $0
801058de:	6a 00                	push   $0x0
  pushl $143
801058e0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801058e5:	e9 95 f6 ff ff       	jmp    80104f7f <alltraps>

801058ea <vector144>:
.globl vector144
vector144:
  pushl $0
801058ea:	6a 00                	push   $0x0
  pushl $144
801058ec:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801058f1:	e9 89 f6 ff ff       	jmp    80104f7f <alltraps>

801058f6 <vector145>:
.globl vector145
vector145:
  pushl $0
801058f6:	6a 00                	push   $0x0
  pushl $145
801058f8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801058fd:	e9 7d f6 ff ff       	jmp    80104f7f <alltraps>

80105902 <vector146>:
.globl vector146
vector146:
  pushl $0
80105902:	6a 00                	push   $0x0
  pushl $146
80105904:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105909:	e9 71 f6 ff ff       	jmp    80104f7f <alltraps>

8010590e <vector147>:
.globl vector147
vector147:
  pushl $0
8010590e:	6a 00                	push   $0x0
  pushl $147
80105910:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105915:	e9 65 f6 ff ff       	jmp    80104f7f <alltraps>

8010591a <vector148>:
.globl vector148
vector148:
  pushl $0
8010591a:	6a 00                	push   $0x0
  pushl $148
8010591c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105921:	e9 59 f6 ff ff       	jmp    80104f7f <alltraps>

80105926 <vector149>:
.globl vector149
vector149:
  pushl $0
80105926:	6a 00                	push   $0x0
  pushl $149
80105928:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010592d:	e9 4d f6 ff ff       	jmp    80104f7f <alltraps>

80105932 <vector150>:
.globl vector150
vector150:
  pushl $0
80105932:	6a 00                	push   $0x0
  pushl $150
80105934:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105939:	e9 41 f6 ff ff       	jmp    80104f7f <alltraps>

8010593e <vector151>:
.globl vector151
vector151:
  pushl $0
8010593e:	6a 00                	push   $0x0
  pushl $151
80105940:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105945:	e9 35 f6 ff ff       	jmp    80104f7f <alltraps>

8010594a <vector152>:
.globl vector152
vector152:
  pushl $0
8010594a:	6a 00                	push   $0x0
  pushl $152
8010594c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105951:	e9 29 f6 ff ff       	jmp    80104f7f <alltraps>

80105956 <vector153>:
.globl vector153
vector153:
  pushl $0
80105956:	6a 00                	push   $0x0
  pushl $153
80105958:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010595d:	e9 1d f6 ff ff       	jmp    80104f7f <alltraps>

80105962 <vector154>:
.globl vector154
vector154:
  pushl $0
80105962:	6a 00                	push   $0x0
  pushl $154
80105964:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105969:	e9 11 f6 ff ff       	jmp    80104f7f <alltraps>

8010596e <vector155>:
.globl vector155
vector155:
  pushl $0
8010596e:	6a 00                	push   $0x0
  pushl $155
80105970:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105975:	e9 05 f6 ff ff       	jmp    80104f7f <alltraps>

8010597a <vector156>:
.globl vector156
vector156:
  pushl $0
8010597a:	6a 00                	push   $0x0
  pushl $156
8010597c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105981:	e9 f9 f5 ff ff       	jmp    80104f7f <alltraps>

80105986 <vector157>:
.globl vector157
vector157:
  pushl $0
80105986:	6a 00                	push   $0x0
  pushl $157
80105988:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010598d:	e9 ed f5 ff ff       	jmp    80104f7f <alltraps>

80105992 <vector158>:
.globl vector158
vector158:
  pushl $0
80105992:	6a 00                	push   $0x0
  pushl $158
80105994:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105999:	e9 e1 f5 ff ff       	jmp    80104f7f <alltraps>

8010599e <vector159>:
.globl vector159
vector159:
  pushl $0
8010599e:	6a 00                	push   $0x0
  pushl $159
801059a0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801059a5:	e9 d5 f5 ff ff       	jmp    80104f7f <alltraps>

801059aa <vector160>:
.globl vector160
vector160:
  pushl $0
801059aa:	6a 00                	push   $0x0
  pushl $160
801059ac:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801059b1:	e9 c9 f5 ff ff       	jmp    80104f7f <alltraps>

801059b6 <vector161>:
.globl vector161
vector161:
  pushl $0
801059b6:	6a 00                	push   $0x0
  pushl $161
801059b8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801059bd:	e9 bd f5 ff ff       	jmp    80104f7f <alltraps>

801059c2 <vector162>:
.globl vector162
vector162:
  pushl $0
801059c2:	6a 00                	push   $0x0
  pushl $162
801059c4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801059c9:	e9 b1 f5 ff ff       	jmp    80104f7f <alltraps>

801059ce <vector163>:
.globl vector163
vector163:
  pushl $0
801059ce:	6a 00                	push   $0x0
  pushl $163
801059d0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801059d5:	e9 a5 f5 ff ff       	jmp    80104f7f <alltraps>

801059da <vector164>:
.globl vector164
vector164:
  pushl $0
801059da:	6a 00                	push   $0x0
  pushl $164
801059dc:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801059e1:	e9 99 f5 ff ff       	jmp    80104f7f <alltraps>

801059e6 <vector165>:
.globl vector165
vector165:
  pushl $0
801059e6:	6a 00                	push   $0x0
  pushl $165
801059e8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801059ed:	e9 8d f5 ff ff       	jmp    80104f7f <alltraps>

801059f2 <vector166>:
.globl vector166
vector166:
  pushl $0
801059f2:	6a 00                	push   $0x0
  pushl $166
801059f4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801059f9:	e9 81 f5 ff ff       	jmp    80104f7f <alltraps>

801059fe <vector167>:
.globl vector167
vector167:
  pushl $0
801059fe:	6a 00                	push   $0x0
  pushl $167
80105a00:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105a05:	e9 75 f5 ff ff       	jmp    80104f7f <alltraps>

80105a0a <vector168>:
.globl vector168
vector168:
  pushl $0
80105a0a:	6a 00                	push   $0x0
  pushl $168
80105a0c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105a11:	e9 69 f5 ff ff       	jmp    80104f7f <alltraps>

80105a16 <vector169>:
.globl vector169
vector169:
  pushl $0
80105a16:	6a 00                	push   $0x0
  pushl $169
80105a18:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105a1d:	e9 5d f5 ff ff       	jmp    80104f7f <alltraps>

80105a22 <vector170>:
.globl vector170
vector170:
  pushl $0
80105a22:	6a 00                	push   $0x0
  pushl $170
80105a24:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a29:	e9 51 f5 ff ff       	jmp    80104f7f <alltraps>

80105a2e <vector171>:
.globl vector171
vector171:
  pushl $0
80105a2e:	6a 00                	push   $0x0
  pushl $171
80105a30:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a35:	e9 45 f5 ff ff       	jmp    80104f7f <alltraps>

80105a3a <vector172>:
.globl vector172
vector172:
  pushl $0
80105a3a:	6a 00                	push   $0x0
  pushl $172
80105a3c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a41:	e9 39 f5 ff ff       	jmp    80104f7f <alltraps>

80105a46 <vector173>:
.globl vector173
vector173:
  pushl $0
80105a46:	6a 00                	push   $0x0
  pushl $173
80105a48:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a4d:	e9 2d f5 ff ff       	jmp    80104f7f <alltraps>

80105a52 <vector174>:
.globl vector174
vector174:
  pushl $0
80105a52:	6a 00                	push   $0x0
  pushl $174
80105a54:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105a59:	e9 21 f5 ff ff       	jmp    80104f7f <alltraps>

80105a5e <vector175>:
.globl vector175
vector175:
  pushl $0
80105a5e:	6a 00                	push   $0x0
  pushl $175
80105a60:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105a65:	e9 15 f5 ff ff       	jmp    80104f7f <alltraps>

80105a6a <vector176>:
.globl vector176
vector176:
  pushl $0
80105a6a:	6a 00                	push   $0x0
  pushl $176
80105a6c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105a71:	e9 09 f5 ff ff       	jmp    80104f7f <alltraps>

80105a76 <vector177>:
.globl vector177
vector177:
  pushl $0
80105a76:	6a 00                	push   $0x0
  pushl $177
80105a78:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105a7d:	e9 fd f4 ff ff       	jmp    80104f7f <alltraps>

80105a82 <vector178>:
.globl vector178
vector178:
  pushl $0
80105a82:	6a 00                	push   $0x0
  pushl $178
80105a84:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a89:	e9 f1 f4 ff ff       	jmp    80104f7f <alltraps>

80105a8e <vector179>:
.globl vector179
vector179:
  pushl $0
80105a8e:	6a 00                	push   $0x0
  pushl $179
80105a90:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a95:	e9 e5 f4 ff ff       	jmp    80104f7f <alltraps>

80105a9a <vector180>:
.globl vector180
vector180:
  pushl $0
80105a9a:	6a 00                	push   $0x0
  pushl $180
80105a9c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105aa1:	e9 d9 f4 ff ff       	jmp    80104f7f <alltraps>

80105aa6 <vector181>:
.globl vector181
vector181:
  pushl $0
80105aa6:	6a 00                	push   $0x0
  pushl $181
80105aa8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105aad:	e9 cd f4 ff ff       	jmp    80104f7f <alltraps>

80105ab2 <vector182>:
.globl vector182
vector182:
  pushl $0
80105ab2:	6a 00                	push   $0x0
  pushl $182
80105ab4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105ab9:	e9 c1 f4 ff ff       	jmp    80104f7f <alltraps>

80105abe <vector183>:
.globl vector183
vector183:
  pushl $0
80105abe:	6a 00                	push   $0x0
  pushl $183
80105ac0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105ac5:	e9 b5 f4 ff ff       	jmp    80104f7f <alltraps>

80105aca <vector184>:
.globl vector184
vector184:
  pushl $0
80105aca:	6a 00                	push   $0x0
  pushl $184
80105acc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105ad1:	e9 a9 f4 ff ff       	jmp    80104f7f <alltraps>

80105ad6 <vector185>:
.globl vector185
vector185:
  pushl $0
80105ad6:	6a 00                	push   $0x0
  pushl $185
80105ad8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105add:	e9 9d f4 ff ff       	jmp    80104f7f <alltraps>

80105ae2 <vector186>:
.globl vector186
vector186:
  pushl $0
80105ae2:	6a 00                	push   $0x0
  pushl $186
80105ae4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105ae9:	e9 91 f4 ff ff       	jmp    80104f7f <alltraps>

80105aee <vector187>:
.globl vector187
vector187:
  pushl $0
80105aee:	6a 00                	push   $0x0
  pushl $187
80105af0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105af5:	e9 85 f4 ff ff       	jmp    80104f7f <alltraps>

80105afa <vector188>:
.globl vector188
vector188:
  pushl $0
80105afa:	6a 00                	push   $0x0
  pushl $188
80105afc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105b01:	e9 79 f4 ff ff       	jmp    80104f7f <alltraps>

80105b06 <vector189>:
.globl vector189
vector189:
  pushl $0
80105b06:	6a 00                	push   $0x0
  pushl $189
80105b08:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105b0d:	e9 6d f4 ff ff       	jmp    80104f7f <alltraps>

80105b12 <vector190>:
.globl vector190
vector190:
  pushl $0
80105b12:	6a 00                	push   $0x0
  pushl $190
80105b14:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105b19:	e9 61 f4 ff ff       	jmp    80104f7f <alltraps>

80105b1e <vector191>:
.globl vector191
vector191:
  pushl $0
80105b1e:	6a 00                	push   $0x0
  pushl $191
80105b20:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105b25:	e9 55 f4 ff ff       	jmp    80104f7f <alltraps>

80105b2a <vector192>:
.globl vector192
vector192:
  pushl $0
80105b2a:	6a 00                	push   $0x0
  pushl $192
80105b2c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b31:	e9 49 f4 ff ff       	jmp    80104f7f <alltraps>

80105b36 <vector193>:
.globl vector193
vector193:
  pushl $0
80105b36:	6a 00                	push   $0x0
  pushl $193
80105b38:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b3d:	e9 3d f4 ff ff       	jmp    80104f7f <alltraps>

80105b42 <vector194>:
.globl vector194
vector194:
  pushl $0
80105b42:	6a 00                	push   $0x0
  pushl $194
80105b44:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b49:	e9 31 f4 ff ff       	jmp    80104f7f <alltraps>

80105b4e <vector195>:
.globl vector195
vector195:
  pushl $0
80105b4e:	6a 00                	push   $0x0
  pushl $195
80105b50:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105b55:	e9 25 f4 ff ff       	jmp    80104f7f <alltraps>

80105b5a <vector196>:
.globl vector196
vector196:
  pushl $0
80105b5a:	6a 00                	push   $0x0
  pushl $196
80105b5c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105b61:	e9 19 f4 ff ff       	jmp    80104f7f <alltraps>

80105b66 <vector197>:
.globl vector197
vector197:
  pushl $0
80105b66:	6a 00                	push   $0x0
  pushl $197
80105b68:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105b6d:	e9 0d f4 ff ff       	jmp    80104f7f <alltraps>

80105b72 <vector198>:
.globl vector198
vector198:
  pushl $0
80105b72:	6a 00                	push   $0x0
  pushl $198
80105b74:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105b79:	e9 01 f4 ff ff       	jmp    80104f7f <alltraps>

80105b7e <vector199>:
.globl vector199
vector199:
  pushl $0
80105b7e:	6a 00                	push   $0x0
  pushl $199
80105b80:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b85:	e9 f5 f3 ff ff       	jmp    80104f7f <alltraps>

80105b8a <vector200>:
.globl vector200
vector200:
  pushl $0
80105b8a:	6a 00                	push   $0x0
  pushl $200
80105b8c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b91:	e9 e9 f3 ff ff       	jmp    80104f7f <alltraps>

80105b96 <vector201>:
.globl vector201
vector201:
  pushl $0
80105b96:	6a 00                	push   $0x0
  pushl $201
80105b98:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b9d:	e9 dd f3 ff ff       	jmp    80104f7f <alltraps>

80105ba2 <vector202>:
.globl vector202
vector202:
  pushl $0
80105ba2:	6a 00                	push   $0x0
  pushl $202
80105ba4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105ba9:	e9 d1 f3 ff ff       	jmp    80104f7f <alltraps>

80105bae <vector203>:
.globl vector203
vector203:
  pushl $0
80105bae:	6a 00                	push   $0x0
  pushl $203
80105bb0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105bb5:	e9 c5 f3 ff ff       	jmp    80104f7f <alltraps>

80105bba <vector204>:
.globl vector204
vector204:
  pushl $0
80105bba:	6a 00                	push   $0x0
  pushl $204
80105bbc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105bc1:	e9 b9 f3 ff ff       	jmp    80104f7f <alltraps>

80105bc6 <vector205>:
.globl vector205
vector205:
  pushl $0
80105bc6:	6a 00                	push   $0x0
  pushl $205
80105bc8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105bcd:	e9 ad f3 ff ff       	jmp    80104f7f <alltraps>

80105bd2 <vector206>:
.globl vector206
vector206:
  pushl $0
80105bd2:	6a 00                	push   $0x0
  pushl $206
80105bd4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105bd9:	e9 a1 f3 ff ff       	jmp    80104f7f <alltraps>

80105bde <vector207>:
.globl vector207
vector207:
  pushl $0
80105bde:	6a 00                	push   $0x0
  pushl $207
80105be0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105be5:	e9 95 f3 ff ff       	jmp    80104f7f <alltraps>

80105bea <vector208>:
.globl vector208
vector208:
  pushl $0
80105bea:	6a 00                	push   $0x0
  pushl $208
80105bec:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105bf1:	e9 89 f3 ff ff       	jmp    80104f7f <alltraps>

80105bf6 <vector209>:
.globl vector209
vector209:
  pushl $0
80105bf6:	6a 00                	push   $0x0
  pushl $209
80105bf8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105bfd:	e9 7d f3 ff ff       	jmp    80104f7f <alltraps>

80105c02 <vector210>:
.globl vector210
vector210:
  pushl $0
80105c02:	6a 00                	push   $0x0
  pushl $210
80105c04:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105c09:	e9 71 f3 ff ff       	jmp    80104f7f <alltraps>

80105c0e <vector211>:
.globl vector211
vector211:
  pushl $0
80105c0e:	6a 00                	push   $0x0
  pushl $211
80105c10:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105c15:	e9 65 f3 ff ff       	jmp    80104f7f <alltraps>

80105c1a <vector212>:
.globl vector212
vector212:
  pushl $0
80105c1a:	6a 00                	push   $0x0
  pushl $212
80105c1c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105c21:	e9 59 f3 ff ff       	jmp    80104f7f <alltraps>

80105c26 <vector213>:
.globl vector213
vector213:
  pushl $0
80105c26:	6a 00                	push   $0x0
  pushl $213
80105c28:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c2d:	e9 4d f3 ff ff       	jmp    80104f7f <alltraps>

80105c32 <vector214>:
.globl vector214
vector214:
  pushl $0
80105c32:	6a 00                	push   $0x0
  pushl $214
80105c34:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c39:	e9 41 f3 ff ff       	jmp    80104f7f <alltraps>

80105c3e <vector215>:
.globl vector215
vector215:
  pushl $0
80105c3e:	6a 00                	push   $0x0
  pushl $215
80105c40:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c45:	e9 35 f3 ff ff       	jmp    80104f7f <alltraps>

80105c4a <vector216>:
.globl vector216
vector216:
  pushl $0
80105c4a:	6a 00                	push   $0x0
  pushl $216
80105c4c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c51:	e9 29 f3 ff ff       	jmp    80104f7f <alltraps>

80105c56 <vector217>:
.globl vector217
vector217:
  pushl $0
80105c56:	6a 00                	push   $0x0
  pushl $217
80105c58:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105c5d:	e9 1d f3 ff ff       	jmp    80104f7f <alltraps>

80105c62 <vector218>:
.globl vector218
vector218:
  pushl $0
80105c62:	6a 00                	push   $0x0
  pushl $218
80105c64:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105c69:	e9 11 f3 ff ff       	jmp    80104f7f <alltraps>

80105c6e <vector219>:
.globl vector219
vector219:
  pushl $0
80105c6e:	6a 00                	push   $0x0
  pushl $219
80105c70:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105c75:	e9 05 f3 ff ff       	jmp    80104f7f <alltraps>

80105c7a <vector220>:
.globl vector220
vector220:
  pushl $0
80105c7a:	6a 00                	push   $0x0
  pushl $220
80105c7c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c81:	e9 f9 f2 ff ff       	jmp    80104f7f <alltraps>

80105c86 <vector221>:
.globl vector221
vector221:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $221
80105c88:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c8d:	e9 ed f2 ff ff       	jmp    80104f7f <alltraps>

80105c92 <vector222>:
.globl vector222
vector222:
  pushl $0
80105c92:	6a 00                	push   $0x0
  pushl $222
80105c94:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c99:	e9 e1 f2 ff ff       	jmp    80104f7f <alltraps>

80105c9e <vector223>:
.globl vector223
vector223:
  pushl $0
80105c9e:	6a 00                	push   $0x0
  pushl $223
80105ca0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105ca5:	e9 d5 f2 ff ff       	jmp    80104f7f <alltraps>

80105caa <vector224>:
.globl vector224
vector224:
  pushl $0
80105caa:	6a 00                	push   $0x0
  pushl $224
80105cac:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105cb1:	e9 c9 f2 ff ff       	jmp    80104f7f <alltraps>

80105cb6 <vector225>:
.globl vector225
vector225:
  pushl $0
80105cb6:	6a 00                	push   $0x0
  pushl $225
80105cb8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105cbd:	e9 bd f2 ff ff       	jmp    80104f7f <alltraps>

80105cc2 <vector226>:
.globl vector226
vector226:
  pushl $0
80105cc2:	6a 00                	push   $0x0
  pushl $226
80105cc4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105cc9:	e9 b1 f2 ff ff       	jmp    80104f7f <alltraps>

80105cce <vector227>:
.globl vector227
vector227:
  pushl $0
80105cce:	6a 00                	push   $0x0
  pushl $227
80105cd0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105cd5:	e9 a5 f2 ff ff       	jmp    80104f7f <alltraps>

80105cda <vector228>:
.globl vector228
vector228:
  pushl $0
80105cda:	6a 00                	push   $0x0
  pushl $228
80105cdc:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105ce1:	e9 99 f2 ff ff       	jmp    80104f7f <alltraps>

80105ce6 <vector229>:
.globl vector229
vector229:
  pushl $0
80105ce6:	6a 00                	push   $0x0
  pushl $229
80105ce8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105ced:	e9 8d f2 ff ff       	jmp    80104f7f <alltraps>

80105cf2 <vector230>:
.globl vector230
vector230:
  pushl $0
80105cf2:	6a 00                	push   $0x0
  pushl $230
80105cf4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105cf9:	e9 81 f2 ff ff       	jmp    80104f7f <alltraps>

80105cfe <vector231>:
.globl vector231
vector231:
  pushl $0
80105cfe:	6a 00                	push   $0x0
  pushl $231
80105d00:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105d05:	e9 75 f2 ff ff       	jmp    80104f7f <alltraps>

80105d0a <vector232>:
.globl vector232
vector232:
  pushl $0
80105d0a:	6a 00                	push   $0x0
  pushl $232
80105d0c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105d11:	e9 69 f2 ff ff       	jmp    80104f7f <alltraps>

80105d16 <vector233>:
.globl vector233
vector233:
  pushl $0
80105d16:	6a 00                	push   $0x0
  pushl $233
80105d18:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105d1d:	e9 5d f2 ff ff       	jmp    80104f7f <alltraps>

80105d22 <vector234>:
.globl vector234
vector234:
  pushl $0
80105d22:	6a 00                	push   $0x0
  pushl $234
80105d24:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d29:	e9 51 f2 ff ff       	jmp    80104f7f <alltraps>

80105d2e <vector235>:
.globl vector235
vector235:
  pushl $0
80105d2e:	6a 00                	push   $0x0
  pushl $235
80105d30:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d35:	e9 45 f2 ff ff       	jmp    80104f7f <alltraps>

80105d3a <vector236>:
.globl vector236
vector236:
  pushl $0
80105d3a:	6a 00                	push   $0x0
  pushl $236
80105d3c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d41:	e9 39 f2 ff ff       	jmp    80104f7f <alltraps>

80105d46 <vector237>:
.globl vector237
vector237:
  pushl $0
80105d46:	6a 00                	push   $0x0
  pushl $237
80105d48:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d4d:	e9 2d f2 ff ff       	jmp    80104f7f <alltraps>

80105d52 <vector238>:
.globl vector238
vector238:
  pushl $0
80105d52:	6a 00                	push   $0x0
  pushl $238
80105d54:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105d59:	e9 21 f2 ff ff       	jmp    80104f7f <alltraps>

80105d5e <vector239>:
.globl vector239
vector239:
  pushl $0
80105d5e:	6a 00                	push   $0x0
  pushl $239
80105d60:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105d65:	e9 15 f2 ff ff       	jmp    80104f7f <alltraps>

80105d6a <vector240>:
.globl vector240
vector240:
  pushl $0
80105d6a:	6a 00                	push   $0x0
  pushl $240
80105d6c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105d71:	e9 09 f2 ff ff       	jmp    80104f7f <alltraps>

80105d76 <vector241>:
.globl vector241
vector241:
  pushl $0
80105d76:	6a 00                	push   $0x0
  pushl $241
80105d78:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105d7d:	e9 fd f1 ff ff       	jmp    80104f7f <alltraps>

80105d82 <vector242>:
.globl vector242
vector242:
  pushl $0
80105d82:	6a 00                	push   $0x0
  pushl $242
80105d84:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d89:	e9 f1 f1 ff ff       	jmp    80104f7f <alltraps>

80105d8e <vector243>:
.globl vector243
vector243:
  pushl $0
80105d8e:	6a 00                	push   $0x0
  pushl $243
80105d90:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d95:	e9 e5 f1 ff ff       	jmp    80104f7f <alltraps>

80105d9a <vector244>:
.globl vector244
vector244:
  pushl $0
80105d9a:	6a 00                	push   $0x0
  pushl $244
80105d9c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105da1:	e9 d9 f1 ff ff       	jmp    80104f7f <alltraps>

80105da6 <vector245>:
.globl vector245
vector245:
  pushl $0
80105da6:	6a 00                	push   $0x0
  pushl $245
80105da8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105dad:	e9 cd f1 ff ff       	jmp    80104f7f <alltraps>

80105db2 <vector246>:
.globl vector246
vector246:
  pushl $0
80105db2:	6a 00                	push   $0x0
  pushl $246
80105db4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105db9:	e9 c1 f1 ff ff       	jmp    80104f7f <alltraps>

80105dbe <vector247>:
.globl vector247
vector247:
  pushl $0
80105dbe:	6a 00                	push   $0x0
  pushl $247
80105dc0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105dc5:	e9 b5 f1 ff ff       	jmp    80104f7f <alltraps>

80105dca <vector248>:
.globl vector248
vector248:
  pushl $0
80105dca:	6a 00                	push   $0x0
  pushl $248
80105dcc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105dd1:	e9 a9 f1 ff ff       	jmp    80104f7f <alltraps>

80105dd6 <vector249>:
.globl vector249
vector249:
  pushl $0
80105dd6:	6a 00                	push   $0x0
  pushl $249
80105dd8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105ddd:	e9 9d f1 ff ff       	jmp    80104f7f <alltraps>

80105de2 <vector250>:
.globl vector250
vector250:
  pushl $0
80105de2:	6a 00                	push   $0x0
  pushl $250
80105de4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105de9:	e9 91 f1 ff ff       	jmp    80104f7f <alltraps>

80105dee <vector251>:
.globl vector251
vector251:
  pushl $0
80105dee:	6a 00                	push   $0x0
  pushl $251
80105df0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105df5:	e9 85 f1 ff ff       	jmp    80104f7f <alltraps>

80105dfa <vector252>:
.globl vector252
vector252:
  pushl $0
80105dfa:	6a 00                	push   $0x0
  pushl $252
80105dfc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105e01:	e9 79 f1 ff ff       	jmp    80104f7f <alltraps>

80105e06 <vector253>:
.globl vector253
vector253:
  pushl $0
80105e06:	6a 00                	push   $0x0
  pushl $253
80105e08:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105e0d:	e9 6d f1 ff ff       	jmp    80104f7f <alltraps>

80105e12 <vector254>:
.globl vector254
vector254:
  pushl $0
80105e12:	6a 00                	push   $0x0
  pushl $254
80105e14:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105e19:	e9 61 f1 ff ff       	jmp    80104f7f <alltraps>

80105e1e <vector255>:
.globl vector255
vector255:
  pushl $0
80105e1e:	6a 00                	push   $0x0
  pushl $255
80105e20:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105e25:	e9 55 f1 ff ff       	jmp    80104f7f <alltraps>

80105e2a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e2a:	55                   	push   %ebp
80105e2b:	89 e5                	mov    %esp,%ebp
80105e2d:	57                   	push   %edi
80105e2e:	56                   	push   %esi
80105e2f:	53                   	push   %ebx
80105e30:	83 ec 0c             	sub    $0xc,%esp
80105e33:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e35:	c1 ea 16             	shr    $0x16,%edx
80105e38:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105e3b:	8b 1f                	mov    (%edi),%ebx
80105e3d:	f6 c3 01             	test   $0x1,%bl
80105e40:	74 37                	je     80105e79 <walkpgdir+0x4f>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105e42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
80105e48:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80105e4e:	77 1c                	ja     80105e6c <walkpgdir+0x42>
    return (char*)a + KERNBASE;
80105e50:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e56:	c1 ee 0c             	shr    $0xc,%esi
80105e59:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105e5f:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105e62:	89 d8                	mov    %ebx,%eax
80105e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e67:	5b                   	pop    %ebx
80105e68:	5e                   	pop    %esi
80105e69:	5f                   	pop    %edi
80105e6a:	5d                   	pop    %ebp
80105e6b:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	68 78 6d 10 80       	push   $0x80106d78
80105e74:	e8 cf a4 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105e79:	85 c9                	test   %ecx,%ecx
80105e7b:	74 40                	je     80105ebd <walkpgdir+0x93>
80105e7d:	e8 4d c2 ff ff       	call   801020cf <kalloc>
80105e82:	89 c3                	mov    %eax,%ebx
80105e84:	85 c0                	test   %eax,%eax
80105e86:	74 da                	je     80105e62 <walkpgdir+0x38>
    memset(pgtab, 0, PGSIZE);
80105e88:	83 ec 04             	sub    $0x4,%esp
80105e8b:	68 00 10 00 00       	push   $0x1000
80105e90:	6a 00                	push   $0x0
80105e92:	50                   	push   %eax
80105e93:	e8 88 df ff ff       	call   80103e20 <memset>
    if (a < (void*) KERNBASE)
80105e98:	83 c4 10             	add    $0x10,%esp
80105e9b:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80105ea1:	76 0d                	jbe    80105eb0 <walkpgdir+0x86>
    return (uint)a - KERNBASE;
80105ea3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ea9:	83 c8 07             	or     $0x7,%eax
80105eac:	89 07                	mov    %eax,(%edi)
80105eae:	eb a6                	jmp    80105e56 <walkpgdir+0x2c>
        panic("V2P on address < KERNBASE "
80105eb0:	83 ec 0c             	sub    $0xc,%esp
80105eb3:	68 48 6a 10 80       	push   $0x80106a48
80105eb8:	e8 8b a4 ff ff       	call   80100348 <panic>
      return 0;
80105ebd:	bb 00 00 00 00       	mov    $0x0,%ebx
80105ec2:	eb 9e                	jmp    80105e62 <walkpgdir+0x38>

80105ec4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105ec4:	55                   	push   %ebp
80105ec5:	89 e5                	mov    %esp,%ebp
80105ec7:	57                   	push   %edi
80105ec8:	56                   	push   %esi
80105ec9:	53                   	push   %ebx
80105eca:	83 ec 1c             	sub    $0x1c,%esp
80105ecd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ed0:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ed3:	89 d3                	mov    %edx,%ebx
80105ed5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105edb:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105edf:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ee5:	b9 01 00 00 00       	mov    $0x1,%ecx
80105eea:	89 da                	mov    %ebx,%edx
80105eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eef:	e8 36 ff ff ff       	call   80105e2a <walkpgdir>
80105ef4:	85 c0                	test   %eax,%eax
80105ef6:	74 2e                	je     80105f26 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105ef8:	f6 00 01             	testb  $0x1,(%eax)
80105efb:	75 1c                	jne    80105f19 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105efd:	89 f2                	mov    %esi,%edx
80105eff:	0b 55 0c             	or     0xc(%ebp),%edx
80105f02:	83 ca 01             	or     $0x1,%edx
80105f05:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105f07:	39 fb                	cmp    %edi,%ebx
80105f09:	74 28                	je     80105f33 <mappages+0x6f>
      break;
    a += PGSIZE;
80105f0b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105f11:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f17:	eb cc                	jmp    80105ee5 <mappages+0x21>
      panic("remap");
80105f19:	83 ec 0c             	sub    $0xc,%esp
80105f1c:	68 a0 71 10 80       	push   $0x801071a0
80105f21:	e8 22 a4 ff ff       	call   80100348 <panic>
      return -1;
80105f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f2e:	5b                   	pop    %ebx
80105f2f:	5e                   	pop    %esi
80105f30:	5f                   	pop    %edi
80105f31:	5d                   	pop    %ebp
80105f32:	c3                   	ret    
  return 0;
80105f33:	b8 00 00 00 00       	mov    $0x0,%eax
80105f38:	eb f1                	jmp    80105f2b <mappages+0x67>

80105f3a <seginit>:
{
80105f3a:	55                   	push   %ebp
80105f3b:	89 e5                	mov    %esp,%ebp
80105f3d:	53                   	push   %ebx
80105f3e:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105f41:	e8 42 d3 ff ff       	call   80103288 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f46:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f4c:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
80105f53:	ff ff 
80105f55:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80105f5c:	00 00 
80105f5e:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
80105f65:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
80105f6c:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f6f:	83 c9 1a             	or     $0x1a,%ecx
80105f72:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f75:	83 c9 80             	or     $0xffffff80,%ecx
80105f78:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
80105f7e:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
80105f85:	83 c9 0f             	or     $0xf,%ecx
80105f88:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f8b:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f8e:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
80105f94:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105f9b:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
80105fa2:	ff ff 
80105fa4:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
80105fab:	00 00 
80105fad:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80105fb4:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
80105fbb:	83 e1 f0             	and    $0xfffffff0,%ecx
80105fbe:	83 c9 12             	or     $0x12,%ecx
80105fc1:	83 e1 9f             	and    $0xffffff9f,%ecx
80105fc4:	83 c9 80             	or     $0xffffff80,%ecx
80105fc7:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80105fcd:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80105fd4:	83 c9 0f             	or     $0xf,%ecx
80105fd7:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fda:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fdd:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
80105fe3:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105fea:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80105ff1:	ff ff 
80105ff3:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
80105ffa:	00 00 
80105ffc:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
80106003:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
8010600a:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
80106011:	83 c9 0f             	or     $0xf,%ecx
80106014:	83 e1 cf             	and    $0xffffffcf,%ecx
80106017:	83 c9 c0             	or     $0xffffffc0,%ecx
8010601a:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
80106020:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106027:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
8010602e:	ff ff 
80106030:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
80106037:	00 00 
80106039:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
80106040:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
80106047:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
8010604e:	83 c9 0f             	or     $0xf,%ecx
80106051:	83 e1 cf             	and    $0xffffffcf,%ecx
80106054:	83 c9 c0             	or     $0xffffffc0,%ecx
80106057:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
8010605d:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106064:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
80106069:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
8010606f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106073:	c1 e8 10             	shr    $0x10,%eax
80106076:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010607a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010607d:	0f 01 10             	lgdtl  (%eax)
}
80106080:	83 c4 14             	add    $0x14,%esp
80106083:	5b                   	pop    %ebx
80106084:	5d                   	pop    %ebp
80106085:	c3                   	ret    

80106086 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106086:	a1 a4 56 11 80       	mov    0x801156a4,%eax
    if (a < (void*) KERNBASE)
8010608b:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106090:	76 09                	jbe    8010609b <switchkvm+0x15>
    return (uint)a - KERNBASE;
80106092:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106097:	0f 22 d8             	mov    %eax,%cr3
8010609a:	c3                   	ret    
{
8010609b:	55                   	push   %ebp
8010609c:	89 e5                	mov    %esp,%ebp
8010609e:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
801060a1:	68 48 6a 10 80       	push   $0x80106a48
801060a6:	e8 9d a2 ff ff       	call   80100348 <panic>

801060ab <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801060ab:	55                   	push   %ebp
801060ac:	89 e5                	mov    %esp,%ebp
801060ae:	57                   	push   %edi
801060af:	56                   	push   %esi
801060b0:	53                   	push   %ebx
801060b1:	83 ec 1c             	sub    $0x1c,%esp
801060b4:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801060b7:	85 f6                	test   %esi,%esi
801060b9:	0f 84 e4 00 00 00    	je     801061a3 <switchuvm+0xf8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801060bf:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801060c3:	0f 84 e7 00 00 00    	je     801061b0 <switchuvm+0x105>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801060c9:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801060cd:	0f 84 ea 00 00 00    	je     801061bd <switchuvm+0x112>
    panic("switchuvm: no pgdir");

  pushcli();
801060d3:	e8 bf db ff ff       	call   80103c97 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801060d8:	e8 4f d1 ff ff       	call   8010322c <mycpu>
801060dd:	89 c3                	mov    %eax,%ebx
801060df:	e8 48 d1 ff ff       	call   8010322c <mycpu>
801060e4:	8d 78 08             	lea    0x8(%eax),%edi
801060e7:	e8 40 d1 ff ff       	call   8010322c <mycpu>
801060ec:	83 c0 08             	add    $0x8,%eax
801060ef:	c1 e8 10             	shr    $0x10,%eax
801060f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060f5:	e8 32 d1 ff ff       	call   8010322c <mycpu>
801060fa:	83 c0 08             	add    $0x8,%eax
801060fd:	c1 e8 18             	shr    $0x18,%eax
80106100:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106107:	67 00 
80106109:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106110:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106114:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010611a:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106121:	83 e2 f0             	and    $0xfffffff0,%edx
80106124:	83 ca 19             	or     $0x19,%edx
80106127:	83 e2 9f             	and    $0xffffff9f,%edx
8010612a:	83 ca 80             	or     $0xffffff80,%edx
8010612d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106133:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
8010613a:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106140:	e8 e7 d0 ff ff       	call   8010322c <mycpu>
80106145:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010614c:	83 e2 ef             	and    $0xffffffef,%edx
8010614f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106155:	e8 d2 d0 ff ff       	call   8010322c <mycpu>
8010615a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106160:	8b 5e 08             	mov    0x8(%esi),%ebx
80106163:	e8 c4 d0 ff ff       	call   8010322c <mycpu>
80106168:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010616e:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106171:	e8 b6 d0 ff ff       	call   8010322c <mycpu>
80106176:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010617c:	b8 28 00 00 00       	mov    $0x28,%eax
80106181:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106184:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
80106187:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010618c:	76 3c                	jbe    801061ca <switchuvm+0x11f>
    return (uint)a - KERNBASE;
8010618e:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106193:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106196:	e8 39 db ff ff       	call   80103cd4 <popcli>
}
8010619b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010619e:	5b                   	pop    %ebx
8010619f:	5e                   	pop    %esi
801061a0:	5f                   	pop    %edi
801061a1:	5d                   	pop    %ebp
801061a2:	c3                   	ret    
    panic("switchuvm: no process");
801061a3:	83 ec 0c             	sub    $0xc,%esp
801061a6:	68 a6 71 10 80       	push   $0x801071a6
801061ab:	e8 98 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801061b0:	83 ec 0c             	sub    $0xc,%esp
801061b3:	68 bc 71 10 80       	push   $0x801071bc
801061b8:	e8 8b a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801061bd:	83 ec 0c             	sub    $0xc,%esp
801061c0:	68 d1 71 10 80       	push   $0x801071d1
801061c5:	e8 7e a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801061ca:	83 ec 0c             	sub    $0xc,%esp
801061cd:	68 48 6a 10 80       	push   $0x80106a48
801061d2:	e8 71 a1 ff ff       	call   80100348 <panic>

801061d7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061d7:	55                   	push   %ebp
801061d8:	89 e5                	mov    %esp,%ebp
801061da:	56                   	push   %esi
801061db:	53                   	push   %ebx
801061dc:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061df:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061e5:	77 57                	ja     8010623e <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
801061e7:	e8 e3 be ff ff       	call   801020cf <kalloc>
801061ec:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061ee:	83 ec 04             	sub    $0x4,%esp
801061f1:	68 00 10 00 00       	push   $0x1000
801061f6:	6a 00                	push   $0x0
801061f8:	50                   	push   %eax
801061f9:	e8 22 dc ff ff       	call   80103e20 <memset>
    if (a < (void*) KERNBASE)
801061fe:	83 c4 10             	add    $0x10,%esp
80106201:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106207:	76 42                	jbe    8010624b <inituvm+0x74>
    return (uint)a - KERNBASE;
80106209:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010620f:	83 ec 08             	sub    $0x8,%esp
80106212:	6a 06                	push   $0x6
80106214:	50                   	push   %eax
80106215:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010621a:	ba 00 00 00 00       	mov    $0x0,%edx
8010621f:	8b 45 08             	mov    0x8(%ebp),%eax
80106222:	e8 9d fc ff ff       	call   80105ec4 <mappages>
  memmove(mem, init, sz);
80106227:	83 c4 0c             	add    $0xc,%esp
8010622a:	56                   	push   %esi
8010622b:	ff 75 0c             	pushl  0xc(%ebp)
8010622e:	53                   	push   %ebx
8010622f:	e8 67 dc ff ff       	call   80103e9b <memmove>
}
80106234:	83 c4 10             	add    $0x10,%esp
80106237:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010623a:	5b                   	pop    %ebx
8010623b:	5e                   	pop    %esi
8010623c:	5d                   	pop    %ebp
8010623d:	c3                   	ret    
    panic("inituvm: more than a page");
8010623e:	83 ec 0c             	sub    $0xc,%esp
80106241:	68 e5 71 10 80       	push   $0x801071e5
80106246:	e8 fd a0 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010624b:	83 ec 0c             	sub    $0xc,%esp
8010624e:	68 48 6a 10 80       	push   $0x80106a48
80106253:	e8 f0 a0 ff ff       	call   80100348 <panic>

80106258 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106258:	55                   	push   %ebp
80106259:	89 e5                	mov    %esp,%ebp
8010625b:	57                   	push   %edi
8010625c:	56                   	push   %esi
8010625d:	53                   	push   %ebx
8010625e:	83 ec 0c             	sub    $0xc,%esp
80106261:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106264:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010626b:	75 07                	jne    80106274 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010626d:	bb 00 00 00 00       	mov    $0x0,%ebx
80106272:	eb 43                	jmp    801062b7 <loaduvm+0x5f>
    panic("loaduvm: addr must be page aligned");
80106274:	83 ec 0c             	sub    $0xc,%esp
80106277:	68 a0 72 10 80       	push   $0x801072a0
8010627c:	e8 c7 a0 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106281:	83 ec 0c             	sub    $0xc,%esp
80106284:	68 ff 71 10 80       	push   $0x801071ff
80106289:	e8 ba a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010628e:	89 da                	mov    %ebx,%edx
80106290:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
80106293:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106298:	77 51                	ja     801062eb <loaduvm+0x93>
    return (char*)a + KERNBASE;
8010629a:	05 00 00 00 80       	add    $0x80000000,%eax
8010629f:	56                   	push   %esi
801062a0:	52                   	push   %edx
801062a1:	50                   	push   %eax
801062a2:	ff 75 10             	pushl  0x10(%ebp)
801062a5:	e8 b7 b4 ff ff       	call   80101761 <readi>
801062aa:	83 c4 10             	add    $0x10,%esp
801062ad:	39 f0                	cmp    %esi,%eax
801062af:	75 54                	jne    80106305 <loaduvm+0xad>
  for(i = 0; i < sz; i += PGSIZE){
801062b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062b7:	39 fb                	cmp    %edi,%ebx
801062b9:	73 3d                	jae    801062f8 <loaduvm+0xa0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801062bb:	89 da                	mov    %ebx,%edx
801062bd:	03 55 0c             	add    0xc(%ebp),%edx
801062c0:	b9 00 00 00 00       	mov    $0x0,%ecx
801062c5:	8b 45 08             	mov    0x8(%ebp),%eax
801062c8:	e8 5d fb ff ff       	call   80105e2a <walkpgdir>
801062cd:	85 c0                	test   %eax,%eax
801062cf:	74 b0                	je     80106281 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801062d1:	8b 00                	mov    (%eax),%eax
801062d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062d8:	89 fe                	mov    %edi,%esi
801062da:	29 de                	sub    %ebx,%esi
801062dc:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062e2:	76 aa                	jbe    8010628e <loaduvm+0x36>
      n = PGSIZE;
801062e4:	be 00 10 00 00       	mov    $0x1000,%esi
801062e9:	eb a3                	jmp    8010628e <loaduvm+0x36>
        panic("P2V on address > KERNBASE");
801062eb:	83 ec 0c             	sub    $0xc,%esp
801062ee:	68 78 6d 10 80       	push   $0x80106d78
801062f3:	e8 50 a0 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
801062f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106300:	5b                   	pop    %ebx
80106301:	5e                   	pop    %esi
80106302:	5f                   	pop    %edi
80106303:	5d                   	pop    %ebp
80106304:	c3                   	ret    
      return -1;
80106305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630a:	eb f1                	jmp    801062fd <loaduvm+0xa5>

8010630c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010630c:	55                   	push   %ebp
8010630d:	89 e5                	mov    %esp,%ebp
8010630f:	57                   	push   %edi
80106310:	56                   	push   %esi
80106311:	53                   	push   %ebx
80106312:	83 ec 0c             	sub    $0xc,%esp
80106315:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106318:	39 7d 10             	cmp    %edi,0x10(%ebp)
8010631b:	73 11                	jae    8010632e <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010631d:	8b 45 10             	mov    0x10(%ebp),%eax
80106320:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106326:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010632c:	eb 19                	jmp    80106347 <deallocuvm+0x3b>
    return oldsz;
8010632e:	89 f8                	mov    %edi,%eax
80106330:	eb 78                	jmp    801063aa <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106332:	c1 eb 16             	shr    $0x16,%ebx
80106335:	83 c3 01             	add    $0x1,%ebx
80106338:	c1 e3 16             	shl    $0x16,%ebx
8010633b:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106341:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106347:	39 fb                	cmp    %edi,%ebx
80106349:	73 5c                	jae    801063a7 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010634b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106350:	89 da                	mov    %ebx,%edx
80106352:	8b 45 08             	mov    0x8(%ebp),%eax
80106355:	e8 d0 fa ff ff       	call   80105e2a <walkpgdir>
8010635a:	89 c6                	mov    %eax,%esi
    if(!pte)
8010635c:	85 c0                	test   %eax,%eax
8010635e:	74 d2                	je     80106332 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106360:	8b 00                	mov    (%eax),%eax
80106362:	a8 01                	test   $0x1,%al
80106364:	74 db                	je     80106341 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010636b:	74 20                	je     8010638d <deallocuvm+0x81>
    if (a > KERNBASE)
8010636d:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106372:	77 26                	ja     8010639a <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
80106374:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106379:	83 ec 0c             	sub    $0xc,%esp
8010637c:	50                   	push   %eax
8010637d:	e8 10 bc ff ff       	call   80101f92 <kfree>
      *pte = 0;
80106382:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106388:	83 c4 10             	add    $0x10,%esp
8010638b:	eb b4                	jmp    80106341 <deallocuvm+0x35>
        panic("kfree");
8010638d:	83 ec 0c             	sub    $0xc,%esp
80106390:	68 d6 6a 10 80       	push   $0x80106ad6
80106395:	e8 ae 9f ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
8010639a:	83 ec 0c             	sub    $0xc,%esp
8010639d:	68 78 6d 10 80       	push   $0x80106d78
801063a2:	e8 a1 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801063a7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801063aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063ad:	5b                   	pop    %ebx
801063ae:	5e                   	pop    %esi
801063af:	5f                   	pop    %edi
801063b0:	5d                   	pop    %ebp
801063b1:	c3                   	ret    

801063b2 <allocuvm>:
{
801063b2:	55                   	push   %ebp
801063b3:	89 e5                	mov    %esp,%ebp
801063b5:	57                   	push   %edi
801063b6:	56                   	push   %esi
801063b7:	53                   	push   %ebx
801063b8:	83 ec 1c             	sub    $0x1c,%esp
801063bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801063be:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801063c1:	85 ff                	test   %edi,%edi
801063c3:	0f 88 d9 00 00 00    	js     801064a2 <allocuvm+0xf0>
  if(newsz < oldsz)
801063c9:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063cc:	72 67                	jb     80106435 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
801063ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801063d1:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801063d7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801063dd:	39 fe                	cmp    %edi,%esi
801063df:	0f 83 c4 00 00 00    	jae    801064a9 <allocuvm+0xf7>
    mem = kalloc();
801063e5:	e8 e5 bc ff ff       	call   801020cf <kalloc>
801063ea:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801063ec:	85 c0                	test   %eax,%eax
801063ee:	74 4d                	je     8010643d <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
801063f0:	83 ec 04             	sub    $0x4,%esp
801063f3:	68 00 10 00 00       	push   $0x1000
801063f8:	6a 00                	push   $0x0
801063fa:	50                   	push   %eax
801063fb:	e8 20 da ff ff       	call   80103e20 <memset>
    if (a < (void*) KERNBASE)
80106400:	83 c4 10             	add    $0x10,%esp
80106403:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106409:	76 5a                	jbe    80106465 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
8010640b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106411:	83 ec 08             	sub    $0x8,%esp
80106414:	6a 06                	push   $0x6
80106416:	50                   	push   %eax
80106417:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010641c:	89 f2                	mov    %esi,%edx
8010641e:	8b 45 08             	mov    0x8(%ebp),%eax
80106421:	e8 9e fa ff ff       	call   80105ec4 <mappages>
80106426:	83 c4 10             	add    $0x10,%esp
80106429:	85 c0                	test   %eax,%eax
8010642b:	78 45                	js     80106472 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
8010642d:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106433:	eb a8                	jmp    801063dd <allocuvm+0x2b>
    return oldsz;
80106435:	8b 45 0c             	mov    0xc(%ebp),%eax
80106438:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010643b:	eb 6c                	jmp    801064a9 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
8010643d:	83 ec 0c             	sub    $0xc,%esp
80106440:	68 1d 72 10 80       	push   $0x8010721d
80106445:	e8 c1 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010644a:	83 c4 0c             	add    $0xc,%esp
8010644d:	ff 75 0c             	pushl  0xc(%ebp)
80106450:	57                   	push   %edi
80106451:	ff 75 08             	pushl  0x8(%ebp)
80106454:	e8 b3 fe ff ff       	call   8010630c <deallocuvm>
      return 0;
80106459:	83 c4 10             	add    $0x10,%esp
8010645c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106463:	eb 44                	jmp    801064a9 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
80106465:	83 ec 0c             	sub    $0xc,%esp
80106468:	68 48 6a 10 80       	push   $0x80106a48
8010646d:	e8 d6 9e ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
80106472:	83 ec 0c             	sub    $0xc,%esp
80106475:	68 35 72 10 80       	push   $0x80107235
8010647a:	e8 8c a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010647f:	83 c4 0c             	add    $0xc,%esp
80106482:	ff 75 0c             	pushl  0xc(%ebp)
80106485:	57                   	push   %edi
80106486:	ff 75 08             	pushl  0x8(%ebp)
80106489:	e8 7e fe ff ff       	call   8010630c <deallocuvm>
      kfree(mem);
8010648e:	89 1c 24             	mov    %ebx,(%esp)
80106491:	e8 fc ba ff ff       	call   80101f92 <kfree>
      return 0;
80106496:	83 c4 10             	add    $0x10,%esp
80106499:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801064a0:	eb 07                	jmp    801064a9 <allocuvm+0xf7>
    return 0;
801064a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801064a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064af:	5b                   	pop    %ebx
801064b0:	5e                   	pop    %esi
801064b1:	5f                   	pop    %edi
801064b2:	5d                   	pop    %ebp
801064b3:	c3                   	ret    

801064b4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801064b4:	55                   	push   %ebp
801064b5:	89 e5                	mov    %esp,%ebp
801064b7:	56                   	push   %esi
801064b8:	53                   	push   %ebx
801064b9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801064bc:	85 f6                	test   %esi,%esi
801064be:	74 1a                	je     801064da <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801064c0:	83 ec 04             	sub    $0x4,%esp
801064c3:	6a 00                	push   $0x0
801064c5:	68 00 00 00 80       	push   $0x80000000
801064ca:	56                   	push   %esi
801064cb:	e8 3c fe ff ff       	call   8010630c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801064d0:	83 c4 10             	add    $0x10,%esp
801064d3:	bb 00 00 00 00       	mov    $0x0,%ebx
801064d8:	eb 1d                	jmp    801064f7 <freevm+0x43>
    panic("freevm: no pgdir");
801064da:	83 ec 0c             	sub    $0xc,%esp
801064dd:	68 51 72 10 80       	push   $0x80107251
801064e2:	e8 61 9e ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801064e7:	83 ec 0c             	sub    $0xc,%esp
801064ea:	68 78 6d 10 80       	push   $0x80106d78
801064ef:	e8 54 9e ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801064f4:	83 c3 01             	add    $0x1,%ebx
801064f7:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801064fd:	77 26                	ja     80106525 <freevm+0x71>
    if(pgdir[i] & PTE_P){
801064ff:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106502:	a8 01                	test   $0x1,%al
80106504:	74 ee                	je     801064f4 <freevm+0x40>
80106506:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010650b:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106510:	77 d5                	ja     801064e7 <freevm+0x33>
    return (char*)a + KERNBASE;
80106512:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106517:	83 ec 0c             	sub    $0xc,%esp
8010651a:	50                   	push   %eax
8010651b:	e8 72 ba ff ff       	call   80101f92 <kfree>
80106520:	83 c4 10             	add    $0x10,%esp
80106523:	eb cf                	jmp    801064f4 <freevm+0x40>
    }
  }
  kfree((char*)pgdir);
80106525:	83 ec 0c             	sub    $0xc,%esp
80106528:	56                   	push   %esi
80106529:	e8 64 ba ff ff       	call   80101f92 <kfree>
}
8010652e:	83 c4 10             	add    $0x10,%esp
80106531:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106534:	5b                   	pop    %ebx
80106535:	5e                   	pop    %esi
80106536:	5d                   	pop    %ebp
80106537:	c3                   	ret    

80106538 <setupkvm>:
{
80106538:	55                   	push   %ebp
80106539:	89 e5                	mov    %esp,%ebp
8010653b:	56                   	push   %esi
8010653c:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
8010653d:	e8 8d bb ff ff       	call   801020cf <kalloc>
80106542:	89 c6                	mov    %eax,%esi
80106544:	85 c0                	test   %eax,%eax
80106546:	74 55                	je     8010659d <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106548:	83 ec 04             	sub    $0x4,%esp
8010654b:	68 00 10 00 00       	push   $0x1000
80106550:	6a 00                	push   $0x0
80106552:	50                   	push   %eax
80106553:	e8 c8 d8 ff ff       	call   80103e20 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106558:	83 c4 10             	add    $0x10,%esp
8010655b:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106560:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106566:	73 35                	jae    8010659d <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106568:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010656b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010656e:	29 c1                	sub    %eax,%ecx
80106570:	83 ec 08             	sub    $0x8,%esp
80106573:	ff 73 0c             	pushl  0xc(%ebx)
80106576:	50                   	push   %eax
80106577:	8b 13                	mov    (%ebx),%edx
80106579:	89 f0                	mov    %esi,%eax
8010657b:	e8 44 f9 ff ff       	call   80105ec4 <mappages>
80106580:	83 c4 10             	add    $0x10,%esp
80106583:	85 c0                	test   %eax,%eax
80106585:	78 05                	js     8010658c <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106587:	83 c3 10             	add    $0x10,%ebx
8010658a:	eb d4                	jmp    80106560 <setupkvm+0x28>
      freevm(pgdir);
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	56                   	push   %esi
80106590:	e8 1f ff ff ff       	call   801064b4 <freevm>
      return 0;
80106595:	83 c4 10             	add    $0x10,%esp
80106598:	be 00 00 00 00       	mov    $0x0,%esi
}
8010659d:	89 f0                	mov    %esi,%eax
8010659f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801065a2:	5b                   	pop    %ebx
801065a3:	5e                   	pop    %esi
801065a4:	5d                   	pop    %ebp
801065a5:	c3                   	ret    

801065a6 <kvmalloc>:
{
801065a6:	55                   	push   %ebp
801065a7:	89 e5                	mov    %esp,%ebp
801065a9:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801065ac:	e8 87 ff ff ff       	call   80106538 <setupkvm>
801065b1:	a3 a4 56 11 80       	mov    %eax,0x801156a4
  switchkvm();
801065b6:	e8 cb fa ff ff       	call   80106086 <switchkvm>
}
801065bb:	c9                   	leave  
801065bc:	c3                   	ret    

801065bd <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801065bd:	55                   	push   %ebp
801065be:	89 e5                	mov    %esp,%ebp
801065c0:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065c3:	b9 00 00 00 00       	mov    $0x0,%ecx
801065c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801065cb:	8b 45 08             	mov    0x8(%ebp),%eax
801065ce:	e8 57 f8 ff ff       	call   80105e2a <walkpgdir>
  if(pte == 0)
801065d3:	85 c0                	test   %eax,%eax
801065d5:	74 05                	je     801065dc <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801065d7:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801065da:	c9                   	leave  
801065db:	c3                   	ret    
    panic("clearpteu");
801065dc:	83 ec 0c             	sub    $0xc,%esp
801065df:	68 62 72 10 80       	push   $0x80107262
801065e4:	e8 5f 9d ff ff       	call   80100348 <panic>

801065e9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801065e9:	55                   	push   %ebp
801065ea:	89 e5                	mov    %esp,%ebp
801065ec:	57                   	push   %edi
801065ed:	56                   	push   %esi
801065ee:	53                   	push   %ebx
801065ef:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801065f2:	e8 41 ff ff ff       	call   80106538 <setupkvm>
801065f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
801065fa:	85 c0                	test   %eax,%eax
801065fc:	0f 84 f2 00 00 00    	je     801066f4 <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106602:	bb 00 00 00 00       	mov    $0x0,%ebx
80106607:	eb 3a                	jmp    80106643 <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106609:	83 ec 0c             	sub    $0xc,%esp
8010660c:	68 6c 72 10 80       	push   $0x8010726c
80106611:	e8 32 9d ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106616:	83 ec 0c             	sub    $0xc,%esp
80106619:	68 86 72 10 80       	push   $0x80107286
8010661e:	e8 25 9d ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106623:	83 ec 0c             	sub    $0xc,%esp
80106626:	68 78 6d 10 80       	push   $0x80106d78
8010662b:	e8 18 9d ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106630:	83 ec 0c             	sub    $0xc,%esp
80106633:	68 48 6a 10 80       	push   $0x80106a48
80106638:	e8 0b 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010663d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106643:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
80106646:	0f 83 a8 00 00 00    	jae    801066f4 <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010664c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010664f:	b9 00 00 00 00       	mov    $0x0,%ecx
80106654:	89 da                	mov    %ebx,%edx
80106656:	8b 45 08             	mov    0x8(%ebp),%eax
80106659:	e8 cc f7 ff ff       	call   80105e2a <walkpgdir>
8010665e:	85 c0                	test   %eax,%eax
80106660:	74 a7                	je     80106609 <copyuvm+0x20>
    if(!(*pte & PTE_P))
80106662:	8b 00                	mov    (%eax),%eax
80106664:	a8 01                	test   $0x1,%al
80106666:	74 ae                	je     80106616 <copyuvm+0x2d>
80106668:	89 c6                	mov    %eax,%esi
8010666a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
80106670:	25 ff 0f 00 00       	and    $0xfff,%eax
80106675:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106678:	e8 52 ba ff ff       	call   801020cf <kalloc>
8010667d:	89 c7                	mov    %eax,%edi
8010667f:	85 c0                	test   %eax,%eax
80106681:	74 5c                	je     801066df <copyuvm+0xf6>
    if (a > KERNBASE)
80106683:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106689:	77 98                	ja     80106623 <copyuvm+0x3a>
    return (char*)a + KERNBASE;
8010668b:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106691:	83 ec 04             	sub    $0x4,%esp
80106694:	68 00 10 00 00       	push   $0x1000
80106699:	56                   	push   %esi
8010669a:	50                   	push   %eax
8010669b:	e8 fb d7 ff ff       	call   80103e9b <memmove>
    if (a < (void*) KERNBASE)
801066a0:	83 c4 10             	add    $0x10,%esp
801066a3:	81 ff ff ff ff 7f    	cmp    $0x7fffffff,%edi
801066a9:	76 85                	jbe    80106630 <copyuvm+0x47>
    return (uint)a - KERNBASE;
801066ab:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801066b1:	83 ec 08             	sub    $0x8,%esp
801066b4:	ff 75 e0             	pushl  -0x20(%ebp)
801066b7:	50                   	push   %eax
801066b8:	b9 00 10 00 00       	mov    $0x1000,%ecx
801066bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801066c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801066c3:	e8 fc f7 ff ff       	call   80105ec4 <mappages>
801066c8:	83 c4 10             	add    $0x10,%esp
801066cb:	85 c0                	test   %eax,%eax
801066cd:	0f 89 6a ff ff ff    	jns    8010663d <copyuvm+0x54>
      kfree(mem);
801066d3:	83 ec 0c             	sub    $0xc,%esp
801066d6:	57                   	push   %edi
801066d7:	e8 b6 b8 ff ff       	call   80101f92 <kfree>
      goto bad;
801066dc:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
801066df:	83 ec 0c             	sub    $0xc,%esp
801066e2:	ff 75 dc             	pushl  -0x24(%ebp)
801066e5:	e8 ca fd ff ff       	call   801064b4 <freevm>
  return 0;
801066ea:	83 c4 10             	add    $0x10,%esp
801066ed:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801066f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801066f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066fa:	5b                   	pop    %ebx
801066fb:	5e                   	pop    %esi
801066fc:	5f                   	pop    %edi
801066fd:	5d                   	pop    %ebp
801066fe:	c3                   	ret    

801066ff <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801066ff:	55                   	push   %ebp
80106700:	89 e5                	mov    %esp,%ebp
80106702:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106705:	b9 00 00 00 00       	mov    $0x0,%ecx
8010670a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010670d:	8b 45 08             	mov    0x8(%ebp),%eax
80106710:	e8 15 f7 ff ff       	call   80105e2a <walkpgdir>
  if((*pte & PTE_P) == 0)
80106715:	8b 00                	mov    (%eax),%eax
80106717:	a8 01                	test   $0x1,%al
80106719:	74 24                	je     8010673f <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
8010671b:	a8 04                	test   $0x4,%al
8010671d:	74 27                	je     80106746 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
8010671f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106724:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106729:	77 07                	ja     80106732 <uva2ka+0x33>
    return (char*)a + KERNBASE;
8010672b:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106730:	c9                   	leave  
80106731:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80106732:	83 ec 0c             	sub    $0xc,%esp
80106735:	68 78 6d 10 80       	push   $0x80106d78
8010673a:	e8 09 9c ff ff       	call   80100348 <panic>
    return 0;
8010673f:	b8 00 00 00 00       	mov    $0x0,%eax
80106744:	eb ea                	jmp    80106730 <uva2ka+0x31>
    return 0;
80106746:	b8 00 00 00 00       	mov    $0x0,%eax
8010674b:	eb e3                	jmp    80106730 <uva2ka+0x31>

8010674d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010674d:	55                   	push   %ebp
8010674e:	89 e5                	mov    %esp,%ebp
80106750:	57                   	push   %edi
80106751:	56                   	push   %esi
80106752:	53                   	push   %ebx
80106753:	83 ec 0c             	sub    $0xc,%esp
80106756:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106759:	eb 25                	jmp    80106780 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010675b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010675e:	29 f2                	sub    %esi,%edx
80106760:	01 d0                	add    %edx,%eax
80106762:	83 ec 04             	sub    $0x4,%esp
80106765:	53                   	push   %ebx
80106766:	ff 75 10             	pushl  0x10(%ebp)
80106769:	50                   	push   %eax
8010676a:	e8 2c d7 ff ff       	call   80103e9b <memmove>
    len -= n;
8010676f:	29 df                	sub    %ebx,%edi
    buf += n;
80106771:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106774:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
8010677a:	89 45 0c             	mov    %eax,0xc(%ebp)
8010677d:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106780:	85 ff                	test   %edi,%edi
80106782:	74 2f                	je     801067b3 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106784:	8b 75 0c             	mov    0xc(%ebp),%esi
80106787:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010678d:	83 ec 08             	sub    $0x8,%esp
80106790:	56                   	push   %esi
80106791:	ff 75 08             	pushl  0x8(%ebp)
80106794:	e8 66 ff ff ff       	call   801066ff <uva2ka>
    if(pa0 == 0)
80106799:	83 c4 10             	add    $0x10,%esp
8010679c:	85 c0                	test   %eax,%eax
8010679e:	74 20                	je     801067c0 <copyout+0x73>
    n = PGSIZE - (va - va0);
801067a0:	89 f3                	mov    %esi,%ebx
801067a2:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801067a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801067ab:	39 df                	cmp    %ebx,%edi
801067ad:	73 ac                	jae    8010675b <copyout+0xe>
      n = len;
801067af:	89 fb                	mov    %edi,%ebx
801067b1:	eb a8                	jmp    8010675b <copyout+0xe>
  }
  return 0;
801067b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067bb:	5b                   	pop    %ebx
801067bc:	5e                   	pop    %esi
801067bd:	5f                   	pop    %edi
801067be:	5d                   	pop    %ebp
801067bf:	c3                   	ret    
      return -1;
801067c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c5:	eb f1                	jmp    801067b8 <copyout+0x6b>
