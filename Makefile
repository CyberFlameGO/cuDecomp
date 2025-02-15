# Update this CONFIGFILE for your system or use command 'make CONFIGFILE=<path to your config file>'
PWD=$(shell pwd)
CONFIGFILE=${PWD}/configs/nvhpcsdk.conf
include ${CONFIGFILE}

MPICXX ?= ${MPI_HOME}/bin/mpicxx
MPIF90 ?= ${MPI_HOME}/bin/mpif90
NVCC ?= ${CUDA_HOME}/bin/nvcc

CXXFLAGS=-O3 -std=c++14
# Note: compiling autotune.cc with -O1 due to double free issues otherwise
CXXFLAGS_O1=-O1 -std=c++14
NVFLAGS=-O3 -std=c++14 --ptxas-options=-v -cudart shared

CUDA_CC_LIST ?= 60 70 80
CUDA_CC_LAST := $(lastword $(sort ${CUDA_CC_LIST}))
NVFLAGS += $(foreach CC,${CUDA_CC_LIST},-gencode=arch=compute_${CC},code=sm_${CC})
NVFLAGS += -gencode=arch=compute_${CUDA_CC_LAST},code=compute_${CUDA_CC_LAST}

BUILDDIR=${PWD}/build
TESTDIR=${PWD}/tests
EXAMPLEDIR=${PWD}/examples
BENCHMARKDIR=${PWD}/benchmark

OBJ=${BUILDDIR}/cudecomp.o ${BUILDDIR}/cudecomp_kernels.o ${BUILDDIR}/autotune.o
TESTS_CC=${TESTDIR}/cc/test ${TESTDIR}/cc/fft_test
TESTS_F90=${TESTDIR}/fortran/test ${TESTDIR}/fortran/fft_test

CUDECOMPLIB=${BUILDDIR}/lib/libcudecomp.so
CUDECOMPFLIB=${BUILDDIR}/lib/libcudecomp_fort.so
CUDECOMPMOD=${BUILDDIR}/cudecomp_m.o

LIBS = -L${BUILDDIR}/lib -lcudecomp
FLIBS = -L${BUILDDIR}/lib -lcudecomp -lcudecomp_fort
INCLUDES = -I${BUILDDIR}/include

INCLUDES += -I${PWD}/include -I${MPI_HOME}/include -I${CUDA_HOME}/include -I${NCCL_HOME}/include  -I${CUTENSOR_HOME}/include -I${CUDACXX_HOME}/include -I${NVSHMEM_HOME}/include
BUILD_INCLUDES = -I${PWD}/include -I${MPI_HOME}/include -I${CUDA_HOME}/include -I${NCCL_HOME}/include  -I${CUTENSOR_HOME}/include -I${CUDACXX_HOME}/include -I${NVSHMEM_HOME}/include
LIBS += -L${CUDA_HOME}/lib64 -L${CUTENSOR_HOME}/lib64 -L${NCCL_HOME}/lib -L${CUDA_HOME}/lib64/stubs -lnccl -lcutensor -lcufft -lcudart -lnvidia-ml
FLIBS += -cudalib=nccl,cufft,cutensor -lstdc++ -L${CUDA_HOME}/lib64 -L${CUDA_HOME}/lib64/stubs -lnvidia-ml

ifeq ($(strip $(ENABLE_NVSHMEM)),1)
DEFINES += -DENABLE_NVSHMEM -DNVSHMEM_USE_NCCL
INCLUDES += -I${NVSHMEM_HOME}/include
LIBS += -lcuda
FLIBS += -lcuda
STATIC_LIBS += ${NVSHMEM_HOME}/lib/libnvshmem.a
endif
ifeq ($(strip $(ENABLE_NVTX)),1)
DEFINES += -DENABLE_NVTX
endif

ifeq ($(strip $(MPIF90)),ftn)
DEFINES += -DMPICH
endif

LIBS += ${EXTRA_LIBS}
FLIBS += ${EXTRA_LIBS}
DEFINES += ${EXTRA_DEFINES}


LIBTARGETS = ${CUDECOMPLIB}
ifeq ($(strip $(BUILD_FORTRAN)),1)
LIBTARGETS += ${CUDECOMPFLIB}
endif

export LIBS FLIBS INCLUDES DEFINES MPICXX MPIF90 NVCC CXXFLAGS NVFLAGS BUILD_FORTRAN

.PHONY: all lib tests benchmark examples

all: lib tests benchmark examples

lib: ${LIBTARGETS}
	@mkdir -p ${BUILDDIR}/include
	cp ./include/cudecomp.h ${BUILDDIR}/include

tests: lib
	cd ${TESTDIR}; make CONFIGFILE=${CONFIGFILE}

benchmark: lib
	cd ${BENCHMARKDIR}; make CONFIGFILE=${CONFIGFILE}

examples: lib
	cd ${EXAMPLEDIR}; make CONFIGFILE=${CONFIGFILE}

${BUILDDIR}/autotune.o: src/autotune.cc  include/*.h include/internal/*.h
	@mkdir -p ${BUILDDIR}
	${MPICXX} -fPIC ${DEFINES} ${CXXFLAGS_O1} ${BUILD_INCLUDES} -c -o $@ $<

${BUILDDIR}/%.o: src/%.cc  include/*.h include/internal/*.h
	@mkdir -p ${BUILDDIR}
	${MPICXX} -fPIC ${DEFINES} ${CXXFLAGS} ${BUILD_INCLUDES} -c -o $@ $<

${BUILDDIR}/%.o: src/%.cu  include/internal/*.cuh
	@mkdir -p ${BUILDDIR}
	${NVCC} -rdc=true -Xcompiler -fPIC ${DEFINES} ${NVFLAGS} ${BUILD_INCLUDES} -c -o $@ $<

${CUDECOMPMOD}: src/cudecomp_m.cuf 
	@mkdir -p ${BUILDDIR}/include
	${MPIF90} -Mpreprocess -fPIC -module ${BUILDDIR}/include ${DEFINES} ${BUILD_INCLUDES} -c -o $@ $<

${CUDECOMPLIB}: ${OBJ}
	@mkdir -p ${BUILDDIR}/lib
	${NVCC} -rdc=true -shared ${NVFLAGS} ${BUILD_INCLUDES} -o $@ $^ ${STATIC_LIBS}

${CUDECOMPFLIB}: ${CUDECOMPMOD}
	@mkdir -p ${BUILDDIR}/lib
	${MPIF90} -shared ${BUILD_INCLUDES} -o $@ $^

clean:
	rm -f ${CUDECOMPLIB} ${CUDECOMPFLIB} ${BUILDDIR}/*.o ${BUILDDIR}/include/*.mod ${BUILDDIR}/include/*.h
	cd ${TESTDIR}; make clean
	cd ${BENCHMARKDIR}; make clean
	cd ${EXAMPLEDIR}; make clean
