module matvec_mod
implicit none ; private

public :: matvec

contains 

subroutine matvec(size1,size2,a,b,c)
  integer,                      intent(in)  :: size1,size2
  real, dimension(size1,size2), intent(in)  :: a
  real, dimension(size2),       intent(in)  :: b
  real, dimension(size1),       intent(inout) :: c
  integer                                   :: j

  c=0.
  do j=1,size2
!     do i=1,size1
        c(:) = c(:) + a(:,j) * b(j)
!     enddo
  enddo
end subroutine

end module matvec_mod
