
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
80100046:	e8 01 3d 00 00       	call   80103d4c <acquire>

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
8010007c:	e8 30 3d 00 00       	call   80103db1 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 ac 3a 00 00       	call   80103b38 <acquiresleep>
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
801000ca:	e8 e2 3c 00 00       	call   80103db1 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 5e 3a 00 00       	call   80103b38 <acquiresleep>
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
801000ea:	68 a0 67 10 80       	push   $0x801067a0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 b1 67 10 80       	push   $0x801067b1
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 06 3b 00 00       	call   80103c10 <initlock>
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
8010013a:	68 b8 67 10 80       	push   $0x801067b8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 bd 39 00 00       	call   80103b05 <initsleeplock>
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
801001a8:	e8 15 3a 00 00       	call   80103bc2 <holdingsleep>
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
801001cb:	68 bf 67 10 80       	push   $0x801067bf
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
801001e4:	e8 d9 39 00 00       	call   80103bc2 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 8e 39 00 00       	call   80103b87 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 47 3b 00 00       	call   80103d4c <acquire>
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
8010024c:	e8 60 3b 00 00       	call   80103db1 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 c6 67 10 80       	push   $0x801067c6
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
8010028a:	e8 bd 3a 00 00       	call   80103d4c <acquire>
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
801002bf:	e8 14 35 00 00       	call   801037d8 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 db 3a 00 00       	call   80103db1 <release>
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
80100331:	e8 7b 3a 00 00       	call   80103db1 <release>
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
80100363:	68 cd 67 10 80       	push   $0x801067cd
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 ef 71 10 80 	movl   $0x801071ef,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 97 38 00 00       	call   80103c2b <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 e1 67 10 80       	push   $0x801067e1
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
8010049e:	68 e5 67 10 80       	push   $0x801067e5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 b4 39 00 00       	call   80103e73 <memmove>
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
801004d9:	e8 1a 39 00 00       	call   80103df8 <memset>
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
80100506:	e8 88 4d 00 00       	call   80105293 <uartputc>
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
8010051f:	e8 6f 4d 00 00       	call   80105293 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 63 4d 00 00       	call   80105293 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 57 4d 00 00       	call   80105293 <uartputc>
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
80100576:	0f b6 92 10 68 10 80 	movzbl -0x7fef97f0(%edx),%edx
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
801005ca:	e8 7d 37 00 00       	call   80103d4c <acquire>
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
801005f1:	e8 bb 37 00 00       	call   80103db1 <release>
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
80100638:	e8 0f 37 00 00       	call   80103d4c <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 ff 67 10 80       	push   $0x801067ff
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
801006ee:	be f8 67 10 80       	mov    $0x801067f8,%esi
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
80100734:	e8 78 36 00 00       	call   80103db1 <release>
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
8010074f:	e8 f8 35 00 00       	call   80103d4c <acquire>
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
801007de:	e8 5d 31 00 00       	call   80103940 <wakeup>
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
80100873:	e8 39 35 00 00       	call   80103db1 <release>
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
80100887:	e8 53 31 00 00       	call   801039df <procdump>
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
80100894:	68 08 68 10 80       	push   $0x80106808
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 6d 33 00 00       	call   80103c10 <initlock>

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
80100952:	68 21 68 10 80       	push   $0x80106821
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
80100972:	e8 99 5b 00 00       	call   80106510 <setupkvm>
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
80100a06:	e8 7f 59 00 00       	call   8010638a <allocuvm>
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
80100a38:	e8 f3 57 00 00       	call   80106230 <loaduvm>
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
80100a74:	e8 11 59 00 00       	call   8010638a <allocuvm>
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
80100a9d:	e8 ea 59 00 00       	call   8010648c <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 d4 5a 00 00       	call   80106595 <clearpteu>
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
80100ae2:	e8 b3 34 00 00       	call   80103f9a <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 a1 34 00 00       	call   80103f9a <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 1a 5c 00 00       	call   80106725 <copyout>
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
80100b66:	e8 ba 5b 00 00       	call   80106725 <copyout>
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
80100ba3:	e8 b7 33 00 00       	call   80103f5f <safestrcpy>
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
80100bd1:	e8 ad 54 00 00       	call   80106083 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 ae 58 00 00       	call   8010648c <freevm>
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
80100c19:	68 2d 68 10 80       	push   $0x8010682d
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 e8 2f 00 00       	call   80103c10 <initlock>
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
80100c39:	e8 0e 31 00 00       	call   80103d4c <acquire>
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
80100c68:	e8 44 31 00 00       	call   80103db1 <release>
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
80100c7f:	e8 2d 31 00 00       	call   80103db1 <release>
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
80100c9d:	e8 aa 30 00 00       	call   80103d4c <acquire>
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
80100cba:	e8 f2 30 00 00       	call   80103db1 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 34 68 10 80       	push   $0x80106834
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
80100ce2:	e8 65 30 00 00       	call   80103d4c <acquire>
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
80100d03:	e8 a9 30 00 00       	call   80103db1 <release>
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
80100d13:	68 3c 68 10 80       	push   $0x8010683c
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
80100d49:	e8 63 30 00 00       	call   80103db1 <release>
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
80100e4b:	68 46 68 10 80       	push   $0x80106846
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
80100f10:	68 4f 68 10 80       	push   $0x8010684f
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
80100f2d:	68 55 68 10 80       	push   $0x80106855
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
80100f8a:	e8 e4 2e 00 00       	call   80103e73 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 d4 2e 00 00       	call   80103e73 <memmove>
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
80100fdf:	e8 14 2e 00 00       	call   80103df8 <memset>
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
80101062:	68 5f 68 10 80       	push   $0x8010685f
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
80101113:	68 72 68 10 80       	push   $0x80106872
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
801011ed:	68 88 68 10 80       	push   $0x80106888
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
8010120a:	e8 3d 2b 00 00       	call   80103d4c <acquire>
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
80101251:	e8 5b 2b 00 00       	call   80103db1 <release>
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
80101287:	e8 25 2b 00 00       	call   80103db1 <release>
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
8010129c:	68 9b 68 10 80       	push   $0x8010689b
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
801012c5:	e8 a9 2b 00 00       	call   80103e73 <memmove>
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
801012e1:	68 ab 68 10 80       	push   $0x801068ab
801012e6:	68 e0 09 11 80       	push   $0x801109e0
801012eb:	e8 20 29 00 00       	call   80103c10 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 b2 68 10 80       	push   $0x801068b2
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 20 0a 11 80       	add    $0x80110a20,%eax
8010130f:	50                   	push   %eax
80101310:	e8 f0 27 00 00       	call   80103b05 <initsleeplock>
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
8010135a:	68 18 69 10 80       	push   $0x80106918
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
801013cd:	68 b8 68 10 80       	push   $0x801068b8
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 14 2a 00 00       	call   80103df8 <memset>
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
8010146e:	e8 00 2a 00 00       	call   80103e73 <memmove>
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
8010154e:	e8 f9 27 00 00       	call   80103d4c <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101563:	e8 49 28 00 00       	call   80103db1 <release>
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
80101588:	e8 ab 25 00 00       	call   80103b38 <acquiresleep>
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
801015a0:	68 ca 68 10 80       	push   $0x801068ca
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
80101602:	e8 6c 28 00 00       	call   80103e73 <memmove>
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
80101627:	68 d0 68 10 80       	push   $0x801068d0
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
80101644:	e8 79 25 00 00       	call   80103bc2 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 28 25 00 00       	call   80103b87 <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 df 68 10 80       	push   $0x801068df
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
80101686:	e8 ad 24 00 00       	call   80103b38 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 e3 24 00 00       	call   80103b87 <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016ab:	e8 9c 26 00 00       	call   80103d4c <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016c0:	e8 ec 26 00 00       	call   80103db1 <release>
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
801016d8:	e8 6f 26 00 00       	call   80103d4c <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016e7:	e8 c5 26 00 00       	call   80103db1 <release>
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
80101818:	e8 56 26 00 00       	call   80103e73 <memmove>
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
80101914:	e8 5a 25 00 00       	call   80103e73 <memmove>
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
80101997:	e8 3e 25 00 00       	call   80103eda <strncmp>
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
801019be:	68 e7 68 10 80       	push   $0x801068e7
801019c3:	e8 80 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 f9 68 10 80       	push   $0x801068f9
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
80101b80:	68 08 69 10 80       	push   $0x80106908
80101b85:	e8 be e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b8a:	83 ec 04             	sub    $0x4,%esp
80101b8d:	6a 0e                	push   $0xe
80101b8f:	57                   	push   %edi
80101b90:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b93:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b96:	50                   	push   %eax
80101b97:	e8 7b 23 00 00       	call   80103f17 <strncpy>
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
80101bc5:	68 e8 6f 10 80       	push   $0x80106fe8
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
80101cba:	68 6b 69 10 80       	push   $0x8010696b
80101cbf:	e8 84 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 74 69 10 80       	push   $0x80106974
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
80101cf4:	68 86 69 10 80       	push   $0x80106986
80101cf9:	68 80 a5 10 80       	push   $0x8010a580
80101cfe:	e8 0d 1f 00 00       	call   80103c10 <initlock>
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
80101d6e:	e8 d9 1f 00 00       	call   80103d4c <acquire>

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
80101d9b:	e8 a0 1b 00 00       	call   80103940 <wakeup>

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
80101db9:	e8 f3 1f 00 00       	call   80103db1 <release>
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
80101dd0:	e8 dc 1f 00 00       	call   80103db1 <release>
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
80101e08:	e8 b5 1d 00 00       	call   80103bc2 <holdingsleep>
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
80101e35:	e8 12 1f 00 00       	call   80103d4c <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e3a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e49:	eb 2a                	jmp    80101e75 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 8a 69 10 80       	push   $0x8010698a
80101e53:	e8 f0 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e58:	83 ec 0c             	sub    $0xc,%esp
80101e5b:	68 a0 69 10 80       	push   $0x801069a0
80101e60:	e8 e3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e65:	83 ec 0c             	sub    $0xc,%esp
80101e68:	68 b5 69 10 80       	push   $0x801069b5
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
80101e97:	e8 3c 19 00 00       	call   801037d8 <sleep>
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
80101eb1:	e8 fb 1e 00 00       	call   80103db1 <release>
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
80101f2d:	68 d4 69 10 80       	push   $0x801069d4
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
80101fcc:	e8 27 1e 00 00       	call   80103df8 <memset>

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
80101ffb:	68 08 6a 10 80       	push   $0x80106a08
80102000:	e8 43 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80102005:	83 ec 0c             	sub    $0xc,%esp
80102008:	68 96 6a 10 80       	push   $0x80106a96
8010200d:	e8 36 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102012:	83 ec 0c             	sub    $0xc,%esp
80102015:	68 40 26 11 80       	push   $0x80112640
8010201a:	e8 2d 1d 00 00       	call   80103d4c <acquire>
8010201f:	83 c4 10             	add    $0x10,%esp
80102022:	eb b9                	jmp    80101fdd <kfree+0x4b>
    release(&kmem.lock);
80102024:	83 ec 0c             	sub    $0xc,%esp
80102027:	68 40 26 11 80       	push   $0x80112640
8010202c:	e8 80 1d 00 00       	call   80103db1 <release>
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
80102054:	68 9c 6a 10 80       	push   $0x80106a9c
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
80102083:	68 a6 6a 10 80       	push   $0x80106aa6
80102088:	68 40 26 11 80       	push   $0x80112640
8010208d:	e8 7e 1b 00 00       	call   80103c10 <initlock>
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
80102108:	e8 3f 1c 00 00       	call   80103d4c <acquire>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	eb cd                	jmp    801020df <kalloc+0x10>
    release(&kmem.lock);
80102112:	83 ec 0c             	sub    $0xc,%esp
80102115:	68 40 26 11 80       	push   $0x80112640
8010211a:	e8 92 1c 00 00       	call   80103db1 <release>
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
80102164:	0f b6 8a e0 6b 10 80 	movzbl -0x7fef9420(%edx),%ecx
8010216b:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
80102171:	0f b6 82 e0 6a 10 80 	movzbl -0x7fef9520(%edx),%eax
80102178:	31 c1                	xor    %eax,%ecx
8010217a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102180:	89 c8                	mov    %ecx,%eax
80102182:	83 e0 03             	and    $0x3,%eax
80102185:	8b 04 85 c0 6a 10 80 	mov    -0x7fef9540(,%eax,4),%eax
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
801021c0:	0f b6 82 e0 6b 10 80 	movzbl -0x7fef9420(%edx),%eax
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
801024bb:	e8 7e 19 00 00       	call   80103e3e <memcmp>
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
80102626:	e8 48 18 00 00       	call   80103e73 <memmove>
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
80102725:	e8 49 17 00 00       	call   80103e73 <memmove>
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
80102793:	68 e0 6c 10 80       	push   $0x80106ce0
80102798:	68 80 26 11 80       	push   $0x80112680
8010279d:	e8 6e 14 00 00       	call   80103c10 <initlock>
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
801027dd:	e8 6a 15 00 00       	call   80103d4c <acquire>
801027e2:	83 c4 10             	add    $0x10,%esp
801027e5:	eb 15                	jmp    801027fc <begin_op+0x2a>
      sleep(&log, &log.lock);
801027e7:	83 ec 08             	sub    $0x8,%esp
801027ea:	68 80 26 11 80       	push   $0x80112680
801027ef:	68 80 26 11 80       	push   $0x80112680
801027f4:	e8 df 0f 00 00       	call   801037d8 <sleep>
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
8010282b:	e8 a8 0f 00 00       	call   801037d8 <sleep>
80102830:	83 c4 10             	add    $0x10,%esp
80102833:	eb c7                	jmp    801027fc <begin_op+0x2a>
      log.outstanding += 1;
80102835:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	68 80 26 11 80       	push   $0x80112680
80102842:	e8 6a 15 00 00       	call   80103db1 <release>
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
80102858:	e8 ef 14 00 00       	call   80103d4c <acquire>
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
80102892:	e8 1a 15 00 00       	call   80103db1 <release>
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
801028a6:	68 e4 6c 10 80       	push   $0x80106ce4
801028ab:	e8 98 da ff ff       	call   80100348 <panic>
    wakeup(&log);
801028b0:	83 ec 0c             	sub    $0xc,%esp
801028b3:	68 80 26 11 80       	push   $0x80112680
801028b8:	e8 83 10 00 00       	call   80103940 <wakeup>
801028bd:	83 c4 10             	add    $0x10,%esp
801028c0:	eb c8                	jmp    8010288a <end_op+0x3e>
    commit();
801028c2:	e8 91 fe ff ff       	call   80102758 <commit>
    acquire(&log.lock);
801028c7:	83 ec 0c             	sub    $0xc,%esp
801028ca:	68 80 26 11 80       	push   $0x80112680
801028cf:	e8 78 14 00 00       	call   80103d4c <acquire>
    log.committing = 0;
801028d4:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
801028db:	00 00 00 
    wakeup(&log);
801028de:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028e5:	e8 56 10 00 00       	call   80103940 <wakeup>
    release(&log.lock);
801028ea:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028f1:	e8 bb 14 00 00       	call   80103db1 <release>
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
8010292d:	e8 1a 14 00 00       	call   80103d4c <acquire>
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
80102958:	68 f3 6c 10 80       	push   $0x80106cf3
8010295d:	e8 e6 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102962:	83 ec 0c             	sub    $0xc,%esp
80102965:	68 09 6d 10 80       	push   $0x80106d09
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
80102988:	e8 24 14 00 00       	call   80103db1 <release>
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
801029b6:	e8 b8 14 00 00       	call   80103e73 <memmove>

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
801029c8:	68 08 6a 10 80       	push   $0x80106a08
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
80102a60:	68 24 6d 10 80       	push   $0x80106d24
80102a65:	e8 a1 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a6a:	e8 bc 25 00 00       	call   8010502b <idtinit>
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
80102a8d:	e8 cc 35 00 00       	call   8010605e <switchkvm>
  seginit();
80102a92:	e8 7b 34 00 00       	call   80105f12 <seginit>
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
80102ac1:	e8 b8 3a 00 00       	call   8010657e <kvmalloc>
  mpinit();        // detect other processors
80102ac6:	e8 e7 01 00 00       	call   80102cb2 <mpinit>
  lapicinit();     // interrupt controller
80102acb:	e8 c8 f7 ff ff       	call   80102298 <lapicinit>
  seginit();       // segment descriptors
80102ad0:	e8 3d 34 00 00       	call   80105f12 <seginit>
  picinit();       // disable pic
80102ad5:	e8 a0 02 00 00       	call   80102d7a <picinit>
  ioapicinit();    // another interrupt controller
80102ada:	e8 09 f4 ff ff       	call   80101ee8 <ioapicinit>
  consoleinit();   // console hardware
80102adf:	e8 aa dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102ae4:	e8 f0 27 00 00       	call   801052d9 <uartinit>
  pinit();         // process table
80102ae9:	e8 24 07 00 00       	call   80103212 <pinit>
  tvinit();        // trap vectors
80102aee:	e8 87 24 00 00       	call   80104f7a <tvinit>
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
80102b61:	68 38 6d 10 80       	push   $0x80106d38
80102b66:	e8 dd d7 ff ff       	call   80100348 <panic>
80102b6b:	83 c3 10             	add    $0x10,%ebx
80102b6e:	39 f3                	cmp    %esi,%ebx
80102b70:	73 29                	jae    80102b9b <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b72:	83 ec 04             	sub    $0x4,%esp
80102b75:	6a 04                	push   $0x4
80102b77:	68 52 6d 10 80       	push   $0x80106d52
80102b7c:	53                   	push   %ebx
80102b7d:	e8 bc 12 00 00       	call   80103e3e <memcmp>
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
80102c43:	68 57 6d 10 80       	push   $0x80106d57
80102c48:	53                   	push   %ebx
80102c49:	e8 f0 11 00 00       	call   80103e3e <memcmp>
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
80102c85:	68 38 6d 10 80       	push   $0x80106d38
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
80102ce3:	68 5c 6d 10 80       	push   $0x80106d5c
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
80102d22:	ff 24 85 94 6d 10 80 	jmp    *-0x7fef926c(,%eax,4)
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
80102d70:	68 74 6d 10 80       	push   $0x80106d74
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
80102e2c:	68 a8 6d 10 80       	push   $0x80106da8
80102e31:	50                   	push   %eax
80102e32:	e8 d9 0d 00 00       	call   80103c10 <initlock>
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
80102e88:	e8 bf 0e 00 00       	call   80103d4c <acquire>
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
80102eaa:	e8 91 0a 00 00       	call   80103940 <wakeup>
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
80102ec8:	e8 e4 0e 00 00       	call   80103db1 <release>
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
80102ee9:	e8 52 0a 00 00       	call   80103940 <wakeup>
80102eee:	83 c4 10             	add    $0x10,%esp
80102ef1:	eb bf                	jmp    80102eb2 <pipeclose+0x35>
    release(&p->lock);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	53                   	push   %ebx
80102ef7:	e8 b5 0e 00 00       	call   80103db1 <release>
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
80102f18:	e8 2f 0e 00 00       	call   80103d4c <acquire>
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
80102f61:	e8 da 09 00 00       	call   80103940 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f66:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f6c:	83 c4 08             	add    $0x8,%esp
80102f6f:	56                   	push   %esi
80102f70:	50                   	push   %eax
80102f71:	e8 62 08 00 00       	call   801037d8 <sleep>
80102f76:	83 c4 10             	add    $0x10,%esp
80102f79:	eb b3                	jmp    80102f2e <pipewrite+0x25>
        release(&p->lock);
80102f7b:	83 ec 0c             	sub    $0xc,%esp
80102f7e:	53                   	push   %ebx
80102f7f:	e8 2d 0e 00 00       	call   80103db1 <release>
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
80102fc0:	e8 7b 09 00 00       	call   80103940 <wakeup>
  release(&p->lock);
80102fc5:	89 1c 24             	mov    %ebx,(%esp)
80102fc8:	e8 e4 0d 00 00       	call   80103db1 <release>
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
80102fe4:	e8 63 0d 00 00       	call   80103d4c <acquire>
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
8010301a:	e8 b9 07 00 00       	call   801037d8 <sleep>
8010301f:	83 c4 10             	add    $0x10,%esp
80103022:	eb c8                	jmp    80102fec <piperead+0x17>
      release(&p->lock);
80103024:	83 ec 0c             	sub    $0xc,%esp
80103027:	53                   	push   %ebx
80103028:	e8 84 0d 00 00       	call   80103db1 <release>
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
80103077:	e8 c4 08 00 00       	call   80103940 <wakeup>
  release(&p->lock);
8010307c:	89 1c 24             	mov    %ebx,(%esp)
8010307f:	e8 2d 0d 00 00       	call   80103db1 <release>
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
801030cb:	e8 7c 0c 00 00       	call   80103d4c <acquire>
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
801030f6:	e8 b6 0c 00 00       	call   80103db1 <release>
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
80103125:	e8 87 0c 00 00       	call   80103db1 <release>
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
80103142:	c7 80 b0 0f 00 00 6f 	movl   $0x80104f6f,0xfb0(%eax)
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
8010315c:	e8 97 0c 00 00       	call   80103df8 <memset>
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
8010318e:	e8 1e 0c 00 00       	call   80103db1 <release>
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
80103218:	68 ad 6d 10 80       	push   $0x80106dad
8010321d:	68 20 2d 11 80       	push   $0x80112d20
80103222:	e8 e9 09 00 00       	call   80103c10 <initlock>
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
80103264:	68 90 6e 10 80       	push   $0x80106e90
80103269:	e8 da d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010326e:	83 ec 0c             	sub    $0xc,%esp
80103271:	68 b4 6d 10 80       	push   $0x80106db4
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
801032aa:	e8 c0 09 00 00       	call   80103c6f <pushcli>
  c = mycpu();
801032af:	e8 78 ff ff ff       	call   8010322c <mycpu>
  p = c->proc;
801032b4:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032ba:	e8 ed 09 00 00       	call   80103cac <popcli>
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
801032da:	e8 31 32 00 00       	call   80106510 <setupkvm>
801032df:	89 43 04             	mov    %eax,0x4(%ebx)
801032e2:	85 c0                	test   %eax,%eax
801032e4:	0f 84 c1 00 00 00    	je     801033ab <userinit+0xe4>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032ea:	83 ec 04             	sub    $0x4,%esp
801032ed:	68 2c 00 00 00       	push   $0x2c
801032f2:	68 60 a4 10 80       	push   $0x8010a460
801032f7:	50                   	push   %eax
801032f8:	e8 b2 2e 00 00       	call   801061af <inituvm>
  p->sz = PGSIZE;
801032fd:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103303:	83 c4 0c             	add    $0xc,%esp
80103306:	6a 4c                	push   $0x4c
80103308:	6a 00                	push   $0x0
8010330a:	ff 73 18             	pushl  0x18(%ebx)
8010330d:	e8 e6 0a 00 00       	call   80103df8 <memset>
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
8010336a:	68 dd 6d 10 80       	push   $0x80106ddd
8010336f:	50                   	push   %eax
80103370:	e8 ea 0b 00 00       	call   80103f5f <safestrcpy>
  p->cwd = namei("/");
80103375:	c7 04 24 e6 6d 10 80 	movl   $0x80106de6,(%esp)
8010337c:	e8 4e e8 ff ff       	call   80101bcf <namei>
80103381:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103384:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010338b:	e8 bc 09 00 00       	call   80103d4c <acquire>
  p->state = RUNNABLE;
80103390:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103397:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010339e:	e8 0e 0a 00 00       	call   80103db1 <release>
}
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033a9:	c9                   	leave  
801033aa:	c3                   	ret    
    panic("userinit: out of memory?");
801033ab:	83 ec 0c             	sub    $0xc,%esp
801033ae:	68 c4 6d 10 80       	push   $0x80106dc4
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
801033db:	e8 04 2f 00 00       	call   801062e4 <deallocuvm>
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
801033f8:	e8 8d 2f 00 00       	call   8010638a <allocuvm>
801033fd:	83 c4 10             	add    $0x10,%esp
80103400:	85 c0                	test   %eax,%eax
80103402:	74 1a                	je     8010341e <growproc+0x66>
  curproc->sz = sz;
80103404:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103406:	83 ec 0c             	sub    $0xc,%esp
80103409:	53                   	push   %ebx
8010340a:	e8 74 2c 00 00       	call   80106083 <switchuvm>
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
8010344f:	e8 6d 31 00 00       	call   801065c1 <copyuvm>
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
80103506:	e8 54 0a 00 00       	call   80103f5f <safestrcpy>
  pid = np->pid;
8010350b:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010350e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103515:	e8 32 08 00 00       	call   80103d4c <acquire>
  np->state = RUNNABLE;
8010351a:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103521:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103528:	e8 84 08 00 00       	call   80103db1 <release>
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
80103544:	56                   	push   %esi
80103545:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103546:	e8 e1 fc ff ff       	call   8010322c <mycpu>
8010354b:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010354d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103554:	00 00 00 
80103557:	e9 b9 00 00 00       	jmp    80103615 <scheduler+0xd4>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010355c:	05 84 00 00 00       	add    $0x84,%eax
80103561:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
80103566:	73 11                	jae    80103579 <scheduler+0x38>
      if(p->state != RUNNABLE)
80103568:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
8010356c:	75 ee                	jne    8010355c <scheduler+0x1b>
      runnable_processes++;
8010356e:	83 c2 01             	add    $0x1,%edx
      total_tickets += p->tickets;
80103571:	03 98 80 00 00 00    	add    0x80(%eax),%ebx
80103577:	eb e3                	jmp    8010355c <scheduler+0x1b>
    if(runnable_processes == 0){
80103579:	85 d2                	test   %edx,%edx
8010357b:	74 18                	je     80103595 <scheduler+0x54>
    unsigned myRandom = next_random();
8010357d:	e8 81 fc ff ff       	call   80103203 <next_random>
    int myRandInt = (int) myRandom;
80103582:	ba 00 00 00 00       	mov    $0x0,%edx
80103587:	f7 f3                	div    %ebx
    int tick_index = 0;
80103589:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010358e:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103593:	eb 18                	jmp    801035ad <scheduler+0x6c>
      release(&ptable.lock);
80103595:	83 ec 0c             	sub    $0xc,%esp
80103598:	68 20 2d 11 80       	push   $0x80112d20
8010359d:	e8 0f 08 00 00       	call   80103db1 <release>
      continue;
801035a2:	83 c4 10             	add    $0x10,%esp
801035a5:	eb 6e                	jmp    80103615 <scheduler+0xd4>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035a7:	81 c3 84 00 00 00    	add    $0x84,%ebx
801035ad:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
801035b3:	73 50                	jae    80103605 <scheduler+0xc4>
      if(p->state != RUNNABLE) continue;
801035b5:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035b9:	75 ec                	jne    801035a7 <scheduler+0x66>
      tick_index += p->tickets;
801035bb:	03 83 80 00 00 00    	add    0x80(%ebx),%eax
      if(tick_index > myRandInt){
801035c1:	39 c2                	cmp    %eax,%edx
801035c3:	7d e2                	jge    801035a7 <scheduler+0x66>
      c->proc = p;
801035c5:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801035cb:	83 ec 0c             	sub    $0xc,%esp
801035ce:	53                   	push   %ebx
801035cf:	e8 af 2a 00 00       	call   80106083 <switchuvm>
      p->state = RUNNING;
801035d4:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      p->num_times_scheduled++;
801035db:	8b 43 7c             	mov    0x7c(%ebx),%eax
801035de:	83 c0 01             	add    $0x1,%eax
801035e1:	89 43 7c             	mov    %eax,0x7c(%ebx)
      swtch(&(c->scheduler), p->context);
801035e4:	83 c4 08             	add    $0x8,%esp
801035e7:	ff 73 1c             	pushl  0x1c(%ebx)
801035ea:	8d 46 04             	lea    0x4(%esi),%eax
801035ed:	50                   	push   %eax
801035ee:	e8 bf 09 00 00       	call   80103fb2 <swtch>
      switchkvm();
801035f3:	e8 66 2a 00 00       	call   8010605e <switchkvm>
      c->proc = 0;
801035f8:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035ff:	00 00 00 
      break;
80103602:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80103605:	83 ec 0c             	sub    $0xc,%esp
80103608:	68 20 2d 11 80       	push   $0x80112d20
8010360d:	e8 9f 07 00 00       	call   80103db1 <release>
80103612:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103615:	fb                   	sti    
    acquire(&ptable.lock);
80103616:	83 ec 0c             	sub    $0xc,%esp
80103619:	68 20 2d 11 80       	push   $0x80112d20
8010361e:	e8 29 07 00 00       	call   80103d4c <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103623:	83 c4 10             	add    $0x10,%esp
    int runnable_processes = 0;
80103626:	ba 00 00 00 00       	mov    $0x0,%edx
    int total_tickets = 0;
8010362b:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103630:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103635:	e9 27 ff ff ff       	jmp    80103561 <scheduler+0x20>

8010363a <sched>:
{
8010363a:	55                   	push   %ebp
8010363b:	89 e5                	mov    %esp,%ebp
8010363d:	56                   	push   %esi
8010363e:	53                   	push   %ebx
  struct proc *p = myproc();
8010363f:	e8 5f fc ff ff       	call   801032a3 <myproc>
80103644:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103646:	83 ec 0c             	sub    $0xc,%esp
80103649:	68 20 2d 11 80       	push   $0x80112d20
8010364e:	e8 b9 06 00 00       	call   80103d0c <holding>
80103653:	83 c4 10             	add    $0x10,%esp
80103656:	85 c0                	test   %eax,%eax
80103658:	74 4f                	je     801036a9 <sched+0x6f>
  if(mycpu()->ncli != 1)
8010365a:	e8 cd fb ff ff       	call   8010322c <mycpu>
8010365f:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103666:	75 4e                	jne    801036b6 <sched+0x7c>
  if(p->state == RUNNING)
80103668:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010366c:	74 55                	je     801036c3 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010366e:	9c                   	pushf  
8010366f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103670:	f6 c4 02             	test   $0x2,%ah
80103673:	75 5b                	jne    801036d0 <sched+0x96>
  intena = mycpu()->intena;
80103675:	e8 b2 fb ff ff       	call   8010322c <mycpu>
8010367a:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103680:	e8 a7 fb ff ff       	call   8010322c <mycpu>
80103685:	83 ec 08             	sub    $0x8,%esp
80103688:	ff 70 04             	pushl  0x4(%eax)
8010368b:	83 c3 1c             	add    $0x1c,%ebx
8010368e:	53                   	push   %ebx
8010368f:	e8 1e 09 00 00       	call   80103fb2 <swtch>
  mycpu()->intena = intena;
80103694:	e8 93 fb ff ff       	call   8010322c <mycpu>
80103699:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010369f:	83 c4 10             	add    $0x10,%esp
801036a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036a5:	5b                   	pop    %ebx
801036a6:	5e                   	pop    %esi
801036a7:	5d                   	pop    %ebp
801036a8:	c3                   	ret    
    panic("sched ptable.lock");
801036a9:	83 ec 0c             	sub    $0xc,%esp
801036ac:	68 e8 6d 10 80       	push   $0x80106de8
801036b1:	e8 92 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
801036b6:	83 ec 0c             	sub    $0xc,%esp
801036b9:	68 fa 6d 10 80       	push   $0x80106dfa
801036be:	e8 85 cc ff ff       	call   80100348 <panic>
    panic("sched running");
801036c3:	83 ec 0c             	sub    $0xc,%esp
801036c6:	68 06 6e 10 80       	push   $0x80106e06
801036cb:	e8 78 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801036d0:	83 ec 0c             	sub    $0xc,%esp
801036d3:	68 14 6e 10 80       	push   $0x80106e14
801036d8:	e8 6b cc ff ff       	call   80100348 <panic>

801036dd <exit>:
{
801036dd:	55                   	push   %ebp
801036de:	89 e5                	mov    %esp,%ebp
801036e0:	56                   	push   %esi
801036e1:	53                   	push   %ebx
  struct proc *curproc = myproc();
801036e2:	e8 bc fb ff ff       	call   801032a3 <myproc>
  if(curproc == initproc)
801036e7:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
801036ed:	74 09                	je     801036f8 <exit+0x1b>
801036ef:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801036f1:	bb 00 00 00 00       	mov    $0x0,%ebx
801036f6:	eb 10                	jmp    80103708 <exit+0x2b>
    panic("init exiting");
801036f8:	83 ec 0c             	sub    $0xc,%esp
801036fb:	68 28 6e 10 80       	push   $0x80106e28
80103700:	e8 43 cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103705:	83 c3 01             	add    $0x1,%ebx
80103708:	83 fb 0f             	cmp    $0xf,%ebx
8010370b:	7f 1e                	jg     8010372b <exit+0x4e>
    if(curproc->ofile[fd]){
8010370d:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103711:	85 c0                	test   %eax,%eax
80103713:	74 f0                	je     80103705 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103715:	83 ec 0c             	sub    $0xc,%esp
80103718:	50                   	push   %eax
80103719:	e8 b5 d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
8010371e:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103725:	00 
80103726:	83 c4 10             	add    $0x10,%esp
80103729:	eb da                	jmp    80103705 <exit+0x28>
  begin_op();
8010372b:	e8 a2 f0 ff ff       	call   801027d2 <begin_op>
  iput(curproc->cwd);
80103730:	83 ec 0c             	sub    $0xc,%esp
80103733:	ff 76 68             	pushl  0x68(%esi)
80103736:	e8 3b df ff ff       	call   80101676 <iput>
  end_op();
8010373b:	e8 0c f1 ff ff       	call   8010284c <end_op>
  curproc->cwd = 0;
80103740:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103747:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010374e:	e8 f9 05 00 00       	call   80103d4c <acquire>
  wakeup1(curproc->parent);
80103753:	8b 46 14             	mov    0x14(%esi),%eax
80103756:	e8 36 f9 ff ff       	call   80103091 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010375b:	83 c4 10             	add    $0x10,%esp
8010375e:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103763:	eb 06                	jmp    8010376b <exit+0x8e>
80103765:	81 c3 84 00 00 00    	add    $0x84,%ebx
8010376b:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103771:	73 1a                	jae    8010378d <exit+0xb0>
    if(p->parent == curproc){
80103773:	39 73 14             	cmp    %esi,0x14(%ebx)
80103776:	75 ed                	jne    80103765 <exit+0x88>
      p->parent = initproc;
80103778:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
8010377d:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103780:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103784:	75 df                	jne    80103765 <exit+0x88>
        wakeup1(initproc);
80103786:	e8 06 f9 ff ff       	call   80103091 <wakeup1>
8010378b:	eb d8                	jmp    80103765 <exit+0x88>
  curproc->state = ZOMBIE;
8010378d:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103794:	e8 a1 fe ff ff       	call   8010363a <sched>
  panic("zombie exit");
80103799:	83 ec 0c             	sub    $0xc,%esp
8010379c:	68 35 6e 10 80       	push   $0x80106e35
801037a1:	e8 a2 cb ff ff       	call   80100348 <panic>

801037a6 <yield>:
{
801037a6:	55                   	push   %ebp
801037a7:	89 e5                	mov    %esp,%ebp
801037a9:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801037ac:	68 20 2d 11 80       	push   $0x80112d20
801037b1:	e8 96 05 00 00       	call   80103d4c <acquire>
  myproc()->state = RUNNABLE;
801037b6:	e8 e8 fa ff ff       	call   801032a3 <myproc>
801037bb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801037c2:	e8 73 fe ff ff       	call   8010363a <sched>
  release(&ptable.lock);
801037c7:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037ce:	e8 de 05 00 00       	call   80103db1 <release>
}
801037d3:	83 c4 10             	add    $0x10,%esp
801037d6:	c9                   	leave  
801037d7:	c3                   	ret    

801037d8 <sleep>:
{
801037d8:	55                   	push   %ebp
801037d9:	89 e5                	mov    %esp,%ebp
801037db:	56                   	push   %esi
801037dc:	53                   	push   %ebx
801037dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801037e0:	e8 be fa ff ff       	call   801032a3 <myproc>
  if(p == 0)
801037e5:	85 c0                	test   %eax,%eax
801037e7:	74 66                	je     8010384f <sleep+0x77>
801037e9:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801037eb:	85 db                	test   %ebx,%ebx
801037ed:	74 6d                	je     8010385c <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801037ef:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
801037f5:	74 18                	je     8010380f <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801037f7:	83 ec 0c             	sub    $0xc,%esp
801037fa:	68 20 2d 11 80       	push   $0x80112d20
801037ff:	e8 48 05 00 00       	call   80103d4c <acquire>
    release(lk);
80103804:	89 1c 24             	mov    %ebx,(%esp)
80103807:	e8 a5 05 00 00       	call   80103db1 <release>
8010380c:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103815:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010381c:	e8 19 fe ff ff       	call   8010363a <sched>
  p->chan = 0;
80103821:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103828:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
8010382e:	74 18                	je     80103848 <sleep+0x70>
    release(&ptable.lock);
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	68 20 2d 11 80       	push   $0x80112d20
80103838:	e8 74 05 00 00       	call   80103db1 <release>
    acquire(lk);
8010383d:	89 1c 24             	mov    %ebx,(%esp)
80103840:	e8 07 05 00 00       	call   80103d4c <acquire>
80103845:	83 c4 10             	add    $0x10,%esp
}
80103848:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010384b:	5b                   	pop    %ebx
8010384c:	5e                   	pop    %esi
8010384d:	5d                   	pop    %ebp
8010384e:	c3                   	ret    
    panic("sleep");
8010384f:	83 ec 0c             	sub    $0xc,%esp
80103852:	68 41 6e 10 80       	push   $0x80106e41
80103857:	e8 ec ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010385c:	83 ec 0c             	sub    $0xc,%esp
8010385f:	68 47 6e 10 80       	push   $0x80106e47
80103864:	e8 df ca ff ff       	call   80100348 <panic>

80103869 <wait>:
{
80103869:	55                   	push   %ebp
8010386a:	89 e5                	mov    %esp,%ebp
8010386c:	56                   	push   %esi
8010386d:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010386e:	e8 30 fa ff ff       	call   801032a3 <myproc>
80103873:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	68 20 2d 11 80       	push   $0x80112d20
8010387d:	e8 ca 04 00 00       	call   80103d4c <acquire>
80103882:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103885:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010388a:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010388f:	eb 5e                	jmp    801038ef <wait+0x86>
        pid = p->pid;
80103891:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103894:	83 ec 0c             	sub    $0xc,%esp
80103897:	ff 73 08             	pushl  0x8(%ebx)
8010389a:	e8 f3 e6 ff ff       	call   80101f92 <kfree>
        p->kstack = 0;
8010389f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801038a6:	83 c4 04             	add    $0x4,%esp
801038a9:	ff 73 04             	pushl  0x4(%ebx)
801038ac:	e8 db 2b 00 00       	call   8010648c <freevm>
        p->pid = 0;
801038b1:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801038b8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038bf:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038c3:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038ca:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801038d1:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038d8:	e8 d4 04 00 00       	call   80103db1 <release>
        return pid;
801038dd:	83 c4 10             	add    $0x10,%esp
}
801038e0:	89 f0                	mov    %esi,%eax
801038e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038e5:	5b                   	pop    %ebx
801038e6:	5e                   	pop    %esi
801038e7:	5d                   	pop    %ebp
801038e8:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038e9:	81 c3 84 00 00 00    	add    $0x84,%ebx
801038ef:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
801038f5:	73 12                	jae    80103909 <wait+0xa0>
      if(p->parent != curproc)
801038f7:	39 73 14             	cmp    %esi,0x14(%ebx)
801038fa:	75 ed                	jne    801038e9 <wait+0x80>
      if(p->state == ZOMBIE){
801038fc:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103900:	74 8f                	je     80103891 <wait+0x28>
      havekids = 1;
80103902:	b8 01 00 00 00       	mov    $0x1,%eax
80103907:	eb e0                	jmp    801038e9 <wait+0x80>
    if(!havekids || curproc->killed){
80103909:	85 c0                	test   %eax,%eax
8010390b:	74 06                	je     80103913 <wait+0xaa>
8010390d:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103911:	74 17                	je     8010392a <wait+0xc1>
      release(&ptable.lock);
80103913:	83 ec 0c             	sub    $0xc,%esp
80103916:	68 20 2d 11 80       	push   $0x80112d20
8010391b:	e8 91 04 00 00       	call   80103db1 <release>
      return -1;
80103920:	83 c4 10             	add    $0x10,%esp
80103923:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103928:	eb b6                	jmp    801038e0 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010392a:	83 ec 08             	sub    $0x8,%esp
8010392d:	68 20 2d 11 80       	push   $0x80112d20
80103932:	56                   	push   %esi
80103933:	e8 a0 fe ff ff       	call   801037d8 <sleep>
    havekids = 0;
80103938:	83 c4 10             	add    $0x10,%esp
8010393b:	e9 45 ff ff ff       	jmp    80103885 <wait+0x1c>

80103940 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
80103943:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103946:	68 20 2d 11 80       	push   $0x80112d20
8010394b:	e8 fc 03 00 00       	call   80103d4c <acquire>
  wakeup1(chan);
80103950:	8b 45 08             	mov    0x8(%ebp),%eax
80103953:	e8 39 f7 ff ff       	call   80103091 <wakeup1>
  release(&ptable.lock);
80103958:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010395f:	e8 4d 04 00 00       	call   80103db1 <release>
}
80103964:	83 c4 10             	add    $0x10,%esp
80103967:	c9                   	leave  
80103968:	c3                   	ret    

80103969 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	53                   	push   %ebx
8010396d:	83 ec 10             	sub    $0x10,%esp
80103970:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103973:	68 20 2d 11 80       	push   $0x80112d20
80103978:	e8 cf 03 00 00       	call   80103d4c <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010397d:	83 c4 10             	add    $0x10,%esp
80103980:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103985:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
8010398a:	73 3c                	jae    801039c8 <kill+0x5f>
    if(p->pid == pid){
8010398c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010398f:	74 07                	je     80103998 <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103991:	05 84 00 00 00       	add    $0x84,%eax
80103996:	eb ed                	jmp    80103985 <kill+0x1c>
      p->killed = 1;
80103998:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010399f:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801039a3:	74 1a                	je     801039bf <kill+0x56>
        p->state = RUNNABLE;
      release(&ptable.lock);
801039a5:	83 ec 0c             	sub    $0xc,%esp
801039a8:	68 20 2d 11 80       	push   $0x80112d20
801039ad:	e8 ff 03 00 00       	call   80103db1 <release>
      return 0;
801039b2:	83 c4 10             	add    $0x10,%esp
801039b5:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039bd:	c9                   	leave  
801039be:	c3                   	ret    
        p->state = RUNNABLE;
801039bf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801039c6:	eb dd                	jmp    801039a5 <kill+0x3c>
  release(&ptable.lock);
801039c8:	83 ec 0c             	sub    $0xc,%esp
801039cb:	68 20 2d 11 80       	push   $0x80112d20
801039d0:	e8 dc 03 00 00       	call   80103db1 <release>
  return -1;
801039d5:	83 c4 10             	add    $0x10,%esp
801039d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039dd:	eb db                	jmp    801039ba <kill+0x51>

801039df <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801039df:	55                   	push   %ebp
801039e0:	89 e5                	mov    %esp,%ebp
801039e2:	56                   	push   %esi
801039e3:	53                   	push   %ebx
801039e4:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039e7:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801039ec:	eb 36                	jmp    80103a24 <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801039ee:	b8 58 6e 10 80       	mov    $0x80106e58,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801039f3:	8d 53 6c             	lea    0x6c(%ebx),%edx
801039f6:	52                   	push   %edx
801039f7:	50                   	push   %eax
801039f8:	ff 73 10             	pushl  0x10(%ebx)
801039fb:	68 5c 6e 10 80       	push   $0x80106e5c
80103a00:	e8 06 cc ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a05:	83 c4 10             	add    $0x10,%esp
80103a08:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a0c:	74 3c                	je     80103a4a <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a0e:	83 ec 0c             	sub    $0xc,%esp
80103a11:	68 ef 71 10 80       	push   $0x801071ef
80103a16:	e8 f0 cb ff ff       	call   8010060b <cprintf>
80103a1b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a1e:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103a24:	81 fb 54 4e 11 80    	cmp    $0x80114e54,%ebx
80103a2a:	73 61                	jae    80103a8d <procdump+0xae>
    if(p->state == UNUSED)
80103a2c:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a2f:	85 c0                	test   %eax,%eax
80103a31:	74 eb                	je     80103a1e <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a33:	83 f8 05             	cmp    $0x5,%eax
80103a36:	77 b6                	ja     801039ee <procdump+0xf>
80103a38:	8b 04 85 b8 6e 10 80 	mov    -0x7fef9148(,%eax,4),%eax
80103a3f:	85 c0                	test   %eax,%eax
80103a41:	75 b0                	jne    801039f3 <procdump+0x14>
      state = "???";
80103a43:	b8 58 6e 10 80       	mov    $0x80106e58,%eax
80103a48:	eb a9                	jmp    801039f3 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a4a:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a4d:	8b 40 0c             	mov    0xc(%eax),%eax
80103a50:	83 c0 08             	add    $0x8,%eax
80103a53:	83 ec 08             	sub    $0x8,%esp
80103a56:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a59:	52                   	push   %edx
80103a5a:	50                   	push   %eax
80103a5b:	e8 cb 01 00 00       	call   80103c2b <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a60:	83 c4 10             	add    $0x10,%esp
80103a63:	be 00 00 00 00       	mov    $0x0,%esi
80103a68:	eb 14                	jmp    80103a7e <procdump+0x9f>
        cprintf(" %p", pc[i]);
80103a6a:	83 ec 08             	sub    $0x8,%esp
80103a6d:	50                   	push   %eax
80103a6e:	68 e1 67 10 80       	push   $0x801067e1
80103a73:	e8 93 cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a78:	83 c6 01             	add    $0x1,%esi
80103a7b:	83 c4 10             	add    $0x10,%esp
80103a7e:	83 fe 09             	cmp    $0x9,%esi
80103a81:	7f 8b                	jg     80103a0e <procdump+0x2f>
80103a83:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a87:	85 c0                	test   %eax,%eax
80103a89:	75 df                	jne    80103a6a <procdump+0x8b>
80103a8b:	eb 81                	jmp    80103a0e <procdump+0x2f>
  }
}
80103a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a90:	5b                   	pop    %ebx
80103a91:	5e                   	pop    %esi
80103a92:	5d                   	pop    %ebp
80103a93:	c3                   	ret    

80103a94 <getprocessesinfo_helper>:

int getprocessesinfo_helper(struct processes_info *my_process_info){
80103a94:	55                   	push   %ebp
80103a95:	89 e5                	mov    %esp,%ebp
80103a97:	53                   	push   %ebx
80103a98:	83 ec 10             	sub    $0x10,%esp
80103a9b:	8b 5d 08             	mov    0x8(%ebp),%ebx

  struct proc *p;

  acquire(&ptable.lock);
80103a9e:	68 20 2d 11 80       	push   $0x80112d20
80103aa3:	e8 a4 02 00 00       	call   80103d4c <acquire>
  int i = 0;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103aa8:	83 c4 10             	add    $0x10,%esp
  int i = 0;
80103aab:	ba 00 00 00 00       	mov    $0x0,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ab0:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103ab5:	eb 05                	jmp    80103abc <getprocessesinfo_helper+0x28>
80103ab7:	05 84 00 00 00       	add    $0x84,%eax
80103abc:	3d 54 4e 11 80       	cmp    $0x80114e54,%eax
80103ac1:	73 2b                	jae    80103aee <getprocessesinfo_helper+0x5a>
    if(p->state != UNUSED){
80103ac3:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
80103ac7:	74 ee                	je     80103ab7 <getprocessesinfo_helper+0x23>
      //cprintf("PID %d has %d tickets! \n", p->pid, p->tickets);
      my_process_info->pids[i] = p->pid;
80103ac9:	8b 48 10             	mov    0x10(%eax),%ecx
80103acc:	89 4c 93 04          	mov    %ecx,0x4(%ebx,%edx,4)
      my_process_info->tickets[i] = p->tickets;
80103ad0:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80103ad6:	89 8c 93 04 02 00 00 	mov    %ecx,0x204(%ebx,%edx,4)
      my_process_info->times_scheduled[i] = p->num_times_scheduled;
80103add:	8b 48 7c             	mov    0x7c(%eax),%ecx
80103ae0:	89 8c 93 04 01 00 00 	mov    %ecx,0x104(%ebx,%edx,4)
      my_process_info->num_processes = ++i;
80103ae7:	83 c2 01             	add    $0x1,%edx
80103aea:	89 13                	mov    %edx,(%ebx)
80103aec:	eb c9                	jmp    80103ab7 <getprocessesinfo_helper+0x23>

    }
    
  }
  
  release(&ptable.lock);
80103aee:	83 ec 0c             	sub    $0xc,%esp
80103af1:	68 20 2d 11 80       	push   $0x80112d20
80103af6:	e8 b6 02 00 00       	call   80103db1 <release>
  return 0;
}
80103afb:	b8 00 00 00 00       	mov    $0x0,%eax
80103b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b03:	c9                   	leave  
80103b04:	c3                   	ret    

80103b05 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103b05:	55                   	push   %ebp
80103b06:	89 e5                	mov    %esp,%ebp
80103b08:	53                   	push   %ebx
80103b09:	83 ec 0c             	sub    $0xc,%esp
80103b0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103b0f:	68 d0 6e 10 80       	push   $0x80106ed0
80103b14:	8d 43 04             	lea    0x4(%ebx),%eax
80103b17:	50                   	push   %eax
80103b18:	e8 f3 00 00 00       	call   80103c10 <initlock>
  lk->name = name;
80103b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b20:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b23:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b29:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b30:	83 c4 10             	add    $0x10,%esp
80103b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b36:	c9                   	leave  
80103b37:	c3                   	ret    

80103b38 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b38:	55                   	push   %ebp
80103b39:	89 e5                	mov    %esp,%ebp
80103b3b:	56                   	push   %esi
80103b3c:	53                   	push   %ebx
80103b3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b40:	8d 73 04             	lea    0x4(%ebx),%esi
80103b43:	83 ec 0c             	sub    $0xc,%esp
80103b46:	56                   	push   %esi
80103b47:	e8 00 02 00 00       	call   80103d4c <acquire>
  while (lk->locked) {
80103b4c:	83 c4 10             	add    $0x10,%esp
80103b4f:	eb 0d                	jmp    80103b5e <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b51:	83 ec 08             	sub    $0x8,%esp
80103b54:	56                   	push   %esi
80103b55:	53                   	push   %ebx
80103b56:	e8 7d fc ff ff       	call   801037d8 <sleep>
80103b5b:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b5e:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b61:	75 ee                	jne    80103b51 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b63:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b69:	e8 35 f7 ff ff       	call   801032a3 <myproc>
80103b6e:	8b 40 10             	mov    0x10(%eax),%eax
80103b71:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b74:	83 ec 0c             	sub    $0xc,%esp
80103b77:	56                   	push   %esi
80103b78:	e8 34 02 00 00       	call   80103db1 <release>
}
80103b7d:	83 c4 10             	add    $0x10,%esp
80103b80:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b83:	5b                   	pop    %ebx
80103b84:	5e                   	pop    %esi
80103b85:	5d                   	pop    %ebp
80103b86:	c3                   	ret    

80103b87 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b87:	55                   	push   %ebp
80103b88:	89 e5                	mov    %esp,%ebp
80103b8a:	56                   	push   %esi
80103b8b:	53                   	push   %ebx
80103b8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b8f:	8d 73 04             	lea    0x4(%ebx),%esi
80103b92:	83 ec 0c             	sub    $0xc,%esp
80103b95:	56                   	push   %esi
80103b96:	e8 b1 01 00 00       	call   80103d4c <acquire>
  lk->locked = 0;
80103b9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ba1:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ba8:	89 1c 24             	mov    %ebx,(%esp)
80103bab:	e8 90 fd ff ff       	call   80103940 <wakeup>
  release(&lk->lk);
80103bb0:	89 34 24             	mov    %esi,(%esp)
80103bb3:	e8 f9 01 00 00       	call   80103db1 <release>
}
80103bb8:	83 c4 10             	add    $0x10,%esp
80103bbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bbe:	5b                   	pop    %ebx
80103bbf:	5e                   	pop    %esi
80103bc0:	5d                   	pop    %ebp
80103bc1:	c3                   	ret    

80103bc2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bc2:	55                   	push   %ebp
80103bc3:	89 e5                	mov    %esp,%ebp
80103bc5:	56                   	push   %esi
80103bc6:	53                   	push   %ebx
80103bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103bca:	8d 73 04             	lea    0x4(%ebx),%esi
80103bcd:	83 ec 0c             	sub    $0xc,%esp
80103bd0:	56                   	push   %esi
80103bd1:	e8 76 01 00 00       	call   80103d4c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bd6:	83 c4 10             	add    $0x10,%esp
80103bd9:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bdc:	75 17                	jne    80103bf5 <holdingsleep+0x33>
80103bde:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103be3:	83 ec 0c             	sub    $0xc,%esp
80103be6:	56                   	push   %esi
80103be7:	e8 c5 01 00 00       	call   80103db1 <release>
  return r;
}
80103bec:	89 d8                	mov    %ebx,%eax
80103bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bf1:	5b                   	pop    %ebx
80103bf2:	5e                   	pop    %esi
80103bf3:	5d                   	pop    %ebp
80103bf4:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103bf5:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103bf8:	e8 a6 f6 ff ff       	call   801032a3 <myproc>
80103bfd:	3b 58 10             	cmp    0x10(%eax),%ebx
80103c00:	74 07                	je     80103c09 <holdingsleep+0x47>
80103c02:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c07:	eb da                	jmp    80103be3 <holdingsleep+0x21>
80103c09:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c0e:	eb d3                	jmp    80103be3 <holdingsleep+0x21>

80103c10 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103c10:	55                   	push   %ebp
80103c11:	89 e5                	mov    %esp,%ebp
80103c13:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103c16:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c19:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c22:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c29:	5d                   	pop    %ebp
80103c2a:	c3                   	ret    

80103c2b <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c2b:	55                   	push   %ebp
80103c2c:	89 e5                	mov    %esp,%ebp
80103c2e:	53                   	push   %ebx
80103c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c32:	8b 45 08             	mov    0x8(%ebp),%eax
80103c35:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c38:	b8 00 00 00 00       	mov    $0x0,%eax
80103c3d:	83 f8 09             	cmp    $0x9,%eax
80103c40:	7f 25                	jg     80103c67 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c42:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c48:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c4e:	77 17                	ja     80103c67 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c50:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c53:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c56:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c58:	83 c0 01             	add    $0x1,%eax
80103c5b:	eb e0                	jmp    80103c3d <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c5d:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c64:	83 c0 01             	add    $0x1,%eax
80103c67:	83 f8 09             	cmp    $0x9,%eax
80103c6a:	7e f1                	jle    80103c5d <getcallerpcs+0x32>
}
80103c6c:	5b                   	pop    %ebx
80103c6d:	5d                   	pop    %ebp
80103c6e:	c3                   	ret    

80103c6f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c6f:	55                   	push   %ebp
80103c70:	89 e5                	mov    %esp,%ebp
80103c72:	53                   	push   %ebx
80103c73:	83 ec 04             	sub    $0x4,%esp
80103c76:	9c                   	pushf  
80103c77:	5b                   	pop    %ebx
  asm volatile("cli");
80103c78:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c79:	e8 ae f5 ff ff       	call   8010322c <mycpu>
80103c7e:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c85:	74 12                	je     80103c99 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c87:	e8 a0 f5 ff ff       	call   8010322c <mycpu>
80103c8c:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c93:	83 c4 04             	add    $0x4,%esp
80103c96:	5b                   	pop    %ebx
80103c97:	5d                   	pop    %ebp
80103c98:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c99:	e8 8e f5 ff ff       	call   8010322c <mycpu>
80103c9e:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ca4:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103caa:	eb db                	jmp    80103c87 <pushcli+0x18>

80103cac <popcli>:

void
popcli(void)
{
80103cac:	55                   	push   %ebp
80103cad:	89 e5                	mov    %esp,%ebp
80103caf:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cb2:	9c                   	pushf  
80103cb3:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cb4:	f6 c4 02             	test   $0x2,%ah
80103cb7:	75 28                	jne    80103ce1 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103cb9:	e8 6e f5 ff ff       	call   8010322c <mycpu>
80103cbe:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cc4:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cc7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103ccd:	85 d2                	test   %edx,%edx
80103ccf:	78 1d                	js     80103cee <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cd1:	e8 56 f5 ff ff       	call   8010322c <mycpu>
80103cd6:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cdd:	74 1c                	je     80103cfb <popcli+0x4f>
    sti();
}
80103cdf:	c9                   	leave  
80103ce0:	c3                   	ret    
    panic("popcli - interruptible");
80103ce1:	83 ec 0c             	sub    $0xc,%esp
80103ce4:	68 db 6e 10 80       	push   $0x80106edb
80103ce9:	e8 5a c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103cee:	83 ec 0c             	sub    $0xc,%esp
80103cf1:	68 f2 6e 10 80       	push   $0x80106ef2
80103cf6:	e8 4d c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cfb:	e8 2c f5 ff ff       	call   8010322c <mycpu>
80103d00:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103d07:	74 d6                	je     80103cdf <popcli+0x33>
  asm volatile("sti");
80103d09:	fb                   	sti    
}
80103d0a:	eb d3                	jmp    80103cdf <popcli+0x33>

80103d0c <holding>:
{
80103d0c:	55                   	push   %ebp
80103d0d:	89 e5                	mov    %esp,%ebp
80103d0f:	53                   	push   %ebx
80103d10:	83 ec 04             	sub    $0x4,%esp
80103d13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103d16:	e8 54 ff ff ff       	call   80103c6f <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d1b:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d1e:	75 12                	jne    80103d32 <holding+0x26>
80103d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d25:	e8 82 ff ff ff       	call   80103cac <popcli>
}
80103d2a:	89 d8                	mov    %ebx,%eax
80103d2c:	83 c4 04             	add    $0x4,%esp
80103d2f:	5b                   	pop    %ebx
80103d30:	5d                   	pop    %ebp
80103d31:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d32:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d35:	e8 f2 f4 ff ff       	call   8010322c <mycpu>
80103d3a:	39 c3                	cmp    %eax,%ebx
80103d3c:	74 07                	je     80103d45 <holding+0x39>
80103d3e:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d43:	eb e0                	jmp    80103d25 <holding+0x19>
80103d45:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d4a:	eb d9                	jmp    80103d25 <holding+0x19>

80103d4c <acquire>:
{
80103d4c:	55                   	push   %ebp
80103d4d:	89 e5                	mov    %esp,%ebp
80103d4f:	53                   	push   %ebx
80103d50:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d53:	e8 17 ff ff ff       	call   80103c6f <pushcli>
  if(holding(lk))
80103d58:	83 ec 0c             	sub    $0xc,%esp
80103d5b:	ff 75 08             	pushl  0x8(%ebp)
80103d5e:	e8 a9 ff ff ff       	call   80103d0c <holding>
80103d63:	83 c4 10             	add    $0x10,%esp
80103d66:	85 c0                	test   %eax,%eax
80103d68:	75 3a                	jne    80103da4 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d6d:	b8 01 00 00 00       	mov    $0x1,%eax
80103d72:	f0 87 02             	lock xchg %eax,(%edx)
80103d75:	85 c0                	test   %eax,%eax
80103d77:	75 f1                	jne    80103d6a <acquire+0x1e>
  __sync_synchronize();
80103d79:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d81:	e8 a6 f4 ff ff       	call   8010322c <mycpu>
80103d86:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d89:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8c:	83 c0 0c             	add    $0xc,%eax
80103d8f:	83 ec 08             	sub    $0x8,%esp
80103d92:	50                   	push   %eax
80103d93:	8d 45 08             	lea    0x8(%ebp),%eax
80103d96:	50                   	push   %eax
80103d97:	e8 8f fe ff ff       	call   80103c2b <getcallerpcs>
}
80103d9c:	83 c4 10             	add    $0x10,%esp
80103d9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103da2:	c9                   	leave  
80103da3:	c3                   	ret    
    panic("acquire");
80103da4:	83 ec 0c             	sub    $0xc,%esp
80103da7:	68 f9 6e 10 80       	push   $0x80106ef9
80103dac:	e8 97 c5 ff ff       	call   80100348 <panic>

80103db1 <release>:
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	53                   	push   %ebx
80103db5:	83 ec 10             	sub    $0x10,%esp
80103db8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103dbb:	53                   	push   %ebx
80103dbc:	e8 4b ff ff ff       	call   80103d0c <holding>
80103dc1:	83 c4 10             	add    $0x10,%esp
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	74 23                	je     80103deb <release+0x3a>
  lk->pcs[0] = 0;
80103dc8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103dcf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dd6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ddb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103de1:	e8 c6 fe ff ff       	call   80103cac <popcli>
}
80103de6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103de9:	c9                   	leave  
80103dea:	c3                   	ret    
    panic("release");
80103deb:	83 ec 0c             	sub    $0xc,%esp
80103dee:	68 01 6f 10 80       	push   $0x80106f01
80103df3:	e8 50 c5 ff ff       	call   80100348 <panic>

80103df8 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103df8:	55                   	push   %ebp
80103df9:	89 e5                	mov    %esp,%ebp
80103dfb:	57                   	push   %edi
80103dfc:	53                   	push   %ebx
80103dfd:	8b 55 08             	mov    0x8(%ebp),%edx
80103e00:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103e03:	f6 c2 03             	test   $0x3,%dl
80103e06:	75 05                	jne    80103e0d <memset+0x15>
80103e08:	f6 c1 03             	test   $0x3,%cl
80103e0b:	74 0e                	je     80103e1b <memset+0x23>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80103e0d:	89 d7                	mov    %edx,%edi
80103e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e12:	fc                   	cld    
80103e13:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103e15:	89 d0                	mov    %edx,%eax
80103e17:	5b                   	pop    %ebx
80103e18:	5f                   	pop    %edi
80103e19:	5d                   	pop    %ebp
80103e1a:	c3                   	ret    
    c &= 0xFF;
80103e1b:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e1f:	c1 e9 02             	shr    $0x2,%ecx
80103e22:	89 f8                	mov    %edi,%eax
80103e24:	c1 e0 18             	shl    $0x18,%eax
80103e27:	89 fb                	mov    %edi,%ebx
80103e29:	c1 e3 10             	shl    $0x10,%ebx
80103e2c:	09 d8                	or     %ebx,%eax
80103e2e:	89 fb                	mov    %edi,%ebx
80103e30:	c1 e3 08             	shl    $0x8,%ebx
80103e33:	09 d8                	or     %ebx,%eax
80103e35:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80103e37:	89 d7                	mov    %edx,%edi
80103e39:	fc                   	cld    
80103e3a:	f3 ab                	rep stos %eax,%es:(%edi)
80103e3c:	eb d7                	jmp    80103e15 <memset+0x1d>

80103e3e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e3e:	55                   	push   %ebp
80103e3f:	89 e5                	mov    %esp,%ebp
80103e41:	56                   	push   %esi
80103e42:	53                   	push   %ebx
80103e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e46:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e49:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e4c:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e4f:	85 c0                	test   %eax,%eax
80103e51:	74 1c                	je     80103e6f <memcmp+0x31>
    if(*s1 != *s2)
80103e53:	0f b6 01             	movzbl (%ecx),%eax
80103e56:	0f b6 1a             	movzbl (%edx),%ebx
80103e59:	38 d8                	cmp    %bl,%al
80103e5b:	75 0a                	jne    80103e67 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e5d:	83 c1 01             	add    $0x1,%ecx
80103e60:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e63:	89 f0                	mov    %esi,%eax
80103e65:	eb e5                	jmp    80103e4c <memcmp+0xe>
      return *s1 - *s2;
80103e67:	0f b6 c0             	movzbl %al,%eax
80103e6a:	0f b6 db             	movzbl %bl,%ebx
80103e6d:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e6f:	5b                   	pop    %ebx
80103e70:	5e                   	pop    %esi
80103e71:	5d                   	pop    %ebp
80103e72:	c3                   	ret    

80103e73 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e73:	55                   	push   %ebp
80103e74:	89 e5                	mov    %esp,%ebp
80103e76:	56                   	push   %esi
80103e77:	53                   	push   %ebx
80103e78:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e7e:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e81:	39 c1                	cmp    %eax,%ecx
80103e83:	73 3a                	jae    80103ebf <memmove+0x4c>
80103e85:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e88:	39 c3                	cmp    %eax,%ebx
80103e8a:	76 37                	jbe    80103ec3 <memmove+0x50>
    s += n;
    d += n;
80103e8c:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e8f:	eb 0d                	jmp    80103e9e <memmove+0x2b>
      *--d = *--s;
80103e91:	83 eb 01             	sub    $0x1,%ebx
80103e94:	83 e9 01             	sub    $0x1,%ecx
80103e97:	0f b6 13             	movzbl (%ebx),%edx
80103e9a:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e9c:	89 f2                	mov    %esi,%edx
80103e9e:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ea1:	85 d2                	test   %edx,%edx
80103ea3:	75 ec                	jne    80103e91 <memmove+0x1e>
80103ea5:	eb 14                	jmp    80103ebb <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103ea7:	0f b6 11             	movzbl (%ecx),%edx
80103eaa:	88 13                	mov    %dl,(%ebx)
80103eac:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103eaf:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103eb2:	89 f2                	mov    %esi,%edx
80103eb4:	8d 72 ff             	lea    -0x1(%edx),%esi
80103eb7:	85 d2                	test   %edx,%edx
80103eb9:	75 ec                	jne    80103ea7 <memmove+0x34>

  return dst;
}
80103ebb:	5b                   	pop    %ebx
80103ebc:	5e                   	pop    %esi
80103ebd:	5d                   	pop    %ebp
80103ebe:	c3                   	ret    
80103ebf:	89 c3                	mov    %eax,%ebx
80103ec1:	eb f1                	jmp    80103eb4 <memmove+0x41>
80103ec3:	89 c3                	mov    %eax,%ebx
80103ec5:	eb ed                	jmp    80103eb4 <memmove+0x41>

80103ec7 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103ec7:	55                   	push   %ebp
80103ec8:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103eca:	ff 75 10             	pushl  0x10(%ebp)
80103ecd:	ff 75 0c             	pushl  0xc(%ebp)
80103ed0:	ff 75 08             	pushl  0x8(%ebp)
80103ed3:	e8 9b ff ff ff       	call   80103e73 <memmove>
}
80103ed8:	c9                   	leave  
80103ed9:	c3                   	ret    

80103eda <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103eda:	55                   	push   %ebp
80103edb:	89 e5                	mov    %esp,%ebp
80103edd:	53                   	push   %ebx
80103ede:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103ee7:	eb 09                	jmp    80103ef2 <strncmp+0x18>
    n--, p++, q++;
80103ee9:	83 e8 01             	sub    $0x1,%eax
80103eec:	83 c2 01             	add    $0x1,%edx
80103eef:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103ef2:	85 c0                	test   %eax,%eax
80103ef4:	74 0b                	je     80103f01 <strncmp+0x27>
80103ef6:	0f b6 1a             	movzbl (%edx),%ebx
80103ef9:	84 db                	test   %bl,%bl
80103efb:	74 04                	je     80103f01 <strncmp+0x27>
80103efd:	3a 19                	cmp    (%ecx),%bl
80103eff:	74 e8                	je     80103ee9 <strncmp+0xf>
  if(n == 0)
80103f01:	85 c0                	test   %eax,%eax
80103f03:	74 0b                	je     80103f10 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103f05:	0f b6 02             	movzbl (%edx),%eax
80103f08:	0f b6 11             	movzbl (%ecx),%edx
80103f0b:	29 d0                	sub    %edx,%eax
}
80103f0d:	5b                   	pop    %ebx
80103f0e:	5d                   	pop    %ebp
80103f0f:	c3                   	ret    
    return 0;
80103f10:	b8 00 00 00 00       	mov    $0x0,%eax
80103f15:	eb f6                	jmp    80103f0d <strncmp+0x33>

80103f17 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f17:	55                   	push   %ebp
80103f18:	89 e5                	mov    %esp,%ebp
80103f1a:	57                   	push   %edi
80103f1b:	56                   	push   %esi
80103f1c:	53                   	push   %ebx
80103f1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f20:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f23:	8b 45 08             	mov    0x8(%ebp),%eax
80103f26:	eb 04                	jmp    80103f2c <strncpy+0x15>
80103f28:	89 fb                	mov    %edi,%ebx
80103f2a:	89 f0                	mov    %esi,%eax
80103f2c:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f2f:	85 c9                	test   %ecx,%ecx
80103f31:	7e 1d                	jle    80103f50 <strncpy+0x39>
80103f33:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f36:	8d 70 01             	lea    0x1(%eax),%esi
80103f39:	0f b6 1b             	movzbl (%ebx),%ebx
80103f3c:	88 18                	mov    %bl,(%eax)
80103f3e:	89 d1                	mov    %edx,%ecx
80103f40:	84 db                	test   %bl,%bl
80103f42:	75 e4                	jne    80103f28 <strncpy+0x11>
80103f44:	89 f0                	mov    %esi,%eax
80103f46:	eb 08                	jmp    80103f50 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f48:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f4b:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f4d:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f50:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f53:	85 d2                	test   %edx,%edx
80103f55:	7f f1                	jg     80103f48 <strncpy+0x31>
  return os;
}
80103f57:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5a:	5b                   	pop    %ebx
80103f5b:	5e                   	pop    %esi
80103f5c:	5f                   	pop    %edi
80103f5d:	5d                   	pop    %ebp
80103f5e:	c3                   	ret    

80103f5f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f5f:	55                   	push   %ebp
80103f60:	89 e5                	mov    %esp,%ebp
80103f62:	57                   	push   %edi
80103f63:	56                   	push   %esi
80103f64:	53                   	push   %ebx
80103f65:	8b 45 08             	mov    0x8(%ebp),%eax
80103f68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f6b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f6e:	85 d2                	test   %edx,%edx
80103f70:	7e 23                	jle    80103f95 <safestrcpy+0x36>
80103f72:	89 c1                	mov    %eax,%ecx
80103f74:	eb 04                	jmp    80103f7a <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f76:	89 fb                	mov    %edi,%ebx
80103f78:	89 f1                	mov    %esi,%ecx
80103f7a:	83 ea 01             	sub    $0x1,%edx
80103f7d:	85 d2                	test   %edx,%edx
80103f7f:	7e 11                	jle    80103f92 <safestrcpy+0x33>
80103f81:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f84:	8d 71 01             	lea    0x1(%ecx),%esi
80103f87:	0f b6 1b             	movzbl (%ebx),%ebx
80103f8a:	88 19                	mov    %bl,(%ecx)
80103f8c:	84 db                	test   %bl,%bl
80103f8e:	75 e6                	jne    80103f76 <safestrcpy+0x17>
80103f90:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f92:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f95:	5b                   	pop    %ebx
80103f96:	5e                   	pop    %esi
80103f97:	5f                   	pop    %edi
80103f98:	5d                   	pop    %ebp
80103f99:	c3                   	ret    

80103f9a <strlen>:

int
strlen(const char *s)
{
80103f9a:	55                   	push   %ebp
80103f9b:	89 e5                	mov    %esp,%ebp
80103f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103fa0:	b8 00 00 00 00       	mov    $0x0,%eax
80103fa5:	eb 03                	jmp    80103faa <strlen+0x10>
80103fa7:	83 c0 01             	add    $0x1,%eax
80103faa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103fae:	75 f7                	jne    80103fa7 <strlen+0xd>
    ;
  return n;
}
80103fb0:	5d                   	pop    %ebp
80103fb1:	c3                   	ret    

80103fb2 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103fb2:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103fb6:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fba:	55                   	push   %ebp
  pushl %ebx
80103fbb:	53                   	push   %ebx
  pushl %esi
80103fbc:	56                   	push   %esi
  pushl %edi
80103fbd:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fbe:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fc0:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fc2:	5f                   	pop    %edi
  popl %esi
80103fc3:	5e                   	pop    %esi
  popl %ebx
80103fc4:	5b                   	pop    %ebx
  popl %ebp
80103fc5:	5d                   	pop    %ebp
  ret
80103fc6:	c3                   	ret    

80103fc7 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fc7:	55                   	push   %ebp
80103fc8:	89 e5                	mov    %esp,%ebp
80103fca:	53                   	push   %ebx
80103fcb:	83 ec 04             	sub    $0x4,%esp
80103fce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fd1:	e8 cd f2 ff ff       	call   801032a3 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fd6:	8b 00                	mov    (%eax),%eax
80103fd8:	39 d8                	cmp    %ebx,%eax
80103fda:	76 19                	jbe    80103ff5 <fetchint+0x2e>
80103fdc:	8d 53 04             	lea    0x4(%ebx),%edx
80103fdf:	39 d0                	cmp    %edx,%eax
80103fe1:	72 19                	jb     80103ffc <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103fe3:	8b 13                	mov    (%ebx),%edx
80103fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe8:	89 10                	mov    %edx,(%eax)
  return 0;
80103fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fef:	83 c4 04             	add    $0x4,%esp
80103ff2:	5b                   	pop    %ebx
80103ff3:	5d                   	pop    %ebp
80103ff4:	c3                   	ret    
    return -1;
80103ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffa:	eb f3                	jmp    80103fef <fetchint+0x28>
80103ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104001:	eb ec                	jmp    80103fef <fetchint+0x28>

80104003 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104003:	55                   	push   %ebp
80104004:	89 e5                	mov    %esp,%ebp
80104006:	53                   	push   %ebx
80104007:	83 ec 04             	sub    $0x4,%esp
8010400a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010400d:	e8 91 f2 ff ff       	call   801032a3 <myproc>

  if(addr >= curproc->sz)
80104012:	39 18                	cmp    %ebx,(%eax)
80104014:	76 26                	jbe    8010403c <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80104016:	8b 55 0c             	mov    0xc(%ebp),%edx
80104019:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010401b:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010401d:	89 d8                	mov    %ebx,%eax
8010401f:	39 d0                	cmp    %edx,%eax
80104021:	73 0e                	jae    80104031 <fetchstr+0x2e>
    if(*s == 0)
80104023:	80 38 00             	cmpb   $0x0,(%eax)
80104026:	74 05                	je     8010402d <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104028:	83 c0 01             	add    $0x1,%eax
8010402b:	eb f2                	jmp    8010401f <fetchstr+0x1c>
      return s - *pp;
8010402d:	29 d8                	sub    %ebx,%eax
8010402f:	eb 05                	jmp    80104036 <fetchstr+0x33>
  }
  return -1;
80104031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104036:	83 c4 04             	add    $0x4,%esp
80104039:	5b                   	pop    %ebx
8010403a:	5d                   	pop    %ebp
8010403b:	c3                   	ret    
    return -1;
8010403c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104041:	eb f3                	jmp    80104036 <fetchstr+0x33>

80104043 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104043:	55                   	push   %ebp
80104044:	89 e5                	mov    %esp,%ebp
80104046:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104049:	e8 55 f2 ff ff       	call   801032a3 <myproc>
8010404e:	8b 50 18             	mov    0x18(%eax),%edx
80104051:	8b 45 08             	mov    0x8(%ebp),%eax
80104054:	c1 e0 02             	shl    $0x2,%eax
80104057:	03 42 44             	add    0x44(%edx),%eax
8010405a:	83 ec 08             	sub    $0x8,%esp
8010405d:	ff 75 0c             	pushl  0xc(%ebp)
80104060:	83 c0 04             	add    $0x4,%eax
80104063:	50                   	push   %eax
80104064:	e8 5e ff ff ff       	call   80103fc7 <fetchint>
}
80104069:	c9                   	leave  
8010406a:	c3                   	ret    

8010406b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010406b:	55                   	push   %ebp
8010406c:	89 e5                	mov    %esp,%ebp
8010406e:	56                   	push   %esi
8010406f:	53                   	push   %ebx
80104070:	83 ec 10             	sub    $0x10,%esp
80104073:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104076:	e8 28 f2 ff ff       	call   801032a3 <myproc>
8010407b:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010407d:	83 ec 08             	sub    $0x8,%esp
80104080:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104083:	50                   	push   %eax
80104084:	ff 75 08             	pushl  0x8(%ebp)
80104087:	e8 b7 ff ff ff       	call   80104043 <argint>
8010408c:	83 c4 10             	add    $0x10,%esp
8010408f:	85 c0                	test   %eax,%eax
80104091:	78 24                	js     801040b7 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104093:	85 db                	test   %ebx,%ebx
80104095:	78 27                	js     801040be <argptr+0x53>
80104097:	8b 16                	mov    (%esi),%edx
80104099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409c:	39 c2                	cmp    %eax,%edx
8010409e:	76 25                	jbe    801040c5 <argptr+0x5a>
801040a0:	01 c3                	add    %eax,%ebx
801040a2:	39 da                	cmp    %ebx,%edx
801040a4:	72 26                	jb     801040cc <argptr+0x61>
    return -1;
  *pp = (char*)i;
801040a6:	8b 55 0c             	mov    0xc(%ebp),%edx
801040a9:	89 02                	mov    %eax,(%edx)
  return 0;
801040ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040b3:	5b                   	pop    %ebx
801040b4:	5e                   	pop    %esi
801040b5:	5d                   	pop    %ebp
801040b6:	c3                   	ret    
    return -1;
801040b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040bc:	eb f2                	jmp    801040b0 <argptr+0x45>
    return -1;
801040be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c3:	eb eb                	jmp    801040b0 <argptr+0x45>
801040c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ca:	eb e4                	jmp    801040b0 <argptr+0x45>
801040cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d1:	eb dd                	jmp    801040b0 <argptr+0x45>

801040d3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040d3:	55                   	push   %ebp
801040d4:	89 e5                	mov    %esp,%ebp
801040d6:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040dc:	50                   	push   %eax
801040dd:	ff 75 08             	pushl  0x8(%ebp)
801040e0:	e8 5e ff ff ff       	call   80104043 <argint>
801040e5:	83 c4 10             	add    $0x10,%esp
801040e8:	85 c0                	test   %eax,%eax
801040ea:	78 13                	js     801040ff <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801040ec:	83 ec 08             	sub    $0x8,%esp
801040ef:	ff 75 0c             	pushl  0xc(%ebp)
801040f2:	ff 75 f4             	pushl  -0xc(%ebp)
801040f5:	e8 09 ff ff ff       	call   80104003 <fetchstr>
801040fa:	83 c4 10             	add    $0x10,%esp
}
801040fd:	c9                   	leave  
801040fe:	c3                   	ret    
    return -1;
801040ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104104:	eb f7                	jmp    801040fd <argstr+0x2a>

80104106 <syscall>:
[SYS_getprocessesinfo] sys_getprocessesinfo,
};

void
syscall(void)
{
80104106:	55                   	push   %ebp
80104107:	89 e5                	mov    %esp,%ebp
80104109:	53                   	push   %ebx
8010410a:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010410d:	e8 91 f1 ff ff       	call   801032a3 <myproc>
80104112:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104114:	8b 40 18             	mov    0x18(%eax),%eax
80104117:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010411a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010411d:	83 fa 1a             	cmp    $0x1a,%edx
80104120:	77 18                	ja     8010413a <syscall+0x34>
80104122:	8b 14 85 40 6f 10 80 	mov    -0x7fef90c0(,%eax,4),%edx
80104129:	85 d2                	test   %edx,%edx
8010412b:	74 0d                	je     8010413a <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
8010412d:	ff d2                	call   *%edx
8010412f:	8b 53 18             	mov    0x18(%ebx),%edx
80104132:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104135:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104138:	c9                   	leave  
80104139:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010413a:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010413d:	50                   	push   %eax
8010413e:	52                   	push   %edx
8010413f:	ff 73 10             	pushl  0x10(%ebx)
80104142:	68 09 6f 10 80       	push   $0x80106f09
80104147:	e8 bf c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
8010414c:	8b 43 18             	mov    0x18(%ebx),%eax
8010414f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104156:	83 c4 10             	add    $0x10,%esp
}
80104159:	eb da                	jmp    80104135 <syscall+0x2f>

8010415b <argfd>:
uint writeCount_global;
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010415b:	55                   	push   %ebp
8010415c:	89 e5                	mov    %esp,%ebp
8010415e:	56                   	push   %esi
8010415f:	53                   	push   %ebx
80104160:	83 ec 18             	sub    $0x18,%esp
80104163:	89 d6                	mov    %edx,%esi
80104165:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104167:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010416a:	52                   	push   %edx
8010416b:	50                   	push   %eax
8010416c:	e8 d2 fe ff ff       	call   80104043 <argint>
80104171:	83 c4 10             	add    $0x10,%esp
80104174:	85 c0                	test   %eax,%eax
80104176:	78 2e                	js     801041a6 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104178:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010417c:	77 2f                	ja     801041ad <argfd+0x52>
8010417e:	e8 20 f1 ff ff       	call   801032a3 <myproc>
80104183:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104186:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
8010418a:	85 c0                	test   %eax,%eax
8010418c:	74 26                	je     801041b4 <argfd+0x59>
    return -1;
  if(pfd)
8010418e:	85 f6                	test   %esi,%esi
80104190:	74 02                	je     80104194 <argfd+0x39>
    *pfd = fd;
80104192:	89 16                	mov    %edx,(%esi)
  if(pf)
80104194:	85 db                	test   %ebx,%ebx
80104196:	74 23                	je     801041bb <argfd+0x60>
    *pf = f;
80104198:	89 03                	mov    %eax,(%ebx)
  return 0;
8010419a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010419f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a2:	5b                   	pop    %ebx
801041a3:	5e                   	pop    %esi
801041a4:	5d                   	pop    %ebp
801041a5:	c3                   	ret    
    return -1;
801041a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ab:	eb f2                	jmp    8010419f <argfd+0x44>
    return -1;
801041ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b2:	eb eb                	jmp    8010419f <argfd+0x44>
801041b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b9:	eb e4                	jmp    8010419f <argfd+0x44>
  return 0;
801041bb:	b8 00 00 00 00       	mov    $0x0,%eax
801041c0:	eb dd                	jmp    8010419f <argfd+0x44>

801041c2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041c2:	55                   	push   %ebp
801041c3:	89 e5                	mov    %esp,%ebp
801041c5:	53                   	push   %ebx
801041c6:	83 ec 04             	sub    $0x4,%esp
801041c9:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041cb:	e8 d3 f0 ff ff       	call   801032a3 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041d0:	ba 00 00 00 00       	mov    $0x0,%edx
801041d5:	83 fa 0f             	cmp    $0xf,%edx
801041d8:	7f 18                	jg     801041f2 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801041da:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801041df:	74 05                	je     801041e6 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801041e1:	83 c2 01             	add    $0x1,%edx
801041e4:	eb ef                	jmp    801041d5 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801041e6:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801041ea:	89 d0                	mov    %edx,%eax
801041ec:	83 c4 04             	add    $0x4,%esp
801041ef:	5b                   	pop    %ebx
801041f0:	5d                   	pop    %ebp
801041f1:	c3                   	ret    
  return -1;
801041f2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801041f7:	eb f1                	jmp    801041ea <fdalloc+0x28>

801041f9 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801041f9:	55                   	push   %ebp
801041fa:	89 e5                	mov    %esp,%ebp
801041fc:	56                   	push   %esi
801041fd:	53                   	push   %ebx
801041fe:	83 ec 10             	sub    $0x10,%esp
80104201:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104203:	b8 20 00 00 00       	mov    $0x20,%eax
80104208:	89 c6                	mov    %eax,%esi
8010420a:	39 43 58             	cmp    %eax,0x58(%ebx)
8010420d:	76 2e                	jbe    8010423d <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010420f:	6a 10                	push   $0x10
80104211:	50                   	push   %eax
80104212:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104215:	50                   	push   %eax
80104216:	53                   	push   %ebx
80104217:	e8 45 d5 ff ff       	call   80101761 <readi>
8010421c:	83 c4 10             	add    $0x10,%esp
8010421f:	83 f8 10             	cmp    $0x10,%eax
80104222:	75 0c                	jne    80104230 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104224:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104229:	75 1e                	jne    80104249 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010422b:	8d 46 10             	lea    0x10(%esi),%eax
8010422e:	eb d8                	jmp    80104208 <isdirempty+0xf>
      panic("isdirempty: readi");
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	68 b0 6f 10 80       	push   $0x80106fb0
80104238:	e8 0b c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
8010423d:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104242:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104245:	5b                   	pop    %ebx
80104246:	5e                   	pop    %esi
80104247:	5d                   	pop    %ebp
80104248:	c3                   	ret    
      return 0;
80104249:	b8 00 00 00 00       	mov    $0x0,%eax
8010424e:	eb f2                	jmp    80104242 <isdirempty+0x49>

80104250 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104250:	55                   	push   %ebp
80104251:	89 e5                	mov    %esp,%ebp
80104253:	57                   	push   %edi
80104254:	56                   	push   %esi
80104255:	53                   	push   %ebx
80104256:	83 ec 34             	sub    $0x34,%esp
80104259:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010425c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010425f:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104262:	8d 55 da             	lea    -0x26(%ebp),%edx
80104265:	52                   	push   %edx
80104266:	50                   	push   %eax
80104267:	e8 7b d9 ff ff       	call   80101be7 <nameiparent>
8010426c:	89 c6                	mov    %eax,%esi
8010426e:	83 c4 10             	add    $0x10,%esp
80104271:	85 c0                	test   %eax,%eax
80104273:	0f 84 38 01 00 00    	je     801043b1 <create+0x161>
    return 0;
  ilock(dp);
80104279:	83 ec 0c             	sub    $0xc,%esp
8010427c:	50                   	push   %eax
8010427d:	e8 ed d2 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104282:	83 c4 0c             	add    $0xc,%esp
80104285:	6a 00                	push   $0x0
80104287:	8d 45 da             	lea    -0x26(%ebp),%eax
8010428a:	50                   	push   %eax
8010428b:	56                   	push   %esi
8010428c:	e8 0d d7 ff ff       	call   8010199e <dirlookup>
80104291:	89 c3                	mov    %eax,%ebx
80104293:	83 c4 10             	add    $0x10,%esp
80104296:	85 c0                	test   %eax,%eax
80104298:	74 3f                	je     801042d9 <create+0x89>
    iunlockput(dp);
8010429a:	83 ec 0c             	sub    $0xc,%esp
8010429d:	56                   	push   %esi
8010429e:	e8 73 d4 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
801042a3:	89 1c 24             	mov    %ebx,(%esp)
801042a6:	e8 c4 d2 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042ab:	83 c4 10             	add    $0x10,%esp
801042ae:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801042b3:	75 11                	jne    801042c6 <create+0x76>
801042b5:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042ba:	75 0a                	jne    801042c6 <create+0x76>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042bc:	89 d8                	mov    %ebx,%eax
801042be:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042c1:	5b                   	pop    %ebx
801042c2:	5e                   	pop    %esi
801042c3:	5f                   	pop    %edi
801042c4:	5d                   	pop    %ebp
801042c5:	c3                   	ret    
    iunlockput(ip);
801042c6:	83 ec 0c             	sub    $0xc,%esp
801042c9:	53                   	push   %ebx
801042ca:	e8 47 d4 ff ff       	call   80101716 <iunlockput>
    return 0;
801042cf:	83 c4 10             	add    $0x10,%esp
801042d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801042d7:	eb e3                	jmp    801042bc <create+0x6c>
  if((ip = ialloc(dp->dev, type)) == 0)
801042d9:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
801042dd:	83 ec 08             	sub    $0x8,%esp
801042e0:	50                   	push   %eax
801042e1:	ff 36                	pushl  (%esi)
801042e3:	e8 84 d0 ff ff       	call   8010136c <ialloc>
801042e8:	89 c3                	mov    %eax,%ebx
801042ea:	83 c4 10             	add    $0x10,%esp
801042ed:	85 c0                	test   %eax,%eax
801042ef:	74 55                	je     80104346 <create+0xf6>
  ilock(ip);
801042f1:	83 ec 0c             	sub    $0xc,%esp
801042f4:	50                   	push   %eax
801042f5:	e8 75 d2 ff ff       	call   8010156f <ilock>
  ip->major = major;
801042fa:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
801042fe:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104302:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104306:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
8010430c:	89 1c 24             	mov    %ebx,(%esp)
8010430f:	e8 fa d0 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104314:	83 c4 10             	add    $0x10,%esp
80104317:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010431c:	74 35                	je     80104353 <create+0x103>
  if(dirlink(dp, name, ip->inum) < 0)
8010431e:	83 ec 04             	sub    $0x4,%esp
80104321:	ff 73 04             	pushl  0x4(%ebx)
80104324:	8d 45 da             	lea    -0x26(%ebp),%eax
80104327:	50                   	push   %eax
80104328:	56                   	push   %esi
80104329:	e8 f0 d7 ff ff       	call   80101b1e <dirlink>
8010432e:	83 c4 10             	add    $0x10,%esp
80104331:	85 c0                	test   %eax,%eax
80104333:	78 6f                	js     801043a4 <create+0x154>
  iunlockput(dp);
80104335:	83 ec 0c             	sub    $0xc,%esp
80104338:	56                   	push   %esi
80104339:	e8 d8 d3 ff ff       	call   80101716 <iunlockput>
  return ip;
8010433e:	83 c4 10             	add    $0x10,%esp
80104341:	e9 76 ff ff ff       	jmp    801042bc <create+0x6c>
    panic("create: ialloc");
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	68 c2 6f 10 80       	push   $0x80106fc2
8010434e:	e8 f5 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104353:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104357:	83 c0 01             	add    $0x1,%eax
8010435a:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010435e:	83 ec 0c             	sub    $0xc,%esp
80104361:	56                   	push   %esi
80104362:	e8 a7 d0 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104367:	83 c4 0c             	add    $0xc,%esp
8010436a:	ff 73 04             	pushl  0x4(%ebx)
8010436d:	68 d2 6f 10 80       	push   $0x80106fd2
80104372:	53                   	push   %ebx
80104373:	e8 a6 d7 ff ff       	call   80101b1e <dirlink>
80104378:	83 c4 10             	add    $0x10,%esp
8010437b:	85 c0                	test   %eax,%eax
8010437d:	78 18                	js     80104397 <create+0x147>
8010437f:	83 ec 04             	sub    $0x4,%esp
80104382:	ff 76 04             	pushl  0x4(%esi)
80104385:	68 d1 6f 10 80       	push   $0x80106fd1
8010438a:	53                   	push   %ebx
8010438b:	e8 8e d7 ff ff       	call   80101b1e <dirlink>
80104390:	83 c4 10             	add    $0x10,%esp
80104393:	85 c0                	test   %eax,%eax
80104395:	79 87                	jns    8010431e <create+0xce>
      panic("create dots");
80104397:	83 ec 0c             	sub    $0xc,%esp
8010439a:	68 d4 6f 10 80       	push   $0x80106fd4
8010439f:	e8 a4 bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801043a4:	83 ec 0c             	sub    $0xc,%esp
801043a7:	68 e0 6f 10 80       	push   $0x80106fe0
801043ac:	e8 97 bf ff ff       	call   80100348 <panic>
    return 0;
801043b1:	89 c3                	mov    %eax,%ebx
801043b3:	e9 04 ff ff ff       	jmp    801042bc <create+0x6c>

801043b8 <sys_dup>:
{
801043b8:	55                   	push   %ebp
801043b9:	89 e5                	mov    %esp,%ebp
801043bb:	53                   	push   %ebx
801043bc:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043bf:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043c2:	ba 00 00 00 00       	mov    $0x0,%edx
801043c7:	b8 00 00 00 00       	mov    $0x0,%eax
801043cc:	e8 8a fd ff ff       	call   8010415b <argfd>
801043d1:	85 c0                	test   %eax,%eax
801043d3:	78 23                	js     801043f8 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d8:	e8 e5 fd ff ff       	call   801041c2 <fdalloc>
801043dd:	89 c3                	mov    %eax,%ebx
801043df:	85 c0                	test   %eax,%eax
801043e1:	78 1c                	js     801043ff <sys_dup+0x47>
  filedup(f);
801043e3:	83 ec 0c             	sub    $0xc,%esp
801043e6:	ff 75 f4             	pushl  -0xc(%ebp)
801043e9:	e8 a0 c8 ff ff       	call   80100c8e <filedup>
  return fd;
801043ee:	83 c4 10             	add    $0x10,%esp
}
801043f1:	89 d8                	mov    %ebx,%eax
801043f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043f6:	c9                   	leave  
801043f7:	c3                   	ret    
    return -1;
801043f8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043fd:	eb f2                	jmp    801043f1 <sys_dup+0x39>
    return -1;
801043ff:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104404:	eb eb                	jmp    801043f1 <sys_dup+0x39>

80104406 <sys_read>:
{
80104406:	55                   	push   %ebp
80104407:	89 e5                	mov    %esp,%ebp
80104409:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010440c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010440f:	ba 00 00 00 00       	mov    $0x0,%edx
80104414:	b8 00 00 00 00       	mov    $0x0,%eax
80104419:	e8 3d fd ff ff       	call   8010415b <argfd>
8010441e:	85 c0                	test   %eax,%eax
80104420:	78 43                	js     80104465 <sys_read+0x5f>
80104422:	83 ec 08             	sub    $0x8,%esp
80104425:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104428:	50                   	push   %eax
80104429:	6a 02                	push   $0x2
8010442b:	e8 13 fc ff ff       	call   80104043 <argint>
80104430:	83 c4 10             	add    $0x10,%esp
80104433:	85 c0                	test   %eax,%eax
80104435:	78 35                	js     8010446c <sys_read+0x66>
80104437:	83 ec 04             	sub    $0x4,%esp
8010443a:	ff 75 f0             	pushl  -0x10(%ebp)
8010443d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104440:	50                   	push   %eax
80104441:	6a 01                	push   $0x1
80104443:	e8 23 fc ff ff       	call   8010406b <argptr>
80104448:	83 c4 10             	add    $0x10,%esp
8010444b:	85 c0                	test   %eax,%eax
8010444d:	78 24                	js     80104473 <sys_read+0x6d>
  return fileread(f, p, n);
8010444f:	83 ec 04             	sub    $0x4,%esp
80104452:	ff 75 f0             	pushl  -0x10(%ebp)
80104455:	ff 75 ec             	pushl  -0x14(%ebp)
80104458:	ff 75 f4             	pushl  -0xc(%ebp)
8010445b:	e8 77 c9 ff ff       	call   80100dd7 <fileread>
80104460:	83 c4 10             	add    $0x10,%esp
}
80104463:	c9                   	leave  
80104464:	c3                   	ret    
    return -1;
80104465:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010446a:	eb f7                	jmp    80104463 <sys_read+0x5d>
8010446c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104471:	eb f0                	jmp    80104463 <sys_read+0x5d>
80104473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104478:	eb e9                	jmp    80104463 <sys_read+0x5d>

8010447a <sys_write>:
{
8010447a:	55                   	push   %ebp
8010447b:	89 e5                	mov    %esp,%ebp
8010447d:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104480:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104483:	ba 00 00 00 00       	mov    $0x0,%edx
80104488:	b8 00 00 00 00       	mov    $0x0,%eax
8010448d:	e8 c9 fc ff ff       	call   8010415b <argfd>
80104492:	85 c0                	test   %eax,%eax
80104494:	78 4a                	js     801044e0 <sys_write+0x66>
80104496:	83 ec 08             	sub    $0x8,%esp
80104499:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010449c:	50                   	push   %eax
8010449d:	6a 02                	push   $0x2
8010449f:	e8 9f fb ff ff       	call   80104043 <argint>
801044a4:	83 c4 10             	add    $0x10,%esp
801044a7:	85 c0                	test   %eax,%eax
801044a9:	78 3c                	js     801044e7 <sys_write+0x6d>
801044ab:	83 ec 04             	sub    $0x4,%esp
801044ae:	ff 75 f0             	pushl  -0x10(%ebp)
801044b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044b4:	50                   	push   %eax
801044b5:	6a 01                	push   $0x1
801044b7:	e8 af fb ff ff       	call   8010406b <argptr>
801044bc:	83 c4 10             	add    $0x10,%esp
801044bf:	85 c0                	test   %eax,%eax
801044c1:	78 2b                	js     801044ee <sys_write+0x74>
      writeCount_global++;
801044c3:	83 05 54 4e 11 80 01 	addl   $0x1,0x80114e54
  return filewrite(f, p, n);
801044ca:	83 ec 04             	sub    $0x4,%esp
801044cd:	ff 75 f0             	pushl  -0x10(%ebp)
801044d0:	ff 75 ec             	pushl  -0x14(%ebp)
801044d3:	ff 75 f4             	pushl  -0xc(%ebp)
801044d6:	e8 81 c9 ff ff       	call   80100e5c <filewrite>
801044db:	83 c4 10             	add    $0x10,%esp
}
801044de:	c9                   	leave  
801044df:	c3                   	ret    
    return -1;
801044e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e5:	eb f7                	jmp    801044de <sys_write+0x64>
801044e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ec:	eb f0                	jmp    801044de <sys_write+0x64>
801044ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044f3:	eb e9                	jmp    801044de <sys_write+0x64>

801044f5 <sys_close>:
{
801044f5:	55                   	push   %ebp
801044f6:	89 e5                	mov    %esp,%ebp
801044f8:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801044fb:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801044fe:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104501:	b8 00 00 00 00       	mov    $0x0,%eax
80104506:	e8 50 fc ff ff       	call   8010415b <argfd>
8010450b:	85 c0                	test   %eax,%eax
8010450d:	78 25                	js     80104534 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010450f:	e8 8f ed ff ff       	call   801032a3 <myproc>
80104514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104517:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010451e:	00 
  fileclose(f);
8010451f:	83 ec 0c             	sub    $0xc,%esp
80104522:	ff 75 f0             	pushl  -0x10(%ebp)
80104525:	e8 a9 c7 ff ff       	call   80100cd3 <fileclose>
  return 0;
8010452a:	83 c4 10             	add    $0x10,%esp
8010452d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104532:	c9                   	leave  
80104533:	c3                   	ret    
    return -1;
80104534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104539:	eb f7                	jmp    80104532 <sys_close+0x3d>

8010453b <sys_fstat>:
{
8010453b:	55                   	push   %ebp
8010453c:	89 e5                	mov    %esp,%ebp
8010453e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104541:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104544:	ba 00 00 00 00       	mov    $0x0,%edx
80104549:	b8 00 00 00 00       	mov    $0x0,%eax
8010454e:	e8 08 fc ff ff       	call   8010415b <argfd>
80104553:	85 c0                	test   %eax,%eax
80104555:	78 2a                	js     80104581 <sys_fstat+0x46>
80104557:	83 ec 04             	sub    $0x4,%esp
8010455a:	6a 14                	push   $0x14
8010455c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010455f:	50                   	push   %eax
80104560:	6a 01                	push   $0x1
80104562:	e8 04 fb ff ff       	call   8010406b <argptr>
80104567:	83 c4 10             	add    $0x10,%esp
8010456a:	85 c0                	test   %eax,%eax
8010456c:	78 1a                	js     80104588 <sys_fstat+0x4d>
  return filestat(f, st);
8010456e:	83 ec 08             	sub    $0x8,%esp
80104571:	ff 75 f0             	pushl  -0x10(%ebp)
80104574:	ff 75 f4             	pushl  -0xc(%ebp)
80104577:	e8 14 c8 ff ff       	call   80100d90 <filestat>
8010457c:	83 c4 10             	add    $0x10,%esp
}
8010457f:	c9                   	leave  
80104580:	c3                   	ret    
    return -1;
80104581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104586:	eb f7                	jmp    8010457f <sys_fstat+0x44>
80104588:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458d:	eb f0                	jmp    8010457f <sys_fstat+0x44>

8010458f <sys_link>:
{
8010458f:	55                   	push   %ebp
80104590:	89 e5                	mov    %esp,%ebp
80104592:	56                   	push   %esi
80104593:	53                   	push   %ebx
80104594:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104597:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010459a:	50                   	push   %eax
8010459b:	6a 00                	push   $0x0
8010459d:	e8 31 fb ff ff       	call   801040d3 <argstr>
801045a2:	83 c4 10             	add    $0x10,%esp
801045a5:	85 c0                	test   %eax,%eax
801045a7:	0f 88 32 01 00 00    	js     801046df <sys_link+0x150>
801045ad:	83 ec 08             	sub    $0x8,%esp
801045b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045b3:	50                   	push   %eax
801045b4:	6a 01                	push   $0x1
801045b6:	e8 18 fb ff ff       	call   801040d3 <argstr>
801045bb:	83 c4 10             	add    $0x10,%esp
801045be:	85 c0                	test   %eax,%eax
801045c0:	0f 88 20 01 00 00    	js     801046e6 <sys_link+0x157>
  begin_op();
801045c6:	e8 07 e2 ff ff       	call   801027d2 <begin_op>
  if((ip = namei(old)) == 0){
801045cb:	83 ec 0c             	sub    $0xc,%esp
801045ce:	ff 75 e0             	pushl  -0x20(%ebp)
801045d1:	e8 f9 d5 ff ff       	call   80101bcf <namei>
801045d6:	89 c3                	mov    %eax,%ebx
801045d8:	83 c4 10             	add    $0x10,%esp
801045db:	85 c0                	test   %eax,%eax
801045dd:	0f 84 99 00 00 00    	je     8010467c <sys_link+0xed>
  ilock(ip);
801045e3:	83 ec 0c             	sub    $0xc,%esp
801045e6:	50                   	push   %eax
801045e7:	e8 83 cf ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
801045ec:	83 c4 10             	add    $0x10,%esp
801045ef:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045f4:	0f 84 8e 00 00 00    	je     80104688 <sys_link+0xf9>
  ip->nlink++;
801045fa:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045fe:	83 c0 01             	add    $0x1,%eax
80104601:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104605:	83 ec 0c             	sub    $0xc,%esp
80104608:	53                   	push   %ebx
80104609:	e8 00 ce ff ff       	call   8010140e <iupdate>
  iunlock(ip);
8010460e:	89 1c 24             	mov    %ebx,(%esp)
80104611:	e8 1b d0 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104616:	83 c4 08             	add    $0x8,%esp
80104619:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010461c:	50                   	push   %eax
8010461d:	ff 75 e4             	pushl  -0x1c(%ebp)
80104620:	e8 c2 d5 ff ff       	call   80101be7 <nameiparent>
80104625:	89 c6                	mov    %eax,%esi
80104627:	83 c4 10             	add    $0x10,%esp
8010462a:	85 c0                	test   %eax,%eax
8010462c:	74 7e                	je     801046ac <sys_link+0x11d>
  ilock(dp);
8010462e:	83 ec 0c             	sub    $0xc,%esp
80104631:	50                   	push   %eax
80104632:	e8 38 cf ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104637:	83 c4 10             	add    $0x10,%esp
8010463a:	8b 03                	mov    (%ebx),%eax
8010463c:	39 06                	cmp    %eax,(%esi)
8010463e:	75 60                	jne    801046a0 <sys_link+0x111>
80104640:	83 ec 04             	sub    $0x4,%esp
80104643:	ff 73 04             	pushl  0x4(%ebx)
80104646:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104649:	50                   	push   %eax
8010464a:	56                   	push   %esi
8010464b:	e8 ce d4 ff ff       	call   80101b1e <dirlink>
80104650:	83 c4 10             	add    $0x10,%esp
80104653:	85 c0                	test   %eax,%eax
80104655:	78 49                	js     801046a0 <sys_link+0x111>
  iunlockput(dp);
80104657:	83 ec 0c             	sub    $0xc,%esp
8010465a:	56                   	push   %esi
8010465b:	e8 b6 d0 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104660:	89 1c 24             	mov    %ebx,(%esp)
80104663:	e8 0e d0 ff ff       	call   80101676 <iput>
  end_op();
80104668:	e8 df e1 ff ff       	call   8010284c <end_op>
  return 0;
8010466d:	83 c4 10             	add    $0x10,%esp
80104670:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104675:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104678:	5b                   	pop    %ebx
80104679:	5e                   	pop    %esi
8010467a:	5d                   	pop    %ebp
8010467b:	c3                   	ret    
    end_op();
8010467c:	e8 cb e1 ff ff       	call   8010284c <end_op>
    return -1;
80104681:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104686:	eb ed                	jmp    80104675 <sys_link+0xe6>
    iunlockput(ip);
80104688:	83 ec 0c             	sub    $0xc,%esp
8010468b:	53                   	push   %ebx
8010468c:	e8 85 d0 ff ff       	call   80101716 <iunlockput>
    end_op();
80104691:	e8 b6 e1 ff ff       	call   8010284c <end_op>
    return -1;
80104696:	83 c4 10             	add    $0x10,%esp
80104699:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010469e:	eb d5                	jmp    80104675 <sys_link+0xe6>
    iunlockput(dp);
801046a0:	83 ec 0c             	sub    $0xc,%esp
801046a3:	56                   	push   %esi
801046a4:	e8 6d d0 ff ff       	call   80101716 <iunlockput>
    goto bad;
801046a9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046ac:	83 ec 0c             	sub    $0xc,%esp
801046af:	53                   	push   %ebx
801046b0:	e8 ba ce ff ff       	call   8010156f <ilock>
  ip->nlink--;
801046b5:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046b9:	83 e8 01             	sub    $0x1,%eax
801046bc:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046c0:	89 1c 24             	mov    %ebx,(%esp)
801046c3:	e8 46 cd ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801046c8:	89 1c 24             	mov    %ebx,(%esp)
801046cb:	e8 46 d0 ff ff       	call   80101716 <iunlockput>
  end_op();
801046d0:	e8 77 e1 ff ff       	call   8010284c <end_op>
  return -1;
801046d5:	83 c4 10             	add    $0x10,%esp
801046d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046dd:	eb 96                	jmp    80104675 <sys_link+0xe6>
    return -1;
801046df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e4:	eb 8f                	jmp    80104675 <sys_link+0xe6>
801046e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046eb:	eb 88                	jmp    80104675 <sys_link+0xe6>

801046ed <sys_unlink>:
{
801046ed:	55                   	push   %ebp
801046ee:	89 e5                	mov    %esp,%ebp
801046f0:	57                   	push   %edi
801046f1:	56                   	push   %esi
801046f2:	53                   	push   %ebx
801046f3:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801046f6:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046f9:	50                   	push   %eax
801046fa:	6a 00                	push   $0x0
801046fc:	e8 d2 f9 ff ff       	call   801040d3 <argstr>
80104701:	83 c4 10             	add    $0x10,%esp
80104704:	85 c0                	test   %eax,%eax
80104706:	0f 88 83 01 00 00    	js     8010488f <sys_unlink+0x1a2>
  begin_op();
8010470c:	e8 c1 e0 ff ff       	call   801027d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104711:	83 ec 08             	sub    $0x8,%esp
80104714:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104717:	50                   	push   %eax
80104718:	ff 75 c4             	pushl  -0x3c(%ebp)
8010471b:	e8 c7 d4 ff ff       	call   80101be7 <nameiparent>
80104720:	89 c6                	mov    %eax,%esi
80104722:	83 c4 10             	add    $0x10,%esp
80104725:	85 c0                	test   %eax,%eax
80104727:	0f 84 ed 00 00 00    	je     8010481a <sys_unlink+0x12d>
  ilock(dp);
8010472d:	83 ec 0c             	sub    $0xc,%esp
80104730:	50                   	push   %eax
80104731:	e8 39 ce ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104736:	83 c4 08             	add    $0x8,%esp
80104739:	68 d2 6f 10 80       	push   $0x80106fd2
8010473e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104741:	50                   	push   %eax
80104742:	e8 42 d2 ff ff       	call   80101989 <namecmp>
80104747:	83 c4 10             	add    $0x10,%esp
8010474a:	85 c0                	test   %eax,%eax
8010474c:	0f 84 fc 00 00 00    	je     8010484e <sys_unlink+0x161>
80104752:	83 ec 08             	sub    $0x8,%esp
80104755:	68 d1 6f 10 80       	push   $0x80106fd1
8010475a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010475d:	50                   	push   %eax
8010475e:	e8 26 d2 ff ff       	call   80101989 <namecmp>
80104763:	83 c4 10             	add    $0x10,%esp
80104766:	85 c0                	test   %eax,%eax
80104768:	0f 84 e0 00 00 00    	je     8010484e <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010476e:	83 ec 04             	sub    $0x4,%esp
80104771:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104774:	50                   	push   %eax
80104775:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104778:	50                   	push   %eax
80104779:	56                   	push   %esi
8010477a:	e8 1f d2 ff ff       	call   8010199e <dirlookup>
8010477f:	89 c3                	mov    %eax,%ebx
80104781:	83 c4 10             	add    $0x10,%esp
80104784:	85 c0                	test   %eax,%eax
80104786:	0f 84 c2 00 00 00    	je     8010484e <sys_unlink+0x161>
  ilock(ip);
8010478c:	83 ec 0c             	sub    $0xc,%esp
8010478f:	50                   	push   %eax
80104790:	e8 da cd ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
80104795:	83 c4 10             	add    $0x10,%esp
80104798:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010479d:	0f 8e 83 00 00 00    	jle    80104826 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047a3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047a8:	0f 84 85 00 00 00    	je     80104833 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801047ae:	83 ec 04             	sub    $0x4,%esp
801047b1:	6a 10                	push   $0x10
801047b3:	6a 00                	push   $0x0
801047b5:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047b8:	57                   	push   %edi
801047b9:	e8 3a f6 ff ff       	call   80103df8 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047be:	6a 10                	push   $0x10
801047c0:	ff 75 c0             	pushl  -0x40(%ebp)
801047c3:	57                   	push   %edi
801047c4:	56                   	push   %esi
801047c5:	e8 94 d0 ff ff       	call   8010185e <writei>
801047ca:	83 c4 20             	add    $0x20,%esp
801047cd:	83 f8 10             	cmp    $0x10,%eax
801047d0:	0f 85 90 00 00 00    	jne    80104866 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047d6:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047db:	0f 84 92 00 00 00    	je     80104873 <sys_unlink+0x186>
  iunlockput(dp);
801047e1:	83 ec 0c             	sub    $0xc,%esp
801047e4:	56                   	push   %esi
801047e5:	e8 2c cf ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
801047ea:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801047ee:	83 e8 01             	sub    $0x1,%eax
801047f1:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801047f5:	89 1c 24             	mov    %ebx,(%esp)
801047f8:	e8 11 cc ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801047fd:	89 1c 24             	mov    %ebx,(%esp)
80104800:	e8 11 cf ff ff       	call   80101716 <iunlockput>
  end_op();
80104805:	e8 42 e0 ff ff       	call   8010284c <end_op>
  return 0;
8010480a:	83 c4 10             	add    $0x10,%esp
8010480d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104812:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104815:	5b                   	pop    %ebx
80104816:	5e                   	pop    %esi
80104817:	5f                   	pop    %edi
80104818:	5d                   	pop    %ebp
80104819:	c3                   	ret    
    end_op();
8010481a:	e8 2d e0 ff ff       	call   8010284c <end_op>
    return -1;
8010481f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104824:	eb ec                	jmp    80104812 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104826:	83 ec 0c             	sub    $0xc,%esp
80104829:	68 f0 6f 10 80       	push   $0x80106ff0
8010482e:	e8 15 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104833:	89 d8                	mov    %ebx,%eax
80104835:	e8 bf f9 ff ff       	call   801041f9 <isdirempty>
8010483a:	85 c0                	test   %eax,%eax
8010483c:	0f 85 6c ff ff ff    	jne    801047ae <sys_unlink+0xc1>
    iunlockput(ip);
80104842:	83 ec 0c             	sub    $0xc,%esp
80104845:	53                   	push   %ebx
80104846:	e8 cb ce ff ff       	call   80101716 <iunlockput>
    goto bad;
8010484b:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010484e:	83 ec 0c             	sub    $0xc,%esp
80104851:	56                   	push   %esi
80104852:	e8 bf ce ff ff       	call   80101716 <iunlockput>
  end_op();
80104857:	e8 f0 df ff ff       	call   8010284c <end_op>
  return -1;
8010485c:	83 c4 10             	add    $0x10,%esp
8010485f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104864:	eb ac                	jmp    80104812 <sys_unlink+0x125>
    panic("unlink: writei");
80104866:	83 ec 0c             	sub    $0xc,%esp
80104869:	68 02 70 10 80       	push   $0x80107002
8010486e:	e8 d5 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104873:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104877:	83 e8 01             	sub    $0x1,%eax
8010487a:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010487e:	83 ec 0c             	sub    $0xc,%esp
80104881:	56                   	push   %esi
80104882:	e8 87 cb ff ff       	call   8010140e <iupdate>
80104887:	83 c4 10             	add    $0x10,%esp
8010488a:	e9 52 ff ff ff       	jmp    801047e1 <sys_unlink+0xf4>
    return -1;
8010488f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104894:	e9 79 ff ff ff       	jmp    80104812 <sys_unlink+0x125>

80104899 <sys_open>:

int
sys_open(void)
{
80104899:	55                   	push   %ebp
8010489a:	89 e5                	mov    %esp,%ebp
8010489c:	57                   	push   %edi
8010489d:	56                   	push   %esi
8010489e:	53                   	push   %ebx
8010489f:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801048a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048a5:	50                   	push   %eax
801048a6:	6a 00                	push   $0x0
801048a8:	e8 26 f8 ff ff       	call   801040d3 <argstr>
801048ad:	83 c4 10             	add    $0x10,%esp
801048b0:	85 c0                	test   %eax,%eax
801048b2:	0f 88 30 01 00 00    	js     801049e8 <sys_open+0x14f>
801048b8:	83 ec 08             	sub    $0x8,%esp
801048bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048be:	50                   	push   %eax
801048bf:	6a 01                	push   $0x1
801048c1:	e8 7d f7 ff ff       	call   80104043 <argint>
801048c6:	83 c4 10             	add    $0x10,%esp
801048c9:	85 c0                	test   %eax,%eax
801048cb:	0f 88 21 01 00 00    	js     801049f2 <sys_open+0x159>
    return -1;

  begin_op();
801048d1:	e8 fc de ff ff       	call   801027d2 <begin_op>

  if(omode & O_CREATE){
801048d6:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048da:	0f 84 84 00 00 00    	je     80104964 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801048e0:	83 ec 0c             	sub    $0xc,%esp
801048e3:	6a 00                	push   $0x0
801048e5:	b9 00 00 00 00       	mov    $0x0,%ecx
801048ea:	ba 02 00 00 00       	mov    $0x2,%edx
801048ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801048f2:	e8 59 f9 ff ff       	call   80104250 <create>
801048f7:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801048f9:	83 c4 10             	add    $0x10,%esp
801048fc:	85 c0                	test   %eax,%eax
801048fe:	74 58                	je     80104958 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104900:	e8 28 c3 ff ff       	call   80100c2d <filealloc>
80104905:	89 c3                	mov    %eax,%ebx
80104907:	85 c0                	test   %eax,%eax
80104909:	0f 84 ae 00 00 00    	je     801049bd <sys_open+0x124>
8010490f:	e8 ae f8 ff ff       	call   801041c2 <fdalloc>
80104914:	89 c7                	mov    %eax,%edi
80104916:	85 c0                	test   %eax,%eax
80104918:	0f 88 9f 00 00 00    	js     801049bd <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010491e:	83 ec 0c             	sub    $0xc,%esp
80104921:	56                   	push   %esi
80104922:	e8 0a cd ff ff       	call   80101631 <iunlock>
  end_op();
80104927:	e8 20 df ff ff       	call   8010284c <end_op>

  f->type = FD_INODE;
8010492c:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104932:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104935:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010493c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493f:	83 c4 10             	add    $0x10,%esp
80104942:	a8 01                	test   $0x1,%al
80104944:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104948:	a8 03                	test   $0x3,%al
8010494a:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010494e:	89 f8                	mov    %edi,%eax
80104950:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104953:	5b                   	pop    %ebx
80104954:	5e                   	pop    %esi
80104955:	5f                   	pop    %edi
80104956:	5d                   	pop    %ebp
80104957:	c3                   	ret    
      end_op();
80104958:	e8 ef de ff ff       	call   8010284c <end_op>
      return -1;
8010495d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104962:	eb ea                	jmp    8010494e <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104964:	83 ec 0c             	sub    $0xc,%esp
80104967:	ff 75 e4             	pushl  -0x1c(%ebp)
8010496a:	e8 60 d2 ff ff       	call   80101bcf <namei>
8010496f:	89 c6                	mov    %eax,%esi
80104971:	83 c4 10             	add    $0x10,%esp
80104974:	85 c0                	test   %eax,%eax
80104976:	74 39                	je     801049b1 <sys_open+0x118>
    ilock(ip);
80104978:	83 ec 0c             	sub    $0xc,%esp
8010497b:	50                   	push   %eax
8010497c:	e8 ee cb ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104981:	83 c4 10             	add    $0x10,%esp
80104984:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104989:	0f 85 71 ff ff ff    	jne    80104900 <sys_open+0x67>
8010498f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104993:	0f 84 67 ff ff ff    	je     80104900 <sys_open+0x67>
      iunlockput(ip);
80104999:	83 ec 0c             	sub    $0xc,%esp
8010499c:	56                   	push   %esi
8010499d:	e8 74 cd ff ff       	call   80101716 <iunlockput>
      end_op();
801049a2:	e8 a5 de ff ff       	call   8010284c <end_op>
      return -1;
801049a7:	83 c4 10             	add    $0x10,%esp
801049aa:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049af:	eb 9d                	jmp    8010494e <sys_open+0xb5>
      end_op();
801049b1:	e8 96 de ff ff       	call   8010284c <end_op>
      return -1;
801049b6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049bb:	eb 91                	jmp    8010494e <sys_open+0xb5>
    if(f)
801049bd:	85 db                	test   %ebx,%ebx
801049bf:	74 0c                	je     801049cd <sys_open+0x134>
      fileclose(f);
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	53                   	push   %ebx
801049c5:	e8 09 c3 ff ff       	call   80100cd3 <fileclose>
801049ca:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049cd:	83 ec 0c             	sub    $0xc,%esp
801049d0:	56                   	push   %esi
801049d1:	e8 40 cd ff ff       	call   80101716 <iunlockput>
    end_op();
801049d6:	e8 71 de ff ff       	call   8010284c <end_op>
    return -1;
801049db:	83 c4 10             	add    $0x10,%esp
801049de:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049e3:	e9 66 ff ff ff       	jmp    8010494e <sys_open+0xb5>
    return -1;
801049e8:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049ed:	e9 5c ff ff ff       	jmp    8010494e <sys_open+0xb5>
801049f2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049f7:	e9 52 ff ff ff       	jmp    8010494e <sys_open+0xb5>

801049fc <sys_mkdir>:

int
sys_mkdir(void)
{
801049fc:	55                   	push   %ebp
801049fd:	89 e5                	mov    %esp,%ebp
801049ff:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a02:	e8 cb dd ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a07:	83 ec 08             	sub    $0x8,%esp
80104a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a0d:	50                   	push   %eax
80104a0e:	6a 00                	push   $0x0
80104a10:	e8 be f6 ff ff       	call   801040d3 <argstr>
80104a15:	83 c4 10             	add    $0x10,%esp
80104a18:	85 c0                	test   %eax,%eax
80104a1a:	78 36                	js     80104a52 <sys_mkdir+0x56>
80104a1c:	83 ec 0c             	sub    $0xc,%esp
80104a1f:	6a 00                	push   $0x0
80104a21:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a26:	ba 01 00 00 00       	mov    $0x1,%edx
80104a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2e:	e8 1d f8 ff ff       	call   80104250 <create>
80104a33:	83 c4 10             	add    $0x10,%esp
80104a36:	85 c0                	test   %eax,%eax
80104a38:	74 18                	je     80104a52 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a3a:	83 ec 0c             	sub    $0xc,%esp
80104a3d:	50                   	push   %eax
80104a3e:	e8 d3 cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104a43:	e8 04 de ff ff       	call   8010284c <end_op>
  return 0;
80104a48:	83 c4 10             	add    $0x10,%esp
80104a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a50:	c9                   	leave  
80104a51:	c3                   	ret    
    end_op();
80104a52:	e8 f5 dd ff ff       	call   8010284c <end_op>
    return -1;
80104a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a5c:	eb f2                	jmp    80104a50 <sys_mkdir+0x54>

80104a5e <sys_mknod>:

int
sys_mknod(void)
{
80104a5e:	55                   	push   %ebp
80104a5f:	89 e5                	mov    %esp,%ebp
80104a61:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a64:	e8 69 dd ff ff       	call   801027d2 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a69:	83 ec 08             	sub    $0x8,%esp
80104a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a6f:	50                   	push   %eax
80104a70:	6a 00                	push   $0x0
80104a72:	e8 5c f6 ff ff       	call   801040d3 <argstr>
80104a77:	83 c4 10             	add    $0x10,%esp
80104a7a:	85 c0                	test   %eax,%eax
80104a7c:	78 62                	js     80104ae0 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a7e:	83 ec 08             	sub    $0x8,%esp
80104a81:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a84:	50                   	push   %eax
80104a85:	6a 01                	push   $0x1
80104a87:	e8 b7 f5 ff ff       	call   80104043 <argint>
  if((argstr(0, &path)) < 0 ||
80104a8c:	83 c4 10             	add    $0x10,%esp
80104a8f:	85 c0                	test   %eax,%eax
80104a91:	78 4d                	js     80104ae0 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a93:	83 ec 08             	sub    $0x8,%esp
80104a96:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a99:	50                   	push   %eax
80104a9a:	6a 02                	push   $0x2
80104a9c:	e8 a2 f5 ff ff       	call   80104043 <argint>
     argint(1, &major) < 0 ||
80104aa1:	83 c4 10             	add    $0x10,%esp
80104aa4:	85 c0                	test   %eax,%eax
80104aa6:	78 38                	js     80104ae0 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104aa8:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104aac:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104ab0:	83 ec 0c             	sub    $0xc,%esp
80104ab3:	50                   	push   %eax
80104ab4:	ba 03 00 00 00       	mov    $0x3,%edx
80104ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abc:	e8 8f f7 ff ff       	call   80104250 <create>
80104ac1:	83 c4 10             	add    $0x10,%esp
80104ac4:	85 c0                	test   %eax,%eax
80104ac6:	74 18                	je     80104ae0 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ac8:	83 ec 0c             	sub    $0xc,%esp
80104acb:	50                   	push   %eax
80104acc:	e8 45 cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104ad1:	e8 76 dd ff ff       	call   8010284c <end_op>
  return 0;
80104ad6:	83 c4 10             	add    $0x10,%esp
80104ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ade:	c9                   	leave  
80104adf:	c3                   	ret    
    end_op();
80104ae0:	e8 67 dd ff ff       	call   8010284c <end_op>
    return -1;
80104ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aea:	eb f2                	jmp    80104ade <sys_mknod+0x80>

80104aec <sys_chdir>:

int
sys_chdir(void)
{
80104aec:	55                   	push   %ebp
80104aed:	89 e5                	mov    %esp,%ebp
80104aef:	56                   	push   %esi
80104af0:	53                   	push   %ebx
80104af1:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104af4:	e8 aa e7 ff ff       	call   801032a3 <myproc>
80104af9:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104afb:	e8 d2 dc ff ff       	call   801027d2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b00:	83 ec 08             	sub    $0x8,%esp
80104b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b06:	50                   	push   %eax
80104b07:	6a 00                	push   $0x0
80104b09:	e8 c5 f5 ff ff       	call   801040d3 <argstr>
80104b0e:	83 c4 10             	add    $0x10,%esp
80104b11:	85 c0                	test   %eax,%eax
80104b13:	78 52                	js     80104b67 <sys_chdir+0x7b>
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	ff 75 f4             	pushl  -0xc(%ebp)
80104b1b:	e8 af d0 ff ff       	call   80101bcf <namei>
80104b20:	89 c3                	mov    %eax,%ebx
80104b22:	83 c4 10             	add    $0x10,%esp
80104b25:	85 c0                	test   %eax,%eax
80104b27:	74 3e                	je     80104b67 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b29:	83 ec 0c             	sub    $0xc,%esp
80104b2c:	50                   	push   %eax
80104b2d:	e8 3d ca ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104b32:	83 c4 10             	add    $0x10,%esp
80104b35:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b3a:	75 37                	jne    80104b73 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b3c:	83 ec 0c             	sub    $0xc,%esp
80104b3f:	53                   	push   %ebx
80104b40:	e8 ec ca ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104b45:	83 c4 04             	add    $0x4,%esp
80104b48:	ff 76 68             	pushl  0x68(%esi)
80104b4b:	e8 26 cb ff ff       	call   80101676 <iput>
  end_op();
80104b50:	e8 f7 dc ff ff       	call   8010284c <end_op>
  curproc->cwd = ip;
80104b55:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b58:	83 c4 10             	add    $0x10,%esp
80104b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b60:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b63:	5b                   	pop    %ebx
80104b64:	5e                   	pop    %esi
80104b65:	5d                   	pop    %ebp
80104b66:	c3                   	ret    
    end_op();
80104b67:	e8 e0 dc ff ff       	call   8010284c <end_op>
    return -1;
80104b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b71:	eb ed                	jmp    80104b60 <sys_chdir+0x74>
    iunlockput(ip);
80104b73:	83 ec 0c             	sub    $0xc,%esp
80104b76:	53                   	push   %ebx
80104b77:	e8 9a cb ff ff       	call   80101716 <iunlockput>
    end_op();
80104b7c:	e8 cb dc ff ff       	call   8010284c <end_op>
    return -1;
80104b81:	83 c4 10             	add    $0x10,%esp
80104b84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b89:	eb d5                	jmp    80104b60 <sys_chdir+0x74>

80104b8b <sys_exec>:

int
sys_exec(void)
{
80104b8b:	55                   	push   %ebp
80104b8c:	89 e5                	mov    %esp,%ebp
80104b8e:	53                   	push   %ebx
80104b8f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b95:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b98:	50                   	push   %eax
80104b99:	6a 00                	push   $0x0
80104b9b:	e8 33 f5 ff ff       	call   801040d3 <argstr>
80104ba0:	83 c4 10             	add    $0x10,%esp
80104ba3:	85 c0                	test   %eax,%eax
80104ba5:	0f 88 a8 00 00 00    	js     80104c53 <sys_exec+0xc8>
80104bab:	83 ec 08             	sub    $0x8,%esp
80104bae:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bb4:	50                   	push   %eax
80104bb5:	6a 01                	push   $0x1
80104bb7:	e8 87 f4 ff ff       	call   80104043 <argint>
80104bbc:	83 c4 10             	add    $0x10,%esp
80104bbf:	85 c0                	test   %eax,%eax
80104bc1:	0f 88 93 00 00 00    	js     80104c5a <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bc7:	83 ec 04             	sub    $0x4,%esp
80104bca:	68 80 00 00 00       	push   $0x80
80104bcf:	6a 00                	push   $0x0
80104bd1:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bd7:	50                   	push   %eax
80104bd8:	e8 1b f2 ff ff       	call   80103df8 <memset>
80104bdd:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104be0:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104be5:	83 fb 1f             	cmp    $0x1f,%ebx
80104be8:	77 77                	ja     80104c61 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104bea:	83 ec 08             	sub    $0x8,%esp
80104bed:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104bf3:	50                   	push   %eax
80104bf4:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104bfa:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104bfd:	50                   	push   %eax
80104bfe:	e8 c4 f3 ff ff       	call   80103fc7 <fetchint>
80104c03:	83 c4 10             	add    $0x10,%esp
80104c06:	85 c0                	test   %eax,%eax
80104c08:	78 5e                	js     80104c68 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104c0a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c10:	85 c0                	test   %eax,%eax
80104c12:	74 1d                	je     80104c31 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104c14:	83 ec 08             	sub    $0x8,%esp
80104c17:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c1e:	52                   	push   %edx
80104c1f:	50                   	push   %eax
80104c20:	e8 de f3 ff ff       	call   80104003 <fetchstr>
80104c25:	83 c4 10             	add    $0x10,%esp
80104c28:	85 c0                	test   %eax,%eax
80104c2a:	78 46                	js     80104c72 <sys_exec+0xe7>
  for(i=0;; i++){
80104c2c:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c2f:	eb b4                	jmp    80104be5 <sys_exec+0x5a>
      argv[i] = 0;
80104c31:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c38:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c3c:	83 ec 08             	sub    $0x8,%esp
80104c3f:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c45:	50                   	push   %eax
80104c46:	ff 75 f4             	pushl  -0xc(%ebp)
80104c49:	e8 84 bc ff ff       	call   801008d2 <exec>
80104c4e:	83 c4 10             	add    $0x10,%esp
80104c51:	eb 1a                	jmp    80104c6d <sys_exec+0xe2>
    return -1;
80104c53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c58:	eb 13                	jmp    80104c6d <sys_exec+0xe2>
80104c5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c5f:	eb 0c                	jmp    80104c6d <sys_exec+0xe2>
      return -1;
80104c61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c66:	eb 05                	jmp    80104c6d <sys_exec+0xe2>
      return -1;
80104c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c70:	c9                   	leave  
80104c71:	c3                   	ret    
      return -1;
80104c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c77:	eb f4                	jmp    80104c6d <sys_exec+0xe2>

80104c79 <sys_pipe>:

int
sys_pipe(void)
{
80104c79:	55                   	push   %ebp
80104c7a:	89 e5                	mov    %esp,%ebp
80104c7c:	53                   	push   %ebx
80104c7d:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c80:	6a 08                	push   $0x8
80104c82:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c85:	50                   	push   %eax
80104c86:	6a 00                	push   $0x0
80104c88:	e8 de f3 ff ff       	call   8010406b <argptr>
80104c8d:	83 c4 10             	add    $0x10,%esp
80104c90:	85 c0                	test   %eax,%eax
80104c92:	78 77                	js     80104d0b <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c94:	83 ec 08             	sub    $0x8,%esp
80104c97:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c9a:	50                   	push   %eax
80104c9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c9e:	50                   	push   %eax
80104c9f:	e8 ec e0 ff ff       	call   80102d90 <pipealloc>
80104ca4:	83 c4 10             	add    $0x10,%esp
80104ca7:	85 c0                	test   %eax,%eax
80104ca9:	78 67                	js     80104d12 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cae:	e8 0f f5 ff ff       	call   801041c2 <fdalloc>
80104cb3:	89 c3                	mov    %eax,%ebx
80104cb5:	85 c0                	test   %eax,%eax
80104cb7:	78 21                	js     80104cda <sys_pipe+0x61>
80104cb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cbc:	e8 01 f5 ff ff       	call   801041c2 <fdalloc>
80104cc1:	85 c0                	test   %eax,%eax
80104cc3:	78 15                	js     80104cda <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc8:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ccd:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cd8:	c9                   	leave  
80104cd9:	c3                   	ret    
    if(fd0 >= 0)
80104cda:	85 db                	test   %ebx,%ebx
80104cdc:	78 0d                	js     80104ceb <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104cde:	e8 c0 e5 ff ff       	call   801032a3 <myproc>
80104ce3:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104cea:	00 
    fileclose(rf);
80104ceb:	83 ec 0c             	sub    $0xc,%esp
80104cee:	ff 75 f0             	pushl  -0x10(%ebp)
80104cf1:	e8 dd bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104cf6:	83 c4 04             	add    $0x4,%esp
80104cf9:	ff 75 ec             	pushl  -0x14(%ebp)
80104cfc:	e8 d2 bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104d01:	83 c4 10             	add    $0x10,%esp
80104d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d09:	eb ca                	jmp    80104cd5 <sys_pipe+0x5c>
    return -1;
80104d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d10:	eb c3                	jmp    80104cd5 <sys_pipe+0x5c>
    return -1;
80104d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d17:	eb bc                	jmp    80104cd5 <sys_pipe+0x5c>

80104d19 <sys_writecount>:

int
sys_writecount(void){
80104d19:	55                   	push   %ebp
80104d1a:	89 e5                	mov    %esp,%ebp
  uint myWriteCount;
  myWriteCount = writeCount_global;
  return myWriteCount;
}
80104d1c:	a1 54 4e 11 80       	mov    0x80114e54,%eax
80104d21:	5d                   	pop    %ebp
80104d22:	c3                   	ret    

80104d23 <sys_setwritecount>:

int
sys_setwritecount(void){
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 20             	sub    $0x20,%esp
   int pid;
  

  if(argint(0, &pid) < 0)
80104d29:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d2c:	50                   	push   %eax
80104d2d:	6a 00                	push   $0x0
80104d2f:	e8 0f f3 ff ff       	call   80104043 <argint>
80104d34:	83 c4 10             	add    $0x10,%esp
80104d37:	85 c0                	test   %eax,%eax
80104d39:	78 0f                	js     80104d4a <sys_setwritecount+0x27>
    return -1;
  writeCount_global = (uint) pid;
80104d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3e:	a3 54 4e 11 80       	mov    %eax,0x80114e54
  return 0;
80104d43:	b8 00 00 00 00       	mov    $0x0,%eax
80104d48:	c9                   	leave  
80104d49:	c3                   	ret    
    return -1;
80104d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4f:	eb f7                	jmp    80104d48 <sys_setwritecount+0x25>

80104d51 <sys_fork>:



int
sys_fork(void)
{
80104d51:	55                   	push   %ebp
80104d52:	89 e5                	mov    %esp,%ebp
80104d54:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d57:	e8 c9 e6 ff ff       	call   80103425 <fork>
}
80104d5c:	c9                   	leave  
80104d5d:	c3                   	ret    

80104d5e <sys_exit>:

int
sys_exit(void)
{
80104d5e:	55                   	push   %ebp
80104d5f:	89 e5                	mov    %esp,%ebp
80104d61:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d64:	e8 74 e9 ff ff       	call   801036dd <exit>
  return 0;  // not reached
}
80104d69:	b8 00 00 00 00       	mov    $0x0,%eax
80104d6e:	c9                   	leave  
80104d6f:	c3                   	ret    

80104d70 <sys_wait>:

int
sys_wait(void)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d76:	e8 ee ea ff ff       	call   80103869 <wait>
}
80104d7b:	c9                   	leave  
80104d7c:	c3                   	ret    

80104d7d <sys_kill>:

int
sys_kill(void)
{
80104d7d:	55                   	push   %ebp
80104d7e:	89 e5                	mov    %esp,%ebp
80104d80:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d86:	50                   	push   %eax
80104d87:	6a 00                	push   $0x0
80104d89:	e8 b5 f2 ff ff       	call   80104043 <argint>
80104d8e:	83 c4 10             	add    $0x10,%esp
80104d91:	85 c0                	test   %eax,%eax
80104d93:	78 10                	js     80104da5 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d95:	83 ec 0c             	sub    $0xc,%esp
80104d98:	ff 75 f4             	pushl  -0xc(%ebp)
80104d9b:	e8 c9 eb ff ff       	call   80103969 <kill>
80104da0:	83 c4 10             	add    $0x10,%esp
}
80104da3:	c9                   	leave  
80104da4:	c3                   	ret    
    return -1;
80104da5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104daa:	eb f7                	jmp    80104da3 <sys_kill+0x26>

80104dac <sys_getpid>:

int
sys_getpid(void)
{
80104dac:	55                   	push   %ebp
80104dad:	89 e5                	mov    %esp,%ebp
80104daf:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104db2:	e8 ec e4 ff ff       	call   801032a3 <myproc>
80104db7:	8b 40 10             	mov    0x10(%eax),%eax
}
80104dba:	c9                   	leave  
80104dbb:	c3                   	ret    

80104dbc <sys_sbrk>:

int
sys_sbrk(void)
{
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	53                   	push   %ebx
80104dc0:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dc6:	50                   	push   %eax
80104dc7:	6a 00                	push   $0x0
80104dc9:	e8 75 f2 ff ff       	call   80104043 <argint>
80104dce:	83 c4 10             	add    $0x10,%esp
80104dd1:	85 c0                	test   %eax,%eax
80104dd3:	78 27                	js     80104dfc <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104dd5:	e8 c9 e4 ff ff       	call   801032a3 <myproc>
80104dda:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104ddc:	83 ec 0c             	sub    $0xc,%esp
80104ddf:	ff 75 f4             	pushl  -0xc(%ebp)
80104de2:	e8 d1 e5 ff ff       	call   801033b8 <growproc>
80104de7:	83 c4 10             	add    $0x10,%esp
80104dea:	85 c0                	test   %eax,%eax
80104dec:	78 07                	js     80104df5 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104dee:	89 d8                	mov    %ebx,%eax
80104df0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104df3:	c9                   	leave  
80104df4:	c3                   	ret    
    return -1;
80104df5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dfa:	eb f2                	jmp    80104dee <sys_sbrk+0x32>
    return -1;
80104dfc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e01:	eb eb                	jmp    80104dee <sys_sbrk+0x32>

80104e03 <sys_sleep>:

int
sys_sleep(void)
{
80104e03:	55                   	push   %ebp
80104e04:	89 e5                	mov    %esp,%ebp
80104e06:	53                   	push   %ebx
80104e07:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e0d:	50                   	push   %eax
80104e0e:	6a 00                	push   $0x0
80104e10:	e8 2e f2 ff ff       	call   80104043 <argint>
80104e15:	83 c4 10             	add    $0x10,%esp
80104e18:	85 c0                	test   %eax,%eax
80104e1a:	78 75                	js     80104e91 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e1c:	83 ec 0c             	sub    $0xc,%esp
80104e1f:	68 60 4e 11 80       	push   $0x80114e60
80104e24:	e8 23 ef ff ff       	call   80103d4c <acquire>
  ticks0 = ticks;
80104e29:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  while(ticks - ticks0 < n){
80104e2f:	83 c4 10             	add    $0x10,%esp
80104e32:	a1 a0 56 11 80       	mov    0x801156a0,%eax
80104e37:	29 d8                	sub    %ebx,%eax
80104e39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e3c:	73 39                	jae    80104e77 <sys_sleep+0x74>
    if(myproc()->killed){
80104e3e:	e8 60 e4 ff ff       	call   801032a3 <myproc>
80104e43:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e47:	75 17                	jne    80104e60 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e49:	83 ec 08             	sub    $0x8,%esp
80104e4c:	68 60 4e 11 80       	push   $0x80114e60
80104e51:	68 a0 56 11 80       	push   $0x801156a0
80104e56:	e8 7d e9 ff ff       	call   801037d8 <sleep>
80104e5b:	83 c4 10             	add    $0x10,%esp
80104e5e:	eb d2                	jmp    80104e32 <sys_sleep+0x2f>
      release(&tickslock);
80104e60:	83 ec 0c             	sub    $0xc,%esp
80104e63:	68 60 4e 11 80       	push   $0x80114e60
80104e68:	e8 44 ef ff ff       	call   80103db1 <release>
      return -1;
80104e6d:	83 c4 10             	add    $0x10,%esp
80104e70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e75:	eb 15                	jmp    80104e8c <sys_sleep+0x89>
  }
  release(&tickslock);
80104e77:	83 ec 0c             	sub    $0xc,%esp
80104e7a:	68 60 4e 11 80       	push   $0x80114e60
80104e7f:	e8 2d ef ff ff       	call   80103db1 <release>
  return 0;
80104e84:	83 c4 10             	add    $0x10,%esp
80104e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e8f:	c9                   	leave  
80104e90:	c3                   	ret    
    return -1;
80104e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e96:	eb f4                	jmp    80104e8c <sys_sleep+0x89>

80104e98 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e98:	55                   	push   %ebp
80104e99:	89 e5                	mov    %esp,%ebp
80104e9b:	53                   	push   %ebx
80104e9c:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e9f:	68 60 4e 11 80       	push   $0x80114e60
80104ea4:	e8 a3 ee ff ff       	call   80103d4c <acquire>
  xticks = ticks;
80104ea9:	8b 1d a0 56 11 80    	mov    0x801156a0,%ebx
  release(&tickslock);
80104eaf:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80104eb6:	e8 f6 ee ff ff       	call   80103db1 <release>
  return xticks;
}
80104ebb:	89 d8                	mov    %ebx,%eax
80104ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ec0:	c9                   	leave  
80104ec1:	c3                   	ret    

80104ec2 <sys_yield>:

int
sys_yield(void)
{
80104ec2:	55                   	push   %ebp
80104ec3:	89 e5                	mov    %esp,%ebp
80104ec5:	83 ec 08             	sub    $0x8,%esp
  yield();
80104ec8:	e8 d9 e8 ff ff       	call   801037a6 <yield>
  return 0;
}
80104ecd:	b8 00 00 00 00       	mov    $0x0,%eax
80104ed2:	c9                   	leave  
80104ed3:	c3                   	ret    

80104ed4 <sys_shutdown>:

int sys_shutdown(void)
{
80104ed4:	55                   	push   %ebp
80104ed5:	89 e5                	mov    %esp,%ebp
80104ed7:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104eda:	e8 27 d3 ff ff       	call   80102206 <shutdown>
  return 0;
}
80104edf:	b8 00 00 00 00       	mov    $0x0,%eax
80104ee4:	c9                   	leave  
80104ee5:	c3                   	ret    

80104ee6 <sys_settickets>:

int sys_settickets(void){
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
80104ee9:	53                   	push   %ebx
80104eea:	83 ec 14             	sub    $0x14,%esp
  int tickets;
  struct proc *curproc = myproc();
80104eed:	e8 b1 e3 ff ff       	call   801032a3 <myproc>
80104ef2:	89 c3                	mov    %eax,%ebx

  if(argint(0, &tickets) < 0)
80104ef4:	83 ec 08             	sub    $0x8,%esp
80104ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104efa:	50                   	push   %eax
80104efb:	6a 00                	push   $0x0
80104efd:	e8 41 f1 ff ff       	call   80104043 <argint>
80104f02:	83 c4 10             	add    $0x10,%esp
80104f05:	85 c0                	test   %eax,%eax
80104f07:	78 13                	js     80104f1c <sys_settickets+0x36>
    return -1;

  curproc->tickets = tickets;
80104f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)

  
  
  return 0;
80104f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f1a:	c9                   	leave  
80104f1b:	c3                   	ret    
    return -1;
80104f1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f21:	eb f4                	jmp    80104f17 <sys_settickets+0x31>

80104f23 <sys_getprocessesinfo>:

int sys_getprocessesinfo(void){
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
80104f26:	83 ec 1c             	sub    $0x1c,%esp
  //int x;
  


  
  if( argptr(0, (void*) &my_process_info, sizeof(*my_process_info)) < 0){
80104f29:	68 04 03 00 00       	push   $0x304
80104f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f31:	50                   	push   %eax
80104f32:	6a 00                	push   $0x0
80104f34:	e8 32 f1 ff ff       	call   8010406b <argptr>
80104f39:	83 c4 10             	add    $0x10,%esp
80104f3c:	85 c0                	test   %eax,%eax
80104f3e:	78 10                	js     80104f50 <sys_getprocessesinfo+0x2d>
    return -1;
  }

  return getprocessesinfo_helper(my_process_info);
80104f40:	83 ec 0c             	sub    $0xc,%esp
80104f43:	ff 75 f4             	pushl  -0xc(%ebp)
80104f46:	e8 49 eb ff ff       	call   80103a94 <getprocessesinfo_helper>
80104f4b:	83 c4 10             	add    $0x10,%esp
}
80104f4e:	c9                   	leave  
80104f4f:	c3                   	ret    
    return -1;
80104f50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f55:	eb f7                	jmp    80104f4e <sys_getprocessesinfo+0x2b>

80104f57 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104f57:	1e                   	push   %ds
  pushl %es
80104f58:	06                   	push   %es
  pushl %fs
80104f59:	0f a0                	push   %fs
  pushl %gs
80104f5b:	0f a8                	push   %gs
  pushal
80104f5d:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f5e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f62:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f64:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f66:	54                   	push   %esp
  call trap
80104f67:	e8 e3 00 00 00       	call   8010504f <trap>
  addl $4, %esp
80104f6c:	83 c4 04             	add    $0x4,%esp

80104f6f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f6f:	61                   	popa   
  popl %gs
80104f70:	0f a9                	pop    %gs
  popl %fs
80104f72:	0f a1                	pop    %fs
  popl %es
80104f74:	07                   	pop    %es
  popl %ds
80104f75:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f76:	83 c4 08             	add    $0x8,%esp
  iret
80104f79:	cf                   	iret   

80104f7a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f7a:	55                   	push   %ebp
80104f7b:	89 e5                	mov    %esp,%ebp
80104f7d:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f80:	b8 00 00 00 00       	mov    $0x0,%eax
80104f85:	eb 4a                	jmp    80104fd1 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f87:	8b 0c 85 0c a0 10 80 	mov    -0x7fef5ff4(,%eax,4),%ecx
80104f8e:	66 89 0c c5 a0 4e 11 	mov    %cx,-0x7feeb160(,%eax,8)
80104f95:	80 
80104f96:	66 c7 04 c5 a2 4e 11 	movw   $0x8,-0x7feeb15e(,%eax,8)
80104f9d:	80 08 00 
80104fa0:	c6 04 c5 a4 4e 11 80 	movb   $0x0,-0x7feeb15c(,%eax,8)
80104fa7:	00 
80104fa8:	0f b6 14 c5 a5 4e 11 	movzbl -0x7feeb15b(,%eax,8),%edx
80104faf:	80 
80104fb0:	83 e2 f0             	and    $0xfffffff0,%edx
80104fb3:	83 ca 0e             	or     $0xe,%edx
80104fb6:	83 e2 8f             	and    $0xffffff8f,%edx
80104fb9:	83 ca 80             	or     $0xffffff80,%edx
80104fbc:	88 14 c5 a5 4e 11 80 	mov    %dl,-0x7feeb15b(,%eax,8)
80104fc3:	c1 e9 10             	shr    $0x10,%ecx
80104fc6:	66 89 0c c5 a6 4e 11 	mov    %cx,-0x7feeb15a(,%eax,8)
80104fcd:	80 
  for(i = 0; i < 256; i++)
80104fce:	83 c0 01             	add    $0x1,%eax
80104fd1:	3d ff 00 00 00       	cmp    $0xff,%eax
80104fd6:	7e af                	jle    80104f87 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104fd8:	8b 15 0c a1 10 80    	mov    0x8010a10c,%edx
80104fde:	66 89 15 a0 50 11 80 	mov    %dx,0x801150a0
80104fe5:	66 c7 05 a2 50 11 80 	movw   $0x8,0x801150a2
80104fec:	08 00 
80104fee:	c6 05 a4 50 11 80 00 	movb   $0x0,0x801150a4
80104ff5:	0f b6 05 a5 50 11 80 	movzbl 0x801150a5,%eax
80104ffc:	83 c8 0f             	or     $0xf,%eax
80104fff:	83 e0 ef             	and    $0xffffffef,%eax
80105002:	83 c8 e0             	or     $0xffffffe0,%eax
80105005:	a2 a5 50 11 80       	mov    %al,0x801150a5
8010500a:	c1 ea 10             	shr    $0x10,%edx
8010500d:	66 89 15 a6 50 11 80 	mov    %dx,0x801150a6

  initlock(&tickslock, "time");
80105014:	83 ec 08             	sub    $0x8,%esp
80105017:	68 11 70 10 80       	push   $0x80107011
8010501c:	68 60 4e 11 80       	push   $0x80114e60
80105021:	e8 ea eb ff ff       	call   80103c10 <initlock>
}
80105026:	83 c4 10             	add    $0x10,%esp
80105029:	c9                   	leave  
8010502a:	c3                   	ret    

8010502b <idtinit>:

void
idtinit(void)
{
8010502b:	55                   	push   %ebp
8010502c:	89 e5                	mov    %esp,%ebp
8010502e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105031:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105037:	b8 a0 4e 11 80       	mov    $0x80114ea0,%eax
8010503c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105040:	c1 e8 10             	shr    $0x10,%eax
80105043:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105047:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010504a:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010504d:	c9                   	leave  
8010504e:	c3                   	ret    

8010504f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010504f:	55                   	push   %ebp
80105050:	89 e5                	mov    %esp,%ebp
80105052:	57                   	push   %edi
80105053:	56                   	push   %esi
80105054:	53                   	push   %ebx
80105055:	83 ec 1c             	sub    $0x1c,%esp
80105058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010505b:	8b 43 30             	mov    0x30(%ebx),%eax
8010505e:	83 f8 40             	cmp    $0x40,%eax
80105061:	74 13                	je     80105076 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105063:	83 e8 20             	sub    $0x20,%eax
80105066:	83 f8 1f             	cmp    $0x1f,%eax
80105069:	0f 87 3a 01 00 00    	ja     801051a9 <trap+0x15a>
8010506f:	ff 24 85 b8 70 10 80 	jmp    *-0x7fef8f48(,%eax,4)
    if(myproc()->killed)
80105076:	e8 28 e2 ff ff       	call   801032a3 <myproc>
8010507b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010507f:	75 1f                	jne    801050a0 <trap+0x51>
    myproc()->tf = tf;
80105081:	e8 1d e2 ff ff       	call   801032a3 <myproc>
80105086:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105089:	e8 78 f0 ff ff       	call   80104106 <syscall>
    if(myproc()->killed)
8010508e:	e8 10 e2 ff ff       	call   801032a3 <myproc>
80105093:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105097:	74 7e                	je     80105117 <trap+0xc8>
      exit();
80105099:	e8 3f e6 ff ff       	call   801036dd <exit>
8010509e:	eb 77                	jmp    80105117 <trap+0xc8>
      exit();
801050a0:	e8 38 e6 ff ff       	call   801036dd <exit>
801050a5:	eb da                	jmp    80105081 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801050a7:	e8 dc e1 ff ff       	call   80103288 <cpuid>
801050ac:	85 c0                	test   %eax,%eax
801050ae:	74 6f                	je     8010511f <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801050b0:	e8 08 d3 ff ff       	call   801023bd <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050b5:	e8 e9 e1 ff ff       	call   801032a3 <myproc>
801050ba:	85 c0                	test   %eax,%eax
801050bc:	74 1c                	je     801050da <trap+0x8b>
801050be:	e8 e0 e1 ff ff       	call   801032a3 <myproc>
801050c3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050c7:	74 11                	je     801050da <trap+0x8b>
801050c9:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050cd:	83 e0 03             	and    $0x3,%eax
801050d0:	66 83 f8 03          	cmp    $0x3,%ax
801050d4:	0f 84 62 01 00 00    	je     8010523c <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801050da:	e8 c4 e1 ff ff       	call   801032a3 <myproc>
801050df:	85 c0                	test   %eax,%eax
801050e1:	74 0f                	je     801050f2 <trap+0xa3>
801050e3:	e8 bb e1 ff ff       	call   801032a3 <myproc>
801050e8:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801050ec:	0f 84 54 01 00 00    	je     80105246 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050f2:	e8 ac e1 ff ff       	call   801032a3 <myproc>
801050f7:	85 c0                	test   %eax,%eax
801050f9:	74 1c                	je     80105117 <trap+0xc8>
801050fb:	e8 a3 e1 ff ff       	call   801032a3 <myproc>
80105100:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105104:	74 11                	je     80105117 <trap+0xc8>
80105106:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010510a:	83 e0 03             	and    $0x3,%eax
8010510d:	66 83 f8 03          	cmp    $0x3,%ax
80105111:	0f 84 43 01 00 00    	je     8010525a <trap+0x20b>
    exit();
}
80105117:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010511a:	5b                   	pop    %ebx
8010511b:	5e                   	pop    %esi
8010511c:	5f                   	pop    %edi
8010511d:	5d                   	pop    %ebp
8010511e:	c3                   	ret    
      acquire(&tickslock);
8010511f:	83 ec 0c             	sub    $0xc,%esp
80105122:	68 60 4e 11 80       	push   $0x80114e60
80105127:	e8 20 ec ff ff       	call   80103d4c <acquire>
      ticks++;
8010512c:	83 05 a0 56 11 80 01 	addl   $0x1,0x801156a0
      wakeup(&ticks);
80105133:	c7 04 24 a0 56 11 80 	movl   $0x801156a0,(%esp)
8010513a:	e8 01 e8 ff ff       	call   80103940 <wakeup>
      release(&tickslock);
8010513f:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80105146:	e8 66 ec ff ff       	call   80103db1 <release>
8010514b:	83 c4 10             	add    $0x10,%esp
8010514e:	e9 5d ff ff ff       	jmp    801050b0 <trap+0x61>
    ideintr();
80105153:	e8 09 cc ff ff       	call   80101d61 <ideintr>
    lapiceoi();
80105158:	e8 60 d2 ff ff       	call   801023bd <lapiceoi>
    break;
8010515d:	e9 53 ff ff ff       	jmp    801050b5 <trap+0x66>
    kbdintr();
80105162:	e8 8a d0 ff ff       	call   801021f1 <kbdintr>
    lapiceoi();
80105167:	e8 51 d2 ff ff       	call   801023bd <lapiceoi>
    break;
8010516c:	e9 44 ff ff ff       	jmp    801050b5 <trap+0x66>
    uartintr();
80105171:	e8 05 02 00 00       	call   8010537b <uartintr>
    lapiceoi();
80105176:	e8 42 d2 ff ff       	call   801023bd <lapiceoi>
    break;
8010517b:	e9 35 ff ff ff       	jmp    801050b5 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105180:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105183:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105187:	e8 fc e0 ff ff       	call   80103288 <cpuid>
8010518c:	57                   	push   %edi
8010518d:	0f b7 f6             	movzwl %si,%esi
80105190:	56                   	push   %esi
80105191:	50                   	push   %eax
80105192:	68 1c 70 10 80       	push   $0x8010701c
80105197:	e8 6f b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
8010519c:	e8 1c d2 ff ff       	call   801023bd <lapiceoi>
    break;
801051a1:	83 c4 10             	add    $0x10,%esp
801051a4:	e9 0c ff ff ff       	jmp    801050b5 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801051a9:	e8 f5 e0 ff ff       	call   801032a3 <myproc>
801051ae:	85 c0                	test   %eax,%eax
801051b0:	74 5f                	je     80105211 <trap+0x1c2>
801051b2:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801051b6:	74 59                	je     80105211 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801051b8:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051bb:	8b 43 38             	mov    0x38(%ebx),%eax
801051be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801051c1:	e8 c2 e0 ff ff       	call   80103288 <cpuid>
801051c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801051c9:	8b 53 34             	mov    0x34(%ebx),%edx
801051cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
801051cf:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801051d2:	e8 cc e0 ff ff       	call   801032a3 <myproc>
801051d7:	8d 48 6c             	lea    0x6c(%eax),%ecx
801051da:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801051dd:	e8 c1 e0 ff ff       	call   801032a3 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051e2:	57                   	push   %edi
801051e3:	ff 75 e4             	pushl  -0x1c(%ebp)
801051e6:	ff 75 e0             	pushl  -0x20(%ebp)
801051e9:	ff 75 dc             	pushl  -0x24(%ebp)
801051ec:	56                   	push   %esi
801051ed:	ff 75 d8             	pushl  -0x28(%ebp)
801051f0:	ff 70 10             	pushl  0x10(%eax)
801051f3:	68 74 70 10 80       	push   $0x80107074
801051f8:	e8 0e b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801051fd:	83 c4 20             	add    $0x20,%esp
80105200:	e8 9e e0 ff ff       	call   801032a3 <myproc>
80105205:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010520c:	e9 a4 fe ff ff       	jmp    801050b5 <trap+0x66>
80105211:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105214:	8b 73 38             	mov    0x38(%ebx),%esi
80105217:	e8 6c e0 ff ff       	call   80103288 <cpuid>
8010521c:	83 ec 0c             	sub    $0xc,%esp
8010521f:	57                   	push   %edi
80105220:	56                   	push   %esi
80105221:	50                   	push   %eax
80105222:	ff 73 30             	pushl  0x30(%ebx)
80105225:	68 40 70 10 80       	push   $0x80107040
8010522a:	e8 dc b3 ff ff       	call   8010060b <cprintf>
      panic("trap");
8010522f:	83 c4 14             	add    $0x14,%esp
80105232:	68 16 70 10 80       	push   $0x80107016
80105237:	e8 0c b1 ff ff       	call   80100348 <panic>
    exit();
8010523c:	e8 9c e4 ff ff       	call   801036dd <exit>
80105241:	e9 94 fe ff ff       	jmp    801050da <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105246:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010524a:	0f 85 a2 fe ff ff    	jne    801050f2 <trap+0xa3>
    yield();
80105250:	e8 51 e5 ff ff       	call   801037a6 <yield>
80105255:	e9 98 fe ff ff       	jmp    801050f2 <trap+0xa3>
    exit();
8010525a:	e8 7e e4 ff ff       	call   801036dd <exit>
8010525f:	e9 b3 fe ff ff       	jmp    80105117 <trap+0xc8>

80105264 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105264:	55                   	push   %ebp
80105265:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105267:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
8010526e:	74 15                	je     80105285 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105270:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105275:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105276:	a8 01                	test   $0x1,%al
80105278:	74 12                	je     8010528c <uartgetc+0x28>
8010527a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010527f:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105280:	0f b6 c0             	movzbl %al,%eax
}
80105283:	5d                   	pop    %ebp
80105284:	c3                   	ret    
    return -1;
80105285:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528a:	eb f7                	jmp    80105283 <uartgetc+0x1f>
    return -1;
8010528c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105291:	eb f0                	jmp    80105283 <uartgetc+0x1f>

80105293 <uartputc>:
  if(!uart)
80105293:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
8010529a:	74 3b                	je     801052d7 <uartputc+0x44>
{
8010529c:	55                   	push   %ebp
8010529d:	89 e5                	mov    %esp,%ebp
8010529f:	53                   	push   %ebx
801052a0:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801052a3:	bb 00 00 00 00       	mov    $0x0,%ebx
801052a8:	eb 10                	jmp    801052ba <uartputc+0x27>
    microdelay(10);
801052aa:	83 ec 0c             	sub    $0xc,%esp
801052ad:	6a 0a                	push   $0xa
801052af:	e8 28 d1 ff ff       	call   801023dc <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801052b4:	83 c3 01             	add    $0x1,%ebx
801052b7:	83 c4 10             	add    $0x10,%esp
801052ba:	83 fb 7f             	cmp    $0x7f,%ebx
801052bd:	7f 0a                	jg     801052c9 <uartputc+0x36>
801052bf:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052c4:	ec                   	in     (%dx),%al
801052c5:	a8 20                	test   $0x20,%al
801052c7:	74 e1                	je     801052aa <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801052c9:	8b 45 08             	mov    0x8(%ebp),%eax
801052cc:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052d1:	ee                   	out    %al,(%dx)
}
801052d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052d5:	c9                   	leave  
801052d6:	c3                   	ret    
801052d7:	f3 c3                	repz ret 

801052d9 <uartinit>:
{
801052d9:	55                   	push   %ebp
801052da:	89 e5                	mov    %esp,%ebp
801052dc:	56                   	push   %esi
801052dd:	53                   	push   %ebx
801052de:	b9 00 00 00 00       	mov    $0x0,%ecx
801052e3:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052e8:	89 c8                	mov    %ecx,%eax
801052ea:	ee                   	out    %al,(%dx)
801052eb:	be fb 03 00 00       	mov    $0x3fb,%esi
801052f0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801052f5:	89 f2                	mov    %esi,%edx
801052f7:	ee                   	out    %al,(%dx)
801052f8:	b8 0c 00 00 00       	mov    $0xc,%eax
801052fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105302:	ee                   	out    %al,(%dx)
80105303:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105308:	89 c8                	mov    %ecx,%eax
8010530a:	89 da                	mov    %ebx,%edx
8010530c:	ee                   	out    %al,(%dx)
8010530d:	b8 03 00 00 00       	mov    $0x3,%eax
80105312:	89 f2                	mov    %esi,%edx
80105314:	ee                   	out    %al,(%dx)
80105315:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010531a:	89 c8                	mov    %ecx,%eax
8010531c:	ee                   	out    %al,(%dx)
8010531d:	b8 01 00 00 00       	mov    $0x1,%eax
80105322:	89 da                	mov    %ebx,%edx
80105324:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105325:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010532a:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010532b:	3c ff                	cmp    $0xff,%al
8010532d:	74 45                	je     80105374 <uartinit+0x9b>
  uart = 1;
8010532f:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105336:	00 00 00 
80105339:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010533e:	ec                   	in     (%dx),%al
8010533f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105344:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105345:	83 ec 08             	sub    $0x8,%esp
80105348:	6a 00                	push   $0x0
8010534a:	6a 04                	push   $0x4
8010534c:	e8 1b cc ff ff       	call   80101f6c <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105351:	83 c4 10             	add    $0x10,%esp
80105354:	bb 38 71 10 80       	mov    $0x80107138,%ebx
80105359:	eb 12                	jmp    8010536d <uartinit+0x94>
    uartputc(*p);
8010535b:	83 ec 0c             	sub    $0xc,%esp
8010535e:	0f be c0             	movsbl %al,%eax
80105361:	50                   	push   %eax
80105362:	e8 2c ff ff ff       	call   80105293 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105367:	83 c3 01             	add    $0x1,%ebx
8010536a:	83 c4 10             	add    $0x10,%esp
8010536d:	0f b6 03             	movzbl (%ebx),%eax
80105370:	84 c0                	test   %al,%al
80105372:	75 e7                	jne    8010535b <uartinit+0x82>
}
80105374:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105377:	5b                   	pop    %ebx
80105378:	5e                   	pop    %esi
80105379:	5d                   	pop    %ebp
8010537a:	c3                   	ret    

8010537b <uartintr>:

void
uartintr(void)
{
8010537b:	55                   	push   %ebp
8010537c:	89 e5                	mov    %esp,%ebp
8010537e:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105381:	68 64 52 10 80       	push   $0x80105264
80105386:	e8 b3 b3 ff ff       	call   8010073e <consoleintr>
}
8010538b:	83 c4 10             	add    $0x10,%esp
8010538e:	c9                   	leave  
8010538f:	c3                   	ret    

80105390 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105390:	6a 00                	push   $0x0
  pushl $0
80105392:	6a 00                	push   $0x0
  jmp alltraps
80105394:	e9 be fb ff ff       	jmp    80104f57 <alltraps>

80105399 <vector1>:
.globl vector1
vector1:
  pushl $0
80105399:	6a 00                	push   $0x0
  pushl $1
8010539b:	6a 01                	push   $0x1
  jmp alltraps
8010539d:	e9 b5 fb ff ff       	jmp    80104f57 <alltraps>

801053a2 <vector2>:
.globl vector2
vector2:
  pushl $0
801053a2:	6a 00                	push   $0x0
  pushl $2
801053a4:	6a 02                	push   $0x2
  jmp alltraps
801053a6:	e9 ac fb ff ff       	jmp    80104f57 <alltraps>

801053ab <vector3>:
.globl vector3
vector3:
  pushl $0
801053ab:	6a 00                	push   $0x0
  pushl $3
801053ad:	6a 03                	push   $0x3
  jmp alltraps
801053af:	e9 a3 fb ff ff       	jmp    80104f57 <alltraps>

801053b4 <vector4>:
.globl vector4
vector4:
  pushl $0
801053b4:	6a 00                	push   $0x0
  pushl $4
801053b6:	6a 04                	push   $0x4
  jmp alltraps
801053b8:	e9 9a fb ff ff       	jmp    80104f57 <alltraps>

801053bd <vector5>:
.globl vector5
vector5:
  pushl $0
801053bd:	6a 00                	push   $0x0
  pushl $5
801053bf:	6a 05                	push   $0x5
  jmp alltraps
801053c1:	e9 91 fb ff ff       	jmp    80104f57 <alltraps>

801053c6 <vector6>:
.globl vector6
vector6:
  pushl $0
801053c6:	6a 00                	push   $0x0
  pushl $6
801053c8:	6a 06                	push   $0x6
  jmp alltraps
801053ca:	e9 88 fb ff ff       	jmp    80104f57 <alltraps>

801053cf <vector7>:
.globl vector7
vector7:
  pushl $0
801053cf:	6a 00                	push   $0x0
  pushl $7
801053d1:	6a 07                	push   $0x7
  jmp alltraps
801053d3:	e9 7f fb ff ff       	jmp    80104f57 <alltraps>

801053d8 <vector8>:
.globl vector8
vector8:
  pushl $8
801053d8:	6a 08                	push   $0x8
  jmp alltraps
801053da:	e9 78 fb ff ff       	jmp    80104f57 <alltraps>

801053df <vector9>:
.globl vector9
vector9:
  pushl $0
801053df:	6a 00                	push   $0x0
  pushl $9
801053e1:	6a 09                	push   $0x9
  jmp alltraps
801053e3:	e9 6f fb ff ff       	jmp    80104f57 <alltraps>

801053e8 <vector10>:
.globl vector10
vector10:
  pushl $10
801053e8:	6a 0a                	push   $0xa
  jmp alltraps
801053ea:	e9 68 fb ff ff       	jmp    80104f57 <alltraps>

801053ef <vector11>:
.globl vector11
vector11:
  pushl $11
801053ef:	6a 0b                	push   $0xb
  jmp alltraps
801053f1:	e9 61 fb ff ff       	jmp    80104f57 <alltraps>

801053f6 <vector12>:
.globl vector12
vector12:
  pushl $12
801053f6:	6a 0c                	push   $0xc
  jmp alltraps
801053f8:	e9 5a fb ff ff       	jmp    80104f57 <alltraps>

801053fd <vector13>:
.globl vector13
vector13:
  pushl $13
801053fd:	6a 0d                	push   $0xd
  jmp alltraps
801053ff:	e9 53 fb ff ff       	jmp    80104f57 <alltraps>

80105404 <vector14>:
.globl vector14
vector14:
  pushl $14
80105404:	6a 0e                	push   $0xe
  jmp alltraps
80105406:	e9 4c fb ff ff       	jmp    80104f57 <alltraps>

8010540b <vector15>:
.globl vector15
vector15:
  pushl $0
8010540b:	6a 00                	push   $0x0
  pushl $15
8010540d:	6a 0f                	push   $0xf
  jmp alltraps
8010540f:	e9 43 fb ff ff       	jmp    80104f57 <alltraps>

80105414 <vector16>:
.globl vector16
vector16:
  pushl $0
80105414:	6a 00                	push   $0x0
  pushl $16
80105416:	6a 10                	push   $0x10
  jmp alltraps
80105418:	e9 3a fb ff ff       	jmp    80104f57 <alltraps>

8010541d <vector17>:
.globl vector17
vector17:
  pushl $17
8010541d:	6a 11                	push   $0x11
  jmp alltraps
8010541f:	e9 33 fb ff ff       	jmp    80104f57 <alltraps>

80105424 <vector18>:
.globl vector18
vector18:
  pushl $0
80105424:	6a 00                	push   $0x0
  pushl $18
80105426:	6a 12                	push   $0x12
  jmp alltraps
80105428:	e9 2a fb ff ff       	jmp    80104f57 <alltraps>

8010542d <vector19>:
.globl vector19
vector19:
  pushl $0
8010542d:	6a 00                	push   $0x0
  pushl $19
8010542f:	6a 13                	push   $0x13
  jmp alltraps
80105431:	e9 21 fb ff ff       	jmp    80104f57 <alltraps>

80105436 <vector20>:
.globl vector20
vector20:
  pushl $0
80105436:	6a 00                	push   $0x0
  pushl $20
80105438:	6a 14                	push   $0x14
  jmp alltraps
8010543a:	e9 18 fb ff ff       	jmp    80104f57 <alltraps>

8010543f <vector21>:
.globl vector21
vector21:
  pushl $0
8010543f:	6a 00                	push   $0x0
  pushl $21
80105441:	6a 15                	push   $0x15
  jmp alltraps
80105443:	e9 0f fb ff ff       	jmp    80104f57 <alltraps>

80105448 <vector22>:
.globl vector22
vector22:
  pushl $0
80105448:	6a 00                	push   $0x0
  pushl $22
8010544a:	6a 16                	push   $0x16
  jmp alltraps
8010544c:	e9 06 fb ff ff       	jmp    80104f57 <alltraps>

80105451 <vector23>:
.globl vector23
vector23:
  pushl $0
80105451:	6a 00                	push   $0x0
  pushl $23
80105453:	6a 17                	push   $0x17
  jmp alltraps
80105455:	e9 fd fa ff ff       	jmp    80104f57 <alltraps>

8010545a <vector24>:
.globl vector24
vector24:
  pushl $0
8010545a:	6a 00                	push   $0x0
  pushl $24
8010545c:	6a 18                	push   $0x18
  jmp alltraps
8010545e:	e9 f4 fa ff ff       	jmp    80104f57 <alltraps>

80105463 <vector25>:
.globl vector25
vector25:
  pushl $0
80105463:	6a 00                	push   $0x0
  pushl $25
80105465:	6a 19                	push   $0x19
  jmp alltraps
80105467:	e9 eb fa ff ff       	jmp    80104f57 <alltraps>

8010546c <vector26>:
.globl vector26
vector26:
  pushl $0
8010546c:	6a 00                	push   $0x0
  pushl $26
8010546e:	6a 1a                	push   $0x1a
  jmp alltraps
80105470:	e9 e2 fa ff ff       	jmp    80104f57 <alltraps>

80105475 <vector27>:
.globl vector27
vector27:
  pushl $0
80105475:	6a 00                	push   $0x0
  pushl $27
80105477:	6a 1b                	push   $0x1b
  jmp alltraps
80105479:	e9 d9 fa ff ff       	jmp    80104f57 <alltraps>

8010547e <vector28>:
.globl vector28
vector28:
  pushl $0
8010547e:	6a 00                	push   $0x0
  pushl $28
80105480:	6a 1c                	push   $0x1c
  jmp alltraps
80105482:	e9 d0 fa ff ff       	jmp    80104f57 <alltraps>

80105487 <vector29>:
.globl vector29
vector29:
  pushl $0
80105487:	6a 00                	push   $0x0
  pushl $29
80105489:	6a 1d                	push   $0x1d
  jmp alltraps
8010548b:	e9 c7 fa ff ff       	jmp    80104f57 <alltraps>

80105490 <vector30>:
.globl vector30
vector30:
  pushl $0
80105490:	6a 00                	push   $0x0
  pushl $30
80105492:	6a 1e                	push   $0x1e
  jmp alltraps
80105494:	e9 be fa ff ff       	jmp    80104f57 <alltraps>

80105499 <vector31>:
.globl vector31
vector31:
  pushl $0
80105499:	6a 00                	push   $0x0
  pushl $31
8010549b:	6a 1f                	push   $0x1f
  jmp alltraps
8010549d:	e9 b5 fa ff ff       	jmp    80104f57 <alltraps>

801054a2 <vector32>:
.globl vector32
vector32:
  pushl $0
801054a2:	6a 00                	push   $0x0
  pushl $32
801054a4:	6a 20                	push   $0x20
  jmp alltraps
801054a6:	e9 ac fa ff ff       	jmp    80104f57 <alltraps>

801054ab <vector33>:
.globl vector33
vector33:
  pushl $0
801054ab:	6a 00                	push   $0x0
  pushl $33
801054ad:	6a 21                	push   $0x21
  jmp alltraps
801054af:	e9 a3 fa ff ff       	jmp    80104f57 <alltraps>

801054b4 <vector34>:
.globl vector34
vector34:
  pushl $0
801054b4:	6a 00                	push   $0x0
  pushl $34
801054b6:	6a 22                	push   $0x22
  jmp alltraps
801054b8:	e9 9a fa ff ff       	jmp    80104f57 <alltraps>

801054bd <vector35>:
.globl vector35
vector35:
  pushl $0
801054bd:	6a 00                	push   $0x0
  pushl $35
801054bf:	6a 23                	push   $0x23
  jmp alltraps
801054c1:	e9 91 fa ff ff       	jmp    80104f57 <alltraps>

801054c6 <vector36>:
.globl vector36
vector36:
  pushl $0
801054c6:	6a 00                	push   $0x0
  pushl $36
801054c8:	6a 24                	push   $0x24
  jmp alltraps
801054ca:	e9 88 fa ff ff       	jmp    80104f57 <alltraps>

801054cf <vector37>:
.globl vector37
vector37:
  pushl $0
801054cf:	6a 00                	push   $0x0
  pushl $37
801054d1:	6a 25                	push   $0x25
  jmp alltraps
801054d3:	e9 7f fa ff ff       	jmp    80104f57 <alltraps>

801054d8 <vector38>:
.globl vector38
vector38:
  pushl $0
801054d8:	6a 00                	push   $0x0
  pushl $38
801054da:	6a 26                	push   $0x26
  jmp alltraps
801054dc:	e9 76 fa ff ff       	jmp    80104f57 <alltraps>

801054e1 <vector39>:
.globl vector39
vector39:
  pushl $0
801054e1:	6a 00                	push   $0x0
  pushl $39
801054e3:	6a 27                	push   $0x27
  jmp alltraps
801054e5:	e9 6d fa ff ff       	jmp    80104f57 <alltraps>

801054ea <vector40>:
.globl vector40
vector40:
  pushl $0
801054ea:	6a 00                	push   $0x0
  pushl $40
801054ec:	6a 28                	push   $0x28
  jmp alltraps
801054ee:	e9 64 fa ff ff       	jmp    80104f57 <alltraps>

801054f3 <vector41>:
.globl vector41
vector41:
  pushl $0
801054f3:	6a 00                	push   $0x0
  pushl $41
801054f5:	6a 29                	push   $0x29
  jmp alltraps
801054f7:	e9 5b fa ff ff       	jmp    80104f57 <alltraps>

801054fc <vector42>:
.globl vector42
vector42:
  pushl $0
801054fc:	6a 00                	push   $0x0
  pushl $42
801054fe:	6a 2a                	push   $0x2a
  jmp alltraps
80105500:	e9 52 fa ff ff       	jmp    80104f57 <alltraps>

80105505 <vector43>:
.globl vector43
vector43:
  pushl $0
80105505:	6a 00                	push   $0x0
  pushl $43
80105507:	6a 2b                	push   $0x2b
  jmp alltraps
80105509:	e9 49 fa ff ff       	jmp    80104f57 <alltraps>

8010550e <vector44>:
.globl vector44
vector44:
  pushl $0
8010550e:	6a 00                	push   $0x0
  pushl $44
80105510:	6a 2c                	push   $0x2c
  jmp alltraps
80105512:	e9 40 fa ff ff       	jmp    80104f57 <alltraps>

80105517 <vector45>:
.globl vector45
vector45:
  pushl $0
80105517:	6a 00                	push   $0x0
  pushl $45
80105519:	6a 2d                	push   $0x2d
  jmp alltraps
8010551b:	e9 37 fa ff ff       	jmp    80104f57 <alltraps>

80105520 <vector46>:
.globl vector46
vector46:
  pushl $0
80105520:	6a 00                	push   $0x0
  pushl $46
80105522:	6a 2e                	push   $0x2e
  jmp alltraps
80105524:	e9 2e fa ff ff       	jmp    80104f57 <alltraps>

80105529 <vector47>:
.globl vector47
vector47:
  pushl $0
80105529:	6a 00                	push   $0x0
  pushl $47
8010552b:	6a 2f                	push   $0x2f
  jmp alltraps
8010552d:	e9 25 fa ff ff       	jmp    80104f57 <alltraps>

80105532 <vector48>:
.globl vector48
vector48:
  pushl $0
80105532:	6a 00                	push   $0x0
  pushl $48
80105534:	6a 30                	push   $0x30
  jmp alltraps
80105536:	e9 1c fa ff ff       	jmp    80104f57 <alltraps>

8010553b <vector49>:
.globl vector49
vector49:
  pushl $0
8010553b:	6a 00                	push   $0x0
  pushl $49
8010553d:	6a 31                	push   $0x31
  jmp alltraps
8010553f:	e9 13 fa ff ff       	jmp    80104f57 <alltraps>

80105544 <vector50>:
.globl vector50
vector50:
  pushl $0
80105544:	6a 00                	push   $0x0
  pushl $50
80105546:	6a 32                	push   $0x32
  jmp alltraps
80105548:	e9 0a fa ff ff       	jmp    80104f57 <alltraps>

8010554d <vector51>:
.globl vector51
vector51:
  pushl $0
8010554d:	6a 00                	push   $0x0
  pushl $51
8010554f:	6a 33                	push   $0x33
  jmp alltraps
80105551:	e9 01 fa ff ff       	jmp    80104f57 <alltraps>

80105556 <vector52>:
.globl vector52
vector52:
  pushl $0
80105556:	6a 00                	push   $0x0
  pushl $52
80105558:	6a 34                	push   $0x34
  jmp alltraps
8010555a:	e9 f8 f9 ff ff       	jmp    80104f57 <alltraps>

8010555f <vector53>:
.globl vector53
vector53:
  pushl $0
8010555f:	6a 00                	push   $0x0
  pushl $53
80105561:	6a 35                	push   $0x35
  jmp alltraps
80105563:	e9 ef f9 ff ff       	jmp    80104f57 <alltraps>

80105568 <vector54>:
.globl vector54
vector54:
  pushl $0
80105568:	6a 00                	push   $0x0
  pushl $54
8010556a:	6a 36                	push   $0x36
  jmp alltraps
8010556c:	e9 e6 f9 ff ff       	jmp    80104f57 <alltraps>

80105571 <vector55>:
.globl vector55
vector55:
  pushl $0
80105571:	6a 00                	push   $0x0
  pushl $55
80105573:	6a 37                	push   $0x37
  jmp alltraps
80105575:	e9 dd f9 ff ff       	jmp    80104f57 <alltraps>

8010557a <vector56>:
.globl vector56
vector56:
  pushl $0
8010557a:	6a 00                	push   $0x0
  pushl $56
8010557c:	6a 38                	push   $0x38
  jmp alltraps
8010557e:	e9 d4 f9 ff ff       	jmp    80104f57 <alltraps>

80105583 <vector57>:
.globl vector57
vector57:
  pushl $0
80105583:	6a 00                	push   $0x0
  pushl $57
80105585:	6a 39                	push   $0x39
  jmp alltraps
80105587:	e9 cb f9 ff ff       	jmp    80104f57 <alltraps>

8010558c <vector58>:
.globl vector58
vector58:
  pushl $0
8010558c:	6a 00                	push   $0x0
  pushl $58
8010558e:	6a 3a                	push   $0x3a
  jmp alltraps
80105590:	e9 c2 f9 ff ff       	jmp    80104f57 <alltraps>

80105595 <vector59>:
.globl vector59
vector59:
  pushl $0
80105595:	6a 00                	push   $0x0
  pushl $59
80105597:	6a 3b                	push   $0x3b
  jmp alltraps
80105599:	e9 b9 f9 ff ff       	jmp    80104f57 <alltraps>

8010559e <vector60>:
.globl vector60
vector60:
  pushl $0
8010559e:	6a 00                	push   $0x0
  pushl $60
801055a0:	6a 3c                	push   $0x3c
  jmp alltraps
801055a2:	e9 b0 f9 ff ff       	jmp    80104f57 <alltraps>

801055a7 <vector61>:
.globl vector61
vector61:
  pushl $0
801055a7:	6a 00                	push   $0x0
  pushl $61
801055a9:	6a 3d                	push   $0x3d
  jmp alltraps
801055ab:	e9 a7 f9 ff ff       	jmp    80104f57 <alltraps>

801055b0 <vector62>:
.globl vector62
vector62:
  pushl $0
801055b0:	6a 00                	push   $0x0
  pushl $62
801055b2:	6a 3e                	push   $0x3e
  jmp alltraps
801055b4:	e9 9e f9 ff ff       	jmp    80104f57 <alltraps>

801055b9 <vector63>:
.globl vector63
vector63:
  pushl $0
801055b9:	6a 00                	push   $0x0
  pushl $63
801055bb:	6a 3f                	push   $0x3f
  jmp alltraps
801055bd:	e9 95 f9 ff ff       	jmp    80104f57 <alltraps>

801055c2 <vector64>:
.globl vector64
vector64:
  pushl $0
801055c2:	6a 00                	push   $0x0
  pushl $64
801055c4:	6a 40                	push   $0x40
  jmp alltraps
801055c6:	e9 8c f9 ff ff       	jmp    80104f57 <alltraps>

801055cb <vector65>:
.globl vector65
vector65:
  pushl $0
801055cb:	6a 00                	push   $0x0
  pushl $65
801055cd:	6a 41                	push   $0x41
  jmp alltraps
801055cf:	e9 83 f9 ff ff       	jmp    80104f57 <alltraps>

801055d4 <vector66>:
.globl vector66
vector66:
  pushl $0
801055d4:	6a 00                	push   $0x0
  pushl $66
801055d6:	6a 42                	push   $0x42
  jmp alltraps
801055d8:	e9 7a f9 ff ff       	jmp    80104f57 <alltraps>

801055dd <vector67>:
.globl vector67
vector67:
  pushl $0
801055dd:	6a 00                	push   $0x0
  pushl $67
801055df:	6a 43                	push   $0x43
  jmp alltraps
801055e1:	e9 71 f9 ff ff       	jmp    80104f57 <alltraps>

801055e6 <vector68>:
.globl vector68
vector68:
  pushl $0
801055e6:	6a 00                	push   $0x0
  pushl $68
801055e8:	6a 44                	push   $0x44
  jmp alltraps
801055ea:	e9 68 f9 ff ff       	jmp    80104f57 <alltraps>

801055ef <vector69>:
.globl vector69
vector69:
  pushl $0
801055ef:	6a 00                	push   $0x0
  pushl $69
801055f1:	6a 45                	push   $0x45
  jmp alltraps
801055f3:	e9 5f f9 ff ff       	jmp    80104f57 <alltraps>

801055f8 <vector70>:
.globl vector70
vector70:
  pushl $0
801055f8:	6a 00                	push   $0x0
  pushl $70
801055fa:	6a 46                	push   $0x46
  jmp alltraps
801055fc:	e9 56 f9 ff ff       	jmp    80104f57 <alltraps>

80105601 <vector71>:
.globl vector71
vector71:
  pushl $0
80105601:	6a 00                	push   $0x0
  pushl $71
80105603:	6a 47                	push   $0x47
  jmp alltraps
80105605:	e9 4d f9 ff ff       	jmp    80104f57 <alltraps>

8010560a <vector72>:
.globl vector72
vector72:
  pushl $0
8010560a:	6a 00                	push   $0x0
  pushl $72
8010560c:	6a 48                	push   $0x48
  jmp alltraps
8010560e:	e9 44 f9 ff ff       	jmp    80104f57 <alltraps>

80105613 <vector73>:
.globl vector73
vector73:
  pushl $0
80105613:	6a 00                	push   $0x0
  pushl $73
80105615:	6a 49                	push   $0x49
  jmp alltraps
80105617:	e9 3b f9 ff ff       	jmp    80104f57 <alltraps>

8010561c <vector74>:
.globl vector74
vector74:
  pushl $0
8010561c:	6a 00                	push   $0x0
  pushl $74
8010561e:	6a 4a                	push   $0x4a
  jmp alltraps
80105620:	e9 32 f9 ff ff       	jmp    80104f57 <alltraps>

80105625 <vector75>:
.globl vector75
vector75:
  pushl $0
80105625:	6a 00                	push   $0x0
  pushl $75
80105627:	6a 4b                	push   $0x4b
  jmp alltraps
80105629:	e9 29 f9 ff ff       	jmp    80104f57 <alltraps>

8010562e <vector76>:
.globl vector76
vector76:
  pushl $0
8010562e:	6a 00                	push   $0x0
  pushl $76
80105630:	6a 4c                	push   $0x4c
  jmp alltraps
80105632:	e9 20 f9 ff ff       	jmp    80104f57 <alltraps>

80105637 <vector77>:
.globl vector77
vector77:
  pushl $0
80105637:	6a 00                	push   $0x0
  pushl $77
80105639:	6a 4d                	push   $0x4d
  jmp alltraps
8010563b:	e9 17 f9 ff ff       	jmp    80104f57 <alltraps>

80105640 <vector78>:
.globl vector78
vector78:
  pushl $0
80105640:	6a 00                	push   $0x0
  pushl $78
80105642:	6a 4e                	push   $0x4e
  jmp alltraps
80105644:	e9 0e f9 ff ff       	jmp    80104f57 <alltraps>

80105649 <vector79>:
.globl vector79
vector79:
  pushl $0
80105649:	6a 00                	push   $0x0
  pushl $79
8010564b:	6a 4f                	push   $0x4f
  jmp alltraps
8010564d:	e9 05 f9 ff ff       	jmp    80104f57 <alltraps>

80105652 <vector80>:
.globl vector80
vector80:
  pushl $0
80105652:	6a 00                	push   $0x0
  pushl $80
80105654:	6a 50                	push   $0x50
  jmp alltraps
80105656:	e9 fc f8 ff ff       	jmp    80104f57 <alltraps>

8010565b <vector81>:
.globl vector81
vector81:
  pushl $0
8010565b:	6a 00                	push   $0x0
  pushl $81
8010565d:	6a 51                	push   $0x51
  jmp alltraps
8010565f:	e9 f3 f8 ff ff       	jmp    80104f57 <alltraps>

80105664 <vector82>:
.globl vector82
vector82:
  pushl $0
80105664:	6a 00                	push   $0x0
  pushl $82
80105666:	6a 52                	push   $0x52
  jmp alltraps
80105668:	e9 ea f8 ff ff       	jmp    80104f57 <alltraps>

8010566d <vector83>:
.globl vector83
vector83:
  pushl $0
8010566d:	6a 00                	push   $0x0
  pushl $83
8010566f:	6a 53                	push   $0x53
  jmp alltraps
80105671:	e9 e1 f8 ff ff       	jmp    80104f57 <alltraps>

80105676 <vector84>:
.globl vector84
vector84:
  pushl $0
80105676:	6a 00                	push   $0x0
  pushl $84
80105678:	6a 54                	push   $0x54
  jmp alltraps
8010567a:	e9 d8 f8 ff ff       	jmp    80104f57 <alltraps>

8010567f <vector85>:
.globl vector85
vector85:
  pushl $0
8010567f:	6a 00                	push   $0x0
  pushl $85
80105681:	6a 55                	push   $0x55
  jmp alltraps
80105683:	e9 cf f8 ff ff       	jmp    80104f57 <alltraps>

80105688 <vector86>:
.globl vector86
vector86:
  pushl $0
80105688:	6a 00                	push   $0x0
  pushl $86
8010568a:	6a 56                	push   $0x56
  jmp alltraps
8010568c:	e9 c6 f8 ff ff       	jmp    80104f57 <alltraps>

80105691 <vector87>:
.globl vector87
vector87:
  pushl $0
80105691:	6a 00                	push   $0x0
  pushl $87
80105693:	6a 57                	push   $0x57
  jmp alltraps
80105695:	e9 bd f8 ff ff       	jmp    80104f57 <alltraps>

8010569a <vector88>:
.globl vector88
vector88:
  pushl $0
8010569a:	6a 00                	push   $0x0
  pushl $88
8010569c:	6a 58                	push   $0x58
  jmp alltraps
8010569e:	e9 b4 f8 ff ff       	jmp    80104f57 <alltraps>

801056a3 <vector89>:
.globl vector89
vector89:
  pushl $0
801056a3:	6a 00                	push   $0x0
  pushl $89
801056a5:	6a 59                	push   $0x59
  jmp alltraps
801056a7:	e9 ab f8 ff ff       	jmp    80104f57 <alltraps>

801056ac <vector90>:
.globl vector90
vector90:
  pushl $0
801056ac:	6a 00                	push   $0x0
  pushl $90
801056ae:	6a 5a                	push   $0x5a
  jmp alltraps
801056b0:	e9 a2 f8 ff ff       	jmp    80104f57 <alltraps>

801056b5 <vector91>:
.globl vector91
vector91:
  pushl $0
801056b5:	6a 00                	push   $0x0
  pushl $91
801056b7:	6a 5b                	push   $0x5b
  jmp alltraps
801056b9:	e9 99 f8 ff ff       	jmp    80104f57 <alltraps>

801056be <vector92>:
.globl vector92
vector92:
  pushl $0
801056be:	6a 00                	push   $0x0
  pushl $92
801056c0:	6a 5c                	push   $0x5c
  jmp alltraps
801056c2:	e9 90 f8 ff ff       	jmp    80104f57 <alltraps>

801056c7 <vector93>:
.globl vector93
vector93:
  pushl $0
801056c7:	6a 00                	push   $0x0
  pushl $93
801056c9:	6a 5d                	push   $0x5d
  jmp alltraps
801056cb:	e9 87 f8 ff ff       	jmp    80104f57 <alltraps>

801056d0 <vector94>:
.globl vector94
vector94:
  pushl $0
801056d0:	6a 00                	push   $0x0
  pushl $94
801056d2:	6a 5e                	push   $0x5e
  jmp alltraps
801056d4:	e9 7e f8 ff ff       	jmp    80104f57 <alltraps>

801056d9 <vector95>:
.globl vector95
vector95:
  pushl $0
801056d9:	6a 00                	push   $0x0
  pushl $95
801056db:	6a 5f                	push   $0x5f
  jmp alltraps
801056dd:	e9 75 f8 ff ff       	jmp    80104f57 <alltraps>

801056e2 <vector96>:
.globl vector96
vector96:
  pushl $0
801056e2:	6a 00                	push   $0x0
  pushl $96
801056e4:	6a 60                	push   $0x60
  jmp alltraps
801056e6:	e9 6c f8 ff ff       	jmp    80104f57 <alltraps>

801056eb <vector97>:
.globl vector97
vector97:
  pushl $0
801056eb:	6a 00                	push   $0x0
  pushl $97
801056ed:	6a 61                	push   $0x61
  jmp alltraps
801056ef:	e9 63 f8 ff ff       	jmp    80104f57 <alltraps>

801056f4 <vector98>:
.globl vector98
vector98:
  pushl $0
801056f4:	6a 00                	push   $0x0
  pushl $98
801056f6:	6a 62                	push   $0x62
  jmp alltraps
801056f8:	e9 5a f8 ff ff       	jmp    80104f57 <alltraps>

801056fd <vector99>:
.globl vector99
vector99:
  pushl $0
801056fd:	6a 00                	push   $0x0
  pushl $99
801056ff:	6a 63                	push   $0x63
  jmp alltraps
80105701:	e9 51 f8 ff ff       	jmp    80104f57 <alltraps>

80105706 <vector100>:
.globl vector100
vector100:
  pushl $0
80105706:	6a 00                	push   $0x0
  pushl $100
80105708:	6a 64                	push   $0x64
  jmp alltraps
8010570a:	e9 48 f8 ff ff       	jmp    80104f57 <alltraps>

8010570f <vector101>:
.globl vector101
vector101:
  pushl $0
8010570f:	6a 00                	push   $0x0
  pushl $101
80105711:	6a 65                	push   $0x65
  jmp alltraps
80105713:	e9 3f f8 ff ff       	jmp    80104f57 <alltraps>

80105718 <vector102>:
.globl vector102
vector102:
  pushl $0
80105718:	6a 00                	push   $0x0
  pushl $102
8010571a:	6a 66                	push   $0x66
  jmp alltraps
8010571c:	e9 36 f8 ff ff       	jmp    80104f57 <alltraps>

80105721 <vector103>:
.globl vector103
vector103:
  pushl $0
80105721:	6a 00                	push   $0x0
  pushl $103
80105723:	6a 67                	push   $0x67
  jmp alltraps
80105725:	e9 2d f8 ff ff       	jmp    80104f57 <alltraps>

8010572a <vector104>:
.globl vector104
vector104:
  pushl $0
8010572a:	6a 00                	push   $0x0
  pushl $104
8010572c:	6a 68                	push   $0x68
  jmp alltraps
8010572e:	e9 24 f8 ff ff       	jmp    80104f57 <alltraps>

80105733 <vector105>:
.globl vector105
vector105:
  pushl $0
80105733:	6a 00                	push   $0x0
  pushl $105
80105735:	6a 69                	push   $0x69
  jmp alltraps
80105737:	e9 1b f8 ff ff       	jmp    80104f57 <alltraps>

8010573c <vector106>:
.globl vector106
vector106:
  pushl $0
8010573c:	6a 00                	push   $0x0
  pushl $106
8010573e:	6a 6a                	push   $0x6a
  jmp alltraps
80105740:	e9 12 f8 ff ff       	jmp    80104f57 <alltraps>

80105745 <vector107>:
.globl vector107
vector107:
  pushl $0
80105745:	6a 00                	push   $0x0
  pushl $107
80105747:	6a 6b                	push   $0x6b
  jmp alltraps
80105749:	e9 09 f8 ff ff       	jmp    80104f57 <alltraps>

8010574e <vector108>:
.globl vector108
vector108:
  pushl $0
8010574e:	6a 00                	push   $0x0
  pushl $108
80105750:	6a 6c                	push   $0x6c
  jmp alltraps
80105752:	e9 00 f8 ff ff       	jmp    80104f57 <alltraps>

80105757 <vector109>:
.globl vector109
vector109:
  pushl $0
80105757:	6a 00                	push   $0x0
  pushl $109
80105759:	6a 6d                	push   $0x6d
  jmp alltraps
8010575b:	e9 f7 f7 ff ff       	jmp    80104f57 <alltraps>

80105760 <vector110>:
.globl vector110
vector110:
  pushl $0
80105760:	6a 00                	push   $0x0
  pushl $110
80105762:	6a 6e                	push   $0x6e
  jmp alltraps
80105764:	e9 ee f7 ff ff       	jmp    80104f57 <alltraps>

80105769 <vector111>:
.globl vector111
vector111:
  pushl $0
80105769:	6a 00                	push   $0x0
  pushl $111
8010576b:	6a 6f                	push   $0x6f
  jmp alltraps
8010576d:	e9 e5 f7 ff ff       	jmp    80104f57 <alltraps>

80105772 <vector112>:
.globl vector112
vector112:
  pushl $0
80105772:	6a 00                	push   $0x0
  pushl $112
80105774:	6a 70                	push   $0x70
  jmp alltraps
80105776:	e9 dc f7 ff ff       	jmp    80104f57 <alltraps>

8010577b <vector113>:
.globl vector113
vector113:
  pushl $0
8010577b:	6a 00                	push   $0x0
  pushl $113
8010577d:	6a 71                	push   $0x71
  jmp alltraps
8010577f:	e9 d3 f7 ff ff       	jmp    80104f57 <alltraps>

80105784 <vector114>:
.globl vector114
vector114:
  pushl $0
80105784:	6a 00                	push   $0x0
  pushl $114
80105786:	6a 72                	push   $0x72
  jmp alltraps
80105788:	e9 ca f7 ff ff       	jmp    80104f57 <alltraps>

8010578d <vector115>:
.globl vector115
vector115:
  pushl $0
8010578d:	6a 00                	push   $0x0
  pushl $115
8010578f:	6a 73                	push   $0x73
  jmp alltraps
80105791:	e9 c1 f7 ff ff       	jmp    80104f57 <alltraps>

80105796 <vector116>:
.globl vector116
vector116:
  pushl $0
80105796:	6a 00                	push   $0x0
  pushl $116
80105798:	6a 74                	push   $0x74
  jmp alltraps
8010579a:	e9 b8 f7 ff ff       	jmp    80104f57 <alltraps>

8010579f <vector117>:
.globl vector117
vector117:
  pushl $0
8010579f:	6a 00                	push   $0x0
  pushl $117
801057a1:	6a 75                	push   $0x75
  jmp alltraps
801057a3:	e9 af f7 ff ff       	jmp    80104f57 <alltraps>

801057a8 <vector118>:
.globl vector118
vector118:
  pushl $0
801057a8:	6a 00                	push   $0x0
  pushl $118
801057aa:	6a 76                	push   $0x76
  jmp alltraps
801057ac:	e9 a6 f7 ff ff       	jmp    80104f57 <alltraps>

801057b1 <vector119>:
.globl vector119
vector119:
  pushl $0
801057b1:	6a 00                	push   $0x0
  pushl $119
801057b3:	6a 77                	push   $0x77
  jmp alltraps
801057b5:	e9 9d f7 ff ff       	jmp    80104f57 <alltraps>

801057ba <vector120>:
.globl vector120
vector120:
  pushl $0
801057ba:	6a 00                	push   $0x0
  pushl $120
801057bc:	6a 78                	push   $0x78
  jmp alltraps
801057be:	e9 94 f7 ff ff       	jmp    80104f57 <alltraps>

801057c3 <vector121>:
.globl vector121
vector121:
  pushl $0
801057c3:	6a 00                	push   $0x0
  pushl $121
801057c5:	6a 79                	push   $0x79
  jmp alltraps
801057c7:	e9 8b f7 ff ff       	jmp    80104f57 <alltraps>

801057cc <vector122>:
.globl vector122
vector122:
  pushl $0
801057cc:	6a 00                	push   $0x0
  pushl $122
801057ce:	6a 7a                	push   $0x7a
  jmp alltraps
801057d0:	e9 82 f7 ff ff       	jmp    80104f57 <alltraps>

801057d5 <vector123>:
.globl vector123
vector123:
  pushl $0
801057d5:	6a 00                	push   $0x0
  pushl $123
801057d7:	6a 7b                	push   $0x7b
  jmp alltraps
801057d9:	e9 79 f7 ff ff       	jmp    80104f57 <alltraps>

801057de <vector124>:
.globl vector124
vector124:
  pushl $0
801057de:	6a 00                	push   $0x0
  pushl $124
801057e0:	6a 7c                	push   $0x7c
  jmp alltraps
801057e2:	e9 70 f7 ff ff       	jmp    80104f57 <alltraps>

801057e7 <vector125>:
.globl vector125
vector125:
  pushl $0
801057e7:	6a 00                	push   $0x0
  pushl $125
801057e9:	6a 7d                	push   $0x7d
  jmp alltraps
801057eb:	e9 67 f7 ff ff       	jmp    80104f57 <alltraps>

801057f0 <vector126>:
.globl vector126
vector126:
  pushl $0
801057f0:	6a 00                	push   $0x0
  pushl $126
801057f2:	6a 7e                	push   $0x7e
  jmp alltraps
801057f4:	e9 5e f7 ff ff       	jmp    80104f57 <alltraps>

801057f9 <vector127>:
.globl vector127
vector127:
  pushl $0
801057f9:	6a 00                	push   $0x0
  pushl $127
801057fb:	6a 7f                	push   $0x7f
  jmp alltraps
801057fd:	e9 55 f7 ff ff       	jmp    80104f57 <alltraps>

80105802 <vector128>:
.globl vector128
vector128:
  pushl $0
80105802:	6a 00                	push   $0x0
  pushl $128
80105804:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105809:	e9 49 f7 ff ff       	jmp    80104f57 <alltraps>

8010580e <vector129>:
.globl vector129
vector129:
  pushl $0
8010580e:	6a 00                	push   $0x0
  pushl $129
80105810:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105815:	e9 3d f7 ff ff       	jmp    80104f57 <alltraps>

8010581a <vector130>:
.globl vector130
vector130:
  pushl $0
8010581a:	6a 00                	push   $0x0
  pushl $130
8010581c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105821:	e9 31 f7 ff ff       	jmp    80104f57 <alltraps>

80105826 <vector131>:
.globl vector131
vector131:
  pushl $0
80105826:	6a 00                	push   $0x0
  pushl $131
80105828:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010582d:	e9 25 f7 ff ff       	jmp    80104f57 <alltraps>

80105832 <vector132>:
.globl vector132
vector132:
  pushl $0
80105832:	6a 00                	push   $0x0
  pushl $132
80105834:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105839:	e9 19 f7 ff ff       	jmp    80104f57 <alltraps>

8010583e <vector133>:
.globl vector133
vector133:
  pushl $0
8010583e:	6a 00                	push   $0x0
  pushl $133
80105840:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105845:	e9 0d f7 ff ff       	jmp    80104f57 <alltraps>

8010584a <vector134>:
.globl vector134
vector134:
  pushl $0
8010584a:	6a 00                	push   $0x0
  pushl $134
8010584c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105851:	e9 01 f7 ff ff       	jmp    80104f57 <alltraps>

80105856 <vector135>:
.globl vector135
vector135:
  pushl $0
80105856:	6a 00                	push   $0x0
  pushl $135
80105858:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010585d:	e9 f5 f6 ff ff       	jmp    80104f57 <alltraps>

80105862 <vector136>:
.globl vector136
vector136:
  pushl $0
80105862:	6a 00                	push   $0x0
  pushl $136
80105864:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105869:	e9 e9 f6 ff ff       	jmp    80104f57 <alltraps>

8010586e <vector137>:
.globl vector137
vector137:
  pushl $0
8010586e:	6a 00                	push   $0x0
  pushl $137
80105870:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105875:	e9 dd f6 ff ff       	jmp    80104f57 <alltraps>

8010587a <vector138>:
.globl vector138
vector138:
  pushl $0
8010587a:	6a 00                	push   $0x0
  pushl $138
8010587c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105881:	e9 d1 f6 ff ff       	jmp    80104f57 <alltraps>

80105886 <vector139>:
.globl vector139
vector139:
  pushl $0
80105886:	6a 00                	push   $0x0
  pushl $139
80105888:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010588d:	e9 c5 f6 ff ff       	jmp    80104f57 <alltraps>

80105892 <vector140>:
.globl vector140
vector140:
  pushl $0
80105892:	6a 00                	push   $0x0
  pushl $140
80105894:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105899:	e9 b9 f6 ff ff       	jmp    80104f57 <alltraps>

8010589e <vector141>:
.globl vector141
vector141:
  pushl $0
8010589e:	6a 00                	push   $0x0
  pushl $141
801058a0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801058a5:	e9 ad f6 ff ff       	jmp    80104f57 <alltraps>

801058aa <vector142>:
.globl vector142
vector142:
  pushl $0
801058aa:	6a 00                	push   $0x0
  pushl $142
801058ac:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801058b1:	e9 a1 f6 ff ff       	jmp    80104f57 <alltraps>

801058b6 <vector143>:
.globl vector143
vector143:
  pushl $0
801058b6:	6a 00                	push   $0x0
  pushl $143
801058b8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801058bd:	e9 95 f6 ff ff       	jmp    80104f57 <alltraps>

801058c2 <vector144>:
.globl vector144
vector144:
  pushl $0
801058c2:	6a 00                	push   $0x0
  pushl $144
801058c4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801058c9:	e9 89 f6 ff ff       	jmp    80104f57 <alltraps>

801058ce <vector145>:
.globl vector145
vector145:
  pushl $0
801058ce:	6a 00                	push   $0x0
  pushl $145
801058d0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801058d5:	e9 7d f6 ff ff       	jmp    80104f57 <alltraps>

801058da <vector146>:
.globl vector146
vector146:
  pushl $0
801058da:	6a 00                	push   $0x0
  pushl $146
801058dc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801058e1:	e9 71 f6 ff ff       	jmp    80104f57 <alltraps>

801058e6 <vector147>:
.globl vector147
vector147:
  pushl $0
801058e6:	6a 00                	push   $0x0
  pushl $147
801058e8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801058ed:	e9 65 f6 ff ff       	jmp    80104f57 <alltraps>

801058f2 <vector148>:
.globl vector148
vector148:
  pushl $0
801058f2:	6a 00                	push   $0x0
  pushl $148
801058f4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801058f9:	e9 59 f6 ff ff       	jmp    80104f57 <alltraps>

801058fe <vector149>:
.globl vector149
vector149:
  pushl $0
801058fe:	6a 00                	push   $0x0
  pushl $149
80105900:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105905:	e9 4d f6 ff ff       	jmp    80104f57 <alltraps>

8010590a <vector150>:
.globl vector150
vector150:
  pushl $0
8010590a:	6a 00                	push   $0x0
  pushl $150
8010590c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105911:	e9 41 f6 ff ff       	jmp    80104f57 <alltraps>

80105916 <vector151>:
.globl vector151
vector151:
  pushl $0
80105916:	6a 00                	push   $0x0
  pushl $151
80105918:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010591d:	e9 35 f6 ff ff       	jmp    80104f57 <alltraps>

80105922 <vector152>:
.globl vector152
vector152:
  pushl $0
80105922:	6a 00                	push   $0x0
  pushl $152
80105924:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105929:	e9 29 f6 ff ff       	jmp    80104f57 <alltraps>

8010592e <vector153>:
.globl vector153
vector153:
  pushl $0
8010592e:	6a 00                	push   $0x0
  pushl $153
80105930:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105935:	e9 1d f6 ff ff       	jmp    80104f57 <alltraps>

8010593a <vector154>:
.globl vector154
vector154:
  pushl $0
8010593a:	6a 00                	push   $0x0
  pushl $154
8010593c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105941:	e9 11 f6 ff ff       	jmp    80104f57 <alltraps>

80105946 <vector155>:
.globl vector155
vector155:
  pushl $0
80105946:	6a 00                	push   $0x0
  pushl $155
80105948:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010594d:	e9 05 f6 ff ff       	jmp    80104f57 <alltraps>

80105952 <vector156>:
.globl vector156
vector156:
  pushl $0
80105952:	6a 00                	push   $0x0
  pushl $156
80105954:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105959:	e9 f9 f5 ff ff       	jmp    80104f57 <alltraps>

8010595e <vector157>:
.globl vector157
vector157:
  pushl $0
8010595e:	6a 00                	push   $0x0
  pushl $157
80105960:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105965:	e9 ed f5 ff ff       	jmp    80104f57 <alltraps>

8010596a <vector158>:
.globl vector158
vector158:
  pushl $0
8010596a:	6a 00                	push   $0x0
  pushl $158
8010596c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105971:	e9 e1 f5 ff ff       	jmp    80104f57 <alltraps>

80105976 <vector159>:
.globl vector159
vector159:
  pushl $0
80105976:	6a 00                	push   $0x0
  pushl $159
80105978:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010597d:	e9 d5 f5 ff ff       	jmp    80104f57 <alltraps>

80105982 <vector160>:
.globl vector160
vector160:
  pushl $0
80105982:	6a 00                	push   $0x0
  pushl $160
80105984:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105989:	e9 c9 f5 ff ff       	jmp    80104f57 <alltraps>

8010598e <vector161>:
.globl vector161
vector161:
  pushl $0
8010598e:	6a 00                	push   $0x0
  pushl $161
80105990:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105995:	e9 bd f5 ff ff       	jmp    80104f57 <alltraps>

8010599a <vector162>:
.globl vector162
vector162:
  pushl $0
8010599a:	6a 00                	push   $0x0
  pushl $162
8010599c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801059a1:	e9 b1 f5 ff ff       	jmp    80104f57 <alltraps>

801059a6 <vector163>:
.globl vector163
vector163:
  pushl $0
801059a6:	6a 00                	push   $0x0
  pushl $163
801059a8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801059ad:	e9 a5 f5 ff ff       	jmp    80104f57 <alltraps>

801059b2 <vector164>:
.globl vector164
vector164:
  pushl $0
801059b2:	6a 00                	push   $0x0
  pushl $164
801059b4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801059b9:	e9 99 f5 ff ff       	jmp    80104f57 <alltraps>

801059be <vector165>:
.globl vector165
vector165:
  pushl $0
801059be:	6a 00                	push   $0x0
  pushl $165
801059c0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801059c5:	e9 8d f5 ff ff       	jmp    80104f57 <alltraps>

801059ca <vector166>:
.globl vector166
vector166:
  pushl $0
801059ca:	6a 00                	push   $0x0
  pushl $166
801059cc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801059d1:	e9 81 f5 ff ff       	jmp    80104f57 <alltraps>

801059d6 <vector167>:
.globl vector167
vector167:
  pushl $0
801059d6:	6a 00                	push   $0x0
  pushl $167
801059d8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801059dd:	e9 75 f5 ff ff       	jmp    80104f57 <alltraps>

801059e2 <vector168>:
.globl vector168
vector168:
  pushl $0
801059e2:	6a 00                	push   $0x0
  pushl $168
801059e4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801059e9:	e9 69 f5 ff ff       	jmp    80104f57 <alltraps>

801059ee <vector169>:
.globl vector169
vector169:
  pushl $0
801059ee:	6a 00                	push   $0x0
  pushl $169
801059f0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801059f5:	e9 5d f5 ff ff       	jmp    80104f57 <alltraps>

801059fa <vector170>:
.globl vector170
vector170:
  pushl $0
801059fa:	6a 00                	push   $0x0
  pushl $170
801059fc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a01:	e9 51 f5 ff ff       	jmp    80104f57 <alltraps>

80105a06 <vector171>:
.globl vector171
vector171:
  pushl $0
80105a06:	6a 00                	push   $0x0
  pushl $171
80105a08:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a0d:	e9 45 f5 ff ff       	jmp    80104f57 <alltraps>

80105a12 <vector172>:
.globl vector172
vector172:
  pushl $0
80105a12:	6a 00                	push   $0x0
  pushl $172
80105a14:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a19:	e9 39 f5 ff ff       	jmp    80104f57 <alltraps>

80105a1e <vector173>:
.globl vector173
vector173:
  pushl $0
80105a1e:	6a 00                	push   $0x0
  pushl $173
80105a20:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a25:	e9 2d f5 ff ff       	jmp    80104f57 <alltraps>

80105a2a <vector174>:
.globl vector174
vector174:
  pushl $0
80105a2a:	6a 00                	push   $0x0
  pushl $174
80105a2c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105a31:	e9 21 f5 ff ff       	jmp    80104f57 <alltraps>

80105a36 <vector175>:
.globl vector175
vector175:
  pushl $0
80105a36:	6a 00                	push   $0x0
  pushl $175
80105a38:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105a3d:	e9 15 f5 ff ff       	jmp    80104f57 <alltraps>

80105a42 <vector176>:
.globl vector176
vector176:
  pushl $0
80105a42:	6a 00                	push   $0x0
  pushl $176
80105a44:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105a49:	e9 09 f5 ff ff       	jmp    80104f57 <alltraps>

80105a4e <vector177>:
.globl vector177
vector177:
  pushl $0
80105a4e:	6a 00                	push   $0x0
  pushl $177
80105a50:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105a55:	e9 fd f4 ff ff       	jmp    80104f57 <alltraps>

80105a5a <vector178>:
.globl vector178
vector178:
  pushl $0
80105a5a:	6a 00                	push   $0x0
  pushl $178
80105a5c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a61:	e9 f1 f4 ff ff       	jmp    80104f57 <alltraps>

80105a66 <vector179>:
.globl vector179
vector179:
  pushl $0
80105a66:	6a 00                	push   $0x0
  pushl $179
80105a68:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a6d:	e9 e5 f4 ff ff       	jmp    80104f57 <alltraps>

80105a72 <vector180>:
.globl vector180
vector180:
  pushl $0
80105a72:	6a 00                	push   $0x0
  pushl $180
80105a74:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a79:	e9 d9 f4 ff ff       	jmp    80104f57 <alltraps>

80105a7e <vector181>:
.globl vector181
vector181:
  pushl $0
80105a7e:	6a 00                	push   $0x0
  pushl $181
80105a80:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a85:	e9 cd f4 ff ff       	jmp    80104f57 <alltraps>

80105a8a <vector182>:
.globl vector182
vector182:
  pushl $0
80105a8a:	6a 00                	push   $0x0
  pushl $182
80105a8c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a91:	e9 c1 f4 ff ff       	jmp    80104f57 <alltraps>

80105a96 <vector183>:
.globl vector183
vector183:
  pushl $0
80105a96:	6a 00                	push   $0x0
  pushl $183
80105a98:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a9d:	e9 b5 f4 ff ff       	jmp    80104f57 <alltraps>

80105aa2 <vector184>:
.globl vector184
vector184:
  pushl $0
80105aa2:	6a 00                	push   $0x0
  pushl $184
80105aa4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105aa9:	e9 a9 f4 ff ff       	jmp    80104f57 <alltraps>

80105aae <vector185>:
.globl vector185
vector185:
  pushl $0
80105aae:	6a 00                	push   $0x0
  pushl $185
80105ab0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105ab5:	e9 9d f4 ff ff       	jmp    80104f57 <alltraps>

80105aba <vector186>:
.globl vector186
vector186:
  pushl $0
80105aba:	6a 00                	push   $0x0
  pushl $186
80105abc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105ac1:	e9 91 f4 ff ff       	jmp    80104f57 <alltraps>

80105ac6 <vector187>:
.globl vector187
vector187:
  pushl $0
80105ac6:	6a 00                	push   $0x0
  pushl $187
80105ac8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105acd:	e9 85 f4 ff ff       	jmp    80104f57 <alltraps>

80105ad2 <vector188>:
.globl vector188
vector188:
  pushl $0
80105ad2:	6a 00                	push   $0x0
  pushl $188
80105ad4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105ad9:	e9 79 f4 ff ff       	jmp    80104f57 <alltraps>

80105ade <vector189>:
.globl vector189
vector189:
  pushl $0
80105ade:	6a 00                	push   $0x0
  pushl $189
80105ae0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105ae5:	e9 6d f4 ff ff       	jmp    80104f57 <alltraps>

80105aea <vector190>:
.globl vector190
vector190:
  pushl $0
80105aea:	6a 00                	push   $0x0
  pushl $190
80105aec:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105af1:	e9 61 f4 ff ff       	jmp    80104f57 <alltraps>

80105af6 <vector191>:
.globl vector191
vector191:
  pushl $0
80105af6:	6a 00                	push   $0x0
  pushl $191
80105af8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105afd:	e9 55 f4 ff ff       	jmp    80104f57 <alltraps>

80105b02 <vector192>:
.globl vector192
vector192:
  pushl $0
80105b02:	6a 00                	push   $0x0
  pushl $192
80105b04:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b09:	e9 49 f4 ff ff       	jmp    80104f57 <alltraps>

80105b0e <vector193>:
.globl vector193
vector193:
  pushl $0
80105b0e:	6a 00                	push   $0x0
  pushl $193
80105b10:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b15:	e9 3d f4 ff ff       	jmp    80104f57 <alltraps>

80105b1a <vector194>:
.globl vector194
vector194:
  pushl $0
80105b1a:	6a 00                	push   $0x0
  pushl $194
80105b1c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b21:	e9 31 f4 ff ff       	jmp    80104f57 <alltraps>

80105b26 <vector195>:
.globl vector195
vector195:
  pushl $0
80105b26:	6a 00                	push   $0x0
  pushl $195
80105b28:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105b2d:	e9 25 f4 ff ff       	jmp    80104f57 <alltraps>

80105b32 <vector196>:
.globl vector196
vector196:
  pushl $0
80105b32:	6a 00                	push   $0x0
  pushl $196
80105b34:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105b39:	e9 19 f4 ff ff       	jmp    80104f57 <alltraps>

80105b3e <vector197>:
.globl vector197
vector197:
  pushl $0
80105b3e:	6a 00                	push   $0x0
  pushl $197
80105b40:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105b45:	e9 0d f4 ff ff       	jmp    80104f57 <alltraps>

80105b4a <vector198>:
.globl vector198
vector198:
  pushl $0
80105b4a:	6a 00                	push   $0x0
  pushl $198
80105b4c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105b51:	e9 01 f4 ff ff       	jmp    80104f57 <alltraps>

80105b56 <vector199>:
.globl vector199
vector199:
  pushl $0
80105b56:	6a 00                	push   $0x0
  pushl $199
80105b58:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b5d:	e9 f5 f3 ff ff       	jmp    80104f57 <alltraps>

80105b62 <vector200>:
.globl vector200
vector200:
  pushl $0
80105b62:	6a 00                	push   $0x0
  pushl $200
80105b64:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b69:	e9 e9 f3 ff ff       	jmp    80104f57 <alltraps>

80105b6e <vector201>:
.globl vector201
vector201:
  pushl $0
80105b6e:	6a 00                	push   $0x0
  pushl $201
80105b70:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b75:	e9 dd f3 ff ff       	jmp    80104f57 <alltraps>

80105b7a <vector202>:
.globl vector202
vector202:
  pushl $0
80105b7a:	6a 00                	push   $0x0
  pushl $202
80105b7c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b81:	e9 d1 f3 ff ff       	jmp    80104f57 <alltraps>

80105b86 <vector203>:
.globl vector203
vector203:
  pushl $0
80105b86:	6a 00                	push   $0x0
  pushl $203
80105b88:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b8d:	e9 c5 f3 ff ff       	jmp    80104f57 <alltraps>

80105b92 <vector204>:
.globl vector204
vector204:
  pushl $0
80105b92:	6a 00                	push   $0x0
  pushl $204
80105b94:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b99:	e9 b9 f3 ff ff       	jmp    80104f57 <alltraps>

80105b9e <vector205>:
.globl vector205
vector205:
  pushl $0
80105b9e:	6a 00                	push   $0x0
  pushl $205
80105ba0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105ba5:	e9 ad f3 ff ff       	jmp    80104f57 <alltraps>

80105baa <vector206>:
.globl vector206
vector206:
  pushl $0
80105baa:	6a 00                	push   $0x0
  pushl $206
80105bac:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105bb1:	e9 a1 f3 ff ff       	jmp    80104f57 <alltraps>

80105bb6 <vector207>:
.globl vector207
vector207:
  pushl $0
80105bb6:	6a 00                	push   $0x0
  pushl $207
80105bb8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105bbd:	e9 95 f3 ff ff       	jmp    80104f57 <alltraps>

80105bc2 <vector208>:
.globl vector208
vector208:
  pushl $0
80105bc2:	6a 00                	push   $0x0
  pushl $208
80105bc4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105bc9:	e9 89 f3 ff ff       	jmp    80104f57 <alltraps>

80105bce <vector209>:
.globl vector209
vector209:
  pushl $0
80105bce:	6a 00                	push   $0x0
  pushl $209
80105bd0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105bd5:	e9 7d f3 ff ff       	jmp    80104f57 <alltraps>

80105bda <vector210>:
.globl vector210
vector210:
  pushl $0
80105bda:	6a 00                	push   $0x0
  pushl $210
80105bdc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105be1:	e9 71 f3 ff ff       	jmp    80104f57 <alltraps>

80105be6 <vector211>:
.globl vector211
vector211:
  pushl $0
80105be6:	6a 00                	push   $0x0
  pushl $211
80105be8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105bed:	e9 65 f3 ff ff       	jmp    80104f57 <alltraps>

80105bf2 <vector212>:
.globl vector212
vector212:
  pushl $0
80105bf2:	6a 00                	push   $0x0
  pushl $212
80105bf4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105bf9:	e9 59 f3 ff ff       	jmp    80104f57 <alltraps>

80105bfe <vector213>:
.globl vector213
vector213:
  pushl $0
80105bfe:	6a 00                	push   $0x0
  pushl $213
80105c00:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c05:	e9 4d f3 ff ff       	jmp    80104f57 <alltraps>

80105c0a <vector214>:
.globl vector214
vector214:
  pushl $0
80105c0a:	6a 00                	push   $0x0
  pushl $214
80105c0c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c11:	e9 41 f3 ff ff       	jmp    80104f57 <alltraps>

80105c16 <vector215>:
.globl vector215
vector215:
  pushl $0
80105c16:	6a 00                	push   $0x0
  pushl $215
80105c18:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c1d:	e9 35 f3 ff ff       	jmp    80104f57 <alltraps>

80105c22 <vector216>:
.globl vector216
vector216:
  pushl $0
80105c22:	6a 00                	push   $0x0
  pushl $216
80105c24:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c29:	e9 29 f3 ff ff       	jmp    80104f57 <alltraps>

80105c2e <vector217>:
.globl vector217
vector217:
  pushl $0
80105c2e:	6a 00                	push   $0x0
  pushl $217
80105c30:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105c35:	e9 1d f3 ff ff       	jmp    80104f57 <alltraps>

80105c3a <vector218>:
.globl vector218
vector218:
  pushl $0
80105c3a:	6a 00                	push   $0x0
  pushl $218
80105c3c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105c41:	e9 11 f3 ff ff       	jmp    80104f57 <alltraps>

80105c46 <vector219>:
.globl vector219
vector219:
  pushl $0
80105c46:	6a 00                	push   $0x0
  pushl $219
80105c48:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105c4d:	e9 05 f3 ff ff       	jmp    80104f57 <alltraps>

80105c52 <vector220>:
.globl vector220
vector220:
  pushl $0
80105c52:	6a 00                	push   $0x0
  pushl $220
80105c54:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c59:	e9 f9 f2 ff ff       	jmp    80104f57 <alltraps>

80105c5e <vector221>:
.globl vector221
vector221:
  pushl $0
80105c5e:	6a 00                	push   $0x0
  pushl $221
80105c60:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c65:	e9 ed f2 ff ff       	jmp    80104f57 <alltraps>

80105c6a <vector222>:
.globl vector222
vector222:
  pushl $0
80105c6a:	6a 00                	push   $0x0
  pushl $222
80105c6c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c71:	e9 e1 f2 ff ff       	jmp    80104f57 <alltraps>

80105c76 <vector223>:
.globl vector223
vector223:
  pushl $0
80105c76:	6a 00                	push   $0x0
  pushl $223
80105c78:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c7d:	e9 d5 f2 ff ff       	jmp    80104f57 <alltraps>

80105c82 <vector224>:
.globl vector224
vector224:
  pushl $0
80105c82:	6a 00                	push   $0x0
  pushl $224
80105c84:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c89:	e9 c9 f2 ff ff       	jmp    80104f57 <alltraps>

80105c8e <vector225>:
.globl vector225
vector225:
  pushl $0
80105c8e:	6a 00                	push   $0x0
  pushl $225
80105c90:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c95:	e9 bd f2 ff ff       	jmp    80104f57 <alltraps>

80105c9a <vector226>:
.globl vector226
vector226:
  pushl $0
80105c9a:	6a 00                	push   $0x0
  pushl $226
80105c9c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105ca1:	e9 b1 f2 ff ff       	jmp    80104f57 <alltraps>

80105ca6 <vector227>:
.globl vector227
vector227:
  pushl $0
80105ca6:	6a 00                	push   $0x0
  pushl $227
80105ca8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105cad:	e9 a5 f2 ff ff       	jmp    80104f57 <alltraps>

80105cb2 <vector228>:
.globl vector228
vector228:
  pushl $0
80105cb2:	6a 00                	push   $0x0
  pushl $228
80105cb4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105cb9:	e9 99 f2 ff ff       	jmp    80104f57 <alltraps>

80105cbe <vector229>:
.globl vector229
vector229:
  pushl $0
80105cbe:	6a 00                	push   $0x0
  pushl $229
80105cc0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105cc5:	e9 8d f2 ff ff       	jmp    80104f57 <alltraps>

80105cca <vector230>:
.globl vector230
vector230:
  pushl $0
80105cca:	6a 00                	push   $0x0
  pushl $230
80105ccc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105cd1:	e9 81 f2 ff ff       	jmp    80104f57 <alltraps>

80105cd6 <vector231>:
.globl vector231
vector231:
  pushl $0
80105cd6:	6a 00                	push   $0x0
  pushl $231
80105cd8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105cdd:	e9 75 f2 ff ff       	jmp    80104f57 <alltraps>

80105ce2 <vector232>:
.globl vector232
vector232:
  pushl $0
80105ce2:	6a 00                	push   $0x0
  pushl $232
80105ce4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105ce9:	e9 69 f2 ff ff       	jmp    80104f57 <alltraps>

80105cee <vector233>:
.globl vector233
vector233:
  pushl $0
80105cee:	6a 00                	push   $0x0
  pushl $233
80105cf0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105cf5:	e9 5d f2 ff ff       	jmp    80104f57 <alltraps>

80105cfa <vector234>:
.globl vector234
vector234:
  pushl $0
80105cfa:	6a 00                	push   $0x0
  pushl $234
80105cfc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d01:	e9 51 f2 ff ff       	jmp    80104f57 <alltraps>

80105d06 <vector235>:
.globl vector235
vector235:
  pushl $0
80105d06:	6a 00                	push   $0x0
  pushl $235
80105d08:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d0d:	e9 45 f2 ff ff       	jmp    80104f57 <alltraps>

80105d12 <vector236>:
.globl vector236
vector236:
  pushl $0
80105d12:	6a 00                	push   $0x0
  pushl $236
80105d14:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d19:	e9 39 f2 ff ff       	jmp    80104f57 <alltraps>

80105d1e <vector237>:
.globl vector237
vector237:
  pushl $0
80105d1e:	6a 00                	push   $0x0
  pushl $237
80105d20:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d25:	e9 2d f2 ff ff       	jmp    80104f57 <alltraps>

80105d2a <vector238>:
.globl vector238
vector238:
  pushl $0
80105d2a:	6a 00                	push   $0x0
  pushl $238
80105d2c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105d31:	e9 21 f2 ff ff       	jmp    80104f57 <alltraps>

80105d36 <vector239>:
.globl vector239
vector239:
  pushl $0
80105d36:	6a 00                	push   $0x0
  pushl $239
80105d38:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105d3d:	e9 15 f2 ff ff       	jmp    80104f57 <alltraps>

80105d42 <vector240>:
.globl vector240
vector240:
  pushl $0
80105d42:	6a 00                	push   $0x0
  pushl $240
80105d44:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105d49:	e9 09 f2 ff ff       	jmp    80104f57 <alltraps>

80105d4e <vector241>:
.globl vector241
vector241:
  pushl $0
80105d4e:	6a 00                	push   $0x0
  pushl $241
80105d50:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105d55:	e9 fd f1 ff ff       	jmp    80104f57 <alltraps>

80105d5a <vector242>:
.globl vector242
vector242:
  pushl $0
80105d5a:	6a 00                	push   $0x0
  pushl $242
80105d5c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d61:	e9 f1 f1 ff ff       	jmp    80104f57 <alltraps>

80105d66 <vector243>:
.globl vector243
vector243:
  pushl $0
80105d66:	6a 00                	push   $0x0
  pushl $243
80105d68:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d6d:	e9 e5 f1 ff ff       	jmp    80104f57 <alltraps>

80105d72 <vector244>:
.globl vector244
vector244:
  pushl $0
80105d72:	6a 00                	push   $0x0
  pushl $244
80105d74:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d79:	e9 d9 f1 ff ff       	jmp    80104f57 <alltraps>

80105d7e <vector245>:
.globl vector245
vector245:
  pushl $0
80105d7e:	6a 00                	push   $0x0
  pushl $245
80105d80:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d85:	e9 cd f1 ff ff       	jmp    80104f57 <alltraps>

80105d8a <vector246>:
.globl vector246
vector246:
  pushl $0
80105d8a:	6a 00                	push   $0x0
  pushl $246
80105d8c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d91:	e9 c1 f1 ff ff       	jmp    80104f57 <alltraps>

80105d96 <vector247>:
.globl vector247
vector247:
  pushl $0
80105d96:	6a 00                	push   $0x0
  pushl $247
80105d98:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d9d:	e9 b5 f1 ff ff       	jmp    80104f57 <alltraps>

80105da2 <vector248>:
.globl vector248
vector248:
  pushl $0
80105da2:	6a 00                	push   $0x0
  pushl $248
80105da4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105da9:	e9 a9 f1 ff ff       	jmp    80104f57 <alltraps>

80105dae <vector249>:
.globl vector249
vector249:
  pushl $0
80105dae:	6a 00                	push   $0x0
  pushl $249
80105db0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105db5:	e9 9d f1 ff ff       	jmp    80104f57 <alltraps>

80105dba <vector250>:
.globl vector250
vector250:
  pushl $0
80105dba:	6a 00                	push   $0x0
  pushl $250
80105dbc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105dc1:	e9 91 f1 ff ff       	jmp    80104f57 <alltraps>

80105dc6 <vector251>:
.globl vector251
vector251:
  pushl $0
80105dc6:	6a 00                	push   $0x0
  pushl $251
80105dc8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105dcd:	e9 85 f1 ff ff       	jmp    80104f57 <alltraps>

80105dd2 <vector252>:
.globl vector252
vector252:
  pushl $0
80105dd2:	6a 00                	push   $0x0
  pushl $252
80105dd4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105dd9:	e9 79 f1 ff ff       	jmp    80104f57 <alltraps>

80105dde <vector253>:
.globl vector253
vector253:
  pushl $0
80105dde:	6a 00                	push   $0x0
  pushl $253
80105de0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105de5:	e9 6d f1 ff ff       	jmp    80104f57 <alltraps>

80105dea <vector254>:
.globl vector254
vector254:
  pushl $0
80105dea:	6a 00                	push   $0x0
  pushl $254
80105dec:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105df1:	e9 61 f1 ff ff       	jmp    80104f57 <alltraps>

80105df6 <vector255>:
.globl vector255
vector255:
  pushl $0
80105df6:	6a 00                	push   $0x0
  pushl $255
80105df8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105dfd:	e9 55 f1 ff ff       	jmp    80104f57 <alltraps>

80105e02 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e02:	55                   	push   %ebp
80105e03:	89 e5                	mov    %esp,%ebp
80105e05:	57                   	push   %edi
80105e06:	56                   	push   %esi
80105e07:	53                   	push   %ebx
80105e08:	83 ec 0c             	sub    $0xc,%esp
80105e0b:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e0d:	c1 ea 16             	shr    $0x16,%edx
80105e10:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105e13:	8b 1f                	mov    (%edi),%ebx
80105e15:	f6 c3 01             	test   $0x1,%bl
80105e18:	74 37                	je     80105e51 <walkpgdir+0x4f>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105e1a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
80105e20:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80105e26:	77 1c                	ja     80105e44 <walkpgdir+0x42>
    return (char*)a + KERNBASE;
80105e28:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e2e:	c1 ee 0c             	shr    $0xc,%esi
80105e31:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105e37:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105e3a:	89 d8                	mov    %ebx,%eax
80105e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e3f:	5b                   	pop    %ebx
80105e40:	5e                   	pop    %esi
80105e41:	5f                   	pop    %edi
80105e42:	5d                   	pop    %ebp
80105e43:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105e44:	83 ec 0c             	sub    $0xc,%esp
80105e47:	68 38 6d 10 80       	push   $0x80106d38
80105e4c:	e8 f7 a4 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105e51:	85 c9                	test   %ecx,%ecx
80105e53:	74 40                	je     80105e95 <walkpgdir+0x93>
80105e55:	e8 75 c2 ff ff       	call   801020cf <kalloc>
80105e5a:	89 c3                	mov    %eax,%ebx
80105e5c:	85 c0                	test   %eax,%eax
80105e5e:	74 da                	je     80105e3a <walkpgdir+0x38>
    memset(pgtab, 0, PGSIZE);
80105e60:	83 ec 04             	sub    $0x4,%esp
80105e63:	68 00 10 00 00       	push   $0x1000
80105e68:	6a 00                	push   $0x0
80105e6a:	50                   	push   %eax
80105e6b:	e8 88 df ff ff       	call   80103df8 <memset>
    if (a < (void*) KERNBASE)
80105e70:	83 c4 10             	add    $0x10,%esp
80105e73:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80105e79:	76 0d                	jbe    80105e88 <walkpgdir+0x86>
    return (uint)a - KERNBASE;
80105e7b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e81:	83 c8 07             	or     $0x7,%eax
80105e84:	89 07                	mov    %eax,(%edi)
80105e86:	eb a6                	jmp    80105e2e <walkpgdir+0x2c>
        panic("V2P on address < KERNBASE "
80105e88:	83 ec 0c             	sub    $0xc,%esp
80105e8b:	68 08 6a 10 80       	push   $0x80106a08
80105e90:	e8 b3 a4 ff ff       	call   80100348 <panic>
      return 0;
80105e95:	bb 00 00 00 00       	mov    $0x0,%ebx
80105e9a:	eb 9e                	jmp    80105e3a <walkpgdir+0x38>

80105e9c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105e9c:	55                   	push   %ebp
80105e9d:	89 e5                	mov    %esp,%ebp
80105e9f:	57                   	push   %edi
80105ea0:	56                   	push   %esi
80105ea1:	53                   	push   %ebx
80105ea2:	83 ec 1c             	sub    $0x1c,%esp
80105ea5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ea8:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105eab:	89 d3                	mov    %edx,%ebx
80105ead:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105eb3:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105eb7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ebd:	b9 01 00 00 00       	mov    $0x1,%ecx
80105ec2:	89 da                	mov    %ebx,%edx
80105ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ec7:	e8 36 ff ff ff       	call   80105e02 <walkpgdir>
80105ecc:	85 c0                	test   %eax,%eax
80105ece:	74 2e                	je     80105efe <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105ed0:	f6 00 01             	testb  $0x1,(%eax)
80105ed3:	75 1c                	jne    80105ef1 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105ed5:	89 f2                	mov    %esi,%edx
80105ed7:	0b 55 0c             	or     0xc(%ebp),%edx
80105eda:	83 ca 01             	or     $0x1,%edx
80105edd:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105edf:	39 fb                	cmp    %edi,%ebx
80105ee1:	74 28                	je     80105f0b <mappages+0x6f>
      break;
    a += PGSIZE;
80105ee3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105ee9:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105eef:	eb cc                	jmp    80105ebd <mappages+0x21>
      panic("remap");
80105ef1:	83 ec 0c             	sub    $0xc,%esp
80105ef4:	68 40 71 10 80       	push   $0x80107140
80105ef9:	e8 4a a4 ff ff       	call   80100348 <panic>
      return -1;
80105efe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f06:	5b                   	pop    %ebx
80105f07:	5e                   	pop    %esi
80105f08:	5f                   	pop    %edi
80105f09:	5d                   	pop    %ebp
80105f0a:	c3                   	ret    
  return 0;
80105f0b:	b8 00 00 00 00       	mov    $0x0,%eax
80105f10:	eb f1                	jmp    80105f03 <mappages+0x67>

80105f12 <seginit>:
{
80105f12:	55                   	push   %ebp
80105f13:	89 e5                	mov    %esp,%ebp
80105f15:	53                   	push   %ebx
80105f16:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105f19:	e8 6a d3 ff ff       	call   80103288 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f1e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f24:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
80105f2b:	ff ff 
80105f2d:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80105f34:	00 00 
80105f36:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
80105f3d:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
80105f44:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f47:	83 c9 1a             	or     $0x1a,%ecx
80105f4a:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f4d:	83 c9 80             	or     $0xffffff80,%ecx
80105f50:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
80105f56:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
80105f5d:	83 c9 0f             	or     $0xf,%ecx
80105f60:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f63:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f66:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
80105f6c:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105f73:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
80105f7a:	ff ff 
80105f7c:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
80105f83:	00 00 
80105f85:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80105f8c:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
80105f93:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f96:	83 c9 12             	or     $0x12,%ecx
80105f99:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f9c:	83 c9 80             	or     $0xffffff80,%ecx
80105f9f:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80105fa5:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80105fac:	83 c9 0f             	or     $0xf,%ecx
80105faf:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fb2:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fb5:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
80105fbb:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105fc2:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80105fc9:	ff ff 
80105fcb:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
80105fd2:	00 00 
80105fd4:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
80105fdb:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
80105fe2:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
80105fe9:	83 c9 0f             	or     $0xf,%ecx
80105fec:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fef:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ff2:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
80105ff8:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105fff:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
80106006:	ff ff 
80106008:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
8010600f:	00 00 
80106011:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
80106018:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
8010601f:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
80106026:	83 c9 0f             	or     $0xf,%ecx
80106029:	83 e1 cf             	and    $0xffffffcf,%ecx
8010602c:	83 c9 c0             	or     $0xffffffc0,%ecx
8010602f:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
80106035:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010603c:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
80106041:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106047:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
8010604b:	c1 e8 10             	shr    $0x10,%eax
8010604e:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106052:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106055:	0f 01 10             	lgdtl  (%eax)
}
80106058:	83 c4 14             	add    $0x14,%esp
8010605b:	5b                   	pop    %ebx
8010605c:	5d                   	pop    %ebp
8010605d:	c3                   	ret    

8010605e <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010605e:	a1 a4 56 11 80       	mov    0x801156a4,%eax
    if (a < (void*) KERNBASE)
80106063:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106068:	76 09                	jbe    80106073 <switchkvm+0x15>
    return (uint)a - KERNBASE;
8010606a:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010606f:	0f 22 d8             	mov    %eax,%cr3
80106072:	c3                   	ret    
{
80106073:	55                   	push   %ebp
80106074:	89 e5                	mov    %esp,%ebp
80106076:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
80106079:	68 08 6a 10 80       	push   $0x80106a08
8010607e:	e8 c5 a2 ff ff       	call   80100348 <panic>

80106083 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106083:	55                   	push   %ebp
80106084:	89 e5                	mov    %esp,%ebp
80106086:	57                   	push   %edi
80106087:	56                   	push   %esi
80106088:	53                   	push   %ebx
80106089:	83 ec 1c             	sub    $0x1c,%esp
8010608c:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
8010608f:	85 f6                	test   %esi,%esi
80106091:	0f 84 e4 00 00 00    	je     8010617b <switchuvm+0xf8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106097:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
8010609b:	0f 84 e7 00 00 00    	je     80106188 <switchuvm+0x105>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801060a1:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801060a5:	0f 84 ea 00 00 00    	je     80106195 <switchuvm+0x112>
    panic("switchuvm: no pgdir");

  pushcli();
801060ab:	e8 bf db ff ff       	call   80103c6f <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801060b0:	e8 77 d1 ff ff       	call   8010322c <mycpu>
801060b5:	89 c3                	mov    %eax,%ebx
801060b7:	e8 70 d1 ff ff       	call   8010322c <mycpu>
801060bc:	8d 78 08             	lea    0x8(%eax),%edi
801060bf:	e8 68 d1 ff ff       	call   8010322c <mycpu>
801060c4:	83 c0 08             	add    $0x8,%eax
801060c7:	c1 e8 10             	shr    $0x10,%eax
801060ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060cd:	e8 5a d1 ff ff       	call   8010322c <mycpu>
801060d2:	83 c0 08             	add    $0x8,%eax
801060d5:	c1 e8 18             	shr    $0x18,%eax
801060d8:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801060df:	67 00 
801060e1:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801060e8:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
801060ec:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801060f2:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
801060f9:	83 e2 f0             	and    $0xfffffff0,%edx
801060fc:	83 ca 19             	or     $0x19,%edx
801060ff:	83 e2 9f             	and    $0xffffff9f,%edx
80106102:	83 ca 80             	or     $0xffffff80,%edx
80106105:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010610b:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106112:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106118:	e8 0f d1 ff ff       	call   8010322c <mycpu>
8010611d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106124:	83 e2 ef             	and    $0xffffffef,%edx
80106127:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010612d:	e8 fa d0 ff ff       	call   8010322c <mycpu>
80106132:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106138:	8b 5e 08             	mov    0x8(%esi),%ebx
8010613b:	e8 ec d0 ff ff       	call   8010322c <mycpu>
80106140:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106146:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106149:	e8 de d0 ff ff       	call   8010322c <mycpu>
8010614e:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106154:	b8 28 00 00 00       	mov    $0x28,%eax
80106159:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010615c:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
8010615f:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106164:	76 3c                	jbe    801061a2 <switchuvm+0x11f>
    return (uint)a - KERNBASE;
80106166:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010616b:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010616e:	e8 39 db ff ff       	call   80103cac <popcli>
}
80106173:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106176:	5b                   	pop    %ebx
80106177:	5e                   	pop    %esi
80106178:	5f                   	pop    %edi
80106179:	5d                   	pop    %ebp
8010617a:	c3                   	ret    
    panic("switchuvm: no process");
8010617b:	83 ec 0c             	sub    $0xc,%esp
8010617e:	68 46 71 10 80       	push   $0x80107146
80106183:	e8 c0 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106188:	83 ec 0c             	sub    $0xc,%esp
8010618b:	68 5c 71 10 80       	push   $0x8010715c
80106190:	e8 b3 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106195:	83 ec 0c             	sub    $0xc,%esp
80106198:	68 71 71 10 80       	push   $0x80107171
8010619d:	e8 a6 a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801061a2:	83 ec 0c             	sub    $0xc,%esp
801061a5:	68 08 6a 10 80       	push   $0x80106a08
801061aa:	e8 99 a1 ff ff       	call   80100348 <panic>

801061af <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061af:	55                   	push   %ebp
801061b0:	89 e5                	mov    %esp,%ebp
801061b2:	56                   	push   %esi
801061b3:	53                   	push   %ebx
801061b4:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061b7:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061bd:	77 57                	ja     80106216 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
801061bf:	e8 0b bf ff ff       	call   801020cf <kalloc>
801061c4:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061c6:	83 ec 04             	sub    $0x4,%esp
801061c9:	68 00 10 00 00       	push   $0x1000
801061ce:	6a 00                	push   $0x0
801061d0:	50                   	push   %eax
801061d1:	e8 22 dc ff ff       	call   80103df8 <memset>
    if (a < (void*) KERNBASE)
801061d6:	83 c4 10             	add    $0x10,%esp
801061d9:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801061df:	76 42                	jbe    80106223 <inituvm+0x74>
    return (uint)a - KERNBASE;
801061e1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801061e7:	83 ec 08             	sub    $0x8,%esp
801061ea:	6a 06                	push   $0x6
801061ec:	50                   	push   %eax
801061ed:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061f2:	ba 00 00 00 00       	mov    $0x0,%edx
801061f7:	8b 45 08             	mov    0x8(%ebp),%eax
801061fa:	e8 9d fc ff ff       	call   80105e9c <mappages>
  memmove(mem, init, sz);
801061ff:	83 c4 0c             	add    $0xc,%esp
80106202:	56                   	push   %esi
80106203:	ff 75 0c             	pushl  0xc(%ebp)
80106206:	53                   	push   %ebx
80106207:	e8 67 dc ff ff       	call   80103e73 <memmove>
}
8010620c:	83 c4 10             	add    $0x10,%esp
8010620f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106212:	5b                   	pop    %ebx
80106213:	5e                   	pop    %esi
80106214:	5d                   	pop    %ebp
80106215:	c3                   	ret    
    panic("inituvm: more than a page");
80106216:	83 ec 0c             	sub    $0xc,%esp
80106219:	68 85 71 10 80       	push   $0x80107185
8010621e:	e8 25 a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106223:	83 ec 0c             	sub    $0xc,%esp
80106226:	68 08 6a 10 80       	push   $0x80106a08
8010622b:	e8 18 a1 ff ff       	call   80100348 <panic>

80106230 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106230:	55                   	push   %ebp
80106231:	89 e5                	mov    %esp,%ebp
80106233:	57                   	push   %edi
80106234:	56                   	push   %esi
80106235:	53                   	push   %ebx
80106236:	83 ec 0c             	sub    $0xc,%esp
80106239:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010623c:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106243:	75 07                	jne    8010624c <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106245:	bb 00 00 00 00       	mov    $0x0,%ebx
8010624a:	eb 43                	jmp    8010628f <loaduvm+0x5f>
    panic("loaduvm: addr must be page aligned");
8010624c:	83 ec 0c             	sub    $0xc,%esp
8010624f:	68 40 72 10 80       	push   $0x80107240
80106254:	e8 ef a0 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106259:	83 ec 0c             	sub    $0xc,%esp
8010625c:	68 9f 71 10 80       	push   $0x8010719f
80106261:	e8 e2 a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106266:	89 da                	mov    %ebx,%edx
80106268:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
8010626b:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106270:	77 51                	ja     801062c3 <loaduvm+0x93>
    return (char*)a + KERNBASE;
80106272:	05 00 00 00 80       	add    $0x80000000,%eax
80106277:	56                   	push   %esi
80106278:	52                   	push   %edx
80106279:	50                   	push   %eax
8010627a:	ff 75 10             	pushl  0x10(%ebp)
8010627d:	e8 df b4 ff ff       	call   80101761 <readi>
80106282:	83 c4 10             	add    $0x10,%esp
80106285:	39 f0                	cmp    %esi,%eax
80106287:	75 54                	jne    801062dd <loaduvm+0xad>
  for(i = 0; i < sz; i += PGSIZE){
80106289:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010628f:	39 fb                	cmp    %edi,%ebx
80106291:	73 3d                	jae    801062d0 <loaduvm+0xa0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106293:	89 da                	mov    %ebx,%edx
80106295:	03 55 0c             	add    0xc(%ebp),%edx
80106298:	b9 00 00 00 00       	mov    $0x0,%ecx
8010629d:	8b 45 08             	mov    0x8(%ebp),%eax
801062a0:	e8 5d fb ff ff       	call   80105e02 <walkpgdir>
801062a5:	85 c0                	test   %eax,%eax
801062a7:	74 b0                	je     80106259 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801062a9:	8b 00                	mov    (%eax),%eax
801062ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062b0:	89 fe                	mov    %edi,%esi
801062b2:	29 de                	sub    %ebx,%esi
801062b4:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062ba:	76 aa                	jbe    80106266 <loaduvm+0x36>
      n = PGSIZE;
801062bc:	be 00 10 00 00       	mov    $0x1000,%esi
801062c1:	eb a3                	jmp    80106266 <loaduvm+0x36>
        panic("P2V on address > KERNBASE");
801062c3:	83 ec 0c             	sub    $0xc,%esp
801062c6:	68 38 6d 10 80       	push   $0x80106d38
801062cb:	e8 78 a0 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
801062d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062d8:	5b                   	pop    %ebx
801062d9:	5e                   	pop    %esi
801062da:	5f                   	pop    %edi
801062db:	5d                   	pop    %ebp
801062dc:	c3                   	ret    
      return -1;
801062dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e2:	eb f1                	jmp    801062d5 <loaduvm+0xa5>

801062e4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062e4:	55                   	push   %ebp
801062e5:	89 e5                	mov    %esp,%ebp
801062e7:	57                   	push   %edi
801062e8:	56                   	push   %esi
801062e9:	53                   	push   %ebx
801062ea:	83 ec 0c             	sub    $0xc,%esp
801062ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801062f0:	39 7d 10             	cmp    %edi,0x10(%ebp)
801062f3:	73 11                	jae    80106306 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801062f5:	8b 45 10             	mov    0x10(%ebp),%eax
801062f8:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062fe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106304:	eb 19                	jmp    8010631f <deallocuvm+0x3b>
    return oldsz;
80106306:	89 f8                	mov    %edi,%eax
80106308:	eb 78                	jmp    80106382 <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010630a:	c1 eb 16             	shr    $0x16,%ebx
8010630d:	83 c3 01             	add    $0x1,%ebx
80106310:	c1 e3 16             	shl    $0x16,%ebx
80106313:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106319:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010631f:	39 fb                	cmp    %edi,%ebx
80106321:	73 5c                	jae    8010637f <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106323:	b9 00 00 00 00       	mov    $0x0,%ecx
80106328:	89 da                	mov    %ebx,%edx
8010632a:	8b 45 08             	mov    0x8(%ebp),%eax
8010632d:	e8 d0 fa ff ff       	call   80105e02 <walkpgdir>
80106332:	89 c6                	mov    %eax,%esi
    if(!pte)
80106334:	85 c0                	test   %eax,%eax
80106336:	74 d2                	je     8010630a <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106338:	8b 00                	mov    (%eax),%eax
8010633a:	a8 01                	test   $0x1,%al
8010633c:	74 db                	je     80106319 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010633e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106343:	74 20                	je     80106365 <deallocuvm+0x81>
    if (a > KERNBASE)
80106345:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010634a:	77 26                	ja     80106372 <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
8010634c:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106351:	83 ec 0c             	sub    $0xc,%esp
80106354:	50                   	push   %eax
80106355:	e8 38 bc ff ff       	call   80101f92 <kfree>
      *pte = 0;
8010635a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106360:	83 c4 10             	add    $0x10,%esp
80106363:	eb b4                	jmp    80106319 <deallocuvm+0x35>
        panic("kfree");
80106365:	83 ec 0c             	sub    $0xc,%esp
80106368:	68 96 6a 10 80       	push   $0x80106a96
8010636d:	e8 d6 9f ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106372:	83 ec 0c             	sub    $0xc,%esp
80106375:	68 38 6d 10 80       	push   $0x80106d38
8010637a:	e8 c9 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
8010637f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106382:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106385:	5b                   	pop    %ebx
80106386:	5e                   	pop    %esi
80106387:	5f                   	pop    %edi
80106388:	5d                   	pop    %ebp
80106389:	c3                   	ret    

8010638a <allocuvm>:
{
8010638a:	55                   	push   %ebp
8010638b:	89 e5                	mov    %esp,%ebp
8010638d:	57                   	push   %edi
8010638e:	56                   	push   %esi
8010638f:	53                   	push   %ebx
80106390:	83 ec 1c             	sub    $0x1c,%esp
80106393:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106396:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106399:	85 ff                	test   %edi,%edi
8010639b:	0f 88 d9 00 00 00    	js     8010647a <allocuvm+0xf0>
  if(newsz < oldsz)
801063a1:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063a4:	72 67                	jb     8010640d <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
801063a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801063a9:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801063af:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801063b5:	39 fe                	cmp    %edi,%esi
801063b7:	0f 83 c4 00 00 00    	jae    80106481 <allocuvm+0xf7>
    mem = kalloc();
801063bd:	e8 0d bd ff ff       	call   801020cf <kalloc>
801063c2:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801063c4:	85 c0                	test   %eax,%eax
801063c6:	74 4d                	je     80106415 <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
801063c8:	83 ec 04             	sub    $0x4,%esp
801063cb:	68 00 10 00 00       	push   $0x1000
801063d0:	6a 00                	push   $0x0
801063d2:	50                   	push   %eax
801063d3:	e8 20 da ff ff       	call   80103df8 <memset>
    if (a < (void*) KERNBASE)
801063d8:	83 c4 10             	add    $0x10,%esp
801063db:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801063e1:	76 5a                	jbe    8010643d <allocuvm+0xb3>
    return (uint)a - KERNBASE;
801063e3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063e9:	83 ec 08             	sub    $0x8,%esp
801063ec:	6a 06                	push   $0x6
801063ee:	50                   	push   %eax
801063ef:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063f4:	89 f2                	mov    %esi,%edx
801063f6:	8b 45 08             	mov    0x8(%ebp),%eax
801063f9:	e8 9e fa ff ff       	call   80105e9c <mappages>
801063fe:	83 c4 10             	add    $0x10,%esp
80106401:	85 c0                	test   %eax,%eax
80106403:	78 45                	js     8010644a <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80106405:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010640b:	eb a8                	jmp    801063b5 <allocuvm+0x2b>
    return oldsz;
8010640d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106413:	eb 6c                	jmp    80106481 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
80106415:	83 ec 0c             	sub    $0xc,%esp
80106418:	68 bd 71 10 80       	push   $0x801071bd
8010641d:	e8 e9 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106422:	83 c4 0c             	add    $0xc,%esp
80106425:	ff 75 0c             	pushl  0xc(%ebp)
80106428:	57                   	push   %edi
80106429:	ff 75 08             	pushl  0x8(%ebp)
8010642c:	e8 b3 fe ff ff       	call   801062e4 <deallocuvm>
      return 0;
80106431:	83 c4 10             	add    $0x10,%esp
80106434:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010643b:	eb 44                	jmp    80106481 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
8010643d:	83 ec 0c             	sub    $0xc,%esp
80106440:	68 08 6a 10 80       	push   $0x80106a08
80106445:	e8 fe 9e ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
8010644a:	83 ec 0c             	sub    $0xc,%esp
8010644d:	68 d5 71 10 80       	push   $0x801071d5
80106452:	e8 b4 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106457:	83 c4 0c             	add    $0xc,%esp
8010645a:	ff 75 0c             	pushl  0xc(%ebp)
8010645d:	57                   	push   %edi
8010645e:	ff 75 08             	pushl  0x8(%ebp)
80106461:	e8 7e fe ff ff       	call   801062e4 <deallocuvm>
      kfree(mem);
80106466:	89 1c 24             	mov    %ebx,(%esp)
80106469:	e8 24 bb ff ff       	call   80101f92 <kfree>
      return 0;
8010646e:	83 c4 10             	add    $0x10,%esp
80106471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106478:	eb 07                	jmp    80106481 <allocuvm+0xf7>
    return 0;
8010647a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106484:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106487:	5b                   	pop    %ebx
80106488:	5e                   	pop    %esi
80106489:	5f                   	pop    %edi
8010648a:	5d                   	pop    %ebp
8010648b:	c3                   	ret    

8010648c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010648c:	55                   	push   %ebp
8010648d:	89 e5                	mov    %esp,%ebp
8010648f:	56                   	push   %esi
80106490:	53                   	push   %ebx
80106491:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106494:	85 f6                	test   %esi,%esi
80106496:	74 1a                	je     801064b2 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106498:	83 ec 04             	sub    $0x4,%esp
8010649b:	6a 00                	push   $0x0
8010649d:	68 00 00 00 80       	push   $0x80000000
801064a2:	56                   	push   %esi
801064a3:	e8 3c fe ff ff       	call   801062e4 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801064a8:	83 c4 10             	add    $0x10,%esp
801064ab:	bb 00 00 00 00       	mov    $0x0,%ebx
801064b0:	eb 1d                	jmp    801064cf <freevm+0x43>
    panic("freevm: no pgdir");
801064b2:	83 ec 0c             	sub    $0xc,%esp
801064b5:	68 f1 71 10 80       	push   $0x801071f1
801064ba:	e8 89 9e ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801064bf:	83 ec 0c             	sub    $0xc,%esp
801064c2:	68 38 6d 10 80       	push   $0x80106d38
801064c7:	e8 7c 9e ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801064cc:	83 c3 01             	add    $0x1,%ebx
801064cf:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801064d5:	77 26                	ja     801064fd <freevm+0x71>
    if(pgdir[i] & PTE_P){
801064d7:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801064da:	a8 01                	test   $0x1,%al
801064dc:	74 ee                	je     801064cc <freevm+0x40>
801064de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801064e3:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801064e8:	77 d5                	ja     801064bf <freevm+0x33>
    return (char*)a + KERNBASE;
801064ea:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
801064ef:	83 ec 0c             	sub    $0xc,%esp
801064f2:	50                   	push   %eax
801064f3:	e8 9a ba ff ff       	call   80101f92 <kfree>
801064f8:	83 c4 10             	add    $0x10,%esp
801064fb:	eb cf                	jmp    801064cc <freevm+0x40>
    }
  }
  kfree((char*)pgdir);
801064fd:	83 ec 0c             	sub    $0xc,%esp
80106500:	56                   	push   %esi
80106501:	e8 8c ba ff ff       	call   80101f92 <kfree>
}
80106506:	83 c4 10             	add    $0x10,%esp
80106509:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010650c:	5b                   	pop    %ebx
8010650d:	5e                   	pop    %esi
8010650e:	5d                   	pop    %ebp
8010650f:	c3                   	ret    

80106510 <setupkvm>:
{
80106510:	55                   	push   %ebp
80106511:	89 e5                	mov    %esp,%ebp
80106513:	56                   	push   %esi
80106514:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106515:	e8 b5 bb ff ff       	call   801020cf <kalloc>
8010651a:	89 c6                	mov    %eax,%esi
8010651c:	85 c0                	test   %eax,%eax
8010651e:	74 55                	je     80106575 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106520:	83 ec 04             	sub    $0x4,%esp
80106523:	68 00 10 00 00       	push   $0x1000
80106528:	6a 00                	push   $0x0
8010652a:	50                   	push   %eax
8010652b:	e8 c8 d8 ff ff       	call   80103df8 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106530:	83 c4 10             	add    $0x10,%esp
80106533:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106538:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
8010653e:	73 35                	jae    80106575 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106540:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106543:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106546:	29 c1                	sub    %eax,%ecx
80106548:	83 ec 08             	sub    $0x8,%esp
8010654b:	ff 73 0c             	pushl  0xc(%ebx)
8010654e:	50                   	push   %eax
8010654f:	8b 13                	mov    (%ebx),%edx
80106551:	89 f0                	mov    %esi,%eax
80106553:	e8 44 f9 ff ff       	call   80105e9c <mappages>
80106558:	83 c4 10             	add    $0x10,%esp
8010655b:	85 c0                	test   %eax,%eax
8010655d:	78 05                	js     80106564 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010655f:	83 c3 10             	add    $0x10,%ebx
80106562:	eb d4                	jmp    80106538 <setupkvm+0x28>
      freevm(pgdir);
80106564:	83 ec 0c             	sub    $0xc,%esp
80106567:	56                   	push   %esi
80106568:	e8 1f ff ff ff       	call   8010648c <freevm>
      return 0;
8010656d:	83 c4 10             	add    $0x10,%esp
80106570:	be 00 00 00 00       	mov    $0x0,%esi
}
80106575:	89 f0                	mov    %esi,%eax
80106577:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010657a:	5b                   	pop    %ebx
8010657b:	5e                   	pop    %esi
8010657c:	5d                   	pop    %ebp
8010657d:	c3                   	ret    

8010657e <kvmalloc>:
{
8010657e:	55                   	push   %ebp
8010657f:	89 e5                	mov    %esp,%ebp
80106581:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106584:	e8 87 ff ff ff       	call   80106510 <setupkvm>
80106589:	a3 a4 56 11 80       	mov    %eax,0x801156a4
  switchkvm();
8010658e:	e8 cb fa ff ff       	call   8010605e <switchkvm>
}
80106593:	c9                   	leave  
80106594:	c3                   	ret    

80106595 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106595:	55                   	push   %ebp
80106596:	89 e5                	mov    %esp,%ebp
80106598:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010659b:	b9 00 00 00 00       	mov    $0x0,%ecx
801065a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801065a3:	8b 45 08             	mov    0x8(%ebp),%eax
801065a6:	e8 57 f8 ff ff       	call   80105e02 <walkpgdir>
  if(pte == 0)
801065ab:	85 c0                	test   %eax,%eax
801065ad:	74 05                	je     801065b4 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801065af:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801065b2:	c9                   	leave  
801065b3:	c3                   	ret    
    panic("clearpteu");
801065b4:	83 ec 0c             	sub    $0xc,%esp
801065b7:	68 02 72 10 80       	push   $0x80107202
801065bc:	e8 87 9d ff ff       	call   80100348 <panic>

801065c1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801065c1:	55                   	push   %ebp
801065c2:	89 e5                	mov    %esp,%ebp
801065c4:	57                   	push   %edi
801065c5:	56                   	push   %esi
801065c6:	53                   	push   %ebx
801065c7:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801065ca:	e8 41 ff ff ff       	call   80106510 <setupkvm>
801065cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
801065d2:	85 c0                	test   %eax,%eax
801065d4:	0f 84 f2 00 00 00    	je     801066cc <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801065da:	bb 00 00 00 00       	mov    $0x0,%ebx
801065df:	eb 3a                	jmp    8010661b <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
801065e1:	83 ec 0c             	sub    $0xc,%esp
801065e4:	68 0c 72 10 80       	push   $0x8010720c
801065e9:	e8 5a 9d ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
801065ee:	83 ec 0c             	sub    $0xc,%esp
801065f1:	68 26 72 10 80       	push   $0x80107226
801065f6:	e8 4d 9d ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801065fb:	83 ec 0c             	sub    $0xc,%esp
801065fe:	68 38 6d 10 80       	push   $0x80106d38
80106603:	e8 40 9d ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106608:	83 ec 0c             	sub    $0xc,%esp
8010660b:	68 08 6a 10 80       	push   $0x80106a08
80106610:	e8 33 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106615:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010661b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
8010661e:	0f 83 a8 00 00 00    	jae    801066cc <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106624:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106627:	b9 00 00 00 00       	mov    $0x0,%ecx
8010662c:	89 da                	mov    %ebx,%edx
8010662e:	8b 45 08             	mov    0x8(%ebp),%eax
80106631:	e8 cc f7 ff ff       	call   80105e02 <walkpgdir>
80106636:	85 c0                	test   %eax,%eax
80106638:	74 a7                	je     801065e1 <copyuvm+0x20>
    if(!(*pte & PTE_P))
8010663a:	8b 00                	mov    (%eax),%eax
8010663c:	a8 01                	test   $0x1,%al
8010663e:	74 ae                	je     801065ee <copyuvm+0x2d>
80106640:	89 c6                	mov    %eax,%esi
80106642:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
80106648:	25 ff 0f 00 00       	and    $0xfff,%eax
8010664d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106650:	e8 7a ba ff ff       	call   801020cf <kalloc>
80106655:	89 c7                	mov    %eax,%edi
80106657:	85 c0                	test   %eax,%eax
80106659:	74 5c                	je     801066b7 <copyuvm+0xf6>
    if (a > KERNBASE)
8010665b:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106661:	77 98                	ja     801065fb <copyuvm+0x3a>
    return (char*)a + KERNBASE;
80106663:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106669:	83 ec 04             	sub    $0x4,%esp
8010666c:	68 00 10 00 00       	push   $0x1000
80106671:	56                   	push   %esi
80106672:	50                   	push   %eax
80106673:	e8 fb d7 ff ff       	call   80103e73 <memmove>
    if (a < (void*) KERNBASE)
80106678:	83 c4 10             	add    $0x10,%esp
8010667b:	81 ff ff ff ff 7f    	cmp    $0x7fffffff,%edi
80106681:	76 85                	jbe    80106608 <copyuvm+0x47>
    return (uint)a - KERNBASE;
80106683:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106689:	83 ec 08             	sub    $0x8,%esp
8010668c:	ff 75 e0             	pushl  -0x20(%ebp)
8010668f:	50                   	push   %eax
80106690:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106695:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106698:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010669b:	e8 fc f7 ff ff       	call   80105e9c <mappages>
801066a0:	83 c4 10             	add    $0x10,%esp
801066a3:	85 c0                	test   %eax,%eax
801066a5:	0f 89 6a ff ff ff    	jns    80106615 <copyuvm+0x54>
      kfree(mem);
801066ab:	83 ec 0c             	sub    $0xc,%esp
801066ae:	57                   	push   %edi
801066af:	e8 de b8 ff ff       	call   80101f92 <kfree>
      goto bad;
801066b4:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
801066b7:	83 ec 0c             	sub    $0xc,%esp
801066ba:	ff 75 dc             	pushl  -0x24(%ebp)
801066bd:	e8 ca fd ff ff       	call   8010648c <freevm>
  return 0;
801066c2:	83 c4 10             	add    $0x10,%esp
801066c5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801066cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801066cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066d2:	5b                   	pop    %ebx
801066d3:	5e                   	pop    %esi
801066d4:	5f                   	pop    %edi
801066d5:	5d                   	pop    %ebp
801066d6:	c3                   	ret    

801066d7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801066d7:	55                   	push   %ebp
801066d8:	89 e5                	mov    %esp,%ebp
801066da:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801066dd:	b9 00 00 00 00       	mov    $0x0,%ecx
801066e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801066e5:	8b 45 08             	mov    0x8(%ebp),%eax
801066e8:	e8 15 f7 ff ff       	call   80105e02 <walkpgdir>
  if((*pte & PTE_P) == 0)
801066ed:	8b 00                	mov    (%eax),%eax
801066ef:	a8 01                	test   $0x1,%al
801066f1:	74 24                	je     80106717 <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
801066f3:	a8 04                	test   $0x4,%al
801066f5:	74 27                	je     8010671e <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
801066f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801066fc:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106701:	77 07                	ja     8010670a <uva2ka+0x33>
    return (char*)a + KERNBASE;
80106703:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106708:	c9                   	leave  
80106709:	c3                   	ret    
        panic("P2V on address > KERNBASE");
8010670a:	83 ec 0c             	sub    $0xc,%esp
8010670d:	68 38 6d 10 80       	push   $0x80106d38
80106712:	e8 31 9c ff ff       	call   80100348 <panic>
    return 0;
80106717:	b8 00 00 00 00       	mov    $0x0,%eax
8010671c:	eb ea                	jmp    80106708 <uva2ka+0x31>
    return 0;
8010671e:	b8 00 00 00 00       	mov    $0x0,%eax
80106723:	eb e3                	jmp    80106708 <uva2ka+0x31>

80106725 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106725:	55                   	push   %ebp
80106726:	89 e5                	mov    %esp,%ebp
80106728:	57                   	push   %edi
80106729:	56                   	push   %esi
8010672a:	53                   	push   %ebx
8010672b:	83 ec 0c             	sub    $0xc,%esp
8010672e:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106731:	eb 25                	jmp    80106758 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106733:	8b 55 0c             	mov    0xc(%ebp),%edx
80106736:	29 f2                	sub    %esi,%edx
80106738:	01 d0                	add    %edx,%eax
8010673a:	83 ec 04             	sub    $0x4,%esp
8010673d:	53                   	push   %ebx
8010673e:	ff 75 10             	pushl  0x10(%ebp)
80106741:	50                   	push   %eax
80106742:	e8 2c d7 ff ff       	call   80103e73 <memmove>
    len -= n;
80106747:	29 df                	sub    %ebx,%edi
    buf += n;
80106749:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
8010674c:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106752:	89 45 0c             	mov    %eax,0xc(%ebp)
80106755:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106758:	85 ff                	test   %edi,%edi
8010675a:	74 2f                	je     8010678b <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
8010675c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010675f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106765:	83 ec 08             	sub    $0x8,%esp
80106768:	56                   	push   %esi
80106769:	ff 75 08             	pushl  0x8(%ebp)
8010676c:	e8 66 ff ff ff       	call   801066d7 <uva2ka>
    if(pa0 == 0)
80106771:	83 c4 10             	add    $0x10,%esp
80106774:	85 c0                	test   %eax,%eax
80106776:	74 20                	je     80106798 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106778:	89 f3                	mov    %esi,%ebx
8010677a:	2b 5d 0c             	sub    0xc(%ebp),%ebx
8010677d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106783:	39 df                	cmp    %ebx,%edi
80106785:	73 ac                	jae    80106733 <copyout+0xe>
      n = len;
80106787:	89 fb                	mov    %edi,%ebx
80106789:	eb a8                	jmp    80106733 <copyout+0xe>
  }
  return 0;
8010678b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106790:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106793:	5b                   	pop    %ebx
80106794:	5e                   	pop    %esi
80106795:	5f                   	pop    %edi
80106796:	5d                   	pop    %ebp
80106797:	c3                   	ret    
      return -1;
80106798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010679d:	eb f1                	jmp    80106790 <copyout+0x6b>
