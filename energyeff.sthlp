{smcl}
{* *! version 0.3  29 Oct 2019}{...}
{cmd:help energyeff}
{hline}

{title:Title}

{phang}
{bf:energyeff} {hline 2}  Energy Efficiency Index in Stata 

{title:Syntax}

{p 8 21 2}
{cmd:energyeff} ({it:{help varlist:energyvars}}) {it:{help varlist:otherinputvars}} {cmd:=} {it:{help varlist:outputvars}} {ifin} 
{cmd:,} {cmdab:d:mu(}{varname}{cmd:)} [{it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:dmu(varname)}}specifies names of DMUs. 

{synopt:{cmdab:t:ime:(varname)}}specifies time period for contemporaneous production technology. If {opt time:(varname)} is not specified, global production technology is assumed. 
{p_end}

{synopt:{cmdab:seq:uential}}specifies sequential production technology.
{p_end}

{synopt:{cmdab:win:dow(#)}}specifies window production technology with # periods.
{p_end}

{synopt:{opt global}}specifies global production technology.
{p_end}

{synopt:{opt vrs}}specifies production technology with variable returns to scale. By default, production technology with constant returns to scale is assumed.
{p_end}

{synopt:{opt sav:ing(filename[,replace])}}specifies that the results be saved in {it:filename}.dta. 
{p_end}

{synopt:{opt maxiter(#)}}specifies the maximum number of iterations, which must be an integer greater than 0. The default value of maxiter is 16000.
{p_end}

{synopt:{opt tol(real)}}specifies the convergence-criterion tolerance, which must be greater than 0.  The default value of tol is 1e-8.
{p_end}

{synoptline}
{p2colreset}{p 4 6 2}
time() should be specified when sequential or window() is used.


{title:Description}

{pstd}
{cmd:energyeff} selects the input and output variables in the opened data set and estimate Total Factor Energy Efficiency using Data Envelopment Analysis(DEA) frontier by options specified. 


{title:Examples}

{phang}{cmd:. use "https://raw.githubusercontent.com/kerrydu/energyeff/master/exdata.dta"}

{phang}{cmd:. energyeff (E) K L= Y, dmu(dmu) global}

{phang}{cmd:. energyeff (E) K L= Y, dmu(dmu) time(year) seq }

{phang}{cmd:. energyeff (E) K L= Y, dmu(dmu) time(year) vrs sav(energyeff_result,replace)}

{title:Saved Results}

{psee}
Macro:

{psee}
{cmd: r(file)} the filename stores results of {cmd:energyeff}.
{p_end}


{marker references}{...}
{title:References}
 
{phang}
Li J., Liu H., Du k. Does market-oriented reform increase energy rebound effect? Evidence from China’s regional development, China Economic Review, 2019，56，101304. 


{title:Author}

{psee}
Kerry Du

{psee}
Xiamen University

{psee}
Xiamen, China

{psee}
E-mail: kerrydu@xmu.edu.cn
{p_end}
