clear

use "http://caucasusbarometer.org/downloads/NDI_2019_April_22.04.19_Public.dta"

set more off


/// weights
svyset PSU [pweight=WTIND], strata(SUBSTRATUM) fpc(NPSUSS)singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)


/// recodes
recode RESPEDU (1=1) (2=1) (3=1) (4=2) (5=3) (6=3) (-3=-3) (-7=-7) (-9=-9) , gen(RESPEDUrec)

label define RESPEDUrec 1 "Secondary or lower", modify
label define RESPEDUrec 2 "Vocational/technical degree", modify
label define RESPEDUrec 3 "Higher than secondary", modify

label values RESPEDUrec RESPEDUrec


/// recodes for regression



recode TOPTHREA19 (1=1) (5=1) (6=1) (8=1) (9=1) (-5=-5) (-1=2) (-2=-2) (else=0)
label var TOPTHREA19 "Russian thing"


label define TOPTHREA19 0 "Other threats", modify
label define TOPTHREA19 1 "Russian threats", modify
label define TOPTHREA19 2 "don't know", modify


label values TOPTHREA19 TOPTHREA19

recode PARTYSUPP1 (9=.) (18=.) (20=.) (24=.) (-2=.) (1=4) (2=4) (4=4) (5=4) (11=4) (12=4) (14=4) (19=4) (21=4) (22=4) (3=3) (7=3) (10=3) (13=3) (15=3) (16=3) (17=3) (23=3) (6=2) (8=1) (25=5) (-1=5)

label define PARTYSUPP1 4 "Other parties", modify
label define PARTYSUPP1 3 "Liberal parties", modify
label define PARTYSUPP1 2 "UNM", modify
label define PARTYSUPP1 1 "GD", modify
label define PARTYSUPP1 5 "No party", modify

label values PARTYSUPP1 PARTYSUPP1


/// Wealth index

foreach var of varlist  OWNFRDG OWNCOTV OWNSPHN OWNTBLT OWNCARS OWNAIRC OWNWASH OWNCOMP OWNHWT OWNCHTG {
recode `var' (-9/-1=0)
}

gen wealth_index = OWNFRDG + OWNCOTV + OWNSPHN + OWNTBLT + OWNCARS + OWNAIRC + OWNWASH + OWNCOMP + OWNHWT + OWNCHTG 

// NewSettype

recode SUBSTRATUM (10=1) (21/26=2) (31/34=2) (51=2) (61=2)  (41/44=3) (52=3) (62=3) , gen(NEW_SETTYPE)
label var NEW_SETTYPE "Settlement type"

label define NEW_SETTYPE 1 "Capital", modify
label define NEW_SETTYPE 2 "Urban", modify
label define NEW_SETTYPE 3 "Rural", modify

label value NEW_SETTYPE NEW_SETTYPE


/// ethnicity
recode ETHNIC (1=1) (2=2) (3=3) (4/7=4)

label define ETHNIC 1 "Armenian", modify
label define ETHNIC 2 "Azerbaijani", modify
label define ETHNIC 3 "Georgian", modify
label define ETHNIC 4 "Other ethnicity", modify

label values ETHNIC ETHNIC



//////// multinominal regression

//missing values
recode TOPTHREA19 PARTYSUPP1 ETHNIC RESPEDUrec (-3=.) (-5=.) (-2=.) (-1=.)
recode ETHNIC (4=.)


/// mlogit

qui svy: mlogit TOPTHREA19 i.RESPSEX i.AGEGROUP b03.ETHNIC b03.NEW_SETTYPE b03.RESPEDUrec b01.PARTYSUPP1 c.wealth_index, base (1)  
margins, dydx(*) predict(outcome(0)) post
estimates store OtherThreats

qui svy: mlogit TOPTHREA19 i.RESPSEX i.AGEGROUP b03.ETHNIC b03.NEW_SETTYPE b03.RESPEDUrec b01.PARTYSUPP1 c.wealth_index, base (1)  
margins, dydx(*) predict(outcome(1)) post
estimates store RussianThreats

qui svy: mlogit TOPTHREA19 i.RESPSEX i.AGEGROUP b03.ETHNIC b03.NEW_SETTYPE b03.RESPEDUrec b01.PARTYSUPP1 c.wealth_index, base (1)  
margins, dydx(*) predict(outcome(2)) post
estimates store DK

coefplot OtherThreats || RussianThreats || DK, drop(_cons) xline(0) byopts(xrescale) 

/// title("In your opinion, what is the top threat to Georgia’s national security?" "By demographic variables and party support", color(dknavy*.9) tstyle(size(medium)) span)
/// subtitle("Marginal effects, 95% CIs", color(navy*.8) tstyle(size(msmall)) span)
/// note("NDI/CRRC-Georgia, April 2019")




