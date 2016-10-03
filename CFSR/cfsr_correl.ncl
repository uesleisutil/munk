;;; cfsr_correl.ncl ;;;;;;;;;;;;;;;;......;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 30 Sep 2016                                      ;
; Last modified  - 30 Sep 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 load "/home/uesleisutil/NCL/loads.ncl"
 begin
 
 a = addfile("/home/uesleisutil/Documentos/cfsr_correl.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      

 var      = "sst"

 lh1      = a->LHTFL_L1
 sst      = a->TMP_L1
 
 latmin   = -30
 latmax   = -26
 lonmin   = -48
 lonmax   = -44

 tempo    = a->time
 tempo2   = cd_calendar(tempo, 3)
 tempodim = dimsizes(tempo2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Do the table.                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Remove file just in case.
 filename = "file2.txt"
 system("rm -f " + filename)

; 3.2. If header is desired.
 ;header = "Dias       Dados"
 ;write_table(filename, "w", [/header/], "%s")    ; Use "w" to create file

; 3.3. Create the tables. 
 if (var.eq."sst")then 
   do it = 0,tempodim-1
     sst1  = sst(it,{latmin:latmax},{lonmin:lonmax})
     sst2  = sst1-273.15
     copy_VarCoords(sst1, sst2)
     sst3  = avg(sst2)
     slist = [/tempo2(it)-1 + " " + sst3/]
     write_table(filename, "a", slist, "%s")   ; Use "a" to append to existing file
     delete([/sst2,sst1,sst3/])
   end do
 end if


  if (var.eq."lh")then 
   do it = 0,tempodim-1
     lh2  = lh1(it,{latmin:latmax},{lonmin:lonmax})
     lh3  = avg(lh2)  
     slist = [/tempo2(it)-1 + " " + lh3/]
     write_table(filename, "a", slist, "%s")   ; Use "a" to append to existing file
     delete([/lh2,lh3/])
   end do
 end if

end