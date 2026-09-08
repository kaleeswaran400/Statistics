-- Which campaigns consume the highest budget?*/

with sum_spend as(
 select sum(Planned_Daily_Ad_Set_Budget) as sum_spend_per, Campaign_Name
from marketing_campaign_analysis_2_5_years
group by Campaign_Name)

select round(sum_spend_per,2) as mx_spend,Campaign_Name,rank() over( order by sum_spend_per desc) as rank_per_budget
from sum_spend
order by mx_spend  desc
limit 10;
 
-- Which campaigns have the highest ROAS?


with request_data1 as (
select  Campaign_Name,Ad_Set_Name, Ad_Name, sum(ROAS)
from marketing_campaign_analysis_2_5_years
group by Campaign_Name,Ad_Set_Name,Ad_Name
order by sum(ROAS)
limit 10),
requested_data2 as(
select c.Campaign_Name,c.Ad_Set_Name, c.Ad_Name, ROAS,row_number() over(partition by Campaign_Name order by ROAS desc) as rank_per_ROAS
from request_data1 o
join marketing_campaign_analysis_2_5_years c on o.Campaign_Name=c.Campaign_Name)

select Campaign_Name,Ad_Set_Name, Ad_Name, ROAS,rank_per_ROAS
from requested_data2
where rank_per_ROAS<6;*/


--Which campaigns have the lowest CPA?

with requested_data as
(select Campaign_Name,Ad_Set_Name,Ad_Name,CPA , row_number() over(partition by Campaign_Name order by CPA) as rank_per_CPA
from marketing_campaign_analysis_2_5_years
where CPA !=0)
select Campaign_Name,Ad_Set_Name,Ad_Name,CPA
from requested_data
where rank_per_CPA<6;



-- above is not a optimum strategy to find the low roas*/

 
from marketing_campaign_analysis_2_5_years)
select Campaign_Name,Ad_Set_Name,CPA
from quatail_cet
where qurtail =1;/* 

--Which campaigns are under-spending?*/


with requested_data as
(select Campaign_Name,Ad_Set_Name,Ad_Name, round(((Planned_Daily_Ad_Set_Budget-Actual_Spend)/Planned_Daily_Ad_Set_Budget)*100,2) as spending_prct
from marketing_campaign_analysis_2_5_years),
requested_data2 as(
select *,row_number()over( order by spending_prct desc) as rank_per_spending
from requested_data
where spending_prct >0)
select Campaign_Name,Ad_Set_Name,Ad_Name, spending_prct
from requested_data2
where rank_per_spending <50;*/


--Which campaigns exceed their planned budget*/
with requested_data as
(select Campaign_Name,Ad_Set_Name,Ad_Name, round(((Planned_Daily_Ad_Set_Budget-Actual_Spend)/Planned_Daily_Ad_Set_Budget)*100,2) as spending_prct
from marketing_campaign_analysis_2_5_years),
requested_data2 as(
select *,row_number()over( order by spending_prct desc) as rank_per_spending
from requested_data
where spending_prct <0)
select Campaign_Name,Ad_Set_Name,Ad_Name, spending_prct
from requested_data2
where rank_per_spending <50;*/

-- What is budget utilization by campaign?    

select Campaign_Name,Ad_Set_Name, Ad_Name,(sum(Actual_Spend)/sum(Planned_Daily_Ad_Set_Budget))*100 as utilization
from marketing_campaign_analysis_2_5_years
group by Campaign_Name,Ad_Set_Name,Ad_Name;

--How does ROAS change month-over-month? 


-- update the date in a corrt format

ALTER TABLE marketing_campaign_analysis_2_5_years
ADD COLUMN Date_temp DATE;

SET SQL_SAFE_UPDATES = 0;
update marketing_campaign_analysis_2_5_years
set months=str_to_date(Date, '%d/%m/%Y');

SET SQL_SAFE_UPDATES = 1;*/



with previous_data as (select Campaign_Name, ROAS, Date, Ad_Set_Name,Ad_Name, lag(ROAS,1) over(partition by  Campaign_Name order by months) as previous_roas
from marketing_campaign_analysis_2_5_years)
select Campaign_Name, ROAS,previous_roas, Date,Ad_Set_Name,Ad_Name,(ROAS-previous_roas)/previous_roas as diff_roas
from previous_data;*/

-- Which /* campaigns are under-spending?
select Campaign_Name, (Planned_Daily_Ad_Set_Budget-Actual_Spend)/Planned_Daily_Ad_Set_Budget
from marketing_campaign_analysis_2_5_years;

-- Which campaigns generate the most conversions per ₹1,000?

select Campaign_Name,Ad_Set_Name,Ad_Name, (Actual_Spend/Impressions)*1000 as CPM
from marketing_campaign_analysis_2_5_years;

-- Which campaigns have high spend but poor conversion performance?*/

with requireed_data as(
select  Campaign_Name,Ad_Set_Name,Ad_Name,Actual_Spend,Conversions, row_number() over(partition by Campaign_Name order by Conversions) as con_rank, row_number() over(partition by Campaign_Name order by Actual_Spend desc) as spend_con
from marketing_campaign_analysis_2_5_years)
select Campaign_Name,Ad_Set_Name,Ad_Name,Actual_Spend,Conversions, row_number() over(order by con_rank+spend_con) as top_campaign
from requireed_data
order by top_campaign 
 
-- Which campaigns have high ROAS but low spending?

 with requireed_data as(
select  Campaign_Name,Ad_Set_Name,Ad_Name,Actual_Spend,ROAS, row_number() over(partition by Campaign_Name order by ROAS desc) as con_rank, row_number() over(partition by Campaign_Name order by Actual_Spend ) as spend_con
from marketing_campaign_analysis_2_5_years)
select Campaign_Name,Ad_Set_Name,Ad_Name,Actual_Spend,ROAS,con_rank,spend_con ,row_number()over( order by con_rank+spend_con ) as top_campaign
from requireed_data
order by top_campaign 
 
 -- What would happen if 10% of the budget were shifted from low-performing campaigns to high-performing campaigns?*/
 
 with fetch_data as
 (select Campaign_Name,Ad_Set_Name,Ad_Name,Actual_Spend,CPA,Revenue,Conversions,Planned_Daily_Ad_Set_Budget
 from marketing_campaign_analysis_2_5_years)
 
 select Campaign_Name,Ad_Set_Name,Ad_Name, CPA,(0.10*Planned_Daily_Ad_Set_Budget)/CPA as add_CPA,0.10*Planned_Daily_Ad_Set_Budget as n_CPA
 from fetch_data;
 
-- What is the marginal CPA at different spending levels?

 with cte_data as (select Campaign_Name,Ad_Set_Name,Ad_Name, Date, CPA, Actual_Spend,  lag(CPA,1) over(partition by Ad_Name order by Ad_Name) as pre_CPA,
 lag(Actual_Spend,1) over(partition by Ad_Name order by Ad_Name) as pre_spend
 from marketing_campaign_analysis_2_5_years
 where cpa is not null)
 select Campaign_Name,Ad_Set_Name,Ad_Name, Date, round((Actual_Spend- pre_spend)/(CPA-pre_CPA),2) as marginal_CPA
 from cte_data
 order by marginal_CPA DESC; */
 
 -- Which campaigns should receive additional budget? 
 
 -- SIS is curated so it is onot accurate result
 
 with request_data as (select Campaign_Name,Ad_Set_Name,Ad_Name, (`Target CPA`/CPA)*(100-SIS) as scalibility_score
 from marketing_campaign_analysis_2_5_years)
 select *
 from request_data
 where scalibility_score is not null
 order by scalibility_score
 
 -- Which campaigns should have their budgets reduced? 
 
  with request_data as (select Campaign_Name,Ad_Set_Name,Ad_Name, (CPA/`Target CPA`) as CPA_deficit
 from marketing_campaign_analysis_2_5_years)
 select *
 from request_data
 where CPA_deficit <1
 order by CPA_deficit 

 
 Which campaigns are scalable and efficient? 
 
 with request_data as(
 select Campaign_Name,Ad_Set_Name,Ad_Name, Actual_Spend,CPA,(Actual_Spend/SIS) as max_scalable_buget
 from marketing_campaign_analysis_2_5_years),
 request_data_2 as (select *,(Actual_Spend-max_scalable_buget) as available_budget
 from request_data),
 request_ata_3 as (select *,(available_budget/CPA) as additional_con
 from request_data_2)
 select Campaign_Name,Ad_Set_Name,Ad_Name,additional_con*CPA as revenue
 from request_ata_3*/
 
 Which campaigns consistently outperform their historical benchmarks? 
 
 with request_data as(
 select Campaign_Name,Ad_Set_Name,Ad_Name,CPA,ROAS, lag(CPA,1) over(partition by Ad_Name order by Date) as previous_CPA, lag(ROAS,1) over(partition by Ad_Name order by Date) as previous_ROAS
 from marketing_campaign_analysis_2_5_years)
 select Campaign_Name,Ad_Set_Name,Ad_Name, round((CPA-previous_CPA)/CPA,2) as performance_lift_CPA, round((ROAS-previous_ROAS)/ROAS,2) as performance_lift_roas
 from request_data