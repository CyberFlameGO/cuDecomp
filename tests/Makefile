TESTS_CC=cc/transpose_test cc/halo_test
TESTS_F90=fortran/transpose_test fortran/halo_test

TESTTARGETS = ${TESTS_CC}
ifeq (${strip ${BUILD_FORTRAN}},1)
TESTTARGETS += ${TESTS_F90}
endif

TRANSPOSE_TEST_CC_BINS = cc/transpose_test_R32 \
                         cc/transpose_test_R64 \
                         cc/transpose_test_C32 \
                         cc/transpose_test_C64
HALO_TEST_CC_BINS = cc/halo_test_R32 \
                    cc/halo_test_R64 \
                    cc/halo_test_C32 \
                    cc/halo_test_C64

TRANSPOSE_TEST_F90_BINS = fortran/transpose_test_R32 \
                          fortran/transpose_test_R64 \
                          fortran/transpose_test_C32 \
                          fortran/transpose_test_C64
HALO_TEST_F90_BINS = fortran/halo_test_R32 \
                     fortran/halo_test_R64 \
                     fortran/halo_test_C32 \
                     fortran/halo_test_C64

.PHONY: all cc/transpose_test cc/halo_test fortran/tranpose_test fortran/fortran_halo_test

all: ${TESTTARGETS}

cc/transpose_test: ${TRANSPOSE_TEST_CC_BINS}
cc/transpose_test_R32: cc/transpose_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DR32 -o $@ $< ${LIBS}
cc/transpose_test_R64: cc/transpose_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DR64 -o $@ $< ${LIBS}
cc/transpose_test_C32: cc/transpose_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DC32 -o $@ $< ${LIBS}
cc/transpose_test_C64: cc/transpose_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DC64 -o $@ $< ${LIBS}

cc/halo_test: ${HALO_TEST_CC_BINS}
cc/halo_test_R32: cc/halo_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DR32 -o $@ $< ${LIBS}
cc/halo_test_R64: cc/halo_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DR64 -o $@ $< ${LIBS}
cc/halo_test_C32: cc/halo_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DC32 -o $@ $< ${LIBS}
cc/halo_test_C64: cc/halo_test.cc ${CUDECOMPLIB}
	${MPICXX} ${DEFINES} ${CXXFLAGS} ${INCLUDES} -DC64 -o $@ $< ${LIBS}

fortran/transpose_test: ${TRANSPOSE_TEST_F90_BINS}
fortran/transpose_test_R32: fortran/transpose_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DR32 -o $@ $< ${FLIBS}
fortran/transpose_test_R64: fortran/transpose_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DR64 -o $@ $< ${FLIBS}
fortran/transpose_test_C32: fortran/transpose_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DC32 -o $@ $< ${FLIBS}
fortran/transpose_test_C64: fortran/transpose_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DC64 -o $@ $< ${FLIBS}

fortran/halo_test: ${HALO_TEST_F90_BINS}
fortran/halo_test_R32: fortran/halo_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DR32 -o $@ $< ${FLIBS}
fortran/halo_test_R64: fortran/halo_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DR64 -o $@ $< ${FLIBS}
fortran/halo_test_C32: fortran/halo_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DC32 -o $@ $< ${FLIBS}
fortran/halo_test_C64: fortran/halo_test.f90 ${CUDECOMPLIB}
	${MPIF90} -cuda -cpp  ${DEFINES} ${INCLUDES} -DC64 -o $@ $< ${FLIBS}

clean:
	rm -f cc/transpose_test_* fortran/transpose_test_*
	rm -f cc/halo_test_* fortran/halo_test_*
	rm -f *.mod
