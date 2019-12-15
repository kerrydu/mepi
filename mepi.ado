*! version 0.1
* Kerry Du (kerrydu@xmu.edu.cn)
* 14 Dec 2019
capture program drop mepi
program define mepi,rclass prop(xt)
    version 16

	_xt, trequired 
	local id=r(ivar)
	local time=r(tvar)
	qui mata mata mlib index
*******************************************************************************
	gettoken word 0 : 0, parse("=,()")
	
	
    while ~("`word'" == "="| "`word'" == "") {
        if "`word'" == "," | "`word'" == "" {
                error 198
        }

		if "`word'" == "(" {
			gettoken word 0 : 0, parse("=,()")
			while ~("`word'" == ")" |"`word'" == ""){
				if "`word'" == "(" | "`word'" == "" {
				       disp as error `"unbalanced "(""'
						error 198
				}				
						
				local inv1 `inv1' `word'
				gettoken word 0 : 0, parse("=,()")
			}
			gettoken word 0 : 0, parse("=,()")
		}
		else{
			if "`word'" == ")"  {
			    disp as error `"unbalanced ")""'
				error 198
			}				
			local inv2 `inv2' `word'
			gettoken word 0 : 0, parse("=,()")
		}
		

    }
	
	local invars `inv1' `inv2'
*********************************************************************************	
	
    syntax varlist [if] [in], [ GLOBAL SEQuential WINdow(numlist intege max=1 >=1) FILLmissing ///
							   SAVing(string) maxiter(numlist integer >0 max=1) tol(numlist max=1 >0)]
							   
							   
	
	
	
	
	
	preserve
	marksample touse 
    local opvars `varlist'
	
	confirm numeric var `invars' `opvars' 
	
	local comvars: list invars & opvars 
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as input and output simultaneously."
		error 498
	}
	
	local comvars: list inv1 & inv2
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as energy input and non-energy input simultaneously."
		error 498
	}	
	
	
	
	
	qui keep `invars' `opvars' `id' `time' `touse' `dmu'
	qui gen Row=_n
	label var Row "Row # in the original dataset"

	
	local techtype "contemporaneous"
   

   if "`global'"!=""{
	   if "`sequential'"!=""{
	   
		   disp as error "global and sequential cannot be specified together."
		   error 198	   
	   
	   }
	   
	   if "`window'"!=""{
	   
		   disp as error "global and window() cannot be specified together."
		   error 198	   
	   
	   }	   
	   
	   local techtype "global"
	
	}	
	
   

   if "`sequential'"!=""{
 
	   if "`window'"!=""{
	   
		   disp as error "sequential and window() cannot be specified together."
		   error 198	   
	   
	   }	   
	   
	   local techtype "sequential"
	
	}	
		
 
	   if "`window'"!=""{
	   
	       local techtype "window"   
	   
	   }	   
	   
	if "`maxiter'"==""{
		local maxiter=-1
	}
	if "`tol'"==""{
		local tol=-1
	}	
	
   
    tempvar period dmu
	
	qui egen `period'=group(`time')
	qui egen `dmu'=group(`id')	

	
    qui su  `period'
    local tmax=r(max)

    tempvar flag temp DD D21 D12
    
    qui gen `DD'=.
    qui gen `D21'=.
    qui gen `D12'=.
	
    qui gen `flag'=0
	
	sort `period' `dmu'
	
  if `"`techtype'"'=="contemporaneous"{
  
	    qui{
        forv t=1/`tmax'{
            qui replace `flag'= (`period'==`t')
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui drop `temp'
        }    
        local tt=`tmax'-1
        forv t=1/`tt'{
            qui replace `flag'=(`period'==`t'+1) 
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `D21'=`temp' if `period'==`t'
            qui drop `temp'
        }  

        forv t=2/`tmax'{
            qui replace `flag'=(`period'==`t'-1)
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui drop `temp'
        }       

    }
  
  
  }
  
  
    if `"`techtype'"'=="sequential"{
  
	  
        forv t=1/`tmax'{
            qui replace `flag'=(`period'<=`t')
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui replace `flag'=0
            qui drop `temp'
        }    
        local tt=`tmax'-1
        forv t=1/`tt'{
            qui replace `flag'=(`period'<=`t'+1) 
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `D21'=`temp' if `period'==`t'
            qui drop `temp'
        }  

        forv t=2/`tmax'{
            qui replace `flag'= (`period'<=`t'-1) 
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui drop `temp'
        }       

    
  
  
  }
  
  
  
     if `"`techtype'"'=="window"{
		local band=(`window'-1)/2
	 
        forv t=1/`tmax'{
            qui replace `flag'=(`period'<=`t'+`band' & `period'>=`t'-`band') 
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui cap drop `temp'
        }    
        local tt=`tmax'-1
        forv t=1/`tt'{
            qui replace `flag'= (`period'<=`t'+1+`band' &  `period'>=`t'-`band'+1)
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `D21'=`temp' if `period'==`t'
            qui cap drop `temp'
        }  

        forv t=2/`tmax'{
            qui replace `flag'=(`period'<=`t'-1+`band' & `period'>=`t'-1-`band') 
            specisdf (`inv1') `inv2' = `opvars'  if `period'==`t' & `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui cap drop `temp'
        }       

    
  
  
  }
 

 	
 
	if `"`techtype'"'=="global"{

	    qui replace `flag'=1
		specisdf (`inv1') `inv2' = `opvars' if `touse', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
        
        qui bys `dmu' (`period'): gen MEPI=`temp'/`temp'[_n-1]	
		label var MEPI "Malmquist Energy Productivity Index"
		cap drop `temp'		
		
		sort `period' `dmu'
		forv t=1/`tmax'{
			qui replace `flag'=(`period'==`t')
			specisdf (`inv1') `inv2' = `opvars'  if `touse' & `period'==`t', rflag(`flag') gen(`temp')  maxiter(`maxiter') tol(`tol')
			qui replace `DD'=`temp' if `period'==`t'
			qui cap drop `temp'
		}
		
		qui bys `dmu' (`period'): gen TECH=`DD'/`DD'[_n-1]	
		qui bys `dmu' (`period'): gen BPC=MEPI/TECH			
	
		label var TECH  "energy efficiency change"	
		label var BPC "Best practice gap change"
		local resvars MEPI TECH  BPC
		
		
	}
	else{
	
			//su `DD' `D12' `D21'
		qui {
			sort `dmu' `period'
			bys `dmu' (`period'): gen TECH=`DD'/`DD'[_n-1]
			bys `dmu' (`period'): gen TECCH=sqrt(`D12'/`DD'*`DD'[_n-1]/`D21'[_n-1])
			if "`fillmissing'"!=""{
			
				
			    disp  _n(2) as red "Note: Some missing values of TECCH are filled by D^{t}(t)/D^{t+1}(t) or  D^{t}(t+1)/D^{t+1}(t+1)."
				
				
				qui gen _missing=missing(TECCH)
				replace TECCH=`DD'[_n-1]/`D21'[_n-1] if missing(TECCH)
				replace TECCH=`D12'/`DD' if missing(TECCH)
				//gen D21=`D21'
				//gen D12=`D12'
				local missing _missing
			}
			
			
			gen MEPI= TECH*TECCH
			local resvars MEPI TECH TECCH
		    label var MEPI "Malmquist Energy Productivity Index"
		    label var TECH  "energy efficiency change"	
		    label var TECCH "Techological change"				
		}	
	
	}


		
	    format `resvars' %9.4f

		qui keep if `touse'
		qui cap bys `id' (`time'): gen Pdwise=`time'[_n-1]+"~"+`time' if _n>1
		qui cap bys `id' (`time'): gen Pdwise=string(`time'[_n-1])+"~"+string(`time') if _n>1
		label var Pdwise "Period wise"
			    
		order Row  `id' Pdwise  `resvars' 
		qui keep if !missing(Pdwise) & `touse'
		qui keep  Row `id' Pdwise  `resvars' `missing' 
	
		disp _n(2) as yellow " Malmquist Energy Productivity Index Results:"
		disp "    (Row: Row # in the original data; Pdwise: periodwise)"

		list Row `id'  Pdwise  `resvars' `missing', sep(0) 
		di "Note: missing value indicates infeasible problem."

		if `"`saving'"'!=""{
		  save `saving'
		  gettoken filenames saving:saving, parse(",")
		  local filenames `filenames'.dta
		  disp _n `"Estimated Results are saved in `filenames'."'
		}	
		

	    return local file `filenames'
	    restore			
		

	
	
	
	
	
end	
	
	

capture program drop specisdf
program define specisdf
    version 16
	
	gettoken word 0 : 0, parse("=,()")
	
	
    while ~("`word'" == "="| "`word'" == "") {
        if "`word'" == "," | "`word'" == "" {
                error 198
        }

		if "`word'" == "(" {
			gettoken word 0 : 0, parse("=,()")
			while ~("`word'" == ")" |"`word'" == ""){
				if "`word'" == "(" | "`word'" == "" {
				       disp as error `"unbalanced "(""'
						error 198
				}				
						
				local inv1 `inv1' `word'
				gettoken word 0 : 0, parse("=,()")
			}
			gettoken word 0 : 0, parse("=,()")
		}
		else{
			if "`word'" == ")"  {
			    disp as error `"unbalanced ")""'
				error 198
			}				
			local inv2 `inv2' `word'
			gettoken word 0 : 0, parse("=,()")
		}
		

    }
	

	
	local inv1: list uniq inv1
	local inv2: list uniq inv2
	*local inv2: list inv2 - inv1 
	
	local num1: word count `inv1'
	local num2: word count `inv2'
	local invars `inv1' `inv2'
	
	if `"`inv1'"'==""{
		disp as error "No input variables are specified to be adjusted."
		error 198
		
	
	}
	
    syntax varlist [if] [in],  gen(string) [ rflag(varname)  VRS maxiter(numlist) tol(numlist)]
	    local opvars `varlist'
        marksample touse 
		markout `touse' `invars' `opvars' 
		if "`rflag'"==""{
		  tempvar rflag
		  qui gen `rflag'=1
		}
		tempvar touse2
		mark `touse2' if `rflag'
		markout `touse2' `invars' `opvars'
		//qui gen `touse2'=`rflag'	
        
		if "`maxiter'"==""{
			local maxiter=-1
		}
		if "`tol'"==""{
			local tol=-1
		}	
	
		local comvars: list invars & opvars 
		if !(`"`comvars'"'==""){
			disp as error "`comvars' should not be specified as input and output simultaneously."
			error 498
		}		
		
        local data `invars' `opvars'
		confirm numeric var `data'
		
        local num: word count `invars'		
		

		if "`vrs'"!=""{
			local rts=1
		}
		else{
			local rts=0
		
		}

		qui gen `gen'=.
		if `num2'>0{
			mata: sdf_e("`data'","`touse'", "`touse2'",`num1',`num2',`rts',"`gen'",`maxiter',`tol')
		  }
		else{
			mata: sdf_i("`data'","`touse'", "`touse2'",`num1',`rts',"`gen'",`maxiter',`tol')
		 }
		 
		 

end 





	
