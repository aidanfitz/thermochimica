
    !-------------------------------------------------------------------------------------------------------------
    !
    !> \file    TestThermo13.F90
    !> \brief   Unit test - unsupported mass unit.
    !> \author  M.H.A. Piro, B.W.N. Fitzpatrick
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
    !    02/07/2012    M.H.A. Piro         Original code
    !    11/07/2018    B.W.N. Fitzpatrick  Changed to a C-O database
    !    04/17/2024    A.E.F. Fitzsimmons   Naming convention change
    !
    ! Purpose:
    ! ========
    !> \details The purpose of this unit test is to ensure that Thermochimica does not proceed if a mass unit is
    !! specified, but is not supported.
    !
    !-------------------------------------------------------------------------------------------------------------

program ThermoTest13

    USE ModuleThermoIO

    implicit none

    ! Initialize variables:
    dTemperature            = 300D0
    dPressure               = 1D0
    dElementMass            = 1D0
    cInputUnitTemperature   = 'K'
    cInputUnitPressure      = 'atm'
    cInputUnitMass          = 'elephants'  !an unsupported unit mass.
    cThermoFileName         = DATA_DIRECTORY // 'CO.dat'

    ! Parse the ChemSage data-file:
    call ParseCSDataFile(cThermoFileName)

    ! Call Thermochimica:
    call Thermochimica

    if (INFOThermo == 4) then
        ! The unit test passed: the correct error code was reported and exited gracefully.
        print *, 'TestThermo13: PASS'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(0)
    else
        ! The unit test failed.
        print *, 'TestThermo13: FAIL <---'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(1)
    end if

    ! Reset Thermochimica:
    call ResetThermo

end program ThermoTest13
