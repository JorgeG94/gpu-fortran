# Set minimum required version of CMake
cmake_minimum_required(VERSION 3.21..26)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0083 NEW)
cmake_policy(SET CMP0104 NEW)
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0048 NEW)

# Name your project
set(project_name frank)

project({project_name} VERSION 0.0.1)
enable_language(Fortran)
set(CMAKE_Fortran_STANDARD 2008)
set(FVERSION "-cpp")
#set(FLAGS1 "-Wall -Wextra -Wpedantic")
# set(WERROR "-Werror")
set(CMAKE_Fortran_FLAGS
    "${CMAKE_Fortran_FLAGS} ${FVERSION} ${FLAGS1} ${WERROR}")
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

# Set default install prefix to the project source directory
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX
      ${CMAKE_SOURCE_DIR}
      CACHE PATH "..." FORCE)
endif()
if(USE_GPU)
  # set the variable we'll use ON, make sure to turn MPI and OpenMP ON
  set(GPU ON)
  set(GPU_RUNTIMES "CUDA" "HIP")
  # iterate through the list to see if we have a valid GPU runtime
  if(DEFINED GPU_RUNTIME)
    if("${GPU_RUNTIME}" IN_LIST GPU_RUNTIMES)
      message(STATUS "GPU_RUNTIME set to \"${GPU_RUNTIME}\"!")
    else()
      set(FATAL_ERROR
          "GPU_RUNTIME is set to ${GPU_RUNTIME} \nValid options are HIP, CUDA, INTEL"
      )
    endif()
  else()
    set(GPU_RUNTIME "CUDA")
    message(WARNING "Setting GPU_RUNTIME to CUDA by default!")
  endif()
  # enable the language for gpus
  enable_language(${GPU_RUNTIME})
else()
  message(STATUS "${project_name} built with pure CPU support!")
  set(GPU OFF)
endif()

if(GPU)
  if(${GPU_RUNTIME} MATCHES "CUDA")
    # do not try to change this to find_package(CUDA) this is deprecated in
    # cmake
    find_package(CUDAToolkit REQUIRED)
  elseif(${GPU_RUNTIME} MATCHES "HIP")
    #target_compile_definitions(${project_name} PUBLIC HAVE_HIP)
    # for some reason we need all of this crap TODO: figure out how much crap we
    # actually need O.o
    find_package(HIP REQUIRED)
    find_package(hipBLAS REQUIRED)
    find_package(hipSPARSE REQUIRED)
    find_package(hipSOLVER REQUIRED)
    find_package(rocBLAS REQUIRED)
    find_package(rocSPARSE REQUIRED)
    find_package(rocSOLVER REQUIRED)
  endif()
endif()

add_executable(${project_name} main.f90 device_mem_info_module.F90)
#add_executable(${project_name} main.f90)
#target_compile_options(${project_name} PUBLIC 
#      -cpp
#) 
# Add the executable target based on main.f90
if(GPU)
  if(${GPU_RUNTIME} MATCHES CUDA)
    target_compile_definitions(${project_name} PUBLIC HAVE_CUDA)
  target_link_libraries(${project_name} PUBLIC CUDA::cublas CUDA::cusolver CUDA::cusparse
         CUDA::cudart)
  elseif(${GPU_RUNTIME} MATCHES HIP)
  target_link_libraries(${project_name} PUBLIC
      hip::host
      roc::hipblas
      roc::hipsparse
      roc::hipsolver
      roc::rocblas
      roc::rocsparse
      roc::rocsolver)
  endif()
endif()
    #target_link_options(
    #  ${project_name}
    #  PRIVATE
    #  -cpp
    #  )
install(TARGETS ${project_name} DESTINATION ${PROJECT_SOURCE_DIR})
