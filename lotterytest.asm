
_lotterytest:     file format elf32-i386


Disassembly of section .text:

00000000 <run_forever>:
        yield();
    }
}

__attribute__((noreturn))
void run_forever() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
    while (1) {
        __asm__("");
   3:	eb fe                	jmp    3 <run_forever+0x3>

00000005 <yield_forever>:
void yield_forever() {
   5:	55                   	push   %ebp
   6:	89 e5                	mov    %esp,%ebp
   8:	83 ec 08             	sub    $0x8,%esp
        yield();
   b:	e8 04 0b 00 00       	call   b14 <yield>
  10:	eb f9                	jmp    b <yield_forever+0x6>

00000012 <iowait_forever>:
    }
}

__attribute__((noreturn))
void iowait_forever() {
  12:	55                   	push   %ebp
  13:	89 e5                	mov    %esp,%ebp
  15:	83 ec 24             	sub    $0x24,%esp
    int fds[2];
    pipe(fds);
  18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1b:	50                   	push   %eax
  1c:	e8 63 0a 00 00       	call   a84 <pipe>
  21:	83 c4 10             	add    $0x10,%esp
    while (1) {
        char temp[1];
        read(fds[0], temp, 0);
  24:	83 ec 04             	sub    $0x4,%esp
  27:	6a 00                	push   $0x0
  29:	8d 45 ef             	lea    -0x11(%ebp),%eax
  2c:	50                   	push   %eax
  2d:	ff 75 f0             	pushl  -0x10(%ebp)
  30:	e8 57 0a 00 00       	call   a8c <read>
  35:	83 c4 10             	add    $0x10,%esp
  38:	eb ea                	jmp    24 <iowait_forever+0x12>

0000003a <exit_fast>:
    }
}

__attribute__((noreturn))
void exit_fast() {
  3a:	55                   	push   %ebp
  3b:	89 e5                	mov    %esp,%ebp
  3d:	83 ec 08             	sub    $0x8,%esp
    exit();
  40:	e8 2f 0a 00 00       	call   a74 <exit>

00000045 <spawn>:
}


int spawn(int tickets, function_type function) {
  45:	55                   	push   %ebp
  46:	89 e5                	mov    %esp,%ebp
  48:	53                   	push   %ebx
  49:	83 ec 04             	sub    $0x4,%esp
    int pid = fork();
  4c:	e8 1b 0a 00 00       	call   a6c <fork>
    if (pid == 0) {
  51:	85 c0                	test   %eax,%eax
  53:	74 0e                	je     63 <spawn+0x1e>
  55:	89 c3                	mov    %eax,%ebx
        settickets(tickets);
        yield();
        (*function)();
        exit();
    } else if (pid != -1) {
  57:	83 f8 ff             	cmp    $0xffffffff,%eax
  5a:	74 1f                	je     7b <spawn+0x36>
        return pid;
    } else {
        printf(2, "error in fork\n");
        return -1;
    }
}
  5c:	89 d8                	mov    %ebx,%eax
  5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  61:	c9                   	leave  
  62:	c3                   	ret    
        settickets(tickets);
  63:	83 ec 0c             	sub    $0xc,%esp
  66:	ff 75 08             	pushl  0x8(%ebp)
  69:	e8 c6 0a 00 00       	call   b34 <settickets>
        yield();
  6e:	e8 a1 0a 00 00       	call   b14 <yield>
        (*function)();
  73:	ff 55 0c             	call   *0xc(%ebp)
        exit();
  76:	e8 f9 09 00 00       	call   a74 <exit>
        printf(2, "error in fork\n");
  7b:	83 ec 08             	sub    $0x8,%esp
  7e:	68 00 10 00 00       	push   $0x1000
  83:	6a 02                	push   $0x2
  85:	e8 54 0b 00 00       	call   bde <printf>
        return -1;
  8a:	83 c4 10             	add    $0x10,%esp
  8d:	eb cd                	jmp    5c <spawn+0x17>

0000008f <find_index_of_pid>:

int find_index_of_pid(int *list, int list_size, int pid) {
  8f:	55                   	push   %ebp
  90:	89 e5                	mov    %esp,%ebp
  92:	53                   	push   %ebx
  93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  96:	8b 55 0c             	mov    0xc(%ebp),%edx
  99:	8b 4d 10             	mov    0x10(%ebp),%ecx
    for (int i = 0; i < list_size; ++i) {
  9c:	b8 00 00 00 00       	mov    $0x0,%eax
  a1:	39 d0                	cmp    %edx,%eax
  a3:	7d 0a                	jge    af <find_index_of_pid+0x20>
        if (list[i] == pid)
  a5:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  a8:	74 0a                	je     b4 <find_index_of_pid+0x25>
    for (int i = 0; i < list_size; ++i) {
  aa:	83 c0 01             	add    $0x1,%eax
  ad:	eb f2                	jmp    a1 <find_index_of_pid+0x12>
            return i;
    }
    return -1;
  af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  b4:	5b                   	pop    %ebx
  b5:	5d                   	pop    %ebp
  b6:	c3                   	ret    

000000b7 <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  b7:	55                   	push   %ebp
  b8:	89 e5                	mov    %esp,%ebp
  ba:	57                   	push   %edi
  bb:	56                   	push   %esi
  bc:	53                   	push   %ebx
  bd:	81 ec 38 03 00 00    	sub    $0x338,%esp
  c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  c6:	8b 7d 10             	mov    0x10(%ebp),%edi
    /* temporarily lower our share to give other processes more of a chance to run
     * their settickets() call */
    settickets(NOT_AS_LARGE_TICKET_COUNT);
  c9:	68 10 27 00 00       	push   $0x2710
  ce:	e8 61 0a 00 00       	call   b34 <settickets>
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  d3:	83 c4 10             	add    $0x10,%esp
  d6:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  dd:	00 00 00 
  e0:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
  e7:	7f 6c                	jg     155 <wait_for_ticket_counts+0x9e>
        yield();
  e9:	e8 26 0a 00 00       	call   b14 <yield>
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
  ee:	83 ec 0c             	sub    $0xc,%esp
  f1:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  f7:	50                   	push   %eax
  f8:	e8 3f 0a 00 00       	call   b3c <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  fd:	83 c4 10             	add    $0x10,%esp
 100:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
 105:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
 10c:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
 10f:	eb 03                	jmp    114 <wait_for_ticket_counts+0x5d>
 111:	83 c3 01             	add    $0x1,%ebx
 114:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 117:	7d 33                	jge    14c <wait_for_ticket_counts+0x95>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
 119:	83 ec 04             	sub    $0x4,%esp
 11c:	ff 34 9e             	pushl  (%esi,%ebx,4)
 11f:	ff b5 e4 fc ff ff    	pushl  -0x31c(%ebp)
 125:	8d 85 e8 fc ff ff    	lea    -0x318(%ebp),%eax
 12b:	50                   	push   %eax
 12c:	e8 5e ff ff ff       	call   8f <find_index_of_pid>
 131:	83 c4 10             	add    $0x10,%esp
            if (info.tickets[index] != tickets[i]) done = 0;
 134:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
 137:	39 94 85 e8 fe ff ff 	cmp    %edx,-0x118(%ebp,%eax,4)
 13e:	74 d1                	je     111 <wait_for_ticket_counts+0x5a>
 140:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
 147:	00 00 00 
 14a:	eb c5                	jmp    111 <wait_for_ticket_counts+0x5a>
        }
        if (done)
 14c:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 153:	74 18                	je     16d <wait_for_ticket_counts+0xb6>
            break;
    }
    settickets(LARGE_TICKET_COUNT);
 155:	83 ec 0c             	sub    $0xc,%esp
 158:	68 a0 86 01 00       	push   $0x186a0
 15d:	e8 d2 09 00 00       	call   b34 <settickets>
}
 162:	83 c4 10             	add    $0x10,%esp
 165:	8d 65 f4             	lea    -0xc(%ebp),%esp
 168:	5b                   	pop    %ebx
 169:	5e                   	pop    %esi
 16a:	5f                   	pop    %edi
 16b:	5d                   	pop    %ebp
 16c:	c3                   	ret    
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 16d:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 174:	e9 67 ff ff ff       	jmp    e0 <wait_for_ticket_counts+0x29>

00000179 <check>:

void check(struct test_case* test, int passed_p, const char *description) {
 179:	55                   	push   %ebp
 17a:	89 e5                	mov    %esp,%ebp
 17c:	83 ec 08             	sub    $0x8,%esp
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
    test->total_tests++;
 182:	8b 48 04             	mov    0x4(%eax),%ecx
 185:	8d 51 01             	lea    0x1(%ecx),%edx
 188:	89 50 04             	mov    %edx,0x4(%eax)
    if (!passed_p) {
 18b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 18f:	74 02                	je     193 <check+0x1a>
        test->errors++;
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
    }
}
 191:	c9                   	leave  
 192:	c3                   	ret    
        test->errors++;
 193:	8b 48 08             	mov    0x8(%eax),%ecx
 196:	8d 51 01             	lea    0x1(%ecx),%edx
 199:	89 50 08             	mov    %edx,0x8(%eax)
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
 19c:	ff 75 10             	pushl  0x10(%ebp)
 19f:	ff 30                	pushl  (%eax)
 1a1:	68 e4 10 00 00       	push   $0x10e4
 1a6:	6a 01                	push   $0x1
 1a8:	e8 31 0a 00 00       	call   bde <printf>
 1ad:	83 c4 10             	add    $0x10,%esp
}
 1b0:	eb df                	jmp    191 <check+0x18>

000001b2 <execute_and_get_info>:

void execute_and_get_info(
        struct test_case* test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	57                   	push   %edi
 1b6:	56                   	push   %esi
 1b7:	53                   	push   %ebx
 1b8:	83 ec 18             	sub    $0x18,%esp
 1bb:	8b 75 08             	mov    0x8(%ebp),%esi
    settickets(LARGE_TICKET_COUNT);
 1be:	68 a0 86 01 00       	push   $0x186a0
 1c3:	e8 6c 09 00 00       	call   b34 <settickets>
    for (int i = 0; i < test->num_children; ++i) {
 1c8:	83 c4 10             	add    $0x10,%esp
 1cb:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d0:	eb 21                	jmp    1f3 <execute_and_get_info+0x41>
        pids[i] = spawn(test->tickets[i], test->functions[i]);
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 1d8:	83 ec 08             	sub    $0x8,%esp
 1db:	ff b4 9e 94 01 00 00 	pushl  0x194(%esi,%ebx,4)
 1e2:	ff 74 9e 10          	pushl  0x10(%esi,%ebx,4)
 1e6:	e8 5a fe ff ff       	call   45 <spawn>
 1eb:	89 07                	mov    %eax,(%edi)
    for (int i = 0; i < test->num_children; ++i) {
 1ed:	83 c3 01             	add    $0x1,%ebx
 1f0:	83 c4 10             	add    $0x10,%esp
 1f3:	8b 46 0c             	mov    0xc(%esi),%eax
 1f6:	39 d8                	cmp    %ebx,%eax
 1f8:	7f d8                	jg     1d2 <execute_and_get_info+0x20>
    }
    wait_for_ticket_counts(test->num_children, pids, test->tickets);
 1fa:	8d 56 10             	lea    0x10(%esi),%edx
 1fd:	83 ec 04             	sub    $0x4,%esp
 200:	52                   	push   %edx
 201:	ff 75 0c             	pushl  0xc(%ebp)
 204:	50                   	push   %eax
 205:	e8 ad fe ff ff       	call   b7 <wait_for_ticket_counts>
    before->num_processes = after->num_processes = -1;
 20a:	8b 45 14             	mov    0x14(%ebp),%eax
 20d:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
 213:	8b 45 10             	mov    0x10(%ebp),%eax
 216:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    sleep(WARMUP_TIME);
 21c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
 223:	e8 dc 08 00 00       	call   b04 <sleep>
    getprocessesinfo(before);
 228:	83 c4 04             	add    $0x4,%esp
 22b:	ff 75 10             	pushl  0x10(%ebp)
 22e:	e8 09 09 00 00       	call   b3c <getprocessesinfo>
    sleep(SLEEP_TIME);
 233:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 23a:	e8 c5 08 00 00       	call   b04 <sleep>
    getprocessesinfo(after);
 23f:	83 c4 04             	add    $0x4,%esp
 242:	ff 75 14             	pushl  0x14(%ebp)
 245:	e8 f2 08 00 00       	call   b3c <getprocessesinfo>
    for (int i = 0; i < test->num_children; ++i) {
 24a:	83 c4 10             	add    $0x10,%esp
 24d:	bb 00 00 00 00       	mov    $0x0,%ebx
 252:	8b 7d 0c             	mov    0xc(%ebp),%edi
 255:	eb 11                	jmp    268 <execute_and_get_info+0xb6>
        kill(pids[i]);
 257:	83 ec 0c             	sub    $0xc,%esp
 25a:	ff 34 9f             	pushl  (%edi,%ebx,4)
 25d:	e8 42 08 00 00       	call   aa4 <kill>
    for (int i = 0; i < test->num_children; ++i) {
 262:	83 c3 01             	add    $0x1,%ebx
 265:	83 c4 10             	add    $0x10,%esp
 268:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 26b:	7f ea                	jg     257 <execute_and_get_info+0xa5>
    }
    for (int i = 0; i < test->num_children; ++i) {
 26d:	bb 00 00 00 00       	mov    $0x0,%ebx
 272:	eb 08                	jmp    27c <execute_and_get_info+0xca>
        wait();
 274:	e8 03 08 00 00       	call   a7c <wait>
    for (int i = 0; i < test->num_children; ++i) {
 279:	83 c3 01             	add    $0x1,%ebx
 27c:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 27f:	7f f3                	jg     274 <execute_and_get_info+0xc2>
    }
}
 281:	8d 65 f4             	lea    -0xc(%ebp),%esp
 284:	5b                   	pop    %ebx
 285:	5e                   	pop    %esi
 286:	5f                   	pop    %edi
 287:	5d                   	pop    %ebp
 288:	c3                   	ret    

00000289 <count_schedules>:

void count_schedules(
        struct test_case *test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	57                   	push   %edi
 28d:	56                   	push   %esi
 28e:	53                   	push   %ebx
 28f:	83 ec 1c             	sub    $0x1c,%esp
 292:	8b 75 08             	mov    0x8(%ebp),%esi
    test->total_actual_schedules = 0;
 295:	c7 86 90 01 00 00 00 	movl   $0x0,0x190(%esi)
 29c:	00 00 00 
    for (int i = 0; i < test->num_children; ++i) {
 29f:	bf 00 00 00 00       	mov    $0x0,%edi
 2a4:	eb 54                	jmp    2fa <count_schedules+0x71>
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
        check(test,
              before_index >= 0 && after_index >= 0,
              "subprocess's pid appeared in getprocessesinfo output");
        if (before_index >= 0 && after_index >= 0) {
            check(test,
 2a6:	8b 55 14             	mov    0x14(%ebp),%edx
 2a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 2ac:	3b 84 8a 04 02 00 00 	cmp    0x204(%edx,%ecx,4),%eax
 2b3:	0f 84 c9 00 00 00    	je     382 <count_schedules+0xf9>
 2b9:	b8 00 00 00 00       	mov    $0x0,%eax
 2be:	83 ec 04             	sub    $0x4,%esp
 2c1:	68 48 11 00 00       	push   $0x1148
 2c6:	50                   	push   %eax
 2c7:	56                   	push   %esi
 2c8:	e8 ac fe ff ff       	call   179 <check>
                  test->tickets[i] == before->tickets[before_index] &&
                  test->tickets[i] == after->tickets[after_index],
                  "subprocess assigned correct number of tickets");
            test->actual_schedules[i] = after->times_scheduled[after_index] - before->times_scheduled[before_index];
 2cd:	8b 45 14             	mov    0x14(%ebp),%eax
 2d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 2d3:	8b 84 88 04 01 00 00 	mov    0x104(%eax,%ecx,4),%eax
 2da:	8b 55 10             	mov    0x10(%ebp),%edx
 2dd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 2e0:	2b 84 8a 04 01 00 00 	sub    0x104(%edx,%ecx,4),%eax
 2e7:	89 84 be 10 01 00 00 	mov    %eax,0x110(%esi,%edi,4)
            test->total_actual_schedules += test->actual_schedules[i];
 2ee:	01 86 90 01 00 00    	add    %eax,0x190(%esi)
 2f4:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < test->num_children; ++i) {
 2f7:	83 c7 01             	add    $0x1,%edi
 2fa:	39 7e 0c             	cmp    %edi,0xc(%esi)
 2fd:	0f 8e 99 00 00 00    	jle    39c <count_schedules+0x113>
        int before_index = find_index_of_pid(before->pids, before->num_processes, pids[i]);
 303:	8b 45 0c             	mov    0xc(%ebp),%eax
 306:	8b 1c b8             	mov    (%eax,%edi,4),%ebx
 309:	8b 45 10             	mov    0x10(%ebp),%eax
 30c:	83 c0 04             	add    $0x4,%eax
 30f:	53                   	push   %ebx
 310:	8b 4d 10             	mov    0x10(%ebp),%ecx
 313:	ff 31                	pushl  (%ecx)
 315:	50                   	push   %eax
 316:	e8 74 fd ff ff       	call   8f <find_index_of_pid>
 31b:	83 c4 0c             	add    $0xc,%esp
 31e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
 321:	8b 4d 14             	mov    0x14(%ebp),%ecx
 324:	8d 41 04             	lea    0x4(%ecx),%eax
 327:	53                   	push   %ebx
 328:	ff 31                	pushl  (%ecx)
 32a:	50                   	push   %eax
 32b:	e8 5f fd ff ff       	call   8f <find_index_of_pid>
 330:	83 c4 08             	add    $0x8,%esp
 333:	89 c2                	mov    %eax,%edx
 335:	89 45 e0             	mov    %eax,-0x20(%ebp)
              before_index >= 0 && after_index >= 0,
 338:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 33b:	f7 d3                	not    %ebx
 33d:	89 d8                	mov    %ebx,%eax
 33f:	c1 e8 1f             	shr    $0x1f,%eax
 342:	f7 d2                	not    %edx
 344:	89 d3                	mov    %edx,%ebx
 346:	c1 eb 1f             	shr    $0x1f,%ebx
        check(test,
 349:	21 c3                	and    %eax,%ebx
 34b:	68 10 11 00 00       	push   $0x1110
 350:	0f b6 c3             	movzbl %bl,%eax
 353:	50                   	push   %eax
 354:	56                   	push   %esi
 355:	e8 1f fe ff ff       	call   179 <check>
        if (before_index >= 0 && after_index >= 0) {
 35a:	83 c4 10             	add    $0x10,%esp
 35d:	84 db                	test   %bl,%bl
 35f:	74 2b                	je     38c <count_schedules+0x103>
                  test->tickets[i] == before->tickets[before_index] &&
 361:	8b 44 be 10          	mov    0x10(%esi,%edi,4),%eax
            check(test,
 365:	8b 55 10             	mov    0x10(%ebp),%edx
 368:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 36b:	3b 84 9a 04 02 00 00 	cmp    0x204(%edx,%ebx,4),%eax
 372:	0f 84 2e ff ff ff    	je     2a6 <count_schedules+0x1d>
 378:	b8 00 00 00 00       	mov    $0x0,%eax
 37d:	e9 3c ff ff ff       	jmp    2be <count_schedules+0x35>
 382:	b8 01 00 00 00       	mov    $0x1,%eax
 387:	e9 32 ff ff ff       	jmp    2be <count_schedules+0x35>
        } else {
            test->actual_schedules[i] = -99999; // obviously bogus count that will fail checks later
 38c:	c7 84 be 10 01 00 00 	movl   $0xfffe7961,0x110(%esi,%edi,4)
 393:	61 79 fe ff 
 397:	e9 5b ff ff ff       	jmp    2f7 <count_schedules+0x6e>
        }
    }
}
 39c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 39f:	5b                   	pop    %ebx
 3a0:	5e                   	pop    %esi
 3a1:	5f                   	pop    %edi
 3a2:	5d                   	pop    %ebp
 3a3:	c3                   	ret    

000003a4 <dump_test_timings>:

void dump_test_timings(struct test_case *test) {
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
 3a7:	56                   	push   %esi
 3a8:	53                   	push   %ebx
 3a9:	8b 75 08             	mov    0x8(%ebp),%esi
    printf(1, "-----------------------------------------\n");
 3ac:	83 ec 08             	sub    $0x8,%esp
 3af:	68 78 11 00 00       	push   $0x1178
 3b4:	6a 01                	push   $0x1
 3b6:	e8 23 08 00 00       	call   bde <printf>
    printf(1, "%s expected schedules ratios and observations\n", test->name);
 3bb:	83 c4 0c             	add    $0xc,%esp
 3be:	ff 36                	pushl  (%esi)
 3c0:	68 a4 11 00 00       	push   $0x11a4
 3c5:	6a 01                	push   $0x1
 3c7:	e8 12 08 00 00       	call   bde <printf>
    printf(1, "#\texpect\tobserve\t(description)\n");
 3cc:	83 c4 08             	add    $0x8,%esp
 3cf:	68 d4 11 00 00       	push   $0x11d4
 3d4:	6a 01                	push   $0x1
 3d6:	e8 03 08 00 00       	call   bde <printf>
    for (int i = 0; i < test->num_children; ++i) {
 3db:	83 c4 10             	add    $0x10,%esp
 3de:	bb 00 00 00 00       	mov    $0x0,%ebx
 3e3:	eb 2e                	jmp    413 <dump_test_timings+0x6f>
        const char *assigned_function = "(unknown)";
        if (test->functions[i] == yield_forever) {
            assigned_function = "yield_forever";
 3e5:	b8 0f 10 00 00       	mov    $0x100f,%eax
        } else if (test->functions[i] == iowait_forever) {
            assigned_function = "iowait_forever";
        } else if (test->functions[i] == exit_fast) {
            assigned_function = "exit_fast";
        }
        printf(1, "%d\t%d\t%d\t(assigned %d tickets; running %s)\n",
 3ea:	83 ec 04             	sub    $0x4,%esp
 3ed:	50                   	push   %eax
 3ee:	ff 74 9e 10          	pushl  0x10(%esi,%ebx,4)
 3f2:	ff b4 9e 10 01 00 00 	pushl  0x110(%esi,%ebx,4)
 3f9:	ff b4 9e 90 00 00 00 	pushl  0x90(%esi,%ebx,4)
 400:	53                   	push   %ebx
 401:	68 f4 11 00 00       	push   $0x11f4
 406:	6a 01                	push   $0x1
 408:	e8 d1 07 00 00       	call   bde <printf>
    for (int i = 0; i < test->num_children; ++i) {
 40d:	83 c3 01             	add    $0x1,%ebx
 410:	83 c4 20             	add    $0x20,%esp
 413:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 416:	7e 3f                	jle    457 <dump_test_timings+0xb3>
        if (test->functions[i] == yield_forever) {
 418:	8b 84 9e 94 01 00 00 	mov    0x194(%esi,%ebx,4),%eax
 41f:	3d 05 00 00 00       	cmp    $0x5,%eax
 424:	74 bf                	je     3e5 <dump_test_timings+0x41>
        } else if (test->functions[i] == run_forever) {
 426:	3d 00 00 00 00       	cmp    $0x0,%eax
 42b:	74 15                	je     442 <dump_test_timings+0x9e>
        } else if (test->functions[i] == iowait_forever) {
 42d:	3d 12 00 00 00       	cmp    $0x12,%eax
 432:	74 15                	je     449 <dump_test_timings+0xa5>
        } else if (test->functions[i] == exit_fast) {
 434:	3d 3a 00 00 00       	cmp    $0x3a,%eax
 439:	74 15                	je     450 <dump_test_timings+0xac>
        const char *assigned_function = "(unknown)";
 43b:	b8 38 10 00 00       	mov    $0x1038,%eax
 440:	eb a8                	jmp    3ea <dump_test_timings+0x46>
            assigned_function = "run_forever";
 442:	b8 1d 10 00 00       	mov    $0x101d,%eax
 447:	eb a1                	jmp    3ea <dump_test_timings+0x46>
            assigned_function = "iowait_forever";
 449:	b8 29 10 00 00       	mov    $0x1029,%eax
 44e:	eb 9a                	jmp    3ea <dump_test_timings+0x46>
            assigned_function = "exit_fast";
 450:	b8 42 10 00 00       	mov    $0x1042,%eax
 455:	eb 93                	jmp    3ea <dump_test_timings+0x46>
            test->expect_schedules_unscaled[i],
            test->actual_schedules[i],
            test->tickets[i],
            assigned_function);
    }
    printf(1, "\nNOTE: the 'expect' values above represent the expected\n"
 457:	83 ec 08             	sub    $0x8,%esp
 45a:	68 20 12 00 00       	push   $0x1220
 45f:	6a 01                	push   $0x1
 461:	e8 78 07 00 00       	call   bde <printf>
              "      ratio of schedules between the processes. So, to compare\n"
              "      them to the observations by hand, multiply each expected\n"
              "      value by (sum of observed)/(sum of expected)\n");
    printf(1, "-----------------------------------------\n");
 466:	83 c4 08             	add    $0x8,%esp
 469:	68 78 11 00 00       	push   $0x1178
 46e:	6a 01                	push   $0x1
 470:	e8 69 07 00 00       	call   bde <printf>
}
 475:	83 c4 10             	add    $0x10,%esp
 478:	8d 65 f8             	lea    -0x8(%ebp),%esp
 47b:	5b                   	pop    %ebx
 47c:	5e                   	pop    %esi
 47d:	5d                   	pop    %ebp
 47e:	c3                   	ret    

0000047f <compare_schedules_chi_squared>:
    FIXED_POINT_BASE / 100 * 2612,
    FIXED_POINT_BASE / 100 * 2788,
    FIXED_POINT_BASE / 100 * 2959,
};

int compare_schedules_chi_squared(struct test_case *test) {
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	57                   	push   %edi
 483:	56                   	push   %esi
 484:	53                   	push   %ebx
 485:	83 ec 2c             	sub    $0x2c,%esp
 488:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (test->num_children < 2) {
 48b:	8b 5f 0c             	mov    0xc(%edi),%ebx
 48e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
 491:	83 fb 01             	cmp    $0x1,%ebx
 494:	0f 8e 95 01 00 00    	jle    62f <compare_schedules_chi_squared+0x1b0>
        return 1;
    }
    long long expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
 49a:	b9 00 00 00 00       	mov    $0x0,%ecx
    long long expect_schedules_total = 0;
 49f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 4a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 4ad:	eb 11                	jmp    4c0 <compare_schedules_chi_squared+0x41>
        expect_schedules_total += test->expect_schedules_unscaled[i];
 4af:	8b 84 8f 90 00 00 00 	mov    0x90(%edi,%ecx,4),%eax
 4b6:	99                   	cltd   
 4b7:	01 45 d8             	add    %eax,-0x28(%ebp)
 4ba:	11 55 dc             	adc    %edx,-0x24(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 4bd:	83 c1 01             	add    $0x1,%ecx
 4c0:	39 cb                	cmp    %ecx,%ebx
 4c2:	7f eb                	jg     4af <compare_schedules_chi_squared+0x30>
       a better solution would be to use a statistical test that can handle this case,
       like Fisher's exact test.
    */
    long long delta = 0;
    int skipped = 0;
    for (int i = 0; i < test->num_children; ++i) {
 4c4:	be 00 00 00 00       	mov    $0x0,%esi
    int skipped = 0;
 4c9:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
    long long delta = 0;
 4d0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 4d7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 4de:	eb 1f                	jmp    4ff <compare_schedules_chi_squared+0x80>
            (int)(scaled_expected >> FIXED_POINT_COUNT),
            (int) expect_schedules_total,
            test->total_actual_schedules);
#endif
        if (scaled_expected == 0) {
            ++skipped;
 4e0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
            continue;
 4e4:	eb 16                	jmp    4fc <compare_schedules_chi_squared+0x7d>
        printf(1, "delta before division [raw]     %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
        printf(1, "delta before division [rounded] %d\n", (int) (cur_delta >> FIXED_POINT_COUNT));
#endif
        if (scaled_expected > 0) {
            // cur_delta <<= FIXED_POINT_COUNT;
            cur_delta /= scaled_expected;
 4e6:	ff 75 e4             	pushl  -0x1c(%ebp)
 4e9:	ff 75 e0             	pushl  -0x20(%ebp)
 4ec:	52                   	push   %edx
 4ed:	50                   	push   %eax
 4ee:	e8 ad 09 00 00       	call   ea0 <__divdi3>
 4f3:	83 c4 10             	add    $0x10,%esp
            cur_delta = FIXED_POINT_BASE * 100000LL;
        }
#ifdef DEBUG
        printf(1, "cur_delta = %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
#endif
        delta += cur_delta;
 4f6:	01 45 c8             	add    %eax,-0x38(%ebp)
 4f9:	11 55 cc             	adc    %edx,-0x34(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 4fc:	83 c6 01             	add    $0x1,%esi
 4ff:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
 502:	0f 8e 93 00 00 00    	jle    59b <compare_schedules_chi_squared+0x11c>
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 508:	8b 84 b7 90 00 00 00 	mov    0x90(%edi,%esi,4),%eax
 50f:	c1 e0 0a             	shl    $0xa,%eax
 512:	99                   	cltd   
 513:	ff 75 dc             	pushl  -0x24(%ebp)
 516:	ff 75 d8             	pushl  -0x28(%ebp)
 519:	52                   	push   %edx
 51a:	50                   	push   %eax
 51b:	e8 80 09 00 00       	call   ea0 <__divdi3>
 520:	83 c4 10             	add    $0x10,%esp
                             * test->total_actual_schedules;
 523:	8b 8f 90 01 00 00    	mov    0x190(%edi),%ecx
 529:	89 cb                	mov    %ecx,%ebx
 52b:	c1 fb 1f             	sar    $0x1f,%ebx
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 52e:	0f af 97 90 01 00 00 	imul   0x190(%edi),%edx
 535:	89 d9                	mov    %ebx,%ecx
 537:	0f af c8             	imul   %eax,%ecx
 53a:	01 d1                	add    %edx,%ecx
 53c:	f7 a7 90 01 00 00    	mull   0x190(%edi)
 542:	89 45 e0             	mov    %eax,-0x20(%ebp)
 545:	01 d1                	add    %edx,%ecx
 547:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        if (scaled_expected == 0) {
 54a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 54d:	09 c1                	or     %eax,%ecx
 54f:	74 8f                	je     4e0 <compare_schedules_chi_squared+0x61>
        long long cur_delta = scaled_expected - (test->actual_schedules[i] << FIXED_POINT_COUNT);
 551:	8b 84 b7 10 01 00 00 	mov    0x110(%edi,%esi,4),%eax
 558:	c1 e0 0a             	shl    $0xa,%eax
 55b:	99                   	cltd   
 55c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 55f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 562:	29 c1                	sub    %eax,%ecx
 564:	19 d3                	sbb    %edx,%ebx
 566:	89 c8                	mov    %ecx,%eax
        cur_delta *= cur_delta;
 568:	0f af d9             	imul   %ecx,%ebx
 56b:	89 d9                	mov    %ebx,%ecx
 56d:	01 c9                	add    %ecx,%ecx
 56f:	f7 e0                	mul    %eax
 571:	01 ca                	add    %ecx,%edx
        if (scaled_expected > 0) {
 573:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 576:	85 db                	test   %ebx,%ebx
 578:	78 12                	js     58c <compare_schedules_chi_squared+0x10d>
 57a:	85 db                	test   %ebx,%ebx
 57c:	0f 8f 64 ff ff ff    	jg     4e6 <compare_schedules_chi_squared+0x67>
 582:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 586:	0f 87 5a ff ff ff    	ja     4e6 <compare_schedules_chi_squared+0x67>
            cur_delta = FIXED_POINT_BASE * 100000LL;
 58c:	b8 00 80 1a 06       	mov    $0x61a8000,%eax
 591:	ba 00 00 00 00       	mov    $0x0,%edx
 596:	e9 5b ff ff ff       	jmp    4f6 <compare_schedules_chi_squared+0x77>
    }
#ifdef DEBUG
    printf(1, "%s test statistic %d (rounded)\n", test->name, (int) ((delta + FIXED_POINT_BASE / 2) >> FIXED_POINT_COUNT));
#endif
    int degrees_of_freedom = test->num_children - 1 - skipped;
 59b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 59e:	83 e8 01             	sub    $0x1,%eax
 5a1:	2b 45 d0             	sub    -0x30(%ebp),%eax
    long long expected_value = chi_squared_thresholds[degrees_of_freedom - 1];
 5a4:	83 e8 01             	sub    $0x1,%eax
 5a7:	8b 0c c5 20 16 00 00 	mov    0x1620(,%eax,8),%ecx
 5ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 5b1:	8b 34 c5 24 16 00 00 	mov    0x1624(,%eax,8),%esi
    int passed_threshold = delta < expected_value;
 5b8:	bb 01 00 00 00       	mov    $0x1,%ebx
 5bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
 5c0:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5c3:	39 f2                	cmp    %esi,%edx
 5c5:	7c 0b                	jl     5d2 <compare_schedules_chi_squared+0x153>
 5c7:	7f 04                	jg     5cd <compare_schedules_chi_squared+0x14e>
 5c9:	39 c8                	cmp    %ecx,%eax
 5cb:	72 05                	jb     5d2 <compare_schedules_chi_squared+0x153>
 5cd:	bb 00 00 00 00       	mov    $0x0,%ebx
 5d2:	0f b6 db             	movzbl %bl,%ebx
    check(test, passed_threshold,
 5d5:	83 ec 04             	sub    $0x4,%esp
 5d8:	68 0c 13 00 00       	push   $0x130c
 5dd:	53                   	push   %ebx
 5de:	57                   	push   %edi
 5df:	e8 95 fb ff ff       	call   179 <check>
          "distribution of schedules run passed chi-squared test "
          "for being same as expected");
    if (!passed_threshold) {
 5e4:	83 c4 10             	add    $0x10,%esp
 5e7:	8b 45 c8             	mov    -0x38(%ebp),%eax
 5ea:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5ed:	39 f2                	cmp    %esi,%edx
 5ef:	7c 15                	jl     606 <compare_schedules_chi_squared+0x187>
 5f1:	7f 07                	jg     5fa <compare_schedules_chi_squared+0x17b>
 5f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
 5f6:	39 f0                	cmp    %esi,%eax
 5f8:	72 0c                	jb     606 <compare_schedules_chi_squared+0x187>
        dump_test_timings(test);
 5fa:	83 ec 0c             	sub    $0xc,%esp
 5fd:	57                   	push   %edi
 5fe:	e8 a1 fd ff ff       	call   3a4 <dump_test_timings>
 603:	83 c4 10             	add    $0x10,%esp
    }
    check(test, test->total_actual_schedules > 70,
 606:	83 ec 04             	sub    $0x4,%esp
 609:	68 60 13 00 00       	push   $0x1360
 60e:	83 bf 90 01 00 00 46 	cmpl   $0x46,0x190(%edi)
 615:	0f 9f c0             	setg   %al
 618:	0f b6 c0             	movzbl %al,%eax
 61b:	50                   	push   %eax
 61c:	57                   	push   %edi
 61d:	e8 57 fb ff ff       	call   179 <check>
          "experiment ran for a non-trivial number of schedules\n"
          "if you are properly recording times scheduled, then this might\n"
          "just mean that SLEEP_TIME in lotterytest.c should be increased\n"
          "to get a larger sample");
    return passed_threshold;
 622:	83 c4 10             	add    $0x10,%esp
}
 625:	89 d8                	mov    %ebx,%eax
 627:	8d 65 f4             	lea    -0xc(%ebp),%esp
 62a:	5b                   	pop    %ebx
 62b:	5e                   	pop    %esi
 62c:	5f                   	pop    %edi
 62d:	5d                   	pop    %ebp
 62e:	c3                   	ret    
        return 1;
 62f:	bb 01 00 00 00       	mov    $0x1,%ebx
 634:	eb ef                	jmp    625 <compare_schedules_chi_squared+0x1a6>

00000636 <compare_schedules_naive>:

   This hopefully will detect cases where a biased random
   number generator is in use but otherwise the implementation
   is generally okay.
 */
void compare_schedules_naive(struct test_case *test) {
 636:	55                   	push   %ebp
 637:	89 e5                	mov    %esp,%ebp
 639:	57                   	push   %edi
 63a:	56                   	push   %esi
 63b:	53                   	push   %ebx
 63c:	83 ec 2c             	sub    $0x2c,%esp
 63f:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (test->num_children < 2) {
 642:	8b 4f 0c             	mov    0xc(%edi),%ecx
 645:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 648:	83 f9 01             	cmp    $0x1,%ecx
 64b:	0f 8e 14 01 00 00    	jle    765 <compare_schedules_naive+0x12f>
        return;
    }
    int expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
 651:	b8 00 00 00 00       	mov    $0x0,%eax
    int expect_schedules_total = 0;
 656:	ba 00 00 00 00       	mov    $0x0,%edx
 65b:	eb 0a                	jmp    667 <compare_schedules_naive+0x31>
        expect_schedules_total += test->expect_schedules_unscaled[i];
 65d:	03 94 87 90 00 00 00 	add    0x90(%edi,%eax,4),%edx
    for (int i = 0; i < test->num_children; ++i) {
 664:	83 c0 01             	add    $0x1,%eax
 667:	39 c1                	cmp    %eax,%ecx
 669:	7f f2                	jg     65d <compare_schedules_naive+0x27>
 66b:	89 55 d8             	mov    %edx,-0x28(%ebp)
    }
    int failed_any = 0;
    for (int i = 0; i < test->num_children; ++i) {
 66e:	be 00 00 00 00       	mov    $0x0,%esi
    int failed_any = 0;
 673:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 67a:	89 7d 08             	mov    %edi,0x8(%ebp)
 67d:	89 f7                	mov    %esi,%edi
 67f:	eb 0a                	jmp    68b <compare_schedules_naive+0x55>
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
        int max_expected = scaled_expected * 11 / 10 + 10;
        int min_expected = scaled_expected * 9 / 10 - 10;
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
        if (!in_range) {
            failed_any = 1;
 681:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 688:	83 c7 01             	add    $0x1,%edi
 68b:	39 7d dc             	cmp    %edi,-0x24(%ebp)
 68e:	0f 8e b0 00 00 00    	jle    744 <compare_schedules_naive+0x10e>
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
 694:	8b 45 08             	mov    0x8(%ebp),%eax
 697:	8b 84 b8 90 00 00 00 	mov    0x90(%eax,%edi,4),%eax
 69e:	89 c3                	mov    %eax,%ebx
 6a0:	c1 fb 1f             	sar    $0x1f,%ebx
 6a3:	8b 75 08             	mov    0x8(%ebp),%esi
 6a6:	8b 96 90 01 00 00    	mov    0x190(%esi),%edx
 6ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
 6af:	89 d6                	mov    %edx,%esi
 6b1:	c1 fe 1f             	sar    $0x1f,%esi
 6b4:	89 75 e4             	mov    %esi,-0x1c(%ebp)
 6b7:	89 d9                	mov    %ebx,%ecx
 6b9:	0f af ca             	imul   %edx,%ecx
 6bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 6bf:	0f af d8             	imul   %eax,%ebx
 6c2:	01 d9                	add    %ebx,%ecx
 6c4:	f7 e2                	mul    %edx
 6c6:	01 ca                	add    %ecx,%edx
 6c8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
 6cb:	89 cb                	mov    %ecx,%ebx
 6cd:	c1 fb 1f             	sar    $0x1f,%ebx
 6d0:	53                   	push   %ebx
 6d1:	51                   	push   %ecx
 6d2:	52                   	push   %edx
 6d3:	50                   	push   %eax
 6d4:	e8 c7 07 00 00       	call   ea0 <__divdi3>
 6d9:	83 c4 10             	add    $0x10,%esp
 6dc:	89 c6                	mov    %eax,%esi
 6de:	89 d3                	mov    %edx,%ebx
        int max_expected = scaled_expected * 11 / 10 + 10;
 6e0:	6b ca 0b             	imul   $0xb,%edx,%ecx
 6e3:	b8 0b 00 00 00       	mov    $0xb,%eax
 6e8:	f7 e6                	mul    %esi
 6ea:	01 ca                	add    %ecx,%edx
 6ec:	6a 00                	push   $0x0
 6ee:	6a 0a                	push   $0xa
 6f0:	52                   	push   %edx
 6f1:	50                   	push   %eax
 6f2:	e8 a9 07 00 00       	call   ea0 <__divdi3>
 6f7:	83 c4 10             	add    $0x10,%esp
 6fa:	83 c0 0a             	add    $0xa,%eax
 6fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int min_expected = scaled_expected * 9 / 10 - 10;
 700:	6b db 09             	imul   $0x9,%ebx,%ebx
 703:	b8 09 00 00 00       	mov    $0x9,%eax
 708:	f7 e6                	mul    %esi
 70a:	01 da                	add    %ebx,%edx
 70c:	6a 00                	push   $0x0
 70e:	6a 0a                	push   $0xa
 710:	52                   	push   %edx
 711:	50                   	push   %eax
 712:	e8 89 07 00 00       	call   ea0 <__divdi3>
 717:	83 c4 10             	add    $0x10,%esp
 71a:	83 e8 0a             	sub    $0xa,%eax
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
 71d:	8b 75 08             	mov    0x8(%ebp),%esi
 720:	8b 94 be 10 01 00 00 	mov    0x110(%esi,%edi,4),%edx
 727:	39 c2                	cmp    %eax,%edx
 729:	0f 8c 52 ff ff ff    	jl     681 <compare_schedules_naive+0x4b>
 72f:	3b 55 e0             	cmp    -0x20(%ebp),%edx
 732:	0f 8e 50 ff ff ff    	jle    688 <compare_schedules_naive+0x52>
            failed_any = 1;
 738:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 73f:	e9 44 ff ff ff       	jmp    688 <compare_schedules_naive+0x52>
 744:	8b 7d 08             	mov    0x8(%ebp),%edi
        }
    }
    check(test, !failed_any, "schedule counts within +/- 10% or +/- 10 of expected");
 747:	83 ec 04             	sub    $0x4,%esp
 74a:	68 2c 14 00 00       	push   $0x142c
 74f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
 752:	89 f0                	mov    %esi,%eax
 754:	83 f0 01             	xor    $0x1,%eax
 757:	50                   	push   %eax
 758:	57                   	push   %edi
 759:	e8 1b fa ff ff       	call   179 <check>
    if (!failed_any) {
 75e:	83 c4 10             	add    $0x10,%esp
 761:	85 f6                	test   %esi,%esi
 763:	74 08                	je     76d <compare_schedules_naive+0x137>
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
        printf(1, "*** a likely cause is bias in random number generation\n");
    }
}
 765:	8d 65 f4             	lea    -0xc(%ebp),%esp
 768:	5b                   	pop    %ebx
 769:	5e                   	pop    %esi
 76a:	5f                   	pop    %edi
 76b:	5d                   	pop    %ebp
 76c:	c3                   	ret    
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
 76d:	83 ec 04             	sub    $0x4,%esp
 770:	ff 37                	pushl  (%edi)
 772:	68 64 14 00 00       	push   $0x1464
 777:	6a 01                	push   $0x1
 779:	e8 60 04 00 00       	call   bde <printf>
        printf(1, "*** a likely cause is bias in random number generation\n");
 77e:	83 c4 08             	add    $0x8,%esp
 781:	68 a4 14 00 00       	push   $0x14a4
 786:	6a 01                	push   $0x1
 788:	e8 51 04 00 00       	call   bde <printf>
 78d:	83 c4 10             	add    $0x10,%esp
 790:	eb d3                	jmp    765 <compare_schedules_naive+0x12f>

00000792 <run_test_case>:

void run_test_case(struct test_case* test) {
 792:	55                   	push   %ebp
 793:	89 e5                	mov    %esp,%ebp
 795:	53                   	push   %ebx
 796:	81 ec 94 06 00 00    	sub    $0x694,%esp
 79c:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int pids[MAX_CHILDREN];
    test->total_tests = test->errors = 0;
 79f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
 7a6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
    struct processes_info before, after;
    execute_and_get_info(test, pids, &before, &after);
 7ad:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 7b3:	50                   	push   %eax
 7b4:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 7ba:	50                   	push   %eax
 7bb:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 7c1:	50                   	push   %eax
 7c2:	53                   	push   %ebx
 7c3:	e8 ea f9 ff ff       	call   1b2 <execute_and_get_info>
    check(test, 
          before.num_processes < NPROC && after.num_processes < NPROC &&
 7c8:	8b 85 74 fc ff ff    	mov    -0x38c(%ebp),%eax
    check(test, 
 7ce:	83 c4 10             	add    $0x10,%esp
 7d1:	83 f8 3f             	cmp    $0x3f,%eax
 7d4:	7f 1d                	jg     7f3 <run_test_case+0x61>
          before.num_processes < NPROC && after.num_processes < NPROC &&
 7d6:	8b 95 70 f9 ff ff    	mov    -0x690(%ebp),%edx
 7dc:	83 fa 3f             	cmp    $0x3f,%edx
 7df:	7f 72                	jg     853 <run_test_case+0xc1>
          before.num_processes > test->num_children && after.num_processes > test->num_children,
 7e1:	8b 4b 0c             	mov    0xc(%ebx),%ecx
          before.num_processes < NPROC && after.num_processes < NPROC &&
 7e4:	39 c8                	cmp    %ecx,%eax
 7e6:	7e 72                	jle    85a <run_test_case+0xc8>
    check(test, 
 7e8:	39 ca                	cmp    %ecx,%edx
 7ea:	7f 75                	jg     861 <run_test_case+0xcf>
 7ec:	b8 00 00 00 00       	mov    $0x0,%eax
 7f1:	eb 05                	jmp    7f8 <run_test_case+0x66>
 7f3:	b8 00 00 00 00       	mov    $0x0,%eax
 7f8:	83 ec 04             	sub    $0x4,%esp
 7fb:	68 dc 14 00 00       	push   $0x14dc
 800:	50                   	push   %eax
 801:	53                   	push   %ebx
 802:	e8 72 f9 ff ff       	call   179 <check>
          "getprocessesinfo returned a reasonable number of processes");
    count_schedules(test, pids, &before, &after);
 807:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 80d:	50                   	push   %eax
 80e:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 814:	50                   	push   %eax
 815:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 81b:	50                   	push   %eax
 81c:	53                   	push   %ebx
 81d:	e8 67 fa ff ff       	call   289 <count_schedules>
    if (!compare_schedules_chi_squared(test)) {
 822:	83 c4 14             	add    $0x14,%esp
 825:	53                   	push   %ebx
 826:	e8 54 fc ff ff       	call   47f <compare_schedules_chi_squared>
 82b:	83 c4 10             	add    $0x10,%esp
 82e:	85 c0                	test   %eax,%eax
 830:	74 36                	je     868 <run_test_case+0xd6>
        compare_schedules_naive(test);
    }
    printf(1, "%s: passed %d of %d\n", test->name, test->total_tests - test->errors, test->total_tests);
 832:	8b 43 04             	mov    0x4(%ebx),%eax
 835:	83 ec 0c             	sub    $0xc,%esp
 838:	50                   	push   %eax
 839:	2b 43 08             	sub    0x8(%ebx),%eax
 83c:	50                   	push   %eax
 83d:	ff 33                	pushl  (%ebx)
 83f:	68 4c 10 00 00       	push   $0x104c
 844:	6a 01                	push   $0x1
 846:	e8 93 03 00 00       	call   bde <printf>
}
 84b:	83 c4 20             	add    $0x20,%esp
 84e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 851:	c9                   	leave  
 852:	c3                   	ret    
    check(test, 
 853:	b8 00 00 00 00       	mov    $0x0,%eax
 858:	eb 9e                	jmp    7f8 <run_test_case+0x66>
 85a:	b8 00 00 00 00       	mov    $0x0,%eax
 85f:	eb 97                	jmp    7f8 <run_test_case+0x66>
 861:	b8 01 00 00 00       	mov    $0x1,%eax
 866:	eb 90                	jmp    7f8 <run_test_case+0x66>
        compare_schedules_naive(test);
 868:	83 ec 0c             	sub    $0xc,%esp
 86b:	53                   	push   %ebx
 86c:	e8 c5 fd ff ff       	call   636 <compare_schedules_naive>
 871:	83 c4 10             	add    $0x10,%esp
 874:	eb bc                	jmp    832 <run_test_case+0xa0>

00000876 <main>:

int main(int argc, char *argv[])
{
 876:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 87a:	83 e4 f0             	and    $0xfffffff0,%esp
 87d:	ff 71 fc             	pushl  -0x4(%ecx)
 880:	55                   	push   %ebp
 881:	89 e5                	mov    %esp,%ebp
 883:	57                   	push   %edi
 884:	56                   	push   %esi
 885:	53                   	push   %ebx
 886:	51                   	push   %ecx
 887:	83 ec 18             	sub    $0x18,%esp
    int total_tests = 0;
    int passed_tests = 0;
    for (int i = 0; tests[i].name; ++i) {
 88a:	be 00 00 00 00       	mov    $0x0,%esi
    int passed_tests = 0;
 88f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int total_tests = 0;
 896:	bf 00 00 00 00       	mov    $0x0,%edi
    for (int i = 0; tests[i].name; ++i) {
 89b:	eb 26                	jmp    8c3 <main+0x4d>
        struct test_case *test = &tests[i];
 89d:	69 de 14 02 00 00    	imul   $0x214,%esi,%ebx
 8a3:	81 c3 80 1b 00 00    	add    $0x1b80,%ebx
        run_test_case(test);
 8a9:	83 ec 0c             	sub    $0xc,%esp
 8ac:	53                   	push   %ebx
 8ad:	e8 e0 fe ff ff       	call   792 <run_test_case>
        total_tests += test->total_tests;
 8b2:	8b 43 04             	mov    0x4(%ebx),%eax
 8b5:	01 c7                	add    %eax,%edi
        passed_tests += test->total_tests - test->errors;
 8b7:	2b 43 08             	sub    0x8(%ebx),%eax
 8ba:	01 45 e4             	add    %eax,-0x1c(%ebp)
    for (int i = 0; tests[i].name; ++i) {
 8bd:	83 c6 01             	add    $0x1,%esi
 8c0:	83 c4 10             	add    $0x10,%esp
 8c3:	69 c6 14 02 00 00    	imul   $0x214,%esi,%eax
 8c9:	83 b8 80 1b 00 00 00 	cmpl   $0x0,0x1b80(%eax)
 8d0:	75 cb                	jne    89d <main+0x27>
    }
    printf(1, "overall: passed %d of %d\n", passed_tests, total_tests);
 8d2:	57                   	push   %edi
 8d3:	ff 75 e4             	pushl  -0x1c(%ebp)
 8d6:	68 61 10 00 00       	push   $0x1061
 8db:	6a 01                	push   $0x1
 8dd:	e8 fc 02 00 00       	call   bde <printf>
    exit();
 8e2:	e8 8d 01 00 00       	call   a74 <exit>

000008e7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 8e7:	55                   	push   %ebp
 8e8:	89 e5                	mov    %esp,%ebp
 8ea:	53                   	push   %ebx
 8eb:	8b 45 08             	mov    0x8(%ebp),%eax
 8ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 8f1:	89 c2                	mov    %eax,%edx
 8f3:	0f b6 19             	movzbl (%ecx),%ebx
 8f6:	88 1a                	mov    %bl,(%edx)
 8f8:	8d 52 01             	lea    0x1(%edx),%edx
 8fb:	8d 49 01             	lea    0x1(%ecx),%ecx
 8fe:	84 db                	test   %bl,%bl
 900:	75 f1                	jne    8f3 <strcpy+0xc>
    ;
  return os;
}
 902:	5b                   	pop    %ebx
 903:	5d                   	pop    %ebp
 904:	c3                   	ret    

00000905 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 905:	55                   	push   %ebp
 906:	89 e5                	mov    %esp,%ebp
 908:	8b 4d 08             	mov    0x8(%ebp),%ecx
 90b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 90e:	eb 06                	jmp    916 <strcmp+0x11>
    p++, q++;
 910:	83 c1 01             	add    $0x1,%ecx
 913:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 916:	0f b6 01             	movzbl (%ecx),%eax
 919:	84 c0                	test   %al,%al
 91b:	74 04                	je     921 <strcmp+0x1c>
 91d:	3a 02                	cmp    (%edx),%al
 91f:	74 ef                	je     910 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 921:	0f b6 c0             	movzbl %al,%eax
 924:	0f b6 12             	movzbl (%edx),%edx
 927:	29 d0                	sub    %edx,%eax
}
 929:	5d                   	pop    %ebp
 92a:	c3                   	ret    

0000092b <strlen>:

uint
strlen(const char *s)
{
 92b:	55                   	push   %ebp
 92c:	89 e5                	mov    %esp,%ebp
 92e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 931:	ba 00 00 00 00       	mov    $0x0,%edx
 936:	eb 03                	jmp    93b <strlen+0x10>
 938:	83 c2 01             	add    $0x1,%edx
 93b:	89 d0                	mov    %edx,%eax
 93d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 941:	75 f5                	jne    938 <strlen+0xd>
    ;
  return n;
}
 943:	5d                   	pop    %ebp
 944:	c3                   	ret    

00000945 <memset>:

void*
memset(void *dst, int c, uint n)
{
 945:	55                   	push   %ebp
 946:	89 e5                	mov    %esp,%ebp
 948:	57                   	push   %edi
 949:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 94c:	89 d7                	mov    %edx,%edi
 94e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 951:	8b 45 0c             	mov    0xc(%ebp),%eax
 954:	fc                   	cld    
 955:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 957:	89 d0                	mov    %edx,%eax
 959:	5f                   	pop    %edi
 95a:	5d                   	pop    %ebp
 95b:	c3                   	ret    

0000095c <strchr>:

char*
strchr(const char *s, char c)
{
 95c:	55                   	push   %ebp
 95d:	89 e5                	mov    %esp,%ebp
 95f:	8b 45 08             	mov    0x8(%ebp),%eax
 962:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 966:	0f b6 10             	movzbl (%eax),%edx
 969:	84 d2                	test   %dl,%dl
 96b:	74 09                	je     976 <strchr+0x1a>
    if(*s == c)
 96d:	38 ca                	cmp    %cl,%dl
 96f:	74 0a                	je     97b <strchr+0x1f>
  for(; *s; s++)
 971:	83 c0 01             	add    $0x1,%eax
 974:	eb f0                	jmp    966 <strchr+0xa>
      return (char*)s;
  return 0;
 976:	b8 00 00 00 00       	mov    $0x0,%eax
}
 97b:	5d                   	pop    %ebp
 97c:	c3                   	ret    

0000097d <gets>:

char*
gets(char *buf, int max)
{
 97d:	55                   	push   %ebp
 97e:	89 e5                	mov    %esp,%ebp
 980:	57                   	push   %edi
 981:	56                   	push   %esi
 982:	53                   	push   %ebx
 983:	83 ec 1c             	sub    $0x1c,%esp
 986:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 989:	bb 00 00 00 00       	mov    $0x0,%ebx
 98e:	8d 73 01             	lea    0x1(%ebx),%esi
 991:	3b 75 0c             	cmp    0xc(%ebp),%esi
 994:	7d 2e                	jge    9c4 <gets+0x47>
    cc = read(0, &c, 1);
 996:	83 ec 04             	sub    $0x4,%esp
 999:	6a 01                	push   $0x1
 99b:	8d 45 e7             	lea    -0x19(%ebp),%eax
 99e:	50                   	push   %eax
 99f:	6a 00                	push   $0x0
 9a1:	e8 e6 00 00 00       	call   a8c <read>
    if(cc < 1)
 9a6:	83 c4 10             	add    $0x10,%esp
 9a9:	85 c0                	test   %eax,%eax
 9ab:	7e 17                	jle    9c4 <gets+0x47>
      break;
    buf[i++] = c;
 9ad:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 9b1:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 9b4:	3c 0a                	cmp    $0xa,%al
 9b6:	0f 94 c2             	sete   %dl
 9b9:	3c 0d                	cmp    $0xd,%al
 9bb:	0f 94 c0             	sete   %al
    buf[i++] = c;
 9be:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 9c0:	08 c2                	or     %al,%dl
 9c2:	74 ca                	je     98e <gets+0x11>
      break;
  }
  buf[i] = '\0';
 9c4:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 9c8:	89 f8                	mov    %edi,%eax
 9ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
 9cd:	5b                   	pop    %ebx
 9ce:	5e                   	pop    %esi
 9cf:	5f                   	pop    %edi
 9d0:	5d                   	pop    %ebp
 9d1:	c3                   	ret    

000009d2 <stat>:

int
stat(const char *n, struct stat *st)
{
 9d2:	55                   	push   %ebp
 9d3:	89 e5                	mov    %esp,%ebp
 9d5:	56                   	push   %esi
 9d6:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 9d7:	83 ec 08             	sub    $0x8,%esp
 9da:	6a 00                	push   $0x0
 9dc:	ff 75 08             	pushl  0x8(%ebp)
 9df:	e8 d0 00 00 00       	call   ab4 <open>
  if(fd < 0)
 9e4:	83 c4 10             	add    $0x10,%esp
 9e7:	85 c0                	test   %eax,%eax
 9e9:	78 24                	js     a0f <stat+0x3d>
 9eb:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 9ed:	83 ec 08             	sub    $0x8,%esp
 9f0:	ff 75 0c             	pushl  0xc(%ebp)
 9f3:	50                   	push   %eax
 9f4:	e8 d3 00 00 00       	call   acc <fstat>
 9f9:	89 c6                	mov    %eax,%esi
  close(fd);
 9fb:	89 1c 24             	mov    %ebx,(%esp)
 9fe:	e8 99 00 00 00       	call   a9c <close>
  return r;
 a03:	83 c4 10             	add    $0x10,%esp
}
 a06:	89 f0                	mov    %esi,%eax
 a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
 a0b:	5b                   	pop    %ebx
 a0c:	5e                   	pop    %esi
 a0d:	5d                   	pop    %ebp
 a0e:	c3                   	ret    
    return -1;
 a0f:	be ff ff ff ff       	mov    $0xffffffff,%esi
 a14:	eb f0                	jmp    a06 <stat+0x34>

00000a16 <atoi>:

int
atoi(const char *s)
{
 a16:	55                   	push   %ebp
 a17:	89 e5                	mov    %esp,%ebp
 a19:	53                   	push   %ebx
 a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 a22:	eb 10                	jmp    a34 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 a24:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 a27:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 a2a:	83 c1 01             	add    $0x1,%ecx
 a2d:	0f be d2             	movsbl %dl,%edx
 a30:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 a34:	0f b6 11             	movzbl (%ecx),%edx
 a37:	8d 5a d0             	lea    -0x30(%edx),%ebx
 a3a:	80 fb 09             	cmp    $0x9,%bl
 a3d:	76 e5                	jbe    a24 <atoi+0xe>
  return n;
}
 a3f:	5b                   	pop    %ebx
 a40:	5d                   	pop    %ebp
 a41:	c3                   	ret    

00000a42 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 a42:	55                   	push   %ebp
 a43:	89 e5                	mov    %esp,%ebp
 a45:	56                   	push   %esi
 a46:	53                   	push   %ebx
 a47:	8b 45 08             	mov    0x8(%ebp),%eax
 a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 a4d:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 a50:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 a52:	eb 0d                	jmp    a61 <memmove+0x1f>
    *dst++ = *src++;
 a54:	0f b6 13             	movzbl (%ebx),%edx
 a57:	88 11                	mov    %dl,(%ecx)
 a59:	8d 5b 01             	lea    0x1(%ebx),%ebx
 a5c:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 a5f:	89 f2                	mov    %esi,%edx
 a61:	8d 72 ff             	lea    -0x1(%edx),%esi
 a64:	85 d2                	test   %edx,%edx
 a66:	7f ec                	jg     a54 <memmove+0x12>
  return vdst;
}
 a68:	5b                   	pop    %ebx
 a69:	5e                   	pop    %esi
 a6a:	5d                   	pop    %ebp
 a6b:	c3                   	ret    

00000a6c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 a6c:	b8 01 00 00 00       	mov    $0x1,%eax
 a71:	cd 40                	int    $0x40
 a73:	c3                   	ret    

00000a74 <exit>:
SYSCALL(exit)
 a74:	b8 02 00 00 00       	mov    $0x2,%eax
 a79:	cd 40                	int    $0x40
 a7b:	c3                   	ret    

00000a7c <wait>:
SYSCALL(wait)
 a7c:	b8 03 00 00 00       	mov    $0x3,%eax
 a81:	cd 40                	int    $0x40
 a83:	c3                   	ret    

00000a84 <pipe>:
SYSCALL(pipe)
 a84:	b8 04 00 00 00       	mov    $0x4,%eax
 a89:	cd 40                	int    $0x40
 a8b:	c3                   	ret    

00000a8c <read>:
SYSCALL(read)
 a8c:	b8 05 00 00 00       	mov    $0x5,%eax
 a91:	cd 40                	int    $0x40
 a93:	c3                   	ret    

00000a94 <write>:
SYSCALL(write)
 a94:	b8 10 00 00 00       	mov    $0x10,%eax
 a99:	cd 40                	int    $0x40
 a9b:	c3                   	ret    

00000a9c <close>:
SYSCALL(close)
 a9c:	b8 15 00 00 00       	mov    $0x15,%eax
 aa1:	cd 40                	int    $0x40
 aa3:	c3                   	ret    

00000aa4 <kill>:
SYSCALL(kill)
 aa4:	b8 06 00 00 00       	mov    $0x6,%eax
 aa9:	cd 40                	int    $0x40
 aab:	c3                   	ret    

00000aac <exec>:
SYSCALL(exec)
 aac:	b8 07 00 00 00       	mov    $0x7,%eax
 ab1:	cd 40                	int    $0x40
 ab3:	c3                   	ret    

00000ab4 <open>:
SYSCALL(open)
 ab4:	b8 0f 00 00 00       	mov    $0xf,%eax
 ab9:	cd 40                	int    $0x40
 abb:	c3                   	ret    

00000abc <mknod>:
SYSCALL(mknod)
 abc:	b8 11 00 00 00       	mov    $0x11,%eax
 ac1:	cd 40                	int    $0x40
 ac3:	c3                   	ret    

00000ac4 <unlink>:
SYSCALL(unlink)
 ac4:	b8 12 00 00 00       	mov    $0x12,%eax
 ac9:	cd 40                	int    $0x40
 acb:	c3                   	ret    

00000acc <fstat>:
SYSCALL(fstat)
 acc:	b8 08 00 00 00       	mov    $0x8,%eax
 ad1:	cd 40                	int    $0x40
 ad3:	c3                   	ret    

00000ad4 <link>:
SYSCALL(link)
 ad4:	b8 13 00 00 00       	mov    $0x13,%eax
 ad9:	cd 40                	int    $0x40
 adb:	c3                   	ret    

00000adc <mkdir>:
SYSCALL(mkdir)
 adc:	b8 14 00 00 00       	mov    $0x14,%eax
 ae1:	cd 40                	int    $0x40
 ae3:	c3                   	ret    

00000ae4 <chdir>:
SYSCALL(chdir)
 ae4:	b8 09 00 00 00       	mov    $0x9,%eax
 ae9:	cd 40                	int    $0x40
 aeb:	c3                   	ret    

00000aec <dup>:
SYSCALL(dup)
 aec:	b8 0a 00 00 00       	mov    $0xa,%eax
 af1:	cd 40                	int    $0x40
 af3:	c3                   	ret    

00000af4 <getpid>:
SYSCALL(getpid)
 af4:	b8 0b 00 00 00       	mov    $0xb,%eax
 af9:	cd 40                	int    $0x40
 afb:	c3                   	ret    

00000afc <sbrk>:
SYSCALL(sbrk)
 afc:	b8 0c 00 00 00       	mov    $0xc,%eax
 b01:	cd 40                	int    $0x40
 b03:	c3                   	ret    

00000b04 <sleep>:
SYSCALL(sleep)
 b04:	b8 0d 00 00 00       	mov    $0xd,%eax
 b09:	cd 40                	int    $0x40
 b0b:	c3                   	ret    

00000b0c <uptime>:
SYSCALL(uptime)
 b0c:	b8 0e 00 00 00       	mov    $0xe,%eax
 b11:	cd 40                	int    $0x40
 b13:	c3                   	ret    

00000b14 <yield>:
SYSCALL(yield)
 b14:	b8 16 00 00 00       	mov    $0x16,%eax
 b19:	cd 40                	int    $0x40
 b1b:	c3                   	ret    

00000b1c <shutdown>:
SYSCALL(shutdown)
 b1c:	b8 17 00 00 00       	mov    $0x17,%eax
 b21:	cd 40                	int    $0x40
 b23:	c3                   	ret    

00000b24 <writecount>:
SYSCALL(writecount)
 b24:	b8 18 00 00 00       	mov    $0x18,%eax
 b29:	cd 40                	int    $0x40
 b2b:	c3                   	ret    

00000b2c <setwritecount>:
SYSCALL(setwritecount)
 b2c:	b8 19 00 00 00       	mov    $0x19,%eax
 b31:	cd 40                	int    $0x40
 b33:	c3                   	ret    

00000b34 <settickets>:
SYSCALL(settickets)
 b34:	b8 1a 00 00 00       	mov    $0x1a,%eax
 b39:	cd 40                	int    $0x40
 b3b:	c3                   	ret    

00000b3c <getprocessesinfo>:
 b3c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 b41:	cd 40                	int    $0x40
 b43:	c3                   	ret    

00000b44 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 b44:	55                   	push   %ebp
 b45:	89 e5                	mov    %esp,%ebp
 b47:	83 ec 1c             	sub    $0x1c,%esp
 b4a:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 b4d:	6a 01                	push   $0x1
 b4f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 b52:	52                   	push   %edx
 b53:	50                   	push   %eax
 b54:	e8 3b ff ff ff       	call   a94 <write>
}
 b59:	83 c4 10             	add    $0x10,%esp
 b5c:	c9                   	leave  
 b5d:	c3                   	ret    

00000b5e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b5e:	55                   	push   %ebp
 b5f:	89 e5                	mov    %esp,%ebp
 b61:	57                   	push   %edi
 b62:	56                   	push   %esi
 b63:	53                   	push   %ebx
 b64:	83 ec 2c             	sub    $0x2c,%esp
 b67:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 b6d:	0f 95 c3             	setne  %bl
 b70:	89 d0                	mov    %edx,%eax
 b72:	c1 e8 1f             	shr    $0x1f,%eax
 b75:	84 c3                	test   %al,%bl
 b77:	74 10                	je     b89 <printint+0x2b>
    neg = 1;
    x = -xx;
 b79:	f7 da                	neg    %edx
    neg = 1;
 b7b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 b82:	be 00 00 00 00       	mov    $0x0,%esi
 b87:	eb 0b                	jmp    b94 <printint+0x36>
  neg = 0;
 b89:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 b90:	eb f0                	jmp    b82 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 b92:	89 c6                	mov    %eax,%esi
 b94:	89 d0                	mov    %edx,%eax
 b96:	ba 00 00 00 00       	mov    $0x0,%edx
 b9b:	f7 f1                	div    %ecx
 b9d:	89 c3                	mov    %eax,%ebx
 b9f:	8d 46 01             	lea    0x1(%esi),%eax
 ba2:	0f b6 92 78 16 00 00 	movzbl 0x1678(%edx),%edx
 ba9:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 bad:	89 da                	mov    %ebx,%edx
 baf:	85 db                	test   %ebx,%ebx
 bb1:	75 df                	jne    b92 <printint+0x34>
 bb3:	89 c3                	mov    %eax,%ebx
  if(neg)
 bb5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 bb9:	74 16                	je     bd1 <printint+0x73>
    buf[i++] = '-';
 bbb:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 bc0:	8d 5e 02             	lea    0x2(%esi),%ebx
 bc3:	eb 0c                	jmp    bd1 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 bc5:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 bca:	89 f8                	mov    %edi,%eax
 bcc:	e8 73 ff ff ff       	call   b44 <putc>
  while(--i >= 0)
 bd1:	83 eb 01             	sub    $0x1,%ebx
 bd4:	79 ef                	jns    bc5 <printint+0x67>
}
 bd6:	83 c4 2c             	add    $0x2c,%esp
 bd9:	5b                   	pop    %ebx
 bda:	5e                   	pop    %esi
 bdb:	5f                   	pop    %edi
 bdc:	5d                   	pop    %ebp
 bdd:	c3                   	ret    

00000bde <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 bde:	55                   	push   %ebp
 bdf:	89 e5                	mov    %esp,%ebp
 be1:	57                   	push   %edi
 be2:	56                   	push   %esi
 be3:	53                   	push   %ebx
 be4:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 be7:	8d 45 10             	lea    0x10(%ebp),%eax
 bea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 bed:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
 bf7:	eb 14                	jmp    c0d <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 bf9:	89 fa                	mov    %edi,%edx
 bfb:	8b 45 08             	mov    0x8(%ebp),%eax
 bfe:	e8 41 ff ff ff       	call   b44 <putc>
 c03:	eb 05                	jmp    c0a <printf+0x2c>
      }
    } else if(state == '%'){
 c05:	83 fe 25             	cmp    $0x25,%esi
 c08:	74 25                	je     c2f <printf+0x51>
  for(i = 0; fmt[i]; i++){
 c0a:	83 c3 01             	add    $0x1,%ebx
 c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
 c10:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 c14:	84 c0                	test   %al,%al
 c16:	0f 84 23 01 00 00    	je     d3f <printf+0x161>
    c = fmt[i] & 0xff;
 c1c:	0f be f8             	movsbl %al,%edi
 c1f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 c22:	85 f6                	test   %esi,%esi
 c24:	75 df                	jne    c05 <printf+0x27>
      if(c == '%'){
 c26:	83 f8 25             	cmp    $0x25,%eax
 c29:	75 ce                	jne    bf9 <printf+0x1b>
        state = '%';
 c2b:	89 c6                	mov    %eax,%esi
 c2d:	eb db                	jmp    c0a <printf+0x2c>
      if(c == 'd'){
 c2f:	83 f8 64             	cmp    $0x64,%eax
 c32:	74 49                	je     c7d <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 c34:	83 f8 78             	cmp    $0x78,%eax
 c37:	0f 94 c1             	sete   %cl
 c3a:	83 f8 70             	cmp    $0x70,%eax
 c3d:	0f 94 c2             	sete   %dl
 c40:	08 d1                	or     %dl,%cl
 c42:	75 63                	jne    ca7 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 c44:	83 f8 73             	cmp    $0x73,%eax
 c47:	0f 84 84 00 00 00    	je     cd1 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c4d:	83 f8 63             	cmp    $0x63,%eax
 c50:	0f 84 b7 00 00 00    	je     d0d <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 c56:	83 f8 25             	cmp    $0x25,%eax
 c59:	0f 84 cc 00 00 00    	je     d2b <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c5f:	ba 25 00 00 00       	mov    $0x25,%edx
 c64:	8b 45 08             	mov    0x8(%ebp),%eax
 c67:	e8 d8 fe ff ff       	call   b44 <putc>
        putc(fd, c);
 c6c:	89 fa                	mov    %edi,%edx
 c6e:	8b 45 08             	mov    0x8(%ebp),%eax
 c71:	e8 ce fe ff ff       	call   b44 <putc>
      }
      state = 0;
 c76:	be 00 00 00 00       	mov    $0x0,%esi
 c7b:	eb 8d                	jmp    c0a <printf+0x2c>
        printint(fd, *ap, 10, 1);
 c7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 c80:	8b 17                	mov    (%edi),%edx
 c82:	83 ec 0c             	sub    $0xc,%esp
 c85:	6a 01                	push   $0x1
 c87:	b9 0a 00 00 00       	mov    $0xa,%ecx
 c8c:	8b 45 08             	mov    0x8(%ebp),%eax
 c8f:	e8 ca fe ff ff       	call   b5e <printint>
        ap++;
 c94:	83 c7 04             	add    $0x4,%edi
 c97:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 c9a:	83 c4 10             	add    $0x10,%esp
      state = 0;
 c9d:	be 00 00 00 00       	mov    $0x0,%esi
 ca2:	e9 63 ff ff ff       	jmp    c0a <printf+0x2c>
        printint(fd, *ap, 16, 0);
 ca7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 caa:	8b 17                	mov    (%edi),%edx
 cac:	83 ec 0c             	sub    $0xc,%esp
 caf:	6a 00                	push   $0x0
 cb1:	b9 10 00 00 00       	mov    $0x10,%ecx
 cb6:	8b 45 08             	mov    0x8(%ebp),%eax
 cb9:	e8 a0 fe ff ff       	call   b5e <printint>
        ap++;
 cbe:	83 c7 04             	add    $0x4,%edi
 cc1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 cc4:	83 c4 10             	add    $0x10,%esp
      state = 0;
 cc7:	be 00 00 00 00       	mov    $0x0,%esi
 ccc:	e9 39 ff ff ff       	jmp    c0a <printf+0x2c>
        s = (char*)*ap;
 cd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 cd4:	8b 30                	mov    (%eax),%esi
        ap++;
 cd6:	83 c0 04             	add    $0x4,%eax
 cd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 cdc:	85 f6                	test   %esi,%esi
 cde:	75 28                	jne    d08 <printf+0x12a>
          s = "(null)";
 ce0:	be 70 16 00 00       	mov    $0x1670,%esi
 ce5:	8b 7d 08             	mov    0x8(%ebp),%edi
 ce8:	eb 0d                	jmp    cf7 <printf+0x119>
          putc(fd, *s);
 cea:	0f be d2             	movsbl %dl,%edx
 ced:	89 f8                	mov    %edi,%eax
 cef:	e8 50 fe ff ff       	call   b44 <putc>
          s++;
 cf4:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 cf7:	0f b6 16             	movzbl (%esi),%edx
 cfa:	84 d2                	test   %dl,%dl
 cfc:	75 ec                	jne    cea <printf+0x10c>
      state = 0;
 cfe:	be 00 00 00 00       	mov    $0x0,%esi
 d03:	e9 02 ff ff ff       	jmp    c0a <printf+0x2c>
 d08:	8b 7d 08             	mov    0x8(%ebp),%edi
 d0b:	eb ea                	jmp    cf7 <printf+0x119>
        putc(fd, *ap);
 d0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 d10:	0f be 17             	movsbl (%edi),%edx
 d13:	8b 45 08             	mov    0x8(%ebp),%eax
 d16:	e8 29 fe ff ff       	call   b44 <putc>
        ap++;
 d1b:	83 c7 04             	add    $0x4,%edi
 d1e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 d21:	be 00 00 00 00       	mov    $0x0,%esi
 d26:	e9 df fe ff ff       	jmp    c0a <printf+0x2c>
        putc(fd, c);
 d2b:	89 fa                	mov    %edi,%edx
 d2d:	8b 45 08             	mov    0x8(%ebp),%eax
 d30:	e8 0f fe ff ff       	call   b44 <putc>
      state = 0;
 d35:	be 00 00 00 00       	mov    $0x0,%esi
 d3a:	e9 cb fe ff ff       	jmp    c0a <printf+0x2c>
    }
  }
}
 d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 d42:	5b                   	pop    %ebx
 d43:	5e                   	pop    %esi
 d44:	5f                   	pop    %edi
 d45:	5d                   	pop    %ebp
 d46:	c3                   	ret    

00000d47 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d47:	55                   	push   %ebp
 d48:	89 e5                	mov    %esp,%ebp
 d4a:	57                   	push   %edi
 d4b:	56                   	push   %esi
 d4c:	53                   	push   %ebx
 d4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d50:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d53:	a1 70 34 00 00       	mov    0x3470,%eax
 d58:	eb 02                	jmp    d5c <free+0x15>
 d5a:	89 d0                	mov    %edx,%eax
 d5c:	39 c8                	cmp    %ecx,%eax
 d5e:	73 04                	jae    d64 <free+0x1d>
 d60:	39 08                	cmp    %ecx,(%eax)
 d62:	77 12                	ja     d76 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d64:	8b 10                	mov    (%eax),%edx
 d66:	39 c2                	cmp    %eax,%edx
 d68:	77 f0                	ja     d5a <free+0x13>
 d6a:	39 c8                	cmp    %ecx,%eax
 d6c:	72 08                	jb     d76 <free+0x2f>
 d6e:	39 ca                	cmp    %ecx,%edx
 d70:	77 04                	ja     d76 <free+0x2f>
 d72:	89 d0                	mov    %edx,%eax
 d74:	eb e6                	jmp    d5c <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 d76:	8b 73 fc             	mov    -0x4(%ebx),%esi
 d79:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 d7c:	8b 10                	mov    (%eax),%edx
 d7e:	39 d7                	cmp    %edx,%edi
 d80:	74 19                	je     d9b <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 d82:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 d85:	8b 50 04             	mov    0x4(%eax),%edx
 d88:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 d8b:	39 ce                	cmp    %ecx,%esi
 d8d:	74 1b                	je     daa <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 d8f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 d91:	a3 70 34 00 00       	mov    %eax,0x3470
}
 d96:	5b                   	pop    %ebx
 d97:	5e                   	pop    %esi
 d98:	5f                   	pop    %edi
 d99:	5d                   	pop    %ebp
 d9a:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 d9b:	03 72 04             	add    0x4(%edx),%esi
 d9e:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 da1:	8b 10                	mov    (%eax),%edx
 da3:	8b 12                	mov    (%edx),%edx
 da5:	89 53 f8             	mov    %edx,-0x8(%ebx)
 da8:	eb db                	jmp    d85 <free+0x3e>
    p->s.size += bp->s.size;
 daa:	03 53 fc             	add    -0x4(%ebx),%edx
 dad:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 db0:	8b 53 f8             	mov    -0x8(%ebx),%edx
 db3:	89 10                	mov    %edx,(%eax)
 db5:	eb da                	jmp    d91 <free+0x4a>

00000db7 <morecore>:

static Header*
morecore(uint nu)
{
 db7:	55                   	push   %ebp
 db8:	89 e5                	mov    %esp,%ebp
 dba:	53                   	push   %ebx
 dbb:	83 ec 04             	sub    $0x4,%esp
 dbe:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 dc0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 dc5:	77 05                	ja     dcc <morecore+0x15>
    nu = 4096;
 dc7:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 dcc:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 dd3:	83 ec 0c             	sub    $0xc,%esp
 dd6:	50                   	push   %eax
 dd7:	e8 20 fd ff ff       	call   afc <sbrk>
  if(p == (char*)-1)
 ddc:	83 c4 10             	add    $0x10,%esp
 ddf:	83 f8 ff             	cmp    $0xffffffff,%eax
 de2:	74 1c                	je     e00 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 de4:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 de7:	83 c0 08             	add    $0x8,%eax
 dea:	83 ec 0c             	sub    $0xc,%esp
 ded:	50                   	push   %eax
 dee:	e8 54 ff ff ff       	call   d47 <free>
  return freep;
 df3:	a1 70 34 00 00       	mov    0x3470,%eax
 df8:	83 c4 10             	add    $0x10,%esp
}
 dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 dfe:	c9                   	leave  
 dff:	c3                   	ret    
    return 0;
 e00:	b8 00 00 00 00       	mov    $0x0,%eax
 e05:	eb f4                	jmp    dfb <morecore+0x44>

00000e07 <malloc>:

void*
malloc(uint nbytes)
{
 e07:	55                   	push   %ebp
 e08:	89 e5                	mov    %esp,%ebp
 e0a:	53                   	push   %ebx
 e0b:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e0e:	8b 45 08             	mov    0x8(%ebp),%eax
 e11:	8d 58 07             	lea    0x7(%eax),%ebx
 e14:	c1 eb 03             	shr    $0x3,%ebx
 e17:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 e1a:	8b 0d 70 34 00 00    	mov    0x3470,%ecx
 e20:	85 c9                	test   %ecx,%ecx
 e22:	74 04                	je     e28 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e24:	8b 01                	mov    (%ecx),%eax
 e26:	eb 4d                	jmp    e75 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 e28:	c7 05 70 34 00 00 74 	movl   $0x3474,0x3470
 e2f:	34 00 00 
 e32:	c7 05 74 34 00 00 74 	movl   $0x3474,0x3474
 e39:	34 00 00 
    base.s.size = 0;
 e3c:	c7 05 78 34 00 00 00 	movl   $0x0,0x3478
 e43:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 e46:	b9 74 34 00 00       	mov    $0x3474,%ecx
 e4b:	eb d7                	jmp    e24 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 e4d:	39 da                	cmp    %ebx,%edx
 e4f:	74 1a                	je     e6b <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 e51:	29 da                	sub    %ebx,%edx
 e53:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e56:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 e59:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 e5c:	89 0d 70 34 00 00    	mov    %ecx,0x3470
      return (void*)(p + 1);
 e62:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 e65:	83 c4 04             	add    $0x4,%esp
 e68:	5b                   	pop    %ebx
 e69:	5d                   	pop    %ebp
 e6a:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 e6b:	8b 10                	mov    (%eax),%edx
 e6d:	89 11                	mov    %edx,(%ecx)
 e6f:	eb eb                	jmp    e5c <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e71:	89 c1                	mov    %eax,%ecx
 e73:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 e75:	8b 50 04             	mov    0x4(%eax),%edx
 e78:	39 da                	cmp    %ebx,%edx
 e7a:	73 d1                	jae    e4d <malloc+0x46>
    if(p == freep)
 e7c:	39 05 70 34 00 00    	cmp    %eax,0x3470
 e82:	75 ed                	jne    e71 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 e84:	89 d8                	mov    %ebx,%eax
 e86:	e8 2c ff ff ff       	call   db7 <morecore>
 e8b:	85 c0                	test   %eax,%eax
 e8d:	75 e2                	jne    e71 <malloc+0x6a>
        return 0;
 e8f:	b8 00 00 00 00       	mov    $0x0,%eax
 e94:	eb cf                	jmp    e65 <malloc+0x5e>
 e96:	66 90                	xchg   %ax,%ax
 e98:	66 90                	xchg   %ax,%ax
 e9a:	66 90                	xchg   %ax,%ax
 e9c:	66 90                	xchg   %ax,%ax
 e9e:	66 90                	xchg   %ax,%ax

00000ea0 <__divdi3>:
 ea0:	55                   	push   %ebp
 ea1:	57                   	push   %edi
 ea2:	56                   	push   %esi
 ea3:	53                   	push   %ebx
 ea4:	83 ec 1c             	sub    $0x1c,%esp
 ea7:	8b 54 24 34          	mov    0x34(%esp),%edx
 eab:	8b 44 24 30          	mov    0x30(%esp),%eax
 eaf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
 eb6:	00 
 eb7:	89 d5                	mov    %edx,%ebp
 eb9:	89 04 24             	mov    %eax,(%esp)
 ebc:	89 54 24 04          	mov    %edx,0x4(%esp)
 ec0:	85 ed                	test   %ebp,%ebp
 ec2:	8b 44 24 38          	mov    0x38(%esp),%eax
 ec6:	8b 54 24 3c          	mov    0x3c(%esp),%edx
 eca:	79 1a                	jns    ee6 <__divdi3+0x46>
 ecc:	f7 1c 24             	negl   (%esp)
 ecf:	c7 44 24 08 ff ff ff 	movl   $0xffffffff,0x8(%esp)
 ed6:	ff 
 ed7:	83 54 24 04 00       	adcl   $0x0,0x4(%esp)
 edc:	f7 5c 24 04          	negl   0x4(%esp)
 ee0:	8b 7c 24 04          	mov    0x4(%esp),%edi
 ee4:	89 fd                	mov    %edi,%ebp
 ee6:	85 d2                	test   %edx,%edx
 ee8:	89 d3                	mov    %edx,%ebx
 eea:	79 0d                	jns    ef9 <__divdi3+0x59>
 eec:	f7 d8                	neg    %eax
 eee:	f7 54 24 08          	notl   0x8(%esp)
 ef2:	83 d2 00             	adc    $0x0,%edx
 ef5:	f7 da                	neg    %edx
 ef7:	89 d3                	mov    %edx,%ebx
 ef9:	85 db                	test   %ebx,%ebx
 efb:	89 c7                	mov    %eax,%edi
 efd:	8b 04 24             	mov    (%esp),%eax
 f00:	75 0e                	jne    f10 <__divdi3+0x70>
 f02:	39 ef                	cmp    %ebp,%edi
 f04:	76 52                	jbe    f58 <__divdi3+0xb8>
 f06:	89 ea                	mov    %ebp,%edx
 f08:	31 f6                	xor    %esi,%esi
 f0a:	f7 f7                	div    %edi
 f0c:	89 c1                	mov    %eax,%ecx
 f0e:	eb 08                	jmp    f18 <__divdi3+0x78>
 f10:	39 eb                	cmp    %ebp,%ebx
 f12:	76 24                	jbe    f38 <__divdi3+0x98>
 f14:	31 f6                	xor    %esi,%esi
 f16:	31 c9                	xor    %ecx,%ecx
 f18:	89 c8                	mov    %ecx,%eax
 f1a:	8b 4c 24 08          	mov    0x8(%esp),%ecx
 f1e:	89 f2                	mov    %esi,%edx
 f20:	85 c9                	test   %ecx,%ecx
 f22:	74 07                	je     f2b <__divdi3+0x8b>
 f24:	f7 d8                	neg    %eax
 f26:	83 d2 00             	adc    $0x0,%edx
 f29:	f7 da                	neg    %edx
 f2b:	83 c4 1c             	add    $0x1c,%esp
 f2e:	5b                   	pop    %ebx
 f2f:	5e                   	pop    %esi
 f30:	5f                   	pop    %edi
 f31:	5d                   	pop    %ebp
 f32:	c3                   	ret    
 f33:	90                   	nop
 f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 f38:	0f bd f3             	bsr    %ebx,%esi
 f3b:	83 f6 1f             	xor    $0x1f,%esi
 f3e:	75 40                	jne    f80 <__divdi3+0xe0>
 f40:	39 eb                	cmp    %ebp,%ebx
 f42:	72 07                	jb     f4b <__divdi3+0xab>
 f44:	31 c9                	xor    %ecx,%ecx
 f46:	3b 3c 24             	cmp    (%esp),%edi
 f49:	77 cd                	ja     f18 <__divdi3+0x78>
 f4b:	b9 01 00 00 00       	mov    $0x1,%ecx
 f50:	eb c6                	jmp    f18 <__divdi3+0x78>
 f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 f58:	85 ff                	test   %edi,%edi
 f5a:	75 0b                	jne    f67 <__divdi3+0xc7>
 f5c:	b8 01 00 00 00       	mov    $0x1,%eax
 f61:	31 d2                	xor    %edx,%edx
 f63:	f7 f3                	div    %ebx
 f65:	89 c7                	mov    %eax,%edi
 f67:	31 d2                	xor    %edx,%edx
 f69:	89 e8                	mov    %ebp,%eax
 f6b:	f7 f7                	div    %edi
 f6d:	89 c6                	mov    %eax,%esi
 f6f:	8b 04 24             	mov    (%esp),%eax
 f72:	f7 f7                	div    %edi
 f74:	89 c1                	mov    %eax,%ecx
 f76:	eb a0                	jmp    f18 <__divdi3+0x78>
 f78:	90                   	nop
 f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 f80:	b8 20 00 00 00       	mov    $0x20,%eax
 f85:	89 f1                	mov    %esi,%ecx
 f87:	89 fa                	mov    %edi,%edx
 f89:	29 f0                	sub    %esi,%eax
 f8b:	d3 e3                	shl    %cl,%ebx
 f8d:	89 c1                	mov    %eax,%ecx
 f8f:	d3 ea                	shr    %cl,%edx
 f91:	89 f1                	mov    %esi,%ecx
 f93:	09 da                	or     %ebx,%edx
 f95:	d3 e7                	shl    %cl,%edi
 f97:	89 eb                	mov    %ebp,%ebx
 f99:	89 c1                	mov    %eax,%ecx
 f9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
 f9f:	8b 14 24             	mov    (%esp),%edx
 fa2:	d3 eb                	shr    %cl,%ebx
 fa4:	89 f1                	mov    %esi,%ecx
 fa6:	d3 e5                	shl    %cl,%ebp
 fa8:	89 c1                	mov    %eax,%ecx
 faa:	d3 ea                	shr    %cl,%edx
 fac:	09 d5                	or     %edx,%ebp
 fae:	89 da                	mov    %ebx,%edx
 fb0:	89 e8                	mov    %ebp,%eax
 fb2:	f7 74 24 0c          	divl   0xc(%esp)
 fb6:	89 d3                	mov    %edx,%ebx
 fb8:	89 c5                	mov    %eax,%ebp
 fba:	f7 e7                	mul    %edi
 fbc:	39 d3                	cmp    %edx,%ebx
 fbe:	72 20                	jb     fe0 <__divdi3+0x140>
 fc0:	8b 3c 24             	mov    (%esp),%edi
 fc3:	89 f1                	mov    %esi,%ecx
 fc5:	d3 e7                	shl    %cl,%edi
 fc7:	39 c7                	cmp    %eax,%edi
 fc9:	73 04                	jae    fcf <__divdi3+0x12f>
 fcb:	39 d3                	cmp    %edx,%ebx
 fcd:	74 11                	je     fe0 <__divdi3+0x140>
 fcf:	89 e9                	mov    %ebp,%ecx
 fd1:	31 f6                	xor    %esi,%esi
 fd3:	e9 40 ff ff ff       	jmp    f18 <__divdi3+0x78>
 fd8:	90                   	nop
 fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 fe0:	8d 4d ff             	lea    -0x1(%ebp),%ecx
 fe3:	31 f6                	xor    %esi,%esi
 fe5:	e9 2e ff ff ff       	jmp    f18 <__divdi3+0x78>
