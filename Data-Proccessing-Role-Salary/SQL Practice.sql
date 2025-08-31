-- Output : ANalisis salary data analyst job di wilayah dengan  rata-rata salary tertinggi
-- Poin-poin analisis:
-- 1. Sebaran rata_rata gaji berdasarkan wilayah company
-- 2. Proporsi local vs foreign employee
-- 3. proporsi remote_ratio employee
-- 4. Rank job title dengan rata-rata salary tertinggi
-- 5. Perbandingan rata-rata salary based on company size, employee type, and experience
-- 6. Prospek rata-rata data analys salary 

-- Prepare Data
-- 1. Create database
create database ds_salary;
-- 2. Import data
-- 3. cek data
select *
	from info_salary;
    
-- Query Analysis :
-- 1. Sebaran rata_rata gaji berdasarkan wilayah company
select company_location, round(avg(salary_in_usd),0) as avg_salary_usd
	from info_salary
    where job_title like '%Analyst%'
    group by company_location
    order by avg_salary_usd desc;
-- Rata salary terbesar di US. Selanjutnya akan menganalsis salary berdasarkan company location US

-- 2. Proporsi local vs foreign employee
with locals as(
	select count(*) as number_local,company_location
		from info_salary
        where company_location=employee_residence and company_location='US'),
	foreigns as(
    select count(*) as number_foreign,company_location
		from info_salary
        where company_location<>employee_residence and company_location='US')
select az.company_location,number_local,number_foreign
	from locals az
    join foreigns;

-- OR try this one: 

select distinct (select count(*) as number_local
		from info_salary
        where company_location=employee_residence and company_location='US') as number_loc,
       (select distinct count(*) as number_foreign
		from info_salary
        where company_location<>employee_residence and company_location='US') as number_foreg,
        company_location
	from info_salary
    where company_location='US';

-- 3. proporsi remote_ratio employee
select distinct 
	case when remote_ratio=0 then 'On site'
		when remote_ratio=50 then 'Hybrid'
        else 'Full remote'
        end work_model, count(*) as number_employee,company_location
	from info_salary
    where job_title like '%Analyst%' and company_location='US'
    group by work_model,company_location;

-- 4. Rank job title dengan rata-rata salary tertinggi
select distinct job_title, round(avg(salary_in_usd),0) as avg_salary_usd
	from info_salary
    where job_title like '%Analyst%' and company_location='US'
    group by job_title
    order by avg_salary_usd desc;

-- 5. Perbandingan rata-rata salary based on company size,status employment, dan experience
with aa as(select distinct company_size, (select distinct employment_type) as Status_employment,
	(select distinct experience_level) as experience,
    round(avg(salary_in_usd),0) as avg_salary_usd
	from info_salary
	where job_title like '%Analyst%' and company_location='US'
    group by company_size,status_employment,experience
    order by company_size,status_employment, avg_salary_usd desc)
select company_size,
		round(avg(avg_salary_usd) over(partition by company_size),0) as avg_company_size,
        case when status_employment='PT' then 'Part Time'
			when status_employment='FT' then 'Full Time'
            when status_employment='CT' then 'Contract'
            else 'Freelance'
            end status_employment,
		round(avg(avg_salary_usd) over (partition by company_size order by status_employment),0) as avg_size_status,
        case when experience='EN' then 'Entry Level'
			when experience='MI' then 'Mid Level'
            when experience='SE' then 'Senior/Expert'
            else 'Executive/Director'
            end experience_Employee,
        avg_salary_usd
	from aa;

-- 6. Prospek rata-rata data analys salary 
with usa as(select distinct work_year, company_location,
	round(avg(salary_in_usd),0) as avg_salary
		from info_salary
		where job_title like '%Analyst%' and company_location='US'
		group by work_year,company_location),
		other as(select distinct work_year,
	case when work_year=2020 then 'Others'
		else 'Others'
        end as company_location,
		round(avg(salary_in_usd),0) as avg_salary
		from info_salary
		where job_title like '%Analyst%' and company_location not in('US')
		group by work_year)
select * 
	from other
    union
		select *
			from usa;