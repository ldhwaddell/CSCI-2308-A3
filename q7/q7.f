      Program Brent1Example

      IMPLICIT NONE

      INTEGER, PARAMETER :: N = 3 ! Number of nonlinear equations
      INTEGER, PARAMETER :: LWA = N*(N+3) ! Size of work array, WA

      INTEGER :: INFO

      DOUBLE PRECISION :: X(N),FVEC(N),TOL,WA(LWA)  
                      
      EXTERNAL FCN ! This function name is defined in a separate 
                   ! software component external to the main program 
      !--------------------------------------------------------------                                                        
                                                                    
      TOL = 1.D-5 ! Set tolerance                                                      

      !STARTING VALUES.
      X(1) = -0.5D0
      X(2) = 9.0D0
      X(3) = -9.0D0

      CALL BRENT1(FCN,N,X,FVEC,TOL,INFO,WA,LWA)

      WRITE (6,*) 'The value of INFO is ',INFO
      WRITE(6,*) 'Solution values = ',X
      WRITE(6,*) 'Residual values = ',FVEC
      READ(*,*)

      STOP

      End Program Brent1Example


      SUBROUTINE FCN(N,X,FVEC,IFLAG)
                                  
      INTEGER :: N,IFLAG
      DOUBLE PRECISION :: X(N),FVEC(N),SIGMA,r, b

      SIGMA = 10
      r = 28
      b = 8/3

      FVEC(1) = SIGMA * (X(2)-X(1))
      FVEC(2) = r * X(1) - X(2) - X(1) * X(3)
      FVEC(3) = X(1) * X(2) - b * X(3)

      RETURN

      END SUBROUTINE FCN

C-----------------------------------------------------------------------

      SUBROUTINE BRENT1(FCN,N,X,FVEC,TOL,INFO,WA,LWA)                   
      INTEGER N,INFO,LWA
      DOUBLE PRECISION TOL
      DOUBLE PRECISION X(N),FVEC(N),WA(LWA)
      EXTERNAL FCN
C     **********
C
C     SUBROUTINE BRENT1
C
C     THE PURPOSE OF THIS SUBROUTINE IS TO FIND A ZERO OF
C     A SYSTEM OF N NONLINEAR EQUATIONS IN N VARIABLES BY A
C     METHOD DUE TO R. BRENT. THIS IS DONE BY USING THE
C     MORE GENERAL NONLINEAR EQUATION SOLVER BRENTM.
C
C     THE SUBROUTINE STATEMENT IS
C
C       SUBROUTINE BRENT1(FCN,N,X,FVEC,TOL,INFO,WA,LWA)
C
C     WHERE
C
C       FCN IS THE NAME OF THE USER-SUPPLIED SUBROUTINE WHICH
C         CALCULATES COMPONENTS OF THE FUNCTION. FCN SHOULD BE
C         DECLARED IN AN EXTERNAL STATEMENT IN THE USER CALLING
C         PROGRAM, AND SHOULD BE WRITTEN AS FOLLOWS.
C
C         SUBROUTINE FCN(N,X,FVEC,IFLAG)
C         INTEGER N,IFLAG
C         DOUBLE PRECISION X(N),FVEC(N)
C         ----------
C         CALCULATE THE IFLAG-TH COMPONENT OF THE FUNCTION
C         AND RETURN THIS VALUE IN FVEC(IFLAG).
C         ----------
C         RETURN
C         END
C
C         THE VALUE OF IFLAG SHOULD NOT BE CHANGED BY FCN UNLESS
C         THE USER WANTS TO TERMINATE EXECUTION OF BRENT1.
C         IN THIS CASE SET IFLAG TO A NEGATIVE INTEGER.
C
C       N IS A POSITIVE INTEGER INPUT VARIABLE SET TO THE NUMBER
C         OF EQUATIONS AND VARIABLES.
C
C       X IS AN ARRAY OF LENGTH N. ON INPUT IT MUST CONTAIN
C         AN INITIAL ESTIMATE OF THE SOLUTION VECTOR. ON OUTPUT X
C         CONTAINS THE FINAL ESTIMATE OF THE SOLUTION VECTOR.
C
C       FVEC IS AN ARRAY OF LENGTH N. ON OUTPUT IT CONTAINS
C         THE FINAL RESIDUALS.
C
C       TOL IS A NONNEGATIVE INPUT VARIABLE. THE ALGORITHM CONVERGES
C         IF EITHER ALL THE RESIDUALS ARE AT MOST TOL IN MAGNITUDE,
C         OR IF THE ALGORITHM ESTIMATES THAT THE RELATIVE ERROR
C         BETWEEN X AND THE SOLUTION IS AT MOST TOL.
C
C       INFO IS AN INTEGER OUTPUT VARIABLE SET AS FOLLOWS. IF
C         THE USER HAS TERMINATED EXECUTION, INFO WILL BE SET TO
C         THE (NEGATIVE) VALUE OF IFLAG. SEE DESCRIPTION OF FCN.
C         OTHERWISE
C
C         INFO = 0   IMPROPER INPUT PARAMETERS.
C
C         INFO = 1   ALL RESIDUALS ARE AT MOST TOL IN MAGNITUDE.
C
C         INFO = 2   ALGORITHM ESTIMATES THAT THE RELATIVE ERROR
C                    BETWEEN X AND THE SOLUTION IS AT MOST TOL.
C
C         INFO = 3   CONDITIONS FOR INFO = 1 AND INFO = 2 BOTH HOLD.
C
C         INFO = 4   NUMBER OF FUNCTION EVALUATIONS HAS REACHED OR
C                    EXCEEDED 50*(N+3).
C
C         INFO = 5   APPROXIMATE JACOBIAN MATRIX IS SINGULAR.
C
C         INFO = 6   ITERATION IS NOT MAKING GOOD PROGRESS.
C
C         INFO = 7   ITERATION IS DIVERGING.
C
C         INFO = 8   ITERATION IS CONVERGING, BUT TOL IS TOO
C                    SMALL, OR THE CONVERGENCE IS VERY SLOW
C                    DUE TO A JACOBIAN SINGULAR NEAR THE OUTPUT
C                    X OR DUE TO BADLY SCALED VARIABLES.
C
C       WA IS A WORK ARRAY OF LENGTH LWA.
C
C       LWA IS A POSITIVE INTEGER INPUT VARIABLE NOT LESS THAN
C         N*(N+3).
C
C     SUBPROGRAMS REQUIRED
C
C       USER-SUPPLIED ...... FCN, BRENTM
C
C       FORTRAN-SUPPLIED ... DLOG
C
C     **********
      INTEGER I,IVAR,MAXFEV,MOPT,NFEV
      DOUBLE PRECISION EMAX,FTOL,TEMP,XTOL,ZERO
      DOUBLE PRECISION DFLOAT
      DATA ZERO /0.D0/
      DFLOAT(IVAR) = IVAR
      INFO = 0
C
C     CHECK THE INPUT PARAMETERS FOR ERRORS.
C
      IF (N .LE. 0 .OR. TOL .LT. ZERO .OR. LWA .LT. N*(N+3)) GO TO 30
C
C     DETERMINE AN OPTIMAL VALUE FOR MOPT.
C
      EMAX = ZERO
      DO 10 I = 1, N
         TEMP = DLOG(DFLOAT(I+1))/DFLOAT(N+2*I+1)
         IF (TEMP .LT. EMAX) GO TO 20
         MOPT = I
         EMAX = TEMP
   10    CONTINUE
   20 CONTINUE
C
C     CALL BRENTM.
C
      MAXFEV = 50*(N + 3)
      FTOL = TOL
      XTOL = TOL
      CALL BRENTM(FCN,N,X,FVEC,FTOL,XTOL,MAXFEV,MOPT,
     1           INFO,NFEV,WA(3*N+1),N,WA(1),WA(N+1),WA(2*N+1))
   30 CONTINUE
      RETURN
C
C     LAST CARD OF SUBROUTINE BRENT1.
C
      END
      SUBROUTINE BRENTM(FCN,N,X,FVEC,FTOL,XTOL,MAXFEV,MOPT,             
     1                  INFO,NFEV,Q,LDQ,SIGMA,WA1,WA2)
      INTEGER N,MAXFEV,MOPT,INFO,NFEV,LDQ
      DOUBLE PRECISION FTOL,XTOL
      DOUBLE PRECISION X(N),FVEC(N),Q(LDQ,N),SIGMA(N),WA1(N),WA2(N)
C     **********
C
C     SUBROUTINE BRENTM
C
C     THE PURPOSE OF THIS SUBROUTINE IS TO FIND A ZERO TO
C     A SYSTEM OF N NONLINEAR EQUATIONS IN N VARIABLES BY A
C     METHOD DUE TO R. BRENT.
C
C     THE SUBROUTINE STATEMENT IS
C
C       SUBROUTINE BRENTM(FCN,N,X,FVEC,FTOL,XTOL,MAXFEV,MOPT,
C                         INFO,NFEV,Q,LDQ,SIGMA,WA1,WA2)
C
C     WHERE
C
C       FCN IS THE NAME OF THE USER-SUPPLIED SUBROUTINE WHICH
C         CALCULATES COMPONENTS OF THE FUNCTION. FCN SHOULD BE
C         DECLARED IN AN EXTERNAL STATEMENT IN THE USER CALLING
C         PROGRAM, AND SHOULD BE WRITTEN AS FOLLOWS.
C
C         SUBROUTINE FCN(N,X,FVEC,IFLAG)
C         INTEGER N,IFLAG
C         DOUBLE PRECISION X(N),FVEC(N)
C         ----------
C         CALCULATE THE IFLAG-TH COMPONENT OF THE FUNCTION
C         AND RETURN THIS VALUE IN FVEC(IFLAG).
C         ----------
C         RETURN
C         END
C
C         THE VALUE OF IFLAG SHOULD NOT BE CHANGED BY FCN UNLESS
C         THE USER WANTS TO TERMINATE EXECUTION OF BRENTM.
C         IN THIS CASE SET IFLAG TO A NEGATIVE INTEGER.
C
C       N IS A POSITIVE INTEGER INPUT VARIABLE SET TO THE NUMBER OF
C         EQUATIONS AND VARIABLES.
C
C       X IS AN ARRAY OF LENGTH N. ON INPUT IT MUST CONTAIN
C         AN ESTIMATE TO THE SOLUTION OF THE SYSTEM OF EQUATIONS.
C         ON OUTPUT X CONTAINS THE FINAL ESTIMATE TO THE SOLUTION
C         OF THE SYSTEM OF EQUATIONS.
C
C       FVEC IS AN ARRAY OF LENGTH N. ON OUTPUT IT CONTAINS
C         THE FINAL RESIDUALS.
C
C       FTOL IS A NONNEGATIVE INPUT VARIABLE. CONVERGENCE
C         OCCURS IF ALL RESIDUALS ARE AT MOST FTOL IN MAGNITUDE.
C
C       XTOL IS A NONNEGATIVE INPUT VARIABLE. CONVERGENCE
C         OCCURS IF THE RELATIVE ERROR BETWEEN TWO SUCCESSIVE
C         ITERATES IS AT MOST XTOL.
C
C       MAXFEV IS A POSITIVE INTEGER INPUT VARIABLE. TERMINATION
C         OCCURS IF THE NUMBER OF FUNCTION EVALUATIONS IS AT
C         LEAST MAXFEV BY THE END OF AN ITERATION. IN BRENTM,
C         A FUNCTION EVALUATION CORRESPONDS TO N CALLS TO FCN.
C
C       MOPT IS A POSITIVE INTEGER INPUT VARIABLE. MOPT SPECIFIES
C         THE NUMBER OF TIMES THAT THE APPROXIMATE JACOBIAN IS
C         USED DURING EACH ITERATION WHICH EMPLOYS ITERATIVE
C         REFINEMENT. IF MOPT IS 1, NO ITERATIVE REFINEMENT WILL
C         BE DONE. MAXIMUM EFFICIENCY IS USUALLY OBTAINED IF
C         MOPT MAXIMIZES LOG(K+1)/(N+2*K+1) FOR K = 1,...,N.
C
C       INFO IS AN INTEGER OUTPUT VARIABLE SET AS FOLLOWS. IF
C         THE USER HAS TERMINATED EXECUTION, INFO WILL BE SET TO
C         THE (NEGATIVE) VALUE OF IFLAG. SEE DESCRIPTION OF FCN.
C         OTHERWISE
C
C         INFO = 0   IMPROPER INPUT PARAMETERS.
C
C         INFO = 1   ALL RESIDUALS ARE AT MOST FTOL IN MAGNITUDE.
C
C         INFO = 2   RELATIVE ERROR BETWEEN TWO SUCCESSIVE ITERATES
C                    IS AT MOST XTOL.
C
C         INFO = 3   CONDITIONS FOR INFO = 1 AND INFO = 2 BOTH HOLD.
C
C         INFO = 4   NUMBER OF FUNCTION EVALUATIONS HAS REACHED OR
C                    EXCEEDED MAXFEV.
C
C         INFO = 5   APPROXIMATE JACOBIAN MATRIX IS SINGULAR.
C
C         INFO = 6   ITERATION IS NOT MAKING GOOD PROGRESS.
C
C         INFO = 7   ITERATION IS DIVERGING.
C
C         INFO = 8   ITERATION IS CONVERGING, BUT XTOL IS TOO
C                    SMALL, OR THE CONVERGENCE IS VERY SLOW
C                    DUE TO A JACOBIAN SINGULAR NEAR THE OUTPUT
C                    X OR DUE TO BADLY SCALED VARIABLES.
C
C       NFEV IS AN INTEGER OUTPUT VARIABLE SET TO THE NUMBER OF
C         FUNCTION EVALUATIONS USED IN PRODUCING X. IN BRENTM,
C         A FUNCTION EVALUATION CORRESPONDS TO N CALLS TO FCN.
C
C       Q IS AN N BY N ARRAY. IF JAC DENOTES THE APPROXIMATE
C         JACOBIAN, THEN ON OUTPUT Q IS (A MULTIPLE OF) AN
C         ORTHOGONAL MATRIX SUCH THAT JAC*Q IS A LOWER TRIANGULAR
C         MATRIX. ONLY THE DIAGONAL ELEMENTS OF JAC*Q NEED
C         TO BE STORED, AND THESE CAN BE FOUND IN SIGMA.
C
C       LDQ IS A POSITIVE INTEGER INPUT VARIABLE NOT LESS THAN N
C         WHICH SPECIFIES THE LEADING DIMENSION OF THE ARRAY Q.
C
C       SIGMA IS A LINEAR ARRAY OF LENGTH N. ON OUTPUT SIGMA
C         CONTAINS THE DIAGONAL ELEMENTS OF THE MATRIX JAC*Q.
C         SEE DESCRIPTION OF Q.
C
C       WA1 AND WA2 ARE LINEAR WORK ARRAYS OF LENGTH N.
C
C     SUBPROGRAMS REQUIRED
C
C       USER-SUPPLIED ...... FCN
C
C       FORTRAN-SUPPLIED ... DABS,DMAX1,DSQRT,DSIGN
C
C     **********
      INTEGER I,IFLAG,J,K,M,NFCALL,NIER6,NIER7,NIER8,NSING
      LOGICAL CONV
      DOUBLE PRECISION DELTA,DIFIT,DIFIT1,EPS,EPSMCH,ETA,FKY,FKZ,
     1       FNORM,FNORM1,H,P05,SCALE,SKNORM,TEMP,XNORM,ZERO
      DATA ZERO,P05,SCALE /0.D0,5.D-2,1.D1/
C
C     WARNING.
C
C     THIS IS AN IBM CODE. TO RUN THIS CODE ON OTHER MACHINES IT
C     IS NECESSARY TO CHANGE THE VALUE OF THE MACHINE PRECISION
C     EPSMCH. THE MACHINE PRECISION IS THE SMALLEST FLOATING
C     POINT NUMBER EPSMCH SUCH THAT
C
C           1 + EPSMCH .GT. 1
C
C     IN WORKING PRECISION. IF IN DOUBT ABOUT THE VALUE OF
C     EPSMCH, THEN THE FOLLOWING PROGRAM SEGMENT DETERMINES
C     EPSMCH ON MOST MACHINES.
C
C     EPSMCH = 0.5D0
C   1 CONTINUE
C     IF (1.D0+EPSMCH .EQ. 1.D0) GO TO 2
C     EPSMCH = 0.5D0*EPSMCH
C     GO TO 1
C   2 CONTINUE
C     EPSMCH = 2.D0*EPSMCH
C
C     THE IBM DOUBLE PRECISION EPSMCH.
C
      EPSMCH = 16.D0**(-13)
C
      INFO = 0
      IFLAG = 0
      NFEV = 0
      NFCALL = 0
C
C     CHECK THE INPUT PARAMETERS FOR ERRORS.
C
      IF (N .LE. 0 .OR. FTOL .LT. ZERO .OR. XTOL .LT. ZERO .OR.
     1    MAXFEV .LE. 0 .OR. MOPT .LE. 0 .OR. LDQ .LT. N) GO TO 220
C
C     INITIALIZE SOME OF THE VARIABLES.
C
      NIER6 = -1
      NIER7 = -1
      NIER8 = 0
      FNORM = ZERO
      DIFIT = ZERO
      XNORM = ZERO
      DO 10 I = 1, N
         XNORM = DMAX1(XNORM,DABS(X(I)))
   10    CONTINUE
      EPS = DSQRT(EPSMCH)
      DELTA = SCALE*XNORM
      IF (XNORM .EQ. ZERO) DELTA = SCALE
C
C     ENTER THE PRINCIPAL ITERATION.
C
   20 CONTINUE
C
C     TO PRINT THE ITERATES, PLACE WRITE STATEMENTS
C     FOR THE VECTOR X HERE.
C
      NSING = N
      FNORM1 = FNORM
      DIFIT1 = DIFIT
      FNORM = ZERO
C
C     COMPUTE THE STEP H FOR THE DIVIDED DIFFERENCE WHICH
C     APPROXIMATES THE K-TH ROW OF THE JACOBIAN MATRIX.
C
      H = EPS*XNORM
      IF (H .EQ. ZERO) H = EPS
      DO 40 J = 1, N
         DO 30 I = 1, N
            Q(I,J) = ZERO
   30       CONTINUE
         Q(J,J) = H
         WA1(J) = X(J)
   40    CONTINUE
C
C     ENTER A SUBITERATION.
C
      DO 150 K = 1, N
         IFLAG = K
         CALL FCN(N,WA1,FVEC,IFLAG)
         FKY = FVEC(K)
         NFCALL = NFCALL + 1
         NFEV = NFCALL/N
         IF (IFLAG .LT. 0) GO TO 230
         FNORM = DMAX1(FNORM,DABS(FKY))
C
C        COMPUTE THE K-TH ROW OF THE JACOBIAN MATRIX.
C
         DO 60 J = K, N
            DO 50 I = 1, N
               WA2(I) = WA1(I) + Q(I,J)
   50          CONTINUE
            CALL FCN(N,WA2,FVEC,IFLAG)
            FKZ = FVEC(K)
            NFCALL = NFCALL + 1
            NFEV = NFCALL/N
            IF (IFLAG .LT. 0) GO TO 230
            SIGMA(J) = FKZ - FKY
   60       CONTINUE
         FVEC(K) = FKY
C
C        COMPUTE THE HOUSEHOLDER TRANSFORMATION TO REDUCE THE K-TH ROW
C        OF THE JACOBIAN MATRIX TO A MULTIPLE OF THE K-TH UNIT VECTOR.
C
         ETA = ZERO
         DO 70 I = K, N
            ETA = DMAX1(ETA,DABS(SIGMA(I)))
   70       CONTINUE
         IF (ETA .EQ. ZERO) GO TO 150
         NSING = NSING - 1
         SKNORM = ZERO
         DO 80 I = K, N
            SIGMA(I) = SIGMA(I)/ETA
            SKNORM = SKNORM + SIGMA(I)**2
   80       CONTINUE
         SKNORM = DSQRT(SKNORM)
         IF (SIGMA(K) .LT. ZERO) SKNORM = -SKNORM
         SIGMA(K) = SIGMA(K) + SKNORM
C
C        APPLY THE TRANSFORMATION AND COMPUTE THE MATRIX Q.
C
         DO 90 I = 1, N
            WA2(I) = ZERO
   90       CONTINUE
         DO 110 J = K, N
            TEMP = SIGMA(J)
            DO 100 I = 1, N
               WA2(I) = WA2(I) + TEMP*Q(I,J)
  100          CONTINUE
  110       CONTINUE
         DO 130 J = K, N
            TEMP = SIGMA(J)/(SKNORM*SIGMA(K))
            DO 120 I = 1, N
               Q(I,J) = Q(I,J) - TEMP*WA2(I)
  120          CONTINUE
  130       CONTINUE
C
C        COMPUTE THE SUBITERATE.
C
         SIGMA(K) = SKNORM*ETA
         TEMP = FKY/SIGMA(K)
         IF (H*DABS(TEMP) .GT. DELTA) TEMP = DSIGN(DELTA/H,TEMP)
         DO 140 I = 1, N
            WA1(I) = WA1(I) + TEMP*Q(I,K)
  140       CONTINUE
  150    CONTINUE
C
C     COMPUTE THE NORMS OF THE ITERATE AND CORRECTION VECTOR.
C
      XNORM = ZERO
      DIFIT = ZERO
      DO 160 I = 1, N
         XNORM = DMAX1(XNORM,DABS(WA1(I)))
         DIFIT = DMAX1(DIFIT,DABS(X(I)-WA1(I)))
         X(I) = WA1(I)
  160    CONTINUE
C
C     UPDATE THE BOUND ON THE CORRECTION VECTOR.
C
      DELTA = DMAX1(DELTA,SCALE*XNORM)
C
C     DETERMINE THE PROGRESS OF THE ITERATION.
C
      CONV = (FNORM .LT. FNORM1 .AND. DIFIT .LT. DIFIT1 .AND.
     1        NSING .EQ. 0)
      NIER6 = NIER6 + 1
      NIER7 = NIER7 + 1
      NIER8 = NIER8 + 1
      IF (CONV) NIER6 = 0
      IF (FNORM .LT. FNORM1 .OR. DIFIT .LT. DIFIT1) NIER7 = 0
      IF (DIFIT .GT. EPS*XNORM) NIER8 = 0
C
C     TESTS FOR CONVERGENCE.
C
      IF (FNORM .LE. FTOL) INFO = 1
      IF (DIFIT .LE. XTOL*XNORM .AND. CONV) INFO = 2
      IF (FNORM .LE. FTOL .AND. INFO .EQ. 2) INFO = 3
      IF (INFO .NE. 0) GO TO 230
C
C     TESTS FOR TERMINATION.
C
      IF (NFEV .GE. MAXFEV) INFO = 4
      IF (NSING .EQ. N) INFO = 5
      IF (NIER6 .EQ. 5) INFO = 6
      IF (NIER7 .EQ. 3) INFO = 7
      IF (NIER8 .EQ. 4) INFO = 8
      IF (INFO .NE. 0) GO TO 230
C
C     ITERATIVE REFINEMENT IS USED IF THE ITERATION IS CONVERGING.
C
      IF (.NOT. CONV .OR. DIFIT .GT. P05*XNORM .OR. MOPT .EQ. 1)
     1    GO TO 220
C
C     START ITERATIVE REFINEMENT.
C
      DO 210 M = 2, MOPT
         FNORM1 = FNORM
         FNORM = ZERO
         DO 190 K = 1, N
            IFLAG = K
            CALL FCN(N,WA1,FVEC,IFLAG)
            FKY = FVEC(K)
            NFCALL = NFCALL + 1
            NFEV = NFCALL/N
            IF (IFLAG .LT. 0) GO TO 230
            FNORM = DMAX1(FNORM,DABS(FKY))
C
C           ITERATIVE REFINEMENT IS TERMINATED IF IT DOES NOT
C           GIVE A REDUCTION OF THE RESIDUALS.
C
            IF (FNORM .LT. FNORM1) GO TO 170
            FNORM = FNORM1
            GO TO 220
  170       CONTINUE
            TEMP = FKY/SIGMA(K)
            DO 180 I = 1, N
               WA1(I) = WA1(I) + TEMP*Q(I,K)
  180          CONTINUE
  190       CONTINUE
C
C        COMPUTE THE NORMS OF THE ITERATE AND CORRECTION VECTOR.
C
         XNORM = ZERO
         DIFIT = ZERO
         DO 200 I = 1, N
            XNORM = DMAX1(XNORM,DABS(WA1(I)))
            DIFIT = DMAX1(DIFIT,DABS(X(I)-WA1(I)))
            X(I) = WA1(I)
  200       CONTINUE
C
C        STOPPING CRITERIA FOR ITERATIVE REFINEMENT.
C
         IF (FNORM .LE. FTOL) INFO = 1
         IF (DIFIT .LE. XTOL*XNORM) INFO = 2
         IF (FNORM .LE. FTOL .AND. INFO .EQ. 2) INFO = 3
         IF (NFEV .GE. MAXFEV .AND. INFO .EQ. 0) INFO = 4
         IF (INFO .NE. 0) GO TO 230
  210    CONTINUE
  220 CONTINUE
C
C     END OF THE ITERATIVE REFINEMENT.
C
      GO TO 20
C
C     TERMINATION, EITHER NORMAL OR USER IMPOSED.
C
  230 CONTINUE
      IF (IFLAG .LT. 0) INFO = IFLAG
      RETURN
C
C     LAST CARD OF SUBROUTINE BRENTM.
C
      END




