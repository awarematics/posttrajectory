select sum(m.mpcount) from taxi as t, mpseq_1101121_traj as m where (t.traj).moid = m.mpid and sum(m.mpcount) > 10000;


select * from taxi as t, mpseq_1101121_traj as m where (t.traj).moid = m.mpid limit 100;

select count(*) as cnt, sum(mpcount), mpid from mpseq_1101121_traj group by mpid having sum(mpcount) > 2100;


select sum(mpcount), mpid from mpseq_1696788_traj group by mpid having sum(mpcount) > 2000;

select sum(mpcount), mpid from mpseq_1696788_traj group by mpid having sum(mpcount) > 1500 and sum(mpcount) < 2000;

select sum(mpcount), mpid from mpseq_1696788_traj group by mpid having sum(mpcount) > 1500  4756

select sum(mpcount), mpid from mpseq_1696788_traj group by mpid having sum(mpcount) > 1500 and sum(mpcount) < 1600;  554

select sum(mpcount), mpid from mpseq_1696788_traj group by mpid having sum(mpcount) > 1600; 4194


select sum(mpcount), mpid from mpseq_1696788_traj group by mpid having sum(mpcount) > 1500 order by sum(mpcount) desc limit 4700;

select licenseplate from t_drive_data group by licenseplate having sum(mpcount) > 2500;

select licenseplate, count(licenseplate) from t_drive_data group by licenseplate having count(licenseplate) > 1500 order by count(licenseplate) desc limit 4700;

select licenseplate, count(licenseplate) from t_drive_data group by licenseplate having count(licenseplate) > 2100

select count(*) from t_drive_data where licenseplate = '131';


main_sql := 'select mpid from mpseq_1101138_traj group by mpid having sum(mpcount) > 2100 and mpid !=0 order by mpid;';