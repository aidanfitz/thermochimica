
    !-------------------------------------------------------------------------------------------------------------
    !
    !> \file    TestThermo48.F90
    !> \brief   Spot test - 1973K with 10% Mo, 30% Pd, 60% Ru.
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
    !
    ! Purpose:
    ! ========
    !> \details The purpose of this application test is to ensure that Thermochimica computes the correct
    !! results for the Pd-Ru-Tc-Mo system at 1973K with 10% Mo, 30% Pd, 60% Ru.
    !
    !-------------------------------------------------------------------------------------------------------------

program TestThermo27

    USE ModuleThermoIO
    USE ModuleThermo

    implicit none

    integer :: i,j,k
    logical :: s1pass, s2pass, s3pass, cppass

    ! Specify units:
    cInputUnitTemperature  = 'K'
    cInputUnitPressure     = 'atm'
    cInputUnitMass         = 'moles'
    cThermoFileName        = DATA_DIRECTORY // 'NobleMetals-Kaye.dat'

    ! Specify values:
    dPressure              = 1D0
    dTemperature           = 1973D0
    dElementMass(42)       = 0.1D0        ! Mo
    dElementMass(46)       = 0.3D0        ! Pd
    dElementMass(44)       = 0.6D0        ! Ru

    ! Parse the ChemSage data-file:
    call ParseCSDataFile(cThermoFileName)

    ! Call Thermochimica:
    call Thermochimica
    call HeatCapacity

    s1pass = .FALSE.
    s2pass = .FALSE.
    s3pass = .FALSE.
    cppass = .FALSE.
    ! Check results:
    if (INFOThermo == 0) then
        if (DABS(dGibbsEnergySys - (-1.27255D5))/(-1.27255D5) < 1D-3) then
            do i = 1, nSolnPhases
                k = -iAssemblage(nElements + 1 - i)
                if (cSolnPhaseName(k) == 'LiqN') then
                    do j = nSpeciesPhase(k-1) + 1, nSpeciesPhase(k)
                        if (TRIM(ADJUSTL(cSpeciesName(j))) == 'Ru') then
                            if (DABS(dMolFraction(j) - 0.13768D0)/0.13768D0 < 1D-3) s1pass = .TRUE.
                        else if (TRIM(ADJUSTL(cSpeciesName(j))) == 'Mo') then
                            if (DABS(dMolFraction(j) - 0.12624D0)/0.12624D0 < 1D-3) s2pass = .TRUE.
                        else if (TRIM(ADJUSTL(cSpeciesName(j))) == 'Pd') then
                            if (DABS(dMolFraction(j) - 0.73608D0)/0.73608D0 < 1D-3) s3pass = .TRUE.
                        end if
                    end do
                end if
            end do
            if (ABS(dHeatCapacity - 78.2758)/78.2758 < 1D-3) cppass = .TRUE.
        end if
    end if

    if (s1pass .AND. s2pass .AND. s3pass .AND. cppass) then
        ! The test passed:
        print *, 'TestThermo27: PASS'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(0)
    else
        ! The test failed.
        print *, 'TestThermo27: FAIL <---'
        ! Reset Thermochimica:
        call ResetThermo
        call EXIT(1)
    end if

end program TestThermo27
