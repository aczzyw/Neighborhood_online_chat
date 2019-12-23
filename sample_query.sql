/* joining */
/* check sign up or not */
select * 
from user
where uemail = 'aczzyw@gmail.com';

/* apply to become a member of a block */
insert into `applies`(`uid`, `bid`, `acount`) values
(1, 1, 0);

/* check if block members' number < 3 */
select count(uid)
from ins
where bid = 1;

/* accpet block new members */
update `applies` set acount = 1
where uid = 1;

/* if being accepted, delete from applies and insert into ins */
delete from `applies`
	   where uid = 1;
       
insert into `ins`(`uid`, `bid`) values
(1, 1); 

/* create profile & update profile*/
update `user` 
set 
	uprofile = 'add some thing',
    uphoto = 'url'
where uid = 1;

/* content posting */
/* start a new topic */
insert into `topic`(`tid`, `tsubject`, `ttype`) values
(1, 'dog', 'friend'),
(2, 'cat', 'neighbor'),
(3, 'car', 'block'),
(4, 'food', 'hood');

insert into `posts`(`uid`, `tid`) values
(2, 1),
(2, 2),
(2, 3), 
(2, 4);

/* specify who can chat under this topic */
insert into `specifies`(`tid`, `uid`) values
(2, 2), 
(3, 2),
(4, 2);

/* start a new thread with an initial message, also who can access */
insert into `thread`(`thid`) values
(1);

insert into `contains`(`tid`, `thid`) values
(1, 1);

insert into `message`(`mid`, `uid`, `mtitle`, `mtimestamp`, `mtext`, `mx`, `my`) values
(1, 1, 'How to feed a dog', '2019-11-25 00:00:00', 'Do you have a dog?', 0, 0);

insert into `has`(`thid`, `mid`) values
(1, 1);

insert into `accesses`(`mid`, `uid`) values
(1, 1);

/* replies the message */
insert into `message`(`mid`, `uid`, `mtitle`, `mtimestamp`, `mtext`, `mx`, `my`) values
(2, 2, 'A reply', '2019-11-25 01:00:00', 'Dogs like meat.', 0, 0);

insert into `has`(`thid`, `mid`) values
(1, 2);

insert into `accesses`(`mid`, `uid`) values
(2, 1);

/* friendship */
/* add someone as a friend or neighbor */
insert into `friends`(`uid`, `fid`) values
(1, 2),
(2, 1);

insert into `neighbors`(`uid`, `nid`) values
(1, 2);

/* lists friends and neighbors */
select f1.fid
from friends as f1, friends as f2
where f1.uid = f2.fid and f1.fid = f2.uid and f1.uid = 1;

select nid
from neighbors
where uid = 1;

/* browse and search message */
/* list all threads in a user’s block feed having new messages since the
last time the user accessed the system */
create view block_topic as
select tid
from topic natural join specifies
where topic.ttype = 'block' and specifies.uid = 2;

create view block_thread as
select thid
from `contains` join block_topic on `contains`.tid = block_topic.tid;

create view accessable_message as
select has.thid as thid, has.mid as mid
from (block_thread join has on block_thread.thid = has.thid) join accesses on has.mid = accesses.mid
where uid = 2;

select thid
from accessable_message natural join message, lastvisit
where lastvisit.uid = 2 and lastvisit.ltimestamp < message.mtimestamp;

drop view block_topic;
drop view block_thread;
drop view accessable_message;

/* all threads in friend feed that have unread messages */
create view friend_topic as
select tid
from topic natural join specifies
where topic.ttype = 'friend' and specifies.uid = 2;

create view friend_thread as
select thid
from `contains` join friend_topic on `contains`.tid = friend_topic.tid;

create view accessable_message as
select has.thid as thid, has.mid as mid
from (friend_thread join has on friend_thread.thid = has.thid) join accesses on has.mid = accesses.mid
where uid = 2;

insert into `unreads`(`uid`, `mid`)
select lastvisit.uid, message.mid
from accessable_message natural join message, lastvisit
where lastvisit.uid = 2 and lastvisit.ltimestamp < message.mtimestamp;

drop view friend_topic;
drop view friend_thread;
drop view accessable_message;

/* all messages containing the words “bicycle accident” across all feeds that the user can access */
select message.mid
from accesses join message on accesses.mid = message.mid
where accesses.uid = 2 and mtext like '%bicycle accident%'