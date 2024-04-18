create database finalss;
use finalss;

create table screen(movieorder int(2) primary key,screenid int(10),moviename varchar(100),language varchar(50),movieid int(10),capacitysil 
int(3),capacityplat int(3),capacitygold int(3),time enum("10 am","3 pm","7 pm"),duration_min int(3),genre varchar(100));

create table movieorder_screen(movieorder int(2),screenid int(10),foreign key (movieorder) references screen(movieorder));

create table customer(custid int(10) auto_increment,ticketid int(10) ,custname varchar(100),email varchar(50),phoneno int(12),moviename varchar(100),
time ENUM("10 am","3 pm","7 pm"),snack ENUM("popcorn","nachos","coca cola"),class ENUM("silver","gold","platinum"),membership ENUM("yes","no"),movieorder int(2),
foreign key (movieorder) references movieorder_screen(movieorder),primary key (custid));

create table ticket(custid int(10) ,ticketid int(10) auto_increment,moviename varchar(100),class ENUM("silver","gold","platinum"),screenid int(10),
snack ENUM("popcorn","nachos","coca cola"),time ENUM("10 am","3 pm","7 pm"),price int(5) default 100,custname varchar(100),movieorder int(2),
foreign key (custid) references customer(custid) on delete cascade,primary key (ticketid));

CREATE TABLE ratings(custid int(10) primary key,
movieid INT NULL,
moviename VARCHAR(100) NULL,
review VARCHAR(200) NULL,
rating INT(3) NULL DEFAULT 0,foreign key (custid) references customer(custid));

create table member(custid int(10),email varchar(50) primary key,custname varchar(100),foreign key (custid) references customer(custid));


show tables;

insert into ratings(custid,movieid,moviename,review,rating) values 
(1,200,"Barbie","Fantastic",4),
(4,203,"Train To Busan","Amazing",5),
(2,201,"Oppenheimer","Thrilling",4);
select *from ratings;


drop table member;
drop table ratings;
drop table ticket;
drop table customer;
drop table movieorder_screen;
drop table screen;


Delimiter //
create trigger
ticket_insert
after insert 
on customer
for each row
begin
insert into ticket(custid,ticketid,moviename,class,snack,time,custname,movieorder) 
values (new.custid,new.ticketid,new.moviename,new.class,new.snack,new.time,new.custname,new.movieorder);
end //
delimiter ;


DELIMITER \\
CREATE TRIGGER trigger_class_price
BEFORE INSERT
ON ticket
FOR EACH ROW
BEGIN
  IF NEW.class = 'platinum' THEN
    SET NEW.price = NEW.price + 100;
  ELSEIF new.class='silver' THEN
    SET NEW.price = NEW.price + 0;
  ELSEIF new.class='gold' THEN
    SET NEW.price = NEW.price + 50;
  END IF;
END \\
DELIMITER ;

DELIMITER \\
CREATE TRIGGER trigger_snack_price
BEFORE INSERT
ON ticket
FOR EACH ROW
BEGIN
  IF NEW.snack = 'popcorn' THEN
    SET NEW.price = NEW.price + 70;
  ELSEIF new.snack='coca cola' THEN
    SET NEW.price = NEW.price + 50;
  ELSEIF new.snack='nachos' THEN
    SET NEW.price = NEW.price + 100;
  END IF;
END \\
DELIMITER ;

DELIMITER \\
CREATE TRIGGER screen_id_update
BEFORE INSERT
ON ticket
FOR EACH ROW
BEGIN
  IF NEW.movieorder = 1 or NEW.movieorder = 2 or NEW.movieorder = 3  THEN
    SET NEW.screenid = 1;
  ELSEIF NEW.movieorder = 4 or NEW.movieorder = 5 or NEW.movieorder = 6  THEN
    SET NEW.screenid = 2;
  ELSEIF NEW.movieorder = 7 or NEW.movieorder = 8 or NEW.movieorder = 9  THEN
    SET NEW.screenid = 3;
     ELSEIF NEW.movieorder = 10 or NEW.movieorder = 11 or NEW.movieorder = 12  THEN
    SET NEW.screenid = 4;
  END IF;
END \\
DELIMITER ;

Delimiter //
create trigger
member_insert
after insert 
on customer
for each row
begin
IF NEW.membership = 'yes' THEN
insert into member(custid,email,custname) 
values (new.custid,new.email,new.custname);
END IF;
end //
delimiter ;

/*create trigger if capacity is full*/

Delimiter //
create trigger capacity_full
after update 
on screen
for each row
begin
 IF NEW.capacitygold=0 || NEW.capacitysil=0|| NEW.capacityplat=0 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT="booking complete for this session cannot book anymore";
END IF;
end //
delimiter ;
drop trigger capacity_full;



    



/*create trigger update_capacity_gold 
before insert on customer
for each row
UPDATE screen
SET capacitygold=capacitygold-1
where new.class='gold' and time=new.time and moviename=new.moviename; */
drop trigger update_capacity_gold;
drop trigger update_capacity_silver;
drop trigger update_capacity_platinum;

create trigger update_capacity_gold_ticket
before insert on ticket
for each row
UPDATE screen
SET capacitygold=capacitygold-1
where new.class='gold' and time=new.time and moviename=new.moviename; 



/*create trigger update_capacity_silver 
before insert on customer
for each row
UPDATE screen
SET capacitysil=capacitysil-1
where new.class='silver' and time=new.time and moviename=new.moviename;*/ 

create trigger update_capacity_silver_ticket
before insert on ticket
for each row
UPDATE screen
SET capacitysil=capacitysil-1
where new.class='silver' and time=new.time and moviename=new.moviename; 

/*create trigger update_capacity_platinum
before insert on customer
for each row
UPDATE screen
SET capacityplat=capacityplat-1
where new.class='platinum' and time=new.time and moviename=new.moviename;*/

create trigger update_capacity_platinum
before insert on ticket
for each row
UPDATE screen
SET capacityplat=capacityplat-1
where new.class='platinum' and time=new.time and moviename=new.moviename;


create trigger update_capacity_gold_after_delete 
after delete on ticket
for each row
UPDATE screen
SET capacitygold=capacitygold+1
where old.class='gold' and time=old.time and moviename=old.moviename; 

create trigger update_capacity_silver_after_delete 
after delete on ticket
for each row
UPDATE screen
SET capacitysil=capacitysil+1
where old.class='silver' and time=old.time and moviename=old.moviename; 

create trigger update_capacity_platinum_after_delete
after delete on ticket
for each row
UPDATE screen
SET capacityplat=capacityplat+1
where old.class='platinum' and time=old.time and moviename=old.moviename;

Delimiter //
create trigger
movie_order_insert
after insert 
on screen
for each row
begin
insert into movieorder_screen(movieorder,screenid) 
values (new.movieorder,new.screenid);
end //
delimiter ;

insert into screen(movieorder,screenid,moviename,language,movieid,capacitysil,capacityplat,capacitygold,time,duration_min,genre) values
(1,1,"Barbie","Eng/Hindi",200,50,50,50,"10 am",120,"Fantasy"),
(2,1,"Barbie","Eng/Hindi",200,50,50,50,"3 pm",120,"Fantasy"),
(3,1,"Barbie","Eng/Hindi",200,50,50,50,"7 pm",120,"Fantasy"),
(4,2,"Oppenheimer","Eng",201,50,50,50,"10 am",150,"Fantasy"),
(5,2,"Oppenheimer","Eng",201,50,50,50,"3 pm",150,"Fantasy"),
(6,2,"Oppenheimer","Eng",201,50,50,50,"7 pm",150,"Fantasy"),
(7,3,"Phir Hera Pheri","Hindi",202,50,50,50,"10 am",90,"Fantasy"),
(8,3,"Phir Hera Pheri","Hindi",202,50,50,50,"3 pm",90,"Fantasy"),
(9,3,"Phir Hera Pheri","Hindi",202,50,50,50,"7 pm",90,"Fantasy"),
(10,4,"Train To Busan","Korean",203,50,50,50,"10 am",130,"Fantasy"),
(11,4,"Train To Busan","Korean",203,50,50,50,"3 pm",130,"Fantasy"),
(12,4,"Train To Busan","Korean",203,50,50,50,"7 pm",130,"Fantasy");
select *from screen;
select* from movieorder_screen;

insert into customer(ticketid,custname,email,phoneno,moviename,time,snack,class,membership,movieorder) values
(100,"Taneeshka","tan@gmail.com",935927534,"Barbie",'10 am','popcorn','silver','yes',1),
(101,"Natalie","nat@gmail.com",935927567,"Oppenheimer",'3 pm','nachos','gold','yes',5),
(102,"Matt","matt@gmail.com",935923467,"Phir Hera Pheri",'3 pm','coca cola','platinum','no',8),
(103,"John","john@gmail.com",934927567,"Barbie",'7 pm','nachos','silver','yes',3),
(104,"Meghan","meg@gmail.com",944927567,"Train To Busan",'10 am','popcorn','gold','yes',10);
select *from customer;
select *from ticket;
select *from member;
insert into ticket(custid,ticketid,moviename,class,screenid,snack,time,price,custname,movieorder) values
(5,104,"Train To Busan","gold",4,"popcorn","10 am",100,"Meghan",10);

-- queries

-- query to give discount to member
UPDATE ticket
INNER JOIN member ON ticket.custname = member.custname
SET ticket.price=ticket.price-25
WHERE ticket.custname = member.custname;
select *from ticket;

-- query to set the screen id's for the movies showing each day
-- UPDATE ticket
-- INNER JOIN screen ON ticket.moviename=screen.moviename
-- SET ticket.screenid=screen.screenid
-- WHERE ticket.moviename=screen.moviename;

-- Displaying movieid, moviename which have runtime >= 120
SELECT DISTINCT movieid, moviename, language, genre FROM screen WHERE duration_min>=120;

-- Gives info on people who are watching oppenheimer.
SELECT custid, ticketid, custname, time FROM customer WHERE moviename="Oppenheimer";


-- Gives info on moives which have rating > 3.
SELECT DISTINCT n.moviename,n.language,s.genre,r.review
FROM screen s ,ratings r
WHERE s.moviename=r.moviename AND r.rating>3;



-- Checking who has taken silver seat + popcorn
SELECT custname, phoneno FROM customer WHERE snack="popcorn" AND class="silver";



-- creating views
CREATE VIEW runtime_above_120mins AS
SELECT DISTINCT movieid, moviename, language, genre FROM screen WHERE duration_min>=120;
select* from runtime_above_120mins;

CREATE VIEW people_watching_oppenheimer AS
SELECT custid, ticketid, custname, time FROM customer WHERE moviename="Oppenheimer";
select* from people_watching_oppenheimer;

CREATE VIEW RATING_ABOVE_3 AS
SELECT DISTINCT s.moviename,s.language,s.genre,r.review
FROM screen s ,ratings r
WHERE s.moviename=r.moviename AND r.rating>3;
select *from rating_above_3;



CREATE VIEW tickets_sold AS
SELECT moviename,COUNT(moviename) as tickets_sold from ticket
GROUP BY moviename;
select *from tickets_sold;

-- cancelling ticket
delete from ticket where custid=5;
select *from ticket;
select *from customer;

/*update screen set capacitygold=50 where moviename="Train To Busan" and time="10 am";*/

