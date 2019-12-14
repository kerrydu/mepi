{smcl}
{* *! version 0.3  29 Oct 2019}{...}
{cmd:help mepi}
{hline}

{title:Title}

{phang}
{bf:mepi} {hline 2} Malmquist Energy Productivity Index in Stata 

{title:Syntax}

{p 8 21 2}
{cmd:mepi} ({it:{help varlist:energyvars}}) {it:{help varlist:otherinputvars}} {cmd:=} {it:{help varlist:outputvars}} {ifin} 
{cmd:,} [{it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:dmu(varname)}}specifies names of DMUs. 

{synopt:{cmdab:seq:uential}}specifies sequential production technology.
{p_end}

{synopt:{cmdab:win:dow(#)}}specifies window production technology with # periods.
{p_end}

{synopt:{opt global}}specifies global production technology.
{p_end}

{synopt:{cmdab:fill:missing}}specifies filling TECCH with the ratio of D^{t}(t)/D^{t+1}(t) when TECCH is missing due to the infeasible problem of D^{t}(t+1).
{p_end}

{synopt:{opt sav:ing(filename[,replace])}}specifies that the results be saved in {it:filename}.dta. 
{p_end}

{synopt:{opt maxiter(#)}}specifies the maximum number of iterations, which must be an integer greater than 0. The default value of maxiter is 16000.
{p_end}

{synopt:{opt tol(real)}}specifies the convergence-criterion tolerance, which must be greater than 0.  The default value of tol is 1e-8.
{p_end}

{synoptline}
{p2colreset}{p 4 6 2}
A panel variable and a time variable must be specified; use {helpb xtset}.


{title:Description}

{pstd}
{cmd:mepi} selects the input and output variables in the opened data set and estimate Malmquist Energy Productivity Index using Data Envelopment Analysis(DEA) frontier by options specified. 



{title:Examples}

{phang}{cmd:. use "https://raw.githubusercontent.com/kerrydu/mepi/master/exdata.dta"}

{phang}{cmd:. xtset dmu year}

{phang}{cmd:. mepi (E) K L= Y,  global}

{phang}{cmd:. mepi (E) K L= Y,  seq }

{phang}{cmd:. mepi (E) K L= Y, sav(mepi_result,replace)}

{title:Saved Results}

{psee}
Macro:

{psee}
{cmd: r(file)} the filename stores results of {cmd:mepi}.
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
