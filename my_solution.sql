
use ipl;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_player;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_team_players;
select * from ipl_team_standings;
select * from ipl_tournament;
select * from ipl_user;


-- Questions – Write SQL queries to get data for the following requirements:

-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select * from ipl_bidding_details  ;
select * from ipl_bidder_points ;
select * from ipl_bidder_details ;


with Total_bids as (
select bd.bidder_id, count(no_of_bids) as Total
from ipl_bidding_details as bd join ipl_bidder_points as bp on bd.bidder_id = bp.bidder_id
group by bd.bidder_id
order by total desc),
total_wins as 
(
select bid_status, bd.bidder_id , bd.bidder_name, count(bid_status) as Wins
from ipl_bidder_details as bd join ipl_bidding_details as bdd on bd.bidder_id = bdd.bidder_id where bid_status = 'Won'
group by bd.bidder_id, bid_status)

select total_wins.bidder_id, total_wins.bidder_name, (wins/total)*100 as percent_win from total_bids, total_wins where total_bids.bidder_id = total_wins.bidder_id
order by percent_win desc;



-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.


select std.stadium_id, stadium_name, city, count(std.stadium_id) as Total_matches from ipl_match_schedule as ms join ipl_stadium as std on std.stadium_id = ms.stadium_id
where status = 'Completed'
group by std.stadium_id, city
order by total_matches desc;


-- 3.	In a given stadium, what is the percentage of wins by a team that has won the toss?

select * from ipl_match;
select * from ipl_team;
select * from ipl_match_schedule ;
select * from ipl_stadium ;

with cte1 as (
select s.stadium_id, s.stadium_name, count(m.match_id) as Toss_and_Match_Wins
from ipl_match as m join ipl_match_schedule as ms on m.match_Id = ms.match_id join ipl_stadium as s on s.stadium_id = ms.stadium_id
where toss_winner = match_winner
group by s.stadium_id, s.stadium_name),

cte2 as (
select s.stadium_id, s.stadium_name, count(m.match_id) as Total_match_Wins_at_Stadium
from ipl_match as m join ipl_match_schedule as ms on m.match_Id = ms.match_id join ipl_stadium as s on s.stadium_id = ms.stadium_id
where ms.stadium_id = s.stadium_id
group by s.stadium_id, s.stadium_name)

select cte1.stadium_id, cte1.stadium_name, (Toss_and_Match_Wins/Total_match_Wins_at_Stadium)*100 as Percentage_win
from cte1,cte2
where cte1.stadium_id = cte2.stadium_id
order by Percentage_win desc;


-- 4.	Show the total bids along with the bid team and team name.

select * from ipl_team ;
select * from ipl_bidder_details;
select * from ipl_bidding_details;
select * from ipl_match_schedule;
select * from ipl_match;


-- total bids by a bidder
select bidder_id, no_of_bids from ipl_bidder_points where bidder_id in (select bidder_id from ipl_bidding_details);


select bid_team as 'Team ID' , team_name as 'Team Name' , count(bidder_id) as Total_Bids from ipl_bidding_details as bd join ipl_team as t on t.team_id = bd.bid_team
where bid_status <> 'Cancelled'
group by bid_team, team_name
order by Total_Bids desc
;



-- 5.	Show the team ID who won the match as per the win details.

select * from ipl_team_standings;
select * from ipl_team;
select * from ipl_match;

with team_number as (
select case 
when substring(win_details,6,3) = 'CSK' then 1 
when substring(win_details,6,2) = 'DD' then 2
when substring(win_details,6,4) = 'KXIP' then 3 
when substring(win_details,6,3) = 'KKR' then 4 
when substring(win_details,6,2) = 'MI' then 5 
when substring(win_details,6,2) = 'RR' then 6 
when substring(win_details,6,3) = 'RCB' then 7 
when substring(win_details,6,3) = 'SRH' then 8 
end as t_id from ipl_match)

select team_id, team_name from ipl_team as t join team_number as tn on tn.t_Id = t.team_id
order by team_id
;

-- Here I have additionally counted which team has won how many times.

with team_number as (
select case 
when substring(win_details,6,3) = 'CSK' then 1 
when substring(win_details,6,2) = 'DD' then 2
when substring(win_details,6,4) = 'KXIP' then 3 
when substring(win_details,6,3) = 'KKR' then 4 
when substring(win_details,6,2) = 'MI' then 5 
when substring(win_details,6,2) = 'RR' then 6 
when substring(win_details,6,3) = 'RCB' then 7 
when substring(win_details,6,3) = 'SRH' then 8 
end as t_id from ipl_match)

select team_id, team_name, count(team_id) as No_of_times from ipl_team as t join team_number as tn on tn.t_Id = t.team_id
group by team_id, team_name
order by No_of_times desc
;


-- 6.	Display the total matches played, total matches won and total matches lost by the team along with its team name.

select * from ipl_team;
select * from ipl_team_standings;
select count(*) from ipl_match_schedule;

with cte as (
select ts.team_id, team_name, sum(matches_played) as total_matches, sum(matches_won) as total_wins , sum(matches_lost) as _total_loss 
from ipl_team_standings as ts join ipl_team as t on t.team_id = ts.team_id
group by ts.team_id , team_name )
select *, (total_wins/total_matches)*100 as win_prcnt from cte;

## Additional Calculated the Win Percentage of the each Team


-- 7.	Display the bowlers for the Mumbai Indians team.

select * from ipl_team;
select * from ipl_team_players;
select * from ipl_player;

select player.player_id, player_name,player_role,team_name
from ipl_team_players tepl join ipl_player player 
on player.player_id = tepl.player_id join ipl_team te 
on tepl.team_id = te.team_id
where player_role = 'bowler' and te.remarks like '%MI%';


-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.

select * from ipl_team;
select * from ipl_team_players;
select * from ipl_player;


select t.Team_id, team_name, count(tp.player_id) as No_of_allrounder
from ipl_player as p join ipl_team_players as tp on p.player_id = tp.player_id join ipl_team as t on t.team_id = tp.team_id
where tp.player_role = 'All-Rounder' 
group by t.Team_id, team_name
having no_of_allrounder > 4
order by no_of_allrounder desc
;


-- 9.	 Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
--  Note the total bidders’ points in descending order and the year is the bidding year.'
-- Display columns: bidding status, bid date as year, total bidder’s points


select * from ipl_bidder_details;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_team;
select * from ipl_tournament;
select * from ipl_stadium;

with cte as (
select bidd.bidder_id , bd.bidder_name, bidd.bid_status, count(bidd.bidder_id) as total_wins,
case when bid_status = 'Won' then 2
when bid_status = 'Lost' then 0
when bid_status = 'Bid' then 0
end as points , year(bid_date) as yr 
from ipl_bidder_details as bd join ipl_bidding_details bidd 
on bd.bidder_id = bidd.bidder_id join ipl_bidder_points bp 
on bp.bidder_id = bidd.bidder_id join ipl_team t
on bidd.bid_team = t.team_id join ipl_match_schedule ms
on bidd. schedule_id = ms.schedule_id join ipl_stadium s 
on s.stadium_id = ms.stadium_id join ipl_match m 
on m.match_id = ms.match_id
where t.remarks = 'csk' and s.stadium_name = 'M. Chinnaswamy Stadium' and bid_team = 1
group by bidd.bidder_id , bd.bidder_name, bidd.bid_status)

select bid_status, yr, total_wins from cte where points > 0;





-- 10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
-- Note 
-- 1. Use the performance_dtls column from ipl_player to get the total number of wickets
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.	Do not use joins in any cases.
-- 4.	Display the following columns teamn_name, player_name, and player_role.

select * from ipl_player;
select * from ipl_team_players;
select * from ipl_team;

with cte1 as (
select player_id, player_name, trim(substr(PERFORMANCE_DTLS, instr(PERFORMANCE_DTLS,'Wkt'), 6)) as wickets from ipl_player where player_id in ( select player_id from ipl_team_players
where player_role = 'Bowler' or player_role = 'All-Rounder' )
),
cte2 as (
select player_role, team_id from ipl_team_players where player_id in (select player_id from ipl_team_players where player_role = 'Bowler' or player_role = 'All-Rounder'))

select distinct player_id, player_name, cte2.player_role, cast(substr(wickets,instr(wickets,'-')+1,length(wickets)-instr(wickets,'-')) as unsigned) as Total_wickets
, dense_rank()over(partition by player_name order by cte1.wickets asc ) as rnk
from cte1, cte2
order by total_wickets desc

;


-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

select * from ipl_bidding_details;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_team;

with cte as (
select case 
when toss_winner = 1 then team_id1
when toss_winner = 2 then team_id2
end as t_count , bd.bid_team , bd.bidder_id
from ipl_match as m join ipl_match_schedule as ms on m.match_id = ms.match_id join ipl_bidding_details as bd on bd.schedule_id = ms.schedule_id join ipl_team as t)
select team_name, count(t_count) as wins from cte join ipl_team as t on t.team_id = cte.t_count
group by team_name order by wins desc;

with cte1 as (
select case 
when team_id1 = 1 then 1 
when team_id1= 2 then 2
when team_id1= 3 then 3 
when team_id1= 4 then 4 
when team_id1= 5 then 5 
when team_id1= 6 then 6 
when team_id1= 7 then 7 
when team_id1= 8 then 8 
end as t_no1
from ipl_match where toss_winner = 1),
cte2 as (
select case 
when team_id2 = 1 then 1 
when team_id2= 2 then 2
when team_id2= 3 then 3 
when team_id2= 4 then 4 
when team_id2= 5 then 5 
when team_id2= 6 then 6 
when team_id2= 7 then 7 
when team_id2= 8 then 8 
end as t_no2
from ipl_match where toss_winner = 2)
select ((select team_name, team_id, count(team_id) from ipl_team as t join cte1 on cte1.t_no1 = t.team_id
group by team_name, team_id ) + (select team_name, team_id, count(team_id) from ipl_team as t join cte2 on cte2.t_no2 = t.team_id
group by team_name , team_id)) from cte1, cte2 where cte1.t_no1 = cte2.t_no2;

with cte as
(select *,
case
	when toss_winner = 1 then team_id1
    else team_id2
end as Toss_winning_Team
from ipl_match mtch ),
cte1 as
(select bidder_id,bidd_dt.schedule_id,mtch_sch.match_id,bid_team, toss_winning_team,
case 
	when bid_team = toss_winning_team then 1 
    else 0
end as Win_Loss
from ipl_bidding_details bidd_dt join ipl_match_schedule mtch_sch
on bidd_dt.schedule_id = mtch_sch.schedule_id  join cte 
on mtch_sch.match_id = cte.match_id)
select Bidder_id, (sum(win_loss)/count(bid_team))*100 as `Toss_Win(%)`
from cte1
group by bidder_id
order by `Toss_Win(%)` desc;


-- 12.	find the IPL season which has a duration and max duration. Output columns should be like the below: Tournment_ID, Tourment_name, Duration column, Max Duration

select * from ipl_tournament;

with cte as(
select tournmt_id, tournmt_name , datediff(to_date,from_date) as duration_days, dense_rank()over(order by datediff( date(to_date),date(from_date)) desc) as rnk
 from ipl_tournament )
select tournmt_id, tournmt_name, duration_days, max(duration_days)over() as maximum_duration from cte
where rnk = 1
;


-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
-- Only use joins for the above query queries.

select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;



select bd.bidder_id , bd.bidder_name , year(bid_date) as yr, month(bid_date) as Mnth, sum(bp.total_points) as cnt
from ipl_bidding_details as bnd join ipl_bidder_details as bd on bnd.bidder_id = bd.bidder_id join ipl_bidder_points as bp on bnd.bidder_id = bp.bidder_id
where year(bid_date) = 2017 
group by bp.bidder_id , bd.bidder_name , year(bid_date) , month(bid_date);
-- order by cnt desc , mnth asc;




-- 14.	Write a query for the above question using sub-queries by having the same constraints as the above question.

select bd.bidder_id , bd.bidder_name , year(bid_date) as yr, month(bid_date) as Mnth, sum(bp.total_points) as cnt
from ipl_bidding_details as bnd join ipl_bidder_details as bd on bnd.bidder_id = bd.bidder_id join ipl_bidder_points as bp on bnd.bidder_id = bp.bidder_id
where year(bid_date) = 2018 
group by bp.bidder_id , bd.bidder_name , year(bid_date) , month(bid_date)
order by cnt desc ;




-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be like :
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

with cte1 as (
select bd.bidder_id , bd.bidder_name , year(bid_date), sum(bp.total_points) as cnt
from ipl_bidding_details as bnd join ipl_bidder_details as bd on bnd.bidder_id = bd.bidder_id join ipl_bidder_points as bp on bnd.bidder_id = bp.bidder_id
where year(bid_date) = 2018 
group by bp.bidder_id , bd.bidder_name
order by cnt desc limit 3 ) ,
cte2 as (
select bd.bidder_id , bd.bidder_name , year(bid_date), sum(bp.total_points) as cnt
from ipl_bidding_details as bnd join ipl_bidder_details as bd on bnd.bidder_id = bd.bidder_id join ipl_bidder_points as bp on bnd.bidder_id = bp.bidder_id
where year(bid_date) = 2018
group by bp.bidder_id , bd.bidder_name 
having cnt <> 0
order by cnt asc limit 3)

select * from cte1
union
select * from cte2;



-- 16.	Create two tables called Student_details and Student_details_backup. (Additional Question - Self Study is required)

-- Table 1: Attributes 							Table 2: Attributes
-- Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

-- Feel free to add more columns the above one is just an example schema.
-- Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in the Student details table. 
-- Every time the students change their details like their mobile number, You need to update their details in the student details table.  
-- Here is one thing you should ensure whenever the new students details come, you should also store them in the Student backup table so that if you modify the details in the student details table, 
-- you will be having the old details safely.
-- You need not insert the records separately into both tables rather Create a trigger in such a way that It should insert the details into the Student back table 
-- when you insert the student details into the student table automatically.'


create table Student_detals (
Student_id int primary key,
Student_name varchar(50) Unique Not Null,
Mail_id varchar(50) Not Null,
Mobile_number int Not Null) ;


create table Student_details_backup (
Student_id int ,
Student_name varchar(50) ,
Mail_id int,
Mobile_numberr int ,
Foreign key (Student_id) references Student_details(student_id) ;
