capture program drop energyeff
program define energyeff,rclass
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
	
    syntax varlist [if] [in],  dmu(varname) [Time(varname) global SEQuential WINdow(numlist intege max=1 >=1)  VRS  SAVing(string) maxiter(numlist integer >0 max=1) tol(numlist max=1)]	
	
	marksample touse 
	
    local opvars `varlist'
	
	confirm numeric var `invars' `opvars' 
	
	preserve
	
	qui keep `dmu' `time' `touse' `invars' `opvars' 
	qui gen Row=_n
	label var Row "Row # in the original data"
	
	
	local comvars: list invars & opvars 
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as input and output simultaneously."
		error 198
	}
	
	local comvars: list inv1 & inv2
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as energy input and non-energy input simultaneously."
		error 198
	}	
	
	if "`time'"==""{
		local techtype "global"
	}
	else{
		local techtype "contemporaneous"
	}
		
	local techflag "=="
	
	if "`sequential'"!=""{
		if "`time'"==""{
		   disp as error "For sequential technology reference, time() should be specified."
		   error 198
		}
		else{
		   local techflag "<="
		}
	
	}	
	
	if "`window'"!=""{
		if "`time'"==""{
		   disp as error "For sequential technology reference, time() should be specified."
		   error 198
		}
	
	}



   

   if "`global'"!=""{
	   if "`sequential'"!=""{
	   
		   disp as error "global and sequential cannot be specified together."
		   error 498	   
	   
	   }
	   
	   if "`window'"!=""{
	   
		   disp as error "global and window() cannot be specified together."
		   error 498	   
	   
	   }	   
	   
	   local techtype "global"
	
	}	
	
   

   if "`sequential'"!=""{
 
	   if "`window'"!=""{
	   
		   disp as error "sequential and window() cannot be specified together."
		   error 498	   
	   
	   }	   
	   
	   local techtype "sequential"
	
	}	
		
 
	   if "`window'"!=""{
	   
	       local techtype "window"   
	   
	   }	


	tempvar flag temeff tvar
	
	if `"`time'"'!=""{
		qui egen `tvar'=group(`time')
		qui su `tvar',meanonly
		local tmax=r(max)
	
	}
	
	
	qui gen `flag'=.

	if "`techtype'"=="global"{
		specisdf (`inv1') `inv2' = `opvars' if `touse', gen(effscore) `vrs' maxiter(`maxiter') tol(`tol')
	}
	
	if "`techtype'"=="window"{
		local band=(`window'-1)/2
		qui gen effscore=.
		forv t=1/`tmax'{
			cap drop `temeff'
			qui replace `flag'=(`tvar'<=`t'+`band' & `tvar'>=`t'-`band') 
			specisdf (`inv1') `inv2' = `opvars' if `tvar'==`t' & `touse', gen(`temeff') `vrs' maxiter(`maxiter') tol(`tol') rflag(`flag')
			qui replace effscore=`temeff' if `tvar'==`t' & `touse'
		}
		
	}	
	
	if "`techtype'"=="sequential"|"`techtype'"=="contemporaneous"{
		
		qui gen effscore=.
		forv t=1/`tmax'{
			cap drop `temeff'
			qui replace `flag'=(`tvar' `techflag' `t') 
			specisdf (`inv1') `inv2' = `opvars' if `tvar'==`t' & `touse', gen(`temeff') `vrs' maxiter(`maxiter') tol(`tol') rflag(`flag')
			qui replace effscore=`temeff' if `tvar'==`t' & `touse'
		}
		
	}
	
	local crs=cond("`vrs'"!="","VRS","CRS")

	label var effscore "Energy Efficiency Score"
	format effscore %9.4f
	qui keep if `touse'
	
	disp _n(2) "Energy Efficiency Results under `techtype' technology with `crs' assumption: "
	
	disp "    (Row: Row # in the original data; effscore: Energy Efficiency Score)"

	list Row `dmu' `time' effscore, sep(0) 	

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
	local inv2: list inv2 - inv1 
	
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


cap mata mata drop sdf_e()
mata:
void function sdf_e(string scalar d, ///
                    string scalar touse, ///
					string scalar rflag, ///
					real scalar k, ///
					real scalar l,
					real scalar scale, ///
					string scalar g, ///
					real scalar  maxiter, ///
				    real scalar  tol)
    { 
          data=st_data(.,d,touse)
          data=data'
          dataref=st_data(.,d,rflag)
          dataref=dataref'
          M=rows(data)
		  Eref=dataref[1..k,.]
          Xref=dataref[k+1..k+l,.]
          Yref=dataref[k+l+1..M,.]
		  E=data[1..k,.]
          X=data[k+1..k+l,.]
          Y=data[k+l+1..M,.]		  
		  
          N=cols(dataref)
  
          class LinearProgram scalar q
          q = LinearProgram()
		  q.setMaxOrMin("min")
			if(maxiter!=-1){
			  q.setMaxiter(maxiter)
			}
			if (tol!=-1){
			  q.setTol(tol)
			}			  
          c = (1, J(1,N,0))
          //lowerbd =., J(1,N,0)
		  lowerbd = J(1,N+1,0)
          upperbd = J(1,N+1,.)		  
		  if(scale==1){
            Aec= (0, J(1,N,1))
            q.setEquality(Aec, 1)
		   }  
          theta=J(cols(data),1,.)
  
          for(j=1;j<=cols(data);j++){
              A1 = (-E[.,j],Eref)
              b1 = J(k,1,0)
              A2 = (J(l,1,0),Xref)
              b2 = X[.,j]			  
              A3 = (J(M-k-l,1,0),-Yref)
              b3=  -Y[.,j]
              Aie=A1 \ A2 \ A3
              bie=b1 \ b2 \ b3
              q.setCoefficients(c)
              q.setInequality(Aie, bie)
              q.setBounds(lowerbd, upperbd)
 //             theta[j]=1/q.optimize()		
              theta[j]=q.optimize() 
         }
          st_view(gen=.,.,g,touse)
          gen[.,.]=theta
    
    }
end

cap mata mata drop sdf_i()
mata:
void function sdf_i(string scalar d, ///
                    string scalar touse, ///
					string scalar rflag, ///
					real scalar k, ///
					real scalar scale, ///
					string scalar g, ///
					real scalar  maxiter, ///
				    real scalar  tol)
    { 
          data=st_data(.,d,touse)
          data=data'
          dataref=st_data(.,d,rflag)
          dataref=dataref'
          M=rows(data)
          Xref=dataref[1..k,.]
          Yref=dataref[k+1..M,.]
          X=data[1..k,.]
          Y=data[k+1..M,.]
          N=cols(dataref)
  
          class LinearProgram scalar q
          q = LinearProgram()
		  q.setMaxOrMin("min")
			if(maxiter!=-1){
			  q.setMaxiter(maxiter)
			}
			if (tol!=-1){
			  q.setTol(tol)
			}			  
          c = (1, J(1,N,0))
          //lowerbd =., J(1,N,0)
		  lowerbd = J(1,N+1,0)
          upperbd = J(1,N+1,.)		  
		  if(scale==1){
            Aec= (0, J(1,N,1))
            q.setEquality(Aec, 1)
		   }  
          theta=J(cols(data),1,.)
  
          for(j=1;j<=cols(data);j++){
              A1 = (-X[.,j],Xref)
              b1 = J(k,1,0)
              A2 = (J(M-k,1,0),-Yref)
              b2=  -Y[.,j]
              Aie=A1 \ A2
              bie=b1 \ b2
              q.setCoefficients(c)
              q.setInequality(Aie, bie)
              q.setBounds(lowerbd, upperbd)
 //             theta[j]=1/q.optimize()	
			  theta[j]=q.optimize()
         }
          st_view(gen=.,.,g,touse)
          gen[.,.]=theta
    
    }
end


