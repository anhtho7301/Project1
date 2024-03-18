create table daily_activity
(
Id varchar,
ActivityDate date,
TotalSteps numeric,
TotalDistance	numeric,
TrackerDistance	numeric,
LoggedActivitiesDistance numeric,
VeryActiveDistance numeric,
ModeratelyActiveDistance numeric,
LightActiveDistance numeric,
SedentaryActiveDistance numeric,
VeryActiveMinutes numeric,
FairlyActiveMinutes numeric,
LightlyActiveMinutes numeric,
SedentaryMinutes numeric,
Calories numeric
);

create table daily_calories
(
Id varchar,
ActivityDay date,
Calories numeric
);

create table daily_intensities
(
Id	varchar,
ActivityDay	date,
SedentaryMinutes numeric,
LightlyActiveMinutes numeric,
FairlyActiveMinutes	numeric,
VeryActiveMinutes numeric,
SedentaryActiveDistance	numeric,
LightActiveDistance	numeric,
ModeratelyActiveDistance numeric,
VeryActiveDistance numeric
);

create table daily_steps
(
Id	varchar,
ActivityDay	date,
StepTotal numeric
);

create table hourly_calories
(
Id	varchar,
ActivityHour timestamp,
Calories numeric
);

create table hourly_intensities
(
Id	varchar,
ActivityHour timestamp,
TotalIntensity numeric,
AverageIntensity numeric
);

create table hourly_steps
(
Id	varchar,
ActivityHour timestamp,
StepTotal numeric
);

create table minute_sleep
(
Id	varchar,
date timestamp,
value numeric,
logId varchar
);

create table sleep_day
(
Id	varchar,
SleepDay timestamp,
TotalSleepRecords numeric,
TotalMinutesAsleep numeric,
TotalTimeInBed numeric
);

create table weight_log_info
(
Id	varchar,
Date timestamp,
WeightKg numeric,
WeightPounds numeric,
Fat	numeric,
BMI	numeric,
IsManualReport boolean,
LogId varchar
);

  --check dup
DELETE FROM minute_sleep
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (PARTITION BY id, date ORDER BY ctid) AS row_num
        FROM minute_sleep
    ) sub
    WHERE row_num > 1
);

DELETE FROM sleep_day
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (PARTITION BY id, sleepday ORDER BY ctid) AS row_num
        FROM sleep_day
    ) sub
    WHERE row_num > 1
);

--check tables if same
select * from daily_activity as a
inner join daily_calories as b
on a.id=b.id and a.activitydate=b.activityday;

select * from daily_activity as a
inner join daily_intensities as c
on a.id=c.id and a.activitydate=c.activityday;

select * from daily_activity as a
inner join daily_steps as d
on a.id=d.id and a.activitydate=d.activityday;

--check amount of ids in all tables
select count(distinct id) as unique_id
from daily_activity;

select count(distinct id) as unique_id
from hourly_calories;

select count(distinct id) as unique_id
from hourly_intensities;

select count(distinct id) as unique_id
from hourly_steps;

select count(distinct id) as unique_id
from minute_sleep;

select count(distinct id) as unique_id
from sleep_day;

select count(distinct id) as unique_id
from weight_log_info

--check how often user log in
select id,
count(id) AS total_id
from daily_activity
group by id
order by total_id

select count(total_id) from
(select id,
count(id) AS total_id
from daily_activity
group by id
order by total_id) as a 
where total_id=31

select *,
case when total_id between 1 and 10 then 'occasional_users'
when total_id between 11 and 20 then 'regular_users'
else 'active_users' end as user_type
from (select id,
count(id) AS total_id
from daily_activity
group by id
order by total_id) as a 

-- time spent on activity
select distinct Id, 
sum(veryactiveminutes) as very_active_mins,
sum(fairlyactiveminutes) as fairly_active_mins,
sum(lightlyactiveminutes) as lightly_active_mins,
sum(sedentaryminutes) as sendentary_mins
from daily_activity
group by Id

--daily average analysis
select to_char(activitydate,'Day') as day_of_week,
round(avg(totalsteps),2) as avg_steps,
round(avg(totaldistance),2) as avg_distance,
round(avg(calories),2) as avg_calories
from daily_activity
group by day_of_week

--active mins vs. calories burned
select id,
sum(totalsteps) as total_steps,
sum(veryactiveminutes) as total_very_active_mins,
sum(fairlyactiveminutes) as total_fairly_active_mins,
sum(lightlyactiveminutes) as total_lightly_active_mins,
sum(calories) as total_calories
from daily_activity
group by Id

--intensity vs. calories burned
select a.id, 
sum(a.totalintensity) as total_intensities,
sum(b.calories) as total_calories
from hourly_intensities as a
join hourly_calories as b
on a.id=b.id and a.activityhour=b.activityhour
group by a.id

--workout time in a day
select 
cast(activityhour as time) as workout_time,
sum(calories)
from hourly_calories
group by workout_time
order by workout_time

--time taken to sleep vs. steps
select b.id, 
round(avg(a.totalsteps),2) as steps,
round(avg((b.totaltimeinbed-b.totalminutesasleep)),2) as time_taken_sleep
from daily_activity as a
join sleep_day as b on a.id=b.id
group by b.id
order by time_taken_sleep

