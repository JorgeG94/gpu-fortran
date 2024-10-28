
program main
use device_mem_info_module
use hipfort
  use iso_c_binding
  implicit none
      type(c_ptr) :: cpfree, cptot
    integer*8, target :: free, total
    integer res

    cpfree = c_loc(free)
    cptot = c_loc(total)

    res = get_gpu_mem_info(cpfree, cptot)
!    res = cudaMemGetInfo(cpfree, cptot)
    print *, res
    if(res.eq.0) then 
    write(*,*)"GPU free mem:", free
    write(*,*)" "
    else
    write(*,*) "FAILL"
    endif



end program main
