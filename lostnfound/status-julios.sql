select julios_next_check::date, julios_status, julios_transfer_id,
count(1), sum(amount/100)
 from votolegal_donation a
 join votolegal_donation_immutable b on b.votolegal_donation_id = a.id
 where captured_at is not null and candidate_id= 78 and julios_status='waiting' group by 1,2,3 order by 1;
