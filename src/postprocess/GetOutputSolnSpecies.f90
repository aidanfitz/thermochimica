
!-------------------------------------------------------------------------------
!
!> \file    GetOutputSolnSpecies.f90
!> \brief   Get specific thermodynamic output.
!> \author  M.H.A. Piro
!> \date    Sept. 16, 2015
!
!
! Revisions:
! ==========
!
!   Date            Programmer          Description of change
!   ----            ----------          ---------------------
!   09/16/2015      M.H.A. Piro         Original code
!
!
! Purpose:
! ========
!
!> \details The purpose of this subroutine is to get specific thermodynamic
!! output from an equilibrium calculation.
!
!
!
! Pertinent variables:
! ====================
!
!> \param[in]     cSolnOut              A character string represnting the solution
!!                                       phase name.
!> \param[in]     cSpeciesOut           A character string representing the
!!                                       species.
!> \param[out]    dMolFractionOut       A double real scalar representing the
!!                                       mole fraction of said species.
!> \param[out]    dChemPotSpecies       A double real scalar representing the
!!                                       chemical potential of said species.
!> \param[out]    INFO                  An integer scalar indicating a successful
!!                                       exit (== 0) or an error (/= 0).
!!
!
!-------------------------------------------------------------------------------


subroutine GetOutputSolnSpecies(cSolnOut, lcSolnOut, cSpeciesOut, lcSpeciesOut, dMolFractionOut, dChemPotSpecies, INFO) &
    bind(C, name="TCAPI_getOutputSolnSpecies")

    USE ModuleThermo
    USE ModuleThermoIO
    USE,INTRINSIC :: ISO_C_BINDING

    implicit none

    integer,       intent(out)   :: INFO
    real(8),       intent(out)   :: dMolFractionOut, dChemPotSpecies
    character(kind=c_char,len=1), target, intent(in) :: cSolnOut(*), cSpeciesOut(*)
    integer(c_size_t), intent(in), value             :: lcSolnOut, lcSpeciesOut
    character(kind=c_char,len=lcSolnOut), pointer    :: fSolnOut
    character(kind=c_char,len=lcSpeciesOut), pointer :: fSpeciesOut
    integer                      :: i, j, k
    character(30)                :: cTemp

    call c_f_pointer(cptr=c_loc(cSolnOut), fptr=fSolnOut)
    call c_f_pointer(cptr=c_loc(cSpeciesOut), fptr=fSpeciesOut)

    ! Initialize variables:
    INFO            = 0
    dMolFractionOut = 0D0
    dChemPotSpecies = 0D0

    ! Only proceed if Thermochimica solved successfully:
    if (INFOThermo == 0) then

        ! Loop through stable soluton phases to find the one corresponding to the
        ! solution phase being requested:
        j = 0
        LOOP_SOLN: do i = 1, nSolnPhases
            k = -iAssemblage(nElements - i + 1)

            if (fSolnOut == cSolnPhaseName(k)) then
                ! Solution phase found.  Record integer index and exit loop.
                j = k
                exit LOOP_SOLN
            end if

        end do LOOP_SOLN

        ! Check to make sure that the solution phase was found:
        IF_SOLN: if (j /= 0) then
            k = 0
            ! Solution phase found.  Now, look for the species in this phase.
            LOOP_SPECIES: do i = nSpeciesPhase(j-1) + 1, nSpeciesPhase(j)

                ! Remove leading blanks:
                cTemp = ADJUSTL(cSpeciesName(i))

                ! Loop through species in this phase:
                if (cTemp == fSpeciesOut) then
                    ! Solution species found.  Record index and exit loop.
                    k = i
                    exit LOOP_SPECIES
                end if

            end do LOOP_SPECIES

            ! Check if the solution species was found:
            if (k /= 0 ) then
                ! Solution species found.
                dMolFractionOut = dMolFraction(k)

                ! Compute the chemical potential of this solution species
                do j = 1, nElements
                    dChemPotSpecies = dChemPotSpecies + dElementPotential(j) * dStoichSpecies(k,j)
                end do

                ! Convert to units of J/mol:
                dChemPotSpecies = dChemPotSpecies * dIdealConstant * dTemperature

            else
                ! Solution species not found.  Record an error:
                INFO = 2
            end if
        else
            ! This solution phase was not found.  Report an error:
            INFO = 1
        end if IF_SOLN

    else
        ! Record an error with INFO if INFOThermo /= 0.
        INFO = -1
    end if

    return

end subroutine GetOutputSolnSpecies
