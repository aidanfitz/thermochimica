
    !-------------------------------------------------------------------------------------------------------------
    !
    !> \file    TestThermo40.F90
    !> \brief   Spot test - 2250K with 80% Mo, 20% Ru.
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
    !    05/14/2013    M.H.A. Piro         Original code
    !    08/31/2018    B.W.N. Fitzpatrick  Modification to use Kaye's Pd-Ru-Tc-Mo system
    !    05/06/2024    A.E.F. Fitzsimmons  Naming convention change
    !    08/27/2024    A.E.F. Fitzsimmons  SQA, standardizing tests
    !
    ! Purpose:
    ! ========
    !> \details The purpose of this application test is to ensure that Thermochimica computes the correct
    !! results for the Pd-Ru-Tc-Mo system at 2250K with 80% Mo, 20% Ru.
    !
    !-------------------------------------------------------------------------------------------------------------

program TestThermo19

    USE ModuleThermoIO
    USE ModuleThermo
    USE ModuleTesting

    implicit none

    ! Init variables
    logical :: lPass
    real(8) :: dGibbsCheck, dHeatCapacityCheck
    integer :: nSpeciesTest
    integer, allocatable :: iSpeciesIndexTest(:)
    real(8), allocatable :: dMolFractionTest(:)

    ! Specify units:
    cInputUnitTemperature  = 'K'
    cInputUnitPressure     = 'atm'
    cInputUnitMass         = 'moles'
    cThermoFileName        = DATA_DIRECTORY // 'NobleMetals-Kaye.dat'

    ! Specify values:
    dPressure              = 1D0
    dTemperature           = 2250D0
    dElementMass(42)       = 0.8D0        ! Mo
    dElementMass(44)       = 0.2D0        ! Ru

    ! Init test values
    dGibbsCheck            = -1.44373D05
    dHeatCapacityCheck     = 40.2726
    nSpeciesTest           = 3
    iSpeciesIndexTest      = [1, 2, 7] !Mo, Mo2, Ru
    dMolFractionTest       = [6.40268D-09, 1.93080D-013, 0.23683D0]
    lPass                  = .FALSE.

    ! Parse the ChemSage data-file:
    call ParseCSDataFile(cThermoFileName)

    ! Call Thermochimica:
    call Thermochimica
    call HeatCapacity

    !Execute the test for mole fractions, gibbs energy and heat capacity
    call testProperties(dGibbsCheck, dHeatCapacityCheck, nSpeciesTest, iSpeciesIndexTest, dMolFractionTest, lPass)

    ! Deallocation
    deallocate(iSpeciesIndexTest, dMolFractionTest)

    if (lPass) then
        ! The test passed:
        print *, 'TestThermo19: PASS'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(0)
    else
        ! The test failed.
        print *, 'TestThermo19: FAIL <---'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(1)
    end if

end program TestThermo19
