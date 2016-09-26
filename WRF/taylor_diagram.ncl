;;; taylor_diagram.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 21 Dec 2015                                      ;
; Last modified  - 21 Dec 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  load "/home/uesleisutil/NCL/loads.ncl"

begin



; Cases [Model]
  case      = (/ "Florian"+oacute+"polis", "Rio Grande", "Torres" /) 
  nCase     = dimsizes(case )                 ; # of Cases [Cases]

; variables compared
  var       = (/ "Sea Level Pressure","Air Temperature (2 m)","Wind Velocity (10 m)" /) 
  nVar      = dimsizes(var)                   ; # of Variables

; "Case A"                        
  CA_cc      = (/ 0.956, 0.657, 0.299 /)
  CA_ratio   = (/ 0.909, 0.572, 1.379 /)

; "Case B" 
  CB_cc      = (/ 0.966, 0.708, 0.218 /)
  CB_ratio   = (/ 0.960, 0.605, 1.255 /)

; "Case C)"
  CC_cc      = (/ 0.889, 0.647, 0.133 /)
  CC_ratio   = (/ 0.965, 1.019, 1.341 /)

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )  
  cc         = new ((/nCase, nVar/),typeof(CA_cc) ) 

  ratio(0,:) = CA_ratio 
  ratio(1,:) = CB_ratio
  ratio(2,:) = CC_ratio

  cc(0,:)    = CA_cc 
  cc(1,:)    = CB_cc
  cc(2,:)    = CC_cc

;**********************************
; create plot
;**********************************

  res   = True                           ; default taylor diagram
        
  res@Markers      = (/16, 16,16/)               ; make all solid fill
  res@Colors       = (/"red", "blue", "green" /)          
  res@varLabels    = var
  res@caseLabels   = case
  res@centerDiffRMS = True          ; RMS 'circles'
  res@stnRad        = (/ 0.5, 1.5 /)     ; additional standard radii
  res@ccRays        = (/ 0.3, 0.6, 0.9 /)     ; correllation rays
  res@caseLabelsFontHeightF = 0.16       ; make slight larger   [default=0.12 ]
  res@varLabelsFontHeightF  = 0.014      ; make slight smaller  [default=0.013]

  wks   = gsn_open_wks("png","taylor")        ; send graphics to PNG file 
  plot  = taylor_diagram(wks,ratio,cc,res)


end 