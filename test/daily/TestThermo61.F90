
    !-------------------------------------------------------------------------------------------------------------
    !
    !> \file    TestThermo87.F90
    !> \brief   SUBM mistmatch coefficients and charges.
    !> \author  M.H.A. Piro, M. Poschmann
    !
    ! DISCLAIMER
    ! ==========
    ! All of the programming herein is original unless otherwise specified.  Details of contributions to the
    ! programming are given below.
    !
    ! Revisions:
    ! ==========
    !    Date          Programmer          Description of change
    !    ----          ----------          ---------------------
    !    05/14/2013    M.H.A. Piro         Original code
    !    11/08/2022    M. Poschmann        SUBM Test Case
    !    04/17/2024    A.E.F. Fitzsimmons  Naming convention change
    !
    ! Purpose:
    ! ========
    !> \details The purpose of this application test is to ensure that Thermochimica computes the correct
    !!  results a SUBM phase where not all charges and coefficients are equal, i.e. with Zr(4+) + O(2-) -> ZrO2.
    !!  Two constituents on second sublattice are tested.
    !
    !-------------------------------------------------------------------------------------------------------------

program TestThermo61

    USE ModuleThermoIO
    USE ModuleThermo

    implicit none

    real(8) :: gibbscheck
    logical :: s1pass


    ! Specify units:
    cInputUnitTemperature = 'K'
    cInputUnitPressure    = 'atm'
    cInputUnitMass        = 'moles'
    cThermoFileName       = DATA_DIRECTORY // 'ZrFeKClNaFOLi.dat'

    ! Specify values:
    dTemperature          = 1000
    dPressure             = 1.0D0
    dElementMass          = 0D0

    dElementMass(3)       = 0D0                              ! Li
    dElementMass(11)      = 0D0                              ! Na
    dElementMass(17)      = 2D0                              ! Cl
    dElementMass(9)       = 0D0                              ! F
    dElementMass(26)      = 0D0                              ! Fe
    dElementMass(8)       = 1D0                              ! O
    dElementMass(19)      = 0D0                              ! K
    dElementMass(40)      = 1D0                              ! Zr

    gibbscheck = -1.50268D04

    ! Parse the ChemSage data-file:
    call ParseCSDataFile(cThermoFileName)

    ! Call Thermochimica:
    call Thermochimica

    ! Check results:
    s1pass = .FALSE.

    ! Check results:
    if (INFOThermo == 0) then
        if ((DABS((dGibbsEnergySys - (gibbscheck))/(gibbscheck)) < 1D-3)) then
            s1pass = .TRUE.
        end if
    end if

    if (s1pass) then
        ! The test passed:
        print *, 'TestThermo61: PASS'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(0)
    else
        ! The test failed.
        print *, 'TestThermo61: FAIL <---'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(1)
    end if

end program TestThermo61
