-- Country Club case study, Tier 2: Part 1 (MySQL / phpMyAdmin)
USE country_club;

-- Q1: Facilities that charge members
SELECT name FROM Facilities WHERE membercost > 0;

-- Q2: Count of free facilities
SELECT COUNT(*) AS free_facilities FROM Facilities WHERE membercost = 0;

-- Q3: Paid facilities below 20% maintenance
SELECT facid, name, membercost, monthlymaintenance FROM Facilities WHERE membercost > 0 AND membercost < monthlymaintenance * 0.20;

-- Q4: Facilities with IDs 1 and 5
SELECT * FROM Facilities WHERE facid IN (1, 5);

-- Q5: Cheap versus expensive facilities
SELECT name, monthlymaintenance, CASE WHEN monthlymaintenance > 100 THEN 'expensive' ELSE 'cheap' END AS cost_category FROM Facilities;

-- Q6: Most recent member(s)
SELECT firstname, surname FROM Members WHERE joindate = (SELECT MAX(joindate) FROM Members);

-- Q7: Distinct tennis court users
SELECT DISTINCT f.name AS court, CONCAT(m.firstname, ' ', m.surname) AS member FROM Bookings b JOIN Facilities f ON b.facid = f.facid JOIN Members m ON b.memid = m.memid WHERE f.name LIKE 'Tennis Court%' AND m.memid <> 0 ORDER BY member;

-- Q8: Bookings costing over $30 on September 14 (no subquery)
SELECT f.name AS facility, CONCAT(m.firstname, ' ', m.surname) AS member, CASE WHEN b.memid = 0 THEN b.slots * f.guestcost ELSE b.slots * f.membercost END AS cost FROM Bookings b JOIN Facilities f ON b.facid = f.facid JOIN Members m ON b.memid = m.memid WHERE b.starttime >= '2012-09-14' AND b.starttime < '2012-09-15' AND (CASE WHEN b.memid = 0 THEN b.slots * f.guestcost ELSE b.slots * f.membercost END) > 30 ORDER BY cost DESC;

-- Q9: Same bookings using a subquery
SELECT facility, member, cost FROM (SELECT f.name AS facility, CONCAT(m.firstname, ' ', m.surname) AS member, CASE WHEN b.memid = 0 THEN b.slots * f.guestcost ELSE b.slots * f.membercost END AS cost, b.starttime FROM Bookings b JOIN Facilities f ON b.facid = f.facid JOIN Members m ON b.memid = m.memid) AS booking_costs WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15' AND cost > 30 ORDER BY cost DESC;

-- Part 2 queries below use SQLite syntax; execute them in SQLite, not phpMyAdmin.
-- Country Club case study, Tier 2: Part 2 (SQLite)

-- Q10: Facilities with revenue below 1000
SELECT f.name AS facility, ROUND(SUM(CASE WHEN b.memid = 0 THEN b.slots * f.guestcost ELSE b.slots * f.membercost END), 2) AS revenue FROM Facilities f JOIN Bookings b ON f.facid = b.facid GROUP BY f.facid, f.name HAVING SUM(CASE WHEN b.memid = 0 THEN b.slots * f.guestcost ELSE b.slots * f.membercost END) < 1000 ORDER BY revenue;

-- Q11: Members and their recommenders
SELECT m.surname || ', ' || m.firstname AS member, r.surname || ', ' || r.firstname AS recommended_by FROM Members m LEFT JOIN Members r ON CAST(m.recommendedby AS INTEGER) = r.memid WHERE m.memid <> 0 ORDER BY m.surname, m.firstname;

-- Q12: Facility usage excluding guests
SELECT f.name AS facility, COUNT(*) AS bookings, SUM(b.slots) AS slots_used FROM Facilities f JOIN Bookings b ON f.facid = b.facid WHERE b.memid <> 0 GROUP BY f.facid, f.name ORDER BY facility;

-- Q13: Monthly facility usage excluding guests
SELECT f.name AS facility, strftime('%Y-%m', b.starttime) AS month, COUNT(*) AS bookings, SUM(b.slots) AS slots_used FROM Facilities f JOIN Bookings b ON f.facid = b.facid WHERE b.memid <> 0 GROUP BY f.facid, f.name, strftime('%Y-%m', b.starttime) ORDER BY facility, month;
