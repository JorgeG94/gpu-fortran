module device_mem_info_module
  use, intrinsic :: iso_c_binding
  implicit none

interface 
#ifdef HAVE_CUDA
        integer (c_int) function cudaMemGetInfo(fre, tot) &
                        bind(C, name="cudaMemGetInfo")
            use iso_c_binding
            implicit none
            type(c_ptr),value :: fre
            type(c_ptr),value :: tot
        end function cudaMemGetInfo
#elif HAVE_HIP
    integer(c_int) function hipMemGetInfo(fre, tot) bind(C, name="hipMemGetInfo")
            use iso_c_binding
            implicit none
            type(c_ptr),value :: fre
            type(c_ptr),value :: tot
    end function hipMemGetInfo
#endif
end interface

contains
    ! Implementation of the fail function
    integer(c_int) function fail() result(error)
        implicit none
        print *, "SUPER FAIL"
        error = 69
    end function fail

    integer(c_int) function get_gpu_mem_info(free, total) result(error) 
      type(c_ptr), value :: free, total 
#ifdef HAVE_CUDA 
      error = cudaMemGetInfo(free,total)
#elif HAVE_HIP
      error = hipMemGetInfo(free,total)
#else
      error = fail()
#endif
    end function 

end module device_mem_info_module
