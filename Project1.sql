--Viewing Data for Exports--
select *
from Project..Exports


--Viewing Data for Imports--
select *
from Project..Imports


--Trade Balance with Each Country--
select ex."Trade Flow", ex."Partner Name", ex."Export (US$ Thousand)",
im."Trade Flow", im."Partner Name", im."Import (US$ Thousand)",
( ex."Export (US$ Thousand)" - im."Import (US$ Thousand)" ) as TradeBalance
from Project..Exports as ex
 full outer join Project..Imports as im
	on ex."Partner Name" = im."Partner Name"
--where ex."Partner Name" = 'Brazil'


--Using Case Statement--
with CTE_TB as
(
select ex."Trade Flow" as TradeFlow, ex."Partner Name" as PartnerName, ex."Export (US$ Thousand)",
im."Trade Flow" as Trade_Flow, im."Partner Name" as Partner_Name, im."Import (US$ Thousand)",
( ex."Export (US$ Thousand)" - im."Import (US$ Thousand)" ) as TradeBalance
from Project..Exports as ex
 full outer join Project..Imports as im
	on ex."Partner Name" = im."Partner Name"
	)
select *,
Case
	when TradeBalance > 0 then 'Surplus'
	else 'Deficit'
End as DeficitORSurplus
from CTE_TB
--where ex."Partner Name" = 'Brazil'


--Total Exports and Imports of Pakistan--
select ex."Trade Flow", SUM(ex."Export (US$ Thousand)") as ValueOfExports$000, im."Trade Flow", SUM(im."Import (US$ Thousand)") as ValueOfImports$000
from Project..Exports as ex
full outer join Project..Imports as im
	on ex."Partner Name" = im."Partner Name"
where ex."Export (US$ Thousand)" is not null
and im."Import (US$ Thousand)" is not null
group by ex."Trade Flow", im."Trade Flow"


--Trade Deficit of Pakistan using CTE--
with CTE_TotalExpImp
as
(
select SUM(ex."Export (US$ Thousand)") as ValueOfExports$000, SUM(im."Import (US$ Thousand)") as ValueOfImports$000
from Project..Exports as ex
full outer join Project..Imports as im
	on ex."Partner Name" = im."Partner Name"
where ex."Export (US$ Thousand)" is not null
and im."Import (US$ Thousand)" is not null
group by ex."Trade Flow", im."Trade Flow"
)
select ValueOfExports$000, ValueOfImports$000, (ValueOfExports$000 - ValueOfImports$000) as TradeDeficit$000
from CTE_TotalExpImp


--Trade Deficit of Pakistan using Temp Table--
drop table if exists #Temp_TotalExpImp
create table #Temp_TotalExpImp
	(TradeFlow varchar(50),
	ValueOfExports$000 bigint,
	Trade_Flow varchar(50),
	ValueOfImports$000 bigint)

insert into #Temp_TotalExpImp
select ex."Trade Flow", SUM(ex."Export (US$ Thousand)") as ValueOfExports$000, im."Trade Flow", SUM(im."Import (US$ Thousand)") as ValueOfImports$000
from Project..Exports as ex
full outer join Project..Imports as im
	on ex."Partner Name" = im."Partner Name"
where ex."Export (US$ Thousand)" is not null
and im."Import (US$ Thousand)" is not null
group by ex."Trade Flow", im."Trade Flow"

select ValueOfExports$000, ValueOfImports$000, (ValueOfExports$000 - ValueOfImports$000) as TradeDeficit
from #Temp_TotalExpImp
 

--PARTITION BY--
select "Partner Name", "Export (US$ Thousand)", SUM("Export (US$ Thousand)") over (partition by year) as TotalExportsOfPak$000
from Project..Exports
order by 2 desc


--Percent Exported to Partner Country--
WITH CTE_PakExports as
(
select "Partner Name", "Export (US$ Thousand)", SUM("Export (US$ Thousand)") over (partition by year) as TotalExportsOfPak$000
from Project..Exports
)
select *, ("Export (US$ Thousand)" / TotalExportsOfPak$000)*100 as PercentExportToCountry
from CTE_PakExports
order by 4 desc


--Percent Imported from Partner Country--
WITH CTE_PakImports as
(
select "Partner Name", "Import (US$ Thousand)", SUM("Import (US$ Thousand)") over (partition by year) as TotalImportsOfPak$000
from Project..Imports
)
select *, ("Import (US$ Thousand)" / TotalImportsOfPak$000)*100 as PercentImportFromCountry
from CTE_PakImports
order by 4 desc



--UNION--
select ex."Trade Flow", ex."Partner Name", ex."Export (US$ Thousand)" as ValueIn$000
from Project..Exports as ex
union 
select im."Trade Flow", im."Partner Name", im."Import (US$ Thousand)"
from Project..Imports as im
order by 2