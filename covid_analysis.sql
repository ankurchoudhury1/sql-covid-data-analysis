--select top 1 *
--from covid..covid_vac

--select top 1 *
--from covid..covid_deaths

--select top 1 *
--from covid..covid_countrystats
-- ###

with cte_population as (
	select location, max(population) as population
	from covid..covid_countrystats
	group by location
)
select v.continent, v.location, v.date, 
		(v.total_cases/p.population)*100 as infect_perc,
		(v.people_vaccinated/p.population)*100 as vac_perc,
		(v.people_fully_vaccinated/p.population)*100 as vac_fully_perc,
		(d.total_deaths/p.population)*100 as death_over_pop_perc,
		(d.total_deaths/v.total_cases)*100 as death_over_infect_perc,
		d.new_deaths,
		sum(d.new_deaths) over (partition by v.location order by v.location, v.date) as rs_deaths,
		v.new_vaccinations,
		sum(v.new_vaccinations) over (partition by v.location order by v.location, v.date) as rs_vac
from covid..covid_vac v
left outer join cte_population p on
	p.location = v.location
left outer join covid..covid_deaths d on
	d.iso_code = v.iso_code and
	d.date = v.date
where v.continent is not null
order by 1,2,3,4
