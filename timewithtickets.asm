
_timewithtickets:     file format elf32-i386


Disassembly of section .text:

00000000 <yield_forever>:
#define MAX_CHILDREN 32
#define LARGE_TICKET_COUNT 100000
#define MAX_YIELDS_FOR_SETUP 100

__attribute__((noreturn))
void yield_forever() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        yield();
   6:	e8 40 06 00 00       	call   64b <yield>
   b:	eb f9                	jmp    6 <yield_forever+0x6>

0000000d <run_forever>:
    }
}

__attribute__((noreturn))
void run_forever() {
   d:	55                   	push   %ebp
   e:	89 e5                	mov    %esp,%ebp
    while (1) {
        __asm__("");
  10:	eb fe                	jmp    10 <run_forever+0x3>

00000012 <spawn>:
    }
}

int spawn(int tickets) {
  12:	55                   	push   %ebp
  13:	89 e5                	mov    %esp,%ebp
  15:	53                   	push   %ebx
  16:	83 ec 04             	sub    $0x4,%esp
    int pid = fork();
  19:	e8 85 05 00 00       	call   5a3 <fork>
    if (pid == 0) {
  1e:	85 c0                	test   %eax,%eax
  20:	74 0e                	je     30 <spawn+0x1e>
  22:	89 c3                	mov    %eax,%ebx
#ifdef USE_YIELD
        yield_forever();
#else
        run_forever();
#endif
    } else if (pid != -1) {
  24:	83 f8 ff             	cmp    $0xffffffff,%eax
  27:	74 1c                	je     45 <spawn+0x33>
        return pid;
    } else {
        printf(2, "error in fork\n");
        return -1;
    }
}
  29:	89 d8                	mov    %ebx,%eax
  2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  2e:	c9                   	leave  
  2f:	c3                   	ret    
        settickets(tickets);
  30:	83 ec 0c             	sub    $0xc,%esp
  33:	ff 75 08             	pushl  0x8(%ebp)
  36:	e8 30 06 00 00       	call   66b <settickets>
        yield();
  3b:	e8 0b 06 00 00       	call   64b <yield>
        run_forever();
  40:	e8 c8 ff ff ff       	call   d <run_forever>
        printf(2, "error in fork\n");
  45:	83 ec 08             	sub    $0x8,%esp
  48:	68 d0 09 00 00       	push   $0x9d0
  4d:	6a 02                	push   $0x2
  4f:	e8 c1 06 00 00       	call   715 <printf>
        return -1;
  54:	83 c4 10             	add    $0x10,%esp
  57:	eb d0                	jmp    29 <spawn+0x17>

00000059 <find_index_of_pid>:

int find_index_of_pid(int *list, int list_size, int pid) {
  59:	55                   	push   %ebp
  5a:	89 e5                	mov    %esp,%ebp
  5c:	53                   	push   %ebx
  5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  60:	8b 55 0c             	mov    0xc(%ebp),%edx
  63:	8b 4d 10             	mov    0x10(%ebp),%ecx
    for (int i = 0; i < list_size; ++i) {
  66:	b8 00 00 00 00       	mov    $0x0,%eax
  6b:	39 d0                	cmp    %edx,%eax
  6d:	7d 0a                	jge    79 <find_index_of_pid+0x20>
        if (list[i] == pid)
  6f:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  72:	74 0a                	je     7e <find_index_of_pid+0x25>
    for (int i = 0; i < list_size; ++i) {
  74:	83 c0 01             	add    $0x1,%eax
  77:	eb f2                	jmp    6b <find_index_of_pid+0x12>
            return i;
    }
    return -1;
  79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  7e:	5b                   	pop    %ebx
  7f:	5d                   	pop    %ebp
  80:	c3                   	ret    

00000081 <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  81:	55                   	push   %ebp
  82:	89 e5                	mov    %esp,%ebp
  84:	57                   	push   %edi
  85:	56                   	push   %esi
  86:	53                   	push   %ebx
  87:	81 ec 2c 03 00 00    	sub    $0x32c,%esp
  8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  90:	8b 7d 10             	mov    0x10(%ebp),%edi
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  93:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  9a:	00 00 00 
  9d:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
  a4:	7f 6c                	jg     112 <wait_for_ticket_counts+0x91>
        yield();
  a6:	e8 a0 05 00 00       	call   64b <yield>
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
  ab:	83 ec 0c             	sub    $0xc,%esp
  ae:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  b4:	50                   	push   %eax
  b5:	e8 b9 05 00 00       	call   673 <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
  c2:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
  c9:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
  cc:	eb 03                	jmp    d1 <wait_for_ticket_counts+0x50>
  ce:	83 c3 01             	add    $0x1,%ebx
  d1:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  d4:	7d 33                	jge    109 <wait_for_ticket_counts+0x88>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
  d6:	83 ec 04             	sub    $0x4,%esp
  d9:	ff 34 9e             	pushl  (%esi,%ebx,4)
  dc:	ff b5 e4 fc ff ff    	pushl  -0x31c(%ebp)
  e2:	8d 85 e8 fc ff ff    	lea    -0x318(%ebp),%eax
  e8:	50                   	push   %eax
  e9:	e8 6b ff ff ff       	call   59 <find_index_of_pid>
  ee:	83 c4 10             	add    $0x10,%esp
            if (info.tickets[index] != tickets[i]) done = 0;
  f1:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
  f4:	39 94 85 e8 fe ff ff 	cmp    %edx,-0x118(%ebp,%eax,4)
  fb:	74 d1                	je     ce <wait_for_ticket_counts+0x4d>
  fd:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
 104:	00 00 00 
 107:	eb c5                	jmp    ce <wait_for_ticket_counts+0x4d>
        }
        if (done)
 109:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 110:	74 08                	je     11a <wait_for_ticket_counts+0x99>
            break;
    }
}
 112:	8d 65 f4             	lea    -0xc(%ebp),%esp
 115:	5b                   	pop    %ebx
 116:	5e                   	pop    %esi
 117:	5f                   	pop    %edi
 118:	5d                   	pop    %ebp
 119:	c3                   	ret    
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 11a:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 121:	e9 77 ff ff ff       	jmp    9d <wait_for_ticket_counts+0x1c>

00000126 <main>:

int main(int argc, char *argv[])
{
 126:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 12a:	83 e4 f0             	and    $0xfffffff0,%esp
 12d:	ff 71 fc             	pushl  -0x4(%ecx)
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	57                   	push   %edi
 134:	56                   	push   %esi
 135:	53                   	push   %ebx
 136:	51                   	push   %ecx
 137:	81 ec 28 07 00 00    	sub    $0x728,%esp
 13d:	8b 31                	mov    (%ecx),%esi
 13f:	8b 79 04             	mov    0x4(%ecx),%edi
    if (argc < 3) {
 142:	83 fe 02             	cmp    $0x2,%esi
 145:	7e 33                	jle    17a <main+0x54>
                  argv[0]);
        exit();
    }
    int tickets_for[MAX_CHILDREN];
    int active_pids[MAX_CHILDREN];
    int num_seconds = atoi(argv[1]);
 147:	83 ec 0c             	sub    $0xc,%esp
 14a:	ff 77 04             	pushl  0x4(%edi)
 14d:	e8 fb 03 00 00       	call   54d <atoi>
 152:	89 85 d4 f8 ff ff    	mov    %eax,-0x72c(%ebp)
    int num_children = argc - 2;
 158:	83 ee 02             	sub    $0x2,%esi
    if (num_children > MAX_CHILDREN) {
 15b:	83 c4 10             	add    $0x10,%esp
 15e:	83 fe 20             	cmp    $0x20,%esi
 161:	7f 2d                	jg     190 <main+0x6a>
        printf(2, "only up to %d supported\n", MAX_CHILDREN);
        exit();
    }
    /* give us a lot of ticket so we don't get starved */
    settickets(LARGE_TICKET_COUNT);
 163:	83 ec 0c             	sub    $0xc,%esp
 166:	68 a0 86 01 00       	push   $0x186a0
 16b:	e8 fb 04 00 00       	call   66b <settickets>
    for (int i = 0; i < num_children; ++i) {
 170:	83 c4 10             	add    $0x10,%esp
 173:	bb 00 00 00 00       	mov    $0x0,%ebx
 178:	eb 54                	jmp    1ce <main+0xa8>
        printf(2, "usage: %s seconds tickets1 tickets2 ... ticketsN\n"
 17a:	83 ec 04             	sub    $0x4,%esp
 17d:	ff 37                	pushl  (%edi)
 17f:	68 28 0a 00 00       	push   $0xa28
 184:	6a 02                	push   $0x2
 186:	e8 8a 05 00 00       	call   715 <printf>
        exit();
 18b:	e8 1b 04 00 00       	call   5ab <exit>
        printf(2, "only up to %d supported\n", MAX_CHILDREN);
 190:	83 ec 04             	sub    $0x4,%esp
 193:	6a 20                	push   $0x20
 195:	68 df 09 00 00       	push   $0x9df
 19a:	6a 02                	push   $0x2
 19c:	e8 74 05 00 00       	call   715 <printf>
        exit();
 1a1:	e8 05 04 00 00       	call   5ab <exit>
        int tickets = atoi(argv[i + 2]);
 1a6:	83 ec 0c             	sub    $0xc,%esp
 1a9:	ff 74 9f 08          	pushl  0x8(%edi,%ebx,4)
 1ad:	e8 9b 03 00 00       	call   54d <atoi>
        tickets_for[i] = tickets;
 1b2:	89 84 9d 68 ff ff ff 	mov    %eax,-0x98(%ebp,%ebx,4)
        active_pids[i] = spawn(tickets);
 1b9:	89 04 24             	mov    %eax,(%esp)
 1bc:	e8 51 fe ff ff       	call   12 <spawn>
 1c1:	89 84 9d e8 fe ff ff 	mov    %eax,-0x118(%ebp,%ebx,4)
    for (int i = 0; i < num_children; ++i) {
 1c8:	83 c3 01             	add    $0x1,%ebx
 1cb:	83 c4 10             	add    $0x10,%esp
 1ce:	39 f3                	cmp    %esi,%ebx
 1d0:	7c d4                	jl     1a6 <main+0x80>
    }
    wait_for_ticket_counts(num_children, active_pids, tickets_for);
 1d2:	83 ec 04             	sub    $0x4,%esp
 1d5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
 1db:	50                   	push   %eax
 1dc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
 1e2:	50                   	push   %eax
 1e3:	56                   	push   %esi
 1e4:	e8 98 fe ff ff       	call   81 <wait_for_ticket_counts>
    struct processes_info before, after;
    before.num_processes = after.num_processes = -1;
 1e9:	c7 85 e0 f8 ff ff ff 	movl   $0xffffffff,-0x720(%ebp)
 1f0:	ff ff ff 
 1f3:	c7 85 e4 fb ff ff ff 	movl   $0xffffffff,-0x41c(%ebp)
 1fa:	ff ff ff 
    getprocessesinfo(&before);
 1fd:	8d 85 e4 fb ff ff    	lea    -0x41c(%ebp),%eax
 203:	89 04 24             	mov    %eax,(%esp)
 206:	e8 68 04 00 00       	call   673 <getprocessesinfo>
    sleep(num_seconds);
 20b:	83 c4 04             	add    $0x4,%esp
 20e:	ff b5 d4 f8 ff ff    	pushl  -0x72c(%ebp)
 214:	e8 22 04 00 00       	call   63b <sleep>
    getprocessesinfo(&after);
 219:	8d 85 e0 f8 ff ff    	lea    -0x720(%ebp),%eax
 21f:	89 04 24             	mov    %eax,(%esp)
 222:	e8 4c 04 00 00       	call   673 <getprocessesinfo>
    for (int i = 0; i < num_children; ++i) {
 227:	83 c4 10             	add    $0x10,%esp
 22a:	bb 00 00 00 00       	mov    $0x0,%ebx
 22f:	eb 15                	jmp    246 <main+0x120>
        kill(active_pids[i]);
 231:	83 ec 0c             	sub    $0xc,%esp
 234:	ff b4 9d e8 fe ff ff 	pushl  -0x118(%ebp,%ebx,4)
 23b:	e8 9b 03 00 00       	call   5db <kill>
    for (int i = 0; i < num_children; ++i) {
 240:	83 c3 01             	add    $0x1,%ebx
 243:	83 c4 10             	add    $0x10,%esp
 246:	39 f3                	cmp    %esi,%ebx
 248:	7c e7                	jl     231 <main+0x10b>
    }
    for (int i = 0; i < num_children; ++i) {
 24a:	bb 00 00 00 00       	mov    $0x0,%ebx
 24f:	eb 08                	jmp    259 <main+0x133>
        wait();
 251:	e8 5d 03 00 00       	call   5b3 <wait>
    for (int i = 0; i < num_children; ++i) {
 256:	83 c3 01             	add    $0x1,%ebx
 259:	39 f3                	cmp    %esi,%ebx
 25b:	7c f4                	jl     251 <main+0x12b>
    }
    if (before.num_processes >= NPROC || after.num_processes >= NPROC) {
 25d:	8b 85 e4 fb ff ff    	mov    -0x41c(%ebp),%eax
 263:	83 f8 3f             	cmp    $0x3f,%eax
 266:	7f 27                	jg     28f <main+0x169>
 268:	8b 95 e0 f8 ff ff    	mov    -0x720(%ebp),%edx
 26e:	83 fa 3f             	cmp    $0x3f,%edx
 271:	7f 1c                	jg     28f <main+0x169>
        printf(2, "getprocessesinfo's num_processes is greater than NPROC before parent slept\n");
        return 1;
    }
    if (before.num_processes < 0 || after.num_processes < 0) {
 273:	85 c0                	test   %eax,%eax
 275:	78 04                	js     27b <main+0x155>
 277:	85 d2                	test   %edx,%edx
 279:	79 37                	jns    2b2 <main+0x18c>
        printf(2, "getprocessesinfo's num_processes is negative -- not changed by syscall?\n");
 27b:	83 ec 08             	sub    $0x8,%esp
 27e:	68 20 0b 00 00       	push   $0xb20
 283:	6a 02                	push   $0x2
 285:	e8 8b 04 00 00       	call   715 <printf>
        return 1;
 28a:	83 c4 10             	add    $0x10,%esp
 28d:	eb 12                	jmp    2a1 <main+0x17b>
        printf(2, "getprocessesinfo's num_processes is greater than NPROC before parent slept\n");
 28f:	83 ec 08             	sub    $0x8,%esp
 292:	68 d4 0a 00 00       	push   $0xad4
 297:	6a 02                	push   $0x2
 299:	e8 77 04 00 00       	call   715 <printf>
        return 1;
 29e:	83 c4 10             	add    $0x10,%esp
            }
            printf(1, "%d\t%d\n", tickets_for[i], after.times_scheduled[after_index] - before.times_scheduled[before_index]);
        }
    }
    exit();
}
 2a1:	b8 01 00 00 00       	mov    $0x1,%eax
 2a6:	8d 65 f0             	lea    -0x10(%ebp),%esp
 2a9:	59                   	pop    %ecx
 2aa:	5b                   	pop    %ebx
 2ab:	5e                   	pop    %esi
 2ac:	5f                   	pop    %edi
 2ad:	5d                   	pop    %ebp
 2ae:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2b1:	c3                   	ret    
    printf(1, "TICKETS\tTIMES SCHEDULED\n");
 2b2:	83 ec 08             	sub    $0x8,%esp
 2b5:	68 f8 09 00 00       	push   $0x9f8
 2ba:	6a 01                	push   $0x1
 2bc:	e8 54 04 00 00       	call   715 <printf>
    for (int i = 0; i < num_children; ++i) {
 2c1:	83 c4 10             	add    $0x10,%esp
 2c4:	bb 00 00 00 00       	mov    $0x0,%ebx
 2c9:	e9 c8 00 00 00       	jmp    396 <main+0x270>
        int before_index = find_index_of_pid(before.pids, before.num_processes, active_pids[i]);
 2ce:	8b bc 9d e8 fe ff ff 	mov    -0x118(%ebp,%ebx,4),%edi
 2d5:	83 ec 04             	sub    $0x4,%esp
 2d8:	57                   	push   %edi
 2d9:	ff b5 e4 fb ff ff    	pushl  -0x41c(%ebp)
 2df:	8d 85 e8 fb ff ff    	lea    -0x418(%ebp),%eax
 2e5:	50                   	push   %eax
 2e6:	e8 6e fd ff ff       	call   59 <find_index_of_pid>
 2eb:	83 c4 0c             	add    $0xc,%esp
 2ee:	89 85 d4 f8 ff ff    	mov    %eax,-0x72c(%ebp)
        int after_index = find_index_of_pid(after.pids, after.num_processes, active_pids[i]);
 2f4:	57                   	push   %edi
 2f5:	ff b5 e0 f8 ff ff    	pushl  -0x720(%ebp)
 2fb:	8d 85 e4 f8 ff ff    	lea    -0x71c(%ebp),%eax
 301:	50                   	push   %eax
 302:	e8 52 fd ff ff       	call   59 <find_index_of_pid>
 307:	83 c4 10             	add    $0x10,%esp
 30a:	89 c7                	mov    %eax,%edi
        if (before_index == -1)
 30c:	83 bd d4 f8 ff ff ff 	cmpl   $0xffffffff,-0x72c(%ebp)
 313:	0f 84 8a 00 00 00    	je     3a3 <main+0x27d>
        if (after_index == -1)
 319:	83 ff ff             	cmp    $0xffffffff,%edi
 31c:	0f 84 99 00 00 00    	je     3bb <main+0x295>
        if (before_index == -1 || after_index == -1) {
 322:	83 bd d4 f8 ff ff ff 	cmpl   $0xffffffff,-0x72c(%ebp)
 329:	0f 94 c2             	sete   %dl
 32c:	83 ff ff             	cmp    $0xffffffff,%edi
 32f:	0f 94 c0             	sete   %al
 332:	08 c2                	or     %al,%dl
 334:	0f 85 99 00 00 00    	jne    3d3 <main+0x2ad>
            if (before.tickets[before_index] != tickets_for[i]) {
 33a:	8b 85 d4 f8 ff ff    	mov    -0x72c(%ebp),%eax
 340:	8b 94 9d 68 ff ff ff 	mov    -0x98(%ebp,%ebx,4),%edx
 347:	39 94 85 e8 fd ff ff 	cmp    %edx,-0x218(%ebp,%eax,4)
 34e:	0f 85 9a 00 00 00    	jne    3ee <main+0x2c8>
            if (after.tickets[after_index] != tickets_for[i]) {
 354:	8b 84 9d 68 ff ff ff 	mov    -0x98(%ebp,%ebx,4),%eax
 35b:	39 84 bd e4 fa ff ff 	cmp    %eax,-0x51c(%ebp,%edi,4)
 362:	0f 85 9e 00 00 00    	jne    406 <main+0x2e0>
            printf(1, "%d\t%d\n", tickets_for[i], after.times_scheduled[after_index] - before.times_scheduled[before_index]);
 368:	8b 84 bd e4 f9 ff ff 	mov    -0x61c(%ebp,%edi,4),%eax
 36f:	8b 95 d4 f8 ff ff    	mov    -0x72c(%ebp),%edx
 375:	2b 84 95 e8 fc ff ff 	sub    -0x318(%ebp,%edx,4),%eax
 37c:	50                   	push   %eax
 37d:	ff b4 9d 68 ff ff ff 	pushl  -0x98(%ebp,%ebx,4)
 384:	68 21 0a 00 00       	push   $0xa21
 389:	6a 01                	push   $0x1
 38b:	e8 85 03 00 00       	call   715 <printf>
 390:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < num_children; ++i) {
 393:	83 c3 01             	add    $0x1,%ebx
 396:	39 f3                	cmp    %esi,%ebx
 398:	0f 8c 30 ff ff ff    	jl     2ce <main+0x1a8>
    exit();
 39e:	e8 08 02 00 00       	call   5ab <exit>
            printf(2, "child %d did not exist for getprocessesinfo before parent slept\n", i);
 3a3:	83 ec 04             	sub    $0x4,%esp
 3a6:	53                   	push   %ebx
 3a7:	68 6c 0b 00 00       	push   $0xb6c
 3ac:	6a 02                	push   $0x2
 3ae:	e8 62 03 00 00       	call   715 <printf>
 3b3:	83 c4 10             	add    $0x10,%esp
 3b6:	e9 5e ff ff ff       	jmp    319 <main+0x1f3>
            printf(2, "child %d did not exist for getprocessesinfo after parent slept\n", i);
 3bb:	83 ec 04             	sub    $0x4,%esp
 3be:	53                   	push   %ebx
 3bf:	68 b0 0b 00 00       	push   $0xbb0
 3c4:	6a 02                	push   $0x2
 3c6:	e8 4a 03 00 00       	call   715 <printf>
 3cb:	83 c4 10             	add    $0x10,%esp
 3ce:	e9 4f ff ff ff       	jmp    322 <main+0x1fc>
            printf(1, "%d\t--unknown--\n", tickets_for[i]);
 3d3:	83 ec 04             	sub    $0x4,%esp
 3d6:	ff b4 9d 68 ff ff ff 	pushl  -0x98(%ebp,%ebx,4)
 3dd:	68 11 0a 00 00       	push   $0xa11
 3e2:	6a 01                	push   $0x1
 3e4:	e8 2c 03 00 00       	call   715 <printf>
 3e9:	83 c4 10             	add    $0x10,%esp
 3ec:	eb a5                	jmp    393 <main+0x26d>
                printf(2, "child %d had wrong number of tickets in getprocessinfo before parent slept\n", i);
 3ee:	83 ec 04             	sub    $0x4,%esp
 3f1:	53                   	push   %ebx
 3f2:	68 f0 0b 00 00       	push   $0xbf0
 3f7:	6a 02                	push   $0x2
 3f9:	e8 17 03 00 00       	call   715 <printf>
 3fe:	83 c4 10             	add    $0x10,%esp
 401:	e9 4e ff ff ff       	jmp    354 <main+0x22e>
                printf(2, "child %d had wrong number of tickets in getprocessinfo after parent slept\n", i);
 406:	83 ec 04             	sub    $0x4,%esp
 409:	53                   	push   %ebx
 40a:	68 3c 0c 00 00       	push   $0xc3c
 40f:	6a 02                	push   $0x2
 411:	e8 ff 02 00 00       	call   715 <printf>
 416:	83 c4 10             	add    $0x10,%esp
 419:	e9 4a ff ff ff       	jmp    368 <main+0x242>

0000041e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 41e:	55                   	push   %ebp
 41f:	89 e5                	mov    %esp,%ebp
 421:	53                   	push   %ebx
 422:	8b 45 08             	mov    0x8(%ebp),%eax
 425:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 428:	89 c2                	mov    %eax,%edx
 42a:	0f b6 19             	movzbl (%ecx),%ebx
 42d:	88 1a                	mov    %bl,(%edx)
 42f:	8d 52 01             	lea    0x1(%edx),%edx
 432:	8d 49 01             	lea    0x1(%ecx),%ecx
 435:	84 db                	test   %bl,%bl
 437:	75 f1                	jne    42a <strcpy+0xc>
    ;
  return os;
}
 439:	5b                   	pop    %ebx
 43a:	5d                   	pop    %ebp
 43b:	c3                   	ret    

0000043c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
 43f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 442:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 445:	eb 06                	jmp    44d <strcmp+0x11>
    p++, q++;
 447:	83 c1 01             	add    $0x1,%ecx
 44a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 44d:	0f b6 01             	movzbl (%ecx),%eax
 450:	84 c0                	test   %al,%al
 452:	74 04                	je     458 <strcmp+0x1c>
 454:	3a 02                	cmp    (%edx),%al
 456:	74 ef                	je     447 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 458:	0f b6 c0             	movzbl %al,%eax
 45b:	0f b6 12             	movzbl (%edx),%edx
 45e:	29 d0                	sub    %edx,%eax
}
 460:	5d                   	pop    %ebp
 461:	c3                   	ret    

00000462 <strlen>:

uint
strlen(const char *s)
{
 462:	55                   	push   %ebp
 463:	89 e5                	mov    %esp,%ebp
 465:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 468:	ba 00 00 00 00       	mov    $0x0,%edx
 46d:	eb 03                	jmp    472 <strlen+0x10>
 46f:	83 c2 01             	add    $0x1,%edx
 472:	89 d0                	mov    %edx,%eax
 474:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 478:	75 f5                	jne    46f <strlen+0xd>
    ;
  return n;
}
 47a:	5d                   	pop    %ebp
 47b:	c3                   	ret    

0000047c <memset>:

void*
memset(void *dst, int c, uint n)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	57                   	push   %edi
 480:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 483:	89 d7                	mov    %edx,%edi
 485:	8b 4d 10             	mov    0x10(%ebp),%ecx
 488:	8b 45 0c             	mov    0xc(%ebp),%eax
 48b:	fc                   	cld    
 48c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 48e:	89 d0                	mov    %edx,%eax
 490:	5f                   	pop    %edi
 491:	5d                   	pop    %ebp
 492:	c3                   	ret    

00000493 <strchr>:

char*
strchr(const char *s, char c)
{
 493:	55                   	push   %ebp
 494:	89 e5                	mov    %esp,%ebp
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 49d:	0f b6 10             	movzbl (%eax),%edx
 4a0:	84 d2                	test   %dl,%dl
 4a2:	74 09                	je     4ad <strchr+0x1a>
    if(*s == c)
 4a4:	38 ca                	cmp    %cl,%dl
 4a6:	74 0a                	je     4b2 <strchr+0x1f>
  for(; *s; s++)
 4a8:	83 c0 01             	add    $0x1,%eax
 4ab:	eb f0                	jmp    49d <strchr+0xa>
      return (char*)s;
  return 0;
 4ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4b2:	5d                   	pop    %ebp
 4b3:	c3                   	ret    

000004b4 <gets>:

char*
gets(char *buf, int max)
{
 4b4:	55                   	push   %ebp
 4b5:	89 e5                	mov    %esp,%ebp
 4b7:	57                   	push   %edi
 4b8:	56                   	push   %esi
 4b9:	53                   	push   %ebx
 4ba:	83 ec 1c             	sub    $0x1c,%esp
 4bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c0:	bb 00 00 00 00       	mov    $0x0,%ebx
 4c5:	8d 73 01             	lea    0x1(%ebx),%esi
 4c8:	3b 75 0c             	cmp    0xc(%ebp),%esi
 4cb:	7d 2e                	jge    4fb <gets+0x47>
    cc = read(0, &c, 1);
 4cd:	83 ec 04             	sub    $0x4,%esp
 4d0:	6a 01                	push   $0x1
 4d2:	8d 45 e7             	lea    -0x19(%ebp),%eax
 4d5:	50                   	push   %eax
 4d6:	6a 00                	push   $0x0
 4d8:	e8 e6 00 00 00       	call   5c3 <read>
    if(cc < 1)
 4dd:	83 c4 10             	add    $0x10,%esp
 4e0:	85 c0                	test   %eax,%eax
 4e2:	7e 17                	jle    4fb <gets+0x47>
      break;
    buf[i++] = c;
 4e4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4e8:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 4eb:	3c 0a                	cmp    $0xa,%al
 4ed:	0f 94 c2             	sete   %dl
 4f0:	3c 0d                	cmp    $0xd,%al
 4f2:	0f 94 c0             	sete   %al
    buf[i++] = c;
 4f5:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 4f7:	08 c2                	or     %al,%dl
 4f9:	74 ca                	je     4c5 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 4fb:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 4ff:	89 f8                	mov    %edi,%eax
 501:	8d 65 f4             	lea    -0xc(%ebp),%esp
 504:	5b                   	pop    %ebx
 505:	5e                   	pop    %esi
 506:	5f                   	pop    %edi
 507:	5d                   	pop    %ebp
 508:	c3                   	ret    

00000509 <stat>:

int
stat(const char *n, struct stat *st)
{
 509:	55                   	push   %ebp
 50a:	89 e5                	mov    %esp,%ebp
 50c:	56                   	push   %esi
 50d:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 50e:	83 ec 08             	sub    $0x8,%esp
 511:	6a 00                	push   $0x0
 513:	ff 75 08             	pushl  0x8(%ebp)
 516:	e8 d0 00 00 00       	call   5eb <open>
  if(fd < 0)
 51b:	83 c4 10             	add    $0x10,%esp
 51e:	85 c0                	test   %eax,%eax
 520:	78 24                	js     546 <stat+0x3d>
 522:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 524:	83 ec 08             	sub    $0x8,%esp
 527:	ff 75 0c             	pushl  0xc(%ebp)
 52a:	50                   	push   %eax
 52b:	e8 d3 00 00 00       	call   603 <fstat>
 530:	89 c6                	mov    %eax,%esi
  close(fd);
 532:	89 1c 24             	mov    %ebx,(%esp)
 535:	e8 99 00 00 00       	call   5d3 <close>
  return r;
 53a:	83 c4 10             	add    $0x10,%esp
}
 53d:	89 f0                	mov    %esi,%eax
 53f:	8d 65 f8             	lea    -0x8(%ebp),%esp
 542:	5b                   	pop    %ebx
 543:	5e                   	pop    %esi
 544:	5d                   	pop    %ebp
 545:	c3                   	ret    
    return -1;
 546:	be ff ff ff ff       	mov    $0xffffffff,%esi
 54b:	eb f0                	jmp    53d <stat+0x34>

0000054d <atoi>:

int
atoi(const char *s)
{
 54d:	55                   	push   %ebp
 54e:	89 e5                	mov    %esp,%ebp
 550:	53                   	push   %ebx
 551:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 554:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 559:	eb 10                	jmp    56b <atoi+0x1e>
    n = n*10 + *s++ - '0';
 55b:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 55e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 561:	83 c1 01             	add    $0x1,%ecx
 564:	0f be d2             	movsbl %dl,%edx
 567:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 56b:	0f b6 11             	movzbl (%ecx),%edx
 56e:	8d 5a d0             	lea    -0x30(%edx),%ebx
 571:	80 fb 09             	cmp    $0x9,%bl
 574:	76 e5                	jbe    55b <atoi+0xe>
  return n;
}
 576:	5b                   	pop    %ebx
 577:	5d                   	pop    %ebp
 578:	c3                   	ret    

00000579 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 579:	55                   	push   %ebp
 57a:	89 e5                	mov    %esp,%ebp
 57c:	56                   	push   %esi
 57d:	53                   	push   %ebx
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 584:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 587:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 589:	eb 0d                	jmp    598 <memmove+0x1f>
    *dst++ = *src++;
 58b:	0f b6 13             	movzbl (%ebx),%edx
 58e:	88 11                	mov    %dl,(%ecx)
 590:	8d 5b 01             	lea    0x1(%ebx),%ebx
 593:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 596:	89 f2                	mov    %esi,%edx
 598:	8d 72 ff             	lea    -0x1(%edx),%esi
 59b:	85 d2                	test   %edx,%edx
 59d:	7f ec                	jg     58b <memmove+0x12>
  return vdst;
}
 59f:	5b                   	pop    %ebx
 5a0:	5e                   	pop    %esi
 5a1:	5d                   	pop    %ebp
 5a2:	c3                   	ret    

000005a3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5a3:	b8 01 00 00 00       	mov    $0x1,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret    

000005ab <exit>:
SYSCALL(exit)
 5ab:	b8 02 00 00 00       	mov    $0x2,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret    

000005b3 <wait>:
SYSCALL(wait)
 5b3:	b8 03 00 00 00       	mov    $0x3,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret    

000005bb <pipe>:
SYSCALL(pipe)
 5bb:	b8 04 00 00 00       	mov    $0x4,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret    

000005c3 <read>:
SYSCALL(read)
 5c3:	b8 05 00 00 00       	mov    $0x5,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret    

000005cb <write>:
SYSCALL(write)
 5cb:	b8 10 00 00 00       	mov    $0x10,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret    

000005d3 <close>:
SYSCALL(close)
 5d3:	b8 15 00 00 00       	mov    $0x15,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret    

000005db <kill>:
SYSCALL(kill)
 5db:	b8 06 00 00 00       	mov    $0x6,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret    

000005e3 <exec>:
SYSCALL(exec)
 5e3:	b8 07 00 00 00       	mov    $0x7,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret    

000005eb <open>:
SYSCALL(open)
 5eb:	b8 0f 00 00 00       	mov    $0xf,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret    

000005f3 <mknod>:
SYSCALL(mknod)
 5f3:	b8 11 00 00 00       	mov    $0x11,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret    

000005fb <unlink>:
SYSCALL(unlink)
 5fb:	b8 12 00 00 00       	mov    $0x12,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <fstat>:
SYSCALL(fstat)
 603:	b8 08 00 00 00       	mov    $0x8,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <link>:
SYSCALL(link)
 60b:	b8 13 00 00 00       	mov    $0x13,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <mkdir>:
SYSCALL(mkdir)
 613:	b8 14 00 00 00       	mov    $0x14,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <chdir>:
SYSCALL(chdir)
 61b:	b8 09 00 00 00       	mov    $0x9,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <dup>:
SYSCALL(dup)
 623:	b8 0a 00 00 00       	mov    $0xa,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <getpid>:
SYSCALL(getpid)
 62b:	b8 0b 00 00 00       	mov    $0xb,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    

00000633 <sbrk>:
SYSCALL(sbrk)
 633:	b8 0c 00 00 00       	mov    $0xc,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret    

0000063b <sleep>:
SYSCALL(sleep)
 63b:	b8 0d 00 00 00       	mov    $0xd,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret    

00000643 <uptime>:
SYSCALL(uptime)
 643:	b8 0e 00 00 00       	mov    $0xe,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret    

0000064b <yield>:
SYSCALL(yield)
 64b:	b8 16 00 00 00       	mov    $0x16,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret    

00000653 <shutdown>:
SYSCALL(shutdown)
 653:	b8 17 00 00 00       	mov    $0x17,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret    

0000065b <writecount>:
SYSCALL(writecount)
 65b:	b8 18 00 00 00       	mov    $0x18,%eax
 660:	cd 40                	int    $0x40
 662:	c3                   	ret    

00000663 <setwritecount>:
SYSCALL(setwritecount)
 663:	b8 19 00 00 00       	mov    $0x19,%eax
 668:	cd 40                	int    $0x40
 66a:	c3                   	ret    

0000066b <settickets>:
SYSCALL(settickets)
 66b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 670:	cd 40                	int    $0x40
 672:	c3                   	ret    

00000673 <getprocessesinfo>:
 673:	b8 1b 00 00 00       	mov    $0x1b,%eax
 678:	cd 40                	int    $0x40
 67a:	c3                   	ret    

0000067b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 67b:	55                   	push   %ebp
 67c:	89 e5                	mov    %esp,%ebp
 67e:	83 ec 1c             	sub    $0x1c,%esp
 681:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 684:	6a 01                	push   $0x1
 686:	8d 55 f4             	lea    -0xc(%ebp),%edx
 689:	52                   	push   %edx
 68a:	50                   	push   %eax
 68b:	e8 3b ff ff ff       	call   5cb <write>
}
 690:	83 c4 10             	add    $0x10,%esp
 693:	c9                   	leave  
 694:	c3                   	ret    

00000695 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 695:	55                   	push   %ebp
 696:	89 e5                	mov    %esp,%ebp
 698:	57                   	push   %edi
 699:	56                   	push   %esi
 69a:	53                   	push   %ebx
 69b:	83 ec 2c             	sub    $0x2c,%esp
 69e:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 6a4:	0f 95 c3             	setne  %bl
 6a7:	89 d0                	mov    %edx,%eax
 6a9:	c1 e8 1f             	shr    $0x1f,%eax
 6ac:	84 c3                	test   %al,%bl
 6ae:	74 10                	je     6c0 <printint+0x2b>
    neg = 1;
    x = -xx;
 6b0:	f7 da                	neg    %edx
    neg = 1;
 6b2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 6b9:	be 00 00 00 00       	mov    $0x0,%esi
 6be:	eb 0b                	jmp    6cb <printint+0x36>
  neg = 0;
 6c0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 6c7:	eb f0                	jmp    6b9 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 6c9:	89 c6                	mov    %eax,%esi
 6cb:	89 d0                	mov    %edx,%eax
 6cd:	ba 00 00 00 00       	mov    $0x0,%edx
 6d2:	f7 f1                	div    %ecx
 6d4:	89 c3                	mov    %eax,%ebx
 6d6:	8d 46 01             	lea    0x1(%esi),%eax
 6d9:	0f b6 92 90 0c 00 00 	movzbl 0xc90(%edx),%edx
 6e0:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 6e4:	89 da                	mov    %ebx,%edx
 6e6:	85 db                	test   %ebx,%ebx
 6e8:	75 df                	jne    6c9 <printint+0x34>
 6ea:	89 c3                	mov    %eax,%ebx
  if(neg)
 6ec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 6f0:	74 16                	je     708 <printint+0x73>
    buf[i++] = '-';
 6f2:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 6f7:	8d 5e 02             	lea    0x2(%esi),%ebx
 6fa:	eb 0c                	jmp    708 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 6fc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 701:	89 f8                	mov    %edi,%eax
 703:	e8 73 ff ff ff       	call   67b <putc>
  while(--i >= 0)
 708:	83 eb 01             	sub    $0x1,%ebx
 70b:	79 ef                	jns    6fc <printint+0x67>
}
 70d:	83 c4 2c             	add    $0x2c,%esp
 710:	5b                   	pop    %ebx
 711:	5e                   	pop    %esi
 712:	5f                   	pop    %edi
 713:	5d                   	pop    %ebp
 714:	c3                   	ret    

00000715 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 715:	55                   	push   %ebp
 716:	89 e5                	mov    %esp,%ebp
 718:	57                   	push   %edi
 719:	56                   	push   %esi
 71a:	53                   	push   %ebx
 71b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 71e:	8d 45 10             	lea    0x10(%ebp),%eax
 721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 724:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 729:	bb 00 00 00 00       	mov    $0x0,%ebx
 72e:	eb 14                	jmp    744 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 730:	89 fa                	mov    %edi,%edx
 732:	8b 45 08             	mov    0x8(%ebp),%eax
 735:	e8 41 ff ff ff       	call   67b <putc>
 73a:	eb 05                	jmp    741 <printf+0x2c>
      }
    } else if(state == '%'){
 73c:	83 fe 25             	cmp    $0x25,%esi
 73f:	74 25                	je     766 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 741:	83 c3 01             	add    $0x1,%ebx
 744:	8b 45 0c             	mov    0xc(%ebp),%eax
 747:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 74b:	84 c0                	test   %al,%al
 74d:	0f 84 23 01 00 00    	je     876 <printf+0x161>
    c = fmt[i] & 0xff;
 753:	0f be f8             	movsbl %al,%edi
 756:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 759:	85 f6                	test   %esi,%esi
 75b:	75 df                	jne    73c <printf+0x27>
      if(c == '%'){
 75d:	83 f8 25             	cmp    $0x25,%eax
 760:	75 ce                	jne    730 <printf+0x1b>
        state = '%';
 762:	89 c6                	mov    %eax,%esi
 764:	eb db                	jmp    741 <printf+0x2c>
      if(c == 'd'){
 766:	83 f8 64             	cmp    $0x64,%eax
 769:	74 49                	je     7b4 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 76b:	83 f8 78             	cmp    $0x78,%eax
 76e:	0f 94 c1             	sete   %cl
 771:	83 f8 70             	cmp    $0x70,%eax
 774:	0f 94 c2             	sete   %dl
 777:	08 d1                	or     %dl,%cl
 779:	75 63                	jne    7de <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 77b:	83 f8 73             	cmp    $0x73,%eax
 77e:	0f 84 84 00 00 00    	je     808 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 784:	83 f8 63             	cmp    $0x63,%eax
 787:	0f 84 b7 00 00 00    	je     844 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 78d:	83 f8 25             	cmp    $0x25,%eax
 790:	0f 84 cc 00 00 00    	je     862 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 796:	ba 25 00 00 00       	mov    $0x25,%edx
 79b:	8b 45 08             	mov    0x8(%ebp),%eax
 79e:	e8 d8 fe ff ff       	call   67b <putc>
        putc(fd, c);
 7a3:	89 fa                	mov    %edi,%edx
 7a5:	8b 45 08             	mov    0x8(%ebp),%eax
 7a8:	e8 ce fe ff ff       	call   67b <putc>
      }
      state = 0;
 7ad:	be 00 00 00 00       	mov    $0x0,%esi
 7b2:	eb 8d                	jmp    741 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 7b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 7b7:	8b 17                	mov    (%edi),%edx
 7b9:	83 ec 0c             	sub    $0xc,%esp
 7bc:	6a 01                	push   $0x1
 7be:	b9 0a 00 00 00       	mov    $0xa,%ecx
 7c3:	8b 45 08             	mov    0x8(%ebp),%eax
 7c6:	e8 ca fe ff ff       	call   695 <printint>
        ap++;
 7cb:	83 c7 04             	add    $0x4,%edi
 7ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 7d1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 7d4:	be 00 00 00 00       	mov    $0x0,%esi
 7d9:	e9 63 ff ff ff       	jmp    741 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 7de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 7e1:	8b 17                	mov    (%edi),%edx
 7e3:	83 ec 0c             	sub    $0xc,%esp
 7e6:	6a 00                	push   $0x0
 7e8:	b9 10 00 00 00       	mov    $0x10,%ecx
 7ed:	8b 45 08             	mov    0x8(%ebp),%eax
 7f0:	e8 a0 fe ff ff       	call   695 <printint>
        ap++;
 7f5:	83 c7 04             	add    $0x4,%edi
 7f8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 7fb:	83 c4 10             	add    $0x10,%esp
      state = 0;
 7fe:	be 00 00 00 00       	mov    $0x0,%esi
 803:	e9 39 ff ff ff       	jmp    741 <printf+0x2c>
        s = (char*)*ap;
 808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80b:	8b 30                	mov    (%eax),%esi
        ap++;
 80d:	83 c0 04             	add    $0x4,%eax
 810:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 813:	85 f6                	test   %esi,%esi
 815:	75 28                	jne    83f <printf+0x12a>
          s = "(null)";
 817:	be 88 0c 00 00       	mov    $0xc88,%esi
 81c:	8b 7d 08             	mov    0x8(%ebp),%edi
 81f:	eb 0d                	jmp    82e <printf+0x119>
          putc(fd, *s);
 821:	0f be d2             	movsbl %dl,%edx
 824:	89 f8                	mov    %edi,%eax
 826:	e8 50 fe ff ff       	call   67b <putc>
          s++;
 82b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 82e:	0f b6 16             	movzbl (%esi),%edx
 831:	84 d2                	test   %dl,%dl
 833:	75 ec                	jne    821 <printf+0x10c>
      state = 0;
 835:	be 00 00 00 00       	mov    $0x0,%esi
 83a:	e9 02 ff ff ff       	jmp    741 <printf+0x2c>
 83f:	8b 7d 08             	mov    0x8(%ebp),%edi
 842:	eb ea                	jmp    82e <printf+0x119>
        putc(fd, *ap);
 844:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 847:	0f be 17             	movsbl (%edi),%edx
 84a:	8b 45 08             	mov    0x8(%ebp),%eax
 84d:	e8 29 fe ff ff       	call   67b <putc>
        ap++;
 852:	83 c7 04             	add    $0x4,%edi
 855:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 858:	be 00 00 00 00       	mov    $0x0,%esi
 85d:	e9 df fe ff ff       	jmp    741 <printf+0x2c>
        putc(fd, c);
 862:	89 fa                	mov    %edi,%edx
 864:	8b 45 08             	mov    0x8(%ebp),%eax
 867:	e8 0f fe ff ff       	call   67b <putc>
      state = 0;
 86c:	be 00 00 00 00       	mov    $0x0,%esi
 871:	e9 cb fe ff ff       	jmp    741 <printf+0x2c>
    }
  }
}
 876:	8d 65 f4             	lea    -0xc(%ebp),%esp
 879:	5b                   	pop    %ebx
 87a:	5e                   	pop    %esi
 87b:	5f                   	pop    %edi
 87c:	5d                   	pop    %ebp
 87d:	c3                   	ret    

0000087e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87e:	55                   	push   %ebp
 87f:	89 e5                	mov    %esp,%ebp
 881:	57                   	push   %edi
 882:	56                   	push   %esi
 883:	53                   	push   %ebx
 884:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 887:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88a:	a1 00 10 00 00       	mov    0x1000,%eax
 88f:	eb 02                	jmp    893 <free+0x15>
 891:	89 d0                	mov    %edx,%eax
 893:	39 c8                	cmp    %ecx,%eax
 895:	73 04                	jae    89b <free+0x1d>
 897:	39 08                	cmp    %ecx,(%eax)
 899:	77 12                	ja     8ad <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89b:	8b 10                	mov    (%eax),%edx
 89d:	39 c2                	cmp    %eax,%edx
 89f:	77 f0                	ja     891 <free+0x13>
 8a1:	39 c8                	cmp    %ecx,%eax
 8a3:	72 08                	jb     8ad <free+0x2f>
 8a5:	39 ca                	cmp    %ecx,%edx
 8a7:	77 04                	ja     8ad <free+0x2f>
 8a9:	89 d0                	mov    %edx,%eax
 8ab:	eb e6                	jmp    893 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ad:	8b 73 fc             	mov    -0x4(%ebx),%esi
 8b0:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 8b3:	8b 10                	mov    (%eax),%edx
 8b5:	39 d7                	cmp    %edx,%edi
 8b7:	74 19                	je     8d2 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 8b9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 8bc:	8b 50 04             	mov    0x4(%eax),%edx
 8bf:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8c2:	39 ce                	cmp    %ecx,%esi
 8c4:	74 1b                	je     8e1 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 8c6:	89 08                	mov    %ecx,(%eax)
  freep = p;
 8c8:	a3 00 10 00 00       	mov    %eax,0x1000
}
 8cd:	5b                   	pop    %ebx
 8ce:	5e                   	pop    %esi
 8cf:	5f                   	pop    %edi
 8d0:	5d                   	pop    %ebp
 8d1:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 8d2:	03 72 04             	add    0x4(%edx),%esi
 8d5:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d8:	8b 10                	mov    (%eax),%edx
 8da:	8b 12                	mov    (%edx),%edx
 8dc:	89 53 f8             	mov    %edx,-0x8(%ebx)
 8df:	eb db                	jmp    8bc <free+0x3e>
    p->s.size += bp->s.size;
 8e1:	03 53 fc             	add    -0x4(%ebx),%edx
 8e4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e7:	8b 53 f8             	mov    -0x8(%ebx),%edx
 8ea:	89 10                	mov    %edx,(%eax)
 8ec:	eb da                	jmp    8c8 <free+0x4a>

000008ee <morecore>:

static Header*
morecore(uint nu)
{
 8ee:	55                   	push   %ebp
 8ef:	89 e5                	mov    %esp,%ebp
 8f1:	53                   	push   %ebx
 8f2:	83 ec 04             	sub    $0x4,%esp
 8f5:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 8f7:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 8fc:	77 05                	ja     903 <morecore+0x15>
    nu = 4096;
 8fe:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 903:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 90a:	83 ec 0c             	sub    $0xc,%esp
 90d:	50                   	push   %eax
 90e:	e8 20 fd ff ff       	call   633 <sbrk>
  if(p == (char*)-1)
 913:	83 c4 10             	add    $0x10,%esp
 916:	83 f8 ff             	cmp    $0xffffffff,%eax
 919:	74 1c                	je     937 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 91b:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 91e:	83 c0 08             	add    $0x8,%eax
 921:	83 ec 0c             	sub    $0xc,%esp
 924:	50                   	push   %eax
 925:	e8 54 ff ff ff       	call   87e <free>
  return freep;
 92a:	a1 00 10 00 00       	mov    0x1000,%eax
 92f:	83 c4 10             	add    $0x10,%esp
}
 932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 935:	c9                   	leave  
 936:	c3                   	ret    
    return 0;
 937:	b8 00 00 00 00       	mov    $0x0,%eax
 93c:	eb f4                	jmp    932 <morecore+0x44>

0000093e <malloc>:

void*
malloc(uint nbytes)
{
 93e:	55                   	push   %ebp
 93f:	89 e5                	mov    %esp,%ebp
 941:	53                   	push   %ebx
 942:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 945:	8b 45 08             	mov    0x8(%ebp),%eax
 948:	8d 58 07             	lea    0x7(%eax),%ebx
 94b:	c1 eb 03             	shr    $0x3,%ebx
 94e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 951:	8b 0d 00 10 00 00    	mov    0x1000,%ecx
 957:	85 c9                	test   %ecx,%ecx
 959:	74 04                	je     95f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95b:	8b 01                	mov    (%ecx),%eax
 95d:	eb 4d                	jmp    9ac <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 95f:	c7 05 00 10 00 00 04 	movl   $0x1004,0x1000
 966:	10 00 00 
 969:	c7 05 04 10 00 00 04 	movl   $0x1004,0x1004
 970:	10 00 00 
    base.s.size = 0;
 973:	c7 05 08 10 00 00 00 	movl   $0x0,0x1008
 97a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 97d:	b9 04 10 00 00       	mov    $0x1004,%ecx
 982:	eb d7                	jmp    95b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 984:	39 da                	cmp    %ebx,%edx
 986:	74 1a                	je     9a2 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 988:	29 da                	sub    %ebx,%edx
 98a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 98d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 990:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 993:	89 0d 00 10 00 00    	mov    %ecx,0x1000
      return (void*)(p + 1);
 999:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 99c:	83 c4 04             	add    $0x4,%esp
 99f:	5b                   	pop    %ebx
 9a0:	5d                   	pop    %ebp
 9a1:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 9a2:	8b 10                	mov    (%eax),%edx
 9a4:	89 11                	mov    %edx,(%ecx)
 9a6:	eb eb                	jmp    993 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	89 c1                	mov    %eax,%ecx
 9aa:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 9ac:	8b 50 04             	mov    0x4(%eax),%edx
 9af:	39 da                	cmp    %ebx,%edx
 9b1:	73 d1                	jae    984 <malloc+0x46>
    if(p == freep)
 9b3:	39 05 00 10 00 00    	cmp    %eax,0x1000
 9b9:	75 ed                	jne    9a8 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 9bb:	89 d8                	mov    %ebx,%eax
 9bd:	e8 2c ff ff ff       	call   8ee <morecore>
 9c2:	85 c0                	test   %eax,%eax
 9c4:	75 e2                	jne    9a8 <malloc+0x6a>
        return 0;
 9c6:	b8 00 00 00 00       	mov    $0x0,%eax
 9cb:	eb cf                	jmp    99c <malloc+0x5e>
