#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{

    //test setwritecount works
    printf(1,"Testing Num times process run \n");
    // setwritecount(69);
    // printf(1, "%d\n", writecount() );
    // setwritecount(0);
    // printf(1, "%d\n", writecount() );
    // //test that it will actual increment when write is called
    // printf(1, "%d\n", writecount() );
    // printf(1, "%d\n", writecount() );
    // printf(1, "%d\n", writecount() );
    // printf(1,"this is a test \n");
    // printf(1, "%d\n", writecount() );
    
  struct processes_info myInfo;
  struct processes_info *myProcess = &myInfo;
    getprocessesinfo(myProcess);
    settickets(69);
    getprocessesinfo(myProcess);
  exit();
}
